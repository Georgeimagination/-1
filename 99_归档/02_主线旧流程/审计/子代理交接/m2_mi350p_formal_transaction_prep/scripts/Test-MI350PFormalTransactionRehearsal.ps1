#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourceRoot,
    [Parameter(Mandatory=$true)][ValidateSet('positive','rollback_after_3_tables','rollback_after_2_payloads')][string]$Scenario,
    [string]$PackageRoot = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总\审计\子代理交接\m2_mi350p_formal_transaction_prep'
)
Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$Utf8NoBom=New-Object Text.UTF8Encoding($false)
$ExpectedBaseline='f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10'
$ExpectedPostmerge='28923f7aa9dea488152f699e6879319d1fb96222fe72745754cf8ffd7b46518e'
function Fail([string]$Message){throw $Message}
function Get-Sha256([string]$Path){return(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Get-TextSha256([string]$Text){$a=[Security.Cryptography.SHA256]::Create();try{return([BitConverter]::ToString($a.ComputeHash($Utf8NoBom.GetBytes($Text))).Replace('-','').ToLowerInvariant())}finally{$a.Dispose()}}
function Get-ChildPath([string]$Root,[string]$RelativePath,[bool]$MustExist=$true){$rootFull=[IO.Path]::GetFullPath($Root).TrimEnd('\');$full=[IO.Path]::GetFullPath((Join-Path $rootFull ($RelativePath.Replace('/','\'))));if(-not$full.StartsWith($rootFull+'\',[StringComparison]::OrdinalIgnoreCase)){Fail "Path escapes root: $RelativePath"};if($MustExist-and-not(Test-Path -LiteralPath $full -PathType Leaf)){Fail "Missing file: $full"};return $full}
function Get-Aggregate([string]$Root,[object[]]$Manifest){$parts=foreach($entry in($Manifest|Sort-Object relative_path)){[string]$entry.relative_path+'|'+(Get-Sha256 (Get-ChildPath $Root ([string]$entry.relative_path)))};return Get-TextSha256 ($parts-join[char]10)}
$SourceRoot=(Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\');$PackageRoot=(Resolve-Path -LiteralPath $PackageRoot).Path.TrimEnd('\')
$manifest=@(Import-Csv -LiteralPath (Join-Path $PackageRoot 'formal-32-baseline.csv') -Encoding UTF8);$newFiles=@(Import-Csv -LiteralPath (Join-Path $PackageRoot 'new-file-targets.csv') -Encoding UTF8)
$rehearsalBase=Join-Path $PackageRoot 'rehearsal';$mirror=Join-Path $rehearsalBase ('mirror-'+$Scenario);$result=Join-Path $rehearsalBase ('result-'+$Scenario)
foreach($path in @($mirror,$result)){if(Test-Path -LiteralPath $path){Remove-Item -LiteralPath $path -Recurse -Force};New-Item -ItemType Directory -Path $path|Out-Null}
foreach($entry in $manifest){$source=Get-ChildPath $SourceRoot ([string]$entry.relative_path);$target=Get-ChildPath $mirror ([string]$entry.relative_path) $false;[IO.Directory]::CreateDirectory((Split-Path -Parent $target))|Out-Null;[IO.File]::Copy($source,$target,$false)}
[IO.File]::WriteAllText((Join-Path $mirror '.mi350p-formal-transaction-mirror'),'MI350P-FORMAL-TRANSACTION-MIRROR-20260813',$Utf8NoBom)
$endpoints=@(Import-Csv -LiteralPath (Get-ChildPath $SourceRoot '最小参考资料库/source-endpoints.csv') -Encoding UTF8);$endpointCopies=0;foreach($endpoint in $endpoints){$relative=[string]$endpoint.local_path;if([string]::IsNullOrWhiteSpace($relative)){continue};$source=Get-ChildPath $SourceRoot $relative $false;if(-not(Test-Path -LiteralPath $source -PathType Leaf)){continue};$target=Get-ChildPath $mirror $relative $false;[IO.Directory]::CreateDirectory((Split-Path -Parent $target))|Out-Null;[IO.File]::Copy($source,$target,$false);$endpointCopies++}
if((Get-Aggregate $mirror $manifest)-cne$ExpectedBaseline){Fail 'Mirror baseline aggregate differs before execution.'}
$beforeFormal=Get-Aggregate $SourceRoot $manifest;$executor=Join-Path $PackageRoot 'scripts\Invoke-MI350PFormalTransaction.ps1'
$env:MI350P_FORMAL_TRANSACTION_TEST_FAIL_AFTER_REPLACEMENTS='';$env:MI350P_FORMAL_TRANSACTION_TEST_FAIL_AFTER_PAYLOADS=''
if($Scenario-ceq'rollback_after_3_tables'){$env:MI350P_FORMAL_TRANSACTION_TEST_FAIL_AFTER_REPLACEMENTS='3'}
if($Scenario-ceq'rollback_after_2_payloads'){$env:MI350P_FORMAL_TRANSACTION_TEST_FAIL_AFTER_PAYLOADS='2'}
$previousPreference=$ErrorActionPreference;$ErrorActionPreference='Continue';$output=@(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $executor -SourceRoot $SourceRoot -TargetRoot $mirror -ResultRoot $result 2>&1);$code=$LASTEXITCODE;$ErrorActionPreference=$previousPreference
$env:MI350P_FORMAL_TRANSACTION_TEST_FAIL_AFTER_REPLACEMENTS='';$env:MI350P_FORMAL_TRANSACTION_TEST_FAIL_AFTER_PAYLOADS=''
[IO.File]::WriteAllLines((Join-Path $PackageRoot ('logs\'+$Scenario+'-executor-output.txt')),@($output|ForEach-Object{[string]$_}),$Utf8NoBom)
$outcomePath=Join-Path $result 'transaction-outcome.json';if(-not(Test-Path -LiteralPath $outcomePath -PathType Leaf)){Fail 'Transaction outcome is missing.'};$outcome=Get-Content -LiteralPath $outcomePath -Raw -Encoding UTF8|ConvertFrom-Json
if($Scenario-ceq'rollback_after_3_tables' -and -not([string]$outcome.error -match 'INJECTED_TEST_FAILURE_AFTER_3_REPLACEMENTS')){Fail ('Scenario did not reach the three-table injection point: '+[string]$outcome.error)}
if($Scenario-ceq'rollback_after_2_payloads' -and -not([string]$outcome.error -match 'INJECTED_TEST_FAILURE_AFTER_2_PAYLOADS')){Fail ('Scenario did not reach the two-payload injection point: '+[string]$outcome.error)}
$journalPath=Join-Path $result 'commit-rollback-journal.csv';if(-not(Test-Path -LiteralPath $journalPath -PathType Leaf)){Fail 'Transaction journal is missing.'};$journal=@(Import-Csv -LiteralPath $journalPath -Encoding UTF8)
$mirrorAggregate=Get-Aggregate $mirror $manifest
if($Scenario-ceq'positive'){
    if($code-ne0-or[string]$outcome.status-cne'PASS'){Fail "Positive transaction failed: $($output-join' | ')"}
    if($mirrorAggregate-cne$ExpectedPostmerge){Fail "Positive mirror aggregate differs: $mirrorAggregate"}
    foreach($item in $newFiles){$target=Get-ChildPath $mirror ([string]$item.target_path);if((Get-Sha256 $target)-cne[string]$item.source_sha256){Fail "Positive payload differs: $($item.target_path)"}}
    $expectedStatus='PASS';$rollbackSucceeded=$false
}else{
    if($code-eq0-or[string]$outcome.status-cne'FAIL_ROLLED_BACK'-or-not[bool]$outcome.rollback_succeeded){Fail 'Injected failure did not report successful rollback.'}
    if($mirrorAggregate-cne$ExpectedBaseline){Fail "Rollback aggregate differs: $mirrorAggregate"}
    foreach($item in $newFiles){$target=Get-ChildPath $mirror ([string]$item.target_path) $false;if(Test-Path -LiteralPath $target){Fail "Rollback left payload: $($item.target_path)"}}
    $expectedStatus='FAIL_ROLLED_BACK';$rollbackSucceeded=$true
}
$afterFormal=Get-Aggregate $SourceRoot $manifest;if($afterFormal-cne$beforeFormal-or$afterFormal-cne$ExpectedBaseline){Fail 'Formal root changed during rehearsal.'}
foreach($item in $newFiles){$formalTarget=Get-ChildPath $SourceRoot ([string]$item.target_path) $false;if(Test-Path -LiteralPath $formalTarget){Fail "Formal payload appeared during rehearsal: $($item.target_path)"}}
$tempFiles=@(Get-ChildItem -LiteralPath $mirror -Recurse -Force -File|Where-Object{$_.Name-like'*.mi350p-formal-transaction-*' -and $_.Name-cne'.mi350p-formal-transaction-mirror'});if($tempFiles.Count-ne0){Fail 'Transaction temp files remain in mirror.'}
$lockFiles=@(Get-ChildItem -LiteralPath (Join-Path $PackageRoot 'scripts') -Force -File -Filter 'MI350P-FORMAL-TRANSACTION-LOCK-*.lock');if($lockFiles.Count-ne0){Fail 'Transaction lock files remain after rehearsal.'}
$transactionTemps=@(Get-ChildItem -LiteralPath $PackageRoot -Force -Directory -Filter '.tmp-mi350p-formal-*');if($transactionTemps.Count-ne0){Fail 'Transaction temp directories remain after rehearsal.'}
$summary=[ordered]@{scenario=$Scenario;status='passed';executor_exit_code=$code;expected_outcome=$expectedStatus;rollback_succeeded=$rollbackSucceeded;mirror_aggregate_after=$mirrorAggregate;formal_aggregate_before=$beforeFormal;formal_aggregate_after=$afterFormal;journal_rows=$journal.Count;csv_commit_complete=@($journal|Where-Object{$_.phase-ceq'commit_complete'-and$_.kind-ceq'csv_replace'}).Count;csv_rollback_complete=@($journal|Where-Object{$_.phase-ceq'rollback_complete'-and$_.kind-ceq'csv_restore'}).Count;payload_commit_complete=@($journal|Where-Object{$_.phase-ceq'commit_complete'-and$_.kind-ceq'payload_copy'}).Count;payload_rollback_complete=@($journal|Where-Object{$_.phase-ceq'rollback_complete'-and$_.kind-ceq'payload_delete'}).Count;endpoint_files_seeded=$endpointCopies;formal_writes_performed=0}
[IO.File]::WriteAllText((Join-Path $PackageRoot ('rehearsal\'+$Scenario+'-summary.json')),(($summary|ConvertTo-Json -Depth 5)+"`r`n"),$Utf8NoBom)
Write-Output ($summary|ConvertTo-Json -Compress)
Write-Output "PASS: MI350P rehearsal scenario $Scenario; formal root unchanged."
