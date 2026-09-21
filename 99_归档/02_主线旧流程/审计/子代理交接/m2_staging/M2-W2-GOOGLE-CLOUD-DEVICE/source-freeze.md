# Google TPU 云端单器件来源冻结

状态：`accept_with_caveat / content_extract_frozen / upstream_body_pending`  
资料截止日：`2026-08-13`

## 已核来源

| 来源 | URL | 在线核查 | 本地内容快照 | 字节 | SHA-256 | 正式拟落路径 | 门状态 |
|---|---|---|---|---:|---|---|---|
| `SRC-M2-GA-G05` | `https://docs.cloud.google.com/tpu/docs/system-architecture-tpu-vm` | 200 等价可读；页面正文显示 last updated 2026-08-05 UTC | `snapshots/2026-08-13/google-cloud-tpu-architecture-2026-08-13.html` | 20,515 | `DDF8F0A880DB456B5EDC190A6EC2FEB63B06C016E86D8583072CD70EAED93841` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-architecture-2026-08-13.html` | `content_frozen` |
| `SRC-M2-GA-G08` | `https://docs.cloud.google.com/tpu/docs/v5e` | 200 等价可读 | `snapshots/2026-08-13/google-cloud-tpu-v5e-2026-08-13.html` | 13,076 | `7BB0A40383503F76C43E728D8868C7F17F1E715A6D0E200F90428471CE646B47` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v5e-2026-08-13.html` | `content_frozen` |
| `SRC-M2-GA-G09` | `https://docs.cloud.google.com/tpu/docs/v5p` | 200 等价可读；页面正文显示 last updated 2026-08-05 UTC | `snapshots/2026-08-13/google-cloud-tpu-v5p-2026-08-13.html` | 15,574 | `C4207909253EF1C0D96298396C080FD2349BDB92A8048C717D582D9BCC2E6C5C` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v5p-2026-08-13.html` | `content_frozen` |
| `SRC-M2-GA-G10` | `https://docs.cloud.google.com/tpu/docs/v6e` | 200 等价可读；页面正文显示 last updated 2026-08-05 UTC | `snapshots/2026-08-13/google-cloud-tpu-v6e-2026-08-13.html` | 11,999 | `65C35FF3C661E7E4CB0C08D382AACC713592D49107D0D1C1C29A27BD58332DC2` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v6e-2026-08-13.html` | `content_frozen` |
| `SRC-M2-GA-G15` | `https://openxla.org/xla/sparsecore` | 200 等价可读；完整抽取到正文第 409 行 | `snapshots/2026-08-13/openxla-sparsecore-2026-08-13.html` | 36,858 | `9F77BA67B06EA8B3091B2842157F6422E261A5D076ACDA1A7203832529935AAD` | `最小参考资料库/快照/Google/TPU/2026-08-13/openxla-sparsecore-2026-08-13.html` | `content_frozen` |
| `SRC-M2-W2-G-TPU-MACHINES-20260813`（staging 候选） | `https://docs.cloud.google.com/compute/docs/tpus/tpu-machines` | 200 等价可读 | `snapshots/2026-08-13/google-cloud-tpu-machines-2026-08-13.html` | 27,322 | `B87A1B00C38354659EFC4FB0073B4DD205CE807E37CFC01252BE6BF5820C96B8` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-machines-2026-08-13.html` | `candidate_reserved` |

## 快照方法与限制

六份本地文件是 2026-08-13 通过联网读取工具取得的渲染文本内容，并包装成可哈希的 UTF-8 HTML；它们保留 URL、访问日、页面行号和正文，不是上游服务器返回字节的逐字副本。浏览器与命令行直取均在 TLS 握手阶段失败，具体表现为 `ERR_CONNECTION_CLOSED`、`UNEXPECTED_EOF_WHILE_READING` 或 Schannel 握手错误；这属于远端或本机网络链路错误，不是用户拒绝、沙箱拒绝或审批失败。两次提权下载获得批准但仍在 TLS 阶段失败。

这些内容快照足以固定本轮页面语义和原文定位。总控裁定来源门为 `accept_with_caveat`：内容提取可按 `other / non-preferred` 作为候选 endpoint，但正式原始响应体冻结仍为 `pending`，不得把本文件标为 `web_snapshot` 或 byte-identical body。`tpu-machines` 的 staging 预留候选为 `SFAM-M2-W2-G-TPU-MACHINES`、`SRC-M2-W2-G-TPU-MACHINES-20260813` 和 `END-M2-W2-G-TPU-MACHINES-EXTRACT-20260813`。endpoint 类型候选用 `other`，`is_preferred_endpoint=false`；notes 必须注明 `renderer-extracted text wrapped as HTML / not upstream response body`。它不替代原始 `html_page`，也不能标为 `web_snapshot`。

## 已核关键边界

- `SRC-M2-GA-G15` 已补入冻结范围。它的规格表直接列出 Trillium 每芯片 2 个 SparseCore，也列出 v5p 96 GiB；后者不能替代 v5p 云产品页的 95 GiB，更不能用于推导 1 GiB 预留。
- `tpu-machines` 把 v6e 的 1t、4t、8t 分别列为 1、4、8 个 TPU 芯片，并把 v5p 4t 列为 4 个芯片和 380 GiB 总 HBM。这些是 VM 或 machine type 聚合配置，不写入单器件。
- 三个产品页分别把 `per chip` 定值与 VM、slice/Pod 配置分表，支持三张 `cloud_accelerator` 器件卡的对象边界。

## 当前阻断

1. `tpu-machines` 的三个 ID 只是总控预留候选，独立复核和正式范围验收前不写正式库。
2. 上游原始响应体未能通过本机 TLS 链路保存。总控已裁定内容提取可按 `other / non-preferred` 进入候选 endpoint，但正式原始响应体冻结仍为 `pending`。
3. 全部来源筛选和反向移除只能在器件事实集合冻结后最终重跑；本包先给出候选结果。