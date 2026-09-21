# GA100 IEEE Micro 候选来源差分阅读卡

> 子任务：`r1_ga100_04_ieee_micro_differential_reading`  
> 状态：完成，待总控复核  
> 读取对象：NVIDIA A100 Tensor Core GPU，以及文中与 GA100 die、Ampere 架构、A100 启用配置、SXM4 板级实现和 DGX A100 系统相邻的表述  
> 写入边界：只新增本交接文件和同名辅助目录；未修改正式 CSV、资料卡、来源记录或进度文件

## 来源身份和版式核验

本轮阅读的固定版本如下：

| 项目 | 核验结果 |
|---|---|
| 标题 | *NVIDIA A100 Tensor Core GPU: Performance and Innovation* |
| 作者与来源性质 | Jack Choquette、Wishwesh Gandhi、Olivier Giroux、Nick Stam、Ronny Krashinsky；作者署名均为 NVIDIA，因此是厂商一手文章，不是独立第三方确认 |
| 出版物 | *IEEE Micro*, 41(2), March/April 2021, pp. 29-35 |
| DOI | `10.1109/MM.2021.3061394` |
| 日期 | 首次发表 2021-02-23；当前版本 2021-03-26，均来自文章 PDF 第 1 页页脚 |
| 本地文件 | `论文/NVIDIA_GPU/01_厂商直接架构论文/2021_NVIDIA_A100_Tensor_Core_GPU_Performance_and_Innovation.pdf` |
| SHA-256 | `96a0f9053da3c3978f907ee1fee324913bd6b600fec96137738b407e400d700d` |
| 页数 | 7 页；PDF 页 1-7 对应印刷页 29-35 |

后文中，SM（Streaming Multiprocessor）指流式多处理器，HBM2（High Bandwidth Memory 2）指第二代高带宽内存，MIG（Multi-Instance GPU）指多实例 GPU，QoS（Quality of Service）指服务质量，RAS（Reliability, Availability and Serviceability）指可靠性、可用性和可维护性。API（Application Programming Interface）和 BIST（Built-In Self-Test）分别指应用程序接口和内建自测试。

全部 7 页均已渲染并逐页查看。Figure 1-9、Figure 4 的格式与吞吐表、Figure 6 的标注裸片图、Figure 7 的 DGX A100 系统图，以及 Figure 8-9 的代码均以页面图像为准；抽取文本只用于检索。页面没有缺页、裁切或不可读图表。

资料池另存有 92 页的 *IEEE Micro* 41(2) 整期 PDF。整期 PDF 第 31-37 页和本次 7 页独立文章的 `pdftotext -layout` 输出逐字节相同，SHA-256 也相同。因此整期文件只是同一文章的容器，不能注册成第二来源、第二内容版本或第二份证据。

## 对象边界

文章正文没有出现 `GA100` 代号。主语始终是 A100 GPU、A100 SM、A100 L2、A100 MIG 或 DGX A100。Figure 6 的标题是 `NVIDIA A100 die`，仍未把该裸片明确命名为 GA100。由此得到的边界如下：

| 对象层级 | 文章能直接支持的内容 | GA100 工作包的处理 |
|---|---|---|
| Ampere 架构 | 第三代 Tensor Core、异步 global-to-shared 搬运、异步 barrier、L2 residency control、Compute Data Compression 和第三代 NVLink 的机制描述 | 与 A100 实现绑定的架构证据。若复用到 GA100，必须先有正式的 `implements_architecture` 或 A100 与 GA100 的身份关系，不能凭本文直接扩展到所有 Ampere 芯片 |
| GA100 die | 本文没有使用 GA100 代号，也没有给 full implementation 的 128 SM、64 TPC、826 mm² 或 54.2B 等明确 GA100 数值 | 不能单独承担 GA100 die 身份或 full-die 物理规格。Figure 6 只能作物理区域的视觉旁证 |
| A100 enabled configuration | 108 SM、6912 CUDA Core、40 MB L2、12 条 NVLink、Tensor Core 峰值、最多 7 个 MIG GPU Instance | 可作为 A100 启用配置事实，不得改写成 full GA100 的物理资源数量 |
| SXM4 板级实现 | 40 GB HBM2、5 个 active stack、每 stack 8 个 memory die、1215 MHz DDR、1555 GB/s | 原文明确写在 `SXM4-style circuit board` 上，不能写到 GA100 die |
| DGX A100 和多系统 | 8 个 A100、NVSwitch、200G NIC、InfiniBand 或 Ethernet 扩展 | 只作系统背景。Figure 7 的拓扑和任何系统聚合值都不进入 GA100 资料卡 |

文章第 1 页把 A100 的部分产品规格写成概览，并用较低精度表示。`54 billion` 与白皮书的 `54.2 billion`、`1.6 TB/s` 与本文后文和白皮书的 `1555 GB/s` 是四舍五入后的同一量级表述，不构成来源冲突。若正式记录原值，应优先保存更精确的 `54.2B` 和 `1555 GB/s`，同时把概览原文保留在断言中，不能把两种精度混成两项独立规格。

## 相对白皮书的差分结果

下表以 `r1_ga100_03_core_source_reading.md` 为基线。`新增` 表示白皮书阅读卡没有覆盖、且本文给出了可定位的额外信息；`更清楚限定` 表示本文帮助收紧对象或机制，但不新增一项独立芯片事实；`重复` 表示白皮书已有更完整或同等证据；`冲突` 只用于无法通过对象、方向、单位或舍入解释的不一致。本轮没有发现实质冲突。

| 编号 | 页码、图表与主张 | 主体和条件 | 候选 `field_id` | 差分判定与正式使用边界 |
|---|---|---|---|---|
| PHY-01 | PDF p.1，印刷 p.29：A100 为 TSMC 7 nm、54B transistor，启用 108 SM、6912 CUDA Core、40 MB L2，并列出 600 GB/s NVLink 和 1.6 TB/s HBM2 | A100 enabled configuration；概览精度 | `FIELD-PHY-PROCESS`、`FIELD-PHY-TRANSISTORS`、`FIELD-COMP-UNIT-COUNT`、`FIELD-MEM-CAPACITY`、`FIELD-INT-AGGREGATE-BW` | 重复且作用域更弱。本文没有 GA100 代号、N7 细分或面积。54B 与 54.2B、1.6 TB/s 与 1555 GB/s 是舍入差异。600 GB/s 由 p.5 说明为 A100 的双向总带宽，不是单向注入带宽 |
| PHY-02 | PDF p.4，印刷 p.32，Figure 6 `NVIDIA A100 die`：标出 SM 区域、两处 L2 区域、HBM 边缘接口和 NVLINK 区域 | A100 裸片图；无尺寸、比例、精确单元边界或资源计数承诺 | `FIELD-COMP-DATAFLOW-RESIDENCY`、`FIELD-MEM-LOCALITY-SCOPE` 的旁证；不建议据图直接建数值事实 | 更清楚限定。它可帮助理解计算区、L2 和 I/O 的物理相邻关系，也与“L2 分为两个 partition”相互印证；图中标签不足以证明 controller 数、bank 数或精确 floorplan，不能从图形面积反推资源比例 |
| COMP-01 | PDF p.3，印刷 p.31，Figure 4：A100 的 FP32、TF32、FP16、BF16、INT8、INT4、binary 和 FP64 路径及 dense/sparse 峰值 | A100 enabled configuration；厂商峰值；图中 TOPS/TFLOPS 口径 | `FIELD-COMP-THROUGHPUT`、`FIELD-COMP-COUNT-RULE` 以及 precision path 的 operand/accumulator 字段 | 重复。白皮书 Table 3/4 对输入、累加格式和峰值的定位更完整。本文不能证明物理 Tensor Core array shape，也不能把 Figure 4 的逻辑格式图当成物理位宽 |
| COMP-02 | PDF pp.3-4，印刷 pp.31-32，Figure 5：Tensor Core 从 V100 的 8-thread granularity 改为 A100 的 32-thread granularity；数据加载由 6 次 L1+SMEM access 减为 2 次 SMEM read；异步 combined load-global-store-shared 绕过 register file | A100 SM；与 V100 的相对比较 | `FIELD-COMP-DATAFLOW-RESIDENCY`、`FIELD-COMP-SHARED-RESOURCE`、`FIELD-MEM-DMA` | 重复但图示更紧凑。白皮书已经给出 32-thread sharing、指令和寄存器访问减少、异步 copy 及 register-file bypass。这里的 `6` 和 `2` 是该数据供给路径的访问次数，不是通用端口数或每周期带宽 |
| MEM-01 | PDF p.3，印刷 p.31：L2 是 SM 共享资源，分为两个 partition；每个 partition 服务直接相连的 SM，硬件 cache coherence 在 full GPU 上维持 CUDA programming model | A100 L2；两个 partition 不是两个软件可见独立内存池 | `FIELD-MEM-INSTANCE-COUNT`、`FIELD-MEM-LOCALITY-SCOPE`、`FIELD-MEM-CONSISTENCY`、`FIELD-MEM-POOLING-MODE` | 重复。白皮书有相同表述，并进一步给出 slice、read byte/cycle 和 MIG group。本文有助于防止把两个 partition 错记成可独立分配容量，但不增加新的数值 |
| MEM-02 | PDF p.4，印刷 p.32：L2 residency control 通过 address-based window 或 per-memory-operation control 影响 replacement policy；normal/streaming access 只在 persistent 区未占用时使用 set-aside | A100 L2；未给 CUDA 版本、1/16 粒度，也未提醒 MIG mode 禁用 set-aside | `FIELD-COMP-DATAFLOW-RESIDENCY`、`FIELD-MEM-MANAGEMENT`、`FIELD-SW-PROGRAMMING-MODEL` | 重复且限定不如白皮书。白皮书已明确 CUDA 11.0、2.5 MB/1/16 粒度和 MIG 禁用条件。正式事实应沿用白皮书的完整条件，不能因本文省略而取消 MIG 限制 |
| MEM-03 | PDF pp.4-5，印刷 pp.32-33，`A100 Compute Data Compression`：CUDA 11 API 先把 buffer 标为可压缩；写入数据由 L2 内硬件检查，只有匹配硬件算法的 pattern 才被压缩并写回；后续访问利用压缩后的带宽 | A100 L2 compression；需软件标记且效果依赖数据 pattern | `FIELD-MEM-COMPRESSION`、`FIELD-CAP-IMPLEMENTATION-DETAIL`、`FIELD-CAP-LIMITATION`、`FIELD-SW-PROGRAMMING-MODEL`、`FIELD-SW-SUPPORT-MATURITY` | 新增，是本文最明确的不可替代贡献。白皮书支持 Compute Data Compression 的存在和上限，但本轮基线没有给出 API 标记、L2 内检查和 pattern-gated 压缩链。本文只能证明 `documented_supported`，没有算法、压缩粒度、解压路径、最坏情形或可运行验证 |
| MEM-04 | PDF p.4，印刷 p.32：40 GB HBM2 位于 SXM4-style circuit board，5 个 active stack，每 stack 8 个 memory die，1215 MHz DDR，1555 GB/s | A100 SXM4 board/product configuration | `FIELD-PHY-HBM-STACKS`、`FIELD-PHY-FORM-FACTOR`、`FIELD-PHY-CLOCK`、`FIELD-MEM-CAPACITY`、`FIELD-MEM-READ-BW` | 重复，并进一步确认这些值属于 SXM4 板级实现。它不能证明 full GA100 只有 5 个 HBM site，也不能把 1555 GB/s 写成裸片内部带宽。Figure 6 标出多处 HBM 边缘区域，但不能据图建立 stack 数值 |
| INT-01 | PDF p.5，印刷 p.33：NVLink3 为每 signal pair 50 Gb/s，每方向 4 个 differential pair，单 link 每方向 25 GB/s；A100 为 12 link、600 GB/s total；write 需要 destination acknowledgement，并有 link-level error detection、packet replay、specific execution-context attribution，以及 small-payload write 和 dataless-response 优化 | NVLink3 link mechanism 与 A100 link configuration；600 GB/s 是 12×25×2 的双向聚合 | `FIELD-INT-PROTOCOL`、`FIELD-INT-PER-LINK-RATE`、`FIELD-INT-LANE-COUNT`、`FIELD-INT-LINK-COUNT`、`FIELD-INT-AGGREGATE-BW`、`FIELD-INT-FAULT`、`FIELD-RAS-ERROR-DETECTION`、`FIELD-RAS-CORRECTION-REPLAY` | 重复。白皮书已有同样的 link-level mechanism 和产品数值。本文的 `guarantee successful transmission` 是厂商措辞，正式事实只记录 detection/replay/acknowledgement 机制，不扩大为端到端无故障保证 |
| INT-02 | PDF pp.1、6，印刷 pp.29、34：概览把 MIG 称作 elastic GPU 的 `scale-out support`，后文实际描述的是单个 A100 内的 GPU Instance 分区 | A100 virtualization/product positioning | `FIELD-VIRT-PARTITIONING`；不对应 `FIELD-INT-TOPOLOGY` | 更清楚限定，也暴露出术语风险。本文的 `scale-out` 是资源供给和多实例的营销语境，不能据此把 MIG 登记为芯片间 scale-out 拓扑、All-to-All 或网络能力 |
| VIRT-01 | PDF p.6，印刷 p.34：最多 7 个 GPU Instance；每个 instance 独占 SM 到 crossbar port、L2 bank、memory controller 和 DRAM address bus 的路径，宣称 predictable throughput/latency、defined QoS 和 fault isolation | A100 enabled MIG configuration；最多 7 个来自 A100 的启用 GPC/slice 配置 | `FIELD-VIRT-PARTITIONING`、`FIELD-VIRT-MULTI-TENANCY`、`FIELD-VIRT-PREEMPTION-QOS`、`FIELD-RAS-FAULT-ISOLATION` | 重复。白皮书有相同表述，并补充 GPU Slice、Compute Instance、Sys Pipe 和 context switch。`predictable`、`same allocation` 和 `defined QoS` 是定性厂商声明，没有给误差范围、调度策略或持续带宽测量 |
| SW-01 | PDF p.6，印刷 p.34：用户可以把 MIG GPU Instance 当作 physical GPU 查看并调度作业；MIG 与 Linux 和 hypervisor 配合 | A100 MIG 软件绑定；未给 Linux、driver、hypervisor 或 MIG 版本 | `FIELD-VIRT-MULTI-TENANCY`、`FIELD-SW-PROGRAMMING-MODEL`、`FIELD-SW-SUPPORT-MATURITY` | 重复。它证明文档级软件集成语境，不证明芯片有作业放置算法、硬件 job queue 或 request scheduler，因此不应单独填写 `FIELD-SW-CHIP-BOUND-SCHEDULING` |
| SW-02 | PDF pp.6-7，印刷 pp.34-35，Figure 8-9：异步 barrier 将 arrival 和 wait 分开；`cuda::barrier` 与 `cuda::memcpy_async` 代码展示 copy、barrier 与 independent work 的重叠；相关 barrier 思路进入 ISO C++20，并称已有 LLVM `libcxx` 实现 | CUDA/A100 hardware-software co-design；代码为说明例，不是 benchmark | `FIELD-COMP-CONTROL-SCHEDULING`、`FIELD-MEM-DMA`、`FIELD-SW-PROGRAMMING-MODEL`、`FIELD-SW-COMPILER`、`FIELD-SW-SUPPORT-MATURITY` | 机制重复，标准化语境略有新增。白皮书已经给出 hardware-accelerated barrier、arrival/wait、CUDA 11 和 global-to-shared async copy。ISO C++20 与 `libcxx` 说明标准和库背景，不等于任意 LLVM/libcxx 程序可在 A100 上运行，也不构成 runnable verification |
| RAS-01 | PDF pp.5-6，印刷 pp.33-34：RAS 只涉及 NVLink detection/replay/acknowledgement 和 MIG fault isolation | NVLink link 与 A100 MIG | `FIELD-RAS-ERROR-DETECTION`、`FIELD-RAS-CORRECTION-REPLAY`、`FIELD-RAS-FAULT-ISOLATION` | 重复且覆盖更窄。本文没有 ECC、计算路径保护、silent-data-error detection、telemetry、BIST、reset、degradation、checkpoint 或 restart。不能用 `resiliency` 或 `fault isolation` 概括为全芯片 RAS |
| BENCH-01 | PDF pp.1-2，印刷 pp.29-30，Figure 1-2：HPC 和 MLPerf v0.7 相对 V100 的 speedup，并写 `normalized to per chip` | Figure 1 为多应用相对结果；Figure 2 段落主语是 DGX SuperPOD，缺系统配置、软件、精度和完整 benchmark 条件 | 条件化 benchmark 字段；若使用必须建立完整 `condition_set_id` | 筛除。图中没有足够条件，且 Figure 2 把系统结果按芯片数归一化，不能转成 GA100 die 固定性能或独立单芯片实测。它们只说明厂商的产品定位和 strong-scaling 叙事 |

## 可新增的候选事实

在白皮书已完成精读的前提下，本文只有一组内容值得新建来源断言，且应保持 A100 实现作用域：

| 候选事实 | 原文定位 | 主体和条件 | 字段与建议状态 |
|---|---|---|---|
| Compute Data Compression 需要软件先用 CUDA 11 API 把 buffer 标为可压缩 | PDF p.4，印刷 p.32，`A100 Compute Data Compression` | A100 L2；CUDA 11 文档支持 | `FIELD-MEM-COMPRESSION`、`FIELD-SW-PROGRAMMING-MODEL`；`documented_supported` |
| 数据写入后由 L2 内硬件检查，只有匹配硬件算法的 pattern 才压缩并写回 | PDF pp.4-5，印刷 pp.32-33，同一节跨页 | A100 L2 compression；pattern-dependent | `FIELD-CAP-IMPLEMENTATION-DETAIL`、`FIELD-CAP-LIMITATION`；不要推断算法、粒度、压缩率下界或解压位置 |
| 后续 read 和 write 可利用已压缩数据，提高有效 DRAM 带宽 | PDF p.5，印刷 p.33，段首续文 | A100，只有数据实际匹配并被压缩时成立 | `FIELD-MEM-COMPRESSION`；不把 `up to 4×` 当作持续带宽保证 |

Figure 6 的标注裸片图可以附在对象边界审计中，但不建议仅为它新建正式数值事实。ISO C++20 和 LLVM `libcxx` 是软件标准化背景；如资料卡只记录 CUDA 11 与硬件 barrier/copy 的绑定，它们没有必要单独入库。

## 被筛除的内容和理由

本文大部分内容是 A100 白皮书的七页压缩版。Tensor Core 格式与峰值、32-thread data sharing、异步 global-to-shared copy、L2 两分区与 coherence、residency control、NVLink3、MIG 和异步 barrier 均有白皮书的同等或更完整定位。重复断言不会因为载体改成 IEEE 期刊而成为独立第三方证据。

Figure 1-2 的 HPC/MLPerf 相对结果缺完整测试条件；Figure 3 是 strong-scaling 概念图；Figure 7 是 DGX A100 系统；Figure 8-9 是代码说明例。它们都不产生 GA100 die 的无条件规格。文中的 DNN 规模、low batch inference、SMEM bandwidth demand、系统扩展和客户利用率属于工作负载或系统语境，不能注册成芯片属性。

## 最小来源集建议

本文有一项相对白皮书基线的局部不可替代贡献：它把 A100 Compute Data Compression 的软件触发、L2 内硬件检查、pattern 匹配和写回流程连成了可定位的实现链，并明确显示该能力受数据 pattern 限制。ISSCC 候选来源仍由另一工作包独立裁决；如果其最终阅读结果覆盖同一条 API 到硬件处理链，本文的不可替代性需要重新判断。

基于当前来源集，建议把本文纳入 GA100 工作包的候选最小集，角色限定为 `compression_mechanism_detail` 或 `software_binding_detail`，不承担 GA100 die 身份、物理规格、独立交叉确认或 benchmark 角色。正式反向移除时，只有资料卡确实保留上述压缩触发与 pattern 限制，本文才应存活；若后续固定版 CUDA Programming Guide 或更强的一手压缩文档覆盖同一链条，应移除本文。即使本文最终入选，它仍是 NVIDIA 作者的一手文章，和 NVIDIA 白皮书、ISSCC 论文不构成厂商独立性上的第三方确认。

## 交接和未决项

本轮没有发现需要登记为 `conflicting_unresolved` 的数值冲突。54B/54.2B 和 1.6 TB/s/1555 GB/s 通过舍入可解释；A100 108 SM、5 active HBM stack、40 MB L2、12 NVLink 与白皮书中的 full GA100 资源表述存在对象和启用状态差别，不能通过选一个数值消除。

仍待总控或后续来源处理的事项是：先冻结 GA100 die 与 A100 enabled configuration 的正式关系；再决定 Compute Data Compression 事实挂到 A100 实现、GA100 组件还是 Ampere capability。若没有明确关系，本文新增的压缩断言应停留在 A100 作用域，不得直接写入 GA100 die。

本轮写入文件为：

- `审计/子代理交接/r1_ga100_04_ieee_micro_differential_reading.md`
- `审计/子代理交接/r1_ga100_04_ieee_micro_differential_reading_assets/page-1.png` 至 `page-7.png`
- `审计/子代理交接/r1_ga100_04_ieee_micro_differential_reading_assets/article_layout.txt`

验证：`report-humanizer` 机器扫描没有发现可检测的 AI 套路。人工逆向复读检查了标题、各节首段、表格引导、结尾和重复句式；没有发现需要再改的模板化措辞。剩余风险是 ISSCC 独立阅读包尚未完成交叉比较，因此最小集结论保留反向移除条件。
