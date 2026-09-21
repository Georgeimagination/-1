# 字段主体合同修正版

## 结论

本包已按独立复核意见完成修正，结论为 accept，可以交给另一代理复核。正式库、原审计包、根目录项目文档均未修改。

修正版覆盖原预审的 132 个主键，仍是 26 个字段、28 个原始组合。可执行动作已经固定为：

| 动作 | 行数 |
| --- | ---: |
| `expand_contract` | 12 |
| `retarget_row` | 12 |
| `no_change_with_rationale` | 108 |

四条漏迁的 Trainium2 规格计算带宽比要求已经从 NCv3（第三代 NeuronCore）单核精度路径迁到对应的 CHIP-TENSOR 芯片聚合路径。12 条 overlay 都记录当前和候选 requirement fingerprint，生成器会逐行复算，并拒绝重复的候选指纹。

## 两套合同

事实继续使用 `allowed_subject_kinds`。字段要求新增 `allowed_requirement_target_kinds`。这样，事实主体许可不会因为对象级缺失或不适用覆盖而被放宽。

正式迁移只改两个事实合同：

- `FIELD-DER-COMPUTE-BW-SPEC`：`object` → `object;precision_path`；
- `FIELD-PHY-CLOCK`：`object` → `object;component`。

要求合同覆盖全部 120 个字段：26 个受影响字段采用逐字段候选，其余 94 个复制迁移后的事实合同。多值合同统一按 `object;component;link;object_relation;precision_path;capability;topology` 排序。

## validator 候选

本目录的 `Validate-ResearchData.ps1` 可以直接替换正式 validator。它新增 `-SubjectContractMode audit|gate`，默认是 gate，并执行以下检查：

- 合同语法：非空、无空 token、无重复、类型合法、顺序规范；
- 事实实际主体属于事实合同；
- 字段要求实际目标属于要求合同；
- `value_available` 和 `conflicting_unresolved` 存在同目标、同字段正式事实；
- `FIELD-ID-ARCH` 只允许投影到唯一存在的 `implements_architecture` 对象关系。

audit 只放宽数据语义错误，不放宽合同注册表的结构或语法错误。详细边界和测试见 `validator-audit-design.md`。

## 隔离验证

迁移从 Google 来源门合并后的当前正式基线构建。正式库原 validator 新鲜运行结果是 93,378 项检查。全新隔离根应用迁移后，三种正向验证都通过：

| 调用方式 | 结果 | 检查数 |
| --- | --- | ---: |
| 显式 audit | PASS，0 个合同问题 | 97,920 |
| 显式 gate | PASS | 97,920 |
| 不传模式参数 | PASS，显示默认 gate | 97,920 |

负向测试共 6 项，全部得到预期结果。其中非规范合同 `component;object` 在 audit 模式退出 1；事实类型不匹配和同目标闭环缺失在 audit 只报告、在 gate 阻断；`FIELD-ID-ARCH` 指向非架构实现关系时也被阻断。

三份正式 CSV 候选均为 UTF-8 无 BOM、只使用 CRLF，并保留末尾 CRLF。隔离期间六个正式基线目标文件哈希变化为 0。临时隔离根和负向测试副本在冻结前已清理。

## 正式迁移范围

可替换文件是：

- `candidate-fields.csv` → `数据/fields.csv`；
- `candidate-schema-columns.csv` → `数据/schema-columns.csv`；
- `candidate-field-requirements.csv` → `数据/field-requirements.csv`；
- `Validate-ResearchData.ps1` → `scripts/validation/Validate-ResearchData.ps1`。

精确差异见 `formal-migration-manifest.csv`：120 个新合同单元格、2 个事实合同单元格、1 个 schema 新行的 11 个非空单元格、12 条要求的 32 个目标或指纹单元格，以及 1 个 validator 文件替换。迁移前后文件哈希见 `formal-file-hashes.csv`。应用顺序和回滚方法见 `formal-migration-and-rollback.md`。

本包没有修改 `facts.csv`、`enums.csv`、断言、派生输入或生命周期状态，也不声称顺带解决其他语义问题。Trainium2 FP8 sparse 的派生事实和对应要求继续保持未决。
