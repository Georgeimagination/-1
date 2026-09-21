# GA100 来源缺口修复 v2

状态：`remediation_input_ready`

复核日期：2026-08-21。本轮只新增本报告和同名 `_assets/`；没有修改正式 32 表、既有 staging、合同、资料卡或进度。本报告是下一版原子 staging 的逐 pair 来源裁决输入，不是正式发布，也不是 coverage manifest。

## 结论

R35 指出的 Tensor utilization-limit 内容缺口已经找到可接收原文。NVIDIA *Matrix Multiplication Background User Guide* 的§2.2、§2.3 和§3.1 直接说明 A100 对齐效率、small GEMM 的 tile efficiency/parallelism 权衡以及 tile quantization。这三类内容可以作为 A100-SXM4-80GB carrier 条件下的 GA100 on-die Tensor/GEMM component 事实，但不是无条件的 full-GA100 利用率数值。§3.2 的 108-SM wave size、tail wave 占用和相关 GFLOPS/时延必须留在 A100 启用配置，不得改成 full GA100 128-SM 的波次结论。

六个 benchmark pair 全部 `include`，不走 bare-die `exclude` 或 `not_applicable`。在本轮固定的计划语料内，六项均可拟为 `not_found`：MLCommons 在固定 commit 下给出的是“1× A100-SXM-80GB + DGX host + TensorRT 8.4.0 + CUDA 11.6”系统级 BERT-99 结果，可以关闭错误主体搜索，不能逆投为 full 128-SM GA100 die 的值。这一 `not_found` 只針对本轮明示的来源计划，不声称全网绝对不存在其他结果。

SEC 10-Q 直接支持 A100/H100 integrated circuits 及包含它们的系统受新出口许可要求约束。它没有直接命名 full GA100 die，而 A100 integrated circuit 也不等于未裁剪的 128-SM 物理设计对象。因此 GA100 market-access pair 保守裁为 `not_found`，SEC 行是 `checked_no_support` 的 wrong-subject closure，不是 GA100 条件值。

release date 按 R13 合同设计的 deferred 语义处理，并遵守 R35 的后续复核，不在本报告提前发布。只要正式字段仍是“具体对象的首次发布日期”，2020-05-14 的 NVIDIA blog 发布日就不能被私下改成 GA100 release value；该 pair 继续 `pending_verification`，等全库字段语义统一。

## 给 expected-pair builder 的精确增量表

下表只列本轮实际重裁的 exact pair，不是所有 GA100/Ampere 应有 pair 的人工代理。builder 仍须从批准合同、reachable target 和 field target-kind 生成全集，然后要求候选集合与该全集 set-equal。本表的行数不得写入 `closure_count`，更不得恢复固定 25 的口径。

| exact target / field | candidate decision | 拟议 `requirement_status` | 直接裁决 | 后续闭合键 |
|---|---|---|---|---|
| `COMP-R1-GA100-TENSOR / FIELD-COMP-UTILIZATION-LIMIT` | `include` | `value_available` | 接收 A100 carrier 条件下的 alignment、small-GEMM tile tradeoff 和 tile quantization；拒绝 108-SM wave 下放 | `VAL-UTIL-MATRIX-R37` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-LATENCY` | `include` | `not_found` | 有 A100/DGX BERT SingleStream 正结果，无 full-GA100 correct-subject 结果 | `SEARCH-PROP-GA100-BENCH-LATENCY-R37` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-THROUGHPUT` | `include` | `not_found` | 有 A100/DGX BERT Offline 正结果与 A100 microbenchmark，无 full-GA100 完整 workload 结果 | `SEARCH-PROP-GA100-BENCH-THROUGHPUT-R37` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-POWER` | `include` | `not_found` | TDP 不是 workload power；选定的 MLCommons x1 场景目录没有 `power` child | `SEARCH-PROP-GA100-BENCH-POWER-R37` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-ENERGY-PER-TOKEN` | `include` | `not_found` | 无同 scope token 计数与能量测量，不从 samples/s 或 TDP 推导 | `SEARCH-PROP-GA100-BENCH-ENERGY-R37` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-TOKENS-PER-JOULE` | `include` | `not_found` | 无同 scope token/J，不取缺失量的倒数 | `SEARCH-PROP-GA100-BENCH-TOKENS-J-R37` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-UTILIZATION` | `include` | `not_found` | Matrix Guide 是 GEMM/component 利用限制，不是完整模型 MFU/HFU/MBU 或 scaling efficiency | `SEARCH-PROP-GA100-BENCH-UTIL-R37` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-MARKET-ACCESS-CONSTRAINT` | `include` | `not_found` | SEC 直接主体是 A100/H100 integrated circuits 及 systems，不归属 full GA100 die | `SEARCH-PROP-GA100-MARKET-R37` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-RELEASE-DATE` | `include` | `pending_verification` | 遵守 R35 的 deferred 语义；blog 日期仅是 source publication/direct naming evidence | `PENDING-GLOBAL-RELEASE-SEMANTICS` |
| `OBJ-NVIDIA-AMPERE-ARCH / FIELD-ID-DESIGN-OBJECTIVE` | `include` | `value_available` | whitepaper p.38 直接值：架构目标是在现有 DNN 上 strong scaling | `VAL-AMPERE-DESIGN-P38` |
| `OBJ-NVIDIA-AMPERE-ARCH / FIELD-ID-TARGET-USE-POSITIONING` | `include` | `value_available` | p.38 直接限定为 existing deep neural networks 的 strong-scaling 用途；不擅自扩成所有 cloud workload | `VAL-AMPERE-TARGET-P38` |
| `OBJ-NVIDIA-AMPERE-ARCH / FIELD-ID-VENDOR-POSITIONING` | `include` | `value_available` | whitepaper p.11 直接以 Ampere architecture 为主语，定位为降低延迟/软件复杂度并提高相对 Volta 的 perf/W | `VAL-AMPERE-VENDOR-P11` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-DESIGN-OBJECTIVE` | `include` | `not_found` | p.38 的主语是 Ampere architecture，A100 wording 也不是 full GA100 die | `SEARCH-PROP-GA100-DESIGN-R37` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-TARGET-USE-POSITIONING` | `include` | `not_found` | 目标用途原文直接指向 A100 product 或 Ampere architecture | `SEARCH-PROP-GA100-TARGET-R37` |
| `OBJ-NVIDIA-GA100-DIE / FIELD-ID-VENDOR-POSITIONING` | `include` | `not_found` | `GA100 powers A100` 是 identity bridge，不是 GA100 standalone-die 厂商定位 | `SEARCH-PROP-GA100-VENDOR-R37` |

本表未重裁的 deployment、availability、status、price、die-count 等 pair 仍由 builder 生成并继承已批准的最新裁决，不能因本表没有列出就消失。

## Tensor/GEMM utilization-limit

新固定端点为 `END-PROP-GA100R37-MATRIX-LOCAL`，对应 `SRCVER-GA100R37-NVIDIA-MATRIX-GUIDE-CAPTURE-20260821`。本地原字节路径、hash 和 HTTP 信息见后文 endpoint 表与 snapshot manifest。

`VAL-UTIL-MATRIX-R37` 应拆成三条 assertion，而不是一段混合值。第一条定位§2.2 `Requirements for Tensor Cores`：A100 在 cuBLAS 11.0 及以后可以在非对齐尺寸上使用 Tensor Cores，但效率更好的维度对齐与数据类型有关；A100 表中给出 INT8 128、FP16 64、TF32 32、FP64 16 elements 的最佳效率倍数。该 assertion 需保留 datatype 和 library-version 条件，不得写成物理 Tensor Core 阵列寸寸。

第二条定位§2.3 `Typical Tile Dimensions in cuBLAS and Performance`：大 tile 数据复用高但并行 tile 数少，小 tile 反之；GEMM 过小时，tile efficiency 或 tile parallelism 的损失会阻止 GPU 达到 peak math utilization。Figure 3/4 的测量条件是 NVIDIA A100-SXM4-80GB、CUDA 11.2、cuBLAS 11.4。该条正面满足字段的 small/narrow GEMM 语义，但数值与载体条件必须保留。

第三条定位§3.1 `Tile Quantization`：当矩阵维度不能被 thread-block tile 尺寸整除时，边界 tile 仍执行同量 math，因而出现无效工作；输出维度可被 tile 维度整除时利用率最高。Figure 7 同样是 A100-SXM4-80GB、CUDA 11.2、cuBLAS 11.4，使用 256×128 tiles 的条件测量。

§3.2 `Wave Quantization` 不进入 `VAL-UTIL-MATRIX-R37`。原文明确写“A100 has 108 SMs”，并以 108 tiles 为 wave size 分析 117 tiles 形成的一个 full wave 与一个 9-tile tail wave。这是 A100 enabled configuration 的 aggregate scheduling 现象，不是 full GA100 128-SM 设计的波次数值。下一版 staging 应对该 locator 生成 `checked_no_support`/rejected assertion，理由为 `wrong_enabled_scale_108sm_not_full_ga100_128sm`；禁止把 108 换成 128 后作为“强扩展”事实。

## MLCommons 固定版本与错误主体闭合

MLCommons 只有一个 source version：`SRCVER-GA100R37-MLCOMMONS-COMMIT-36D324B5`，commit 全值为 `36d324b502175621063a478fcbf6d2cb9421ca34`。commit API 快照记录的 tree 是 `c3d2a5adfda50a1cde7ebec7896fe0ab6ceea526`，且 API 返回的 `sha` 与用户指定值一致。commit HTML 只是同版本的可读视图，不算第二份 corroboration。

最小内容端点已经分开固定：system JSON、BERT-99 Offline summary 和 BERT-99 SingleStream summary 是三个 actual endpoint。为避免把“未列出目录”误说成“全仓库不存在”，本轮又固定了 Offline 和 SingleStream 两个选定场景的 contents API JSON。这两个目录各只列出 `accuracy` 和 `performance`，因此只能说“选定单卡 BERT-99 场景没有 `power` child”，不说 MLCommons v2.0 全库没有 power 或 MaxQ 结果。

system JSON 的直接条件为 `NVIDIA DGX A100 (1x A100-SXM-80GB, TensorRT)`、1 node、1 accelerator、A100-SXM-80GB 80 GB HBM2e，host 为 2 颗 AMD EPYC 7742 与 2 TB memory，软件为 TensorRT 8.4.0、CUDA 11.6、cuDNN 8.3.2、Driver 510.39.01 和 DALI 0.31.0。Offline summary 的 VALID 结果是 `3560.73 samples/s`；SingleStream summary 的 VALID 90th-percentile latency 是 `1,551,870 ns`，换成字段 canonical unit 为 `0.001551870 s`。这两个数值只能写给上述 system-under-test，不能写给 `OBJ-NVIDIA-GA100-DIE`。

## benchmark 逐字段搜索闭合

下表中的 endpoint ID 都在后文映射到唯一的本地字节路径和 hash，不是 `A100-BENCH`、`PB` 或 `TRADE` 这类别名。每个 search 在正式 staging 中应写一条 `no_reliable_result`，表内的每个 actual endpoint 再分别写 `checked_no_support` 或 `duplicate`。

| search ID / final status | `no_reliable_result` 搜索范围 | 关键 actual-endpoint result |
|---|---|---|
| `SEARCH-PROP-GA100-BENCH-LATENCY-R37` / `not_found` | `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL` pp.9-12,36-38；`END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL` pp.4-7 Tables II-IV；`END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-LOCAL` full text；`END-PROP-R1GA100-WEB-001-LOCAL`、`END-PROP-R1GA100-WEB-002-LOCAL`、`END-PROP-R1GA100-WEB-003-LOCAL`、`END-PROP-R1GA100-WEB-004-LOCAL`、`END-PROP-R1GA100-WEB-005-LOCAL`；`END-PROP-GA100R37-MATRIX-LOCAL` §2.3,§3.1-§3.2；`END-PROP-MLC-36D324B5-SYSTEM`、`END-PROP-MLC-36D324B5-OFFLINE-SUMMARY`、`END-PROP-MLC-36D324B5-SINGLE-SUMMARY` | HPEC cycles 是 `checked_no_support` 的 wrong metric/unit；RAND 没有 latency；Matrix 是 A100 GEMM component measurement；MLCommons SingleStream 的 1,551,870 ns 是 A100-SXM-80GB + DGX/TensorRT/CUDA system 结果，因 wrong subject 为 `checked_no_support`；`END-PROP-R1GA100-WEB-003-LOCAL` 对 `END-PROP-R1GA100-WEB-002-LOCAL` 是 `duplicate`。 |
| `SEARCH-PROP-GA100-BENCH-THROUGHPUT-R37` / `not_found` | `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL` pp.9-12,36-38；`END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL` p.6 Table III；`END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-LOCAL` pp.1-2,5-6 Figures 1/6；`END-PROP-R1GA100-WEB-001-LOCAL`、`END-PROP-R1GA100-WEB-002-LOCAL`、`END-PROP-R1GA100-WEB-003-LOCAL`、`END-PROP-R1GA100-WEB-004-LOCAL`、`END-PROP-R1GA100-WEB-005-LOCAL`；`END-PROP-GA100R37-MATRIX-LOCAL` Figures 3/4/7/8；`END-PROP-MLC-36D324B5-SYSTEM`、`END-PROP-MLC-36D324B5-OFFLINE-SUMMARY`、`END-PROP-MLC-36D324B5-SINGLE-SUMMARY` | HPEC `GB/s` 列缺 operation-count rule 且主体未解；RAND 是 A100-SXM4-80GB random-access path；Matrix 是 A100 GEMM microbenchmark；MLCommons Offline `3560.73 samples/s` 是系统级 BERT-99；均 `checked_no_support`。`END-PROP-R1GA100-WEB-003-LOCAL` 是 `duplicate`。 |
| `SEARCH-PROP-GA100-BENCH-POWER-R37` / `not_found` | `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`、`END-PROP-R1GA100-WEB-001-LOCAL`、`END-PROP-R1GA100-WEB-002-LOCAL`、`END-PROP-R1GA100-WEB-003-LOCAL`、`END-PROP-R1GA100-WEB-004-LOCAL`、`END-PROP-R1GA100-WEB-005-LOCAL` 查 `power`, `watt`, `TDP`；`END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL`、`END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-LOCAL`、`END-PROP-GA100R37-MATRIX-LOCAL` 全文；`END-PROP-MLC-36D324B5-SYSTEM` 的 `power_*` keys；`END-PROP-MLC-36D324B5-OFFLINE-SUMMARY`、`END-PROP-MLC-36D324B5-SINGLE-SUMMARY`、`END-PROP-MLC-36D324B5-OFFLINE-DIR`、`END-PROP-MLC-36D324B5-SINGLE-DIR` | WP/Blog/Newsroom/PB 的 400 W 类数值是 A100 TDP/nameplate，不是 workload measurement；HPEC/RAND/Matrix 无同 scope power；MLCommons system 的 power fields 为空，两个选定场景目录不列 `power`，均 `checked_no_support`。`END-PROP-R1GA100-WEB-003-LOCAL` 是 `duplicate`；目录结论不外推到全仓库。 |
| `SEARCH-PROP-GA100-BENCH-ENERGY-R37` / `not_found` | `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`、`END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL`、`END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-LOCAL`、`END-PROP-R1GA100-WEB-001-LOCAL`、`END-PROP-R1GA100-WEB-002-LOCAL`、`END-PROP-R1GA100-WEB-003-LOCAL`、`END-PROP-R1GA100-WEB-004-LOCAL`、`END-PROP-R1GA100-WEB-005-LOCAL`、`END-PROP-GA100R37-MATRIX-LOCAL`、`END-PROP-MLC-36D324B5-SYSTEM`、`END-PROP-MLC-36D324B5-OFFLINE-SUMMARY`、`END-PROP-MLC-36D324B5-SINGLE-SUMMARY`、`END-PROP-MLC-36D324B5-OFFLINE-DIR`、`END-PROP-MLC-36D324B5-SINGLE-DIR`；关键词 `energy`, `joule`, `J/token`, `token` | 无 full-GA100 token workload 与 energy measurement；MLCommons 使用 samples 且选定场景无 power 目录；内容端点均 `checked_no_support`，`END-PROP-R1GA100-WEB-003-LOCAL` 是 `duplicate`。 |
| `SEARCH-PROP-GA100-BENCH-TOKENS-J-R37` / `not_found` | `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`、`END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL`、`END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-LOCAL`、`END-PROP-R1GA100-WEB-001-LOCAL`、`END-PROP-R1GA100-WEB-002-LOCAL`、`END-PROP-R1GA100-WEB-003-LOCAL`、`END-PROP-R1GA100-WEB-004-LOCAL`、`END-PROP-R1GA100-WEB-005-LOCAL`、`END-PROP-GA100R37-MATRIX-LOCAL`、`END-PROP-MLC-36D324B5-SYSTEM`、`END-PROP-MLC-36D324B5-OFFLINE-SUMMARY`、`END-PROP-MLC-36D324B5-SINGLE-SUMMARY`、`END-PROP-MLC-36D324B5-OFFLINE-DIR`、`END-PROP-MLC-36D324B5-SINGLE-DIR`；关键词 `tokens/J`, `token per joule`, `efficiency per token` | 无直接 token/J，也缺可合法派生的同 scope token throughput 和 energy/power input；内容端点均 `checked_no_support`，`END-PROP-R1GA100-WEB-003-LOCAL` 是 `duplicate`；不做倒数或 TDP 换算。 |
| `SEARCH-PROP-GA100-BENCH-UTIL-R37` / `not_found` | `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL` p.38；`END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL` Table III/全文；`END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-LOCAL` Figures 1/6/全文；`END-PROP-R1GA100-WEB-001-LOCAL`、`END-PROP-R1GA100-WEB-002-LOCAL`、`END-PROP-R1GA100-WEB-003-LOCAL`、`END-PROP-R1GA100-WEB-004-LOCAL`、`END-PROP-R1GA100-WEB-005-LOCAL` 全文；`END-PROP-GA100R37-MATRIX-LOCAL` §2.3,§3.1-§3.2；`END-PROP-MLC-36D324B5-SYSTEM`、`END-PROP-MLC-36D324B5-OFFLINE-SUMMARY`、`END-PROP-MLC-36D324B5-SINGLE-SUMMARY` | WP strong scaling 是 design objective；HPEC `Measured-theoretical`、RAND `full-speed` 没有项目所需 metric definition；Matrix peak math utilization 是 component/GEMM 限制；MLCommons 只给 latency/throughput；对 benchmark utilization 均 `checked_no_support`。`END-PROP-R1GA100-WEB-003-LOCAL` 是 `duplicate`。 |

搜索中的 official-web 入口是 Technical Blog、A100 Newsroom launch 和两个 A100 PCIe Product Brief 版本。official-web v2 其他条目主要是 CUDA/TensorRT/cuDNN/NCCL/container/MIG/vGPU 版本证据，不在这六个 workload benchmark 的内容搜索范围；它们应在 source screening 中保留“非 benchmark content candidate”的理由，不应被伪写成全部已搜且全部无支持。

## market access

`SEARCH-PROP-GA100-MARKET-R37` 的 source range 是 `END-PROP-GA100R37-SEC-10Q-LOCAL`、`END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`、`END-PROP-R1GA100-WEB-001-LOCAL`、`END-PROP-R1GA100-WEB-004-LOCAL` 和 `END-PROP-R1GA100-WEB-005-LOCAL`，查找 `export`, `license`, `China`, `Hong Kong`, `Russia`, `restriction`, `market access`。建议 search 结果为 `no_reliable_result`。

SEC 定位是 Form 10-Q `Item 1A. Risk Factors`，以 `On August 26, 2022` 开头的段落。原文明确说美国政府对未来向中国（包括香港）和俄罗斯出口 A100 和即将推出的 H100 integrated circuits 施加即时生效的新 license requirement，并覆盖包含它们的 DGX/其他系统以及 A100X。这一行对 A100 IC/product 约束是正证据，对 `OBJ-NVIDIA-GA100-DIE` 是 `checked_no_support: wrong_subject_a100_ic_and_system_not_full_ga100_design`。

whitepaper pp.9,14,19 和 blog 可以建立 GA100 powers A100、full 128-SM design 与 A100 108-SM enabled implementation 的 identity boundary，但这条 bridge 不具有 market-access 投影权；它们对该 pair 分别是 `checked_no_support`。两个 Product Brief 只能说明 A100 40GB/80GB PCIe product 版本和 SKU 边界，同样为 `checked_no_support`，且两个修订版不算独立 corroboration。

## release date 和三个 Ampere architecture pair

`OBJ-NVIDIA-GA100-DIE / FIELD-ID-RELEASE-DATE` 按 R13 deferred 语义继续 `pending_verification`。`R1GA100-WEB-001` 的页面 metadata 记录 `datePublished=2020-05-14`，且正文直接命名 GA100，但这只支持“首次已固定的官方发文观察”。除非全库将 `FIELD-ID-RELEASE-DATE` 统一迁移为“厂商首次正式公开并直接命名对象的日期”，否则不得将它写成 GA100 value。A100 full-production/shipping 的 Newsroom 日期更不能代替 GA100 standalone-die release。

Ampere architecture 的三个 pair 都要保留在 builder 输出中。`FIELD-ID-DESIGN-OBJECTIVE` 的 direct value 来自 whitepaper p.38 `Strong Scaling Deep Learning Performance`，可记录为“目标是在现有深度神经网络上通过 strong scaling 实现加速”。该页还定义 fixed workload per GPU，因此 `FIELD-ID-TARGET-USE-POSITIONING` 可保守写为“针对 existing DNN 的 strong-scaling deep-learning workload”，不从 A100 product 章节扩成所有 AI/HPC/data-analytics 对象。

`FIELD-ID-VENDOR-POSITIONING` 的直接主语来自 whitepaper p.11：NVIDIA 将 Ampere architecture 定位为改善可编程性、降低延迟和 AI/HPC 软件复杂度，并且相对 Volta 提供更高 performance per watt。这是厂商原文定位，不是独立测量结论。

对应的 GA100 die 三 pair 不能从 architecture/A100 值复制。`SEARCH-PROP-GA100-DESIGN-R37`、`SEARCH-PROP-GA100-TARGET-R37` 和 `SEARCH-PROP-GA100-VENDOR-R37` 都应产生 `no_reliable_result`；三者的内容端点范围均为 `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL` pp.9-12,14,19,38、`END-NVIDIA-A100-ISSCC-2021-LOCAL` 全文、`END-PROP-R1GA100-WEB-001-LOCAL` 正文介绍与 `Key features`、`END-PROP-R1GA100-WEB-002-LOCAL`、`END-PROP-R1GA100-WEB-003-LOCAL`、`END-PROP-R1GA100-WEB-004-LOCAL` 和 `END-PROP-R1GA100-WEB-005-LOCAL`。whitepaper p.38/p.11 对 die pair 是 `checked_no_support: architecture_subject`；Blog/Newsroom/PB 的用途与定位句对 die pair 是 `checked_no_support: A100_product_subject`；ISSCC 的主语为 A100/A100 die，没有 GA100 codename，也是 `checked_no_support`。`END-PROP-R1GA100-WEB-003-LOCAL` 对 `END-PROP-R1GA100-WEB-002-LOCAL` 是 `duplicate`。

## source version 与 actual endpoint 目录

下列 ID 是给下一版 staging 的精确 endpoint 建议。已存在的 ID 保持原样；`END-PROP-*` 尚未进正式表，但每个都映射到唯一的固定字节。下一版不能用 online URL 代替这些本地 snapshot。

| source version / family | actual endpoint ID | 固定端点、字节和用途 |
|---|---|---|
| `SRC-M2NA-NVIDIA-AMPERE-WP-2020` v1.0 / `SFAM-M2NA-NVIDIA-AMPERE-WP-2020` | `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL` | `论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf`；7,979,890 bytes；SHA-256 `3a800ad7668ec37037fa5870a8e3bb681b75f19668b3d11492ab9b0da0d58815`。identity、architecture value、benchmark negative。 |
| `SRC-NVIDIA-A100-ISSCC-2021` | `END-NVIDIA-A100-ISSCC-2021-LOCAL` | `论文/NVIDIA_GPU/01_厂商直接架构论文/2021_A100_Datacenter_GPU_Ampere_ISSCC.pdf`；463,828 bytes；SHA-256 `55765d2680678ba46045da1902496ddd3995d5964a5f0ef68a99362e2c43b601`。A100 subject cross-check，不计作 whitepaper 的独立厂商 corroboration。 |
| `SRC-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-2022` | `END-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-LOCAL` | `论文/NVIDIA_GPU/02_独立逆向与微基准/2022_Demystifying_NVIDIA_Ampere_Architecture.pdf`；285,169 bytes；SHA-256 `86013d806532a281e7878415cc1a55aa426f8fbd8ae0e9dc02285882fbdd8227`。arXiv v1；HPEC 出版等价性未验证。 |
| `SRC-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-2024` | `END-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-LOCAL` | `论文/NVIDIA_GPU/02_独立逆向与微基准/2024_A100_Full_Speed_Random_Access_Memory.pdf`；587,055 bytes；SHA-256 `6ca888b92691f06de9d5d15b268f2e2c738c9f0ef44441e6fd785f65a113a8a9`。A100-SXM4-80GB product microbenchmark。 |
| NVIDIA Technical Blog / 2020-05-14 observation | `END-PROP-R1GA100-WEB-001-LOCAL` | `审计/子代理交接/r1_ga100_source_staging_v3_official_web_v2/payload/html/nvidia-technical-blog_ampere-architecture-in-depth__captured-20260821.html`；330,174 bytes；SHA-256 `ced8cd095756924ef61121e83eb69f66ceeb100c6616f71ed8c2bb3cb1e76e52`。 |
| NVIDIA Newsroom A100 launch / 2020-05-14 | `END-PROP-R1GA100-WEB-002-LOCAL` | official-web-v2 `payload/html/nvidia-newsroom_a100-full-production-launch__captured-20260821.html`；81,832 bytes；SHA-256 `85e892e042eb3961d39ce9c67f00924ee9db41cb97ea62bd91d7f9da6af31d0e`。 |
| 同一 Newsroom source version 的 PDF mirror | `END-PROP-R1GA100-WEB-003-LOCAL` | official-web-v2 `payload/pdf/nvidia-newsroom_a100-full-production-launch__captured-20260821.pdf`；33,646 bytes；SHA-256 `6ffe3336858ec847e41e4d82cc776c62885b4fedb1531068fd512476eed7ce51`；对 WEB-002 为 `duplicate`。 |
| A100 PCIe Product Brief / `PB-10137-001_v03` | `END-PROP-R1GA100-WEB-004-LOCAL` | official-web-v2 `payload/pdf/nvidia-a100-pcie-product-brief-40gb_PB-10137-001_v03__captured-20260821.pdf`；341,524 bytes；SHA-256 `06e4c11c950d6ad08fbe2ea543857d6b22d0a3060d6cf8b63e550debf448fe0b`。 |
| A100 PCIe Product Brief / `PB-10577-001_v03` | `END-PROP-R1GA100-WEB-005-LOCAL` | official-web-v2 `payload/pdf/nvidia-a100-pcie-product-brief-80gb_PB-10577-001_v03__captured-20260821.pdf`；399,355 bytes；SHA-256 `ef1350c2315f52040994d31826bc95eacdfd8edb56bb363f23ad0a5e5059f601`。URL 名为 v02，source version 以 PDF 内页 v03 为准。 |
| `SRCVER-GA100R37-NVIDIA-MATRIX-GUIDE-CAPTURE-20260821` | `END-PROP-GA100R37-MATRIX-LOCAL` | `_assets/payload/nvidia-matrix-multiplication-background__captured-20260821.html`；326,039 bytes；SHA-256 `c4a8e64475bce019738c6cf9067ecc9cac8348e2c67cdc7fe056eddeda00c790`。 |
| `SRCVER-GA100R37-MLCOMMONS-COMMIT-36D324B5` | `END-PROP-MLC-36D324B5-COMMIT-API` | `_assets/payload/mlcommons_commit_36d324b502175621063a478fcbf6d2cb9421ca34.json`；2,872 bytes；SHA-256 `b6bf83b065d52716b21aa98c166650d67b543be844b1214267cf68127b241a14`。commit identity endpoint。 |
| 同一 MLCommons source version | `END-PROP-MLC-36D324B5-COMMIT-HTML` | `_assets/payload/mlcommons_commit_36d324b502175621063a478fcbf6d2cb9421ca34.html`；393,000 bytes；SHA-256 `5c73adfe1b1ea0f58c4dfe22ac19de4e2a4a2098c52ce21e22d57aac37c1210a`；对 commit API 为可读视图，`duplicate`。 |
| 同一 MLCommons source version | `END-PROP-MLC-36D324B5-SYSTEM` | `_assets/payload/mlcommons_dgx-a100_a100-sxm-80gbx1_trt_system__commit-36d324b5.json`；1,711 bytes；SHA-256 `165899d99b7fd835e2692b710053c8b86275a453aba35131146d2337e62de1ff`。 |
| 同一 MLCommons source version | `END-PROP-MLC-36D324B5-OFFLINE-SUMMARY` | `_assets/payload/mlcommons_dgx-a100_bert-99_offline_summary__commit-36d324b5.txt`；1,594 bytes；SHA-256 `b3d290da496e8c76eee37f8fa1140bf73d258784418f1da638ae4eac6d95b1ef`。 |
| 同一 MLCommons source version | `END-PROP-MLC-36D324B5-SINGLE-SUMMARY` | `_assets/payload/mlcommons_dgx-a100_bert-99_singlestream_summary__commit-36d324b5.txt`；1,864 bytes；SHA-256 `0db37d68fc0641abdb4ed32f0c1439a454c997104e9b0b350825330f3ddff8b1`。 |
| 同一 MLCommons source version | `END-PROP-MLC-36D324B5-OFFLINE-DIR` | `_assets/payload/mlcommons_dgx-a100_bert-99_offline_contents__commit-36d324b5.json`；2,467 bytes；SHA-256 `09c1c63115de96400e78ad7c615ead3e0ca64dd33ad64efe1c361777abd44dc1`。 |
| 同一 MLCommons source version | `END-PROP-MLC-36D324B5-SINGLE-DIR` | `_assets/payload/mlcommons_dgx-a100_bert-99_singlestream_contents__commit-36d324b5.json`；2,709 bytes；SHA-256 `1037e0dde1c48b5596a51e0b8384b917bd9298232c5243bd94fc2a2a25ba9d5c`。 |
| `SRCVER-GA100R37-NVIDIA-20220731-10Q` | `END-PROP-GA100R37-SEC-10Q-LOCAL` | `_assets/payload/sec_nvidia_2022-07-31_10-q__captured-20260821.html`；1,861,176 bytes；SHA-256 `3fcc8e3277e625bafe4a4645b03c3f3d3a040e96373ef9adf09b6eabd4ba15dd`。market-access source。 |

## source-family 裁决

MLCommons commit 是一个 source version，system JSON、两个 result summary 和两个 directory manifest 都是它的 actual endpoint，不是六个独立来源。commit API 与 HTML 是同一 identity 的两个视图。NVIDIA Matrix Guide 是新 family，2026-08-21 快照只固定这次可变页面观察；后续修订仍属同一作品家族。SEC 的 403 body、gzip transfer 和最终解压 HTML 也只对应一份 filing source version，仅最终 200 HTML 是内容证据端点。

cuSPARSELt User Guide 与 cuSPARSELt Release Notes 必须分成两个 family，不得因为产品名相同而合并。各自内部的修订版不算独立 corroboration。MIG r580 PDF、`latest` 与 r610 HTML/章节端点都归入同一 *MIG User Guide* family。PTX 7.0 和 7.2 是同一 PTX ISA family 的 revision，不得把它们当两份独立证据。详细映射已写入 `_assets/source-family-map.csv`。

## 最小来源选择与反向移除

下一版必须先把上述 value、`checked_no_support`/`duplicate` 与 `no_reliable_result` 全部落成原子行，再建 GA100 object-scope selection run。不能先删掉承担 `not_found` 的来源，然后用缩水语料重算出同样的缺失结论。

选择角色要按职责分开。identity 以 Ampere whitepaper 为核心，Technical Blog 只在 GA100 direct naming/发文观察仍被要求时保留。architecture mechanism 由 whitepaper 与 Matrix Guide 承担；Matrix Guide 的不可替代价值是本轮 utilization-limit 直接原文。software 由 CUDA Programming Guide、PTX family、TensorRT/cuDNN/cuSPARSELt 等实际被接收的版本证据承担；cuSPARSELt Guide 和 Release Notes 不合并。virtualization/RAS 由 MIG User Guide 单 family 和 GPU Memory Error Management/RAS family 承担，r580/r610/latest 不重复计数。

independent validation 中，HPEC arXiv v1 只有在它保留的 A100-conditioned on-die cycle/mapping fact 无法被第一方来源覆盖时才入选；RAND 对本轮六个 benchmark 主要是 coverage-obligation evidence，不是 full-GA100 正值。coverage-obligation evidence 还必须包含 MLCommons 固定 commit（一个 source version、多个 actual endpoint）、SEC 10-Q、Technical Blog/Newsroom/Product Brief 的实际被查版本，以及承担相应负证据的 HPEC/RAND/Matrix endpoint。

反向移除时，每删除一个 family 都要重算全部 include pair 的 value 支持、actual-endpoint search result 与 `no_reliable_result` 搜索范围。Newsroom PDF mirror、MLCommons commit HTML、SEC gzip transport body 可作为 `duplicate` 移出最终 selected member，但历史 capture/screening 记录保留。Product Brief 两版若对所有 remaining obligation 都只是同家族重复结果，可保留一个主版本作 coverage evidence；但前提是另一版的产品范围不再被任何 requirement 引用。SEC 和 MLCommons 在 market/benchmark `not_found` 正式闭合前不可移除。

## 新增快照完整性

`_assets/snapshot-manifest.csv` 给出每个新捕获 body 的 requested URL、final URL、`captured_at`、HTTP status、content-type、bytes、SHA-256，以及对应 headers 的 bytes/hash。新增 body 的精确值如下：

| body | status / type | bytes | SHA-256 | 证据资格 |
|---|---|---:|---|---|
| `nvidia-matrix-multiplication-background__captured-20260821.html` | 200 / `text/html;charset=UTF-8` | 326,039 | `c4a8e64475bce019738c6cf9067ecc9cac8348e2c67cdc7fe056eddeda00c790` | canonical snapshot |
| `mlcommons_commit_36d324b502175621063a478fcbf6d2cb9421ca34.json` | 200 / `application/json; charset=utf-8` | 2,872 | `b6bf83b065d52716b21aa98c166650d67b543be844b1214267cf68127b241a14` | canonical commit identity |
| `mlcommons_commit_36d324b502175621063a478fcbf6d2cb9421ca34.html` | 200 / `text/html; charset=utf-8` | 393,000 | `5c73adfe1b1ea0f58c4dfe22ac19de4e2a4a2098c52ce21e22d57aac37c1210a` | duplicate human-readable view |
| `mlcommons_dgx-a100_a100-sxm-80gbx1_trt_system__commit-36d324b5.json` | 200 / `text/plain; charset=utf-8` | 1,711 | `165899d99b7fd835e2692b710053c8b86275a453aba35131146d2337e62de1ff` | canonical content endpoint |
| `mlcommons_dgx-a100_bert-99_offline_summary__commit-36d324b5.txt` | 200 / `text/plain; charset=utf-8` | 1,594 | `b3d290da496e8c76eee37f8fa1140bf73d258784418f1da638ae4eac6d95b1ef` | canonical content endpoint |
| `mlcommons_dgx-a100_bert-99_singlestream_summary__commit-36d324b5.txt` | 200 / `text/plain; charset=utf-8` | 1,864 | `0db37d68fc0641abdb4ed32f0c1439a454c997104e9b0b350825330f3ddff8b1` | canonical content endpoint |
| `mlcommons_dgx-a100_bert-99_offline_contents__commit-36d324b5.json` | 200 / `application/json; charset=utf-8` | 2,467 | `09c1c63115de96400e78ad7c615ead3e0ca64dd33ad64efe1c361777abd44dc1` | selected-directory manifest |
| `mlcommons_dgx-a100_bert-99_singlestream_contents__commit-36d324b5.json` | 200 / `application/json; charset=utf-8` | 2,709 | `1037e0dde1c48b5596a51e0b8384b917bd9298232c5243bd94fc2a2a25ba9d5c` | selected-directory manifest |
| `sec_nvidia_2022-07-31_10-q__captured-20260821.html` | 200 / `text/html` | 1,861,176 | `3fcc8e3277e625bafe4a4645b03c3f3d3a040e96373ef9adf09b6eabd4ba15dd` | canonical SEC snapshot |
| `sec_nvidia_2022-07-31_10-q-retry.html` | 200 / `text/html`, gzip transfer bytes | 151,972 | `27ca7b57a6385a37e06973b3ad1ff2285ffda2ea4ea2c12d4abb31a2eee66f02` | transport duplicate, not corroboration |
| `sec_nvidia_2022-07-31_10-q.html` | 403 / `text/html` | 4,818 | `e97163e32bbb0f0f16b7a6f598743841c8005c738972a23e7cf1dcdc4b8dc204` | failed-request response, not evidence |

第一次在 sandbox 中请求 Matrix Guide 时，`curl` 返回 exit 6 `Could not resolve host: docs.nvidia.com`。这是 sandbox network/DNS denial，不是来源不存在、审批被用户拒绝或模型无法执行。按规则改用只读网络权限后成功捕获 200 body。SEC 首次通用请求返回 403，分类为 remote service access-policy response；使用符合 SEC 要求的 identifying User-Agent 重试后得到 200。这两个失败都已写入 `_assets/logs/capture-attempts.csv`，没有被误当成负证据。

末次尝试以 `git status` 审核写入边界时，当前主线根返回 `not a git repository`。这是当前工作根的 repository-state 不适用，不是 sandbox denial、审批失败、远程服务错误或交付文件失效。写入边界改用精确路径目录和逐字节 hash 校验；manifest 的 11 行 payload/header 尺寸与 SHA-256 全部通过，结果见 `_assets/logs/asset-integrity-check.txt`。

## 下一版原子 staging 的必要顺序

先由合同 builder 生成 expected-pair 全集和 exact candidate decision，再将本报告的 15 个增量 pair 按 target/field join 入；任何不在本增量表中的 pair 都不得被默认删除。其次注册新 source family/version/actual endpoint，将 Matrix 三条正 assertion、108-SM 拒绝行、六个 benchmark search 与 market/positioning search 拆成原子行。然后才能生成 requirement evidence、source role 和 GA100 object-scope selection run。最后执行逐 family 反向移除、coverage manifest 与独立复核。

本报告不运行 Windows 三道 hard gate，因为它没有改动正式数据，也不声称正式发布门已经通过。

## 文本复核

`report-humanizer` 已对本单文件执行机器扫描，结果为 `No machine-detectable AI tells found. Manual reverse-audit still required.`，原始输出已保存到 `_assets/logs/report-humanizer-scan.txt`。人工逆序复读从下一版顺序、快照完整性、反向移除、family 裁决、endpoint 目录、release/Ampere 三 pair、market access、benchmark search、MLCommons、utilization-limit、candidate 表回到开头结论，重点核对了 128/108 SM、A100 product/full GA100、component fact/workload benchmark、source version/actual endpoint/family、`not_found`/`pending_verification`、以及“增量 pair 表”与“coverage manifest”的边界。没有发现需要修正的模板口号或责任主体漂移；剩余风险是 builder、formal ingestion 和 independent approval 尚未执行，不是本报告可以代替的文本问题。
