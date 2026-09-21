# GA100 资料卡与 0.3 合同独立复核

## 复核范围和结论

本复核只读取主线的 `AGENTS.md`、0.3 模板和字段字典、研究计划、`fields.csv`、`enums.csv`、`schema-columns.csv`、`field-requirements.csv` 以及 `Validate-ResearchData.ps1`，并审阅 `r1_ga100_08_atomic_staging/` 与 `r1_ga100_11_card_draft/`。没有修改正式 32 表、正式模板、正式资料卡或进度文件；本文件是审计区交接材料。

结论：`reject`，暂不允许把候选卡转写为正式资料卡。已接受的 GA100 原子事实可保留；staging 报告中的主键、外键、枚举和既有 requirement 的同目标闭合也可以成立。问题在于，它没有证明“每个可能相关因素均有可追踪的事实、缺失记录或不适用裁决”。候选卡已经暴露了其中三项模板或元数据问题，但数值路径与 141 字段的缺口比候选交接说明所列的更大。

`r1_ga100_08_atomic_staging/validation_report.md` 记录的 PASS 只能说明 128 条 staged requirement 自身满足结构合同。`Validate-ResearchData.ps1` 逐行检查 requirement 的 target 合法性，并在 `value_available` 或 `conflicting_unresolved` 时要求同 target、同 field 的事实；它不从 141 个 field 反推某个 GA100 subject 或 precision path 是否应当有 requirement。因此，75 个 `coverage_only` 行不会触发现有硬门。

## 五项指定核对

### 1. 资料卡阅读层没有 `die`

这项是候选卡的填写错误，不是必须新增 `die` 阅读层枚举的正式数据合同缺口。模板在开头已明确阅读层与正式 `object_type` 分离；字段字典把 `silicon_package` 定义为“裸片、芯粒或封装内实现”，正式 `object_type` 又单列 `die`。因此 GA100 的合规写法应为：

`对象层级：silicon_package（正式 object_type：die）`。

候选卡现在写成自由文本 “full GA100 bare die design”，并称模板枚举缺 `die`，与模板规定的四个阅读层不一致。最小修复只改 GA100 候选卡头部。为避免以后重复误读，可以在模板的这一行后补一句映射说明，但不应把 `die` 加入阅读层枚举；那会把对象类型和阅读分组重新混在一起。

### 2. HBM 堆叠和 interface 不能共用一个缺失状态

正式字段已经正确拆开：`FIELD-PHY-HBM-STACKS` 与 `FIELD-PHY-HBM-INTERFACE` 是两个 object-target field。GA100 staging 也给出了不同结论：前者 `not_applicable`，因为 HBM stack 不属于 bare die 内存实体；后者是 `pending_verification`，因为 12 个 512-bit memory controller 不能无来源地相乘为 6144 bit。这两条 requirement 的主体、状态和理由均正确。

问题在于模板第 2 节仍把二者压在“HBM 堆叠和接口”一行，且占位符只允许一个“待填或不适用”状态和一个 `fact_id`。当一个字段不适用、另一个字段待核时，读者无法从该行得到无歧义状态。候选卡已拆为两行，方向正确，但与正式模板脱节。

这要求修改模板：把该行固定拆为“HBM 堆叠数量”和“HBM 总接口宽度”，各自保留条件、作用域和事实或 requirement 标识。字段字典与 32 表无需新增列；GA100 staging 的两条现有 requirement 可以直接复用。

### 3. `FIELD-ID-STATUS` 与 `FIELD-ID-DATA-CUTOFF` 的行政元数据边界

`FIELD-ID-STATUS` 的定义是产品状态，已有事实也都由厂商公开的 `available`、`announced` 等状态支撑。冻结名单中的“历史锚点”是项目的纳入角色，不是 NVIDIA 对 GA100 bare die 的销售或供货状态。把它写成 `FIELD-ID-STATUS=historical_anchor` 会把研究范围判断伪装成厂商事实；当前 staging 把它保留为 `pending_verification`，没有制造事实，这一部分是正确的。

`FIELD-ID-DATA-CUTOFF` 的问题更直接。模板已经把资料截止日放在卡片头部，字段字典却又把它设为必须有来源链的普通 object fact。`card-completeness.csv` 只有逐领域的 `assessed_date`，既不是整张卡的截止日，也没有保存卡片生命周期或冻结名单角色。现有 32 表中没有能同时表达“卡片最后核查日期”和“这是项目管理元数据、无需厂商断言”的位置。

因此这两项的合法落位应当分开处理：

| 信息 | 当前 32 表内的合法表达 | 不能做的事 | 所需修复 |
|---|---|---|---|
| 历史锚点 | 继续以冻结名单的纳入角色保存；`FIELD-ID-STATUS` 对 bare die 维持 `pending_verification`，或在总控确认其没有独立产品状态后改为 `not_applicable` | 写成有来源的 `historical_anchor` product fact | 只改 GA100 数据即可；同时应从 `product_status` 的定义中明确删去“历史锚点是产品状态”的暗示 |
| 厂商产品状态 | 有对象匹配、带日期的一手声明时，仍使用 `FIELD-ID-STATUS` 与 `fact-assertions.csv` | 用冻结名单、卡片草稿状态或资料管理员判断补值 | GA100 后续资料工程处理 |
| 资料截止日 | 目前只能作为 Markdown 卡头；`card-completeness.assessed_date` 只能说明领域评估日期 | 伪造 vendor fact 或把 `assessed_date` 当作同义截止日 | 必须修改正式数据合同：新增受控的 card metadata 记录，或把等价列明确加入现有 card-completeness 结构；随后由 GA100 写入该管理记录 |

推荐新增独立的 card metadata 记录，而不是放宽 `facts.csv` 的来源要求。最小字段为 `object_id`、`card_lifecycle`、`data_cutoff_date`、`research_role`、`scope_record_ref`、`assessed_date`、`review_status` 和 `notes`。这样厂商事实、冻结范围和卡片管理信息不会共用一个 `field_id`。在该合同落地前，候选卡必须继续显示 `pending_contract_gap`，不能称 0.3 已完整承载截止日。

### 4. 141 字段中的 `coverage_only`

`field_coverage_summary.csv` 的 141 行与正式 `fields.csv` 一一对应，这只能证明每个字段被人工讨论过，不能证明它已进入正式覆盖链。75 行的 `formal_record_ids` 恰为 `coverage_only`，并且这 75 个 field 在 GA100 staging 的 `field-requirements.csv` 中均没有 requirement。它们按领域分布为：互联 18、存储 16、身份 9、软件 9、数值 6、计算 5、派生指标 5、虚拟化 3、benchmark 2、可靠性 2。

优先处理标成 `register_not_found_after_search_log` 却没有 requirement 的条目，例如 `FIELD-NUM-PRODUCT`、`FIELD-NUM-ROUNDING`、`FIELD-NUM-SCALING-MODE`、`FIELD-NUM-SCALING-GRANULARITY`、`FIELD-NUM-SUBNORMAL`，以及多个 memory、interconnect、software 缺口。缺少 requirement 时，正式 target、`search_status`、`last_searched_date`、search log 外键和后续重新检索的闭环均无从建立；其他芯片的同字段 requirement 也不能替 GA100 承担该义务。

所以，若项目规则是“适用但缺失的字段必须进入 `field-requirements.csv`”，`coverage_only` 在 GA100 中不合规。该汇总表可以保留为审计索引，但不能替代正式 requirement。最小修复分为两层：先为 GA100 的每个适用 subject-field 建 requirement，`not_found` 必须逐条关联 search log，`not_applicable` 必须填理由，架构投影则目标指向实际的 component、precision path、capability、link 或 object relation；再扩展校验器，使其对工作包声明的 coverage target 集合检查“每个适用 field 至少有一个正式 requirement 或事实”。否则下一张卡仍可用 `coverage_only` 绕过硬门。

这不是模板文本问题，也不能只靠改候选 Markdown 解决。GA100 数据需要补 requirement、search log 和必要的 requirement evidence；为了让规则可执行，正式合同和验证脚本也需要增加 target-coverage gate。是否采用新增正式 coverage target 表，或由每个工作包的受控 manifest 提供 target 集合，由总控选择；仅保留审计区 CSV 不足以成为硬门输入。

### 5. precision path 的逐路径闭合

字段字典和模板已经列出正确维度：A、B、product、程序员可见累加、物理内部累加、output、rounding、scaling、sparsity。问题不在字段不存在，而在候选卡第 5 节把若干没有 formal target 的“未公开”写成了已登记的路径结论。

按 formal base 与 staging operations 在内存中合并后，八条 Tensor path 的 A、B 与程序员可见累加均有 `value_available` 对应事实。TF32 的 output 也有事实。其余字段没有同样闭合：

| 项目 | 已闭合内容 | 未闭合的 target-field 单元 |
|---|---|---|
| 物理内部累加 | FP16、BF16、TF32、FP64、INT8 各有 `not_found` requirement | 新的 GA100 dense FP16、INT4、Binary 三条 path 没有 requirement |
| product encoding | 无 | 八条 Tensor path 全部没有事实或 requirement |
| output | TF32 有 `FP32` 事实 | 其余七条 path 都没有 `not_found` 或其他 requirement |
| rounding | 无 | 八条 path 均未登记 |
| scaling mode / granularity | 无 | 两个字段在八条 path 上均未登记 |
| saturation / subnormal | 无 | 两个字段在八条 path 上均未登记 |
| sparsity | FP16、BF16、TF32、INT8、INT4 有与 datatype 条件绑定的值 | GA100 dense FP16、FP64、Binary 没有 value 或缺失 requirement |

按上述八条 path 和十个核心维度计数，至少有 61 个 target-field 单元既没有事实、也没有 requirement。这个数字包括现有 Markdown 明确写成 `not_found` 的 product、output、rounding、scaling、saturation 与 subnormal；它不把“同一字段在其他芯片或其他 path 已有 requirement”误算为 GA100 覆盖。另有已登记但不属于该矩阵的 Ampere CUDA FP32 scalar path；若它要在第 5 节作为数值路径出现，也必须先定义哪些数值字段对标量路径适用，不能只留下一个 physical-accumulator `not_applicable`。

最小 GA100 数据修复是建立一张 path-by-field closure 清单，并据此补全上述 61 个单元。来源没有披露时写 `not_found` 并建对应 search log；明确不适用时写 `not_applicable` 和理由；只有 source 明确给出时才建立事实。GA100 dense FP16 的“dense direct”与 Ampere FP16 的 2:4 sparse contract 还应分两条 path 或在同一 path 中以不同 condition 显式分行，不能只在 Markdown 里用一句“2:4 为架构投影”完成跨主体闭合。

## 需要修改的位置

| 类别 | 必须修改的内容 | 仅改 GA100 数据是否足够 |
|---|---|---|
| 阅读层 | 候选卡写成 `silicon_package` 加 `object_type=die`；模板可补映射说明 | 足够，模板说明属于防错增强 |
| HBM | 模板把 stacks 与 interface 拆行 | 不足；GA100 两条 requirement 已具备，模板必须同步 |
| 产品状态与截止日 | 历史锚点留在冻结名单；为资料截止日建立正式管理元数据位置，并把卡头与该位置连接 | 不足；需要正式数据合同和 schema/validator 变更，之后再写 GA100 管理记录 |
| 141 字段覆盖 | 禁止以 `coverage_only` 代替适用的 requirement，并增加 target-coverage 硬门 | 不足；GA100 先补 75 个 `coverage_only` 字段中每个适用 target 的 requirement，正式验证规则也必须补上 |
| 数值路径 | 以 path-by-field closure 清单补 61 个最小 target-field 单元及搜索记录 | 对 GA100 当前缺口足够；但将来仍应由通用 target-coverage gate 防回归 |

## 复核后的合并门

在上述 blocker 关闭前，候选卡只能作为审计阅读稿。关闭后仍须依既有事务顺序复制 19 个 payload、重跑 reverse removal、做正式 assertion review，并在 Windows 执行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1`。当前没有运行这三项正式硬门；原因是本机缺少 PowerShell runtime，属于工具运行时限制，不是已通过或被本复核替代的检查。

## report-humanizer 复读记录

机器扫描先发现一处不必要的粗体和一处对称否定句，均已改写。人工逆向复读覆盖结论段、表格导语、模板与数据边界的转折句，以及最后的合并门；最后一轮机器扫描应无硬性命中。剩余风险来自尚待总控裁决的合同取舍，文本表达没有发现新的问题。
