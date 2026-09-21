# GA100 v3 官方网页与固定文档快照校验

本次暂存记录了 29 个 manifest 条目：27 个 endpoint 获取成功，包含 22 个 raw HTML 主文档和 5 个原始 PDF；2 个条目是 r23 已拒绝的 DGX system price 与 Developer Forum EOL 线索，没有保存 payload。所有成功 endpoint 的 HTTP status 为 200。`snapshot-manifest.csv` 中的 bytes、SHA-256、final URL、content type 和本地路径已按 payload 与 transfer metadata 重新核对。

## 内容完整性

27 个成功 payload 都有对应的 header 文件和 transfer metadata 文件。HTML 使用原始响应 body 保存，因而不依赖搜索结果摘要或 print-to-PDF 替代品。PDF 保留服务端返回的原始 bytes。HTML 外链的 CSS、JavaScript、图片和附件没有一并获取，正文的实际 evidence endpoint 已在 manifest 的 `requested_endpoint_url`、`final_url` 与 `local_payload_path` 中写清。

来源家族映射覆盖 manifest 的全部 29 个 ID。PyTorch 20.06/20.07、TensorFlow 20.06/20.07、MIG 的 HTML/PDF 多入口和 AI Enterprise 的 A100 profile 与 feature 页面都按 family 归并，未把版本修订或 companion endpoint 当成额外独立佐证。

## 固定文档和动态地址核对

两份 A100 PCIe Product Brief 都已用第一页和 Document History 复查内部版本。40 GB 文件为 `PB-10137-001_v03`、19 页；80 GB 文件请求 URL 中仍是 `v02`，内部版本为 `PB-10577-001_v03`、20 页。MIG 无版本 PDF 的内部标识为 `Release r580`、74 页。vGPU User Guide 的内部标识为 `Release 20.0-20.2`、2026-07-31、360 页。

MIG `latest`、MIG supported-GPUs、vGPU lifecycle 和路径含 `latest` 的 AI Enterprise 页面都以快照记录，不能只引用在线地址。TensorRT 8.6.1 的三个请求 URL 均实际解析到 `archive.docs.nvidia.com`，manifest 保留请求和最终 URL。cuSPARSELt HTML title 标为 0.0.1，CUDA、NCCL、cuDNN、framework container 和 TensorRT endpoint 的版本化路径也已逐项保存。

## 失败、拒绝与正式门范围

本轮 27 个请求没有 remote service error、sandbox denial、tool runtime failure、用户中断或 operator mistake。两条未下载记录属于范围内的 `rejected_candidate`，不是网络失败：DGX A100 价格只对应系统对象，Forum 回复不构成正式 lifecycle endpoint。若未来需要重新固定某个成功 endpoint，可按 `download-or-capture-log.csv` 的 requested URL 重放，并比较重新计算的 SHA-256。

本任务未更改正式数据或资料池，也没有运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1`。因此本报告不声明任何正式门通过。正式接收前仍需由总控建立 source/version/endpoint 元数据、逐事实断言、筛选角色和反向移除记录。

## 文本复核

`README.md` 和本文件已分别用 `report-humanizer` 做单文件机器扫描，结果均为 `No machine-detectable AI tells found`。随后从末节向前复读，检查了动态 URL 的版本风险、Product Brief 的 URL 与内部版本差异、MIG r580、vGPU 20.0-20.2、TensorRT 重定向、候选与正式 selected 的边界，以及未运行正式门的说明。未发现需要修改的模板化标题、泛化转场或结尾套话。剩余风险来自动态网页后续更新和正式 source/selection 尚未建模，不来自当前文档表达。
