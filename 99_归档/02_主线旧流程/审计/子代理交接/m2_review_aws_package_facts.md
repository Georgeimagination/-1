# M2-W2 AWS package facts 独立复核

复核对象：`审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS/`

复核日期：2026-08-13

本报告中的 AWS 指 Amazon Web Services（亚马逊云服务）；package 指已预留的单芯片或单器件封装对象。

## 裁决

裁决为 `accept_with_fixes`。这不是“可以先合并、以后补说明”：当前冻结包有来源覆写、最小来源集、字段主体、原文短摘录、缺失检索和生命周期方面的阻断项，正式合并必须等这些问题全部修正、重新冻结并再次独立复核。

包内 56 条事实的主体边界大体正确，五组冲突也没有被静默归一；但机器校验只证明现有规则下的表结构自洽，不能代替语义判断。由于裁决不是 `accept`，本报告不签发 DEC-025 规定的生命周期 manifest（逐主键清单），也不签发绑定 manifest 散列和冻结 aggregate hash 的独立 signoff（签字）。

## 合并前必须关闭的阻断项

| 编号 | 精确对象 | 问题与必须动作 |
|---|---|---|
| AWS-PKG-B01 | `audit/source-updates.csv` 中 `SRC-M2-GA-A02`、`A03`、`A04`、`A05`、`A06`、`A08`、`A10` | 七行都写成“latest 与版本化入口正文相同”，实际只有 A01、A07 各有一对等价入口。这不是审计旁注：该 CSV（逗号分隔值文件）是正式 `最小参考资料库/sources.csv` 的实际覆写候选，直接合并会把错误来源说明写入正式库。七行必须改成各自真实的单一固定快照说明；正文等价只保留给 A01、A07。 |
| AWS-PKG-B02 | `ASRT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32-A10-1`、`ASRT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32-A10-1`，以及 `FACT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32`、`...SCALAR-FP32` | 两条断言的 notes 称 A07 只给宽度和频率；A07 v2.31.0 第 2128、2167 行其实分别直接给 NeuronCore-v4（NCv4）Vector/Scalar Engine 的 1.2 TFLOPS（每秒万亿次浮点运算）。应补 A07 断言并重算 `evidence_state`。A10 对这两条事实不再不可替代，当前九源最小集应改为八源；同步处理 `SELMEM-M2W2-AWS-PKG-A10`、`SROLE-M2W2-AWS-PKG-A10-CORE`、A10 反向移除行、`SELRUN-M2W2-AWS-PKG-20260813`、Trainium3 卡及计数和校验器。A10 快照仍可用于既有架构断言，不能因此删除该来源。 |
| AWS-PKG-B03 | A08 第 2116 行、`DEF-M2GA-ATRN3-02`、`FACT-M2W2-AWS-TRN3-CHIP-MX-PEAK`、`REQ-M2W2-AWS-PKG-030` | A08 明确以单颗 Trainium3 芯片为主语给出 2.52 PFLOPS（每秒千万亿次浮点运算）的 FP8（8 位浮点）计算量。当前包只在 handoff 和 MX 事实 notes 中说它不与 A06 的 2,517 MXFP8/MXFP4 TFLOPS 合并，却没有结构化保留 A08 的直接定值。精度标签和显示精度不同，确实不能合并；正确做法是为通用 FP8 建独立 precision path、事实、断言和字段要求，并更新卡片及 backlog 映射，而不是省略这条单芯片事实。 |
| AWS-PKG-B04 | 七条 `fact-assertions.csv` 断言，详见下文 | 66 个 `quoted_context` 中只有 59 个是定位窗口内的逐字文本。七个非原文短摘录必须改成连续、逐字的原文，并同步四张卡中的重复摘录。事实数值本身没有因此失真，但证据文本不能由整理者补写、纠错或用省略号拼接。 |
| AWS-PKG-B05 | 五组 fact/requirement，详见下表 | 事实与字段要求的主体不符合 `数据/fields.csv` 的 `allowed_subject_kinds`。正式校验器（validator）没有报错，说明校验覆盖有缺口，不代表建模合法。必须先按注册表重建主体，或由总控明确修改字段注册规则后再重冻。 |
| AWS-PKG-B06 | `SEARCH-M2W2-AWS-{INF1,TRN1,INF2,TRN3}-{PACKAGE,DIE-COUNT,INTERPOSER,DIE-AREA,TRANSISTORS}` 共 20 条；对应 `REQ-M2W2-AWS-PKG-051` 至 `070` | 20 条都声称检查了 `developer_documentation;cloud_service_documentation;press_release`。前 15 条的结果只登记开发文档；Trainium3 五条只登记开发文档和 A08 新闻稿，全部没有云服务文档结果。若只认冻结语料，前 15 条应写 `developer_documentation`，后五条应写 `developer_documentation;press_release`，并明确“固定语料内未找到”；若要保留当前三类声明，就必须补全真实检索结果。未补计划检索时，不能把元数据写成已经完成。 |
| AWS-PKG-B07 | `audit/reverse-removal.csv` 的 `SRC-M2-GA-A09` 行 | `out_of_scope / excluded` 结论正确，`rationale` 却误称 A09 只承担 Trainium3 正式可用（GA）/收入状态。Gate review 和 `DEF-M2GA-ATRN4-01` 至 `03` 明确表明 A09 支撑 Trainium4 路线图及 6×、4×、2×相对声明。应改成“当前四个 package 对象不含 Trainium4，故本包排除；既有架构 selection run 不删除”。 |
| AWS-PKG-B08 | `audit/source-screening-updates.csv` 的 `SCREEN-M2-GA-A01` | 把筛选语义从 `redundant_covered` 改为 `selected` 是合理的，因为 A01 现在支持 package 事实；但候选同时把正式行的 `review_status` 从 `reviewed` 降为 `draft`。该文件也是正式覆写候选，不能造成生命周期倒退。修正包通过独立复核后，新语义行应以 `reviewed` 合并，并在生命周期 manifest 中单列 old/new 状态和 `update_existing` 动作。 |
| AWS-PKG-B09 | `scripts/Test-Staging.ps1` 第 7、222 至 226 行 | 从项目根以 `-RootPath '.'` 调用会误报 `AWS_Inferentia1_芯片实现资料卡.md` 含外来事实；绝对根路径调用才通过。原因是 `$RootPath` 未先解析为绝对路径，随后拿相对 `Join-Path` 结果与 `$file.FullName` 比较。脚本应在构造 `$stage` 前用 `Resolve-Path` 规范化根路径，并把相对、绝对两种调用都纳入复验。 |

### 非逐字 `quoted_context` 的精确 ID

七条分别是：

- `ASRT-M2W2-AWS-INF1-NCV1-COUNT-A01-1`：把相邻标题和表格内容合成一句；
- `ASRT-M2W2-AWS-TRN1-DMA-COUNT-A05-1`：删掉原文中的 `(Direct Memory Access)`；
- `ASRT-M2W2-AWS-INF2-HBM-CAPACITY-A04-1`：把原文拼写 `memor` 静默改成 `memory`；
- `ASRT-M2W2-AWS-INF2-DMA-COUNT-A05-1`：同样删掉 `(Direct Memory Access)`；
- `ASRT-M2W2-AWS-INF2-NEURONLINK-COUNT-A05-1`：从 `2 (Inferentia2) or 4 (Trainium) NeuronLink-v2` 中删去中间分支后拼接；
- `ASRT-M2W2-AWS-TRN3-NCV4-TENSOR-CLOCK-A07-1`：使用整理者写的 `Tensor ... 2.4`，不是连续原文；
- `ASRT-M2W2-AWS-TRN3-DMA-COUNT-A07-1`：删掉 `(Direct Memory Access)`。

这些摘录也出现在 `card-draft/AWS_Inferentia1_芯片实现资料卡.md`、`AWS_Trainium1_芯片实现资料卡.md`、`AWS_Inferentia2_芯片实现资料卡.md` 和 `AWS_Trainium3_芯片实现资料卡.md`，不能只改结构化断言。

### 字段主体不一致的五组 ID

| fact_id / requirement_id | 当前主体 | 注册表允许主体 | 修正方向 |
|---|---|---|---|
| `FACT-M2W2-AWS-INF1-NCV1-VECTOR-OPS-CYCLE` / `REQ-M2W2-AWS-PKG-007` | `CMP-M2W2-AWS-INF1-VECTOR` component | `FIELD-COMP-THROUGHPUT` 只允许 `precision_path` | 建与原文精度边界一致的 precision path，或先调整字段模型；不能绕过注册表。 |
| `FACT-M2W2-AWS-INF1-NCV1-SCALAR-OPS-CYCLE` / `REQ-M2W2-AWS-PKG-008` | `CMP-M2W2-AWS-INF1-SCALAR` component | `precision_path` | 同上。 |
| `FACT-M2W2-AWS-TRN1-CC-COUNT` / `REQ-M2W2-AWS-PKG-017` | `OBJ-AWS-TRAINIUM1-CHIP` object | `FIELD-COMP-UNIT-COUNT` 只允许 `component` | 新建 Trainium1 CC-Core 组件并重映射事实、要求和卡片。 |
| `FACT-M2W2-AWS-INF2-CC-COUNT` / `REQ-M2W2-AWS-PKG-027` | `OBJ-AWS-INFERENTIA2-CHIP` object | `component` | 新建 Inferentia2 CC-Core 组件并重映射；Trainium2、Trainium3 已有同类组件先例。 |
| `FACT-M2W2-AWS-TRN3-NCV4-TENSOR-CLOCK` / `REQ-M2W2-AWS-PKG-038` | `CMP-M2W2-AWS-TRN3-TENSOR` component | `FIELD-PHY-CLOCK` 当前只允许 `object` | 该事实语义上确实是 Tensor Engine 时钟，正式 Trainium2 也已有组件时钟先例。总控应决定把字段允许主体扩为 `component`，还是另建合适字段；不能让 package 局部记录继续与注册表冲突。 |

## 已通过的语义检查

四个目标都保持在单颗芯片或单器件的 `package` 层。A01、A03、A04 中的实例芯片数，以及 A08 的 144 颗芯片、20.7 TB 高带宽内存（HBM）和 706 TB/s UltraServer 聚合量，都没有下放。架构机制仍通过四条既有 `implements_architecture` 关系复用，当前事实没有复制架构卡中的流水、同步或编程模型说明。

当前 56 条事实的单位换算、每芯片/每引擎作用域、峰值与稀疏条件、带宽聚合范围、操作计数未知项和累加精度边界，除阻断项所列部分外可以回到原文。五组冲突共有十个成员，均保留原标签：Trainium1 和 Inferentia2 各自的 820 GiB/s 与 820 GB/s；Trainium3 的 144 GiB 与 144 GB、4.9 与 4.7 TB/s、16 与 20 个集合通信核心（CC-Core）。没有先换算再选值，也没有设置 preferred fact。A06 的 2,517 MXFP8/MXFP4 TFLOPS 与 A08 的 2.52 PFLOPS 没有被静默合并，但 A08 事实仍须按 AWS-PKG-B03 补入结构化链。

23 条 AWS 实现待办（backlog）目前确实拆成 56 个互异事实，`audit/card-fact-coverage.csv` 也以 56 行一一覆盖四张卡，没有缺卡或卡外事实。`card-completeness.csv` 有 36 行，四个对象各九域。这个算术结果只说明现有集合内部闭合；修复 B02、B03 后必须重新计算，不能继续沿用 56/66/70 和九源结论。

Trainium2 没有在本包复制事实。`DEF-M2GA-ATRN2-01` 指向既有正式链；复核的复用映射（reuse map）有 110 行、109 个互异事实，其中 95 行带来源并逐条匹配正式 `fact-assertions.csv` 的 `fact_id`、`source_id` 和 `source_locator`，15 行是无 source_id 的派生事实，共涉及 12 个来源。唯一重复事实是软件 runtime 的两个正式定位，不是重复导入。

## 来源冻结、最小集与正式覆写安全性

11 份 HTML（超文本标记语言）固定件的路径、2026-08-13 访问日期、字节数和 SHA-256（256 位安全散列）均独立复算一致。A01 和 A07 的 latest/版本化页面整页哈希不同，但 article 正文逐字符相同：A01 正文长度 1,788，正文散列为 `7a543953ea484988d931750775682b6e8c18ab25e5f381cf772539a3994372a3`；A07 正文长度 31,435，正文散列为 `485f54894a039bf2c42115ac257317fe304139a29c922f267ab8670f14cb9e84`。因此这两对入口各只计一个 `source_id` 是正确的。

`audit/freeze-manifest.csv` 有 66 行，覆盖冻结目录除 manifest 自身外的全部文件；67 个文件均未在复核中改动。manifest 文件 SHA-256 为 `e4ccfce114a72c2db61be18950f0449ff7845f4148b9445fa2bf9cd80dcaa322`，按 `relative_path|sha256|bytes` 排序后计算的冻结 aggregate hash 为 `4b687fd4f67dbd3f0779ef3d33ace09ded32f219e7bc04935bae6659e7b29060`。这些散列只作为本次复核证据，不构成 DEC-025 signoff。

11 个拟正式路径都落在 `最小参考资料库/快照/AWS/PackageImplementations/2026-08-13/`，当前没有路径碰撞。九条旧 endpoint（访问入口）覆写只把远程入口的 preferred 从 `true` 改为 `false`，再追加固定快照；合并模拟后每个来源仍只有一个 preferred endpoint。这个 endpoint 方案本身安全。

来源覆写也不会使旧架构断言断链。A02、A03、A04、A05、A06、A07、A08、A10 当前分别承载 10、4、4、26、1、19、1、3 条正式断言，共 68 条；固定正文继续支持这些定位。真正不安全的是 B01 的错误 notes 和 B08 的生命周期倒退。A01 从旧架构筛选的 `redundant_covered` 改成 package 选择来源，语义变化合理，但必须以经过复核的新行落库。

反向移除不是九源最小集。A07 已覆盖 A10 声称独占的两条 1.2 TFLOPS 事实，修正证据后 A10 的 `unique_fact_count` 应为 0，package 最小集为八个来源。A09 仍列在完整反向移除清单中并标记 out of scope，这个列表结构正确，只有 B07 的理由需要改正。

20 条 `not_found` 在当前 11 份固定网页里确实没有找到封装方式、裸片/芯粒数、中介层/基板、裸片面积或晶体管数量。问题在于检索元数据夸大了已检查的来源类型；因此本报告不否定“固定语料内无值”，但不接受“计划检索已经完整完成”的现状。

## 验证记录

| 检查 | 结果 |
|---|---|
| `Test-Staging.ps1`，绝对 `RootPath` | PASS，8,322 项。 |
| `Test-Staging.ps1 -RootPath '.'` | FAIL，误报 Inferentia1 卡含外来 fact ID；见 AWS-PKG-B09。 |
| 当前正式库基线与官方 validator | 75 个对象、24 条关系、632 条事实、622 条断言、803 条字段要求；PASS，93,799 项，注册表含 323 列、488 个枚举值。 |
| 隔离临时正式合并 | PASS，101,475 项；32 张正式表前后 SHA-256 全部相同，临时目录已删除。 |
| 当前 32 张正式表规范聚合散列 | `07da52a91c4ae26e416c251f6f72a0117d6eb7d3074703de44a13461f81ebfa9`。 |

第一次隔离合并运行期间，总控正好合并 Helios，脚本因此观察到 18 张正式表变化并中止。总控确认这是同期的有意正式写入，不是 AWS 临时合并副作用。等正式库静止后重建基线并复跑，得到上表的 101,475 项 PASS 和 32 表不变结论。冻结包原报告中的 99,503 项对应 Helios 合并前基线；新旧差额完全来自正式库新增内容。

## DEC-025 生命周期处置

本裁决没有触发 accept-only 的 manifest 与 signoff 条件。所有拟追加 structured 行、三个审计 overlay 中的正式覆写行，以及四张卡，都排除在本轮 `draft → reviewed` 升级之外。`SCREEN-M2-GA-A01` 还必须先消除 `reviewed → draft` 的倒退。五组冲突及十个成员可以在以后被“结构上已复核”，但仍须保持 `needs_resolution`，不得借生命周期升级选出偏好值。

修复必须在原冻结包之外形成新版本：更新事实、断言、要求、卡片、反向移除、最小集、来源说明和两个校验器后，重新生成 freeze manifest 与 aggregate hash，再由未参与修复者独立复核。只有届时裁决为 `accept`，才能按实际拟写正式库的主键逐行生成 DEC-025 manifest，并让 signoff 同时绑定新 manifest SHA-256 与新冻结 aggregate hash。

## 写入边界与项目文档

复核过程只写了 `审计/子代理交接/m2_review_aws_package_facts.md`。冻结 staging、正式库、资料卡和全局文档均未修改；隔离临时目录已清除。已检查项目级 `README.md` 和 `AGENTS.md`，本报告只是独立验收意见，尚未改变正式项目状态、范围或运行方法，因此不应由子代理更新这两份全局文档。
