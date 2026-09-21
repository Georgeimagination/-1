# M2-GA-ARCH 修复后验证结果

检查日期：2026-08-13。检查对象仅为 `M2-GA-ARCH` staging。正式数据表没有被修改；正式校验器是在包内临时副本上运行的。

## 包内结构与事实链

32 张 `structured/*.csv` 的表头都与正式表一致，其中 20 张有数据。当前包含 141 条事实、141 条逐来源断言和 72 条字段要求。事实与断言一一对应：缺失断言 0、孤立断言 0。141 条事实的七目标 XOR 和 `allowed_subject_kinds` 均无错误；72 条字段要求按“可挂对象，或挂字段允许的目标类型”检查，也无错误。

141 条断言已逐条回到来源核对。`raw_value_text` 和 `quoted_context` 均保存来源原文，两列完全相同 141 条；这是同一来源摘录在两个字段中的完整保存，不是把研究者规范值复制成原值。来源原值不在对应 context 内 0 条，研究者通用改写 context 0 条，缺失或含混 locator 0 条，研究者写入的“未公开、未说明、未找到”等审计否定句 0 条。唯一含 “not found” 的 direct statement 是 G03 原文本身关于 TPU v4 CMEM 的句子，不是审计判断。三条 NeuronLink 事实仅规范为设备间集合通信用途；2/4 接口数量只留在原文和 deferred 记录，未写入架构规范值，也没有推断其与 CC-Core 集成。

14 张卡都有“结构化事实明细”和九域完整度。明细合计列出 141 个 fact_id，与 `structured/facts.csv` 双向一致：遗漏 0、孤立 0、重复 0。`card-completeness.csv` 共 126 行，即 14 个对象各 9 个域，且 126 个对象/域组合全部唯一。最终独立复核指出的 7 行已由 `partial` 同步为卡片中的 `missing_public_data`；修后状态为 27 个 `complete`、14 个 `not_applicable`、69 个 `partial` 和 16 个 `missing_public_data`，结构化表与 14 张卡逐项差异为 0。

## MoE、Top-K 与 Ironwood D2D

Top-K 与专用 MoE router 已拆开。G01 第 5 页只说明 SparseCore 在 Transformer 兴起后开始承担 Top-K 等卸载，没有给出首次代际或逐代归属。因此，本包删除了 v3、v4、v5p 和 Ironwood 的 4 项逐代 capability、fact、assertion、requirement 与 search；来源原句只保存在边界记录 `M2GA-BD-005`，不得绑定任一具体代际。专用 MoE router 继续单独记录为 `not_found`。

Ironwood 架构层已无 D2D link、fact、assertion 或对应的 `value_available` requirement。D2D 相对带宽和集合通信管理机制分别保存在 `DEF-M2GA-G7X-06`、`DEF-M2GA-G7X-07`，建议目标均为 `silicon_package`。

## 来源链与选择草案

25 个来源都有一对一的来源家族和 endpoint；断言到来源、来源到家族、来源到 endpoint 的断链均为 0。11 个动态页全部保持 `dynamic_unfrozen`，并各有一条快照候选。

选择草案已按第二次修复后的 141 条事实和 141 条断言重跑，run 为 `SEL-M2GA-ARCH-20260812-R2`。25 个包内候选中入选 19 个，反向移除 A01、G04、G06、G07、G09、G12 共 6 个。入选成员与实际贡献事实的来源集合完全一致。成员理由已区分“事实唯一支持”“必要身份/版本职责”和“必要状态/版本职责”；6 个移除来源的 `source-screening` 状态、理由和 `source-coverage` 记录一致。Trainium2 的既有正式来源没有混入本包 selection run。该 run 仍为 `draft`，全库合并后还要复核。

## 固定 PDF endpoint

| endpoint | 页数 | SHA-256 | 结果 |
|---|---:|---|---|
| `END-M2-GA-G01-PRIMARY` | 13 | `d1e5d21b9959afefe574a6de839f52c094b3b7d3d481c89cd48b2e2737214465` | 匹配 |
| `END-M2-GA-G02-PRIMARY` | 12 | `3d64c6b36ec5897eef3ef3d5234e9c086d99ecf8007307aafde416ae1d40e887` | 匹配 |
| `END-M2-GA-G03-PRIMARY` | 14 | `94f08ac4cd041e46e5037876793761df8043296ac374aa5372af7afb0bdf3ce2` | 匹配 |
| `END-M2-GA-G04-PRIMARY` | 26 | `328ef921c6931a2a56dfbf06043f596ba73c21b6e4f1162754e6f11711e2132b` | 匹配 |

## 文档自然化

README、自检、验证结果、修复日志、检索轨迹和 14 张卡共 19 份中文 Markdown，均先用 report-humanizer 机器扫描，再按 shuorenhua 做人工事实保真检查。19 份机器扫描全部通过。人工回读检查了标题、首段、表格引导、转场和结尾，没有发现需要改写的套话；版本、数字、术语、路径、状态和责任归属均保持不变。

## 正式校验器临时合并

将正式 `数据/` 和 `最小参考资料库/` 复制到包内临时目录，再把 staging 片段追加到对应表；`论文/` 通过只读 junction 指向正式资料池。本轮结构修复后重新建立临时合并并运行官方 `Validate-ResearchData.ps1`，输出为：

```text
PASS: 32-table research data model; 62355 checks executed.
Registry: 323 columns, 488 enum values.
```

本次使用 2026-08-13 当前正式库重建 32 张临时合并表，并同步正式库中已存在的固定快照；官方校验器一次通过。临时合并前后复核 32 张正式 CSV 的 SHA-256，变化 0 个，本轮只修改 staging 和包内临时副本。

临时合并没有写回正式库。验证后尝试删除包内 `.validation-temp-R1`，但该删除动作因 auto-review approval connection/usage-limit failure 被拦截，返回 `Automatic approval review failed: usage limit`。这不是用户拒绝、sandbox denial 或校验失败。依照系统要求没有改走其他删除路径，因此包内临时副本 `.validation-temp-R1` 及其只读 `论文/` junction 仍留在 staging，待总控按该精确路径处理。