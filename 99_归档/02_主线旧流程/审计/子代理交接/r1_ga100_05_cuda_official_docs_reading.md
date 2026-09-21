# GA100 CUDA 官方文档定向阅读卡

> 子任务：`r1_ga100_05_cuda_official_docs_reading`  
> 状态：完成，待总控复核  
> 研究对象：NVIDIA GA100 die、A100 对 GA100 的启用配置、Ampere architecture，以及 CUDA/PTX 对 `sm_80` 暴露的软件接口  
> 资料截止与访问日期：2026-08-21  
> 写入边界：只新增本交接文件；没有下载网页、建立正式来源记录、修改正式 CSV、资料卡或进度文件

## 本轮结论

CUDA 官方文档可以补上白皮书的三类证据缺口。第一，PTX 明确把 NVIDIA GPU 的执行模型表述为 SIMT，并说明 SIMT 单元在指令发射时从 ready warp 中选择一个 warp；这一表述与白皮书 Figure 7 的 GA100 warp scheduler 结构合并后，足以支持 `SIMT + warp-level scheduling` 分类。它仍是公开机器模型，不能当作调度仲裁 RTL、scoreboard 结构或每周期真实发射行为的披露。

第二，CUDA 11.0 文档把 global-to-shared async copy、split arrive/wait barrier 和 L2 residency control 的软件版本与限制写清楚了。`cp.async` 和 `mbarrier` 在 PTX ISA 7.0、CUDA 11.0 中面向 `sm_80` 出现；CUDA C++ Programming Guide 也明确说 async-copy 在 11.0 仍是 experimental。到 CUDA 11.2.1，接口改由 `cuda::pipeline`、`cuda::barrier` 和 `cuda::memcpy_async` 承接。公开文档因此支持“硬件能力已由软件接口暴露”和 `documented_supported`，不支持 `runnable_verified`、`benchmarked` 或“独立 DMA engine”。

第三，structured sparse MMA 的直接 PTX 接口不是 CUDA 11.0 首发项。PTX ISA 7.1、CUDA 11.1 才加入 `mma.sp`，目标为 `sm_80` 或更高。PTX 还显示稀疏粒度与数据格式有关：FP16/BF16 和 INT8 是 2:4，TF32 是 1:2，INT4 是 pair-wise 4:8。资料卡若只写一条无条件“2:4”，会丢失 ISA 已公开的格式约束。

ISSCC 论文中的 `supported in CUDA 8.0` 不应进入正式事实。CUDA 官方文档明确区分 CUDA software version 与 Compute Capability，并把 split barrier、async-copy 的首个文档版本放在 CUDA 11.0，同时把硬件目标写成 Compute Capability 8.0。现有证据不能证明 ISSCC 原句为何写成 8.0，但可以判定它不能作为软件版本事实；最可能的解释是把 `CUDA 11.0` 与 `Compute Capability 8.0` 混写或排版失误，这一解释只能标为推断。

## 来源版本和来源家族

下列标识只是供总控分配正式 ID 时参考，不构成正式 ID 预留。同一文档的不同归档修订应归入同一来源家族，不能按版本数增加独立来源计数。

| 候选来源 | 文档版本与日期 | 官方入口 | 本轮职责 | 来源家族处理 |
|---|---|---|---|---|
| `CAND-NVIDIA-AMPERE-TUNING-11-0-3` | *NVIDIA Ampere GPU Architecture Tuning Guide*，CUDA Toolkit v11.0.3，2020-08-04 | [归档 HTML](https://docs.nvidia.com/cuda/archive/11.0/ampere-tuning-guide/index.html) | 初始资源上限、async copy、barrier 和 L2 control 的发布期表述 | 与 11.2.1 版同属 `Ampere Tuning Guide` revision series |
| `CAND-NVIDIA-AMPERE-TUNING-11-2-1` | 同名文档，CUDA Toolkit v11.2.1，2021-02-09 | [归档 HTML](https://docs.nvidia.com/cuda/archive/11.2.1/ampere-tuning-guide/index.html) | 明确区分 CC 8.0/A100 与 CC 8.6，并修订 per-block shared-memory 上限 | 作为该家族后续修订；不与 11.0.3 计为两份独立来源 |
| `CAND-NVIDIA-CUDA-PG-11-0` | *CUDA C++ Programming Guide*，`PG-02829-001_v11.0`，CUDA Toolkit v11.0.3 归档 | [归档 HTML](https://docs.nvidia.com/cuda/archive/11.0/cuda-c-programming-guide/index.html)；[固定 PDF](https://docs.nvidia.com/cuda/archive/11.0/pdf/CUDA_C_Programming_Guide.pdf) | CUDA 11.0 首发版本、experimental 状态、API/对齐/方向限制、L2 control 与 MIG 条件 | 与 11.2.1 版同属 `CUDA C++ Programming Guide` revision series |
| `CAND-NVIDIA-CUDA-PG-11-2-1` | 同名文档，v11.2.1，2021-02-09 | [归档 HTML](https://docs.nvidia.com/cuda/archive/11.2.1/cuda-c-programming-guide/index.html) | `cuda::barrier`、`cuda::pipeline` 和更新后的 `memcpy_async` 接口；软件版本与 Compute Capability 的概念区分 | 用于版本演进，不增加来源独立性 |
| `CAND-NVIDIA-PTX-ISA-7-0` | *Parallel Thread Execution ISA* 7.0，CUDA Toolkit v11.0.3 | [归档 HTML](https://docs.nvidia.com/cuda/archive/11.0/parallel-thread-execution/index.html) | SIMT 机器模型、`cp.async`、`mbarrier`、`sm_80` 首次目标支持 | 与 PTX 7.2 同属 `PTX ISA` revision series |
| `CAND-NVIDIA-PTX-ISA-7-2` | *Parallel Thread Execution ISA* 7.2，CUDA Toolkit v11.2.1，2021-02-09 归档 | [归档 HTML](https://docs.nvidia.com/cuda/archive/11.2.1/parallel-thread-execution/index.html) | `mma.sp`、稀疏 metadata 和 revision history；同时保留 7.0 指令语义 | 若进入最小集，可作为本轮 PTX 家族的规范修订版本 |

本轮没有使用当前滚动版 CUDA 13.x 文档来回填 2020 年的软件成熟度。滚动版会混入后续接口和术语，不能替代发布期归档版。CUDA 11.2.1 只用于观察同一 11.x 家族内的修订和接口演进。

## 对象和证据层级

| 文档中的主语 | 本轮采用的对象边界 | 可支持的结论 | 不能支持的结论 |
|---|---|---|---|
| CUDA/PTX generic GPU machine model | 通用 CUDA/PTX 抽象 | SIMT、warp、ready-warp issue 的公开抽象 | GA100 的仲裁算法、物理 scheduler RTL、scoreboard 或实际延迟 |
| NVIDIA Ampere GPU architecture | Ampere 架构机制 | async global-to-shared copy、shared-memory barrier、warp reduction 等架构能力 | 所有 Ampere 产品具有相同资源数量和相同 Compute Capability |
| Compute Capability 8.0 / `sm_80` | 软件和 ISA 目标 | API 或指令在该 target 上可生成/使用，具体限制按文档保存 | `sm_80` 等于某一唯一裸片，或接口必然对应一个公开物理模块 |
| A100 GPU | GA100 的具体启用产品语境 | A100 与 CC 8.0 的绑定、运行时可见资源上限 | full GA100 的 128-SM 物理总量、所有接口都启用或所有资源都可分配 |
| GA100 die | GA100 工作包的芯片主体 | 由白皮书/ISSCC 直接确认的物理结构，再与 CUDA 文档的软件暴露建立关系 | 把 A100 SXM、HBM、功耗或 MIG 7-way 配置直接写成 full die 固有值 |

PTX 是虚拟 ISA。PTX 文档说明 PTX 程序还会被翻译为 target GPU instruction set，因此 `cp.async`、`mbarrier`、`mma.sp` 的存在可以支撑“ISA 可见的专用指令语义”，不能直接证明 native opcode 编码、物理模块数量、pipeline 深度或内部数据通路。

## SIMT、warp scheduler 与 CC 8.0 资源上限

| 编号 | 版本、章节和定位 | 原文支持层级 | 主体与候选字段 | 采用边界 |
|---|---|---|---|---|
| CUDA-SIMT-01 | PTX ISA 7.0，§2.2.1 `Cooperative Thread Arrays`、§3.1 `A Set of SIMT Multiprocessors`，HTML lines 826、850-861 | 直接陈述通用 PTX machine model；与 GA100 的绑定需要 A100=`CC 8.0` 和白皮书 Figure 7 组成证据链 | Ampere/GA100 SM；`FIELD-COMP-EXECUTION` | 可规范化为 SIMT。不要把 generic PTX 模型写成 GA100 独有设计，也不要用它替代 Figure 7 的物理 scheduler 数量。 |
| CUDA-SIMT-02 | PTX ISA 7.0，§3.1，HTML lines 855-858 | 直接陈述 SIMT unit 管理 warp，并在 issue 时选择 ready warp | GA100 SM；`FIELD-COMP-CONTROL-SCHEDULING` | 可写“warp-level ready selection”的公开抽象。文档没有公布 ready 判定、优先级、公平性、scoreboard、dual-issue 或 stall policy。 |
| CUDA-SIMT-03 | CUDA C++ Programming Guide v11.0，§4.1 `SIMT Architecture`，PDF pp.129-130 / 印刷 pp.112-113 | 直接陈述 32-thread warp、warp scheduler 和 divergence 行为；generic CUDA hardware model | GA100 SM；`FIELD-COMP-CONTROL-SCHEDULING` | 32 threads/warp 是编程/执行粒度。它不等于 `FIELD-COMP-ISSUE-WIDTH=32`；后者只能由 GA100 Figure 7 的 `32 thread/clk` 单独支撑。 |
| CUDA-SIMT-04 | PTX ISA 7.0，§3.2 `Independent Thread Scheduling`，HTML lines 867-871 | 直接陈述 Volta 及之后的通用调度语义 | Ampere/GA100；`FIELD-COMP-CONTROL-SCHEDULING`、`FIELD-COMP-UTILIZATION-LIMIT` | 可保留为继承的架构语义和 warp-synchronous code 风险，不能推断 GA100 的 per-thread physical issue。 |
| CUDA-SIMT-05 | CUDA C++ Programming Guide v11.2.1，§I.7.1 `Architecture`，HTML lines 11676-11682 | 直接陈述 Compute Capability 8.x SM 的软件可见调度组织；通过 A100=`CC 8.0` 绑定到 GA100 | CC 8.x，适用于 A100/GA100；`FIELD-COMP-UNIT-COUNT`、`FIELD-COMP-CONTROL-SCHEDULING` | 每个 SM 有 4 个 warp scheduler；SM 将 warp 静态分配给 scheduler；每次 issue 时，每个 scheduler 至多从其已分配且 ready 的 warp 中发出一条指令。这里仍是公开架构语义，不能据此推断 dual-issue、仲裁优先级、scoreboard 或 scheduler RTL。 |
| CUDA-CC80-01 | CUDA C++ Programming Guide v11.2.1，§2.5 `Compute Capability` | 直接解释 Compute Capability 是硬件能力版本，并明确不能与 CUDA software version 混淆 | GA100/A100 软件绑定；`FIELD-SW-PROGRAMMING-MODEL` | 该段把 Ampere 归入 major revision 8，但不单独证明 A100 是 8.0；A100=8.0 由 Ampere Tuning Guide 和白皮书补齐。 |
| CUDA-CC80-02 | Ampere Tuning Guide v11.2.1，§1.4.1.1 `Occupancy`，HTML lines 75-80 | 直接把 `compute capability 8.0` 括注为 A100 GPUs | A100/GA100 软件可见配置；`FIELD-SW-PROGRAMMING-MODEL`、`FIELD-COMP-UTILIZATION-LIMIT` | 支持 A100↔CC 8.0 映射，不应扩成所有 Ampere 均为 8.0。 |
| CUDA-RES-01 | Ampere Tuning Guide v11.2.1，§1.4.1.1，HTML lines 75-80；CUDA C++ Programming Guide v11.2.1，§I.7.3 `Shared Memory`，HTML lines 11698-11700 | A100/CC 8.0 直接规格 | A100-enabled GA100 SM；`FIELD-COMP-SHARED-RESOURCE`、`FIELD-COMP-UTILIZATION-LIMIT`、`FIELD-MEM-CAPACITY` | 最大 64 concurrent warps/SM、64K 个 32-bit register/SM、255 register/thread、32 block/SM、164 KB shared/SM、163 KB shared/block。单 block 使用超过 48 KB 时需要 dynamic shared memory 和显式 opt-in；每个 SM 有 1 KB 留给系统，不能分配给 block。这里是软件可见/occupancy 上限，不是可持续利用率。 |
| CUDA-RES-02 | Ampere Tuning Guide v11.0.3，§1.4.1.1，HTML lines 73-78；Ampere Tuning Guide v11.2.1 同节 lines 75-80；CUDA C++ Programming Guide v11.2.1，§I.7.3，HTML lines 11698-11700 | 同一家族修订加独立官方文档交叉核验 | A100/CC 8.0；`FIELD-MEM-CAPACITY`、冲突记录 | v11.0.3 写 160 KB shared/block；v11.2.1 Tuning Guide 与 Programming Guide 都写 163 KB，后者说明另外 1 KB 保留给系统。正式事实宜采用后续修订的 163 KB，并把 160 KB 标 `superseded`，不能把两者当作两种硬件配置。 |

资源上限不应全部挂到 GA100 object。64K×32-bit register file 和 shared-memory 容量属于 SM 或 memory component；warps/SM、blocks/SM 和 registers/thread 更适合放入 `FIELD-COMP-UTILIZATION-LIMIT` 或 `FIELD-COMP-SHARED-RESOURCE` 的结构化说明。现有字段没有单独的 warp-size 和 occupancy-limit 数值字段，不能为了保存数字而误用 `FIELD-COMP-ISSUE-WIDTH`。

## Async copy、barrier 与 L2 residency

| 编号 | 版本、章节和定位 | 原文支持层级 | 主体与候选字段 | 软件版本、限制和裁决 |
|---|---|---|---|---|
| CUDA-ASYNC-01 | Ampere Tuning Guide v11.0.3，§1.4.1.2；HTML lines 81-83 | Ampere 架构的直接厂商说明 | Ampere/GA100 SM；`FIELD-MEM-DMA`、`FIELD-COMP-DATAFLOW-RESIDENCY`、`FIELD-CAP-IMPLEMENTATION-LEVEL`、`FIELD-CAP-IMPLEMENTATION-DETAIL` | hardware-accelerated global-to-shared copy，可与计算重叠、避免额外 register，并可绕过 L1。方向固定为 global→shared；“可绕过”不是所有 copy 都 bypass L1。 |
| CUDA-ASYNC-02 | CUDA C++ Programming Guide v11.0，§B.24 `Asynchronously Copy Data from Global to Shared Memory`，PDF pp.213-225 / 印刷 pp.196-208 | CUDA API 的直接版本和行为说明 | A100/CC 8.0 软件绑定；`FIELD-SW-PROGRAMMING-MODEL`、`FIELD-SW-SUPPORT-MATURITY`、`FIELD-CAP-LIMITATION` | CUDA 11.0 引入；该版本明确标 experimental；hardware acceleration 需要 CC 8.0+。低于 8.0 会 fallback，不能把 API 存在等同于硬件执行。 |
| CUDA-ASYNC-03 | 同一文档 §B.24.1.2、§B.24.3.1，PDF pp.215-223 / 印刷 pp.198-206 | 直接说明 codegen 和数据竞争条件 | GA100/CC 8.0；同上 | 满足条件时成为 single instruction、避免 intermediate register；source 必须在 global、destination 必须在 shared，size/alignment 受 4/8/16-byte 条件约束，使用前必须 wait。它不是任意方向 memcpy，也不是公开的通用 DMA engine。 |
| CUDA-ASYNC-04 | PTX ISA 7.0，§9.7.8.16 `Asynchronous copy`，HTML lines 7472-7587 | PTX 虚拟 ISA 指令的直接说明 | `sm_80`；`FIELD-MEM-DMA`、`FIELD-CAP-IMPLEMENTATION-LEVEL=dedicated_instruction`、`FIELD-CAP-IMPLEMENTATION-DETAIL` | `cp.async` 在 PTX 7.0 引入，要求 `sm_80+`。`.ca`/`.cg` 是 cache hint；`.cg` 只在 L2 缓存。指令语义不证明 native opcode 编码、copy engine 数量或持续带宽。 |
| CUDA-BAR-01 | Ampere Tuning Guide v11.0.3，§1.4.1.3；HTML lines 84-85 | Ampere 架构的直接厂商说明 | Ampere/GA100 SM；`FIELD-COMP-CONTROL-SCHEDULING`、capability implementation fields | shared-memory split arrive/wait barrier 有硬件加速，可配合 async copy。只支持 block/shared-memory 范围的公开语义，不是跨 GPU barrier。 |
| CUDA-BAR-02 | CUDA C++ Programming Guide v11.0，§B.23，PDF pp.203-213 / 印刷 pp.186-196 | CUDA API 的直接版本说明 | A100/CC 8.0 软件绑定；`FIELD-SW-PROGRAMMING-MODEL`、`FIELD-SW-SUPPORT-MATURITY` | 文档明确写 CUDA 11 introduces；CC 8.0+ 有 barrier 与 async-copy integration 的硬件加速，CC 7.x 是无该硬件加速的可用实现。 |
| CUDA-BAR-03 | PTX ISA 7.0，§9.7.12.11 `mbarrier`，HTML lines 9230-9604 | PTX 虚拟 ISA 指令和 shared-memory object 的直接说明 | `sm_80`；`FIELD-COMP-CONTROL-SCHEDULING`、capability implementation fields | `mbarrier` 在 PTX 7.0 引入并要求 `sm_80+`；对象是 shared-memory 中的 64-bit opaque state。公开状态语义不等于硬件 barrier storage 的物理实现。 |
| CUDA-L2-01 | CUDA C++ Programming Guide v11.0，§3.2.3 `Device Memory L2 Access Management`，PDF pp.40-45 / 印刷 pp.23-28 | CUDA Runtime API 的直接版本和限制说明 | A100/CC 8.0 L2；`FIELD-MEM-MANAGEMENT`、`FIELD-CAP-LIMITATION`、`FIELD-SW-PROGRAMMING-MODEL` | CUDA 11.0 起，CC 8.0+ 可影响 L2 persistence；支持 set-aside、access-policy window 和 per-access property。只说明优先驻留控制，不保证命中、延迟或带宽。 |
| CUDA-L2-02 | 同一文档 §3.2.3.1，PDF p.40 / 印刷 p.23 | 直接限制 | A100 MIG/MPS 条件；`FIELD-CAP-LIMITATION`、`FIELD-VIRT-PARTITIONING` | MIG mode 下 L2 set-aside disabled；MPS 下不能由 `cudaDeviceSetLimit` 动态修改，只能在 MPS server 启动时指定。条件必须跟随事实。 |

L2 access-policy window 是软件控制的地址范围，不应登记成 `FIELD-MEM-GRANULARITY` 的固定物理粒度。白皮书给出的 A100 1/16、2.5 MB 增量可以作为 A100 配置的产品化限制，但 CUDA Programming Guide 本身只给 API 属性和上限查询方式。

## Structured sparse MMA 和 metadata

PTX ISA 7.2 是本轮对稀疏接口最精确的一手资料。相关章节是 §9.7.13.5 `Matrix multiply-accumulate operation using mma.sp instruction with sparse matrix A`，尤其是 §9.7.13.5.1、§9.7.13.5.2 和指令的 Target ISA Notes；revision history 位于 §12.2。

| 编号 | PTX 直接支持内容 | 候选字段 | 对象与条件 | 不能升级的结论 |
|---|---|---|---|---|
| CUDA-SP-01 | `mma.sp` 是 warp-level sparse matrix A MMA；A 以 50% non-zero 的压缩形式传入，位置由显式 metadata 给出 | `FIELD-CAP-IMPLEMENTATION-LEVEL=dedicated_instruction`、`FIELD-CAP-IMPLEMENTATION-DETAIL`、`FIELD-NUM-SPARSITY` | `sm_80+`、matrix A sparse、warp scope | 不证明 Tensor Core 物理阵列形状、selector RTL、物理乘法器数量或实际 2× speedup。 |
| CUDA-SP-02 | FP16/BF16 的 `.m16n8k16/.m16n8k32` 采用 2:4；每个四元素 chunk 保存两个非零项及两个 2-bit index | `FIELD-NUM-SPARSITY`、`FIELD-COMP-INSTRUCTION-TILE`、`FIELD-CAP-LIMITATION` | FP16/BF16 sparse A；shape-specific | metadata operand 的 thread/register layout 是 ISA 映射，不是独立 metadata SRAM 或硬连线选择器的公开证据。 |
| CUDA-SP-03 | TF32 稀疏 A 的粒度为 1:2；每个二元素 chunk 保存一个非零项和 4-bit index | 同上 | TF32；`.m16n8k8/.m16n8k16` | 不应为了与高层白皮书“2:4”统一而改写成 2:4；两者的逻辑 50% 稀疏相同，但物理原子和 metadata 编码不同。 |
| CUDA-SP-04 | INT8 使用 2:4，metadata 以两个 2-bit index 指示四元素 chunk 中两个非零位置 | 同上 | `.u8/.s8`，shape-specific | 只支持 PTX 列出的形状、类型和 selector 值；其他组合不能类推。 |
| CUDA-SP-05 | INT4 使用 pair-wise 4:8：八元素 chunk 由四个二元素 pair 组成，保留两个全非零 pair，metadata 指示 pair 位置 | 同上 | `.u4/.s4`、pair atom | 这是以二元素 pair 为原子的结构化稀疏，不是任意四个非零分布，也不能简化成普通 4:8。 |
| CUDA-SP-06 | `mma.sp.sync.aligned` 在 PTX ISA 7.1 引入，target 要求 `sm_80+`；同一 warp 的线程必须使用一致 instruction/qualifier，否则行为未定义 | `FIELD-SW-PROGRAMMING-MODEL`、`FIELD-SW-SUPPORT-MATURITY`、`FIELD-CAP-LIMITATION` | PTX 7.1 / CUDA 11.1 / driver r455 起的 PTX 接口 | 只能说明直接 PTX 接口从 CUDA 11.1 文档化。不能据此断言 CUDA 11.0 完全没有库级或其他软件路径。 |

白皮书 Figure 12 的 `Select` 仍是硬件数据流证据；PTX 则补足了 programmer-visible metadata operand、selector 和 shape/type 约束。两者互补。PTX 不能把白皮书未公开的 physical selector、metadata decoder、pipeline latency 或 real silicon throughput 补出来。

## CUDA 8.0、CUDA 11 与支持成熟度

| 问题 | 官方文档证据 | 本轮裁决 |
|---|---|---|
| ISSCC 的 `supported in CUDA 8.0` | CUDA C++ Programming Guide v11.0 §B.23 明确写 CUDA 11 introduces split barrier；§B.24 明确写 CUDA 11.0 introduces async-copy；PTX 7.0 revision history 把 `sm_80`、`cp.async`、`mbarrier` 映射到 CUDA 11.0 | 不采纳 `CUDA 8.0`。正式冲突记录应标“出版论文与 NVIDIA 开发文档不一致”；可注明疑似把 Compute Capability 8.0 写成 CUDA 8.0，但这是推断。 |
| 硬件版本 | Ampere Tuning Guide v11.2.1 把 CC 8.0 括注为 A100 GPUs；白皮书 Table 5 也将 A100/GA100 codename 与 CC 8.0 并列 | `Compute Capability 8.0 / sm_80` 是硬件 target，不是 CUDA 软件版本。 |
| async-copy 首发成熟度 | CUDA C++ Programming Guide v11.0 明确标 experimental，并使用 `nvcuda::experimental::pipeline` | 2020 发布期只能写 `documented_supported` 且附 `experimental in CUDA 11.0`；不能写 runnable verified。 |
| 11.x 后续接口 | v11.2.1 revision notes 更新 asynchronous copies 与 asynchronous barrier，正文使用 `cuda::pipeline`、`cuda::barrier`、`cuda::memcpy_async` | 可记录同一家族内的软件接口演进。它证明文档和 API 延续，不等于本轮已做运行测试或性能基准。 |
| sparse PTX 接口 | PTX 7.1 / CUDA 11.1 新增 `.sp` modifier，要求 `sm_80+` | 稀疏硬件存在与直接 PTX 接口版本拆开：硬件由白皮书/ISSCC 支持，PTX interface 从 CUDA 11.1 文档化。 |

候选 `FIELD-SW-SUPPORT-MATURITY` 应使用 `documented_supported`。理由是三套材料都是 NVIDIA 正式开发文档，给出 API、PTX target 和编程限制；本轮没有实际编译、运行、性能测量或公开 benchmark 复核。`vendor_claimed` 会低估开发文档的证据层级，`runnable_verified` 和 `benchmarked` 则超出证据。

## 候选事实与字段映射

| 候选事实 | 候选 `field_id` | 建议主体 | 证据层级 | 必须保存的条件 |
|---|---|---|---|---|
| GA100/A100 对外执行模型为 SIMT，warp 是公开调度粒度 | `FIELD-COMP-EXECUTION`、`FIELD-COMP-CONTROL-SCHEDULING` | GA100 SM component，或 Ampere architecture 经关系复用 | PTX generic direct + A100/CC8 绑定推断 + Figure 7 物理佐证 | `CUDA/PTX programming model`；不要写仲裁算法 |
| A100 CC8.0 occupancy/resource limits | `FIELD-COMP-SHARED-RESOURCE`、`FIELD-COMP-UTILIZATION-LIMIT`、`FIELD-MEM-CAPACITY` | A100-enabled GA100 SM/component | direct official spec | `compute_capability=8.0`、per-SM/per-thread/per-block 作用域；shared/block 采用 163 KB 后续修订 |
| global→shared hardware-accelerated async copy | `FIELD-MEM-DMA`、`FIELD-COMP-DATAFLOW-RESIDENCY`、capability implementation fields | Ampere/GA100 SM | direct architecture + PTX instruction | CUDA 11.0、PTX 7.0、`sm_80+`、global→shared、4/8/16-byte and alignment、wait/visibility rules |
| split arrive/wait barrier 与 async-copy integration | `FIELD-COMP-CONTROL-SCHEDULING`、capability implementation fields | Ampere/GA100 SM | direct architecture + PTX instruction | CUDA 11.0、PTX 7.0、`sm_80+`、shared-memory/block scope |
| L2 persistence set-aside 和 access-policy window | `FIELD-MEM-MANAGEMENT`、`FIELD-CAP-LIMITATION` | A100 L2 component | direct API documentation | CUDA 11.0、CC8.0+、MIG disabled、MPS startup-only size control |
| structured sparse `mma.sp` 与 metadata | `FIELD-NUM-SPARSITY`、`FIELD-COMP-INSTRUCTION-TILE`、capability implementation fields | Ampere/GA100 precision paths | direct PTX ISA | PTX 7.1 / CUDA 11.1、`sm_80+`、datatype/shape-specific 2:4、1:2、pair-wise 4:8、warp-uniform requirement |
| CUDA/PTX 文档支持成熟度 | `FIELD-SW-PROGRAMMING-MODEL`、`FIELD-SW-SUPPORT-MATURITY` | GA100 object software binding | direct official developer documentation | `documented_supported`；async-copy at CUDA 11.0 additionally `experimental`；无 runnable/benchmark evidence |

## 来源家族去重和最小集反向移除

本轮三类文档各自内部按 revision series 去重。Ampere Tuning Guide 11.0.3/11.2.1 只算一个来源家族，CUDA C++ Programming Guide 11.0/11.2.1 只算一个来源家族，PTX ISA 7.0/7.2 也只算一个来源家族。引用后续修订中的 revision history，不会把同一家族变成独立交叉证据。

在 GA100 最终接受事实包含本轮软件和 ISA 细节的前提下，建议把 CUDA C++ Programming Guide 与 PTX ISA 两个家族纳入反向移除测试：

| 来源家族 | 移除后的缺口 | 初步判定 |
|---|---|---|
| CUDA C++ Programming Guide 11.x | 丢失 `CUDA 11.0 introduces`、experimental 状态、API fallback/alignment/race 条件、L2 set-aside 的 MIG/MPS 限制，以及 CUDA version 与 Compute Capability 的明确区分 | 若这些事实被接受，不能移除，建议角色 `software_version_evidence` / `architecture_mechanism` |
| PTX ISA 7.x | 丢失 `cp.async`/`mbarrier` 的 PTX 7.0 与 `sm_80` target、`mma.sp` 的 PTX 7.1/CUDA 11.1 起点、datatype-specific sparse granularity 和 metadata layout | 若 sparse metadata 或 direct-instruction level 被接受，不能移除，建议角色 `api_or_isa_documentation` / `architecture_mechanism` |
| Ampere Tuning Guide 11.x | 白皮书、CUDA PG 和 PTX 已覆盖大多数接受事实；独有价值主要是 A100=CC8.0 的简洁映射、CC8.0/8.6 资源对照以及 160→163 KB 的官方修订链 | 默认先标 `redundant_covered`；只有总控决定保留 shared/block 版本冲突或需要独立的 A100↔CC8.0 绑定时再入选 |

如果 GA100 资料卡只保留白皮书已覆盖的高层机制，不收录 API 版本、PTX instruction、metadata 和软件限制，那么三类 CUDA 文档都可能被白皮书反向覆盖，不应仅因“官方开发文档”身份自动进入最小集。反之，只要接受 `mma.sp` metadata、CUDA 11.0 experimental 或 MIG 下 L2 set-aside disabled，白皮书就不能完整替代对应文档家族。

## 尚未核实和不应扩大之处

本轮没有做 runnable test、SASS 反汇编、microbenchmark 或驱动兼容性验证，因此不能判断 PTX 指令是否在所有 CUDA 11.x minor release、所有驱动组合和所有 A100 SKU 上以相同性能执行。公开 ISA 也没有给出 native opcode、Tensor Core physical array、sparse selector RTL、metadata decoder 面积、`cp.async` engine 数量、queue depth、持续带宽或延迟。

CUDA 11.2.1 的接口演进说明了持续文档支持，但没有给出“experimental”标签从哪一个精确 minor release 移除的单独声明。本卡只记录可观察到的 namespace/API 迁移，不把它解释成某个日期完成生产级认证。

L2 residency control 只影响 cache persistence policy。它不能自动升级为芯片绑定的 KV Cache manager，也不能用来推导特定模型的 KV 容量、迁移量或命中率。`cp.async` 同样只是 global→shared 数据搬运指令，不能据此写成 Attention 专用搬运引擎、MoE dispatch 或任意 tensor DMA。

## 验证和写入文件

本轮逐项复核了三套 NVIDIA 归档文档的版本入口、章节、target ISA notes 和 revision history，并把数字与 `r1_ga100_03_core_source_reading.md`、`r1_ga100_04_isscc_source_reading.md` 交叉核对。关键版本链为：PTX 7.0 / CUDA 11.0 / driver r445 / `sm_80`；PTX 7.1 / CUDA 11.1 / driver r455 / `mma.sp`；PTX 7.2 / CUDA 11.2 / driver r460。

本子任务新增：

- `审计/子代理交接/r1_ga100_05_cuda_official_docs_reading.md`

没有建立 `_assets/`，因为没有保存网页摘录或下载文件。没有修改 `数据/`、`最小参考资料库/`、`资料卡/` 或 `进度/` 中的任何正式文件。
