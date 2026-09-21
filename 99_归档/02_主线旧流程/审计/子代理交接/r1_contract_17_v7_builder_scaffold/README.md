# Contract v7 builder scaffold

这里交付的是审计区专用脚手架，不是正式 contract migration，也不是 GA100 transaction。当前 31 项 Python 3.9 单元测试通过；live 前置检查按设计返回 `E_UPSTREAM_PREREQUISITE`，因此没有创建 snapshot、candidate 或 transaction。正式 32 表、正式 scripts、source-pool staging、v7 设计稿、资料卡、模板和进度文件都不在本目录的写入范围内。

## 入口和边界

`run_live_preflight.py` 是任何构造动作之前的只读入口。它首先核对正式 `Test-SourcePool.ps1` 是否为 post-113 hash `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0`，然后检查受控输入目录及六项 post-113 正式字节。只有显式给入、通过 exact schema 和 canonical hash 校验的 prerequisite manifest 与 approval，才能提供 promotion record 和三份 Windows transcript 的可信路径与 hash。promotion record 只核对原始字节，不解析其中的 JSON，也不从中推导 gate 结果。

只要上述任一项缺失、漂移或未获独立批准，入口就以 `E_UPSTREAM_PREREQUISITE` 退出。`guard.initialize_audit_workspace()` 也把这项检查放在第一次目录写入之前，并把未来输出限制在本 scaffold 目录下。当前 live validator 仍为旧 hash `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f`，受控输入目录、可信 promotion record、三份 transcript 和独立 prerequisite 均未闭合，所以阻断是正确结果，不应以 staging 或当前 live 字节绕过。

## 已实现的可复用部分

`src/v7_builder/` 包含九个相互独立的合同组件。`canonical.py` 实现无空白 canonical JSON、重复 key/float/surrogate 拒绝、domain + NUL + uint64 big-endian framing，并从正式 `fields.csv` 复算三组 SemanticPath 的 `row-v1` 与 singleton `rowset-v1` oracle。`freeze_scope.py` 先核对冻结文件 55,224 byte 原始形态，再按 RFC 4180 解析 77 行并按活动名单行序构造 49 个 scope；初始 mapping projection 为 9 mapped、GH100 pending、GA100 pending 和 38 unmapped。

`formula.py` 从当前四张只读正式表消费 24 条 metric 和 47 条 input，逐项核对 formula field、unit、role、arity、constant、rounding 与输出值。structural formula 单独执行 enum/text 规则：spec 与 metric 使用 `enum:pooling_mode`，fact unit 为空，text 为 `distributed_not_pooled`。`bootstrap.py` 校验七键 item schema、数组顺序、45/58/12 membership、23 项唯一交集、92 项 identity union 以及加四项固定输入后的 96 项投影。

`mapping.py` 是无 I/O 的 37/38 分支函数。它从 immutable mapping history 计算 EffectiveTip；同 card 的 `mapped+approved` 选择 37 项分支，三种可解析 tip 选择 38 项 override，GA100 seq1 pending 因而固定得到 38 与 next seq 2。该模块不生成 reviewer、date 或 approval。`authorization.py` 只执行 v7 允许的两组身份比较：transaction ID 对 transaction manifest，work package/scope/card 三元组对 coverage manifest。`dag.py` 对每一条显式 hash-reference 或 semantic edge要求 `level(parent) < level(child)`，并另行拒绝环。`preflight.py` 与 `guard.py` 负责前置阻断和审计区输出约束。

`schemas/` 保存 bootstrap item、source-pool prerequisite、artifact approval 和 validation report 的机器 schema；`fixtures/` 保存三组 SemanticPath oracle，以及 contract/chip 两套关键 DAG edge。fixtures 没有 reviewer、date、PowerShell transcript 或 approval 实例，也不表示 Windows 门曾运行。

## 运行命令

从 `02_主线调研-49款芯片资料库/` 的上一级目录运行单元测试：

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -B 02_主线调研-49款芯片资料库/审计/子代理交接/r1_contract_17_v7_builder_scaffold/run_tests.py --json-summary
```

当前 live 负向门使用下面的只读命令，预期退出码为 2，状态为 `BLOCKED`：

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -B 02_主线调研-49款芯片资料库/审计/子代理交接/r1_contract_17_v7_builder_scaffold/run_live_preflight.py --mainline-root 02_主线调研-49款芯片资料库
```

source-pool 正式推广完成后，必须显式传入独立 prerequisite 的两个已完成文件；脚手架不会搜索并猜测哪个文件获得批准：

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -B 02_主线调研-49款芯片资料库/审计/子代理交接/r1_contract_17_v7_builder_scaffold/run_live_preflight.py --mainline-root 02_主线调研-49款芯片资料库 --prerequisite-manifest /path/to/source-pool-113-prerequisite.json --prerequisite-approval /path/to/source-pool-113-prerequisite-approval.json
```

## 当前没有实施的工作

本 scaffold 不生成 45/58/12 的真实 bootstrap bytes，不物化 13 个 stable artifact、12 个 managed patch、operation/payload/image/rollback inventory 或 transaction manifest，也不执行 apply、resume、no-op、rollback 和 GA100 object/fact/card 写入。它没有 PowerShell 5.1、PowerShell 7 或 Windows hard-gate runtime result；Python 测试通过不能替代这些门。source-pool 推广、独立 prerequisite、正式 contract transaction 和后续 GA100 38-input package 仍须按 v7 的顺序另行完成。

R16 编写时把 R15 记为 pending；当前目录已经存在 `r1_contract_15_design_v7_independent_review.md`，其结论为 `accept`，原始 SHA-256 为 `c0f7ce1408e9678f8f131b91e181a4d00a3df042af9033dcaceda5664ec44fad`。本 scaffold 采用当前可见的 R15 状态，但不会把设计验收解释成 source-pool、Windows gate 或 transaction approval。另一个实现选择是 prerequisite manifest/approval 由调用方显式给入，因为 v7 要求前置批准先于任何 T snapshot；脚手架不会预先创建 T 再从中寻找前置文件。
