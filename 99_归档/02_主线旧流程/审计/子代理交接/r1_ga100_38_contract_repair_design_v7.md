# GA100 资料卡合同修复设计 v7

## 状态、继承顺序与写入边界

本稿只修订机器合同。它不执行 source-pool-113 推广、contract migration 或 GA100 chip work package，也不表示三运行时 fixture、Windows 数据门、正式来源选择或资料卡已经通过。本轮只新增本报告；v6、正式 CSV、validator、staging、资料卡和进度文件保持原字节。

规范继承顺序固定为 v3、R08、R09、v4、R10、v5、R12、R35、source-pool-113 v4 独立复核、R13、v6、R14、v7。与本稿冲突的 v6 条款由本稿逐项替换；未冲突且已通过 R12、R13、R14 复算的 byte contract、scope constructor、raw-only freeze、source family singleton、六个 mandatory N/A、factor migration、reconciliation、AFPV2、cutoff、reverse-removal、source-pool 前置和事务恢复规则继续生效。

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
| `r1_contract_13_release_date_semantic_audit.md` | `1c25df6fbc5a8371a0827edadf33dfee1c1561725db197f7a604589f97af63da` |
| `r1_ga100_36_contract_repair_design_v6.md` | `a59eacd0d1e82db52427abdc5de6881d68416d0ce7143124a3e8d2bed22ec641` |
| `r1_contract_14_design_v6_independent_review.md` | `357b3d1af81434be6eeb07ef08030d7d83baf54edc9ec1a5ebfb7547b94c5c8b` |

v6 继续作为冻结上游报告，但不再占用 active `contract_design` role。contract migration与chip package的该项都必须改绑：

```text
ActiveContractDesignV7 =
  (contract_design,
   审计/子代理交接/r1_ga100_38_contract_repair_design_v7.md)

ReplaceActiveContractDesign(S) =
  S
  minus {(contract_design,
          审计/子代理交接/r1_ga100_36_contract_repair_design_v6.md)}
  union {ActiveContractDesignV7}

ContractFileInputSetV7 = ReplaceActiveContractDesign(ContractFileInputSetV6)
BaseChipRolePathSetV7  = ReplaceActiveContractDesign(BaseChipRolePathSetV6)

Count(ContractFileInputSetV7) == 96
Count(BaseChipRolePathSetV7)  == 35
```

其 `raw_sha256` 使用本稿定稿后从文件外部复算的最终值；报告不能把自己的hash写进自身bytes。任何 transaction仍把v6路径登记为 active `contract_design`、同时登记v6/v7两个active design，或用本稿落盘前的中间hash，都返回 `E_REQUIRED_SET`。这只是35/96集合中的同role路径替换，计数不变。

source-pool-113 v4 仍必须先正式推广，sequence 00 至 11 全部成功，三份 Windows transcript 全部 PASS，独立 prerequisite manifest 与 approval 完成后，v7 才能复制任何 base snapshot。`Test-SourcePool.ps1` 的 base hash继续固定为 post-113 值 `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0`，不准从当前旧 live validator 构造。

正式 contract postimage 算术不变：

```text
tables:          32 + 2                       = 34
schema columns:  346 + 4 + 20 + 5 + 1       = 376
fields:          141 - 1 + 1                 = 141
enum groups:     76 + 1                      = 77
enum rows:       557 - 1 + 5 + 1 + 2         = 564
```

contract 的 `11 table images / 24 payloads / 35 managed targets / 20 restore / 15 delete-created / 13 stable artifacts` 不变。bootstrap 仍是 `45 / 58 / 12`，contract file input仍为96，role token仍为46。v7 新增的是 chip scope mapping 的37/38双分支；它不倒推改变 contract migration 数量。

## Bootstrap membership 与96项 file input

### 三个 array 的唯一 identity

bootstrap item仍使用 v6 的七个 exact key。v7 把 item identity 和 locator分别定义为：

```text
ItemIdentity7(i) =
  (input_role,source_path,logical_target_path,preimage_state,
   raw_sha256,canonical_domain_tag,canonical_sha256)

ItemLocator3(i) =
  (input_role,source_path,logical_target_path)
```

`BaseItems`、`PostItems`、`PatchItems` 各自内部必须同时满足 `ItemIdentity7` 唯一和 `ItemLocator3` 唯一。这样既拒绝完全重复项，也拒绝同一 locator 自报两组不同 hash。全局不再要求三个 array 合并后 `(role,path)` 唯一，因为23个 unchanged membership本来就要跨 base/post复用。

独立 builder先构造 v6 明列的23个 `UnchangedItem`。每项只复制一份物理文件，七键在 base与post中逐字相同。集合关系固定为：

```text
U23 = BuildTwentyThreeUnchangedItemsFromOneSnapshotEach()

Set7(BaseItems) intersect Set7(PostItems) == Set7(U23)
Set7(BaseItems) intersect Set7(PatchItems) == empty
Set7(PostItems) intersect Set7(PatchItems) == empty

Count(BaseItems)  == 20 base + 23 unchanged + 2 prerequisite == 45
Count(PostItems)  == 22 post + 23 unchanged + 13 candidate  == 58
Count(PatchItems) == 12
Count(Set7(BaseItems union PostItems union PatchItems))      == 92
```

`BaseItems - U23` 恰为20个 managed base加2个 source-pool prerequisite；`PostItems - U23` 恰为22个 changed post加13个 stable candidate。两个差集也分别与 v6 的路径/role builder双向 set-equal。不能用总数45/58掩盖错交集。

### unchanged 只投影一个 file-input row

file-input builder对三个 array先取 `ItemIdentity7` 并集，再投影 `(input_role,source_path)`。只有 `U23` 可以在两个 array中贡献同一 identity；这23项各投影一行，不因 base/post membership产生第二行。其他 identity若投影到相同 `(role,source_path)` 一律失败，不做静默去重。

```text
BootstrapUniqueInputs =
  ProjectUniqueRoleSource(Set7(BaseItems union PostItems union PatchItems))

Count(BootstrapUniqueInputs) == 92

ContractFileInputs = BootstrapUniqueInputs
  union {contract_design(v7 path),scope_freeze_archive,
         bootstrap_bundle_manifest,bootstrap_bundle_approval}

Count(ContractFileInputs) == 92 + 4 == 96
```

CSV仍须与这96个 `(input_role,relative_path)` 双向 set-equal，每键恰一行且 `is_required=true`。`FIX-V7-BOOTSTRAP-UNCHANGED-INTERSECTION` 的正例使用实际45/58/12 builder，要求23项七键交集、92个唯一 identity和96个 file input同时成立。负例固定覆盖 array内重复、同locator异hash、少一个post unchanged、base/post unchanged hash不同、patch与base/post相交、把23项登记成46行，以及错误去重一个非unchanged冲突；分别返回 `E_BOOTSTRAP_ITEM_IDENTITY`、`E_BOOTSTRAP_PHASE_INTERSECTION` 或 `E_FILE_INPUT_PROJECTION`。

v6 的 `FIX-V6-BOOTSTRAP-MANIFEST` serialization oracle保持原值。v7 fixture验证的是 membership/set projection，不另发明 JSON domain，也不改变 `CONTRACT-BOOTSTRAP-V2` schema。

## SemanticPath fixture 的 domain 与 payload类型

v6 的 `33b9...`、`b43d...`、`d43f...` 数值正确，但它们是 singleton rowset，不是单行 RowHash。v7 用当前 `数据/fields.csv` 第一条 data row定义 canonical envelope `E(p)`：envelope的 `table_path=p`，domain cell为 `research-csv-row-v1`，PK为该行 `field_id`，columns按当前 schema ordinal完整排列。

两种 hash严格分开：

```text
RowHash(p) = SHA256(
  UTF8("row-v1") || 0x00 || UINT64_BE(ByteLen(E(p))) || E(p))

SingletonRowsetHash(p) = SHA256(
  UTF8("rowset-v1") || 0x00 ||
  UINT64_BE(ByteLen("[" || E(p) || "]")) ||
  "[" || E(p) || "]")
```

`E(p)` 和 `[E(p)]` 都是无额外空白的 canonical JSON UTF-8 bytes。三个精确 oracle为：

| envelope `table_path` | `E(p)` bytes / singleton payload bytes | `row-v1` | singleton `rowset-v1` |
|---|---:|---|---|
| `数据/fields.csv` | `859 / 861` | `c9332d894c520577a49b7479652139dc9f6de35df8591481bd25e7e1b9a4c10f` | `33b9c8872bb811fb91c3147df2c6c85f852ae63cf6be380e9f84b3a35de5eff2` |
| `审计/事务/TX-TEST/inputs/base/数据/fields.csv` | `893 / 895` | `8db42271feef643745b699bb303622c09a2c22038c7415f370dd059fbea7aa2a` | `b43d5fe8867c74f0487df09b3f6fca35ac5763f27742126c6d7c0ac3df1860c6` |
| `审计/事务/TX-TEST/inputs/post/数据/fields.csv` | `893 / 895` | `d605741c1806deb881fa6631bc72d401cc1b8a444503db4cbb9557ffaf8bd91d` | `d43f156813cf3b382a603af19fb6ef460883435b9276ef6f055d15a97212b81a` |

正确的 base/post snapshot虽然从后两条物理路径读取，envelope仍必须使用 `SemanticPath=数据/fields.csv`，所以合法 RowHash恒为 `c933...`，singleton rowset恒为 `33b9...`。后两行仅是把物理T path错误写进envelope时的 negative oracle。table image的 canonical set继续使用 `rowset-v1`；单行 operation pre/post hash继续使用 `row-v1`，二者不得互换。

## Release-date 仍为 deferred migration

R13 已作为冻结输入。coverage policy中 `release_date_semantics_gate.target_field_name_zh` 必须逐字为：

```text
首次公开日期
```

`target_definition` 必须逐字为以下188-byte UTF-8文本：

```text
厂商或设计方在具日期、可核验的正式材料中首次直接命名/宣布该研究对象；不能用上位架构预告、下位产品发布、availability/shipping/sales 替代
```

合格材料是厂商或设计方发布的具日期、可核验正式材料，不得缩窄为“官方页面”，也不得放宽为媒体转述。R13 的5条 fact、6条 requirement、证据/检索闭包和全部语义引用面仍须由后续独立 migration原子裁决。本事务不修改 `fields.csv`、`facts.csv`、`field-requirements.csv`、字段字典、模板或卡片；GA100 release-date requirement继续 `pending_verification`，正式计数和96个 contract input均 `+0`。

coverage policy仍属 `COVERAGE-POLICY-V5`，v6 冻结的完整顶层 key序保持不变。这里只替换 deferred gate内的目标字节；policy candidate、approval、bootstrap candidate和transaction相关 hash必须据此重算。

## R35 coverage gate 不退步

v7不改写v6已经冻结的三类R35规则。`FIELD-PHY-DIE-COUNT` 仍只在exact target object row满足 `object_type=die` 和 `PRED-NORMAL-PHY-DIE-COUNT-TARGET-IS-DIE-V1` 时允许normal structural N/A；package target继续include并走value或endpoint-aware not_found。GA100 card object上的 `FIELD-BENCH-LATENCY,FIELD-BENCH-THROUGHPUT,FIELD-BENCH-POWER,FIELD-BENCH-ENERGY-PER-TOKEN,FIELD-BENCH-TOKENS-PER-JOULE,FIELD-BENCH-UTILIZATION` 六对仍必须include，不能以bare die或no reachable subject排除；没有正确主体measurement时只能走endpoint-aware not_found。reachable Ampere object上的 `FIELD-ID-DESIGN-OBJECTIVE,FIELD-ID-TARGET-USE-POSITIONING,FIELD-ID-VENDOR-POSITIONING` 三对仍由expected-pair builder逐项生成并include，不能因GA100 die已有同field结果而消失。以上规则继续使用v6 exact predicate、proof和reason code，mandatory集合仍为108，六个mandatory N/A和一个normal die-count N/A互不混用，不增加正式field/table/enum。

## Formula evaluator 对现有24条派生指标的闭包

### 独立 use-builder

当前 immutable base包含24条 `derived-metrics.csv` row和47条 `derived-inputs.csv` row。v7 不只检查 formula ID集合，而是从 `derived-metrics.csv`、`derived-inputs.csv`、`facts.csv`、`fields.csv` 四个 snapshot独立构造：

```text
FormulaUseProjection(m) =
  (formula_id,derived_metric_id,derived_fact_id,
   output_field_id,output_fact_value_kind,
   output_fact_normalized_unit,metric_output_unit,
   arity,
   [(input_order,input_role,input_field_id,
     input_normalized_unit,input_normalized_value)...])
```

builder对每条 metric按 `derived_fact_id` exact key找唯一 output fact；inputs按整数 `input_order` 排序，必须从1连续到spec.arity，每个 input fact唯一存在。随后逐项检查 role、allowed field、unit option、required decimal、operation、constant、rounding、output field和重算值。output field的 `canonical_unit` 非空时必须与numeric spec相等；为空时不能反向禁止事实行使用 `TFLOP/s`、`FLOP/s` 或 `FLOP/cycle/CU` 等已登记单位。

当前五个已使用 formula和24条 row的精确兼容投影为：

| formula | metric/input行数 | 实际 input field@unit / arity | 实际 output | 重算规则 |
|---|---:|---|---|---|
| `FORMULA-COMPUTE-DIV-MEMBW` | `7 / 14` | numerator `FIELD-COMP-THROUGHPUT@TFLOP/s`；denominator `FIELD-MEM-READ-BW@byte/s`；2 | `FIELD-DER-COMPUTE-BW-SPEC@FLOP/byte` | 乘 `10^12` 后相除，2位 half-up；7值全等 |
| `FORMULA-AWS-TRN2-COMPUTE-DIV-HBM-BW` | `4 / 8` | numerator `FIELD-COMP-THROUGHPUT@FLOP/s`；denominator `FIELD-MEM-BIDIR-BW@byte/s`；2 | `FIELD-DER-COMPUTE-BW-SPEC@FLOP/byte` | 相除，1位 half-up；`447.9,230.0,62.4,883.8` |
| `FORMULA-AWS-TRN2-CORE-X8` | `11 / 22` | numerator `FIELD-COMP-THROUGHPUT@FLOP/s`；scale `FIELD-COMP-UNIT-COUNT@count=8`；2 | `FIELD-COMP-THROUGHPUT@FLOP/s` | exact multiply；11值全等 |
| `FORMULA-MATRIX-DIV-VECTOR` | `1 / 2` | numerator/denominator均为 `FIELD-COMP-THROUGHPUT@FLOP/cycle/CU`；2 | `FIELD-DER-MATRIX-VECTOR@ratio` | `4096 / 256 = 16` exact |
| `FORMULA-STRUCTURAL-PROJECTION` | `1 / 1` | other `FIELD-MEM-CAPACITY@byte=262144`；1 | enum text `FIELD-MEM-POOLING-MODE` | constant `distributed_not_pooled` |

formula registry的ID集合仍与这五个已使用ID加以下三个 GA100 ID双向 set-equal：

```text
FORMULA-GA100-HBM-CONTROLLER-COUNT-X512
FORMULA-GA100-NVLINK-COUNT-X25GBPS
FORMULA-GA100-BIDIRECTIONAL-X2
```

三个预登记ID允许当前 usage count为0；出现第九个ID立即返回 `E_UNKNOWN_FORMULA`。当前24条使用分布固定为 `7/4/11/1/1`，合计24；47条 input合计为 `14+8+22+2+1`。

### enum/text output 的专门规则

v6 的“text output要求 `output_unit=null`”以及v3无条件的 `derived-metrics.output_unit == fact.normalized_unit` 在 enum/text分支被本节替换。`output_value_kind=text` 在 formula evaluator v1 中只允许输出到 `fields.value_kind=enum` 且 `value_enum_name` 非空的 field，并要求：

```text
enum_token = "enum:" + fields.value_enum_name

formula.output_unit              == enum_token
derived-metrics.output_unit      == enum_token
facts.normalized_unit            == empty
facts.normalized_value_number    == empty
facts.normalized_value_text      == formula.constant_text
formula.constant_decimal         == null
formula.decimal_places           == null
formula.rounding_mode            == none
formula.operation                == emit_constant_text
```

因此 `FORMULA-STRUCTURAL-PROJECTION` 的 output descriptor固定为 `output_value_kind=text`、`output_unit=enum:pooling_mode`、`required_output_field_id=FIELD-MEM-POOLING-MODE`、`constant_text=distributed_not_pooled`。numeric output仍要求 formula、derived metric和fact三者unit逐字相等。

这项修复只改变尚未落盘的 `formula-evaluator-v1.json` candidate及其 formula managed patch post hash；`derived-metrics.csv`、`derived-inputs.csv`、`facts.csv` 和 `fields.csv`继续属于23张 unchanged snapshot，不增加 table image。

`FIX-V7-FORMULA-STRUCTURAL-ENUM-CURRENT` 直接读取当前四表 snapshot，要求以下 projection通过：

```text
(FORMULA-STRUCTURAL-PROJECTION,
 DERMET-NVIDIA-H100-REG-POOLING-MODE,
 FACT-NVIDIA-H100-REG-POOLING-MODE,
 FIELD-MEM-POOLING-MODE,text,
 empty,enum:pooling_mode,
 1,[(1,other,FIELD-MEM-CAPACITY,byte,262144)],
 distributed_not_pooled)
```

把 formula descriptor改回null、把metric token改为 `pooling_mode`、把fact unit填成enum token、输出field不是enum、constant错或arity错均失败，返回 `E_FORMULA_OUTPUT_DESCRIPTOR`、`E_FORMULA_FACT_UNIT`、`E_FORMULA_VALUE` 或 `E_FORMULA_ARITY`。v6 numeric synthetic formula oracle仍保持 `122f80043c705bfc3f34ea662298cdde4e7f283f3952079375dd5b4edb9cac76`；实际 formula candidate内容必须按本节重算，不能沿用v6尚未生成的设想字节。

## Scope mapping 的37/38双分支

### 分支只由冻结 preimage决定

前文已从35项active chip base机械得到 `BaseChipRolePathSetV7`。随后定义：

```text
MappingStablePair =
  (scope_mapping_registry,审计/合同注册表/scope-object-mapping.csv)

CommonChipBase34 = BaseChipRolePathSetV7 minus {MappingStablePair}
AuthorizationTwo = {
  (chip_operation_authorization,
   T/authorization/chip-operation-payload-authorization.json),
  (chip_operation_authorization_approval,
   T/authorization/chip-operation-payload-authorization-approval.json)
}
Count(AuthorizationTwo) == 2
```

若该 scope 的 `EffectiveTip` 已经是同一 `card_object_id` 的 `mapped+approved`，使用 no-mapping-change 分支：

```text
ChipRequired37 = CommonChipBase34
  union {MappingStablePair}
  union AuthorizationTwo

Count == 34 + 1 + 2 == 37
```

若有效tip不是同 card的 `mapped+approved`，必须使用 mapping-override 分支。stable live pair从35项中移除，只增加以下两个既有role的T内snapshot：

```text
(managed_base_snapshot,
 T/inputs/base/审计/合同注册表/scope-object-mapping.csv)

(managed_postimage_snapshot,
 T/inputs/post/审计/合同注册表/scope-object-mapping.csv)
```

两项 `logical_target_path` 都逐字等于 `审计/合同注册表/scope-object-mapping.csv`，canonical envelope也使用该 SemanticPath。于是：

```text
ChipRequired38 = CommonChipBase34
  union {mapping base snapshot,mapping post snapshot}
  union AuthorizationTwo

Count == 34 + 2 + 2 == 38
```

no-change分支保留28个T外 stable/live pair；override分支为27个。snapshot复用既有 `managed_base_snapshot/managed_postimage_snapshot`，不增加role token，46不变。两个分支互斥：stable mapping pair与两张mapping snapshot不得同时存在；两张snapshot也不得只出现一张。branch在transaction首次冻结时从immutable base决定，后续 fresh、resume、applied no-op和rollback都从T内base及manifest重建同一分支，禁止因live已经变成mapped而把38项no-op重解释成37项。

GA100 的 contract postimage固定为：

```text
(FREEZE-NV-001,SCOPE-0001,1,
 empty,OBJ-NVIDIA-GA100-DIE,
 pending_formal_object_create,needs_resolution)
```

所以 GA100 必须走38项分支。

### 唯一 append-only 转移

对一个 scope，先验证全历史 `(scope_id,mapping_event_seq)` 唯一且seq从1连续。`EffectiveTip` 取最高seq且 `approval_status != rejected` 的event；`next_seq` 等于全部历史最大seq加1，拒绝过的event也占用sequence。旧event任何 update/delete都失败。

允许从以下三种有效tip进入同一个终态：

| tip状态 | 前置 | 新event |
|---|---|---|
| `pending_formal_object_create` | proposed ID非空且等于card ID；object在base absent，本事务insert | `mapped+approved` |
| `pending_identity_review` | proposed ID非空且等于card ID；本事务补齐或修正identity/scope | `mapped+approved` |
| `unmapped` | formal/proposed均空；独立identity裁决把freeze scope与card ID绑定 | `mapped+approved` |

`retired`、`tombstoned`、非approved的 `mapped` 或无法唯一解释的event chain不得借本分支复活，返回 `E_SCOPE_MAPPING_TRANSITION`。已映射到另一个formal ID也不得覆盖。

新event semantic projection必须为：

```text
(freeze_row_id,same scope_id,next_seq,
 formal_object_id=card_object_id,
 proposed_formal_object_id=empty,
 mapping_status=mapped,
 approval_status=approved)
```

`mapping_event_id` 的机械constructor为 `MAPEV-<scope_id>-<seq>`，其中seq为最少四位、不截断的零填充十进制；GA100 seq2固定 `MAPEV-SCOPE-0001-0002`。`mapping_basis` 固定为 `chip_identity_mapping_approved_v1`。approved event的 reviewer/date必须非空且由独立authorization完整绑定；审计人员姓名和日期不由名称或对象数据猜测。full row hash、insert operation和authorization table item逐字相等。

GA100 post snapshot必须保留原49行不变并恰追加上面的seq2 event，总行数为50。全历史状态为 `10 mapped + 1 pending_identity_review + 1 historical pending_formal_object_create + 38 unmapped`；按每scope EffectiveTip归约则为 `10 mapped + 1 pending_identity_review + 38 unmapped`，合计49。

### 与 object identity/card creation 同一事务

mapping insert不能单独发布。override branch的H10 complete planned post和H18 isolated full post mirror都必须同时满足：

```text
ExactlyOne(objects.csv row where object_id == card_object_id)
objects.scope_id == scope_id

ExactlyOne(card-completeness.csv identity row for card_object_id)
identity.scope_id == scope_id
identity lifecycle satisfies chip publication phase

ExactlyOne(new mapping event for (scope_id,next_seq))
LatestApprovedMapping(scope_id).formal_object_id == card_object_id
No event with seq greater than that mapping and approval_status != rejected
```

若object在base absent，objects与identity使用insert；若object已存在但identity未闭合，必须以授权的update/insert组合到达同一post条件。mapping、object、identity及其余card operation共享一个transaction manifest、authorization和journal。缺任一项都不能先apply另两项。

mapping table产生一个 present→present table image和一个 `restore` rollback target，不产生raw payload target。相对于内容相同但不做mapping的chip package，override branch恰多一条mapping row insert、一个distinct table image和一个rollback target，payload数不变。chip的具体operation/image/payload总数仍由authorization双向 set-equal，不写死为contract migration的11/24。

## Forced GA100 object 的phase-aware解析

`coverage-policy-v5.0.json` 在 contract migration阶段引用尚未存在的 `OBJ-NVIDIA-GA100-DIE`。v7只为这一项冻结唯一forward-resolution规则，不提供通用悬空FK豁免。

contract candidate gate要求：

```text
ga100_mandatory_policy.card_object_id
  == every ga100_forced_object_include_rules[*].target_id
  == OBJ-NVIDIA-GA100-DIE

ExactlyOne active allocation:
  FREEZE-NV-001 -> SCOPE-0001

ExactlyOne EffectiveTip in candidate scope mapping:
  scope_id=SCOPE-0001
  seq=1
  mapping_status=pending_formal_object_create
  approval_status=needs_resolution
  formal_object_id=empty
  proposed_formal_object_id=OBJ-NVIDIA-GA100-DIE
```

六个 forced rule必须全部是 `target_kind=object`，并继续与R35的六个benchmark field set-equal。contract phase只允许 `ga100_mandatory_policy.card_object_id` 和这六个rule通过上述 proposed ID解析；任何其他缺失 object target、第二条active proposed mapping、错scope、错seq、错status或不同ID都返回 `E_POLICY_FORWARD_TARGET`。

chip package在H3 preliminary semantic post上先切换到正式解析：target ID必须exact命中唯一 `objects.csv` row，且该对象、identity、scope allocation和最新unblocked `mapped+approved` event都指向同一 `SCOPE-0001`。H10 complete planned post、H18 isolated full post mirror和apply后live gate还要逐次复算同一关系，此时禁止继续用seq1 proposed ID代替正式FK。coverage manifest绑定seq2 mapping row hash和card object row hash。这样六个 forced benchmark pair既不会在contract阶段成为任意未来字符串，也不会在chip完成后继续悬空。

## Authorization 顶层身份绑定

v6 authorization的exact schema、13列 operation item、19列 payload item、approval domain和双向 allowed-set公式均保留，不新增顶层key。四个身份字段只作以下两组比较：

```text
authorization.transaction_id
  == transaction_manifest.transaction_id

(authorization.work_package_id,
 authorization.scope_id,
 authorization.card_object_id)
  ==
(coverage_manifest.work_package_id,
 coverage_manifest.scope_id,
 coverage_manifest.card_object_id)
```

coverage manifest没有 `transaction_id`，transaction manifest也没有后三个field；validator不得读取不存在的key，也不得用“比较共有字段”自行放宽。transaction ID在构建开始时作为预分配scalar输入，后续由authorization与transaction manifest共同引用，不形成反向hash边。

`FIX-V7-AUTHORIZATION-IDENTITY` 正例分别完成上述两个等式。把authorization transaction ID拿去和coverage manifest比较、把work package/scope/card拿去和transaction manifest比较、coverage三元组任一错位、transaction ID错位或为通过测试擅自扩任一manifest schema都失败，返回 `E_AUTHORIZATION_IDENTITY_BINDING` 或 `E_JSON_KEY`。

## 无同层依赖的 hash DAG

validator必须同时收集显式 hash-reference edge和会决定下游bytes的semantic edge，包括approval绑定、candidate source path、patch post hash、runtime-result fixture输入、manifest set hash和transaction ID预分配引用。对每条边都要求 `level(parent) < level(child)`；只比较节点数与拓扑输出数仍不够。

contract migration的层级固定为：

```text
C0  frozen reports, raw freeze, post-113 formal evidence,
    preimage live bytes, synthetic fixture source values, transaction_id scalar
C1  source-pool prerequisite manifest derived from C0 post-113 evidence
C2  source-pool prerequisite approval
C3  immutable base/post/unchanged snapshots and raw candidates, copied only after C2
C4  scope/date/legacy/reconciliation/formula/canonical-fixture candidate bytes
    derived from C3
C5  coverage-policy candidate after scope forward-target resolution;
    date/legacy artifact approvals; canonical runtime results from C4 fixtures
C6  coverage-policy approval; canonical fixture manifest from C5 results;
    all managed patches, including formula patch after C4 formula candidate
C7  bootstrap bundle manifest
C8  bootstrap bundle approval
C9  planned contract delta and payload plan
C10 operation inventory materialized from C9
C11 isolated post mirror produced by applying C10 operations to C3 base
C12 table-image, payload and file-input inventories
C13 rollback rows derived from C12 images/payloads
C14 rollback manifest
C15 transaction manifest
C16 transaction approval
C17 append-only journal events
```

真实edge `formula candidate -> formula managed patch` 因此从C4跨到C6，不再同层。source-pool prerequisite manifest先于其approval，approval先于任何snapshot；snapshot再先于由其派生的candidate。fixture bytes/formula schema先于runtime results，runtime results先于fixture manifest；candidate artifact先于批准它的approval；planned delta先于operation inventory，operation先于mirror，mirror先于table image，image/payload先于rollback row，rollback row先于rollback manifest；bootstrap manifest和transaction manifest也都先于各自approval。approval不得反向进入被批准artifact的bytes。

chip branch的层级固定为：

```text
H0  applied contract inputs, immutable mapping base when used,
    source/candidate raw bytes, preallocated transaction_id
H1  direct non-derived row/payload candidates, including fact/assertion,
    search/result/evidence, object/identity and mapping seq+1 candidates
H2  formula-derived post row candidates computed from H1 inputs
H3  pre-coverage candidate view combining H1/H2 with immutable base
H4  reachability inventory and formula-use verification from H3
H5  expected field-pair and factor-obligation builder outputs from H4
H6  coverage target, reachable binding and factor-binding rows from H5
H7  terminal requirement/factor adjudication rows derived from H1/H6,
    including endpoint-aware terminal evidence closure
H8  selection and reverse-removal result rows derived from H7
H9  coverage-field rows derived from H7/H8
H10 complete planned post view combining H1/H2/H6-H9 with immutable base
H11 complete planned delta as ExactDiff(H0 base,H10 post)
H12 transaction coverage closure set derived from H4-H11
H13 coverage manifest binding H10 object/mapping and H12 closure
H14 coverage approval
H15 chip operation/payload authorization built from the complete H11 delta
H16 authorization approval
H17 actual operation, payload and file-input inventories materialized
H18 isolated full post mirror produced by applying H17 to the H0 immutable base;
    exact set-equal to the H10 planned post view
H19 table images derived from H17/H18
H20 rollback rows derived from H17/H19
H21 rollback manifest
H22 transaction manifest
H23 transaction approval
H24 append-only journal events
```

authorization中的planned operation/payload item是H11完整delta的受批准表达，实际CSV在H17 materialize并与之set-equal，所以没有 `actual operations -> authorization -> actual operations` 自环。H3只是供reachability和formula-use读取的pre-coverage view，不冒充最终post；expected pair/factor、target/binding、terminal adjudication、selection/reverse-removal和coverage-field rows依次升层，不能由一个opaque builder同层生成。H10先汇成complete planned post，H11再求完整delta，H12才构造transaction coverage closure；coverage manifest随后依次先于coverage approval和authorization。H17 operations施加到H0 immutable base才得到H18 isolated full post mirror，且H18必须与H10逐表、逐行、逐payload exact set-equal。transaction ID来自H0，transaction manifest在H22绑定authorization hash。任何同层实际edge、approval回指自身、runtime result读取fixture manifest、formula patch先于candidate或coverage approval参与mapping row生成，都返回 `E_HASH_CYCLE` 或 `E_HASH_LEVEL`。

## v7状态机

### immutable builders

```text
BuildContractInputsV7(T):
    Require(SourcePool113PromotedAndApprovedBeforeSnapshot())
    base = Build45BaseMemberships()
    post = Build58PostMemberships()
    patch = Build12PatchMembershipsAfterCandidateBytes()
    ValidatePerArrayIdentityAndLocatorUniqueness(base,post,patch)
    Require(Set7(base) intersect Set7(post) == Set7(U23))
    Require(OtherIntersectionsEmpty())
    file_inputs = Project92UniqueBootstrapInputs() + FourFixedInputs()
    Require(Count(file_inputs) == 96)
    ValidateFormulaUseBuilderAgainst24CurrentRows()
    return immutable inputs
```

```text
ChooseChipBranchV7(T,stable_mapping,scope_id,card_object_id):
    tip = EffectiveTip(stable_mapping,scope_id)
    if tip is mapped+approved to card_object_id:
        Require(ChipRequired37 exact set)
        return NO_MAPPING_CHANGE

    Require(tip.status in {
      pending_formal_object_create,
      pending_identity_review,
      unmapped})
    Copy stable_mapping once to T mapping base
    Build exactly one append-only mapped+approved event
    Build full mapping post snapshot
    Require(ChipRequired38 exact set)
    return MAPPING_OVERRIDE
```

```text
BuildChipOperationSetV7(T):
    branch = BranchEncodedByApprovedImmutableInputs(T)
    base = BuildChipBaseOnlyFromTAndApprovedStableInputs(branch)
    direct_candidates = BuildDirectNonDerivedCandidates(base,branch)
    formula_candidates = BuildFormulaDerivedCandidates(direct_candidates)
    candidates = Union(direct_candidates,formula_candidates)
    pre_coverage_view = BuildPreliminarySemanticPostView(base,candidates)
    ValidateForcedTargetAgainstPostObjectAndLatestMapping(pre_coverage_view)
    formula_use = Validate24ExistingAndAllNewFormulaUses(pre_coverage_view)
    expected = BuildExpectedPairsAndFactors(pre_coverage_view,formula_use)
    bindings = BuildCoverageTargetsAndBindings(pre_coverage_view,expected)
    terminal = BuildTerminalRequirementFactorAdjudications(
                 candidates,bindings)
    selection = BuildSelectionAndReverseRemoval(terminal)
    coverage_fields = BuildCoverageFields(terminal,selection)
    coverage_rows = Union(bindings,terminal,selection,coverage_fields)
    planned_post = BuildCompletePlannedPostView(base,candidates,coverage_rows)
    planned_delta = ExactDiff(base,planned_post)
    closure = BuildTransactionCoverageClosure(
                planned_post,planned_delta,expected)
    coverage = BuildCoverageManifest(planned_post,closure)
    authorization = LoadApprovedAuthorizationFor(coverage)
    Require(ProjectPlannedDelta(planned_delta)
            == ProjectAuthorizedDelta(authorization))
    operations,payloads = MaterializeAuthorization(authorization)
    Require(Project13(operations) == authorization.table_operation_items)
    Require(Project19(payloads) == authorization.payload_items)
    post = ApplyOperationsAndPayloadsToImmutableBase(base,operations,payloads)
    Require(ExactManagedPostSet(post) == ExactManagedPostSet(planned_post))
    return branch,operations,payloads,post
```

### validate、fresh、mixed、no-op与rollback

```text
ValidateTransactionV7(root,T):
    ValidateAllCanonicalDomainsAndOracles()
    ValidateHashDagEveryActualEdgeStrictlyIncreasesLevel()
    if contract_migration:
        Require(45/58/12 memberships, 92 unique, 96 file inputs)
        BuildContractInputsV7(T)
        ValidateContractImagesPayloadsAndRollbackSetEqual()
    else:
        branch = BranchEncodedByApprovedImmutableInputs(T)
        Require(file inputs == 37 if NO_MAPPING_CHANGE else 38)
        BuildChipOperationSetV7(T)
        ValidateAuthorizationIdentityBindingsOnlyAgainstExistingKeys()
        ValidateChipImagesPayloadsRollbackAndAuthorizationSetEqual()
```

```text
ResumeOrApplyChipV7(root,T):
    ValidateTransactionV7(root,T)
    branch,operations,payloads,post = BuildChipOperationSetV7(T)
    observed = ObserveAuthorizedManagedTargets(root)

    if observed == post and JournalHas(applied,succeeded,same_manifest):
        Require(branch is still reconstructed from immutable T base)
        ValidateLatestApprovedMappingAndForcedTargets(post)
        RunCompletePostimageGatesWithoutRewrite()
        return SUCCESS_NOOP

    if JournalLatestIs(applying,started,same_manifest):
        Require(EveryTargetIsOwnPreimageOrPostimage(observed))
        RollForwardOnlyPreimageTargetsInPathOrder()
        ValidateLatestApprovedMappingAndForcedTargets(live)
        RunCompletePostimageGates()
        AppendJournal(applied,succeeded)
        return SUCCESS_RESUMED

    Require(observed == complete_preimage)
    Require(JournalAllowsFreshOrPostRollbackApply())
    RunAllGatesOnIsolatedPost(post)
    AppendJournal(applying,started)
    ReplaceAuthorizedTargetsInPathOrder(post)
    ValidateLatestApprovedMappingAndForcedTargets(live)
    RunCompletePostimageGates()
    AppendJournal(applied,succeeded)
    return SUCCESS_APPLIED
```

```text
RollbackChipV7(root,T):
    ValidateTransactionV7(root,T)
    observed = ObserveAuthorizedManagedTargets(root)
    if observed == complete_preimage
       and JournalHas(rolled_back,succeeded,same_manifest):
        return ROLLBACK_NOOP
    if JournalLatestIs(rollback_applying,started,same_manifest):
        Require(EveryTargetIsOwnPostimageOrPreimage(observed))
    else:
        Require(observed == complete_postimage)
        Require(JournalHas(applied,succeeded,same_manifest))
        AppendJournal(rollback_applying,started)
    RestoreOrDeleteCreatedFromImmutableTInPathOrder()
    Require(ObserveAuthorizedManagedTargets(root) == complete_preimage)
    if mapping override:
        Require(mapping raw/canonical == exact 49-row base snapshot)
        Require(seq2 absent and seq1 pending row unchanged)
    AppendJournal(rolled_back,succeeded)
    return SUCCESS_ROLLED_BACK
```

rollback删除seq2只表示恢复整个受批准事务的preimage，不是普通mapping生命周期delete。无matching journal的mixed、branch计数漂移、mapping出现第三种hash、旧event改写、只创建object不追加mapping、只追加mapping不创建identity、post mapping后又出现更高non-rejected event均保留现场并失败。

## v7 fixture矩阵

v3至v6的mandatory fixture继续执行。v7新增或修正的fixture family如下；每项仍需 `powershell_5_1,powershell_7,python_3` 三行runtime result，当前设计稿不宣称这些结果已存在。

| family | positive | negative |
|---|---|---|
| bootstrap intersection | 45/58/12 membership；23个七键交集；92 unique；96 file input | array内重复、交集22/24、同locator异hash、patch相交、unchanged登记两行 |
| semantic path type | `row-v1`单envelope与`rowset-v1` singleton各匹配三值；snapshot合法路径得到formal oracle | 把33b9称RowHash、domain互换、T path进入合法envelope |
| release deferred | R13 hash命中、target name/188-byte definition逐字相同、5+6 unchanged、GA100 pending | 短定义、仅官方页面、availability/shipping替代、直接发布fact |
| current formula uses | 24 metrics/47 inputs按field/unit/role/arity/value全通过 | 只比formula ID、错field/unit/role/arity/value、unknown formula |
| structural enum | spec和metric均 `enum:pooling_mode`、fact unit空、constant命中 | spec null、metric无`enum:`、fact填enum unit、错enum field/value |
| mapping 37 | 已mapped同card、stable pair保留、无snapshot，35+2 | 已mapped到别card、存在更高non-rejected、误加snapshot |
| mapping 38 / GA100 | seq1 pending不变、append seq2、50-row post、object/identity同scope，36+2 | 报37、改seq1、少/重seq2、跳seq、错ID/status/null、缺object/identity |
| mapping replay | fresh、applying mixed roll-forward、applied no-op仍读T pending base、rollback恢复49行 | no-op从live改选37、无journal mixed、unknown mapping hash、普通delete seq2 |
| forced future object | contract只经SCOPE-0001 seq1 proposed解析；chip post经object+seq2解析同ID | 任意missing object获豁免、第二proposed、错scope/ID、chip继续用pending |
| authorization identity | transaction ID只对transaction manifest；coverage三元组只对coverage manifest | 读取不存在key、比较错manifest、任一ID漂移、擅自扩schema |
| hash DAG | candidate→formula patch、fixture→runtime→manifest、artifact→approval均严格升层 | candidate/patch同层、runtime/manifest互引、approval回填artifact |

新增error code为 `E_BOOTSTRAP_ITEM_IDENTITY,E_BOOTSTRAP_PHASE_INTERSECTION,E_FILE_INPUT_PROJECTION,E_FORMULA_OUTPUT_DESCRIPTOR,E_FORMULA_FACT_UNIT,E_FORMULA_VALUE,E_FORMULA_ARITY,E_SCOPE_MAPPING_TRANSITION,E_SCOPE_MAPPING_LIFECYCLE,E_POLICY_FORWARD_TARGET,E_AUTHORIZATION_IDENTITY_BINDING,E_HASH_LEVEL`。继承error enum不删项。

## v6到v7 exact crosswalk

| R14 blocker | v7替换条款 | 被拒绝的v6解释 |
|---|---|---|
| 1. bootstrap重复与唯一冲突 | 每个array内identity/locator唯一；Base∩Post恰U23；另两交集空；92 unique投影为96 file input | 三array合并后role/path全局唯一，或删掉post unchanged |
| 2. SemanticPath oracle类型错 | 明分 `row-v1:E` 和 `rowset-v1:[E]`；冻结三组各自hash与payload bytes | 把33b9/b43d/d43f称为RowHash |
| 3. release target漂移 | 冻结R13及SHA；逐字使用“首次公开日期”和188-byte定义；正式材料不缩为页面 | 73-byte摘要、媒体转述或availability/shipping替代 |
| 4. structural formula不相容 | 24/47独立use-builder；enum/text spec与metric用 `enum:<enum_name>`，fact unit空；四表仍unchanged | text一律null，或无条件metric unit等于fact unit |
| 5. mapping无出口且forced target悬空 | 37/38机械分支；GA100 append seq2并与object/identity同事务；contract proposed FK与chip formal FK两阶段唯一解析 | mapping固定live禁写、任意future ID、先建object后补mapping |
| 6. authorization比较不存在字段 | transaction ID只对transaction manifest；work-package/scope/card只对coverage manifest | 要求两个manifest各自拥有四个字段，或运行时按交集猜测 |
| 7. DAG同层真实依赖 | prerequisite manifest→approval→snapshots；formula candidate→patch；preliminary post→expected/binding→terminal adjudication→selection/reverse-removal→coverage fields→planned post→delta→closure→authorization→operation→isolated mirror→image逐层分开 | candidate和patch同L1、terminal/selection/coverage-field同层、operation与mirror同层，或只用节点数声称无环 |

## 精确计数与实施顺序

| 项目 | v7结果 |
|---|---:|
| 正式 tables / columns / fields / enum groups / enum rows | `34 / 376 / 141 / 77 / 564` |
| contract images / payloads / managed targets | `11 / 24 / 35` |
| contract restore / delete-created | `20 / 15` |
| stable artifacts | `13` |
| bootstrap base / post / patch membership | `45 / 58 / 12` |
| bootstrap unique identity / contract file input | `92 / 96` |
| input role token | `46` |
| chip no-mapping-change base / auth / required | `35 / 2 / 37` |
| chip mapping-override base / auth / required | `36 / 2 / 38` |
| GA100 branch | `38 required` |
| GA100 mapping rows before / after / latest scopes | `49 / 50 / 49` |
| current formula usage | `24 metrics / 47 inputs / 5 used IDs + 3 preregistered` |
| mandatory / structural N/A | `108 / 6 mandatory + 1 normal die-count` |
| forced expected-pair / release audit universe | `9 / (5 facts + 6 requirements)` |

唯一实施顺序为：先推广source-pool-113并完成三门与独立prerequisite；再按v7构造contract的45/58/12 membership、92 unique identity和96 file input；随后执行三运行时fixtures、批准candidate/patch/bootstrap、构造11/24/35事务并通过34/376/141/77/564 mirror门。contract migration正式成功后，GA100 chip package从seq1 pending preimage选择38项分支，在preliminary和complete planned post中共同规划object、identity/card、seq2 mapping与全部coverage row；完成closure、coverage approval和完整delta authorization后才materialize operations。operations施加到immutable base得到isolated full post mirror并与planned post exact set-equal，再生成images、rollback和transaction approval。任何步骤都不能用后一步产物反向决定前一步hash。

设计验收通过只表示可以进入实现。source-pool live目前仍是pre-promotion，合同注册表和factor table仍不存在，Windows三运行时也未在本机执行；这些外部状态不能由本稿替代。
