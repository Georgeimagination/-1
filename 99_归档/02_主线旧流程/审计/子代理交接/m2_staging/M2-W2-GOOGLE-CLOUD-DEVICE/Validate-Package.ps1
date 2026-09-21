[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$script:CheckCount = 0
$script:Errors = [System.Collections.Generic.List[string]]::new()

function Test-Rule {
    param([bool]$Condition, [string]$Message)
    $script:CheckCount++
    if (-not $Condition) {
        $script:Errors.Add($Message)
    }
}

$packageRoot = $PSScriptRoot
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $packageRoot '..\..\..\..')).Path
$required = @(
    'README.md',
    'object-scope-candidates.csv',
    'relationship-candidates.csv',
    'deferred-dispositions.csv',
    'configuration-row-dispositions.csv',
    'source-candidates.csv',
    'source-selection-candidates.csv',
    'source-freeze.md',
    'merge-instructions.md'
)
foreach ($name in $required) {
    Test-Rule (Test-Path -LiteralPath (Join-Path $packageRoot $name) -PathType Leaf) "缺少包内文件：$name"
}

$objects = Import-Csv -LiteralPath (Join-Path $packageRoot 'object-scope-candidates.csv')
$relations = Import-Csv -LiteralPath (Join-Path $packageRoot 'relationship-candidates.csv')
$deferred = Import-Csv -LiteralPath (Join-Path $packageRoot 'deferred-dispositions.csv')
$config = Import-Csv -LiteralPath (Join-Path $packageRoot 'configuration-row-dispositions.csv')
$sources = Import-Csv -LiteralPath (Join-Path $packageRoot 'source-candidates.csv')
$selection = Import-Csv -LiteralPath (Join-Path $packageRoot 'source-selection-candidates.csv')

Test-Rule ($objects.Count -eq 3) '对象候选必须恰好为 3 行'
Test-Rule (($objects.proposed_object_id | Sort-Object -Unique).Count -eq 3) '对象候选 ID 不唯一'
Test-Rule (($objects | Where-Object final_object_type -ne 'cloud_accelerator').Count -eq 0) '对象层级必须全部为 cloud_accelerator'
Test-Rule (($objects | Where-Object source_gate_status -ne 'accept_with_caveat').Count -eq 0) '来源门状态必须为 accept_with_caveat'
Test-Rule (($objects | Where-Object proposed_formal_review_status -ne 'needs_resolution').Count -eq 0) '正式预留状态必须为 needs_resolution'

Test-Rule ($relations.Count -eq 3) '架构关系候选必须恰好为 3 行'
Test-Rule (($relations.candidate_relation_id | Sort-Object -Unique).Count -eq 3) '关系候选 ID 不唯一'
Test-Rule (($relations | Where-Object relation_type -ne 'implements_architecture').Count -eq 0) '三条关系必须全部为 implements_architecture'
foreach ($relation in $relations) {
    Test-Rule ($objects.proposed_object_id -contains $relation.subject_object_id) "关系主体不在对象候选中：$($relation.candidate_relation_id)"
}

Test-Rule ($deferred.Count -eq 15) 'deferred 处置应为 15 个持久项'
Test-Rule (($deferred.disposition_id | Sort-Object -Unique).Count -eq 15) 'deferred disposition_id 不唯一'
Test-Rule (($deferred.parent_deferred_id | Sort-Object -Unique).Count -eq 14) 'deferred 父主键应恰好覆盖 14 行'
$v5p03 = @($deferred | Where-Object parent_deferred_id -eq 'DEF-M2GA-GV5P-03')
Test-Rule ($v5p03.Count -eq 2) 'GV5P-03 必须拆成两个子处置项'
Test-Rule (($v5p03.raw_value -contains '95 GiB') -and ($v5p03.raw_value -contains '96 GiB')) 'GV5P-03 必须保留 95 GiB 与 96 GiB 两个原值'
Test-Rule (($v5p03 | Where-Object notes -notmatch '不得推导 1 GiB 预留').Count -eq 0) 'GV5P-03 两分支都必须禁止推导 1 GiB 预留'
Test-Rule (($deferred | Where-Object branch_label -eq 'complete_cloud_device_item').Count -eq 9) '应有 9 条完整云端器件待办'
Test-Rule (($deferred | Where-Object action_in_this_package -eq 'route_to_future_cloud_device_fact_package').Count -eq 10) '云端事实包应承接 9 条完整项加 95 GiB 子项'
Test-Rule (($deferred | Where-Object action_in_this_package -eq 'defer_to_physical_package_identity_gate').Count -eq 5) '物理 package 门应承接 4 条完整项加 96 GiB 子项'

Test-Rule ($config.Count -eq 7) '配置行处置应为 7 组'
Test-Rule (($config | Where-Object device_value_action -ne 'do_not_write_to_cloud_accelerator').Count -eq 0) '配置聚合值不得写入 cloud_accelerator'
Test-Rule (@($config | Where-Object formal_fact_action -eq 'relation_candidate_only_no_quantity_fact').Count -eq 1) 'CT6E 家族关系候选应恰好 1 行且不带数量事实'
Test-Rule (($config | Where-Object config_group_id -eq 'CFGDISP-GOOGLE-V6E-MACHINE-TYPES').structured_owner_rule -match '独立 cloud_instance') 'v6e 命名机器类型必须先升为独立 cloud_instance'

$reserved = @(
    'SFAM-M2-W2-G-TPU-MACHINES',
    'SRC-M2-W2-G-TPU-MACHINES-20260813',
    'END-M2-W2-G-TPU-MACHINES-EXTRACT-20260813'
)
foreach ($id in $reserved) {
    Test-Rule ($sources.proposed_id -contains $id) "缺少总控预留来源候选：$id"
}
$extracts = @($sources | Where-Object { $_.candidate_record_kind -eq 'endpoint' -and $_.local_staging_path -ne '' })
Test-Rule ($extracts.Count -eq 6) '应有 6 个本地内容提取 endpoint 候选'
foreach ($endpoint in $extracts) {
    Test-Rule ($endpoint.source_type_or_endpoint_type -eq 'other') "内容提取 endpoint 类型不是 other：$($endpoint.proposed_id)"
    Test-Rule ($endpoint.is_preferred_endpoint -eq 'false') "内容提取 endpoint 不能是 preferred：$($endpoint.proposed_id)"
    Test-Rule ($endpoint.notes -eq 'renderer-extracted text wrapped as HTML / not upstream response body') "内容提取 endpoint notes 不符合总控裁决：$($endpoint.proposed_id)"
    $localPath = Join-Path $packageRoot $endpoint.local_staging_path
    Test-Rule (Test-Path -LiteralPath $localPath -PathType Leaf) "内容提取文件不存在：$($endpoint.local_staging_path)"
    if (Test-Path -LiteralPath $localPath -PathType Leaf) {
        $item = Get-Item -LiteralPath $localPath
        $hash = (Get-FileHash -LiteralPath $localPath -Algorithm SHA256).Hash
        Test-Rule ($item.Length -eq [int64]$endpoint.byte_count) "字节数不匹配：$($endpoint.proposed_id)"
        Test-Rule ($hash -eq $endpoint.content_fingerprint_or_sha256) "SHA-256 不匹配：$($endpoint.proposed_id)"
    }
}
$primary = @($sources | Where-Object proposed_id -eq 'END-M2-W2-G-TPU-MACHINES-PRIMARY')
Test-Rule ($primary.Count -eq 1) '缺少 tpu-machines 原 html_page 入口候选'
Test-Rule (($primary.source_type_or_endpoint_type -eq 'html_page') -and ($primary.local_staging_path -eq '')) '原 html_page 入口不能被本地 extract 替代'

Test-Rule (($selection | Where-Object { $_.candidate_kind -eq 'selection_member' -and $_.scope_id -eq 'SELRUN-M2W2-GOOGLE-CLOUD-DEVICE-20260813' }).Count -eq 4) '器件反向移除候选应有 4 个成员'
Test-Rule (@($selection | Where-Object { $_.candidate_kind -eq 'screening' -and $_.source_id -eq 'SRC-M2-GA-G09' -and $_.status_or_role -eq 'selected' }).Count -eq 1) 'G09 必须在器件事实范围改为 selected 候选'
Test-Rule (@($selection | Where-Object { $_.candidate_kind -eq 'screening' -and $_.source_id -eq 'SRC-M2-W2-G-TPU-MACHINES-20260813' -and $_.status_or_role -eq 'out_of_scope' }).Count -eq 1) 'tpu-machines 在器件事实范围必须为 out_of_scope'

$formalObjects = Import-Csv -LiteralPath (Join-Path $projectRoot '数据\objects.csv')
$formalRelations = Import-Csv -LiteralPath (Join-Path $projectRoot '数据\object-relations.csv')
$formalSources = Import-Csv -LiteralPath (Join-Path $projectRoot '最小参考资料库\sources.csv')
$formalEndpoints = Import-Csv -LiteralPath (Join-Path $projectRoot '最小参考资料库\source-endpoints.csv')
$formalFamilies = Import-Csv -LiteralPath (Join-Path $projectRoot '最小参考资料库\source-families.csv')
foreach ($object in $objects) {
    Test-Rule (-not ($formalObjects.object_id -contains $object.proposed_object_id)) "对象候选已与正式 ID 碰撞：$($object.proposed_object_id)"
    Test-Rule (-not ($formalObjects.curator_slug -contains $object.curator_slug)) "对象候选 slug 已与正式值碰撞：$($object.curator_slug)"
    Test-Rule (($formalObjects | Where-Object object_id -eq $object.architecture_id).review_status -eq 'reviewed') "架构端点不存在或未 reviewed：$($object.architecture_id)"
}
foreach ($relation in $relations) {
    Test-Rule (-not ($formalRelations.object_relation_id -contains $relation.candidate_relation_id)) "关系候选已与正式 ID 碰撞：$($relation.candidate_relation_id)"
    Test-Rule (-not ($formalRelations.relation_fingerprint -contains $relation.relation_fingerprint)) "关系候选指纹已与正式值碰撞：$($relation.relation_fingerprint)"
}
Test-Rule (-not ($formalFamilies.source_family_id -contains 'SFAM-M2-W2-G-TPU-MACHINES')) 'tpu-machines source family 候选已与正式 ID 碰撞'
Test-Rule (-not ($formalSources.source_id -contains 'SRC-M2-W2-G-TPU-MACHINES-20260813')) 'tpu-machines source 候选已与正式 ID 碰撞'
foreach ($endpoint in @($sources | Where-Object candidate_record_kind -eq 'endpoint')) {
    Test-Rule (-not ($formalEndpoints.endpoint_id -contains $endpoint.proposed_id)) "新 endpoint 候选已与正式 ID 碰撞：$($endpoint.proposed_id)"
}
$familyRelation = @($config | Where-Object config_group_id -eq 'CFGDISP-GOOGLE-V6E-FAMILY-RELATION')
Test-Rule (($formalObjects | Where-Object object_id -eq 'OBJ-GOOGLE-CT6E-STANDARD-FAMILY').review_status -eq 'reviewed') 'CT6E 正式家族对象不存在或未 reviewed'
Test-Rule (-not ($formalRelations.object_relation_id -contains $familyRelation.proposed_relation_id)) 'CT6E 家族关系候选 ID 已与正式值碰撞'

$freeze = Get-Content -LiteralPath (Join-Path $packageRoot 'source-freeze.md') -Raw -Encoding UTF8
Test-Rule ($freeze -match 'accept_with_caveat / content_extract_frozen / upstream_body_pending') 'source-freeze 状态不符合总控裁决'
Test-Rule ($freeze -match '不得把本文件标为 `web_snapshot`') 'source-freeze 缺少禁止标成 web_snapshot 的说明'

if ($script:Errors.Count -gt 0) {
    Write-Output "FAIL: $($script:Errors.Count) errors in $($script:CheckCount) checks."
    $script:Errors | ForEach-Object { Write-Output "- $_" }
    exit 1
}

Write-Output "PASS: M2-W2-GOOGLE-CLOUD-DEVICE preparation package; $($script:CheckCount) checks executed."
Write-Output 'Scope: 3 cloud_accelerator candidates, 3 implements_architecture relations, 15 deferred dispositions, 7 configuration groups, 6 hashed content extracts.'
exit 0
