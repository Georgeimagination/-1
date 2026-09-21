# GA100 field 与 benchmark 缺口闭合独立复核

状态：`reject`

复核日期：2026-08-21。复核对象是 `r1_ga100_32_field_benchmark_gap_closure.md`（下文简称 r32）。本轮没有修改 r32、正式 32 张数据表、来源注册表、staging、合同、资料卡或进度文件；唯一项目写入是本报告。

## 裁决

r32 不能作为 25 个 requirement 的发布性闭合输入。它的文内算术没有错：15 个漏失 field 被写成 4 `value`、10 `not_found`、1 `not_applicable`，六个 benchmark 全部写成 `not_found`，日期、状态和价格四项又是 1 `value`、3 `not_found`，合计确为 5 `value`、19 `not_found`、1 `not_applicable`。问题在于，这个 25 只是人工列出的 25 行，不是合同 builder 生成并 set-equal 的 expected field-target pair 集。

r28 所说的“15 个”是 15 个不同 `field_id`，不是 15 个 obligation。r32 把每个 field 选一个 target 后直接当作 requirement 总数，漏掉了同一 field 在其他 reachable target 上的候选。最明确的反例是白皮书 p.38 直接写明 NVIDIA Ampere architecture targets strong scaling；因此 `OBJ-NVIDIA-AMPERE-ARCH / FIELD-ID-DESIGN-OBJECTIVE` 至少是一条需要独立裁决的 architecture pair，并且现有内容足以支持 `value`。r32 只保留 GA100 die 上的 `not_found`，一边承认 architecture 可建 direct fact，一边又把它排除在“25 项全部闭合”的计数之外。`FIELD-ID-TARGET-USE-POSITIONING` 和 `FIELD-ID-VENDOR-POSITIONING` 在 architecture target 上也必须由 builder 明示为 include 或 exclude，不能因 die pair 已写结果而消失。

此外，r32 用 `A100-BENCH` 改变六个 benchmark 的状态，用 `TRADE` 改变 market-access 的状态，却把两者都留在“online-only、未落快照”，又说可以等 reverse removal 后再决定是否入库。这条顺序不可执行：如果删除 `A100-BENCH`，r22 的结论仍是“完成其他计划来源后才可发布 `not_found`”；如果删除 `TRADE`，r28 关于 whitepaper/ISSCC 零命中不足以关闭 market-access 的 blocker 也没有被新证据解除。它们要么先固定并进入逐 endpoint search closure，要么不得计入状态变化。

因此，本报告拒收的是 r32 的“25 项已无来源缺口”和“没有 pending”两项总裁决。白皮书支持的数据流值、CUDA 文档支持的 compiler/runtime 值、部分 exact-die `not_found` 方向，以及 HPEC 的窄 test-carrier 规则仍可作为修订输入。

## 正式基线与来源状态

本轮直接解析正式表，得到 141 个 field、78 个 object、27 个 object relation、270 个 component、93 个 source 和 153 个 endpoint。`OBJ-NVIDIA-AMPERE-ARCH` 与 `COMP-M2NA-AMPERE-*` 已在正式表；`OBJ-NVIDIA-GA100-DIE`、`COMP-R1-GA100-*` 及 `GA100 implements Ampere` relation 均不存在。r32 对这层 preimage 的描述正确，但这也意味着所有 GA100 die/component 行目前只能是拟议 postimage，不能称为已发布 requirement closure。

正式来源注册表中，本轮相关来源只有 `SRC-M2NA-NVIDIA-AMPERE-WP-2020` 及其 local/remote endpoint。ISSCC、CUDA Programming Guide 11.0、PTX 7.0/7.2、HPEC arXiv v1、random-access arXiv v1，以及 official-web v2 的候选仍未成为正式 source/version/actual endpoint。Ampere whitepaper 虽已参加 `SELRUN-M2NA-ARCH-20260812`，该运行面向既有 M2 architecture 事实；新加 GA100 fact、missing-data result 或 `coverage_obligation_evidence` 职责后必须重跑，不能沿用旧运行证明新闭合。

official-web v2 的独立验收结果仍是 29 个 manifest 条目、27 个成功、2 个无 payload 拒绝项，成功 payload 为 22 HTML 加 5 PDF，共 15,817,628 bytes，归入 19 个 family。r29 的 `accept` 只接受隔离 staging 的字节、身份和 family map，不等于正式来源选择。`A100-BENCH` 与 `TRADE` 又不在这 29 项中；它们目前连 staging snapshot 都没有。

## 25 行逐项复核

下表中的“内容通过”只表示 target、原文与字段语义可以作为后续写入输入，不表示当前正式表已经满足 endpoint、selection、reverse-removal 和 approval 门。“条件通过”表示 r32 的状态方向可以保留，但必须补齐 builder 与逐来源发布链。“拒收”表示当前建议状态或值本身需要改变。

| # | exact target / field | r32 建议 | 独立复核 | 最小处理 |
|---:|---|---|---|---|
| 1 | `COMP-M2NA-AMPERE-TENSOR / FIELD-COMP-DATAFLOW-RESIDENCY` | `value` | 内容通过 | 只保留 32-thread warp operand sharing、降低 RF bandwidth 和冗余 SMEM→RF load；不要并入 `cp.async` feeding path。新增 assertion 后重跑 selection。 |
| 2 | `COMP-R1-GA100-TENSOR / FIELD-COMP-UTILIZATION-LIMIT` | `value` | 拒收 | p.38 直接支持的是 Ampere strong-scaling design objective，并以 A100 Tensor Core 说明 feeding challenge；它没有直接报告 GA100 Tensor component 的利用率下降或字段定义所列的小矩阵、窄矩阵、小 batch、不规则形状限制。carrier identity bridge 不能补足字段语义。先改回 `pending_verification`；若保留值，必须找到直接 limitation 句或条件完整的测量。 |
| 3 | `OBJ-NVIDIA-GA100-DIE / FIELD-DER-CAPACITY-COMPUTE` | `not_found` | 条件通过 | full-design compute 与 A100 external-HBM capacity 不同对象。补 actual-endpoint search rows 后可关闭，不建空 DAG。 |
| 4 | `OBJ-NVIDIA-GA100-DIE / FIELD-DER-COMPUTE-BW-SPEC` | `not_found` | 条件通过 | 缺同对象、同 precision 的 full-design peak/clock/nameplate bandwidth 输入；A100 108-SM 与 HBM 数值不得混入。 |
| 5 | `OBJ-NVIDIA-GA100-DIE / FIELD-DER-COMPUTE-BW-SUSTAINED` | `not_found` | 条件通过 | HPEC cycle 和 A100 random-access GB/s 都不是 full-design sustained-bandwidth input。 |
| 6 | `OBJ-NVIDIA-GA100-DIE / FIELD-DER-INTERCONNECT-COMPUTE` | `not_found` | 条件通过 | NVLink interface 一侧有线索，但 compatible full-design compute 输入未闭合。 |
| 7 | `OBJ-NVIDIA-GA100-DIE / FIELD-DER-MOVE-MATRIX` | `not_found` | 条件通过 | RF/SMEM access-count illustration、cycle latency 和异常单位 Table III 均不能组成同 scope movement/matrix ratio。 |
| 8 | `OBJ-NVIDIA-GA100-DIE / FIELD-ID-DEPLOYMENT` | `not_found` | 条件通过 | 现有命中均为 A100/DGX/HGX/cloud；需要把每个 wrong-subject source 写成 actual-endpoint `checked_no_support`。 |
| 9 | `OBJ-NVIDIA-GA100-DIE / FIELD-ID-DESIGN-OBJECTIVE` | `not_found` | die 行条件通过，但集合拒收 | die exact-target 可以在充分检索后为 `not_found`；同时必须新增或显式裁决 `OBJ-NVIDIA-AMPERE-ARCH / FIELD-ID-DESIGN-OBJECTIVE`，白皮书 p.38 对该 architecture pair 是 direct `value`。 |
| 10 | `OBJ-NVIDIA-GA100-DIE / FIELD-ID-MARKET-ACCESS-CONSTRAINT` | `not_found` | 拒收当前闭合 | r28 的缺口只靠 online-only `TRADE` 才有新增覆盖；两份 SEC filing 未快照、未注册、未形成 endpoint/locator result。固定它们或同等官方贸易来源后再裁。 |
| 11 | `OBJ-NVIDIA-GA100-DIE / FIELD-ID-TARGET-USE-POSITIONING` | `not_found` | die 行条件通过，但集合未闭合 | A100 product wording 不能逆投 die；builder 仍须单列 Ampere architecture pair，并对直接 architecture wording 作 include/value、include/not_found 或经审核的 exclude。 |
| 12 | `OBJ-NVIDIA-GA100-DIE / FIELD-ID-VENDOR-POSITIONING` | `not_found` | die 行条件通过，但集合未闭合 | `GA100 powers A100` 是 identity，不是 positioning；同样不能省略 architecture pair。 |
| 13 | `OBJ-NVIDIA-GA100-DIE / FIELD-PHY-DIE-COUNT` | `not_applicable` | 拒收当前闭合 | 语义方向合理，但 `target_is_a_die_not_a_containing_package` 只是自由文本 reason，不是已批准的 policy predicate。合同迁移前应保持 pending；迁移时补 exact structural predicate、field rule 和独立 proof。 |
| 14 | `OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-COMPILER` | `value` | 内容通过 | `nvcc`、Toolkit 11.0.3、PTX/cubin、`sm_80` 的边界正确；CUDA-PG/PTX actual endpoint、assertion 和新 selection 尚未完成。 |
| 15 | `OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-RUNTIME` | `value` | 内容通过 | `CUDA Runtime (cudart), CUDA Toolkit 11.0.3` 的主体与版本正确；链接形态不拆值，发布前置同上。 |
| 16 | `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-LATENCY` | `not_found` | 拒收当前闭合 | r22 只完成 HPEC/RAND 两源，r32 新增的 A100 BERT/MIG 与 MLCommons 未固定；先按 benchmark policy 选择 include-search 或 no-reachable-target 路径。 |
| 17 | `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-THROUGHPUT` | `not_found` | 拒收当前闭合 | HPEC Table III 单位/operation rule 不闭合，RAND 和 MLCommons 是 product/system；未固定 `A100-BENCH` 前不能发布 absence。 |
| 18 | `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-POWER` | `not_found` | 拒收当前闭合 | TDP 不是 workload power，MLPerf Power 又是 system scope；必须固定所查结果及 scope，或经 policy 排除 bare-die pair。 |
| 19 | `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-ENERGY-PER-TOKEN` | `not_found` | 拒收当前闭合 | 现有语料没有 token workload 与 die-only energy，但计划来源尚未形成完整 actual-endpoint closure。 |
| 20 | `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-TOKENS-PER-JOULE` | `not_found` | 拒收当前闭合 | 不得由 TDP、samples/s 或倒数派生；发布前置与上一项相同。 |
| 21 | `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-UTILIZATION` | `not_found` | 拒收当前闭合 | strong-scaling motivation、`Measured-theoretical` 和 product throughput ratio 均非项目定义的 MFU/HFU/MBU/efficiency；`A100-BENCH` 未固定。 |
| 22 | `OBJ-NVIDIA-GA100-DIE / FIELD-ID-RELEASE-DATE` | `value = 2020-05-14` | 拒收当前值定义 | 正式 field 只写“首次发布日期；具体对象日期，不用架构预告代替”，没有把 source publication date 定义成 object release date。r23 已明确给出二选一，r32 不能在单行内私设 `first official publication directly naming GA100`。先统一全库语义再定 value/not_found。 |
| 23 | `OBJ-NVIDIA-GA100-DIE / FIELD-ID-AVAILABILITY-DATE` | `not_found` | 条件通过 | A100 production/shipping 不等于 standalone GA100 availability；NEWS/BLOG/PB 的 actual endpoint/result 完成后可关闭。 |
| 24 | `OBJ-NVIDIA-GA100-DIE / FIELD-ID-STATUS` | `not_found` | 条件通过 | A100 vGPU full support、Infra compatibility 和当前网页存在均不证明 die lifecycle；official-web v2 正式入库后可形成 wrong-subject closure。 |
| 25 | `OBJ-NVIDIA-GA100-DIE / FIELD-ECON-PUBLISHED-PRICE` | `not_found` | 条件通过 | standalone die price 与 card/system/cloud price 已正确分开；需把 r23 实际查过的产品页、brief、release 和查询范围完整转成 endpoint-aware result，而不是只保留摘要。 |

以上复核不会给出一个替代的固定“25 项状态分布”。在 builder 输出完成前，任何固定分布都会再次把 field ID 数误当作 expected pair 数。可以确认的是，dataflow、compiler、runtime 这三条正向内容的来源语义成立；utilization-limit 与 release-date 不能按 r32 原值直接进入事实层；die-count 还缺 policy；六个 benchmark 和 market-access 还缺发布性负证据链。

## `not_found` 是否已经足以发布

答案是否定的。合同要求每条新 `not_found` 至少有一条 `no_reliable_result` search log，并要求每个实际检索 source 都有同源 actual endpoint、非空 locator，以及 `checked_no_support` 或不计覆盖的 `duplicate` result。wrong subject、wrong scope 和 wrong semantics 可以写在 `checked_no_support.notes`，但不能用这些自然语言标签替代受控 result relation。

r32 的来源简称表仍把多个 source/version/endpoint 合在一个别名下。例如 `PB` 是两份 PDF，`PTX` 是两个 revision，`A100-BENCH` 又把一个 NVIDIA blog 和一个 MLCommons repository 合为一项。逐 field 表也只列 alias 和章节摘要，不能机械生成“每个实际检索 source 恰有一条 result”的集合。ISSCC、CUDA-PG、PTX、HPEC、RAND 和 official-web 候选尚无正式 endpoint；`A100-BENCH` 与 `TRADE` 连固定 payload 都没有。因此当前 19 条 `not_found` 都不是发布完成态，区别只在于部分行已有足够内容、部分行还缺真正的检索证据。

online-only 来源不能等 reverse removal 之后再决定是否抓取。reverse removal 的覆盖宇宙本来就要包含支撑 missing-data closure 的 search/result/actual endpoint；没有快照和 source row 的候选无法先参加这次计算。可执行顺序只能是：先固定并注册候选，生成逐 endpoint result；在全体 requirement 稳定后运行 reverse removal；被证明冗余的来源再从最终 selected set 移除，但其历史 screening/search 记录仍可审计。

## benchmark 是 `not_found` 还是 no-reachable-subject

当前 `fields.csv` 把六个 benchmark field 的 `allowed_requirement_target_kinds` 都设为 `object`。一旦 chip transaction 正式创建 `OBJ-NVIDIA-GA100-DIE` 并使其 reachable，builder 就会生成六个 exact field-target pair。现有合同没有 bare-die benchmark structural N/A predicate，也没有一个可以跳过 builder candidate 的自由文本 `no-reachable-subject` 状态。因此，r32 选择 `not_found` 并非天然非法，但只有在六条 search closure 都完成时才成立。

真正需要 policy 先回答的是：full GA100 design 从未作为公开的完整 128-SM workload test carrier 时，这六个 pair 是否应当 include。若答案是 include，就必须保留 requirement 并继续找 correct-subject/full-design measurement；A100 108-SM product 和 system result 只能作为 `checked_no_support`。若答案是 exclude，则仍要让 builder 生成 candidate，再用批准的 subtype/scope reason、独立 exclusion review 和 zero-included-field 后续门处理；不能把“没找到 bare-die benchmark”同时写成 no-reachable target 和 `not_found`。r32 目前跳过了这个二选一。

## release date、die count 与 utilization-limit

release date 必须先在全库层面选定一种语义。若统一定义为“厂商首次正式公开并直接命名具体对象的日期”，BLOG 的 2020-05-14 可以成为 GA100 value，但 `fields.csv`、字段字典、模板和既有对象都要按同一规则迁移。若字段仍表示对象的正式发布/产品 launch，则 BLOG 只证明 source publication 和 GA100 direct naming，GA100 die requirement 应继续 `not_found` 或 `pending_verification`。不能把 A100 shipping 混入任一解释。

die count 的最小可执行 predicate 应是 policy 中一个 `predicate_scope=structural_na` 的受控对象，至少以当前 candidate 的 `数据/objects.csv.object_type equals die` 为 all-of clause；`FIELD-PHY-DIE-COUNT` 的 field rule 同时设置 `allow_structural_na=true` 并引用该 predicate。若 policy 还要求 proof，则另建 `supports_not_applicable` evidence，绑定实际 endpoint 和独立 reviewer。自由文本 reason 和 die photo 均不能替代这组条款。

utilization-limit 的桥接分两层。白皮书 p.19 能把 A100 implementation 与 GA100 区分并关联，p.38 又直接提到 A100 Tensor Core；这足以说明 carrier 身份，却没有直接陈述“该 GA100 Tensor component 在某尺寸或形状下利用率受限”。p.38 最稳妥的现成落点是 `OBJ-NVIDIA-AMPERE-ARCH / FIELD-ID-DESIGN-OBJECTIVE`。如要关闭 `FIELD-COMP-UTILIZATION-LIMIT`，还需直接限制语句或可复查 measurement，且要保留 matrix size、shape、batch、datatype、software 和 product configuration 条件。

## HPEC bridge 与 cycle 候选

r32 对 HPEC 的窄桥接方向基本符合 r28：`AI100` 原文和 Table V 的 `Amepere A100` 应原样保留，书目身份只能写 arXiv v1，124-SM background 继续拒绝，global-memory 290 cycles 和 Table III throughput 不能下放。只有能由 opcode/SASS mapping、cache operator 或 pointer-chasing path 隔离到 on-die component 的 cycle measurement，才可在 A100 product-family、SKU/form factor unknown、software/clock unknown 等条件下归属 GA100 component。

这只是未来 cycle fact 的建模许可，不是当前 25 项的正向闭合。HPEC actual endpoint、GA100 target、`FIELD-COMP-INSTRUCTION-LATENCY` 和 memory-latency cycle 合同都未正式完成。正式写入还应建立可审计的 carrier identity assertion；不能只靠报告中的一句“结合标题和正文”绕过 source/condition row。

## source endpoint、selection 与 reverse-removal 前置

最小顺序如下：

1. 先运行独立 expected-pair builder。25 只能保留为 r32 的人工检查行数，不能写入 coverage manifest；builder 输出必须覆盖所有 reachable target，包括 Ampere architecture 的 identity pair。
2. 再固定 source family、source version 和 actual endpoint。r14 与 official-web v2 的已有 payload 可复制到 stable target，并复算 hash；`A100-BENCH` 和 `TRADE` 若继续承担 closure，必须先新增快照。MLCommons 应固定 commit 和具体 system/result 文件，不接受 repository root 作为唯一 locator。
3. 逐 exact pair 生成 fact/assertion 或 search log/result。每个实际查过的 source/version/endpoint 单独成 result，不把两个 PDF、两个 revision 或 blog+repo 合在一行。
4. 只有 value、N/A policy、not-found search、derived input absence 和 candidate include/exclude 都稳定后，才建立 GA100 object-scope selection run。所有用于 `not_found` 的必要来源以 `coverage_obligation_evidence` 参加；HPEC 若保留 cycle measurement，再加 `independent_validation`。
5. 最后运行 reverse removal，并以删除任一 family 后重新计算完整 closure 的结果决定成员。现有 M2NA run 和 r32 的来源简称都不能替代这一步。

## 最小修复条款

修订版至少需要加入以下硬条款，才能重新送审：

- 计数条款：independent builder 先生成 expected field-target pair 全集，coverage candidate 必须与全集 set-equal；`closure_count` 只统计其中的 include candidate，不得用 distinct field ID 数或手写表行数代替。必须显式加入 `OBJ-NVIDIA-AMPERE-ARCH / FIELD-ID-DESIGN-OBJECTIVE`，并列出 architecture target 的 target-use/vendor-positioning candidate 决策。
- 状态条款：utilization-limit 退回 pending，直至 direct limitation 或条件完整 measurement；release date 在全库语义批准前退回 pending；die count 在 structural predicate 批准前退回 pending。
- 负证据条款：`A100-BENCH` 和 `TRADE` 未固定时不得用于把 pending 改成 `not_found`。若删除它们，benchmark 与 market-access 的状态必须按剩余 corpus 重算，不能保持原结论不变。
- benchmark 条款：由 policy 明确选择 include+search 或 builder candidate exclude+independent review；禁止用“no reachable subject”作为未登记的第三种 requirement status。
- 来源条款：每个 value、search result 和 requirement evidence 绑定同源 actual endpoint 与 canonical locator；staging snapshot ID 不冒充 endpoint ID，online URL 不冒充 snapshot。
- selection 条款：GA100 facts/results 完成后新建 object-scope selection run，再做 reverse removal；不得借用旧 M2NA architecture run，也不得先按预期结论删候选来源。
- HPEC 条款：carrier bridge 只准进入 exact on-die cycle measurement；124 SM、global memory、aggregate throughput、product HBM/MIG/SM configuration 继续拒绝。bridge 本身必须有 source-backed identity/condition row。

## 真正的来源缺口

需要区分“内容已经找到但尚未入库”和“公开内容本身仍缺”。dataflow、compiler/runtime、Ampere strong-scaling objective 已有可接收内容；official-web v2、CUDA/PTX、HPEC/RAND 的多数问题是 endpoint 与 selection 生命周期，不是再找论文的问题。die-count 是 policy 缺口，release date 首先是定义缺口。

当前仍有三类真实来源缺口。第一，r32 没有找到直接的 GA100 Tensor component utilization-limit 语句或测量，strong-scaling motivation 不能替代它。第二，如果 policy 坚持包含 full GA100 die 的六个 workload benchmark pair，就仍缺 correct-subject/full-design benchmark；A100 product 和 MLCommons system 结果只能证明错误主体。第三，若 release date 被定义为 standalone die/product release，或希望把 deployment、availability、hardware status、market access、positioning 和 price 写成正向值，当前没有直接 GA100 standalone-die 来源；这些项只能在足够的 endpoint-aware 检索后以 `not_found` 关闭。

还有两项发布性负证据缺口不应误称为“只差 ingestion”：A100 BERT/MIG、MLCommons 具体结果，以及两份 SEC filing 尚无固定 payload。它们若继续承担 benchmark/market-access 的状态变化，就必须先补快照；否则 r32 相对 r22/r28 并没有新增可复现证据。

## 再验收门

只有同时满足以下条件，修订版才可从 `reject` 改为 `accept`：builder expected pair set-equal；architecture pair 无漏项；utilization、release 和 die-count 三项完成上述语义或 policy 修复；六个 benchmark 走唯一批准路径；所有 value/not-found/N/A 有正式 target 和 actual endpoint 链；online-only 来源已固定或从结论中移除；GA100 object-scope selection、reverse removal、coverage manifest 与独立批准全部完成。

## 复核与失败分类

本轮先按主线恢复顺序读取规则，再对 r16、r20-r24、r28、r32、official-web v2/r29、正式 fields/objects/relations/components 和来源注册表做交叉核对。机器辅助计数独立得到 141/78/27/270/93/153；没有采用 r32 自报计数作为结果。

两次只读命令需要纠正。第一次把 r20-r22 的文件名简写错，`sed` 返回 `No such file or directory`；这是 model/operator path mistake，随后用文件枚举找到真实名称并重读。第二次 Python 单行计数在 f-string expression 中使用转义引号，触发 `SyntaxError`；这是 model/operator quoting mistake，改为不含 f-string 的同一只读计算后成功。二者都不是 sandbox denial、审批失败、远程服务错误、用户中断或来源失效，也没有缩减复核范围。

本机没有执行 Windows 三道 hard gate；本轮没有改正式数据，因而不声明数据门通过。`report-humanizer` 已对本文件单独执行机器扫描。人工逆向复读从失败分类、再验收门、真正来源缺口、最小修复、selection、HPEC、三个语义争议、benchmark policy、not-found 发布门、25 行表、正式基线回到开头裁决，重点复核了 15 field ID 不等于 15 pair、5/19/1 算术、29/27/2、22/5、15,817,628 bytes、A100-BENCH/TRADE 的快照状态，以及 product carrier 与 exact die/component target 的边界。
