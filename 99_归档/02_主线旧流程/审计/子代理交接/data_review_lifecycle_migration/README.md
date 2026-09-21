# 正式库四表生命周期迁移审计清单

状态：清单已生成并通过独立验证，正式迁移未执行。  
审计日期：2026-08-13  
清单签字：`m2_wave2_queue_audit`  
适用范围：只允许把清单内行的 `review_status` 从 `draft` 改为 `reviewed`。

## 文件

本目录共有七个交付文件：

| 文件 | 用途 |
|---|---|
| `migration.csv` | 1,924 行显式主键白名单，记录表名、主键、批次、状态变化、须保留的语义状态和验收依据 |
| `signoff-M1.csv` | M1 的四表签字摘要，共 4 行 |
| `signoff-GHC.csv` | GHC 的四表签字摘要，共 4 行 |
| `signoff-GA.csv` | GA 的四表签字摘要，共 4 行 |
| `signoff-NA.csv` | NA 的四表签字摘要，共 4 行 |
| `Verify-Migration.ps1` | 从正式四表和三份 staging 主键集合重新计算白名单，并核对清单与签字摘要 |
| `README.md` | 说明生成口径、验证结果和执行边界 |

`migration.csv` 的 SHA-256 为 `E2D7F62795DE4DBAB1985BE057F3B2EBFDC750F775AFD3A4773FB7A278CD2A54`。四份签字摘要都绑定这个哈希；清单内容一旦变化，验证脚本会因哈希不一致而失败。

## 主键归属和候选条件

GHC、GA、NA 的成员分别取自以下 staging 文件中的实际主键集合：

- `审计/子代理交接/m2_staging/M2-GHC-ARCH/structured/`
- `审计/子代理交接/m2_staging/M2-GA-ARCH/structured/`
- `审计/子代理交接/m2_staging/M2-NA-ARCH/structured/`

脚本对 `facts.csv`、`fact-assertions.csv`、`field-requirements.csv` 和 `source-screening.csv` 逐表读取主键，检查批次间无交集，并确认每个 staging 主键已经存在于正式表。M1 是正式表候选集合扣除这三个 staging 主键集合后的余集。批次归属没有使用 ID 前缀或名称猜测。

进入 `migration.csv` 的行还必须符合对应状态条件：

| 正式表 | 当前条件 | `semantic_status_preserved` 的写法 |
|---|---|---|
| `最小参考资料库/fact-assertions.csv` | `review_status=draft` 且 `extraction_status=source_checked` | `extraction_status=source_checked` |
| `数据/facts.csv` | `review_status=draft` 且 `resolution_state` 为 `accepted`、`provisional` 或 `superseded` | `resolution_state=<当前值>` |
| `数据/field-requirements.csv` | `review_status=draft` 且 `requirement_status` 为 `value_available`、`not_found`、`not_applicable` 或 `inaccessible_evidence` | `requirement_status=<当前值>` |
| `最小参考资料库/source-screening.csv` | `review_status=draft` 且 `screening_status` 为 `selected`、`redundant_covered`、`out_of_scope`、`rejected_unreliable` 或 `lead_only` | `screening_status=<当前值>` |

`semantic_status_preserved` 只记录迁移前必须保持的正式值，不能作为更新指令。实际迁移只能改 `review_status`。

## 清单复算

| 批次 | 断言 | 事实 | 字段要求 | 来源筛选 | 合计 |
|---|---:|---:|---:|---:|---:|
| M1 | 237 | 195 | 193 | 21 | 646 |
| GHC | 35 | 35 | 79 | 9 | 158 |
| GA | 141 | 141 | 72 | 25 | 379 |
| NA | 185 | 183 | 354 | 19 | 741 |
| 合计 | 598 | 554 | 698 | 74 | 1,924 |

1,924 个“表名加主键”组合全部唯一。每行都是 `old_review_status=draft`、`new_review_status=reviewed`，并能逐行回到当前正式表。四份签字摘要各有四行，表内数量分别合计为 646、158、379 和 741；`signoff_status` 均为 `accept`，签字只覆盖清单成员、批次归属、状态转换和语义状态保留。

## 实跑结果

从项目根目录执行：

```powershell
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '.\审计\子代理交接\data_review_lifecycle_migration\Verify-Migration.ps1' -RootPath '.'
```

2026-08-13 的实际输出为：

```text
PASS: migration audit manifest; 51399 checks executed.
Manifest: 1924 unique rows; SHA-256 E2D7F62795DE4DBAB1985BE057F3B2EBFDC750F775AFD3A4773FB7A278CD2A54
By table: fact-assertions=598; facts=554; field-requirements=698; source-screening=74.
By batch: M1=646; GHC=158; GA=379; NA=741.
All rows match current formal primary keys, staging-derived batch membership, draft->reviewed, and preserved semantic statuses.
Four batch signoff summaries match the manifest and are bound to its SHA-256.
No migration was executed; the four formal CSV files were read only.
```

脚本检查七列固定表头、复合主键唯一性、正式行匹配、staging 成员归属、四表总数、四批次总数、16 个批次和表交叉计数、`draft → reviewed`、四个语义状态列，以及签字摘要的数量、证据路径、签字人、日期和清单哈希。

生成和验证前后，正式四表 SHA-256 未改变：

| 正式表 | SHA-256 |
|---|---|
| `数据/facts.csv` | `045D108C963B97401BD44E677026255EFB82C67BA08BAAC2FA9B84BE0620059D` |
| `最小参考资料库/fact-assertions.csv` | `EA985E42F5AF7E1584EAD4CADD20B74370C386587D38329CD149411738034823` |
| `数据/field-requirements.csv` | `143A0AF7BDC976950044FA59FD26992227B08DFE7155B4EF6241AB261C6DE307` |
| `最小参考资料库/source-screening.csv` | `3BBDBF1BC2CB235DA06014C2A8643B2EA6E4B428BE65609B898231FA1AFDAF7D` |

## 执行边界

本目录不含写入正式表的迁移脚本。总控若以后执行迁移，仍须先备份四表并重新运行本验证；任何正式表变化都会使逐行匹配失败。迁移时应按断言、事实、字段要求、来源筛选的顺序处理，每步只改 `review_status`，保存差异后运行正式 `Validate-ResearchData.ps1`。

以下内容不在许可范围内：把断言的 `extraction_status` 改为 `independently_reviewed`；把事实的 `provisional` 改为 `accepted`；改变字段要求或来源筛选结论；触碰 `needs_resolution`、`pending_verification` 或已是 `reviewed` 的行；把任何记录提高到 `approved`。出现清单外差异、数量变化、语义状态变化或验证失败时，应停止并用备份恢复。

## 运行说明和文档检查

四份签字摘要第一次生成时，命令把 statement-form `foreach` 直接接到管道，PowerShell 在解析阶段退出，没有写文件。这是命令构造错误；改为先物化结果后生成成功。

`Verify-Migration.ps1` 第一次以 UTF-8 无 BOM 保存，Windows PowerShell 5.1 把脚本中的中文路径按系统代码页读取，得到 1,997 个连锁错误。问题属于编码处理错误，与用户拒绝、审批失败、沙箱拒绝或验证逻辑无关；脚本改为 UTF-8 BOM 后重跑通过 51,399 项检查。两次失败均未修改正式表。

根 `README.md` 与 `AGENTS.md` 已按只读方式检查。本次只新增迁移审计产物，没有改变项目目标、正式数据、目录职责、运行规则或全局进度，因此无需修改根文档。交付前，本文通过 `report-humanizer` 机器扫描，并按 `shuorenhua` 的文档场景回读标题、首段、表格引导、转场和结尾；主键口径、数量、状态、路径、哈希和责任归属均保持不变。