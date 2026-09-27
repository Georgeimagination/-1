# NVIDIA Rubin CPX 128GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：调研中（完整格式表、片上存储容量与分层带宽尚缺）  
> 资料截止日：2026-09-27

本卡研究 NVIDIA 于 2025 年公布的 Rubin CPX 单 GPU 配置。它面向长上下文推理的 prefill，即处理输入 token、建立后续生成所需上下文的阶段；token 是模型处理的基本序列单位。[1, 开篇] [2, 分解推理：针对 AI 复杂性的可扩展方法]

产品计划已有变化。 2025 年发布稿原定于 2026 年底提供 CPX；但 2026 年 3 月公布的 Ian Buck 现场问答逐字稿中，他表示已撤下当年的 CPX 安排，把资源转向 decode（逐步生成输出 token）侧，并考虑在下一代重新推进 CPX。因此，本卡保存的是已公布、后来暂缓的方案，不能继续把旧供货时间写成现行承诺，也不能据此断言永久取消或确定新的上市年份。[1, Availability] [5, CPX delay and LPU decode architecture；CPX is still a good idea, says Buck]

## 基本规格先读

| 关心的问题 | 当前能确认到什么程度 | 证据 |
|---|---|---|
| 单 GPU 算力多大？ | 官方最高 30 PFLOPS NVFP4，即 30,000 TFLOPS；发布稿没有注明稠密/稀疏条件。NVFP4 是 NVIDIA 的 4 位浮点格式；PFLOPS 表示每秒 10¹⁵ 次浮点运算，TFLOPS 为每秒 10¹² 次 | [1, Advancements Offered by Rubin CPX] |
| 稠密算力是多少？ | SemiAnalysis 给出约 20 PFLOPS FP4 dense，将 30 PFLOPS 解释为 sparse 峰值；这是独立分析口径，尚无本轮取得的 CPX 官方规格表直接确认 | [4, Bandwidth and Compute Difference] |
| 支持多少种数据格式？ | 总数未确认。 CPX 官方发布资料点名 NVFP4，但没有完整支持矩阵；不能据此说“只支持一种”。各格式情况见第 3 节 | [1, 单 GPU 规格段] [6, 型号表] [7, Table 33] |
| 有多少级存储？ | 物理层级数未确认。 官方只明确外部显存配置；寄存器、L1/shared memory、L2 等片上层次未取得 CPX 专属容量、组织和带宽表，见第 4 节 | [1-3, CPX 规格与技术说明] [6-7, 型号映射及资源表] |
| 显存多大、带宽多少？ | 128 GB GDDR7 为官方值；约 2 TB/s 为 SemiAnalysis 估算。 GDDR7 是第七代图形用双倍数据速率内存。官方单 GPU 带宽仍未确认 | [1, Advancements Offered by Rubin CPX] [4, Bandwidth and Compute Difference] |
| 片上每层带宽多少？ | 寄存器、L1/shared memory、L2 的带宽均未找到 CPX 专属数值；约 2 TB/s 仅指第三方估算的外部显存接口，不能代替片上带宽 | [1-3, CPX 技术说明] [4, Bandwidth and Compute Difference] [7, Table 31-32] |

这张卡可以用于了解 CPX 已公布的设计取向，但现有证据还不足以完成各精度算力和分层存储性能的定量比较。第三方估算单独标出，不作为厂商已确认规格或实测结果。

## 1. SKU 身份与厂商定位

SKU 指配置明确的产品型号；CPX 未取得完整板卡料号，因此本卡采用官方单 GPU 配置作为研究单位。[1, Advancements Offered by Rubin CPX]

| 字段 | 内容与范围 | 来源 |
|---|---|---|
| 厂商与产品名 | NVIDIA Rubin CPX GPU，区别于配备 HBM 的标准 Rubin GPU | [1, 开篇及系统说明] |
| 研究配置 | 单 GPU，128 GB GDDR7；不同功耗档位和板卡型号未找到 | [1, Advancements Offered by Rubin CPX] |
| 架构代际与计算裸片 | Rubin 架构，monolithic die（单计算裸片） | [1, 开篇单片设计段] |
| 首次公开 | 2025-09-09 | [1, 发布日期] |
| 计划状态 | 2025 年宣布；2026 年 3 月厂商负责人称暂缓当年安排，下一代再考虑。尚无本轮可核实的交付声明 | [1, Availability] [5, CPX delay and LPU decode architecture] |
| 定位 | 长上下文 prefill；与承担生成阶段的 GPU 配合 | [2, Rubin CPX：专为加速长上下文处理而构建，图1] [3, 同名章节] |
| 目标应用 | 长代码上下文、长视频与生成式视频应用；百万级 token 是目标负载规模，不是无条件的单芯片容量指标 | [1, 开篇与视频处理段] |

## 2. 层级关系与复用

| 层级 | 已确认关系 | 来源 |
|---|---|---|
| 计算核心 | 具备 NVFP4 运算能力；未取得 CPX 专属的 SM 数量及执行单元配置。SM 是 GPU 的流式多处理器 | [1, Advancements Offered by Rubin CPX] |
| 计算裸片 | 单计算裸片；不能由此确定所有辅助芯片或显存颗粒的数量与位置 | [1, 开篇单片设计段] |
| 单 GPU 配置 | 128 GB GDDR7；完整封装剖面、显存颗粒和内存通道组成未公开于已取得的官方资料 | [1, Advancements Offered by Rubin CPX] |
| 上层系统 | 发布时规划 Vera Rubin NVL144 CPX，组合 CPX、标准 Rubin GPU 和 Vera CPU，并提供独立 CPX 计算托盘方案 | [1, 开篇系统段] [3, 图2] |

[Rubin 架构观察资料](../架构/NVIDIA_Rubin_架构_观察.md)用于同代背景阅读。架构名称相同不能证明 CPX 与标准 Rubin 采用相同的核心数量、片上存储、数据格式或互联配置。

## 3. 算力、数据格式与执行路径

30 PFLOPS 是官方发布峰值；20 PFLOPS dense 是第三方分析值。 SemiAnalysis 按 sparse:dense = 3:2 解释 CPX 的 FP4 峰值，但本轮取得的官方 CPX 正文未给出该换算关系。因此不能自行把 30 PFLOPS 除以 2，也不能按位宽直接折算 FP8、FP16 算力。[1, Advancements Offered by Rubin CPX] [4, Bandwidth and Compute Difference]

| 格式 | CPX 专属支持与峰值证据 | 仍缺什么 |
|---|---|---|
| NVFP4 | 官方明确最高 30 PFLOPS；第三方给出约 20 PFLOPS dense，条件如上。[1, 单 GPU 规格段] [4, Bandwidth and Compute Difference] | 官方稠密/稀疏条件、累加精度、运行频率及完整乘加计数说明 |
| 其他 FP4、FP6、FP8 | 未找到 CPX 专属支持表或峰值；FP4/6/8 分别指 4/6/8 位浮点格式族。[1-3, 规格说明] [6-7, 型号映射与 Table 33] | 具体编码、缩放方案、原生矩阵执行路径与吞吐 |
| FP16、BF16 | 未找到 CPX 专属矩阵支持与峰值；二者均为 16 位浮点格式，但指数与尾数分配不同。[6-7, 型号映射与 Table 33] | 原生支持、累加格式及 dense/sparse 峰值 |
| TF32 | 未找到 CPX 专属矩阵支持与峰值；TF32 是 NVIDIA 的 TensorFloat-32 计算格式。[6-7, 型号映射与 Table 33] | 原生矩阵路径、累加条件与峰值 |
| FP32、FP64 | 官方称其为 CUDA GPU，但未列 CPX 的 32/64 位浮点执行配置或峰值。[1, 开篇引述] [6-7, 型号映射与资源表] | 通用计算与矩阵计算应分别核对，不能混用吞吐 |
| INT8、INT4 | 未找到 CPX 专属原生整数矩阵支持表或峰值；二者为 8/4 位整数。[6-7, 型号映射与 Table 33] | 是否原生执行、累加类型及峰值；软件转换不能代替硬件支持证据 |

这里的“未找到”不表示“不支持”。CUDA 是 NVIDIA GPU 编程平台；其 compute capability（CC）用于标识硬件特征与指令支持。官方型号对照表未列 CPX，因此不能把其他 CC 行的完整格式表直接挂到 CPX 名下。Programming Guide 的 Table 33 还是 Tensor Core 输入类型表，不是整颗 GPU 所有存储、转换、标量和矩阵格式的总表；Tensor Core 是专门加速矩阵运算的执行单元。[6, Compute Capability 型号表] [7, 5.1.1、5.1.2.1、Table 33]

矩阵单元数量、标量/向量通路、调度器、发射宽度和搬运单元配置均未在已取得的 CPX 官方资料中列明。官方确认芯片集成视频编码和解码硬件，但未在这些正文中给出单元数量、编解码格式及吞吐；视频 decoder 也不等于大模型的 decode 阶段。[1, 视频处理段] [2-3, CPX 技术说明]

## 4. 存储层级、容量与带宽

目前不能给 CPX 填一个经过确认的“几级存储”数字。 下表按 GPU 调研通常需要核对的存储项逐项列出，并不把这些项的数量当成 CPX 已确认的物理层数。shared memory 是程序显式管理的共享工作存储，不是另一级自动缓存；它与 L1 是否共用物理资源、如何划分容量，也需要 CPX 本身的证据。[7, Table 31-32]

| 待核对的存储项 | CPX 容量与组织 | CPX 带宽 | 证据与范围 |
|---|---|---|---|
| Register file（寄存器文件） | 每 SM 容量、bank/端口组织未找到 | 未找到每 SM 或全芯片读写带宽 | CPX 未建立 CC 映射，不能套用通用资源表。[6, 型号表] [7, Table 31] |
| L1 cache（一级缓存） | 容量及与 shared memory 的划分未找到 | 未找到 | CPX 发布资料未列；CC 资源表未明确对应 CPX。[1-3, 技术说明] [7, Table 32] |
| Shared memory（共享工作存储） | 每 SM/线程块可用容量、bank 组织未找到 | 未找到 | 不能把标准 Rubin 的容量写为 CPX 容量。[6, 型号表] [7, Table 31-32] |
| L2 cache（二级缓存） | 全芯片容量、切片与一致性组织未找到 | 未找到 | 已取得的 CPX 官方资料未列。[1-3, 技术说明] |
| 其他专用片上存储 | 是否配置独立矩阵工作存储及其容量未确认 | 未找到 | 不按同代产品名称推定 CPX 配置。[1-3, 技术说明] [7, 5.1.2.1] |
| 外部显存 GDDR7 | 128 GB，官方确认；保留原单位 GB | 官方值未找到；SemiAnalysis 估算约 2 TB/s | 单 GPU 显存接口总量，非片上带宽，也非整机架聚合值。[1, 单 GPU 规格段] [4, Bandwidth and Compute Difference] |

显存带宽估算的假设是 512-bit 总位宽、每位 32 Gb/s。按这些假设计算，32 × 512 ÷ 8 = 2,048 GB/s，即 2.048 TB/s，通常取约 2 TB/s。位宽和速率均来自 SemiAnalysis 的预估，尚未取得官方 CPX 规格确认；该值不是实测有效吞吐，也不应再按“读写双向”翻倍。[4, Bandwidth and Compute Difference；本卡按所列假设计算]

片上 SRAM（静态随机存取存储器）的总量目前不能计算。缺少各级容量、资源数量及共享关系时，既不能把寄存器、L1 和 shared memory 简单相加，也不能从 128 GB 外部显存推断片上容量。

## 5. 单 GPU 物理与接口配置

| 字段 | 官方证据与缺口 | 独立分析补充及边界 |
|---|---|---|
| 工艺、面积、晶体管数 | 官方确认单计算裸片，未给出这些物理规模参数。[1, 开篇] | 不使用标准 Rubin 的数值 |
| 核心使能数与时钟 | 未找到。[1-3, 技术说明] | 不从峰值和假定时钟反推 SM 数量 |
| 封装 | 未取得完整基板与显存颗粒布局。[1-3, 技术说明] | 第三方描述为传统 flip-chip BGA（倒装焊球阵列）封装，未获官方规格确认。[4, Bandwidth and Compute Difference] |
| 主机接口 | 未找到官方 CPX 代际、通道数及有效带宽表。[1-3, 技术说明] | SemiAnalysis 给出 PCIe Gen6 ×16，约 1 Tbit/s 单向的链路量级；PCIe 是外设互联总线，该数值不是应用有效吞吐。[4, More on Prefill Pipeline Parallelism: One Interesting Upside of Disaggregated Prefill with the Rubin CPX] |
| GPU 间互联 | 未找到 CPX 专属 NVLink 端点规格；NVLink 是 NVIDIA 的高速芯片互联。[1-3, 技术说明] | SemiAnalysis 称无 NVLink SerDes（串行收发器），依靠 PCIe 与网卡连接；保留为第三方判断。[4, Bandwidth and Compute Difference] |
| 功耗与散热 | 未找到单 GPU 官方额定功率和散热配置。[1-3, 技术说明] | SemiAnalysis 估算芯片约 800 W、含 GDDR7 的模组约 880 W，二者对象不同，均非官方 TDP（热设计功耗）。[4, Bandwidth and Compute Difference；Nvidia Oberon Rack Architecture Upgrade] |
| 一致性与可靠性 | 远程访存、缓存一致性、纠错、故障隔离和降级机制未找到 CPX 专属说明。[1-3, 技术说明] | 系统网络与软件编排不作为芯片硬件机制的证据 |

以上第三方数据用于说明已有分析及其依据，不足以消除官方规格缺口。

## 6. 系统级互联上下文

发布时的方案由 CPX 处理上下文、Rubin GPU 与 Vera CPU 承担生成侧。系统可以结合 Quantum-X800 InfiniBand 或 Spectrum-X Ethernet，并使用 ConnectX-9 SuperNIC（网络适配器）；这些是上层系统配置，不证明网络接口集成在 CPX 裸片内。[1, 系统说明及 Advancements Offered by Rubin CPX] [3, 图1、图2及系统说明]

图示为生成侧 Rubin GPU 标出 NVLink 连接，但没有给出 CPX 自身完整的端点带宽表。独立 CPX 托盘也只是发布时的部署方案。整机架总算力、总显存容量及聚合带宽不换算成单 CPX 参数。[1, 开篇系统段] [3, 图2]

## 7. 尚未解决的规格与来源问题

| 问题 | 本轮核查与处理 |
|---|---|
| 官方专属规格不足 | 已补查官方型号/CC 对照和开发文档，仍没有 CPX 完整数据格式、寄存器/L1/shared/L2 容量及分层带宽。官方格式表存在，但缺少型号映射这一环，不能直接移用。[6, 型号表] [7, Table 31-33] |
| 发布稿与独立分析口径不同 | 官方给出 30 PFLOPS NVFP4；第三方将其解释为 sparse，并给出 dense 值、显存带宽、接口和功耗。两类证据分别列出，不混成一张“官方规格表”。[1, 单 GPU 规格段] [4, Bandwidth and Compute Difference] |
| 供应计划更新 | 2026 年 3 月的厂商负责人现场问答比 2025 年发布计划更新，采用“暂缓当年安排、下一代再考虑”的表述。逐字稿由媒体记录，出处性质明确标注。[5, CPX delay and LPU decode architecture] |
| 官方中文版本歧义 | 中文正文的“共同承担生成阶段”与同页图示及韩文正文不一致；采用一致的 context 定位和韩文对生成侧的明确说明。[2-3, CPX 专章及图1、图2] |
| 原文访问限制 | 英文技术博客返回 HTTP 404；官方发布演讲的实际播放器要求登录，字幕接口返回 HTTP 400，属于远端页面/服务限制。未把未看过的演讲或转载图片当作已核对的官方证据。访问入口和限制见[来源说明](../../../原始资料/网页快照/NVIDIA/RubinCPX/2026-09-27/来源说明.md) |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡采用内容 | 原文与本地文件 |
|---:|---|---|---|---|
| [1] | NVIDIA，NVIDIA Unveils Rubin CPX: A New Class of GPU Designed for Massive-Context Inference，2025-09-09 | 官方发布稿 | 单 GPU 峰值、显存、单计算裸片、视频硬件、初始计划 | [官网](https://nvidianews.nvidia.com/news/nvidia-unveils-rubin-cpx-a-new-class-of-gpu-designed-for-massive-context-inference)；[本地原文](../../../原始资料/网页快照/NVIDIA/RubinCPX/2026-09-27/nvidia-rubin-cpx-announcement-2025-09-09.html) |
| [2] | NVIDIA，NVIDIA Rubin CPX 加速百万级以上 token 上下文工作负载的推理性能和效率，2025-09-09 | 官方中文技术博客 | prefill 定位、阶段分工图与系统关系 | [官网](https://developer.nvidia.cn/blog/nvidia-rubin-cpx-accelerates-inference-performance-and-efficiency-for-1m-token-context-workloads/)；[本地原文](../../../原始资料/网页快照/NVIDIA/RubinCPX/2026-09-27/nvidia-rubin-cpx-technical-zh-2025-09-09.html) |
| [3] | NVIDIA，同题韩文技术博客，2025-09-25 | 官方技术博客另一语言版本 | 核对 CPX 与生成侧的关系，解决中文歧义 | [官网](https://developer.nvidia.com/ko-kr/blog/nvidia-rubin-cpx-accelerates-inference-performance-and-efficiency-for-1m-token-context-workloads/)；[本地原文](../../../原始资料/网页快照/NVIDIA/RubinCPX/2026-09-27/nvidia-rubin-cpx-technical-ko-2025-09-25.html) |
| [4] | SemiAnalysis，Another Giant Leap: The Rubin CPX Specialized Accelerator & Rack，2025-09-10 | 原始独立分析，非官方规格 | FP4 dense/sparse 口径、显存带宽假设、封装、接口与功耗估算 | [原文](https://newsletter.semianalysis.com/p/another-giant-leap-the-rubin-cpx-specialized-accelerator-rack)；[本地原文](../../../原始资料/网页快照/NVIDIA/RubinCPX/2026-09-27/semianalysis-rubin-cpx-analysis-2025-09-10.html) |
| [5] | Tom's Hardware，GTC 2026: Ian Buck press Q&A transcript，2026-03-23 | NVIDIA 负责人现场发言的媒体逐字稿 | CPX 暂缓及下一代再考虑的计划变化；不用于补猜芯片规格 | [原文](https://www.tomshardware.com/tech-industry/gc-2026-press-q-and-a-transcript)；[本地原文](../../../原始资料/网页快照/NVIDIA/RubinCPX/2026-09-27/ian-buck-gtc-qa-transcript-2026-03-23.html) |
| [6] | NVIDIA，CUDA GPU Compute Capability，访问于 2026-09-27 | 官方型号支持表 | 核查 CPX 未取得明确 CC 映射的限制 | [官网](https://developer.nvidia.com/cuda/gpus)；[本地快照](../../../原始资料/网页快照/NVIDIA/RubinCPX/2026-09-27/nvidia-cuda-gpu-compute-capability-2026-09-27.html) |
| [7] | NVIDIA，CUDA Programming Guide，5.1 Compute Capabilities，更新于 2026-09-10 | 官方开发文档 | 架构专属功能、寄存器与共享存储资源表、Tensor Core 输入类型表；不作为 CPX 参数表 | [官网](https://docs.nvidia.com/cuda/cuda-programming-guide/05-appendices/compute-capabilities.html)；[本地快照](../../../原始资料/网页快照/NVIDIA/RubinCPX/2026-09-27/nvidia-cuda-guide-compute-capabilities-2026-09-27.html) |

## 9. 完成检查

已核对单 GPU 与系统边界，保存上述原文，分别列出官方规格、独立分析和缺失项，并更新产品计划。原先仅根据发布资料便标为“已完成”过早，本卡恢复“调研中”。

尚未满足的核心要求是：取得可绑定 CPX 的完整数据格式与峰值表，以及片上存储组织、容量和每层带宽。当前资料能回答官方公布的最高算力和显存容量，不能声称已经回答全部基本架构问题。
