# M2-W2-TRN2-INSTANCE 自检

- 状态：`ready_for_independent_review`
- 检查日期：2026-08-13
- 检查范围：本 staging 包；正式库只读

## 计数口径

三个实例对象连同其拥有实体和主语关系共命中 49 条正式事实。`FACT-AWS-TRN2-ULTRA64-INSTANCE-QTY` 的目标是 UltraServer 部署关系，属于系统组成；显式排除后，三卡映射 48 条，分布为 4、23、21。对应 48 条正式逐来源断言均已是 `reviewed`。字段要求在排除 `REQ-AWS-TRN2-0092` 后为 51 条，分布为 5、24、22。

## 必查项

| 检查 | 预期 | 当前结果 |
|---|---:|---|
| 三张卡主对象唯一 | 3 | 通过 |
| `card-fact-map.csv` 行数 | 48 | 已生成 |
| owner 分布 | 4 / 23 / 21 | 已复算 |
| `card_id` 与 `owner_object_id` 空值 | 0 | 已复算 |
| 映射 fact_id 重复 | 0 | 已复算 |
| 卡片漏引正式 fact_id | 0 | 通过 |
| 系统事实排除 | 1 | `FACT-AWS-TRN2-ULTRA64-INSTANCE-QTY` |
| staging facts/assertions/requirements/relations | 0 / 0 / 0 / 0 | 保持空表，避免复制正式记录 |
| 九域完整度 | 27 | 已写入，三对象各 9 域 |
| S07 新 snapshot endpoint 日期 | 2026-08-13 / 2026-08-13 | 已写入 |
| endpoint merge 动作 | 1 更新 + 1 新增 | `sources/endpoint-merge-plan.csv` 已区分 |
| S07 快照本地哈希 | 匹配 | 已复算 |
| 来源筛选 | 5 | 已写入 |
| 选择运行与成员 | 1 / 4 | 已写入，均为 `draft` |
| 包内自检 | 109 项 | 错误 0 |
| 临时正式合并校验 | 1 次 | 官方校验 92,374 项通过 |

## 边界复查

卡片只记录实例级组成、峰值、内存、实例内互联、EFA、状态和缺口。Trainium2 package 与 architecture 的事实仅通过 `sources/architecture-reference-map.csv` 引用。UltraServer 的 64 芯片、4 个组成实例、跨实例 ring、系统 EFA 和状态冲突没有进入三张实例卡。

S07 的新旧原始哈希不同，但归一化 nonce 后全文相同。新 endpoint 是 `append_new_pk`，旧 endpoint 是 `update_existing_pk`；临时合并脚本必须先更新旧 PK，再追加新 PK，不得把两行都当 append。

卡片 fact_id 双向映射、32 表表头、正式外键、本地 endpoint 哈希、临时正式合并和官方校验器均已完成。中文自然化复扫完成后，本包交由未参与初稿的代理独立复核。
