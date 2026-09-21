# R1 冻结合同 v3 独立红队验收

## 结论

`reject`

冻结设计已经补上 v2 审计指出的大部分结构性缺口，但仍有两处会让独立实现产生不同合法结果，或者让不完整事务自洽地通过。它们都属于冻结合同本身的机器可判定性问题，不能留给实现者自行约定。本结论不评价正式数据质量，也不表示合同迁移、GA100 工作包或 Windows 门已经执行。

## 审计边界与当前基线

本次是只读红队。除本报告外，没有改动设计稿、32 张正式表、schema、enum、fields、资料卡模板、validator、staging 或进度文件。审计前完整读取了主线 `AGENTS.md`、指定恢复链，以及 R07、v3 设计、v2 独立复核、salvage map 和四份 gap remediation。被冻结设计稿 `r1_ga100_19_contract_repair_design_v3.md` 的 SHA-256 实测为 `f590a98ec29f3202c3d2eb3801f5fcddf165fd31bd5c86f2d778b797e0276cf8`，与委托值一致，共 948 行。

对正式基线重新解析后，schema 注册 32 张表、346 列，32 张磁盘 CSV 表头与注册列序全部一致。其余实测为 141 个唯一 field、76 个 enum group 和 557 个 enum row、78 个 object、585 条 completeness（45 个 object，每个 13 个 domain）、1,059 条 legacy field requirement、832 条 assertion、92 个 source family、93 个 source、153 个 endpoint。1,059 条 requirement 中存在 29 个重复 target-field key group，涉及 79 行，即比唯一键多 50 行；`pending_verification` 为 26 行。这些数字与 v3 的迁移前提一致。

活动名单实测 49 行，当前仍是六列表头；现有 scope registry 为 78 行，类型分布是 10 个 `chip_primary`、29 个 `architecture_evidence` 和 39 个 `out_of_scope_nonchip`。`card-completeness.csv` 的 585 行恰好是 45×13，13 个 domain 的集合与合同列出的集合一致。当前恢复校验器实跑通过：32 张正式表、153 个 endpoint、79 个本地路径及其 79 个 hash、11 个 selection run 和 106 个 selection member 均可恢复。

## 逐项红队结果

下表只表示冻结文本是否给出了足以拒绝反例的设计约束，不把尚未实现的 validator 或 fixture 记为运行通过。

| 检查面 | 红队结果 | 反例判断 |
|---|---|---|
| `34/376/141/77/562` | 通过 | 机器复算分别为 `32+2`、`346+4+20+5+1`、`141-1+1`、`76+1`、`557-1+5+1`。两张新表为 9/11 列，正式 postimage 目标数自洽。 |
| 两项 latency field contract | 通过 | `FIELD-COMP-INSTRUCTION-LATENCY` 固定 `cycle`，并有完整 condition JSON；`FIELD-MEM-LATENCY` 取消单一 canonical unit，只允许 `cycle/s`，无同 clock domain 频率时禁止隐式换算。instruction latency 没被混入 workload latency。 |
| 832 条 AFPV2 迁移与 endpoint closure | 通过 | 每条 update 都要求 V1 preimage、含 null endpoint 的 V2 input/postimage；新 lifecycle closure 又要求 actual endpoint 非空，因此 null 仅能保留 legacy，不能发布。删掉 endpoint 或不同源 endpoint 都会失败。 |
| 唯一活动 scope 与历史 | 通过 | 唯一活动名单、49 个 active allocation、不可复用 scope ID、append-only mapping event 和 tombstone 规则闭合；GA100 固定 `SCOPE-0001`，但不预先创建 formal object。 |
| projection 与 reachability | 通过 | expected projection 先于 manifest 独立构造并与 manifest set-equal；省略 projection、沿反向 relation 吸入对象、跨 owner parent 或形成环都会失败。 |
| 141 field 全集与 GA100 mandatory 108 | 通过 | field×reachable real target 全集与 candidate/binding 双重 set-equal；`12×9=108` mandatory 项必须 include，且不得用 `not_applicable` 规避。 |
| factor universe、target、binding 与 status | 通过 | factor obligation、kind-allowed target、include binding 分别 set-equal，status 与 search/result/evidence 有固定闭包；`min_targets_if_available` 不能替代全集。省掉 factor、target 或 binding 均不能通过。workload-variable 被显式排除在 architecture factor 之外。 |
| zero-included field | 通过 | include 数为零时必须映射至少一个 applicable factor，且所有映射 factor 闭合，不能把“没有真实 target”当作自动完成。 |
| source date | 通过 | 裁决键是 `(source_type,actual endpoint_type)`，并使用实际 source version 与 actual endpoint 的 publication/snapshot/access date；preferred endpoint 不参与替代。 |
| immutable legacy 与 successor lifecycle | 通过 | 1,059 行 baseline set-equal、29 个重复组逐组裁决、26 个 pending 隔离；approved→withdrawn→replacement 状态机能区分 ActiveSuccessor、InactiveHistoricalSuccessor 和普通 current duplicate。选择 inactive successor 或遗漏更高序事件会失败。 |
| derived metric | 通过 | unknown formula、输入缺失、input order 断裂、单位不兼容、除零、隐式精度转换和递归环都失败；input fact 的 assertion 和 actual endpoint 递归进入 closure。 |
| 13 条 completeness | 通过 | domain set、identity 唯一行、lifecycle/cutoff/scope 和机械派生状态均有约束；不能只提交 identity 或自报 completeness。 |
| strict bytes 与 domain framing | 通过 | UTF-8/BOM、strict JSON key/type/order、CSV 全 cell 引号、LF、logical PK、row envelope、domain framing、重复行拒绝都已给出。日期被限定为真实 Gregorian `YYYY-MM-DD`。 |
| 58-key manifest 与批准方向 | 部分通过 | key 数机器计数为 58；policy→approval、manifest→approval、rollback→transaction、journal 最后生成的方向没有自引用。若 hash 输入本身已有定义，单向性成立；若输入是下述未定义虚拟集合，则无法跨实现复算。 |
| transaction pre/postimage 与中断恢复 | 部分通过 | 832 行 assertion 的逐行 preimage/input/postimage、table image、payload、rollback、同 manifest 的 applying/rollback_applying 恢复规则完整；未知 hash、无 journal 的 mixed state 和不同 manifest mixed state都会失败。但 file-input universe 与路径域仍未闭合，见 blocker 2。 |
| PS5.1/PS7/Python fixtures | 未达到可实现合同 | 三端逐 fixture 全等、正负例和上线前置门写清楚；然而 `input_kind` 仍是未定义 enum，而且虚拟集合缺少 golden serialization，当前 fixture 不能充当这些 hash 的跨运行时 oracle。 |
| 模板、字段字典和来源角色 | 通过到迁移清单层 | HBM 两字段拆分、instruction/memory latency、factor requirement、actual endpoint、`coverage_obligation_evidence` 和相关文档均纳入迁移要求；最终来源数量及 MIG source role 没有被预设。 |

## Blocker 1：若干 manifest hash 没有唯一的 canonical 输入

设计在 coverage manifest 中声明了 `legacy_reconciliation_schema_canonical_sha256`、`active_scope_list_schema_canonical_sha256`、`expected_field_target_pairs_canonical_set_sha256`、`expected_factor_obligations_canonical_set_sha256`、`expected_factor_target_pairs_canonical_set_sha256` 和 `ga100_mandatory_keys_canonical_set_sha256`；transaction manifest 又声明了 `journal_schema_canonical_sha256`。然而冻结文本只为正式 CSV row、Markdown 活动名单 row、reachable inventory 和少数专用 JSON 给出了 envelope。它没有给上述“schema”或“虚拟 key set”逐项定义 table/domain、logical PK、完整有序 columns、空值表示、排序键和确切 payload 形状。

这不是命名问题。以 expected field-target pair 为例，实现 A 可以把一项编码成 `{field_id,target_kind,target_id}` object，实现在 domain A 下对 object array 哈希；实现 B 可以把它编码成 synthetic CSV row envelope，或直接编码成三元素 array。两者都能构造完整 candidate set、满足 set-equal、生成与各自实现一致的 manifest/approval，现有文字却没有依据判定哪一个 hash 错。`ValidateAllRawAndCanonicalManifestHashes` 的总括调用也不能补出缺失的 byte contract；伪代码没有逐键把这些 builder 输出的 hash 与 manifest 对比。省略 projection/field/factor 会被集合门拒绝，但把同一全集编码成不同 bytes 仍可能通过各自实现。

最小修复是在设计稿中逐个冻结这些 manifest key 的 canonical schema：给出唯一 domain tag、exact-key/column 顺序、table path 或明确的非表 envelope、logical PK、null/empty 表示和排序规则；随后在伪代码中为每个 key 写出显式 `Require(recompute == manifest key)`，并为每种虚拟集合和 schema hash 提供至少一个三运行时 golden hex/hash fixture。不能只用 `HashRowSet(expected_pairs)` 之类未定义的抽象名替代。

## Blocker 2：file-input 与 fixture 的 enum 和输入全集未冻结

`transaction-file-inputs.csv.input_role` 在设计第 629 行被声明为 `enum!`，但全文没有给出允许值；第 629 行只有“登记 policy、approval、coverage files、活动 scope row source、legacy registry、formula evaluator、validator、template/docs patch 和其他非 operation 输入”的自然语言描述。`canonical-fixtures.csv.input_kind` 在第 753 行同样声明为 `enum!`，全文也没有枚举允许值。这样 `validator`、`validator_patch`、`other` 等任意 token 是否有效，只能由实现者决定，严格 parser 和三运行时无法证明使用了同一合同。

更直接的漏检反例是：chip transaction 从 file-inputs 省掉一个 validator 或 template/docs patch，同时把 `file_input_count`、raw hash 和 canonical set hash按缩小后的文件自洽更新。transaction manifest 目前只要求 count 等于 CSV 行数；policy bundle 只对七个 policy role 做 set-equal，没有给 `transaction_kind → required/allowed (input_role,relative_path)` 的完整集合门。设计后文虽然说这些文件“必须纳入”，但没有冻结具体角色 token、文件集合和拒绝额外项的规则。与此同时，项目相对路径、防 absolute/`.`/`..`/反斜杠的规则只明确写在 payload inventory；operations、table-images、file-inputs 和 rollback inventory 的相关 path 列没有被明确纳入同一约束，跨实现仍会分歧。

最小修复是同时完成三件事：为 `input_role` 与 `input_kind` 列出封闭 enum；为两种 transaction kind 定义独立构造的 required/allowed file-input `(role,path)` 集合，并与 CSV set-equal，明确 validator、formula evaluator、模板和文档的固定项目相对路径；把同一安全路径语法显式应用到 operations、table-images、payload inventory、file-inputs、rollback inventory 及其 payload/rollback path。相应的 omitted/extra role、未知 enum、绝对路径和 `..` 反例要进入 PS5.1、PS7 与 Python fixture。

## 失败与运行边界

当前环境没有 `pwsh`、`powershell` 或 `powershell.exe`，因此没有执行现状的 `Test-ChipScope.ps1`、`Test-SourcePool.ps1` 和 `Validate-ResearchData.ps1`。这是运行时缺失，不是 sandbox、approval、远端服务或模型能力限制；本次只读设计验收也不能用 macOS 上的 Python 结果替代 Windows 门。Python 恢复校验器已实跑通过，但它只证明当前 32 表和本地证据可恢复，不证明 v3 postimage。

操作过程中有四次已纠正的操作者错误：前三次分别把恢复脚本目录、当前 source 表名和 schema ordinal 列名写错，改正后确认恢复校验通过、source-family/source/endpoint 为 92/93/153、32 张表共 346 列且零表头不一致；第四次在最终字节检查命令里把 newline byte 误写成转义后的字面量，纠正断言后通过。人工逆向复读时还遇到一次工具运行失败：系统没有 `tac`，改用本机可用的逆序读取方式完成复读。最终 Git 状态/`diff --check` 尝试也因该目录不处于 Git worktree 而失败，改用直接 UTF-8、尾随空白、行数和 hash 检查；这是仓库环境状态，不是 sandbox denial。没有发生用户中断、approval failure、approval-review connection failure 或 remote service error。

## 验收边界

本次 `reject` 只由上述两个可复现 blocker 触发。其余已通过的项目不要求重写；修订时应保持冻结 SHA 另起新版本，并把修复限制在 canonical 输入定义、逐键复算门、file-input/fixture enum 与输入集合/路径约束。即使下一版通过独立设计验收，也只代表可以进入审计区实现，仍不代表正式迁移或 Windows 门通过。
