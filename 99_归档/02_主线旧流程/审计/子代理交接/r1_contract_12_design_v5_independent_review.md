# R1 冻结合同 v5 独立设计验收

## 结论

`reject`

v5 已经把 R10 的五个直接问题修到正确方向：首次发布纳入 contract migration，活动名单、allocation、mapping 与 13 个稳定 artifact 共用一套恢复状态；factor table 的创建门移入 migration 分支；minimum-source 改从 actual `sources.csv` row 归约；六个 mandatory N/A rule 与四个 predicate 也有了完整对象。独立复算确认，正式 postimage 算术、71 个 file input、35 个 managed target 及回滚数量都没有写错。

当前仍不能冻结。可构造的反例集中在六处：snapshot 的 canonical 身份、freeze archive 的 hash 语义、scope builder 的 exact bytes、三个新 JSON 输入的字节合同、跨 phase 的 base image，以及 chip package 的授权全集。这些缺口会让两个实现对同一事务得到不同 hash、不同 scope 映射或不同 allowed target set，不能留给实现者自行选择。

## 冻结输入与当前基线

五个继承输入的 SHA-256 均与 v5 第 11 至 15 行相同：

| 输入 | 独立实测 SHA-256 |
|---|---|
| `r1_ga100_19_contract_repair_design_v3.md` | `f590a98ec29f3202c3d2eb3801f5fcddf165fd31bd5c86f2d778b797e0276cf8` |
| `r1_contract_08_design_v3_independent_review.md` | `161cfc6142b6b84b823fa65ec4c7d5476bf2601d9073ca4ef9462abf89c27a07` |
| `r1_contract_09_design_v3_additional_redteam.md` | `37bcc1243862d2c7540c05caff323d10d0d1da12246d33a556623707ba553f69` |
| `r1_ga100_26_contract_repair_design_v4.md` | `4771e201f404699f41f486fa85adba8609e9c5c5797632fb52f99ededce9b349` |
| `r1_contract_10_design_v4_independent_review.md` | `afad0d0ce892b130cd1846b8ba713f966ba9cd9051372a213a8bd9565dde5e34` |

被审 v5 文件实测为 553 行，SHA-256 为 `067cde50421c8108be1b6407f18d68ab650369803b74a295c4da285052534c5e`。当前 32 个正式 `table_path` 与 346 条 schema row 均可解析，32 张 CSV 的表头与 schema ordinal 全部一致；其余基线为 141 个 field、76 个 enum group、557 个 enum row、78 个 object、585 条 completeness 和 832 条 assertion。活动名单仍是六列、49 行。13 个 stable target、两张 factor table 和整个 `审计/合同注册表/` 当前均不存在，符合 fresh base 的 absent 声明。

正式 postimage 算术独立复算如下，未发现漂移：

```text
tables          32 + 2                         = 34
schema columns  346 + 4 + 20 + 5 + 1          = 376
fields          141 - 1 + 1                   = 141
enum groups     76 + 1                        = 77
enum rows       557 - 1 + 5 + 1 + 2           = 564
```

v4 的七个 golden serialization oracle 和 `managed-state-rowset-v2` oracle 已用 Python 3 从 domain、payload 和 framing 独立重建，八项 SHA-256 全部与冻结值相同。本机只有 Python 3.9.6，没有 `pwsh`、`powershell` 或 `powershell.exe`；因此本次不能运行 PowerShell 5.1/7，也没有把 Python 复算写成“三运行时通过”。这是 runtime limitation，不是 sandbox denial、approval failure 或远端服务错误。

## 已经闭合的项目

按 v5 明列路径展开后，file input 为 `1 + 1 + 2 + 13 + 20 + 22 + 12 = 71`，71 个 `(role,path)` 和 71 个 path 均唯一。11 个 table image 与 24 个 payload target 互斥，并集为 35；其中 9 张既有表加 11 个既有 payload 共 20 个 `restore`，2 张 factor table 加 13 个 stable artifact 共 15 个 `delete_created`。列出的静态路径均通过词法安全检查，现有 ancestor 中也没有 symlink。

13 个 role 到 candidate path、stable target 的映射是一一对应，现状也确实是 13 项全 absent。factor table 的 absent→present 检查只出现在 `contract_migration` 分支；chip image set 等于 `Distinct(operations.table_path)`，这两处修复可以保留。

scope 状态拓扑本身也闭合：fresh 是六列名单加两个 absent registry，applying/rollback mixed 都限制为每个目标自身的双状态，applied 是七列加49 allocation和49 mapping，两个 no-op均要求相同 manifest 的 journal成功事件。活动名单和两个 registry都已进入同一35-target managed-state，不再存在 v4 那种事务外先改其中一项的合法路径。后续 blocker针对的是 builder与hash输入，不否定这套状态矩阵。

minimum-source 的 actual-row 算法也可执行。当前 93 条 source row 属于 92 个 family，唯一的多版本 family 在 `source_type` 与 `source_authority` 上都分别 singleton；93 行没有空 type/authority，所有值都命中正式 enum。六个 N/A rule 的四键均唯一，引用四个唯一 predicate；`precision-paths.csv` 中存在 `precision_path_id` 与 `operation_class` 两列，`equals/in` clause 有可读取的正式字段。核心批准方向没有发现必然自环：candidate approval 先于 bootstrap，rollback 不引用 transaction manifest，transaction manifest 也不引用 transaction approval。

## Blocker 1：snapshot 的 semantic path 没有进入 canonical 合同

v3 第 448 至 468 行把 `table_path` 写入 `research-csv-row-v1` envelope。v5 第 59 行只规定 13 个 candidate controlled CSV 使用 stable target 作为 `table_path`；第 153 至 187 行对 20 个 base snapshot 和 22 个 post snapshot只给出物理路径。bootstrap item 虽有 `logical_target_path`，却没有规定 snapshot envelope 必须使用该值。

反例只需移动同一行 bytes。取当前 `数据/fields.csv` 第一行，使用相同列、PK、`rowset-v1` framing，仅改变 envelope 的 `table_path`，得到：

```text
数据/fields.csv
  33b9c8872bb811fb91c3147df2c6c85f852ae63cf6be380e9f84b3a35de5eff2

审计/事务/TX-TEST/inputs/base/数据/fields.csv
  b43d5fe8867c74f0487df09b3f6fca35ac5763f27742126c6d7c0ac3df1860c6

审计/事务/TX-TEST/inputs/post/数据/fields.csv
  d43f156813cf3b382a603af19fb6ef460883435b9276ef6f055d15a97212b81a
```

三个结果都能由 v3 的通用 envelope 算法生成，只有第一项能与 live table image 的 canonical hash共享身份。抽象调用 `ValidateEveryExistingTargetAgainstBaseAndPostSnapshots()` 不能替代缺失的字节规则。

Severity：`Blocker`。v6 应统一定义 `SemanticPath(item)=item.logical_target_path`，并明确 `BaseItem(p)` 与 `PostItem(p)` 的 `logical_target_path=p`；candidate 同样用 stable target。每个 base/post canonical hash还应与相应 table image 的 pre/post canonical hash逐项相等。三运行时 fixture 要覆盖“相同 CSV bytes、不同物理 source path、相同 logical target 得到相同 canonical hash”和“误用 T path 被拒绝”。

## Blocker 2：freeze archive 的 canonical 值无法复算

v5 第 232 行要求 transaction file-input manifest 单向绑定 freeze archive 的 raw/canonical hash，却没有把 `scope_freeze_archive` 定义为 raw-only，也没有冻结它的 schema、PK、sort key、domain 或 envelope path。该 CSV 不在 32 张正式表的 schema registry 中。

当前归档实测为 24 列、77 行，其中 49 行计数；raw SHA-256 为 `df171b83b1be7dd747e9c78f5417ce8347c4bfcf70c31cb77f39699f44ef41ea`。文件带 UTF-8 BOM，同时有 64 个 CRLF 和 14 个 LF-only record separator，不能直接冒充 v3 controlled writer 输出。即使宽容解析后再做 rowset，选 `freeze_row_id` 为 PK得到 `c3bea88dc2da8a7745144c2ce1a418f2dc9f47a6ea882a2caea455bb30f1f8b8`；选同样唯一的 `(vendor,canonical_chip_name)` 为 PK则得到 `7a65f156e1a83024b826d8da0e06dc39911d254ed688c200bc27ff2b520e1eda`。v5 没有规则排除其中任一实现。

Severity：`Blocker`。最小 v6 修复是把该 role 明确设为 raw-only，file-input 的 canonical domain/hash 两列为空，同时冻结现有 raw hash和 24 列 import schema；builder 严格解析唯一 `freeze_row_id`、小写 bool 和 `counts_toward_chip_completion=true`。若仍要 canonical hash，就必须完整给出 24 列类型、nullable、PK、sort、table path、domain 与 golden oracle。

## Blocker 3：49 行 scope builder 依赖未写出的映射函数

按当前数据和预期映射复算，freeze archive 的 49 个计数行与活动名单 49 行逐行、逐集合都能唯一对应；10 个非空 `existing_formal_object_id` 都存在，其中 9 个有 identity completeness，因而确实得到 `9 mapped + 1 GH100 pending identity + 1 GA100 pending create + 38 unmapped`。问题不在数据，而在 v5 第 120、135 行没有把这套复算写成唯一函数。

当前 49/49 成立所需的 cell bytes 是：

```text
die     -> 裸片（die）
package -> 单芯片封装（package）

include_main              -> 主样本
include_historical_anchor -> 历史锚点

shared_design_group = "`" + silicon_design_group + "`"
identity_source = "[" + official_source_title + "](" + official_source_url + ")"
```

v5 只写“层级映射”“角色映射”和“组成 Markdown link”。ASCII 括号、裸 design-group、`[title](<url>)` 都是可实现的自然语言解释，却会让当前 base 零匹配或部分匹配。formal-object join也未固定：按 archive 的 `existing_formal_object_id` 连接是 10 个 object、9 个 identity；按 `canonical_chip_name == objects.canonical_label` 只命中 3 个 object、2 个 identity。候选 mapping 所谓“49 个 exact row key”也未定义投影，v3 同时有 event ID PK 与 `(scope_id,mapping_event_seq)` unique key，pending approval status还允许两种值。

Severity：`Blocker`。v6 应逐字冻结四个 cell constructor，禁止 trim、Unicode/URL normalization；用六 cell tuple 与活动名单做双射，名单行序生成 `SCOPE-%04d`。formal join只允许 archive 的 `existing_formal_object_id`；GH100 proposed ID取该列，GA100 proposed ID固定继承 v3 的 `OBJ-NVIDIA-GA100-DIE`。独立 builder需要明列 allocation 与 mapping 的 semantic projection；任意 ID、reviewer、date、basis、notes可以由已批准 candidate 固定，但不能称为 builder 可独立生成的 exact row key。

## Blocker 4：新 canonical JSON 仍有自报空间

这组问题有三个独立入口，任一项都足以让 approval 绑定一个实现自选的 hash。

| artifact | 可构造分叉 | 最小 v6 修复 |
|---|---|---|
| `bootstrap-bundle-manifest.json` | v5 给了 key 名和 item shape，但没有把新 input role 显式映射到 canonical domain，也没有完整标注顶层类型/nullability、bundle ID语法或提供 oracle。对同一 334-byte 示例 payload，`json-manifest-v1` 得到 `458d6de2a4e6ccfbc2982219a7114f546a89c2f4d32f75d0e968559e707863d9`，`json-transaction-v1` 得到 `a8100a9f1bcd4b6c9f16eefe6e1a2412fd0ce13cfd7f25011656ac9bd50dcbd3`。approval 只比较自报 canonical hash时，两套 bundle 都可自洽；v5 也没有要求 approval 的 `artifact_id` 等于 `bootstrap_bundle_id`，或 approval date 不早于 manifest reviewed date。 | 明定 typed exact schema、唯一 domain、framing 和 role-to-domain 映射；补齐 ID/date/approval关系；给 positive hex/hash、wrong-domain、unknown-key、key-order negative fixture。 |
| `formula-evaluator-v1.json` | v4 只说 strict JSON validation和 `RecomputeDerivedV1` total function，从未给 exact key、value type、formula ID 到操作语义的 schema或 canonical domain；v5 却把它列成 `canonical_json` stable target。对象映射和 array 映射都可能通过“strict JSON”。 | 冻结 evaluator 的完整 schema、允许的 formula/operator universe、排序、domain、golden bytes及未知 formula反例。 |
| 12 个 managed patch | v4 第 357 行只自然语言说 patch记录 target、pre/post raw hash和操作类型，没有给 key 名、顺序、version、nullable或 domain；v5 第 191 行称其为“v4 exact-key JSON contract”，实际没有可继承的 exact contract。 | 定义 `MANAGED-PATCH-V1` exact schema、domain和 target/action nullable matrix；12 个 patch逐项与 payload target、base/post raw hash set-equal。 |

Severity：`Blocker`。核心批准箭头本身没有直接反向引用，但 canonical bytes 未封闭时，拓扑排序只能证明“字段引用没有显式环”，不能证明各节点 hash由同一算法产生。v5 新增的 bootstrap fixture还应明确使用独立 synthetic fixture，不读取本次真实 bootstrap/transaction hash，避免 fixture manifest反向依赖后续节点。

## Blocker 5：跨 phase 的 base image 仍会漂移

v5 第 187、285 行要求每个 phase 重算同一组 T bytes，但事务伪代码第 391 行仍调用 `BuildContractMigrationOperationSetV5(CurrentFormalBase)`。fresh 时 `CurrentFormalBase` 是 preimage；applied no-op 或 rollback 前复核时，九张受影响正式表已经是 postimage。相同事务因此会生成不同 operation universe，重现 R10 的 phase-dependent input问题。

迁移顺序第 514 行还说把当前 32 张正式表写入 `T/inputs/base/`，而封闭的 20 个 base snapshot 中只有 9 张正式表，另 23 张既不在 71 个 file input中，也不在 bootstrap base array中。transaction manifest 的全表 canonical digest能发现 live 语义漂移，但它不能提供缺失的 bytes，也没有说明 isolated mirror应从 T、live root还是 digest声明恢复这 23 张表。一个实现复制 live 23 表，另一个坚持只从 immutable T 构建，结果不同。

Severity：`Blocker`。v6 应把 operation builder 的输入固定为 immutable base/post snapshot，禁止读取 `CurrentFormalBase`。对于 23 张未改正式表，需要二选一并重算计数：要么每张提供受 manifest绑定的 immutable snapshot，令完整 base formal image可从 T重建；要么删去“冻结32张”和“从 immutable T inputs构建完整 mirror”的承诺，明确给出 live 23 表的逐表 hash绑定、读取时点与并发漂移失败规则。若选择第一条，最小输入数会从 71 增至 94，而不是继续宣称71覆盖全部32张正式表。

## Blocker 6：chip package 没有独立的 allowed set

v5 第 281、407 行调用 “approved operation/payload authorization”，但 v3、v4、v5 都没有定义这个 artifact 的路径、schema、logical key、批准者、canonical domain或 transaction manifest绑定。执行器因此无法独立构造 chip payload universe。只要自报 pre/post hash与 rollback action自洽，一个 package就可以额外管理无关 Markdown，或遗漏本应发布的卡片/来源 payload；现有 set-equal门没有可信的右侧集合。

role/path 也没有闭合，而且“36 项”本身复算错误。v4 的共享集合是 27 项，chip 另加 1 个 formula evaluator和 7 个 coverage输入，合计 35 项；第 36 个 `(role,path)` 并不存在。36 是 v4 `input_role` enum 的 token数，其中包括 chip不使用的 `managed_patch`，不能拿来充当 chip pair数。v5 第 240 行又允许把被修改的 live input从固定集合移除并换成 T 内 base/post snapshot，却没有给出哪个 authorization触发替换、snapshot role/path如何构造、修改后 required/allowed set的计数或 set-equal公式。两个实现可以分别保留 live row、替换双 snapshot或直接拒绝，三者都能引用当前文字。

Severity：`Blocker`。v6 应先把 chip base pair逐项重列为正确的35项，或明确补出真实的第36项。随后定义经独立 approval绑定的 chip operation/payload authorization artifact，至少冻结 target path、role、kind、operation、pre/post state和允许的 source path，并把它作为 required file input纳入 transaction manifest。operations、images、payloads和 authorization应各做双向 set-equal；遗漏、额外 target、错 role、错 action都要有 fixture。chip input可选择禁止修改固定 live input；若确需修改，则必须给出从 authorization机械生成 remove/add pair的唯一公式。

## v6 修复后需要重跑的门

| 门 | 通过条件 |
|---|---|
| canonical identity | candidate、base、post与 stable copy统一使用 logical target；freeze archive mode唯一；bootstrap、formula、patch各有 typed schema、domain和 oracle。 |
| scope bootstrap | 49 个 freeze row与49个六列行按冻结 constructor双射；七列行、allocation semantic projection和mapping semantic projection逐项相等。 |
| transaction replay | fresh、applying、applied no-op、rollback、rollback no-op五种状态重算同一 operation/input universe，不读取 phase-dependent base。 |
| chip authorization | file-input、operation/image和payload target均有独立 allowed set，extra/omission/role swap全部失败。 |
| runtime | Python 3、PowerShell 5.1、PowerShell 7分别生成相同 positive hex/hash和negative error code；当前 macOS结果不能替代这一步。 |

本次 `reject` 只针对上述可执行性与 canonical 唯一性。13 个 absent stable target的原子发布框架、contract migration列明集合内部的71 file input、35 managed target、20 restore、15 delete-created算术、factor分支、actual-row family归约、六个 N/A四键以及34/376/141/77/564正式计数都已复算正确；若 v6 选择把另外23张正式表纳入 T，71 必须按本报告所列方案改为94。修订版完成这些补丁后，仍需另行实现并运行 contract migration；设计验收不等于正式数据、GA100工作包或Windows gate通过。

本报告只新增本文件，没有改写 v3、v4、R08、R09、R10、v5或正式数据。`report-humanizer` 单文件机器扫描未检出 hard tell；随后从末段向前复读标题、各节首段、反例、表格引导、修复条件和结尾，没有发现仍需改写的模板化收束。剩余风险是合同取舍，不是文案自然度。
