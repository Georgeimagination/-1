# 正式库四表复核生命周期独立裁决

复核日期：2026-08-13  
裁决：`accept_with_fixes`  
写入范围：仅本报告；正式四表未修改。

## 裁决

`data_review_lifecycle_audit.md` 的数量复算正确，状态分层也正确，但当前证据不足以直接执行 1,924 行晋级。四个包的最终 `accept` 可以证明整包达到合并门，却不能单独证明迁移清单中的每个主键都完成了行级生命周期复核。尤其是 598 条候选断言的 `reviewer` 全为空；包级报告虽覆盖事实链、定位、最小集和正式校验，四份报告对四张目标表的逐行覆盖深度并不完全相同。

因此，本裁决接受候选集合、迁移方向和不动项，暂不授权正式写入。修复要求是先生成带主键的 1,924 行迁移清单，再由独立复核者按批次和表签字确认清单覆盖。这里不要求把 598 条断言都改成 `independently_reviewed`。只有将 `extraction_status` 从 `source_checked` 晋级为 `independently_reviewed` 时，才必须逐行保存第二读者、复核日期和来源回读结果。

## 数量复算

按三份 M2 staging 主键集合划分 GHC、GA、NA，其余正式行归 M1。复算结果与拟迁移方案一致：

| 批次 | 断言 | 事实 | 字段要求 | 来源筛选 | 合计 |
|---|---:|---:|---:|---:|---:|
| M1 | 237 | 195 | 193 | 21 | 646 |
| GHC | 35 | 35 | 79 | 9 | 158 |
| GA | 141 | 141 | 72 | 25 | 379 |
| NA | 185 | 183 | 354 | 19 | 741 |
| 合计 | 598 | 554 | 698 | 74 | 1,924 |

正式四表的批次总量也复算一致：M1 为 253/239/265/26，GHC 为 35/35/80/11，GA 为 141/141/72/25，NA 为 185/185/369/19；顺序均为事实、断言、字段要求、来源筛选。

候选状态组合没有算错：

- 598 条断言均为 `source_checked / draft`。
- 554 条事实由 5 条 `accepted / draft`、547 条 `provisional / draft` 和 2 条 `superseded / draft` 组成；其中 541 条为直接事实、13 条为派生事实。541 条直接事实均能连到本批可晋级或已经复核的断言。
- 698 条字段要求由 315 条 `value_available`、221 条 `not_found`、151 条 `not_applicable` 和 11 条 `inaccessible_evidence` 组成。
- 74 条来源筛选由 60 条 `selected`、9 条 `redundant_covered`、3 条 `out_of_scope`、1 条 `rejected_unreliable` 和 1 条 `lead_only` 组成。

当前正式校验器新鲜实跑通过：`PASS: 32-table research data model; 91190 checks executed.`，注册表为 323 列、488 个枚举值。该结果确认当前结构合法，不构成 1,924 个行级复核动作已经发生的证据。

## 包级验收能承接到哪里

四份正式验收和对应独立复核都给出最终 `accept`，足以作为迁移清单的包级来源。GHC 报告明确全量核过 35 条事实、35 条断言和 80 条字段要求；GA、NA 报告明确核过事实、断言、卡片闭环与最小来源选择；M1 则经过独立复核、修复和总控关闭。它们共同支持“可以准备生命周期迁移”，也支持保留现有业务状态列。

现有报告没有统一列出本次 1,924 个主键，也没有统一声明四张表的每一行都完成了同一含义的行级复核。包级 `accept` 因而不能直接替代迁移清单签字。安全做法是把已有包级复核复用为证据，由独立复核者检查显式清单的成员、状态组合、排除项和证据链；无需重新做一遍架构抽取，也无需为 `review_status` 晋级逐条重读全部来源原文。

## 必须保持不动的状态

本次只能改清单内 1,924 行的 `review_status`，且只能做 `draft → reviewed`。下列记录不得进入迁移：

- 58 条 `facts.review_status=needs_resolution`，包括 45 条 `conflict_member` 和 13 条 `provisional`；2 条已经 `reviewed` 的事实也不重复修改。
- 71 条 `field-requirements.review_status=needs_resolution`；14 条 `draft / pending_verification`；3 条已经 `reviewed` 的字段要求。
- 4 条 `source-screening.review_status=needs_resolution`，即 2 条 `pending` 和 2 条 `inaccessible`；3 条已经 `reviewed` 的筛选记录。
- 2 条已经 `reviewed` 的断言。

`facts.resolution_state`、`fact-assertions.extraction_status`、`field-requirements.requirement_status` 和 `source-screening.screening_status` 必须零变化。不得把 599 条 `source_checked` 断言批量改成 `independently_reviewed`，不得把 `provisional` 改成 `accepted`，也不得把任何行提高为 `approved`。

## 安全迁移门

总控只有在以下条件全部满足后才能执行迁移：

1. 固定四张正式表的 SHA-256，并生成 1,924 行只含表名、主键、批次、旧 `review_status`、新 `review_status`、包级复核文件和独立签字的清单。清单按本报告的 646/158/379/741 与 598/554/698/74 双向复算。
2. 独立复核者确认四个批次在四张表中的成员边界。对包级报告没有明确声称全表逐行覆盖的部分，复核者至少检查每个主键的状态组合和所需证据链；发现语义疑点的行从清单移出并保持 `draft` 或改走 `needs_resolution` 裁决，不得为了凑数放行。
3. 先迁移 598 条断言，再迁移 554 条事实，随后处理 698 条字段要求和 74 条来源筛选。每一步只改 `review_status`，每一步都保存差异并运行正式校验器。
4. 完成后四表行数和主键集合必须不变，差异恰好为 1,924 个 `draft → reviewed`。四个业务状态列、事实值、来源定位、单位、条件、筛选理由和其他字段必须零变化；按 M1/GHC/GA/NA 复算仍应得到本报告表格。
5. 任一步出现清单外变化、计数不符、关系链缺失或 validator 非零退出，整次迁移停止并从备份恢复。修正语义内容应另开工作包，不能混入生命周期迁移。

替代策略是“显式清单加独立签字”，不要求再做 1,924 次完整来源抽取。它保留包级验收的已有价值，又使 `review_status=reviewed` 能回到具体主键和复核责任。完成这项修复后，本方案可以转为 `accept`。

## 文档与运行检查

根 `README.md` 与 `AGENTS.md` 已按只读方式检查。本次没有改变正式数据、项目状态、目录或规则，无需修改两份文件。

复核中有两次只读命令构造错误：一次文件名筛选因查询条件未匹配而返回退出码 1；一次哈希汇总把 statement-form `foreach` 直接接到管道，触发 PowerShell 解析错误。两项都属于操作者的命令构造问题，与用户拒绝、审批失败、沙箱拒绝或运行时能力限制无关；改为先物化结果后均成功，正式文件未受影响。`report-humanizer` 机器扫描已通过；随后按 `shuorenhua` 的文档场景做最小回读，复核了标题、首段、表格引导、转场和结尾。所有数量、状态、文件名、命令及责任归属均保持不变。