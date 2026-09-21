# 验证记录

记录日期：2026-08-13

冻结结论：`ready_for_independent_review`。这表示事务包可以交给未参与编写的复核者，不表示可以正式执行。

## 当前冻结版本的证据

| 检查 | 结果 | 证据边界 |
|---|---:|---|
| PowerShell 语法解析 | PASS | `Invoke-AwsFormalTransaction.ps1` 为 0 个解析错误 |
| 静态事务合同 | 17/17 PASS | 见 `static-contract-checks.json`；覆盖外部 formal temp、授权前置顺序、25 项备份、精确签字 schema、动态 package aggregate、原子锁、严格逆序回滚、payload 哈希门和临时文件清理 |
| 正式根默认拒绝 | PASS | 未给 `-AllowFormalRoot` 时退出码为 1，命中默认拒绝；32 表变化 0、正式 payload 变化 0、事务 temp/lock 变化 0，见 `formal-hard-deny-test.json` |
| 一次性事务只读预检 | 4,324 项 PASS | 486 行签字解释为 462 次 CSV 行操作、15 个文件 payload、9 个守卫；`fields.csv` 为 13 列，见 `preflight-current-final.txt` |
| 当前正式数据校验器 | 97,920 项 PASS | `subject_contract_mode=gate`，见 `formal-validator-current-final.txt` |
| 正式 32 表完整性 | 32/32 PASS | 当前哈希与签字基线逐表一致，见 `formal-root-integrity.csv` |
| 正式新文件目标 | 0/15 已存在 | 只读预检和 hard-deny 测试均确认 |
| 清理状态 | PASS | freeze 前 `.tmp-aws-formal-*`、事务 lock、replacement 和 restore 临时文件均为 0 |

当前 32 表 aggregate 仍为 `d10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff`。候选 20 表 posthash 冻结文件有 20 行，SHA-256 为 `4188a42de1eafc383a592814330790ebb939d2613756781a3c941611e11857a7`。

## 可继承但必须重跑的镜像证据

`rehearsal-summary.json` 和 `rehearsal-scenarios.csv` 记录了较早脚本版本的完整三场景演练。结果是：正向写入 477 项并守住 9 行，候选与写后校验均为 `106160` 项；注入“替换 3 张表后失败”时全部恢复；注入“替换 20 张表并复制 4 个 payload 后失败”时恢复 20 张表并删除 4 个新文件。正式 32 表当时保持不变。

后续单场景复测进一步确认了 journal 按实际提交顺序逆序恢复、payload 删除前执行当前哈希门，以及成功和回滚后 replacement/restore 临时文件为 0。收口期间又增加了 formal 分支的外部 `BackupRoot` 临时目录、授权前完整备份门和锁所有权清理。这些修改没有改变镜像数据路径，但改变了冻结脚本哈希。因此，旧结果只能作为设计证据，不能作为当前冻结版本的最终签字依据。

独立复核者必须对当前 manifest 中的三份脚本重新运行：

1. 镜像正向场景，确认 477/9、两次 `106160` 和 15 个 payload；
2. 替换 3 张表后的故障注入，确认严格逆序恢复和所有临时文件清零；
3. 替换 20 张表、复制 4 个 payload 后的故障注入，确认 payload 哈希门、逆序删除和 20 表恢复；
4. formal 缺签字、缺 marker 或 25 项备份不完整的负向场景，确认在任何正式写入、结果目录、候选目录或锁创建前拒绝。

只有这些场景对冻结哈希全部通过，复核者才能在包外生成 `accept/true` 的事务签字。

## 异常分类

实现过程中有两类 PowerShell 命令构造错误：一次文本替换模式没有匹配并在写文件前退出；一次首版 manifest 生成命令缺少必要空格，报错后已被完整覆盖重建。两者都不是沙箱、审批或工具能力限制，修正后重新完成了解析、逐文件哈希和 aggregate 核验，也没有触碰正式数据。最后一次长时正向演练按总控的明确时间要求被主动终止，属于上级任务中断；受控 staging 临时目录和锁随后核验并清理，正式根没有变化。总控尝试读取进程命令行时遇到操作系统或沙箱权限拒绝，但不影响文件级清理和正式根完整性核验。本交付没有因审批拒绝或远程服务错误降低结果质量。