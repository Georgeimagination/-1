# 验证结果

验证日期：2026-08-12。验证对象为修复后的 `M2-GHC-ARCH` staging 包；正式库只用于读取、复制和对照，没有被写入。

## 包内结构校验

实跑 `validate-staging.ps1`，结果通过。校验覆盖 24 张 staging CSV 的正式同表头、必填值、主键、与正式库临时合并时的主键碰撞、外键、受控枚举、分号禁用规则、事实与字段要求的七目标 XOR、事实文本值/数值 XOR，以及每条 `not_found` 是否有检索记录。

修复后的主要计数为：35 条 facts、35 条 assertions、80 条 field requirements、43 条 search logs、43 条 search results、36 条 card completeness 记录和 46 条 implementation backlog。条件集为空表头；派生指标、派生输入和冲突表也为空表头。

## 独立语义检查

另行按正式 `fields.allowed_subject_kinds` 复算字段目标：

| 检查项 | 结果 |
|---|---:|
| facts 与字段允许目标类型不匹配 | 0 |
| requirements 不满足“object 或字段允许类型” | 0 |
| 保留事实的断言数量不是 1 | 0 |
| 35 条 staged facts 未进入四卡追溯 | 0 |
| 已移出 fact ID 仍残留在卡片中 | 0 |
| backlog 复合 `source_id` | 0 |
| backlog 的 ISCA 2020 宽定位 `pp.1-12` | 0 |
| 非整数 `http_status` | 0 |

这里的 requirement 口径由总控确定：`field-requirements` 可以挂在上层 object，也可以挂在字段允许的具体目标上。因此，独立复核中指出的 26 条 object 挂载不按错误处理；实际错误的 9 条具体目标挂载已经修复。

## 临时正式库合并

在系统临时目录复制正式 `数据/`、`最小参考资料库/` 和官方校验器，随后按依赖顺序追加本包 staging。为复核本地 endpoint 的存在性与哈希，临时库只复制合并后实际引用的 32 个本地文件，没有建立目录联接。

官方 `Validate-ResearchData.ps1` 输出为：

```text
PASS: 32-table research data model; 46867 checks executed.
Registry: 323 columns, 488 enum values.
```

临时根目录经过路径校验后已经清理。为确认修复过程没有改动正式结构化库，又在真实项目根目录只读运行同一官方校验器，输出为：

```text
PASS: 32-table research data model; 40237 checks executed.
Registry: 323 columns, 488 enum values.
```

这些结果说明修复后的 staging 可以与当前正式库通过临时合并校验；它们不代表 staging 已经正式入库。总控实际合并后仍需在真实工作目录重跑同一校验器。