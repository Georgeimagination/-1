# NVIDIA Hopper 架构资料卡（M1 复用草稿）

> 对象：OBJ-NVIDIA-HOPPER-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：draft。


术语：TMA（Tensor Memory Accelerator）是张量数据搬运机制；DSM（Distributed Shared Memory）是线程块簇内的分布式共享内存；DPX 是面向动态规划的专用指令族。
## 复用边界

Hopper 在 M1 已随 GH100/H100 试填建立完整正式事实链。本包不再复制 Hopper 架构事实、组件、精度路径、来源或断言；下面只给总控可复用的正式标识。具体总峰值、HBM、NVLink 带宽和封装数据仍归 GH100 裸片或 H100 SXM5 模组，而不是 Hopper 架构对象。

## 执行、数值、存储、互联与特殊能力

| 域 | 复用的正式 fact_id / 说明 |
|---|---|
| 执行组织与矩阵/向量/标量 | H100 正式组件和路径；代表事实 `FACT-NVIDIA-H100-FP8-DENSE-PEAK` 仅用于实现级峰值，不上卷为 Hopper 总算力。 |
| 数据格式与累加 | `FACT-NVIDIA-H100-FP8-ACCUM`、`FACT-NVIDIA-H100-FP16-TENSOR-ACCUM`、`FACT-NVIDIA-H100-BF16-TENSOR-ACCUM`。物理累加宽度继续按缺失项记录。 |
| 存储层次 | `FACT-NVIDIA-H100-REG-CAPACITY-PER-SM`、`FACT-NVIDIA-H100-L1SMEM-CAPACITY-PER-SM`、`FACT-NVIDIA-H100-L2-CAPACITY`；这些是 H100 实现事实。 |
| 互联 | `FACT-NVIDIA-H100-NVLINK-PROTOCOL`、`FACT-NVIDIA-H100-NVLINK-RATE-BIDIR-DEVICE`；带宽仍是 H100 模组层事实。 |
| 特殊能力 | `FACT-NVIDIA-H100-TMA-DETAIL`、`FACT-NVIDIA-H100-DPX-IMPL-LEVEL`、`FACT-NVIDIA-H100-DPX-THROUGHPUT-16`、`FACT-NVIDIA-H100-TRANSFORMER-ENGINE-DETAIL`、`FACT-NVIDIA-H100-DSM-DETAIL`。 |
| 软件映射 | CUDA Hopper Tuning Guide 13.3 已在正式来源表登记，但当前选择事实均由白皮书覆盖，因此未进入 M1 最小集。 |
| 物理实现边界 | GH100 工艺、裸片面积、晶体管数和 H100 SXM5 的 HBM/功耗/总峰值不能挂到 Hopper architecture object。 |

## 缺失项与检索记录

| requirement_id | 状态 | search_id | 说明 |
|---|---|---|---|
| REQ-NVIDIA-H100-BF16-TENSOR-PHYSICAL-ACCUM | not_found | SEARCH-NVIDIA-H100-BF16-TENSOR-PHYSICAL-ACCUM | 复用 M1 正式 requirement/search；不在 M2 重建。 |
| REQ-NVIDIA-H100-L1SMEM-BW | not_found | SEARCH-NVIDIA-H100-L1SMEM-BW | 复用 M1 正式 requirement/search；不在 M2 重建。 |
| REQ-NVIDIA-H100-L2-BW | not_found | SEARCH-NVIDIA-H100-L2-BW | 复用 M1 正式 requirement/search；不在 M2 重建。 |
| REQ-NVIDIA-H100-MOE-ROUTE | not_found | SEARCH-NVIDIA-H100-MOE-ROUTE | 复用 M1 正式 requirement/search；不在 M2 重建。 |
| REQ-NVIDIA-H100-TOPK | not_found | SEARCH-NVIDIA-H100-TOPK | 复用 M1 正式 requirement/search；不在 M2 重建。 |
| REQ-NVIDIA-H100-NVLINK-PAYLOAD | not_found | SEARCH-NVIDIA-H100-NVLINK-PAYLOAD | 复用 M1 正式 requirement/search；不在 M2 重建。 |

## 最小来源与反向移除

| source_id | 独有贡献 / 未采用理由 |
|---|---|
| SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04 | selected：H100/Hopper 执行、精度、存储组织和架构机制的主来源。 |
| SRC-NVIDIA-H100-DATASHEET-20240924 | selected：当前 H100 SXM5 铭牌规格；属于实现对象，不上卷到 Hopper。 |
| SRC-NVIDIA-H100-HOTCHIPS34-2022 | selected：只保留发布期 HBM 版本差异证据。 |
| SRC-NVIDIA-HOPPER-TUNING-GUIDE-13-3 | redundant_covered：当前结构化事实可由白皮书覆盖；仍保留为软件线索。 |
| SRC-NVIDIA-H100-IEEE-MICRO-2023 | redundant_covered：没有增加当前已选事实。 |
| SRC-NVIDIA-HOPPER-MICROBENCH-2024 / 2025 | out_of_scope：实测对象是 H800 PCIe，不能填 H100/Hopper 当前对象。 |

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | needs_review | 本卡不复制 Hopper 架构事实；只列 M1 H100/GH100 实现事实供总控建立显式复用或重新抽取。 |
| numerics | needs_review | 现列 FP8/FP16/BF16 累加标识来自 H100 实现，不能无关系上卷为 Hopper 代际事实。 |
| memory | needs_review | 现列寄存器、L1/共享内存与 L2 数值属于 H100 实现；Hopper 架构层需总控决定复用方式。 |
| interconnect | needs_review | NVLink 协议可作架构线索，但带宽是 H100 模组事实；本卡不复制。 |
| special_engines | needs_review | TMA、DPX、Transformer Engine 和 DSM 目前均引用 M1 H100 事实；需显式复用裁决。 |
| software | needs_review | Hopper Tuning Guide 已登记为正式来源，但本包没有新增架构层软件事实。 |
| evidence | needs_review | M1 来源链可复用，但现有事实目标是 GH100/H100；总控需避免把实现证据自动改写成架构事实。 |

## 自检与复核

- 本卡只有正式 ID 复用说明，不产生新事实、来源或断言，因此不会与 M1 重复。
- 总控合并时只需接入此卡和九域完整度，不应合并任何 Hopper staging facts。
