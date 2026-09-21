# Contract v7 builder scaffold 独立验收

验收日期：2026-08-21  
验收对象：`审计/子代理交接/r1_contract_17_v7_builder_scaffold/` 的 33 个文件  
验收边界：只读正式数据与被审 scaffold；本轮只新增本报告，未修改 scaffold、v7 设计、正式 CSV、validator、staging、资料卡或进度文件。

## 验收裁决

`reject`

当前 live preflight 的阻断行为正确，31 项 Python 3.9 测试也都能稳定通过，但这两项已有结果不足以支持验收通过。关键 validator 仍能对错误的 v7 输入假通过：45/58/12 和 92/96 使用虚构路径、虚构 hash 达成；37/38 使用任意 34 对 common base 达成；JSON Schema 文件没有参与任何一次实例验证；DAG 只检查人工列出的 critical edge，没有从真实 artifact 收集完整依赖边。这些缺口已暴露为 `PASS` 接口的假通过面，不能按普通的未实现项处理。

README 对产物边界的声明基本准确：它明确说这只是 audit-only scaffold，不是 contract migration 或 GA100 transaction，也没有实现真实 bootstrap bytes、stable artifact、patch、operation、rollback 和 apply 状态机。因此没有发现它把自己冒充为真正 builder。但 README 同时把多个组件称为“已实现的可复用部分”，而这些接口当前不能安全地作为真实 v7 builder 的验证基础。按“任何会让真实实现误用或假通过的未覆盖点都 reject”的验收标准，本轮不能 accept。

## 独立实跑与机械复算

本机运行时为 CPython 3.9.6。独立运行 `run_tests.py --json-summary` 得到 `31 passed / 0 failures / 0 errors / 0 skipped`，与 validation report 相同。这 31 项的通过状态只证明现有测试按其自身 fixture 通过，不改变后文对 fixture 覆盖面的裁决。

`run_live_preflight.py --mainline-root .` 实际退出码为 2，报告 `BLOCKED / E_UPSTREAM_PREREQUISITE / snapshot_candidate_creation_authorized=false`。失败集恰为 validation report 记录的 13 项：post-113 validator 与三个旧 live 文件 hash 不符，两个受控输入文件和受控目录不存在，prerequisite manifest、promotion record、三份 Windows transcript 及 prerequisite approval 未闭合。这是预期的上游合同阻断，不是测试或运行时失败。

阻断后，32 张正式 CSV 和 R16 列出的 11 个 raw payload preimage 的 SHA-256 全部与 R16 基线逐文件相同。scaffold 下没有出现 `_unit_test_blocked_workspace_should_not_exist`、snapshot、candidate 或 `__pycache__`。实际正式写入数、snapshot/candidate 写入数均为 0。

| 复算面 | 独立结果 | 验收含义 |
|---|---|---|
| SemanticPath | 三组 payload bytes 为 `859/861, 893/895, 893/895`；`row-v1` 和 singleton `rowset-v1` 的六个 hash 全部命中 v7 oracle | 通过；真实 `fields.csv` 参与复算 |
| formula use | `24 metrics / 47 inputs`，使用分布 `7/4/11/1/1`；structural enum 投影通过 | 通过；真实四表参与复算 |
| freeze/scope | `77 archive rows / 49 counted / 49 scopes`；initial mapping 为 `9 mapped + 1 GA100 pending + 1 GH100 pending + 38 unmapped` | 通过；真实 freeze、active list、objects 与 completeness 参与复算 |
| bootstrap | 测试返回 `45/58/12, U23=23, unique=92, file input=96` | 只是 synthetic membership 算术，不是真实 v7 set-equal |
| chip branch | synthetic mapped 得 37，synthetic GA100 pending 得 38 | 只是分支加法，没有复算真实 `BaseChipRolePathSetV7` |
| DAG | contract fixture `22 nodes / 24 edges / C0…C17`；chip fixture `25 nodes / 35 edges / H0…H24`；已列 edge 全部严格升层 | 只证明 fixture 内已列 edge，不证明 actual-edge closure |
| artifact hash | validation report 中除自身外的 32 个 scaffold artifact 全部命中，content-set hash 为 `02deb22a403865fefe19b4efb30d89ffd167b8177e873a8ac538f9c592fe43f4` | 通过；validation report 自身 SHA-256 为 `bb8737cfe13b239f03fcf6c6ddc0fb5c07441143c5947d4377f3fe2a480a9e9c` |

## 会导致真实实现假通过的阻断项

### Bootstrap 没有验证 v7 的真实成员集

`bootstrap.py` 第 146至230行检查了数量、U23 路径、部分 role 数量和投影唯一性，但没有对 20 个 base、22 个 post、13 个 stable candidate、12 个 patch 与四个 fixed input 执行 v7/v6 builder 的精确 role/path 双向 set-equal。四个 fixed input 只比 role，不比路径；13 个 candidate 只靠“post-only 还剩 13 个”推导，role 和 target 都可任意；两个 prerequisite role 仅检查 `startswith`。

同一函数也没有从 `source_path` 读取文件并重算 raw/canonical hash。第 99至118行只要 canonical domain 非空就接受，不要求 controlled table 使用 `rowset-v1`，也不要求 JSON 使用对应的 artifact domain。独立红队实跑把 active design 路径改成 `wrong/active-design-v6.md`，再把 U23 的 canonical domain 改成 `wrong-domain-v9`，validator 仍返回 96 inputs。

这与测试构造直接相符：`tests/test_bootstrap.py` 第 24至76行使用 `table-00.csv`、`post-table-00.csv`、`artifact-00.json`、`patch-00.json` 和整数格式化出的假 hash，没有任何正例从 post-113 immutable base 构造真实 45/58/12。因此 92/96 目前是对 synthetic fixture 的循环证明，不是 v7 membership 的合同证明。

### 37/38 只验证了任意 34 对输入的分支算术

`mapping.py` 第 108至182行假定调用方已经提供受批准的 `CommonChipBase34`，自身只检查“34 对、唯一、不含四个 branch-specific pair”。它没有从冻结的 35 对 active chip base 机械构造 `BaseChipRolePathSetV7`，也没有验证 `contract_design` 已从 v6 替换为 v7。`tests/test_mapping.py` 第 14至15行明确用 `common_role_00 / stable/common-00` 这类虚构 pair 作为正例。独立红队重跑后，这 34 个虚构 pair 确实得到 38-input `PASS`。

mapping history 还只验证所选 scope 的 seq 连续与 tip 形状。`freeze_row_id`、scope allocation、event ID constructor、old-row byte immutability、reviewer/date/authorization、object/identity 同事务闭合都不在该接口中。作为一个明确标注的纯分支函数，这个边界可以理解；但它不能支撑“37/38 contract 已获得真实成员集验证”的验收结论。

### Schema 和 DAG 都没有闭合到真实 artifact

`schemas/` 的四份 JSON Schema 当前只是文档 artifact。源码没有 schema loader 或 validator，`tests/test_artifacts.py` 第 9至17行只执行 `json.loads` 并确认结果是 object。`validation-report.json`、bootstrap item、prerequisite 和 approval 都没有在测试中通过各自 schema 的正例/反例验证。preflight 对 prerequisite/approval 有另一套手写 exact-key 检查，但这不能证明交付的 schema 正在执行，bootstrap 更没有 JSON manifest loader 把 schema、canonical bytes 与 dataclass validator 绑在一起。

DAG validator 可以正确拒绝已提供 edge 中的同层依赖和环，但它无法发现没有被列入 fixture 的真实依赖。例如 v7 的 H10 planned post 明确组合 H1/H2 与 H6至H9，当前 chip fixture 却没有 `direct_candidates→planned_post` 和 `formula_candidates→planned_post`。contract fixture 的 bootstrap manifest 也只列出 formula patch 和 fixture manifest 两条入边，没有表达 13 个 stable candidate、12 个 patch、3 类 artifact approval 及 membership set hash 的完整输入闭包。所以 `22/24` 和 `25/35` 是 critical fixture 自身的拓扑结果，不是 v7 要求的“收集每一条 actual hash/semantic edge”。

### 身份、路径、TOCTOU 和错误码仍不足以支持真实构造

prerequisite 的独立性仅由三个非空显示字符串的不等关系表示。`preflight.py` 第 239至273行没有使用不可混淆的 principal ID，也没有对空白、Unicode normalization 或 case 做 identity canonicalization。独立红队令 `prepared_by="Alice"`、`approved_by=" Alice "`，approval validator 仍通过。这不能证明三个独立主体。

project path 只拒绝反斜杠、NUL、绝对路径和 `.`/`..`，没有冻结 Windows drive-relative/ADS、保留名、尾部点空格、Unicode normalization 或 case-fold collision 语义。实跑中 `_safe_project_path("C:outside/transcript.txt")` 被接受。`_safe_resolve` 对当前存在的祖先和 symlink 有 root containment 检查，这是有效的一层防护；但 Windows 命名等价关系与跨运行时唯一性还没有闭合。

`guard.initialize_audit_workspace()` 确实先跑 preflight，当前 BLOCKED 时不会创建空目录。然而 READY 报告与后续构造之间没有不可变文件句柄、二次 hash/precondition 或原子 snapshot 协议；函数只在 preflight 完成后创建一个空目录。上游文件可以在 gate 与未来 snapshot 之间漂移。这与 README 所说“还没有真正 builder”一致，但也意味着它尚未解决 TOCTOU 或 atomic write，不能将 `AuditWorkspacePermit` 视为构造授权。

错误分类也并非全部 fail-closed 为稳定机器码。`run_live_preflight.py` 只捕获 `UpstreamPrerequisiteError`；传入不存在的 mainline root 时，`Path.resolve(strict=True)` 抛出未捕获的 `FileNotFoundError`，实跑结果是退出码 1 和 traceback，而不是受控 `E_PATH`/`E_RUNTIME_IO` 报告。CSV 解析、I/O 与 formula `input_order` 转换也仍有同类未封装异常面。它们在当前阻断路径上没有导致写入，但不满足真实 validator 的错误码合同。

## 通过下一次验收所需的最小闭包

下一版不需要提前实现正式 apply，但至少要把“脚手架可验证的合同”与“尚未实现的 builder”分开。bootstrap 需由 v7 冻结的精确 role/path/domain/state 构造器从真实 post-113 base 生成，逐文件重算 raw/canonical hash，再对 45/58/12、U23、92/96 做双向 set-equal；chip base 也要机械构造真实 35 对，然后替换 mapping pair 得 37/38，不接受调用方自报的任意 34 对。

schema 需对正反实例真正执行，或删除与手写 validator 并存却无法证明同义的两套合同。DAG 需从 artifact hash reference、source path、approval binding、patch post hash、manifest set hash 和会改变下游 bytes 的 semantic input 中收集边，并与 v7 的 C0至C17、H0至H24 预期边集双向闭合。identity 应绑定稳定 principal ID；路径需有明确的 POSIX logical identity 和 Windows physical alias/collision 规则；READY 到 snapshot 之间需重验 precondition 或使用可证明的不变输入。所有外部错误路径都应返回稳定 error code 且保持零写入。

## 失败分类与交付边界

本轮 `reject` 属于实现/合同验证缺口：已经实跑证明存在会接收错误 membership、domain、common base 和 approval identity 的假通过。live 退出码 2 则是正确的 `E_UPSTREAM_PREREQUISITE` 数据/状态阻断。不存在 root 的 traceback 是 scaffold 实现错误，不是工具失败。本机没有 `jsonschema` 模块，尝试调用该外部 validator 时发生的 `ModuleNotFoundError` 属于 tool/runtime failure；本裁决不依赖它，因为源码与测试已能直接证明交付 schema 从未被加载。

本轮没有 sandbox denial、用户拒绝、auto-review denial、approval-review connection failure、remote service error 或用户中断。PowerShell 5.1、PowerShell 7 和 Windows hard gate 仍未实际运行；这与 scaffold 的自身声明一致，也意味着 Python 3.9 单元测试不能被解读为 PowerShell/Windows 兼容验收。

本报告是本轮唯一项目写入。交付前已对本文件单文件运行 `report-humanizer` 机器扫描，并从末段向首段人工复读标题、首段、表格引导、转场、数字、hash、错误分类和验收边界。机器扫描最终零命中；人工复读修正了交付句的时态，未发现剩余模板腔。
