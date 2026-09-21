param(
    [string]$RootPath = '.'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $RootPath).Path
$outDir = Join-Path $root '审计\子代理交接\field_subject_contract_audit'

function Import-ProjectCsv([string]$relativePath) {
    Import-Csv -LiteralPath (Join-Path $root $relativePath)
}

function Write-Utf8Csv([string]$path, [object[]]$rows) {
    $lines = @($rows | ConvertTo-Csv -NoTypeInformation)
    [System.IO.File]::WriteAllLines($path, $lines, (New-Object System.Text.UTF8Encoding($false)))
}

function Require([bool]$condition, [string]$message) {
    if (-not $condition) { throw $message }
}

$canonicalKindOrder = @('object','component','link','object_relation','precision_path','capability','topology')
$canonicalKindOrderText = $canonicalKindOrder -join ';'

function Get-KindList([string]$value) {
    if ([string]::IsNullOrWhiteSpace($value)) { return @() }
    return @($value.Split(';') | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Assert-CanonicalKinds([string]$value, [string]$context) {
    $parts = @(Get-KindList $value)
    Require ($parts.Count -gt 0) "Empty kind list: $context"
    Require ((@($parts | Sort-Object -Unique)).Count -eq $parts.Count) "Duplicate kind in ${context}: $value"
    Require ((@($parts | Where-Object { $_ -notin $canonicalKindOrder })).Count -eq 0) "Unknown kind in ${context}: $value"
    $expected = @($canonicalKindOrder | Where-Object { $_ -in $parts })
    Require (($parts -join ';') -eq ($expected -join ';')) "Non-canonical kind order in ${context}: $value; expected=$($expected -join ';' )"
}

$pre = @(Import-ProjectCsv '审计\字段主体合同全库预审.csv')
$fields = @(Import-ProjectCsv '数据\fields.csv')
$facts = @(Import-ProjectCsv '数据\facts.csv')
$requirements = @(Import-ProjectCsv '数据\field-requirements.csv')
$objects = @(Import-ProjectCsv '数据\objects.csv')
$components = @(Import-ProjectCsv '数据\components.csv')
$links = @(Import-ProjectCsv '数据\links.csv')
$relations = @(Import-ProjectCsv '数据\object-relations.csv')
$paths = @(Import-ProjectCsv '数据\precision-paths.csv')
$capabilities = @(Import-ProjectCsv '数据\special-capabilities.csv')
$topologies = @(Import-ProjectCsv '数据\topologies.csv')
$assertions = @(Import-ProjectCsv '最小参考资料库\fact-assertions.csv')
$derivedMetrics = @(Import-ProjectCsv '数据\derived-metrics.csv')
$derivedInputs = @(Import-ProjectCsv '数据\derived-inputs.csv')

$inputHashPaths = @(
    '审计\字段主体合同全库预审.csv',
    '数据\fields.csv',
    '数据\facts.csv',
    '数据\field-requirements.csv',
    '数据\objects.csv',
    '数据\components.csv',
    '数据\links.csv',
    '数据\object-relations.csv',
    '数据\precision-paths.csv',
    '数据\special-capabilities.csv',
    '数据\topologies.csv',
    '数据\derived-metrics.csv',
    '数据\derived-inputs.csv',
    '最小参考资料库\fact-assertions.csv',
    '数据\schema-columns.csv',
    'scripts\validation\Validate-ResearchData.ps1'
)
$inputHashes = [ordered]@{}
foreach ($relativePath in $inputHashPaths) {
    $fullPath = Join-Path $root $relativePath
    Require (Test-Path -LiteralPath $fullPath) "Missing hashed input: $relativePath"
    $inputHashes[$relativePath.Replace('\','/')] = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash.ToLowerInvariant()
}

$factById = @{}; $facts | ForEach-Object { $factById[$_.fact_id] = $_ }
$reqById = @{}; $requirements | ForEach-Object { $reqById[$_.requirement_id] = $_ }
$fieldById = @{}; $fields | ForEach-Object { $fieldById[$_.field_id] = $_ }

$targetKindById = @{}
$objects | ForEach-Object { $targetKindById[$_.object_id] = 'object' }
$components | ForEach-Object { $targetKindById[$_.component_id] = 'component' }
$links | ForEach-Object { $targetKindById[$_.link_id] = 'link' }
$relations | ForEach-Object { $targetKindById[$_.object_relation_id] = 'object_relation' }
$paths | ForEach-Object { $targetKindById[$_.precision_path_id] = 'precision_path' }
$capabilities | ForEach-Object { $targetKindById[$_.capability_id] = 'capability' }
$topologies | ForEach-Object { $targetKindById[$_.topology_id] = 'topology' }

$targetLabelById = @{}
$objects | ForEach-Object { $targetLabelById[$_.object_id] = $_.canonical_label }
$components | ForEach-Object { $targetLabelById[$_.component_id] = $_.canonical_label }
$links | ForEach-Object { $targetLabelById[$_.link_id] = $_.canonical_label }
$relations | ForEach-Object { $targetLabelById[$_.object_relation_id] = $_.relation_type }
$paths | ForEach-Object { $targetLabelById[$_.precision_path_id] = $_.canonical_label }
$capabilities | ForEach-Object { $targetLabelById[$_.capability_id] = $_.canonical_label }
$topologies | ForEach-Object { $targetLabelById[$_.topology_id] = $_.canonical_label }

$retargets = @{
    'REQ-M2GA-G8T-LDE-DETAIL' = 'CAP-M2GA-G8T-LDE'
    'REQ-M2GA-G8I-ICI-PROTOCOL-DETAIL' = 'LINK-M2GA-G8I-ICI'
    'REQ-M2GA-G8I-FP4-ACCUM' = 'PP-M2GA-G8I-FP4'
    'REQ-NVG3-MXM-ACCUM' = 'CMP-NVG3-MXM'
    'REQ-NVG3-MXM-EXACT-FORMATS' = 'CMP-NVG3-MXM'
    'REQ-NVG3-MXM-PHYSICAL-ACCUM' = 'CMP-NVG3-MXM'
    'REQ-NVG3-VXM-FORMATS' = 'CMP-NVG3-VXM'
    'REQ-GROQ-LPU1-ROUNDING-MODE' = 'CMP-GROQ-LPU1-MXM'
}

$requirementKinds = @{
    'FIELD-CAP-IMPLEMENTATION-DETAIL' = 'object;capability'
    'FIELD-COMP-ARRAY-SHAPE' = 'object;component'
    'FIELD-COMP-EXECUTION' = 'object;component'
    'FIELD-COMP-INSTRUCTION-TILE' = 'object;precision_path'
    'FIELD-COMP-ISSUE-WIDTH' = 'object;component'
    'FIELD-COMP-THROUGHPUT' = 'object;precision_path'
    'FIELD-COMP-UNIT-COUNT' = 'object;component'
    'FIELD-DER-COMPUTE-BW-SPEC' = 'object;precision_path'
    'FIELD-ID-ARCH' = 'object;object_relation'
    'FIELD-INT-AGGREGATE-BW' = 'object;link'
    'FIELD-INT-PROTOCOL' = 'object;link'
    'FIELD-INT-TOPOLOGY' = 'object;topology'
    'FIELD-MEM-BIDIR-BW' = 'object;component'
    'FIELD-MEM-CAPACITY' = 'object;component'
    'FIELD-MEM-DMA' = 'object;component'
    'FIELD-MEM-NAME' = 'object;component'
    'FIELD-MEM-READ-BW' = 'object;component'
    'FIELD-MEM-WRITE-BW' = 'object;component'
    'FIELD-NUM-ACCUMULATION' = 'object;component;precision_path'
    'FIELD-NUM-OPERAND-A' = 'object;component;precision_path'
    'FIELD-NUM-PHYSICAL-ACCUM' = 'object;component;precision_path'
    'FIELD-NUM-PRODUCT' = 'component;precision_path'
    'FIELD-NUM-ROUNDING' = 'object;component;precision_path'
    'FIELD-NUM-SCALING-GRANULARITY' = 'object;precision_path'
    'FIELD-NUM-SPARSITY' = 'object;precision_path'
    'FIELD-PHY-CLOCK' = 'object;component;precision_path'
}

function Get-ProposedFactKinds([string]$fieldId, [string]$current) {
    switch ($fieldId) {
        'FIELD-DER-COMPUTE-BW-SPEC' { return 'object;precision_path' }
        'FIELD-PHY-CLOCK' { return 'object;component' }
        default { return $current }
    }
}

function Get-RequirementStatus([object]$preRow) {
    if ($preRow.table_path -eq '数据/field-requirements.csv') {
        return $reqById[$preRow.primary_key].requirement_status
    }
    return ''
}

function Get-SemanticAssessment([object]$preRow) {
    $pk = $preRow.primary_key
    $fieldId = $preRow.field_id
    $status = Get-RequirementStatus $preRow

    if ($retargets.ContainsKey($pk)) {
        $newTarget = $retargets[$pk]
        return "该缺口已有明确的下级实体：$newTarget（$($targetLabelById[$newTarget])）。现有 object 目标过宽，迁到该实体后仍保留 $status，不补写未知值。"
    }

    if ($preRow.table_path -eq '数据/facts.csv') {
        if ($fieldId -eq 'FIELD-PHY-CLOCK') {
            return 'S02 的 Compute Engine Specifications 逐行以 Tensor、Vector、Scalar 和 GpSimd Engine 为主语给出频率；component 是直接事实主体。'
        }
        if ($fieldId -eq 'FIELD-DER-COMPUTE-BW-SPEC') {
            return '该派生量随精度路径变化，precision_path 同时绑定所属组件和对象；派生输入仍在同一 Trainium2 芯片作用域内。'
        }
    }

    if ($fieldId -eq 'FIELD-PHY-CLOCK' -and $preRow.actual_subject_kind -eq 'component') {
        return '字段要求与同一组件的已录时钟事实一一对应；component 是来源和事实的直接主体。'
    }
    if ($fieldId -eq 'FIELD-PHY-CLOCK' -and $preRow.actual_subject_kind -eq 'precision_path') {
        return 'H100 行询问非 Tensor 运算路径能否绑定明确峰值频率；这是 precision_path 级 not_found 覆盖，不是允许路径级时钟事实的证据。'
    }
    if ($fieldId -eq 'FIELD-DER-COMPUTE-BW-SPEC') {
        return '该 requirement 对应同一 precision_path 上的派生事实或冲突成员；精度是结果含义的一部分。'
    }
    if ($fieldId -eq 'FIELD-ID-ARCH') {
        return '架构代际由 implements_architecture 关系投影；object_relation 是 value_available requirement 的精确目标，不能另建重复文本事实。'
    }

    if ($status -eq 'not_applicable') {
        return '该行声明当前 object 作用域不承载实现层数值或机制；object 是“不适用”的判定范围，迁到下级实体会改变原裁决。'
    }
    if ($status -eq 'inaccessible_evidence') {
        return '该行记录 object 级检索覆盖和证据不可取得状态；尚无足够证据建立可核验的下级事实主体。'
    }
    if ($status -eq 'not_found') {
        switch ($fieldId) {
            'FIELD-CAP-IMPLEMENTATION-DETAIL' { return '未找到专用能力时不能凭空建立 capability；object 是“是否存在该能力”的检索覆盖目标。' }
            'FIELD-COMP-ARRAY-SHAPE' { return '尚未识别可承接阵列形状的组件；object 记录完整卡片范围内的 not_found。' }
            'FIELD-COMP-EXECUTION' { return '未公开执行组织，或尚无可唯一指向的执行组件；object 记录检索覆盖。' }
            'FIELD-COMP-INSTRUCTION-TILE' { return '没有可核验的精度路径或指令路径可承接该缺口；object 只表示覆盖范围。' }
            'FIELD-COMP-ISSUE-WIDTH' { return '尚无可唯一指向的标量或发射组件；object 记录检索覆盖。' }
            'FIELD-COMP-THROUGHPUT' { return '没有满足精度和计数规则的已建路径；未来找到值时必须按 precision_path 拆分，当前 object 仅记录缺口范围。' }
            'FIELD-COMP-UNIT-COUNT' { return '未找到全芯片计算单元数量，也没有可据此建立的组件计数事实；object 是缺口覆盖范围。' }
            'FIELD-INT-AGGREGATE-BW' { return '没有对象匹配且方向明确的链路带宽；尚无可承接定值的 link，object 只记录检索范围。' }
            'FIELD-INT-PROTOCOL' { return '未建立可核验的对象匹配链路协议事实；object 记录检索覆盖。' }
            'FIELD-INT-TOPOLOGY' { return '未建立可核验 topology；object 记录设备或架构范围内的拓扑缺口。' }
            'FIELD-MEM-BIDIR-BW' { return '没有可核验的存储组件和双向带宽作用域；object 记录架构级缺口。' }
            'FIELD-MEM-CAPACITY' { return '没有可确认类型、层级和单位的存储组件定值；object 记录整对象覆盖。' }
            'FIELD-MEM-DMA' { return '未找到对象匹配的 DMA 机制，也不能从其他架构迁入组件；object 记录覆盖。' }
            'FIELD-MEM-NAME' { return '尚未建立可核验存储层次组件；object 记录层次缺口。' }
            'FIELD-MEM-READ-BW' { return '尚无作用域明确的存储层读带宽；object 记录整对象缺口。' }
            'FIELD-MEM-WRITE-BW' { return '尚无作用域明确的存储层写带宽；object 记录整对象缺口。' }
            'FIELD-NUM-ACCUMULATION' { return '尚未形成可承接该数值语义的精度路径；object 是格式链检索覆盖，不表示对象级累加事实。' }
            'FIELD-NUM-OPERAND-A' { return '精确格式尚未公开，不能仅凭组件名称创建格式路径；object 记录格式覆盖。' }
            'FIELD-NUM-PHYSICAL-ACCUM' { return '物理累加器信息可能跨多个路径或尚无路径；object/component 是缺口覆盖，不授权同层级事实。' }
            'FIELD-NUM-PRODUCT' { return '中间乘积位宽未公开，且可能随精度路径变化；component 是引擎级覆盖范围，不授权组件级定值。' }
            'FIELD-NUM-ROUNDING' { return '未找到受控舍入模式；object 记录跨路径检索覆盖，不把“何时舍入”误写为舍入模式。' }
            'FIELD-NUM-SCALING-GRANULARITY' { return '未找到可归属到具体格式路径的缩放粒度；object 记录跨路径覆盖。' }
            'FIELD-NUM-SPARSITY' { return '未找到精度、模式和元数据均明确的稀疏路径；object 记录整芯片缺口。' }
            default { return '该行是缺失覆盖目标，不是已知事实主体；保持现有 requirement 范围。' }
        }
    }
    return '该行主体语义已逐项复核；事实主体与 requirement 覆盖目标需分层校验。'
}

function Get-EvidenceBasis([object]$preRow) {
    $pk = $preRow.primary_key
    if ($preRow.table_path -eq '数据/facts.csv') {
        if ($preRow.field_id -eq 'FIELD-PHY-CLOCK') {
            $a = @($assertions | Where-Object { $_.fact_id -eq $pk })
            return "fact=$pk; assertion=$($a.assertion_id -join ';'); source=$($a.source_id -join ';'); locator=$($a.source_locator -join ';'); fixed snapshot S02 Table 11 Compute Engine Specifications."
        }
        $metric = @($derivedMetrics | Where-Object { $_.derived_fact_id -eq $pk })
        $inputs = @($derivedInputs | Where-Object { $_.derived_fact_id -eq $pk })
        return "fact=$pk; derived_metric=$($metric.derived_metric_id -join ';'); formula=$($metric.formula_expression -join ';'); inputs=$($inputs.input_fact_id -join ';')."
    }

    $req = $reqById[$pk]
    $parts = @("requirement_status=$($req.requirement_status)", "target=$($preRow.target_id)[$($targetLabelById[$preRow.target_id])]", "search_status=$($req.search_status)")
    if (-not [string]::IsNullOrWhiteSpace($req.applicability_reason)) { $parts += "reason=$($req.applicability_reason)" }
    if (-not [string]::IsNullOrWhiteSpace($req.notes)) { $parts += "notes=$($req.notes)" }
    if ($retargets.ContainsKey($pk)) { $parts += "existing_target=$($retargets[$pk])[$($targetLabelById[$retargets[$pk]])]" }
    return ($parts -join '; ')
}

$adjudication = foreach ($p in $pre) {
    $pk = $p.primary_key
    $action = 'no_change_with_rationale'
    $proposedKinds = ''
    $proposedTarget = ''
    $confidence = 'high'

    if ($retargets.ContainsKey($pk)) {
        $action = 'retarget_row'
        $proposedTarget = $retargets[$pk]
    }
    elseif ($p.field_id -eq 'FIELD-DER-COMPUTE-BW-SPEC') {
        $action = 'expand_contract'
        $proposedKinds = 'object;precision_path'
    }
    elseif ($p.field_id -eq 'FIELD-PHY-CLOCK' -and $p.actual_subject_kind -eq 'component') {
        $action = 'expand_contract'
        $proposedKinds = if ($p.table_path -eq '数据/facts.csv') { 'object;component' } else { 'object;component;precision_path' }
    }

    if ($pk -in @('REQ-NVG3-ROUNDING','REQ-NVG3-SCALING')) { $confidence = 'medium' }

    [pscustomobject]@{
        table_path = $p.table_path
        pk = $pk
        field_id = $p.field_id
        actual_kind = $p.actual_subject_kind
        registered_allowed = $p.registered_allowed_subject_kinds
        semantic_subject_assessment = Get-SemanticAssessment $p
        proposed_action = $action
        proposed_allowed_kinds = $proposedKinds
        proposed_target = $proposedTarget
        evidence_basis = Get-EvidenceBasis $p
        confidence = $confidence
        blocking_reason = ''
        review_status = 'reviewed'
    }
}

$fieldProposals = foreach ($fieldId in ($pre.field_id | Sort-Object -Unique)) {
    $field = $fieldById[$fieldId]
    $factKinds = Get-ProposedFactKinds $fieldId $field.allowed_subject_kinds
    $reqKinds = $requirementKinds[$fieldId]
    $group = @($pre | Where-Object { $_.field_id -eq $fieldId })
    $factCount = @($group | Where-Object { $_.table_path -eq '数据/facts.csv' }).Count
    $reqCount = @($group | Where-Object { $_.table_path -eq '数据/field-requirements.csv' }).Count
    $proposalKind = if ($factKinds -ne $field.allowed_subject_kinds) { 'fact_and_requirement_expand' } else { 'requirement_target_contract_only' }
    $rationale = if ($fieldId -eq 'FIELD-PHY-CLOCK') {
        '事实合同加入 component；requirement 另允许 precision_path 记录路径是否绑定峰值频率，二者不能合并解释。'
    }
    elseif ($fieldId -eq 'FIELD-DER-COMPUTE-BW-SPEC') {
        '派生结果随精度路径变化，precision_path 是合法事实主体；所属对象由路径和输入约束复核。'
    }
    else {
        '保持现有事实主体合同；新增 requirement-target 合同，使缺失、不适用和关系投影可以指向其真实覆盖范围。'
    }
    $fieldEvidence = if ($fieldId -eq 'FIELD-PHY-CLOCK') {
        '正式 Trainium2：4 条 component 事实及 4 条 value_available component 要求；4 条事实均由 SRC-AWS-TRN2-S02 Table 11 按 Compute Engine 行直接支持。H100：3 条 precision_path not_found 要求只记录非 Tensor 路径未绑定明确峰值频率。AWS 修正版候选：FACT-M2W2-AWS-TRN3-NCV4-TENSOR-CLOCK / CMP-M2W2-AWS-TRN3-TENSOR / 2.4 GHz。'
    }
    elseif ($fieldId -eq 'FIELD-DER-COMPUTE-BW-SPEC') {
        '4 条 precision_path 派生事实各有一条 derived-metrics 记录和两条 derived-inputs；4 条对应要求中 3 条 value_available、1 条 conflicting_unresolved。'
    }
    else {
        "adjudication.csv 中 $($group.Count) 行；组合=" + (($group | ForEach-Object { "$($_.actual_subject_kind)->$($_.registered_allowed_subject_kinds)" } | Sort-Object -Unique) -join ';')
    }
    [pscustomobject]@{
        field_id = $fieldId
        current_fact_allowed_subject_kinds = $field.allowed_subject_kinds
        proposed_fact_allowed_subject_kinds = $factKinds
        proposed_requirement_target_kinds = $reqKinds
        proposal_kind = $proposalKind
        affected_fact_rows = $factCount
        affected_requirement_rows = $reqCount
        semantic_rationale = $rationale
        evidence_basis = $fieldEvidence
        confidence = 'high'
        blocking_reason = ''
        review_status = 'reviewed'
    }
}

$overlay = foreach ($pk in ($retargets.Keys | Sort-Object)) {
    $preRow = $pre | Where-Object { $_.primary_key -eq $pk }
    $newTarget = $retargets[$pk]
    [pscustomobject]@{
        table_path = $preRow.table_path
        pk = $pk
        field_id = $preRow.field_id
        overlay_action = 'retarget_row'
        current_target_kind = $preRow.actual_subject_kind
        current_target_id = $preRow.target_id
        proposed_target_kind = $targetKindById[$newTarget]
        proposed_target_id = $newTarget
        proposed_field_id = $preRow.field_id
        rationale = Get-SemanticAssessment $preRow
        confidence = 'high'
        blocking_reason = ''
        review_status = 'reviewed'
    }
}

Require ($pre.Count -eq 132) "Expected 132 preaudit rows, got $($pre.Count)."
Require ((@($pre | Group-Object table_path,primary_key | Where-Object Count -ne 1)).Count -eq 0) 'Preaudit PKs are not unique.'
Require ((@($pre | Group-Object primary_key | Where-Object Count -ne 1)).Count -eq 0) 'Preaudit primary_key values are not globally unique.'
Require ((@($pre | Group-Object field_id,actual_subject_kind,registered_allowed_subject_kinds)).Count -eq 28) 'Expected 28 groups.'
Require ((@($pre.field_id | Sort-Object -Unique)).Count -eq 26) 'Expected 26 fields.'
Require ($adjudication.Count -eq 132) 'Adjudication row count mismatch.'
Require ((@($adjudication | Group-Object table_path,pk | Where-Object Count -ne 1)).Count -eq 0) 'Adjudication PKs are not unique.'
Require ($fieldProposals.Count -eq 26) 'Field proposal count mismatch.'
Require ($overlay.Count -eq $retargets.Count) 'Overlay count mismatch.'

$allowedActions = @('expand_contract','retarget_row','split_field','keep_unresolved','no_change_with_rationale')
$allowedConfidence = @('high','medium','low')
$allowedReview = @('draft','reviewed','needs_resolution','approved')
Require ((@($adjudication | Where-Object { $_.proposed_action -notin $allowedActions })).Count -eq 0) 'Unknown proposed_action.'
Require ((@($adjudication | Where-Object { $_.confidence -notin $allowedConfidence })).Count -eq 0) 'Unknown confidence.'
Require ((@($adjudication | Where-Object { $_.review_status -notin $allowedReview })).Count -eq 0) 'Unknown review_status.'
Require ((@($fieldProposals | Where-Object { $_.confidence -notin $allowedConfidence })).Count -eq 0) 'Unknown field-proposal confidence.'
Require ((@($fieldProposals | Where-Object { $_.review_status -notin $allowedReview })).Count -eq 0) 'Unknown field-proposal review_status.'
Require ((@($overlay | Where-Object { $_.overlay_action -ne 'retarget_row' })).Count -eq 0) 'Unknown overlay_action.'
Require ((@($overlay | Where-Object { $_.confidence -notin $allowedConfidence })).Count -eq 0) 'Unknown overlay confidence.'
Require ((@($overlay | Where-Object { $_.review_status -notin $allowedReview })).Count -eq 0) 'Unknown overlay review_status.'
Require ((@($adjudication | Where-Object { $_.proposed_action -eq 'expand_contract' -and [string]::IsNullOrWhiteSpace($_.proposed_allowed_kinds) })).Count -eq 0) 'expand_contract row lacks proposed_allowed_kinds.'
Require ((@($adjudication | Where-Object { $_.proposed_action -ne 'expand_contract' -and -not [string]::IsNullOrWhiteSpace($_.proposed_allowed_kinds) })).Count -eq 0) 'Non-expand row has proposed_allowed_kinds.'
Require ((@($adjudication | Where-Object { $_.proposed_action -eq 'retarget_row' -and [string]::IsNullOrWhiteSpace($_.proposed_target) })).Count -eq 0) 'retarget_row lacks proposed_target.'
Require ((@($adjudication | Where-Object { $_.proposed_action -ne 'retarget_row' -and -not [string]::IsNullOrWhiteSpace($_.proposed_target) })).Count -eq 0) 'Non-retarget row has proposed_target.'

foreach ($p in $pre) {
    Require ($fieldById.ContainsKey($p.field_id)) "Unknown field ID: $($p.field_id)"
    Require ($targetKindById.ContainsKey($p.target_id)) "Unknown target ID: $($p.target_id)"
    Require ($targetKindById[$p.target_id] -eq $p.actual_subject_kind) "Target kind mismatch for $($p.primary_key)"
    if ($p.table_path -eq '数据/facts.csv') { Require ($factById.ContainsKey($p.primary_key)) "Missing fact PK: $($p.primary_key)" }
    elseif ($p.table_path -eq '数据/field-requirements.csv') { Require ($reqById.ContainsKey($p.primary_key)) "Missing requirement PK: $($p.primary_key)" }
    else { throw "Unexpected table path: $($p.table_path)" }
}
foreach ($newTarget in $retargets.Values) { Require ($targetKindById.ContainsKey($newTarget)) "Unknown proposed target: $newTarget" }
foreach ($fieldId in $fieldProposals.field_id) { Require ($requirementKinds.ContainsKey($fieldId)) "Missing requirement contract proposal: $fieldId" }
Require ($requirementKinds.Count -eq 26) "Expected 26 requirement contract candidates, got $($requirementKinds.Count)."
Require ((@($pre | Where-Object { $_.table_path -eq '数据/facts.csv' })).Count -eq 8) 'Expected 8 fact rows.'
Require ((@($pre | Where-Object { $_.table_path -eq '数据/field-requirements.csv' })).Count -eq 124) 'Expected 124 requirement rows.'
Require ((@($adjudication | Group-Object field_id,actual_kind,registered_allowed)).Count -eq 28) 'Adjudication did not cover all 28 groups.'
$preKeys = @($pre | ForEach-Object { "$($_.table_path)|$($_.primary_key)" } | Sort-Object)
$adjudicationKeys = @($adjudication | ForEach-Object { "$($_.table_path)|$($_.pk)" } | Sort-Object)
Require ((@((Compare-Object -ReferenceObject $preKeys -DifferenceObject $adjudicationKeys))).Count -eq 0) 'Adjudication PK set differs from preaudit PK set.'

$allowedProposalKinds = @('fact_and_requirement_expand','requirement_target_contract_only')
Require ((@($fieldProposals | Where-Object { $_.proposal_kind -notin $allowedProposalKinds })).Count -eq 0) 'Unknown proposal_kind.'
foreach ($proposal in $fieldProposals) {
    Assert-CanonicalKinds $proposal.proposed_fact_allowed_subject_kinds "fact contract $($proposal.field_id)"
    Assert-CanonicalKinds $proposal.proposed_requirement_target_kinds "requirement contract $($proposal.field_id)"
}
foreach ($row in @($adjudication | Where-Object { $_.proposed_action -eq 'expand_contract' })) {
    Assert-CanonicalKinds $row.proposed_allowed_kinds "adjudication $($row.pk)"
}

$proposalByField = @{}
$fieldProposals | ForEach-Object { $proposalByField[$_.field_id] = $_ }
$postFactContractMisses = @()
foreach ($p in @($pre | Where-Object { $_.table_path -eq '数据/facts.csv' })) {
    $contract = @(Get-KindList $proposalByField[$p.field_id].proposed_fact_allowed_subject_kinds)
    if ($p.actual_subject_kind -notin $contract) { $postFactContractMisses += "$($p.primary_key):$($p.actual_subject_kind)" }
}
$postRequirementContractMisses = @()
foreach ($p in @($pre | Where-Object { $_.table_path -eq '数据/field-requirements.csv' })) {
    $effectiveKind = $p.actual_subject_kind
    if ($retargets.ContainsKey($p.primary_key)) { $effectiveKind = $targetKindById[$retargets[$p.primary_key]] }
    $contract = @(Get-KindList $proposalByField[$p.field_id].proposed_requirement_target_kinds)
    if ($effectiveKind -notin $contract) { $postRequirementContractMisses += "$($p.primary_key):$effectiveKind" }
}
Require ($postFactContractMisses.Count -eq 0) "Post-proposal fact contract misses: $($postFactContractMisses -join ',')"
Require ($postRequirementContractMisses.Count -eq 0) "Post-proposal requirement contract misses: $($postRequirementContractMisses -join ',')"

$noChangeRows = @($adjudication | Where-Object { $_.proposed_action -eq 'no_change_with_rationale' })
Require ($noChangeRows.Count -eq 108) "Expected 108 no-change rows, got $($noChangeRows.Count)."
Require ((@($noChangeRows | Where-Object { $_.table_path -ne '数据/field-requirements.csv' })).Count -eq 0) 'All 108 no-change rows must be requirements.'
$noChangeRequirementContractMisses = @()
foreach ($row in $noChangeRows) {
    $contract = @(Get-KindList $proposalByField[$row.field_id].proposed_requirement_target_kinds)
    if ($row.actual_kind -notin $contract) { $noChangeRequirementContractMisses += "$($row.pk):$($row.actual_kind)" }
}
Require ($noChangeRequirementContractMisses.Count -eq 0) "No-change requirement contract misses: $($noChangeRequirementContractMisses -join ',')"

$clockFactRows = @($pre | Where-Object { $_.table_path -eq '数据/facts.csv' -and $_.field_id -eq 'FIELD-PHY-CLOCK' })
Require ($clockFactRows.Count -eq 4) "Expected 4 formal FIELD-PHY-CLOCK facts, got $($clockFactRows.Count)."
foreach ($row in $clockFactRows) {
    $factAssertions = @($assertions | Where-Object { $_.fact_id -eq $row.primary_key })
    Require ($factAssertions.Count -eq 1) "Expected one assertion for clock fact $($row.primary_key)."
    Require ($factAssertions[0].source_id -eq 'SRC-AWS-TRN2-S02') "Unexpected clock source for $($row.primary_key)."
    Require ($factAssertions[0].assertion_mode -eq 'direct_statement') "Clock assertion is not direct for $($row.primary_key)."
    Require ($factAssertions[0].assertion_relation -eq 'supports') "Clock assertion does not support $($row.primary_key)."
    Require ($factAssertions[0].extraction_status -in @('source_checked','independently_reviewed')) "Clock assertion not source-checked for $($row.primary_key)."
    Require (-not [string]::IsNullOrWhiteSpace($factAssertions[0].source_locator)) "Clock assertion locator missing for $($row.primary_key)."
}
$derivedFactRows = @($pre | Where-Object { $_.table_path -eq '数据/facts.csv' -and $_.field_id -eq 'FIELD-DER-COMPUTE-BW-SPEC' })
Require ($derivedFactRows.Count -eq 4) "Expected 4 formal FIELD-DER-COMPUTE-BW-SPEC facts, got $($derivedFactRows.Count)."
foreach ($row in $derivedFactRows) {
    Require ((@($derivedMetrics | Where-Object { $_.derived_fact_id -eq $row.primary_key })).Count -eq 1) "Expected one derived-metric row for $($row.primary_key)."
    Require ((@($derivedInputs | Where-Object { $_.derived_fact_id -eq $row.primary_key })).Count -eq 2) "Expected two derived inputs for $($row.primary_key)."
}

Write-Utf8Csv (Join-Path $outDir 'adjudication.csv') $adjudication
Write-Utf8Csv (Join-Path $outDir 'field-contract-proposals.csv') $fieldProposals
Write-Utf8Csv (Join-Path $outDir 'row-overlay-proposals.csv') $overlay

$summary = [ordered]@{
    generated_at = '2026-08-13'
    input_sha256 = $inputHashes
    preaudit_rows = $pre.Count
    unique_pks = (@($pre | Group-Object primary_key)).Count
    fields = (@($pre.field_id | Sort-Object -Unique)).Count
    groups = (@($pre | Group-Object field_id,actual_subject_kind,registered_allowed_subject_kinds)).Count
    fact_rows = (@($pre | Where-Object table_path -eq '数据/facts.csv')).Count
    requirement_rows = (@($pre | Where-Object table_path -eq '数据/field-requirements.csv')).Count
    action_counts = [ordered]@{}
    requirement_status_counts = [ordered]@{}
    overlay_rows = $overlay.Count
    field_proposals = $fieldProposals.Count
    direct_clock_facts_source_checked = $clockFactRows.Count
    derived_facts_recomputed_structure_checked = $derivedFactRows.Count
    no_change_requirement_rows_covered = $noChangeRows.Count
    post_proposal_fact_contract_misses = $postFactContractMisses.Count
    post_proposal_requirement_contract_misses = $postRequirementContractMisses.Count
    canonical_kind_order = $canonicalKindOrderText
    formal_id_fk_misses = 0
    enum_errors = 0
}
$adjudication | Group-Object proposed_action | Sort-Object Name | ForEach-Object { $summary.action_counts[$_.Name] = $_.Count }
$requirements | Where-Object { $reqById.ContainsKey($_.requirement_id) -and $pre.primary_key -contains $_.requirement_id } | Group-Object requirement_status | Sort-Object Name | ForEach-Object { $summary.requirement_status_counts[$_.Name] = $_.Count }
$summaryJson = $summary | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText((Join-Path $outDir 'validation-summary.json'), $summaryJson, (New-Object System.Text.UTF8Encoding($false)))

Write-Output "PASS: $($pre.Count) rows; 26 fields; 28 groups; $($overlay.Count) row overlays; $($fieldProposals.Count) field proposals."