# M2 第二波 Google 云端器件来源门正式验收

验收日期：2026 年 8 月 13 日  
工作包：`M2-W2-GOOGLE-CLOUD-DEVICE-REMEDIATED`  
结论：`accept_with_caveat`；本次只接收来源元数据和五份固定提取，不接收器件事实、资料卡或正式最小来源选择。

## 接收范围

正式库新增一条动态页面家族 `SFAM-M2-W2-G-TPU-MACHINES`、一个内容版本 `SRC-M2-W2-G-TPU-MACHINES-20260813` 和六个访问入口。新内容版本继续保持 `source_status=pending_verification`：它绑定 2026 年 8 月 13 日的页面渲染提取，不表示已经保存服务器原始响应体。六个入口包括 `tpu-machines` 的官方远端入口，以及 `tpu-machines`、G05、G08、G09、G10 的五个本地提取入口。

五个本地入口均采用 `endpoint_type=other`、`is_preferred_endpoint=false`，notes 保留 `renderer-extracted text wrapped as HTML / not upstream response body`。正式 `http_status` 留空，因为没有取得可核验的原始 HTTP 响应；没有把候选记录中的 `200-equivalent-*` 写入整数列。官方远端入口是新来源的唯一首选入口，但没有 `local_path`、SHA-256 或快照日期。

## 保留的限制

G15 提取从 `L148` 开始，缺失原定位使用的 `L69-L87`，因此 `END-M2-GA-G15-EXTRACT-20260813` 没有进入正式库。G15 原始响应体门继续未关闭。

修复包对六源池的重算可以用来审查下一轮事实抽取，但当前没有冻结器件事实集合，所以本次不导入 `source-screening`、`source-coverage`、selection run 或 selection member。v5e、v5p、v6e 三个云端器件对象和三条架构关系继续保持 `needs_resolution`。15 个待办处置、七组配置落点、CT6E 配置关系、器件 facts、资料卡、物理 package、slice 和 Pod 也都不在本次接收范围内。

95 GiB 云端值与 96 GiB 物理分支继续分开保留，不能推导 1 GiB 被预留。`tpu-machines` 只在它实际列出的 v5p、v6e 每芯片规格范围内使用；v5e 配置不引用该页。

## 固定文件

五份正式文件位于 `最小参考资料库/快照/Google/TPU/2026-08-13/`：

| 文件 | 字节 | SHA-256 |
|---|---:|---|
| `google-cloud-tpu-machines-2026-08-13.html` | 27,322 | `b87a1b00c38354659efc4fb0073b4dd205ce807e37cfc01252be6bf5820c96b8` |
| `google-cloud-tpu-architecture-2026-08-13.html` | 20,515 | `ddf8f0a880db456b5edc190a6ec2feb63b06c016e86d8583072cd70eaed93841` |
| `google-cloud-tpu-v5e-2026-08-13.html` | 13,076 | `7bb0a40383503f76c43e728d8868c7f17f1e715a6d0e200f90428471ce646b47` |
| `google-cloud-tpu-v5p-2026-08-13.html` | 15,574 | `c4207909253ef1c0d96298396c080fd2349bdb92a8048c717d582d9bcc2e6c5c` |
| `google-cloud-tpu-v6e-2026-08-13.html` | 11,999 | `65c35ff3c661e7e4cb0c08d382aacc713592d49107d0d1c1c29a27bd58332dc2` |

五个正式文件的大小和 SHA-256 已逐项重算，错误数为 0。

## 独立复核、验证与恢复

独立复核报告为 `审计/子代理交接/m2_final_review_google_cloud_device.md`，裁决 `accept_with_caveat`，SHA-256 为 `51d0495c7350a8acb2ea24ffe99a1baa86282b1bdf424cd7af69e6b9b41cbdf8`。修复包自身通过 282 项检查；独立临时合并通过 93,378 项检查。

真实工作目录完成 1 个 family、1 个 source、6 个 endpoint 和五份文件的精确合并后，正式校验器再次通过 93,378 项检查，注册表仍为 323 列和 488 个枚举值。G15 endpoint 的正式命中数为 0，五个本地 endpoint 的哈希错误数为 0。三张正式 CSV 保持 UTF-8 无 BOM 和 CRLF 换行。

合并前备份位于 `审计/合并备份/M2-W2-GOOGLE-CLOUD-DEVICE-SOURCES-20260813/`。备份 10 个既有文件，`backup-hashes.csv` 的 SHA-256 为 `62ad20eb0e72dffca1237f8b3345d9122dc706efb8808775761ddfd1a45822e1`。本次新增文件原先不存在；恢复时应从备份还原三张来源表，并移除本验收列出的五个新增快照。删除操作必须先逐路径确认，不能对上级快照目录做递归删除。

## 错误分类

补取 OpenXLA 原始响应体时，普通下载和已批准的提权下载都在 TLS 握手阶段以 exit 35 失败，没有生成文件。这是远端或本机网络链路错误，不是用户拒绝、沙箱拒绝、自动审批拒绝或审批连接失败。修复包中三次 PowerShell 锚点或管道构造失败、独立复核中的正则和数组构造错误，均属于操作者命令构造错误；它们没有写入正式库，也不影响最终验收。

## 验收结论

Google 云端器件来源门已经按有限范围正式接收。现在有可复现的 v5e、v5p、v6e 和机器类型页面提取可供后续器件事实包使用，但原始 body 门仍未关闭，最小来源集也必须等器件事实集合冻结后重跑。本次验收不开始训练与推理架构差异分析。