# AMD Instinct MI455X EAM 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-16

本卡以一个 AMD Instinct MI455X Enhanced Accelerator Module（EAM，增强型加速器模组）为正式比较对象。产品页把它列为一个 MI455X GPU，采用 AMD CDNA 5 架构，专门面向 Helios rack-scale solution。4-GPU compute tray 和 72-GPU Helios rack 是上层系统，聚合算力、容量、带宽与系统功耗不下放到单个 EAM。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Advanced Micro Devices（AMD） | AMD Instinct 数据中心加速器 | `[1, Product Basics]` |
| 产品家族 | AMD Instinct MI400 Series | 当前家族页面和独立产品页 | `[1, Product Basics]` `[5, AMD Instinct MI400 Series GPUs]` |
| 完整 SKU | AMD Instinct MI455X | 单个 MI455X GPU/EAM | `[1, Product Basics and Board Specifications]` `[2, p.1 Specifications]` |
| 对象形态 | EAM Module，Direct Liquid Cooling（DLC，直接液冷） | 不是 4-GPU compute tray 或 72-GPU Helios rack | `[1, Board Specifications]` `[2, p.1 Specifications]` |
| 架构代际 | AMD CDNA 5 | 256 个 WGP、8 个 XCD | `[1, GPU Specifications]` `[3, Accelerated Compute Dies]` |
| 首次按型号披露 | 2025-11-11 | AMD Financial Analyst Day 博客首次具体列出 MI455X；当时仍为预览 | `[6, Advancing AI Leadership Across AMD Instinct GPUs and ROCm]` |
| 正式发布与当前状态 | 2026-07-23 发布；当前仍列出 | Helios 已进入生产，系统预计 2026 年下半年 volume deployment；单 EAM 独立首批出货日未公开 | `[1, Product Basics]` `[7, News Highlights and opening]` `[5, FAQ]` |
| 厂商定位 | 面向 frontier AI 的 inference、training 与 fine-tuning，并专门用于 Helios | 属于产品定位，不等于特定模型实测 | `[1, opening]` `[5, Meet the AMD Instinct MI400 Series GPUs]` |

本卡包含单个 MI455X EAM 的计算资源、理论峰值、HBM4、cache、封装组成、互联端点、媒体单元、虚拟化与 RAS（Reliability, Availability and Serviceability，可靠性、可用性和可维护性）。

本卡不包含 Helios 的 2.9EFLOPS FP4、31TB HBM4、1.67PB/s HBM 带宽、260TB/s scale-up 带宽、43TB/s scale-out 带宽，也不包含 tray、rack、EPYC CPU、AI NIC、DPU、系统供电与系统散热指标。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | CDNA 5 Wave32 WGP（Work Group Processor，工作组处理器） | 属于 CDNA 5 架构代际 | 复用 [CDNA 5 架构卡](../架构/AMD_CDNA5_架构.md)，本卡记录 256 个使能 WGP 和 2.4GHz 配置 | `[4, pp.6-10]` `[1, GPU Specifications]` |
| compute die | 8 个 XCD（Accelerated Compute Die，加速计算裸片） | MI455X 的计算 chiplet | 每 XCD 启用 32 个 WGP，分成两个各 16 WGP 的 Shader Engine | `[2, p.1 Specifications]` `[4, p.6]` |
| specialized die | 2 个 IOD（I/O Die）及 2 个 fabric/cache die | MI455X 的 I/O、fabric、cache 与 HBM 接口实现 | brochure 只列 8 XCD、2 IOD；CDNA 页面另披露 2 个 fabric/cache die | `[2, p.1 Specifications]` `[3, I/O Die and Fabric and Cache Die]` |
| package | 3D hybrid-bonded compute dies、Infinity Fabric、高密度互联与 CoWoS-L | 单个 MI455X EAM 的多芯粒封装 | 不从页面示意图推导 die 面积、键合 pitch 或总 chiplet 数 | `[3, Advanced Packaging]` `[5, Advanced Packaging Technology]` |
| 产品配置 | MI455X EAM，2.4GHz、432GB HBM4、DLC | 正式比较单位 | `[1, full page]` `[2, p.1]` |
| 相关系统 | 4-GPU compute tray、18-tray/72-GPU Helios reference design | 上层部署系统 | 只用于说明 UALoE/UALink 的系统语境，不下放聚合资源 | `[2, p.2]` `[8, Rackscale Highlights, Compute Tray and FAQ]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| WGP 执行组织 | Wave32 WGP 含 4 个 32-thread SIMD 单元和 4 个 scalar 单元，共享 constant cache | 本 SKU 产品页列 256 个 WGP；brochure 将同一数量写为 256 Compute Units | `[4, p.6]` `[1, GPU Specifications]` `[2, p.1 Specifications]` |
| Matrix 路径 | Wave32 WMMA 与 2:4 structured-sparse SWMMAC | 属于 CDNA 5 ISA 语义；不能由指令数量反推物理 Matrix Core 数 | `[9, pp.105-106 and 466-473]` |
| 数值格式与累加 | FP4 WMMA 支持 FP32 C/D；FP8 WMMA 可采用 FP32 或 FP16 C/D；INT8 路径采用 signed INT32 C/D | 程序员可见语义，不等于物理 accumulator 位宽 | `[9, pp.467-473]` |
| 结构化稀疏 | SWMMAC 的 A 矩阵沿 K 轴每 4 个元素有 2 个零，并由 index 指明零位置 | 产品峰值表只为 FP16、BF16、INT8 给出 structured-sparsity 列；不为 MXFP/FP8 自行乘二 | `[9, pp.466-467]` `[2, p.1 AI Peak Theoretical Performance]` |
| 数据搬运 | 每 WGP 有异步 Tensor Data Mover（TDM），支持最多 5D tile、descriptor transfer、multicast 及 DRAM 与 LDS 直接传输 | TDM 是通用 tensor 搬运引擎，不等同于 MoE router | `[4, p.10]` |
| 本地存储 | 每 WGP 有 320KB LDS、64KB vector cache、16KB constant cache、64KB instruction cache | LDS 是 software-managed scratchpad，其余为 hardware cache | `[4, p.10]` |
| 特殊数学路径 | 新增 tanh，并把既有 transcendental operations 吞吐相对 MI355X 提高 2 倍 | 是通用执行路径，不构成专用 attention 或 softmax 单元证据 | `[4, p.7]` |
| 专用 LLM 单元缺口 | 未找到专用 attention、MoE routing、top-k、sampling 或 KV Cache 管理物理模块 | 相关 workload 可由通用执行与软件完成，但不能据此宣称专用硬件 | `[4, pp.6-10]` `[9, relevant instruction sections]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算裸片 | 8 个 TSMC N2 XCD，共启用 256 个 WGP；每 XCD 为 32 个 WGP、两个 Shader Engine | N2 是 2nm gate-all-around；不是从产品页聚合工艺自行推导 | `[2, p.1 Specifications]` `[4, pp.6 and 14]` |
| I/O 裸片 | 2 个 enhanced I/O die | 支持 2×PCIe 6-compatible NIC 或 3×AMD AI NIC，并承载 CPU-GPU 与 UALoE 连接 | `[3, I/O Die and Unified Fabric and I/O]` |
| Fabric/cache 裸片 | 2 个 TSMC N3P fabric and cache die（FCD），提供 192-channel HBM4 interface 与 192MB global L2 | 每个 FCD 有 96 个 1MB L2 block，aggregate L2 bandwidth 27TB/s；全 GPU 为 54TB/s | `[3, Fabric and Cache Die]` `[4, pp.10 and 14]` |
| 物理集成 | 3D hybrid-bonded compute dies，经 Infinity Fabric 连接 specialized dies，采用 advanced CoWoS-L package | 封装尺寸、die 面积、hybrid-bond pitch 未公开 | `[3, Advanced Packaging]` `[5, Advanced Packaging Technology]` |
| HBM 组成 | 12 个 HBM4 stack，合计 432GB；每 stack 为 2,048-bit interface | 可由 12×2,048bit 复算总接口宽度，但本卡保留官方逐 stack 原值；memory clock 未公开 | `[1, GPU Memory]` `[4, p.9]` |
| 晶体管与工艺 | 320 billion transistors；TSMC 2nm / 3nm FinFET | 产品页没有按 chiplet 拆分晶体管数或工艺 | `[1, GPU Specifications]` |
| RAS、安全与分区 | Full-chip ECC、page retirement、SR-IOV；brochure 写 4 个 memory partition，但白皮书 Figure 5 给 NPS1/NPS2 | 计算分区与内存 NUMA 模式分开；内存分区冲突见第 7 节。brochure 另描述 expanded device attestation、link/memory encryption 和 secure multi-GPU scaling，未给定量开销 | `[2, pp.1-2]` `[4, p.8 Figure 5]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 256 WGP | 产品页与架构页术语；brochure 同一数量标为 256 Compute Units，不据此推导传统 CU 数 | `[1, GPU Specifications]` `[2, p.1 Specifications]` `[3, Accelerated Compute Dies]` |
| 时钟 | 2,400MHz peak engine clock | 峰值，不是保证持续频率 | `[1, GPU Specifications]` |
| MXFP 峰值 | OCP MXFP4 40,265TFLOPS；MXFP6 20,133TFLOPS；MXFP8 20,133TFLOPS | 单 EAM 的 peak theoretical performance；官方未列 structured-sparse MXFP 值 | `[2, p.1 AI Peak Theoretical Performance]` |
| OCP-FP8 峰值 | 20,133TFLOPS | 单 EAM 理论峰值；编码与 structured-sparse 值未在该表展开 | `[2, p.1 AI Peak Theoretical Performance]` |
| FP16 / BF16 Matrix 峰值 | 各 5,033TFLOPS 基础值、10,066TFLOPS structured sparsity | 右值为 structured-sparsity 列，不是实测 | `[2, p.1 AI Peak Theoretical Performance]` |
| INT8 Matrix 峰值 | 5,033TOPS 基础值、10,066TOPS structured sparsity | 整数路径使用 OP/s，不写成 FLOP/s | `[2, p.1 AI Peak Theoretical Performance]` |
| FP16 / FP32 / FP64 峰值 | FP16 vector 315TFLOPS；FP32 Matrix/Vector 各 315TFLOPS；FP64 Matrix/Vector 各 5TFLOPS | 不同路径不能相加；产品页的 40.3/20.1/5/10.1PFLOPS 是相同精确值的舍入 | `[1, GPU Specifications]` `[2, p.1 performance tables]` |
| HBM | 432GB HBM4、12 stacks、23.3TB/s peak bandwidth；Full-chip ECC | 单 EAM；HBM 总线宽度、时钟与持续 workload 带宽未公开 | `[1, GPU Memory]` `[2, p.1 Specifications]` |
| Cache / scratchpad | 192MB global L2、54TB/s aggregate L2 bandwidth；每 WGP 320KB LDS、64KB vector cache、16KB constant cache、64KB instruction cache | global cache、per-WGP hardware cache 与 software-managed LDS 分开；L2 带宽是全 GPU aggregate，不是 HBM 带宽 | `[1, GPU Memory]` `[4, p.10 and pp.21-22]` |
| CPU-GPU 互联 | AMD Infinity Fabric 256GB/s bidirectional | brochure 只写 256GB/s；方向由 CDNA 页面补充，payload 与持续口径未公开 | `[2, p.1 Specifications]` `[3, Unified Fabric and I/O]` |
| Scale-up 端点 | 36 条 bidirectional UALoE links（x2），单 EAM 合计 3.6TB/s bidirectional | 面向 Helios scale-up domain；不是 HBM 带宽 | `[1, Board Specifications]` `[3, Unified Fabric and I/O]` |
| Scale-out 端点 | UALink，600GB/s peak bidirectional | 可选 2×PCIe Gen6 x16 连接两个外部 NIC，或最多 3×UALink x8 连接三个外部 NIC；每 NIC 最高 800Gb/s（200GB/s 双向），三 NIC 汇总 600GB/s 双向。不是 GPU 自带以太网 MAC 的声明；持续 payload 与外部网络拓扑未公开 | `[1, Board Specifications]` `[2, p.1 Specifications]` `[4, p.13 Scale-Out Networking]` |
| 功耗与供电 | 未公开 | 当前产品页和专用 brochure 均未给单 EAM 的 TBP/TDP、峰值功耗、输入电压或连接器；不从 Helios 系统反推 | `[1, full page]` `[2, pp.1-2]` |
| 形态与散热 | EAM Module；Liquid / Direct Liquid Cooling | 液冷流量、压降、入口温度、EAM 尺寸与重量未公开 | `[1, Board Specifications]` `[2, p.1 Specifications]` |
| 媒体与虚拟化 | 4 个 video decoder engine，支持 HEVC/H.265、AVC/H.264、VP9、AV1；40 个 JPEG/MJPEG core；SR-IOV | JPEG/MJPEG 为 10 core/group；软件与分区条件未展开 | `[2, p.1 Decoders and Virtualization]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Compute tray | 每个 tray 含 4 个 MI455X GPU，并另有 EPYC CPU、AI NIC、DPU 等系统部件 | 不是一个 EAM；tray 资源与功耗不得回填单 GPU | `[8, Compute Tray]` |
| Helios rack | 18 个 compute tray，共 72 个 MI455X GPU | 2.9EFLOPS FP4、31TB HBM4、260TB/s scale-up 与 43TB/s scale-out 均为 rack aggregate | `[2, p.2]` `[8, Rackscale Highlights]` |
| 产品属性 | Helios 是供 OEM/ODM 构建系统的 reference design，不是 AMD 直接销售的单一产品 | MI455X 产品页仍以单 GPU/EAM 列规格 | `[8, FAQ: Is the AMD Helios rackscale solution an AMD product or a reference design?]` `[1, full page]` |
| 供货语境 | Helios 已进入生产，reference design 正交付合作伙伴，系统预计 2026 年下半年 volume deployment | 不等于单个 MI455X EAM 已有独立 GA 或零售日期 | `[7, opening]` `[5, FAQ]` |

## 7. 证据缺口与来源差异

| 项目 | 状态 | 已检查范围或差异来源 | 当前处理 |
|---|---|---|---|
| WGP / Compute Unit 术语 | 官方资料用词不同 | 产品页与 CDNA 页面写 256 WGP；brochure 写 256 Compute Units | 主字段采用当前产品页术语，同时保留 brochure 原词；不把二者视为两组资源 |
| HBM 带宽 | Helios 页面内部存在旧值 | MI455X 产品页、brochure 和 Helios highlights 均写 23.3TB/s per GPU；Helios compute-tray 段仍写 19.6TB/s per GPU | 单 EAM 采用当前 exact-SKU 页面与 brochure 的 23.3TB/s，并登记页面内部版本差异 |
| EAM 与 tray 措辞 | brochure p.2 散文句语法含混 | p.1 正式规格字段和产品页均把 MI455X 的 form factor 写为 EAM；p.2 同时明确 4-GPU tray 与 72-GPU rack | 以正式 SKU 字段确定单 GPU/EAM 主语，不把 4 个 GPU 合并成一个 EAM |
| XCD、IOD 与 fabric/cache die | 来源披露粒度不同 | brochure 简表只列 8 XCD、2 IOD；CDNA 页面另列 2 个 fabric/cache die | CDNA 5 白皮书 p.14 明确列 8 XCD、2 IOD、2 FCD，共 12 个逻辑裸片；另有 12 个 HBM4 stack，不把 HBM 内部 DRAM die 纳入上述计数 |
| 内存分区 | 官方资料不一致 | brochure p.1 写 4；白皮书 p.8 Figure 5 给 NPS1/NPS2 | 保留两者，不将 brochure 的 4 直接等同于 NPS4 |
| 工艺映射 | 部分公开 | 白皮书明确 XCD 为 TSMC N2、FCD 与 MID 为 TSMC N3P；没有在同一句明确 IOD 节点 | 只记录有明确主语的映射，不把 IOD 自动写成 N3P |
| 单 EAM 功耗 | 未公开 | 当前产品页、brochure、CDNA 白皮书与 CDNA 页面 | 保持“未公开”，不由 rack 或 tray 数值除算 |
| 物理与冷却细节 | 未公开 | 产品页和 brochure | die 面积、封装尺寸、键合 pitch、液冷流量/压降/温度、输入电压与连接器保持未公开 |
| 专用 LLM 单元 | 未找到 | 产品页、brochure、白皮书与 ISA | attention、MoE router、top-k、sampling 和 KV Cache 管理保持未公开 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | AMD，*AMD Instinct MI455X GPUs* | 当前官方 SKU 产品页 | 身份、发布日期、资源、峰值、HBM/cache、互联端点、EAM 与 DLC | <https://www.amd.com/en/products/accelerators/instinct/mi400/mi455x.html> |
| `[2]` | AMD，*AMD Instinct MI455X GPU*，LE-93204-00，07/26 | 官方 GPU brochure | 精确峰值、8 XCD/2 IOD、媒体/RAS、互联、液冷与 Helios 边界 | [本地 PDF](../../../原始资料/论文/AMD_Instinct/02_厂商产品资料/2026_AMD_Instinct_MI455X_GPU_Brochure.pdf) |
| `[3]` | AMD，*AMD CDNA Architecture* | 当前官方架构页面 | 8 XCD、2 IOD、2 fabric/cache die、WGP、HBM/cache、互联与封装 | <https://www.amd.com/en/technologies/cdna.html> |
| `[4]` | AMD，*Introducing AMD CDNA 5 Architecture* | 官方架构白皮书 | WGP、TDM、LDS/cache 与数学路径 | [本地 PDF](../../../原始资料/论文/AMD_Instinct/01_厂商直接架构论文/2026_AMD_CDNA_5_Architecture_White_Paper.pdf) |
| `[5]` | AMD，*AMD Instinct MI400 Series GPUs* | 官方家族页面 | 产品定位、封装、Helios 边界与供货语境 | <https://www.amd.com/en/products/accelerators/instinct/mi400.html> |
| `[6]` | AMD，*Advancing AI Leadership Across AMD Instinct GPUs and ROCm*，2025-11-11 | 官方博客 | MI455X 首次按型号披露 | <https://www.amd.com/en/blogs/2025/amd-cements-data-center-leadership-at-financial-analyst.html> |
| `[7]` | AMD，*AAI 2026: AMD Delivers Full-Stack Compute for the Agentic AI Era*，2026-07-23 | 官方发布稿 | MI400 正式发布与 Helios 生产状态 | <https://ir.amd.com/news-events/press-releases/detail/1294/aai-2026-amd-delivers-full-stack-compute-for-the-agentic-ai-era> |
| `[8]` | AMD，*AMD Helios Rackscale Solutions* | 官方 reference-design 页面 | 4-GPU tray、72-GPU rack、聚合指标与产品边界 | <https://www.amd.com/en/products/rackscale-solutions/helios.html> |
| `[9]` | AMD，*CDNA5 Instruction Set Architecture: Reference Guide* | 官方 ISA | WMMA/SWMMAC、累加格式与 2:4 sparse index 语义 | <https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/instruction-set-architectures/amd-instinct-cdna5-instruction-set-architecture.pdf> |

## 9. 完成检查

- [x] SKU 身份和厂商定位的主语已经固定
- [x] Core、die/chiplet、package、SKU 和系统事实没有混用
- [x] 共享下层对象已经链接复用，没有重复计为样本
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] cache、scratchpad、统一内存、一致性和远程访问的管理语义没有混写
- [x] 封装内 D2D 互联与 HBM、设备互联和系统聚合带宽已经分开
- [x] SKU 互联端点与系统拓扑、域大小和聚合带宽已经分开
- [x] 系统级互联上下文只在相关时填写
- [x] 资料卡没有混入软件生态、benchmark、部署成绩或配对分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：AMD Instinct MI455X 的正式比较对象是一个采用 EAM 形态和 DLC 的 CDNA 5 GPU。单 EAM 的 256 个 WGP、8 个 XCD、2 个 IOD、2 个 fabric/cache die、432GB HBM4、23.3TB/s、192MB L2、2.4GHz，以及 CPU-GPU、scale-up 和 scale-out 三类互联口径均有 AMD 一手资料支持。精确峰值来自固定 brochure，产品页是同组数据的舍入显示。4-GPU compute tray 和 72-GPU Helios rack 的聚合资源没有下放。单 EAM 功耗、供电、封装尺寸、die 面积、节点到各 die 的映射、液冷工况以及专用 LLM 单元保持未公开。
