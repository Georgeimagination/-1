# 字段主体合同校验器过渡设计

状态：审计方案，未修改正式校验器、正式表或现有暂存目录（staging）。

## 当前校验器能证明什么

2026 年 8 月 13 日只读运行：

```text
PASS: 32-table research data model; 93251 checks executed.
Registry: 323 columns, 488 enum values.
```

`Validate-ResearchData.ps1` 当前会检查七个目标外键，并要求 `facts.csv` 和 `field-requirements.csv` 每行恰有一个目标。脚本第 142 至 149 行的目标顺序是 `object_id`、`component_id`、`link_id`、`object_relation_id`、`precision_path_id`、`capability_id`、`topology_id`。脚本没有读取或校验 `fields.csv.allowed_subject_kinds`。因此，上面的 93,251 项通过只能说明现行结构和外键等规则通过，不能说明字段主体合同已经闭合。

## 事实主体与要求覆盖目标要分开

`allowed_subject_kinds` 应继续只约束规范事实的主体。字段要求不仅描述已有值，也描述在哪个范围内检索过、哪里不适用、哪里存在冲突。因此，要求目标不能一律套用事实主体合同。

建议在 `fields.csv` 末尾追加第 13 列 `allowed_requirement_target_kinds`，并在 `schema-columns.csv` 增加 `SCOL-FIELDS-CSV-013`：`table_path=数据/fields.csv`、`column_name=allowed_requirement_target_kinds`、`ordinal=13`、`data_type=text`、`is_nullable=false`、`semicolon_forbidden=false`。定义应写明：“该字段的 field-requirements 合法覆盖目标类型；不授权同类型 facts。”

正式 120 个字段先逐行把 `allowed_subject_kinds` 复制到新列，再只对本包 `field-contract-proposals.csv` 中的 26 个字段应用候选值。事实合同只改两个字段：`FIELD-DER-COMPUTE-BW-SPEC` 改为 `object;precision_path`，`FIELD-PHY-CLOCK` 改为 `object;component`。其余 24 个字段保持事实合同不变，只扩要求覆盖合同。

多值类型统一按正式目标列次序书写：

```text
object;component;link;object_relation;precision_path;capability;topology
```

每个字段只保留实际需要的子集，但子集内部不得换序、重复或出现集合外值。例如，`FIELD-PHY-CLOCK` 的事实合同写 `object;component`，要求合同写 `object;component;precision_path`。

## requirement_status 的主体语义

`value_available` 的目标应能与现有事实主体或关系投影对应。`REQ-CAMBRICON-MLU590-ARCH-RELATION` 指向 `implements_architecture` 关系，属于有效的关系投影，不应为了迎合 object 事实合同而迁回对象。

`conflicting_unresolved` 应指向发生冲突的实体或精度路径。Trainium2 的计算带宽比随精度变化，因此冲突行继续指向 `precision_path`。

`not_found` 表示完成计划检索后，在指定覆盖范围内没有可靠值。如果已存在唯一且语义明确的组件、链路、能力或精度路径，应迁到该实体；本包列出 8 条这样的行。如果无法确认唯一的下级实体，object 仍是合法的检索覆盖范围，缺值本身不能作为迁主体的理由。

`inaccessible_evidence` 同样描述覆盖范围，只是已知证据暂时无法合法取得。没有正文支撑时不能为了满足合同而新造下级主体。

`not_applicable` 的目标是“不适用”判断的作用域，而不是未来事实的预计主体。它必须保留 `applicability_reason`，不能把架构卡上的 object 级不适用项机械下推到组件、链路或精度路径。本次共有 60 条：object→component 28 条、object→precision_path 16 条、object→link 15 条、object→topology 1 条。

## 108 条不迁移行如何落地

`adjudication.csv` 中 108 条 `no_change_with_rationale` 全部来自 `field-requirements.csv`，包括 60 条 `not_applicable`、45 条 `not_found`、2 条 `inaccessible_evidence` 和 1 条 `value_available`。这些行不改目标列，也不写 overlay。

它们通过新合同落地：正式合并 26 个 `allowed_requirement_target_kinds` 候选后，校验器针对 requirement 读取新列，现有目标类型就会成为合法覆盖目标。本包生成器已逐行复算，108 行全部命中候选要求合同。若只扩 `allowed_subject_kinds`，这些行虽可能暂时不报错，却会把缺失覆盖目标误当成事实主体，因此不接受这种做法。

## 校验逻辑

校验器可复用现有七目标顺序，建立“目标列→类型”映射。对两个合同列先按分号切分，再检查非空、无重复、只含七种合法类型且顺序规范。随后按表分别执行：

1. `facts.csv`：从唯一非空目标列得到实际类型，检查它属于该字段的 `allowed_subject_kinds`。
2. `field-requirements.csv`：同样得到实际类型，检查它属于 `allowed_requirement_target_kinds`。
3. 报错必须包含表路径、主键、`field_id`、实际类型和合同值，便于回到本包逐行裁决。

这项检查不能替代语义复核。特别是 8 条迁主体建议，即使旧 object 也恰好被要求合同允许，仍必须按 `row-overlay-proposals.csv` 执行；否则合同校验为零也不能证明行级目标足够精确。迁移时清空原 `object_id`、设置对应的新目标列、重算 `requirement_fingerprint`，保留 `requirement_status`、`search_status`、日期和缺失理由。

## 从审计模式（audit mode）到硬门（hard gate）

第一阶段使用审计模式。建议为脚本增加 `-SubjectContractMode audit|gate`，迁移期默认 `audit`。audit mode 执行全部检查并输出不匹配明细，但不把主体合同问题加入失败列表；其他现有错误仍正常阻断。首次启用时应能复现预审的 132 行，随后用候选合同和 8 条 overlay 做预演。

只有以下条件同时满足，才能把默认值切到 `gate`：

- `fields.csv` 的 120 行均有规范排序的要求合同，26 个候选已经独立复核并正式合并；
- 两个事实合同变更和 8 条行级迁移已合并，迁移后的外键、指纹和状态复核通过；
- audit mode 对正式库报告 0 条事实合同错误和 0 条要求合同错误；
- 现有完整校验器仍通过，且独立复核确认没有用扩合同掩盖错误主体。

进入硬门模式后，任何事实或要求的实际目标类型不在对应合同中都应加入 `$script:Errors` 并返回非零退出码。候选包预演为 0 不等于正式库已经闭合；只有上述正式变更落地并重新运行后才能下这个结论。

## `FIELD-PHY-CLOCK` 的过渡裁决

AWS（Amazon Web Services）包可以先做局部的事实合同修复：把 `FIELD-PHY-CLOCK.allowed_subject_kinds` 从 `object` 改成 `object;component`。Trainium2 的四条正式事实由固定快照 `SRC-AWS-TRN2-S02` 的 Table 11 按 Tensor、Vector、Scalar 和 GpSimd Engine 行直接给出频率；Trainium3 候选 `FACT-M2W2-AWS-TRN3-NCV4-TENSOR-CLOCK` 的主语同样是 Tensor Engine。把候选改挂芯片 object 会改变来源语义。

三条 H100 要求则询问非 Tensor 精度路径是否绑定明确峰值频率，状态都是 `not_found`。它们证明 `precision_path` 是合法的要求覆盖目标，不证明频率事实可以直接挂精度路径。因此，本次不把事实合同扩成 `object;component;precision_path`；precision_path 只进入 `allowed_requirement_target_kinds`。AWS 的局部修复可以先合并，但不得据此声称全库字段主体合同已经关闭。