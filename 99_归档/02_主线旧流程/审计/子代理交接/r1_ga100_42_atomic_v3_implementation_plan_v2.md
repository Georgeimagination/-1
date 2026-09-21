# GA100 atomic v3 实施蓝图 v2：可执行 builder 与前置合同门

状态：blocked_preimplementation。本文根据 r41 的 reject 重写 r40 的实施边界，只新增本报告。r40 保留为被拒历史设计；本报告不创建 staging，不修改正式表、v2 staging、合同、来源快照、资料卡或进度。

## 本版裁决

r41 接受了 r40 的对象边界、当时 v7 的 38-input scope 历史分支、来源主体裁决、H0 至 H24 的依赖方向和 card 受管 payload 时序，却拒绝了四处会让实现者自行猜测 planned post 的缺口。本版逐一关闭这些缺口：9×12 只冻结 expected key 与六格 structural N/A；ExpectedPairBuilder 和 ExpectedFactorBuilder 被定义为可执行、可哈希的 H5 构造器；v2 内容阅读与正式 PK 分配完全拆开；release-date 输入只接受未来已落地的 active amendment post。

这仍不是实施授权。source-pool-113、v7.1 active contract、release-date amendment、正式 source ingestion、coverage/transaction approval 和 Windows hard gate 仍须逐项满足。r41 重新验收本报告时，接受的含义也只限于蓝图可以进入实现，不能倒推这些外部状态已经成功。

## 当前前置门与 H0 的可用输入

| 门 | H0 所需的最终证据 | 当前状态 |
|---|---|---|
| source-pool-113 | 已推广的 postimage、独立 prerequisite approval 和三个 Windows PASS transcript | blocked。候选资料不能以文件存在为由当作正式 source pool 记录。 |
| contract v7.1 | 唯一 active contract amendment post、transaction/coverage authorization、独立 postimage 复核和 34-table contract base | not_created。R15 已接受 v7 设计；contract v7 implementation/transaction 的独立审查与实施尚未发生，r38/R15均不构成 v7.1 实施 post。 |
| release-date amendment v2 | 新 amendment 设计、独立 accept、原子实施 transaction、独立 postimage accept，并由 v7.1 active contract 引用 | rejected_design / hard blocker。r1_release_date_02_semantic_migration_independent_review.md 已拒绝 r01；所需 v2 amendment 的设计、独审和实施均尚未完成。 |
| GA100 source chain | family、version、actual endpoint、payload、screening、search/result、requirement evidence 和 selection 已正式注册 | not_ingested。r29 与 r37/r39 的固定载荷和裁决只能进入 H0 的候选原料集合。 |
| Windows publish gates | Test-SourcePool.ps1、Test-ChipScope.ps1、Validate-ResearchData.ps1 及规定 fixture 的三 runtime PASS | not_run。当前 macOS 没有 PowerShell runtime，这是 tool/runtime limitation。 |

r1_release_date_01_semantic_migration_design.md 与 r02 都只允许出现在 RejectedHistoricalReferences 中，用于拒绝错误的 H0 输入。它们不能作为 I-release、active policy、approval、payload、fact 或 requirement 的来源。H0 只能读取未来经正式切换的 ActiveContractV7_1，并由该 post 递归绑定唯一的 release-date amendment v2 implementation post、coverage/authorization approval 和独立 postimage accept；任何 reject、pending 或未应用的设计文件都必须返回 E_RELEASE_AMENDMENT_NOT_ACTIVE。

对 release-date amendment v2，重新开始的顺序固定为：先冻结完整 active-reference closure、Phase A 的唯一 post、new selection run/member 与 policy/approval 路径；再独立复核并取得 accept；随后执行可回滚的 implementation transaction；最后由独立 postimage review 接受，并以一个新版本化 contract amendment 切换 active binding。没有这条闭环，GA100 release-date requirement 不可被提前写入 H0，也不能由 Technical Blog 的 2020-05-14 强候选转成 accepted value。

## 保留的对象、scope 与 card 边界

`ga100_full_die` 内容身份始终表示 full 128-SM physical design；历史拟定标签 `OBJ-NVIDIA-GA100-DIE` 只用于 r40/r41/v2 对照，H0 必须从 final contract解析实际 formal key。它不等于 108-SM A100 enabled product、A100 PCIe/SXM module、DGX system-under-test，或 A100/H100 integrated circuit 的监管主体。`ga100_full_die implements ampere_architecture` 的 relation 内容身份（历史拟定标签 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE`）仍限于合同允许的 identity relation projection，不能把 Ampere architecture、A100 product 或 DGX measurement 的事实无条件复制给 GA100 die。

scope 的冻结 preimage仍是 SCOPE-0001 的 seq1 `pending_formal_object_create`。r41 接受的 v7 历史分支可记为：

~~~text
HistoricV7ChipRequired38 =
  CommonChipBase34
  union {mapping base snapshot, mapping post snapshot}
  union AuthorizationTwo
~~~

`HistoricV7ChipRequired38` 只保留为 r41 的审计事实，绝不作为 H0 输入、H15 授权依据或 operation inventory。release-date v2 仍在 rejected design 状态；其重做可能使最终 active amendment 的角色集合、mapping delta和文件数不同。于是既不把 38，也不把任何尚未独审接受的替代数字，提前冻结进本蓝图。

最终实施时，H0 从唯一的、已独审接受且已正式 apply 的 `ActiveContractV7_1` 机械投影：

~~~text
ActiveChipRequiredRoleSet =
  {active contract file-input row
   | package_scope == "GA100 atomic v3"
     and role == "ChipRequired"}

ActiveScopeMappingDelta =
  {active contract mapping-delta row
   | scope_id == SCOPE-0001}
~~~

H0 的 projection adapter必须产生下面两个 canonical record；最终 contract可有不同的内部表/PK，但必须无损映射到这两个 schema，否则不具备本蓝图的输入资格：

~~~text
ActiveChipRequiredRoleRecord =
  package_scope
  role
  logical_path
  raw_sha256
  canonical_domain_tag
  canonical_sha256
  source_contract_row_hash

ActiveScopeMappingDeltaRecord =
  scope_id
  mapping_event_semantic_identity_sha256
  mapping_event_id
  event_sequence
  card_object_semantic_identity_sha256
  mapping_status
  approval_status
  mapping_basis
  source_contract_row_hash
~~~

前者按 `(package_scope, role, logical_path)`、后者按 `(scope_id, event_sequence, mapping_event_semantic_identity_sha256)` 的 UTF-8 tuple order排序；row/set hash domain分别为 `active-chip-required-role-row-v2` / `active-chip-required-role-set-v2` 与 `active-scope-mapping-delta-row-v2` / `active-scope-mapping-delta-set-v2`。H0验证两个投影与 active contract相应过滤行双向相等、seq1 immutable base、由 `ActiveScopeMappingDelta` 从 base 得到的 post、`ActiveChipRequiredRoleSet` 与 contract file-input inventory 的双向相等，以及每个 mapped card object 的 approved identity basis。`ChipRequired` 的结果数只是重算输出，不能由本报告预设。H3、H10、H18 与 apply 后 live gate都验证这一最终 post 的 object、identity、scope allocation与 mapping delta同一性。历史上 49→50、`MAPEV-SCOPE-0001-0002` 和 37/38 分支只可作为 historical-v7 fixture；不得将它们误作 v7.1 授权输入，也不得在 live 已映射时重选更小分支。

card 也保留 r41 接受的时序。H9 的 coverage、selection 和 factor closure完成后，renderer 以 planned formal rows 为唯一输入生成 card candidate；该 payload 在 H10 进入 complete planned post，在 H11 进入 delta，在 H15/H17 进入 authorization/inventory，并在 H18 与 isolated mirror 一起复验。apply 后只做重渲染 byte-equality，不允许新增或补写 card。H13 继续使用冻结的 58-key coverage manifest schema，只绑定 H10 object/mapping 与 H12 closure；不新增 card payload hash key。

## 9×12：冻结 key，不冻结其余 102 格的答案

### 九个 path 的内容身份和十二个 field

9×12 的对象是九个 precision-path 内容身份乘十二个 field，不使用 r14 draft PK 的笛卡尔积。H1 的 allocator 将每个内容身份映射到唯一的正式 precision_path_id；H4 只接受该映射后的 reachable path。九个内容身份为：

~~~text
ampere_tensor_fp16_to_fp32
ampere_tensor_fp16_to_fp16
ampere_tensor_bf16_to_fp32
ampere_tensor_tf32_to_fp32
ampere_tensor_fp64_to_fp64
ampere_tensor_int8_to_int32
ampere_tensor_int4_to_int32
ampere_tensor_binary_to_int32
ga100_tensor_dense_fp16_to_fp32
~~~

十二个正式 field ID 固定为：

~~~text
FIELD-NUM-OPERAND-A
FIELD-NUM-OPERAND-B
FIELD-NUM-ACCUMULATION
FIELD-NUM-PRODUCT
FIELD-NUM-PHYSICAL-ACCUM
FIELD-NUM-OUTPUT
FIELD-NUM-ROUNDING
FIELD-NUM-SCALING-MODE
FIELD-NUM-SCALING-GRANULARITY
FIELD-NUM-SATURATION
FIELD-NUM-SUBNORMAL
FIELD-NUM-SPARSITY
~~~

Mandatory108 是上述九个经 H1 分配且经 H4 reachability 验证的 final path ID 与十二个 field ID 的集合。builder 必须证明它恰有 108 个唯一 key；重复、缺 path、缺 field、以 v2 draft path ID替代 final ID，或出现额外 mandatory key 均失败。

### 唯一预定的 six structural N/A

仅以下六个 mandatory key 预先确定为 structural N/A：

~~~text
{ampere_tensor_int8_to_int32,
 ampere_tensor_int4_to_int32,
 ampere_tensor_binary_to_int32}
  ×
{FIELD-NUM-ROUNDING, FIELD-NUM-SUBNORMAL}
~~~

在 H5 中，final-key 版本为 `StructuralNaFinalKeys = {(ResolvePath(semantic_path), field_id)}`。`ResolvePath` 必须来自同一份 H1 content-identity 到 formal-PK crosswalk，且九个 semantic path恰好各解析一次；因此机器门核对的是六个 final `(precision_path_id,field_id)` key，而不是 r14 的历史字符串。

H5 将它们写为 decision=structural_na，H7 只可在对应 integer/logical-path predicate、N/A policy 与 requirement evidence 全部存在时写 not_applicable。这六格不能被 exclude、不能被写成 not_found，也不能替代 normal FIELD-PHY-DIE-COUNT structural N/A。后者仍只在 target object type 为 die 且 active policy 的正常 predicate 命中时成立。

其余 102 个 mandatory key 在 H5 都是 decision=include。H7 必须逐 key 从 actual direct assertion、approved formula 或 endpoint-aware search 得到终态。可接受的终态是 evidence 支持的 value、受实际搜索范围约束的 not_found、明示官方不公开的 not_public，或合同允许的其他 terminal disposition；没有闭合时 transaction 停在 H7，不能把 pending 送进 H10。H7 之后可以导出 status histogram，但 histogram 只记录本次 source/evidence manifest 下的重算结果。验证器不得比较某个预定的 value/not_found 数量，也不得为了保持历史分布拒绝新证据。

### 六 benchmark 与三组 identity 的强制 pair

`MandatoryPairPolicy` 还必须以 semantic-root resolution形成下列 exact include key，不给它们预定 terminal status：

~~~text
GA100Object = ResolveObject(ga100_full_die)
AmpereObject = ResolveObject(ampere_architecture)

BenchmarkSix = {GA100Object} × {
  FIELD-BENCH-LATENCY,
  FIELD-BENCH-THROUGHPUT,
  FIELD-BENCH-POWER,
  FIELD-BENCH-ENERGY-PER-TOKEN,
  FIELD-BENCH-TOKENS-PER-JOULE,
  FIELD-BENCH-UTILIZATION}

AmpereIdentityThree = {AmpereObject} × {
  FIELD-ID-DESIGN-OBJECTIVE,
  FIELD-ID-TARGET-USE-POSITIONING,
  FIELD-ID-VENDOR-POSITIONING}

Ga100IdentitySearchThree = {GA100Object} × {
  FIELD-ID-DESIGN-OBJECTIVE,
  FIELD-ID-TARGET-USE-POSITIONING,
  FIELD-ID-VENDOR-POSITIONING}
~~~

`BenchmarkSix`、`AmpereIdentityThree` 和 `Ga100IdentitySearchThree` 都必须出现在 H5 expected pair、H6 requirement/binding和 H7 terminal key set中；缺项、extra duplicate、exclude或 structural N/A都失败。Ampere三 pair在正式 source链完成后可由 whitepaper direct assertion闭合为 value；GA100 counterparts必须单独 search，不能从 `implements` relation下放。该对比规定的是对象和证据边界，不预置 GA100三 pair在本次 future run中的 value/not_found结果。

## ExpectedPairBuilder v2

### 输入、canonicalization 与数据域

ExpectedPairBuilder 是 H5 的确定性函数，版本固定为 EXPECTED-PAIR-BUILDER-V2。它不读 live 目录、不读 r14 CSV、不从作者文字猜 selector；全部输入都经 H0/H4 的 immutable reference 绑定。输入 manifest 使用 v7 canonical JSON writer，key 顺序固定如下：

~~~text
builder_version
active_contract_ref
scope_mapping_ref
reachability_inventory_ref
fields_ref
field_selector_policy_ref
mandatory_pair_policy_ref
factor_policy_ref
~~~

除 scope_mapping_ref 外，每个 *_ref 是 exact-key object：

~~~text
logical_path
raw_sha256
canonical_domain_tag
canonical_sha256
~~~

scope_mapping_ref 的 ordered schema 固定为：

~~~text
scope_id
base_ref
post_ref
mapping_delta_ref
chip_required_role_projection_ref
base_row_count
post_row_count
append_event_ids
~~~

其中 `base_ref`、`post_ref`、`mapping_delta_ref` 和 `chip_required_role_projection_ref` 各自采用上表四个 exact key。`append_event_ids` 是按 UTF-8 byte order 排序的去重数组，且必须与 `mapping_delta_ref` 所列 event ID双向相等；`base_row_count` 和 `post_row_count` 是对应 canonical snapshot 的实际计数。pair builder 验证 `post_ref == Apply(base_ref, mapping_delta_ref)`，再验证 role projection 是 `ActiveContractV7_1` 上述过滤式的完整结果。这样 builder不能只绑定一张 mapping snapshot 后再从 live 文件猜另一张，也不会把未批准的 49/50、37/38 或候选替代数当成合同事实。

active_contract_ref 必须指向 v7.1 active contract post，而非 r38/r01/r02；scope_mapping_ref 必须同时绑定 immutable base、由最终 active mapping delta导出的 post和最终 `ChipRequired` role projection；reachability_inventory_ref 只能指向 H4 输出；其余四个 ref 必须指向 active contract post 中明确列入的 managed policy/table image。manifest 本身采用 domain expected-pair-input-v2，以 Frame(domain, strict_json_bytes(manifest)) 计算 SHA-256。任何 BOM、非 UTF-8、浮点 JSON、重复 key、非 canonical key order、路径逃逸、hash 不匹配、mapping post与 delta不相符、role projection不完整或有两个 active contract reference 均失败。

输入中的 141 fields 来自 fields.csv 的 active v7.1 post。每一行必须 review_status=approved，field ID全局唯一，并保留 allowed_subject_kinds、allowed_requirement_target_kinds、condition_schema、required_tier、value_kind 和 field row hash。允许的 target kind 仅为：

~~~text
object
component
link
object_relation
precision_path
capability
topology
~~~

selector parser 对两个 allowed_*_kinds 字段按分号拆分，要求无空 token、无重复 token、无额外空白、并按上述 token 集合验证。field 的 subject kind 是 coverage/fact 的 canonical subject；本版 ordinary pair 只允许 direct_subject_v1 selector，因此 requirement target kind 也必须等于该 subject kind。当前 141 fields 的 selector集合满足这个条件；若未来字段让 subject kind 不在其 allowed requirement kinds 中，builder 返回 E_FIELD_DIRECT_SELECTOR，不会自行把 pair 改挂到 owner object 或 component。

H4 reachability inventory 的每行使用下列有序 schema：

~~~text
target_kind
target_id
semantic_identity_sha256
owner_object_id
parent_target_id
root_object_id
route_canonical_json
source_row_hash
~~~

它按 (target_kind, target_id) 的 UTF-8 byte order 排序，主键唯一。inventory 的 roots 是 `ResolveObject(ga100_full_die)` 与 `ResolveObject(ampere_architecture)`；两个 resolution都必须来自 H0 的 semantic-identity/formal-key crosswalk。traverse 只允许正式 relation、owner、parent、component-path、capability、link/topology 关系和 active projection policy 所列边。假 capability/topology、未授权 A100 product/system、r14 draft row和与这两个 root 无 route 的正式对象均不能进入 inventory。每个 route 必须能回溯到 H3 candidate view的 row hash，不能通过 label 同名推断 reachability。

### Candidate universe 与决策状态机

builder 先形成完整 universe：

~~~text
U = {(target_kind, target_id, field_id)
     | target in H4 ReachabilityInventory,
       field in 141 approved fields}
~~~

每个 U key 恰输出一条 ExpectedPairRecord。对于 target kind 不属于 field allowed_subject_kinds 的行，decision 固定为 exclude，reason 为 field_subject_kind_not_allowed，并在 coverage-exclusion-review 中留下同一 key。对于允许的 subject kind，direct selector 必须也被 allowed requirement kinds 接受；否则停止，不生成带猜测 target 的 row。

对可选 subject 的 pair，决策优先级固定如下：

1. Mandatory108 命中时，six structural N/A 写 structural_na，另 102 个写 include。此步先于普通 field policy，普通 exclude rule 不得覆盖 mandatory key。
2. GA100 card object的六个 benchmark pair 命中时，一律写 include, mandatory_benchmark_include。它们是 latency、throughput、power、energy-per-token、tokens-per-joule、utilization；不允许 bare-die、no-reachable-subject或 N/A 排除。
3. Ampere architecture的 design objective、target-use positioning、vendor positioning三 pair 命中时，一律写 include, mandatory_ampere_identity_include。GA100 die 的同名三 pair也必须由 active `mandatory_ga100_identity_search_include` policy写 include并进入独立 search obligation；它们不能因 Ampere已有 value而消失，也不能被 ordinary exclude覆盖。
4. 其余 pair 按 active field_selector_policy_ref 的 field rule执行。card selector 为 false 时，恰一条 explicit_card_scope_exclusion 必须命中。card selector 为 true 时，mandatory target selector恰一条命中则 include；若无 mandatory selector 命中，恰一条 exclude selector必须命中。两类 selector同时命中、任一类命中多条或两类都不命中都返回 E_SELECTOR_CARDINALITY。
5. active rule若允许 normal structural N/A，必须有唯一 predicate 命中、非空 reason，并与 mandatory six N/A 互不重叠；否则不可把资料缺失改写为 N/A。

规则 1 至 3 的强制 pair 若在 H4 缺 target、field或 required policy，则返回 E_MANDATORY_PAIR_MISSING；不会默默降为 exclude。规则 4 的所有 exclude reason code必须在该 field 的 active allowed reason set中，且 predicate scope必须为 target。任何人工 decision column 都被忽略并报告 E_UNDECLARED_PAIR_DECISION。

### ExpectedPairRecord、hash 与跨表相等式

ExpectedPairRecord 的 ordered schema 是：

~~~text
target_kind
target_id
field_id
selector_id
decision
decision_reason_code
mandatory_policy_id
applicability_predicate_id
subject_semantic_identity_sha256
~~~

逻辑主键是 (target_kind,target_id,field_id)，按该三元组的 UTF-8 byte order排序。selector_id 对 direct pair 固定为 direct_subject_v1；无 policy/predicate/reason的字段使用空字符串，禁止省略 key。单行 hash 为：

~~~text
Frame("expected-pair-row-v2", strict_json_bytes(ExpectedPairRecord))
~~~

全体 row array hash 为：

~~~text
Frame("expected-pair-set-v2", strict_json_bytes(rows_sorted_by_logical_key))
~~~

H6 必须从输出派生四个互斥集合：

~~~text
IncludedPairKeys     = {key | decision == include}
StructuralNaPairKeys = {key | decision == structural_na}
ExcludedPairKeys     = {key | decision == exclude}
RequiredPairKeys     = IncludedPairKeys union StructuralNaPairKeys
~~~

下面的关系必须双向 set-equal，且每个逻辑 key最多一条实际 row：

~~~text
coverage-target logical keys              == RequiredPairKeys
field-requirement seven-target projection == RequiredPairKeys
reachable-target-binding logical keys     == RequiredPairKeys
coverage-exclusion-review logical keys    == ExcludedPairKeys
~~~

structural_na 的 field requirement必为 not_applicable；include 的 requirement在 H7 才以 actual evidence/search裁决 terminal status。H7 terminal key set必须与 RequiredPairKeys 双向相等，但 H7 的 status histogram不参与上述四个集合的验收。H6/H7 任一多一行、少一行、错 target、错 field、重复 key、错 selector、错 policy hash或把 excluded key写入 requirement，都失败。

## ExpectedFactorBuilder v2

ExpectedFactorBuilder 与 ExpectedPairBuilder 同在 H5 执行，版本为 EXPECTED-FACTOR-BUILDER-V2。其 `ExpectedFactorInputManifest` 与 pair builder使用同一八项 ordered input schema，唯一差别是 `builder_version`；所以它也精确绑定 final active v7.1 contract、scope mapping base/post/delta/ChipRequired projection、H4 object/relation reachability inventory、141 fields、allowed kinds、field selector、mandatory-pair policy和 factor policy。所有 ref、canonical JSON、UTF-8 order、Frame hash、path/hash/duplicate-key拒绝规则完全复用 pair builder；factor builder不得从 pair 的人工结果、live 目录或卡片正文读取输入。factor policy中每个 rule至少有 factor_id、card_selector_predicate_id、allowed_target_kinds、target_subtype_predicate_id、min_targets_if_available、allow_not_applicable、structural_na_predicate_id、minimum source type/authority及其 none|all|any match mode、identity/explains field ID集合和 review status。数组按 UTF-8 byte order排序，空 array只可配 none；重复或未知 token都失败。

builder 的第一输出是 obligation triple：

~~~text
FactorObligationKey = (card_object_id, policy_id, factor_id)
~~~

card selector为 true 的每个 active factor rule恰产生一个 `decision=include` obligation；false 的 rule仅产生一条带 policy reason 的 exclusion review，不产生 factor requirement。FactorObligationRecord 的有序字段为：

~~~text
card_object_id
policy_id
factor_id
decision
decision_reason_code
card_selector_predicate_id
factor_policy_row_hash
~~~

其 logical key就是 obligation triple，按 `(card_object_id, policy_id, factor_id)` 的 UTF-8 tuple order排序；行/集合 hash domain分别为 expected-factor-obligation-row-v2 与 expected-factor-obligation-set-v2。

对于每个 obligation，builder 遍历 H4 inventory 中符合 allowed_target_kinds 和 target subtype predicate的 target，构造 FactorTargetRecord：

~~~text
card_object_id
policy_id
factor_id
target_kind
target_id
decision
decision_reason_code
structural_na_predicate_id
target_semantic_identity_sha256
~~~

逻辑 key 是 (card_object_id,policy_id,factor_id,target_kind,target_id)，按该五元组的 UTF-8 tuple order排序；row/set hash domain分别为 expected-factor-target-row-v2 与 expected-factor-target-set-v2。每一个目标只能有一个 decision。required target写 include；policy允许且唯一 structural predicate命中时写 structural_na；不满足 target subtype、source-independent eligibility 或 min-target policy时写 policy reason的 exclude。min_targets_if_available 的计数只在可达 target存在时应用，不能以假 entity补数；强制因子缺少最小 target时失败。

H6/H7 的 factor 相等式为：

~~~text
factor-requirements logical triples
  == {FactorObligationKey | decision == include}

factor-target-candidates logical keys
  == {FactorTargetKey | decision in {include, exclude, structural_na}}

factor-target-bindings logical keys
  == {FactorTargetKey | decision == include}

factor-target exclusion review logical keys
  == {FactorTargetKey | decision == exclude or structural_na}
~~~

每个实际 factor_requirement_id 必须唯一映射一个 obligation triple；每个 (factor_requirement_id,target_kind,target_id) 必须唯一映射一个 include binding。factor source minimum 的 all 要求每个 token至少由一个 selected、endpoint-qualified、closed evidence的 source family满足；any 只要求至少一个；两个维度分别计算后再 AND。同一 family的多 endpoint或镜像版本只能算一个 family。H8 若模拟移除某 family后不再满足最小来源条件，就必须保留该 family或输出 selection-closure failure；不得回写 H5/H7，也不能借旧 selected source数量补齐。没有 H8 selection closure，H10 仍然阻断。

## 内容 seed 与正式 PK allocation 的隔离

### Candidate content identity

v2 只提供可重新阅读的内容 seed：GA100 full-die边界、11 个真实 component、2 个 link、3 个 memory level、4 个真实 capability、14 个 condition、九条 path语义、direct assertion locator、source bytes、以及 r37/r39 的 Matrix、MLCommons、SEC裁决。seed 进入 CandidateContentManifestV2 时使用内容身份，不带 r14 PK。每个 manifest record 的有序 schema 是：

~~~text
entity_or_claim_kind
semantic_identity_canonical_json
semantic_identity_sha256
source_content_fingerprint
condition_signature_sha256
candidate_disposition
~~~

semantic_identity_canonical_json 对实体至少包含 kind、owner/parent semantic identity、canonical label、operation/class、对象边界和 condition signature；对 fact包含 target semantic identity、field、normalized value/unit、condition、validity和 resolution；对 source包含 family identity、version/edition/date/commit、actual endpoint identity和 payload hash。它用 Frame("ga100-v3-semantic-identity-v2", strict_json_bytes(...)) 哈希。相同 semantic identity出现两次、同一 source content fingerprint被伪装成两个 canonical source、或同一实体仅因 notes不同而重复，均在 H1 前失败。

### 四个互斥 key 集

H0/H1 必须冻结下列四个集合，并以 table path、primary key、row hash和 disposition输出 KeyAllocationManifestV2：

| 集合 | 内容 | 允许的动作 |
|---|---|---|
| ExistingFormalKeys | H0 formal post中已存在的所有 PK。Ampere object/component/path等若被复用，只能绑定 exact H0 row hash。 | 默认 no-write；任何 update必须在 H11显式出现并有 preimage hash。 |
| ContractReservedNewKeys | 仅为 final `ActiveContractV7_1` 的 `ContractReservedNewKeyProjection` 所列的 key。GA100 die object、implements-Ampere relation及 scope mapping delta只按其 semantic identity和 final contract分配，不能沿用历史 ID或预设 event ID。 | 每个 create在各自正式表 H0 expected-absent后创建；mapping post只可由 active delta作用于 immutable base 得到。保留 ID 的资格来自 active contract，不来自 r14 或 historical-v7 fixture。 |
| FreshAllocatedKeys | 新 GA100 entity、fact、assertion、requirement、source、endpoint、search/result、selection、coverage/factor和 payload row。 | 只由下文 allocator给出；每个 key必须 H0 expected-absent。 |
| ForbiddenLegacyKeys | r14 30 CSV 的全部 draft PK、全部旧 requirement/search/result/selection/operation PK、12 个假 entity及从属键。 | 永不出现在 H1/H10/H17。若字符串恰与 contract-reserved key同名，只能按 ContractReservedNewKeys 的 H0 absence与合同来源重建，不能引用 r14 row。 |

ExistingFormalKeys、ContractReservedNewKeys、FreshAllocatedKeys 和 ForbiddenLegacyKeys 必须逐项互斥。每个 H1 candidate都恰属前三者之一；每个 v2 内容 seed只能对应一个 existing_no_write、reserved_create、fresh_create 或 rejected disposition。没有这个 crosswalk，candidate不得进入 H3。

本计划冻结 H0 presence/absence fixture的判定法，而非未批准的 v7.1 key实例。现有 Ampere semantic identities（architecture object、Tensor component、FP16/BF16/TF32/FP64/INT8 precision path）必须从 H0 formal post解析为 `expected-present`，每项带 exact preimage row hash作为 no-write或显式-update guard。GA100 die object、implements-Ampere relation、`ActiveScopeMappingDelta` 的每个 create以及每个 FreshAllocatedKey必须由最终 `ContractReservedNewKeyProjection` 或 allocator解析后成为 `expected-absent`；mapping registry本身则以 active contract绑定的 immutable base为 `expected-present`。若 final post未给出这些语义身份与 key的唯一 crosswalk，H0失败。v2 的 FP16-ACC16、INT4、Binary、GA100 dense FP16 等内容身份可进入 crosswalk，但其 r14 path PK仍在 ForbiddenLegacyKeys，必须用 allocator生成新 key或经正式 existing-key binding证明已存在。

### allocator 与 collision gate

Fresh key 不使用人工复写的 r14 ID。allocator根据 semantic identity hash生成：

~~~text
AllocatedPK(kind, semantic_hash) =
  Prefix(kind) + "-GA100V3-" + semantic_hash
~~~

semantic_hash 使用完整 lowercase SHA-256，Prefix(kind) 固定为：

~~~text
object=OBJ
object_relation=OREL
component=COMP
link=LINK
memory_level=MEM
precision_path=PPATH
capability=CAP
condition_set=COND
fact=FACT
requirement=REQ
assertion=ASSERT
source_family=SFAM
source_version=SRC
endpoint=END
screening=SCREEN
search=SEARCH
search_result=SRESULT
requirement_evidence=REVID
selection_run=SELRUN
selection_member=SELMEM
factor_requirement=FREQ
factor_binding=FBIND
factor_target_candidate=FTCAND
coverage_target=CTARGET
reachable_binding=RBIND
coverage_exclusion_review=EXREV
coverage_field=CFIELD
card_completeness=CCOMPLETE
source_selected_role=SROLE
source_coverage=COV
payload=PAYLOAD
operation=OP
~~~

每种 kind的 prefix和 semantic identity domain都固定，因此 allocator不以 label缩写、行顺序、当前日期或旧 PK决定 ID。若 full hash碰撞、prefix产生与 H0 existing/reserved/forbidden key相同的 ID、不同内容身份分配同一 key、或同一内容身份被要求分配两个 key，builder失败。新 row的 expected-absent guard、existing row的 exact preimage hash、reserved key的合同 token和 source/endpoint的 payload fingerprint必须全部进入 H11/H15/H17；缺任一项即使 CSV PK未重复也失败。

独立的 LegacyRejectFixture 可以从 r14 构造完整 forbidden-key set，用于机器拒绝旧 key；它不属于 H0 input、candidate source、authorization input 或 payload。由此，v2 的证据内容可重读，v2 的 draft PK绝不能成为授权资产。

### v2 semantic crosswalk：可读内容与必须重建的事务分开

下表中的 v2 ID只是在 salvage archive中定位阅读材料的 locator；它们先被丢弃，再由 `CandidateContentManifestV2` 以内容身份重新表达。任何一格都不能把 legacy ID带入 `ContractReservedNewKeys`、`FreshAllocatedKeys`、H0 input、H11 delta或 H15 authorization。

| v2 locator 或内容组 | 可语义复用的内容身份 | v3 必须重建或删除的部分 |
|---|---|---|
| `OBJ-NVIDIA-GA100-DIE` / `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` | full 128-SM physical die 的主体边界，以及 die `implements` Ampere architecture 的方向。 | 从 final contract 分配 object/relation key，并重建 identity、card identity、scope mapping post、relation projection、row/preimage guard和 authorization。A100 108-SM product、module、DGX或监管 IC主体不得混入。 |
| 11 个 `COMP-R1-GA100-*` locator | GPC、TPC、SM、FP32、Tensor、memory controller、L1/shared、L2、register、OFA、video decode这些真实结构或功能语义。 | 每个 component以 owner、scope、condition、actual source和 final PK重建；per-SM capacity、full-die count和 A100 carrier条件不能互相换算。 |
| 两个 link 与三个 memory locator | NVLink interface、PCIe 4 x16 interface；register file、combined L1/shared、L2的层次身份。 | 不创造 topology、degree、hops、aggregate bandwidth或 host endpoint。192 KB L1/shared和 256 KB register file只在 per-SM条件下重建，不能相加或扩成未公开 aggregate。 |
| 四个真实 capability locator | `mma.sp`/metadata-directed sparse、Ampere warp reduction、OFA、video decode 的限定机制。 | sparse不外推成 runtime discovery；warp reduction不等于 collective/Softmax；OFA/video decode不补 count/throughput。每个 capability的 architecture/die scope、source和 condition重新落行。 |
| 14 个 condition seed | 2:4、BF16 sparse、CUDA 11.0/SM80、INT4 pair 4:8、INT8 sparse、NVLink lane/rate、TF32 sparse、full-die、per-SM memory、RAS containment/DPO/row-remap、SM FP16 dense、SM processing block。 | 每个 condition生成 canonical condition signature；保留 datatype、pattern、software revision、direction、aggregation/measurement scope和 external dependency，禁止以无条件 fact替代。 |
| 旧五 path 与四条补全 path的内容线索 | FP16→FP32、FP16→FP16、BF16→FP32、TF32→FP32、FP64→FP64、INT8→INT32、INT4→INT32、Binary→INT32、GA100 dense FP16→FP32 九条语义。 | H1以 semantic-path crosswalk解析 final path key；旧 108 requirement key、draft terminal status和旧 PK全部丢弃，H5 从九条 final path与十二个 field重新生成 closure。 |
| 非 MIG direct fact/assertion 阅读 | 旧 raw value、unit、condition和 locator可供复核 128 SM、8192 FP32 cores、512 Tensor Cores、12×512-bit controllers、N7/area/transistor等公开设计事实；经批准 H2 formula才可导出 6144-bit interface。 | 所有事实和 assertion重新绑定正式 source family/version/endpoint、field、condition、row hash与 subject；MIG identity fact/两条 identity assertion删除，不能把旧 review status或 notes移植为新证据。 |
| requirement/evidence 与 numeric closure | 旧 direct-value、structural-N/A和 search-scope阅读可作为 policy/evidence seed。 | 所有 requirement、evidence、factor binding、coverage和 terminal disposition由 H5-H8重建；旧 pending不能继承。data-cutoff移为 contract/card metadata input，vendor TOPS N/A删除，release-date仍只消费前置 migration post。 |
| source bytes、screening与 selection | family/version/endpoint/payload fingerprint、fixed bytes、locator和 family-dedup阅读可以帮助重搜。 | family/version/endpoint/payload-copy、screening、search/result、source coverage、selected role和 reverse-removal全量重建。旧 selection run/member不继承；MIG610 identity role/member删除，只有 H8 证明不可替代的 VIRT职责才可作为新成员。 |
| operation、coverage、card与假实体链 | 无可直接复用的 transaction asset。 | 旧 operation、coverage、completeness与 card payload全部不进入 H10。11 个 `CAP-R1-GA100-GAP-*`（attention move、collective、compression、dequantize、KV cache、MoE dispatch、MoE route、quantize、Softmax、Top-k、transpose）及 `TOPO-R1-GA100-NVLINK-GAP` 是假 entity；其从属 requirement/template search/template result/coverage链全部删除。其余 legacy template search/result也必须按 actual endpoint、locator、target、field与排除理由重建。 |

`SemanticCrosswalkV2` 的 ordered record schema固定为：

~~~text
legacy_seed_locator
legacy_seed_row_hash
semantic_identity_sha256
source_content_fingerprint
candidate_disposition
resolved_table_path
resolved_pk
h0_guard_kind
h0_guard_value
~~~

其 logical key 是 `(legacy_seed_locator, legacy_seed_row_hash)`，以 UTF-8 tuple order排序；row/set hash domain是 `semantic-crosswalk-row-v2` 和 `semantic-crosswalk-set-v2`。`legacy_seed_locator` 可在审计输出中保存旧路径和旧行定位，但 `resolved_pk` 只能是 final formal key、或 rejected 时空字符串；它绝不能等于 legacy PK。`KeyAllocationManifestV2` 同时按 `(resolved_table_path, resolved_pk)` 排序，输出 `key_class`、`semantic_identity_sha256`、`h0_guard_kind`、`h0_guard_value`、`contract_reservation_token` 与 `allocator_version`，并使用 `key-allocation-row-v2` / `key-allocation-set-v2` 两个 domain。每个 legacy locator只能指向一个 content fingerprint或 explicit rejected disposition；每个候选内容身份必须恰有一个 existing/reserved/fresh/rejected disposition；同一 fingerprint不能在两个 source family中重复；任一 legacy PK若穿透到 planned post，即报 `E_LEGACY_PK_AUTHORIZATION_LEAK`。它把“可语义复用”限定为可重读、可核对的事实材料，而不把 v2 状态、搜索模板、选择结论或事务资产带进新包。

## 来源与事实裁决的保留边界

ExpectedPairBuilder 决定 coverage universe，不能替代 H1/H7 的证据裁决。下列现有内容结论继续有效：

| 主题 | H1/H7 必须保持的边界 |
|---|---|
| Matrix Guide | r37 Matrix fixed snapshot 在 A100-SXM4-80GB、CUDA 11.2、cuBLAS 11.4、datatype/tile条件下支撑 allocator-resolved GA100 Tensor component 的 alignment、small-GEMM tile效率/并行度和 tile quantization限制。它的 r37 endpoint label只是内容 seed；H1必须分配或经正式 endpoint crosswalk绑定实际 formal key。108-SM wave例子必须写 wrong-enabled-scale result，不能替换成 full GA100 128-SM结论。 |
| MLCommons | 固定 commit 36d324b502175621063a478fcbf6d2cb9421ca34 的 Offline 3560.73 samples/s 和 SingleStream 0.001551870 s 是 DGX A100 system-under-test结果。它们只能构成 wrong-subject closure，不能写为 GA100 die benchmark value。 |
| SEC | 10-Q 对 A100/H100 integrated circuits和相关 systems有正面限制内容；对 GA100 die market-access pair只是 checked_no_support。gzip为 duplicate，403为 remote access-policy response，不参加内容证据。 |
| six benchmark | latency、throughput、power、energy-per-token、tokens-per-joule、utilization始终由 ExpectedPairBuilder include。当前固定 corpus可导向 endpoint-aware not_found；若未来正式 source给出正确主体、条件完整的 direct measurement，H7可改为 value。 |
| Ampere identity | architecture 的 design objective、target-use positioning、vendor positioning三 pair始终 include并由白皮书 direct assertion闭合；GA100 die 的同名三 pair仍要独立 search，不能关系投影。 |
| CUDA/MIG/RAS | CUDA/PTX是 architecture/software-visible ISA语义，不证明 SASS、physical accumulator、array、RTL或 runnable measurement。MIG不能做 GA100 identity source；GI/CI、vGPU lifecycle和driver条件分开。RAS按 on-die、external HBM、NVLink、driver、InfoROM、reset/service等 scope记录。 |

11 个 CAP-R1-GA100-GAP-* 和 TOPO-R1-GA100-NVLINK-GAP 继续在 ForbiddenLegacyKeys 中。它们的 20 条 requirement、17 条 template search、34 条 template result和 11 条 coverage从属链不能经 factor builder复活。机制缺口只能产生没有假实体的 factor obligation、target binding或 search policy。

从 H1 到 H8 的 source chain必须按 `source family → version → actual endpoint → immutable payload → screening → assertion/search → endpoint result → requirement evidence → selected role → reverse-removal` 单向生成；每一跳都带上游 row hash和 source-content fingerprint，H8只能消费 H7 closed result，不能用 selection反填 screening或 evidence。r29 的 official-web v2 仅提供 29 个 manifest 中 27 个成功 snapshot（22 HTML、5 PDF）和两个无 payload拒绝项；r37/r39 的 11 个 asset仅提供 8 canonical、2 duplicate、1 failed attempt的内容裁决。这些 fixed bytes可以成为 H0 candidate raw input，但必须先正式注册 family/version/endpoint/payload/screening。duplicate只可参与去重与 search range，failed capture和历史 403/DNS失败只记录 transport/access资格，均不能支持 positive fact或 `not_found`。每一条 `not_found` 需要 actual endpoint范围、关键词、locator/section/JSON path、target/field和 source-specific exclusion reason；每一个 selected family还要有 H8 before/after closure hash、不可替代职责和反向移除结论。

## H0 至 H24 的实现顺序

H0 至 H24 保持 r38 的严格升层关系。H0只读取已应用的 v7.1/release post、immutable mapping base、由 final contract机械投影的 mapping post与 `ChipRequired` role set、source/candidate raw bytes和 transaction ID。H1产生 direct row/payload candidates，H2只产生 formula rows，H3构成 preliminary semantic post，H4构成 reachability inventory，H5运行本版两类 builder，H6生成 coverage/target/factor binding，H7形成 terminal adjudication，H8运行 selection/reverse-removal，H9生成 coverage field与 card renderer input，H10汇成 complete planned post，H11对 H0/H10 求 exact delta，H12生成 closure，H13生成 58-key coverage manifest，H14 coverage approval，H15/H16完成 authorization，H17 materialize operation/payload/file-input inventory，H18产生 isolated mirror，H19至H24依次完成 image、rollback、manifest、approval和 journal。

新的两个 builder只增加 H4 到 H5、H5 到 H6的 deterministic semantic edge；不能与 H6/H7/H8同层互读，不能让 H7 evidence状态反过来删改 ExpectedPairSet，也不能让 approval参与 selector或 PK allocation。H10必须同时包含 object、identity、final active mapping post、all coverage rows和受管 card candidate；H18与H10逐表、逐行、逐payload exact set-equal。operation数仅在 H17由完整 H11 delta materialize，蓝图不预设总数。

## v2 重新送审的机器验收条件

重新送审前，实施者必须提交版本化 builder fixture、input manifest、expected output manifest、negative fixtures和三个 runtime transcript。以下条件都应由机器检查；缺任一项即保持 reject。

| 验收项 | 必须通过的 machine condition |
|---|---|
| MA-01 active input | manifest只解析一个 v7.1 active contract post；r38、historical-v7 38-input fixture、r01/r02、r40/r41、r14及任何 pending/rejected release artifact作为 active input均被拒绝。141 fields、selector/factor/mandatory policy、scope mapping、`ChipRequired` role projection、mapping delta和 H4 inventory的 raw/canonical hash必须与 manifest相等；projection row/set与 final contract过滤行双向相等。 |
| MA-02 pair universe | H4 target inventory与 141 fields产生完整 U；每个 U key一条 ExpectedPairRecord，key/order/row hash/set hash正确。删一行、加一行、错 kind、错 field、重复 key、非 canonical selector字符串均失败。 |
| MA-03 mandatory numeric | final 9 path映射与12 field产生108个唯一 mandatory key；six N/A final-key set恰为 INT8/INT4/Binary的 rounding/subnormal。任何 six key被exclude或非 N/A、其余 mandatory key被exclude、six benchmark、Ampere three pair或 GA100 identity-search three pair缺失/被exclude，均失败。 |
| MA-04 dynamic evidence | fixture可让 102 个 ordinary mandatory key中的任一格因 direct assertion或 endpoint search改变 terminal status；只要 H7 evidence closure合法，验收仍通过。验证器只校验 terminal key set和 six N/A set，不含 value/not_found固定计数比较。 |
| MA-05 pair propagation | coverage-targets、field requirements、reachable bindings与 RequiredPairKeys 双向相等；exclusion review与 ExcludedPairKeys 双向相等；H7 terminal keys与 RequiredPairKeys双向相等。 |
| MA-06 factor builder | active factor obligation triples与 factor-requirements logical keys双向相等；include factor targets与 factor-target-bindings双向相等；exclude/N/A target与 factor exclusion review双向相等。all/any/none source minimum、min-target、duplicate logical key和foreign work-package fixture必须各有负例。 |
| MA-07 PK allocation | four key sets互斥；every fresh/reserved create H0 expected-absent；every existing reuse含 exact preimage hash；full semantic identity、allocator collision、reserved-ID misuse、duplicate source fingerprint、r14 forbidden key和fake entity revival均被拒绝。 |
| MA-08 release gate | r02 reject 不能通过；只有 v2 amendment design independent accept、implementation success、postimage independent accept与 v7.1 active binding共同存在时，I-release 才可构造。 |
| MA-09 transaction/card | H5 outputs只向 H6流动；H10包含 card candidate；card payload出现在 H11/H15/H17/H18且 apply 后重渲染 bytes相等。H13的 schema仍恰为58 key，新增 card hash key必须失败。 |
| MA-10 postimage | H18与H10的 tables、rows、payloads、source selection、final active mapping post和 card payload逐项相等；H19至H24的 image/rollback/manifest/approval/journal可从 H0/H17重建。三个 Windows runtime gate均 PASS后才允许实际 apply。 |

MA-04 是 r41 B01 的核心回归门：它强制实现者证明 status可以随着真实证据变动，而 coverage shape、six structural N/A和完整 transaction仍保持闭合。任何测试、policy或 validator若把历史 value/not_found总数当作通过条件，都应视为 E_PRESET_STATUS_DISTRIBUTION 并拒绝。

## 交付边界与文本复核

本报告只定义未来 v3 的可执行构造和重送审门，不宣称 source-pool、contract、release amendment、source ingestion或 Windows gate已完成。当前 Mac 上缺少 PowerShell属于 tool/runtime limitation；本次没有试图绕过或把它写成验证通过。

本文定稿后应单独运行 report-humanizer，并从本节逆读机器验收、H0至H24、来源边界、PK allocation、factor/pair builder、9×12、scope和前置门。人工复读重点检查：是否还保留固定 status配额、是否把 v2 PK混入授权输入、是否把 r02误称 pending、是否让 card扩张H13 schema、以及是否把 A100/DGX/SEC/MLCommons证据越界写给 GA100 die。最终 SHA-256与行数在交接回报中给出，避免将自引用 hash写回正文。
