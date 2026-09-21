#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$SourceRoot = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总',
    [string]$MergeScript = '',
    [string]$AcceptedSignoffRelativePath = '审计/子代理交接/aws_signoff_rebase/aws-signoff-rebase.csv'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\')
$WorkRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($MergeScript)) { $MergeScript = Join-Path $WorkRoot 'Invoke-AwsPackageMerge.ps1' }
$MergeScript = (Resolve-Path -LiteralPath $MergeScript).Path
$Validator = Join-Path $SourceRoot 'scripts\validation\Validate-ResearchData.ps1'
$OldSignoff = Join-Path $SourceRoot '审计\子代理交接\m2_final_review_aws_package_merge_signoff.csv'
$GoogleBackup = Join-Path $SourceRoot '审计\合并备份\M2-W2-GOOGLE-CLOUD-DEVICE-SOURCES-20260813'
$ExpectedOldAggregate = '0b4c6106bde7e2a62b1ffd6a0df7246ded62177d941c7fb9303a2cbac62f92bf'
$ExpectedCurrentAggregate = '97ebb17a2518e3a43b18a382dcfc879c1f5e2b08118a6149c8fa984e65017453'
$MarkerText = 'M2-W2-AWS-PACKAGE-FACTS-ISOLATED-REHEARSAL'
$runRoot = Join-Path $WorkRoot ('.tmp-aws-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$junctions = [System.Collections.Generic.List[string]]::new()
$script:Checks = 0

function Assert-Check {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
    $script:Checks++
}

function Get-Sha256 {
    param([string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-TextSha256 {
    param([string]$Text)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($encoding.GetBytes($Text))).Replace('-', '').ToLowerInvariant()) }
    finally { $sha.Dispose() }
}

function Write-CsvNoBom {
    param([string]$Path, [object[]]$Rows)
    Assert-Check ($Rows.Count -gt 0) "Refusing to write empty CSV: $Path"
    $text = (@($Rows | ConvertTo-Csv -NoTypeInformation) -join "`r`n") + "`r`n"
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, $text, $encoding)
    Assert-Check (Test-Path -LiteralPath $Path -PathType Leaf) "CSV was not written: $Path"
}

function Write-Utf8Text {
    param([string]$Path, [string]$Text)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, $Text, $encoding)
}

function Get-SchemaInfo {
    $schema = @(Import-Csv -LiteralPath (Join-Path $SourceRoot '数据\schema-columns.csv') -Encoding UTF8)
    $paths = @($schema.table_path | Sort-Object -Unique)
    Assert-Check ($paths.Count -eq 32) 'Formal schema does not contain 32 tables.'
    return [pscustomobject]@{ Rows = $schema; Paths = $paths }
}

function Get-FormalHashes {
    param([string]$Root, [string[]]$TablePaths)
    $result = foreach ($relative in ($TablePaths | Sort-Object)) {
        $path = Join-Path $Root $relative.Replace('/', '\')
        Assert-Check (Test-Path -LiteralPath $path -PathType Leaf) "Formal table is missing: $path"
        [pscustomobject][ordered]@{ table_path = $relative; sha256 = Get-Sha256 $path }
    }
    return @($result)
}

function Get-FormalAggregate {
    param([object[]]$Hashes)
    $lines = @($Hashes | Sort-Object table_path | ForEach-Object { $_.table_path + '|' + $_.sha256 })
    return Get-TextSha256 ($lines -join "`n")
}

function Assert-SafeRunPath {
    param([string]$Path)
    $workPrefix = [IO.Path]::GetFullPath($WorkRoot).TrimEnd('\') + '\'
    $full = [IO.Path]::GetFullPath($Path)
    Assert-Check ($full.StartsWith($workPrefix, [StringComparison]::OrdinalIgnoreCase)) "Unsafe rehearsal path: $full"
    Assert-Check ((Split-Path -Leaf $full).StartsWith('.tmp-aws-', [StringComparison]::Ordinal)) "Unexpected rehearsal directory name: $full"
}

function Remove-SafeRunRoot {
    param([string]$Path)
    Assert-SafeRunPath $Path
    foreach ($junction in @($junctions | Sort-Object Length -Descending)) {
        if (Test-Path -LiteralPath $junction) {
            $item = Get-Item -LiteralPath $junction -Force
            Assert-Check ([bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) "Refusing to remove non-junction as junction: $junction"
            [IO.Directory]::Delete($junction)
        }
    }
    if (Test-Path -LiteralPath $Path) { Remove-Item -LiteralPath $Path -Recurse -Force }
    Assert-Check (-not (Test-Path -LiteralPath $Path)) 'Temporary rehearsal root was not removed.'
}

function New-IsolatedBase {
    param([string]$TargetRoot, [bool]$RestoreSignedPreGoogleBaseline)
    [IO.Directory]::CreateDirectory($TargetRoot) | Out-Null
    Write-Utf8Text -Path (Join-Path $TargetRoot '.aws-merge-isolated-target') -Text $MarkerText
    foreach ($relative in $schemaInfo.Paths) {
        $source = Join-Path $SourceRoot $relative.Replace('/', '\')
        $target = Join-Path $TargetRoot $relative.Replace('/', '\')
        [IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
        [IO.File]::Copy($source, $target, $false)
    }
    if ($RestoreSignedPreGoogleBaseline) {
        foreach ($relative in @('最小参考资料库/source-families.csv', '最小参考资料库/sources.csv', '最小参考资料库/source-endpoints.csv')) {
            $source = Join-Path $GoogleBackup $relative.Replace('/', '\')
            $target = Join-Path $TargetRoot $relative.Replace('/', '\')
            Assert-Check (Test-Path -LiteralPath $source -PathType Leaf) "Google premerge backup is missing: $source"
            [IO.File]::Copy($source, $target, $true)
        }
    }
    $cardSource = Join-Path $SourceRoot '资料卡'
    $cardTarget = Join-Path $TargetRoot '资料卡'
    Copy-Item -LiteralPath $cardSource -Destination $cardTarget -Recurse
    Assert-Check (Test-Path -LiteralPath $cardTarget -PathType Container) 'Card tree copy failed.'
}

function Add-ValidatorDependencies {
    param([string]$TargetRoot)
    $paperJunction = Join-Path $TargetRoot '论文'
    New-Item -ItemType Junction -Path $paperJunction -Target (Join-Path $SourceRoot '论文') | Out-Null
    $junctions.Add($paperJunction)
    $snapshotTarget = Join-Path $TargetRoot '最小参考资料库\快照'
    [IO.Directory]::CreateDirectory($snapshotTarget) | Out-Null
    foreach ($vendor in @('AMD', 'Google', 'NVIDIA', '寒武纪')) {
        $source = Join-Path $SourceRoot ('最小参考资料库\快照\' + $vendor)
        if (Test-Path -LiteralPath $source -PathType Container) {
            $junction = Join-Path $snapshotTarget $vendor
            New-Item -ItemType Junction -Path $junction -Target $source | Out-Null
            $junctions.Add($junction)
        }
    }
    $awsTarget = Join-Path $snapshotTarget 'AWS'
    [IO.Directory]::CreateDirectory($awsTarget) | Out-Null
    $trainium2Source = Join-Path $SourceRoot '最小参考资料库\快照\AWS\Trainium2'
    $trainium2Junction = Join-Path $awsTarget 'Trainium2'
    New-Item -ItemType Junction -Path $trainium2Junction -Target $trainium2Source | Out-Null
    $junctions.Add($trainium2Junction)
}

function Get-PkColumn {
    param([string]$TablePath)
    $columns = @($schemaInfo.Rows | Where-Object { $_.table_path -ceq $TablePath -and $_.is_primary_key -ceq 'true' })
    Assert-Check ($columns.Count -eq 1) "Expected one PK for $TablePath."
    return $columns[0].column_name
}

function Get-RowHash {
    param([object]$Row)
    $values = @($Row.PSObject.Properties | ForEach-Object { [string]$_.Value })
    return Get-TextSha256 ($values -join [char]31)
}

function Build-RebaseAudit {
    $oldHashes = [System.Collections.Generic.List[object]]::new()
    foreach ($relative in $schemaInfo.Paths) {
        $backupCandidate = Join-Path $GoogleBackup $relative.Replace('/', '\')
        $oldPath = if (Test-Path -LiteralPath $backupCandidate -PathType Leaf) { $backupCandidate } else { Join-Path $SourceRoot $relative.Replace('/', '\') }
        $currentPath = Join-Path $SourceRoot $relative.Replace('/', '\')
        $oldHashes.Add([pscustomobject][ordered]@{ table_path = $relative; signed_pre_google_sha256 = Get-Sha256 $oldPath; current_post_google_sha256 = Get-Sha256 $currentPath; changed = ([string]((Get-Sha256 $oldPath) -cne (Get-Sha256 $currentPath))).ToLowerInvariant() })
    }
    Write-CsvNoBom -Path (Join-Path $WorkRoot 'current-baseline-table-diff.csv') -Rows @($oldHashes)
    $changedTables = @($oldHashes | Where-Object changed -ceq 'true')
    Assert-Check ($changedTables.Count -eq 3) "Expected three Google-changed formal tables; found $($changedTables.Count)."

    $pkDiff = [System.Collections.Generic.List[object]]::new()
    foreach ($table in $changedTables) {
        $relative = $table.table_path
        $pk = Get-PkColumn $relative
        $oldPath = Join-Path $GoogleBackup $relative.Replace('/', '\')
        $currentPath = Join-Path $SourceRoot $relative.Replace('/', '\')
        $oldRows = @(Import-Csv -LiteralPath $oldPath -Encoding UTF8)
        $newRows = @(Import-Csv -LiteralPath $currentPath -Encoding UTF8)
        $oldMap = @{}
        $newMap = @{}
        foreach ($row in $oldRows) { $oldMap[[string]$row.$pk] = $row }
        foreach ($row in $newRows) { $newMap[[string]$row.$pk] = $row }
        $keys = @($oldMap.Keys + $newMap.Keys | Sort-Object -Unique)
        foreach ($key in $keys) {
            $oldPresent = $oldMap.ContainsKey($key)
            $newPresent = $newMap.ContainsKey($key)
            $oldHash = if ($oldPresent) { Get-RowHash $oldMap[$key] } else { '' }
            $newHash = if ($newPresent) { Get-RowHash $newMap[$key] } else { '' }
            if ($oldHash -cne $newHash) {
                $change = if (-not $oldPresent) { 'append' } elseif (-not $newPresent) { 'delete' } else { 'update' }
                $pkDiff.Add([pscustomobject][ordered]@{ table_path = $relative; pk_column = $pk; pk_value = $key; change_type = $change; signed_pre_google_row_sha256 = $oldHash; current_post_google_row_sha256 = $newHash })
            }
        }
    }
    Write-CsvNoBom -Path (Join-Path $WorkRoot 'current-baseline-pk-diff.csv') -Rows @($pkDiff)

    $oldSignoffRows = @(Import-Csv -LiteralPath $OldSignoff -Encoding UTF8)
    $awsWrites = @($oldSignoffRows | Where-Object { $_.authorization_scope -ceq 'lifecycle_pk_write' })
    $conflicts = foreach ($diff in $pkDiff) {
        $matches = @($awsWrites | Where-Object { $_.target_path -ceq $diff.table_path -and $_.pk_column -ceq $diff.pk_column -and $_.pk_value -ceq $diff.pk_value })
        [pscustomobject][ordered]@{
            table_path = $diff.table_path
            pk_column = $diff.pk_column
            pk_value = $diff.pk_value
            google_change_type = $diff.change_type
            aws_authorized_write_count = $matches.Count
            aws_signoff_row_ids = (@($matches | ForEach-Object { $_.signoff_row_id }) -join ';')
            conflict = ([string]($matches.Count -gt 0)).ToLowerInvariant()
        }
    }
    Write-CsvNoBom -Path (Join-Path $WorkRoot 'aws-google-write-set-conflict-audit.csv') -Rows @($conflicts)
    Assert-Check (@($conflicts | Where-Object conflict -ceq 'true').Count -eq 0) 'AWS and Google row-level write sets overlap.'

    $currentHashes = Get-FormalHashes -Root $SourceRoot -TablePaths $schemaInfo.Paths
    $currentHashMap = @{}
    foreach ($row in $currentHashes) { $currentHashMap[$row.table_path] = $row.sha256 }
    $currentAggregate = Get-FormalAggregate $currentHashes
    $candidateRows = foreach ($row in $oldSignoffRows) {
        $proposedTargetHash = $row.formal_target_premerge_sha256
        if (-not [string]::IsNullOrWhiteSpace($row.formal_target_premerge_sha256) -and $currentHashMap.ContainsKey($row.target_path)) { $proposedTargetHash = $currentHashMap[$row.target_path] }
        [pscustomobject][ordered]@{
            signoff_row_id = $row.signoff_row_id
            authorization_scope = $row.authorization_scope
            target_path = $row.target_path
            pk_column = $row.pk_column
            pk_value = $row.pk_value
            old_formal_target_premerge_sha256 = $row.formal_target_premerge_sha256
            proposed_formal_target_premerge_sha256 = $proposedTargetHash
            target_hash_changed = ([string]($row.formal_target_premerge_sha256 -cne $proposedTargetHash)).ToLowerInvariant()
            old_formal_baseline_aggregate_sha256 = $row.formal_baseline_aggregate_sha256
            proposed_formal_baseline_aggregate_sha256 = $currentAggregate
            aggregate_changed = ([string]($row.formal_baseline_aggregate_sha256 -cne $currentAggregate)).ToLowerInvariant()
            row_level_write_set_conflict = 'false'
            candidate_status = 'candidate_only_not_authorized'
        }
    }
    Write-CsvNoBom -Path (Join-Path $WorkRoot 'resign-candidate.csv') -Rows @($candidateRows)
    return [pscustomobject]@{ CurrentAggregate = $currentAggregate; ChangedTables = $changedTables.Count; ChangedPks = $pkDiff.Count; Conflicts = 0; CandidateRows = $candidateRows.Count }
}

Assert-SafeRunPath $runRoot
Assert-Check (Test-Path -LiteralPath $MergeScript -PathType Leaf) 'Merge script is missing.'
Assert-Check (Test-Path -LiteralPath $Validator -PathType Leaf) 'Formal validator is missing.'
Assert-Check (Test-Path -LiteralPath $OldSignoff -PathType Leaf) 'Old signoff is missing.'
Assert-Check (Test-Path -LiteralPath $GoogleBackup -PathType Container) 'Google premerge backup is missing.'
$schemaInfo = Get-SchemaInfo
$formalBefore = Get-FormalHashes -Root $SourceRoot -TablePaths $schemaInfo.Paths
$currentAggregate = Get-FormalAggregate $formalBefore
Assert-Check ($currentAggregate -ceq $ExpectedCurrentAggregate) "Current aggregate differs: $currentAggregate"
$rebaseAudit = Build-RebaseAudit
Assert-Check ($rebaseAudit.CurrentAggregate -ceq $ExpectedCurrentAggregate) 'Rebase audit current aggregate differs.'

$oldSignoffRoot = Join-Path $runRoot 'o'
$existingTargetRoot = Join-Path $runRoot 'e'
$positiveRoot = Join-Path $runRoot 'p'
$oldSignoffOutput = @()
$existingTargetOutput = @()
$positiveOutput = @()
$validatorOutput = @()
$oldSignoffExit = -1
$existingTargetExit = -1
$positiveExit = -1
$validatorExit = -1
try {
    New-IsolatedBase -TargetRoot $oldSignoffRoot -RestoreSignedPreGoogleBaseline $false
    $oldSignoffHashesBefore = Get-FormalHashes -Root $oldSignoffRoot -TablePaths $schemaInfo.Paths
    $savedErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $oldSignoffOutput = @(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $MergeScript -SourceRoot $SourceRoot -TargetRoot $oldSignoffRoot -SignoffRelativePath '审计/子代理交接/m2_final_review_aws_package_merge_signoff.csv' 2>&1)
        $oldSignoffExit = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $savedErrorActionPreference }
    Write-Utf8Text -Path (Join-Path $WorkRoot 'negative-old-signoff.txt') -Text (($oldSignoffOutput -join "`r`n") + "`r`n")
    Assert-Check ($oldSignoffExit -ne 0) 'Old signoff was unexpectedly accepted by the rebase-bound merge script.'
    Assert-Check (($oldSignoffOutput -join "`n") -match 'Signoff SHA-256 does not match') 'Old signoff was not rejected at the signoff SHA gate.'
    $oldSignoffHashesAfter = Get-FormalHashes -Root $oldSignoffRoot -TablePaths $schemaInfo.Paths
    foreach ($before in $oldSignoffHashesBefore) {
        $after = @($oldSignoffHashesAfter | Where-Object table_path -ceq $before.table_path)[0]
        Assert-Check ($before.sha256 -ceq $after.sha256) "Old-signoff test changed a formal table: $($before.table_path)"
    }
    New-IsolatedBase -TargetRoot $existingTargetRoot -RestoreSignedPreGoogleBaseline $false
    $existingHashesBefore = Get-FormalHashes -Root $existingTargetRoot -TablePaths $schemaInfo.Paths
    $sentinelTarget = Join-Path $existingTargetRoot '资料卡\AWS\封装\AWS_Inferentia1_芯片实现资料卡.md'
    [IO.Directory]::CreateDirectory((Split-Path -Parent $sentinelTarget)) | Out-Null
    Write-Utf8Text -Path $sentinelTarget -Text 'PREEXISTING-SENTINEL'
    $sentinelHashBefore = Get-Sha256 $sentinelTarget
    $savedErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $existingTargetOutput = @(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $MergeScript -SourceRoot $SourceRoot -TargetRoot $existingTargetRoot -SignoffRelativePath $AcceptedSignoffRelativePath 2>&1)
        $existingTargetExit = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $savedErrorActionPreference }
    Write-Utf8Text -Path (Join-Path $WorkRoot 'negative-existing-target.txt') -Text (($existingTargetOutput -join "`r`n") + "`r`n")
    Assert-Check ($existingTargetExit -ne 0) 'Pre-existing authorized target was unexpectedly overwritten.'
    Assert-Check (($existingTargetOutput -join "`n") -match 'Authorized copy target already exists') 'Existing-target test did not fail at the copy preflight gate.'
    $existingHashesAfter = Get-FormalHashes -Root $existingTargetRoot -TablePaths $schemaInfo.Paths
    foreach ($before in $existingHashesBefore) {
        $after = @($existingHashesAfter | Where-Object table_path -ceq $before.table_path)[0]
        Assert-Check ($before.sha256 -ceq $after.sha256) "Existing-target test changed a formal table: $($before.table_path)"
    }
    Assert-Check ((Get-Sha256 $sentinelTarget) -ceq $sentinelHashBefore) 'Pre-existing target sentinel was changed.'
    Assert-Check (-not (Test-Path -LiteralPath (Join-Path $existingTargetRoot '最小参考资料库\快照\AWS\PackageImplementations'))) 'Existing-target test copied snapshots before stopping.'
    New-IsolatedBase -TargetRoot $positiveRoot -RestoreSignedPreGoogleBaseline $false
    $positiveAggregate = Get-FormalAggregate (Get-FormalHashes -Root $positiveRoot -TablePaths $schemaInfo.Paths)
    Assert-Check ($positiveAggregate -ceq $ExpectedCurrentAggregate) "Current signed baseline differs: $positiveAggregate"
    Add-ValidatorDependencies -TargetRoot $positiveRoot
    $savedErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        
$positiveOutput = @(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $MergeScript -SourceRoot $SourceRoot -TargetRoot $positiveRoot -SignoffRelativePath $AcceptedSignoffRelativePath 2>&1)
        $positiveExit = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $savedErrorActionPreference }
    Write-Utf8Text -Path (Join-Path $WorkRoot 'positive-signed-baseline.txt') -Text (($positiveOutput -join "`r`n") + "`r`n")
    Assert-Check ($positiveExit -eq 0) "Signed-baseline merge failed with exit code $positiveExit."
    Assert-Check (($positiveOutput -join "`n") -match '"status":"PASS"') 'Signed-baseline merge did not report PASS.'

    $validatorOutput = @(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $Validator -RootPath $positiveRoot 2>&1)
    $validatorExit = $LASTEXITCODE
    Write-Utf8Text -Path (Join-Path $WorkRoot 'validator-signed-baseline.txt') -Text (($validatorOutput -join "`r`n") + "`r`n")
    Assert-Check ($validatorExit -eq 0) "Formal validator failed with exit code $validatorExit."
    Assert-Check (($validatorOutput -join "`n") -match '101311 checks executed') 'Formal validator count is not 101311.'
}
finally {
    if (Test-Path -LiteralPath $runRoot) { Remove-SafeRunRoot $runRoot }
}

$formalAfter = Get-FormalHashes -Root $SourceRoot -TablePaths $schemaInfo.Paths
$integrity = foreach ($before in $formalBefore) {
    $after = @($formalAfter | Where-Object table_path -ceq $before.table_path)[0]
    [pscustomobject][ordered]@{ table_path = $before.table_path; before_sha256 = $before.sha256; after_sha256 = $after.sha256; unchanged = ([string]($before.sha256 -ceq $after.sha256)).ToLowerInvariant() }
}
Write-CsvNoBom -Path (Join-Path $WorkRoot 'formal-hash-integrity.csv') -Rows @($integrity)
Assert-Check (@($integrity | Where-Object unchanged -cne 'true').Count -eq 0) 'Current formal table hashes changed during rehearsal.'
$formalAfterAggregate = Get-FormalAggregate $formalAfter
Assert-Check ($formalAfterAggregate -ceq $currentAggregate) 'Current formal aggregate changed during rehearsal.'

$mergeResultLine = @($positiveOutput | Where-Object { [string]$_ -match '^\{"status":"PASS"' } | Select-Object -Last 1)
Assert-Check ($mergeResultLine.Count -eq 1) 'Merge PASS JSON is missing.'
$mergeResult = $mergeResultLine[0] | ConvertFrom-Json
$summary = [pscustomobject][ordered]@{
    status = 'PASS'
    rehearsal_checks = $script:Checks
    merge_checks = [int]$mergeResult.checks
    authorized_writes = [int]$mergeResult.authorized_writes
    no_write_guards = [int]$mergeResult.no_write_guards
    old_signoff_sha_rejection_exit = $oldSignoffExit
    negative_existing_target_exit = $existingTargetExit
    positive_current_rebase_exit = $positiveExit
    formal_validator_exit = $validatorExit
    formal_validator_checks = 101311
    current_post_google_aggregate = $currentAggregate
    signed_pre_google_aggregate = $ExpectedOldAggregate
    google_changed_tables = $rebaseAudit.ChangedTables
    google_changed_primary_keys = $rebaseAudit.ChangedPks
    aws_google_write_set_conflicts = $rebaseAudit.Conflicts
    resign_candidate_rows = $rebaseAudit.CandidateRows
    current_formal_tables_unchanged = 32
    temporary_root_removed = $true
}
$summaryJson = $summary | ConvertTo-Json
Write-Utf8Text -Path (Join-Path $WorkRoot 'validation-summary.json') -Text ($summaryJson + "`r`n")
$summary | ConvertTo-Json -Compress
