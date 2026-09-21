#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总'
)
$ErrorActionPreference = 'Stop'
$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
$StagePath = Join-Path $RootPath '审计\子代理交接\m2_staging\M2-W2-AWS-PACKAGE-FACTS-REMEDIATED'
$utf8Bom = New-Object System.Text.UTF8Encoding($true)

function Import-Rows([string]$RelativePath) {
    return @(Import-Csv -LiteralPath (Join-Path $StagePath $RelativePath) -Encoding UTF8)
}
function Export-Rows([string]$RelativePath,[object[]]$Rows) {
    @($Rows) | Export-Csv -LiteralPath (Join-Path $StagePath $RelativePath) -NoTypeInformation -Encoding UTF8
}
function Get-One([object[]]$Rows,[string]$Column,[string]$Value) {
    $matches = @($Rows | Where-Object { $_.$Column -eq $Value })
    if ($matches.Count -ne 1) { throw "Expected one row for $Column=$Value, found $($matches.Count)." }
    return $matches[0]
}
function Add-Unique([object[]]$Rows,[string]$Column,[pscustomobject]$Row) {
    if (@($Rows | Where-Object { $_.$Column -eq $Row.$Column }).Count -gt 0) { throw "Duplicate candidate $Column=$($Row.$Column)." }
    return @($Rows + $Row)
}
function Write-Text([string]$RelativePath,[string]$Text) {
    [System.IO.File]::WriteAllText((Join-Path $StagePath $RelativePath),$Text,$utf8Bom)
}

# B01: only A01 and A07 have an independently checked latest/versioned equivalence pair.
$sourceUpdates = Import-Rows 'audit\source-updates.csv'
foreach ($sid in @('SRC-M2-GA-A02','SRC-M2-GA-A03','SRC-M2-GA-A04','SRC-M2-GA-A05','SRC-M2-GA-A06','SRC-M2-GA-A08','SRC-M2-GA-A10')) {
    $row = Get-One $sourceUpdates 'source_id' $sid
    $row.notes = '2026-08-13 已取得单一固定 web_snapshot；证据按 source_id 计数，不因 endpoint 数增加独立证据。'
}
Export-Rows 'audit\source-updates.csv' $sourceUpdates

# B08: retain the already reviewed lifecycle state while changing screening semantics.
$screening = Import-Rows 'audit\source-screening-updates.csv'
$screenA01 = Get-One $screening 'screening_id' 'SCREEN-M2-GA-A01'
$screenA01.review_status = 'reviewed'
$screenA01.notes = 'update_existing 候选：筛选语义从 redundant_covered 改为 selected，生命周期保持 reviewed，不发生降级。'
Export-Rows 'audit\source-screening-updates.csv' $screening

# B05 and B03: add the two missing legal throughput paths, two CC-Core components,
# and one chip-aggregate component for the separately labelled generic FP8 fact.
$components = Import-Rows 'structured\components.csv'
$components = Add-Unique $components 'component_id' ([pscustomobject][ordered]@{
    component_id='CMP-M2W2-AWS-TRN1-CC'
    owner_object_id='OBJ-AWS-TRAINIUM1-CHIP'
    parent_component_id=''
    component_domain='special_function'
    component_type='network_offload'
    canonical_label='Trainium CC-Cores'
    review_status='draft'
    notes='单芯片集合通信组件；只承载 A05 给出的 6 个 CC-Core 数量，不复制架构机制。'
})
$components = Add-Unique $components 'component_id' ([pscustomobject][ordered]@{
    component_id='CMP-M2W2-AWS-INF2-CC'
    owner_object_id='OBJ-AWS-INFERENTIA2-CHIP'
    parent_component_id=''
    component_domain='special_function'
    component_type='network_offload'
    canonical_label='Inferentia2 CC-Cores'
    review_status='draft'
    notes='单芯片集合通信组件；只承载 A05 给出的 6 个 CC-Core 数量，不复制架构机制。'
})
$components = Add-Unique $components 'component_id' ([pscustomobject][ordered]@{
    component_id='CMP-M2W2-AWS-TRN3-CHIP-COMPUTE'
    owner_object_id='OBJ-AWS-TRAINIUM3-CHIP'
    parent_component_id=''
    component_domain='compute'
    component_type='other_fixed_function'
    canonical_label='Trainium3 chip aggregate compute view'
    review_status='draft'
    notes='芯片级聚合规格视图，不表示新增物理执行单元；用于保留 A08 的通用 FP8 厂商标签。'
})
Export-Rows 'structured\components.csv' $components

$paths = Import-Rows 'structured\precision-paths.csv'
$paths = Add-Unique $paths 'precision_path_id' ([pscustomobject][ordered]@{
    precision_path_id='PP-M2W2-AWS-INF1-NCV1-VECTOR-GENERIC-FLOAT'
    component_id='CMP-M2W2-AWS-INF1-VECTOR'
    canonical_label='NCv1 Vector Engine generic floating-point operations per cycle'
    operation_class='vector'
    review_status='draft'
    notes='A02 未给具体浮点格式；该 precision path 只固定原文的 generic floating-point 边界。'
})
$paths = Add-Unique $paths 'precision_path_id' ([pscustomobject][ordered]@{
    precision_path_id='PP-M2W2-AWS-INF1-NCV1-SCALAR-GENERIC-FLOAT'
    component_id='CMP-M2W2-AWS-INF1-SCALAR'
    canonical_label='NCv1 Scalar Engine generic floating-point operations per cycle'
    operation_class='scalar'
    review_status='draft'
    notes='A02 未给具体浮点格式；该 precision path 只固定原文的 generic floating-point 边界。'
})
$paths = Add-Unique $paths 'precision_path_id' ([pscustomobject][ordered]@{
    precision_path_id='PP-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    component_id='CMP-M2W2-AWS-TRN3-CHIP-COMPUTE'
    canonical_label='Trainium3 chip aggregate generic FP8 compute path'
    operation_class='other'
    review_status='draft'
    notes='A08 只标为 FP8；与 A06 的 MXFP8/MXFP4 标签及显示精度分别保留，不静默合并。'
})
Export-Rows 'structured\precision-paths.csv' $paths

$conditions = Import-Rows 'structured\condition-sets.csv'
(Get-One $conditions 'condition_set_id' 'COND-M2W2-AWS-INF1-CORE-VECTOR').precision_path_id = 'PP-M2W2-AWS-INF1-NCV1-VECTOR-GENERIC-FLOAT'
(Get-One $conditions 'condition_set_id' 'COND-M2W2-AWS-INF1-CORE-SCALAR').precision_path_id = 'PP-M2W2-AWS-INF1-NCV1-SCALAR-GENERIC-FLOAT'
$conditions = Add-Unique $conditions 'condition_set_id' ([pscustomobject][ordered]@{
    condition_set_id='COND-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    condition_fingerprint='CFP-COND-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    precision_path_id='PP-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    sparsity_mode='not_specified'
    sparsity_pattern=''
    operation_type=''
    operation_count_rule='not_specified'
    performance_basis='vendor_label_unresolved'
    support_level='hardware_peak_published'
    power_mode=''
    frequency_value=''
    frequency_unit=''
    software_version='AWS announcement 2025-12-02'
    workload_stage=''
    bandwidth_direction=''
    aggregation_scope=''
    traffic_basis=''
    measurement_scope='per_object'
    effective_date='2025-12-02'
    review_status='draft'
    notes='A08 给出单颗 Trainium3 芯片的通用 FP8 厂商定值；未说明运算类型、稠密/稀疏、是否理论峰值或运算计数规则。'
})
Export-Rows 'structured\condition-sets.csv' $conditions

$facts = Import-Rows 'structured\facts.csv'
$f = Get-One $facts 'fact_id' 'FACT-M2W2-AWS-INF1-NCV1-VECTOR-OPS-CYCLE'
$f.component_id = ''
$f.precision_path_id = 'PP-M2W2-AWS-INF1-NCV1-VECTOR-GENERIC-FLOAT'
$f.fact_fingerprint = 'M2W2-AWS-PKG|precision_path_id|PP-M2W2-AWS-INF1-NCV1-VECTOR-GENERIC-FLOAT|FIELD-COMP-THROUGHPUT|256|OP/cycle|COND-M2W2-AWS-INF1-CORE-VECTOR'
$f.notes = '通用浮点 operations/cycle；A02 未给具体精度，不据此派生 FLOP/s。'
$f = Get-One $facts 'fact_id' 'FACT-M2W2-AWS-INF1-NCV1-SCALAR-OPS-CYCLE'
$f.component_id = ''
$f.precision_path_id = 'PP-M2W2-AWS-INF1-NCV1-SCALAR-GENERIC-FLOAT'
$f.fact_fingerprint = 'M2W2-AWS-PKG|precision_path_id|PP-M2W2-AWS-INF1-NCV1-SCALAR-GENERIC-FLOAT|FIELD-COMP-THROUGHPUT|512|OP/cycle|COND-M2W2-AWS-INF1-CORE-SCALAR'
$f.notes = '通用浮点 operations/cycle；A02 未给具体精度，不据此派生 FLOP/s。'
$f = Get-One $facts 'fact_id' 'FACT-M2W2-AWS-TRN1-CC-COUNT'
$f.object_id = ''
$f.component_id = 'CMP-M2W2-AWS-TRN1-CC'
$f.fact_fingerprint = 'M2W2-AWS-PKG|component_id|CMP-M2W2-AWS-TRN1-CC|FIELD-COMP-UNIT-COUNT|6|count|COND-NONE'
$f.notes = '单颗 Trainium 芯片的 CC-Core 数量。'
$f = Get-One $facts 'fact_id' 'FACT-M2W2-AWS-INF2-CC-COUNT'
$f.object_id = ''
$f.component_id = 'CMP-M2W2-AWS-INF2-CC'
$f.fact_fingerprint = 'M2W2-AWS-PKG|component_id|CMP-M2W2-AWS-INF2-CC|FIELD-COMP-UNIT-COUNT|6|count|COND-NONE'
$f.notes = '单颗 Inferentia2 芯片的 CC-Core 数量。'
(Get-One $facts 'fact_id' 'FACT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32').evidence_state = 'corroborated'
(Get-One $facts 'fact_id' 'FACT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32').evidence_state = 'corroborated'
$facts = Add-Unique $facts 'fact_id' ([pscustomobject][ordered]@{
    fact_id='FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    object_id=''
    component_id=''
    link_id=''
    object_relation_id=''
    precision_path_id='PP-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    capability_id=''
    topology_id=''
    field_id='FIELD-COMP-THROUGHPUT'
    normalized_value_text=''
    normalized_value_number='2520000000000000'
    normalized_unit='FLOP/s'
    condition_set_id='COND-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    fact_kind='direct_statement'
    evidence_state='single_source'
    resolution_state='provisional'
    valid_from='2025-12-02'
    valid_to=''
    confidence='high'
    confidence_reason='A08 固定 AWS 一手正文直接以单颗 Trainium3 芯片为主语给出 2.52 PFLOPS 的 FP8 compute。'
    fact_fingerprint='M2W2-AWS-PKG|precision_path_id|PP-M2W2-AWS-TRN3-CHIP-FP8-GENERIC|FIELD-COMP-THROUGHPUT|2520000000000000|FLOP/s|COND-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    review_status='draft'
    notes='保留 A08 的 generic FP8 标签和 2.52 显示精度；不与 A06 的 2,517 MXFP8/MXFP4 TFLOPS 合并。'
})
Export-Rows 'structured\facts.csv' $facts

$requirements = Import-Rows 'structured\field-requirements.csv'
$r = Get-One $requirements 'requirement_id' 'REQ-M2W2-AWS-PKG-007'
$r.component_id = ''
$r.precision_path_id = 'PP-M2W2-AWS-INF1-NCV1-VECTOR-GENERIC-FLOAT'
$r.requirement_fingerprint = 'REQ-M2W2-AWS-PKG-007|||||PP-M2W2-AWS-INF1-NCV1-VECTOR-GENERIC-FLOAT|||FIELD-COMP-THROUGHPUT'
$r.notes = 'FIELD-COMP-THROUGHPUT 按字段合同落在 precision_path；A02 未给具体精度。'
$r = Get-One $requirements 'requirement_id' 'REQ-M2W2-AWS-PKG-008'
$r.component_id = ''
$r.precision_path_id = 'PP-M2W2-AWS-INF1-NCV1-SCALAR-GENERIC-FLOAT'
$r.requirement_fingerprint = 'REQ-M2W2-AWS-PKG-008|||||PP-M2W2-AWS-INF1-NCV1-SCALAR-GENERIC-FLOAT|||FIELD-COMP-THROUGHPUT'
$r.notes = 'FIELD-COMP-THROUGHPUT 按字段合同落在 precision_path；A02 未给具体精度。'
$r = Get-One $requirements 'requirement_id' 'REQ-M2W2-AWS-PKG-017'
$r.object_id = ''
$r.component_id = 'CMP-M2W2-AWS-TRN1-CC'
$r.requirement_fingerprint = 'REQ-M2W2-AWS-PKG-017||CMP-M2W2-AWS-TRN1-CC||||||FIELD-COMP-UNIT-COUNT'
$r.notes = 'FIELD-COMP-UNIT-COUNT 按字段合同落在 CC-Core component。'
$r = Get-One $requirements 'requirement_id' 'REQ-M2W2-AWS-PKG-027'
$r.object_id = ''
$r.component_id = 'CMP-M2W2-AWS-INF2-CC'
$r.requirement_fingerprint = 'REQ-M2W2-AWS-PKG-027||CMP-M2W2-AWS-INF2-CC||||||FIELD-COMP-UNIT-COUNT'
$r.notes = 'FIELD-COMP-UNIT-COUNT 按字段合同落在 CC-Core component。'
$r = Get-One $requirements 'requirement_id' 'REQ-M2W2-AWS-PKG-038'
$r.notes = 'Tensor Engine 时钟必须保留 component 主体；依赖 audit/field-contract-change-candidate.csv 中 FIELD-PHY-CLOCK 的最小全局合同候选，未改正式 fields.csv。'
$requirements = Add-Unique $requirements 'requirement_id' ([pscustomobject][ordered]@{
    requirement_id='REQ-M2W2-AWS-PKG-071'
    object_id=''
    component_id=''
    link_id=''
    object_relation_id=''
    precision_path_id='PP-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    capability_id=''
    topology_id=''
    field_id='FIELD-COMP-THROUGHPUT'
    requirement_status='value_available'
    applicability_reason='A08 固定 AWS 一手正文给出单颗 Trainium3 芯片的 2.52 PFLOPS generic FP8 定值。'
    search_status='completed'
    last_searched_date='2026-08-13'
    requirement_fingerprint='REQ-M2W2-AWS-PKG-071|||||PP-M2W2-AWS-TRN3-CHIP-FP8-GENERIC|||FIELD-COMP-THROUGHPUT'
    review_status='draft'
    notes='与 A06 的 MXFP8/MXFP4 path 分开建模，保留精度标签和显示精度差异。'
})
Export-Rows 'structured\field-requirements.csv' $requirements

# B02, B03 and B04: repair assertions, add A07 corroboration and the A08 generic FP8 assertion.
$assertions = Import-Rows 'structured\fact-assertions.csv'
(Get-One $assertions 'assertion_id' 'ASRT-M2W2-AWS-INF1-NCV1-COUNT-A01-1').quoted_context = 'each with four NeuronCore-v1'
(Get-One $assertions 'assertion_id' 'ASRT-M2W2-AWS-TRN1-DMA-COUNT-A05-1').quoted_context = '32 DMA (Direct Memory Access) engines'
(Get-One $assertions 'assertion_id' 'ASRT-M2W2-AWS-INF2-HBM-CAPACITY-A04-1').quoted_context = '32GiB of high-bandwidth device memor (HBM)'
(Get-One $assertions 'assertion_id' 'ASRT-M2W2-AWS-INF2-DMA-COUNT-A05-1').quoted_context = '32 DMA (Direct Memory Access) engines'
(Get-One $assertions 'assertion_id' 'ASRT-M2W2-AWS-INF2-NEURONLINK-COUNT-A05-1').quoted_context = '2 (Inferentia2) or 4 (Trainium) NeuronLink-v2'
(Get-One $assertions 'assertion_id' 'ASRT-M2W2-AWS-TRN3-NCV4-TENSOR-CLOCK-A07-1').quoted_context = 'Trainium3 Tensor 8x128 (MXFP8 dense input) or 2x128 (non-MXFP8 dense input) or 5x128 (sparse input); 1x128 (output) 2.4'
(Get-One $assertions 'assertion_id' 'ASRT-M2W2-AWS-TRN3-DMA-COUNT-A07-1').quoted_context = '128 DMA (Direct Memory Access) engines'
$a = Get-One $assertions 'assertion_id' 'ASRT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32-A10-1'
$a.notes = 'A07 v2.31.0 也直接给出相同的 1.2 TFLOPS，故本事实由两个 source_id 交叉支持；A10 不再是 package 最小集成员。'
$a = Get-One $assertions 'assertion_id' 'ASRT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32-A10-1'
$a.notes = 'A07 v2.31.0 也直接给出相同的 1.2 TFLOPS，故本事实由两个 source_id 交叉支持；A10 不再是 package 最小集成员。'
$assertions = Add-Unique $assertions 'assertion_id' ([pscustomobject][ordered]@{
    assertion_id='ASRT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32-A07-1'
    fact_id='FACT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32'
    source_id='SRC-M2-GA-A07'
    claim_role='core_spec'
    assertion_mode='direct_statement'
    assertion_relation='supports'
    raw_value_text=''
    raw_value_number='1.2'
    raw_unit='FP32 TFLOPS per NCv4 Vector Engine'
    source_locator='A07 v2.31.0 snapshot line 2128, Vector Engine paragraph'
    quoted_context='The NeuronCore-v4 Vector Engine delivers a total of 1.2 TFLOPS of FP32 computations'
    extraction_status='source_checked'
    extractor='m2_w2_aws_package_facts_remediation'
    reviewer=''
    review_date='2026-08-13'
    assertion_fingerprint='M2W2-AWS-PKG|FACT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32|SRC-M2-GA-A07|A07 v2.31.0 snapshot line 2128, Vector Engine paragraph'
    review_status='draft'
    notes='与 A10 为不同 source_id 的独立直接断言。'
})
$assertions = Add-Unique $assertions 'assertion_id' ([pscustomobject][ordered]@{
    assertion_id='ASRT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32-A07-1'
    fact_id='FACT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32'
    source_id='SRC-M2-GA-A07'
    claim_role='core_spec'
    assertion_mode='direct_statement'
    assertion_relation='supports'
    raw_value_text=''
    raw_value_number='1.2'
    raw_unit='FP32 TFLOPS per NCv4 Scalar Engine'
    source_locator='A07 v2.31.0 snapshot line 2167, Scalar Engine paragraph'
    quoted_context='The NeuronCore-v4 Scalar Engine delivers a total of 1.2 TFLOPS of FP32 computations'
    extraction_status='source_checked'
    extractor='m2_w2_aws_package_facts_remediation'
    reviewer=''
    review_date='2026-08-13'
    assertion_fingerprint='M2W2-AWS-PKG|FACT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32|SRC-M2-GA-A07|A07 v2.31.0 snapshot line 2167, Scalar Engine paragraph'
    review_status='draft'
    notes='与 A10 为不同 source_id 的独立直接断言。'
})
$assertions = Add-Unique $assertions 'assertion_id' ([pscustomobject][ordered]@{
    assertion_id='ASRT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC-A08-1'
    fact_id='FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    source_id='SRC-M2-GA-A08'
    claim_role='core_spec'
    assertion_mode='direct_statement'
    assertion_relation='supports'
    raw_value_text=''
    raw_value_number='2.52'
    raw_unit='FP8 PFLOPS per Trainium3 chip'
    source_locator='A08 2025-12-02 snapshot line 2116, Trainium3 chip paragraph'
    quoted_context='Each AWS Trainium3 chip provides 2.52 petaflops (PFLOPs) of FP8 compute'
    extraction_status='source_checked'
    extractor='m2_w2_aws_package_facts_remediation'
    reviewer=''
    review_date='2026-08-13'
    assertion_fingerprint='M2W2-AWS-PKG|FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC|SRC-M2-GA-A08|A08 2025-12-02 snapshot line 2116, Trainium3 chip paragraph'
    review_status='draft'
    notes='通用 FP8 标签与 A06 的 MXFP8/MXFP4 标签分开；2.52 与 2,517 的显示精度不静默归一。'
})
Export-Rows 'structured\fact-assertions.csv' $assertions

# Add one-to-one requirement and card coverage for the new fact.
$factMap = Import-Rows 'audit\fact-requirement-map.csv'
$factMap = Add-Unique $factMap 'fact_id' ([pscustomobject][ordered]@{
    requirement_id='REQ-M2W2-AWS-PKG-071'
    fact_id='FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    mapping_status='mapped'
    notes='A08 generic FP8 独立事实。'
})
Export-Rows 'audit\fact-requirement-map.csv' $factMap

$cardCoverage = Import-Rows 'audit\card-fact-coverage.csv'
$cardCoverage = Add-Unique $cardCoverage 'fact_id' ([pscustomobject][ordered]@{
    card_path='card-draft/AWS_Trainium3_芯片实现资料卡.md'
    object_id='OBJ-AWS-TRAINIUM3-CHIP'
    fact_id='FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
    section='实现事实候选'
    fact_present='true'
    reverse_locator='Markdown row containing FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
})
Export-Rows 'audit\card-fact-coverage.csv' $cardCoverage

# B02 and B07: rerun the exact current fact-set reverse removal; A10 is retained as a source but not selected.
$members = Import-Rows 'structured\selection-members.csv'
$members = @($members | Where-Object source_id -ne 'SRC-M2-GA-A10')
foreach ($memberRow in $members) { $memberRow.notes = $memberRow.notes.Replace('当前 56 条事实集合','当前 57 条事实集合') }
$m = Get-One $members 'source_id' 'SRC-M2-GA-A07'
$m.mandatory_reason = '移除此来源会使 8 条候选事实失去唯一直接证据：FACT-M2W2-AWS-TRN3-NCV4-TENSOR-CLOCK、FACT-M2W2-AWS-TRN3-SBUF-CAPACITY、FACT-M2W2-AWS-TRN3-PSUM-CAPACITY、FACT-M2W2-AWS-TRN3-HBM-BW-47、FACT-M2W2-AWS-TRN3-HBM-STACKS、FACT-M2W2-AWS-TRN3-DMA-COUNT、FACT-M2W2-AWS-TRN3-CC-COUNT-20、FACT-M2W2-AWS-TRN3-NEURONLINK-COUNT。'
$m.notes = '该来源共支持 15 条本轮事实；反向移除结论针对当前 57 条事实集合。'
$m = Get-One $members 'source_id' 'SRC-M2-GA-A08'
$m.mandatory_reason = '移除此来源会使 4 条候选事实失去唯一直接证据：FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GB、FACT-M2W2-AWS-TRN3-PROCESS、FACT-M2W2-AWS-TRN3-HBM-TYPE、FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC。'
$m.notes = '该来源共支持 5 条本轮事实；反向移除结论针对当前 57 条事实集合。'
Export-Rows 'structured\selection-members.csv' $members

$roles = Import-Rows 'structured\source-selected-roles.csv'
$roles = @($roles | Where-Object source_selected_role_id -ne 'SROLE-M2W2-AWS-PKG-A10-CORE')
Export-Rows 'structured\source-selected-roles.csv' $roles

$runs = Import-Rows 'structured\selection-runs.csv'
$run = Get-One $runs 'selection_run_id' 'SELRUN-M2W2-AWS-PKG-20260813'
$run.notes = '按 57 条 package 实现候选及五组冲突执行逐来源反向移除。八个 source_id 各有不可替代事实；A10 的五条 package 事实均由 A07 覆盖，故不入本轮最小集。A01/A07 的 latest 与 v2.31.0 入口正文相同，各只计一个来源。等待独立复核。'
Export-Rows 'structured\selection-runs.csv' $runs

$reverse = Import-Rows 'audit\reverse-removal.csv'
$rr = Get-One $reverse 'source_id' 'SRC-M2-GA-A07'
$rr.supported_fact_count = '15'
$rr.unique_fact_count = '8'
$rr.rationale = '移除后 8 条当前事实失去唯一直接证据；A07 另与 A10 共同支持 5 条事实，故保留。'
$rr = Get-One $reverse 'source_id' 'SRC-M2-GA-A08'
$rr.supported_fact_count = '5'
$rr.unique_fact_count = '4'
$rr.lost_fact_ids = 'FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GB|FACT-M2W2-AWS-TRN3-PROCESS|FACT-M2W2-AWS-TRN3-HBM-TYPE|FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
$rr.rationale = '移除后 4 条当前事实失去唯一直接证据，其中包括 A08 独有的 generic FP8 定值，故保留。'
$rr = Get-One $reverse 'source_id' 'SRC-M2-GA-A09'
$rr.rationale = '当前四个 package 对象不含 Trainium4；A09 只支撑 Trainium4 路线图及 6×、4×、2× 相对声明，故本包排除。既有架构 selection run 不删除。'
$rr = Get-One $reverse 'source_id' 'SRC-M2-GA-A10'
$rr.reverse_removal_result = 'no_fact_loss'
$rr.supported_fact_count = '5'
$rr.unique_fact_count = '0'
$rr.lost_fact_ids = ''
$rr.decision = 'excluded'
$rr.rationale = 'A10 的 5 条当前 package 事实均有 A07 直接断言；移除 A10 不造成事实损失，因此不进入本轮八源最小集。来源与既有架构断言均保留。'
Export-Rows 'audit\reverse-removal.csv' $reverse

$coverage = @([pscustomobject][ordered]@{
    coverage_id='COV-M2W2-AWS-PKG-A10-BY-A07'
    covered_source_id='SRC-M2-GA-A10'
    covering_source_id='SRC-M2-GA-A07'
    coverage_scope='selected_fact_set'
    equivalence_status='fully_covered'
    rationale='A07 直接支持 A10 在本轮涉及的五条 package 事实，包括 NCv4 Vector/Scalar 各 1.2 TFLOPS；A10 对本轮不再不可替代。'
    reviewed_by='m2_w2_aws_package_facts_remediation'
    review_date='2026-08-13'
    review_status='draft'
    notes='只用于本轮 package selection；不得删除 A10 来源、endpoint 或既有架构断言。'
})
Export-Rows 'structured\source-coverage.csv' $coverage

# B03: extend the frozen architecture backlog split without changing the other 23 dispositions.
$backlog = Import-Rows 'audit\backlog-disposition.csv'
$b = Get-One $backlog 'deferred_id' 'DEF-M2GA-ATRN3-02'
$b.candidate_fact_count = '5'
$b.candidate_fact_ids = 'FACT-M2W2-AWS-TRN3-CHIP-MX-PEAK|FACT-M2W2-AWS-TRN3-CHIP-MIXED-PEAK|FACT-M2W2-AWS-TRN3-CHIP-SPARSE-PEAK|FACT-M2W2-AWS-TRN3-CHIP-FP32-PEAK|FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC'
$b.notes = '已拆为五条原子事实；A08 generic FP8 固定定值与 A06 MXFP8/MXFP4 分开，未复制 architecture 机制、实例总量或系统聚合量。'
Export-Rows 'audit\backlog-disposition.csv' $backlog

# B06: record only source types that are actually present in the frozen search corpus.
$searchLog = Import-Rows 'structured\search-log.csv'
foreach ($s in $searchLog) {
    if ($s.search_id -like 'SEARCH-M2W2-AWS-TRN3-*') {
        $s.source_types_checked = 'developer_documentation;press_release'
        $s.notes = '在本包固定的开发文档与 A08 新闻稿语料内未找到可靠定值；未声称检查 cloud_service_documentation。'
    } else {
        $s.source_types_checked = 'developer_documentation'
        $s.notes = '在本包固定的开发文档语料内未找到可靠定值；未声称检查 cloud_service_documentation 或 press_release。'
    }
}
Export-Rows 'structured\search-log.csv' $searchLog

# B05: propose the smallest global field contract change, but do not modify formal or staged fields.csv.
$fieldProposal = @([pscustomobject][ordered]@{
    field_id='FIELD-PHY-CLOCK'
    current_allowed_subject_kinds='object'
    proposed_allowed_subject_kinds='object;component'
    rationale='时钟可以属于整个对象或具体执行组件；Trainium3 A07 的 2.4 GHz 主语是 Tensor Engine，改挂芯片 object 会改变事实语义。'
    formal_precedent_fact_ids='FACT-AWS-TRN2-TENSOR-CLOCK|FACT-AWS-TRN2-VECTOR-CLOCK|FACT-AWS-TRN2-SCALAR-CLOCK|FACT-AWS-TRN2-GPSIMD-CLOCK'
    formal_precedent_requirement_ids='REQ-AWS-TRN2-0069|REQ-AWS-TRN2-0070|REQ-AWS-TRN2-0071|REQ-AWS-TRN2-0072'
    action='propose_global_contract_update'
    decision_status='pending_independent_review'
    review_status='draft'
    notes='最小候选只补 component，以覆盖 Trainium2 正式组件时钟先例和本包 Trainium3 Tensor Engine 时钟；正式库其他历史主体问题另案处理。此文件不写数据/fields.csv。'
})
Export-Rows 'audit\field-contract-change-candidate.csv' $fieldProposal

# B09: all package-local paths must point to this remediated staging version.
$freezeRegister = Import-Rows 'source-gate\source-freeze-register.csv'
foreach ($row in $freezeRegister) {
    $row.staging_local_path = $row.staging_local_path.Replace('M2-W2-AWS-PACKAGE-FACTS/','M2-W2-AWS-PACKAGE-FACTS-REMEDIATED/')
}
Export-Rows 'source-gate\source-freeze-register.csv' $freezeRegister

Write-Output 'AWS package remediation data transform completed.'
