#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = '.',
    [string]$IsolatedRoot = ''
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $RootPath).Path
$outDir = Join-Path $root '审计\子代理交接\field_subject_contract_remediation'
if ([string]::IsNullOrWhiteSpace($IsolatedRoot)) { $IsolatedRoot = Join-Path $outDir 'isolated-current' }
$iso = (Resolve-Path -LiteralPath $IsolatedRoot).Path
$neg = Join-Path $outDir 'negative-tests'
if (Test-Path -LiteralPath $neg) { throw "Negative test root already exists: $neg" }
[void](New-Item -ItemType Directory -Path $neg)

function Require([bool]$Condition,[string]$Message) { if(-not $Condition){throw $Message} }
function Write-CsvNoBom([object[]]$Rows,[string[]]$Headers,[string]$Path) {
    $text = (@($Rows | Select-Object -Property $Headers | ConvertTo-Csv -NoTypeInformation) -join [Environment]::NewLine) + [Environment]::NewLine
    [System.IO.File]::WriteAllText($Path,$text,[System.Text.UTF8Encoding]::new($false))
}
function Copy-Isolated([string]$Destination) {
    [void](New-Item -ItemType Directory -Path $Destination)
    Copy-Item -LiteralPath (Join-Path $iso '数据') -Destination (Join-Path $Destination '数据') -Recurse
    Copy-Item -LiteralPath (Join-Path $iso '最小参考资料库') -Destination (Join-Path $Destination '最小参考资料库') -Recurse
    [void](New-Item -ItemType Directory -Path (Join-Path $Destination 'scripts\validation') -Force)
    Copy-Item -LiteralPath (Join-Path $iso 'scripts\validation\Validate-ResearchData.ps1') -Destination (Join-Path $Destination 'scripts\validation\Validate-ResearchData.ps1')
    $eps = @(Import-Csv -LiteralPath (Join-Path $Destination '最小参考资料库\source-endpoints.csv'))
    foreach($rel in @($eps | Where-Object { -not [string]::IsNullOrWhiteSpace($_.local_path) } | Select-Object -ExpandProperty local_path -Unique)) {
        $src=$iso; foreach($part in($rel -split '/')){$src=Join-Path $src $part}
        $dst=$Destination; foreach($part in($rel -split '/')){$dst=Join-Path $dst $part}
        $dir=Split-Path -Parent $dst; if(-not(Test-Path -LiteralPath $dir)){[void](New-Item -ItemType Directory -Path $dir -Force)}
        Copy-Item -LiteralPath $src -Destination $dst
    }
}
function Invoke-Case([string]$Name,[string]$Mode,[string]$Mutation,[int]$ExpectedExit,[string]$ExpectedPattern,[scriptblock]$Mutator) {
    $caseRoot=Join-Path $neg $Name
    Copy-Isolated $caseRoot
    & $Mutator $caseRoot
    $validator=Join-Path $caseRoot 'scripts\validation\Validate-ResearchData.ps1'
    $lines=@(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $validator -RootPath $caseRoot -SubjectContractMode $Mode 2>&1 | ForEach-Object{[string]$_})
    $code=$LASTEXITCODE
    [System.IO.File]::WriteAllLines((Join-Path $outDir "negative-$Name.txt"),$lines,[System.Text.UTF8Encoding]::new($true))
    $found=($lines -join [char]10).Contains($ExpectedPattern)
    return [pscustomobject][ordered]@{test_case=$Name;mode=$Mode;mutation=$Mutation;expected_exit_code=$ExpectedExit;actual_exit_code=$code;expected_pattern=$ExpectedPattern;pattern_found=$found.ToString().ToLowerInvariant();result=if($code-eq$ExpectedExit-and$found){'passed'}else{'failed'}}
}
$mutateClockNoncanonical = {
    param($caseRoot)
    $p=Join-Path $caseRoot '数据\fields.csv';$rows=@(Import-Csv -LiteralPath $p);($rows|Where-Object field_id -eq 'FIELD-PHY-CLOCK').allowed_subject_kinds='component;object';Write-CsvNoBom $rows @($rows[0].PSObject.Properties.Name) $p
}
$mutateClockObjectOnly = {
    param($caseRoot)
    $p=Join-Path $caseRoot '数据\fields.csv';$rows=@(Import-Csv -LiteralPath $p);($rows|Where-Object field_id -eq 'FIELD-PHY-CLOCK').allowed_subject_kinds='object';Write-CsvNoBom $rows @($rows[0].PSObject.Properties.Name) $p
}
$mutateOldTrn2Path = {
    param($caseRoot)
    $p=Join-Path $caseRoot '数据\field-requirements.csv';$rows=@(Import-Csv -LiteralPath $p);$row=$rows|Where-Object requirement_id -eq 'REQ-AWS-TRN2-0175';$row.precision_path_id='PP-AWS-TRN2-TENSOR-FP8';$row.requirement_fingerprint='REQ-AWS-TRN2-0175|||||PP-AWS-TRN2-TENSOR-FP8|||FIELD-DER-COMPUTE-BW-SPEC';Write-CsvNoBom $rows @($rows[0].PSObject.Properties.Name) $p
}
$mutateWrongArchitectureRelation = {
    param($caseRoot)
    $p=Join-Path $caseRoot '数据\field-requirements.csv';$rows=@(Import-Csv -LiteralPath $p);$row=$rows|Where-Object requirement_id -eq 'REQ-CAMBRICON-MLU590-ARCH-RELATION';$row.object_relation_id='OREL-AWS-TRN2-INSTANCE-CONTAINS-TRAINIUM2';$row.requirement_fingerprint='REQ-CAMBRICON-MLU590-ARCH-RELATION||||OREL-AWS-TRN2-INSTANCE-CONTAINS-TRAINIUM2||||FIELD-ID-ARCH';Write-CsvNoBom $rows @($rows[0].PSObject.Properties.Name) $p
}
$results=@()
$results += Invoke-Case 'syntax_noncanonical_order' 'audit' 'FIELD-PHY-CLOCK.allowed_subject_kinds=component;object' 1 'Subject contract order is not canonical' $mutateClockNoncanonical
$results += Invoke-Case 'semantic_fact_kind_mismatch_audit' 'audit' 'FIELD-PHY-CLOCK.allowed_subject_kinds=object' 0 'Fact subject contract mismatch' $mutateClockObjectOnly
$results += Invoke-Case 'semantic_fact_kind_mismatch_gate' 'gate' 'FIELD-PHY-CLOCK.allowed_subject_kinds=object' 1 'Fact subject contract mismatch' $mutateClockObjectOnly
$results += Invoke-Case 'closure_same_target_missing_audit' 'audit' 'REQ-AWS-TRN2-0175 target=old NCv3 path' 0 'Requirement lacks same-target same-field fact' $mutateOldTrn2Path
$results += Invoke-Case 'closure_same_target_missing_gate' 'gate' 'REQ-AWS-TRN2-0175 target=old NCv3 path' 1 'Requirement lacks same-target same-field fact' $mutateOldTrn2Path
$results += Invoke-Case 'arch_relation_wrong_type_gate' 'gate' 'FIELD-ID-ARCH target=non-implements relation' 1 'FIELD-ID-ARCH projection requires a unique implements_architecture relation' $mutateWrongArchitectureRelation
Require (@($results|Where-Object result-ne'passed').Count -eq 0) 'One or more negative tests failed.'
Write-CsvNoBom $results @($results[0].PSObject.Properties.Name) (Join-Path $outDir 'negative-test-results.csv')
$results | Format-Table -AutoSize -Wrap
