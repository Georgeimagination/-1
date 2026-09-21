# M2-W2-TRN2-INSTANCE 独立复核

- 复核日期：2026-08-13
- 被复核包：`审计/子代理交接/m2_staging/M2-W2-TRN2-INSTANCE/`
- 最终裁决：`reject`
- 写入边界：本报告是本次复核的唯一写入文件；staging、正式 32 表、正式资料卡、README、AGENTS、研究计划和进度文件均未修改

## 结论

本包不能按现状合并。结构层面可以通过官方校验器，但源文复核发现 7 条包内 S10 历史稀疏事实没有直接证据；正式库同一批 M1 数据另有 3 条芯片级同类污染。`trn2.3xlarge` 的芯片数事实本身正确，唯一断言却挂错到不含该 SKU 的 S06。Elastic Fabric Adapter（EFA，弹性网络适配器）的五条正式事实又把实例或系统网络带宽写成“单链路速率”。这些问题直接涉及事实、来源和字段语义，不能靠文字润色解决。

机械闭包计数仍可复现：原始命中 49 条，排除 UltraServer 组成事实后为 48 条，分布 `4 / 23 / 21`；字段要求由 52 条排除 `REQ-AWS-TRN2-0092` 后为 51 条，分布 `5 / 24 / 22`。但删除 7 条包内无证据事实后，合理的实例事实基线应先变为 41 条，分布 `4 / 20 / 17`；对应字段要求变为 44 条，分布 `5 / 21 / 18`。因此不能继续把 `48 / 51` 当作待验收的规范数量。

## 阻断一：S10 的 FP8 表述被扩写到其他格式和后来的 SKU

S10 固定快照第 451 行只支持单颗 Trainium2 芯片的 FP8：1.3 PFLOPS dense、5.2 PFLOPS sparse。第 452 行只写 2024 年发布时 “Each Trn2 instance” 有 16 颗芯片、20.8 PFLOPS dense FP8 和 83.2 PFLOPS sparse FP8。该句可对应当时发布的 `trn2.48xlarge`，没有直接命名后来单独建模的 `trn2u.48xlarge`，也没有把 83.2 PFLOPS 扩写为 BF16、FP16 或 TF32。

S10 当前共有 12 条正式断言。保守可留的只有两条：

- `FACT-AWS-TRN2-CHIP-FP8-SPARSE-HIST2024`
- `FACT-AWS-TRN2-48XL-FP8-SPARSE-HIST2024`

其余 10 条需要进入正式修复审计。其中 7 条在本包闭包内：

| 无证据事实 | 正式断言 | 随事实删除的要求 | 受影响冲突组 |
|---|---|---|---|
| `FACT-AWS-TRN2-48XL-BF16-SPARSE-HIST2024` | `ASSERT-FACT-AWS-TRN2-48XL-BF16-SPARSE-HIST2024-S10` | `REQ-AWS-TRN2-0148` | `CG-AWS-TRN2-003-48XL-BF16` |
| `FACT-AWS-TRN2-48XL-FP16-SPARSE-HIST2024` | `ASSERT-FACT-AWS-TRN2-48XL-FP16-SPARSE-HIST2024-S10` | `REQ-AWS-TRN2-0149` | `CG-AWS-TRN2-003-48XL-FP16` |
| `FACT-AWS-TRN2-48XL-TF32-SPARSE-HIST2024` | `ASSERT-FACT-AWS-TRN2-48XL-TF32-SPARSE-HIST2024-S10` | `REQ-AWS-TRN2-0150` | `CG-AWS-TRN2-003-48XL-TF32` |
| `FACT-AWS-TRN2-TRN2U-48XL-FP8-SPARSE-HIST2024` | `ASSERT-FACT-AWS-TRN2-TRN2U-48XL-FP8-SPARSE-HIST2024-S10` | `REQ-AWS-TRN2-0160` | `CG-AWS-TRN2-003-TRN2U-48XL-FP8` |
| `FACT-AWS-TRN2-TRN2U-48XL-BF16-SPARSE-HIST2024` | `ASSERT-FACT-AWS-TRN2-TRN2U-48XL-BF16-SPARSE-HIST2024-S10` | `REQ-AWS-TRN2-0161` | `CG-AWS-TRN2-003-TRN2U-48XL-BF16` |
| `FACT-AWS-TRN2-TRN2U-48XL-FP16-SPARSE-HIST2024` | `ASSERT-FACT-AWS-TRN2-TRN2U-48XL-FP16-SPARSE-HIST2024-S10` | `REQ-AWS-TRN2-0162` | `CG-AWS-TRN2-003-TRN2U-48XL-FP16` |
| `FACT-AWS-TRN2-TRN2U-48XL-TF32-SPARSE-HIST2024` | `ASSERT-FACT-AWS-TRN2-TRN2U-48XL-TF32-SPARSE-HIST2024-S10` | `REQ-AWS-TRN2-0163` | `CG-AWS-TRN2-003-TRN2U-48XL-TF32` |

删除这些历史成员后，当前 41 PFLOPS 事实不再有相应历史冲突。三条 `trn2.48xlarge` 当前要求 `REQ-AWS-TRN2-0144` 至 `0146`，以及四条 `trn2u.48xlarge` 当前要求 `REQ-AWS-TRN2-0156` 至 `0159`，需要从 `conflicting_unresolved` 改回与唯一可靠当前值相符的状态；对应当前事实、冲突组和冲突成员也要同步收口。`trn2.48xlarge` 的 FP8 当前值与 2024 年 FP8 历史值仍有证据，相关冲突可以保留。

另外 3 条位于本包之外，但已经污染正式 M1 芯片数据：

| 包外无证据事实 | 正式断言 | 随事实删除的要求 | 受影响冲突组 |
|---|---|---|---|
| `FACT-AWS-TRN2-CHIP-BF16-SPARSE-HIST2024` | `ASSERT-FACT-AWS-TRN2-CHIP-BF16-SPARSE-HIST2024-S10` | `REQ-AWS-TRN2-0056` | `CG-AWS-TRN2-003-CHIP-BF16` |
| `FACT-AWS-TRN2-CHIP-FP16-SPARSE-HIST2024` | `ASSERT-FACT-AWS-TRN2-CHIP-FP16-SPARSE-HIST2024-S10` | `REQ-AWS-TRN2-0060` | `CG-AWS-TRN2-003-CHIP-FP16` |
| `FACT-AWS-TRN2-CHIP-TF32-SPARSE-HIST2024` | `ASSERT-FACT-AWS-TRN2-CHIP-TF32-SPARSE-HIST2024-S10` | `REQ-AWS-TRN2-0064` | `CG-AWS-TRN2-003-CHIP-TF32` |

芯片当前直报值还可能与每核乘 8 的派生值存在范围争议，所以修复这三条历史污染时，不能顺手把芯片级其他冲突全部判为已解决；只移除 S10 不支持的历史成员和相应版本冲突链。

## 阻断二：`trn2.3xlarge` 芯片数挂错来源

S06 固定页全文对 `trn2.3xlarge` 和 `3xlarge` 的命中数都是 0。它明确只介绍 `trn2.48xlarge`、`trn2u.48xlarge` 和 UltraServer，因此不能支持 `FACT-AWS-TRN2-3XL-CHIP-QTY = 1`。S07 的 Product details 表才明确列出 `Trn2.3xlarge` 的 Trainium2 chips 为 1。

应删除 `ASSERT-FACT-AWS-TRN2-3XL-CHIP-QTY-S06`，改建指向 S07 的断言，并同步修改 3XL 卡、`card-fact-map.csv`、screening、selected role 和 selection member 的说明。完成本项并删除阻断一的 7 条包内事实后，41 条映射的来源分布应为：`S06=32、S07=5、S09=1、S10=1、S15=2`。

## 阻断三：EFA 的字段写成了单链路速率

字段字典把 `FIELD-INT-PER-LINK-RATE` 定义为“单链路速率”。S07 的表头却是按 instance size 给出的 `Network bandwidth (Tbps)`；条件行也写着 `measurement_scope=per_instance`、备注为“实例级聚合带宽”。源文没有提供物理链路数量，也没有说 0.2 或 3.2 Tbps 是单条链路速率。

本包内受影响的是：

- `FACT-AWS-TRN2-3XL-EFA-RATE` / `REQ-AWS-TRN2-0107`
- `FACT-AWS-TRN2-48XL-EFA-RATE` / `REQ-AWS-TRN2-0108`
- `FACT-AWS-TRN2-TRN2U-48XL-EFA-RATE` / `REQ-AWS-TRN2-0109`

正式库中还有两条包外系统事实使用了同一错误字段：

- `FACT-AWS-TRN2-ULTRA64-EFA-3P2` / `REQ-AWS-TRN2-0110`
- `FACT-AWS-TRN2-ULTRA64-EFA-12P8` / `REQ-AWS-TRN2-0111`

0.2、3.2 和 12.8 Tbps 规范化为 bit/s 的算术没有错，错的是把实例或系统聚合口径命名为 per-link。修复时应改用每设备注入或聚合带宽字段，并按该字段的 canonical unit 转换；如果现有字段无法同时保留 bit/s 与聚合作用域，应先补字段，不能借“link 对象”把聚合值解释成单物理链路。

## S07 版本与 endpoint 裁决

2026-08-12 和 2026-08-13 两份 S07 HTML 都是 487,377 bytes、3,241 行。前者 SHA-256 为 `4c315ad5c342d10e1e0a6a8a5ab59b87be94e9fc19911f6ac122964317aa32cf`，后者为 `94ceea74234b30d6568127badd6a4df68a46b861d1d989c21463fea3b0690edb`。逐行比较只有两处一次性随机值变化；按 staging 的两条规则归一化后，全文逐字相同，归一化 SHA-256 均为 `3070baef5d94db45396bd210d4f16f1bf8f8aa1b2586d1215530f82e2acf473e`。两份快照语义等价，没有产品正文变化。

按研究计划第 332 行，只有实质内容变化才新建 source version。因此继续使用 `SRC-AWS-TRN2-S07`，保留 `observed-2026-08-12` 和既有 `content_fingerprint`，不为随机值新建来源版本，是正确的。旧 fingerprint 与新首选 endpoint 的原始 SHA-256 不同也可以接受：前者继续锚定既有语义版本，后者记录实际抓取载体；但 source notes 必须写明两份原始哈希和归一化等价结果。

`no_source_row_change` 不能接受。动态页已经在 2026-08-13 重新核查，`last_verified_date` 应更新为 2026-08-13，并补充上述 notes；`version_label` 和 `content_fingerprint` 保持不变。旧 endpoint 以既有主键把 `is_preferred_endpoint` 改为 `false`，新 endpoint 用新主键追加并设为 `true`，两种动作本身安全，且旧行除首选标志外没有其他列漂移。

新 endpoint 当前把 `local_path` 指向 staging 的 `fixed-candidates/`。正式合并前应把文件复制到 `最小参考资料库/快照/AWS/Trainium2/2026-08-13/`，复核 SHA-256 后再登记正式路径。不能让正式来源入口长期依赖待验收的 staging 目录。

## 来源最小集与 S15

5 条 screening 的方向正确：S06、S07、S09、S10 入选，S15 保持 `rejected_unreliable`。S15 固定页确实写有 512 GiB 和 8,192 GiB，这两个原始单元应保留质量审计链；它们不能覆盖 96 GB 和 1,536 GiB 的产品专页或架构页值，也不能进入正向最小来源集。

当前四成员 selection run 仍不成立。运行说明声称覆盖 48 条事实和 48 条断言，但 S15 的两条事实各只有 S15 断言，`source-coverage.csv` 又明确标为 `not_equivalent`。所以四个入选成员不可能覆盖其自称的全部范围。修复阻断一、二后，建议把运行范围明确写成 39 条可采纳事实：S06 32 条、S07 5 条、S09 1 条、S10 1 条；两条 S15 声明另列为 rejected audit claims，不算入最小集覆盖分母。若仍坚持以全部 41 条映射事实为范围，就不能声称四成员覆盖全部事实。

在修复后的 39 条可采纳事实集合上，S06、S07、S09、S10 仍各有不可替代贡献，四成员大概率仍是最小集；但必须重新运行，不能沿用当前计数和理由。S10 的不可替代理由只能剩下一条 `trn2.48xlarge` FP8 历史事实。

S15 还暴露了一处状态文字不一致：正式冲突组仍是 `unreviewed` 且没有 `preferred_fact_id`，卡片却称 96 GB 和 1,536 GiB 为“正向采用值”，同时把 S15 称为错误来源。要么正式完成 `source_error_suspected` 的裁决并登记优选事实，要么删掉卡片的“采用”措辞；不能让卡片先于规范事实层裁决。GB 与 GiB 的换算本身正确：96 GB 按十进制为 96,000,000,000 byte，512 GiB 为 549,755,813,888 byte，1,536 GiB 为 1,649,267,441,664 byte，8,192 GiB 为 8,796,093,022,208 byte，没有静默混用单位。

## 三张卡与 27 条完整度

现有 `card-fact-map.csv` 有 48 行、48 个唯一 `fact_id`，机械上双向闭合；每个事实恰有一条正式断言。三张卡没有把 Trainium2 芯片、架构或 UltraServer 系统事实复制成实例事实，`facts.csv`、`fact-assertions.csv`、`field-requirements.csv` 和 `object-relations.csv` 的 staging 片段也都保持空表。卡中出现的两个架构软件 fact_id 是关系引用，`trn2u` 卡出现的 UltraServer 数量 fact_id 是明确的包外说明，不属于复制。

阻断一修复后，映射必须从 48 行重建为 41 行，分布 `4 / 20 / 17`。此外，3XL 卡的三个 `card_section` 定位已经错位：内存事实写成 §5，实际在 §4；EFA 写成 §8，实际在 §7；S15 冲突写成 §10，实际在 §9。开头“正式对象和六条必要关系已经存在”也不符合该对象实际引用链，应改成明确的关系 ID 或去掉数量。

九域完整度共有 27 行，三个对象各九域且无重复。物理实现和特殊能力使用 `not_applicable`，以及其余 `partial`，大体符合实例卡不复制芯片或架构事实的边界。`OBJ-AWS-TRN2-48XLARGE / evidence = complete` 不能保留：当前存在挂错来源、无源文事实和待修的 S07 source 行，至少应在修复完成前改为 `needs_review` 或 `partial`。全部 27 行应在事实集合重建后再评一次。

## 数值和状态抽查

除上述历史扩写、EFA 字段和来源归属外，卡片列出的当前值与固定一手来源一致：

| 对象 | 可保留的当前规格 |
|---|---|
| `trn2.3xlarge` | 1 颗 Trainium2（来源应为 S07）；96 GB；0.2 Tbps 的实例网络原值 |
| `trn2.48xlarge` | 16 颗；20.8 FP8 dense、10.7 BF16/FP16/TF32 dense、2.9 FP32、41 FP8/FP16/BF16/TF32 sparse PFLOPS；1,536 GiB；46.4 TB/s；1,024 GB/s/chip；4×4 torus、16 节点；3.2 Tbps；2024-12-03 available |
| `trn2u.48xlarge` | 16 颗；与 S06 同表的当前实例峰值、1,536 GiB、46.4 TB/s、1,024 GB/s/chip、4×4 torus、16 节点；S07 的 3.2 Tbps；首次固定可用日期继续 `pending_verification` |

46.4 TB/s 按十进制规范化为 46,400,000,000,000 byte/s 正确。原文没有说明读写方向；正式条件保留 `direction_not_specified`，卡片也没有把它改写成单向持续带宽，因此内存带宽口径可以保留。`trn2.48xlarge` 的 83.2 PFLOPS 历史值只对 FP8 保留；`trn2u.48xlarge` 不保留任何 S10 历史峰值。

## 独立结构检查、临时合并与正式库保护

独立结构检查执行 216 项，错误为 0，覆盖 32 张 staging CSV 与正式表头、非空表计数、主键唯一性、48 行旧映射的外键和断言基数、27 条完整度，以及 S07 新旧文件大小和哈希。这说明 staging 形式完整，不推翻前面的源文语义阻断。

按当前 merge plan 构造临时正式副本后，合并了 27 条完整度、5 条 screening、4 条来源角色、1 个 selection run、4 个 selection member、1 条 coverage，以及 1 个旧 endpoint 更新和 1 个新 endpoint 追加。官方校验结果为：

```text
PASS: 32-table research data model; 92392 checks executed.
Registry: 323 columns, 488 enum values.
```

staging 自报的 92,374 项无法在当前文件集和 merge plan 上复现，应更新校验记录。官方 validator 只证明结构、引用和已编码规则通过，不会发现 S10 把 FP8 扩写到其他格式、S06 不含 3XL，或 EFA 聚合值挂到 per-link 字段。

临时目录最终已删除。正式库在复核前后均为：

```text
PASS: 32-table research data model; 91827 checks executed.
Registry: 323 columns, 488 enum values.
```

下列七个正式关键文件与 staging 记录的基线 SHA-256 全部一致，差异数为 0：

| 正式文件 | 行数 | SHA-256 |
|---|---:|---|
| `数据/objects.csv` | 75 | `13A001E67F8BA83D5A236A75F51AAB5454E690174BF421A3E663786180334BEC` |
| `数据/object-relations.csv` | 24 | `6102A347F1A7575BBB9DB23701F93DE85D0DFD1CC32D729A0A2F7E2FF257B116` |
| `数据/facts.csv` | 614 | `634ABA9D93229219DDD4DA9952612E97841C1937C9D032B45FA4C3FF42F3DEA2` |
| `数据/field-requirements.csv` | 786 | `429DD029364820A8F5E428F62EDAF4C80AE692230AF13A7B7090EB1B32A4BC19` |
| `最小参考资料库/fact-assertions.csv` | 600 | `173BB2406374C25767AAFF6404BC2E9854E5EF133A154668AB167E9BE367C0BF` |
| `最小参考资料库/sources.csv` | 81 | `3FFF1FBFA2A880525432FF414CFB5CCEB2DB8BAA474D43A4BE97ADA767580C22` |
| `最小参考资料库/source-endpoints.csv` | 116 | `8DE1EE64763E2F2C7E24C995E776D343033D782F3C0458C1E4BE2B3515DF8D1A` |

## 重新送审的最低条件

重新送审前，需要先清除 10 条 S10 正式污染并收口对应要求和冲突；把 3XL 芯片数断言改挂 S07；修正五条 EFA 事实的字段语义；更新 S07 的 `last_verified_date`、notes 和正式快照路径；按 41 条映射事实与 39 条可采纳事实重建卡片、完整度和 selection run。修复后再跑同一套结构检查、临时正式合并和官方 validator。以上任一项未完成，都不能把本裁决降为 `accept_with_fixes`。

## 运行异常与文件检查

复核中有两次预读路径写错和一次把 statement-form `foreach` 直接接管道的 PowerShell 解析错误，均属于操作者命令构造错误；改用正确路径和先物化结果后完成。一次对大型 S10 HTML 的宽泛 `Select-String` 超时，属于本地命令超时，改用 `rg` 后取得第 451 至 453 行。清理临时目录时，PowerShell `Remove-Item` 对已核实的 junction 抛出 `NullReferenceException`，属于本地工具/运行时故障；随后逐一复核 junction 类型和目标，用 .NET 目录 API 只删除链接，再确认无 reparse point 后删除临时根目录。没有用户拒绝、自动审批拒绝、审批连接失败、沙箱拒绝或远端服务错误。

本次只写入 `审计/子代理交接/m2_review_trn2_instance.md`。README 与 AGENTS 已只读检查；任务边界禁止修改全局文档，而且本报告尚未被主代理验收合并，因此无需更新。