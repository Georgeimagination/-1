# AMD CDNA 5 架构资料卡（草稿）

> 对象：OBJ-AMD-CDNA5-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：draft。


术语：WGP（Work Group Processor，工作组处理器）是 CDNA 5 的执行组织；WMMA/SWMMAC 分别是稠密与结构化稀疏矩阵指令；TDM（Tensor Data Mover）是描述符驱动的数据搬运模块；LDS（Local Data Share）是软件管理的本地共享存储。
## 对象边界

本卡只收录能直接归到架构代际的执行组织、程序员可见数值语义、存储机制、互联协议、特殊能力和软件映射。具体 GPU/加速器的启用单元数、总峰值、HBM、封装和系统拓扑留给物理对象、SKU 或系统卡。

## 执行组织、矩阵/向量/标量路径

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA5-WGP-EXEC | FIELD-COMP-EXECUTION | Wave32 Work Group Processor containing four 32-thread SIMD units and four scalar units sharing a constant cache. | COND-NONE | SRC-M2NA-AMD-CDNA5-WP，PDF p.6, new WGP design paragraph |
| FACT-M2NA-CDNA5-VECTOR-COUNT | FIELD-COMP-UNIT-COUNT | 4 count | COND-M2NA-CDNA5-WGP | SRC-M2NA-AMD-CDNA5-WP，PDF p.6, new WGP design paragraph |
| FACT-M2NA-CDNA5-VECTOR-WIDTH | FIELD-COMP-ISSUE-WIDTH | 32 thread/cycle | COND-M2NA-CDNA5-WGP | SRC-M2NA-AMD-CDNA5-WP，PDF p.6, new WGP design paragraph |
| FACT-M2NA-CDNA5-SCALAR-COUNT | FIELD-COMP-UNIT-COUNT | 4 count | COND-M2NA-CDNA5-WGP | SRC-M2NA-AMD-CDNA5-WP，PDF p.6, new WGP design paragraph |
| FACT-M2NA-CDNA5-MATRIX-EXEC | FIELD-COMP-EXECUTION | Wave32 WMMA and 2:4 sparse SWMMAC matrix paths. | COND-NONE | SRC-M2NA-AMD-CDNA5-ISA，PDF pp.105-106, section 7.12 Wave Matrix Multiply Accumulate |
| FACT-M2NA-CDNA5-TRANS-EXEC | FIELD-COMP-EXECUTION | New tanh operation plus twice the throughput for existing transcendental operations relative to MI355X. | COND-M2NA-CDNA5-TRANS-REL | SRC-M2NA-AMD-CDNA5-WP，PDF p.7, Optimized Compute for AI, second paragraph |
| FACT-M2NA-CDNA5-TDM-EXEC | FIELD-COMP-EXECUTION | Per-WGP asynchronous Tensor Data Mover understands up to five-dimensional tiles and executes descriptor-based transfers. | COND-NONE | SRC-M2NA-AMD-CDNA5-WP，PDF p.10, Tensor Data Mover paragraph |

## 数据格式、累加与稀疏语义

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA5-FP4-A | FIELD-NUM-OPERAND-A | FP4 | COND-NONE | SRC-M2NA-AMD-CDNA5-ISA，PDF p.472, V_WMMA_F32_32X16X128_F4 description |
| FACT-M2NA-CDNA5-FP4-ACC | FIELD-NUM-ACCUMULATION | FP32 C and D | COND-NONE | SRC-M2NA-AMD-CDNA5-ISA，PDF p.472, V_WMMA_F32_32X16X128_F4 description |
| FACT-M2NA-CDNA5-FP4-SCALE | FIELD-NUM-SCALING-MODE | per_block | COND-NONE | SRC-M2NA-AMD-CDNA5-ISA，PDF p.473, V_WMMA_SCALE_F32_16X16X128_F8F6F4 description |
| FACT-M2NA-CDNA5-FP4-GRAN | FIELD-NUM-SCALING-GRANULARITY | Blocks sharing a common scale factor may be 16 or 32 elements in size. | COND-NONE | SRC-M2NA-AMD-CDNA5-WP，PDF p.7, Optimized Compute for AI, first paragraph |
| FACT-M2NA-CDNA5-FP4-ROUND | FIELD-NUM-ROUNDING | rne | COND-NONE | SRC-M2NA-AMD-CDNA5-ISA，PDF p.472, V_WMMA_F32_32X16X128_F4 Notes |
| FACT-M2NA-CDNA5-FP8-A | FIELD-NUM-OPERAND-A | FP8 or BF8 | COND-NONE | SRC-M2NA-AMD-CDNA5-ISA，PDF pp.468-470, FP8/BF8 WMMA instruction variants |
| FACT-M2NA-CDNA5-FP8-ACC32 | FIELD-NUM-ACCUMULATION | FP32 C and D | COND-NONE | SRC-M2NA-AMD-CDNA5-ISA，PDF p.468, V_WMMA_F32_16X16X128_FP8_FP8 description |
| FACT-M2NA-CDNA5-FP8-ACC16 | FIELD-NUM-ACCUMULATION | FP16 C and D | COND-NONE | SRC-M2NA-AMD-CDNA5-ISA，PDF p.471, V_WMMA_F16_16X16X128_BF8_FP8 description |
| FACT-M2NA-CDNA5-INT8-A | FIELD-NUM-OPERAND-A | Signed or unsigned INT8 | COND-NONE | SRC-M2NA-AMD-CDNA5-ISA，PDF p.467, V_SWMMAC_I32_16X16X128_IU8 description |
| FACT-M2NA-CDNA5-INT8-ACC | FIELD-NUM-ACCUMULATION | Signed INT32 C and D | COND-NONE | SRC-M2NA-AMD-CDNA5-ISA，PDF p.467, V_SWMMAC_I32_16X16X128_IU8 description |
| FACT-M2NA-CDNA5-SPARSE-MODE | FIELD-NUM-SPARSITY | structured_sparse | COND-M2NA-CDNA5-SPARSE | SRC-M2NA-AMD-CDNA5-ISA，PDF pp.466-467, V_SWMMAC sparse-matrix descriptions |
| FACT-M2NA-CDNA5-VBF16-A | FIELD-NUM-OPERAND-A | BF16 | COND-NONE | SRC-M2NA-AMD-CDNA5-WP，PDF p.7, Optimized Compute for AI, second paragraph |

## 存储层次、带宽与管理

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA5-TDM-DMA | FIELD-MEM-DMA | Supports multicast and direct transfers between DRAM and LDS without register staging. | COND-NONE | SRC-M2NA-AMD-CDNA5-WP，PDF p.10, Tensor Data Mover paragraph |
| FACT-M2NA-CDNA5-LDS-CAP | FIELD-MEM-CAPACITY | 327680 byte | COND-M2NA-CDNA5-WGP | SRC-M2NA-AMD-CDNA5-WP，PDF p.10, LDS and vector-cache paragraph |
| FACT-M2NA-CDNA5-LDS-MGMT | FIELD-MEM-MANAGEMENT | software_scratchpad | COND-M2NA-CDNA5-WGP | SRC-M2NA-AMD-CDNA5-WP，PDF p.10, Tensor Data Mover paragraph |
| FACT-M2NA-CDNA5-VCACHE-CAP | FIELD-MEM-CAPACITY | 65536 byte | COND-M2NA-CDNA5-WGP | SRC-M2NA-AMD-CDNA5-WP，PDF p.10, LDS and vector-cache paragraph |
| FACT-M2NA-CDNA5-VCACHE-MGMT | FIELD-MEM-MANAGEMENT | hardware_cache | COND-M2NA-CDNA5-WGP | SRC-M2NA-AMD-CDNA5-WP，PDF p.10, LDS and vector-cache paragraph |
| FACT-M2NA-CDNA5-CCACHE-CAP | FIELD-MEM-CAPACITY | 16384 byte | COND-M2NA-CDNA5-WGP | SRC-M2NA-AMD-CDNA5-WP，PDF p.10, WGP cache sentence |
| FACT-M2NA-CDNA5-ICACHE-CAP | FIELD-MEM-CAPACITY | 65536 byte | COND-M2NA-CDNA5-WGP | SRC-M2NA-AMD-CDNA5-WP，PDF p.10, WGP cache sentence |

## 互联机制

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA5-IF-PROTOCOL | FIELD-INT-PROTOCOL | AMD Infinity Fabric for coherent on-package communication among specialized dies. | COND-NONE | SRC-M2NA-AMD-CDNA-LANDING，Fixed HTML snapshot, Unified Fabric and I/O, line 8132 |

## 特殊算子与专用能力

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA5-SPARSE-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | dedicated_instruction | COND-M2NA-CDNA5-SPARSE | SRC-M2NA-AMD-CDNA5-ISA，PDF p.467, V_SWMMAC sparse matrix opcode |
| FACT-M2NA-CDNA5-SPARSE-DETAIL | FIELD-CAP-IMPLEMENTATION-DETAIL | SWMMAC uses a sparse A matrix where two of every four K-axis elements are zero, and indexes identify the zero positions. | COND-M2NA-CDNA5-SPARSE | SRC-M2NA-AMD-CDNA5-ISA，PDF p.467, V_SWMMAC_I32_16X16X128_IU8 description |
| FACT-M2NA-CDNA5-SOFTMAX-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | general_compute_path | COND-M2NA-CDNA5-TRANS-REL | SRC-M2NA-AMD-CDNA5-WP，PDF p.7, Optimized Compute for AI, second paragraph |
| FACT-M2NA-CDNA5-TDM-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | configurable_engine | COND-NONE | SRC-M2NA-AMD-CDNA5-WP，PDF p.10, Tensor Data Mover paragraph |
| FACT-M2NA-CDNA5-TDM-DETAIL | FIELD-CAP-IMPLEMENTATION-DETAIL | Descriptor-defined asynchronous tensor transfers support up to five dimensions, bounds checking and multicast. | COND-NONE | SRC-M2NA-AMD-CDNA5-WP，PDF p.10, Tensor Data Mover paragraph |

## 软件映射

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA5-SW | FIELD-SW-PROGRAMMING-MODEL | ROCm open AI software stack with optimized compilers, runtimes, communication libraries, AI frameworks and developer tools. | COND-NONE | SRC-M2NA-AMD-CDNA5-WP，PDF p.3, ROCm paragraph |

## 缺失项与不适用项

| requirement_id | 目标/字段 | 状态 | search_id | 适用性理由 |
|---|---|---|---|---|
| REQ-M2NA-GAP-0047 | OBJ-AMD-CDNA5-ARCH / FIELD-COMP-VENDOR-AI-TOPS | not_applicable | 不需要 | 架构代际没有一项脱离具体实现仍成立的加速器总峰值；总量应归裸片、封装、模组、卡或系统对象。 |
| REQ-M2NA-GAP-0048 | OBJ-AMD-CDNA5-ARCH / FIELD-PHY-PROCESS | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0049 | OBJ-AMD-CDNA5-ARCH / FIELD-PHY-DIE-COUNT | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0050 | OBJ-AMD-CDNA5-ARCH / FIELD-PHY-PACKAGE | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0051 | OBJ-AMD-CDNA5-ARCH / FIELD-DER-COMPUTE-BW-SPEC | not_found | SEARCH-M2NA-0015 | 完成对象边界与条件对齐后，没有找到同精度、同作用域的架构计算吞吐与存储带宽对。 |
| REQ-M2NA-GAP-0052 | OBJ-AMD-CDNA5-ARCH / FIELD-DER-MATRIX-VECTOR | not_found | SEARCH-M2NA-0016 | 没有找到精度、作用域和运算计数口径都一致的矩阵/向量吞吐对。 |
| REQ-M2NA-GAP-0103 | PPATH-M2NA-CDNA5-WMMA-FP4 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0058 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0104 | PPATH-M2NA-CDNA5-WMMA-FP8-F32 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0059 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0105 | PPATH-M2NA-CDNA5-WMMA-FP8-F16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0060 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0106 | PPATH-M2NA-CDNA5-WMMA-INT8 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0061 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0107 | PPATH-M2NA-CDNA5-SWMMAC / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0062 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0108 | PPATH-M2NA-CDNA5-VECTOR-BF16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0063 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0143 | COMP-M2NA-CDNA5-LDS / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0098 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0144 | COMP-M2NA-CDNA5-LDS / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0099 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0145 | COMP-M2NA-CDNA5-VCACHE / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0100 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0146 | COMP-M2NA-CDNA5-VCACHE / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0101 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0147 | COMP-M2NA-CDNA5-CCACHE / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0102 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0148 | COMP-M2NA-CDNA5-CCACHE / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0103 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0149 | COMP-M2NA-CDNA5-ICACHE / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0104 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0150 | COMP-M2NA-CDNA5-ICACHE / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0105 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0162 | LINK-M2NA-CDNA5-IF-PKG / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0179 | CAP-M2NA-CDNA5-MOE / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0122 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |
| REQ-M2NA-GAP-0180 | CAP-M2NA-CDNA5-TOPK / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0123 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |

## 最小来源与反向移除

| source_id | 定位 | 独有贡献 / 不采用理由 |
|---|---|---|
| SRC-M2NA-AMD-CDNA5-WP | p.5；p.6；p.9；pp.2-4 and software sections | CDNA 5 主架构来源；支撑 Wave32 WGP、四 SIMD/四标量单元、TDM、LDS 与 WGP 缓存层次及 ROCm 映射。 |
| SRC-M2NA-AMD-CDNA5-ISA | p.462；p.472, FP4 WMMA notes；pp.103, 110-111 and 455-475；pp.110-111, 473-475 | 截至截止日可用的 CDNA 5 ISA；独有支撑 FP4/FP8 WMMA 累加选项、block scale 16/32、RNE 与 2:4 SWMMAC。 |
| SRC-M2NA-AMD-CDNA-LANDING | CDNA 5, Unified Fabric and I/O | 直接支撑 CDNA 5 coherent on-package Infinity Fabric 机制；不以通用代际身份作为入选理由，其他微架构事实仍由白皮书和 ISA 承担。 |

## 实现边界与冲突

未发现需要建立 conflict-group 的同条件直接冲突。产品表、系统表与架构定义如果数值不同，先按对象或条件分层，不视为同一事实冲突。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | partial | 已记录 Wave32 WGP、四 SIMD/四标量单元、WMMA/SWMMAC、transcendental 与 TDM；绝对矩阵/向量吞吐未形成同口径对。 |
| numerics | partial | 已记录 FP4/FP8/INT8 的 C/D 格式、block scale、RNE 和 2:4 稀疏；物理累加器位宽未找到。 |
| memory | partial | 已记录每 WGP LDS、向量/常量/指令缓存容量和 TDM 搬运；各层读写带宽未找到。 |
| interconnect | partial | 只评价架构级互联机制，不混入产品或系统聚合值。 |
| special_engines | partial | 已记录 SWMMAC、通用 transcendental 路径与 TDM；没有证据把 TDM 解释为 expert routing/top-k。 |
| software | complete | 白皮书直接给出 ROCm 及优化编译器、运行时、通信库、AI 框架和开发工具；本来源没有出现 HIP。 |
| evidence | complete | 只使用一手来源，并保留筛选与反向移除记录。 |

## 自检与复核

- 本卡的 fact_id、requirement_id、search_id、source_id 均来自本 staging 结构化片段；总控合并前状态均为 draft 或 needs_resolution。
- 本卡中的 per-CU、per-WGP 或 per-XCD 数值均保留显式 condition_set；不是芯片总量。
- 主键、外键、枚举、七目标 XOR 与中文润色检查在交付前统一执行；检查结果写入 README 和 notes。
