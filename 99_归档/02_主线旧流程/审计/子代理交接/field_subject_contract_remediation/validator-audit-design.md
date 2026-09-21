# 字段主体合同校验设计

## 目标

正式校验器候选新增 `-SubjectContractMode audit|gate`，默认值是 `gate`。事实主体与字段要求覆盖目标使用两套合同：

- `allowed_subject_kinds` 只约束 `facts.csv`；
- `allowed_requirement_target_kinds` 只约束 `field-requirements.csv`。

两套合同都只能使用 `object;component;link;object_relation;precision_path;capability;topology` 中的值，并按这一顺序书写。

## audit 与 gate 的边界

合同注册表的结构或语法错误在两种模式下都阻断。缺少 schema 列、缺少或为空的合同、空 token、重复类型、未知类型和非规范排序都属于这一类。

事实或要求的实际目标类型不在合同内，以及 `value_available`、`conflicting_unresolved` 找不到同目标同字段事实，属于数据语义错误。audit 模式打印明细但不因这些错误退出失败；gate 模式把它们加入正式错误列表。这样可以先审计旧库，再在迁移完成后启用硬门。正式候选默认 gate，不能依赖调用者显式传参。

## 同目标闭环

除架构关系投影外，`value_available` 和 `conflicting_unresolved` 都必须至少有一条正式事实同时满足：

1. `field_id` 相同；
2. object、component、link、object_relation、precision_path、capability、topology 七个目标列逐列相同。

条件集和值允许不同；本规则只证明要求所指目标确有该字段。四条 Trainium2 规格计算带宽比要求因此必须迁到对应的 CHIP-TENSOR 芯片聚合精度路径，不能停留在 NCv3 单核路径。

## 架构关系投影例外

`FIELD-ID-ARCH` 是唯一例外。它不要求复制一条关系文本事实，而是要求：

- 目标类型必须是 `object_relation`；
- `object_relation_id` 必须唯一存在；
- 关系类型必须是 `implements_architecture`。

校验器没有对其他 `value_kind=relation` 做泛化放行。

## 已执行测试

正向隔离验证均通过：

| 模式 | 退出码 | 检查数 | 结果 |
| --- | ---: | ---: | --- |
| audit | 0 | 97,920 | 0 个合同问题，完整校验 PASS |
| 显式 gate | 0 | 97,920 | PASS |
| 默认参数 | 0 | 97,920 | 默认显示 `subject_contract_mode=gate`，PASS |

负向测试覆盖了模式边界：

- 非规范合同 `component;object` 在 audit 模式退出 1，证明语法错误不会被 audit 放过；
- component 时钟事实与 `object` 合同不匹配时，audit 只报告且退出 0，gate 退出 1；
- 把 `REQ-AWS-TRN2-0175` 迁回旧 NCv3 路径时，audit 只报告闭环缺失，gate 退出 1；
- 把 `FIELD-ID-ARCH` 指向非 `implements_architecture` 关系时，gate 退出 1。

逐项结果在 `negative-test-results.csv`，原始输出保存在相应的 `negative-*.txt` 文件。
