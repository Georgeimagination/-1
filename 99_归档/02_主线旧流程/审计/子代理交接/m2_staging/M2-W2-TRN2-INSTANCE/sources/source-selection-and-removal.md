# Trn2 三实例来源筛选与反向移除

## 事实集合

本轮只评估三张实例卡映射的 48 条正式事实和对应 48 条正式逐来源断言。来源分布为：`SRC-AWS-TRN2-S06` 33 条、`S07` 4 条、`S09` 1 条、`S10` 8 条、`S15` 2 条。架构与芯片事实不进入这个选择运行，UltraServer 组成事实也已排除。

选择运行使用 `SELRUN-M2W2-TRN2INST-20260813`，状态保持 `draft`。反向移除以“删去来源后是否丢失采用事实、历史冲突事实或固定状态版本”为判据。

## 反向移除结果

| 来源 | 移除结果 | 结论 |
|---|---|---|
| `SRC-AWS-TRN2-S06` | 丢失 33 条唯一直接断言 | 入选 `core_spec` |
| `SRC-AWS-TRN2-S07` | 丢失 4 条唯一直接断言 | 入选 `core_spec`；2026-08-13 快照已固定 |
| `SRC-AWS-TRN2-S09` | 丢失 `FACT-AWS-TRN2-48XL-STATUS-GA` 的固定日期证据 | 入选 `status_version_evidence` |
| `SRC-AWS-TRN2-S10` | 丢失 8 条 2024 稀疏历史事实及版本冲突链 | 入选 `conflict_evidence` |
| `SRC-AWS-TRN2-S15` | 不影响正向采用值；两条断言仍需保留为被拒绝来源的质量审计 | 不进入最小入选集；筛选状态保持 `rejected_unreliable` |

`S15` 不能登记为被 `S06` 完全覆盖，因为 512 GiB 和 8,192 GiB 是必须保留的原始错误候选，不与 S06 的采用值等价。`source-coverage.csv` 因此用 `not_equivalent` 明确这条边界。

## S07 版本判断

2026-08-13 快照的原始 SHA-256 与前一日不同，差异只在两行 CSP 和模块加载 nonce。替换 nonce 后，两份 HTML 全文相同。因此沿用 `SRC-AWS-TRN2-S07` 及原有 4 条断言，正式 source 行、`observed-2026-08-12` 版本标签和旧 `content_fingerprint` 均不改。合并时新增 2026-08-13 snapshot endpoint；旧 snapshot endpoint 是 PK 更新，`is_preferred_endpoint` 改为 `false`；新 endpoint 是 PK append，访问日和快照日都为 2026-08-13。

事实集合、S06 版本、S07 页面语义、S09 固定公告或 S10 历史冲突职责发生变化时，应重跑反向移除。当前运行不能代替独立复核。
