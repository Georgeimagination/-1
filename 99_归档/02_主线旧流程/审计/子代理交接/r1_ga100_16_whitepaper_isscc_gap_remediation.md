# GA100 v3：白皮书与 ISSCC 来源级缺口补救

> 输入：`r1_ga100_15_atomic_v2_independent_review.md` 与 `r1_ga100_14_atomic_staging_v2/` 中的字段要求  
> 固定来源：`SRC-M2NA-NVIDIA-AMPERE-WP-2020`、`SRC-NVIDIA-A100-ISSCC-2021`  
> 写入边界：本轮只新增这份审计报告，未改正式数据、v2 候选、资料卡或进度

## 裁决摘要

两份核心来源能把 49 条 `pending_verification` 中的 23 条推进为有值，3 条判为 `not_applicable`，其余 23 条仍需其他来源。`pending` 在这里表示明确的后续来源待办，不能进入发布 manifest；v3 发布前仍须把它们收敛到 `value`、`not_found`、`not_public` 或 `not_applicable`。

最重要的修正有四项。第一，full GA100 的 HBM 总接口可以由白皮书 p.19 的 12 个、每个 512-bit memory controller 明示为 `public_derived`：`12 × 512 = 6144 bit`；不能把 A100 Table 4 的 5120-bit 产品值下放。第二，Figure 6 显示 full GA100 有 12 个 NVLink 物理接口，结合白皮书 p.52 的每链路 4 lane、25 GB/s/方向，可明确得到 300 GB/s/方向和 600 GB/s 双向聚合，但必须保留“12 条均启用、vendor nameplate”条件。第三，Tensor Core 的 16×8×16 是 warp-level instruction tile，不是物理阵列形状；`FIELD-COMP-INSTRUCTION-TILE` 可有值，`FIELD-COMP-ARRAY-SHAPE` 仍是 `not_found`。第四，A100 的 1.41 GHz、400 W 和整卡/整 GPU TOPS 都不能写给 full GA100；clock、power 和 vendor AI TOPS 对裸片在概念上适用，因此状态是 `not_found`，不是 `not_applicable`。

两份来源没有出现“厂商明确不公开”的表述，所以本轮不建议任何字段使用 `not_public`。仅仅未检出数值，应在计划来源已经查完后用 `not_found`；若还有明确的下一类来源，则保持 `pending`。

## 来源核对与对象边界

`SRC-M2NA-NVIDIA-AMPERE-WP-2020` 对应固定 PDF `论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf`，82 页，SHA-256 为 `3a800ad7668ec37037fa5870a8e3bb681b75f19668b3d11492ab9b0da0d58815`。本轮对全文抽取文本重新做关键词检索，并视觉复核 p.14、17、19、20、28、34-39、43、45、47、48、51、52、56、58、63、73 等与缺口直接相关的页面、表格和框图。

`SRC-NVIDIA-A100-ISSCC-2021` 对应固定 PDF `论文/NVIDIA_GPU/01_厂商直接架构论文/2021_A100_Datacenter_GPU_Ampere_ISSCC.pdf`，3 页，SHA-256 为 `55765d2680678ba46045da1902496ddd3995d5964a5f0ef68a99362e2c43b601`。三页均重新渲染并逐页视觉核对；PDF p.1 对应印刷 p.48，PDF p.2 对应印刷 p.49，PDF p.3 为 continuation 页。

白皮书 p.19 是本轮的主边界锚点：full GA100 是 128 SM、8192 FP32 CUDA core、512 Tensor Core、12 个 512-bit memory controller；A100 enabled implementation 是 108 SM、6912 core、432 Tensor Core、10 个 512-bit controller 和 5 个 active HBM stack。白皮书 pp.36-37 的 1410 MHz、5120-bit HBM2、40 GB、1555 GB/s 和 400 W，以及 ISSCC p.1/p.2 的 108 SM、40 MB L2、1.41 GHz、1.56 TB/s 和产品峰值，全部属于 A100 配置或其封装/模组语境。

## 49 条 pending 的逐项建议

以下每个字段都同时检查了两个固定 source_id：表内“白皮书”严格指 `SRC-M2NA-NVIDIA-AMPERE-WP-2020`，“ISSCC”严格指 `SRC-NVIDIA-A100-ISSCC-2021`，“两源”指这两个 source_id 的并集。定位列只列实际命中、容易误判或足以排除的页码；某一来源未列具体页码时，表示其全文检索没有增加该字段的支持。

### 身份、物理、benchmark 与 RAS checkpoint

| requirement / 目标 | 建议状态 | 实际检查的来源与定位 | 命中、排除理由和对象边界 |
|---|---|---|---|
| `REQ-R1-GA100-ID-AVAIL`；`OBJ-NVIDIA-GA100-DIE / FIELD-ID-AVAILABILITY-DATE` | `pending` | 两源全文检索 `availability date`、`available`；白皮书 p.17、p.53 的 `availability` 都指系统 uptime，ISSCC 无 GA100 供货日期 | 文档出版或 A100 产品出现不能替代 GA100 die 的首次可用日期。下一步应查固定的 NVIDIA 发布/供货公告。 |
| `REQ-R1-GA100-ID-DATA-CUTOFF`；`OBJ-NVIDIA-GA100-DIE / FIELD-ID-DATA-CUTOFF` | `not_applicable` | 两源无需提供；独立复核已要求从 141-field 迁移到 140-field | 这是资料卡生命周期元数据，不是厂商事实。v3 不应再为裸片建立外部证据要求。 |
| `REQ-R1-GA100-ID-STATUS`；`OBJ-NVIDIA-GA100-DIE / FIELD-ID-STATUS` | `pending` | 两源全文检索 `status`、`lifecycle`、`end of support`，没有对象级命中 | “历史锚点”是项目范围状态，不是产品生命周期。需另查官方支持或生命周期来源。 |
| `REQ-R1-GA100-PHY-DIE-COUNT`；`OBJ-NVIDIA-GA100-DIE / FIELD-PHY-DIE-COUNT` | `not_applicable` | 白皮书 pp.19-20 描述 full GA100；ISSCC PDF p.3 Figure 3.2.7 是单张 `A100 die photo` | 当前主体本身就是一个 die，而不是承载若干 die/chiplet 的 package。不得从单张 die photo 推出一个 package-level `1`。 |
| `REQ-R1-GA100-PHY-HBM-INTERFACE`；`OBJ-NVIDIA-GA100-DIE / FIELD-PHY-HBM-INTERFACE` | `value` | `SRC-M2NA-NVIDIA-AMPERE-WP-2020`，p.19，`full implementation` 列出 12 个 512-bit memory controller；p.20 Figure 6 视觉核对 6 组 HBM/controller 边缘接口 | 建议值 `6144 bit`，evidence type 必须是 `public_derived`，公式和两个直接输入均入条件。A100 pp.36-37 的 `5120-bit HBM2` 是 10-controller enabled 产品值；6 个 HBM stack 仍属于封装，不挂 die。 |
| `REQ-R1-GA100-RAS-CKPT`；`OBJ-NVIDIA-GA100-DIE / FIELD-RAS-CHECKPOINT-RESTART` | `pending` | 白皮书 p.52 `MIG Migration`：vGPU/GPU-slice state 可保存并恢复到相同 slice 数的另一 GPU Instance；ISSCC 未写 checkpoint/restart | 这是厂商描述的 MIG migration 流程，但白皮书没有软件版本、交付状态、停机/一致性条件，也不证明通用芯片 checkpoint。应由固定 MIG/vGPU 文档决定是否形成条件化 value。 |
| `REQ-R1-GA100-V2-BENCH-LATENCY`；`OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-LATENCY` | `pending` | 白皮书 p.14 Figure 5、ISSCC PDF p.2 Figure 3.2.4；全文检索 `latency` | 两图给 A100 对 V100 的相对 speedup，不给秒级延迟。ISSCC 对 NVLink 的 `tens of nanoseconds` 是相对 FEC 节省量，也不是 workload latency。需查条件完整的 A100/GA100 microbenchmark。 |
| `REQ-R1-GA100-V2-BENCH-THROUGHPUT`；`OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-THROUGHPUT` | `pending` | 白皮书 p.14 Figure 5；ISSCC PDF p.1 右栏及 p.2 Figure 3.2.4，关键词 `MLPerf v0.7`、`per chip`、`speedup` | 结果主体是 A100 产品或系统，且缺绝对吞吐、完整软件/精度/batch/功耗条件。相对 speedup 不能填入 GA100 die 的实测吞吐。 |
| `REQ-R1-GA100-V2-ID-DEPLOYMENT`；`OBJ-NVIDIA-GA100-DIE / FIELD-ID-DEPLOYMENT` | `pending` | 白皮书 p.52 的 DGX A100、ISSCC PDF p.2 Figure 3.2.6 | 两处都是 A100/NVSwitch 系统部署。它们证明上层系统使用 A100，不是 standalone GA100 die 的公开部署记录。 |
| `REQ-R1-GA100-V2-ID-DESIGN-OBJECTIVE`；`OBJ-NVIDIA-GA100-DIE / FIELD-ID-DESIGN-OBJECTIVE` | `value` | 白皮书 p.38 `Strong Scaling Deep Learning Performance`；ISSCC PDF p.1 左栏末，固定规模 NN 的 strong-scaling 目标 | 建议保存“面向 fixed-size neural networks 的 strong scaling，并改善 Tensor Core feed efficiency”。这是 Ampere 架构目标，经批准的 `implements_architecture` 关系投影到 GA100；不要把 batch size 注册为芯片属性，也不要把 2.5× 相对目标改成绝对性能。 |
| `REQ-R1-GA100-V2-ID-MARKET-ACCESS-CONSTRAINT`；`OBJ-NVIDIA-GA100-DIE / FIELD-ID-MARKET-ACCESS-CONSTRAINT` | `pending` | 两源全文检索 `region`、`export`、`market access`、`country`，无日期与地区绑定的命中 | 架构白皮书和 ISSCC 论文不是销售/出口合规来源。需要地区、有效日期和具体对象均明确的官方材料。 |
| `REQ-R1-GA100-V2-ID-RELEASE-DATE`；`OBJ-NVIDIA-GA100-DIE / FIELD-ID-RELEASE-DATE` | `pending` | 白皮书全文 `release` 仅在 p.58 命中 CUDA 10 release；ISSCC 的 2021 session 日期是论文发表时间 | 白皮书 PDF 创建/版本日期、ISSCC 会议日期和 A100 announcement 都不能静默改写成 GA100 die 首次发布日期。需查正式产品发布页并保留对象映射。 |
| `REQ-R1-GA100-V2-ID-TARGET-USE-POSITIONING`；`OBJ-NVIDIA-GA100-DIE / FIELD-ID-TARGET-USE-POSITIONING` | `pending` | 白皮书 p.14 将 A100 定位于 cloud/data-center AI、HPC、data analytics；p.19 写 GA100 powers A100；ISSCC PDF p.1 列 A100 workload | 现有句子是 A100 产品定位，`powers A100` 只建立硅设计关系。若 v3 允许经产品关系投影，可形成条件化值；在投影规则批准前，不直接下放给 full GA100。 |
| `REQ-R1-GA100-V2-ID-VENDOR-POSITIONING`；`OBJ-NVIDIA-GA100-DIE / FIELD-ID-VENDOR-POSITIONING` | `pending` | 同上：白皮书 p.14、p.19；ISSCC PDF p.1 标题与 opening paragraph | 有清楚的 A100 vendor wording，没有独立的 full-GA100 die 市场定位句。应先决定产品定位能否沿 `A100 implementation of GA100` 关系投影。 |

### 计算结构与派生字段

| requirement / 目标 | 建议状态 | 实际检查的来源与定位 | 命中、排除理由和对象边界 |
|---|---|---|---|
| `REQ-R1-GA100-V2-COMP-CONCURRENCY`；`COMP-R1-GA100-SM / FIELD-COMP-CONCURRENCY` | `value` | 白皮书 p.34，`Simultaneous Execution of FP32 and INT32 Operations` | A100 SM 有独立 FP32 与 INT32 core，可同时以 full throughput 执行；例子是 FP32 计算与 INT32 地址计算重叠。只覆盖这两条路径，不推出 Tensor Core、FP64、LD/ST 或全 SM 同时达峰。 |
| `REQ-R1-GA100-V2-COMP-DATAFLOW-RESIDENCY`；`COMP-M2NA-AMPERE-TENSOR / FIELD-COMP-DATAFLOW-RESIDENCY` | `value` | 白皮书 p.38 data sharing、p.39 Figure 14 与 async copy；ISSCC PDF p.1 左栏第 3 段、p.2 Figure 3.2.3 | 可记录 32-thread warp operand sharing、较少 SMEM/RF 访问，以及 global-to-shared async copy 绕过 RF；Figure 3.2.3 caption 另写绕过 L1。它们是特定数据复用和搬运机制，不是通用 Tensor residency policy。 |
| `REQ-R1-GA100-V2-COMP-INSTRUCTION-TILE`；`PPATH-M2NA-AMPERE-TENSOR-FP16 / FIELD-COMP-INSTRUCTION-TILE` | `value` | 白皮书 p.39 Figure 14 | 建议值为 `16×8×16 warp-level Tensor Core instruction tile`。图中 16×16×16 matrix multiply 由两条 lower-level hardware instruction 完成；不要把 16×8×16 写成 Tensor Core 物理阵列。 |
| `REQ-R1-GA100-V2-COMP-UTILIZATION-LIMIT`；`COMP-R1-GA100-TENSOR / FIELD-COMP-UTILIZATION-LIMIT` | `value` | 白皮书 p.38 strong-scaling 段；ISSCC PDF p.1 左栏第 3-4 段 | 可记录 vendor-design constraint：固定规模 GEMM 被拆到更多 SM 后，每 SM tile 不增长，而 A100 Tensor Core 的数据消耗比 V100 更快，喂数和可用并行度成为限制。该值是定性限制，不是实测利用率，也不等于所有小矩阵都低效。 |
| `REQ-R1-GA100-V2-DER-CAPACITY-COMPUTE`；`OBJ-NVIDIA-GA100-DIE / FIELD-DER-CAPACITY-COMPUTE` | `pending` | 白皮书 p.19 full-design compute，p.35 的 40 GB HBM2 是 A100 SXM4；ISSCC 的 HBM2 值同为 A100 | full GA100 的同对象 memory capacity 缺失，不能用 A100 module HBM 容量与 full-design compute 相除。 |
| `REQ-R1-GA100-V2-DER-COMPUTE-BW-SPEC`；`OBJ-NVIDIA-GA100-DIE / FIELD-DER-COMPUTE-BW-SPEC` | `pending` | 白皮书 p.20 给 per-SM FMA/clock，pp.35-37 给 A100 HBM bandwidth/boost clock；ISSCC p.1 给 A100 产品峰值 | 没有同一 full-GA100 对象、频率、precision path 和 nameplate bandwidth 的完整输入链。 |
| `REQ-R1-GA100-V2-DER-COMPUTE-BW-SUSTAINED`；`OBJ-NVIDIA-GA100-DIE / FIELD-DER-COMPUTE-BW-SUSTAINED` | `pending` | 白皮书/ISSCC 的存储与互联带宽均为 vendor nameplate 或相对提升 | 两源没有 GA100 die sustained bandwidth；不得把 1555 GB/s、1.56 TB/s 或压缩上限当 sustained 值。 |
| `REQ-R1-GA100-V2-DER-INTERCONNECT-COMPUTE`；`OBJ-NVIDIA-GA100-DIE / FIELD-DER-INTERCONNECT-COMPUTE` | `pending` | NVLink 输入可由白皮书 pp.20、52 关闭；compute 聚合值仍只有 108-SM A100，见 pp.36-37 和 ISSCC Figure 3.2.2 | interconnect 一侧有同对象候选，compute 一侧仍缺 full-design clock/aggregate peak，暂不能派生比值。 |
| `REQ-R1-GA100-V2-DER-MOVE-MATRIX`；`OBJ-NVIDIA-GA100-DIE / FIELD-DER-MOVE-MATRIX` | `pending` | 白皮书 p.39 仅有示例寄存器访问与周期，p.35 的 5120 B/clk 是 A100 L2；ISSCC 只给相对 data-BW pressure | 没有同一作用域、方向和 traffic basis 的 movement 值与 matrix throughput 值。示例访问次数不能充当全芯片 movement bandwidth。 |

### NVLink interface

| requirement / 目标 | 建议状态 | 实际检查的来源与定位 | 命中、排除理由和对象边界 |
|---|---|---|---|
| `REQ-R1-GA100-V2-INT-AGGREGATE-BW`；`LINK-R1-GA100-NVLINK-INTERFACE / FIELD-INT-AGGREGATE-BW` | `value` | 白皮书 p.20 Figure 6、p.52 `Third-Generation NVLink`；ISSCC PDF p.1 右栏及 p.2 Figure 3.2.6 | 建议 `600 GB/s`，`direction=bidirectional_aggregate`，`traffic_basis=vendor_nameplate`，条件为 12 links 均启用。它等于 `12 × 25 GB/s × 2`；不是单向注入，也不是 DGX 系统总带宽。 |
| `REQ-R1-GA100-V2-INT-INJECTION-BW`；同一 link / `FIELD-INT-INJECTION-BW` | `value` | 同上；ISSCC 明写 300 GB/s each direction | 建议 `300 GB/s per direction per device`，条件为 12 links。不要把双向 600 GB/s 填入 injection 字段。 |
| `REQ-R1-GA100-V2-INT-LANE-COUNT`；同一 link / `FIELD-INT-LANE-COUNT` | `value` | 白皮书 p.52：每 link 每方向 4 个 differential signal pair，并括注 4 lanes | 建议 `4 lane per direction per link`。不要把收发两向相加成 8，也不要把 50 Gbit/s/lane 误作完整 link rate。 |
| `REQ-R1-GA100-V2-INT-LINK-COUNT`；同一 link / `FIELD-INT-LINK-COUNT` | `value` | 白皮书 p.52 明写 A100 total links 为 12；p.20 full GA100 Figure 6 有 12 个 NVLink 标签；ISSCC PDF p.1 也写 links/GPU 增至 12 | 建议 `12 links/device`。p.20 解决 full-design 边界，p.52/ISSCC 解决逻辑名称和 A100 启用情况。 |
| `REQ-R1-GA100-V2-INT-PER-LINK-RATE`；同一 link / `FIELD-INT-PER-LINK-RATE` | `value` | 白皮书 p.52：50 Gbit/s per signal pair、4 pair/方向、25 GB/s/link/方向；ISSCC PDF p.1 的 50 Gbps 是 LR differential-interface raw bitrate | 规范值建议 `200 Gbit/s per direction per logical link`，由 `4 × 50 Gbit/s` 明示推导，`traffic_basis=raw_line_rate`；来源原文的 25 GB/s/方向另作 vendor-nameplate 交叉检查。LR-PHY 的 50 Gbit/s 不能单独填成 link rate。 |
| `REQ-R1-GA100-V2-INT-PHYSICAL-LINK-COUNT`；同一 link / `FIELD-INT-PHYSICAL-LINK-COUNT` | `value` | 白皮书 p.20 Figure 6，full GA100 图底部 12 个独立 NVLink block 标签 | 建议 `12 physical interfaces`，evidence type 为 figure direct/count。它不创建 device topology，也不说明外部连到哪些 peer 或 switch。 |

NVLink 的 link 事实与 topology 必须分开。`TOPO-R1-GA100-NVLINK-GAP` 不是公开实体，它承接的 bisection、degree、hops、max scale、oversubscription、topology、dimensions、node count 和 routing 九条要求都应对当前假 target 判 `not_applicable` 并删除。白皮书 p.52 只说 12 links 可组成多种配置，随后描述 DGX A100；ISSCC PDF p.2 Figure 3.2.6 也是 8×A100+6×NVSwitch 系统。两处都不能制造一个“GA100 die topology”。

### 存储、可靠性、软件与虚拟化

| requirement / 目标 | 建议状态 | 实际检查的来源与定位 | 命中、排除理由和对象边界 |
|---|---|---|---|
| `REQ-R1-GA100-CAP-GAP-COMPRESSION`；`CAP-R1-GA100-GAP-COMPRESSION / FIELD-CAP-IMPLEMENTATION-DETAIL` | `not_applicable` | 白皮书 p.35、p.41；ISSCC PDF p.1 左栏末 | 当前 capability ID 是 coverage placeholder，应删除；但真实机制并不缺失。白皮书直接把 Compute Data Compression 归于 Ampere architecture，ISSCC 说明 A100/GA100 实现中的 activation/DRAM/L2 压缩。应在真实 Ampere/L2 mechanism target 上建立 value，不新造本体 ID。 |
| `REQ-R1-GA100-V2-MEM-COMPRESSION`；`COMP-R1-GA100-L2 / FIELD-MEM-COMPRESSION` | `value` | 白皮书 p.35、p.41；ISSCC PDF p.1 左栏末 | 可记录对 unstructured sparsity 与其他 compressible patterns 的 Compute Data Compression；4× DRAM R/W、4× L2 read、2× effective L2 capacity 都是 vendor `up to`，不可乘到基础带宽/容量，也不同于 2:4 Sparse MMA。 |
| `REQ-R1-GA100-V2-MEM-CONSISTENCY`；`COMP-R1-GA100-L2 / FIELD-MEM-CONSISTENCY` | `value` | 白皮书 p.35；ISSCC PDF p.1 左栏末 | 硬件 cache coherence 在 full-GPU 范围维持 CUDA programming model。建议条件为 full-GPU/non-partitioned view；来源没有公开 coherence protocol、原子范围或 MIG 跨实例一致性。 |
| `REQ-R1-GA100-V2-MEM-GRANULARITY`；`COMP-R1-GA100-L1SMEM / FIELD-MEM-GRANULARITY` | `pending` | 白皮书 p.22 Figure 7、pp.33-34、pp.61-63；ISSCC Figure 3.2.3 | 来源给 combined L1/shared、async copy 路径和 instruction example，没有 L1/shared transaction size、cache-line size 或 bank access granularity。L2 residency 的 2.5 MB set-aside 粒度不属于该 L1SMEM target。 |
| `REQ-R1-GA100-V2-MEM-LATENCY`；`COMP-R1-GA100-L2 / FIELD-MEM-LATENCY` | `pending` | 白皮书 p.35 只写 lower latency；ISSCC p.1 只写 partitioning lowers latency | 没有 cycle 或 second 数值，也没有 L2 clock domain。第三方 cycle 测量需另作完整 product/clock 条件。 |
| `REQ-R1-GA100-V2-MEM-POOLING-MODE`；`COMP-R1-GA100-L2 / FIELD-MEM-POOLING-MODE` | `value` | 白皮书 p.35：L2 为 GPC/SM shared resource、位于 GPC 外、分成两个 partition，并在 full GPU 维持 coherence | 建议枚举 `logically_shared_distributed`。它不是每 GPC private cache，也不是一个未分区的物理池；MIG 下还会按 GPU Instance 切分，须另设条件。 |
| `REQ-R1-GA100-V2-MEM-READ-TRANSFER-PER-CYCLE`；`COMP-R1-GA100-L1SMEM / FIELD-MEM-READ-TRANSFER-PER-CYCLE` | `pending` | 白皮书 p.35 的 `5120 Bytes/clk` 明确是 A100 L2 read；p.39 的寄存器访问数是 16×16×16 Tensor example | 两个数字都不是 L1/shared 每周期读传输量。不能跨 component 搬用，也不能从 instruction example 反推 memory-port contract。 |
| `REQ-R1-GA100-V2-MEM-USABLE-CAPACITY`；`COMP-R1-GA100-L1SMEM / FIELD-MEM-USABLE-CAPACITY` | `value` | 白皮书 pp.36-37 Table 4、p.43 Table 5 | 建议保留原文 `shared memory configurable up to 164 KB per SM`，条件为 GA100/A100 Compute Capability 8.0；它是 software-visible maximum，不与 192 KB combined physical L1/shared capacity 相加。若规范化为 byte，须沿用项目对 KB 的既定换算并保存原文。 |
| `REQ-R1-GA100-V2-MEM-VIRTUAL-MEMORY`；`COMP-R1-GA100-L2 / FIELD-MEM-VIRTUAL-MEMORY` | `pending` | 白皮书 p.34 CUDA memory spaces、pp.52-54 peer memory/remote page fault；ISSCC 无 virtual-memory 细节 | 这些段落证明 device/peer access 与 fault return，不给页大小、迁移语义、地址空间、oversubscription 或 L2 的虚拟内存职责。 |
| `REQ-R1-GA100-V2-RAS-ECC`；`OBJ-NVIDIA-GA100-DIE / FIELD-RAS-ECC` | `value` | 白皮书 p.35，`ECC Memory Resiliency` | 可记录 on-die L2、L1 cache 和所有 SM register file 使用 SECDED ECC。HBM2 SECDED 属于外部 memory subsystem，应拆开；来源未支持 Tensor/CUDA datapath ECC。 |
| `REQ-R1-GA100-V2-RAS-PROTECTION-SCOPE`；`OBJ-NVIDIA-GA100-DIE / FIELD-RAS-PROTECTION-SCOPE` | `value` | 白皮书 p.35 的 L2/L1/RF SECDED，p.52 的 NVLink link-level detection/replay，pp.45-48 的 MIG path isolation | 建议拆成存储、互联和 MIG isolation 三个条件化 scope，而不是写“全芯片受保护”。计算 datapath、控制状态、BIST 和 silent-data-error coverage 仍未由两源建立。 |
| `REQ-R1-GA100-V2-SW-CHIP-BOUND-SCHEDULING`；`OBJ-NVIDIA-GA100-DIE / FIELD-SW-CHIP-BOUND-SCHEDULING` | `value` | 白皮书 p.48 Sys Pipe scheduling、p.51 independent context switch；ISSCC p.1 的 OS scheduling/MIG isolation | Sys Pipe 与 host CPU 通信并把工作调度到 GPC/SM；不同 Compute Instance 可分别 context switch。数量 7 和具体 MIG profile 仍是 A100 enabled condition，不是 full GA100 固定数量。 |
| `REQ-R1-GA100-V2-SW-COMMUNICATION-LIBRARY`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-COMMUNICATION-LIBRARY` | `pending` | 白皮书 p.17 `Magnum IO`/`CUDA-X libraries`，p.52 NVLink；ISSCC 无 library/version | 来源只给平台/API 集合，没有通信库名称+版本+互联范围的完整绑定；不能把 NVLink protocol 或 Magnum IO 品牌当 NCCL 版本。 |
| `REQ-R1-GA100-V2-SW-COMPILER`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-COMPILER` | `pending` | 两源全文检索 `compiler`、`nvcc`，无版本化对象绑定 | CUDA programming model 和 PTX/ISA 的存在不等于编译器名称与版本。应由固定 CUDA Toolkit/Compiler 文档关闭。 |
| `REQ-R1-GA100-V2-SW-FRAMEWORK`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-FRAMEWORK` | `pending` | 白皮书 p.73 DGX A100 appendix 列 PyTorch、MXNet、TensorFlow，未给版本或 backend；ISSCC 无框架映射 | 这是 DGX container ecosystem，不能直接成为 Ampere architecture 的版本化 framework fact。 |
| `REQ-R1-GA100-V2-SW-OPERATOR-LIBRARY`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-OPERATOR-LIBRARY` | `value` | 白皮书 p.28：cuSOLVER in CUDA 11.0 增加对 A100 Tensor Core 新格式（包括 TF32）的支持 | 可记录 `cuSOLVER / CUDA 11.0 / A100 implementation of GA100 Tensor Core formats`。作用域不是所有 Ampere SKU，也不是通用框架支持。p.66-67 Cooperative Groups 只作补充，不把 group-wide collective 写成网络 collective offload。 |
| `REQ-R1-GA100-V2-SW-RUNTIME`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-RUNTIME` | `pending` | 白皮书 p.58 说 CUDA 11 提供 programming/API support；p.73 的 container runtime 属于 DGX；ISSCC 的 CUDA 8.0 见冲突节 | 来源没有把某个 CUDA Runtime 名称和版本明确绑定到该 architecture target。不要从 CUDA 11 platform/API 表述自动生成 runtime fact。 |
| `REQ-R1-GA100-V2-VIRT-MULTI-TENANCY`；`OBJ-NVIDIA-GA100-DIE / FIELD-VIRT-MULTI-TENANCY` | `value` | 白皮书 p.45，MIG capability 与 multi-tenant use case；ISSCC PDF p.1 右栏第 2 段 | 可记录多个 GPU Instance 并行、客户端间 QoS/fault isolation 的 vendor claim。`up to 7` 只适用于 7-GPC A100 enabled configuration。 |
| `REQ-R1-GA100-V2-VIRT-PARTITIONING`；同一 object / `FIELD-VIRT-PARTITIONING` | `value` | 白皮书 pp.45、47-48、51，Figures 21、22、25；ISSCC PDF p.1 MIG 段 | GPU Instance 配套切分 SM、crossbar、L2 slice、memory controller 和 DRAM path；Compute Instance 可继续拆分 compute。不同 instance 类型的 memory isolation 不同，不能写成一律全隔离。 |
| `REQ-R1-GA100-V2-VIRT-PREEMPTION-QOS`；同一 object / `FIELD-VIRT-PREEMPTION-QOS` | `value` | 白皮书 p.45 QoS/isolation、p.48 memory QoS、p.51 independent context switch | 可记录独立 context-switch 粒度和厂商声称的 predictable throughput/latency、QoS。来源没有给 priority policy、抢占时延或量化 QoS 保证，字段内容必须停在这些边界内。 |

## 对现有 not_found / not_applicable 的来源级修正

| requirement / 当前状态 | 建议状态 | 白皮书与 ISSCC 的实际结果 |
|---|---|---|
| `REQ-R1-GA100-COMP-VENDOR-TOPS`；当前 `not_applicable` | `not_found` | full GA100 的 vendor aggregate AI TOPS 在概念上适用。白皮书 pp.15、23、36-37 和 ISSCC PDF p.1/p.2 Figure 3.2.2 只给 108-SM、1.41 GHz A100 的 precision-specific peak/effective sparse values；不能下放，也没有 full-design clock 可推导。 |
| `REQ-R1-GA100-PHY-CLOCK`；当前 `not_found` | 维持 `not_found` | 白皮书 p.36 Table 4 的 1410 MHz 与 ISSCC p.1 的 1.41 GHz 都是 A100 product/boost condition；两源没有 full GA100 die clock 或各 clock-domain 值。 |
| `REQ-R1-GA100-PHY-POWER`；当前 `not_found` | 维持 `not_found` | 白皮书 p.37 的 400 W 是 A100 SXM4 TDP。ISSCC 全文没有 device TDP；其 `power` 只出现在 NVLink receiver 的定性节能说明。 |
| `REQ-R1-GA100-ECON-PRICE`；当前 `not_found` | 维持 `not_found` | 两源检索 `price`、`pricing`、`MSRP`、`list price`、`USD`、`dollar` 均无 bare-die 命中；`cost` 只谈服务器、MIG 或设计成本。不能用 A100 card/module 或 DGX 价格替代。 |
| `REQ-R1-GA100-V2-COMP-ARRAY-SHAPE`；当前 `not_found` | 维持 `not_found` | 白皮书 p.39 Figure 14 给 instruction tile 和示例 mapping，ISSCC Figure 3.2.2 给格式/吞吐；两者都没有 Tensor Core 物理 MAC array shape。 |
| `REQ-R1-GA100-OFA-THROUGHPUT`；当前 `not_found` | 维持 `not_found` | 白皮书 p.56 只说 GA100 Optical Flow Accelerator 是支持 optical flow/stereo disparity 的硬件模块，性能可调；没有 operation definition、format、frequency 或 throughput。ISSCC 未提 OFA。 |
| `REQ-R1-GA100-V2-INT-LATENCY`；当前 `not_found` | 维持 `not_found` | ISSCC PDF p.1 的 `tens of nanoseconds` 是相对需要 FEC 的 LR link 所节省 round-trip latency；不是绝对单跳或端到端 latency。白皮书 p.52 只写 low-latency。 |
| `REQ-R1-GA100-V2-INT-COLLECTIVE`；当前 `not_found` | 维持 `not_found` | 白皮书 p.66-67 的 group-wide collective/warp reduction 是 CUDA software abstraction 或 warp instruction；p.52 NVLink 没有 network collective offload。ISSCC 只写通信链路与 DGX system。 |
| `REQ-R1-GA100-BENCH-ENERGY`、`REQ-R1-GA100-BENCH-POWER`、`REQ-R1-GA100-BENCH-TPJ`、`REQ-R1-GA100-BENCH-UTIL`；当前均 `not_found` | 改回 `pending`，待相关来源完成后再定 | 白皮书与 ISSCC 没有 J/token、measured workload W、token/J、MFU/HFU/MBU 或 condition-complete scaling efficiency。独立复核指出既有 search 未实际检查已入池 HPEC/random-access microbenchmark；因此“两源无值”不足以形成全计划 `not_found`。 |
| `REQ-R1-GA100-RAS-BIST`、`REQ-R1-GA100-RAS-SDE`；当前 `not_found` | `pending`，本轮不背书现有闭合 | 两源支持 SECDED、NVLink replay 与 MIG isolation，但没有 BIST 或 compute-datapath SDE coverage。独立复核已指出已选 GPU Memory Error Management 来源尚未写入这两个 search closure，须由该来源阅读后裁决。 |

## 候选 factor 与假实体

11 个 `CAP-R1-GA100-GAP-*` 都不能作为公开 capability entity 保留。白皮书/ISSCC 对它们的来源级结果如下；状态左侧针对当前假 entity，右侧针对未来无 target 的 card-scope mechanism gap。

| requirement | 当前 entity-bound 状态 | 两源结果与精确排除理由 |
|---|---|---|
| `REQ-R1-GA100-CAP-GAP-COMPRESSION` | `not_applicable`；真实机制为 `value` | 白皮书 p.35/p.41 和 ISSCC p.1 明确支持 Compute Data Compression；应落到真实 Ampere/L2 mechanism，不保留 placeholder。 |
| `REQ-R1-GA100-CAP-GAP-ATTENTION-MOVE` | `not_applicable`；card-scope 两源 `not_found` | 全文无 Attention-bound movement engine。白皮书 p.39 async global-to-shared copy 是通用 SM 指令，不能改名为 Attention data movement。 |
| `REQ-R1-GA100-CAP-GAP-COLLECTIVE` | `not_applicable`；card-scope 两源 `not_found` | 白皮书 pp.52、66-67 分别是 NVLink transport 和 CUDA/warp-scope collective；都不是 network collective offload。 |
| `REQ-R1-GA100-CAP-GAP-DEQUANTIZE` | `not_applicable`；card-scope 两源 `not_found` | TF32 input conversion 与 Tensor Core datatype support 不等于 dedicated dequantization engine；两源没有相应 module/instruction。 |
| `REQ-R1-GA100-CAP-GAP-KV-CACHE` | `not_applicable`；card-scope 两源 `not_found` | 全文检索 `KV cache` 无命中；L2 residency 和 MIG memory partitioning 不是 inference KV manager。 |
| `REQ-R1-GA100-CAP-GAP-MOE-DISPATCH` | `not_applicable`；card-scope 两源 `not_found` | 全文检索 `MoE`、`mixture of experts`、`dispatch`，没有芯片绑定模块；NVLink/MIG 不能反推 MoE dispatch。 |
| `REQ-R1-GA100-CAP-GAP-MOE-ROUTE` | `not_applicable`；card-scope 两源 `not_found` | 两源没有 expert routing、token routing 或 routing table 硬件；DGX/NVLink topology 也不是 MoE route engine。 |
| `REQ-R1-GA100-CAP-GAP-QUANTIZE` | `not_applicable`；card-scope 两源 `not_found` | INT8/INT4/Binary 执行格式只证明 compute path，未证明 dedicated quantizer 或 scale/zero-point pipeline。 |
| `REQ-R1-GA100-CAP-GAP-SOFTMAX` | `not_applicable`；card-scope 两源 `not_found` | 白皮书 p.67 warp reduce 仅支持 ADD/MIN/MAX 与逻辑 reduce；不能反推出 exponent、normalization 或 Softmax unit。 |
| `REQ-R1-GA100-CAP-GAP-TOPK` | `not_applicable`；card-scope 两源 `not_found` | 两源无 Top-k/selection module；warp reduction 只给 reduce operation，不给 ranking 或 index selection。 |
| `REQ-R1-GA100-CAP-GAP-TRANSPOSE` | `not_applicable`；card-scope 两源 `not_found` | 两源的 matrix tile、shared-memory copy 和 L2 movement 没有专用 transpose/permute engine 或 instruction 陈述。 |

上述 `not_found` 只是这两份固定来源的结果。v3 的最终 card-scope closure 仍应把实际查过的 CUDA/PTX 等来源、关键词和 locator 一并写入，不能把本表复制成全计划结论。

## ISSCC 的 CUDA 8.0 冲突

ISSCC PDF p.1 左栏第 3 段把 ISO C++20 asynchronous barrier 写成由 `CUDA 8.0` 支持。白皮书 p.17 和 p.63 对同一硬件 barrier 两次写明 CUDA 11，p.58 又把第三代 Tensor Core、sparsity、MIG 和 L2 controls 归入 CUDA 11 support。对象层级无法解释这个差异；它是软件版本的直接冲突。

v3 不应采用 `CUDA 8.0` 作为 value。建议保留 ISSCC assertion 为 `conflicts`，canonical software mapping 采用白皮书反复出现的 CUDA 11，并由已固定的 CUDA 11.0 Programming Guide/API 来源完成第三源裁决。不能把 CUDA 8.0 解释成“最低版本”，也不能用 ISSCC 的同行评审身份覆盖 NVIDIA 自己的版本化软件文档。

## 可复查的全文检索痕迹

本轮对两份抽取文本实际检查了以下词组。身份组包括 `release`、`availability`、`status`、`lifecycle`、`region`、`export`；物理/性能组包括 `clock`、`MHz`、`GHz`、`TDP`、`Watt`、`TOPS`、`HBM2`、`memory interface`；互联组包括 `NVLink`、`lane`、`differential signal pair`、`topology`、`bisection`、`routing`、`collective`、`latency`；经济组包括 `price`、`pricing`、`MSRP`、`list price`、`cost`、`USD`、`dollar`；候选机制组包括 `attention`、`softmax`、`top-k`、`MoE`、`KV cache`、`quantization`、`dequantization`、`transpose`。命中的正文均回到渲染页面核对，未命中项没有用同义推断补值。

本报告是 source-reading 交接，不创建正式 fact/assertion/requirement ID，也不授权写入 v3。总控生成 v3 时，应先删除假 capability/topology target，再按本表把 23 个 value 拆成直接值、显式 `public_derived` 值和条件化投影；23 个 pending 分派给发布/生命周期、MIG/vGPU、CUDA 软件栈和 microbenchmark 等真正相关来源。

## 核验说明

`report-humanizer` 已对本文件单独扫描，结果为 `No machine-detectable AI tells found`。随后按 CUDA 冲突、candidate factor、not_found 修正、软件/虚拟化、存储/RAS、NVLink、计算、身份/物理、来源边界和开头裁决的顺序逆向复读，重新核对了 49 条 pending 的 23 value、3 not_applicable、23 pending 计数，以及 HBM 6144-bit 推导、NVLink 方向/traffic basis、A100/full-GA100 边界、benchmark/price 排除和 CUDA 8.0 冲突；未发现字段遗漏、主体倒置或结论强度前后不一致。
