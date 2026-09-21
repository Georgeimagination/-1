# Trainium2 修复包行级生命周期独立签字

签字日期：2026-08-13  
裁决：`accept`  
独立复核者：`m2_review_trn2_correction`  
绑定包：`审计/子代理交接/m2_staging/M2-W2-TRN2-CORRECTION/`  
冻结包聚合 SHA-256：`1dc2d1923146667b6798805585211981cd86ed4196d7fa80f7d490b7b950204f`  
绑定清单：`lifecycle-manifest.csv`  
清单 SHA-256：`7b94c86c6df141839dff03c77732e245118f77a4c0af3526d1575bef8f85d74c`

## 签字范围

我逐行复核并同意下列 17 个行级生命周期结果。前 16 行是在修复语义已先确定的前提下，把 `review_status` 从 `needs_resolution` 改为 `reviewed`；最后一行是新增的 S07 芯片数断言，允许以 `extraction_status=source_checked`、`review_status=reviewed` 写入。该许可不改变修复后事实值、单位、对象层级、字段、来源、条件、`resolution_state`、`evidence_state` 或 `requirement_status`。

| 表 | 主键 | 旧状态 | 新状态 | 修复后语义状态 |
|---|---|---|---|---|
| `数据/facts.csv` | `FACT-AWS-TRN2-48XL-BF16-SPARSE` | `needs_resolution` | `reviewed` | `resolution_state=provisional;evidence_state=single_source` |
| `数据/facts.csv` | `FACT-AWS-TRN2-48XL-FP16-SPARSE` | `needs_resolution` | `reviewed` | `resolution_state=provisional;evidence_state=single_source` |
| `数据/facts.csv` | `FACT-AWS-TRN2-48XL-TF32-SPARSE` | `needs_resolution` | `reviewed` | `resolution_state=provisional;evidence_state=single_source` |
| `数据/facts.csv` | `FACT-AWS-TRN2-TRN2U-48XL-BF16-SPARSE` | `needs_resolution` | `reviewed` | `resolution_state=provisional;evidence_state=single_source` |
| `数据/facts.csv` | `FACT-AWS-TRN2-TRN2U-48XL-FP16-SPARSE` | `needs_resolution` | `reviewed` | `resolution_state=provisional;evidence_state=single_source` |
| `数据/facts.csv` | `FACT-AWS-TRN2-TRN2U-48XL-FP8-SPARSE` | `needs_resolution` | `reviewed` | `resolution_state=provisional;evidence_state=single_source` |
| `数据/facts.csv` | `FACT-AWS-TRN2-TRN2U-48XL-TF32-SPARSE` | `needs_resolution` | `reviewed` | `resolution_state=provisional;evidence_state=single_source` |
| `数据/facts.csv` | `FACT-AWS-TRN2-ULTRA64-EFA-12P8` | `needs_resolution` | `reviewed` | `resolution_state=provisional;evidence_state=single_source` |
| `数据/field-requirements.csv` | `REQ-AWS-TRN2-0111` | `needs_resolution` | `reviewed` | `requirement_status=value_available` |
| `数据/field-requirements.csv` | `REQ-AWS-TRN2-0144` | `needs_resolution` | `reviewed` | `requirement_status=value_available` |
| `数据/field-requirements.csv` | `REQ-AWS-TRN2-0145` | `needs_resolution` | `reviewed` | `requirement_status=value_available` |
| `数据/field-requirements.csv` | `REQ-AWS-TRN2-0146` | `needs_resolution` | `reviewed` | `requirement_status=value_available` |
| `数据/field-requirements.csv` | `REQ-AWS-TRN2-0156` | `needs_resolution` | `reviewed` | `requirement_status=value_available` |
| `数据/field-requirements.csv` | `REQ-AWS-TRN2-0157` | `needs_resolution` | `reviewed` | `requirement_status=value_available` |
| `数据/field-requirements.csv` | `REQ-AWS-TRN2-0158` | `needs_resolution` | `reviewed` | `requirement_status=value_available` |
| `数据/field-requirements.csv` | `REQ-AWS-TRN2-0159` | `needs_resolution` | `reviewed` | `requirement_status=value_available` |
| `最小参考资料库/fact-assertions.csv` | `ASSERT-FACT-AWS-TRN2-3XL-CHIP-QTY-S07` | `new_row` | `reviewed` | `extraction_status=source_checked` |

## 语义修复与生命周期的边界

八条事实从假冲突中解脱后变成 `resolution_state=provisional`、`evidence_state=single_source`，八条字段要求恢复为 `requirement_status=value_available`。这些是本修复包经过独立语义复核的实质改正，不是生命周期动作本身。以该修复后中间态为基线，以上 17 行的生命周期动作没有再改语义列。

本签字不覆盖两个新选择运行、23 个选择成员、新 S07 endpoint、来源筛选行或来源角色行的状态晋级。它们须按包内值继续保持 `draft`；尤其不得把 `SELRUN-M2W2-TRN2INST-CORRECTED-20260813` 或 `SELRUN-M1-PILOTS-TRN2-CORRECTED-20260813` 表述为已经正式 `reviewed`。本复核只确认其范围和反向移除计算在草稿状态下成立。

## 执行边界

总控合并前应重算 49 文件冻结包聚合哈希和本清单哈希。包目录相对路径使用 `/`，按 `StringComparer.Ordinal` 排序；每行写成“相对路径、TAB、字节数、TAB、小写文件 SHA-256”，行间使用 LF，并在末尾保留一个 LF；整个 UTF-8 无 BOM 文本再计算 SHA-256。任何文件、字节数或哈希变化都会使本签字失效。

合并后应验证：上述 17 行与本表一致，两个选择运行和 23 个成员仍为 `draft`，新 S07 endpoint 仍为 `draft`；随后运行正式 32 表校验器。若清单外发生生命周期晋级、正式校验失败或冻结哈希不符，应停止合并并按包内回滚方案恢复。