# 候选因素缺失覆盖模型独立复核

## 任务状态

待总控验收。

本轮裁决对象是 SHA-256 为 `0cea4afe94e00a360287c5df7910ed7e9fd41051d0d7eb7edd8be59b1c3155a2` 的 `r1_ga100_13_contract_repair_design.md`，重点复核其中新增 `mechanism-requirements.csv` 与 `mechanism-search-log.csv` 的方案，并把检查范围扩展到所有“尚无真实 target”的候选因素。当前方案裁决为 `reject`。它能阻止继续使用假 capability 或 topology，但没有把逐来源检索、真实实体发现后的绑定、零候选字段的适用性裁决和最小来源反向移除接成一条可验证的数据链。

建议保留“缺失结论不能创建假实体”这一原则，撤回两张机制专表，改用通用的 `factor-requirements.csv` 与 `factor-target-bindings.csv`，再让现有 `search-log.csv`、`search-results.csv` 和 `requirement-evidence.csv` 同时服务 field requirement 与 factor requirement。这个替代方案在完成本文列出的 schema 和 validator 规则后，可判为 `accept_with_implementation_tests`。

## 输入

本轮完整读取了主线 `AGENTS.md`、`研究计划.md`、`资料卡/模板.md`、正式 `schema-columns.csv`、`fields.csv`、`field-requirements.csv`、`search-log.csv`、`search-results.csv`，并核对了相关枚举、`requirement-evidence.csv` 和 `Validate-ResearchData.ps1`。设计与前序复核输入为 `r1_ga100_12_card_contract_independent_review.md`、上述 SHA 对应的 `r1_ga100_13_contract_repair_design.md` 和 `r1_contract_05_design_redteam.md`。GA100 v2 另核对了 `special-capabilities.csv`、`topologies.csv`、`capability_coverage.csv` 以及相应 requirement、search log 和 search result。

本轮没有修改设计稿、正式 32 表、GA100 staging、资料卡模板、validator、冻结名单或进度文件。结论只写入本报告。

## 已完成

### 当前机制专表仍有四个数据链断点

第一处断点在逐来源检索。设计中的 `mechanism-search-log.csv` 只有 `query_or_path` 和 `source_types_checked`，没有 `source_id`、`endpoint_id`，也没有对应的 source-level result 表。自由文本可以说明研究者打算查什么，不能作为来源版本或访问入口的外键。现有 `search-results.csv` 已经提供 `search_id → source_id` 的逐来源记录，另建一条没有 result 层的机制检索链会形成两套不同强度的审计口径。

这一断点也进入了设计伪代码。`BuildClosureSet` 把普通 requirement 的 search log 和 result 交给 source/version/endpoint 解析，却只把机制 requirement 与 search 收入 `mechanisms` 集合；后续来源解析没有接收这组机制记录。由此得到的 closure hash 可以包含“查过”这一行，同时不包含究竟查了哪个 source version 和 endpoint。

第二处断点出现在找到真实实体之后。`mechanism-requirements.csv` 的最小列只有 `object_id` 和 `mechanism_id`，没有 capability、component、link、topology 或其他真实 target 的绑定列。设计文字要求找到证据后先建真实实体，再把机制 requirement 关联到实体 ID，现有列无法保存这个关联。`value_available` 因而没有结构化闭合条件，后续 field×target 也无法证明由哪条 absence obligation 转入了真实实体链。

第三处断点是状态规则不完整。设计表复用了 `requirement_status`，正文只明确了 `not_found` 与 `not_applicable`，没有给 `not_public`、`inaccessible_evidence`、`pending_verification` 和 `value_available` 定义可执行闭合条件。`requirement_id` 在两张 requirement 表之间全局唯一、`(object_id, mechanism_id)` 复合唯一、policy 中存在该 `mechanism_id`，这些都需要项目级 validator；单表 PK 和普通 FK 不会自动提供。表内也没有 `policy_id`。policy 改版后，同一 `mechanism_id` 的既有行会失去自描述版本，只有外部 manifest hash 能间接解释。

第四处断点在选源。没有 source-level result 和 endpoint 绑定时，反向移除无法回答“移除这份来源后，`not_found` 的计划检索是否仍然成立”。现有 selected role 也没有表达候选因素缺失证据的通用角色。把这类来源归入 `architecture_mechanism` 会遗漏矩阵、向量、存储层、互联层级和 topology 实体存在性等一般因素。

### GA100 假实体显示了零 target 问题的实际范围

GA100 v2 用十一个 `CAP-R1-GA100-GAP-*` 和一个 `TOPO-R1-GA100-NVLINK-GAP` 承载缺失结论。这些行的 notes 已承认它们只是结构性 target。对应 search result 实际能够逐条列出所查的两个 source version，说明现有 `search-log.csv` 与 `search-results.csv` 已经具备可复用的检索骨架；问题来自 requirement 必须指向真实实体的合同，而非 search results 表本身。

机制专表只能覆盖这十二个假实体暴露出的部分问题。`coverage-fields.csv` 对没有任何 reachable allowed target 的 field 派生 `no_reachable_allowed_target`，这个状态本身不能说明原因。die 卡没有 topology entity 时，可能表示系统 topology 对该裸片确实不适用，也可能表示芯片侧互联层级应当存在而实体尚未发现。矩阵单元、向量单元、特殊函数单元、某级存储、主机接口、设备直连接口和 topology 都会遇到相同问题。只为 Attention、Softmax、Top-k、MoE 等机制建专表，其他零候选仍会静默停在诊断状态。

用户要求所有可能造成训练与推理差异的芯片因素进入资料卡或明确缺失裁决。这个要求需要一组独立于 reachable entity 的 card-scope obligation。模型、batch、上下文长度、MoE 通信量和 KV Cache 迁移量仍保留在 condition-set 或后续 workload 分析，不应登记成 factor obligation。

### 正式表说明新门不能继续沿用“有日志即可”

当前正式基线是 32 张表、346 条 schema-column、141 个 field、76 组枚举、557 条枚举值和 585 条 card-completeness 记录。正式表有 1,059 条 field requirement、353 条 search log 和 699 条 search result。现行 validator 对 `not_found` 只检查是否存在任意 search log，不检查 log 的 result status、review status、逐来源结果、endpoint 或 cutoff。

数据现状印证了这项差异。317 条已复核的 `not_found` requirement 中，只有 96 条能找到已复核的 `no_reliable_result` log；只有 93 条同时具有非空且全部已复核的 search result。33 条 search log 没有任何 result，其中 3 条已经标为 reviewed。`source_types_checked` 也不是受控集合：正式行同时存在分号集合、逗号自由文本和单值，GA100 v2 则以逗号为主。新的发布门必须从逐来源结果反推实际 source type，不能继续信任这列自由文本。

这些旧行是迁移输入，不应在合同上线时被误称为已经满足新门。更可控的做法是只对进入 `provisional` 或 `formal` 生命周期的 card closure 执行新规则；旧对象保持 `legacy_unreconciled`，按逐芯片工作包迁移。

### 三种方案的裁决

| 方案 | 能关闭的缺口 | 仍然缺失 | 裁决 |
|---|---|---|---|
| 新增 `mechanism-search-results.csv` 第三张专表 | 可为机制检索补 `source_id` | 没有 endpoint，找到实体后仍无 linkage，矩阵、向量、存储、互联和 topology 的零候选仍未覆盖；还复制一套已有 search result 语义 | `reject` |
| 只扩展现有 `search-log.csv`，让 field requirement 与 mechanism requirement 二选一 | 可以直接复用现有逐 source result，减少平行表 | mechanism requirement 仍过窄，也没有 0..N 真实 target binding | `reject_as_standalone` |
| 通用 factor obligation 加真实 target binding，同时复用现有 search/evidence 链 | 同时承载机制、组件类别、存储层、互联层级和 topology 的存在性裁决；找到实体后有明确 linkage | 需要 policy、两张 formal 表和五个现有列的合同迁移 | `accept_with_implementation_tests` |

若照当前设计再加一张六列的机制 search result 表，中间合同基线将从 32 表、350 列增加到 35 表、372 列，仍没有真实 target linkage。继续增加 mechanism-target binding 后表数和迁移面还会扩大。通用 factor 方案使用两张新表即可同时解决 linkage 和一般零候选。

### 最小可实施 schema

factor 表中的“factor”表示卡级必须裁决的芯片因素，包括实体类别是否存在和候选机制是否存在。policy 需要为每个 factor 固定适用对象 selector、允许的真实 target kind、target subtype selector、`value_available` 时的最小 target 数量、是否允许 `not_applicable`、最低检索 source type，以及该 factor 负责解释的 field 集合。`BuildExpectedFactorObligations` 只读取 card 对象和 manifest 外的已批准 policy，不依赖当前有没有实体。

`数据/factor-requirements.csv` 建议固定为 9 列：

| 列 | 合同 |
|---|---|
| `factor_requirement_id` | PK；使用 `REQ-FACTOR-*`；与 `field-requirements.requirement_id` 做跨表全局唯一检查 |
| `card_object_id` | 非空 FK 到 `objects.object_id` |
| `policy_id` | 非空；必须等于 manifest 的 policy ID |
| `factor_id` | 非空；必须在该 policy 中唯一命中 |
| `requirement_status` | 复用正式 `requirement_status` 枚举 |
| `applicability_reason` | `not_applicable` 必填；其他状态按规则填写 |
| `requirement_fingerprint` | 对 `card_object_id + policy_id + factor_id` 做 canonical fingerprint |
| `review_status` | 复用正式 `review_status` 枚举 |
| `notes` | 可空，只保存边界说明 |

`数据/factor-target-bindings.csv` 建议固定为 11 列：`factor_target_binding_id`、`factor_requirement_id`、七个与 facts 相同的 target 列、`review_status`、`notes`。七个 target 列每行恰好一个非空；同一 factor 可有 0..N 行 binding，因此不会把多组件或多 chiplet 压成单值。validator 还要检查 `(factor_requirement_id, target_kind, target_id)` 唯一、target 属于该卡的受控 reachability、target kind 和 subtype 满足 policy，并且真实实体已经有 policy 指定的 identity field、已接受 fact 和 assertion。名称、ID 或 notes 带 `GAP` 不能单独作为拒绝依据；缺少真实身份事实链才是硬失败条件。

现有三张来源表做以下兼容扩列：

| 表 | 变更 | 条件规则 |
|---|---|---|
| `search-log.csv` | 现有 `requirement_id` 改为 nullable，追加 `factor_requirement_id` | 两个 requirement 外键恰好一个非空；分别 FK 到 field requirement 和 factor requirement |
| `search-results.csv` | 追加 `endpoint_id`、`checked_locator_or_scope` | `endpoint_id` FK 到 source endpoint，且 endpoint 的 `source_id` 必须等于本行 `source_id`；进入新 closure 的行两列均非空 |
| `requirement-evidence.csv` | 现有 `requirement_id` 改为 nullable，追加 `factor_requirement_id`、`endpoint_id` | 两个 requirement 外键 XOR；endpoint 与 source 必须同属一个 source version |

这个方案不新增 factor 专用 search log 或 result 表。`search-results.source_id` 继续表示具体内容版本，新增 `endpoint_id` 固定实际访问入口，`checked_locator_or_scope` 保存该来源内真正检查的章节、表格、网页小标题、API 节点或全文范围。`source_types_checked` 改为派生审计列，由 search result 命中的 `sources.source_type` 按 canonical 分号顺序重算；作者填写的自由文本不再参与发布裁决。

在设计稿的 card metadata 迁移完成后，中间基线是 32 表、350 条 schema-column、140 个 field、77 组枚举和 561 条枚举值。上述两张表共 20 列，三张现有表共增加 5 列，修订后的精确合同基线应为 34 表、375 条 schema-column、140 个 field 和 77 组枚举。为让反向移除明确表达缺失覆盖来源，还应给现有 `selected_role` 增加 `coverage_obligation_evidence`，枚举值总数随之变为 562。78 个 object 和 585 条历史 completeness 行在合同迁移中保持不变；GA100 对象与 13 条 completeness 另属后续芯片事务。

### validator 发布门

factor policy、field coverage 与真实 target 要形成双向约束。validator 先独立生成 `(card_object_id, policy_id, factor_id)` 全集，并要求它与该卡的 factor requirement 集合严格相等。然后再计算 reachable target 与 field×target 候选。`coverage-fields.no_reachable_allowed_target` 只保留为诊断值；如果 policy 没有把该 field 映射到至少一个 factor，或者映射的 factor 仍为 pending，该卡不得进入 provisional 或 formal。

各状态的最小闭合条件如下：

| factor status | target binding | 来源与检索门 |
|---|---|---|
| `value_available` | 数量达到 policy 的 `min_targets_if_available` | 每个 target 有真实身份 fact/assertion；若由搜索发现，log 为 `source_confirmed`，并有 `supports_requirement` result |
| `not_found` | 0 | 至少一条 reviewed/approved 的 `no_reliable_result` log；逐 source result 非空，实际 source type 满足 policy 最低集合，结果只能是已复核的 `checked_no_support` 或不计覆盖的 `duplicate` |
| `not_public` | 0 | 至少一条 reviewed/approved 的 `supports_not_public` requirement evidence，带精确 source、endpoint 和 locator |
| `not_applicable` | 0 | policy 明确允许，结构性 predicate 成立，理由非空；policy 要求来源时再附 `supports_not_applicable` evidence |
| `pending_verification` | 0 | 只允许 draft card；可有 `planned`、`in_progress` 或 `candidate_found` log，禁止发布为 provisional/formal |
| `inaccessible_evidence` | 0 | reviewed/approved 的 `blocked` log，且至少一个逐来源 result 为 `inaccessible`，source 与 endpoint 可解析 |
| `conflicting_unresolved` | 0 | 第一版只有在独立 conflict 规则能保存相反证据时才允许；规则未实现前不得用该状态发布 factor closure |

search log 与 result 还要做状态相容检查：`candidate_found` 至少命中一个 `candidate`，`source_confirmed` 至少命中一个 `supports_requirement`，`blocked` 至少命中一个 `inaccessible`，`no_reliable_result` 不得同时出现 candidate 或 support。进入 provisional/formal closure 的 factor requirement、binding、log、result 和 evidence 均须达到 reviewed 或 approved，并由 manifest 外的独立审批文件绑定 closure hash；`prepared_by` 与审批人不能相同。

cutoff gate 使用 identity 行的 `data_cutoff_date`。factor search 的 `searched_date`、实际 endpoint 的 `access_date` 和非空 `snapshot_date` 均不得晚于 cutoff；source version 的裁决日期继续由 `source-date-policy` 确定。review 与 approval 日期可以晚于 cutoff，前提是 closure hash 证明没有引入更晚的 source version、endpoint 或 search result。validator 必须使用 search result 直接指向的 endpoint，不应根据当前 preferred endpoint 反推历史检索入口。

最小来源反向移除要把 factor closure 纳入覆盖宇宙。一次删除 source 的试算需要重新检查 factor status、policy 最低 source type、逐 endpoint 结果、target identity fact/assertion 和 field requirement。某来源只承担缺失覆盖时，以 `coverage_obligation_evidence` 进入 selection member；移除后仍能满足全部 factor 和 field closure，才可以降为未选。search result 仍指向未入选来源时，selection run 必须明确它只是非必要的检索审计输入；凡被 not-found、not-public 或 inaccessible 发布结论依赖的来源，都必须成为该 run 的 member。

### 与资料卡的连接

资料卡第 8 节的机制行和其他零 target 领域应引用 `factor_requirement_id`。找到真实实体后，同一 factor requirement 保留，状态改为 `value_available`，`factor-target-bindings.csv` 连接真实 capability、component、link 或 topology；该实体的具体属性继续走 `field-requirements.csv → facts.csv → fact-assertions.csv`。这种分层使“是否存在某类实体或机制”和“该真实实体有哪些字段”各有一个权威位置。

例如 GA100 的 Top-k factor 可以以 `not_found` 保持 0 binding，并连接两条 exact source/version/endpoint 的 checked-no-support result。若后续固定 ISA 证据确认了专用指令，则新增真实 capability 与身份事实，factor 改为 `value_available` 并增加 binding，随后为该 capability 建 implementation level、detail、limitation 和 throughput 的 field requirement。整个过程无需创建或保留 `CAP-*-GAP-*`。

die 卡没有 topology entity 时也使用同一模型。policy 先区分“芯片绑定的互联接口或路由机制”和“只属于上层部署的系统 topology”。前者是必须裁决的 factor，未找到只能写 `not_found`、`not_public`、`pending_verification` 或 `inaccessible_evidence`；后者可以在结构 predicate 成立时写 `not_applicable`。任何 topology field 的零 candidate 都必须回到这一 factor 裁决，不能只靠 `no_reachable_allowed_target` 结案。

## 验证

本轮以 Python 标准 CSV parser 读取并遍历正式 requirement、search log、search result 和 requirement evidence 全部记录，复算了行数、PK、FK 可达性、status/review 组合、逐 requirement 的 log/result/evidence 覆盖和 field×target 重复键。正式 search log 与 result 没有孤立 FK，主键也没有重复；当前弱门与新发布门之间的数量差异见上文。

设计稿 SHA-256 已在本地复算，确认为 `0cea4afe94e00a360287c5df7910ed7e9fd41051d0d7eb7edd8be59b1c3155a2`。正式表计数复算为 32/346/141/76/557/585，与前序复核一致。GA100 v2 的十一条假 capability 和一条假 topology 均已回查到对应 requirement、search log 与逐来源 result。

本轮没有 PowerShell runtime，也没有修改正式结构化数据，因此没有运行或宣称通过 Windows 三道正式硬门。这个限制不影响只读 schema 裁决；后续实现仍须在 PS5.1、PS7 和 Python 三端运行新增正负 fixture。

## 未解决

factor policy 的第一版清单仍需总控批准，尤其要确定哪些互联 topology 属于 die 卡必须裁决的芯片侧因素，哪些只属于系统部署。边界应依据对象 ownership 和可能影响训练或推理的芯片机制制定，不能按当前有没有实体倒推。

当前正式库的旧 `not_found` 行没有全部达到新 source-result 门。合同迁移需要明确 `legacy_unreconciled` 策略和逐芯片重建顺序，不能通过一次全库改 review status 把旧日志视为已补齐。正式 field requirement 还存在 29 组同 field、同七目标键重复，共 50 条额外行；新 manifest 的 exact-one 规则在作用于历史对象前，需要先裁决这些行究竟代表条件差异、版本差异还是重复 requirement。

## 建议下一步

总控若接受本裁决，应先修订 `r1_ga100_13_contract_repair_design.md` 的 B10、闭包伪代码和精确基线，把 mechanism 两表替换为 factor 两表及现有 search/evidence XOR 扩列。随后制作只含合同结构和 validator fixture 的独立事务，在隔离副本中验证零 topology、零 vector component、机制未找到、明确不适用、不可访问、晚于 cutoff、source 与 endpoint 不一致、发现真实 target 后回绑、移除必要缺失证据来源等负例。合同通过后，再从 140-field 新基线重生成 GA100，不在现有 v2 假实体上原地补丁。

## 写入文件

- `审计/子代理交接/r1_contract_06_absence_coverage_model_review.md`

## 文本复读记录

本报告按 research note 与 engineering audit 的语气编写。`report-humanizer` 单文件机器扫描无硬性命中。人工逆向复读从写入边界、未解决项、资料卡连接、validator、schema、方案比较和结论依次回看，并单独检查标题、各节首段、表格引导、转场和结尾；没有发现新的模板化表达。剩余风险是 factor policy 的内容取舍尚未由总控批准，不是文字自然度问题。
