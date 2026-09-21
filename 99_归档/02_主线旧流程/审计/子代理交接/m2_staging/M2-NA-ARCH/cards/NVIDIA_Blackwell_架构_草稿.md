# NVIDIA Blackwell 架构资料卡（草稿）

> 对象：OBJ-NVIDIA-BLACKWELL-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：draft。


术语：PTX（Parallel Thread Execution）是 NVIDIA 的虚拟指令集；CTA（Cooperative Thread Array）对应 CUDA thread block；TMA（Tensor Memory Accelerator）是描述符驱动的张量数据搬运机制；RAS 指可靠性、可用性与可维护性。
## 对象边界

本卡只收录能直接归到架构代际的执行组织、程序员可见数值语义、存储机制、互联协议、特殊能力和软件映射。具体 GPU/加速器的启用单元数、总峰值、HBM、封装和系统拓扑留给物理对象、SKU 或系统卡。

## 执行组织、矩阵/向量/标量路径

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-BLACKWELL-TENSOR-EXEC | FIELD-COMP-EXECUTION | Fifth-generation Tensor Core matrix path with micro-tensor scaling and structured-sparse instruction forms. | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF p.8, Blackwell Tensor Core Architecture |
| FACT-M2NA-BLACKWELL-TENSOR-FORMATS | FIELD-COMP-SHARED-RESOURCE | FP64, FP32, TF32, FP16, BF16, FP8, INT8, FP6 and FP4. | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF p.8, Table 1 |
| FACT-M2NA-BLACKWELL-TMA-EXEC | FIELD-COMP-EXECUTION | Tensor-map-driven asynchronous tensor copy among global and shared state spaces, supporting one to five dimensions. | COND-NONE | SRC-M2NA-NVIDIA-PTX-ISA-9-3，PTX ISA 9.3, section 9.7.9.26.5.2 cp.async.bulk.tensor, lines 11448-11464 |

### 组件职责

以下组件用于保存父子结构或承接精度路径；没有独立公开值时不另造规格事实。

| component_id | 保留职责 | 数据落点 |
|---|---|---|
| COMP-M2NA-BLACKWELL-SM | Tensor Core、CUDA、SFU、TMA、TMEM 和 L1/共享存储组件的父级。 | 组件父子关系。 |
| COMP-M2NA-BLACKWELL-CUDA | SM 下的 CUDA 算术分支。 | `PPATH-M2NA-BLACKWELL-CUDA` 精度路径。 |
| COMP-M2NA-BLACKWELL-SFU | SM 下的特殊函数执行分支。 | 组件父子关系；来源没有给出可单列的架构代际定值。 |
| COMP-M2NA-BLACKWELL-RAS | Blackwell 的可靠性、可用性与可维护性引擎。 | `FACT-M2NA-BLACKWELL-RAS`；字段目标类型要求该事实落在架构对象。 |

## 数据格式、累加与稀疏语义

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-BLACKWELL-FP4-A | FIELD-NUM-OPERAND-A | FP4 | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF pp.8-9, Tensor Core and Transformer Engine sections |
| FACT-M2NA-BLACKWELL-FP4-SCALE | FIELD-NUM-SCALING-MODE | per_block | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-HC36-2024，Hot Chips PDF p.14, 5th Gen Tensor Core |
| FACT-M2NA-BLACKWELL-FP4-GRAN | FIELD-NUM-SCALING-GRANULARITY | Micro-tensor block with scale factors on fixed vectors. Exact instruction granularity depends on PTX form. | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-HC36-2024，Hot Chips PDF p.14, 5th Gen Tensor Core |
| FACT-M2NA-BLACKWELL-FP6-A | FIELD-NUM-OPERAND-A | FP6 | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF p.8, Table 1 |
| FACT-M2NA-BLACKWELL-FP8-A | FIELD-NUM-OPERAND-A | FP8 | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF p.8, Table 1 |
| FACT-M2NA-BLACKWELL-FP16-A | FIELD-NUM-OPERAND-A | FP16 or BF16 | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF p.8, Table 1 |
| FACT-M2NA-BLACKWELL-HIGH-A | FIELD-NUM-OPERAND-A | TF32, FP32 or FP64 | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF p.8, Table 1 |
| FACT-M2NA-BLACKWELL-SPARSE-MODE | FIELD-NUM-SPARSITY | structured_sparse | COND-M2NA-BLACKWELL-SPARSE | SRC-M2NA-NVIDIA-PTX-ISA-9-3，PTX ISA 9.3, section 9.7.17.10.8 Sparse Matrices, lines 22615-22624 |

## 存储层次、带宽与管理

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-BLACKWELL-TMEM-MGMT | FIELD-MEM-MANAGEMENT | software_scratchpad | COND-NONE | SRC-M2NA-NVIDIA-PTX-ISA-9-3，PTX ISA 9.3, sections 9.7.17.1.2 and 9.7.17.7.1, lines 20769-20774 and 21600-21624 |
| FACT-M2NA-BLACKWELL-TMEM-LOGICAL-SPACE | FIELD-MEM-CAPACITY | 262144 byte | COND-M2NA-BLACKWELL-TMEM-CC100 | SRC-M2NA-NVIDIA-PTX-ISA-9-3，PTX ISA 9.3, section 9.7.17.1 Tensor Memory, lines 20745-20750 |
| FACT-M2NA-BLACKWELL-TMEM-GRAN | FIELD-MEM-GRANULARITY | 4 byte | COND-NONE | SRC-M2NA-NVIDIA-PTX-ISA-9-3，PTX ISA 9.3, section 9.7.17.1 Tensor Memory, line 20749 |

这里的 262144 byte 是程序员可见的每 CTA 逻辑地址空间，按 $512 \times 128 \times 32 / 8$ 规范化得到；它不是物理 SRAM 容量，也不能汇总成 GPU 总容量。

## 互联机制

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-BLACKWELL-NVHBI-PROTOCOL | FIELD-INT-PROTOCOL | NV-HBI coherent die-to-die interface mechanism. | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF p.8, opening paragraph |
| FACT-M2NA-BLACKWELL-NVLINK5-PROTOCOL | FIELD-INT-PROTOCOL | Fifth-generation NVLink | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF p.10, Fifth-Generation NVLink and NVLink Switch |

## 特殊算子与专用能力

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-BLACKWELL-TE-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | configurable_engine | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF p.9, Second-Generation Transformer Engine |
| FACT-M2NA-BLACKWELL-TE-DETAIL | FIELD-CAP-IMPLEMENTATION-DETAIL | Second-generation Transformer Engine combines Tensor Core hardware, micro-tensor scaling and software format management. | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-HC36-2024，Hot Chips PDF p.16, NVIDIA Quasar Quantization System |
| FACT-M2NA-BLACKWELL-SPARSE-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | dedicated_instruction | COND-M2NA-BLACKWELL-SPARSE | SRC-M2NA-NVIDIA-PTX-ISA-9-3，PTX ISA 9.3, sections 9.7.17.10.8 and 9.7.17.10.9.2, lines 22615-22624 and 22973-23062 |
| FACT-M2NA-BLACKWELL-TMA-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | configurable_engine | COND-NONE | SRC-M2NA-NVIDIA-PTX-ISA-9-3，PTX ISA 9.3, section 9.7.9.26.5.2 cp.async.bulk.tensor, lines 11448-11464 |
| FACT-M2NA-BLACKWELL-TMA-DETAIL | FIELD-CAP-IMPLEMENTATION-DETAIL | Descriptor-driven tensor mover used by tiled kernels. | COND-NONE | SRC-M2NA-NVIDIA-PTX-ISA-9-3，PTX ISA 9.3, section 9.7.9.26.5.2 cp.async.bulk.tensor, lines 11448-11465 |
| FACT-M2NA-BLACKWELL-RAS | FIELD-RAS-CAPABILITY | Dedicated RAS engine plus internal error detection and containment mechanisms described at architecture level. | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1，PDF pp.11-12, RAS Engine |

## 软件映射

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-BLACKWELL-SW | FIELD-SW-PROGRAMMING-MODEL | PTX exposes fifth-generation TensorCore and Tensor Memory instructions. | COND-NONE | SRC-M2NA-NVIDIA-PTX-ISA-9-3，PTX ISA 9.3, sections 9.7.17.7-9.7.17.10, lines 21600-23062 |

## 缺失项与不适用项

| requirement_id | 目标/字段 | 状态 | search_id | 适用性理由 |
|---|---|---|---|---|
| REQ-M2NA-GAP-0013 | OBJ-NVIDIA-BLACKWELL-ARCH / FIELD-COMP-VENDOR-AI-TOPS | not_applicable | 不需要 | 架构代际没有一项脱离具体实现仍成立的加速器总峰值；总量应归裸片、封装、模组、卡或系统对象。 |
| REQ-M2NA-GAP-0014 | OBJ-NVIDIA-BLACKWELL-ARCH / FIELD-PHY-PROCESS | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0015 | OBJ-NVIDIA-BLACKWELL-ARCH / FIELD-PHY-DIE-COUNT | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0016 | OBJ-NVIDIA-BLACKWELL-ARCH / FIELD-PHY-PACKAGE | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0017 | OBJ-NVIDIA-BLACKWELL-ARCH / FIELD-DER-COMPUTE-BW-SPEC | not_found | SEARCH-M2NA-0005 | 完成对象边界与条件对齐后，没有找到同精度、同作用域的架构计算吞吐与存储带宽对。 |
| REQ-M2NA-GAP-0018 | OBJ-NVIDIA-BLACKWELL-ARCH / FIELD-DER-MATRIX-VECTOR | not_found | SEARCH-M2NA-0006 | 没有找到精度、作用域和运算计数口径都一致的矩阵/向量吞吐对。 |
| REQ-M2NA-GAP-0071 | PPATH-M2NA-BLACKWELL-TENSOR-FP4 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0029 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0072 | PPATH-M2NA-BLACKWELL-TENSOR-FP6 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0030 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0073 | PPATH-M2NA-BLACKWELL-TENSOR-FP8 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0031 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0074 | PPATH-M2NA-BLACKWELL-TENSOR-FP16BF16 / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0032 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0075 | PPATH-M2NA-BLACKWELL-TENSOR-HIGH / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0033 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0076 | PPATH-M2NA-BLACKWELL-TENSOR-SPARSE / FIELD-NUM-PHYSICAL-ACCUM | not_found | SEARCH-M2NA-0034 | 所选官方架构资料和 ISA 只给出程序员可见的累加格式，没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0077 | PPATH-M2NA-BLACKWELL-CUDA / FIELD-NUM-PHYSICAL-ACCUM | not_applicable | 不需要 | 该标量或特殊函数路径不按矩阵/向量累加路径建模。 |
| REQ-M2NA-GAP-0119 | COMP-M2NA-BLACKWELL-TMEM / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0074 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0120 | COMP-M2NA-BLACKWELL-TMEM / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0075 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0121 | COMP-M2NA-BLACKWELL-L1SMEM / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0076 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0122 | COMP-M2NA-BLACKWELL-L1SMEM / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0077 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0123 | COMP-M2NA-BLACKWELL-L2 / FIELD-MEM-READ-BW | not_found | SEARCH-M2NA-0078 | 已在架构来源集中检索该存储层级的实现无关读带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0124 | COMP-M2NA-BLACKWELL-L2 / FIELD-MEM-WRITE-BW | not_found | SEARCH-M2NA-0079 | 已在架构来源集中检索该存储层级的实现无关写带宽，未找到可靠定值。 |
| REQ-M2NA-GAP-0152 | LINK-M2NA-BLACKWELL-NVHBI / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0153 | LINK-M2NA-BLACKWELL-NVLINK5 / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0167 | CAP-M2NA-BLACKWELL-MOE / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0110 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |
| REQ-M2NA-GAP-0168 | CAP-M2NA-BLACKWELL-TOPK / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0111 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |

## 最小来源与反向移除

| source_id | 定位 | 独有贡献 / 不采用理由 |
|---|---|---|
| SRC-M2NA-NVIDIA-BLACKWELL-BRIEF-V2-1 | p.8；p.9, micro-tensor scaling；pp.7, 10；pp.7, 11-12 | Blackwell 的主架构固定来源；支撑第五代 Tensor Core、FP4/FP6、第二代 Transformer Engine、NV-HBI/NVLink 5 机制和 RAS。物理解压引擎数值已因 GB200 范围移入 backlog。 |
| SRC-M2NA-NVIDIA-BLACKWELL-HC36-2024 | p.14；p.14, micro-tensor scaling；pp.14-16, Quasar and Transformer Engine | 补足技术简报没有展开的 micro-tensor 缩放与相对吞吐语义；对这些事实不可由简报完整替代。 |
| SRC-M2NA-NVIDIA-PTX-ISA-9-3 | PTX ISA 9.3, tcgen05 chapters；PTX ISA 9.3, tcgen05.cp and TMA sections；PTX ISA 9.3, tcgen05.cp, lines 21972-21994；PTX ISA 9.3, tcgen05.mma.sp | 给出 Tensor Memory 每 CTA 逻辑地址空间、动态分配、tcgen05.cp 与 tcgen05.mma.sp 的精确程序员语义；不能由宣传简报替代。 |
| SRC-M2NA-NVIDIA-BLACKWELL-TUNING-12-8 |  | 未入当前最小事实集：所需架构机制已由技术简报与 PTX 覆盖；只保留 CUDA 调优线索。 |
| SRC-M2NA-NVIDIA-BLACKWELL-DATASHEET-OCT25 |  | 未用于架构事实：内容主要是 GPU、模组和系统铭牌规格，应在后续物理对象或 SKU 卡重评。 |

## 实现边界与冲突

与本对象相关但属于封装、模组或具体产品实现的数值，见 `notes/implementation-fact-backlog.csv`。Blackwell 的双裸片、NV-HBI 10 TB/s 与 GB200 解压引擎；Rubin 的双裸片封装都未挂到架构对象。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | partial | 已记录第五代 Tensor Core 与 TMA 搬运路径；架构总峰值和完整向量吞吐未采用具体 GPU 值补齐。 |
| numerics | partial | 已记录 FP4/FP6/FP8 等输入、micro-tensor 缩放与稀疏语义；累加接口和物理累加器位宽仍缺。 |
| memory | partial | 已记录 PTX 条件下每 CTA Tensor Memory 的逻辑组织；不能解释为全芯片物理容量，L1/L2 带宽也未找到。 |
| interconnect | partial | 已记录 NV-HBI 与 NVLink 5 机制；双裸片及 10 TB/s 已下沉 implementation backlog。 |
| special_engines | partial | 已记录 Transformer Engine、TMA、结构化稀疏和 RAS；GB200 解压实现已下沉，MoE routing/top-k 未找到。 |
| software | complete | PTX 9.3 直接给出 Tensor Memory 与 tcgen05 指令的程序员映射。 |
| evidence | complete | 只使用一手来源，并保留筛选与反向移除记录。 |

## 自检与复核

- 本卡的 fact_id、requirement_id、search_id、source_id 均来自本 staging 结构化片段；总控合并前状态均为 draft 或 needs_resolution。
- 本卡事实只挂一个目标主语；SKU、模组、封装和系统聚合值未上卷到架构对象。
- 主键、外键、枚举、七目标 XOR 与中文润色检查在交付前统一执行；检查结果写入 README 和 notes。
