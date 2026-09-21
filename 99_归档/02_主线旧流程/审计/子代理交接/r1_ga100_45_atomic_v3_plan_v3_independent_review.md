# GA100 atomic v3 实施蓝图 v3 独立验收

验收结论：`reject`。

被验收文件为 `审计/子代理交接/r1_ga100_44_atomic_v3_implementation_plan_v3.md`，296 行，SHA-256 为 `6781415cb509a898bf1085f6d8f88014f985f1bfdd8f6f1488f5a0dd89985d1b`。

本轮只新增本验收报告，没有修改 r44、r42/r43、r14 staging、正式表、合同、来源、资料卡、验证器或进度文件。本次 `reject` 只针对蓝图的可执行性；ContractReservedNewKeyProjection 和 FactorTargetUniverse 的主要缺口已经补上，但 formal-key 的 legacy adapter 仍无法从 r14 实际列机械生成，H7 又新增了对 H8 selection closure 的依赖。这两处会分别破坏 B01 的 key-class 复算和已通过的 H7 到 H8 层级顺序。

## 验收范围与机械回查

我完整读取了项目根和主线 `AGENTS.md`、r42、r43 reject 与 r44，并回查了 r41 已通过项、r38 的 H0 至 H24 层级、release r03 设计稿、r14 的 `operations.csv` 及其 update/delete 指向的当前正式 preimage。

r14 `operations.csv` 的实际表头是 `target_table, operation, primary_key, rationale, dependency_group, risk_level, fragment_file`，共 1,021 条 operation，分布为 942 insert、76 update 和 3 delete。79 个 update/delete target 互不重复，且全部可以在相应正式 CSV 的首列主键中找到。`PPATH-M2NA-AMPERE-TENSOR-INT8`、`CAP-M2NA-AMPERE-SPARSE`、`COND-M2NA-AMPERE-2OF4` 和 `FACT-M2NA-AMPERE-TF32-A` 四个 r43 举例也均命中当前 formal preimage。因此，r43 关于 79 个 existing key 的事实基础成立。

## R45-B01：legacy provenance 记录无法生成它后面使用的 FormalKey

r44 第 18 至 29 行已经把正式 key 固定为 `(logical_table_path, pk_canonical_json)`，并把 `ExistingFormalKeys` 交给 H0 exact preimage。第 48 至 64 行也不再把 r14 的 update/delete target自动加入 forbidden，所以上述 79 个 key 不再同时属于 existing 和 forbidden。第 107 至 115 行还正确允许“同表、同语义、同 H0 row hash”的 legacy locator 解析到同名 existing FormalKey，并以 `E_LEGACY_PROVENANCE_AS_AUTHORIZATION` 拒绝旧 row hash、operation 或 authorization 穿透。这一层的裁决方向是对的。

但是，第 34 至 42 行定义的 `LegacyProvenanceRecord` 没有 `logical_table_path`，第 55 行却直接读取 `locator.logical_table_path`。第 52 行又读取 `op.logical_table_path` 和 `op.pk_canonical_json`，而 r14 真实列名是 `target_table` 和 `primary_key`。`LegacyProvenanceRecord` 中的 `legacy_operation_id` 在 r14 表头中也不存在，文本没有给出它的确定性派生规则。因此 `LegacyInsertOrDraftOnlyKeys` 与 `ForbiddenLegacyDraftOnly` 的当前伪代码无法直接在实际 r14 上运行，实施者仍须自行发明 operations/locator adapter、列映射和 canonical PK 解析。

同一节第 103 行还说，前三个 candidate subset 的 resolved FormalKey 与“各自 key class”双向相等。如果这里的 existing key class 指第 26 行定义的全部 `ExistingFormalKeys`，等式必然错误：GA100 CandidateContentManifest 中的 existing candidate 只是全 formal preimage 的子集。如果它指 candidate-scoped key-class projection，文本又没有定义这三个 projection。这一处不能留给实施者选择解释。

修订时需要给 r14 operation 和普通 locator 各自定义有序 normalization record，至少显式将 `target_table -> logical_table_path`、`primary_key -> pk_canonical_json`，并固定 adapter 版本、主键 schema、row/set hash 和不存在 operation ID 时的 locator 规则。candidate 端应改为两类可复算关系：resolved existing candidate FormalKey 是 `ExistingFormalKeys` 的子集，且它与 `CandidateDispositionRecord[existing_*]` 的 key projection 双向相等。reserved 和 fresh 也应用同样的 candidate-scoped projection 表达，避免把全局 key class 与工作包候选子集误写为相等。

## ContractReservedNewKeyProjection 的审查结果

r44 第 121 至 174 行已经关闭 R43-B02。它限定唯一已应用 `ActiveContractV7_1`，给出 package scope、contract role、active hash 和 approved status 的完整过滤；定义了七列 ordered record、三元 logical key、UTF-8 tuple order、strict canonical JSON、row/set domain 与 hash，并要求 active claim 和 projection 在 key、normalized content 和 source row hash 上双向相等。`absent_create` 和 `present_existing` 也分别绑定 H0 absence 或 exact present preimage，后者转入 existing class，不再冒充 reserved create。

MK-04 至 MK-06 已覆盖缺 claim、重复 logical key/token、同表同 PK 异语义、expected-absent 却 preexisting、present-existing 缺 hash、reserved/fresh 和 reserved/existing collision，也包含跨表同 PK 字符串的合法正例。本节没有发现独立 blocker。

## R45-B02：H7 terminal factor 不能携带 H8 selection closure

r44 第 206 至 246 行已经把 `FactorTargetUniverse` 固定为 included obligation 乘以 H4 中所有 kind-allowed target。subtype predicate 只决定 `exclude`，不再在候选全集之前删行；r42 未定义的 `source-independent eligibility` 已删除；`min_targets_if_available` 也被限定为 all-eligible-include 之后的 count fail gate，不允许从 eligible target 中任选子集。这三项修复通过。

第 250 至 270 行也给出了 obligation include 对 requirement、obligation exclude 对 exclusion review、target universe 对 candidate、include target 对 binding、exclude/N/A target 对 exclusion review，以及 H7 terminal triple 对 include obligation 的双向 set-equality。MK-07 至 MK-10 包含 dropped subtype target、extra target、unknown predicate、任意少选 eligible target、missing obligation exclusion 和 missing H7 terminal 负例，也足以拒绝 r43 指出的静默漏列。

新的问题在第 272 行：文本要求 H7 terminal factor record 携带 `endpoint-qualified evidence/selection closure`。r38 及 r42 的已接受顺序是 H7 从 H1/H6 产生 endpoint-aware terminal evidence closure，H8 再从 H7 产生 selection 和 reverse-removal。H7 不可能携带尚未产生的 H8 selection closure；若按字面实现，会形成 `H7 -> H8 -> H7` 的反向依赖，并违反 H5 到 H10 的分层。

修订只需把 H7 terminal factor record 的条件改为“携带 endpoint-qualified terminal evidence closure”，selection/reverse-removal closure 继续由 H8 产生，H9 再同时消费 H7 与 H8。为避免这个错误回归，machine fixture 还应加一个负例：任何 H7 record 或 H7 hash input 引用 H8 selection/reverse-removal row 时报 `E_HASH_LEVEL`。

## 未回退的边界与 release gate

r44 通过第 3 行的明确继承和第 292 行的回归要求，保留了 r42/r43 已接受的 9 条 final path 乘以 12 个 field 所得 108 exact key，也仍只固定 INT8、INT4、Binary 与 rounding、subnormal 的六个 structural N/A。其余 102 格没有重新引入 value/not_found 数量配额。ExpectedPairBuilder 的完整 `H4 targets x 141 fields` universe、six benchmark、Ampere 三个 identity pair、GA100 三个 counterpart search pair、card 的 H9 至 H18 payload 链和 H13 的 58-key schema也没有被改写。

对象和来源边界仍由 r42 继承：GA100 full die、A100 enabled product/module、Ampere architecture 和 DGX system 不混层；MLCommons 仍只能作 wrong-subject closure，SEC 不支持 GA100 die market-access value，Ampere identity 也不能沿 `implements` 关系下放。除 R45-B02 指出的 H7/H8 反向依赖外，card、H13、pair builder 和来源边界未见回退。

release r03 当前仍只是 744 行的设计稿，SHA-256 为 `c0e4add73d621e5dee5e68904c58469db7f48d833fff3df93e21251d45d19c9e`。当前目录中没有它的独立 accept、实施成功、postimage accept 或 active binding。r44 第 7 至 9 行将其定为 `pending_independent_review`，并以 `E_RELEASE_AMENDMENT_NOT_ACTIVE` 继续硬阻断 H0，这一点通过。

## 重新送审的最小修订

下一版只需关闭两个精确问题：先使 legacy provenance adapter 能从 r14 的真实列无歧义生成 FormalKey，再把 candidate-scoped key projection 与全局 key class 的 subset/set-equal 关系分开；随后删除 H7 terminal factor 对 H8 selection closure 的引用，并加入相应层级负例。ContractReservedNewKeyProjection 和 FactorTargetUniverse 的其他已通过内容可原样保留。release r03 若尚未完成“独审 accept、实施、postimage accept、active binding”，GA100 transaction 仍必须停在 H0。

## 失败与环境分类

本轮的 `reject` 分类为设计/规范缺陷，不是模型能力、sandbox denial、user denial、auto-review denial、approval-review connection failure 或 remote service error。一次初始路径探测假定正式库存在 `数据/operations.csv`，该文件实际不存在，分类为 model/operator path assumption mistake；随后通过全路径清单定位 r14 `operations.csv` 及各正式 target table，完整复算 1,021 条 operation 和 79 个 preimage key，未缩减验收范围。本轮没有用户中断、工具停滞、输出截断或其他 runtime failure。

定稿前已对本文件单独运行 `report-humanizer` 扫描，并从末节向前逆序复读失败分类、release gate、未回退项、B03、B02、B01和首段结论。报告自身的最终行数和 SHA-256 只在交接消息中给出，避免将自引用 hash 写回正文。
