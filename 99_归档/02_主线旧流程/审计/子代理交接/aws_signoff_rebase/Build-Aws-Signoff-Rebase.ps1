#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = '.'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $RootPath).Path
$outDir = Join-Path $root '审计\子代理交接\aws_signoff_rebase'
$oldSignoffPath = Join-Path $root '审计\子代理交接\m2_final_review_aws_package_merge_signoff.csv'
$oldAwsReportPath = Join-Path $root '审计\子代理交接\m2_final_review_aws_package.md'
$googleReviewPath = Join-Path $root '审计\子代理交接\m2_final_review_google_cloud_device.md'
$googleAcceptancePath = Join-Path $root '审计\M2_第二波_Google云端器件来源门正式验收.md'
$googleBackupDir = Join-Path $root '审计\合并备份\M2-W2-GOOGLE-CLOUD-DEVICE-SOURCES-20260813'
$googleBackupManifestPath = Join-Path $googleBackupDir 'backup-hashes.csv'
$bindingId = 'AWS-SIGNOFF-REBASE-GOOGLE-SOURCE-GATE-20260813'
$expectedOriginalSignoffHash = '58f2368764e4fb132fe63a5acc427f22cdace7c38538270a7457e566d19bbd05'
$expectedOldAggregate = '0b4c6106bde7e2a62b1ffd6a0df7246ded62177d941c7fb9303a2cbac62f92bf'
$expectedCurrentAggregate = '97ebb17a2518e3a43b18a382dcfc879c1f5e2b08118a6149c8fa984e65017453'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}
function Get-LowerHash {
    param([string]$LiteralPath)
    return (Get-FileHash -LiteralPath $LiteralPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Resolve-RelativePath {
    param([string]$Base, [string]$RelativePath)
    $p = $Base
    foreach ($part in ($RelativePath -split '/')) { $p = Join-Path $p $part }
    return $p
}
function Write-CsvUtf8Bom {
    param([object[]]$Rows, [string]$LiteralPath)
    $lines = @($Rows | ConvertTo-Csv -NoTypeInformation)
    $text = ($lines -join [Environment]::NewLine) + [Environment]::NewLine
    [System.IO.File]::WriteAllText($LiteralPath, $text, [System.Text.UTF8Encoding]::new($true))
}
function Write-JsonUtf8Bom {
    param($Value, [string]$LiteralPath)
    $text = ($Value | ConvertTo-Json -Depth 12) + [Environment]::NewLine
    [System.IO.File]::WriteAllText($LiteralPath, $text, [System.Text.UTF8Encoding]::new($true))
}
function Get-Baseline {
    param([string]$BaseRoot, [hashtable]$HashOverrides)
    $schema = @(Import-Csv -LiteralPath (Join-Path $BaseRoot '数据\schema-columns.csv'))
    $tablePaths = @($schema | Select-Object -ExpandProperty table_path -Unique | Sort-Object)
    $rows = foreach ($tablePath in $tablePaths) {
        $path = Resolve-RelativePath -Base $BaseRoot -RelativePath $tablePath
        $hash = if ($HashOverrides -and $HashOverrides.ContainsKey($tablePath)) {
            [string]$HashOverrides[$tablePath]
        } else {
            Get-LowerHash -LiteralPath $path
        }
        [pscustomobject][ordered]@{
            table_path = $tablePath
            sha256 = $hash
            bytes = if (Test-Path -LiteralPath $path -PathType Leaf) { (Get-Item -LiteralPath $path).Length } else { '' }
        }
    }
    $payload = (@($rows | ForEach-Object { "$($_.table_path)|$($_.sha256)" }) -join [char]10)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $aggregate = ([System.BitConverter]::ToString($sha.ComputeHash([System.Text.UTF8Encoding]::new($false).GetBytes($payload)))).Replace('-', '').ToLowerInvariant()
    } finally {
        $sha.Dispose()
    }
    return [pscustomobject]@{ Aggregate = $aggregate; Rows = @($rows); Payload = $payload }
}
function Get-PrimaryKey {
    param([string]$TablePath)
    switch ($TablePath) {
        '最小参考资料库/source-families.csv' { return 'source_family_id' }
        '最小参考资料库/sources.csv' { return 'source_id' }
        '最小参考资料库/source-endpoints.csv' { return 'endpoint_id' }
        default { throw "Unsupported Google delta table: $TablePath" }
    }
}

Assert-True (Test-Path -LiteralPath $outDir -PathType Container) "Missing output directory: $outDir"
Assert-True (-not (Test-Path -LiteralPath (Join-Path $outDir 'isolated-replay-results.json') -PathType Leaf)) 'Refusing to regenerate a finalized rebase package; remove isolated replay results explicitly before rebuilding.'
$originalSignoffHash = Get-LowerHash -LiteralPath $oldSignoffPath
Assert-True ($originalSignoffHash -eq $expectedOriginalSignoffHash) "Original signoff SHA-256 mismatch: $originalSignoffHash"
$oldRows = @(Import-Csv -LiteralPath $oldSignoffPath)
Assert-True ($oldRows.Count -eq 486) "Original signoff row count is $($oldRows.Count), expected 486"
Assert-True (@($oldRows | Select-Object -ExpandProperty signoff_row_id -Unique).Count -eq 486) 'Original signoff row IDs are not unique'
Assert-True (@($oldRows | Select-Object -ExpandProperty formal_baseline_aggregate_sha256 -Unique).Count -eq 1) 'Original signoff has multiple baseline aggregates'
Assert-True ($oldRows[0].formal_baseline_aggregate_sha256 -eq $expectedOldAggregate) 'Original signoff old aggregate mismatch'

$currentBaseline = Get-Baseline -BaseRoot $root -HashOverrides @{}
Assert-True ($currentBaseline.Rows.Count -eq 32) "Current formal table count is $($currentBaseline.Rows.Count), expected 32"
Assert-True ($currentBaseline.Aggregate -eq $expectedCurrentAggregate) "Current aggregate mismatch: $($currentBaseline.Aggregate)"

$backupManifest = @(Import-Csv -LiteralPath $googleBackupManifestPath)
$oldHashOverrides = @{}
foreach ($rel in @('最小参考资料库/source-families.csv','最小参考资料库/sources.csv','最小参考资料库/source-endpoints.csv')) {
    $m = @($backupManifest | Where-Object relative_path -eq $rel)
    Assert-True ($m.Count -eq 1) "Google backup manifest row missing or duplicate: $rel"
    $backupPath = Resolve-RelativePath -Base $googleBackupDir -RelativePath $rel
    Assert-True ((Get-LowerHash -LiteralPath $backupPath) -eq $m[0].sha256) "Google backup file hash mismatch: $rel"
    $oldHashOverrides[$rel] = [string]$m[0].sha256
}
$reconstructedOld = Get-Baseline -BaseRoot $root -HashOverrides $oldHashOverrides
Assert-True ($reconstructedOld.Aggregate -eq $expectedOldAggregate) "Reconstructed old aggregate mismatch: $($reconstructedOld.Aggregate)"

$googleExpected = @(
    [pscustomobject]@{table_path='最小参考资料库/source-families.csv';pk_column='source_family_id';pk_value='SFAM-M2-W2-G-TPU-MACHINES'},
    [pscustomobject]@{table_path='最小参考资料库/sources.csv';pk_column='source_id';pk_value='SRC-M2-W2-G-TPU-MACHINES-20260813'},
    [pscustomobject]@{table_path='最小参考资料库/source-endpoints.csv';pk_column='endpoint_id';pk_value='END-M2-W2-G-TPU-MACHINES-PRIMARY'},
    [pscustomobject]@{table_path='最小参考资料库/source-endpoints.csv';pk_column='endpoint_id';pk_value='END-M2-W2-G-TPU-MACHINES-EXTRACT-20260813'},
    [pscustomobject]@{table_path='最小参考资料库/source-endpoints.csv';pk_column='endpoint_id';pk_value='END-M2-GA-G05-EXTRACT-20260813'},
    [pscustomobject]@{table_path='最小参考资料库/source-endpoints.csv';pk_column='endpoint_id';pk_value='END-M2-GA-G08-EXTRACT-20260813'},
    [pscustomobject]@{table_path='最小参考资料库/source-endpoints.csv';pk_column='endpoint_id';pk_value='END-M2-GA-G09-EXTRACT-20260813'},
    [pscustomobject]@{table_path='最小参考资料库/source-endpoints.csv';pk_column='endpoint_id';pk_value='END-M2-GA-G10-EXTRACT-20260813'}
)
$googleDeltaRows = [System.Collections.Generic.List[object]]::new()
foreach ($tablePath in @('最小参考资料库/source-families.csv','最小参考资料库/sources.csv','最小参考资料库/source-endpoints.csv')) {
    $pk = Get-PrimaryKey -TablePath $tablePath
    $oldData = @(Import-Csv -LiteralPath (Resolve-RelativePath -Base $googleBackupDir -RelativePath $tablePath))
    $newData = @(Import-Csv -LiteralPath (Resolve-RelativePath -Base $root -RelativePath $tablePath))
    $oldMap = @{}
    foreach ($row in $oldData) { $oldMap[[string]$row.$pk] = $row }
    $newMap = @{}
    foreach ($row in $newData) { $newMap[[string]$row.$pk] = $row }
    foreach ($key in @($oldMap.Keys | Sort-Object)) {
        Assert-True ($newMap.ContainsKey($key)) "Google merge removed PK $tablePath::$key"
        $oldJson = $oldMap[$key] | ConvertTo-Json -Compress -Depth 5
        $newJson = $newMap[$key] | ConvertTo-Json -Compress -Depth 5
        Assert-True ($oldJson -ceq $newJson) "Google merge changed existing row $tablePath::$key"
    }
    foreach ($key in @($newMap.Keys | Sort-Object)) {
        if (-not $oldMap.ContainsKey($key)) {
            $googleDeltaRows.Add([pscustomobject][ordered]@{
                table_path = $tablePath
                pk_column = $pk
                pk_value = $key
                delta_type = 'added'
                old_presence = 'absent'
                new_presence = 'present'
            })
        }
    }
}
Assert-True ($googleDeltaRows.Count -eq 8) "Google formal PK delta count is $($googleDeltaRows.Count), expected 8"
$expectedKeys = @($googleExpected | ForEach-Object { "$($_.table_path)|$($_.pk_column)|$($_.pk_value)" } | Sort-Object)
$actualKeys = @($googleDeltaRows | ForEach-Object { "$($_.table_path)|$($_.pk_column)|$($_.pk_value)" } | Sort-Object)
Assert-True (($expectedKeys -join [char]10) -ceq ($actualKeys -join [char]10)) 'Google formal PK set differs from the authorized eight rows'
Write-CsvUtf8Bom -Rows @($googleDeltaRows) -LiteralPath (Join-Path $outDir 'google-formal-pk-delta.csv')

$googleFiles = @(
    [pscustomobject]@{path='最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-machines-2026-08-13.html';bytes=27322;sha256='b87a1b00c38354659efc4fb0073b4dd205ce807e37cfc01252be6bf5820c96b8'},
    [pscustomobject]@{path='最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-architecture-2026-08-13.html';bytes=20515;sha256='ddf8f0a880db456b5edc190a6ec2feb63b06c016e86d8583072cd70eaed93841'},
    [pscustomobject]@{path='最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v5e-2026-08-13.html';bytes=13076;sha256='7bb0a40383503f76c43e728d8868c7f17f1e715a6d0e200f90428471ce646b47'},
    [pscustomobject]@{path='最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v5p-2026-08-13.html';bytes=15574;sha256='c4207909253ef1c0d96298396c080fd2349bdb92a8048c717d582d9bcc2e6c5c'},
    [pscustomobject]@{path='最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v6e-2026-08-13.html';bytes=11999;sha256='65c35ff3c661e7e4cb0c08d382aacc713592d49107d0d1c1c29a27bd58332dc2'}
)
$googleFileAudit = foreach ($f in $googleFiles) {
    $p = Resolve-RelativePath -Base $root -RelativePath $f.path
    Assert-True (Test-Path -LiteralPath $p -PathType Leaf) "Google fixed file missing: $($f.path)"
    $actualBytes = (Get-Item -LiteralPath $p).Length
    $actualHash = Get-LowerHash -LiteralPath $p
    Assert-True ($actualBytes -eq $f.bytes) "Google fixed file bytes mismatch: $($f.path)"
    Assert-True ($actualHash -eq $f.sha256) "Google fixed file hash mismatch: $($f.path)"
    [pscustomobject][ordered]@{ path=$f.path; expected_bytes=$f.bytes; actual_bytes=$actualBytes; expected_sha256=$f.sha256; actual_sha256=$actualHash; check_status='passed' }
}
Write-CsvUtf8Bom -Rows @($googleFileAudit) -LiteralPath (Join-Path $outDir 'google-fixed-file-audit.csv')

$writeRows = @($oldRows | Where-Object authorization_scope -ne 'no_write_guard')
$guardRows = @($oldRows | Where-Object authorization_scope -eq 'no_write_guard')
Assert-True ($writeRows.Count -eq 478) "AWS write authorization count is $($writeRows.Count), expected 478"
Assert-True ($guardRows.Count -eq 8) "AWS no-write guard count is $($guardRows.Count), expected 8"
$awsKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($row in $writeRows | Where-Object { -not [string]::IsNullOrWhiteSpace($_.pk_column) }) {
    [void]$awsKeys.Add("$($row.target_path)|$($row.pk_column)|$($row.pk_value)")
}
$googleKeyConflicts = @($actualKeys | Where-Object { $awsKeys.Contains($_) })
Assert-True ($googleKeyConflicts.Count -eq 0) "AWS/Google PK conflict count is $($googleKeyConflicts.Count), expected 0"
$awsTargetPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($row in $writeRows) { [void]$awsTargetPaths.Add([string]$row.target_path) }
$googleFixedPathConflicts = @($googleFiles | Where-Object { $awsTargetPaths.Contains($_.path) })
Assert-True ($googleFixedPathConflicts.Count -eq 0) "AWS/Google fixed-file conflict count is $($googleFixedPathConflicts.Count), expected 0"

$currentHashByTable = @{}
foreach ($row in $currentBaseline.Rows) { $currentHashByTable[$row.table_path] = $row.sha256 }
$newRows = [System.Collections.Generic.List[object]]::new()
$rebaseNote = "rebase_binding=$bindingId"
foreach ($old in $oldRows) {
    $props = [ordered]@{}
    foreach ($p in $old.PSObject.Properties) { $props[$p.Name] = [string]$p.Value }
    if (-not [string]::IsNullOrWhiteSpace($old.formal_target_premerge_sha256)) {
        Assert-True ($currentHashByTable.ContainsKey($old.target_path)) "Bound target is not a formal table: $($old.signoff_row_id) $($old.target_path)"
        $props['formal_target_premerge_sha256'] = [string]$currentHashByTable[$old.target_path]
    }
    $props['formal_baseline_aggregate_sha256'] = $currentBaseline.Aggregate
    $props['notes'] = ([string]$old.notes).TrimEnd() + $rebaseNote
    $newRows.Add([pscustomobject]$props)
}
$newSignoffPath = Join-Path $outDir 'aws-signoff-rebase.csv'
Write-CsvUtf8Bom -Rows @($newRows) -LiteralPath $newSignoffPath
$newSignoffHash = Get-LowerHash -LiteralPath $newSignoffPath

$diffs = [System.Collections.Generic.List[object]]::new()
$headers = @($oldRows[0].PSObject.Properties.Name)
for ($i=0; $i -lt $oldRows.Count; $i++) {
    foreach ($column in $headers) {
        $oldValue = [string]$oldRows[$i].$column
        $newValue = [string]$newRows[$i].$column
        if ($oldValue -cne $newValue) {
            $diffs.Add([pscustomobject][ordered]@{
                signoff_row_id = $oldRows[$i].signoff_row_id
                column_name = $column
                old_value = $oldValue
                new_value = $newValue
                allowed_change = if ($column -in @('formal_target_premerge_sha256','formal_baseline_aggregate_sha256','notes')) { 'true' } else { 'false' }
            })
        }
    }
}
$forbiddenDiffs = @($diffs | Where-Object allowed_change -ne 'true')
Assert-True ($forbiddenDiffs.Count -eq 0) "Signoff has $($forbiddenDiffs.Count) changes outside allowed columns"
$targetHashDiffs = @($diffs | Where-Object column_name -eq 'formal_target_premerge_sha256')
$aggregateDiffs = @($diffs | Where-Object column_name -eq 'formal_baseline_aggregate_sha256')
$noteDiffs = @($diffs | Where-Object column_name -eq 'notes')
Assert-True ($targetHashDiffs.Count -eq 29) "Target premerge hash diff count is $($targetHashDiffs.Count), expected 29"
Assert-True ($aggregateDiffs.Count -eq 486) "Aggregate diff count is $($aggregateDiffs.Count), expected 486"
Assert-True ($noteDiffs.Count -eq 486) "Notes diff count is $($noteDiffs.Count), expected 486"
$expectedTargetDiffIds = @($oldRows | Where-Object target_path -in @('最小参考资料库/sources.csv','最小参考资料库/source-endpoints.csv') | Select-Object -ExpandProperty signoff_row_id)
Assert-True (@($targetHashDiffs | Where-Object { $_.signoff_row_id -notin $expectedTargetDiffIds }).Count -eq 0) 'Unexpected target hash rebinding row'
Write-CsvUtf8Bom -Rows @($diffs) -LiteralPath (Join-Path $outDir 'old-to-new-cell-diff.csv')
Write-CsvUtf8Bom -Rows @($currentBaseline.Rows) -LiteralPath (Join-Path $outDir 'formal-baseline-hashes.csv')

$pathAudit = foreach ($path in @($oldRows | Select-Object -ExpandProperty target_path -Unique | Sort-Object)) {
    $awsCount = @($writeRows | Where-Object target_path -eq $path).Count
    $googleContainerChanged = $path -in @('最小参考资料库/source-families.csv','最小参考资料库/sources.csv','最小参考资料库/source-endpoints.csv')
    $googleFixedFile = @($googleFiles | Where-Object path -eq $path).Count -gt 0
    [pscustomobject][ordered]@{
        path = $path
        aws_write_rows = $awsCount
        google_container_changed = $googleContainerChanged.ToString().ToLowerInvariant()
        google_fixed_file_added = $googleFixedFile.ToString().ToLowerInvariant()
        exact_path_overlap = ($googleContainerChanged -or $googleFixedFile).ToString().ToLowerInvariant()
        pk_or_file_conflict = 'false'
        rationale = if ($path -in @('最小参考资料库/sources.csv','最小参考资料库/source-endpoints.csv')) { '共享 CSV 容器，但 Google 8 个新增主键均不在 AWS 478 行写集中。' } else { '无 Google 授权写入，或仅为不同固定文件路径。' }
    }
}
Write-CsvUtf8Bom -Rows @($pathAudit) -LiteralPath (Join-Path $outDir 'aws-google-conflict-audit.csv')

$binding = [ordered]@{
    binding_id = $bindingId
    verdict = 'pending_isolated_replay'
    generated_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
    original_aws_signoff = [ordered]@{ path='审计/子代理交接/m2_final_review_aws_package_merge_signoff.csv'; sha256=$originalSignoffHash; rows=486; writes=478; no_write_guards=8 }
    original_aws_report = [ordered]@{ path='审计/子代理交接/m2_final_review_aws_package.md'; sha256=(Get-LowerHash -LiteralPath $oldAwsReportPath) }
    google_review = [ordered]@{ path='审计/子代理交接/m2_final_review_google_cloud_device.md'; sha256=(Get-LowerHash -LiteralPath $googleReviewPath) }
    google_formal_acceptance = [ordered]@{ path='审计/M2_第二波_Google云端器件来源门正式验收.md'; sha256=(Get-LowerHash -LiteralPath $googleAcceptancePath) }
    google_backup_manifest = [ordered]@{ path='审计/合并备份/M2-W2-GOOGLE-CLOUD-DEVICE-SOURCES-20260813/backup-hashes.csv'; sha256=(Get-LowerHash -LiteralPath $googleBackupManifestPath) }
    baseline = [ordered]@{ old_aggregate=$expectedOldAggregate; reconstructed_old_aggregate=$reconstructedOld.Aggregate; current_aggregate=$currentBaseline.Aggregate; formal_table_count=32 }
    authorized_google_delta = [ordered]@{ family_rows=1; source_rows=1; endpoint_rows=6; formal_pk_total=8; fixed_files=5; existing_rows_changed=0; rows_removed=0 }
    conflict_audit = [ordered]@{ aws_write_rows=478; google_formal_pks=8; pk_intersection=0; google_fixed_files=5; exact_fixed_file_intersection=0; shared_csv_containers=@('最小参考资料库/sources.csv','最小参考资料库/source-endpoints.csv') }
    rebase_signoff = [ordered]@{ path='审计/子代理交接/aws_signoff_rebase/aws-signoff-rebase.csv'; sha256=$newSignoffHash; rows=486; allowed_changed_columns=@('formal_target_premerge_sha256','formal_baseline_aggregate_sha256','notes'); target_hash_cells_changed=29; aggregate_cells_changed=486; note_cells_changed=486; forbidden_cells_changed=0; original_binding_id_preserved=$true }
}
Write-JsonUtf8Bom -Value $binding -LiteralPath (Join-Path $outDir 'rebase-binding.json')

$summary = [ordered]@{
    stage = 'signoff_generated'
    current_formal_aggregate = $currentBaseline.Aggregate
    reconstructed_old_aggregate = $reconstructedOld.Aggregate
    original_signoff_sha256 = $originalSignoffHash
    rebase_signoff_sha256 = $newSignoffHash
    signoff_rows = 486
    aws_write_rows = 478
    aws_guard_rows = 8
    google_pk_delta = 8
    google_fixed_files = 5
    aws_google_pk_conflicts = 0
    aws_google_fixed_file_conflicts = 0
    target_hash_cell_diffs = $targetHashDiffs.Count
    aggregate_cell_diffs = $aggregateDiffs.Count
    note_cell_diffs = $noteDiffs.Count
    forbidden_cell_diffs = $forbiddenDiffs.Count
}
Write-JsonUtf8Bom -Value $summary -LiteralPath (Join-Path $outDir 'build-summary.json')
$summary | ConvertTo-Json -Depth 6
