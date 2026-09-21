param(
    [string]$RootPath = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总'
)

$ErrorActionPreference = 'Stop'
$outDir = Join-Path $RootPath '审计\子代理交接\chip_only_scope_audit'

function New-StringSet {
    return ,([System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal))
}

function Add-MapSet {
    param(
        [hashtable]$Map,
        [string]$Key,
        [string]$Value
    )
    if ([string]::IsNullOrWhiteSpace($Key) -or [string]::IsNullOrWhiteSpace($Value)) { return }
    if (-not $Map.ContainsKey($Key)) { $Map[$Key] = New-StringSet }
    [void]$Map[$Key].Add($Value)
}

function Get-SetValues {
    param([hashtable]$Map, [string]$Key)
    if (-not $Map.ContainsKey($Key)) { return @() }
    return @($Map[$Key] | Sort-Object)
}

$objects = Import-Csv -LiteralPath (Join-Path $RootPath '数据\objects.csv') -Encoding UTF8
$relations = Import-Csv -LiteralPath (Join-Path $RootPath '数据\object-relations.csv') -Encoding UTF8
$components = Import-Csv -LiteralPath (Join-Path $RootPath '数据\components.csv') -Encoding UTF8
$links = Import-Csv -LiteralPath (Join-Path $RootPath '数据\links.csv') -Encoding UTF8
$paths = Import-Csv -LiteralPath (Join-Path $RootPath '数据\precision-paths.csv') -Encoding UTF8
$capabilities = Import-Csv -LiteralPath (Join-Path $RootPath '数据\special-capabilities.csv') -Encoding UTF8
$topologies = Import-Csv -LiteralPath (Join-Path $RootPath '数据\topologies.csv') -Encoding UTF8
$facts = Import-Csv -LiteralPath (Join-Path $RootPath '数据\facts.csv') -Encoding UTF8
$requirements = Import-Csv -LiteralPath (Join-Path $RootPath '数据\field-requirements.csv') -Encoding UTF8
$completeness = Import-Csv -LiteralPath (Join-Path $RootPath '数据\card-completeness.csv') -Encoding UTF8
$assertions = Import-Csv -LiteralPath (Join-Path $RootPath '最小参考资料库\fact-assertions.csv') -Encoding UTF8
$selectionRuns = Import-Csv -LiteralPath (Join-Path $RootPath '最小参考资料库\selection-runs.csv') -Encoding UTF8
$selectionMembers = Import-Csv -LiteralPath (Join-Path $RootPath '最小参考资料库\selection-members.csv') -Encoding UTF8
$sources = Import-Csv -LiteralPath (Join-Path $RootPath '最小参考资料库\sources.csv') -Encoding UTF8
$screening = Import-Csv -LiteralPath (Join-Path $RootPath '最小参考资料库\source-screening.csv') -Encoding UTF8

$objectById = @{}
$classByObject = @{}
foreach ($o in $objects) {
    $objectById[$o.object_id] = $o
    switch ($o.object_type) {
        'architecture_generation' { $classByObject[$o.object_id] = 'B' }
        'die' { $classByObject[$o.object_id] = 'A' }
        'chiplet' { $classByObject[$o.object_id] = 'A' }
        'package' { $classByObject[$o.object_id] = 'A' }
        default { $classByObject[$o.object_id] = 'C' }
    }
}

$componentById = @{}
foreach ($x in $components) { $componentById[$x.component_id] = $x }
$linkById = @{}
foreach ($x in $links) { $linkById[$x.link_id] = $x }
$pathById = @{}
foreach ($x in $paths) { $pathById[$x.precision_path_id] = $x }
$capabilityById = @{}
foreach ($x in $capabilities) { $capabilityById[$x.capability_id] = $x }
$topologyById = @{}
foreach ($x in $topologies) { $topologyById[$x.topology_id] = $x }
$relationById = @{}
foreach ($x in $relations) { $relationById[$x.object_relation_id] = $x }

function Resolve-OwnerObjects {
    param($Row)
    $owners = New-StringSet
    if (-not [string]::IsNullOrWhiteSpace($Row.object_id)) {
        [void]$owners.Add($Row.object_id)
    }
    elseif (-not [string]::IsNullOrWhiteSpace($Row.component_id)) {
        if ($componentById.ContainsKey($Row.component_id)) {
            [void]$owners.Add($componentById[$Row.component_id].owner_object_id)
        }
    }
    elseif (-not [string]::IsNullOrWhiteSpace($Row.link_id)) {
        if ($linkById.ContainsKey($Row.link_id)) {
            [void]$owners.Add($linkById[$Row.link_id].owner_object_id)
        }
    }
    elseif (-not [string]::IsNullOrWhiteSpace($Row.object_relation_id)) {
        if ($relationById.ContainsKey($Row.object_relation_id)) {
            $rel = $relationById[$Row.object_relation_id]
            [void]$owners.Add($rel.subject_object_id)
            [void]$owners.Add($rel.object_object_id)
        }
    }
    elseif (-not [string]::IsNullOrWhiteSpace($Row.precision_path_id)) {
        if ($pathById.ContainsKey($Row.precision_path_id)) {
            $componentId = $pathById[$Row.precision_path_id].component_id
            if ($componentById.ContainsKey($componentId)) {
                [void]$owners.Add($componentById[$componentId].owner_object_id)
            }
        }
    }
    elseif (-not [string]::IsNullOrWhiteSpace($Row.capability_id)) {
        if ($capabilityById.ContainsKey($Row.capability_id)) {
            $cap = $capabilityById[$Row.capability_id]
            if (-not [string]::IsNullOrWhiteSpace($cap.owner_object_id)) {
                [void]$owners.Add($cap.owner_object_id)
            }
            elseif (-not [string]::IsNullOrWhiteSpace($cap.component_id) -and $componentById.ContainsKey($cap.component_id)) {
                [void]$owners.Add($componentById[$cap.component_id].owner_object_id)
            }
        }
    }
    elseif (-not [string]::IsNullOrWhiteSpace($Row.topology_id)) {
        if ($topologyById.ContainsKey($Row.topology_id)) {
            [void]$owners.Add($topologyById[$Row.topology_id].owner_object_id)
        }
    }
    return @($owners)
}

$objectFacts = @{}
$factOwners = @{}
foreach ($f in $facts) {
    $owners = @(Resolve-OwnerObjects $f)
    $factOwners[$f.fact_id] = $owners
    foreach ($owner in $owners) { Add-MapSet $objectFacts $owner $f.fact_id }
}

$objectRequirements = @{}
foreach ($req in $requirements) {
    $owners = @(Resolve-OwnerObjects $req)
    foreach ($owner in $owners) { Add-MapSet $objectRequirements $owner $req.requirement_id }
}

$objectAssertions = @{}
$objectSources = @{}
$sourceObjects = @{}
foreach ($a in $assertions) {
    if (-not $factOwners.ContainsKey($a.fact_id)) { continue }
    foreach ($owner in $factOwners[$a.fact_id]) {
        Add-MapSet $objectAssertions $owner $a.assertion_id
        Add-MapSet $objectSources $owner $a.source_id
        Add-MapSet $sourceObjects $a.source_id $owner
    }
}

$objectRelations = @{}
foreach ($rel in $relations) {
    Add-MapSet $objectRelations $rel.subject_object_id $rel.object_relation_id
    Add-MapSet $objectRelations $rel.object_object_id $rel.object_relation_id
}

$objectComponents = @{}
foreach ($x in $components) { Add-MapSet $objectComponents $x.owner_object_id $x.component_id }
$objectLinks = @{}
foreach ($x in $links) { Add-MapSet $objectLinks $x.owner_object_id $x.link_id }
$objectPaths = @{}
foreach ($x in $paths) {
    if ($componentById.ContainsKey($x.component_id)) {
        Add-MapSet $objectPaths $componentById[$x.component_id].owner_object_id $x.precision_path_id
    }
}
$objectCapabilities = @{}
foreach ($x in $capabilities) {
    $owner = $x.owner_object_id
    if ([string]::IsNullOrWhiteSpace($owner) -and $componentById.ContainsKey($x.component_id)) {
        $owner = $componentById[$x.component_id].owner_object_id
    }
    Add-MapSet $objectCapabilities $owner $x.capability_id
}
$objectTopologies = @{}
foreach ($x in $topologies) { Add-MapSet $objectTopologies $x.owner_object_id $x.topology_id }

$sourceRuns = @{}
$runMembers = @{}
foreach ($m in $selectionMembers) {
    Add-MapSet $sourceRuns $m.source_id $m.selection_run_id
    Add-MapSet $runMembers $m.selection_run_id $m.selection_member_id
}

$screeningStatuses = @{}
foreach ($s in $screening) { Add-MapSet $screeningStatuses $s.source_id $s.screening_status }

$cardFiles = Get-ChildItem -LiteralPath (Join-Path $RootPath '资料卡') -Recurse -File -Filter '*.md' | Where-Object {
    $_.Name -notin @('字段字典.md','模板.md','型号索引.md')
}
$objectHeaderCards = @{}
$objectMentionCards = @{}
foreach ($file in $cardFiles) {
    $relative = $file.FullName.Substring($RootPath.Length + 1).Replace('\','/')
    $allText = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $headText = (Get-Content -LiteralPath $file.FullName -Encoding UTF8 | Select-Object -First 30) -join "`n"
    foreach ($o in $objects) {
        $pattern = [regex]::Escape($o.object_id)
        if ($allText -match $pattern) { Add-MapSet $objectMentionCards $o.object_id $relative }
        if ($headText -match $pattern) { Add-MapSet $objectHeaderCards $o.object_id $relative }
    }
}

$completenessByObject = @{}
foreach ($c in $completeness) { Add-MapSet $completenessByObject $c.object_id $c.card_completeness_id }

$objectRows = foreach ($o in $objects) {
    $class = $classByObject[$o.object_id]
    $reason = switch ($o.object_type) {
        'architecture_generation' { '架构代际只用于解释训练/推理芯片的计算、数值、存储和互联机制；保留为证据支持，不单独计入芯片完成度。' }
        'die' { '裸片属于训练/推理芯片本体。' }
        'chiplet' { '芯粒属于训练/推理芯片本体。' }
        'package' { '当前对象被正式建模为单器件芯片或硅封装，而非板卡、云配置或系统；保留在芯片主线，未公开的封装构造继续标缺口。' }
        'module' { 'SXM、OAM 或 EAM 等板级模组不属于芯片本体，退出主线。' }
        'card' { 'PCIe 或其他加速卡属于板卡产品，不属于芯片本体，退出主线。' }
        'cloud_accelerator' { '云端 accelerator/device 是服务暴露的配置对象，不能替代物理芯片身份，退出主线。' }
        'cloud_instance' { '云实例、实例族或机器类型属于部署配置，退出主线。' }
        'server' { '服务器或计算托盘属于系统对象，退出主线。' }
        'rack' { '机架或参考机架属于系统对象，退出主线。' }
        'pod' { 'Pod、SuperPod 或超节点属于系统对象，退出主线。' }
        'cluster' { '集群属于系统对象，退出主线。' }
        'baseboard' { '底板属于系统承载对象，退出主线。' }
        'switch' { '交换设备属于系统互联对象，退出主线。' }
        default { '不属于已定义的裸片、芯粒、硅封装或架构支持对象，暂按退出主线处理。' }
    }
    $disposition = switch ($class) {
        'A' { 'retain_chip_mainline' }
        'B' { 'retain_architecture_support_only' }
        'C' { 'exit_mainline_keep_historical_audit' }
    }
    $sourceIds = @(Get-SetValues $objectSources $o.object_id)
    $selectionRunSet = New-StringSet
    $selectionMemberSet = New-StringSet
    foreach ($sourceId in $sourceIds) {
        foreach ($runId in @(Get-SetValues $sourceRuns $sourceId)) {
            [void]$selectionRunSet.Add($runId)
            foreach ($memberId in @(Get-SetValues $runMembers $runId)) {
                $member = $selectionMembers | Where-Object { $_.selection_member_id -eq $memberId } | Select-Object -First 1
                if ($null -ne $member -and $member.source_id -eq $sourceId) { [void]$selectionMemberSet.Add($memberId) }
            }
        }
    }
    foreach ($run in $selectionRuns | Where-Object { $_.scope_kind -eq 'object' -and $_.scope_id -eq $o.object_id }) {
        [void]$selectionRunSet.Add($run.selection_run_id)
    }
    [pscustomobject]@{
        object_id = $o.object_id
        vendor_id = $o.vendor_id
        canonical_label = $o.canonical_label
        object_type = $o.object_type
        current_review_status = $o.review_status
        scope_class = $class
        recommended_disposition = $disposition
        classification_reason = $reason
        component_count = @(Get-SetValues $objectComponents $o.object_id).Count
        link_count = @(Get-SetValues $objectLinks $o.object_id).Count
        precision_path_count = @(Get-SetValues $objectPaths $o.object_id).Count
        capability_count = @(Get-SetValues $objectCapabilities $o.object_id).Count
        topology_count = @(Get-SetValues $objectTopologies $o.object_id).Count
        fact_footprint_count = @(Get-SetValues $objectFacts $o.object_id).Count
        assertion_footprint_count = @(Get-SetValues $objectAssertions $o.object_id).Count
        requirement_footprint_count = @(Get-SetValues $objectRequirements $o.object_id).Count
        card_completeness_row_count = @(Get-SetValues $completenessByObject $o.object_id).Count
        header_mention_card_count = @(Get-SetValues $objectHeaderCards $o.object_id).Count
        header_mention_card_paths = (Get-SetValues $objectHeaderCards $o.object_id) -join ';'
        mentioning_card_count = @(Get-SetValues $objectMentionCards $o.object_id).Count
        selection_run_touch_count = @($selectionRunSet).Count
        selection_run_ids = (@($selectionRunSet | Sort-Object) -join ';')
        selection_member_touch_count = @($selectionMemberSet).Count
        distinct_asserted_source_count = $sourceIds.Count
        asserted_source_ids = $sourceIds -join ';'
        relation_count = @(Get-SetValues $objectRelations $o.object_id).Count
        relation_ids = (Get-SetValues $objectRelations $o.object_id) -join ';'
    }
}
$objectRows | Export-Csv -LiteralPath (Join-Path $outDir 'object-classification.csv') -NoTypeInformation -Encoding UTF8

$classImpactRows = foreach ($scopeClass in @('A','B','C')) {
    $classObjects = @($objectRows | Where-Object { $_.scope_class -eq $scopeClass })
    $factSet = New-StringSet
    $assertionSet = New-StringSet
    $requirementSet = New-StringSet
    $sourceSet = New-StringSet
    $relationSet = New-StringSet
    $componentSet = New-StringSet
    $linkSet = New-StringSet
    $pathSet = New-StringSet
    $capabilitySet = New-StringSet
    $topologySet = New-StringSet
    $cardCompletenessSet = New-StringSet
    $selectionRunSet = New-StringSet
    $selectionMemberSet = New-StringSet
    foreach ($row in $classObjects) {
        foreach ($value in @(Get-SetValues $objectFacts $row.object_id)) { [void]$factSet.Add($value) }
        foreach ($value in @(Get-SetValues $objectAssertions $row.object_id)) { [void]$assertionSet.Add($value) }
        foreach ($value in @(Get-SetValues $objectRequirements $row.object_id)) { [void]$requirementSet.Add($value) }
        foreach ($value in @(Get-SetValues $objectSources $row.object_id)) { [void]$sourceSet.Add($value) }
        foreach ($value in @(Get-SetValues $objectRelations $row.object_id)) { [void]$relationSet.Add($value) }
        foreach ($value in @(Get-SetValues $objectComponents $row.object_id)) { [void]$componentSet.Add($value) }
        foreach ($value in @(Get-SetValues $objectLinks $row.object_id)) { [void]$linkSet.Add($value) }
        foreach ($value in @(Get-SetValues $objectPaths $row.object_id)) { [void]$pathSet.Add($value) }
        foreach ($value in @(Get-SetValues $objectCapabilities $row.object_id)) { [void]$capabilitySet.Add($value) }
        foreach ($value in @(Get-SetValues $objectTopologies $row.object_id)) { [void]$topologySet.Add($value) }
        foreach ($value in @(Get-SetValues $completenessByObject $row.object_id)) { [void]$cardCompletenessSet.Add($value) }
        foreach ($value in @($row.selection_run_ids -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })) { [void]$selectionRunSet.Add($value) }
        foreach ($sourceId in @(Get-SetValues $objectSources $row.object_id)) {
            foreach ($runId in @(Get-SetValues $sourceRuns $sourceId)) {
                foreach ($memberId in @(Get-SetValues $runMembers $runId)) {
                    $member = $selectionMembers | Where-Object { $_.selection_member_id -eq $memberId } | Select-Object -First 1
                    if ($null -ne $member -and $member.source_id -eq $sourceId) { [void]$selectionMemberSet.Add($memberId) }
                }
            }
        }
    }
    [pscustomobject]@{
        scope_class = $scopeClass
        object_count = $classObjects.Count
        component_count = $componentSet.Count
        link_count = $linkSet.Count
        precision_path_count = $pathSet.Count
        capability_count = $capabilitySet.Count
        topology_count = $topologySet.Count
        unique_fact_footprint_count = $factSet.Count
        unique_assertion_footprint_count = $assertionSet.Count
        unique_requirement_footprint_count = $requirementSet.Count
        card_completeness_row_count = $cardCompletenessSet.Count
        card_object_count = @($classObjects | Where-Object { [int]$_.card_completeness_row_count -gt 0 }).Count
        distinct_asserted_source_count = $sourceSet.Count
        selection_run_touch_count = $selectionRunSet.Count
        selection_member_touch_count = $selectionMemberSet.Count
        relation_touch_count = $relationSet.Count
        overlap_note = '跨类关系事实、共享来源和组合 selection run 会同时计入相关类别；三个类别的影响计数不可直接相加为全库总数。'
    }
}
$classImpactRows | Export-Csv -LiteralPath (Join-Path $outDir 'class-impact-summary.csv') -NoTypeInformation -Encoding UTF8

$vendorRows = foreach ($group in ($objectRows | Group-Object vendor_id,scope_class | Sort-Object Name)) {
    $sample = $group.Group | Select-Object -First 1
    [pscustomobject]@{
        vendor_id = $sample.vendor_id
        scope_class = $sample.scope_class
        object_count = $group.Count
    }
}
$vendorRows | Export-Csv -LiteralPath (Join-Path $outDir 'vendor-scope-summary.csv') -NoTypeInformation -Encoding UTF8

$sourceRows = foreach ($s in $sources) {
    $objectIds = @(Get-SetValues $sourceObjects $s.source_id)
    $classes = New-StringSet
    foreach ($objectId in $objectIds) {
        if ($classByObject.ContainsKey($objectId)) { [void]$classes.Add($classByObject[$objectId]) }
    }
    $classValues = @($classes | Sort-Object)
    $hasMainline = ($classValues -contains 'A') -or ($classValues -contains 'B')
    $hasC = $classValues -contains 'C'
    if ($objectIds.Count -eq 0) {
        $disposition = 'audit_only_no_current_assertion'
    }
    elseif ($hasMainline -and $hasC) {
        $disposition = 'retain_mixed_mainline_support'
    }
    elseif ($hasMainline) {
        $disposition = 'retain_mainline_support'
    }
    else {
        $disposition = 'exit_mainline_c_only'
    }
    $isMediaOnly = $s.source_authority -notin @('first_party','peer_reviewed','independent_measurement')
    [pscustomobject]@{
        source_id = $s.source_id
        title = $s.title
        author_or_organization = $s.author_or_organization
        source_type = $s.source_type
        source_authority = $s.source_authority
        source_status = $s.source_status
        review_status = $s.review_status
        asserted_object_count = $objectIds.Count
        asserted_object_ids = $objectIds -join ';'
        asserted_scope_classes = $classValues -join ';'
        selection_run_count = @(Get-SetValues $sourceRuns $s.source_id).Count
        screening_statuses = (Get-SetValues $screeningStatuses $s.source_id) -join ';'
        media_only = if ($isMediaOnly) { 'yes' } else { 'no' }
        recommended_disposition = if ($isMediaOnly) { 'skip_media_only' } else { $disposition }
    }
}
$sourceRows | Export-Csv -LiteralPath (Join-Path $outDir 'source-scope-disposition.csv') -NoTypeInformation -Encoding UTF8

$relationRows = foreach ($rel in $relations) {
    $subjectClass = $classByObject[$rel.subject_object_id]
    $objectClass = $classByObject[$rel.object_object_id]
    $classes = @($subjectClass,$objectClass)
    $disposition = if ($classes -contains 'C') { 'exit_mainline_keep_historical_relation' } else { 'retain_mainline_or_architecture_support' }
    $relationFacts = @($facts | Where-Object { $_.object_relation_id -eq $rel.object_relation_id })
    $relationFactIds = @($relationFacts | ForEach-Object { $_.fact_id })
    $relationAssertions = @($assertions | Where-Object { $_.fact_id -in $relationFactIds })
    [pscustomobject]@{
        object_relation_id = $rel.object_relation_id
        subject_object_id = $rel.subject_object_id
        subject_scope_class = $subjectClass
        relation_type = $rel.relation_type
        object_object_id = $rel.object_object_id
        object_scope_class = $objectClass
        current_review_status = $rel.review_status
        fact_count = $relationFacts.Count
        assertion_count = $relationAssertions.Count
        recommended_disposition = $disposition
    }
}
$relationRows | Export-Csv -LiteralPath (Join-Path $outDir 'relation-scope-disposition.csv') -NoTypeInformation -Encoding UTF8

$summary = [ordered]@{
    snapshot_time = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
    object_total = $objects.Count
    class_A_chip_mainline = @($objectRows | Where-Object { $_.scope_class -eq 'A' }).Count
    class_B_architecture_support = @($objectRows | Where-Object { $_.scope_class -eq 'B' }).Count
    class_C_exit_mainline = @($objectRows | Where-Object { $_.scope_class -eq 'C' }).Count
    retained_A_plus_B = @($objectRows | Where-Object { $_.scope_class -in @('A','B') }).Count
    current_card_objects_by_completeness = @($objectRows | Where-Object { [int]$_.card_completeness_row_count -gt 0 }).Count
    retained_card_objects_A_plus_B = @($objectRows | Where-Object { $_.scope_class -in @('A','B') -and [int]$_.card_completeness_row_count -gt 0 }).Count
    exited_card_objects_C = @($objectRows | Where-Object { $_.scope_class -eq 'C' -and [int]$_.card_completeness_row_count -gt 0 }).Count
    formal_source_total = $sources.Count
    formal_media_only_count = @($sourceRows | Where-Object { $_.media_only -eq 'yes' }).Count
    source_mainline_or_mixed_count = @($sourceRows | Where-Object { $_.recommended_disposition -in @('retain_mainline_support','retain_mixed_mainline_support') }).Count
    source_C_only_count = @($sourceRows | Where-Object { $_.recommended_disposition -eq 'exit_mainline_c_only' }).Count
    source_no_assertion_count = @($sourceRows | Where-Object { $_.recommended_disposition -eq 'audit_only_no_current_assertion' }).Count
    relation_total = $relations.Count
    relation_retained_count = @($relationRows | Where-Object { $_.recommended_disposition -eq 'retain_mainline_or_architecture_support' }).Count
    relation_exited_count = @($relationRows | Where-Object { $_.recommended_disposition -eq 'exit_mainline_keep_historical_relation' }).Count
}
[System.IO.File]::WriteAllText((Join-Path $outDir 'scope-summary.json'), ($summary | ConvertTo-Json -Depth 4), [System.Text.UTF8Encoding]::new($false))

Write-Output "OBJECT_ROWS=$($objectRows.Count)"
Write-Output "SOURCE_ROWS=$($sourceRows.Count)"
Write-Output "RELATION_ROWS=$($relationRows.Count)"
Write-Output ($summary | ConvertTo-Json -Compress)