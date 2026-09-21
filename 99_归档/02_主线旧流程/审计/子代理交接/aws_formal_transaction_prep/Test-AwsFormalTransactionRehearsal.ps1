#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$SourceRoot = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总',
    [string]$TransactionScript = ''
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version 2.0
$SourceRoot=(Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\')
$WorkRoot=Split-Path -Parent $MyInvocation.MyCommand.Path
if([string]::IsNullOrWhiteSpace($TransactionScript)){$TransactionScript=Join-Path $WorkRoot 'Invoke-AwsFormalTransaction.ps1'}
$TransactionScript=(Resolve-Path -LiteralPath $TransactionScript).Path
$schema=@(Import-Csv -LiteralPath (Join-Path $SourceRoot '数据\schema-columns.csv') -Encoding UTF8)
$tablePaths=@($schema.table_path|Sort-Object -Unique)
$newFileList=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'new-file-targets.csv') -Encoding UTF8)
$expectedAggregate='d10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff'
$script:Checks=0
function Assert-Check{param([bool]$Condition,[string]$Message);if(-not $Condition){throw $Message};$script:Checks++}
function Get-Sha256{param([string]$Path);(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Get-TextSha256{param([string]$Text);$enc=New-Object Text.UTF8Encoding($false);$sha=[Security.Cryptography.SHA256]::Create();try{([BitConverter]::ToString($sha.ComputeHash($enc.GetBytes($Text))).Replace('-','').ToLowerInvariant())}finally{$sha.Dispose()}}
function Get-FormalHashes{param([string]$Root);$result=foreach($relative in $tablePaths){$p=Join-Path $Root $relative.Replace('/','\');Assert-Check(Test-Path -LiteralPath $p -PathType Leaf) "Missing table: $relative";[pscustomobject]@{table_path=$relative;sha256=Get-Sha256 $p}};@($result)}
function Get-Aggregate{param([object[]]$Hashes);Get-TextSha256(@($Hashes|Sort-Object table_path|ForEach-Object{$_.table_path+'|'+$_.sha256})-join [char]10)}
function Write-Utf8NoBom{param([string]$Path,[string]$Text);[IO.File]::WriteAllText($Path,$Text,(New-Object Text.UTF8Encoding($false)))}
function New-Mirror{
 param([string]$Path)
 [IO.Directory]::CreateDirectory($Path)|Out-Null
 Write-Utf8NoBom (Join-Path $Path '.aws-formal-transaction-mirror') 'AWS-FORMAL-TRANSACTION-MIRROR-20260813'
 foreach($relative in $tablePaths){$src=Join-Path $SourceRoot $relative.Replace('/','\');$dst=Join-Path $Path $relative.Replace('/','\');[IO.Directory]::CreateDirectory((Split-Path -Parent $dst))|Out-Null;[IO.File]::Copy($src,$dst,$false)}
 Copy-Item -LiteralPath (Join-Path $SourceRoot '资料卡') -Destination (Join-Path $Path '资料卡') -Recurse
 $snapTarget=Join-Path $Path '最小参考资料库\快照';[IO.Directory]::CreateDirectory($snapTarget)|Out-Null
 foreach($vendor in @('AMD','Google','NVIDIA','寒武纪')){$src=Join-Path $SourceRoot ('最小参考资料库\快照\'+$vendor);if(Test-Path -LiteralPath $src -PathType Container){Copy-Item -LiteralPath $src -Destination (Join-Path $snapTarget $vendor) -Recurse}}
 $awsTarget=Join-Path $snapTarget 'AWS';[IO.Directory]::CreateDirectory($awsTarget)|Out-Null
 Copy-Item -LiteralPath (Join-Path $SourceRoot '最小参考资料库\快照\AWS\Trainium2') -Destination (Join-Path $awsTarget 'Trainium2') -Recurse
}
function Assert-Restored{
 param([string]$Root,[object[]]$Before)
 $after=Get-FormalHashes $Root
 foreach($item in $Before){$m=@($after|Where-Object table_path -ceq $item.table_path);Assert-Check($m.Count -eq 1 -and $m[0].sha256 -ceq $item.sha256) "Rollback hash differs: $($item.table_path)"}
 Assert-Check((Get-Aggregate $after)-ceq $expectedAggregate)'Rollback aggregate differs.'
 foreach($item in $newFileList){Assert-Check(-not(Test-Path -LiteralPath (Join-Path $Root $item.target_path.Replace('/','\')))) "Rollback left payload: $($item.target_path)"}
 $temps=@(Get-ChildItem -LiteralPath $Root -Recurse -File|Where-Object{$_.Name -like '*.aws-formal-transaction-new' -or $_.Name -like '*.aws-formal-transaction-restore'})
 Assert-Check($temps.Count -eq 0)'Rollback left replacement or restore temporary files.'
}
Assert-Check($tablePaths.Count -eq 32)'Formal path count differs.'
Assert-Check($newFileList.Count -eq 15)'Payload list count differs.'
$formalBefore=Get-FormalHashes $SourceRoot
Assert-Check((Get-Aggregate $formalBefore)-ceq $expectedAggregate)'Formal aggregate differs before rehearsal.'
foreach($item in $newFileList){Assert-Check(-not(Test-Path -LiteralPath (Join-Path $SourceRoot $item.target_path.Replace('/','\')))) "Formal payload exists: $($item.target_path)"}
$runRoot=Join-Path $WorkRoot ('.tmp-aws-transaction-rehearsal-'+[guid]::NewGuid().ToString('N'))
$mirror=Join-Path $runRoot 'mirror'
$tableResult=Join-Path $runRoot 'result-table-failure'
$payloadResult=Join-Path $runRoot 'result-payload-failure'
$positiveResultRoot=Join-Path $runRoot 'result-positive'
$results=[Collections.Generic.List[object]]::new()
try{
 New-Mirror $mirror
 $mirrorBefore=Get-FormalHashes $mirror
 $savedPreference=$ErrorActionPreference
 $ErrorActionPreference='Continue'
 $env:AWS_FORMAL_TRANSACTION_TEST_FAIL_AFTER_REPLACEMENTS='3'
 try{$out=@(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $TransactionScript -SourceRoot $SourceRoot -TargetRoot $mirror -ResultRoot $tableResult 2>&1);$exit=$LASTEXITCODE}finally{Remove-Item Env:AWS_FORMAL_TRANSACTION_TEST_FAIL_AFTER_REPLACEMENTS -ErrorAction SilentlyContinue}
 Assert-Check($exit -ne 0)'Table fault unexpectedly succeeded.'
 Assert-Check(($out-join [char]10)-match 'ROLLBACK SUCCEEDED')'Table rollback message missing.'
 Assert-Check(($out-join [char]10)-match 'INJECTED_TEST_FAILURE_AFTER_3_REPLACEMENTS')'Table fault marker missing.'
 $ErrorActionPreference=$savedPreference
 Assert-Restored $mirror $mirrorBefore
 $results.Add([pscustomobject]@{scenario='failure_after_3_table_replacements';exit_code=$exit;rollback='passed';formal_result='unchanged'})
 $savedPreference=$ErrorActionPreference
 $ErrorActionPreference='Continue'
 $env:AWS_FORMAL_TRANSACTION_TEST_FAIL_AFTER_PAYLOADS='4'
 try{$out=@(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $TransactionScript -SourceRoot $SourceRoot -TargetRoot $mirror -ResultRoot $payloadResult 2>&1);$exit=$LASTEXITCODE}finally{Remove-Item Env:AWS_FORMAL_TRANSACTION_TEST_FAIL_AFTER_PAYLOADS -ErrorAction SilentlyContinue}
 Assert-Check($exit -ne 0)'Payload fault unexpectedly succeeded.'
 Assert-Check(($out-join [char]10)-match 'ROLLBACK SUCCEEDED')'Payload rollback message missing.'
 Assert-Check(($out-join [char]10)-match 'INJECTED_TEST_FAILURE_AFTER_4_PAYLOADS')'Payload fault marker missing.'
 $ErrorActionPreference=$savedPreference
 Assert-Restored $mirror $mirrorBefore
 $results.Add([pscustomobject]@{scenario='failure_after_20_tables_and_4_payloads';exit_code=$exit;rollback='passed';formal_result='unchanged'})
 $out=@(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $TransactionScript -SourceRoot $SourceRoot -TargetRoot $mirror -ResultRoot $positiveResultRoot 2>&1);$exit=$LASTEXITCODE
 Assert-Check($exit -eq 0) "Positive transaction failed: $($out -join ' | ')"
 $json=@($out|Where-Object{[string]$_ -match '^\{"status":"PASS"'}|Select-Object -Last 1)
 Assert-Check($json.Count -eq 1)'Positive PASS JSON missing.'
 $r=$json[0]|ConvertFrom-Json
 Assert-Check([int]$r.authorized_writes -eq 477 -and [int]$r.no_write_guards -eq 9)'Positive write or guard counts differ.'
 Assert-Check([int]$r.csv_tables_replaced -eq 20 -and [int]$r.files_created -eq 15)'Positive table or payload counts differ.'
 Assert-Check([int]$r.candidate_validator_checks -eq 106160 -and [int]$r.post_commit_validator_checks -eq 106160)'Positive validator checks differ.'
 foreach($item in $newFileList){Assert-Check((Get-Sha256 (Join-Path $mirror $item.target_path.Replace('/','\')))-ceq $item.expected_output_sha256) "Positive payload hash differs: $($item.target_path)"}
 $temps=@(Get-ChildItem -LiteralPath $mirror -Recurse -File|Where-Object{$_.Name -like '*.aws-formal-transaction-new' -or $_.Name -like '*.aws-formal-transaction-restore'})
 Assert-Check($temps.Count -eq 0)'Positive transaction left temporary files.'
 $results.Add([pscustomobject]@{scenario='positive_mirror';exit_code=$exit;rollback='not_used';formal_result='unchanged'})
}
finally{
 Remove-Item Env:AWS_FORMAL_TRANSACTION_TEST_FAIL_AFTER_REPLACEMENTS -ErrorAction SilentlyContinue
 Remove-Item Env:AWS_FORMAL_TRANSACTION_TEST_FAIL_AFTER_PAYLOADS -ErrorAction SilentlyContinue
 if(Test-Path -LiteralPath $runRoot){Remove-Item -LiteralPath $runRoot -Recurse -Force}
}
Assert-Check(-not(Test-Path -LiteralPath $runRoot))'Rehearsal temp root remains.'
$formalAfter=Get-FormalHashes $SourceRoot
foreach($item in $formalBefore){$m=@($formalAfter|Where-Object table_path -ceq $item.table_path);Assert-Check($m[0].sha256 -ceq $item.sha256) "Formal table changed: $($item.table_path)"}
Assert-Check((Get-Aggregate $formalAfter)-ceq $expectedAggregate)'Formal aggregate changed.'
foreach($item in $newFileList){Assert-Check(-not(Test-Path -LiteralPath (Join-Path $SourceRoot $item.target_path.Replace('/','\')))) "Formal payload appeared: $($item.target_path)"}
Write-Utf8NoBom (Join-Path $WorkRoot 'rehearsal-scenarios.csv') ((@($results|ConvertTo-Csv -NoTypeInformation)-join ([char]13+[char]10))+[char]13+[char]10)
$summary=[pscustomobject][ordered]@{status='PASS';checks=$script:Checks;scenarios=3;positive_authorized_writes=477;positive_no_write_guards=9;positive_validator_checks=106160;rollback_table_failure='passed';rollback_payload_failure='passed';formal_tables_unchanged=32;formal_payload_targets_created=0;temporary_root_removed=$true}
Write-Utf8NoBom (Join-Path $WorkRoot 'rehearsal-summary.json') (($summary|ConvertTo-Json)+[char]13+[char]10)
$summary|ConvertTo-Json -Compress
