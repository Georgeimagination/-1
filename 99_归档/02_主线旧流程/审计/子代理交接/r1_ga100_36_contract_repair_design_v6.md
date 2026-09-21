# GA100 资料卡合同修复设计 v6

## 状态、规范基底与写入边界

本稿只修订机器合同，不授权执行 contract migration，也不表示 GA100 芯片工作包、三运行时 fixture 或 Windows 数据门已经通过。本轮唯一允许的新文件是本文件；正式 CSV、活动名单、validator、模板、staging 和进度文件保持原字节。

规范继承顺序固定为 v3、R08、R09、v4、R10、v5、R12、R35 来源独立复核、v6。v4、v5 中已经通过且未被后续独立复核否决的 byte contract、logical key、selector、managed-state、latency mapping、AFPV2、actual endpoint、source locator、cutoff、derived DAG、reconciliation lifecycle、58-key coverage manifest、事务日志、factor migration 分支、actual-row family 归约和六个 mandatory N/A 规则继续生效。本稿与前稿冲突时以本稿为准。

| 冻结输入 | SHA-256 |
|---|---|
| `r1_ga100_19_contract_repair_design_v3.md` | `f590a98ec29f3202c3d2eb3801f5fcddf165fd31bd5c86f2d778b797e0276cf8` |
| `r1_contract_08_design_v3_independent_review.md` | `161cfc6142b6b84b823fa65ec4c7d5476bf2601d9073ca4ef9462abf89c27a07` |
| `r1_contract_09_design_v3_additional_redteam.md` | `37bcc1243862d2c7540c05caff323d10d0d1da12246d33a556623707ba553f69` |
| `r1_ga100_26_contract_repair_design_v4.md` | `4771e201f404699f41f486fa85adba8609e9c5c5797632fb52f99ededce9b349` |
| `r1_contract_10_design_v4_independent_review.md` | `afad0d0ce892b130cd1846b8ba713f966ba9cd9051372a213a8bd9565dde5e34` |
| `r1_ga100_31_contract_repair_design_v5.md` | `067cde50421c8108be1b6407f18d68ab650369803b74a295c4da285052534c5e` |
| `r1_contract_12_design_v5_independent_review.md` | `4919b674244c0c933da7cf4b213baed87d345706b8827bfc6856df3cf73d4a65` |
| `r1_ga100_35_field_benchmark_gap_independent_review.md` | `b72d09c70152e5288c9609cf06194257525a32bde6ce2ce90cfab3e4da271fd4` |
| `r1_source_pool_113_v4_independent_review.md` | `6980a2d109e6bf17de2ce47829b1c2063dcefe1a1e323413a818992dc02c5b11` |

当前正式基线仍为 32 张表、346 个 schema column、141 个 field、76 个 enum group、557 个 enum row、78 个 object、585 条 completeness、832 条 assertion 和 93 个 source version。活动名单仍为六列、49 行。13 个 stable target、两张 factor table 和 `审计/合同注册表/` 当前均不存在。

v6 不改变已经复算通过的正式 postimage：

```text
tables:          32 + 2                       = 34
schema columns:  346 + 4 + 20 + 5 + 1       = 376
fields:          141 - 1 + 1                 = 141
enum groups:     76 + 1                      = 77
enum rows:       557 - 1 + 5 + 1 + 2         = 564
```

v4 的七个 golden serialization oracle 和 `managed-state-rowset-v2` oracle原样保留。v5 已闭合的 11 个 contract table image、24 个 payload、35 个 managed target、20 个 restore、15 个 delete-created、13 个 stable artifact、factor-create migration-only、source-family singleton、六个 mandatory N/A 四键、108 个 mandatory key和 58-key coverage manifest也不重写。R35 触发的 normal die-count N/A、benchmark 强制 include 和 Ampere architecture pair 裁决只改尚未落盘的 coverage-policy candidate 及后续 chip operation universe，不改上述 contract migration target 算术。release-date 新语义则按本稿后文的原子 gate 暂缓，不在本事务中偷换既有行语义。source-pool-113 v4 是唯一前置事务，它不增加 managed target，但使 bootstrap base 增加两个独立 prerequisite item，因而 file-input 算术在后文从94更新为96。

## SemanticPath 统一 canonical 身份

### 唯一语义路径函数

每个 bootstrap item 都有物理 `source_path` 和逻辑 `logical_target_path`。v6 对 candidate、base、post 和 unchanged 四类 item 统一定义：

```text
SemanticPath(item) = item.logical_target_path
BaseItem(p).source_path = T/inputs/base/<p>
BaseItem(p).logical_target_path = p
PostItem(p).source_path = T/inputs/post/<p>
PostItem(p).logical_target_path = p
UnchangedItem(p).source_path = T/inputs/unchanged/<p>
UnchangedItem(p).logical_target_path = p
CandidateItem(role,p).source_path = T/inputs/bootstrap/targets/<p>
CandidateItem(role,p).logical_target_path = p
```

`T = 审计/事务/<transaction_id>`。路径保留 Unicode scalar，不 trim、不 case-fold、不做 Unicode normalization。所有 path 仍须通过 v4 的 `ValidateSafeProjectRelativePathV1`。

对任何 controlled CSV item，`research-csv-row-v1` envelope 的 `table_path` 必须逐字等于 `SemanticPath(item)`。物理 `T/...` path 只用于读取原字节，禁止进入 row envelope、logical PK、row hash 或 rowset hash。对活动名单的 parsed row envelope同样使用逻辑目标 `清单/训练与推理芯片名单.md`。canonical JSON 使用本稿给出的 role-to-domain，不把物理路径混入 domain。

### snapshot、image 和 stable copy 的逐项等式

对九张现有受管正式表 `p`：

```text
Raw(BaseItem(p))      == images[p].preimage_raw_file_sha256
Canonical(BaseItem(p), SemanticPath=p)
                         == images[p].preimage_canonical_set_sha256
Raw(PostItem(p))      == images[p].expected_postimage_raw_file_sha256
Canonical(PostItem(p), SemanticPath=p)
                         == images[p].expected_postimage_canonical_set_sha256
```

对两张新 factor table 只存在 PostItem 等式；preimage 必须 absent。对 11 个 present→present raw payload，base/post raw hash分别与 payload inventory逐项相等。对 13 个 candidate stable target，candidate 原字节必须等于 stable postimage，canonical hash必须用 stable target语义重算并逐项相等。任何 item 的自报 `canonical_domain_tag/canonical_sha256` 与独立 role/path builder 不相等，返回 `E_HASH_INPUT_CONTRACT`。

`FIX-V6-SEMANTIC-PATH-FIELDS-ROW` 固定使用当前 `数据/fields.csv` 第一条 data row。无论原字节从 live、`T/inputs/base/数据/fields.csv` 还是 `T/inputs/post/数据/fields.csv` 读取，只要 `logical_target_path=数据/fields.csv`，row hash 都必须为：

```text
33b9c8872bb811fb91c3147df2c6c85f852ae63cf6be380e9f84b3a35de5eff2
```

把物理 base path或post path写进 envelope 时必须分别拒绝；已知错误结果 `b43d5fe8867c74f0487df09b3f6fca35ac5763f27742126c6d7c0ac3df1860c6` 和 `d43f156813cf3b382a603af19fb6ef460883435b9276ef6f055d15a97212b81a` 只能作为 negative fixture，不能成为合法 canonical identity。另一个 positive fixture把相同 controlled CSV bytes放在两个不同物理 source path，声明同一 logical target，要求 canonical rowset hash逐字相同。

## freeze archive 只按现有 raw bytes 导入

`scope_freeze_archive` 固定为 raw-only。`transaction-file-inputs.csv` 和 bootstrap item中的 `canonical_domain_tag`、`canonical_sha256` 必须同时为空；它不进入 32/34 张正式表的 canonical registry。

冻结原字节合同如下：

```text
path = 审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv
byte_length = 55224
raw_sha256 = df171b83b1be7dd747e9c78f5417ce8347c4bfcf70c31cb77f39699f44ef41ea
leading_bytes = efbbbf
record_separators = 64 CRLF + 14 LF-only
bare_CR = 0
data_rows = 77
```

24 列 header 必须逐字等于：

```text
freeze_row_id,early_candidate_id,existing_formal_object_id,vendor,canonical_chip_name,object_layer,time_bucket,time_boundary,availability_at_identity_cutoff,training_inference_relevance,inclusion_status,counts_toward_chip_completion,silicon_design_group,counting_method,related_nonchip_products,exclusion_reason,official_source_title,official_source_url,official_source_locator,identity_checked_date,author_review_status,independent_review_status,freeze_state,notes
```

import parser 的顺序固定为：先对未修改原字节校验长度和 SHA-256；再要求恰一个开头 UTF-8 BOM；去掉该 BOM 后按 RFC 4180 quote/double-quote语义解析，CRLF 与 LF 都是 record separator，bare CR、cell 内 CR/LF、非法 UTF-8、列数不等于24或数据行不等于77均失败。parser 不先统一换行、不重写 quote、不 trim cell。`freeze_row_id` 必须非空且77行唯一；bool只允许小写 `true/false`；`counts_toward_chip_completion=true` 必须恰有49行。只要 raw hash变化，即使宽容解析后得到相同 cell，也返回 `E_FREEZE_ARCHIVE_RAW_DRIFT`。

## 49 个 scope 的唯一 byte builder

### 六个 cell constructor

对筛出的每条 freeze row `r`，活动名单六个原 cell 只能由以下函数构造：

```text
Vendor(r) = r.vendor
ChipName(r) = r.canonical_chip_name
Layer(r) = {"die":"裸片（die）","package":"单芯片封装（package）"}[r.object_layer]
Role(r) = {"include_main":"主样本",
           "include_historical_anchor":"历史锚点"}[r.inclusion_status]
SharedGroup(r) = "`" + r.silicon_design_group + "`"
IdentityLink(r) = "[" + r.official_source_title + "](" +
                  r.official_source_url + ")"
```

反引号、ASCII 方括号和圆括号都是 constructor bytes的一部分。禁止输出裸 group、`[title](<url>)`、转义 URL、HTML link、额外空格或 normalized URL。输入 cell也不 trim、不 decode URL、不 normalization。六元组
`(Vendor,ChipName,Layer,Role,SharedGroup,IdentityLink)` 必须与六列活动名单49行构成双射；零匹配、多匹配、重复 tuple或任一侧有剩余行都失败。

匹配后按活动名单当前行序分配 `SCOPE-0001` 至 `SCOPE-0049`，七列 postimage 只在最前面增加 scope_id，六个旧 cell逐字不变。`FREEZE-NV-001 -> SCOPE-0001` 必须成立。

### formal join 与唯一 pending 状态

formal join 只能读取 `freeze_row.existing_formal_object_id`。非空值必须作为 `数据/objects.csv.object_id` exact key命中恰一行；空值不得用 `canonical_chip_name`、label、厂商名称或模糊匹配补连。identity completeness也只能按该 object ID查 `card-completeness.csv` 的唯一 identity row。

首次 mapping 的机械分类固定为：

| 条件 | `formal_object_id` | `proposed_formal_object_id` | `mapping_status` | `approval_status` | 行数 |
|---|---|---|---|---|---:|
| existing ID存在、唯一 identity row存在且 post scope可闭合 | existing ID | 空 | `mapped` | `approved` | 9 |
| `FREEZE-NV-002` / GH100 | 空 | `OBJ-NVIDIA-GH100-DIE` | `pending_identity_review` | `needs_resolution` | 1 |
| `FREEZE-NV-001` / GA100 | 空 | `OBJ-NVIDIA-GA100-DIE` | `pending_formal_object_create` | `needs_resolution` | 1 |
| 其余 | 空 | 空 | `unmapped` | `approved` | 38 |

pending event 的 approval status 在 v6 中只有 `needs_resolution`，不再允许 reviewed/needs_resolution 二选一。GA100 proposed ID继承 v3，GH100 proposed ID只能取 archive 的 existing ID。49条 event 的 `mapping_event_seq` 都是1。

### allocation 与 mapping semantic projection

独立 builder不伪造 reviewer/date/notes。candidate可在批准前固定这些审计元数据，但 bootstrap set-equal只比较下列机器可独立生成的 semantic projection；candidate完整行仍受 schema、PK、date、approval和 raw/canonical hash约束。

```text
AllocationProjection(row) =
  (freeze_row_id,scope_id,allocation_state,
   active_list_row_canonical_sha256,approval_status)

MappingProjection(row) =
  (freeze_row_id,scope_id,mapping_event_seq,
   formal_object_id,proposed_formal_object_id,
   mapping_status,approval_status)
```

allocation builder恰生成49行 `active+approved`，其 row hash来自同一七列 postimage和 `active-scope-markdown-row-v1`。mapping builder恰生成上表49行。candidate registry对两个 projection分别与 builder双向 set-equal，每个 projection key恰一行；额外 event、遗漏 event、错 proposed ID、把 pending标approved或使用六列 row hash都失败。

## R35 后的 field 与 expected-pair 硬门

### release-date 新语义只冻结迁移目标，本事务不发布

`FIELD-ID-RELEASE-DATE` 的全库目标语义固定为“厂商/官方来源首次公开且直接命名具体研究对象的日期”，目标中文字段名为“首次公开日期”。该日期与 availability、first shipment、上市销售日和 source 的普通修订日期分开；只有官方页面在该日期直接命名 exact object，且没有更早的同类官方公开，才能支持该值。依此语义，2020-05-14 的 NVIDIA BLOG 可成为 GA100 的 candidate value，但不因“可以”而自动成为已发布 fact。

本 v6 contract migration 不执行这项全库语义迁移。`fields.csv`、`facts.csv`、`field-requirements.csv`、字段字典和资料卡模板都保持当前 raw/canonical snapshot；因此 23 张 unchanged table和11个 table image不变。file input 只因 source-pool 前置增加两项而为96，与 release-date 无关。coverage policy candidate 必须含 `release_date_semantics_gate`，exact key 顺序与类型为：

```text
current_effective_field_name_zh(string)
current_effective_definition(string)
target_field_name_zh(string)
target_definition(string)
migration_status(enum: deferred_blocking)
ga100_pre_migration_requirement_status(enum: pending_verification)
legacy_fact_ids(array[string])
legacy_requirement_ids(array[string])
review_status(enum: reviewed)
notes(string|null)
```

current 两值必须逐字等于正式 `fields.csv` 的“首次发布日期”和“具体对象日期，不用架构预告代替”；target 两值必须逐字等于上段给出的新名称和新定义。两个 ID array按 UTF-8 bytes 排序、去重，并分别与当前正式表的两个独立查询 set-equal：

```text
Select facts.csv.fact_id
  where field_id == FIELD-ID-RELEASE-DATE
== {
  FACT-AWS-TRN2-ARCH-RELEASE-DATE,
  FACT-M2W3-AMD-MI455X-RELEASE-DATE,
  FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE,
  FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE,
  FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE
}

Select field-requirements.csv.requirement_id
  where field_id == FIELD-ID-RELEASE-DATE
== {
  REQ-CAMBRICON-MLU590-RELEASE-DATE,
  REQ-M2W3-AMD-MI350P-RELEASE-DATE,
  REQ-M2W3-AMD-MI455X-RELEASE-DATE,
  REQ-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE,
  REQ-M2W3-HUAWEI-ASC950DT-RELEASE-DATE,
  REQ-M2W3-HUAWEI-ASC950PR-RELEASE-DATE
}
```

这是五条 fact 和六条 requirement 的迁移前完整宇宙，不是抽样。本事务只验证它们仍为 unchanged，不允许将旧值、旧 rationale 或旧 fingerprint 静默解释为新语义。GA100 release-date requirement 在独立迁移 apply 前只能为 `pending_verification`；无论 BLOG 内容是否已找到，本 package 都不得先写 `value_available`。

后续独立迁移必须原子地产生：`fields.csv` 中该 field 行的 update；字段字典和资料卡模板的 update payload；上述五条 fact 与六条 requirement 逐行语义审计和对应 operation。每个旧行的独立裁决只能是 `retain_recomputed,repair,downgrade`；`retain_recomputed` 必须绑定证明“最早官方公开并直接命名”的 actual endpoint、canonical locator和重算 fingerprint，不能证明则修复值或降级状态。MI455X 的 `Launch Date 7/23/2026` 不自动等于首次公开，必须检索更早官方直接命名；MLU590 的“开发中披露”和 MI350P 的“article publication date 不能代替 release date”旧 rationale 在新语义下均失效，必须重新裁决。Trainium2 与 Ascend 950 die/PR/DT 也不允许无审计继承。任一行无最终裁决、缺证据链或 operation 不与该11行双向 set-equal，整个新语义迁移 fail closed，不得宣称“首次公开日期”已发布。

上述11行只是结构化核心全集，不是完整 write set。后续迁移的独立 reference builder 还必须扫描并以受控 manifest 与全部命中引用双向 set-equal：assertion/evidence/search链、active card、completeness说明、selection run/member/role/screening、研究计划，以及 Trainium2 reuse map/架构卡/试填、MLU590/MI455X/MI350P卡和 Ascend 950 die/PR/DT卡中的所有语义引用；漏任一命中项即阻断。Trainium2 的 accepted fact 当前没有同 field requirement，MI455X 和 Ascend 950 die/PR/DT 的四条 `value_available` requirement 所引 facts 仍为 provisional，都必须在新语义下显式裁决，不得因现有 status 自动保留。除了11行 operation set-equal，reference manifest不完整也必须返回 `E_RELEASE_DATE_MIGRATION_BLOCKED`。

### die-count normal structural N/A

coverage policy 的 `predicates` 新增一个 exact object：

```json
{"predicate_id":"PRED-NORMAL-PHY-DIE-COUNT-TARGET-IS-DIE-V1","predicate_scope":"structural_na","all_of":[{"table_path":"数据/objects.csv","column_name":"object_type","operator":"equals","values":["die"]}],"none_of":[],"review_status":"reviewed","notes":null}
```

该 clause 只在 candidate 已用 `(target_kind=object,target_id)` exact key 命中的那一条 `objects.csv` row 上求值；不允许对全表做 existential 匹配。`FIELD-PHY-DIE-COUNT` 的 normal field rule 必须固定 `allow_structural_na=true`、`structural_na_predicate_id=PRED-NORMAL-PHY-DIE-COUNT-TARGET-IS-DIE-V1`。当 object type 为 `die` 时，candidate 仍是 `include`，requirement 才可以是 `not_applicable`；当 object type 为 `package` 时该 predicate 必须 false，candidate 仍是 include 并走 value/not_found 证据闭合，不得套用 die N/A。

normal N/A 的 `applicability_reason` 必须是 exact-key JSON：`reason_contract_version,reason_code,target_kind,target_id,structural_na_predicate_id,proof_requirement_evidence_id`，version 固定 `NORMAL-STRUCTURAL-NA-V1`，reason 固定 `target_is_a_die_not_a_containing_package`。proof ID 必须解析到 `supports_not_applicable` evidence，其 actual endpoint 和 canonical locator 直接支持 exact target 为 die，reviewer 非空且不等于 coverage manifest.prepared_by。自由文本 reason、无 endpoint 的 die photo、package 行 N/A 或 exclude 都返回 `E_STRUCTURAL_NA_PROOF`。该规则属 normal field，不改原六个 mandatory N/A 四键与 108-key 算术。

### GA100 benchmark 六对强制 include

用户要求“可能影响因素也要纳入”。因此 policy 必须含 `ga100_forced_object_include_rules`，其 item exact key 为 `field_id,target_kind,target_id,reason_code`，并与下列六行 set-equal：

```text
(FIELD-BENCH-LATENCY,object,OBJ-NVIDIA-GA100-DIE,card_scope_requirement)
(FIELD-BENCH-THROUGHPUT,object,OBJ-NVIDIA-GA100-DIE,card_scope_requirement)
(FIELD-BENCH-POWER,object,OBJ-NVIDIA-GA100-DIE,card_scope_requirement)
(FIELD-BENCH-ENERGY-PER-TOKEN,object,OBJ-NVIDIA-GA100-DIE,card_scope_requirement)
(FIELD-BENCH-TOKENS-PER-JOULE,object,OBJ-NVIDIA-GA100-DIE,card_scope_requirement)
(FIELD-BENCH-UTILIZATION,object,OBJ-NVIDIA-GA100-DIE,card_scope_requirement)
```

builder 先生成六个 expected pair，再在 normal selector 的可排除分支之前强制生成 `include` candidate。它们不得因 bare die、full 128-SM design 没有现成 test carrier、A100 是108-SM product、`no_reachable_subject` 或“暂未找到”而 exclude/N/A；`no_reachable_subject` 仍不是合法 requirement status。正确主体和完整条件的 measurement 存在时走 `value_available`；否则只能在每个实际查过的 source/version 都有同源 actual endpoint、非空 locator 和 `checked_no_support|duplicate`，且至少一条 `no_reliable_result` search log 后写 `not_found`。A100 card/system 测量可作 wrong-subject closure，不得逆投为 GA100 die value。未固定的 `A100-BENCH` 不计入负证据闭合。

### Ampere architecture 三对显式裁决

reachable inventory 中既有 `OBJ-NVIDIA-AMPERE-ARCH`，expected-pair builder 必须生成下列三对，并全部裁决为 include：

```text
(FIELD-ID-DESIGN-OBJECTIVE,object,OBJ-NVIDIA-AMPERE-ARCH,include,selector_match)
(FIELD-ID-TARGET-USE-POSITIONING,object,OBJ-NVIDIA-AMPERE-ARCH,include,selector_match)
(FIELD-ID-VENDOR-POSITIONING,object,OBJ-NVIDIA-AMPERE-ARCH,include,selector_match)
```

`FIELD-ID-DESIGN-OBJECTIVE` 必须由 Ampere whitepaper p.38 的 architecture-level strong-scaling 目标及正式 actual endpoint/assertion 闭合为 value，不能把 GA100 die 的 `not_found` 复制过来。另两对同样不允许消失；若当前证据不足，先保持 `pending_verification`，只有完成 endpoint-aware 负证据后才可以 `not_found`，不得 exclude 或 N/A。builder 以 `(field_id,target_kind,target_id)` 为键，所以 GA100 die 上同 field 已有结果不会折叠或拦截 architecture pair。

上述三类 policy 修订进入尚未创建的 `coverage-policy-v5.0.json` candidate；路径、stable artifact 数和 schema/table/field/enum 总数不变。policy canonical hash、approval artifact hash、bootstrap candidate hash、payload/input hash、managed-state hash、transaction manifest 和后续 chip authorization 必须按这些完整 nested object 重算。任何沿用新规则加入前的 preliminary policy hash 都返回 `E_POLICY_HASH`。

coverage policy 仍属 `COVERAGE-POLICY-V5` schema，stable path 仍是 `审计/合同注册表/coverage-policy-v5.0.json`。因该 candidate 尚未落盘，v6 在此取代 v4/v5 的“顶层 key 与 v3 相同”约定，将完整顶层 exact key 顺序最终冻结为：

```text
coverage_policy_contract_version(string)
policy_id(string)
effective_date(date)
supersedes_policy_id(string|null)
target_kind_order(array[string])
include_reason_codes(array[string])
exclude_reason_codes(array[string])
projection_rules(array[object])
predicates(array[object])
field_rules(array[object])
field_unit_rules(array[object])
factor_rules(array[object])
zero_included_field_factor_map(array[object])
ga100_mandatory_policy(object)
release_date_semantics_gate(object)
ga100_forced_object_include_rules(array[object])
prepared_by(string)
prepared_date(date)
reviewed_by(string)
reviewed_date(date)
review_status(string)
notes(string|null)
```

version必须逐字等于 `COVERAGE-POLICY-V5`，除新增两项外的nested schema、nullable、object sort和FK继承v4/v5。`include_reason_codes` 仍只能是 canonical-sorted `card_scope_requirement,mandatory_include,selector_match`，本稿不新增reason enum；六个benchmark rule使用既有 `card_scope_requirement`。`release_date_semantics_gate` 的schema与排序就是前文所定。`ga100_forced_object_include_rules` 每项exact key顺序为 `field_id,target_kind,target_id,reason_code`，按这四值的 UTF-8 bytes tuple升序，四键logical key唯一，数组与前文六行双向set-equal。未知顶层key、两项互换位置、forced rule乱序/重复/遗漏或仍按v3顶层生成都返回 `E_JSON_KEY,E_JSON_ORDER,E_POLICY_HASH` 中对应错误。

## source-pool-113 的唯一前置顺序

source-pool-113 v4 必须先完成正式推广，然后 v6 才能冻结 bootstrap。唯一合法顺序是：113 事务的 sequence 00至08 成功写入，Windows 上的 SourcePool、ChipScope、ResearchData 三门按 sequence 09至11 全部 PASS，promotion record 收尾为 succeeded，独立 prerequisite 批准，最后才生成 v6 Test-SourcePool BaseItem 并批准 bootstrap。v6 先 apply、两事务并行写 validator，或在当前旧 validator 上冻结 base，都返回 `E_UPSTREAM_PREREQUISITE`。

`scripts/validation/Test-SourcePool.ps1` 的 v6 BaseItem 必须绑定 source-pool-113 已推广 post raw SHA-256：

```text
c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0
```

当前旧值 `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f` 只是113事务的 precondition，禁止作为 v6 BaseItem、rollback preimage 或 test-source-pool patch preimage。v6 可现在用已验收 staging candidate 预制 expected base 的 hash，但不得从当前 live 旧字节创建 T snapshot；只有正式 live 在113成功后也等于 `c2dc...fbf0`，才能把它复制进 `T/inputs/base/`。v6 的 `test-source-pool.patch.json`、post snapshot、payload preimage 和 rollback payload 都以该 post-113 字节为唯一 preimage。

T 内必须新增两个只读 prerequisite input，不是 managed target：

```text
(source_pool_prerequisite_manifest,T/inputs/prerequisites/source-pool-113-prerequisite.json)
(source_pool_prerequisite_approval,T/inputs/prerequisites/source-pool-113-prerequisite-approval.json)
```

对这两项，bootstrap builder 唯一构造：

```text
PrerequisiteItem(file).source_path = T/inputs/prerequisites/<file>
PrerequisiteItem(file).logical_target_path = T/inputs/prerequisites/<file>
PrerequisiteItem(file).preimage_state = present
RoleDomain(source_pool_prerequisite_manifest) = source-pool-113-prerequisite-v1
RoleDomain(source_pool_prerequisite_approval) = json-approval-v1
```

source path 和logical target path在每项内逐字相同，都是上述唯一T-local path；raw SHA-256、canonical domain和canonical SHA-256均非空。canonical JSON hash仍只由domain+payload的framing决定，不把path写入payload。任何一项写absent、用stable target path、交换role/domain或使logical path不等于source path，都返回 `E_REQUIRED_SET` 或 `E_HASH_INPUT_CONTRACT`。

manifest 固定 domain `source-pool-113-prerequisite-v1`，exact key 顺序和类型为：

```text
prerequisite_contract_version(string)
prerequisite_id(id)
source_pool_contract_review_path(safe_project_relative_path)
source_pool_contract_review_raw_sha256(sha256)
source_pool_operations_path(safe_project_relative_path)
source_pool_operations_raw_sha256(sha256)
promotion_id(id)
promotion_record_path(safe_project_relative_path)
promotion_record_raw_sha256(sha256)
promotion_status(enum: succeeded)
formal_manifest_path(safe_project_relative_path)
formal_manifest_raw_sha256(sha256)
formal_manifest_rows(uint)
formal_summary_path(safe_project_relative_path)
formal_summary_raw_sha256(sha256)
collector_path(safe_project_relative_path)
collector_raw_sha256(sha256)
validator_path(safe_project_relative_path)
validator_raw_sha256(sha256)
controlled_ledger_path(safe_project_relative_path)
controlled_ledger_raw_sha256(sha256)
controlled_frozen_manifest_path(safe_project_relative_path)
controlled_frozen_manifest_raw_sha256(sha256)
gate_results(array[gate_result])
prepared_by(string)
prepared_date(date)
reviewed_by(string)
reviewed_date(date)
review_status(enum: reviewed)
notes(string|null)
```

version 固定 `SOURCE-POOL-113-PREREQUISITE-V1`。review path/hash 固定为 `审计/子代理交接/r1_source_pool_113_v4_independent_review.md` / `6980a2d109e6bf17de2ce47829b1c2063dcefe1a1e323413a818992dc02c5b11`；operations path/hash 固定为 `审计/子代理交接/r1_source_pool_113_staging/operations.csv` / `e8bf4895f0d376d355ad0cae507664f9911b23d5ada653ef5626440f07bbc9ea`。promotion record path 必须是 `审计/子代理交接/r1_source_pool_113_staging/promotion-records/<promotion_id>/promotion-record.json`，其 recomputed raw hash 与 manifest所填值相等。promotion record 只作 raw-hash 审计引用，v6 不解析其内部 JSON，也不从中派生 step 或 gate 结果；`promotion_status=succeeded` 是 prerequisite reviewer 在六个 live post hash 和三份受控 transcript 都通过后作出的独立裁决，并由approval绑定。

六个正式 post path/hash 固定为：

```text
清单/论文PDF清单.csv = 4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab, rows=113
清单/汇总统计.json = 994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e
scripts/collect_references.py = 2a980efd45bc9846029003ca38ece6823f75f9d00d6fcbbe0137638e4c2aefcb
scripts/validation/Test-SourcePool.ps1 = c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0
清单/资料池受控输入/source-pool-input-ledger.json = 08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812
清单/资料池受控输入/frozen-legacy-pdf-manifest.csv = c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27
```

`gate_result` exact key为 `gate_seq,gate_id,transcript_path,transcript_raw_sha256,result`；seq 必须恰为1、2、3，id 依次为 `source_pool,chip_scope,research_data_subject_contract`，result全部为`passed`，transcript path安全、hash非空。这三行是实际 gate 的唯一机器闭合来源，按 gate_seq 数值升序、gate_id 唯一；promotion record 可以引用 transcript，但不参与集合派生。prepared_by与reviewed_by不同，reviewed_date不早于prepared_date。

approval 使用9-key `ARTIFACT-APPROVAL-V1`，`artifact_kind=source_pool_113_prerequisite`，artifact ID等于prerequisite ID，artifact hash使用 `source-pool-113-prerequisite-v1`，approved_by不得等于prepared_by或reviewed_by。bootstrap 对两个 prerequisite 重算 canonical hash，并在任何 BaseItem 复制前重算六个 formal post hash、promotion record raw hash、三个transcript和approval。少一项、一门仍 pending、live validator仍是旧hash或 `promotion_status` 不是 `succeeded` 都 fail closed。

`FIX-V6-SOURCE-POOL-PREREQUISITE` 是不读取真实promotion、transcript或transaction hash的synthetic serialization fixture。其path使用 `r.md,o.csv,p.json,m.csv,s.json,c.py,v.ps1,l.json,f.csv,g1.log,g2.log,g3.log`，hash依字段顺序使用小写 `0`至`9`、`a`、`b` 各重复64次，IDs为 `PREREQ-TEST-0001,PROMO-TEST-0001`，日期为2026-08-21，三个gate依次为 `source_pool,chip_scope,research_data_subject_contract`，result全为`passed`，notes为null。positive oracle为：

```text
domain=source-pool-113-prerequisite-v1
payload_bytes=2089
expected_sha256=9244b827d4db311bd4a5d9c3f17c74be853472c0f2d52fdae04b85d130bb492f
expected_canonical_hex=736f757263652d706f6f6c2d3131332d7072657265717569736974652d76310000000000000008297b227072657265717569736974655f636f6e74726163745f76657273696f6e223a22534f555243452d504f4f4c2d3131332d5052455245515549534954452d5631222c227072657265717569736974655f6964223a225052455245512d544553542d30303031222c22736f757263655f706f6f6c5f636f6e74726163745f7265766965775f70617468223a22722e6d64222c22736f757263655f706f6f6c5f636f6e74726163745f7265766965775f7261775f736861323536223a2230303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030222c22736f757263655f706f6f6c5f6f7065726174696f6e735f70617468223a226f2e637376222c22736f757263655f706f6f6c5f6f7065726174696f6e735f7261775f736861323536223a2231313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131222c2270726f6d6f74696f6e5f6964223a2250524f4d4f2d544553542d30303031222c2270726f6d6f74696f6e5f7265636f72645f70617468223a22702e6a736f6e222c2270726f6d6f74696f6e5f7265636f72645f7261775f736861323536223a2232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232222c2270726f6d6f74696f6e5f737461747573223a22737563636565646564222c22666f726d616c5f6d616e69666573745f70617468223a226d2e637376222c22666f726d616c5f6d616e69666573745f7261775f736861323536223a2233333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333222c22666f726d616c5f6d616e69666573745f726f7773223a3131332c22666f726d616c5f73756d6d6172795f70617468223a22732e6a736f6e222c22666f726d616c5f73756d6d6172795f7261775f736861323536223a2234343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434222c22636f6c6c6563746f725f70617468223a22632e7079222c22636f6c6c6563746f725f7261775f736861323536223a2235353535353535353535353535353535353535353535353535353535353535353535353535353535353535353535353535353535353535353535353535353535222c2276616c696461746f725f70617468223a22762e707331222c2276616c696461746f725f7261775f736861323536223a2236363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636222c22636f6e74726f6c6c65645f6c65646765725f70617468223a226c2e6a736f6e222c22636f6e74726f6c6c65645f6c65646765725f7261775f736861323536223a2237373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737373737222c22636f6e74726f6c6c65645f66726f7a656e5f6d616e69666573745f70617468223a22662e637376222c22636f6e74726f6c6c65645f66726f7a656e5f6d616e69666573745f7261775f736861323536223a2238383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838383838222c22676174655f726573756c7473223a5b7b22676174655f736571223a312c22676174655f6964223a22736f757263655f706f6f6c222c227472616e7363726970745f70617468223a2267312e6c6f67222c227472616e7363726970745f7261775f736861323536223a2239393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939222c22726573756c74223a22706173736564227d2c7b22676174655f736571223a322c22676174655f6964223a22636869705f73636f7065222c227472616e7363726970745f70617468223a2267322e6c6f67222c227472616e7363726970745f7261775f736861323536223a2261616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161222c22726573756c74223a22706173736564227d2c7b22676174655f736571223a332c22676174655f6964223a2272657365617263685f646174615f7375626a6563745f636f6e7472616374222c227472616e7363726970745f70617468223a2267332e6c6f67222c227472616e7363726970745f7261775f736861323536223a2262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262222c22726573756c74223a22706173736564227d5d2c2270726570617265645f6279223a22617574686f722d61222c2270726570617265645f64617465223a22323032362d30382d3231222c2272657669657765645f6279223a2272657669657765722d62222c2272657669657765645f64617465223a22323032362d30382d3231222c227265766965775f737461747573223a227265766965776564222c226e6f746573223a6e756c6c7d
```

negative fixture固定覆盖 wrong domain、顶层或gate unknown key、key乱序、gate seq非1/2/3或不连续、result非passed、unsafe/empty transcript path、非64位小写hex hash和三gate遗漏/重复，错误码依次取 `E_HASH_FRAME,E_JSON_KEY,E_JSON_ORDER,E_GATE_RESULT,E_PATH,E_SHA256,E_REQUIRED_SET`。approval不新定oracle，继续复用已冻结的 `ARTIFACT-APPROVAL-V1`。

## immutable complete formal image 与 96 个 file input

### changed snapshot 和 unchanged snapshot

v5 的20个 base snapshot角色/路径集合保持不变：九张受影响正式表，加活动名单、四个 validator/恢复脚本和六个模板/项目文档。22个普通 post snapshot也保持不变：11张 post formal table（九张更新表加两张新 factor table）和11个 present→present raw payload。其中 `Test-SourcePool.ps1` 的 base bytes 不沿用当前旧值，必须是前节 post-113 hash；这是同一 role/path 的正确 preimage，不是第21个 managed base snapshot。

v6 新增 role `managed_unchanged_snapshot`。下列23张当前正式表各自只生成一个 `UnchangedItem(p)`，同一份原字节同时充当该表的 base和post；不复制成两项：

```text
数据/components.csv
数据/condition-sets.csv
数据/derived-inputs.csv
数据/derived-metrics.csv
数据/facts.csv
数据/field-requirements.csv
数据/links.csv
数据/memory-levels.csv
数据/object-relations.csv
数据/precision-paths.csv
数据/special-capabilities.csv
数据/topologies.csv
数据/vendors.csv
最小参考资料库/conflict-groups.csv
最小参考资料库/conflict-members.csv
最小参考资料库/selection-members.csv
最小参考资料库/selection-runs.csv
最小参考资料库/source-coverage.csv
最小参考资料库/source-endpoints.csv
最小参考资料库/source-families.csv
最小参考资料库/sources.csv
最小参考资料库/source-screening.csv
最小参考资料库/source-selected-roles.csv
```

complete immutable base formal image只能这样构造：

```text
BaseFormalImageV6 = 9 changed BaseItem + 23 UnchangedItem = 32 tables
PostFormalImageV6 = 11 changed/new PostItem + 23 UnchangedItem = 34 tables
```

operation builder固定读取 `BaseFormalImageV6`、freeze archive和已批准 candidate policy，不读取 `CurrentFormalBase`、live root或上一 phase的 postimage。fresh、resume、applied no-op和rollback前复核都必须重建相同 operation universe与相同 operation hash。

23张 unchanged table不进入 table image，因为 table image是写授权和 rollback target；本事务既没有这些表的 row operation，也不允许写它们。因此 table image仍恰为11，而不是34。每次 validate、mirror build、写入第一个 target前、完整 postimage gate和rollback完成后，都必须同时比较 live raw hash、live canonical rowset hash、UnchangedItem raw hash和UnchangedItem canonical hash。四者逐表相等才继续；任一表在 freeze后漂移返回 `E_UNCHANGED_DRIFT`，不把 live新值吸入 mirror。transaction manifest绑定23个 snapshot及其集合 hash，因而这不是未受约束的 live读取。

### bootstrap 三个 item set

v6 bootstrap 的精确计数为：

```text
base_snapshot_items = 20 base + 23 unchanged + 2 prerequisite = 45
postimage_candidate_items = 22 changed post + 23 unchanged + 13 candidate = 58
patch_items = 12
```

同一 UnchangedItem按 item identity分别参与 base/post集合投影，但在 manifest JSON中只在两个 array各出现一次；file-input表只登记一次。base与post array中对应 unchanged item的七个 key必须逐字相同。两个 prerequisite 只在 base array出现，不是 formal table，也不进入 post array、operation、table image、payload或 rollback。

contract migration 的 `(input_role,relative_path)` 全集是：

```text
1 contract_design(v6)
+ 1 raw-only scope_freeze_archive
+ 2 bootstrap manifest/approval
+ 13 stable candidate sources
+ 20 managed_base_snapshot
+ 22 managed_postimage_snapshot
+ 23 managed_unchanged_snapshot
+ 12 managed_patch
+ 2 source_pool prerequisite manifest/approval
= 96
```

CSV 必须与独立 builder双向 set-equal，每个 pair恰一行且 `is_required=true`。v5 的71只描述未纳入 unchanged image的旧集合，从v6起不得再用于 contract migration。

## bootstrap-bundle-manifest.json exact contract

固定路径为 `T/inputs/bootstrap/bootstrap-bundle-manifest.json`，domain固定 `contract-bootstrap-manifest-v2`。顶层 key顺序和类型如下：

```text
bootstrap_contract_version(string)
bootstrap_bundle_id(id)
transaction_id(id)
transaction_kind(string)
base_snapshot_items(array[item])
postimage_candidate_items(array[item])
patch_items(array[item])
prepared_by(string)
prepared_date(date)
reviewed_by(string)
reviewed_date(date)
review_status(string)
notes(string|null)
```

version固定 `CONTRACT-BOOTSTRAP-V2`，kind固定 `contract_migration`，status固定 `reviewed`；prepared_by与reviewed_by不同，reviewed_date不早于prepared_date。三个 array item的 exact key顺序和类型为：

```text
input_role(string)
source_path(safe_project_relative_path)
logical_target_path(safe_project_relative_path)
preimage_state(enum: present|absent)
raw_sha256(sha256)
canonical_domain_tag(string|null)
canonical_sha256(sha256|null)
```

item按 `(input_role,source_path,logical_target_path)` UTF-8 bytes tuple排序并在三数组合后保持 `(role,path)` 唯一。raw-only item的两个 canonical key必须同为null；controlled CSV与canonical JSON必须同为非空。role-to-domain由本合同和继承合同唯一确定，manifest内自报值不能改写它。

`bootstrap-bundle-approval.json` 继续使用9-key `ARTIFACT-APPROVAL-V1`，`artifact_kind=contract_bootstrap_bundle`，`artifact_id`必须等于 manifest.bootstrap_bundle_id，artifact hash使用 `contract-bootstrap-manifest-v2`。approved_by不得等于prepared_by或reviewed_by，approved_date不得早于reviewed_date。approval只绑定已完成manifest；manifest不含approval hash。

`FIX-V6-BOOTSTRAP-MANIFEST` 的 payload是一个仅用于 serialization的 synthetic bundle；它不读取本次真实 transaction hash。positive oracle为：

```text
domain=contract-bootstrap-manifest-v2
payload_bytes=750
expected_sha256=b8f1c8bc65f580091e2031833e30fbd77c141c957280e3ce9ed0bcda84e6283e
expected_canonical_hex=636f6e74726163742d626f6f7473747261702d6d616e69666573742d76320000000000000002ee7b22626f6f7473747261705f636f6e74726163745f76657273696f6e223a22434f4e54524143542d424f4f5453545241502d5632222c22626f6f7473747261705f62756e646c655f6964223a22424f4f5453545241502d544553542d30303031222c227472616e73616374696f6e5f6964223a2254582d544553542d30303031222c227472616e73616374696f6e5f6b696e64223a22636f6e74726163745f6d6967726174696f6e222c22626173655f736e617073686f745f6974656d73223a5b7b22696e7075745f726f6c65223a226d616e616765645f626173655f736e617073686f74222c22736f757263655f70617468223a22e5aea1e8aea12fe4ba8be58aa12f54582d544553542d303030312f696e707574732f626173652f782e637376222c226c6f676963616c5f7461726765745f70617468223a22782e637376222c22707265696d6167655f7374617465223a2270726573656e74222c227261775f736861323536223a2230303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030222c2263616e6f6e6963616c5f646f6d61696e5f746167223a22726f777365742d7631222c2263616e6f6e6963616c5f736861323536223a2231313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131227d5d2c22706f7374696d6167655f63616e6469646174655f6974656d73223a5b5d2c2270617463685f6974656d73223a5b5d2c2270726570617265645f6279223a22617574686f722d61222c2270726570617265645f64617465223a22323032362d30382d3231222c2272657669657765645f6279223a2272657669657765722d62222c2272657669657765645f64617465223a22323032362d30382d3231222c227265766965775f737461747573223a227265766965776564222c226e6f746573223a6e756c6c7d
```

negative fixture固定覆盖 wrong domain、顶层或item未知key、key乱序、raw-only填canonical、controlled item留canonical为空、bundle ID与approval artifact ID不等、approval date早于reviewed date，错误码分别为 `E_HASH_FRAME,E_JSON_KEY,E_JSON_ORDER,E_CANONICAL_NULL,E_APPROVAL_BINDING,E_DATE`。

## formula-evaluator-v1.json exact contract

固定 stable path为 `审计/合同注册表/formula-evaluator-v1.json`，domain固定 `formula-evaluator-spec-v1`。顶层 exact key与类型为：

```text
formula_evaluator_contract_version(string)
formula_set_id(id)
numeric_model(string)
unknown_formula_action(string)
formulas(array[formula])
prepared_by(string)
prepared_date(date)
reviewed_by(string)
reviewed_date(date)
review_status(string)
notes(string|null)
```

version固定 `FORMULA-EVALUATOR-V1`，numeric model固定 `decimal-rational-v1`，unknown action固定 `fail_closed_E_UNKNOWN_FORMULA`，review status固定reviewed。formula按formula_id UTF-8 bytes排序且ID唯一。每项 exact key为：

```text
formula_id(string)
operation(enum: divide|multiply|multiply_by_constant|emit_constant_text)
arity(uint>0)
input_contracts(array[input])
output_value_kind(enum: number|text)
output_unit(string|null)
constant_decimal(canonical_decimal_string|null)
constant_text(string|null)
decimal_places(uint|null)
rounding_mode(enum: exact|round_half_up|none)
required_output_field_id(string)
review_status(string)
notes(string|null)
```

input按input_order数值升序且从1连续到arity，每项 exact key为：

```text
input_order(uint>0)
input_role(string)
allowed_field_ids(array[string])
unit_options(array[unit_option])
required_decimal(canonical_decimal_string|null)
```

allowed field按UTF-8 bytes排序且非空；unit option按unit bytes排序且非空，每项key为 `unit(string),scale_to_base_decimal(canonical_decimal_string)`。decimal string语法固定 `0|-?[1-9][0-9]*(?:\.[0-9]+)?|0\.[0-9]+`，禁止指数、正号和负零。

decimal evaluator使用任意精度十进制有理数，不使用binary float。先应用unit scale，再按operation计算；除零、unit不匹配、input field不匹配、required decimal不相等、非连续arity都fail closed。`round_half_up`要求decimal_places非空，输出保留恰好该位数；`exact`要求decimal_places为空且结果可精确表示；`none`只允许text output。number output要求output_unit非空且两个constant key中至多constant_decimal非空；text output要求output_unit、constant_decimal、decimal_places均null，operation为emit_constant_text且constant_text非空。

v1 formula集合必须与当前正式5个ID加GA100预登记3个ID set-equal：

| formula_id | operation / arity | input contract | output | constant / rounding |
|---|---|---|---|---|
| `FORMULA-COMPUTE-DIV-MEMBW` | divide / 2 | 1 numerator `FIELD-COMP-THROUGHPUT`, `TFLOP/s×1000000000000`; 2 denominator `FIELD-MEM-READ-BW`, `byte/s×1` | number `FIELD-DER-COMPUTE-BW-SPEC`, `FLOP/byte` | null; 2 places half-up |
| `FORMULA-AWS-TRN2-COMPUTE-DIV-HBM-BW` | divide / 2 | 1 numerator `FIELD-COMP-THROUGHPUT`, `FLOP/s×1`; 2 denominator `FIELD-MEM-BIDIR-BW`, `byte/s×1` | number `FIELD-DER-COMPUTE-BW-SPEC`, `FLOP/byte` | null; 1 place half-up |
| `FORMULA-AWS-TRN2-CORE-X8` | multiply / 2 | 1 numerator `FIELD-COMP-THROUGHPUT`, `FLOP/s×1`; 2 scale `FIELD-COMP-UNIT-COUNT`, `count×1`, required `8` | number `FIELD-COMP-THROUGHPUT`, `FLOP/s` | null; exact |
| `FORMULA-MATRIX-DIV-VECTOR` | divide / 2 | numerator、denominator均为 `FIELD-COMP-THROUGHPUT`, `FLOP/cycle/CU×1` | number `FIELD-DER-MATRIX-VECTOR`, `ratio` | null; exact |
| `FORMULA-STRUCTURAL-PROJECTION` | emit_constant_text / 1 | other `FIELD-MEM-CAPACITY`, `byte×1` | text `FIELD-MEM-POOLING-MODE`, null unit | text=`distributed_not_pooled`; none |
| `FORMULA-GA100-HBM-CONTROLLER-COUNT-X512` | multiply_by_constant / 1 | controller_count `FIELD-COMP-UNIT-COUNT`, `count×1`, required `12` | number `FIELD-PHY-HBM-INTERFACE`, `bit` | decimal=`512`; exact |
| `FORMULA-GA100-NVLINK-COUNT-X25GBPS` | multiply_by_constant / 1 | physical_link_count `FIELD-INT-PHYSICAL-LINK-COUNT`, `count×1`, required `12` | number `FIELD-INT-INJECTION-BW`, `byte/s` | decimal=`25000000000`; exact |
| `FORMULA-GA100-BIDIRECTIONAL-X2` | multiply_by_constant / 1 | one_direction_bandwidth `FIELD-INT-INJECTION-BW`, `byte/s×1`, required null | number `FIELD-INT-AGGREGATE-BW`, `byte/s` | decimal=`2`; exact |

GA100 的512 bit/controller、25 GB/s/方向/link和双向系数2必须同时进入 formula expression、derived input或formula constant以及实际 source locator/evidence closure；formula registry approval不替代来源证据。以后出现新 formula ID必须发布新受批准 formula spec，不能靠formula_expression自由文本执行。

`FIX-V6-FORMULA-SPEC` positive oracle为：

```text
domain=formula-evaluator-spec-v1
payload_bytes=835
expected_sha256=122f80043c705bfc3f34ea662298cdde4e7f283f3952079375dd5b4edb9cac76
expected_canonical_hex=666f726d756c612d6576616c7561746f722d737065632d76310000000000000003437b22666f726d756c615f6576616c7561746f725f636f6e74726163745f76657273696f6e223a22464f524d554c412d4556414c5541544f522d5631222c22666f726d756c615f7365745f6964223a22464f524d554c412d5345542d544553542d30303031222c226e756d657269635f6d6f64656c223a22646563696d616c2d726174696f6e616c2d7631222c22756e6b6e6f776e5f666f726d756c615f616374696f6e223a226661696c5f636c6f7365645f455f554e4b4e4f574e5f464f524d554c41222c22666f726d756c6173223a5b7b22666f726d756c615f6964223a22464f524d554c412d544553542d5832222c226f7065726174696f6e223a226d756c7469706c795f62795f636f6e7374616e74222c226172697479223a312c22696e7075745f636f6e747261637473223a5b7b22696e7075745f6f72646572223a312c22696e7075745f726f6c65223a2276616c7565222c22616c6c6f7765645f6669656c645f696473223a5b224649454c442d41225d2c22756e69745f6f7074696f6e73223a5b7b22756e6974223a22627974652f73222c227363616c655f746f5f626173655f646563696d616c223a2231227d5d2c2272657175697265645f646563696d616c223a6e756c6c7d5d2c226f75747075745f76616c75655f6b696e64223a226e756d626572222c226f75747075745f756e6974223a22627974652f73222c22636f6e7374616e745f646563696d616c223a2232222c22636f6e7374616e745f74657874223a6e756c6c2c22646563696d616c5f706c61636573223a6e756c6c2c22726f756e64696e675f6d6f6465223a226578616374222c2272657175697265645f6f75747075745f6669656c645f6964223a224649454c442d42222c227265766965775f737461747573223a227265766965776564222c226e6f746573223a6e756c6c7d5d2c2270726570617265645f6279223a22617574686f722d61222c2270726570617265645f64617465223a22323032362d30382d3231222c2272657669657765645f6279223a2272657669657765722d62222c2272657669657765645f64617465223a22323032362d30382d3231222c227265766965775f737461747573223a227265766965776564222c226e6f746573223a6e756c6c7d
```

negative fixture必须包含未登记formula ID并返回 `E_UNKNOWN_FORMULA`，另含错operation、错arity、错unit、错constant、division by zero、wrong domain、unknown key和key乱序。

## MANAGED-PATCH-V1 exact contract

12个 patch都使用domain `managed-patch-v1`。exact key顺序与类型为：

```text
patch_contract_version(string)
patch_id(id)
transaction_id(id)
target_path(safe_project_relative_path)
target_kind(enum: raw_only|canonical_json|controlled_csv)
operation_kind(enum: create|update|delete)
preimage_state(enum: present|absent)
preimage_raw_sha256(sha256|null)
postimage_state(enum: present|absent)
postimage_raw_sha256(sha256|null)
base_snapshot_source_path(safe_project_relative_path|null)
postimage_source_path(safe_project_relative_path|null)
prepared_by(string)
prepared_date(date)
reviewed_by(string)
reviewed_date(date)
review_status(string)
notes(string|null)
```

version固定 `MANAGED-PATCH-V1`，status固定reviewed，prepared/review独立。状态矩阵固定为：update=`present→present`且两个hash、两个snapshot path都非空；create=`absent→present`且pre hash/base path为空、post hash/path非空；delete=`present→absent`且pre hash/base path非空、post hash/path为空。12个patch只允许11个update和formula evaluator的1个create，不允许delete。

patch投影 `(target_path,target_kind,operation_kind,preimage_state,preimage_raw_sha256,postimage_state,postimage_raw_sha256)` 必须与对应12个payload target逐项双向 set-equal；base/post source path分别解析到同一logical target的approved snapshot或formula candidate。patch不能替代完整postimage source。

`FIX-V6-MANAGED-PATCH` positive oracle为：

```text
domain=managed-patch-v1
payload_bytes=709
expected_sha256=1d7bcce0fc415fa8175ecdb5f0eb839e421f329f2a360ab4822a3f786beaf733
expected_canonical_hex=6d616e616765642d70617463682d76310000000000000002c57b2270617463685f636f6e74726163745f76657273696f6e223a224d414e414745442d50415443482d5631222c2270617463685f6964223a2250415443482d544553542d30303031222c227472616e73616374696f6e5f6964223a2254582d544553542d30303031222c227461726765745f70617468223a22e5aea1e8aea12fe59088e5908ce6b3a8e5868ce8a1a82f666f726d756c612d6576616c7561746f722d76312e6a736f6e222c227461726765745f6b696e64223a2263616e6f6e6963616c5f6a736f6e222c226f7065726174696f6e5f6b696e64223a22637265617465222c22707265696d6167655f7374617465223a22616273656e74222c22707265696d6167655f7261775f736861323536223a6e756c6c2c22706f7374696d6167655f7374617465223a2270726573656e74222c22706f7374696d6167655f7261775f736861323536223a2231313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131222c22626173655f736e617073686f745f736f757263655f70617468223a6e756c6c2c22706f7374696d6167655f736f757263655f70617468223a22e5aea1e8aea12fe4ba8be58aa12f54582d544553542d303030312f696e707574732f626f6f7473747261702f746172676574732fe5aea1e8aea12fe59088e5908ce6b3a8e5868ce8a1a82f666f726d756c612d6576616c7561746f722d76312e6a736f6e222c2270726570617265645f6279223a22617574686f722d61222c2270726570617265645f64617465223a22323032362d30382d3231222c2272657669657765645f6279223a2272657669657765722d62222c2272657669657765645f64617465223a22323032362d30382d3231222c227265766965775f737461747573223a227265766965776564222c226e6f746573223a6e756c6c7d
```

negative fixture覆盖unknown key、key乱序、wrong domain、create填preimage、update缺base、target与payload不等、hash错位和重复target。

## chip operation/payload 独立授权

### 35个固定 base pair与37个实际 required input

chip package 的固定 base pair是35项，不是36项。它由v4共享27项、stable formula evaluator 1项和当前T coverage 7项组成：

```text
(contract_design,审计/子代理交接/r1_ga100_36_contract_repair_design_v6.md)
(coverage_policy,审计/合同注册表/coverage-policy-v5.0.json)
(coverage_policy_approval,审计/合同注册表/coverage-policy-v5.0-approval.json)
(source_date_policy,审计/合同注册表/source-date-policy-v3.0.csv)
(source_date_policy_approval,审计/合同注册表/source-date-policy-approval.json)
(legacy_requirement_registry,审计/合同注册表/legacy-requirement-disposition.csv)
(legacy_requirement_registry_approval,审计/合同注册表/legacy-requirement-disposition-approval.json)
(legacy_reconciliation_registry,审计/合同注册表/legacy-requirement-reconciliation-events.csv)
(active_scope_list,清单/训练与推理芯片名单.md)
(scope_allocation_registry,审计/合同注册表/scope-id-registry.csv)
(scope_mapping_registry,审计/合同注册表/scope-object-mapping.csv)
(schema_registry,数据/schema-columns.csv)
(enum_registry,数据/enums.csv)
(field_registry,数据/fields.csv)
(data_validator,scripts/validation/Validate-ResearchData.ps1)
(scope_validator,scripts/validation/Test-ChipScope.ps1)
(source_pool_validator,scripts/validation/Test-SourcePool.ps1)
(recovery_validator,scripts/validation/verify_recovery_paths.py)
(card_template,资料卡/模板.md)
(field_dictionary,资料卡/字段字典.md)
(project_readme,README.md)
(project_agents,AGENTS.md)
(research_plan,研究计划.md)
(current_status,进度/当前状态.md)
(canonical_fixture_manifest,审计/合同注册表/canonical-fixture-manifest.json)
(canonical_fixtures,审计/合同注册表/canonical-fixtures.csv)
(canonical_runtime_results,审计/合同注册表/canonical-runtime-results.csv)
(formula_evaluator_spec,审计/合同注册表/formula-evaluator-v1.json)
(coverage_manifest,T/coverage/coverage-manifest.json)
(coverage_approval,T/coverage/independent-approval.json)
(coverage_targets,T/coverage/coverage-targets.csv)
(factor_target_candidates,T/coverage/factor-target-candidates.csv)
(reachable_target_bindings,T/coverage/reachable-target-bindings.csv)
(coverage_fields,T/coverage/coverage-fields.csv)
(coverage_exclusion_reviews,T/coverage/coverage-exclusion-review.csv)
```

v6 再加入两个 authorization input：

```text
(chip_operation_authorization,T/authorization/chip-operation-payload-authorization.json)
(chip_operation_authorization_approval,T/authorization/chip-operation-payload-authorization-approval.json)
```

因此 `BaseChipRolePathSet` 恰为35，实际 chip transaction required/allowed file-input set恰为37。36只是v4旧 `input_role` enum token数，不能当pair计数。v6 role enum在v5的41个token上增加 `managed_unchanged_snapshot,chip_operation_authorization,chip_operation_authorization_approval,source_pool_prerequisite_manifest,source_pool_prerequisite_approval`，共46个token。两个source-pool角色只属contract migration bootstrap，不进入chip的35个base pair；chip从已applied contract state读取已受事务manifest绑定的前置结果。

### authorization exact schema与批准

authorization固定domain `chip-operation-payload-authorization-v1`。顶层exact key为：

```text
authorization_contract_version(string)
authorization_id(id)
transaction_id(id)
work_package_id(id)
scope_id(scope_id)
card_object_id(string)
table_operation_items(array[operation_item])
payload_items(array[payload_item])
prepared_by(string)
prepared_date(date)
reviewed_by(string)
reviewed_date(date)
review_status(string)
notes(string|null)
```

version固定 `CHIP-OPERATION-AUTHORIZATION-V1`，review status固定reviewed；transaction/work-package/scope/card必须与coverage manifest和transaction manifest逐字一致。

`operation_item` exact key镜像 operations.csv 的完整13列，但省略顶层已绑定的transaction ID：

```text
operation_id,operation_seq,table_path,operation_kind,pk_canonical_json,
input_payload_path,input_payload_raw_sha256,expected_preimage_state,
expected_preimage_canonical_row_sha256,expected_postimage_state,
expected_postimage_canonical_row_sha256,rollback_payload_path,
rollback_payload_raw_sha256
```

类型、nullable、insert/update/delete矩阵继承v3；按operation_seq数值升序且连续，`(table_path,pk_canonical_json)`唯一。chip operation的table pre/post state只允许present row update/delete或absent row insert；table file本身始终present→present。

`payload_item` exact key是payload inventory v2的20列中省略顶层已绑定 `transaction_id` 后的19列：

```text
payload_id,payload_operation_kind,payload_kind,source_path,target_path,
target_canonical_domain_tag,input_payload_domain_tag,preimage_state,
preimage_raw_sha256,preimage_canonical_sha256,input_raw_sha256,
input_canonical_sha256,postimage_state,expected_postimage_raw_sha256,
expected_postimage_canonical_sha256,rollback_action,rollback_payload_path,
rollback_payload_raw_sha256,notes
```

类型、domain与nullable矩阵继承v4；按target_path bytes排序，target唯一。authorization至少有一个operation或payload，两个array不能同时空。

approval使用9-key `ARTIFACT-APPROVAL-V1`，`artifact_kind=chip_operation_payload_authorization`，artifact_id等于authorization_id，artifact hash使用上述domain；approver与preparer/reviewer均不同，date不早于reviewed date。

transaction manifest v6在`prepared_by`前增加四个nullable key：

```text
chip_authorization_id
chip_authorization_canonical_sha256
chip_authorization_approval_id
chip_authorization_approval_canonical_sha256
```

contract migration四键必须为null；chip transaction四键必须非空，并与authorization、approval和file-input row的recomputed hash逐字相等。

### 双向 allowed-set门与固定live输入禁写

```text
Project13(actual_operations) == authorization.table_operation_items
Distinct(actual_images.table_path)
    == Distinct(authorization.table_operation_items.table_path)
Project19(actual_payloads) == authorization.payload_items
Set(actual_rollback.target_path)
    == Distinct(authorized operation table_path)
       union Set(authorized payload target_path)
```

四个等式都是双向set-equal并要求logical key exactly one。extra、omission、role swap、action swap、source path替换、hash替换、漏image、伪image或漏rollback都失败。

v6 选择默认禁止修改固定live input，不提供replacement公式。35个base pair中位于T外的28个stable/live path必须与operations.table_path和payloads.target_path都disjoint。若后续确需修改其中任一项，必须发布新合同版本；当前chip package不能自行删除live input再换snapshot。这一禁令不影响对 `facts.csv`、`field-requirements.csv`、factor table和其他未列入固定live input的正式表执行已批准operation。

fixture至少覆盖：合法37项；误报36；遗漏authorization；extra Markdown target；payload遗漏；operation多一行；错role/action/source；把active scope或validator当payload；authorization approval hash错。统一返回 `E_REQUIRED_SET,E_AUTHORIZATION_SET,E_IMMUTABLE_LIVE_INPUT` 中对应错误。

## contract table/payload universe与状态机

contract migration的table image继续与以下11项set-equal：九张更新表加`数据/factor-requirements.csv`和`数据/factor-target-bindings.csv`。前九项present→present/restore，后两项absent→present/delete_created。payload继续为11个present→present raw target加13个absent→present stable target，共24项。managed target仍为35，table和payload path仍互斥。

chip package先验证34-table applied contract base。它的image path等于approved operation table path的distinct集合，每项只能present→present/restore。两张factor table的absent→present gate只在contract migration分支；chip有factor operation才生成对应present→present image，无operation不得伪造image。

### immutable builder伪代码

```text
BuildContractInputsV6(T):
    freeze = LoadRawOnlyFreezeArchiveExactBytes()
    source_pool_prerequisites =
        LoadAndApprovePost113PrerequisiteBeforeAnyBaseCopy()
    base9 = LoadNineBaseTableItemsUsingSemanticPath()
    unchanged23 = LoadTwentyThreeUnchangedItemsUsingSemanticPath()
    base_payload11 = LoadElevenBasePayloadItems()
    Require(base_payload11[Test-SourcePool].raw_sha256 == c2dc...fbf0)
    post11 = LoadElevenPostTableItemsUsingSemanticPath()
    post_payload11 = LoadElevenPostPayloadItems()
    candidates13 = LoadThirteenStableCandidatesUsingSemanticPath()
    patches12 = LoadTwelveManagedPatches()
    Require(Counts == (45,58,12,96))
    return freeze, source_pool_prerequisites,
           base9+unchanged23, base_payload11,
           post11+unchanged23, post_payload11, candidates13, patches12

BuildContractMigrationOperationSetV6(T):
    inputs = BuildContractInputsV6(T)
    base = StrictFormalImage(inputs.base_tables, expected_tables=32)
    Require(NoReadFromLiveRootByOperationBuilder())
    operations = BuildFrozenMigrationDelta(base, inputs.freeze, inputs.candidates)
    mirror = ApplyOperationsToImmutableBase(base, operations)
    Require(mirror.tables == inputs.post_tables)
    Require(Counts(mirror) == (34,376,141,77,564))
    return operations, mirror
```

### validate、fresh、mixed、no-op与rollback

```text
ValidateTransactionV6(root,T):
    RecomputeAllImmutableTInputsWithSemanticPath()
    ValidateSourcePool113PrerequisiteEvidence()
    ValidateBootstrapV2AndApproval()
    Require(contract file-input set == 96 if contract_migration)
    Require(chip file-input set == 35 base + 2 authorization if chip)
    ValidateFreezeRawOnlyExactBytesIfContract()
    ValidateUnchanged23AgainstSnapshotAtDeclaredReadPointsIfContract()
    operations, expected_mirror =
        BuildContractMigrationOperationSetV6(T) if contract
        else BuildChipOperationSetFromApprovedAuthorization(T)
    ValidateImagesPayloadsRollbackAndAuthorizationSetEqual()
    ValidateScopeConstructorsAnd49SemanticProjectionsIfContract()
    ValidateFormulaPatchAndAllCanonicalOracles()
    ValidateHashDagAcyclic()
    RecomputeEveryManifestHash()
```

```text
ResumeOrApplyV6(root,T):
    ValidateTransactionV6(root,T)
    observed = ObserveManagedStateV2(root,targets)
    ValidateFiveNonmanagedPost113PathsStillEqualPrerequisite()

    if observed == postimage and JournalHas(applied,succeeded,same_manifest):
        ValidateUnchanged23LiveEqualsSnapshot()
        RunCompletePostimageGatesWithoutRewrite()
        return SUCCESS_NOOP

    if JournalLatestIs(applying,started,same_manifest):
        Require(EachTargetIsOwnPreimageOrPostimage(observed))
        ValidateUnchanged23LiveEqualsSnapshot()
        RollForwardOnlyPreimageTargetsFromImmutableTInPathOrder()
        RunCompletePostimageGates()
        AppendJournal(applied,succeeded)
        return SUCCESS_RESUMED

    Require(observed == complete_preimage)
    Require(JournalAllowsFreshOrPostRollbackApply())
    ValidateUnchanged23LiveEqualsSnapshot()
    mirror = BuildIsolatedPostimageOnlyFromImmutableT()
    RunAllGates(mirror)
    AppendJournal(applying,started)
    ValidateUnchanged23LiveEqualsSnapshot()
    ReplaceManagedTargetsInPathOrder(mirror)
    RunCompletePostimageGates()
    AppendJournal(applied,succeeded)
    return SUCCESS_APPLIED
```

```text
RollbackV6(root,T):
    ValidateTransactionV6(root,T)
    observed = ObserveManagedStateV2(root,targets)
    ValidateFiveNonmanagedPost113PathsStillEqualPrerequisite()
    if observed == complete_preimage and JournalHas(rolled_back,succeeded,same_manifest):
        ValidateUnchanged23LiveEqualsSnapshot()
        return ROLLBACK_NOOP
    if JournalLatestIs(rollback_applying,started,same_manifest):
        Require(EachTargetIsOwnPostimageOrPreimage(observed))
    else:
        Require(observed == complete_postimage)
        Require(JournalHas(applied,succeeded,same_manifest))
        AppendJournal(rollback_applying,started)
    ValidateUnchanged23LiveEqualsSnapshot()
    RestoreOrDeleteCreatedInPathOrderFromImmutableT()
    Require(ObserveManagedStateV2(root,targets) == complete_preimage)
    Require(All15CreatedTargetsAbsentIfContract())
    ValidateUnchanged23LiveEqualsSnapshot()
    AppendJournal(rolled_back,succeeded)
    return SUCCESS_ROLLED_BACK
```

无 applying event的mixed state、不同manifest、unknown hash、partial registry rowset和unchanged漂移都保留现场并失败。apply mixed必须先roll-forward，不能直接rollback。

## hash DAG、稳定 artifact与继承硬门

13个stable artifact仍是v5列出的完整集合：coverage policy及approval、source-date policy及approval、legacy disposition及approval、legacy reconciliation registry、scope allocation、scope mapping、formula evaluator、fixture manifest、fixtures和runtime results。每项都是candidate source到stable target的absent→present/delete-created；不得漏项或预创建。

hash DAG的唯一拓扑层为：

```text
L0 frozen designs/raw freeze/base/post/unchanged bytes, post-113 promotion evidence and synthetic fixture inputs
L1 source-pool prerequisite manifest, candidate policy/date/legacy/scope/formula/fixture bytes and managed patches
L2 source-pool prerequisite approval, other artifact approvals and canonical runtime results
L3 canonical fixture manifest
L4 bootstrap bundle manifest
L5 bootstrap bundle approval
L6 chip authorization, when transaction_kind=chip_work_package
L7 chip authorization approval, when present
L8 operations/images/payload/file-input/rollback inventories
L9 rollback manifest and coverage manifest
L10 coverage approval
L11 transaction manifest
L12 transaction approval
L13 append-only journal events
```

L3 fixture manifest只绑定独立synthetic fixture和三运行时结果，不读取真实bootstrap、authorization、rollback或transaction hash。candidate artifact不得引用L4以后节点；bootstrap manifest不引用自身approval；rollback manifest不引用transaction manifest；transaction manifest不引用transaction approval；journal最后生成。validator从实际hash-reference edge做拓扑排序，节点数与输出数不同即 `E_HASH_CYCLE`。

以下继承门不得退步：

- actual qualifying `sources.csv` row先按source_id去重，再按family要求source_type和source_authority各自singleton；歧义返回 `E_SOURCE_FAMILY_DIMENSION_AMBIGUITY`。
- 六个 mandatory structural N/A exact object、四个predicate object、actual endpoint、canonical locator和独立proof evidence保持v5逐项set-equal；其余102格禁止N/A，108个candidate仍全部include。
- `FIELD-PHY-DIE-COUNT` 的新 normal N/A 是第五个 structural predicate object，但不加入上一条的六个 mandatory N/A 四键；die/package 分支和 proof 必须按本稿独立复算。
- expected-pair builder 对六个 GA100 benchmark 对和三个 Ampere architecture 对生成恰好九个强制 include 裁决；它们必须进入58-key coverage manifest的 expected pair/hash/closure 重算，不得用手写25行或 distinct field ID 数代替。
- release-date gate 中的5 fact + 6 requirement 必须与 unchanged formal image双向 set-equal；本事务不准发布新字段名或新定义，GA100 该 requirement 保持 pending。
- 141-field、factor obligation、factor target和binding全集门，normal selector、zero-included factor、AFPV2、reconciliation、derived recursive closure、cutoff、reverse-removal、13-domain completeness和latency mapping继续执行。
- factor table的create只允许contract migration；chip只能在applied 34-table base上做present→present image。
- 活动名单、allocation、mapping和13个stable target仍共享同一35-target managed-state，不存在事务外合法切换点。

## v6 fixture矩阵

v3、v4、v5 mandatory fixture全部保留。v6追加的fixture family必须各有 `powershell_5_1,powershell_7,python_3` 三行独立runtime result；positive的framed hex/hash逐字相同，negative的error code逐字相同。

| family | positive | negative |
|---|---|---|
| semantic path | 同bytes、不同physical path、同logical target得到同hash；base/post与image逐项相等 | envelope写T path、logical target错、stable copy改语义path |
| freeze raw-only | 当前55224 bytes、BOM、24列、77/49行通过 | hash漂移、去BOM、统一换行、换header、bool大写、canonical列非空 |
| scope constructor | 49六元组双射，四constructor逐字，9/1/1/38分布 | 裸group、尖括号URL、trim、name join、GH100/GA100 proposed ID错、pending reviewed |
| complete immutable image | 9+23得到32 base，11+23得到34 post，各phase operation hash相同 | 从live/post phase重建operation、漏unchanged、snapshot后live漂移 |
| source-pool prerequisite | 113推广12步成功、三门PASS、六个post hash精确，Test-SourcePool base为c2dc...fbf0 | 用当前447560...736f冻结、推广pending/回滚、少transcript、并行两事务 |
| bootstrap v2 | 45/58/12和96 file input，positive oracle匹配 | 仍报71/94、unchanged重复成46 file input、漏两个prerequisite、wrong domain/key/type/order |
| formula evaluator | 当前5+GA100 3精确set，4类operation可复算 | unknown formula、错arity/unit/constant/rounding、division zero |
| managed patch | 11 update+1 create与payload逐项双向相等 | 漏patch、extra target、create填base、update缺post、wrong domain |
| chip authorization | 35 base+2 auth，operation/image/payload/rollback双向set-equal | 报36、extra/omission、role/action/source swap、改固定live input |
| release-date deferred gate | 当前field字节不变，5 fact+6 requirement与正式表set-equal，GA100保持pending | 直接改字段名、旧行静默继承、MI455X Launch Date自动retain、少审一行 |
| die-count normal N/A | GA100 die include+N/A+exact reason+proof，synthetic package include且predicate=false | 对全objects表existential命中、package N/A、自由文本reason、缺endpoint proof |
| GA100 benchmark include | 六个exact object pair全include，无correct-subject值时走endpoint-aware not_found | bare-die/no-reachable-subject exclude、N/A、用A100/system值逆投 |
| Ampere expected pairs | design-objective/target-use/vendor-positioning三对全include，design-objective由p.38闭合 | 因die已有结果漏architecture pair、exclude、N/A、错主体value |
| phase replay | fresh、applying mixed、applied no-op、rollback mixed、rollback no-op共用同一immutable universe | 无event mixed、不同manifest、unknown hash、partial allocation/mapping |
| hash DAG | synthetic fixture与真实transaction解耦，拓扑覆盖全部节点 | candidate回引bootstrap、fixture绑定真实transaction、rollback/transaction互引 |

error code enum在v5基础上增加 `E_FREEZE_ARCHIVE_RAW_DRIFT,E_UNCHANGED_DRIFT,E_UNKNOWN_FORMULA,E_APPROVAL_BINDING,E_AUTHORIZATION_SET,E_IMMUTABLE_LIVE_INPUT,E_HASH_CYCLE,E_POLICY_HASH,E_STRUCTURAL_NA_PROOF,E_RELEASE_DATE_MIGRATION_BLOCKED,E_UPSTREAM_PREREQUISITE`。三运行时结果未全部存在并独立批准前，contract migration不能apply。

## v5 到 v6 exact repair crosswalk

| R12 blocker | v6替换条款 | 被拒绝的反例 |
|---|---|---|
| 1. snapshot canonical身份依赖物理path | 统一 `SemanticPath=logical_target_path`；base/post/candidate/unchanged controlled row envelope禁止T path；base/post与table image canonical逐项相等；固定fields row oracle | 同CSV从base/post目录得到三个canonical身份 |
| 2. freeze archive canonical无法复算 | archive固定raw-only，绑定当前raw SHA、55224 bytes、BOM、混合换行、24列header和77/49 parser结果；canonical两列null | 先统一换行或选不同PK再自报canonical |
| 3. scope builder映射函数未冻结 | 冻结die/package、角色、反引号group、Markdown link四个constructor；只用existing ID join；GH100/GA100 proposed ID固定；allocation/mapping semantic projection明确；pending status唯一 | 裸group、尖括号URL、canonical label join、pending reviewed、任意exact row key |
| 4. 三个新JSON可自报hash | bootstrap v2、formula evaluator和MANAGED-PATCH-V1都有typed exact schema、唯一domain、sort/null/ID矩阵、positive hex/hash与negative fixture；formula覆盖当前5个ID并预登记GA100 3个 | wrong domain、unknown/乱序key、formula任意object、patch状态自选 |
| 5. phase builder和23张表漂移 | operation builder只读T内32-table base；23张表用单一unchanged snapshot同时充当base/post；live在固定读取点逐表双hash锁定；R12部分先从71加23为94，再因post-113前置两项为96，bootstrap变45/58/12 | applied no-op从live post重建operation、mirror缺23表、并发漂移被吸收 |
| 6. chip package无独立allowed set且35误写36 | 逐项列出35个base pair；加独立authorization/approval后实际37；schema/domain/approval/manifest绑定完整；operation/image/payload/rollback双向set-equal；固定live input禁止修改 | 自报额外Markdown、漏card payload、漏image、替换source path、移除live input换snapshot |

R35 及后续补充意见对 v6 的 exact crosswalk 如下：

| 补充问题 | v6裁决 | 对contract/hash的影响 |
|---|---|---|
| release-date定义与旧行 | 冻结新名称/定义作为后续迁移目标；本事务deferred，GA100 pending；5 fact+6 requirement全集必须逐行审计 | coverage-policy candidate和其approval/hash重算；当前facts/requirements仍是unchanged，11 image不变；96 input中没有release-date新增项 |
| `FIELD-PHY-DIE-COUNT` normal N/A | exact target row的`object_type=die`才include+N/A；package仍include且不得N/A；绑定proof | policy新增第五个structural predicate；原6 mandatory N/A和108 key不变 |
| 六个benchmark pair | `OBJ-NVIDIA-GA100-DIE` 上六对强制include，无正确主体measurement时走endpoint-aware not_found | policy、expected-pair/closure hash和chip authorization重算；不增field/table/enum |
| Ampere architecture三对 | design-objective、target-use、vendor-positioning恰三对全include，design-objective为architecture value | policy、expected-pair/closure hash和chip operation universe重算；禁止手写25行计数 |
| source-pool-113与v6互相踩写 | 唯一113先推广并通过三门，v6再以c2dc...fbf0作Test-SourcePool base；两项独立prerequisite入bootstrap | bootstrap base 43→45、file input 94→96、role 44→46；managed target/image/payload/rollback不增加 |

## 精确计数与 hash 影响

| 项目 | v6结果 | hash影响 |
|---|---:|---|
| 正式 tables / columns / fields / enum groups / enum rows | `34 / 376 / 141 / 77 / 564` | 与v4/v5一致 |
| 活动名单 / allocation / mapping | `49七列 / 49 / 49` | constructor、semantic projection和row hash全部重算 |
| mapping状态 | `9 mapped + 1 GH100 pending + 1 GA100 pending + 38 unmapped` | 两个pending均唯一needs_resolution |
| contract images / payloads / managed targets | `11 / 24 / 35` | 不因23张只读锁表增加image |
| restore / delete-created | `20 / 15` | 与v5一致 |
| base / post / patch bootstrap items | `45 / 58 / 12` | 43个formal/payload base相关item加2个post-113 prerequisite；bootstrap manifest/approval重算 |
| contract file inputs | `96` | v5的71加23 unchanged snapshot再加2 prerequisite |
| chip base pairs / auth pairs / actual required | `35 / 2 / 37` | chip file-input set和transaction manifest重算 |
| stable artifact | `13` | 集合完整，不增减 |
| input role enum | `46` | v5 41加3个R12角色再加2个post-113角色 |
| mandatory / N/A rules | `108 / 6 mandatory + 1 normal die-count` | 六个mandatory key集不变，normal predicate/proof独立 |
| R35 forced include / release audit universe | `9 / (5 facts + 6 requirements)` | policy与chip closure hash重算；release审计仍deferred |
| source family/source rows | `92 / 93` 当前基线 | schema不变，继续actual-row singleton |

正式row operation数必须由immutable base和冻结post重新生成；不能为了匹配报告手写数而删减。table image仍是11，是因为23张unchanged table没有operation或write authorization，两个post-113 prerequisite也只是只读前置。前者通过96个file input中的23个snapshot、bootstrap两个array、transaction manifest集合hash和五个固定live读取点完成锁定；后者通过manifest/approval和post-113正式hash门锁定。

## 实现与验收顺序

1. 先冻结本稿和表中九个继承/独立复核输入hash。不创建stable registry，也不从当前旧Test-SourcePool复制base。
2. 先执行source-pool-113 v4正式推广并在Windows完成三门；生成和独立批准两个prerequisite item。只有live Test-SourcePool等于c2dc...fbf0后，才只读复制九张changed base table、23张unchanged table和11个base raw payload。
3. 按raw-only parser读取freeze archive，构造49行七列名单、allocation和mapping semantic projection；按本稿生成13个candidate、22个普通post snapshot和12个patch。
4. 生成formula evaluator时，先对当前24条derived metric确认formula ID只来自已登记5项，再加入GA100 3项预登记；任何未登记ID立即停止。
5. 三运行时执行继承fixture和v6 fixture。只有positive hex/hash与negative error code全等，才允许批准fixture manifest。
6. 依次批准candidate artifact、bootstrap manifest/approval，再构造operations、11 images、24 payload、96 file inputs和35 rollback rows。complete mirror只能由T内32-table base生成。
7. isolated mirror通过34/376/141/77/564、832 AFPV2、49/49 scope、1,059 legacy baseline、formula、source family、N/A、recovery、source pool和Windows三道门后，才生成transaction approval并apply。
8. GA100 chip package从applied base生成37项file input及独立authorization。它不重复创建factor table，也不能修改35项固定base中的live artifact。
9. 独立设计验收先复算本稿SHA和所有oracle，再按crosswalk执行fresh、mixed、apply、no-op、rollback、unknown formula、freeze drift、unchanged drift、upstream pending/drift、chip extra/omission反例。通过只表示可以进入实现，不表示正式迁移、GA100资料卡或Windows gate已经完成。

本稿保留R12已确认通过的算术和语义，只关闭六类可执行性blocker，并纳入R35与source-pool交叉约束。实现阶段若要改变96/35/37计数、23张unchanged策略、post-113先行顺序、formula集合或固定live禁写策略，必须另起合同版本，不能用实现备注覆盖本稿。
