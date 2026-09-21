# M2-W2 AWS package facts 修正记录

状态：`ready_for_independent_review`

修正来源：`审计/子代理交接/m2_review_aws_package_facts.md`

写入边界：只修改本目录；原冻结包、正式库、正式资料卡和全局文档保持不变。

## B01-B09 关闭结果

| ID | 当前状态 | 处理结果 |
|---|---|---|
| AWS-PKG-B01 | closed | A02/A03/A04/A05/A06/A08/A10 七条来源覆写 notes 已改为“单一固定快照”；正文等价说明只留 A01、A07。 |
| AWS-PKG-B02 | closed | 为 Vector/Scalar 各补 A07 直接断言，两个事实改为 `corroborated`；A10 已退出 package selection member 和 selected role，反向移除改为零事实损失，当前最小集为八源。 |
| AWS-PKG-B03 | closed | 已新增 A08 generic FP8 的 component、precision path、condition、fact、assertion、requirement、卡片和 backlog 映射；A06 的 2,517 MXFP8/MXFP4 与 A08 的 2.52 FP8 保持分立。 |
| AWS-PKG-B04 | closed | 七条非逐字 `quoted_context` 已改为连续原文，四张卡同步；69 条断言均通过固定 HTML 全文规范化匹配，失败数为 0。 |
| AWS-PKG-B05 | closed | Vector/Scalar 吞吐改挂新 precision path；Trainium1/Inferentia2 CC 数量改挂新 component。Trainium3 Tensor Engine 时钟保留 component 主体，并新增最小全局合同候选 `FIELD-PHY-CLOCK: object → object;component`；正式与 staged `fields.csv` 均未修改。 |
| AWS-PKG-B06 | closed | 前 15 条 search-log 只登记 `developer_documentation`，Trainium3 五条登记 `developer_documentation;press_release`，notes 明确限于冻结语料。 |
| AWS-PKG-B07 | closed | A09 rationale 已改为 Trainium4 路线图及 6×/4×/2× 声明因不在四个 package 对象范围而排除；既有架构 selection run 不删除。 |
| AWS-PKG-B08 | closed | `SCREEN-M2-GA-A01` 保持 `reviewed`，只更新筛选语义，不发生生命周期倒退。 |
| AWS-PKG-B09 | closed | `Test-Staging.ps1` 先解析绝对 RootPath，再定位 remediated 包；相对路径和绝对路径各通过 9,289 项检查。字段合同、逐字引用、B01-B08 语义和 DEC-025 候选均纳入回归检查。 |

## 最终结构化计数

修正版有 27 个组件、6 个存储层、3 条芯片级互连、20 条 precision path、29 个条件集、57 条事实、69 条断言和 71 条字段要求。57 条事实各有一条 fact/requirement 映射和一条卡片覆盖；五组冲突与十个成员未变。来源选择为八个 member、14 条 selected role，A10 留在来源与断言链中，但不再承担 package 最小集角色。

71 条字段要求由 46 条 `value_available`、5 条 `conflicting_unresolved` 和 20 条 `not_found` 组成。24 条 backlog 记录包括 23 条拆分记录和一条 Trainium2 正式链复用记录。DEC-025 lifecycle manifest 候选覆盖 457 个拟写正式库主键：407 行可在独立 accept 与 signoff 后从 `draft` 升为 `reviewed`；49 条未决链保持 `needs_resolution`，`SCREEN-M2-GA-A01` 保持 `reviewed → reviewed`。候选 SHA-256 为 `f2682bdaf3ee4bee58aa95e20aa60461cc96a1f1fbc20a04b93bdcd2e98bc880`。

## 验证与交付状态

包内校验以相对和绝对 RootPath 各通过 9,289 项检查。当前正式基线为 75 个对象、24 条关系、621 条事实、611 条断言和 792 条字段要求，官方 validator 通过 93,179 项检查。基于这份静止基线的隔离临时合并通过 101,048 项检查，临时目录已删除，32 张正式表的前后 SHA-256 全部一致。

中文文档已按 report-humanizer 扫描并做 shuorenhua 人工终检；机器扫描记录见 `audit/report-humanizer-scan.csv`。包内最终 `freeze-manifest.csv` 在文档和验证产物稳定后重建，aggregate 与 manifest SHA-256 由交接消息单独报告，避免把 aggregate 写回被哈希内容造成自引用。独立复核和 signoff 尚未执行，修正者没有自行签字。