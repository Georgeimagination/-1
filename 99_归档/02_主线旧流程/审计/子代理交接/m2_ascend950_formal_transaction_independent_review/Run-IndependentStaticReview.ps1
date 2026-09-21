#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$RootPath,
    [Parameter(Mandatory=$true)][string]$PrepRoot,
    [Parameter(Mandatory=$true)][string]$OutputPath
)
Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$Checks=0
$Utf8NoBom=New-Object Text.UTF8Encoding($false)
function Assert-Check([bool]$Condition,[string]$Message){if(-not $Condition){throw $Message};$script:Checks++}
function Get-Hash([string]$Path){return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Get-TextHash([string]$Text){$a=[Security.Cryptography.SHA256]::Create();try{return([BitConverter]::ToString($a.ComputeHash($Utf8NoBom.GetBytes($Text))).Replace('-','').ToLowerInvariant())}finally{$a.Dispose()}}
function Get-Child([string]$Base,[string]$Relative,[bool]$MustExist=$true){$baseFull=[IO.Path]::GetFullPath($Base).TrimEnd('\');$full=[IO.Path]::GetFullPath((Join-Path $baseFull ($Relative.Replace('/','\'))));Assert-Check ($full.StartsWith($baseFull+'\',[StringComparison]::OrdinalIgnoreCase)) "Path escapes root: $Relative";if($MustExist){Assert-Check (Test-Path -LiteralPath $full -PathType Leaf) "File missing: $full"};return $full}
$RootPath=(Resolve-Path -LiteralPath $RootPath).Path.TrimEnd('\')
$PrepRoot=(Resolve-Path -LiteralPath $PrepRoot).Path.TrimEnd('\')
$manifestPath=Get-Child $PrepRoot 'manifest.csv'
Assert-Check ((Get-Hash $manifestPath)-ceq'91af02c00a0e75854473503628ba49c4c3b062ffaca25199486cdb01fcb7c316') 'Prep manifest SHA-256 differs.'
$manifest=@(Import-Csv -LiteralPath $manifestPath -Encoding UTF8)
Assert-Check ($manifest.Count-eq66) 'Prep manifest is not 66 rows.'
Assert-Check (@($manifest.relative_path|Group-Object|Where-Object Count -gt 1).Count-eq0) 'Prep manifest paths are duplicated.'
foreach($m in $manifest){$file=Get-Child $PrepRoot ([string]$m.relative_path);Assert-Check ((Get-Hash $file)-ceq[string]$m.sha256) "Prep member hash differs: $($m.relative_path)";Assert-Check ((Get-Item -LiteralPath $file).Length-eq[int64]$m.bytes) "Prep member bytes differ: $($m.relative_path)"}
$aggregateParts=@($manifest|Where-Object in_aggregate -CEQ 'true'|Sort-Object relative_path|ForEach-Object{$_.relative_path+'|'+$_.sha256+'|'+$_.bytes})
Assert-Check ($aggregateParts.Count-eq66) 'Prep aggregate row count differs.'
$prepAggregate=Get-TextHash ($aggregateParts-join[char]10)
Assert-Check ($prepAggregate-ceq'a83dc6f86c06dc44daa70a76525f2ea2dc3e4047eca1e3b15bea09245f42d418') 'Prep aggregate differs.'
$staticHashes=@(Import-Csv -LiteralPath (Get-Child $PrepRoot 'static-contract-file-hashes.csv') -Encoding UTF8)
foreach($entry in $staticHashes){$file=Get-Child $PrepRoot ([string]$entry.relative_path);Assert-Check ((Get-Hash $file)-ceq[string]$entry.sha256) "Static member hash differs: $($entry.relative_path)";Assert-Check ((Get-Item -LiteralPath $file).Length-eq[int64]$entry.bytes) "Static member bytes differ: $($entry.relative_path)"}
$signoffPath=Get-Child $RootPath '审计/子代理交接/m2_final_review_ascend950_physical_signoff.csv'
Assert-Check ((Get-Hash $signoffPath)-ceq'0f59aa2fd893473eb1002d44816e16ace6b204259ac94e802b5f00774ea0cbd5') 'Upstream signoff SHA-256 differs.'
$signoff=@(Import-Csv -LiteralPath $signoffPath -Encoding UTF8)
Assert-Check ($signoff.Count-eq553) 'Upstream signoff is not 553 rows.'
Assert-Check (@($signoff|Where-Object binding_kind -CEQ 'lifecycle_pk_write').Count-eq545) 'Upstream structural write count differs.'
Assert-Check (@($signoff|Where-Object binding_kind -CEQ 'card_copy').Count-eq3) 'Card copy count differs.'
Assert-Check (@($signoff|Where-Object binding_kind -CEQ 'source_copy').Count-eq5) 'Source copy count differs.'
Assert-Check (@($signoff|Where-Object verdict -CNE 'accept').Count-eq0) 'Upstream signoff verdict differs.'
Assert-Check (@($signoff|Where-Object reviewer -CNE 'm2_final_review_ascend950').Count-eq0) 'Upstream reviewer differs.'
$writeSet=@(Import-Csv -LiteralPath (Get-Child $PrepRoot 'authorized-write-set.csv') -Encoding UTF8)
$guards=@(Import-Csv -LiteralPath (Get-Child $PrepRoot 'no-write-guards.csv') -Encoding UTF8)
$newFiles=@(Import-Csv -LiteralPath (Get-Child $PrepRoot 'new-file-targets.csv') -Encoding UTF8)
Assert-Check ($writeSet.Count-eq545) 'Authorized write count differs.'
Assert-Check (@($writeSet.target_path|Sort-Object -Unique).Count-eq20) 'Authorized table count differs.'
Assert-Check ($guards.Count-eq5) 'Guard count differs.'
Assert-Check ($newFiles.Count-eq8) 'New-file target count differs.'
foreach($target in $newFiles){Assert-Check (-not(Test-Path -LiteralPath (Get-Child $RootPath ([string]$target.target_path) $false))) "Formal new target exists: $($target.target_path)"}
$formalManifest=@(Import-Csv -LiteralPath (Get-Child $PrepRoot 'formal-32-baseline.csv') -Encoding UTF8)
Assert-Check ($formalManifest.Count-eq32) 'Formal manifest count differs.'
$formalParts=foreach($entry in($formalManifest|Sort-Object relative_path)){$file=Get-Child $RootPath ([string]$entry.relative_path);$entry.relative_path+'|'+(Get-Hash $file)}
$formalAggregate=Get-TextHash ($formalParts-join[char]10)
Assert-Check ($formalAggregate-ceq'f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10') 'Formal aggregate differs.'
$expectedPosthash=Get-Child $PrepRoot 'expected-candidate-20-table-posthashes.csv'
Assert-Check ((Get-Hash $expectedPosthash)-ceq'b84ce89dbdf96accb7861e61cedbfb33618ed8793d33188030f7ef51f15efe73') 'Candidate posthash manifest differs.'
$template=@(Import-Csv -LiteralPath (Get-Child $PrepRoot 'transaction-review-signoff-template.csv') -Encoding UTF8)
Assert-Check ($template.Count-eq1) 'Transaction review template row count differs.'
Assert-Check ($template[0].verdict-ceq'pending') 'Prep template is not pending.'
Assert-Check ($template[0].ready_for_formal_execution-ceq'false') 'Prep template unexpectedly authorizes execution.'
Assert-Check ($template[0].transaction_script_sha256-ceq(Get-Hash (Get-Child $PrepRoot 'scripts/Invoke-Ascend950FormalTransaction.ps1'))) 'Transaction script binding differs.'
Assert-Check ($template[0].preflight_script_sha256-ceq(Get-Hash (Get-Child $PrepRoot 'scripts/Test-Ascend950FormalTransactionPreflight.ps1'))) 'Preflight script binding differs.'
Assert-Check ($template[0].rehearsal_script_sha256-ceq(Get-Hash (Get-Child $PrepRoot 'scripts/Test-Ascend950FormalTransactionRehearsal.ps1'))) 'Rehearsal script binding differs.'
$temp=@(Get-ChildItem -LiteralPath $RootPath -Recurse -Force -File|Where-Object{$_.Name-like'.ascend950-formal-transaction-*'})
$locks=@(Get-ChildItem -LiteralPath (Get-Child $PrepRoot 'scripts/Invoke-Ascend950FormalTransaction.ps1'|Split-Path -Parent) -Force -File|Where-Object{$_.Name-like'ASCEND950-FORMAL-TRANSACTION-LOCK-*.lock'})
Assert-Check ($temp.Count-eq0) 'Formal transaction temp files remain.'
Assert-Check ($locks.Count-eq0) 'Transaction lock files remain.'
$result=[ordered]@{status='passed';generated_at='2026-08-13';checks=$Checks;prep_manifest_sha256=Get-Hash $manifestPath;prep_manifest_rows=$manifest.Count;prep_aggregate_sha256=$prepAggregate;static_hash_entries=$staticHashes.Count;upstream_signoff_sha256=Get-Hash $signoffPath;upstream_signoff_rows=$signoff.Count;authorized_write_rows=$writeSet.Count;authorized_write_tables=@($writeSet.target_path|Sort-Object -Unique).Count;card_copies=3;source_copies=5;no_write_guards=$guards.Count;new_file_targets=$newFiles.Count;formal_table_count=$formalManifest.Count;formal_aggregate_sha256=$formalAggregate;candidate_posthash_manifest_sha256=Get-Hash $expectedPosthash;candidate_aggregate_sha256='bcb16e932019c1625e9b5a5309a37f569c0bb230b7c921a589dd3f7175632b8c';formal_new_targets_existing=0;formal_temp_files=$temp.Count;transaction_lock_files=$locks.Count;formal_writes_performed=0}
[IO.File]::WriteAllText($OutputPath,(($result|ConvertTo-Json -Depth 5)+"`r`n"),$Utf8NoBom)
$result|ConvertTo-Json -Compress
