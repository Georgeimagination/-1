# Google 张量处理器来源补取与对抗核验记录

日期：`2026-08-13`  
范围：OpenXLA SparseCore（稀疏计算核）页面与 `tpu-machines` 器件规格段  
结论：官方页面中的规格可以交叉确认，但现有 G15 本地文件仍是缺少 `L0-L147` 的局部提取，不能作为可用 endpoint 合并。

## OpenXLA 补取结果

联网读取 `https://openxla.org/xla/sparsecore` 时，官方页面显示共 410 行，`L69-L87` 可见。`L82-L87` 的表格列出 TPU（Tensor Processing Unit，张量处理器）v4、TPU v5p 和 Trillium，其中 `L84` 为 `SparseCores/Chip | 4 | 4 | 2`。这次读取确认了远端页面仍有目标内容，但没有得到可直接保存为上游响应体的字节流。

随后分别在普通权限和已批准的提权下载中调用 Windows `curl.exe`。普通权限返回退出码 35，错误为 `SEC_E_NO_CREDENTIALS`；提权重试也返回退出码 35，错误为 `SSL/TLS connection failed`。两次都没有生成下载文件。提权请求已获批准，因此失败属于远端或本机 TLS（Transport Layer Security，传输层安全）链路错误，不是用户拒绝、沙箱拒绝、自动审批拒绝或审批连接故障。

包内 `openxla-sparsecore-2026-08-13.html` 仍保持原字节和哈希。它的第一个页面行标记是 `L148`，没有 `L69-L87`。本修复包把它标成 `partial / pending_verification`，不填写正式拟落路径，也不把它当作 G15 断言的证据入口。没有用第三方页面替代 OpenXLA 官方来源。

## 三路核验

核验问题一是“Trillium 每芯片是否有 2 个 SparseCore”。第一路是 OpenXLA 官方页面 `L82-L87`；第二路是 Google Cloud TPU architecture 固定提取的 `L210-L211`；第三路是 `tpu-machines` 固定提取的 `L624-L638`。三处都直接给出 2，未发现相反的一手值。规格事实本身通过核验。

核验问题二是“现有 G15 本地 endpoint 是否能支撑该事实”。三个检查都否定这一点：目标定位 `L69-L87` 不在文件内，文件从 `L148` 开始，哈希匹配只能证明这份局部文件未变化。规格事实成立，不能反推 endpoint 完整。来源门因此继续为 `pending_verification`。

核验问题三是“`tpu-machines` 是否属于器件事实范围”。该页 `L624-L639` 明确使用 `per chip`，直接列出 v5p 和 v6e 的峰值、HBM（High Bandwidth Memory，高带宽存储器）、TensorCore、SparseCore、ICI（Inter-Chip Interconnect，芯片间互联）与 DCN（Data Center Network，数据中心网络）。G09 与 G10 产品页对其中 BF16、HBM 和 ICI 数值给出同向一手核对，未发现把这些行解释为 VM 或 Pod 聚合值的依据。`tpu-machines` 因而在器件候选池中标为 `selected`；后续机器类型表仍按配置层处理。

## 去重决定

候选池统一纳入 G05、G08、G09、G10、G15 和 `tpu-machines`。G08、G09、G10 与 `tpu-machines` 进入本轮反向移除成员。G05 在器件范围内采用的 SparseCore 数量分别由 G09 和 `tpu-machines` 覆盖；G15 的本地 endpoint 未关闭，而且本范围采用的 SparseCore 数量也已有单源覆盖，所以两者标为 `redundant_covered`。覆盖记录按一个 `covering_source_id` 一行拆分，没有把多源组合写成单源全文覆盖。