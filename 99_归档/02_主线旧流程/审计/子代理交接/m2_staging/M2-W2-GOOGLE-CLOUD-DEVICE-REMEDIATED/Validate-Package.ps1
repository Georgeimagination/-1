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

function Test-SetEqual {
    param([object[]]$Actual, [object[]]$Expected, [string]$Message)
    $a = @($Actual | Sort-Object -Unique)
    $e = @($Expected | Sort-Object -Unique)
    $equal = ($a.Count -eq $e.Count) -and (($a -join "`n") -eq ($e -join "`n"))
    Test-Rule $equal $Message
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
    'remote-retrieval-log.md',
    'merge-instructions.md',
    'validation-report.md',
    'handoff.md',
    'package-manifest.csv',
    'package-freeze.sha256'
)
foreach ($name in $required) {
    Test-Rule (Test-Path -LiteralPath (Join-Path $packageRoot $name) -PathType Leaf) "缺少包内文件：$name"
}

$objects = @(Import-Csv -LiteralPath (Join-Path $packageRoot 'object-scope-candidates.csv'))
$relations = @(Import-Csv -LiteralPath (Join-Path $packageRoot 'relationship-candidates.csv'))
$deferred = @(Import-Csv -LiteralPath (Join-Path $packageRoot 'deferred-dispositions.csv'))
$config = @(Import-Csv -LiteralPath (Join-Path $packageRoot 'configuration-row-dispositions.csv'))
$sources = @(Import-Csv -LiteralPath (Join-Path $packageRoot 'source-candidates.csv'))
$selection = @(Import-Csv -LiteralPath (Join-Path $packageRoot 'source-selection-candidates.csv'))

Test-Rule ($objects.Count -eq 3) '对象范围引用必须恰好为 3 行'
Test-Rule (@($objects.proposed_object_id | Sort-Object -Unique).Count -eq 3) '对象候选 ID 不唯一'
Test-Rule (@($objects | Where-Object { $_.decision -ne 'reference_formal_reservation' }).Count -eq 0) '对象行必须标为 reference_formal_reservation'
Test-Rule (@($objects | Where-Object { $_.final_object_type -ne 'cloud_accelerator' }).Count -eq 0) '对象层级必须全部为 cloud_accelerator'
Test-Rule (@($objects | Where-Object { $_.proposed_formal_review_status -ne 'needs_resolution' }).Count -eq 0) '对象正式状态必须保持 needs_resolution'
Test-Rule (@($objects | Where-Object { $_.source_gate_status -ne 'accept_with_caveat' }).Count -eq 0) '对象来源门必须保持 accept_with_caveat'

Test-Rule ($relations.Count -eq 3) '架构关系引用必须恰好为 3 行'
Test-Rule (@($relations.candidate_relation_id | Sort-Object -Unique).Count -eq 3) '关系候选 ID 不唯一'
Test-Rule (@($relations | Where-Object { $_.relation_type -ne 'implements_architecture' }).Count -eq 0) '三条关系必须全部为 implements_architecture'
foreach ($relation in $relations) {
    Test-Rule ($objects.proposed_object_id -contains $relation.subject_object_id) "关系主体不在对象范围引用中：$($relation.candidate_relation_id)"
}

Test-Rule ($deferred.Count -eq 15) 'deferred 处置应为 15 个持久项'
Test-Rule (@($deferred.disposition_id | Sort-Object -Unique).Count -eq 15) 'deferred disposition_id 不唯一'
Test-Rule (@($deferred.parent_deferred_id | Sort-Object -Unique).Count -eq 14) 'deferred 父主键应恰好覆盖 14 行'
$v5p03 = @($deferred | Where-Object { $_.parent_deferred_id -eq 'DEF-M2GA-GV5P-03' })
Test-Rule ($v5p03.Count -eq 2) 'GV5P-03 必须拆成两个子处置项'
Test-Rule (($v5p03.raw_value -contains '95 GiB') -and ($v5p03.raw_value -contains '96 GiB')) 'GV5P-03 必须保留 95 GiB 与 96 GiB 两个原值'
Test-Rule (@($v5p03 | Where-Object { $_.notes -notmatch '不得推导 1 GiB 预留' }).Count -eq 0) 'GV5P-03 两分支都必须禁止推导 1 GiB 预留'
Test-Rule (@($deferred | Where-Object { $_.branch_label -eq 'complete_cloud_device_item' }).Count -eq 9) '应有 9 条完整云端器件待办'
Test-Rule (@($deferred | Where-Object { $_.action_in_this_package -eq 'route_to_future_cloud_device_fact_package' }).Count -eq 10) '云端事实包应承接 9 条完整项和 95 GiB 子项'
Test-Rule (@($deferred | Where-Object { $_.action_in_this_package -eq 'defer_to_physical_package_identity_gate' }).Count -eq 5) '物理 package 门应承接 4 条完整项和 96 GiB 子项'
$v6eComponent = @($deferred | Where-Object { $_.disposition_id -eq 'DISP-M2W2-G-DEF-M2GA-GV6E-01' })
Test-Rule ($v6eComponent.Count -eq 1) '缺少唯一的 v6e 组件处置行'
if ($v6eComponent.Count -eq 1) {
    Test-Rule ($v6eComponent[0].source_id -match 'SRC-M2-W2-G-TPU-MACHINES-20260813') 'v6e 组件行必须引用 tpu-machines'
    Test-Rule ($v6eComponent[0].source_id -notmatch 'SRC-M2-GA-G15') 'v6e 组件行不得继续引用不可用 G15 endpoint'
    Test-Rule ($v6eComponent[0].source_locator -match 'L624-L638') 'v6e 组件行缺少 tpu-machines 固定定位'
}

Test-Rule ($config.Count -eq 7) '配置行处置应为 7 组'
Test-Rule (@($config | Where-Object { $_.device_value_action -ne 'do_not_write_to_cloud_accelerator' }).Count -eq 0) '配置聚合值不得写入 cloud_accelerator'
Test-Rule (@($config | Where-Object { $_.formal_fact_action -eq 'relation_candidate_only_no_quantity_fact' }).Count -eq 1) 'CT6E 家族关系候选应恰好 1 行且不带数量事实'
$v5eConfig = @($config | Where-Object { $_.config_group_id -eq 'CFGDISP-GOOGLE-V5E-MACHINE-TYPES' })
Test-Rule ($v5eConfig.Count -eq 1) '缺少唯一的 v5e machine-types 配置行'
if ($v5eConfig.Count -eq 1) {
    Test-Rule ($v5eConfig[0].source_ids -eq 'SRC-M2-GA-G08') 'v5e machine-types 来源必须只保留 G08'
    Test-Rule ($v5eConfig[0].source_ids -notmatch 'TPU-MACHINES') 'v5e machine-types 不得引用 tpu-machines'
}

$reserved = @(
    'SFAM-M2-W2-G-TPU-MACHINES',
    'SRC-M2-W2-G-TPU-MACHINES-20260813',
    'END-M2-W2-G-TPU-MACHINES-EXTRACT-20260813'
)
foreach ($id in $reserved) {
    Test-Rule ($sources.proposed_id -contains $id) "缺少总控预留来源候选：$id"
}
Test-Rule (@($sources.proposed_id | Sort-Object -Unique).Count -eq $sources.Count) '来源候选 ID 不唯一'
$extracts = @($sources | Where-Object { $_.candidate_record_kind -eq 'endpoint' -and $_.local_staging_path -ne '' })
Test-Rule ($extracts.Count -eq 6) '应保留 6 个本地内容提取，其中 1 个为 G15 局部提取'
$g15Endpoint = @($extracts | Where-Object { $_.proposed_id -eq 'END-M2-GA-G15-EXTRACT-20260813' })
$usableExtracts = @($extracts | Where-Object { $_.proposed_id -ne 'END-M2-GA-G15-EXTRACT-20260813' })
Test-Rule ($g15Endpoint.Count -eq 1) '缺少唯一的 G15 局部提取候选'
Test-Rule ($usableExtracts.Count -eq 5) '可用内容提取必须恰好为 5 个'
foreach ($endpoint in $extracts) {
    Test-Rule ($endpoint.source_type_or_endpoint_type -eq 'other') "内容提取 endpoint 类型不是 other：$($endpoint.proposed_id)"
    Test-Rule ($endpoint.is_preferred_endpoint -eq 'false') "内容提取 endpoint 不能是 preferred：$($endpoint.proposed_id)"
    $localPath = Join-Path $packageRoot $endpoint.local_staging_path
    Test-Rule (Test-Path -LiteralPath $localPath -PathType Leaf) "内容提取文件不存在：$($endpoint.local_staging_path)"
    if (Test-Path -LiteralPath $localPath -PathType Leaf) {
        $item = Get-Item -LiteralPath $localPath
        $hash = (Get-FileHash -LiteralPath $localPath -Algorithm SHA256).Hash
        Test-Rule ($item.Length -eq [int64]$endpoint.byte_count) "字节数不匹配：$($endpoint.proposed_id)"
        Test-Rule ($hash -eq $endpoint.content_fingerprint_or_sha256) "SHA-256 不匹配：$($endpoint.proposed_id)"
    }
}
foreach ($endpoint in $usableExtracts) {
    Test-Rule ($endpoint.notes -eq 'renderer-extracted text wrapped as HTML / not upstream response body') "可用提取 notes 不符合边界：$($endpoint.proposed_id)"
    Test-Rule ($endpoint.source_or_accessibility_status -eq 'accessible') "可用提取必须为 accessible：$($endpoint.proposed_id)"
    Test-Rule ($endpoint.proposed_formal_path -ne '') "可用提取缺少正式拟落路径：$($endpoint.proposed_id)"
}
if ($g15Endpoint.Count -eq 1) {
    Test-Rule ($g15Endpoint[0].source_or_accessibility_status -eq 'pending_verification') 'G15 局部提取必须保持 pending_verification'
    Test-Rule ($g15Endpoint[0].proposed_formal_path -eq '') 'G15 局部提取不得填写正式拟落路径'
    Test-Rule ($g15Endpoint[0].notes -match 'partial') 'G15 notes 必须明确 partial'
    Test-Rule ($g15Endpoint[0].notes -match 'missing L0-L147 including L69-L87') 'G15 notes 必须写出缺失范围'
    Test-Rule ($g15Endpoint[0].notes -match 'not usable for evidence or formal endpoint merge') 'G15 notes 必须禁止证据和正式合并'
}
$primary = @($sources | Where-Object { $_.proposed_id -eq 'END-M2-W2-G-TPU-MACHINES-PRIMARY' })
Test-Rule ($primary.Count -eq 1) '缺少 tpu-machines 原 html_page 入口候选'
if ($primary.Count -eq 1) {
    Test-Rule (($primary[0].source_type_or_endpoint_type -eq 'html_page') -and ($primary[0].local_staging_path -eq '')) '原 html_page 入口不能被本地 extract 替代'
}

$g05Text = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $packageRoot 'snapshots\2026-08-13\google-cloud-tpu-architecture-2026-08-13.html')
$g08Text = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $packageRoot 'snapshots\2026-08-13\google-cloud-tpu-v5e-2026-08-13.html')
$g09Text = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $packageRoot 'snapshots\2026-08-13\google-cloud-tpu-v5p-2026-08-13.html')
$g10Text = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $packageRoot 'snapshots\2026-08-13\google-cloud-tpu-v6e-2026-08-13.html')
$tpuMachinesText = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $packageRoot 'snapshots\2026-08-13\google-cloud-tpu-machines-2026-08-13.html')
$g15Text = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $packageRoot 'snapshots\2026-08-13\openxla-sparsecore-2026-08-13.html')

Test-Rule ($g05Text -match '(?m)^L211:.*v6e has two SparseCores per chip') 'G05 固定文件缺少 v6e 2 SparseCore 定位'
Test-Rule (($g08Text -match '(?m)^L144: Each v5e chip contains one TensorCore') -and ($g08Text -match '(?m)^L154: Peak compute per chip') -and ($g08Text -match '(?m)^L158: Bidirectional inter-chip interconnect')) 'G08 固定文件缺少器件规格定位'
Test-Rule (($g09Text -match '(?m)^L149: Peak compute per chip') -and ($g09Text -match '(?m)^L156: Number of SparseCores per chip') -and ($g09Text -match '(?m)^L159: Interconnect topology')) 'G09 固定文件缺少器件规格或拓扑定位'
Test-Rule (($g10Text -match '(?m)^L143: Each v6e chip contains one TensorCore') -and ($g10Text -match '(?m)^L148: Peak compute per chip \(Int8\)') -and ($g10Text -match '(?m)^L152: ICI ports per chip') -and ($g10Text -match '(?m)^L156: Interconnect topology')) 'G10 固定文件缺少器件规格或拓扑定位'
Test-Rule (($tpuMachinesText -match '(?m)^L518: Compute Engine supports the following TPU versions:') -and ($tpuMachinesText -match '(?m)^L520:.*TPU7x') -and ($tpuMachinesText -match '(?m)^L521:.*TPU v6e') -and ($tpuMachinesText -match '(?m)^L522:.*TPU v5p')) 'tpu-machines 缺少版本范围定位'
Test-Rule ($tpuMachinesText -notmatch '(?m)^L52[0-3]:.*v5e') 'tpu-machines 版本范围不应包含 v5e'
$perChipMarkers = @(
    '^L624: ### TPU architecture specifications',
    '^L630: Peak compute per chip \(BF16\)',
    '^L631: Peak compute per chip \(FP8\)',
    '^L632: HBM capacity per chip',
    '^L633: HBM bandwidth per chip',
    '^L636: Number of TensorCores per chip',
    '^L637: Number of SparseCores per chip',
    '^L638: Bidirectional inter-chip interconnect \(ICI\) bandwidth per chip',
    '^L639: Data center network \(DCN\) bandwidth per chip'
)
foreach ($pattern in $perChipMarkers) {
    Test-Rule ($tpuMachinesText -match "(?m)$pattern") "tpu-machines 缺少定位：$pattern"
}
$firstG15Marker = [regex]::Match($g15Text, '(?m)^L(?<line>[0-9]+):')
Test-Rule ($firstG15Marker.Success) 'G15 局部文件没有页面行标记'
if ($firstG15Marker.Success) {
    Test-Rule ($firstG15Marker.Groups['line'].Value -eq '148') 'G15 局部文件的首行标记必须是 L148'
}
Test-Rule ($g15Text -notmatch '(?m)^L(?:69|7[0-9]|8[0-7]):') 'G15 局部文件不应冒充含有 L69-L87'
Test-Rule ($g15Text -match '(?m)^L409:') 'G15 局部文件应保留末尾 L409'

$runId = 'SELRUN-M2W2-GOOGLE-CLOUD-DEVICE-20260813-R1'
$runs = @($selection | Where-Object { $_.candidate_kind -eq 'selection_run' })
Test-Rule ($runs.Count -eq 1) '来源选择候选必须恰好有一个 selection run'
if ($runs.Count -eq 1) {
    Test-Rule ($runs[0].candidate_id -eq $runId) 'selection run ID 不符合修复版 R1'
    Test-Rule ($runs[0].status_or_role -eq 'draft') 'selection run 在独立复核前必须保持 draft'
    Test-Rule ($runs[0].rationale -match '六源池') 'selection run 必须说明六源候选池'
}
$sixSources = @(
    'SRC-M2-GA-G05',
    'SRC-M2-GA-G08',
    'SRC-M2-GA-G09',
    'SRC-M2-GA-G10',
    'SRC-M2-GA-G15',
    'SRC-M2-W2-G-TPU-MACHINES-20260813'
)
$poolScreenings = @($selection | Where-Object { $_.candidate_kind -eq 'screening' -and $_.scope_id -eq 'M2-W2-GOOGLE-CLOUD-DEVICE' -and $_.source_id -in $sixSources })
Test-Rule ($poolScreenings.Count -eq 6) '器件候选池必须包含 G05/G08/G09/G10/G15/tpu-machines 六源'
Test-SetEqual $poolScreenings.source_id $sixSources '器件六源候选池集合不闭合'
function Test-ScreeningStatus {
    param([string]$SourceId, [string]$ExpectedStatus)
    $rows = @($selection | Where-Object { $_.candidate_kind -eq 'screening' -and $_.scope_id -eq 'M2-W2-GOOGLE-CLOUD-DEVICE' -and $_.source_id -eq $SourceId })
    Test-Rule ($rows.Count -eq 1) "screening 行不是唯一：$SourceId"
    if ($rows.Count -eq 1) {
        Test-Rule ($rows[0].status_or_role -eq $ExpectedStatus) "screening 状态错误：$SourceId"
    }
}
Test-ScreeningStatus 'SRC-M2-GA-G05' 'redundant_covered'
Test-ScreeningStatus 'SRC-M2-GA-G08' 'selected'
Test-ScreeningStatus 'SRC-M2-GA-G09' 'selected'
Test-ScreeningStatus 'SRC-M2-GA-G10' 'selected'
Test-ScreeningStatus 'SRC-M2-GA-G15' 'redundant_covered'
Test-ScreeningStatus 'SRC-M2-W2-G-TPU-MACHINES-20260813' 'selected'
Test-Rule (@($selection | Where-Object { $_.candidate_id -eq 'SCREEN-M2W2-G-TPUMACH-DEVICE' -and $_.status_or_role -eq 'out_of_scope' }).Count -eq 0) 'tpu-machines 不得继续标为器件 out_of_scope'

$members = @($selection | Where-Object { $_.candidate_kind -eq 'selection_member' -and $_.scope_id -eq $runId })
$expectedMembers = @('SRC-M2-GA-G08','SRC-M2-GA-G09','SRC-M2-GA-G10','SRC-M2-W2-G-TPU-MACHINES-20260813')
Test-Rule ($members.Count -eq 4) '修复版反向移除成员必须恰好为 4 个'
Test-SetEqual $members.source_id $expectedMembers '修复版反向移除成员集合错误'
Test-Rule (@($members | Where-Object { $_.source_id -eq 'SRC-M2-GA-G15' }).Count -eq 0) 'G15 不得进入选择成员'
Test-Rule (@($members | Where-Object { $_.source_id -eq 'SRC-M2-W2-G-TPU-MACHINES-20260813' }).Count -eq 1) 'tpu-machines 必须进入选择成员'

$coverage = @($selection | Where-Object { $_.candidate_kind -eq 'coverage_candidate' })
Test-Rule ($coverage.Count -eq 4) '单源覆盖候选必须恰好为 4 行'
Test-Rule (@($coverage.candidate_id | Sort-Object -Unique).Count -eq 4) 'coverage candidate ID 不唯一'
foreach ($row in $coverage) {
    Test-Rule ($row.paired_source_ids -ne '') "coverage 缺少 covering source：$($row.candidate_id)"
    Test-Rule ($row.paired_source_ids -notmatch '\|') "coverage 不能组合多个 covering source：$($row.candidate_id)"
    Test-Rule ($row.status_or_role -eq 'fully_covered') "coverage 状态不是 fully_covered：$($row.candidate_id)"
}
Test-Rule (@($coverage | Where-Object { $_.source_id -eq 'SRC-M2-GA-G15' }).Count -eq 2) 'G15 SparseCore 覆盖必须拆为两行'
Test-Rule (@($coverage | Where-Object { $_.source_id -eq 'SRC-M2-GA-G05' }).Count -eq 2) 'G05 SparseCore 覆盖必须拆为两行'
Test-Rule (@($selection | Where-Object { $_.candidate_id -eq 'BOUNDARY-M2W2-G-G15-V5P96' -and $_.status_or_role -eq 'out_of_scope' }).Count -eq 1) 'G15 96 GiB 必须留在物理 package 边界'
$tpuConfigScreen = @($selection | Where-Object { $_.candidate_id -eq 'SCREEN-M2W2-G-TPUMACH-CONFIG' })
Test-Rule (($tpuConfigScreen.Count -eq 1) -and ($tpuConfigScreen[0].status_or_role -eq 'selected')) 'tpu-machines 配置范围 screening 必须保留 selected'

$formalObjects = @(Import-Csv -LiteralPath (Join-Path $projectRoot '数据\objects.csv'))
$formalRelations = @(Import-Csv -LiteralPath (Join-Path $projectRoot '数据\object-relations.csv'))
$formalSources = @(Import-Csv -LiteralPath (Join-Path $projectRoot '最小参考资料库\sources.csv'))
$formalEndpoints = @(Import-Csv -LiteralPath (Join-Path $projectRoot '最小参考资料库\source-endpoints.csv'))
$formalFamilies = @(Import-Csv -LiteralPath (Join-Path $projectRoot '最小参考资料库\source-families.csv'))
foreach ($object in $objects) {
    $formal = @($formalObjects | Where-Object { $_.object_id -eq $object.proposed_object_id })
    Test-Rule ($formal.Count -eq 1) "总控预留对象不存在或不唯一：$($object.proposed_object_id)"
    if ($formal.Count -eq 1) {
        Test-Rule ($formal[0].vendor_id -eq $object.final_vendor_id) "正式对象 vendor 不匹配：$($object.proposed_object_id)"
        Test-Rule ($formal[0].canonical_label -eq $object.canonical_label) "正式对象 label 不匹配：$($object.proposed_object_id)"
        Test-Rule ($formal[0].object_type -eq $object.final_object_type) "正式对象 type 不匹配：$($object.proposed_object_id)"
        Test-Rule ($formal[0].curator_slug -eq $object.curator_slug) "正式对象 slug 不匹配：$($object.proposed_object_id)"
        Test-Rule ($formal[0].review_status -eq 'needs_resolution') "正式对象状态不是 needs_resolution：$($object.proposed_object_id)"
    }
    $arch = @($formalObjects | Where-Object { $_.object_id -eq $object.architecture_id })
    Test-Rule (($arch.Count -eq 1) -and ($arch[0].review_status -eq 'reviewed')) "架构端点不存在或未 reviewed：$($object.architecture_id)"
}
foreach ($relation in $relations) {
    $formal = @($formalRelations | Where-Object { $_.object_relation_id -eq $relation.candidate_relation_id })
    Test-Rule ($formal.Count -eq 1) "总控预留关系不存在或不唯一：$($relation.candidate_relation_id)"
    if ($formal.Count -eq 1) {
        Test-Rule ($formal[0].subject_object_id -eq $relation.subject_object_id) "正式关系 subject 不匹配：$($relation.candidate_relation_id)"
        Test-Rule ($formal[0].relation_type -eq $relation.relation_type) "正式关系 type 不匹配：$($relation.candidate_relation_id)"
        Test-Rule ($formal[0].object_object_id -eq $relation.object_object_id) "正式关系 object 不匹配：$($relation.candidate_relation_id)"
        Test-Rule ($formal[0].relation_fingerprint -eq $relation.relation_fingerprint) "正式关系 fingerprint 不匹配：$($relation.candidate_relation_id)"
        Test-Rule ($formal[0].review_status -eq 'needs_resolution') "正式关系状态不是 needs_resolution：$($relation.candidate_relation_id)"
    }
}
Test-Rule (@($formalFamilies | Where-Object { $_.source_family_id -eq 'SFAM-M2-W2-G-TPU-MACHINES' }).Count -eq 0) 'tpu-machines family 尚不应已写入正式库'
Test-Rule (@($formalSources | Where-Object { $_.source_id -eq 'SRC-M2-W2-G-TPU-MACHINES-20260813' }).Count -eq 0) 'tpu-machines source 尚不应已写入正式库'
foreach ($endpoint in @($sources | Where-Object { $_.candidate_record_kind -eq 'endpoint' })) {
    Test-Rule (@($formalEndpoints | Where-Object { $_.endpoint_id -eq $endpoint.proposed_id }).Count -eq 0) "新 endpoint 候选尚不应已写入正式库：$($endpoint.proposed_id)"
}

$manifestPath = Join-Path $packageRoot 'package-manifest.csv'
$packageFreezePath = Join-Path $packageRoot 'package-freeze.sha256'
$manifestRows = @(Import-Csv -LiteralPath $manifestPath)
$manifestColumns = @('relative_path','byte_count','sha256')
if ($manifestRows.Count -gt 0) {
    Test-SetEqual $manifestRows[0].PSObject.Properties.Name $manifestColumns 'package-manifest.csv 表头错误'
}
$manifestFiles = @(Get-ChildItem -LiteralPath $packageRoot -Recurse -File | Where-Object { $_.Name -notin @('package-manifest.csv','package-freeze.sha256') })
Test-Rule ($manifestRows.Count -eq $manifestFiles.Count) 'package manifest 行数与包文件数不一致'
Test-Rule (@($manifestRows.relative_path | Sort-Object -Unique).Count -eq $manifestRows.Count) 'package manifest relative_path 不唯一'
foreach ($file in $manifestFiles) {
    $relative = $file.FullName.Substring($packageRoot.Length + 1).Replace('\','/')
    $rows = @($manifestRows | Where-Object { $_.relative_path -eq $relative })
    Test-Rule ($rows.Count -eq 1) "package manifest 缺少或重复文件：$relative"
    if ($rows.Count -eq 1) {
        $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        Test-Rule ([int64]$rows[0].byte_count -eq $file.Length) "package manifest 字节数不匹配：$relative"
        Test-Rule ($rows[0].sha256 -eq $hash) "package manifest SHA-256 不匹配：$relative"
    }
}
$manifestHash = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
$recordedFreeze = (Get-Content -Raw -Encoding UTF8 -LiteralPath $packageFreezePath).Trim()
Test-Rule ($recordedFreeze -eq "sha256:$manifestHash  package-manifest.csv") 'package-freeze.sha256 与 manifest 哈希不一致'
$freeze = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $packageRoot 'source-freeze.md')
$remoteLog = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $packageRoot 'remote-retrieval-log.md')
$readme = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $packageRoot 'README.md')
Test-Rule ($freeze -match 'five_extracts_frozen / g15_partial_pending / upstream_body_pending') 'source-freeze 状态不符合修复边界'
Test-Rule ($freeze -match '不能标成 `web_snapshot`') 'source-freeze 缺少禁止 web_snapshot 的说明'
Test-Rule ($freeze -match '第一个页面行标记是 `L148`') 'source-freeze 缺少 G15 partial 边界'
Test-Rule ($remoteLog -match '退出码 35') '远端日志缺少 curl 退出码'
Test-Rule ($remoteLog -match '提权请求已获批准') '远端日志没有区分审批成功与 TLS 失败'
Test-Rule ($remoteLog -match '不是用户拒绝、沙箱拒绝、自动审批拒绝或审批连接故障') '远端日志缺少错误分类'
Test-Rule ($readme -match 'ready_for_independent_review') 'README 状态不是 ready_for_independent_review'
Test-Rule ($readme -match 'tpu-machines.*selected') 'README 没有说明 tpu-machines 入选'
Test-Rule ($readme -match 'G15.*pending_verification') 'README 没有说明 G15 pending'

if ($script:Errors.Count -gt 0) {
    Write-Output "FAIL: $($script:Errors.Count) errors in $($script:CheckCount) checks."
    $script:Errors | ForEach-Object { Write-Output "- $_" }
    exit 1
}

Write-Output "PASS: M2-W2-GOOGLE-CLOUD-DEVICE-REMEDIATED preparation package; $($script:CheckCount) checks executed."
Write-Output 'Scope: 3 reserved cloud_accelerator references, 3 reserved implements_architecture relations, 15 deferred dispositions, 7 configuration groups, 5 usable extracts, 1 partial G15 extract, 6-source device pool, 4 selection members.'
exit 0