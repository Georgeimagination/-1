# Helios 身份与 72 数量来源门

- 状态：`passed_with_status_caveat`
- 主对象：`OBJ-AMD-HELIOS-72-MI455X`
- 裁定口径：参考机架观察卡，只接收一手来源直接陈述的 rack 事实
- 截止日：2026-08-12；网页快照取得日：2026-08-13

## 裁决

对象身份和“72 个 MI455X”来源门已经通过。AMD Helios 产品页在本地快照第 11208 行把它称为 AMD 首个 rackscale AI reference design，并直接写出 72 个 MI455X；第 11268 行又明确说明它是参考设计，不是销售产品。MI400 页面第 6935 行独立重复了 72 个 MI455X，因此数量不是从对象名或包含关系推出来的。

日期与状态门只通过到 `announced`。2026-01-05 的 AMD CES 新闻稿称其为 early look；Helios 页面第 11288 行写的是 2026 年下半年预计进行规模部署。这两句话都不能证明已经交付、可订购或进入量产爬坡。

## 固定来源

| 来源 | 本地文件 | 字节数 | SHA-256 | 本地定位 |
|---|---|---:|---|---|
| AMD Helios 产品页 | `fixed-candidates/amd-helios-rackscale-2026-08-13.html` | 282127 | `ed1642ec9ec16f9a5db4a8956b367e9859a3b2f47f9b18fcfe441fc56c34c6b7` | 8028、9058、9068、9088、10414、11208 至 11288、11722 |
| AMD Instinct MI400 页面 | `fixed-candidates/amd-instinct-mi400-2026-08-13.html` | 318594 | `aa5603704c4d77d1e912a5921e289ccabaa45111bab209c2ce08975aedc58a7e` | 6935、7531、8252、11959、12039、13098 |
| AMD CES 2026 新闻稿 | 正式快照 `最小参考资料库/快照/AMD/CDNA6/2026-08-12/amd-ces2026-cdna6-2026-08-12.html` | 120072 | `c2d36db9db2f7d269dc4db51ba4125e4556dd666270c010ac715eed0d9e6009f` | 290，News Highlights 与 The blueprint for yotta-scale compute |

两个新页面的 HTTP 状态均为 200，MIME 均为 `text/html`。HEAD 返回的 Last-Modified 分别为 2026-08-12 15:40:12 UTC 和 17:39:49 UTC。它们仍是会变化的产品页，所以本包只认上述内容哈希对应的快照。

MI455X 独立产品页没有固定。它是 module 页面，而 Helios 身份、72 数量和状态门已经由对象匹配的 rack 页面与 MI400 页面通过；本包又禁止抽取或乘算 module 数值，因此把该页记为 `deferred_out_of_scope`，不是“未公开”或访问失败。

## 四道门

| 门 | 裁决 | 证据边界 |
|---|---|---|
| 对象身份 | `pass` | Helios 页面直接说明 rackscale reference design，并给出 double-wide ORW rack 形态 |
| 72 个 MI455X | `pass` | Helios 与 MI400 两个固定官方页面均直接写 72 |
| 日期与状态 | `pass_with_caveat` | 规范为 `announced`；保留 early look 与 expected in 2H 2026 原词，不上卷为 available |
| rack 直报规格 | `pass_with_caveat` | 只收页面直接给出的 rack 数值；1.67 PB/s 保留精确原值并用同页 1.7 PB/s 记录定性理论峰值；互联带宽峰值/持续值、带宽方向、稀疏条件和“AI exaflops”数据格式按未说明处理 |

## 固定过程中的错误分类

最初的 PowerShell 网页请求没有生成文件且没有返回可用诊断，按工具或运行时失败记录；随后 `curl` 返回 `SEC_E_NO_CREDENTIALS`，属于本机 Schannel 凭据运行时错误。第一次 Python 保存因内联脚本路径编码变成问号，是命令构造与编码处理错误。改用 ASCII 文件名并从目标目录保存后，两份官方 HTML 均成功取得。过程中没有沙箱拒绝、审批拒绝或远程 HTTP 错误。

## 保持冻结的边界

- 不把对象 ID 中的 `72` 或 `physically_contains` 关系当证据。
- 不用 72 乘单模组容量、带宽、算力或功耗制造机架值。
- 不把 `expected in 2H 2026` 写成已经量产、可订购或已部署。
- 不把参考设计写成 AMD 可直接销售的 rack SKU。
- 不把 CDNA 5 架构共性复制到 Helios；只沿既有关系回到正式架构对象。