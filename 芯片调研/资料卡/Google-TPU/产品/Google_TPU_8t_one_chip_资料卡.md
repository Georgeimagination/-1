# Google TPU 8t one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡以 Google 官方公布的单颗 TPU 8t 配置为主语。Google 没有为 TPU 8t 公布常规板卡 SKU；Axion host、机架、Superpod、Virgo fabric 和跨数据中心训练集群仅用于解释芯片所处的系统互联，不能作为单芯片规格。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Google | TPU 8t | `[1, 页面标题与 TPU 8: Specialized by design]` |
| 产品家族 | 第八代 TPU（TPU 8） | 家族包含 TPU 8t 与 TPU 8i，不代替本配置 | `[1, TPU 8: Specialized by design]` |
| 完整 SKU | Google TPU 8t one chip | 正式比较采用官方 per-chip 口径；官方产品名为 TPU 8t | `[1, TPU 8t and TPU 8i at a glance]` |
| 对象形态 | 官方 per-chip 配置 | Google 未公布常规板卡料号 | `[1, TPU 8t and TPU 8i at a glance]` |
| 架构代际 | 第八代 TPU | TPU 8t 与 TPU 8i 是该代的两个不同产品 | `[1, TPU 8: Specialized by design]` |
| 发布与可用状态 | 2026-04-22 发布技术说明；截至 2026-09-16 为 `Coming soon` | 已宣布，尚未标为 Preview 或 Generally available | `[1, 页面日期]` `[2, TPU versions / TPU 8t]` |
| 厂商定位 | 面向训练的高吞吐 TPU | TPU 8t 产品与系统 | `[1, TPU 8t: The pre-training powerhouse]` |
| 目标 workload | 大规模 pre-training、embedding-heavy workload | 官方主优化方向，并非排他性能力边界 | `[1, TPU 8t: The pre-training powerhouse]` `[2, TPU versions / TPU 8t]` |
| 产品目标 | 提高大规模训练吞吐、计算利用率和扩展规模 | 产品与上层系统共同目标；不是实测结果 | `[1, TPU 8t: The pre-training powerhouse]` |

本卡包含：单颗 TPU 8t 的 TensorCore、SparseCore、logic chiplet、ICI/SerDes chiplet、HBM、主机接口和公开的每芯片配置。

本卡不包含：Axion host CPU、TPU 8t rack、Virgo/Jupiter 网络、9,600-chip Superpod、134,000-chip fabric 或百万芯片训练集群的聚合规格。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | TPU 8t TensorCore；另有两个图示 SparseCore | 第八代 TPU 沿用 TensorCore、MXU、VPU 等命名；是否与 8i 复用同一物理 IP 未公开 | 记录 Figure 1 明示的组成，不由方框推算面积或吞吐 | `[1, Figure 1]` |
| die / chiplet | logic chiplet 与独立 ICI/SerDes chiplet | 未公开 | 记录功能方框与连接关系，不猜测 die 面积、工艺或完整资源规模 | `[1, Figure 1]` |
| package | logic chiplet、ICI/SerDes chiplet、六组 HBM3E controller 与 HBM3E stack | TPU 8t 的公开 package 图 | 只记录 Figure 1 直接标出的组成 | `[1, Figure 1]` |
| 产品 SKU | Google TPU 8t one chip | 不适用 | 正式比较单位 | `[1, TPU 8t and TPU 8i at a glance]` |
| 相关系统 | TPU 8t rack、9,600-chip Superpod、Virgo fabric、Google Cloud AI Hypercomputer | 多种上层配置 | 只在第 6 节记录与互联端点直接相关的结构 | `[1, TPU 8: Specialized by design; TPU 8t: The pre-training powerhouse]` |

现有 [TPU 8t 架构资料卡](../架构/Google_TPU_8t_架构卡.md) 作为早期共享材料保留。本卡重新以单颗 TPU 8t 配置为主语，并把芯片端点与系统聚合值分开。

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | Figure 1 的 TensorCore 内含中央 `VPU + Vmem`、两个 MXU、两个 XLU 和一个 TCS。MXU 负责矩阵运算；页面没有解释 TCS、XLU 的完整名称和指令职责 | Figure 1 的单个 TensorCore 结构块；不由图形重复数推断未明示的全芯片规模 | `[1, Figure 1; The SparseCore advantage]` |
| 执行模型与调度 | Google 称 VPU/MXU 的配比可减少暴露的向量操作时间，使 quantization、softmax 和 layer normalization 与 MXU 矩阵乘重叠 | TPU 8t 执行路径的设计说明；调度粒度、流水级和指令语义未公开 | `[1, TPU 8t: The pre-training powerhouse / VPU/MXU overlap and balanced scaling]` |
| 局部存储与数据搬运 | 技术文章给每芯片 128 MB Vmem；JAX 的 8t 分支另给每 TensorCore 128 MiB VMEM，Pallas 将 kernel 引用映射到 VMEM/SMEM，并由编译器安排 HBM 搬运与计算重叠 | JAX 将 8t 记为一个物理 TensorCore；MB 与 MiB 按原来源分列。编程模型属于显式局部工作区，物理 bank、端口、绝对带宽仍未公开 | `[1, On-Chip SRAM (Vmem); Figure 1]` `[5, num_physical_tensor_cores_per_chip; TPU_8T branch]` `[6, BlockSpecs and grid iteration]` |
| 数值与累加路径 | TPU 8t 原生支持 FP4；Google 称该路径可使 MXU throughput 翻倍并减少参数存储和数据搬运 | FP4 输入、乘积、累加、输出、舍入、缩放和 FMA 计数口径未公开 | `[1, TPU 8t: The pre-training powerhouse / Native FP4]` |
| 稀疏与专用单元 | SparseCore 处理 embedding lookup 的不规则访存，并卸载 data-dependent all-gather 等 collective；规格表另列 `LLM Decoder Engine` | Figure 1 画出两个 SparseCore。LLM Decoder Engine 只在规格表中出现，内部位置、数量、算子和吞吐均未公开 | `[1, The SparseCore advantage; Figure 1; TPU 8t and TPU 8i at a glance / Specialized Chip Features]` |

### 3.1 官方开发资料中的工作存储

JAX 的 TPU_8T 分支给每个 TensorCore 1 MiB SMEM（标量存储器），与主向量工作区 VMEM 分开。Pallas 文档将控制流判断和不规则 tile 索引放在 SMEM，HBM 与 VMEM/SMEM 之间的数据搬运由编译器安排，并与计算重叠。这里描述软件可见的存储组织，未得到每层 SRAM 的绝对读写带宽或延迟。[5, TPU_8T branch] [6, BlockSpecs and grid iteration; Placing operands in SMEM]

同一配置还列 2 个 SparseCore，每个含 16 个 vector subcore、每 subcore 16 lane；每 subcore VMEM 为 256 KiB，DMA 传输粒度为 64 B。每 SparseCore 的分散工作区算术合计 4 MiB，但不构成额外的统一共享 Vmem；64 B 也不表示 bank 宽度或访存延迟。该软件资源表与 Figure 1 的两个 SparseCore 对应。[5, TPU_8T branch / SparseCoreInfo] [1, Figure 1]

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | Figure 1 画出一个 TensorCore 结构块和两个 SparseCore | 官方没有用正文确认该框图是否等同于全部使能计算资源，因此不再外推 Core 总数 | `[1, Figure 1]` |
| 片上存储 | 产品文章给 per-chip Vmem 128 MB；官方 JAX 配置给单 TensorCore 128 MiB VMEM 和 1 MiB SMEM，SparseCore 另有分散的 subcore VMEM | MB/MiB 不静默换算；SMEM 与 SparseCore 工作区不并入主 Vmem；物理 bank、共享与绝对带宽未公开 | `[1, On-Chip SRAM (Vmem); Figure 1]` `[5, TPU_8T branch]` |
| 片内互联 | `Memory and DMA Interconnect` 连接 TensorCore、SparseCore、六个 HBM3E controller、PCIe、chip manager 和 ICI/SerDes chiplet | logic chiplet 范围；拓扑、带宽、一致性和路由细节未公开 | `[1, Figure 1]` |
| 内存控制器与 PHY | 六个 HBM3E controller；独立 SerDes chiplet 内标有 ICI、ICR Router、`6x Link Stack` 与 `6x224G SerDes octals` | 图中原始标签。`224G` 的 lane、octal、编码和方向口径未解释，不计算聚合带宽 | `[1, Figure 1]` |
| 工艺与物理规模 | 未公开 | 未找到工艺、面积或晶体管数的一手数据 | `[1, 全文及 Figure 1]` |
| 封装组成 | 一个图示 logic chiplet、一个 ICI/SerDes chiplet及六组 HBM3E controller/stack；六个 HBM3E stack 旁标有 `12-hi` | TPU 8t package；interposer、基板和封装尺寸未公开 | `[1, Figure 1]` |
| 封装内互联 | logic chiplet 与 ICI/SerDes chiplet之间存在图示双向连接 | D2D 协议、链路数量、速率和聚合方向未公开；不能把外部 ICI 带宽当作 D2D 带宽 | `[1, Figure 1]` |
| RAS | Figure 1 标出 chip manager、gBMC 和管理用 PCIe Gen2 x1 | 只证明管理模块与接口存在；ECC、隔离、重放、降级及覆盖范围未公开 | `[1, Figure 1]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 图示一个 TensorCore 结构块、两个 SparseCore；另列 LLM Decoder Engine | Figure 1 与规格表口径；正文未确认完整使能资源计数 | `[1, Figure 1; TPU 8t and TPU 8i at a glance / Specialized Chip Features]` |
| 时钟 | 未公开 | 未找到基准或峰值时钟 | `[1, 全文及 Figure 1]` |
| 理论峰值 | 12.6 PFLOPS FP4 | 官方 per-chip 峰值；输入/累加格式、稠密或稀疏、FMA 计数和功耗点未公开 | `[1, TPU 8t and TPU 8i at a glance / Peak FP4 PFLOPs]` |
| 内存类型与容量 | HBM3E，216 GB | HBM3E 来自 Figure 1；216 GB 为官方 per-chip 配置 | `[1, Figure 1; TPU 8t and TPU 8i at a glance / HBM Capacity]` |
| 内存带宽 | 6,528 GB/s | 官方 per-chip 值；读写方向和有效带宽未公开 | `[1, TPU 8t and TPU 8i at a glance / HBM Bandwidth]` |
| 主机接口 | PCIe Gen5 x16；另有管理用 PCIe Gen2 x1 | 前者连接 host，后者连接 gBMC，不合并为同一主机带宽 | `[1, Figure 1]` |
| 设备互联端点 | 独立 ICI/SerDes chiplet，含 ICR Router、`6x Link Stack` 和 `6x224G SerDes octals`；官方发布规格图给出每芯片双向 ICI scale-up 带宽 19.2 Tb/s（2,400 GB/s），相比上一代为 2× | 每芯片双向值直接采用发布规格图；payload、编码与持续带宽未公开，不由 Figure 1 的 SerDes 标签反推 | `[1, Figure 1; TPU 8t: The pre-training powerhouse / Virgo 段后正文]` `[3, TPU 8t 规格图 / Bidirectional scale-up bandwidth]` |
| 内存访问语义 | TPUDirect RDMA 可在 TPU HBM 与 NIC 之间直接传输，绕过 host CPU/DRAM；TPUDirect Storage 可在 TPU 与托管存储之间建立绕过 host 的直接访问路径 | 只证明 DMA/RDMA 直达路径，不证明统一地址、cache coherence、远程一致内存或页迁移 | `[1, TPU 8t: The pre-training powerhouse / Faster storage access; Figure 3]` |
| 跨设备集合通信能力 | SparseCore 可卸载 data-dependent all-gather 等 collective | 芯片内专用单元承担的通信卸载；可支持的完整 collective 集、数据类型和吞吐未公开 | `[1, The SparseCore advantage]` |
| 功耗 | 未公开 | 未找到芯片、package 或系统功耗的可靠一手值 | `[1, 全文及 Figure 1]` |
| 形态与散热 | 官方 per-chip 云产品配置；具体模组与散热未公开 | 不把 Axion host、rack 或 Superpod 形态写成芯片形态 | `[1, TPU 8: Specialized by design; Figure 1]` |

## 6. 系统级互联上下文

本节只解释 TPU 8t 的芯片端点如何接入 Google 的 scale-up 与 scale-out 系统。所有规模和带宽均保留原始系统主语。

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | TPU 8t 采用 3D torus；单个 Superpod 可包含 9,600 颗芯片，ICI scale-up bandwidth 是上一代的 2× | 3D torus 与 9,600 是 Superpod 拓扑和域大小；单芯片只保留第 5 节的 ICI 端点 | `[1, TPU 8t: The pre-training powerhouse; TPU 8t and TPU 8i at a glance / Network Topology]` |
| Scale-out | Virgo 使用 high-radix switch、扁平两层 non-blocking topology 与多 plane 独立控制域；TPU 8t rack 还连接 Jupiter north-south fabric。官方发布规格图另给 scale-out networking bandwidth 为 400 Gb/s per chip | 400 Gb/s 是系统网络按芯片配置的资源，不证明 TPU 内集成同速率 NIC，也不与 ICI 的双向 19.2 Tb/s 相加；Virgo、Jupiter、交换机及 fabric 聚合值仍属芯片外 | `[1, TPU 8t: The pre-training powerhouse / Virgo Network topology]` `[3, TPU 8t 规格图 / Scale-out networking bandwidth]` |
| 系统可靠性 | Google 将多 plane 独立控制域与 high availability 联系起来 | 未公开冗余、故障绕行、维修域或降级机制，不能写成 die/package RAS | `[1, TPU 8t: The pre-training powerhouse / Virgo Network topology]` |
| 相关系统 | Google Cloud AI Hypercomputer、TPU 8t rack、9,600-chip Superpod、Virgo fabric | Axion CPU header、NIC、存储、SPOCS、Virgo、Jupiter 和 WAN 都是外部系统组成 | `[1, TPU 8: Specialized by design; Figure 2; Figure 3]` |

官方文章还披露 Virgo 单一 fabric 可连接超过 134,000 颗 TPU 8t，并给出 47 petabits/s 双剖带宽与集群聚合算力；这些数值属于 fabric 或集群，没有写入 SKU 配置。[1, TPU 8t: The pre-training powerhouse / Virgo 段后正文]

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| 完整使能计算资源 | 未公开 | 官方 Figure 1 与技术文章正文 | 保留图示结构，不把功能方框当作经正文确认的完整资源清单 |
| FP4 完整数值语义 | 未公开 | 官方 Native FP4 段、规格表 | 只记录原生 FP4 与官方峰值，不猜测乘积、累加、输出、舍入和 FMA 计数 |
| 时钟、功耗与散热 | 未公开 | 两个官方页面 | 如实登记缺失 |
| 工艺、面积与晶体管数 | 未公开 | 官方技术文章与产品页 | 如实登记缺失 |
| Vmem 管理与带宽 | 软件管理方式有公开说明，物理带宽未公开 | Pallas 文档与 JAX 8t 分支给出显式局部工作区及容量；Figure 1 和规格表不含物理 bank/端口参数 | 记录编程语义，不改称透明 L2 cache；分别保留产品 128 MB 与开发配置 128 MiB `[5, TPU_8T branch]` `[6, BlockSpecs and grid iteration]` |
| ICI 带宽与方向 | 每芯片双向值已公开，持续有效带宽未公开 | 官方发布规格图给出 19.2 Tb/s per chip `[3, TPU 8t 规格图 / Bidirectional scale-up bandwidth]` | 按 bit/byte 换算为 2,400 GB/s；不由 SerDes 标签重算，不解释为单向注入或 payload 带宽 |
| 封装内 D2D | 未公开 | Figure 1 | 只记录连接存在，不猜测协议或带宽 |
| RAS 机制 | 未公开 | Figure 1、Virgo 段 | 芯片管理模块与系统 high availability 不互相替代 |
| 可用状态 | 已确认 | 官方 TPU 产品页截至 2026-09-16 标为 `Coming soon` | 写为已宣布、尚未正式可用，不以 interest form 推断 Preview 或 GA |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Diwakar Gupta、Sabastian Mugazambi，*TPU 8t and TPU 8i technical deep dive* / 正文标题 *Inside the eighth-generation TPU: An architecture deep dive*，Google Cloud，2026-04-22 | 官方技术文章与封装框图 | 身份、定位、Core/package 结构、FP4、Vmem、HBM、ICI、TPUDirect 与系统互联边界 | [官方网页](https://cloud.google.com/blog/products/compute/tpu-8t-and-tpu-8i-technical-deep-dive)；[本地快照](../../../../前置调研/原文/网页快照/S14_tpu8t_tpu8i.html) |
| `[2]` | *Tensor Processing Units (TPUs)*，Google Cloud，访问日期 2026-09-16 | 官方产品页 | TPU 8t 当前状态、目标 workload 与 Superpod 口径 | <https://cloud.google.com/tpu> |
| `[3]` | Amin Vahdat，*Our eighth generation TPUs: two chips for the agentic era*，Google，2026-04-22 | 官方发布文章及 TPU 8t 规格图 | 每芯片双向 ICI 带宽与 scale-out 配置带宽 | [官方文章](https://blog.google/innovation-and-ai/infrastructure-and-cloud/google-cloud/eighth-generation-tpu-agentic-era/)；[规格原图](https://storage.googleapis.com/gweb-uniblog-publish-prod/images/TPU_8_Cloud_inline_1.width-1200.format-webp.webp)；[本地原图](../../../原始资料/网页快照/Google/TPU/2026-09-17/8t-launch.webp) |
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

复核结论：截至 2026-09-16，TPU 8t 的官方 per-chip 配置、芯片端点与系统边界已经按公开资料固定。未公开字段已登记，不影响本轮信息搜集完成。
