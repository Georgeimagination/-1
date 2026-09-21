# Google 云端单器件来源修复交接

- 任务状态：`ready_for_independent_review`
- 输入报告：`审计/子代理交接/m2_review_google_cloud_device_gate.md`
- 写入范围：`审计/子代理交接/m2_staging/M2-W2-GOOGLE-CLOUD-DEVICE-REMEDIATED/`
- 对象层级：TPU（Tensor Processing Unit，张量处理器）v5e、v5p、v6e 的 `cloud_accelerator`；对象与架构关系已由总控以 `needs_resolution` 预留

## 完成内容

修复包从原包完整复制后独立修改，没有回写原包或正式库。G15 本地文件保持原字节和哈希，按首行 `L148` 认定为局部提取；候选 endpoint（访问入口）改为 `pending_verification`，正式拟落路径清空。OpenXLA 官方页面的 `L69-L87` 可以在线读取，但两次原始响应体下载都因 TLS（Transport Layer Security，传输层安全）失败，未生成文件，也没有使用第三方替代。

来源选择已经把 G05、G08、G09、G10、G15 和 `tpu-machines` 放入同一器件候选池。G08、G09、G10 与 `tpu-machines` 为选择成员；G05 和 G15 为 `redundant_covered`。四条 SparseCore（稀疏计算核）覆盖记录都只有一个覆盖来源。G15 的 96/32 GiB 没有与 G09/G10 的 95 GiB/32 GB 合并。

配置处置保留七组，v5e 机器类型行删除了不含 v5e 的 `tpu-machines` 映射。14 个父待办仍映射为 15 个持久处置项；v6e 组件行的 2 SparseCore 固定证据改用 `tpu-machines L624-L638`，95/96 GiB 分支和禁止推导 1 GiB 的规则没有变化。

## 读取来源

本包核对了 G05、G08、G09、G10、G15 和 `tpu-machines` 的六个本地提取，以及 OpenXLA 与 Google Cloud 的官方在线页面。G15 规格通过 OpenXLA 远端正文、G05 `L210-L211` 和 `tpu-machines L624-L638` 三路核验。`tpu-machines L624-L639` 的表头和字段都明确写为 `per chip`，因此不能继续标为器件 `out_of_scope`。

## 验证

包内校验器通过 282 项检查。项目正式校验器只读运行通过 93,251 项检查。校验器会读取证据定位，不再只检查哈希。最终冻结清单生成后，独立复核者还应核对 `package-manifest.csv` 与 `package-freeze.sha256`。

## 未关闭事项

G15 的完整、可哈希官方响应体仍未取得，来源门继续 `pending_verification`。五个可用提取也只是 `other / non-preferred`，不是 `web_snapshot` 或上游响应体。事实集合、三张器件卡、配置 facts、v5p 物理 package 和正式 selection run 都不在本修复包范围内。

## 建议复核顺序

先运行 `Validate-Package.ps1`，再人工核对 G15 首行、`tpu-machines L624-L639` 和四个选择成员的移除后缺口。复核通过后，总控可以考虑合并 `tpu-machines` 的 family/source/两类 endpoint，以及 G05、G08、G09、G10 的四个 `other` endpoint；G15 endpoint 继续禁入。

## 写入文件

本修复包包含原包的六个本地提取，并修改或新增 README、对象与关系引用、deferred 和配置处置、来源候选、来源选择、来源冻结、补取日志、合并说明、校验器、校验记录和本交接文件。包外文件均未由本子任务修改。