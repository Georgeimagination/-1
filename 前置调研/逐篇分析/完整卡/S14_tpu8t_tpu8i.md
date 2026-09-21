# S14｜TPU 8t 与 TPU 8i 技术深潜

## 1. 来源身份与固定版本

| 项目 | 记录 |
| --- | --- |
| 来源编号 | S14 |
| 题名 | 网页元数据题名为“TPU 8t and TPU 8i technical deep dive”；正文标题为“Inside the eighth-generation TPU: An architecture deep dive” |
| 作者与机构 | Diwakar Gupta（Distinguished Engineer, Google Cloud）、Sabastian Mugazambi（Group Product Manager, Google Cloud） |
| 发布日期 | 2026-04-22 |
| 来源类型 | Google Cloud 厂商技术博客 HTML；不是论文，也没有同行评审 |
| 固定版本 | 2026-04-22 页面；本地访问与固定日期为 2026-08-14 |
| 原始网址 | https://cloud.google.com/blog/products/compute/tpu-8t-and-tpu-8i-technical-deep-dive |
| 本地原文 | 原文/网页快照/S14_tpu8t_tpu8i.html |
| 规范化文本 | 原文/规范化文本/S14_tpu8t_tpu8i.txt |
| 固定图表 | 原文/图表/S14/ 下六幅 PNG；另有一张 HTML 规格表 |
| SHA-256 | 525847A04226828E32DB3E8F7C040322A2F384DAD3CC92690E03E5B9510988BF |
| 许可与访问限制 | 公开可访问的厂商动态网页，本地快照固定后可复核；页面未声明开放内容许可 |
| 定位体系 | 网页小节标题、Figure 1 至 Figure 6、规格表行名和段落开头；网页没有页码 |

本地 HTML 为 289,902 字节。规范化文本有 181 行，存在少量编码乱码和由响应式页面造成的重复段落；身份、规格表和图注均回到原始 HTML 核对，图中信息以本地 PNG 为准。

## 2. 实际阅读范围与筛选判断

已扫描完整 HTML 的标题、元数据、正文边界、六个 Figure 图注、唯一一张规格表、链接区和页尾；全文精读从“TPU 8: Specialized by design”到“Looking ahead”的全部正文，同时读完规范化文本，并逐幅视觉核对六张固定图。Related articles 和导航页尾只用于确认网页边界，不作为技术证据。没有未读的正文段落，也没有正式参考文献表。

| 判断项 | 结论 | 理由 |
| --- | --- | --- |
| 问题匹配 | pass | 同一代张量处理单元（Tensor Processing Unit，TPU）被明确分为面向大规模预训练的 TPU 8t 和面向采样、服务与推理的 TPU 8i，直接回答训练与推理需求怎样改变芯片、内存和互联。 |
| 方法与信息增益 | pass | 页面同时给出两颗产品的封装框图、HBM 与片上 SRAM 规格、计算峰值、3D 环面与 Boardfly 拓扑、直连存储路径和软件栈，是本语料中少见的同代专用化对照。 |
| 证据质量 | borderline | 架构图和规格表信息具体，但全部来自 Google 对自家产品的披露。性能、成本、能效和设计动机没有完整基准设置、原始数据、误差或模型质量结果。 |
| 可交叉验证性 | borderline | 固定 HTML、六图和规格表可以复核“Google 发布了什么”，却不能独立验证硬件实物或性能。文内 1,152 个已连接芯片与 1,024 个 active chips 的口径也没有解释。 |

范围相关性为“直接相关”，领域角色是“重要的厂商一手产品披露”。证据成熟度只能记为厂商架构披露与内部性能宣称，不能升级成独立实测或跨团队验证。对页面内容的读取判断置信度高；对硬件实际效果和相对优势的判断置信度中低。

## 3. 两类 TPU 的工作负载、目标与机制

这篇文章展示了 Google 如何在共享 TensorCore、HBM、主机接口和软件栈的前提下，把第八代 TPU 分别向训练吞吐与推理状态容量、集合通信时延倾斜，因此它支持“同代架构按工作负载重新配比”，不支持训练芯片与推理芯片绝对割裂。

[厂商设计意图] Google 把大规模预训练和嵌入密集负载的主要压力概括为持续供给矩阵计算、处理不规则嵌入访问、同步大量芯片并按计划完成训练。TPU 8t 因而采用更高的 FP4 峰值、SparseCore、向量处理单元（Vector Processing Unit，VPU）与矩阵乘法单元（Matrix Multiply Unit，MXU）的重叠执行、3D 环面片间互联、Virgo 扩展网络以及绕过主机的存储路径。原文形成的因果链是：大规模预训练与嵌入访问增加计算、集合通信和数据摄取压力 → 系统目标偏向总吞吐、利用率和跨集群扩展 → 芯片保留 SparseCore 并提高 FP4 计算，系统侧扩大 ICI、数据中心网络和存储直达能力。

[厂商设计意图] Google 把后训练、采样、长上下文自回归解码和混合专家模型（Mixture of Experts，MoE）的主要压力概括为更大的键值缓存（KV cache）、频繁归约与同步，以及跨芯片全互联通信。TPU 8i 因而增加高带宽内存（High Bandwidth Memory，HBM）和片上静态随机存储器（SRAM），加入集合通信加速引擎（Collectives Acceleration Engine，CAE），并以 Boardfly 降低网络直径。对应因果链是：解码状态和 MoE 路由增加容量、带宽与全互联时延压力 → 系统目标偏向低时延、高并发和尾延迟 → 芯片增加 Vmem 与 CAE，网络从大规模 3D 环面转向分层高基数 Boardfly。

[原文事实][单源观察] 规格表给 TPU 8t 与 TPU 8i 的峰值 4 位浮点（FP4）性能分别为 12.6 和 10.1 PFLOPS，HBM 容量分别为 216 GB 和 288 GB，HBM 带宽分别为 6,528 GB/s 和 8,601 GB/s，Vmem 分别为 128 MB 和 384 MB。PFLOPS 表示每秒 $10^{15}$ 次浮点运算。页面没有说明峰值是稠密还是稀疏、乘加计数方式、累加精度、频率或功耗点，规格也没有独立验证。

[原文事实] 两种系统都被 Google 描述为支持完整 AI 生命周期，并共享 JAX、PyTorch、Keras、Accelerated Linear Algebra（XLA）和其他 AI Hypercomputer 组件。两者的“primary workload”是优先优化方向，不是排他性的能力边界。

## 4. 图表过账与视觉核对

网页有六幅编号图和一张规格表。固定图文件名中的主题词与实际图号并不完全一致，以下按图内内容过账。

| 图表与本地文件 | 视觉内容 | 与课题关系 | 支持范围、条件与限制 | 视觉核对状态 |
| --- | --- | --- | --- | --- |
| Figure 1；F01_TPU8_Specialization.png | TPU 8t 封装框图：一个 TensorCore 逻辑区域、两个 SparseCore、VPU/Vmem、两个 MXU、六组 HBM3E 控制器与堆栈、PCIe、管理模块和 ICI/SerDes 芯粒 | 高 | [原文事实] 支持组件存在及连接关系。图中没有容量、带宽、频率、功耗或面积标尺。 | 已逐项核对图例、模块名、箭头、六组 HBM 和封装边界。方框面积不得用于推算资源或芯片面积占比。 |
| Figure 2；F02_TPU8t_Rack_Connectivity.png | TPU 8t 机架经 ICI/SPOCS 接入两层、全非阻塞、多独立平面的 Virgo，旁接 Jupiter 的 Apollo 光路交换与聚合块，并可扩到跨数据中心 WAN | 高 | [原文事实] 支持 Virgo、Jupiter 和多平面层级关系；图本身没有 47 Pb/s、134,000 芯片或 4 倍带宽数值。 | 已核对两层交换、独立平面、机架、Jupiter 和 WAN 标注。 |
| Figure 3；F03_TPU8t_Boardfly.png | 实际内容是 TPUDirect，而不是 Boardfly：上半图的数据从 TPU HBM 经主机和 NIC 转发，下半图显示 HBM 到 NIC 的 RDMA 路径及到 Managed 10T Lustre 的存储路径 | 高 | [厂商设计意图] 支持“绕过主机 CPU/DRAM”的路径差异；示意中的五步与三步不能证明“带宽翻倍”或“存储访问快 10 倍”。 | 已核对 Without TPUDirect、TPUDirect RDMA、TPUDirect Storage 三部分及编号路径。 |
| Figure 4；F04_TPU8i_Torus.png | 实际内容是 TPU 8i 封装框图：两个 TensorCore 区域、每区 VPU/Vmem 与两个 MXU、八组 HBM 堆栈、共享 ICI/SerDes 芯粒内的 SC-CAE、PCIe 和管理模块 | 高 | [原文事实] 支持双 TensorCore 与 CAE 芯粒关系。控制器写作 HBM3 Ctrl，堆栈写作 HBM3E stack，正文未解释这一标注差异。 | 已核对两个 TensorCore、八组 HBM、SC-CAE 和封装边界。仍不得由方框面积推算资源比例。 |
| Figure 5；F05_TPU8_Performance.png | 实际内容是 Boardfly 层级：每个 building block 为 4 个全连接 TPU；8 个 building block 构成全连接 group；36 个 group 再全连接 | 高 | [原文事实] 支持 4×8×36 的层级组织。乘积为 1,152 个位置，与正文“up to 1,024 active chips”并列存在，不能自行解释为备用芯片。 | 已核对 4 芯片、8 个 BB 和 36 个 group；图中没有性能曲线。 |
| Figure 6；F06_TPU8_Cost_Efficiency.png | 实际内容是 Boardfly 最远通信路径：从 Group N 经组内连接、光路交换机（Optical Circuit Switch，OCS）到 Group M，共标出 1 至 7 跳 | 高 | [原文事实] 支持作者给出的最大七跳路径示例；不包含尾延迟、带宽或拥塞实测，不能由跳数直接算出时延。 | 已核对起点、终点、OCS 和七个编号跳。 |
| “TPU 8t and TPU 8i at a glance” HTML 表 | 工作负载、网络、专用特性、HBM、Vmem、FP4 峰值、HBM 带宽和 Axion CPU header | 高 | [原文事实][单源观察] 数值可从固定 HTML 逐格复核，仍只是 Google 厂商规格。CPU header 属系统主机配置，不能当作 TPU 裸片内部单元。 | 已核对 8 行、3 列及 16 个产品单元；规范化文本的重复布局不影响原始表格取值。 |

六幅图只证明网页公开的框图和拓扑表达。它们没有晶体管、模块面积、链路负载、持续带宽或功耗测量，任何性能归因都需要正文主张和额外实测，不能从视觉面积或连线数量推出。

## 5. 训练与推理差异维度

| 维度 | 本来源提取结果、证据标签与网页定位 |
| --- | --- |
| 执行阶段与状态 | [厂商设计意图] TPU 8t 面向大规模预训练与嵌入密集负载；TPU 8i 面向后训练、采样、服务和推理，正文具体提到长上下文自回归解码、KV cache 与 chain-of-thought 处理（“TPU 8t: The pre-training powerhouse”“TPU 8i: The sampling and serving specialist”）。[未覆盖] 训练前向/反向、梯度、优化器状态、保存激活，推理预填充、前缀缓存、批量与并发状态的字节量。 |
| 优化目标 | [厂商设计意图] 8t 强调训练总吞吐、按期完成和跨 superpod 扩展；8i 强调高并发、低通信时延和尾延迟。代际段落给 performance/\$ 与 performance/W 主张。[未覆盖] 训练完成时间、首词延迟、逐词延迟、尾延迟分位数、并发数和服务等级目标。 |
| 数值与累加 | [原文事实] 8t 引入原生 FP4；规格表同时给两颗芯片的 FP4 峰值。Google 称 FP4 可让 8t 的 MXU 吞吐翻倍并维持大模型准确度。[未覆盖] 输入、乘积、累加与输出精度，舍入模式，稠密/稀疏计数以及准确度实验。SparseCore 是嵌入与不规则访问单元，不能据名称推断算术稀疏峰值。 |
| 计算单元与数据流 | [原文事实] F01 中 8t 的 TensorCore 含 VPU/Vmem、MXU、TCS 和 XLU，并另有两个 SparseCore；正文称 VPU 可把量化、softmax、layer norm 与 MXU 矩阵计算重叠。F04 中 8i 有两个 TensorCore 区域和共享 CAE，正文称 CAE 加速归约与同步。[未覆盖] 阵列形状、时钟、流水线、片上数据复用量和持续利用率。 |
| 片上存储 | [原文事实][单源观察] 表中 Vmem 为 8t 128 MB、8i 384 MB；Google 称 8i 较上一代增加 3 倍片上 SRAM，可把更大的 KV cache 留在芯片上（规格表、“Large on-chip SRAM”）。[未覆盖] 容量在两个 TensorCore 间的划分、缓存层次、端口和带宽，亦不能据此断言任意模型的完整 KV cache 都能驻留片上。 |
| HBM 与片外存储 | [原文事实][单源观察] 8t 为 216 GB、6,528 GB/s，8i 为 288 GB、8,601 GB/s；图中均画 HBM3E stack。8t 另有 TPUDirect RDMA 和 TPUDirect Storage，按厂商描述可绕过主机 CPU/DRAM（规格表、F03）。[未覆盖] 有效带宽、访问粒度、权重/KV/激活流量、HBM 功耗和并发条件。 |
| 存算配比 | [分析者推断] 以表中峰值作分子、HBM 带宽作分母，并把 GB/s 按十进制字节换算，8t 的 $12.6\times10^{15}/(6528\times10^9)\approx1930$ FP4 FLOP/B，8i 的 $10.1\times10^{15}/(8601\times10^9)\approx1174$ FP4 FLOP/B。8i 的公开峰值因此呈现更低的计算/带宽配比；这只是峰值机器平衡代理，不能替代实际算术强度、持续带宽或 roofline 测量。 |
| 互联与通信 | [厂商设计意图] 8t 在单个 9,600 芯片 superpod 使用 3D 环面，片间互联（Inter-Chip Interconnect，ICI）带宽据称为上一代 2 倍，并由 Virgo 负责跨机架扩展；8i 用 Boardfly 处理 MoE 与推理的全互联通信，CAE 处理片上归约和同步（F02、F05、F06、“Boardfly vs. torus math”）。训练同步算法和推理通信流量均[未覆盖]。 |
| 调度与服务质量 | [厂商设计意图] 8i 的目标包括高并发和较低尾延迟，Boardfly 被描述为减少全互联跳数。[未覆盖] 连续/动态批处理、请求调度、隔离、抢占、服务质量（Quality of Service，QoS）、排队和尾延迟数据。 |
| 功耗与部署 | [原文事实] 两者是 Google Cloud AI Hypercomputer 的云端系统，文章涉及封装、机架、superpod、跨数据中心网络和 Axion 主机。Google 宣称两颗芯片相对 Ironwood 的 performance/W 最高提高 2 倍。[未覆盖] 芯片或系统瓦数、散热、机架功率、测量边界和可用区域。 |
| 软件栈 | [原文事实] Pallas 是用 Python 编写硬件感知内核的接口，配合 Mosaic；PyTorch 原生支持处于 preview，包含 Eager Mode。JAX、PyTorch、Keras 代码可从 Ironwood 迁移，XLA 处理 Boardfly 拓扑与 CAE 同步；Pathways 用于超大规模训练，结尾还列出 vLLM（“Software enablement”“Looking ahead”）。软件版本、算子覆盖、编译开销和端到端性能拆分均[未覆盖]。 |
| LLM 专项 | [厂商设计意图] 8t 针对预训练、embedding 与 FP4；8i 针对采样、自回归解码、长上下文 KV cache、MoE 路由和推理链同步。规格表还给 8t 列出 LLM Decoder Engine，但正文没有解释其结构。[未覆盖] 预填充、上下文长度、KV cache 容量需求、模型参数、专家数、batch、投机解码和量化质量。 |

## 6. 关键数字与证据链

### 6.1 芯片与系统规格

| 候选事实 | 原值、单位与条件 | 对象层级与性质 | 证据链与限制 |
| --- | --- | --- | --- |
| FP4 峰值 | 8t 12.6 PFLOPS；8i 10.1 PFLOPS | 网页按 TPU 产品列示；规格表 | [原文事实][单源观察] 峰值口径，精确芯粒/封装边界未单独定义。没有稠密/稀疏、乘加计数、频率、功耗点和持续结果。 |
| HBM | 8t 216 GB、6,528 GB/s；8i 288 GB、8,601 GB/s | TPU 封装/产品；规格表、F01、F04 | [原文事实][单源观察] 8i 相对 8t 的容量为 1.33 倍、带宽为 1.32 倍，这是从同表计算的比例。没有有效带宽或工作负载。 |
| 片上 Vmem | 8t 128 MB；8i 384 MB | TPU 产品；规格表 | [原文事实][单源观察] 8i 为 3 倍。Google 将它与更大 KV cache 驻留相连，但没有给可容纳的模型、序列长度、batch 或 KV 精度。 |
| 8t superpod | 单个 superpod 9,600 颗 8t | 系统规模；“TPU 8t”小节 | [原文事实][单源观察] 原文没有拓扑维度、有效芯片数、作业规模、可用性或扩展效率曲线。 |
| 8i Boardfly | 最多连接 1,152 颗；36 个 group、最多 1,024 个 active chips；最大 7 跳 | pod 与互联；F05、F06、Boardfly 小节 | [原文事实][单源观察] 4×8×36 对应 1,152 个位置，但 128 颗差异没有说明；不能自行归为冗余。 |

规格表把 CPU Header 写为两者都使用 Arm Axion。该项属于系统主机，不应与 TPU 封装内计算、HBM 或 ICI 参数混在同一对象层级。

### 6.2 网络、存储与性能宣称

| Google 的主张 | 原值与网页定位 | 支持材料 | 缺失条件与可用边界 |
| --- | --- | --- | --- |
| 8t ICI 与数据中心网络提升 | ICI scale-up 带宽 2 倍；原始 scale-out DCN 带宽最高 4 倍，均相对上一代（“Virgo Network”） | F02 只给层级与连接示意 | [单源观察] 没有链路速率、单/双向口径、负载、拓扑规模或基准，因此只能记录厂商代际宣称。 |
| Virgo 规模 | 超过 134,000 颗 8t、最高 47 Pb/s 非阻塞双剖带宽、超过 1.7K ExaFLOPS；JAX 与 Pathways 被称可扩到超过 100 万 TPU 的单个训练集群 | 正文陈述，无曲线或原始数据 | [单源观察] “近线性扩展”没有模型、并行策略、有效芯片数和效率数值；不同规模与对象不能合并成单芯片性能。 |
| TPUDirect | Direct Storage 据称使大规模传输带宽翻倍；配合 Managed Lustre 10T，相对 Ironwood 训练的存储访问最高快 10 倍 | F03 只显示绕过主机的路径 | [单源观察] 没有数据集、文件大小、读写方向、缓存状态、吞吐或时延值。示意图不能独立支撑倍数。 |
| CAE 与 Boardfly | CAE 据称把片上 collective 时延降低 5 倍；Boardfly 对通信密集负载时延最高改善 50%；同规模网络直径由 16 跳降到 7 跳，即 56% | F04、F05、F06 与 $8/2+8/2+16/2=16$ 的环面算式 | [单源观察] 16 对 7 是拓扑直径，不等于 56% 端到端时延；50% 的负载、分位数、消息大小、拥塞和基线均未给出。 |
| 代际 performance/\$ | 8t 大规模训练相对 Ironwood 最高 2.7 倍；8i 对低时延大型 MoE 推理相对 Ironwood 最高改善 80% | “Generation over generation”文字 | [单源观察] 没有模型、精度、batch、上下文、延迟目标、价格、地区、软件版本、运行次数或原始数据，不能归因某一硬件部件。 |
| 代际 performance/W | 两颗芯片相对 Ironwood 最高 2 倍 | 同上，仅文字 | [单源观察] 没有功耗边界、测量点、冷却、工作负载和系统组成，不能当作独立能效结果。 |

关键主张的证据结构如下。

1. 专用化主张有规格表、封装框图和拓扑图相互对应：8t 的 FP4 峰值更高并保留 SparseCore，8i 的 HBM、Vmem 与 CAE 更强，网络目标也不同。证据足以证明 Google 公开了这套设计取舍；没有芯片测量或受控消融，不能证明每个部件带来了多少收益。
2. Boardfly 的七跳上限有拓扑算式和 F05/F06 支持。50% 通信时延改善与“56% 网络直径下降”是不同指标，后者不能替代前者的基准数据。
3. TPUDirect 的主机绕行差异在 F03 中清楚可见。带宽翻倍和存储访问快 10 倍只有厂商文字，没有绝对值与测试条件。
4. 2.7 倍训练 performance/\$、80% 推理 performance/\$和 2 倍 performance/W 均是 Google 对第八代系统相对 Ironwood 的上限宣称。页面没有可复算分子、分母或置信区间，因此不进入独立性能结论。

## 7. 跨图表推理与反例

[分析者推断] 规格表和 F01/F04 合看，8i 相对 8t 的 FP4 峰值约为 0.80 倍，但 HBM 容量约为 1.33 倍、HBM 带宽约为 1.32 倍，Vmem 为 3 倍；再结合 CAE 与 Boardfly，可以把 8i 理解为把公开资源配比从峰值矩阵计算向状态驻留和通信时延移动。替代解释是两颗产品的频率、功耗、稠密/稀疏口径或芯粒边界可能不同，而页面没有披露，故该判断只描述公开峰值的相对形状。

[分析者推断] 8t 的 3D 环面服务邻近通信和大规模规则训练，8i 的 Boardfly 缩短全互联路径，显示网络专用化发生在通信模式层面，而不只是链路带宽层面。F06 只能证明作者选择了七跳上限的结构，实际尾延迟还会受消息大小、路由、争用、OCS 配置与软件调度影响。

[原文事实] 两颗产品都支持完整 AI 生命周期，共享 TensorCore、HBM、Axion 主机和同一软件生态；8t 的规格表甚至列有 LLM Decoder Engine，8i 也保留 10.1 PFLOPS 的 FP4 计算。这是训练/推理绝对二分的反例。来源更适合支持“主优化点不同”，不能支持“8t 不能推理”或“8i 不能训练”。

[分析者推断] F05 的 4×8×36 层级与“up to 1,152 chips”一致，但正文又称“up to 1,024 active chips”。128 颗差值可能来自实现中的非 active 位置，也可能是口径或版本差异；原文没有说明，必须保留为未解决项。

所有封装框图都使用功能方框，没有面积比例、版图、工艺或晶体管数据。方框面积和数量只能说明示意结构，不能推算计算、存储、互联或管理逻辑的资源占比。

## 8. 适用时代、工作负载与缺失项

本文属于 2026 年云端现代大语言模型、MoE、长上下文推理、强化学习后训练和世界模型语境。8t 的对象是大规模预训练、embedding 和跨 superpod 训练；8i 的对象是采样、服务、推理链和高并发全互联通信。可迁移的认识是：训练侧更重视持续计算、数据摄取和规则的大规模同步，推理侧更容易受状态容量、内存带宽、集合操作和全互联时延约束。具体峰值、规模、倍数和拓扑只能用于 Google TPU 8 产品披露。

这不是芯片论文或第三方评测。页面没有工艺、晶体管数、裸片面积、频率、芯片/封装功耗、散热、良率和可用区域；没有持续算力、有效 HBM 带宽、链路速率、网络拥塞、训练时间、模型质量、首词/逐词/尾延迟、并发数、batch、上下文长度、模型参数、专家数、KV 精度、运行次数或误差。FP4 的乘积、累加和输出精度，以及峰值的稠密/稀疏口径均未披露。

软件侧没有版本号、编译时间、算子覆盖、kernel 配置、框架性能差异或可复现实验。商业侧没有价格、地区、合约和 performance/\$ 计算式。页面结尾仍引导提交 interest form，具体供货和访问状态未说明。由于原页是动态厂商网页，后续内容可能变化；本卡只对应已固定的 2026-04-22 页面快照。

全部规格、性能倍数、设计动机和“效率”表述都来自 Google。视觉核对只确认固定页面中的图、表和值，没有提供独立验证。

## 9. 对最终报告的贡献

| 候选结论 | 标签与定位 | 适用条件 | 独立工作家族 |
| --- | --- | --- | --- |
| Google 在同一 TPU 世代内把 8t 的主目标设为大规模预训练，把 8i 的主目标设为采样、服务和推理，并分别调整计算、存储和互联。 | [厂商设计意图] “Specialized by design”、规格表 | 仅代表 Google 的产品定位，不是跨厂商共识。 | WF-GOOGLE-TPU8-SPLIT |
| 公开峰值显示 8i 相比 8t 减少 FP4 算力、增加 HBM/Vmem，并加入 CAE，呈现向状态容量和集合通信倾斜的资源配比。 | [分析者推断] 规格表、F01、F04 | 基于厂商峰值；缺持续性能、功耗和口径细节。 | WF-GOOGLE-TPU8-SPLIT |
| 8t 的 3D 环面与 Virgo 面向规则的大规模扩展；8i 的 Boardfly 把 1,024 芯片示例的网络直径从 16 跳降到 7 跳，面向 MoE 全互联。 | [厂商设计意图] F02、F05、F06、“Boardfly vs. torus math” | 跳数可核对，时延和扩展收益没有独立基准。 | WF-GOOGLE-TPU8-SPLIT |
| Pallas/Mosaic、JAX、PyTorch、Keras、XLA 与 Pathways 是硬件专用化的配套条件，软件栈不能从性能归因中剥离。 | [原文事实] “Software enablement” | 页面只给能力与可移植性描述，没有软件消融。 | WF-GOOGLE-TPU8-SPLIT |
| 两者共享核心计算与软件栈并支持完整生命周期，训练型与推理型是相对优化方向，不是互斥类别。 | [原文事实] “Specialized by design”“Looking ahead” | 说明统一基础仍存在，不证明任一方案在所有阶段最优。 | WF-GOOGLE-TPU8-SPLIT |

S14 的主要信息是 Google 公开了同代产品的两种资源配比：8t 把重点放在峰值计算、嵌入处理、数据摄取和跨集群扩展，8i 把重点放在 HBM/Vmem、片上集合操作和低直径全互联。六幅图和规格表能支撑这种结构对照；2.7 倍、80%、2 倍、50%、10 倍等数字都缺少可复现条件。最终报告可以用它说明训练与推理的专用化方向，同时必须写明这是 Google 单源厂商披露，而且两颗 TPU 仍共享核心计算与软件栈。
