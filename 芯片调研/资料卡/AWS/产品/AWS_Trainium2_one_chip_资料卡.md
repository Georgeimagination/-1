# AWS Trainium2 one chip 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

本卡采用一颗AWS Trainium2 chip/NeuronDevice作为正式比较对象。该芯片包含8个NeuronCore-v3（NCv3，第三代Neuron计算核）、4个HBM stack、128个主DMA engine和4个NeuronLink-v3接口。`trn2.3xlarge`确实配置一颗Trainium2；16-chip Trn2/Trn2u实例和64-chip Trn2 UltraServer的聚合资源不下放。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Amazon Web Services（AWS） | AWS自研Trainium | `[7, Trainium2 announcement]` |
| 产品家族 | AWS Trainium2 | AWS称其为第二代Trainium；部分材料按NeuronDevice计为第三代，计数基准不同 | `[1, opening]` `[7, Trainium2 announcement]` |
| 完整 SKU | AWS Trainium2 one chip | 官方未公开常规板卡料号，采用一颗chip/NeuronDevice口径 | `[1, Trainium2 chip components]` |
| 对象形态 | 一颗Cloud AI accelerator chip/package | 单裸片、chiplet数量与物理package构造未公开 | `[1, device diagram and chip components]` |
| 架构代际 | 8个NeuronCore-v3 | 每个NCv3有Tensor、Vector、Scalar和GPSIMD引擎 | `[1, Trainium2 chip components]` `[2, NeuronCore-v3 Compute Engines]` |
| 发布与可用状态 | 2023-11-28公布；2024-12-03 Trn2正式可用；当前产品页仍列Trn2实例 | 芯片经Cloud实例交付，不写成独立销售芯片的GA | `[7, page date and Trainium2 announcement]` `[6, page date and opening]` `[5, Product details]` |
| 厂商定位 | 面向generative AI training与inference | 产品页同时写training和inference，不将其简化为只训练 | `[5, opening and Why Amazon EC2 Trn2?]` |
| 目标 workload | LLM、diffusion、multimodal和MoE等大模型 | 产品定位；模型参数量和训练/推理成绩不写成芯片属性 | `[5, Benefits and Features]` |
| 产品目标 | 提高FP8/BF16算力、HBM容量/带宽与NeuronLink扩展能力 | 单芯片规格与16/64-chip系统分层记录 | `[1, Trainium2 performance improvements]` |

本卡包含：8个NCv3、Tensor/Vector/Scalar/GPSIMD引擎、当前per-chip稠密与结构化稀疏峰值、96GiB HBM、SBUF/PSUM、DMA、CC-Core和4个NeuronLink-v3接口。

本卡不包含：Trn2实例的vCPU、host RAM、EFA、NVMe、实例聚合算力，以及Trn2 UltraServer的64-chip总资源。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | NeuronCore-v3，含Tensor、Vector、Scalar和GPSIMD | Trainium2实现共享 | 本卡记录每核机制及八核芯片配置 | `[2, NeuronCore-v3 Compute Engines]` `[3, full page]` |
| die | 未公开 | 未证明单裸片或chiplet组成 | 不从逻辑框图推断 | `[1, device diagram]` |
| package | 一颗Trainium2 device，连接4个HBM stack | Trainium2实现共享 | 逻辑组成按官方device图记录，物理封装保持未知 | `[2, Trainium2 Device Diagram]` |
| 产品配置 | AWS Trainium2 one chip | 不适用 | 正式比较单位；实际对应`trn2.3xlarge`的一颗加速器 | `[5, Product details]` |
| 相关系统 | 1-chip Trn2、16-chip Trn2/Trn2u、64-chip Trn2 UltraServer | 多种系统规模 | 只用于划定NeuronLink和EFA边界 | `[4, Trn2 Architecture]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 异构执行 | 每个NCv3含Tensor、Vector、Scalar和GPSIMD引擎，并有独立sequencer；计算引擎、DMA和collective可并行 | 单个NCv3；完整芯片有8个 | `[2, NeuronCore-v3 Compute Engines]` |
| Tensor Engine | 128×128 PE systolic array；每NCv3为158TFLOPS FP8、79TFLOPS BF16/FP16/TF32、20TFLOPS FP32、316TFLOPS structured sparse | 2.4GHz；FP8 double-row在编程视图呈现256×128，但物理阵列仍为128×128 | `[2, Tensor Engine and Table 11]` `[8, Performance mode and tile size]` |
| Vector Engine | FP32峰值1.0TFLOPS/NCv3，支持FP8、FP16、BF16、TF32、FP32及多种整数格式 | 0.96GHz；BF16/FP16通路可按模式提高指令吞吐，内部算术仍为FP32 | `[2, Vector Engine and Table 11]` `[3, Vector Engine]` |
| Scalar Engine | FP32峰值1.2TFLOPS/NCv3，面向element-wise和非线性函数 | 1.2GHz、128 element/cycle | `[2, Scalar Engine and Table 11]` |
| GPSIMD Engine | 每个GPSIMD有8个可编程512-bit processor，可执行C/C++ custom operator | 1.2GHz；未公开可直接比较的FLOPS | `[2, Gpsimd Engine and Table 11]` `[3, GPSIMD engine]` |
| FP8 double 模式限制 | E4/E5 支持 double FP8；E3 与 FP16/BF16 同吞吐；double FP8 不能与 sparse matmul 合用 | 支持的格式、执行模式和稀疏条件分开 | `[2, Double FP8 Matmul Performance]` |
| 数值与累加路径 | Tensor matmul支持E4M3/E5M2、BF16、FP16、TF32和FP32输入，内部累加与NCv3 PSUM目标为FP32 | 两输入格式存在组合限制；物理累加器位宽与具体舍入点未公开 | `[8, Data types]` |
| 结构化稀疏 | Tensor Engine支持4:16、4:12、4:8、2:8、2:4、1:4和1:2模式 | 未公开metadata编码、带宽或在线剪枝机制 | `[3, Tensor Engine]` |
| 局部存储 | 每NCv3有28MiB software-managed SBUF和2MiB PSUM；SBUF有128个224KiB partition | SBUF/PSUM是core-local scratchpad，不是统一共享cache | `[2, NeuronCore-v3 Compute Engine Updates and Data Movement Updates]` |
| 数据搬运辅助 | 每NCv3通常有16个主DMA和2个Descriptor Generation Engine；DMA支持copy与transpose | 一颗芯片共有128个主DMA；DGE按需生成DMA描述符 | `[1, Data movement]` `[2, DMA Transpose and Descriptor Generation Engine]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算与专用单元 | 8个NCv3、128个主DMA、4个NeuronLink-v3接口；CC-Core数量在官方文档中存在16与20的冲突 | 单颗Trainium2 chip/device；CC-Core不取唯一值 | `[1, Trainium2 chip components]` `[2, Trainium2 Device Diagram]` |
| 片上存储 | 28MiB SBUF和2MiB PSUM/NCv3；芯片SBUF合计224MiB | 八组core-local SRAM，不写成单一共享SRAM；PSUM合计16MiB为按核容量关系，不替代官方共享容量 | `[1, Memory]` `[2, NeuronCore-v3 Compute Engine Updates]` |
| 片内互联 | 未公开完整拓扑 | 文档给出NCv3、HBM、DMA、CC-Core和NeuronLink功能块，未给chip级NoC或coherence | `[2, Trainium2 Device Diagram]` |
| 内存控制器与PHY | 4个HBM stack，总容量96GiB | controller、PHY宽度、HBM代际、bank映射和stack高度未公开 | `[1, Memory]` `[2, Trainium2 Device Diagram]` |
| 工艺与物理规模 | 未公开 | 未找到process node、foundry、die area、晶体管数或电压范围 | `[1, full page]` `[5, full page]` |
| 封装组成 | 未公开 | 单裸片/chiplet数量、interposer、基板和package尺寸均未找到；4个HBM stack不足以证明封装方式 | `[2, Trainium2 Device Diagram]` |
| 封装内互联 | 未公开 | 没有足够证据证明compute chiplet或D2D协议 | `[1, device diagram]` |
| RAS与安全 | 未公开芯片级ECC、重放、隔离或secure boot细节 | Nitro提供的实例网络加密不下放为芯片属性 | `[5, Reliably and securely scale]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 8个NeuronCore-v3、128个主DMA、4个NeuronLink-v3接口 | 单颗Trainium2；CC-Core数量存在官方冲突 | `[1, Trainium2 chip components]` `[2, Trainium2 Device Diagram]` |
| 时钟 | Tensor 2.4GHz；Vector 0.96GHz；Scalar和GPSIMD各1.2GHz | engine clock，不存在一个公开的统一chip clock | `[2, Table 11]` |
| 稠密理论峰值 | 1,299TFLOPS FP8；667TFLOPS BF16/FP16/TF32；181TFLOPS FP32 | 当前per-chip advertised peak；计数规则和频率条件未完整披露 | `[1, Compute]` |
| 结构化稀疏峰值 | 最高 2,563TFLOPS FP8/FP16/BF16/TF32 | 当前per-chip advertised peak；是最高值；支持上述七种 M:N 模式，但官方未逐模式报告芯片峰值，不能认为每种模式均达到此值，也不能当作稠密峰值 | `[1, Compute]` `[3, Tensor Engine]` |
| 内存类型与容量 | 4个HBM stack，96GiB/chip | NKI图另写4×24GB，原单位保留；HBM代际未公开 | `[1, Memory]` `[2, Trainium2 Device Diagram]` |
| 内存带宽 | 2.9TB/s，NKI页另四舍五入为3TB/s | per-chip；方向和有效负载未公开 | `[1, Memory]` `[2, Trainium2 Device Diagram]` |
| 片上存储 | 224MiB SBUF/chip；每NCv3另有2MiB PSUM | SBUF为8×28MiB core-local software-managed SRAM；PSUM也是core-local | `[1, Memory]` `[2, NeuronCore-v3 Compute Engine Updates]` |
| DMA | 128个主DMA；chip级3.5TB/s，支持inline compression/decompression | 方向、有效负载和每engine峰值未作为芯片统一口径披露 | `[1, Data movement]` `[2, Trainium2 Device Diagram]` |
| 主机接口 | PCIe，具体代际、lane数和host-device带宽未公开 | 逻辑图只确认host PCIe路径 | `[2, Trainium2 Device Diagram]` |
| 设备互联端点 | 4个NeuronLink-v3接口，chip级聚合1.28TB/s | 单向/双向、per-link和payload口径未公开；一芯片实例不形成scale-up拓扑 | `[1, Interconnect]` `[2, Trainium2 Device Diagram]` |
| 内存访问语义 | HBM经DMA与各核SBUF交换，PSUM保存Tensor Engine累加；同一多芯片实例支持HBM pooling | 芯片本地存储与16-chip远端内存池分开 | `[2, Data Movement Updates]` `[4, Trn2 Architecture]` |
| 集合通信能力 | CC-Core与NeuronLink-v3支持collective communication | CC-Core数量冲突，具体offload边界与单元吞吐未公开 | `[1, Collective communication]` `[2, Trainium2 Device Diagram]` |
| 功耗 | TDP、平均和峰值功耗均未公开 | 不从实例成本、相对perf/W或整机功耗推算 | `[1, full page]` `[5, full page]` |
| 形态与散热 | Cloud accelerator chip；散热形式未公开 | 不是零售卡；`trn2.3xlarge`是一芯片Cloud配置 | `[5, Product details]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| 单芯片部署 | `trn2.3xlarge`有1 chip和96GB accelerator memory | 证明one-chip是实际Cloud配置，不是从16-chip实例归一化 | `[5, Product details]` |
| Scale-up | `trn2.48xlarge`和`trn2u.48xlarge`各有16 chips，组成4×4 2D torus并支持16-chip memory pooling | 20.8PFLOPS FP8、1,536GiB HBM、46.4TB/s HBM带宽和1,024GB/s/chip intra-instance NeuronLink均留在系统层 | `[4, trn2.48xlarge / trn2u.48xlarge and specifications]` |
| UltraServer | 4个`trn2u.48xlarge`组成64-chip UltraServer；同一XY坐标的chip跨实例连成ring | 6,144GiB HBM、83.2PFLOPS FP8及256GB/s/chip inter-instance NeuronLink不写成单芯片独占资源 | `[4, Trn2 UltraServer and specifications]` |
| Scale-out | 16-chip实例通过EFAv3连接外部网络，UltraServer产品页列12.8Tbps聚合EFA | EFA是实例/系统网络，不是Trainium2片上NIC或NeuronLink | `[4, Trn2 instance specifications]` `[5, Features]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| Trainium代际称谓 | 官方术语计数基准不同 | 第二代Trainium与第三代NeuronDevice/自研ML chip措辞并存 | 产品名固定为Trainium2，不自行统一其余代际计数 |
| 芯片与每核Tensor峰值 | 官方直接值不能简单相加 | chip页为1,299/667/181/2,563；NKI每核为158/79/20/316，乘8得到不同结果 | 芯片字段采用direct per-chip值，每核值只在Core层记录 |
| 早期FP8稀疏峰值 | 官方版本发生变化 | 2024发布文章写5.2PFLOPS sparse FP8/chip；当前芯片页写2,563TFLOPS | 当前字段采用版本化芯片架构页；NKI 明确 double FP8 不能与 sparse matmul 合用。旧 5.2PFLOPS 保留为历史冲突，不猜测原因 `[2, Double FP8 Matmul Performance]` |
| CC-Core数量 | 当前官方文档相互冲突 | 高层架构页写16个，NKI device图写20个 | 不填写唯一数量，只确认CC-Core存在 |
| HBM容量单位 | 一手资料单位不同 | 芯片页96GiB；NKI图4×24GB；产品表96GB | 原单位按来源保留，不静默换算 |
| HBM与NeuronLink带宽 | 粗略值与分层值并存 | NKI页3TB/s；芯片页2.9TB/s；芯片聚合NeuronLink 1.28TB/s，16/64-chip架构又分intra/inter | 主字段用直接per-chip 2.9和1.28；系统分层值不下放 |
| 工艺、die/package与功耗 | 未公开 | 当前Neuron硬件页、NKI指南、产品页和GA公告 | 不采用第三方推测，不从实例指标反推 |
| 主机接口与RAS | 未公开完整规格 | 只确认逻辑PCIe路径，没有代际/lane/带宽或芯片级RAS细节 | 保持缺失 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | AWS Neuron，*Trainium2 Architecture* | 官方芯片架构文档 | per-chip峰值、NCv3数、HBM、SBUF、DMA、CC-Core与NeuronLink | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/about-neuron/arch/neuron-hardware/trainium2.html> |
| `[2]` | AWS Neuron，*Trainium2 Architecture Guide for NKI* | 官方底层硬件指南 | device组成、引擎、频率、SBUF/PSUM、DMA、DGE与CC-Core冲突 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/nki/guides/architecture/trainium2_arch.html> |
| `[3]` | AWS Neuron，*NeuronCore-v3 Architecture* | 官方Core架构文档 | 数据格式、M:N稀疏、Vector/Scalar/GPSIMD | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/about-neuron/arch/neuron-hardware/neuron-core-v3.html> |
| `[4]` | AWS Neuron，*Amazon EC2 Trn2 Architecture* | 官方系统架构文档 | 16/64-chip配置、2D torus、跨实例ring与分层互联 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/about-neuron/arch/neuron-hardware/trn2-arch.html> |
| `[5]` | AWS，*Amazon EC2 Trn2 instances and UltraServers* | 当前官方产品页 | 当前状态、training/inference定位、1/16/64-chip配置与EFA边界 | <https://aws.amazon.com/ec2/instance-types/trn2/> |
| `[6]` | AWS，*Amazon EC2 Trn2 instances, powered by AWS Trainium2 chips, are now generally available*，2024-12-03 | 官方GA公告 | Trn2正式可用日期与当时UltraServer Preview状态 | <https://aws.amazon.com/about-aws/whats-new/2024/12/amazon-ec2-trn2-instances-available/> |
| `[7]` | Amazon Press Center，*AWS Unveils Next Generation of AWS-Designed Chips*，2023-11-28 | 官方发布稿 | Trainium2公布日期、产品代际与计划定位 | <https://press.aboutamazon.com/2023/11/aws-unveils-next-generation-aws-designed-chips> |
| `[8]` | AWS Neuron，*nki.isa.nc_matmul* | 官方ISA文档 | 物理阵列、FP8 double-row、输入格式与FP32累加 | <https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/nki/api/generated/nki.isa.nc_matmul.html> |

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

复核结论：AWS Trainium2 one chip的主语已经固定为一颗包含8个NeuronCore-v3的chip/NeuronDevice。当前官方1,299TFLOPS FP8、667TFLOPS BF16/FP16/TF32、181TFLOPS FP32、2,563TFLOPS结构化稀疏、96GiB HBM、224MiB SBUF、128个DMA engine和4个NeuronLink-v3接口均有AWS一手资料支持；1/16/64-chip对象、NeuronLink与EFA的边界没有混用。每核与每芯片峰值、早期FP8稀疏峰值以及16/20个CC-Core冲突已经按原始作用域保留，process、die/package构造、HBM代际、PCIe配置、绝对功耗和芯片级RAS保持缺失。
