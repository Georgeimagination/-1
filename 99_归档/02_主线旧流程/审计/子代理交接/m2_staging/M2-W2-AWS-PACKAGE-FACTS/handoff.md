# M2-W2-AWS-PACKAGE-FACTS 交接

状态：`ready_for_independent_review`。输入包括 M2-GA 架构包的 implementation backlog、第二波对象范围裁决、11 个 2026-08-13 HTML 抓取件、M1 Trainium2 正式链以及当前 32 表的字段与枚举注册表。

## 已完成内容

四个正式预留的 package 对象各有一张实现资料卡，分别覆盖 Inferentia1、Trainium1、Inferentia2 和 Trainium3。结构化候选共有 56 条事实、66 条逐来源断言、24 个组件、6 个存储层、3 条芯片级互连、17 条精度路径和 28 个条件集。事实只写单芯片或每 NeuronCore 的实现量，没有复制正式 architecture 机制，也没有把实例、服务器或机架总量下放。

70 条字段要求把结果和缺口分开：50 条要求已有值或未决冲突，20 条物理构造要求为 `not_found`。这些缺口分别对应四个对象的封装方式、裸片或芯粒数、中介层、裸片面积和晶体管数，均有检索日志与逐来源检查记录。九域完整度为每个对象 9 行，共 36 行。

五组冲突共 10 个候选成员，未设置 preferred fact。Trainium1 与 Inferentia2 的 HBM 带宽分别保留 820 GiB/s 和 820 GB/s；Trainium3 分别保留 144 GiB 与 144 GB、4.9 TB/s 与 4.7 TB/s、16 与 20 个 CC-Core。raw 值、规范值、单位、作用域、条件、短摘录和 locator 都在 `structured/facts.csv` 与 `structured/fact-assertions.csv` 中闭合。

原架构包 23 条 implementation backlog 全部写入 `audit/backlog-disposition.csv`，合计拆成 56 条 fact_id；`DEF-M2GA-ATRN2-01` 复用正式 Trainium2 M1 链。每行都有 disposition、目标对象、拆分数量、完整 fact_id 列表和边界检查。`audit/card-fact-coverage.csv` 用 56 行建立卡片与 fact_id 的双向映射。

## 来源与最小集

11 个抓取件都登记为新的 `web_snapshot` endpoint 候选，日期为 2026-08-13。`local_path` 指向拟正式目录 `最小参考资料库/快照/AWS/PackageImplementations/2026-08-13/`，`staging_local_path` 指向当前 `fixed-candidates/` 文件；合并时应按该映射复制并复核哈希。现有 2026-08-12 endpoint 不补挂这些抓取件。

A01 和 A07 的 latest 与 v2.31.0 `<article>` 正文逐字符相同，版本化入口优先，latest 只作审计；两组各按一个 `source_id` 计证据。append 候选只放在 `structured/source-endpoints.csv`。既有 PK 更新分别位于 `audit/source-endpoint-updates.csv`、`audit/source-updates.csv` 和 `audit/source-screening-updates.csv`，临时合并验证按 overlay 处理，不能把这些行追加成重复 PK。

最小来源候选包含 A01、A02、A03、A04、A05、A06、A07、A08 和 A10 九个 source_id。`structured/selection-members.csv` 对每个来源完整列出移除后会失去的事实，数量与 `audit/reverse-removal.csv` 的 `unique_fact_count`、`lost_fact_ids` 逐项一致。A09 只涉及状态信息，本包未抽取供货状态，故排除。selection run 仍为 `draft`，等待不同代理复核。

## 验证

`scripts/Test-Staging.ps1` 通过 8,322 项检查。它核对 32 个同表头候选、主键与外键、正式 PK 碰撞、枚举和必填值、事实与断言 XOR、证据数量、20 条缺失检索、五组冲突、11 个 endpoint、A01/A07 正文等价、24 条 backlog、36 条完整度、56 条卡片覆盖，以及 selection-members 与反向移除清单的一致性。

`scripts/Test-TemporaryFormalMerge.ps1` 把 append 候选和既有 PK overlay 合并到 staging 内的临时目录，再运行正式 `Validate-ResearchData.ps1`。正式 validator 通过 99,503 项检查。验证前后 32 张正式表的 SHA-256 全部不变，临时目录与目录联接已经删除。正式库本身的 validator 也需在独立复核时再运行一次，确认基线仍为 91,827 项。

中文 README、4 张资料卡和本交接先按 `report-humanizer` 扫描，再按 `shuorenhua` 的 docs/status 边界人工回读；数字、版本、ID、路径、短摘录和责任归属保持不变。

## 待独立复核

复核者应先确认四个 package 对象仍只承担实现事实，再检查五组冲突的成员是否同对象、同字段、同条件。随后核对 11 个拟正式快照路径和复制哈希，确认 A01/A07 不重复计证据，并复算九个最小来源的失事实集合。通过后才能把 selection run 和事实状态升级并交给总控顺序合并。

供货状态未在本包抽取。Trainium3 定日公告的 2.52 PFLOPs 与开发文档的 2,517 TFLOPs 展示精度关系也未强行合并；本包只保留可直接定位且作用域明确的 2,517 TFLOPs 候选。方向、有效载荷、物理封装构造等未知量继续留空。

## 写入文件

本任务只写 `审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS/`。正式 32 表、正式资料卡、README、AGENTS、研究计划和进度文件均未修改。长期保留两份验证器；一次性 Build 脚本已在最终冻结前删除。