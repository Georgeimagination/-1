# Huawei Ascend 950DT 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

本卡以 Huawei Ascend 950DT packaged processor 为正式主语。950DT 是包含多个计算资源和内存配置的产品族，不能把各字段的最大值任意拼接成唯一销售 SKU。它与 950PR 共用第三代 DaVinci 架构，封装内包含 2 个 AI Die、2 个 IO Die 和 4 个高速内存模块；HiZQ 2.0 是官方路线图给出的高带宽内存（HBM）名称。Atlas 650E server、Atlas 850E SuperPoD、Atlas 950 SuperPoD 是上层产品，其系统聚合值不作为本卡的单封装规格。[1, PDF pp.10, 12-15，正文 pp.6, 8-11，图3-1、表3-1] [2, Ascend 950DT] [3, Table 1] [4, Atlas 650E specifications] [5, 真机亮相]

本卡以《昇腾950 NPU架构白皮书》的芯片规格和架构说明为主。文中 PDF 页码从封面开始计数；正文页码按目录分页，较 PDF 页码少 4 页。白皮书版权年为 2026，未标明确切发布日期；不以下载时间推定发布或供货日期。[1, 封面、版权页、目录]

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Huawei（华为） | Ascend processor | `[1, 封面]` |
| 产品家族 | Ascend 950 series，包括 950PR 与 950DT | 两款产品共架构，通过不同内存配置适配不同场景 | `[1, PDF p.10，正文 p.6，§3]` |
| 完整名称与配置边界 | Huawei Ascend 950DT | 含多个资源档位；未公开完整销售 part number 与各字段的一一配置映射 | `[1, PDF pp.13-15，正文 pp.9-11，表3-1及前文]` |
| 对象形态 | 多 chiplet 合封的 processor/package | 含 AI Die、IO Die 和高速内存模块，不是加速卡、服务器或集群 | `[1, PDF p.12，正文 p.8，图3-1]` |
| 架构代际 | 第三代 DaVinci | Ascend 950 共架构 | `[1, PDF p.10，正文 p.6，§3]` |
| 首次公开 | 2025-09-18 | HUAWEI CONNECT 2025 官方主题演讲 | `[2, 标题日期与芯片路标]` |
| 可用状态 | 已有官方系统型号与 Atlas 950 真机展示；950DT 独立上市或普遍可用日期仍未确认。2025 年路线图给出的 single-chip availability window 为 2026Q4 | 白皮书公开架构规格，不单独证明全部配置均已供货 | `[2, Ascend 950DT] [3, Table 1] [5, 真机亮相与 Atlas 850E]` |
| 厂商定位与目标 workload | 大模型预训练、后训练与推理全流程，包括 decode 和 prefill | 厂商定位，不是应用实测结论，也不表示另一款产品不能执行这些任务 | `[1, PDF p.10，正文 p.6，§3]` |
| 产品目标 | 以较高内存带宽和互联能力支持生成式模型的训练与复杂推理 | 厂商设计意图，不等同于已测量性能、能效或成本 | `[1, PDF pp.8, 10，正文 pp.4, 6]` |

## 2. 层级关系与复用

| 层级 | 本产品对应对象 | 与另一款 Ascend 950 的关系 | 本卡采用的边界 | 来源 |
|---|---|---|---|---|
| Core IP | 一个 AI 子系统含 1 个 Cube Core 和 2 个 Vector Core | 共享第三代 DaVinci 设计 | Cube 处理矩阵计算，Vector 处理向量计算；不把三者计成三个同类 AI Core | `[1, PDF pp.13, 17，正文 pp.9, 13，图4-1]` |
| AI Die | 计算 chiplet，完整封装有 2 个 | 两款产品共架构 | 承载 AI Core、CPU、片上缓存和内存接口等 | `[1, PDF pp.5, 12，正文 pp.1, 8，表1-1、图3-1]` |
| IO Die | IO 通信 chiplet，完整封装有 2 个 | 两款产品共架构 | 集成 UB/PCIe 等通信功能；不是另外两个计算 die | `[1, PDF pp.6, 12, 34，正文 pp.2, 8, 30]` |
| Package | 2 个 AI Die + 2 个 IO Die + 4 个高速内存模块 | HiZQ 2.0 内存分支 | 本卡正式物理对象；内存模块数不等于 DRAM 裸片层数 | `[1, PDF p.12，正文 p.8]` `[2, Ascend 950DT]` |
| 产品配置 | Ascend 950DT 的多个资源档位 | 使能资源与内存配置存在差异 | 按表3-1分别记录，不强行配对各字段 | `[1, PDF pp.13-15，正文 pp.9-11，表3-1]` |
| 上层产品 | Atlas 650E server、Atlas 850E SuperPoD、Atlas 950 SuperPoD | 按具体系统型号部署多个 950DT | 用于说明产品关系、实际系统配置和状态；不混入单封装聚合规格 | `[3, Table 1] [4, Atlas 650E specifications] [5, 真机亮相]` |

完整 Ascend 950 设计包含 36 个 AI 子系统、4 个 AI CPU Cluster、4 个 DVPP 图像处理子系统、128MB L2 和 STARS2.0 调度系统。950DT 的实际公开计算档位为 36 / 32 / 28 个 Cube、72 / 64 / 56 个 Vector；“完整设计”与“产品使能资源”应分开记录。每个完整 CPU Cluster 包含 2 个 Linx816 CPU 和 4MB L3。[1, PDF p.13，正文 p.9，表3-1及前文]

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与限制 | 来源 |
|---|---|---|---|
| 矩阵、向量与控制路径 | 一个 AI Core 含 1 个 Cube、2 个 Vector 及各自 Scalar 控制；图中 Cube 标为 16×16×16 FP16，Vector 各有两组 64×FP32 或 128×FP16 执行资源 | 图示资源与运算组织，不自行换算每周期吞吐、延迟或未公开时钟 | `[1, PDF p.17，正文 p.13，图4-1]` |
| 执行模型 | 支持 SIMD/SIMT 混合编程；SIMD 是主要向量计算路径，SIMT 可处理不规则访存与复杂分支；Vector Function 可选择两种模式并切换 | SIMD 为单指令多数据，SIMT 为单指令多线程；具体线程宽度、scheduler 数量和完整发射限制未公开 | `[1, PDF pp.16, 21，正文 pp.12, 17，§4.1、§4.1.3]` |
| Vector 执行 | register-based SIMD，支持双发 ALU 指令与乱序执行；Unified Buffer（UB，向量局部缓冲）与 Vector ALU 之间增加 Register File | 不能由双发推断任意指令组合均能同时发射 | `[1, PDF pp.11, 21，正文 pp.7, 17]` |
| 显式局部存储 | SIMD 编程显式管理 Global Memory、Local Memory 与 Register；CANN 文档给出 256B 单寄存器及 GM→UB→Register 层次 | 256B 是单寄存器大小，不是寄存器文件总容量 | `[6, AI Core 组成、显式分层访存与三级内存层次]` |
| SIMT 存储视图 | UB 可作为 Shared Memory 与 Data Cache；Vector Core 通过共享 L2 访问全局内存 | 编程抽象与物理 SRAM 容量分别记录，不把 SIMD 寄存器和 SIMT 线程寄存器重复计数 | `[7, 抽象硬件架构]` |
| Cube-Vector 数据通路 | Cube L1 与 Vector UB 有直接数据交换通路，支持随路精度和布局转换 | 减少融合算子中间结果搬运；未公开此通路的独立带宽 | `[1, PDF p.22，正文 p.18，§4.1.4]` |
| 数据搬运与同步 | NDDMA 是多维 DMA 引擎，支持五维数据排布变换；内部 cache 聚合 128B 读请求；BufferID 的 get_buf/rel_buf 协调生产者与消费者 | NDDMA 的 128B 请求粒度与全局 L2 的 512B cache line 是不同层次 | `[1, PDF pp.22-24，正文 pp.18-20，§4.1.4]` |
| 矩阵数值格式 | Cube 支持 MXFP4、HiF8、MXFP8、FP8、INT8、BF16、FP16、TF32；图中 FP8 分为 E5M2/E4M3，FP4 为 E2M1 | 算力使用表3-1纯 Cube 栏；图中 FP32 格式示意不提供 Cube FP32 峰值 | `[1, PDF pp.13-14, 18，正文 pp.9-10, 14，表3-1、图4-3]` |
| 相对计算速率 | 同频下，Cube 的 HiF8/MXFP8/FP8 TFLOPS 为 FP16 的 2 倍，MXFP4 为 4 倍 | 是精度带来的相对速率，不是稀疏翻倍 | `[1, PDF p.17，正文 p.13，§4.1.1]` |
| 输出转换与累加边界 | L0C→UB 可将 FP32/INT32 量化到 BF16/FP16/FP8/INT8，并转换 NZ→ND/DN 布局 | 可确认输出数据路径；完整输入/乘积/累加/输出组合、舍入与溢出规则未全部公开 | `[1, PDF p.17，正文 p.13，§4.1.1]` |
| HiF8 编码 | 8 位格式动态分配指数与尾数，描述的指数幂次覆盖为 [-22,15]，不采用 MX 格式的额外 8 位 scale | 独立的数值编码；不把“接近 FP16”视为对任意模型精度的保证 | `[1, PDF pp.19-20，正文 pp.15-16，§4.1.1]` |
| 稀疏与专用功能 | 未找到结构化稀疏模式或专用 MoE routing、top-k、sampling、KV Cache 单元的一手证据；已公开针对 FlashAttention、Softmax、GELU 的数据通路或微架构优化 | 算子优化不等于独立专用引擎；没有充分测试条件的厂商性能倍数不列为可比实测 | `[1, PDF pp.16-17, 21-22，正文 pp.12-13, 17-18]` |

## 4. Die、chiplet 与 package

| 维度 | 公开实现或物理组成 | 作用域与限制 | 来源 |
|---|---|---|---|
| 完整设计与使能 | 完整设计 36 个 AI 子系统；本产品表列 36 / 32 / 28 Cube、72 / 64 / 56 Vector | 产品档位见§5，不能用完整设计替代使能数 | `[1, PDF p.13，正文 p.9，表3-1及前文]` |
| Core 局部 SRAM | 每 AI Core：L1 512KB、L0A 64KB、L0B 64KB、L0C 256KB、UB 合计 512KB | 图4-1显示两个 Vector 各有 256KB UB；这些是局部缓冲，不能全部称为硬件 cache | `[1, PDF pp.17, 25，正文 pp.13, 21，图4-1、表4-2]` |
| CPU 缓存 | 每 Linx816 Core：L1 64KB、L2 1MB；每 CPU Cluster：L3 4MB | CPU 基于 ARMv8-A，支持单/双线程配置，核内线程共享 CPU L1/L2；实际 CPU 档位见§5 | `[1, PDF pp.24-25，正文 pp.20-21，§4.2、表4-2]` |
| 全局 L2 | 128 MB；512B cache line，由 4×128B sector 组成；支持 Hint、按 way 管理及 CMO | 与 AI Core 的 L1/L0/UB、CPU 的 L1/L2/L3区分 | `[1, PDF pp.11, 15, 25-27，正文 pp.7, 11, 21-23，表3-1、§4.3]` |
| 本地内存一致性 | 两计算 die 采用统一内存访问；AI CPU 与 AI Core 共享芯片内存，以硬件缓存一致性协调 CPU cache 与 AI Core+L2；L2支持跨 die 一致性 | 只确认本芯片范围，不扩展为所有远程设备的全系统 cache coherence | `[1, PDF pp.24-26，正文 pp.20-22，图4-9、§4.3]` |
| 高速内存模块 | 4 个高速内存模块；白皮书明确为 DRAM，官方路线图名称为 HiZQ 2.0 HBM | 模块数不等于 DRAM 堆叠层数；controller/PHY宽度、内存时钟及堆叠层数未公开 | `[1, PDF pp.12, 25，正文 pp.8, 21]` `[2, Ascend 950DT]` |
| 封装内互联 | AI Die、IO Die与内存模块通过 D2D Clink 和 Memory Interface 相连 | 链路宽度、各条链路峰值及完整 D2D 拓扑未公开；外部 2016GB/s 不是 D2D 带宽 | `[1, PDF p.12，正文 p.8，图3-1及前文]` |
| 片内 NoC 与转发 | 每个 IO Die 支持 9 个×4端口之间的路由转发，流量通过 IO Die 的 NoC，不进入计算 die、不占用 DRAM 带宽 | 完整计算 NoC 的拓扑与带宽未公开 | `[1, PDF p.34，正文 p.30，§4.6.5]` |
| STARS2.0 调度 | 硬件调度 AI Core、AI CPU、DVPP、系统DMA（SDMA）、UB通信与集合通信单元（CCU）；支持 2048 条任务流，并行支持 16 个 AI CPU任务、64个Host任务、64个UB Jetty任务、32个CCU任务、32个SDMA通道 | 任务并发数不是相应物理引擎数量，32 个CCU任务不代表32个CCU | `[1, PDF pp.27-28，正文 pp.23-24，§4.4]` |
| 内存可靠性（RAS） | DRAM online ECC、巡检弱单元并重写/隔离、保留行动态修复 | 纠错码参数、SRAM覆盖范围与完整故障颗粒度未公开 | `[1, PDF p.26，正文 p.22，§4.3]` |
| 制造与物理规模 | process、foundry、die area、transistor count、die clock、封装尺寸未公开 | 不从“自主制造”表述推断具体工艺，也不用传闻补值 | `[1, §3-4；未列这些参数]` |

## 5. SKU 配置

### 5.1 计算资源与规格算力

下表按官方列顺序记录。950DT 的算力列依次对应 36 / 32 / 28 个 Cube，Vector 数为其两倍。这里只能把计算资源与同列计算规格对应；不能进一步按位置强行配对 CPU、DRAM 或 L2 档位。表3-1未给运行频率、功耗模式、FMA计数和结构化稀疏条件；以下是厂商规格值，不是实测。[1, PDF pp.13-15，正文 pp.9-11，表3-1]

| 单元/精度 | 原始值 | 口径 | 来源 |
|---|---:|---|---|
| Cube MXFP4 | 1946 / 1730 / 1513 TFLOPS | 纯 Cube 规格，不含 Vector | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| Cube HiF8 / MXFP8 / FP8 | 973 / 865 / 756 TFLOPS | 纯 Cube 规格，不含 Vector | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| Cube INT8 | 973 / 865 / 756 TOPS | 纯 Cube 规格，不含 Vector | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| Cube BF16 / FP16 | 486 / 432 / 378 TFLOPS | 纯 Cube 规格，不含 Vector | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| Cube TF32 | 243 / 216 / 189 TFLOPS | 纯 Cube 规格，不含 Vector | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| Vector FP16 / BF16 | 60 / 54 / 47 TFLOPS | 纯 Vector 规格，不含 Cube | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| Vector FP32 | 30 / 27 / 23 TFLOPS | 纯 Vector 规格，不含 Cube | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| Vector INT8 | 60 / 54 / 47 TOPS | 纯 Vector 规格，不含 Cube | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| Vector INT16 | 30 / 27 / 23 TOPS | 纯 Vector 规格，不含 Cube | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| Vector INT32 | 15 / 13 / 11 TOPS | 纯 Vector 规格，不含 Cube | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| Vector INT64 | 7 / 6 / 5 TOPS | 纯 Vector 规格，不含 Cube | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |

官方另列 Cube+Vector 聚合算力，记录如下，以免与产品页 headline 混淆。表中未列 Vector MXFP4/FP8 吞吐，不能把聚合数进一步解释为全部由同一低精度矩阵单元产生；跨厂商矩阵算力比较使用上表的纯 Cube 值。[1, PDF pp.13-14，正文 pp.9-10，表3-1]

| 官方聚合项 | Cube+Vector总量 | 来源 |
|---|---:|---|
| MXFP4 | 2007 / 1784 / 1561 TFLOPS | `[1, PDF p.13，正文 p.9，表3-1]` |
| HiF8 / MXFP8 / FP8 | 1034 / 919 / 804 TFLOPS | `[1, PDF p.13，正文 p.9，表3-1]` |
| INT8 | 1034 / 919 / 804 TOPS | `[1, PDF p.13，正文 p.9，表3-1]` |
| BF16 / FP16 | 547 / 486 / 425 TFLOPS | `[1, PDF p.13，正文 p.9，表3-1]` |
| TF32 | 273 / 243 / 212 TFLOPS | `[1, PDF p.13，正文 p.9，表3-1]` |

最大2007TFLOPS是36 Cube配置、MXFP4项的Cube+Vector聚合总量；纯Cube MXFP4为1946TFLOPS。原表聚合量与已取整的分项不总能严格相加，例如1946+60=2006而聚合项为2007；保留官方各项原值，不自行校正或从中反推频率。[1, PDF pp.13-14，正文 pp.9-10，表3-1]

### 5.2 内存、接口与其他配置

| 字段 | 原始值或公开能力 | 条件和口径 | 来源 |
|---|---|---|---|
| 高速内存 | HiZQ 2.0 HBM；白皮书规格为 144 / 96 GB | 多个processor配置；未公开与各Core/CPU档位的完整组合映射 | `[1, PDF pp.14, 25，正文 pp.10, 21，表3-1、表4-2]` `[2, Ascend 950DT]` |
| 内存带宽 | 4 TB/s | 单封装规格；读写合计方式、方向与持续带宽未说明 | `[1, PDF p.14，正文 p.10，表3-1]` |
| 全局L2 | 128 MB | 本产品公开规格均列128MB；不反推与CPU/内存档位的完整配对关系 | `[1, PDF p.15，正文 p.11，表3-1]` |
| AI CPU | Linx816，8C16T / 6C12T；支持NEON | C为CPU核，T为线程；不是AI Core数量 | `[1, PDF p.14，正文 p.10，表3-1]` |
| DVPP | 4/2个VPC、8个JPEGD、4/2个JPEGE | 图像预处理及JPEG编解码硬件；资源档位不与Core/内存强配 | `[1, PDF p.14，正文 p.10，表3-1]` |
| 外部SerDes | 72条HiLink lane，每lane最高112Gbps，组成18个×4端口 | 全封装合计，不是每IO die18端口 | `[1, PDF pp.10, 13，正文 pp.6, 9]` |
| UB设备互联 | Unified Bus 2.0（通信语境中的UB）；2016GB/s双向 | 18×4×112Gbps÷8×2；出框速率还受光模块限制，非有效payload或持续吞吐 | `[1, PDF p.15，正文 p.11，表3-1]` |
| UBoE（UB over Ethernet） | 全芯片2×400Gbps Ethernet Link，200GB/s双向合计 | 集成于芯片；与UB共用2个端口，支持2个×4或4个×2配置 | `[1, PDF pp.15, 30-31，正文 pp.11, 26-27，表3-1、§4.6.2]` |
| PCIe接口 | PCIe5.0，1×16，128GB/s双向；可降至×8/×4/×2，向下兼容Gen4/3/2/1，EP/RC静态选定 | 芯片集成控制器；与UB共用4个端口；上层产品实际暴露接口另计 | `[1, PDF pp.15, 29-30, 35，正文 pp.11, 25-26, 31，§4.6.6]` |
| 异步远程访问 | URMA经Jetty队列支持write/read/send及immediate/notify、Atomic FetchAdd/CAS；UMMU负责VA→PA地址转换与权限校验 | URMA为异步远程内存访问，UMMU为地址转换/权限部件；不是本地内存容量 | `[1, PDF pp.30-31，正文 pp.26-27，§4.6.1]` |
| 同步远程访问 | UB Memory支持AI Core/AI CPU发起read/write、AtomicStore/Load/Swap/CAS，经对端地址翻译和权限校验直接访问远端内存 | 可确认远程load/store/atomic；没有由此证明所有远端缓存的全局一致性或按缺页迁移机制 | `[1, PDF pp.31-32，正文 pp.27-28，§4.6.3]` |
| 集合通信硬件 | CCU运行软件预置算法，完成搬运、同步、归约；支持Broadcast、Reduce Scatter、All Gather、All Reduce、All2All、All2Allv | 已确认硬件卸载；CCU/CCUA数量、MemorySlice容量、归约精度和吞吐未公开 | `[1, PDF pp.32-33，正文 pp.28-29，§4.6.4]` |
| 时钟与功耗 | 未公开 | 不用上层board/server功耗替代processor值 | `[1, 表3-1、§4；未列这些参数]` |
| 形态与散热 | 多chiplet packaged processor；封装尺寸、processor独立thermal solution未公开 | 上层加速卡、服务器或超节点散热另计 | `[1, PDF p.12，正文 p.8；表3-1]` |

UB、UBoE和PCIe共用部分物理端口，不能把2016、200和128GB/s相加。启用一个400G Ethernet端口会减少相应UB Link能力；同样不能把系统附加网络卡的吞吐加进本芯片端点。[1, PDF p.15，正文 p.11，表3-1；PDF31，正文27，§4.6.2]

CCU包含任务解释控制部分CCUM，以及带MemorySlice和Reduce Unit的CCUA；它可以调用URMA，把远端数据搬至本地DRAM或MemorySlice后处理。这是芯片内的集合通信硬件，而软件负责预置通信算法。图中多个方框表示结构，不提供精确物理数量。[1, PDF p.33，正文 p.29，图4-14及后文]

## 6. 系统级互联上下文

| 内容 | 公开事实 | 与本芯片的边界 | 来源 |
|---|---|---|---|
| Scale-up拓扑能力 | 支持Clos、Full Mesh+Clos、nD-Mesh；通过UB Switch扩展；厂商给出最大8192卡超节点 | 芯片/架构支持上限，不等于现有某台系统的规模或已交付集群 | `[1, PDF p.30，正文 p.26，§4.6]` |
| Scale-out端点 | 芯片集成UBoE，可通过以太网交换机组网，scale-up与scale-out端口复用 | 2×400Gbps为芯片能力，系统可暴露更少端口；不将UBoE自动等同独立RoCE NIC | `[1, PDF pp.11, 31，正文 pp.7, 27，§4.6.2]` |
| 共享访问规模 | 白皮书称支持最高128TB的Host-Device及Device-Device内存共享访问 | 是远程共享访问范围，不是本封装DRAM容量，也不证明远端全局cache coherence | `[1, PDF p.11，正文 p.7]` |
| 传输可靠性 | UB支持链路层重传；RTP支持端到端可靠重传，CTP不支持端到端可靠重传 | §4.6.1分别写RTP支持4个Port可靠传输带宽、CTP支持9个Port带宽，但未明确按单IO die或全封装计，不乘2或外推18端口全速可靠传输 | `[1, PDF pp.30-31，正文 pp.26-27，§4.6.1]` |
| Atlas 650E | 采用8×950DT，系统配置为8×96GB；可通过UnifiedBus Link 2.0构成跨两台服务器的16-NPU full-mesh | 这是具体server/domain配置；系统互联聚合值、网络、约14.5kW系统功耗与电源/风扇冗余不下放成processor参数 | `[4, Atlas 650E Product Features and Specifications]` |
| Atlas 850E / 950 | 官方型号表列出两者；2026-07新闻展示Atlas950真机，并称Atlas850E支持单个风冷超节点扩展至96卡商用部署 | “支持96卡商用部署”是能力表述，不证明已完成96卡客户部署；真机展示也不等于所有DT配置独立GA | `[3, Table 1]` `[5, 真机亮相与 Atlas 850E]` |

96GB和144GB均已由白皮书表3-1直接列为950DT芯片容量，4TB/s也是单芯片表列带宽。Atlas650E的8×96GB是具体系统配置，产品族的144GB档位和4TB/s现有直接芯片规格来源，不依赖该服务器配置推断。[1, PDF p.14，正文 p.10，表3-1] [4, Atlas 650E specifications]

## 7. 证据缺口与来源差异

| 项目 | 已确认内容 | 仍未确认的边界与处理 | 来源 |
|---|---|---|---|
| 产品族与精确SKU | 表3-1列出多个Core、CPU、内存和L2资源档位 | 未给完整part number及档位组合；不按斜杠位置强行配对所有字段 | `[1, PDF pp.13-15，正文 pp.9-11，表3-1]` |
| 算力口径 | 矩阵与向量分项、Cube+Vector聚合值已公开 | 主要比较采用纯Cube；未补写频率、功耗、FMA计数、dense/sparse条件或实测利用率 | `[1, PDF pp.13-14，正文 pp.9-10，表3-1]` |
| 2025路线图与当前规格 | 早期1PFLOPS低精度、2PFLOPS MXFP4为概略标签；白皮书细化资源档位和算力分项 | 当前数字以表3-1为主，不用路线图近似数覆盖或叠加精确规格 | `[1, 表3-1]` `[2, Ascend 950 architecture]` |
| 数值语义与稀疏 | 编码格式、部分输出转换和HiF8语义可确认 | 完整输入/乘积/累加/输出、舍入/溢出和结构化稀疏模式仍缺失 | `[1, PDF pp.17-20，正文 pp.13-16，§4.1.1]` |
| 存储层次 | SRAM/L2容量与512B line、128B sector已确认 | Register File总容量、cache各操作完整一致性规则及实测带宽未公开 | `[1, PDF pp.17, 25-27，正文 pp.13, 21-23]` `[6, 三级内存层次]` |
| 远程内存语义 | 有UB Memory同步访问、URMA异步访问、地址翻译和权限校验 | 芯片内一致性不代表远端全局一致性；没有充分证据填写缺页迁移机制 | `[1, PDF pp.24-26, 30-32，正文 pp.20-22, 26-28]` |
| 互联端口与吞吐 | 18×4 HiLink、2016GB/s双向、UBoE和PCIe端口复用已确认 | D2D/完整NoC带宽、payload效率及各传输模式持续吞吐未知；RTP/CTP的4/9端口范围不外推 | `[1, PDF pp.12, 15, 30-35，正文 pp.8, 11, 26-31]` |
| CCU硬件规模 | 任务控制、MemorySlice、Reduce Unit及支持的collective已确认 | 引擎数量、缓冲容量、归约数据类型与吞吐未公开，任务并发不等于物理数量 | `[1, PDF pp.28, 32-33，正文 pp.24, 28-29]` |
| 物理实现和运行条件 | 多die角色与内存模块数已公开 | 工艺、foundry、面积、晶体管、频率、功耗、封装尺寸、内存位宽/层数等未公开 | `[1, 图3-1、表3-1、§4]` |
| 上市与供货 | 官方系统型号与Atlas950真机可确认，Atlas850E的96卡为支持能力 | 独立封装销售和全部资源配置的供货日期未知；白皮书无明确发布日期，不用版权年证明GA | `[2, Ascend 950DT] [3, Table 1] [5, 真机亮相与 Atlas 850E]` `[1, 版权页]` |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接 |
|---:|---|---|---|---|
| `[1]` | Huawei，《昇腾950 NPU架构白皮书》，40页，版权2026，未标明确切发布日期 | 官方架构白皮书 | 产品档位、计算/内存/CPU资源、多die、Core微架构、数值格式、互联、CCU、调度和RAS | <https://public-download.obs.cn-east-2.myhuaweicloud.com/ascend/%E6%98%87%E8%85%BE950%20NPU%E6%9E%B6%E6%9E%84%E7%99%BD%E7%9A%AE%E4%B9%A6.pdf>；[本地 PDF](../../../原始资料/论文/华为昇腾_DaVinci/90_官方白皮书与技术资料/2026_Ascend950_NPU_Architecture_White_Paper.pdf) |
| `[2]` | Huawei，《以开创的超节点互联技术，引领AI基础设施新范式》，2025-09-18 | 官方主题演讲 | 首次公开、HiBL1.0/HiZQ2.0名称、早期路线图及DT availability window | <https://www.huawei.com/cn/news/2025/9/hc-xu-keynote-speech> |
| `[3]` | Huawei Ascend Community，《昇腾产品形态说明》 | 官方FAQ | 950DT对应Atlas650E/850E/950 | <https://www.hiascend.com/document/detail/zh/AscendFAQ/ProduTech/productform/hardwaredesc_0001.html> |
| `[4]` | Huawei Ascend Community，Atlas 650E | 官方server产品页 | 8×950DT、8×96GB配置、16-NPU full-mesh及系统边界 | <https://www.hiascend.com/en/hardware/ai-server?tag=800A2> |
| `[5]` | Huawei，《昇腾950超节点真机亮相2026世界人工智能大会》，2026-07-17 | 官方新闻 | Atlas950真机与Atlas850E支持96卡商用部署的能力表述 | <https://www.huawei.com/cn/news/2026/7/atlas-950-superpod> |
| `[6]` | Huawei Ascend Community，《概述：AI Core SIMD编程》，CANN9.1.0 | 官方编程指南 | 显式分层访存、256B单寄存器、GM→UB→Register | <https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/910/programug/Ascendcopdevg/docs/guide/%E7%BC%96%E7%A8%8B%E6%8C%87%E5%8D%97/%E7%BC%96%E7%A8%8B%E6%A8%A1%E5%9E%8B/AI-Core-SIMD%E7%BC%96%E7%A8%8B/%E6%A6%82%E8%BF%B0.md> |
| `[7]` | Huawei Ascend Community，《抽象硬件架构：AI Core SIMT编程》，CANN9.1.0 | 官方编程指南 | SIMT的Shared Memory、Data Cache与L2抽象 | <https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/910/programug/Ascendcopdevg/docs/guide/%E7%BC%96%E7%A8%8B%E6%8C%87%E5%8D%97/%E7%BC%96%E7%A8%8B%E6%A8%A1%E5%9E%8B/AI-Core-SIMT%E7%BC%96%E7%A8%8B/%E6%8A%BD%E8%B1%A1%E7%A1%AC%E4%BB%B6%E6%9E%B6%E6%9E%84.md> |

## 9. 完成检查

- [x] 产品族、使能档位、完整设计与上层系统边界已分开。
- [x] 矩阵采用纯Cube规格，Cube+Vector聚合数另列；未强配CPU、内存和L2档位。
- [x] 关键数字标注精度、单位、方向、作用域与可定位原文；端口复用及未知条件已说明。
- [x] 多die、存储、PCIe/UBoE、CCU、RAS及可用状态按新证据更新；未将支持能力写成已完成部署。
- [x] 文末仅保留正文实际引用来源。
