# M2-GA-ARCH Google TPU 与 AWS 架构工作包

> 状态：`complete_in_staging / final_review_fix_applied / ready_for_parent_merge`  
> 资料截止日：2026-08-12  
> 执行者：子代理 `/root/m2_arch_google_aws`  
> 写入边界：仅本目录；正式表、正式资料卡、最小资料库与全局进度均未修改。

## 交付范围与对象边界

本包覆盖 14 个 `architecture_generation`：Google TPU v3、v4、v5e、v5p、v6e Trillium、TPU7x Ironwood、TPU 8t、TPU 8i，以及 AWS Inferentia 第一代、Trainium 第一代、Inferentia2、Trainium2、Trainium3、Trainium4。

架构事实只保留共同执行组织、矩阵/向量/标量路径、输入、乘积、累加和输出语义、程序员可见的存储层次与管理机制、DMA、互联协议机制、专用能力和软件映射。具体芯片/云加速器的总峰值、执行单元/链路数量、频率、存储容量/带宽、封装/工艺/芯粒，以及 Pod、Boardfly、Virgo、EC2、UltraServer 和系统聚合全部排除。65 条已核实但层级不适用的实现信息另存 `sources/deferred_implementation_facts.csv`，并给出建议目标对象。

Trainium2 是引用型卡：110 行映射覆盖 109 个唯一 M1 芯片/组件事实，只作为“当前实现投影”，不复制、不上卷，也不暗示所有实现共享相同定值。正式 `implements_architecture` 关系与 M1 冲突组继续复用。

## 目录与产物

- `object_scope.csv`：14 个冻结对象和边界。
- `cards/`：14 张一对象一卡的中文草稿，每卡包含 fact_id、九域完整度、缺失与 search_id、来源贡献/移除、实现 backlog 和自检状态。
- `structured/`：32 张正式同表头 staging 片段；空表保留表头。当前包含 141 条架构 facts、141 条逐来源断言和 72 条字段要求；14 张卡的事实明细合计恰好覆盖这 141 条事实，无重复、无遗漏。`card-completeness.csv` 有 126 个唯一对象/域组合，状态为 27 个 `complete`、14 个 `not_applicable`、69 个 `partial` 和 16 个 `missing_public_data`，与卡片逐项差异为 0。
- `sources/source_candidates.csv`：25 个一手来源候选及独有贡献。
- `sources/object_coverage_and_gaps.csv`：14 对象覆盖与缺口。
- `sources/deferred_implementation_facts.csv`：65 条实现层候选，不得合并到架构对象。
- `sources/trainium2_existing_reuse_map.csv`：110 行投影映射，覆盖 109 个唯一 M1 fact_id；重复 fact 行来自不同 source assertion。
- `sources/conflict_and_boundary_log.csv`：版本/舍入、作用域、实现层真冲突和系统边界。
- `sources/deep_research_trace.md`、`skeptical_vote_matrix.csv`：五角度检索、抓取预算和 25 个高影响主张的三票核验。
- `sources/snapshot_candidates.csv`：11 个动态网页快照候选；这些来源在 structured 中标为 `dynamic_unfrozen`，没有冒充 fixed/stable。
- `fixed-candidates/README.md`：四份本地固定 Google PDF 的页码/表格核对结论。

## 来源筛选结果

全部事实链只使用 Google、Google Cloud、OpenXLA、AWS、Amazon IR 和 AWS Neuron 一手材料。媒体没有进入 structured。固定论文优先承担 v3/v4/v5p/Ironwood；版本化 Neuron 文档承担 NCv1、NCv2、NCv4；带日期公告只承担未来对象或状态。

按第二次修复后的 141 条事实与 141 条断言重跑包内选择后，25 个候选中入选 19 个，反向移除 A01、G04、G06、G07、G09 和 G12，共 6 个。它们没有给当前架构事实集合增加不可替代信息，或独有内容只属于具体实现。`selection-members.csv` 只保留这 19 个实际贡献事实的包内来源，不再混入 Trainium2 的既有正式来源。selection run 仍是 `draft`；动态页继续标为 `dynamic_unfrozen`，总控合并后还要按全局事实集合复核。

冲突口径已经收紧：v5p 95/96 GiB、Ironwood 7300/7380 GB/s、Trainium1 旧 420 TOPS 不建 formal conflict；Trainium3 16/20 CC-Core、4.9/4.7 TB/s，以及 Trainium1/Inferentia2 820 GB/GiB 是实现层真冲突候选，等待相应 `silicon_package` 对象建立。Trainium2 沿用 M1 `CF-006`。所以本 architecture staging 的 `conflict-groups.csv` 与 `conflict-members.csv` 只有表头。

## 访问与工具记录

没有用户拒绝。临时目录清理只发生过 auto-review approval connection/usage-limit failure，不是用户拒绝或 sandbox denial。其余异常均已分类：AWS Neuron 个别动态入口的缓存/内部错误属于远端服务错误；PDF 包装脚本路径失败属于本地工具/运行时失败；AppData 临时目录写入被拒属于沙箱拒绝；PDF 文本抽取的 UnicodeEncodeError 与一次 PowerShell 保留变量 `$PID` 误用属于命令环境/操作者错误。替代路径均使用同一一手来源，未降低证据等级。

## 自检与临时合并预期

本包在交付前检查 32 表表头、包内主键、正式+staging 外键、受控枚举、facts 与 field-requirements 的七目标 XOR、Trainium2 不复制、来源断言对应、动态状态、Markdown 公式分隔符和临时产物。当前包内结果见 `self_check.md` 和 `validation-result.md`。最终完整度同步后，正式 validator 临时合并已通过 62,355 项检查，正式 32 张 CSV 前后哈希变化 0。包内 `.validation-temp-R1` 的既有清理请求曾因 auto-review approval connection/usage-limit failure 被拦截。这不是用户拒绝或 sandbox denial。该目录及其只读 `论文/` junction 留给总控按精确路径处理。

临时合并顺序建议：先由总控决定 14 个 architecture 对象是否补正式 objects/relations；再合并组件、存储层、精度路径、能力与 links；随后合并 facts/assertions、requirements/search；最后按全库事实重跑来源最小集。`deferred_implementation_facts.csv` 不能合并到架构对象；应等 silicon_package/cloud_accelerator 工作包建立目标对象后逐行迁移。Trainium2 staging 不产生正式新 facts。

## 项目文档检查

已检查项目根 `README.md` 与 `AGENTS.md`。本包遵守现有范围、目录与协作规则，没有改变项目目标、正式结构或全局状态，因此按任务边界未修改两份根文档。