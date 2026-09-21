# GA100 v3 官方网页与固定文档快照校验 v2

本目录是 v1 暂存包的完整修正版。`r1_ga100_27_official_web_snapshot_independent_review.md` 已裁决 v1 为 `reject`，原因仅为 `R1GA100-WEB-010` 的 `source_family` 字符串不一致。v2 将 manifest、source-family map 与 capture input 统一为 `NVIDIA AI Enterprise Infra 8.2 support matrix`，没有重新下载或改写 payload。v1 保持原样，v2 仍为待独立验收。

v2 有 29 个 manifest 条目：27 个 endpoint payload 完整复制，包含 22 个 raw HTML 主文档和 5 个原始 PDF；2 个条目是 r23 已拒绝的 DGX system price 与 Developer Forum EOL 线索，没有保存 payload。所有成功 endpoint 的 HTTP status 为 200。`snapshot-manifest.csv` 中的 bytes、SHA-256、final URL、content type 和本地路径已按 v2 payload 与 transfer metadata 重新核对。

## v2 修复与复算结果

`R1GA100-WEB-010` 在 manifest、source-family map 和 capture input 中都精确写为 `NVIDIA AI Enterprise Infra 8.2 support matrix`。其 family ID 仍为 `SFAM-R1GA100-NVIDIA-AI-ENTERPRISE-INFRA-8-2`，endpoint membership 没有变化。v1 的旧字符串仍保留在 v1 目录，证明修复没有覆盖被拒收的原始暂存包。

| 检查范围 | v2 结果 |
|---|---|
| manifest、来源家族、capture input 与 capture log 的 ID 集合 | 29、29、27、29 行集合均精确匹配各自边界；19 个 family 对 29 个 endpoint 恰好一次覆盖 |
| payload 集合、bytes 与 SHA-256 | 27 个磁盘 payload 与 27 个成功 manifest 行精确相等；总计 15,817,628 bytes；逐文件 bytes 与 SHA-256 全部匹配 |
| HTTP metadata | 27 个 transfer metadata、27 个 headers 与 manifest 的 final URL、200 status、content type 和传输 bytes 全部一致 |
| PDF 固定版本和页数 | Newsroom 3 页；40 GB brief `PB-10137-001_v03` 19 页；80 GB brief `PB-10577-001_v03` 20 页；MIG r580 74 页；vGPU 20.0-20.2 360 页 |
| rejected 记录 | 2 条 rejected 行仍无 payload 路径、bytes、SHA-256 或 header；磁盘 payload 中没有 DGX price 或 Forum 文件 |
| v1 与 v2 的原始载荷材料 | `payload/`、`headers/`、`transfer-meta/` 和 `transfer-errors/` 逐目录 byte-identical |

首轮本地 PDF 正文检查对 Newsroom 标题使用了一个与 `pdftotext` 输出不完全相同的弯引号写法，造成假阴性。该问题属于 operator check criterion mismatch，不是 payload、PDF 解析或远端 endpoint 失败。改用正文中的稳定短语后重跑，全部检查通过。

随后一条汇总检查命令误在外层总目录运行，使相对 staging 路径无法解析。该问题属于 operator/context mistake，没有写入 v1 或 v2；在主线运行根重跑后，表中的最终结果为通过。

## 内容完整性

27 个成功 payload 都有对应的 header 文件和 transfer metadata 文件。HTML 使用原始响应 body 保存，因而不依赖搜索结果摘要或 print-to-PDF 替代品。PDF 保留服务端返回的原始 bytes。HTML 外链的 CSS、JavaScript、图片和附件没有一并获取，正文的实际 evidence endpoint 已在 manifest 的 `requested_endpoint_url`、`final_url` 与 `local_payload_path` 中写清。

来源家族映射覆盖 manifest 的全部 29 个 ID。`R1GA100-WEB-010` 的 manifest、source-family map 和 capture input 现在精确使用同一 canonical string。PyTorch 20.06/20.07、TensorFlow 20.06/20.07、MIG 的 HTML/PDF 多入口和 AI Enterprise 的 A100 profile 与 feature 页面都按 family 归并，未把版本修订或 companion endpoint 当成额外独立佐证。

## 固定文档和动态地址核对

两份 A100 PCIe Product Brief 都已用第一页和 Document History 复查内部版本。40 GB 文件为 `PB-10137-001_v03`、19 页；80 GB 文件请求 URL 中仍是 `v02`，内部版本为 `PB-10577-001_v03`、20 页。MIG 无版本 PDF 的内部标识为 `Release r580`、74 页。vGPU User Guide 的内部标识为 `Release 20.0-20.2`、2026-07-31、360 页。

MIG `latest`、MIG supported-GPUs、vGPU lifecycle 和路径含 `latest` 的 AI Enterprise 页面都以快照记录，不能只引用在线地址。TensorRT 8.6.1 的三个请求 URL 均实际解析到 `archive.docs.nvidia.com`，manifest 保留请求和最终 URL。cuSPARSELt HTML title 标为 0.0.1，CUDA、NCCL、cuDNN、framework container 和 TensorRT endpoint 的版本化路径也已逐项保存。

## 失败、拒绝与正式门范围

v2 没有重新发起网络请求，payload、headers、transfer metadata 和空 stderr 文件均从 v1 按字节复制。复制本身没有出现 sandbox denial、tool runtime failure 或用户中断；后续两次本地检查的 operator mistake 已在本报告的复算结果中如实记录。两条未下载记录属于范围内的 `rejected_candidate`，不是网络失败：DGX A100 价格只对应系统对象，Forum 回复不构成正式 lifecycle endpoint。若未来需要重新固定某个成功 endpoint，可按 `download-or-capture-log.csv` 的 requested URL 重放，并比较重新计算的 SHA-256。

本任务未更改正式数据或资料池，也没有运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1`。因此本报告不声明任何正式门通过。正式接收前仍需由总控建立 source/version/endpoint 元数据、逐事实断言、筛选角色和反向移除记录。

## 文本复核

`README.md` 和本文件已分别用 `report-humanizer` 做单文件机器扫描，结果均为 `No machine-detectable AI tells found`。随后从末节向前复读，检查动态 URL 的版本风险、Product Brief 的 URL 与内部版本差异、MIG r580、vGPU 20.0-20.2、TensorRT 重定向、canonical family label、v1 reject、v2 待独立验收边界，以及未运行正式门的说明。没有发现需要修改的模板化标题、泛化转场或结尾套话。剩余风险是动态页面可能继续变化，且 v2 尚未独立验收。
