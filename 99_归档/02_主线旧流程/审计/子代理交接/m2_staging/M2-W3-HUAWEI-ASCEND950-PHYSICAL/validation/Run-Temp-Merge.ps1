param([string]$Root='D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总')
$ErrorActionPreference='Stop'
$pkg=Join-Path $Root '审计\子代理交接\m2_staging\M2-W3-HUAWEI-ASCEND950-PHYSICAL'
$temp=Join-Path $pkg 'validation\temp-merge-root'
$pkgFull=[IO.Path]::GetFullPath($pkg).TrimEnd('\')
$tempFull=[IO.Path]::GetFullPath($temp).TrimEnd('\')
if(-not $tempFull.StartsWith($pkgFull+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Refusing temp operation outside package.'}
if(Test-Path -LiteralPath $tempFull){Remove-Item -LiteralPath $tempFull -Recurse -Force}
New-Item -ItemType Directory -Path (Join-Path $tempFull '数据') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempFull '最小参考资料库') -Force | Out-Null
$formalFiles=@()
$formalFiles+=Get-ChildItem -LiteralPath (Join-Path $Root '数据') -File -Filter '*.csv'
$formalFiles+=Get-ChildItem -LiteralPath (Join-Path $Root '最小参考资料库') -File -Filter '*.csv'
if($formalFiles.Count-ne32){throw "Expected 32 formal CSVs, found $($formalFiles.Count)."}
foreach($file in $formalFiles){
  $parent=Split-Path -Leaf (Split-Path -Parent $file.FullName)
  Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $tempFull "$parent\$($file.Name)")
}
$structured=Join-Path $pkg 'structured'
$stageFiles=Get-ChildItem -LiteralPath $structured -File -Filter '*.csv'
if($stageFiles.Count-ne24){throw "Expected 24 staging CSVs, found $($stageFiles.Count)."}
$appendSummary=[Collections.Generic.List[object]]::new()
foreach($stage in $stageFiles){
  $targetData=Join-Path $tempFull "数据\$($stage.Name)"
  $targetRef=Join-Path $tempFull "最小参考资料库\$($stage.Name)"
  $target=if(Test-Path -LiteralPath $targetData){$targetData}elseif(Test-Path -LiteralPath $targetRef){$targetRef}else{throw "No temp formal target for $($stage.Name)."}
  $formalHeader=Get-Content -LiteralPath $target -TotalCount 1 -Encoding UTF8
  $stageLines=@(Get-Content -LiteralPath $stage.FullName -Encoding UTF8)
  if($formalHeader.Trim([char]0xFEFF)-ne$stageLines[0].Trim([char]0xFEFF)){throw "Header mismatch before append: $($stage.Name)."}
  $rows=[Math]::Max(0,$stageLines.Count-1)
  if($rows-gt0){
    $existing=[IO.File]::ReadAllText($target,[Text.Encoding]::UTF8)
    if(-not $existing.EndsWith("`n")){[IO.File]::AppendAllText($target,[Environment]::NewLine,(New-Object Text.UTF8Encoding($false)))}
    $payload=($stageLines|Select-Object -Skip 1)-join[Environment]::NewLine
    [IO.File]::AppendAllText($target,$payload+[Environment]::NewLine,(New-Object Text.UTF8Encoding($false)))
  }
  $appendSummary.Add([pscustomobject]@{table=$stage.Name;rows_appended=$rows})
}
$mergedEndpoints=@(Import-Csv -LiteralPath (Join-Path $tempFull '最小参考资料库\source-endpoints.csv') | Where-Object {-not [string]::IsNullOrWhiteSpace($_.local_path)})
$linkCount=0;$copyFallbackCount=0
foreach($ep in $mergedEndpoints){
  $rel=([string]$ep.local_path).Replace('/',[IO.Path]::DirectorySeparatorChar)
  $source=[IO.Path]::GetFullPath((Join-Path $Root $rel))
  $dest=[IO.Path]::GetFullPath((Join-Path $tempFull $rel))
  if(-not $dest.StartsWith($tempFull+'\',[StringComparison]::OrdinalIgnoreCase)){throw "Endpoint destination escapes temp root: $($ep.endpoint_id)."}
  if(-not(Test-Path -LiteralPath $source -PathType Leaf)){throw "Original endpoint file missing: $source"}
  $destDir=Split-Path -Parent $dest
  if(-not(Test-Path -LiteralPath $destDir)){New-Item -ItemType Directory -Path $destDir -Force|Out-Null}
  try {New-Item -ItemType HardLink -Path $dest -Target $source -ErrorAction Stop|Out-Null;$linkCount++}
  catch {Copy-Item -LiteralPath $source -Destination $dest;$copyFallbackCount++}
}
$validator=Join-Path $Root 'scripts\validation\Validate-ResearchData.ps1'
$validationText=& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $validator -RootPath $tempFull 2>&1 | Out-String
$validatorExit=$LASTEXITCODE
$validationLog=Join-Path $pkg 'validation\temp-merge-validation.txt'
[IO.File]::WriteAllText($validationLog,$validationText,(New-Object Text.UTF8Encoding($false)))
$summary=[ordered]@{
  status=if($validatorExit-eq0){'pass'}else{'fail'}
  run_date='2026-08-13'
  formal_base='current formal 32-table library after the independently authorized AWS merge'
  rows_appended=[ordered]@{}
  endpoint_files=$mergedEndpoints.Count
  endpoint_hardlinks=$linkCount
  endpoint_copy_fallbacks=$copyFallbackCount
  validator_exit_code=$validatorExit
  validator_output=$validationText.Trim()
  temp_root_cleaned=$false
}
foreach($row in $appendSummary){$summary.rows_appended[$row.table]=$row.rows_appended}
if(-not $tempFull.StartsWith($pkgFull+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Refusing cleanup outside package.'}
Remove-Item -LiteralPath $tempFull -Recurse -Force
$summary.temp_root_cleaned= -not(Test-Path -LiteralPath $tempFull)
$summaryPath=Join-Path $pkg 'validation\temp-merge-summary.json'
[IO.File]::WriteAllText($summaryPath,($summary|ConvertTo-Json -Depth 8),(New-Object Text.UTF8Encoding($false)))
$summary|ConvertTo-Json -Depth 8
if($validatorExit-ne0){exit $validatorExit}