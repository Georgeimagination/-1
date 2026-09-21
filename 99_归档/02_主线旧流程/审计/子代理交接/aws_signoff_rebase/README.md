# AWS 最终合并签字基线重签

## 结论

本轮结论为 accept。原 AWS 最终签字的 486 行授权继续有效，但执行前必须改用本目录的基线重签版；原签字、原最终报告、AWS 冻结包、正式数据表、资料卡和快照均未修改。

重签版绑定 Google TPU（Tensor Processing Unit，张量处理器）云端器件来源门合并后的当前正式基线。当前 32 张正式表的聚合 SHA-256 为：

`97ebb17a2518e3a43b18a382dcfc879c1f5e2b08118a6149c8fa984e65017453`

新的 486 行签字文件为 `aws-signoff-rebase.csv`，SHA-256 为：

`9429d80f0ba649724ed1276523df8ecfcf269e6e748b15a6cbe4dd11013b42c0`

原签字 SHA-256 `58f2368764e4fb132fe63a5acc427f22cdace7c38538270a7457e566d19bbd05` 已写入 `rebase-binding.json`；该文件也绑定 Google 最终复核 SHA-256 `51d0495c7350a8acb2ea24ffe99a1baa86282b1bdf424cd7af69e6b9b41cbdf8` 和正式验收 SHA-256 `e4368e49bc2263da19a2e6ddc8daaadc867a4449e7026476189e804b1617943a`。原签字仍是授权来源，但不能再直接用于当前基线，因为其中两个目标表的预合并哈希和全库聚合哈希已经过时。

## 基线变化怎么核实

原 AWS 报告使用的聚合算法是：把 32 张正式表按 `table_path` 排序，每行写成 `table_path|sha256`，以 LF 连接且末尾不加换行，再对无 BOM 的 UTF-8 字节计算 SHA-256。本轮沿用同一算法。

Google 正式合并前的三个文件取自其合并备份，其余 29 张表取当前正式库。这样重构出的旧聚合值是：

`0b4c6106bde7e2a62b1ffd6a0df7246ded62177d941c7fb9303a2cbac62f92bf`

该值与原 AWS 报告和原签字完全一致。把三个备份文件替换为当前正式文件后，聚合值变为 `97ebb17a…7453`。逐主键比较显示，三表只增加了一个来源家族、一个来源和六个访问入口；既有行改动为 0，删除为 0。Google 验收的五个固定网页文件也逐一通过路径、字节数和 SHA-256 核验。G15 不在这八个主键和五个文件中。

可复算明细在 `formal-baseline-hashes.csv`、`google-formal-pk-delta.csv` 和 `google-fixed-file-audit.csv`。

## AWS 与 Google 是否冲突

AWS 原签字包含 478 次写入和 8 条不写保护。AWS 写入主键与 Google 新增的 8 个正式主键交集为 0；AWS 固定文件目标与 Google 的 5 个固定文件路径交集也为 0。

两批工作都涉及 `最小参考资料库/sources.csv` 和 `最小参考资料库/source-endpoints.csv`，因此文件容器层面有两个共享路径。这不等于写入冲突：Google 在这两个 CSV 中新增的是一个 source 主键和六个 endpoint 主键，均不在 AWS 的 478 行写集中。逐路径结果见 `aws-google-conflict-audit.csv`，完整绑定见 `rebase-binding.json`。

## 签字改了什么

`old-to-new-cell-diff.csv` 逐单元格记录了原签字到重签版的变化。允许列以外的变化为 0。实际变化为：

| 列 | 改动单元格数 | 原因 |
| --- | ---: | --- |
| `formal_target_premerge_sha256` | 29 | AWS 有 9 行写 `sources.csv`、20 行写 `source-endpoints.csv`；这两个表的预合并哈希随 Google 合并更新。 |
| `formal_baseline_aggregate_sha256` | 486 | 全部授权行改绑当前 32 表基线。 |
| `notes` | 486 | 只追加 `rebase_binding=AWS-SIGNOFF-REBASE-GOOGLE-SOURCE-GATE-20260813`。 |

其余授权内容，包括 action、主键、来源哈希、写后语义、冻结哈希、原 `binding_id`、reviewer、日期和 verdict，全部保持不变。

## 隔离执行结果

重签版已在临时副本中逐行执行。执行前检查了 486 行的目标状态和 39 个唯一来源文件哈希；随后执行 457 条生命周期写入、1 个精确字段单元格更新、5 条复核后的语义收口和 15 个固定文件或资料卡复制，共 478 次授权写入，并复查 8 条不写保护。

临时副本的正式校验器通过，共执行 101,311 项检查；输出保存在 `isolated-validator-output.txt`。隔离合并后的 32 表聚合值为 `32c2fa9a40d1f98e9243c722a637079033d881fe4efcd1e9506d91f1234373a7`。隔离执行前后，真实正式库 32 表聚合值都为 `97ebb17a…7453`，表哈希变化为 0；原报告、原签字、Google 复核与验收文件、AWS 冻结来源文件的哈希变化也为 0。临时目录已经清理。

当前正式库本身另做了新鲜校验，结果为 PASS，共 93,378 项检查。

## 文件说明

- `aws-signoff-rebase.csv`：可在当前基线上执行的 486 行重签版。
- `rebase-binding.json`：原 AWS 签字、Google 最终复核、Google 正式验收、旧新基线和隔离执行结果的统一绑定。
- `old-to-new-cell-diff.csv`：逐单元格差异，便于确认授权列外变化为 0。
- `formal-baseline-hashes.csv`：当前 32 张正式表的逐表哈希。
- `google-formal-pk-delta.csv`：Google 正式三表的 8 个新增主键。
- `google-fixed-file-audit.csv`：Google 五个固定文件的字节数和哈希复核。
- `aws-google-conflict-audit.csv`：AWS 目标路径与 Google 变化的冲突检查。
- `isolated-replay-results.json`、`isolated-validator-output.txt`：隔离执行和正式校验器结果。
- `Build-Aws-Signoff-Rebase.ps1`：生成重签和差异证据的脚本。隔离执行结果存在时会拒绝覆盖已冻结产物。
- `Invoke-Aws-Signoff-IsolatedReplay.ps1`：严格执行重签、校验并清理临时副本的脚本。
- `manifest.csv`：本目录冻结产物的文件名、字节数和 SHA-256。

本轮只做基线重签，不等同于把 AWS 包写入正式库，也不裁决其他字段主体合同问题。
