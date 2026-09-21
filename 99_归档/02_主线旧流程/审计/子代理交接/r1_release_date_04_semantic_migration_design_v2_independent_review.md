# `FIELD-ID-RELEASE-DATE` 语义迁移设计 v2 独立验收

审计日期：2026-08-21  
审计对象：`r1_release_date_03_semantic_migration_design_v2.md`，744 行，SHA-256 `c0e4add73d621e5dee5e68904c58469db7f48d833fff3df93e21251d45d19c9e`  
审计性质：只读机械复算与红队验收；没有修改设计稿、正式 CSV、资料卡、contract、validator、staging 或进度文件。  
唯一项目写入：本报告。

## 验收结论

`reject`

v2 已经修正 v1 的主要集合错误。103 条 active identity、106 条含 history guard identity、18 个 active preimage payload、81 个 row target、25 个 managed payload target、13 张 table image 和 38 个 rollback target都能按稿内列出的 PK/path 复算；MLU590 evidence completeness 与 MI350P blog coverage/member 没有再漏。Phase A 的保守状态、Phase B 的事务隔离、v5.0 no-write、v5.1 active resolver 的方向和 hash DAG 也没有发现环。

拒绝原因在 planned post 仍不唯一。v2 冻结了大部分目标身份、状态和集合 hash，却没有冻结新 selection 行、若干正式 update、19 个 present-to-present payload、16 个 fixture 及新 approval 的完整可构造字节。把实施器在 prepare 阶段自行写出的候选再用 hash 绑定，只能证明该次候选没有漂移，不能证明设计本身只有一个候选。这正是 R02 要求下一版消除的分叉；在 `ExactRowDiff(V7Base, CompletePlannedPost)` 和 isolated mirror 之前，必须先有唯一的 `CompletePlannedPost`。

本次 `reject` 不否定字段定义和五条 fact、六条 requirement 的语义裁决，也不授权修改任何正式数据。

## 机械复算结果

我直接解析当前正式 CSV 和设计中的 exact list，未抄用设计里的合计数。通过项如下。

| 检查面 | 独立复算 | 结论 |
|---|---|---|
| 字段定义 | 新定义为 188-byte UTF-8，SHA-256 `757e9a1275f9bbe1381fbbad06a24c0992689ebbe45cd22cd71305031ce6f41b` | 通过 |
| active closure | 103 项，framed set hash `30c27efce51e187ff8c94cde63f441629029704414e47d756465ef065c5c013d`；加入 1 个 superseded run 和 2 个 history member 后为 106 项，hash `efec06bc0872e5252836e9915facb2a6b2b2ab2d9c27ee64fc72c502aa3ad3ea` | 通过 |
| active payload | 18 个路径，hash `a8d17c5f560f191e4d2bcf77a2a027736324285087b0d8fcdc17c43f7c7ccf0c` | 路径集合通过；内容扫描规则另见阻断项 |
| Phase A row target | 81 个唯一 `[table_path,PK,kind]`，覆盖 13 张表，hash `c2975c797ea9a2a29f7602e79335b9c245178d7fb8beaa7d482905f04db50349` | target identity 通过 |
| managed payload target | 19 个 present→present 加 6 个 absent→present，共 25 个唯一 path/state tuple，hash `16c98850247a3d55dcb5260f2c8c2afb49073a775b1e19881afbb7fd0c73dfdb` | target identity 通过 |
| image / rollback | 13 张 changed table image；`13 + 19 + 6 = 38` 个 rollback target | 数量与类别通过 |
| 旧 selection | 5 个 predecessor run、48 个 member；81 个 row target中没有旧 run/member update 或 delete | 通过 |
| 新 selection | 4 个 run ID；28 个机械 member ID 和 28 个 `[member_id,run_id,source_id,role]` 四元组均唯一，framed hash `b08ec022bd25d3ee7c726934486d640d72d132c4e17cbe55176644f916fefbd6` | 身份层通过；完整行另见阻断项 |
| selection source universe | 28 source 均存在，映射到 28 个不同 family，并命中 54 个不同 endpoint；没有缺行或无 endpoint source | 计数与成员关系通过；三个 guard hash另见阻断项 |
| fingerprint | 5 个 RDFP1、6 个 RDRP1、5 个 AFPV2 全部按单一 framing 重算，与稿内 16 个 expected value 一致；AWS fact canonical payload 为 151 bytes | 算法和值通过；fixture 文件另见阻断项 |

active closure 的分组也逐项相等：`1 field + 5 facts + 6 requirements + 5 assertions + 1 requirement evidence + 2 search logs + 4 results + 7 families + 7 sources + 13 endpoints + 7 screening + 12 roles + 8 coverage + 4 current runs + 7 affected current members + 14 completeness = 103`。这条闭包确实包含 `COMPLETE-CAMBRICON-MLU590-EVIDENCE`、`COV-M2W3-AMD-MI350P-BLOG-NOT-EQUIV-PRODUCT` 和 `SELMEM-M2W3-AMD-MI350P-BLOG`，因此 R02 指出的三处漏项已经补齐。

Phase A 的状态投影也能闭合为 2 条 rejected fact、3 条 provisional fact、6 条 pending requirement、0 条 accepted fact 和 0 条 value-available requirement。81 项 operation universe 只更新 2 个既有 search 和 4 个既有 result，没有 search/evidence/result insert；稿内也禁止在 Phase A 临时增加查询。Phase B 使用新的 transaction family、base、cutoff、authorization、approval、mirror 和 rollback，与 Phase A 的 81/25 集合分离，这两项通过。

## 阻断项

| 编号 | 阻断事实 | 为什么不能通过 |
|---|---|---|
| `R04-B01` | 新 selection 只有 PK、scope、cutoff、algorithm、reviewer scalar 和 source/role 四元组被固定。正式 `selection-runs.csv` 还有 `notes`；`selection-members.csv` 还有 `mandatory_reason`、`review_status`、`notes`。v2 第 421 至 463 行只给语义理由，没有这些 cell 的 exact string 或机械 constructor。 | 4 个 run 和 28 个 member 可产生多套完整 CSV post row，但都会保留相同 ID、计数和四元组 hash。新行的 post row hash、81 项授权 payload和 exact diff因此不是设计的函数。 |
| `R04-B02` | 多个既有 row update 及 19 个 present→present payload 仍以自然语言描述 post。典型例子是 screening、selected role、coverage 和 completeness 的“rationale 加入”“notes 改为”，以及 8 张卡、reuse map、字段文档、计划、AGENTS、README 和两个 validator 的 semantic patch。第 295 行虽然要求 operation 保存完整 post row，第 639 行也要求 authorization 记录完整 post hash，但设计没有给出 exact cell、唯一 anchor/replacement 或完整候选 raw hash。 | 两名合规 builder 可以写出语义等价、字节不同的 row、Markdown、CSV、JSON 或 PowerShell post，再分别批准自己的 hash。authorization 只能锁住事后选择，不能消除选择。18 路径的内容检查也没有枚举 `active roots`，没有定义 Markdown 段落边界或 CSV/JSON/PowerShell 的“同段”规则；第 291 行的扫描器不能据此唯一实现。 |
| `R04-B03` | v2 固定了 16 个 fingerprint value，却只说向 `canonical-fixtures.csv` 追加 16 行、向 runtime result 追加 48 行并重算 manifest。它没有给 fixture ID、完整 fixture row、runtime-result ID/row、排序位置、v7.1 manifest 的完整 key/value 或唯一 constructor。 | RDFP1/RDRP1/AFPV2 本身单一且重算时点没有条件分支，但三个 fixture payload 的 post bytes仍有多种合法写法，无法生成唯一 raw hash、mirror 和 rollback pre/post。 |
| `R04-B04` | v5.1 policy approval、amendment approval和 authorization approval复用 9-key `ARTIFACT-APPROVAL-V1`，但 v2 没有冻结 `approved_by`、`approved_date`、`notes`，也没有要求 approver 与相应 artifact 的 preparer/reviewer 不同。amendment 只要求 `prepared_by != reviewed_by`。既有 v7 approval 校验明确要求 approver 不得等于 preparer 或 reviewer。 | 自签 approval 在 v2 文本下没有被拒绝；即使外部人工避免自签，approval bytes 仍不唯一。版本链和 DAG 拓扑无环，不足以弥补批准件身份约束和 postimage 未冻结。 |
| `R04-B05` | 第 465 行给出 28 source、28 family、54 endpoint 的三个 hash，却没有给三组 hash 的 item shape、排序、canonical JSON 和 domain/framing。第 663 行随后把它们当作 no-write guard。GA100 后续 input 也只写“替换 v5.0 pair、增加 amendment pair”，没有冻结新增 pair 的 exact `input_role` token 与 `(role,path)` 集。 | 28/28/54 的实际成员和计数能复算，但稿内三个 hash不能独立重建。GA100 的 `38→40`、`37→39` 算术正确，v5.0 pair 也没有误计为新增量；然而 40/39 的 exact role/path set 仍不唯一，不能成为后续 immutable input guard。 |

`R04-B01` 至 `R04-B04` 中任一项都足以触发本任务的 reject 门；`R04-B05` 还使 selection no-write guard 与 GA100 后续 active input set不能按同一规则复算。

## v7.1 路径、回滚和 GA100 边界

按 v2 明写的边，v5.0 policy/approval 和 v7 manifest/approval都是 no-write inputs。v5.1 policy、其 approval、amendment、其 approval、authorization 和 transaction manifest保持单向依赖；amendment 不绑定下游 authorization，approval 也不回填被批准 artifact。我没有在 A0 到 A19 拓扑中发现 hash 环，active resolver 对“完整 amendment + approval”“两者均不存在且 core 等于 v7”“半应用或多候选”三个状态的处理也只有一个结果。

这一部分只能说明版本切换逻辑方向成立，不能使 artifact bytes自动唯一。尤其第 710 行所说“最后发布 amendment approval”必须建立在一份已独立批准、身份关系合法且 byte-exact 的 approval 上；`R04-B04` 未修复前，activation marker 本身仍不合格。

回滚的类别划分没有算术错误：13 张 table image 恢复 v7 原字节，19 个 present→present payload 恢复 v7 原字节，6 个新 stable artifact执行 post-hash guarded delete。问题仍在前述 complete planned post未唯一构造；没有唯一 post hash，就不能唯一产生 13 张 post image、19 个 payload snapshot、6 个 delete-created guard、authorization、mirror和 rollback manifest。

GA100 的数量变化与 v7 的 37/38 双分支在算术上相容：用 v5.1 policy/approval 替换 v5.0 pair为净零，再加入 amendment/approval pair为净增 2，所以 no-mapping-change 为 39，mapping-override 为 40。v2 没有改 v7 的 stable `34/376/141/77/564`、11/24/35、96 input 或 v5.0 bytes，也没有把 2020-05-14 候选误升为 fact。当前缺口是新增 pair 的 exact role/path，而不是计数。

## 重新送审条件

下一版不需要推翻已经通过的语义和集合身份。它需要先把 `CompletePlannedPost` 写成唯一函数：为 4 个 run、28 个 member 以及所有 update 固定完整行或可执行的逐 cell constructor；为 19 个 present→present payload提供 exact anchors/replacements或完整候选 bytes；为 16 个 fixture 和 48 个 runtime result固定完整 row schema、ID、顺序与 manifest constructor；为每份 approval固定身份/date/notes并强制 approver 与 preparer/reviewer分离；补齐 28/28/54 guard 和 GA100 39/40 role/path set的 canonical contract。完成后，才能重新复算 81/25 exact diff、13 image、38 rollback、authorization 与 isolated mirror。

## 工具与边界

审计只使用本地固定文件、CSV 解析和字节级 hash，不需要网络，也没有运行未来实施期的 Windows 三道 hard gate。发生过四次非阻断的 model/operator mistake：两次只读命令使用了错误的相对路径，两次在非 Git 目录执行状态检查；命令均未写入文件，修正路径后完成复核。另有一次非阻断的 tool/runtime limitation：系统没有 `tac`，随后用 `tail -r` 完成逆序复读。没有用户中断、sandbox denial、approval failure、approval-review connection failure或 remote service error。

本报告的 `reject` 只表示 v2 尚不能进入实施，不表示 v7 已 apply，也不把任何候选日期升级为正式事实。
