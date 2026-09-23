# Google Cloud TPU v5p one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

Google公开了TPU v5p的per-chip规格，但云端最小拓扑是4-chip `2×2×1` slice，没有独立的单芯片租用配置。本卡以规格表中的一颗TPU v5p chip作为正式比较对象；四芯片VM/host、cube、slice、Pod和Multislice只用于解释部署关系，不把聚合资源写成芯片属性。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Google | Cloud TPU v5p | `[1, page title and System architecture]` |
| 产品家族 | Google Cloud TPU v5p | training TPU代际 | `[2, p. 2, Table 1; p. 3, Architecture Stability Over Time]` |
| 完整 SKU | Google Cloud TPU v5p one chip | 官方per-chip比较配置；实际云端最小配置为4 chips | `[1, System architecture and Configurations]` |
| 对象形态 | 一颗TPU v5p chip/package的官方per-chip规格 | 不是`ct5p-hightpu-4t` VM或四芯片host | `[1, System architecture; VM, host and slice properties]` |
| 架构代际 | TPU v5p | 两个TensorCore、八个128×128 MXU和四个SparseCore的实现 | `[1, System architecture]` `[2, p. 2, Table 1]` |
| 发布与可用状态 | 2023-12-06宣布并开放申请；2024-04-09 GA；当前仍有按chip-hour计价的v5p资源 | 首次公开、GA和当前云服务状态分开 | `[4, page date and opening]` `[5, Cloud TPU v5p GA]` `[6, Regional pricing]` |
| 厂商定位 | 面向大型、要求高的generative AI模型训练；也用于serving/inference | 芯片家族和Cloud平台定位，不代表每种部署形态都等价 | `[4, opening and Inside Cloud TPU v5p]` `[5, Cloud TPU v5p GA and Comprehensive GKE support]` |
| 目标 workload | 大型foundation model、LLM和embedding-dense模型的训练，并可用于多host serving | 厂商定位，不把系统benchmark写进芯片配置 | `[4, opening and Inside Cloud TPU v5p]` `[5, Comprehensive GKE support]` |
| 产品目标 | 相对TPU v4提高单芯片算力、HBM容量/带宽、SparseCore性能与大规模扩展能力 | 单芯片增量和Pod扩展目标分层 | `[4, Inside Cloud TPU v5p]` `[1, System architecture and Configurations]` |

本卡包含：单颗TPU v5p的两个TensorCore、八个MXU、四个SparseCore、128MiB VMEM、六个HBM2E stack、BF16/FP8或BF8峰值、六条ICI link及per-chip功耗证据。

本卡不包含：四芯片VM/host的vCPU与RAM、64-chip cube、8,960-chip Pod、最大6,144-chip job和18,432-chip Multislice聚合资源。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | TensorCore内的VLIW scalar、vector、MXU和VMEM路径；SparseCore | TPU v2至Ironwood训练TPU的稳定架构在v5p上扩容 | 复用[TPU v5p架构资料](../架构/Google_TPU_v5p_架构卡.md)，本卡补足数量与容量 | `[2, pp. 3-7]` |
| die | TPU v5p compute实现；die size、工艺和chiplet边界未公开 | TPU v5p代际共享 | 不从package照片推断die/chiplet参数 | `[2, p. 6, Figure 3]` `[7, p. 2, Table 1]` |
| package | TPU v5p package，周围有6个HBM stack | TPU v5p实现 | 记录Google论文明确计数，不推断stack高度与interposer | `[2, pp. 2, 6, Table 1 and Figure 3]` |
| 产品配置 | Google Cloud TPU v5p one chip | 不适用 | 正式比较单位；不是可单独租用的最小slice | `[1, System architecture and Configurations]` |
| 相关系统 | 4-chip host/VM、64-chip cube、8,960-chip Pod及Multislice | 多种规模 | 只保留芯片端点和对象边界 | `[1, Configurations; VM, host and slice properties]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | 每芯片2个TensorCore，每个TensorCore含4个128×128 MXU、1个vector unit和1个scalar unit；单芯片共8个MXU | v5p直接数量；每个TensorCore结构由当前产品页给出 | `[1, System architecture]` `[2, p. 2, Table 1]` |
| 执行模型与调度 | scalar unit取VLIW bundle并转发解码指令，vector与matrix路径相对scalar解耦执行；异步DMA可与计算重叠 | Google称TPU v2框图的基本结构持续适用于包括v5p的训练TPU | `[2, pp. 3-4, Figure 2]` |
| 局部存储与数据搬运 | 每TensorCore有64MiB VMEM、1MiB SMEM，两核VMEM合计128MiB；vector lane寄存器读写本地VMEM切片，异步DMA在HBM和VMEM间搬运；由编译器管理 | JAX明确给出per-TensorCore容量，128MiB不是每核可独立使用的共享池；SMEM用于标量控制和动态索引 | `[2, pp. 2, 4, Table 1 and Figure 2]` `[10, TPU_V5P branch]` `[12, Placing operands in SMEM]` |
| 数值与累加路径 | 128×128 MXU采用systolic array；BF16乘法、FP32累加；v5p另有459TFLOPS的低精度峰值 | 当前Cloud页标为FP8，Google跨代论文标为BF8；官方Ironwood发布文将v5p的FP8标为emulated，保留模拟执行条件；完整乘积、累加和输出语义未公开 `[9, Figure 2 caption]` | `[2, pp. 2, 4, Table 1]` `[1, System architecture]` |
| 稀疏与专用单元 | 每芯片4个SparseCore，每SC有16个vector subcore（tile），每tile为8-wide SIMD、512KiB局部VMEM；SC内另有共享SPMEM | tile局部VMEM与共享SPMEM是不同空间；跨代论文的2.5MiB通用Sparse Vector Memory描述不能替代v5p专属分支。支持embedding、scatter/gather及部分collective、Top-K和小稀疏张量操作 | `[1, System architecture]` `[2, p. 5, SparseCore]` `[10, TPU_V5P branch]` `[13, Hardware overview]` |

### 3.1 寄存器、DMA与逻辑核心配置

scaling book以v5p为例给出每TensorCore 64个VREG，每个容纳8×128个32-bit元素，即4KiB；VMEM每周期可向VREG读入3个完整寄存器、写回1个。按教程约1.75GHz计算，分别为21.504TB/s和7.168TB/s/核；这两个方向须分别使用，也不能将两核合计带宽看成单核共享总线。每个标量核最多每周期创建一个DMA请求，并控制VPU、4个MXU、2个XLU和多个DMA engine，描述符创建速率与搬运吞吐不是同一个量。[11, Appendix A / VREGs; Scalar Core]

JAX明确v5p支持Megacore模式，即一个逻辑device包含两个物理TensorCore，也支持一个逻辑device只使用一个TensorCore的split模式。该软件映射不改变芯片的两核物理数量或每核64MiB VMEM；Pallas利用两核时需要将一个grid轴并行化，不能仅凭逻辑device数量认定执行资源自动翻倍。[10, ChipVersion.supports_megacore; get_tpu_info_for_chip] [12, Multicore TPU configurations]

v5p SparseCore DMA的最小传输粒度为32B。Pallas文档区分tile局部VMEM/SMEM、SC共享VMEM（常称SPMEM）和标量subcore的SMEM；gather/scatter DMA原生搬运32-bit类型，BF16/FP16数据须打包后读取并拆分。这是访问路径约束，不是结构化稀疏矩阵峰值倍增。[10, TPU_V5P branch] [13, Hardware overview; Gathering and scattering 16-bit dtypes]

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 2个TensorCore、8个128×128 MXU、4个SparseCore | 单颗v5p chip | `[1, System architecture]` `[2, p. 2, Table 1]` |
| 片上存储 | TensorCore：64MiB VMEM与1MiB SMEM/核；SparseCore：512KiB局部VMEM/tile，16 tile/SC | 两TensorCore合计128MiB VMEM；每SC分散tile空间算术合计8MiB，不含容量未明确的共享SPMEM，不将不同管理层级拼成统一cache | `[2, p. 2, Table 1]` `[10, TPU_V5P branch]` `[13, Hardware overview]` |
| 片内互联 | TensorCore、HBM、SparseCore和ICI router之间存在数据通路；具体NoC、crossbar、路由和一致性未公开 | Figure 2是跨代基本框图，不是v5p版图 | `[2, pp. 4-5, Figures 2-3]` |
| 内存控制器与PHY | 连接6个HBM2E stack和6条外部ICI link；控制器、PHY数量和宽度未公开 | per-chip物理端点 | `[2, pp. 2, 6, Table 1 and Figure 3]` |
| 工艺与物理规模 | 未公开 | Google作者资料将v5p die size和technology标为N.A. | `[7, p. 2, Table 1 and footnote 1]` |
| 封装组成 | v5p package照片显示6个HBM stack；芯片采用液冷 | 论文未给stack高度、interposer协议、基板或封装尺寸 | `[2, pp. 2, 6, Table 1 and Figure 3]` |
| 封装内互联 | 未公开独立D2D协议；未确认chiplet | HBM接口与ICI不写成compute-chiplet D2D | `[2, p. 6, Figure 3]` |
| RAS | 未公开芯片级ECC、重放或隔离细节 | ICI resiliency属于cube及以上系统能力 | `[1, Cloud TPU ICI resiliency]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 2个TensorCore、8个128×128 MXU、4个SparseCore | 单芯片 | `[1, System architecture]` `[2, p. 2, Table 1]` |
| 时钟 | 产品保证频率未公开；scaling book给约1.75GHz | 开发者架构说明的近似工作频率，不由峰值反推或升格为额定时钟 | `[1, System architecture]` `[11, Appendix A / VPU]` |
| 理论峰值 | Cloud/论文：459TFLOPS BF16、459TFLOPS FP8或BF8；JAX：918TOPS INT8、1,840TOPS INT4/全芯片 | 低精度浮点保留官方emulated条件；整数为每核459/920TOPS乘两核，不能等同FP4；来源未给完整稠密/稀疏与FMA计数说明 | `[1, System architecture]` `[2, p. 2, Table 1]` `[9, Figure 2 caption]` `[10, TPU_V5P branch]` |
| 内存类型与容量 | 当前Cloud页95GiB；Google论文96GiB HBM2E，6 stacks | 两份一手资料存在1GiB差异；原样并列 | `[1, System architecture]` `[2, pp. 2, 6, Table 1 and Figure 3]` |
| 内存带宽 | 2,765GB/s | per-chip；原文未说明读写方向和有效负载 | `[1, System architecture]` `[2, p. 2, Table 1]` |
| 主机接口 | CPU host经PCIe连接，开发者教程估算约16GB/s/TPU；接口代际、lane数与保证带宽未公开 | 教程DCN约6.25GB/s/TPU是host网络分摊量，不能写成芯片NIC | `[2, p. 5, SparseCore]` `[11, TPU Networking; TPU specs]` |
| 设备互联端点 | 6条ICI link，每条100GB/s per direction；当前规格表给1,200GB/s per-chip双向聚合带宽 | 6×100GB/s×两个方向与当前聚合口径一致 | `[2, pp. 2, 7, Table 1 and footnote 4]` `[1, System architecture]` |
| 内存访问语义 | SparseCore利用HBM和ICI形成flat、globally addressable的系统级内存空间；ICI DMA与本地HBM DMA类似但仅支持push/write | 远程可寻址依赖多芯片系统和软件同步，不等同于cache coherence | `[2, pp. 4-5, SparseCore]` |
| 跨设备集合通信能力 | SparseCore可卸载AllReduce、AllGather、ReduceScatter和Broadcast等操作；ICI支持芯片间直接DMA | 公开为训练TPU演进中的硬件路径，未给v5p单芯片独立吞吐 | `[2, pp. 4-5, SparseCore]` |
| 功耗 | TDP未公开；Google fleet实测平均331W/TPU（不含host） | 331W是生产fleet的per-TPU平均值，不是TDP或峰值；整机平均2,176W不得下放 | `[7, p. 2, Table 1]` |
| 形态与散热 | 官方per-chip比较配置，package液冷；实际Cloud最小为四芯片host/VM | 单芯片不是独立零售卡或当前最小租用单元 | `[1, Configurations]` `[2, pp. 2, 6, Table 1 and Figure 3]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | 每个v5p host有4 chips；64-chip `4×4×4` cube及更大slice形成完整3D torus；Pod有8,960 chips，最大单slice为6,144 chips | 本卡只保留6条ICI link和per-chip双向带宽；Pod峰值、HBM容量、bisection和DCN不下放 | `[1, System architecture; Configurations; VM, host and slice properties]` `[2, p. 2, Table 1]` |
| Scale-out | 当前规格表按chip归一化列50Gbps DCN；单slice可到6,144 chips，Multislice可扩到18,432 chips | 50Gbps是Cloud系统分配口径，不足以证明芯片集成独立NIC；Multislice经数据中心网络连接多个slice | `[1, System architecture and Configurations]` `[3, Multislice versus single slice]` |
| 系统可靠性 | 一个cube及以上v5p slice默认启用ICI resiliency，可绕过光链路或OCS故障，但会暂时降低ICI性能 | cube内铜链路和cube间光链路的容错是系统特性 | `[1, Cloud TPU ICI resiliency]` |
| 相关系统 | `ct5p-hightpu-4t` VM/host有4 chips、208 vCPU、448GB RAM、2个NUMA node和200Gbps NIC | CPU、RAM、NUMA与NIC不是chip内资源，也不能除以4写成per-chip属性 | `[1, VM, host and slice properties]` |

### 6.1 相同端点带宽下的拓扑选择

v5p部分slice支持twisted torus（改变边界回环连接的环面拓扑），要求各维长度等于最短维或为其两倍。官方以4×4×8为例给出约70%的理论二分带宽增加，4×8×8约40%，相对于相同形状的普通torus；端点规格仍是每芯片1,200GB/s双向聚合。优势来自负载均衡、路径长度和全局通信布局，不能改写为单芯片带宽增加或所有模型同幅加速。官方要求按LLM的实际并行策略比较两种拓扑。[1, Twisted torus topologies]

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| HBM容量 | 一手资料冲突 | 当前Cloud规格表写95GiB；Google跨代论文Table 1写96GiB HBM2E | 两种原始口径并列，不猜测是否为保留容量或实现/云配置差异 |
| FP8/BF8标签 | 一手资料用词不同 | 当前Cloud规格表写FP8 459TFLOPS；Google跨代论文写BF8 459TFLOPS | 保留两种标签；官方Ironwood发布文标为emulated，不把此峰值解释为原生FP8执行 `[9, Figure 2 caption]` |
| HBM带宽历史页面 | 官方页面版本冲突 | 当前2026-08-11英文页写2,765GB/s；较早缓存页面曾写2,575GiB/s | 采用当前页且由Google论文2,765GB/s交叉确认，保留旧值为页面历史口径 |
| JAX硬件模型的HBM值 | 与产品规格不同 | JAX使用103×10⁹B全芯片容量及2,460GB/s带宽，产品页为95GiB及2,765GB/s | 只用JAX解释开发模型，不将它定义为实测带宽，也不替换产品规格主值 |
| 工艺、die和chiplet | 未公开 | Google作者资料将die size与technology标为N.A.，package照片未给chiplet说明 | 不从照片、相邻代际或第三方资料补值 |
| 时钟、主机接口细节与TDP | 额定参数未公开；开发估算另列 | 产品页/论文无保证时钟或接口lane数；scaling book约1.75GHz和PCIe约16GB/s/TPU | 不将开发估算或331W fleet平均值当作保证规格和TDP |
| VMEM分配与Sparse Vector Memory总量 | VMEM按核分配已公开，稀疏存储须分层 | JAX给64MiB VMEM/TC及512KiB局部VMEM/tile；Pallas另列SC共享SPMEM，跨代论文用2.5MiB描述通用Sparse Vector Memory | 保留两类原文，不把2.5MiB覆盖v5p专属tile容量，不估算共享SPMEM总量 |
| per-chip与系统聚合值 | 对象层级不同 | 同页并列chip、VM、host、cube、slice和Pod数据 | 只有明确per-chip或per-TPU字段进入SKU配置 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Google Cloud，*TPU v5p* | 当前官方产品与系统文档 | per-chip规格、host/VM、slice、Pod、ICI resiliency及当前配置 | <https://docs.cloud.google.com/tpu/docs/v5p> |
| `[2]` | Norman P. Jouppi等（Google），*Google's Training Supercomputers from TPU v2 to Ironwood: Architectural Stability, Scale, Resilience, Power Efficiency, and Sustainability Across Five Generations*，2026 | Google厂商团队跨代架构论文 | TensorCore/MXU、VLIW、VMEM/DMA、SparseCore、HBM/package、ICI和系统边界 | [本地PDF](../../../原始资料/论文/Google_TPU/01_厂商直接架构论文/2026_TPUv2_to_Ironwood_Five_Generations.pdf) |
| `[3]` | Google Cloud，*TPU architecture* | 当前官方通用系统文档 | slice、Pod和Multislice边界 | <https://docs.cloud.google.com/tpu/docs/system-architecture-tpu-vm> |
| `[4]` | Google Cloud，*Enabling next-generation AI workloads: Announcing TPU v5p and AI Hypercomputer*，2023-12-06 | 官方发布文章 | 首次公开、开放申请、训练/serving定位和产品目标 | <https://cloud.google.com/blog/products/ai-machine-learning/introducing-cloud-tpu-v5p-and-ai-hypercomputer> |
| `[5]` | Google Cloud，*What's new with Google Cloud's AI Hypercomputer architecture*，2024-04-09 | 官方GA公告 | v5p与GKE/多host serving GA | <https://cloud.google.com/blog/products/compute/whats-new-with-google-clouds-ai-hypercomputer-architecture> |
| `[6]` | Google Cloud，*Cloud TPU pricing* | 当前官方定价页 | v5p仍按chip-hour提供 | <https://cloud.google.com/tpu/pricing> |
| `[7]` | Ian Schneider等（Google），*Life-Cycle Emissions of AI Hardware: A Cradle-To-Grave Approach and Generational Trends*，2025 | Google作者一手硬件生命周期论文 | die/工艺未披露状态与fleet实测功耗 | [本地PDF](../../../原始资料/论文/Google_TPU/03_系统与性能补充/2025_Life_Cycle_Emissions_AI_Hardware.pdf) |
| `[9]` | Amin Vahdat，*Ironwood: The first Google TPU for the age of inference*，2025-04-23 更新 | 官方发布文 | Figure 2 图注中的v5p FP8模拟执行条件 | <https://blog.google/innovation-and-ai/infrastructure-and-cloud/google-cloud/ironwood-tpu-age-of-inference/> |
| `[10]` | The JAX Authors，*TPU hardware information*，2026-09-17快照 | 官方JAX源码 | v5p每核存储、整数吞吐、SparseCore专属参数及Megacore模式 | [本地源码](../../../原始资料/网页快照/Google/JAX/2026-09-17/jax-info-source.py)，<https://github.com/jax-ml/jax/blob/main/jax/_src/tpu_info.py> |
| `[11]` | Jacob Austin等，*How to Think About TPUs*，2026-09-17快照 | Google DeepMind作者的JAX架构教程 | v5p寄存器/VMEM端口、DMA控制和近似时钟/接口带宽 | [本地原文](../../../原始资料/网页快照/Google/JAX/2026-09-17/scaling-book-tpus.md)，<https://jax-ml.github.io/scaling-book/tpus/> |
| `[12]` | The JAX Authors，*Pallas: TPU Details*，2026-09-17快照 | 官方编程文档 | SMEM、向量布局和多核执行映射 | [本地原文](../../../原始资料/网页快照/Google/JAX/2026-09-17/jax-details.rst)，<https://docs.jax.dev/en/latest/pallas/tpu/details.html> |
| `[13]` | The JAX Authors，*SparseCore Kernel Writing*，2026-09-17快照 | 官方编程文档 | tile局部与SC共享存储及32-bit gather/scatter约束 | [本地原文](../../../原始资料/网页快照/Google/JAX/2026-09-17/jax-sparsecore.md)，<https://docs.jax.dev/en/latest/pallas/tpu/sparsecore.html> |

## 9. 完成检查

- [x] SKU身份和厂商定位的主语已经固定
- [x] Core、die/chiplet、package、SKU和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、统一内存、一致性和远程访问的管理语义没有混写
- [x] 封装内D2D互联与HBM、设备互联和系统聚合带宽已经分开
- [x] SKU互联端点与系统拓扑、域大小和聚合带宽已经分开
- [x] 系统级互联上下文只在相关时填写
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：Google Cloud TPU v5p单芯片的主语、两个TensorCore、八个128×128 MXU、四个SparseCore、128MiB VMEM、六个HBM2E stack、459TFLOPS BF16与低精度峰值、2,765GB/s HBM带宽、六条ICI link和1,200GB/s双向带宽已由Google一手资料固定。95/96GiB与FP8/BF8按来源并列，331W仅作为不含host的fleet实测平均值；四芯片VM/host、cube、slice、Pod和Multislice没有下放。JAX补充了每核64MiB VMEM、SparseCore tile局部存储和开发估算；工艺、die/chiplet、主机接口代际与lane数、保证时钟和TDP仍保留缺口。
