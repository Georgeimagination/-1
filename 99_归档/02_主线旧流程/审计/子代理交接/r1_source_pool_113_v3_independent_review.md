# 113 份 PDF 资料池 v3 独立最终复核

状态：`reject`

复核日期：2026-08-21。本次只读取正式主线与 `r1_source_pool_113_staging/`，在 `/private/tmp/r1_source_pool_113_v3_independent.5ZpMtZ/` 建立独立 formal mirror。正式 `论文/`、`清单/`、`scripts/`、三张来源表和 `进度/` 均未写入；正式工作区的唯一新增文件是本复核记录。

## 裁决

v3 的 collector、ledger、frozen manifest 和两份候选输出已经关闭 v2 的技术阻断。稳定输入落点与默认解析正确；legacy preview、首次 apply、apply 后 preview、第二次 apply 均可重放；三张动态 registry 各追加无关 GA100 行不会阻断，两条 AMD row-level binding 仍严格；三类重叠 output root 均在写入前失败；生成器只写 manifest 与 summary；网页和待补清单留在 validator 的冻结边界内。113 份 PDF 的数量、字节、页数、哈希和分类也全部复算通过。

当前 `operations.csv` 还没有形成完整的字节级正式事务，因此正式推广仍判 `reject`。`OP-113-V3-000` 要备份并随后替换四个既有文件，却只给 manifest、summary 和 collector 三个正式旧哈希，漏掉现有 `Test-SourcePool.ps1` 的哈希。`OP-113-V3-003` 与 `OP-113-V3-006` 也没有固定 candidate collector 与 validator 的 SHA-256，写后验证只描述行为，没有证明安装的是本次独立复核过的两个脚本。正式目录若在推广前出现并发或用户修改，当前 precondition 不能阻止 validator 被覆盖；staging 脚本若发生漂移，operations 也不能识别。这个缺口直接落在本次要求的“精确目标、顺序和回滚”边界内。

## 候选快照

| 文件 | SHA-256 |
|---|---|
| `README.md` | `d0a143db49174d056076606c3c507ed9e7c3d6745d2081dc7dfe5781573e69dd` |
| `collect_references.py` | `2a980efd45bc9846029003ca38ece6823f75f9d00d6fcbbe0137638e4c2aefcb` |
| `Test-SourcePool.ps1` | `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0` |
| `source-pool-input-ledger.json` | `08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812` |
| `frozen-legacy-pdf-manifest.csv` | `c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27` |
| `论文PDF清单.csv` | `4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab` |
| `汇总统计.json` | `994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e` |
| `operations.csv` | `67ed6f16e46dd758d2b136ccae2b3de7e4ba5e22ce901af63ccf39ff5a9b6a5a` |
| `validation_report.md` | `8a5268870a9993fffebdeeab187a35d5525c1b00d87000cc6d81c926887a9d6a` |

`formal_payload/清单/资料池受控输入/source-pool-input-ledger.json` 与 staging 根的同名 ledger 逐字节相同，`cmp` 返回 0；两份 frozen manifest 也逐字节相同。formal payload 中只有这两组同名文件，哈希分别为 `08994b24...8812` 和 `c8c43df6...8b27`。

## 稳定落点与默认解析

mirror 将两个 formal payload 文件安装到 `清单/资料池受控输入/`，将 candidate collector 安装到 `scripts/collect_references.py`。运行 collector 时没有传 `--mainline-root` 或 `--ledger`，脚本仍从自身路径定位主线，并默认读取：

`清单/资料池受控输入/source-pool-input-ledger.json`

ledger 的 `frozen_legacy_pdf_manifest.relative_path` 为同目录相对路径 `frozen-legacy-pdf-manifest.csv`。独立重放证明安装后没有回指 staging，也不需要历史项目目录或 `codex-v3/.tmp/paper_inventory_final.json`。

## legacy 到幂等状态的独立重放

| 步骤 | 结果 |
|---|---|
| legacy prestate preview | 退出码 0；只生成两份清单文件；与 staging 候选逐字节相同 |
| 错误 confirmation apply | `deadbeef` 以退出码 2 fail closed；mirror manifest 与 summary 仍为旧哈希 |
| 首次正确 apply | 退出码 0；输出变为 `4df7c221...c1ab` 与 `994a4950...4785` |
| 三张 registry 各追加一条无关 GA100 row | append 后 post-apply preview 退出码 0；输出字节不变 |
| AMD source binding 负向测试 | 把 MI455X `source_authority` 改为 `third_party` 后退出码 2，明确要求 `first_party` |
| AMD endpoint binding 负向测试 | 把 local endpoint MIME 改为 `text/plain` 后退出码 2，明确要求 `application/pdf` |
| AMD selection binding 负向测试 | 把 `selected_role` 改为 `redundant_covered` 后退出码 2，明确要求 `core_spec` |
| 第二次正确 apply | 退出码 0；输出哈希不变 |
| 再次幂等 apply 的全文件内容快照 | 前后均为 123 个文件，内容哈希差异为 0；程序仍只报告两个 written outputs |

动态追加使用了三个不同主键：`SRC-R1-GA100-DYNAMIC-APPEND-TEST`、`END-R1-GA100-DYNAMIC-APPEND-TEST` 和 `SELMEM-R1-GA100-DYNAMIC-APPEND-TEST`。这比只追加 `sources.csv` 更完整地验证了三张 registry 不受整表 hash gate 限制。对 AMD source、endpoint 和 selection member 分别做字段篡改后，三次均在生成输出前失败；恢复字段后第二次 apply 通过。

## output root 与写入范围

以下三个 preview output root 都以退出码 2 和 `must be fully disjoint` 拒绝，且没有创建 child preview：

| 关系 | 测试路径 |
|---|---|
| 等于 mainline | mirror 主线根本身 |
| mainline 子目录 | mirror 根下的 `preview_child/` |
| mainline 祖先 | 包住 mirror 主线的临时父目录 |

collector 的 `write_scope.outputs` 精确等于 `清单/论文PDF清单.csv` 与 `清单/汇总统计.json`。代码中的写入调用也只有这两个路径，`pdf_copy_operations=0`；没有复制或改写 PDF 的函数路径。网页清单和待补清单只作为 ledger 创建时的 audit-only observation，不由 collector 读取或写入。

候选 `Test-SourcePool.ps1` 有意继续冻结网页清单与待补清单：正式网页清单为 914 行、893 个区分大小写 URL、892 个忽略大小写 URL，待补清单为 11 行；其哈希分别为 `f19991c7...395f` 与 `b5a5993c...07bd`。validator 还固定 ledger 和 frozen manifest 的正式落点及哈希。该职责划分与 README、ledger 和代码一致。

## 113 份 PDF 与 summary 复算

| 检查项 | 候选值 | 独立结果 |
|---|---:|---:|
| manifest 行数、磁盘 PDF 数 | 113、113 | 113、113 |
| 总字节 | 315,363,681 | 315,363,681 |
| manifest 页数、`pdfinfo` 页数 | 2,214、2,214 | 2,214、2,214 |
| `源文件` 出现次数 | 114 | 114 |
| 唯一 SHA-256 | 113 | 113 |
| 历史重复 | 1 | 1 |
| AMD Instinct PDF | 6 | 6 |
| AMD 白皮书、产品资料 | 4、2 | 4、2 |
| 冻结 paper inventory | 112、101 | 112、101 |

113 个 manifest 路径与正式 `论文/**/*.pdf` 集合完全相同。逐文件大小、SHA-256 和 `pdfinfo` 页数没有不匹配；manifest 无空哈希、重复哈希或重复目标路径。平台与类别计数逐键等于 summary，两个计数集合都合计 113。frozen legacy 也独立命中 111 行、112 次来源出现、111 个唯一内容、313,921,821 字节和 2,210 页。

## operations 已完成部分与阻断项

`operations.csv` 已给出 00 至 09 的连续序号，stable input、collector、独立 preview、apply、validator 和三道 Windows gate 的正式目标、先后关系与失败回滚方向都清楚。受控输入采用 frozen 先于 ledger、ledger 先于 collector 的顺序；apply 只允许两个输出；失败后恢复原 manifest、summary、collector 和 validator，并只在记录证明目录由本事务新建时删除受控输入目录。这些边界通过。

还需补齐下面三项，才能把状态改为 formal-ready：

1. `OP-113-V3-000` 的正式 precondition 加入现有 `scripts/validation/Test-SourcePool.ps1` 哈希 `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f`。该行声称保护四个既有文件，precondition 也必须覆盖四个。
2. `OP-113-V3-003` 与 `OP-113-V3-006` 分别固定 staging source 与写后目标哈希：collector `2a980efd45bc9846029003ca38ece6823f75f9d00d6fcbbe0137638e4c2aefcb`，validator `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0`。备份记录还应写明实际备份目录及其 manifest 哈希，避免“timestamped backup”只停留在文字要求。
3. 在正式 apply 后增加 post-apply preview 与 second apply 两项验证，要求输出逐字节不变、全文件内容快照无其他变化。v3 mirror 已证明代码具备此能力；把它写入正式顺序，才能让推广记录证明安装后的 collector 也满足幂等合同。

这些修改会改变 `operations.csv`，不要求重做 113 份 PDF 的内容复算。如果 collector、validator、ledger 或 formal payload 也发生变化，则必须按新哈希重新执行完整重放。

## Windows 硬门

当前 macOS 环境没有 `pwsh`、`powershell` 或 `powershell.exe`。候选 PowerShell 脚本只能做静态复读，不能在此环境声明 Windows PowerShell 5.1 实跑通过。该限制属于 `tool/runtime failure`，没有发生 sandbox denial、审批失败、远端服务错误或用户拒绝。

修正 operations 并正式推广后，仍须在 Windows 顺序运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1 -SubjectContractMode gate`。这三项当前都是 `windows_pending`；它们通过前，不能把资料池正式基线写成已验收。

## 正式文件静态性与错误分类

复核结束时，正式 PDF manifest、summary、网页清单、待补清单、collector 和 validator 的 SHA-256 仍依次为 `c8c43df6...8b27`、`eee940c5...20c7`、`f19991c7...395f`、`b5a5993c...07bd`、`4946da30...b06f` 和 `44756009...736f`。正式 `清单/资料池受控输入/` 仍不存在。三张正式 registry 也保持原哈希，GA100 测试行只存在于 `/private/tmp` mirror。

错误 confirmation、三类重叠 output root 和三次 AMD 字段篡改都是预定负向测试，退出码 2 属于预期 fail-closed 行为。validation report 记载的 argparse 默认值过早求值属于已修复的 implementation mistake；当前 PowerShell 缺失属于 tool/runtime failure。没有发现把这些事件误记为 sandbox 或审批问题的情况。

## 自然化复读

本记录按工程审计文档处理。机器扫描后人工复读了标题、裁决首段、表格引导、重放顺序、operations 阻断、Windows 限制和结尾。没有发现明显 AI 腔；剩余重复来自必须逐项区分的旧状态、候选状态与正式推广状态。
