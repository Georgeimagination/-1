# Ascend 950 物理对象包返修记录

- 工作包：`M2-W3-HUAWEI-ASCEND950-PHYSICAL`
- 当前状态：`ready_for_final_independent_review`
- 返修依据：`审计/子代理交接/m2_review_ascend950_physical.md`
- 依据文件 SHA-256：`1ab5dd20c2cf8598cfd83a7fb05b376b5df142d7bb9bc3375ddc77b3e887e9d9`
- 写入边界：仅限本暂存包；正式 32 表、正式资料卡、来源快照、根目录 README、`AGENTS.md`、研究计划和进度文件保持只读。

## 已完成的精确修复

以下八条断言的 `assertion_mode` 已从 `direct_statement` 改为 `inferred`：

- `ASSERT-M2W3-HUAWEI-DIE-FP8-H2`
- `ASSERT-M2W3-HUAWEI-DIE-MXFP8-H2`
- `ASSERT-M2W3-HUAWEI-DIE-HIF8-H2`
- `ASSERT-M2W3-HUAWEI-DIE-MXFP4-H2`
- `ASSERT-M2W3-HUAWEI-DIE-VECTOR-H2`
- `ASSERT-M2W3-HUAWEI-DIE-GRAN-H2`
- `ASSERT-M2W3-HUAWEI-DIE-LINK-H2`
- `ASSERT-M2W3-HUAWEI-PR-STATUS-H12`

前七条的直接来源主语是复数 “Ascend 950 chips”。把它们只挂到共享裸片，是依据同段前文“950PR 与 950DT 使用同一颗 Ascend 950 die”完成的主体归一化。H-12 直接上市的主体是搭载 950PR 的 Atlas 350；把这条卡级上市陈述归一化为 950PR package 在嵌入条件下 `available`，是主体和状态推断。`ASSERT-M2W3-HUAWEI-PR-DEPLOY-H12` 保持 `direct_statement`，继续记录 Atlas 350 搭载关系和伙伴整机。

断言备注、`object-scope.csv`、三张资料卡、README、handoff、事实冻结、来源与事实审计、验证报告及可复现生成脚本已经同步。三条 2 TB/s 记录也已明确分开：共同芯片标签、950DT 路线图值和 950PR 当前灵衢 2.0 值属于不同主体和条件，不能相加，也不能据此认定存在三套独立物理带宽池。

## 不变量复核

返修后仍有 41 条事实、50 条断言和 106 条字段要求。断言模式恰为 8 条 `inferred` 和 42 条 `direct_statement`。41 条事实的数值、`fact_kind`、`evidence_state`、来源数、对象归属、关系、条件集和三源最小集均未改变；53 条缺口检索日志、212 条检索结果和三个对象各九域的完整度也未变化。结构对象仍是 6 个组件、3 条链路、2 个内存层级、5 条精度路径和 11 个条件集。

生成脚本加入同一组八条断言的固定映射后已重跑。24 份结构化 CSV 与返修目标逐文件一致，除预定的 `fact-assertions.csv` 语义修复外没有额外漂移。包校验器也增加固定门，要求恰好这八条为 `inferred`，H-12 deployment 保持直接，并锁定对应事实的 `fact_kind`、`evidence_state` 和来源数。

## 验证结果

包校验通过 1,087 项检查。当前正式库单独通过 106,160 项检查；把本包叠加到当前 AWS 后正式基线的只读副本后，正式校验器通过 115,461 项检查，`subject_contract_mode=gate`，临时根已清理。正式 32 表与 `formal-32-post-aws-baseline.csv` 逐文件哈希和字节数 32/32 一致，变化数为 0；事务聚合仍为 `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10`，含 Windows 相对路径、哈希和字节数的包聚合仍为 `f58d455018ba4a9580427e23948acdd553ad3d61da9e6177c2ca20d9af3633cd`。

`manifest.csv` 按返修后的最终文件重建，登记本包除 manifest 自身外的 53 个文件。中文 Markdown 已先经过 `report-humanizer` 机器扫描，再按 `shuorenhua` 做事实保真的最小人工检查；结果记录在 `validation/report-humanizer-scan-final.csv`。

## 工具异常记录

返修中出现六次命令构造或编码错误：字符串分割被误用于定位生成脚本插入点；一条卡片编辑命令把变量后的冒号写成了 PowerShell 无法解析的形式；包校验器一度以无 BOM 的 UTF-8 写回，导致 Windows PowerShell 误解中文路径；正式聚合调试首次把反斜杠当成了无效正则；第一次汇总文档扫描结果和第一次执行最终完整性检查时，两处 `Where-Object` 比较运算符旁少了空格。前两次在写入前停止，第三次没有生成新的校验结果，后三次只影响诊断、结果汇总或只读检查。它们都属于模型或操作命令错误，不是用户拒绝、审批失败、沙箱拒绝或远端服务错误。更正后已用新鲜结果重跑相应检查。

## 交接边界

根目录 README、`AGENTS.md` 和 `进度/当前状态.md` 已只读检查，无需由本返修包修改：本次没有改变正式库、项目范围、目录职责或正式进度。当前包仅转为 `ready_for_final_independent_review`，不自签 `accept`，不提供正式合并或生命周期迁移授权。
