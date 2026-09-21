# M2-W2-AMD-HELIOS-SYSTEM 行级生命周期独立签字

签字日期：2026-08-13  
裁决：`accept`  
独立复核者：`m2_final_review_helios`  
绑定包级裁决：`审计/子代理交接/m2_review_helios_system_final.md`，裁决为 `accept`，当前 SHA-256 `b3af840bd6f76ed178276f0caf2ba87ac20827f50567b7f2ad5850c946d2b26f`  
绑定清单：`审计/子代理交接/m2_review_helios_system_lifecycle_manifest.csv`  
清单 SHA-256（256 位安全散列算法）：`263e4b176f2eb5cb73890d5d50ee8635d75e19af384ab56dbd1f03100a17b46b`  
冻结包聚合 SHA-256：`9f87160dcafd5061abd1b01a57b5df2a63c2c662446bd3a436f2d9da5034fad5`

## 签字范围

我独立复核了冻结包 24 个结构化 CSV（Comma-Separated Values，逗号分隔值）文件的全部 102 行。清单逐行列出其中 97 条 `review_status=draft` 记录，允许总控在合并时仅把这些主键的 `review_status` 改为 `reviewed`。清单的 97 个“表名 + 主键”组合全部唯一，逐一回查冻结 staging（待合并区）后，原状态均为 `draft`；清单没有漏掉任何 `draft` 行。行级复算共执行 98 项检查，失败为 0。

这项许可只覆盖清单中的 `review_status: draft → reviewed`。事实的 `resolution_state`、断言的 `extraction_status`、字段要求的 `requirement_status`、选择运行的语义 `status` 以及其余所有列必须保持原值；表名、主键或冻结包聚合哈希任一不符时，许可自动失效。

## 排除记录

以下 5 行没有进入清单，合并时继续保留 `needs_resolution`：

| 表 | 主键 | 保留理由 |
|---|---|---|
| `condition-sets.csv` | `COND-M2W2-AMD-HELIOS-AI-UNSPEC-20260105` | 3 AI exaflops 缺数据格式和运算计数定义。 |
| `fact-assertions.csv` | `ASSERT-M2W2-AMD-HELIOS-0011` | 来源只给厂商标签，无法补足精度口径。 |
| `facts.csv` | `FACT-M2W2-AMD-HELIOS-AI-EXAFLOPS-UNSPEC` | 该事实必须与 MXFP4、MXFP8 保持分离，当前不能定案。 |
| `field-requirements.csv` | `REQ-M2W2-AMD-HELIOS-0008` | 值虽已找到，字段定义仍不完整。 |
| `precision-paths.csv` | `PPATH-M2W2-AMD-HELIOS-AI-UNSPEC` | 缺数据格式和运算计数（operation-count）规则。 |

这些排除项不是拒绝该原始厂商断言，也不影响包级 `accept`；它们只表示语义缺口尚未关闭。

## 执行边界

总控执行前应重新计算逐行清单（manifest）的 SHA-256 和冻结包聚合 SHA-256，并确认与本报告一致。执行后应逐表比较：恰好 97 个 `review_status` 单元格改变，其他主键、行顺序、语义状态和内容均不变；随后运行正式 32 表校验器。若出现清单外变化、哈希不符或校验失败，应停止合并并从备份恢复。

`SELRUN-M2W2-AMD-HELIOS-20260813.status: draft → reviewed` 的语义许可不属于本清单；它由包级最终报告单独签字。该运行行自身的 `review_status: draft → reviewed` 仍在本清单内。
