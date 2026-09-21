param(
    [string]$ProjectRoot = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总',
    [string]$ReviewRoot = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总\审计\子代理交接\m2_mi350p_formal_transaction_independent_review'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Get-TextSha256 {
    param([string]$Text)
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = $Utf8.GetBytes($Text)
        return (($algorithm.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join '')
    }
    finally {
        $algorithm.Dispose()
    }
}

$prepRoot = Join-Path $ProjectRoot '审计\子代理交接\m2_mi350p_formal_transaction_prep'
$manifestPath = Join-Path $prepRoot 'manifest.csv'
$manifestRows = @(Import-Csv -LiteralPath $manifestPath -Encoding UTF8)
$manifestFailureCount = 0
foreach ($row in $manifestRows) {
    $full = Join-Path $prepRoot ($row.relative_path.Replace('/','\'))
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        $manifestFailureCount++
        continue
    }
    $actualHash = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLowerInvariant()
    $actualBytes = (Get-Item -LiteralPath $full).Length
    if ($actualHash -cne $row.sha256 -or [string]$actualBytes -cne [string]$row.bytes) {
        $manifestFailureCount++
    }
}

$aggregateLines = @(
    $manifestRows |
        Where-Object { $_.in_aggregate -ceq 'true' } |
        Sort-Object relative_path |
        ForEach-Object { $_.relative_path + '|' + $_.sha256 + '|' + $_.bytes }
)
$packageAggregate = Get-TextSha256 ($aggregateLines -join [char]10)

$listed = @($manifestRows.relative_path | ForEach-Object { $_.Replace('/','\') })
$actualMembers = @(
    Get-ChildItem -LiteralPath $prepRoot -Recurse -File |
        ForEach-Object { $_.FullName.Substring($prepRoot.Length + 1) } |
        Where-Object { $_ -cne 'manifest.csv' }
)
$unlistedCount = @($actualMembers | Where-Object { $listed -cnotcontains $_ }).Count
$missingListedCount = @($listed | Where-Object { $actualMembers -cnotcontains $_ }).Count

$formalRows = @(Import-Csv -LiteralPath (Join-Path $prepRoot 'formal-32-baseline.csv') -Encoding UTF8)
$formalFailureCount = 0
$formalActual = New-Object System.Collections.Generic.List[object]
foreach ($row in $formalRows) {
    $full = Join-Path $ProjectRoot ($row.relative_path.Replace('/','\'))
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        $formalFailureCount++
        $formalActual.Add([pscustomobject]@{relative_path=$row.relative_path;sha256=''})
        continue
    }
    $actualHash = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLowerInvariant()
    $actualBytes = (Get-Item -LiteralPath $full).Length
    $formalActual.Add([pscustomobject]@{relative_path=$row.relative_path;sha256=$actualHash})
    if ($actualHash -cne $row.sha256 -or [string]$actualBytes -cne [string]$row.bytes) {
        $formalFailureCount++
    }
}
$formalLines = @($formalActual | Sort-Object relative_path | ForEach-Object { $_.relative_path + '|' + $_.sha256 })
$formalAggregate = Get-TextSha256 ($formalLines -join [char]10)

$signoffPath = Join-Path $ProjectRoot '审计\子代理交接\m2_final_review_mi350p_signoff.csv'
$signoffRows = @(Import-Csv -LiteralPath $signoffPath -Encoding UTF8)
$writeRows = @(Import-Csv -LiteralPath (Join-Path $prepRoot 'authorized-write-set.csv') -Encoding UTF8)
$guards = @(Import-Csv -LiteralPath (Join-Path $prepRoot 'no-write-guards.csv') -Encoding UTF8)
$targets = @(Import-Csv -LiteralPath (Join-Path $prepRoot 'new-file-targets.csv') -Encoding UTF8)
$absentTargetCount = 0
foreach ($target in $targets) {
    $full = Join-Path $ProjectRoot ($target.target_path.Replace('/','\'))
    if (-not (Test-Path -LiteralPath $full)) {
        $absentTargetCount++
    }
}

$checkpoint = [ordered]@{
    status = 'in_progress'
    reviewer = 'm2_mi350p_formal_transaction_independent_review'
    write_scope = '审计/子代理交接/m2_mi350p_formal_transaction_independent_review/'
    generated_at = '2026-08-13'
    prep = [ordered]@{
        manifest_sha256 = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
        manifest_rows = $manifestRows.Count
        manifest_member_failures = $manifestFailureCount
        unlisted_files_excluding_manifest = $unlistedCount
        missing_listed_files = $missingListedCount
        aggregate = $packageAggregate
    }
    formal = [ordered]@{
        table_rows = $formalRows.Count
        member_failures = $formalFailureCount
        aggregate = $formalAggregate
    }
    signed_data = [ordered]@{
        signoff_sha256 = (Get-FileHash -LiteralPath $signoffPath -Algorithm SHA256).Hash.ToLowerInvariant()
        signoff_rows = $signoffRows.Count
        lifecycle_pk_writes = @($signoffRows | Where-Object binding_kind -ceq 'lifecycle_pk_write').Count
        file_payloads = @($signoffRows | Where-Object { $_.binding_kind -in @('card_copy','source_copy') }).Count
        authorized_write_rows = $writeRows.Count
        write_tables = @($writeRows.target_path | Sort-Object -Unique).Count
        guards = $guards.Count
        new_file_targets = $targets.Count
        absent_targets = $absentTargetCount
    }
    expected = [ordered]@{
        prep_manifest_sha256 = 'c21612350bae17288e365d26f95b5f669426ba99fd33cefce746644986cb3c98'
        prep_aggregate = 'e7138b42baee6b2d138cb5d8f31593c4f6c62319fa16688e866b840d2e419949'
        formal_aggregate = 'f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10'
        candidate_aggregate = '28923f7aa9dea488152f699e6879319d1fb96222fe72745754cf8ffd7b46518e'
        candidate_validator_checks = 111390
    }
    formal_writes_performed = 0
}
$out = Join-Path $ReviewRoot 'review-checkpoint.json'
[System.IO.File]::WriteAllText($out,(($checkpoint | ConvertTo-Json -Depth 8) + [Environment]::NewLine),$Utf8)
Write-Output $out