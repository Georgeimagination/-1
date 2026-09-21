# `FIELD-ID-RELEASE-DATE` 语义迁移设计独立验收

审计日期：2026-08-21  
审计对象：`r1_release_date_01_semantic_migration_design.md`  
审计性质：只读复算与红队验收；本轮没有修改设计稿、正式 CSV、contract v7、staging、资料卡、模板或进度文件。  
唯一项目写入：本报告。

## 结论

`reject`

设计稿对字段语义和六组对象的实质判断是对的：字段应改为“首次公开日期”，不能把架构预告、下位产品、launch/availability/shipping/sales 投影成目标对象的首次公开；Trainium2 architecture 与 MI455X module 两条旧 fact 应拒绝，Ascend 950 三对象只能保留 provisional，MLU590 与 MI350P 只能进入 pending 候选链，GA100 的 `2020-05-14` 也只能算强候选。保守状态下 accepted 与 value_available 都为空，这一状态闭包成立。

拒绝原因不在上述语义裁决，而在事务尚未冻结成可以授权、set-equal、回滚的唯一方案。当前稿件没有给出 active 引用闭包的精确集合；把四个 2026-08-13 的 reviewed selection run 写成原 ID“重跑”，会改写历史运行与 cutoff；`coverage-policy-v5.0.json` 的 present→present 更新没有配套一个合法且唯一的 approval/version 路径；阶段 A 与阶段 B 的 row/payload 授权集合仍可分叉；fact/requirement fingerprint 又保留了条件分支。按本任务“任何无法 set-equal 即 reject”的门槛，不能以“实施时再生成 planned post”替代设计冻结。

这里的 `reject` 只表示当前设计还不能进入实施，不否定新字段定义，也不授权修改任何正式数据。

## 独立基线复算

我直接解析当前正式 CSV，没有从 R13 或设计稿抄数。核心表的行数和原字节 SHA-256 如下。

| 文件 | 数据行 | SHA-256 |
|---|---:|---|
| `数据/fields.csv` | 141 | `9e01cdb3bbd5db9dbdab0763db7b85a57c7bd055436ccdff1e88ad0f737b0233` |
| `数据/facts.csv` | 798 | `24addee6816046f5d3d1651cc4fc54e62e536a13d360c27c04bd833a89384871` |
| `数据/field-requirements.csv` | 1,059 | `7f84f6109d3a362bdf6beae395e6213bc2aefcfb0244ab7d4440680b0c8cf9a3` |
| `最小参考资料库/fact-assertions.csv` | 832 | `284489effdbfda10a37da139ded2d68c1608004fbc93336c0cd1ff023d5dab33` |
| `最小参考资料库/requirement-evidence.csv` | 73 | `e11d052d9900f3092d8d1bd90c3c727687d7a319586d86f6092f6da3ba489959` |
| `最小参考资料库/search-log.csv` | 353 | `52b253fb9a554b28dcdaf7a09f517e97a748746d77469b8e642fd37618a5ed94` |
| `最小参考资料库/search-results.csv` | 699 | `a5e1dbd8effe9007bf5b99a9ca8826a2cbb47a036554d6922eba2c35596b0e86` |
| `最小参考资料库/source-families.csv` | 92 | `03997ba2d81c5a3d2bacf3fb8c821f3b77399acfcf005ddb90f87c7f000e6bcb` |
| `最小参考资料库/sources.csv` | 93 | `eee9a5dd3161d1fc83cbf141c3af930e87fbdef1cf1eb4dda3a13388837518eb` |
| `最小参考资料库/source-endpoints.csv` | 153 | `e4984fef2846fbc299e93dd4573aa3252858848cd7eb7ecc42c4a0d7a249f7bd` |
| `最小参考资料库/source-screening.csv` | 101 | `dde05c0fd0557d945309ec11b782a14d6df56f74fb69604ea4a6bcc4dc2674b6` |
| `最小参考资料库/source-selected-roles.csv` | 113 | `1b7d95871586b874b076863f64f5e5a2e276a70a565bbe199d7ac0b69c7bb262` |
| `最小参考资料库/source-coverage.csv` | 27 | `5c20123eeddf5046e7b6bc8b44728d5eb89f2ce70106f292b3508b0311a7bf68` |
| `最小参考资料库/selection-runs.csv` | 11 | `1e2f0aa6e13af4f0ce5b9268c62bee58735b320196400f6ea2773354bbc1672c` |
| `最小参考资料库/selection-members.csv` | 106 | `33489268f80d30d4b1d0063da8cb7a15e8ad0fe3d1f1c961bc19d41339dfbd30` |
| `数据/card-completeness.csv` | 585 | `dc41bd9350cf82940953d2e5c843d5433c1cd9b2b081b9eb2100177f76d9b053` |

按 `field_id == FIELD-ID-RELEASE-DATE` 过滤，facts 与 requirements 分别恰为 5 行和 6 行，与设计稿双向 set-equal。沿这些主键复算，现存直接闭包也恰为 5 条 assertion、1 条 requirement evidence、2 条 search 和 4 条 result；没有发现额外 release-date fact、requirement、conflict member 或 derived input。

当前字段仍叫“首次发布日期”，定义仍是“具体对象日期，不用架构预告代替”。拟议新定义逐字编码为 UTF-8 后是 188 bytes，SHA-256 为 `757e9a1275f9bbe1381fbbad06a24c0992689ebbe45cd22cd71305031ce6f41b`。设计稿在名称、定义字节和 first-public 边界上的复算通过。

## 逐行语义裁决

### 5 条 fact

| fact | 独立结论 | 设计方向 |
|---|---|---|
| `FACT-AWS-TRN2-ARCH-RELEASE-DATE` | S11 直接命名的是 Trainium2 chip family/chips，不是 `OBJ-AWS-TRAINIUM2-ARCH`；应保留旧 target/value 作为错误历史行并置 `rejected`，不得原地改投 chip | 通过 |
| `FACT-M2W3-AMD-MI455X-RELEASE-DATE` | 动态产品页的 `Launch Date` 不是材料发布日期，页面主语又是 GPU，而 formal target 是 module；应置 `rejected`，不得改投 package | 通过 |
| `FACT-M2W3-HUAWEI-ASC950-DIE-RELEASE-DATE` | H-2 同日直接命名 exact die，但最早性未闭合；`2025-09-18/provisional` 可保留，置信度和 review 状态应降级 | 通过 |
| `FACT-M2W3-HUAWEI-ASC950PR-RELEASE-DATE` | H-2 直接命名 PR；2026 Q1 availability 不参与该值；只保留 provisional candidate | 通过 |
| `FACT-M2W3-HUAWEI-ASC950DT-RELEASE-DATE` | H-2 直接命名 DT；2026 Q4 availability 不参与该值；只保留 provisional candidate | 通过 |

### 6 条 requirement

| requirement | 独立结论 | 设计方向 |
|---|---|---|
| `REQ-CAMBRICON-MLU590-RELEASE-DATE` | 2022-09-02 第一方材料直接命名“思元590”，“在研”不再构成类别性排除；但 MLU590/思元590 同一性桥和更早材料仍开放 | 保持 `pending_verification/in_progress`，通过 |
| `REQ-M2W3-AMD-MI455X-RELEASE-DATE` | module 没有具日期且直接命名 module 的材料 | `value_available/completed` 降为 pending，方向通过 |
| `REQ-M2W3-AMD-MI350P-RELEASE-DATE` | 2026-05-07 官方 exact-card 文章是 first-public 候选，旧 `not_found` 已不成立 | 降为 pending，方向通过 |
| Huawei Die、PR、DT 三条 requirement | 三个对象分别有 H-2 候选，但三次更早材料检索都未闭合，不能共用一个 search 宣称完成 | 三条均降为 pending，方向通过 |

保守 post 的状态集合可以闭合：`AcceptedReleaseFactKeys == ValueAvailableRequirementKeys == empty`；三条 Huawei provisional key 都包含在 pending requirement key 中；两条 rejected fact 不满足任何 requirement。Phase A 只要完整同步全部引用面，就不会制造 accepted 或 value_available。

## 来源、endpoint 与 GA100 候选

7 个 source version 与 13 个 endpoint 均从正式表复算命中。分布为 MLU590 `1 source/2 endpoints`、Trainium2 `1/2`、MI455X `1/2`、MI350P `3/6`、Huawei H-2 `1/1`，合计 `7/13`。它们引用 7 个不同的 source family；这 7 行虽无需改值，也应作为 FK no-write guard 进入冻结基线。

七份固定载荷的 SHA-256 与设计稿全部一致：MLU590 `0ed095...a8a9`、Trainium2 `863600...e1f2`、MI455X `2fa276...5b47`、MI350P blog `2bc9cb...dfb8`、brochure `a4e93e...fb29`、product `09b3ff...c088`、Huawei H-2 `8bf0f4...7499`。MI455X source 的 `publication_date` 为空；MI350P brochure 只有月级版本标签；MI350P product 同样没有页面发布日期。设计没有把这些元数据误升为 first-public date。

GA100 固定快照实测为 330,174 bytes，SHA-256 为 `ced8cd095756924ef61121e83eb69f66ceeb100c6616f71ed8c2bb3cb1e76e52`。页面的 `article:published_time`、JSON-LD 与可见日期都落在 2020-05-14，正文有 `NVIDIA Ampere architecture-based GA100 GPU` 和 `The NVIDIA GA100 GPU` 等直接命名。它通过第一方、日级日期、可复现 actual endpoint、exact-object 直接命名四道候选门，但没有证明 2020-05-14 之前不存在更早官方材料，也尚未进入正式 source/endpoint/search/evidence 链。因此只能称“强候选”，不能生成 GA100 accepted fact；设计边界通过。

## Active 引用闭包没有冻结

设计稿用 `ContentAndFKReferences(...)` 命名了一个构造器，但没有定义搜索根、允许文件类型、active/history 判定、内容匹配规则，也没有给出期望 PK/path set。这个名称不能独立生成集合，因而无法与 authorization 双向 set-equal。

按当前正式库复算，除 1 条 field、5 facts、6 requirements 和 12 条 evidence/search 闭包外，至少还有以下活动面：7 个 source version、13 个 endpoint、7 个 screening、12 个 selected role、8 个 coverage、4 个当前 reviewed selection run、7 个当前 selection member，以及 7 个目标对象的 14 条 identity/evidence completeness。另有 1 个 superseded run 和其中 2 个历史 member，只能作 no-write 历史守卫。人读载荷则是设计列出的 8 张 Markdown 卡、1 张 Trainium2 reuse map、字段字典、模板、研究计划，以及 policy/approval 对。上述集合必须分别冻结完整 PK/path，而不是只写代表性条目。

现稿至少漏了三处会在 Phase A 后变成明显旧语义的 active 行：

1. `COMPLETE-CAMBRICON-MLU590-EVIDENCE` 仍写 WAIC “dynamic and unfrozen”，但正式 endpoint 已有带 SHA-256 的本地 snapshot；设计只点名 MLU590 identity，没有裁决这条 evidence completeness。
2. `COV-M2W3-AMD-MI350P-BLOG-NOT-EQUIV-PRODUCT` 仍写“Only available status is selected from the article”，而新语义已让同一 blog 承担 first-public candidate；设计只点名 MI455X coverage，没有给这条 coverage 的 postimage。
3. `SELMEM-M2W3-AMD-MI350P-BLOG` 的 mandatory reason 也只认 available status。稿件说“重跑”MI350P selection，却没有冻结替代 run/member 的 PK、cutoff、成员集合和 removal rationale，不能据此推导唯一 post。

此外，AWS S11 在正式 assertion 表中只支撑那条将被拒绝的 architecture fact。设计一方面不允许新增 Trainium2 chip fact，另一方面又预定保留 S11 的 active member 并改成 chip-family/status 角色，却没有说明该职责由哪一条 formal requirement/evidence 或 card obligation承接。这个选择结果需要明确裁决，不能由 builder 临场决定。

只要上述任一行或文件缺席，所谓 Phase A 就会出现 formal state 已降级而 selection、coverage、completeness 或卡片仍宣称旧闭合的混合态，违反设计自己的 `E_RELEASE_ACTIVE_REFERENCE_DRIFT` 门。

## Selection 历史与 cutoff 冲突

当前四个活动 run 都是 `created_date/cutoff_date=2026-08-13` 且 `status/review_status=reviewed`。本次语义迁移、候选重解释和独立批准发生在 2026-08-21。把同一 run ID 原地“重跑”，或者让它的成员吸收 8 月 21 日证据，会同时改写历史算法输入、cutoff 和 reviewed 结论。

可实施设计应新建四个 selection run 与新的 member PK，cutoff 不早于实际语义事务输入日期；旧四个 run 的审计内容和旧 member 保留。新运行通过后，如果生命周期规则要求，只能按明确授权把旧 run 的 `status/notes` 更新为 superseded，旧 member 不改。新运行的 scope、算法版本、source universe、成员全集、反向移除理由和 reviewer 必须进入 Phase A 或 Phase B 中唯一的一笔事务。当前稿件没有选择哪一阶段承接，也没有给新 ID，因此 selection 面不能 set-equal。

## Coverage policy 与 approval 没有唯一合法路径

v7 把 `审计/合同注册表/coverage-policy-v5.0.json` 及其 approval 作为 contract migration 的 stable candidate，冻结值是 `migration_status=deferred_blocking`。本稿随后要求同一路径 present→present 改成 `applied`，又说不得回写 v7 approval，同时只笼统要求重算“approval binding/downstream hashes”。这留下两个互斥实现：覆盖 v5.0 policy 并使既有 approval 失配，或连同 v5.0 approval 一起覆盖而改写 v7 的稳定批准件。两种都不是已授权 postimage。

修订稿必须选定一种无歧义路径。较稳妥的方案是发布新的 versioned policy/approval 对，并显式切换 active binding；如果一定要 present→present 替换 v5.0，则必须把 policy 与对应 approval 的 base/post、授权、回滚和历史 v7 snapshot 一并冻结，并解释为何这不构成对 v7 stable artifact 的改写。无论采用哪一种，`migration_status=applied` 都应是同一原子事务中的最后逻辑门：field、事实、要求、证据、selection、coverage、completeness、卡片和 validator 全部达到 planned post 后才可生效，不能先解除 GA100 语义门再补引用面。

## Phase A、Phase B 与 fingerprint

v7 必须先正式 apply，并通过 `34 tables / 376 schema columns / 141 fields`、`endpoint_id` 与全量 AFPV2 live gate；这一前置顺序正确。Phase A 的保守状态也可以成立，但稿件没有冻结 Phase A 到底包含哪些新 evidence/search/result 行。设计稿第 119、128 行要求新增 evidence/search/result，第 130、212 行又允许在 reviewer、日期或查询未完成时停在保守 post。于是同一个“Phase A”至少有两种合法行数和两套 payload，ExactDiff 与 authorization 不唯一。

修订后应把 Phase A 定义成一笔完整、独立、可回滚的语义退出事务：只使用已经存在且可复核的输入，冻结每个 insert/update/no-write guard 与 8 卡、reuse map、字段文档、policy/approval 的精确 post；accepted/value_available 仍为空。需要新执行查询、写入新 search/evidence/result 或把候选升为事实的工作全部进入新的 transaction ID。Phase B 必须是后续独立事务，重新冻结 base、requirement-specific 搜索、selection run、fingerprint、authorization 和 rollback，不能作为 Phase A manifest 的续写。设计提出 Phase B 要用新 transaction ID，这个方向正确，但“同一事务的两个批准阶段”应删去，避免状态机出现双重解释。

AFPV2 部分可以实施：v7 先为 832 条 assertion 引入 endpoint-aware fingerprint，本迁移再因 relation、endpoint 或 locator 变化重算 5 条相关 assertion，不能复用第一次 AFPV2。fact/requirement 部分则仍有条件分支：“若 v7 registry 已覆盖定义就服从，否则用 RDFP1/RDRP1”。v7 已冻结的文本只明确 AFPV2，并没有给本字段的 fact/requirement semantic-identity registry。修订稿应直接选定 RDFP1/RDRP1，或绑定一个确切 registry path/hash；同时给出 canonical byte golden vector、重复/碰撞门和 5+6 的预期 fingerprint set。RequirementFingerprint 含 `requirement_status/search_status`，Phase B 改状态时必须再次重算，也要在 Phase B 合同中明写。

## 重新送审前必须补齐的内容

下一版不需要改动已通过的语义结论，但必须把设计从“原则正确”推进到“只有一个 planned post”。具体而言，应冻结 Phase A 的完整 active PK/path set 及 exact pre/post row 或 row hash；用新 ID 追加 selection run/member，而不是重写 2026-08-13 reviewed 运行；补齐 MLU590 evidence completeness、MI350P blog coverage/member 等遗漏；选定 policy/approval 的版本与切换方式；消除 fingerprint 条件分支；分别给 Phase A 和 Phase B 独立的 transaction ID、base hash、operation/payload authorization、rollback manifest 与 no-write 历史守卫。完成这些修订后，再做一次独立 set-equal 验收。

## 验收边界与工具情况

本轮没有发生用户中断、sandbox denial、approval failure、approval-review connection failure、remote service error、tool/runtime failure 或 model/operator mistake。审计仅依赖本地固定文件和 CSV/字节级复算，不需要网络，也没有尝试运行 Windows PowerShell hard gate；后者属于未来正式 apply 的前置，不影响本次设计拒绝结论。

本报告的 `reject` 只代表当前设计不可实施；它不把任何候选日期升级为正式事实，也不代表 v7、source-pool-113、GA100 chip package 或 Windows 三道 hard gate 已经通过。
