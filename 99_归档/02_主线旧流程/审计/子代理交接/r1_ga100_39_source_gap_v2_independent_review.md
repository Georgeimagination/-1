# GA100 来源缺口 v2 独立验收

状态：`accept`

验收日期：2026-08-21。本轮把 `r1_ga100_37_source_gap_remediation_v2.md` 作为“下一版原子 staging 的来源裁决输入”验收。按这个交付边界，内容可以接收；若把它解释成已经完成 requirement closure、正式入库或发布门，则裁决为 `reject`。本轮只新增本报告，没有修改 r37、同名 `_assets/`、既有 staging、正式 CSV、资料卡或进度文件。

## 验收裁决

r37 已经关闭 R35 指出的三类内容缺口。Matrix Guide 给出了可直接定位的 alignment、small GEMM tile tradeoff 和 tile quantization 限制，并把 A100 108-SM wave quantization 留在产品启用配置；六个 benchmark exact GA100-die pair 均明确 `include/not_found`，MLCommons 固定提交只承担错误主体检索闭合；SEC 10-Q 只支持 A100/H100 integrated circuits 及相应系统的市场准入约束；Ampere architecture 的 design objective、target use 和 vendor positioning 三个 pair 均有白皮书直接原文。release date 也继续遵守 R13 的 deferred 处理。

没有发现需要退回 r37 重做的内容 blocker。当前 blocker 都位于它明示的后续阶段：合同 builder 尚未生成 expected-pair 全集，逐 endpoint 的 search/result 原子行尚未实施，GA100 对象和新增来源尚未进入正式库，object-scope selection 与逐 family 反向移除尚未运行，release-date 语义迁移仍未执行，Windows 三道 hard gate 也没有运行。接受本报告不能改变这些状态。

| 验收层 | 独立裁决 | 当前边界 |
|---|---|---|
| 来源内容与对象边界 | `accept` | 新证据能够支撑 r37 的增量裁决，未发现 A100 product、full GA100 design、Ampere architecture 和 system-under-test 混写。 |
| expected-pair 合同 | `blocked_not_implemented` | 15 行只是增量；没有 builder 全集、candidate set-equal 或正式 `closure_count`。 |
| 原子来源与负证据链 | `blocked_not_implemented` | 固定字节可用，逐 source/version/actual-endpoint 的正式 assertion、search result 和 requirement evidence 尚未建立。 |
| 正式入库与 selection | `not_ingested` | 正式库没有 GA100/R37 对象、组件、来源、endpoint、requirement 或 object-scope selection run。 |
| Windows 发布门 | `not_run` | 当前环境没有 `pwsh`、`powershell` 或 `powershell.exe`；本轮也没有正式数据变更。该项不能写成通过或失败。 |

## 输入与复算范围

必读输入包括主线 `AGENTS.md`、R35、r37、R13 release-date 语义审计、R29 official-web v2 独立验收、r37 同名 `_assets/` 中的 manifest、family map、11 个 payload、11 个 headers 和 capture logs。另行读取了正式 `objects.csv`、`object-relations.csv`、`components.csv`、`fields.csv`、`facts.csv`、`field-requirements.csv`、source family/version/endpoint 注册表、search 表和 selection 表，并从正式 Ampere 白皮书 PDF 直接抽取 viewer p.11 与 p.38。

处理对象严格分为四层：`OBJ-NVIDIA-GA100-DIE` 是 full 128-SM GA100 design；`COMP-R1-GA100-TENSOR` 是拟议 on-die Tensor/GEMM component；A100-SXM4-80GB、A100 PCIe 和 A100 integrated circuit 是产品或测试载体；DGX A100 加主机和软件栈是 system-under-test。`OBJ-NVIDIA-AMPERE-ARCH` 只承接架构主语原文。

## 11 组 body 与 headers 的机械验算

我从磁盘重新枚举文件并逐项计算 byte count 与 SHA-256，没有采用 r37 的 integrity log 作为验收结果。manifest 有 11 个唯一 asset ID；payload 目录恰有 11 个文件，headers 目录也恰有 11 个文件，两边路径集合都与 manifest set-equal。11 个 body 共 2,750,222 bytes，11 个 headers 共 15,204 bytes；body hash 与 header hash 各自均无重复，逐行结果全部相等。证据资格分布为 8 个 canonical snapshot、2 个 duplicate endpoint 和 1 个 failed attempt。

| asset | HTTP | body bytes / SHA-256 | header bytes / SHA-256 | 端点分类 |
|---|---:|---|---|---|
| `GA100R37-MATRIX-HTML` | 200 | 326,039 / `c4a8e64475bce019738c6cf9067ecc9cac8348e2c67cdc7fe056eddeda00c790` | 2,070 / `8e35d0c902a09e477847bb1cea451d961737cddeaf178acfd024ac44c0b70fcf` | canonical content snapshot |
| `GA100R37-MLC-COMMIT-API` | 200 | 2,872 / `b6bf83b065d52716b21aa98c166650d67b543be844b1214267cf68127b241a14` | 1,326 / `2265327add12008af512356b6d5d53432b32176f8dc000b6375d22bb21a25115` | canonical identity endpoint |
| `GA100R37-MLC-COMMIT-HTML` | 200 | 393,000 / `5c73adfe1b1ea0f58c4dfe22ac19de4e2a4a2098c52ce21e22d57aac37c1210a` | 5,068 / `5c67187119a2a0a13d4977c4e7a39c7ad83d15685e9459000d3ab360d7b06b2f` | duplicate identity view |
| `GA100R37-MLC-SYSTEM` | 200 | 1,711 / `165899d99b7fd835e2692b710053c8b86275a453aba35131146d2337e62de1ff` | 902 / `f4e8ab83673ed92eb745437e5664bed0a3ae93396fafd8788a7977d094348797` | canonical content endpoint |
| `GA100R37-MLC-OFFLINE-SUMMARY` | 200 | 1,594 / `b3d290da496e8c76eee37f8fa1140bf73d258784418f1da638ae4eac6d95b1ef` | 902 / `5122799ccfa8ce4a731dc355ed91c4f2845b86d599f1a9bd4e97896ec2e83951` | canonical content endpoint |
| `GA100R37-MLC-SINGLE-SUMMARY` | 200 | 1,864 / `0db37d68fc0641abdb4ed32f0c1439a454c997104e9b0b350825330f3ddff8b1` | 902 / `fdc761c22d06c5e950d481a7b161bb14ea0c77f5f223439bdbc6d9ef0cc8e29c` | canonical content endpoint |
| `GA100R37-MLC-OFFLINE-DIR` | 200 | 2,467 / `09c1c63115de96400e78ad7c615ead3e0ca64dd33ad64efe1c361777abd44dc1` | 1,301 / `f69ae755706011b83ff84163ba9fc55e9f996f0c6d4eab03cd4612d1aa3c301c` | canonical directory manifest |
| `GA100R37-MLC-SINGLE-DIR` | 200 | 2,709 / `1037e0dde1c48b5596a51e0b8384b917bd9298232c5243bd94fc2a2a25ba9d5c` | 1,301 / `7e225720c78c2dd4c79d00cf2ea99ea970a25c8b75e857dbd17c5259c46d6569` | canonical directory manifest |
| `GA100R37-SEC-10Q-CANONICAL` | 200 | 1,861,176 / `3fcc8e3277e625bafe4a4645b03c3f3d3a040e96373ef9adf09b6eabd4ba15dd` | 532 / `bd43298068e1156d840b857fa459916ee80f6db632bd177636051c13efc5d743` | canonical content snapshot |
| `GA100R37-SEC-10Q-GZIP-RETRY` | 200 | 151,972 / `27ca7b57a6385a37e06973b3ad1ff2285ffda2ea4ea2c12d4abb31a2eee66f02` | 625 / `27ccfaef736d88df6ca0697459c429bc9febf70d17745e8344865f95cde22aea` | transport duplicate |
| `GA100R37-SEC-10Q-403` | 403 | 4,818 / `e97163e32bbb0f0f16b7a6f598743841c8005c738972a23e7cf1dcdc4b8dc204` | 275 / `90f52196a70af38337e8906568333b0cb8987b6ed0f53c90655cd4ac79613cd5` | failed request, no evidence qualification |

所有 manifest 行均满足 `requested_url == final_url`。Matrix 使用同一个 NVIDIA Docs URL；MLCommons 的 commit API、commit HTML、raw system/result 文件和两个 contents API 入口全部固定到 commit `36d324b502175621063a478fcbf6d2cb9421ca34`；三次 SEC 尝试使用同一个 filing URL。10 行状态为 200，SEC 初次通用请求为 403。每个 header 的末个 HTTP 状态和 Content-Type 均与 manifest 相同；有 Content-Length 的行也与 body bytes 相等。

SEC gzip body 独立解压后是 1,861,176 bytes，逐字节等于 canonical HTML，解压后 SHA-256 也是 `3fcc8e3277e625bafe4a4645b03c3f3d3a040e96373ef9adf09b6eabd4ba15dd`。因此它只能是 transport duplicate。403 body 的标题和正文明确说明 undeclared automated tool access policy，属于 remote service access-policy response，不能参加来源缺失证明。capture log 中 Matrix 首次 `curl` exit 6 的归类是 sandbox network/DNS denial；这些都是 r37 留下的历史尝试记录，本轮没有重新发起网络请求，也没有遇到新的 sandbox 或审批失败。

## source family、actual endpoint 与重复项

`source-family-map.csv` 有 7 行。前三个新 family 对 11 个 manifest asset 恰好覆盖一次：Matrix 1 个 asset；MLCommons 固定 commit 7 个 asset；SEC filing 3 个 asset。三者之间没有 asset 重复归属。

MLCommons 的 commit API 与 HTML 只是同一提交的两个 identity 视图；system JSON、两份 result summary 和两个 directory manifest 是同一 source version 下的不同 actual endpoint，不能计成六份独立来源。commit API 直接给出 commit SHA 与 tree SHA `c3d2a5adfda50a1cde7ebec7896fe0ab6ceea526`。SEC 的 canonical HTML、gzip transfer bytes 与 403 response 也只属于一份 filing source version，只有 canonical HTML 具备内容证据资格。

family 去重政策与 R29、official-web v2 map 一致：Newsroom HTML/PDF 是一个 publication family，两个 Product Brief 是一个 family 下的两个产品版本，MIG `latest`、supported-GPUs、r580 PDF 与旧 r610 章节归入一个 MIG User Guide family；PTX 7.0/7.2 是一个 revision family；cuSPARSELt User Guide 与 Release Notes 分属两个 work family；TensorRT Release Notes、Support Matrix 和 Developer Guide 继续保持三个 family。

该 CSV 对 11 个新 asset 已可机械 join，但后四个 legacy family 行仍使用 `versioned_guide_endpoints`、`existing_official_web_v2_rows` 这类说明性占位值，没有列出正式 source/version/endpoint ID。这不影响 r37 作为裁决输入被接收，下一版原子 staging 必须把这些占位值替换为 exact ID 集合，才能参加 set-equal、selection 和 reverse removal。

## Matrix utilization-limit 的对象与条件

Matrix Guide §2.2 的直接原文说明，Tensor Core 使用要求随 library 版本变化；cuBLAS 11.0 起非对齐尺寸仍可使用 Tensor Cores，但尺寸对齐时效率更高。A100 对应的最佳效率倍数为 INT8 128、FP16 64、TF32 32、FP64 16 elements。该值必须带 datatype 与 library-version 条件。

§2.3 直接说明大 tile 有较高复用和 tile efficiency，小 tile 提供更多 tile parallelism；GEMM 太小时，两者任一损失都可能使 GPU 无法达到 peak math utilization。Figure 3/4 的载体与软件条件确为 A100-SXM4-80GB、CUDA 11.2、cuBLAS 11.4。§3.1 又说明矩阵维度不能被 thread-block tile 整除时，边界 tile 仍执行同量 math，造成无效工作；Figure 7 使用同一载体和软件，tile 为 256x128。

这些原文可以进入 `COMP-R1-GA100-TENSOR / FIELD-COMP-UTILIZATION-LIMIT`，但事实文本必须保留 A100 carrier、CUDA/cuBLAS、datatype、矩阵尺寸和 tile 条件。它们支撑的是 alignment、small GEMM、tile parallelism/efficiency 与 tile quantization，不支撑 full-GA100 无条件利用率值。

§3.2 明写 A100 有 108 SM，256x128 tile 下 wave size 为 108；117 tiles 形成一个 full wave 和一个 9-tile tail wave，后者只使用 9/108 的 A100 SM。r37 拒绝将该定位下放给 full GA100 128-SM design 的处理正确。下一版仍需把这个拒绝写成实际 endpoint 上的 `checked_no_support` 或 rejected assertion，不能只保留报告文本。

## 六个 forced benchmark pair

增量表中六个 exact pair 均为 `include/not_found`，没有走 bare-die exclusion、`not_applicable` 或未登记的 no-reachable-subject 路径。六个 search ID 也逐一给出。内容裁决如下。

| exact pair | 内容复核 | 原子链状态 |
|---|---|---|
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-LATENCY` | HPEC cycle 是错误 metric/unit；Matrix 是 A100 GEMM component measurement；MLCommons SingleStream 的 1,551,870 ns 属于 DGX A100 system-under-test。`not_found` 方向成立。 | endpoint 范围已列明，正式 `search-log/search-results` 未实施。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-THROUGHPUT` | HPEC Table III 缺 operation-count rule；RAND 与 Matrix 都是 A100 条件化 microbenchmark；MLCommons Offline 的 3560.73 samples/s 是系统级 BERT-99。`not_found` 方向成立。 | 同上。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-POWER` | A100 TDP/nameplate 不能充当 workload power；MLCommons system 的 power 字段为空，选定 Offline 与 SingleStream 目录各只有 `accuracy`、`performance` 两个 child。结论只覆盖这两个目录。 | 两个 directory endpoint 已固定，正式逐 endpoint result 未实施。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-ENERGY-PER-TOKEN` | 没有同 scope token workload 与 energy measurement，MLCommons 使用 samples 且没有相应 power child，不能派生 J/token。 | 正式逐 endpoint result 未实施。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-TOKENS-PER-JOULE` | 没有直接 token/J，也没有可合法组合的同 scope token throughput 与 energy/power input。 | 正式逐 endpoint result 未实施。 |
| `OBJ-NVIDIA-GA100-DIE / FIELD-BENCH-UTILIZATION` | Ampere strong scaling 是 design objective；HPEC `Measured-theoretical`、RAND `full-speed` 和 Matrix peak-math utilization 都不等于完整模型 MFU/HFU/MBU 或 scaling efficiency。 | 正式逐 endpoint result 未实施。 |

MLCommons 条件核对通过。system JSON 的对象是 `NVIDIA DGX A100 (1x A100-SXM-80GB, TensorRT)`，1 node、1 accelerator、80 GB HBM2e，主机为 2 颗 AMD EPYC 7742 和 2 TB memory；软件为 TensorRT 8.4.0、CUDA 11.6、cuDNN 8.3.2、Driver 510.39.01、DALI 0.31.0。Offline summary 的 VALID 值为 3560.73 samples/s；SingleStream 的 VALID 90th-percentile latency 为 1,551,870 ns，即 0.001551870 s。固定提交、系统/SKU、host、software 与数值只能形成 wrong-subject closure，不能写成 GA100 die benchmark value。

每个 benchmark 表都把实际检查的内容 endpoint 列入 source range，并把 Newsroom PDF mirror 标为对 HTML 的 `duplicate`。commit API/HTML 只承担 source identity，不需要伪写成 benchmark 内容检索结果。official-web v2 的其余 22 个成功 endpoint 没有被写成“全部已搜”，而是留作非 benchmark candidate screening；该边界正确。由于还没有一行一 endpoint 的正式 result，六条链当前可称为“内容计划闭合”，不能称为“发布性原子闭合”。

## market access、release date 与 Ampere 三个 pair

SEC canonical payload 的 `Item 1A. Risk Factors` 直接写明，2022-08-26 起的新 license requirement 覆盖未来向中国及香港、俄罗斯出口的 A100 和 forthcoming H100 integrated circuits，也覆盖包含 A100/H100 的 DGX 或其他系统及 A100X。原文没有 GA100 codename，也没有把约束写给 full 128-SM GA100 design。A100 产品到 GA100 的 identity bridge 没有 market-access 投影权。因此 SEC 对 A100/H100 是正证，对 GA100 exact pair 只能是 `checked_no_support: wrong_subject`；r37 将 `OBJ-NVIDIA-GA100-DIE / FIELD-ID-MARKET-ACCESS-CONSTRAINT` 裁为 `not_found` 的方向可接收，正式负证据链仍待实施。

release date 保持 R13 的裁决。正式 `fields.csv` 仍写“首次发布日期；具体对象日期，不用架构预告代替”，R13 又明确要求 `REQ-R1-GA100-V2-ID-RELEASE-DATE` 继续 `pending_verification`，并禁止在全库语义迁移前生成 GA100 release-date fact。Technical Blog 的 `datePublished=2020-05-14` 只能证明该日已有一份直接命名 GA100 的官方材料，不能在旧合同下直接等同为 GA100 release date。r37 没有提前发布该值。

Ampere architecture 三个正值均有直接证据。白皮书 viewer p.38 的主语明确是 NVIDIA Ampere architecture，写明它 targets strong scaling，以 fixed workload per GPU 加速 existing deep neural networks；这分别支撑 design objective 与保守限定的 target-use positioning。viewer p.11 又直接写 Ampere architecture 改善 ease of programming、降低 latency 和 AI/HPC software complexity，并相对 Volta 提高 performance per watt，足以支撑 vendor positioning。三条原文都不能复制给 GA100 die 的同名 pair。

## 15 行增量与正式基线

我机械解析 r37 的增量表，得到 15 个唯一 exact target/field pair，全部 `include`；状态分布为 4 个 `value_available`、10 个 `not_found`、1 个 `pending_verification`。其中 benchmark 恰为 6 行，Ampere architecture 正值恰为 3 行。表前后都明确写明它不代表 GA100/Ampere builder 全集，不得把 15 写入 `closure_count`，且 deployment、availability、status、price、die-count 等未重裁 pair 仍须由 builder 生成。这个边界通过验收。

正式数据仍是 78 个 object、27 条 object relation、270 个 component、141 个 field、798 条 fact、1,059 条 field requirement、92 个 source family、93 个 source version、153 个 endpoint、11 个 selection run 和 106 个 selection member。`fields.csv`、`facts.csv`、`field-requirements.csv` 与 `fact-assertions.csv` 的 SHA-256 仍分别为 `9e01cdb3bbd5db9dbdab0763db7b85a57c7bd055436ccdff1e88ad0f737b0233`、`24addee6816046f5d3d1651cc4fc54e62e536a13d360c27c04bd833a89384871`、`7f84f6109d3a362bdf6beae395e6213bc2aefcfb0244ab7d4440680b0c8cf9a3` 和 `284489effdbfda10a37da139ded2d68c1608004fbc93336c0cd1ff023d5dab33`，与 R13/R35 使用的 preimage 一致。

正式表中不存在 `OBJ-NVIDIA-GA100-DIE`、`COMP-R1-GA100-*`、`GA100R37`、`R1GA100` 或 r37 的拟议 search ID。正式相关来源仍只有 `SRC-M2NA-NVIDIA-AMPERE-WP-2020` 及其 local/remote endpoint；Ampere 三个新增 identity pair 也没有 fact 或 requirement。现有 `SELRUN-M2NA-ARCH-20260812` 面向旧的 M2 architecture fact set，不能证明本轮新增 value 与 negative-search obligation 的最小性。

跨平台恢复检查通过：`formal_tables=32; endpoint_rows=153; local_paths=79; hashes_checked=79; selection_runs=11; selection_members=106`。这只能证明现有正式恢复链未被本轮写入破坏，不能替代 Windows `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1`。

## 后续实施条件

下一版先由批准合同和 reachable target 生成 expected-pair 全集，并和 candidate decision 双向 set-equal，再把这 15 行按 exact key 加入，不能覆盖或删除表外 pair。随后把 family、source version、actual endpoint、Matrix 三条正 assertion、108-SM 拒绝行、六个 benchmark search、market/positioning search 及每个实际 endpoint 的 `checked_no_support` 或 `duplicate` 拆成原子记录。

这些行稳定后再建立 GA100 object-scope selection run。反向移除必须逐 family 重算 value 支持、endpoint result 与 `no_reliable_result` 的计划范围；SEC 与 MLCommons 在相应 `not_found` 正式闭合前不能移除。release-date pair 继续 pending，等待独立语义迁移。正式事务写入后再在 Windows 运行三道 hard gate，并由不同作者复核 postimage。

尚未核实或未发布的字段包括本报告之外的 builder 全集、六个 benchmark 的正式 `not_found`、GA100 market-access、release date、GA100 die 三个 identity positioning pair，以及 deployment、availability、status、price、die-count 等由最新合同决定的 pair。已筛除或降级的材料包括 Newsroom PDF mirror、MLCommons commit HTML 和 SEC gzip body，原因均为重复 endpoint；SEC 403 response 是失败请求；A100/DGX/MLCommons 数值、Product Brief 和产品发布页因对象或范围不匹配只作 negative-search evidence；Matrix §3.2 因 108-SM enabled scale 不进入 full GA100 值。

## 交付与文本检查

唯一写入文件是 `审计/子代理交接/r1_ga100_39_source_gap_v2_independent_review.md`。本轮没有工具中断、用户拒绝、审批失败、sandbox denial、远程服务错误或 operator mistake。PowerShell 缺失属于本机 tool/runtime limitation；Windows 门保持 `not_run`。

本文按工程审计文档处理。`report-humanizer` 机器扫描针对本文件单独运行；人工逆序复读从交付与文本检查、后续实施条件、正式基线、15 行增量、Ampere/market/release、六个 benchmark、Matrix、family、asset 复算回到验收裁决，重点复核了 11/10/1、8/2/1、2,750,222、15,204、128/108 SM、15/6/3、固定 commit、SEC 主体和正式未入库边界。
