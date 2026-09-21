# GA100 资料卡合同修复设计 v3

## 设计状态与写入边界

本稿把 SHA-256 为 `33a9193978ed08b855702d45bf1373a5bb55642458cb27da087f3c34ca0d7e27` 的 `r1_contract_07_design_v2_independent_review.md` 作为 R1 至 R8 的硬约束。后续来源复核又确认 instruction latency 是不可丢失的 compute factor，因此本稿在不改变 34 表、376 列和 108 mandatory cell 的前提下新增一个正式 field；这项修订明确取代 R07 当时按“141−DATA-CUTOFF”得到的 140-field 派生值。它是机器合同设计，不是正式迁移许可。本轮只新增本文件，没有修改正式表、validator、模板、字段字典、活动名单、GA100 staging 或进度文件。

合同迁移后的精确正式基线固定为 34 张表、376 个 schema column、141 个 field、77 个 enum group、562 个 enum row、78 个 object 和 585 条 card-completeness。GA100 v3 属于后续芯片事务，完成后才增加 GA100 object 和 13 条 completeness。

## 共享标量、空值和顺序

后文所有 JSON 禁止未知 key、重复 key、大小写碰撞 key 和 schema 外 value type。所有 CSV 禁止未知列、重复列、缺列、cell 内 CR/LF 和 header 顺序变化。

| 名称 | 机器类型与格式 |
|---|---|
| `id` | JSON string 或 CSV text；非空；`^[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)*$` |
| `scope_id` | string；`^SCOPE-[0-9]{4,}$` |
| `sha256` | string；小写 `^[0-9a-f]{64}$` |
| `date` | string；真实存在的 Gregorian `YYYY-MM-DD` |
| `uint` | JSON integer 或 CSV 十进制整数；`0` 或无前导零的正整数；禁止浮点 |
| `bool` | JSON `true/false`；CSV 小写 `true/false` |
| `text` | Unicode scalar string；不 trim、不 case-fold、不作 normalization |
| JSON nullable | 只能写 JSON `null`，不能用空字符串代替 |
| CSV nullable | 只能写空 cell；字符串 `null` 仍是普通文本 |
| set array | 元素唯一，按元素 canonical UTF-8 bytes 升序；空集为 `[]` |

ID 中确需下划线或小写的既有正式主键不因本合同改名；读取 legacy row 时沿用原值。上述 `id` 正则只约束本合同新建的 manifest、policy、approval、registry、operation 和工作包 ID。所有 ordered JSON key 和 CSV column 的顺序均由本文件固定。

## 正式 schema 迁移

### 计数复算

正式基线按下式迁移：

```text
tables:         32 + 2 factor tables = 34
schema columns: 346 + 4 scope/card + 20 factor + 5 search/evidence + 1 assertion endpoint = 376
fields:         141 - FIELD-ID-DATA-CUTOFF + FIELD-COMP-INSTRUCTION-LATENCY = 141
enum groups:    76 + card_lifecycle = 77
enum rows:      557 - historical_anchor + 5 lifecycle + coverage_obligation_evidence = 562
```

`FIELD-ID-DATA-CUTOFF` 在正式 facts、field-requirements 和 fact-assertions 中均没有引用；`product_status.historical_anchor` 也没有正式 fact 引用。删除这两行不产生孤立外键。卡级截止日迁到 identity completeness metadata。新增 instruction latency field 抵消被删 field，所以正式 field 总数仍为 141。

### field contract 的两项时延修订

合同事务把 `FIELD-MEM-LATENCY.canonical_unit` 从 `s` 改为空，definition 继续限定 memory latency；该 field 的 normalized_unit 只允许 `s` 或 `cycle`。来源只给 cycle 而没有同一 clock domain 的可靠频率时，必须原样保存 cycle，禁止换算成秒。若要换算，另建 derived fact，输入必须包括 cycle latency 和同 scope/clock domain 的频率 fact，并通过派生 DAG 门。

同时插入以下完整 field row；不把 instruction cycles 塞进 memory、benchmark、workload 或 tile field：

```text
field_id=FIELD-COMP-INSTRUCTION-LATENCY
field_domain=compute
field_name_zh=指令级延迟/周期
definition=特定 instruction/opcode 在明确 dependency、instruction mapping、SASS/toolchain 与 clock domain 条件下的 latency；未知条件必须显式保留
value_kind=number
canonical_unit=cycle
value_enum_name=<empty>
allowed_subject_kinds=component;precision_path
condition_schema=compute
required_tier=important
review_status=approved
notes=合同 v3 新增；禁止与完整 workload latency 混用
allowed_requirement_target_kinds=component;precision_path
```

该 field 不加入 GA100 12×9 mandatory set，所以 108 不变；它仍参加 141-field 全候选 builder，并由 target subtype selector 决定 component/path include。instruction latency fact 的 condition-set.notes 必须是 exact-key canonical JSON object，key 顺序为 `condition_contract_version,instruction_or_opcode,dependency_pattern,instruction_mapping,toolchain_or_disassembler,clock_domain,clock_frequency_known,source_condition_text`。前六项为非空 string，clock_frequency_known 为 bool，source_condition_text 为 string|null；version 固定 `INSTRUCTION-LATENCY-CONDITION-V1`，未知值写明确的 `unknown`，不能省 key。known=true 时 condition-set.frequency_value/unit 均非空，known=false 时均为空；operation_type、operation_count_rule、software_version 与 JSON 中的 instruction/dependency/toolchain 值必须按 validator 映射一致，不一致即失败。

### 既有表的精确改列

| 表 | 改动 | 新列规则 |
|---|---|---|
| `数据/objects.csv` | 在 `notes` 后增加 `scope_id` | nullable `scope_id`；FK 由项目规则指向活动 allocation；semicolon forbidden |
| `数据/card-completeness.csv` | 在 `notes` 后依次增加 `card_lifecycle,data_cutoff_date,scope_id` | 三列 nullable；只允许 identity row 非空；scope semicolon forbidden |
| `最小参考资料库/search-log.csv` | `requirement_id` 改 nullable；其后增加 `factor_requirement_id` | 两个 requirement FK 恰一非空 |
| `最小参考资料库/search-results.csv` | 在 `source_id` 后依次增加 `endpoint_id,checked_locator_or_scope` | 两列 nullable 以容纳 legacy；新 closure 必填；endpoint/source 同源 |
| `最小参考资料库/requirement-evidence.csv` | `requirement_id` 改 nullable；其后增加 `factor_requirement_id`；在 `source_id` 后增加 `endpoint_id` | 两个 requirement FK XOR；新 closure endpoint 必填 |
| `最小参考资料库/fact-assertions.csv` | 在 `source_id` 后增加 `endpoint_id` | nullable 以容纳尚未核对入口的 legacy；新 closure 必填；同步迁移 assertion fingerprint |

`card_lifecycle` 的五个正式 enum value 依次为 `legacy_unreconciled,draft,provisional,formal,archived`。`selected_role` 追加 `coverage_obligation_evidence`。不引入 `superseded`。

每个有 completeness 的 object 仍恰有一条 identity row。identity 以外的 `card_lifecycle,data_cutoff_date,scope_id` 必须全空。`provisional/formal/archived` 的 identity 三列均非空；`legacy_unreconciled/draft` 允许 cutoff 和 scope 为空。objects.scope_id 非空时，同 object 必须有 identity row 且 scope 相等；identity scope 非空时 objects.scope_id 也必须相等。

迁移不保留旧式 assertion fingerprint。合同事务对当前 832 条 fact assertion 全量执行 update：`endpoint_id` 先写 CSV 空 cell，并把 `assertion_fingerprint` 改成 `AFPV2-` 加 64 位小写 SHA-256。hash payload 是 exact-key canonical JSON array `[fact_id,source_id,endpoint_id,assertion_relation,source_locator]`，其中 CSV 空 endpoint 映射为 JSON `null`，非空 endpoint 映射为 JSON string；framing domain 固定 `assertion-fingerprint-v2`。每条 update 都在 operations 中保存 V1 preimage、含空 endpoint 的 V2 input 和 V2 postimage。迁移后 validator 只接受 AFPV2；补录或改动 endpoint 时必须同步重算。新 assertion 禁止写旧 `fact|source|relation|locator` 形式。`provisional/formal` closure 另要求 endpoint 非空，因此带 JSON null 计算的 legacy V2 仍不能进入新卡发布链。

合同迁移时，45 个既有 identity row 写 `legacy_unreconciled`，行数仍为 585。初始 10 个冻结对象已有 formal object ID，但 `OBJ-NVIDIA-GH100-DIE` 没有 completeness；因此只给已有 identity 的 9 个 object 和 identity row 写 scope。GH100 先保留 `pending_identity_review` mapping，objects.scope_id 为空，直到其芯片工作包补齐 completeness。不能为了凑 10 个映射在合同事务中新增第 586 条 completeness。

### 两张新正式表

`数据/factor-requirements.csv` 固定 9 列：

```text
factor_requirement_id,card_object_id,policy_id,factor_id,requirement_status,applicability_reason,requirement_fingerprint,review_status,notes
```

逐列类型与空值为 `factor_requirement_id:id!`、`card_object_id:text!`、`policy_id:id!`、`factor_id:id!`、`requirement_status:enum!`、`applicability_reason:text?`、`requirement_fingerprint:sha256!`、`review_status:enum!`、`notes:text?`。`factor_requirement_id` 是 PK，使用 `REQ-FACTOR-*`，并与 field-requirements.requirement_id 跨表全局唯一。`card_object_id` FK 到 objects；两个 status 复用正式 enum。fingerprint 为 domain `factor-requirement-fingerprint-v1` 下 `[card_object_id,policy_id,factor_id]` exact-key canonical JSON array 的 framed SHA-256。

`数据/factor-target-bindings.csv` 固定 11 列：

```text
factor_target_binding_id,factor_requirement_id,object_id,component_id,link_id,object_relation_id,precision_path_id,capability_id,topology_id,review_status,notes
```

逐列类型为 `factor_target_binding_id:id!`、`factor_requirement_id:id!`、七个 `*_id:text?`、`review_status:enum!`、`notes:text?`。七 target 列恰一非空。PK 为 `factor_target_binding_id`；`(factor_requirement_id,target_kind,target_id)` 复合唯一。target FK 与 facts 相同。

## 唯一活动名单与 scope 历史

### 活动名单

`清单/训练与推理芯片名单.md` 继续是唯一范围维护入口，不创建第二份活动对象名单。`## 正式名单` 下的表头固定为：

```markdown
| scope_id | 厂商 | 芯片对象 | 层级 | 角色 | 共享设计组 | 一手身份来源 |
|---|---|---|---|---|---|---|
```

初始 49 行通过一次性签字迁移把归档 `freeze_row_id` 绑定到 `SCOPE-0001` 至 `SCOPE-0049`。GA100 固定为 `FREEZE-NV-001 → SCOPE-0001`。活动表的 scope 集合必须与 allocation registry 中 `allocation_state=active` 的集合 set-equal。Markdown parser 只读取这一个标题下的第一张表；数据行必须有首尾 pipe。parser 在每个 delimiter 内侧至多移除一个作为表格 padding 的 ASCII space，其余字符原样保留；未转义 `|` 分列，`\|` 保留反斜杠和 pipe 两个 scalar。跨行 cell、未闭合 link/code span、重复 scope 或列数不等于 7 均失败。

### scope-id-registry.csv

固定路径为 `审计/合同注册表/scope-id-registry.csv`。

固定列序：

```text
scope_allocation_id,freeze_row_id,scope_id,allocation_state,active_list_row_canonical_sha256,allocation_basis,allocated_by,allocated_date,reviewed_by,reviewed_date,approval_status,notes
```

逐列类型为 `scope_allocation_id:id!`、`freeze_row_id:text?`、`scope_id:scope_id!`、`allocation_state:enum!`、`active_list_row_canonical_sha256:sha256!`、`allocation_basis:text!`、`allocated_by:text!`、`allocated_date:date!`、`reviewed_by:text!`、`reviewed_date:date!`、`approval_status:enum!`、`notes:text?`。`freeze_row_id` 只允许新增范围行为空；active 时 hash 取当前活动行，tombstoned 时保留最后 active row hash。`allocation_state` 仅 `active,tombstoned`；`approval_status` 仅 `draft,reviewed,needs_resolution,approved,rejected`。发布只接受 active+approved。

`scope_allocation_id` 为 PK；`scope_id`、非空 freeze_row_id 在全历史唯一。row identity、scope、freeze ID、allocation basis 和初始分配人/日期不得更新或删除。活动名单内容变化时，只能由有 pre/postimage 的受批准事务更新 row hash 与 review 元数据；退出时同一 row 更新为 tombstoned 并从名单移除，不能追加同 scope 的第二条 allocation。新 scope 编号等于 active 与 tombstoned 全历史最大编号加一，不填补空号，scope 永不复用。

### scope-object-mapping.csv

固定路径为 `审计/合同注册表/scope-object-mapping.csv`。

固定列序：

```text
mapping_event_id,mapping_event_seq,freeze_row_id,scope_id,formal_object_id,proposed_formal_object_id,mapping_status,mapping_basis,reviewer,review_date,approval_status,notes
```

逐列类型为 `mapping_event_id:id!`、`mapping_event_seq:uint!`、`freeze_row_id:text?`、`scope_id:scope_id!`、`formal_object_id:text?`、`proposed_formal_object_id:text?`、`mapping_status:enum!`、`mapping_basis:text!`、`reviewer:text?`、`review_date:date?`、`approval_status:enum!`、`notes:text?`。freeze row 非空时必须等于 allocation；event ID 为 PK；`(scope_id,mapping_event_seq)` 唯一；seq 从 1 连续递增。旧 event 不更新、不删除。

| mapping_status | formal_object_id | proposed_formal_object_id | reviewer/date | 可作为有效映射 |
|---|---|---|---|---|
| `unmapped` | 空 | 空 | approved 时必填 | 否 |
| `pending_identity_review` | 空 | 必填 | 可空；approved 不允许 | 否 |
| `pending_formal_object_create` | 空 | 必填 | 可空；approved 不允许 | 否 |
| `mapped` | 必填 | 空 | 必填 | 仅 approval_status=approved |
| `retired` | 必填 | 空 | 必填 | 否；保留历史占用 |
| `tombstoned` | 可空；有历史映射时必填 | 空 | 必填 | 否 |

同一 formal object ID 在全部 approved mapped/retired/tombstoned 历史中只能属于一个 scope。非空 proposed ID 不能同时出现在两个未 rejected 的有效事件链。`LatestApprovedMapping` 取最大 seq 的 approved mapped event；若存在更高 seq 且 approval status 不是 rejected 的 event，发布阻断，不能继续沿用旧 mapping。mapped object 的 objects.scope_id、identity.scope_id 和 mapping.scope_id 必须逐字相同。

selection run 保持 object scope：`selection-runs.scope_kind=object`，`selection-runs.scope_id=manifest.card_object_id`。`SCOPE-*` 只通过 approved mapping 连接，不写入 selection-runs.scope_id。

## coverage policy 和 approval

### coverage-policy-v3.0.json

固定路径为 `审计/合同注册表/coverage-policy-v3.0.json`；approval 紧邻存放。

顶层 key 只能按以下顺序出现。括号内为类型和 nullable；未标 nullable 均非空。

```text
coverage_policy_contract_version (string)
policy_id (string)
effective_date (date)
supersedes_policy_id (string|null)
target_kind_order (array[string])
include_reason_codes (array[string])
exclude_reason_codes (array[string])
projection_rules (array[object])
predicates (array[object])
field_rules (array[object])
field_unit_rules (array[object])
factor_rules (array[object])
zero_included_field_factor_map (array[object])
ga100_mandatory_policy (object)
prepared_by (string)
prepared_date (date)
reviewed_by (string)
reviewed_date (date)
review_status (string)
notes (string|null)
```

`coverage_policy_contract_version` 固定 `COVERAGE-POLICY-V3`。`target_kind_order` 是 ordered array，必须逐字等于 `object,component,link,object_relation,precision_path,capability,topology`；其余具有集合语义的 scalar array 去重后按元素 canonical UTF-8 bytes 排序。include code 只允许 `mandatory_include,selector_match,card_scope_requirement`；exclude code 只允许 `target_subtype_mismatch,wrong_owner_scope,architecture_only_not_implementation,implementation_only_not_architecture,explicit_card_scope_exclusion`。projection、predicate、field、field-unit、factor 和 zero-map object array 分别按 `projection_rule_id,predicate_id,field_id,field_unit_rule_id,factor_id,field_id` 排序且主键唯一；顶层 `review_status` 固定 reviewed，reviewed_by 与 prepared_by 不同。

`projection_rules` 每项 key 顺序和类型为：

```text
projection_rule_id(string),card_selector_predicate_id(string),relation_type(string),direction(string),min_count(uint),max_count(uint|null),review_status(string),notes(string|null)
```

direction 固定 `subject_to_object`，relation type 固定 `implements_architecture`。max 为 null 表示无有限上界。

`predicates` 每项 key 顺序为：

```text
predicate_id(string),predicate_scope(string),all_of(array[object]),none_of(array[object]),review_status(string),notes(string|null)
```

predicate_scope 仅 `card,target,structural_na`。每个 clause 的 key 顺序为 `table_path(string),column_name(string),operator(string),values(array[string])`。operator 仅 `equals,in,is_empty,is_nonempty,reachable_match_count_equals`；`equals/is_empty/is_nonempty/reachable_match_count_equals` 的 values 长度分别为 1/0/0/1，计数值使用 uint 文本。all_of 是 AND；none_of 中任一 clause 为真即 predicate 为假。table/column 必须来自完整 376-column schema；target clause 只读当前 candidate row 和其 reachable envelope，structural N/A clause 只读 card、candidate 和 inventory aggregate。禁止自由文本表达式、跨 scope 查询和可执行代码。

`field_rules` 每项 key 顺序为：

```text
field_id(string),card_selector_predicate_id(string),mandatory_target_selector_predicate_ids(array[string]),allow_structural_na(bool),structural_na_predicate_id(string|null),allowed_exclude_reason_codes(array[string]),review_status(string),notes(string|null)
```

field candidate target kind 仍从正式 `fields.allowed_requirement_target_kinds` 读取，policy 不得缩小 builder 全集。allow_structural_na=false 时 predicate ID 必须 null；为 true 时必须非空且 predicate_scope=structural_na。

policy.field_rules 的 field_id 集必须与完整 141-field contract set-equal，每个 field 恰一条 rule。factor_rules 的 factor_id 是经独立批准的 factor universe，主键唯一；validator 只能从这些 rule 生成 obligation，不接受 policy 外隐式 factor。所有 card/target/structural predicate ID、projection rule ID、zero-map factor ID、identity/explains field ID 都做 exact FK。每个 predicate 必须被 field/factor/projection/zero-map 至少引用一次；每条 projection rule 都由其 card selector 对当前 card 作适用性裁决。悬空或未引用 predicate、重复对象 ID、factor 外映射或 selector 指向错误 predicate_scope 均失败。

`field_unit_rules` 每项 key 顺序为：

```text
field_unit_rule_id(string),field_id(string),allowed_normalized_units(array[string]),conversion_policy(string),condition_contract_id(string),review_status(string),notes(string|null)
```

v3 必须且只能包含两行：`FIELD-MEM-LATENCY` 允许 canonical-sorted `{cycle,s}`，conversion policy 固定 `preserve_source_unit_no_implicit_conversion`，condition contract 为 `MEMORY-LATENCY-CONDITION-V1`；`FIELD-COMP-INSTRUCTION-LATENCY` 只允许 `{cycle}`，conversion policy 固定 `no_conversion`，condition contract 为 `INSTRUCTION-LATENCY-CONDITION-V1`。其他 number field 继续服从 fields.canonical_unit。memory cycle→s 只能通过带 frequency input 的 derived fact，不能直接改 normalized_unit。

memory latency fact 的 condition-set.notes 同样是 exact-key canonical JSON，key 顺序为 `condition_contract_version,memory_level_or_path,access_operation,dependency_pattern,working_set_or_measurement_scope,clock_domain,clock_frequency_known,software_or_product_condition,source_condition_text`。version、memory/path、access、dependency、working-set/scope、clock domain 和 software/product condition 为非空 string，clock_frequency_known 为 bool，source_condition_text 为 string|null；version 固定 `MEMORY-LATENCY-CONDITION-V1`，未知条件写 `unknown`。condition-set 的 operation_type、operation_count_rule、measurement_scope、software_version 和 frequency_value/unit 必须与 JSON 对应；frequency known true/false 的 nullable 门与 instruction contract 相同。normalized_unit=cycle 时 clock_domain 至少是非空明确值或字面 `unknown`，不得省略；没有可靠频率仍保存 cycle，不得伪造换算。两个 condition contract ID 都进入 policy canonical hash、validator 分派和正负 fixtures。

`factor_rules` 每项 key 顺序为：

```text
factor_id(string),factor_label(string),card_selector_predicate_id(string),allowed_target_kinds(array[string]),target_subtype_predicate_id(string),min_targets_if_available(uint),allow_not_applicable(bool),structural_na_predicate_id(string|null),minimum_source_types(array[string]),minimum_source_authorities(array[string]),identity_field_ids(array[string]),explains_field_ids(array[string]),review_status(string),notes(string|null)
```

allowed target kind 使用七目标受控集合。`min_targets_if_available` 必须大于 0。N/A 的 nullable 规则与 field 相同。source type/authority 必须来自正式 enum。identity/explains field 必须存在于 141-field contract。factor 只覆盖 component 类别、memory level、link、topology、special capability 和其他芯片绑定机制；模型、batch、序列/上下文长度、MoE 通信量、KV Cache 迁移量不得出现在 factor ID、label、selector 或 explains field 中。

`zero_included_field_factor_map` 每项 key 顺序为：

```text
field_id(string),card_selector_predicate_id(string),factor_ids(array[string]),review_status(string),notes(string|null)
```

它处理 `included_target_count=0`，而非只处理 raw candidate 为 0。factor_ids 非空，且每个 factor 对同一卡可适用并在 explains_field_ids 中含该 field。对某个 work package，validator 派生所有 zero-included field，再要求其 field ID 集与 card selector 命中的 map row 集 set-equal；有 include target 的 field 不得残留 applicable map row。

`ga100_mandatory_policy` 的 key 顺序为：

```text
scope_id(string),card_object_id(string),field_ids(array[string]),precision_path_ids(array[string]),expected_cell_count(uint),expected_key_set_canonical_sha256(sha256)
```

scope 固定 `SCOPE-0001`，card object 固定 `OBJ-NVIDIA-GA100-DIE`，expected count 固定 108。field_ids 固定以下 12 项并按 canonical bytes 排序：

```text
FIELD-NUM-ACCUMULATION
FIELD-NUM-OPERAND-A
FIELD-NUM-OPERAND-B
FIELD-NUM-OUTPUT
FIELD-NUM-PHYSICAL-ACCUM
FIELD-NUM-PRODUCT
FIELD-NUM-ROUNDING
FIELD-NUM-SATURATION
FIELD-NUM-SCALING-GRANULARITY
FIELD-NUM-SCALING-MODE
FIELD-NUM-SPARSITY
FIELD-NUM-SUBNORMAL
```

precision_path_ids 固定以下 9 项并按 canonical bytes 排序：

```text
PPATH-M2NA-AMPERE-TENSOR-BF16
PPATH-M2NA-AMPERE-TENSOR-FP16
PPATH-M2NA-AMPERE-TENSOR-FP64
PPATH-M2NA-AMPERE-TENSOR-INT8
PPATH-M2NA-AMPERE-TENSOR-TF32
PPATH-R1-GA100-AMPERE-TENSOR-BINARY
PPATH-R1-GA100-AMPERE-TENSOR-FP16-ACC16
PPATH-R1-GA100-AMPERE-TENSOR-INT4
PPATH-R1-GA100-TENSOR-FP16-DENSE
```

builder 对笛卡尔积生成 108 个 `(field_id,"precision_path",precision_path_id)` key，复算 hash 并与 policy 相等。每键必须 `decision=include,reason_code=mandatory_include`，不能 exclude；所引用 requirement 的 status 也不得为 `not_applicable`。这条禁令独立于普通 field structural N/A 规则。

### policy approval

`coverage-policy-approval.json` 的完整 key 顺序为：

```text
approval_contract_version(string)
approval_id(string)
artifact_kind(string)
artifact_id(string)
artifact_canonical_sha256(sha256)
approved_by(string)
approved_date(date)
approval_status(string)
notes(string|null)
```

contract version 固定 `ARTIFACT-APPROVAL-V1`；artifact kind 固定 `coverage_policy`；status 固定 `approved`。approved_by 与 policy.prepared_by 不同，approved_date 不早于 policy.reviewed_date。approval 只绑定已完成 policy canonical hash，policy 不含 approval hash。

## source-date policy 与实际 endpoint

policy 与 approval 的固定路径分别为 `审计/合同注册表/source-date-policy-v3.0.csv` 和 `审计/合同注册表/source-date-policy-approval.json`。

`source-date-policy-v3.0.csv` 固定列序：

```text
source_date_rule_id,source_date_policy_id,source_type,endpoint_type,content_mode,date_basis,publication_date_required,snapshot_date_required,access_fallback_allowed,allowed_accessibility_statuses,prepared_by,prepared_date,reviewed_by,reviewed_date,review_status,notes
```

逐列类型为 `source_date_rule_id:id!`、`source_date_policy_id:id!`、`source_type:enum!`、`endpoint_type:enum!`、`content_mode:enum!`、`date_basis:enum!`、三个 `*_required/*_allowed:bool!`、`allowed_accessibility_statuses:text!`、`prepared_by:text!`、`prepared_date:date!`、`reviewed_by:text!`、`reviewed_date:date!`、`review_status:enum!`、`notes:text?`；logical PK 是 source_date_rule_id。状态集合按正式 enum canonical 顺序用分号连接，且禁止空项和重复项。`(source_date_policy_id,source_type,endpoint_type)` 唯一；同一 policy 的 prepared/review 元数据逐字相同，reviewed_by 与 prepared_by 不同，review_status 固定 reviewed。所有进入 closure 的实际 source×endpoint type 组合恰好命中一条 rule。

content_mode 仅 `fixed_version,snapshot_of_dynamic,live_mutable`。date_basis 仅 `publication_only,snapshot_only,publication_then_snapshot_then_access`。publication_only 要求三个 bool 为 true/false/false；snapshot_only 要求 false/true/false；publication_then_snapshot_then_access 要求 false/false/显式 policy value，且只允许 fixed_version。`live_mutable` endpoint 不得直接进入发布 closure，必须改用同 source 的实际 snapshot endpoint；`snapshot_of_dynamic` 必须用 snapshot_only。access fallback 只在该实际 endpoint 所属 source 的 publication date 与 endpoint snapshot date 均空、rule 允许且 endpoint access date 非空时使用。

`source-date-policy-approval.json` 使用与 coverage policy approval 相同的 9 个 key，artifact_kind 固定 `source_date_policy`，artifact hash 是 date-policy canonical rowset hash，不是 raw CSV hash；approved_by 不得等于 prepared_by 或 reviewed_by。

fact-assertions、search-results 和 requirement-evidence 的新 closure 行都必须绑定实际 endpoint。endpoint.source_id 与行内 source_id 相等。fact assertion 使用 AFPV2；search result 的 checked locator、requirement evidence 的 source locator 均非空。preferred endpoint 不参与历史入口解析。

## legacy requirement 隔离

baseline registry、approval 和 reconciliation event registry 固定放在 `审计/合同注册表/`，文件名分别为 `legacy-requirement-disposition.csv`、`legacy-requirement-disposition-approval.json` 和 `legacy-requirement-reconciliation-events.csv`。

`legacy-requirement-disposition.csv` 固定列序：

```text
requirement_id,baseline_canonical_row_sha256,disposition,canonical_requirement_id,reviewed_by,reviewed_date,approval_status,notes
```

逐列类型为 `requirement_id:text!`、`baseline_canonical_row_sha256:sha256!`、`disposition:enum!`、`canonical_requirement_id:text?`、`reviewed_by:text!`、`reviewed_date:date!`、`approval_status:enum!`、`notes:text?`；logical PK 是 requirement_id。disposition 仅 `legacy_unreconciled,canonical_reusable,retired_duplicate`，approval status 固定 approved。retired_duplicate 必须有 canonical ID，且两行 field 与七目标键逐字相同；其他 disposition 的 canonical ID 必须为空。canonical_reusable 不得是 pending、draft、needs_resolution，且必须达到新 closure 门。迁移前 1,059 个 requirement ID 与 registry requirement ID set-equal；新合同 ID 禁止写入该 registry。

29 个重复 target-field group 必须逐组审查；不能按主键最小值自动选 canonical。不能裁清的行全部保留 legacy_unreconciled。26 条正式 pending 只能标 legacy_unreconciled。GA100 v2 的 49 条 staging pending 不属于这 1,059 行，v3 重新生成时全部完成实际裁决。

`legacy-requirement-disposition-approval.json` 复用 9-key artifact approval schema，artifact_kind 固定 `legacy_requirement_registry`，artifact hash 取全量 immutable registry canonical rowset，artifact_id 即 manifest 的 legacy_registry_id；approved_by 不得出现在 registry.reviewed_by 中。批准后 registry 不再更新；后续需重建的 legacy obligation 创建新 current requirement。

发布 candidate 显式选中的 requirement 必须 reviewed/approved，且不得为 `pending_verification`。它若属于 legacy registry，只能是 canonical_reusable；同键其他 legacy 行只能是批准的 legacy_unreconciled 或 retired_duplicate。除后述 approved successor 外，任何不在 registry 中的第二条同 field/七目标键 requirement 都是 current duplicate，立即拒绝；不能以较小主键、较新 review date 或任意一行优先来消歧。26 条正式 legacy pending 只留在 registry 隔离区，GA100 v2 的 49 条 staging pending 则必须在 v3 事务中逐条裁决或删除，二者都不能进入 provisional/formal closure。

immutable baseline registry 不阻止后续完成旧 obligation。新增 append-only `legacy-requirement-reconciliation-events.csv`，固定列序：

```text
reconciliation_event_id,reconciliation_event_seq,legacy_requirement_id,legacy_baseline_canonical_row_sha256,successor_requirement_id,successor_canonical_row_sha256,field_id,object_id,component_id,link_id,object_relation_id,precision_path_id,capability_id,topology_id,event_type,reconciliation_basis,reviewed_by,reviewed_date,approved_by,approved_date,approval_status,notes
```

逐列类型为 `reconciliation_event_id:id!`、`reconciliation_event_seq:uint!`、`legacy_requirement_id:text!`、`legacy_baseline_canonical_row_sha256:sha256!`、`successor_requirement_id:text?`、`successor_canonical_row_sha256:sha256?`、`field_id:text!`、七 target `*_id:text?`、`event_type:enum!`、`reconciliation_basis:text!`、`reviewed_by:text!`、`reviewed_date:date!`、`approved_by:text?`、`approved_date:date?`、`approval_status:enum!`、`notes:text?`。七 target 列恰一非空；logical PK 是 event ID，`(legacy_requirement_id,event_seq)` 唯一且 seq 从 1 连续递增。event_type 仅 `successor_proposed,successor_approved,successor_withdrawn`；approval_status 是本辅助合同专用集合 `draft,reviewed,needs_resolution,approved,rejected`，不复用正式 review_status。旧 event、旧 requirement 和 baseline registry 均不更新、不删除。

successor_proposed/approved 必须有 successor 两列；withdrawn 必须为空。successor 是 registry 外的新 current requirement，必须与 legacy row 的 field/七目标键逐字相同，且 event.successor_canonical_row_sha256 必须等于当前 successor requirement 完整 canonical row hash；它不等于 legacy baseline hash。successor status 已从 pending 裁成可发布状态，successor ID 在全 registry 只能被一个 legacy chain 引用。

状态机固定为：successor_proposed 只允许 draft/reviewed/needs_resolution/rejected，approver/date 为空；successor_approved 只允许 approved，approver/date 非空且 approver 与 reviewer 不同；successor_withdrawn 是经独立批准的 terminal revocation，也只允许 approved，approver/date 非空且独立。按 seq 倒序忽略 rejected proposal 后，若首个 event 是未决 proposal，则阻断；若是 successor_approved，则该 successor 是 ActiveSuccessor；若是 successor_withdrawn，则该 chain 暂无 active successor。新的 proposed/approved 可以引用新 successor ID，形成 replacement；批准后旧 ID 转为 InactiveHistoricalSuccessor。

InactiveHistoricalSuccessor 是曾至少命中一条 successor_approved event、但不等于当前 active 的 successor row。它必须继续物理存在，当前 row hash 等于该 ID 的最后 approved event.successor_canonical_row_sha256，且不得被任何 coverage include 选择；它不触发 duplicate。只有 rejected proposal 引用而从未 approved 的 row 不属于受控历史。全局同 field/七目标键最多一个 ActiveSuccessor。存在 active 时同键 legacy row 不可选；latest withdrawn 后，只有原本 canonical_reusable 的 legacy row 可恢复可选。include candidate 可选择 canonical_reusable legacy row 或 ActiveSuccessor；既非 active、也非受控 historical successor 的 registry 外同键 row 才是 current duplicate。这样 26 条 legacy pending 可由“新 current row + approved successor event”完成，replacement/withdrawal 也不会要求改 immutable disposition。

全局 validator 对完整 reconciliation registry 执行 append-only、FK、same-key、successor 唯一、Active/Inactive 分类和 pending-event 阻断。coverage closure 对本卡每个涉及 legacy 的 field/target key 收入该键全部 reconciliation chain，而不只收入当前授权 event；manifest 绑定 reconciliation schema 和这些 relevant event rowset，避免遗漏更高 seq，也避免无关 key 的新 event 使旧卡失效。产生 successor 的 transaction 必须原子 insert current requirement 与 reconciliation event，并分别保存 absent→present pre/postimage。

## 精确 reachability

先运行 `BuildExpectedProjectionRelations(card,policy,data)`：不读取 manifest，先枚举 merged data 里 `subject_object_id=card`、relation_type=`implements_architecture`、review_status=approved 的全部正向 relation；每条必须且只能命中一条 card selector 适用的 projection rule，未命中或多重命中都失败。再按每条 rule 的命中集合检查 min/max cardinality，结果并集就是 expected set。manifest.projection_relation_ids 必须与该 relation ID 集 set-equal，不能靠省略 rule 或少列 relation 缩小 inventory。随后 `BuildReachableInventory` 只使用以下有向规则：

1. 起点 object 集只有 manifest.card_object_id。
2. projection relation 必须同时属于 expected set 与 manifest set，subject 等于 card object，relation type 为 `implements_architecture`，review status 为 approved；只沿 subject→object 正向加入 0..N architecture object。
3. component 仅在 owner_object_id 属于 card/projection object 集时加入。每个已加入 component 的 parent chain 递归加入；parent 必须同 owner，visited set 防环。
4. precision path 仅在 component 已加入时加入。
5. memory level 仅在 memory_level_id 同时是已加入 component_id 时加入；memory parent chain 必须闭合且防环。它仍以 component 作为七目标 kind。
6. capability 仅在 owner_object_id 属于 card/projection object 集且空或非空 component_id 可解析到已加入 component 时加入。
7. link 仅在 owner_object_id 属于 card/projection object 集时加入。endpoint 只校验 FK，不扩张 object 集，不沿 endpoint 吸入 card、module、server 或 system。
8. topology 仅在 owner_object_id 属于 card/projection object 集时加入。
9. object_relation target 只包含 manifest 显式 projection relation；其他 relation 不进入 field candidate inventory。
10. 每个 target 以 `(target_kind,target_id)` ordinal 去重；重复 ID、跨 target kind ID collision、owner 缺失或 parent 环均失败。

reachable inventory row envelope 包含实体 table path、PK、全 canonical row、owner path 和 projection origin。后续新增共享 architecture 的反向 relation 或无关 scope 不改变旧 card inventory。

## field 与 factor 全候选工作包

以下工作包 CSV 与 coverage manifest/approval 都固定在该 chip transaction 的 `coverage/` 子目录；CSV 均为 UTF-8 无 BOM、LF、末尾恰一个 LF。所有 ID/target 列 semicolon forbidden。

### coverage-targets.csv

```text
coverage_target_id,work_package_id,field_id,object_id,component_id,link_id,object_relation_id,precision_path_id,capability_id,topology_id,decision,reason_code,reason_text,requirement_id,review_status,notes
```

逐列类型为前三个 `*_id:id!`、七 target `*_id:text?`、`decision:enum!`、`reason_code:enum!`、`reason_text:text!`、`requirement_id:text?`、`review_status:enum!`、`notes:text?`；logical PK 是 coverage_target_id。七 target 列恰一非空。decision 仅 include/exclude，review status 固定 reviewed 或 approved。include 时 requirement ID 必填；exclude 时必须为空。candidate key 为 `(field_id,target_kind,target_id)`。

### factor-target-candidates.csv

```text
factor_target_candidate_id,work_package_id,factor_requirement_id,factor_id,object_id,component_id,link_id,object_relation_id,precision_path_id,capability_id,topology_id,decision,reason_code,reason_text,review_status,notes
```

逐列类型为前四个 `*_id:id!`、七 target `*_id:text?`、`decision:enum!`、`reason_code:enum!`、`reason_text:text!`、`review_status:enum!`、`notes:text?`；logical PK 是 factor_target_candidate_id。七 target 列恰一非空，其余 nullable 如标记。candidate key 为 `(factor_requirement_id,target_kind,target_id)`。policy subtype selector 命中必须 include 且 reason=selector_match；kind allowed 但 subtype 不匹配才可 exclude，reason 只能 target_subtype_mismatch。

### reachable-target-bindings.csv

```text
reachable_target_binding_id,work_package_id,coverage_target_id,field_id,object_id,component_id,link_id,object_relation_id,precision_path_id,capability_id,topology_id,resolved_table_path,resolved_primary_key_canonical_json,resolved_row_canonical_sha256,chain_node_ids_canonical_json,chain_canonical_sha256,review_status,notes
```

逐列类型为前三个 `*_id:id!`、`field_id:text!`、七 target `*_id:text?`、`resolved_table_path:text!`、`resolved_primary_key_canonical_json:text!`、`resolved_row_canonical_sha256:sha256!`、`chain_node_ids_canonical_json:text!`、`chain_canonical_sha256:sha256!`、`review_status:enum!`、`notes:text?`；logical PK 是 reachable_target_binding_id。七 target 列恰一非空。最后 chain node 必须等于 candidate target；resolved table/PK/row hash 必须匹配该最后节点。chain array item 的 exact key 顺序为 `target_kind,target_id,row_canonical_sha256`。首节点为 card object；projection object 经过显式 relation node；component 经过 owner 与 parent chain；precision path 再追加 path；capability/link/topology 追加各自节点；object relation 以 relation 为末节点。数组有序、不重复，chain hash 使用 domain `reachable-chain-v1`。

### coverage-fields.csv

```text
coverage_field_id,work_package_id,field_id,raw_candidate_count,included_target_count,excluded_target_count,closed_requirement_count,mapped_factor_count,closed_factor_count,coverage_status,review_status,notes
```

逐列类型为 `coverage_field_id:id!`、`work_package_id:id!`、`field_id:text!`、六个 `*_count:uint!`、`coverage_status:enum!`、`review_status:enum!`、`notes:text?`；logical PK 是 coverage_field_id，field_id 在 work package 内唯一。coverage_status 仅 `closed_by_targets,closed_by_factors,closed_by_targets_and_factors,unclosed`，完全由 validator 派生。文件内容必须逐 cell 等于 derivation，不接受作者自报。

### coverage-exclusion-review.csv

```text
exclusion_review_id,work_package_id,candidate_kind,candidate_id,candidate_key_canonical_sha256,exclusion_reason_code,reviewed_by,reviewed_date,approval_status,notes
```

逐列类型为 `exclusion_review_id:id!`、`work_package_id:id!`、`candidate_kind:enum!`、`candidate_id:id!`、`candidate_key_canonical_sha256:sha256!`、`exclusion_reason_code:enum!`、`reviewed_by:text!`、`reviewed_date:date!`、`approval_status:enum!`、`notes:text?`；logical PK 是 exclusion_review_id。candidate_kind 仅 `field_target,factor_target`；approval_status 固定 approved。每条 exclude candidate 恰有一条 review，reviewed_by 与 package prepared_by 不同。include candidate 不得出现。

### 全集规则

field expected pairs 为所有 `field × reachable real target` 中 target kind 出现在 fields.allowed_requirement_target_kinds 的组合。coverage-targets 和 reachable-target-bindings 的 candidate key 都与 expected pairs set-equal，每键恰一行。mandatory 108 项全部 include 且不得 not_applicable。普通 include 精确引用一条 same-field/same-seven-target requirement；exclude 不得引用 requirement。

factor expected obligations 由 card object 与 approved policy 独立生成，factor-requirements 必须 set-equal。`BuildExpectedFactorTargetPairs` 对每个 obligation 与全部 reachable、kind-allowed target 生成全集；factor-target-candidates 与它 set-equal。factor-target-bindings 的键集合必须与 include factor candidate 集合 set-equal。`min_targets_if_available` 只是额外下界，不能替代全集。

每个 field 的发布门按 `included_target_count` 判断。至少一个 include 时，所有 include requirement 必须闭合；等于 0 时，policy 必须映射至少一个 applicable factor，且所映射 factor 全部闭合。raw candidate 非零但全部 exclude 也走 factor 门。coverage-fields 的 mapped_factor_count 是适用 factor_rules 中 explains_field_ids 含该 field 的唯一 factor 数，closed_factor_count 是其中闭合数；zero-map factor 必须属于该集合。coverage status 由 target/factor 两类 count 机械派生。

非 mandatory field 的 `not_applicable` 除非 policy.allow_structural_na=true、structural predicate 在当前 data/inventory 上为真且理由非空，否则失败。GA100 mandatory cell 禁止 not_applicable，不能用自由文本 N/A 绕过。

factor candidate decision 只裁决真实 target 是否属于 factor selector，不裁决该 factor 的值是否公开。所有 include candidate 无论 requirement_status 为何都必须有正式 binding；binding key 与 include candidate set-equal 的规则先于 status gate 执行。factor、binding、search、result 和 evidence 的 review status 均须 reviewed/approved。status 闭合固定如下：

| requirement_status | binding 集 | 必要来源链 |
|---|---|---|
| `value_available` | 与 include candidates 相等，非空，且数量不小于 min_targets_if_available | 每个 binding 有 policy identity field、accepted fact 和 AFPV2 accepted assertion；还必须有 factor-specific `source_confirmed` log 及至少一条 `supports_requirement` result。result 的 source/actual endpoint 与身份 assertion 同源，或命中 policy 允许的独立 source type/authority。 |
| `not_found` | 与 include candidates 相等，可空 | 至少一条 `no_reliable_result` log；每个实际检索 source 都有 endpoint/locator 非空的 `checked_no_support` 或不计覆盖的 `duplicate` result，且 source type/authority 满足 policy。 |
| `not_public` | 与 include candidates 相等，可空 | 至少一条 `supports_not_public` evidence，source、实际 endpoint 和 locator 完整。 |
| `not_applicable` | include candidates 与 binding 都为空 | factor rule 允许 N/A、structural predicate 为真、理由非空；policy 要求 evidence 时另有 `supports_not_applicable`。 |
| `inaccessible_evidence` | 与 include candidates 相等，可空 | 至少一条 `blocked` log 和一个 endpoint 可解析的 `inaccessible` result。 |
| `pending_verification` | 与 include candidates 相等，可空 | 只允许 draft；provisional/formal 拒绝。 |
| `conflicting_unresolved` | 与 include candidates 相等，可空 | 第一版无条件拒绝。 |

`candidate_found/source_confirmed/blocked/no_reliable_result` 分别要求 candidate、supports_requirement、inaccessible、仅 checked_no_support/duplicate 的相容 result 集。field requirement 的 value/not_found/not_public/not_applicable/inaccessible/pending/conflict 采用同一套 endpoint、检索和 lifecycle 门；value_available 需要 same-target accepted fact，conflict 使用后述 conflict closure。这里没有 `IfSearchWasUsed` 分支。

## canonical bytes、domain separation 与 hash

### strict encoding

受控 JSON 和工作包 CSV 必须是 UTF-8 无 BOM。legacy 正式 CSV reader 可以接受单个起始 BOM；正文 BOM、非法 UTF-8、overlong encoding、未配对 surrogate、非 Unicode scalar 均拒绝。canonical 输出不含 BOM。

JSON 无额外空白。key 使用 schema 顺序。string 只转义引号、反斜杠和 U+0000 至 U+001F；控制字符一律小写 `\u00xx`，不使用 `\n` 等短转义；slash、U+2028、U+2029 和其他非 ASCII scalar 不转义。整数用最短十进制。禁止浮点、NaN 和 Infinity。

CSV parser 按 RFC 4180 的 quote/double-quote 规则解析，但本合同禁止 cell 内 CR/LF。legacy reader 可识别 CRLF/LF；controlled writer 只输出 UTF-8 无 BOM、逗号 delimiter 和 LF。header 按本文件 schema 顺序，header 与每个 data cell 一律用双引号包围，内部双引号写成 `""`，空 cell 写 `""`，不得输出 delimiter 外空白；最后一条 record 后恰一个 LF。受控 raw CSV 与这些 bytes 不同即失败，不先宽容改写。

controlled CSV 的 data row 顺序固定。operations 与 journal 分别按 sequence 数值升序；mapping 按 scope_id canonical bytes 后接 event seq；runtime results 按 fixture_id 后接固定 runtime order `powershell_5_1,powershell_7,python_3`；其余文件按该 schema 的 logical primary key canonical bytes 升序。每份 schema 必须在下文声明 logical PK；未声明、重复或排序相同但 full row 不同均失败。

### canonical row envelope

CSV row envelope 的 JSON key 顺序固定为：

```text
domain(string),table_path(string),primary_key(array[object]),columns(array[object])
```

primary_key item 的 key 为 `name(string),value(string)`；columns item 同样为 `name,value`，并按 schema ordinal 包含全部列。CSV 空 cell 在 envelope 中仍是 JSON 空 string，不变成 null。domain 固定 `research-csv-row-v1`。Markdown 活动名单 row 使用相同 envelope，domain 固定 `active-scope-markdown-row-v1`，table_path 固定其项目相对路径，PK 为 scope_id。

rowset 先按 `(table_path UTF-8 bytes, primary_key canonical bytes, full row canonical bytes)` 排序。相同 table+PK、完全重复 envelope 或 schema 外列均拒绝。空集 payload 唯一为 `[]`。

所有 canonical hash 使用：

```text
SHA256(UTF8(domain_tag) || 0x00 || UINT64_BE(payload_byte_length) || payload_bytes)
```

domain tag 固定区分 `row-v1,rowset-v1,closure-rowset-v1,json-manifest-v1,json-policy-v1,json-approval-v1,json-transaction-v1,json-rollback-v1,managed-state-rowset-v1,raw-set-v1`。RowHash 的 payload 是单个 envelope；rowset payload 是带 table domain 的无空白 JSON array。closure 混合多表时仍保留每行 table_path。重复行在 hash 前失败，不按 set 静默去重。

raw file hash 仅为对磁盘原字节直接 SHA-256，不加 framing。raw set 的 item exact key 顺序为 `relative_path(string),raw_sha256(sha256)`，按 relative_path bytes 排序，再用 raw-set domain 计算。manifest 中带 `_raw_file_sha256` 的 key 绑定原字节；`*_canonical_row_sha256` 绑定 row-v1，`*_canonical_set_sha256` 绑定 rowset/closure/managed-state 的相应 domain；policy、manifest、approval、transaction 和 rollback 的 `*_canonical_sha256` 分别绑定 exact-key canonical JSON 及各自 domain。不得只拼 row bytes 或把 raw hash 当 canonical hash。

## closure 与 cutoff

identity.data_cutoff_date、manifest.cutoff_date 和 selection-run.cutoff_date 必须相等。selection run 要求 scope_kind=object、scope_id=card object、algorithm version 相等、created_date 不早于 cutoff，且 run/status/review 达到 approved。prepared date 不早于 cutoff；review/approval date 可以更晚。

closure 从全部 include field requirement 和全部 factor requirement 出发，包含 field/factor requirement、factor binding、accepted fact 及其直接或派生证据链、search log/result 及实际 endpoint、requirement evidence 及实际 endpoint、selection run/member/selected role、source screening、source family/version、相关 scope/list/allocation/mapping row、relevant legacy disposition 与 reconciliation event、policy/date policy 及其 approval。它还必须包含 card object 的全部 13 条 card-completeness，domain 集逐字等于 `benchmark,compute,economics,evidence,identity,interconnect,memory,numerics,physical,reliability,scheduling,software,special_engines`；identity row 另受显式 row hash 约束。validator 从 field domain、coverage 和 factor closure 复算：全为 structural N/A 时是 not_applicable；只要有 not_found/not_public/inaccessible 且没有未闭合项就是 missing_public_data；其余全部闭合时是 complete。partial/needs_review 禁止 provisional/formal。`FIELD-ID-ARCH` 收入 approved projection relation，不要求 duplicate fact。

每条 assertion/result/evidence 的 endpoint access date、非空 snapshot date、source-date policy 裁决日期和每条 search.searched_date 均不晚于 cutoff。source-date rule 按 `(source_type,actual endpoint_type)` 唯一命中，并据 actual source version 的 publication date、actual endpoint 的 snapshot/access date 计算有效日期。每个非 lead-only selection member 必须至少被一条 assertion/result/evidence 的 actual endpoint 引用；preferred endpoint 不参与。

field `conflicting_unresolved` 必须命中同 target/field 的 reviewed conflict group、至少两个表达相反值或相反限定的 conflict member、各自 accepted fact/assertion 和实际 endpoint。conflict group、member 及整条来源链进入 closure。未实现此门时禁止发布 field conflict；factor conflict 第一版始终禁止。

accepted fact 若为 direct_statement/measured，至少有一条 accepted AFPV2 assertion，且 assertion、actual endpoint、source version 和 source family 全部进入 closure。若 `fact_kind=derived`，则必须恰有一条 reviewed/approved derived-metrics row，formula_id、formula_expression、output_unit 非空，output_unit 与 fact normalized_unit 相等，scope/precision/direction 三个 check status 全为 passed；其 derived-inputs 按 input_order 从 1 连续排列，每行 reviewed/approved，至少一行。validator 以 visited set 拒绝派生环，递归关闭全部 input fact 及其 direct assertion/actual endpoint；derived-metrics、derived-inputs 和所有递归 input row 都进入 closure。

`RecomputeDerivedV1(formula_id, ordered_input_normalized_values)` 是 validator 中对已登记 formula_id 的 total function；未知 ID、除零、单位不相容、隐式精度转换或输出无法与 derived fact 的 normalized text/number/unit exact-equal 均失败。formula evaluator 源文件作为 transaction-file-input 绑定 raw hash。这样 GA100 的 HBM 6144-bit、NVLink 聚合等显式派生可以发布，但不能把人写的 formula_expression 当作已验证计算。

reverse-removal 的覆盖宇宙包含 field closure、factor obligation、factor-specific search、actual endpoint、派生 fact 的递归 input assertion、最低 source type/authority 和 conflict closure。发布性 not_found/not_public/inaccessible 依赖的 source 必须是 run member；移除 source 后重算派生 DAG 与全部门，仍满足时才可不选。`coverage_obligation_evidence` 只标识承担 factor/缺失覆盖的必要 source。

## coverage manifest 与独立批准

### coverage-manifest.json

完整 key 顺序如下，共 58 个 key。除 notes 为 nullable、projection relation array 可空数组外，其余均非空。

```text
coverage_contract_version(string)
manifest_id(string)
work_package_id(string)
policy_id(string)
policy_canonical_sha256(sha256)
policy_approval_id(string)
policy_approval_canonical_sha256(sha256)
source_date_policy_id(string)
source_date_policy_raw_file_sha256(sha256)
source_date_policy_canonical_set_sha256(sha256)
source_date_policy_approval_id(string)
source_date_policy_approval_canonical_sha256(sha256)
legacy_registry_id(string)
legacy_registry_raw_file_sha256(sha256)
legacy_registry_canonical_set_sha256(sha256)
legacy_registry_approval_id(string)
legacy_registry_approval_canonical_sha256(sha256)
legacy_reconciliation_schema_canonical_sha256(sha256)
relevant_legacy_reconciliations_canonical_set_sha256(sha256)
card_object_id(string)
card_object_canonical_row_sha256(sha256)
card_identity_completeness_canonical_row_sha256(sha256)
card_completeness_canonical_set_sha256(sha256)
scope_id(string)
active_scope_list_schema_canonical_sha256(sha256)
active_scope_list_row_canonical_sha256(sha256)
scope_allocation_id(string)
scope_allocation_canonical_row_sha256(sha256)
mapping_event_id(string)
mapping_event_canonical_row_sha256(sha256)
expected_card_lifecycle(string)
cutoff_date(date)
selection_run_id(string)
selection_algorithm_version(string)
projection_relation_ids(array[string])
expected_projection_relations_canonical_set_sha256(sha256)
field_count(uint)
fields_contract_canonical_set_sha256(sha256)
coverage_schema_canonical_set_sha256(sha256)
coverage_enums_canonical_set_sha256(sha256)
reachable_inventory_canonical_set_sha256(sha256)
expected_field_target_pairs_canonical_set_sha256(sha256)
expected_factor_obligations_canonical_set_sha256(sha256)
expected_factor_target_pairs_canonical_set_sha256(sha256)
ga100_mandatory_keys_canonical_set_sha256(sha256)
relevant_legacy_dispositions_canonical_set_sha256(sha256)
closure_canonical_set_sha256(sha256)
coverage_targets_raw_file_sha256(sha256)
factor_target_candidates_raw_file_sha256(sha256)
reachable_target_bindings_raw_file_sha256(sha256)
coverage_fields_raw_file_sha256(sha256)
coverage_exclusion_reviews_raw_file_sha256(sha256)
prepared_by(string)
prepared_date(date)
reviewed_by(string)
reviewed_date(date)
review_status(string)
notes(string|null)
```

contract version 固定 `COVERAGE-CONTRACT-V3`；field_count 固定 141；expected lifecycle 仅 provisional/formal；review status 固定 reviewed；reviewed_by 与 prepared_by 不同。identity hash 必须等于 13-row completeness set 中 `domain=identity` 的唯一 row，且该 row lifecycle/cutoff/scope 与 manifest 相等。policy/date/legacy approval 都先于 manifest 存在。scope 只绑定当前活动名单 schema、当前 scope row、相关 allocation 和 latest approved mapping row，不绑定整份活动名单或完整 scope registry，避免新增无关 scope 使旧卡失效。全局 validator 仍单独执行活动名单与 active allocation set-equal。

coverage schema hash 固定绑定合同 postimage 的完整 376 条 schema-columns row；coverage enum hash 固定绑定完整 562 条 enums row，不能由手写 used-subset 缩小。fields contract hash 绑定全部 141 条 field row。任一旧列、旧枚举、field 或 review 语义漂移都会改变 manifest；跨 contract version 不能沿用旧 manifest。

五个 raw hash 绑定工作包 CSV 原字节。expected/inventory/closure/contract hash 绑定 canonical rowset。policy approval 和 coverage approval 只使用 canonical JSON hash。

### independent-approval.json

完整 key 顺序：

```text
approval_contract_version(string)
approval_id(string)
manifest_id(string)
manifest_canonical_sha256(sha256)
closure_canonical_set_sha256(sha256)
policy_id(string)
policy_approval_id(string)
policy_approval_canonical_sha256(sha256)
source_date_policy_id(string)
source_date_policy_approval_id(string)
source_date_policy_approval_canonical_sha256(sha256)
legacy_registry_id(string)
legacy_registry_approval_id(string)
legacy_registry_approval_canonical_sha256(sha256)
card_object_id(string)
scope_id(string)
scope_allocation_canonical_row_sha256(sha256)
mapping_event_canonical_row_sha256(sha256)
cutoff_date(date)
approved_by(string)
approved_date(date)
approval_status(string)
notes(string|null)
```

contract version 固定 `COVERAGE-APPROVAL-V3`，status 固定 approved。approved_by 与 prepared_by 不同，approved date 不早于 manifest.reviewed_date。approval 单向绑定完整 manifest canonical hash；manifest 不含本 approval hash。

## transaction 机器合同

合同迁移事务和 GA100 v3 芯片事务使用同一结构。下列辅助 CSV 都采用 strict controlled CSV。

### operations.csv

固定 13 列：

```text
operation_id,operation_seq,table_path,operation_kind,pk_canonical_json,input_payload_path,input_payload_raw_sha256,expected_preimage_state,expected_preimage_canonical_row_sha256,expected_postimage_state,expected_postimage_canonical_row_sha256,rollback_payload_path,rollback_payload_raw_sha256
```

逐列类型为 `operation_id:id!`、`operation_seq:uint!`、`table_path:text!`、`operation_kind:enum!`、`pk_canonical_json:text!`、`input_payload_path:text!`、`input_payload_raw_sha256:sha256!`、`expected_preimage_state:enum!`、`expected_preimage_canonical_row_sha256:sha256?`、`expected_postimage_state:enum!`、`expected_postimage_canonical_row_sha256:sha256?`、`rollback_payload_path:text?`、`rollback_payload_raw_sha256:sha256?`。logical PK 是 operation_id；operation seq 从 1 连续递增。kind 仅 insert/update/delete；state 仅 present/absent。同一 `(table_path,pk_canonical_json)` 只允许一项。insert 为 absent→present，update 为 present→present，delete 为 present→absent。state=present 对应 row hash 必填；absent 对应 row hash 为空。rollback payload 在 preimage present 时必填且是原 row envelope；preimage absent 时两列为空。

每项 input payload 都是受控 canonical JSON，exact key 顺序为 `operation_payload_contract_version,operation_id,table_path,operation_kind,primary_key,postimage_row`。version 固定 `OPERATION-PAYLOAD-V1`；primary_key 是与 row envelope 相同的 ordered `name,value` array；insert/update 的 postimage_row 为完整 row envelope，delete 为 JSON null。input raw hash绑定该 JSON 原字节。由此 update/delete 均有明确 preimage、input 和 postimage，不允许执行器从 staging 隐式取 row。

### transaction-table-images.csv

```text
table_image_id,transaction_id,table_path,primary_key_columns_canonical_json,preimage_raw_file_sha256,preimage_canonical_set_sha256,expected_postimage_raw_file_sha256,expected_postimage_canonical_set_sha256,row_count_before,row_count_after,rollback_preimage_path,rollback_preimage_raw_sha256
```

逐列类型为 `table_image_id:id!`、`transaction_id:id!`、`table_path:text!`、`primary_key_columns_canonical_json:text!`、`preimage_raw_file_sha256:sha256!`、`preimage_canonical_set_sha256:sha256!`、`expected_postimage_raw_file_sha256:sha256!`、`expected_postimage_canonical_set_sha256:sha256!`、`row_count_before:uint!`、`row_count_after:uint!`、`rollback_preimage_path:text!`、`rollback_preimage_raw_sha256:sha256!`；logical PK 是 table_image_id。每张受影响正式表或 registry 恰一行。raw hash 固定完整文件 bytes，canonical set hash 固定语义行集合。rollback preimage 保存原始 bytes。

### transaction-payload-inventory.csv

```text
payload_id,transaction_id,source_path,target_path,preimage_state,preimage_raw_sha256,input_raw_sha256,expected_postimage_state,expected_postimage_raw_sha256,rollback_action,rollback_payload_path,rollback_payload_raw_sha256
```

逐列类型为 `payload_id:id!`、`transaction_id:id!`、`source_path:text!`、`target_path:text!`、`preimage_state:enum!`、`preimage_raw_sha256:sha256?`、`input_raw_sha256:sha256!`、`expected_postimage_state:enum!`、`expected_postimage_raw_sha256:sha256?`、`rollback_action:enum!`、`rollback_payload_path:text?`、`rollback_payload_raw_sha256:sha256?`；logical PK 是 payload_id，target_path 在事务内唯一。state 仅 present/absent；对应 hash nullable 规则与 operations 相同。rollback_action 仅 restore/delete_created/noop。delete_created 时 rollback payload path/hash 为空；restore 时必填。path 必须为项目相对路径，禁止 absolute、空 segment、`.`、`..` 和反斜杠。

### transaction-file-inputs.csv

```text
file_input_id,transaction_id,input_role,relative_path,raw_file_sha256,canonical_domain_tag,canonical_sha256,is_required,notes
```

逐列类型为 `file_input_id:id!`、`transaction_id:id!`、`input_role:enum!`、`relative_path:text!`、`raw_file_sha256:sha256!`、`canonical_domain_tag:text?`、`canonical_sha256:sha256?`、`is_required:bool!`、`notes:text?`；logical PK 是 file_input_id，`(transaction_id,relative_path,input_role)` 唯一。canonical domain/hash 只能同时为空或同时非空。它登记 policy、approval、coverage files、活动 scope row source、legacy registry、formula evaluator、validator、template/docs patch 和其他非 operation 输入。

### rollback-file-inventory.csv

```text
rollback_file_id,transaction_id,target_path,preimage_state,preimage_raw_sha256,expected_transaction_postimage_state,expected_transaction_postimage_raw_sha256,rollback_action,rollback_payload_path,rollback_payload_raw_sha256
```

逐列类型为 `rollback_file_id:id!`、`transaction_id:id!`、`target_path:text!`、`preimage_state:enum!`、`preimage_raw_sha256:sha256?`、`expected_transaction_postimage_state:enum!`、`expected_transaction_postimage_raw_sha256:sha256?`、`rollback_action:enum!`、`rollback_payload_path:text?`、`rollback_payload_raw_sha256:sha256?`；logical PK 是 rollback_file_id，target_path 唯一。state/hash 与 payload inventory 同规则。rollback action 仅 restore/delete_created/noop。每个受影响正式表、registry、managed doc 和 payload target 恰一行。

### transaction-journal.csv

```text
journal_event_id,transaction_id,event_seq,manifest_canonical_sha256,previous_event_canonical_sha256,event_type,event_time_utc,executor,observed_state_canonical_set_sha256,event_canonical_sha256,status,notes
```

逐列类型为 `journal_event_id:id!`、`transaction_id:id!`、`event_seq:uint!`、`manifest_canonical_sha256:sha256!`、`previous_event_canonical_sha256:sha256?`、`event_type:enum!`、`event_time_utc:text!`、`executor:text!`、`observed_state_canonical_set_sha256:sha256!`、`event_canonical_sha256:sha256!`、`status:enum!`、`notes:text?`；logical PK 是 journal_event_id。event seq 连续递增。第一行 previous hash 为空，后续必等于上一 event hash。event type 仅 prepared,applying,applied,rollback_applying,rolled_back,failed；status 仅 started,succeeded,failed。允许 pair 仅 `prepared+succeeded,applying+started,applied+succeeded,rollback_applying+started,rolled_back+succeeded,failed+failed`。event time 固定 UTC RFC3339 秒精度 `YYYY-MM-DDTHH:MM:SSZ`。observed state 是按 target_path 排序的 exact-key object array `target_path,state,raw_sha256,canonical_sha256`，absent 的两个 hash 为 null，domain 固定 `managed-state-rowset-v1`。event hash 的 payload 是除 event_canonical_sha256 本身外的完整 row envelope，domain 为 `transaction-journal-event-v1`。

### rollback-manifest.json

key 顺序和类型：

```text
rollback_contract_version(string)
rollback_id(string)
transaction_id(string)
operations_raw_file_sha256(sha256)
table_images_raw_file_sha256(sha256)
payload_inventory_raw_file_sha256(sha256)
rollback_file_inventory_raw_file_sha256(sha256)
expected_transaction_postimage_canonical_set_sha256(sha256)
expected_base_preimage_canonical_set_sha256(sha256)
prepared_by(string)
prepared_date(date)
reviewed_by(string)
reviewed_date(date)
review_status(string)
notes(string|null)
```

contract version 固定 `ROLLBACK-CONTRACT-V1`，review_status 固定 reviewed。两个 expected state hash 都使用前述 managed-state rowset，目标集合与 table-images 加 payload inventory 完全相同且排除控制面。rollback manifest 不含 transaction manifest hash；transaction manifest 随后绑定 rollback canonical hash，避免互相引用。

### transaction-manifest.json

完整 key 顺序：

```text
transaction_contract_version(string)
transaction_id(string)
transaction_kind(string)
base_contract_version(string)
target_contract_version(string)
operation_count(uint)
table_image_count(uint)
payload_count(uint)
file_input_count(uint)
base_formal_tables_canonical_set_sha256(sha256)
operations_raw_file_sha256(sha256)
operations_canonical_set_sha256(sha256)
table_images_raw_file_sha256(sha256)
table_images_canonical_set_sha256(sha256)
payload_inventory_raw_file_sha256(sha256)
payload_inventory_canonical_set_sha256(sha256)
file_inputs_raw_file_sha256(sha256)
file_inputs_canonical_set_sha256(sha256)
rollback_file_inventory_raw_file_sha256(sha256)
rollback_file_inventory_canonical_set_sha256(sha256)
rollback_manifest_canonical_sha256(sha256)
journal_schema_canonical_sha256(sha256)
registries_expected_postimage_canonical_set_sha256(sha256)
policy_bundle_canonical_set_sha256(sha256)
coverage_manifest_canonical_sha256(sha256|null)
coverage_approval_canonical_sha256(sha256|null)
expected_all_formal_tables_postimage_canonical_set_sha256(sha256)
expected_all_managed_files_postimage_raw_set_sha256(sha256)
prepared_by(string)
prepared_date(date)
reviewed_by(string)
reviewed_date(date)
review_status(string)
notes(string|null)
```

contract version 固定 `TRANSACTION-CONTRACT-V1`；kind 仅 contract_migration/chip_work_package。contract_migration 的 coverage manifest/approval 两键必须 null；chip_work_package 必须非空。reviewed_by 与 prepared_by 不同，status 固定 reviewed。所有 count 与对应 CSV 行数相等。

事务控制面固定放在 `审计/事务/<transaction_id>/control/`，包括 transaction-manifest、transaction-approval、rollback-manifest 和 transaction-journal。前三者按各自规则 immutable，journal append-only。四者以及 operations、table-images、payload/file-input/rollback inventories 都不进入本事务自己的 payload target、rollback inventory、`expected_all_managed_files_postimage_raw_set` 或 apply 前 postimage 比较；它们只作为被 manifest raw/canonical hash 绑定的控制输入。coverage manifest/approval 已在 transaction manifest 生成之前完成，可作为 chip transaction 的已知 file input，并在需要归档时作为 managed audit payload。这样 transaction manifest、approval、rollback manifest 与 journal 都不会自哈希。

`expected_all_managed_files_postimage_raw_set_sha256` 只覆盖 payload inventory 中的受管目标和 table-images 中的表/registry target。`expected_all_formal_tables_postimage_canonical_set_sha256` 固定覆盖 34 张正式表的完整 postimage rowset；`registries_expected_postimage_canonical_set_sha256` 覆盖 scope allocation/mapping、legacy disposition、legacy reconciliation 等 registry postimage。journal 最终 bytes 直到执行时才产生，manifest 只绑定其 12-column schema canonical hash 和 hash-chain 规则。

`policy_bundle_canonical_set_sha256` 的 item exact key 顺序为 `artifact_role,artifact_id,canonical_domain_tag,canonical_sha256`，role 集固定为 coverage_policy、coverage_policy_approval、source_date_policy、source_date_policy_approval、legacy_requirement_registry、legacy_requirement_registry_approval、legacy_reconciliation_schema；按 role bytes 排序。contract migration 和 chip transaction 都必须绑定这七项，任何缺项或额外项失败。journal schema hash 则对本文件给出的 12 个 column definition envelope 取 rowset hash，不绑定空 journal file bytes。

### transaction-approval.json

```text
approval_contract_version(string)
approval_id(string)
transaction_id(string)
transaction_manifest_canonical_sha256(sha256)
expected_all_formal_tables_postimage_canonical_set_sha256(sha256)
expected_all_managed_files_postimage_raw_set_sha256(sha256)
approved_by(string)
approved_date(date)
approval_status(string)
notes(string|null)
```

contract version 固定 `TRANSACTION-APPROVAL-V1`，status 固定 approved，approver 与 preparer 不同。transaction manifest 不含 approval hash。

### 幂等执行和回滚

执行器先解析并验证全部 strict artifact，再计算每个 managed target 的 state row。全部等于 derived preimage 时允许 apply；全部等于 expected postimage 且 journal 有同 manifest hash 的 applied+succeeded event 时返回成功 no-op。正常 apply 先在隔离镜像生成并验证所有表和 managed file，跑 schema、coverage、scope、recovery 和 hash gate；随后以同文件系统 temp+fsync+rename 原子写入 applying+started journal event，再逐 target 用已验证 postimage 的 temp+fsync+rename 替换。全部复核为 postimage 后，原子追加 applied+succeeded event。

多文件替换中断允许确定性 roll-forward，但只在 journal 最新 event 是同 manifest hash 的 applying+started，且每个 managed target 恰好等于该 target 的 expected preimage 或 expected postimage 时成立。执行器重新验证尚未替换的 postimage payload，替换所有仍为 preimage 的 target；已经是 postimage 的 target 不重复写。随后跑完整 postimage gate 并追加 applied+succeeded。出现未知 hash、target 缺失与 state 声明不符、manifest hash 不同，或没有 applying event 的 pre/post 混合状态，均失败并保留现场。

rollback 只从完整 applied postimage 开始。它先写 rollback_applying+started，再逐 target 恢复原始 bytes；只删除本事务创建且当前 hash 仍等于 expected postimage hash 的 payload。rollback 中断时，只有 journal 最新为同 manifest 的 rollback_applying+started，且每个 target 恰为 transaction postimage 或 base preimage，才继续恢复剩余 target；未知状态失败。恢复后复核完整 base preimage并写 rolled_back+succeeded。全部已处于 base preimage且 journal有 rolled_back+succeeded 时返回成功 no-op。若 apply 中断，必须先按上段完成 roll-forward，再开始 rollback，不能在 applying mixed state 直接反向覆盖。任何后来修改导致 hash 不同都拒绝回滚。

## fixture 合同与三运行时交付

### canonical-fixtures.csv

```text
fixture_id,input_kind,input_file,expected_valid,expected_canonical_hex,expected_sha256,expected_error_code,notes
```

逐列类型为 `fixture_id:id!`、`input_kind:enum!`、`input_file:text!`、`expected_valid:bool!`、`expected_canonical_hex:text?`、`expected_sha256:sha256?`、`expected_error_code:enum?`、`notes:text?`；logical PK 是 fixture_id。hex 只能是偶数长度小写十六进制。positive fixture 的 hex/hash 必填、error code 为空；negative fixture 反之。error code 只允许 `E_UTF8,E_BOM,E_SURROGATE,E_JSON_KEY,E_JSON_TYPE,E_JSON_NUMBER,E_JSON_ORDER,E_CSV_HEADER,E_CSV_NEWLINE,E_CSV_QUOTE,E_MARKDOWN_PIPE,E_DATE,E_ENDPOINT_SOURCE,E_DUPLICATE,E_HASH_FRAME`。

### canonical-runtime-results.csv

```text
runtime_result_id,fixture_id,runtime_id,implementation_version,observed_valid,observed_canonical_hex,observed_sha256,observed_error_code,executed_by,executed_date,review_status,notes
```

逐列类型为 `runtime_result_id:id!`、`fixture_id:id!`、`runtime_id:enum!`、`implementation_version:text!`、`observed_valid:bool!`、`observed_canonical_hex:text?`、`observed_sha256:sha256?`、`observed_error_code:enum?`、`executed_by:text!`、`executed_date:date!`、`review_status:enum!`、`notes:text?`；logical PK 是 runtime_result_id，`(fixture_id,runtime_id)` 唯一。runtime ID 仅 `powershell_5_1,powershell_7,python_3`。每个 fixture 恰有三行。三端 positive canonical hex/hash 必须与 expected 逐字相等；negative error code 必须相等。

### fixture-manifest.json

```text
fixture_contract_version(string)
fixture_set_id(string)
canonical_contract_version(string)
fixtures_raw_file_sha256(sha256)
fixtures_canonical_set_sha256(sha256)
runtime_results_raw_file_sha256(sha256)
runtime_results_canonical_set_sha256(sha256)
fixture_count(uint)
runtime_result_count(uint)
prepared_by(string)
prepared_date(date)
reviewed_by(string)
reviewed_date(date)
review_status(string)
notes(string|null)
```

fixtures 至少覆盖中文、前后空格、空字符串与 null、引号、反斜杠、slash、U+0000/U+000A、U+2028/U+2029、supplementary-plane、escaped pipe、UTF-8 BOM、LF/CRLF/CR、重复/未知/乱序 JSON key、浮点、非法 UTF-8、未配对 surrogate、CSV cell 内换行、真实与伪日期、错误 endpoint/source、空 rowset、重复 row、跨表同内容 row 和不同 domain tag。合同语义 fixture 还要覆盖 AFPV2 null/string endpoint、reconciliation approved→withdrawn→replacement、higher needs_resolution 阻断、rejected proposal 忽略、inactive successor 不可选、memory `cycle/s`、禁止隐式换算、instruction condition 缺 key 和 clock known/unknown 一致性。三运行时结果未全部产生前，fixture manifest review_status 不能 approved，合同不能上线。

## 严格发布伪代码

```text
ValidateCoveragePackage(base, staging, registries, active_list, policy, date_policy,
                        legacy_registry, package_dir):
    data = StrictMerge(base, staging)
    manifest = LoadExactCanonicalJson(package_dir/coverage-manifest.json, CoverageManifestSchema)
    approval = LoadExactCanonicalJson(package_dir/independent-approval.json, CoverageApprovalSchema)

    ValidateArtifactApproval(policy, policy_approval, manifest.policy_approval_canonical_sha256)
    ValidateArtifactApproval(date_policy, date_policy_approval,
                             manifest.source_date_policy_approval_canonical_sha256)
    ValidateArtifactApproval(legacy_registry, legacy_approval,
                             manifest.legacy_registry_approval_canonical_sha256)
    ValidatePolicyUniversePredicatesAndUnitContracts(policy, data.fields,
                                                       expected_field_count=141)
    Require(HashRowSet(data.schema_columns) ==
            manifest.coverage_schema_canonical_set_sha256)
    Require(HashRowSet(data.enums) == manifest.coverage_enums_canonical_set_sha256)
    Require(Count(legacy_registry) == 1059)
    Require(ForEachLegacyRowExactBaselineMatch(legacy_registry,
                                               data.field_requirements))
    ValidateAppendOnlyReconciliationRegistry(reconciliation_events,
                                               legacy_registry, data)

    list_row = ExactlyOne(ParseActiveScopeRows(active_list), scope_id == manifest.scope_id)
    allocation = ExactlyOne(registries.allocations,
                            scope_allocation_id == manifest.scope_allocation_id)
    mapping = LatestApprovedUnblockedMapping(registries.mappings, manifest.scope_id)
    Require(HashRow(list_row) == manifest.active_scope_list_row_canonical_sha256)
    Require(HashRow(allocation) == manifest.scope_allocation_canonical_row_sha256)
    Require(HashRow(mapping) == manifest.mapping_event_canonical_row_sha256)
    Require(allocation.active && mapping.formal_object_id == manifest.card_object_id)
    Require(ObjectIdentityScopeEqual(data, manifest.card_object_id, manifest.scope_id))
    ValidateObjectScopedSelectionRun(data, manifest)

    expected_projections = BuildExpectedProjectionRelations(manifest.card_object_id,
                                                              policy, data)
    Require(Set(manifest.projection_relation_ids) == KeySet(expected_projections))
    Require(HashRowSet(expected_projections) ==
            manifest.expected_projection_relations_canonical_set_sha256)
    projections = ResolveExplicitForwardProjections(data, expected_projections)
    inventory = BuildReachableInventoryStrict(data, manifest.card_object_id, projections)
    Require(HashRowSet(inventory) == manifest.reachable_inventory_canonical_set_sha256)

    expected_pairs = BuildExpectedFieldTargetPairs(data.fields, inventory.real_targets)
    field_candidates = LoadStrictCsv(package_dir/coverage-targets.csv)
    field_bindings = LoadStrictCsv(package_dir/reachable-target-bindings.csv)
    Require(KeySet(field_candidates) == expected_pairs)
    Require(KeySet(field_bindings) == expected_pairs)
    Require(EachKeyExactlyOnce(field_candidates, field_bindings))
    relevant_reconciliation = RelevantReconciliationChainsForPackage(
                                  field_candidates, reconciliation_events)
    Require(HashRowSet(relevant_reconciliation) ==
            manifest.relevant_legacy_reconciliations_canonical_set_sha256)
    ValidateMandatory108(field_candidates, policy.ga100_mandatory_policy)
    ValidateFieldDecisionsRequirementsStructuralNAExclusionsAndSuccession(
        field_candidates, data, policy, legacy_registry, reconciliation_events)

    expected_factors = BuildExpectedFactorObligations(manifest.card_object_id, policy)
    factors = CardFactors(data.factor_requirements, manifest.card_object_id)
    Require(KeySet(factors) == expected_factors)
    expected_factor_pairs = BuildExpectedFactorTargetPairs(factors, inventory, policy)
    factor_candidates = LoadStrictCsv(package_dir/factor-target-candidates.csv)
    Require(KeySet(factor_candidates) == expected_factor_pairs)
    ValidateFactorCandidateDecisionsAndExclusions(factor_candidates, policy)
    factor_bindings = BindingsFor(factors, data.factor_target_bindings)
    Require(KeySet(factor_bindings) == IncludeKeySet(factor_candidates))
    ValidateFactorStatusIdentityAndFactorSpecificSearch(
        factors, factor_candidates, factor_bindings, data, policy, manifest.cutoff_date)

    derived_fields = DeriveCoverageFields(field_candidates, factors, policy)
    Require(LoadStrictCsv(package_dir/coverage-fields.csv) == derived_fields)
    for field in derived_fields:
        if field.included_target_count > 0:
            Require(field.closed_requirement_count == field.included_target_count)
        else:
            Require(field.mapped_factor_count > 0)
            Require(field.closed_factor_count == field.mapped_factor_count)

    completeness = ExactCardCompletenessSet(data, manifest.card_object_id, expected_count=13)
    identity = ExactlyOne(completeness, domain == "identity")
    Require(HashRow(identity) == manifest.card_identity_completeness_canonical_row_sha256)
    Require(HashRowSet(completeness) == manifest.card_completeness_canonical_set_sha256)
    closure = BuildClosureWithActualEndpointsDerivedFactsConflictsSelectionAndRegistries(
                  data, field_candidates, factors, factor_bindings, manifest, policy,
                  date_policy, legacy_registry, reconciliation_events, completeness)
    ValidateAllClosureDates(closure, manifest.cutoff_date,
                            key=(source_type, actual_endpoint_type))
    ValidateReverseRemoval(closure, manifest.selection_run_id, policy)
    Require(HashRowSet(closure) == manifest.closure_canonical_set_sha256)
    ValidateAllRawAndCanonicalManifestHashes(manifest, package_dir, data)
    ValidateCoverageApprovalOneWay(approval, manifest)
```

```text
ApplyTransaction(root, transaction_dir):
    tx = LoadExactCanonicalJson(transaction-manifest.json, TransactionManifestSchema)
    tx_approval = LoadExactCanonicalJson(transaction-approval.json, TransactionApprovalSchema)
    rollback = LoadExactCanonicalJson(rollback-manifest.json, RollbackManifestSchema)
    ValidateNoHashCycleAndAllBindings(tx, tx_approval, rollback)
    preimage = DeriveExpectedPreimageStateSet(tx)
    postimage = DeriveExpectedPostimageStateSet(tx)
    observed = HashAllManagedTargetsExcludingControlPlane(root, tx)
    if observed == postimage and JournalHasApplied(tx): return SUCCESS_NOOP
    if JournalLatestIsApplyingForSameManifest(tx):
        Require(EachTargetEqualsItsPreimageOrPostimage(observed, preimage, postimage))
        return ResumeApplyByRollForward(root, tx, observed, postimage)
    Require(observed == preimage and JournalAllowsFreshApply(tx))
    mirror = BuildIsolatedPostimage(root, tx.operations, tx.payloads, tx.file_inputs)
    RunAllGates(mirror)
    Require(HashAllManagedTargetsExcludingControlPlane(mirror, tx) == postimage)
    AppendJournalAtomically(applying, started)
    ReplaceManagedTargetsWithVerifiedPostimage(mirror)
    Require(HashAllManagedTargetsExcludingControlPlane(root, tx) == postimage)
    AppendJournalAtomically(applied, succeeded)
    return SUCCESS_APPLIED
```

## 无循环的批准顺序

批准和 hash 按以下单向顺序产生：

```text
coverage policy → policy approval
source-date policy → source-date approval
immutable legacy registry → legacy registry approval
scope/list/allocation/mapping expected rows + formal expected rows + 工作包 CSV
    → coverage manifest → coverage approval
operations/table-images/payload/file-input/rollback inventories
    → rollback manifest
coverage manifest/approval + rollback manifest + 全部 transaction inputs/postimages
    → transaction manifest → transaction approval
apply/rollback execution → append-only journal events
```

policy、date policy 和 legacy registry 不含各自 approval hash；coverage manifest 不含 coverage approval hash；rollback manifest 不含 transaction manifest hash；transaction manifest 不含 transaction approval hash；journal 是最后生成的执行输出。任何箭头反向引用都作为 hash cycle 拒绝。

## 迁移和实现顺序

1. 冻结当前 32 表、活动名单、scope registry、validator、模板和文档 raw/canonical 基线。生成全部 1,059 行 legacy disposition，独立复核 29 个重复键和 26 条 pending，再批准 immutable registry；同时创建只有 header 的空 reconciliation event registry。
2. 给唯一活动名单 49 行分配 scope_id，生成 allocation 与 mapping event。初始只批准 9 个已有 completeness 的 mapped event；GH100 保持 pending identity review；GA100 为 pending formal object create；其余未通过身份门的 scope 保持 unmapped/pending。
3. 生成并独立批准 coverage policy、source-date policy 和 golden fixture expected。先在 Python 实现 strict canonical reference，再由 PS5.1 与 PS7 独立实现；三端 fixture 全等后才允许合同事务。
4. 构造独立 contract_migration transaction：删除 DATA-CUTOFF/historical_anchor，插入 `FIELD-COMP-INSTRUCTION-LATENCY`，修改 `FIELD-MEM-LATENCY` 单位合同，扩列六张既有表，增加两张 factor 表和全部 schema/enum row，迁移 45 个 identity lifecycle 与 9 个已批准 scope；对 832 条 fact assertion 逐行执行 V1→AFPV2 update，endpoint 先置空；创建 reconciliation registry，并更新 validator、formula evaluator、模板、字段字典、README、AGENTS、研究计划和状态计数。field delete/insert/update 和每条 assertion update 都有 preimage/input/postimage。它不写 GA100 facts。
5. 在隔离根执行 transaction preflight，验证精确 34/376/141/77/562、78 objects、585 completeness、832 条 AFPV2 assertion、49 active allocations、mapping 状态矩阵、1,059-row legacy baseline 与空 reconciliation registry、strict fixtures、恢复链和 Windows 三道 gate。通过独立 transaction approval 后才能正式应用。
6. 从合同 postimage 重新生成 GA100 v3。删除 12 个 GAP entity 及其 20 条 requirement/search/result；完成 49 条 staging pending 和全部 not_found 的真实逐来源检索；每条 assertion/result/evidence 绑定实际 endpoint；108 mandatory cell 全闭合；factor target 全集与 binding set-equal；zero-included field 走 factor；派生 facts 递归关闭 input/source；13 条 completeness 从 coverage 复算。先移除 MIG 610 的冗余 identity 职责，再按最终 fact/factor closure 对全部候选来源做反向移除；MIG 文档、HPEC microbenchmark 和 random-access 来源是否 selected 只由 architecture mechanism、status/version evidence、independent validation 或 coverage obligation 的不可替代职责决定，不预设来源数量或 lead/selected 结论。
7. GA100 package 先生成 coverage manifest/approval，再生成 rollback manifest、transaction manifest/approval。完整临时根通过 fixtures、coverage、scope、recovery、source pool 和 Windows 数据门后才可应用。应用成功后生成资料卡并反向核对每个显示单元的 fact/field requirement/factor requirement ID。

## 模板、字段字典和文档迁移

合同事务必须把这些非正式表文件纳入 transaction-file-inputs 和 managed postimage：

1. `资料卡/模板.md` 第 2 节把 HBM stacks 与 HBM total interface width 拆成两行，各自使用事实或 requirement 标识；所有允许显示缺失的标识列统一为 `<fact_id / requirement_id / factor_requirement_id>`。
2. 卡头 cutoff 连接 identity metadata；`silicon_package` 继续对应正式 object_type=die，不新增阅读层 die。
3. 数据链说明加入 field/factor requirement、search result、requirement evidence 和实际 endpoint；最小来源角色加入 `coverage_obligation_evidence`。
4. `资料卡/字段字典.md` 删除 DATA-CUTOFF 事实口径，写明 card metadata、factor obligation、zero-included field、HBM 两字段和 endpoint-aware source chain。
5. 模板与字段字典增加 instruction latency 行及其 condition contract；memory latency 显示单位必须沿用 fact 的 `s` 或 `cycle`，不得把无频率 cycle 自动换算。canonical fixtures 增加两种单位、缺失 instruction condition key、clock known/unknown 一致性和非法隐式换算正负例。
6. README、AGENTS、研究计划、当前状态和 validator 输出更新为 34/376/141/77/562。旧审计快照、归档冻结 CSV 和前序 reject 报告保持原字节。

## 设计交付检查

本设计已经把 R07 的八项 blocker 转成精确 schema、字节规则、集合门、审批链、事务状态和迁移顺序。当前仍未执行正式迁移、PS5.1/PS7/Python 三运行时 fixture 或 Windows gate，也没有授权修改正式数据；这些属于下一阶段实现和独立验收，不能在本设计稿中写成 PASS。

本文件已按 `report-humanizer` 完成单文件机器扫描，未检出 hard tell。人工从最后边界逆向复读迁移顺序、transaction 状态、manifest 58-key 顺序、schema 表、首段和标题，修正了 completeness 列名、reconciliation 状态机、crash recovery、field count 和时延单位合同；未发现剩余的模板化收束或前后计数冲突。
