# Ascend 950 物理对象暂存包验证报告

> 验证日期：2026-08-13  
> 最终结论：`PASS`  
> 包状态：`ready_for_final_independent_review`

CSV 是逗号分隔表格，SHA-256 是用来确认文件内容是否变化的散列值。

八条断言主体模式返修后，三张资料卡和 24 份结构化增量重新通过包级检查，并在正式库只读副本上通过官方验证器。正式数据区没有被本包改写，临时合并目录已删除。

## 最终结果

| 检查 | 结果 | 证据 |
|---|---|---|
| 包级结构、外键预检、层级硬门和断言模式固定门 | PASS，1,087 项 | `package-validation-results.json` |
| 正式库当前基线 | PASS，106,160 项 | 2026-08-13 重新执行正式验证器 |
| 暂存增量叠加到只读副本 | PASS，115,461 项，`subject_contract_mode=gate` | `temp-merge-validation.txt`、`temp-merge-summary.json` |
| 正式 32 表静态性 | PASS，32/32 文件 SHA-256 和字节数一致，变化 0 | `formal-32-staticity-after.csv`、`formal-32-staticity-summary.json` |
| 临时目录清理 | PASS | `temp-merge-summary.json` 中 `temp_root_cleaned=true`；现场复查目录不存在 |

包级验证覆盖 24 份 CSV 的正式表头、主键唯一性、与正式库的主键碰撞、事实主体合同、字段要求目标合同、证据来源计数、快照文件哈希、三对象事实归属、状态边界、来源筛选与反向移除、检索日志、九域完整度，以及资料卡对 41 个事实标识的完整引用。返修后增加固定集合门，要求恰好八条指定断言为 `inferred`、其余 42 条为 `direct_statement`，并单独锁定 H-12 deployment 断言。最终计数仍为 41 条事实、50 条断言、106 条要求、27 条完整度记录、4 个来源版本、5 个入口、53 条检索日志和 212 条检索结果。

## 返修内容

复核报告 `m2_review_ascend950_physical.md` 的 SHA-256 为 `1ab5dd20c2cf8598cfd83a7fb05b376b5df142d7bb9bc3375ddc77b3e887e9d9`。按报告列出的精确集合，七条 H-2 共同芯片规格断言和 `ASSERT-M2W3-HUAWEI-PR-STATUS-H12` 改为 `inferred`。前七条的直接主语是复数 “Ascend 950 chips”，共享裸片主体来自同段“PR 与 DT 使用同一颗 die”的归一化；H-12 直接上市的主体是搭载 950PR 的 Atlas 350，把它映射为 package 在嵌入条件下 `available` 也是主体和状态归一化。`ASSERT-M2W3-HUAWEI-PR-DEPLOY-H12` 保持 `direct_statement`。

41 条事实的数值、`fact_kind`、`evidence_state`、来源数、对象归属、关系、条件集和三源最小集均未改变。共同芯片、950DT 路线图和 950PR 当前产品页中的三个 2 TB/s 仍是不同条件记录，不能相加。生成脚本已同步这一精确八条集合；重跑后 24 份结构化 CSV 与返修目标逐文件一致，没有出现额外变化。
## 临时合并方法

验证脚本把当前正式 32 表复制到本包内部的临时根目录，再按同名正式表追加 24 份暂存增量。74 个已有及新增本地入口通过同盘硬链接映射到临时根，未复制或修改原文件；随后用正式 `Validate-ResearchData.ps1` 的 `gate` 模式检查合并结果。验证结束后只删除位于本包下、已解析并确认边界的 `validation/temp-merge-root/`，硬链接目标未受影响。

第一次临时合并检查发现 5 个条件集把 `operation_type` 写成了枚举中不存在的 `other`。这是结构化建模错误，与沙箱、审批和远端服务无关。修正时把未披露的 `operation_type` 留空，继续保留精度路径的 `operation_class=other`、`operation_count_rule=vendor_label` 和 `performance_basis=vendor_label_unresolved`，没有猜测矩阵或向量类型。重跑包级验证和临时合并后均通过。

包级验证还发现生成脚本中两条相邻命令缺少换行，导致 950PR 独立可用日期要求未实际生成。该操作构造错误已修正；最终要求数从预检阶段的 105 条变为 106 条，新增的是 `REQ-M2W3-HUAWEI-ASC950PR-AVAILABILITY=not_found`。相应检索日志由 52 条变为 53 条，结果由 208 条变为 212 条。三张资料卡原本已经写明这个缺口，修复使结构化表与卡片一致。

## 正式基线和并发变化

本包开始后，总控独立完成了已获授权的 AWS 正式合并。刷新后的正式基线是 `formal-32-post-aws-baseline.csv`，正式验证器检查数为 106,160；这次并发变化不属于 Ascend 950 包。旧的 `formal-32-baseline.csv` 只保留为时间顺序证据，不再作为本包静态性比较基准。

正式静态性采用逐文件同算法比较：对 32 份 CSV 分别复算 SHA-256 和字节数，再与刷新基线逐行核对，结果 32/32 一致。事务口径把正斜杠 `table_path|sha256` 按路径排序、以 LF 连接且末尾不换行，聚合值为 `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10`。本包另保留 Windows 相对路径的 `relative_path|sha256|bytes` 口径，聚合值为 `f58d455018ba4a9580427e23948acdd553ad3d61da9e6177c2ca20d9af3633cd`。两个聚合算法不同，不能互相当作前后值；正式库未变的结论来自相同逐文件哈希与字节数比较。

## 工具和访问异常分类

来源预检阶段，H-2 的第一次受限网络访问遭到沙箱拒绝，归类为 `sandbox_denial_recovered`；经批准的升级访问随后成功，固定文件完整。最初一次 PowerShell 下载方法调用括号错误、生成脚本分块时的换行遗漏、短函数名与 PowerShell 别名冲突、`$PID` 只读变量冲突，以及一次筛选表达式写错，都属于操作构造错误，纠正后重新生成和验证，未保留错误产物。一次过长的内联命令触发 Windows CreateProcess 错误 206，属于命令过长造成的工具运行失败；改为短而顺序化的本地脚本后恢复。聚合调试中也曾把函数命名为 `H`，与 `Get-History` 别名冲突；只影响一次诊断输出，最终聚合已用无冲突函数复算。

没有用户拒绝、审批审核拒绝、审批连接失败或华为远端服务错误。最终交付没有因这些已恢复异常降低来源覆盖或验证强度。

## 边界复查

正式 `数据/`、`最小参考资料库/`、`资料卡/`、项目根 `README.md`、项目根 `AGENTS.md`、`进度/`、其他暂存包和两个历史调研目录均未由本包修改。项目根 README 和 AGENTS 已检查；隔离暂存尚未改变正式范围、目录职责或完成状态，所以本代理不更新它们，待总控在独立复核和正式合并后统一处理。