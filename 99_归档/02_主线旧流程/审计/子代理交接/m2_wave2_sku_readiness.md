# M2 第二波产品 SKU / 云配置准备度审计

> 审计日期：2026-08-13  
> 状态：`completed / ready_for_parent_review`  
> 性质：只读准备度审计。本次只写本报告，没有修改正式 CSV、资料卡、进度、README、AGENTS 或研究计划。

## 审计结论

建议先启动 `M2-A-INSTANCE-TRN2`，把原 `M2-A-INSTANCE` 中已有正式事实的三个 Trainium2 云实例拆成三张独立资料卡：

- `OBJ-AWS-TRN2-3XLARGE`
- `OBJ-AWS-TRN2-48XLARGE`
- `OBJ-AWS-TRN2U-48XLARGE`

这是当前边界最清楚的 SKU / 云配置小包。三个计费 SKU、Trn2 配置族、Trainium2 芯片和 Trainium2 架构对象都已存在；六条实例到家族或芯片的关系，以及一条芯片到架构的关系均已复核。包内还能直接引用 48 条现有实例事实，不需要另建一套 ID。`trn2u.48xlarge` 的首次固定可用日期仍未解决，但这是状态字段缺口，不是对象身份或实例边界不清；资料卡可以开工，缺口继续保留 `pending_verification`。

Google `ct6e-standard` 配置族虽然在原计划中排在配置波次，但当前只有一个家族容器对象，没有配置事实和对象关系，API 名、宿主边界、芯片数量口径及区域状态还依赖动态页面。AWS Trn2 小包无需新增对象或关系，已有 2026-08-12 快照和正式事实链，因而应排在 Google 配置包之前。

## 1. 审计输入和口径

本次完整读取了根规则、三份 M2 批次计划、M2 对象范围验收与 56 行范围映射、正式 `objects.csv` 和 `object-relations.csv`、三份第一波架构包实现对象待办，以及已验收的 Trainium2、H100 SXM5 80 GB、MLU590 资料卡与正式事实链。正式对象表以 2026-08-13 当前版本为准；第一波 20 个架构对象的说明已更新为“第一波已完成，身份与架构事实已复核”，对象 ID、类型和复核状态未变。

计数采用事实目标的实际所有者：对象自身、对象拥有的组件、链路、精度路径、拓扑、能力及以该对象为主语的对象关系都归到同一对象。架构、芯片、实例和系统严格分层。实例总算力、总内存、总带宽、EFA 网络和实例内拓扑不除以芯片数后回填成 Trainium2 芯片定值；芯片与架构事实也不复制成新的 SKU 事实。

本次没有联网更新动态页面。下文的“当前”只表示正式库已保存的 2026-08-12 观察版本；工作包开工时仍要按本文的冻结规则重新核对。

## 2. 候选准备度比较

| 候选 | 当前正式状态 | 可直接复用的内容 | 开工前仍缺什么 | 准备度 |
|---|---|---|---|---|
| AWS Trn2 三个云实例 | 三个 `cloud_instance` 已存在；六条 SKU 关系和芯片到架构关系已复核；其中 `trn2u.48xlarge` 因供货日期待核而为 `needs_resolution` | 48 条包内实例事实、48 条逐来源断言、51 条包内字段要求；Trainium2 芯片与架构事实链可引用 | 重新冻结动态产品页；固定证据找不到时继续保留两条首次可用日期缺口 | 可立即启动 |
| NVIDIA H100 SXM5 80 GB | `module` 已有 64 条按当前归属规则统计的事实和两条已复核关系，资料卡已验收 | 固定版数据表、白皮书和 Hot Chips 资料 | H100 本身已完成；扩到 H100 PCIe、H100 NVL、H200 等兄弟 SKU 前要新建对象并处理多器件边界 | 不适合作为新的先行包 |
| NVIDIA L20 / L2 | 两个 `card` 均已建对象，各有一条到 Ada Lovelace 架构的已复核关系 | Ada 架构事实可引用 | 当前均为 0 条 SKU 事实；还要取得对象匹配的数据表和供货状态快照 | 先做来源预审 |
| AMD MI350P / MI308X / MI455X | `card` 或 `module` 对象已存在；MI350P、MI455X 有架构关系，MI308X 的 CDNA 3 关系待核 | CDNA4、CDNA5 架构事实可引用 | 三个对象当前均为 0 条产品事实；需要固定产品级证据，MI455X 还处于 announced 边界 | 排在 AWS 之后 |
| Google `ct6e-standard` 配置家族 | `OBJ-GOOGLE-CT6E-STANDARD-FAMILY` 已作为 `cloud_instance` 家族容器导入 | TPU v6e 架构事实可引用 | 0 条配置事实、0 条对象关系；1t/4t/8t 仍是待冻结配置行，动态 API 和区域页面风险高 | 先做配置建模和快照预审 |
| 寒武纪 MLU590-H8 / M9 | 两个 `card` 对象均为 `needs_resolution` | MLU590 芯片已有少量身份与软件事实 | 卡到 MLU590 芯片的包含关系尚无一手证据；受限页面无法确认完整订货名和规格 | 当前阻塞 |

AWS 的优势不在披露更完整，而在于工作边界已经固定。Google 配置包必须先回答“一个 API 配置行是不是独立对象、宿主与 TPU 器件如何映射”；Trn2 小包只需把已存在的实例事实从综合试填卡拆成三张主对象明确的卡。

## 3. 建议工作包的冻结边界

`M2-A-INSTANCE-TRN2` 是建议的工作包名，正式 ID 仍由总控预留。包内不新增对象。

| 处理方式 | 精确对象 ID | 本包职责 |
|---|---|---|
| 建三张正式卡 | `OBJ-AWS-TRN2-3XLARGE`；`OBJ-AWS-TRN2-48XLARGE`；`OBJ-AWS-TRN2U-48XLARGE` | 每个计费 SKU 一张卡，只写实例身份、实例级资源、实例内互联、EFA、状态和缺口 |
| 只作关系端点 | `OBJ-AWS-TRN2-INSTANCE-FAMILY` | 配置族容器，不承载三个实例的聚合规格，不另建卡 |
| 只作引用对象 | `OBJ-AWS-TRAINIUM2-CHIP`；`OBJ-AWS-TRAINIUM2-ARCH` | 卡片通过关系和既有事实 ID 引用芯片实现及共享架构，不复制事实 |
| 冻结在包外 | `OBJ-AWS-TRN2-ULTRASERVER-64` | 系统对象、64 芯片聚合值、跨实例 ring、UltraServer EFA 和供货冲突全部留给 `M2-A-SYSTEM` |

`OBJ-AWS-TRN2-3XLARGE` 和 `OBJ-AWS-TRN2-48XLARGE` 的对象状态为 `reviewed`。`OBJ-AWS-TRN2U-48XLARGE` 为 `needs_resolution`，原因只涉及首次固定可用日期和当前供货状态；其作为独立计费 SKU、含 16 个 Trainium2 的关系以及与普通 `trn2.48xlarge` 分开的对象边界已经有正式记录。

### 3.1 必须先核对的关系

以下七条关系已存在且为 `reviewed`，工作包开始时只需核对当前正式表没有变化：

| 关系 ID | 主语到宾语 | 用途 |
|---|---|---|
| `OREL-AWS-TRN2-3XLARGE-VARIANT-OF-FAMILY` | `OBJ-AWS-TRN2-3XLARGE` → `OBJ-AWS-TRN2-INSTANCE-FAMILY` | SKU 归入 Trn2 配置族 |
| `OREL-AWS-TRN2-48XLARGE-VARIANT-OF-FAMILY` | `OBJ-AWS-TRN2-48XLARGE` → `OBJ-AWS-TRN2-INSTANCE-FAMILY` | 同上 |
| `OREL-AWS-TRN2U-48XLARGE-VARIANT-OF-FAMILY` | `OBJ-AWS-TRN2U-48XLARGE` → `OBJ-AWS-TRN2-INSTANCE-FAMILY` | 同上 |
| `OREL-AWS-TRN2-3XLARGE-CONTAINS-TRAINIUM2` | `OBJ-AWS-TRN2-3XLARGE` → `OBJ-AWS-TRAINIUM2-CHIP` | 实例包含加速器；数量由事实另存 |
| `OREL-AWS-TRN2-48XLARGE-CONTAINS-TRAINIUM2` | `OBJ-AWS-TRN2-48XLARGE` → `OBJ-AWS-TRAINIUM2-CHIP` | 同上 |
| `OREL-AWS-TRN2U-48XLARGE-CONTAINS-TRAINIUM2` | `OBJ-AWS-TRN2U-48XLARGE` → `OBJ-AWS-TRAINIUM2-CHIP` | 同上 |
| `OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH` | `OBJ-AWS-TRAINIUM2-CHIP` → `OBJ-AWS-TRAINIUM2-ARCH` | 芯片实现 Trainium2 架构 |

必须新增的关系为 0 条。不要为了读取方便再建 SKU 到架构的 `implements_architecture` 捷径；实例到芯片、芯片到架构的两级链已经足够。`OREL-AWS-TRN2-INSTANCE-CONTAINS-TRAINIUM2` 是家族层导航关系，不能推导任一 SKU 的芯片数量。

`OREL-AWS-TRN2U-48XLARGE-DEPLOYED-IN-ULTRASERVER` 仍为 `needs_resolution`。它不阻塞实例卡，但本包不得引用其数量事实或把它改成已解决关系。

## 4. 可直接引用的实例事实

三张卡共有 48 条包内事实和 48 条逐来源断言：`trn2.3xlarge` 4 条，`trn2.48xlarge` 23 条，`trn2u.48xlarge` 21 条。按当前状态计，28 条为 `provisional`，20 条为 `conflict_member`。这里的“可引用”是复用现有 `fact_id`，不是重新抽取或复制记录。

### 4.1 `OBJ-AWS-TRN2-3XLARGE`：4 条

- 对象关系与网络：`FACT-AWS-TRN2-3XL-CHIP-QTY`、`FACT-AWS-TRN2-3XL-EFA-RATE`
- 内存及冲突：`FACT-AWS-TRN2-3XL-MEM-CAP`、`FACT-AWS-TRN2-3XL-MEM-CAP-GENERIC`

后一条来自官方通用 EC2 表，但该来源已标 `rejected_unreliable`，只能作为冲突和质量审计证据，不能作为卡片采用值。

### 4.2 `OBJ-AWS-TRN2-48XLARGE`：23 条

身份、组成、内存和互联共有 10 条：

- `FACT-AWS-TRN2-48XL-CHIP-QTY`
- `FACT-AWS-TRN2-48XL-STATUS-GA`
- `FACT-AWS-TRN2-48XL-EFA-RATE`
- `FACT-AWS-TRN2-48XL-INTRA-BW`
- `FACT-AWS-TRN2-48XL-MEM-BW`
- `FACT-AWS-TRN2-48XL-MEM-CAP`
- `FACT-AWS-TRN2-48XL-MEM-CAP-GENERIC`
- `FACT-AWS-TRN2-48XL-TOPO-TYPE`
- `FACT-AWS-TRN2-48XL-TOPO-DIMS`
- `FACT-AWS-TRN2-48XL-TOPO-NODES`

实例级精度吞吐共有 13 条：

- `FACT-AWS-TRN2-48XL-BF16-DENSE`
- `FACT-AWS-TRN2-48XL-FP16-DENSE`
- `FACT-AWS-TRN2-48XL-FP32-DENSE`
- `FACT-AWS-TRN2-48XL-FP8-DENSE`
- `FACT-AWS-TRN2-48XL-TF32-DENSE`
- `FACT-AWS-TRN2-48XL-BF16-SPARSE`
- `FACT-AWS-TRN2-48XL-FP16-SPARSE`
- `FACT-AWS-TRN2-48XL-FP8-SPARSE`
- `FACT-AWS-TRN2-48XL-TF32-SPARSE`
- `FACT-AWS-TRN2-48XL-BF16-SPARSE-HIST2024`
- `FACT-AWS-TRN2-48XL-FP16-SPARSE-HIST2024`
- `FACT-AWS-TRN2-48XL-FP8-SPARSE-HIST2024`
- `FACT-AWS-TRN2-48XL-TF32-SPARSE-HIST2024`

当前 Neuron 2.29.1 表与 2024-12-03 发布博客的稀疏吞吐不同，八条对应事实保持冲突成员，不能挑一个数字覆盖另一个。

### 4.3 `OBJ-AWS-TRN2U-48XLARGE`：21 条

身份、组成、内存和互联共有 8 条：

- `FACT-AWS-TRN2U-48XL-CHIP-QTY`
- `FACT-AWS-TRN2-TRN2U-48XL-EFA-RATE`
- `FACT-AWS-TRN2-TRN2U-48XL-INTRA-BW`
- `FACT-AWS-TRN2-TRN2U-48XL-MEM-BW`
- `FACT-AWS-TRN2-TRN2U-48XL-MEM-CAP`
- `FACT-AWS-TRN2-TRN2U-48XL-TOPO-TYPE`
- `FACT-AWS-TRN2-TRN2U-48XL-TOPO-DIMS`
- `FACT-AWS-TRN2-TRN2U-48XL-TOPO-NODES`

实例级精度吞吐共有 13 条：

- `FACT-AWS-TRN2-TRN2U-48XL-BF16-DENSE`
- `FACT-AWS-TRN2-TRN2U-48XL-FP16-DENSE`
- `FACT-AWS-TRN2-TRN2U-48XL-FP32-DENSE`
- `FACT-AWS-TRN2-TRN2U-48XL-FP8-DENSE`
- `FACT-AWS-TRN2-TRN2U-48XL-TF32-DENSE`
- `FACT-AWS-TRN2-TRN2U-48XL-BF16-SPARSE`
- `FACT-AWS-TRN2-TRN2U-48XL-FP16-SPARSE`
- `FACT-AWS-TRN2-TRN2U-48XL-FP8-SPARSE`
- `FACT-AWS-TRN2-TRN2U-48XL-TF32-SPARSE`
- `FACT-AWS-TRN2-TRN2U-48XL-BF16-SPARSE-HIST2024`
- `FACT-AWS-TRN2-TRN2U-48XL-FP16-SPARSE-HIST2024`
- `FACT-AWS-TRN2-TRN2U-48XL-FP8-SPARSE-HIST2024`
- `FACT-AWS-TRN2-TRN2U-48XL-TF32-SPARSE-HIST2024`

`FACT-AWS-TRN2-ULTRA64-INSTANCE-QTY` 的目标是 `OREL-AWS-TRN2U-48XLARGE-DEPLOYED-IN-ULTRASERVER`，属于系统组成，不计入上述 21 条。对应的 `REQ-AWS-TRN2-0092` 也冻结在包外。

### 4.4 现有字段要求

剔除 `REQ-AWS-TRN2-0092` 后，包内可复用 51 条字段要求：28 条 `value_available`、20 条 `conflicting_unresolved`、2 条 `pending_verification` 和 1 条 `not_found`。两条待核要求是：

- `REQ-AWS-TRN2-0194`：`trn2.3xlarge` 的 `FIELD-ID-AVAILABILITY-DATE`
- `REQ-AWS-TRN2-0195`：`trn2u.48xlarge` 的 `FIELD-ID-AVAILABILITY-DATE`

`REQ-AWS-TRN2-0185` 记录 `trn2.48xlarge` 的 `FIELD-INT-BISECTION-BW` 为 `not_found`。工作包无需为了让卡片看起来完整而用拓扑推算对分带宽。

## 5. 架构与芯片事实的复用方式

与本包对应的实现待办是 `DEF-M2GA-ATRN2-01`。它把 109 条 M1 Trainium2 芯片、组件、链路、精度路径和能力事实指向 `OBJ-AWS-TRAINIUM2-CHIP`，来源范围为 `SRC-AWS-TRN2-S01` 至 `SRC-AWS-TRN2-S14`，处置明确为“引用既有事实，不复制”。完整精确列表已经保存在第一波交接中的 `trainium2_existing_reuse_map.csv`，本包不另造平行清单或事实 ID。

只有下面三条是架构对象本身的直接事实：

| `fact_id` | `source_id` | 卡片中的用途 |
|---|---|---|
| `FACT-AWS-TRN2-ARCH-RELEASE-DATE` | `SRC-AWS-TRN2-S11` | Trainium2 架构/产品首次正式公布日期 |
| `FACT-AWS-TRN2-ARCH-SW-MODEL` | `SRC-AWS-TRN2-S07` | 共享编程模型和框架入口 |
| `FACT-AWS-TRN2-ARCH-SW-RUNTIME` | `SRC-AWS-TRN2-S14` | AWS Neuron SDK 运行时 |

其余条目是芯片或组件实现事实。实例卡可在“共享架构引用”中列出这些 ID，但不能把它们写成实例自身的原子事实：

| 主题 | 可引用的精确 `fact_id` | `source_id` |
|---|---|---|
| 执行组织 | `FACT-AWS-TRN2-NCV3-COUNT`；`FACT-AWS-TRN2-TENSOR-ARRAY-SHAPE`；`FACT-AWS-TRN2-TENSOR-EXECUTION-RATES`；`FACT-AWS-TRN2-TENSOR-FP8-TILE`；`FACT-AWS-TRN2-VECTOR-FP32-CORE`；`FACT-AWS-TRN2-SCALAR-FP32-CORE`；`FACT-AWS-TRN2-SPARSITY-MODES` | `SRC-AWS-TRN2-S01`、`S02`、`S03`、`S04`，以逐事实断言为准 |
| 精度和累加 | `FACT-AWS-TRN2-TENSOR-FP8-OPERAND-A`；`FACT-AWS-TRN2-TENSOR-FP8-OPERAND-B`；`FACT-AWS-TRN2-TENSOR-FP8-ACCUM`；`FACT-AWS-TRN2-TENSOR-FP8-OUTPUT`；`FACT-AWS-TRN2-TENSOR-BF16-OPERAND-A`；`FACT-AWS-TRN2-TENSOR-BF16-OPERAND-B`；`FACT-AWS-TRN2-TENSOR-BF16-ACCUM`；`FACT-AWS-TRN2-TENSOR-BF16-OUTPUT`；`FACT-AWS-TRN2-TENSOR-FP16-OPERAND-A`；`FACT-AWS-TRN2-TENSOR-FP16-OPERAND-B`；`FACT-AWS-TRN2-TENSOR-FP16-ACCUM`；`FACT-AWS-TRN2-TENSOR-FP16-OUTPUT`；`FACT-AWS-TRN2-TENSOR-TF32-OPERAND-A`；`FACT-AWS-TRN2-TENSOR-TF32-OPERAND-B`；`FACT-AWS-TRN2-TENSOR-TF32-ACCUM`；`FACT-AWS-TRN2-TENSOR-TF32-OUTPUT`；`FACT-AWS-TRN2-TENSOR-FP32-OPERAND-A`；`FACT-AWS-TRN2-TENSOR-FP32-OPERAND-B`；`FACT-AWS-TRN2-TENSOR-FP32-ACCUM`；`FACT-AWS-TRN2-TENSOR-FP32-OUTPUT` | `SRC-AWS-TRN2-S04` |
| FP8 数值行为 | `FACT-AWS-TRN2-TENSOR-FP8-ROUNDING`；`FACT-AWS-TRN2-TENSOR-FP8-SCALING` | `SRC-AWS-TRN2-S03` |
| 存储和搬运 | `FACT-AWS-TRN2-HBM-CAPACITY`；`FACT-AWS-TRN2-HBM-BANDWIDTH`；`FACT-AWS-TRN2-SBUF-CAPACITY-CORE`；`FACT-AWS-TRN2-SBUF-MANAGEMENT`；`FACT-AWS-TRN2-PSUM-CAPACITY-CORE`；`FACT-AWS-TRN2-MAIN-DMA-BW` | `SRC-AWS-TRN2-S01`、`S02`，以逐事实断言为准 |
| 芯片互联 | `FACT-AWS-TRN2-NEURONLINK-IF-COUNT`；`FACT-AWS-TRN2-NEURONLINK-AGG-BW` | `SRC-AWS-TRN2-S01` |
| 集合通信与软件算子 | `FACT-AWS-TRN2-CAP-COLLECTIVE-HW-LEVEL`；`FACT-AWS-TRN2-CAP-COLLECTIVE-NKI-LEVEL`；`FACT-AWS-TRN2-CAP-MOE-NKI-LEVEL`；`FACT-AWS-TRN2-CAP-TOPK-NKI-LEVEL` | `SRC-AWS-TRN2-S01`、`S08`、`S12`、`S13`，以逐事实断言为准 |

最后两条只证明 MoE 和 Router Top-K 有 NKI 库实现，不能在实例卡里写成 Trainium2 含专用物理模块。实例内的 4×4 torus 与 EFAv3 也分别属于实例内互联和实例级横向扩展网络，不能和芯片上的 NeuronLink-v3 接口数量混成一个带宽口径。

Google TPU v6e 对照项仍有 `DEF-M2GA-GV6E-01` 至 `DEF-M2GA-GV6E-04`，分别等待把单器件的计算单元数量、峰值、HBM 和 ICI 端口/带宽下沉到尚未冻结的 cloud accelerator/device 对象。这四条待办说明 Google 配置族还缺一层可被配置行引用的实现对象；Trn2 已经有 `OBJ-AWS-TRAINIUM2-CHIP` 和 109 条现成实现事实，因此优先级更高。

## 6. 最低一手证据组合与动态冻结风险

三张实例卡的包内 48 条断言只用五个 AWS 官方来源：`SRC-AWS-TRN2-S06` 33 条、`S07` 4 条、`S09` 1 条、`S10` 8 条、`S15` 2 条。前四个来源构成包内最小入选集；`S15` 不进入最小集，只保留为被拒绝的冲突审计来源。

| `source_id` | 正式状态与独有职责 | 已保存快照及核对结果 | 开工时处理 |
|---|---|---|---|
| `SRC-AWS-TRN2-S06` | `current`；Neuron 2.29.1 版本化 Trn2 架构页，独有实例聚合规格、拓扑与多数吞吐事实 | 2026-08-12；SHA-256 `7fb896ec667656d3ee2ce9641e595deef15094851505fcdc63413aa990dfcb00`；本地实算一致 | 作为 `core_spec` 保留；版本号变化时新建内容版本，不覆盖旧快照 |
| `SRC-AWS-TRN2-S07` | `dynamic_unfrozen`；EC2 Trn2 产品页，独有 `trn2.3xlarge` 配置、三实例 EFA 和截止日观察状态 | 2026-08-12；SHA-256 `4c315ad5c342d10e1e0a6a8a5ab59b87be94e9fc19911f6ac122964317aa32cf`；本地实算一致 | 工作包截止日必须重新保存快照；内容哈希变化时新建来源版本并重跑事实与最小集 |
| `SRC-AWS-TRN2-S09` | `current`；2024-12-03 固定 GA 公告，独有 `trn2.48xlarge` 正式可用日期 | 2026-08-12；SHA-256 `153871394577aa451cebacf67c7e7fe62683abd74645b56b8886dd316506f037`；本地实算一致 | 作为 `status_version_evidence` 保留 |
| `SRC-AWS-TRN2-S10` | `current`；2024-12-03 发布博客，保留首发区域和稀疏吞吐历史冲突 | 2026-08-12；SHA-256 `dd48c849a0e6ce3f2577c2b048de587026b658fba306168edb730b7475ee55a2`；本地实算一致 | 作为 `conflict_evidence` 与历史状态证据保留，不拿历史值覆盖当前版本表 |
| `SRC-AWS-TRN2-S15` | `dynamic_unfrozen`，筛选状态 `rejected_unreliable`；通用 EC2 表与产品页、架构页的内存单元冲突 | 2026-08-12；SHA-256 `efa57a13af5ef3995be93dcbb43476a6552a1e2b25dae71addd530dbdac854f4`；本地实算一致 | 不作为采用值来源；若报告要描述“当前通用表仍冲突”，再取一份同日快照，否则保留 2026-08-12 历史审计版本 |

最低正向证据组合是 `S06 + S07 + S09`：版本化技术页负责配置和拓扑，动态产品页负责当前 SKU 入口，固定 GA 公告负责 `trn2.48xlarge` 的首发状态。由于现有正式事实还保留 2024 年稀疏值，`S10` 在当前事实集合下也不能移除。`S15` 的两条冲突事实保留在正式库，但来源继续维持 `rejected_unreliable`，不计入最小入选来源。

`trn2.3xlarge` 和 `trn2u.48xlarge` 的首次固定可用日期仍缺一手定日证据。开工后可以各补一份 AWS 固定公告、版本发布记录或带稳定日期的官方文档；找不到时不使用产品页的“当前可见”反推发布日期，继续保留 `REQ-AWS-TRN2-0194` 和 `REQ-AWS-TRN2-0195`。

## 7. 工作量预算

| 产物 | 预算 | 边界 |
|---|---:|---|
| 正式资料卡 | 3 张 | 每个实例一张；家族、芯片、架构和 UltraServer 不在本包新建卡 |
| 新对象 | 0 | 六个相关对象均已存在 |
| 新关系 | 0 | 七条必需关系已复核；UltraServer 部署关系留在系统包 |
| 复用实例事实 | 48 条 | 4 + 23 + 21；使用原 `fact_id` 和断言，不复制 |
| 复用字段要求 | 51 条 | 28 条有值、20 条冲突、2 条待核、1 条未找到 |
| 新事实 | 0 至 4 条 | 只允许补 `trn2.3xlarge`、`trn2u.48xlarge` 的固定首次可用日期和有明确截止日的一手当前状态；找不到就不建事实 |
| 最小入选来源 | 4 个现有来源 | `S06`、`S07`、`S09`、`S10`；`S15` 另作被拒绝的冲突审计来源 |
| 新来源 | 0 至 2 个 | 只为两条首次可用日期缺口补固定 AWS 一手证据 |
| 动态页冻结 | 1 个必做，1 个条件项 | 必做 `S07`；只有继续描述通用表当前状态时才重新冻结 `S15` |
| 架构/芯片新事实 | 0 | 通过 `DEF-M2GA-ATRN2-01` 和既有事实链引用 |

如果 `S07` 哈希不变、两条日期缺口也未找到新证据，结构化事实可以保持 48 条不变；工作量主要是把综合试填卡拆成三张可维护资料卡、修正卡片事实引用，并生成包级最小来源选择运行。

## 8. 开工顺序

先冻结三张卡的主对象和七条关系，再为 `S07` 保存截止日快照并比较内容哈希。快照没有改变时，直接按上述 48 个 `fact_id` 拆卡；页面变化时，只复核受影响断言，不把同一 URL 的新内容覆盖到旧来源版本。

卡片成稿后再检索两条首次可用日期。固定一手资料没有结果时，缺口维持原状态。最后按 48 条包内事实重跑一次包级反向移除：`S06`、`S07`、`S09`、`S10` 各自仍有独有事实或版本职责时才进入最小集，`S15` 保持被拒绝的冲突审计身份。

Google `M2-G-CONFIG` 可同时做只读来源预审，但不要与 Trn2 争用正式关系和共享配置表的写入窗口。它至少要先补齐 v6e 器件对象、配置族到器件的关系、1t/4t/8t 配置行模型和同日 Cloud TPU 快照，之后再进入卡片抽取。

## 9. 独立验收门

独立复核人不能参与三张卡的初稿。只有以下条件同时满足，工作包才可交总控合并：

1. 三张卡各只有一个主对象，`OBJ-AWS-TRN2-INSTANCE-FAMILY` 只作关系端点；卡片中没有 UltraServer 的 64 芯片、跨实例 ring、系统 EFA 或供货结论。
2. 七条必需关系仍为 `reviewed`，新增关系数为 0；`OREL-AWS-TRN2U-48XLARGE-DEPLOYED-IN-ULTRASERVER` 和 `REQ-AWS-TRN2-0092` 不进入包内事实覆盖。
3. 48 条包内事实全部进入相应卡片，卡片没有新造平行 `fact_id`；卡片事实 ID 到正式事实、正式事实到卡片的双向检查均为 0 缺漏。
4. 作用域和单位保持原样：GB 与 GiB 不互换，稠密与结构化稀疏不合并，当前版本值与 2024 历史值不覆盖，EFAv3、实例内 NeuronLink 和芯片 NeuronLink-v3 分开。
5. `S15` 的通用表数值不作为采用值；`S06` 与 `S10` 的稀疏吞吐冲突保持 `conflicting_unresolved`，除非出现同口径、同版本的一手裁决证据。
6. `S07` 有工作包截止日快照、SHA-256 和本地入口。找不到固定首发证据时，两条日期要求继续是 `pending_verification`，不能以当前产品页替代。
7. 包级 selection run 以实际事实集合重跑，记录反向移除。动态页面版本或事实集合变化时不得沿用 `SELRUN-M1-PILOTS-20260812` 的结论。
8. 三张卡的九个完整度领域都有状态。与云实例不适用的芯片物理字段写明引用或不适用原因，不能为了填满模板复制架构共性。
9. staging 的主键、外键、枚举、断言、来源端点哈希和卡片事实 ID 自检通过；临时合并正式库后运行 `Validate-ResearchData.ps1`。如果新增来源池文件，再运行 `Test-SourcePool.ps1`。
10. 独立复核报告明确给出 `accept`、`accept_with_fixes` 或 `reject`；只有 `accept` 才进入总控合并。

## 10. 文档检查

本报告按 `docs` 场景完成自然化检查。`report-humanizer` 机器扫描为 0 条；人工复查了标题、首段、表格引导、段落转场和结尾，没有发现需要改写的模板化表达。随后按 `shuorenhua` 的 `docs / minimal` 口径做了两遍回读：第一遍核对对象 ID、关系 ID、事实 ID、来源 ID、日期、数量、状态枚举、SHA-256、文件名和作用域关系，未发现漂移；第二遍检查开场、空总结、旁白、空泛判断和句式重复，没有再改动受保护内容。

根 `README.md` 和 `AGENTS.md` 已检查。本次是只读准备度审计，项目范围、正式状态、目录结构、运行方式和协作规则没有因本报告改变，因此按任务边界不修改这两个文件。