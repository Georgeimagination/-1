# 113 份 PDF 资料池 v2 独立最终复核

状态：`reject`

复核日期：2026-08-21。本次复核先读取项目根与主线 `AGENTS.md`、49 款芯片主线恢复材料，以及 v1 独立拒绝记录 `r1_source_pool_113_independent_review.md`；随后逐项检查 `r1_source_pool_113_staging/` 的九个候选文件。正式 `论文/`、四项清单、来源表、校验脚本和生成器均保持只读。唯一正式工作区写入是本复核记录，重放输出位于 `/private/tmp/r1_source_pool_113_v2_independent.SzUimL/`。

## 裁决

v2 已关闭 v1 关于数据内容和当前状态重放的阻断。冻结 legacy manifest 与正式旧 PDF 清单逐字节相同；ledger 完整绑定 legacy 统计、两条 M2 supplemental PDF、正式 source、endpoint、selection member、两份输出和未改清单；生成器不再读取两个漂移的历史目录或 `codex-v3/.tmp/paper_inventory_final.json`。我在独立临时目录重放得到的 manifest 与 summary 均与候选逐字节相同，且没有 PDF copy。

正式推广合同仍未闭合，因此本轮结论仍为 `reject`。当前包没有给 ledger、frozen manifest 和 collector 指定无歧义的正式落点；更关键的是，collector 若作为持久正式生成器替换现有脚本，第一次正确 apply 后便会被自己锁定的旧 111 行 prewrite guard 拒绝，后续 preview 也不能重放 113 行正式状态。三张来源表的全文件哈希同样会随 GA100 等后续正式事务漂移。当前候选可以证明一次迁移前重放正确，尚不能成为迁移后可持续使用的正式 collector。

## 九个候选文件

| 候选文件 | SHA-256 | 复核结果 |
|---|---|---|
| `README.md` | `2cb846a920a4fbdb12d8a6ddad633bd5f5f508b662ffefb9e6980eaa0aa13a38` | 内容边界基本正确，但正式目标和迁移后重放规则仍不明确 |
| `Test-SourcePool.ps1` | `fe184b1d7ab986f4429c123e5e6f6e1cfc701e83b12845dcc6a4ac5ceb76b9ba` | 常量与候选一致；Windows 实跑待补 |
| `collect_references.py` | `45b01655e52ee9bc8c0fdf2859fda960b627315032c91ffff07a4758d64c1754` | 当前旧基线下 preview 通过；正式目标和迁移后幂等性未关闭 |
| `frozen-legacy-pdf-manifest.csv` | `c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27` | 与正式旧 manifest 逐字节相同 |
| `operations.csv` | `2c48ac9de1af005fd660f708fa99c70ae0aadb078737e547aae7745fc208f975` | 八项候选职责齐全，但 006 至 008 没有精确正式目标和推广顺序 |
| `source-pool-input-ledger.json` | `7740f81d1df356eec6356762c21aa48bb7a8a4484e53717512ee633424c132f8` | 当前输入绑定通过；持久 guard 策略未闭合 |
| `validation_report.md` | `a96d54b9d30581ac9785ea8f30e43945f688beea54f7d3794646be76a374340a` | 当前状态复算可信，未披露迁移后非幂等问题 |
| `汇总统计.json` | `994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e` | 独立复算通过 |
| `论文PDF清单.csv` | `4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab` | 独立复算通过 |

## 独立复算

| 检查项 | 候选值 | 独立结果 |
|---|---:|---:|
| manifest 行数 | 113 | 113 |
| 磁盘 PDF 数 | 113 | 113 |
| 总字节 | 315,363,681 | 315,363,681 |
| `pdfinfo` 总页数 | 2,214 | 2,214 |
| `源文件` 出现次数 | 114 | 114 |
| 唯一 SHA-256 | 113 | 113 |
| 历史重复 | 1 | 1 |
| AMD Instinct PDF | 6 | 6 |
| AMD 官方白皮书与技术资料 | 4 | 4 |
| AMD 厂商产品资料 | 2 | 2 |

113 个 manifest 路径与正式 `论文/**/*.pdf` 集合完全相同。逐文件检查没有发现缺失、多列、路径重复、空哈希、重复哈希、大小不符、哈希不符或页数不符。这里的“1 个历史重复”是来源出现层的重复：`Google Training Supercomputers from TPU v2 to Ironwood` 一行保留两个历史源文件位置；113 个正式 manifest 行的内容哈希仍全部唯一。

冻结 legacy 输入为 111 行、112 次来源出现、111 个唯一内容、1 个重复、313,921,821 字节和 2,210 页，所有值均独立命中。candidate manifest 的前 111 行与 frozen manifest 字段语义相同，且候选字节流以前一份正式 manifest 的完整字节流开头。

`paper_inventory_records=112` 和 `paper_inventory_downloaded=101` 与旧正式 summary 相同，作为历史 inventory 快照保留是自洽的。当前可变 `.tmp` 实际为 111 条、其中 100 条已下载；两个历史目录当前扫描结果为 103 次 PDF 出现、102 个唯一内容和 1 个重复。v2 generator 未读取这些漂移输入，因此 112/101 的冻结边界已落实。

## 两条 M2 supplemental 与来源绑定

| 来源 | source / local endpoint / selection member | 文件核对 |
|---|---|---|
| MI455X brochure | `SRC-M2W3-AMD-MI455X-BROCHURE-202607` / `END-M2W3-AMD-MI455X-BROCHURE-LOCAL` / `SELMEM-M2W3-AMD-MI455X-BROCHURE` | fixed candidate、正式 PDF 与 manifest 均为 `6555fef1...4208`，659,374 字节，2 页 |
| MI350P brochure | `SRC-M2W3-AMD-MI350P-BROCHURE-202605` / `END-M2W3-AMD-MI350P-BROCHURE-LOCAL` / `SELMEM-M2W3-AMD-MI350P-BROCHURE` | fixed candidate、正式 PDF 与 manifest 均为 `a4e93edf...fb29`，782,486 字节，2 页 |

两条 `sources.csv` 记录的题名、AMD 署名、`product_brief` 类型、版本、内容指纹和 `reviewed` 状态均与 ledger 相符。local endpoint 的来源、类型、路径、哈希、页数和复核状态一致；remote endpoint 的 `pdf_direct` URL 和复核状态一致。两个 selection member 均绑定正确 source，其 selection run 的 `status` 与 `review_status` 也都是 `reviewed`。两份文档按 `厂商产品资料` 登记正确，AMD 白皮书仍为 4 份，未发现把 product brochure 错归为架构白皮书的情况。

## 重放、写入范围和负向检查

候选 collector 只渲染 `清单/论文PDF清单.csv` 与 `清单/汇总统计.json`。代码没有历史项目扫描、paper inventory 读取或 PDF copy 路径；`shutil` 只用于查找 `pdfinfo`。独立 preview 在 `/private/tmp` 中只生成这两个文件，输出 SHA-256 分别为 `4df7c221...c1ab` 与 `994a4950...4785`，均与 staging 候选逐字节相同，程序报告 `pdf_copy_operations=0`。

使用错误的 `--confirm-ledger-sha256 deadbeef` 执行 apply 负向检查，程序以退出码 2 和 `SOURCE_POOL_LEDGER_VALIDATION_FAILED` 结束。检查前后，正式 manifest、summary、网页清单、待补清单、collector、validator 以及三张来源表的哈希均未改变。该退出是预期的 fail-closed 结果，不是工具故障。

正式文件在复核结束时仍为：PDF manifest `c8c43df6...8b27`，网页清单 `f19991c7...395f`，待补清单 `b5a5993c...07bd`，summary `eee940c5...20c7`，collector `4946da30...b06f`，`Test-SourcePool.ps1` 为 `44756009...736f`。三张来源表也继续命中 ledger 记录的 `eee9a5dd...8eb`、`e4984fef...f7bd` 和 `33489268...bd30`。

## 尚未关闭的正式推广合同

### 正式目标未落定

collector 的默认 ledger 是脚本同目录的 `source-pool-input-ledger.json`，frozen manifest 又按 ledger 所在目录解析相对路径。若 collector 推广到 `scripts/collect_references.py`，同一套默认值要求 ledger 与 frozen manifest 分别位于 `scripts/source-pool-input-ledger.json` 和 `scripts/frozen-legacy-pdf-manifest.csv`。README 只写“迁入受控位置”，`operations.csv` 的 006 至 008 仍把 target 写成 staging 名称，`formal_local_path` 为空，也没有给出六文件推广顺序。照当前 operations 执行，正式 collector 会找不到默认 ledger，或者继续依赖审计 staging，均不符合持久正式输入的要求。

### 第一次 apply 后不能再次重放

ledger 的 formal prewrite guards 把正式 PDF manifest 和 summary 固定为旧哈希 `c8c43df6...8b27` 与 `eee940c5...20c7`。collector 在 preview 和 apply 两种模式下都会无条件先检查这四个 guard。正确 apply 把两份正式输出改为 `4df7c221...c1ab` 与 `994a4950...4785` 后，同一 collector 的下一次 preview 会在生成前失败。这套行为适合一次性迁移前守卫，不适合作为正式持久 collector。

`sources.csv`、`source-endpoints.csv` 和 `selection-members.csv` 当前全文件哈希已命中，具体两条绑定也正确；但 collector 每次运行都要求三张表的整文件哈希保持不变。GA100 或后续芯片事务只要合法新增来源行，即使两条 AMD 绑定没有变化，113 PDF 重放也会失败。正式方案应把一次性事务 guard 与长期行级绑定分开，或明确 ledger 更新、复核和重新签字机制，不能把今天的整表哈希当作永久不变合同。

### preview 独立目录只写在文档中

本次实际使用了 `/private/tmp` 独立目录，结果符合要求。代码只拒绝 `output_root` 与主线根完全相等，没有拒绝主线根下面的子目录。正式 collector 若要求 preview 不触碰主线，应在代码中检查 output root 不得位于主线根内，并在 operations 中固定使用独立临时目录。

## 达到 formal-ready 所需的精确边界

持久方案应把下列六项作为同一个签字推广集，不能只覆盖两份清单或只替换 collector：

| staging 候选 | 建议正式目标 |
|---|---|
| `collect_references.py` | `scripts/collect_references.py` |
| `source-pool-input-ledger.json` | `scripts/source-pool-input-ledger.json` |
| `frozen-legacy-pdf-manifest.csv` | `scripts/frozen-legacy-pdf-manifest.csv` |
| `Test-SourcePool.ps1` | `scripts/validation/Test-SourcePool.ps1` |
| `论文PDF清单.csv` | `清单/论文PDF清单.csv` |
| `汇总统计.json` | `清单/汇总统计.json` |

在这六项进入正式事务前，还需要修改 collector、ledger、README 和 operations，使路径与行为一致。至少应允许正式 PDF manifest 和 summary 处于 legacy 旧状态或 expected output 状态，并在 113 行状态下再次 preview 得到相同字节；三张来源表应保留两条 AMD 行级绑定检查，同时明确整表哈希是一次性 apply guard，还是随正式来源事务更新的可审计输入。若选择其他 ledger 目录，必须同步改 collector 默认路径和 ledger 内 frozen manifest 相对路径。

修正后的 operations 应为六个正式目标记录候选哈希、目标旧哈希或缺失状态、写入顺序、失败回滚和写后哈希。先在主线外的临时目录执行 preview 并逐字节比较，再按签字集同步推广六项；推广后必须直接使用正式 `scripts/collect_references.py` 的默认 ledger 再做一次独立 preview，证明 113 行正式状态可重放。两份 PDF 已在正式池中，本事务不复制或改写 PDF，也不改 `网页与在线资料.csv`、`待补论文清单.csv` 或三张来源表。

如果把当前 collector 仅定义为一次性迁移工具，它应继续留在审计 staging，不能声称替换正式 collector。该选择仍没有解决正式 `scripts/collect_references.py` 的漂移输入问题，因此不足以关闭 v1 blocker。

## Windows 硬门与错误分类

当前 macOS 环境没有 `pwsh`、`powershell` 或 `powershell.exe`。候选 `Test-SourcePool.ps1` 的新增语法静态上没有发现超出 Windows PowerShell 5.1 的用法，但无法在这里执行。该限制属于 `tool/runtime failure`，不是 sandbox denial、审批失败、远端服务错误或用户拒绝。修正推广合同并完成六文件同步后，仍须在 Windows 依次运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1 -SubjectContractMode gate`；三项都通过后，资料池基线才能正式验收。

候选 validation report 记录的 CSV 换行、Ruby 依赖、macOS `find` 参数、UTF-8 BOM 和错误工作目录问题，分别归为 operator mistake 或 implementation mistake，分类与现象相符，没有误写成审批或沙箱问题。本次复核的错误 confirmation 是有意的负向检查，也不应记作故障。

## 自然化复读

本记录按工程审计文档处理。机器扫描后人工复读了标题、裁决首段、三组数字边界、表格引导、阻断条件、formal-ready 边界和结尾。没有发现明显 AI 腔；保留的重复术语用于区分一次性迁移工具、持久 collector 和 Windows hard gate，不作同义改写。
