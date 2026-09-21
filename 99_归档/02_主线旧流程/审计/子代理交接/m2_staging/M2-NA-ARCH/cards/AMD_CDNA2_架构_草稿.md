# AMD CDNA 2 架构资料卡（草稿）

> 对象：OBJ-AMD-CDNA2-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：draft。


术语：CU（Compute Unit，计算单元）是 CDNA 2 的执行组织；SIMD 指单指令多数据；MFMA（Matrix Fused Multiply-Add）是矩阵融合乘加指令；LDS（Local Data Share）是软件管理的本地共享存储。
## 对象边界

本卡只收录能直接归到架构代际的执行组织、程序员可见数值语义、存储机制、互联协议、特殊能力和软件映射。具体 GPU/加速器的启用单元数、总峰值、HBM、封装和系统拓扑留给物理对象、SKU 或系统卡。

## 执行组织、矩阵/向量/标量路径

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA2-CU-EXEC | FIELD-COMP-EXECUTION | Wave64 Compute Unit with scalar, vector, matrix and memory paths. | COND-NONE | SRC-M2NA-AMD-CDNA2-WP，PDF p.10, Figure 3 and Shader Array discussion |
| FACT-M2NA-CDNA2-VECTOR-COUNT | FIELD-COMP-UNIT-COUNT | 4 count | COND-M2NA-CDNA2-CU | SRC-M2NA-AMD-CDNA2-WP，PDF p.10, Figure 3 |
| FACT-M2NA-CDNA2-VECTOR-WIDTH | FIELD-COMP-ISSUE-WIDTH | 16 lane | COND-M2NA-CDNA2-CU | SRC-M2NA-AMD-CDNA2-WP，PDF p.10, Figure 3 |
| FACT-M2NA-CDNA2-VECTOR-EXEC | FIELD-COMP-EXECUTION | Four 16-wide SIMD units execute a Wave64, with FP64 vector rate equal to FP32. | COND-NONE | SRC-M2NA-AMD-CDNA2-WP，PDF p.10, Compute Unit discussion |
| FACT-M2NA-CDNA2-MATRIX-EXEC | FIELD-COMP-EXECUTION | Wave-wide MFMA matrix operations, including native FP64 matrix fused multiply-add. | COND-NONE | SRC-M2NA-AMD-CDNA2-WP，PDF p.11, Matrix Core Technology discussion |
| FACT-M2NA-CDNA2-VFP64-THR | FIELD-COMP-THROUGHPUT | 64 FMA/cycle/CU | COND-M2NA-CDNA2-VECTOR-FP64 | SRC-M2NA-AMD-CDNA2-WP，PDF p.10, Compute Unit discussion |
| FACT-M2NA-CDNA2-PFP32-THR | FIELD-COMP-THROUGHPUT | 128 FMA/cycle/CU | COND-M2NA-CDNA2-PACKED-FP32 | SRC-M2NA-AMD-CDNA2-WP，PDF p.10, Compute Unit discussion |
| FACT-M2NA-CDNA2-FP64-TILE | FIELD-COMP-INSTRUCTION-TILE | 16x16x4 and 4x4x4 wave-wide FP64 matrix forms. | COND-NONE | SRC-M2NA-AMD-CDNA2-WP，PDF p.11, Matrix Core Technology discussion |

### 组件职责

以下组件用于保存父子结构或承接精度路径；没有独立公开值时不另造规格事实。

| component_id | 保留职责 | 数据落点 |
|---|---|---|
| COMP-M2NA-CDNA2-SCALAR | CU 下的标量执行分支。 | `FACT-M2NA-CDNA2-CU-EXEC` 的复合执行组织事实。 |

## 数据格式、累加与稀疏语义

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA2-FP64-A | FIELD-NUM-OPERAND-A | FP64 | COND-NONE | SRC-M2NA-AMD-CDNA2-WP，PDF p.11, Matrix Core Technology discussion |
| FACT-M2NA-CDNA2-FP16-A | FIELD-NUM-OPERAND-A | FP16 | COND-NONE | SRC-M2NA-AMD-CDNA2-ISA，PDF pp.52-53, section 7.1 Matrix Arithmetic Opcodes, MFMA naming and Table 25 |
| FACT-M2NA-CDNA2-FP16-ACC | FIELD-NUM-ACCUMULATION | FP32 C and D in the selected MFMA forms | COND-NONE | SRC-M2NA-AMD-CDNA2-ISA，PDF pp.52-53, section 7.1, MFMA instruction naming |
| FACT-M2NA-CDNA2-BF16-A | FIELD-NUM-OPERAND-A | BF16 | COND-NONE | SRC-M2NA-AMD-CDNA2-WP，PDF p.11, Matrix Core Technology closing paragraph |
| FACT-M2NA-CDNA2-BF16-ACC | FIELD-NUM-ACCUMULATION | FP32 C and D in the selected MFMA forms | COND-NONE | SRC-M2NA-AMD-CDNA2-ISA，PDF pp.52-53, section 7.1, MFMA naming and BF16 row in Table 25 |

## 存储层次、带宽与管理

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA2-LDS-MGMT | FIELD-MEM-MANAGEMENT | software_scratchpad | COND-NONE | SRC-M2NA-AMD-CDNA2-WP，PDF p.10, Local Data Share paragraph |
| FACT-M2NA-CDNA2-LDS-DMA | FIELD-MEM-DMA | Supports FP64 atomic operations in LDS. | COND-NONE | SRC-M2NA-AMD-CDNA2-WP，PDF p.10, Local Data Share paragraph |

## 互联机制

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA2-IF-PROTOCOL | FIELD-INT-PROTOCOL | AMD Infinity Fabric with coherent package connectivity. | COND-NONE | SRC-M2NA-AMD-CDNA2-WP，PDF pp.5 and 8, Communication and Scaling |

## 软件映射

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA2-SW | FIELD-SW-PROGRAMMING-MODEL | ROCm with HIP, compilers, runtimes and libraries. | COND-NONE | SRC-M2NA-AMD-CDNA2-WP，PDF pp.12-13, ROCm Open Software Platform and Figure 5 |

## 缺失项与不适用项

| requirement_id | 目标/字段 | 状态 | search_id | 适用性理由 |
|---|---|---|---|---|
| REQ-M2NA-GAP-0031 | OBJ-AMD-CDNA2-ARCH / FIELD-COMP-VENDOR-AI-TOPS | not_applicable | 不需要 | 架构代际没有一项脱离具体实现仍成立的加速器总峰值；总量应归裸片、封装、模组、卡或系统对象。 |
| REQ-M2NA-GAP-0032 | OBJ-AMD-CDNA2-ARCH / FIELD-PHY-PROCESS | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0033 | OBJ-AMD-CDNA2-ARCH / FIELD-PHY-DIE-COUNT | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0034 | OBJ-AMD-CDNA2-ARCH / FIELD-PHY-PACKAGE | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0035 | OBJ-AMD-CDNA2-ARCH / FIELD-DER-COMPUTE-BW-SPEC | not_found | SEARCH-M2NA-0011 | 完成对象边界与条件对齐后，没有找到同精度、同作用域的架构计算吞吐与存储带宽对。 |
| REQ-M2NA-GAP-0036 | OBJ-AMD-CDNA2-ARCH / FIELD-DER-MATRIX-VECTOR | not_found | SEARCH-M2NA-0012 | 没有找到精度、作用域和运算计数口径都一致的矩阵/向量吞吐对。 |
| REQ-M2NA-GAP-0082 | PPATH-M2NA-CDNA2-MFMA-FP64 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0037 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0083 | PPATH-M2NA-CDNA2-MFMA-FP16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0038 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0084 | PPATH-M2NA-CDNA2-MFMA-BF16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0039 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0085 | PPATH-M2NA-CDNA2-VECTOR-FP64 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0040 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0086 | PPATH-M2NA-CDNA2-VECTOR-PACKED-FP32 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0041 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0125 | COMP-M2NA-CDNA2-LDS / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0080 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0126 | COMP-M2NA-CDNA2-LDS / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0081 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0127 | COMP-M2NA-CDNA2-L1 / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0082 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0128 | COMP-M2NA-CDNA2-L1 / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0083 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0129 | COMP-M2NA-CDNA2-L2 / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0084 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0130 | COMP-M2NA-CDNA2-L2 / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0085 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0156 | LINK-M2NA-CDNA2-IF-PKG / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0157 | LINK-M2NA-CDNA2-IF-P2P / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0173 | CAP-M2NA-CDNA2-MOE / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0116 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |
| REQ-M2NA-GAP-0174 | CAP-M2NA-CDNA2-TOPK / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0117 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |

## 最小来源与反向移除

| source_id | 定位 | 独有贡献 / 不采用理由 |
|---|---|---|
| SRC-M2NA-AMD-CDNA2-WP | p.10；p.12, Packed FP32；p.13, ROCm software platform；p.9 | CDNA 2 主架构来源；支撑 Wave64 CU、4×16-wide SIMD、MFMA、LDS 与 Infinity Fabric 机制。 |
| SRC-M2NA-AMD-CDNA2-ISA | MFMA naming and BF16 forms；MFMA naming and matrix format tables, pp.52-53；MFMA naming, pp.52-53 | 补足白皮书未系统说明的 MFMA A/B 与 C/D 格式，尤其 FP16/BF16 到 FP32 的程序员可见累加语义。 |

## 实现边界与冲突

未发现需要建立 conflict-group 的同条件直接冲突。产品表、系统表与架构定义如果数值不同，先按对象或条件分层，不视为同一事实冲突。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | partial | 已记录 Wave64 CU、4×16-wide SIMD、矩阵与向量路径及每 CU 吞吐；没有独立于实现的芯片总峰值。 |
| numerics | partial | 已记录 FP64、FP16/BF16 到 FP32 的 MFMA 接口；物理累加器位宽未找到。 |
| memory | partial | 已记录 LDS 管理和 FP64 原子能力；LDS/L1/L2 架构级读写带宽未找到。 |
| interconnect | partial | 只评价架构级互联机制，不混入产品或系统聚合值。 |
| special_engines | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| software | complete | 白皮书直接给出 ROCm、HIP、编译器、运行时和库的映射。 |
| evidence | complete | 只使用一手来源，并保留筛选与反向移除记录。 |

## 自检与复核

- 本卡的 fact_id、requirement_id、search_id、source_id 均来自本 staging 结构化片段；总控合并前状态均为 draft 或 needs_resolution。
- 本卡中的 per-CU、per-WGP 或 per-XCD 数值均保留显式 condition_set；不是芯片总量。
- 主键、外键、枚举、七目标 XOR 与中文润色检查在交付前统一执行；检查结果写入 README 和 notes。
