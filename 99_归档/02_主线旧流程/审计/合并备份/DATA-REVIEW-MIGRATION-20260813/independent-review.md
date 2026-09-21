# 正式库四表生命周期迁移清单独立复核

复核日期：2026-08-13  
裁决：`accept`  
独立复核者：`data_review_migration_independent_signoff`  
绑定清单：`migration.csv`，SHA-256 `E2D7F62795DE4DBAB1985BE057F3B2EBFDC750F775AFD3A4773FB7A278CD2A54`  
写入范围：仅本报告；正式四表和迁移目录均未修改。

## 裁决与执行许可

本清单可以进入正式迁移。总控获准把清单内 1,924 行的 `review_status` 从 `draft` 改为 `reviewed`，许可不覆盖任何其他列、其他主键或其他状态变化。执行前仍要核对本报告列出的清单哈希与四张正式表哈希；任一哈希不符时，本次许可自动失效，须重新生成或复核清单。

四份 `signoff-*.csv` 的 16 行 `reviewer` 都是 `m2_wave2_queue_audit`，与清单及签字摘要作者相同。它们只能作为作者自检摘要，单独使用不能满足独立签字要求。本文由未参与清单生成的代理复核，并对下表 16 个“批次 × 正式表”单元格逐项签字 `accept`。因此，本文已经补上 `data_review_lifecycle_independent_review.md` 要求的独立签字，不需要改写四份作者摘要。

## 独立签字矩阵

表中每格采用“进入迁移的行数 / 该批次正式行总数”。GHC、GA、NA 的批次成员来自三个已验收架构包的 staging 主键集合；M1 是当前正式四表扣除这三个集合后的余集。

| 批次 | 断言 | 事实 | 字段要求 | 来源筛选 | 迁移行合计 | 独立签字 |
|---|---:|---:|---:|---:|---:|---|
| M1 | 237 / 239 | 195 / 253 | 193 / 265 | 21 / 26 | 646 | `accept` |
| GHC | 35 / 35 | 35 / 35 | 79 / 80 | 9 / 11 | 158 | `accept` |
| GA | 141 / 141 | 141 / 141 | 72 / 72 | 25 / 25 | 379 | `accept` |
| NA | 185 / 185 | 183 / 185 | 354 / 369 | 19 / 19 | 741 | `accept` |
| 合计 | 598 / 600 | 554 / 614 | 698 / 786 | 74 / 81 | 1,924 | `accept` |

未进入清单的 157 行都符合排除规则。M1 排除了 2 条已复核断言；56 条 `needs_resolution` 和 2 条已复核事实；13 条 `pending_verification`、56 条 `needs_resolution` 和 3 条已复核字段要求；以及 2 条 `needs_resolution` 和 3 条已复核来源筛选。GHC 排除了 1 条 `pending_verification` 字段要求和 2 条 `needs_resolution / inaccessible` 来源筛选。NA 排除了 2 条 `needs_resolution` 事实和 15 条 `needs_resolution` 字段要求。GA 没有排除项。清单没有为了满足目标数量而放入未决、待验证或已复核记录。

## 复算与逐行核对

我完整读取了迁移目录的 `README.md`、四份 `signoff-*.csv`、`Verify-Migration.ps1`，并回读了前置裁决 `data_review_lifecycle_independent_review.md`。清单固定为七列、1,924 行；1,924 个“表名 + 主键”组合全部唯一，空主键和重复组合均为 0。四表分布为断言 598、事实 554、字段要求 698、来源筛选 74；批次分布为 M1 646、GHC 158、GA 379、NA 741。

我用独立实现重新构造白名单，没有复用 `Verify-Migration.ps1` 的候选结果。GHC、GA、NA 分别从 `M2-GHC-ARCH`、`M2-GA-ARCH`、`M2-NA-ARCH` 的四份 structured 表读取实际主键，确认三个批次两两无交集，所有 staging 主键都存在于对应正式表。随后按正式语义状态筛选候选，并把余集归入 M1。独立生成的 1,924 个复合主键和七列内容与 `migration.csv` 全量相等，缺行、越界行和字段差异均为 0。清单中的四组 `evidence_basis` 所列文件也全部存在；各包最终验收文件均给出通过或 `accept`。

在内存中模拟迁移后，恰有 1,924 行发生变化，每行只变化一个单元格：`review_status` 的 `draft → reviewed`。四张表的行数、主键集合和顺序保持不变；`facts.resolution_state`、`fact-assertions.extraction_status`、`field-requirements.requirement_status`、`source-screening.screening_status` 的变化数均为 0，其他非白名单列和行的变化数也为 0。

抽查采用每个“批次 × 表”单元格按主键排序后的首行、中间行和末行，共 48 行。抽查行逐项核对正式主键、当前 `review_status`、语义状态和批次来源，48 行全部通过。样本包括 `FACT-AWS-TRN2-3XL-CHIP-QTY`、`REQ-NVG3-VXM-FORMATS`、`SCREEN-M2-GA-G15`、`ASSERT-M2NA-DER-CDNA4-MATRIX-VECTOR`；这些样本分别覆盖 M1、GHC、GA、NA 和四类正式表。

## 本次验证结果

迁移目录自带验证器实跑通过：

```text
PASS: migration audit manifest; 51399 checks executed.
Manifest: 1924 unique rows; SHA-256 E2D7F62795DE4DBAB1985BE057F3B2EBFDC750F775AFD3A4773FB7A278CD2A54
```

当前正式校验器也通过：`PASS: 32-table research data model; 91286 checks executed.`。四张目标表仍是迁移清单生成时的版本：

| 正式表 | 当前行数 | SHA-256 |
|---|---:|---|
| `最小参考资料库/fact-assertions.csv` | 600 | `EA985E42F5AF7E1584EAD4CADD20B74370C386587D38329CD149411738034823` |
| `数据/facts.csv` | 614 | `045D108C963B97401BD44E677026255EFB82C67BA08BAAC2FA9B84BE0620059D` |
| `数据/field-requirements.csv` | 786 | `143A0AF7BDC976950044FA59FD26992227B08DFE7155B4EF6241AB261C6DE307` |
| `最小参考资料库/source-screening.csv` | 81 | `3BBDBF1BC2CB235DA06014C2A8643B2EA6E4B428BE65609B898231FA1AFDAF7D` |

`Verify-Migration.ps1` 会检查签字人非空，但不会判断签字人与清单作者是否为同一人；它也没有把上表四个正式哈希写成强制断言。本次独立复核已经补足签字人独立性，并确认四个哈希相符。后续若四表发生任何修改，即使自带验证器仍能通过，也应先停止执行并重新确认差异是否影响本清单。

## 总控执行边界

执行顺序固定为断言 598 行、事实 554 行、字段要求 698 行、来源筛选 74 行。总控应先备份四表并保存哈希，每完成一张表就运行正式校验器和差异检查。全部迁移完成后的 `review_status` 数量应为：断言 `reviewed=600`；事实 `reviewed=556`、`needs_resolution=58`；字段要求 `reviewed=701`、`draft=14`、`needs_resolution=71`；来源筛选 `reviewed=77`、`needs_resolution=4`。

出现清单外主键、任何非 `review_status` 变化、行数或主键集合变化、语义状态变化、哈希不符或验证器非零退出时，应立即停止并从备份恢复。语义内容修订必须另开工作包，不能夹带在本次生命周期迁移中。

## 文档与运行检查

根 `README.md` 与 `AGENTS.md` 已按只读方式检查。本次只新增独立复核报告，没有改变项目目标、目录职责、正式数据、运行规则或全局进度，因此无需修改两份根文档。

独立复算第一次通过 PowerShell 管道向 Python 传递脚本时，默认输出编码把中文路径替换成问号，Python 因无效路径退出；这是操作者的编码处理错误。改为显式 UTF-8 后，同一独立复算通过。另一次生成 48 行抽查样本时，数组长度表达式构造错误导致只读命令退出；改用显式数组长度后通过。两项都没有写入正式表、迁移目录或其他项目文件，也没有发生用户拒绝、自动审批拒绝、审批连接失败、沙箱拒绝或远端服务错误。