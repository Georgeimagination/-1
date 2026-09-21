# M2-NA-ARCH 验证记录

> 验证日期：2026-08-12 至 2026-08-13。本记录只验证 staging 与当前正式库的可合并性，不表示总控已批准入库。

## 临时合并与正式校验器

验证时复制正式 `数据/` 与 `最小参考资料库/`，再按同名表追加本包 23 个结构化片段。临时副本只使用 staging 内的工作目录；正式 CSV 和正式资料文件均未改动。本地 endpoint 通过只读硬链接提供给副本，共 46 个，哈希复核全部一致。

第一次修复后实跑暴露出两类装配问题：29 条数值断言同时填了 `raw_value_text` 和 `raw_value_number`，另有一条已删除 Rubin NV-HBI 要求的孤儿 `requirement-evidence`。这两项均在 staging 内修正。重新生成对应临时表后，正式校验器通过：

~~~text
PASS: 32-table research data model; 75746 checks executed.
Registry: 323 columns, 488 enum values.
~~~

退出码为 0。29 条数值断言现在只在 `raw_value_number` 和 `raw_unit` 保存来源原值，行名、列名和适用对象留在短上下文及定位中，符合断言 raw value 的异或约束。孤儿 requirement evidence 已删除。

## 额外语义检查

最终 staging 有 185 条 facts、185 条 assertions 和 369 条 field requirements。检查结果如下：

| 检查 | 结果 |
|---|---:|
| facts 字段目标类型错误 | 0 |
| requirements 字段目标类型错误 | 0 |
| 每 fact 的 assertion 基数错误 | 0 |
| 孤儿 assertion | 0 |
| raw value、短上下文或定位缺失 | 0 |
| 卡片漏掉 fact_id | 0 |
| 卡片保留已删除 fact_id | 0 |
| 卡片事实值与 facts 不一致 | 0 |
| `value_available` 要求缺对应事实 | 0 |
| `not_found` 要求缺 search log | 0 |
| 派生指标复算错误 | 0 |

CDNA 4 唯一保留的派生指标使用同一张 Table 1 的 4096 与 256 FLOP/cycle/CU，复算为 16。`derived-inputs.csv` 恰有这两个输入，scope、precision 和 direction 三项检查均为 `passed`。

11 张卡共出现 185 个不重复 fact_id，与 facts 一一对应。卡片已同步 Ada 与 Rubin 软件缺口、Blackwell TMA/PTX 表述、CDNA 3 稀疏和 Infinity Fabric 表述、CDNA 4 FP8/MX/吞吐/L2 bank 修正，以及 CDNA 5 TDM、稀疏索引和 ROCm 表述。

## 独立复核修正后的重验

独立复核指出的 CDNA 5 coherent 证据、13 个组件职责和 Ampere/Ada 复合执行事实已修正。计数仍为 185 条 facts、185 条 assertions、64 个 components 和 369 条 field requirements。新增检查确认：13 个组件均有结构化职责并出现在相应卡片；三条修正断言的 raw 值、短上下文和定位均不为空；所有卡片的事实值、条件、来源和定位与结构化表一致。

重新构造临时正式副本时，第一次只为本包 14 个本地 endpoint 建立硬链接，漏了正式库已有的 11 个 endpoint，校验器因此报告文件缺失。这是临时副本装配错误。补齐 11 个只读硬链接后，官方校验器再次通过：

~~~text
PASS: 32-table research data model; 75746 checks executed.
Registry: 323 columns, 488 enum values.
~~~

退出码为 0。临时副本已删除。

## 固定资料与清理

14 个本地 endpoint 均复算 SHA-256，缺失数与哈希不匹配数均为 0。四份动态 HTML 快照的 `snapshot_date` 为 2026-08-12，均为唯一优选 endpoint；对应 source status 使用正式枚举 `current`。四份 AMD 白皮书页数分别为 17、28、21、24，登记值与文件一致。

本包不保留 `.ps1`、PDF 页图或调试图片。临时合并副本在验证完成后删除。总控实际合并后仍须在正式工作目录重跑同一校验器；临时副本通过不能替代正式入库验收。

## 字段契约局部修复重验（2026-08-13）

本轮使用正式 `fields.csv` 中已批准的 `FIELD-MEM-READ-TRANSFER-PER-CYCLE` 和 `FIELD-MEM-WRITE-TRANSFER-PER-CYCLE`，没有在 staging 复制字段表。CDNA 3 L2 读、CDNA 4 LDS 读、CDNA 4 L2 读和写的字段、规范单位、要求、指纹及卡片已同步；XCD（AMD 计算芯粒）、CU（Compute Unit，计算单元）和通道（channel）的作用域仍由原条件集承担。Blackwell Tensor Memory（TMEM）每 CTA（Cooperative Thread Array，对应一个 CUDA thread block）逻辑空间规范为 262144 byte，按 $512 \times 128 \times 32 / 8$ 直接换算，不登记为派生性能指标。

全包字段目标类型错误为 0，185 条事实和 369 条要求均能解析到正式字段；185 条事实仍各有一条符合 raw 异或、短上下文和定位合同的断言。断言文件 SHA-256 保持 `0a5ef16209e1e63b20fb89191b9bd8361082487fa7514a9080aeeb299274623b`。11 张卡仍有 185 个不重复 fact_id，字段、值、条件、来源和定位均与结构化表一致。反向移除重验仍选出 17 个必要来源，AMD CDNA 产品页的角色在成员表与角色表中都为 `architecture_mechanism`。

临时合并时追加 23 个 staging 片段，并为 46 个本地 endpoint 建立只读硬链接。副本中的 `fields.csv` 与正式表 SHA-256 同为 `7cf5442800a7e453b34bbda4ac335ccf101ce5cac2dde297be657d4f56a02cae`。正式校验器结果为：

~~~text
PASS: 32-table research data model; 75776 checks executed.
Registry: 323 columns, 488 enum values.
~~~

退出码为 0。临时副本已删除，包内没有新增 `fields.csv`。完成结构化检查后，`report-humanizer` 对包内 17 份 Markdown 的机器扫描均为 0 条命中；随后按 `shuorenhua` 复读新增段落，字段编号、公式、数值、责任主体和风险说明均保持不变。
