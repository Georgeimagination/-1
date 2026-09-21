# 字段主体合同修正版独立复核

复核日期：2026 年 8 月 13 日  
裁决：`accept`  
正式迁移状态：`ready_for_formal_migration`

## 复核范围

本次只读复核 `审计/子代理交接/field_subject_contract_remediation/`，没有修改修正版、正式表、正式校验器或项目进度。复核结果绑定该包的 `manifest.csv`：

`16d721dde2c39154d40d6c3cef6f6525ac8fd24ef5e3c7ad29c2daef94fa0239`

包内 31 条文件记录的字节数和 SHA-256（256 位安全哈希算法）全部与当前文件相同。正式迁移清单 `formal-migration-manifest.csv` 的 SHA-256 为：

`f10921f8eee6fe7dc7c2799cf9c7c753c9d9584a4efa2835d6f15fd5d03f8e25`

## 数据复核

原预审的 132 个“表路径 + 主键”均唯一，修正版恰好覆盖一次，没有漏项、重复项或身份字段变化。独立统计为 12 条 `expand_contract`、12 条 `retarget_row` 和 108 条 `no_change_with_rationale`。

12 条 overlay 与 12 条迁主体裁决逐项一致。每条当前指纹都能从正式 `field-requirements.csv` 复算，每条候选指纹也能从候选表复算；候选表的 792 个主键和 792 个指纹均唯一。除这 12 个主键外，没有其他要求行变化。`REQ-AWS-TRN2-0175` 至 `0178` 已分别迁到对应的 `PP-AWS-TRN2-CHIP-TENSOR-*` 路径，状态和生命周期没有改变。

26 个字段候选均为迁移后事实合同与实际要求目标类型的最小并集，没有缺项或多余类型。其余 94 个字段的要求合同与最终事实合同相同。事实合同只修改：

- `FIELD-DER-COMPUTE-BW-SPEC`：`object` 改为 `object;precision_path`；
- `FIELD-PHY-CLOCK`：`object` 改为 `object;component`。

迁移后的 342 条 `value_available` 和 36 条 `conflicting_unresolved` 要求都通过同字段、同目标事实检查。唯一例外是 `FIELD-ID-ARCH`；候选校验器只允许它投影到唯一存在且类型为 `implements_architecture` 的对象关系，没有泛化到其他关系字段。

## 校验器与迁移清单

候选校验器的 `audit` 模式只放宽事实主体、要求目标和事实闭合等数据语义错误。合同列缺失、空合同、空 token、重复类型、未知类型和非规范排序在 `audit` 下仍阻断。默认模式是 `gate`。

三次隔离正向校验均通过，每次执行 97,920 项检查：显式 `audit`、显式 `gate` 和默认 `gate`。六项负向测试也全部符合预期：非规范合同在 `audit` 阻断；事实类型错误与同目标事实缺失在 `audit` 报告、在 `gate` 阻断；错误的架构关系投影在 `gate` 阻断。

三份候选 CSV 均为 UTF-8 无字节顺序标记，只使用 CRLF 换行并保留末尾 CRLF。166 行正式迁移清单与候选对当前正式文件的逐单元格差异完全一致，组成是：120 个新要求合同单元格、2 个事实合同单元格、11 个非空 schema 新行单元格、32 个要求目标或指纹单元格，以及 1 个校验器整文件替换。清单外差异为 0。

## 正式基线与授权

当前正式校验器新鲜运行通过 93,378 项检查。正式 32 表聚合值为：

`97ebb17a2518e3a43b18a382dcfc879c1f5e2b08118a6149c8fa984e65017453`

复核前后六个被观察的正式文件哈希变化为 0。正式库未迁移。

精确授权写在 `formal-migration-accept-signoff.csv`。该文件有 166 行：165 行精确单元格变更和 1 行校验器整文件替换。每行绑定正式目标的迁移前哈希、候选目标的迁移后哈希、当前正式基线聚合值、修正版包清单哈希和正式迁移清单哈希。合并者只能执行 signoff 中列出的变更；任一迁移前哈希不匹配时，应停止并重新生成签字。

本次复核没有遗留阻断。正式迁移仍须按包内回滚说明先备份四个目标，再执行三种正向校验，并确认实际差异与 signoff 完全一致。

## 写入文件

本代理只新增：

- `审计/子代理交接/field_subject_contract_remediation_independent_review/README.md`；
- `审计/子代理交接/field_subject_contract_remediation_independent_review/formal-migration-accept-signoff.csv`；
- `审计/子代理交接/field_subject_contract_remediation_independent_review/manifest.csv`。

根目录 `README.md` 与 `AGENTS.md` 已只读检查。本任务只交付独立复核签字，不改变项目正式状态，因此没有修改它们。