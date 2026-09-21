# Google 张量处理器云端单器件来源冻结

状态：`remediated / five_extracts_frozen / g15_partial_pending / upstream_body_pending`  
资料截止日：`2026-08-13`

本表冻结 Google TPU（Tensor Processing Unit，张量处理器）器件范围内的内容提取，并用 SHA-256（安全哈希算法）校验文件没有变化。

## 固定内容与来源门

| 来源 | URL | 本地提取 | 字节 | SHA-256 | 正式拟落路径 | 门状态 |
|---|---|---|---:|---|---|---|
| `SRC-M2-GA-G05` | `https://docs.cloud.google.com/tpu/docs/system-architecture-tpu-vm` | `snapshots/2026-08-13/google-cloud-tpu-architecture-2026-08-13.html` | 20,515 | `DDF8F0A880DB456B5EDC190A6EC2FEB63B06C016E86D8583072CD70EAED93841` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-architecture-2026-08-13.html` | `content_frozen` |
| `SRC-M2-GA-G08` | `https://docs.cloud.google.com/tpu/docs/v5e` | `snapshots/2026-08-13/google-cloud-tpu-v5e-2026-08-13.html` | 13,076 | `7BB0A40383503F76C43E728D8868C7F17F1E715A6D0E200F90428471CE646B47` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v5e-2026-08-13.html` | `content_frozen` |
| `SRC-M2-GA-G09` | `https://docs.cloud.google.com/tpu/docs/v5p` | `snapshots/2026-08-13/google-cloud-tpu-v5p-2026-08-13.html` | 15,574 | `C4207909253EF1C0D96298396C080FD2349BDB92A8048C717D582D9BCC2E6C5C` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v5p-2026-08-13.html` | `content_frozen` |
| `SRC-M2-GA-G10` | `https://docs.cloud.google.com/tpu/docs/v6e` | `snapshots/2026-08-13/google-cloud-tpu-v6e-2026-08-13.html` | 11,999 | `65C35FF3C661E7E4CB0C08D382AACC713592D49107D0D1C1C29A27BD58332DC2` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v6e-2026-08-13.html` | `content_frozen` |
| `SRC-M2-GA-G15` | `https://openxla.org/xla/sparsecore` | `snapshots/2026-08-13/openxla-sparsecore-2026-08-13.html` | 36,858 | `9F77BA67B06EA8B3091B2842157F6422E261A5D076ACDA1A7203832529935AAD` | 不拟合并 | `partial / pending_verification` |
| `SRC-M2-W2-G-TPU-MACHINES-20260813` | `https://docs.cloud.google.com/compute/docs/tpus/tpu-machines` | `snapshots/2026-08-13/google-cloud-tpu-machines-2026-08-13.html` | 27,322 | `B87A1B00C38354659EFC4FB0073B4DD205CE807E37CFC01252BE6BF5820C96B8` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-machines-2026-08-13.html` | `candidate_selected / content_frozen` |

## 提取类型

六份文件都是联网读取工具返回的渲染文本，再包装成可哈希的 UTF-8（Unicode 文本编码）HTML。它们不是上游服务器的逐字响应体。G05、G08、G09、G10 和 `tpu-machines` 五个文件包含本包使用的定位，可以作为 `other / non-preferred` 候选；notes 固定为 `renderer-extracted text wrapped as HTML / not upstream response body`。它们不能标成 `web_snapshot`，也不能替代远端 `html_page`。

G15 单独处理。该文件的第一个页面行标记是 `L148`，缺少 `L0-L147`，正式 G15 断言使用的 `L69-L87` 不在文件中。`source-candidates.csv` 将它保留为 `other / non-preferred / pending_verification`，但清空正式拟落路径，notes 明确写出 `partial` 与缺失区间。它不能支撑 G15 事实，也不能进入正式 endpoint 表。

## 补取错误分类

联网读取器能看到 OpenXLA 官方页面的 410 行正文和 `L69-L87`，但没有提供可直接保存的上游响应体。Windows `curl.exe` 的普通权限尝试返回退出码 35 和 `SEC_E_NO_CREDENTIALS`；已批准的提权重试仍返回退出码 35 和 `SSL/TLS connection failed`，两次都没有生成文件。这是远端或本机 TLS（Transport Layer Security，传输层安全）链路错误，不是用户拒绝、沙箱拒绝、自动审批拒绝或审批连接故障。详情见 `remote-retrieval-log.md`。

## 规格与范围边界

`tpu-machines` 的 `L624-L639` 明确使用 `per chip`，列出 v5p、v6e 的峰值、HBM（High Bandwidth Memory，高带宽存储器）、TensorCore、SparseCore（稀疏计算核）、ICI（Inter-Chip Interconnect，芯片间互联）与 DCN（Data Center Network，数据中心网络）。它属于器件事实候选范围，同时也在后续行提供机器类型和 VM 聚合配置。前一段可进入器件来源选择，后一段继续留在配置层。

该页 `L518-L523` 只列 TPU7x、v6e 和 v5p，不含 v5e。因此 `CFGDISP-GOOGLE-V5E-MACHINE-TYPES` 已移除 `tpu-machines` 映射。v5e 的 `ct5lp-hightpu-*` 仍由 G08 等实际包含 v5e 的页面支撑。

G15 远端页面中的 Trillium 2 SparseCore 规格由 G05 `L210-L211` 和 `tpu-machines L624-L638` 两路官方固定内容交叉确认。本包选择 `tpu-machines` 承担固定证据，G05 作为可替代交叉来源，G15 endpoint 保持待补。v5p 的 95 GiB 云端值和 96 GiB 物理值继续分层，不能推导 1 GiB 预留；G15 的 32 GiB 也不改写 G10 的 32 GB 原值。

## 当前可接收范围

总控可在独立复核通过后考虑 `tpu-machines` 的 family、source、远端 `html_page` 和本地 `other` endpoint 候选，以及 G05、G08、G09、G10 的四个新增 `other` endpoint。G15 本地 endpoint、六份文件的 `web_snapshot` 说法和上游响应体完成状态都不能接收。任何来源文件哈希或器件事实集合改变后，来源选择必须重跑。