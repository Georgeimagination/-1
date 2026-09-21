#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourceRoot,
    [Parameter(Mandatory=$true)][string]$TargetRoot,
    [string]$WorkRoot = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总\审计\子代理交接\m2_mi350p_formal_transaction_prep'
)
Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$Utf8NoBom=New-Object Text.UTF8Encoding($false)
$ExpectedFormalAggregate='f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10'
$ExpectedCandidateAggregate='28923f7aa9dea488152f699e6879319d1fb96222fe72745754cf8ffd7b46518e'
$ExpectedValidatorChecks=111390
$ExpectedSignoffSha256='74ac69c299f5ce817c03236ef97df4e13f08f2d6724bb1c0178376661be5dad1'
$ExpectedFreezeSha256='1cb279b56f4fbfc688ed2f798646a93baed02ffbd34a647ffecf4cb6672f0e01'

function Fail([string]$Message){throw $Message}
function Get-Sha256([string]$Path){return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Get-TextSha256([string]$Text){$a=[Security.Cryptography.SHA256]::Create();try{return([BitConverter]::ToString($a.ComputeHash($Utf8NoBom.GetBytes($Text))).Replace('-','').ToLowerInvariant())}finally{$a.Dispose()}}
function Get-ChildPath([string]$Root,[string]$RelativePath,[bool]$MustExist=$true){$rootFull=[IO.Path]::GetFullPath($Root).TrimEnd('\');$full=[IO.Path]::GetFullPath((Join-Path $rootFull ($RelativePath.Replace('/','\'))));if(-not $full.StartsWith($rootFull+'\',[StringComparison]::OrdinalIgnoreCase)){Fail "Path escapes root: $RelativePath"};if($MustExist -and -not(Test-Path -LiteralPath $full -PathType Leaf)){Fail "Missing file: $full"};return $full}
function Get-CanonicalRowSha256([object]$Row){return Get-TextSha256 (@($Row|ConvertTo-Csv -NoTypeInformation)-join[char]10)}
function Get-Aggregate([string]$Root,[object[]]$Manifest){$parts=foreach($entry in($Manifest|Sort-Object relative_path)){[string]$entry.relative_path+'|'+(Get-Sha256 (Get-ChildPath $Root ([string]$entry.relative_path)))};return Get-TextSha256 ($parts-join[char]10)}
function Write-Csv([string]$Path,[object[]]$Rows){[IO.File]::WriteAllLines($Path,($Rows|ConvertTo-Csv -NoTypeInformation),$Utf8NoBom)}

$SourceRoot=(Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\')
$TargetRoot=(Resolve-Path -LiteralPath $TargetRoot).Path.TrimEnd('\')
$WorkRoot=(Resolve-Path -LiteralPath $WorkRoot).Path.TrimEnd('\')
$preflight=Join-Path $WorkRoot 'scripts\Test-MI350PFormalTransactionPreflight.ps1'
$preflightOutput=@(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $preflight -SourceRoot $SourceRoot -TargetRoot $TargetRoot -WorkRoot $WorkRoot 2>&1)
if($LASTEXITCODE-ne0){Fail ('Preflight failed: '+($preflightOutput-join' | '))}

$manifest=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'formal-32-baseline.csv') -Encoding UTF8)
$writeSet=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'authorized-write-set.csv') -Encoding UTF8)
$backupList=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'formal-csv-backup-candidates.csv') -Encoding UTF8)
$newFiles=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'new-file-targets.csv') -Encoding UTF8)
$oracleRoot=Join-Path $WorkRoot 'rehearsal\oracle-candidate'
$allowedParent=[IO.Path]::GetFullPath((Join-Path $WorkRoot 'rehearsal')).TrimEnd('\')
$oracleFull=[IO.Path]::GetFullPath($oracleRoot).TrimEnd('\')
if(-not $oracleFull.StartsWith($allowedParent+'\',[StringComparison]::OrdinalIgnoreCase)){Fail 'Oracle candidate path is outside the authorized rehearsal directory.'}
if(Test-Path -LiteralPath $oracleFull){Remove-Item -LiteralPath $oracleFull -Recurse -Force}
New-Item -ItemType Directory -Path $oracleFull|Out-Null

$sourceCache=@{}
try{
    foreach($entry in $manifest){$source=Get-ChildPath $TargetRoot ([string]$entry.relative_path);$target=Get-ChildPath $oracleFull ([string]$entry.relative_path) $false;[IO.Directory]::CreateDirectory((Split-Path -Parent $target))|Out-Null;[IO.File]::Copy($source,$target,$false)}
    foreach($group in($writeSet|Group-Object target_path|Sort-Object Name)){
        $target=Get-ChildPath $oracleFull ([string]$group.Name)
        $formalRows=@(Import-Csv -LiteralPath $target -Encoding UTF8);$header=@($formalRows[0].PSObject.Properties.Name);$append=[Collections.Generic.List[object]]::new()
        foreach($binding in($group.Group|Sort-Object signoff_row_id)){
            $source=Get-ChildPath $SourceRoot ([string]$binding.source_path)
            if((Get-Sha256 $source)-cne[string]$binding.source_sha256){Fail "Source hash differs: $($binding.signoff_row_id)"}
            if(-not $sourceCache.ContainsKey($source)){$sourceCache[$source]=@(Import-Csv -LiteralPath $source -Encoding UTF8)}
            $matches=@($sourceCache[$source]|Where-Object{[string]$_.$([string]$binding.pk_column)-ceq[string]$binding.pk_value});if($matches.Count-ne1){Fail "Source PK count differs: $($binding.signoff_row_id)"}
            $values=[ordered]@{};foreach($column in $header){$values[$column]=[string]$matches[0].$column};$row=[pscustomobject]$values
            if((Get-CanonicalRowSha256 $row)-cne[string]$binding.canonical_source_row_sha256){Fail "Canonical source row differs: $($binding.signoff_row_id)"}
            $row.review_status=[string]$binding.authorized_review_status
            if(-not[string]::IsNullOrEmpty([string]$binding.semantic_status_column)){$column=[string]$binding.semantic_status_column;if([string]$row.$column-cne[string]$binding.semantic_status_before){Fail "Semantic before-value differs: $($binding.signoff_row_id)"};$row.$column=[string]$binding.semantic_status_after}
            if((Get-CanonicalRowSha256 $row)-cne[string]$binding.canonical_authorized_row_sha256){Fail "Canonical authorized row differs: $($binding.signoff_row_id)"}
            $append.Add($row)
        }
        Write-Csv $target (@($formalRows)+@($append.ToArray()))
    }
    foreach($item in($newFiles|Sort-Object commit_order)){$source=Get-ChildPath $SourceRoot ([string]$item.source_path);$target=Get-ChildPath $oracleFull ([string]$item.target_path) $false;if(Test-Path -LiteralPath $target){Fail "Oracle payload target exists: $($item.target_path)"};[IO.Directory]::CreateDirectory((Split-Path -Parent $target))|Out-Null;[IO.File]::Copy($source,$target,$false);if((Get-Sha256 $target)-cne[string]$item.source_sha256){Fail "Oracle payload hash differs: $($item.target_path)"}}
    $endpoints=@(Import-Csv -LiteralPath (Get-ChildPath $oracleFull '最小参考资料库/source-endpoints.csv') -Encoding UTF8)
    $copied=0
    foreach($endpoint in $endpoints){$relative=[string]$endpoint.local_path;if([string]::IsNullOrWhiteSpace($relative)){continue};$destination=Get-ChildPath $oracleFull $relative $false;if(Test-Path -LiteralPath $destination -PathType Leaf){continue};$candidate=Get-ChildPath $TargetRoot $relative $false;if(-not(Test-Path -LiteralPath $candidate -PathType Leaf)){$candidate=Get-ChildPath $SourceRoot $relative $false};if(-not(Test-Path -LiteralPath $candidate -PathType Leaf)){Fail "Endpoint file is unavailable: $relative"};[IO.Directory]::CreateDirectory((Split-Path -Parent $destination))|Out-Null;[IO.File]::Copy($candidate,$destination,$false);$copied++}
    $validator=Get-ChildPath $SourceRoot 'scripts/validation/Validate-ResearchData.ps1'
    $validatorOutput=@(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $validator -RootPath $oracleFull 2>&1);$validatorCode=$LASTEXITCODE
    [IO.File]::WriteAllLines((Join-Path $WorkRoot 'logs\candidate-oracle-validator.txt'),@($validatorOutput|ForEach-Object{[string]$_}),$Utf8NoBom)
    if($validatorCode-ne0){Fail ('Oracle validator failed: '+($validatorOutput-join' | '))}
    $validatorText=$validatorOutput-join"`n";$match=[regex]::Match($validatorText,'PASS:.*?(\d+)\s+checks executed')
    if(-not $match.Success -or [int]$match.Groups[1].Value-ne$ExpectedValidatorChecks){Fail 'Oracle validator check count differs.'}
    $aggregate=Get-Aggregate $oracleFull $manifest;if([string]::IsNullOrWhiteSpace($ExpectedCandidateAggregate)){$ExpectedCandidateAggregate=$aggregate;Write-Output "DISCOVERED_CANDIDATE_AGGREGATE=$aggregate"}elseif($aggregate-cne$ExpectedCandidateAggregate){Fail "Oracle aggregate differs: $aggregate"}
    $posthash=[Collections.Generic.List[object]]::new()
    foreach($item in($backupList|Sort-Object {[int]$_.commit_order})){$target=Get-ChildPath $oracleFull ([string]$item.target_path);$posthash.Add([pscustomobject][ordered]@{target_path=[string]$item.target_path;premerge_sha256=[string]$item.premerge_sha256;candidate_postmerge_sha256=Get-Sha256 $target;candidate_bytes=(Get-Item -LiteralPath $target).Length;signoff_sha256=$ExpectedSignoffSha256;freeze_manifest_sha256=$ExpectedFreezeSha256;formal_baseline_aggregate=$ExpectedFormalAggregate;candidate_aggregate=$ExpectedCandidateAggregate;validator_checks=$ExpectedValidatorChecks;authorized_write_set_sha256=Get-Sha256 (Join-Path $WorkRoot 'authorized-write-set.csv');backup_list_sha256=Get-Sha256 (Join-Path $WorkRoot 'formal-csv-backup-candidates.csv');guard_list_sha256=Get-Sha256 (Join-Path $WorkRoot 'no-write-guards.csv');new_file_list_sha256=Get-Sha256 (Join-Path $WorkRoot 'new-file-targets.csv')})}
    $posthashPath=Join-Path $WorkRoot 'expected-candidate-19-table-posthashes.csv';Write-Csv $posthashPath $posthash.ToArray()
    $summary=[ordered]@{status='passed';generated_at='2026-08-13';preflight_checks=([regex]::Match(($preflightOutput-join"`n"),'preflight;\s+(\d+) checks').Groups[1].Value);validator_checks=$ExpectedValidatorChecks;formal_baseline_aggregate=$ExpectedFormalAggregate;candidate_aggregate=$aggregate;write_tables=$backupList.Count;write_rows=$writeSet.Count;payloads=$newFiles.Count;endpoint_files_copied=$copied;posthash_manifest_sha256=Get-Sha256 $posthashPath;formal_writes_performed=0;target_aggregate_after=Get-Aggregate $TargetRoot $manifest}
    if($summary.target_aggregate_after-cne$ExpectedFormalAggregate){Fail 'TargetRoot changed during oracle build.'}
    [IO.File]::WriteAllText((Join-Path $WorkRoot 'candidate-oracle-summary.json'),(($summary|ConvertTo-Json -Depth 6)+"`r`n"),$Utf8NoBom)
    Write-Output "PASS: MI350P candidate oracle; $ExpectedValidatorChecks checks; aggregate $aggregate; target unchanged."
}
finally{
    if(Test-Path -LiteralPath $oracleFull){Remove-Item -LiteralPath $oracleFull -Recurse -Force}
}
