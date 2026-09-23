# AWS Trainium3 one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡采用一颗AWS Trainium3 chip/NeuronDevice作为正式比较对象。AWS直接公开了每芯片规格，但当前交付形态是64-chip或144-chip Trn3 UltraServer，未找到单芯片Trn3实例。因此本卡是厂商直接per-chip口径，不是可单独申请的Cloud SKU，也不是将UltraServer总量除以芯片数所得。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Amazon Web Services（AWS） | AWS自研Trainium | `[6, opening]` |
| 产品家族 | AWS Trainium3 | AWS称其为第四代自研AI chip/NeuronDevice | `[1, opening]` `[2, opening]` |
| 完整 SKU | AWS Trainium3 one chip | 没有常规板卡料号或one-chip EC2实例，采用官方直接per-chip配置 | `[1, NeuronCore-v4 table]` `[6, each-chip paragraph]` |
| 对象形态 | 一颗3nm Cloud AI accelerator chip/package | 3nm由AWS直接公布；单裸片、chiplet与物理package构造未公开 | `[6, opening]` `[2, device overview]` |
| 架构代际 | 8个NeuronCore-v4（NCv4） | 每个NCv4含Tensor、Vector、Scalar和GPSIMD引擎 | `[1, opening]` `[2, NeuronCore-v4 Compute Engine Updates]` |
| 发布与可用状态 | 2024-12-03首次公布；2025-12-02 Trn3 UltraServer GA；当前产品页仍在提供 | 2024为unveil，不写成Preview或GA；2025 GA对象是UltraServer交付形态 | `[7, page date and opening]` `[6, page date and opening]` `[5, opening]` |
| 厂商定位 | 面向frontier-scale model的training与inference/serving，按训推兼顾记录 | 2024预告曾称AI training chip，但同段也涉及实时部署；2025 GA正文和当前产品页均明确共同面向training与serving，不据名称判定偏训练 | `[7, Trainium3 chips—designed for the high-performance needs of the next frontier of generative AI workloads]` `[6, opening and training and serving paragraph]` `[5, Why Amazon EC2 Trn3 UltraServers? and Benefits]` |
| 目标 workload | agentic、reasoning、video generation、long-context和MoE | 产品定位，不把模型参数量、token/s或相对性能写成芯片属性 | `[5, opening and Features]` |
| 产品目标 | 以MX低精度、HBM3e和全互连scale-up fabric提高训练与serving效率 | 芯片能力与NeuronSwitch/UltraCluster分层记录 | `[5, Features]` |

本卡包含：每芯片8个NCv4、MXFP8/MXFP4及BF16/FP16/TF32路径、结构化稀疏、HBM3e、SBUF/PSUM、DMA、CC-Core和NeuronLink-v4端点。

本卡不包含：64/144-chip UltraServer的host、EFA、总算力、总HBM、总内存带宽，以及UltraCluster 3.0规模。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | NeuronCore-v4，含Tensor、Vector、Scalar、GPSIMD和Sync Engine | Trainium3实现共享 | 复用[Trainium3架构卡](../架构/AWS_Trainium3_架构卡.md)，本卡补八核芯片配置 | `[2, NeuronCore-v4 Compute Engine Updates]` |
| die | 未公开 | 未证明单裸片或chiplet组成 | 不从逻辑框图或3nm工艺推断 | `[2, device overview]` |
| package | 一颗Trainium3 device，连接4个HBM stack | Trainium3实现共享 | 复用[芯片实现卡](../封装/AWS_Trainium3_芯片实现资料卡.md)，改写为正式per-chip SKU口径 | `[2, device overview]` |
| 产品配置 | AWS Trainium3 one chip | 不适用 | 正式比较单位；没有公开one-chip实例 | `[1, NeuronCore-v4 table]` `[6, each-chip paragraph]` |
| 相关系统 | 64-chip Gen1和144-chip Gen2 Trn3 UltraServer、UltraCluster 3.0 | 多种系统规模 | 只用于划定NeuronLink、NeuronSwitch和EFA边界 | `[4, full page]` `[5, Features]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 异构执行 | 每个NCv4保留Tensor、Vector、Scalar、GPSIMD四类独立sequencer执行引擎，并由Sync Engine协调 | 单个NCv4；完整芯片有8个 | `[2, NeuronCore-v4 Compute Engine Updates]` |
| Tensor Engine | 物理128×128 PE systolic array；每NCv4为315TFLOPS MXFP8/MXFP4、79TFLOPS BF16/FP16/TF32、20TFLOPS FP32 | 2.4GHz；MX模式向软件呈现有效512×128 contraction，但不是512×128物理阵列 | `[2, Tensor Engine and Table 11]` |
| MX数值路径 | 支持MXFP8和MXFP4，group size为32；MXFP8×MXFP4可混用，matmul同时完成scale dequantization，输出FP32或BF16 | NCv4 文档明确 MXFP4 在进入 Tensor Engine 计算逻辑前通过可编程映射转换为 MXFP8；不能将 MXFP4 输入性能解释为独立原生 FP4 乘法阵列或相对 MXFP8 翻倍。scale 和数据均来自 SBUF | `[2, Quad-MXFP8/MXFP4 Matmul Performance]` `[3, Tensor Engine]` |
| Vector Engine | 1.2TFLOPS FP32/NCv4，支持FP8、FP16、BF16、TF32、FP32及多种整数格式 | 1.2GHz；原生MX quantization和fast exponential属于该通用引擎能力 | `[2, Vector Engine and Table 11]` |
| Scalar Engine | 1.2TFLOPS FP32/NCv4，支持FP8、FP16、BF16、TF32、FP32及多种整数格式 | 1.2GHz；面向逐元素、nonlinear和reduction等 | `[2, Scalar Engine and Table 11]` |
| GPSIMD Engine | 可编程通用SIMD路径用于custom operator | 1.2GHz、128 element/cycle；未公开直接可比的FLOPS | `[1, Programmability]` `[2, Table 11]` |
| 累加与舍入 | MX和BF16/FP16/TF32 matmul内部使用FP32 accumulation；NCv4允许将结果直接降为BF16写入PSUM | BF16写回可选RNE或stochastic rounding；计算语义不等于物理accumulator位宽 | `[2, BF16 Matmul Results in PSUM and Quad-MXFP8/MXFP4 Matmul Performance]` |
| 结构化稀疏 | 支持4:16、4:12、4:8、2:8、2:4、1:4和1:2模式 | 未公开metadata编码、带宽、在线剪枝或独立sparse core | `[3, Tensor Engine]` |
| 局部存储 | 每NCv4有32MiB software-managed SBUF和2MiB PSUM | SBUF/PSUM是core-local SRAM，不是芯片统一共享cache | `[2, NeuronCore-v4 Compute Engine Updates]` |
| 数据搬运与特殊路径 | 主DMA负责显式搬运；NCv4增加SBUF/PSUM间接访问、SBUF read-add-write和可与matmul重叠的background transpose | 是通用memory/compute机制，不写成attention或MoE专用单元 | `[2, Data Movement and DMA updates, SBUF near-memory accumulation, Background Transpose]` |

### 3.1 NCv4 新增的数据布局、结果保存与搬运机制

| 机制 | 原文规定的作用与条件 | 编程或量化边界 | 来源 |
|---|---|---|---|
| MX输入布局 | contraction维最大512，拆为128个SBUF partition与最内层free维连续四个元素，使用x4 packed datatype；每32个数据共享一个8-bit scale | 与NCv3把额外K维放在最外层free维的double FP8布局不同；一次MX matmul需stationary/moving各自的数据与scale共四份输入，流量不能省略scale | `[2, Quad-MXFP8/MXFP4 Matmul Performance]` |
| BF16 PSUM近存累加 | 旧BF16 PSUM值先升成FP32，与TensorEngine的FP32输出相加，再按RNE或stochastic rounding降为BF16写回 | PSUM物理容量仍为2MiB；位宽减半可容纳更多元素，但分块间反复降精度与一直保留FP32部分和的数值路径不同 | `[2, BF16 Matmul Results in PSUM]` |
| Background transpose | TensorEngine可使一次transpose与另一次matmul或transpose并行；由硬件自动触发，程序无需显式启用 | 原文只称长transpose链接近双倍性能或与较大matmul重叠，不能推成所有matmul吞吐翻倍 | `[2, Background Transpose]` |
| QuantizeMX | Vector将SBUF中的FP16/BF16量化为MXFP8 data与scale；每partition每周期处理四个元素 | 源和目标都在SBUF，源布局必须已经符合目标布局；指令本身不完成任意布局重排 | `[2, MX data-type Quantization]` |
| Fast exponential | Vector上的exponential吞吐为Scalar activation(exp)的四倍，可融合exp前减行最大值与exp后求和 | 官方将该模式联系到长上下文self-attention的softmax；四倍属于指定指令对照，不能写成attention端到端四倍 | `[2, Fast Exponential Evaluation]` |
| XORWOW随机数状态 | Vector每compute lane每周期产生四个32-bit伪随机数；128个lane各追踪四个状态，每状态含六个uint32，可保存到SBUF/PSUM再恢复 | 支持训练随机序列复现；不是新增独立计算核 | `[2, XORWOW-based PRNG]` |
| SBUF/PSUM间接访问 | 四类compute engine均可按单独offset tensor在free维gather/scatter，在一次指令内访问不规则位置 | v2.31.0明确该机制当时尚无nki.isa API，不能据硬件描述认为该版本kernel已可调用 | `[2, SBUF/PSUM indirect access and Note]` |
| SBUF Read-Add-Write | DMA把A送到SBUF邻近加法单元，对SBUF内B执行B+=A；A可来自可寻址HBM/SBUF，单次transfer中A、B同为BF16或同为FP32；吞吐与普通DMA copy到SBUF相同 | 指南对照此前DMA collective compute engine路径约50%的copy吞吐；v2.31.0仍无nki.isa API，不把相对吞吐提升当作实测算子收益 | `[2, SBUF Read-Add-Write and Note]` |
| DMA Traffic Shaping | 四类服务等级可配置不同DMA操作的带宽分配与优先级，用于跨核通信与计算重叠时控制争用 | 调度机制不增加HBM物理带宽；v2.31.0明确当时无nki.isa API | `[2, DMA Traffic Shaping and Note]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算与专用单元 | 8个NCv4、128个DMA、4个NeuronLink-v4接口；CC-Core数量在官方文档中存在16与20的冲突 | 单颗Trainium3 chip/device；CC-Core不取唯一值 | `[1, NeuronCore-v4 table]` `[2, device overview]` |
| 片上存储 | 32MiB SBUF和2MiB PSUM/NCv4 | 完整芯片是八组core-local SRAM；不写成单一共享SRAM | `[2, NeuronCore-v4 Compute Engine Updates]` |
| 片内互联 | 未公开完整拓扑 | 文档没有给chip级NoC、coherence或跨核SBUF直接访问语义 | `[2, device overview and NCv4 diagram]` |
| 内存控制器与PHY | 4个HBM stack、144GiB/GB HBM3e | controller、PHY宽度和stack高度未公开 | `[2, device overview]` `[6, each-chip paragraph]` |
| 工艺与物理规模 | 3nm；foundry、die area、晶体管数与电压未公开 | AWS称其为首颗3nm AWS AI chip，不据此推断具体foundry node | `[6, opening]` |
| 封装组成 | 未公开 | 单裸片/chiplet数量、interposer、基板、HBM连接方式和package尺寸均未找到 | `[1, chip diagram]` `[5, full page]` |
| 封装内互联 | 未公开 | NeuronLink-v4是device-to-device端点，不证明package内部D2D | `[1, NeuronLink]` |
| RAS与安全 | 未公开芯片级ECC、重放、隔离或secure boot细节 | 不把EC2/Nitro或UltraCluster系统能力下放 | `[1, full page]` `[5, full page]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 8个NeuronCore-v4、128个DMA、4个NeuronLink-v4接口 | 单颗Trainium3；CC-Core数量存在官方冲突 | `[1, NeuronCore-v4 table]` `[2, device overview]` |
| 时钟 | Tensor 2.4GHz；Vector、Scalar和GPSIMD各1.2GHz | engine clock，不存在一个公开的统一chip clock | `[2, Table 11]` |
| MX理论峰值 | 2,517TFLOPS MXFP8/MXFP4 | per-chip advertised peak；GA页四舍五入为2.52PFLOPS FP8 | `[1, Compute]` `[6, each-chip paragraph]` |
| 混合精度理论峰值 | 671TFLOPS BF16/FP16/TF32；183TFLOPS FP32 | per-chip advertised peak；未说明MAC计数和持续条件 | `[1, Compute]` |
| 结构化稀疏峰值 | 2,517TFLOPS FP16/BF16/TF32 sparse | per-chip advertised peak；不能当作稠密峰值 | `[1, Compute]` `[3, Tensor Engine]` |
| 内存类型与容量 | 4个HBM stack；架构页144GiB，GA/产品页144GB HBM3e | 同一芯片的官方单位标签不同，原样保留 | `[1, Device memory]` `[2, device overview]` `[6, each-chip paragraph]` |
| 内存带宽 | 高层架构页和GA页4.9TB/s；NKI实现页4.7TB/s | per-chip官方冲突，未找到版本关系说明 | `[1, Device memory]` `[2, device overview]` `[6, each-chip paragraph]` |
| 片上存储 | 256MiB SBUF/chip；每NCv4为32MiB SBUF和2MiB PSUM | 八组core-local software-managed SRAM；PSUM不并入SBUF总量 | `[1, Memory comparison table]` `[2, NeuronCore-v4 Compute Engine Updates]` |
| DMA | 128个DMA；芯片级4.9TB/s，支持inline computation | 方向、有效负载和per-engine峰值未公开 | `[1, Data movement]` `[2, device overview]` |
| 主机接口 | 未公开单独的host-CPU PCIe代际、lane数和带宽 | UltraServer公开的PCIe Gen6 switch连接服务于NeuronSwitch/NeuronLink fabric，保留在系统作用域 | `[4, Trn3 UltraServer Connectivity and Networking]` |
| 设备互联端点 | 4个NeuronLink-v4接口；高层芯片页写2.56TB/s/device | per-link、单/双向和payload口径未公开；UltraServer表另写2,048GiB/s/device | `[1, NeuronLink]` `[2, device overview]` `[4, specifications]` |
| 内存访问语义 | HBM、software-managed SBUF和PSUM构成显式搬运层次；多芯片部署支持memory pooling | 本地存储管理与UltraServer远端互联分开 | `[1, NeuronLink]` `[2, Data Movement and DMA updates]` |
| 集合通信能力 | CC-Core与NeuronLink-v4支持device间collective communication | CC-Core数量冲突；NeuronSwitch属于UltraServer fabric | `[1, Collective communication]` `[2, device overview]` |
| 功耗 | TDP、平均和峰值功耗均未公开 | 产品页只有相对performance/W，不从系统比较反推绝对功耗 | `[5, Benefits]` |
| 形态与散热 | Cloud accelerator chip；当前经Trn3 UltraServer交付 | 未找到one-chip实例、独立零售卡或芯片散热规格 | `[4, opening]` `[5, opening]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| 单芯片部署 | 未找到公开的one-chip Trn3实例 | 本卡只采用AWS直接per-chip规格，不把它说成可单独申请的实例 | `[4, full page]` `[5, full page]` |
| Gen1 UltraServer | 4个server、每server 16 chips，共64 chips | 161,088TFLOPS MX、9,216GiB HBM、313.6TB/s HBM带宽是系统聚合值 | `[4, Trn3 Gen1 UltraServer and specifications]` |
| Gen2 UltraServer | 36个server、每server 4 chips，共144 chips | 362,448TFLOPS MX、20,736GiB HBM、705.6TB/s HBM带宽是系统聚合值 | `[4, Trn3 Gen2 UltraServer and specifications]` |
| Scale-up fabric | Gen1/Gen2以NeuronSwitch-v1和NeuronLink-v4形成all-to-all connectivity；公开表写2,048GiB/s/device | NeuronSwitch是系统交换fabric，不是芯片内NoC，也不改变每芯片四个端点的对象边界 | `[4, full page]` |
| Scale-out | Trn3 UltraServer经EFA进入EC2 UltraCluster 3.0 | EFA和数十万芯片规模属于集群，不是Trainium3片上NIC或SKU属性 | `[5, opening and Features]` |

## 7. 证据缺口与来源冲突

Trn3 系统文档新增按芯片列出的 Gen6 x8 互联：intra-server 4 组、256GB/s 双向；inter-server 5 组、320GB/s 双向；inter-rack 2 组、128GB/s 双向。该段使用每 sled 4 chips 的描述，前文另有 Gen1 每 server 16 chips，适用系统版本需分开；这些分层数值与同页 2,048GiB/s、芯片页 2.56TB/s 的关系未说明，不能简单相加替代 NeuronLink 额定值，也不是已确认的 host-CPU 接口。`[4, Trn3 UltraServer Connectivity and Networking]`

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| one-chip产品配置 | 未公开 | 当前产品页与Trn3系统架构只列64/144-chip UltraServer | 采用厂商direct per-chip规格；明确不是可申请的一芯片实例 |
| 芯片与每核Tensor峰值 | 官方直接值存在小幅口径差 | chip页为2,517/671/183；NKI每核为315/79/20，乘8为2,520/632/160TFLOPS，不能完全复现chip headline | 纯Tensor比较采用按八核相乘的名义合计，并注明每核已取整；advertised peak单列，计数范围未解释，不将差额分配给其他引擎 |
| HBM容量单位 | 一手资料单位不同 | 架构/NKI页144GiB；GA/产品页144GB | 原单位并列，不静默换算 |
| HBM带宽 | 一手资料数值不同 | 高层架构与GA页4.9TB/s；NKI device overview 4.7TB/s | 并列保留，不猜测为额定/有效或版本变化 |
| CC-Core数量 | 一手资料数值不同 | 高层架构页16个；NKI device overview 20个 | 不填写唯一数量，只确认CC-Core存在 |
| NeuronLink芯片与系统口径 | 单位和部署口径不同 | 芯片页2.56TB/s/device；UltraServer表2,048GiB/s/device；产品营销页约2TB/s/chip | 各留在原作用域，不换算合并或拆成per-link |
| 物理实现与功耗 | 大量未公开 | 除3nm与HBM3e外，没有foundry、die/chiplet、面积、晶体管、package和绝对功耗 | 保持缺失，不采用第三方推测 |
| 主机接口与RAS | 未公开完整规格 | 只确认Host PCIe路径，没有代际/lane/带宽或芯片级RAS细节 | 保持缺失 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | AWS Neuron，*Trainium3 Architecture* | 官方芯片架构文档 | per-chip峰值、HBM、DMA、NeuronLink、CC-Core与programmability | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.28.1/about-neuron/arch/neuron-hardware/trainium3.html> |
| `[2]` | AWS Neuron，*Trainium3 Architecture Guide for NKI* | 官方底层硬件指南 | device组成、NCv4引擎、MX、SBUF/PSUM、DMA与CC-Core冲突 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.31.0/nki/guides/architecture/trainium3_arch.html> |
| `[3]` | AWS Neuron，*NeuronCore-v4 Architecture* | 官方Core架构文档 | NCv4数值路径、M:N稀疏与执行机制 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.30.0/about-neuron/arch/neuron-hardware/neuron-core-v4.html> |
| `[4]` | AWS Neuron，*Amazon EC2 Trn3 Architecture* | 官方系统架构文档 | 64/144-chip UltraServer、NeuronSwitch、all-to-all、系统规格与EFA | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.30.0/about-neuron/arch/neuron-hardware/trn3-arch.html> |
| `[5]` | AWS，*Amazon EC2 Trn3 UltraServers* | 当前官方产品页 | 当前状态、训练/推理定位、144-chip产品与系统互联边界 | <https://aws.amazon.com/ec2/instance-types/trn3/> |
| `[6]` | AWS，*Announcing Amazon EC2 Trn3 UltraServers for faster, lower-cost generative AI training*，2025-12-02 | 官方GA公告 | GA日期、3nm、per-chip FP8、HBM3e容量/带宽及144-chip边界 | <https://aws.amazon.com/about-aws/whats-new/2025/12/amazon-ec2-trn3-ultraservers/> |
| `[7]` | Amazon Press Center，*AWS Trainium2 Instances Now Generally Available*，2024-12-03 | 官方发布稿 | Trainium3首次unveil日期与当时的next-generation定位 | <https://press.aboutamazon.com/2024/12/aws-trainium2-instances-now-generally-available> |

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

复核结论：AWS Trainium3 one chip的主语已经固定为AWS直接公开的一颗chip/NeuronDevice配置，而不是可单独申请的Cloud实例。8个NeuronCore-v4、2,517TFLOPS MXFP8/MXFP4、671TFLOPS BF16/FP16/TF32、183TFLOPS FP32、2,517TFLOPS结构化稀疏、144GiB/GB HBM3e、128个DMA和4个NeuronLink-v4接口均有AWS一手资料支持；64/144-chip UltraServer、NeuronSwitch和EFA没有下放。4.9/4.7TB/s HBM带宽、16/20个CC-Core及NeuronLink不同部署口径按原始作用域保留，除3nm与HBM3e外的die/package、主机接口、绝对功耗和芯片级RAS保持缺失。
