# M2-GA-ARCH staging 自检

检查日期：2026-08-13。范围仅为 `M2-GA-ARCH` staging；这不是正式库验收，也没有运行会把 staging 自动并入正式表的命令。

## 结构与引用

- 32 个 `structured/*.csv` 与对应正式表表头逐字一致：通过，0 个表头差异。
- 20 个非空表的第一列主键：通过，0 个空主键或重复主键。
- 事实与字段要求数量：141 条 facts、72 条 field requirements。
- 包内主键加正式库/本包外键：通过，0 个对象、组件、link、precision path、capability 或 source 断裂。
- 每条 fact 都有一条 source assertion：通过，0 条无断言事实；断言 fact/source 外键 0 错误。
- selection member 的 source 外键：通过，0 错误。
- `card-completeness.csv`：126 个唯一对象/域组合，即 14 个对象各 9 个域；状态分布为 27 个 `complete`、14 个 `not_applicable`、69 个 `partial` 和 16 个 `missing_public_data`。逐卡解析 126 个状态后，结构化表与卡片差异为 0。

## 枚举与七目标 XOR

对 27 个受控字段检查正式 `数据/enums.csv`：通过，0 个未知枚举值。覆盖组件域/类型、存储层级、precision operation class、capability、link、fact、requirement、source、screening、selection、coverage、search 与 completeness。

141 条 facts 和 72 条 field requirements 的七目标列（object、component、link、object_relation、precision_path、capability、topology）逐行 XOR：通过，0 条不等于一个目标。Trainium2 没有新增 facts；复用映射共有 110 行，覆盖 109 个唯一 fact_id（一个 fact 对应两条不同来源断言）。

## 架构层级闸门

对 facts 检查以下禁止下放字段：芯片/执行单元总峰值、核心/链路数量、存储容量/带宽、互联总带宽、工艺、频率、die/HBM stack 数。结果：0 条。数值列 `normalized_value_number` 也为 0 条非空。65 条已核实实现信息全部在 `sources/deferred_implementation_facts.csv`，不属于正式同表头片段。

Pod、Boardfly、Virgo、EC2、UltraServer、NeuronSwitch 和系统聚合只出现在边界/卡片说明，没有 structured fact。TPU 外部 2D/3D 部署拓扑没有作为架构 topology fact；structured 只保留 ICI/NeuronLink 等架构层协议机制。Ironwood 的 D2D 协议与集合通信管理均已下沉 deferred。

## 来源与最小集

基于第二次修复后的 141 条事实和 141 条断言重跑 selection run `SEL-M2GA-ARCH-20260812-R2`：25 个一手候选中 19 个 `selected`，且每个至少支撑一条事实；A01、G04、G06、G07、G09、G12 共 6 个来源被反向移除，覆盖关系写入 `source-coverage.csv`。Trainium2 既有正式来源未混入本包 selection run。11 个动态页标记为 `dynamic_unfrozen` 并登记快照候选，没有宣称已固定。媒体来源数为 0。

五角度检索、15 个首轮抓取预算和高相关例外已经写入 `sources/deep_research_trace.md`。25 个高影响主张完成三票核验；两票以上反对的主张均未进入架构 facts。

`raw_value_text` 和 `quoted_context` 均保存逐条回源核对的来源原文；141 条中两列完全相同 141 条，这是同一原文摘录在两个字段中的完整保存，不是把 normalized value 复制成伪原文。来源原值不含审计判断句；source locator 均为页码、表格、明确章节或版本化网页行号。

G01 第 5 页的 SparseCore Top-K 句只说明跨代演进，没有给出首次代际或逐代归属。本包已删除 v3、v4、v5p、Ironwood 四个逐代 capability、fact、assertion、requirement 和 search；原句仅留在 `M2GA-BD-005`，专用 MoE router 继续独立为 `not_found`。

## 冲突与缺口

本架构包没有 formal conflict group。v5p 95/96 GiB、Ironwood 7300/7380 GB/s 和旧 420 TOPS 属作用域、显示精度或 superseded 版本。Trainium3 16/20 CC-Core、4.9/4.7 TB/s，以及 Trainium1/Inferentia2 820 GB/GiB 是实现层真冲突候选，等待 silicon_package 对象。Trainium2 只引用 M1 `CF-006`。

缺失状态区分了 `not_found` 与 `not_applicable`：前者表示完成计划检索仍无一手证据；后者表示请求的是芯片 total，目标层级对 architecture_generation 不适用，不表示硬件没有该值。

## 文档与临时产物

14 张卡均包含 fact_id、九域完整度、缺失/search_id、最小来源、反向移除/未采用理由、实现 backlog 和自检状态。逐卡事实明细合计 141 个 fact_id，与 `structured/facts.csv` 双向一致：遗漏 0、孤立 0、重复 0。Markdown 未使用项目禁止的旧式 LaTeX 公式分隔符。README、自检、验证结果、修复日志、检索轨迹和 14 张卡共 19 份中文 Markdown 已依次完成 report-humanizer 机器扫描和 shuorenhua 人工事实保真检查；机器可识别问题为 0。人工回读检查了标题、首段、表格引导、转场和结尾，没有发现需要改写的套话；数字、版本、路径、状态和责任归属均未因自然化而改变。

临时 PDF 页图与临时生成器在最终交付前删除；`fixed-candidates/README.md` 只保留页码和表格核对结论。根 `README.md` 与 `AGENTS.md` 已检查但不修改，因为本包没有改变正式项目范围、结构或全局状态。

使用 2026-08-13 当前正式库重新建立包内临时合并并运行官方校验器，结果为 `PASS: 32-table research data model; 62355 checks executed`；正式 32 张 CSV 前后哈希变化为 0。

## 合并预期

总控应先审阅对象边界，再按“components/memory/precision/capability/link → facts/assertions → requirements/search → selection”顺序合并。selection run 只是 draft，必须在全局事实集上重跑。`deferred_implementation_facts.csv` 不得直接导入架构 facts；只能在相应 silicon_package/cloud_accelerator 对象建立后逐行迁移并重做冲突判定。Trainium2 的新合并动作预期为零条事实，只保留卡片和复用映射。