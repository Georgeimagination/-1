# contract v7 builder scaffold v2

本目录是一套前置感知、审计区专用的 Python 3.9 脚手架。它可以在 source-pool-113 正式推广后，读取冻结路径并构造 contract v7 的输入投影；当前正式前置尚未满足，所以 live preflight 按合同返回 `E_UPSTREAM_PREREQUISITE`，不会创建 transaction、snapshot 或 candidate。

## 当前可以复用的部分

`src/v7_builder_v2/` 中的代码只依赖 Python 标准库。`preflight.py` 把 post-113 validator、六项正式文件、受控输入目录、source-pool v4 独立复核、operations、promotion record、三份 transcript、独立 prerequisite 及其 approval 纳入同一检查。validator 的 `c2dc1319...` 是第一项 live byte gate。只有全部检查满足时，函数才签发当前进程内的 `ReadyReport`；报告绑定所有已检查文件和目录成员的 digest。`guard.py` 在首次创建 temp 文件前重新计算这些 digest，并以 exclusive temp、同 volume 检查、`fsync` 和 atomic rename 写入审计快照。任何漂移返回 `E_PRECONDITION_DRIFT`，目标文件和 temp 文件均不保留。

`bootstrap.py` 从冻结常量机械构造 20 个 managed base、22 个 ordinary post、23 个 unchanged、2 个 prerequisite、13 个 stable candidate、12 个 patch 和4个 fixed input。role、source path、logical target path、state 与 canonical domain 均不接受调用方替换。它复算每个实际文件的 raw SHA-256；controlled CSV 使用 stable SemanticPath 计算 `rowset-v1`，strict JSON 使用各自 domain framing。三个 array 的计数为45、58、12，交集严格等于 U23，七键并集为92，file-input 投影加4个 fixed input 后为96。正式 post-113 bytes 不可用时，公开 materializer 只会返回前置错误。

范围与 chip 分支也由固定集合产生。`freeze_scope.py` 先校验55,224 byte 的 raw-only 冻结 CSV，再解析77行并把49条 counted row 与活动名单六元组双射，固定得到 `FREEZE-NV-001 / SCOPE-0001`。`mapping.py` 用 v7 design 替换后的真实 `BaseChipRolePathSetV7` 35项推导37或38项输入，不接收任意34对。override plan 验证 allocation、全历史 seq、`freeze_row_id`、旧 event 不变、event ID constructor，以及 object、identity completeness、mapping 三类输出的 transaction/object/scope 一致性。mapped+approved 计划还必须带由 `authorization.py` 校验并签发的 authorization grant；脚手架不生成 reviewer 或日期。

其余已落地的审计门包括 canonical JSON 与 domain framing、三组 SemanticPath row-v1/rowset-v1 oracle、当前24条 derived metric 与47条 input 的独立 formula 投影、structural enum 专门规则、principal NFC/casefold/whitespace 冲突、POSIX logical path 与 Windows physical alias 分层、symlink 祖先 containment，以及完整的 contract 23-edge 和 chip 51-edge DAG。DAG edge 从 artifact manifest 的 raw、canonical、hash-reference、source、approval、patch、manifest-set、semantic-byte 八类依赖字段实际收集，再与 v7 expected edge set 双向比较。

四份 JSON Schema 会由 `schemas.py` 实际加载。该模块实现本包专用的 Draft 2020-12 子集，覆盖这些 schema 使用的全部 keyword 和本地 `$ref`；未知 keyword、未解析 `$ref` 或 schema/manual validator 分歧均 fail closed。它不是通用 JSON Schema 引擎。

## 当前没有实现的部分

本目录不执行 source-pool-113 推广，也不生成 promotion record、Windows transcript、approval、reviewer 或日期。测试里的 `fixture:*` principal 和固定日期只用于 isolated unit instance，不能复制到 transaction，也不表示任何 live gate 已运行。

脚手架没有生成 v7 policy、34表 postimage、managed patch 内容、operations、payload inventory、rollback inventory、transaction manifest、transaction approval、正式资料卡或 GA100 evidence closure。它也没有正式 apply、roll-forward、rollback、多文件事务执行器或 Windows PowerShell runtime。`guard.py` 只实现单个审计快照的 TOCTOU 与 atomic write 协议，不能替代正式事务 materializer。未来补齐上游后，仍需从正式 post-113 root 重新冻结输入并完成完整 isolated mirror、三运行时 fixture 和独立批准。

## 运行方法与当前结果

在本目录运行单元测试：

```bash
PYTHONDONTWRITEBYTECODE=1 python3 run_tests.py
```

当前共95项测试，全部通过。测试只读取正式冻结输入，或在 `/private/tmp` 创建隔离文件。它们覆盖正反 schema instance、45/58/12 与92/96集合、35到37/38分支、old-row immutability、principal/path冲突、DAG缺边/额外边/同层/环，以及 READY 漂移后的零写入。

运行 live 负向门：

```bash
PYTHONDONTWRITEBYTECODE=1 python3 run_live_preflight.py --transaction-id TX-R19-LIVE-PREFLIGHT
```

当前命令退出码为3，结构化结果为 `BLOCKED / E_UPSTREAM_PREREQUISITE`。第一项 validator 实际 hash 仍为 `44756009...`，期望 post-113 hash 为 `c2dc1319...`；受控输入目录不存在，manifest、summary 和 collector 仍是推广前字节，独立 prerequisite 链也不存在。source-pool v4 独立复核与 operations 两项 hash 已满足。此结果是设计内的 fail-closed，不是 Windows 门已通过。

## 文件位置

`src/v7_builder_v2/` 保存库代码，`schemas/` 保存四份实际执行的 schema，`fixtures/` 保存完整 DAG manifest 与 SemanticPath oracle，`tests/` 保存 isolated/read-only 测试。`validation-report.json` 记录最终测试、live block、失败分类和目录内逐文件 hash；为避免自引用，它列出除自身外的全部文件，自身 SHA-256 在交付回报中单独提供。

