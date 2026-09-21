# Ascend 950 正式事务准备包

## 状态

`ready_for_independent_review`。本目录只保存事务合同、外置备份方案、回滚方案和隔离镜像证据；没有修改正式 32 表、正式资料卡或正式网页快照。正式模式继续默认拒绝，准备者没有签署 `accept`，`transaction-review-signoff-template.csv` 仍是 `pending / false`。

## 冻结输入与写入边界

事务绑定以下输入：正式 32 表聚合哈希（aggregate）为 `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10`；最终复核报告 SHA-256 为 `0680f9ce290ab7b937b4f40c8a1d9250fd1b63e43e7beafef1f7e5e24369a709`；553 行签字 SHA-256 为 `0f59aa2fd893473eb1002d44816e16ace6b204259ac94e802b5f00774ea0cbd5`；暂存区清单（staging manifest）SHA-256 为 `ec23f82850e0c72fc2eb8d60d72d08dfed9fbc0237e27dbea7e3fb87041c36c7`，53 行聚合为 `d10ba0c4437c8f10c044149015101e066688d0cf8b1a43d7379529eed940dd87`。

553 行签字被规范为 545 行结构化写集和 8 个新文件目标。结构化写集覆盖 20 张表；新文件包括 3 张资料卡和 5 份官方 HTML 快照。另有 5 个只读保护项（guard），保护 3 个既有对象和 2 条既有裸片封装关系。候选 32 表聚合哈希固定为 `bcb16e932019c1625e9b5a5309a37f569c0bb230b7c921a589dd3f7175632b8c`，20 表后哈希清单 SHA-256 为 `b84ce89dbdf96accb7861e61cedbfb33618ed8793d33188030f7ef51f15efe73`。

## 两个校验计数的含义

上游签字中的 115,461 项是 staging 行仍处于 `draft` 时的临时合并结果。正式事务会按签字把 531 行从 `draft` 提升为 `reviewed`，另有 14 行保持 `needs_resolution`。生命周期提升后，校验器会多执行 48 项门：41 条已复核非派生事实各增加 1 项“已复核断言存在”检查；1 个已复核的来源最小集选择运行（selection run）及其 3 个成员增加 7 项最小集检查。因此受控候选和事务提交后的预期计数为 115,509。这里没有更改事实值、对象、来源或最小集成员。

## 演练结果

正向镜像完成 20 张表替换和 8 个文件复制，候选与提交后校验均通过 115,509 项。第 3 张表提交后注入故障时，事务逆序恢复 3 张表；第 2 个文件复制后注入故障时，事务先逆序删除 2 个文件，再逆序恢复 20 张表。两次回滚后镜像均回到 f152，正式根在三场演练前后始终为 f152，8 个正式目标始终不存在，事务临时文件和锁均为 0。默认拒绝、错误令牌、待复核签字、错误镜像标记、预存目标和错误合并前（premerge）哈希六个负向门也全部通过。

## 独立复核入口

先读 `VALIDATION-RECORD.md` 和 `EXECUTION-ROLLBACK.md`，再核 `authorized-write-set.csv`、`no-write-guards.csv`、`new-file-targets.csv`、`formal-backup-manifest-template.csv`、`expected-candidate-20-table-posthashes.csv` 及三场事务日志（journal）。不同代理须重新计算包内 `manifest.csv` 和 `package-aggregate.txt`，建立正式根之外的 24 项备份，另建 `accept / true` 外部签字后，执行器才允许正式模式。准备包本身不授权正式写入。
