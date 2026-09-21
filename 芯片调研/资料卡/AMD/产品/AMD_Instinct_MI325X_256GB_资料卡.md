# AMD Instinct MI325X 256GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

本卡采用一块AMD Instinct MI325X 256GB OAM（OCP Accelerator Module）加速模组作为正式比较对象。它沿用CDNA 3的8个5nm XCD和4个6nm IOD计算封装，将外部内存升级为8个32GB HBM3E stack，并保持304个使能CU。8-OAM MI325X Platform的2TB总HBM和聚合资源不下放。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Advanced Micro Devices（AMD） | AMD Instinct数据中心加速器 | `[1, Product Basics]` |
| 产品家族 | Instinct MI300 Series | CDNA 3离散GPU，与MI300X共享计算架构 | `[1, Product Basics and GPU Specifications]` |
| 完整 SKU | AMD Instinct MI325X 256GB | 官方产品页与datasheet的独立规格对象 | `[1, full page]` `[3, Specifications]` |
| 对象形态 | OAM Module，54V UBB供电，passive cooling | 不是PCIe插卡；PCIe 5.0 x16是host接口 | `[1, Requirements and Board Specifications]` |
| 架构代际 | AMD CDNA 3 | 8 XCD、304 CU、1,216 Matrix Core | `[1, GPU Specifications]` `[2, Table 2]` |
| 发布与可用状态 | 2024-06-02预告；2024-10-10正式发布；2024 Q4生产出货、2025 Q1起OEM系统广泛可用；当前仍列出 | 预告、SKU发布和系统供货时间分开 | `[7, roadmap announcement]` `[1, Product Basics]` `[6, MI325X availability paragraph]` |
| 厂商定位 | 面向AI training、inference与HPC | datasheet明确列出generative AI、LLM、training、inference和HPC | `[1, opening]` `[3, p.1 opening]` |
| 目标 workload | Generative AI、LLM、machine learning和HPC | 不是单一推理SKU，也没有专用MoE router证据 | `[3, p.1 opening]` |
| 产品目标 | 在MI300X计算资源基础上扩大HBM容量和带宽，并保持platform drop-in compatibility | 单OAM与8-GPU平台分开 | `[3, pp.1-2]` |

本卡包含：304个使能CU、1,216个Matrix Core、各精度峰值、8 XCD/4 IOD/8 HBM3E stack、cache、PCIe、Infinity Fabric、1000W TBP、媒体单元和OAM散热形态。

本卡不包含：8-GPU MI325X Platform的2TB HBM3E、48TB/s聚合HBM带宽、平台聚合算力、主机CPU和系统功耗。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | CDNA 3 Compute Unit，含scalar、vector、matrix、load/store、L1和LDS | 与MI300X共享 | 复用[CDNA 3架构卡](../架构/AMD_CDNA3_架构.md)，本卡补304 CU实现量 | `[2, pp.5-9]` |
| die/chiplet | 8个XCD和4个IOD | 与MI300X共享主要compute/I/O实现 | XCD为5nm计算裸片；IOD为6nm memory/communication裸片 | `[2, pp.2-5 and p.10]` |
| package | 单一逻辑GPU，12个chiplet连接8个HBM3E stack | MI325X专属内存配置 | 记录3D堆叠与Infinity Fabric，不拆成8个GPU样本 | `[2, pp.2-4 and p.11]` |
| 产品配置 | MI325X 256GB OAM Module | 不适用 | 正式比较单位 | `[1, full page]` |
| 相关系统 | 8×MI325X OAM + UBB 2.0平台 | 多模组系统 | 只用于划定7-link fully connected P2P与host PCIe边界 | `[4, full document]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| CU执行组织 | 每个CU含scalar、vector、Matrix Core、load/store、32KB L1和64KB software-managed LDS | 304个使能CU | `[2, pp.5-6 and p.9]` |
| Matrix Core | 每CU有4个Matrix Core，支持FP64、FP32、TF32、FP16、BF16、FP8和INT8矩阵格式 | SKU合计1,216个；峰值按精度分别记录 | `[1, GPU Specifications]` `[2, pp.6-8]` |
| FP8 格式 | E5M2/E4M3 的 FNUZ 变体 | 特殊值和指数编码语义有别于 CDNA 4 的 OCP FP8 | `[8, Data type support and FP8 variant change]` |
| 稠密吞吐路径 | 每CU/clock：Matrix FP64/FP32各256 FLOP，TF32 1,024，FP16/BF16各2,048，FP8/INT8各4,096 operation | 2.1GHz peak engine clock；与MI300X共享CDNA 3计算实现 | `[2, Table 1]` `[1, GPU Specifications]` |
| FP8与累加 | FP8支持E5M2和E4M3；FP8/BF8与FP16/BF16 MFMA写FP32 C/D，INT8写INT32 C/D | ISA语义，不等同于物理accumulator位宽 | `[1, FP8 rows]` `[5, pp.274, 276 and 284]` |
| 结构化稀疏 | Matrix Core支持4:2 sparse，将非零值压紧并携带location metadata | 适用路径峰值为dense的2倍；metadata带宽成本未完整披露 | `[2, p.8]` `[5, pp.59-60]` |
| CU局部存储 | 64KB LDS为software scratchpad；32KB L1 vector data cache、128B cache line | L1需显式同步取得强coherence/ordering | `[2, p.9]` |
| XCD存储 | 每XCD有4MB、16-way L2，由38个使能CU共享，read throughput为2KB/clock/XCD | 8个XCD；L2为XCD内hardware-coherent cache | `[2, pp.5 and 10]` |
| 媒体单元 | datasheet列4组HEVC/H.265、AVC/H.264、VP9或AV1 decoder，以及32个JPEG/MJPEG core | 单OAM；兼容媒体软件是使用条件，不能将codec数并入Matrix Core | `[3, Decoders and Virtualization]` |
| 专用AI单元缺口 | 未找到专用attention、MoE routing、top-k或sampling物理模块 | 由通用Matrix/Vector/Scalar路径和软件完成 | `[2, pp.5-8]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算裸片 | 8个TSMC 5nm XCD；每XCD设计40 CU、使能38 CU，共304 CU | 每XCD另有4 ACE、scheduler、hardware queues和4MB L2 | `[2, pp.4-5 and Table 2]` |
| I/O裸片 | 4个TSMC 6nm IOD，每个在一对XCD下方 | IOD包含Infinity Cache、HBM接口和system communication | `[2, p.10]` |
| 物理集成 | 一颗逻辑GPU由12个chiplet构成，XCD垂直堆叠于IOD，通过Infinity Fabric on-package连接 | AMD称advanced 3D package/chiplet construction；未公开封装尺寸 | `[2, pp.2-4]` |
| HBM组成 | 8个HBM3E stack，每个32GB；每个IOD连接2 stack | 合计256GB；stack高度未公开 | `[2, p.11]` |
| 晶体管与工艺 | 153 billion transistors；TSMC 5nm XCD + 6nm IOD | 产品页未按chiplet拆晶体管数量 | `[1, GPU Specifications]` `[2, pp.5 and 10]` |
| Infinity Cache | 256MB LLC，位于4个IOD；128 channels，16-way，峰值17.2TB/s | memory-side cache/snoop filter，不保存下级L2 dirty eviction | `[1, GPU Memory]` `[2, pp.10-11]` |
| 封装内互联 | 4th Gen Infinity Fabric连接XCD、IOD、cache、HBM与外部link端点 | 未公开单一on-package aggregate payload带宽 | `[2, pp.4, 9-11 and 15]` |
| RAS与分区 | Full-chip ECC、page retirement/avoidance、SR-IOV和最多8 partitions | 分区不改变物理资源总量 | `[1, GPU Memory and Additional Features]` `[3, Decoders and Virtualization]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 304 CU、19,456 Stream Processor、1,216 Matrix Core | 8 XCD，每XCD使能38 CU | `[1, GPU Specifications]` `[2, pp.5 and Table 2]` |
| 时钟 | 2,100MHz peak engine clock | peak而非保证持续时钟 | `[1, GPU Specifications]` |
| FP8/INT8峰值 | FP8 2,614.9TFLOPS dense、5,229.8TFLOPS sparse；INT8 2,614.9TOPS dense、5,229.8TOPS sparse | E4M3/E5M2；sparse需满足4:2条件 | `[3, AI Peak Theoretical Performance]` |
| FP16/BF16峰值 | 各1,307.4TFLOPS dense、2,614.9TFLOPS sparse | Matrix path | `[3, AI Peak Theoretical Performance]` |
| TF32峰值 | 653.7TFLOPS dense、1,307.4TFLOPS sparse | 当前SKU datasheet直接值；白皮书Table 1另写490.3TFLOPS dense | `[3, AI Peak Theoretical Performance]` `[2, Table 1]` |
| FP32/FP64峰值 | FP32 Matrix/Vector各163.4TFLOPS；FP64 Matrix 163.4、Vector 81.7TFLOPS | Matrix与Vector路径不能相加 | `[3, HPC Peak Theoretical Performance]` |
| HBM | 256GB HBM3E、8,192-bit、最高6.0GT/s、6TB/s；Full-chip ECC | 8×32GB stack；bandwidth为max peak theoretical | `[1, GPU Memory]` `[2, p.11]` `[3, Specifications]` |
| Cache | 256MB Infinity Cache；每XCD另有4MB L2，每CU有32KB L1和64KB LDS | LLC、L2、L1与scratchpad管理语义分开 | `[1, GPU Memory]` `[2, pp.9-11]` |
| Host接口 | 1×PCIe Gen5 x16，128GB/s | host CPU I/O口径 | `[3, Specifications]` |
| GPU P2P端点 | 7条bidirectional Infinity Fabric scale-up link，每条128GB/s；另有host PCIe | 平台资料把七链路配置标为896GB/s aggregate；当前产品页另写8条IF | `[3, Specifications]` `[1, Board Specifications]` `[4, High-Speed GPU Interconnects]` |
| 功耗 | 1000W maximum TBP | 单OAM，不是8-GPU baseboard或服务器功耗 | `[3, Specifications]` |
| 形态与散热 | OAM Module、54V UBB、passive OAM | 需要系统级冷却；模块温度、风量/液流未公开 | `[1, Requirements and Board Specifications]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| 8-GPU平台 | UBB 2.0承载8块MI325X OAM，总HBM为2,048GB/约2TB | 不是一块MI325X的容量或板卡形态 | `[4, overview and diagram]` |
| Scale-up拓扑 | 每块GPU用7条128GB/s IF link与其余7块GPU fully connected；每OAM另有PCIe Gen5 x16 | 平台P2P aggregate为896GB/s，不写成单链路速率 | `[4, High-Speed GPU Interconnects]` |
| 聚合资源 | 平台总HBM带宽48TB/s，并有8-GPU聚合算力 | 这些值只属于8-OAM系统，不回填单OAM | `[4, specifications]` |
| Scale-out | platform datasheet仅给每OAM PCIe Gen5 x16 scale-out/network bandwidth端点 | 外部NIC和网络拓扑由OEM/server决定 | `[3, Specifications]` `[4, full document]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| MI325X与MI300X | 计算实现相同，HBM/TBP不同 | 两者均304 CU、1,216 Matrix Core、2.1GHz；MI325X为256GB HBM3E/6TB/s/1000W | 不把共享计算规格解释为同一SKU |
| 预告与正式HBM容量 | 发布前规格发生变化 | 2024-06路线图预告288GB HBM3E；2024-10正式发布及当前datasheet为256GB | 正式SKU字段采用256GB，288GB只保留为pre-launch规划值 |
| TF32 dense峰值 | 官方资料及白皮书内部不一致 | 当前SKU datasheet/产品页653.7TFLOPS；CDNA 3白皮书Table 1为490.3TFLOPS | 主字段采用SKU datasheet，同一白皮书 Table 2/脚注又给653.7TFLOPS，保留此内部冲突，不猜测原因 |
| Infinity Fabric link数量 | 当前官方资料不一致 | SKU datasheet写7条scale-up IF加1条host PCIe；产品页写8条IF | 主字段采用datasheet的7×128GB/s，网页值保留为冲突 |
| sparse峰值 | 条件明确但metadata成本不完整 | datasheet为2×dense headline；白皮书说明4:2与location metadata | 保留sparse条件，不与dense等价比较 |
| HBM与cache共享语义 | 容易跨SKU或跨系统误读 | MI325X单OAM 256GB；8-GPU平台约2TB；Infinity Cache只在单GPU内共享 | 三层对象分开 |
| 物理封装细节 | 部分公开 | 已知8 XCD、4 IOD、8 HBM3E、5/6nm与3D堆叠；interposer/hybrid-bonding名称、封装尺寸未确认 | 未公开项保持缺失 |
| 功耗与散热条件 | 部分公开 | 1000W maximum TBP与passive OAM明确，典型功耗、温度、风量/液流未公开 | 不从platform/server反推 |
| 散热表述 | 官方资料粒度不同 | 当前SKU页写Passive OAM；CDNA 3白皮书Table 2写Passive and Liquid | 主形态按SKU页记录，液冷只表示系统可选方案，不推断冷板参数 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | AMD，*AMD Instinct MI325X Accelerators* | 当前官方SKU产品页 | SKU、资源、HBM、PCIe、Infinity Fabric、1000W、OAM与RAS | <https://www.amd.com/en/products/accelerators/instinct/mi300/mi325x.html> |
| `[2]` | AMD，*Introducing AMD CDNA 3 Architecture* | 官方架构白皮书 | XCD/IOD/package、CU、cache/HBM层次、稀疏与通信机制 | [本地PDF](../../../原始资料/论文/AMD_Instinct/01_厂商直接架构论文/2025_AMD_CDNA_3_Architecture_White_Paper.pdf) |
| `[3]` | AMD，*AMD Instinct MI325X Accelerator Data Sheet* | 当前官方SKU datasheet | 精确峰值、HBM3E、媒体单元、7×IF、PCIe与1000W | <https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/product-briefs/instinct-mi325x-datasheet.pdf> |
| `[4]` | AMD，*AMD Instinct MI325X Platform Data Sheet* | 官方平台datasheet | 8×OAM、UBB 2.0、2TB HBM与系统互联边界 | <https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/product-briefs/instinct-mi325x-platform-datasheet.pdf> |
| `[5]` | AMD，*AMD Instinct MI300 Instruction Set Architecture* | 官方ISA | MFMA累加格式与4:2 sparse指令语义 | <https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/instruction-set-architectures/amd-instinct-mi300-cdna3-instruction-set-architecture.pdf> |
| `[6]` | AMD，*AMD Delivers Leadership AI Performance with AMD Instinct MI325X Accelerators*，2024-10-10 | 官方发布稿 | 正式发布、出货时间和training/inference定位 | <https://www.amd.com/en/newsroom/press-releases/2024-10-10-amd-delivers-leadership-ai-performance-with-amd-in.html> |
| `[7]` | AMD，*AMD Accelerates Pace of Data Center AI Innovation*，2024-06-02 | 官方路线图公告 | 首次预告日期和288GB pre-launch规格 | <https://www.amd.com/en/newsroom/press-releases/2024-6-2-amd-accelerates-pace-of-data-center-ai-innovation-.html> |
| `[8]` | AMD ROCm，*AMD Instinct MI300 Series / MI350 Series workload optimization*，7.2.4 | 官方硬件优化文档 | CDNA 3 的 FP8 FNUZ 与 CDNA 4 的 OCP 编码区别 | <https://rocm.docs.amd.com/en/docs-7.2.4/how-to/rocm-for-ai/inference-optimization/workload.html> |

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

复核结论：AMD Instinct MI325X 256GB的主语已经固定为一块1000W passive OAM module。8个5nm XCD、4个6nm IOD、8个HBM3E stack、304个CU、1,216个Matrix Core、256GB HBM3E、6TB/s、PCIe Gen5 x16和SKU datasheet所列896GB/s GPU P2P均有AMD一手资料支持；8-GPU UBB平台没有下放。MI325X与MI300X共享CDNA 3计算资源，但HBM、功耗和正式SKU不同。TF32 653.7/490.3TFLOPS及7/8条Infinity Fabric的官方差异按原始来源保留；具体interposer/hybrid-bonding、封装尺寸、典型功耗、环境条件和专用MoE/attention单元保持缺失。
