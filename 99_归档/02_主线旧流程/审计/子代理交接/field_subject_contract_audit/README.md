# 字段主体合同全库独立审计

审计日期：2026 年 8 月 13 日  
状态：审计产物完成；尚未修改任何正式表、正式卡、现有暂存目录（staging） 或全局项目文档。

## 结论

预审的 132 个主键已逐行裁决，26 个字段、28 组“字段、实际类型、登记类型”全部覆盖，没有按统计结果批量放宽事实合同。

| 裁决 | 行数 | 含义 |
|---|---:|---|
| `expand_contract` | 16 | 8 条正式事实和 8 条对应要求；只涉及 `FIELD-DER-COMPUTE-BW-SPEC` 与 `FIELD-PHY-CLOCK` |
| `retarget_row` | 8 | 已有明确下级实体的缺失要求，迁目标但不补未知值 |
| `no_change_with_rationale` | 108 | 保留要求行现有目标，由独立的 requirement-target 合同承接 |
| 合计 | 132 | 主键恰好一次 |

132 行中有 8 条 facts（规范事实）和 124 条 field requirements（字段要求）。124 条要求按正式状态复算为：`not_applicable` 60 条、`not_found` 53 条、`value_available` 8 条、`inaccessible_evidence` 2 条、`conflicting_unresolved` 1 条。此前“59 条 not_applicable”的小计漏了 1 条 object→topology；正确分解是 object→component 28、object→precision_path 16、object→link 15、object→topology 1。

## 为什么不能把 132 行都当成事实合同错误

`fields.csv.allowed_subject_kinds` 适合约束事实主体，却不足以表达要求行的覆盖范围。缺失要求可能在整张对象卡上声明“没找到”或“不适用”，即使将来找到的事实应落到组件、链路或精度路径，也不能仅凭当前缺值把 requirement 迁下去。

本包因此提出两个分开的合同：

- `allowed_subject_kinds` 继续约束 `facts.csv`；
- 在 `fields.csv` 新增 `allowed_requirement_target_kinds`，只约束 `field-requirements.csv`。

正式 120 个字段可先把现有事实合同复制到新列，再应用 `field-contract-proposals.csv` 中 26 个受影响字段的候选。26 个候选里，只有 2 个会改变事实合同；其余 24 个只改变要求覆盖合同。多值类型一律按 `object;component;link;object_relation;precision_path;capability;topology` 的子序列书写。

108 条不迁移行全部是要求行：60 条 `not_applicable`、45 条 `not_found`、2 条 `inaccessible_evidence`、1 条关系投影型 `value_available`。它们不需要行级迁移清单；新列合并后，校验器按要求合同检查即可。本包生成器已逐行验证这 108 行全部命中候选合同。

## 8 条正式事实

四条 Trainium2 时钟事实分别挂在 Tensor、Vector、Scalar、GpSimd 组件，数值为 2.4、0.96、1.2、1.2 GHz。四条断言都指向 `SRC-AWS-TRN2-S02`，提取状态为 `source_checked`。固定 HTML（超文本标记语言）快照 Table 11 的表头是 Compute Engine 与 Frequency (GHz)，并逐引擎给值，所以 component 是来源的直接主语。

另四条 `FIELD-DER-COMPUTE-BW-SPEC` 是 Trainium2 不同精度路径上的派生计算带宽比。每条都有一条 `derived-metrics.csv` 记录和两条 `derived-inputs.csv` 输入，结果含义随精度改变。它们没有直接来源断言，这是派生事实的预期结构；应把事实合同从 `object` 扩为 `object;precision_path`。

## `FIELD-PHY-CLOCK` 裁决

事实合同建议从 `object` 扩为 `object;component`。这能同时承接四条正式 Trainium2 组件时钟事实、四条对应 `value_available` 要求，以及 AWS（Amazon Web Services）Trainium3 的 Tensor Engine 2.4 GHz 候选 `FACT-M2W2-AWS-TRN3-NCV4-TENSOR-CLOCK`。AWS 包可以先执行这个局部合同修复；把候选迁到芯片 object 会改变一手表格的主语。

H100 的三条行不同。`REQ-NVIDIA-H100-BF16-CUDA-FREQUENCY`、`REQ-NVIDIA-H100-FP16-CUDA-FREQUENCY` 和 `REQ-NVIDIA-H100-INT32-CUDA-FREQUENCY` 都是 precision_path 级 `not_found`：资料卡明确说明 Table 3 没有把这些非 Tensor 路径绑定到某一峰值频率。它们应保留为路径级覆盖要求，但不足以授权 precision_path 级频率事实。因此：

```text
事实合同：object;component
要求合同：object;component;precision_path
```

AWS 局部修复成立，不代表全库闭合。26 个字段候选、8 条迁移和校验器规则正式合并并重跑前，不能写“字段主体合同问题已关闭”。

## 8 条行级迁移

| requirement | 从 | 迁到 | 状态处理 |
|---|---|---|---|
| `REQ-M2GA-G8T-LDE-DETAIL` | object | `CAP-M2GA-G8T-LDE` | 保持 `not_found` |
| `REQ-M2GA-G8I-ICI-PROTOCOL-DETAIL` | object | `LINK-M2GA-G8I-ICI` | 保持 `not_found` |
| `REQ-M2GA-G8I-FP4-ACCUM` | object | `PP-M2GA-G8I-FP4` | 保持 `not_found` |
| `REQ-NVG3-MXM-ACCUM` | object | `CMP-NVG3-MXM` | 保持 `not_found` |
| `REQ-NVG3-MXM-EXACT-FORMATS` | object | `CMP-NVG3-MXM` | 保持 `not_found` |
| `REQ-NVG3-MXM-PHYSICAL-ACCUM` | object | `CMP-NVG3-MXM` | 保持 `not_found` |
| `REQ-NVG3-VXM-FORMATS` | object | `CMP-NVG3-VXM` | 保持 `not_found` |
| `REQ-GROQ-LPU1-ROUNDING-MODE` | object | `CMP-GROQ-LPU1-MXM` | 保持 `not_found` |

这些目标都已在正式实体表中命中。正式迁移时还要清空旧 `object_id`、设置新目标列并重算 `requirement_fingerprint`；不能改变缺失状态、检索状态或日期。

## 交付文件

- `adjudication.csv`：132 行逐主键裁决，表头与任务合同一致。
- `field-contract-proposals.csv`：26 个字段候选；不复制其余 94 个无改字段。
- `row-overlay-proposals.csv`：只列 8 条需迁主体的要求行，没有无改行。
- `validator-audit-design.md`：新列、状态语义、审计模式和硬门过渡规则。
- `Build-Adjudication.ps1`：从正式只读输入重新生成三个 CSV 和复算摘要。
- `validation-summary.json`：输入 SHA-256、行数、动作、状态、枚举顺序、外键与候选合同复算结果。
- `formal-validator-readonly-run.txt`：正式校验器最后一次只读运行及源码检索记录。
- `progress-2026-08-13.md`：本任务的持久化中间节点。

复算命令：

```powershell
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '.\审计\子代理交接\field_subject_contract_audit\Build-Adjudication.ps1' -RootPath '.'
```

预期输出：

```text
PASS: 132 rows; 26 fields; 28 groups; 8 row overlays; 26 field proposals.
```

生成器还验证了：132 个主键全局唯一且恰好一次；28 组全覆盖；正式 field、fact、requirement 和七类目标外键全部命中；候选动作、置信度、复核状态及多值类型集合闭合；四条时钟事实的直接断言和四条派生事实的结构齐全；候选应用后事实合同与要求合同不匹配均为 0。

## 正式校验器现状与边界

本次只读运行正式校验器得到：

```text
PASS: 32-table research data model; 93251 checks executed.
Registry: 323 columns, 488 enum values.
```

源码检查确认，它目前只检查七目标外键和“恰有一个目标”，没有检查 `allowed_subject_kinds`。因此这次通过不能替代主体合同审计。应先按 `validator-audit-design.md` 使用审计模式（audit mode），再在正式迁移和独立复核完成后启用硬门（hard gate）。

根目录 `README.md` 与 `AGENTS.md` 已按要求只读检查。由于本子任务被明确限制为只写本交接目录，且没有正式项目状态变更，两份根文档均未修改。