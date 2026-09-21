# R1 GA100 合同 v6 独立设计验收

审计日期：2026-08-21  
审计性质：只读、独立复算；没有修改 v6、正式数据、staging 或既有合同。

## 结论

`reject`

v6 已经实质修复 v5 的大部分设计缺口：freeze archive 变成 raw-only，49 行 scope builder 有了 exact constructor，完整正式镜像补入 23 张 unchanged snapshot，bootstrap、formula、patch 和 source-pool prerequisite 都有 typed JSON 合同及 golden oracle，chip 固定输入也从错误的 36 项校正为 35 项并增加独立 authorization。正式 postimage 算术、source-pool 前置顺序和 release-date 暂缓边界同样保持正确。

不过，当前文本仍有七个会阻断实现或让两个严格实现产生不同结果的问题。其中一个使 bootstrap positive manifest 本身不可满足；两个使 GA100 chip package 无法获得合法 scope 或无法通过 authorization 绑定；其余涉及 canonical fixture 类型、release-date 字节语义、现有 derived metric 与 formula spec 的冲突，以及 hash DAG 的错误分层。它们不是文案偏好，不能留给执行器解释。

## 冻结输入与独立基线

被审文件实测为 971 行，SHA-256 为 `a59eacd0d1e82db52427abdc5de6881d68416d0ce7143124a3e8d2bed22ec641`，与题述作者值相同。v6 第 11 至 19 行列出的九个输入，我逐文件重算后均与稿内值一致：

| 输入 | 独立实测 SHA-256 |
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

这里有一个重要缺项：v6 实际采用了 release-date 审计裁决，却没有把 `r1_contract_13_release_date_semantic_audit.md` 放进继承顺序和冻结输入表。该报告当前 SHA-256 为 `1c25df6fbc5a8371a0827edadf33dfee1c1561725db197f7a604589f97af63da`。这项遗漏已经造成 target definition 漂移，具体见后文 Blocker 3。

正式基线独立解析为 32 张正式表、346 条 schema column、141 个 field、76 个 enum group、557 个 enum row、78 个 object、585 条 completeness、832 条 assertion、93 个 source version 和 92 个 source family。当前唯一的多版本 family 在实际 qualifying source rows 上仍分别只有一种 `source_type` 和一种 `source_authority`。13 个 stable target、两张 factor table和整个正式合同注册表当前均不存在。

正式 postimage 计数仍是：

```text
tables          32 + 2                         = 34
schema columns  346 + 4 + 20 + 5 + 1          = 376
fields          141 - 1 + 1                   = 141
enum groups     76 + 1                        = 77
enum rows       557 - 1 + 5 + 1 + 2           = 564
```

## R12 六个 blocker 的关闭情况

| R12 问题 | v6 独立裁决 | 说明 |
|---|---|---|
| snapshot semantic path | 部分关闭 | `SemanticPath=logical_target_path` 和 base/post/image 等式已经唯一；positive oracle 却把 singleton rowset hash称为 row hash，仍有类型冲突。 |
| freeze archive canonical kind | 已关闭 | raw-only、空 canonical 两列、24 列 parser、BOM与混合换行检查均可执行。 |
| 49 行 scope builder | 已关闭 | layer、role、Markdown link、六元组双射、行序分配和 projection 均已冻结。 |
| bootstrap/formula/patch bytes | 部分关闭 | 四个新 oracle均能重建；bootstrap数组唯一性自相矛盾，formula spec又与一条 unchanged正式 derived metric 不相容。 |
| complete immutable formal image | 已关闭 | 9 changed + 23 unchanged 构成32表 base，11 changed/new + 23 unchanged 构成34表 post；operation builder不再读取 phase-dependent live base。 |
| chip allowed set | 未关闭 | 35+2 路径和13/19列 projection已经明确，但 scope mapping被冻结为 pending且又被禁写；authorization还要求比较两个 manifest中不存在的字段。 |

## Blocker 1：bootstrap 的正例集合同时要求重复和不重复

v6 第 424 至 429 行要求同一个 `UnchangedItem` 在 `base_snapshot_items` 和 `postimage_candidate_items` 中各出现一次，而且七个 key逐字相同；第 480 行又要求三个 array 合并后 `(role,path)` 唯一。这两个条件不能同时成立。

以 `数据/components.csv` 为例，base和post中都必须出现：

```text
input_role         = managed_unchanged_snapshot
source_path        = T/inputs/unchanged/数据/components.csv
logical_target_path= 数据/components.csv
```

保留两项时，合并集合出现重复 `(role,path)`；删除 post 中的一项时，又破坏 58 项 post set以及 34-table post mirror。相同反例对全部23张 unchanged table成立。这里的正确算术是三个 array 共 `45 + 58 + 12 = 115` 个 membership，其中23项是刻意的跨 array复用；去重后有92个 item identity，再加 contract design、freeze archive、bootstrap manifest和approval，file input才是96。

Severity：`Blocker`。最小修复是把唯一性改成“每个 array 内 `(role,path)` 唯一”，并冻结：

```text
BaseItems ∩ PostItems = BuildTwentyThreeUnchangedItems()
BaseItems ∩ PatchItems = ∅
PostItems ∩ PatchItems = ∅
```

若一定要声明全局 membership 唯一，logical key必须包含 `array_name`。同时保留 file-input 对同一物理 unchanged snapshot只登记一次的规则，并增加一个 unchanged item 同时进入 base/post 的 positive fixture。

## Blocker 2：SemanticPath oracle 的数值是 rowset，不是 RowHash

v6 第 72 至 78 行把 `33b9...` 称为“row hash”，而 v3 已经把两个类型分开：`RowHash` 使用 `row-v1` 对单个 envelope framing；canonical table image使用 `rowset-v1` 对 `[envelope]` framing。我从当前 `数据/fields.csv` 第一条 data row重新构造两种 framing，结果如下：

| envelope table path | `row-v1` | singleton `rowset-v1` |
|---|---|---|
| `数据/fields.csv` | `c9332d894c520577a49b7479652139dc9f6de35df8591481bd25e7e1b9a4c10f` | `33b9c8872bb811fb91c3147df2c6c85f852ae63cf6be380e9f84b3a35de5eff2` |
| `T/inputs/base/数据/fields.csv` | `8db42271feef643745b699bb303622c09a2c22038c7415f370dd059fbea7aa2a` | `b43d5fe8867c74f0487df09b3f6fca35ac5763f27742126c6d7c0ac3df1860c6` |
| `T/inputs/post/数据/fields.csv` | `d605741c1806deb881fa6631bc72d401cc1b8a444503db4cbb9557ffaf8bd91d` | `d43f156813cf3b382a603af19fb6ef460883435b9276ef6f055d15a97212b81a` |

v6 给出的三个值全部是 singleton rowset，数值没有算错，类型标签错了。执行器若服从“RowHash”，会生成第一列；若服从 literal hash和第78行的“rowset”，会生成第二列。

Severity：`Blocker`。最小修复是把该 fixture逐字命名为 `singleton canonical rowset`，固定 `domain=rowset-v1`、payload=`[envelope]`。若合同还需要单行 `RowHash` oracle，应另列 `row-v1` 的三个值，不能让一个 hash同时承担两种 domain。

## Blocker 3：release-date 的冻结目标已偏离 R13

R13 已要求后续迁移使用以下 byte-exact 定义：

```text
厂商或设计方在具日期、可核验的正式材料中首次直接命名/宣布该研究对象；不能用上位架构预告、下位产品发布、availability/shipping/sales 替代
```

v6 第 162、179 行却改成：

```text
厂商/官方来源首次公开且直接命名具体研究对象的日期
```

短句漏掉了设计方、具日期且可核验的正式材料、“宣布”，以及上位架构、下位产品、availability、shipping和sales五类禁止替代项；后句还把合格载体进一步缩为“官方页面”。两个 UTF-8 cell分别是188和73 bytes，无法得到相同 policy hash，也会对 MI350P article、设计方材料和下位产品日期产生不同裁决。

当前正式5条 fact和6条 requirement，v6 第 181 至 205 行的 ID全集均独立复算正确；本事务把它们保持 unchanged、让 GA100 requirement继续 `pending_verification` 的决策也是正确的。问题只在 v6 声称冻结的 target semantics已经发生漂移，并且没有冻结 R13 输入。

Severity：`Blocker`。最小修复是把 R13 的路径和上述 SHA-256加入规范继承与冻结输入，`target_definition` 逐字采用 R13 定义，并删除后文对“官方页面”的无依据收窄。5+6 set-equal和 `deferred_blocking` 保持不变，release-date 对本事务计数仍是 `+0`。

## Blocker 4：formula spec 与现有24条 derived metric不能同时通过

v6 第 543、553 行规定 text output 的 `output_unit=null`，并把 `FORMULA-STRUCTURAL-PROJECTION` 冻结为 text输出、null unit。当前正式 `数据/derived-metrics.csv` 却有：

```text
derived_metric_id = DERMET-NVIDIA-H100-REG-POOLING-MODE
formula_id        = FORMULA-STRUCTURAL-PROJECTION
output_unit       = enum:pooling_mode
```

该表的 `output_unit` 在 `schema-columns.csv` 中是 `is_nullable=false`。对应 field `FIELD-MEM-POOLING-MODE` 是 enum，`value_enum_name=pooling_mode`、`canonical_unit`为空；对应 fact `FACT-NVIDIA-H100-REG-POOLING-MODE` 的值为 `distributed_not_pooled`、`normalized_unit`为空。v3 第480行又要求 `derived-metrics.output_unit == fact.normalized_unit`。因此当前行已经不满足继承门；v6 同时把 `derived-metrics.csv`、`facts.csv` 和schema都放在23张 unchanged里，没有任何 operation可修它。

我按当前47条 derived input复算了24条 derived metric。五个现有 formula ID及其行数为 `CORE-X8=11`、`COMPUTE-DIV-MEMBW=7`、`TRN2-COMPUTE-DIV-HBM-BW=4`、`STRUCTURAL-PROJECTION=1`、`MATRIX-DIV-VECTOR=1`；23条 numeric结果和 field/unit输入均可与 v6 spec相容，只有上述 structural text row发生 unit合同冲突。

Severity：`Blocker`。若不改正式表，最小修复是为 enum/text输出写出单独规则：formula spec 的 output descriptor和 `derived-metrics.output_unit` 必须等于 `enum:<fields.value_enum_name>`，而 enum fact 的 `normalized_unit` 继续为空；相应移除旧的无条件 `output_unit == normalized_unit`，并给当前 structural projection一个 positive fixture。若坚持 text output必须 null，则 `derived-metrics.csv`、`facts.csv` 与相关schema不能再算 unchanged，必须授权操作并重算 table image、snapshot和事务计数。

## Blocker 5：GA100 scope 永远停在 pending，forced object也缺少 phase-aware FK

contract migration 按 v6 第136行只创建 GA100 seq=1 的 `pending_formal_object_create/needs_resolution` mapping。v3 第144至153行明确说 pending不能成为有效映射；更高的未 rejected pending还会阻止沿用旧 mapping。v3 的 ChipScope/coverage gate随后要求 latest approved unblocked mapping、`mapping.formal_object_id == card_object_id`，并要求 object、identity和scope相等。

chip 的35个固定 base pair又把 `scope-object-mapping.csv` 列为 `scope_mapping_registry`；v6 第739行禁止28个 T 外 fixed live input与 operation/payload target相交。于是 chip即使插入 `OBJ-NVIDIA-GA100-DIE`，也不能追加 seq=2 的 `mapped/approved` event。可构造状态是：object和identity已存在，mapping仍是 seq=1 pending；此时 mapping gate必然失败，coverage manifest、chip authorization和完成态都无法闭合。

同一 phase问题还出现在 coverage policy。contract migration发布 policy时，`ga100_forced_object_include_rules` 的六项已经写入尚不存在的 `OBJ-NVIDIA-GA100-DIE`。v6 第278行只说 nested FK继承旧合同，没有说明该新数组可使用哪一种 deferred FK，也没有冻结 later-resolution gate。严格 current-FK实现会在 contract base拒绝 policy；宽松实现会接受任意未来字符串。六项 set-equal能固定值，却不能代替引用时序和对象存在性规则。

Severity：`Blocker`。v7 需要选择一条完整路径：

1. 在 chip coverage之前增加独立 identity事务，创建 GA100 object/identity并追加 seq=2 `mapped/approved`；或
2. 从 fixed-live集合移除 `scope_mapping_registry`，给它增加精确 base/post snapshot，并在 chip authorization中只允许一条 seq=2 append。

第二种方案会把固定35项中的一个 live pair删除、增加两个 snapshot pair，因此 chip base从35变成36，连同两个 authorization input后实际 required set从37变成38；相关 `28 T外` 也要改成27。无论选哪条，policy阶段都应只允许这一项 forward ID，并冻结：

```text
forced.target_id
  == ga100_mandatory_policy.card_object_id
  == pending_mapping.proposed_formal_object_id
```

chip coverage前再强制该 ID已存在，并且 latest mapping为同scope的 `mapped/approved`。不能把“forward declaration”留成实现约定。

## Blocker 6：authorization 要求比较对方 manifest 中不存在的字段

v6 第685行要求 authorization 的 `transaction/work-package/scope/card` 与 coverage manifest和 transaction manifest都逐字一致。继承的58-key coverage manifest有 `work_package_id`、`scope_id`、`card_object_id`，没有 `transaction_id`；transaction manifest有 `transaction_id`，却没有另外三个 key。字面执行“与两者都一致”不可能成功。

一个实现可能只比较交集字段，另一个实现会因缺 key fail closed；合同没有授权第一种解释。19列 payload projection和13列 operation projection本身已经闭合，这个 blocker位于顶层身份绑定，不否定两个 array的 set-equal设计。

Severity：`Blocker`。最小修复是把关系逐项写成：

```text
authorization.transaction_id
  == transaction_manifest.transaction_id

authorization.(work_package_id,scope_id,card_object_id)
  == coverage_manifest.(work_package_id,scope_id,card_object_id)
```

若确实要求 transaction manifest也直接绑定后三项，就必须显式增加 key、更新 exact schema/domain/oracle和所有引用 hash，不能用自然语言补出不存在的列。

## Blocker 7：声明的“唯一拓扑层”包含真实的同层依赖

v6 第862至878行把 candidate formula bytes和 managed patches都放在 L1；第598、606行的 formula patch又必须写入 formula candidate 的 source path与 `postimage_raw_sha256`。真实 hash edge因此是：

```text
candidate formula bytes -> formula managed patch
```

有边的两个节点不能同时属于严格拓扑层。当前图按实际引用边复算没有发现必然循环，但“唯一拓扑层”与实际边不一致，会使按声明层生成的实现和按引用边排序的实现产生不同构建顺序。

Severity：`Blocker`。最小修复是保留 candidate bytes在 L1，把 managed patches移到 L2，再顺延需要保持先后关系的层；也可以细分为 `L1 candidates / L2 patches` 后重排批准与bootstrap。修复后应以每条实际 hash引用边验证 `level(parent) < level(child)`，不能只做节点数检查。

## 其余独立复算结果

四个 v6 新 oracle均从 exact schema、synthetic values、canonical JSON和 `domain || 00 || uint64be(length) || payload` framing重新构造；没有直接拿作者的 hex再做 hash。四项 payload bytes、SHA-256和全文 hex都与 v6逐字相同：

| oracle | payload bytes | SHA-256 |
|---|---:|---|
| source-pool prerequisite | 2,089 | `9244b827d4db311bd4a5d9c3f17c74be853472c0f2d52fdae04b85d130bb492f` |
| bootstrap manifest | 750 | `b8f1c8bc65f580091e2031833e30fbd77c141c957280e3ce9ed0bcda84e6283e` |
| formula evaluator | 835 | `122f80043c705bfc3f34ea662298cdde4e7f283f3952079375dd5b4edb9cac76` |
| managed patch | 709 | `1d7bcce0fc415fa8175ecdb5f0eb839e421f329f2a360ab4822a3f786beaf733` |

freeze archive实测55,224 bytes、24列、77行、49条 `counts_toward_chip_completion=true`，`freeze_row_id`非空且唯一；文件带UTF-8 BOM，record separator为64个CRLF和14个LF-only、没有bare CR。v6 的 raw hash `df171b83b1be7dd747e9c78f5417ce8347c4bfcf70c31cb77f39699f44ef41ea` 正确。把它设为 raw-only并要求 canonical两键为空，已经排除了 v5 的多PK、多domain分叉。

49个活动名单 constructor与归档49条计数行逐行、逐集合都能双射，`FREEZE-NV-001 -> SCOPE-0001` 成立。formal join只读 archive existing ID后，机械分类确为 `9 mapped + 1 GH100 pending_identity_review + 1 GA100 pending_formal_object_create + 38 unmapped`。这一 builder本身通过；Blocker 5针对后续 GA100 pending状态没有合法出口。

contract migration的集合算术也通过：

```text
base/post/patch memberships = 45 / 58 / 12
unique file inputs          = 96
input_role enum tokens      = 46
table images / payloads     = 11 / 24
managed targets             = 35
restore / delete_created    = 20 / 15
stable artifacts            = 13
```

23张 unchanged table恰好是32表减去9张 changed table的补集，没有遗漏或重叠。旧的94、43、44只出现在历史比较、旧稿说明或 negative fixture中，没有再被当作 v6 active contract count。所有列出的相对路径均通过 lexical safety检查；当前主线相关目录未发现 symlink。

source-pool-113 的唯一前置顺序和边界正确。v6 引用的 `operations.csv`、Test-SourcePool candidate、manifest、summary、collector、ledger和 frozen source hashes均与 staging实物相同，post validator基准确为 `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0`。当前 live仍是 pre-promotion状态，controlled input目录和 promotion records不存在，所以 prerequisite尚未满足；v6没有把 staging验收冒充正式推广。promotion record保持 audit-only raw输入，两个 prerequisite logical path/domain也唯一。

coverage-policy-v5的22个顶层 key、两个新 nested object的位置、forced reason code `card_scope_requirement`、四值tuple排序和六行 set-equal都可机械实现。六个 GA100 benchmark pair与三个 Ampere architecture pair均被强制 include，没有被已有 GA100 field结果折叠。`FIELD-PHY-DIE-COUNT` 的 normal structural N/A与原六个 mandatory N/A分开，die/package predicate方向正确。source actual-row family singleton、actual endpoint、reverse-removal、六个 mandatory N/A四键、108个 mandatory key和58-key coverage manifest均保留了继承门。

chip固定 pair独立计数为35，另加 authorization与其approval后 required input为37；authorization的 operation item确为13列投影，payload item确为20列去掉 `transaction_id` 后的19列。35+2算术和双向 allowed-set公式本身没有缺项，不能用它们掩盖 Blocker 5和6。

## 最小修订后的复验门

v7 至少要同时满足以下条件，才值得重新提交设计验收：

| 修复面 | 复验条件 |
|---|---|
| bootstrap membership | base/post各自唯一，交集恰为23个 unchanged，file-input仍只登记一次；positive manifest可实际构造。 |
| canonical fixture | row-v1和singleton rowset-v1分开命名、分开domain、分开oracle。 |
| release-date | 冻结R13及其hash，target definition逐字一致；5+6继续deferred且正式表不变。 |
| formula | 24条当前 derived metric全部通过 field、input unit、output descriptor和fact unit门；structural enum有专门fixture。 |
| GA100 identity | object、identity、seq=2 mapped/approved与coverage之间存在唯一合法事务路径；forced object forward FK有明确phase gate。 |
| authorization | transaction只对 transaction manifest比较；work-package/scope/card只对 coverage manifest比较，或显式扩展schema。 |
| hash DAG | 每条实际 hash edge严格跨层向前，formula candidate先于formula patch。 |

这些补丁会改变 policy、bootstrap、patch、approval、authorization和transaction相关 canonical hash；若采用“chip内更新 mapping”的方案，还会把 chip base/required input从35/37改为36/38。其他已经通过的正式 `34/376/141/77/564`、contract `11/24/35/20/15/13` 和source-pool `45/58/12/96/46` 不应无故漂移。

## 运行环境与交付自检

本机使用 Python 3.9.6完成 CSV、JSON、bytes、framing、SHA-256、集合和路径复算。`pwsh`、`powershell`、`powershell.exe` 均不存在，因此没有执行 PowerShell 5.1或PowerShell 7，也没有把 Python结果表述为“三运行时通过”。这是 `runtime limitation`，不是 sandbox denial、approval failure、远端服务错误或模型能力限制。一次文本搜索最初误用了当前 `rg` 默认模式不支持的 lookbehind，随即改用 PCRE2重跑成功；该事件属于 operator command-syntax mistake，没有降低审计范围或结论可信度。

本报告只新增当前文件。成稿已按 `report-humanizer` 对单文件执行机器扫描，并人工复读标题、各节首段、表格引导、反例、修复条件和结尾；最后再按末段到首段逆序核对 PK、数字、hash、状态与结论。设计结论仍为 `reject`：当前问题修完前，不得执行 contract migration，也不能把 source-pool staging、未运行的Windows门或 GA100 chip package称为已发布。
