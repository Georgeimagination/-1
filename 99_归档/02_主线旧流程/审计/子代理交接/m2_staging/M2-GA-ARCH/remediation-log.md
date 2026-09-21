# M2-GA-ARCH 修复记录

- 状态：`complete_in_staging / final_review_fix_applied / ready_for_parent_merge`
- 输入：`审计/子代理交接/m2_review_ga_arch.md`、本包 README、14 张资料卡、32 张 structured CSV、sources 辅助表，以及正式字段、枚举和校验规则。
- 写入边界：只修改 `审计/子代理交接/m2_staging/M2-GA-ARCH/`，不修改正式库、根 README、AGENTS、研究计划或进度文件。

## 阻断项处理状态

| 项目 | 状态 | 处理记录 |
|---|---|---|
| B1 目标类型与枚举 | `completed` | Google DMA 只在有证据时挂到 DMA 组件；v5e/v6e 无证据的 DMA 与 VMEM 管理事实删除。Trainium3 舍入拆为 RNE 与 stochastic 两条条件化事实，稀疏能力不再误用 precision-path 字段。最终 141 条事实的目标 XOR、`allowed_subject_kinds` 与受控枚举错误均为 0。 |
| B2 来源家族与 PDF 页数 | `completed` | 25 个来源家族映射为正式枚举：dynamic page history 11、document revision series 6、event material set 4、publication versions 4；四个本地 PDF endpoint 已补 13、12、14、26 页。 |
| B3 来源误引与断言原文 | `completed` | 删除 G05 不支持的 v5e/v6e DMA、VMEM 管理和软件事实；跨代软件事实只由 G01 记录 XLA，不登记 Mosaic 或逐代 Pallas。NCv2 DMA 改为 A05 的 HBM↔SBUF 原文，压缩与解压分别改由 A03/A04 支撑。A07 未直接支持的 MXFP4 转换改由 A10 支撑；AIF1 软件和 NCv2 两条无正文支撑的 Tensor I/O 事实删除。现有 141 条 fact 与 141 条 assertion 一一对应。141 条 assertion 已逐条回源；`raw_value_text` 与 `quoted_context` 都保存同一来源原文，因此两列相同 141 条，来源原值不在 context 内 0 条，研究者通用改写 context 0 条，含混 locator 0 条，研究者写入的 direct raw 审计否定句 0 条；唯一含 “not found” 的 direct raw 是 G03 的来源原句。三条 NeuronLink 规范值只保留设备间集合通信用途，接口数量留在来源原文和 deferred，不推断与 CC-Core 集成。 |
| B4 MoE router / Top-K | `completed` | G01 p.5 只说明 SparseCore 在 Transformer 兴起后开始承担 Top-K 等卸载，没有给出首次代际或逐代归属。已删除 v3、v4、v5p、Ironwood 四项逐代 capability、fact、assertion、requirement 和 search；原文仅留在 `M2GA-BD-005`，禁止绑定具体代际。专用 MoE router 继续独立 `not_found`；`CL-M2GA-009` 改为 `deferred_scope_boundary`。 |
| B5 卡片事实标识 | `completed` | 14 张卡均已按最终事实重生明细；合计显式列出 141 个 fact_id，与 `structured/facts.csv` 双向一致，遗漏 0、孤立 0、重复 0。每卡均有九域完整度。 |
| 最终完整度同步 | `completed` | 按最终独立复核，把 Inferentia1 的 `interconnect`、`special_engines`、`software`，TPU 8i 的 `compute`、`numerics`，TPU 8t 的 `numerics`，以及 TPU v5e 的 `special_engines` 共 7 行由 `partial` 改为 `missing_public_data`；notes 与卡片原有说明一致。修后 126 个对象/域组合唯一，结构化状态与 14 张卡逐项差异为 0。 |
| B6 Ironwood D2D 层级 | `completed` | 已删除 `LINK-M2GA-G7X-D2D` 及对应 fact/assertion；新增 `DEF-M2GA-G7X-07` 保存 collective 管理机制。包内没有对应 `value_available` requirement；卡片改为引用 deferred。 |
| N2 筛选文案 | `completed` | G04 及其余 5 个反向移除来源都明确写为“本轮最小集移除”；`screening_status`、理由与 `source-coverage` 一致。 |
| 最小来源集草案 | `completed` | 已按第二次修复后 141 条事实/141 条断言重跑，run 为 `SEL-M2GA-ARCH-20260812-R2`：25 个候选中 19 个 selected、6 个反向移除。19 个成员恰好等于实际贡献事实的来源集合；mandatory reason 区分事实唯一支持、必要身份/版本、必要状态/版本。Trainium2 既有来源不混入本包 run；11 个动态网页仍为 `dynamic_unfrozen`。 |

## 验证记录

当前复算：141 条 facts、141 条 assertions、72 条 field requirements；缺失断言 0、孤儿断言 0、来源原值不在 context 内 0、研究者通用改写 context 0、含混 locator 0、研究者写入的 direct raw 审计否定语句 0；唯一含 “not found” 的 direct raw 是 G03 的来源原句。32 表表头错误 0，141 条事实和 72 条字段要求的目标/字段允许类型错误 0；14 卡共 126 个九域记录，显式覆盖 141 个 fact_id；完整度状态为 27 个 `complete`、14 个 `not_applicable`、69 个 `partial` 和 16 个 `missing_public_data`，与卡片逐项差异为 0。四个固定 PDF endpoint 的页数为 13/12/14/26，SHA-256 全部匹配。正式库临时副本合并通过官方 validator：`PASS: 32-table research data model; 62355 checks executed`，正式 32 张 CSV 前后哈希变化 0。首次临时合并遗漏 5 个正式快照而失败，补齐后复跑通过；该次失败属于临时副本构造不完整的模型/操作者错误。19 份中文 Markdown 的 report-humanizer 机器扫描全部通过，并按 shuorenhua 完成保真回读；结果见 `validation-result.md`。

## 工具异常与错误分类

依赖定位工具调用超过 50 秒仍无输出，已终止，分类为工具/运行时挂起，未依赖该结果。PDF 文本抽取首次向本机 GBK 控制台输出特殊字符时报 Unicode 编码错误，分类为工具/运行时编码配置问题，改用 UTF-8 输出后成功。若干 PowerShell 命令因空结果索引、缺右花括号、空管道元素、`foreach` 语法构造错误或 `Where-Object` 运算符前后漏空格而失败，均分类为模型/操作者失误，已用短命令纠正并重跑。`rg` 无匹配时退出码 1 属于正常无结果。没有用户拒绝。AppData 临时目录写入曾发生 sandbox denial；AWS Neuron 个别动态入口曾发生远端缓存/内部错误，随后用同一官方站点的版本化页面核对。正式 validator 临时副本清理因 auto-review approval connection/usage-limit failure 被拦截，返回 `Automatic approval review failed: usage limit`；不是用户拒绝，也不是 sandbox denial。依照系统要求没有绕过或重试，`.validation-temp-R1` 及其只读 `论文/` junction 留给总控按精确路径处理。

## 修改文件

- `remediation-log.md`（本文件）
- `structured/card-completeness.csv`
- `structured/facts.csv`
- `structured/components.csv`
- `structured/condition-sets.csv`
- `structured/fact-assertions.csv`
- `structured/field-requirements.csv`
- `structured/search-log.csv`
- `structured/search-results.csv`
- `structured/special-capabilities.csv`
- `structured/conflict-groups.csv`
- `structured/links.csv`
- `structured/source-families.csv`
- `structured/source-endpoints.csv`
- `sources/deferred_implementation_facts.csv`
- `structured/source-screening.csv`、`structured/source-coverage.csv`、`structured/selection-runs.csv`、`structured/selection-members.csv`、`structured/source-selected-roles.csv`
- `README.md`、`self_check.md`、`validation-result.md`
- `sources/deep_research_trace.md`、`sources/skeptical_vote_matrix.csv`、`sources/conflict_and_boundary_log.csv`
- 14 张 `cards/*.md`（B4、B5 与证据边界调整）