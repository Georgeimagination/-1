#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总'
)
$ErrorActionPreference = 'Stop'
$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
$StagePath = Join-Path $RootPath '审计\子代理交接\m2_staging\M2-W2-AWS-PACKAGE-FACTS-REMEDIATED'
$CardDir = Join-Path $StagePath 'card-draft'
$utf8Bom = New-Object System.Text.UTF8Encoding($true)

function Read-Text([string]$Name) {
    return [System.IO.File]::ReadAllText((Join-Path $CardDir $Name),[System.Text.Encoding]::UTF8)
}
function Write-Text([string]$Name,[string]$Text) {
    [System.IO.File]::WriteAllText((Join-Path $CardDir $Name),$Text,$utf8Bom)
}
function Replace-Required([string]$Text,[string]$Old,[string]$New,[string]$Label) {
    if (-not $Text.Contains($Old)) { if ($Text.Contains($New)) { return $Text }; throw "Missing card replacement token: $Label" }
    return $Text.Replace($Old,$New)
}

foreach ($file in Get-ChildItem -LiteralPath $CardDir -Filter '*.md' -File) {
    $text = [System.IO.File]::ReadAllText($file.FullName,[System.Text.Encoding]::UTF8)
    $text = $text.Replace('当前 56 条跨对象事实集合','当前 57 条跨对象事实集合')
    [System.IO.File]::WriteAllText($file.FullName,$text,$utf8Bom)
}

$text = Read-Text 'AWS_Inferentia1_芯片实现资料卡.md'
$text = Replace-Required $text '`CMP-M2W2-AWS-INF1-NCV1 / FIELD-COMP-UNIT-COUNT` | `COND-NONE` | SRC-M2-GA-A01: 4 NeuronCore-v1 per chip | 4 count | SRC-M2-GA-A01: A01 v2.31.0 snapshot lines 1977-1987, Inferentia Architecture table | “Each Inferentia chip consists of four NeuronCore-v1 cores.”' '`CMP-M2W2-AWS-INF1-NCV1 / FIELD-COMP-UNIT-COUNT` | `COND-NONE` | SRC-M2-GA-A01: 4 NeuronCore-v1 per chip | 4 count | SRC-M2-GA-A01: A01 v2.31.0 snapshot lines 1977-1987, Inferentia Architecture table | “each with four NeuronCore-v1”' 'Inferentia1 NC count quote'
$text = Replace-Required $text '`CMP-M2W2-AWS-INF1-VECTOR / FIELD-COMP-THROUGHPUT`' '`PP-M2W2-AWS-INF1-NCV1-VECTOR-GENERIC-FLOAT / FIELD-COMP-THROUGHPUT`' 'Inferentia1 vector target'
$text = Replace-Required $text '`CMP-M2W2-AWS-INF1-SCALAR / FIELD-COMP-THROUGHPUT`' '`PP-M2W2-AWS-INF1-NCV1-SCALAR-GENERIC-FLOAT / FIELD-COMP-THROUGHPUT`' 'Inferentia1 scalar target'
Write-Text 'AWS_Inferentia1_芯片实现资料卡.md' $text

$text = Read-Text 'AWS_Trainium1_芯片实现资料卡.md'
$text = Replace-Required $text '`OBJ-AWS-TRAINIUM1-CHIP / FIELD-COMP-UNIT-COUNT`' '`CMP-M2W2-AWS-TRN1-CC / FIELD-COMP-UNIT-COUNT`' 'Trainium1 CC target'
$text = Replace-Required $text '“32 DMA engines”' '“32 DMA (Direct Memory Access) engines”' 'Trainium1 DMA quote'
Write-Text 'AWS_Trainium1_芯片实现资料卡.md' $text

$text = Read-Text 'AWS_Inferentia2_芯片实现资料卡.md'
$text = Replace-Required $text '`OBJ-AWS-INFERENTIA2-CHIP / FIELD-COMP-UNIT-COUNT`' '`CMP-M2W2-AWS-INF2-CC / FIELD-COMP-UNIT-COUNT`' 'Inferentia2 CC target'
$text = Replace-Required $text '“32GiB of high-bandwidth device memory”' '“32GiB of high-bandwidth device memor (HBM)”' 'Inferentia2 HBM quote'
$text = Replace-Required $text '“32 DMA engines”' '“32 DMA (Direct Memory Access) engines”' 'Inferentia2 DMA quote'
$text = Replace-Required $text '“2 (Inferentia2) NeuronLink-v2”' '“2 (Inferentia2) or 4 (Trainium) NeuronLink-v2”' 'Inferentia2 NeuronLink quote'
Write-Text 'AWS_Inferentia2_芯片实现资料卡.md' $text

$text = Read-Text 'AWS_Trainium3_芯片实现资料卡.md'
$text = Replace-Required $text '候选事实：26 条。' '候选事实：27 条。' 'Trainium3 candidate count'
$mxLine = ($text -split '\r?\n' | Where-Object { $_ -match '^\| .*FACT-M2W2-AWS-TRN3-CHIP-MX-PEAK' } | Select-Object -First 1)
if ([string]::IsNullOrWhiteSpace($mxLine)) { throw 'Trainium3 MX row missing.' }
$newFp8Line = '| `FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC` | `PP-M2W2-AWS-TRN3-CHIP-FP8-GENERIC / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CHIP-FP8-GENERIC` | SRC-M2-GA-A08: 2.52 FP8 PFLOPS per Trainium3 chip | 2520000000000000 FLOP/s | SRC-M2-GA-A08: A08 2025-12-02 snapshot line 2116, Trainium3 chip paragraph | “Each AWS Trainium3 chip provides 2.52 petaflops (PFLOPs) of FP8 compute” |'
$text = Replace-Required $text $mxLine ($mxLine + [Environment]::NewLine + $newFp8Line) 'Trainium3 generic FP8 row insertion'

$oldVector = ($text -split '\r?\n' | Where-Object { $_ -match '^\| .*FACT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32' } | Select-Object -First 1)
$newVector = '| `FACT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32` | `PP-M2W2-AWS-TRN3-NCV4-VECTOR-FP32 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CORE-VECTOR` | SRC-M2-GA-A07: 1.2 FP32 TFLOPS per NCv4 Vector Engine<br>SRC-M2-GA-A10: 1.2 FP32 TFLOPS per NCv4 Vector Engine | 1200000000000 FLOP/s | SRC-M2-GA-A07: A07 v2.31.0 snapshot line 2128, Vector Engine paragraph<br>SRC-M2-GA-A10: A10 v2.30.0 snapshot line 1936, Vector Engine paragraph | “The NeuronCore-v4 Vector Engine delivers a total of 1.2 TFLOPS of FP32 computations”<br>“deliver a total of 1.2 TFLOPS of FP32 computations” |'
$text = Replace-Required $text $oldVector $newVector 'Trainium3 vector corroboration row'

$oldScalar = ($text -split '\r?\n' | Where-Object { $_ -match '^\| .*FACT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32' } | Select-Object -First 1)
$newScalar = '| `FACT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32` | `PP-M2W2-AWS-TRN3-NCV4-SCALAR-FP32 / FIELD-COMP-THROUGHPUT` | `COND-M2W2-AWS-TRN3-CORE-SCALAR` | SRC-M2-GA-A07: 1.2 FP32 TFLOPS per NCv4 Scalar Engine<br>SRC-M2-GA-A10: 1.2 FP32 TFLOPS per NCv4 Scalar Engine | 1200000000000 FLOP/s | SRC-M2-GA-A07: A07 v2.31.0 snapshot line 2167, Scalar Engine paragraph<br>SRC-M2-GA-A10: A10 v2.30.0 snapshot line 1945, Scalar Engine paragraph | “The NeuronCore-v4 Scalar Engine delivers a total of 1.2 TFLOPS of FP32 computations”<br>“deliver a total of 1.2 TFLOPS of FP32 computations” |'
$text = Replace-Required $text $oldScalar $newScalar 'Trainium3 scalar corroboration row'

$text = Replace-Required $text '“Tensor ... 2.4”' '“Trainium3 Tensor 8x128 (MXFP8 dense input) or 2x128 (non-MXFP8 dense input) or 5x128 (sparse input); 1x128 (output) 2.4”' 'Trainium3 clock quote'
$text = Replace-Required $text '“128 DMA engines”' '“128 DMA (Direct Memory Access) engines”' 'Trainium3 DMA quote'

$oldA07 = ($text -split '\r?\n' | Where-Object { $_ -match '^\| .*SRC-M2-GA-A07.*在本卡直接支持' } | Select-Object -First 1)
$newA07 = '| `SRC-M2-GA-A07` | 在本卡直接支持 15 条事实：`FACT-M2W2-AWS-TRN3-NCV4-COUNT`、`FACT-M2W2-AWS-TRN3-NCV4-TENSOR-MX`、`FACT-M2W2-AWS-TRN3-NCV4-TENSOR-MIXED`、`FACT-M2W2-AWS-TRN3-NCV4-TENSOR-FP32`、`FACT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32`、`FACT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32`、`FACT-M2W2-AWS-TRN3-NCV4-TENSOR-CLOCK`、`FACT-M2W2-AWS-TRN3-SBUF-CAPACITY`、`FACT-M2W2-AWS-TRN3-PSUM-CAPACITY`、`FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GIB`、`FACT-M2W2-AWS-TRN3-HBM-BW-47`、`FACT-M2W2-AWS-TRN3-HBM-STACKS`、`FACT-M2W2-AWS-TRN3-DMA-COUNT`、`FACT-M2W2-AWS-TRN3-CC-COUNT-20`、`FACT-M2W2-AWS-TRN3-NEURONLINK-COUNT`。其中 8 条在移除 A07 后失去唯一直接证据；完整清单见 structured/selection-members.csv。 |'
$text = Replace-Required $text $oldA07 $newA07 'Trainium3 A07 minimum-set row'

$oldA08 = ($text -split '\r?\n' | Where-Object { $_ -match '^\| .*SRC-M2-GA-A08.*在本卡直接支持' } | Select-Object -First 1)
$newA08 = '| `SRC-M2-GA-A08` | 在本卡直接支持 5 条事实：`FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GB`、`FACT-M2W2-AWS-TRN3-HBM-BW-49`、`FACT-M2W2-AWS-TRN3-PROCESS`、`FACT-M2W2-AWS-TRN3-HBM-TYPE`、`FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC`。其中 4 条在移除 A08 后失去唯一直接证据；完整清单见 structured/selection-members.csv。 |'
$text = Replace-Required $text $oldA08 $newA08 'Trainium3 A08 minimum-set row'

$oldA10 = ($text -split '\r?\n' | Where-Object { $_ -match '^\| .*SRC-M2-GA-A10.*在本卡直接支持' } | Select-Object -First 1)
if ([string]::IsNullOrWhiteSpace($oldA10)) { throw 'Trainium3 A10 minimum-set row missing.' }
$a10Note = 'A10 仍为五条 Trainium3 事实提供直接断言，也继续支撑既有架构链；但 A07 已覆盖这五条事实，所以 A10 不属于本轮 package 八源最小集，来源、endpoint 和旧断言均不删除。'
$text = Replace-Required $text ($oldA10 + [Environment]::NewLine + [Environment]::NewLine + '## 九域完整度') ($a10Note + [Environment]::NewLine + [Environment]::NewLine + '## 九域完整度') 'Trainium3 A10 removal and explanation'
Write-Text 'AWS_Trainium3_芯片实现资料卡.md' $text

Write-Output 'AWS package card remediation completed.'
