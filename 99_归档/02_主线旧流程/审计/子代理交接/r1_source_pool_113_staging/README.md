# 113 份 PDF 资料池基线修复候选

状态：`v4_operations_contract_candidate_ready_windows_gate_pending`

这是一个只在 staging 中落盘的正式推广包。它没有改动正式 `论文/`、`清单/`、`scripts/`、`进度/` 或三张来源表；实际推广时，受控输入的固定落点是 `清单/资料池受控输入/`，而不是本 staging 目录。该目录必须先取得冻结的 111 行 baseline，再取得 ledger，随后才替换 collector。这样安装后的 `scripts/collect_references.py` 默认解析 `清单/资料池受控输入/source-pool-input-ledger.json`，不再依赖已漂移到 103 份 PDF、102 个唯一内容的历史扫描目录，也不读取当前为 111/100 的可变 `.tmp/paper_inventory_final.json`。

## 修复范围

候选 manifest 在冻结的 111 行基础上增加两份 AMD Instinct product brochure。MI455X GPU 和 MI350P PCIe Card 都有第三波 fixed candidate、正式 `sources.csv`、`source-endpoints.csv` 与 `selection-members.csv` 的逐 ID 绑定。新行的资料类别是 `厂商产品资料`，因此 AMD Instinct 平台数从 4 增至 6；`AMD Instinct / 官方白皮书与技术资料` 保持 4，`AMD Instinct / 厂商产品资料` 为 2。

最终 PDF 口径为 114 次 `源文件` 出现、113 个唯一 SHA-256、1 个历史重复、315,363,681 字节和 2,214 页。`paper_inventory_records=112` 与 `paper_inventory_downloaded=101` 保持冻结历史快照：它们只描述 codex-v3 的历史 paper inventory，不把两份 M2 product brochure 计入其中。

## 可安装的受控输入

`formal_payload/清单/资料池受控输入/` 是将来正式目录的字节级镜像。两个文件必须按下面顺序复制到正式目录：

| 正式目标 | staging 源 | SHA-256 | 作用 |
|---|---|---|---|
| `清单/资料池受控输入/frozen-legacy-pdf-manifest.csv` | `formal_payload/清单/资料池受控输入/frozen-legacy-pdf-manifest.csv` | `c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27` | 111 行历史 manifest 的持久输入，含 112 次来源出现和 1 个历史重复。 |
| `清单/资料池受控输入/source-pool-input-ledger.json` | `formal_payload/清单/资料池受控输入/source-pool-input-ledger.json` | `08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812` | 固定 baseline、两条 M2 supplement、输出合同和冻结 112/101 inventory 值。 |

根目录的同名 ledger 与 frozen CSV 供 staging 审阅；它们与 `formal_payload` 中的两个文件逐字节相同。ledger 内的 frozen 文件名是相对路径 `frozen-legacy-pdf-manifest.csv`，所以安装后不指向 staging，也不会让候选输出反过来成为唯一输入。

## collector 的运行合同

候选 `collect_references.py` 只允许写 `清单/论文PDF清单.csv` 和 `清单/汇总统计.json`。它会先验证冻结 111 行、两条 supplement 的 fixed candidate 与正式资料池 PDF、113 份本地 PDF 的路径/字节/SHA-256/页数，以及两条 AMD 的 source、local endpoint、remote endpoint 和 selection member 的必要字段。来源表的整表 SHA-256 只保留为 ledger 创建时的审计观察，不是运行硬门；因此追加无关的 GA100 来源行不会阻断重放。

两份可写输出各有双态 prewrite guard。首次 apply 接受旧的 111 行 manifest 和旧 summary 哈希；apply 之后也接受本候选的期望输出哈希。因此正确 apply 后，独立 preview 与第二次带同一 ledger confirmation 的 apply 都会成功并保持输出不变。网页清单和待补清单只记录创建时观察值，不被 collector 读取或锁死；严格 write scope 确保它们不会被改写。

这里的 collector 输入边界不改变资料池 baseline gate。候选 `Test-SourcePool.ps1` 仍将 `网页与在线资料.csv` 和 `待补论文清单.csv` 的当前 SHA-256 与 914/893/892/11 计数作为本次冻结的硬门；将来扩充这两张清单时，应单独审计并显式升级 baseline。会在逐芯片工作中正常增加的 `sources.csv`、`source-endpoints.csv`、`selection-members.csv` 则不使用整表哈希硬锁，collector 只检查两条 AMD 所需的行级绑定。

preview 的 `--output-root` 必须与主线完全分离。主线根本身、其任何子目录，或任何包住主线的祖先目录都会被拒绝。apply 需要 ledger 的精确 SHA-256 confirmation：`08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812`。

## 正式推广顺序

具体顺序和回滚边界写在 `operations.csv`。事务开始前必须对四个既有正式目标做字节级 precondition：旧 manifest、旧 summary、旧 collector，以及 SHA-256 为 `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f` 的旧 validator。受控输入目录必须尚不存在。任何一项不匹配都停止，不覆盖并发或用户产生的变更。

备份不再只要求带时间戳的目录。推广时在 `审计/子代理交接/r1_source_pool_113_staging/promotion-records/<promotion_id>/` 建立 `backup-manifest.json` 与 `promotion-record.json`：前者逐项记录四个原目标的绝对路径、项目相对路径、原 SHA-256、备份绝对路径、备份项目相对路径和备份 SHA-256，并记录受控输入目录原先不存在；后者保存该 manifest 的 SHA-256、实际备份目录和每步结果。分成两个文件避免 backup manifest 的自引用 hash 循环。

完成 frozen CSV、ledger 与 collector 的安装后，先在完全独立的 output root preview 并逐字节比较候选输出，再以精确 ledger hash apply 两份输出。接着必须进行一次 post-apply preview 和第二次 apply；两份输出仍须保持候选哈希，且第二次 apply 前后的全主线常规文件内容快照，除两份受控输出和两张 snapshot 自身外，必须为 0 diff。只有这些幂等证据完成后，才安装 SHA-256 为 `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0` 的 validator。collector 的 staging 源和写后正式目标都必须为 `2a980efd45bc9846029003ca38ece6823f75f9d00d6fcbbe0137638e4c2aefcb`。最后在 Windows 依次运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1 -SubjectContractMode gate`。任一环节失败都应停止并从已记录的备份恢复，而不是手改汇总数字。

## 已完成的重放与剩余硬门

已用临时 formal mirror 完成 legacy prestate 的 preview、正确 apply、apply 后 preview 与第二次 apply。四次生成的 manifest 和 summary 都分别等于 `4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab` 与 `994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e`；每次都报告 `pdf_copy_operations=0`。独立复核还对三张 registry 分别追加无关的 GA100 行，并在第二次 apply 前后比较全部非受控内容，得到 123 个文件、0 个内容哈希差异。主线本身、主线子目录和主线祖先作为 preview output root 的三项负向测试都以退出码 2 fail closed。

v4 只修订了操作合同和两份中文交接文档。collector、validator、ledger、frozen baseline、formal payload 与两份候选输出都保留 v3 已独立重放的内容哈希；因此不需要重新生成 113 行候选或重新复制 113 份 PDF。

正式 Windows 硬门仍未运行。本 macOS 环境没有 `pwsh`、`powershell` 或 `powershell.exe`，属于 `tool/runtime failure`，不是 sandbox denial、审批失败或远端服务错误。完整证据、精确命令和正式文件哈希见 `validation_report.md`。

| 文件 | 用途 |
|---|---|
| `论文PDF清单.csv`、`汇总统计.json` | 113 行 manifest 与汇总的完整候选副本。 |
| `formal_payload/清单/资料池受控输入/` | 必须迁入正式 `清单/资料池受控输入/` 的持久输入镜像。 |
| `source-pool-input-ledger.json`、`frozen-legacy-pdf-manifest.csv` | staging 中可审阅的同字节输入源。 |
| `collect_references.py` | ledger-backed PDF/summary-only collector 候选。 |
| `Test-SourcePool.ps1` | 113 文件、汇总、稳定输入和分类计数的 Windows validator 候选。 |
| `operations.csv` | 正式目标、复制顺序、验证和回滚记录。 |
| `validation_report.md` | 重放、幂等、负向测试、正式哈希与遗留硬门。 |
