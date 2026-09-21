# 正式迁移与回滚说明

## 允许写入的正式文件

本包只授权迁移以下四个文件：

1. `数据/fields.csv`：追加第 13 列 `allowed_requirement_target_kinds`，120 行全部填值；另更新两个既有事实合同。
2. `数据/schema-columns.csv`：新增 `SCOL-FIELDS-CSV-013` 一行。
3. `数据/field-requirements.csv`：只修改 overlay 指定的 12 个主键。
4. `scripts/validation/Validate-ResearchData.ps1`：整文件替换为本包候选。

`facts.csv`、`enums.csv` 和其他 30 张正式表均不得修改。精确单元格清单见 `formal-migration-manifest.csv`，迁移前后文件哈希见 `formal-file-hashes.csv`。

## 应用前检查

合并者先核对四个正式文件的 premerge SHA-256 与 `formal-file-hashes.csv` 完全一致，并确认正式 validator 当前仍为 93,378 项检查。任何哈希不一致都表示基线已变化，必须停止并重新生成，不得手工套用候选。

正式 CSV 候选均为 UTF-8 无 BOM、CRLF 换行并保留末尾 CRLF。PowerShell 脚本带 BOM，只用于避免 Windows PowerShell 5.1 误读中文路径。

## 应用顺序

建议按下面顺序原子替换：

1. 备份四个正式目标文件并记录 SHA-256；
2. 写入 `candidate-schema-columns.csv`；
3. 写入 `candidate-fields.csv`；
4. 写入 `candidate-field-requirements.csv`；
5. 写入本目录的 `Validate-ResearchData.ps1`；
6. 显式运行 audit，再显式运行 gate，最后不带模式参数运行默认 gate；
7. 比较实际正式差异与 `formal-migration-manifest.csv`，不得出现清单外单元格或文件变化。

全部校验通过前，不更新项目进度，也不继续合并依赖这一合同的 AWS 包。

## 回滚

若写入、哈希或校验任一项失败，立即停止后续工作，用应用前备份逐文件恢复上述四个目标。恢复后应核对：

- 四个文件 SHA-256 回到 `formal-file-hashes.csv.formal_premerge_sha256`；
- 32 张正式表的聚合值回到迁移前基线；
- 原正式 validator 再次通过 93,378 项检查；
- 没有残留临时文件、半写入 CSV 或新进度记录。

不要试图按反向单元格补丁手工回滚 validator；四个目标文件都应从同一备份批次恢复。
