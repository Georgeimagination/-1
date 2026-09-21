# GA100 核心一手来源阅读卡

> 子任务：`r1_ga100_03_core_source_reading`  
> 状态：完成，待总控复核  
> 阅读对象：NVIDIA GA100 die、NVIDIA Ampere architecture，以及白皮书中与二者相邻但必须隔离的 A100 GPU、SXM4 模组和 DGX A100 系统表述  
> 资料截止：2026-08-21  
> 写入边界：只新增本交接文件和视觉核验辅助文件；未修改正式 CSV、资料卡、来源记录或进度文件

## 来源身份和核验范围

本轮使用正式资料池中的规范主副本：

- 来源标识：`SRC-M2NA-NVIDIA-AMPERE-WP-2020`
- 标题：*NVIDIA A100 Tensor Core GPU Architecture*
- 作者：NVIDIA
- 固定版 PDF：`论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf`
- SHA-256：`3a800ad7668ec37037fa5870a8e3bb681b75f19668b3d11492ab9b0da0d58815`
- 页数：82
- PDF 元数据创建时间：2020-08-26；正式 `sources.csv` 的 `publication_date` 当前为空，不能用创建时间静默代替发布日期

哈希、页数和本地路径与 `论文PDF清单.csv`、`source-endpoints.csv` 一致。没有使用 `审计/子代理交接/.../rehearsal/` 下的任何镜像作为证据，也没有联网或下载资料。

阅读先覆盖全文目录和正文，再集中精读印刷页 11-68。表格、框图、图注和脚注已渲染核对，重点包括 Figure 5-7、Table 1-5、Figure 9、Figure 12-17、Figure 21-26、Table 6-9、Figure 28-35。本文中的页码是 PDF 页码，也是页面上印刷的页码。文本抽取只用于检索，没有把抽取结果当成表格或框图的最终依据。

## 对象边界

这份白皮书把四种对象写在同一篇文档里，不能按标题中的 A100 一概下放到 GA100 die。

| 层级 | 本轮判定 | 典型表述 | 对 GA100 工作包的用法 |
|---|---|---|---|
| Ampere architecture | 架构代际 | 第三代 Tensor Core、Sparse MMA、asynchronous copy/barrier、L2 residency control、第三代 NVLink 的协议机制 | 已有架构卡承接，GA100 通过 `implements_architecture` 关系复用；但本白皮书只直接展开数据中心 GA100/A100，不能据此断言所有 Ampere 实现具有完全相同的 SM 数量、缓存容量或 Compute Capability |
| GA100 die | 裸片 | TSMC N7、54.2B 晶体管、826 mm²、full GA100 的 GPC/TPC/SM 组织、Figure 6/7、GA100 Optical Flow Accelerator | 可直接支撑 GA100，但要区分“full implementation”物理设计上限和 A100 启用配置 |
| A100 GPU | GA100 的具体启用实现/产品语境 | 108 SM、432 Tensor Cores、40 MB L2、12 NVLink、Compute Capability 8.0、MIG 7 个 GPU slice | 只在原文明确同指 GA100 硬件时作为候选；启用数量、频率、吞吐、TDP 和 MIG 配置不能自动改写成 full GA100 die 属性 |
| A100 SXM4 模组或板级配置 | 模组/产品 SKU | 40 GB HBM2、5 个 active HBM2 stack、1215 MHz、1555 GB/s、SXM4、400 W | 不写入 GA100 die；只能保留关系或作为后续 A100 模组卡证据 |
| DGX A100、HGX A100、NVSwitch、InfiniBand 系统 | 系统 | 8-GPU DGX 拓扑、系统扩展、Magnum IO、Mellanox 网络 | 不写入 GA100 die；只作上层关系背景 |

最容易出错的是白皮书交替使用 “GA100 GPU”“A100 GPU”“A100 Tensor Core GPU implementation of GA100”。下文只有原句把主语落到 GA100，或者图表标题明确写 `GA100` 时，才判为可直接支撑。产品数值即使物理上很可能由同一裸片提供，也先保留为 A100 作用域，等待第二来源确认。

## 物理实现和计算组织

| 编号 | 原文主张与精确定位 | 对象作用域 | 可对应字段和条件 | GA100 使用判定与风险 |
|---|---|---|---|---|
| PHY-01 | “GA100 GPU that powers A100” 采用 TSMC 7 nm N7，54.2 billion transistors，die size 826 mm²。PDF p.14，`A100 GPU Key Features Summary`；Table 4 在 pp.36-37 再列出 54.2B、826 mm²、7 nm N7。 | GA100 die | `FIELD-PHY-FOUNDRY`、`FIELD-PHY-PROCESS`、`FIELD-PHY-TRANSISTORS`、`FIELD-PHY-DIE-AREA`；`COND-NONE` | 可直接支撑 GA100。Table 4 的列名是 NVIDIA A100，宜以 p.14 的明确 GA100 主语为主，Table 4 只作同源复核。 |
| PHY-02 | full GA100 包含 8 GPC、每 GPC 8 TPC、每 TPC 2 SM、每 GPC 16 SM、全 GPU 128 SM。PDF p.19，`The full implementation of the GA100 GPU`；Figure 6，p.20。 | full GA100 die | `FIELD-COMP-UNIT-COUNT`；条件必须写 `full_implementation / physical_design`，不能用 A100 enabled SKU 条件 | 可直接支撑 full GA100。`128 SM` 不是 A100 产品启用数。 |
| PHY-03 | full GA100 每 SM 64 个 FP32 CUDA Core，合计 8192；每 SM 4 个第三代 Tensor Core，合计 512。PDF p.19。 | full GA100 die | `FIELD-COMP-UNIT-COUNT`；分别建立 FP32 component、Tensor Core component，条件为 full implementation | 可直接支撑。总数和每 SM 数应拆成原子事实。 |
| PHY-04 | full GA100 列出 6 个 HBM2 stack 和 12 个 512-bit memory controller。PDF p.19；Figure 6，p.20。 | 混合了 GA100 die 接口与封装 HBM | memory controller 可用 `FIELD-COMP-UNIT-COUNT`；每控制器宽度缺少专门字段时保留原文；HBM stack 对应 `FIELD-PHY-HBM-STACKS` 但主体应是封装/模组 | `12 × 512-bit memory controllers` 可作为 GA100 die 的控制器候选；6 个 HBM2 stack 是与 full implementation 配套的封装结构，不能挂到 die。不得无条件派生 6144-bit 总接口。 |
| PHY-05 | A100 implementation of GA100 为 7 GPC、每 GPC 7 或 8 TPC、108 SM、6912 FP32 Core、432 Tensor Core、5 HBM2 stack、10 个 512-bit memory controller。PDF p.19。 | A100 具体启用实现 | 产品组件计数和 HBM 配置 | 不能下放为 full GA100 die。它能证明同一 GA100 设计存在禁用/裁剪配置，正好构成对象分层证据。 |
| PHY-06 | Figure 6 的 full GA100 框图显示 PCI Express 4.0 host interface、GigaThread Engine with MIG Control、成对 L2 cache、12 个 NVLink 标签以及 6 组 HBM2/memory-controller 连接。PDF p.20，Figure 6。 | full GA100 die schematic | `FIELD-INT-PROTOCOL`、link/component 候选 | 图可以证明结构存在和物理接口数量，但不单独证明带宽、协议有效载荷或所有单元在 A100 SKU 中启用。 |
| PHY-07 | Table 4 给出 A100 SXM4、1410 MHz boost、40 GB HBM2、5120-bit interface、1215 MHz DDR、1555 GB/s、400 W。PDF pp.36-37，Table 4，脚注 1 指明 peak rates 基于 GPU Boost Clock。 | A100 SXM4 产品/模组 | `FIELD-PHY-FORM-FACTOR`、`FIELD-PHY-CLOCK`、`FIELD-PHY-POWER`、HBM fields；条件为 A100 SXM4、boost clock | 不直接支撑 GA100 die。尤其不能把 400 W 当裸片功耗，也不能把 5120-bit 当 full GA100 的总物理接口。 |
| COMP-01 | Figure 7 展示 GA100 SM：4 个 processing block；每块含 L0 instruction cache、warp scheduler 32 thread/clk、dispatch unit 32 thread/clk、16,384×32-bit register file、INT32/FP32/FP64 执行资源、1 Tensor Core、LD/ST 和 SFU；SM 顶层有 L1 instruction cache，底部有 192 KB L1 data cache/shared memory。PDF p.22，Figure 7。 | GA100 SM | `FIELD-COMP-UNIT-NAME`、`FIELD-COMP-UNIT-COUNT`、`FIELD-COMP-ISSUE-WIDTH`、`FIELD-COMP-CONTROL-SCHEDULING`、`FIELD-COMP-SHARED-RESOURCE`、`FIELD-MEM-CAPACITY` | 可直接支撑 GA100 SM。图中重复小方块不应未经正文确认就逐格计为独立物理 ALU；可安全采用的数量是图明示的 4 个 processing block、4 个 Tensor Core、4 个 scheduler/dispatch 和 4 组 register file。 |
| COMP-02 | 每个第三代 Tensor Core 每周期执行 256 个 FP16/FP32 FMA；每 SM 4 个 Tensor Core，共 1024 dense FP16/FP32 FMA/clock。PDF p.20，`A100 SM Architecture`。 | A100/GA100 SM | `FIELD-COMP-THROUGHPUT`，precision path 为 FP16 inputs/FP32 accumulation，basis=`theoretical_peak`，scope=`per_SM_per_clock`，dense | 机制直接落在 GA100 SM 图和 A100 SM 正文，可作为 GA100 候选。不能把 1024 FMA/clk 静默写成 2048 FLOP/clk，除非另记一次 FMA=2 FLOP 的计数规则。 |
| COMP-03 | A100 SM 有独立 FP32 和 INT32 core，可同时以 full throughput 执行 FP32 和 INT32；正文举例是浮点计算与地址计算重叠。PDF p.34，`Simultaneous Execution of FP32 and INT32 Operations`。 | A100/GA100 SM | `FIELD-COMP-CONCURRENCY`、`FIELD-COMP-DATAFLOW-RESIDENCY` | 可作为 GA100 机制候选，但“full throughput”没有给出并发时的频率、功耗或与 Tensor Core 的关系，不能扩成所有路径可同时达峰。 |
| COMP-04 | Compute Capability 8.0：32 threads/warp，64 warps/SM，2048 threads/SM，32 blocks/SM，65536 个 32-bit register/SM，max 255 register/thread，block 最大 1024 threads，shared memory configurable up to 164 KB。PDF p.43，Table 5。 | A100/GA100 的 CUDA 暴露配置 | 多个 compute/resource fields；条件 `compute_capability=8.0` | 表列名是 A100、codename 是 GA100。适合 GA100 的软件可见资源上限，但不应提升为所有 Ampere GPU 的统一架构事实。 |
| COMP-05 | 对 16×16×16 matrix multiply，A100 16×8×16 Tensor Core warp-level instruction 相比 V100 提高 thread sharing；Figure 14 列出 A100 TC instruction 覆盖 2048 MAC、8 cycles，整个 16×16×16 例子需要 2 条 lower-level hardware instruction、28 次 warp register read+write、16 cycles。PDF pp.38-39，Figure 14 及图注。 | A100 Tensor Core 的示例映射 | `FIELD-COMP-INSTRUCTION-TILE`、`FIELD-COMP-DATAFLOW-RESIDENCY`、`FIELD-COMP-UTILIZATION-LIMIT`；条件必须包含示例矩阵大小和 warp scope | 可支撑数据共享和寄存器访问优化。`16×8×16` 是 warp-level 指令 Tile，不是物理阵列形状；Figure 14 的周期和访问次数绑定该示例，不能概化为所有 MMA。 |
| COMP-06 | Figure 7 的 warp/thread 组织能证明按 warp 调度，但白皮书没有在相关正文中明确使用 `SIMT` 一词。 | GA100 SM | `FIELD-COMP-EXECUTION` | 当前架构卡把它规范化为 SIMT 可以理解，但若要求“原文直接陈述”，本来源只能支撑 warp scheduler、threads 和 SM 组织；SIMT 分类最好补 CUDA Programming Guide 或正式 ISA。 |

## 数值路径和稀疏机制

| 编号 | 原文主张与精确定位 | 对象作用域 | 可对应字段和条件 | GA100 使用判定与风险 |
|---|---|---|---|---|
| NUM-01 | Table 3 列出 A100 Tensor Core 的 input operand 与 accumulator：TF32→FP32，FP16→FP32，BF16→FP32，FP16→FP16，INT8→INT32，INT4→INT32，Binary→INT32，IEEE FP64→FP64。PDF p.27，Table 3。 | A100 Tensor Core/GA100 precision paths | `FIELD-NUM-OPERAND-A/B`、`FIELD-NUM-ACCUMULATION`；每种路径拆记录 | 这是本来源中比 pp.20-21 的格式列表更强的精度路径证据。表给的是程序员可见 accumulator，不证明物理内部累加位宽、乘积编码、舍入或 subnormal 处理。 |
| NUM-02 | TF32 接收 FP32 数据，内部使用 8-bit exponent、10-bit mantissa、1 sign bit，输出标准 IEEE FP32；non-tensor operation 继续走 FP32 datapath。PDF p.26；Figure 9，p.27。 | A100 Tensor Core 数值语义 | `FIELD-NUM-CONVERSION`、`FIELD-NUM-OPERAND-A/B`、`FIELD-NUM-ACCUMULATION`、`FIELD-NUM-OUTPUT` | 可通过 Ampere 关系复用到 GA100。不能把“same range as FP32”改写成完整 IEEE FP32 精度，也不能从图推断未写明的舍入模式。 |
| NUM-03 | BF16 是 8-bit exponent、7-bit mantissa、1 sign bit；FP16/BF16 mixed precision 的 accumulator 为 FP32。PDF pp.26-27。 | A100 Tensor Core | operand/accumulation fields | 可支撑 GA100 数值路径。现有架构卡没有 BF16 的 operand B 记录，后续结构化时应补齐成对操作数或明确同格式双输入。 |
| NUM-04 | FP64 Tensor Core 每 SM 共 64 FP64 FMA/clock，即 128 FP64 operations/clock；A100 108 SM 的聚合峰值为 19.5 TFLOPS。PDF p.28。 | 前半句为 A100/GA100 SM；后半句为 108-SM A100 产品 | `FIELD-COMP-THROUGHPUT`，scope 分别为 per SM 与 A100 GPU | per-SM 路径可作为 GA100 候选；19.5 TFLOPS 不能写给 full GA100 die。 |
| NUM-05 | 2:4 definition 是每四项向量允许两个非零值，A100 支持 row 方向的 2:4 structured sparsity。PDF p.31，`Sparse Matrix Definition`。 | A100 Sparse Tensor Core | `FIELD-NUM-SPARSITY`；条件需记录 2:4、row、50% structured | 可经 Ampere 关系复用到 GA100。不能把 2:4 解释成任意非结构化 50% sparsity。 |
| NUM-06 | Figure 12 显示离线 pruning/fine-tuning 后，稀疏权重以 non-zero data values 加 indices 压缩；Sparse Tensor Core 的 `Select` 按索引选择与非零权重对应的 input activations。PDF p.32，Figure 12。 | 稀疏训练流程 + 硬件数据路径 | `FIELD-NUM-SPARSITY`、`FIELD-MEM-COMPRESSION`、`FIELD-CAP-IMPLEMENTATION-DETAIL` | 关键边界：硬件不是在运行时从四个权重里“挑出两个该保留的非零值”。权重选择和 pruning 在软件流程中完成；硬件使用压缩值与 indices 对齐对应 dense activation。 |
| NUM-07 | Sparse MMA 跳过 zero-valued entries；示例中逻辑 16×16 sparse A 与 dense 16×8 B 相乘，从 N cycles 降到 N/2。PDF pp.32-33，Figure 13。 | A100 Sparse MMA 示例 | `FIELD-CAP-IMPLEMENTATION-LEVEL=dedicated_instruction`、`FIELD-CAP-IMPLEMENTATION-DETAIL`、`FIELD-COMP-THROUGHPUT`；条件为图示矩阵和 2:4 | 可支撑“Sparse MMA instruction/skip zero/2× effective throughput”。Figure 13 是示意，不足以注册物理 array shape，也不公开 metadata encoding、selector RTL 或每周期物理乘法器数量。 |
| NUM-08 | Table 1、Table 2、Table 3 的 312/624 TFLOPS、156/312 TFLOPS、624/1248 TOPS 等，脚注明确后一个值是使用 sparsity 的 effective TFLOPS/TOPS；峰值基于 GPU Boost Clock。PDF pp.15、23、27。 | 108-SM A100 产品 | `FIELD-COMP-THROUGHPUT`，必须标 `theoretical_peak`、dense/sparse effective、boost clock、A100 product | 不支撑 full GA100 die 总吞吐。Sparse 数值是等效吞吐，不代表物理 MAC 数量翻倍。 |

## 存储层次和数据搬运

| 编号 | 原文主张与精确定位 | 对象作用域 | 可对应字段和条件 | GA100 使用判定与风险 |
|---|---|---|---|---|
| MEM-01 | combined L1 data cache/shared memory 为 192 KB/SM；最大 shared memory allocation 为 164 KB。PDF p.21；pp.33-34；Table 4 pp.36-37；Figure 7 p.22。 | A100/GA100 SM | `FIELD-MEM-CAPACITY`、`FIELD-MEM-MANAGEMENT=mixed`、`FIELD-MEM-LOCALITY-SCOPE=core`；分别记录 combined physical capacity 和 configurable shared allocation | 可作为 GA100 SM 直接候选。192 KB 不能同时再当 192 KB L1 加 164 KB shared 求和。 |
| MEM-02 | Figure 7 每个 SM processing block 有 16,384×32-bit register file，合计 4 组；Table 4 列 register file size 256 KB/SM。PDF p.22，Figure 7；p.37，Table 4。 | GA100 SM | `FIELD-MEM-CAPACITY`、`FIELD-MEM-INSTANCE-COUNT`、scope=per SM | 图和表同源一致，可直接支撑 per-SM register file。Table 4 的 27,648 KB/GPU 是 108-SM A100 汇总，不能用于 full 128-SM GA100。 |
| MEM-03 | CUDA global/local memory 位于 HBM2 device memory；constant、texture、surface 也在 device memory 并由相应 cache 缓存；L2 缓存 HBM2 的读写。PDF p.34，`A100 HBM2 and L2 Cache Memory Architectures`。 | A100 memory hierarchy / CUDA view | `FIELD-MEM-MANAGEMENT`、`FIELD-MEM-CONSISTENCY`、`FIELD-MEM-NAME` | 可作为架构关系事实，但作用域是 CUDA 可见层次，不等于物理地址映射细节。MIG 模式下资源被分区，不能继续写成所有 application 无条件共享完整 L2/HBM。 |
| MEM-04 | A100 SXM4-style 配置有 40 GB HBM2、5 个 active stack、每 stack 8 个 memory die、1215 MHz DDR、1555 GB/s。PDF p.35。 | A100 SXM4/模组 | HBM capacity/interface/bandwidth fields；条件含 A100、SXM4、5 active stacks、DDR rate | 不写入 GA100 die。p.34 还说明 HBM stack 位于与 GPU 相同的 physical package，进一步表明它不是裸片内资源。 |
| MEM-05 | A100 L2 为 40 MB、在 GPC 外为 GPC/SM 共享资源；分为两个 partition，每 partition 40 个 512 KB slice，每 memory controller 关联 8 个 slice；A100 L2 read bandwidth 为 5120 Bytes/clk。PDF p.35。 | A100 具体实现 | `FIELD-MEM-CAPACITY`、`FIELD-MEM-INSTANCE-COUNT`、`FIELD-MEM-READ-TRANSFER-PER-CYCLE`、`FIELD-MEM-LOCALITY-SCOPE` | 结构很可能在 GA100 die 上，但正文主语是 A100。40 MB 和 5120 B/clk 进入 GA100 正式事实前宜由 ISSCC/另一份一手架构来源确认。不要凭 1410 MHz 将 5120 B/clk 换算为 byte/s；时钟域未说明。 |
| MEM-06 | hardware cache-coherence 在 full GPU 上保持 CUDA programming model。PDF p.35。 | A100 full-GPU memory system | `FIELD-MEM-CONSISTENCY` | 可记录为 A100/GA100 候选，但“full GPU”一致性与 MIG partition 隔离并不矛盾；二者是不同配置条件。来源没有公开具体 coherence protocol。 |
| MEM-07 | 新 asynchronous copy 从 global memory 直接到 shared memory，避开 register staging；BYPASS variant 避开 L1 和 RF，ACCESS variant 保留 L1 access/reuse。PDF p.21；Figure 15 p.40；pp.61-62，Figure 31。 | Ampere/GA100 SM 指令机制 | `FIELD-MEM-DMA`、`FIELD-CAP-IMPLEMENTATION-LEVEL=dedicated_instruction`、`FIELD-CAP-IMPLEMENTATION-DETAIL`、`FIELD-COMP-DATAFLOW-RESIDENCY` | 可通过架构关系复用。它是 global-to-shared 的特定 async copy，不应泛化为任意 DMA 或双向 copy engine。 |
| MEM-08 | asynchronous barrier 位于 shared memory，硬件加速；arrival 与 wait 分离，可让任意 CUDA thread subset 在 block 内同步，并与 async copy 重叠。PDF p.17；pp.63-64，Figure 33。 | Ampere/GA100 SM 控制机制 + CUDA 11 暴露 | `FIELD-COMP-CONTROL-SCHEDULING`、special capability、`FIELD-SW-PROGRAMMING-MODEL` | 可经架构关系复用。硬件能力与 CUDA 11 ISO C++ barrier object 是两个层次，需拆成机制事实和软件映射事实。 |
| MEM-09 | Compute Data Compression 面向 unstructured sparsity 和其他 compressible patterns，可“up to”节省 4× DRAM read/write bandwidth、4× L2 read bandwidth、2× L2 capacity。PDF p.35；p.41，Figure 17。 | A100/GA100 compression mechanism | `FIELD-MEM-COMPRESSION`、`FIELD-CAP-IMPLEMENTATION-LEVEL`、`FIELD-CAP-LIMITATION` | 可记录机制和厂商上限，但不能把 4×加到基础 1555 GB/s，不能当成所有数据的持续带宽，也不能与 2:4 Sparse MMA 混为同一机制。 |
| MEM-10 | CUDA 11/Compute Capability 8.0 可设置 L2 persistent region；A100 按 1/16、即 2.5 MB 增量 set-aside，支持 address-range window 和 per-memory-operation control；MIG 模式下 set-aside disabled。PDF pp.64-65。 | 架构机制 + 40 MB A100 配置 + CUDA 11 | `FIELD-MEM-MANAGEMENT`、`FIELD-MEM-GRANULARITY`、`FIELD-SW-PROGRAMMING-MODEL`；条件必须区分 MIG off/on | 机制可关系复用；2.5 MB 是 A100 40 MB L2 的产品化粒度。现有架构卡只写“residency controls”会丢失 MIG 禁用条件。 |

## 互联、虚拟化和调度

| 编号 | 原文主张与精确定位 | 对象作用域 | 可对应字段和条件 | GA100 使用判定与风险 |
|---|---|---|---|---|
| INT-01 | 第三代 NVLink 是 lossless、high-bandwidth、low-latency shared-memory interconnect，带 link-level error detection 和 packet replay。PDF p.52，`Third-Generation NVLink`。 | Ampere/A100 link mechanism，NVSwitch 也实现 | `FIELD-INT-PROTOCOL`、`FIELD-INT-REMOTE-MEMORY`、`FIELD-INT-FAULT`、`FIELD-RAS-ERROR-DETECTION`、`FIELD-RAS-CORRECTION-REPLAY` | 可经 Ampere/NVLink link 关系复用到 GA100。不要把 NVSwitch 的能力自动算作 die 内机制。 |
| INT-02 | 50 Gbit/s per signal pair；每方向 4 differential pair；单 link 每方向 25 GB/s；A100 12 links，整个 A100 600 GB/s total。PDF pp.16-17、52。 | A100 device link configuration | `FIELD-INT-PER-LINK-RATE`、`FIELD-INT-LANE-COUNT`、`FIELD-INT-LINK-COUNT`、`FIELD-INT-AGGREGATE-BW` | 25 GB/s 是 per-direction；600 GB/s 是 12×25×2 的双向聚合设备值。Figure 6 可支持 full GA100 有 12 个物理 link 接口，但 600 GB/s 仍应标 A100 device、bidirectional aggregate、vendor nameplate，不能写成单向注入。 |
| INT-03 | A100 通过 NVLink 访问 peer GPU memory；第三代 NVLink 的 write 改为 non-posted，由 requester 同步并把 error attribution 返回具体 execution context；remote GPU page fault 经 NVLink 返回 source GPU。PDF pp.52-54。 | A100/NVLink protocol behavior | `FIELD-INT-REMOTE-MEMORY`、`FIELD-INT-FAULT`、RAS fields | 可记录 link 机制。来源未给 remote-memory consistency model、原子范围、访问延迟或持续带宽。 |
| INT-04 | PCIe Gen 4 x16 每方向 31.5 GB/s；A100 支持 SR-IOV，VF/PF 可经 NVLink 访问 peer GPU。PDF pp.17、53。 | A100 device host interface | `FIELD-INT-PROTOCOL`、`FIELD-INT-INJECTION-BW` 或 per-link rate、`FIELD-VIRT-PARTITIONING` | Figure 6 证明 full GA100 有 PCIe 4.0 x16 host interface；31.5 GB/s 和 SR-IOV 是 A100 产品能力。不得把 x16 两方向相加写成 63 GB/s 单向带宽。 |
| INT-05 | DGX A100 的 8 个 A100 经 NVSwitch 连接，多个系统再通过 InfiniBand/Ethernet scale-out。PDF pp.52-53，Figure 26。 | DGX/system | system topology fields | 对 GA100 只作 deployed/connected relationship；不能把 DGX 拓扑、网络数量或系统聚合带宽下放。 |
| VIRT-01 | MIG 可把一个 A100 分为最多 7 个 GPU Instance；每个 instance 独占 SM 路径、on-chip crossbar port、L2 bank、memory controller 和 DRAM address bus，提供 QoS、fault isolation 和 error containment。PDF pp.16、45。 | A100 enabled configuration | `FIELD-VIRT-PARTITIONING`、`FIELD-VIRT-MULTI-TENANCY`、`FIELD-VIRT-PREEMPTION-QOS`、`FIELD-RAS-FAULT-ISOLATION` | 这是芯片绑定机制，但“最多 7 个”来自 7-GPC A100 配置，不应作为 full 8-GPC GA100 die 的物理分区数。QoS 是厂商声明，未给出定量界限。 |
| VIRT-02 | GPU slice 包含 1 Sys Pipe、1 GPC、1 个含 10 个 L2 slice 的 L2 slice group，以及一部分 frame buffer；A100 支持 7 个 GPU slice，MIG 时每 slice 启用 7 TPC/14 SM。PDF p.47。 | A100 MIG configuration | partitioning fields、component counts；条件 MIG mode | 不写成 full GA100 固有的 7-slice 上限。它同时证明 MIG 的 compute、cache、controller、memory partition 是配套的，不能只记 SM 切分。 |
| VIRT-03 | Sys Pipe 是 A100 GigaThread Engine 的一部分，负责与 host CPU 通信并向 GPC/SM 调度工作；A100 有 7 个 Sys Pipe，其中 1 个 graphics+compute、6 个 compute-only；MIG 仅支持 compute mode。PDF p.48。 | A100 control/scheduling implementation | `FIELD-COMP-CONTROL-SCHEDULING`、`FIELD-SW-CHIP-BOUND-SCHEDULING`、`FIELD-VIRT-PARTITIONING` | 可记录 A100/GA100 候选机制，数量和 graphics 约束绑定 A100 配置。 |
| VIRT-04 | Compute Instance 可在 GPU Instance 内继续拆分 compute resources；每个 Compute Instance 有一个 Sys Pipe，可独立 context switch；不同 Compute Instance 的 GPC 不再像旧 GPU 那样一起 context switch。PDF pp.49-51，Figure 24-25。 | A100 MIG control mechanism | `FIELD-COMP-CONTROL-SCHEDULING`、`FIELD-VIRT-PARTITIONING`、`FIELD-VIRT-PREEMPTION-QOS` | 可支撑独立上下文切换粒度。Figure 24 还说明同一 GPU Instance 内不同 Compute Instance 共享 L2/frame buffer，不能误写成完整 memory isolation。 |
| VIRT-05 | MIG migration 描述 vGPU state 保存并恢复到相同 GPU-slice 数的另一个 GPU Instance，可用于迁移、装箱和维护。PDF p.52。 | vGPU/MIG 软件与系统工作流 | `FIELD-RAS-RECOVERY` 或 `FIELD-SW-CHIP-BOUND-SCHEDULING` 的候选线索 | 本白皮书的描述不足以证明 GA100 芯片具有通用 checkpoint/restart，也没有软件版本、可用状态和限制。需要 vGPU/MIG 正式文档第二来源后再收录。 |

## 专用机制、RAS 和软件表述

| 编号 | 原文主张与精确定位 | 对象作用域 | 可对应字段和条件 | GA100 使用判定与风险 |
|---|---|---|---|---|
| SPEC-01 | A100 加入 5-core hardware JPEG decode engine `NVJPG`；支持 YUV420/422/444/400 和 RGBA。PDF p.54；Table 6 p.55。 | A100 product hardware | media capability，`dedicated_physical_module`、component count | 很可能位于 GA100，但正文主语是 A100。进入 GA100 正式事实前建议由 ISSCC 或芯片级 block diagram 交叉确认。 |
| SPEC-02 | NVJPG 在 1410 MHz、图像不小于约 1 Mpixel、10:1 compression ratio 时，4:2:0 为 7000 Mpixel/s、4:4:4 为 3335 Mpixel/s；224×224 小图可低 30%-40%。PDF pp.54-55，Table 6 及注。 | A100 vendor benchmark | `FIELD-CAP-THROUGHPUT`，完整 condition set | 不是 GA100 无条件吞吐；必须保留频率、图像尺寸、格式、压缩比和“小图下降”限制。 |
| SPEC-03 | “GA100 Optical Flow Accelerator” 是硬件模块，支持 optical flow 和 stereo disparity，质量/性能可由参数调节。PDF p.56。 | GA100 die | media capability，`dedicated_physical_module`、`FIELD-CAP-LIMITATION` | 可直接支撑 GA100。来源没有数量、接口、精度或吞吐，不能自行补齐。 |
| SPEC-04 | A100 有 5 个 NVDEC，支持 H264 8-bit 4:2:0、HEVC 8/10/12-bit 4:2:0/4:4:4、VP9 8/10/12-bit 4:2:0；Table 7 标题为 `GA100 HW decode support`。PDF pp.56-57，Table 7-9。 | A100 unit count；GA100 format support | media capability、component count、conditioned throughput | 格式支持可直接指向 GA100；5-unit 数量仍宜第二来源确认 full die 与 A100 enabled 配置是否相同。并发流性能绑定 1410 MHz 和分辨率/帧率，不是 GA100 裸片峰值。 |
| SPEC-05 | A100 相比 V100 的 global-memory atomic throughput：FP16 11×，FP32 2.7×。PDF p.56。 | A100 vendor relative result | `FIELD-COMP-THROUGHPUT` 或 benchmark，traffic basis=`relative_only` | 缺少绝对值、测试方法和并发条件，只能保留为 vendor relative claim，不应写成固定芯片吞吐。 |
| SPEC-06 | Table 4 注明 A100 不含 display connector、RT Core、NVENC encoder。PDF p.37。 | A100 product design | component absence / `not_applicable` 候选 | 可用于 A100 产品边界；是否能直接证明 full GA100 die 完全无对应物理模块，宜由 die-level 第二来源确认。 |
| RAS-01 | HBM2 subsystem 使用 SECDED ECC；L2、L1 和所有 SM register file 也受 SECDED ECC 保护。PDF p.35，`ECC Memory Resiliency`。 | A100 memory system | `FIELD-RAS-ECC`、`FIELD-RAS-PROTECTION-SCOPE` | L1/L2/RF 是 GA100 die 候选；HBM 保护属于 A100 HBM subsystem/封装路径。必须拆分覆盖范围，不能笼统写“全芯片全部状态 SECDED”。 |
| RAS-02 | A100 新技术改善 error/fault attribution、isolation、containment，重点面向 cluster 和 MIG；PDF pp.53-54 解释 attribution、isolation、containment 的含义。 | A100/MIG vendor architecture claim | `FIELD-RAS-CAPABILITY`、`FIELD-RAS-FAULT-ISOLATION`、`FIELD-RAS-PROTECTION-SCOPE` | 只能记录厂商声明的能力边界。除 ECC、NVLink detection/replay、remote page-fault return 外，来源没有给出具体 detector、recovery state machine、遥测或 BIST。 |
| RAS-03 | NVLink link-level error detection、packet replay、non-posted write 与 remote page-fault return。PDF pp.52-54。 | link mechanism | `FIELD-RAS-ERROR-DETECTION`、`FIELD-RAS-CORRECTION-REPLAY`、`FIELD-INT-FAULT` | 可直接记录为 NVLink link 机制，并经关系关联 GA100；不能扩大为计算错误重放或全局任务恢复。 |
| SW-01 | CUDA 11 提供第三代 Tensor Core、sparsity、CUDA Graphs、MIG、L2 residency control 等 API/编程支持。PDF p.58。 | Ampere/A100 software binding | `FIELD-SW-PROGRAMMING-MODEL`、`FIELD-SW-SUPPORT-MATURITY=documented_supported` | 这是第一方文档支持，不等于本轮已做 runnable verification 或 benchmark verification。 |
| SW-02 | CUDA Graph 本身在 CUDA 10 已引入；A100 新增 launch optimization 和 dependency tracking，对复杂 fork/join graph 降低 inter-kernel latency。PDF pp.58-61，Figure 28-30。 | CUDA software + A100 hardware optimization | `FIELD-COMP-CONTROL-SCHEDULING`、`FIELD-SW-CHIP-BOUND-SCHEDULING` | 只能把 A100 的依赖跟踪/launch 优化记为新硬件机制，不能写成“A100 发明 CUDA Graph”。图中 speedup 是特定短 kernel/graph topology 的条件化结果。 |
| SW-03 | CUDA 11 async copy API 暴露 hardware-accelerated direct global-to-shared copy；asynchronous barriers 以 ISO C++-conforming barrier object 暴露。PDF pp.61-64。 | 软件映射到硬件机制 | `FIELD-SW-PROGRAMMING-MODEL`、`FIELD-SW-SUPPORT-MATURITY` | 适合与 MEM-07/MEM-08 分层记录。接口存在不等于任意 copy 或任意同步都走专用硬件。 |
| SW-04 | Cooperative Groups 将 async copy 封装为 group-wide collective，并为 older architecture/反方向提供 software fallback。PDF pp.66-67。 | CUDA library/programming abstraction | `FIELD-SW-OPERATOR-LIBRARY` 或 programming model | 需要保留“software fallback”边界，不能把所有 collective 都写成 GA100 硬件卸载。 |
| SW-05 | A100 warp reduce instruction 可硬件加速 arithmetic ADD/MIN/MAX 和 logical AND/OR/XOR；其他类型/操作可由软件实现。PDF p.67，Figure 35。 | GA100/A100 dedicated instruction | reduction capability，`dedicated_instruction`、`FIELD-CAP-LIMITATION` | 可作为 GA100 候选机制。它是 warp-wide reduction，不是网络 collective offload，也不证明 Softmax 专用单元。 |

## 工作负载表述与芯片机制的分离

白皮书用 BERT、TCAIRS、histogram、MIG 多租户、JPEG/video pipeline 等例子说明机制价值。这些例子不能改写成 GA100 的无条件属性。

| 来源位置 | 工作负载或测量内容 | 可保留的芯片机制 | 不能下放的内容 |
|---|---|---|---|
| Figure 4，p.13 | BERT-LARGE training/inference speedup | Tensor Core、sparsity、memory hierarchy 的存在 | BERT 性能不能脱离 batch、精度、稀疏、软件和系统条件写成芯片固定吞吐 |
| pp.28-30，Figure 10-11 | 37 个 SuiteSparse 问题上的 TCAIRS convergence 和 speedup | TF32/BF16/FP16/FP64 Tensor Core 路径、cuSOLVER CUDA 11 支持 | geomean speedup、fallback 次数属于 solver/data-set 条件，不是数值格式固有精度结论 |
| pp.31-32 | dense training、pruning、fine-tuning、inference accuracy | 2:4 compressed weights、indices、Sparse MMA | pruning recipe、accuracy 和训练何时引入 sparsity 属于模型训练流程，不是芯片自动完成的机制 |
| pp.40-41、64-66 | ping-pong buffer、producer-consumer、LSTM weight、histogram | L2 residency control 和 set-aside | “某模型应该把哪些 buffer 放入 L2”是 workload mapping；Figure 34 的 2.48× 只适用于给定 256M integer dataset、5M-bin histogram |
| pp.44-52 | 多租户、VM、container、job packing | MIG 的物理分区、Sys Pipe、独立 context switch、fault isolation | 客户 workload 数量、利用率、装箱收益、数据中心成本不是 GA100 芯片属性 |
| pp.54-57 | JPEG/video training input pipeline | NVJPG、NVDEC、optical-flow module | 图像大小、压缩比、分辨率、帧率和并发流数量必须进 condition set |
| pp.58-61 | 2 μs sequential kernel、fork/join graph | task-graph dependency tracking 和 launch optimization | 图中 speedup 不能脱离 graph topology、kernel duration、CPU/driver/software条件 |

白皮书没有公开 Attention data movement、Softmax 专用单元、Top-k、MoE router/dispatch、network collective offload 或芯片绑定 KV Cache manager。不能因为通用 CUDA、warp reduction、NVLink 或 MIG 能承载相关软件，就把这些工作负载行为写成专用硬件。

## 对现有 Ampere 架构卡的复核

现有 `资料卡/NVIDIA/架构/NVIDIA_Ampere_架构.md` 的 21 条来源断言能回到这份固定 PDF，但本轮发现以下需要总控处理的范围和定位问题。这里不直接改卡或正式表。

| 项目 | 当前状态 | 本轮意见 |
|---|---|---|
| `FACT-M2NA-AMPERE-SM-EXEC` | Figure 7 规范化为 “SIMT Streaming Multiprocessor” | Figure 7 明确支持 warp scheduler、dispatch、thread/clk 和执行资源；`SIMT` 不是该处原文，应标项目分类或补 Programming Guide/ISA 第二来源。 |
| `FACT-M2NA-AMPERE-TENSOR-FORMATS` | 用 `FIELD-COMP-SHARED-RESOURCE` 承载格式列表 | 格式应由 precision path 的 operand/accumulation facts 承接；shared resource 字段不合适。 |
| `FACT-M2NA-AMPERE-ASYNC-EXEC` | 用 `FIELD-COMP-EXECUTION` 承载 async copy | async copy 更符合 `FIELD-MEM-DMA`、dataflow/residency 和 capability implementation；它不是执行模型。 |
| FP16/BF16/TF32/INT precision assertions | 多数定位 pp.20-21 的 feature bullet | Table 3 p.27 是更精确的 input/accumulator 证据；TF32 conversion/output 还应引用 pp.26-27。现卡缺 BF16 operand B、INT32 accumulator、FP16 accumulator 变体。 |
| `FACT-M2NA-AMPERE-SPARSE-DETAIL` | 卡内中文解释为硬件“从每四个中选择两个非零值” | 原始 assertion 只写 skip zero 是安全的；卡片解释易误导。Figure 12 显示 pruning/fine-tuning 先确定非零权重，硬件 `Select` 根据 indices 选择对应 input activation。 |
| L1/shared memory | 只记 mixed management 和 per-SM scope | 本来源还明确给 192 KB combined capacity、最大 164 KB shared allocation，二者不可相加。 |
| L2 residency | 架构卡未完整展开 | 应补 address-range/per-access control、1/16 A100 粒度以及 MIG mode 下 disabled 的条件。 |
| NVLink 3 | 只记 protocol name | 本来源还可支持 per-direction/per-link rate、lane 数、A100 link count、双向聚合口径、remote memory、error detection/replay，但产品数值和 link mechanism 应分开。 |
| 特殊机制 | 只保留 sparse 与 async copy | warp reduce、task graph dependency tracking、MIG context switch、NVJPG/NVDEC/optical-flow 等仍未承接；其中 optical-flow 有 GA100 明确主语，其他需要对象裁决。 |
| RAS、virtualization、scheduling | 现卡仍是旧九域结构 | 0.3 模板已经新增 scheduling、reliability、benchmark、economics；现卡的完整度和事实覆盖尚未按 0.3 回查。 |
| 来源生命周期 | 架构卡写 accepted，assertion/screening 多为 reviewed | `sources.csv`、`source-endpoints.csv`、`source-selected-roles.csv` 中该来源仍为 draft；来源已进入 reviewed selection member。正式验收前应统一解释或收敛状态。 |

## 可直接进入 GA100 候选抽取的最小集合

如果总控下一步建立 GA100 单芯片 staging，本来源中最稳的直接候选是：TSMC N7、54.2B、826 mm²；full GA100 的 8 GPC/64 TPC/128 SM、8192 FP32 Core、512 Tensor Core；12 个 512-bit memory controller；Figure 7 的 GA100 SM 结构；per-SM 4 Tensor Core 和 1024 dense FP16/FP32 FMA/clock；GA100 Optical Flow Accelerator；Figure 6 显示的 PCIe 4.0 x16 与 12 个 NVLink 物理接口。每项仍要按 component/link/precision-path 主体拆分，不要都挂 object。

第三代 Tensor Core 数值路径、2:4 Sparse MMA、async copy/barrier、combined L1/shared、L2 residency、NVLink 3 protocol behavior 和 warp reduction 更适合保留在 Ampere architecture 或 link/capability 实体上，再由 GA100 的 `implements_architecture`/link 关系复用。需要注意，本白皮书实际展开的是 GA100/A100 data-center Ampere；不要将数量和容量推广到所有 Ampere GPU。

A100 的 108 SM、432 Tensor Core、40 GB HBM2、5 stack、5120-bit、1555 GB/s、1410 MHz、400 W、产品峰值、最多 7 MIG instance 以及 108-SM register-file 总量不能进入 full GA100 die 事实。DGX A100/NVSwitch/InfiniBand 的系统拓扑也只能保留关系。

## 未决事实和需要的第二来源

1. GA100 die 与 A100 enabled configuration 的精确边界：需要 `2021_A100_Datacenter_GPU_Ampere_ISSCC.pdf` 或同级一手芯片论文确认 40 MB L2、5 NVDEC、NVJPG 数量、MIG/Sys Pipe 数量以及 absence of NVENC/RT/display 是 full GA100 物理实现还是 A100 产品启用配置。
2. full GA100 HBM interface：p.19 的 12 个 512-bit controller 可以直接记录，但 6 stack 属于封装语境；需第二来源决定能否建立 6144-bit total interface 派生值，以及该值应挂 die、package 还是 link/component。
3. SM execution taxonomy：需要 CUDA Programming Guide 或 ISA 明确支持 `SIMT`、warp scheduler 语义和 instruction issue 口径；Figure 7 不足以证明所有图示小方块的物理 ALU 数。
4. Tensor Core instruction/physical array：Figure 14 的 16×8×16 是 warp-level instruction tile，不能当 physical array。物理阵列形状、lower-level MMA 编码、metadata encoding、selector 实现和物理累加位宽仍未公开或需 ISA/独立微架构来源。
5. L2 组织与时钟域：40 MB、two partition、40 slice/partition、5120 B/clk 和 MIG 10-slice group 的关系需要第二来源核对；不能用 1410 MHz boost 直接把 5120 B/clk 转成 byte/s。
6. MIG migration 可用性：p.52 的迁移描述缺版本和运行限制，需要正式 MIG/vGPU 文档确认它是已交付功能、管理流程还是当时的产品方向；不得据此建立通用 checkpoint/restart。
7. RAS 缺口：白皮书支持 SECDED、NVLink detection/replay、MIG isolation 和 remote page-fault return；silent-data-error detection、telemetry/BIST、计算重放、复位/降级边界和作业恢复仍需第二来源。
8. 软件支持层级：本来源只能标 `documented_supported`。CUDA 11、MIG、async copy、L2 control、Cooperative Groups 的 runnable verification 和版本限制需要开发文档或可复现测试。
9. 专用大模型机制：Attention、Softmax、Top-k、MoE routing/dispatch、collective offload、KV Cache management 在本来源中没有芯片级证据，当前只能保留 `pending_verification`，不能写 `not_found`，因为本子任务没有完成全计划检索。

## 交接说明

本轮完整阅读和视觉核验使用的辅助抽取文本与渲染页位于 `审计/子代理交接/r1_ga100_03_core_source_reading_assets/`。这些文件只用于复核版式、表格、框图和脚注，不是新的正式来源，也不能替代规范 PDF。

正式写入前建议总控先做一次对象裁决：确定冻结对象 `NV-GA100` 是“full physical GA100 die design”还是“A100 中实际启用的 GA100 die configuration”。如果按前者，优先采用 PHY-01 至 PHY-04 和明确写 GA100 的专用模块，A100 enabled 数值全部留在关系侧；如果按后者，必须在对象名称、条件和事实说明中显式写 enabled configuration，避免与 full 128-SM design 混用。
