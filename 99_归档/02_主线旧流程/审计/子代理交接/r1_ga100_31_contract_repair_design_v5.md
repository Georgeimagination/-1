# GA100 资料卡合同修复设计 v5

## 设计状态与规范基底

本稿只定义合同，不授权执行 contract migration，也不表示 GA100 工作包、三运行时 fixture 或 Windows 数据门已经通过。本轮只新增本文件；正式表、活动名单、模板、validator、staging 和进度文件均保持原字节。

规范继承顺序固定为 v3、v4、R10、v5。v4 中未被 R10 否决的字节合同、logical key、selector、managed-state、latency mapping、AFPV2、source locator、cutoff、derived DAG、reconciliation lifecycle、coverage manifest 和事务日志条款继续生效。本稿与 v4 冲突时以本稿为准；实现者不得从同名但不同 SHA-256 的文件继承规则。

| 冻结输入 | SHA-256 |
|---|---|
| `r1_ga100_19_contract_repair_design_v3.md` | `f590a98ec29f3202c3d2eb3801f5fcddf165fd31bd5c86f2d778b797e0276cf8` |
| `r1_contract_08_design_v3_independent_review.md` | `161cfc6142b6b84b823fa65ec4c7d5476bf2601d9073ca4ef9462abf89c27a07` |
| `r1_contract_09_design_v3_additional_redteam.md` | `37bcc1243862d2c7540c05caff323d10d0d1da12246d33a556623707ba553f69` |
| `r1_ga100_26_contract_repair_design_v4.md` | `4771e201f404699f41f486fa85adba8609e9c5c5797632fb52f99ededce9b349` |
| `r1_contract_10_design_v4_independent_review.md` | `afad0d0ce892b130cd1846b8ba713f966ba9cd9051372a213a8bd9565dde5e34` |

当前实测基线为 32 张正式 CSV、346 个 schema column、141 个 field、76 个 enum group、557 个 enum row、78 个 object、585 条 completeness、832 条 assertion、93 个 source version。活动名单有 49 个数据行，表头只有六列：`厂商,芯片对象,层级,角色,共享设计组,一手身份来源`。`审计/合同注册表/` 目录及其下所有本合同 prerequisite 当前均不存在。`source-families.csv` 只有七列，没有 authority 列；authority 只能从 `sources.csv.source_authority` 读取。

v5 不改动 v4 的正式 postimage 算术：

```text
formal tables:  32 + 2 = 34
schema columns: 346 + 4 + 20 + 5 + 1 = 376
fields:         141 - 1 + 1 = 141
enum groups:    76 + 1 = 77
enum rows:      557 - 1 + 5 + 1 + 2 = 564
```

本稿只修复 R10 的五个 blocker 及其同类矛盾。v4 已经通过的七组 golden serialization oracle 和 `managed-state-rowset-v2` oracle 保持原 domain、payload、hex 与 hash，不重新编码。

## 首次 bootstrap 并入 contract migration

### 事务内与事务外的边界

令 `T = 审计/事务/<transaction_id>`。首次迁移允许在 `T/inputs/` 中准备候选 policy、approval、registry、fixture、base snapshot、postimage snapshot 和 patch。这些文件是不可变事务输入，不是正式 prerequisite，不会因为出现在 `T` 中就被视为稳定合同已发布。

稳定路径的首次 absent→present 只能由同一 contract migration 执行。禁止事务外先创建 `审计/合同注册表/` 中的任何文件，也禁止先把活动名单改成七列。执行器在写入第一个目标前可以创建精确的父目录；目录本身不是合同 artifact。rollback 后可以留下空目录，但不得留下任何 absent preimage 的文件。

### 十三个候选稳定 artifact

下表的 13 个 stable target 当前均为 absent。候选字节先放在 `T/inputs/bootstrap/targets/<stable_target>`，经隔离镜像验证后，作为 payload inventory 的完整 source bytes 发布到 stable target。每一项都必须是 `absent→present,delete_created`。

| input role | stable target | payload kind |
|---|---|---|
| `coverage_policy` | `审计/合同注册表/coverage-policy-v5.0.json` | `canonical_json` |
| `coverage_policy_approval` | `审计/合同注册表/coverage-policy-v5.0-approval.json` | `canonical_json` |
| `source_date_policy` | `审计/合同注册表/source-date-policy-v3.0.csv` | `controlled_csv` |
| `source_date_policy_approval` | `审计/合同注册表/source-date-policy-approval.json` | `canonical_json` |
| `legacy_requirement_registry` | `审计/合同注册表/legacy-requirement-disposition.csv` | `controlled_csv` |
| `legacy_requirement_registry_approval` | `审计/合同注册表/legacy-requirement-disposition-approval.json` | `canonical_json` |
| `legacy_reconciliation_registry` | `审计/合同注册表/legacy-requirement-reconciliation-events.csv` | `controlled_csv` |
| `scope_allocation_registry` | `审计/合同注册表/scope-id-registry.csv` | `controlled_csv` |
| `scope_mapping_registry` | `审计/合同注册表/scope-object-mapping.csv` | `controlled_csv` |
| `formula_evaluator_spec` | `审计/合同注册表/formula-evaluator-v1.json` | `canonical_json` |
| `canonical_fixture_manifest` | `审计/合同注册表/canonical-fixture-manifest.json` | `canonical_json` |
| `canonical_fixtures` | `审计/合同注册表/canonical-fixtures.csv` | `controlled_csv` |
| `canonical_runtime_results` | `审计/合同注册表/canonical-runtime-results.csv` | `controlled_csv` |

候选 controlled CSV 虽然位于 `T` 下，canonical row envelope 中的 `table_path` 一律使用上表 stable target，不使用 candidate source path。这个 target mapping 由 input role 和上表唯一决定。stable copy 的原字节必须与 candidate source 完全相同，因此 candidate approval 绑定的 canonical hash 在 stable target 上复算仍相同。

### bootstrap bundle 的单向批准

`T/inputs/bootstrap/bootstrap-bundle-manifest.json` 使用 exact-key schema：

```text
bootstrap_contract_version
bootstrap_bundle_id
transaction_kind
base_snapshot_items
postimage_candidate_items
patch_items
prepared_by
prepared_date
reviewed_by
reviewed_date
review_status
notes
```

contract version 固定 `CONTRACT-BOOTSTRAP-V1`，transaction kind 固定 `contract_migration`，review status 固定 `reviewed`，prepared_by 与 reviewed_by 必须不同。三个 item array 的项均使用 exact key `input_role,source_path,logical_target_path,preimage_state,raw_sha256,canonical_domain_tag,canonical_sha256`，按 `(input_role,source_path,logical_target_path)` 的 UTF-8 bytes tuple 排序。raw-only 文件的两个 canonical key 为 JSON `null`；controlled CSV 和 canonical JSON 两键非空。

base array 必须与后文 20 个 base snapshot set-equal，postimage array 必须与 22 个普通 post snapshot 加上表 13 个候选 artifact set-equal，patch array 必须与后文 12 个 patch set-equal。manifest 不包含自身、bootstrap approval 或 transaction manifest 的 hash。

`T/inputs/bootstrap/bootstrap-bundle-approval.json` 复用 v4 的 9-key `ARTIFACT-APPROVAL-V1`，`artifact_kind=contract_bootstrap_bundle`，只绑定 bootstrap manifest canonical hash。approved_by 不得等于 bootstrap manifest 的 prepared_by 或 reviewed_by。两个 bootstrap 文件只是 immutable transaction input，不复制到 `审计/合同注册表/`，也不进入 rollback target set。

批准顺序固定为：

```text
candidate policy -> candidate policy approval
candidate source-date policy -> candidate source-date approval
candidate immutable legacy registry -> candidate legacy approval
candidate fixtures + three runtime results -> candidate fixture manifest
candidate scope/registry/formula rows + all candidates/approvals/snapshots/patches
    -> bootstrap bundle manifest -> bootstrap bundle approval
operations/images/payload/file-input/rollback inventories
    -> rollback manifest
bootstrap approval + rollback manifest + all transaction inputs/postimages
    -> transaction manifest -> transaction approval
execution -> append-only journal
```

任何 candidate artifact 都不得引用 bootstrap manifest、bootstrap approval、transaction manifest 或 transaction approval。bootstrap manifest 不引用自身 approval；rollback manifest 不引用 transaction manifest；transaction manifest 不引用 transaction approval。validator 按此 DAG 进行拓扑排序，节点数不等于排序输出数即返回 `E_HASH_CYCLE`。

## 六列名单、49 个 scope 与 mapping 的原子切换

### legacy preimage 和 contract postimage

contract migration 是唯一允许识别六列活动名单的 transaction kind。它的 base snapshot 必须逐字节匹配当前六列、49 行文件。legacy schema 固定为下列顺序：

```text
厂商,芯片对象,层级,角色,共享设计组,一手身份来源
```

postimage 使用 v4 已冻结的七列 schema：

```text
scope_id,厂商,芯片对象,层级,角色,共享设计组,一手身份来源
```

七列 postimage 的 49 行与六列 preimage 按行序一一对应，六个原列的 cell 逐字相同。freeze row 只能从不受本事务修改的 `审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv` 构造。builder 精确筛选 `counts_toward_chip_completion=true` 的 49 行，再用 vendor、canonical chip name、层级映射、include_main/include_historical_anchor 角色映射、silicon design group 和 official source title/URL 组成的 Markdown link 与当前六列行做唯一对应。零匹配、多匹配、冻结集不是 49 行或对应后有剩余行都失败。scope 按当前活动名单行序唯一分配 `SCOPE-0001` 至 `SCOPE-0049`；GA100 固定为 `FREEZE-NV-001 -> SCOPE-0001`。名单改写是 raw-only `present→present,restore` payload target，base snapshot 同时作为 rollback payload。

### 49 条 allocation 和 49 条 mapping event

`scope-id-registry.csv` 在 postimage 中必须恰有 49 条 `active+approved` allocation。每条 `scope_id` 与活动名单 set-equal，`freeze_row_id` 与归档冻结行一一对应，`active_list_row_canonical_sha256` 必须从同一七列 postimage 行重算。任何 allocation 都不能绑定六列行 hash。

`scope-object-mapping.csv` 在首次 postimage 中必须恰有 49 条 seq=1 event，每个 scope 恰一条。状态分布由当前正式对象和 completeness 独立派生：

| 集合 | 行数 | 初始 mapping 状态 |
|---|---:|---|
| 已有 formal object、identity completeness 且 scope 合同可一次闭合 | 9 | `mapped+approved` |
| GH100 | 1 | `pending_identity_review`，不得 approved |
| GA100 | 1 | `pending_formal_object_create`，不得 approved |
| 其余冻结 scope | 38 | `unmapped+approved` |

pending event 的 approval status 只能是 `reviewed` 或 `needs_resolution`，并满足 v4 的 proposed object nullable matrix。mapped 九行必须由当前 object、identity completeness 和冻结名单独立 join 构造，不读取候选 mapping 中的自报 object ID。候选 mapping 与独立 builder 的 49 个 exact row key set-equal，否则 bootstrap 批准无效。

活动名单、allocation 和 mapping 必须在同一 isolated mirror 中联合验证。正式 apply 不存在只更新其中一项的合法停点。scope 状态门固定为：

| 事务状态 | 活动名单 | allocation | mapping | 合法结果 |
|---|---|---|---|---|
| fresh base | 六列、49 行，等于 base snapshot | absent | absent | 只允许 contract migration fresh apply |
| applying mixed | 恰为自身 preimage 或 postimage | absent 或完整 49 行 postimage | absent 或完整 49 行 postimage | 只在同 manifest `applying+started` 下 roll-forward |
| applied | 七列、49 行 | 49 active+approved | 49 seq=1 event | 全局 scope gate PASS；同 manifest 可 `SUCCESS_NOOP` |
| rollback mixed | 恰为自身 postimage 或 base | 完整 postimage 或 absent | 完整 postimage 或 absent | 只在 `rollback_applying+started` 下继续 rollback |
| rolled back | 六列、49 行 | absent | absent | 完整 base gate PASS；同 manifest 可 `ROLLBACK_NOOP` |

chip work package 只接受 applied contract state。它看到六列名单、absent allocation 或 absent mapping 时必须在构造 coverage inventory 前失败。

## immutable snapshot 与 role/path 全集

### 所有现有 live target 都改用 T 内 snapshot

snapshot path 函数固定为：

```text
BaseSnapshot(p) = T/inputs/base/<p>
PostSnapshot(p) = T/inputs/post/<p>
```

路径保留项目相对目录层级和 Unicode scalar，不做 case-fold 或 normalization。下表给出普通 live/formal target 的完整集合。前 20 项有 base 和 post snapshot，最后两张 factor table 只有 post snapshot。

| target path | base state | post state |
|---|---|---|
| `数据/schema-columns.csv` | present | present |
| `数据/enums.csv` | present | present |
| `数据/fields.csv` | present | present |
| `数据/objects.csv` | present | present |
| `数据/card-completeness.csv` | present | present |
| `最小参考资料库/search-log.csv` | present | present |
| `最小参考资料库/search-results.csv` | present | present |
| `最小参考资料库/requirement-evidence.csv` | present | present |
| `最小参考资料库/fact-assertions.csv` | present | present |
| `清单/训练与推理芯片名单.md` | present | present |
| `scripts/validation/Validate-ResearchData.ps1` | present | present |
| `scripts/validation/Test-ChipScope.ps1` | present | present |
| `scripts/validation/Test-SourcePool.ps1` | present | present |
| `scripts/validation/verify_recovery_paths.py` | present | present |
| `资料卡/模板.md` | present | present |
| `资料卡/字段字典.md` | present | present |
| `README.md` | present | present |
| `AGENTS.md` | present | present |
| `研究计划.md` | present | present |
| `进度/当前状态.md` | present | present |
| `数据/factor-requirements.csv` | absent | present |
| `数据/factor-target-bindings.csv` | absent | present |

20 个 base snapshot 的 role 都是 `managed_base_snapshot`，22 个普通 post snapshot 的 role 都是 `managed_postimage_snapshot`。snapshot 必须在 bootstrap approval 前冻结，之后每次 validate/apply/resume/no-op/rollback 都从 `T` 路径重算 raw/canonical hash。live target 的存在性和 hash 只由 table image、payload inventory、rollback inventory 和 managed-state 观察。

### 十二个 exact managed patch

patch 使用 v4 exact-key JSON contract，路径集合固定为：

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

每个 patch 的 target path 必须与后文 payload target 恰一对应。active scope patch 必须证明六列→七列且 49 个原数据行不变；formula patch 证明 absent→present；其余 10 项证明 present→present。patch 只是差异证据，不取代完整 postimage source。

### contract migration 的 71 个 file input pair

v5 在 v4 的 36 个 `input_role` token 上追加下列五个 token，封闭 role enum 因此有 41 个 token：

```text
bootstrap_bundle_manifest
bootstrap_bundle_approval
managed_base_snapshot
managed_postimage_snapshot
scope_freeze_archive
```

contract migration 的 `(input_role,relative_path)` 全集是下列互斥并集，恰有 71 项：

1. `(contract_design,审计/子代理交接/r1_ga100_31_contract_repair_design_v5.md)`，1 项。
2. `(scope_freeze_archive,审计/归档/芯片名单冻结_2026-08-17/训练推理芯片名单冻结.csv)`，1 项。
3. bootstrap manifest 和 approval 的两个 exact path，2 项。
4. 前述 13 个 candidate artifact，role 取表中值，relative path 取 `T/inputs/bootstrap/targets/<stable_target>`。
5. 前述 20 个 `managed_base_snapshot` path。
6. 前述 22 个 `managed_postimage_snapshot` path。
7. 前述 12 个 `managed_patch` path。

CSV 必须与这个独立 builder 的集合 set-equal，每个 pair 恰一行，每行 `is_required=true`。少一个 base/post snapshot、漏掉 freeze archive、额外登记 live target、candidate 改用 stable path、同 path 换 role 或项数不是 71 均返回 `E_REQUIRED_SET`。freeze archive 是只读归档输入，不在 managed target set 中，其 raw/canonical hash 由 transaction file-input manifest 单向绑定。

v5 增加一条通用门：

```text
Set(file_inputs.relative_path outside T) disjoint Set(managed_target_paths)
```

对 contract migration，除 v5 设计文件外，所有可变 base/post 输入都在 `T`中；v5 设计本身不是 managed target。对 chip work package，v4 的 36 项集合保留，但 `contract_design` 改为 v5，coverage policy/approval 改为 stable v5.0 路径。chip package 若要修改任何原本的 live file input，就必须将它从 live input 集合移除，并在自己的 `T/inputs/base|post` 中提供双 snapshot。不允许一个 live path 用单 hash 同时充当 immutable input 和 managed target。

## table image 与 payload universe 分支

### contract migration

contract migration 的 table image path 必须与下列 11 项 set-equal：

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

前九张只允许 `present→present,restore`，两张 factor table 各自必须有恰一条 `absent→present,delete_created` image。每张表的 isolated-mirror postimage 必须同时等于 operations 机械应用结果和对应 `PostSnapshot(table_path)` 原字节。

contract migration 的 payload target 必须与 24 项 set-equal：前述 20 个现有 target 中的活动名单、四个 validator/恢复脚本和六个模板/项目文档，共 11 项；再加 13 个候选稳定 artifact。现有 11 项使用 `present→present,restore`，13 个稳定 artifact 使用 `absent→present,delete_created`。七列名单必须出现在这 24 项中，不得再作为只读 live input。

由此，contract migration 的 managed target 恰有 35 个：11 个 table image 加 24 个 payload。其中 20 个 present preimage 在 rollback 时 restore，15 个 absent preimage 在 rollback 时 delete-created。table path 与 payload target path 仍必须 disjoint，它们的并集与 rollback inventory target set 仍必须 set-equal。

### chip work package

factor table 的 absent→present gate 只存在于 `transaction_kind=contract_migration` 分支。chip work package 必须先在 contract base gate 确认两张 factor table 均 present，schema 分别为 v4 冻结的 9 列与 11 列，且已进入 34-table schema registry。

chip work package 的 image universe 独立定义为：

```text
expected_chip_image_paths = Distinct(operations.table_path)
Set(images.table_path) == expected_chip_image_paths
```

每个 image 都只能 `present→present,restore`。工作包如果实际向 factor table 插入或更新行，对应 table 才进入 image set；没有 factor operation 时不得为它伪造 image。chip work package 不得声明任何 contract base table 的 absent preimage，也不得重复创建 factor table。

chip payload universe 从该 package 的 approved operation/payload authorization 独立构造，不继承 contract migration 的 24 个固定 target。每个目标仍必须有真实 preimage/postimage 和 rollback action。

## 可重放的 phase 状态

`transaction-file-inputs.csv` 只对 `T` 内 immutable bytes、未被管理的 v5 设计文件和只读 freeze archive 重算 hash。它不再从 live target path 读取 schema、enum、field、活动名单、validator 或项目文档的 input hash。四个执行 phase 的输入与现场观察如下：

| phase | immutable input 校验 | live managed state | journal 条件 | 结果 |
|---|---|---|---|---|
| fresh apply | 重算同一组 T bytes | 完整 base | 无冲突 manifest，或同 manifest 最新为 rolled_back+succeeded | 构建 mirror，追加 applying |
| applying resume | 重算同一组 T bytes | 每个 target 恰为自身 preimage 或 postimage | 同 manifest applying+started | 按 path roll-forward |
| applied no-op | 重算同一组 T bytes | 完整 postimage | 同 manifest applied+succeeded | `SUCCESS_NOOP` |
| rollback no-op | 重算同一组 T bytes | 完整 base | 同 manifest rolled_back+succeeded | `ROLLBACK_NOOP` |

如果 T 内任一 snapshot、candidate、approval 或 patch 漂移，所有 phase 均失败。如果 live target 处于未知 hash、存在性与 state 不符、没有 applying event 的混合状态或不同 manifest 的混合状态，执行器保留现场并失败。rollback 开始后只接受 transaction postimage/base 双状态，不接受 applying mixed state。

## factor minimum source 的 actual-row 归约

v4 的 `none/all/any`、actual endpoint、locator、cutoff、selection member 和 source-family 去重规则保留，但 authority/type 的取值算法替换为下列闭合流程。

`BuildQualifyingActualSourceRows(factor)` 从当前 selection run 的 member 开始，连接 factor 已闭合的 assertion/result/evidence、该行实际 `source_id`、该 source 的 actual endpoint、canonical locator 和通过的 cutoff/date rule。结果先按 `source_id` 去重，每行必须实际存在于 `最小参考资料库/sources.csv`，并保留其 `source_family_id,source_type,source_authority`。不读取 `source-families.csv` 中不存在的 authority，也不从 publisher、URL host、title 或 family kind 推测 authority。

然后对每个 `source_family_id=f` 执行：

```text
rows_f = qualifying actual sources.csv rows for family f
types_f = Distinct(rows_f.source_type)
authorities_f = Distinct(rows_f.source_authority)
Require(Count(types_f) == 1)
Require(Count(authorities_f) == 1)
family_tuple_f = (f, Only(types_f), Only(authorities_f))
```

`source_type` 和 `source_authority` 必须非空且命中各自正式 enum。同 family 的多个 endpoint 不会复制 source row；同 family 的多个 qualifying source version 只有在 type 和 authority 两个维度各自 singleton 时才归并成一个 family tuple。任一维度有两个不同值都 fail closed，不取第一行、不取最高 authority、不取并集。错误码固定为 `E_SOURCE_FAMILY_DIMENSION_AMBIGUITY`。

最低 type 门在 `{family_tuple_f.type}` 上计算，最低 authority 门在 `{family_tuple_f.authority}` 上计算。`all` 要求 policy array 中每个 token 被至少一个 family tuple 命中，`any` 要求至少一个 token 被命中，`none` 要求对应 array 为空。两个维度分别计算后取逻辑 AND，不要求同一 family 同时命中两个维度。qualifying family 为空时，任一非 `none` 维度失败；两维均为 `none` 只表示最低来源门没有额外要求，不取代 requirement status 自身的来源闭包。

## mandatory structural N/A 的唯一四键集合

coverage policy contract version 升为 `COVERAGE-POLICY-V5`，stable path 固定为 `审计/合同注册表/coverage-policy-v5.0.json`。coverage manifest/approval contract version 分别升为 `COVERAGE-CONTRACT-V5` 和 `COVERAGE-APPROVAL-V5`。manifest 仍为 v4 已冻结的 58 个 key，不增减 key。

`ga100_mandatory_policy.mandatory_structural_na_rules` 必须与下列六个 complete exact-key JSON object set-equal。item key 顺序固定为 `field_id,precision_path_id,reason_code,structural_na_predicate_id`，按四值 UTF-8 bytes tuple 排序，每个四键 logical key 恰一次：

```json
{"field_id":"FIELD-NUM-ROUNDING","precision_path_id":"PPATH-M2NA-AMPERE-TENSOR-INT8","reason_code":"integer_matrix_no_rounding_stage","structural_na_predicate_id":"PRED-MNA-ROUNDING-INT-MATRIX-V1"}
{"field_id":"FIELD-NUM-SUBNORMAL","precision_path_id":"PPATH-M2NA-AMPERE-TENSOR-INT8","reason_code":"integer_datatype_has_no_subnormal","structural_na_predicate_id":"PRED-MNA-SUBNORMAL-INT-DATATYPE-V1"}
{"field_id":"FIELD-NUM-ROUNDING","precision_path_id":"PPATH-R1-GA100-AMPERE-TENSOR-INT4","reason_code":"integer_matrix_no_rounding_stage","structural_na_predicate_id":"PRED-MNA-ROUNDING-INT-MATRIX-V1"}
{"field_id":"FIELD-NUM-SUBNORMAL","precision_path_id":"PPATH-R1-GA100-AMPERE-TENSOR-INT4","reason_code":"integer_datatype_has_no_subnormal","structural_na_predicate_id":"PRED-MNA-SUBNORMAL-INT-DATATYPE-V1"}
{"field_id":"FIELD-NUM-ROUNDING","precision_path_id":"PPATH-R1-GA100-AMPERE-TENSOR-BINARY","reason_code":"logical_matrix_no_rounding_stage","structural_na_predicate_id":"PRED-MNA-ROUNDING-LOGICAL-MATRIX-V1"}
{"field_id":"FIELD-NUM-SUBNORMAL","precision_path_id":"PPATH-R1-GA100-AMPERE-TENSOR-BINARY","reason_code":"logical_datatype_has_no_subnormal","structural_na_predicate_id":"PRED-MNA-SUBNORMAL-LOGICAL-DATATYPE-V1"}
```

policy.predicates 中下列四个 predicate 对象也是冻结对象。object key 顺序沿用 v4 的 `predicate_id,predicate_scope,all_of,none_of,review_status,notes`，clause key 顺序为 `table_path,column_name,operator,values`。all_of 按下列顺序执行，none_of 固定为空数组：

```json
{"predicate_id":"PRED-MNA-ROUNDING-INT-MATRIX-V1","predicate_scope":"structural_na","all_of":[{"table_path":"数据/precision-paths.csv","column_name":"precision_path_id","operator":"in","values":["PPATH-M2NA-AMPERE-TENSOR-INT8","PPATH-R1-GA100-AMPERE-TENSOR-INT4"]},{"table_path":"数据/precision-paths.csv","column_name":"operation_class","operator":"equals","values":["matrix"]}],"none_of":[],"review_status":"reviewed","notes":null}
{"predicate_id":"PRED-MNA-SUBNORMAL-INT-DATATYPE-V1","predicate_scope":"structural_na","all_of":[{"table_path":"数据/precision-paths.csv","column_name":"precision_path_id","operator":"in","values":["PPATH-M2NA-AMPERE-TENSOR-INT8","PPATH-R1-GA100-AMPERE-TENSOR-INT4"]},{"table_path":"数据/precision-paths.csv","column_name":"operation_class","operator":"equals","values":["matrix"]}],"none_of":[],"review_status":"reviewed","notes":null}
{"predicate_id":"PRED-MNA-ROUNDING-LOGICAL-MATRIX-V1","predicate_scope":"structural_na","all_of":[{"table_path":"数据/precision-paths.csv","column_name":"precision_path_id","operator":"equals","values":["PPATH-R1-GA100-AMPERE-TENSOR-BINARY"]},{"table_path":"数据/precision-paths.csv","column_name":"operation_class","operator":"equals","values":["matrix"]}],"none_of":[],"review_status":"reviewed","notes":null}
{"predicate_id":"PRED-MNA-SUBNORMAL-LOGICAL-DATATYPE-V1","predicate_scope":"structural_na","all_of":[{"table_path":"数据/precision-paths.csv","column_name":"precision_path_id","operator":"equals","values":["PPATH-R1-GA100-AMPERE-TENSOR-BINARY"]},{"table_path":"数据/precision-paths.csv","column_name":"operation_class","operator":"equals","values":["matrix"]}],"none_of":[],"review_status":"reviewed","notes":null}
```

每个 clause 都在 merged data 中以当前 candidate.precision_path_id 精确查找恰一条 `precision-paths.csv` row，再对该行执行 `equals/in`。零行、多行、错 operation class 或路径 ID 不在冻结集合均为 false。validator 还必须要求 policy 中以这四个 ID 命中的完整 predicate object 与上述四项 set-equal，不接受同 ID 不同 clause。

四个 predicate 只证明候选目标落在冻结的 integer/logical matrix path 结构集合。`requirement-evidence.csv` 的 `supports_not_applicable` 行仍要求 actual endpoint、canonical locator 和独立 reviewer，定位内容必须明确支持该 path 的 integer/logical datatype 或 instruction semantics。`applicability_reason` 仍使用 v4 的 `MANDATORY-NA-V1` exact-key JSON，reason code、predicate ID、proof evidence 三者必须按上述六行一一配对。

六格仍是 108 mandatory include 的一部分，candidate decision 仍为 `include,mandatory_include`，并精确引用 same-field/same-path requirement。它们只是 requirement status `not_applicable`，不生成伪 value fact，也不使用 `not_found` 替代结构不适用。其余 102 格继续禁止 mandatory N/A。

## validator 伪代码

### 事务结构门

```text
ValidateTransactionV5(root, tx_dir):
    tx = LoadExactTransactionManifestV1(tx_dir)
    Require(tx.transaction_kind in {contract_migration, chip_work_package})
    ValidateSafePathOnEveryDeclaredPathColumn(tx_dir)

    inputs = LoadStrictFileInputs(tx_dir)
    expected_inputs = BuildRolePathUniverseV5(tx.transaction_kind, tx.transaction_id)
    Require(EachLogicalKeyExactlyOnce(inputs))
    Require(ProjectRolePath(inputs) == expected_inputs)
    Require(All(inputs.is_required == true))
    Require(Set(OutsideT(inputs.relative_path)) disjoint BuildManagedTargetPaths(tx_dir))
    RecomputeEveryImmutableInputFromDeclaredRelativePath(inputs)

    if tx.transaction_kind == contract_migration:
        Require(Count(inputs) == 71)
        bootstrap = LoadBootstrapBundleAndApproval(tx_dir)
        ValidateBootstrapApprovalOneWayNoCycle(bootstrap)
        Require(BootstrapBaseItems(bootstrap) == BuildTwentyBaseSnapshotItems())
        Require(BootstrapPostItems(bootstrap) ==
                BuildTwentyTwoPostSnapshotItems() union
                BuildThirteenStableCandidateItems())
        Require(BootstrapPatchItems(bootstrap) == BuildTwelvePatchItems())
        ValidateLegacySixColumnScopeBaseSnapshot()

    operations = LoadStrictOperations(tx_dir)
    images = LoadStrictTableImagesV2(tx_dir)
    payloads = LoadStrictPayloadInventoryV2(tx_dir)
    rollback_rows = LoadStrictRollbackInventoryV2(tx_dir)
    Require(Set(images.table_path) disjoint Set(payloads.target_path))
    Require(Set(rollback_rows.target_path) ==
            Set(images.table_path) union Set(payloads.target_path))
    ValidateStateNullabilityDomainsAndActions(images, payloads, rollback_rows)
    ValidateEveryOperationHasOneImageAndExactPreInputPostimage(operations, images)
    ValidateEveryPayloadHasExactPreInputPostimage(payloads)

    if tx.transaction_kind == contract_migration:
        Require(Set(images.table_path) == BuildElevenContractTableTargetsV5())
        Require(Set(payloads.target_path) == BuildTwentyFourContractPayloadTargetsV5())
        Require(ProjectOperationKeys(operations) ==
                BuildContractMigrationOperationSetV5(CurrentFormalBase))
        Require(ExactlyOneAbsentToPresentDeleteCreatedImage(
                images, "数据/factor-requirements.csv"))
        Require(ExactlyOneAbsentToPresentDeleteCreatedImage(
                images, "数据/factor-target-bindings.csv"))
        Require(Count(images) == 11 && Count(payloads) == 24)
        Require(ManagedTargetCount(images, payloads) == 35)
        ValidateEveryExistingTargetAgainstBaseAndPostSnapshots()
        ValidateEveryAbsentStableTargetAgainstCandidateAndPostimage()
        ValidateScopeListAllocationMappingAtomicPostimage()
    else:
        ValidateContractBaseIsApplied34TableState()
        Require(FactorTablesPresentWithFrozenSchemas())
        Require(Set(images.table_path) == Distinct(operations.table_path))
        Require(All(images.transition == "present_to_present_restore"))
        ForbidAbsentPreimageForAnyContractBaseTable(images)
        ValidateChipPayloadUniverseFromApprovedPackageAuthorization(payloads)

    RecomputeAndRequireEveryTransactionManifestHash(tx)
    preimage = BuildManagedStateV2(images.preimage, payloads.preimage)
    postimage = BuildManagedStateV2(images.postimage, payloads.postimage)
    Require(Hash(preimage) == rollback.expected_base_preimage_canonical_set_sha256)
    Require(Hash(postimage) == rollback.expected_transaction_postimage_canonical_set_sha256)
    ValidateApprovalDirectionAndNoHashCycleV5(tx, bootstrap if present)
```

```text
ResumeOrApplyV5(root, tx):
    ValidateTransactionV5(root, tx.dir)
    observed = ObserveManagedStateV2(root, tx.targets)

    if observed == tx.postimage and JournalHasAppliedSameManifest(tx):
        RunCompletePostimageGatesWithoutRewrite()
        return SUCCESS_NOOP

    if JournalLatestIsApplyingSameManifest(tx):
        Require(EachTargetIsOwnPreimageOrPostimage(observed, tx))
        RollForwardRemainingTargetsInPathOrderFromImmutableTInputs(tx)
        RunCompletePostimageGates()
        AppendJournal(applied, succeeded)
        return SUCCESS_RESUMED

    Require(observed == tx.preimage)
    Require(JournalAllowsFreshOrPostRollbackApply(tx))
    mirror = BuildAndVerifyIsolatedPostimageFromImmutableTInputs(tx)
    if tx.transaction_kind == contract_migration:
        Require(ScopeMirrorIsSevenColumns49Allocations49Mappings(mirror))
        Require(AllThirteenStableCandidatesPresentAndValid(mirror))
        Require(Counts(mirror) == (34,376,141,77,564))
    AppendJournal(applying, started)
    ReplaceTargetsInPathOrder(mirror)
    RunCompletePostimageGates()
    AppendJournal(applied, succeeded)
    return SUCCESS_APPLIED
```

```text
RollbackV5(root, tx):
    ValidateTransactionV5(root, tx.dir)
    observed = ObserveManagedStateV2(root, tx.targets)
    if observed == tx.preimage and JournalHasRolledBackSameManifest(tx):
        return ROLLBACK_NOOP
    if JournalLatestIsRollbackApplyingSameManifest(tx):
        Require(EachTargetIsOwnPostimageOrPreimage(observed, tx))
        ContinueRestoreOrDeleteCreatedInPathOrder(tx)
    else:
        Require(observed == tx.postimage and JournalHasAppliedSameManifest(tx))
        AppendJournal(rollback_applying, started)
        RestoreOrDeleteCreatedInPathOrder(tx)
    Require(ObserveManagedStateV2(root, tx.targets) == tx.preimage)
    if tx.transaction_kind == contract_migration:
        Require(LiveScopeIsSixColumns49Rows())
        Require(AllFifteenCreatedTargetsAbsent())
    AppendJournal(rolled_back, succeeded)
    return SUCCESS_ROLLED_BACK
```

### coverage 新增门

```text
ValidateCoveragePackageV5(...):
    ValidateCoveragePackageV4UnchangedGates(...)
    Require(coverage_policy.contract_version == "COVERAGE-POLICY-V5")
    Require(manifest.contract_version == "COVERAGE-CONTRACT-V5")
    Require(approval.contract_version == "COVERAGE-APPROVAL-V5")

    rules = policy.ga100_mandatory_policy.mandatory_structural_na_rules
    Require(EachFourKeyExactlyOnce(rules))
    Require(rules == BuildSixFrozenMandatoryNaRuleObjectsV5())
    Require(SelectPredicates(policy, FourFrozenMandatoryPredicateIds) ==
            BuildFourFrozenMandatoryPredicateObjectsV5())
    ValidateSixMandatoryNaRulePredicateReasonEvidencePairings()

    rows = BuildQualifyingActualSourceRowsForEveryFactor()
    family_tuples = ReduceEachFamilyToSingletonTypeAndAuthorityOrFail(rows)
    ValidateMinimumSourceModesOverFamilyTuples(family_tuples)

    RecomputeAndRequireAll58CoverageManifestHashes()
```

v4 coverage validator 中的 141 field 全集、108 mandatory include、factor obligation/candidate/binding exactly-one、normal selector、actual endpoint、locator、cutoff、reconciliation、derived closure 和 reverse-removal 调用顺序不变。本节的 N/A 四键门必须在作者自报 requirement status 之前运行；family singleton 门必须在 `all/any` 计算之前运行。

## v5 fixture 与反例

v4 的全部 mandatory fixture 继续保留。v5 追加下列 fixture family，每个 fixture 仍要有 `powershell_5_1,powershell_7,python_3` 三行独立 runtime result。positive 的 hex/hash 逐字相同，negative 的 error code 逐字相同。

| fixture family | positive | negative |
|---|---|---|
| `bootstrap_scope_fresh` | 六列 49 行，allocation/mapping absent，13 个 stable artifact absent，T candidate 完整；mirror 得到七列+49+49 | 事务外先改七列、只有 allocation、只有 mapping、少一 candidate、stable target 被预创建 |
| `bootstrap_scope_applied_noop` | 35 target 完整 postimage、applied event、同一 T input，返回 `SUCCESS_NOOP` | file input 仍指 live preimage hash、T post snapshot 漂移、七列名单与 allocation row hash 不等 |
| `bootstrap_scope_rollback_noop` | 20 target 恢复 base、15 个 created target absent、rolled_back event，返回 `ROLLBACK_NOOP` | factor table 留 header、stable registry 留空文件、六列名单未恢复 |
| `bootstrap_mixed_resume` | applying event 下每个 target 恰为自身 pre/post，从 T roll-forward | 无 applying event、不同 manifest、unknown hash、allocation 只写入部分行 |
| `factor_migration_create` | contract migration 两张 absent→present image | chip package 宣称 absent→present、迁移少一 factor image |
| `factor_chip_update` | contract base 两表 present，chip insert 产生 present→present image | 无 factor operation 却伪造 image、有 operation 却漏 image、unconditional creation gate |
| `immutable_target_input` | live target 只在 image/payload 观察，base/post 输入都在 T | 同一 live path 兼 file input 与 target、fresh hash 用于 applied no-op、post hash 用于 fresh |
| `family_dimension_reduction` | 同 family 多 endpoint、多 source version但 type/authority 各 singleton，归约为一 tuple | authority 两值、type 两值、取第一行、取并集、读取不存在的 family.authority |
| `mandatory_na_four_key` | 六个完整 rule object 与四个冻结 predicate object 逐项相等 | 第四键悬空、错 predicate ID、rounding/subnormal 交叉配对、integer/logical 交叉配对、只投影前三键、同 ID 改 clause |
| `bootstrap_approval_dag` | candidate→artifact approval→bootstrap→transaction 拓扑排序完整 | candidate 引用 bootstrap hash、bootstrap 引用自身 approval、rollback/transaction 互引 |

fixture 还必须分别固定 four-state managed-state rowset：fresh base、applying mixed、complete postimage 和 complete rolled-back base。四个 fixture 使用同一 transaction ID、同一 immutable input raw set 和同一 target universe，只改变 journal 与 observed managed state。这个约束直接验证 fresh/apply/no-op/rollback-noop 没有依赖单个 live input hash。

## 迁移顺序

1. 只读冻结当前 32 张正式表、六列活动名单、四个 validator/恢复脚本和六个模板/项目文档，写入 `T/inputs/base/`。这一步不创建 stable registry。
2. 在 `T/inputs/bootstrap/targets/` 生成 13 个 candidate artifact。legacy disposition 仍要对 1,059 行、29 个重复键组和 26 条 pending 独立复核；scope candidate 按本稿一次构造 49 allocation 和 49 mapping。
3. 在 T 中生成正式 table/payload 的全部 post snapshot 和 12 个 patch。三运行时先通过 v4 保留 fixture 和 v5 新增 fixture，再批准 candidate fixture manifest。
4. 按单向顺序生成 artifact approval、bootstrap manifest 和 bootstrap approval。bootstrap 批准后，`T/inputs/` 所有文件的字节冻结，任一变化要求换新 bootstrap bundle ID。
5. 构造 contract migration 的 exact operations、11 table images、24 payload rows、71 file inputs 和 35 rollback rows。isolated mirror 必须同时通过 34/376/141/77/564、832 AFPV2、49 allocation/49 mapping、legacy baseline、fixture、scope、source、recovery 和 Windows 数据门。
6. 通过独立 transaction approval 后才能 apply。apply 成功后，稳定 policy/approval/registry/fixture/formula 从 `审计/合同注册表/` 读取；T 内 candidate 继续作为事务恢复证据。
7. GA100 chip work package 从 applied contract state 生成，不重复创建 factor table。minimum source 先做 family singleton 归约，mandatory N/A 先做六个四键 rule 与四个 predicate object 门，再继续 v4 的 closure 和 reverse-removal。

## v4 到 v5 exact repair crosswalk

| R10 blocker | v5 替换条款 | 被拒绝的反例 |
|---|---|---|
| 1. 六列名单与 absent scope/prerequisite 没有原子 bootstrap | 活动名单加入 raw payload target；49 allocation、49 mapping 与其他 13 个 stable artifact 从 T candidate 在同一 contract migration absent→present；bootstrap approval DAG 不自引 | 事务外先改名单、事务外先建 registry、只切换名单/allocation/mapping 其一、rollback 后留稳定文件 |
| 2. chip transaction 被强制再创建 factor table | absent→present factor gate 移入 contract branch；chip 的 image set 等于自身 operation table set，factor table 作为 present base | chip preflight 声明 absent、无 operation 伪造 factor image、有 operation 却漏 image |
| 3. live target 单 hash 无法跨 fresh/apply/no-op | 20 个 immutable base snapshot、22 个普通 post snapshot、13 个 stable candidate、12 个 patch 全部放在 T；outside-T file input 与 managed target disjoint | preimage hash 在 post-noop 失配、postimage hash 在 fresh 失配、同 live path 同时是 input/target |
| 4. authority 读取不存在的 family 列 | 从 actual qualifying `sources.csv` rows 开始，按 family 对 type 和 authority 分别要求 singleton，再生成唯一 family tuple | 取第一行、取最高 authority、一 family 用多 type 并集同时满足 all、读 family.authority |
| 5. 六个 N/A 三键与四键无法 set-equal | 列出六个完整 exact object，冻结四个 predicate ID 及它们的可执行 clause，rule 与 predicate object 分别 set-equal | 只比较前三键、错 predicate、rounding/subnormal 交叉、第四键悬空、同 ID 改 clause |

同类矛盾也一并关闭。任何未存在的稳定 prerequisite 都要进入 candidate bundle 和 absent→present target；任何被修改的 live file 都不能以单 hash live input 身份出现；任何 family-level 属性都必须由 actual source rows 经唯一归约得到；任何 policy rule 新增第四键时都必须用完整 object set-equal，不得默认投影。

## 计数与 hash 影响

| 项目 | v5 结果 | 影响 |
|---|---:|---|
| 正式 tables / schema columns / fields / enum groups / enum rows | `34 / 376 / 141 / 77 / 564` | 与v4一致，无需为 R10 修复新增正式列、field 或 enum |
| 活动名单 | 49 行，6 列→7 列 | 49 个 active-scope row canonical hash 全部新生成；active schema hash 使用 v4 七列 contract |
| scope allocation / mapping | `49 / 49` 首次创建 | registry raw/canonical hash、registries postimage hash、managed postimage hash 全部新生成 |
| contract table images / payloads / managed targets | `11 / 24 / 35` | table image、payload inventory、rollback inventory、managed-state 与 transaction manifest hash 全部重算 |
| present restore / absent delete-created target | `20 / 15` | base/post managed-state 与 fresh/rollback fixture 重算 |
| contract file inputs | `71` | 包含 freeze archive；file input raw/canonical set、count、bootstrap manifest/approval 和 transaction manifest 重算 |
| input role enum | `41` token | v4 36 token 加 5；fixture manifest 和 enum negative fixture 重算 |
| coverage manifest | 58 key | key 数不变；contract version、policy path/hash、closure hash 和 approval hash 重算 |
| mandatory key | 108 | key set/hash 不变；六个 N/A rule object、四个 predicate object、policy hash 和 proof closure hash 重算 |
| source families / sources schema | 92 / 93 当前行数，正式列不变 | 不新增 family authority 列；minimum-source 结果、closure 和 reverse-removal hash 按 actual-row 算法重算 |

formal row operation universe 仍由 v4 的 exact migration builder 产生，R10 修复没有增加正式 CSV 行语义变更。实现时必须从当前 preimage 和冻结 post snapshot 重算 operation count，不得为了匹配报告中的某个手写总数而缩减 operation set。

## 验收边界

独立设计验收要先确认本文件是唯一新增文件，再核对五个冻结输入 SHA-256，最后按 crosswalk 构造 fresh、mixed、applied no-op、rollback no-op、family ambiguity 和 mandatory N/A 反例。设计验收通过只表示可以进入审计区实现，不等于 contract migration 已应用，不等于 GA100 资料卡完成，也不等于 PowerShell 5.1、PowerShell 7、Python 3 或 Windows 数据门已运行。
