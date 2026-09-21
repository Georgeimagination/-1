# NVIDIA Rubin 架构资料卡

> 对象：OBJ-NVIDIA-RUBIN-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：accepted。


术语：TMA（Tensor Memory Accelerator）是描述符驱动的张量数据搬运机制；LUT（Look-Up Table，查找表）在本卡中指 3-bit 编码的矩阵 B 模式。
## 对象边界

Rubin 目前只有截止日前的 NVIDIA 官方观察文章，故本卡记录直接架构机制，并把双裸片封装等实现谓词移到 实现对象待办。产品总峰值、HBM 和系统互联聚合值不进入本卡。

## 执行组织、矩阵/向量/标量路径

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-RUBIN-TENSOR-EXEC | FIELD-COMP-EXECUTION | Third-generation Transformer Engine with doubled Tensor Core K-dimension throughput per clock and a 3-bit LUT matrix-B mode. | COND-NONE | SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721，Fixed HTML snapshot, paragraphs 21 and 37-40 |
| FACT-M2NA-RUBIN-TMA-EXEC | FIELD-COMP-EXECUTION | Inline descriptor pointer and stride overrides update tensor transfers without rebuilding full descriptors. | COND-NONE | SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721，Fixed HTML snapshot, paragraphs 33-34 |
| FACT-M2NA-RUBIN-SFU-EXEC | FIELD-COMP-EXECUTION | Exponential throughput is stated as 2 times for FP32 and 4 times for FP16 and BF16 relative to Blackwell. | COND-M2NA-RUBIN-EXP-REL | SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721，Fixed HTML snapshot, paragraph 45 |
| FACT-M2NA-RUBIN-COMPRESS-EXEC | FIELD-COMP-EXECUTION | Activation sparse compression generates nonzero values and metadata for later sparse MMA. | COND-NONE | SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721，Fixed HTML snapshot, paragraphs 43-44 |

## 数据格式、累加与稀疏语义

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-RUBIN-LUT3-B | FIELD-NUM-OPERAND-B | 3-bit LUT-encoded matrix B | COND-NONE | SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721，Fixed HTML snapshot, paragraph 40 |
| FACT-M2NA-RUBIN-SPARSE-MODE | FIELD-NUM-SPARSITY | structured_sparse | COND-NONE | SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721，Fixed HTML snapshot, paragraph 43 |

## 互联机制

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-RUBIN-NVLINK-PROTOCOL | FIELD-INT-PROTOCOL | Counted writes let the receiving GPU track device-initiated NVLink transfer completion more efficiently. | COND-NONE | SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721，Fixed HTML snapshot, paragraphs 55-58 |

## 特殊算子与专用能力

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-RUBIN-TMA-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | configurable_engine | COND-NONE | SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721，Fixed HTML snapshot, paragraphs 33-34 |
| FACT-M2NA-RUBIN-SPARSE-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | dedicated_instruction | COND-NONE | SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721，Fixed HTML snapshot, paragraph 44 |
| FACT-M2NA-RUBIN-COMPRESS-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | configurable_engine | COND-NONE | SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721，Fixed HTML snapshot, paragraphs 43-44 |

## 软件映射

固定快照没有陈述 Rubin 的 CUDA 或其他编程模型映射。REQ-M2NA-AVAIL-0073 因此改为 not_found，检索记录为 SEARCH-M2NA-0127。

## 缺失项与不适用项

| requirement_id | 目标/字段 | 状态 | search_id | 适用性理由 |
|---|---|---|---|---|
| REQ-M2NA-GAP-0025 | OBJ-NVIDIA-RUBIN-ARCH / FIELD-COMP-VENDOR-AI-TOPS | not_applicable | 不需要 | 架构代际没有一项脱离具体实现仍成立的加速器总峰值；总量应归裸片、封装、模组、卡或系统对象。 |
| REQ-M2NA-GAP-0026 | OBJ-NVIDIA-RUBIN-ARCH / FIELD-PHY-PROCESS | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0027 | OBJ-NVIDIA-RUBIN-ARCH / FIELD-PHY-DIE-COUNT | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0028 | OBJ-NVIDIA-RUBIN-ARCH / FIELD-PHY-PACKAGE | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0029 | OBJ-NVIDIA-RUBIN-ARCH / FIELD-DER-COMPUTE-BW-SPEC | pending_verification | SEARCH-M2NA-0009 | 固定版官方架构资料尚未给出同口径的计算峰值与存储带宽对。 |
| REQ-M2NA-GAP-0030 | OBJ-NVIDIA-RUBIN-ARCH / FIELD-DER-MATRIX-VECTOR | pending_verification | SEARCH-M2NA-0010 | 固定版官方架构资料尚未给出口径一致的矩阵与向量吞吐值。 |
| REQ-M2NA-AVAIL-0073 | OBJ-NVIDIA-RUBIN-ARCH / FIELD-SW-PROGRAMMING-MODEL | not_found | SEARCH-M2NA-0127 | 固定快照没有陈述 CUDA 或其他编程模型映射。 |
| REQ-M2NA-GAP-0079 | PPATH-M2NA-RUBIN-LUT3 / FIELD-NUM-PHYSICAL-ACCUM | pending_verification | SEARCH-M2NA-0035 | Rubin 观察期文章没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0080 | PPATH-M2NA-RUBIN-ACT-SPARSE / FIELD-NUM-PHYSICAL-ACCUM | pending_verification | SEARCH-M2NA-0036 | Rubin 观察期文章没有给出物理累加器位宽。 |
| REQ-M2NA-GAP-0081 | PPATH-M2NA-RUBIN-EXP / FIELD-NUM-PHYSICAL-ACCUM | not_applicable | 不需要 | 该标量或特殊函数路径不按矩阵/向量累加路径建模。 |
| REQ-M2NA-GAP-0155 | LINK-M2NA-RUBIN-NVLINK / FIELD-INT-AGGREGATE-BW | not_applicable | 不需要 | 该 link 记录架构级机制；已检资料中的聚合带宽都绑定具体封装、设备或系统实现。 |
| REQ-M2NA-GAP-0171 | CAP-M2NA-RUBIN-MOE / FIELD-CAP-IMPLEMENTATION-LEVEL | pending_verification | SEARCH-M2NA-0114 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |
| REQ-M2NA-GAP-0172 | CAP-M2NA-RUBIN-TOPK / FIELD-CAP-IMPLEMENTATION-LEVEL | pending_verification | SEARCH-M2NA-0115 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |

## 最小来源与反向移除

| source_id | 定位 | 独有贡献 / 不采用理由 |
|---|---|---|
| SRC-M2NA-NVIDIA-RUBIN-BLOG-20260721 | Activation and special-function section, article lines 68-80；Activation sparse compression section；Activation sparsity section；Activation sparsity section, article lines 68-80 | 截止日前唯一达到当前粒度、且已保存固定快照的 Rubin 官方架构来源；支撑增强 TMA、3-bit LUT、激活稀疏压缩、指数路径与 counted writes。 |

## 实现边界与冲突

与本对象相关但属于封装、模组或具体产品实现的数值，见 `notes/implementation-fact-待办.csv`。Blackwell 的双裸片、NV-HBI 10 TB/s 与 GB200 解压引擎；Rubin 的双裸片封装及其中的 NV-HBI 链路都未挂到架构对象。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | partial | 官方观察文章给出增强 TMA、Tensor Core K 维相对吞吐、SFU 和压缩路径；缺固定白皮书与绝对架构吞吐。 |
| numerics | partial | 已记录 3-bit LUT 矩阵 B 与激活稀疏；完整格式矩阵、累加接口和物理位宽仍待固定 ISA。 |
| memory | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的内存层级事实。 |
| interconnect | partial | 已记录 NVLink counted writes；双裸片封装及其中的 NV-HBI 链路已下沉，链路带宽未采用产品值。 |
| special_engines | partial | 已记录增强 TMA 与激活稀疏压缩；MoE routing/top-k 仍待固定资料核验。 |
| software | missing_public_data | 固定快照没有陈述 CUDA 或其他编程模型映射，检索结果保留为 not_found。 |
| evidence | partial | 10 条事实依赖同一份已固定的官方网页快照；尚无架构白皮书或 ISA 交叉核验。 |

## 自检与复核

- 本卡的 fact_id、requirement_id、search_id、source_id 均已进入正式 32 表；仍需后续解决的字段继续保留 `needs_resolution`。
- 本卡事实只挂一个目标主语；SKU、模组、封装和系统聚合值未上卷到架构对象。
- 主键、外键、枚举、七目标 XOR 与中文润色检查在交付前统一执行；检查结果写入 README 和 notes。
