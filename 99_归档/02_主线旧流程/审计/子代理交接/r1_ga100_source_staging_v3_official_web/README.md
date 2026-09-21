# GA100 v3 官方网页与固定文档快照暂存

本目录为 `R1-CHIP-NVIDIA-GA100` 的 v3 来源工程准备了可复查的 NVIDIA 官方网页和 PDF 快照。它只服务总控后续的来源建模、事实断言和反向移除复核；没有改动 32 张正式表、未来表、既有来源表、资料池清单、模板、校验器、进度文件或既有 `r1_ga100_source_staging/`。

`r1_ga100_23_official_web_status_remediation.md` 和 `r1_ga100_24_software_stack_gap_remediation.md` 中标为候选的官方来源均以 `selected_candidate` 记录。这个标签只表示原报告提出的候选角色，尚未形成正式 `source-screening`、`source-selected-roles` 或 selection run 结论。两份 A100 PCIe Product Brief 以 `lead_candidate` 保留，用于核对 URL 与 PDF 内部版本。DGX A100 价格页和 Developer Forum 仅在 manifest 中标为 `rejected_candidate`，没有下载 payload。

## 目录内容

`payload/html/` 保存 22 个 HTML 主文档的原始响应 body，`payload/pdf/` 保存 5 个官方 PDF 的原始 bytes。每个 HTML/PDF endpoint 还配有 `headers/` 中的完整 redirect response-header 序列，以及 `transfer-meta/` 中的 final URL、HTTP status、content type 和传输字节数。外链 CSS、JavaScript、图片和下载附件没有随 HTML 一起镜像；对应正文 payload 才是本暂存的实际证据 endpoint。

`snapshot-manifest.csv` 是入口级台账，每个实际 endpoint 一行，记录请求 URL、最终解析 URL、状态、content type、访问日期、标题或 PDF 内部版本、页数、bytes、SHA-256、headers 路径和版本风险。`source-family-map.csv` 把同一作品的多版本或多 endpoint 聚在同一来源家族下，避免将 HTML、PDF、版本修订或 feature 页面误算成独立佐证。`download-or-capture-log.csv` 给出逐 endpoint 的获取结果和重试路径。`capture-input.tsv` 保留本轮下载输入与文件命名规则。

## 已固定的版本边界

40 GB A100 PCIe Product Brief 的封面与历史表为 `PB-10137-001_v03`，共 19 页。80 GB brief 的请求 URL 仍写 `v02`，下载 PDF 的封面与历史表为 `PB-10577-001_v03`，共 20 页，正式建模应以 PDF 内部版本为准。未带版本的 MIG PDF endpoint 在本次快照中为 `Release r580`，74 页；`latest` HTML 和 unversioned supported-GPUs 页面也按 2026-08-21 的 raw HTML 保存，后续不得把它们当作不可变链接。vGPU User Guide 的封面为 `Release 20.0-20.2`、2026-07-31，共 360 页。

AI Enterprise 8.2 support matrix 与五个 vGPU feature 页面保留了 URL 内的 `latest` 风险。PyTorch/TensorFlow 20.06 和 20.07、CUDA 11.0 GA、NCCL 2.7.6、cuDNN 8.x archive、cuSPARSELt 0.0.1，以及 TensorRT 8.6.1 的 Release Notes、Support Matrix 和 Developer Guide 都已保存为 raw HTML。三份 TensorRT 请求 URL 实际重定向到 `archive.docs.nvidia.com`，两端 URL 均在 manifest 中保留。

## 使用边界

本目录不替代源码级精读或正式来源筛选。正式写入前，总控仍需按字段、对象层级和 source family 复核内容，生成正式 source、endpoint、assertion、search 和 selection 记录，并重跑反向移除。这里没有运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 或 `Validate-ResearchData.ps1`，也没有把这三道正式门的状态写成通过。

中文文档已分别完成 `report-humanizer` 单文件扫描，并从结尾向前复读版本边界、候选状态、payload 类型、外链资源范围和正式写入边界。机器扫描和人工复读的结果写在 `validation_report.md`。
