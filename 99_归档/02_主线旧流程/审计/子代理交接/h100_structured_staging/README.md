# H100 SXM5 80 GB 结构化候选

> 总控验收状态：本批次 18 张 CSV 已于 2026-08-12 合并到正式表；本目录保留为可复查的交接快照，不再作为待合并队列。

本目录把 `资料卡/NVIDIA/产品/H100_SXM5_80GB_试填草稿.md` 中已有出处的内容拆成待总控合并的 CSV。表头、枚举和外键口径沿用正式数据模型；除 `memory-levels.csv` 按模型要求复用对应内存组件 ID 外，新增标识均为未占用的 ASCII ID。本目录原为待合并区（staging），现作为已接收批次的交接快照；后续语义修正以正式表和 M1 验收记录为准。

## 对象范围

H100 SXM5 80 GB 模组使用 `OBJ-NVIDIA-H100-SXM5-80GB`。总控已建立 `OBJ-NVIDIA-GH100-DIE` 及 `OREL-NVIDIA-H100-SXM5-CONTAINS-GH100`，所以 TSMC 4N、800 亿晶体管和 814 mm² 三项只归到 GH100 裸片，未写入模组物理规格。HGX、DGX、NVSwitch、Grace Hopper 和 NVLink Switch System 仍留在系统或组合产品层，不进入本次 staging。

H100 架构白皮书 v1.04 已由总控正式登记为 `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04`。本目录直接复用这个来源 ID，没有再提交同一来源家族、内容版本、访问入口、筛选记录或入选角色候选。

## 数据量

结构候选包括 14 个组件、11 条精度路径、4 个内存层级、2 个互联端点、6 项特殊能力和 31 组条件。事实表共有 66 行，其中 59 行为来源直接陈述，7 行为规格计算带宽比；67 条逐来源断言覆盖全部直接事实。7 个派生事实分别保存公式记录和 2 个输入，共 7 行 `derived-metrics`、14 行 `derived-inputs`。

缺口部分有 17 条字段要求。16 条 `not_found` 都配有检索记录，覆盖片上各级带宽、TF32/FP64 Tensor/INT8 的程序员可见累加格式、六条矩阵路径的物理累加器位宽、NVLink/PCIe 有效载荷，以及专用 MoE（Mixture of Experts，专家混合）routing 和通用 Top-K 模块；另有 1 条产品可用日期待核实。这里的 `not_found` 表示所选一手资料没有给出可直接入表的证据，不等于厂商明确宣称“未公开”，也不等于数值为零或能力不存在。

来源候选另有 5 个来源家族、6 个内容版本和 6 个访问入口。筛选结果为 3 个 `selected`、1 个 `redundant_covered`、2 个 `out_of_scope`，另有 3 条入选角色和 2 条覆盖关系。白皮书已在全局表中，因此不计入上述 staging 来源数量，但承担多数计算、存储和机制断言。

## 数值和版本处理

计算吞吐按精度路径、稠密或结构化稀疏、操作计数规则和峰值时钟拆开。非 Tensor CUDA 路径保留 NVIDIA 给出的理论峰值，但没有改写成厂商未发布的独立“向量总峰值”或“标量总峰值”。CUDA core 在统一组件模型中的 `scalar` / `vector` 分类仍需总控决定，相应组件和路径暂标 `needs_resolution`。

第三代高带宽存储器（High Bandwidth Memory 3，HBM3）的带宽保留三个时间版本：Hot Chips 34 的 3 TB/s 带有“数据率未最终确定”条件；白皮书 v1.04 Table 3 给出 3,352 GB/s；当前数据手册给出 3.35 TB/s。前两条标为历史版本，不当作无法解释的矛盾。7 个规格计算带宽比统一使用当前 3.35 TB/s，条件集同时保存计算精度、稠密口径、理论峰值、带宽方向未单列和当前版本日期。INT8 的结果单位是 OP/byte（每字节操作次数），与浮点路径的 FLOP/byte（每字节浮点操作次数）不混在同一字段，因此没有写入该字段的派生表。

逐来源断言保留资料原始单位，例如 80 GB、3.35 TB/s、900 GB/s；规范事实再统一换成 byte、byte/s 或 bit/s。寄存器容量的原始断言保留为“65,536 个 32-bit 寄存器/SM”，规范事实才换算为 262,144 byte。这样可同时审计原文和单位换算。

## 来源筛选

当前数据手册、Hopper Tuning Guide 13.3 和 Hot Chips 34 分别承担定版产品规格、编程可见限制与机制补充、发布期版本证据。H100 白皮书使用全局正式来源。IEEE（Institute of Electrical and Electronics Engineers，电气电子工程师学会）Micro 文章在这张卡实际选用的事实范围内，被白皮书和 Hot Chips 材料覆盖；`source-coverage.csv` 的 `fully_covered` 只针对 `selected_fact_set`，不表示两份文档逐句相同。

两篇 Hopper 微基准使用 H800 测试对象，不能为 H100 SXM5 回填数值，因此标为 `out_of_scope`。2025 扩展版是否用于以后 Hopper 架构对象的独立测量，应在架构卡阶段另行判断。动态 H100 产品页和 HGX/DGX 系统资料没有在本卡新增独立事实，未提交为本次最小集合候选。

总控在合并后又从 NVIDIA 官方入口固定了数据手册与 Tuning Guide 13.3，并把本地路径、页数和 SHA-256 登记到全局来源表；本 staging 不重复提交这两条后续 endpoint。产品精确可用日期仍未固定。Tensor Memory Accelerator（TMA，张量内存加速器）和 Transformer Engine 的实现层级仍需复核。TMA 是明确命名的硬件数据搬运机制，但 `configurable_engine` 与 `dedicated_physical_module` 的枚举边界尚未冻结；Transformer Engine 由软件与 Hopper Tensor Core 技术组合实现，当前暂用 `configurable_engine`。两条事实都标 `needs_resolution`，避免只凭名称推断独立物理单元。

## 合并顺序与检查

合并前先确认全局仍存在以下依赖：`OBJ-NVIDIA-H100-SXM5-80GB`、`OBJ-NVIDIA-GH100-DIE`、`COND-NONE` 和 `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04`。来源候选可先合并，再按组件、内存层级与精度路径、特殊能力与互联、条件集、事实与字段要求、逐来源断言、派生记录的顺序合并。`memory_level_id` 按正式模型等于对应内存组件的 `component_id`，这是表间别名关系，不应改成另一套 ID。

`Validate-Staging.ps1` 会检查正式表头、必填列、枚举、全局及 staging 外键、主键冲突、事实目标与数值异或、断言定位、缺口检索记录、冗余来源覆盖、派生输入和 UTF-8 替换字符。当前结果为：

```text
PASS: 7215 checks across 18 staging tables
```

把 18 张候选表合并到全局表的临时副本后，正式校验器也已通过：

```text
PASS: 32-table research data model; 17117 checks executed.
Registry: 323 columns, 488 enum values.
```

临时合并目录已在验证后删除。总控正式合并后重新运行 `scripts/validation/Validate-ResearchData.ps1` 并通过；数据手册与 Tuning Guide 固定副本缺口已关闭。CUDA 非 Tensor 路径分类、TMA 与 Transformer Engine 实现层级、HBM 三个版本的有效期仍保留相应 `needs_resolution` 或版本条件，不因合并而静默裁决。
