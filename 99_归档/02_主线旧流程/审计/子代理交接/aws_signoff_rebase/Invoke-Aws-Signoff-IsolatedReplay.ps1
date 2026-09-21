#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = '.'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $RootPath).Path
$outDir = Join-Path $root '审计\子代理交接\aws_signoff_rebase'
$signoffPath = Join-Path $outDir 'aws-signoff-rebase.csv'
$validatorPath = Join-Path $root 'scripts\validation\Validate-ResearchData.ps1'
$expectedSignoffHash = '9429d80f0ba649724ed1276523df8ecfcf269e6e748b15a6cbe4dd11013b42c0'
$expectedBaselineAggregate = '97ebb17a2518e3a43b18a382dcfc879c1f5e2b08118a6149c8fa984e65017453'
$tempRoot = Join-Path $outDir ('isolated-replay-' + [guid]::NewGuid().ToString('N'))
$validatorOutputPath = Join-Path $outDir 'isolated-validator-output.txt'
$resultsPath = Join-Path $outDir 'isolated-replay-results.json'

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
    param([object[]]$Rows, [string[]]$Headers, [string]$LiteralPath)
    $ordered = foreach ($row in $Rows) { $row | Select-Object -Property $Headers }
    $lines = @($ordered | ConvertTo-Csv -NoTypeInformation)
    [System.IO.File]::WriteAllText($LiteralPath, (($lines -join [Environment]::NewLine) + [Environment]::NewLine), [System.Text.UTF8Encoding]::new($true))
}
function Write-JsonUtf8Bom {
    param($Value, [string]$LiteralPath)
    [System.IO.File]::WriteAllText($LiteralPath, (($Value | ConvertTo-Json -Depth 12) + [Environment]::NewLine), [System.Text.UTF8Encoding]::new($true))
}
function Get-Baseline {
    param([string]$BaseRoot)
    $schema = @(Import-Csv -LiteralPath (Join-Path $BaseRoot '数据\schema-columns.csv'))
    $tablePaths = @($schema | Select-Object -ExpandProperty table_path -Unique | Sort-Object)
    $rows = foreach ($tablePath in $tablePaths) {
        $path = Resolve-RelativePath -Base $BaseRoot -RelativePath $tablePath
        [pscustomobject]@{table_path=$tablePath;sha256=(Get-LowerHash -LiteralPath $path)}
    }
    $payload = @($rows | ForEach-Object { "$($_.table_path)|$($_.sha256)" }) -join [char]10
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $aggregate = ([System.BitConverter]::ToString($sha.ComputeHash([System.Text.UTF8Encoding]::new($false).GetBytes($payload)))).Replace('-', '').ToLowerInvariant()
    } finally { $sha.Dispose() }
    return [pscustomobject]@{Aggregate=$aggregate;Rows=@($rows)}
}
function Get-FormalState {
    param([string]$BaseRoot)
    $baseline = Get-Baseline -BaseRoot $BaseRoot
    $map = @{}
    foreach ($r in $baseline.Rows) { $map[$r.table_path] = $r.sha256 }
    return [pscustomobject]@{Aggregate=$baseline.Aggregate;HashMap=$map;Rows=$baseline.Rows}
}
function Get-RowProjection {
    param($Row, [string[]]$Headers)
    $parts = foreach ($h in $Headers) { [string]$Row.$h }
    return $parts -join [char]31
}
function Parse-SemanticFields {
    param([string]$Text)
    $result = [ordered]@{}
    $matches = [regex]::Matches($Text, '(?:^|;)([A-Za-z_][A-Za-z0-9_]*)=')
    for ($i=0; $i -lt $matches.Count; $i++) {
        $name = $matches[$i].Groups[1].Value
        $start = $matches[$i].Index + $matches[$i].Length
        $end = if ($i + 1 -lt $matches.Count) { $matches[$i + 1].Index } else { $Text.Length }
        $result[$name] = $Text.Substring($start, $end - $start)
    }
    return $result
}

$signoffHash = Get-LowerHash -LiteralPath $signoffPath
Assert-True ($signoffHash -eq $expectedSignoffHash) "Rebase signoff hash mismatch: $signoffHash"
Assert-True (-not (Test-Path -LiteralPath $resultsPath -PathType Leaf)) 'Refusing to overwrite an existing isolated replay result; use a fresh audit output directory.'
$signoff = @(Import-Csv -LiteralPath $signoffPath)
Assert-True ($signoff.Count -eq 486) "Signoff row count $($signoff.Count), expected 486"
Assert-True (@($signoff | Select-Object -ExpandProperty signoff_row_id -Unique).Count -eq 486) 'Duplicate signoff row ID'
Assert-True (@($signoff | Where-Object authorization_scope -ne 'no_write_guard').Count -eq 478) 'AWS write count mismatch'
Assert-True (@($signoff | Where-Object authorization_scope -eq 'no_write_guard').Count -eq 8) 'AWS no-write guard count mismatch'
Assert-True (@($signoff | Where-Object formal_baseline_aggregate_sha256 -ne $expectedBaselineAggregate).Count -eq 0) 'Not all signoff rows bind current aggregate'

$formalBefore = Get-FormalState -BaseRoot $root
Assert-True ($formalBefore.Aggregate -eq $expectedBaselineAggregate) "Formal aggregate before replay mismatch: $($formalBefore.Aggregate)"

$immutablePaths = @(
    '审计/子代理交接/m2_final_review_aws_package_merge_signoff.csv',
    '审计/子代理交接/m2_final_review_aws_package.md',
    '审计/子代理交接/m2_final_review_google_cloud_device.md',
    '审计/M2_第二波_Google云端器件来源门正式验收.md'
)
$immutablePaths += @($signoff | Select-Object -ExpandProperty source_path -Unique | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
$immutableBefore = @{}
foreach ($rel in ($immutablePaths | Sort-Object -Unique)) {
    $p = Resolve-RelativePath -Base $root -RelativePath $rel
    Assert-True (Test-Path -LiteralPath $p -PathType Leaf) "Immutable input missing: $rel"
    $immutableBefore[$rel] = Get-LowerHash -LiteralPath $p
}

try {
    [void](New-Item -ItemType Directory -Path $tempRoot)
    Copy-Item -LiteralPath (Join-Path $root '数据') -Destination (Join-Path $tempRoot '数据') -Recurse
    Copy-Item -LiteralPath (Join-Path $root '最小参考资料库') -Destination (Join-Path $tempRoot '最小参考资料库') -Recurse
    [void](New-Item -ItemType Directory -Path (Join-Path $tempRoot 'scripts\validation') -Force)
    Copy-Item -LiteralPath $validatorPath -Destination (Join-Path $tempRoot 'scripts\validation\Validate-ResearchData.ps1')

    $formalEndpointRows = @(Import-Csv -LiteralPath (Join-Path $root '最小参考资料库\source-endpoints.csv'))
    $pdfLocalPaths = @($formalEndpointRows | Where-Object { $_.local_path -like '论文/*' } | Select-Object -ExpandProperty local_path -Unique)
    foreach ($rel in $pdfLocalPaths) {
        $src = Resolve-RelativePath -Base $root -RelativePath $rel
        $dst = Resolve-RelativePath -Base $tempRoot -RelativePath $rel
        $dstDir = Split-Path -Parent $dst
        if (-not (Test-Path -LiteralPath $dstDir -PathType Container)) { [void](New-Item -ItemType Directory -Path $dstDir -Force) }
        Copy-Item -LiteralPath $src -Destination $dst
    }

    $initialTargetHashes = @{}
    foreach ($row in $signoff | Where-Object { -not [string]::IsNullOrWhiteSpace($_.formal_target_premerge_sha256) }) {
        $target = Resolve-RelativePath -Base $tempRoot -RelativePath $row.target_path
        Assert-True (Test-Path -LiteralPath $target -PathType Leaf) "Bound target missing in replay: $($row.target_path)"
        if (-not $initialTargetHashes.ContainsKey($row.target_path)) {
            $initialTargetHashes[$row.target_path] = Get-LowerHash -LiteralPath $target
        }
        Assert-True ($initialTargetHashes[$row.target_path] -eq $row.formal_target_premerge_sha256) "Premerge target hash mismatch: $($row.signoff_row_id)"
    }
    foreach ($row in $signoff | Where-Object { [string]::IsNullOrWhiteSpace($_.formal_target_premerge_sha256) }) {
        Assert-True ($row.formal_premerge_presence -eq 'absent') "Blank target hash without absent status: $($row.signoff_row_id)"
        $target = Resolve-RelativePath -Base $tempRoot -RelativePath $row.target_path
        Assert-True (-not (Test-Path -LiteralPath $target -PathType Leaf)) "Absent-bound target already exists: $($row.signoff_row_id)"
    }
    foreach ($row in $signoff | Where-Object { -not [string]::IsNullOrWhiteSpace($_.source_path) }) {
        $source = Resolve-RelativePath -Base $root -RelativePath $row.source_path
        Assert-True ((Get-LowerHash -LiteralPath $source) -eq $row.source_sha256) "Source hash mismatch: $($row.signoff_row_id)"
    }

    $guardBefore = @{}
    foreach ($row in $signoff | Where-Object authorization_scope -eq 'no_write_guard') {
        $target = Resolve-RelativePath -Base $tempRoot -RelativePath $row.target_path
        $data = @(Import-Csv -LiteralPath $target)
        $matches = @($data | Where-Object { [string]$_.($row.pk_column) -ceq [string]$row.pk_value })
        Assert-True ($matches.Count -eq 1) "No-write guard PK missing/duplicate: $($row.signoff_row_id)"
        $headers = @($matches[0].PSObject.Properties.Name)
        $guardBefore[$row.signoff_row_id] = Get-RowProjection -Row $matches[0] -Headers $headers
    }

    $lifecycleRows = @($signoff | Where-Object authorization_scope -eq 'lifecycle_pk_write')
    foreach ($targetGroup in ($lifecycleRows | Group-Object target_path)) {
        $targetPath = [string]$targetGroup.Name
        $target = Resolve-RelativePath -Base $tempRoot -RelativePath $targetPath
        $rows = [System.Collections.Generic.List[object]]::new()
        foreach ($r in @(Import-Csv -LiteralPath $target)) { $rows.Add($r) }
        $headers = @((Import-Csv -LiteralPath $target | Select-Object -First 1).PSObject.Properties.Name)
        if ($headers.Count -eq 0) {
            $headers = @((Get-Content -LiteralPath $target -Encoding UTF8 -TotalCount 1) -split ',' | ForEach-Object { $_.Trim('"') })
        }
        foreach ($auth in ($targetGroup.Group | Sort-Object signoff_row_id)) {
            $sourcePath = Resolve-RelativePath -Base $root -RelativePath $auth.source_path
            $sourceRows = @(Import-Csv -LiteralPath $sourcePath)
            $sourceMatches = @($sourceRows | Where-Object { [string]$_.($auth.pk_column) -ceq [string]$auth.pk_value })
            Assert-True ($sourceMatches.Count -eq 1) "Source PK missing/duplicate: $($auth.signoff_row_id)"
            $candidate = $sourceMatches[0] | Select-Object -Property $headers
            Assert-True ([string]$candidate.review_status -ceq [string]$auth.candidate_pre_review_status) "Candidate review status mismatch: $($auth.signoff_row_id)"
            $existing = @($rows | Where-Object { [string]$_.($auth.pk_column) -ceq [string]$auth.pk_value })
            if ($auth.formal_premerge_presence -eq 'absent') {
                Assert-True ($existing.Count -eq 0) "Append target already has PK: $($auth.signoff_row_id)"
            } else {
                Assert-True ($existing.Count -eq 1) "Update target PK missing/duplicate: $($auth.signoff_row_id)"
                Assert-True ([string]$existing[0].review_status -ceq [string]$auth.formal_existing_review_status) "Formal existing review status mismatch: $($auth.signoff_row_id)"
                [void]$rows.Remove($existing[0])
            }
            $candidate.review_status = [string]$auth.authorized_review_status
            $rows.Add($candidate)
        }
        Write-CsvUtf8Bom -Rows @($rows) -Headers $headers -LiteralPath $target
    }

    $cellAuth = @($signoff | Where-Object authorization_scope -eq 'exact_cell_write')
    Assert-True ($cellAuth.Count -eq 1) 'Expected exactly one exact-cell authorization'
    $cell = $cellAuth[0]
    $cellTarget = Resolve-RelativePath -Base $tempRoot -RelativePath $cell.target_path
    $cellRows = [System.Collections.Generic.List[object]]::new()
    foreach ($r in @(Import-Csv -LiteralPath $cellTarget)) { $cellRows.Add($r) }
    $cellHeaders = @($cellRows[0].PSObject.Properties.Name)
    $cellMatches = @($cellRows | Where-Object { [string]$_.($cell.pk_column) -ceq [string]$cell.pk_value })
    Assert-True ($cellMatches.Count -eq 1) 'FIELD-PHY-CLOCK target row missing/duplicate'
    $beforeProjection = Get-RowProjection -Row $cellMatches[0] -Headers @($cellHeaders | Where-Object { $_ -ne 'allowed_subject_kinds' })
    Assert-True ([string]$cellMatches[0].allowed_subject_kinds -ceq 'object') 'FIELD-PHY-CLOCK prevalue is not object'
    $cellMatches[0].allowed_subject_kinds = 'object;component'
    $afterProjection = Get-RowProjection -Row $cellMatches[0] -Headers @($cellHeaders | Where-Object { $_ -ne 'allowed_subject_kinds' })
    Assert-True ($beforeProjection -ceq $afterProjection) 'FIELD-PHY-CLOCK changed outside allowed_subject_kinds'
    Write-CsvUtf8Bom -Rows @($cellRows) -Headers $cellHeaders -LiteralPath $cellTarget

    foreach ($auth in $signoff | Where-Object authorization_scope -eq 'semantic_signoff') {
        $target = Resolve-RelativePath -Base $tempRoot -RelativePath $auth.target_path
        $rows = [System.Collections.Generic.List[object]]::new()
        foreach ($r in @(Import-Csv -LiteralPath $target)) { $rows.Add($r) }
        $headers = @($rows[0].PSObject.Properties.Name)
        $matches = @($rows | Where-Object { [string]$_.($auth.pk_column) -ceq [string]$auth.pk_value })
        Assert-True ($matches.Count -eq 1) "Semantic signoff target missing/duplicate: $($auth.signoff_row_id)"
        $fields = Parse-SemanticFields -Text ([string]$auth.semantic_status_after)
        Assert-True ($fields.Count -eq 3) "Semantic signoff field count is not three: $($auth.signoff_row_id)"
        $nonSemanticHeaders = @($headers | Where-Object { $_ -notin @($fields.Keys) })
        $before = Get-RowProjection -Row $matches[0] -Headers $nonSemanticHeaders
        foreach ($name in $fields.Keys) {
            Assert-True ($headers -contains $name) "Semantic signoff target lacks field ${name}: $($auth.signoff_row_id)"
            $matches[0].$name = [string]$fields[$name]
        }
        $after = Get-RowProjection -Row $matches[0] -Headers $nonSemanticHeaders
        Assert-True ($before -ceq $after) "Semantic signoff changed unauthorized field: $($auth.signoff_row_id)"
        Write-CsvUtf8Bom -Rows @($rows) -Headers $headers -LiteralPath $target
    }

    $copyRows = @($signoff | Where-Object authorization_scope -in @('exact_file_copy','exact_finalized_card_write'))
    Assert-True ($copyRows.Count -eq 15) 'Expected 15 exact file/card copies'
    foreach ($auth in $copyRows) {
        $source = Resolve-RelativePath -Base $root -RelativePath $auth.source_path
        $target = Resolve-RelativePath -Base $tempRoot -RelativePath $auth.target_path
        Assert-True (-not (Test-Path -LiteralPath $target -PathType Leaf)) "Copy target already exists: $($auth.signoff_row_id)"
        $dir = Split-Path -Parent $target
        if (-not (Test-Path -LiteralPath $dir -PathType Container)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
        Copy-Item -LiteralPath $source -Destination $target
        Assert-True ((Get-LowerHash -LiteralPath $target) -eq $auth.expected_output_sha256) "Copied output hash mismatch: $($auth.signoff_row_id)"
        Assert-True ((Get-Item -LiteralPath $target).Length -eq [int64]$auth.expected_output_bytes) "Copied output bytes mismatch: $($auth.signoff_row_id)"
    }

    foreach ($row in $signoff | Where-Object authorization_scope -eq 'no_write_guard') {
        $target = Resolve-RelativePath -Base $tempRoot -RelativePath $row.target_path
        $matches = @(Import-Csv -LiteralPath $target | Where-Object { [string]$_.($row.pk_column) -ceq [string]$row.pk_value })
        Assert-True ($matches.Count -eq 1) "No-write guard post-replay PK missing/duplicate: $($row.signoff_row_id)"
        $headers = @($matches[0].PSObject.Properties.Name)
        Assert-True ((Get-RowProjection -Row $matches[0] -Headers $headers) -ceq $guardBefore[$row.signoff_row_id]) "No-write guard changed: $($row.signoff_row_id)"
    }

    foreach ($auth in $lifecycleRows) {
        $target = Resolve-RelativePath -Base $tempRoot -RelativePath $auth.target_path
        $matches = @(Import-Csv -LiteralPath $target | Where-Object { [string]$_.($auth.pk_column) -ceq [string]$auth.pk_value })
        Assert-True ($matches.Count -eq 1) "Lifecycle output PK missing/duplicate: $($auth.signoff_row_id)"
        Assert-True ([string]$matches[0].review_status -ceq [string]$auth.authorized_review_status) "Lifecycle output review status mismatch: $($auth.signoff_row_id)"
    }
    foreach ($auth in $signoff | Where-Object authorization_scope -eq 'semantic_signoff') {
        $target = Resolve-RelativePath -Base $tempRoot -RelativePath $auth.target_path
        $matches = @(Import-Csv -LiteralPath $target | Where-Object { [string]$_.($auth.pk_column) -ceq [string]$auth.pk_value })
        $fields = Parse-SemanticFields -Text ([string]$auth.semantic_status_after)
        foreach ($name in $fields.Keys) {
            Assert-True ([string]$matches[0].$name -ceq [string]$fields[$name]) "Semantic output mismatch: $($auth.signoff_row_id) $name"
        }
    }

    $validatorInvocation = @(
        '-NoProfile',
        '-ExecutionPolicy','Bypass',
        '-File',(Join-Path $tempRoot 'scripts\validation\Validate-ResearchData.ps1'),
        '-RootPath',$tempRoot
    )
    $validatorLines = @(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' @validatorInvocation 2>&1 | ForEach-Object { [string]$_ })
    $validatorExitCode = $LASTEXITCODE
    [System.IO.File]::WriteAllText($validatorOutputPath, (($validatorLines -join [Environment]::NewLine) + [Environment]::NewLine), [System.Text.UTF8Encoding]::new($true))
    Assert-True ($validatorExitCode -eq 0) "Isolated validator failed with exit code $validatorExitCode"
    $validatorText = $validatorLines -join [char]10
    $checkMatch = [regex]::Match($validatorText, '([0-9]+) checks executed')
    Assert-True ($checkMatch.Success) 'Could not parse isolated validator check count'
    $isolatedChecks = [int]$checkMatch.Groups[1].Value

    $mergedBaseline = Get-Baseline -BaseRoot $tempRoot
    $formalAfter = Get-FormalState -BaseRoot $root
    Assert-True ($formalAfter.Aggregate -eq $formalBefore.Aggregate) 'Formal aggregate changed during isolated replay'
    foreach ($tablePath in $formalBefore.HashMap.Keys) {
        Assert-True ($formalAfter.HashMap[$tablePath] -eq $formalBefore.HashMap[$tablePath]) "Formal table changed during isolated replay: $tablePath"
    }
    foreach ($rel in $immutableBefore.Keys) {
        $p = Resolve-RelativePath -Base $root -RelativePath $rel
        Assert-True ((Get-LowerHash -LiteralPath $p) -eq $immutableBefore[$rel]) "Immutable input changed: $rel"
    }

    $result = [ordered]@{
        verdict = 'accept'
        rebase_signoff_sha256 = $signoffHash
        formal_pre_replay_aggregate = $formalBefore.Aggregate
        formal_post_replay_aggregate = $formalAfter.Aggregate
        formal_table_hash_changes = 0
        immutable_input_hash_changes = 0
        signoff_rows_preflighted = 486
        lifecycle_rows_executed = 457
        exact_cell_writes_executed = 1
        semantic_signoffs_executed = 5
        exact_file_or_card_copies_executed = 15
        no_write_guards_verified = 8
        total_authorized_writes_executed = 478
        isolated_validator_exit_code = $validatorExitCode
        isolated_validator_checks = $isolatedChecks
        isolated_validator_output = '审计/子代理交接/aws_signoff_rebase/isolated-validator-output.txt'
        isolated_merged_aggregate = $mergedBaseline.Aggregate
        temp_root_cleaned = $false
    }
    Write-JsonUtf8Bom -Value $result -LiteralPath $resultsPath
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTemp = (Resolve-Path -LiteralPath $tempRoot).Path
        $resolvedOut = (Resolve-Path -LiteralPath $outDir).Path.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
        Assert-True ($resolvedTemp.StartsWith($resolvedOut, [System.StringComparison]::OrdinalIgnoreCase)) "Refusing to clean temp root outside output: $resolvedTemp"
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
    }
}
Assert-True (-not (Test-Path -LiteralPath $tempRoot)) 'Temporary replay root was not cleaned'
$result = Get-Content -LiteralPath $resultsPath -Raw -Encoding UTF8 | ConvertFrom-Json
$result.temp_root_cleaned = $true
Write-JsonUtf8Bom -Value $result -LiteralPath $resultsPath
$result | ConvertTo-Json -Depth 12
