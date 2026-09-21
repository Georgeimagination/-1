# 资料池 113 份 PDF 的差异复核

状态：`recommend_A_register_113_baseline`  
日期：2026-08-21  
范围：只读核对 `论文/`、四项资料清单、正式来源表、冻结名单和第三波审计链；本任务仅新增本文件。

## 裁决

建议采用 A：把两份 AMD 官方 brochure 登记为资料池的第 112、113 份内容去重 PDF，并将资料池基线从 111 份更新到 113 份。两份文件都有 2026-08-13 第三波组合事务的正式载荷记录，当前仍被 `source-endpoints.csv` 的已复核 `local_pdf` 入口引用，并且分别属于已复核的最小来源选择成员。只从 `论文/` 移走文件会立刻让两条正式 local endpoint 失效，破坏历史对象的恢复链。

这个裁决只修复资料池清单与磁盘的不一致，不改变 49 款芯片的分母、对象身份、事实、断言、选择运行或资料卡状态。MI455X EAM 模组和 MI350P PCIe 卡仍按 DEC-031 保持在主线外；它们的既有正式记录只作历史证据。MI455X 的冻结 GPU package 后续需要单独做对象层级重切，不能把现有 `module` 行直接改写成 `package` 事实。

## 当前差异与文件核验

对 `清单/论文PDF清单.csv` 以 CSV 语义读取，并与 `论文/**/*.pdf` 逐路径比较，结果为清单 111 行、磁盘 113 份，清单缺失路径为以下两项；不存在清单有而磁盘无的路径。

| 文件 | SHA-256 | 字节 | 页数 | 文件修改时间 | PDF 标题 |
|---|---|---:|---:|---|---|
| `论文/AMD_Instinct/02_厂商产品资料/2026_AMD_Instinct_MI455X_GPU_Brochure.pdf` | `6555fef1399a35f472e325dc61936d293e129735ec1e191d5fd0f3b6fa0c4208` | 659,374 | 2 | 2026-08-13T09:25:54+08:00 | AMD Instinct 455X GPU |
| `论文/AMD_Instinct/02_厂商产品资料/2026_AMD_Instinct_MI350P_PCIe_Card_Brochure.pdf` | `a4e93edffc6c2a03668eef72b84d85e1d2586afb331c2228595d1549609afb29` | 782,486 | 2 | 2026-08-13T12:18:16+08:00 | AMD Instinct MI350P PCIe Card |

两份合计 1,441,860 字节、4 页。因此完整资料池的可复核物理计数为 113 份、315,363,681 字节和 2,214 页。四项现有清单的 SHA-256 均仍等于 `Test-SourcePool.ps1` 当前冻结值：PDF 清单为 `c8c43df...cdb38b27`，网页清单为 `f19991c...2aa1395f`，待补清单为 `b5a5993...a02307bd`，汇总 JSON 为 `eee940c...2b41db7`。这证明差异来自未登记文件，没有发生已登记清单的静默改写。

`pdfinfo` 成功读取两份文件，均为两页 Letter PDF。MI455X 文件的文档标识是 `LE-93204-00 07/26; PID 5158303`；MI350P 为 `LE-93401-00 05/26`。在 113 份正式资料池内部按 SHA-256 分组，没有发现重复哈希。

## 进入资料池的时间和事务来源

两份文件均可追溯到 2026-08-13 的已完成第三波工作包，而非后续人工复制。

MI455X 路径由 `M2-W3-AMD-MI455X-MODULE` 写入。其事务包的 `new-file-targets.csv` 将 staging 的 `amd-instinct-mi455x-brochure-2026-08-13.pdf` 作为第三个 `source_copy` 载荷，目标正是当前 `论文/` 路径；正向演练 journal 也记录了同一目标与哈希。MI350P 的 `M2-W3-AMD-MI350P-CARD` 事务包以相同方式写入其 brochure。`进度/当前状态.md` 和任务台账随后确认第三波组合事务已真实写入 1,057 个签字主键和 15 个载荷，其中包括这 2 份固定官方 PDF，事务未回滚。

每个正式池文件都与对应 staging 固定候选完全同哈希：MI455X 的候选位于 `审计/子代理交接/m2_staging/M2-W3-AMD-MI455X-MODULE/fixed-candidates/amd-instinct-mi455x-brochure-2026-08-13.pdf`，MI350P 位于 `审计/子代理交接/m2_staging/M2-W3-AMD-MI350P-CARD/fixed-candidates/amd-instinct-mi350p-product-brochure-2026-08-13.pdf`。这是事务前固定原件与正式池副本之间有意保留的审计镜像，不是正式池内部的重复文件，也不能据此删除任何一方。

## 正式证据链及冻结范围的影响

两份来源都已经完整登记在正式最小参考资料库中。MI455X 的来源 ID 是 `SRC-M2W3-AMD-MI455X-BROCHURE-202607`，其 local endpoint 为 `END-M2W3-AMD-MI455X-BROCHURE-LOCAL`；MI350P 对应 `SRC-M2W3-AMD-MI350P-BROCHURE-202605` 和 `END-M2W3-AMD-MI350P-BROCHURE-LOCAL`。两个 endpoint 的 local path、哈希、2 页、访问日期与本次磁盘复算一致。跨平台恢复检查也通过：32 张正式表、153 个 endpoint、79 个 local path 与哈希、11 次选择运行和 106 个成员均可解析。

从已录入的逐来源断言看，MI455X brochure 支持 29 个不同事实，覆盖精确峰值表、8 XCD、2 IOD、HBM4、CPU 到 GPU 带宽与 RAS 等内容；反向移除成员 `SELMEM-M2W3-AMD-MI455X-BROCHURE` 明确把它列为不可替代的 `core_spec`。MI350P brochure 支持 15 个不同事实，包括 4 XCD、1 IOD、FHFL PCIe CEM 卡形态、PCIe 128 GB/s 与带 Estimated 限定的 FP16、FP32、FP64 vector 峰值；它同样是 `SELMEM-M2W3-AMD-MI350P-BROCHURE` 的不可替代成员。两份 brochure 和各自动态产品页互有重叠，却都被 `source-coverage.csv` 或选择说明判为部分覆盖，不能当作内容等价。

这些不可替代结论的对象范围需要分开理解。当前 `OBJ-AMD-MI455X` 是 `module`，`OBJ-AMD-MI350P` 是 `card`，二者在活动范围映射表中都是 `out_of_scope_nonchip`。MI350P 仅通过已纳入的 CDNA4 XCD 共享设计组关联；卡级 brochure 不能直接把卡级容量、功耗、PCIe 或峰值下放为 CDNA4 die 的事实。MI455X 则在冻结名单中同时出现为已排除的 EAM module 和已纳入的 GPU package。brochure 确实给出 GPU 多芯粒 package、EAM module 以及四 GPU compute tray 的分层表述，但当前正式事实把它的可用证据归到 `module`。因此它是后续 MI455X GPU package 工作包的重要一手线索，却还不是该 package 的已关闭正式证据链；必须重新建立 package 对象、原子事实和选择运行，不能复用 module 主语。

## 登记为 113 基线时的同步项

以下是 A 的完整同步边界。正式来源表、对象表、事实、断言、筛选、覆盖、选择运行和选择成员不应在这次资料池登记中改动。

`清单/论文PDF清单.csv` 需要新增两条 AMD Instinct、2026、`厂商产品资料` 行。MI455X 行应使用标题 `AMD Instinct MI455X GPU`、文档标识 `LE-93204-00 07/26; PID 5158303`、AMD 官方 PDF URL `https://www.amd.com/content/dam/amd/en/documents/products/accelerators/instinct/amd-instinct-mi455x_brochure.pdf`、上述正式池路径、2 页、659,374 字节、哈希 `6555...4208` 和 `PDF解析=通过`。MI350P 行应使用标题 `AMD Instinct MI350P PCIe Card`、文档标识 `LE-93401-00 05/26`、AMD 官方 PDF URL `https://www.amd.com/content/dam/amd/en/documents/epyc-business-docs/other/amd-instinct-mi350p-product-brochure.pdf`、上述正式池路径、2 页、782,486 字节、哈希 `a4e9...fb29` 和 `PDF解析=通过`。两个 `源文件` 应指向相应 M2 staging fixed candidate，`来源项目` 明确写为 M2 第三波 AMD 工作包，避免伪称来自两个历史调研目录。

`清单/汇总统计.json` 至少要把 `unique_pdfs` 更新为 113、`platform_pdf_counts["AMD Instinct"]` 更新为 6。原有 `category_pdf_counts["AMD Instinct / 官方白皮书与技术资料"]` 保持 4，并新增 `category_pdf_counts["AMD Instinct / 厂商产品资料"]=2`。`combined_online_urls=893`、`pending_papers=11`、网页清单和待补清单均不变。JSON 中的 `source_pdf_occurrences`、`duplicates_removed`、`paper_inventory_records` 与 `paper_inventory_downloaded` 来自旧版 `collect_references.py` 的两个历史项目绝对路径和旧 `.tmp/paper_inventory_final.json`，该生成器不覆盖本主线第三波 staging 输入。不能在不先修正其输入范围与语义的情况下臆填这四个字段。正式同步时应先决定把这两份 M2 固定候选纳入该生成器的来源账本，随后由同一生成规则产出这些派生值；手工只改 `unique_pdfs` 会让汇总 JSON 的来源口径继续不自洽。

`scripts/validation/Test-SourcePool.ps1` 需要把 PDF manifest row count 与 disk PDF count 的预期值由 111 改为 113，PDF total bytes 由 313,921,821 改为 315,363,681，页数预期由 2,210 改为 2,214，`Summary unique_pdfs` 由 111 改为 113。`expectedHashes` 中 PDF manifest 和汇总 JSON 的 SHA-256 必须取最终写入文件的实际值；网页清单和待补清单的预期哈希不应改变。脚本的 URL 计数 914、893、892 和待补 11 均不应改变。

同步完成后还要更新活动叙述中的旧基线：`README.md`、`AGENTS.md`、`参考资料总览.md`、`研究计划.md` 和 `进度/当前状态.md`。历史验收、归档冻结材料、第三波事务备份及任务台账记录的是当时状态，不应回写。活动文档应写明两份 2026-08-13 官方 product brochure 已补登记，而不把 A 解释为 MI455X module 或 MI350P card 回到 49 芯片主线。

## 不采用 B 或 C 的原因

B 只有在主代理决定撤销两条历史对象的完整来源链时才成立。届时必须先把两个 `source-endpoints.local_path`、相关 sources、逐来源断言、筛选、覆盖、选择成员和两张历史卡迁入专门的历史证据模型，再用 Windows 硬门重审；单独移动 PDF 不是可恢复处置。MI350P 的主线外范围本身不足以支持这种迁移，因为 DEC-031 要求保留既有非芯片数据和原始资料的审计价值。MI455X 还会丢失后续 package 工作包需要重新判别的一手线索。

C 不成立。正式池内没有相同 SHA-256 的第二份文件；staging 与正式池同哈希是已签字事务源件和落盘载荷的可追溯镜像。应按该哈希继续验证两处一致，不应删除或折叠到一个路径。

## 关闭条件和运行限制

完成 A 后，从 Windows 正式根以默认参数运行 `Test-SourcePool.ps1`，预期所有 critical check 通过；`pdfinfo.exe` 缺失时的既有 noncritical warning 可按脚本定义保留。接着运行 `Test-ChipScope.ps1` 与 `Validate-ResearchData.ps1 -SubjectContractMode gate`，以确认只改资料池登记没有伤及 49 芯片范围和正式数据。MI455X GPU package 的证据重切不属于本关闭条件，应留给该芯片的独立 R1 工作包。

当前 macOS 环境未找到 `pwsh`、`powershell` 或 `powershell.exe`，因此本次未实际运行三个 PowerShell 硬门。这是 `tool/runtime failure`，即项目规定运行时缺失，不是 sandbox denial、approval failure、remote service error 或用户拒绝。`verify_recovery_paths.py --root .` 已通过，但它只检查恢复路径、local endpoint 哈希和 selection 引用，不能替代三道硬门。

本次只读过程的四项非结论性工具异常也已收敛：两次宽范围检索触发输出长度上限，分类为 `tool/runtime failure`，随后改用目标文件与目标 source ID 重新读取；一次 Ruby 统计命令使用当前运行时不支持的 `Array#tally` 而中止，分类为 `tool/runtime failure`，其后的兼容计数命令已得到 29 和 15 个唯一事实；一次 `git diff --check` 因此目录不是 Git worktree 而不可用，分类为 `operator mistake`，没有产生写入；一次文件大小查询遗漏运行根而未命中目标，分类为 `operator mistake`，已在正确运行根重试并确认本交接文件为 11,753 字节。没有发生写入失败、权限拒绝、网络请求、审批请求、用户中断或 sandbox denial。

## 自然化复读

本文件按工程审计记录处理。机器扫描后再人工复读了标题、裁决段、两处范围区分、同步边界和结束条件；删去了把资料池登记误写成对象纳入、把历史证据误写成 frozen package 事实的表述。剩余风险来自尚未执行的 Windows 硬门，以及旧版汇总生成器没有覆盖第三波来源账本，这两项需要主代理在正式写入时关闭。
