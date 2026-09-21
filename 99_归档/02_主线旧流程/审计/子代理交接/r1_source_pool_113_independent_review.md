# 113 份 PDF 资料池候选独立复核

状态：`reject`

复核日期：2026-08-21。此记录只读取正式资料池、正式来源表、`r1_source_pool_113_staging/`、第三波 AMD 固定候选、现有生成器和两个历史项目的当前只读输入；本任务唯一写入文件是本独立复核记录。正式 `论文/`、四项资料清单、校验脚本、来源表和 staging 均未修改。

## 裁决

候选的内容正确，但还不是可正式合并的修复包。113 行 manifest、汇总 JSON 和候选 `Test-SourcePool.ps1` 彼此一致，也完整覆盖当前磁盘的 113 份 PDF；两条新增 AMD brochure 的对象、来源链和物理属性均已独立验证。

阻断项在可复现性，而不在两条数据行。正式 `scripts/collect_references.py` 仍只扫描两个历史项目，并从相邻 `codex-v3/.tmp/paper_inventory_final.json` 派生 paper inventory 字段。它不读取本 staging 的 `operations.csv`，也不读取主线 `论文/`、第三波 M2 fixed candidate 或任何受控增量账本。把当前候选文件直接覆盖到正式位置后，下一次预览或带 `--apply` 的生成仍会按照已漂移的历史输入重写资料池，113 基线没有持久的生成来源。因此结论为 `reject`，不得执行正式合并。

## 已通过的候选内容核验

正式 PDF 清单的 111 条旧记录以 CSV 字段语义逐字段比对，候选前 111 条完全相同，16 列表头和行序也保持不变。候选仅在末尾追加两条记录：

| 资料 | 正式资料池路径 | 来源 ID / local endpoint | SHA-256 | 字节 | 页数 |
|---|---|---|---|---:|---:|
| AMD Instinct™ MI455X GPU | `论文/AMD_Instinct/02_厂商产品资料/2026_AMD_Instinct_MI455X_GPU_Brochure.pdf` | `SRC-M2W3-AMD-MI455X-BROCHURE-202607` / `END-M2W3-AMD-MI455X-BROCHURE-LOCAL` | `6555fef1399a35f472e325dc61936d293e129735ec1e191d5fd0f3b6fa0c4208` | 659,374 | 2 |
| AMD Instinct™ MI350P PCIe® Card | `论文/AMD_Instinct/02_厂商产品资料/2026_AMD_Instinct_MI350P_PCIe_Card_Brochure.pdf` | `SRC-M2W3-AMD-MI350P-BROCHURE-202605` / `END-M2W3-AMD-MI350P-BROCHURE-LOCAL` | `a4e93edffc6c2a03668eef72b84d85e1d2586afb331c2228595d1549609afb29` | 782,486 | 2 |

两条记录的标题、AMD、文档版本、SHA-256、正式本地路径和页数分别与 `sources.csv`、`source-endpoints.csv` 相同；候选的官方 URL 也逐条对应各自的 `pdf_direct` endpoint。两份正式池文件、相应第三波 fixed candidate 和候选 manifest 的哈希一致。`pdfinfo` 对两份文件均返回 Letter、2 页。

以候选 manifest 对全部正式 `论文/**/*.pdf` 重算后，磁盘与清单都是 113 份；没有清单缺失文件、未登记磁盘文件、路径重复、空哈希、重复哈希、大小不符、哈希不符、页数不符或 PDF 解析失败。合计为 315,363,681 字节和 2,214 页。

`源文件` 以中文分号切分后共有 114 次出现，113 个 SHA-256 唯一值，故精确重复为 1。候选汇总的 `114 - 1 = 113` 关系成立。平台与类别统计均逐键等于候选 manifest：AMD Instinct 为 6，其中 `官方白皮书与技术资料` 仍为 4，`厂商产品资料` 为新增的 2；全部平台和全部类别的合计各为 113。

## 汇总字段的边界

候选保留 `paper_inventory_records=112` 和 `paper_inventory_downloaded=101` 是正确的语义选择：它们是旧 paper inventory 的冻结汇总，不应因两份 M2 product brochure 自动变化。当前 `codex-v3/.tmp/paper_inventory_final.json` 已是 111 条，其中 100 条标记为已下载、11 条待下载；它不能静默取代冻结值。

不过，现有生成器会从这个已漂移的 `.tmp` 直接计算两项字段。更严重的是，按生成器当前的两个历史项目扫描规则实测只得到 103 次 PDF 出现、102 个唯一 SHA-256 和 1 个重复，而不是正式 manifest 所代表的 112 次出现、111 个唯一 PDF 和 1 个重复。该差异说明 111 行旧基线本身也已不能由今天的历史目录重放，并非只缺两条 M2 增量。

因此，候选 `operations.csv` 的两条 `controlled_pdf_input` 只能作为 staging 的操作说明，不能充当正式生成输入。完整修复至少需要一个纳入正式管理、可冻结的输入层：一方面固定旧基线的 112 次来源出现与 111 个唯一文件，另一方面登记两条 M2 输入的 source ID、remote/local endpoint、URL、正式路径、原 staging 路径、哈希、字节、页数、题名、版本和分类。随后必须提交 `collect_references.py` 的候选补丁，让它明确消费该输入层并生成候选中的 114/113/1 与冻结的 112/101 语义；或者以等价的正式生成器取代现有脚本。仅有完整 manifest、summary 和 validator 不能关闭这一风险。

`r1_source_pool_113_reconciliation.md` 的“同步项”段还把 `AMD Instinct / 官方白皮书与技术资料` 写成应更新到 6，与它后文的两条 `厂商产品资料` 定义以及候选统计相冲突。应改为白皮书 4、产品资料 2。这是文档一致性问题，不是新增两行的内容错误。

## 校验器复核与运行限制

候选 `Test-SourcePool.ps1` 的 PDF manifest 与汇总 JSON 哈希常量分别等于候选文件的实际 SHA-256；未修改的网页清单和待补清单哈希仍等于正式值。113 份、315,363,681 字节、2,214 页、114/113/1、112/101、平台和类别常量也均与独立复算一致。新增检查覆盖空 SHA-256、重复 SHA-256、来源出现次数与唯一哈希的差额、汇总算术、平台统计和类别统计；脚本没有写入 cmdlet，仍是只读校验。

静态检查没有发现 Windows PowerShell 5.1 之后才有的语法或 API：候选只使用 PowerShell 5.1 已支持的 `Import-Csv`、`ConvertFrom-Json`、`[ordered]`、泛型集合、`-notin`、`-ieq`、`StringComparer` 和 .NET Framework 路径/哈希 API。候选和正式脚本都保持 UTF-8 BOM；混合的 CRLF/LF 换行不影响这一语法判断。当前 macOS 环境没有 `pwsh`、`powershell` 或 `powershell.exe`，所以无法实际用 Windows PowerShell 5.1 解析并运行硬门。这是 `tool/runtime failure`，即所需运行时缺失，不是 sandbox denial、审批失败、远端服务错误或用户拒绝。Windows 实跑仍是正式合并前的必经关闭条件。

## 正式文件静态性

复核期间，四项正式资料清单和正式校验脚本保持下列 SHA-256；它们与正式脚本原有基线一致，未见本候选造成的写入。

| 正式文件 | SHA-256 |
|---|---|
| `清单/论文PDF清单.csv` | `c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27` |
| `清单/网页与在线资料.csv` | `f19991c731fcdca8e0dee65601a2637a5568bc1fde46b357757d19292aa1395f` |
| `清单/待补论文清单.csv` | `b5a5993c0a29364c5be3c2d6d35321e3150b5599913e3fafe887bff3a02307bd` |
| `清单/汇总统计.json` | `eee940c5b1fdaa871fe0f2ea734216136471db28a68f43ff10cfdc2602b41db7` |
| `scripts/validation/Test-SourcePool.ps1` | `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f` |

## 关闭条件

先在正式工作区加入并冻结可复现的 legacy 加 M2 输入账本，再提交生成器候选补丁。以该补丁生成的预览必须与 staging 的 manifest、汇总和校验器逐文件、逐字段一致，且明确维持 paper inventory 的冻结 112/101 口径。之后才能复制候选文件到正式位置，并在 Windows PowerShell 5.1 运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1 -SubjectContractMode gate`。在此之前，不应执行正式合并。

## 自然化复读

本文件按工程审计记录处理。机器扫描后复读了标题、裁决、两类计数边界、阻断条件、表格引导和结尾。删除了概括性收束语，保留了可验证的文件、计数和关闭动作。没有发现明显 AI 腔；剩余风险来自缺失的正式生成输入和 Windows 运行时，而不是表述问题。
