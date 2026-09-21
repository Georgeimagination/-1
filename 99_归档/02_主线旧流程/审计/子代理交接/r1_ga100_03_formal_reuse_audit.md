# R1 NVIDIA GA100 die 正式库复用审计

日期：2026-08-21  
任务：`R1-CHIP-NVIDIA-GA100` 的正式库只读复用审计  
范围：只读检查现有正式 CSV、已验收审计和已接收的 Ampere 架构卡；未联网、未下载，也未修改正式 CSV、资料卡或进度文件。  
结论：正式库缺少 `NVIDIA GA100 die` 对象及其架构关系。下一次正式事务应先建立 GA100 裸片对象和 `implements_architecture` 关系，再把 Ampere 架构事实作为关系投影使用；不得复制为 GA100 的普通事实。

## 读取范围与方法

已按主线恢复顺序阅读 `AGENTS.md`、冻结名单、DEC-030 至 DEC-036、研究计划、当前状态、任务台账、资料卡字段字典 0.3 和模板 0.3。审计读取了用户指定的 11 张正式数据表，以及最小参考资料库全部 14 张来源表；为核对 141 字段合同，额外只读了 `fields.csv` 和相关 `condition-sets.csv`。

| 范围 | 已解析行数 |
|---|---:|
| `objects.csv` / `object-relations.csv` | 78 / 27 |
| `components.csv` / `precision-paths.csv` / `special-capabilities.csv` | 270 / 171 / 95 |
| `memory-levels.csv` / `links.csv` / `topologies.csv` | 88 / 45 / 5 |
| `facts.csv` / `field-requirements.csv` / `card-completeness.csv` | 798 / 1,059 / 585 |
| `source-families.csv` / `sources.csv` / `source-endpoints.csv` | 92 / 93 / 153 |
| `fact-assertions.csv` / `requirement-evidence.csv` | 832 / 73 |
| `source-screening.csv` / `source-selected-roles.csv` / `source-coverage.csv` | 101 / 113 / 27 |
| `selection-runs.csv` / `selection-members.csv` | 11 / 106 |
| `conflict-groups.csv` / `conflict-members.csv` | 20 / 41 |
| `search-log.csv` / `search-results.csv` | 353 / 699 |

读取前的内容聚合值为：`数据/` 18 个 CSV、1,258,251 bytes、`52272ccd5fd486e25dd92b6bd1ba778ad4268f632e136a67faec25337462cc67`；`最小参考资料库/` 14 个 CSV、982,324 bytes、`508427cadb5ad714966e48283269988016298d70a4ea3878524e70a317974f36`。本任务只写本交接文件。

已采用的验收材料是 `审计/M2_NA_架构包正式合并验收.md`。它确认 `M2-NA-ARCH` 在 2026-08-13 已 `accept`，并明确具体裸片、封装、SKU 和系统值由后续对象工作包承接。`审计/目录迁移验收_2026-08-18.md` 说明迁移前未验收输出不能作为正式输入。本复用审计为保持独立性，未读取 `审计/子代理交接/r1_ga100_03_core_source_reading_assets/` 的并行核心精读产物。

## 对象边界与关系裁决

冻结名单把 “NVIDIA GA100 die” 定义为历史锚点，层级为 `die`。正式 `objects.csv` 中却没有含 `GA100` 或独立 `A100` 的对象行，也没有任何对象关系以 GA100 为任一端点。当前可复用的正式对象只有下列不同层级记录。

| 主键 | 正式对象和层级 | 对 GA100 的用途 |
|---|---|---|
| `OBJ-NVIDIA-AMPERE-ARCH` | `architecture_generation`，`reviewed` | GA100 应连接的架构证据对象；范围审计标为 `architecture_evidence`，不计芯片完成度。 |
| `OBJ-NVIDIA-GH100-DIE` | `die`，`reviewed` | 只提供裸片建模先例；它属于 Hopper，不能复用为 GA100 事实或关系。 |
| `OBJ-NVIDIA-H100-SXM5-80GB` | `module`，`reviewed` | Hopper 的模组试填对象，不是 GA100，也不能用于 GA100 的物理、功耗、容量或吞吐字段。 |

`A100` 在正式来源层只出现在白皮书题名、文件名和页码定位中；它不是现有 `objects.csv` 的 `die`、`package`、`module`、`card` 或 `system` 对象。因此不得把来源中的 A100 SKU、板卡或系统聚合数字视为现成 GA100 正式事实。`LINK-M2NA-AMPERE-NVLINK3` 的说明也已明确：A100 的 NVLink 数量与聚合带宽是 SKU 事实。

需要新建以下两条正式记录。主键为建议值，当前均不存在，且本任务没有写入。

| 建议主键 | 记录 | 裁决与证据边界 |
|---|---|---|
| `OBJ-NVIDIA-GA100-DIE` | `VEN-NVIDIA`；`NVIDIA GA100 die`；`object_type=die`；建议 slug `nvidia-ga100-die` | 必须新建。它是冻结 49 芯片名单所要求的芯片本体，不能以 Ampere 架构对象或 A100 产品名称替代。正式身份来源仍须先登记；名单给出的 NVIDIA MIG Supported GPUs 页面尚未成为正式 `source_id`。 |
| `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` | `OBJ-NVIDIA-GA100-DIE` `implements_architecture` `OBJ-NVIDIA-AMPERE-ARCH` | 必须与新对象作为同一原子包写入。该关系让 `FIELD-ID-ARCH` 通过关系投影，而不是新增一条 “Ampere” 文本事实。关系本身仍应有直接身份和代际对应证据。 |

现有 `SELRUN-M2NA-ARCH-20260812` 的范围是 `architecture_evidence`，范围审计明确标为 `on_demand_only`，不能视为 GA100 的芯片最小来源运行。GA100 建立事实和字段要求后，需要针对新对象重新生成覆盖和反向移除记录。

## 已接收 Ampere 机制可作关系复用

Ampere 闭包由 8 个组件、6 条数值路径、4 项特殊能力、3 个存储层级、1 条互联和 0 个拓扑组成。组件、数值路径和能力仍归 `OBJ-NVIDIA-AMPERE-ARCH`，不迁移所有权。

| 实体种类 | 可复用主键 |
|---|---|
| 组件 | `COMP-M2NA-AMPERE-SM`、`COMP-M2NA-AMPERE-TENSOR`、`COMP-M2NA-AMPERE-CUDA`、`COMP-M2NA-AMPERE-SFU`、`COMP-M2NA-AMPERE-ASYNC-COPY`、`COMP-M2NA-AMPERE-REG`、`COMP-M2NA-AMPERE-L1SMEM`、`COMP-M2NA-AMPERE-L2` |
| 数值路径 | `PPATH-M2NA-AMPERE-TENSOR-FP16`、`PPATH-M2NA-AMPERE-TENSOR-BF16`、`PPATH-M2NA-AMPERE-TENSOR-TF32`、`PPATH-M2NA-AMPERE-TENSOR-FP64`、`PPATH-M2NA-AMPERE-TENSOR-INT8`、`PPATH-M2NA-AMPERE-CUDA-FP32` |
| 特殊能力 | `CAP-M2NA-AMPERE-SPARSE`、`CAP-M2NA-AMPERE-ASYNC`、`CAP-M2NA-AMPERE-MOE`、`CAP-M2NA-AMPERE-TOPK` |
| 存储层级 | `COMP-M2NA-AMPERE-REG`、`COMP-M2NA-AMPERE-L1SMEM`、`COMP-M2NA-AMPERE-L2` |
| 互联 | `LINK-M2NA-AMPERE-NVLINK3`，只表示第三代 NVLink 协议机制 |

共有 21 条 Ampere 正式事实。全部 `resolution_state=provisional`，其中 20 条 `reviewed`，`FACT-M2NA-AMPERE-CUDA-EXEC` 为 `needs_resolution`，因此关系投影时必须保留这个状态与“标量路径不等同于向量聚合”的注记。

| 领域 | 关系可读的事实主键 |
|---|---|
| 计算组织 | `FACT-M2NA-AMPERE-SM-EXEC`、`FACT-M2NA-AMPERE-TENSOR-EXEC`、`FACT-M2NA-AMPERE-TENSOR-FORMATS`、`FACT-M2NA-AMPERE-CUDA-EXEC`、`FACT-M2NA-AMPERE-ASYNC-EXEC` |
| 数值路径 | `FACT-M2NA-AMPERE-FP16-A`、`FACT-M2NA-AMPERE-FP16-B`、`FACT-M2NA-AMPERE-FP16-ACC`、`FACT-M2NA-AMPERE-BF16-A`、`FACT-M2NA-AMPERE-BF16-ACC`、`FACT-M2NA-AMPERE-TF32-A`、`FACT-M2NA-AMPERE-TF32-ACC`、`FACT-M2NA-AMPERE-FP64-A`、`FACT-M2NA-AMPERE-INT-A` |
| 存储机制 | `FACT-M2NA-AMPERE-L1SMEM-MGMT`、`FACT-M2NA-AMPERE-L1SMEM-SCOPE` |
| 专用机制 | `FACT-M2NA-AMPERE-SPARSE-LEVEL`、`FACT-M2NA-AMPERE-SPARSE-DETAIL`、`FACT-M2NA-AMPERE-ASYNC-LEVEL` |
| 互联机制 | `FACT-M2NA-AMPERE-NVLINK-PROTOCOL` |
| 软件公开映射 | `FACT-M2NA-AMPERE-SW`，仅限 CUDA 对 asynchronous-copy 与 barrier 的暴露 |

这 21 条事实只对应 11 个字段语义：`FIELD-COMP-EXECUTION`、`FIELD-COMP-SHARED-RESOURCE`、`FIELD-NUM-OPERAND-A`、`FIELD-NUM-OPERAND-B`、`FIELD-NUM-ACCUMULATION`、`FIELD-MEM-MANAGEMENT`、`FIELD-MEM-LOCALITY-SCOPE`、`FIELD-CAP-IMPLEMENTATION-LEVEL`、`FIELD-CAP-IMPLEMENTATION-DETAIL`、`FIELD-INT-PROTOCOL`、`FIELD-SW-PROGRAMMING-MODEL`。它们在 GA100 卡中应显示为架构关系证据，不能改写为 `OBJ-NVIDIA-GA100-DIE` 的 21 条重复事实。

## 主体错误、已有缺口与不得下放的值

Ampere 闭包中的 42 个字段要求均以架构对象、其组件、链路、数值路径或能力为主体：`REQ-M2NA-AVAIL-0001` 至 `REQ-M2NA-AVAIL-0021` 为 21 条 `value_available`；15 条 `not_found` 和 6 条 `not_applicable` 的精确主键见下表及其后一段。它们不是 GA100 的字段要求，不能改主键后直接复用。

下表列出已明确禁止下放或仍仅在架构作用域检索过的关键主键。它们构成 GA100 工作包的防错清单。

| 类型 | 正式主键 | 对 GA100 的处理 |
|---|---|---|
| 架构对象不适用 | `REQ-M2NA-GAP-0001` | `FIELD-COMP-VENDOR-AI-TOPS` 不能挂在 Ampere 架构；GA100 总峰值须以裸片作用域、精度、稠密度和计数规则另取证。 |
| 架构对象不适用 | `REQ-M2NA-GAP-0002`、`REQ-M2NA-GAP-0003`、`REQ-M2NA-GAP-0004` | `FIELD-PHY-PROCESS`、`FIELD-PHY-DIE-COUNT`、`FIELD-PHY-PACKAGE` 是实现字段。GA100 必须独立建事实或缺失要求。 |
| 架构链路不适用 | `REQ-M2NA-GAP-0151` | `FIELD-INT-AGGREGATE-BW` 不能从架构级 NVLink 3 推得；GA100 的链路数、每链路速率、方向和聚合带宽要按裸片或特定产品作用域分开。 |
| 架构路径未找到 | `REQ-M2NA-GAP-0059` 至 `REQ-M2NA-GAP-0063` | 物理累加器位宽没有被当前架构来源公开。它们不能给 GA100 填零，也不能把程序员可见 FP32 累加改写成物理累加位宽。 |
| 架构存储未找到 | `REQ-M2NA-GAP-0109` 至 `REQ-M2NA-GAP-0114` | 寄存器、L1/共享内存与 L2 的架构级读写带宽无可靠值；GA100 若有直接实测或官方实现值，应另建条件化事实。 |
| 专用机制未找到 | `REQ-M2NA-GAP-0163`、`REQ-M2NA-GAP-0164` | 未找到专用 MoE routing 或 top-k 实现。通用 CUDA 软件、模型 All-to-All 或 KV Cache 迁移量均不能填入 GA100 的硬件能力。 |

6 条 `not_applicable` 的完整集合还包括 `REQ-M2NA-GAP-0064`；15 条 `not_found` 的完整集合为 `REQ-M2NA-GAP-0005`、`REQ-M2NA-GAP-0006`、`REQ-M2NA-GAP-0059` 至 `REQ-M2NA-GAP-0063`、`REQ-M2NA-GAP-0109` 至 `REQ-M2NA-GAP-0114`、`REQ-M2NA-GAP-0163`、`REQ-M2NA-GAP-0164`。架构级派生比值不能复用。GA100 的派生指标要等同一裸片作用域的实际矩阵峰值、存储带宽或互联注入带宽齐备后才计算。

## 141 字段与 13 个完整度领域的落点

`fields.csv` 的 141 个字段按正式 field domain 计数为：身份 17、物理 13、计算 14、数值 13、存储 22、互联 20、特殊能力 4、软件 11、虚拟化 3、可靠性 10、实测 6、经济性 1、派生 6、关系数量 1。资料卡的 13 个完整度领域不把工作负载条件作为领域；派生字段跨计算、存储和互联使用，关系字段用于 `FIELD-ID-ARCH` 投影。

由于 GA100 对象尚不存在，141 个字段中没有一条可直接挂到 GA100。下表描述新对象建立后每个完整度领域可借用的架构信息和仍须建立的 GA100 工作项；这里的“关系复用”不改变 21 条原事实主体。

| 完整度领域 | 当前 GA100 直接事实 | 可通过新关系读取 | 主体错误或缺失待补 |
|---|---|---|---|
| `identity` | 0 | Ampere 架构对象可成为 `FIELD-ID-ARCH` 的关系目标 | 新对象的 17 个身份字段和关系投影要求；先补正式 GA100 身份来源。 |
| `physical` | 0 | 0 | 13 个物理字段均需 GA100 裸片作用域。`REQ-M2NA-GAP-0002` 至 `0004` 已说明这些不是架构值。 |
| `compute` | 0 | 5 条组织事实 | 单元数量、阵列、发射、吞吐、功耗和利用限制必须重核；禁止使用 A100 卡或系统聚合峰值。 |
| `numerics` | 0 | 9 条路径事实 | 可读 FP16、BF16、TF32、FP64、整数与可见累加；物理累加、乘积、舍入和转换仍应对 GA100 单独检查。 |
| `memory` | 0 | 2 条统一 L1/共享内存机制事实 | 22 个存储字段仍缺实现范围、容量、带宽、端口和汇聚边界；6 条架构级带宽 `not_found` 不等于 GA100 `not_found`。 |
| `interconnect` | 0 | 1 条 NVLink 3 协议事实 | 20 个互联字段中的数量、方向、速率、注入和拓扑不可下放；`REQ-M2NA-GAP-0151` 是明确护栏。 |
| `special_engines` | 0 | 2:4 稀疏两条和异步复制一条 | MoE/top-k 仍待核，且只登记芯片绑定模块、指令或明确软件绑定，不写负载量。 |
| `software` | 0 | 1 条 CUDA asynchronous-copy/barrier 映射 | 其余软件、框架、运行时、库、成熟度和版本均待 GA100 对象级核验。 |
| `scheduling` | 0 | 0 | 0.3 新领域。现有 Ampere 完整度为 `needs_review`，不能推定 GA100 有或没有芯片绑定调度、分区、抢占或 QoS。 |
| `reliability` | 0 | 0 | 0.3 新领域。需独立检查 ECC、保护范围、检测、恢复、遥测和 BIST。 |
| `benchmark` | 0 | 0 | 只接受带完整 `condition_set_id` 的实测；模型、batch、上下文和通信量只作条件。 |
| `economics` | 0 | 0 | 公开价格若存在也需绑定 GA100 裸片对象、地区、渠道、数量和日期；云实例或整卡价格不能下放。 |
| `evidence` | 0 | 1 份 Ampere 架构来源可承担机制角色 | GA100 还缺身份和实现规格的直接来源、筛选、覆盖与芯片范围 selection run。 |

现有 Ampere 的 13 条完整度记录是 `CC-M2NA-NVIDIA-AMPERE-ARCH-IDENTITY`、`PHYSICAL`、`COMPUTE`、`NUMERICS`、`MEMORY`、`INTERCONNECT`、`SPECIAL_ENGINES`、`SOFTWARE`、`EVIDENCE`、`SCHEDULING`、`RELIABILITY`、`BENCHMARK`、`ECONOMICS`。状态为 2 条 `complete`、6 条 `partial`、1 条 `not_applicable`、4 条 `needs_review`，且 13 行的 `review_status` 都是 `draft`。这些记录只描述 architecture_generation，GA100 必须新建自己的 13 行完整度记录，不能复制状态。

## 来源链与 14 张来源表的复用结果

所有 21 条关系可读 Ampere 事实都经同一份一手固定白皮书支撑。链条为：

`SFAM-M2NA-NVIDIA-AMPERE-WP-2020` → `SRC-M2NA-NVIDIA-AMPERE-WP-2020` → `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL` / `END-M2NA-NVIDIA-AMPERE-WP-2020-REMOTE` → 21 条 `FACT-M2NA-*` → 21 条 `ASSERT-M2NA-0001` 至 `ASSERT-M2NA-0021`。

本地固定端点为 `论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf`，82 页，SHA-256 `3a800ad7668ec37037fa5870a8e3bb681b75f19668b3d11492ab9b0da0d58815`。21 条断言均为 `source_checked` 和 `reviewed`；白皮书涉及的稳定定位包括 Tensor Core、A100 SM、异步复制、NVLink 3 和 2:4 稀疏章节。

| 来源表 | 与 Ampere 闭包直接相关的主键或数量 | 复用结论 |
|---|---|---|
| `source-families` | `SFAM-M2NA-NVIDIA-AMPERE-WP-2020`，1 行 | 可作架构机制来源家族。行状态为 `draft`，不改变已接收事实的断言状态。 |
| `sources` | `SRC-M2NA-NVIDIA-AMPERE-WP-2020`，1 行 | `first_party`、`architecture_whitepaper`、v1.0；备注明确排除了 A100 启用单元数、HBM 和板级峰值。 |
| `source-endpoints` | `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`、`END-M2NA-NVIDIA-AMPERE-WP-2020-REMOTE`，2 行 | 本地固定 PDF 是 preferred endpoint；两行 `review_status=draft`。 |
| `fact-assertions` | `ASSERT-M2NA-0001` 至 `ASSERT-M2NA-0021`，21 行 | 可保留为架构机制证据，不能改接到新 GA100 普通事实。 |
| `requirement-evidence` | `REVID-M2NA-0001` 至 `0004`、`0041`、`0046`，6 行 | 只支持 Ampere 架构范围的 `not_applicable` 护栏。 |
| `source-screening` | `SCREEN-M2NA-NVIDIA-AMPERE-WP-2020`，1 行，`selected`、`reviewed` | 移除会使 21 条 Ampere 机制事实失去当前直接证据。 |
| `source-selected-roles` | `SROLE-M2NA-NVIDIA-AMPERE-WP-2020`，1 行 | 角色为 `architecture_mechanism`；行状态 `draft`。 |
| `source-coverage` | 0 行 | 没有对该来源的覆盖替代关系。 |
| `selection-runs` | `SELRUN-M2NA-ARCH-20260812`，1 行，`reviewed` | 只覆盖 `M2-NA-ARCH` 的 185 条架构事实，不能充当 GA100 运行。 |
| `selection-members` | `SELMEM-M2NA-NVIDIA-AMPERE-WP-2020`，1 行，`reviewed` | 反向移除理由是 21 条 Ampere 事实不可替代。 |
| `conflict-groups` / `conflict-members` | 0 / 0 行 | 当前 Ampere 闭包没有正式冲突组。 |
| `search-log` | `SEARCH-M2NA-0001`、`0002`、`0019` 至 `0023`、`0064` 至 `0069`、`0106`、`0107`，15 行 | 结果都只对应架构主体的负项检索。GA100 不能继承这些 `not_found`。 |
| `search-results` | `SRESULT-M2NA-0001`、`0002`、`0033` 至 `0037`、`0123` 至 `0128`、`0211`、`0212`，15 行 | 与上述 15 次检索一一对应，均为 `checked_no_support`。 |

`M2_NA_架构包正式合并验收.md` 已接收 `SELRUN-M2NA-ARCH-20260812`，并说明 17 个最小集成员服务于 185 条架构事实。这个已验收运行足以证明 Ampere 机制来源的现有保留理由，却不能证明 GA100 的产品身份、裸片物理实现、规格或最小来源集已经完成。

## 结论与下一步

GA100 的正确路径是先补“一个 die 对象加一条架构关系”，随后按 0.3 合同建立 GA100 自己的字段要求、事实、断言、缺失状态、13 个完整度记录和芯片范围的筛选运行。现有 Ampere 资产能减少架构机制重复阅读：21 条事实、42 条架构字段要求和 1 份固定一手白皮书均可通过关系引用。它们不提供 GA100 的直接实现规格，尤其不能提供 A100 SKU 的启用单元、HBM、板级功耗、卡级峰值、NVLink 数量或系统拓扑。

建议主代理将下一步拆成三个顺序门：先登记 GA100 身份来源并写对象关系，再按 die 主体读取本地已登记 A100/Ampere 原始资料以补物理与产品级事实，最后以 GA100 事实集合重做 screening、coverage、reverse-removal 和独立复核。每一步都保持模型、batch、上下文、MoE All-to-All 通信量和 KV Cache 迁移量在 `condition-sets.csv` 或后续负载分析中，不写为 GA100 芯片属性。

## 写入文件与验证

本子任务只新增：`审计/子代理交接/r1_ga100_03_formal_reuse_audit.md`。

验证采用 UTF-8 CSV 解析、主外键闭包追踪、全表主键检索和跨表数量复算。复算得到 0 个 GA100/A100 正式对象、0 条 Ampere 对象关系、21 条 Ampere 关系可读事实、42 条架构字段要求、13 条架构完整度记录、1 条选中来源链、0 个相关冲突组。当前 macOS 环境没有 PowerShell 运行时，未运行三项 Windows 硬门；这属于工具运行时缺失，未影响本次只读审计。正式写入前仍须按项目规定在 Windows 运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1`。
