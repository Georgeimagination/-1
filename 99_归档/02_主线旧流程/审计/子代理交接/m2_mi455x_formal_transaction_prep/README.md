# MI455X 正式事务准备包

## 状态

`ready_for_independent_review`。本包只准备事务、备份合同、回滚合同和镜像演练证据，没有改写正式 32 表、正式资料卡或正式快照。正式模式仍默认拒绝；准备者没有签署 `accept`，也没有把模板改成可执行签字。

## 冻结边界

输入绑定为：正式 32 表 aggregate `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10`，MI455X 245 行签字文件 SHA-256 `196863031761221d825309387c563553187b0ee23630002aeaeed57bbbd6084c`，rebase freeze manifest SHA-256 `d3156e2f08b72eca66c3146a423e60264f10aa6eaa3229b684789c4b87640802`。受控写集为 19 张表、242 行；另外有 3 个新文件目标和 3 个禁止改写的行级 guard。候选合并后的 32 表 aggregate 必须为 `0d94c60e136fab58941ad8d1f6b5b55a4d2013a370c9a1dc938bd8005fa57bca`。

## 独立复核顺序

先读 `VALIDATION-RECORD.md`，再核 `authorized-write-set.csv`、`no-write-guards.csv`、`new-file-targets.csv` 和 `formal-backup-manifest-template.csv`。随后复算 `manifest.csv` 的每个文件哈希及 `package-aggregate.txt`。复核者须是不同代理 `m2_mi455x_formal_transaction_independent_review`；只有其另建一行 `accept/true` 外部签字，并逐项绑定冻结脚本、包 manifest、包 aggregate、两份上游签字和正式基线，执行器才会解除 hard deny。

正式备份必须位于正式根之外，完整保存 19 张待改表、guard 涉及的 2 张表、新文件不存在清单和候选 19 表后哈希清单，共 23 个唯一条目。`EXECUTION-ROLLBACK.md` 说明备份目录、授权标记、执行与逆序回滚要求。`transaction-review-signoff-template.csv` 只是不可执行模板，其中 reviewer 为 pending、verdict 为 pending、ready 为 false。

## 已完成演练

隔离镜像正向事务通过：19 张表和 3 个文件恰好写入，候选与提交后校验各为 111,040 项，候选 aggregate 为 `0d94…`。两项故障注入也通过：第 3 张表提交后中断时逆序恢复 3 张表；第 2 个 payload 提交后中断时先逆序删除 2 个 payload，再逆序恢复 19 张表。两场回滚后镜像回到 `f152…`，正式根始终保持 `f152…`，正式目标始终不存在，临时文件与锁均清零。六项负向门全部通过。

## 文件导航

`manifest.csv` 和 `package-aggregate.txt` 是冻结入口；`rehearsal-scenarios.csv`、`negative-gates.csv` 和各 result 目录保存演练原始证据；`operator-error-log.csv` 记录准备过程中所有已识别错误及准确分类。正式执行前仍须独立复核、建立外部备份、生成独立签字和授权标记。本包本身不授权正式写入。
