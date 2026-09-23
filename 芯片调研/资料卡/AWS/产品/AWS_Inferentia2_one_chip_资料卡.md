# AWS Inferentia2 one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡采用一颗第二代AWS Inferentia2 chip/NeuronDevice作为正式比较对象。该芯片包含两个NeuronCore-v2（NCv2，第二代Neuron计算核）、32GiB HBM、32个DMA engine、6个CC-Core和2个NeuronLink-v2接口。`inf2.xlarge`与`inf2.8xlarge`各配置一颗芯片；6-chip与12-chip实例的聚合资源不下放。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Amazon Web Services（AWS） | AWS自研Inferentia2 | `[1, opening]` |
| 产品家族 | 第二代AWS Inferentia | 与第一代Inferentia和共享NCv2的Trainium1区分 | `[1, opening]` `[5, opening]` |
| 完整 SKU | AWS Inferentia2 one chip | 官方未公开常规板卡料号，采用一颗chip/NeuronDevice口径 | `[1, chip table]` |
| 对象形态 | 一颗Cloud inference accelerator chip/package | 单裸片、chiplet数量与物理package构造未公开 | `[1, chip architecture diagram and table]` |
| 架构代际 | 2个NeuronCore-v2 | NCv2也用于Trainium1，但Inferentia2的链路数和产品配置独立 | `[2, device overview]` |
| 发布与可用状态 | 2022-11-29 Preview；2023-04-13 GA；当前Inf2产品页仍列出1/6/12-chip实例 | Preview、GA与当前服务状态分开 | `[7, page date and Inf2 announcement]` `[6, page date and opening]` `[5, Product details]` |
| 厂商定位 | 专门面向大规模DL与generative AI inference | 不是training产品；不扩大成硬件绝对不能训练的结论 | `[1, opening]` `[5, Why Amazon EC2 Inf2 Instances?]` |
| 目标 workload | LLM、vision transformer、text summarization、code generation、图像/视频生成、speech recognition等 | 产品定位，不把模型参数量写成芯片属性 | `[5, opening]` |
| 产品目标 | 以更大模型、分布式inference、较高内存带宽和直接chip-to-chip通信改善吞吐与延迟 | 相对Inf1的实例成绩不写入芯片峰值 | `[5, opening and NeuronLink interconnect]` |

本卡包含：每芯片两个NCv2、Tensor/Vector/Scalar/GpSimd引擎、190TFLOPS FP16/BF16/cFP8/TF32、47.5TFLOPS FP32、380TOPS INT8、32GiB HBM、DMA、CC-Core和NeuronLink-v2。

本卡不包含：Inf2实例的vCPU、host RAM、EFA/ENA、EBS、实例价格、实例聚合算力与跨实例网络。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | NeuronCore-v2，含Tensor、Vector、Scalar、GpSimd与Sync Engine | 与AWS Trainium1共享 | 复用[Inferentia2架构卡](../架构/AWS_Inferentia2_架构卡.md)，本卡补Inferentia2的两核实现量 | `[2, NeuronCore-v2 Compute Engines]` |
| die | 未公开 | 未证明单裸片或chiplet组成 | 不从逻辑框图或相邻产品推断 | `[1, chip architecture diagram]` |
| package | 一颗Inferentia2 chip/device，连接32GiB HBM | Inferentia2实现共享 | 复用[芯片实现卡](../封装/AWS_Inferentia2_芯片实现资料卡.md)，本卡改为正式SKU口径 | `[1, chip table]` |
| 产品配置 | AWS Inferentia2 one chip | 不适用 | 正式比较单位；`inf2.xlarge`和`inf2.8xlarge`各有1颗 | `[4, Inf2 Architecture table]` `[5, Product details]` |
| 相关系统 | 1/6/12-chip Inf2实例 | 多种实例规模 | 只用于划定NeuronLink与host资源边界 | `[4, Inf2 Architecture table]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 异构执行与调度 | 每个NCv2有Tensor、Vector、Scalar、GpSimd四个独立sequencer和instruction stream，可异步并行；Sync Engine触发DMA，硬件semaphore与compiler处理依赖同步 | 单个NCv2；完整芯片有2个 | `[2, NeuronCore-v2 Compute Engines]` |
| TensorEngine | 128×128 PE systolic array；每个 NCv2 的 TensorE 为 92 TFLOPS BF16/FP16/TF32/cFP8、23 TFLOPS FP32；两核纯 Tensor 资源加总为 184／46 TFLOPS | TensorE 数据路径 2×128 input、1×128 output，频率 2.8 GHz；184／46 为按 NKI 每核值推导，不能替代芯片页未解释执行路径构成的 190／47.5 headline | `[2, device overview; Tensor Engine: Data Types; engine width/frequency table]` `[1, Compute row]` |
| VectorEngine | 128个parallel vector lanes，面向reduction、LayerNorm、pooling等；2.3TFLOPS FP32 | 数据路径128 input/output，频率1.12GHz；算术内部以FP32执行并自动cast | `[2, Vector Engine and engine width/frequency table]` `[3, VectorEngine paragraph]` |
| ScalarEngine | 面向element-wise和标量运算；2.9TFLOPS FP32 | 数据路径128 input/output，频率1.4GHz | `[3, ScalarEngine paragraph]` `[2, engine width/frequency table]` |
| GpSimd Engine | 8个可编程512-bit vector processor，可执行通用C code和custom operator；每个processor有64KB local data RAM | 引擎频率1.4GHz；不等同于8个独立NeuronCore | `[3, GPSIMD paragraph]` `[2, GpSimd Engine and engine width/frequency table]` |
| 数值与累加路径 | TensorEngine接受cFP8/FP16/BF16/TF32/FP32/INT8输入，输出FP32/INT32；PSUM的matmul accumulation固定用FP32 | cFP8编码、INT8饱和、完整舍入和输出规则未全部公开；支持RNE与stochastic rounding | `[3, TensorEngine and rounding paragraphs]` `[2, Near-memory accumulation in PSUM]` |
| 局部存储 | 每个NCv2有24MiB SBUF主数据scratchpad和2MiB PSUM累加buffer，均为128 partitions；PSUM每partition 8 banks | SBUF/PSUM由software/compiler管理，不是hardware cache | `[2, NeuronCore-v2 Compute Engines and memory hierarchy]` |
| 稀疏与专用单元 | 未找到结构化稀疏Tensor path或专用MoE router；chip级有6个CC-Core用于collective communication | CC-Core不是TensorCore稀疏翻倍资源 | `[2, device overview]` |

### 3.1 矩阵分块、局部接口与并行限制

NKI 对 Trainium1 和 Inferentia2 给出共同的 NCv2 执行机制。下列容量、接口和启动成本均属于单个 NCv2，不能把两核局部空间合并解释为共享 cache。`partition` 是 SRAM 的并行分区，`bank` 是 PSUM 分区内可分别承接矩阵结果的存储单元。`[2, NeuronCore-v2 Compute Engines; Data Movement]`

| 机制 | 公开事实 | 条件和含义 | 来源 |
|---|---|---|---|
| 矩阵输入与分块 | LoadStationary 先把固定输入载入 TensorEngine 内部，MultiplyMoving 使流动输入与之相乘；stationary[K,M] 与 moving[K,N] 执行 stationary.T @ moving | K、M 最大为 128，N 最大为 512；K 更大时分块并累加到同一 PSUM 位置，N 的限制来自单 bank 输出容量 | `[2, Tensor Engine: Layout and Tile Size]` |
| 矩阵流水与预装 | 复用已加载 stationary 时，BF16/FP16/TF32/cFP8 连续 MultiplyMoving 的近似启动间隔为 max(N,64) 个 TensorEngine 周期；FP32 成本约为四倍。background LoadStationary 允许下一块固定输入预装与当前计算重叠 | 启动间隔不等同于单指令完成延迟；LoadStationary 本身也可能限制矩阵吞吐 | `[2, Tensor Engine: Performance Consideration]` |
| PSUM 分 bank 累加 | 每 partition 为 16 KiB，分八个 bank，每 bank 容纳 512 个 32-bit 元素；TensorEngine 可控制逐元素 read-accumulate-write | 最多八组 matmul accumulation group 可并存，允许下一组矩阵计算与前一组结果处理重叠；Vector/Scalar 把 PSUM 当普通 SRAM 访问，不能发起这种累加 | `[2, Near-memory accumulation in PSUM]` |
| SRAM 接口峰值与步长 | 每条 tensor 读或写接口在 1.4 GHz 下最多 128 elements/cycle；fastest free 维 stride 小于 16 B 时可达该峰值，大于 16 B 时吞吐减半；每次访问启动约有 60 周期开销 | 单接口、单方向；按 FP32 换算为 716.8 GB/s，按 FP16/BF16 换算为 358.4 GB/s，均为 128×元素字节数×1.4 GHz，不是整个 SRAM 的聚合带宽；原文未明确恰好 16 B 的边界 | `[2, Accessing SBUF/PSUM tensors using compute engines: Performance Consideration；本行换算]` |
| 多引擎访问限制 | Vector 与 GpSimd 不能同时访问 SBUF；Vector 与 Scalar 不能同时访问 PSUM，编译器将冲突访问串行化 | 允许的 Tensor+Vector+Scalar 或 Tensor+GpSimd+Scalar 组合可同时保持各自 SBUF 接口峰值；PSUM 允许 Tensor+Vector 或 Tensor+Scalar；独立指令流不保证任意组合都能无争用执行 | `[2, Data Movement; Accessing SBUF/PSUM tensors using compute engines: Concurrent accesses]` |
| GpSimd 局部 RAM 与连接 | 每 processor 的 64 KB TCM 为 512-bit 数据宽度、3-cycle 访问延迟；每 processor 固定连接 16 个 SBUF partition，读和写接口分别最多 512 bit/cycle | 八个 processor 覆盖 128 partition；接口峰值不能绕过 Vector/GpSimd 的 SBUF 共享限制 | `[2, GpSimd Engine: Memory Hierarchy and Fig. 54]` |
| DMA scatter-gather | 一次 transfer 收集源 buffer 列表，再散写目的 buffer 列表；每个 buffer 内存连续，一个 engine 同时处理一个 transfer | 指南建议每 partition 连续数据达到 4 KiB 或以上并尽量使用全部 128 partition，以摊薄 buffer/transfer 开销；这不是合法传输的最小尺寸 | `[2, Data movement between HBM and SBUF using DMAs]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算与专用单元 | 2个NCv2、32个DMA engine、6个CC-Core | 单颗Inferentia2 chip/device | `[2, device overview]` |
| 片上存储 | 每个NCv2有24MiB SBUF、2MiB PSUM和8×64KB GpSimd local RAM | 完整芯片有2个NCv2；未确认是否还有共享cache或片上SRAM | `[2, NeuronCore-v2 Compute Engines and GpSimd memory hierarchy]` |
| 片内互联 | 未公开完整拓扑 | 文档给出engine到SBUF/PSUM和DMA路径，但未给chip级NoC、coherence或remote-core访问语义 | `[2, NeuronCore-v2 diagram and memory hierarchy]` |
| 内存控制器与PHY | 2个HBM stack，总容量32GiB | controller、PHY宽度、HBM代际与stack高度未公开 | `[2, device overview]` |
| 工艺与物理规模 | 只称advanced silicon process，具体未公开 | 未找到process node、die area、晶体管数或时钟电压范围 | `[5, Meet your sustainability goals]` |
| 封装组成 | 未公开 | 单裸片/chiplet数量、interposer、基板与package尺寸均未找到；2个HBM stack是逻辑/实现数量，不足以证明封装方式 | `[2, device overview and diagram]` |
| 封装内互联 | 未公开 | 没有足够证据证明compute chiplet或D2D | `[1, chip architecture diagram]` |
| RAS与安全 | 未公开芯片级ECC、重放、隔离或secure boot细节 | 不把Nitro平台能力下放 | `[1, full page]` `[5, full page]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 2个NeuronCore-v2、32个DMA engine、6个CC-Core | 单颗Inferentia2 | `[1, chip table]` `[2, device overview]` |
| 时钟 | Tensor 2.8GHz；Vector 1.12GHz；Scalar和GpSimd各1.4GHz | engine clock，不存在一个公开的统一chip clock | `[2, engine width/frequency table]` |
| 理论峰值 | 190TFLOPS FP16/BF16/cFP8/TF32；47.5TFLOPS FP32；380TOPS INT8 | per-chip advertised peak；未说明structured-sparse条件 | `[1, Compute row]` |
| 纯 Tensor 派生峰值 | BF16/FP16/TF32/cFP8 为 184 TFLOPS；FP32 为 46 TFLOPS | 按两个 NCv2×每核 92／23 推导；普通矩阵路径，不含结构化稀疏倍数；保留每核原报取整条件，供同路径比较，与上一行芯片宣传值并列 | `[2, device overview; Tensor Engine: Data Types；本行资源加总]` |
| 内存类型与容量 | 2个HBM stack，32GiB/chip；产品页写32GB HBM | HBM代际未公开；官方页面存在GB/GiB单位差异 | `[1, Device Memory row]` `[2, device overview]` `[5, high-bandwidth accelerator memory]` |
| 内存带宽 | 当前技术页820GiB/s；NKI实现页和产品聚合口径为820GB/s | per-chip；官方未解释二进制/十进制标签差异 | `[1, Device Memory row]` `[2, device overview]` |
| DMA | 32个DMA engine；chip级额定1TB/s DMA bandwidth，支持inline compression/decompression | 每个NCv2有16个DMA，每engine局部峰值27GiB/s；1TB/s的方向与有效负载未公开 | `[1, Data Movement row]` `[2, device overview and DMA section]` |
| 主机接口 | PCIe，具体代际、lane数和host-device带宽未公开 | profile/instance中出现PCIe不足以证明物理配置 | `[2, device diagram]` |
| 设备互联端点 | 2个NeuronLink-v2接口；当前Inf2架构表按多芯片实例列192GiB/s/chip | chip-to-chip direct interconnect；方向、端口速率和有效负载未公开 | `[2, device overview]` `[4, Inf2 Architecture table]` |
| 内存访问语义 | HBM存model state；DMA在HBM与本地SBUF之间异步搬运并可与compute并行，PSUM保存Tensor累加/结果 | 未公开cache coherence、unified memory或transparent remote HBM | `[1, Device Memory row]` `[2, memory hierarchy]` |
| 跨设备集合通信能力 | 6个CC-Core和NeuronLink-v2支持AllReduce、AllGather等collective，允许模型分片绕过host CPU传输 | 未公开单CC-Core吞吐、调度或与两条link的绑定关系 | `[2, device overview]` `[4, Inf2 Architecture]` `[5, NeuronLink interconnect]` |
| 功耗 | TDP、平均与峰值功耗均未公开 | 50%更高perf/W是Inf2实例相对可比实例的宣传，不能换算为per-chip瓦数 | `[5, Meet your sustainability goals]` |
| 形态与散热 | Cloud accelerator chip；散热形式未公开 | 不是零售卡；两种实际one-chip实例均无inter-chip interconnect | `[5, Product details]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| 单芯片部署 | `inf2.xlarge`与`inf2.8xlarge`各1 chip/32GB accelerator memory，inter-chip栏为N/A | 证明one-chip是实际Cloud配置，不是从最大实例归一化 | `[4, Inf2 Architecture table]` `[5, Product details]` |
| Scale-up | `inf2.24xlarge`有6 chips，`inf2.48xlarge`有12 chips；NeuronLink-v2按chip列192GiB/s，可执行AllReduce/AllGather | 1,140/2,280TFLOPS和192/384GiB HBM是实例聚合值，不进入芯片字段 | `[4, Inf2 Architecture table]` |
| 实例网络与厂商“scale-out”措辞 | 最大实例有100Gbps网络，单芯片实例最高15或25Gbps；AWS把单个多芯片Inf2内的模型分片称为scale-out distributed inference | NeuronLink证据只支持6/12-chip instance内通信；当前四种Inf2均无EFA，不能写成跨instance/server fabric | `[5, opening and Product details]` `[6, NeuronLink v2]` `[8, Network specifications: Inf2]` |
| 相关系统 | Inf2有1/6/12-chip四种实例，最大实例有192 vCPU和768GiB host RAM | host资源与9.8TB/s实例内存带宽不下放 | `[5, Product details and high-bandwidth accelerator memory]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| chip、NeuronDevice与Inf2 | 官方术语跨层 | Inferentia2是chip/NeuronDevice，Inf2是含1/6/12 chips的EC2 instance | 正式主语固定为一颗Inferentia2 chip/device |
| HBM容量与带宽单位 | 一手资料单位不同 | 当前技术页32GiB、820GiB/s；NKI页32GiB、820GB/s；产品页32GB | 原单位并列，不静默换算 |
| NeuronLink-v2带宽 | 版本化页面口径变化 | 早期v2.9.1表写384GiB/s/chip；较新Inf2架构表与当前产品页写192GiB/s或192GB/s | 采用较新192口径，并保留历史差异；不猜测单向/双向原因 |
| NCv2与chip峰值 | 两类来源计数差异未解释 | NKI 给每核 TensorE 92 TFLOPS BF16/FP16/TF32/cFP8、23 TFLOPS FP32；两核纯 Tensor 派生值为 184／46，芯片页另报 190／47.5 | 保留两者；同路径矩阵比较可使用有公式的 184／46，不能声称它改正了官方 headline，也不由差值推断其他引擎贡献 |
| DMA headline与单engine峰值 | 统计条件不同 | 芯片页写1TB/s DMA；NKI页写每个DMA engine 27GiB/s、每芯片32 engines | 分别保留，不用32×27推翻或重算headline |
| NCv2与产品边界 | 架构共享但实现不同 | Trainium1和Inferentia2均用NCv2，后者有2条NeuronLink-v2，Trainium1有4条 | 复用Core机制，产品链路数量不互相下放 |
| 工艺、die/package与功耗 | 未公开 | 当前Neuron硬件页、NKI指南、AWS产品页和GA文章 | 不采用第三方推测，不从实例perf/W反推瓦数 |
| HBM与片上SRAM管理 | 已公开主要路径，仍不完整 | 确认HBM、SBUF、PSUM与DMA；cache coherence、远端HBM和页迁移未公开 | 不写成统一内存或hardware cache |
| 主机接口与RAS | 未公开完整规格 | 只确认逻辑PCIe路径，没有代际/lane/带宽或芯片级RAS细节 | 保持缺失 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | AWS Neuron，*Inferentia2 Architecture* | 当前官方芯片架构文档 | 两个NCv2、per-chip峰值、HBM、DMA、NeuronLink与programmability | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.31.1/about-neuron/arch/neuron-hardware/inferentia2.html> |
| `[2]` | AWS Neuron，*Trainium/Inferentia2 Architecture Guide for NKI* | 官方底层硬件指南 | NCv2引擎、SBUF/PSUM、DMA、CC-Core、HBM stack与NeuronLink数量 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/nki/guides/architecture/trainium_inferentia2_arch.html> |
| `[3]` | AWS Neuron，*NeuronCore-v2 Architecture* | 官方Core架构文档 | 各引擎吞吐、数据类型、GpSimd与动态执行 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.27.0/about-neuron/arch/neuron-hardware/neuron-core-v2.html> |
| `[4]` | AWS Neuron，*Amazon EC2 Inf2 Architecture* | 官方系统架构文档 | 1/6/12-chip实例、per-chip NeuronLink与系统边界 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.27.0/about-neuron/arch/neuron-hardware/inf2-arch.html> |
| `[5]` | AWS，*Amazon EC2 Inf2 Instances* | 当前官方产品页 | 当前状态、inference定位、HBM和1/6/12-chip配置 | <https://aws.amazon.com/ec2/instance-types/inf2/> |
| `[6]` | AWS，*Amazon EC2 Inf2 Instances ... Are Now Generally Available*，2023-04-13 | 官方GA文章 | Preview回顾、GA日期、芯片创新与实例边界 | <https://aws.amazon.com/blogs/aws/amazon-ec2-inf2-instances-for-low-cost-high-performance-generative-ai-inference-are-now-generally-available/> |
| `[7]` | AWS，*AWS Announces Three Amazon EC2 Instances Powered by New AWS-Designed Chips*，2022-11-29 | 官方Preview发布稿 | Inf2/Inferentia2首次公开与原始定位 | <https://press.aboutamazon.com/2022/11/aws-announces-three-amazon-ec2-instances-powered-by-new-aws-designed-chips> |
| `[8]` | AWS EC2，*Specifications for Amazon EC2 accelerated computing instances* | 当前官方实例规格 | one-chip accelerator memory与Inf2无EFA的系统边界 | <https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html> |

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

复核结论：AWS Inferentia2 one chip的主语已经固定为一颗包含两个NeuronCore-v2的chip/NeuronDevice。190TFLOPS FP16/BF16/cFP8/TF32、47.5TFLOPS FP32、380TOPS INT8、32GiB HBM、32个DMA engine、6个CC-Core和2个NeuronLink-v2接口均有AWS一手资料支持；1/6/12-chip实例与host资源没有下放。process、die/package构造、HBM代际、主机PCIe配置、绝对功耗和芯片级RAS保持缺失。
