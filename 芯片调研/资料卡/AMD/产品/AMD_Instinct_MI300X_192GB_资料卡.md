# AMD Instinct MI300X 192GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

本卡采用一块AMD Instinct MI300X 192GB OAM（OCP Accelerator Module）加速模组作为正式比较对象。它是一颗逻辑GPU，由8个5nm XCD（Accelerator Complex Die，计算裸片）垂直堆叠在4个6nm IOD（I/O Die）上，并连接8个HBM3 stack。8-OAM UBB 2.0平台的聚合资源不下放。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Advanced Micro Devices（AMD） | AMD Instinct数据中心加速器 | `[1, Product Basics]` |
| 产品家族 | Instinct MI300 Series | CDNA 3离散GPU，不是带Zen 4 CPU的MI300A APU | `[1, Product Basics and GPU Specifications]` `[2, pp.3-4]` |
| 完整 SKU | AMD Instinct MI300X 192GB | 官方产品页的独立规格对象 | `[1, full page]` |
| 对象形态 | OAM Module，54V UBB供电，passive cooling | 不是PCIe插卡；PCIe 5.0 x16是总线接口 | `[1, Requirements and Board Specifications]` |
| 架构代际 | AMD CDNA 3 | 8 XCD、304 CU、1,216 Matrix Core | `[1, GPU Specifications]` `[2, Table 2]` |
| 发布与可用状态 | 2023-12-06发布；当前AMD产品页仍列出，未标为legacy | Launch Date与新闻稿日期一致 | `[1, Product Basics]` `[4, page date and opening]` |
| 厂商定位 | Generative AI与HPC accelerator，覆盖training和inference | 产品定位，不把单一benchmark写成硬件属性 | `[1, opening]` `[2, pp.2-3 and p.16]` |
| 目标 workload | LLM、generative AI、AI training/inference和HPC | 不是MoE router或attention专用芯片 | `[1, opening]` `[4, opening]` |
| 产品目标 | 以chiplet、HBM3、FP8和Infinity Fabric提高单模组与多GPU节点能力 | 单OAM与8-GPU UBB平台分开 | `[2, pp.2-4 and pp.15-17]` |

本卡包含：304个使能CU、1,216个Matrix Core、各精度峰值、8 XCD/4 IOD/8 HBM3 stack、cache、PCIe、Infinity Fabric、TBP和OAM散热形态。

本卡不包含：8-GPU MI300X Platform的1.5TB HBM、聚合算力、主机CPU、UBB系统功耗及机箱网络。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | CDNA 3 Compute Unit，含scalar、vector、matrix、load/store、L1和LDS路径 | 与MI300A、MI325X共享代际机制 | 复用[CDNA 3架构卡](../架构/AMD_CDNA3_架构.md)，本卡补304 CU实现量 | `[2, pp.5-9]` |
| die/chiplet | 8个XCD和4个IOD | XCD/IOD架构由MI300 Series共享，SKU使能量不同 | XCD为5nm计算裸片；IOD为6nm memory/communication裸片 | `[2, pp.2-5 and p.10]` |
| package | 单一逻辑GPU，12个chiplet连接8个HBM3 stack | MI300X物理实现 | 记录3D堆叠与Infinity Fabric，不拆成8个GPU样本 | `[2, pp.2-4 and p.11]` |
| 产品配置 | MI300X 192GB OAM Module | 不适用 | 正式比较单位 | `[1, full page]` |
| 相关系统 | 8×MI300X OAM + UBB 2.0平台 | 多模组系统 | 只用于划定7-link fully connected P2P与host PCIe边界 | `[2, pp.15-17]` `[5, p.1]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| CU执行组织 | 每个CU含scalar、vector、Matrix Core、load/store、32KB L1和64KB software-managed LDS | 304个使能CU；wavefront和寄存器细节沿ISA/架构复用 | `[2, pp.5-6 and p.9]` |
| Matrix Core | 每CU有4个Matrix Core，支持FP64、FP32、TF32、FP16、BF16、FP8和INT8矩阵格式 | SKU合计1,216个；峰值需按精度分别读取 | `[1, GPU Specifications]` `[2, pp.6-8]` |
| 稠密吞吐路径 | 每CU/clock：Matrix FP64/FP32各256 FLOP，TF32 1,024，FP16/BF16各2,048，FP8/INT8各4,096 operation | 2.1GHz peak engine clock；不能把不同路径相加 | `[2, Table 1]` `[1, GPU Specifications]` |
| FP8格式 | 支持 E5M2/E4M3 的 FNUZ 变体；不能与 CDNA 4 的 OCP FP8 编码语义等同 | FNUZ 的特殊值和指数编码规则有别于 OCP；白皮书中的典型用途不是硬件限制 | `[9, Data type support and FP8 variant change]` |
| 程序员可见累加 | FP8/BF8与FP16/BF16 MFMA写FP32 C/D，INT8 MFMA写INT32 C/D | ISA语义；不等同于公开了物理accumulator位宽 | `[3, pp.274, 276 and 284]` |
| 结构化稀疏 | Matrix Core支持4:2 sparse：每4个输入至少2个为0，以压缩非零值和location metadata进入pipeline | 可使适用矩阵路径吞吐翻倍；metadata编码成本未完整披露 | `[2, p.8]` `[3, pp.59-60]` |
| CU局部存储 | 64KB LDS为software scratchpad；32KB L1 vector data cache、128B cache line | L1 coherence较弱，需要显式同步取得强ordering | `[2, p.9]` |
| XCD存储 | 每XCD有4MB、16-way L2，由38个使能CU共享，read throughput为2KB/clock/XCD | 8个XCD；L2是XCD内hardware-coherent writeback/write-allocate cache | `[2, pp.5 and 10]` |
| 特殊单元缺口 | 未找到专用attention、MoE routing、top-k或sampling物理模块 | 这些工作负载由通用Matrix/Vector/Scalar与软件完成 | `[2, pp.5-8]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算裸片 | 8个TSMC 5nm XCD；每XCD物理设计40 CU、使能38 CU，共304 CU | 每XCD另有4 ACE、scheduler、hardware queues和4MB L2 | `[2, pp.4-5]` |
| I/O裸片 | 4个TSMC 6nm IOD，每个在一对XCD下方 | IOD包含Infinity Cache、HBM3接口和system communication | `[2, p.10]` |
| 物理集成 | 一颗逻辑GPU由12个chiplet构成，XCD垂直堆叠于IOD，并通过Infinity Fabric on-package连接 | AMD称其为advanced 3D package/chiplet construction；未公开封装尺寸 | `[2, pp.2-4]` |
| HBM组成 | 8个HBM3 stack，每个24GB；每个IOD连接2 stack | 合计192GB；stack高度和具体封装工艺未公开 | `[2, p.11]` |
| 晶体管与工艺 | 153 billion transistors；TSMC 5nm XCD + 6nm IOD | 产品页未按chiplet拆晶体管数量 | `[1, GPU Specifications]` `[2, pp.5 and 10]` |
| Infinity Cache | 256MB LLC，位于4个IOD；128 channels，16-way，峰值17.2TB/s | memory-side cache/snoop filter，不保存下级L2 dirty eviction | `[1, GPU Memory]` `[2, pp.10-11]` |
| 封装内互联 | 4th Gen AMD Infinity Fabric连接XCD、IOD、cache、HBM与外部link端点 | 未公开单一on-package aggregate payload带宽；cache路径带宽不可冒充D2D带宽 | `[2, pp.4, 9-11 and 15]` |
| RAS与分区 | Full-chip memory ECC、RAS、page retirement/avoidance和SR-IOV均有官方支持 | GPU可按XCD做SPX/DPX/QPX/CPX partition，HBM另有NPS1/NPS4；分区不改变物理资源总量 | `[1, GPU Memory and Additional Features]` `[2, pp.12-14]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 304 CU、19,456 Stream Processor、1,216 Matrix Core | 8 XCD，每XCD使能38 CU | `[1, GPU Specifications]` `[2, pp.5 and Table 2]` |
| 时钟 | 2,100MHz peak engine clock | peak而非保证持续时钟 | `[1, GPU Specifications]` |
| FP8/INT8峰值 | FP8 2.61PFLOPS dense、5.22PFLOPS sparse；INT8 2.6POPS dense、5.22POPS sparse | E4M3/E5M2；sparse需满足4:2条件 | `[1, GPU Specifications]` |
| FP16/BF16峰值 | 各1.3PFLOPS dense、2.61PFLOPS sparse | Matrix path；产品页按两位小数展示 | `[1, GPU Specifications]` |
| TF32峰值 | 653.7TFLOPS dense、1.3PFLOPS sparse | 当前产品页直接值；白皮书Table 1另写490.3TFLOPS，见冲突表 | `[1, GPU Specifications]` `[2, Table 1]` |
| FP32/FP64峰值 | FP32 Matrix 163.4TFLOPS，FP32 Vector 163.4TFLOPS；FP64 Matrix 163.4TFLOPS，FP64 Vector 81.7TFLOPS | Matrix与Vector路径不能相加为“总峰值” | `[1, GPU Specifications]` |
| HBM | 192GB HBM3、8,192-bit、5.2Gbps、5.3TB/s；Full-chip ECC | 8×24GB stack；bandwidth为peak theoretical | `[1, GPU Memory]` `[2, p.11]` |
| Cache | 256MB Infinity Cache；每XCD另有4MB L2，每CU有32KB L1和64KB LDS | LLC、L2、L1与scratchpad管理语义分开 | `[1, GPU Memory]` `[2, pp.9-11]` |
| Host接口 | PCIe 5.0 x16 | 8-GPU平台将一个multi-purpose link配置为host PCIe | `[1, Board Specifications]` `[2, pp.15-17]` |
| GPU P2P端点 | SKU datasheet为7条bidirectional Infinity Fabric scale-up link，每条128GB/s；另有1×PCIe Gen5 x16 host link | 平台资料把七链路配置标为896GB/s aggregate；当前产品页另写8条IF、最高1,024GB/s/OAM，按官方差异保留 | `[8, pp.1-2]` `[1, Board Specifications]` `[7, MI300-11 footnote]` |
| 功耗 | 750W peak TBP | OAM module口径，不是8-GPU baseboard或服务器功耗 | `[1, Requirements]` |
| 形态与散热 | OAM Module、54V UBB、passive OAM | 需要系统风冷/液冷基础设施带走热量，产品页未给模块温度/风量条件 | `[1, Requirements and Board Specifications]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| 8-GPU平台 | UBB 2.0承载8块MI300X OAM，总HBM为1.5TB | 不是一块MI300X的容量或板卡形态 | `[5, p.1]` |
| Scale-up拓扑 | 每块GPU用7条Infinity Fabric link与其余7块GPU fully connected；host经PCIe Gen5 x16连接 | 标准平台按7×128GB/s P2P加1条host PCIe配置 | `[2, pp.15-17]` `[8, p.2]` |
| 聚合性能 | 平台资料给8-GPU聚合算力、HBM带宽和总TBP | 不除以8生成新SKU事实，也不把系统数字写入单OAM字段 | `[5, specifications]` |
| Scale-out | 平台外部网络由OEM/server设计决定 | 未找到MI300X OAM自带以太网或InfiniBand NIC的证据 | `[5, full document]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| OAM、UBB与8-GPU Platform | 对象层级不同 | OAM是本SKU；UBB 2.0是8块OAM系统 | 卡内只保留单OAM直接规格，平台值只用于边界 |
| TF32 dense峰值 | 官方资料及白皮书内部不一致 | 当前产品页653.7TFLOPS；2025 CDNA 3白皮书Table 1为490.3TFLOPS | 主字段采用当前SKU产品页，同一白皮书 Table 2/脚注又给653.7TFLOPS，保留此内部冲突，不猜测时钟或勘误原因 |
| sparse峰值 | 条件明确但metadata成本不完整 | 产品页为2×dense headline；白皮书说明4:2数据与location metadata | 保留sparse条件，不与dense等价比较 |
| Infinity Fabric link数量 | 当前官方资料不一致 | SKU datasheet与platform资料写7条scale-up IF加1条host PCIe；当前产品页写8条IF、最高1,024GB/s | 主字段采用SKU datasheet的7×128GB/s与896GB/s，网页值保留为冲突，不把PCIe计入IF |
| 物理封装细节 | 部分公开 | 已知8 XCD、4 IOD、8 HBM、5/6nm与3D堆叠；hybrid bonding名称、interposer实现、封装尺寸未在本轮最小来源中确认 | 未公开项保持缺失 |
| 功耗与散热条件 | 部分公开 | 750W peak TBP与passive OAM明确，典型功耗、温度、风量/液流未公开 | 不从平台或服务器规格反推 |
| 主机一致性与统一内存 | 不适用/未公开 | MI300X是离散GPU，白皮书的CPU-GPU unified HBM属于MI300A | 不把MI300A语义下放到MI300X |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | AMD，*AMD Instinct MI300X Accelerators* | 当前官方SKU产品页 | SKU、计算峰值、资源、HBM、PCIe、Infinity Fabric、TBP、OAM与RAS | <https://www.amd.com/en/products/accelerators/instinct/mi300/mi300x.html> |
| `[2]` | AMD，*Introducing AMD CDNA 3 Architecture* | 官方架构白皮书 | XCD/IOD/3D package、CU、cache/HBM层次、稀疏与8-GPU拓扑 | [本地PDF](../../../原始资料/论文/AMD_Instinct/01_厂商直接架构论文/2025_AMD_CDNA_3_Architecture_White_Paper.pdf) |
| `[3]` | AMD，*AMD Instinct MI300 Instruction Set Architecture* | 官方ISA | MFMA累加格式与4:2 sparse指令语义 | <https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/instruction-set-architectures/amd-instinct-mi300-cdna3-instruction-set-architecture.pdf> |
| `[4]` | AMD，*AMD Delivers Leadership Portfolio of Data Center AI Solutions with AMD Instinct MI300 Series*，2023-12-06 | 官方发布稿 | 发布日期、AI/HPC定位与MI300X平台边界 | <https://www.amd.com/en/newsroom/press-releases/2023-12-6-amd-delivers-leadership-portfolio-of-data-center-a.html> |
| `[5]` | AMD，*AMD Instinct MI300X Platform* | 官方平台datasheet | 8×OAM、UBB 2.0和系统聚合边界 | <https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/data-sheets/amd-instinct-mi300x-platform-data-sheet.pdf> |
| `[6]` | AMD ROCm，*AMD Instinct MI300 series microarchitecture* | 官方开发文档 | XCD/CU/cache组织交叉核对 | <https://instinct.docs.amd.com/develop/gpu-arch/mi300.html> |
| `[7]` | AMD，*AMD Instinct MI300 Series Accelerators* | 官方家族页 | 1,024GB/s per-OAM P2P聚合脚注与MI300X/MI325X边界 | <https://www.amd.com/en/products/accelerators/instinct/mi300.html> |
| `[8]` | AMD，*AMD Instinct MI300X Accelerator Data Sheet* | 当前官方SKU datasheet | 单OAM精确峰值、7条scale-up IF、1条host PCIe、OAM与750W | <https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/data-sheets/amd-instinct-mi300x-data-sheet.pdf> |
| `[9]` | AMD ROCm，*AMD Instinct MI300 Series / MI350 Series workload optimization*，7.2.4 | 官方硬件优化文档 | CDNA 3 的 FP8 FNUZ 与 CDNA 4 的 OCP 编码区别 | <https://rocm.docs.amd.com/en/docs-7.2.4/how-to/rocm-for-ai/inference-optimization/workload.html> |

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

复核结论：AMD Instinct MI300X 192GB的主语已经固定为一块750W passive OAM module。8个5nm XCD、4个6nm IOD、8个HBM3 stack、304个CU、1,216个Matrix Core、192GB HBM3、5.3TB/s、PCIe 5.0 x16和7条128GB/s GPU P2P link均有AMD一手资料支持；8-GPU UBB平台没有下放。当前产品页计算峰值按dense/sparse和Matrix/Vector条件分开记录，MI300A统一内存语义没有混入。产品页8条IF/1,024GB/s与datasheet 7条IF及平台896GB/s聚合值的差异、以及TF32 653.7/490.3TFLOPS冲突均按原始作用域保留；具体interposer/hybrid-bonding、封装尺寸、典型功耗、环境条件和专用MoE/attention单元保持缺失。
