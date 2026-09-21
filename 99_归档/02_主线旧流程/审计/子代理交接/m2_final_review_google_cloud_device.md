# M2 Google TPU 云端器件修复包最终独立复核

## 文档状态

- 复核状态：`completed`
- 复核日期：`2026-08-13`
- 复核对象：`审计/子代理交接/m2_staging/M2-W2-GOOGLE-CLOUD-DEVICE-REMEDIATED/`
- 写入边界：仅本报告；未修改冻结包、正式 32 表、资料卡或全局文档
- 最终裁决：`accept_with_caveat`

这个 Google TPU（Tensor Processing Unit，张量处理器）修复包已经关闭上一轮指出的三个实质问题：`tpu-machines` 的每芯片规格不再被误标为器件范围之外，v5e 配置不再引用不含 v5e 的 `tpu-machines`，G15 本地提取也没有再冒充完整证据入口。来源元数据和五份可用提取可以按本报告给出的正式行顺序合并。包内来源选择仍是候选结果：器件事实和拓扑事实尚未冻结到正式归属对象，不能据此直接新增正式 screening、coverage、selection run 或 selection member。

## 输入与基线

本次完整读取了根 `README.md`、`AGENTS.md`、`研究计划.md`、`资料卡/字段字典.md`，以及数据模型说明、120 行 `数据/fields.csv`、488 行 `数据/enums.csv` 和 323 行 `数据/schema-columns.csv`。字段注册表的 SHA-256（256 位安全散列算法）为 `7cf5442800a7e453b34bbda4ac335ccf101ce5cac2dde297be657d4f56a02cae`，枚举表为 `5864354d6cd26237ff9495e23e0121feb6a7a665f37dcbd1b00b8646e3211474`，表结构注册表为 `85129e57f6ab927cac43ca820d7b8df6558516f956bb1525ffca615f66654a6b`。

我还逐文件读取了原包 `M2-W2-GOOGLE-CLOUD-DEVICE/`、第一次独立复核 `m2_review_google_cloud_device_gate.md` 和修复包全部 21 个文件；六份 HTML（HyperText Markup Language，超文本标记语言）提取均检查了实际行标记和目标正文。正式库中三枚 `cloud_accelerator` 对象及三条 `implements_architecture` 关系已经存在，六行的 `review_status` 都是 `needs_resolution`。拟新增的一个来源家族、一个来源版本和七个候选访问入口（endpoint）ID 在正式表中均无碰撞；本报告只授权其中六个 endpoint，G15 行继续禁入。

## 冻结与清单复算

`package-manifest.csv` 有 19 行，恰好覆盖 21 个包文件中除 manifest 自身和 `package-freeze.sha256` 外的 19 个文件。逐项重算相对路径、字节数和小写 SHA-256 后，缺项、额外项和不匹配项均为 0。manifest 的 SHA-256 是：

`fae56649e8c21314ef571b57560053166e2120d057087844b818fd34d7edcf3b`

`package-freeze.sha256` 的内容与该值逐字一致。为额外绑定包含 manifest 与 freeze 在内的 21 个文件，我按正斜杠相对路径、`.NET StringComparer.OrdinalIgnoreCase` 排序，将每行序列化为 `relative_path<TAB>byte_length<TAB>lowercase_file_sha256`，采用 UTF-8（Unicode 文本编码）且不带 BOM（Byte Order Mark，字节顺序标记），以 LF（Line Feed，换行符）分行并保留末尾 LF；所得 2,175 字节清单文本的聚合 SHA-256 为：

`2489a07005e7b41a61dc7959aae56885096dca4635b5e596bd7b44149b6d2fc3`

这两个哈希作用不同：前者是包内正式冻结合同，后者是本次独立复核的 21 文件整体指纹。

## 来源池与反向移除

六源器件候选池为 G05、G08、G09、G10、G15 和 `tpu-machines`。另有 G01 的物理封装（package）边界行，但它不属于这六源器件池。逐段核对结果如下。表中的 SparseCore 是稀疏计算核，TensorCore 是张量计算核，MXU（Matrix Multiply Unit）是矩阵乘法单元；HBM（High Bandwidth Memory）是高带宽存储器，ICI（Inter-Chip Interconnect）是芯片间互联，DCN（Data Center Network）是数据中心网络。BF16 指 bfloat16 浮点格式，INT8 指 8 位整数，VM 指虚拟机，GiB 指 $2^{30}$ 字节，torus 指环面互联拓扑。

| 来源 | 本范围结论 | 复核依据 |
|---|---|---|
| G05 | `redundant_covered` 候选成立 | 本范围采用的 v5p 每芯片 4 个 SparseCore 由 G09 `L156` 覆盖，v6e 每芯片 2 个由 `tpu-machines L637` 覆盖。G05 在架构包中的作用不变。 |
| G08 | `selected` 候选成立 | 唯一直接覆盖 v5e 云端器件页中的组件、BF16/INT8 峰值、HBM、每芯片 ICI 和 v5e 配置边界；`tpu-machines L518-L523` 不列 v5e。 |
| G09 | `selected` 候选在“器件身份加拓扑边界”范围成立 | 直接给出 v5p 的 95 GiB、组件、每芯片 ICI，以及 `L159-L160` 的 3D torus 适用条件。后者属于 slice/系统拓扑边界，不能直接挂到云端器件。 |
| G10 | `selected` 候选成立 | 直接给出 v6e 的 MXU、INT8、ICI 端口和 2D torus 条件；这些内容不被 `tpu-machines` 全部替代。 |
| G15 | 器件范围的 `redundant_covered` 候选成立，endpoint 不通过 | 本地文件缺 `L69-L87`；v5p/v6e SparseCore 数量已有 G09 和 `tpu-machines` 单源覆盖。G15 在正式架构选择中的稀疏计算机制角色不变。 |
| `tpu-machines` | `selected` 候选成立 | `L624-L639` 的表头和各字段明确写 `per chip`，覆盖 v5p/v6e 的峰值、HBM、TensorCore、SparseCore、ICI 和 DCN；后续 VM 表仍属于配置层。 |

四个选择成员是 G08、G09、G10 和 `tpu-machines`。包内四条 coverage candidate 均只有一个 covering source，G05/G15 的 v5p SparseCore 分别由 G09 覆盖，v6e SparseCore 分别由 `tpu-machines` 覆盖，没有把多源组合伪装成任一单源全文覆盖。G05 和 G15 的 `redundant_covered` 只在当前云端器件候选范围成立，不能改写它们在正式架构选择中的状态。

这组四源候选通过了当前审计范围的反向移除核对，但还不能成为正式最小集。G09 的不可替代项包含 slice/系统拓扑条件，包内也没有冻结正式器件事实、拓扑归属对象或资料卡。待事实和 owner 集冻结后，应按实际原子事实重跑；在此之前，`source-selection-candidates.csv` 的全部 screening、coverage、selection run 和 selection member 都不得转入正式表。

## 对象、待办与配置边界

三枚对象和三条架构关系已由总控预留，本包只能引用，不能重复追加或升状态：

- `OBJ-GOOGLE-TPU-V5E-CLOUD-DEVICE`
- `OBJ-GOOGLE-TPU-V5P-CLOUD-DEVICE`
- `OBJ-GOOGLE-TPU-V6E-CLOUD-DEVICE`
- `OREL-GOOGLE-V5E-CLOUD-DEVICE-IMPLEMENTS-ARCH`
- `OREL-GOOGLE-V5P-CLOUD-DEVICE-IMPLEMENTS-ARCH`
- `OREL-GOOGLE-V6E-CLOUD-DEVICE-IMPLEMENTS-ARCH`

Google/AWS 架构工作包（GA）的 14 个父待办完整映射到 15 个持久处置项。只有 `DEF-M2GA-GV5P-03` 拆成两支：云端器件保持 `95 GiB`，物理 package 保持 `96 GiB`。10 行去往后续云端器件事实包，5 行等待物理 package 身份门；两支都明确禁止推导 `1 GiB` 预留，也没有把差异写成已解决冲突。v6e 组件行已改用 G10 与 `tpu-machines`，不再依赖当前不可用的 G15 本地提取。

七组配置处置都保持 `do_not_write_to_cloud_accelerator`。`CFGDISP-GOOGLE-V5E-MACHINE-TYPES` 现在只引用 G08；这与 `tpu-machines L518-L523` 仅列 TPU7x、v6e、v5p 的正文一致。VM 总 HBM、机器类型芯片数、NUMA（Non-Uniform Memory Access，非统一内存访问）、slice/Pod 拓扑和系统聚合带宽都继续留在配置或系统层。CT6E 家族关系、命名机器类型、slice 与 Pod 也不在本次合并范围。

## 提取合同与获取错误

六份本地 HTML 都是联网读取器返回的渲染文本再包装为可哈希 HTML，不是上游服务器的原始响应体。G05、G08、G09、G10 和 `tpu-machines` 五份文件包含本包使用的定位，可以作为 `endpoint_type=other`、`is_preferred_endpoint=false` 的非首选固定提取。它们的 notes 必须逐字保持：

`renderer-extracted text wrapped as HTML / not upstream response body`

它们不得标为 `web_snapshot`。`snapshot_date=2026-08-13` 只记录提取日期，不改变 endpoint 类型，也不表示取得了原始响应体。远端 primary 行不带本地文件，因此 `local_path`、`sha256`、`page_count` 和 `snapshot_date` 留空；候选表中的 `200-equivalent-renderer-read` 不是整数，不能写入正式 `http_status`，正式值必须留空。

G15 本地文件为 36,858 字节，SHA-256 为 `9f77ba67b06ea8b3091b2842157f6422e261a5d076acda1a7203832529935aad`。它的首个行标记是 `L148`，末行是 `L409`，缺少正式断言所需的 `L69-L87`。远端 OpenXLA 官方页当前可读到 410 行，`L84` 仍给出 `SparseCores/Chip | 4 | 4 | 2`，但这不能补足本地文件。`END-M2-GA-G15-EXTRACT-20260813` 必须继续 `partial / pending_verification`，不得设置正式拟落路径，也不得进入正式 endpoint 表。

普通权限下载返回退出码 35 和 `SEC_E_NO_CREDENTIALS`；已获批准的提权重试仍返回退出码 35 和 `SSL/TLS connection failed`，两次都没有生成文件。这是远端或本机 TLS（Transport Layer Security，传输层安全）链路错误，不是用户拒绝、沙箱拒绝、自动审批拒绝、审批连接故障，也不是模型能力限制。

## 获准复制的五个文件

总控只有在逐条重算字节数和 SHA-256 均一致后，才可复制以下文件。G15 不在本表中。

| endpoint_id | staging（待合并区）文件 | 正式 local_path | 字节 | SHA-256 |
|---|---|---|---:|---|
| `END-M2-W2-G-TPU-MACHINES-EXTRACT-20260813` | `snapshots/2026-08-13/google-cloud-tpu-machines-2026-08-13.html` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-machines-2026-08-13.html` | 27,322 | `b87a1b00c38354659efc4fb0073b4dd205ce807e37cfc01252be6bf5820c96b8` |
| `END-M2-GA-G05-EXTRACT-20260813` | `snapshots/2026-08-13/google-cloud-tpu-architecture-2026-08-13.html` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-architecture-2026-08-13.html` | 20,515 | `ddf8f0a880db456b5edc190a6ec2feb63b06c016e86d8583072cd70eaed93841` |
| `END-M2-GA-G08-EXTRACT-20260813` | `snapshots/2026-08-13/google-cloud-tpu-v5e-2026-08-13.html` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v5e-2026-08-13.html` | 13,076 | `7bb0a40383503f76c43e728d8868c7f17f1e715a6d0e200f90428471ce646b47` |
| `END-M2-GA-G09-EXTRACT-20260813` | `snapshots/2026-08-13/google-cloud-tpu-v5p-2026-08-13.html` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v5p-2026-08-13.html` | 15,574 | `c4207909253ef1c0d96298396c080fd2349bdb92a8048c717d582d9bcc2e6c5c` |
| `END-M2-GA-G10-EXTRACT-20260813` | `snapshots/2026-08-13/google-cloud-tpu-v6e-2026-08-13.html` | `最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v6e-2026-08-13.html` | 11,999 | `65c35ff3c661e7e4cb0c08d382aacc713592d49107d0d1c1c29a27bd58332dc2` |

## 逐列正式候选与生命周期授权

`source-candidates.csv` 不是正式表头，不能整行追加。以下三个 CSV（Comma-Separated Values，逗号分隔值）代码块是本次签字的完整、逐列正式候选；空字段必须保持为空，不得从 staging 候选的复合状态字符串中猜值。

### `最小参考资料库/source-families.csv`

```csv
"source_family_id","canonical_title","family_kind","publisher_or_organization","persistent_work_id","review_status","notes"
"SFAM-M2-W2-G-TPU-MACHINES","TPU machines in accelerator-optimized machine family","dynamic_page_history","Google Cloud","https://docs.cloud.google.com/compute/docs/tpus/tpu-machines","reviewed","Google Cloud dynamic machine-type documentation family; accepted content version is a renderer extract, not an upstream response body."
```

### `最小参考资料库/sources.csv`

```csv
"source_id","source_family_id","title","author_or_organization","source_type","publication_date","version_label","language","source_authority","source_status","content_fingerprint","last_verified_date","review_status","notes"
"SRC-M2-W2-G-TPU-MACHINES-20260813","SFAM-M2-W2-G-TPU-MACHINES","TPU machines in accelerator-optimized machine family","Google Cloud","cloud_service_documentation","","renderer-extract-2026-08-13","en","first_party","pending_verification","sha256:b87a1b00c38354659efc4fb0073b4dd205ce807e37cfc01252be6bf5820c96b8","2026-08-13","reviewed","The fingerprint binds the fixed renderer extract, not an upstream response body; the canonical remote page is readable, while raw-body capture remains pending."
```

### `最小参考资料库/source-endpoints.csv`

```csv
"endpoint_id","source_id","endpoint_type","url","local_path","sha256","page_count","mime_type","access_date","http_status","snapshot_date","is_preferred_endpoint","accessibility_status","review_status","notes"
"END-M2-W2-G-TPU-MACHINES-PRIMARY","SRC-M2-W2-G-TPU-MACHINES-20260813","html_page","https://docs.cloud.google.com/compute/docs/tpus/tpu-machines","","","","text/html","2026-08-13","","","true","accessible","reviewed","Official canonical URL; renderer read succeeded, but no upstream response body was saved; http_status is blank because no raw HTTP response was captured."
"END-M2-W2-G-TPU-MACHINES-EXTRACT-20260813","SRC-M2-W2-G-TPU-MACHINES-20260813","other","","最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-machines-2026-08-13.html","b87a1b00c38354659efc4fb0073b4dd205ce807e37cfc01252be6bf5820c96b8","","text/html","2026-08-13","","2026-08-13","false","accessible","reviewed","renderer-extracted text wrapped as HTML / not upstream response body"
"END-M2-GA-G05-EXTRACT-20260813","SRC-M2-GA-G05","other","","最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-architecture-2026-08-13.html","ddf8f0a880db456b5edc190a6ec2feb63b06c016e86d8583072cd70eaed93841","","text/html","2026-08-13","","2026-08-13","false","accessible","reviewed","renderer-extracted text wrapped as HTML / not upstream response body"
"END-M2-GA-G08-EXTRACT-20260813","SRC-M2-GA-G08","other","","最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v5e-2026-08-13.html","7bb0a40383503f76c43e728d8868c7f17f1e715a6d0e200f90428471ce646b47","","text/html","2026-08-13","","2026-08-13","false","accessible","reviewed","renderer-extracted text wrapped as HTML / not upstream response body"
"END-M2-GA-G09-EXTRACT-20260813","SRC-M2-GA-G09","other","","最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v5p-2026-08-13.html","c4207909253ef1c0d96298396c080fd2349bdb92a8048c717d582d9bcc2e6c5c","","text/html","2026-08-13","","2026-08-13","false","accessible","reviewed","renderer-extracted text wrapped as HTML / not upstream response body"
"END-M2-GA-G10-EXTRACT-20260813","SRC-M2-GA-G10","other","","最小参考资料库/快照/Google/TPU/2026-08-13/google-cloud-tpu-v6e-2026-08-13.html","65c35ff3c661e7e4cb0c08d382aacc713592d49107d0d1c1c29a27bd58332dc2","","text/html","2026-08-13","","2026-08-13","false","accessible","reviewed","renderer-extracted text wrapped as HTML / not upstream response body"
```

本次独立签字授权以上 1 个 family、1 个 source 和 6 个 endpoint 在正式合并时直接使用 `review_status=reviewed`。这是逐主键生命周期授权，不扩展到其他行。`SRC-M2-W2-G-TPU-MACHINES-20260813.source_status` 必须保持 `pending_verification`；`reviewed` 表示这八行的元数据和边界已经复核，不表示原始响应体门已经关闭。

现有 G05、G08、G09、G10 的 family、source 和 primary endpoint 不得随本包改变状态或其他列。三枚器件对象和三条架构关系继续 `needs_resolution`。G15 endpoint、全部来源选择候选、配置和 deferred 审计行均无生命周期授权。

## 新鲜校验

修复包校验器原样运行通过：

```text
PASS: M2-W2-GOOGLE-CLOUD-DEVICE-REMEDIATED preparation package; 282 checks executed.
Scope: 3 reserved cloud_accelerator references, 3 reserved implements_architecture relations, 15 deferred dispositions, 7 configuration groups, 5 usable extracts, 1 partial G15 extract, 6-source device pool, 4 selection members.
```

当前真实工作目录的正式校验器只读运行通过：

```text
PASS: 32-table research data model; 93251 checks executed.
Registry: 323 columns, 488 enum values.
```

我把上述 1+1+6 行和五份文件加入受控临时正式副本后，再运行同一正式校验器：

```text
PASS: 32-table research data model; 93378 checks executed.
Registry: 323 columns, 488 enum values.
```

临时副本随后删除并确认不存在；真实正式表和冻结包没有变化。

一次只读路径分组命令把反斜杠误作不完整正则表达式，PowerShell 报错；改用字符串 `Split` 后复算成功。另一次 manifest 对照没有把单行结果强制转换为数组，曾误报 19 项不匹配；改用 `@(...)` 后逐行复算为 0。两项都是复核者的命令构造错误，没有写文件，不是沙箱、审批、远端服务或工具能力问题。

## 最终裁决与禁入范围

裁决为 `accept_with_caveat`。总控可按本报告完整 CSV 行顺序合并 1 个来源家族、1 个来源版本、6 个 endpoint，并复制表列出的五个固定提取。正式合并前须再次核对 manifest SHA、五个文件的字节数和 SHA；合并后须在真实工作目录重跑正式校验器，并做逐主键差异检查。

以下内容继续禁止：`END-M2-GA-G15-EXTRACT-20260813`；任何 `web_snapshot` 或“已保存上游响应体”的说法；对象和架构关系的重复追加或状态提升；包内全部 screening、coverage、selection run、selection member；15 个 deferred 处置直接转事实；七组配置直接转事实；CT6E 配置关系、命名机器类型、slice、Pod、v5p 物理 package；三张器件卡及器件事实。事实或归属对象集合冻结后，需要重新执行器件范围反向移除，不能沿用本包的 draft 选择结论。

根 `README.md` 和 `AGENTS.md` 已在成稿后复查。本次只新增独立复核报告，没有改变正式数据、项目目标、目录职责或长期约定，因此没有修改这两份文件。正式合并完成后，应由总控同步项目状态文档。

## 报告文件校验值

为避免自引用，本报告不在正文内嵌自身 SHA-256；最终文件哈希在交接消息中单独给出。