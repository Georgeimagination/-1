# GA100 atomic v3 实施蓝图 v3：formal key、reserved projection 与 factor universe

状态：`blocked_preimplementation`。本文只针对 r43 的 R43-B01 至 R43-B03 和 release r03 状态作可执行修订；r42 已通过的 9×12、ExpectedPairBuilder、三组 forced pair、对象与来源边界、H0 至 H24、card 时序及 H13 的 58-key schema均原样继承，不在这里重新展开。本轮只新增本文件，不创建 staging，也不修改 r42/r43、正式表、合同、来源快照、资料卡或进度。

## 当前实施门

r43 的 `reject` 仍有效，解除条件是本版的 formal-key 规则、reserved-key projection 和 factor universe全部经过机器复算。release-date 的状态也应同步更新：`r1_release_date_03_semantic_migration_design_v2.md` 已存在，属于接收 r02 问题后的设计稿；它尚未独立验收、尚未实施、尚未取得 postimage accept，也尚未成为 active contract binding。因此 r02 对 r01 的 `reject` 仍是历史裁决，r03 只是 `pending_independent_review` 的后续设计，H0 继续返回 `E_RELEASE_AMENDMENT_NOT_ACTIVE`。

H0 唯一可消费的 release 输入仍是未来同时满足以下条件的 immutable post：r03 或其后继设计获得独立 accept，migration transaction 实施成功，独立 postimage review接受，且最终 `ActiveContractV7_1` 只绑定这一份 amendment/approval/policy closure。r03 中的 operation、payload、policy v5.1 或 amendment manifest均不能在此之前进入 GA100 的 H0、H11、H15 或 H17。

## R43-B01：formal key 与 legacy provenance 分层

### 正式 key 的唯一模型

所有正式 row 的身份固定为：

~~~text
FormalKey = (logical_table_path, pk_canonical_json)
~~~

`logical_table_path` 必须是 active contract注册的 root-relative table path，采用 UTF-8、`/` 分隔、无 `.`/`..` segment 的规范形式。`pk_canonical_json` 是该表 primary-key value 的 strict canonical JSON：对象 key顺序、字符串 Unicode、数字类型和空值均按 v7 canonical writer处理；同一显示字符串在不同表中是两个不同的 FormalKey。禁止以裸 PK 字符串、CSV 行号、label 或 v2 operation ID做 key 比较。

H0 从最终 formal preimage先构造 `H0FormalRowIndex`。每条记录至少含 `FormalKey`、`semantic_identity_sha256`、exact `h0_row_hash` 与 row canonical bytes hash。由它得到：

~~~text
ExistingFormalKeys = {FormalKey | FormalKey in H0FormalRowIndex}
~~~

`ExistingFormalKeys` 只由 H0 exact preimage决定，不从 r14 的 row、operation type或同名字符串推断。已存在 row 的正常动作是 no-write；需要 update 时，H11 必须同时携带同一 FormalKey、H0 row hash和 complete delta reason。

legacy locator是审计 provenance，不是 FormalKey。其记录单独保存为：

~~~text
LegacyProvenanceRecord =
  legacy_artifact_path
  legacy_row_locator
  legacy_row_hash
  legacy_operation_id
  legacy_operation_kind
  observed_legacy_pk_canonical_json
  candidate_semantic_key
~~~

它只能帮助定位可重读内容和构造拒绝 fixture。legacy row hash、review status、operation、authorization、payload hash和 coverage status均不参与 H0 guard、H11 delta、H15 authorization或 H17 inventory。

### 四类 key 集合与 candidate disposition

`ContractReservedNewKeys` 来自下一节的 active-contract projection；`FreshAllocatedKeys` 只来自 allocator。二者均是 FormalKey 集合，create 时必须在 H0 absent。`ForbiddenLegacyDraftOnly` 是负面集合，计算式固定为：

~~~text
LegacyInsertOrDraftOnlyKeys =
  {FormalKey(op.logical_table_path, op.pk_canonical_json)
   | r14 operation_kind == insert}
  union
  {FormalKey(locator.logical_table_path, locator.observed_legacy_pk_canonical_json)
   | locator has independently classified draft_only provenance}

ForbiddenLegacyDraftOnly =
  LegacyInsertOrDraftOnlyKeys
  minus ExistingFormalKeys
  minus ContractReservedNewKeys
~~~

r14 的 76 个 update 和 3 个 delete target不因旧 operation type自动进入 `LegacyInsertOrDraftOnlyKeys`。它们的正式 preimage归属必须由 H0逐 key判断：命中 H0 exact row时属于 `ExistingFormalKeys`；不命中时旧 update/delete没有复用授权，只能作为 provenance，或由独立 draft-only 分类进入拒绝链。这样不会把真实 formal preimage同时标成 forbidden。

三个可分配集合必须满足：

~~~text
ExistingFormalKeys intersect ContractReservedNewKeys = empty
ExistingFormalKeys intersect FreshAllocatedKeys = empty
ContractReservedNewKeys intersect FreshAllocatedKeys = empty
ForbiddenLegacyDraftOnly intersect
  (ExistingFormalKeys union ContractReservedNewKeys union FreshAllocatedKeys) = empty
~~~

`CandidateDispositionRecord` 的 ordered schema 是：

~~~text
candidate_kind
logical_table_path
semantic_identity_sha256
disposition
resolved_pk_canonical_json
h0_row_hash
reservation_token
allocator_version
~~~

其 logical key为 `(candidate_kind, logical_table_path, semantic_identity_sha256)`，按该三元组的 UTF-8 tuple order排序，row/set hash domain分别为 `candidate-disposition-row-v3` 与 `candidate-disposition-set-v3`。`disposition` 仅允许 `existing_no_write`、`existing_update`、`reserved_create`、`fresh_create`、`rejected`。前四类必须填 `resolved_pk_canonical_json`；existing类必须填 exact H0 row hash；reserved类必须填 reservation token；fresh类必须填 allocator version；rejected类四个 guard字段必须为 canonical null。

设 `CandidateInputKeys` 为 CandidateContentManifest 中所有待判定内容身份的上述 logical key，`DispositionKeys` 为 CandidateDispositionRecord 的 logical key，则：

~~~text
CandidateInputKeys == DispositionKeys

CandidateInputKeys ==
  ExistingCandidateKeys union ReservedCandidateKeys union
  FreshCandidateKeys union RejectedCandidateKeys

the four candidate subsets are pairwise disjoint
~~~

其中前三个子集的 resolved FormalKey与各自 key class双向相等；H1 direct candidate key集合又必须与 `ExistingCandidateKeys` 中的 explicit update、`ReservedCandidateKeys` 和 `FreshCandidateKeys` 双向相等。no-write existing不产生 H1 row create，仍必须出现在 disposition manifest中。这些等式把候选内容、正式 key class和实际 delta分开验证。

### 同名 legacy locator 的可接受路径与拒绝路径

legacy locator可以解析到与其 observed PK字符串同名的 existing FormalKey，条件必须同时满足：

1. `logical_table_path` 完全相同；
2. candidate semantic identity与 H0 formal row的 `semantic_identity_sha256` 完全相同；
3. CandidateDispositionRecord 中的 H0 row hash与 H0FormalRowIndex 的 exact row hash相同。

例如 r14 的 `数据/precision-paths.csv / PPATH-M2NA-AMPERE-TENSOR-INT8` locator，若 H0 对相同 `(path, pk_canonical_json)` 给出同一 semantic identity和 exact preimage hash，可产生 `existing_no_write` 或带 explicit delta guard的 `existing_update`。它解析到同名正式 key，不复制 r14 row或其操作。

相反，任何把 legacy row hash、legacy review status、旧 operation ID、旧 authorization、旧 payload hash当作 H0 guard或 H15 authorization的 fixture都必须报 `E_LEGACY_PROVENANCE_AS_AUTHORIZATION`。同名但 table不同、semantic identity不同、H0 hash不同或 H0 缺行时，都报 `E_LEGACY_SAME_NAME_NOT_EXISTING`；不能退化成无 guard 的 reserved/fresh create。

## R43-B02：完整的 ContractReservedNewKeyProjection

### active contract 的过滤式与 canonical record

`ContractReservedNewKeyProjection` 只从唯一 `ActiveContractV7_1` 的已应用 post读取。最终合同内部可以使用不同的表名，但 H0 adapter必须无损归一出 `ActiveContractReservationClaim`，并以以下过滤式选取全部 claim：

~~~text
ActiveReservationClaims =
  {r in NormalizeReservationClaims(ActiveContractV7_1)
   | r.package_scope == "GA100 atomic v3"
     and r.contract_role == "formal_key_reservation"
     and r.active_contract_canonical_sha256
         == ActiveContractV7_1.canonical_sha256
     and r.review_status == "approved"}
~~~

一个 claim都不能由 r38、historical-v7 fixture、r03 design、r14 或 live directory补入。`NormalizeReservationClaims` 本身是 H0 adapter的一部分，其 source table path、source row hash、输入 schema和 canonical adapter version必须进入 H0 manifest；无法映射、未知状态或两个 active contract均失败。

projection 的每个 ordered record固定为：

~~~text
package_scope
logical_table_path
semantic_identity_sha256
reserved_pk_canonical_json
reservation_token
expected_h0_state
source_contract_row_hash
~~~

`expected_h0_state` 只允许 `absent_create` 与 `present_existing`。logical key是 `(package_scope, logical_table_path, semantic_identity_sha256)`，按该三元组的 UTF-8 tuple order排序。每行使用：

~~~text
Frame("contract-reserved-new-key-row-v3",
      strict_json_bytes(ContractReservedNewKeyRecord))
~~~

全体排序行使用：

~~~text
Frame("contract-reserved-new-key-set-v3",
      strict_json_bytes(rows_sorted_by_logical_key))
~~~

`reserved_pk_canonical_json` 必须可按该 table的 primary-key schema反序列化并重新 canonicalize，不能是显示字符串或含重复 key的 JSON。`reservation_token` 全局唯一且非空；`source_contract_row_hash` 必须精确指向 active contract中一条已过滤的 claim row。`ActiveReservationClaims` 与 projection在 logical key、normalized content和 source row hash上双向 set-equal；缺一条、额外一条、相同 logical key不同内容、相同 FormalKey对应两个 semantic identity、重复 token、未知 expected state或 canonical hash不符均失败。

### H0 分类与 collision gate

projection不直接把所有 claim写成 create。H0 以 `expected_h0_state` 进行下列转换：

| projection 状态 | H0 必须观察到的状态 | 归属与后续约束 |
|---|---|---|
| `absent_create` | 对应 FormalKey absent | 进入 `ContractReservedNewKeys`；H11 create、H15 authorization与 H17 inventory必须携带 reservation token。 |
| `present_existing` | 对应 FormalKey present，且 table、semantic identity、exact H0 row hash均匹配 | 转入 `ExistingFormalKeys`，带 exact preimage guard；不进入 `ContractReservedNewKeys`，也不作为 create。 |

`absent_create` 在 H0 发现同一 FormalKey已存在时，报 `E_RESERVED_EXPECTED_ABSENT`；`present_existing` 缺行、语义不匹配或 hash不同，报 `E_RESERVED_EXISTING_MISMATCH`。Fresh allocator只能在 `ExistingFormalKeys`、`ContractReservedNewKeys` 和 `ForbiddenLegacyDraftOnly` 均不含该 FormalKey时分配；reserved/fresh collision、reserved/existing collision与同一 semantic identity的两种 disposition均失败。

跨表出现同一 PK JSON字符串不构成 collision，因为 FormalKey还包含 logical table path；同表同一 PK JSON对应两个 identity才是 collision。验证器必须分别给出跨表同字符串正例和同表碰撞负例，不能采用裸字符串全局去重。

## R43-B03：先建 FactorTargetUniverse，再判定 target

### obligation 与 target 的完整全集

H0 先从 final active mapping post 与 `ActiveChipRequiredRoleSet` 共同投影 `ActiveCardObjectProjection`。每条 record为 `(card_object_id, card_object_semantic_identity_sha256, mapping_event_formal_key, mapping_h0_row_hash)`，按 `card_object_id` 的 UTF-8 order排序，row/set hash domain为 `active-card-object-projection-row-v3` 与 `active-card-object-projection-set-v3`；它必须与属于本 package、`mapped + approved` 的 mapping rows双向 set-equal。H5 只从这个投影和 active factor rule建立 `FactorObligationUniverse`。每个 triple都有一条 `FactorObligationRecord`；card selector为 true 写 `include`，为 false 写 `exclude`，不能只为 include case留记录：

~~~text
FactorObligationKey = (card_object_id, policy_id, factor_id)

FactorObligationUniverse =
  {FactorObligationKey
   | card object in ActiveCardObjectProjection,
     factor rule in active factor policy}
~~~

`FactorObligationRecord` 的 ordered schema为：

~~~text
card_object_id
policy_id
factor_id
decision
decision_reason_code
card_selector_predicate_id
card_selector_predicate_canonical_sha256
factor_policy_row_hash
~~~

logical key为 obligation triple，按 UTF-8 tuple order排序，row/set hash domain为 `expected-factor-obligation-row-v3` 与 `expected-factor-obligation-set-v3`。card selector和所有 target predicate都必须来自 active policy所引用的 canonical predicate registry；每个 predicate ID、输入字段清单和 canonical definition hash要与 policy row hash一起绑定。未知 ID、输入字段缺失或 hash不符都失败。

对 `decision=include` 的 obligation，先建立完整 target全集：

~~~text
FactorTargetUniverse =
  { (card_object_id, policy_id, factor_id, target_kind, target_id)
    | obligation is include,
      target in H4 ReachabilityInventory,
      target_kind in obligation.allowed_target_kinds }
~~~

这里不得先按 subtype筛掉 H4 target。`FactorTargetUniverse` 的每一个 logical key都必须有一条 `FactorTargetCandidateRecord`，没有 candidate的 kind-allowed target即为遗漏。

### 决策顺序、全 eligible include 与 minimum gate

FactorTargetCandidateRecord 的 ordered schema为：

~~~text
card_object_id
policy_id
factor_id
target_kind
target_id
target_semantic_identity_sha256
target_subtype_predicate_id
target_subtype_predicate_canonical_sha256
structural_na_predicate_id
structural_na_predicate_canonical_sha256
decision
decision_reason_code
factor_policy_row_hash
~~~

logical key是 universe五元组，按 UTF-8 tuple order排序，row/set hash domain为 `expected-factor-target-row-v3` 与 `expected-factor-target-set-v3`。本版删除 r42 中未定义的 `source-independent eligibility`。对 universe中每个 key，固定按下列顺序求值：

1. target subtype predicate为 false，写 `exclude / target_subtype_not_matched`；
2. subtype为 true且 structural-N/A predicate唯一命中时，policy允许 N/A则写 `structural_na`，不允许则报 `E_FACTOR_STRUCTURAL_NA_FORBIDDEN`；
3. 其余 subtype-eligible target全部写 `include`。

source minimum、endpoint qualification和 H8 selection不参与 H5 target decision。它们仍按已继承的 H7/H8证据与 reverse-removal规则闭合，不能回写 H5 universe或 candidate decision。

`min_targets_if_available` 是 include count的 fail gate，不是从多个 eligible target任挑一部分的许可。对每个 include obligation，令 `available_count = |FactorTargetUniverse|`、`include_count = |{target | decision=include}|`：当 `available_count > 0` 时，`include_count` 必须不少于 policy中的 minimum；否则 H5报 `E_FACTOR_MIN_TARGETS_NOT_MET`。本版采用“all eligible include”，禁止任意子集选择。日后若合同确实允许子集，必须另行引入一个唯一、可哈希的 target selector，并为每个未选 universe key写 exclusion reason；该能力不属于本版。

### H6/H7 的闭合等式和负例

H6/H7必须同时满足以下双向 set-equality：

~~~text
FactorRequirementTriples
  == {obligation key | obligation decision == include}

FactorObligationExclusionReviewTriples
  == {obligation key | obligation decision == exclude}

FactorTargetCandidateKeys
  == FactorTargetUniverse

FactorTargetBindingKeys
  == {target key | target decision == include}

FactorTargetExclusionReviewKeys
  == {target key | target decision in {exclude, structural_na}}

H7TerminalFactorTriples
  == {obligation key | obligation decision == include}
~~~

每个 actual `factor_requirement_id` 必须唯一映射 include obligation；每个 include target binding必须唯一映射该 requirement与 target key。H7 terminal factor record只在 include obligation上存在，且带其 endpoint-qualified evidence/selection closure；obligation exclude不产生 requirement或 H7 terminal。这样 card selector false、subtype false、structural N/A与 evidence terminal各自在正确层消费，不能静默漏掉。

## 重新送审的机器条件

重送审 fixture至少包含以下反例，并要求每一项在进入 H10 前拒绝：

| 编号 | fixture | 必须观察到的结果 |
|---|---|---|
| MK-01 | r14 update/delete target与 H0 existing同名 | 被分到 ExistingFormalKeys；不进入 ForbiddenLegacyDraftOnly。 |
| MK-02 | legacy precision-path locator与 H0 table、semantic identity、row hash全等 | 可解析为同名 existing FormalKey，但 legacy provenance不会成为 guard/authorization。 |
| MK-03 | legacy row hash或旧 operation伪装 H0/H15输入 | `E_LEGACY_PROVENANCE_AS_AUTHORIZATION`。 |
| MK-04 | reserved projection缺 active claim、重复 logical key、重复 token、同表同 PK不同 identity | projection set-equality或 collision gate失败。 |
| MK-05 | reserved create在 H0已存在，或 present-existing缺 exact row hash | 分别报 `E_RESERVED_EXPECTED_ABSENT` 或 `E_RESERVED_EXISTING_MISMATCH`。 |
| MK-06 | reserved/fresh collision、reserved/existing collision、跨表同 PK字符串 | 前两者拒绝；跨表同字符串按两个 FormalKey保留，不能误报 collision。 |
| MK-07 | kind-allowed但 subtype=false target被从 candidate rows删除 | `FactorTargetCandidateKeys != FactorTargetUniverse`。 |
| MK-08 | extra target、未知 predicate或任意少选 eligible target | 分别拒绝为 universe extra、predicate resolution failure、all-eligible rule违反。 |
| MK-09 | card selector=false却缺 obligation exclusion review | obligation-exclusion set-equality失败。 |
| MK-10 | include obligation缺 H7 terminal factor triple | H7 factor-terminal set-equality失败。 |
| MK-11 | r03 design被作为 H0 release input | `E_RELEASE_AMENDMENT_NOT_ACTIVE`。 |

验收还应复跑 r43 已通过项：108 exact numeric key、six structural N/A、six benchmark、Ampere三 pair、GA100 counterpart search pair、动态 ChipRequired projection、H13 58-key schema、card H9→H18 payload链和 Windows hard gate。它们在本版没有改变；source-pool、final contract、release migration、正式 source ingestion和 Windows runtime仍是实际 apply之前的独立阻断门。

## 交接边界

本版让 H0 的 formal key类、H1 candidate disposition、H5 factor candidate、H6 binding/review和 H7 terminal都有可复算的集合边界。它不宣称 active contract、release amendment、source chain或 Windows gate已经完成。实施只能在上述外部门全部满足后，从 H0重新冻结 immutable input；在此之前不得生成 staging或预先写入任何正式 row。
