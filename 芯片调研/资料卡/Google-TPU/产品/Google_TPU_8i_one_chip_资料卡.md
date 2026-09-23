# Google TPU 8i one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡以 Google 官方公布的单颗 TPU 8i 配置为主语。Google 没有为 TPU 8i 公布常规板卡 SKU；Arm Axion host、tray、Boardfly group、Optical Circuit Switch（OCS）和 Pod 仅用于解释芯片的系统互联，不能作为单芯片规格。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Google | TPU 8i | `[1, 页面标题与 TPU 8: Specialized by design]` |
| 产品家族 | 第八代 TPU（TPU 8） | 家族包含 TPU 8t 与 TPU 8i，不代替本配置 | `[1, TPU 8: Specialized by design]` |
| 完整 SKU | Google TPU 8i one chip | 正式比较采用官方 per-chip 口径；官方产品名为 TPU 8i | `[1, TPU 8t and TPU 8i at a glance]` |
| 对象形态 | 官方 per-chip 配置 | Google 未公布常规板卡料号 | `[1, TPU 8t and TPU 8i at a glance]` |
| 架构代际 | 第八代 TPU | TPU 8t 与 TPU 8i 是该代的两个不同产品 | `[1, TPU 8: Specialized by design]` |
| 发布与可用状态 | 2026-04-22 发布技术说明；截至 2026-09-16 为 `Coming soon` | 已宣布，尚未标为 Preview 或 Generally available | `[1, 页面日期]` `[3, TPU versions / TPU 8i]` |
| 厂商定位 | 面向 post-training、sampling、serving 与 inference 的 TPU | TPU 8i 产品与系统 | `[1, TPU 8i: The sampling and serving specialist]` `[3, TPU versions / TPU 8i]` |
| 目标 workload | post-training、high-concurrency reasoning、sampling、serving | 官方主优化方向，并非排他性能力边界 | `[1, TPU 8i: The sampling and serving specialist; TPU 8t and TPU 8i at a glance / Primary Workload]` |
| 产品目标 | 增加片上状态容量，降低 autoregressive decoding 中归约、同步和全互联通信的等待 | 芯片内 CAE 与系统 Boardfly 共同承担，作用域需分开 | `[1, TPU 8i: The sampling and serving specialist]` |

本卡包含：单颗 TPU 8i package、两个 on-core die、两个 TensorCore、CAE chiplet、HBM、PCIe 与 ICI 端点。

本卡不包含：Arm Axion host、tray/board、Boardfly group、OCS、Pod 及其聚合规模、跳数和时延。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | 两个 TPU 8i TensorCore；另有 CAE | 第八代 TPU 沿用 TensorCore、MXU、VPU 等命名；是否与 8t 复用同一物理 IP 未公开 | 记录 Figure 4 与正文明示的组成，不由方框推算面积或吞吐 | `[1, The Collectives Acceleration Engine; Figure 4]` |
| die / chiplet | 两个 on-core die 与一个承载 CAE 的 chiplet die | 未公开 | 按正文区分 TensorCore die 和 CAE chiplet，不把 Boardfly 交换结构写入 package | `[1, The Collectives Acceleration Engine; Figure 4]` |
| package | 两个 logic/on-core die、ICI/SerDes/CAE chiplet 与八组 HBM3E stack | TPU 8i 的公开 package 图 | 只记录 Figure 4 与正文直接披露的组成 | `[1, Figure 4]` |
| 产品 SKU | Google TPU 8i one chip | 不适用 | 正式比较单位 | `[1, TPU 8t and TPU 8i at a glance]` |
| 相关系统 | TPU 8i tray、Boardfly group 与 Pod、Google Cloud AI Hypercomputer | 多种上层配置 | 只在第 6 节记录系统级 ICI 组织 | `[1, TPU 8: Specialized by design; Boardfly ICI topology]` |

现有 [TPU 8i 架构资料卡](../架构/Google_TPU_8i_架构卡.md) 作为早期共享材料保留。本卡重新以单颗 TPU 8i 配置为主语，并把 CAE 的片内功能、ICI 芯片端点和 Boardfly 系统拓扑分开。

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每个 TPU 8i chip 有两个 TensorCore，分别位于两个 on-core die。Figure 4 中每个 TensorCore 含中央 `VPU + Vmem`、两个 MXU、两个 XLU 和一个 TCS | 每 TensorCore 图示组成；阵列尺寸、频率、每单元吞吐及 TCS/XLU 的完整职责未公开 | `[1, The Collectives Acceleration Engine; Figure 4]` |
| 执行模型与调度 | CAE 聚合跨 Core 的结果，用于 autoregressive decoding 与 chain-of-thought 处理中的 reduction 和 synchronization | 芯片内、跨两个 TensorCore 的集合操作；调度粒度、消息大小和指令语义未公开 | `[1, The Collectives Acceleration Engine]` |
| 局部存储与数据搬运 | 产品文章给整芯片 384 MB Vmem；官方 JAX 8i 分支独立给每 TensorCore 192 MiB VMEM 和 1 MiB SMEM，Figure 4 的两个 TensorCore 各连接本地 Memory and DMA Interconnect | 每核值来自开发配置，不由产品总量均分推导；MB/MiB 分列。Pallas 使用显式局部工作区，跨核共享、一致性、bank 和绝对带宽未公开 | `[1, On-Chip SRAM (Vmem); Figure 4]` `[5, TPU_8I branch]` `[6, BlockSpecs and grid iteration; Placing operands in SMEM]` |
| 数值与累加路径 | 官方规格表给出 FP4 峰值，证明 TPU 8i 具有 FP4 计算路径 | FP4 输入、乘积、累加、输出、舍入、缩放和 FMA 计数口径未公开 | `[1, TPU 8t and TPU 8i at a glance / Peak FP4 PFLOPs]` |
| 稀疏与专用单元 | 一个 CAE 位于独立 chiplet die，替代前代 on-core die 上的四个 SparseCore；CAE 加速片内归约与同步 | TPU 8i 没有被正文描述为仍启用这四个 SparseCore；CAE 内部结构和吞吐未公开 | `[1, The Collectives Acceleration Engine; Figure 4]` |

### 3.1 官方开发资料中的局部工作区与接口

JAX 的 TPU_8I 分支列每 TensorCore 1 MiB SMEM（标量存储器），与 192 MiB VMEM 分开。Pallas 文档将 kernel 输入输出映射到这些局部工作区，由编译器处理 HBM 搬运；控制流与不规则索引可使用 SMEM。较大 Vmem 的产品设计目的，是在长上下文 decoding 时保存更多 KV Cache（已处理 token 的 key/value 状态），减少计算核心等待。实际可驻留量仍取决于模型、精度和分块方式。[5, TPU_8I branch] [6, BlockSpecs and grid iteration; Placing operands in SMEM] [1, Large on-chip SRAM]

同一 JAX 配置保留一个 SparseCore 软件接口，含 4 个 vector subcore、每 subcore 16 lane；每 subcore VMEM 为 512 KiB，DMA 粒度为 64 B。官方物理图与正文将独立 chiplet 描述为 CAE，并说它替代 Ironwood 的四个 SparseCore。现有资料没有说明该软件接口与 CAE 的物理映射，不能据此在封装图上再增加一个 SparseCore，也不能把 64 B 当作 CAE 消息粒度。[5, TPU_8I branch / SparseCoreInfo] [1, The Collectives Acceleration Engine; Figure 4]

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 两个 on-core die 各含一个 TensorCore；每个 TensorCore 图示两个 MXU、两个 XLU、一个 `VPU + Vmem` 和一个 TCS；另有一个 CAE | per-chip package；矩阵阵列内部规模与每单元吞吐未公开 | `[1, The Collectives Acceleration Engine; Figure 4]` |
| 片上存储 | 产品文章给 per-chip Vmem 384 MB，分布在两个 TensorCore 区域；JAX 专属配置给 192 MiB VMEM/TensorCore，两核局部容量算术合计 384 MiB | 每核容量有独立来源，MB/MiB 不静默换算；局部工作区合计不表示任一核心可访问全部容量，物理带宽与一致共享方式未公开 | `[1, On-Chip SRAM (Vmem); Figure 4]` `[5, TPU_8I branch]` |
| 片内互联 | 两个 logic die 各有一个 `Memory and DMA interconnect`，两侧互联之间存在图示双向连接；左侧连接 host/management，右侧连接 ICI/CAE chiplet | package 内结构；拓扑、宽度、带宽和一致性未公开 | `[1, Figure 4]` |
| 内存控制器与 PHY | 两个 logic die 各有四个 `HBM3 Ctrl`；ICI/SerDes chiplet 内标有 ICI Router、`6x Link Stack` 与 `6x200G SerDes octals + PCS` | Figure 4 原始标签。`200G` 的 lane、octal、编码和方向口径未解释，不由此计算聚合带宽 | `[1, Figure 4]` |
| 工艺与物理规模 | 未公开 | 未找到工艺、die 面积或晶体管数的一手数据 | `[1, 全文及 Figure 4]` |
| 封装组成 | 两个 logic/on-core die、一个 ICI/SerDes/CAE chiplet、八个 HBM3E stack；HBM stack 旁标有 `12-hi` | 控制器标为 HBM3、stack 标为 HBM3E，原图没有解释命名差异；interposer、基板和封装尺寸未公开 | `[1, Figure 4]` |
| 封装内互联 | 两个 logic die 相互连接，右侧 logic die 再连接 ICI/SerDes/CAE chiplet；Figure 4 底部简图显示一个 SC-CAE chiplet与 TN1、TN2 的 TC 关联 | D2D 协议、链路数、带宽及 TN1/TN2 缩写均未公开；不能把外部 ICI 带宽当作 D2D 带宽 | `[1, Figure 4]` |
| RAS | Figure 4 标出 chip manager、gBMC 和管理用 PCIe Gen2 x1 | 只证明管理模块与接口存在；ECC、隔离、重放、降级及覆盖范围未公开 | `[1, Figure 4]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 2 个 TensorCore、1 个 CAE；每个 TensorCore 图示 2 个 MXU、2 个 XLU、1 个 `VPU + Vmem` 和 1 个 TCS | 两个 TensorCore 位于两个 on-core die，CAE 位于独立 chiplet die | `[1, The Collectives Acceleration Engine; Figure 4]` |
| 时钟 | 未公开 | 未找到基准或峰值时钟 | `[1, 全文及 Figure 4]` |
| 理论峰值 | 10.1 PFLOPS FP4 | 技术文章的 per-chip 表头为 FP4；发布规格图另将 Pod 的 11.6EFLOPS 标为 FP8，精度标签冲突未解释。输入/累加格式、稠密或稀疏、FMA 计数和功耗点未公开 | `[1, TPU 8t and TPU 8i at a glance / Peak FP4 PFLOPs]` |
| 内存类型与容量 | HBM3E，288 GB | HBM3E 来自 Figure 4；288 GB 为官方 per-chip 配置 | `[1, Figure 4; TPU 8t and TPU 8i at a glance / HBM Capacity]` |
| 内存带宽 | 8,601 GB/s | 官方 per-chip 值；读写方向和有效带宽未公开 | `[1, TPU 8t and TPU 8i at a glance / HBM Bandwidth]` |
| 主机接口 | PCIe Gen5 x16；另有管理用 PCIe Gen2 x1 | 前者连接 host，后者连接 gBMC，不合并为同一主机带宽 | `[1, Figure 4]` |
| 设备互联端点 | ICI/SerDes/CAE chiplet 内含 ICI Router、`6x Link Stack` 与 `6x200G SerDes octals + PCS`；ICI bidirectional scale-up bandwidth 为 19.2 Tb/s per chip | 19.2 Tb/s 的每芯片、双向口径由官方规格图明确给出；payload、编码和持续带宽未公开，不由 Figure 4 的 SerDes 标签另行换算 | `[1, Figure 4]` `[2, TPU 8i: The reasoning engine / Ironwood 与 TPU 8i 规格图]` |
| 内存访问语义 | 未公开 | 未找到统一地址、统一内存、一致性、远程内存或页迁移的一手说明 | `[1, 全文及 Figure 4]` |
| 跨设备集合通信能力 | 未找到 | CAE 的公开职责是芯片内跨 Core 归约与同步；Boardfly 是外部 ICI 拓扑，均不能单独证明跨设备 collective engine | `[1, The Collectives Acceleration Engine; Boardfly ICI topology]` |
| 功耗 | 未公开 | 未找到芯片、package 或系统功耗的可靠一手值 | `[1, 全文及 Figure 4]` |
| 形态与散热 | 官方 per-chip 云产品配置；具体模组与散热未公开 | 不把 Axion host、tray、OCS 或 Pod 形态写成芯片形态 | `[1, TPU 8: Specialized by design; Figure 4]` |

## 6. 系统级互联上下文

本节只解释 TPU 8i 的 ICI 端点如何接入 Boardfly。系统规模、OCS 和跳数不属于单芯片配置。

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | Boardfly 采用分层 high-radix 组织：四芯片 tray 构成 building block，八个 building block 组成 fully connected group，36 个 group 经 OCS 连接；Pod 最多有 1,024 个 active chip，任意芯片间最多七跳 | tray、group、OCS、Pod 和跳数均在 TPU 8i package 外；单芯片只保留第 5 节 ICI 端点 | `[1, Boardfly ICI topology; Boardfly consists of the following elements; Figure 5; Figure 6]` |
| Scale-out | 未记录 | 官方文章没有为 TPU 8i 给出与单芯片端点直接绑定的独立 scale-out 架构 | `[1, TPU 8i 全节]` |
| 系统可靠性 | 未公开 | 未找到 Boardfly 的冗余、故障绕行、降级或维修域说明 | `[1, Boardfly 全节]` |
| 相关系统 | Google Cloud AI Hypercomputer、TPU 8i tray、Boardfly group 与 Pod | Arm Axion、铜缆、OCS 和 Pod 是外部系统组成 | `[1, TPU 8: Specialized by design; Figure 5; Figure 6]` |

## 7. 证据缺口与来源冲突

技术文章给单芯片 10.1PFLOPS FP4；Google 官方发布规格图则把 1,152-chip Pod 的 11.6EFLOPS 标为 FP8。未找到两种标签的关系说明，不能通过 Pod 聚合除法另立一个已确认的单芯片 FP8 峰值，也不能自行认定其中一处是笔误。按精度比较时须保留这一限制。`[1, TPU 8t and TPU 8i at a glance]` `[4, FP8 Eflops per pod]`

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| Boardfly building block 拓扑 | 来源冲突 | 正文写四芯片 `ring`，Figure 5 及图注写四芯片 `fully connected` `[1, Boardfly consists of the following elements; Figure 5]` | 并列保留，不裁定实际 tray 拓扑 |
| Boardfly Pod 芯片数 | 口径未解释 | 正文前段写 `up to 1,152 chips`；Pod structure 写 `up to 1,024 active chips`；Figure 5 的 4×8×36 为 1,152 个位置 `[1, Boardfly ICI topology; Pod structure; Figure 5]` | 保留物理位置与 active 口径差异，不擅自解释为 spare 或降级配置 |
| FP4 完整数值语义 | 未公开 | 官方规格表、Figure 4 | 只记录官方峰值，不猜测乘积、累加、输出、舍入和 FMA 计数 |
| Vmem 管理、分配与带宽 | 每核容量及软件管理语义已有公开说明；跨核共享和物理带宽未公开 | JAX 给 192 MiB/TensorCore；Pallas 描述显式 VMEM/SMEM 工作区与编译器搬运 | 保留产品 384 MB 与两核开发配置合计 384 MiB 的单位差异；不当作自动共享的 L2 `[5, TPU_8I branch]` `[6, BlockSpecs and grid iteration]` |
| CAE 内部结构与性能条件 | 未公开 | CAE 段、Figure 4 | 只记录归约/同步职责；5× 时延为缺少消息大小和基线的厂商相对值，不写成芯片铭牌规格 `[1, The Collectives Acceleration Engine]` |
| ICI 有效载荷与编码 | 未公开 | Figure 4、Google 官方 TPU 8i 规格图 | 方向与 per-chip 口径已确认为双向 19.2 Tb/s；不把该值进一步解释为 payload 或持续带宽 |
| 时钟、功耗与散热 | 未公开 | 三个官方页面 | 如实登记缺失 |
| 工艺、面积与晶体管数 | 未公开 | 官方技术文章与产品页 | 如实登记缺失 |
| 封装内 D2D 与 RAS | 未公开 | Figure 4 | 只记录图示连接和管理模块，不猜测协议、带宽或可靠性机制 |
| 可用状态 | 已确认 | 官方 TPU 产品页截至 2026-09-16 标为 `Coming soon` `[3, TPU versions / TPU 8i]` | 写为已宣布、尚未正式可用 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Diwakar Gupta、Sabastian Mugazambi，*TPU 8t and TPU 8i technical deep dive* / 正文标题 *Inside the eighth-generation TPU: An architecture deep dive*，Google Cloud，2026-04-22 | 官方技术文章与封装框图 | 身份、定位、Core/package 结构、Vmem、HBM、CAE、ICI 与 Boardfly 边界 | [官方网页](https://cloud.google.com/blog/products/compute/tpu-8t-and-tpu-8i-technical-deep-dive)；[本地快照](../../../../前置调研/原文/网页快照/S14_tpu8t_tpu8i.html) |
| `[2]` | Amin Vahdat，*Our eighth generation TPUs: two chips for the agentic era*，Google，2026-04-22 | 官方发布文章与规格图 | TPU 8i 的 19.2 Tb/s per-chip 双向 scale-up 带宽口径 | [官方文章](https://blog.google/innovation-and-ai/infrastructure-and-cloud/google-cloud/eighth-generation-tpu-agentic-era/)；[官方规格图](https://storage.googleapis.com/gweb-uniblog-publish-prod/images/TPU_8_Cloud_inline_2.width-1200.format-webp.webp) |
| `[3]` | *Tensor Processing Units (TPUs)*，Google Cloud，访问日期 2026-09-16 | 官方产品页 | TPU 8i 当前状态与产品定位 | <https://cloud.google.com/tpu> |
| `[4]` | Google，*TPU 8i 发布规格图* | 官方发布文章原始图像 | 1,152-chip Pod 的 11.6EFLOPS 被标为 FP8，与技术规格表 FP4 标签冲突 | <https://storage.googleapis.com/gweb-uniblog-publish-prod/images/TPU_8_Cloud_inline_2.width-1200.format-webp.webp> |
| `[5]` | The JAX Authors，*TPU hardware information*，`jax/_src/tpu_info.py`，2026-09-17 快照 | 官方开发源码 | TensorCore 数量、每核 VMEM/SMEM 与 SparseCore 软件资源；不采用其中开发模型的峰值替代产品规格 | [官方源码](https://github.com/jax-ml/jax/blob/main/jax/_src/tpu_info.py)；[本地快照](../../../原始资料/网页快照/Google/JAX/2026-09-17/jax-info-source.py) |
| `[6]` | The JAX Authors，*Pallas: TPU Details*，2026-09-17 快照 | 官方开发文档 | BlockSpecs and grid iteration、Placing operands in SMEM 的显式工作区与搬运语义 | [官方文档](https://docs.jax.dev/en/latest/pallas/tpu/details.html)；[本地快照](../../../原始资料/网页快照/Google/JAX/2026-09-17/jax-details.rst) |

## 9. 完成检查

- [x] SKU 身份和厂商定位的主语已经固定
- [x] Core、die/chiplet、package、SKU 和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、统一内存、一致性和远程访问的管理语义没有混写
- [x] 封装内 D2D 互联与 HBM、设备互联和系统聚合带宽已经分开
- [x] SKU 互联端点与系统拓扑、域大小和聚合带宽已经分开
- [x] 系统级互联上下文只在相关时填写，没有为普通 SKU 强制扩展调查范围
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：截至 2026-09-16，TPU 8i 的官方 per-chip 配置、芯片内 CAE、ICI 端点与 Boardfly 系统边界已经按公开资料固定。未公开字段和来源内部口径差异已登记，不影响本轮信息搜集完成。
