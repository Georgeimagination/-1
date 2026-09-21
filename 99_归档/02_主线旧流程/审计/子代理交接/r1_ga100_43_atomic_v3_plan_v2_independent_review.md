# GA100 atomic v3 实施蓝图 v2 独立验收

验收结论：`reject`。

被验收文件：`审计/子代理交接/r1_ga100_42_atomic_v3_implementation_plan_v2.md`，526 行，SHA-256 为 `24b51973ba5939b9ecdeba6d52c0d77ffe8ff35aee7407994c5c1d7dd9faf9d0`。

本轮只新增本报告，没有修改 r42、正式表、staging、合同、来源、资料卡、验证器或进度文件。`reject` 只表示 r42 仍不能作为 atomic v3 的可执行实施蓝图，不否定其中已经修复的 B01、pair builder、release fail-closed、H0 至 H24、card 和对象边界。

## 验收范围与方法

我完整读取了主线 `AGENTS.md`、r41 reject、r38 contract v7、R15 对 v7 设计的独立 accept、r18 salvage、r20、r21、r28、r35、r37、r39、release r02 reject、当前 release r03 设计和 r42。R15 的 accept 只覆盖 r38 的设计，不证明 v7 已实施；release r03 也只是一份尚未独立验收、尚未实施的 pending design，不能替代 r02 留下的 hard blocker。r03 当前为 744 行，SHA-256 为 `c0e4add73d621e5dee5e68904c58469db7f48d833fff3df93e21251d45d19c9e`。

机械检查覆盖 9×12 expected key、six structural N/A、三组 forced pair、ExpectedPair/ExpectedFactor 的输入和集合等式、四类 PK、allocator/crosswalk、H0 presence/absence、release active-reference closure、动态 `ChipRequired` 投影、H0 至 H24、H13 58-key、card payload、source/search/selection，以及 GA100、A100、Ampere、DGX、SEC、MLCommons 的对象和来源边界。r14 `operations.csv` 另按 operation 类型和目标 PK 解析，用来验证 legacy key 与正式 preimage 的实际交集。

## 拒绝理由

### R43-B01：四类 key 的互斥定义与实际 preimage 冲突

r42 第 384 至 393 行把 `ExistingFormalKeys`、`ContractReservedNewKeys`、`FreshAllocatedKeys` 和 `ForbiddenLegacyKeys` 定义为逐项互斥，同时把“r14 30 CSV 的全部 draft PK”放入 `ForbiddenLegacyKeys`。但 r14 不是纯 insert 草稿。机械解析其 `operations.csv` 得到 942 个 insert、76 个 update、3 个 delete；后两类合计 79 个目标本来就是正式 preimage key。因此，按 r42 的字面定义，至少这 79 个 `(logical_table_path, primary_key)` 同时属于 `ExistingFormalKeys` 和 `ForbiddenLegacyKeys`。

碰撞不是抽象风险。可直接复现的例子包括 `数据/precision-paths.csv / PPATH-M2NA-AMPERE-TENSOR-INT8`、`数据/special-capabilities.csv / CAP-M2NA-AMPERE-SPARSE`、`数据/condition-sets.csv / COND-M2NA-AMPERE-2OF4` 和 `数据/facts.csv / FACT-M2NA-AMPERE-TF32-A`。r42 第 391 行还承认 legacy 字符串可能与 contract-reserved key 同名，却在第 393 行继续要求四集合逐项互斥，逻辑上同样不能同时成立。

第 464 至 478 行的 crosswalk 又要求 `resolved_pk` 绝不能等于 legacy PK。这会错误拒绝一种合法情况：legacy locator 指向的内容身份经 H0 exact row hash 证明已经是正式 existing row，解析结果理应仍是同一个正式 PK。应禁止的是“用 legacy row 授权”，而不是禁止解析后的正式 key 与 locator 中的字符串相等。

修复时应把正式 key 身份固定为 `(logical_table_path, pk_canonical_json)`，并把 legacy locator/provenance 与可分配 key class 分开。`ExistingFormalKeys` 和 `ContractReservedNewKeys` 先由 H0/active contract决定；`ForbiddenLegacyKeyStrings` 若仍保留，只能是 draft-only key 减去 existing 和 reserved 后的差集。crosswalk 可以在 exact H0 preimage row hash、semantic identity 和 table path全部一致时解析到同名 existing key，但 r14 row hash、review status、operation 和授权不得随之继承。修正后还要用双向 set-equality 证明每个 candidate 恰有一个 disposition，并加入“legacy locator 同名 existing key”的正例 fixture 和“legacy row 冒充授权”的负例 fixture。

### R43-B02：`ContractReservedNewKeyProjection` 没有可执行合同

r42 第 389、395 行依赖 final `ActiveContractV7_1` 的 `ContractReservedNewKeyProjection` 分配 GA100 die、implements-Ampere relation 和 mapping delta 的 reserved key，但全文没有定义该 projection 的输入过滤式、ordered record schema、logical key、canonical domain、排序、row/set hash或与 active contract 的双向 set-equality。第 53 至 77 行只冻结了 `ActiveChipRequiredRoleRecord` 和 `ActiveScopeMappingDeltaRecord`，不能替代 reserved-key projection。

这使 H0 无法机械判断某个 reserved key 是否真的来自唯一 active contract，也无法区分 absent、preexisting、collision 和 legacy 同名。第 395 行的“若 final post 未给出唯一 crosswalk 则失败”只是 fail-closed 口号，不是 builder 合同；实施者仍需自行发明 projection 和 hash 域。动态合同本身没有把蓝图变成占位符，缺失的 reserved-key adapter 才是不可执行点。

修复时至少应冻结 `ContractReservedNewKeyRecord = (package_scope, logical_table_path, semantic_identity_sha256, reserved_pk_canonical_json, reservation_token, expected_h0_state, source_contract_row_hash)`，规定过滤式、tuple order、canonical JSON、row/set domain 和 duplicate/collision规则，并要求 projection 与 active contract 对应行双向 set-equal。`expected_h0_state` 对 create 必须为 absent；若 active contract把同一 semantic identity解析到 existing row，则必须转入 `ExistingFormalKeys`，带 exact preimage hash，不能继续冒充 reserved create。MA-07 还需覆盖 preexisting、absent、reserved/existing collision、reserved/fresh collision、legacy 同名和跨 table 同 PK 字符串。

### R43-B03：ExpectedFactorBuilder 的候选全集和终态闭合仍可静默漏列

r42 第 331 行规定只遍历同时满足 `allowed_target_kinds` 和 `target_subtype_predicate` 的 H4 target来构造 `FactorTargetRecord`；第 345 行却又要求“不满足 target subtype”的目标输出 `exclude`。一个先被遍历条件过滤掉的目标不可能再产生 exclude row。实现者可以把 factor universe理解为“仅 subtype 命中项”，也可以理解为“所有 kind-allowed target，subtype失败项写 exclude”，两种实现都会声称遵守文字，set hash却不同。此处没有完整 universe，MA-06 也就不能发现某个 subtype candidate 被静默删掉。

同一段还使用未进入 factor policy schema和 record的 `source-independent eligibility`；`min_targets_if_available` 没说明是只做数量门，还是在多于 minimum 的 eligible target中允许任选子集。第 317 行要求 card selector=false 的 obligation产生 exclusion review，但第 347 至 361 行及 MA-06 没有把该 obligation-exclusion 集与 builder输出双向 set-equal。r38 的 H7 明确包含 terminal factor adjudication，r42 却没有要求 H7 factor terminal triple与 include obligation triple双向相等。于是 obligation、target或 terminal factor仍有静默漏行通道。

修复时应先构造完整全集：

```text
FactorTargetUniverse =
  {obligation} ×
  {target in H4 | target_kind in obligation.allowed_target_kinds}
```

随后再按固定优先级对每个 universe key判定 `include / structural_na / exclude`；subtype predicate和其他 eligibility只能影响 decision，不能先从全集删行。`source-independent eligibility` 要么删除，要么补成有 ID、有输入字段、有 canonical hash的 active predicate。若所有 eligible target都必须 include，应明确 `min_targets_if_available` 只是 include count的 fail gate；若允许挑选子集，则必须冻结唯一 selector和全候选 exclusion reason。最后补齐四组双向相等式：obligation include对 factor requirements、obligation exclude对 obligation exclusion review、target全集对 candidate rows、include target对 binding，并增加 H7 terminal factor triple对 include obligation triple的双向相等。MA-06 至少要有 dropped subtype target、extra target、unknown eligibility predicate、missing obligation exclusion和missing H7 terminal factor五类负例。

## 已通过的重点检查

### 9×12、pair builder 与三组强制 pair

r42 已不再把历史 `53 value / 49 not_found` 当成验收配额。第 116 行只冻结 108 个 exact key；第 120 至 132 行只固定 INT8、INT4、Binary 三条 path与 rounding、subnormal 两个 field的六个 structural N/A；第 134、512、520 行明确其余 102 格的终态随 actual evidence重算。文中的 49 仅用于历史 mapping/role fixture，不是 status配额。

ExpectedPairBuilder 的八项 ordered input、ref schema、scope base/post/delta/role projection、141-field schema、H4 target schema、canonical/hash规则和 selector precedence已经足以生成全候选集合 `U = H4 targets × 141 fields`。ExpectedPairRecord 的 logical key、四个 H6 set-equality和 H7 terminal key equality也已冻结。六个 benchmark、Ampere architecture 的三个 identity pair、GA100 die 的三个 counterpart search pair都在 precedence前部强制 include；第 163、257、511 行把缺失、exclude 和 structural N/A设为失败。因此 r41 的 fixed-status B01 和 pair-builder B02在本版已经关闭。

### release blocker 与动态 active contract

r42 正确把 release r02标为 `rejected_design / hard blocker`，并只允许未来“独立 accept + 正式 apply + postimage accept + active binding”的 release amendment进入 H0。当前 r03 已经存在，但它只有设计身份，尚无独立 accept、implementation、postimage accept和 active binding；所以它只能作为 pending design参考，不能解除 H0 的 `E_RELEASE_AMENDMENT_NOT_ACTIVE`。r42 第 17、23 行仍写“v2 design 尚未完成”，这是随 r03 新建而变旧的状态描述，建议改为“r03 design 已存在但未独审、未实施”；由于第 21 行的 active resolver仍然 fail closed，此处不单列 hard blocker。

`ActiveContractV7_1` 的 `ChipRequired` 数量由最终 active role rows动态投影，第 77 行明确不预设结果数。历史 37/38、49/50只作 fixture。这个设计保留了确定的 adapter schema和双向相等式，本身可执行，也没有因拒绝提前写死 r03 的 39/40而退化成占位；真正缺失的是 R43-B02 所述 reserved-key projection。

### DAG、card、来源与对象边界

H0 至 H24 的升层关系没有回退。card candidate在 H9 coverage/selection/factor closure之后渲染，进入 H10 complete planned post，再进入 H11、H15、H17、H18，并在 apply 后按 bytes重渲染复验。H13仍严格保持 58-key schema，不让 card payload hash扩张 manifest。

source chain也保持 `family → version → actual endpoint → payload → screening → assertion/search → endpoint result → requirement evidence → selected role → reverse-removal` 的单向授权。r29、r37/r39只提供候选 bytes与内容裁决，不能冒充正式 ingestion或 selection closure。r42没有遗漏重新构造 source、search/result、selection、coverage和 card payload的授权边界；但这些仍是未来 H1 至 H18 工作，不是当前已经完成的资产。

对象边界保持正确：`ga100_full_die` 是 128-SM physical design，不等于 108-SM A100 enabled product、module或 DGX system。Ampere architecture的三条 identity value不能沿 implements relation直接下放给 GA100；MLCommons结果只能作 DGX wrong-subject closure；SEC材料只覆盖 A100/H100 integrated circuits及相关 systems；CUDA/PTX、MIG和RAS也没有被外推成 GA100 RTL、hidden datapath或裸 die measurement。

## 重新送审的最小条件

下一版需要同时关闭 R43-B01 至 B03，不能只在 prose中加一句 fail closed。key 部分要给出四类不重叠、可从真实 H0/r14机械复算的集合和 crosswalk；reserved-key projection要有完整 schema、hash域和 active-contract set equality；factor builder要从 kind-allowed全集出发，并把 obligation exclusion、candidate全集、binding和 H7 terminal全部纳入双向相等与负例 fixture。release r03若届时仍未独立 accept、正式 apply并通过 postimage复核，GA100 transaction仍须停在 H0。

## 失败与环境分类

本轮没有用户中断、sandbox denial、user denial、auto-review denial、approval-review connection failure或 remote service error。首次批量读取多份长报告时发生一次输出上限截断，分类为 tool/runtime output-limit truncation；随后逐文件、分段读到 EOF，未缩减验收范围。一次 Git 状态探测因当前工作根不是 Git repository而退出，分类为 tool/runtime environment mismatch；本轮改用目标文件的直接行数、hash和路径存在性复核，没有降低结论可信度。当前环境没有 `pwsh` 或 `powershell`，分类为 tool/runtime limitation；由于本轮是只读蓝图验收，不是 implementation/postimage，未把 Windows hard gate写成 PASS，也未用其他运行时替代。

定稿前已对本文件单独运行 `report-humanizer` 扫描，并从末节到首节人工逆序复读结论、blocker、集合关系、数量、hash、状态词和对象限定。报告自身的最终行数与 SHA-256只在交接消息中给出，避免自引用。
