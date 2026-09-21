# NVIDIA Ampere 架构资料卡（草稿）

> 对象：OBJ-NVIDIA-AMPERE-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：draft。


术语：SM（Streaming Multiprocessor，流式多处理器）是 NVIDIA 的核心执行组织；SIMT（Single Instruction, Multiple Threads，单指令多线程）描述线程束执行方式。
## 对象边界

本卡只收录能直接归到架构代际的执行组织、程序员可见数值语义、存储机制、互联协议、特殊能力和软件映射。具体 GPU/加速器的启用单元数、总峰值、HBM、封装和系统拓扑留给物理对象、SKU 或系统卡。

## 执行组织、矩阵/向量/标量路径

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-AMPERE-SM-EXEC | FIELD-COMP-EXECUTION | SIMT Streaming Multiprocessor with separate CUDA ALU, Tensor Core, load-store, special-function and control resources. | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.22, Figure 7, GA100 Streaming Multiprocessor labels |
| FACT-M2NA-AMPERE-TENSOR-EXEC | FIELD-COMP-EXECUTION | Third-generation Tensor Core matrix fused-multiply-add path. | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.20, A100 SM Architecture |
| FACT-M2NA-AMPERE-TENSOR-FORMATS | FIELD-COMP-SHARED-RESOURCE | FP16, BF16, TF32, IEEE FP64, INT8, INT4 and binary matrix formats. | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.20, Third-generation Tensor Cores bullet |
| FACT-M2NA-AMPERE-CUDA-EXEC | FIELD-COMP-EXECUTION | Per-thread SIMT FP32 and integer ALU execution path. | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.22, Figure 7, SM processing-block labels |
| FACT-M2NA-AMPERE-ASYNC-EXEC | FIELD-COMP-EXECUTION | Asynchronous global-memory to shared-memory copy without register-file staging, paired with asynchronous barriers. | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.21, A100 SM feature bullets |

### 组件职责

以下组件用于保存父子结构或承接精度路径；没有独立公开值时不另造规格事实。

| component_id | 保留职责 | 数据落点 |
|---|---|---|
| COMP-M2NA-AMPERE-SFU | SM 下的特殊函数执行分支。 | `FACT-M2NA-AMPERE-SM-EXEC` 的执行组织事实。 |

## 数据格式、累加与稀疏语义

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-AMPERE-FP16-A | FIELD-NUM-OPERAND-A | FP16 | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.21, Tensor Core feature bullets |
| FACT-M2NA-AMPERE-FP16-B | FIELD-NUM-OPERAND-B | FP16 | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.21, Tensor Core feature bullets |
| FACT-M2NA-AMPERE-FP16-ACC | FIELD-NUM-ACCUMULATION | FP32 | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.21, Tensor Core feature bullets |
| FACT-M2NA-AMPERE-BF16-A | FIELD-NUM-OPERAND-A | BF16 | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.21, Tensor Core feature bullets |
| FACT-M2NA-AMPERE-BF16-ACC | FIELD-NUM-ACCUMULATION | FP32 | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.21, Tensor Core feature bullets |
| FACT-M2NA-AMPERE-TF32-A | FIELD-NUM-OPERAND-A | TF32 derived from FP32 input | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.21, Tensor Core feature bullets |
| FACT-M2NA-AMPERE-TF32-ACC | FIELD-NUM-ACCUMULATION | FP32 | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.21, Tensor Core feature bullets |
| FACT-M2NA-AMPERE-FP64-A | FIELD-NUM-OPERAND-A | IEEE FP64 | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.15, A100 SM section |
| FACT-M2NA-AMPERE-INT-A | FIELD-NUM-OPERAND-A | INT8, INT4 or binary depending on instruction mode | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.20, Third-generation Tensor Cores bullet |

## 存储层次、带宽与管理

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-AMPERE-L1SMEM-MGMT | FIELD-MEM-MANAGEMENT | mixed | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.21, A100 SM feature bullets |
| FACT-M2NA-AMPERE-L1SMEM-SCOPE | FIELD-MEM-LOCALITY-SCOPE | core | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.15, A100 GPU Key Features Summary |

## 互联机制

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-AMPERE-NVLINK-PROTOCOL | FIELD-INT-PROTOCOL | Third-generation NVLink | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF pp.16-17, Third-Generation NVLink |

## 特殊算子与专用能力

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-AMPERE-SPARSE-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | dedicated_instruction | COND-M2NA-AMPERE-2OF4 | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.32, Sparse Matrix Multiply-Accumulate Operations |
| FACT-M2NA-AMPERE-SPARSE-DETAIL | FIELD-CAP-IMPLEMENTATION-DETAIL | Hardware selects two nonzero values from each group of four and skips multiplication by the structured zeros. | COND-M2NA-AMPERE-2OF4 | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.32, Sparse Matrix Multiply-Accumulate Operations |
| FACT-M2NA-AMPERE-ASYNC-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | dedicated_instruction | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.21, A100 SM feature bullets |

## 软件映射

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-AMPERE-SW | FIELD-SW-PROGRAMMING-MODEL | CUDA exposes Ampere asynchronous-copy and barrier capabilities. | COND-NONE | SRC-M2NA-NVIDIA-AMPERE-WP-2020，PDF p.17, Asynchronous Barrier |

## 缺失项与不适用项

| requirement_id | 目标/字段 | 状态 | search_id | 适用性理由 |
|---|---|---|---|---|
| REQ-M2NA-GAP-0001 | OBJ-NVIDIA-AMPERE-ARCH / FIELD-COMP-VENDOR-AI-TOPS | not_applicable | 不需要 | 架构代际没有一项脱离具体实现仍成立的加速器总峰值；总量应归裸片、封装、模组、卡或系统对象。 |
| REQ-M2NA-GAP-0002 | OBJ-NVIDIA-AMPERE-ARCH / FIELD-PHY-PROCESS | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0003 | OBJ-NVIDIA-AMPERE-ARCH / FIELD-PHY-DIE-COUNT | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0004 | OBJ-NVIDIA-AMPERE-ARCH / FIELD-PHY-PACKAGE | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0005 | OBJ-NVIDIA-AMPERE-ARCH / FIELD-DER-COMPUTE-BW-SPEC | not_found | SEARCH-M2NA-0001 | 完成对象边界与条件对齐后，没有找到同精度、同作用域的架构计算吞吐与存储带宽对。 |
| REQ-M2NA-GAP-0006 | OBJ-NVIDIA-AMPERE-ARCH / FIELD-DER-MATRIX-VECTOR | not_found | SEARCH-M2NA-0002 | 没有找到精度、作用域和运算计数口径都一致的矩阵/向量吞吐对。 |
| REQ-M2NA-GAP-0059 | PPATH-M2NA-AMPERE-TENSOR-FP16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0019 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0060 | PPATH-M2NA-AMPERE-TENSOR-BF16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0020 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0061 | PPATH-M2NA-AMPERE-TENSOR-TF32 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0021 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0062 | PPATH-M2NA-AMPERE-TENSOR-FP64 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0022 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0063 | PPATH-M2NA-AMPERE-TENSOR-INT8 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0023 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0064 | PPATH-M2NA-AMPERE-CUDA-FP32 / FIELD-NUM-PHYSICAL-ACCUM | not_applicable | 不需要 | 该标量或特殊函数路径不按矩阵/向量累加路径建模。 |
| REQ-M2NA-GAP-0109 | COMP-M2NA-AMPERE-REG / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0064 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0110 | COMP-M2NA-AMPERE-REG / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0065 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0111 | COMP-M2NA-AMPERE-L1SMEM / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0066 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0112 | COMP-M2NA-AMPERE-L1SMEM / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0067 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0113 | COMP-M2NA-AMPERE-L2 / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0068 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0114 | COMP-M2NA-AMPERE-L2 / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0069 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0151 | LINK-M2NA-AMPERE-NVLINK3 / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0163 | CAP-M2NA-AMPERE-MOE / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0106 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |
| REQ-M2NA-GAP-0164 | CAP-M2NA-AMPERE-TOPK / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0107 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |

## 最小来源与反向移除

| source_id | 定位 | 独有贡献 / 不采用理由 |
|---|---|---|
| SRC-M2NA-NVIDIA-AMPERE-WP-2020 | p.20；p.20, Figure 10；p.21；p.21, Asynchronous Copy and Barrier | Ampere 的唯一主架构固定来源；移除后第三代 Tensor Core 格式、2:4 稀疏、异步复制、统一 L1/共享内存和 NVLink 3 机制均失去一手定位。 |

## 实现边界与冲突

未发现需要建立 conflict-group 的同条件直接冲突。产品表、系统表与架构定义如果数值不同，先按对象或条件分层，不视为同一事实冲突。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | partial | 已记录 SM、Tensor Core、CUDA 标量路径和异步复制；没有可跨实现使用的架构总吞吐。 |
| numerics | partial | 已记录 FP16/BF16/TF32/FP64/整数输入及程序员可见累加格式；物理累加器位宽未找到。 |
| memory | partial | 已记录统一 L1/共享内存的管理与作用域；寄存器、L1、L2 的架构级带宽未找到。 |
| interconnect | partial | 只评价架构级互联机制，不混入产品或系统聚合值。 |
| special_engines | partial | 已记录 2:4 稀疏和异步复制指令；专用 MoE routing/top-k 实现未找到。 |
| software | partial | 白皮书直接给出 CUDA 异步复制与 barrier 的程序员映射；本卡未扩展到编译器、运行时和库。 |
| evidence | complete | 只使用一手来源，并保留筛选与反向移除记录。 |

## 自检与复核

- 本卡的 fact_id、requirement_id、search_id、source_id 均来自本 staging 结构化片段；总控合并前状态均为 draft 或 needs_resolution。
- 本卡事实只挂一个目标主语；SKU、模组、封装和系统聚合值未上卷到架构对象。
- 主键、外键、枚举、七目标 XOR 与中文润色检查在交付前统一执行；检查结果写入 README 和 notes。
