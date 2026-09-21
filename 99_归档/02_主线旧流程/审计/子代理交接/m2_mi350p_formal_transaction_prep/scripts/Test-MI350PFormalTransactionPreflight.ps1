#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourceRoot,
    [Parameter(Mandatory=$true)][string]$TargetRoot,
    [string]$WorkRoot = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总\审计\子代理交接\m2_mi350p_formal_transaction_prep'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$script:Checks = 0
$ExpectedFormalAggregate = 'f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10'
$ExpectedFinalReportSha256 = '470d381d66e5cb7ccd7b3fc9aa88ede12ed1a995a6a1af6e03844630d9b43461'
$ExpectedSignoffSha256 = '74ac69c299f5ce817c03236ef97df4e13f08f2d6724bb1c0178376661be5dad1'
$ExpectedFreezeSha256 = '1cb279b56f4fbfc688ed2f798646a93baed02ffbd34a647ffecf4cb6672f0e01'
$ExpectedFreezeAggregate = '152df43e8b64c2b78c54a41c6cf9bd7acfa4d3315fcf33d6128399b22f2f8825'
$ExpectedFormalManifestSha256 = '68773358da2fe590aaaecdcccdaf0e68d61176df35d4b759dad14b4ae1174e5c'
$ExpectedValidatorChecks = '111343'
$ExpectedStaticHashes = [ordered]@{
    'formal-32-baseline.csv' = 'c8c424fa21838248cca020b6c5feefd9c05287adec8c077474f0f36cff834f5f'
    'authorized-write-set.csv' = 'f2f92876b801d5bc98f0e7540010c595070a8f1103039d763d32672f3bdcb801'
    'formal-csv-backup-candidates.csv' = 'acb17a4b9b41df585b013e136560f206ed5fc943102f0d231494852da834a9b3'
    'no-write-guards.csv' = '1a979d0ce56346c456e1e4f372ffe92b4800c15dba724944de57242a7522e28c'
    'new-file-targets.csv' = '483f458ad8f65602c9ac8acc191d743b8bad65790488e3a0db6dbce05da4a0fd'
    'backup-rollback-inventory.csv' = '02c08c6c81f3ebbd9d62c29a91d6e35ffd54e31623c8f78e89e9a285784afcc9'
    'static-contract-file-hashes.csv' = 'c1e6bfe40fec2f0ee97200e7e63a7db7342deb4979fcef123a5347cac0d05d93'
}
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Assert-Check { param([bool]$Condition,[string]$Message); if(-not $Condition){throw $Message}; $script:Checks++ }
function Get-Sha256 { param([string]$Path); return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-TextSha256 { param([string]$Text); $a=[Security.Cryptography.SHA256]::Create(); try{return ([BitConverter]::ToString($a.ComputeHash($Utf8NoBom.GetBytes($Text))).Replace('-','').ToLowerInvariant())}finally{$a.Dispose()} }
function Get-ExistingRoot { param([string]$Path,[string]$Label); Assert-Check (Test-Path -LiteralPath $Path -PathType Container) "$Label is missing: $Path"; return (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\') }
function Get-ChildPath {
    param([string]$Root,[string]$RelativePath,[bool]$MustExist=$true)
    Assert-Check (-not [string]::IsNullOrWhiteSpace($RelativePath)) 'Relative path is empty.'
    $normalized=$RelativePath.Replace('/','\')
    Assert-Check (-not [IO.Path]::IsPathRooted($normalized)) "Rooted path is forbidden: $RelativePath"
    $rootFull=[IO.Path]::GetFullPath($Root).TrimEnd('\')
    $full=[IO.Path]::GetFullPath((Join-Path $rootFull $normalized))
    Assert-Check ($full.StartsWith($rootFull+'\',[StringComparison]::OrdinalIgnoreCase)) "Path escapes root: $RelativePath"
    if($MustExist){Assert-Check (Test-Path -LiteralPath $full -PathType Leaf) "Required file is missing: $full"}
    return $full
}
function Get-CanonicalRowSha256 { param([object]$Row); return Get-TextSha256 (@($Row|ConvertTo-Csv -NoTypeInformation)-join[char]10) }
function Get-FormalAggregate {
    param([string]$Root,[object[]]$Manifest)
    $parts=foreach($entry in ($Manifest|Sort-Object relative_path)){ $path=Get-ChildPath $Root ([string]$entry.relative_path); [string]$entry.relative_path+'|'+(Get-Sha256 $path) }
    return Get-TextSha256 ($parts-join[char]10)
}
function Get-FreezeAggregate { param([object[]]$Rows); $parts=foreach($row in ($Rows|Sort-Object relative_path)){[string]$row.relative_path+'|'+[string]$row.sha256+'|'+[string]$row.byte_size}; return Get-TextSha256 ($parts-join[char]10) }

$SourceRoot=Get-ExistingRoot $SourceRoot 'SourceRoot'
$TargetRoot=Get-ExistingRoot $TargetRoot 'TargetRoot'
$WorkRoot=Get-ExistingRoot $WorkRoot 'WorkRoot'

foreach($name in $ExpectedStaticHashes.Keys){$path=Get-ChildPath $WorkRoot $name; Assert-Check ((Get-Sha256 $path)-ceq $ExpectedStaticHashes[$name]) "Static contract hash differs: $name"}
$formalManifest=@(Import-Csv -LiteralPath (Get-ChildPath $WorkRoot 'formal-32-baseline.csv') -Encoding UTF8)
$writeSet=@(Import-Csv -LiteralPath (Get-ChildPath $WorkRoot 'authorized-write-set.csv') -Encoding UTF8)
$backupList=@(Import-Csv -LiteralPath (Get-ChildPath $WorkRoot 'formal-csv-backup-candidates.csv') -Encoding UTF8)
$guards=@(Import-Csv -LiteralPath (Get-ChildPath $WorkRoot 'no-write-guards.csv') -Encoding UTF8)
$newFiles=@(Import-Csv -LiteralPath (Get-ChildPath $WorkRoot 'new-file-targets.csv') -Encoding UTF8)
Assert-Check ($formalManifest.Count-eq32) 'Formal manifest is not 32 rows.'
Assert-Check ($writeSet.Count-eq270) 'Authorized write-set is not 270 rows.'
Assert-Check ($backupList.Count-eq19) 'Backup list is not 19 rows.'
Assert-Check ($guards.Count-eq3) 'No-write guard list is not 3 rows.'
Assert-Check ($newFiles.Count-eq4) 'New-file target list is not 4 rows.'
Assert-Check ((Get-FormalAggregate $SourceRoot $formalManifest)-ceq $ExpectedFormalAggregate) 'SourceRoot formal aggregate differs.'
Assert-Check ((Get-FormalAggregate $TargetRoot $formalManifest)-ceq $ExpectedFormalAggregate) 'TargetRoot formal aggregate differs.'
foreach($entry in $formalManifest){
    $source=Get-ChildPath $SourceRoot ([string]$entry.relative_path)
    $target=Get-ChildPath $TargetRoot ([string]$entry.relative_path)
    Assert-Check ((Get-Sha256 $source)-ceq [string]$entry.sha256) "Source formal table hash differs: $($entry.relative_path)"
    Assert-Check ((Get-Sha256 $target)-ceq [string]$entry.sha256) "Target formal table hash differs: $($entry.relative_path)"
    Assert-Check ([string](Get-Item -LiteralPath $target).Length-ceq [string]$entry.bytes) "Target formal table size differs: $($entry.relative_path)"
}

$stagingBase=Get-ExistingRoot (Join-Path $SourceRoot '审计\子代理交接\m2_staging\M2-W3-AMD-MI350P-CARD') 'MI350P staging root'
$signoffPath=Get-ChildPath $SourceRoot '审计/子代理交接/m2_final_review_mi350p_signoff.csv'
$finalReportPath=Get-ChildPath $SourceRoot '审计/子代理交接/m2_final_review_mi350p.md'
$freezePath=Get-ChildPath $stagingBase 'validation/staging-file-manifest.csv'
$formalBindingPath=Get-ChildPath $stagingBase 'validation/formal-32-csv-baseline.csv'
Assert-Check ((Get-Sha256 $finalReportPath)-ceq $ExpectedFinalReportSha256) 'Final review report SHA-256 differs.'
Assert-Check ((Get-Sha256 $signoffPath)-ceq $ExpectedSignoffSha256) 'Final signoff SHA-256 differs.'
Assert-Check ((Get-Sha256 $freezePath)-ceq $ExpectedFreezeSha256) 'Freeze manifest SHA-256 differs.'
Assert-Check ((Get-Sha256 $formalBindingPath)-ceq $ExpectedFormalManifestSha256) 'Signed formal baseline manifest SHA-256 differs.'
$freeze=@(Import-Csv -LiteralPath $freezePath -Encoding UTF8)
Assert-Check ($freeze.Count-eq50) 'Freeze manifest is not 50 rows.'
Assert-Check (@($freeze.relative_path|Group-Object|Where-Object Count -gt 1).Count-eq0) 'Freeze manifest contains duplicate paths.'
foreach($entry in $freeze){$path=Get-ChildPath $stagingBase ([string]$entry.relative_path);Assert-Check ((Get-Sha256 $path)-ceq [string]$entry.sha256) "Freeze member hash differs: $($entry.relative_path)";Assert-Check ([string](Get-Item -LiteralPath $path).Length-ceq [string]$entry.byte_size) "Freeze member size differs: $($entry.relative_path)"}
Assert-Check ((Get-FreezeAggregate $freeze)-ceq $ExpectedFreezeAggregate) 'Freeze aggregate differs.'
$signedFormal=@(Import-Csv -LiteralPath $formalBindingPath -Encoding UTF8)
Assert-Check ($signedFormal.Count-eq32) 'Signed formal baseline is not 32 rows.'
Assert-Check (@($signedFormal.table_path|Group-Object|Where-Object Count -gt 1).Count-eq0) 'Signed formal baseline contains duplicate paths.'
foreach($entry in $signedFormal){$path=Get-ChildPath $SourceRoot ([string]$entry.table_path);Assert-Check ((Get-Sha256 $path)-ceq [string]$entry.sha256) "Signed formal table hash differs: $($entry.table_path)";Assert-Check ([string](Get-Item -LiteralPath $path).Length-ceq [string]$entry.byte_size) "Signed formal table size differs: $($entry.table_path)"}

$signoff=@(Import-Csv -LiteralPath $signoffPath -Encoding UTF8)
Assert-Check ($signoff.Count-eq274) 'Final signoff is not 274 rows.'
Assert-Check (@($signoff.signoff_row_id|Group-Object|Where-Object Count -gt 1).Count-eq0) 'Signoff IDs are duplicated.'
$signoffMap=@{};foreach($row in $signoff){$signoffMap[[string]$row.signoff_row_id]=$row;Assert-Check ([string]$row.freeze_manifest_sha256-ceq $ExpectedFreezeSha256) "Signoff freeze binding differs: $($row.signoff_row_id)";Assert-Check ([string]$row.freeze_aggregate_sha256-ceq $ExpectedFreezeAggregate) "Signoff freeze aggregate differs: $($row.signoff_row_id)";Assert-Check ([string]$row.formal_baseline_manifest_sha256-ceq $ExpectedFormalManifestSha256) "Signoff formal-manifest binding differs: $($row.signoff_row_id)";Assert-Check ([string]$row.formal_baseline_aggregate_sha256-ceq $ExpectedFormalAggregate) "Signoff formal binding differs: $($row.signoff_row_id)";Assert-Check ([string]$row.temporary_merge_validator_checks-ceq $ExpectedValidatorChecks) "Signoff validator binding differs: $($row.signoff_row_id)";Assert-Check ([string]$row.verdict-ceq'accept') "Signoff verdict differs: $($row.signoff_row_id)";Assert-Check ([string]$row.reviewer-ceq'm2_final_review_mi350p') "Signoff reviewer differs: $($row.signoff_row_id)"}

$sourceCache=@{};$targetCache=@{}
foreach($entry in $writeSet){
    Assert-Check ($signoffMap.ContainsKey([string]$entry.signoff_row_id)) "Write row lacks signoff: $($entry.signoff_row_id)"
    $binding=$signoffMap[[string]$entry.signoff_row_id]
    foreach($column in @('target_path','pk_column','pk_value','source_path','source_sha256','source_bytes','source_review_status','authorized_review_status','semantic_status_column','semantic_status_before','semantic_status_after')){Assert-Check ([string]$entry.$column-ceq[string]$binding.$column) "Write/signoff binding differs at ${column}: $($entry.signoff_row_id)"}
    Assert-Check ([string]$entry.signed_source_line_sha256-ceq[string]$binding.source_line_sha256) "Signed source-line binding differs: $($entry.signoff_row_id)"
    $sourcePath=Get-ChildPath $SourceRoot ([string]$entry.source_path)
    Assert-Check ((Get-Sha256 $sourcePath)-ceq[string]$entry.source_sha256) "Write source hash differs: $($entry.signoff_row_id)"
    Assert-Check ([string](Get-Item -LiteralPath $sourcePath).Length-ceq[string]$entry.source_bytes) "Write source size differs: $($entry.signoff_row_id)"
    if(-not $sourceCache.ContainsKey($sourcePath)){$sourceCache[$sourcePath]=@(Import-Csv -LiteralPath $sourcePath -Encoding UTF8)}
    $targetPath=Get-ChildPath $TargetRoot ([string]$entry.target_path)
    Assert-Check ((Get-Sha256 $targetPath)-ceq[string]$entry.formal_premerge_sha256) "Write target prehash differs: $($entry.target_path)"
    Assert-Check ([string](Get-Item -LiteralPath $targetPath).Length-ceq[string]$entry.formal_premerge_bytes) "Write target size differs: $($entry.target_path)"
    if(-not $targetCache.ContainsKey($targetPath)){$targetCache[$targetPath]=@(Import-Csv -LiteralPath $targetPath -Encoding UTF8)}
    $sourceMatches=@($sourceCache[$sourcePath]|Where-Object{[string]$_.$([string]$entry.pk_column)-ceq[string]$entry.pk_value})
    $targetMatches=@($targetCache[$targetPath]|Where-Object{[string]$_.$([string]$entry.pk_column)-ceq[string]$entry.pk_value})
    Assert-Check ($sourceMatches.Count-eq1) "Write source PK count differs: $($entry.pk_value)"
    Assert-Check ($targetMatches.Count-eq0) "Write target PK already exists: $($entry.pk_value)"
    $header=@($targetCache[$targetPath][0].PSObject.Properties.Name);$values=[ordered]@{};foreach($column in $header){$values[$column]=[string]$sourceMatches[0].$column};$sourceRow=[pscustomobject]$values
    Assert-Check ((Get-CanonicalRowSha256 $sourceRow)-ceq[string]$entry.canonical_source_row_sha256) "Canonical source row differs: $($entry.signoff_row_id)"
    Assert-Check ([string]$sourceRow.review_status-ceq[string]$entry.source_review_status) "Source lifecycle differs: $($entry.signoff_row_id)"
    $sourceRow.review_status=[string]$entry.authorized_review_status
    if(-not [string]::IsNullOrEmpty([string]$entry.semantic_status_column)){$column=[string]$entry.semantic_status_column;Assert-Check ([string]$sourceRow.$column-ceq[string]$entry.semantic_status_before) "Semantic before-value differs: $($entry.signoff_row_id)";$sourceRow.$column=[string]$entry.semantic_status_after}
    Assert-Check ((Get-CanonicalRowSha256 $sourceRow)-ceq[string]$entry.canonical_authorized_row_sha256) "Canonical authorized row differs: $($entry.signoff_row_id)"
}
Assert-Check (@($writeSet|Group-Object{$_.target_path+'|'+$_.pk_value}|Where-Object Count -gt 1).Count-eq0) 'Write target keys are duplicated.'
Assert-Check ((@($writeSet.target_path|Sort-Object -Unique)-join[char]31)-ceq(@($backupList.target_path|Sort-Object -Unique)-join[char]31)) 'Write-table set differs from backup list.'

foreach($guard in $guards){$target=Get-ChildPath $TargetRoot ([string]$guard.target_path);Assert-Check ((Get-Sha256 $target)-ceq[string]$guard.formal_file_sha256) "Guard table hash differs: $($guard.guard_id)";$rows=@(Import-Csv -LiteralPath $target -Encoding UTF8);$matches=@($rows|Where-Object{[string]$_.$([string]$guard.pk_column)-ceq[string]$guard.pk_value});Assert-Check ($matches.Count-eq1) "Guard row count differs: $($guard.guard_id)";Assert-Check ((Get-CanonicalRowSha256 $matches[0])-ceq[string]$guard.canonical_row_sha256) "Guard row differs: $($guard.guard_id)"}
foreach($item in $newFiles){Assert-Check ($signoffMap.ContainsKey([string]$item.signoff_row_id)) "New file lacks signoff: $($item.signoff_row_id)";$binding=$signoffMap[[string]$item.signoff_row_id];Assert-Check ([string]$binding.source_path-ceq[string]$item.source_path) "New-file source binding differs: $($item.signoff_row_id)";Assert-Check ([string]$binding.target_path-ceq[string]$item.target_path) "New-file target binding differs: $($item.signoff_row_id)";$source=Get-ChildPath $SourceRoot ([string]$item.source_path);Assert-Check ((Get-Sha256 $source)-ceq[string]$item.source_sha256) "New-file source hash differs: $($item.signoff_row_id)";Assert-Check ([string](Get-Item -LiteralPath $source).Length-ceq[string]$item.source_bytes) "New-file source size differs: $($item.signoff_row_id)";$target=Get-ChildPath $TargetRoot ([string]$item.target_path) $false;Assert-Check (-not(Test-Path -LiteralPath $target)) "New-file target already exists: $($item.target_path)"}

$summary=[ordered]@{status='passed';checks=$Checks;formal_baseline_aggregate=$ExpectedFormalAggregate;final_review_report_sha256=$ExpectedFinalReportSha256;signoff_sha256=$ExpectedSignoffSha256;signed_formal_manifest_sha256=$ExpectedFormalManifestSha256;freeze_manifest_sha256=$ExpectedFreezeSha256;structured_rows=$writeSet.Count;write_tables=$backupList.Count;no_write_guards=$guards.Count;new_file_targets=$newFiles.Count;formal_writes_performed=0}
Write-Output ($summary|ConvertTo-Json -Compress)
Write-Output "PASS: MI350P formal transaction preflight; $Checks checks; target remains at f152 baseline."
