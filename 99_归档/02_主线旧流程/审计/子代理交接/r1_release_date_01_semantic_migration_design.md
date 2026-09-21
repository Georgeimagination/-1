# `FIELD-ID-RELEASE-DATE` 全库语义迁移设计

设计日期：2026-08-21  
设计性质：独立、只读预设计；本稿没有修改正式 CSV、contract v7、staging、模板、资料卡、进度或既有审计件。  
唯一允许的本轮新增物：本报告。

## 裁决摘要

这项迁移必须排在 contract v7 正式成功之后，不能并入 v7，也不能在 v7 之前先改字段。v7 负责把合同基线推进到 `34 tables / 376 schema columns / 141 fields`，并把 assertion 迁到带 `endpoint_id` 的 `AFPV2` 合同；本迁移再以该 postimage 为 immutable base，原子改写 release-date 语义及其全部引用面。两者共用同一个目标定义，但不是同一个事务。

迁移后的字段名只能是“首次公开日期”，定义只能逐字为：

```text
厂商或设计方在具日期、可核验的正式材料中首次直接命名/宣布该研究对象；不能用上位架构预告、下位产品发布、availability/shipping/sales 替代
```

这段定义的 UTF-8 SHA-256 为 `757e9a1275f9bbe1381fbbad06a24c0992689ebbe45cd22cd71305031ce6f41b`。它记录的是 exact object 首次进入厂商或设计方正式公开材料的日期，不是发布会泛称、架构预告、产品上市、供货、销售或首次交付日期。

按这个口径，R13 的 5 条 fact 中，Trainium2 architecture 和 MI455X module 两条应拒绝；Ascend 950 Die、950PR、950DT 三条可保留 `2025-09-18` 作为 `provisional` 候选，但不能继续让 requirement 显示 `value_available/completed`。6 条 requirement 在最早材料检索和独立复核闭合前全部回到 `pending_verification/in_progress`。MLU590 的 2022-09-02 官方文章和 MI350P 的 2026-05-07 官方文章分别成为候选，不再因“尚在研”或“只是文章发布日期”而被类别性排除。当前没有一条 requirement 可以诚实地落为终态 `not_found`：旧的 MI350P `not_found` 已被新定义推翻，其余对象也尚未完成 exact-object 历史检索。

GA100 的 `2020-05-14` 不是预置答案。现有固定 NVIDIA Technical Blog 材料具日期、可核验、第一方且直接命名 GA100 GPU，因此它通过来源、日期和对象三项候选门；但全历史最早性尚未闭合，来源和 actual endpoint 也尚未写入正式库，所以 GA100 仍须 `pending_verification`，不得在本迁移中提前生成 `accepted` fact。

## 迁移输入与边界

本设计继承并实际核对了主线 `AGENTS.md`、R13、contract v7、R14、R35、r37、r39，以及正式 `fields/facts/field-requirements/fact-assertions/requirement-evidence/search-log/search-results/objects/sources/source-endpoints`。字段字典、模板、研究计划和内容引用面也纳入闭包。R14 证明 5+6 集合正确并要求 defer；R35 拒绝在旧定义下直接接收 GA100 日期；r37/r39 固定了 GA100 官方网页材料的来源质量和复现边界；v7 则把 R13 作为冻结输入，并明确把语义迁移留给后续独立事务。

本事务的 scope constructor 先从 v7 postimage 机械生成：

```text
LegacyFacts = rows(facts.csv where field_id == FIELD-ID-RELEASE-DATE)
LegacyRequirements = rows(field-requirements.csv where field_id == FIELD-ID-RELEASE-DATE)
EvidenceClosure = FKClosure(LegacyFacts, LegacyRequirements)
ActiveReferenceClosure = ContentAndFKReferences(LegacyFacts, LegacyRequirements,
                                                FIELD-ID-RELEASE-DATE)
```

`LegacyFacts` 必须与下列 5 个 PK 双向 set-equal：

```text
FACT-AWS-TRN2-ARCH-RELEASE-DATE
FACT-M2W3-AMD-MI455X-RELEASE-DATE
FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE
FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE
FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE
```

`LegacyRequirements` 必须与下列 6 个 PK 双向 set-equal：

```text
REQ-CAMBRICON-MLU590-RELEASE-DATE
REQ-M2W3-AMD-MI455X-RELEASE-DATE
REQ-M2W3-AMD-MI350P-RELEASE-DATE
REQ-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE
REQ-M2W3-HUAWEI-ASC950PR-RELEASE-DATE
REQ-M2W3-HUAWEI-ASC950DT-RELEASE-DATE
```

历史 audit、staging、backup、superseded selection run 和旧事务镜像只进入只读命中清单，不进入 active payload。它们保留当时的 preimage，不回写新语义。当前正式库仍是迁移前快照；以下 postimage 都是后续事务的设计值，不是已落库状态。

## 什么材料可以支撑这个字段

候选材料必须同时满足五个条件：发布主体是厂商或设计方；材料本身有可核验的日级日期；actual endpoint 可复现；正文或标题直接命名 exact object；该日期不是从父架构、子产品或 availability/shipping/sales 事件倒推。新闻稿、技术博客、演讲实录、产品手册都可能合格，材料类型本身不决定结果。

单份材料通常只证明“截至该日已经公开”，不能自动证明“该日就是首次公开”。升为 `accepted/value_available` 前，必须按 exact object 名称、官方别名和厂商域回查更早材料，并记录已检查范围。若存在更早 candidate、无法访问候选、对象身份未决或只有月级日期，要求保持 `pending_verification`。`today announced` 能增强当日候选，但仍不能替代对象绑定和独立 reviewer。

本轮复核涉及的 7 个 source version 和 13 个 endpoint 如下。现有 source/endpoint 行本身不因字段改名自动失效；表中的“缺口”决定能否把日期升为终值。

| 对象链 | source version | 首选 actual endpoint | 当前裁决与缺口 |
|---|---|---|---|
| MLU590 | `SRC-2022-CAMBRICON-WAIC-MLU590`，`publication_date=2022-09-02` | `END-CAMBRICON-WAIC-2022-MLU590-SNAPSHOT` | 官方正文直接写“云端智能训练芯片思元590”且说明在研；可作候选。仍缺 `MLU590` 与“思元590”的正式同一性桥和更早材料检索。远程 HTML endpoint 保留为辅助入口。 |
| Trainium2 | `SRC-AWS-TRN2-S11`，`publication_date=2023-11-28` | `END-AWS-TRN2-S11-SNAPSHOT` | 官方材料直接命名 Trainium2 chip family/chips，不直接命名 architecture。source 与两个 endpoint 目前仍为 `draft`；旧 architecture fact 不合格。 |
| MI455X | `SRC-M2W3-AMD-MI455X-PRODUCT-20260813`，`publication_date` 为空 | `END-M2W3-AMD-MI455X-PRODUCT-SNAPSHOT` | 页内 `Launch Date 7/23/2026` 不是页面发布日期，且页面主语为 GPU、正式 target 为 module。远程 endpoint 只作入口。该 source 对旧 requirement 为 `checked_no_support`。 |
| MI350P | `SRC-M2W3-AMD-MI350P-BLOG-20260507`，`publication_date=2026-05-07` | `END-M2W3-AMD-MI350P-BLOG-SNAPSHOT` | 官方文章标题和正文直接命名 exact MI350P PCIe card，可作候选；仍缺更早官方材料检索。远程 endpoint 只作入口。 |
| MI350P | `SRC-M2W3-AMD-MI350P-BROCHURE-202605`，无日级 `publication_date` | `END-M2W3-AMD-MI350P-BROCHURE-LOCAL` | `05/26` 只能作月份线索，不能单独支撑 date；远程 PDF endpoint 只作入口。 |
| MI350P | `SRC-M2W3-AMD-MI350P-PRODUCT-20260813`，`publication_date` 为空 | `END-M2W3-AMD-MI350P-PRODUCT-SNAPSHOT` | 动态产品页直接命名对象但没有材料发布日期；对本字段为 `checked_no_support`。远程 endpoint 只作入口。 |
| Ascend 950 三对象 | `SRC-M2W3-HUAWEI-H2-ASC950-KEYNOTE-20250918`，`publication_date=2025-09-18` | `END-M2W3-HUAWEI-H2-SNAPSHOT` | 同一官方具日期演讲直接命名 Die、PR、DT，三者分别可作候选；仍缺三个 requirement-specific 的更早材料检索和独立 reviewer。DT 的 2026 Q4 availability 另属 availability/status 链。 |

上表对应的固定快照 SHA-256 依次为 MLU590 `0ed0950c492ca46344be53a0e815a24282c8c55389079c0bb7bde856458ad8a9`、Trainium2 `8636005578721583b257d1ed88e5806315b0ff6ac5c93105160725890547e1f2`、MI455X `2fa27618862c42b0b9e6eed2e5c88c360e6eac2650d9fc97bae08c6338315b47`、MI350P blog `2bc9cbb81e424e4d1c5d6912b43e7cfb1107081f159b012d8ad9cffd3b66dfb8`、MI350P brochure `a4e93edffc6c2a03668eef72b84d85e1d2586afb331c2228595d1549609afb29`、MI350P product `09b3ffd469353dfb2456fc2fca67b421aa8bf5ae48be809fa64f1a30dda3c088`、Huawei H-2 `8bf0f453e143562c7b5f3ead61f54a35da6020689dbc20aede772da0d00d7499`。这些 hash 只证明固定载荷一致，不证明“首次”。

## 5 条 fact 的 exact preimage → postimage

下表只列必须变化的 cell；未列 cell 逐字保留。执行器必须从 v7 base 读取完整 row、套用下表后再算 row hash，不能从本稿拼一个不完整 CSV 行。

| fact PK | preimage | postimage | 裁决理由 |
|---|---|---|---|
| `FACT-AWS-TRN2-ARCH-RELEASE-DATE` | `target=OBJ-AWS-TRAINIUM2-ARCH`；`value=2023-11-28`；`evidence_state=single_source`；`resolution_state=accepted`；`confidence=high`；`review_status=reviewed` | target 和 value 保留为历史错误行；`evidence_state=source_with_caveat`；`resolution_state=rejected`；`confidence=low`；`review_status=needs_resolution`；notes 明写 S11 命中 chip family/chips 而非 architecture | 不允许把旧 PK 原地改投 `OBJ-AWS-TRAINIUM2-CHIP`。若后续为 chip 建候选，必须使用新 requirement/fact/assertion PK，并先闭合更早材料检索。 |
| `FACT-M2W3-AMD-MI455X-RELEASE-DATE` | `target=OBJ-AMD-MI455X(module)`；`value=2026-07-23`；`evidence_state=single_source`；`resolution_state=provisional`；`confidence=high`；`review_status=reviewed` | target 和 value保留为历史错误行；`evidence_state=source_with_caveat`；`resolution_state=rejected`；`confidence=low`；`review_status=needs_resolution`；notes 明写动态页 `Launch Date` 非 publication date 且 GPU/module 不同层 | 内层 GPU package 的 identity、对象和首次公开链属于另一包，不得借本 module PK 修复。 |
| `FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE` | `value=2025-09-18`；`single_source/provisional/high/reviewed` | value、target、`single_source/provisional` 保留；`confidence=medium`；`review_status=needs_resolution`；notes 改为“direct exact-object candidate；earliest search open” | H-2 直接命名 Die，但“最早”未闭合。 |
| `FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE` | `value=2025-09-18`；`single_source/provisional/high/reviewed` | value、target、`single_source/provisional` 保留；`confidence=medium`；`review_status=needs_resolution`；notes 改为“direct exact-object candidate；earliest search open；availability excluded” | PR 名称和日期直接，但 2026 Q1 roadmap availability 不能参与该值。 |
| `FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE` | `value=2025-09-18`；`single_source/provisional/high/reviewed` | value、target、`single_source/provisional` 保留；`confidence=medium`；`review_status=needs_resolution`；notes 改为“direct exact-object candidate；earliest search open；2026 Q4 availability excluded” | DT 名称和日期直接；2026 Q4 只进入 availability/status 链。 |

迁移的保守 postimage 不新增 Trainium2 chip fact、MI455X package fact、MLU590 fact、MI350P fact或 GA100 fact。这样 5 条 legacy fact 每条都有裁决，又不会把尚未证明“最早”的候选包装成事实。后续 search closure 若通过，应在独立 chip/card transaction 中插入新 PK 或把三条 Huawei `provisional` 升级；不得回写本事务的授权集合。

## 6 条 requirement 的 exact preimage → postimage

| requirement PK | preimage | postimage | 迁移后的含义 |
|---|---|---|---|
| `REQ-CAMBRICON-MLU590-RELEASE-DATE` | `pending_verification/in_progress`；reason=`in-development disclosure, not an explicit release notice`；`review_status=draft` | 状态和进度保留；reason 改为“2022-09-02 first-party material directly names 思元590; identity bridge and earlier official disclosure search remain open”；`review_status=needs_resolution`；notes 明写不以 supply/GA 为门槛 | 旧否定理由删除，2022-09-02 进入候选链，不新建 fact。 |
| `REQ-M2W3-AMD-MI455X-RELEASE-DATE` | `value_available/completed/reviewed`；notes 指向 canonical fact | `pending_verification/in_progress/needs_resolution`；reason 改为“current module row has no dated formal material directly naming the module”；notes 删除 canonical 结论并指向 exact-module search | 从伪闭合降级；产品页 `Launch Date` 不支撑 module 首次公开。 |
| `REQ-M2W3-AMD-MI350P-RELEASE-DATE` | `not_found/completed/reviewed`；reason 排除 article publication date | `pending_verification/in_progress/needs_resolution`；reason 改为“2026-05-07 official exact-card article is a candidate; earlier official disclosure search remains open”；notes 明写 brochure/product page 仍不支撑日级首次公开 | 旧 `not_found` 被新定义推翻，但候选尚未升值。 |
| `REQ-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE` | `value_available/completed/reviewed` | `pending_verification/in_progress/needs_resolution`；reason 改为“H-2 exact-object 2025-09-18 candidate; earlier official disclosure search open”；notes 禁止 architecture/product/availability 替代 | candidate 和 terminal value 分离。 |
| `REQ-M2W3-HUAWEI-ASC950PR-RELEASE-DATE` | `value_available/completed/reviewed` | `pending_verification/in_progress/needs_resolution`；reason 改为“H-2 exact-object 2025-09-18 candidate; PR-specific earlier search open”；notes 排除 2026 Q1 availability | 不借 Die/DT 检索代替 PR。 |
| `REQ-M2W3-HUAWEI-ASC950DT-RELEASE-DATE` | `value_available/completed/reviewed` | `pending_verification/in_progress/needs_resolution`；reason 改为“H-2 exact-object 2025-09-18 candidate; DT-specific earlier search open”；notes 排除 2026 Q4 availability | 不借 Die/PR 检索代替 DT。 |

所有 requirement 的 `last_searched_date` 只在实际执行了相应搜索时写真实日期；生成候选文件本身不算搜索。迁移事务可先把旧错误状态降为 pending，但任何 `candidate_found` 或 `source_confirmed` 都必须有同日 search/result 载荷和 reviewer 证据。

## assertion、requirement evidence 与检索闭包

v7 完成后，下面 5 条 assertion 都应存在 `endpoint_id`，并使用 `AFPV2`。迁移对它们的精确关系裁决如下；locator 和 context 用固定材料中的 exact-object 段落，不再只写“publication date”。

| assertion PK | preimage → postimage |
|---|---|
| `ASSERT-AWS-TRN2-ARCH-RELEASE-DATE-S11` | `supports` → `qualifies`；endpoint=`END-AWS-TRN2-S11-SNAPSHOT`；locator 定位公告标题日期和 `Trainium2 chip family/chips` 段；context 补直接主语；notes 写 `object mismatch: architecture not directly named`。它随 rejected fact 保留作反证，不得满足 accepted gate。 |
| `ASSERT-M2W3-AMD-MI455X-RELEASE-DATE-PRODUCT` | `supports` → `qualifies`；endpoint=`END-M2W3-AMD-MI455X-PRODUCT-SNAPSHOT`；locator 仍指 `Board Specifications, Launch Date`，context 补 `AMD Instinct MI455X GPUs / Launch Date 7/23/2026`；notes 写“材料发布日期为空，页面主语与 module target 不同”。它随 rejected fact 保留作反证。 |
| `ASSERT-M2W3-HUAWEI-DIE-RELEASE-H2` | 保留 `supports`；endpoint=`END-M2W3-HUAWEI-H2-SNAPSHOT`；locator 改为 H-2 中同时命名 `Ascend 950PR`、`Ascend 950DT` 和共享 `Ascend 950 Die` 的段落；context 补 exact sentence；`review_status=needs_resolution`，独立 reviewer 完成前不得升 fact。 |
| `ASSERT-M2W3-HUAWEI-PR-RELEASE-H2` | 保留 `supports`；同一 actual endpoint；locator/context 定位 `The first chip is Ascend 950PR` 和共享 die 段；`review_status=needs_resolution`。 |
| `ASSERT-M2W3-HUAWEI-DT-RELEASE-H2` | 保留 `supports`；同一 actual endpoint；locator/context 定位 `The next chip is Ascend 950DT` 和共享 die 段；`review_status=needs_resolution`；2026 Q4 availability 只作排除边界，不作该 assertion 的 raw date。 |

已有 `REVID-CAMBRICON-MLU590-RELEASE-DATE` 保留 `supports_pending`，在 v7 schema 中绑定 `END-CAMBRICON-WAIC-2022-MLU590-SNAPSHOT`；locator 保留页面日期并定位“在演讲的最后”段，context 扩成直接包含“云端智能训练芯片思元590”的句子，notes 从“不明确 release”改成“新语义候选；别名桥和更早检索未闭合”。postimage 还应插入四条 `supports_pending` evidence：MI350P blog 一条、Huawei Die/PR/DT 各一条，分别绑定上述 actual snapshot endpoint。MI455X 不插入 supports evidence，因为当前 source 不满足字段定义。

检索层不是装饰性备注。已有两条 search 要做下列转换：

| search PK | preimage → postimage |
|---|---|
| `SEARCH-CAMBRICON-MLU590-RELEASE-DATE` | query 从寻找 release/ordering notice 改为查 exact `思元590/MLU590` 最早厂商正式直接命名；检查 source type 扩为厂商新闻、演讲、产品/技术文档和可复现存档；检查未完成时仍为 `planned`，若把 2022-09-02 候选正式录入则为 `candidate_found`，不能直接为 `source_confirmed`。 |
| `SEARCH-M2W3-AMD-MI350P-RELEASE-DATE` | `no_reliable_result` → `candidate_found`；query 明写回查 2026-05-07 之前 AMD 对 exact `MI350P PCIe card` 的正式直接命名；notes 说明最早性未闭合。 |

已有 4 条 result 的 postimage 是：MLU590 `checked_no_support → candidate`；MI350P blog `checked_no_support → candidate`；MI350P brochure 和 product 保持 `checked_no_support`，但理由分别改成“只有月级版本标签”和“动态页无材料发布日期”。另新建 4 条 requirement-specific search：MI455X module、Huawei Die、Huawei PR、Huawei DT。MI455X search 先为 `planned`，并为现有产品页插入 `checked_no_support` result；Huawei 三条 search 在仅登记 H-2 候选时为 `candidate_found`，各自插入 H-2 `candidate` result。三对象不得共用一个 search PK 来宣称历史闭合。

任何新 evidence/search/result PK 必须在 planned post 中冻结为完整行，并进入 authorization 双向 set-equal。本稿只冻结语义和机械 ID 规则，不猜 reviewer、执行日期或尚未执行的查询结果；这些非确定值必须作为审批前 scalar 输入。缺一项时允许事务停在“全部旧错误值已降级、全部 requirement pending”的保守 postimage，不允许以假日期补齐。

## fingerprint 的重算边界

字段 ID 不变而定义改变，不能让旧 fingerprint 看起来仍代表同一事实合同。迁移先冻结：

```text
ReleaseSemanticId = RELEASE-DATE-SEMANTICS-V1
ReleaseDefinitionSha256 = 757e9a1275f9bbe1381fbbad06a24c0992689ebbe45cd22cd71305031ce6f41b
```

5 条 fact 和 6 条 requirement 都须重算 fingerprint。若 v7 后正式 fingerprint registry 已覆盖 field definition identity，直接服从该注册合同；若仍只是自由文本，则本迁移必须先批准下列 domain-separated 规则，不能让执行器自行选择字符串拼接：

```text
FactFingerprint = "RDFP1-" + SHA256(
  Frame("release-date-fact-fingerprint-v1",
        CanonicalJSON([target_kind,target_id,field_id,ReleaseSemanticId,
                       normalized_value_text,normalized_value_number,normalized_unit,
                       condition_set_id,valid_from,valid_to,resolution_state])))

RequirementFingerprint = "RDRP1-" + SHA256(
  Frame("release-date-requirement-fingerprint-v1",
        CanonicalJSON([target_kind,target_id,field_id,ReleaseSemanticId,
                       requirement_status,search_status])))
```

这里的 `target_kind/target_id` 必须由 object/component/link/relation/path/capability/topology 七选一 projection 生成，空值保留为空字符串；JSON 使用 v7 的 canonical runtime。`resolution_state` 和 requirement 状态进入 payload，是为了让 rejected/pending 行不能与旧 accepted/value_available 行共用 fingerprint。

assertion 不另创第三套算法。v7 已冻结：

```text
AssertionFingerprint = "AFPV2-" + SHA256(
  Frame("assertion-fingerprint-v2",
        CanonicalJSON([fact_id,source_id,endpoint_id,
                       assertion_relation,source_locator])))
```

因此 5 条 assertion 在 v7 首次迁移时先从旧 fingerprint 变成 AFPV2；本语义事务又因 `assertion_relation`、`endpoint_id` 或 `source_locator` 改变而第二次重算。任何复用第一次 AFPV2 的做法都应失败。新 requirement-evidence/search-result 的 endpoint-aware 行 hash同样由 v7 schema生成，不允许只绑定 source family 或远程 URL。

## 字段字典、模板与 coverage policy

正式 `fields.csv`、`资料卡/字段字典.md` 和 `资料卡/模板.md` 必须在同一事务里切换。三处的可见名称都改成“首次公开日期”，定义都使用 188-byte 原文；模板的值仍是 `<待填>`，但提示必须明确 exact object、材料日期、直接命名和禁止替代项。`研究计划.md` 中“新闻稿适合支撑发布日期”的概括改成“具日期且直接命名 exact object 的厂商/设计方正式材料可成为首次公开日期候选；availability/shipping/sales 另记”。研究计划中 source 自身的 `publication_date` 元数据规则不改，因为 source date 与 object field 是两件事。

v7 的 `coverage-policy-v5.0.json` 在 contract 阶段必须继续保存 `release_date_semantics_gate.migration_status=deferred_blocking`。本迁移不能回写 v7 报告或 v7 approval；它应基于已应用 policy 生成 present→present candidate，把：

```text
current_effective_field_name_zh = 首次公开日期
current_effective_definition = <188-byte definition>
target_field_name_zh = 首次公开日期
target_definition = <188-byte definition>
migration_status = applied
ga100_pre_migration_requirement_status = pending_verification
legacy_fact_ids = <exact 5-set>
legacy_requirement_ids = <exact 6-set>
review_status = reviewed
```

作为 gate postimage。`applied` 必须先进入该 JSON 合同的允许 token fixture；若 v7 policy schema 没有这个 token，事务在 candidate 阶段 fail closed，不能借自由文本绕过。policy 的 raw/canonical hash、approval binding、bootstrap/transaction 下游 hash按新 bytes 重算。GA100 的字段语义门由此解除，但 requirement 仍是 pending；“语义已生效”不等于“GA100 日期已确认”。

## 全部 active 引用面

R13 明列的主链是 5 facts、6 requirements、5 assertions、1 requirement-evidence、2 search-log、4 search-result。本轮全库复算还发现以下 active 引用面；它们都要进入 `ActiveReferenceClosure`，否则 formal row 与人读卡片会在事务后互相矛盾。

| 引用面 | 必须同步的 active 项 |
|---|---|
| completeness | `COMPLETE-CAMBRICON-MLU590-IDENTITY` 重写首次公开候选/别名缺口；`COMPLETE-M2W3-AMD-MI455X-IDENTITY` 删除已闭合 launch-date 表述；`COMPLETE-M2W3-AMD-MI350P-IDENTITY` 从 release `not_found` 改为 candidate pending。Huawei Die/PR 的 `evidence=complete` 降为 `partial`，DT 保持 `partial` 并补首次公开检索缺口。AWS architecture 的 evidence/identity 完整性随错误 fact 重评。 |
| selection | 不改 superseded `SELMEM-M1-AWS-TRN2-S11`。更新 active `SELMEM-M1R2-AWS-TRN2-S11` 和 `SELMEM-M2W3-AMD-MI455X-PRODUCT` 的 removal rationale；重跑 `SELRUN-M1-PILOTS-TRN2-CORRECTED-20260813`、`SELRUN-M2W3-AMD-MI455X-20260813`、`SELRUN-M2W3-AMD-MI350P-20260813`、`SELRUN-M2W3-HUAWEI-ASC950-PHYSICAL-20260813`。 |
| source screening / role / coverage | MI455X `SCREEN-M2W3-AMD-MI455X-PRODUCT`、`SROLE-M2W3-AMD-MI455X-PRODUCT-IDENTITY`、`COV-M2W3-AMD-MI455X-PRODUCT-BY-BROCHURE` 保留 vendor literal `Launch Date`，但删除其作为 first-public closure 的含义。`SROLE-AWS-TRN2-017` 只保留 chip-family/status 角色，不再指向 architecture date。MI350P blog role 从“publication date not promoted”改为“exact-card candidate, earliest search open”。 |
| source metadata | MI455X source 的 `version_label=page launch-date-2026-07-23` 可保留为页面自带字段记录，`publication_date` 必须继续为空；notes 增加“不支撑首次公开日期”。其余 6 个 source version 不改历史 publication metadata，只通过 evidence/search 记录候选资格。13 个 endpoint 的 URL、路径和 hash均不因语义迁移重写。 |
| cards / reuse map | Trainium2 试填草稿和架构卡把 S11 改述为 chip-family 公开候选，不是 architecture release；`trainium2_existing_reuse_map.csv` 的旧 accepted fact 从 active reuse 移除或标为 rejected/do-not-copy。MLU590 卡把 release/ordering 搜索拆成“更早正式直接命名”和 supply/GA 两条。MI455X 模组卡把 2026-07-23 写成 vendor `Launch Date` literal，并把首次公开日期设 pending。MI350P 卡把 release `not_found` 改为 2026-05-07 candidate/pending。三张 Huawei 卡在日期后标明 `provisional candidate；最早公开检索未闭合`。 |
| field-facing documents | `fields.csv`、字段字典、模板、研究计划和 coverage policy 按上一节同步；当前状态、任务台账和其他进度文件不在本迁移授权内。 |

builder 应按 CSV FK、精确 PK 和 Markdown/CSV 内容引用三路取并集。只写手工清单不够：任何仍把旧 fact 当 `accepted/canonical/value_available/not_found` 的 active 文件都是 `E_RELEASE_ACTIVE_REFERENCE_DRIFT`。历史审计和 staging 命中只记 inventory，不修改。

## 事务顺序

contract v7 与本迁移的唯一先后关系是：v7 先通过全部三运行时 fixture、独立验收、apply 和 `34/376/141` live gate；本事务随后冻结该 live postimage 的 raw hash。若 v7 尚未应用、AFPV2 schema 不存在或 counts 不符，本迁移不启动。

本迁移内部按以下因果顺序执行：先冻结 5+6 集合、证据闭包、active 引用闭包和 base hash；再固定 field/policy candidate、逐行 disposition 和 source eligibility；随后完成实际 search、evidence/result 候选及独立 reviewer 输入。具备这些直接输入后，生成 facts、requirements、assertions、引用表和卡片的 complete planned post；从 `ExactDiff(base,planned_post)` 机械生成 operations，而不是先定 operation 数。

planned post 经独立 approval 后，operations 施加到 isolated mirror。mirror 与 planned post byte/set-equal 后，才生成 table images、Markdown/CSV payload、rollback rows、rollback manifest、transaction manifest 和最终 approval。apply 期间 journal 只追加；任一文件 preimage hash、PK 集合、endpoint hash或 approval 变动都整包回滚，不允许先改字段名、后补卡片，也不允许先把 requirement 降级而遗漏引用面。

为避免把检索工作伪装成数据迁移，建议拆成同一事务的两个批准阶段：阶段 A 可以批准“保守语义 postimage”，即拒绝两条错配 fact、三条 Huawei 保持 provisional、6 条 requirement 全 pending；阶段 B 只有在搜索闭合时才批准后续独立 fact 升级。阶段 B 不是本事务的隐式续写，必须另有 transaction ID。这样即便尚未找到更早材料，旧语义也能安全退出，而不会制造未授权终值。

## 独立验收门

验收者不能是 builder 或本稿作者。门禁按以下顺序复算，任何一门失败即不 apply：

1. v7 prerequisite gate：live 正式库必须是 v7 已批准 postimage，计数精确为 `34/376/141`，assertion schema 含 `endpoint_id`，现有 assertion fingerprint 全符合 AFPV2。
2. scope gate：`LegacyFacts == exact 5-set`、`LegacyRequirements == exact 6-set`；FK evidence closure 与 active reference closure 都和 authorization 双向 set-equal；无额外 release fact 被静默插入。
3. semantic bytes gate：field、字典、模板和 policy 中名称逐字相同，定义 SHA-256 精确为 `757e...f41b`；旧“首次发布日期”在 active payload 中零命中，历史材料除外。
4. object/source gate：每个候选都有 exact target、第一方厂商/设计方 source、日级 publication date、actual preferred endpoint、直接命名 locator/context。architecture→chip、product→module、availability/shipping/sales→first-public 的投影均为零。
5. state closure gate：`AcceptedReleaseFactKeys == ValueAvailableRequirementKeys`；`ProvisionalReleaseFactKeys ⊆ PendingRequirementKeys`；`rejected` fact 不得满足 requirement；`not_found/not_public/not_applicable/inaccessible_evidence` target 不得有 active fact。本设计的保守 postimage 中 accepted/value_available 两集合都为空。
6. earliest-search gate：任何升为 accepted 的 key 恰有一个 requirement-specific terminal search，状态为 `completed/source_confirmed`；其 supports source 与 fact assertion source 一致；所有更早 candidate、inaccessible、identity-pending 集合为空，采用日期等于已审批候选的最小 `publication_date`。
7. fingerprint/hash gate：5 fact、6 requirement fingerprint 均含新 semantic ID；5 assertion 按最终 endpoint/relation/locator 重算 AFPV2；所有 operation pre/post row hash、table image、payload、policy、approval、manifest hash可由三运行时独立重建。
8. reference gate：completeness、selection、source screening/roles/coverage、reuse map、8 张受影响卡、字段字典、模板、研究计划和 policy 全部与 formal post 一致。superseded/history 字节未改；进度文件未改。
9. rollback/live gate：isolated mirror 与 planned post exact set-equal；rollback 在第二镜像恢复原 bytes；apply 后复跑第 1 至第 8 门。GA100 requirement 仍为 `pending_verification`，除非另一个经批准的 GA100 chip transaction 已独立完成。

其中第 4、6 门必须由独立 reviewer 读固定原文，validator 只检查结构化证据和集合关系，不能靠 URL、标题或关键词替代语义判断。

## GA100 `2020-05-14` 的候选边界

固定 NVIDIA Technical Blog 快照路径为 `审计/子代理交接/r1_ga100_source_staging_v3_official_web_v2/payload/html/nvidia-technical-blog_ampere-architecture-in-depth__captured-20260821.html`，实测 `330174 bytes`，SHA-256 为 `ced8cd095756924ef61121e83eb69f66ceeb100c6616f71ed8c2bb3cb1e76e52`。页面 metadata 和可见日期均给出 2020-05-14；正文直接写 `NVIDIA ... GA100 GPU`、`The NVIDIA GA100 GPU`，并清楚区分 full GA100 与 A100 implementation。

因此，这份材料满足新定义的“厂商正式材料、具日期、可核验、直接命名 exact GA100 对象”四项资格，不是从 Ampere 架构预告或 A100 产品供货倒推。它使 `2020-05-14` 成为强候选，但还不能证明此前没有 NVIDIA 或设计方材料直接命名 GA100。后续 GA100 包必须先把该 material 登记为新的正式 source version 和 actual snapshot endpoint，建立 `REQ-R1-GA100-V2-ID-RELEASE-DATE` 的 search/evidence/result，再检索更早官方材料并由独立 reviewer 裁决。NVIDIA Newsroom 关于 A100 production/shipping/sales 的日期无论早晚，都不能替代 GA100 first-public date。

如果历史检索找到更早的具日期正式材料且直接命名 GA100，取最早合格日期；如果只有架构名、A100 产品名或供货表述，不纳入候选集合；如果更早材料无法访问，则 requirement 保持 pending，不写 `not_found` 或 `2020-05-14 accepted`。

## 与 v7 数量和合同的隔离

本设计不修改 `r1_ga100_38_contract_repair_design_v7.md`，也不重写它的 approval、96 个 contract input 或 `34/376/141` 计数。release-date 语义迁移沿用 141 个 field 中的同一个 `FIELD-ID-RELEASE-DATE`，不增删正式表、schema column、field 或 enum row；因此对 v7 冻结计数的影响精确为 `+0/+0/+0`。policy token 若需注册，只能作为已冻结 JSON gate 的 migration-specific schema fixture，不能伪装成正式 `enums.csv` 增量。

后续事务会改变若干正式表和人读 payload 的 bytes，也可能因新增 evidence/search/result 增加数据行数；这些是 release-date transaction 自己的 operation/image/payload/hash，不反向改变 contract v7 的历史 contract counts。GA100 对象、requirement 和 fact 的行数也属于之后的 chip package，不计入本语义事务的 legacy 5+6，也不能被拿来修改 v7 的 `34/376/141` 声明。

## 自检与工具情况

本设计过程中发生两次非阻断工具问题。可选 HTML parser `bs4` 在本地环境不可用，分类为 tool/runtime failure（缺少模块）；我改用固定快照原文、结构化 metadata、现有 endpoint hash 和本地文本工具复核，没有降低来源边界。最后的 `git status` 检查因当前 artifact root 不在可识别的 Git worktree 中而失败，同样分类为 tool/runtime failure（运行环境不是 Git repository）；这不影响单文件交付，我改用目标文件存在性、正式文件 raw SHA-256 和受保护路径的直接内容校验。没有发生用户中断、sandbox denial、approval failure 或 remote service error。

最终交付前按 `report-humanizer` 要求，只对本 Markdown 做单文件扫描，并从末节向首节人工逆序复读 PK、状态、数字、hash 与限定词；扫描结果、最终 SHA-256 和行数在完成后写入交接回报，不把扫描日志或其他资产写入项目。
