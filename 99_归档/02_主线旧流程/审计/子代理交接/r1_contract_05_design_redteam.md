# GA100 资料卡合同修复设计独立红队复核

## 复核结论

本轮复核对象是 SHA-256 为 `a0bb667801a05a194fdeccc72c881e3a995e13cab4d882039f0187d218be8b4c` 的 `r1_ga100_13_contract_repair_design.md`。裁决为 `reject_pending_contract_fixes`：把资料截止日移出厂商事实、在现有完整度表保存卡级元数据、用工作包 manifest 建立覆盖发布门，这三个方向可以保留；当前文本还不能直接交给实现者。主要阻断并非 GA100 事实内容，而是覆盖门只验证“已列目标”，没有证明“所有应列目标已经出现”，同时截止日只被保存，没有约束实际纳入的证据。canonical 序列化也缺少足以让 PowerShell 5.1、PowerShell 7 与 Python 逐字节互认的解析细则和共同测试向量。

复算基线与设计稿一致：正式库现有 78 个对象、141 个字段、346 个列定义、557 条枚举值、585 条完整度记录；完整度记录恰好覆盖 45 个对象，每个对象 13 个领域且各有一条 identity 行。45 个对象由 29 个 architecture、8 个 package、3 个 cloud instance、2 个 module、1 个 die、1 个 rack 和 1 个 card 构成，不能当作冻结 49 芯片。冻结名单的 49 行中，归档冻结表只为 10 行给出了既有正式 `object_id`；这 10 行里有 9 行已有完整度记录，`OBJ-NVIDIA-GH100-DIE` 尚无完整度记录。`OBJ-NVIDIA-GA100-DIE` 目前仍只在 staging，不能用标签相似度批量推断其余映射。

## 覆盖全集仍缺一条决定性规则

设计稿的伪代码对 `has_applicable_target` 只要求 `count(targets) >= 1`。因此，一个允许 `precision_path` 的数值字段即使有 9 条可达 Tensor path，也可以只列 1 条 target；reachable inventory 的 hash 仍会正确，因为它绑定的是实体集合，不是 field 与实体的笛卡尔决策集合。现稿据此无法机器证明 9×12 的 108 个单元全部经过裁定。

总控提出的修正方向可以关闭这个缺口：把 `coverage-targets.csv` 定义为所有 `reachable target` 且 `target_kind` 出现在 `field.allowed_requirement_target_kinds` 中的 field×target 候选决策全集，并要求它与独立计算的 `BuildExpectedFieldTargetPairs` 集合完全相等。每行必须包含 `decision=include|exclude`、受控 `reason_code`、非空说明和复核状态；`include` 恰好命中一条同 field、同 target 的 requirement，`exclude` 不得存在该 requirement；bindings 与候选全集也必须集合相等。`coverage-fields` 的状态应由候选决策派生，不能再作为另一份可与 targets 相互背书的自报结论。这样可以消除静默漏列和“只列自己已经处理的目标”的循环自证。

这个修正还需要一层位于 manifest 之外的 coverage policy。仅要求每个候选 `include/exclude`，仍允许作者把 8 条未处理的 path 全部标成 `exclude`。GA100 的 12 个数值字段对 9 条已确认 Tensor path 都属于必须裁定的单元，必须标为 `mandatory_include`；即使最终结论是不适用，也要以 `include + exact-one not_applicable requirement` 落盘，不能用 exclude 省掉 requirement。建议由验证器版本化保存这组规则，或在 `fields.csv` 增加受控的展开策略与 target 选择器。它不能放在同一个工作包 manifest 中由作者自行声明。

对其他 field×target 候选，`exclude` 只表示“字段合同允许这种 target kind，但该具体实体不满足更细的语义选择器”，例如 memory field 面对 compute component。reason code 至少要区分 `target_subtype_mismatch`、`wrong_owner_scope`、`architecture_only_not_implementation`、`implementation_only_not_architecture` 和 `explicit_card_scope_exclusion`。`not_public`、`not_found`、`not_applicable` 不是 exclude reason；它们是已适用目标的 requirement 裁决。每条 exclude 必须为 `approved`，并受独立签字约束，否则全候选表只是把漏项改名为排除项。

## `scope_id` 不能只靠当前表内唯一

设计稿提出的 `SCOPE-001` 至 `SCOPE-049` 在当前 49 行中可以做到唯一，也能避免 Ascend 950 Die、950PR、950DT 共享设计组造成的一对多歧义，但“当前表唯一”不能证明 ID 永不复用。删除一行后再把空出的编号赋给新对象，常规验证仍会通过。按物理行序首次编号也没有继承归档冻结表已经审过的行身份。

更稳妥的实现是直接沿用归档冻结表的 `freeze_row_id` 作为 scope ID，或建立一次性的显式迁移清单，把 49 个 `freeze_row_id`、新 `scope_id`、冻结名单行和正式 `object_id` 一一签字绑定。若仍采用 `SCOPE-nnn`，分配规则必须是 `max(所有现役和退役 ID)+1`，范围行不得物理删除，退役只改状态；验证器还要读取不可回写的迁移清单或 tombstone registry，防止换号和复用。

首次迁移不能按中文名称自动匹配 78 个正式对象。当前能够无歧义继承的是归档冻结表中已有 `existing_formal_object_id` 的 10 行；GA100 则由本工作包新增对象显式绑定。其余行保持未映射，等各芯片工作包通过身份门后再填写。迁移清单应至少记录旧冻结行 ID、scope ID、正式 object ID、映射状态、判定依据、复核者和复核日期，并验证 object ID 在全表不重复。这样才能把 49 scope、78 个现有对象和 45 个完整度对象安全分开，而不是用三个数量接近的集合互相猜测。

`objects.scope_id` 与 identity 行的 `scope_id` 都应设置 `semicolon_forbidden=true`，并由项目规则检查格式、唯一命中与相等关系。设计稿给出的 `false` 不符合项目对标识符单值化的既有做法。两者为空时只能解释为“尚未映射”；一旦 objects 行有 scope ID，同对象 identity 行必须在同一事务写入相同值。

## 扩列可以兼容通用校验器，但不能只依赖 schema 行

`Validate-ResearchData.ps1` 的表头、必填、枚举、PK 和 FK 检查由 `schema-columns.csv` 驱动，所以只要正式 CSV 与 schema 在同一原子事务扩列，`card-completeness.csv` 增加 3 列、`objects.csv` 增加 1 列不会破坏通用表头门。`Test-ChipScope.ps1` 按属性名读取对象列，也不会因为末尾新增列失效。迁移后的基线应是 350 个列定义、140 个字段、77 个枚举组和 563 条枚举值；585 条历史完整度行数量不变，GA100 的 13 行正式合并后才增至 598。所有当前 README、AGENTS、研究计划、字段字典和状态页中的旧计数要随合同事务更新，旧审计快照不改写。

通用校验器目前不验证 schema 中的 `date` 类型，也不表达 `(object_id, domain)` 复合唯一、每对象恰一条 identity、非 identity 元数据必须为空、scope ID 跨 Markdown registry 解析、生命周期条件或 objects.scope_id 唯一。因此这些都必须作为显式项目规则加入验证器。还应把日期限制为真实存在的 ISO `YYYY-MM-DD`，不能只用正则检查字符串形状。

`card_lifecycle=superseded` 与“每对象恰一条 identity”存在模型冲突：同一对象的新正式卡会覆盖这条 identity，旧卡无法同时保留为 superseded。第一版可以只支持 `legacy_unreconciled`、`draft`、`provisional`、`formal` 和 `archived`，旧版本由已归档 manifest 保存；若确实需要查询卡版本历史，再引入 card revision，而不是让当前行同时承担现态和历史。

## 截止日迁移本身安全，发布约束尚未闭合

正式 `facts.csv`、`field-requirements.csv` 和 `fact-assertions.csv` 当前都没有 `FIELD-ID-DATA-CUTOFF` 记录；15 条 `FIELD-ID-STATUS` 事实只使用 `announced`、`available` 和 `cloud_available`，没有使用 `historical_anchor`。因此删除 DATA-CUTOFF field 和 `product_status.historical_anchor` 不会造成正式事实孤儿。需要同步修改的是 `fields.csv`、字段字典、产品状态枚举说明、模板的数据来源说明和当前计数文档。旧归档、范围映射和批次计划中的 `historical_anchor` 是研究纳入角色或历史审计文字，不属于 `product_status` 外键，不能做全库字符串替换。

活动中的 GA100 v2 staging 仍有 141 行 field coverage summary，辅助校验器也硬编码 141；合同批准后应从新 140-field 基线重新生成 staging，不能在当前生成过程中原地补丁。`source-screening.csv` 中“141 条事实”等历史批次数量同样不是字段总数，不应误改。

现稿只验证 identity 行存在 `data_cutoff_date`，没有证明本卡实际使用的证据遵守该日期。若资料截止日的定义是“允许纳入本卡的最新证据观察或固定版本日期”，发布门至少要满足：`prepared_date >= data_cutoff_date`；本卡 selection run 的 `cutoff_date` 与 identity cutoff 相等；支撑 fact、not-public、inaccessible 和搜索结论的 source version、endpoint snapshot/access 与 search-log 日期不得越过 cutoff；晚于 cutoff 的复核日期可以存在，但不得借此引入更晚内容。具体选择 publication、snapshot、access 或 effective date 作为不同来源类型的裁决日期，要在一张来源类型规则表中固定，不能由每个 manifest 自选。

manifest 还应绑定本卡实际闭合链的 canonical set hash，包括 requirement、被采用的 fact、fact assertion、search log、requirement evidence 和必要的 source/version/endpoint 行。否则一个已经写成 `approved` 的 manifest 可以在事实值或缺失证据被替换后继续复用，只要粗粒度状态仍满足伪代码。审批信息也不能只有自报的 `review_status=approved`；应加入 prepared_by、reviewed_by、reviewed_date，或绑定独立签字文件。

## reachability 与 exact-one 的合法边界

GA100 当前有一条 `implements_architecture` 投影到 Ampere，按一条关系实现没有问题；合同不应把“唯一 architecture relation”写成所有芯片的永久全局假设。多 chiplet package 可能合法投影到多个 architecture 对象，也可能暂时没有可接受的投影。manifest 应显式列出经审查的 projection relation ID 集，GA100 要求恰好一条，通用遍历允许 0..N，并把集合变化纳入 inventory hash。

遍历方向必须固定为从 card object 出发的 subject-side relation，只跟随 manifest 允许的 projection relation，不能从共享 architecture 反向吸入后来新增的其他芯片。component 要递归纳入 parent chain；precision path 由 component 所有；link、capability 和 topology 按 owner 与端点的单向规则纳入，并设置 visited set 防环。row binding 的最后一个 node 必须就是 coverage target，`resolved_table_path`、PK 和 row hash 必须与该最后节点一致。中间节点内容由 reachable inventory set hash 绑定。

exact-one requirement 对普通 target-field 是合理的，因为 requirement 表没有 condition 维度，多条件值留在 facts。实现时还要补四条细则：coverage target 和 requirement 的 target 七列逐字相同；requirement、coverage target、coverage field 与 exclude 决策均达到发布要求的复核状态；`value_available` 和 `conflicting_unresolved` 所用 fact 及 assertion 必须达到正式状态；`not_public` 必须命中 `supports_not_public` evidence，`inaccessible_evidence` 必须同时有 `search_status=blocked` 和 reviewed blocked log，不能让任意 evidence relation 或 draft log 过门。

`FIELD-ID-ARCH` 是现有通用校验器已经承认的例外：它以 `implements_architecture` 的 object_relation 投影，不要求同 target 的普通 fact。设计稿的 `requirement_is_closed` 目前把所有 `value_available` 都送入 same-target fact 检查，会误拒绝这条合法关系，必须保留该例外。`not_found` 也要核对 completed search、reviewed/approved 的 `no_reliable_result` log、日期和本卡 cutoff；仅“存在任意 search log”不够。

## canonical 序列化还需要可执行的跨运行时规范

规范选择 UTF-8 原字节、JSON 固定键序、UTF-8 byte sort、不转义 U+2028/U+2029，是可以实现逐字节一致的；不能直接依赖 PowerShell `ConvertTo-Json`、Python 默认 `json.dumps`、`Sort-Object` 或默认文本编码。PowerShell 5.1 没有 `System.Text.Rune`，默认 JSON 和 CSV 行为也与 PowerShell 7 不完全相同。当前正式 CSV 多为无 BOM 的 UTF-8 与 CRLF，现有 `Validate-ResearchData.ps1` 的若干 `Import-Csv` 调用没有显式编码；canonical 实现必须另用 strict UTF-8 decoder，不能继承平台默认值。

实施前必须补齐这些规范：拒绝非法 UTF-8、正文中 BOM 和未配对 surrogate；合法 supplementary-plane 字符按 Unicode scalar 编成四字节 UTF-8；明确 CSV 的换行是在解析前全局规范化，或者直接禁止 cell 内嵌 CR/LF；canonical writer 对控制字符统一写小写 `\u00xx`，不要让标准库自行选择 `\n` 等短转义；JSON 重复 key、大小写碰撞 key、未知 key、浮点和非 canonical 原始字节一律拒绝；manifest 解析后重新生成 canonical bytes，并要求与磁盘原字节完全相等；集合排序使用显式 UTF-8 byte comparer，不使用 locale 或 PowerShell 字符串排序。

Markdown 表还需定义 pipe 语法。建议只把未转义的 `|` 当分隔符，`\|` 两个原始字符保留在 cell 值中；含未转义内部 pipe、跨行 cell、无法闭合的链接或 code span pipe 直接拒绝，而不是猜测渲染结果。长期更稳的方案是 scope registry 使用受控 CSV，Markdown 只做显示；若坚持 Markdown 为唯一 registry，就必须把这套受限语法写进合同。

三种运行时要共享一组 golden fixtures，至少包含中文、前后空格、空值与 `null`、引号、反斜杠、斜杠、U+0000/U+000A、U+2028/U+2029、一个 supplementary-plane 字符、Markdown 链接与转义 pipe、UTF-8 BOM、LF/CRLF/CR、重复 JSON key 和未配对 surrogate。PowerShell 5.1、PowerShell 7 与 Python 必须分别生成同一 canonical bytes 和 SHA-256；负例也要三端一致拒绝。当前 macOS 没有 PowerShell runtime，因此本轮只能审查规范，不能声称已经完成跨运行时一致性证明。

## 下一芯片与 9×12 口径

若按单 scope row hash、单 card object row hash、只沿 GA100 出边构造的 reachable inventory 实施，下一芯片只新增自己的 scope、object、component、path、fact 和 requirement，不会使 GA100 失效。常规验证不能继续硬编码“恰有 49 个 scope”；49 只用于首次迁移验收。新增 unrelated scope row也不能进入 GA100 的 scope row hash。字段、覆盖相关 schema、gate enum 或 GA100/Ampere 可达实体变化则有意触发 GA100 复审。共享 Ampere 的另一芯片新增反向 relation 不得进入 GA100 遍历，否则“下一芯片不使 GA100 失效”的承诺不成立。

9×12 的字段口径与当前字段字典一致：A、B、product、程序员可见 accumulation、physical accumulation、output、rounding、scaling mode、scaling granularity、saturation、subnormal 和 sparsity，共 12 个 field。合并视图中的 9 条目标应按唯一 `precision_path_id` 计算，不能按 label 去重；现有正式 Ampere path 与 GA100 v2 的新增/更新合并后应恰为 9 个。`61+12=73` 只是某次 staging 快照的最低未闭合数，不能写成永久门。永久门应验证 108 个 mandatory decision 全部存在，每个都 exact-one requirement，并由 status 决定 fact、search、evidence 或 applicability reason 的闭合方式。

## 实施裁决

在开始正式合同事务前，必须完成以下修订：把 coverage targets 改成独立计算的全候选决策全集，并为 9×12 建立 manifest 外的 mandatory-include policy；补齐 scope ID 的不可复用机制和 49→10→45 显式迁移清单；把 cutoff 接到 selection/source/search 的日期门；让 manifest 绑定 closure set 与独立审批；明确 0..N architecture projection、遍历方向和 `FIELD-ID-ARCH` 例外；完成 strict canonical parser/writer、Markdown pipe 规则和三运行时 golden fixtures；把 schema 基线、枚举基线、日期条件和 scope 条件写入 validator 测试。以上完成后，设计方向可改判为 `accept_with_implementation_tests`。

可以延后的只有 card revision 历史查询、新建第 33 张长期 coverage 表、对 45 个历史混合对象追溯补齐正式 manifest，以及把 Markdown scope registry 迁成正式 CSV。它们不能削弱 GA100 首个正式 manifest 的全集相等、mandatory include、证据截止日和跨运行时 hash 门。

## 验证与复读

本轮只新增这份红队报告，没有修改正式 32 表、正式模板、冻结名单、validator、进度文件或任何 GA100 staging。已逐项复算正式 headers、对象/完整度分布、字段与枚举计数、DATA-CUTOFF 和 product status 的正式引用、GA100 v2 的 9×12 closure 行，并对设计稿的发布门从输出向输入逆向复读。

报告完成后按 `report-humanizer` 执行机器扫描，并人工复读标题、每节首段、表述转折和最终裁决。人工检查重点是避免把 blocker、实现建议和可延后项混在同一层级。PowerShell 三运行时一致性仍是待实施验证，不是本轮已通过结果。
