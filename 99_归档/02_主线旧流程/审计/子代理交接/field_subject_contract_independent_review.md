# 字段主体合同独立复核

复核日期：2026 年 8 月 13 日  
裁决：`accept_with_fixes`  
写入边界：只写本报告；未修改审计候选包、正式数据表、正式校验器或项目状态文档。

## 裁决

把事实主体合同与字段要求覆盖合同分开建模是成立的。`allowed_subject_kinds` 继续约束 `facts.csv`，新增 `allowed_requirement_target_kinds` 只约束 `field-requirements.csv`，可以表达“事实以后应落到组件或精度路径，但当前缺口是在整张对象卡上检索”的情况。26 个字段候选按修正后的正式数据计算，都是实际需要类型与事实主体类型的最小并集，没有额外放入未使用类型。

当前包不能直接写入正式库。四条 Trainium2 规格计算带宽比要求仍指向 NCv3（NeuronCore-v3，AWS 第三代神经计算核）单核路径，而对应派生事实已经在纠错包中迁到芯片聚合路径。候选只扩类型合同，因而会让四条错误外键通过校验。严格校验器还缺少 `value_available` 与正式事实的同目标、同字段闭环，以及 `FIELD-ID-ARCH` 的对象关系投影例外。这两项修正完成并重新生成候选后，可以进入正式迁移。

## 输入与基线

我完整读取并交叉核对了审计包的 `README.md`、`adjudication.csv`、`field-contract-proposals.csv`、`row-overlay-proposals.csv`、`validator-audit-design.md`、`Build-Adjudication.ps1`、`validation-summary.json` 和正式校验记录；同时读取正式 `fields.csv`、`facts.csv`、`field-requirements.csv`、`schema-columns.csv`、`enums.csv`、七类目标实体表、派生输入表、事实断言表、预审 CSV（逗号分隔值）及 `Validate-ResearchData.ps1`。

`validation-summary.json` 记录的 16 个输入 SHA-256（256 位安全哈希算法）与当前文件逐一相同。候选生成器在隔离副本中重新运行，输出仍为 132 行裁决、26 个字段、28 组组合和 8 行原候选迁移；四个生成文件的哈希与交付包逐字节相同。

包内正式校验记录为 93,251 项，已经落后于 Google 来源有限合并后的正式基线。独立复核时重新运行正式校验器，得到：

```text
PASS: 32-table research data model; 93378 checks executed.
Registry: 323 columns, 488 enum values.
```

这次基线变化来自本审计输入之外的来源表。上述 16 个主体合同相关输入哈希仍全部匹配，但修正版应刷新正式校验记录，不能继续把 93,251 当作当前检查数。

## 独立重算

预审 132 个“表路径 + 主键”组合全部唯一，裁决 CSV 恰好覆盖一次，没有漏项或重复项。原始统计可复现：

| 项目 | 独立重算 |
|---|---:|
| 预审行 | 132 |
| 事实 | 8 |
| 字段要求 | 124 |
| 字段 | 26 |
| “字段、实际类型、登记类型”组合 | 28 |
| 原候选 `expand_contract` | 16 |
| 原候选 `retarget_row` | 8 |
| 原候选 `no_change_with_rationale` | 108 |

124 条字段要求的状态也是 60 条 `not_applicable`、53 条 `not_found`、8 条 `value_available`、2 条 `inaccessible_evidence` 和 1 条 `conflicting_unresolved`。108 条原候选保留行由 60 条 `not_applicable`、45 条 `not_found`、2 条 `inaccessible_evidence` 和 1 条关系投影型 `value_available` 构成。

四条 Trainium2 要求补入迁移后，132 行的可执行裁决应改为：

| 裁决 | 修正后行数 |
|---|---:|
| `expand_contract` | 12 |
| `retarget_row` | 12 |
| `no_change_with_rationale` | 108 |
| 合计 | 132 |

字段层仍有 26 个候选。事实合同只改 2 个字段，另 24 个字段只改字段要求覆盖合同；多值类型都符合 `object;component;link;object_relation;precision_path;capability;topology` 的子序列。按 12 条迁移模拟后，每个候选字段的要求合同恰好等于“最终事实合同 + 当前实际要求类型”的并集，缺项和多余类型均为 0。

## 28 组逐组复核

下表的“处理”已经把四条漏迁 Trainium2 要求改正。表中“保留”表示要求目标不动，由新的要求覆盖合同承接；不表示给同类型事实授权。

| 字段 | 实际类型 → 现登记类型 | 行数 | 处理 |
|---|---|---:|---|
| `FIELD-CAP-IMPLEMENTATION-DETAIL` | object → capability | 11 | 保留 10，迁 capability 1 |
| `FIELD-COMP-ARRAY-SHAPE` | object → component | 1 | 保留 1 |
| `FIELD-COMP-EXECUTION` | object → component | 2 | 保留 2 |
| `FIELD-COMP-INSTRUCTION-TILE` | object → precision_path | 1 | 保留 1 |
| `FIELD-COMP-ISSUE-WIDTH` | object → component | 1 | 保留 1 |
| `FIELD-COMP-THROUGHPUT` | object → precision_path | 20 | 保留 20 |
| `FIELD-COMP-UNIT-COUNT` | object → component | 1 | 保留 1 |
| `FIELD-DER-COMPUTE-BW-SPEC` | precision_path → object | 8 | 事实扩合同 4，要求迁路径 4 |
| `FIELD-ID-ARCH` | object_relation → object | 1 | 保留关系投影 1 |
| `FIELD-INT-AGGREGATE-BW` | object → link | 17 | 保留 17 |
| `FIELD-INT-PROTOCOL` | object → link | 2 | 保留 1，迁 link 1 |
| `FIELD-INT-TOPOLOGY` | object → topology | 4 | 保留 4 |
| `FIELD-MEM-BIDIR-BW` | object → component | 1 | 保留 1 |
| `FIELD-MEM-CAPACITY` | object → component | 17 | 保留 17 |
| `FIELD-MEM-DMA` | object → component | 1 | 保留 1 |
| `FIELD-MEM-NAME` | object → component | 1 | 保留 1 |
| `FIELD-MEM-READ-BW` | object → component | 15 | 保留 15 |
| `FIELD-MEM-WRITE-BW` | object → component | 1 | 保留 1 |
| `FIELD-NUM-ACCUMULATION` | object → precision_path | 4 | 保留 2，迁 component 1、precision_path 1 |
| `FIELD-NUM-OPERAND-A` | object → precision_path | 3 | 保留 1，迁 component 2 |
| `FIELD-NUM-PHYSICAL-ACCUM` | component → precision_path | 1 | 保留 1 |
| `FIELD-NUM-PHYSICAL-ACCUM` | object → precision_path | 3 | 保留 2，迁 component 1 |
| `FIELD-NUM-PRODUCT` | component → precision_path | 1 | 保留 1 |
| `FIELD-NUM-ROUNDING` | object → precision_path | 2 | 保留 object 1，迁 component 1 |
| `FIELD-NUM-SCALING-GRANULARITY` | object → precision_path | 1 | 保留 1 |
| `FIELD-NUM-SPARSITY` | object → precision_path | 1 | 保留 1 |
| `FIELD-PHY-CLOCK` | component → object | 8 | 事实 4、要求 4 均扩合同 |
| `FIELD-PHY-CLOCK` | precision_path → object | 3 | 保留 3 条路径级缺口 |

60 条 `not_applicable` 是架构对象级的适用性判断。把这些行下推到某一个既有组件、链路或精度路径，会把“本卡不承载实现层定值”改成“某个下级实体不适用”。45 条保留的 `not_found` 中，大多数没有可核验的下级实体，或无法唯一选定一个下级实体。`REQ-NVG3-ROUNDING` 与 `REQ-NVG3-SCALING` 虽然各有一条泛化向量路径候选，但要求本身询问整代架构，原包标为中等置信度；保留 object 覆盖比把它们硬迁到不含完整格式语义的路径更稳妥。2 条 `inaccessible_evidence` 同样只记录对象级检索范围。

## 新要求合同的建模边界

新增 `allowed_requirement_target_kinds` 是必要的，不是对 132 行统一放宽。它应满足三条约束。

第一，120 个字段都必须有值。未受本次 26 字段影响的 94 行复制最终 `allowed_subject_kinds`；26 行使用复核后的候选。第二，`facts.csv` 只读 `allowed_subject_kinds`，字段要求只读新列。第三，要求状态还要接受更强的闭环检查。单靠“目标类型在列表中”不足以证明具体目标正确，四条 Trainium2 漏迁正是反例。

`enums.csv` 不需要修改。两个合同列是分号分隔的多值集合，不能直接套用现有单值枚举检查；正式校验器应复用七个目标外键的固定映射，并按该顺序检查非空、去重、合法值和规范排序。

## 两个字段的专项裁决

### `FIELD-PHY-CLOCK`

事实合同采用 `object;component`，要求合同采用 `object;component;precision_path`。

Trainium2 的四条时钟事实分别挂在 Tensor、Vector、Scalar 和 GpSimd 组件，固定来源 `SRC-AWS-TRN2-S02` 的 Table 11 逐引擎给出 2.4、0.96、1.2 和 1.2 GHz。四条断言均为 `direct_statement / supports / source_checked`，component 是来源直接主语。

H100 的三条要求是非 Tensor 精度路径是否绑定明确峰值频率，状态均为 `not_found`。它们证明 precision_path 是合法的要求覆盖目标，不授权 precision_path 级时钟事实。AWS Trainium3 的 Tensor Engine 2.4 GHz 候选也应挂 component。这个分离合同可以接收 AWS 局部修复，同时避免把 H100 的缺口误读成事实许可。

### `FIELD-DER-COMPUTE-BW-SPEC`

事实与要求合同均采用 `object;precision_path`。四条 Trainium2 派生事实都挂在芯片聚合精度路径，每条有一条 `derived-metrics.csv` 记录和两条派生输入，precision_path 是合法事实主体。

`FACT-AWS-TRN2-DER-BALANCE-FP8-SPARSE` 仍为 `needs_resolution / conflict_member`。它使用稀疏峰值，而字段字典当前把该指标定义为稠密峰值比；本次只确认其主体类型，不提高语义状态，也不把这个未决项写成已接受结论。后续若调整字段定义或条件集，应另开语义修复，不得借主体合同迁移顺带批准。

## 四条漏迁要求

这四条要求声称对应正式派生事实，但实际路径仍停留在 NCv3 单核层。正式事实和派生输入都已使用芯片聚合路径。

| requirement | 旧目标 | 新目标 | 对应事实 | 状态 |
|---|---|---|---|---|
| `REQ-AWS-TRN2-0175` | `PP-AWS-TRN2-TENSOR-FP8` | `PP-AWS-TRN2-CHIP-TENSOR-FP8` | `FACT-AWS-TRN2-DER-BALANCE-FP8` | `value_available / reviewed` |
| `REQ-AWS-TRN2-0176` | `PP-AWS-TRN2-TENSOR-BF16` | `PP-AWS-TRN2-CHIP-TENSOR-BF16` | `FACT-AWS-TRN2-DER-BALANCE-BF16` | `value_available / reviewed` |
| `REQ-AWS-TRN2-0177` | `PP-AWS-TRN2-TENSOR-FP32` | `PP-AWS-TRN2-CHIP-TENSOR-FP32` | `FACT-AWS-TRN2-DER-BALANCE-FP32` | `value_available / reviewed` |
| `REQ-AWS-TRN2-0178` | `PP-AWS-TRN2-TENSOR-FP8` | `PP-AWS-TRN2-CHIP-TENSOR-FP8` | `FACT-AWS-TRN2-DER-BALANCE-FP8-SPARSE` | `conflicting_unresolved / needs_resolution` |

修正版应把它们加入 `row-overlay-proposals.csv`，使 overlay 从 8 行增至 12 行。`adjudication.csv` 中这四行的动作应由 `expand_contract` 改为 `retarget_row`；字段层扩合同仍由 `field-contract-proposals.csv` 负责。

`requirement_fingerprint` 必须使用一条明确、可复算的迁移规则：

```text
requirement_id|object_id|component_id|link_id|object_relation_id|precision_path_id|capability_id|topology_id|field_id
```

空目标保留为空段。四条新指纹分别是：

```text
REQ-AWS-TRN2-0175|||||PP-AWS-TRN2-CHIP-TENSOR-FP8|||FIELD-DER-COMPUTE-BW-SPEC
REQ-AWS-TRN2-0176|||||PP-AWS-TRN2-CHIP-TENSOR-BF16|||FIELD-DER-COMPUTE-BW-SPEC
REQ-AWS-TRN2-0177|||||PP-AWS-TRN2-CHIP-TENSOR-FP32|||FIELD-DER-COMPUTE-BW-SPEC
REQ-AWS-TRN2-0178|||||PP-AWS-TRN2-CHIP-TENSOR-FP8|||FIELD-DER-COMPUTE-BW-SPEC
```

原 8 条迁移也按同一规则生成指纹。隔离副本应用 12 条迁移后，792 个要求指纹仍全部唯一。为避免合并者自行解释，修正版 overlay 应增加 `current_requirement_fingerprint` 和 `proposed_requirement_fingerprint` 两列，并由生成器逐行校验。

## 原 8 条迁移复核

原候选的 8 个新目标全部存在，且每个目标的 owner object 与旧 object 相同。LDE（LLM Decoder Engine，大语言模型解码引擎）细节迁到 `CAP-M2GA-G8T-LDE`，ICI（Inter-Chip Interconnect，芯片间互联）协议迁到 `LINK-M2GA-G8I-ICI`，TPU 8i FP4 累加迁到 `PP-M2GA-G8I-FP4`，均直接对应已建实体。

NVIDIA Groq 3 的 MXM、VXM 要求迁到相应组件。MXM 尚无可承接精确数值语义的路径；VXM 的现有 320-byte 泛化路径不等于精确数据格式路径，因此组件目标比硬挂泛化路径更准确。第一代 Groq LPU 的舍入要求迁到 MXM 组件也可接受：现有资料只说明矩阵操作末尾发生一次舍入，没有分别公开 INT8 与 FP16 的舍入模式，组件级缺口避免复制两个没有新证据的路径要求。

这 8 条迁移可以保留，字段、缺失状态、检索状态、日期、理由和行级复核状态均不得改变。

## 校验器的可执行合同

正式 `Validate-ResearchData.ps1` 应增加 `-SubjectContractMode audit|gate`。迁移演练可显式使用 `audit`，正式迁移验收后默认值必须是 `gate`，使以后新增事实和要求立即受约束。

校验规则按下面顺序执行：

1. 解析两个合同列。值必须非空、不重复、只含七种目标类型，并按固定顺序书写。合同语法错误在 audit 模式下也应阻断，因为它属于注册表结构错误。
2. 对每条事实，从唯一非空目标列得到实际类型，检查它属于 `allowed_subject_kinds`。
3. 对每条字段要求，同样检查实际类型属于 `allowed_requirement_target_kinds`。
4. 对非关系投影的 `value_available`，必须存在至少一条“七个目标列完全相同且 `field_id` 相同”的正式事实。条件集和值可以不同；字段要求只证明该目标有此字段。
5. `FIELD-ID-ARCH` 是当前唯一关系投影例外。它必须以 `object_relation_id` 为目标，所指关系必须存在且 `relation_type=implements_architecture`；不能用“所有 `value_kind=relation` 都放行”的泛规则代替明确例外。
6. `conflicting_unresolved` 必须有至少一条同目标、同字段事实。冲突成员的更细关系仍由现有冲突表管理。
7. audit 模式打印事实合同、要求合同和闭环错误明细，但不把这些问题加入退出失败；gate 模式把每条问题加入正式错误列表。报错应包含表、主键、字段、实际类型或目标和合同值。

第 4 至第 6 条是本次独立复核增加的阻断规则。当前正式库有 342 条 `value_available` 和 36 条 `conflicting_unresolved` 要求。原包 8 条迁移应用后，严格检查只报四条 Trainium2 错误；补齐四条迁移后，唯一没有对应事实的 `value_available` 是 `REQ-CAMBRICON-MLU590-ARCH-RELATION`，它按第 5 条通过对象关系投影检查。

## 隔离迁移验证

我在系统临时目录复制 32 张正式表与校验器，并用只读 junction 引用 111 份 PDF，未写正式库。先应用原 26 个字段候选、1 个 schema 新行和 8 条原 overlay：

```text
正式校验器：PASS，93514 checks，324 columns，488 enum values
增强主体合同校验器：FAIL，4 errors，3444 checks
```

这次 FAIL 是预期的负向测试，四个错误恰好是 `REQ-AWS-TRN2-0175` 至 `0178` 的同目标事实闭环缺失。再把四条要求迁到芯片聚合路径后：

```text
增强主体合同校验器：PASS，3444 checks
正式校验器：PASS，93514 checks，324 columns，488 enum values
```

最终模拟差异为：

| 正式文件 | 行数变化 | 现有或新增单元格变化 |
|---|---:|---:|
| `数据/fields.csv` | 120 → 120 | 122：新列 120 个值，事实合同 2 个值 |
| `数据/schema-columns.csv` | 323 → 324 | 新增 1 行 |
| `数据/field-requirements.csv` | 792 → 792 | 12 行、32 个单元格 |
| `数据/facts.csv` | 不变 | 0 |
| `数据/enums.csv` | 不变 | 0 |

12 条要求中，原 8 条 object 迁移各改变 `object_id`、一个新目标列和指纹，共 24 个单元格；四条 Trainium2 要求各改变现有 `precision_path_id` 和指纹，共 8 个单元格。主键、行序、业务状态和其他列均不变。

第一次运行临时迁移脚本时，Windows PowerShell 5.1 把无 BOM 的 UTF-8 脚本按本地编码读取，中文路径变成乱码并中止。这是脚本编码处理的操作错误，不是沙箱、审批或工具能力限制。改为带 BOM 的 UTF-8 后重新运行成功；失败尝试没有写候选包或正式库，也没有影响上述验证结果。

## 修正版必须完成的工作

审计候选包应先完成以下修正，再重新交给独立复核：

- `Build-Adjudication.ps1`：把四条 Trainium2 要求加入 retarget 映射；生成 12 条 overlay；增加同目标事实闭环、关系投影、指纹唯一性与显式新指纹检查。
- `adjudication.csv`：四行由 `expand_contract` 改为 `retarget_row`，填写新目标并改正“同一 precision_path”的错误说明。
- `row-overlay-proposals.csv`：由 8 行增至 12 行，增加当前和候选指纹两列。
- `field-contract-proposals.csv`：26 个字段值不变；`FIELD-DER-COMPUTE-BW-SPEC` 的证据说明要注明四条要求同时迁到芯片聚合路径。
- `validation-summary.json`、`README.md`、`validator-audit-design.md`：动作统计改为 12/12/108，记录严格闭环规则和四条迁移。
- `formal-validator-readonly-run.txt`：在当时正式基线上重跑，不再沿用 93,251。

修正后，三个生成 CSV 和摘要应重新冻结哈希；不能只手改 CSV 而不更新生成器。

## 正式迁移授权边界

完成上述修正并再次签字后，可修改的正式范围如下：

| 文件 | 允许修改 |
|---|---|
| `数据/schema-columns.csv` | 新增 `SCOL-FIELDS-CSV-013`，列名 `allowed_requirement_target_kinds`，`ordinal=13`，非空，允许分号多值，最终 `review_status=approved` |
| `数据/fields.csv` | 新增第 13 列并填满 120 行；只把 `FIELD-DER-COMPUTE-BW-SPEC.allowed_subject_kinds` 改为 `object;precision_path`，把 `FIELD-PHY-CLOCK.allowed_subject_kinds` 改为 `object;component`；26 个要求合同用修正版候选，其余 94 个复制最终事实合同 |
| `数据/field-requirements.csv` | 只改 12 个指定主键的目标列和指纹；保留 8 条 `not_found / reviewed`、3 条 `value_available / reviewed`、1 条 `conflicting_unresolved / needs_resolution` |
| `scripts/validation/Validate-ResearchData.ps1` | 加入合同语法、事实主体、要求目标、可用值闭环、冲突闭环和显式关系投影检查；正式默认 `gate` |
| `数据/facts.csv` | 不修改 |
| `数据/enums.csv` | 不修改 |

现有 120 个 field 行继续保持 `approved`。四条 Trainium2 时钟事实、四条派生事实以及全部断言、派生输入和业务状态不改。`FACT-AWS-TRN2-DER-BALANCE-FP8-SPARSE` 与 `REQ-AWS-TRN2-0178` 继续保持未决生命周期。

推荐迁移顺序是：先冻结并备份 `fields.csv`、`schema-columns.csv`、`field-requirements.csv` 和校验器；在隔离副本复现 132 条旧问题；合并新 schema 与 120 个要求合同；应用 12 条迁移；显式用 audit 模式确认三类错误均为 0；再用 gate 模式运行完整校验，并把 gate 设为默认。每一步都核对主键、行序、允许列和 SHA-256。

这项迁移应先于 AWS 四代物理对象事实包。这样 Trainium3 Tensor Engine 的 component 时钟进入正式库时，硬门已经认识 `FIELD-PHY-CLOCK` 的事实合同。如果 AWS 包先合并并局部修改了该字段，本审计包必须针对新哈希重新生成，不能照搬 `current_fact_allowed_subject_kinds=object` 的旧前提。字段合同先合并后，AWS 合并脚本也必须保留 `fields.csv` 的第 13 列，不能用 12 列候选覆盖新表头。

## 项目文档检查

根目录 `README.md` 与 `AGENTS.md` 已只读检查。它们仍记录原候选的“16 行扩合同、8 行迁主体、108 行保留”，与本复核发现不再一致。按照子代理写入边界，本报告没有修改这两份文件；主代理接收修正版裁决时应把统计改为 12/12/108，并记录四条 Trainium2 漏迁与严格校验器要求。

## 最终结论

裁决为 `accept_with_fixes`。分离事实主体与字段要求覆盖目标的建模方案、26 个字段合同、原 8 条迁移、`FIELD-PHY-CLOCK` 的双合同及 `FIELD-DER-COMPUTE-BW-SPEC` 的 precision_path 事实合同均可接受。正式合并的阻断是四条 Trainium2 要求漏迁、指纹迁移缺少显式值，以及校验器没有执行同目标事实闭环和明确的架构关系投影规则。

修正版达到 12 条 overlay、12/12/108 动作统计，增强校验器与正式校验器在隔离副本同时通过，并刷新候选哈希后，才可按本报告的正式迁移授权边界写入。当前版本不授权直接合并。