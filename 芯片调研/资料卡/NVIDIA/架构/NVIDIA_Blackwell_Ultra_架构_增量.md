# NVIDIA Blackwell Ultra 架构资料卡

> 对象：OBJ-NVIDIA-BLACKWELL-ULTRA-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：accepted。


术语：SFU（Special Function Unit，特殊函数单元）承担指数等特殊函数；`MUFU.EX2` 是这里直接记录的指数指令路径。
## 对象边界

本卡只记录直接以 Blackwell Ultra 为主语的增量事实，不从 Blackwell 隐式继承。当前正式对象关系表没有可用于继承共有事实的关系。在该关系经过另行核验前，本卡不复制 Blackwell 事实；矩阵、存储和互联共有项记为未直接披露或待关系复核，不判断这些能力在架构上不存在。

## 执行组织、矩阵/向量/标量路径

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-ULTRA-SFU-EXEC | FIELD-COMP-EXECUTION | MUFU.EX2 exponential instruction path used inside optimized softmax kernels. | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-ULTRA-SOFTMAX-2026，snapshot paragraphs 20-21; section Alleviating the softmax bottleneck |
| FACT-M2NA-ULTRA-EXP-REL | FIELD-COMP-THROUGHPUT | 2 ratio | COND-M2NA-ULTRA-EXP-REL | SRC-M2NA-NVIDIA-BLACKWELL-ULTRA-SOFTMAX-2026，snapshot paragraph 36, Alleviating the softmax bottleneck |

## 特殊算子与专用能力

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-ULTRA-SOFTMAX-LEVEL | FIELD-CAP-IMPLEMENTATION-LEVEL | dedicated_instruction | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-ULTRA-SOFTMAX-2026，snapshot paragraphs 20-21 |
| FACT-M2NA-ULTRA-SOFTMAX-DETAIL | FIELD-CAP-IMPLEMENTATION-DETAIL | MUFU.EX2 accelerates the exponential stage used by softmax. | COND-NONE | SRC-M2NA-NVIDIA-BLACKWELL-ULTRA-SOFTMAX-2026，snapshot paragraphs 20-21 and 39-41 |

## 缺失项与不适用项

| requirement_id | 目标/字段 | 状态 | search_id | 适用性理由 |
|---|---|---|---|---|
| REQ-M2NA-GAP-0019 | OBJ-NVIDIA-BLACKWELL-ULTRA-ARCH / FIELD-COMP-VENDOR-AI-TOPS | not_applicable | 不需要 | 架构代际没有一项脱离具体实现仍成立的加速器总峰值；总量应归裸片、封装、模组、卡或系统对象。 |
| REQ-M2NA-GAP-0020 | OBJ-NVIDIA-BLACKWELL-ULTRA-ARCH / FIELD-PHY-PROCESS | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0021 | OBJ-NVIDIA-BLACKWELL-ULTRA-ARCH / FIELD-PHY-DIE-COUNT | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0022 | OBJ-NVIDIA-BLACKWELL-ULTRA-ARCH / FIELD-PHY-PACKAGE | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0023 | OBJ-NVIDIA-BLACKWELL-ULTRA-ARCH / FIELD-DER-COMPUTE-BW-SPEC | not_found | SEARCH-M2NA-0007 | 本增量卡没有直接披露同口径计算吞吐与存储带宽对，且没有正式关系允许复用 Blackwell。 |
| REQ-M2NA-GAP-0024 | OBJ-NVIDIA-BLACKWELL-ULTRA-ARCH / FIELD-DER-MATRIX-VECTOR | not_found | SEARCH-M2NA-0008 | 本增量卡没有直接披露口径一致的矩阵/向量吞吐对，且没有正式关系允许复用 Blackwell。 |
| REQ-M2NA-GAP-0078 | PPATH-M2NA-BLACKWELL-ULTRA-EXP / FIELD-NUM-PHYSICAL-ACCUM | not_applicable | 不需要 | 该标量或特殊函数路径不按矩阵/向量累加路径建模。 |
| REQ-M2NA-GAP-0169 | CAP-M2NA-BLACKWELL-ULTRA-MOE / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0112 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |
| REQ-M2NA-GAP-0170 | CAP-M2NA-BLACKWELL-ULTRA-TOPK / FIELD-CAP-IMPLEMENTATION-LEVEL | not_found | SEARCH-M2NA-0113 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |

## 最小来源与反向移除

| source_id | 定位 | 独有贡献 / 不采用理由 |
|---|---|---|
| SRC-M2NA-NVIDIA-BLACKWELL-ULTRA-SOFTMAX-2026 | 2026-02-25 article, Blackwell Ultra throughput discussion；Making Softmax More Efficient, MUFU.EX2 section；MUFU.EX2 and optimized softmax discussion；MUFU.EX2 section | 唯一直接支撑 Ultra 增量的来源；给出 MUFU.EX2、softmax 映射和相对 Blackwell 的 2 倍指数吞吐。移除后四条 Ultra 直接事实全部失去证据。 |

## 实现边界与冲突

本卡没有建立与 Blackwell 的继承或 successor_of 关系；共有事实不得无关系复用。技术简报里的 Ultra 内容只作线索，事实链采用 Ultra 直接来源。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | partial | 本增量卡只直接记录 SFU 的 MUFU.EX2 路径及相对 Blackwell 的指数吞吐比；共有计算路径不做无关系复用。 |
| numerics | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| memory | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| interconnect | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| special_engines | partial | 已确认 MUFU.EX2 指数指令会加速 softmax 的指数阶段；本卡不从该事实推导其他实现结论。 |
| software | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| evidence | partial | 只使用一手来源，并保留筛选与反向移除记录。 |

## 自检与复核

- 本卡的 fact_id、requirement_id、search_id、source_id 均已进入正式 32 表；仍需后续解决的字段继续保留 `needs_resolution`。
- 本卡事实只挂一个目标主语；SKU、模组、封装和系统聚合值未上卷到架构对象。
- 主键、外键、枚举、七目标 XOR 与中文润色检查在交付前统一执行；检查结果写入 README 和 notes。
