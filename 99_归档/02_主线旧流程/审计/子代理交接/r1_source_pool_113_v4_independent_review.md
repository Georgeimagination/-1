# 113 份 PDF 资料池 v4 操作合同独立复核

状态：`accept`

复核日期：2026-08-21。本轮只复核 `r1_source_pool_113_staging/` 的 v4 操作合同，以及它与 v3 已验收字节的连续性。正式 `论文/`、`清单/`、`scripts/`、来源表和 `进度/` 均未写入；本记录是唯一新增文件。

## 裁决

v3 的拒收项已经关闭。`operations.csv` 现有 00 至 11 共 12 个连续步骤，补齐了旧 validator 的正式 precondition、collector 与 validator 的候选及写后哈希、可核验的备份记录、post-apply preview、第二次 apply、非受控内容快照、validator 安装顺序和完整回滚边界。未发现新的 operations blocker。

本次 `accept` 的精确含义是：v4 staging 已达到可执行正式推广事务的边界，主代理可以按 00 至 11 顺序推广。它不表示正式文件已经迁移，也不表示三道 Windows hard gate 已通过。若推广前任一旧正式 target 或任一候选受控字节发生变化，现有 precondition 应停止事务，并按新字节重新复核。

## v3 字节连续性

下列七项仍与 v3 独立完整重放所用字节一致：

| 受控文件 | v4 SHA-256 |
|---|---|
| `collect_references.py` | `2a980efd45bc9846029003ca38ece6823f75f9d00d6fcbbe0137638e4c2aefcb` |
| `Test-SourcePool.ps1` | `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0` |
| `source-pool-input-ledger.json` | `08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812` |
| `frozen-legacy-pdf-manifest.csv` | `c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27` |
| `论文PDF清单.csv` | `4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab` |
| `汇总统计.json` | `994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e` |
| `formal_payload/清单/资料池受控输入/` | ledger 与 frozen manifest 分别为 `08994b24...8812`、`c8c43df6...8b27` |

formal payload 的 ledger 与 staging 根同名 ledger 逐字节相同，`cmp` 返回 0；两份 frozen manifest 也逐字节相同。v4 只改变了 `operations.csv`、`README.md` 和 `validation_report.md`，其中 operations 当前 SHA-256 为 `e8bf4895f0d376d355ad0cae507664f9911b23d5ada653ef5626440f07bbc9ea`。

因此，v3 已完成的 legacy preview、首次 apply、post-apply preview、第二次 apply、三张 registry 追加无关 GA100 行、AMD 两行 row-level binding 负向检查、三种 output-root 重叠拒绝、错误 confirmation 拒绝、两输出写入范围及 0 PDF copy 证据仍适用于当前 v4。脚本、输入和期望输出均未漂移，本轮没有重复复制 113 份 PDF 或伪造一次新的完整重放。

## 12 步正式事务

CSV 机器读取结果为 12 行，sequence 精确等于 `00, 01, ..., 11`，operation ID 无重复，10 个字段均无空值。顺序如下：

| sequence | 事务阶段 | 复核结果 |
|---|---|---|
| 00 | 四个旧目标 precondition、备份和 promotion record | 通过 |
| 01 至 03 | frozen、ledger、collector 依次安装 | 通过 |
| 04 至 07 | 独立 preview、首次 apply、post-apply preview、第二次 apply及内容快照 | 通过 |
| 08 | 安装候选 validator | 通过 |
| 09 至 11 | 资料池、芯片范围、结构化数据三道 Windows gate | 顺序正确，等待 Windows 实跑 |

sequence 00 逐项固定四个现有正式目标：旧 manifest `c8c43df6...8b27`、旧 summary `eee940c5...1db7`、旧 collector `4946da30...7b06f`、旧 validator `44756009...736f`。这些值与当前正式文件直接复算相同，`清单/资料池受控输入/` 当前也确实不存在。任一哈希不符或受控输入目录预先存在，事务都会在复制前失败。

sequence 03 对 staging collector 和正式写后 target 都要求 `2a980efd...efcb`；sequence 08 对 staging validator 和正式写后 target 都要求 `c2dc1319...fbf0`。validator 只能在 post-apply preview、第二次 apply 和非受控快照 0 diff 后安装。其后固定按 `Test-SourcePool.ps1`、`Test-ChipScope.ps1`、`Validate-ResearchData.ps1 -SubjectContractMode gate` 的顺序运行。

## 备份记录与快照边界

`backup-manifest.json` 记录四个原目标和四个实际备份的绝对路径、项目相对路径与 SHA-256，也记录实际 backup root 和受控输入目录的原存在状态。它不记录自己的哈希。完成该文件后，由单独的 `promotion-record.json` 记录其 SHA-256、实际备份目录和后续步骤结果，因此不存在 backup manifest 自引用。

第二次 apply 前后的两张 snapshot 都排除两份受控输出和两张 snapshot 文件自身。两份受控输出另行要求保持 sequence 05 的字节与哈希；snapshot 则覆盖 promotion record、backup manifest、备份文件和其余主线常规文件。promotion record 在 pre-snapshot 前已经存在，两个 snapshot 的哈希与比较结果只在比较完成后写回该记录，所以不会因记录自身的正常收尾产生假 diff；若第二次 apply 期间有任何非受控文件变化，pre/post snapshot 会不一致并触发回滚。

## 回滚与正式静态性

sequence 00 保存四个旧正式文件的逐字节备份，后续每步失败都停止推进并回到这组记录。旧 manifest、summary、collector 和 validator 全部恢复；只有 promotion record 明确证明 `清单/资料池受控输入/` 在事务前不存在时，才删除本次新建的受控输入目录。推广记录保留为失败证据。README、validation report 和 operations 对这条边界的描述一致。

复核结束时，四个旧正式目标仍分别为 `c8c43df6...8b27`、`eee940c5...1db7`、`4946da30...7b06f`、`44756009...736f`，受控输入目录仍不存在。没有发生正式推广。

## Windows 运行边界与错误分类

当前 macOS 环境没有 `pwsh`、`powershell` 或 `powershell.exe`。三道 Windows hard gate 无法在本轮执行，这属于 `tool/runtime failure`，不是 sandbox denial、审批失败、远端服务错误、用户拒绝或脚本失败。operations 的 09 至 11 仍应保持 `windows_pending`；正式推广只有在 Windows 依次实跑三门并留存 transcript 后才能记为完成验收。

## 自然化复读

本记录按工程审计文档处理。机器扫描后，人工逆向复读了标题、各节首段、表格引导、快照自引用边界、回滚说明和结尾。没有发现明显 AI 腔；保留的重复仅用于区分候选可推广、正式已迁移和 Windows 已验收三种状态。
