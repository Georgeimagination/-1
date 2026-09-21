# GA100 atomic v3 实施蓝图独立复核

状态：`reject`

复核日期：2026-08-21。复核对象是 `r1_ga100_40_atomic_v3_implementation_plan.md`，实测 312 行，SHA-256 为 `5b06e7a6eec3c8c3d9e5642ca50864939e18cd7953b3bcd2884fe08efb6d8518`。本轮只新增本报告，没有修改 r40、正式 CSV、v2/staging、合同、来源快照、资料卡或进度文件。

## 裁决

r40 不能按当前文本作为 atomic v3 的实施蓝图接收，更不能据此生成 staging。主要对象边界、来源边界、38-input mapping、H0 至 H24 的依赖方向和 card 受管方式大体正确，但仍有四个会让 planned post 不唯一或让验收受预定答案驱动的 blocker：把 `53 value / 49 not_found / 6 not_applicable` 固定成通过门；没有给出完整、可执行且可双向 set-equal 的 expected-pair/factor builder；没有把 v2 语义 seed 与正式 PK 分配规则机械分开；release-date migration 的当前独立裁决已经是 `reject`，r40 仍把它写成 `pending_design_review`。

这里的 `reject` 针对实施蓝图，不表示 r40 已经尝试或生成了 staging。即使修复后重新获得 `accept`，其含义也只能是“蓝图可以进入实现”，不能继承为 source-pool、contract migration、release migration、GA100 package 或 Windows 发布门已经通过。

## 四个 blocker

| ID | 独立发现 | 为什么阻断 | 精确修复门 |
|---|---|---|---|
| `R41-B01` | r40 第 158、168、243、295 行把 9×12 的 terminal status 固定为 `53/49/6`，并把该分布放进 H10 前检查和最终 coverage 门。 | 108 个 exact key 与六个 integer/logical N/A 有合同依据；53 个 value 和 49 个 not_found 只是旧来源阅读在某个 corpus 上的结果。把结果计数预先写成 gate，会在新证据改变某个 cell 时迫使 builder 维持旧总数，也可能用另一格的错误状态补齐分布。 | 保留 `Expected108 == 9 paths × 12 fields` 和 exact 六格 N/A set-equal；删除所有要求 value/not_found 必须为 53/49 的通过条件。H7 应逐 key 由 direct assertion、approved formula 或 endpoint-aware search 生成状态，最后只把实际分布作为诊断输出。若仍想保存 `53/49/6`，只能作为带 corpus/version/hash 的历史 regression observation，不能决定验收。 |
| `R41-B02` | r40 只给出 `I-reachability`、H4/H5 名称、九条 path、十二个字段的自然语言和若干 forced pair，没有冻结完整 expected-pair/factor constructor、selector precedence、exact 输出集合或 golden fixture。 | “全部 contract-generated 未闭合 pair”不是可执行集合。它无法独立证明所有 reachable target/field pair、exclude decision 和 factor obligation 都被消费，也无法与 H6/H7、authorization 双向 set-equal。r35 已因用手写 25 行代替 builder 拒收前案；本稿不能用函数名称代替 builder 本身。 | 修订版必须给出一个确定性 builder 规范和可复现 fixture：输入为 H4 reachable inventory、v7 field/target-kind/predicate/forced/factor policy；输出为 exact `(target_id, field_id, decision, predicate_or_reason)` 与 factor-obligation key 集。九条 path和十二个 exact field ID、六个 benchmark、Ampere 三对、GA100 三对以及其余 reachable pair 都要从同一算法产生。候选、terminal、coverage、authorization 分别与该输出 set-equal，并提供缺项、额外项、重复项、错 target、错 predicate 的失败用例。 |
| `R41-B03` | r40 第 104、235 行说只复用语义、不复制旧 PK，但第 106 至 113 行和 salvage 表仍直接列出大量 v2 主键；文本没有定义哪些 key 是 contract-reserved、哪些已在正式 H0 存在、哪些必须 fresh allocate，也没有 v2 seed 到 v3 candidate 的完整 crosswalk、expected-absent 或 collision gate。 | 在没有机械分区时，实现者仍可把“重新绑定”解释为沿用旧 component/link/capability/condition/fact/source PK。r18 的 `retain_as_is` 明说 PK 可作种子，但本次验收规则不允许把旧 PK 当作可复用资产。只承诺“不复制旧行”不能排除 PK 碰撞、误 update 或旧引用链复活。 | H1 前冻结四个互斥集合：`ExistingFormalKeys`、`ContractReservedNewKeys`、`FreshAllocatedKeys`、`ForbiddenLegacyKeys`。`OBJ-NVIDIA-GA100-DIE` 和 `MAPEV-SCOPE-0001-0002` 只能因 v7/scope 合同保留 exact ID，并要求 H0 expected-absent；既有 Ampere 正式行只能以 exact preimage hash 作 no-write/授权 update；其他新行须由确定性 allocator 产生并给出 old-seed→new-key crosswalk。全部旧 requirement/search/result/selection/operation PK、12 个假 entity PK及其从属 key进入 forbidden set。引用重写、PK 唯一、H0 absence/presence 与 H10 postimage必须逐表 set-equal。 |
| `R41-B04` | r40 第 9、17 行把 release-date migration 写成仍在独立审查或 `pending_design_review`。当前 `r1_release_date_02_semantic_migration_independent_review.md` 已明确 `reject`。 | 被拒设计没有唯一 active reference closure、append-only selection run、policy/approval 路径、Phase A/B payload 集和 fingerprint 方案，不能成为 `I-release`，也不能被假定将按现稿执行。 | 当前状态改为 `rejected_design / hard blocker`。H0 只能绑定一份后续修订设计及其独立 `accept`，再绑定实际 migration transaction、coverage/authorization approval 和独立 postimage 审查的 exact path/hash。现有 r01/r02 只能作为被拒历史输入。解除这些门之前不得冻结 GA100 H0，更不得预填 GA100 release value。 |

## 9×12 与六个 benchmark 的独立复算

v2 的 `path_by_field_closure.csv` 机械解析为 108 个唯一 `(precision_path_id, field_id)`，由 9 个 path 与 12 个 field 的笛卡尔积构成。九个 path 与 r40 第 146 至 156 行逐项相同；十二个 field 的 exact ID 是 `FIELD-NUM-OPERAND-A`、`FIELD-NUM-OPERAND-B`、`FIELD-NUM-ACCUMULATION`、`FIELD-NUM-PRODUCT`、`FIELD-NUM-PHYSICAL-ACCUM`、`FIELD-NUM-OUTPUT`、`FIELD-NUM-ROUNDING`、`FIELD-NUM-SCALING-MODE`、`FIELD-NUM-SCALING-GRANULARITY`、`FIELD-NUM-SATURATION`、`FIELD-NUM-SUBNORMAL` 和 `FIELD-NUM-SPARSITY`。因此“9×12=108”的形状成立，但旧 closure status 与 requirement PK 不具继承资格。

六个强制 N/A 也有明确政策基础，exact set 为 INT8、INT4、Binary 三条 path 分别乘 `FIELD-NUM-ROUNDING`、`FIELD-NUM-SUBNORMAL`。r28 从 r25 的 `53 value + 55 not_found` 中把这六格按 integer/logical predicate 改为 N/A，得到 `53/49/6`；r38/R15 后续冻结的是 108 个 mandatory key 和这六格 N/A，而不是 53 个 value 与 49 个 not_found 的不可变配额。更重要的是，r28 对 r25 的总体裁决是 `reject`，r25 的若干 endpoint 当时只存在于被拒 v2 staging；当前正式 source ingestion 仍未完成。因此 53/49 可以作为一次重算结果参考，不能升级成权威分布门。B01 的修复不改变 108 和 exact 六格 N/A，只取消对另外 102 格终态数量的预置。

r40 第 176 至 183 行的 benchmark code block 已按当前原字节独立解析：共有 6 行、6 个唯一 exact pair，`FIELD-BENCH-ENERGY-PER-TOKEN` 只出现一次，没有重复。六个 field ID 也都逐项存在于当前 `fields.csv`，并且都是 approved object-level benchmark field。顺序和内容正确：latency、throughput、power、energy-per-token、tokens-per-joule、utilization。

r37/r39 对这六个 pair 的当前内容裁决是 `include/not_found`，并给出 Matrix、MLCommons 固定 commit、HPEC/RAND、official-web 等实际 endpoint 的 wrong-subject/metric/scope 边界。r40 也正确要求先建立 H1 search/result，再由 H7 形成 `no_reliable_result`，到 H10 才可能闭合。这里通过的是六个 exact ID、forced include 政策和当前候选方向，不是六条正式 `not_found` 已经发布；如果 H1 后来出现 correct-subject direct measurement，H7 必须允许相应 pair 转为 value，不能为了维持固定分布拒绝新证据。

## v2、对象边界与来源边界

我重新解析了 r14 v2。30 个 CSV 中，核心数量为 1 object、1 relation、11 component、2 link、3 memory level、5 precision path、15 capability、1 topology、14 condition、89 fact、109 assertion、272 requirement、132 search、250 result 和 1,021 operation；operation 分布为 942 insert、76 update、3 delete。12 个假 entity 确为 11 个 `CAP-R1-GA100-GAP-*` 加 `TOPO-R1-GA100-NVLINK-GAP`，从属链为 20 requirement、17 search、34 result。r40 第 248 至 250 行要求完整排除这 12 个实体及从属链，并把其余 115 search、216 result全部按 actual endpoint 重建；第 246、269 行又明确拒绝旧 1,021 operation。删除、重搜和 transaction 重建方向通过，剩余问题是 B03 所述 PK 规则没有机器化。

r40 对 full 128-SM GA100 design、108-SM A100 enabled product、A100 module、DGX system 和 Ampere architecture 的分层成立。Matrix Guide 的 alignment、small-GEMM tile trade-off 与 tile quantization只进入带 A100 carrier/CUDA/cuBLAS/datatype/tile 条件的 Tensor/GEMM component fact；108-SM wave 示例保留为 wrong-enabled-scale rejected assertion。MLCommons 的 `3560.73 samples/s` 与 `0.001551870 s` 只用于 DGX A100 system wrong-subject closure；SEC 10-Q 只正面支持 A100/H100 integrated circuit/system 的市场准入，不能改成 GA100 die value。Ampere architecture 三个 identity pair保留在 architecture target，GA100 die 的同名三对另做 search。这里没有发现越界 positive fact。

CUDA/PTX 被限制在 architecture/software-visible ISA 语义，不能推出 SASS、array、accumulator、RTL 或实测可运行性；MIG 不再承担 GA100 identity，只有 VIRT requirement 经 H8 证明不可替代时才能进入 selected set；RAS 则拆开 on-die scope、external HBM、driver、InfoROM、reset/service 条件。这三组边界与 r20/r21/r24、r28、r37/r39 一致。MIG610 的旧 identity assertion/member、模板搜索和旧 selection run均未被 r40保留。

## 38-input、DAG、selection 与 card

scope mapping 部分通过。v7 postimage 的 seq1 是 `pending_formal_object_create`，所以 GA100 必须使用 `CommonChipBase34 + mapping base/post snapshots + AuthorizationTwo = 38` 的 override 分支。r40 保留 seq1 原字节，并只 append `MAPEV-SCOPE-0001-0002`；object、identity/card identity、mapping 与 coverage 同一事务，post mapping 为 50 行。它没有把 38 误写成 operation 数，也没有在 live 已映射后重选 37-input 分支。

H0 至 H24 的依赖方向与 r38/R15 一致：H4 reachability先于H5 expected builder，H7 terminal closure先于H8 selection/reverse-removal，H9 coverage先于H10 planned post，H11 exact delta先于H15 authorization，H17 materialization先于H18 isolated mirror。r40 没有把旧 1,021 operation当作上游，也没有让 approval 回填被批准对象。B02 说的是 H5 的构造内容不完整，不是当前层级顺序发现了环。

H8 不预设最小来源数量，并要求逐 family 反向移除后重算 value、formula input、endpoint result、not-found range、role obligation 与 six-benchmark closure。MLCommons、SEC 可以因负证据职责暂时保留；MIG Guide 不能凭 identity role入选。source selection 与 reverse-removal 的政策方向通过，实际 run 尚未执行。

card 的处理符合本轮强制边界。它必须在 H9 的 field coverage、selection 与 factor closure完成后，由 planned formal rows 确定性渲染，作为受管 payload 进入 H10；随后被 H11 delta、H15 authorization、H17 payload/file-input inventory 与 H18 isolated mirror共同绑定。apply 后只允许重渲染并做 byte equality，不允许补写。H13 仍使用冻结的 58-key coverage manifest schema，没有新增 card payload hash key。这里没有发现未授权 payload 或 58-key schema扩张。

## 前置条件与执行边界

source-pool-113 v4 独立复核只接受了候选 12 步推广合同，正式推广和 Windows transcript 仍未发生；R15 只接受 contract v7 设计，contract transaction也尚未实施；r29 只接受 official-web v2 隔离快照质量，r39 只接受 r37 作为来源裁决输入，正式 family/version/endpoint/search/result/selection均未入库。r40 把这些状态列为 blocking/not-ingested 并禁止提前生成 staging，这一 fail-closed 边界正确。release migration 则须按 B04 更新为已拒设计。

当前环境找不到 `pwsh`、`powershell` 或 `powershell.exe`，所以 Windows hard gate 保持 `not_run`。这属于 tool/runtime limitation，不是 gate FAIL、sandbox denial、审批失败或模型能力限制。主线目录也不是可用 Git repository；`git status` 返回 `not a git repository`，属于 repository-state 前置不适用，本轮改用精确文件路径、行数、SHA-256 和 CSV 集合复算确认写入边界。

## 重新送审条件

修订版只有在 B01 至 B04 全部关闭后才值得重新送审。最关键的验收关系应改成：完整 expected key set由确定性 builder产生；terminal key set与其双向相等；六个 N/A 与 exact policy set相等；其余 status由逐 key证据决定；所有新/既有/合同保留/禁止 PK 均有唯一分区和 preimage/absence guard；release 输入来自新设计的独立 accept及实际 migration postimage。任何固定 value/not_found 配额、旧 PK 复用捷径、手写子集替代 builder、越界对象或 H15 外 payload，都继续返回 `reject`。

## 文本与工具复核

本报告按工程审计文档处理。定稿后使用 `report-humanizer` 对本文件单独扫描，并从本节开始，依次逆读前置条件、card/DAG、对象与来源边界、9×12/benchmark、四个 blocker和开头裁决；重点核对了 `53/49/6`、六个 benchmark exact ID、`108/12/9`、`1,021/942/76/3`、`12/20/17/34`、38-input seq2、58-key schema 和 release `reject` 状态。

只读命令的长输出曾触发一次 tool/runtime output-limit 截断，随后按文件和行段重新读取，未缩减必读范围。没有发生用户中断、sandbox denial、user/auto-review approval denial、approval-review connection failure、remote service error或 model/operator mistake。
