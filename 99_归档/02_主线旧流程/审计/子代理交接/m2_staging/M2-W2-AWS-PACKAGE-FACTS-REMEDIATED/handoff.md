# M2-W2 AWS package facts 修正版交接

状态：`ready_for_independent_review`。

输入包括原 AWS package 冻结包、独立复核报告 `m2_review_aws_package_facts.md`、M2-GA architecture 卡与 deferred backlog、M1 Trainium2 正式链、AWS 范围验收、正式字段与枚举注册表，以及 11 个 2026-08-13 固定 HTML。修正只写本目录。

## 修正结果

四个正式预留的 `package` 对象仍分别对应 Inferentia1、Trainium1、Inferentia2 和 Trainium3。57 条事实全部保持单芯片、单器件或每 NeuronCore 的实现作用域；实例、UltraServer 和架构机制没有下放。五组冲突的原始单位、数值和 10 个成员没有改变。

B01 至 B09 的处理过程和当前验证状态见 `remediation-log.md`。结构化结果为 57 条事实、69 条断言、71 条字段要求、27 个组件、20 条精度路径和 29 个条件集。A07 新增两条 1.2 TFLOPS 断言后，Vector/Scalar 事实均为 `corroborated`；A10 对 package 事实已无独占作用，所以最小集改为八源。A08 的 2.52 PFLOPS generic FP8 被单独保留，没有与 A06 的 2,517 MXFP8/MXFP4 TFLOPS 合并。

20 条 `not_found` 只声称检查了实际冻结语料：Inferentia1、Trainium1 和 Inferentia2 共 15 条只登记 `developer_documentation`，Trainium3 五条登记 `developer_documentation;press_release`。没有再声称检查未登记结果的 cloud service 文档。

## 合并前依赖

Trainium3 Tensor Engine 的 2.4 GHz 事实不能改挂芯片 object，否则会改变来源主语。`audit/field-contract-change-candidate.csv` 根据正式 Trainium2 的四条 reviewed 组件时钟事实和要求，提出最小合同候选 `FIELD-PHY-CLOCK: object → object;component`。本包未改正式或 staged `fields.csv`。独立复核通过后，总控仍须先批准并单独执行这项全局字段合同变更，再合并本包。

`audit/lifecycle-manifest-candidate.csv` 覆盖 457 个实际拟写正式库的主键。407 行可在独立 accept 与 signoff 后执行 `draft → reviewed`；49 行未决冲突链不升 reviewed，`SCREEN-M2-GA-A01` 以 `update_existing` 保持 `reviewed → reviewed`。manifest SHA-256 单列在 `audit/lifecycle-manifest-candidate.sha256`；独立签字和冻结 aggregate 绑定仍未签发。

## 独立复核顺序

先检查四个对象边界与新增 generic FP8 链，再复算 A07/A10 的五条覆盖关系和八源反向移除；随后逐条核对 69 个 `quoted_context`、20 条 search 元数据、A09 rationale 和 A01 screening 生命周期。字段主体检查要把正式字段表与本包的单行合同候选叠加，但不能把候选当成已经生效的正式字段。最后按生命周期清单核对 457 个实际写入主键、49 个未决排除项和 `SCREEN-M2-GA-A01` 的 update_existing 行。

来源合并时，11 个新 endpoint 按 `source-gate/source-freeze-register.csv` 复制到拟正式目录并重算 SHA-256。source、旧 endpoint 和 screening 的既有主键只从 `audit/source-updates.csv`、`source-endpoint-updates.csv` 和 `source-screening-updates.csv` 做 overlay，不得作为 append 行重复写入。A10 的来源、endpoint、五条 package 断言和既有架构断言都要保留。

## 验证证据

相对路径和绝对路径的 staging 校验各通过 9,289 项检查。当前正式基线为 75 个对象、24 条关系、621 条事实、611 条断言和 792 条字段要求，官方 validator 通过 93,179 项检查；以此重建的隔离临时合并通过 101,048 项检查。临时目录已删除，`audit/formal-hash-integrity.csv` 中 32 张正式表的前后 SHA-256 全部相同。

生命周期候选 SHA-256 为 `f2682bdaf3ee4bee58aa95e20aa60461cc96a1f1fbc20a04b93bdcd2e98bc880`。最终冻结哈希由交接消息单独报告；本包没有自签独立复核或 lifecycle signoff。

## 写入边界

本轮新增或修改的文件全部位于 `审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS-REMEDIATED/`。原冻结包、正式 32 表、正式资料卡、`README.md`、`AGENTS.md`、研究计划和进度文件均未修改。