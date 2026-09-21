# GA100 语义红队验收清单

> 对象：`NVIDIA GA100 die`，建议主键 `OBJ-NVIDIA-GA100-DIE`  
> 审查性质：独立先验语义检查，不审 atomic staging，也不代表正式写入通过  
> 截止日：2026-08-21

## 先给结论

GA100 工作包的主要风险来自主体混用。同一份资料经常同时谈 full GA100 design、A100 enabled implementation、A100 module/card、Ampere architecture、CUDA/PTX software target 和第三方实测设备；只要其中两层被压成一个主体，数值看起来再完整也不能验收。

正式冻结前必须先建立 `OBJ-NVIDIA-GA100-DIE implements_architecture OBJ-NVIDIA-AMPERE-ARCH`，并把 full GA100 的物理设计事实与 A100 条件值拆开。Ampere 现有 21 条正式事实不能原样下放：其中至少包括执行模型证据层错位、Tensor 格式字段误用、async copy 字段误用、sparse mechanism 误述、TF32 与 integer path 合并过度，以及缺少 operand B 和 accumulation 的问题。关系投影只能读取修复后的架构事实，不能把这些缺陷复制到 GA100。

本清单把 141 个注册字段分成 25 个 `disclosed fact`、24 个 `architecture projection`、41 个 `pending`、20 个 `not_applicable` 和 31 个 `product-conditioned lead`。这里的分类是 GA100 工作包的默认落位，不等于自动生成事实：同一个 field 可以承载不同主体的多条事实，表中只给出它在本轮最先应进入的语义通道。`product-conditioned lead` 不能靠补一个 condition set 就变成 GA100 die 事实；如果事实主语实际是 A100/A30/card/module，仍需相应上层对象或只能留在资料卡说明中。

## 五类验收口径

| 类别 | 本轮含义 | 正式写入前的门槛 |
|---|---|---|
| `disclosed fact` | 一手来源直接以 GA100/full design 为主体，或属于项目冻结所需的管理元数据 | 原子化拆分主体、值、单位和条件；图中计数必须给出图号与计数规则 |
| `architecture projection` | 事实应归 Ampere architecture、component、precision path、capability 或 NVLink link | 先修复架构事实，再通过唯一 `implements_architecture` 关系读取；不得在 die 上造同义副本 |
| `pending` | 尚无合格定值、搜索未闭合、来源冲突未解，或当前字段单位无法容纳来源值 | 本报告不授权直接写 `not_found`；完成 field-specific search log 后再决定 `not_found` 或继续待核 |
| `not_applicable` | 对 bare die 或当前关系在结构上没有意义 | 必须保留对象层级理由，不能把“没有找到”伪装成“不适用” |
| `product-conditioned lead` | 证据实际绑定 A100/A30 enabled implementation、module/card、software revision 或第三方测量条件 | 有上层主体和完整 condition set 才能转成事实；否则只保留线索、排除证据或说明文字 |

## 主体边界清单

| 主体层 | 可以进入的内容 | 不能越界的内容 |
|---|---|---|
| full GA100 physical die design | `TSMC N7`、826 mm²、54.2B transistors；8 GPC、64 TPC、128 SM、8192 FP32 CUDA Cores、512 third-generation Tensor Cores、12 个 512-bit memory controllers；GA100 SM 图中可直接数出的处理块、scheduler/dispatch、register-file bank、执行资源；192 KB unified L1/shared；Optical Flow Accelerator；full-design 图示 PCIe 4.0 x16 host interface 与 12 个 NVLink physical interfaces | 108 SM、10 个启用的 memory controllers、40 MB L2、40/80 GB HBM、1410 MHz、产品峰值、板卡功耗、MIG profile 数量、DGX/HGX 拓扑 |
| A100 enabled implementation / product | 7 GPC、108 SM、6912 FP32 CUDA Cores、432 Tensor Cores、10 个启用的 memory controllers、40 MB L2；40/80 GB HBM2/HBM2e、5 active stacks、产品带宽和峰值；SXM4/PCIe、250/300/400 W；5 NVDEC/5 NVJPG；A100 MIG profile 和 NVLink device aggregate | 不得覆盖 full GA100 的 128/12 等物理设计数；不得把 card/module 属性写成 die 属性 |
| Ampere architecture | SIMT public machine model、third-generation Tensor Core precision paths、structured sparse MMA、global-to-shared async copy、split arrive/wait barrier、L1/shared management、warp reduction、NVLink 3 mechanism | 不公开的 scheduler RTL、native opcode、Tensor Core physical array、sparse selector RTL、metadata SRAM、内部累加器和 pipeline |
| PCIe / NVLink link | PCIe 与 NVLink 分开建 link；NVLink protocol、lane/physical interface、per-link rate、error detection/replay、remote-memory semantics 和可接受的 PHY 细节放到 link 主体 | A100 设备注入带宽不等于 full-die link 数；DGX/NVSwitch 系统拓扑不下放到 GA100 die |
| CUDA/PTX software binding | 固定版本、`sm_80`/Compute Capability 8.0、documented support、experimental 标签、指令 shape 和 datatype 限制 | 文档存在不等于 `runnable_verified` 或 `benchmarked`；PTX virtual ISA 不证明物理实现 |
| 第三方实测对象 | 保留 A100 SKU、access pattern、dependency、cache operator、software、frequency、power mode、统计方法和单位 | 条件缺失时不写无条件 GA100 指标；作者推断不升级成 die 常量 |

图示计数可以是直接证据，但必须把“图中 12 个 NVLink physical interfaces”与“A100 暴露 12 条逻辑 link”分开。前者可在 `FIELD-INT-PHYSICAL-LINK-COUNT` 下作为 full-design 候选，后者仍是 product-conditioned lead。白皮书的 12×512-bit memory-controller 组织同样可以形成 12 个 controller 组件事实，但在来源没有直接给出总 HBM interface width 时，不应静默写成 6144 bit 的 `FIELD-PHY-HBM-INTERFACE`。

## 141 字段语义验收矩阵

下面的字段恰好覆盖 `数据/fields.csv` 的 141 个 `field_id`，每个字段只出现一次。分类针对 GA100 工作包的默认落位；若同一字段还承载其他主体，相关例外在后文说明。

### benchmark（6）

| 类别 | 字段 |
|---|---|
| `pending` | `FIELD-BENCH-ENERGY-PER-TOKEN`、`FIELD-BENCH-LATENCY`、`FIELD-BENCH-POWER`、`FIELD-BENCH-TOKENS-PER-JOULE`、`FIELD-BENCH-UTILIZATION` |
| `product-conditioned lead` | `FIELD-BENCH-THROUGHPUT` |

HPEC/arXiv v1 的 cycle 数不能写入 canonical unit 为 second 的 `FIELD-BENCH-LATENCY`，除非补齐频率并证明换算条件，或先修改 schema 接纳 cycle。Random-access arXiv v1 的约 64 GB cliff 和 group-to-chunk 改善可以保留为 A100 SXM4 80GB 条件化观察；约 1400/1600 GB/s 缺少完整 software、frequency 和统计条件，不能当作 GA100 HBM 定值。

### special_capabilities（4）

| 类别 | 字段 |
|---|---|
| `disclosed fact` | `FIELD-CAP-IMPLEMENTATION-DETAIL`、`FIELD-CAP-IMPLEMENTATION-LEVEL` |
| `pending` | `FIELD-CAP-LIMITATION`、`FIELD-CAP-THROUGHPUT` |

直接可接受的是 GA100 Optical Flow Accelerator 的存在和 dedicated physical module 层级，以及表题明确落在 GA100 的 decode-format 支持。5 NVDEC、5 NVJPG、对应吞吐与格式条件仍属 A100 产品。白皮书中的 A100 display、RT 和 NVENC 排除项也不能反推 full GA100 die 的物理缺席。Warp reduction 是 Ampere instruction capability，只支持来源列明的 ADD/MIN/MAX 与 AND/OR/XOR；它不等于 Softmax engine、network collective 或专用 LLM engine。

### compute（14）

| 类别 | 字段 |
|---|---|
| `disclosed fact` | `FIELD-COMP-ISSUE-WIDTH`、`FIELD-COMP-SHARED-RESOURCE`、`FIELD-COMP-THROUGHPUT`、`FIELD-COMP-UNIT-COUNT`、`FIELD-COMP-UNIT-NAME` |
| `architecture projection` | `FIELD-COMP-CONTROL-SCHEDULING`、`FIELD-COMP-COUNT-RULE`、`FIELD-COMP-DATAFLOW-RESIDENCY`、`FIELD-COMP-EXECUTION`、`FIELD-COMP-INSTRUCTION-TILE` |
| `pending` | `FIELD-COMP-ARRAY-SHAPE` |
| `not_applicable` | `FIELD-COMP-VENDOR-AI-TOPS` |
| `product-conditioned lead` | `FIELD-COMP-CONCURRENCY`、`FIELD-COMP-UTILIZATION-LIMIT` |

`1024 dense FP16/FP32 FMA per SM per clock` 可作为 GA100 per-SM throughput，但必须保留 FMA count rule，不能静默乘二成 FLOP/clock。PTX 的 `mma`/`mma.sp` tile 与 HPEC 测得的 WMMA→SASS 展开只描述指令接口或实测行为，不公开 Tensor Core physical array shape。A100 产品 aggregate TFLOPS/TOPS 和 occupancy limit 不应填入 full GA100。

### derived（6）

| 类别 | 字段 |
|---|---|
| `pending` | `FIELD-DER-CAPACITY-COMPUTE`、`FIELD-DER-COMPUTE-BW-SPEC`、`FIELD-DER-COMPUTE-BW-SUSTAINED`、`FIELD-DER-INTERCONNECT-COMPUTE`、`FIELD-DER-MATRIX-VECTOR`、`FIELD-DER-MOVE-MATRIX` |

这六项都缺少同一主体、同一 precision、同一方向和同一 count rule 下的可组合原子事实。不能把 full GA100 compute count 与 A100 HBM、L2 或 NVLink device aggregate 混合派生。

### economics（1）

| 类别 | 字段 |
|---|---|
| `not_applicable` | `FIELD-ECON-PUBLISHED-PRICE` |

GA100 bare die 不是单独公开定价的销售对象。A100 card、cloud instance、DGX/HGX 或二手价格都不能除算成 die 价格。

### identity（17）

| 类别 | 字段 |
|---|---|
| `disclosed fact` | `FIELD-ID-DATA-CUTOFF`、`FIELD-ID-FAMILY`、`FIELD-ID-NAME`、`FIELD-ID-OBJECT-TYPE`、`FIELD-ID-STATUS`、`FIELD-ID-VENDOR` |
| `architecture projection` | `FIELD-ID-ARCH` |
| `pending` | `FIELD-ID-MARKET-ACCESS-CONSTRAINT` |
| `not_applicable` | `FIELD-ID-DEPLOYMENT-CONSTRAINT`、`FIELD-ID-REGION`、`FIELD-ID-SKU` |
| `product-conditioned lead` | `FIELD-ID-AVAILABILITY-DATE`、`FIELD-ID-DEPLOYMENT`、`FIELD-ID-DESIGN-OBJECTIVE`、`FIELD-ID-RELEASE-DATE`、`FIELD-ID-TARGET-USE-POSITIONING`、`FIELD-ID-VENDOR-POSITIONING` |

`FIELD-ID-ARCH` 只能从 `implements_architecture` 关系投影，不能再写一个值为 Ampere 的对象事实。A100 launch、availability、HPC/training/inference positioning 和 DGX/HGX deployment 是上层产品或系统证据；没有直接 GA100 die 措辞时只保留 lead。`DATA-CUTOFF` 和 `STATUS` 是项目元数据，不应伪装成 vendor disclosure。

### interconnect（20）

| 类别 | 字段 |
|---|---|
| `disclosed fact` | `FIELD-INT-PHYSICAL-LINK-COUNT`、`FIELD-INT-PROTOCOL` |
| `architecture projection` | `FIELD-INT-FAULT`、`FIELD-INT-LANE-COUNT`、`FIELD-INT-PER-LINK-RATE`、`FIELD-INT-REMOTE-MEMORY` |
| `pending` | `FIELD-INT-COLLECTIVE`、`FIELD-INT-LATENCY` |
| `not_applicable` | `FIELD-INT-BISECTION-BW`、`FIELD-INT-DEGREE`、`FIELD-INT-HOPS`、`FIELD-INT-MAX-SCALE`、`FIELD-INT-OVERSUBSCRIPTION`、`FIELD-INT-TOPOLOGY`、`FIELD-INT-TOPOLOGY-DIMENSIONS`、`FIELD-INT-TOPOLOGY-NODE-COUNT`、`FIELD-INT-TOPOLOGY-ROUTING` |
| `product-conditioned lead` | `FIELD-INT-AGGREGATE-BW`、`FIELD-INT-INJECTION-BW`、`FIELD-INT-LINK-COUNT` |

`FIELD-INT-PROTOCOL` 的 direct 候选是 full GA100 图中的 PCIe 4.0 x16 host interface；NVLink 3 protocol 和 remote-memory behavior 归架构/link 投影。A100 的 12 logical links、300 GB/s per direction 和 600 GB/s bidirectional aggregate 是 device 配置。ISSCC 的 NVLink3 LR PHY 可以在 link 主体下保留 NRZ、no FEC、3-tap Tx FIR、Rx CTLE、PRML/Viterbi 和 BER target；“节省 tens of ns”只是相对描述，不能填写绝对 `FIELD-INT-LATENCY`。BER/no-FEC 也不证明 packet error detection/replay，后者仍由白皮书支持。

### memory（22）

| 类别 | 字段 |
|---|---|
| `disclosed fact` | `FIELD-MEM-AGGREGATION-VALIDITY`、`FIELD-MEM-CAPACITY`、`FIELD-MEM-INSTANCE-COUNT`、`FIELD-MEM-NAME` |
| `architecture projection` | `FIELD-MEM-DMA`、`FIELD-MEM-GRANULARITY`、`FIELD-MEM-LOCALITY-SCOPE`、`FIELD-MEM-MANAGEMENT` |
| `pending` | `FIELD-MEM-BANKS`、`FIELD-MEM-BIDIR-BW`、`FIELD-MEM-LATENCY`、`FIELD-MEM-PORTS`、`FIELD-MEM-READ-WRITE-MODEL`、`FIELD-MEM-WRITE-BW`、`FIELD-MEM-WRITE-TRANSFER-PER-CYCLE` |
| `product-conditioned lead` | `FIELD-MEM-COMPRESSION`、`FIELD-MEM-CONSISTENCY`、`FIELD-MEM-POOLING-MODE`、`FIELD-MEM-READ-BW`、`FIELD-MEM-READ-TRANSFER-PER-CYCLE`、`FIELD-MEM-USABLE-CAPACITY`、`FIELD-MEM-VIRTUAL-MEMORY` |

直接容量只接收 GA100 SM 内可从 full-design 结构落位的 register-file 与 192 KB unified L1/shared。40 MB L2、40/80 GB HBM、5120 B/clock 和 163 KB per-block usable shared memory 都有 A100 enabled implementation 或 software-visible limit 条件。CUDA 11.0 文档中的 160 KB 与后续 163 KB 不是两种硬件配置：前者应标为被后续精确定义取代，不能并列生成两个 accepted facts。

HPEC 的 L1 33 cycles、L2 200 cycles、shared load/store 23/19 cycles 因 `FIELD-MEM-LATENCY` canonical unit 为 second 且设备频率未报告，只能保留为 source-level lead。Random-access 论文观察到的约 64 GB window/cliff 可以保留在 A100 SXM4 80GB 条件下；“每个 group 有自己的 64 GB TLB”和 group 对 half-GPC/controller 的对应关系是作者推断，不是 GA100 常量。

### numerics（13）

| 类别 | 字段 |
|---|---|
| `architecture projection` | `FIELD-NUM-ACCUMULATION`、`FIELD-NUM-CONVERSION`、`FIELD-NUM-OPERAND-A`、`FIELD-NUM-OPERAND-B`、`FIELD-NUM-OUTPUT`、`FIELD-NUM-SPARSITY` |
| `pending` | `FIELD-NUM-PHYSICAL-ACCUM`、`FIELD-NUM-PRODUCT`、`FIELD-NUM-ROUNDING`、`FIELD-NUM-SATURATION`、`FIELD-NUM-SCALING-GRANULARITY`、`FIELD-NUM-SCALING-MODE`、`FIELD-NUM-SUBNORMAL` |

precision path 必须拆成 FP16、BF16、TF32、IEEE FP64、INT8、INT4 和 Binary，并分别填写 A、B、program-visible accumulation/output。TF32 的硬件乘法输入与外围 FP32 storage/output 不能合成一个 operand-A 值。PTX 7.1+ 的 sparse MMA 还要保留 datatype-specific pattern：FP16/BF16 与 INT8 为 2:4，TF32 为 1:2，INT4 为 pair-wise 4:8。硬件读取已剪枝、压缩的 sparse A 及 metadata，再选择对应 dense B，不是在运行时从四个值中发现两个非零。

### physical（13）

| 类别 | 字段 |
|---|---|
| `disclosed fact` | `FIELD-PHY-DIE-AREA`、`FIELD-PHY-FOUNDRY`、`FIELD-PHY-PROCESS`、`FIELD-PHY-TRANSISTORS` |
| `pending` | `FIELD-PHY-DIE-COUNT`、`FIELD-PHY-HBM-INTERFACE` |
| `not_applicable` | `FIELD-PHY-COOLING`、`FIELD-PHY-FORM-FACTOR`、`FIELD-PHY-HBM-STACKS`、`FIELD-PHY-INTERPOSER`、`FIELD-PHY-PACKAGE` |
| `product-conditioned lead` | `FIELD-PHY-CLOCK`、`FIELD-PHY-POWER` |

54B 是 54.2B 的舍入表达，不构成 unresolved conflict。SXM4/PCIe form factor、HBM stacks、interposer、package、cooling 和 250/300/400 W 属于 package/module/card，不进入 bare die。对象类型为 die 也不能单独证明 `FIELD-PHY-DIE-COUNT=1`；仍需明确的 monolithic/count 证据。

### reliability（10）

| 类别 | 字段 |
|---|---|
| `disclosed fact` | `FIELD-RAS-CAPABILITY`、`FIELD-RAS-FAULT-ISOLATION` |
| `architecture projection` | `FIELD-RAS-CORRECTION-REPLAY`、`FIELD-RAS-ERROR-DETECTION` |
| `pending` | `FIELD-RAS-CHECKPOINT-RESTART`、`FIELD-RAS-SILENT-DATA-ERROR` |
| `product-conditioned lead` | `FIELD-RAS-ECC`、`FIELD-RAS-PROTECTION-SCOPE`、`FIELD-RAS-RECOVERY`、`FIELD-RAS-TELEMETRY-BIST` |

June 2023 GPU Memory Error Management 支持 GA100 的 error containment、row remapping 和 dynamic page offlining。后两者是 die、外部 HBM、driver、InfoROM 和 reset/service process 的组合，不可写成 on-die autonomous repair。A100 的 HBM2、L2、L1 和 all-SM-register-file SECDED 仍带 enabled-product 边界。R595 中 Blackwell 才支持的 DRAM channel swap、L2 slice swap 与 XID 160 `RAS Repair for GPU Memory` 是 GA100 的排除证据，不得写成正向能力。公开资料仍没有 compute datapath SDC coverage、全 SRAM parity/ECC map、on-chip interconnect protection、BIST structure、FIT 或 degradation mode。

### relationship（1）

| 类别 | 字段 |
|---|---|
| `not_applicable` | `FIELD-REL-QUANTITY` |

`implements_architecture` 没有有意义的 child-instance quantity，不能因为当前只有一条关系就写 quantity=1。

### software（11）

| 类别 | 字段 |
|---|---|
| `architecture projection` | `FIELD-SW-COMPILER`、`FIELD-SW-PROGRAMMING-MODEL` |
| `pending` | `FIELD-SW-COMMUNICATION-LIBRARY`、`FIELD-SW-CUSTOM-OPERATOR`、`FIELD-SW-DYNAMIC-SHAPE`、`FIELD-SW-FRAMEWORK`、`FIELD-SW-OPERATOR-LIBRARY`、`FIELD-SW-QUANTIZATION-TOOL` |
| `product-conditioned lead` | `FIELD-SW-CHIP-BOUND-SCHEDULING`、`FIELD-SW-RUNTIME`、`FIELD-SW-SUPPORT-MATURITY` |

CUDA 11.0/PTX 7.0 支持 `cp.async`/`mbarrier` 的版本和 experimental 状态；PTX 7.1+ 再支持 `mma.sp`，固定 PTX 7.2 可以承载这部分语义。ISSCC 的“supported in CUDA 8.0”与官方开发文档冲突，不能接受；把它解释成 Compute Capability 8.0 只能保留为推断。当前 MIG guide 的 A100/A30 最低 driver 表也存在与 H100/H200 行次异常，最低 driver 继续 `conflicting_unresolved`。文档支持的最高成熟度是 `documented_supported`，本工作包没有 runnable 或 benchmark 验证。

### virtualization（3）

| 类别 | 字段 |
|---|---|
| `product-conditioned lead` | `FIELD-VIRT-MULTI-TENANCY`、`FIELD-VIRT-PARTITIONING`、`FIELD-VIRT-PREEMPTION-QOS` |

MIG guide 可以证明 A100/A30 使用 GA100 microarchitecture，但 7-way 与 4-way、profile geometry、memory capacity 和 engine count 都是产品条件。GI 获得 SM→crossbar→L2 bank→memory controller→DRAM path 的 partition、memory QoS 与 fault-isolation 边界；CI 只进一步切 SM，仍共享 parent GI 的 memory 和 engines。MIG mode enable 需要 reset，mode 状态可持久化到 InfoROM，但 GI/CI geometry 在 reset/reboot 后不持久。空闲时 create/destroy 也不等于 live resize、checkpoint 或 migration。

## 现有正式 Ampere 行的阻断项

现有 32 表没有 GA100/A100 正式对象，只有 `OBJ-NVIDIA-AMPERE-ARCH`。Ampere closure 目前包含 8 个 component、6 个 precision path、4 个 special capability、3 个 memory level、1 个 link、21 个事实、42 个 field requirement 和 13 个 completeness row。白皮书是一条 source family/source，带一个 local endpoint 和一个 remote endpoint；两者是同一内容版本，不是两份独立证据。

| 必须修复的正式语义 | 红队裁决 |
|---|---|
| `FACT-M2NA-AMPERE-SM-EXEC` 仅用 Figure 7 支撑 SIMT | Figure 7 只直接支撑资源标签；SIMT 需 PTX/CUDA public machine model 与 GA100/A100 图联合支撑 |
| `FACT-M2NA-AMPERE-TENSOR-FORMATS` 使用 `FIELD-COMP-SHARED-RESOURCE` | 删除或替换为 precision-path facts；格式不是 shared resource |
| `FACT-M2NA-AMPERE-ASYNC-EXEC` 使用 execution field | global→shared async copy 移到 `FIELD-MEM-DMA`；split barrier 单独落 control/scheduling |
| `FACT-M2NA-AMPERE-SPARSE-DETAIL` 写成 hardware 从四个中选择两个非零 | 改成压缩 sparse A+metadata 驱动对应 dense B 选择，并保留 datatype-specific pattern |
| `FACT-M2NA-AMPERE-TF32-A` 混合 TF32 与 FP32 storage/output | Tensor input conversion、operand、accumulation 与 output 分拆 |
| `FACT-M2NA-AMPERE-INT-A` 合并 INT8/INT4/Binary | 拆成独立 precision paths，并补 operand B 和 program-visible accumulation |
| software fact 缺少版本与成熟度 | 固定 CUDA 11.0/PTX 7.x/`sm_80`，保留 experimental/documented-supported 边界 |
| entity/source lifecycle 不一致 | components、precision paths、capabilities、link、source family/source/endpoints/selected role 多为 `draft`，事实和 selection member 却多为 `reviewed`；必须先统一 review lifecycle |

修复事实集合或加入 PTX/CUDA 新来源后，`SELRUN-M2NA-ARCH-20260812` 的旧反向移除结论不再覆盖新集合。不能因为白皮书曾对旧 21 条事实不可替代，就直接把旧 mandatory reason 复制到 GA100 run。

## 冲突、条件差异与可规范化项

| 表面差异 | 类型 | 处理方式 |
|---|---|---|
| 128 vs 108 SM；12 vs 10 memory controllers | full design 与 A100 enabled implementation | 两组都可保留在各自主体/条件下，不登记数值冲突 |
| 40 GB vs 80 GB；7-way vs 4-way MIG | A100 产品变体与 A100/A30 产品差异 | 建上层产品/profile 条件，不做二选一 |
| 54B vs 54.2B | 舍入精度 | 54.2B 为规范值，54B 作为 rounded supporting assertion |
| 1.56 TB/s vs 1555 GB/s | 单位与舍入，且均为 A100 HBM 产品口径 | 可规范化但仍不能进入 GA100 die |
| CUDA 11.0 文档 160 KB vs 后续 163 KB | 文档版本修订/精确定义变化 | 标记 superseded；不并列成两种硬件配置 |
| ISSCC `CUDA 8.0` vs CUDA 11.0/PTX 7.0 | 实质版本冲突 | 拒绝 ISSCC 版本值，保留 conflict member；不得暗改为 CC 8.0 |
| MIG guide 最低 driver 表异常 | 实质未解冲突 | 不冻结 A100/A30 minimum driver，等待官方历史 matrix/release note |
| HPEC Table III 单位 `GB/s` 但数值像 TFLOPS/TOPS | 实质未解冲突 | 不替作者改单位，不写吞吐事实；只拒绝该 claim，不必拒绝整篇来源 |
| HPEC background 的 124 SM | 与官方 full 128/A100 enabled 108 都不符 | 作为来源错误拒绝，不参与规范化 |
| Random-access 14 groups、6/8 SM 分布 | A100 108-SM 实测观察与作者结构推断 | 只保留观察，不能据此重建 full GA100 partition 常量 |

## 来源最小性与 endpoint 去重

最小集应在事实和主体都冻结后反向移除。当前候选表中的 `SELRUN-GA100-DIE-20260821-PROVISIONAL` 只能视为计划，不能预先证明来源不可替代。

| 来源家族/版本 | 先验反向移除结论 | 理由 |
|---|---|---|
| `SRC-M2NA-NVIDIA-AMPERE-WP-2020` | 保留 | 唯一同时承担 GA100 命名、full-vs-enabled 边界、N7、面积、transistor、full resource、SM 结构、OFA、media table 与 PCIe/NVLink 图示的固定一手核心来源 |
| June 2023 `NVIDIA GPU Memory Error Management` | 保留，前提是接受 GA100 RAS facts | 对 GA100 error containment、row remapping、DPO 有直接 support matrix 和机制链 |
| ISSCC 2021 | 条件保留 | die photo/面积/transistor 只是交叉核验；只有最终接受 NVLink3 LR PHY 的 NRZ/no-FEC/equalization/BER 等独有 link facts 时才不可移除，不能仅凭“同行评审”入选 |
| PTX ISA 7.2 | 放入 Ampere architecture 修复的条件最小集 | datatype-specific `mma.sp` 与 metadata 语义有独有价值；不应伪装成 GA100 physical disclosure |
| PTX ISA 7.0 | 可反向移除，除非保留“从该版本引入”的状态事实 | 与 7.2 同属 revision family，不增加独立证据数；只在 `cp.async`/`mbarrier` introduction/version provenance 需要时保留 |
| CUDA C++ Programming Guide 11.0 | 条件保留 | 仅当保留 experimental API、software maturity 或 CUDA-version binding；若只留硬件机制，白皮书/PTX 可覆盖大部内容 |
| MIG User Guide 610 bundle | 条件保留 | 只有建立 product/software-conditioned MIG facts 时需要；八个 HTML、version JSON 和 manifest 合起来仍是一份 source version |
| R595 RAS 六页 bundle | 条件保留或移除 | 只在保留 current-support boundary、Blackwell-only repair 排除或与 2023 PDF 的版本差异时有独有职责；六个 chapter endpoint 不是六份来源 |
| IEEE Micro standalone article | 倾向移除 | 只有 API→L2 pattern-gated compression chain 被正式接受且其他官方 CUDA 文档不能覆盖时才保留；full-issue PDF 是 byte-identical container，不另登记来源 |
| HPEC/arXiv v1 | 默认 lead，条件保留 | 只有 schema 接纳 instruction cycles、memory cycles 或 WMMA/SASS tile，并补足事实边界时才进入最小集；未证明 publisher-final equivalence，DOI 不能直接挂到 arXiv v1 |
| Random-access arXiv v1 | 默认 lead，倾向移除 | 只支持 A100 SXM4 80GB 条件化 memory-access observation，且 host/software/frequency/statistics 不完整；作者推断不构成 GA100 fact |
| A100 launch、80GB launch、product page、structured-sparsity blog、full-issue container | 移除或仅作线索 | 分别属于产品/市场背景、冗余机制说明或重复容器，不承担当前 GA100 die 不可替代事实 |

同一 source 的 local PDF、official direct PDF、DOI landing page 或 arXiv remote endpoint 只解决可恢复性和持久定位，不增加独立支持数。MIG 610 的九个 payload、R595 的六个 chapter 和 IEEE Micro standalone/full-issue container 也必须按一个内容版本或一个 source family 处理。真正的交叉验证需要不同来源家族、不同作者链和独立测量，而不是多 URL。

## 总控交接

### 必须修复项

正式写入前必须完成四件事。先建立 GA100 die 对象及唯一 `implements_architecture` 关系；再按上表修复 Ampere 事实和 lifecycle；随后把 A100 enabled/product、MIG profile、software revision 与第三方 measurement 从 full GA100 facts 中拆出；最后重新生成 assertion、requirement、conflict 与 selection run，不能复用旧 21-fact mandatory reason。HPEC cycle 值在 schema 未决前不得进入 `FIELD-MEM-LATENCY`/`FIELD-BENCH-LATENCY`，ISSCC CUDA 8.0、MIG minimum driver 和 HPEC Table III unit 不得被静默“纠正”。

### 可接受项

白皮书中的 full GA100 N7、826 mm²、54.2B、8/64/128、8192、512、12×512-bit controller、GA100 SM 可数结构、192 KB L1/shared、OFA、GA100 decode-format table，以及 full-design 图中的 PCIe 4.0 x16 与 12 个 NVLink physical interfaces，可以进入原子化候选。June 2023 RAS 的 GA100 support matrix 可以支撑 error containment、row remapping 和 DPO，但过程链必须明确外部 HBM、driver、InfoROM 和 reset 的参与。修复后的 Ampere precision、sparsity、async copy/barrier、warp reduction 与 NVLink mechanism 可以通过关系投影。

### 不可下放项

对象层级、A100 条件值是否需要新建上层 object、diagram count 是否接受为 direct assertion、cycle metric 是否扩 schema、ISSCC PHY 是否进入正式 141-field closure、冲突值的接受/拒绝、Ampere repair 是否重开既有 architecture selection run，以及最终最小来源集，必须由总控裁决。子代理不能用 condition set 修复错误主体，也不能以“来源更权威”代替 field-level reverse removal。

### 建议反向移除结论

GA100 direct minimum 的先验核心是白皮书；接受 RAS facts 时加入 June 2023 RAS PDF；接受 NVLink3 LR PHY 独有事实时再加入 ISSCC。PTX/CUDA 应进入 Ampere architecture repair 的最小集，而不是被计算成额外 GA100 physical evidence。MIG、R595、IEEE Micro、HPEC 和 random-access source 都先保留为 conditional candidates，只有最终事实集合中存在它们独自支持、且主体与 schema 合法的事实时才入选。product release/page/blog 和重复 container 应在反向移除中退出。

## 自检与剩余边界

本轮只写本报告，没有修改正式 CSV、资料卡、来源登记、选择运行或其他代理文件，也没有读取或等待 atomic staging。字段清单通过只读比对确认：141 个注册字段全部覆盖、无遗漏、无额外字段、无重复；分类总数为 25+24+41+20+31=141。

本报告完成后运行了 `report-humanizer` 机器扫描，最终返回 `No machine-detectable AI tells found`；随后人工逆向复读标题、各节首段、表格引导、主体转场、总控交接和结尾。剩余风险集中在总控尚未对上层对象、measurement-cycle schema、ISSCC PHY 入库边界和正式 reverse-removal scope 作最终裁决；这些决定不能由本先验清单代替。
