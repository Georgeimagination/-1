# R1 GA100 合同 v7 独立设计验收

审计日期：2026-08-21  
审计性质：只读正式数据和既有设计/红队报告；未修改 v7、正式 CSV、validator、staging、资料卡或进度文件。

## 结论

`accept`

v7 已经关闭 R14 的七个设计 blocker。三个 bootstrap array 的唯一性与跨 array 复用已分层；`row-v1` 和 singleton `rowset-v1` 有分离的 domain、payload 与 oracle；R13 的 release-date 定义按 188-byte 原文冻结；24 条 derived metric 和 47 条 input 都被 formula-use builder 消费，structural enum 分支与当前正式行相容；GA100 有唯一的 38-input mapping override 路径；authorization 只比较对方 manifest 实际存在的字段；contract 与 chip 的每条实际 hash/semantic edge 都严格向更高层流动。

这一裁决只表示当前冻结文本可以进入实现。source-pool-113 正式推广、contract migration、GA100 chip package、三运行时 fixture 和 Windows 数据门都没有因本次 `accept` 而获得通过状态。

## 冻结输入与正式基线

本轮完整读取了主线 `AGENTS.md`、v3、R08、R09、v4、R10、v5、R12、R35、source-pool-113 v4 独立复核、R13、v6、R14 和 v7。v7 表内 12 个上游 SHA-256 均从文件原字节重算一致。被审 v7 实测 661 行，SHA-256 为 `2e896d97e2f87496785e1f466300a7992cf66d778c8f6196274ccc2e00bd8258`。

正式表重新解析为 32 张 table、346 条 schema column；32 张磁盘 CSV 的 header 与 schema ordinal 逐表一致，没有缺表、重列或断号。其余实测为 141 个唯一 field、76 个 enum group、557 条 enum row、78 个 object、832 条 assertion、92 个 source family、93 个 source version 和 153 个 endpoint。completeness 的 585 行恰为 45 个 object 乘 13 个 domain，每个 object 都是完整 13 行。

基于实际 preimage，postimage 算术仍为：

```text
tables          32 + 2                         = 34
schema columns  346 + 4 + 20 + 5 + 1          = 376
fields          141 - 1 + 1                   = 141
enum groups     76 + 1                        = 77
enum rows       557 - 1 + 5 + 1 + 2           = 564
```

`rounding_mode` 当前恰有 5 行，`product_status.historical_anchor` 恰有 1 行，`selected_role.coverage_obligation_evidence`、`card_lifecycle` 和 `rounding_mode=rtn/rtp` 当前均未发布。因此 `77/564` 是可由真实 preimage 机械生成的 postimage，没有借用作者计数。

## R14 七个 blocker 复验

| R14 检查面 | 独立结果 | 可执行证据 |
|---|---|---|
| bootstrap 重复与唯一性 | 通过 | `ItemIdentity7` 和 `ItemLocator3` 只在各 array 内唯一；`Base∩Post=U23`，其他两个交集为空。`45+58+12-23=92`，再加四个固定输入得 96。U23 只投影 23 个 file-input row，其他 role/source 冲突直接失败。 |
| SemanticPath hash 类型 | 通过 | 使用当前 `fields.csv` 第一条 data row 从 envelope 重建。三个 path 的 envelope/singleton payload 字节数为 `859/861,893/895,893/895`；三组 `row-v1` 和三组 singleton `rowset-v1` hash 与 v7 逐字一致。合法 snapshot 仍以 `数据/fields.csv` 作 SemanticPath。 |
| release-date 语义 | 通过 | R13 SHA 已纳入冻结输入。`target_definition` 实测为 188 UTF-8 bytes；正式查询恰命中 5 条 fact 和 6 条 requirement。v7 要求全部 deferred，本事务对其计数为 `+0`。 |
| formula 与当前派生行 | 通过 | 正式库恰有 24 条 derived metric 和 47 条 input，使用分布为 `7/4/11/1/1`。已按 input order、role、field、unit、arity、constant、rounding 重算全部 24 个输出，零差异。structural row 的 metric unit 为 `enum:pooling_mode`，fact unit 为空，text 为 `distributed_not_pooled`，正好命中 v7 专用分支。 |
| GA100 scope mapping 出口 | 通过 | 35 个 base pair 先去掉 stable mapping 得 34；no-change 是 `34+1+2=37`，override 是 `34+2+2=38`。GA100 contract tip 固定为 seq1 pending，只能走 38 分支。seq2 只能 append 为 `MAPEV-SCOPE-0001-0002 / mapped / approved`，post 为 50 行，rollback 恢复原 49 行。object、identity 和 mapping 共用一个事务。 |
| authorization 身份绑定 | 通过 | `transaction_id` 只与 transaction manifest 比较；`work_package_id/scope_id/card_object_id` 只与 coverage manifest 比较。v7 没有虚构对方 manifest 不存在的 key，13 列 operation 与 19 列 payload 投影双向 set-equal 继续生效。 |
| hash DAG 分层 | 通过 | 对 contract 23 条主要实际 edge 和 chip 51 条主要实际 edge 按 v7 级别独立录入，严格不等式检查零违反。关键链为 `terminal result/evidence(H1) → terminal adjudication(H7) → selection/reverse-removal(H8) → coverage fields(H9) → planned post(H10) → delta(H11) → closure(H12) → coverage manifest/approval(H13/H14) → authorization/approval(H15/H16) → operations(H17) → isolated mirror(H18)`。formula candidate `C4→C6` patch 也已升层。 |

bootstrap membership fixture 必须遵守 C0 的 synthetic fixture source value 边界，即用真实 builder 检查 45/58/12 形状和投影，不读取本次 runtime-result 或 fixture-manifest 的最终 hash。v7 的 C0→C5→C6→C7 分层已排除这两种后向读取；实现若违反该边界，应由 `E_HASH_CYCLE` 或 `E_HASH_LEVEL` 拒绝，不属于另一种合法实现。

C3 的 post snapshot 也不能只凭节点名称判定无环。本轮沿 v6 `BuildContractInputsV6` 的物理 `source_path` 逐项回溯：22 个普通 post 都从 `T/inputs/post/<logical_target_path>` 读取，其中 11 个 formal post 是九张更新表加两张新 factor 表，11 个 raw post 是活动名单、四个 validator/恢复脚本和六个模板/项目文档。前者只依赖 C0 冻结规则、C3 base 和 raw freeze 的 exact constructor；`objects/card-completeness` 虽投影 scope 结果，也不读 C4 的 allocation/mapping candidate 原字节或审计元数据。后者的完整 post 字节依冻结设计与 C3 base 独立生成，C6 的 managed patch 反向绑定这些 base/post hash，不得反过来决定 post。13 个 stable candidate 不是这 22 个 C3 post：它们在 C4 至 C6 完成后，到 C7 才与 `22 post + U23` 合成 58 个 `PostItems`。因此当前文本的唯一合法实现是“22 个完整 post snapshot 在 C3 独立物化”；若代码改为从 C4 至 C6 candidate/patch hash 生成其中任一 post byte，就形成下向 semantic edge，必须报 `E_HASH_LEVEL`，不能沿用本次 `accept`。

## 集合、映射与继承计数

冻结归档实测 55,224 bytes，开头 BOM 为 `efbbbf`，换行分布为 64 个 CRLF 和 14 个 LF-only，无 bare CR；24 列、77 行，其中 49 行 `counts_toward_chip_completion=true`。这 49 行按 v6/v7 exact constructor 生成的六元组与活动名单 49 行逐行相等，不只是 set-equal。`FREEZE-NV-001` 是第一行，所以 GA100 唯一分配为 `SCOPE-0001`。

49 个 freeze row 中恰有 10 个非空 `existing_formal_object_id`，全部 exact 命中正式 object，其中 9 个已有 identity completeness。唯一例外是 `FREEZE-NV-002 / OBJ-NVIDIA-GH100-DIE`。因此 contract 初始 projection 的 `9 mapped + 1 GH100 pending_identity_review + 1 GA100 pending_formal_object_create + 38 unmapped` 可从正式 preimage 独立得到。当前 scope allocation/mapping registry 和两张 factor table 均不存在，与 fresh base 一致。

`contract_design` 的 active 角色在 contract 和 chip 两个 builder 中都已由 v6 替换为 `r1_ga100_38_contract_repair_design_v7.md`。v6 仍以冻结上游输入存在，不占用第二个 active role。v4 的 36 个 role token、v5 新增 5 个和 v6 新增 5 个全部唯一，合计 46；v7 mapping snapshot 复用既有 role，所以不增加 token。

其余继承计数也逐项闭合：

| 合同面 | 独立复算 |
|---|---:|
| contract table images / payloads / managed targets | `11 / 24 / 35` |
| restore / delete-created / stable artifacts | `20 / 15 / 13` |
| bootstrap base / post / patch / unique / file input | `45 / 58 / 12 / 92 / 96` |
| chip no-change base / auth / required | `35 / 2 / 37` |
| chip override base / auth / required | `36 / 2 / 38` |
| current formulas | `24 metrics / 47 inputs / 5 used + 3 preregistered IDs` |
| GA100 mandatory / structural N/A | `108 / 6 mandatory + 1 normal die-count` |
| forced expected pair / release audit universe | `9 / 5 facts + 6 requirements` |

## 状态机与执行边界

38-input 分支在首次冻结时由 T 内 mapping base 决定。fresh、applying resume、applied no-op 和 rollback 都从这份 base 重建同一分支，不会在 live 已有 seq2 后切换为 37-input 分支。fresh apply 只接受完整 preimage；混合态只能在同 manifest `applying+started` 下 roll-forward；no-op 要求完整 postimage 和同 manifest 成功 journal；rollback 只恢复整个受批准事务的 49-row preimage。无 journal 的 mixed state、第三种 mapping hash、改写 seq1、只建 object 或只追加 mapping 都 fail closed。

contract 状态机继续使用 v6 的 immutable snapshot 和 35-target managed state。v7 只替换 active design、bootstrap 交集语义、formula candidate/patch、release gate 及严格 DAG，没有改变 contract apply/rollback 的 target 集。因此状态机和新 DAG 没有分支计数或反向 hash 冲突。

## 尚未执行的门

source-pool-113 v4 staging 的 12 步 operations 和候选字节仍与独立复核一致，但 live `Test-SourcePool.ps1` 仍是旧 hash `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f`，`source-pool-input-ledger.json` 的正式受控目录和 promotion records 也仍不存在。所以 source-pool prerequisite 尚未满足，v7 不得复制 base snapshot。

当前环境只有 Python 3.9.6，没有 `pwsh`、`powershell` 或 `powershell.exe`。本轮已实跑 Python 恢复检查，结果为 `formal_tables=32; endpoint_rows=153; local_paths=79; hashes_checked=79; selection_runs=11; selection_members=106`。PowerShell 5.1/7 fixture 和 Windows 三道 hard gate 无法在本机执行；这是 `tool/runtime failure`，没有发生 sandbox denial、approval failure、approval-review connection failure、remote service error 或用户中断。

## 验收边界

本次 `accept` 允许主代理依 v7 进入审计区实现，但实现仍必须依次完成 source-pool-113 正式推广和三门、contract 三运行时 fixture、96-input migration 与 Windows mirror gate，然后才能构造 GA100 38-input chip package。未运行的 fixture、未生成的 stable registry、未执行的 migration 和未通过的 Windows gate 不能从设计验收结论继承成 PASS。

本报告为本轮唯一项目写入。交付前已对单文件执行 `report-humanizer` 机器扫描，并按末段到首段的顺序人工复读标题、每节首段、表格引导、计数、hash、状态与验收边界。
