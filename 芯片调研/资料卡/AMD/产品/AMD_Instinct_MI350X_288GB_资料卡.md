# AMD Instinct MI350X 288GB 资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-09-23

本卡以一块 AMD Instinct MI350X 288GB OAM（OCP Accelerator Module）为正式比较对象。该模组采用 8 个 XCD（Accelerated Compute Die）和 2 个 IOD（I/O Die），有 256 个使能 CU。8-OAM MI350X Platform 的 2.3TB HBM、64TB/s 聚合 HBM 带宽和平台聚合算力不下放到单 OAM。

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Advanced Micro Devices（AMD） | AMD Instinct 数据中心加速器 | `[1, Product Basics]` |
| 产品家族 | Instinct MI350 Series | CDNA 4 OAM 产品 | `[1, Product Basics and GPU Specifications]` |
| 完整 SKU | AMD Instinct MI350X 288GB | 当前官方独立产品页与 GPU brochure 的对象 | `[1, full page]` `[2, pp.1-2]` |
| 对象形态 | OAM Module，54V UBB 供电，passive OAM | PCIe 5.0 x16 是 host I/O，不是 PCIe 插卡形态 | `[1, Requirements and Board Specifications]` |
| 架构代际 | AMD CDNA 4 | 8 XCD、2 mirrored IOD、256 CU、1,024 Matrix Core | `[1, GPU Specifications]` `[2, pp.1-2]` |
| 发布与可用状态 | 2024-06-02 首次预告；2025-06-12 发布；当前仍列出 | 发布稿称系列平台 2025 年下半年广泛可用，未单独给出 MI350X OAM 首批出货日 | `[7, AMD Previews New Accelerators]` `[1, Product Basics]` `[4, opening and AMD Delivers Leadership Solutions]` |
| 厂商定位 | Generative AI、inference、training 与 HPC | 同一 OAM 不是推理专用 SKU | `[2, p.1 heading and opening]` |
| 产品目标 | 在兼容 MI300X/MI325X 的 UBB 2.0 生态中提供更高低精度吞吐、288GB HBM3E 和 8TB/s | drop-in compatibility 是平台兼容性，不代表所有系统无需散热或固件调整 | `[2, p.1 Seamless Scalability & Deployment]` `[3, pp.2-4]` |

本卡包含：256 个使能 CU、1,024 个 Matrix Core、各精度理论峰值、8 XCD/2 IOD/8 HBM3E stack、cache、PCIe、Infinity Fabric link、1000W TBP、媒体单元、分区与 OAM 散热形态。

本卡不包含：8-GPU MI350X Platform 的 2.3TB HBM3E、64TB/s 聚合内存带宽、平台算力、主机 CPU、网络与系统功耗。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | CDNA 4 Compute Unit，含 scalar、vector、matrix、load/store、L1 与 LDS | 与 MI355X、MI350P 共享架构代际 | 复用 [CDNA 4 架构卡](../架构/AMD_CDNA4_架构.md)，本卡补 256 CU 的实现量 | `[3, pp.5-9]` |
| die/chiplet | 8 个 XCD、2 个 mirrored IOD | 与 MI355X 共享主要 chiplet 组织 | 每 XCD 设计 36 CU、使能 32 CU；XCD 为 N3P，IOD 为 N6 | `[3, pp.4-5 and p.10]` |
| package | 8 个 XCD 垂直堆叠于 2 个 IOD，并连接 8 个 12-Hi HBM3E stack | 与 MI355X 同为 CDNA 4 OAM 封装家族 | 作为单一逻辑 GPU，不拆成 8 个 GPU 样本 | `[3, pp.2-5 and p.10]` |
| 产品配置 | MI350X 288GB OAM | 与 MI355X 在时钟、峰值和功耗上不同 | 正式比较单位 | `[1, full page]` |
| 相关系统 | 8×MI350X OAM 的 UBB 2.0 platform | 多模组系统 | 只用于划定 7-link peer domain 与 host PCIe 边界 | `[5, AMD Instinct MI350 Series Platforms]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| CU 执行组织 | 每个 CDNA 4 CU 含 scalar、vector、Matrix Core、transcendental、conversion、load/store、L1 与显式寻址 LDS | 本 SKU 共 256 个使能 CU | `[3, pp.5-6]` `[1, GPU Specifications]` |
| Matrix Core | 每 CU 有 4 个 Matrix Core；SKU 共 1,024 个 | 支持 FP64、FP32、FP16/BF16、OCP-FP8、INT8 与 MXFP8/6/4 路径 | `[1, GPU Specifications]` `[3, pp.7-8]` |
| 数值格式 | OCP-FP8 支持 E5M2/E4M3；MXFP6 支持 E3M2/E2M3，MXFP4 为 E2M1 | MX 格式通常以 32 个元素共享 scale；TF32 物理路径在 CDNA 4 移除，改由 BF16 软件模拟 | `[3, pp.7-8]` |
| 程序员可见累加 | 低精度 dense MFMA 的选定指令以 FP32 C/D 累加；INT8 MFMA 以 INT32 C/D 累加 | ISA 语义不能解释为物理 accumulator 位宽 | `[6, pp.285-288]` |
| 结构化稀疏 | OCP-FP8、FP16、BF16、INT8 有 structured sparsity 峰值；sparse MFMA 的 A 矩阵沿 K 轴每 4 个元素含 2 个零，第三输入提供 sparse index | sparse 峰值为对应基础值 2 倍；index 带宽、选择电路与功耗未公开 | `[1, GPU Specifications]` `[6, pp.294 and 307-308]` |
| LDS | 每 CU 160KB，64 个 bank，每 bank 为 640×4B；含 32 个整数 atomic 单元；读吞吐 256B/clock，可从 L1 直接装入 | 工作组显式管理的 local storage；按 1,280B 连续块分配并按 1,280B 对齐，不能把容量当作统一 cache | `[3, p.9]` `[6, §§2.2.1,3.6.5, 印刷 pp.6,13（PDF pp.14,21）]` |
| L1/L2 | 每 CU 32KB、64-way L1，128B line；每 XCD 共享 4MB、16-way fully coherent L2 | L2 有 16 个并行 channel；每 channel 每 cycle 读 128B、写 64B | `[2, p.2 Multi-Chip Architecture]` `[3, p.9]` |
| L2 管理与通道 | 每 XCD 有 16 个 L2 channel，各 channel 每 cycle 读 128B、写 64B；writeback/write-allocate，XCD 内 fully coherent | CDNA 4 可缓存来自 DRAM 的 non-coherent 数据，并在脏行写回后保留副本；一致性与可见性仍须遵守地址和程序语义，不能推广成整机透明一致性 | `[3, p.9]` |
| 媒体单元 | 4 组 HEVC/H.265、AVC/H.264、VP9 或 AV1 decoder；40 个 JPEG/MJPEG core，每组 10 个 | 需要兼容 media player；brochure p.2 的自然语言措辞含混，主值取 p.1 规格表 | `[2, p.1 Decoders and Virtualization]` |
| 专用 AI 单元缺口 | 未找到专用 attention、MoE routing、top-k、sampling 或 KV Cache 管理物理模块 | 相关 workload 由通用 Matrix/Vector/Scalar 路径和软件完成 | `[2, pp.1-2]` `[3, pp.5-9]` |

### 3.1 矩阵吞吐与输入格式条件

CDNA 4 的 dense 矩阵执行能力按每 CU 每周期计，FP16/BF16 为 4,096 FLOP，OCP-FP8 为 8,192 FLOP。Vector FP16/FP32 为 256 FLOP、FP64 为 128 FLOP；Matrix FP32 为 256 FLOP、FP64 为 128 FLOP。它们是独立路径的上限，不相加为一种精度的峰值。白皮书 Table 1 的 MXFP4/MXFP6 行原印为 16,834 FLOP/CU/clock，与全芯片峰值算术不符，保留疑点，不自行修正官方值。[3, Table 1, p.8]

MFMA（Matrix Fused Multiply-Add，矩阵融合乘加）的 F8F6F4 指令允许 A、B 独立选 FP8、FP6 或 FP4。16×16×128 变体在 A/B 都使用 FP4 或 FP6 时为 16 cycles，任一输入使用 FP8 时为 32 cycles；32×32×64 变体分别为 32 与 64 cycles。结果 C/D 使用 FP32，scaled 变体的共享 scale 为 E8M0。因而仅将权重换成 FP4、另一侧仍为 FP8，不能套用最快的 FP4×FP4 指令周期；这些周期也不包括完整 kernel 的搬运与同步时间。[6, Table 28; §§7.1.5,7.1.5.1, 印刷 pp.43,50-51（PDF pp.51,58-59）]

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算裸片 | 8 个 TSMC N3P XCD；每 XCD 设计 36 CU、使能 32 CU | 合计 256 个使能 CU；每 XCD 另有 4 个 ACE 和 4MB L2 | `[3, pp.4-5]` |
| I/O 裸片 | 2 个 mirrored TSMC N6 IOD，彼此直接连接 | IOD 含 Infinity Cache、HBM controller 与系统通信资源 | `[2, p.1 Specifications]` `[3, p.10]` |
| 物理集成 | XCD 垂直堆叠在 IOD 上，经 on-package Infinity Fabric 连接 | advanced 3D package；未公开 MI350X 封装尺寸与键合 pitch | `[3, pp.2-4 and p.10]` |
| HBM 组成 | 8 个 12-Hi HBM3E stack，合计 288GB | 每个 IOD 连接 4 个 stack；未用总容量反推逐 stack 可寻址容量 | `[3, pp.2 and 10-11]` |
| 晶体管与工艺 | 185 billion transistors；TSMC 3nm / 6nm FinFET | 产品页没有按 chiplet 拆晶体管数 | `[1, GPU Specifications]` |
| Infinity Cache | 256MB、16-way memory-side cache，连接 8 个 HBM stack | 每 stack 对应 16 个 64B channel 与 2MB banked data array | `[1, GPU Memory]` `[3, pp.10-11]` |
| 封装内互联 | 双 IOD 直接连接；Figure 5 标出 Infinity Fabric Advanced Package 的 5.5TB/s bisection bandwidth | 属于封装内剖分带宽，不能与 HBM 或外部 P2P 带宽互换；正文约快 14% 的脚注 MI350-051 限定 MI355X 对 MI300X 的峰值理论 IOD 剖分带宽，不能作为 MI350X 的独立定值 | `[3, Figure 5, pp.10-11; p.21, MI350-051]` |
| RAS 与分区 | Full-chip ECC、page retirement、page avoidance、SR-IOV；计算分区最多 8 个；架构白皮书给 NPS1/NPS2 内存 NUMA 模式 | brochure 的 Memory Partitions 栏另写 1 or 4，与架构说明不一致；计算分区和内存分区不能等同 | `[1, GPU Memory and Additional Features]` `[2, p.1 Decoders and Virtualization]` `[3, pp.12-13 Figure 6]` |
| 计算分区与内存局部性 | Figure 6 给出 SPX+NPS1 的 8 XCD/288GB 单实例，DPX+NPS2 的每实例 4 XCD/144GB，QPX+NPS2 的 2 XCD/72GB，CPX+NPS2 的 1 XCD/36GB | SPX、DPX、QPX、CPX 分别为单、双、四、八计算分区；NPS1 跨两 IOD 交织，NPS2 将内存分成每 IOD 144GB 的两个池。实例容量与 NUMA 池容量处于不同层次，八实例不等于八个 NPS 域 | `[3, pp.11-13, Figure 6]` |

白皮书将 NPS1 的用途表述为便于应用移植和适合访问较均匀的负载；在 NPS2 所示的本地分区配置中，内存访问留在对应 IOD 与 XCD 组内，减少跨 IOD Infinity Fabric 流量。其延迟、带宽和功耗改善是厂商机制说明，未给本型号逐场景的绝对测量值。该机制同时服务大任务与多个小任务，不能只据分区能力把芯片定位成推理专用。[3, pp.11-13]

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 256 CU、16,384 Stream Processor、1,024 Matrix Core | 8 XCD，每 XCD 32 个使能 CU | `[1, GPU Specifications]` `[2, p.2 Multi-Chip Architecture]` |
| 时钟 | 2,200MHz peak engine clock | 峰值，不是保证持续频率 | `[1, GPU Specifications]` |
| MXFP 峰值 | MXFP4 9.2275PFLOPS；MXFP6 9.2275PFLOPS；MXFP8 4.614PFLOPS | brochure 列出的基础峰值；当前产品页舍入为 9.2/9.2/4.6，未列 MXFP sparse 倍增值 | `[2, p.1 AI Peak Theoretical Performance]` `[1, GPU Specifications]` |
| OCP-FP8 / INT8 峰值 | OCP-FP8 4.614→9.2274PFLOPS；INT8 4.614→9.2274POPS | 左为基础值，右为 structured sparsity；OCP-FP8 为 E5M2/E4M3 | `[2, p.1 AI Peak Theoretical Performance]` `[1, GPU Specifications]` |
| FP16 / BF16 Matrix 峰值 | 产品页舍入值为各 2.3PFLOPS 基础值、4.6PFLOPS structured sparsity；brochure 原值为 2.3096/4.6192PFLOPS | Matrix path；原值与 CU×clock×每 CU 吞吐的算术不一致，见第 7 节 | `[1, GPU Specifications]` `[2, p.1 AI Peak Theoretical Performance]` |
| FP16 / FP32 / FP64 峰值 | FP16 vector 144.2TFLOPS；FP32 Matrix/Vector 各 144.2TFLOPS；FP64 Matrix/Vector 各 72.1TFLOPS | 不同路径不能相加 | `[1, GPU Specifications]` `[2, p.1 performance tables]` |
| HBM | 288GB HBM3E、8,192-bit、8Gbps/pin、8TB/s peak bandwidth；Full-chip ECC | 8×36GB、12-Hi stack；产品网页将 Memory Clock 标签写为 8GHz，白皮书按 8Gbps/pin 描述，不能解释为 HBM 核心时钟；带宽不等于持续 workload 吞吐 | `[1, GPU Memory]` `[3, pp.10-11]` |
| Cache / scratchpad | 256MB Infinity Cache；每 XCD 4MB L2；每 CU 32KB L1、160KB LDS | LLC、硬件 cache 与 software-managed LDS 分开 | `[1, GPU Memory]` `[3, pp.9-11]` |
| Host 接口 | 1×PCIe Gen5 x16，128GB/s | brochure 未说明 128GB/s 的方向、payload 或持续口径 | `[1, Board Specifications]` `[2, p.1 Specifications]` |
| GPU P2P 端点 | 7 条 scale-up Infinity Fabric link，每条 153.6GB/s peak aggregate bidirectional；七端口合计 1,075.2GB/s | 面向 8-OAM fully connected domain；当前产品页把单链路舍入为 153GB/s | `[2, p.1 Specifications]` `[3, pp.13 and 19-21]` `[1, Board Specifications]` |
| 功耗 | 1000W maximum TBP | 单 OAM，不是 8-GPU platform 或服务器功耗 | `[1, Requirements]` `[2, p.1 Specifications]` |
| 形态与散热 | OAM Module、54V UBB、passive OAM | 需要系统级风冷；OAM 温度、风量和压降未公开 | `[1, Requirements and Board Specifications]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| 8-GPU platform | UBB 2.0 承载 8 块 MI350X OAM，总 HBM 约 2.3TB | 不是单块 MI350X 的容量或形态 | `[5, AMD Instinct MI350 Series Platforms]` |
| Scale-up 拓扑 | 每块 OAM 通过 7 条 Infinity Fabric link 与其余 7 块 GPU fully connected；第八个 x16 端点配置为 PCIe Gen5 host I/O | 单链路 153.6GB/s；每 OAM 七端口 aggregate 为 1,075.2GB/s，不是 8 卡总和 | `[2, p.1 Specifications]` `[3, pp.13 and 19-21]` `[5, AMD Instinct MI350 Series Platforms]` |
| 聚合资源 | 8-OAM platform 总 HBM 带宽 64TB/s | 只属于 platform，不回填单 OAM | `[5, AMD Instinct MI350 Series Platforms]` |
| 共享内存语义 | platform brochure 称 8 个 accelerator 之间采用 hybrid hardware/software memory coherency | 不等于单一硬件 cache-coherent 2.3TB memory，也不改变每 OAM 288GB 本地 HBM | `[2, p.2 Coherent Shared Memory]` |

## 7. 证据缺口与来源差异

| 项目 | 状态 | 已检查范围或差异来源 | 当前处理 |
|---|---|---|---|
| MI350X 与 MI355X | 共享 CDNA 4 封装组织，SKU 配置不同 | MI350X 2.2GHz、9.2PFLOPS MXFP4/6、1000W；MI355X 2.4GHz、10.1PFLOPS、1400W | 不把 MI355X 峰值和功耗下放 |
| 单 OAM 与 8-OAM platform | 对象可明确区分 | 单 OAM 288GB/8TB/s；platform 2.3TB/64TB/s | 平台聚合值只留在第 6 节 |
| Infinity Fabric 单链路速率 | 官方资料存在取整差异 | 当前产品页写 153GB/s；GPU brochure 写 153.6GB/s | 保留原值，不据此判断硬件版本差异 |
| 第八个高速端点命名 | 当前产品页与技术资料粒度不同 | brochure/白皮书把标准配置写成 7×IF + 1×PCIe host；产品页另列 1 条 scale-out IF 与 128GB/s，同时也列 PCIe 5.0 x16 | 按 8 个 x16 物理端点理解，不把 scale-out 与 PCIe 重复计成第九个端点 |
| platform memory coherence | 描述粒度有限 | brochure 写 hybrid hardware/software memory coherency，未给一致性范围、顺序模型与 remote-access 延迟 | 不写成全硬件透明统一内存 |
| platform link 速率 | 官方文档版本有差异 | GPU brochure 的 coherent shared memory 段写 GPU 间 160GB/s bidirectional；当前 SKU 表与白皮书写 153.6GB/s | SKU 字段采用规格表/白皮书的 153.6GB/s，160GB/s 只保留为平台段落差异 |
| 媒体单元措辞 | brochure 内部自然语言含混 | p.1 规格表写 40 cores total、10/group；p.2 可读成每 decoder group 另有 40-core codec | 主字段采用 p.1 表格 |
| sparse 实现成本 | 条件部分公开 | ISA 确认 2:4 与 sparse index；未公开 index 带宽、selector、reconfiguration 和功耗 | 保留条件，不把 2× headline 等同于无成本 |
| 封装细节 | 部分公开 | 已知 8 XCD、2 IOD、8×12-Hi HBM3E、N3P/N6 与垂直堆叠 | interposer、键合工艺名称、封装尺寸和 die 面积保持未公开 |
| 功耗与散热条件 | 部分公开 | 1000W TBP 与 passive OAM 明确 | 典型功耗、温度、风量、压降和持续峰值条件未公开 |
| FP16/BF16 精细峰值 | 官方内部算术不一致 | brochure 给 2.3096/4.6192PFLOPS；白皮书 Table 1/2 的 256 CU×2.2GHz×4096 FLOP/CU/cycle 可复算为 2.3068672PFLOPS | 保留原值疑点，比较采用官网舍入值 2.3/4.6PFLOPS，不把复算值当成厂商勘误 |
| 内存分区 | 官方资料不一致 | brochure p.1 写 1 or 4；CDNA 4 白皮书 pp.12-13 明确 NPS1/NPS2 | 架构语义采用 NPS1/NPS2，保留 brochure 原词冲突，不把计算分区数当作 HBM 分区数 |
| 专用 LLM 单元 | 未找到 | 产品页、brochure、白皮书与 ISA | attention、MoE router、top-k、sampling 和 KV Cache 管理保持未公开 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | AMD，*AMD Instinct MI350X GPUs* | 当前官方 SKU 产品页 | 身份、发布日期、资源、精度峰值、HBM/cache、PCIe、Infinity Fabric、功耗与 OAM 形态 | <https://www.amd.com/en/products/accelerators/instinct/mi350/mi350x.html> |
| `[2]` | AMD，*AMD Instinct MI350X GPU*，LE-92701-00 C，09/25 | 官方 GPU brochure | 2 IOD、峰值表、媒体/分区、7×IF、PCIe、8 XCD 与 shared-memory 表述 | <https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/product-briefs/amd-instinct-mi350x-gpu-brochure.pdf> |
| `[3]` | AMD，*Introducing AMD CDNA 4 Architecture* | 官方架构白皮书 | Core、XCD/IOD/package、cache/HBM、数值格式与 Infinity Fabric 机制 | [本地 PDF](../../../原始资料/论文/AMD_Instinct/01_厂商直接架构论文/2025_AMD_CDNA_4_Architecture_White_Paper.pdf) |
| `[4]` | AMD，*AMD Unveils Vision for an Open AI Ecosystem, Detailing New Silicon, Software and Systems at Advancing AI 2025*，2025-06-12 | 官方发布稿 | MI350 Series 正式发布与产品定位 | <https://ir.amd.com/news-events/press-releases/detail/1255/amd-unveils-vision-for-an-open-ai-ecosystem-detailing-new-silicon-software-and-systems-at-advancing-ai-2025> |
| `[5]` | AMD，*AMD Instinct MI350 Series GPUs* | 官方家族与 platform 页面 | 单 OAM、MI355X 及 8-OAM platform 边界 | <https://www.amd.com/en/products/accelerators/instinct/mi350.html> |
| `[6]` | AMD，*CDNA4 Instruction Set Architecture: Reference Guide*，2025-08-05 | 官方 ISA | MFMA 累加格式与 2:4 sparse index 语义 | <https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/instruction-set-architectures/amd-instinct-cdna4-instruction-set-architecture.pdf> |
| `[7]` | AMD，*AMD Accelerates Pace of Data Center AI Innovation and Leadership with Expanded AMD Instinct GPU Roadmap*，2024-06-02 | 官方路线图公告 | MI350X 首次具体型号预告 | <https://www.amd.com/en/newsroom/press-releases/2024-6-2-amd-accelerates-pace-of-data-center-ai-innovation-.html> |

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

复核结论：AMD Instinct MI350X 288GB 的正式主语是一块 1000W passive OAM module。8 个 N3P XCD、2 个 N6 IOD、8 个 12-Hi HBM3E stack、256 个 CU、1,024 个 Matrix Core、288GB HBM3E、8TB/s、PCIe Gen5 x16 和 7 条 scale-up Infinity Fabric link 均有 AMD 一手资料支持。8-OAM UBB 2.0 platform 的聚合容量、带宽和算力没有下放。MI350X 与 MI355X 共享 CDNA 4 组织，但时钟、峰值与功耗不同；封装尺寸、die 面积、键合工艺、典型功耗、环境条件和专用 LLM 单元保持未公开。
