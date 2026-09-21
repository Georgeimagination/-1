# GA100 内容交付独立验收

裁决：`accept_with_fixes`  
验收对象：`NVIDIA GA100 die`，即 full 128-SM GA100 bare-die design  
验收日期：2026-08-21  
写入边界：本轮只新增本验收文件，没有修改三份候选、正式 CSV、来源表、资料卡、合同或进度。

## 裁决

三份候选的技术主体边界基本成立。白皮书 PDF p.19 明确把 full GA100 的 `128 SM / 8192 FP32 CUDA Core / 512 Tensor Core / 12×512-bit memory controller` 与 A100 enabled implementation 的 `108 / 6912 / 432 / 10×512-bit` 分开；候选卡和事实缺口矩阵没有把 A100 的 HBM、时钟、功耗、板卡形态或系统 benchmark 写成 full GA100 常量。ISSCC PDF p.1 的 108-SM、1.41 GHz、40 MB L2 和 HBM 值也一直保留在 A100 产品条件下。

`ga100_fact_gap_matrix.md` 的 204 项行数和自报算术可以复现。主矩阵 M001-M096 共 96 项，状态为 35 个可直接写值、18 个条件化写值、39 个 `not_found`、2 个 `not_applicable` 和 2 个 `pending`。precision path 为 9×12 共 108 格，状态为 51 个 `D`、2 个 `C`、49 个 `NF` 和 6 个 `NA`。合并后恰为 86、20、88、8、2，总数 204。六个 precision `NA` 只落在 INT8、INT4、Binary 的 rounding 与 subnormal，FP64 的 `rne/rtz/rtn/rtp`、INT8/INT4 的条件化 saturation、TF32 1:2、INT4 pair-wise 4:8 也没有被简化错。

状态算术正确不等于八个 N/A 都能进入正式 requirement。当前 v7 只冻结了六个 mandatory structural N/A 和一个 normal die-count N/A；M019 的 HBM stack 是额外的第八项，没有对应的正式 structural predicate。它在阅读层确实是裸片外资源，但在本轮不扩合同的边界下，应把 M019 改为 `仍 pending`，或明确标成不参加 formal requirement status 的 card-scope note。若采用前一种处理，204 项分布变为 `86 direct / 20 conditional / 88 not_found / 7 not_applicable / 3 pending`。

当前不能把整包标成“内容完成，可直接进入正式数据工程”。阻塞点不在核心架构事实，而在两处交付同步：11-family 最小来源集不是当前卡片和 204 项矩阵的反向移除结果；卡片中的若干 requirement 状态又与矩阵不一致。以下修正使用现有固定来源即可完成，不要求重新扩搜全网。

## 最小来源集与正文不一致

| 位置 | 问题 | 精确修正 |
|---|---|---|
| `ga100_minimal_sources.md` L10、L16-L24 | 11 family、12 version、26 endpoint 的总数能从后文清单复算，但四个类别的 family/version/endpoint 小计不能由清单复现。RAS family 同时承担正向机制和 R595 负边界，也不适合强行放进互斥类别。 | 删除 L16-L22 的四类小计，改为：“当前清单机械计数为 11 个 family、12 个内容版本和 26 个实际 endpoint。family 可以同时承担正向事实和负向边界，因此不再给互斥类别小计。最终最小数量在卡片正文冻结后按 exact obligation 重跑 reverse removal。” |
| `ga100_minimal_sources.md` L14、L101；`ga100_card_candidate.md` L185-L191；`ga100_fact_gap_matrix.md` M049-M054 | 最小集把 ISSCC 列为 lead-only，但卡片保留 NRZ、无 FEC、`1e-15 BER` 和相对 FEC 往返时延节省；这些是 ISSCC 的独有 NVLink3 PHY 内容，白皮书不能替代。 | 把 L14 后半段改为：“白皮书是唯一不可替代的 full-GA100 主来源。当前卡片保留 NVLink3 NRZ、无 FEC、BER 和相对时延边界，因此 ISSCC 以 `architecture_mechanism` 入选，并在 notes 中限定为 NVLink3 PHY；若删除这些 PHY 内容，才重新测试其可移除性。” 同时把 L101 从 lead-only 移入入选表。 |
| `ga100_card_candidate.md` L194-L213、L350-L358；`ga100_fact_gap_matrix.md` M071-M077；`ga100_minimal_sources.md` L105 | 卡片已经把 PyTorch、TensorFlow、NCCL、cuBLAS、cuDNN、cuSPARSELt 和 TensorRT 三个 work family 写成条件化正文，最小集却称这些资料是“以后若另写”才启用的 lead-only。当前 11-family 集合无法支撑卡片的软件章节。 | 保留卡片第 9 节时，将 S15-S23 对应 family 放回候选成员，按 compiler/runtime、framework、communication、operator、dynamic-shape、quantization 的 exact obligation 逐 family 反向移除。若坚持 11-family 集合，则必须删除卡片第 9 节相应正文和矩阵 M073-M077；本验收不建议删去已完成的内容。 |
| `ga100_minimal_sources.md` L38-L39、L127；`ga100_card_candidate.md` L217-L235、L330-L358 | 最小集选入 AI Enterprise vGPU docs 和 vGPU User Guide，但卡片没有用对应来源呈现已交付的 vGPU 操作，来源索引也没有这两个 family。按最小集自己的 L127，这两组来源在当前卡片上可被移除。 | 在卡片第 10 节新增产品软件侧栏并补来源标签：“A100 vGPU Live Migration、Suspend-Resume 和 time-sliced preemption 是 A100 product + vGPU Manager + hypervisor 的版本化交付；MIG-backed migration 要求 matching profile/configuration；1:1 MIG-backed vGPU 不使用 time slicing。以上不证明 raw GI migration、GA100 die checkpoint 或 general CUDA job restart。” 若不加此侧栏，则从最小集删除这两个 family 并重算 11/12/26。 |
| `ga100_minimal_sources.md` L106；`ga100_card_candidate.md` L23-L29；`ga100_fact_gap_matrix.md` M003-M008、M092 | Technical Blog、Newsroom、Product Brief、vGPU lifecycle 与 Infra support matrix 被统一列作 lead-only，但卡片和矩阵用它们承担日期观察、availability/status/SKU/price 的错误主体或检索边界。 | 不预设这些 family 全部入选或全部移除。先把每个 actual endpoint 绑定到相应 pending 或 `not_found` obligation，再做逐 family 删除测试。承担不可替代 wrong-subject closure 的 family 使用 `coverage_obligation_evidence`；只重复白皮书边界的 family 才降为 lead-only。 |
| `ga100_card_candidate.md` L8、L332；`ga100_minimal_sources.md` L10 | 卡片声称正文引用 23 个 family，最小集声称 11 个 family；两个数字对应两套不同内容宇宙，不能同时作为同一交付的来源规模。 | 卡片正文和状态修订后，以实际保留的 source family set 重写 L8；随后从同一个 set 生成最小来源文件。不要手工保留 23 或 11 作为目标数量。 |

## 卡片状态需要与 204 项矩阵对齐

本轮以 `ga100_fact_gap_matrix.md` 的 exact-target 裁决为内容状态基线，并按当前 structural N/A 门修正 M019。修正后 pending 是 M003 release date、M019 HBM stack applicability 和 M040 software-visible shared capacity。卡片应作以下同步。

| 卡片位置 | 当前写法 | 建议替换文本 |
|---|---|---|
| L21 | SKU 或销售配置=`not_applicable` | “SKU=`not_found`。full GA100 design codename 不是公开销售 SKU；Product Brief 中的 GA100-8xx 是 A100 产品 GPU/SKU，只作 wrong-subject 结果。” |
| L24-L25、L304 | availability 和 status=`pending_verification` | 两项都改为 `not_found`。建议写：“已完成计划来源检索，命中项均为 A100 card/module 的 production、shipping 或软件支持状态，没有 standalone GA100 die 的 availability 或 hardware lifecycle 值。” 并从 pending 表移到 `not_found` 表。 |
| L29、L315、L375 | 裸片公开价格=`not_applicable`，经济性=`not_applicable` | 改为 `not_found`。建议写：“价格字段保留为 included requirement；计划官方来源没有 standalone GA100 die MSRP/list price。A100 card、cloud 和 DGX system 价格均为 wrong subject。” 成本仍单独为 `not_found`。 |
| L139、L324 | 正文采用 163 KB 作为后续 software-visible limit，未把该字段列入 pending | 与 M040 对齐，写成：“192 KiB/SM 是 combined physical capacity 的直接值。164 KB/SM、160 KB/block 和 163 KB/block 属不同对象粒度与文档修订；原值可以展示，但在 per-SM/per-block 语义和规范版本固定前，software-visible shared capacity requirement 保持 `pending_verification`。” |
| L65；矩阵 M019 | HBM stack 对 bare die 直接记 `not_applicable` | 阅读层可继续说明 HBM stack 位于 package/product path，但 formal requirement 状态改为 `pending_verification`，直到已有合同明确接受该 exact pair 的 structural predicate。不要在本轮新增全局 predicate，也不要把白皮书的 6-stack full-implementation 语句下放为 die 内组件值。 |
| L146、L305 | GA100 L2 virtual-memory responsibility=`pending_verification` | 改为 `not_found`。建议写：“在白皮书、CUDA PG 与 PTX 的计划语料内未找到可归属 GA100 L2 exact target 的 page size、migration、oversubscription 或 remote-fault responsibility；CUDA Unified Memory 行为不下放到 L2。” |
| L190、L315 | device/system topology、Scale-up/Scale-out 对 bare die 记 `not_applicable` | 与 M055 对齐，写成：“GA100 die/link factor 的 topology、bisection、degree、hops、max scale 和 oversubscription 为 `not_found`；DGX/NVSwitch topology 是 wrong-subject system evidence。” card-only 的展示性 N/A 不得计入 204 项状态。 |
| L233、L256、L306 | raw MIG migration、checkpoint 和 general restart=`pending_verification` | 改为 `not_found`。建议写：“MIG 610 未给 raw GI migration、checkpoint/save-restore 或 raw hardware preemption；白皮书 `MIG Migration` 只作概念线索。已交付的是带 A100/vGPU/hypervisor 条件的 VM/vGPU 操作，不证明 GA100 die 或 general job checkpoint。” |
| L299-L307 | pending 表同时放 release、availability/status、virtual memory、MIG/checkpoint 和 driver conflict | pending 表保留 release date、HBM-stack applicability 和 software-visible shared capacity 三项。A100/A30 minimum-driver 保留 `conflicting_unresolved`，不要计入 pending；其余项目按上表移入 `not_found`。 |
| L313-L315 | `not_applicable` 汇总包含销售 SKU、价格、系统 topology 等 | 204 项范围内只汇总 M018 和 precision 的六个 structural N/A。M019 在当前合同下回到 pending；package、interposer、cooling 等 card-only 展示项另列“卡片不采集的上层字段”，不并入 204 项计数。 |

完成这些修改后，卡片的状态分布才能与修正后矩阵的 `86 direct / 20 conditional / 88 not_found / 7 not_applicable / 3 pending` 同义对应。`ga100_minimal_sources.md` L125 也应同步改写：release date、HBM-stack applicability 和 shared-capacity 仍是 pending；availability、status、market access、price、raw MIG/general checkpoint 已是内容层 `not_found`，但正式 search/result 链尚未入库。不要把“没有正值”和“内容未裁决”混为一种状态。

## 进入正式数据工程的门

这次验收没有发现 full GA100、A100 enabled implementation、Ampere architecture、card/module 或 DGX system 的新增主体倒置，9×12 precision path 的计数和六个结构 N/A 也通过。M019 HBM stack 是唯一额外的 N/A 越级。核心内容不需要重写，问题集中在三文件同步、M019 状态和 reverse-removal 输入集合。

修正上述两组 blocker，并由同一版卡片正文重新生成 source obligation 后，可以进入正式数据工程，建立 object/component、source/version/endpoint、逐项 assertion/search result、selection 与 reverse-removal。修正前不得把本包标为 `content_complete`，也不能把 11-family 候选当作正式最小来源选择。

## 复核范围与失败分类

本轮完整读取主线 `AGENTS.md` 和三份候选，并回查 GA100 核心白皮书精读、身份边界、ISSCC、CUDA/PTX、RAS、MIG、HPEC、field/benchmark 缺口、官方网页/vGPU、source synthesis 及其独立复核。必要原文又从本地固定白皮书、ISSCC、PTX 7.2、vGPU User Guide 与 AI Enterprise HTML 快照直接复查。

两条只读辅助命令因我构造字符串时分别误放反引号和字面换行而触发 `SyntaxError`，均属于 model/operator command-construction mistake；改用安全检索式和单行表达式后完成复算。它们不是 sandbox denial、审批失败、远程服务错误、用户中断或来源失效，也没有缩减验收范围。

## 修正后复验

复验日期：2026-08-21  
最终裁决：`accept`  
阻断项：无。

| 复验文件 | 当前 SHA-256 |
|---|---|
| `ga100_card_candidate.md` | `0c501f3b833301f12a394d20b67e18ae17b83bf4aa4ddb4922419ebe6ac63162` |
| `ga100_fact_gap_matrix.md` | `2c685c2063e0601733692f8a266ed4b999a59c717a0a9da669e92a735fafc224` |
| `ga100_minimal_sources.md` | `9ad910e7d8bba155c6f4ba049538472eafae30371f7e3367c7aa7b1f65a983ca` |

卡片 L23、L65、L139 及 L301-L307 现在只保留三项 `pending_verification`：GA100 首次发布日期、HBM-stack applicability 和 software-visible shared capacity。L21、L24-L29、L146、L190、L235、L258 及 L309-L317 已将 SKU、availability/status、price、L2 virtual-memory responsibility、GA100 topology、raw GI migration/checkpoint/general restart 与矩阵对齐为 `not_found`。L319-L325 只把 M018 和六个 precision structural N/A 计入 204 项，上层展示字段不再混入状态计数。卡片页首仍保留 `content candidate / accept_with_fixes` 的候选阶段标签；本节的 `accept` 是修正后的最终内容验收裁决。

矩阵 M019 已改为 `仍 pending`。机械复算结果为：M001-M096 共 96 项，35 个可直接写值、18 个条件化写值、39 个 `not_found`、1 个 `not_applicable`、3 个 `pending`；9×12 precision path 为 51 个 `D`、2 个 `C`、49 个 `NF`、6 个 `NA`。合计与 L169 一致：`86 / 20 / 88 / 7 / 3`，总数 204。

最小来源文件已按当前卡片正文重做反向移除。L7 和 L46 的机械计数为 19 个 family、24 个固定内容版本、40 个 endpoint；S02 因 NVLink3 PHY 独有内容入选，S15-S23 因卡片软件正文入选。vGPU 两组 family 已移除，S08 与 S11-S13 为 lead-only。卡片 L8 和 L340-L368 与该集合一致：23 个索引 family = 19 个入选 family + 4 个 lead-only family。

原报告 L22-L27 的最小来源同步问题和 L35-L44 的卡片状态问题均已关闭。full GA100 die、A100 enabled product、Ampere architecture 与板卡/系统的主体边界没有因修正发生倒置。本交付已达到“内容完成，可进入正式数据工程”的门槛；`accept` 不代表 source/version/endpoint 入库、原子 assertion/search result、正式 selection run 或 Windows hard gate 已完成。
