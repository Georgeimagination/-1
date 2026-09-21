# `FIELD-ID-RELEASE-DATE` 语义迁移设计 v2

设计日期：2026-08-21  
前一版：`r1_release_date_01_semantic_migration_design.md`  
修订依据：`r1_release_date_02_semantic_migration_independent_review.md`，SHA-256 `37df92433b7ff969c592a90923057d25570738ff1f6930d92297694d4b53037b`  
本轮边界：只新增本设计稿。没有修改 v1、contract v7、正式表、任何 staging、资料卡、模板、验证器或进度文件。

## 修订结论

R02 的 `reject` 接收。v1 的语义裁决保持不变，事务合同全部重做。新方案把保守语义退出固定为 v7 正式应用后的独立 contract amendment，版本为 v7.1，事务 ID 固定为 `TX-RDATE-V71-SEMANTIC-EXIT-20260821`。它有唯一的 81 条正式行 operation、25 个 managed payload、13 张 table image 和 38 个 rollback target。任何实施候选与这些集合不相等都拒绝。

v7.1 不覆盖 v7 发布的 `coverage-policy-v5.0.json` 或其 approval。它创建 `coverage-policy-v5.1.json` 和新的 approval，再由 `release-date-contract-amendment-v7.1.json` 及其 approval 建立唯一 active binding。v5.0 两个文件保持 byte-for-byte 不变。v7.1 生效前，GA100 仍受 v5.0 的 `deferred_blocking` 阻断；v7.1 生效后，后续 GA100 transaction 必须把 amendment/approval 和 v5.1 policy/approval 当作 immutable inputs，缺一项或 hash 不等即 fail closed，不得回退到 v5.0 继续实施。

本稿所称 Phase A 仅指 `TX-RDATE-V71-SEMANTIC-EXIT-20260821`。它使用当前已经固定、已经能够复核的材料退出旧语义，不新增 fact、requirement、source、endpoint、requirement-evidence、search-log 或 search-result。需要重新搜索、插入证据链或把候选升为事实的工作全部属于之后的 Phase B。Phase B 使用新的 transaction ID、base snapshot、authorization、approval、selection cutoff、rollback 和 journal；它不是 Phase A 的第二个批准阶段。

## 不变的字段语义和逐行方向

v7.1 的字段名逐字为：

```text
首次公开日期
```

定义逐字为以下 188-byte UTF-8 文本，SHA-256 为 `757e9a1275f9bbe1381fbbad06a24c0992689ebbe45cd22cd71305031ce6f41b`：

```text
厂商或设计方在具日期、可核验的正式材料中首次直接命名/宣布该研究对象；不能用上位架构预告、下位产品发布、availability/shipping/sales 替代
```

Phase A 的终态固定如下：Trainium2 architecture 和 MI455X module 的旧 fact 为 `rejected`；Ascend 950 Die、950PR、950DT 保留 `2025-09-18/provisional`；6 条 requirement 全为 `pending_verification/in_progress`；accepted release fact 与 value-available requirement 两集合都为空。MLU590 的 2022-09-02 官方材料和 MI350P 的 2026-05-07 官方文章只进入现有 pending/search candidate 链。GA100 `2020-05-14` 仍是强候选，不在 Phase A 生成 requirement、fact、source 或 endpoint。

## v7.1 的前置和版本路径

Phase A 只能从已经 apply 的 v7 postimage 启动。前置必须同时满足：v7 设计文件 SHA-256 为 `2e896d97e2f87496785e1f466300a7992cf66d778c8f6196274ccc2e00bd8258`；live 计数为 `34 tables / 376 schema columns / 141 fields / 77 enum groups / 564 enum rows`；832 条 assertion 全为 AFPV2；`fact-assertions.csv`、`requirement-evidence.csv` 和 `search-results.csv` 已有 v7 的 endpoint 列；v5.0 policy/approval 已受 v7 transaction manifest 绑定且 gate 为 `deferred_blocking`。任何一项不成立，返回 `E_RDATE_V7_PREREQUISITE`。

唯一版本链为：

```text
v7 applied contract
  -> immutable coverage-policy-v5.0 + approval
  -> TX-RDATE-V71-SEMANTIC-EXIT-20260821
  -> coverage-policy-v5.1 + approval
  -> release-date-contract-amendment-v7.1 + approval
  -> v7.1 active contract
  -> later independent GA100 or release-date evidence transaction
```

`coverage-policy-v5.0.json`、`coverage-policy-v5.0-approval.json` 以及 v7 transaction manifest/approval 都是 no-write guards。v7.1 不创建可变 active pointer。验证器按以下规则解析 active policy：恰有一个 approved `CONTRACT-AMENDMENT-RELEASE-DATE-V7.1`，且 base v7 hash、v5.0 hash、v5.1 hash、三个 expected set hash、全部 approval hash 和 live core-managed-state hash全部相等时，active policy 为 v5.1。amendment approval 在 apply 中最后发布，因而它本身是 activation marker。只有在 amendment/approval 均不存在且 live core 仍与 v7 preimage 全等时才解析为 v5.0；只有 amendment 而无 approval、core 已漂移却无 approval、出现两个候选，或任一 hash 不符时都 fail closed。transaction manifest 保留唯一实施路径和 authorization 证据，不反向进入 amendment bytes。

v5.1 沿用 v5.0 的完整顶层 key 顺序，只做以下固定变化：

```text
coverage_policy_contract_version = COVERAGE-POLICY-V5.1
policy_id = COVERAGE-POLICY-V5.1-RELEASE-DATE
effective_date = 2026-08-21
supersedes_policy_id = ExactString(BaseV5Policy.policy_id)

release_date_semantics_gate.current_effective_field_name_zh = 首次公开日期
release_date_semantics_gate.current_effective_definition = <188-byte definition>
release_date_semantics_gate.target_field_name_zh = 首次公开日期
release_date_semantics_gate.target_definition = <188-byte definition>
release_date_semantics_gate.migration_status = applied
release_date_semantics_gate.ga100_pre_migration_requirement_status = pending_verification
release_date_semantics_gate.legacy_fact_ids = <exact 5-set>
release_date_semantics_gate.legacy_requirement_ids = <exact 6-set>
release_date_semantics_gate.review_status = reviewed
```

其余 key、array、rule 和 nested object 与 v5.0 byte/canonical-equal。`applied` 是 v5.1 policy schema 的受控 token，不写入正式 `enums.csv`。policy approval 使用既有 9-key `ARTIFACT-APPROVAL-V1`，`approval_id=APPROVAL-COVERAGE-POLICY-V5.1-RELEASE-DATE`、`artifact_kind=coverage_policy`、`artifact_id=COVERAGE-POLICY-V5.1-RELEASE-DATE`，单向绑定 `json-policy-v1` canonical hash。

新增 amendment manifest 的 stable path 为 `审计/合同注册表/release-date-contract-amendment-v7.1.json`。它固定 22 个顶层 key，顺序如下：

```text
amendment_contract_version
amendment_id
base_contract_design_path
base_contract_design_raw_sha256
base_transaction_manifest_canonical_sha256
base_transaction_approval_canonical_sha256
base_policy_id
base_policy_canonical_sha256
base_policy_approval_canonical_sha256
active_policy_id
active_policy_canonical_sha256
active_policy_approval_canonical_sha256
semantic_version
definition_utf8_sha256
active_reference_closure_canonical_sha256
semantic_disposition_canonical_sha256
expected_operation_target_set_sha256
expected_payload_target_set_sha256
expected_core_managed_post_raw_set_sha256
prepared_by
reviewed_by
review_status
```

前三个 version/ID 值分别为 `RELEASE-DATE-CONTRACT-AMENDMENT-V1`、`CONTRACT-AMENDMENT-RELEASE-DATE-V7.1` 和 v7 路径；semantic version 固定 `RELEASE-DATE-SEMANTICS-V1`。review status 为 `reviewed`，prepared/reviewed 身份不同。三个 expected hash 分别绑定本稿的 81 operation target set、25 payload target set，以及不含 amendment/approval 自身的 core managed post raw set。manifest domain 为 `release-date-contract-amendment-v1`。对应 approval path 为 `审计/合同注册表/release-date-contract-amendment-v7.1-approval.json`，复用 9-key approval schema，ID 为 `APPROVAL-CONTRACT-AMENDMENT-RELEASE-DATE-V7.1`，artifact kind 为 `release_date_contract_amendment`。manifest 不含自身 approval、operation authorization 或 transaction manifest hash；下游 transaction manifest 再单向绑定 amendment/approval 和 authorization/approval。这是唯一路径，避免 amendment bytes 与 authorization bytes 互相决定。

## ActiveReferenceClosure 的机械构造

构造器只读 v7 live postimage，不遍历 audit/staging/backup 猜测 active 状态。它按以下步骤生成集合：

```text
F0 = exactly one fields row where field_id == FIELD-ID-RELEASE-DATE
F1 = facts rows where field_id == FIELD-ID-RELEASE-DATE
R1 = requirement rows where field_id == FIELD-ID-RELEASE-DATE
E1 = assertions where fact_id in PK(F1)
E2 = requirement-evidence where requirement_id in PK(R1)
S1 = search-log where requirement_id in PK(R1)
S2 = search-results where search_id in PK(S1)

SourceIds = distinct source_id from E1 union E2 union S2
SourceRows = sources where source_id in SourceIds
FamilyRows = source-families reached from SourceRows
EndpointRows = source-endpoints where source_id in SourceIds
ScreenRows = source-screening where source_id in SourceIds
RoleRows = source-selected-roles where source_id in SourceIds
CoverageRows = source-coverage where covered_source_id or covering_source_id in SourceIds

TargetIds = exact object targets from F1 union R1
CompletenessRows = card-completeness where object_id in TargetIds
                   and domain in {identity,evidence}

EffectiveSelectionRuns = for every affected scope, the unique reviewed/approved
                         run having the maximum cutoff_date
CurrentSelectionMembers = selection-members whose source_id in SourceIds
                          and run_id in PK(EffectiveSelectionRuns)
CurrentSelectionRuns = runs referenced by CurrentSelectionMembers
HistoricalGuards = the same source projection where run.status == superseded
PayloadRows = exact registered path set below
```

正式 row item 的 canonical identity 是 `[logical_table_path,primary_key]`，按两项 UTF-8 bytes tuple 排序；domain 为 `release-date-active-reference-set-v1`。payload item 是 logical path string，按 UTF-8 bytes 排序；domain 为 `release-date-active-payload-set-v1`。排序后的整个集合序列化为 UTF-8 canonical JSON array，不带 BOM、空白或末尾换行。两种 hash 都使用 v7 framing：`SHA256(UTF8(domain) || 0x00 || UINT64_BE(payload_length) || payload)`。

### 预期正式集合

| 集合 | 数量 | canonical identity-set SHA-256 |
|---|---:|---|
| field | 1 | `33aaffe061184aab8c91415cf0ea48b26a754937212135ec2b1bfe4baf0ace04` |
| facts | 5 | `6bbc0feb114283890f2909f74e84d85ab668f2644639bf6be1c9a49ed13ee270` |
| requirements | 6 | `a05d244bb94b06fcfee6fbd913df145aecc13179c40aa17504364695368c91b4` |
| assertions | 5 | `4f9b0a16dd0f88a23b1be7da8752f131bb8c32c3293149a8218f084ea4daea97` |
| requirement evidence | 1 | `db2d4f1e93e50c4ab47f98eae75199696ee23c79e2dc0f138cd13d7350c4f000` |
| search logs | 2 | `a825eb1ae8cb9fbd3451e33f02fd8c29fa5ace159448607db102afae766e294e` |
| search results | 4 | `f0d3fec7c88fe96269aeed84ad36d80c4a8dc6f7ff04d082f39a764f3727bcd2` |
| source families / versions / endpoints | 7 / 7 / 13 | `1bc694c036e7eebb56a6f2c1022cdad10e0e4704bcff9a0306d820942c1aa35c / 9a66efb58d8eed067658e9772a4be3a8ae7528466620d106e3ab18c36b61c9cc / 92c17cad0c49d768f2b98936b09fbf4c53c362511d5832e59bdde16bf29685e8` |
| screening / selected roles / coverage | 7 / 12 / 8 | `5e87d255cf20b93b2f36788fe0e99b645dc876d691e142b0643d40969d2077e1 / e0563eed45f4d70c715a11c2b28ff0180a84ba64f98241a5199be9ec13b2675b / 3f3ca4854a7dc2455b0c39621df9ed08dfc8af39f35321fd5f3f426973189bd4` |
| current runs / affected current members | 4 / 7 | `c575cbf827b6f8660bad5ce729c880a281cf207a40a6149025988008119bd6ca / cd08171e5405b3bae5fcba918ebc59e8d070ac0ea18a5ea81cf7832722bf7893` |
| identity/evidence completeness | 14 | `4e442994e72190e26283a68067b15e5c410cee72548fc99afb55ec4f9b3acf76` |

前述 active 正式集合合计 103 个 identity，整体 hash 为 `30c27efefddc8ad98a035a880e855f297517b1de9674059d4e8852e05cdaa9b0`。再加 1 个 superseded run 与其中 2 个相关 historical member 后，guard 集合为 106 个 identity，hash 为 `efec06a6965ed3c19fbcfa40a230f0b3901006070bdb181cf018b71a10e6228e`。builder 必须从下列 exact ID 复算并与表内完整 hash 比较，不得以数量相等代替 set-equal。

核心 5 fact、6 requirement 和 12 条 evidence/search ID 沿用 R13 与 R02 的 exact 集合。其余 expected IDs 固定为：

```text
Source families:
SFAM-AWS-TRN2-S11
SFAM-CAMBRICON-WAIC-2022-MLU590
SFAM-M2W3-AMD-MI350P-BLOG
SFAM-M2W3-AMD-MI350P-BROCHURE
SFAM-M2W3-AMD-MI350P-PRODUCT
SFAM-M2W3-AMD-MI455X-PRODUCT
SFAM-M2W3-HUAWEI-H2-ASC950-KEYNOTE

Sources:
SRC-2022-CAMBRICON-WAIC-MLU590
SRC-AWS-TRN2-S11
SRC-M2W3-AMD-MI350P-BLOG-20260507
SRC-M2W3-AMD-MI350P-BROCHURE-202605
SRC-M2W3-AMD-MI350P-PRODUCT-20260813
SRC-M2W3-AMD-MI455X-PRODUCT-20260813
SRC-M2W3-HUAWEI-H2-ASC950-KEYNOTE-20250918

Endpoints:
END-AWS-TRN2-S11-HTML
END-AWS-TRN2-S11-SNAPSHOT
END-CAMBRICON-WAIC-2022-MLU590-HTML
END-CAMBRICON-WAIC-2022-MLU590-SNAPSHOT
END-M2W3-AMD-MI350P-BLOG-REMOTE
END-M2W3-AMD-MI350P-BLOG-SNAPSHOT
END-M2W3-AMD-MI350P-BROCHURE-LOCAL
END-M2W3-AMD-MI350P-BROCHURE-REMOTE
END-M2W3-AMD-MI350P-PRODUCT-REMOTE
END-M2W3-AMD-MI350P-PRODUCT-SNAPSHOT
END-M2W3-AMD-MI455X-PRODUCT-REMOTE
END-M2W3-AMD-MI455X-PRODUCT-SNAPSHOT
END-M2W3-HUAWEI-H2-SNAPSHOT
```

```text
Screening:
SCREEN-AWS-TRN2-S11
SCREEN-CAMBRICON-WAIC-2022-MLU590
SCREEN-M2W3-AMD-MI350P-BLOG
SCREEN-M2W3-AMD-MI350P-BROCHURE
SCREEN-M2W3-AMD-MI350P-PRODUCT
SCREEN-M2W3-AMD-MI455X-PRODUCT
SCREEN-M2W3-HUAWEI-H2

Selected roles:
M2W3-HUAWEI-SROLE-H2-CORE
M2W3-HUAWEI-SROLE-H2-ID
M2W3-HUAWEI-SROLE-H2-STATUS
SROLE-AWS-TRN2-017
SROLE-CAMBRICON-WAIC-IDENTITY
SROLE-CAMBRICON-WAIC-STATUS
SROLE-M2W3-AMD-MI350P-BLOG-STATUS
SROLE-M2W3-AMD-MI350P-BROCHURE-CORE
SROLE-M2W3-AMD-MI350P-PRODUCT-CORE
SROLE-M2W3-AMD-MI350P-PRODUCT-IDENTITY
SROLE-M2W3-AMD-MI455X-PRODUCT-CORE
SROLE-M2W3-AMD-MI455X-PRODUCT-IDENTITY

Coverage:
COV-CAMBRICON-WAIC-NOT-COVERED-BY-MLUOPS
COV-M2W3-AMD-CDNA5-NOT-EQUIV-PRODUCT
COV-M2W3-AMD-MI350P-BLOG-NOT-EQUIV-PRODUCT
COV-M2W3-AMD-MI350P-BROCHURE-BY-PRODUCT
COV-M2W3-AMD-MI350P-PRODUCT-BY-BROCHURE
COV-M2W3-AMD-MI400-NOT-EQUIV-PRODUCT
COV-M2W3-AMD-MI455X-BROCHURE-BY-PRODUCT
COV-M2W3-AMD-MI455X-PRODUCT-BY-BROCHURE
```

```text
Current runs:
SELRUN-M1-PILOTS-TRN2-CORRECTED-20260813
SELRUN-M2W3-AMD-MI350P-20260813
SELRUN-M2W3-AMD-MI455X-20260813
SELRUN-M2W3-HUAWEI-ASC950-PHYSICAL-20260813

Affected current members:
SELMEM-M1R2-2022-CAMBRICON-WAIC-MLU590
SELMEM-M1R2-AWS-TRN2-S11
SELMEM-M2W3-AMD-MI350P-BLOG
SELMEM-M2W3-AMD-MI350P-BROCHURE
SELMEM-M2W3-AMD-MI350P-PRODUCT
SELMEM-M2W3-AMD-MI455X-PRODUCT
SELMEM-M2W3-HUAWEI-H2

Historical no-write guards:
SELRUN-M1-PILOTS-20260812
SELMEM-M1-2022-CAMBRICON-WAIC-MLU590
SELMEM-M1-AWS-TRN2-S11
```

```text
Completeness:
COMPLETE-CAMBRICON-MLU590-IDENTITY
COMPLETE-CAMBRICON-MLU590-EVIDENCE
COMPLETE-M2GA-AWS_TRAINIUM2_ARCH-IDENTITY
COMPLETE-M2GA-AWS_TRAINIUM2_ARCH-EVIDENCE
COMPLETE-M2W3-AMD-MI455X-IDENTITY
COMPLETE-M2W3-AMD-MI455X-EVIDENCE
COMPLETE-M2W3-AMD-MI350P-IDENTITY
COMPLETE-M2W3-AMD-MI350P-EVIDENCE
CC-M2W3-HUAWEI-ASC950-DIE-IDENTITY
CC-M2W3-HUAWEI-ASC950-DIE-EVIDENCE
CC-M2W3-HUAWEI-ASC950-PR-IDENTITY
CC-M2W3-HUAWEI-ASC950-PR-EVIDENCE
CC-M2W3-HUAWEI-ASC950-DT-IDENTITY
CC-M2W3-HUAWEI-ASC950-DT-EVIDENCE
```

### 预期 payload 集合

active preimage payload 恰为以下 18 路径，set hash 为 `a8d17c5f560f191e4d2bcf77a2a027736324285087b0d8fcdc17c43f7c7ccf0c`：

```text
资料卡/寒武纪/MLU590_试填草稿.md
资料卡/AWS/Trainium2_试填草稿.md
资料卡/AWS/架构/AWS_Trainium2_架构卡.md
资料卡/AMD/封装/AMD_Instinct_MI455X_模组资料卡.md
资料卡/AMD/产品/AMD_Instinct_MI350P_PCIe_卡资料卡.md
资料卡/华为昇腾/封装/华为_Ascend950_共享裸片资料卡.md
资料卡/华为昇腾/封装/华为_Ascend950PR_封装资料卡.md
资料卡/华为昇腾/封装/华为_Ascend950DT_封装资料卡.md
资料卡/AWS/架构/sources/trainium2_existing_reuse_map.csv
资料卡/字段字典.md
资料卡/模板.md
研究计划.md
AGENTS.md
README.md
scripts/validation/Validate-ResearchData.ps1
scripts/validation/Test-ChipScope.ps1
审计/合同注册表/coverage-policy-v5.0.json
审计/合同注册表/coverage-policy-v5.0-approval.json
```

内容检查只扫描 UTF-8 Markdown/CSV/JSON/PowerShell 的 active roots，精确匹配字段 ID、旧/新字段名、5 fact ID、6 requirement ID、7 source ID 和候选日期与对象的同段共现。命中上述 18 路径以外的 active 文件时报 `E_RDATE_REFERENCE_EXTRA`；expected 路径没有命中时报 `E_RDATE_REFERENCE_MISSING`。`审计/子代理交接/**`、归档、staging、事务 base/rollback 和进度目录只进入 history inventory，不改写。

## Phase A 的 5 fact、6 requirement 与证据链

下文只列变化 cell；其余 cell 从 v7 preimage 逐字复制。每个 update 的 operation payload 保存完整 post row，不能由说明文字临时拼接。

### facts

| fact | v7 exact core preimage | exact post change |
|---|---|---|
| `FACT-AWS-TRN2-ARCH-RELEASE-DATE` | `OBJ-AWS-TRAINIUM2-ARCH / 2023-11-28 / single_source / accepted / high / reviewed` | target/value保留；`evidence_state=source_with_caveat`；`resolution_state=rejected`；`confidence=low`；`review_status=needs_resolution`；notes=`S11 directly names the Trainium2 chip family/chips, not OBJ-AWS-TRAINIUM2-ARCH; retained as a rejected historical row.` |
| `FACT-M2W3-AMD-MI455X-RELEASE-DATE` | `OBJ-AMD-MI455X / 2026-07-23 / single_source / provisional / high / reviewed` | target/value保留；`evidence_state=source_with_caveat`；`resolution_state=rejected`；`confidence=low`；`review_status=needs_resolution`；notes=`The dynamic GPU page has no publication_date and its Launch Date does not directly name the formal module target.` |
| `FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE` | `OBJ-HUAWEI-ASCEND-950-DIE / 2025-09-18 / single_source / provisional / high / reviewed` | target/value/evidence/resolution保留；`confidence=medium`；`review_status=needs_resolution`；notes=`H-2 directly names the exact Ascend 950 Die on 2025-09-18; this is a candidate and the earlier formal disclosure search remains open.` |
| `FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE` | `OBJ-HUAWEI-ASCEND-950PR / 2025-09-18 / single_source / provisional / high / reviewed` | target/value/evidence/resolution保留；`confidence=medium`；`review_status=needs_resolution`；notes=`H-2 directly names exact Ascend 950PR on 2025-09-18; this is a candidate, the earlier search remains open, and Q1 availability is excluded.` |
| `FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE` | `OBJ-HUAWEI-ASCEND-950DT / 2025-09-18 / single_source / provisional / high / reviewed` | target/value/evidence/resolution保留；`confidence=medium`；`review_status=needs_resolution`；notes=`H-2 directly names exact Ascend 950DT on 2025-09-18; this is a candidate, the earlier search remains open, and Q4 availability is excluded.` |

### requirements

6 行的 `requirement_status/search_status/review_status` 统一为 `pending_verification/in_progress/needs_resolution`。`last_searched_date` 保留各自 preimage，Phase A 不伪造新检索日期。除 reason/notes 和这三个状态外，其余 cell 逐字复制 v7 preimage。exact pre/post 为：

| requirement | v7 status preimage | exact post reason / notes |
|---|---|---|
| `REQ-CAMBRICON-MLU590-RELEASE-DATE` | `pending_verification/in_progress/draft` | reason=`The dated 2022-09-02 first-party material directly names 思元590; the MLU590 identity bridge and earlier formal disclosure search remain open.` notes=`Candidate retained; supply/GA is a separate lifecycle field.` |
| `REQ-M2W3-AMD-MI455X-RELEASE-DATE` | `value_available/completed/reviewed` | reason=`No dated formal material in the frozen source set directly names the formal MI455X module target.` notes=`Legacy canonical-fact closure withdrawn; run an exact-module earliest formal disclosure search.` |
| `REQ-M2W3-AMD-MI350P-RELEASE-DATE` | `not_found/completed/reviewed` | reason=`The dated 2026-05-07 AMD exact-card article is a first-public candidate; earlier formal disclosure search remains open.` notes=`The brochure has only a month label and the dynamic product page lacks a material publication date.` |
| `REQ-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE` | `value_available/completed/reviewed` | reason=`H-2 is a dated exact-die candidate for 2025-09-18; a die-specific earlier formal disclosure search remains open.` notes=`Architecture, sibling product, availability, shipping, and sales do not satisfy this requirement.` |
| `REQ-M2W3-HUAWEI-ASC950PR-RELEASE-DATE` | `value_available/completed/reviewed` | reason=`H-2 is a dated exact-PR candidate for 2025-09-18; a PR-specific earlier search remains open and Q1 availability is excluded.` notes=`Architecture, sibling product, availability, shipping, and sales do not satisfy this requirement.` |
| `REQ-M2W3-HUAWEI-ASC950DT-RELEASE-DATE` | `value_available/completed/reviewed` | reason=`H-2 is a dated exact-DT candidate for 2025-09-18; a DT-specific earlier search remains open and Q4 availability is excluded.` notes=`Architecture, sibling product, availability, shipping, and sales do not satisfy this requirement.` |

### assertions、evidence 和 search

5 assertion 从 v7 的 null-endpoint AFPV2 preimage 更新为 actual endpoint。AWS 与 MI455X relation 为 `qualifies`，随 rejected fact 保存反证；Huawei 三行保持 `supports`，但 fact 仍 provisional。post locator 和 AFPV2 固定为：

| assertion | endpoint / locator | AFPV2 post |
|---|---|---|
| AWS S11 | `END-AWS-TRN2-S11-SNAPSHOT`；`page header date; paragraphs naming Trainium2 as a chip family and Trainium2 chips` | `AFPV2-eea1ac4de27a2f2390648ac6ae9ccc0c1e75cb5977067b63be037c4b749f5188` |
| MI455X | `END-M2W3-AMD-MI455X-PRODUCT-SNAPSHOT`；`HTML title; Board Specifications, Launch Date` | `AFPV2-1b1451b3112d1ec948168b1db97f1fec0e5033249a6f8f6963a00a92dc27da42` |
| Huawei Die | `END-M2W3-HUAWEI-H2-SNAPSHOT`；`H-2 publication date; paragraphs beginning The first chip is Ascend 950PR; The next chip is Ascend 950DT` | `AFPV2-881ac005a9e1d9c1f917295c7b932b198a2dd3aa4372c590642b7ba759723a3a` |
| Huawei PR | 同一 endpoint；`H-2 publication date; paragraph beginning The first chip is Ascend 950PR` | `AFPV2-647e2144d78b222ac26c896746a979af00be354bddf56408a630df549645c89b` |
| Huawei DT | 同一 endpoint；`H-2 publication date; paragraph beginning The next chip is Ascend 950DT` | `AFPV2-20981b7c0e126f06d5dae55dd75c764e869a1496653de72c7eb56328c3ae2c2c` |

`REVID-CAMBRICON-MLU590-RELEASE-DATE` 保留 `supports_pending`，endpoint 填 `END-CAMBRICON-WAIC-2022-MLU590-SNAPSHOT`；locator=`Page dated 2022-09-02; paragraph beginning 在演讲的最后`；context 必须包含 `云端智能训练芯片思元590`；notes=`Candidate under RELEASE-DATE-SEMANTICS-V1; alias bridge and earlier-source search remain open.`

两个现有 search 改为 `candidate_found`，不插入新 search。MLU query 改为 exact `思元590/MLU590` 的最早厂商正式直接命名检索；MI350P query 改为回查 2026-05-07 之前 AMD 对 exact MI350P PCIe card 的正式直接命名。4 个现有 result 的关系依次为：MLU `candidate`、MI350P blog `candidate`、brochure `checked_no_support`、product `checked_no_support`。它们分别绑定现有 preferred endpoint，并在 `checked_locator_or_scope` 写入已检查段落或整页范围。Phase A 不插入 Huawei/MI455X search，也不插入 MI350P/Huawei requirement-evidence。

## 单一 fingerprint 合同

v2 删除 v1 的条件分支。Phase A 无条件采用 `RDFP1` 与 `RDRP1`；v7 registry 是否以后增加其他算法不影响本事务。

CSV 空 cell 在 JSON 中映射为 `null`，非空 cell 映射为 string。canonical JSON 使用 UTF-8、无 BOM、无空白、array 顺序固定。framing 逐字为：

```text
SHA256(UTF8(domain) || 0x00 || UINT64_BE(payload_byte_length) || payload_bytes)
```

fact domain 为 `release-date-fact-fingerprint-v1`，payload 为：

```text
[target_kind,target_id,field_id,"RELEASE-DATE-SEMANTICS-V1",
 normalized_value_text,normalized_value_number_or_null,normalized_unit_or_null,
 condition_set_id_or_null,valid_from_or_null,valid_to_or_null,resolution_state]
```

requirement domain 为 `release-date-requirement-fingerprint-v1`，payload 为：

```text
[target_kind,target_id,field_id,"RELEASE-DATE-SEMANTICS-V1",
 requirement_status,search_status]
```

前缀分别为 `RDFP1-`、`RDRP1-`。5+6 的 exact post set 为：

```text
FACT-AWS-TRN2-ARCH-RELEASE-DATE              RDFP1-2a7a0b4a79c6416420f62bc87d1346ca12912d5df047774805efcaec23120582
FACT-M2W3-AMD-MI455X-RELEASE-DATE            RDFP1-635e1fcec6c152473d75cc582c6f3a8b85075c6c1380055ecece8c132b36ade5
FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE     RDFP1-fc297c0169df2ac701bd351c2386cbe0eaae98f6d1026b245417e2ff63d6f4c2
FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE       RDFP1-7f05ffdb990e2a6a5ea23db52999c4c40f166a7124cc41b6a809940cca302e25
FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE       RDFP1-47dbabbffce91394daa28d7ba2c88d63ade35d6813e3171ccf3f7f3557a65b28

REQ-CAMBRICON-MLU590-RELEASE-DATE             RDRP1-f5529537ef562da83b58eb4cbfa4cff6304be92c551ce7b48ec4d566e67a6d25
REQ-M2W3-AMD-MI455X-RELEASE-DATE              RDRP1-f61ee68ff3fd8b28e2bf2526763e92f2bbf428ccb35f55a6943d68b319409a14
REQ-M2W3-AMD-MI350P-RELEASE-DATE              RDRP1-a26aa7b1117e46e2c8bfe521582e35724e77bad836936d76d71ad5f10eecac9c
REQ-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE      RDRP1-3fb8ef052907c07f6fdd32beefe97fefb2d75c7a63ccf4515ceb74240d847267
REQ-M2W3-HUAWEI-ASC950PR-RELEASE-DATE        RDRP1-6c37e2f66806e048ee7098066de9fcdda0d4b2409a24c247b6a9ae5cfec385ed
REQ-M2W3-HUAWEI-ASC950DT-RELEASE-DATE        RDRP1-42f0a320de9199417a5e700636bb041462a4454ecc4e11d1090af9bee6f5c97b
```

每条 operation 保存三件东西：v7 preimage 的原 fingerprint、上述 canonical input JSON、post fingerprint。AWS fact 正例 payload 为 151 bytes，hex 为：

```text
5b226f626a656374222c224f424a2d4157532d545241494e49554d322d41524348222c224649454c442d49442d52454c454153452d44415445222c2252454c454153452d444154452d53454d414e544943532d5631222c22323032332d31312d3238222c6e756c6c2c6e756c6c2c22434f4e442d4e4f4e45222c22323032332d31312d3238222c6e756c6c2c2272656a6563746564225d
```

16 个 release-date fingerprint fixture，即 5 RDFP1、6 RDRP1、5 AFPV2，追加到 v7 的 `canonical-fixtures.csv`；三运行时各产生一行，共追加 48 条 runtime result。fixture manifest 按完整新集合重算。重复 fingerprint、同 `(target,field,semantic version)` 不同活动 terminal 行、prefix/domain 错、null/empty 混淆、状态变化未重算都失败。

## source、screening、role 和 coverage 的 postimage

7 source family、7 source version 和 13 endpoint 行全部是 no-write guards。七份首选固定载荷的 SHA-256 依次为 MLU590 `0ed0950c492ca46344be53a0e815a24282c8c55389079c0bb7bde856458ad8a9`、Trainium2 `8636005578721583b257d1ed88e5806315b0ff6ac5c93105160725890547e1f2`、MI455X `2fa27618862c42b0b9e6eed2e5c88c360e6eac2650d9fc97bae08c6338315b47`、MI350P blog `2bc9cbb81e424e4d1c5d6912b43e7cfb1107081f159b012d8ad9cffd3b66dfb8`、brochure `a4e93edffc6c2a03668eef72b84d85e1d2586afb331c2228595d1549609afb29`、product `09b3ffd469353dfb2456fc2fca67b421aa8bf5ae48be809fa64f1a30dda3c088`、Huawei H-2 `8bf0f453e143562c7b5f3ead61f54a35da6020689dbc20aede772da0d00d7499`。source metadata 不承担“最早”结论，Phase A 不改其 publication date、version label 或 notes。

screening 的 5 个 update 固定为：MLU590 保持 `selected`，rationale 加入 2022-09-02 first-public candidate；AWS S11 从 `selected` 改为 `lead_only`，说明只直接命名 chip family/chips；MI455X 保持 `selected`，删除 launch-date 对 module release 的贡献；MI350P blog 保持 `selected`，加入 exact-card first-public candidate；Huawei H2 保持 `selected`，加入三对象各自的 direct-name candidate。MI350P brochure/product 两行 no-write。

selected role 的 postimage 固定为：

| 来源 | post role 处理 |
|---|---|
| MLU590 WAIC | identity 与 status 两行保留，rationale 增加 first-public candidate，明确 supply/GA 分链。 |
| AWS S11 | 删除 `SROLE-AWS-TRN2-017`。它降为 lead，不再拥有 active selected role。 |
| MI455X product | identity 行删除 launch-date closure，core 行 no-write；产品页仍因 L2/WGP/transistor/protocol facts 保留。 |
| MI350P blog | status role 增加 exact-card first-public candidate；brochure core、product core/identity 三行 no-write。 |
| Huawei H2 | identity 行加入 Die/PR/DT direct-name candidate；status 行明确 Q1/Q4 仅是 availability roadmap；core 行 no-write。 |

coverage 的 3 个 update 是 `COV-CAMBRICON-WAIC-NOT-COVERED-BY-MLUOPS`、`COV-M2W3-AMD-MI455X-PRODUCT-BY-BROCHURE` 和被 v1 漏掉的 `COV-M2W3-AMD-MI350P-BLOG-NOT-EQUIV-PRODUCT`。MLU590 行说明 MLU-OPS 不能替代 dated direct-name candidate；MI455X 行把 `exact launch-date field` 改成 vendor literal 且明确不支撑 module first-public；MI350P blog 行把 `Only available status is selected` 改成 `The article remains non-equivalent for dated available status and for the pending exact-card first-public candidate.` 其余 5 条 coverage byte-for-byte 保留。

## 新 selection run、完整 member set 与 reverse removal

2026-08-12/13 的 5 个 predecessor run 及其 48 个 member 全部 byte-for-byte 冻结。Phase A 不更新它们的 status、notes、cutoff、reviewer 或 member rationale。新 active run 由 `EffectiveSelectionRun(scope)` 解析：在 `status/review_status` 均为 reviewed 或 approved 的行中取唯一最大 cutoff；同日出现两行立即失败。新 cutoff 固定为 2026-08-21。若 v7 live input 在该日以后才形成，本 v2 candidate 失效，必须重新发布带新 cutoff 的设计，不能悄悄改日期。

4 个新 run 为：

```text
SELRUN-RDATE-V71-M1-PILOTS-20260821
  custom / M1-H100-TRAINIUM2-MLU590
SELRUN-RDATE-V71-AMD-MI455X-20260821
  object / OBJ-AMD-MI455X
SELRUN-RDATE-V71-AMD-MI350P-20260821
  object / OBJ-AMD-MI350P
SELRUN-RDATE-V71-HUAWEI-ASC950-PHYSICAL-20260821
  custom / M2-W3-HUAWEI-ASCEND950-PHYSICAL
```

四行的 `cutoff_date/created_date=2026-08-21`，algorithm version 固定 `reverse-removal-v2+release-date-semantics-v1`，status/review status 在独立 reviewer 完成后均为 `reviewed`。reviewer 是 transaction 开始前预分配的非空 scalar `R_A`，必须不同于 builder，并由 authorization 和完整 post row hash绑定。

新 member PK 的机械规则为 `SELMEM-RDATE-V71-<run-tag>-<source_id 去掉 SRC- 前缀>`。run-tag 是固定映射：M1 run 取 `M1`，MI455X run 取 `MI455X`，MI350P run 取 `MI350P`，Huawei run 取 `HUAWEI`。四元组 `[member_id,run_id,source_id,role]` 按 UTF-8 tuple 排序后写成无 BOM/空白/末尾换行的 canonical JSON array，domain 为 `release-date-selection-post-set-v1`。28 条 post member 的 framed set hash 为 `b08ec022bd25d3ee7c726934486d640d72d132c4e17cbe55176644f916fefbd6`。完整 source/role 集为：

```text
M1 run, 18 members:
SRC-2022-CAMBRICON-WAIC-MLU590                    identity
SRC-NVIDIA-H100-ARCH-WHITEPAPER-V1-04            core_spec
SRC-NVIDIA-H100-DATASHEET-20240924                core_spec
SRC-NVIDIA-H100-HOTCHIPS34-2022                   status_version_evidence
SRC-AWS-TRN2-S01                                  core_spec
SRC-AWS-TRN2-S02                                  core_spec
SRC-AWS-TRN2-S03                                  architecture_mechanism
SRC-AWS-TRN2-S04                                  architecture_mechanism
SRC-AWS-TRN2-S05                                  architecture_mechanism
SRC-AWS-TRN2-S06                                  core_spec
SRC-AWS-TRN2-S07                                  core_spec
SRC-AWS-TRN2-S08                                  architecture_mechanism
SRC-AWS-TRN2-S09                                  status_version_evidence
SRC-AWS-TRN2-S10                                  conflict_evidence
SRC-AWS-TRN2-S12                                  architecture_mechanism
SRC-AWS-TRN2-S13                                  architecture_mechanism
SRC-AWS-TRN2-S14                                  status_version_evidence
SRC-CAMBRICON-MLU-OPS-COMMIT-67B3707F             architecture_mechanism

MI455X run, 4 members:
SRC-M2W3-AMD-MI455X-PRODUCT-20260813              core_spec
SRC-M2W3-AMD-MI455X-BROCHURE-202607               core_spec
SRC-M2W2-AMD-MI400-LANDING-20260813               core_spec
SRC-M2NA-AMD-CDNA5-WP                             architecture_mechanism

MI350P run, 3 members:
SRC-M2W3-AMD-MI350P-BLOG-20260507                 status_version_evidence
SRC-M2W3-AMD-MI350P-BROCHURE-202605               core_spec
SRC-M2W3-AMD-MI350P-PRODUCT-20260813              core_spec

Huawei run, 3 members:
SRC-M2W3-HUAWEI-H2-ASC950-KEYNOTE-20250918        core_spec
SRC-M2W3-HUAWEI-H6-PROCESSOR-20260813             core_spec
SRC-M2W3-HUAWEI-H12-ATLAS350-LAUNCH-20260320      status_version_evidence
```

reverse-removal 的变化只有四项。MLU590 WAIC 仍必选，因为移除会丢失既有身份/状态事实、supports-pending evidence 和 2022-09-02 candidate；MI350P blog 仍必选，因为移除会同时丢失 dated available status 与 pending first-public candidate；Huawei H2 仍必选，因为移除会丢失共享 die、PR/DT identity、核心事实和三条 provisional candidate；MI455X product 仍必选，但理由只保留 identity、L2/WGP/transistor、protocol 和 current corroboration。AWS S11 的唯一 assertion 已转为 rejected architecture fact 的反证，Phase A 又不新增 chip fact，因此它从新 M1 member set 移除，screening 降为 lead_only，selected-role 行删除。两张 AWS 卡仍可把 S11 作为未来 chip-first-public 搜索线索，不能把它称为当前最小集成员。

新 28 source、28 source family 和 54 endpoint 行全部作为 selection source-universe no-write guards；三组 ID set hash分别为 `a831a3151f47937360e799435d0b390afbf720cf21f367feabfd5daf70fc215c`、`274724f635804c286126ae679b176e0e7e4398e8fcd5b5dab5b0b1dcb3ca6d4c`、`e109026758d049e6694aa2876a8d06ae422333b6a33b58671f5a33d2c645387c`。

## completeness、卡片和文档 postimage

14 条 identity/evidence completeness 全部进入 closure。10 条 update、4 条 no-write：

| 对象 | update |
|---|---|
| MLU590 | identity notes 改为 2022-09-02 candidate、alias/earliest search pending；`COMPLETE-CAMBRICON-MLU590-EVIDENCE` 保持 partial，但改写为本地 snapshot 已固定且 hash 可复现，不能再写 dynamic and unfrozen。 |
| Trainium2 architecture | identity 行 no-write；evidence 从 complete 降为 partial，说明 S11 不直接命名 architecture，当前投影链不能闭合该对象首次公开。 |
| MI455X | identity 删除“launch date supported”，加入 module first-public pending；evidence 保持 needs_review，notes 绑定新 run 并说明 product Launch Date 不支撑该字段。 |
| MI350P | identity 把 release not_found 改为 2026-05-07 candidate/pending；evidence 保持 needs_review，notes 加入 blog candidate 和 earliest search open。 |
| Huawei Die / PR / DT | 三条 identity no-write；Die、PR evidence 从 complete 降为 partial，DT evidence 保持 partial，三行都写 requirement-specific earliest search 未闭合。 |

10 条 update 的 assessed date 为 2026-08-21，assessor 为 `release_date_v71_migration`，review status 为 reviewed。独立 reviewer 仍由 `R_A` 和 amendment approval 绑定。

8 张卡和 reuse map 的 deterministic patch 如下。每个 preimage anchor 必须恰出现一次，零次或多次都失败；patch 后禁止残留与 post formal state 冲突的 active 句子。

| payload | exact semantic post |
|---|---|
| MLU590 卡 | 对象表增加“首次公开日期：2022-09-02 candidate；MLU590/思元590 identity bridge 和更早材料未闭合”，绑定 requirement；WAIC 独有贡献加入 candidate；待办把“正式发布或首供时间”拆成“更早正式直接命名”和“供货/首供”两条。 |
| Trainium2 试填卡 | architecture 行改为 first-public pending；S11 来源行改为 chip-family 2023-11-28 lead，不是 architecture fact，也不是新 active member。 |
| Trainium2 架构卡 | S10/S11 行删除“发布日期”职责；evidence complete 改 partial；明确 S11 只作 chip-family lead。 |
| MI455X 模组卡 | `Launch date` 改成 vendor literal，删除对 release fact 的引用；新增“首次公开日期 pending_verification”，绑定 module requirement。 |
| MI350P 卡 | “发布日期 not_found”改为“首次公开日期 pending；2026-05-07 exact-card article candidate”；12 条 not_found 说明中把 release 移出终态；blog 角色补 candidate。 |
| Huawei 三卡 | 日期显示为 `2025-09-18 provisional candidate；最早正式公开检索未闭合`，同时引用对应 fact 和 pending requirement；availability 段保持独立。 |
| Trainium2 reuse map | `FACT-AWS-TRN2-ARCH-RELEASE-DATE` 行的 resolution `accepted -> rejected`，locator 改成 v7.1 locator，reuse disposition 改为 `rejected_reference_do_not_copy`。 |

字段字典和模板逐字切换为新名称与 188-byte 定义。研究计划把“新闻稿支撑发布日期”改成 exact-object 正式材料只形成 candidate，最早性须由 requirement-specific search 闭合；source 自身 publication date 规则保持。`AGENTS.md` 和 `README.md` 增加 v7.1 active contract、v5.0 immutable、v5.1/amendment 恢复顺序以及 selection latest-cutoff 规则，不改进度台账。

`Validate-ResearchData.ps1` 增加字段字节、5+6 set、accepted/value-available equality、provisional/pending subset、RDFP1/RDRP1/AFPV2、actual endpoint、new effective selection run、v5.1 amendment binding 和 active reference set-equal 门。`Test-ChipScope.ps1` 增加 latest-cutoff selection resolution和旧 run/member no-write hash门。二者都是 v7 post 的 present-to-present payload；`Test-SourcePool.ps1` 与 `verify_recovery_paths.py` 为 no-write inputs。

## 完整 operation universe

Phase A 的 row operation target identity 是 `[table_path,primary_key,operation_kind]`，domain 为 `release-date-operation-target-set-v1`。它恰有 81 项，hash 为 `c2975c797ea9a2a29f7602e79335b9c245178d7fb8beaa7d482905f04db50349`：

| table | update | insert | delete |
|---|---:|---:|---:|
| `数据/fields.csv` | 1 | 0 | 0 |
| `数据/facts.csv` | 5 | 0 | 0 |
| `数据/field-requirements.csv` | 6 | 0 | 0 |
| `最小参考资料库/fact-assertions.csv` | 5 | 0 | 0 |
| `最小参考资料库/requirement-evidence.csv` | 1 | 0 | 0 |
| `最小参考资料库/search-log.csv` | 2 | 0 | 0 |
| `最小参考资料库/search-results.csv` | 4 | 0 | 0 |
| `最小参考资料库/source-screening.csv` | 5 | 0 | 0 |
| `最小参考资料库/source-selected-roles.csv` | 6 | 0 | 1 |
| `最小参考资料库/source-coverage.csv` | 3 | 0 | 0 |
| `最小参考资料库/selection-runs.csv` | 0 | 4 | 0 |
| `最小参考资料库/selection-members.csv` | 0 | 28 | 0 |
| `数据/card-completeness.csv` | 10 | 0 | 0 |

除已在 selection 节列明的 4 个 run PK 和由固定 tag/source constructor 生成的 28 个 member PK 外，其余 49 个 update/delete PK 的 exact set 为：

```text
fields update:
FIELD-ID-RELEASE-DATE

facts update:
FACT-AWS-TRN2-ARCH-RELEASE-DATE
FACT-M2W3-AMD-MI455X-RELEASE-DATE
FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE
FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE
FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE

requirements update:
REQ-CAMBRICON-MLU590-RELEASE-DATE
REQ-M2W3-AMD-MI455X-RELEASE-DATE
REQ-M2W3-AMD-MI350P-RELEASE-DATE
REQ-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE
REQ-M2W3-HUAWEI-ASC950PR-RELEASE-DATE
REQ-M2W3-HUAWEI-ASC950DT-RELEASE-DATE

assertions update:
ASSERT-AWS-TRN2-ARCH-RELEASE-DATE-S11
ASSERT-M2W3-AMD-MI455X-RELEASE-DATE-PRODUCT
ASSERT-M2W3-HUAWEI-DIE-RELEASE-H2
ASSERT-M2W3-HUAWEI-PR-RELEASE-H2
ASSERT-M2W3-HUAWEI-DT-RELEASE-H2

requirement evidence update:
REVID-CAMBRICON-MLU590-RELEASE-DATE

search logs update:
SEARCH-CAMBRICON-MLU590-RELEASE-DATE
SEARCH-M2W3-AMD-MI350P-RELEASE-DATE

search results update:
SRESULT-CAMBRICON-MLU590-RELEASE-DATE
SRESULT-M2W3-AMD-MI350P-RELEASE-DATE-BLOG
SRESULT-M2W3-AMD-MI350P-RELEASE-DATE-BROCHURE
SRESULT-M2W3-AMD-MI350P-RELEASE-DATE-PRODUCT

screening update:
SCREEN-CAMBRICON-WAIC-2022-MLU590
SCREEN-AWS-TRN2-S11
SCREEN-M2W3-AMD-MI455X-PRODUCT
SCREEN-M2W3-AMD-MI350P-BLOG
SCREEN-M2W3-HUAWEI-H2

selected roles update:
SROLE-CAMBRICON-WAIC-IDENTITY
SROLE-CAMBRICON-WAIC-STATUS
SROLE-M2W3-AMD-MI455X-PRODUCT-IDENTITY
SROLE-M2W3-AMD-MI350P-BLOG-STATUS
M2W3-HUAWEI-SROLE-H2-ID
M2W3-HUAWEI-SROLE-H2-STATUS

selected role delete:
SROLE-AWS-TRN2-017

coverage update:
COV-CAMBRICON-WAIC-NOT-COVERED-BY-MLUOPS
COV-M2W3-AMD-MI455X-PRODUCT-BY-BROCHURE
COV-M2W3-AMD-MI350P-BLOG-NOT-EQUIV-PRODUCT

completeness update:
COMPLETE-CAMBRICON-MLU590-IDENTITY
COMPLETE-CAMBRICON-MLU590-EVIDENCE
COMPLETE-M2GA-AWS_TRAINIUM2_ARCH-EVIDENCE
COMPLETE-M2W3-AMD-MI455X-IDENTITY
COMPLETE-M2W3-AMD-MI455X-EVIDENCE
COMPLETE-M2W3-AMD-MI350P-IDENTITY
COMPLETE-M2W3-AMD-MI350P-EVIDENCE
CC-M2W3-HUAWEI-ASC950-DIE-EVIDENCE
CC-M2W3-HUAWEI-ASC950-PR-EVIDENCE
CC-M2W3-HUAWEI-ASC950-DT-EVIDENCE
```

81 个 operation item 按 UTF-8 tuple 排序后序列化为无 BOM/空白/末尾换行的 canonical JSON array，再使用本节 domain 和统一 framing 复算上述 hash。不得增加 Phase A evidence/search 行来改变 81。source family/source/endpoint 三表没有 operation。正式 table image 恰为上述 13 张。

managed payload target item 是 `[logical_path,pre_state,post_state]`，domain 为 `release-date-payload-target-set-v1`。item 按 UTF-8 tuple 排序并写成无 BOM/空白/末尾换行的 canonical JSON array后再按前述 framing 计算。expected set 恰有 25 项，hash 为 `16c98850247a3d55dcb5260f2c8c2afb49073a775b1e19881afbb7fd0c73dfdb`。19 个 present-to-present path 是：

snapshot 状态只有下列三类，不允许实施器选第四条路径：

| target class | pre snapshot | post snapshot | authorization |
|---|---|---|---|
| v5.0 policy/approval、v7 manifest/approval | `present@v7-bound-raw-hash` | 同一 raw bytes/hash | immutable no-write guard |
| 下列 19 个 docs/cards/validator/fixture path | `present@v7-bound-raw-hash` | `present@full-candidate-raw-hash` | 19-column payload item 绑定 pre/post/size |
| 下列 6 个 v5.1/amendment stable path | `absent` | `present@full-candidate-raw-hash` | insert payload；rollback 为 hash-guarded delete-created |

```text
资料卡/寒武纪/MLU590_试填草稿.md
资料卡/AWS/Trainium2_试填草稿.md
资料卡/AWS/架构/AWS_Trainium2_架构卡.md
资料卡/AMD/封装/AMD_Instinct_MI455X_模组资料卡.md
资料卡/AMD/产品/AMD_Instinct_MI350P_PCIe_卡资料卡.md
资料卡/华为昇腾/封装/华为_Ascend950_共享裸片资料卡.md
资料卡/华为昇腾/封装/华为_Ascend950PR_封装资料卡.md
资料卡/华为昇腾/封装/华为_Ascend950DT_封装资料卡.md
资料卡/AWS/架构/sources/trainium2_existing_reuse_map.csv
资料卡/字段字典.md
资料卡/模板.md
研究计划.md
AGENTS.md
README.md
scripts/validation/Validate-ResearchData.ps1
scripts/validation/Test-ChipScope.ps1
审计/合同注册表/canonical-fixtures.csv
审计/合同注册表/canonical-runtime-results.csv
审计/合同注册表/canonical-fixture-manifest.json
```

6 个 absent-to-present stable path 是：

```text
审计/合同注册表/coverage-policy-v5.1.json
审计/合同注册表/coverage-policy-v5.1-approval.json
审计/合同注册表/release-date-active-reference-closure-v1.csv
审计/合同注册表/release-date-semantic-disposition-v1.csv
审计/合同注册表/release-date-contract-amendment-v7.1.json
审计/合同注册表/release-date-contract-amendment-v7.1-approval.json
```

19 个 present-to-present payload 都不允许用“在现有文件上应用 patch”作为授权。它们的 preimage 是 v7 transaction manifest 绑定的完整 raw bytes，postimage 是 v7.1 prepare 阶段产生的完整 candidate bytes；operation payload authorization 逐项记录 logical path、pre raw SHA-256、post raw SHA-256 及 post size。若 live bytes 不等于该 pre hash，本设计即无可执行路径，必须重新 prepare 和独审，不得对漂移文件做 fuzzy patch。因此 policy、approval、validator 和 docs 在 authorization 中都是唯一的 present-to-present snapshot，而非仅有语义描述。

`release-date-semantic-disposition-v1.csv` 恰有 11 行，逐一绑定 5 fact 和6 requirement 的 pre row hash、post row hash、decision、semantic version 和 fingerprint input hash。`release-date-active-reference-closure-v1.csv` 保存前述 106 个正式 identity、18 个 preimage payload、25 个 managed post target和所有 no-write guard hash。两个文件由 amendment manifest 单向绑定，不另建会产生 hash 环的 approval。

operation authorization 使用 v7 已冻结的 13-column operation item和19-column payload item，不重定义两套投影。顶层 contract version 固定 `RELEASE-DATE-OPERATION-PAYLOAD-AUTHORIZATION-V1`。必须同时满足：

```text
AuthorizedOperationTargets == ExpectedOperationTargets81
AuthorizedOperationTargets == ExactRowDiff(V7Base, CompletePlannedPost)

AuthorizedPayloadTargets == ExpectedPayloadTargets25
AuthorizedPayloadTargets == ExactPayloadDiff(V7Base, CompletePlannedPost)

AuthorizedNoWriteGuards == BuiltNoWriteGuardSet
ActiveReferenceClosurePre == ExpectedActiveSet103
ActiveReferenceWithHistoryGuards == ExpectedGuardSet106
```

authorization approval 复用 9-key schema，artifact kind 为 `release_date_operation_payload_authorization`。任何 extra row、遗漏卡片、改写 old run/member、修改 v5.0、把 Phase B 搜索插入 Phase A，或把 no-write source 改值，都返回 `E_AUTHORIZATION_SET`。

事务控制件不冒充 live managed payload。`T=审计/事务/TX-RDATE-V71-SEMANTIC-EXIT-20260821`，固定登记 `T/authorization/release-date-operation-payload-authorization.json`、`T/authorization/release-date-operation-payload-authorization-approval.json`、`T/inventory/table-operations.csv`、`T/inventory/payload-operations.csv`、`T/inventory/file-inputs.csv`、`T/images/table-images.csv`、`T/rollback/rollback-targets.csv`、`T/rollback/rollback-manifest.json`、`T/manifest/transaction-manifest.json`、`T/manifest/transaction-approval.json` 和 `T/journal/apply-journal.jsonl`。authorization/approval 必须在 operation materialize 之前完成；manifest/approval 必须同时绑定 81/25 exact set、13 images、38 rollback targets、immutable inputs 与 reviewer。这些 T 路径由 v7 事务协议保留供审计，不计入 25 个 live payload，也不绕过 authorization 修改任何正式目标。

## no-write guards

除了 7/7/13 semantic source closure，还要锁定新 selection 的完整 source universe。28 source、28 family、54 endpoint 的 exact set hash已在 selection 节给出；所有 preferred local payload 的 raw hash也进入 guard。旧 selection 生命周期由以下集合机械冻结：

```text
FrozenRuns = selection-runs where selection_run_id in {
  SELRUN-M1-PILOTS-20260812,
  SELRUN-M1-PILOTS-TRN2-CORRECTED-20260813,
  SELRUN-M2W3-AMD-MI455X-20260813,
  SELRUN-M2W3-AMD-MI350P-20260813,
  SELRUN-M2W3-HUAWEI-ASC950-PHYSICAL-20260813
}
FrozenMembers = selection-members where selection_run_id in PK(FrozenRuns)
Count(FrozenRuns) == 5
Count(FrozenMembers) == 48
PreRowHash == PostRowHash for every frozen row
```

另外锁定 2 条未更新 screening、5 条未更新 selected role、5 条未更新 coverage 和4 条未更新 completeness。v5.0 policy/approval、source-date policy/approval、v7 manifest/approval、R13、R02、v7 设计以及本设计定稿 hash都进入 immutable input。no-write guard 不是 operation；若任何 guard 在 apply 前漂移，整笔事务失效。

## 依赖 DAG、apply 与回滚

hash DAG 固定为：

```text
A0  v7 applied state, v5.0 policy/approval, R13/R02/R03, source payloads,
    transaction_id, cutoff=2026-08-21, reviewer scalar R_A
A1  immutable base snapshots; ActiveReferenceClosure pre; no-write guard sets
A2  semantic dispositions; RDFP1/RDRP1/AFPV2 inputs; source eligibility
A3  complete row candidates; card/docs/validator candidates; new selection candidates;
    v5.1 policy candidate
A4  canonical fixtures and three-runtime results
A5  fixture manifest; closure CSV; disposition CSV
A6  v5.1 policy approval
A7  core managed post raw set, excluding amendment/approval themselves
A8  amendment manifest binding A0-A7 plus expected 81/25 target-set hashes
A9  amendment approval
A10 complete planned post assembled from A3-A9 and immutable base
A11 ExactDiff; expected 81 operation targets; expected 25 payload targets
A12 operation/payload authorization
A13 authorization approval
A14 actual operation/payload/file-input inventories, exact set-equal to authorization
A15 isolated full post mirror, exact set-equal to A10
A16 13 table images; 38 rollback targets; rollback manifest
A17 transaction manifest binding amendment/approval and authorization/approval
A18 transaction approval
A19 append-only apply journal
```

每条真实依赖必须从低层指向高层。policy approval 不回填 policy；amendment 只绑定上游 core state 和 expected target set，不绑定下游 authorization；amendment approval 不回填 amendment；transaction approval 不回填 manifest。actual operation 由 authorization materialize，不能反向决定 authorization。A19 live apply 先写全部 core target 和 amendment manifest，复验 live core hash后才以 amendment approval 作为最后一个 target，随后追加 applied journal event。`migration_status=applied` 的 bytes 在 A3 产生，但在最后 approval 出现前仍由 v5.0 fail closed。

rollback 恰有 38 个 target：13 张 changed table image恢复完整 v7 preimage bytes；19 个 present-to-present payload恢复 v7 bytes；6 个新 stable artifact 只在当前 hash等于本事务 post hash时删除。rollback 先删 amendment approval 使 v5.1 失活，再删 amendment，然后恢复 core targets；old run/member和 v5.0 从未写入，不需要“恢复”。apply/rollback 中断沿用 v7 journal 的 deterministic roll-forward 规则；未知 hash、缺 target 或 pre/post 混合且无同 manifest applying event时停止。

## hard gates

独立验收按下列顺序执行：

1. v7 prerequisite：`34/376/141/77/564`、832 AFPV2、v5.0 deferred 和 v7 approval 全通过。
2. closure：103 active identity、106 含 history guard identity、18 preimage payload 与本稿 hash逐项 set-equal；MLU590 evidence completeness、MI350P blog coverage/member 均必须命中。
3. semantic bytes：字段名和 188-byte 定义在 fields、字典、模板、v5.1 policy 完全一致；active payload 不再把 launch/availability/shipping/sales 当首次公开。
4. state closure：accepted/value-available 都为空；三条 provisional key 全属于 pending requirement；两条 rejected fact 不能满足 requirement。
5. evidence：5 assertion 的 endpoint/locator/AFPV2 等于本稿；MLU evidence和两条 existing search、4 result 恰按 Phase A post；没有额外 evidence/search insert。
6. fingerprint：5 RDFP1、6 RDRP1、5 AFPV2 与 exact expected set相等，16 fixture在 PowerShell 5.1、PowerShell 7、Python 3 全部一致。
7. selection：新 run 恰4条、新 member 恰28条，source/role set hash为 `b08ec022bd25d3ee7c726934486d640d72d132c4e17cbe55176644f916fefbd6`；S11 不在新 member，MLU/MI350P blog/Huawei H2 保留，MI455X rationale不含 release贡献；5 old run和48 old member行 hash全不变。
8. source/completeness/cards：28/28/54 selection source guard通过；14 completeness无遗漏；8卡、reuse map、字典、模板、计划、AGENTS、README与 formal post一致。
9. contract amendment：v5.0及 approval hash不变；v5.1 policy/approval有效；amendment/approval唯一；active resolver只得到 v5.1；v5.1 applied gate与全部 managed post同一 transaction生效。
10. authorization/mirror：81 row targets、25 payload targets、13 table images、38 rollback targets双向 set-equal；A0至A19的实际 hash edge 全部严格升层；isolated mirror与 complete planned post逐表逐文件相等。
11. runtime：Windows 上 `Test-SourcePool.ps1`、`Test-ChipScope.ps1`、`Validate-ResearchData.ps1` 三门都 PASS；rollback mirror恢复 v7 preimage；live apply 后再复跑 1 至 10。

任何 gate 失败都不发布 amendment。validator 不能以 locator 关键词代替独立 reviewer 对 exact object 的判断。

## Phase B 与 GA100 的边界

Phase B 的 transaction family 固定为 `TX-RDATE-EARLIEST-ADJUDICATION-V1-*`，它只能从已成功应用的 v7.1 managed-state hash启动。每个目标重新冻结 requirement-specific search universe、source/endpoint、候选最早日期、新 selection cutoff、RDFP1/RDRP1/AFPV2、authorization、approval、mirror和rollback。Phase A 的 81/25 allowed set不包含 Phase B 的任何行或 payload。

GA100 `2020-05-14` 仍只通过 source/date/exact-name candidate 门。后续 GA100 transaction 的 immutable contract inputs必须把 v7 的 v5.0 policy/approval pair替换为 v5.1 pair，并新增 amendment manifest/approval pair；v7 的 pending-mapping 38-input branch因此为40项，already-mapped 37-input branch为39项。它仍须新增正式 NVIDIA source/actual endpoint、完成更早官方材料检索并由独立 reviewer裁决，才可能写 release-date fact。A100 product 发布、production、shipping 或 sales 日期不能支撑 GA100 die。

v7.1 不增加正式 table、schema column、field 或 enum row，v7 的 `34/376/141/77/564` 历史计数保持不变。selection run/member 和 stable amendment artifact 的新增量属于 v7.1 transaction，不能反向改写 v7 的 11/24/35、96 inputs 或 approval。

## 交付检查

本稿完成后只对本文件运行 `report-humanizer` 单文件扫描，并从末节到首节人工逆序复读标题、首段、PK、数量、hash、状态和限定词。最终行数与 SHA-256 在交接消息中报告。实施期 Windows 三道 hard gate尚未运行；它们是未来 v7.1 apply 的阻断前置，不是本次只读设计的完成条件。

本轮发生 1 次非阻断的 model/operator mistake：一次 `apply_patch` 因我给出的 expected context 与文件中的完整路径行不相等而拒绝应用，该次没有写入任何 bytes；改用较小、精确 context 后成功。没有发生用户中断、sandbox denial、approval failure、approval-review connection failure、remote service error 或 tool/runtime failure。
