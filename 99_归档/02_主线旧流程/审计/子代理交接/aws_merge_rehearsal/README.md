# AWS 四代物理对象事实包合并演练检查点

状态：`checkpoint_pass_but_do_not_execute`

本目录保存 AWS 四代物理对象事实包在 Google TPU（Tensor Processing Unit，张量处理器）来源门合并后、字段主体合同迁移前的合并演练。当前基线上的演练已经通过，但字段合同迁移必须先执行；该迁移会有意改变正式表哈希。因此，当前签字和脚本只能作为可复算检查点，禁止用于正式写入。字段迁移完成后，需要重新绑定正式基线并完整重跑本目录的三类测试。

## 检查点结果

当前正式 32 表聚合 SHA-256 为 `97ebb17a2518e3a43b18a382dcfc879c1f5e2b08118a6149c8fa984e65017453`。演练使用 `aws_signoff_rebase/aws-signoff-rebase.csv`，其 SHA-256 为 `9429d80f0ba649724ed1276523df8ecfcf269e6e748b15a6cbe4dd11013b42c0`。

隔离副本执行了 478 项写授权，并验证 8 个禁止写入守卫。演练器自身通过 370 项检查，合并脚本通过 25,451 项检查；正式校验器在隔离结果上通过 101,311 项检查。预期结果为 78 个对象、27 条对象关系、678 条事实、680 条断言、863 条字段要求、40 张资料卡、8 个来源选择运行和 96 个选择成员。

原签字 `58f2368764e4fb132fe63a5acc427f22cdace7c38538270a7457e566d19bbd05` 被新的脚本在 signoff SHA 门拒绝，退出码为 1。另一个负向测试预先放入一张已授权资料卡，脚本在任何 CSV 写入前因目标已存在而停止，退出码同为 1；32 张表和预置文件哈希均未改变，也没有复制 AWS PackageImplementations 快照。

演练前后，当前正式库的 32 张表都没有发生变化。临时目录已删除。当前正式库另做了一次校验，共通过 93,378 项检查。

## 文件

`Invoke-AwsPackageMerge.ps1` 是参数化的 PowerShell 5.1 合并器。它要求独立目标根带 `.aws-merge-isolated-target` 标记，并验证 signoff、冻结 manifest、生命周期清单、正式基线、逐表预合并哈希、来源哈希、目标缺失和禁止写入守卫后才会写入。CSV 统一写为 UTF-8 无 BOM、CRLF；11 个快照和 4 张卡逐字节复制，目标存在即停。

`Test-AwsPackageMergeRehearsal.ps1` 构造受控临时根，复制 32 张表和资料卡，使用只读 junction 补充现有 PDF 与快照依赖，运行负向和正向测试，再执行正式校验器。清理前会确认 junction 类型，清理范围受本目录与 `.tmp-aws-` 前缀双重限制。

`current-baseline-table-diff.csv` 和 `current-baseline-pk-diff.csv` 记录 Google 来源门造成的 3 表、8 主键增量；`aws-google-write-set-conflict-audit.csv` 证明这些主键与 AWS 写集没有交集。`formal-hash-integrity.csv` 记录正式 32 表前后哈希。运行输出和汇总分别保存在 `negative-old-signoff.txt`、`negative-existing-target.txt`、`positive-signed-baseline.txt`、`validator-signed-baseline.txt` 和 `validation-summary.json`。

最终文件清单是 `checkpoint-manifest.csv`，其中有 12 条记录。关键哈希为：

- 合并器：`d2623ba0bad3cf841f0d12cd1c1805bb326c03a4d2478589992b36065e3aefbb`
- 演练器：`d394c395d10931c73f43f82eeea8c9d50e7b7646c094ca5ac0ae78e45916cbef`
- 检查点 manifest：`e0b934b95e7c4e2360680690b5639a8c54adc5d768285374aea8e577047b6d9b`
- manifest 12 条记录聚合：`2e3c4a35ef3dbd725465b48c0efe7f2232e8bbd28664c1fb303423f9a6fd6613`

## 后续重放条件

字段主体合同迁移完成后，先冻结新的 32 表 aggregate 和所有受影响目标表哈希，再由独立复核者重签 AWS 486 行清单。随后替换合并器中的 signoff SHA 与正式基线 aggregate，保持冻结包的三项哈希和 478/8 授权边界不变。必须重新跑旧签字拒绝、目标已存在拒绝、当前基线正向演练和正式校验器；四项都通过且正式 32 表不变，才具备真实合并条件。

回滚准备不能省略：真实合并前备份 32 张正式表中的 21 张写入目标表、4 个资料卡目标和 11 个快照目标的目标存在状态，并保存备份 manifest。任何基线、目标文件、来源文件、授权行或计数不一致都应停止，不做部分合并。

本目录没有修改项目级 `README.md` 和 `AGENTS.md`。本任务只生成子代理演练检查点，全局状态由总控在字段合同迁移和 AWS 正式合并时统一更新。