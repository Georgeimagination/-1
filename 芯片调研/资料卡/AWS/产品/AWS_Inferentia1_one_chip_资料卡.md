# AWS Inferentia1 one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-08-25

本卡采用一颗第一代AWS Inferentia chip作为正式比较对象。AWS文档也把该对象称为Inferentia device或NeuronChip；它包含四个NeuronCore-v1（NCv1，第一代Neuron计算核）、8GiB device DRAM和NeuronLink-v1。`inf1.xlarge`与`inf1.2xlarge`确实各配置一颗芯片，4-chip与16-chip实例的聚合资源不下放到本卡。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Amazon Web Services（AWS） | AWS自研Inferentia | `[1, page title and opening]` |
| 产品家族 | 第一代AWS Inferentia | 与Inferentia2区分 | `[2, Optimized for high throughput and low latency]` |
| 完整 SKU | AWS Inferentia1 one chip | 官方未公开常规板卡料号，采用一颗chip/device口径 | `[1, Inferentia Architecture]` `[3, Features: Powered by AWS Inferentia]` |
| 对象形态 | 一颗Cloud accelerator chip/package | 单裸片、chiplet数量和package构造未公开 | `[1, Inferentia Architecture]` |
| 架构代际 | 4个NeuronCore-v1 | 每个NCv1含Tensor、Vector、Scalar三条执行路径 | `[1, Inferentia Architecture]` `[4, NeuronCore-v1 Architecture]` |
| 发布与可用状态 | 2018-11-28宣布；2019-12-03随EC2 Inf1 GA；当前Inf1产品页仍列出1/4/16-chip实例 | 宣布、云服务GA与当前状态分开 | `[5, page date and opening]` `[6, page date and opening]` `[3, Product details]` |
| 厂商定位 | 专门面向低成本、高吞吐、低延迟ML inference | 不是training芯片 | `[2, Why Inferentia?]` `[3, Why Amazon EC2 Inf1 Instances?]` |
| 目标 workload | search、recommendation、computer vision、speech recognition、NLP、personalization和fraud detection | 产品定位，不把具体模型或客户成绩写成芯片属性 | `[3, opening workload list]` `[6, opening]` |
| 产品目标 | 以small-batch、real-time inference的吞吐、延迟和成本为重点 | 相对实例性价比宣传不进入芯片峰值字段 | `[3, Up to 2.3x higher throughput and Extremely low latency]` |

本卡包含：每芯片四个NCv1、Tensor/Vector/Scalar引擎、64TFLOPS FP16/BF16、128TOPS INT8、8GB或8GiB DDR4/device DRAM、50GiB/s device-memory带宽，以及NeuronLink-v1端点。

本卡不包含：Inf1实例的vCPU、host RAM、EFA/ENA、EBS、实例价格、实例聚合算力，以及跨实例网络。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | NeuronCore-v1，含Tensor、Vector、Scalar引擎与software-managed SRAM | 第一代Inferentia芯片共享 | 复用[Inferentia1架构卡](../架构/AWS_Inferentia1_架构卡.md)，本卡补齐四核实现量 | `[4, NeuronCore-v1 Architecture]` |
| die | 未公开 | 未证明单裸片或chiplet组成 | 不从产品名或实例图推断 | `[1, Inferentia Architecture]` |
| package | 一颗Inferentia chip/device，含4个NCv1和8GiB DRAM端点 | 第一代Inferentia实现共享 | 复用[芯片实现卡](../封装/AWS_Inferentia1_芯片实现资料卡.md)，本卡改为正式SKU口径 | `[1, Inferentia Architecture]` |
| 产品配置 | AWS Inferentia1 one chip | 不适用 | 正式比较单位；`inf1.xlarge`和`inf1.2xlarge`各有1颗 | `[3, Product details]` |
| 相关系统 | 1/4/16-chip Inf1实例 | 多种实例规模 | 只用于划定NeuronLink与host资源边界 | `[7, Inf1 Architecture table]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 异构执行路径 | 每个NCv1是独立异构计算单元，包含TensorEngine、VectorEngine和ScalarEngine | 单个NCv1；完整芯片有4个 | `[4, NeuronCore-v1 Architecture]` |
| TensorEngine | 采用power-optimized systolic array，面向GEMM、CONV、reshape和transpose；每个NCv1提供16TFLOPS FP16/BF16 | 阵列尺寸、时钟、发射与pipeline未公开 | `[4, TensorEngine paragraph]` |
| VectorEngine | 面向axpy、Layer Normalization和pooling等多输入相关向量运算，可执行256 floating-point operations/cycle | 支持FP16、BF16、FP32、INT8、INT16和INT32；未公开vector宽度与时钟 | `[4, VectorEngine paragraph]` |
| ScalarEngine | 面向GELU、sigmoid、exp等element-wise计算，可执行512 floating-point operations/cycle | 支持FP16、BF16、FP32、INT8、INT16和INT32；名称不表示串行单lane | `[4, ScalarEngine paragraph]` |
| 数值与累加路径 | TensorEngine接受FP16/BF16/INT8输入，输出FP32/INT32；芯片级峰值为64TFLOPS FP16/BF16和128TOPS INT8 | 公开的是输出/累加语义，未给物理accumulator宽度、舍入和饱和细节 | `[4, TensorEngine paragraph]` `[1, Inferentia Architecture]` |
| 片上存储 | 每个NCv1有compiler-managed、software-managed on-chip SRAM，用于数据局部性与prefetch；术语页将主存储称为State Buffer（SBUF），并列出支持TensorEngine近存累加的Partial Sum Buffer（PSUM） | SBUF/PSUM适用于NCv1及以后，但v1容量、bank、带宽和共享方式未公开；不是硬件cache | `[4, opening]` `[9, State Buffer and Partial Sum Buffer]` |
| 稀疏与专用单元 | 未找到第一代Inferentia的结构化稀疏单元、MoE router、Top-K或独立collective engine | NeuronCore Pipeline是跨核/跨芯片执行技术，不等于专用MoE硬件 | `[1, NeuronLink row]` `[4, full page]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 4个NeuronCore-v1；每个各含Tensor、Vector、Scalar引擎 | 单颗Inferentia1 chip/device | `[1, Inferentia Architecture]` `[4, opening]` |
| 片上存储 | 各NCv1有software-managed SBUF/PSUM；AWS产品页称有大量on-chip memory | 未公开per-core或per-chip容量，不把instance host RAM写入 | `[2, Optimized for high throughput and low latency]` `[4, opening]` `[9, State Buffer and Partial Sum Buffer]` |
| 片内互联 | 未公开完整结构 | 当前术语页称NeuronLink-v1连接Inferentia device内的NeuronCore，但没有给片内拓扑、协议或带宽 | `[9, NeuronLink-v1]` |
| 内存控制器与PHY | 连接8GB或8GiB DDR4/device DRAM，额定带宽50GiB/s | controller数量、通道宽度、数据率与ECC未公开 | `[1, Device Memory row]` `[2, Optimized for high throughput and low latency]` |
| 工艺与物理规模 | 未公开 | 未找到process node、die area、晶体管数、时钟或电压 | `[1, full page]` `[4, full page]` |
| 封装组成 | 未公开 | 单裸片/chiplet数量、基板、interposer、DRAM封装关系和package尺寸均未找到 | `[1, full page]` |
| 封装内互联 | 未公开 | 没有足够证据证明D2D或chiplet互联；NeuronLink-v1在不同官方页面分别按核间和device-to-device口径描述 | `[7, Inf1 Architecture]` `[9, NeuronLink-v1]` |
| RAS与安全 | 未公开芯片级ECC、重放、隔离或secure boot细节 | Nitro System是实例/平台能力，不下放为Inferentia芯片能力 | `[3, Built on AWS Nitro System]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 4个NeuronCore-v1 | 每个NCv1有1套Tensor/Vector/Scalar引擎 | `[1, Compute row]` `[4, opening]` |
| 时钟 | 未公开 | 不由每周期操作数和峰值反推 | `[4, ScalarEngine, VectorEngine and TensorEngine paragraphs]` |
| 理论峰值 | 64TFLOPS FP16/BF16；128TOPS INT8 | per-chip；AWS 2019博客也称16-bit浮点为64 teraOPS，当前架构页明确写TFLOPS | `[1, Compute row]` `[6, per-chip performance]` |
| 内存类型与容量 | 当前AWS产品页写8GB DDR4/chip；Neuron硬件页写8GiB device DRAM | 两份一手资料的单位不同，按原文并列 | `[2, Optimized for high throughput and low latency]` `[1, Device Memory row]` |
| 内存带宽 | 50GiB/s | per-chip device DRAM；参数与intermediate state均存放于此 | `[1, Device Memory row]` |
| 主机接口 | 旧版AWS Neuron架构图标为Host PCIe Gen4；lane数与有效带宽未公开 | 当前硬件页未重复PCIe代际，保留固定旧版文档口径 | `[8, p. 1942, Inferentia Architecture figure]` |
| 设备互联端点 | NeuronLink-v1；多芯片Inf1实例表按chip列32GiB/s chip-to-chip bandwidth | 单芯片实例为N/A；方向、端口数、拓扑与有效负载未公开 | `[7, Inf1 Architecture table]` |
| 内存访问语义 | device DRAM保存parameters与intermediate state；NCv1 SRAM由compiler/software显式管理 | 未公开cache coherence、unified memory或透明远端DRAM访问 | `[1, Device Memory row]` `[4, opening]` |
| 跨设备集合通信能力 | NeuronLink-v1配合NeuronCore Pipeline，可在多个芯片间切分模型以权衡latency与throughput | 未找到独立collective-engine吞吐或硬件collective清单 | `[1, NeuronLink row]` `[3, Deploy with popular ML frameworks]` |
| 功耗 | TDP、平均与峰值功耗均未公开 | 不从实例功耗、成本或相对perf/W推算 | `[1, full page]` `[3, full page]` |
| 形态与散热 | Cloud accelerator chip；散热形式未公开 | 不是零售卡；`inf1.xlarge`/`2xlarge`是一芯片实例 | `[3, Product details]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | `inf1.6xlarge`有4 chips，`inf1.24xlarge`有16 chips，二者提供NeuronLink-v1；按chip列32GiB/s | 只把32GiB/s保留为芯片互联端点口径；256/1,024TFLOPS等为实例聚合值 | `[7, Inf1 Architecture table]` |
| 单芯片部署 | `inf1.xlarge`和`inf1.2xlarge`各有1颗Inferentia，NeuronLink栏为N/A | 证明one-chip配置是实际Cloud资源，而非只由系统总量归一化 | `[3, Product details]` `[7, Inf1 Architecture table]` |
| Scale-out | 最大实例提供100Gbps网络；1-chip实例最高25Gbps | EFA/ENA、EBS、host CPU与网络是实例资源，不是芯片内NIC | `[3, High-performance networking and Product details]` |
| 相关系统 | Inf1共有1/4/16-chip四种实例规格，最大实例有96 vCPU和192GiB host RAM | host资源与128GiB聚合device memory均不下放 | `[3, Product details]` `[7, Inf1 Architecture table]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| chip、device与instance | 官方术语跨层 | Neuron文档把单芯片称chip/device，Inf1是含1/4/16颗芯片的EC2实例 | 正式主语固定为一颗Inferentia1 chip/device |
| device memory容量单位 | 一手资料单位不同 | 当前AWS产品页写8GB DDR4；Neuron硬件页写8GiB device DRAM | 原单位并列，不静默换算 |
| 片上SRAM容量 | 未公开 | NCv1页确认software-managed SRAM，产品页只称large on-chip memory | 记录管理方式，不用营销措辞推测容量 |
| NeuronLink-v1带宽口径 | 只给per-chip额定值 | 多芯片实例表写32GiB/s/chip，未给方向、端口、拓扑和有效负载 | 原样记录，不倍增为双向聚合 |
| NeuronLink-v1作用域 | 官方措辞跨层 | 当前术语页称其连接Inferentia device内的NeuronCore；版本化Inf1页称其为direct device-to-device interconnect | 分别保留，不把32GiB/s外部链路口径当成片内带宽 |
| Inf1芯片数量 | 当前技术页开头过度概括 | Inferentia页称每个Inf1有16 chips；产品表和Inf1架构表明确为1/1/4/16 chips | 采用实例逐型号表，不把最大实例配置套到全部Inf1 |
| FP16/BF16单位措辞 | 早期博客与当前架构页不同 | 2019博客写64 teraOPS；当前架构页写64TFLOPS | 采用当前精度明确的64TFLOPS作主值 |
| 预发布峰值 | 预告与正式规格不同 | 2018公告笼统称hundreds of TOPS；正式产品为最高128TOPS INT8 | 2018页面只用于首次宣布和定位，规格采用正式硬件页 |
| 工艺、die/package与功耗 | 未公开 | 当前Neuron硬件页、AWS产品页和发布文章 | 不采用第三方推测，不从相邻代际下放 |
| RAS和存储管理细节 | 未公开 | 只确认compiler-managed SRAM和device DRAM用途 | ECC、一致性、页迁移、cache和远程访问保持缺失 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | AWS Neuron，*Inferentia Architecture* | 当前官方硬件文档 | 四个NCv1、per-chip峰值、8GiB DRAM、50GiB/s与NeuronLink | <https://awsdocs-neuron.readthedocs-hosted.com/en/latest/about-neuron/arch/neuron-hardware/inferentia.html> |
| `[2]` | AWS，*AWS Inferentia* | 当前官方芯片产品页 | 第一代身份、inference定位、DDR4和数据类型 | <https://aws.amazon.com/ai/machine-learning/inferentia/> |
| `[3]` | AWS，*Amazon EC2 Inf1 Instances* | 当前官方实例产品页 | 当前状态、1/4/16-chip配置、芯片与实例边界 | <https://aws.amazon.com/ec2/instance-types/inf1/> |
| `[4]` | AWS Neuron，*NeuronCore-v1 Architecture* | 当前官方Core架构文档 | 三引擎、每周期操作数、systolic array、数值输出和SRAM管理 | <https://awsdocs-neuron.readthedocs-hosted.com/en/latest/about-neuron/arch/neuron-hardware/neuron-core-v1.html> |
| `[5]` | AWS，*Announcing AWS Inferentia: Machine Learning Inference Chip*，2018-11-28 | 官方首次公告 | 首次宣布日期和初始inference定位 | <https://aws.amazon.com/about-aws/whats-new/2018/11/announcing-amazon-inferentia-machine-learning-inference-microchip/> |
| `[6]` | AWS，*Amazon EC2 Update: Inf1 Instances with AWS Inferentia Chips*，2019-12-03 | 官方GA发布文章 | Inf1 GA、per-chip峰值和实例边界 | <https://aws.amazon.com/blogs/aws/amazon-ec2-update-inf1-instances-with-aws-inferentia-chips-for-high-performance-cost-effective-inferencing/> |
| `[7]` | AWS Neuron，*Amazon EC2 Inf1 Architecture* | 当前官方系统架构文档 | 1/4/16-chip实例与32GiB/s NeuronLink-v1口径 | <https://awsdocs-neuron.readthedocs-hosted.com/en/latest/about-neuron/arch/neuron-hardware/inf1-arch.html> |
| `[8]` | AWS Neuron，*AWS Neuron Documentation v2.3.0* | 官方固定版本PDF | Host PCIe Gen4架构图 | <https://awsdocs-neuron.readthedocs-hosted.com/_/downloads/en/v2.3.0/pdf/> |
| `[9]` | AWS Neuron，*Neuron Glossary* | 当前官方术语文档 | NCv1的SBUF/PSUM以及NeuronLink-v1术语边界 | <https://awsdocs-neuron.readthedocs-hosted.com/en/latest/about-neuron/arch/glossary.html> |

## 9. 完成检查

- [x] SKU身份和厂商定位的主语已经固定
- [x] Core、die/chiplet、package、SKU和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、统一内存、一致性和远程访问的管理语义没有混写
- [x] 封装内D2D互联与DRAM、设备互联和系统聚合带宽已经分开
- [x] SKU互联端点与系统拓扑、域大小和聚合带宽已经分开
- [x] 系统级互联上下文只在相关时填写
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：AWS Inferentia1 one chip的主语已经固定为一颗包含四个NeuronCore-v1的chip/device。64TFLOPS FP16/BF16、128TOPS INT8、8GB或8GiB DDR4/device DRAM、50GiB/s带宽、software-managed SRAM和NeuronLink-v1均由AWS一手资料支持；1/4/16-chip实例、host资源与网络没有下放。process、die/package构造、片上SRAM容量、clock、TDP和NeuronLink方向/协议保持缺失。
