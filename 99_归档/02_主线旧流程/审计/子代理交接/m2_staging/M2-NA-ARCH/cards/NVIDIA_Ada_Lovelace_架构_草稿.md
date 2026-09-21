# NVIDIA Ada Lovelace 架构资料卡（草稿）

> 对象：OBJ-NVIDIA-ADA-LOVELACE-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：draft。


术语：SM（Streaming Multiprocessor，流式多处理器）是 NVIDIA 的核心执行组织；SIMT（Single Instruction, Multiple Threads，单指令多线程）描述线程束执行方式。
## 对象边界

本卡只收录能直接归到架构代际的执行组织、程序员可见数值语义、存储机制、互联协议、特殊能力和软件映射。具体 GPU/加速器的启用单元数、总峰值、HBM、封装和系统拓扑留给物理对象、SKU 或系统卡。

## 执行组织、矩阵/向量/标量路径

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-ADA-SM-EXEC | FIELD-COMP-EXECUTION | SIMT Streaming Multiprocessor with CUDA ALU, Tensor Core and special-function paths. | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF p.10, Ada SM processing-block paragraph |
| FACT-M2NA-ADA-TENSOR-EXEC | FIELD-COMP-EXECUTION | Fourth-generation Tensor Core with FP8 support. | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF pp.8, 10, Ada SM |
| FACT-M2NA-ADA-TENSOR-FORMATS | FIELD-COMP-SHARED-RESOURCE | FP8, FP16, BF16, TF32, INT8 and INT4 matrix formats. | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF pp.24, 27 and p.30 Table 2 |

### 组件职责

以下组件用于保存父子结构或承接精度路径；没有独立公开值时不另造规格事实。

| component_id | 保留职责 | 数据落点 |
|---|---|---|
| COMP-M2NA-ADA-CUDA | SM 下的 CUDA 标量/向量算术分支。 | `PPATH-M2NA-ADA-CUDA-FP32` 精度路径。 |
| COMP-M2NA-ADA-SFU | SM 下的特殊函数执行分支。 | `FACT-M2NA-ADA-SM-EXEC` 的执行组织事实。 |

## 数据格式、累加与稀疏语义

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-ADA-FP8-A | FIELD-NUM-OPERAND-A | FP8 | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF p.30, Table 2, FP8 Tensor rows |
| FACT-M2NA-ADA-FP8-ACC | FIELD-NUM-ACCUMULATION | FP16 or FP32 | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF p.30, Table 2, FP8 Tensor rows |
| FACT-M2NA-ADA-FP16-ACC | FIELD-NUM-ACCUMULATION | FP16 or FP32 | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF p.30, Table 2, FP16 Tensor rows |
| FACT-M2NA-ADA-BF16-ACC | FIELD-NUM-ACCUMULATION | FP32 | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF p.30, Table 2, BF16 Tensor row |
| FACT-M2NA-ADA-TF32-A | FIELD-NUM-OPERAND-A | TF32 | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF p.30, Table 2, TF32 Tensor row |
| FACT-M2NA-ADA-INT-A | FIELD-NUM-OPERAND-A | INT8 or INT4 | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF p.30, Table 2, INT Tensor rows |

## 存储层次、带宽与管理

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-ADA-L1SMEM-MGMT | FIELD-MEM-MANAGEMENT | mixed | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF p.12, Memory Subsystem |
| FACT-M2NA-ADA-L1SMEM-SCOPE | FIELD-MEM-LOCALITY-SCOPE | core | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF p.12, Memory Subsystem |

## 特殊算子与专用能力

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-ADA-SPARSE-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | dedicated_instruction | COND-NONE | SRC-M2NA-NVIDIA-ADA-WP-2022，PDF p.30, Table 2 and footnote 2 |

## 软件映射

所选 Ada 架构白皮书没有给出可直接定位的编程模型陈述。该字段保留为 `not_found`，不再以“CUDA Core”命名推导软件映射。
## 缺失项与不适用项

| requirement_id | 目标/字段 | 状态 | search_id | 适用性理由 |
|---|---|---|---|---|
| REQ-M2NA-AVAIL-0034 | OBJ-NVIDIA-ADA-LOVELACE-ARCH / FIELD-SW-PROGRAMMING-MODEL | not_found | SEARCH-M2NA-0126 | 所选白皮书没有可直接定位的编程模型陈述；CUDA Core 命名不足以支撑该字段。 |
| REQ-M2NA-GAP-0007 | OBJ-NVIDIA-ADA-LOVELACE-ARCH / FIELD-COMP-VENDOR-AI-TOPS | not_applicable | 不需要 | 架构代际没有一项脱离具体实现仍成立的加速器总峰值；总量应归裸片、封装、模组、卡或系统对象。 |
| REQ-M2NA-GAP-0008 | OBJ-NVIDIA-ADA-LOVELACE-ARCH / FIELD-PHY-PROCESS | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0009 | OBJ-NVIDIA-ADA-LOVELACE-ARCH / FIELD-PHY-DIE-COUNT | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0010 | OBJ-NVIDIA-ADA-LOVELACE-ARCH / FIELD-PHY-PACKAGE | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0011 | OBJ-NVIDIA-ADA-LOVELACE-ARCH / FIELD-DER-COMPUTE-BW-SPEC | not_found | SEARCH-M2NA-0003 | 完成对象边界与条件对齐后，没有找到同精度、同作用域的架构计算吞吐与存储带宽对。 |
| REQ-M2NA-GAP-0012 | OBJ-NVIDIA-ADA-LOVELACE-ARCH / FIELD-DER-MATRIX-VECTOR | not_found | SEARCH-M2NA-0004 | 没有找到精度、作用域和运算计数口径都一致的矩阵/向量吞吐对。 |
| REQ-M2NA-GAP-0065 | PPATH-M2NA-ADA-TENSOR-FP8 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0024 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0066 | PPATH-M2NA-ADA-TENSOR-FP16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0025 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0067 | PPATH-M2NA-ADA-TENSOR-BF16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0026 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0068 | PPATH-M2NA-ADA-TENSOR-TF32 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0027 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0069 | PPATH-M2NA-ADA-TENSOR-INT8 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0028 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0070 | PPATH-M2NA-ADA-CUDA-FP32 / FIELD-NUM-PHYSICAL-ACCUM | not_applicable | 不需要 | 该标量或特殊函数路径不按矩阵/向量累加路径建模。 |
| REQ-M2NA-GAP-0115 | COMP-M2NA-ADA-L1SMEM / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0070 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0116 | COMP-M2NA-ADA-L1SMEM / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0071 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0117 | COMP-M2NA-ADA-L2 / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0072 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0118 | COMP-M2NA-ADA-L2 / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0073 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0165 | CAP-M2NA-ADA-MOE / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0108 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |
| REQ-M2NA-GAP-0166 | CAP-M2NA-ADA-TOPK / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0109 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |

## 最小来源与反向移除

| source_id | 定位 | 独有贡献 / 不采用理由 |
|---|---|---|
| SRC-M2NA-NVIDIA-ADA-WP-2022 | Ada SM memory hierarchy；p.30；p.30, Tensor Core precision table；pp.23-30, Ada SM | Ada 的唯一主架构固定来源；直接支撑第四代 Tensor Core、FP8 累加选项、统一 L1/共享内存和结构化稀疏语义。 |

## 实现边界与冲突

未发现需要建立 conflict-group 的同条件直接冲突。产品表、系统表与架构定义如果数值不同，先按对象或条件分层，不视为同一事实冲突。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | partial | 已记录 SM 与第四代 Tensor Core；架构对象没有可独立于具体 GPU 的总吞吐。 |
| numerics | partial | 已记录 FP8/FP16/BF16/TF32/INT8/INT4 及可见累加格式；物理累加器位宽未找到。 |
| memory | partial | 已记录统一 L1/共享内存的管理与作用域；L1/L2 架构级容量和带宽未采用 RTX 4090 数字补齐。 |
| interconnect | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| special_engines | partial | 已记录 Tensor Core 稀疏指令；专用 MoE routing/top-k 实现未找到。 |
| software | missing_public_data | 所选白皮书没有可直接定位的编程模型陈述，检索结果保留为 not_found。 |
| evidence | complete | 只使用一手来源，并保留筛选与反向移除记录。 |

## 自检与复核

- 本卡的 fact_id、requirement_id、search_id、source_id 均来自本 staging 结构化片段；总控合并前状态均为 draft 或 needs_resolution。
- 本卡事实只挂一个目标主语；SKU、模组、封装和系统聚合值未上卷到架构对象。
- 主键、外键、枚举、七目标 XOR 与中文润色检查在交付前统一执行；检查结果写入 README 和 notes。
