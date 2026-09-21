# Groq GroqChip Processor（第一代）资料卡

> 模板版本：1.3（芯片架构事实口径）  
> 卡片状态：已完成  
> 资料截止日：2026-08-25

本卡的正式主语是 first-generation GroqChip Processor，也就是 2020 ISCA paper 所称的第一代 Tensor Streaming Processor（TSP）ASIC，后由 Groq 以 LPU（Language Processing Unit）架构产品对外销售。GroqCard、GroqNode、GroqRack 与 GroqCloud 是上层卡、服务器、集群和云服务，不与本芯片合并；NVIDIA Groq 3 LPX 是后续架构，也不进入本卡。[1, Abstract and Conclusion] [2, pp.1-2]

## 1. SKU 身份与厂商定位

| 字段 | 内容 | 定位主语或适用条件 | 来源 |
|---|---|---|---|
| 厂商 | Groq, Inc. | first-generation Groq silicon | `[1, title and authors]` `[2, pp.1-2]` |
| 产品家族 | GroqChip / LPU | 产品 brief 称 LPU architecture；论文原名 TSP | `[1, Abstract]` `[2, p.1]` |
| 完整 SKU | GroqChip Processor（第一代） | 官方 brief 没有容量后缀或可区分的 chip part number | `[2, title and p.2]` |
| 对象形态 | 单颗 14nm ASIC processor | 不是 GroqCard、GroqRack 或 cloud instance | `[1, pp.1, 4 and 12]` `[2, p.2]` |
| 架构代际 | 第一代 TSP / LPU | 产品 blog 直接说明 first-generation GroqChip 由 software-first flow 构建 | `[1, Conclusion]` `[3, Software First]` |
| 首次公开与可用状态 | architecture 于 2020 ISCA 公开；2022 v1.5 product brief 写 `In production`，2024 v1.7 则写作为 GroqRack compute cluster 的一部分提供 | v1.7 不承诺 standalone chip retail；当前 GroqRack 仍作为 on-premises inference solution 分销 | `[1, publication]` `[2, p.2]` `[4, p.2]` `[5, partnership announcement]` |
| 厂商定位 | AI/ML/HPC acceleration，当前主定位为 AI inference | 2024 brief 同时列 AI、ML、HPC；当前官网以 fast inference 说明 LPU | `[2, p.1]` `[3, Overview and Conclusion]` |
| 目标 workload | linear algebra、LLM 和其他 AI inference | 厂商定位，不是 workload benchmark | `[3, Software First and Conclusion]` |
| 产品目标 | fully deterministic、predictable low latency、减少 data movement，并通过多 chip scale-out 扩展 | 产品特性，不等于本卡汇总应用性能 | `[2, p.1]` `[3, Design Principles 2-4]` |

本卡包含 GroqChip processor 的 die、functional slices、compute paths、on-die SRAM、C2C、PCIe controller、功耗和数值语义。本卡不包含 GroqCard 的 board power/form factor、GroqRack 的 chip count/topology、GroqCloud 的服务性能或 NVIDIA Groq 3 LPX。

## 2. 层级关系与复用

| 层级 | 本 SKU 对应对象 | 是否与其他 SKU 共享 | 本卡怎么使用 | 来源 |
|---|---|---|---|---|
| Core IP | TSP functionally sliced architecture | 第一代 GroqCard/GroqRack 复用 | 复用[第一代 LPU 架构资料](../架构/Groq_第一代_LPU_架构.md)，本卡补入实体实现值 | `[1, pp.1-4]` |
| die | first-generation TSP ASIC，单 die | 没有 chiplet 证据 | 记录 14nm、25×29mm、26.8B transistors 与完整 slices | `[1, pp.1, 4 and 12]` |
| package | package construction 未公开 | 不适用 | 不把 PCIe CEM card form factor 写成 silicon package | `[1, Conclusion]` |
| 产品 SKU | GroqChip Processor | 不适用 | 正式比较单位 | `[2, p.2]` |
| 相关系统 | GroqCard、GroqNode、GroqRack、GroqCloud | 上层形态 | 只记录 chip containment/availability 和 C2C system boundary | `[2, p.2]` `[5, partnership announcement]` |

## 3. Core 微架构

| 维度 | 公开事实 | 作用域与条件 | 来源 |
|---|---|---|---|
| 矩阵、向量、标量与控制路径 | chip 含 4 个独立 320×320 MXM planes、320 lanes×16 vector ALUs = 5,120 vector ALUs，以及 ICU、SXM、MEM 与 C2C functional slices | 不是传统 replicated-core 组织；所有数值为 first TSP die | `[1, pp.3-5 and Conclusion]` |
| 执行模型与调度 | functionally sliced spatial pipeline；compiler cycle-accurately 安排 instructions、data movement 和 slice use，硬件执行 fully deterministic schedule | 144 independent instruction queues；程序开始一次 barrier 后，producer/consumer 通过 stream registers 同步-free 运行 | `[1, pp.2-3 and 6]` |
| 局部存储与数据搬运 | 88 MEM slices 构成 flat partitioned globally shared SRAM；compiler 显式分配 slice/bank 并安排 read/write。architectural vectors 为 320 bytes，在 horizontal stream registers 上流动，SXM 处理 north/south movement | SRAM 不是 hardware-managed cache；中间结果可在 functional slices 间 chain，避免回写 MEM | `[1, pp.3-6 and 8-9]` |
| 数值与累加路径 | MXM 支持 INT8 input→INT32 accumulate 和 FP16 input→FP32 accumulate；320-element sum 最终只执行一次 rounding。VXM 支持 32-bit fixed/floating arithmetic，产品 brief 列 VXM FP16/FP32 | rounding mode、subnormal、NaN/Inf、TruePoint scaling granularity 与 physical accumulator width 未公开 | `[1, pp.5, 8-9 and Conclusion]` `[2, p.2]` |
| 稀疏与专用单元 | first TSP 没有采用 pruning/sparsity optimization，以维持 deterministic execution time/power；SXM 负责 permute、shift、distribute、rotate 和 transpose | 未找到专用 attention、MoE routing、top-k、sampling 或 KV Cache hardware | `[1, pp.4-5, 9 and Conclusion]` |

## 4. Die、chiplet 与 package

| 维度 | 共享实现或物理组成 | 作用域与条件 | 来源 |
|---|---|---|---|
| 计算单元数量 | 4×320×320 MXM plane；5,120 vector ALUs；144 ICU queues；88 MEM slices | single first-generation die | `[1, pp.3-5 and Conclusion]` |
| 片上存储 | 220MiB globally shared SRAM（产品 brief 写 230MB） | 220MiB≈230.7MB，属于二进制/十进制单位差异；产品 brief 的 230MB 与 paper 实现相容 | `[1, pp.3-5]` `[2, pp.1-2]` |
| 片内互联 | east/west stream registers + SXM north/south movement；stream-register aggregate 20TiB/s at illustrative 1GHz | 20TiB/s 是 on-die stream-register bandwidth，不是 SRAM 或 C2C bandwidth | `[1, pp.4-5]` |
| SRAM bandwidth | 55TiB/s at illustrative 1GHz；product brief v1.7 写最高 80TB/s on-die memory bandwidth | 55TiB/s≈60.5TB/s，与 80TB/s 不是单位换算；按 paper implementation 与 later product brief 两个口径并列 | `[1, p.5, Equations 1-2]` `[2, pp.1-2]` |
| 内存控制器与 PHY | public product brief 只列 on-die SRAM；未列 HBM/GDDR/DDR | 不据此声称物理上绝无所有其他 memory PHY，只记录公开 product interface | `[2, p.2]` |
| 工艺与物理规模 | 14nm、25×29mm、26.8B transistors | first-generation ASIC die；25×29mm 为原文尺寸，foundry 和直接标注的 die area 未在两份最小资料中公开 | `[1, pp.1 and 12]` |
| 封装组成 | 未公开 package type、substrate、bump、dimensions 或 thermal interface | paper 的 PCIe CEM 指 card/form factor，不是 chip package | `[1, Conclusion]` |
| 封装内互联 | 不适用；未见 multi-die/chiplet | C2C 是 package 外 device interconnect | `[1, pp.4-5]` |
| RAS | 128-bit SRAM word 使用 9-bit SECDED ECC；ECC 随 stream datapath 搬运，consumer slice 检查；product brief 称 end-to-end on-chip ECC protection | 可纠正 single-bit、检测 double-bit；未公开 spare/retirement/replay | `[1, p.5, Error handling and reliability]` `[2, p.1]` |

## 5. SKU 配置

| 字段 | 原始值 | 条件和口径 | 来源 |
|---|---:|---|---|
| 实际使能计算资源 | 4 MXM planes、5,120 vector ALUs、144 ICU queues、88 MEM slices | first-generation full die；没有另一个公开 disabled-resource SKU | `[1, pp.3-5 and Conclusion]` |
| 时钟 | 900MHz product point | 2024 v1.7 specification；paper 另给 nominal 900MHz，并以 1GHz 做 architecture throughput illustration | `[1, p.1]` `[2, p.2]` |
| INT8 theoretical peak | up to 750TOPS @900MHz | product brief 未说明 dense/sparse、MAC count；paper 1GHz 给 820 TeraOps/s vendor deep-learning-op label | `[1, Conclusion]` `[2, p.2]` |
| FP16 theoretical peak | 188TFLOPS @900MHz | product brief 未说明 FMA counting；MXM uses FP16 input/FP32 accumulate | `[1, pp.5 and 9]` `[2, p.2]` |
| 内存类型与容量 | 230MB on-die SRAM | v1.7 decimal product value；paper 220MiB | `[1, pp.3-5]` `[2, p.2]` |
| 内存带宽 | up to 80TB/s on-die | v1.7 product headline；读写方向与 sustained condition 未说明 | `[2, pp.1-2]` |
| 主机接口 | integrated PCIe Gen4 x16 controller | first-generation chip I/O；payload bandwidth 未公开 | `[2, p.2]` |
| 设备互联端点 | 16 integrated RealScale C2C interconnects；paper implementation 为 16×x4 links at 30Gbps/lane，3.84Tb/s raw bidirectional off-chip pin bandwidth | 3.84Tb/s 是 16×4×30Gbps×2 directions 的 raw aggregate；不等于 payload throughput | `[1, pp.4-5]` `[2, pp.1-2]` |
| 内存访问语义 | partitioned global address space over SRAM；compiler explicitly controls placement/banks | 不存在公开 unified CPU/GPU virtual address、coherence 或 page migration 语义 | `[1, pp.4-6 and 8]` |
| 跨设备集合通信能力 | C2C Send/Receive primitives move 320-byte vectors；未找到 hardware collective/reduction engine | multi-chip compiler/runtime 可编排通信，不等于专用 collective hardware | `[1, pp.4-5 and Table I]` |
| 功耗 | max 300W；TDP 215W；average 185W | v1.7 chip specification；workload/ambient 条件未展开 | `[2, p.2]` |
| 形态与散热 | processor chip；package/cooling 未公开 | product v1.7 作为 GroqRack 一部分提供；GroqCard board form factor/power 不下放 | `[2, p.2]` |

## 6. 系统级互联上下文

| 内容 | 系统架构事实 | 与本 SKU 的边界 | 来源 |
|---|---|---|---|
| Scale-up | 16 C2C ports 可让 chips 直接通信；product brief 称无需额外 switches、cards 或 CPUs | 具体 GroqRack chip count、topology、routing 与 bisection bandwidth 未在本卡最小资料中固定 | `[2, p.1]` |
| Scale-out | 未记录独立 network endpoint | C2C 是 device scale-up；GroqRack/cloud network 不下放为 chip NIC | `[1, pp.4-5]` |
| 系统可靠性 | 未公开 rack-level redundancy/failover | chip-level ECC 已在上一节记录 | `[2, pp.1-2]` |
| 相关系统 | 2024 v1.7 明确 GroqChip 作为 GroqRack compute cluster 的一部分 available；2025 官方 partnership 仍把 GroqRack 作为 on-premises solution 分销 | 证明产品可用状态，不把 rack aggregate performance 写进 chip card | `[2, p.2]` `[5, partnership announcement]` |

## 7. 证据缺口与来源冲突

| 项目 | 状态 | 已检查范围或冲突来源 | 当前处理 |
|---|---|---|---|
| TSP、LPU 与 GroqChip | 命名演进，可确认同一第一代产品链 | 2020 paper 用 TSP；2024 brief 写 GroqChip built on LPU；2025 official blog 明称 first-generation GroqChip | 标题采用产品名 GroqChip，架构别名在正文保留 |
| 220MiB / 230MB | 单位一致 | 220MiB≈230.7MB | paper 保留 MiB，product field 保留 230MB |
| 55TiB/s / 80TB/s | 来源版本差异 | paper first implementation at illustrative 1GHz vs 2024 v1.7 product maximum | 不通过单位换算消除差异，分别记录 |
| 820TeraOps/s / 750TOPS | 时钟与 vendor-label 条件不同 | paper 1GHz vs product 900MHz；operation-count rules 均未完全公开 | SKU 主值采用 v1.7 750TOPS@900MHz，paper 值作为 first-silicon context |
| die/package/card boundary | die 与 card information 混写风险 | 25×29mm 是 die；PCIe CEM 是 board/form factor；GroqCard 有独立 power/connectors | 本卡不采用 card dimensions、board power 或 available connector count |
| current standalone availability | 未找到 | v1.7 只写作为 GroqRack 一部分 available；当前官方材料转向 GroqCloud/GroqRack | 不声称 standalone chip 当前零售 |
| package、thermals 与 clock mode | 未公开 | ISCA paper、v1.7 brief、official architecture blog | package construction、cooling、base/boost、voltage 与 thermal limits 保持未公开 |

## 8. 最小参考资料

| 编号 | 资料 | 类型 | 本卡使用的信息 | 链接或本地文件 |
|---:|---|---|---|---|
| `[1]` | Abts et al.，*Think Fast: A Tensor Streaming Processor (TSP) for Accelerating Deep Learning Workloads*，ISCA 2020 | Groq authors 的原始 architecture paper | first ASIC、functional slices、compute、memory、C2C、ECC、die、numerics 与 execution model | [本地 PDF](../../../原始资料/论文/Groq_LPU/01_厂商直接架构论文/2020_Groq_Think_Fast_Tensor_Streaming_Processor_ISCA.pdf) |
| `[2]` | Groq，*GroqChip Processor Product Brief v1.7*，2024 | 官方 product brief | exact product identity、availability、14nm、900MHz peaks、230MB/80TB/s、C2C、PCIe、numerics 与 power | [本地 PDF](../../../原始资料/论文/Groq_LPU/90_官方白皮书与技术资料/2024_GroqChip_Processor_Product_Brief_v1.7.pdf) |
| `[3]` | Groq，*What Is a Language Processing Unit?*，2025-03-07 | 官方 architecture blog | LPU naming、first-generation GroqChip relationship、software-first、determinism、assembly-line model 和 on-chip SRAM | <https://groq.com/blog/the-groq-lpu-explained> |
| `[4]` | Groq，*GroqChip Processor Product Brief v1.5*，2022 | 官方历史 product brief | `In production` 状态及同代芯片规格 | <https://www.groq.com/GroqDocs/Product%20Spec%20Sheet%20-%20GroqChip%E2%84%A2%20Processor.pdf> |
| `[5]` | Groq，*Groq Partners with Aljammaz Technologies to Power AI Inference Across MENA*，2025-10-17 | 官方 announcement | GroqRack 仍作为 on-premises compute cluster 分销 | <https://groq.com/newsroom/groq-partners-with-aljammaz-technologies-to-power-ai-inference-across-mena> |

## 9. 完成检查

- [x] SKU 身份和厂商定位的主语已经固定
- [x] architecture、die、processor、GroqCard、GroqRack 和 cloud service 没有混用
- [x] 共享第一代 LPU 架构资料已经链接复用
- [x] 计算、数值、内存、互联和功耗字段均已填写或登记缺失
- [x] compiler-managed SRAM 与 cache、HBM、external memory 没有混写
- [x] on-die streams、SRAM bandwidth 与 off-chip C2C 已经分开
- [x] chip C2C endpoints 与 rack topology/aggregate bandwidth 已经分开
- [x] 系统级上下文只保留 GroqRack availability 和 direct-C2C boundary
- [x] 资料卡没有混入 benchmark、部署成绩或训练/推理比较分析
- [x] 所有数字和技术描述都能回到原文位置
- [x] 文末只列正文实际使用的资料

复核结论：first-generation GroqChip 是一颗 14nm、25×29mm、26.8B-transistor 的 deterministic TSP/LPU processor。v1.7 product point 为 900MHz、最高 750TOPS INT8、188TFLOPS FP16、230MB on-die SRAM、最高 80TB/s memory bandwidth、16 个 RealScale C2C interconnect、PCIe Gen4 x16 controller，以及 300W maximum/215W TDP/185W average power。其功能切片由 compiler cycle-accurately 编排，chip 内有 4 个 320×320 MXM planes、5,120 vector ALUs、144 instruction queues 和 88 MEM slices；SRAM 与 streaming datapath 使用 SECDED ECC。当前可确认的产品状态是作为 GroqRack compute cluster 的一部分提供；standalone chip retail、package construction、cooling 和部分数值细节未公开。
