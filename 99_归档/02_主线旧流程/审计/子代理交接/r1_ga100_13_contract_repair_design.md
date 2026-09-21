# GA100 资料卡合同修复设计（第二轮审计稿）

## 裁决边界

本稿吸收 `r1_contract_06_absence_coverage_model_review.md` 与 `r1_ga100_15_atomic_v2_independent_review.md` 的 `reject` 结论，只修订合同设计。它不执行正式表、资料卡模板、validator、GA100 staging、冻结名单或进度文件的写入；GA100 v2 仍为 `reject`，不得据此进入 `provisional` 或 `formal`。

第一轮提出的 `mechanism-requirements.csv` 和 `mechanism-search-log.csv` 已撤回。它们只能覆盖少数机制，不能把逐来源检索、发现真实实体后的 0..N 绑定、零 candidate field 的裁决和最小来源反向移除闭合到同一条数据链。第二轮使用通用 factor obligation：card-scope factor 独立于当前是否已有实体，真实 entity 仍只在正式 component、link、capability、topology 等表中登记。

| 设计索引 | 关闭的风险 | 第二轮裁决 |
|---|---|---|
| B1 | 漏列 field×target | `BuildExpectedFieldTargetPairs` 独立生成全集；targets 与 bindings 均严格 set-equal。 |
| B2 | 把未做单元标为 exclude | policy 外置的 `mandatory_include`；GA100 9×12 的 108 项均不可 exclude。 |
| B3 | scope 可复用或映射漂移 | append-only allocation/mapping registry、tombstone、row hash 和 manifest binding。 |
| B4 | lifecycle 与单 identity 冲突 | 第一版无 `superseded`；revision 历史留给归档 manifest。 |
| B5 | cutoff 只保存、不约束内容 | selection run、实际 source version、实际 endpoint、search result 和 prepared date 全部过日期门。 |
| B6 | manifest/审批 hash 循环或闭包不足 | manifest 绑定完整 closure，approval 单向绑定完整 manifest hash，不回写 approval hash。 |
| B7 | reachability 错吸共享架构对象 | 0..N 显式正向 projection、parent 递归、visited set 和 `FIELD-ID-ARCH` 限定例外。 |
| B8 | parser 或事务可静默漂移 | strict UTF-8/canonical fixtures，update/delete preimage 与全事务 input/postimage hash。 |
| B9 | 迁移口径模糊 | 合同完成基线固定为 34 表、375 schema columns、140 fields、77 enum groups、562 enum rows。 |
| B10 | 用假 entity 记录缺失 | `factor-requirements`、真实 target binding 和 source-result endpoint 取代 GAP entity。 |

下文同时覆盖 GA100 v2 独立复核的十项 blocker：假 entity、141-field 遗留、pending 发布、模板化搜索和错误来源相关性、错误 N/A、冗余 MIG 610、无 preimage 的操作、对象/selection-run scope 漏登记、以及缺失 manifest/审批。它们都是 GA100 v3 的实施门，不能由本设计稿单独解除。

## 卡级元数据与不可复用 scope

`FIELD-ID-DATA-CUTOFF` 属于资料管理元数据，不是厂商事实。合同事务从 `数据/fields.csv` 删除它，并删除 `product_status` 的 `historical_anchor`；该词只保留为冻结名单中的研究角色。`数据/card-completeness.csv` 在 `notes` 后增加 `card_lifecycle`、`data_cutoff_date`、`scope_id`，`数据/objects.csv` 在 `notes` 后增加 `scope_id`。只有 identity 行能填写前三列；每个 object 恰一条 identity 行；objects 与 identity 的非空 scope 必须相同。两个正式 `scope_id` schema 行均设 `semicolon_forbidden=true`，格式为 `^SCOPE-[0-9]{4,}$`。

第一版 lifecycle 只有 `legacy_unreconciled`、`draft`、`provisional`、`formal`、`archived`。`provisional`、`formal`、`archived` 必填 scope 和 cutoff；`legacy_unreconciled`、`draft` 可为空。不存在 `superseded`，因为一条 identity 行不能同时表示当前卡和已替代卡。

scope 的权威来源位于 manifest 外的 `审计/合同注册表/`：

| 文件 | 最小列 | 规则 |
|---|---|---|
| `scope-id-registry.csv` | `scope_allocation_id`、`freeze_row_id`、`scope_id`、`allocation_state`、`allocation_basis`、`allocated_by`、`allocated_date`、`reviewed_by`、`reviewed_date`、`notes` | 初始迁移为 49 条冻结计数行各分配一条。`freeze_row_id`、`scope_id` 全历史唯一，不物理删除；新增编号为 active 与 tombstone 全历史最大编号加一。 |
| `scope-object-mapping.csv` | `mapping_event_id`、`mapping_event_seq`、`freeze_row_id`、`scope_id`、`formal_object_id`、`proposed_formal_object_id`、`mapping_status`、`mapping_basis`、`reviewer`、`review_date`、`approval_status`、`notes` | 映射变更追加 event，不修改旧行。最大 sequence 的 approved event 是有效映射；有效 `mapped` 的 formal object 全局唯一。状态为 `unmapped`、`pending_identity_review`、`pending_formal_object_create`、`mapped`、`retired`、`tombstoned`。 |

初始映射不得通过名称、标签相似度或共享设计组猜测。GA100 的首条 allocation 是 `FREEZE-NV-001 → SCOPE-0001`；创建正式对象前为 `pending_formal_object_create`，只记录 `proposed_formal_object_id=OBJ-NVIDIA-GA100-DIE`。对象、identity 行和 approved mapping event 必须在同一原子事务落地。scope、freeze row、formal object ID 都是单值字段，禁止分号。

## coverage policy、field 候选全集与 factor obligation

`coverage-policy-v2.0.json` 与 `source-date-policy-v2.0.csv` 位于 manifest 外，作为受控、版本化输入。policy 必须有稳定 `policy_id`，并定义 field selector、`mandatory_include`、exclude reason code、factor 目录、零 candidate field 到 factor 的映射、`FIELD-ID-ARCH` 例外、projection cardinality 和最低来源要求。manifest 只能引用这两份已批准政策，不能用本包 CSV 覆盖它们。

`BuildExpectedFieldTargetPairs(data, card_object_id, projection_relation_ids)` 先构造可达真实 target 集合 `R`，再生成所有三元组 `(field_id, target_kind, target_id)`，条件只有 `target_kind ∈ field.allowed_requirement_target_kinds`。这是独立计算结果，不从 `coverage-targets.csv` 回推。任何细粒度 selector 只决定候选的 `include` 或 `exclude`，不能删除候选。

`coverage-targets.csv` 的每行必须有 `coverage_target_id`、`work_package_id`、`field_id`、七个互斥 target 列、`decision`、`reason_code`、`reason_text`、`review_status`、`notes`。candidate key 是 `(field_id, target_kind, target_id)`，每键恰一行，集合必须与 builder 的全集严格相等。`reachable-target-bindings.csv` 也对同一 candidate key 恰一行，集合再次与全集严格相等，包括 exclude。binding 的最后一个 node 必须是 candidate 的真实 target，row hash 和 chain hash 都重算验证。

include code 只能是 `mandatory_include`、`selector_match`、`card_scope_requirement`；每个 include 有且只有一条 field 和七 target 列逐字相同的 field requirement。exclude code 仅限 `target_subtype_mismatch`、`wrong_owner_scope`、`architecture_only_not_implementation`、`implementation_only_not_architecture`、`explicit_card_scope_exclusion`，并有独立 `coverage-exclusion-review.csv` 审核。`not_found`、`not_public`、`not_applicable`、`inaccessible_evidence`、`pending_verification` 均是 include requirement 的状态，不能作为 exclude 理由。

`coverage-fields.csv` 只保存从 candidates、policy 与 requirement closure 重算得到的 field report。`no_reachable_allowed_target` 只是一项诊断，不可作为卡级结案。每一个零 candidate field 都必须由 policy 映射至少一个 applicable factor；未映射、factor 集合缺行或映射 factor 为 pending 时，卡不能进入 `provisional` 或 `formal`。

GA100 policy 固定 12 个数值 field 与 9 个唯一 `precision_path_id` 的 108 项为 `mandatory_include`：A、B、product、程序员可见 accumulation、physical accumulation、output、rounding、scaling mode、scaling granularity、saturation、subnormal、sparsity。任一项最终不适用时也必须是 `include + exact-one requirement_status=not_applicable + applicability_reason`，不能 exclude。旧 `61+12=73` 只是 staging 快照，不是发布口径。

`BuildExpectedFactorObligations(card_object_id, policy)` 独立产生 `(card_object_id, policy_id, factor_id)` 全集，不依赖当前实体。factor 覆盖候选机制、矩阵/向量/特殊函数组件类别、存储层、主机与设备直连接口、芯片侧互联层级、topology 存在性和其他 policy 注册的芯片因素；模型、batch、上下文长度、MoE 通信量、KV Cache 迁移量仍属条件或 workload 分析，不成为 factor。每个 factor 固定 card selector、允许真实 target kind、subtype selector、`min_targets_if_available`、允许 `not_applicable` 的结构 predicate、最低 source type、以及负责解释的 field 集合。

## factor、search 与 evidence 的统一模型

第一轮两张 mechanism 专表撤回，改为两张通用正式表：

| 表 | 固定列 | 项目规则 |
|---|---|---|
| `数据/factor-requirements.csv` | `factor_requirement_id`、`card_object_id`、`policy_id`、`factor_id`、`requirement_status`、`applicability_reason`、`requirement_fingerprint`、`review_status`、`notes` | 9 列。PK 用 `REQ-FACTOR-*`；与 `field-requirements.requirement_id` 跨表全局唯一；集合必须与 `BuildExpectedFactorObligations` 严格相等。 |
| `数据/factor-target-bindings.csv` | `factor_target_binding_id`、`factor_requirement_id`、七个 target 列、`review_status`、`notes` | 11 列。同一 factor 允许 0..N 真实 binding；每行七 target XOR，`(factor_requirement_id,target_kind,target_id)` 唯一。 |

binding target 必须处于该 card 的受控 reachability，target kind/subtype 通过 policy selector，并已有 policy 指定的 identity field、已接受 fact 与 assertion。ID、label 或 notes 中带 `GAP` 不是独立拒绝条件；缺少真实身份事实链才会失败。因而 `CAP-R1-GA100-GAP-*`、`TOPO-R1-GA100-NVLINK-GAP` 永远不能作为 factor binding 的真实 target。

三张既有来源表在同一合同事务扩列：

| 表 | 结构变更 | 约束 |
|---|---|---|
| `最小参考资料库/search-log.csv` | 既有 `requirement_id` 改 nullable；追加 `factor_requirement_id` | 两个 requirement 外键 XOR，分别指向 field/factor requirement。 |
| `最小参考资料库/search-results.csv` | 追加 `endpoint_id`、`checked_locator_or_scope` | endpoint 必须属于同一 `source_id`；进入发布 closure 的两列均非空。 |
| `最小参考资料库/requirement-evidence.csv` | 既有 `requirement_id` 改 nullable；追加 `factor_requirement_id`、`endpoint_id` | 两个 requirement 外键 XOR；endpoint 与 source 同属一个 source version，locator 不可空。 |

`search-results.source_id` 继续表示实际内容版本，`endpoint_id` 固定实际访问入口，`checked_locator_or_scope` 写被查的页码、章节、表格、网页小标题、API 节点或全文范围。发布验证直接使用该 endpoint，绝不根据当前 preferred endpoint 事后替换。`search-log.source_types_checked` 改为派生审计列：由本 log 的 result source rows 的 `source_type` 按 canonical 分号顺序重算；人工自由文本不参与发布裁决。

factor status 的发布闭合如下。factor requirement、binding、search、result、evidence 均至少 `reviewed` 或 `approved`。

| 状态 | binding | 来源与检索闭合 |
|---|---|---|
| `value_available` | 数量达到 `min_targets_if_available` | 每个 target 有真实身份 fact/assertion；发现源有 `source_confirmed` log 与 `supports_requirement` result。 |
| `not_found` | 0 | 至少一条 `no_reliable_result` log；逐源 result 非空，实际 source type 满足 policy，结果为 `checked_no_support` 或不计覆盖的 `duplicate`。 |
| `not_public` | 0 | 有 `supports_not_public` evidence，且 source、实际 endpoint、locator 完整。 |
| `not_applicable` | 0 | policy 明确允许、结构 predicate 成立、理由非空；policy 要求时另有 `supports_not_applicable` evidence。 |
| `pending_verification` | 0 | 仅 draft 可用；可有 `planned`、`in_progress`、`candidate_found`，禁止 provisional/formal。 |
| `inaccessible_evidence` | 0 | 有 `blocked` log 和至少一个 `inaccessible` result，source/endpoint 可解析。 |
| `conflicting_unresolved` | 0 | 只有独立 conflict 模型可保存相反证据时才允许；第一版未实现前禁止发布。 |

log/result 状态必须相容：`candidate_found` 至少一条 `candidate`；`source_confirmed` 至少一条 `supports_requirement`；`blocked` 至少一条 `inaccessible`；`no_reliable_result` 不得同时有 candidate 或 support。field requirement 的同一来源闭合也采用这套 endpoint 和 result 门。`selected_role` 新增且只新增 `coverage_obligation_evidence`，用于最小来源集中承担 factor 缺失或存在性裁决的 source。

资料卡第 8 节、其他零 target 领域及所有允许显示缺失状态的单元，标识列统一为“事实或字段要求标识”，格式为 `<fact_id / requirement_id / factor_requirement_id>`。有值时列 accepted fact；普通 target 缺失时列 field requirement；无 target factor 时列 factor requirement。HBM stacks 与 HBM interface 必须拆成两行；阅读层 `silicon_package` 可对应正式 `object_type=die`。模板不得以虚构 capability/topology fact 表示缺失。

## cutoff、scope、closure 与 reverse-removal

identity `data_cutoff_date` 是 manifest `cutoff_date` 的唯一值。selection run 当前合同中的 scope 是 object scope：`ValidateDates` 必须要求 `selection-runs.scope_kind=object`，`selection-runs.scope_id=manifest.card_object_id`，再经 approved scope mapping event 映射到 `manifest.scope_id`。禁止把 run 的 `scope_id` 直接等同于 `SCOPE-*`。run 的 `cutoff_date`、`algorithm_version` 与 manifest 相等，且 `created_date >= cutoff_date`；`prepared_date >= cutoff_date`。

source-date policy 必须覆盖每个受控 source type，未列类型不得进入 closure。对固定文档，已知 `sources.publication_date` 必须不晚于 cutoff，并作为裁决日期；publication date 为空时，使用实际 result/evidence 所绑定唯一 endpoint 的 `snapshot_date`，若该 endpoint 没有 snapshot date，则用其 `access_date` 作为保守可用日期。动态网页、云文档和动态 API 内容必须有实际 endpoint 的 `snapshot_date`，不得回退到 access date。每个实际 endpoint 的 `access_date`、非空 `snapshot_date`、每项 search 的 `searched_date` 和 source 裁决日期均不得晚于 cutoff。review/approval 可以晚于 cutoff，但 closure 不得出现更晚的 source version、endpoint、search result 或 evidence。

`BuildClosureSet` 从所有 include field requirement 和全量 factor requirement 出发，收集：requirements、factor requirements、factor target bindings、同 target facts、fact assertions、search log、search result、requirement evidence、selection run/member/selected role、source screening、source families、source version rows、每个 result/evidence 实际 endpoint、policy 与 source-date policy reference。`FIELD-ID-ARCH` 不要求重复 fact，但仍收集已批准 `implements_architecture` relation。closure 以 canonical row set hash 固定；替换实际 endpoint、source version、result、evidence、binding 或 mapping 事件都会改变 closure 或 manifest binding。

reverse-removal 的覆盖宇宙包含 field closure 与 factor closure。试删 source 时必须重算 field/factor status、policy 最低 source type、result endpoint、factor target identity fact/assertion 和 selection member role。发布性 `not_found`、`not_public`、`inaccessible_evidence` 依赖的 source 必须是该 selection run 的 member；只保留审计的未选 source 要显式标为非必要输入。缺失覆盖来源使用 `coverage_obligation_evidence`。GA100 v3 还必须移除 MIG 610 的冗余 qualifier 职责、降回 lead，并在全部事实/检索闭合后重跑六源 reverse-removal；不能依赖自报 mandatory reason。

## manifest、approval 与 canonical 规则

`coverage-manifest.json` 只允许下列键，且必须以此顺序写入 canonical JSON；缺键、重复键、未知键、浮点或键顺序错误均失败：

1. `coverage_contract_version`
2. `manifest_id`
3. `work_package_id`
4. `policy_id`
5. `policy_canonical_sha256`
6. `source_date_policy_id`
7. `source_date_policy_canonical_sha256`
8. `card_object_id`
9. `card_object_canonical_row_sha256`
10. `scope_id`
11. `scope_allocation_id`
12. `scope_allocation_canonical_row_sha256`
13. `mapping_event_id`
14. `mapping_event_canonical_row_sha256`
15. `expected_card_lifecycle`
16. `cutoff_date`
17. `selection_run_id`
18. `selection_algorithm_version`
19. `projection_relation_ids`
20. `field_count`
21. `fields_contract_canonical_set_sha256`
22. `coverage_schema_canonical_set_sha256`
23. `coverage_enums_canonical_set_sha256`
24. `reachable_inventory_canonical_set_sha256`
25. `expected_pairs_canonical_set_sha256`
26. `expected_factor_obligations_canonical_set_sha256`
27. `closure_canonical_set_sha256`
28. `coverage_targets_raw_file_sha256`
29. `reachable_target_bindings_raw_file_sha256`
30. `coverage_fields_raw_file_sha256`
31. `coverage_exclusion_reviews_raw_file_sha256`
32. `prepared_by`
33. `prepared_date`
34. `reviewed_by`
35. `reviewed_date`
36. `review_status`
37. `notes`

`field_count` 必须为 140。四项 raw hash 分别固定工作包的 targets、bindings、derived fields、exclusion review 文件，不能以“所有文件”这类泛化描述替代。manifest 不包含 approval file hash，也不允许任何 approval-derived 字段。

`independent-approval.json` 在 manifest 完成后单向绑定其完整 canonical hash。其允许键及顺序是 `approval_contract_version`、`approval_id`、`manifest_canonical_sha256`、`closure_canonical_set_sha256`、`policy_id`、`policy_canonical_sha256`、`source_date_policy_id`、`source_date_policy_canonical_sha256`、`card_object_id`、`scope_id`、`scope_allocation_id`、`scope_allocation_canonical_row_sha256`、`mapping_event_id`、`mapping_event_canonical_row_sha256`、`cutoff_date`、`approved_by`、`approved_date`、`approval_status`、`notes`。`approved_by` 与 `prepared_by` 不同，`approved_date >= reviewed_date >= prepared_date >= cutoff_date`。approval 不参与 manifest 的 hash 计算，消除循环；mapping event 一旦追加或变更为新的 latest approved event，manifest scope binding 与 approval 均失效。

canonical parser 保持严格 UTF-8：只允许文件起始单个 BOM，正文 BOM、非法 UTF-8、overlong encoding、未配对 surrogate、非 scalar 均拒绝。CSV 记录分隔统一为 LF，禁止 cell 内 CR/LF；受控工作包 CSV 是 UTF-8 无 BOM、LF、末尾恰一个 LF。JSON writer 固定键序、UTF-8 byte sort、无额外空白、控制字符用小写 `\\u00xx`，不 trim、不 case-fold、不作 Unicode normalization。Markdown scope 表只允许未转义 `|` 分隔、`\\|` 原样保留、无跨行 cell/未闭合 code 或 link。PS5.1、PS7 与 Python 均使用自建 strict parser/writer，不依赖默认 JSON、CSV、encoding 或 locale；共享正负 golden fixtures 覆盖中文、空值、BOM、LF/CRLF/CR、U+0000/U+2028/U+2029、supplementary-plane、escaped pipe、非法 UTF-8、重复 key、未知 key、浮点、cell 内换行和错误 endpoint/source 配对。当前 macOS 没有 Windows PowerShell runtime，此项为工具运行时限制，fixtures 尚未实际跨三端通过。

## 完整发布门伪代码

```text
ValidateCoveragePackage(base, staging, manifest_dir, registries, policy, date_policy):
    data = Merge(base, staging)
    manifest = LoadStrictCanonicalJson(manifest_dir / "coverage-manifest.json",
                                       ordered_keys=ManifestKeys)
    approval = LoadStrictCanonicalJson(manifest_dir / "independent-approval.json",
                                       ordered_keys=ApprovalKeys)
    Require(manifest.policy_id == policy.policy_id)
    Require(HashCanonical(policy) == manifest.policy_canonical_sha256)
    Require(HashCanonical(date_policy) == manifest.source_date_policy_canonical_sha256)
    ValidateScopeAndApproval(manifest, approval, data, registries)
    ValidateDates(manifest, data, date_policy)
    Require(RawHash(manifest_dir / "coverage-targets.csv") == manifest.coverage_targets_raw_file_sha256)
    Require(RawHash(manifest_dir / "reachable-target-bindings.csv") == manifest.reachable_target_bindings_raw_file_sha256)
    Require(RawHash(manifest_dir / "coverage-fields.csv") == manifest.coverage_fields_raw_file_sha256)
    Require(RawHash(manifest_dir / "coverage-exclusion-review.csv") == manifest.coverage_exclusion_reviews_raw_file_sha256)

    projections = ResolveExplicitForwardProjections(data, manifest.card_object_id,
                                                     manifest.projection_relation_ids)
    Require(policy.ProjectionCardinality(manifest.card_object_id, projections))
    inventory = BuildReachableInventory(data, manifest.card_object_id, projections)
    Require(HashCanonicalSet(inventory.rows) == manifest.reachable_inventory_canonical_set_sha256)

    expected_pairs = BuildExpectedFieldTargetPairs(data.fields, inventory.real_targets)
    candidates = LoadStrictCsv(manifest_dir / "coverage-targets.csv")
    field_bindings = LoadStrictCsv(manifest_dir / "reachable-target-bindings.csv")
    Require(Set(CandidateKey(candidates)) == Set(expected_pairs))
    Require(Set(CandidateKey(field_bindings)) == Set(expected_pairs))
    Require(EachKeyOccursExactlyOnce(candidates, field_bindings))
    ValidateFieldCandidatesAndRequirements(candidates, field_bindings, data, policy, manifest)

    expected_factors = BuildExpectedFactorObligations(manifest.card_object_id, policy)
    factors = Rows(data.factor_requirements, card_object_id == manifest.card_object_id)
    factor_bindings = Rows(data.factor_target_bindings,
                           factor_requirement_id in Set(factors.factor_requirement_id))
    Require(Set(FactorKey(factors)) == Set(expected_factors))
    Require(HashCanonicalSet(expected_factors) == manifest.expected_factor_obligations_canonical_set_sha256)
    ValidateFactors(factors, factor_bindings, inventory, data, policy, manifest)

    derived = DeriveCoverageFields(data.fields, candidates, factors, policy)
    Require(LoadStrictCsv(manifest_dir / "coverage-fields.csv") == derived)
    for field in derived where field.status == "no_reachable_allowed_target":
        Require(Count(policy.FactorsExplaining(field.field_id, manifest.card_object_id)) >= 1)
        Require(AllMappedFactorsClosedForPublication(field, factors, policy))

    closure = BuildClosureSet(data, candidates, factors, factor_bindings,
                              manifest.selection_run_id, policy, date_policy)
    Require(HashCanonicalSet(closure) == manifest.closure_canonical_set_sha256)
    Require(ContractSetHashesMatch(manifest, data))

ValidateScopeAndApproval(manifest, approval, data, registries):
    allocation = ExactlyOne(registries.scope_allocations,
                            scope_allocation_id == manifest.scope_allocation_id)
    Require(allocation.scope_id == manifest.scope_id and allocation.allocation_state == "active")
    Require(RowHash(allocation) == manifest.scope_allocation_canonical_row_sha256)
    mapping = LatestApprovedMapping(registries.scope_mappings, manifest.scope_id)
    Require(mapping.mapping_event_id == manifest.mapping_event_id)
    Require(RowHash(mapping) == manifest.mapping_event_canonical_row_sha256)
    Require(mapping.mapping_status == "mapped" and mapping.formal_object_id == manifest.card_object_id)
    Require(ObjectAndIdentityHaveSameScope(data, manifest.card_object_id, manifest.scope_id,
                                           manifest.expected_card_lifecycle))
    Require(approval.manifest_canonical_sha256 == HashCanonical(manifest))
    Require(ApprovalBindsAllScopePolicyClosureAndCutoffFields(approval, manifest))
    Require(approval.approved_by != manifest.prepared_by and approval.approval_status == "approved")

ValidateDates(manifest, data, date_policy):
    run = ExactlyOne(data.selection_runs, selection_run_id == manifest.selection_run_id)
    Require(run.scope_kind == "object" and run.scope_id == manifest.card_object_id)
    Require(run.cutoff_date == manifest.cutoff_date)
    Require(run.algorithm_version == manifest.selection_algorithm_version)
    Require(run.created_date >= manifest.cutoff_date and run.review_status == "approved")
    Require(manifest.prepared_date >= manifest.cutoff_date)
    for result in ClosureSearchResults(data, manifest):
        endpoint = ResolveEndpoint(result.endpoint_id)
        source = ResolveSource(result.source_id)
        Require(endpoint.source_id == source.source_id and NonEmpty(result.checked_locator_or_scope))
        Require(endpoint.access_date <= manifest.cutoff_date)
        Require(Empty(endpoint.snapshot_date) or endpoint.snapshot_date <= manifest.cutoff_date)
        Require(SourceDateAtOrBeforeCutoff(source, endpoint, date_policy, manifest.cutoff_date))
    for evidence in ClosureEvidence(data, manifest):
        endpoint = ResolveEndpoint(evidence.endpoint_id)
        source = ResolveSource(evidence.source_id)
        Require(endpoint.source_id == source.source_id and NonEmpty(evidence.source_locator))
        Require(endpoint.access_date <= manifest.cutoff_date)
        Require(Empty(endpoint.snapshot_date) or endpoint.snapshot_date <= manifest.cutoff_date)
        Require(SourceDateAtOrBeforeCutoff(source, endpoint, date_policy, manifest.cutoff_date))
    Require(AllClosureSearchDatesAtOrBeforeCutoff(data, manifest.cutoff_date))

SourceDateAtOrBeforeCutoff(source, endpoint, date_policy, cutoff):
    Require(date_policy.ContainsExactlyOneRule(source.source_type))
    if date_policy.IsDynamic(source.source_type):
        Require(NonEmpty(endpoint.snapshot_date))
        return endpoint.snapshot_date <= cutoff
    if NonEmpty(source.publication_date):
        return source.publication_date <= cutoff
    if NonEmpty(endpoint.snapshot_date):
        return endpoint.snapshot_date <= cutoff
    return endpoint.access_date <= cutoff     # fixed document, conservative fallback

ValidateFieldCandidatesAndRequirements(candidates, bindings, data, policy, manifest):
    for candidate in candidates:
        Require(OneTargetColumn(candidate) and NonEmpty(candidate.reason_text))
        Require(candidate.review_status == "approved")
        Require(ReasonCodeMatchesDecision(candidate, policy))
        Require(BindingEndsAtSameRealTarget(bindings[CandidateKey(candidate)], candidate))
        if policy.IsMandatoryInclude(candidate):
            Require(candidate.decision == "include" and candidate.reason_code == "mandatory_include")
        if candidate.decision == "exclude":
            Require(IndependentApprovedExcludeReview(candidate, manifest.prepared_by))
            Require(NoSameFieldSevenTargetRequirement(candidate, data.field_requirements))
            continue
        req = ExactlyOneSameFieldSevenTargetRequirement(candidate, data.field_requirements)
        Require(FieldRequirementClosed(req, data, policy, manifest.expected_card_lifecycle))

FieldRequirementClosed(req, data, policy, lifecycle):
    Require(req.review_status in {"reviewed", "approved"})
    if req.field_id == "FIELD-ID-ARCH":
        Require(req.target_kind == "object_relation")
        Require(ApprovedImplementsArchitectureRelation(req.object_relation_id, data))
        Require(req.requirement_status == "value_available")
        return true
    if req.requirement_status in {"value_available", "conflicting_unresolved"}:
        Require(AcceptedSameTargetFactAndAssertion(req, data))
    if req.requirement_status == "not_found":
        Require(ReviewedNoReliableResultWithEndpoint(req, data, policy.FieldRule(req.field_id)))
    if req.requirement_status == "not_public":
        Require(ReviewedNotPublicEvidenceWithEndpoint(req, data))
    if req.requirement_status == "not_applicable":
        Require(NonEmpty(req.applicability_reason))
    if req.requirement_status == "inaccessible_evidence":
        Require(ReviewedBlockedResultWithEndpoint(req, data))
    if req.requirement_status == "pending_verification":
        Require(lifecycle == "draft")

BuildExpectedFieldTargetPairs(fields, real_targets):
    return { (field.field_id, target.kind, target.id)
             for field in fields for target in real_targets
             if target.kind in ParseCanonicalKinds(field.allowed_requirement_target_kinds) }

BuildExpectedFactorObligations(card_object_id, policy):
    return { (card_object_id, policy.policy_id, factor.factor_id)
             for factor in policy.factors
             if factor.CardSelectorMatches(card_object_id) }

ValidateFactors(factors, bindings, inventory, data, policy, manifest):
    for factor in factors:
        Require(factor.policy_id == manifest.policy_id and factor.review_status in {"reviewed", "approved"})
        Require(PolicyContains(factor.factor_id))
        bs = Rows(bindings, factor_requirement_id == factor.factor_requirement_id)
        Require(UniqueTargetKeys(bs) and AllAreRealReachableTargets(bs, inventory, policy))
        Require(FactorStatusClosed(factor, bs, data, policy, manifest.expected_card_lifecycle))

FactorStatusClosed(factor, bindings, data, policy, lifecycle):
    if factor.requirement_status == "value_available":
        Require(Count(bindings) >= policy.min_targets_if_available)
        Require(EachBindingHasIdentityFactAndAcceptedAssertion(bindings, data))
        Require(ConfirmedSearchAndResultIfSearchWasUsed(factor, data))
    if factor.requirement_status == "not_found":
        Require(Count(bindings) == 0 and ReviewedNoReliableResultWithEndpoint(factor, data, policy))
    if factor.requirement_status == "not_public":
        Require(Count(bindings) == 0 and ReviewedNotPublicEvidenceWithEndpoint(factor, data))
    if factor.requirement_status == "not_applicable":
        Require(Count(bindings) == 0 and policy.AllowsStructuralNA(factor) and NonEmpty(factor.applicability_reason))
    if factor.requirement_status == "inaccessible_evidence":
        Require(Count(bindings) == 0 and ReviewedBlockedResultWithEndpoint(factor, data))
    if factor.requirement_status == "pending_verification":
        Require(Count(bindings) == 0 and lifecycle == "draft")
    if factor.requirement_status == "conflicting_unresolved":
        Require(False)  # v1 conflict model is not implemented

BuildClosureSet(data, candidates, factors, factor_bindings, run_id, policy, date_policy):
    field_reqs = ExactOneRequirementsForIncludedCandidates(candidates, data.field_requirements)
    facts = SameTargetFacts(field_reqs, except_field="FIELD-ID-ARCH")
    assertions = AcceptedAssertionsFor(facts)
    search_logs = LogsFor(field_reqs + factors)
    results = ReviewedResultsFor(search_logs)
    evidence = ReviewedEvidenceFor(field_reqs + factors)
    selection = SelectionRows(run_id)
    sources = SourceFamiliesVersionsActualEndpoints(assertions, results, evidence, selection)
    return CanonicalRows(field_reqs, factors, factor_bindings, facts, assertions,
                         search_logs, results, evidence, selection, sources, policy, date_policy)
```

`BuildReachableInventory` 从 card object 出发，仅沿 manifest 列出的 subject-side `implements_architecture` relation 正向走到 0..N architecture object；再纳入 owner component、递归 parent chain、owned precision path、owner/endpoint 可解析的 link/capability/topology。visited set 防环，且永不沿共享 architecture 的反向 relation 吸入其他 chip。`FIELD-ID-ARCH` 只允许 approved `object_relation` target 的 exact-one `value_available` requirement，不要求 duplicate fact；其他 field 没有此例外。

## 正式事务保护、基线与最小落盘

合同迁移必须是独立原子事务，不与 GA100 facts 混写。事务目录的 `transaction-manifest.json` 固定保存：`transaction_id`、`base_formal_tables_canonical_set_sha256`、每张受影响正式表的 canonical preimage hash、scope allocation/mapping registry canonical set hash、policy/source-date-policy hash、work-package raw hash、payload inventory hash、operations raw hash、每张受影响表的 expected postimage hash、全正式表 expected postimage set hash、prepared/review/approval identity 与日期。任何输入与 manifest 不同即拒绝。

`operations.csv` 的每条 update/delete 必须有 `expected_preimage_sha256`，对其 PK 的 canonical row hash 精确匹配才可执行；每条 insert 必须有 `expected_absent=true` 并证明 PK 在 preimage 中不存在。update/delete 后的 row 和所有表的 postimage hash 都与 transaction manifest 相等才可接受。scope registry、selection-run registry、payload、schema/enums 与正式数据同属这一个 atomic input；这关闭 GA100 v2 76 次 update、3 次 delete 和新增 object/run 的静默漂移风险。

当前基线为 32 表、346 schema columns、141 fields、76 enum groups、557 enum rows、78 objects、585 completeness rows。移除 DATA-CUTOFF/historical_anchor、加入四个 scope/card columns 和五个 lifecycle values 后，中间基线为 32 表、350 schema columns、140 fields、77 enum groups、561 enum rows。factor 两表增加 20 columns，search-log/result/evidence 增加 5 columns，`selected_role` 追加 `coverage_obligation_evidence` 一值；完整合同的精确发布基线为 34 表、375 schema columns、140 fields、77 enum groups、562 enum rows、78 objects、585 completeness rows。GA100 v3 后续正式对象和 13 条 completeness 是单独芯片事务，届时才变为 79 objects、598 completeness rows。

| 层次 | 最小落盘项 | 验收 |
|---|---|---|
| scope/card | scope allocation/mapping registry、objects/card-completeness 扩列、lifecycle enum、DATA-CUTOFF 删除 | 49 条 allocation、不可复用、identity/object scope 相等。 |
| policy/factor | 两份 versioned policy、factor requirements/bindings、零 candidate 映射规则 | factor obligation 全集 set-equal，真实 target 才可 binding。 |
| source chain | 三张既有表的 XOR/endpoint 扩列、selected role enum | result/evidence 绑定实际 endpoint，不再使用 current preferred 替换。 |
| manifest/approval | 精确 key-order manifest、四项 raw hash、单向 independent approval | 无 unknown key、无 hash cycle、mapping event 漂移必失效。 |
| transaction | operation preimage/absent、input/registry/payload/postimage hashes | 任何漂移在执行前或 postimage 比对时失败。 |
| GA100 v3 | 从 140-field 新合同重建；删除 12 个 GAP entity 及其 20 条 requirement/search/result；实际检索、MIG 610 移除、六源 reverse-removal | 108 Tensor mandatory cells 全闭合，49 pending 全部改裁决，所有搜索有字段特定 query/locator/result。 |

旧对象一律保留 `legacy_unreconciled`，不以全库批量改 status 伪装通过新 source-result 门。GA100 v3 还须纠正 vendor TOPS 的错误 N/A：A100 产品条件不构成 full-GA100 field 的结构不适用；应在实际检索后裁为 `not_found`、`not_public` 或有条件 value。benchmark、PHY clock/power、RAS BIST/SDE 的 search policy 必须纳入已选且相关的 HPEC/random-access、ISSCC、GPU Memory Error Management 等资料；通用模板 query/result 不得进入发布 closure。

## 复读记录

已对本文件运行 `report-humanizer` 单文件扫描，机器扫描无硬性命中；随后从 B1 至 B10、factor/field 双轨、实际 endpoint、scope mapping、manifest/approval 单向 hash、事务 preimage/postimage、精确基线和 GA100 v3 实施门逆向复读。人工检查确认 factor obligation 不会创建假 entity，selection run 仍以 object scope 运行，approval 不进入 manifest preimage。Windows PowerShell 5.1 运行时在当前 macOS 环境不可用；三运行时 fixture 尚未执行，不能描述为已通过。
