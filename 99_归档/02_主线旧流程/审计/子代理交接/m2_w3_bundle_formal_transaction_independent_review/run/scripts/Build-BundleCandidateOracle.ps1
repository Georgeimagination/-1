#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourceRoot,
    [string]$WorkRoot=''
)
Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$Utf8NoBom=New-Object Text.UTF8Encoding($false)
$ExpectedFormalAggregate='f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10'
$ExpectedCandidateAggregate='5f62191bfc737535802cd6e0524b1fdf7a742ca36300db11b5a9233d4540052a'
$ExpectedValidatorChecks=125619
function Fail([string]$Message){throw $Message}
function Get-Sha256([string]$Path){return(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Get-TextSha256([string]$Text){$a=[Security.Cryptography.SHA256]::Create();try{return([BitConverter]::ToString($a.ComputeHash($Utf8NoBom.GetBytes($Text))).Replace('-','').ToLowerInvariant())}finally{$a.Dispose()}}
function Get-ChildPath([string]$Root,[string]$RelativePath,[bool]$MustExist=$true){$r=[IO.Path]::GetFullPath($Root).TrimEnd('\');$p=[IO.Path]::GetFullPath((Join-Path $r ($RelativePath.Replace('/','\'))));if(-not$p.StartsWith($r+'\',[StringComparison]::OrdinalIgnoreCase)){Fail "Path escapes root: $RelativePath"};if($MustExist-and-not(Test-Path -LiteralPath $p -PathType Leaf)){Fail "Missing file: $p"};return $p}
function Get-Aggregate([string]$Root,[object[]]$Manifest){$parts=foreach($e in($Manifest|Sort-Object relative_path)){[string]$e.relative_path+'|'+(Get-Sha256(Get-ChildPath $Root ([string]$e.relative_path)))};return Get-TextSha256($parts-join[char]10)}
function Write-Csv([string]$Path,[object[]]$Rows){[IO.File]::WriteAllLines($Path,($Rows|ConvertTo-Csv -NoTypeInformation),$Utf8NoBom)}
$SourceRoot=(Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\')
if([string]::IsNullOrWhiteSpace($WorkRoot)){$WorkRoot=Split-Path -Parent $PSScriptRoot}
$WorkRoot=(Resolve-Path -LiteralPath $WorkRoot).Path.TrimEnd('\')
$manifest=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'formal-32-baseline.csv') -Encoding UTF8)
$backupList=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'formal-csv-backup-candidates.csv') -Encoding UTF8)
$oracleRoot=Join-Path $WorkRoot 'rehearsal\oracle-candidate'
$allowedParent=[IO.Path]::GetFullPath((Join-Path $WorkRoot 'rehearsal')).TrimEnd('\')
$oracleFull=[IO.Path]::GetFullPath($oracleRoot).TrimEnd('\')
if(-not$oracleFull.StartsWith($allowedParent+'\',[StringComparison]::OrdinalIgnoreCase)){Fail 'Oracle candidate path escapes rehearsal root.'}
if(Test-Path -LiteralPath $oracleFull){Remove-Item -LiteralPath $oracleFull -Recurse -Force}
[IO.Directory]::CreateDirectory($oracleFull)|Out-Null
try{
    if((Get-Aggregate $SourceRoot $manifest)-cne$ExpectedFormalAggregate){Fail 'Formal source aggregate differs before oracle build.'}
    foreach($entry in $manifest){$source=Get-ChildPath $SourceRoot ([string]$entry.relative_path);$target=Get-ChildPath $oracleFull ([string]$entry.relative_path) $false;[IO.Directory]::CreateDirectory((Split-Path -Parent $target))|Out-Null;[IO.File]::Copy($source,$target,$false)}
    [IO.File]::WriteAllText((Join-Path $oracleFull '.m2w3-bundle-isolated-target'),'M2-W3-BUNDLE-ISOLATED-TRANSACTION',$Utf8NoBom)
    $replay=Join-Path $WorkRoot 'scripts\Replay-BundleAuthorizedRows.ps1'
    $replayOutput=@(& $replay -SourceRoot $SourceRoot -TargetRoot $oracleFull -PackageRoot $WorkRoot 2>&1)
    $replaySucceeded=$?
    if(-not$replaySucceeded){Fail('Bundle replay failed: '+($replayOutput-join' | '))}
    Remove-Item -LiteralPath (Join-Path $oracleFull '.m2w3-bundle-isolated-target') -Force
    $validator=Get-ChildPath $SourceRoot 'scripts/validation/Validate-ResearchData.ps1'
    $validatorOutput=@(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $validator -RootPath $oracleFull 2>&1)
    if($LASTEXITCODE-ne0){Fail('Bundle oracle validator failed: '+($validatorOutput-join' | '))}
    [IO.File]::WriteAllLines((Join-Path $WorkRoot 'logs\candidate-oracle-validator.txt'),@($validatorOutput|ForEach-Object{[string]$_}),$Utf8NoBom)
    $m=[regex]::Match(($validatorOutput-join"`n"),'PASS:.*?(\d+)\s+checks executed')
    if(-not$m.Success-or[int]$m.Groups[1].Value-ne$ExpectedValidatorChecks){Fail 'Bundle oracle validator count differs.'}
    $aggregate=Get-Aggregate $oracleFull $manifest
    if($aggregate-cne$ExpectedCandidateAggregate){Fail "Bundle oracle aggregate differs: $aggregate"}
    $post=[Collections.Generic.List[object]]::new()
    foreach($item in($backupList|Sort-Object{[int]$_.commit_order})){
        $target=Get-ChildPath $oracleFull ([string]$item.target_path)
        $post.Add([pscustomobject][ordered]@{target_path=[string]$item.target_path;premerge_sha256=[string]$item.premerge_sha256;candidate_postmerge_sha256=Get-Sha256 $target;candidate_bytes=(Get-Item -LiteralPath $target).Length;formal_baseline_aggregate=$ExpectedFormalAggregate;candidate_aggregate=$ExpectedCandidateAggregate;validator_checks=$ExpectedValidatorChecks;authorized_write_set_sha256=Get-Sha256(Join-Path $WorkRoot 'authorized-write-set.csv');new_file_targets_sha256=Get-Sha256(Join-Path $WorkRoot 'new-file-targets.csv');no_write_guards_sha256=Get-Sha256(Join-Path $WorkRoot 'no-write-guards.csv')})
    }
    $postPath=Join-Path $WorkRoot 'expected-candidate-20-table-posthashes.csv'
    Write-Csv $postPath $post.ToArray()
    $summary=[ordered]@{status='passed';generated_at='2026-08-13';validator_checks=$ExpectedValidatorChecks;formal_baseline_aggregate=$ExpectedFormalAggregate;candidate_aggregate=$aggregate;write_tables=$backupList.Count;write_rows=1057;payloads=15;posthash_manifest_sha256=Get-Sha256 $postPath;formal_writes_performed=0;formal_aggregate_after=Get-Aggregate $SourceRoot $manifest}
    if($summary.formal_aggregate_after-cne$ExpectedFormalAggregate){Fail 'Formal source changed during oracle build.'}
    [IO.File]::WriteAllText((Join-Path $WorkRoot 'candidate-oracle-summary.json'),(($summary|ConvertTo-Json -Depth 5)+"`r`n"),$Utf8NoBom)
    Write-Output "PASS: bundle candidate oracle; $ExpectedValidatorChecks checks; aggregate $aggregate; formal root unchanged."
}
finally{
    if(Test-Path -LiteralPath $oracleFull){Remove-Item -LiteralPath $oracleFull -Recurse -Force}
}