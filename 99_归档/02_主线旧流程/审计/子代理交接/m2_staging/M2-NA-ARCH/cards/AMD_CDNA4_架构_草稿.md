# AMD CDNA 4 架构资料卡（草稿）

> 对象：OBJ-AMD-CDNA4-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：draft。


术语：CU（Compute Unit，计算单元）是基本执行组织；XCD 是计算裸片；MFMA（Matrix Fused Multiply-Add）是矩阵融合乘加指令；LDS（Local Data Share）是软件管理的本地共享存储。
## 对象边界

本卡只收录能直接归到架构代际的执行组织、程序员可见数值语义、存储机制、互联协议、特殊能力和软件映射。具体 GPU/加速器的启用单元数、总峰值、HBM、封装和系统拓扑留给物理对象、SKU 或系统卡。

## 执行组织、矩阵/向量/标量路径

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA4-CU-EXEC | FIELD-COMP-EXECUTION | Compute Unit with scalar, vector, matrix, transcendental, conversion, LDS and L1 paths. | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.6, Compute Unit Architecture paragraph |
| FACT-M2NA-CDNA4-MATRIX-EXEC | FIELD-COMP-EXECUTION | Matrix Core with native OCP microscaling formats and sparse matrix throughput modes. | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, Matrix Cores paragraph and Table 1 |
| FACT-M2NA-CDNA4-MFP16-THR | FIELD-COMP-THROUGHPUT | 4096 FLOP/cycle/CU | COND-M2NA-CDNA4-MATRIX-FP16 | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, Table 1, Matrix FP16 row, MI355X column |
| FACT-M2NA-CDNA4-MFP32-THR | FIELD-COMP-THROUGHPUT | 256 FLOP/cycle/CU | COND-M2NA-CDNA4-MATRIX-FP32 | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, Table 1, Matrix FP32 row, MI355X column |
| FACT-M2NA-CDNA4-MFP64-THR | FIELD-COMP-THROUGHPUT | 128 FLOP/cycle/CU | COND-M2NA-CDNA4-MATRIX-FP64 | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, Table 1, Matrix FP64 row, MI355X column |
| FACT-M2NA-CDNA4-VFP16-THR | FIELD-COMP-THROUGHPUT | 256 FLOP/cycle/CU | COND-M2NA-CDNA4-VECTOR-FP16 | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, Table 1, Vector FP16 row, MI355X column |
| FACT-M2NA-CDNA4-VFP32-THR | FIELD-COMP-THROUGHPUT | 256 FLOP/cycle/CU | COND-M2NA-CDNA4-VECTOR-FP32 | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, Table 1, Vector FP32 row, MI355X column |
| FACT-M2NA-CDNA4-VFP64-THR | FIELD-COMP-THROUGHPUT | 128 FLOP/cycle/CU | COND-M2NA-CDNA4-VECTOR-FP64 | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, Table 1, Vector FP64 row, MI355X column |
| FACT-M2NA-CDNA4-TRANS-EXEC | FIELD-COMP-EXECUTION | The transcendental rate is twice the prior generation to aid attention acceleration; the source discusses softmax as the common transformer activation. | COND-M2NA-CDNA4-TRANS-REL | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, activation and transcendental paragraph |
| FACT-M2NA-CDNA4-CONVERT-EXEC | FIELD-COMP-EXECUTION | Dedicated instructions convert newly supported low-precision formats. | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, activation and conversion paragraph |

### 组件职责

以下组件用于保存父子结构或承接精度路径；没有独立公开值时不另造规格事实。

| component_id | 保留职责 | 数据落点 |
|---|---|---|
| COMP-M2NA-CDNA4-VECTOR | CU 下的向量执行分支。 | `PPATH-M2NA-CDNA4-VECTOR-FP16`、`PPATH-M2NA-CDNA4-VECTOR-FP32` 与 `PPATH-M2NA-CDNA4-VECTOR-FP64` 及其吞吐事实。 |
| COMP-M2NA-CDNA4-SCALAR | CU 下的标量执行分支。 | `FACT-M2NA-CDNA4-CU-EXEC` 的复合执行组织事实。 |

## 数据格式、累加与稀疏语义

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA4-MX-A | FIELD-NUM-OPERAND-A | MXFP8, MXFP6 or MXFP4 | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, first paragraph |
| FACT-M2NA-CDNA4-MX-SCALE | FIELD-NUM-SCALING-MODE | per_block | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.7, micro-scaling paragraph |
| FACT-M2NA-CDNA4-MX-GRAN | FIELD-NUM-SCALING-GRANULARITY | A block of values, typically 32, shares one scale factor. | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.7, micro-scaling paragraph |
| FACT-M2NA-CDNA4-FP8-A | FIELD-NUM-OPERAND-A | OCP FP8 E5M2 or E4M3 | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.7, FP8 paragraph |
| FACT-M2NA-CDNA4-FP8-ACC | FIELD-NUM-ACCUMULATION | FP32 C and D in selected dense and sparse MFMA forms | COND-NONE | SRC-M2NA-AMD-CDNA4-ISA，PDF p.286, V_MFMA_F32_32X32X64_F8F6F4 description |
| FACT-M2NA-CDNA4-FP16-A | FIELD-NUM-OPERAND-A | FP16 or BF16 | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, Table 1, Matrix FP16 and Matrix BF16 rows |
| FACT-M2NA-CDNA4-FP16-ACC | FIELD-NUM-ACCUMULATION | FP32 C and D in selected MFMA forms | COND-NONE | SRC-M2NA-AMD-CDNA4-ISA，PDF p.287, V_MFMA_F32_16X16X32_BF16 description |
| FACT-M2NA-CDNA4-INT8-A | FIELD-NUM-OPERAND-A | INT8 | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, Table 1, Matrix INT8 row |
| FACT-M2NA-CDNA4-INT8-ACC | FIELD-NUM-ACCUMULATION | INT32 C and D | COND-NONE | SRC-M2NA-AMD-CDNA4-ISA，PDF p.288, V_MFMA_I32_16X16X64_I8 description |
| FACT-M2NA-CDNA4-TF32-CONV | FIELD-NUM-CONVERSION | TF32 hardware path was removed. TF32 is supported by software emulation using BF16. | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, TF32 paragraph |

## 存储层次、带宽与管理

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA4-LDS-CAP | FIELD-MEM-CAPACITY | 163840 byte | COND-M2NA-CDNA4-LDS-READ | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, LDS paragraph |
| FACT-M2NA-CDNA4-LDS-READ | FIELD-MEM-READ-TRANSFER-PER-CYCLE | 256 byte/cycle | COND-M2NA-CDNA4-LDS-READ | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, LDS paragraph |
| FACT-M2NA-CDNA4-LDS-MGMT | FIELD-MEM-MANAGEMENT | software_scratchpad | COND-M2NA-CDNA4-LDS-READ | SRC-M2NA-AMD-CDNA4-WP，PDF p.6, Compute Unit Architecture paragraph |
| FACT-M2NA-CDNA4-LDS-DMA | FIELD-MEM-DMA | Direct loads from the L1 data cache to LDS reduce register staging. | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, LDS paragraph |
| FACT-M2NA-CDNA4-L1-CAP | FIELD-MEM-CAPACITY | 32768 byte | COND-M2NA-CDNA4-L1-CU | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, L1/L2 paragraph |
| FACT-M2NA-CDNA4-L1-GRAN | FIELD-MEM-GRANULARITY | 128 byte | COND-M2NA-CDNA4-L1-CU | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, L1/L2 paragraph |
| FACT-M2NA-CDNA4-L1-MGMT | FIELD-MEM-MANAGEMENT | hardware_cache | COND-M2NA-CDNA4-L1-CU | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, L1/L2 paragraph |
| FACT-M2NA-CDNA4-L2-CAP | FIELD-MEM-CAPACITY | 4194304 byte | COND-M2NA-CDNA4-L2-XCD | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, L1/L2 paragraph |
| FACT-M2NA-CDNA4-L2-READ | FIELD-MEM-READ-TRANSFER-PER-CYCLE | 128 byte/cycle | COND-M2NA-CDNA4-L2-READ | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, L1/L2 paragraph |
| FACT-M2NA-CDNA4-L2-WRITE | FIELD-MEM-WRITE-TRANSFER-PER-CYCLE | 64 byte/cycle | COND-M2NA-CDNA4-L2-WRITE | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, L1/L2 paragraph |
| FACT-M2NA-CDNA4-L2-CONSISTENCY | FIELD-MEM-CONSISTENCY | Fully coherent, writeback and write-allocate L2 shared by the CUs in one XCD. | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, L1/L2 paragraph |

## 互联机制

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA4-IF-PROTOCOL | FIELD-INT-PROTOCOL | AMD Infinity Fabric ties the XCDs to IOD-resident shared memory resources. | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.10, memory-hierarchy opening paragraph |

## 特殊算子与专用能力

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA4-SPARSE-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | dedicated_instruction | COND-NONE | SRC-M2NA-AMD-CDNA4-ISA，PDF pp.67-68, sparse MFMA section and opcode table |
| FACT-M2NA-CDNA4-SOFTMAX-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | general_compute_path | COND-M2NA-CDNA4-TRANS-REL | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, activation and transcendental paragraph |
| FACT-M2NA-CDNA4-SOFTMAX-DETAIL | FIELD-CAP-IMPLEMENTATION-DETAIL | The transcendental-rate increase supports activation and softmax work. | COND-M2NA-CDNA4-TRANS-REL | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, activation and transcendental paragraph |
| FACT-M2NA-CDNA4-CONVERT-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | dedicated_instruction | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF p.9, activation and conversion paragraph |

## 软件映射

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA4-SW | FIELD-SW-PROGRAMMING-MODEL | ROCm ecosystem with framework, distributed-training, serving and custom-kernel support. | COND-NONE | SRC-M2NA-AMD-CDNA4-WP，PDF pp.16-17, software ecosystem section |

## 派生指标

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA4-DER-FP16-MATRIX-VECTOR | FIELD-DER-MATRIX-VECTOR | 16 ratio | COND-M2NA-CDNA4-DER-MATRIX-VECTOR-FP16 | SRC-M2NA-AMD-CDNA4-WP，PDF p.8, Table 1, Vector FP16 and Matrix FP16 rows, MI355X column |

## 缺失项与不适用项

| requirement_id | 目标/字段 | 状态 | search_id | 适用性理由 |
|---|---|---|---|---|
| REQ-M2NA-GAP-0043 | OBJ-AMD-CDNA4-ARCH / FIELD-COMP-VENDOR-AI-TOPS | not_applicable | 不需要 | 架构代际没有一项脱离具体实现仍成立的加速器总峰值；总量应归裸片、封装、模组、卡或系统对象。 |
| REQ-M2NA-GAP-0044 | OBJ-AMD-CDNA4-ARCH / FIELD-PHY-PROCESS | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0045 | OBJ-AMD-CDNA4-ARCH / FIELD-PHY-DIE-COUNT | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0046 | OBJ-AMD-CDNA4-ARCH / FIELD-PHY-PACKAGE | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0093 | PPATH-M2NA-CDNA4-MX / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0048 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0094 | PPATH-M2NA-CDNA4-MFMA-FP8 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0049 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0095 | PPATH-M2NA-CDNA4-MFMA-FP16BF16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0050 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0096 | PPATH-M2NA-CDNA4-MFMA-INT8 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0051 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0097 | PPATH-M2NA-CDNA4-MFMA-FP32 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0052 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0098 | PPATH-M2NA-CDNA4-MFMA-FP64 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0053 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0099 | PPATH-M2NA-CDNA4-TF32-EMU / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0054 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0100 | PPATH-M2NA-CDNA4-VECTOR-FP16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0055 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0101 | PPATH-M2NA-CDNA4-VECTOR-FP32 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0056 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0102 | PPATH-M2NA-CDNA4-VECTOR-FP64 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0057 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-AVAIL-0144 | COMP-M2NA-CDNA4-L2 / FIELD-MEM-BANKS | not_found | SEARCH-M2NA-0128 | 白皮书给出 16 个并行 channel 和 16-way 组相联，二者都不是 L2 bank 数量。 |
| REQ-M2NA-GAP-0138 | COMP-M2NA-CDNA4-LDS / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0093 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0139 | COMP-M2NA-CDNA4-L1 / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0094 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0140 | COMP-M2NA-CDNA4-L1 / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0095 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0141 | COMP-M2NA-CDNA4-ICACHE / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0096 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0142 | COMP-M2NA-CDNA4-ICACHE / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0097 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0160 | LINK-M2NA-CDNA4-IF-PKG / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0161 | LINK-M2NA-CDNA4-IF-P2P / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0177 | CAP-M2NA-CDNA4-MOE / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0120 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |
| REQ-M2NA-GAP-0178 | CAP-M2NA-CDNA4-TOPK / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0121 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |

## 最小来源与反向移除

| source_id | 定位 | 独有贡献 / 不采用理由 |
|---|---|---|
| SRC-M2NA-AMD-CDNA4-WP | CDNA 4 white paper, Table 1；CDNA 4 white paper, Table 1 and LDS hierarchy section；p.6；p.7 | CDNA 4 主架构来源；支撑公开的每 CU 矩阵/向量吞吐、LDS/L1/L2 参数、OCP 微缩放、TF32 软件模拟及 transcendental 路径。 |
| SRC-M2NA-AMD-CDNA4-ISA | Chapter 7, FP16 and BF16 MFMA descriptions；Chapter 7, FP8 and BF8 MFMA instruction descriptions；Chapter 7, INT8 MFMA descriptions；Chapter 7, sparse MFMA descriptions | 补足 FP8/BF8/FP16/BF16/INT8 的 C/D 格式、稀疏布局和指令级语义。 |

## 实现边界与冲突

未发现需要建立 conflict-group 的同条件直接冲突。产品表、系统表与架构定义如果数值不同，先按对象或条件分层，不视为同一事实冲突。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | complete | 白皮书给出 CU 内矩阵、向量、超越函数和转换路径，并提供同口径每 CU 吞吐。 |
| numerics | partial | 已记录 OCP MX 格式、FP8/FP16/INT8 累加和 TF32 软件模拟；物理累加器位宽未公开。 |
| memory | partial | 已记录每 CU LDS/L1、每 XCD L2 的容量与部分带宽；LDS 写带宽、L1 带宽和 Infinity Cache 定值缺失。 |
| interconnect | partial | 只评价架构级互联机制，不混入产品或系统聚合值。 |
| special_engines | partial | 已记录稀疏 MFMA、格式转换和通用 transcendental 路径；softmax 由已记录的通用路径支撑，MoE routing/top-k 未找到。 |
| software | complete | 白皮书直接给出 ROCm 生态及框架、分布式训练、服务和自定义内核支持；本来源没有出现 HIP。 |
| evidence | complete | 只使用一手来源，并保留筛选与反向移除记录。 |

## 自检与复核

- 本卡的 fact_id、requirement_id、search_id、source_id 均来自本 staging 结构化片段；总控合并前状态均为 draft 或 needs_resolution。
- 本卡中的 per-CU、per-WGP 或 per-XCD 数值均保留显式 condition_set；不是芯片总量。
- 主键、外键、枚举、七目标 XOR 与中文润色检查在交付前统一执行；检查结果写入 README 和 notes。
