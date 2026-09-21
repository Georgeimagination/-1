# `FIELD-ID-RELEASE-DATE` 语义迁移独立审计

审计日期：2026-08-21  
审计性质：只读、独立复算；本报告没有修改任何正式 CSV、资料卡、来源快照或合同稿。

## 结论

新语义本身可接收，但不应在 contract v6 主事务中直接发布。当前 5 条 fact 和 6 条 requirement 中，没有一组能在不补做证据裁决的前提下整体继承：Trainium2 和 MI455X 存在对象层级或日期语义错配；MLU590 与 MI350P 的旧否定理由在新语义下已经失效；Ascend 950 三条值有直接正证，却没有“没有更早正式公开”的检索闭环。

因此，v6 应当只冻结后续迁移目标和 5/6 全集，要求 GA100 的 `REQ-R1-GA100-V2-ID-RELEASE-DATE` 继续为 `pending_verification`，同时禁止在语义迁移前提前生成 GA100 release-date fact。字段改名、旧行裁决、检索补证、卡片同步和 validator 应放入一个独立、原子的 release-date migration。

## 基线与受影响全集

我用 CSV 解析器按 `field_id == FIELD-ID-RELEASE-DATE` 独立筛选，而不是从现有报告复制数字。`facts.csv` 共 798 行数据，命中 5 行；`field-requirements.csv` 共 1,059 行数据，命中 6 行。其他 30 张正式表中没有隐藏的 release-date fact、conflict member 或 derived input。

| 文件 | 数据行 | 当前 raw SHA-256 |
|---|---:|---|
| `数据/fields.csv` | 141 | `9e01cdb3bbd5db9dbdab0763db7b85a57c7bd055436ccdff1e88ad0f737b0233` |
| `数据/facts.csv` | 798 | `24addee6816046f5d3d1651cc4fc54e62e536a13d360c27c04bd833a89384871` |
| `数据/field-requirements.csv` | 1,059 | `7f84f6109d3a362bdf6beae395e6213bc2aefcfb0244ab7d4440680b0c8cf9a3` |
| `最小参考资料库/fact-assertions.csv` | 832 | `284489effdbfda10a37da139ded2d68c1608004fbc93336c0cd1ff023d5dab33` |
| `最小参考资料库/requirement-evidence.csv` | 73 | `e11d052d9900f3092d8d1bd90c3c727687d7a319586d86f6092f6da3ba489959` |
| `最小参考资料库/search-log.csv` | 353 | `52b253fb9a554b28dcdaf7a09f517e97a748746d77469b8e642fd37618a5ed94` |
| `最小参考资料库/search-results.csv` | 699 | `a5e1dbd8effe9007bf5b99a9ca8826a2cbb47a036554d6922eba2c35596b0e86` |

主链还包含 5 条 fact assertion、1 条 requirement evidence、2 条 search log 和 4 条 search result。当前关系本身已经显示语义不闭合：四条 `value_available` requirement 对应的 fact 全是 `provisional`；唯一的 `accepted` fact 是 Trainium2 architecture，反而没有 requirement。当前 validator 只检查 `value_available` 能找到同 target/同 field 的某条 fact，不检查 fact 是否 `accepted`，也不检查 fact 到 requirement 的反向闭合。

## 新语义的可执行边界

建议后续迁移把两个 cell 固定为：

```text
field_name_zh = 首次公开日期
definition = 厂商或设计方在具日期、可核验的正式材料中首次直接命名/宣布该研究对象；不能用上位架构预告、下位产品发布、availability/shipping/sales 替代
```

这个字段记录“对象在正式公开材料中首次出现”，不是上市、可购买或首次交付日期。一份材料能证明“截至当日已公开”，但单独一份材料通常不足以证明“此前从未公开”。除非原文明确表达当日首发，否则需要一条按 exact object 反查更早厂商或设计方材料的检索记录。即使原文写了“today announced”，最终的 `accepted/value_available` 仍应由独立复核者确认对象绑定和更早来源范围。

当前 `数据/fields.csv` 仍是“首次发布日期；具体对象日期，不用架构预告代替”，`资料卡/字段字典.md` 和 `资料卡/模板.md` 也使用旧名称。在这三处没有原子切换前，不能用报告或 coverage policy 里的新句子宣称正式语义已生效。

## 5 条 fact 的逐行裁决

| fact PK | assertion PK | source / actual local endpoint |
|---|---|---|
| `FACT-AWS-TRN2-ARCH-RELEASE-DATE` | `ASSERT-AWS-TRN2-ARCH-RELEASE-DATE-S11` | `SRC-AWS-TRN2-S11` / `END-AWS-TRN2-S11-SNAPSHOT` |
| `FACT-M2W3-AMD-MI455X-RELEASE-DATE` | `ASSERT-M2W3-AMD-MI455X-RELEASE-DATE-PRODUCT` | `SRC-M2W3-AMD-MI455X-PRODUCT-20260813` / `END-M2W3-AMD-MI455X-PRODUCT-SNAPSHOT` |
| `FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE` | `ASSERT-M2W3-HUAWEI-DIE-RELEASE-H2` | `SRC-M2W3-HUAWEI-H2-ASC950-KEYNOTE-20250918` / `END-M2W3-HUAWEI-H2-SNAPSHOT` |
| `FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE` | `ASSERT-M2W3-HUAWEI-PR-RELEASE-H2` | 同一 Huawei source / endpoint |
| `FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE` | `ASSERT-M2W3-HUAWEI-DT-RELEASE-H2` | 同一 Huawei source / endpoint |

| fact PK | 当前 target / value | 独立核对 | 迁移裁决 |
|---|---|---|---|
| `FACT-AWS-TRN2-ARCH-RELEASE-DATE` | `OBJ-AWS-TRAINIUM2-ARCH / 2023-11-28 / accepted` | `SRC-AWS-TRN2-S11` 的固定快照直接写“today announced”，并把 AWS Graviton4 和 AWS Trainium2 称为两个 chip family；后文也写 `Trainium2 chips`。它没有直接命名 `AWS Trainium2 architecture` 或 NCv3。正式架构卡反而明说架构对象未建立自身断言。 | 不得保留在 architecture target。旧 fact 应降为 `rejected`，旧 assertion 改为 `qualifies` 并记录 object mismatch。`2023-11-28` 可迁移为 `OBJ-AWS-TRAINIUM2-CHIP` 的强候选，但要使用新 fact/assertion PK，不能原地改一个带 `ARCH` 的 PK。在更早公开检索闭合前不升为 `accepted`。 |
| `FACT-M2W3-AMD-MI455X-RELEASE-DATE` | `OBJ-AMD-MI455X / 2026-07-23 / provisional` | 固定产品页确实有 `Launch Date 7/23/2026`，但页面无 `publication_date`，只能证明 2026-08-13 快照时页内有这个字段。页面主语是 MI455X GPU，正式 `OBJ-AMD-MI455X` 却是已退出芯片主线的 EAM `module`；冻结名单另行保留的是内层 GPU `package`。 | 降为 `rejected`，不得把动态页的 Launch Date 自动解释成 first public date，也不得投影到 module。后续先建立新 package 对象与它的正式身份映射，再搜索早于 2026-07-23 的官方直接命名。 |
| `FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE` | `OBJ-HUAWEI-ASCEND-950-DIE / 2025-09-18 / provisional` | 2025-09-18 官方演讲在同一页直接写 `Ascend 950PR and Ascend 950DT chips will use the same Ascend 950 Die`，对象层级和日期均直接。 | 值和 target 可保留为 `provisional` 候选，不能当作已完成的首次公开事实。补做更早官方材料检索，把 assertion 补成 actual endpoint、定位原文、引用上下文和独立 reviewer 后，才可升为 `accepted`。 |
| `FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE` | `OBJ-HUAWEI-ASCEND-950PR / 2025-09-18 / provisional` | 同一官方演讲直接写 `Ascend 950PR` 且称其为 chip。该日期不是后文 roadmap availability 的逆向投影。 | 与 die 相同：保留 `provisional` 候选，重新闭合“最早”和独立复核；不使用供货季度支撑这一字段。 |
| `FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE` | `OBJ-HUAWEI-ASCEND-950DT / 2025-09-18 / provisional` | 同一官方演讲直接写 `Ascend 950DT`，并另行写它将于 2026 Q4 available。这两个日期语义清楚分开。 | 保留 `2025-09-18` 为 `provisional` 候选；要求与 die/PR 分别建立 requirement-specific 检索闭环。2026 Q4 只能进 availability/status 链。 |

五条 fact 主链使用的三份本地快照都存在，我重算的 SHA-256 均与 `source-endpoints.csv` 一致：AWS S11 为 `8636005578721583b257d1ed88e5806315b0ff6ac5c93105160725890547e1f2`，MI455X 产品页为 `2fa27618862c42b0b9e6eed2e5c88c360e6eac2650d9fc97bae08c6338315b47`，Huawei H-2 为 `8bf0f453e143562c7b5f3ead61f54a35da6020689dbc20aede772da0d00d7499`。AWS source 和 endpoint 当前仍是 `draft`；MI455X 与 Huawei 的四条 assertion 虽是 `reviewed/source_checked`，`reviewer` 却为空。

## 6 条 requirement 的逐行裁决

| requirement PK | 当前状态 | 证据链判断 | 迁移操作 |
|---|---|---|---|
| `REQ-CAMBRICON-MLU590-RELEASE-DATE` | `pending_verification / in_progress` | 2022-09-02 寒武纪页面直接写“在研…全新一代云端智能训练芯片思元590”。新语义不要求已供货，所以“in-development disclosure, not an explicit release notice”不再是否定理由。正式库已把“思元590”作为该 object 的 accepted official name，但同页“MLU590”别名仍未证实。 | 保留 `pending_verification`，重写 applicability reason；`REVID-CAMBRICON-MLU590-RELEASE-DATE` 保留 `supports_pending`，补全直接命名上下文。`SEARCH-CAMBRICON-MLU590-RELEASE-DATE` 改为查“最早官方直接命名”，`SRESULT-CAMBRICON-MLU590-RELEASE-DATE` 从 `checked_no_support` 改为 `candidate`。先不新建 fact。 |
| `REQ-M2W3-AMD-MI455X-RELEASE-DATE` | `value_available / completed` | 其 canonical fact 已因动态页无发布日期和 module/package 错配失去支撑。 | 降为 `pending_verification / in_progress`，去掉“Canonical fact”结论。新增 exact-module 搜索记录；现有产品页对 module requirement 只能记 `checked_no_support`。新 GPU package 的候选链必须另建，不和本 PK 合并。 |
| `REQ-M2W3-AMD-MI350P-RELEASE-DATE` | `not_found / completed` | `SRC-M2W3-AMD-MI350P-BLOG-20260507` 是具精确日期的 AMD 官方文章，标题和正文直接命名 MI350P PCIe card。在新语义下，article publication date 不能被类别性拒绝；它是 `2026-05-07` 的有效候选。当前检索只证明已检查的三份来源中该文章是唯一具有日级精度的候选，没有证明它是全部官方历史的最早项。 | 从 `not_found/completed` 改为 `pending_verification/in_progress`；`SEARCH-M2W3-AMD-MI350P-RELEASE-DATE` 改为 `candidate_found`，`SRESULT-M2W3-AMD-MI350P-RELEASE-DATE-BLOG` 改为 `candidate`。`SRESULT-M2W3-AMD-MI350P-RELEASE-DATE-PRODUCT` 仍是 `checked_no_support`；只有 `05/26` 月份标签的 brochure 不能单独支撑精确 date，对应 `SRESULT-M2W3-AMD-MI350P-RELEASE-DATE-BROCHURE` 可保留 `checked_no_support` 但必须改写理由。 |
| `REQ-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE` | `value_available / completed` | 有直接对象和日期，无 requirement evidence 或 search log。 | 降为 `pending_verification / in_progress`，新建该 die 的更早官方公开检索。候选源为 `SRC-M2W3-HUAWEI-H2-ASC950-KEYNOTE-20250918`。 |
| `REQ-M2W3-HUAWEI-ASC950PR-RELEASE-DATE` | `value_available / completed` | 有直接对象和日期，无 requirement evidence 或 search log。 | 同样降为 `pending_verification / in_progress` 并建立 PR-specific 检索，不用 die 或 DT 的行代替。 |
| `REQ-M2W3-HUAWEI-ASC950DT-RELEASE-DATE` | `value_available / completed` | 有直接对象和日期，无 requirement evidence 或 search log。 | 同样降为 `pending_verification / in_progress` 并建立 DT-specific 检索，明确排除 2026 Q4 availability 值。 |

MLU590 快照 SHA-256 为 `0ed0950c492ca46344be53a0e815a24282c8c55389079c0bb7bde856458ad8a9`。MI350P BLOG 快照 SHA-256 为 `2bc9cbb81e424e4d1c5d6912b43e7cfb1107081f159b012d8ad9cffd3b66dfb8`；页内同时有 `datePublished=2026-05-07`、页首 `May 07, 2026` 和精确对象名。它证明这个对象在该日已被 AMD 正式公开，不能单凭现有检索将“该日已公开”再升级为“历史最早”。

## 后续独立迁移的 operation 合同

迁移输入先按正式 preimage 构造两个全集，并和下列 ID 双向 set-equal：

```text
legacy_release_fact_ids = {
  FACT-AWS-TRN2-ARCH-RELEASE-DATE,
  FACT-M2W3-AMD-MI455X-RELEASE-DATE,
  FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE,
  FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE,
  FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE
}

legacy_release_requirement_ids = {
  REQ-CAMBRICON-MLU590-RELEASE-DATE,
  REQ-M2W3-AMD-MI350P-RELEASE-DATE,
  REQ-M2W3-AMD-MI455X-RELEASE-DATE,
  REQ-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE,
  REQ-M2W3-HUAWEI-ASC950DT-RELEASE-DATE,
  REQ-M2W3-HUAWEI-ASC950PR-RELEASE-DATE
}
```

建议新建一份只属于该迁移事务的 decision artifact。每个旧 PK 恰有一行，裁决只允许 `retain_recomputed`、`repair` 或 `downgrade`，并列出对应 operation ID。`retain_recomputed` 必须重算 fingerprint，绑定 exact object、actual endpoint、canonical locator、具体上下文、更早来源检索和独立 reviewer；`repair` 如果改变了 target，必须拒绝旧 fact 并插入新 PK，不能让 PK 文义与行内 target 分裂；`downgrade` 不能遗留 `value_available` 或被卡片当成已发布值。

主行还不够。builder 需沿 FK 计算证据闭包，对当前 5 条 assertion、1 条 requirement evidence、2 条 search log 和 4 条 search result 逐行授权，新插入的 requirement/search/result/assertion 也必须加入同一 operation set。这个闭包与 operations 双向 set-equal：遗漏一条旧反证、新建一条未批准的 date fact，或额外改动无关 field 都应 fail closed。

非 CSV 载荷也要从内容引用独立构造，而不是靠手写清单。必改项包括 `资料卡/字段字典.md`、`资料卡/模板.md` 和 `研究计划.md`；内容搜索还命中 Trainium2 两份卡/映射、MLU590 卡、MI455X 卡、MI350P 卡以及三份 Ascend 950 卡。如果 fact 的状态或 ID 改变，只重跑当前 `SELRUN-M1-PILOTS-TRN2-CORRECTED-20260813`、`SELRUN-M2W3-AMD-MI455X-20260813`、`SELRUN-M2W3-AMD-MI350P-20260813` 和 `SELRUN-M2W3-HUAWEI-ASC950-PHYSICAL-20260813`；已 superseded 的旧 run 保留当时审计原文，不回写历史。

## validator 与 set-equal 条款

现有 enum 已能表达这次迁移：`provisional/rejected`、`pending_verification`、`candidate_found/source_confirmed`、`candidate/supports_requirement/checked_no_support` 和 `supports_pending` 都已存在，不需要为新语义增加 enum row。validator 至少实施以下闭环：

```text
AcceptedReleaseFactKeys =
  Project(target_kind, target_id, FIELD-ID-RELEASE-DATE,
          facts where resolution_state == accepted)

ReleaseValueRequirementKeys =
  Project(target_kind, target_id, FIELD-ID-RELEASE-DATE,
          requirements where requirement_status == value_available)

Require(AcceptedReleaseFactKeys == ReleaseValueRequirementKeys)
Require(ProvisionalReleaseFactKeys subset_of PendingReleaseRequirementKeys)
Require(NoActiveReleaseFactFor(not_found, not_public,
                               not_applicable, inaccessible_evidence))
```

每个 `accepted/value_available` key 还必须有 requirement-specific search closure，且 decision artifact 恰指定一个当前 authoritative terminal search ID；历史 search log 不必删除。被采用 assertion 的 source 必须是厂商或设计方的 first-party source，`sources.publication_date` 非空且和规范化日期一致；assertion 必须为 `supports + independently_reviewed`，有 actual preferred endpoint、对象命名定位、非空上下文和非空独立 reviewer。被指定的 search log 必须为 `completed/source_confirmed`，对应的 `supports_requirement` source 和 fact assertion source 一致；fact date 必须等于已审批的 exact-object official candidate source 中最早的 `publication_date`。早于它的 `candidate`、无法访问项或对象层级待裁决项不为空时，不得升为 `value_available`。

validator 不能靠搜索 locator 里是否出现 `launch`、`available` 或 `shipping` 来替代人工语义复核。机器门应检查结构化裁决、证据链、日期最小值和对象 key；独立 approval 对“这份材料是否直接命名 exact object”负责。这样才不会把日期字面规则写成另一个可绕过的弱门。

## 对 contract v6 的 count/hash 影响

按本报告建议拆分后，release-date 对 v6 主事务的数量影响是精确的 `+0`：正式计数继续是 `34 tables / 376 schema columns / 141 fields / 77 enum groups / 564 enum rows`，contract table image、payload、managed target 和 file-input 的数量也不因本语义迁移改变。v6 当前因其他前置事务使用 96 个 contract file input；release-date 对该数是 `+0`，不能用它解释稿件中任何旧的 94 残留。

即使不发布正式行，v6 coverage-policy candidate 只要新增 deferred gate，它的 raw/canonical hash、approval 绑定 hash、bootstrap candidate item hash、transaction file-input set hash 和 transaction manifest hash 都必须重算。这是内容 hash 变化，不是输入数量变化。deferred gate 中的 target definition 应使用本报告前述 byte-exact 文本，不应换成范围更宽的“厂商/官方来源”摘要。

如果强行把迁移并入 v6，在未完成搜索时就没有合法的 exact postimage，因而不存在可信的固定 operation count 或 postimage hash。只计当前已存在的闭包，就至少需要 24 条行操作：1 条 field、5 条 fact、6 条 requirement、5 条 assertion、1 条 requirement evidence、2 条 search log 和 4 条 search result。`facts.csv` 与 `field-requirements.csv` 还会从 v6 的 unchanged snapshot 变成 managed table image；后续新搜索行、Trainium2 chip 新 PK、卡片同步和 selection rerun 会继续增加这个数。在这些行和 payload 全部冻结之前，任何人都不应预先填一个“新 v6 总数”来迫使事务对齐。

## 交付自检

本报告只新增当前这一个 Markdown。成品已按段落首句、表格结论、转折和结尾逐段人工复读，并按末行到首行逆序检查 PK、数字、状态和 hash。`report-humanizer` 扫描对象是本文件本身，不是目录。
