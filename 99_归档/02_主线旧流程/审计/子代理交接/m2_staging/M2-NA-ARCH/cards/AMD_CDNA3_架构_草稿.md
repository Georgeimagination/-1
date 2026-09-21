# AMD CDNA 3 架构资料卡（草稿）

> 对象：OBJ-AMD-CDNA3-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：draft。


术语：CU（Compute Unit，计算单元）是基本执行组织；XCD 是承载计算单元与本地缓存的计算裸片；MFMA（Matrix Fused Multiply-Add）是矩阵融合乘加指令；LDS（Local Data Share）是软件管理的本地共享存储。
## 对象边界

本卡只收录能直接归到架构代际的执行组织、程序员可见数值语义、存储机制、互联协议、特殊能力和软件映射。具体 GPU/加速器的启用单元数、总峰值、HBM、封装和系统拓扑留给物理对象、SKU 或系统卡。

## 执行组织、矩阵/向量/标量路径

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA3-CU-EXEC | FIELD-COMP-EXECUTION | Compute Unit containing scalar, vector, matrix, load-store, L1 and LDS paths. | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF p.6, Figure 4 and Compute Unit Architecture paragraph |
| FACT-M2NA-CDNA3-MATRIX-EXEC | FIELD-COMP-EXECUTION | Matrix Core execution with 4:2 structured-sparse support. | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF p.8, sparse-data paragraph |
| FACT-M2NA-CDNA3-MATRIX-FORMATS | FIELD-COMP-SHARED-RESOURCE | FP64, FP32, TF32, FP16, BF16, FP8 and INT8 matrix formats. | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF p.7, Table 1 |

### 组件职责

以下组件用于保存父子结构或承接精度路径；没有独立公开值时不另造规格事实。

| component_id | 保留职责 | 数据落点 |
|---|---|---|
| COMP-M2NA-CDNA3-VECTOR | CU 下的向量执行分支。 | `PPATH-M2NA-CDNA3-VECTOR` 精度路径。 |
| COMP-M2NA-CDNA3-SCALAR | CU 下的标量执行分支。 | `FACT-M2NA-CDNA3-CU-EXEC` 的复合执行组织事实。 |
| COMP-M2NA-CDNA3-LDST | CU 下的加载/存储分支，连接 L1 和 LDS 组织。 | `FACT-M2NA-CDNA3-CU-EXEC` 及存储层次结构。 |

## 数据格式、累加与稀疏语义

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA3-FP8-A | FIELD-NUM-OPERAND-A | FP8 E4M3 or BF8 E5M2 | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF p.8, FP8 variants paragraph |
| FACT-M2NA-CDNA3-FP8-ACC | FIELD-NUM-ACCUMULATION | FP32 C and D | COND-NONE | SRC-M2NA-AMD-CDNA3-ISA，PDF p.284, V_MFMA_F32_16X16X32_FP8_FP8 description |
| FACT-M2NA-CDNA3-FP16-A | FIELD-NUM-OPERAND-A | FP16 or BF16 | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF pp.6-7, Matrix Core discussion and Table 1 |
| FACT-M2NA-CDNA3-FP16-ACC | FIELD-NUM-ACCUMULATION | FP32 C and D | COND-NONE | SRC-M2NA-AMD-CDNA3-ISA，PDF p.274, V_MFMA_F32_16X16X4_4B_F16 description |
| FACT-M2NA-CDNA3-INT8-A | FIELD-NUM-OPERAND-A | INT8 | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF pp.6-7, Matrix Core discussion and Table 1 |
| FACT-M2NA-CDNA3-INT8-ACC | FIELD-NUM-ACCUMULATION | INT32 C and D | COND-NONE | SRC-M2NA-AMD-CDNA3-ISA，PDF p.276, V_MFMA_I32_16X16X16_I8 description |
| FACT-M2NA-CDNA3-HIGH-A | FIELD-NUM-OPERAND-A | FP64, FP32 or TF32 | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF p.7, Table 1 |
| FACT-M2NA-CDNA3-SPARSE-MODE | FIELD-NUM-SPARSITY | structured_sparse | COND-M2NA-CDNA3-SPARSE | SRC-M2NA-AMD-CDNA3-ISA，PDF p.59, section 7.1.6 Sparse matrix support |

## 存储层次、带宽与管理

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA3-LDS-CAP | FIELD-MEM-CAPACITY | 65536 byte | COND-M2NA-CDNA3-LDS-CU | SRC-M2NA-AMD-CDNA3-WP，PDF p.9, first paragraph |
| FACT-M2NA-CDNA3-LDS-MGMT | FIELD-MEM-MANAGEMENT | software_scratchpad | COND-M2NA-CDNA3-LDS-CU | SRC-M2NA-AMD-CDNA3-WP，PDF pp.6 and 9, CU diagram and memory-hierarchy paragraph |
| FACT-M2NA-CDNA3-L1-CAP | FIELD-MEM-CAPACITY | 32768 byte | COND-M2NA-CDNA3-L1-CU | SRC-M2NA-AMD-CDNA3-WP，PDF p.9, first paragraph |
| FACT-M2NA-CDNA3-L1-GRAN | FIELD-MEM-GRANULARITY | 128 byte | COND-M2NA-CDNA3-L1-CU | SRC-M2NA-AMD-CDNA3-WP，PDF p.9, first paragraph |
| FACT-M2NA-CDNA3-L1-MGMT | FIELD-MEM-MANAGEMENT | hardware_cache | COND-M2NA-CDNA3-L1-CU | SRC-M2NA-AMD-CDNA3-WP，PDF p.9, first paragraph |
| FACT-M2NA-CDNA3-L2-CAP | FIELD-MEM-CAPACITY | 4194304 byte | COND-M2NA-CDNA3-L2-XCD | SRC-M2NA-AMD-CDNA3-WP，PDF p.10, first paragraph |
| FACT-M2NA-CDNA3-L2-READ | FIELD-MEM-READ-TRANSFER-PER-CYCLE | 2048 byte/cycle | COND-M2NA-CDNA3-L2-XCD | SRC-M2NA-AMD-CDNA3-WP，PDF p.10, first paragraph |
| FACT-M2NA-CDNA3-L2-MGMT | FIELD-MEM-MANAGEMENT | hardware_cache | COND-M2NA-CDNA3-L2-XCD | SRC-M2NA-AMD-CDNA3-WP，PDF p.10, first two paragraphs |
| FACT-M2NA-CDNA3-ICACHE-MGMT | FIELD-MEM-MANAGEMENT | hardware_cache | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF pp.9-11, Infinity Cache discussion |
| FACT-M2NA-CDNA3-ICACHE-CONSISTENCY | FIELD-MEM-CONSISTENCY | Memory-side cache and snoop-filter role. It does not hold dirty evictions from lower-level L2 caches. | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF p.10, Infinity Cache paragraph |

## 互联机制

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA3-IF-PROTOCOL | FIELD-INT-PROTOCOL | AMD Infinity Fabric technology | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF pp.2 and 4, package overview |

## 特殊算子与专用能力

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA3-SPARSE-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | dedicated_instruction | COND-M2NA-CDNA3-SPARSE | SRC-M2NA-AMD-CDNA3-ISA，PDF pp.59-60, section 7.1.6 Sparse matrix support and Table 32 |
| FACT-M2NA-CDNA3-SPARSE-DETAIL | FIELD-CAP-IMPLEMENTATION-DETAIL | At least two input values in each group of four are zero; compact non-zero data plus location metadata can double matrix throughput. | COND-M2NA-CDNA3-SPARSE | SRC-M2NA-AMD-CDNA3-WP，PDF p.8, sparse-data paragraph |

## 软件映射

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA3-SW | FIELD-SW-PROGRAMMING-MODEL | ROCm and HIP | COND-NONE | SRC-M2NA-AMD-CDNA3-WP，PDF pp.19-20, ROCm software section |

## 缺失项与不适用项

| requirement_id | 目标/字段 | 状态 | search_id | 适用性理由 |
|---|---|---|---|---|
| REQ-M2NA-GAP-0037 | OBJ-AMD-CDNA3-ARCH / FIELD-COMP-VENDOR-AI-TOPS | not_applicable | 不需要 | 架构代际没有一项脱离具体实现仍成立的加速器总峰值；总量应归裸片、封装、模组、卡或系统对象。 |
| REQ-M2NA-GAP-0038 | OBJ-AMD-CDNA3-ARCH / FIELD-PHY-PROCESS | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0039 | OBJ-AMD-CDNA3-ARCH / FIELD-PHY-DIE-COUNT | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0040 | OBJ-AMD-CDNA3-ARCH / FIELD-PHY-PACKAGE | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0041 | OBJ-AMD-CDNA3-ARCH / FIELD-DER-COMPUTE-BW-SPEC | not_found | SEARCH-M2NA-0013 | 完成对象边界与条件对齐后，没有找到同精度、同作用域的架构计算吞吐与存储带宽对。 |
| REQ-M2NA-GAP-0042 | OBJ-AMD-CDNA3-ARCH / FIELD-DER-MATRIX-VECTOR | not_found | SEARCH-M2NA-0014 | 没有找到精度、作用域和运算计数口径都一致的矩阵/向量吞吐对。 |
| REQ-M2NA-GAP-0087 | PPATH-M2NA-CDNA3-MFMA-FP8 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0042 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0088 | PPATH-M2NA-CDNA3-MFMA-FP16BF16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0043 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0089 | PPATH-M2NA-CDNA3-MFMA-INT8 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0044 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0090 | PPATH-M2NA-CDNA3-MFMA-HIGH / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0045 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0091 | PPATH-M2NA-CDNA3-SMFMAC / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0046 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0092 | PPATH-M2NA-CDNA3-VECTOR / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0047 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0131 | COMP-M2NA-CDNA3-LDS / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0086 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0132 | COMP-M2NA-CDNA3-LDS / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0087 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0133 | COMP-M2NA-CDNA3-L1 / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0088 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0134 | COMP-M2NA-CDNA3-L1 / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0089 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0135 | COMP-M2NA-CDNA3-L2 / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0090 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0136 | COMP-M2NA-CDNA3-ICACHE / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0091 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0137 | COMP-M2NA-CDNA3-ICACHE / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0092 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0158 | LINK-M2NA-CDNA3-IF-PKG / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0159 | LINK-M2NA-CDNA3-IF-P2P / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0175 | CAP-M2NA-CDNA3-MOE / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0118 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |
| REQ-M2NA-GAP-0176 | CAP-M2NA-CDNA3-TOPK / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0119 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |

## 最小来源与反向移除

| source_id | 定位 | 独有贡献 / 不采用理由 |
|---|---|---|
| SRC-M2NA-AMD-CDNA3-WP | Architecture and memory hierarchy sections；p.5, Compute Unit block diagram；p.8；p.9 | CDNA 3 主架构来源；支撑 CU/矩阵组织、LDS/L1/L2/Infinity Cache 层次、片上带宽和 Infinity Fabric 4。 |
| SRC-M2NA-AMD-CDNA3-ISA | MFMA FP16 and BF16 instruction tables；MFMA FP8 and BF8 instruction tables；MFMA INT8 instruction tables；V_SMFMAC section, p.59 | 补足 FP8/BF8、FP16/BF16、INT8 的 C/D 格式与 4:2 稀疏 V_SMFMAC 语义。 |

## 实现边界与冲突

未发现需要建立 conflict-group 的同条件直接冲突。产品表、系统表与架构定义如果数值不同，先按对象或条件分层，不视为同一事实冲突。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | partial | 已记录 CU、稠密/4:2 稀疏 MFMA 与格式范围；缺同口径矩阵/向量吞吐对。 |
| numerics | partial | 已记录 FP8/BF8、FP16/BF16、INT8 的 C/D 格式和稀疏语义；物理累加器位宽未找到。 |
| memory | partial | 已记录每 CU 的 LDS/L1、每 XCD 的 L2 及 Infinity Cache 角色；部分写带宽和存算比缺失。 |
| interconnect | partial | 只评价架构级互联机制，不混入产品或系统聚合值。 |
| special_engines | partial | 已记录 4:2 稀疏 V_SMFMAC；专用 MoE routing/top-k 实现未找到。 |
| software | complete | 白皮书直接确认 ROCm 与 HIP 编程映射。 |
| evidence | complete | 只使用一手来源，并保留筛选与反向移除记录。 |

## 自检与复核

- 本卡的 fact_id、requirement_id、search_id、source_id 均来自本 staging 结构化片段；总控合并前状态均为 draft 或 needs_resolution。
- 本卡中的 per-CU、per-WGP 或 per-XCD 数值均保留显式 condition_set；不是芯片总量。
- 主键、外键、枚举、七目标 XOR 与中文润色检查在交付前统一执行；检查结果写入 README 和 notes。
