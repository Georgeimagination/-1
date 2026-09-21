# S12｜AI 加速器性能与基准测试

## 1. 来源身份与固定版本

- 来源编号：S12
- 题名：*AI Accelerator Performance and Benchmarking*
- 作者或机构：Google Cloud Documentation；页面未列个人作者
- 来源类型：Google Cloud 官方动态网页，属于厂商方法指南，不是同行评审论文、公开基准结果集或具体芯片规格表
- 工作家族：`WF-GOOGLE-ACCELERATOR-BENCHMARKING`
- 固定版本：页面最后更新时间 `2026-07-29 UTC`；本地固定于 2026-08-14
- 原始网址：<https://docs.cloud.google.com/docs/ai-ml/accelerator-performance-benchmarking>
- 本地网页快照：`原文/网页快照/S12_accelerator_benchmarking.html`
- 规范化文本：`原文/规范化文本/S12_accelerator_benchmarking.txt`
- SHA-256：网页快照 `5E5E4A671711654E63CDA62FC0953E0CD20468AB63373DADECD4A65DB5184DDC`
- 文件大小：网页快照 137,925 字节；规范化文本 29,017 字节
- 许可与访问边界：网页正文注明采用 Creative Commons Attribution 4.0（CC BY 4.0），代码示例采用 Apache 2.0；动态页后续可能改版，本卡只采用上述固定快照
- 定位体系：网页无页码，以下用小节标题、表头和段落开头定位。网页中的 Roofline 图由 HTML 引用 Google Cloud 静态 SVG，快照未把图片资产一并保存；本卡仅为视觉核对从该 `src` 指向的同站点路径读取临时副本，不把它作为第二来源

## 2. 实际阅读范围与筛选判断

已扫描 4,298 行 HTML 和 814 行规范化文本，精读从页面主标题到 “What's next” 之前的全部正文，包括 Performance dimensions、Benchmarking principles、Microbenchmarks、Roofline analysis、Model benchmarking、Training benchmarking 和 Inference benchmarking。全文 9 张无编号表、1 幅无编号图和各组示例均已过账；导航、页脚和站点链接只用于核对身份、许可及最后更新时间，没有未读的正文段落。

| 筛选维度 | 判断 | 说明 |
| --- | --- | --- |
| 问题匹配 | `pass` | 页面直接比较训练与推理的规模、吞吐、时延、通信和评测指标，并明确区分推理预填充与逐词解码。 |
| 方法与信息增益 | `pass` | 它把微基准、Roofline 和模型基准串成一套诊断流程，可避免把峰值规格直接当成工作负载性能。 |
| 证据质量 | `borderline` | 方法解释清楚，公式和假设算例可复算；但页面没有真实跨芯片实验、原始数据或统计方法，TPU 案例又来自 Google 自身。 |
| 可交叉验证性 | `borderline` | 固定快照、哈希、表格和更新时间可复核；模型与硬件共设计、集群规模及性能判断缺少本页内的测量数据。 |

范围相关性为“直接相关”，领域角色为“重要方法支撑”，证据成熟度是“厂商方法指南＋教学算例”。本卡对页面内容提取的置信度高，对其跨厂商普适性的置信度中。它可以规定后续比较该测什么、怎样归一化，不能单独回答哪款芯片更快或训练芯片与推理芯片应有多少算力、带宽和容量。

## 3. 评测框架、作者主张与机制

这份指南主张先用微基准测出计算、HBM 和互联的持续能力，再用 Roofline 判断负载受计算还是数据移动限制，最后在固定模型与服务约束下测训练和推理；三层结果不一致时，再检查分片、内核和模型与硬件映射。

[原文事实] Performance dimensions 把评估分成三层。微基准隔离稠密矩阵乘法、HBM、芯片间通信、主机传输和持续功耗；Roofline 用运算强度（Operational Intensity，OI）把峰值计算与内存带宽联系起来；模型基准用每芯片每秒 token 数（TPS/chip）观察真实训练或推理。页面强调模型基准只是“给定模型、规模和平台在某个时点”的快照。

[厂商设计意图] Model and hardware co-design 认为模型几何形状会决定矩阵单元利用率。页面用 `gpt-oss-120B` 举例：注意力头维度为 64，而 Trillium、Ironwood TPU 被描述为偏好 256 的倍数并使用 $256\times256$ 的矩阵执行网格，因此可能产生补零和利用率损失。该段没有 TPS、模型 FLOPS 利用率（MFU）、内核版本或对照实验，只能支持“映射不匹配会污染芯片比较”这一机制，不能量化 TPU 相对 GPU 的差距。

页面给出两条与本课题直接相关的因果链：

1. 固定训练模型后扩大集群 → 系统目标是维持 TPS/chip、MFU 和有效训练进展（goodput） → 架构与系统需要持续计算能力、可扩展互联、故障恢复和成熟软件栈；否则单芯片性能会被“规模税”抵消（Training benchmarking）。
2. 在线推理在首词、逐词和 P99 尾延迟约束下增加并发 → 系统目标是在不违反服务等级协议（SLA）的前提下取得最大持续 TPS/chip → 预填充更偏计算，逐词解码更偏 HBM 带宽，批处理、内存系统和调度共同决定利用率（Inference benchmarking）。

## 4. 图表与示例过账

原网页没有 Figure/Table 编号。下表的“网页表 1 至 9”是本卡为核对完整性添加的顺序编号。

| 图表 | 位置与主题 | 与课题的关系及可支持范围 | 视觉或内容核对状态 |
| --- | --- | --- | --- |
| 网页表 1 | Microbenchmarks，`Benchmark / Explanation` | 列出稠密 GEMM、HBM streaming、all-reduce/all-gather、H2D/D2H 和 48 小时持续功耗五类测试；是建议协议，不是结果。 | 已核对 5 行及条件。 |
| 网页表 2 | Example microbenchmark comparison | 用假设 Chip A/B 比较芯片间网络、GEMM、内存、H2D 和 D2H 的实测/规格比，说明较低标称峰值也可能有更高持续利用率。 | 已逐格核算百分比；所有数值均为教学假设值。 |
| `roofline-model.svg` | Roofline analysis 段落后的唯一正文图 | 横轴为 OI（FLOPS/byte），纵轴为性能（FLOPS/s）；斜屋顶是 memory-bound，平屋顶是 compute-bound，交点为 ridge point。Algo 1 位于交点左侧，Algo 2 位于右侧。图无数值刻度。 | 已视觉核对轴、两条屋顶、交点、区域着色和 Algo 1/2；不能从图读取具体芯片数值。 |
| 网页表 3 | Model benchmarking，`Insight / Training workloads / Inference workloads` | 训练侧突出超大集群、TPS/chip、MFU、数据 I/O 和同步更新；推理侧突出 1 至 64+ 芯片、并发、TTFT、逐 token 时延和端到端排队。 | 已核对 3 行。 |
| 网页表 4 | Training benchmarking，`Benchmark / Explanation` | 给出最小可行集群基线、256/1024/4096 芯片扩展和 goodput 三步；属于建议测法。 | 已核对 3 行及重复抽取文本。 |
| 网页表 5 | 训练推荐模型 | 列出 Llama 3.1 8B、Llama 3.1 70B 和 DeepSeek-V3 671B，覆盖小/中型稠密与大型混合专家模型（MoE）。 | 已核对 3 行；推荐名单具有 2026-07-29 时点性。 |
| 网页表 6 | Chip_A 相对 Chip_B/Chip_C 的 TPS 比 | 四个假设模型负载的相对性能与平均值。 | 已核对 4 行和平均值；不是任何真实芯片数据。 |
| 网页表 7 | 同一算例按 perf/\$ 归一化 | 把假设价格 \$100、\$180、\$200 纳入后，Chip_A 相对 B/C 的平均 perf/\$ 变为 1.42/1.20。 | 已复算各行和平均值；全部是教学假设。 |
| 网页表 8 | Inference benchmarking，`Benchmark / Explanation` | 先设 P99、TTFT、TPOT 约束，再推高 batch，记录持续 TPS/chip，并换算每千/百万 token 的总拥有成本（TCO）。 | 已核对 4 行；SLA 数字是示例阈值。 |
| 网页表 9 | 推理推荐模型 | 列出 Llama 3.1 8B、Llama 3.1 70B 和 Qwen3 Coder 480B。 | 已核对 3 行；不是测量结果。 |

文字示例也已单独核对。`gpt-oss-120B` 段是 Google 对 TPU 几何匹配的单源说明，没有性能数据；“Chip A 快 20%、贵 50%”用于解释性能/美元；Chip A/B/C 两组表用于演示归一化如何改变排序；P99 100 ms、TTFT 小于 500 ms 是推理 SLA 教学示例。上述数字都不能进入具体芯片事实表。

## 5. 训练与推理差异维度

| 维度 | 本来源提取结果、证据标签与定位 |
| --- | --- |
| 执行阶段与状态 | [原文事实] 训练表提到数据加载和同步梯度更新；推理表明确要求分测预填充与解码，并称前者更受计算限制、后者更受内存带宽限制（Model benchmarking；Inference benchmarking）。[未覆盖] 梯度张量、优化器状态、保存激活、KV cache、前缀缓存及其容量。 |
| 优化目标 | [原文事实] 训练关注 TPS/chip、TPS/chip/\$、MFU、扩展退化和 goodput；推理关注在 P99、首词延迟（TTFT）、每输出 token 时间（TPOT）约束下的最大持续 TPS/chip，以及 TCO/token（Training benchmarking；Inference benchmarking）。 |
| 数值与累加 | [原文事实] 微基准建议跨“多种精度”执行 GEMM，推荐模型表区分稠密与 MoE。[未覆盖] 具体输入、乘积、累加、输出精度，稀疏率及稀疏硬件口径。MoE 的稀疏激活不能等同于稀疏峰值规格。 |
| 计算单元与数据流 | [厂商设计意图] `gpt-oss-120B` 示例把头维度 64 与 TPU 的 256 倍数偏好、$256\times256$ MXU 网格联系起来，说明形状、补零和内核影响利用率。[未覆盖] 向量/标量单元、具体数据流、阵列占用率实测。 |
| 片上存储 | [未覆盖] 没有寄存器、缓存、SRAM、片上网络的容量、带宽或复用层级。 |
| HBM 与片外存储 | [原文事实] 建议分别测 HBM 持续读、写、复制带宽，以及 CPU 内存与加速器间 H2D/D2H；解码被定性为 HBM 带宽受限（Microbenchmarks；Inference benchmarking）。[未覆盖] 真实容量、带宽、访问粒度、有效带宽和 KV cache。 |
| 存算配比 | [原文事实] $OI=\text{FLOPs}/\text{bytes}$，内存屋顶为 $P=B_{HBM}\times OI$，计算屋顶为 $P=P_{peak}$（Roofline analysis）。[分析者推断] 交点为 $OI_{ridge}=P_{peak}/B_{HBM}$，单位 FLOPs/byte。页面没有给任何芯片的同精度 $P_{peak}$ 与 $B_{HBM}$，也没有定义网络 Roofline。 |
| 互联与通信 | [原文事实] 微基准建议在数千芯片上测 all-reduce/all-gather，并测 ICI 或 NVLink；MoE 被认为提高网络二分带宽要求。训练的大规模扩展突出通信开销，推理表更偏 1 至 64+ 芯片和并发用户（Benchmarking principles；Microbenchmarks；Model benchmarking）。[未覆盖] 拓扑、方向、有效载荷、消息尺寸和同步频率。 |
| 调度与服务质量 | [原文事实] 推理应先固定 SLA，再逐步增加并发/批量，观察吞吐上升和时延恶化，直到触及 P99 约束（Inference benchmarking）。[未覆盖] 连续批处理、动态调度、隔离、抢占和多租户服务质量实现。 |
| 功耗与部署 | [原文事实] 建议连续 48 小时运行高利用率 GEMM 并监控机架功耗，比较性能/瓦和性能/美元；正文把训练视为前期资本投入、推理视为长期运营开销（Microbenchmarks；Benchmarking principles；Inference benchmarking）。[未覆盖] 单芯片 TDP、散热上限和部署形态。 |
| 软件栈 | [原文事实] 模型结果低于微基准/Roofline 预期时，页面建议检查分片和自定义内核；跨平台推理可用 vLLM，训练在模型保持不变时可分别用 TPU 的 MaxText 与 GPU 的 Megatron（Performance dimensions；Benchmarking principles）。[未覆盖] 软件版本、编译参数和可复现实验仓库。 |
| LLM 专项 | [原文事实] 直接涉及预填充、逐词解码、MoE、注意力头维度、TPS 和 MFU；解码定性为低 OI，batch=1 自回归解码列为 memory-bound（Roofline analysis；Model benchmarking）。[未覆盖] KV cache、长上下文、前缀缓存、投机解码及每 token 状态字节数。 |

## 6. 关键数字与证据链

| 候选数字或公式 | 原值、对象与定位 | 证据性质与限制 |
| --- | --- | --- |
| Roofline 公式 | $OI=\text{FLOPs}/\text{bytes}$；$P_{memory}=B_{HBM}\times OI$；$P_{compute}=P_{peak}$（Roofline analysis） | [原文事实] 方法公式；没有具体精度、芯片和实测点。[分析者推断] 综合写法为 $P_{attainable}=\min(P_{peak},B_{HBM}\times OI)$。 |
| TPU 几何示例 | `gpt-oss-120B` 头维度 64；Trillium/Ironwood 被描述为偏好 256 的倍数和 $256\times256$ MXU 网格（Model and hardware co-design） | [厂商设计意图] 具体模型与平台叙述，但没有 TPS/MFU 数值、对照内核或独立复现。 |
| 微基准时长 | 满负载 GEMM 连续 48 小时并监控机架功耗（Microbenchmarks 表） | [原文事实] 建议测试时长，不是产品通过 48 小时稳定性测试的证据。 |
| 假设微基准表 | A/B：网络 800/850 GBps，GEMM 1,800/1,800 TFLOPS，内存 6,000/6,500 GBps，H2D 58/60 GBps/chip，D2H 55/55 GBps/chip；对应规格和利用率见网页表 2 | [原文事实] 页面明确称 illustrative、Chip A/B 为 hypothetical；只能验证“持续/标称比”算法。五组百分比复算一致。 |
| 典型规模叙述 | 训练常为 10k+、最大模型可到 100k+ 芯片；推理常为 1 至 64+ 芯片（Model benchmarking 表） | [单源观察] 没有样本、产品或集群清单，不能当市场普遍分界。 |
| 训练扩展点 | 256、1,024、4,096 芯片上保持同一模型并重算 TPS/chip（Training benchmarking 表） | [原文事实] 建议实验点，不是测量规模或结果。 |
| TPS 归一化 | $TPS/chip=TPS_{global}/N_{chips}$；再除以单芯片价格得到 TPS/chip/\$（Training benchmarking） | [原文事实] 便于跨规模和成本比较；仍需固定模型、精度、训练有效 batch、软件成熟度和价格口径。 |
| perf/\$ 教学算例 | Chip_A 相对 B/C 的平均 TPS 比为 0.79/0.60；假设价格 \$100/\$180/\$200 后，平均 perf/\$ 比为 1.42/1.20，即高 42%/20% | [原文事实] 算术可复算，模型、性能和价格全部为假设值，不对应真实芯片。 |
| 推理 SLA 示例 | P99 100 ms、TTFT 小于 500 ms；逐步增大 batch，记录最大持续 TPS/chip（Inference benchmarking 表） | [原文事实] 教学阈值，不是通用服务要求。页面没有给 TPOT 阈值、输入/输出长度或并发到达分布。 |
| 推荐模型规模 | 训练：8B、70B、671B；推理：8B、70B、480B（推荐模型两表） | [单源观察] 2026-07-29 的厂商推荐名单，具有明显时点性，不是性能证据。 |

页面的主要主张与证据边界如下：

- “峰值规格不等于工作负载性能”由微基准/规格比算例和 Roofline 机制支持，但没有真实芯片对照，因此证据停留在方法论。
- “训练和推理应采用不同模型基准”由网页表 3、4、8直接支持：训练要看扩展与 goodput，推理要看 SLA 下吞吐。适用条件是 LLM 数据中心工作负载；页面没有训练完成时间或真实服务 trace。
- “预填充偏计算、解码偏带宽”是厂商指南的直接陈述，未给 batch、上下文、精度和模型实测，综合报告应由独立实验家族补强。
- “模型与硬件共设计影响公平比较”由 `gpt-oss-120B` 案例解释，但同一案例没有量化软件优化前后的差值。

## 7. 跨图表推理与反例

[分析者推断] 三层方法构成一条诊断链：微基准先给出组件持续上限，Roofline 再给出给定 OI 下的理论上限，模型基准最后测端到端结果。模型结果低于前两层只说明“存在映射、软件或系统损失”，不能仅凭差距认定分片或内核是唯一根因；网络拥塞、同步、数据输入、可靠性和基准条件也可能造成差异。

[分析者推断] 网页先要求使用跨平台模型和工具，又强调模型与硬件共设计。两者回答的问题不同：固定模型、等价语义和同口径设置用于比较移植后的表现；分别采用平台优化内核与框架用于测各平台能达到的上限。若把这两类结果放进一张排名表，软件投入和模型几何会被误当作芯片差异。

Roofline 图还给出一个重要边界。页面把网络带宽列为第三项硬件约束，但图和公式只有计算与 HBM 两条屋顶；分布式训练、MoE 或多芯片推理需要另建通信模型，不能从这张标准 Roofline 图推出集群扩展效率。

[分析者推断] 推理协议写的是“出现 P99 违约时停止，并记录该 batch 的吞吐”。若目标是“在 SLA 内的最大持续吞吐”，严格口径应记录最后一个仍满足 SLA 的 batch，或对违约点作插值；原文措辞在这里不够严密。TCO/token 也缺少摊销周期、利用率和电价时段，不能仅用单芯片价格除 TPS 得到可比较的长期成本。

反例来自推理自身：预填充偏计算、解码偏带宽，同一次推理服务已经包含两种瓶颈；页面也让同一组 GPU/TPU参与训练和推理基准。因此本来源支持“按阶段和目标调配资源”，不支持把训练芯片与推理芯片划成两类互斥架构。

## 8. 适用时代、工作负载与缺失项

本来源属于 2026-07-29 的现代数据中心 LLM 语境，面向 NVIDIA、AMD、Google、AWS 等平台的跨厂商评估。它覆盖 Transformer、MoE、大规模训练、在线推理、预填充和解码，适合用作后续芯片比较的指标合同。推荐模型和软件工具会快速变化，不能脱离固定日期继续沿用。

它没有提供真实芯片的工艺、频率、精度、峰值/持续算力、HBM 容量与带宽、互联拓扑、功耗、价格或端到端结果；也没有公开代码、环境版本、原始数据、误差、重复次数和统计方法。训练状态只提到同步梯度更新，未覆盖优化器状态和激活；推理未覆盖 KV cache、上下文长度、输入/输出 token 数、前缀复用和动态批处理。网页表中的 Chip A/B/C、价格、带宽、算力、时延门槛和集群扩展点均是教学或建议值，不得写入具体芯片资料卡。

来源归属也构成证据边界。Google Cloud 既是指南发布者，也是 TPU 平台提供者；`gpt-oss-120B` 对 TPU 的解释应标为厂商设计意图。跨厂商结论仍需独立基准、原始运行记录或其他工作家族交叉验证。

## 9. 对最终报告的贡献

| 候选结论 | 标签与定位 | 适用条件 | 独立工作家族 |
| --- | --- | --- | --- |
| 加速器比较应同时使用微基准、Roofline 和模型基准，避免把峰值规格直接当成应用性能。 | [单源观察] Performance dimensions | 方法框架；缺真实跨芯片数据。 | `WF-GOOGLE-ACCELERATOR-BENCHMARKING` |
| 训练侧应看 TPS/chip 随集群扩大后的退化、MFU 和 goodput；推理侧应看 TTFT、TPOT、P99 约束下的持续 TPS/chip。 | [单源观察] Model/Training/Inference benchmarking | 数据中心 LLM；指标口径仍需补齐。 | `WF-GOOGLE-ACCELERATOR-BENCHMARKING` |
| 预填充和逐词解码在同一推理任务中可能分别受计算与 HBM 带宽限制。 | [单源观察] Inference benchmarking | 页面未给模型、batch、上下文和实测。 | `WF-GOOGLE-ACCELERATOR-BENCHMARKING` |
| 模型几何、分片和内核会改变硬件利用率，跨平台比较需区分“固定模型可移植表现”和“平台优化上限”。 | [厂商设计意图] Model and hardware co-design；[分析者推断] Benchmarking principles | TPU 案例没有定量对照，需独立验证。 | `WF-GOOGLE-ACCELERATOR-BENCHMARKING` |
| 性能/美元和性能/瓦可改变原始吞吐排序，但价格、摊销、能耗和 SLA 必须同口径。 | [原文事实] 两组 perf/\$ 教学表；[分析者推断] 成本边界 | 表中数字全部是假设值。 | `WF-GOOGLE-ACCELERATOR-BENCHMARKING` |

供主会话综合：S12 最有价值的是评测结构，而不是任何示例数字。它要求先测组件持续能力，再用 Roofline 判断计算/带宽匹配，最后分别在训练扩展和推理 SLA 下测端到端表现。训练更突出集群扩展、通信、可靠性与 goodput，推理更突出批量、首词/逐词/尾延迟，以及预填充和解码的不同瓶颈。页面没有真实跨芯片结果，Chip A/B/C 和价格均为假设；TPU 共设计案例也只代表 Google 的单源解释。
