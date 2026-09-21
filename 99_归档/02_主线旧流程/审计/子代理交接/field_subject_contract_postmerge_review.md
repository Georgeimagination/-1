# 字段主体合同正式迁移后独立复核

复核日期：2026 年 8 月 13 日  
裁决：`accept`  
正式迁移状态：`closed`

## 复核结论

本次只读复核没有发现未授权变化或迁移遗漏。166 行精确签字全部同时命中迁移前备份值和当前正式值，正式四文件与签字候选逐字节一致；13 个禁止写入或只读输入探针保持原哈希。显式 `audit`、显式 `gate` 和默认 `gate` 三次新鲜校验均通过，每次执行 97,920 项检查。

据此判定 `formal migration` 已闭环：字段主体合同正式迁移已经完成，没有遗留阻断。

## 读取范围与包完整性

完整读取了以下四个目录及其全部 53 个文件，共 1,251,701 字节：

- `审计/子代理交接/field_subject_contract_remediation/`
- `审计/子代理交接/field_subject_contract_remediation_independent_review/`
- `审计/子代理交接/field_contract_migration_preflight/`
- `审计/合并备份/FIELD-SUBJECT-CONTRACT-20260813/`

其中 21 个 CSV、4 个 JSON 和 6 个 PowerShell 脚本均完成全文件读取和类型解析；UTF-8 解码、CSV/JSON 解析及 PowerShell 语法解析错误均为 0。修正版 `manifest.csv` 的 31 条记录和独立复核 `manifest.csv` 的 2 条记录全部匹配当前文件。备份目录的冻结清单也通过逐文件核对。

当前正式 `数据/schema-columns.csv`、`数据/fields.csv`、`数据/field-requirements.csv` 和 `scripts/validation/Validate-ResearchData.ps1` 已完整读取，并参与下面的逐单元格和逐字节复核。

## 迁移前备份与旧基线

`backup-manifest.csv` 恰有 10 行且路径唯一，包括 4 个正式迁移前文件和 6 个项目文档更新前文件。10 份备份的字节数、SHA-256 和 `verified=true` 均与实体文件一致。SHA-256 是 256 位文件哈希，本报告用它确认文件内容是否逐字节相同。

| 正式迁移前文件 | 字节数 | SHA-256 |
| --- | ---: | --- |
| `数据/schema-columns.csv` | 68,583 | `85129e57f6ab927cac43ca820d7b8df6558516f956bb1525ffca615f66654a6b` |
| `数据/fields.csv` | 23,396 | `7cf5442800a7e453b34bbda4ac335ccf101ce5cac2dde297be657d4f56a02cae` |
| `数据/field-requirements.csv` | 273,071 | `e1df2c5584bfbaccdf4352ba8f7a7d2783250d9982473a3d15b649e5521bc62a` |
| `scripts/validation/Validate-ResearchData.ps1` | 15,816 | `66daa54b3273bbdf4f44368a9fb0791816e7e44521e645f6d47ae82f0c3d2f38` |

备份目录共有 13 个文件：上述 10 份备份，加上 `README.md`、`backup-manifest.csv` 和 `freeze-manifest.csv`。`freeze-manifest.csv` 的 12 条被记录文件也全部通过字节数和哈希复算。

使用当前其余 29 张正式表与备份中的三张旧表，按表路径排序后重新计算 32 表聚合值，得到：

`97ebb17a2518e3a43b18a382dcfc879c1f5e2b08118a6149c8fa984e65017453`

该值与独立复核签字绑定的正式旧基线完全相同，说明旧基线可由备份重构。

## 166 行精确签字与实际差异

`formal-migration-accept-signoff.csv` 有 166 行且主键唯一，裁决均为 `accept`。签字与 `formal-migration-manifest.csv` 一一对应，差异为 0；每行绑定的旧基线聚合、修正版包清单哈希和迁移清单哈希也全部一致。

逐行核对结果为 166/166 通过：165 个单元格变化都能在备份中取到签字的 `old_value`，并在当前正式表中取到签字的 `new_value`；最后一行校验器整文件替换同时命中旧备份哈希、当前正式哈希和候选文件哈希。

实际差异组成如下：

| 正式目标 | 实际差异 | 复核结果 |
| --- | --- | --- |
| `数据/fields.csv` | 120 个 `allowed_requirement_target_kinds` 新值，另有 2 个 `allowed_subject_kinds` 变化，共 122 个单元格 | 与签字一致 |
| `数据/schema-columns.csv` | 新增 `SCOL-FIELDS-CSV-013`；该行共有 11 个非空单元格，含主键 | 与签字一致 |
| `数据/field-requirements.csv` | 12 个主键、32 个目标或指纹单元格变化 | 与签字一致 |
| `scripts/validation/Validate-ResearchData.ps1` | 整文件替换 1 次 | 与签字一致 |

三张 CSV 的既有行顺序没有变化。schema 既有 323 行没有单元格变化，只新增一行；字段表仍为 120 行；字段要求仍为 792 行，没有增加、删除或重排主键。当前四个正式文件与修正版候选逐字节一致：

| 当前正式文件 | 字节数 | SHA-256 |
| --- | ---: | --- |
| `数据/schema-columns.csv` | 68,873 | `4c756065e0fc3fba175b0abeb41699ec637224aa4e8a5c9e150ff60730ce9375` |
| `数据/fields.csv` | 25,032 | `1723cd5ef441ea12c53e785a4d2e2101f81ecdc5ce10872a02152cfb6539e2ee` |
| `数据/field-requirements.csv` | 273,459 | `93c27127b6124331368e24ccec97c48620d2e85f08057d14d049d87edb91d347` |
| `scripts/validation/Validate-ResearchData.ps1` | 23,742 | `db0a62b32c6de8920056e1611bfab42dab0c0a78e46c9414f3e35f4e850f230d` |

三张当前 CSV 均为 UTF-8 无字节顺序标记，只使用 CRLF 换行并保留末尾换行。校验器为 UTF-8 有字节顺序标记，以 LF 为主，无独立 CR，且没有末尾换行；字节格式与签字候选一致。

## 裁决、合同与行级结果

132 行裁决的“表路径 + 主键”全部唯一，独立统计为 12 条 `expand_contract`、12 条 `retarget_row` 和 108 条 `no_change_with_rationale`。12 条 overlay 与 12 条迁主体裁决主键完全相同。四条 Trainium2 要求 `REQ-AWS-TRN2-0175` 至 `REQ-AWS-TRN2-0178` 已从 NCv3 单核精度路径迁到对应的 `PP-AWS-TRN2-CHIP-TENSOR-*` 芯片聚合路径；12 条迁移后的指纹均可按新目标重新计算。

字段表现有 120 行、13 列。两套合同均非空、无重复或未知类型，并按 `object;component;link;object_relation;precision_path;capability;topology` 的规范顺序书写。621 条正式事实的实际主体均在 `allowed_subject_kinds` 中，792 条字段要求的实际目标均在 `allowed_requirement_target_kinds` 中。792 个要求主键和 792 个现存指纹均唯一。

状态为 `value_available` 的要求有 342 条，`conflicting_unresolved` 有 36 条。共 378 条要求重新执行同字段、同目标事实检查，普通要求的闭合缺口为 0；`FIELD-ID-ARCH` 的唯一 `implements_architecture` 关系投影错误也为 0。

`FIELD-PHY-CLOCK` 的两套合同符合迁移设计：

- 事实合同 `allowed_subject_kinds = object;component`，现有 4 条时钟事实都挂在组件上；
- 要求合同 `allowed_requirement_target_kinds = object;component;precision_path`，现有 12 条要求覆盖对象、组件和精度路径。精度路径只用于登记缺口，不会放宽事实主体合同。

另一个发生事实合同变化的字段 `FIELD-DER-COMPUTE-BW-SPEC` 为 `allowed_subject_kinds = object;precision_path`，要求合同同样是 `object;precision_path`，实际事实和要求均在许可范围内。

## 禁止写入探针与新基线

预检清单中除四个迁移目标外还有 13 个禁止写入或只读输入探针。它们的当前字节数和 SHA-256 与迁移前基线全部一致，失败数为 0。这里包括：

- `数据/facts.csv`：`55a75c496c304062371ce38e566ee839060ee0706259b0b6e24442fb70b9ae3d`
- `数据/enums.csv`：`5864354d6cd26237ff9495e23e0121feb6a7a665f37dcbd1b00b8646e3211474`

其余 11 个探针覆盖字段主体合同全库预审、对象、组件、链路、对象关系、精度路径、特殊能力、拓扑、派生指标、派生输入和逐来源断言，也全部保持原哈希。

当前 32 表聚合值独立复算为：

`d10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff`

该值与迁移前聚合不同，变化只来自签字授权的三张正式表。校验器不属于 32 张数据表，因此它的整文件替换不进入该聚合。

## 新鲜校验

三种调用均在当前正式根目录重新执行，没有复用隔离包中的旧输出：

| 调用 | 退出码 | 检查数 | 注册表 | 结果 |
| --- | ---: | ---: | --- | --- |
| 显式 `-SubjectContractMode audit` | 0 | 97,920 | 324 列、488 个枚举值 | `SUBJECT-CONTRACT AUDIT: 0 issue(s)`，PASS |
| 显式 `-SubjectContractMode gate` | 0 | 97,920 | 324 列、488 个枚举值 | PASS |
| 不传模式参数 | 0 | 97,920 | 324 列、488 个枚举值 | 默认显示 `subject_contract_mode=gate`，PASS |

## 工具与命令错误记录

复核期间出现过几次只读命令构造错误，均归类为模型/操作者错误，不是正式数据问题：

1. 初次聚合脚本把函数命名为 `H`，与 PowerShell 的 `h`/`Get-History` 别名冲突，产生空哈希和无效聚合值。该结果已丢弃，改名后复算出上文两个有效聚合值。
2. 首次比较签字与迁移清单时，误把签字列 `action_type` 当成 `change_kind`，造成 332 条假差异。修正字段映射后差异为 0。
3. 一次只读表差异脚本在哈希表索引中漏加函数调用括号，PowerShell 解析失败；修正后得到 122、32 等实际单元格统计。
4. 一次扩展检查写错 `Where-Object` 运算符间距，并把 780 条保留旧格式的历史指纹误纳入“全部重算”范围。该输出没有用作裁决；改为按迁移授权验证 12 条 overlay 指纹后，12/12 通过，全部 792 个现存指纹也仍然唯一。
5. 曾只读探测尚不存在的 `审计/字段主体合同正式迁移验收.md`，返回路径不存在。该文件不在本次必读范围，也没有参与复核结论。

这些错误都没有写入正式数据、项目文档、备份或原审计包。没有发生用户拒绝、沙箱拒绝、审批失败、审批连接故障、远端服务错误或工具运行时故障。

## 写入边界

本代理只新增本报告：

`审计/子代理交接/field_subject_contract_postmerge_review.md`

未修改正式数据、正式校验器、项目文档、备份或修正版与独立复核包。