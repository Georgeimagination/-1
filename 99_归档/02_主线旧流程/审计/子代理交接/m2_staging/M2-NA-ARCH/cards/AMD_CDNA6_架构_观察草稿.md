# AMD CDNA 6 架构资料卡（草稿）

> 对象：OBJ-AMD-CDNA6-ARCH；层级：architecture_generation；事实冻结日：2026-08-12；复核状态：draft。

## 对象边界

CDNA 6 当前只冻结官方架构名称和 announced 状态。新闻稿中的 2 nm、HBM4E 与 2027 计划主语是 MI500 产品或实现，均未写入 architecture facts。

## 身份与状态

| fact_id | 字段 | 事实值 | 条件 | 来源定位 |
|---|---|---|---|---|
| FACT-M2NA-CDNA6-NAME | FIELD-ID-NAME | AMD CDNA 6 architecture | COND-NONE | SRC-M2NA-AMD-CES2026-RELEASE，Fixed HTML snapshot, AMD Instinct MI500 Series paragraph 48 |
| FACT-M2NA-CDNA6-STATUS | FIELD-ID-STATUS | announced | COND-NONE | SRC-M2NA-AMD-CES2026-RELEASE，Fixed HTML snapshot, news highlight 36 and MI500 paragraph 48 |

## 缺失项与不适用项

| requirement_id | 目标/字段 | 状态 | search_id | 适用性理由 |
|---|---|---|---|---|
| REQ-M2NA-GAP-0053 | OBJ-AMD-CDNA6-ARCH / FIELD-COMP-VENDOR-AI-TOPS | not_applicable | 不需要 | 架构代际没有一项脱离具体实现仍成立的加速器总峰值；总量应归裸片、封装、模组、卡或系统对象。 |
| REQ-M2NA-GAP-0054 | OBJ-AMD-CDNA6-ARCH / FIELD-PHY-PROCESS | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0055 | OBJ-AMD-CDNA6-ARCH / FIELD-PHY-DIE-COUNT | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0056 | OBJ-AMD-CDNA6-ARCH / FIELD-PHY-PACKAGE | not_applicable | 不需要 | 工艺、裸片数和封装组成描述物理实现，不属于架构代际对象。 |
| REQ-M2NA-GAP-0057 | OBJ-AMD-CDNA6-ARCH / FIELD-DER-COMPUTE-BW-SPEC | pending_verification | SEARCH-M2NA-0017 | 固定版官方架构资料尚未给出同口径的计算峰值与存储带宽对。 |
| REQ-M2NA-GAP-0058 | OBJ-AMD-CDNA6-ARCH / FIELD-DER-MATRIX-VECTOR | pending_verification | SEARCH-M2NA-0018 | 固定版官方架构资料尚未给出口径一致的矩阵与向量吞吐值。 |
| REQ-M2NA-GAP-0181 | CAP-M2NA-CDNA6-MOE / FIELD-CAP-IMPLEMENTATION-LEVEL | pending_verification | SEARCH-M2NA-0124 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |
| REQ-M2NA-GAP-0182 | CAP-M2NA-CDNA6-TOPK / FIELD-CAP-IMPLEMENTATION-LEVEL | pending_verification | SEARCH-M2NA-0125 | 检索目标是专用 MoE routing 或 top-k 模块/指令，不把通用计算上的软件实现算作专用硬件。 |

## 最小来源与反向移除

| source_id | 定位 | 独有贡献 / 不采用理由 |
|---|---|---|
| SRC-M2NA-AMD-CES2026-RELEASE | 2026-01-05 press release, MI500 Series paragraph；2026-01-05 press release, planned MI500 Series using CDNA 6 | CDNA 6 当前唯一必要来源；只证明官方架构名称及 announced 状态。2 nm、HBM4E 和 2027 计划属于 MI500，不写成 CDNA 6 架构事实。 |

## 实现边界与冲突

MI500 的 2 nm、HBM4E 和计划年份不属于本对象。当前没有可解析成 CDNA 6 微架构事实的固定版白皮书。

## 九域完整度

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 对象身份与范围已固定。 |
| physical | not_applicable | 架构代际不承载工艺、裸片数、封装等物理实现值。 |
| compute | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| numerics | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| memory | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| interconnect | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| special_engines | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| software | missing_public_data | 截至 2026-08-12，已核对的一手材料没有公开可归到本架构对象的事实。 |
| evidence | partial | 只使用一手来源，并保留筛选与反向移除记录。 目前仍是观察对象，固定版架构资料缺位。 |

## 自检与复核

- 本卡的 fact_id、requirement_id、search_id、source_id 均来自本 staging 结构化片段；总控合并前状态均为 draft 或 needs_resolution。
- 当前没有 per-CU、per-WGP 或 per-XCD 数值；本卡只有名称和 announced 状态。
- 主键、外键、枚举、七目标 XOR 与中文润色检查在交付前统一执行；检查结果写入 README 和 notes。
