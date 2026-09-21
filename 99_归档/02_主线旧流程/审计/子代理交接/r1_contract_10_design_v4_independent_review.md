# R1 冻结合同 v4 独立设计验收

## 结论

`reject`

v4 已经修复 R08、R09 的大部分字节合同、logical key、managed-state 和 latency mapping 问题，七组 golden serialization fixture 与 managed-state oracle 也能独立复现。不过，当前基线到 contract postimage 的执行链仍有五个可构造反例。它们会让 contract migration 无法覆盖活动 scope 变更、让 chip transaction 必败、破坏 apply 后重放、令 authority 最低来源门读取不存在的字段，或使 mandatory structural N/A 集合没有唯一机器表示。这些是冻结设计 blocker，不应留给实现阶段自行解释。

## 冻结输入与正式基线

v4 设计稿实测 SHA-256 为 `4771e201f404699f41f486fa85adba8609e9c5c5797632fb52f99ededce9b349`，共 818 行。它引用的 v3、R08、R09 SHA 分别实测为 `f590a98ec29f3202c3d2eb3801f5fcddf165fd31bd5c86f2d778b797e0276cf8`、`161cfc6142b6b84b823fa65ec4c7d5476bf2601d9073ca4ef9462abf89c27a07` 和 `37bcc1243862d2c7540c05caff323d10d0d1da12246d33a556623707ba553f69`，均与 v4 声明一致。

当前正式基线仍是 32 张表、346 个 schema column、141 个唯一 field、76 个 enum group、557 个 enum row、832 条 assertion、78 个 object 和 585 条 completeness；32 张 CSV 的磁盘表头与 schema 注册列序没有不一致。目标算术独立复算为：

```text
32 + 2 = 34 tables
346 + 4 + 20 + 5 + 1 = 376 schema columns
141 - 1 + 1 = 141 fields
76 + 1 = 77 enum groups
557 - 1 + 5 + 1 + 2 = 564 enum rows
```

`rounding_mode` 当前有 5 行，追加 ordinal 6 的 `rtn` 和 ordinal 7 的 `rtp` 后与 564 行公式一致。v3 coverage manifest 的 key 数重新计数仍是 58。v4 的 `input_role` 为 36 个唯一 token，`input_kind` 为 17 个唯一 token；contract migration 的 role/path 集为 27 个共享项加 11 个 patch，共 38 项，chip transaction 为 27 个共享项加 formula evaluator 和 8 个 coverage 项，共 36 项。

当前恢复校验器实跑通过：32 张正式表、153 个 endpoint、79 个本地路径和 hash、11 个 selection run、106 个 member 均可恢复。该结果只说明当前基线可读，不代表 v4 postimage 或 Windows 数据门通过。

## Golden bytes 独立复算

没有使用报告给出的 hex 反推 payload。复算器从 v4 写明的 domain、exact-key JSON 和 framing `domain || NUL || UINT64_BE(length) || payload` 独立生成 bytes，再分别与报告的 hex 和 SHA-256 比较。七项全部逐字相等：

| fixture | payload bytes | 独立 SHA-256 | hex/hash |
|---|---:|---|---|
| `FIX-V4-LEGACY-SCHEMA` | 215 | `1132463f16e07cceaac5d8876cc0d8666f5b099a776544078ff126bce572815d` | PASS |
| `FIX-V4-ACTIVE-SCOPE-SCHEMA` | 236 | `a7bd302d5cca32a144a188837b378492e466dab78d01bc3f5eed39e41aec4c1a` | PASS |
| `FIX-V4-FIELD-PAIR` | 67 | `a042e11a61d9c1ac288b7a1d65b8bba4a0f6e48b9c41d175a143ef51d58d42ed` | PASS |
| `FIX-V4-FACTOR-OBLIGATION` | 74 | `8df2bf10b2f34955b0edf1cdd1301caf83bfa6229fb98820fe7ecff5364f3210` | PASS |
| `FIX-V4-FACTOR-PAIR` | 121 | `b53f50f0de8609b187818d070b0849b9751606a7cf3eacb0d9944199fcc31b5f` | PASS |
| `FIX-V4-MANDATORY-KEY` | 77 | `61e7f5b8452a31d29a46cd0730f4cbe22b3e079eb462ec2b321b9204105492ed` | PASS |
| `FIX-V4-JOURNAL-SCHEMA` | 273 | `721ac5e607cce9b5bac57980cdf4d29cdb10e98b3a6a8499a9505ccef2d02894` | PASS |

`managed-state-rowset-v2` 的 raw-payload positive oracle 也通过：payload 为 174 bytes，framed hex逐字相等，SHA-256 为 `21511e5bb126fb4cd5f3e7abdd98eb63aeb21e47d8a661de79cf36b07333d497`。这些 oracle 只含 strict JSON、UTF-8、big-endian length 和 SHA-256，PowerShell 5.1、PowerShell 7 与 Python 3 均可实现；当前机器没有 PowerShell runtime，所以本次只能证明报告中的 bytes/hash 自洽，不能代替三运行时结果文件。

## R08/R09 crosswalk 复算

| 原审计项 | v4 独立判断 |
|---|---|
| R08 virtual/schema canonical bytes | 核心修复通过。三个 schema、四类 synthetic set均有 domain、key、排序、nullable、framing和显式 recompute；七个 oracle全部独立复算通过。 |
| R08 input enum、role/path set、safe path | enum、集合和 path grammar 本身通过；但活动名单漏出 managed target，且可变 live path 的单 hash 无法跨 fresh/apply/no-op，仍有 blocker 1、3。 |
| R09 A absent→present table image | 15-column image、nullable matrix、delete-created和 rollback漂移门通过；但 creation gate放在 transaction-kind分支外，导致 chip transaction必败，见 blocker 2。 |
| R09 B factor/candidate exactly-one 与 package ownership | 通过。obligation triple、candidate/binding logical key、projected pair、141 field row及五张 CSV 的 package归属均有 exactly-one 门。 |
| R09 C managed canonical 与 path overlap | 通过。target kind、raw/canonical nullable matrix、table/payload disjoint union、rollback set-equal和 managed-state-v2 oracle闭合。 |
| R09 D instruction/memory mapping | 通过。列到 JSON key、nullable、enum exact-equal、operation count默认空、source-text配对及 clock门均可执行。 |

## Blocker 1：活动名单和 scope bootstrap 没有完整事务

当前 `清单/训练与推理芯片名单.md` 的正式表实测只有六列：`厂商,芯片对象,层级,角色,共享设计组,一手身份来源`，共有 49 个数据行。v3/v4 postimage schema 则固定为七列，并把 `scope_id` 放在第一列。因此 contract migration 必须把这份 Markdown 从六列改为七列，并为 49 行写入 scope ID。

v4 的 role/path universe 只把活动名单列为 `active_scope_list` file input。`BuildElevenMigrationPayloadTargetsV4()` 的 11 个 non-table target 是 formula evaluator、四个 validator/恢复脚本和六份模板/项目文档，不含活动名单；迁移 action universe 第 7 项还明确说 approved scope 只作 file input、禁止进入 managed target。结果只有两种：名单保持六列时，active-scope schema、49 active allocation set-equal 和 postimage gate失败；在事务外先改成七列时，没有 preimage、input、postimage、rollback或 crash recovery，file-input raw hash也失去明确基线。

scope bootstrap 还存在同一原子性缺口。当前根下连 `审计/合同注册表/` 目录都不存在，`scope-id-registry.csv` 与 `scope-object-mapping.csv` 也不存在；v4 却把二者列为 contract migration 的 required shared input，并在第一步要求先生成 active allocation/mapping。allocation row绑定七列活动名单行 hash。若先生成 49 个 active/approved scope registry 而名单仍是六列，base state不满足 scope gate；若名单先在事务外改写，formal migration rollback又不能恢复 scope组合状态。两者没有一个受控原子切换点。

同目录下的 coverage/source-date policy及批准、legacy disposition及批准/reconciliation registry、canonical fixture manifest/fixtures/runtime results目前也全部 absent。它们可以设计成迁移后仍长期保留的稳定 prerequisite，不必随正式数据 rollback；但 v4 只写“先独立生成并批准”，没有给首次 absent→present 的 bootstrap transaction或等价的原子发布/恢复协议。scope文件因与活动名单强耦合已经构成必然失败，其余 prerequisite至少需要明确由哪一个完整 bootstrap过程首次创建，不能把缺失文件直接当作已批准 base input。

最小修复是把活动名单的六列→七列 update纳入 contract migration payload inventory，使用 raw-only present→present image和 restore rollback；scope allocation/mapping则在同一事务中以 absent→present table/registry image创建，或由一个先行 `contract_bootstrap` 事务创建为非 active状态，再由 contract migration原子激活。两条路线都必须保证 fresh、applied、rollback三个状态下，名单、allocation和mapping的集合门分别成立。其他 prerequisite要么纳入独立 bootstrap transaction，要么补充同等强度的 absent preimage、签字发布、崩溃恢复和不可变批准协议。

## Blocker 2：chip transaction 被强制再次创建 factor 表

`ValidateTransactionV4` 第 676 至 678 行只在 `transaction_kind == contract_migration` 时检查 migration payload与 operation universe；但第 679 至 682 行对两张 factor table 的 `ExactlyOneAbsentToPresentDeleteCreatedImage` 位于 `if` 之外。因此同一 validator 对 `chip_work_package` 也要求 `数据/factor-requirements.csv` 和 `数据/factor-target-bindings.csv` 各有一条 absent→present image。

合法执行顺序中，两张表已经由 contract migration创建。chip transaction看到的 preimage必然是 present；若照伪代码声明 absent，preflight因文件存在失败；若声明 present→present，又不满足 unconditional creation gate。这个反例与数据内容无关，任何 chip工作包都会失败。

最小修复是把两条 factor-table creation gate移入 `contract_migration` 分支。`chip_work_package` 应从自身 operation set独立构造真实 table-image universe，要求两张基础表在 base中 present，并只在该 package确有 row insert/update/delete时生成 present→present image；不得重复创建合同基础表。positive fixture需分别覆盖 migration create与后续 chip update。

## Blocker 3：可变 live file-input 的单 hash 无法支持重放

contract migration 的 required file inputs把 `数据/schema-columns.csv`、`数据/enums.csv`、`数据/fields.csv`、四个 validator/恢复脚本、模板、字段字典、README、AGENTS、研究计划和当前状态都指向项目中的 live target path；同一事务又会更新这些路径。`transaction-file-inputs.csv` 对每个 path只有一个必填 raw hash，并要求 file input先做 raw/canonical自校验，没有 phase或 pre/post双值。

若该 hash绑定 fresh preimage，第一次 preflight可以通过，但 apply后同一路径已经变成postimage，再调用 `ValidateTransactionV4` 进入 `SUCCESS_NOOP`、roll-forward或 rollback前置校验时会因 file-input hash不符而失败。若 hash绑定postimage，fresh preflight立即失败。把 hash只当CSV中的自报值也不成立，因为 v4明确要求从 relative path重算输入，且 transaction manifest的可信性依赖这一步。

最小修复是把可变 target的输入绑定到 `T/inputs/base/...` 下的 immutable preimage snapshot，live target只由 table image/payload/rollback inventory观察；或者为 file input增加明确的 phase-aware preimage/postimage hash和状态矩阵，并规定每个状态机分支读取哪一个值。fresh apply、apply中断、完整postimage no-op和rollback no-op都要有同一 transaction目录的重放 fixture。活动名单纳入 managed target后也必须遵守这条规则。

## Blocker 4：minimum authority 读取了不存在的 family 字段

v4 先按 `source_family_id` 去重 qualifying source，再要求 authority维度使用“source family 的正式 authority”。当前 `source-families.csv` 的七列是 `source_family_id,canonical_title,family_kind,publisher_or_organization,persistent_work_id,review_status,notes`，没有 authority；正式 authority只存在于 `sources.csv.source_authority`。因此 validator没有可读取的 `family.authority`。

当前 93 个 source version中，同一 family暂未出现多个不同 authority或 source_type，这只是当前数据偶然满足 singleton，不是合同约束。未来同 family多版本 authority不一致时，一个实现可以取第一条，另一个可以取并集、最高权威或直接失败，`all/any` 会给出不同结论。现有文本也没有说明同一 family能否用不同 source version同时满足多个 type token。

最小修复是从通过 actual endpoint、locator、cutoff和selection门的实际 `sources.csv` row开始，按 family分组后规定归约：每个 family的 qualifying source rows在 authority与source_type上必须各自 singleton，否则 fail closed；随后以该唯一值参与 all/any。若需要一个 family拥有多种 type/authority，就应明确集合语义和“一 family只算一次”如何作用。另一条路线是在 source-families schema中新增 authority并完整回填，但这会改变376-column合同，必须同步重算迁移计数和全部hash。

## Blocker 5：mandatory structural N/A 的 expected rule没有唯一四键集合

v4 第 52 至 58 行列出的六条允许项都是三元组 `(field_id,precision_path_id,reason_code)`。第 61 行随即把 `mandatory_structural_na_rules` item定义为四个 exact key：`field_id,precision_path_id,reason_code,structural_na_predicate_id`，并要求与“上述六行 set-equal”。三元组集合与四键 object集合无法直接 set-equal，六行也没有给出六个 `structural_na_predicate_id` 的固定值或从 reason code到predicate ID的构造规则。

其余 proof门方向正确：六格仍为 mandatory include，requirement状态为not_applicable，applicability JSON绑定 reason、instruction/datatype语义和 requirement evidence，evidence再绑定 actual endpoint、locator与独立reviewer。但机器在进入这些门之前，无法唯一构造 policy中应有的四键rule set；实现可以让 predicate ID等于 reason code、使用任意approved structural predicate，或只对前三键投影set-equal，三种实现都与现有文字相容。

最小修复是列出六个完整 exact-key JSON object，明确每条 `structural_na_predicate_id`；或者明确写成 `Project(field_id,precision_path_id,reason_code) == SixAllowedTriples`，同时单独要求每条 predicate ID唯一、FK有效、scope为structural_na并命中冻结的exact evaluator。若目标是“独立语义证明”，还需冻结四个 predicate语义或可执行clause，而不是只写“从exact datatype/instruction semantics复算”。fixture应覆盖错predicate ID、reason/predicate交叉配对和前三键正确但第四键悬空。

## 其余重点项

除上述 blocker外，以下设计在文本层可进入实现：normal field selector按card selector、exact-one mandatory target selector和exact-one exclude selector机械派生，108 mandatory始终include并引用exact-one requirement；factor obligation、target candidate、binding和zero-included field均有全集门；rtn/rtp及PTX `.rm/.rp`映射、832条AFPV2逐行迁移、latency unit/mapping、actual endpoint与canonical locator、cutoff/date policy、source-family去重、derived DAG、managed-state disjoint union、delete-created rollback、mixed-state roll-forward、58-key manifest和单向approval DAG均有明确约束。factor最低来源的`none/all/any`定义本身也清楚，修复family authority归约后即可执行。

这些“可进入实现”判断只覆盖设计文字，不代表fixture、transaction或Windows门已经运行。尤其完整factor-table transaction fixture尚待三个runtime实际生成，不能用本次八个小型oracle代替。

## 失败与验收边界

当前环境没有 `pwsh`、`powershell` 或 `powershell.exe`，所以无法执行PowerShell 5.1/7 fixture或现状Windows gate；这是runtime缺失，不是sandbox、approval或远端服务错误。一次读取`condition-sets`及相关设计区段的命令输出因工具上限被截断，随后改用定向header、enum和行号查询补齐，未依赖被截断尾部。除此之外没有用户中断、sandbox denial、approval failure、remote service error或操作者错误。

本次 `reject` 只要求修复上述五个blocker。即使修订版通过独立设计验收，也只表示可以进入审计区实现，不代表contract migration、GA100工作包、PowerShell三运行时fixture或Windows数据门通过。
