# NVIDIA GA100 die 综合资料卡

> 调研状态：已完成。  
> 资料截止日：2026-08-21。  
> 调研对象：完整 128-SM GA100 裸片设计。  
> 来源规模：正文引用 23 组资料，其中 19 组为本卡实际需要的核心参考资料，S08、S11、S12、S13 只用于说明边界或提供后续线索。  
> 引用方法：正文使用 `[Sxx, 定位]`，第 14 节列出短标签对应的资料。

本卡以 full GA100 die 为唯一主语。A100 是采用 GA100 的产品实现，公开配置启用 108 个 Streaming Multiprocessor（SM，流式多处理器）；完整 GA100 设计有 128 个 SM。Ampere 是共享架构代际；SXM 模组、PCI Express（PCIe）卡、高带宽内存（HBM）、DGX/HGX、云实例和软件容器分别属于模组、卡、系统或软件层。正文可以引用这些上层对象来说明实现条件和边界，但不会把它们的容量、频率、功耗、价格或系统性能下放成 GA100 裸片属性。

## 1. 对象、范围与公开身份

| 字段 | 本卡裁决 | 对象、条件与证据 |
|---|---|---|
| 厂商 | NVIDIA | full GA100 die；[S01, PDF pp.9、14、19] |
| 正式名称 | NVIDIA GA100 GPU / GA100 die | 白皮书直接称 GA100 驱动 A100，并区分 full GA100 与 A100 implementation；[S01, PDF pp.9、14、19] |
| 产品家族 | GA100 | 作为物理微架构/裸片标识使用；Multi-Instance GPU（MIG，多实例 GPU）支持表又将 A100-SXM4、A100-PCIE 和 A30 的 `Microarchitecture` 列写为 GA100；[S01, PDF p.19]；[S06, Supported GPUs, Table 1] |
| 对象类型 | die | full physical design；[S01, PDF pp.19-20, Figure 6]；[S02, PDF p.3, Figure 3.2.7] |
| SKU 或销售配置 | `not_found` | 该项是 included requirement。full GA100 design codename 不是公开销售 SKU；Product Brief 中的 GA100-8xx 是 A100 产品 GPU/SKU，只作 wrong-subject 结果；[S13, Product Brief pp.4、6-7] |
| 架构代际 | NVIDIA Ampere | 只通过 `implements_architecture` 关系读取，不另建同义文本事实；[S01, PDF pp.9、14、19]；[S06, Supported GPUs, Table 1] |
| 首次发布日期 | `pending_verification` | 固定 NVIDIA 技术博客在 2020-05-14 已直接命名 GA100，但当前字段仍要求“具体对象首次发布日期”，不能把网页发表日期直接当作 die release date；[S11, 页面 metadata `datePublished` 和正文 `GA100`] |
| 首次可用日期 | `not_found` | 已核白皮书与 A100 launch publication 只给出 A100 产品或系统的可用性，没有 standalone GA100 die 的首次可用日期；[S01, 全文 availability 检索]；[S12, A100 launch publication] |
| 当前硬件状态 | `not_found` | 冻结名单中的“历史锚点”是项目范围标签，不是 NVIDIA 生命周期状态。已核白皮书、ISSCC、技术博客、Newsroom 和 A100 product brief，均未找到直接绑定 full GA100 die 的 current hardware status；[S01-S02、S11-S13] |
| 地区或出口变体、市场准入 | `not_found` | SEC 10-Q 直接约束 A100/H100 integrated circuits 及相应系统，没有直接命名 full GA100 design；[S14, Form 10-Q, Item 1A, `On August 26, 2022` 段] |
| 厂商定位与目标用途 | GA100 die：`not_found`；Ampere 架构：有直接值 | Ampere 被定位为改善可编程性、降低延迟与 AI/HPC 软件复杂度，并提高相对 Volta 的 performance per watt；又以 existing DNN strong scaling 为设计目标。主语是 Ampere，不能复制到 GA100 die；[S01, PDF pp.11、38] |
| 公开部署 | GA100 die：`not_found` | DGX/HGX、NVSwitch 和 A100 卡部署属于系统或产品。它们只能证明上层产品采用 GA100；[S01, PDF p.52 和 DGX 章节]；[S02, Figure 3.2.6] |
| 裸片公开价格 | `not_found` | 价格是 included requirement；计划官方来源未找到 standalone GA100 die 的 MSRP 或 list price。A100 卡、云实例、DGX/HGX 和二手报价均为 wrong subject；裸片成本也保持 `not_found`；[S01-S02, price/cost 全文检索] |

本卡包含 GA100 完整裸片设计、直接绑定 GA100 的跨层 Reliability, Availability and Serviceability（RAS，可靠性、可用性和可维护性）机制、GA100 上实现的 Ampere Compute Capability 8.0（CC8.0，计算能力 8.0）架构能力，以及在 A100 测试载体上测得且可以唯一归属到 GA100 片上组件的条件化微基准。

本卡不包含 A100 的 108-SM 启用规模、40/80 GB HBM、40 MB L2、产品时钟与峰值、250/300/400 W 功耗、SXM/PCIe 形态、MIG profile 容量和 A100/DGX 系统 benchmark 作为 GA100 的无条件值。

### 1.1 四层对象分界

| 层级 | 本卡采用的对象 | 可在本卡出现的内容 | 禁止下放的内容 |
|---|---|---|---|
| 裸片 | full GA100，128 SM | 制程、面积、晶体管、完整设计单元数、片上组件、物理接口；[S01, pp.14、19-20] | A100 产品频率、功耗、HBM 容量和产品峰值 |
| 架构 | NVIDIA Ampere / CC8.0 | SIMT、Tensor Core 数值路径、`cp.async`、`mbarrier`、`mma.sp`、warp reduction 和 CUDA/PTX 接口；[S03, CC8.0 章节]；[S04, PTX 7.0/7.2 相关指令章节] | 把 generic CC8.x 或 A100 软件配置复制成裸片事实 |
| 产品 | A100-SXM4/PCIe、A30 | enabled resource、MIG profile、HBM、板卡功耗、产品软件支持；[S01, p.19 和 Tables 4-5]；[S06, Tables 1、12-13] | 覆盖 full GA100 的 128-SM 设计值 |
| 系统 | DGX/HGX、MLCommons system-under-test | 系统拓扑、主机、软件栈和完整 benchmark 条件；[S02, Figure 3.2.6]；[S10, fixed commit system/result endpoints] | 系统聚合值除以 GPU 数后写回 die |

### 1.2 full GA100 与 A100 enabled implementation

| 项目 | full GA100 design | A100 enabled implementation | 卡片处理 |
|---|---:|---:|---|
| Graphics Processing Cluster（GPC） | 8 | 7 | 前者是本卡值；后者只作产品边界；[S01, PDF p.19] |
| Texture Processing Cluster（TPC） | 64，8/GPC | 54，7 或 8/GPC | 同上；[S01, PDF p.19] |
| SM | 128 | 108 | 本卡所有 full-design 数量使用 128；[S01, PDF p.19]；[S02, PDF pp.1-2] |
| FP32 CUDA Core | 8192 | 6912 | 不能用 6912 覆盖完整设计；[S01, PDF p.19] |
| 第三代 Tensor Core | 512 | 432 | 不能用 432 覆盖完整设计；[S01, PDF p.19] |
| 512-bit memory controller | 12 | 10 active | 12 个控制器属于 die；5 个 active HBM stack 属产品/封装；[S01, PDF p.19] |
| L2、时钟、HBM、功耗 | full-design 定值多项未公开 | 40 MB、1.41 GHz、40/80 GB 及产品功耗等 | 只在产品条件表出现，不填入 full GA100 字段；[S01, pp.35-37]；[S02, pp.1-2] |

## 2. 物理实现与外部边界

| 项目 | 已确认值或状态 | 条件、口径与证据 |
|---|---|---|
| 代工与制程 | TSMC 7 nm N7 | full GA100 die；[S01, PDF p.14]；[S02, PDF p.1 / 印刷 p.48] |
| 裸片面积 | 826 mm² | 每裸片；[S01, PDF p.14]；[S02, PDF p.1 / 印刷 p.48] |
| 晶体管 | 54.2 billion，规范化为 54,200,000,000 | ISSCC 的 54B 按会议短文舍入处理，不构成设计版本冲突；[S01, PDF p.14]；[S02, PDF p.1 / 印刷 p.48] |
| 裸片数量 | `not_applicable`，对应 M018 | 本对象本身就是一颗 die，不从 die photo 反推 package-level quantity=1；[S02, Figure 3.2.7] |
| 封装、中介层、基板 | card-only 上层字段，不采集 | 这些字段属于 package/module，不计入 204 项 requirement 状态。白皮书同页出现 HBM 和 die 信息不改变主体。 |
| HBM stack applicability | `pending_verification` | 阅读层可说明 HBM stack 位于 package/product path，但 formal requirement 尚无已接受的 exact structural predicate。full GA100 的 HBM site 和 A100 active stack 只作上层边界，不能填成 die 内组件；[S01, pp.19、35] |
| HBM 总接口宽度 | 6144 bit，`public_derived` | `12 controller × 512 bit/controller`。两个输入均来自 full implementation；A100 的 5120 bit 是 10-controller 产品值；[S01, PDF pp.19-20] |
| 时钟 | `not_found` | 1.41 GHz 是 A100 产品峰值条件，不是 full GA100 的裸片或各时钟域定值；[S01, Tables 4-5]；[S02, PDF p.1] |
| 功耗 | `not_found` | 250/300/400 W 分别属于不同 A100 卡/模组；[S01, Table 4]；[S13, Product Brief 规格表] |
| 散热 | card-only 上层字段，不采集 | 风冷、被动或液冷属于卡、模组与系统实现，不计入 204 项 requirement 状态。 |
| 形态 | bare die | SXM4、PCIe 是上层产品 form factor；[S13, Product Brief] |

## 3. 计算资源、执行模型与利用限制

### 3.1 full-design 资源

| 组件或路径 | 数量或结构 | 作用域、并发边界与证据 |
|---|---:|---|
| GPC | 8 | full GA100；[S01, PDF p.19] |
| TPC | 64 | 8 TPC/GPC，2 SM/TPC；[S01, PDF p.19] |
| SM | 128 | full GA100；[S01, PDF p.19] |
| FP32 CUDA Core | 8192 | 64/SM；[S01, PDF p.19] |
| 第三代 Tensor Core | 512 | 4/SM；[S01, PDF pp.19、22, Figure 7] |
| memory controller | 12 × 512 bit | 片上控制器数量与外部 HBM stack 分开；[S01, PDF p.19] |
| SM processing block | 4/SM | 每块包含 warp scheduler、dispatch、register file、FP32/INT32、Tensor、load/store 和 special-function 资源；[S01, PDF p.22, Figure 7] |
| warp | 32 threads | 编程和调度粒度，不等于整个 SM 每周期只发 32 threads；[S03, PDF pp.129-130 / 印刷 pp.112-113] |
| processing block 发射 | 32 threads/clock | Figure 7 的局部作用域；不相加成未证明的全 SM 峰值；[S01, PDF p.22, Figure 7] |
| Tensor FP16 dense | 1024 fused multiply-add（FMA，融合乘加）/SM/clock | 保留厂商 FMA 计数，不把一次 FMA 静默改成 2 FLOP；没有绝对频率，故不推导 full-die TFLOP/s；[S01, PDF p.20 和 p.27 Table 3] |

GA100 对外使用 SIMT（Single Instruction, Multiple Threads，单指令多线程）执行模型。CC8.0 文档给出每个 SM 4 个 warp scheduler，warp 静态分配给 scheduler；每次 issue 时，每个 scheduler 最多从自己负责且 ready 的 warp 发出一条指令。这是公开的软件可见组织，不披露仲裁优先级、scoreboard、dual-issue 规则或 RTL；[S03, PDF p.370 / 印刷 p.352, §I.7.1]；[S04, PTX 7.0 §3.1]。

白皮书直接说明 FP32 与 INT32 core 可同时以各自 full throughput 执行，示例是 FP32 计算与 INT32 地址计算重叠。该并发事实只覆盖这两条路径，不扩成 Tensor Core、FP64、load/store 和 special-function 全部同时达峰；[S01, PDF p.34, `Simultaneous Execution of FP32 and INT32 Operations`]。

### 3.2 指令 Tile 与条件化微基准

Tensor Core 的 `M×N×K` 指令 Tile 表示一个 warp-level matrix multiply-accumulate（MMA，矩阵乘加）指令的逻辑覆盖范围，不是物理 multiply-accumulate（MAC，乘加）阵列形状。Parallel Thread Execution（PTX，并行线程执行）是 NVIDIA 的虚拟指令集；SASS 是 GPU 原生机器指令表示。FP16 dense 路径直接支持 `.m8n8k4`、`.m16n8k8` 和 `.m16n8k16`；sparse FP16/BF16 路径支持 `.m16n8k16/.m16n8k32`。物理阵列行列数保持 `not_found`；[S04, PTX 7.0 §9.7.13.4.14；PTX 7.2 §9.7.13.5]。

HPEC arXiv v1 的测试载体只写 A100 product family，容量、SXM/PCIe、CUDA、driver、compiler、GPU 频率、锁频和功耗模式均未报告。下列结果只作为“A100 载体上测得的 GA100 片上路径”条件化证据，不能推广为 full 128-SM 配置的无条件延迟；[S07, PDF pp.4-7, Sections IV-V]。

| 条件化路径 | PTX / SASS 映射 | 原始周期 | 接收边界 |
|---|---|---:|---|
| FP16→FP16 | warp-level matrix multiply-accumulate（WMMA）`m16n16k16/m8n32k16/m32n8k16`；`2×HMMA.16816.F16` | 16 | A100 carrier、dense、4 条独立 Tensor Core 指令、2-cycle clock overhead；[S07, p.6 Table III] |
| FP16→FP32 | 同形状；`2×HMMA.16816.F32` | 16 | 同上；[S07, p.6 Table III] |
| BF16→FP32 | 同形状；`2×HMMA.16816.F32.BF16` | 16 | 同上；[S07, p.6 Table III] |
| TF32→FP32 | `m16n16k8`；`4×HMMA.1684.F32.TF32` | 16 | 同上；[S07, p.6 Table III] |
| FP64→FP64 | `m8n8k4`；`DMMA.884` | 16 | 同上；[S07, p.6 Table III] |
| U8→U32 | `m16n16k16/m32n8k16/m8n32k16`；`2×IMMA.16816.U8.U8` | 8 | 同上；[S07, p.6 Table III] |
| U4→U32 | `m8n8k32`；`IMMA.8832.U4.U4` | 4 | 同上；[S07, p.6 Table III] |

同一论文的 Table III 把聚合吞吐写成 `GB/s`，数值却与 A100 官方 TFLOP/s/TOPS 峰值重合。该列保留原文并判为 `rejected_for_normalization`，不替作者改单位；[S07, p.6 Table III]。论文 background 的 124 SM 同时不符合 full GA100 128 SM 和 A100 enabled 108 SM，也不进入任何事实；[S07, p.2 Section II]。

### 3.3 利用率限制

NVIDIA Matrix Multiplication Guide 给出三条可接受的 A100-carrier 条件化限制。A100 在 cuBLAS 11.0 及以后可以在未对齐尺寸上使用 Tensor Cores，但最佳效率的维度倍数依数据类型而变：INT8 为 128 elements、FP16 为 64、TF32 为 32、FP64 为 16。大 tile 提高复用和 tile efficiency，小 tile 提供更多 tile parallelism；GEMM 过小时，两者任一不足都可能使 GPU 达不到 peak math utilization。矩阵边界不能整除 thread-block tile 时，边界 tile 仍执行同量 math，形成 tile quantization 的无效工作；[S09, §2.2、§2.3、§3.1]。

Figure 3/4/7 的载体是 A100-SXM4-80GB、CUDA 11.2、cuBLAS 11.4，不能写成裸片无条件数值。[S09, Figure 3/4/7 captions]。同指南 §3.2 的 108-SM wave 与 9/108 tail-wave 只适用于 A100 enabled configuration，不改成 full GA100 的 128-SM wave。

## 4. 数值格式、累加语义与结构化稀疏

以下是 Ampere `sm_80` 的 programmer-visible ISA contract，GA100 通过 Ampere/CC8.0 关系可达。`D type` 指矩阵指令目的寄存器类型，不保证随后写入外存时的格式。`product` 精确编码、物理 accumulator、scaling mode 和 scaling granularity 在所有路径上均为 `not_found`；[S04, PTX 7.0 dense MMA/WMMA；PTX 7.2 sparse MMA]。

| 路径 | A/B | 程序员可见 C/D | rounding 与 subnormal | saturation | structured sparsity |
|---|---|---|---|---|---|
| FP16→FP32 | FP16/FP16 | FP32/FP32 | rounding、subnormal 均为 `not_specified`，这是 ISA 直接值 | PTX matrix opcode 无 floating `.satfinite`；高层 WMMA `satf=true` 另属 API 条件 | A 为 2:4；[S04, PTX 7.2 §9.7.13.5.1] |
| FP16→FP16 | FP16/FP16 | FP16/FP16 | `not_specified` | 同上 | A 为 2:4；[S04, PTX 7.2 sparse FP16 example] |
| BF16→FP32 | BF16/BF16 | FP32/FP32 | `not_specified` | 同上 | A 为 2:4；[S04, PTX 7.2 §9.7.13.5.1] |
| TF32→FP32 | TF32/TF32，外围 FP32 可转 TF32 输入 | FP32/FP32 | `not_specified` | 同上 | A 为 1:2；[S01, pp.26-27]；[S04, PTX 7.2 §9.7.13.5.1] |
| FP64→FP64 | FP64/FP64 | FP64/FP64 | 默认 `.rn`，还公开 `.rz/.rm/.rp`，分别表示 nearest-even、toward zero、toward negative infinity、toward positive infinity；matrix subnormal 仍 `not_found` | `not_found` | `not_found`；[S04, PTX 7.0 dense MMA] |
| INT8→INT32 | INT8/INT8 | INT32/INT32 | rounding=`not_applicable`；subnormal=`not_applicable` | 有 `.satfinite` 时饱和到 INT32 范围，省略时 wrap；必须拆成两个指令条件 | A 为 2:4；[S04, PTX 7.2 §9.7.13.5] |
| INT4→INT32 | INT4/INT4 | INT32/INT32 | rounding=`not_applicable`；subnormal=`not_applicable` | 同 INT8 | A 为 pair-wise 4:8，以二元素 pair 为原子，不是任意四个非零；[S04, PTX 7.2 §9.7.13.5.1] |
| Binary→INT32 | binary/binary | INT32/INT32 | rounding=`not_applicable`；subnormal=`not_applicable` | `not_found` | `not_found`；[S01, p.27 Table 3]；[S04, PTX binary MMA] |

`mma.sp.sync.aligned` 是 warp-level 稀疏矩阵乘加指令。稀疏 operand A 以 50% non-zero 的压缩形式传入，metadata 指示保留位置；直接 PTX 接口在 PTX 7.1 / CUDA 11.1 引入，目标为 `sm_80+`。[S04, PTX 7.2 §9.7.13.5 和 §12.2]。白皮书 Figure 12 又给出 Select 数据流。[S01, pp.31-32]。二者共同证明指令可见的结构化零跳过和 metadata 选择，不公开 selector RTL、物理乘法器数量、metadata SRAM 或持续 2 倍实测。

## 5. 存储层次、数据搬运与条件化测量

| 层级或机制 | full GA100 / 架构可确认内容 | 产品条件、测量与边界 |
|---|---|---|
| register file | 每 SM 4 个分区，每分区 16,384 × 32 bit；合计 256 KiB/SM | 端口、持续带宽和读写并发 `not_found`；[S01, PDF p.22 Figure 7] |
| unified L1/shared memory | 192 KiB physical combined capacity/SM 为直接值；software-visible shared capacity 为 `pending_verification` | 164 KB/SM、160 KB/block 和修订后的 163 KB/block 属不同对象粒度与文档版本，后者另有 1 KB system reserve。原值可以展示，但在 per-SM/per-block 语义和规范版本固定前，software-visible shared capacity requirement 不闭合；[S01, pp.21-22]；[S03, §I.7.3 及 revision comparison] |
| L2 | full GA100 图确认存在 L2，full-design 总容量 `not_found` | A100 enabled configuration 为 40 MB；L2 分区、局部性和 full-GPU cache coherence 属 A100/Ampere 条件；[S01, pp.19、35]；[S02, PDF pp.1-2] |
| L2 management | CUDA 11.0、CC8.0+ 支持 persisting set-aside 和 access-policy window | 这是访问策略，不保证命中、延迟或带宽。MIG mode 下 set-aside disabled；MPS 下只能在 server 启动时设上限；[S03, PDF pp.40-45, §3.2.3] |
| async global→shared copy | `cp.async` 可由 `sm_80` 执行，满足条件时成为单条指令并避开中间 register；可选择绕过 L1 | 方向固定为 global→shared，copy size/alignment 为 4/8/16 B，使用前需要 wait。它不是任意方向 DMA，也没有公开 engine count、queue depth、带宽或延迟；[S03, §B.24]；[S04, PTX 7.0 §9.7.8.16] |
| split arrive/wait barrier | `mbarrier` 为 CTA/shared-memory scope 的 64-bit opaque state，与 async copy 可结合 | 不代表跨 GPU barrier，也不披露硬件 barrier storage；[S03, §B.23]；[S04, PTX 7.0 §9.7.12.11] |
| Compute Data Compression | Ampere/A100 实现可压缩 activation 和其他 compressible patterns | 厂商上限为 DRAM 读写最高 4×、L2 read 最高 4×、effective L2 capacity 最高 2×。这些倍率不能乘入基础容量/带宽，也与 2:4 sparse MMA 分开；[S01, pp.35、41]；[S02, PDF p.1] |
| HBM | bare die 上只有 controller/interface；HBM capacity 是 card-only 上层字段，HBM-stack applicability 仍待核 | A100 40/80 GB、5 active stacks、1555/1935/2039 GB/s 都是具体产品/外存路径；[S01, pp.35-37]；[S13, Product Brief 规格表] |
| L2 virtual-memory responsibility | `not_found` | 在白皮书、CUDA PG 与 PTX 的计划语料内，未找到可归属 GA100 L2 exact target 的 page size、migration、oversubscription 或 remote-fault responsibility；CUDA address spaces、Unified Memory、peer access 与 fault return 不下放到 L2；[S01, pp.34、52-54]；[S03-S04, Runtime/Unified Memory 与 memory 章节检索] |

HPEC 条件化 pointer-chasing 结果为 L1 33 cycles、L2 200 cycles、shared load 23 cycles、shared store 19 cycles；global memory 290 cycles 跨越 GA100、HBM 和产品配置，只作 A100 product path。[S07, p.4 §IV-B、p.5 §V-B、p.6 Table IV]。测试缺少时钟与频率，因此周期不能换成秒；也不能把 latency cycle 填入 byte/cycle transfer 字段。

独立 random-access 论文明确使用 A100 SXM4-80GB。128-byte warp-coalesced random access 在约 50-64 GB window 的图读平台约 1240-1250 GB/s，正文又报告更宽 transaction 约 1400/1600 GB/s；超过约 64 GB 后出现 cliff。[S08, pp.1-2、5-6, Figures 1、6]。14 个 SM group 和“每组 64 GB TLB”的说法是作者的 reverse-engineering inference，缺 page size、entry count、controller identity 和原始数据。它们保留为 A100 product lead，不形成 full GA100 组件事实。

## 6. 芯片侧派生指标

full GA100 的 compute/nameplate-bandwidth、compute/sustained-bandwidth、capacity/compute、matrix/vector、move/matrix 和 interconnect/compute 六类比值均不计算。主要原因是缺少 full-design clock、aggregate precision peak、同对象 L2/HBM capacity 或可持续带宽，现有 A100 产品值又不能与 full GA100 数量混配。

NVLink 自身的接口推导是例外，因为所有输入属于同一接口对象并有明确方向：4 lane/方向/link × 50 Gbit/s/lane = 200 Gbit/s/方向/link = 25 GB/s/方向/link；12 link 全部启用时为 300 GB/s/方向和 600 GB/s 双向聚合。[S01, pp.20、52]。这些值进入互联接口，不与缺失的 full-design compute peak相除。

## 7. 可能影响训练或推理取舍的专用机制

| 候选机制 | 内容裁决 | 实现层级、限制与证据 |
|---|---|---|
| Tensor Core 低精度与 FP64 | `value` | 第三代 Tensor Core 支持 TF32、BF16、FP16、FP64、INT8、INT4 和 Binary 的公开路径；格式、累加与稀疏条件见第 4 节；[S01, pp.26-32] |
| structured sparse skip | `value` | `mma.sp` dedicated instruction，datatype-specific pattern，sparse A + metadata；不证明运行时 pruning 或任意稀疏；[S01, pp.31-32]；[S04, PTX 7.2 §9.7.13.5] |
| global→shared async copy | `value` | 通用 SM 指令，可减少 register staging 并与计算重叠；不是 Attention 专用 DMA；[S03, §B.24]；[S04, PTX 7.0 §9.7.8.16] |
| warp reduction | `value` | `redux.sync` / `__reduce_sync` 限单 warp、32-bit signed/unsigned add/min/max 和 unsigned/b32 and/or/xor；不等同 Softmax、Top-k 或跨 GPU collective；[S03, §B.19]；[S04, PTX 7.0 §9.7.12.10] |
| Compute Data Compression | `value` | 通用压缩路径，范围与上限见第 5 节；[S01, pp.35、41] |
| Optical Flow Accelerator | `value` | 白皮书直接描述 GA100 Optical Flow Accelerator，支持 optical flow 和 stereo disparity，质量/性能可调；公开吞吐 `not_found`；[S01, PDF p.56] |
| hardware video decode | `value` | 支持 H.264 8-bit 4:2:0，HEVC 8/10/12-bit 4:2:0 和 4:4:4，VP9 8/10/12-bit 4:2:0；full-design decoder 数量与吞吐 `not_found`；[S01, pp.56-57, Table 7] |
| Attention 数据搬运 | `not_found` | 已查白皮书、ISSCC、CUDA PG 与 PTX。`cp.async` 是通用搬运，不改名为 Attention engine；[S01-S04, 对应机制全文检索] |
| Softmax | `not_found` | warp reduction 没有 exponent 和 normalization；[S03-S04, reduction 章节] |
| Top-k、MoE route/dispatch | `not_found` | 没有 token/expert table、ranking、selection index 或 dispatch queue 的芯片绑定模块/指令；[S01-S04, 关键词检索] |
| network collective offload | `not_found` | NVLink 是传输接口，warp/CTA reduction 也不跨 GPU；[S01, p.52]；[S04, `redux.sync`/`mbarrier`] |
| dedicated quantize/dequantize | `not_found` 于硬件模块 | INT8/INT4 execution format 和 TensorRT calibration 是执行/软件能力，不证明 dedicated quantizer；[S04, MMA 章节]；[S21-S23, TensorRT 量化章节] |
| transpose/permute engine | `not_found` | matrix layout qualifier、MOVM 观察和 async copy 不证明专用物理 engine；[S04, matrix layout]；[S07, p.6 §V-C] |
| chip-bound KV Cache manager | `not_found` | L2 persistence、virtual memory 和 MIG partition 均无 KV-bound buffer/复制/回收语义；[S01、S03、S06, `KV cache` 检索] |

这些因素只是可能影响训练、prefill、decode、稀疏推理、HPC 或多租户服务的芯片侧条件。模型大小、batch、sequence/context/input/output length、并发请求、MoE All-to-All 通信量和 KV Cache 字节数仍是负载变量，只能进入第 12 节的实测条件，不能写成 GA100 属性。

## 8. 互联与拓扑

| 层级 | 已确认值或状态 | 方向、traffic basis、对象边界与证据 |
|---|---|---|
| 片内 | L2/SM/GPC 连接存在；topology、routing、hops、latency `not_found` | 不从方框图推导 mesh、crossbar 尺寸或片内带宽；[S01, Figure 6] |
| 主机接口 | PCI Express 4.0 x16 | full GA100 block diagram；不计算 payload bandwidth；[S01, PDF p.20, Figure 6] |
| NVLink 物理接口 | 12 | full GA100 Figure 6 直接计数，A100 文本也说明 12 links/device；[S01, pp.20、52]；[S02, PDF p.1] |
| 单 NVLink | 4 lane/方向；50 Gbit/s/lane raw；200 Gbit/s 或 25 GB/s/方向/link | `traffic_basis=raw_line_rate` 对 lane 推导；25 GB/s 是 vendor nameplate 交叉检查；[S01, p.52]；[S02, PDF p.1, NVLink3 LR PHY] |
| 每设备单向注入 | 300 GB/s/方向 | 条件为 12 links 全部启用；[S01, p.52]；[S02, PDF p.1] |
| 每设备双向聚合 | 600 GB/s | `bidirectional_aggregate`，不是单向值，也不是 DGX 系统总带宽；[S01, p.52] |
| NVLink PHY 与可靠性 | NRZ，无 FEC 时目标 BER 1e-15；link-level detection/replay | BER 是 PHY 声明，不能扩成端到端 packet error rate或全芯片 RAS；[S02, PDF p.1, NVLink3 段]；[S01, p.52] |
| GA100 die/link factor 拓扑 | topology、bisection、degree、hops、max scale、oversubscription 均为 `not_found` | 12 个 NVLink 物理接口不能直接推出网络图结构、节点度数或系统规模；[S01, pp.20、52] |
| DGX/NVSwitch topology | wrong-subject boundary only | DGX 的 8 GPU、6 NVSwitch、600 GB/s/GPU 和 full-bandwidth pairwise，以及 InfiniBand fat-tree，均为系统证据，不写成 GA100 die/link factor；[S02, PDF pp.1-2, Figure 3.2.6] |
| absolute link latency | `not_found` | ISSCC 的“节省 tens of nanoseconds”是相对 FEC 方案的节省量，不是绝对 latency；[S02, PDF p.1] |
| hardware collective offload | `not_found` | NCCL 软件支持和 NVLink transport 都不能证明网络内 collective engine；[S18, NCCL 2.7.6] |

## 9. 软件、编译、算子库与版本成熟度

软件事实留在 Ampere/CC8.0 架构或具体软件对象上，通过 GA100 的架构关系供读者查阅。它们不变成裸片内建属性。

| 类别 | 已确认的版本化内容 | 成熟度、限制与证据 |
|---|---|---|
| 编译器 | `nvcc` compiler driver，CUDA Toolkit 11.0.3，生成 PTX/cubin 并以 `sm_80` 为目标 | `documented_supported`；[S03, PDF pp.33-35, §§3.1.1-3.1.4]；[S04, PTX 7.0 release table] |
| Runtime | CUDA Runtime `cudart`，CUDA Toolkit 11.0.3 | 不把静态/动态链接形态算成多个 runtime；[S03, PDF pp.37-38, §§3.2-3.2.1] |
| 自定义 kernel 接口 | CUDA C++ `__global__` 与 `<<<...>>>` launch | 只证明 custom kernel interface，不证明 PyTorch/TensorFlow custom-op ABI；[S03, PDF pp.25、33] |
| async copy / barrier | CUDA 11.0 首次文档化；`cp.async`/`mbarrier` 对应 PTX 7.0、`sm_80` | async-copy 在 CUDA 11.0 明标 experimental，故只到 `documented_supported`；[S03, §B.23-24]；[S04, PTX 7.0 §12.1] |
| sparse PTX | `mma.sp` 在 PTX 7.1 / CUDA 11.1 引入 | 硬件存在与直接 PTX 接口版本分开；[S04, PTX 7.2 §12.2] |
| PyTorch | NVIDIA PyTorch container 20.06/20.07；PyTorch `1.6.0a0+9907a3e`；CUDA 11.0 | 20.06 直接声明 A100 支持；20.07 更新到 CUDA 11.0.194、cuDNN 8.0.1、NCCL 2.7.6、TensorRT 7.1.3，并保留 Ampere cuDNN race known issue；[S15, 20.06/20.07 `Contents`、`Key Features`、`Known Issues`] |
| TensorFlow | NVIDIA TensorFlow 20.07；TensorFlow 1.15.3/2.2.0；CUDA 11.0.194 | `documented_supported`。20.06 的 A100/GA100 `CUDA_ERROR_UNKNOWN` 与 NCCL 2.7.6-1 workaround 保留为发布期限定；[S16, 20.06/20.07 同名章节] |
| 通信库 | NCCL 2.7.6，支持 CUDA 11.0，并由 20.07 containers 绑定 A100 | 软件 collective library，不是硬件 collective offload；确切 topology matrix 未给；[S18, `Compatibility`、`Known Issues`]；[S15-S16, component list] |
| dense operator | cuBLAS 11.1.0.229 | CUDA 11.0 release notes 将 BF16、TF32 与 Ampere 优化绑定到 cuBLAS/cuBLASLt；不推广到所有 BLAS operator；[S17, component table 和 cuBLAS section] |
| DNN operator | cuDNN 8.0.1 | 8.0.0 已支持 A100；早期 TF32 只覆盖部分 convolution 路径；[S19, `NVIDIA Ampere Architecture GPU support`]；[S15-S16, component list] |
| structured-sparse operator | cuSPARSELt 0.0.1 | CUDA 11.0、SM8.0，支持 FP16/BF16/INT8 sparse MMA、pruning/compression 与 autotuning；这些 preparation API 不等同 quantization；[S20, `Key Features`、`Support`、`Prerequisites`] |
| inference runtime | TensorRT 7.1.3 的 CUDA 11/A100 build 为 Preview；TensorRT 8.6.1 对 CUDA 11.0 Update 1 和 CC8.0 有版本化支持 | 7.1.3 Preview 与 8.6.1 documented support 分开；[S21, 7.1.3 history 和 8.6.1 compatibility]；[S22, CC8.0 A100/GA100 row] |
| dynamic shape | TensorRT 8.6.1 runtime dimension `-1`、optimization profile 和 shape tensor | 只限定 TensorRT inference runtime，不能推广到任意 framework graph；[S23, `Working with Dynamic Shapes`, §§8.1、8.6-8.10] |
| quantization tool | TensorRT 8.6.1 INT8 calibration 与 Q/DQ explicit quantization | dynamic shapes 需要 calibration optimization profile；7.1.3 只支持有限的 symmetric per-tensor Q/DQ 且 A100 build 为 Preview；[S23, `Working with INT8`, §§7.1、7.4、8.10]；[S21, 7.1.3 limitations] |

ISSCC 将 ISO C++20 asynchronous barrier 写成 `supported in CUDA 8.0`。[S02, PDF p.1, async-copy/barrier 段]。CUDA PG 和 PTX release table 直接表明 split barrier/async copy 对应 CUDA 11.0、PTX 7.0 和 `sm_80`，而 CUDA 8.0 对应 PTX 5.0、`sm_60/61/62`。[S03, §B.23-24]；[S04, PTX 7.2 release table]。本卡采用 CUDA 11.0 的 canonical mapping，ISSCC 原句保留为冲突 assertion；“把 Compute Capability 8.0 写成 CUDA 8.0”仅是解释性推测。

## 10. MIG、调度与虚拟化

MIG（Multi-Instance GPU，多实例 GPU）是 GA100 产品实现上的芯片绑定分区机制。下表所有值都带“支持 MIG 的 A100/A30 产品、MIG mode 和相应软件版本”条件。A100 最多 7 个实例、A30 最多 4 个实例已经说明 profile geometry 不是 full GA100 常量；[S06, Supported GPUs Table 1]。

| 维度 | 可接受内容 | 限制与证据 |
|---|---|---|
| GPU Instance | GI 分配独立 SM、on-chip crossbar port、L2 bank、memory controller 和 DRAM address bus 路径 | 不证明所有 compute/control state 隔离；[S06, Introduction；Concepts `GPU Instance`] |
| Quality of Service（QoS，服务质量）与 fault isolation | 不同 GI 有固定 L2 allocation、DRAM bandwidth 路径和厂商声明的 predictable throughput/latency、memory QoS、fault isolation | 没有带宽百分比、latency bound、fairness、priority 或 Service Level Agreement（SLA，服务等级协议）定值；[S06, Introduction；Concepts Table 3] |
| Compute Instance | 同一 GI 内不同 CI 有 dedicated SM resources | CI 共享父 GI 的 memory slices 和 engines，不能写独立 L2、独立 memory QoS 或完整 fault isolation；[S06, Concepts `Compute Instance`] |
| 地址空间 | GPU context 有 distinct address space 并独立调度 | 文档没有把该属性提升为每个 GI/CI；CI 独立地址空间为 `not_found`；[S06, Concepts `GPU Context`] |
| 调度 | 白皮书的 Sys Pipe 与 host CPU 通信并调度到 GPC/SM；不同 CI 可分别 context switch | 没有 queue structure、priority、preemption point、保存状态或切换 latency；[S01, pp.48、51] |
| mode lifecycle | A100/A30 启用 MIG mode 需要 per-GPU reset、管理权限并停止持有 driver handle 的 daemon；Ampere mode bit 在 InfoROM 跨 reboot 持久 | reset 是模式切换，不是 RAS recovery；[S06, Getting Started `Enable MIG Mode`；Deployment `System Considerations`] |
| geometry lifecycle | GI/CI 可动态 create/destroy，reconfigure 需要 idle；MIG devices/geometry 不跨 reboot 持久 | dynamic 仅指控制面生命周期，不证明 busy resize、state-preserving resize 或 automatic restore；[S06, Getting Started `Creating/Destroying GPU Instances`；Concepts Table 3] |
| 虚拟化部署 | bare metal/container、whole-GPU passthrough 到 Linux guest、MIG-backed vGPU | 不证明 die 自带 hypervisor，也不证明 `MIG=SR-IOV` 或 `GI=VF`；[S06, Supported Configurations；Virtualization] |
| SR-IOV | A100 PCIe 产品单独支持 SR-IOV | MIG Guide 没有把 PF/VF 与 GI/CI 对应；[S01, p.53]；[S06, `SR-IOV` 全指南检索无命中] |
| monitoring | A100/A30 上 NVML 与 `nvidia-smi` 不支持把 utilization 归因到 MIG device，指南建议 DCGM v3+ | 这是软件可观测性限制，不表示硬件没有计数器；[S06, Getting Started `Monitoring MIG Devices`] |
| `MIG Migration` 概念 | `versioned_observation` | 2020 白皮书 p.52 出现 `MIG Migration` 概念，但未给出交付版本、API、hypervisor matrix、停机与一致性条件；该观察不证明功能已经交付；[S01, p.52] |
| raw GI migration、checkpoint、general job restart | `not_found` | MIG 610 的 Concepts、Getting Started、Virtualization 和 Deployment 均未找到 raw GPU Instance（GI）迁移、checkpoint 或通用作业重启机制；[S06, 对应章节检索] |

MIG 610 的最低 driver 表存在内部异常：A100/A30 与 H100/H200 的 driver 行次序和同指南 A100 示例不相容。本卡不采用该表的最低 driver 数值；[S06, Deployment 和 Getting Started driver table]。

## 11. 可靠性、可用性与可维护性

RAS（Reliability, Availability and Serviceability）指可靠性、可用性和可维护性。GA100 的证据必须拆成片上 SRAM、外部 HBM、NVLink、GI、driver 和 service/reset 流程，不能压成“全芯片受保护”。

| 维度 | 可接受内容 | 对象、限制与证据 |
|---|---|---|
| on-die error-correcting code（ECC，纠错码） | A100 enabled implementation 的 L2、L1 cache 和全部 SM register file 使用 SECDED ECC | SECDED 指 single-error correction、double-error detection。来源没有覆盖 Tensor/CUDA datapath 和全部控制状态；[S01, p.35, `ECC Memory Resiliency`] |
| external HBM ECC | A100 HBM2 memory subsystem 支持 SECDED | 属外部 HBM 子系统，和片上 ECC 分开；[S01, p.35]；[S05, fixed PDF p.3 / 文档 p.1] |
| NVLink detection/replay | third-generation NVLink 有 link-level error detection 和 packet replay | 只覆盖 NVLink；[S01, p.52] |
| error containment | GA100 支持 error containment；contained uncorrectable error（UCE，不可纠正错误）的影响限于遇到错误的 application，其余 workload 可继续 | rare uncontained UCE 仍可能发生；`accuracy/performance unaffected` 是厂商陈述；[S05, fixed PDF p.4/文档 p.2 Table 1；p.5/文档 p.3] |
| Dynamic Page Offlining | driver 定位 framebuffer uncorrectable ECC error，并将错误 page 标成 unusable | 受影响 application 终止；多数 contained UCE 不需立即 reset。DPO 不等于物理 repair；[S05, fixed PDF p.6/文档 p.4；p.8/文档 p.6] |
| row remapping | GA100 支持把 failing HBM/DRAM bank row 映射到 spare row | driver、InfoROM、reset 和 service window 是流程条件；[S05, fixed PDF p.4/文档 p.2 Table 1；p.7/文档 p.5 Table 2] |
| recovery | service-window reset 后 row remap 生效并回收 offlined page；uncontained error 需尽快 reset | 不证明作业状态恢复，也没有公开 compute-unit disable 或 capacity derating；[S05, fixed PDF pp.8、10/文档 pp.6、8] |
| telemetry | XID 94/95/63/64，NVML、`nvidia-smi`、SMBPBI、InfoROM remap count/pending/failure/bucketized statistics | 这是 health telemetry，不等于 BIST；[S05, fixed PDF pp.11-12/文档 pp.9-10] |
| field diagnostic | NVIDIA Field Diagnostics 用于 RMA threshold 判定 | 外部 field diagnostic 工具不能改写为 GA100 内建 BIST；[S05, fixed PDF pp.14-15/文档 pp.12-13] |
| built-in self-test（BIST，内建自测）structure | `not_found` | fixed RAS PDF 与 R595 对 `BIST/built-in/self-test` 无支持；[S05, 全文及六个 R595 endpoint 检索] |
| compute-datapath silent data error（SDE，静默数据错误） | `not_found` | ECC/parity 与 contained UCE 都以错误已检测为前提；当前 corpus 没有 Tensor/CUDA datapath silent-data-error checker、冗余执行或 end-to-end coverage；[S01、S05, `silent/SDC` 检索] |
| hardware degradation modes | `not_found` | 只找到 page isolation、application termination 和 unaffected workload continuation，没有公开 compute-unit disable、性能降档或有状态 graceful degradation；[S05, containment/DPO/remap/recovery 章节] |
| GA100 GPU-memory RAS Repair | 明确排除 | R595 Supported GPUs 的 GA100 列未列 `RAS Repair: GPU Memory`，repair 页面限定 select Blackwell products；不得把 DRAM channel/L2 slice swap 下放给 GA100；[S05, R595 Supported GPUs Table 1；GPU Memory Repair] |
| checkpoint/restart | `not_found` | 2020 `MIG Migration` 只保留为版本化概念观察；当前 MIG Guide 未找到已交付的 raw GI migration、checkpoint 或 general job restart，不能把概念线索当作 RAS recovery；[S01, p.52]；[S06, current-guide zero result] |

## 12. 条件化实测与训练/推理相关因素

### 12.1 本卡可保留的实测

| 测量 | 结果 | 完整条件与处理 |
|---|---:|---|
| HPEC L1 latency | 33 cycles | A100 product family，pointer chasing，`ld.global.ca.u64`；SKU、CUDA、driver、compiler、clock、power mode 未报告；[S07, p.6 Table IV] |
| HPEC L2 latency | 200 cycles | `ld.global.cg.u64`，working set 小于 L2，其余条件同上；[S07, p.6 Table IV] |
| HPEC shared load/store | 23/19 cycles | `ld.shared.u64/st.shared.u64`，加入依赖防重排；其余条件同上；[S07, p.6 Table IV] |
| HPEC WMMA cycles | 4、8 或 16 cycles | 逐 datatype/tile/SASS mapping 见第 3.2 节；[S07, p.6 Table III] |
| HPEC scalar instruction | 例如 dependent/independent：add.f16 3/2、add.u32 4/2、add.f64 5/4、mul.lo.u32 3/2、mad.rn.f32 4/2 CPI | 初始化、dependency、PTX→SASS mapping 会改变结果；只作 instruction-path 测量；[S07, p.5 Table II；p.7 Table V] |

这些结果的工作负载阶段、模型、batch、sequence/context length、请求并发和设备并行均为 `not_specified`，因为它们是指令/存储微基准，不是训练、prefill、decode 或服务 benchmark。缺少的环境值保持 unknown，不用论文年份或 A100 公版规格补齐。

### 12.2 被排除但有审计价值的实测

| 来源与结果 | 排除理由 |
|---|---|
| A100 random-access 约 1240-1250、1400、1600 GB/s，约 64 GB cliff，14 groups 推断 | 主体是 A100 SXM4-80GB + HBM + runtime；图读值、软件和统计条件不完整；[S08, Figures 1-6] |
| MLCommons BERT-99 Offline 3560.73 samples/s；SingleStream 90th-percentile 1,551,870 ns，即 0.001551870 s | system-under-test 是 DGX A100，1×A100-SXM-80GB、2×EPYC 7742、2 TB host memory、TensorRT 8.4.0、CUDA 11.6、cuDNN 8.3.2、Driver 510.39.01、DALI 0.31.0；只用于证明 correct-subject GA100 die 结果没有找到；[S10, system JSON、Offline summary、SingleStream summary] |
| A100 @1.41 GHz 的 FP32 19.5 TFLOP/s、TF32 156/312、FP16/BF16 312/624、INT8 624/1248 TOPS、INT4 1248/2496 TOPS、Binary 4992 TOPS、FP64 19.5 TFLOP/s | 108-SM A100 theoretical peak，后列为 sparse effective；不能给 full GA100。格式表的 accumulator 列也不等于最终存储 output；[S02, Figure 3.2.2] |

### 12.3 full GA100 workload benchmark 状态

| 字段 | 状态 | 已检查范围 |
|---|---|---|
| workload latency | `not_found` | 白皮书、ISSCC、HPEC、random-access、Matrix Guide、official product pages 与 fixed MLCommons commit；正结果均为 component、A100 product 或 system subject；[S01-S02、S07-S13] |
| workload throughput | `not_found` | 同上；HPEC Table III 另有单位冲突；[S07-S10] |
| measured workload power | `not_found` | TDP 是 nameplate；两篇微基准未测 power；选定 MLCommons 目录无 power child；[S01、S07-S10、S13] |
| utilization / scaling efficiency | `not_found` | 未找到 full GA100 的 MFU、HFU、MBU 或 scaling efficiency；Matrix Guide 是 GEMM component limit；[S09-S10] |
| energy/token | `not_found` | 没有 full GA100 token workload 与 energy measurement；[S07-S10] |
| token/J | `not_found` | 没有同 scope token throughput 和 power/energy 输入，不取缺失量的倒数；[S07-S10] |

### 12.4 训练与推理可能相关的芯片侧因素

GA100 可为后续训练/推理比较提供八类芯片侧输入：full-design 并行规模与 Tensor feed efficiency；FP16/BF16/TF32/INT8/INT4/Binary/FP64 数值路径；datatype-dependent structured sparsity；L1/shared、L2 policy、async copy 与 compression；NVLink 3 的每设备接口；MIG 的资源隔离与多租户边界；ECC、containment、DPO、row remapping 和 telemetry；CUDA、framework、operator library 与 TensorRT 的版本化支持。

这些输入不直接给出某个模型更适合训练还是推理。训练阶段、prefill、decode、batch、序列/上下文长度、并发、并行方式、模型质量约束、MoE 通信量和 KV Cache 容量必须作为 condition set 或后续 workload model 输入，再观察上述芯片机制是否成为瓶颈或优势。

## 13. 缺失、冲突与未闭合项

### 13.1 `pending_verification`

| 项目 | 尚缺证据或裁决 |
|---|---|
| GA100 首次发布日期 | 全库仍未统一“产品发布”与“厂商首次直接命名”的字段语义。2020-05-14 只作已固定观察；[S11] |
| HBM-stack applicability | 阅读层可确认 HBM stack 位于 package/product path，但 formal requirement 尚无已接受的 exact structural predicate；[S01, pp.19、35] |
| software-visible shared capacity | 192 KiB/SM physical combined capacity 已关闭；164 KB/SM、160 KB/block 和 163 KB/block 的对象粒度与规范版本尚未统一；[S01、S03] |

### 13.2 `not_found`

| 领域 | `not_found` 项与已查边界 |
|---|---|
| 身份与经济性 | 公开销售 SKU、standalone 首次可用日期、current hardware status、地区/出口变体、市场准入、standalone MSRP/list price、裸片成本，以及 GA100 die 自身的定位、目标用途、设计目标和公开部署；已查白皮书、ISSCC、技术博客、Newsroom、A100 product brief 与 SEC 10-Q；[S01-S02、S11-S14] |
| 物理、存储与互联 | 裸片时钟和各时钟域、裸片功耗、full-design L2 容量与持续带宽、L1/shared 与 L2 的端口/Bank/固定 transaction granularity、L2 virtual-memory responsibility、GA100 die/link factor 的 topology/bisection/degree/hops/max scale/oversubscription，以及绝对 NVLink latency；[S01-S04] |
| 计算、数值与媒体 | 物理 Tensor array、精确 product encoding、物理 accumulator、scaling mode/granularity，以及 OFA 与 video decoder 吞吐；[S01-S04] |
| 专用机制、服务与 RAS | Attention、Softmax、Top-k、MoE route/dispatch、network collective offload、dedicated quantizer/dequantizer、transpose/permute、KV Cache manager、raw GI migration/checkpoint/general job restart、compute-datapath SDE、公开 BIST 结构和硬件 degradation mode。MIG 的负向范围是当前指南的 Concepts、Getting Started、Virtualization 与 Deployment；[S01-S06、S21-S23] |
| workload | full GA100 的 workload latency、throughput、measured power、utilization/scaling efficiency、energy/token 和 token/J；[S01-S02、S07-S13] |

### 13.3 204 项中的 `not_applicable`

204 项 requirement 中只计七个 `not_applicable`：M018 的正常裸片数量，以及 INT8、INT4、Binary 三条 precision path 各自的 rounding 和 subnormal 六个 structural N/A。HBM-stack applicability 保持 `pending_verification`；SKU、价格和 GA100 topology 等 included requirement 采用 `not_found`。

### 13.4 卡片不采集的上层字段

封装、中介层、基板、产品 HBM capacity、卡/模组散热与 form factor，以及 DGX/NVSwitch 和 Scale-up/Scale-out 系统配置可以用于解释对象边界，但不属于本轮 204 项 requirement，不参与状态计数。

### 13.5 冲突、版本修订与拒绝项

| 项目 | 来源差异 | 处理 |
|---|---|---|
| CUDA barrier 版本 | ISSCC `CUDA 8.0`；官方 CUDA PG/PTX 为 CUDA 11.0、PTX 7.0、`sm_80` | 采用官方版本化开发文档；ISSCC 原句保留冲突；[S02-S04] |
| 晶体管 | ISSCC 54B；白皮书 54.2B | 取整相容，规范值 54.2B；[S01-S02] |
| A100 HBM bandwidth | ISSCC 1.56 TB/s；白皮书 1555 GB/s | 取整相容，均属 A100 产品，不下放；[S01-S02] |
| L1/shared 容量粒度 | 白皮书 192 KiB physical combined pool；CUDA 文档 164 KB/SM software-visible maximum；per-block limit 从 160 KB 修订为 163 KB，并说明 1 KB reserve | 三者分别属于物理池、SM 级软件上限和 block 级软件上限；只把 160→163 KB 作为版本修订，software-visible shared capacity requirement 仍为 `pending_verification`；[S01、S03] |
| HPEC throughput | Table III 单位为 GB/s，数值与 TFLOP/s/TOPS 峰值重合 | `rejected_for_normalization`；[S07, Table III] |
| HPEC SM 数 | 124 SM | 与 128 full / 108 enabled 均不相容，拒绝；[S07, p.2] |
| MIG minimum-driver table | A100/A30 与 H100/H200 行次序异常，且和示例不相容 | `conflicting_unresolved`，不采用最低版本数值；[S06] |
| A100 108-SM wave | Matrix Guide 以 A100 108 SM 分析 tail wave | 只留 A100 enabled 条件，不改成 GA100 128-SM wave；[S09, §3.2] |

## 14. 来源与 endpoint 索引

本节的 23 行按作品家族计数。内容层最小集成员为 S01-S07、S09-S10、S14-S23，共 19 个来源家族；S08、S11-S13 只承担展示、排除或待核线索，不计入最小集。24 个固定内容版本、40 个实际 endpoint 及逐项反向移除理由见同目录 `ga100_minimal_sources.md`。`候选/暂存` 表示 ID 或 payload 仍位于审计 staging；它可以支持本候选内容，不表示已经进入正式最小参考资料库。

| 短标签 | 来源 ID 或候选来源族 | endpoint、版本与主要定位 | 本卡职责 |
|---|---|---|---|
| S01 | `SRC-M2NA-NVIDIA-AMPERE-WP-2020` | 正式 `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`；A100 Architecture Whitepaper v1.0，PDF pp.9、11、14、19-22、26-41、45-58、67 | identity、full design、SM/Tensor、memory、NVLink、MIG/RAS、media |
| S02 | `SRC-NVIDIA-A100-ISSCC-2021` | 候选 `END-NVIDIA-A100-ISSCC-2021-LOCAL`；PDF pp.1-3 / 印刷 pp.48-50 | A100 enabled 边界、die summary、NVLink PHY、冲突限定 |
| S03 | `SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0` | 候选 `END-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0-LOCAL`；PG-02829-001_v11.0，CUDA 11.0.3，§§3.1-3.2、3.2.3、B.19、B.23-24、I.7 | compiler/runtime、SIMT、L2 policy、async copy、barrier |
| S04 | `SFAM-R1GA100-PTX-ISA`，版本 `SRC-NVIDIA-PTX-ISA-7-0`、`SRC-NVIDIA-PTX-ISA-7-2` | 候选 `END-NVIDIA-PTX-ISA-7-0-LOCAL`、`END-NVIDIA-PTX-ISA-7-2-LOCAL`；PTX §§3.1、9.7.8.16、9.7.12.10-11、9.7.13.4-5、12.1-12.3 | ISA、numerics、sparse metadata、版本链 |
| S05 | `SFAM-NVIDIA-GPU-MEMORY-ERROR-MGMT`，版本 `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001`、`SRC-NVIDIA-GPU-MEM-ERROR-MGMT-R595` | 候选 fixed PDF endpoint 及 R595 Supported/Containment/DPO/Row Remap/Response/Repair endpoints | RAS 正向机制、telemetry、current negative boundary |
| S06 | `SRC-NVIDIA-MIG-USER-GUIDE-610` / `SFAM-R1GA100-MIG-USER-GUIDE` | 候选 `END-NVIDIA-MIG-USER-GUIDE-610-*`；Supported GPUs、Introduction、Concepts、Getting Started、Deployment、Virtualization、Profiles | GA100 product mapping、GI/CI、QoS、lifecycle、virtualization |
| S07 | `SRC-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-2022` | 候选 `END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL`；arXiv:2208.11174v1，PDF pp.4-7, Tables II-V | independent instruction/memory measurement、unit conflict |
| S08 | `SRC-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-2024` | 候选 `END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-LOCAL`；arXiv:2405.11425v1，Figures 1-6 | A100 product random-access lead 与排除证据 |
| S09 | `SFAM-GA100R37-NVIDIA-MATRIX-GUIDE` | 候选 `END-PROP-GA100R37-MATRIX-LOCAL`；2026-08-21 snapshot，§§2.2、2.3、3.1-3.2 | Tensor/GEMM utilization-limit 与 108-SM product boundary |
| S10 | `SFAM-GA100R37-MLCOMMONS-INFERENCE-V2-0` | fixed commit `36d324b502175621063a478fcbf6d2cb9421ca34`；system JSON、BERT-99 Offline/SingleStream summary 和目录 endpoints | correct-subject benchmark negative closure |
| S11 | `SFAM-R1GA100-NVIDIA-TECHNICAL-BLOG` | 候选 `END-PROP-R1GA100-WEB-001-LOCAL`；2020-05-14 Ampere Architecture in Depth snapshot | GA100 direct naming/date observation、benchmark negative search |
| S12 | `SFAM-R1GA100-NVIDIA-NEWSROOM-A100-LAUNCH` | 候选 `END-PROP-R1GA100-WEB-002-LOCAL`；PDF mirror `WEB-003` 为 duplicate | A100 launch/product boundary |
| S13 | `SFAM-R1GA100-NVIDIA-A100-PCIE-PRODUCT-BRIEF` | 候选 `END-PROP-R1GA100-WEB-004-LOCAL`、`WEB-005-LOCAL`；PB-10137-001_v03、PB-10577-001_v03 | A100 40/80GB PCIe 规格与 GA100 SKU 关系边界 |
| S14 | `SFAM-GA100R37-NVIDIA-20220731-10Q` | 候选 `END-PROP-GA100R37-SEC-10Q-LOCAL`；Form 10-Q Item 1A | A100/H100 market-access 正证与 GA100 wrong-subject closure |
| S15 | `SFAM-R1GA100-NVIDIA-PYTORCH-CONTAINER` | 候选 `R1GA100-WEB-017/018`；20.06/20.07 release notes | PyTorch/A100 backend、组件版本与 known issue |
| S16 | `SFAM-R1GA100-NVIDIA-TENSORFLOW-CONTAINER` | 候选 `R1GA100-WEB-019/020`；20.06/20.07 release notes | TensorFlow/A100 backend、NCCL launch issue |
| S17 | `SFAM-R1GA100-NVIDIA-CUDA-RELEASE-NOTES` | 候选 `R1GA100-WEB-021`；CUDA 11.0 GA | CC8.0 reachability、cuBLAS 版本与 Ampere capability |
| S18 | `SFAM-R1GA100-NVIDIA-NCCL-RELEASE-NOTES` | 候选 `R1GA100-WEB-022`；NCCL 2.7.6 | communication library version 与限制 |
| S19 | `SFAM-R1GA100-NVIDIA-CUDNN-RELEASE-NOTES` | 候选 `R1GA100-WEB-023`；cuDNN 8.x archive | A100 support 起点与 operator coverage |
| S20 | `SFAM-R1GA100-NVIDIA-CUSPARSELT-GUIDE` | 候选 `R1GA100-WEB-024`；cuSPARSELt 0.0.1 | structured-sparse operator library |
| S21 | `SFAM-R1GA100-NVIDIA-TENSORRT-RELEASE-NOTES` | 候选 `R1GA100-WEB-025`；8.6.1 archive 含 7.1.3 history | TensorRT lifecycle 与 CUDA compatibility |
| S22 | `SFAM-R1GA100-NVIDIA-TENSORRT-SUPPORT-MATRIX` | 候选 `R1GA100-WEB-026`；TensorRT 8.6.1 CC8.0 row | A100/GA100 reachability 与 precision support |
| S23 | `SFAM-R1GA100-NVIDIA-TENSORRT-DEVELOPER-GUIDE` | 候选 `R1GA100-WEB-027`；TensorRT 8.6.1 dynamic-shape / INT8 chapters | dynamic shape、calibration 与 Q/DQ |

## 15. 完整度、复核与发布边界

| 领域 | 候选状态 | 说明 |
|---|---|---|
| 产品身份 | `partial` | vendor/name/type/architecture 关系已关闭；release 仍待核，公开销售 SKU、standalone availability、current hardware status 和 die-specific positioning 为 `not_found` |
| 物理实现 | `partial` | process/foundry/area/transistors/full resource/HBM interface 已有；HBM-stack applicability 待核，clock/power/L2 full capacity 缺失 |
| 计算资源 | `partial` | full-design counts、SM organization、FP32+INT32 concurrency、instruction tile 和 utilization limits 已有；physical Tensor array/aggregate peak 缺失 |
| 数值格式 | `partial` | ISA-visible operand/accumulator/output、rounding/saturation/sparsity已分路径；product/physical accum/scaling 缺失 |
| 存储层次 | `partial` | RF、192 KiB physical L1/shared、L2 存在性、policy、async copy、compression 和条件化 cycles 已有；software-visible shared capacity 待核，full L2/HBM、L2 virtual-memory responsibility 与端口/Bank/带宽缺失 |
| 互联 | `partial` | PCIe 4.0 x16、12-link NVLink 接口和方向化带宽已关闭；GA100 die/link factor 的 topology、bisection、degree、hops、max scale、oversubscription 和绝对 latency 为 `not_found`，DGX/NVSwitch 仅作 wrong-subject 边界 |
| 特殊能力 | `partial` | sparse、async copy、warp reduction、compression、OFA、video decode 已有；Attention/Softmax/Top-k/MoE/KV 等逐项 `not_found` |
| 软件 | `complete` 于内容候选 | compiler/runtime/framework/library/dynamic shape/quantization 都有版本化一手来源；全部只到 `documented_supported`，正式 snapshot ingestion 待完成 |
| 调度与服务 | `partial` | SIMT scheduler、Sys Pipe、GI/CI 与 lifecycle 有值；`MIG Migration` 仅为 2020 概念观察，preemption、定量 QoS、CI 地址空间以及 raw GI migration/checkpoint/general job restart 为 `not_found` |
| 可靠性 | `partial` | ECC、containment、DPO、row remap、recovery、telemetry 有值；SDE、BIST、degrade 和 general checkpoint/restart 为 `not_found` |
| 实测指标 | `missing_public_data` | 可接收的只有 A100-carrier on-die component cycles；full GA100 workload 六字段均 `not_found` |
| 经济性 | `not_found` | 公开价格是 included requirement；计划官方来源没有 standalone GA100 die MSRP/list price，裸片成本也未找到 |
| 来源证据 | 完成 | 正文索引 23 组资料，其中 19 组进入本卡最小参考资料，4 组只用于说明边界或提供线索 |

本候选已经逐节检查芯片属性、架构机制、产品条件、系统条件和负载变量的边界。它没有把 A100 108-SM、HBM、功耗、MIG profile、DGX/MLCommons 或模型变量写成 full GA100 常量；也没有把接口支持升级成实测、把软件库升级成专用硬件，或用零填补未知值。

复核结论：GA100 full-die 资料卡已经完成。正文中的数字和技术描述均通过 `[Sxx, 定位]` 回到原始资料；未公开、未找到和对象不适用的项目保留说明。
