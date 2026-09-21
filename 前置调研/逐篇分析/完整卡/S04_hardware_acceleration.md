# S04 完整阅读卡：Hardware Acceleration

## 1. 来源身份与固定版本

- 来源编号：S04
- 题名：*Introduction to Machine Learning Systems: Hardware Acceleration*（页面章标题为 “Hardware Acceleration”，快照首页同时出现 “Acceleration Fundamentals”）
- 作者或机构：Harvard Edge / *Introduction to Machine Learning Systems* 项目；本地快照没有给出本章个人署名
- 来源类型：在线教材 HTML，二手综合性教学资料，不是原始芯片论文或产品规格书
- 固定版本：Volume I v0.7.1；清单登记发布日期为 2026-07-27，访问并固定于 2026-08-14
- 原始网址：https://harvard-edge.github.io/cs249r_book_dev/vol1/hw_acceleration/hw_acceleration.html
- 本地原文：`原文/网页快照/S04_hardware_acceleration.html`
- 规范化文本：`原文/规范化文本/S04_hardware_acceleration.txt`
- SHA-256：`7EAE727D054CC6EBA448BE0F1F02E9BDC2B160CC0F67C71BDFC08C124F18E673`
- 文件大小：885,913 字节
- 许可与访问：页面页脚声明 CC BY-NC-SA 4.0；网页可公开访问，但这是持续更新的开发版，后续页面可能与本快照不同
- 定位体系：网页没有稳定页码，本卡以章、节、图号、表号、Napkin Math 编号和段落开头定位。教材中的芯片数值、价格与算例只按教学示例使用，不当作具体产品规格证据。

## 2. 实际阅读范围与筛选判断

本卡扫描了从 Purpose、Hardware Specialization 到 Summary、Self-Check Answers 和参考文献的完整页面，核对了全部 14 幅编号图、24 张编号表及三幅专题固定图。精读范围为 “Machine learning hardware specialization”、数值格式、片内互联、AI Memory Systems、Roofline Model、数据流与映射、编译器、运行时和 Multi-Chip Scaling。自测题和答案只用于确认作者边界，不作为独立证据；参考文献只核对引用归属，没有逐篇外扩阅读。网页没有“未读章节”，但未对正文中与课题关系很弱的硬件史、移动 SoC 和可持续性练习逐句摘录。

| 筛选维度 | 结论 | 理由 |
|---|---|---|
| 问题匹配 | pass | 直接比较训练与推理的状态、精度、吞吐/延迟目标，并区分 LLM 训练、预填充和低批量解码。 |
| 方法与信息增益 | pass | 用 Roofline（屋顶线模型）、内存层级和数据流把“工作负载差异—系统目标—架构后果”连起来，适合作为综合报告的分析骨架。 |
| 证据质量 | borderline | 教材引用较多原始论文，但正文也包含近似值、教学算例、混合精度口径和作者概括；动态开发版不适合作为产品定值的唯一证据。 |
| 可交叉验证性 | pass | 关键机制附有论文引用和稳定的小节、图表或算例定位；但所有定量规格仍需回到原始论文或厂商文档复核。 |

本来源在研究中的角色是“机制型二手综合资料”：适合解释为什么训练、预填充和解码落在不同的算力/带宽区间，不适合替代芯片规格书或独立实测。

## 3. 一句话定位、作者主张与机制

一句话定位：这章最有价值的地方不是给训练芯片和推理芯片各列一张规格表，而是用工作负载状态、数值精度、算术强度和通信边界解释二者为什么会形成有条件的架构倾向。

[原文事实] 作者明确把训练描述为包含反向传播、梯度与权重更新、需要保存激活的双向数据流，并把其系统目标概括为大批量吞吐和训练完成时间；作者把推理描述为前向执行，可使用 INT8/INT4，且延迟敏感。定位：“Machine learning hardware specialization”，脚注 12 “Latency vs. Throughput in Accelerator Design”及其后段落。

[原文事实] 对现代 Transformer，作者进一步区分阶段：训练和预填充中的大矩阵乘法可以是计算受限，低批量自回归解码则常由权重和键值缓存（KV cache）带宽限制。定位：“Applying mapping strategies to neural networks”→“Transformer architectures (GPT-2/Llama)”。这比简单的“训练算力、推理带宽”二分更准确，因为相同模型在不同阶段可以跨越 Roofline 的脊点。

[原文事实] 作者的核心分析工具是 Roofline：可达性能为

$$
R_{\text{attain}}=\min(R_{\text{peak}},\mathrm{BW}\times I),
$$

其中算术强度 $I=O/D_{\text{vol}}$，单位为 FLOP/byte；机器平衡点或脊点为 $I_{\text{ridge}}=R_{\text{peak}}/\mathrm{BW}$。定位：“Roofline Model”，公式 2、3 与 “Hardware ridge points”。

由此可形成两条作者支持的因果链：

训练需要前向、反向、梯度同步并保存激活 → 系统追求训练完成时间和聚合吞吐，通常用较大批量提高复用 → 架构偏向宽浮点/混合精度矩阵通路、较大的高速存储、较高 HBM 带宽及强节点内外互联，并以计算—通信重叠减轻 AllReduce 暴露时间。

低批量自回归解码每步只生成一个或少量 token，反复读取权重并访问随序列增长的 KV cache → 系统受逐请求延迟、内存带宽、容量和能效约束 → 架构和运行时更重视低比特权重、有效带宽、片上分块、融合和动态批处理，而不是只增加峰值 FLOP/s。

这两条链都不是绝对分类。[分析者推断] 同一套通用加速器可通过不同精度、数据流、内核和批量同时服务训练与推理；作者的 “Hybrid mapping strategies” 也明确说没有一种固定数据流适合所有层。因此“训练芯片/推理芯片”更接近设计重心，而不是互斥的指令集类别。

## 4. 图表过账

下表覆盖正文全部编号图表。除明确写出“本地视觉核对”的三幅专题图外，其余项目按 HTML 正文、caption 或表格内容过账，没有把 caption 中的近似值升级为独立实测。

| 图表 | 主题与课题关系 | 支持的断言、条件与边界 | 核对状态 |
|---|---|---|---|
| Figure 1 | Amdahl 热力图；相关 | 硬件加速只有在可并行比例足够高时才转化为端到端收益，适用于训练流水和解码串行开销分析。 | HTML caption 与正文过账；未单独渲染。 |
| Figure 2 | 硬件专用化时间线；背景 | 说明专用化是对长期瓶颈的响应，不直接证明训练/推理差异。 | HTML caption 过账。 |
| Figure 3 | 模型需求与硬件供给的“系统缺口”；背景 | 只能说明协同设计动机；曲线为归一化趋势，不是芯片横评。 | HTML caption 过账。 |
| Figure 4 | 通用计算与专用计算 S 曲线；背景 | 支持“效率换灵活性”的设计权衡，不给出训练/推理定量边界。 | HTML caption 过账。 |
| Table 1 | 各时代硬件专用化趋势；背景 | 说明领域专用硬件随稳定工作负载出现。 | HTML 表格过账。 |
| Figure 5 | 现代 AI 加速器组成；高相关 | 矩阵、向量、专用单元必须由分层存储和互联持续供数。 | HTML caption 过账。 |
| Table 2 | 向量运算与 ML 原语；相关 | 归约、gather/scatter、掩码使向量单元在训练梯度、嵌入和注意力中仍不可少。 | HTML 表格过账。 |
| Table 3 | 矩阵单元与向量单元分工；相关 | 矩阵引擎不覆盖归一化、激活和归约，峰值矩阵吞吐不能代表端到端性能。 | HTML 表格过账。 |
| Table 4 | 特殊函数单元；弱相关 | 非线性函数的硬件成本不同；延迟只是代表性设计目标。 | HTML 表格过账。 |
| Figure 6 | GPU 宣称峰值吞吐演进；相关但高风险 | 混合了 FP32、FP16、INT8、FP8、FP4 和稀疏口径，只能说明低精度/稀疏支持演进，不能作同精度跨代比较。 | HTML caption 过账。 |
| Figure 7 | 稀疏存储格式；相关 | 结构化稀疏减少索引和不规则访问；未直接区分训练与推理。 | HTML caption 过账。 |
| Figure 8 | 脉动阵列数据流；高相关 | 操作数在处理单元间复用，减少外存访问，但密集规则形状受益最大。 | HTML caption 与正文过账。 |
| Table 5 | 脉动阵列 stationary 数据流；高相关 | 不同复用对象对应不同层，支持数据流应按工作负载选。 | HTML 表格过账。 |
| Table 6 | GPU 数值格式演进；高相关 | 训练常用 FP16/BF16 配 FP32 累加，推理更常用 INT8/INT4；表格只覆盖若干架构代际。 | HTML 表格过账。 |
| Table 7 | A100、TPUv4、Sapphire Rapids、移动 NPU 配置；直接相关 | 作者用训练浮点吞吐、推理低精度和移动能效说明设计重心不同；是教学性概括，不是完整产品横评。 | HTML 表格过账。 |
| Table 8 | 加速器价格、峰值与带宽；相关但高风险 | 行间精度和价格口径不同，作者也明确说不可作同精度比较；只保留“持续性能和带宽/成本更重要”的机制。 | HTML 表格过账。 |
| Figure 9 | 能耗层级；高相关 | 外存访问的能耗远高于片上访问和算术，支持所有架构都要减少搬运。数值来自历史 “Horowitz Numbers”。 | 对应本地 `F01_Energy_Ladder.svg`，已转为位图视觉核对；图示 DRAM 640 pJ、FP32 multiply 3.7 pJ、SRAM 0.5 pJ，纵向为对数尺度。 |
| Figure 10 | 计算吞吐与内存带宽增速分化；相关 | 曲线为示意性归一化趋势，不能用于求具体代际增幅。 | HTML caption 过账。 |
| Figure 11 | 硬件脊点上升；高相关 | 当 $P_{\text{peak}}/B_{\text{HBM}}$ 上升，低复用解码更难利用峰值算力；精度和 SKU 改变脊点。 | HTML caption 过账。 |
| Figure 12 | 模型参数增长与硬件带宽增长；相关 | 归一化公开数据说明容量/带宽压力；作者明确没有把未公开模型参数当事实点。 | HTML caption 过账。 |
| Table 9 | 传统负载与 ML 访存；相关 | 稀疏、嵌入、可变长度与路由可能降低局部性，但密集 GEMM 本身仍规则。 | HTML 表格过账。 |
| Table 10 | 寄存器、SRAM、HBM/DRAM、主存和存储层级；高相关 | 容量、延迟、带宽和能耗随层级变化；数值是数量级，不是单一芯片规格。 | HTML 表格过账。 |
| Figure 13 | 主机—加速器数据传输；相关 | 主机拷贝、命令发射、执行、结果回传都可能成为端到端瓶颈；统一内存和直接 I/O 可走不同路径。 | HTML caption 过账。 |
| Table 11 | MLP、CNN、Transformer 内存压力；高相关 | Transformer 同时受大权重、KV cache 和注意力流量影响；MoE/剪枝再带来路由和稀疏性。 | HTML 表格过账。 |
| Table 12 | 不同代际脊点范围；高相关 | 只给数量级，实际值取决于精度和 SKU。 | HTML 表格过账。 |
| Table 13 | 常见算子在 Roofline 上的位置；高相关 | 大批 GEMM/卷积可计算受限，低批 dense、LayerNorm、softmax、embedding 常带宽受限。 | HTML 表格过账。 |
| Table 14 | 按算术强度选择优化；高相关 | 高强度追算力利用率，低强度追融合、低精度和减少往返；速度倍数为教学预期，不能外推。 | HTML 表格过账。 |
| Table 15 | 计算放置挑战；相关 | 负载均衡、数据搬运和硬件约束共同决定利用率。 | HTML 表格过账。 |
| Table 16 | 内存分配挑战；相关 | Transformer 和图网络的动态形状/大状态使容量、带宽和碎片更重要。 | HTML 表格过账。 |
| Table 17 | 放置、分配、调度三者耦合；相关 | 支持架构和软件栈必须共同管理利用率与能耗。 | HTML 表格过账。 |
| Table 18 | NHWC/NCHW 布局；相关 | 最优布局取决于后端、算子和精度，不存在通用的训练/推理布局。 | HTML 表格过账。 |
| Table 19 | 中间张量存储；相关 | 4 个 $1024\times1024$ FP32 张量共 16.8 MB 是特定示例；运行时复用可改变峰值占用。 | HTML 表格过账。 |
| Table 20 | 三个点算子融合；高相关 | 特定推理示例将外部张量流量从 25.2 MB 降至 8.4 MB；真实收益受缓存、寄存器和占用率限制。 | HTML 表格过账。 |
| Figure 14 | 矩阵分块；高相关 | 通过片上复用提高算术强度，训练、预填充和批量推理均可用。 | HTML caption 过账。 |
| Table 21 | 空间、时间、混合分块；相关 | 映射策略是硬件与编译器联合选择，不对应固定“训练/推理”标签。 | HTML 表格过账。 |
| Table 22 | CNN、Transformer、MLP 映射策略；高相关 | 直接指出 Transformer 的训练/预填充与解码受限点不同，并支持按层混合映射。 | HTML 表格过账。 |
| Table 23 | ML 编译器优化重点；相关 | 图融合、内存规划和硬件特定内核选择决定实际利用率。 | HTML 表格过账。 |
| Table 24 | ML 运行时执行模型；相关 | 批量、形状、内存与资源状态需要运行时管理，尤其影响服务延迟。 | HTML 表格过账。 |
| `F01_Energy_Ladder.svg` | 能耗阶梯；高相关 | 视觉确认 DRAM、FP32 乘法、SRAM 的数量级差；只代表引用年代与条件。 | 已视觉核对；与 Figure 9 的机制一致。 |
| `F02_Bandwidth_Ladder.svg` | HBM—NVLink—PCIe—网络带宽阶梯；高相关 | 只显示相对顺序和对数尺度，没有刻度，不可从柱长反推带宽。 | 已视觉核对；四级依次降低。 |
| `F03_Roofline_Elbow.svg` | Roofline 拐点示意；高相关 | 视觉确认斜率区、计算平台和虚线脊点；没有轴标签和数值，只能解释机制。 | 已视觉核对。 |

## 5. 训练与推理差异维度

| 维度 | 本来源给出的差异、证据标签与定位 |
|---|---|
| 1. 执行阶段与状态 | [原文事实] 训练包含前向、反向、梯度计算、权重更新，并需要保存激活；“AI Memory Systems”还写到每个参数的梯度增加存储和数据搬运。推理只做前向。作者区分 Transformer 训练/预填充与自回归解码，并说明 KV cache 容量随序列长度线性增长、每个解码步读取不断增大的缓存。“Machine learning hardware specialization”；“Transformer networks”；“Transformer architectures (GPT-2/Llama)”。[未覆盖] 主权重、各类优化器状态、前缀缓存的独立容量与生命周期没有系统展开。 |
| 2. 优化目标 | [原文事实] 训练强调大批量吞吐和 time-to-result；交互式推理强调单请求、确定性延迟，批处理在吞吐与排队延迟间权衡；边缘/大规模推理还重视每次推理能耗和成本。定位：脚注 12、“Batch size and arithmetic intensity”、Hardware Sustainability。[单源观察] 自测答案讨论多租户导致 p99 上升，但正文没有建立首词延迟、逐词延迟和尾延迟的完整指标体系。[未覆盖] 首词延迟（TTFT）和逐词延迟（TBT）的明确定义。 |
| 3. 数值与累加 | [原文事实] 训练常以 FP16/BF16 做矩阵乘并保留 FP32 累加；推理更常用 INT8/INT4，必要时保留部分高精度激活。低精度同时减少字节数并提高计算密度。“Numerics in AI acceleration”及 Table 6。[未覆盖] 各格式的输入、乘积、累加和输出位宽未按产品完整拆分；稠密/稀疏峰值也未形成训练—推理对照表。 |
| 4. 计算单元与数据流 | [原文事实] 作者把训练导向设计概括为宽浮点通路和高吞吐矩阵单元，把推理导向设计概括为更低精度与能效；但向量、归约和特殊函数单元仍是两者端到端执行所需。训练/预填充大 GEMM 可计算受限，低批解码由权重/KV 带宽限制。定位：Table 2、3、7、13、22。[分析者推断] 对 LLM，合理架构是矩阵与向量/归约资源平衡、数据流可按层切换，不是只扩大矩阵阵列。 |
| 5. 片上存储 | [原文事实] 寄存器、SRAM/cache 和软件管理 scratchpad 用于保存 tile、部分和、常用权重或激活；FlashAttention 通过 SRAM 分块避免把完整 $S\times S$ 注意力矩阵写回 HBM。训练保存激活、解码分块读取 KV cache，都会影响片上工作集。定位：“Memory hierarchy”与“Transformer architectures”。[未覆盖] 任何训练芯片与推理芯片的片上 SRAM 容量定量对照。 |
| 6. HBM 与片外存储 | [原文事实] 训练的激活、梯度和大批量状态带来容量与带宽需求；推理解码的权重和 KV cache 同时施加容量与带宽压力。高性能加速器通常配置几十 GB、数 TB/s 量级的设备内存，但正文数字是代表性范围或算例。定位：“Off-chip memory”“Memory bandwidth and architectural trade-offs”及 Table 11。[分析者推断] HBM 容量大并不能自动解决带宽受限，反之高带宽也不能容纳超出器件内存的完整运行状态。 |
| 7. 存算配比 | [原文事实] 机器平衡点为 $I_{\text{ridge}}=R_{\text{peak}}/\mathrm{BW}$，单位 FLOP/byte；低于脊点为带宽受限。A100 教学值约 153 FLOP/byte，H100 教学值约 295.2 FLOP/byte；精度与 SKU 改变该比值。定位：“Roofline Model”与 Napkin Math 1.3。[未覆盖] $B_{\text{HBM}}/P_{\text{peak}}$、$C_{\text{HBM}}/P_{\text{peak}}$ 以及 HBM 容量/训练状态、HBM 容量/推理状态适配比没有作为正式指标计算。 |
| 8. 互联与通信 | [原文事实] 训练在多芯片上交换激活、梯度并执行 AllReduce；高带宽节点内互联、拓扑感知 collective 和计算—通信重叠决定扩展效率。正文给出 HBM、NVLink、PCIe、网络逐级变慢的示例。定位：“Node-level interconnect topology”与 “Multi-Chip Scaling”。推理侧只零散提到分片权重、高吞吐服务和跨设备张量，没有同等完整的解码通信模型。[未覆盖] MoE all-to-all 的定量开销与推理拆分式服务互联。 |
| 9. 调度与服务质量 | [原文事实] 大批量提高算术强度和吞吐，却增加等待成批的延迟；运行时按已准备的 batch/shape/profile 选择内核并管理缓冲，多租户内存带宽争用和缓存污染会抬高 p99。定位：“Batch size and arithmetic intensity”“Runtime Support”及自测答案。[未覆盖] 芯片级抢占、优先级、隔离带宽和硬 QoS 机制。 |
| 10. 功耗与部署 | [原文事实] 数据中心训练可接受数百瓦功耗以缩短周级训练时间；边缘推理受几瓦热设计与每次推理能耗约束，偏向近存储和低比特。云端大规模推理还要看利用率、租金和生命周期电耗。定位：“Machine learning hardware specialization”后半、Cost-performance、Hardware Sustainability。[未覆盖] 数据中心 LLM 推理芯片的机架功耗和散热定值。 |
| 11. 软件栈 | [原文事实] 编译器负责图融合、内核选择、布局、分块、内存规划和调度；运行时在预构建的合法变体中适配 batch、序列长度、可用内存和资源状态。训练和推理都依赖软硬件协同，但推理服务对动态 shape、批量和尾延迟尤其敏感。定位：“Compiler Support”“Runtime Support”。[未覆盖] 分布式训练框架和推理服务框架的接口级比较。 |
| 12. LLM 专项 | [原文事实] 训练和预填充中的矩阵乘可计算受限；低批自回归解码通常受权重与 KV cache 带宽限制。KV cache 容量随序列线性增长，解码步读取量随上下文增长；FlashAttention 减少注意力中间量的 HBM 往返。MoE 的输入相关路由会增加批处理、预取和负载均衡难度。定位：“Transformer networks”“Irregular memory access”“Transformer architectures”。[未覆盖] 前缀缓存、推测解码硬件、MoE 专家并行/All-to-All 定量模型，以及 TTFT/TBT 分别对应的硬件指标。 |

## 6. 关键数字与证据链

### 6.1 可进入综合候选的数字

| 原值 | 口径与对象 | 定位 | 来源性质与限制 |
|---|---|---|---|
| DRAM 640 pJ、FP32 multiply 3.7 pJ、SRAM 0.5 pJ | 单次事件能耗，Figure 9 对应本地 `F01_Energy_Ladder.svg`，对数尺度 | Figure 9 / “Understanding the AI memory wall” | [单源观察] 教材转述 Horowitz 2014，工艺、位宽和实现会改变绝对值；只用来说明搬运远贵于计算。 |
| A100：312 TFLOP/s FP16/BF16、2.04 TB/s、脊点约 153 FLOP/byte | 单加速器教学配置，稠密低精度峰值与 HBM 峰值相除 | Roofline Definition 1.5、Napkin Math 1.3 | [单源观察] 分子分母必须是同一 SKU/精度/带宽范围；需回原始规格复核。 |
| H100：989 TFLOP/s、3.35 TB/s、脊点约 295.2 FLOP/byte | 单加速器教学配置，稠密 FP16 路径 | Napkin Math 1.3 | [单源观察] 不与 FP8、稀疏或系统聚合数字混用。 |
| 大型 FP16 dense 层近似 $I\approx B$；batch 1≈1、batch 32≈31、batch 256≈204.8 FLOP/byte | $M=N=2048$，权重流量占主导 | Napkin Math 1.8，公式 6 | [原文事实] 是特定矩阵形状和流量模型的推导，不是所有模型的通式。 |
| GPT-2 XL batch 1：约 3 GB FP16 权重、每 token 约 3 GFLOP、$I\approx1$ FLOP/byte、A100 计算利用率上限约 0.7% | 1.5B 参数、逐 token 权重流模型；未把缓存、内核和并发全部纳入 | Napkin Math 1.9 | [单源观察] 很适合解释机制，但不应当作实测吞吐。 |
| HBM 3350 GB/s ≫ NVLink 900 GB/s ≫ PCIe 64 GB/s ≫ 网络 50 GB/s | 示例性带宽阶梯，混有设备内存、聚合双向节点内互联、主机链路和节点网络 | “Node-level interconnect topology” | [单源观察] 不同方向、聚合和拓扑口径不能直接做器件比值；本地 `F02` 只视觉确认顺序。 |
| AllReduce 暴露同步占 5% 时，Amdahl 上限为 20× | 多加速器训练，假定 5% 是不可隐藏串行部分 | “Why scaling introduces new constraints”脚注 41 | [原文事实] 数学边界，不代表特定集群实测。 |
| 融合示例 25.2 MB→8.4 MB，外部张量流量降 3× | 三个点算子、$1024\times1024$ FP32，理想读写模型 | Table 20 | [单源观察] 缓存、缓冲复用、寄存器压力和占用率会改变收益。 |
| Transformer QKV 556.4 FLOP/byte、softmax 0.75 FLOP/byte | batch 32、seq 512、hidden 768 的教学算例 | Napkin Math 1.4 | [单源观察] 表明同一层内也有计算受限与带宽受限算子，不可外推到所有形状。 |

### 6.2 主张—证据—条件—限制

**主张 A：低批量 LLM 解码更容易受 HBM 带宽限制，而不是受峰值矩阵算力限制。**

- 证据：[原文事实] batch 1 dense 层约 1 FLOP/byte；GPT-2 XL 教学模型约 1 FLOP/byte，远低于 A100 153 FLOP/byte 脊点；Transformer mapping 小节直接说低批解码常由权重与 KV-cache 带宽限制。
- 条件：权重不能在更近存储层充分常驻；批量小；逐 token 解码；没有把大量请求合并成大矩阵。
- 限制：量化、连续批处理、投机解码、缓存命中、模型并行和具体内核都可能改变强度和瓶颈；算例不是实测。

**主张 B：训练和预填充更容易利用宽矩阵引擎，但训练仍可能被存储或通信限制。**

- 证据：[原文事实] 作者把训练/预填充 GEMM 归入可计算受限的形状，把反向、梯度、激活与 AllReduce 作为额外状态和通信；Table 13、22 与 Multi-Chip Scaling 共同支持。
- 条件：批量和矩阵形状足够大，内核正确使用 Tensor Core/脉动阵列，数据供给和通信可重叠。
- 限制：教材另有“Transformer-style training often memory-bandwidth bound”的概括，说明训练本身也不是恒定计算受限；需按算子、并行策略和形状分析。

**主张 C：低精度的收益同时作用于算力密度和字节流量，因此训练/推理精度差异会传到内存和能耗架构。**

- 证据：[原文事实] Numerics 小节说明 FP16/BF16 训练配 FP32 累加，INT8/INT4 推理；减少位宽能压缩流量并在专用通路中提高并行密度。
- 条件：硬件原生支持对应格式，模型经过数值验证，算子和 shape 走到专用快路。
- 限制：作者没有给出统一的准确率损失、累加器物理位宽或所有层的精度规则。

**主张 D：训练扩展比单芯片推理更直接依赖高带宽互联，但现代大模型推理也可能因权重分片和 KV 交换触碰同一通信层级。**

- 证据：[原文事实] 训练梯度同步、模型分区和激活交换直接出现在 Node-level interconnect 与 Multi-Chip Scaling；Table 11 和 Transformer 小节说明模型与状态可能超出单芯片容量。
- 条件：模型或状态跨器件，且通信不能完全与计算重叠。
- 限制：本章没有建立推理阶段的张量并行、流水并行或拆分式 prefill/decode 通信模型，推理侧结论只能标为分析者推断。

## 7. 跨图表推理与反例

[分析者推断] Figure 11 的脊点上升、Table 13 的低强度算子，以及 Napkin Math 1.9 的 batch-1 解码算例共同指向：如果训练导向芯片主要增加矩阵峰值、HBM 带宽增长较慢，那么低批解码会用到更小比例的峰值算力。推理步骤为：先确定同精度 $P_{\text{peak}}/B_{\text{HBM}}$ 上升；再确认解码的实际 $I$ 远低于脊点；最后由 Roofline 得出性能随带宽而非峰值算力增长。替代解释是量化、批处理、缓存、稀疏和专用解码数据流可抬高实际强度或减少字节，因此不能只凭一个比值给芯片贴标签。

[分析者推断] Figure 9 的能耗层级、Table 10 的容量—延迟层级和 Table 11 的 Transformer 状态共同说明，HBM“多”和“快”是两种不同能力：容量决定权重和 KV cache 是否能驻留，带宽决定每 token 能多快读取；片上 SRAM 决定可复用 tile 能否避免 HBM 往返。替代解释是某些模型或批量使计算先成为瓶颈，所以三者都要结合 workload 测量。

本章也给出几个反例，限制绝对二分：

- [原文事实] 同一 Transformer 的训练和预填充 GEMM 可计算受限，解码则常带宽受限，说明阶段而非“模型名字”决定瓶颈。
- [原文事实] “Hybrid mapping strategies”要求一个芯片在层边界切换 weight/input/output stationary、分块和融合；固定单一数据流并不适合所有层。
- [原文事实] A100、TPUv4 等通用矩阵加速器可同时执行训练和推理，差别由精度、batch、内核和系统目标塑造。Table 7 的“主要工作负载”不是能力禁区。
- [原文事实] 推理不总是 batch 1；吞吐型服务可通过 batching 把 dense 层从约 1 FLOP/byte 推到计算受限区。相反，训练中的 LayerNorm、softmax、嵌入和通信仍可能带宽受限。

## 8. 适用时代、工作负载与缺失项

这是一份 2026 年仍在更新的机器学习系统教材，既含 TPUv1、V100、A100 等历史案例，也讨论 H100/B200、Transformer、FlashAttention、KV cache、低批解码和 MoE，覆盖面比典型 CNN 时代综述更接近现代 LLM。可迁移到现代研究的部分是 Roofline、内存层级、数据复用、批量—延迟权衡和通信边界；不可直接迁移的是 2014 年能耗绝对值、混合精度峰值曲线、近似价格以及固定 A100/H100 教学算例。

本来源的主要缺失项是：训练主权重和各种优化器状态的逐项字节模型；推理前缀缓存和内存碎片预留；TTFT、TBT 与吞吐的统一测量口径；MoE 专家并行和 All-to-All；解耦式预填充/解码；具体芯片的片上 SRAM 容量、NoC 带宽、HBM 容量、持续带宽和 QoS 硬件；输入/乘积/累加/输出的物理位宽；稠密与稀疏峰值的严格同口径比较。

来源边界也很重要：作者引用原始论文，但这张卡只固定了教材网页，不把其引用列表自动算作多个独立证据家族。教材表格中的厂商规格、价格和峰值必须由主会话回到原始来源核验。动态开发版还可能修正文字和数值，因此综合报告应标注 v0.7.1 与访问日期。

## 9. 对最终报告的贡献

1. [原文事实] 训练状态更大且有双向计算，系统目标偏训练完成时间/吞吐，因而倾向高浮点矩阵吞吐、HBM 与强互联；定位：“Machine learning hardware specialization”、Multi-Chip Scaling；条件：数据中心大模型训练；家族：`WF-HARVARD-MLSYS-TEXTBOOK`。
2. [原文事实] LLM 训练/预填充与低批解码不能合并判断：前者的大 GEMM 可计算受限，后者常受权重和 KV-cache 带宽限制；定位：Table 22 及 “Transformer architectures”；条件：低批自回归解码；家族：`WF-HARVARD-MLSYS-TEXTBOOK`。
3. [原文事实] 机器平衡点必须按同一对象、精度与带宽口径计算为 $P_{\text{peak}}/B_{\text{HBM}}$，单位 FLOP/byte；定位：Roofline 公式 2、3 与 Napkin Math 1.3；家族：`WF-HARVARD-MLSYS-TEXTBOOK`。
4. [原文事实] 训练扩展引入梯度同步和 AllReduce，通信层级越远越慢，架构需要高带宽互联、拓扑感知和计算—通信重叠；定位：Node-level interconnect、Multi-Chip Scaling；家族：`WF-HARVARD-MLSYS-TEXTBOOK`。
5. [分析者推断] “训练芯片/推理芯片”应写成条件化设计倾向：通用矩阵加速器、混合数据流和按层编译构成反例，不能把某个存算比当作绝对标签；定位：Hybrid mapping、Runtime Support；家族：`WF-HARVARD-MLSYS-TEXTBOOK`。

供主会话综合的摘要：这章把训练—推理差异落到三个可检查的变量上：运行状态有多大、每字节能做多少计算、必须跨过哪一级通信边界。训练为了前后向、梯度和大批量吞吐，通常更需要浮点矩阵能力、激活/梯度存储与高带宽互联；LLM 低批解码则因逐 token 读取权重和增长中的 KV cache，更容易被 HBM 容量、带宽和服务调度限制。真正决定架构倾向的是阶段、batch、精度、数据流和部署目标，而不是“训练”或“推理”这个名称本身。