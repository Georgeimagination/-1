# 正式库四表复核生命周期审计

任务状态：`ready_for_parent_review`  
审计日期：2026-08-13  
审计范围：`数据/facts.csv`、`最小参考资料库/fact-assertions.csv`、`数据/field-requirements.csv`、`最小参考资料库/source-screening.csv`。本次只审计状态，不修改正式表。

## 结论

M1、M2-GHC-ARCH、M2-GA-ARCH 和 M2-NA-ARCH 都已经通过包级验收，但“包已接收”和“每一行已经完成生命周期晋级”不是一回事。包级 `accept` 证明该批数据可合并、结构闭合、来源链和卡片对应关系通过独立复核；它不会自动把暂定事实变成最终事实，也不会消除冲突、待核要求或不可访问来源。

四表目前共有 1,924 行满足保守的行级晋级条件：598 条断言、554 条事实、698 条字段要求和 74 条来源筛选记录。这些行只应把 `review_status` 从 `draft` 改为 `reviewed`。不得顺带把事实的 `resolution_state=provisional` 改成 `accepted`，也不得把断言的 `extraction_status=source_checked` 批量改成 `independently_reviewed`。

仍须保持原状态的核心记录包括：58 条 `facts.review_status=needs_resolution`、71 条 `field-requirements.review_status=needs_resolution`、14 条仍为 `draft / pending_verification` 的字段要求，以及 4 条 `source-screening.review_status=needs_resolution`。这些记录正是在保存真实的不确定性，不能为了让表面状态整齐而晋级。

## 口径

三份 M2 工作包按各自 staging 结构化表中的主键确定成员；正式四表中不属于这三包的行归入 M1。统计结果与四份验收记录吻合：M1 有 253 条事实、239 条断言、265 条字段要求和 26 条来源筛选记录；GHC 为 35、35、80、11；GA 为 141、141、72、25；NA 为 185、185、369、19。

本审计依据的包级裁决是：`审计/M1_试填合并验收.md`、`审计/M2_GHC_架构包正式合并验收.md`、`审计/M2_GA_架构包正式合并验收.md`、`审计/M2_NA_架构包正式合并验收.md`，并以三份 M2 独立复核报告和当前校验器的状态约束解释行级含义。

## 四种状态不要混为一谈

`review_status` 记录的是一行数据走到哪一步：`draft` 表示尚未完成正式复核，`reviewed` 表示该行已按当前证据和口径检查，`needs_resolution` 表示仍有必须保留的争议或缺口，`approved` 留给更高一级的治理确认。四表目前没有 `approved` 行。

`facts.resolution_state` 回答的是规范事实本身是否已经定案。它与 `review_status` 正交：一条 `provisional` 事实可以在保留限定条件的前提下成为 `reviewed`；一条 `superseded` 事实也可以作为已核对的历史记录成为 `reviewed`。相反，`conflict_member` 即使原文抽取无误，冲突没有解决时仍应保持 `needs_resolution`。因此，`reviewed / provisional` 是合法组合，不等于“把暂定值批准为最终值”。

断言表也有两条轴。`extraction_status=source_checked` 表示已经回看来源；`independently_reviewed` 还要求逐行的第二读者复核。包级独立验收足以支持把通过检查的断言行标为 `reviewed`，但不能凭一次批次签字推定 599 条 `source_checked` 断言都完成了逐行二次摘录复核。

字段要求和来源筛选同样把“结论是什么”与“这行是否复核”分开。`not_found`、`not_applicable`、`inaccessible_evidence` 或 `redundant_covered` 都可以是经过复核的结论；`pending_verification`、`conflicting_unresolved` 和筛选 `pending` 则表示工作仍未闭合。

## 当前状态组合

### facts

| 批次 | `resolution_state / review_status` | 行数 |
|---|---|---:|
| M1 | `accepted / draft` | 5 |
| M1 | `accepted / reviewed` | 2 |
| M1 | `conflict_member / needs_resolution` | 45 |
| M1 | `provisional / draft` | 188 |
| M1 | `provisional / needs_resolution` | 11 |
| M1 | `superseded / draft` | 2 |
| GHC | `provisional / draft` | 35 |
| GA | `provisional / draft` | 141 |
| NA | `provisional / draft` | 183 |
| NA | `provisional / needs_resolution` | 2 |

合计 614 条。当前有 554 条 `draft`、58 条 `needs_resolution` 和 2 条 `reviewed`。

### fact-assertions

| 批次 | `extraction_status / review_status` | 行数 |
|---|---|---:|
| M1 | `source_checked / draft` | 237 |
| M1 | `source_checked / reviewed` | 1 |
| M1 | `independently_reviewed / reviewed` | 1 |
| GHC | `source_checked / draft` | 35 |
| GA | `source_checked / draft` | 141 |
| NA | `source_checked / draft` | 185 |

合计 600 条。598 条仍为 `draft`；599 条的摘录状态是 `source_checked`，只有 1 条是 `independently_reviewed`。

### field-requirements

| 批次 | `requirement_status / review_status` | 行数 |
|---|---|---:|
| M1 | `conflicting_unresolved / needs_resolution` | 55 |
| M1 | `inaccessible_evidence / draft` | 9 |
| M1 | `not_applicable / draft` | 2 |
| M1 | `not_found / draft` | 50 |
| M1 | `not_found / reviewed` | 3 |
| M1 | `pending_verification / draft` | 13 |
| M1 | `pending_verification / needs_resolution` | 1 |
| M1 | `value_available / draft` | 132 |
| GHC | `inaccessible_evidence / draft` | 2 |
| GHC | `not_applicable / draft` | 37 |
| GHC | `not_found / draft` | 40 |
| GHC | `pending_verification / draft` | 1 |
| GA | `not_applicable / draft` | 56 |
| GA | `not_found / draft` | 16 |
| NA | `not_applicable / draft` | 56 |
| NA | `not_found / draft` | 115 |
| NA | `not_found / needs_resolution` | 3 |
| NA | `pending_verification / needs_resolution` | 10 |
| NA | `value_available / draft` | 183 |
| NA | `value_available / needs_resolution` | 2 |

合计 786 条。712 条为 `draft`，71 条为 `needs_resolution`，3 条为 `reviewed`。

### source-screening

| 批次 | `screening_status / review_status` | 行数 |
|---|---|---:|
| M1 | `selected / draft` | 17 |
| M1 | `selected / reviewed` | 2 |
| M1 | `redundant_covered / draft` | 1 |
| M1 | `redundant_covered / reviewed` | 1 |
| M1 | `out_of_scope / draft` | 2 |
| M1 | `rejected_unreliable / draft` | 1 |
| M1 | `pending / needs_resolution` | 2 |
| GHC | `selected / draft` | 7 |
| GHC | `redundant_covered / draft` | 1 |
| GHC | `lead_only / draft` | 1 |
| GHC | `inaccessible / needs_resolution` | 2 |
| GA | `selected / draft` | 19 |
| GA | `redundant_covered / draft` | 6 |
| NA | `selected / draft` | 17 |
| NA | `redundant_covered / draft` | 1 |
| NA | `out_of_scope / draft` | 1 |

合计 81 条。74 条为 `draft`，4 条为 `needs_resolution`，3 条为 `reviewed`。

## 可执行的晋级规则

迁移必须使用四个已验收批次的主键白名单，不能只按状态做全表替换。建议按以下顺序执行，每一步完成后都运行正式校验器。

第一步处理断言。对白名单内 `review_status=draft` 且 `extraction_status=source_checked` 的 598 行，把 `review_status` 改为 `reviewed`。`extraction_status` 保持 `source_checked`；只有逐行保存第二读者和复核日期后，才允许改为 `independently_reviewed`。

第二步处理事实。对白名单内 `review_status=draft` 且 `resolution_state` 属于 `accepted`、`provisional` 或 `superseded` 的 554 行，把 `review_status` 改为 `reviewed`。其中直接事实必须先能连到第一步已经复核的断言；派生事实必须继续满足公式、作用域、精度和方向检查。`resolution_state` 一律不改。

第三步处理字段要求。只晋级 698 条已经形成闭合结论的草稿行：315 条 `value_available`、221 条 `not_found`、151 条 `not_applicable` 和 11 条 `inaccessible_evidence`。执行时还要分别核对支持事实、已完成检索与 `no_reliable_result`、非空不适用理由，以及不可访问证据链。14 条 `draft / pending_verification` 不晋级；全部 71 条 `needs_resolution` 也不动。

第四步处理来源筛选。把 74 条终局筛选决定从 `draft` 改为 `reviewed`，包括 60 条 `selected`、9 条 `redundant_covered`、3 条 `out_of_scope`、1 条 `rejected_unreliable` 和 1 条 `lead_only`。2 条 `pending` 和 2 条 `inaccessible` 继续保持 `needs_resolution`。

### 迁移数量

| 批次 | 断言 | 事实 | 字段要求 | 来源筛选 | 合计 |
|---|---:|---:|---:|---:|---:|
| M1 | 237 | 195 | 193 | 21 | 646 |
| GHC | 35 | 35 | 79 | 9 | 158 |
| GA | 141 | 141 | 72 | 25 | 379 |
| NA | 185 | 183 | 354 | 19 | 741 |
| 合计 | 598 | 554 | 698 | 74 | 1,924 |

迁移后，四表的 `review_status` 变化应当严格等于上表。任何额外变化都应视为越界，不应合并。

## 明确禁止的批量改动

不得把 560 条 `resolution_state=provisional` 事实整体改为 `accepted`。其中 547 条只是可以把行级复核状态改为 `reviewed`，另有 13 条本身还标着 `needs_resolution`，必须原样保留。

不得把 45 条 `conflict_member` 事实或 55 条 `conflicting_unresolved` 字段要求改成已解决。也不得晋级 3 条 NA 的 `not_found / needs_resolution`、2 条 NA 的 `value_available / needs_resolution`、11 条 `pending_verification / needs_resolution`，以及 14 条仍为草稿的 `pending_verification`。

不得把 599 条 `source_checked` 断言整体改成 `independently_reviewed`。包级验收可以支持 `review_status` 的同步，不能替代逐行第二读者记录。

不得把来源筛选中的 2 条 `pending` 或 2 条 `inaccessible` 改成 `reviewed`，也不得改变其筛选结论。取得正文或完成新一轮检索后，应另走一次复核，而不是借本次生命周期整理消除缺口。

## 回滚与独立验收门

实际迁移前，应固定四表原文件的 SHA-256，并导出包含表名、主键、旧状态、新状态和所属批次的 1,924 行迁移清单。回滚只允许按这份清单把 `review_status` 恢复为原值；如果任何事实值、来源定位、要求结论或筛选结论发生变化，应整体回退本次迁移并另开语义修订工作包。

独立验收至少检查五件事：四表行数和主键集合不变；状态差异恰好是 1,924 个 `draft → reviewed`；`facts.resolution_state`、`fact-assertions.extraction_status`、`field-requirements.requirement_status` 和 `source-screening.screening_status` 零变化；每条已复核直接事实仍有合格断言；正式 `Validate-ResearchData.ps1` 退出码为 0。复核者还应按 M1、GHC、GA、NA 重算上表，不以总数相同代替批次边界检查。

## 交接

本报告只提出迁移方案，没有执行批量迁移，也没有修改正式 CSV、资料卡、进度、README、AGENTS 或研究计划。当前建议是先由总控确认“包级独立验收可以承接行级 `review_status=reviewed`，但不承接 `extraction_status=independently_reviewed`”这一口径，再生成显式主键白名单并实施。