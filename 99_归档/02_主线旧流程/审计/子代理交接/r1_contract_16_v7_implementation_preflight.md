# contract v7 实施前清点

状态：`preflight_complete_not_implementation_authorized`

审计日期：2026-08-21  
审计性质：只读清点。本次只新增本文件；未生成 transaction candidate，未改动正式 32 表、来源资料池、活动名单、脚本、模板、staging 或进度文件。

## 可进入实现准备的边界

v7 已给出可实现的合同形状，但当前不能直接创建 contract migration。最先要完成的是 source-pool-113 v4 的正式推广。该 staging 的独立复核结论为 `accept`，含义是 00 至 11 的推广操作合同可执行；它没有表示正式文件已迁移，也没有表示 Windows 的三道硬门通过。当前 live 的 `scripts/validation/Test-SourcePool.ps1` 仍是旧字节，受控输入目录不存在，因而不能从 live root 复制 v7 的 base snapshot。

source-pool 完成后，contract migration 仍需先在事务目录构造完整 immutable input、三运行时 fixture、候选 artifact 及审批链，在 isolated mirror 上复算全部门，再由独立人批准 transaction。GA100 不在该 migration 内写 fact 或卡片。它只在 contract postimage 已应用后，以 `FREEZE-NV-001 / SCOPE-0001` 的 seq=1 pending mapping 为 immutable preimage，走 v7 的 38-input mapping-override 分支。

R08、R09、R10、R12、R13、R14 已作为 v7 冻结输入读取。R13 的 release-date 结论是 deferred 独立迁移，不能提前改正式行。目录中没有名为 R11 或 v7 对应 R15 的 contract design acceptance；唯一带 `15` 的 `审计/子代理交接/r1_ga100_15_atomic_v2_independent_review.md` 是早期 atomic v2 staging 的 `reject` 复核，不是 v7 accept。故 R15 状态记为 `pending`，不得据此假定 contract migration 或 GA100 package 已获 accept。

## 冻结输入与当前正式 preimage

active `contract_design` 必须只登记 v7：

```text
(contract_design,
 审计/子代理交接/r1_ga100_38_contract_repair_design_v7.md)
```

本次外部复算的 v7 raw SHA-256 为 `2e896d97e2f87496785e1f466300a7992cf66d778c8f6196274ccc2e00bd8258`，共 661 行。它必须由 transaction-file-inputs 在文件外部绑定，不能把自身 hash 写回设计稿以形成自引用。实现开始时应再次复算；若设计稿字节改变，所有 candidate、patch、bootstrap、fixture、approval 和 manifest hash 都要重新生成。v6 仍可作为冻结上游输入，不能继续占用 active `contract_design` role。

当前 schema 有 32 个注册 table、346 个 column；正式数据为 141 field、76 enum group、557 enum row、78 object、585 completeness、798 fact、1,059 field requirement、832 assertion、92 source family、93 source、153 endpoint、11 selection run、106 selection member。Python 恢复检查已实跑通过：`formal_tables=32; endpoint_rows=153; local_paths=79; hashes_checked=79; selection_runs=11; selection_members=106`。

下表是 contract preimage 的 32 张正式 CSV。行数不含 header，hash 为本次直接 SHA-256；实施者应在 source-pool 先行推广完成后重新冻结应受管理的 nine-table base、23-table unchanged image 和 eleven raw payload base，不能把这里的清点当作可直接 apply 的 transaction input。

| 路径 | 行数 | SHA-256 |
|---|---:|---|
| `数据/card-completeness.csv` | 585 | `dc41bd9350cf82940953d2e5c843d5433c1cd9b2b081b9eb2100177f76d9b053` |
| `数据/components.csv` | 270 | `423180b7dcc9950c6eedc7e50ee89d6aa30b6b8b3dcab644bdd4067239e58a87` |
| `数据/condition-sets.csv` | 200 | `65c59ea813cae7b5affda9b14bfc3e8d0f52e0789e2acb22fb9428edf5690ac2` |
| `数据/derived-inputs.csv` | 47 | `96d13946334cecf0ba6ceff6cdc360869a837e8b2868d91ff4ce4af27ccc6a43` |
| `数据/derived-metrics.csv` | 24 | `7e33d6bf8e766e9ef9b318247035c660c0feca9d614bf4da5aa1817b94cfc6c9` |
| `数据/enums.csv` | 557 | `12903d1f3c3ddf476331e5dabd918affe70b377f334366cdbb73e66ec2b3f5f9` |
| `数据/facts.csv` | 798 | `24addee6816046f5d3d1651cc4fc54e62e536a13d360c27c04bd833a89384871` |
| `数据/field-requirements.csv` | 1,059 | `7f84f6109d3a362bdf6beae395e6213bc2aefcfb0244ab7d4440680b0c8cf9a3` |
| `数据/fields.csv` | 141 | `9e01cdb3bbd5db9dbdab0763db7b85a57c7bd055436ccdff1e88ad0f737b0233` |
| `数据/links.csv` | 45 | `647fba1e936abe640b49fe26ca33b4775f674ba3f1239e1a68bbdf7b6fd12fab` |
| `数据/memory-levels.csv` | 88 | `ec06a1942df81dd64a3ebd5b972e3e09b4725eab12f218a88435a075fdfe7132` |
| `数据/object-relations.csv` | 27 | `9bbe32227f7022a5f9e4fe379d805e60780c15d6987e5b20e3b94ac3241fa353` |
| `数据/objects.csv` | 78 | `54800b32b2ee08b45bf0b9ad0aa569b406133a1f74be26d5301ee5de750a1ec7` |
| `数据/precision-paths.csv` | 171 | `13b0c596036655b9b39c960be647ef616e4ed3a26d980c25fe6282c1082265f6` |
| `数据/schema-columns.csv` | 346 | `783c375e4998d131499c55b7d63b8344de924ba7d3c254d95b7167c433fa8dc1` |
| `数据/special-capabilities.csv` | 95 | `ce59d773611e84a22f8f66a3fe78ac79fc6f655f1ca976da16ec0942c72bf59b` |
| `数据/topologies.csv` | 5 | `3002be526aba90d9c646b1fc00d1e63e1c495713c8ee165ef02f11949915c8d8` |
| `数据/vendors.csv` | 7 | `10aaf2440ab727f2d887f0c72a1cb8397cc88aaccf8850d7cf8ca6c242efa156` |
| `最小参考资料库/conflict-groups.csv` | 20 | `3cd63920140e216d107af95b0138f17c2d5a7d37e425b278967b397d3ed7c0ce` |
| `最小参考资料库/conflict-members.csv` | 41 | `c5e002d1098e18d6d23e0fe4968b9672a138b651d10b5c666f3e8d36550ed642` |
| `最小参考资料库/fact-assertions.csv` | 832 | `284489effdbfda10a37da139ded2d68c1608004fbc93336c0cd1ff023d5dab33` |
| `最小参考资料库/requirement-evidence.csv` | 73 | `e11d052d9900f3092d8d1bd90c3c727687d7a319586d86f6092f6da3ba489959` |
| `最小参考资料库/search-log.csv` | 353 | `52b253fb9a554b28dcdaf7a09f517e97a748746d77469b8e642fd37618a5ed94` |
| `最小参考资料库/search-results.csv` | 699 | `a5e1dbd8effe9007bf5b99a9ca8826a2cbb47a036554d6922eba2c35596b0e86` |
| `最小参考资料库/selection-members.csv` | 106 | `33489268f80d30d4b1d0063da8cb7a15e8ad0fe3d1f1c961bc19d41339dfbd30` |
| `最小参考资料库/selection-runs.csv` | 11 | `1e2f0aa6e13af4f0ce5b9268c62bee58735b320196400f6ea2773354bbc1672c` |
| `最小参考资料库/source-coverage.csv` | 27 | `5c20123eeddf5046e7b6bc8b44728d5eb89f2ce70106f292b3508b0311a7bf68` |
| `最小参考资料库/source-endpoints.csv` | 153 | `e4984fef2846fbc299e93dd4573aa3252858848cd7eb7ecc42c4a0d7a249f7bd` |
| `最小参考资料库/source-families.csv` | 92 | `03997ba2d81c5a3d2bacf3fb8c821f3b77399acfcf005ddb90f87c7f000e6bcb` |
| `最小参考资料库/source-screening.csv` | 101 | `dde05c0fd0557d945309ec11b782a14d6df56f74fb69604ea4a6bcc4dc2674b6` |
| `最小参考资料库/source-selected-roles.csv` | 113 | `1b7d95871586b874b076863f64f5e5a2e276a70a565bbe199d7ac0b69c7bb262` |
| `最小参考资料库/sources.csv` | 93 | `eee9a5dd3161d1fc83cbf141c3af930e87fbdef1cf1eb4dda3a13388837518eb` |

作为 eleven raw payload preimage 的当前非表文件及 hash 是 `清单/训练与推理芯片名单.md` `b760d71bf810f5f8d4b72f4e5cfd39b695c64f363852f4f34e4b028c62bf026c`、`scripts/validation/Validate-ResearchData.ps1` `c710439eee8cf5ad57ddbd5eaff75d94bc27f7de9482830dc46f931297bbe618`、`scripts/validation/Test-ChipScope.ps1` `c53c2cdcf6c4180cee9f48fcc389c8e0440f9cc2c0e8eebedd5d00563a466b13`、`scripts/validation/Test-SourcePool.ps1` `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f`、`scripts/validation/verify_recovery_paths.py` `2fc153cc0c521a967122fbda476f928608da50358ee76e5956fc525e52082a73`、`资料卡/模板.md` `29cc08d9a9dd3ac46e6abd1e027731936a3f9091531b8b32ee9a0f842246e478`、`资料卡/字段字典.md` `49ba0e230a908eb18aee91e218e3fcce40bfd26a94f7d398eae754b2ff1df5f4`、`README.md` `0751ce191e63e95b78ffef0d496267c125016e020999097421bcb68ee7061e22`、`AGENTS.md` `3d69282bb5cdef231a66123dc05a04fa340bf03498417bfb9f994e5cd16b4464`、`研究计划.md` `a21aeeb754d679f579fbeab703861bac312d768786cd7bbcc068b5d96a726e8d`、`进度/当前状态.md` `14842e7fa614be74e40974b83b57e5650859e10942c8f123b6c87483c2f59c48`。其中 Test-SourcePool 的旧 hash只可作为 source-pool-113 的 precondition，v7 contract base 必须改用已推广后的 `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0`。

## v7 事务对象、schema 与目标集合

contract migration 的 11 张 table image 是下列九张 present-to-present table 与两张 absent-to-present table。两张 factor table 的 absent state 必须真的不存在，不能用空文件替代。

```text
数据/schema-columns.csv
数据/enums.csv
数据/fields.csv
数据/objects.csv
数据/card-completeness.csv
最小参考资料库/search-log.csv
最小参考资料库/search-results.csv
最小参考资料库/requirement-evidence.csv
最小参考资料库/fact-assertions.csv
数据/factor-requirements.csv
数据/factor-target-bindings.csv
```

v7 postimage 的目标分别为 34 table、376 column、141 field、77 enum group、564 enum row。受影响 schema 是：objects 增加 `scope_id`；card-completeness 增加 `card_lifecycle,data_cutoff_date,scope_id`；search-log 增加 factor requirement XOR；search-results 增加 endpoint 与 checked locator/scope；requirement-evidence 增加 factor requirement XOR 和 endpoint；fact-assertions 增加 endpoint，并将全部 832 行重算为 AFPV2。factor-requirements 固定 9 列，factor-target-bindings 固定 11 列。当前两表均不存在。

两张新表及两个scope registry不得由旧staging猜测表头，固定按下列列序生成。`scope-object-mapping.csv` 的seq=1是contract postimage；GA100的seq=2只在后续chip override事务的post snapshot出现。

```text
数据/factor-requirements.csv
factor_requirement_id,card_object_id,policy_id,factor_id,requirement_status,
applicability_reason,requirement_fingerprint,review_status,notes

数据/factor-target-bindings.csv
factor_target_binding_id,factor_requirement_id,object_id,component_id,link_id,
object_relation_id,precision_path_id,capability_id,topology_id,review_status,notes

审计/合同注册表/scope-id-registry.csv
scope_allocation_id,freeze_row_id,scope_id,allocation_state,
active_list_row_canonical_sha256,allocation_basis,allocated_by,allocated_date,
reviewed_by,reviewed_date,approval_status,notes

审计/合同注册表/scope-object-mapping.csv
mapping_event_id,mapping_event_seq,freeze_row_id,scope_id,formal_object_id,
proposed_formal_object_id,mapping_status,mapping_basis,reviewer,review_date,
approval_status,notes
```

contract payload 是 24 项：上节 eleven raw payload 更新，加下节 thirteen stable artifact create。两类 target 不重叠，故 managed target 为 `11 table image + 24 payload = 35`。其中 20 个已有 target rollback 时 `restore`，两张 factor table与13个 stable artifact共15项 rollback 时 `delete_created`。这一定义不应因23张 unchanged table被误写成34 table image。

23张 unchanged table只作为 immutable image，从每一项单一 snapshot 同时参加 base/post membership，不是写目标：

```text
数据/components.csv
数据/condition-sets.csv
数据/derived-inputs.csv
数据/derived-metrics.csv
数据/facts.csv
数据/field-requirements.csv
数据/links.csv
数据/memory-levels.csv
数据/object-relations.csv
数据/precision-paths.csv
数据/special-capabilities.csv
数据/topologies.csv
数据/vendors.csv
最小参考资料库/conflict-groups.csv
最小参考资料库/conflict-members.csv
最小参考资料库/selection-members.csv
最小参考资料库/selection-runs.csv
最小参考资料库/source-coverage.csv
最小参考资料库/source-endpoints.csv
最小参考资料库/source-families.csv
最小参考资料库/sources.csv
最小参考资料库/source-screening.csv
最小参考资料库/source-selected-roles.csv
```

R13 release-date 迁移不在上述11张 image或23张 unchanged 内转写。policy 的 `release_date_semantics_gate` 要锁定“首次公开日期”及R13的188-byte definition，同时把当前5条 fact、6条 requirement、相关 assertion/evidence/search和语义引用面留待另一份原子 migration。GA100 release-date requirement保持 `pending_verification`。此项对 v7 的34/376/141/77/564、11/24/35与96 inputs均为`+0`。

## bootstrap、stable artifact、patch 与 approval

首次 migration 的13个 stable target 全部以 `absent→present,delete_created` 的候选字节从 `T/inputs/bootstrap/targets/<stable_target>` 发布。候选源与stable target byte-for-byte相同，但 controlled CSV row envelope 必须取stable logical target path，不能取物理 `T` path。

| 角色 | stable target | 生成与批准要求 |
|---|---|---|
| coverage policy | `审计/合同注册表/coverage-policy-v5.0.json` | 由冻结base、scope builder、R13 deferred、R35、formula use等重建；有同名 approval |
| policy approval | `审计/合同注册表/coverage-policy-v5.0-approval.json` | 先绑定coverage policy，不回引bootstrap |
| source-date policy | `审计/合同注册表/source-date-policy-v3.0.csv` | 由actual source/endpoint规则重建；有同名 approval |
| date-policy approval | `审计/合同注册表/source-date-policy-approval.json` | 单向绑定source-date policy |
| legacy disposition | `审计/合同注册表/legacy-requirement-disposition.csv` | 1,059行、29个重复组、26 pending的全量独立处置；有同名 approval |
| legacy approval | `审计/合同注册表/legacy-requirement-disposition-approval.json` | 单向绑定legacy disposition |
| legacy reconciliation | `审计/合同注册表/legacy-requirement-reconciliation-events.csv` | append-only successor/reconciliation registry，approval状态在受控CSV内闭合 |
| scope allocation | `审计/合同注册表/scope-id-registry.csv` | 49个 active+approved allocation；hash来自七列postimage行 |
| scope mapping | `审计/合同注册表/scope-object-mapping.csv` | 初始49个seq=1 event，分布9 mapped、GH100 pending、GA100 pending、38 unmapped |
| formula spec | `审计/合同注册表/formula-evaluator-v1.json` | 由24/47独立use-builder及3个GA100预登记ID生成 |
| fixture manifest | `审计/合同注册表/canonical-fixture-manifest.json` | 仅在fixtures和三运行时结果均已独立满足后生成 |
| fixtures | `审计/合同注册表/canonical-fixtures.csv` | 继承v3-v6并加入v7 families，positive/negative均冻结 |
| runtime results | `审计/合同注册表/canonical-runtime-results.csv` | 每个fixture恰有PowerShell 5.1、PowerShell 7、Python 3三行；当前不得伪造为已存在 |

bootstrap manifest与approval不属于stable artifact，固定放在 `T/inputs/bootstrap/bootstrap-bundle-manifest.json` 和 `T/inputs/bootstrap/bootstrap-bundle-approval.json`。source-pool prerequisite manifest与approval也不是stable target，固定放在 `T/inputs/prerequisites/source-pool-113-prerequisite.json` 和 `T/inputs/prerequisites/source-pool-113-prerequisite-approval.json`。

12个 managed patch 必须逐一存在。前11项是present-to-present update，formula patch是absent-to-present create；它们只能证明diff，不替代对应完整postimage bytes。

```text
T/inputs/patches/active-scope-list.patch.json
T/inputs/patches/formula-evaluator-spec.patch.json
T/inputs/patches/validate-research-data.patch.json
T/inputs/patches/test-chip-scope.patch.json
T/inputs/patches/test-source-pool.patch.json
T/inputs/patches/verify-recovery-paths.patch.json
T/inputs/patches/card-template.patch.json
T/inputs/patches/field-dictionary.patch.json
T/inputs/patches/project-readme.patch.json
T/inputs/patches/project-agents.patch.json
T/inputs/patches/research-plan.patch.json
T/inputs/patches/current-status.patch.json
```

v7 membership必须由对象本身校验，不能只按数字。base array为 `20 managed base + 23 unchanged + 2 prerequisite = 45`；post array为 `22 changed post + 23 unchanged + 13 candidate = 58`；patch为12。23个unchanged item是base与post集合唯一允许的七键交集，两个array中的完整七键必须逐字相同。base、post、patch各自的item identity与locator都唯一，base/post和patch交集都为空。三个array的unique identity为92，投影后再加active v7 design、raw-only freeze archive、bootstrap manifest和bootstrap approval，file-input恰为96。

v7新增或修正的fixture family为`bootstrap intersection`、`semantic path type`、`release deferred`、`current formula uses`、`structural enum`、`mapping 37`、`mapping 38 / GA100`、`mapping replay`、`forced future object`、`authorization identity`和`hash DAG`。每项要和v3至v6继承fixture一起进入candidate fixtures与runtime result；当前没有任何v7 runtime-result文件，不能把设计稿列出的oracle当作已执行结果。

## SemanticPath、formula 与scope的专门门

controlled CSV 从物理snapshot读取时，canonical envelope的`table_path`永远是logical target。以当前`数据/fields.csv`第一data row为例，合法`row-v1` hash是 `c9332d894c520577a49b7479652139dc9f6de35df8591481bd25e7e1b9a4c10f`，其singleton `rowset-v1` hash是 `33b9c8872bb811fb91c3147df2c6c85f852ae63cf6be380e9f84b3a35de5eff2`。把`T/inputs/base/数据/fields.csv`或`T/inputs/post/数据/fields.csv`写入envelope时，row-v1与rowset-v1分别成为负例的`8db42271...`/`b43d5fe8...`和`d605741c...`/`d43f1568...`。table image canonical set用rowset-v1，单行operation pre/post用row-v1，不能互换。

formula candidate不得只校验ID列表。当前immutable input中有24条`derived-metrics.csv`和47条`derived-inputs.csv`。五个已使用formula分布为7、4、11、1、1，合计24；输入分布14、8、22、2、1，合计47。builder还须从facts与fields snapshot逐项校验field、unit、role、arity、constant、rounding和output value。registry完整ID集合是这五个已用ID加`FORMULA-GA100-HBM-CONTROLLER-COUNT-X512`、`FORMULA-GA100-NVLINK-COUNT-X25GBPS`、`FORMULA-GA100-BIDIRECTIONAL-X2`三个usage=0的预登记ID。`FORMULA-STRUCTURAL-PROJECTION`是text/enum特殊例：spec和derived-metric都用`enum:pooling_mode`，fact normalized unit为空，constant为`distributed_not_pooled`。v6的“text output unit为空”方案不可复用。

冻结范围原件 `审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv` 是raw-only input，当前为55,224 byte、SHA-256 `df171b83b1be7dd747e9c78f5417ce8347c4bfcf70c31cb77f39699f44ef41ea`、UTF-8 BOM、24列、77 data row，包含64个CRLF和14个LF record separator，bare CR为0。只可先验原始字节再按RFC4180解析，不能先统一换行。49条`counts_toward_chip_completion=true` row与活动名单六元组双射，随后按活动名单行序发出`SCOPE-0001`至`SCOPE-0049`。GA100固定为`FREEZE-NV-001 → SCOPE-0001`。

contract candidate的GA100 forced benchmark rule可经seq=1 pending proposed ID解析；chip package则必须在同一受批准事务内插入对象、identity completeness和seq=2 `mapped+approved` mapping event。GA100 post mapping共50行，新增行ID为`MAPEV-SCOPE-0001-0002`，旧seq=1不得更改。它从pending preimage选择38项required input：34项common base、mapping base/post snapshot各1项、authorization/approval各1项。已映射同card的工作包才走37项分支。transaction no-op必须继续由T内pending mapping base重建分支，不能因live已map而偷换为37项。

## source-pool-113 v4 先行事务

可安全按字节复用的source-pool v4 candidate只服务其自身的正式推广。它们及批准的staging操作合同如下：

| staging来源 | 正式目标或用途 | SHA-256 | 复用裁决 |
|---|---|---|
| `审计/子代理交接/r1_source_pool_113_staging/formal_payload/清单/资料池受控输入/frozen-legacy-pdf-manifest.csv` | `清单/资料池受控输入/frozen-legacy-pdf-manifest.csv` | `c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27` | 可原字节复用，限sequence 01 |
| `审计/子代理交接/r1_source_pool_113_staging/formal_payload/清单/资料池受控输入/source-pool-input-ledger.json` | `清单/资料池受控输入/source-pool-input-ledger.json` | `08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812` | 可原字节复用，限sequence 02 |
| `审计/子代理交接/r1_source_pool_113_staging/collect_references.py` | `scripts/collect_references.py` | `2a980efd45bc9846029003ca38ece6823f75f9d00d6fcbbe0137638e4c2aefcb` | 可原字节复用，限sequence 03 |
| `审计/子代理交接/r1_source_pool_113_staging/论文PDF清单.csv` | `清单/论文PDF清单.csv` | `4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab` | 可原字节复用，先preview再apply |
| `审计/子代理交接/r1_source_pool_113_staging/汇总统计.json` | `清单/汇总统计.json` | `994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e` | 可原字节复用，先preview再apply |
| `审计/子代理交接/r1_source_pool_113_staging/Test-SourcePool.ps1` | `scripts/validation/Test-SourcePool.ps1` | `c2dc1319f39b5eaaf353274113a5c08b9ca5df3a33636f50517ecbbe3265fbf0` | 可原字节复用，但只能在两次apply及0-diff快照之后安装 |
| `审计/子代理交接/r1_source_pool_113_staging/operations.csv` | source-pool推广操作合同 | `e8bf4895f0d376d355ad0cae507664f9911b23d5ada653ef5626440f07bbc9ea` | 可作唯一顺序输入，00至11不得拆序 |

当前旧precondition为PDF manifest `c8c43df...8b27`、summary `eee940c5b1fdaa871fe0f2ea734216136471db28a68f43ff10cfdc2602b41db7`、collector `4946da30c5fd9540f51298fd5aac839d9573c96cba78ac2b3309096a21a7b06f`、validator `44756009c8791d44a6164aa55b9360cde2a5aa1275b2889b3b5c720e1db9736f`。staging的promotion-record尚不存在，当前也无`清单/资料池受控输入/`目录。故v7仅可将source-pool v4 review、operations与后续promotion record/transcript纳入两个prerequisite input；不得从staging文件直接冒充v7的live BaseItem。

Windows限制是明确的运行时限制。本机没有`pwsh`、`powershell`或`powershell.exe`，因而`Test-SourcePool.ps1`、`Test-ChipScope.ps1`、`Validate-ResearchData.ps1`尚未执行。这是`tool/runtime failure`，不是sandbox denial、approval failure、remote service error或脚本实现失败。Python recovery通过不能替代三门。

## 旧staging的复用界限

`审计/子代理交接/r1_contract_04_card_scope_coverage_staging/`可复用为历史审计证据和parser测试素材，不能复制任何formal_payload字节进入v7 postimage。它使用`SCOPE-001`至`SCOPE-049`，把10个对象直接scope映射并保留`superseded` lifecycle，与v7的`SCOPE-0001`格式、9 mapped/GH100与GA100 pending、5值lifecycle、SemanticPath、96-input bootstrap与37/38 chip分支不兼容。其formal_payload的schema、fields、enums、objects、completeness、活动名单、模板与字段字典均已和live不同；两个旧validator字节虽当前碰巧与live一致，也正是v7要用patch更新的preimage，不能当postimage复用。

v3至v6设计文本、R08至R14复核、R15早期reject、source-pool staging README与validation report、r1_contract_04的scope mapping audit都只应作为只读file input、fixture思想或人工交叉检查来源。不可把它们的候选JSON、scope rows、旧hash、已废弃enum、旧schema、旧操作清单或旧正式payload作为v7 candidate source。v7 candidate必须按v7 exact schema、current/post-113 immutable base、R13 byte definition和v7 hash DAG重建。

## 建议目录布局和实现顺序

建议在实际获得实现授权后创建单一事务根`审计/事务/<TX-CONTRACT-V7>/`，其内部以如下目录固定物理来源；本次没有创建这些目录或文件。

```text
审计/事务/<TX-CONTRACT-V7>/
  inputs/base/<nine changed table + eleven existing payload>
  inputs/post/<eleven contract table + eleven payload postimage>
  inputs/unchanged/<23 formal table>
  inputs/bootstrap/targets/<13 stable target>
  inputs/bootstrap/bootstrap-bundle-manifest.json
  inputs/bootstrap/bootstrap-bundle-approval.json
  inputs/prerequisites/source-pool-113-prerequisite.json
  inputs/prerequisites/source-pool-113-prerequisite-approval.json
  inputs/patches/<12 MANAGED-PATCH-V1 files>
  fixtures/<candidate fixture sources, if the implementation separates them>
  operations.csv
  table-images.csv
  payload-inventory.csv
  transaction-file-inputs.csv
  rollback-inventory.csv
  rollback-manifest.json
  transaction-manifest.json
  transaction-approval.json
```

实施应先在Windows按source-pool operations的00至11推广，保存backup、promotion record与三份PASS transcript，独立生成并批准两个source-pool prerequisite。然后从正式post-113 live root复制v7 BaseItem，不从旧live或staging取代。接着由immutable base重建45/58/12 membership、92 unique identity、96 file input、scope allocation/mapping、policy、date/legacy registry、formula spec、fixtures和patch。三运行时的每个positive canonical hash和negative error code都一致后，才可批准fixture manifest、bootstrap和candidate artifact。

之后builder从T内32-table image产生exact migration delta，生成11 table images、24 payload、35 rollback row和complete mirror。mirror必须同时验证34/376/141/77/564、832 AFPV2、49 allocation、49 seq=1 mapping、raw freeze、23 unchanged、formula 24/47、R13 deferred、R35 expected-pair、source family singleton、recovery及Windows三门。transaction approval通过后才写35个target。GA100 transaction留在下一阶段，使用38-input branch和独立operation/payload authorization；不得在contract migration中补GA100 object、fact、endpoint、selection或资料卡。

## 本次检查记录

本次曾因一个工作目录字符串写错导致命令无法创建进程，属于model/operator mistake；未触及文件，随后已用正确主线目录重跑。没有发生sandbox denial、approval failure、remote service error或用户中断。

本报告已执行 report-humanizer 单文件扫描。扫描仅命中一次归档路径中的项目名，它是必须保留的精确路径，不是泛化文案残留；未出现破折号、模板式标题、机械加粗或套话。人工已从结尾向前复读标题、首段、表格引导、过渡、数字、路径和结论，并修正了 SemanticPath 段的一处 rowset hash 笔误。首个逆序命令因本机没有 `tac` 而失败，属于 tool/runtime failure；改用 macOS 的 `tail -r` 完成同一只读检查。项目目录没有可用Git仓库，`git status` 报 `not a git repository`，属于项目状态限制，故只以文件存在、内容、SHA-256和恢复检查验证本次交接。剩余风险是实施候选尚未生成和Windows三运行时尚未执行，不是报告语言问题。
