# AMD Instinct MI350P 144GB PCIe 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡以一张 AMD Instinct MI350P 144GB PCIe add-in card 为正式比较对象。它是全高、全长、双槽的 PCIe CEM（Card Electromechanical）插卡，采用 4 个 XCD（Accelerated Compute Die）和 1 个 IOD（I/O Die），与 8-XCD、2-IOD 的 MI350X/MI355X OAM 模组不同。服务器中的多卡数量、主机配置和聚合算力不下放到单卡。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Advanced Micro Devices（AMD） | AMD Instinct 数据中心加速器 | `[1, Product Basics]` |
| 产品家族 | Instinct MI350 Series | CDNA 4 产品家族中的 PCIe 卡 | `[1, Product Basics and GPU Specifications]` |
| 完整 SKU | AMD Instinct MI350P 144GB | 当前官方独立产品页与 brochure 的对象 | `[1, full page]` `[2, pp.1-2]` |
| 对象形态 | PCIe add-in card；FHFL、双槽 | 不是 OAM 模组，也不是 8-GPU UBB 平台 | `[1, Board Specifications and Dimensions]` `[2, p.1 Specifications]` |
| 架构代际 | AMD CDNA 4 | 128 个使能 CU、512 个 Matrix Core | `[1, GPU Specifications]` |
| 发布与可用状态 | 2026-05-07 官方介绍；2026-07-23 正式发布；当前仍列出 | 已找到 launch 日期，但 GA、首批出货或 now shipping 日期未找到；系列页仍残留 Preview 标题 | `[3, title and opening]` `[6, Delivering the Highest Performance Data Center CPUs and GPUs]` `[5, What's New]` |
| 厂商定位 | 面向现有企业数据中心中的 generative AI、agentic AI、inference 与 RAG pipeline | 系列页把 MI350P 与面向大规模 training/inference 的 MI350X/MI355X platform 分开 | `[1, opening]` `[3, Performance That Drops into Your Existing Racks]` `[5, Platforms Built for Any Enterprise Scale AI]` |
| 产品目标 | 以标准 PCIe 卡、600W 以内功耗和被动散热接入现有机架 | “现有基础设施”是部署目标，不代表无需服务器级风冷 | `[2, p.1 opening]` `[3, Performance That Drops into Your Existing Racks]` |

本卡包含：128 个使能 CU、512 个 Matrix Core、各精度理论峰值、4 XCD/1 IOD、144GB HBM3E、128MB Infinity Cache、PCIe 5.0 x16、450W 至 600W TBP、媒体单元、分区与卡级散热形态。

本卡不包含：MI350X/MI355X 的 288GB HBM3E、8TB/s、Infinity Fabric scale-up link、OAM 功耗，或任何服务器的多卡聚合性能。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | CDNA 4 Compute Unit，含 scalar、vector、matrix、load/store、L1 与 LDS | 与 MI350X/MI355X 共享架构代际 | 复用 [CDNA 4 架构卡](../架构/AMD_CDNA4_架构.md)，本卡记录 128 CU 的实际配置 | `[4, pp.5-9]` `[1, GPU Specifications]` |
| die/chiplet | 4 个 XCD、1 个 IOD | MI350P 专属半规模 chiplet 配置 | 每个 XCD 有 32 个使能 CU；官方未公开 MI350P 的设计 CU 数或逐 die 面积 | `[2, pp.1-2]` |
| package/card | 多 chiplet GPU 封装装在一张 FHFL 双槽 PCIe 卡上 | 不与 OAM 样本合并 | 正式比较单位；144GB HBM3E 与 128MB LLC 均为整卡值 | `[1, GPU Memory and Dimensions]` `[2, pp.1-2]` |
| 相关系统 | 标准风冷服务器，最多可配置 8 张 MI350P | OEM 系统条件 | 只用于说明部署上限，不建立卡间直连拓扑或聚合带宽 | `[3, Performance That Drops into Your Existing Racks]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| CU 执行组织 | CDNA 4 CU 含 scalar、vector、Matrix Core、load/store、32KB L1 data cache 与显式寻址 LDS | 架构级机制；MI350P 共 128 个使能 CU | `[4, pp.5-6 and p.9]` `[1, GPU Specifications]` |
| Matrix Core | 每 CU 有 4 个 Matrix Core；本卡共 512 个 | 产品页直接给出整卡数量 | `[1, GPU Specifications]` |
| 数值格式 | 原生支持 BF16/FP16、OCP-FP8、INT8，以及 MXFP8、MXFP6、MXFP4 | OCP-FP8 含 E5M2/E4M3；MXFP6 含 E3M2/E2M3，MXFP4 为 E2M1；CDNA 4 已移除 TF32 硬件路径，由 BF16 软件模拟 | `[2, p.2 Multi-Chip Architecture]` `[4, pp.7-8]` |
| 结构化稀疏 | OCP-FP8、FP16、BF16、INT8 均列有 structured sparsity 峰值，数值为对应基础峰值的 2 倍 | CDNA 4 sparse MFMA 的 A 矩阵沿 K 轴每 4 个元素有 2 个零，第三输入提供 sparse index；index 带宽、选择电路和功耗未公开 | `[1, GPU Specifications]` `[7, pp.294 and 307-308]` |
| LDS | 每 CU 160KB，64 个 bank，每 bank 为 640×4B；含 32 个整数 atomic 单元；读吞吐 256B/clock，可从 L1 直接装入 | 工作组显式管理的 local storage；按 1,280B 连续块分配并按 1,280B 对齐，不能把容量当作统一 cache | `[4, p.9]` `[7, §§2.2.1,3.6.5, 印刷 pp.6,13（PDF pp.14,21）]` |
| L1/L2 | 每 CU 32KB、64-way L1，128B line；每 XCD 共享 4MB、16-way coherent L2 | brochure 直接确认 MI350P 的 32KB L1/CU 与 4MB L2/XCD；端口细节来自 CDNA 4 架构 | `[2, p.2 Multi-Chip Architecture]` `[4, p.9]` |
| L2 管理与通道 | 每 XCD 有 16 个 L2 channel，各 channel 每 cycle 读 128B、写 64B；writeback/write-allocate，XCD 内 fully coherent | CDNA 4 可缓存来自 DRAM 的 non-coherent 数据，并在脏行写回后保留副本；一致性与可见性仍须遵守地址和程序语义，不能推广成整机透明一致性 | `[4, p.9]` |
| 媒体单元 | 2 组 HEVC/H.265、AVC/H.264、VP9 或 AV1 decoder；20 个 JPEG/MJPEG core，每组 10 个 | 需要兼容 media player；不能并入 Matrix Core 数量 | `[2, p.1 Decoders and Virtualization]` |
| 专用 AI 单元缺口 | 未找到专用 attention、MoE routing、top-k、sampling 或 KV Cache 管理物理模块 | 相关 workload 由通用计算路径和软件执行 | `[1, full page]` `[2, pp.1-2]` `[4, pp.5-9]` |

### 3.1 矩阵吞吐与输入格式条件

CDNA 4 的 dense 矩阵执行能力按每 CU 每周期计，FP16/BF16 为 4,096 FLOP，OCP-FP8 为 8,192 FLOP。Vector FP16/FP32 为 256 FLOP、FP64 为 128 FLOP；Matrix FP32 为 256 FLOP、FP64 为 128 FLOP。它们是独立路径的上限，不相加为一种精度的峰值。白皮书 Table 1 的 MXFP4/MXFP6 行原印为 16,834 FLOP/CU/clock，与全芯片峰值算术不符，保留疑点，不自行修正官方值。[4, Table 1, p.8]

MFMA（Matrix Fused Multiply-Add，矩阵融合乘加）的 F8F6F4 指令允许 A、B 独立选 FP8、FP6 或 FP4。16×16×128 变体在 A/B 都使用 FP4 或 FP6 时为 16 cycles，任一输入使用 FP8 时为 32 cycles；32×32×64 变体分别为 32 与 64 cycles。结果 C/D 使用 FP32，scaled 变体的共享 scale 为 E8M0。因而仅将权重换成 FP4、另一侧仍为 FP8，不能套用最快的 FP4×FP4 指令周期；这些周期也不包括完整 kernel 的搬运与同步时间。[7, Table 28; §§7.1.5,7.1.5.1, 印刷 pp.43,50-51（PDF pp.51,58-59）]

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算裸片 | 4 个 XCD，每个有 32 个使能 CU | 合计 128 CU；未公开每 XCD 的设计 CU 数和禁用资源 | `[2, p.2 Multi-Chip Architecture]` |
| I/O 裸片 | 1 个 IOD | 产品级 brochure 直接值；不套用 MI350X/MI355X 的双 IOD 结构 | `[2, p.1 Specifications]` |
| 工艺 | TSMC 3nm / 6nm FinFET | 当前产品页未把两种节点逐一映射到 MI350P 的 XCD 与 IOD | `[1, GPU Specifications]` `[2, p.1 Specifications]` |
| 晶体管数 | 73 billion | 整个 MI350P GPU/卡所列产品值；未按 chiplet 拆分 | `[1, GPU Specifications]` |
| HBM 物理组成 | 144GB HBM3E、4,096-bit 总接口 | stack 数、stack 高度和逐 stack 容量未公开，不能由容量反推 | `[1, GPU Memory]` `[2, p.1 Specifications]` |
| Last Level Cache | 128MB AMD Infinity Cache，由 4 个 XCD 共享 | brochure 没有公开 IOD 内实例数、bank 或 LLC 带宽 | `[1, GPU Memory]` `[2, p.2 Multi-Chip Architecture]` |
| 封装内互联 | 产品支持 4th Gen AMD Infinity Architecture | 未找到 MI350P 封装内拓扑、D2D 协议、链路数或带宽的一手定值 | `[1, Additional Features]` |
| 外形与供电 | FHFL、10.5 英寸（267mm）、双槽；12V-2x6 外部电源连接器 | 单张 PCIe CEM 卡 | `[1, Requirements and Dimensions]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 128 CU、8,192 Stream Processor、512 Matrix Core | 4 XCD，每 XCD 32 CU | `[1, GPU Specifications]` `[2, p.2 Multi-Chip Architecture]` |
| 时钟 | 2,200MHz peak engine clock | 峰值，不是保证持续频率 | `[1, GPU Specifications]` |
| MXFP 峰值 | MXFP4 4.6PFLOPS；MXFP6 4.6PFLOPS；MXFP8 2.3PFLOPS | 当前产品页峰值；brochure 将同值标为 estimated | `[1, GPU Specifications]` `[2, p.1 performance tables]` |
| OCP-FP8 / INT8 峰值 | 各 2.3PFLOPS/POPS 基础值、4.6PFLOPS/POPS structured sparsity | OCP-FP8 为 E5M2/E4M3；稀疏条件不能当作稠密峰值 | `[1, GPU Specifications]` |
| FP16 / BF16 Matrix 峰值 | 各 1.15PFLOPS 基础值、2.3PFLOPS structured sparsity | Matrix path | `[1, GPU Specifications]` |
| FP16 / FP32 / FP64 峰值 | FP16 vector 72TFLOPS；FP32 Matrix/Vector 各 72TFLOPS；FP64 Matrix/Vector 各 36TFLOPS | vector 标签来自 brochure；不同路径不能相加 | `[1, GPU Specifications]` `[2, p.1 performance tables]` |
| HBM | 144GB HBM3E、4,096-bit、4TB/s peak memory bandwidth；Full-chip ECC | 带宽方向和持续值未公开 | `[1, GPU Memory]` `[2, p.1 Specifications]` |
| Cache / scratchpad | 128MB Infinity Cache；每 XCD 4MB L2；每 CU 32KB L1、160KB LDS | LLC、硬件 cache 与 software-managed LDS 分开 | `[1, GPU Memory]` `[2, p.2 Multi-Chip Architecture]` `[4, p.9]` |
| 主机接口 | 1×PCIe Gen5 x16，128GB/s | brochure 未说明 128GB/s 的方向、payload 或持续口径，不自行拆分或翻倍 | `[1, Board Specifications]` `[2, p.1 Specifications]` |
| 功耗 | 600W maximum TBP，可配置到 450W | 未公开峰值性能对应哪一功耗点 | `[1, Requirements]` `[2, p.1 Specifications]` |
| 散热 | 卡级 passive cooling；面向标准 air-cooled server | 前者是卡的散热器形态，后者是服务器冷却环境 | `[1, Board Specifications]` `[3, Performance That Drops into Your Existing Racks]` |
| 虚拟化与 RAS | 当前产品页列 SR-IOV、page retirement、page avoidance；brochure 列最多 4 个 36GB physical partition，Memory Partitions 栏为 1 | brochure p.2 又把 SR-IOV 写为 future support，版本差异见第 7 节 | `[1, Additional Features]` `[2, pp.1-2]` |

## 6. 系统级互联上下文

MI350P 公开的单卡外部端点只有 PCIe 5.0 x16。AMD 说明标准风冷服务器最多可装 8 张卡，但没有在入选资料中给出卡间直连、Infinity Fabric scale-up、交换拓扑或单卡 scale-out NIC。因此，本卡不建立多卡互联域，也不从 PCIe 协议理论值推导系统聚合带宽。[2, p.1] [3, Performance That Drops into Your Existing Racks]

## 7. 证据缺口与来源差异

| 项目 | 状态 | 已检查范围或差异来源 | 当前处理 |
|---|---|---|---|
| MI350P 与 MI350X/MI355X | 对象可明确区分 | MI350P 为 4 XCD/1 IOD、144GB、4TB/s、PCIe 卡；另两款是 8 XCD/2 IOD、288GB OAM | 不迁移 OAM 资源、Infinity Fabric link 或功耗 |
| first availability / shipping date | 未找到 | 2026-05-07 官方介绍；2026-07-23 发布稿明确 launched，但未给 GA/出货日 | 发布日期写 2026-07-23，首次供货保持未找到 |
| 页面状态措辞 | 官方当前页面不一致 | 2026-07-23 发布稿写 launched；系列页仍置于 Preview 标题下 | 以定日发布稿固定 launch，保留系列页残留状态 |
| SR-IOV 状态 | 官方版本不一致 | 当前产品页写 Yes；2026-05 brochure p.2 写 Future SR-IOV support | 主字段按当前页记录，并保留 brochure 的时间版本差异 |
| passive 与 air-cooled | 主语不同 | 产品页是卡级 Cooling: Passive；博客是 standard air-cooled servers | 不登记为冲突，也不把 air 写成第二种卡级散热器 |
| 峰值是否 estimated | 资料版本/标签不同 | 当前产品页直接列 Peak Performance；2026-05 brochure 表头写 Estimated | 数值按当前产品页记录；不当作实测或持续性能 |
| 3nm / 6nm 对应关系 | 未公开 | 产品页只并列两个工艺节点 | 不假定 XCD=3nm、IOD=6nm |
| HBM 物理细节 | 未公开 | 已知 144GB、4,096-bit、4TB/s | 不反推 stack 数、高度或逐 stack 容量 |
| 封装内与卡间互联 | 未公开 | 只确认 4th Gen Infinity Architecture 与 PCIe host endpoint | D2D 拓扑/带宽、卡间直连均保持缺失 |
| 稀疏实现成本 | 部分公开 | ISA 已公开 A 矩阵沿 K 轴的 2:4 pattern 与第三输入 sparse index；index 的物理带宽、选择电路、routing 与功耗未公开 | 保留条件，不与基础峰值等价比较 |
| 典型功耗与环境条件 | 部分公开 | 只有 600W maximum、450W configurable、passive card 和 air-cooled server | 不推断持续功耗、温度、风量或性能功耗点 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | AMD，*AMD Instinct MI350P PCIe Cards* | 当前官方 SKU 产品页 | 身份、使能资源、精度峰值、HBM/cache、PCIe、功耗、散热、外形与 RAS | <https://www.amd.com/en/products/accelerators/instinct/mi350/mi350p.html> |
| `[2]` | AMD，*AMD Instinct MI350P PCIe Card*，LE-93401-00，05/26 | 官方产品 brochure | 4 XCD/1 IOD、L1/L2、媒体单元、分区、PCIe 带宽和卡形态 | [本地 PDF](../../../原始资料/论文/AMD_Instinct/02_厂商产品资料/2026_AMD_Instinct_MI350P_PCIe_Card_Brochure.pdf) |
| `[3]` | AMD，*AMD Instinct MI350P PCIe GPUs: Run Enterprise AI on Your Existing Infrastructure*，2026-05-07 | 官方博客 | 首次公开介绍、风冷服务器与最多八卡的部署边界 | <https://www.amd.com/en/blogs/2026/amd-instinct-mi350p-pcie-gpus-run-enterprise-ai-on-your.html> |
| `[4]` | AMD，*Introducing AMD CDNA 4 Architecture* | 官方架构白皮书 | CU、数值格式、LDS 与 L1/L2 管理语义 | [本地 PDF](../../../原始资料/论文/AMD_Instinct/01_厂商直接架构论文/2025_AMD_CDNA_4_Architecture_White_Paper.pdf) |
| `[5]` | AMD，*AMD Instinct MI350 Series GPUs* | 官方家族页 | MI350P PCIe 与 MI350X/MI355X platform 的产品边界及 Preview 残留状态 | <https://www.amd.com/en/products/accelerators/instinct/mi350.html> |
| `[6]` | AMD，*AAI 2026: AMD Delivers Full-Stack Compute for the Agentic AI Era*，2026-07-23 | 官方发布稿 | MI350P 正式发布日期与 existing-infrastructure 定位 | <https://ir.amd.com/news-events/press-releases/detail/1294/aai-2026-amd-delivers-full-stack-compute-for-the-agentic-ai-era> |
| `[7]` | AMD，*CDNA4 Instruction Set Architecture: Reference Guide*，2025-08-05 | 官方 ISA | 2:4 sparse MFMA 的程序员可见数据组织与 index 输入 | <https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/instruction-set-architectures/amd-instinct-cdna4-instruction-set-architecture.pdf> |

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

复核结论：AMD Instinct MI350P 144GB 的正式主语是一张 600W maximum、可配置到 450W 的 passive FHFL 双槽 PCIe 卡。4 个 XCD、1 个 IOD、128 个 CU、512 个 Matrix Core、144GB HBM3E、4TB/s、128MB Infinity Cache 和 PCIe Gen5 x16 均有 AMD 一手产品资料支持。MI350X/MI355X 的 8-XCD OAM 结构、设备直连与 8-GPU 平台数据没有下放。首次供货日期、HBM stack 组成、chiplet 面积、3nm/6nm 的逐 die 映射、封装内 D2D 带宽、卡间直连、典型功耗和环境条件保持未公开；SR-IOV 的当前产品页与 2026-05 brochure 时间版本差异已经保留。
