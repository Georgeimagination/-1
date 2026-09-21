# M2-GA-ARCH 最终独立签字

复核对象：`审计/子代理交接/m2_staging/M2-GA-ARCH/`  
复核日期：2026-08-13  
复核角色：独立复核，未参与初稿或修复  
最终裁决：`accept`  
合并许可：允许进入总控正式合并。

## 签字结论

上一轮全量独立复核只留下 7 条卡片完整度状态不一致。修复后，这 7 行都已改为 `missing_public_data`；`structured/card-completeness.csv` 与 14 张卡的 126 个九域状态逐项一致，差异为 0。没有遗留阻断项。

前一轮已经通过的结论继续成立：141 条事实与 141 条断言一一对应，来源原文和定位可追溯；三条 NeuronLink 事实没有数量或 CC-Core 编排外推；逐代 Top-K 伪归属已经清除；14 张卡与事实表完成双向闭环；最小来源选择 R2 为 25 个候选、19 个入选、6 个冗余覆盖；65 条待办均留在实现层；Trainium2 只引用正式库既有事实，没有把具体实现值上卷到架构对象。

## 唯一修复复核

下列 7 个对象/域在结构化表和卡片中现均为 `missing_public_data`：

| 对象 | 域 | `card-completeness.csv` | 卡片 |
|---|---|---|---|
| `OBJ-AWS-INFERENTIA1-ARCH` | `interconnect` | `missing_public_data` | `missing_public_data` |
| `OBJ-AWS-INFERENTIA1-ARCH` | `special_engines` | `missing_public_data` | `missing_public_data` |
| `OBJ-AWS-INFERENTIA1-ARCH` | `software` | `missing_public_data` | `missing_public_data` |
| `OBJ-GOOGLE-TPU-8I-ARCH` | `compute` | `missing_public_data` | `missing_public_data` |
| `OBJ-GOOGLE-TPU-8I-ARCH` | `numerics` | `missing_public_data` | `missing_public_data` |
| `OBJ-GOOGLE-TPU-8T-ARCH` | `numerics` | `missing_public_data` | `missing_public_data` |
| `OBJ-GOOGLE-TPU-V5E-ARCH` | `special_engines` | `missing_public_data` | `missing_public_data` |

独立复算结果如下：

| 检查项 | 结果 |
|---|---:|
| 卡片文件 | 14 |
| 结构化九域记录 | 126 |
| 结构化唯一对象/域组合 | 126 |
| 卡片解析出的九域记录 | 126 |
| 卡片唯一对象/域组合 | 126 |
| 结构化表与卡片状态差异 | 0 |

因此，九域合同满足 $14\times9=126$。这里的 `missing_public_data` 只表示本轮公开资料覆盖不足，不表示产品一定没有相应能力。

## 临时正式合并验证

我重新建立了正式库临时副本，把 staging 的 32 张结构化表按同名表追加，再运行当前正式校验器。结果为：

```text
PASS: 32-table research data model; 62355 checks executed.
Registry: 323 columns, 488 enum values.
```

校验器退出码为 0。临时目录已删除，复查残留目录数为 0；正式资料池仍有 107 份 PDF。清理临时 `论文` 目录联接时，PowerShell 的 `Remove-Item` 发出一次 `NullReferenceException`，属于工具运行时失败，不是用户拒绝、审批失败或沙箱拒绝。外层临时目录随后删除成功，因此没有残留，也没有影响校验结论。正式库和 staging 均未修改。

## 最终裁决

裁决为 `accept`。7 条状态差异已经关闭，当前包可以正式合并。总控合并时仍应排除 staging 内作者遗留的 `.validation-temp-R1/`，并按项目流程在正式库上再运行一次 `Validate-ResearchData.ps1`。

本轮只更新本独立复核报告，没有修改 staging、正式库或 `进度/`。项目根 `README.md` 与 `AGENTS.md` 已检查；这次签字没有改变项目目标、目录、证据规则或正式进度，且子代理无权更新全局状态，因此无需修改。
