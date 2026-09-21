# GA100 的 ISSCC 2021 核心来源阅读卡

> 子任务：`r1_ga100_04_isscc_source_reading`  
> 状态：完成，待总控复核  
> 写入边界：只新增本交接文件和同名视觉核验资产；未修改正式 CSV、资料卡或进度文件

## 来源身份和核验方法

本轮精读的来源是 NVIDIA 作者在 ISSCC 2021 发表的 *The A100 Datacenter GPU and Ampere Architecture*：

- 本地固定 PDF：`论文/NVIDIA_GPU/01_厂商直接架构论文/2021_A100_Datacenter_GPU_Ampere_ISSCC.pdf`
- DOI：`10.1109/ISSCC42613.2021.9365803`
- 页数：3
- SHA-256：`55765d2680678ba46045da1902496ddd3995d5964a5f0ef68a99362e2c43b601`
- 清单状态：已登记于 `清单/论文PDF清单.csv`；正式 `sources.csv`、`source-families.csv` 和 `source-endpoints.csv` 还没有对应记录，因此本卡不自行分配正式 `source_id`

三页均按 180 dpi 渲染并逐页视觉核对；Figure 3.2.2 另以 300 dpi 放大确认表内格式与吞吐数字。文本抽取只用于定位。下文同时使用 PDF 页码和论文印刷页码：PDF p.1 对应印刷 p.48，PDF p.2 对应印刷 p.49，PDF p.3 是 paper continuation 页。

## 对象边界

这篇论文把物理裸片、A100 启用配置、Ampere 架构机制和 DGX A100 系统压缩在三页内。它没有使用 `GA100` 名称，全文的直接主语是 `A100`、`A100 die`、`A100 Tensor Core` 或 `A100 SM`。将其中的裸片事实写给冻结对象 `NVIDIA GA100 die`，必须经过已冻结身份来源中“A100/A30 映射到 GA100 microarchitecture”的身份链；不能只凭论文标题把全部 A100 数值下放给 GA100。

| 来源中的对象 | 本轮解释 | 对 GA100 工作包的处理 |
|---|---|---|
| `A100 die`、Figure 3.2.7 die photo | 物理裸片 | N7、面积和晶体管数可作为 GA100 候选，但须与 A100→GA100 身份来源共同使用 |
| 108 SM、6912 CUDA core、40 MB L2、1.41 GHz 和产品峰值 | A100 的启用配置 | 不能写成 full GA100 的物理设计资源；白皮书给出的 128 SM/8192 FP32 core/512 Tensor Core 是另一条件 |
| HBM2 带宽和 HBM2 site | A100 产品/封装的 HBM 子系统 | HBM 不在裸片内；不得写成 GA100 die 容量、堆叠数或封装规格 |
| Tensor Core、async copy、L2 residency、compression、MIG | A100 实现所承载的 Ampere/GA100 机制 | 机制可进入架构、component、capability 或 virtualization 主体；数量和产品限制仍绑定 A100 配置 |
| NVLink3 PHY | A100 使用的 device-direct link 机制 | link 事实与 A100 每设备配置分开；不把 DGX/NVSwitch 拓扑写给 die |
| DGX A100、NVSwitch、InfiniBand | 系统 | 只作关系或系统背景，不纳入 GA100 芯片事实 |

## 物理实现与 A100 启用配置

| 编号 | 原文摘录与精确定位 | 候选 `field_id` | 事实主体和条件 | 裁决与不确定性 |
|---|---|---|---|---|
| PHY-01 | “Implemented in a TSMC 7nm N7 process”。PDF p.1 / 印刷 p.48，左栏第 1 段末；Figure 3.2.7 在 PDF p.3。 | `FIELD-PHY-FOUNDRY`；`FIELD-PHY-PROCESS` | `GA100 die` 候选；需 A100→GA100 身份链 | 可支持裸片物理实现。论文写的是 `A100 die`，没有直接写 `GA100`，因此单独使用本源时仍有身份命名缺口。 |
| PHY-02 | “contains 54B transistors”。PDF p.1 / 印刷 p.48，左栏第 1 段末。 | `FIELD-PHY-TRANSISTORS` | `GA100 die` 候选；原始值保留 `54B` | 白皮书为 `54.2 billion`。两者更像会议短文取整，不是明确设计版本冲突；逐来源断言必须保留 54B 与 54.2B，不得把 54B 改写成 54.2B。 |
| PHY-03 | “measures 826mm²”。PDF p.1 / 印刷 p.48，左栏第 1 段末。 | `FIELD-PHY-DIE-AREA` | `GA100 die` 候选；每裸片面积 | 与白皮书 826 mm² 一致，可作为第二份第一方固定来源。 |
| PHY-04 | “A100 contains 108 Streaming Multiprocessors (SMs) and 6912 CUDA cores”。PDF p.1 / 印刷 p.48，左栏第 1 段；Figure 3.2.1 位于 PDF p.2 左上。 | `FIELD-COMP-UNIT-COUNT` | `A100 enabled configuration`；108 SM、6912 CUDA core 分拆 | 不支持 full GA100 物理上限。该来源反而确认 108/6912 是 A100 配置值，不能覆盖白皮书明确的 full GA100 128/8192。 |
| PHY-05 | Figure 3.2.1 caption：“40MB L2”。PDF p.2 / 印刷 p.49，左上。 | `FIELD-MEM-CAPACITY` | A100 启用配置中的 L2；whole-device scope | 不能写成 full GA100 的物理总 L2。该数字与白皮书的 A100 40 MB 一致，但未解决 full design 是否有更大物理容量。 |
| PHY-06 | “1.56TB/s of HBM2 memory bandwidth”；Figure 3.2.1 caption 同值。PDF p.1 左栏第 1 段；PDF p.2 左上。 | `FIELD-MEM-READ-BW` 或 `FIELD-MEM-BIDIR-BW`，需总控先裁决方向口径 | A100 产品/封装 HBM 子系统；`traffic_basis=vendor_nameplate`，方向未写明 | 不能挂 GA100 die。白皮书给 1555 GB/s，本源的 1.56 TB/s 是三位有效数字取整，可视为口径相容；不能据此另建一个无条件 1.56 TB/s GA100 事实。 |
| PHY-07 | “At 1.41GHz”。PDF p.1 / 印刷 p.48，左栏第 1 段。 | `FIELD-PHY-CLOCK` | A100 启用配置；产品峰值条件 | 只给产品性能所用频率，没有证明 full GA100 的设计频率或所有单元时钟域。 |
| PHY-08 | Figure 3.2.1 的框图两侧可见 6 个 HBM 区域标签；caption 只写 HBM2 代际和带宽，没有给 active stack count。PDF p.2 左上。 | 暂不建立字段候选 | A100/GA100 schematic | 不能把图上的 6 个接口位置解释成 6 个 active HBM stack。白皮书区分 full GA100 的 6 个 site 与 A100 的 5 个 active stack，本图没有推翻该边界。 |
| PHY-09 | Figure 3.2.7 caption：“A100 die photo”，版图上标出 SM、L2、NVLINK 和 HBM 边缘区域。PDF p.3 左上。 | 身份证据；已有字段可分别落 `component`/`link`，本图不提供新数量 | `A100 die`；需 A100→GA100 身份链 | 可核对这些物理区域存在，不能按彩色覆盖面积推导单元数、容量、带宽或面积占比。 |

## 计算、数值路径和数据搬运

| 编号 | 原文摘录与精确定位 | 候选 `field_id` | 事实主体和条件 | 裁决与不确定性 |
|---|---|---|---|---|
| COMP-01 | “3rd-generation Tensor Core with support for fine-grained sparsity, new BFloat16 (BF16), TensorFloat-32 (TF32), and FP64 datatypes”。PDF p.1 / 印刷 p.48，左栏第 1 段。 | `FIELD-COMP-UNIT-NAME`；对应 precision path 的 `FIELD-NUM-OPERAND-A/B` | A100 Tensor Core / Ampere 架构机制 | 适合作为架构和 GA100 Tensor Core 机制证据，不含物理阵列形状、内部乘积位宽或舍入模式。 |
| COMP-02 | “2× higher throughput on dense FP16 matrix multiplies per SM per clock cycle” 和 “another 2× boost from fine-grained sparsity”。PDF p.1，左栏第 2 段。 | `FIELD-COMP-THROUGHPUT`；`FIELD-NUM-SPARSITY` | A100/GA100 SM；relative-to-V100、dense/sparse、per-SM-per-cycle | 只能保留相对提升和作用域。稀疏 2× 是 effective throughput，不证明物理 MAC 数翻倍。 |
| COMP-03 | Figure 3.2.2 的 A100 行依次为 FP32→FP32 19.5 TFLOPS；TF32→FP32 156/312；FP16→FP32 312/624；BF16→FP32 312/624；INT8→INT32 624/1248；INT4→INT32 1248/2496；BINARY→INT32 4992；FP64→FP64 19.5。PDF p.2，右上 Figure 3.2.2。 | `FIELD-NUM-OPERAND-A/B`；`FIELD-NUM-ACCUMULATION`；`FIELD-COMP-THROUGHPUT` | 108-SM A100 配置；理论峰值；后列为 sparse effective | 这些数值不能写给 full GA100。图标题概括为 Tensor Core input/output formats，但标准 FP32 19.5 行属于 A100 的非-TF32 FP32 路径，不能据图改写成 FP32 Tensor Core 峰值。列标题实际是 `Input Operands` 和 `Accumulator`，可支持累加格式，不足以证明最终存储输出格式。 |
| COMP-04 | “At 1.41GHz, A100 provides an effective peak 1248TOPS (8b integers), 624TFLOPS (FP16) and 312TFLOPS (TF32) when including sparsity optimizations”。PDF p.1，左栏第 1 段。 | `FIELD-COMP-THROUGHPUT` | A100 配置；1.41 GHz；sparse effective peak | 与 Figure 3.2.2 一致，是同一来源内复核，不是第二个独立来源。INT8、FP16、TF32 必须拆为三个 precision path。 |
| COMP-05 | TF32 “contains 1 sign, 8 exponent, and 10 mantissa bits”；“everything outside of the tensor core remains standard FP32, including accumulators and memory storage”。PDF p.1，左栏第 2 段。 | `FIELD-NUM-CONVERSION`；`FIELD-NUM-ACCUMULATION`；`FIELD-NUM-OUTPUT` | A100 Tensor Core；TF32 input、FP32 accumulation/storage | 比单纯格式列表更强，可支持 TF32 转换边界。`10 mantissa bits` 按原文保存，不自行改成 fraction/significand 的另一种定义。 |
| COMP-06 | “8b integer, 4b integer, and binary datatypes with 32b integer accumulation”。PDF p.1，左栏第 2 段。 | `FIELD-NUM-OPERAND-A/B`；`FIELD-NUM-ACCUMULATION` | A100 Tensor Core；DL inference 语境 | 可支持 INT8、INT4、binary 到 INT32 的程序员可见累加路径；不支持物理累加器位宽或饱和规则。 |
| COMP-07 | “For HPC, A100 introduces FP64 Tensor Cores”。PDF p.1，左栏第 2 段。 | `FIELD-COMP-UNIT-NAME`；FP64 precision path | A100/GA100 Tensor Core；HPC 产品语境 | 机制可经架构关系复用；段落中的 `2.5× FLOPS increase over V100` 是相对产品结果，不是 GA100 绝对吞吐。 |
| COMP-08 | “consume 2× the data BW per SM ... for dense data and 3× for sparse data (compressed weights and uncompressed activations)”。PDF p.1，左栏第 3 段。 | `FIELD-COMP-SHARED-RESOURCE`；`FIELD-COMP-UTILIZATION-LIMIT` | A100 Tensor Core 相对 V100；per SM；dense/sparse | 这是喂数需求和相对带宽压力，不是 HBM 带宽或负载通信量。可解释设计约束，不能登记为绝对 `byte/s`。 |
| COMP-09 | “32-thread Tensor Cores halve the shared memory load BW”。PDF p.1，左栏第 3 段；Figure 3.2.3 位于 PDF p.2 左中。 | `FIELD-COMP-DATAFLOW-RESIDENCY`；`FIELD-COMP-SHARED-RESOURCE` | A100 SM 相对 V100 的矩阵乘示例 | 表述是共享内存 load demand 减半，不是共享内存物理带宽减半。 |
| COMP-10 | “load-global-store-shared instruction ... asynchronous-copy ... directly into shared memory, bypassing the RF”；Figure 3.2.3 caption 进一步写 “bypasses L1 cache and register file”。PDF p.1，左栏第 3 段；PDF p.2 左中。 | `FIELD-MEM-DMA`；`FIELD-COMP-DATAFLOW-RESIDENCY`；`FIELD-CAP-IMPLEMENTATION-LEVEL`；`FIELD-CAP-IMPLEMENTATION-DETAIL` | Ampere/GA100 SM；global-to-shared 专用指令 | 可支持特定方向的 asynchronous copy。不能扩大成通用 DMA 或任意双向复制。正文只明确绕过 RF，绕过 L1 的证据来自 Figure 3.2.3 caption，应保留各自定位。 |
| COMP-11 | “programmed with a new ISO C++20 asynchronous barrier ... supported in CUDA 8.0”。PDF p.1，左栏第 3 段末。 | `FIELD-COMP-CONTROL-SCHEDULING`；`FIELD-SW-PROGRAMMING-MODEL` | A100/GA100 async-copy software mapping | 与 2020 白皮书的 CUDA 11 barrier 表述冲突，且 CUDA 8.0 早于 A100。正式写入前应查原始出版勘误或 CUDA 文档；本源当前只支持 barrier 存在，不采用 `CUDA 8.0` 版本事实。 |
| COMP-12 | “design goal to not rely on weak scaling ... increasing the NN size or batch size”；“targeted strong scaling with 2.5× speedup on fixed-size NNs”。PDF p.1，左栏第 4 段。 | `FIELD-ID-DESIGN-OBJECTIVE` | A100 产品/架构设计目标；相对 V100 | 这是芯片设计目标，batch 只在解释 weak scaling 时出现，不应注册为芯片属性。`2.5×` 仍是目标/相对结果，不能无条件写成芯片性能。 |

## L2、HBM 和压缩机制

| 编号 | 原文摘录与精确定位 | 候选 `field_id` | 事实主体和条件 | 裁决与不确定性 |
|---|---|---|---|---|
| MEM-01 | “L2 was split into partitions using a hierarchical crossbar structure”；每个 partition 缓存靠近其访问 SM 的数据。PDF p.1，左栏第 4 段。 | `FIELD-MEM-MANAGEMENT`；`FIELD-MEM-LOCALITY-SCOPE`；`FIELD-COMP-DATAFLOW-RESIDENCY` | A100 L2 实现；whole GPU、partitioned | 可支持分区和局部性机制，不给 partition 数、slice 数或物理拓扑尺寸。不得从 Figure 3.2.1 的两个 `L2 Cache` 标签直接推导正式 partition count。 |
| MEM-02 | “Hardware cache coherence still maintains the memory consistency supported by CUDA across the full GPU”。PDF p.1，左栏第 4 段。 | `FIELD-MEM-CONSISTENCY` | A100 full-GPU 模式；CUDA memory model | 只说明 full GPU 范围的一致性维护，不公开协议、原子范围或 MIG 条件。与 MIG 的 memory isolation 是不同配置，不冲突。 |
| MEM-03 | “An additional HBM2 site and faster clocks provide 1.56TB/s, a 1.7× increase over V100”。PDF p.1，左栏第 4 段。 | `FIELD-MEM-READ-BW` 或 `FIELD-MEM-BIDIR-BW`，方向待裁决；相对提升可作来源上下文 | A100 产品/封装 HBM 子系统 | `additional site` 是相对 V100 的产品实现说明，不等于本源明确给出 active stack count。不得把 HBM site 当作 die 内 memory capacity。 |
| MEM-04 | “increases L2 capacity by almost 7× over V100 and adds L2 controls ... manage the on-chip residency of data”。PDF p.1，左栏第 4 段。 | `FIELD-MEM-CAPACITY`；`FIELD-MEM-MANAGEMENT` | A100 L2；相对 V100；软件可控 residency | 40 MB 绝对容量见 Figure 3.2.1。控制机制可经架构关系复用；来源没给控制粒度或 MIG 下是否禁用。 |
| MEM-05 | “compute data compression” 利用 activation 中“typically over 50%”的 unstructured sparsity；“compress ... in DRAM by 2-4× and in the L2 by up to 2×”。PDF p.1，左栏第 4 段末。 | `FIELD-MEM-COMPRESSION`；`FIELD-CAP-IMPLEMENTATION-LEVEL`；`FIELD-CAP-IMPLEMENTATION-DETAIL`；`FIELD-CAP-LIMITATION` | A100/GA100 compression hardware；activation data；vendor upper-bound | 这是独立于 2:4 Sparse MMA 的数据压缩机制。50% 是典型 activation 稀疏语境，不是芯片属性；2-4× 和 up to 2× 不能乘到基础带宽或容量上。 |
| MEM-06 | Figure 3.2.1 caption 将 40 MB L2 标为 V100 的 6.7×，正文写 “almost 7×”。PDF p.2 左上；PDF p.1 左栏第 4 段。 | `FIELD-MEM-CAPACITY` | A100 启用配置 | 两处相容，前者更精确。相对数不增加独立来源计数，也不能替代 40 MB 的绝对值。 |

## MIG、软件与 RAS

| 编号 | 原文摘录与精确定位 | 候选 `field_id` | 事实主体和条件 | 裁决与不确定性 |
|---|---|---|---|---|
| VIRT-01 | “Each A100 can function as up to 7 isolated GPUs, reconfigurable on the fly”。PDF p.1 / 印刷 p.48，右栏第 2 段。 | `FIELD-VIRT-PARTITIONING`；`FIELD-VIRT-MULTI-TENANCY` | 7-GPC A100 启用配置；MIG mode | 是芯片绑定机制，但 `up to 7` 不能写成 full 8-GPC GA100 的物理分区上限。 |
| VIRT-02 | “Two types of MIG instances”；一种隔离 compute 但不隔离 memory，另一种提供 memory system 的 functional and performance isolation。PDF p.1，右栏第 2 段。 | `FIELD-VIRT-PARTITIONING`；`FIELD-VIRT-PREEMPTION-QOS`；`FIELD-VIRT-MULTI-TENANCY` | A100 MIG；两类 instance 分开 | 本源对隔离层次的区分比“最多 7 个实例”更重要。不能笼统写成所有 MIG instance 都有完整 memory isolation。 |
| VIRT-03 | 为后者分配“不与其他 MIG instances 共享”的 physical pathways，包括 on-chip crossbar、L2 cache 和 memory interface。PDF p.1，右栏第 2 段。 | `FIELD-VIRT-PARTITIONING`；`FIELD-RAS-FAULT-ISOLATION`；`FIELD-RAS-PROTECTION-SCOPE` | A100 fully isolated MIG type | 可支持计算到内存路径的隔离边界和厂商声称的 security boundary；不证明所有控制状态、copy engine 或 host link 都被隔离。 |
| VIRT-04 | compute-only isolation “enabling an OS to schedule processes with lightweight administration”。PDF p.1，右栏第 2 段。 | `FIELD-SW-CHIP-BOUND-SCHEDULING`；`FIELD-SW-PROGRAMMING-MODEL` | A100 MIG + OS scheduling | 只说明 OS 可调度，不提供 OS、驱动、Runtime 版本或 runnable verification，因此成熟度最多是厂商论文陈述。 |
| VIRT-05 | “CUDA programmability and strong scaling features in A100”。PDF p.1，右栏第 1 段。 | `FIELD-SW-PROGRAMMING-MODEL`；`FIELD-SW-SUPPORT-MATURITY` | A100 产品语境 | 只能支持 CUDA 编程模型的厂商声明。没有版本、框架、编译器或可运行测试，不能标成 `runnable_verified` 或 `benchmarked`。 |
| RAS-01 | NVLink3 PHY 使用 NRZ，在无 FEC 下达到 `1e-15 BER`。PDF p.1，右栏第 3 段。 | `FIELD-INT-FAULT` 的 PHY 可靠性上下文；不支持 `FIELD-RAS-ERROR-DETECTION` | NVLink3 LR PHY | 无 FEC 与 BER 目标不能证明 link-level error detector、packet replay 或全芯片 RAS；这些机制如需收录，应引用白皮书或协议文档。MIG fault isolation 的可用证据已经在 VIRT-03 单独记录。 |

## NVLink3、DGX 和系统边界

| 编号 | 原文摘录与精确定位 | 候选 `field_id` | 事实主体和条件 | 裁决与不确定性 |
|---|---|---|---|---|
| INT-01 | “NVLink3 doubles the BW per GPU to 300GB/s in each direction”；“increasing the links per GPU to 12”。PDF p.1，右栏第 3 段。 | `FIELD-INT-INJECTION-BW`；`FIELD-INT-LINK-COUNT` | A100 device-direct 配置；300 GB/s per direction；12 links/device | 这是 A100 每设备启用配置，不是 DGX 系统聚合值；也不能自动当作 full GA100 所有物理接口的带宽。 |
| INT-02 | “long-reach (LR) differential interface operating at a raw bitrate of 50Gbps”。PDF p.1，右栏第 3 段；Figure 3.2.5 位于 PDF p.2 左下。 | `FIELD-INT-PER-LINK-RATE` 候选；`traffic_basis=raw_line_rate` | NVLink3 LR PHY | 原文把 50 Gbps 说成 differential interface raw bitrate，没有在本句明确它是完整逻辑 NVLink 的单链路 payload。正式结构化时需与白皮书的 signal-pair/lane 定义一起使用。 |
| INT-03 | “uses NRZ signaling and achieves 1e-15 BER without requiring a FEC”；“saves tens of nanoseconds of round-trip latency”。PDF p.1，右栏第 3 段。 | `FIELD-INT-FAULT`；`FIELD-INT-LATENCY` 仅作相对线索 | NVLink3 LR PHY；相对于需 FEC 的 50 Gbps LR 标准 | `tens of nanoseconds` 是节省量，不是绝对 latency，不能直接规范化为秒值。BER 是 PHY 声明，不代表端到端 packet error rate。 |
| INT-04 | LR mode 使用 3-tap Tx FIR、Rx CTLE、PRML sequence detection、Viterbi convolutional decoder 和 baud-rate clock recovery。PDF p.1，右栏第 3 段；Figure 3.2.5。 | 现有 0.3 字段没有完全合适的 link-PHY mechanism 字段；可暂存为 `FIELD-INT-PROTOCOL` 的机制上下文，或后续数据模型裁决 | NVLink3 LR PHY | 这是相对白皮书最明显的独有电路级证据。不要为了保留细节而误写成 AI 专用 `special_capability`。 |
| INT-05 | DGX A100 “with 8 A100 GPUs and 6 NVSwitch chips”。PDF p.1，右栏第 4 段；Figure 3.2.6 位于 PDF p.2 右下。 | 系统关系或 system topology 字段 | DGX A100 system | 主线不统计系统，不能下放给 GA100。 |
| INT-06 | 每个 GPU 与每个 NVSwitch 用 2 条 NVLink3，共 12 connections，并支持 “600GB/s ... for each A100”。PDF p.1，右栏第 4 段。 | `FIELD-INT-AGGREGATE-BW`；`FIELD-INT-LINK-COUNT` | DGX A100 配置中的每 A100；600 GB/s bidirectional aggregate | 600 GB/s 与 300 GB/s each direction 相容。连接方式依赖 DGX/NVSwitch 系统，不能用来证明任意 GA100 部署都具有相同拓扑。 |
| INT-07 | “full-BW non-blocking communication pairwise between all the GPUs”。PDF p.1，右栏第 4 段。 | `FIELD-INT-TOPOLOGY`；`FIELD-INT-OVERSUBSCRIPTION` | 8-GPU DGX A100 + 6 NVSwitch | 是系统拓扑性质，不是 die 的 fully connected 物理拓扑。 |
| INT-08 | Mellanox HDR 200 Gb/s InfiniBand NICs 连接到 “full fat tree switched interconnect”。PDF p.1，右栏第 4 段。 | system scale-out topology | DGX/多系统 scale-out | NIC、fat-tree 和系统网络不进入 GA100 芯片资料卡的物理互联字段，只能保留部署背景。 |

## Benchmark 和工作负载条件

Figure 3.2.4 把 HPC 与 MLPerf v0.7 结果绘成相对 V100 的 speedup。正文写 A100 在 MLPerf v0.7 training 上为 1.5-2.5×，HPC 为 1.5-2×，并使用“per chip”措辞；同一段又说 A100 是唯一运行全部 benchmark 的“system”。Figure 本身没有列出完整的软件版本、精度、batch、模型参数、功耗模式、设备配置和统计口径。

这些结果不能成为 GA100 die 的无条件 `FIELD-COMP-THROUGHPUT`，也不能只凭图建立 `FIELD-BENCH-*` 正式事实。若后续确实要收录，应回到 MLPerf v0.7 原始提交和各 HPC benchmark 配置，分别建立完整 `condition_set_id`，并按单芯片、A100 配置和系统测量范围拆分。这里的模型、batch 或固定问题规模只属于条件，不是芯片属性。

## 相对白皮书的证据职责

### 可新增的职责

ISSCC 论文提供三类集中证据：NVIDIA 芯片作者在同行评审会议论文中明确写出 N7、826 mm² 和 54B，并配有 die photo；108 SM、6912 core 和 40 MB L2 被明确放在 A100 配置下，有助于阻止它们被误当成 full GA100 资源；NVLink3 LR PHY 的 NRZ、无 FEC、BER、均衡与 PRML/Viterbi 实现也有电路级说明。后两类内容在白皮书中较为分散，或者没有同等深度的展开。

### 与白皮书重复的内容

第三代 Tensor Core、BF16/TF32/FP64、INT8/INT4/binary、2:4 sparse effective throughput、async global-to-shared copy、40 MB L2、L2 residency、compute data compression、MIG、12 条 NVLink3、每方向 300 GB/s 和 DGX A100 系统拓扑均已被白皮书更完整地覆盖。若最终 GA100 接受事实没有采用 ISSCC 独有的 die-photo/PHY 证据，反向移除时这篇论文很可能被白皮书完整覆盖；同行评审身份本身不能代替“对接受事实有独有贡献”的最小集规则。

### 需要显式保留的差异

| 项目 | ISSCC 论文 | NVIDIA 白皮书 | 本轮处理 |
|---|---|---|---|
| 晶体管数 | 54B | 54.2B | 视为可能的取整相容；两份来源保留各自原值，规范事实采用哪一口径由总控裁决 |
| HBM 带宽 | 1.56 TB/s | 1555 GB/s | 取整相容；均属于 A100 HBM 子系统，不下放给 GA100 die |
| full design / enabled | 只给 A100 108 SM/6912 core | 明确 full GA100 128 SM/8192 core，A100 enabled 108/6912 | 以白皮书维持两套条件；ISSCC 不解决 full design 资源缺口 |
| HBM site | 图示两侧共 6 个 HBM 区域标签，正文只说 additional site | full GA100 6 site，A100 5 active stack | 图示不能当 active stack count，不构成冲突 |
| async barrier 软件版本 | CUDA 8.0 | CUDA 11 | 未解决冲突；暂不收录 CUDA 8.0，需开发文档或勘误裁决 |
| NVLink 总带宽 | 300 GB/s each direction；DGX 中 600 GB/s/A100 | 600 GB/s bidirectional aggregate | 口径相容；方向和系统条件必须显式保存 |

## 本源未解决的问题

这篇论文没有把 full GA100 的物理设计资源与 A100 启用配置并列表达，因此 40 MB L2、108 SM、6912 CUDA core、MIG 上限 7 等都不能写成 full GA100 事实。它也没有给出 HBM active stack count、full physical HBM interface、NVDEC/NVJPG 数量或 NVENC/RT/display 的物理存在性，无法解决白皮书阅读卡提出的这些对象边界问题。

论文没有提供 ECC、silent data error、telemetry/BIST、checkpoint/restart、计算重放、全芯片故障降级，也没有 Attention、Softmax、Top-k、MoE route/dispatch、network collective offload 或芯片绑定 KV Cache manager。由于本子任务只检查一篇来源，这些字段状态仍应是 `pending_verification`，不能直接改成 `not_found`。

## 建议给总控的下一步

正式 staging 时，优先把本源用作 GA100 物理实现的第二来源和 NVLink3 PHY 机制来源。N7、826 mm²、54B 要与白皮书及 A100→GA100 身份来源共同形成事实链；108/6912、40 MB、1.41 GHz、HBM2 带宽、A100 峰值和 MIG 7-way 都保留在 A100 enabled configuration 或上层产品关系侧，不进入 full GA100 die。

最小来源反向移除前，应先决定是否接受 NRZ/无 FEC/BER/PRML 等 link-PHY 细节。如果接受，这篇论文有白皮书无法完全替代的职责；如果资料卡只保留 0.3 已注册字段且不承接电路级 PHY 机制，这篇论文对 GA100 接受事实大多是重复证据，可能不应进入最小集。

## 验证和写入文件

已完成以下检查：PDF 页数为 3；本地文件哈希与 `清单/论文PDF清单.csv` 一致；三页渲染图均可读；Figure 3.2.2 的格式、累加类型和吞吐数字经 300 dpi 放大核对；PDF p.3 的 Figure 3.2.7 die photo 已视觉检查。渲染时出现 Fontconfig cache 不可写警告，但 PNG 正常生成，属于工具运行环境警告，没有造成版面缺失。

本子任务新增：

- `审计/子代理交接/r1_ga100_04_isscc_source_reading.md`
- `审计/子代理交接/r1_ga100_04_isscc_source_reading_assets/` 下的三页渲染图、Figure 3.2.2 放大图和辅助抽取文本

没有修改 `数据/`、`最小参考资料库/`、`资料卡/` 或 `进度/` 中的正式文件。
