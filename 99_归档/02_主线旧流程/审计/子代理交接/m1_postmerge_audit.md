# M1 合并后独立复核：H100 与 Trainium2

## 交接状态

- 任务状态：复核主体已完成，结论为 M1 暂不能通过。
- 复核日期：2026-08-12。
- 复核范围：H100、GH100 和 Trainium2 的两张资料卡，正式 32 表，字段字典与模板，`pilot_independent_review.md`，H100 与 Trainium2 staging README。
- 写入边界：本任务只写本文件，没有修改正式 CSV、资料卡、README、AGENTS、进度或研究计划。
- 技能边界：未使用 `literature-survey`。交付前还会执行 `report-humanizer` 扫描和 `shuorenhua` 的事实保真检查，并在文末补记结果。

## 结论

B-01 已关闭：GH100 裸片已经成为独立对象，H100 SXM5 模组与裸片之间也有明确的物理包含关系。B-04 的基础外键链也已关闭：H100/Trainium2 范围内有 245 条事实，其中 223 条为直接事实、22 条为派生事实；223 条直接事实均至少有一条断言，231 条断言均能找到来源，实际使用的 19 个来源均至少有一个访问入口。

B-02 只关闭了一半。条件表已经区分 `per_component` 与 `per_object`，派生表也保留了 8 倍汇聚公式；但每核和芯片聚合算力仍共用以 NCv3 Tensor Engine 为所有者的同一条精度路径，芯片级事实本身没有结构化地指向 Trainium2 芯片对象。稀疏算力冲突组又把“每核乘 8 的范围争议”和“2024 与当前文档的版本变化”混在同一个冲突类型中。因此，当前数据能提醒读者存在范围问题，却还不能稳定表达每核与每芯片两个不同事实层级。

除 B-02 外，仍有三类阻断：直接事实的证据状态与独立来源数不一致；Trainium2 卡片与 `facts.csv` 对两个特殊能力给出了不同实现层级；最小参考资料集尚未通过正式反向移除和 selection run 证明。它们分别属于数据语义错误、卡片与唯一真值冲突、以及“最小集尚未证成”，不能混成同一种问题。

## 阻断项

### A-01：证据状态与来源数不一致（数据错误）

下列 21 条直接事实标为 `corroborated`，但每条目前只有一个不同的 `source_id`。正式证据状态与断言表不相符，不能用“同一来源有多种展示方式”解释。

| 唯一来源 | 受影响的事实 ID |
|---|---|
| `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04` | `FACT-NVIDIA-H100-HBM-CAPACITY` |
| `SRC-AWS-TRN2-S01` | `FACT-AWS-TRN2-HBM-BANDWIDTH`、`FACT-AWS-TRN2-HBM-CAPACITY`、`FACT-AWS-TRN2-HBM-STACKS`、`FACT-AWS-TRN2-MAIN-DMA-BW`、`FACT-AWS-TRN2-NEURONLINK-AGG-BW`、`FACT-AWS-TRN2-NEURONLINK-IF-COUNT`、`FACT-AWS-TRN2-SBUF-CAPACITY-CHIP-AGG` |
| `SRC-AWS-TRN2-S02` | `FACT-AWS-TRN2-SBUF-MANAGEMENT` |
| `SRC-AWS-TRN2-S03` | `FACT-AWS-TRN2-GPSIMD-ISSUE-WIDTH`、`FACT-AWS-TRN2-TENSOR-FP8-ROUNDING` |
| `SRC-AWS-TRN2-S06` | `FACT-AWS-TRN2-3XL-CHIP-QTY`、`FACT-AWS-TRN2-48XL-CHIP-QTY`、`FACT-AWS-TRN2U-48XL-CHIP-QTY`、`FACT-AWS-TRN2-ULTRA64-CHIP-QTY`、`FACT-AWS-TRN2-ULTRA64-INSTANCE-QTY`、`FACT-AWS-TRN2-TRN2U-48XL-MEM-CAP`、`FACT-AWS-TRN2-ULTRA64-MEM-CAP` |
| `SRC-AWS-TRN2-S07` | `FACT-AWS-TRN2-ARCH-SW-MODEL` |
| `SRC-AWS-TRN2-S09` | `FACT-AWS-TRN2-48XL-STATUS-GA` |
| `SRC-AWS-TRN2-S14` | `FACT-AWS-TRN2-ARCH-SW-RUNTIME` |

反方向也有 5 条 H100 直接事实标为 `single_source`，却同时由 `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04` 和 `SRC-NVIDIA-HOPPER-TUNING-GUIDE-13-3` 断言：`FACT-NVIDIA-H100-REG-CAPACITY-PER-SM`、`FACT-NVIDIA-H100-L1SMEM-CAPACITY-PER-SM`、`FACT-NVIDIA-H100-NVLINK-LINK-COUNT`、`FACT-NVIDIA-H100-TMA-DETAIL`、`FACT-NVIDIA-H100-DPX-THROUGHPUT-16`。

建议先冻结 `corroborated` 的判定单位究竟是不同 `source_id`、不同来源家族，还是独立发布者；随后批量重算 `evidence_state`。若没有第二条合格断言，前述 21 条应降为 `single_source` 或与其证据含义相符的状态。若保留 H100 的 5 条双来源断言，则也应按冻结后的规则调整状态。校验器应加入直接事实的证据状态与来源基数约束，避免只验证外键存在而漏过语义错误。

### A-02：卡片与正式唯一真值冲突（数据错误）

| 能力 | 资料卡 | `facts.csv` | 断言来源 |
|---|---|---|---|
| CC-Core/NeuronLink 集体通信 | `network_offload`（暂定） | `FACT-AWS-TRN2-CAP-COLLECTIVE-HW-LEVEL = dedicated_physical_module` | `ASSERT-FACT-AWS-TRN2-CAP-COLLECTIVE-HW-LEVEL-S01` / `SRC-AWS-TRN2-S01` |
| Tensor Engine 内建转置 | `configurable_engine`（暂定） | `FACT-AWS-TRN2-CAP-TENSOR-TRANSPOSE-LEVEL = dedicated_instruction` | `ASSERT-FACT-AWS-TRN2-CAP-TENSOR-TRANSPOSE-LEVEL-S02` / `SRC-AWS-TRN2-S02` |

`facts.csv` 被定义为规范事实层，Markdown 卡片不能保留第二套规范值。建议重新读 S01、S02 的原文定位后决定实现层级；在证据不能区分“物理模块”“指令”和“可配置引擎”时，应保留 `provisional`，但卡片和正式表必须使用同一值、同一理由。

### A-03：每核与芯片算力仍未结构化分层（B-02 未关闭）

`PP-AWS-TRN2-TENSOR-FP8` 的所有者是 `CMP-AWS-TRN2-TENSOR`，标签为 “NCv3 Tensor FP8 matrix path”。但 `FACT-AWS-TRN2-CORE-FP8-DENSE-PUB`、`FACT-AWS-TRN2-CHIP-FP8-DENSE-PUB` 和 `FACT-AWS-TRN2-CHIP-FP8-DENSE-DER8` 都挂在这条路径上；BF16、FP16、TF32、FP32 同样如此。条件分别写 `measurement_scope=per_component` 和 `measurement_scope=per_object`，但芯片事实没有直接外键指向 `OBJ-AWS-TRAINIUM2-CHIP`，`aggregation_scope` 也为空。当前芯片直报值由 `SRC-AWS-TRN2-S01` 断言，每核值由 `SRC-AWS-TRN2-S02` 断言，8 倍派生依赖 S02 的每核值和 S01 的 `FACT-AWS-TRN2-NCV3-COUNT`；2024 历史稀疏值来自 `SRC-AWS-TRN2-S10`。

此外，`CG-AWS-TRN2-003-CHIP-FP8`、`CG-AWS-TRN2-003-CHIP-BF16`、`CG-AWS-TRN2-003-CHIP-FP16`、`CG-AWS-TRN2-003-CHIP-TF32` 均标为 `version_change`，每组却同时包含当前芯片直报值、每核乘 8 的派生值和 2024 历史发布值。这里同时存在 scope disagreement 与 version change，单一类型不能表达两个轴。

建议为芯片聚合新建独立的芯片级精度路径或等价的明确目标，把每核直接值、芯片直接值和 8 倍派生值分别归位。四个芯片稀疏冲突组应拆成两层：当前直报值与 8 倍派生值进入范围争议组；当前直报值与 2024 历史值进入版本变化组。实例级的 `CG-AWS-TRN2-003-48XL-*` 和 `CG-AWS-TRN2-003-TRN2U-48XL-*` 只比较当前与历史值，可以继续作为版本变化。

### A-04：最小来源集尚未证成（最小集问题）

`selection-runs.csv` 和 `selection-members.csv` 当前均为 0 行。H100 有两条 `source-coverage` 记录用来说明 IEEE Micro 被白皮书和 Hot Chips 覆盖，但 Trainium2 没有覆盖关系记录，也没有正式 selection run。

反向移除以当前已登记断言为准。这里的“独有”只表示该事实没有被当前 selected 集中的另一来源断言，不表示整个资料池中没有替代来源。

| H100 selected 来源 | 已断言事实 | 移除后缺失的独有事实 |
|---|---:|---:|
| `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04` | 51 | 44 |
| `SRC-NVIDIA-H100-DATASHEET-20240924` | 7 | 7 |
| `SRC-NVIDIA-H100-HOTCHIPS34-2022` | 1 | 1 |
| `SRC-NVIDIA-HOPPER-TUNING-GUIDE-13-3` | 7 | 0 |

| Trainium2 selected 来源 | 已断言事实 | 移除后缺失的独有事实 |
|---|---:|---:|
| `SRC-AWS-TRN2-S01` | 22 | 22 |
| `SRC-AWS-TRN2-S02` | 33 | 33 |
| `SRC-AWS-TRN2-S03` | 5 | 5 |
| `SRC-AWS-TRN2-S04` | 22 | 22 |
| `SRC-AWS-TRN2-S05` | 2 | 2 |
| `SRC-AWS-TRN2-S06` | 51 | 51 |
| `SRC-AWS-TRN2-S07` | 8 | 8 |
| `SRC-AWS-TRN2-S08` | 1 | 1 |
| `SRC-AWS-TRN2-S09` | 2 | 2 |
| `SRC-AWS-TRN2-S10` | 12 | 12 |
| `SRC-AWS-TRN2-S11` | 1 | 1 |
| `SRC-AWS-TRN2-S12` | 1 | 1 |
| `SRC-AWS-TRN2-S13` | 1 | 1 |
| `SRC-AWS-TRN2-S14` | 1 | 1 |

计数显示只有 Tuning Guide 的结构化独有贡献为 0，但 S14 的形式独有性与它的保留角色并不相符，具体如下：

- `SRC-NVIDIA-HOPPER-TUNING-GUIDE-13-3` 断言 7 条事实，独有事实为 0；`FACT-NVIDIA-H100-REG-CAPACITY-PER-SM`、`FACT-NVIDIA-H100-DPX-THROUGHPUT-16`、`FACT-NVIDIA-H100-TMA-DETAIL`、`FACT-NVIDIA-H100-NVLINK-LINK-COUNT`、`FACT-NVIDIA-H100-L1SMEM-SHARED-MAX`、`FACT-NVIDIA-H100-L1SMEM-CAPACITY-PER-SM`、`FACT-NVIDIA-H100-DSM-DETAIL` 全部被 H100 v1.04 白皮书覆盖。资料卡提到的 48 KiB carveout 和静态共享内存限制没有进入正式事实层。因此它目前可以从 selected 集中移除，或者先把真正独有、且属于卡片字段范围的机制/限制结构化后再保留。
- `SRC-AWS-TRN2-S14` 只有 `FACT-AWS-TRN2-ARCH-SW-RUNTIME = AWS Neuron SDK` 一条形式上的独有事实，但它的 selected role 是 `status_version_evidence`，筛选理由是 Neuron 2.21 首次支持 Trainium2。版本号、发布日期和“首次支持”没有进入正式事实层；单凭泛化的 runtime 名称不能证明 S14 不可替代。建议把它独有的历史版本事实结构化，或改为非 selected。
- 其余 13 个 Trainium2 selected 来源在“当前断言集合”中各有至少 1 条独有事实，但这只是抽取结果，不等于全局最小。应在补齐覆盖关系后运行一次有编号、可复现的 selection run，并把每个成员的保留理由和移除后缺失事实写入 `selection-members.csv`。

## B 项关闭情况

| 项目 | 结论 | 复核依据 |
|---|---|---|
| B-01 | 已关闭 | `OBJ-NVIDIA-GH100-DIE` 为 `die`；`OREL-NVIDIA-H100-SXM5-CONTAINS-GH100` 以 `physically_contains` 把 H100 SXM5 模组与 GH100 裸片关联。工艺、800 亿晶体管、814 mm² 三条事实都归 GH100 裸片。 |
| B-02 | 部分关闭，仍阻断 | 条件和派生公式已区分部分范围，但芯片算力仍复用 NCv3 精度路径，四个芯片稀疏冲突组混合范围与版本两个轴。 |
| B-04 | 基础外键链已关闭 | 223 条直接事实无一缺断言，231 条断言无一缺来源，19 个实际使用来源无一缺 endpoint。证据状态、最小集和卡片一致性属于更高层语义检查，仍有阻断。 |

## H-01 至 H-08

| 编号 | 状态 | 结果与剩余问题 |
|---|---|---|
| H-01 | 部分落实，应修 | 卡片已把 65,536×32 bit 正确换算为 262,144 byte，即 256 KiB/SM，并说明 33 MiB 只是算术总和、寄存器实际分布在各 SM。正式事实 `FACT-NVIDIA-H100-REG-CAPACITY-PER-SM` 也为 262,144 byte；但没有 `FIELD-MEM-POOLING-MODE=distributed_not_pooled` 的事实或 requirement，卡片和结构化层仍不等价。 |
| H-02 | 部分落实，应修 | 卡片把 FP16/BF16 非 Tensor 与 INT32 频率改为 `not_found`，对应条件的 `frequency_value`、`frequency_unit` 也为空；但 `COND-NVIDIA-H100-FP16-CUDA-DENSE`、`COND-NVIDIA-H100-BF16-CUDA-DENSE`、`COND-NVIDIA-H100-INT32-CUDA-DENSE` 的 fingerprint 仍以 `MHz` 结尾，也没有频率缺口 requirement/search 记录。 |
| H-03 | 已落实 | HBM、NVLink 和 PCIe 条件明确采用 `vendor_nameplate`；每方向、双向聚合、设备注入范围分别记录，没有把标称值改写成有效载荷或持续性能。 |
| H-04 | 已落实 | Tuning Guide 的正式 selected role 只有 `architecture_mechanism`，没有继续把调优建议写成硬件规格。 |
| H-05 | 部分落实，应修 | IEEE Micro 的两条覆盖关系已经落表。H100 产品页仍只在卡片中作为可用状态线索，没有正式来源、筛选和 endpoint；可用状态 requirement 仍为 pending。 |
| H-06 | 大体落实，应修 | H100 白皮书 v1.04、数据表和 Tuning Guide 均有本地固定 PDF 与哈希。`ASSERT-NVIDIA-H100-DSM-DETAIL-NVIDIA-HOPPER-TUNING-GUIDE-13-3` 的 notes 仍写 “fixed local copy remains pending”，与 `END-NVIDIA-HOPPER-TUNING-GUIDE-LOCAL` 冲突；H100 staging README 也保留了旧状态。 |
| H-07 | 部分落实，应修 | 卡片明确身份完整度为 partial、可用状态待核；正式 `card-completeness.csv` 目前只有 MLU590 的 9 行，没有 H100 完整度记录。 |
| H-08 | 已落实 | 两张卡均把派生比值称为规格机器平衡值/roofline ridge point，并明确它不是工作负载算术强度、利用率或实测性能。 |

## T-01 至 T-09

| 编号 | 状态 | 结果与剩余问题 |
|---|---|---|
| T-01 | 部分落实，应修 | 卡片保留 “second-generation Trainium” 与 “third-generation NeuronDevice/purpose-built chip” 的 `terminology_ambiguity`，没有强行消解；正式事实、断言和冲突组中没有代际术语记录。 |
| T-02 | 已落实 | 原始单位未被静默合并：芯片 96 GiB 归一化为 103,079,215,104 byte；`trn2.3xlarge` 的 96 GB 归一化为 96,000,000,000 byte；1536/6144 GiB 分别归一化为 1,649,267,441,664 / 6,597,069,766,656 byte。 |
| T-03 | 未落实，阻断 | 硬件能力和软件库能力已拆开，但集体通信和 Tensor 转置的实现层级在卡片与正式事实层不一致，见 A-02。 |
| T-04 | 部分落实，随 T-03 阻断 | 相关实现层级保留 `provisional` 是正确的；规范值不一致尚未解决。 |
| T-05 | 部分落实，应修 | UltraServer 状态和 EFA 均保留多值。`CG-AWS-TRN2-005-ULTRA-EFA` 用 `scope_disagreement` 合理；`CG-AWS-TRN2-004-ULTRA-STATUS` 统一标成 `version_change`，但 2026-08-12 同一动态页同时出现 available now 与 preview，不是单纯的历史版本变化。应把同日自相矛盾与 2024→2026 的版本变化分开。 |
| T-06 | 部分落实，阻断 | 当前值和 2024 历史值均有日期/版本条件；四个芯片稀疏冲突组混入 8 倍派生值，见 A-03。 |
| T-07 | 部分落实，应修 | 卡片把板卡 form factor 记 `not_applicable`，把芯片功耗、封装、冷却等分开记 `not_found`；正式 requirements 只有工艺、面积、晶体管、功耗和封装，缺少 form factor 与冷却两类记录。 |
| T-08 | 未落实，阻断 | selected 来源都有筛选行，但没有 selection run；Tuning Guide 无独有事实，S14 的角色与唯一事实不对应，见 A-04。 |
| T-09 | 部分落实，应修 | Trainium2 的 14 条 `not_found` requirement 均有 search-log 行，没有漏项；14 条日志却复用同一句 “AWS official domains and versioned Neuron docs, as recorded in card §10”，没有逐字段列明实际检索的来源 ID、页面或查询路径，可复现性不足。 |

## 关键链与口径抽查

### GH100 与 H100

- `FACT-NVIDIA-GH100-PROCESS`、`FACT-NVIDIA-GH100-TRANSISTORS`、`FACT-NVIDIA-GH100-DIE-AREA` 的目标均为 `OBJ-NVIDIA-GH100-DIE`，值分别为 TSMC 4N、80,000,000,000 count、814 mm²；断言来自 `SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04`，定位到 p.17 和/或第 39 至 40 页 Table 3，再落到首选入口 `END-NVIDIA-H100-ARCH-WP-V1-04-LOCAL`。没有把裸片事实下放到 H100 SXM5 模组。
- `FACT-NVIDIA-H100-HBM-CAPACITY` 为 80,000,000,000 byte，来源为白皮书；`FACT-NVIDIA-H100-HBM-BW-CURRENT` 为 3,350,000,000,000 byte/s，来源为 2024-09-24 数据表。后者的条件是 `direction_not_specified + per_endpoint + vendor_nameplate`，没有伪造读写方向。
- `FACT-NVIDIA-H100-NVLINK-RATE-PERDIR` 为每物理链路、每方向 200,000,000,000 bit/s；`FACT-NVIDIA-H100-NVLINK-RATE-BIDIR-DEVICE` 为设备双向聚合 900,000,000,000 byte/s。条件分别为 `per_direction_symmetric/per_physical_link` 与 `bidirectional_aggregate/per_device_injection`。数值、方向和聚合层级没有混用。

白皮书 Table 3 的视觉复核确认：1830 MHz 明确对应 FP8、FP16、BF16、TF32 Tensor Core 行，1980 MHz 明确对应 FP64 Tensor、FP32 与 FP64 非 Tensor 行；FP16/BF16 非 Tensor 和 INT32 没有被表格明确绑定到某个时钟行。当前卡片把这三项频率记为 `not_found` 是正确的。

### Trainium2 每核、芯片与容量单位

- `FACT-AWS-TRN2-CORE-FP8-DENSE-PUB` 为 158,000,000,000,000 FLOP/s，S02 Table 11，条件为 `per_component`、2.4 GHz；`FACT-AWS-TRN2-CHIP-FP8-DENSE-PUB` 为 1,299,000,000,000,000 FLOP/s，S01 Compute，条件为 `per_object`；`FACT-AWS-TRN2-CHIP-FP8-DENSE-DER8` 为 1,264,000,000,000,000 FLOP/s，来自每核值乘 8。三者的数值和条件没有被覆盖，但共同挂在 NCv3 精度路径上，因此语义分层仍不完整。
- 原始断言保留了单位：`ASSERT-FACT-AWS-TRN2-HBM-CAPACITY-S01` 为 96 GiB，`ASSERT-FACT-AWS-TRN2-3XL-MEM-CAP-S07` 为 96 GB，后者没有伪装成 96 GiB；S06 的 1536/6144 均保留 GiB。归一化 byte 值逐项复算正确。
- S01、S02、S06、S07 均有 2026-08-12 的本地 HTML 快照和 SHA-256，关键事实能沿 fact→assertion→source→preferred endpoint 回溯。
- 对 22 条派生事实按 derived-inputs.csv 逐条重算：7 条 H100 算力/带宽比、11 条 Trainium2 每核乘 8，以及 4 条 Trainium2 算力/带宽比均与存储值一致，错项为 0。

## 校验、哈希与运行记录

在当前全局正式库（H100 + Trainium2 + MLU590）上重新运行 `Validate-ResearchData.ps1`，结果为：`PASS: 32-table research data model; 38130 checks executed.`，注册表为 323 列、488 个枚举值。该结果证明结构和已实现的约束通过，不推翻本报告发现的语义阻断。

本地入口审计覆盖 23 个带 `local_path` 的 endpoint：23 个文件均存在，23 个 SHA-256 均与 `source-endpoints.csv` 一致；对应 23 个 `sources.content_fingerprint` 也全部匹配。关键首选入口包括：

| endpoint | SHA-256 |
|---|---|
| `END-NVIDIA-H100-ARCH-WP-V1-04-LOCAL` | `3641614979809a027a8aabdc2e77639efb8fcd0f8dc7873a22ba2125489f5a27` |
| `END-NVIDIA-H100-DATASHEET-LOCAL` | `17494a1792c15c55bae2453305e265ad508987b474e9235ecbc6f7c815399b98` |
| `END-AWS-TRN2-S01-SNAPSHOT` | `7d64744172d9510676906c3e098366e60ba9da9a6409f463d2ba4cc68e28dac2` |
| `END-AWS-TRN2-S02-SNAPSHOT` | `1fad493985a349aea5e3b54cca1ef50d416e993bba218801d63935335831618b` |
| `END-AWS-TRN2-S06-SNAPSHOT` | `7fb896ec667656d3ee2ce9641e595deef15094851505fcdc63413aa990dfcb00` |
| `END-AWS-TRN2-S07-SNAPSHOT` | `4c315ad5c342d10e1e0a6a8a5ab59b87be94e9fc19911f6ac122964317aa32cf` |

运行中有三项非数据错误：工作区依赖定位工具等待超过 60 秒后被终止，分类为本地工具/运行时卡顿，随后直接使用已安装 Poppler 完成 PDF 页面视觉核查；一次带 `Select-Object -First` 的只读检索因管道提前关闭返回非零码，分类为命令构造问题，改用先物化结果再筛选后成功；另一次把 statement-form `foreach` 直接接管道触发 PowerShell 解析错误，分类为操作者命令错误，按仓库的 PowerShell 规则先物化再格式化后成功。这三项均未改变文件，也没有降低审计结论的质量。本轮没有用户拒绝、自动审批拒绝、审批连接失败、沙箱拒绝或远端服务错误。

## 分级收口

阻断 M1 的是 A-01 至 A-04：证据状态错误、卡片与唯一事实层冲突、每核/芯片目标层级未分开、最小来源集没有正式证成。

在阻断清除后应一并修正 H-01、H-02、H-05、H-06、H-07，以及 T-01、T-05、T-07、T-09；这些问题不会让已录入数值立即失真，但会造成卡片和结构化表不等价、检索不可复现或状态记录过时。`card-completeness.csv` 目前只有 MLU590，H100 与 Trainium2 的九域完整度尚未落表；两张卡中记录的 35,089 项校验数也已被当前 38,130 项全局结果取代，后续统一更新即可。

可以留到 M1 之后的是未公开字段的继续检索、动态产品页的定期重抓取，以及尚未公开的物理实现细节。它们应保持 `not_found`、`pending_verification` 或相应未决状态，不需要为通过 M1 而用第三方估算补齐。

## 文件与文档检查

本任务只新增/更新 `审计/子代理交接/m1_postmerge_audit.md`。已检查 README 与 AGENTS；由于子任务边界明确禁止修改全局文档，本代理没有更新它们。正式库合并后的对象数、关系数、校验数和 M1 状态应由总控在接收本交接、完成修复后统一同步。

## 总控关闭记录

主代理在接收本复核后完成了四组修正，M1 已据此通过。A-01 重算 26 条事实的 `evidence_state`，并在校验器加入来源基数约束。A-02 将 Trainium2 卡片与正式事实统一为 Tensor 转置 `dedicated_instruction`、集体通信硬件 `dedicated_physical_module`，两者继续保留 `provisional`。A-03 新增 Trainium2 芯片聚合 Tensor 组件和五条芯片级精度路径，四个稀疏组拆成版本变化与范围争议。A-04 建立 `SELRUN-M1-PILOTS-20260812`，19 个入选来源都有成员理由；Tuning Guide 在当前事实集合内改为 `redundant_covered`，固定 PDF 不删除。H/T 应修项同时补入 H100 频率缺口、寄存器分布事实、两卡九域完整度，并更新过时状态说明。

修正后的全局校验为 `PASS: 32-table research data model; 39519 checks executed.`。完整验收见 `审计/M1_试填合并验收.md`。本节不改变上文独立审查当时的发现，只记录这些发现之后的处理结果。