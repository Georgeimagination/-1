# GA100 合同设计第二轮实现前独立验收

## 裁决

裁决为 `reject`。当前设计不能进入合同实现或 GA100 v3 生成。

本轮复核对象是 `r1_ga100_13_contract_repair_design.md`，本地复算的 SHA-256 为 `2f35cbb40e8c7fbbb50202d22fc874964eeacd54fa0afe529b09ccea38b5844e`，与任务指定值一致。设计已经保留了几项正确边界：selection run 仍以 formal `object_id` 为 scope；field×reachable target 使用独立 builder 和 set-equal；GA100 9×12 被放入 manifest 外的 mandatory policy；factor obligation 取代假 capability/topology，并明确排除模型、batch、上下文长度、MoE 通信量和 KV Cache 迁移量；coverage approval 单向绑定 manifest，不把 approval hash 回写 manifest；模板要求拆分 HBM stack 与 HBM interface。

这些边界尚未组成可执行合同。事实断言没有实际 endpoint，导致 cutoff 和 closure 无法计算；mandatory cell 可以用自由文本 `not_applicable` 绕过；factor `value_available` 可以跳过 factor-specific source gate；scope registry 没有与唯一活动名单建立稳定行键；legacy 重复 requirement 会让全局 exact-one 失效；transaction manifest、canonical row set、幂等执行和回滚仍没有精确 schema。以上任一项都足以阻止实现前接收。

## 输入与只读复算

本轮完整读取了主线 `AGENTS.md`、正式字段、枚举、schema、字段要求、事实断言、来源版本、endpoint、检索、选择运行、完整度、0.3 模板和字段字典，以及三份正式 validator。前序审计输入包括 `r1_contract_05_design_redteam.md`、`r1_contract_06_absence_coverage_model_review.md`、`r1_ga100_12_card_contract_independent_review.md` 和 `r1_ga100_15_atomic_v2_independent_review.md`。本报告没有修改正式表、设计稿、模板、validator、冻结名单、GA100 staging 或进度文件。

正式基线复算如下。

| 项目 | 当前正式值 | 第二轮设计值 | 本轮验收值 |
|---|---:|---:|---:|
| 正式表 | 32 | 34 | 34 |
| schema columns | 346 | 375 | 376 |
| fields | 141 | 140 | 140 |
| enum groups | 76 | 77 | 77 |
| enum rows | 557 | 562 | 562 |
| objects | 78 | 78 | 78 |
| card-completeness rows | 585 | 585 | 585 |

设计稿原算术本身成立：`346 + 4 个 card/scope 列 + 20 个 factor 两表列 + 5 个 search/evidence 扩展列 = 375`；`141 - DATA-CUTOFF = 140`；`557 - historical_anchor + 5 个 lifecycle 值 + 1 个 selected_role = 562`；新增 lifecycle 枚举组后为 77 组。`FIELD-ID-DATA-CUTOFF` 在正式 facts、field requirements 和 assertions 中均为 0 条，15 条正式产品状态事实也没有使用 `historical_anchor`，所以这两项删除可迁移。

375 列不能作为最终合同值。正式库有 93 个 source version，其中 67 个没有 `publication_date`；832 条 fact assertion 中有 639 条落在 48 个无 publication date 的 source 上。48 个 source 中有 36 个存在两个或三个 endpoint，涉及 561 条 assertion。`source_id` 和当前 preferred endpoint 都不能证明抽取时实际使用了哪个 endpoint。修复 R1 后，schema columns 必须改为 376。

正式库另有 1,059 条 field requirement，其中 29 个 field×七目标键重复，共有 79 条记录和 50 条额外记录；正式 `pending_verification` 为 26 条。GA100 v2 的 49 条 pending 是另一个 staging 数量，不能与正式 26 条混写。只给 object identity 加 `legacy_unreconciled` 无法隔离这些 requirement，因为 requirement 表没有 card owner 或 contract generation。

`verify_recovery_paths.py` 本轮只读通过：32 张表、153 个 endpoint、79 个本地路径及哈希、11 次 selection run 和 106 个 member 均可恢复。当前环境没有 `pwsh`、`powershell` 或 `powershell.exe`，所以 PS5.1、PS7 和三道 Windows gate 均未运行。这是工具运行时限制，不是 sandbox denial、approval failure 或已通过的替代证明。

## 阻断项与精确修订

### R1. fact assertion 必须绑定实际 endpoint

设计稿在 `BuildClosureSet` 中调用 `SourceFamiliesVersionsActualEndpoints(assertions, results, evidence, selection)`，但 `fact-assertions.csv` 只有 `source_id`，没有 `endpoint_id`。`ValidateDates` 也只遍历 search result 和 requirement evidence。一个 `value_available` fact 因而可以使用晚于 cutoff 的实际网页或快照，同时借同 source 的另一个早期 endpoint 通过日期门。

设计文档必须加入以下改动：

1. `最小参考资料库/fact-assertions.csv` 在 `source_id` 后增加 nullable `endpoint_id`，FK 指向 `source-endpoints.endpoint_id`，`semicolon_forbidden=true`。合同 schema 精确基线改为 34 表、376 columns、140 fields、77 enum groups、562 enum rows。
2. 对 `provisional` 或 `formal` closure 内的 accepted assertion，`endpoint_id` 必须非空，且 `endpoint.source_id == assertion.source_id`；`source_locator` 继续必填。`assertion_fingerprint` 的 canonical 输入必须增加 `endpoint_id`。
3. `BuildClosureSet` 从 assertion、search result 和 requirement evidence 三类记录分别取得实际 endpoint；`ValidateDates` 增加 assertion 循环，并执行与 result/evidence 相同的 source、endpoint、locator、access、snapshot 和 source-date policy 门。
4. 既有 assertion 不得按当前 preferred endpoint 批量回填。legacy 行可暂时为空，只能在逐卡核对实际抽取入口后补值；仍为空的 assertion 不得进入新生命周期 closure。

这项改列优于另建 assertion-endpoint bridge。每条 assertion 的抽取动作应有一个实际入口；多个镜像不增加 source 数，也不需要用 35 张表表达。

source-date policy 也不能继续只按 `source_type` 取唯一规则。正式数据中同一 source type 同时出现 `html_page`、`pdf_direct`、`local_pdf` 和 `web_snapshot`，固定内容与动态内容混在一组。policy 主键应改为 `(source_type, endpoint_type)`，每个组合固定 `date_basis`、publication 是否必填、snapshot 是否必填、是否允许 access fallback 和允许的 endpoint 状态。`SourceDateAtOrBeforeCutoff` 必须按 assertion/result/evidence 实际 endpoint 的这组复合键恰好命中一条规则。保守口径可以要求 `html_page`、publisher page、API 等 live endpoint 必须转到有 snapshot date 的实际 snapshot endpoint 后才能发布；`local_pdf`、固定 `pdf_direct` 才允许 publication 缺失时退到该实际 endpoint 的 access date。未登记组合直接失败。该改法不新增正式列，修订后的总列数仍为 376。

### R2. scope 历史不可复用，但活动名单仍缺稳定绑定

append-only allocation/mapping、tombstone 和 object-scope selection run 的方向成立。缺口出在活动范围的权威链。当前唯一名单的 Markdown 行没有 `freeze_row_id` 或 `scope_id`；设计只为初始 49 行引用归档 `freeze_row_id`。后续在唯一活动名单中新增、改名或退出时，validator 无法不用名称匹配就确定它对应哪条 allocation。把 `审计/合同注册表/` 称为另一处 scope 权威，还会与“活动 Markdown 是唯一维护入口”的项目规则产生双主。

设计文档需要固定以下规则：

1. 在唯一活动名单表中增加受控 `scope_id` 列。初始 49 行由一次性签字迁移清单把 `freeze_row_id → scope_id → 活动名单行` 逐行绑定；活动名单中的 scope 集合必须与 `scope-id-registry.csv` 的 active allocation 集合 set-equal。
2. `scope-id-registry.csv` 明确 PK、字段类型、nullable 矩阵和状态枚举。`scope_id`、`scope_allocation_id`、非空 `freeze_row_id` 在全历史唯一；编号只取 active 与 tombstone 全历史最大值加一。活动行退出时保留 allocation 并转 tombstone，scope 永不重新分配。
3. `scope-object-mapping.csv` 明确 `mapping_event_seq` 为每 scope 严格递增整数，`mapping_event_id` 为 PK。approved `mapped` 事件的 `formal_object_id` 在全历史只能属于同一个 scope，不能在旧 scope retired 后转给新 scope；非空 proposed ID 也不得同时被两个有效 scope 占用。
4. 为每个 mapping status 写出 required/forbidden 列矩阵。存在 sequence 更高的 pending 或 needs-resolution event 时，旧 approved mapping 不得继续发布新 manifest。
5. selection run 保持设计稿现有规则：`scope_kind=object`，`scope_id=manifest.card_object_id`。`SCOPE-*` 只通过 latest approved mapping 连接，禁止写入 selection run 的 `scope_id`。

### R3. mandatory_include 仍可被自由文本 N/A 绕过

expected-pair set-equal、exclude 独立审批和 GA100 108 项 mandatory include 都应保留。当前伪代码对 field requirement 的 `not_applicable` 只要求 `applicability_reason` 非空。作者可以把 108 个 mandatory cell 全部写成 include，再用任意自由文本 N/A 通过发布门。这个结果在结构上满足 exact-one，却没有完成逐路径裁决。

设计文档必须把 field N/A 改为 policy 判定：

```text
if req.requirement_status == "not_applicable":
    Require(policy.AllowsStructuralNA(req.field_id, req.target_kind, req.target_id,
                                      manifest.card_object_id))
    Require(policy.StructuralNAPredicateIsTrue(req, data, inventory))
    Require(NonEmpty(req.applicability_reason))
```

GA100 policy 还要显式列出 12 个 field ID 和 9 个 `precision_path_id`，不能只写中文简称或 label selector。9 个 path 是：

`PPATH-M2NA-AMPERE-TENSOR-BF16`、`PPATH-M2NA-AMPERE-TENSOR-FP16`、`PPATH-M2NA-AMPERE-TENSOR-FP64`、`PPATH-M2NA-AMPERE-TENSOR-INT8`、`PPATH-M2NA-AMPERE-TENSOR-TF32`、`PPATH-R1-GA100-AMPERE-TENSOR-BINARY`、`PPATH-R1-GA100-AMPERE-TENSOR-FP16-ACC16`、`PPATH-R1-GA100-AMPERE-TENSOR-INT4` 和 `PPATH-R1-GA100-TENSOR-FP16-DENSE`。

12 个 field 是 `FIELD-NUM-OPERAND-A`、`FIELD-NUM-OPERAND-B`、`FIELD-NUM-PRODUCT`、`FIELD-NUM-ACCUMULATION`、`FIELD-NUM-PHYSICAL-ACCUM`、`FIELD-NUM-OUTPUT`、`FIELD-NUM-ROUNDING`、`FIELD-NUM-SCALING-MODE`、`FIELD-NUM-SCALING-GRANULARITY`、`FIELD-NUM-SATURATION`、`FIELD-NUM-SUBNORMAL` 和 `FIELD-NUM-SPARSITY`。validator 应独立展开这两个显式集合，要求恰好得到 108 个 mandatory key，并逐键强制 include。policy 的 canonical hash 只能绑定经过独立批准的 policy；还需增加 policy approval 文件及其 hash，工作包作者不能自建同名 policy 过门。

`coverage-targets.csv` 应增加 `requirement_id`：include 必填，exclude 必须为空。validator 对该 ID 做精确 field/七目标键匹配。这样可以在 R7 的 legacy disposition 下选择一个合法 requirement，同时继续拒绝当前合同产生的新重复键。

### R4. reachability 算法和 factor value 来源门仍有空白

factor obligation 已覆盖 component 类别、memory level、link、topology 和 special mechanism，也明确排除了 workload 变量；这部分分类通过。实现前仍需把 policy 和 traversal 写成精确规则。

`BuildReachableInventory` 目前只说 owner/endpoint 可解析，没有说明 link endpoint 是否会扩张 object 集。设计文档应固定为：起点只含 card object；只沿 manifest 显式列出的 subject-side `implements_architecture` 到 0..N architecture object；只纳入 owner 属于 card/projection object 的 component、capability、link 和 topology；precision path 只由已纳入 component 拥有；memory level 必须同时命中已纳入 component；link endpoint 只用于校验，不继续扩张 object 或反向吸入系统对象；object relation target 只含显式 projection relation。所有 target 集合以 ID 逐字节去重，parent chain 必须闭合并防环。

factor policy 需要发布精确 schema，而不能只列“最小来源要求”等概念列。每个 factor 至少要固定 card selector、真实 target kind、subtype predicate、`min_targets_if_available`、是否允许 N/A、结构 predicate、最低 source type/authority、identity field 和负责解释的 field ID 集合。零 candidate field 到 factor 的映射必须对发布卡 set-equal，不能由当前实体反推。

factor `value_available` 的正文要求 source-confirmed/result，伪代码却调用 `ConfirmedSearchAndResultIfSearchWasUsed`。这会允许完全不做 factor-specific search。修订后每个发布态 `value_available` factor 都必须有 reviewed/approved 的 `source_confirmed` log 和至少一条 `supports_requirement` result；result 的 source/endpoint 必须与真实 target 的 accepted identity assertion 同源或由 policy 明确允许的独立来源支撑，并满足 factor 的最低 source type/authority。删除 `IfSearchWasUsed` 条件。这样既保留真实 target 的事实链，也不会让一个已有 entity ID 自动证明 factor obligation。

factor target 还需要与 field target 对称的穷举门。当前 `0..N binding + min_targets_if_available` 允许一个 factor 面对多个 selector-match 真实 target 时只绑定其中一个。设计文档应增加工作包文件 `factor-target-candidates.csv`，由 `BuildExpectedFactorTargetPairs(factors, inventory, policy)` 对每个 factor obligation 与所有 reachable、kind-allowed 的真实 target 生成候选全集。每个候选有 include/exclude 决策、受控 reason、review status；policy subtype selector 命中的候选必须 include，selector 不匹配才可经独立审批 exclude。正式 `factor-target-bindings.csv` 的键集合必须与 include 候选集合严格相等，不能用 `min_targets_if_available` 代替。manifest 相应增加 expected factor-target candidate set hash 和 raw file hash；这些是工作包文件，不改变 34 表和 376 columns 的正式基线。

field 的 factor 回退触发条件也要从 raw candidate 数改为 included applicable target 数。按 allowed target kind 生成的 raw candidates 可能全部因 subtype 不匹配而 exclude；此时字段虽然 `candidate_count > 0`，仍没有 requirement。`coverage-fields` 应派生 `included_target_count`，发布门要求每个 field 满足二选一：至少一个 include requirement 已闭合，或 policy 映射的 factor obligation 全部闭合。原 `no_reachable_allowed_target` 只能保留为诊断列，不能作为 factor 映射的唯一触发条件。

### R5. closure、policy approval 和 canonical set 还不足以逐字节实现

coverage manifest 与 independent approval 的单向关系没有 hash 循环，可以保留。当前 37 个 manifest key 和 approval key 只有名称、顺序，没有每个 key 的 JSON 类型、nullable、正则、数组排序和允许值。`CanonicalRows`、`HashCanonicalSet`、`coverage_schema`、`coverage_enums` 和 `ContractSetHashesMatch` 也没有字节级定义。不同 runtime 可以对同一逻辑集合生成不同字节，或在两个表拥有相同 row 内容时失去 table domain。

设计文档必须增加一份 canonical schema：

1. manifest、approval、policy、date policy 和 transaction JSON 的每个 key 固定 `string/integer/array/object` 类型、是否可空、格式和允许值。`projection_relation_ids` 等数组按 UTF-8 bytes 排序、去重；hash 统一为小写 64 位十六进制；日期必须是真实存在的 ISO `YYYY-MM-DD`。
2. canonical row 固定为带 `table_path`、有序 PK 和按 schema ordinal 排列的全部列值的 envelope。CSV cell 一律按 string 保存，空字符串与 JSON `null` 分开。rowset 先按 `(table_path UTF-8 bytes, PK UTF-8 bytes, full row bytes)` 排序；同一 table+PK 或完全重复 envelope 一律拒绝，空集唯一编码为 `[]`。每类 hash 使用固定 domain tag，并按 `domain UTF-8 || 0x00 || uint64be(payload_length) || payload` framing 后取 SHA-256，例如 row、rowset、manifest、policy 和 transaction 使用不同 tag。closure rowset 的 payload 是有 table domain 的无空白 JSON array，不能拼接裸 row bytes。这样 RowHash、混合多表 closure 和空集都有无歧义边界。
3. 明确 `coverage_schema_canonical_set_sha256` 覆盖哪些 schema row，`coverage_enums_canonical_set_sha256` 覆盖哪些 enum group，`fields_contract` 是否含全部 140 行。policy 和 source-date policy 各自需要预先存在的 independent approval，coverage manifest 绑定 policy bytes 与 approval hash。
4. `conflicting_unresolved` 不能只要求一条 accepted fact/assertion。它必须命中同 target/field 的 reviewed conflict group、至少两条相反 conflict member 和各自 assertion；conflict group、member、fact、assertion 及实际 endpoint 全部进入 closure。第一版若不实现这条链，field conflict 与 factor conflict 一样禁止发布。
5. manifest 的 `review_status` 必须为 reviewed 或 approved，`reviewed_by` 与 `prepared_by` 不同；independent approval 的 approver 也必须与 preparer 不同。任何 scope、policy、closure 或 source-date binding 改变后，旧 approval 失效。

### R6. transaction 仍没有精确 schema、幂等语义和回滚合同

设计稿第 339 至 341 行只描述 transaction manifest 应保存的内容。它没有给 key 顺序、类型、数组顺序、operation 的完整列、同 PK 多操作禁令、执行 journal、重复执行判定或 rollback bundle。insert 的 expected-absent 会使成功事务第二次运行直接失败，当前语义并不幂等。

设计文档应把 `operations.csv` 固定为以下列序：

`operation_id,operation_seq,table_path,operation_kind,pk_canonical_json,input_payload_path,input_payload_raw_sha256,expected_preimage_state,expected_preimage_canonical_row_sha256,expected_postimage_state,expected_postimage_canonical_row_sha256,rollback_payload_path,rollback_payload_raw_sha256`

其中 `operation_kind` 仅允许 insert/update/delete；preimage/postimage state 仅允许 `present/absent`。insert 要求 preimage absent、postimage present；update 两者均 present；delete 要求 preimage present、postimage absent。每个 operation 都有 input payload 及其 raw hash；present 状态必须有 canonical row hash，absent 状态对应 hash 必须为空。同一 transaction 内 `(table_path, pk_canonical_json)` 只能出现一次，sequence 从 1 连续递增。

`transaction-manifest.json` 要逐键定义并至少绑定：contract version、transaction ID、base 全表 canonical set、按 table path 排序的受影响表 preimage/postimage hash、scope/list/mapping registry preimage/postimage hash、policy/date-policy及其 approval hash、全部 work-package 文件 raw hash、payload 的 before/after 状态与 hash、operations raw hash、rollback bundle hash、预期全正式表 postimage set、prepared/review 信息。另建 `transaction-approval.json` 单向绑定 manifest canonical hash；manifest 不包含 approval file hash，避免循环。

执行器必须实现两个稳定终态。所有目标处于 manifest preimage 时才执行；所有目标已处于 expected postimage，且 journal 绑定同一 transaction/manifest hash 时返回成功 no-op。混合状态或任一未知状态立即失败。执行前在隔离镜像生成并验证全量 postimage，再以 journal 记录 applying/applied。

rollback bundle 保存每张受影响表和 registry 的原始 preimage bytes，以及 payload 的 before 状态。只有当前状态精确等于该 transaction 的 postimage 时才允许回滚；恢复原始 bytes，删除本事务新建且当前 hash 仍等于 expected payload hash 的文件，最后复核 base set。已处于 base preimage 时，重复 rollback 返回成功 no-op。任何外部修改都拒绝回滚，不能覆盖后来工作。

### R7. legacy duplicate requirement 和 pending 尚未隔离

设计稿把旧 object 标为 `legacy_unreconciled`，但 exact-one 查询的是全局 `field-requirements.csv`。正式库现有 29 个重复 target-field 键，且 requirement 没有 card owner。GA100 或下一张卡复用共享 architecture target 时，旧重复行可能让 `ExactlyOneSameFieldSevenTargetRequirement` 失败；若实现者改成任取一行，又会静默忽略冲突。26 条正式 pending 和 GA100 v2 的 49 条 staging pending 也没有可执行的代际边界。

设计文档应新增 manifest 外、独立批准的 `legacy-requirement-disposition.csv`，固定列为：

`requirement_id,baseline_canonical_row_sha256,disposition,canonical_requirement_id,reviewed_by,reviewed_date,approval_status,notes`

`disposition` 只允许 `legacy_unreconciled`、`canonical_reusable`、`retired_duplicate`。全部迁移前 requirement 必须 set-equal 命中一次；`retired_duplicate` 必须指向同 field/七目标键的 canonical requirement；新合同创建的 requirement 不得进入 legacy registry。

发布卡的 include candidate 通过 R3 新增的 `requirement_id` 显式选择一行。validator 要求该行达到发布状态；同键的其他行只能是已批准的 legacy/retired 行，任何 current 重复仍失败。legacy pending 不进入新 closure，但当前卡显式选择的 requirement 以及 GA100 v3 新建 requirement 不得以 `pending_verification` 进入 provisional/formal。registry、基线 row hash 和 approval hash必须进入 transaction input 与 coverage manifest binding。

### R8. 三运行时 fixture 和模板迁移还没有形成交付件

设计稿列出了 fixture 类型，但没有 fixture 文件格式、每个正例的 expected canonical bytes/hex/SHA-256、每个负例的统一 error code，也没有三端输出。`只允许文件起始单个 BOM` 与“受控工作包 CSV 无 BOM”之间也未区分 legacy reader 和 canonical artifact。

设计文档需要规定：受控 manifest、policy、transaction JSON 和工作包 CSV 一律 UTF-8 无 BOM；strict reader 可以为 legacy 正式 CSV 接受单个起始 BOM，但进入 canonical hash 前必须按目标 artifact schema 重写，raw canonical artifact 与重写 bytes 不相等即失败。fixture 清单至少有 `fixture_id,input_kind,input_file,expected_valid,expected_canonical_hex,expected_sha256,expected_error_code`，并保存 PS5.1、PS7、Python 三端实际输出。中文、前后空格、空字符串/null、引号、反斜杠、控制字符、U+2028/U+2029、supplementary-plane、BOM、三种换行、escaped pipe、重复/未知 key、浮点、非法 UTF-8、未配对 surrogate、cell 内换行、错误 endpoint/source 和真实/伪日期都要有明确正负结论。三端 bytes 和 SHA 不全等时，合同不能上线。

模板方向正确，但落盘清单不完整。合同事务必须同时更新 `资料卡/模板.md` 和 `资料卡/字段字典.md`：第 2 节把 HBM stacks 和 HBM total interface width 固定拆成两行；所有允许显示缺失的标识列统一为 `<fact_id / requirement_id / factor_requirement_id>`；卡头 cutoff 连接 identity metadata；`silicon_package` 继续映射正式 `object_type=die`，不新增阅读层 `die`；最小来源角色加入 `coverage_obligation_evidence`；数据链说明加入 field/factor requirement、search result 和实际 endpoint。README、AGENTS、研究计划和当前状态中的正式计数也应随合同事务更新，历史审计快照不改写。

## 通过项与重新申请条件

本轮对以下设计边界没有提出撤回要求：field candidate 与 binding 对 independently built expected pairs 做双重 set-equal；exclude 不能代替 requirement 状态；GA100 108 个 precision-path cell 由外部 mandatory policy 强制 include；selection run 继续使用 object scope；factor obligation 覆盖真实芯片因素并排除 workload；假 capability/topology 不再作为 gap；coverage approval 对 manifest 的单向 hash 没有循环；HBM stack/interface 拆行。

重新申请实现前验收时，设计稿必须先吸收 R1 至 R8，并给出更新后的精确基线。按本轮推荐的单列 endpoint 修复，目标是 34 表、376 columns、140 fields、77 enum groups、562 enum rows。随后提交 policy/date-policy/registry/manifest/transaction 的机器可读 schema、完整 golden fixtures 和预期 hash。三运行时 fixture 通过属于合同实现门；GA100 v3 的实际检索、49 条 staging pending 裁决、MIG 610 移除、六源 reverse-removal、19 个 payload 和 Windows 三道项目 gate 属于后续芯片事务，不能拿来替代本次合同设计验收。

## 写入与复读记录

本轮只新增 `审计/子代理交接/r1_contract_07_design_v2_independent_review.md`。报告按 engineering audit 语气编写。`report-humanizer` 单文件机器扫描无命中；人工从重新申请条件逆向复读 transaction、legacy、canonical、factor、mandatory、scope、cutoff 和算术，没有发现结论、数字或证据强度前后冲突。Windows runtime 缺失仍保留为明确的未执行边界。
