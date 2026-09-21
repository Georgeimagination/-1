# 验证记录

## 结论

事务准备包达到 `ready_for_independent_review`。本结论只表示合同、执行器和隔离镜像证据已经准备好，不表示正式合并已获授权。正式根在全部检查前后均为 `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10`，3 个正式新文件目标均不存在，正式写入次数为 0。

## 静态合同与预检

静态合同共通过 6,540 项检查：245 行上游签字被规范化为 242 行受控表写入和 3 个新文件；受控写集覆盖 19 张表；guard 为 3 行；备份候选为 19 张表；备份 manifest 模板有 23 个唯一条目。严格 preflight 在当前正式根上通过 9,379 项检查，同时复核正式 aggregate、上游签字 SHA-256、rebase freeze manifest SHA-256、3 个目标不存在状态、逐表 premerge 哈希、行级旧值和 guard。当前正式校验器通过 106,160 项检查。

候选 oracle 在隔离目录重放后通过 111,040 项检查。19 张待改表的后哈希清单 SHA-256 为 `7f9425cae6b74fc5af5e6c6fbb86815f339ff8ef3d112f0ad87bc0aab8f6d85f`；候选 32 表 aggregate 为 `0d94c60e136fab58941ad8d1f6b5b55a4d2013a370c9a1dc938bd8005fa57bca`。

## 镜像事务

正向场景提交 19 张表和 3 个 payload，候选与提交后校验均为 111,040 项，最终 aggregate 为 `0d94…`。执行完成后临时文件和锁均为 0；正式根保持 `f152…`，正式目标仍不存在。

`rollback_after_3_tables` 精确命中 `INJECTED_TEST_FAILURE_AFTER_3_REPLACEMENTS`。journal 记录 3 次 CSV commit complete，随后按 `condition-sets → components → card-completeness` 的逆序完成 3 次恢复。镜像回到 `f152…`，3 个目标不存在，临时文件和锁均为 0。

`rollback_after_2_payloads` 精确命中 `INJECTED_TEST_FAILURE_AFTER_2_PAYLOADS`。journal 记录 19 次 CSV commit complete 和 2 次 payload commit complete；回滚先逆序删除 2 个 payload，再逆序恢复 19 张表。镜像回到 `f152…`，3 个目标不存在，临时文件和锁均为 0。

## 负向门

六项负向门全部按预期以非零退出：默认正式根拒绝、错误令牌、pending 独立签字、错误镜像标记、预存新文件目标和错误 premerge aggregate。每项都保存独立日志。负向套件结束后正式 aggregate 仍为 `f152…`，正式目标不存在。

## 错误与边界

`operator-error-log.csv` 共 32 条，区分 model/operator mistake 与 implementation error；没有把解析错误、脚本设计错误误报成沙箱、审批或远程服务问题。本任务没有审批阻断、沙箱拒绝或远程服务错误。演练镜像在结果固化后已删除，保留结果 JSON、journal、校验器输出、场景摘要与负向日志，避免把约 295 MB 的临时副本带入冻结包。

README.md 与根 AGENTS.md 已只读检查。准备包没有改变项目范围、正式状态、运行方式或全局约定，因此按任务边界不修改这两个根文件。
