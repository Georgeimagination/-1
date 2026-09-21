# GA100 工作包复用 Ampere 正式事实修复审计

> 子任务：`r1_ga100_06_ampere_formal_fact_repair_audit`  
> 状态：完成，待总控复核和正式 staging  
> 审计对象：`OBJ-NVIDIA-AMPERE-ARCH` 现有 21 条事实、21 条 `value_available` requirement 和 21 条 gap requirement  
> 写入边界：本轮只新增本审计报告，没有修改正式 CSV、资料卡或进度文件

## 审计结论

现有 Ampere 包可以作为 GA100 工作包的架构复用基础，但不能原样复用。21 条事实中，12 条事实值可保留，其中 8 条需要把 assertion 定位移到更强的 Table 3 或补充作用域说明；8 条需要改字段、改事实值或改条件；`FACT-M2NA-AMPERE-TENSOR-FORMATS` 应删除并由 precision path 事实替代。正式修复还需新增 2 条 precision path、20 条事实、20 条对应 requirement、至少 21 条 assertion，并修订 1 个、增加 5 个 condition set。

最急的四项错误是：白皮书 Figure 7 没有直接写 `SIMT`，当前事实却把它写成单一来源直接陈述；Tensor format 列表被误放进 `FIELD-COMP-SHARED-RESOURCE`；async copy 被误放进执行模型字段；稀疏事实把软件 pruning 后的压缩权重和硬件依据 metadata 选择对应 dense activation，写成了硬件在运行时“从四个值中挑两个非零值”。这四项若不先修，GA100 资料卡会沿用错误的来源层级和字段语义。

正式输入目前没有 `OBJ-NVIDIA-GA100-DIE`，也没有 GA100 到 `OBJ-NVIDIA-AMPERE-ARCH` 的 `implements_architecture` 关系。因此本报告只裁决架构事实，不为 GA100 预填 128 SM、54.2B、826 mm²、A100 峰值、HBM 或 MIG 数量。GA100 对象和关系应由总控在单芯片事务中建立。

## 证据层级和待注册来源

现有正式来源 `SRC-M2NA-NVIDIA-AMPERE-WP-2020` 可以继续支撑 Tensor Core、数值路径、async copy、Sparse MMA 和 NVLink 3；其规范本地端点是 `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`，SHA-256 为 `3a800ad7668ec37037fa5870a8e3bb681b75f19668b3d11492ab9b0da0d58815`。但该来源不能单独把 Figure 7 的资源标签提升为 `SIMT` 直接陈述，也不能给出 datatype-specific sparse metadata 规则。

以下 ID 是本修复包建议预留的精确新 ID。CUDA 官方阅读卡没有保存网页快照或哈希，正式写入前必须先固定内容版本并补齐 `content_fingerprint`；在此之前，引用这些 ID 的新事实只能进入 staging，不能进入 accepted 正式库。

| 新 PK | 层级 | 版本和职责 | 官方定位 |
|---|---|---|---|
| `SFAM-R1-NVIDIA-PTX-ISA-7X` | source family | PTX ISA 7.x revision series | NVIDIA CUDA archive |
| `SRC-R1-NVIDIA-PTX-ISA-7-0-20200804` | source | PTX ISA 7.0；SIMT、`cp.async`、`mbarrier`、`sm_80` | PTX 7.0 §2.2.1、§3.1、§9.7.8.16、§9.7.12.11 |
| `SRC-R1-NVIDIA-PTX-ISA-7-2-20210209` | source | PTX ISA 7.2；`mma.sp`、metadata、datatype-specific sparsity | PTX 7.2 §9.7.13.5、§9.7.13.5.1、§9.7.13.5.2、§12.2 |
| `END-R1-NVIDIA-PTX-ISA-7-0-ARCHIVE`、`END-R1-NVIDIA-PTX-ISA-7-2-ARCHIVE` | endpoint | 对应 NVIDIA archive HTML；获取后保存固定副本和哈希 | CUDA Toolkit 11.0.3、11.2.1 archive |
| `SFAM-R1-NVIDIA-CUDA-PG-11X` | source family | CUDA C++ Programming Guide 11.x revision series | NVIDIA CUDA archive |
| `SRC-R1-NVIDIA-CUDA-PG-11-0-20200804` | source | CUDA 11.0 async copy、split barrier、experimental 状态 | §B.23、§B.24，PDF pp.203-225 |
| `END-R1-NVIDIA-CUDA-PG-11-0-PDF` | endpoint | CUDA 11.0 固定 PDF；获取后记录页数和哈希 | `PG-02829-001_v11.0` |

同一家族的不同 revision 不能增加独立来源计数。ISSCC 2021 论文可在 GA100 物理事实包注册，但本轮 precision path 修复由白皮书 Table 3 已经覆盖，不需要为了增加来源数而把它强行加入 Ampere 最小集。

## 动作一：修正 SIMT 来源层级

| 项目 | 精确内容 |
|---|---|
| 受影响 PK | `FACT-M2NA-AMPERE-SM-EXEC`、`ASSERT-M2NA-0001`、`REQ-M2NA-AVAIL-0001`、资料卡当前第 15 行；`FACT-M2NA-AMPERE-CUDA-EXEC`、`ASSERT-M2NA-0004`、`REQ-M2NA-AVAIL-0004`、资料卡当前第 18 行 |
| 现值 | SM：`SIMT Streaming Multiprocessor with separate CUDA ALU, Tensor Core, load-store, special-function and control resources.`；CUDA path：`Per-thread SIMT FP32 and integer ALU execution path.`；两条均为 `direct_statement / single_source / COND-NONE` |
| 建议值 | SM 改为 `SIMT execution model with warp-level scheduling and instruction issue in the public CUDA/PTX machine model.`；CUDA path 改为 `FP32 and INT32 ALU datapaths execute CUDA threads under the SM SIMT warp model; no aggregate scalar peak is implied.` |
| 事实主体、字段、条件 | 主体分别是 `COMP-M2NA-AMPERE-SM`、`COMP-M2NA-AMPERE-CUDA`；字段继续使用 `FIELD-COMP-EXECUTION`；条件保留 `COND-NONE`，但 notes 必须写明这是公开 CUDA/PTX machine model 与 GA100 Figure 7 的组合，不是 scheduler RTL，也不代表所有 Ampere SKU 有同样资源数量 |
| 来源与定位 | `SRC-R1-NVIDIA-PTX-ISA-7-0-20200804`，PTX 7.0 §3.1：SIMT multiprocessor、warp 和 ready-warp issue；`SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.22 Figure 7：GA100 SM 的 warp scheduler、dispatch、FP32/INT32、Tensor Core、LD/ST、SFU 标签 |
| assertion 同步 | `ASSERT-M2NA-0001` 改为 `qualifies`，notes 明确 Figure 7 只锚定 GA100 结构、不直接写 SIMT；新增 `ASSERT-R1-GA100-AMPERE-SM-SIMT-PTX70`。`ASSERT-M2NA-0004` 保留为 Figure 7 的 FP32/INT32 结构断言；新增 `ASSERT-R1-GA100-AMPERE-CUDA-SIMT-PTX70`，其 `assertion_mode=inferred`，因为 generic PTX model 到该 Ampere component 的绑定依赖 GA100/CC8.0 证据链 |
| requirement 与卡片同步 | `REQ-M2NA-AVAIL-0001` 保留。`REQ-M2NA-AVAIL-0004` 保留并在证据链完成后由 `needs_resolution` 收敛为 `reviewed`。资料卡两行替换事实值和双来源定位，术语段保留 SIMT 首次解释 |
| 不修正的后果 | 会把项目分类词当成白皮书原文，错误地形成“单一来源直接证明 SIMT”的证据链；GA100 复用时还会把公开编程模型误写成调度仲裁、scoreboard 或物理发射实现 |

## 动作二：删除错误的 Tensor format 共享资源事实

| 项目 | 精确内容 |
|---|---|
| 受影响 PK | `FACT-M2NA-AMPERE-TENSOR-FORMATS`、`ASSERT-M2NA-0003`、`REQ-M2NA-AVAIL-0003`、资料卡当前第 17 行 |
| 现值 | 主体 `COMP-M2NA-AMPERE-TENSOR`，字段 `FIELD-COMP-SHARED-RESOURCE`，值 `FP16, BF16, TF32, IEEE FP64, INT8, INT4 and binary matrix formats.`，条件 `COND-NONE` |
| 建议值/新 ID | 删除该 fact、assertion 和 requirement，不把 format 列表迁移到另一个 component 字段。格式由现有和新增 precision path 的 A/B/accumulator 事实承接；来源中 p.20 的格式总览只保留在卡片引导文字或 component notes，不再充当原子事实 |
| 事实主体、字段、条件 | 删除后不产生替代 component fact。`FIELD-COMP-SHARED-RESOURCE` 的定义是发射、寄存器、存储端口或功耗等共享资源，不是 datatype 枚举 |
| 来源与定位 | 被删除 assertion 的原始来源仍是 `SRC-M2NA-NVIDIA-AMPERE-WP-2020`，PDF p.20；precision path 改用更强的 PDF p.27 Table 3 |
| 同步范围 | 删除 `ASSERT-M2NA-0003`、`REQ-M2NA-AVAIL-0003` 和资料卡 fact 行；在卡片“数据格式、累加与稀疏语义”中增加本报告动作四、动作五列出的新 precision path 行 |
| 不修正的后果 | component 层会把 datatype 当成共享微架构资源；后续 completeness 查询会误判 `FIELD-COMP-SHARED-RESOURCE` 已覆盖，并掩盖真正缺失的端口、寄存器或发射共享约束 |

## 动作三：把 async copy 从执行模型迁到搬运字段，并拆出 barrier

| 项目 | 精确内容 |
|---|---|
| 受影响 PK | `FACT-M2NA-AMPERE-ASYNC-EXEC`、`ASSERT-M2NA-0005`、`REQ-M2NA-AVAIL-0005`、资料卡当前第 19 行；新增 `FACT-R1-GA100-AMPERE-BARRIER-SCHED`、`ASSERT-R1-GA100-AMPERE-BARRIER-WP`、`REQ-R1-GA100-AMPERE-BARRIER-SCHED` |
| 现值 | `FIELD-COMP-EXECUTION = Asynchronous global-memory to shared-memory copy without register-file staging, paired with asynchronous barriers.`，主体 `COMP-M2NA-AMPERE-ASYNC-COPY`，`COND-NONE` |
| 建议值 | 原 fact 保留 PK，但字段改为 `FIELD-MEM-DMA`，值改为 `Hardware-accelerated asynchronous copy from global memory to shared memory without intermediate register-file staging; L1 bypass depends on the copy/cache variant.`；新 barrier fact 使用 `FIELD-COMP-CONTROL-SCHEDULING`，值为 `Hardware-accelerated split arrive/wait barrier in shared memory can synchronize a thread subset within a block and integrate with asynchronous copy.` |
| 事实主体、条件 | copy 主体继续为 `COMP-M2NA-AMPERE-ASYNC-COPY`；barrier 主体为 `COMP-M2NA-AMPERE-SM`；硬件机制均使用 `COND-NONE`。软件版本和 `sm_80` 限制放在动作六的软件事实中，不污染硬件机制事实 |
| 来源与定位 | copy：白皮书 PDF p.21、Figure 15 p.40、pp.61-62 Figure 31；barrier：PDF p.17、pp.63-64 Figure 33。`cp.async` 的方向、4/8/16-byte、alignment 和 wait 规则由 PTX 7.0 §9.7.8.16 或 CUDA PG 11.0 §B.24 作为限定 assertion，不写进无条件硬件事实 |
| assertion 同步 | `ASSERT-M2NA-0005` 的 fact_id 不变，重新生成 fingerprint，locator 可扩为 `PDF p.21; Figure 15 p.40`；新增 `ASSERT-R1-GA100-AMPERE-BARRIER-WP`。若接受 ISA 限制，再新增 `ASSERT-R1-GA100-AMPERE-ASYNC-PTX70`，relation=`qualifies` |
| requirement 与卡片同步 | `REQ-M2NA-AVAIL-0005` 保留 PK，但 field_id 和 fingerprint 改为 `FIELD-MEM-DMA`；新增 `REQ-R1-GA100-AMPERE-BARRIER-SCHED`。资料卡把 copy 移入存储/数据搬运表，barrier 放入执行控制或特殊能力表 |
| 不修正的后果 | 会把定向数据搬运误当成 execution model，并把 `global→shared` 专用指令夸大为通用 DMA、双向 copy engine 或任意张量搬运；barrier 的同步职责也会继续与 copy 混成一个不可核验原子事实 |

`FACT-M2NA-AMPERE-ASYNC-LEVEL`、`ASSERT-M2NA-0019`、`REQ-M2NA-AVAIL-0019` 保留。它们只说明专用指令层级，不说明 copy engine 数量、队列深度、吞吐或延迟。

## 动作四：补齐 A/B/accumulator，并拆分整数路径

白皮书 PDF p.27 Table 3 是当前最强的 input operand/accumulator 证据。这里的 accumulator 是程序员可见 C/D 类型，不是隐藏的物理累加器位宽。

### 现有事实的保留与修正

| 事实 PK | 动作 | 现值 | 建议值、字段与条件 | assertion / requirement / 卡片同步 | 不修正的后果 |
|---|---|---|---|---|---|
| `FACT-M2NA-AMPERE-FP16-A` | 保留 | `FP16` | 不变；`PPATH-M2NA-AMPERE-TENSOR-FP16 / FIELD-NUM-OPERAND-A / COND-NONE` | `ASSERT-M2NA-0008` locator 改为 p.27 Table 3；保留 `REQ-M2NA-AVAIL-0008`；更新卡片当前第 33 行 | 只影响定位强度，不改值会造成的语义风险低 |
| `FACT-M2NA-AMPERE-FP16-B` | 保留 | `FP16` | 不变；`FIELD-NUM-OPERAND-B` | `ASSERT-M2NA-0009` 改到 p.27 Table 3；保留 `REQ-M2NA-AVAIL-0009`；更新卡片第 34 行 | 同上 |
| `FACT-M2NA-AMPERE-FP16-ACC` | 保留 | `FP32` | 不变；`FIELD-NUM-ACCUMULATION` | `ASSERT-M2NA-0010` 改到 p.27 Table 3；保留 `REQ-M2NA-AVAIL-0010`；更新卡片第 35 行 | 若仍只引用 feature bullet，程序员可见 accumulator 的定位不如 Table 3 精确 |
| `FACT-M2NA-AMPERE-BF16-A` | 保留 | `BF16` | 不变 | `ASSERT-M2NA-0011` 改到 p.27 Table 3；保留 `REQ-M2NA-AVAIL-0011`；更新卡片第 36 行 | 低风险定位问题 |
| `FACT-M2NA-AMPERE-BF16-ACC` | 保留 | `FP32` | 不变 | `ASSERT-M2NA-0012` 改到 p.27 Table 3；保留 `REQ-M2NA-AVAIL-0012`；更新卡片第 37 行 | 缺少 B 时路径合同仍不完整 |
| `FACT-M2NA-AMPERE-TF32-A` | 修正 | `TF32 derived from FP32 input` | 改为 `TF32`；转换语义另建 fact；字段仍为 `FIELD-NUM-OPERAND-A` | `ASSERT-M2NA-0013` raw value 改为 `TF32`，locator 改 p.27 Table 3；保留 `REQ-M2NA-AVAIL-0013`；更新卡片第 38 行 | 把来源数据格式和转换过程塞在同一个 operand 字段，无法与 B 对齐 |
| `FACT-M2NA-AMPERE-TF32-ACC` | 保留 | `FP32` | 不变 | `ASSERT-M2NA-0014` raw value 改为 `FP32`，locator 改 p.27 Table 3；保留 `REQ-M2NA-AVAIL-0014`；更新卡片第 39 行 | 当前 raw value `FP32 input/output data` 不是 accumulator 列的精确原值 |
| `FACT-M2NA-AMPERE-FP64-A` | 保留 | `IEEE FP64` | 不变 | `ASSERT-M2NA-0015` 改到 p.27 Table 3；保留 `REQ-M2NA-AVAIL-0015`；更新卡片第 40 行 | p.15 能证明 FP64 指令存在，但不如 Table 3 适合 A/B/accumulator 合同 |
| `FACT-M2NA-AMPERE-INT-A` | 修正 | `INT8, INT4 or binary depending on instruction mode` | 在现有 `PPATH-M2NA-AMPERE-TENSOR-INT8` 上改为 `INT8`；field 保持 `FIELD-NUM-OPERAND-A`；建议同时把 precision path label 改为 `Ampere Tensor Core INT8 matrix path` | `ASSERT-M2NA-0016` raw value 改为 `INT8`，locator 改 p.27 Table 3；`REQ-M2NA-AVAIL-0016` 保留；卡片第 41 行改成 INT8 专属行 | 一个 precision path 混合 INT8、INT4、binary，无法表达不同 accumulator、instruction shape 和 sparse pattern |

### 新 precision path、事实和 requirement

| 新 precision path / fact PK | 事实主体、字段、值、条件 | 来源与定位 | 同步的 assertion / requirement / card 行 | 不新增的后果 |
|---|---|---|---|---|
| `FACT-R1-GA100-AMPERE-BF16-B` | `PPATH-M2NA-AMPERE-TENSOR-BF16 / FIELD-NUM-OPERAND-B / BF16 / COND-NONE` | 白皮书 p.27 Table 3 | `ASSERT-R1-GA100-AMPERE-BF16-B-WP`；`REQ-R1-GA100-AMPERE-BF16-B`；卡片 BF16 A 与 ACC 之间新增一行 | BF16 路径只记录 A，不足以证明同格式双输入 |
| `FACT-R1-GA100-AMPERE-TF32-B` | `PPATH-M2NA-AMPERE-TENSOR-TF32 / FIELD-NUM-OPERAND-B / TF32 / COND-NONE` | 白皮书 p.27 Table 3 | `ASSERT-R1-GA100-AMPERE-TF32-B-WP`；`REQ-R1-GA100-AMPERE-TF32-B`；新增卡片行 | TF32 A/B 合同不完整 |
| `FACT-R1-GA100-AMPERE-TF32-CONVERSION` | `PPATH-M2NA-AMPERE-TENSOR-TF32 / FIELD-NUM-CONVERSION / FP32 input data are converted to TF32 for Tensor Core multiplication; surrounding input/output storage remains FP32. / COND-NONE` | 白皮书 p.26、Figure 9 p.27 | `ASSERT-R1-GA100-AMPERE-TF32-CONVERSION-WP`；`REQ-R1-GA100-AMPERE-TF32-CONVERSION`；新增卡片行 | 会继续把 TF32 编码、FP32 来源数据和输出存储混在 operand 字段 |
| `FACT-R1-GA100-AMPERE-FP64-B` | `PPATH-M2NA-AMPERE-TENSOR-FP64 / FIELD-NUM-OPERAND-B / IEEE FP64 / COND-NONE` | 白皮书 p.27 Table 3 | `ASSERT-R1-GA100-AMPERE-FP64-B-WP`；`REQ-R1-GA100-AMPERE-FP64-B`；新增卡片行 | FP64 双输入合同不完整 |
| `FACT-R1-GA100-AMPERE-FP64-ACC` | 同一 path，`FIELD-NUM-ACCUMULATION / IEEE FP64 / COND-NONE` | 白皮书 p.27 Table 3 | `ASSERT-R1-GA100-AMPERE-FP64-ACC-WP`；`REQ-R1-GA100-AMPERE-FP64-ACC`；新增卡片行 | 会误把“支持 FP64”当成已证明 FP64 accumulation |
| `FACT-R1-GA100-AMPERE-INT8-B`、`FACT-R1-GA100-AMPERE-INT8-ACC` | `PPATH-M2NA-AMPERE-TENSOR-INT8`；分别 `FIELD-NUM-OPERAND-B=INT8`、`FIELD-NUM-ACCUMULATION=INT32`；`COND-NONE` | 白皮书 p.27 Table 3 | `ASSERT-R1-GA100-AMPERE-INT8-B-WP`、`ASSERT-R1-GA100-AMPERE-INT8-ACC-WP`；对应 `REQ-R1-GA100-AMPERE-INT8-B/ACC`；新增两行 | INT8 路径没有 B 和 accumulator，且不能与 INT4 的 sparse pattern 分开 |
| `PPATH-R1-GA100-AMPERE-TENSOR-INT4` + `FACT-R1-GA100-AMPERE-INT4-A`、`FACT-R1-GA100-AMPERE-INT4-B`、`FACT-R1-GA100-AMPERE-INT4-ACC` | component=`COMP-M2NA-AMPERE-TENSOR`，operation=`matrix`；A/B=`INT4`，acc=`INT32`，均 `COND-NONE` | 白皮书 p.27 Table 3 | `ASSERT-R1-GA100-AMPERE-INT4-A-WP`、`ASSERT-R1-GA100-AMPERE-INT4-B-WP`、`ASSERT-R1-GA100-AMPERE-INT4-ACC-WP`；`REQ-R1-GA100-AMPERE-INT4-A`、`REQ-R1-GA100-AMPERE-INT4-B`、`REQ-R1-GA100-AMPERE-INT4-ACC`；新增三行 | 无法记录 INT4 pair-wise 4:8，仍会错误复用 INT8 条件 |
| `PPATH-R1-GA100-AMPERE-TENSOR-BINARY` + `FACT-R1-GA100-AMPERE-BINARY-A`、`FACT-R1-GA100-AMPERE-BINARY-B`、`FACT-R1-GA100-AMPERE-BINARY-ACC` | component=`COMP-M2NA-AMPERE-TENSOR`，operation=`matrix`；A/B=`Binary`，acc=`INT32`，均 `COND-NONE` | 白皮书 p.27 Table 3 | `ASSERT-R1-GA100-AMPERE-BINARY-A-WP`、`ASSERT-R1-GA100-AMPERE-BINARY-B-WP`、`ASSERT-R1-GA100-AMPERE-BINARY-ACC-WP`；`REQ-R1-GA100-AMPERE-BINARY-A`、`REQ-R1-GA100-AMPERE-BINARY-B`、`REQ-R1-GA100-AMPERE-BINARY-ACC`；新增三行 | binary 被埋在 INT8 path，路径主键和事实语义均失真 |

上述 assertion 每条都必须独立建行，不能用一条 Table 3 assertion 同时指向多个 fact。`REQ-M2NA-GAP-0059` 至 `0063` 仍保留 `not_found`，因为新增的是程序员可见 accumulator，不是物理累加器位宽。

## 动作五：改正 Sparse MMA 叙述，并记录 datatype-specific pattern

### 高层 capability 事实

| 项目 | 精确内容 |
|---|---|
| 受影响 PK | `CAP-M2NA-AMPERE-SPARSE`、`FACT-M2NA-AMPERE-SPARSE-LEVEL`、`FACT-M2NA-AMPERE-SPARSE-DETAIL`、`ASSERT-M2NA-0017`、`ASSERT-M2NA-0018`、`REQ-M2NA-AVAIL-0017`、`REQ-M2NA-AVAIL-0018`、资料卡当前第 60-61 行 |
| 现值 | capability label=`Ampere 2:4 structured sparsity acceleration`；detail=`Hardware selects two nonzero values from each group of four and skips multiplication by the structured zeros.`；两条事实均绑定 `COND-M2NA-AMPERE-2OF4` |
| 建议值 | capability label 改为 `Ampere structured sparse MMA acceleration`。level 保持 `dedicated_instruction`，条件改为 `COND-NONE`。detail 改为 `After pruning and compression determine sparse matrix A, Sparse MMA consumes nonzero A values plus position metadata; hardware uses the metadata to select the corresponding dense B values and omits computation for the structured zeros.`，条件改为 `COND-NONE`，notes 指向下面的 per-datatype 事实 |
| 来源与定位 | 白皮书 p.31 `Sparse Matrix Definition`、p.32 Figure 12、pp.32-33 Figure 13；PTX 7.2 §9.7.13.5 说明 compressed A、explicit metadata 和 shape/type 约束 |
| assertion 同步 | `ASSERT-M2NA-0017` 保留并重算 condition 相关 fact fingerprint。`ASSERT-M2NA-0018` 只支撑 `skip compute` 部分；新增 `ASSERT-R1-GA100-AMPERE-SPARSE-SELECT-WP`，raw value 记录 `indices select corresponding input activations`；新增 `ASSERT-R1-GA100-AMPERE-SPARSE-METADATA-PTX72`，relation=`qualifies` |
| requirement 与卡片同步 | `REQ-M2NA-AVAIL-0017/0018` 保留，fingerprint 不变；卡片两行替换 label、值、条件和双来源定位 |
| 不修正的后果 | 会把软件 pruning/selection 误写成硬件在运行时发现非零权重，还会暗示所有格式都是普通 2:4，错误覆盖 TF32 1:2 和 INT4 pair-wise 4:8 |

### 条件集和 precision path 稀疏事实

| condition / fact 新 PK | 精确条件和事实值 | 来源与定位 | assertion / requirement / card 同步 | 不新增的后果 |
|---|---|---|---|---|
| 修订 `COND-M2NA-AMPERE-2OF4` + `FACT-R1-GA100-AMPERE-SPARSE-FP16` | condition 仍绑定 `PPATH-M2NA-AMPERE-TENSOR-FP16`，pattern=`2:4`，software_version=`PTX ISA 7.1 / CUDA 11.1`，support=`hardware_instruction`；fact=`FIELD-NUM-SPARSITY / structured_sparse` | PTX 7.2 §9.7.13.5.1、revision history §12.2 | `ASSERT-R1-GA100-AMPERE-SPARSE-FP16-PTX72`；`REQ-R1-GA100-AMPERE-SPARSE-FP16`；新增卡片行 | 原 condition 只被 capability 借用，precision path 本身没有 sparsity 合同 |
| `COND-R1-GA100-AMPERE-BF16-SP24` + `FACT-R1-GA100-AMPERE-SPARSE-BF16` | BF16 path；2:4；两个 nonzero 和两个 2-bit index；`FIELD-NUM-SPARSITY=structured_sparse` | PTX 7.2 §9.7.13.5.1 | `ASSERT-R1-GA100-AMPERE-SPARSE-BF16-PTX72`；`REQ-R1-GA100-AMPERE-SPARSE-BF16`；新增卡片行 | BF16 会被无证据地从 FP16 条件类推 |
| `COND-R1-GA100-AMPERE-TF32-SP12` + `FACT-R1-GA100-AMPERE-SPARSE-TF32` | TF32 path；1:2；一个 nonzero 和 4-bit index；同字段和值 | PTX 7.2 §9.7.13.5.1 | `ASSERT-R1-GA100-AMPERE-SPARSE-TF32-PTX72`；`REQ-R1-GA100-AMPERE-SPARSE-TF32`；新增卡片行 | 会把逻辑 50% 稀疏错误规范化成 2:4 物理原子 |
| `COND-R1-GA100-AMPERE-INT8-SP24` + `FACT-R1-GA100-AMPERE-SPARSE-INT8` | INT8 path；2:4；两个 2-bit index；同字段和值 | PTX 7.2 §9.7.13.5.1 | `ASSERT-R1-GA100-AMPERE-SPARSE-INT8-PTX72`；`REQ-R1-GA100-AMPERE-SPARSE-INT8`；新增卡片行 | INT8 与 INT4 metadata 会继续混合 |
| `COND-R1-GA100-AMPERE-INT4-PAIR48` + `FACT-R1-GA100-AMPERE-SPARSE-INT4` | `PPATH-R1-GA100-AMPERE-TENSOR-INT4`；pair-wise 4:8，四个二元素 pair 中保留两个全非零 pair；同字段和值 | PTX 7.2 §9.7.13.5.1 | `ASSERT-R1-GA100-AMPERE-SPARSE-INT4-PTX72`；`REQ-R1-GA100-AMPERE-SPARSE-INT4`；新增卡片行 | 会把 pair atom 约束简化成任意 4:8，进而错误推导 metadata、selector 和可支持模式 |

这些事实只证明 PTX 可见接口和 metadata 语义，不证明 native opcode、物理 Tensor Core array、metadata SRAM、selector RTL、decoder 面积、流水深度或实际 2 倍持续性能。

## 动作六：给软件映射加版本、target 和成熟度

| 项目 | 精确内容 |
|---|---|
| 受影响 PK | `FACT-M2NA-AMPERE-SW`、`ASSERT-M2NA-0021`、`REQ-M2NA-AVAIL-0021`、资料卡当前第 68 行；新增 `COND-R1-GA100-AMPERE-CUDA110-SM80`、`FACT-R1-GA100-AMPERE-SW-MATURITY`、`ASSERT-R1-GA100-AMPERE-SW-MODEL-CUDAPG110`、`ASSERT-R1-GA100-AMPERE-SW-MODEL-PTX70`、`ASSERT-R1-GA100-AMPERE-SW-MATURITY-CUDAPG110`、`REQ-R1-GA100-AMPERE-SW-MATURITY` |
| 现值 | `CUDA exposes Ampere asynchronous-copy and barrier capabilities. / COND-NONE`；唯一 assertion 只写 `CUDA 11 barrier objects` |
| 建议值 | `CUDA 11 exposes global-to-shared asynchronous copy and split barrier for the CC 8.0/sm_80 target; the CUDA 11.0 async-copy API was documented as experimental.`；绑定新 condition。新增 maturity fact：`FIELD-SW-SUPPORT-MATURITY=documented_supported`，同 condition |
| condition 精确含义 | software_version=`CUDA 11.0; PTX ISA 7.0`，support_level=`hardware_instruction`，measurement_scope=`per_object`，notes=`CC 8.0/sm_80; async-copy API experimental in CUDA 11.0; no runnable or benchmark verification` |
| 来源与定位 | 现有白皮书 p.17 只支撑 CUDA 11 barrier；CUDA PG 11.0 §B.23、§B.24 支撑版本、API、experimental 和 CC8.0+ 硬件加速；PTX 7.0 `cp.async`/`mbarrier` target notes 支撑 `sm_80+` |
| assertion 同步 | `ASSERT-M2NA-0021` 保留为部分支持；新增 `ASSERT-R1-GA100-AMPERE-SW-MODEL-CUDAPG110`、`ASSERT-R1-GA100-AMPERE-SW-MODEL-PTX70` 和 `ASSERT-R1-GA100-AMPERE-SW-MATURITY-CUDAPG110`，前两条指向现有 programming-model fact，后一条指向新 maturity fact。不得采纳 ISSCC 的 `supported in CUDA 8.0`；若建立 conflict 记录，只能写“ISSCC 与 NVIDIA 开发文档不一致”，不能把“误写 Compute Capability 8.0”当成已证实原因 |
| requirement 与卡片同步 | `REQ-M2NA-AVAIL-0021` 保留；新增 `REQ-R1-GA100-AMPERE-SW-MATURITY`；卡片软件表增加 maturity 行和条件说明 |
| 不修正的后果 | `COND-NONE` 会把发布期软件版本、target 和 experimental 状态抹掉，接口存在也会被误读为 runnable verified 或 benchmarked |

## 动作七：保留的架构事实及定位修订

下列事实无需改主语、字段、值或条件。其 assertion 和 requirement 继续保留；只有明确列出的定位需要修订。

| fact PK | 主体 / 字段 / 条件 | 来源与定位 | 同步行 | 保留边界和不当改动的后果 |
|---|---|---|---|---|
| `FACT-M2NA-AMPERE-TENSOR-EXEC` | `COMP-M2NA-AMPERE-TENSOR / FIELD-COMP-EXECUTION / COND-NONE` | 白皮书 p.20 `A100 SM Architecture` | `ASSERT-M2NA-0002`、`REQ-M2NA-AVAIL-0002`、卡片第 16 行均保留 | 只写第三代 Tensor Core matrix FMA path，不推导阵列形状或总吞吐 |
| `FACT-M2NA-AMPERE-L1SMEM-MGMT` | `COMP-M2NA-AMPERE-L1SMEM / FIELD-MEM-MANAGEMENT=mixed / COND-NONE` | 白皮书 p.21 | `ASSERT-M2NA-0006`、`REQ-M2NA-AVAIL-0006`、卡片第 47 行 | 不能把 combined resource 当成 L1 192 KB 加 shared 164 KB 的两份容量 |
| `FACT-M2NA-AMPERE-L1SMEM-SCOPE` | 同 component，`FIELD-MEM-LOCALITY-SCOPE=core / COND-NONE` | 白皮书 p.15、p.21，per SM | `ASSERT-M2NA-0007`、`REQ-M2NA-AVAIL-0007`、卡片第 48 行 | `core` 是项目规范化值，应在 assertion notes 保留 `per SM` 原文 |
| `FACT-M2NA-AMPERE-ASYNC-LEVEL` | `CAP-M2NA-AMPERE-ASYNC / FIELD-CAP-IMPLEMENTATION-LEVEL=dedicated_instruction / COND-NONE` | 白皮书 p.21 | `ASSERT-M2NA-0019`、`REQ-M2NA-AVAIL-0019`、卡片第 62 行 | 不能扩成独立 DMA engine 数量或性能 |
| `FACT-M2NA-AMPERE-NVLINK-PROTOCOL` | `LINK-M2NA-AMPERE-NVLINK3 / FIELD-INT-PROTOCOL / COND-NONE` | 白皮书 pp.16-17 | `ASSERT-M2NA-0020`、`REQ-M2NA-AVAIL-0020`、卡片第 54 行 | 只保留 protocol generation；12 links、300 GB/s each direction 和 600 GB/s 双向聚合属于 A100/具体实现 |

FP16、BF16、TF32、FP64 的保留事实已经在动作四逐条列出，不在此重复。

## 42 条现有 requirement 的逐条裁决

### 21 条 value_available requirement

| requirement PK | 裁决 | 精确同步 |
|---|---|---|
| `REQ-M2NA-AVAIL-0001` | 保留 | 跟随修正后的 `FACT-M2NA-AMPERE-SM-EXEC`；notes 更新为双来源证据链 |
| `REQ-M2NA-AVAIL-0002` | 保留 | 不变 |
| `REQ-M2NA-AVAIL-0003` | 删除 | 随错误的 Tensor format/shared-resource fact 删除 |
| `REQ-M2NA-AVAIL-0004` | 保留并收敛状态 | 跟随修正后的 CUDA execution fact；补 PTX assertion 后再从 `needs_resolution` 改为 `reviewed` |
| `REQ-M2NA-AVAIL-0005` | 修正 | field 改为 `FIELD-MEM-DMA`，重算 fingerprint，notes 仍指向 `FACT-M2NA-AMPERE-ASYNC-EXEC` |
| `REQ-M2NA-AVAIL-0006`、`0007` | 保留 | 不变 |
| `REQ-M2NA-AVAIL-0008`、`0009`、`0010` | 保留 | FP16 A/B/accumulator，assertion locator 改 p.27 Table 3 |
| `REQ-M2NA-AVAIL-0011`、`0012` | 保留 | BF16 A/accumulator；另加 BF16-B requirement |
| `REQ-M2NA-AVAIL-0013`、`0014` | 保留 | TF32 A 值修正为 TF32，accumulator locator 改 p.27；另加 B 和 conversion requirement |
| `REQ-M2NA-AVAIL-0015` | 保留 | FP64-A；另加 B 和 accumulator requirement |
| `REQ-M2NA-AVAIL-0016` | 保留并缩窄 | 只承接 INT8-A；另建 INT8-B/ACC、INT4 和 binary requirements |
| `REQ-M2NA-AVAIL-0017`、`0018` | 保留 | capability 级稀疏事实改值/条件但 subject-field pair 不变 |
| `REQ-M2NA-AVAIL-0019`、`0020` | 保留 | 不变 |
| `REQ-M2NA-AVAIL-0021` | 保留 | 软件事实改用 CUDA 11.0 / sm_80 condition，新增 maturity requirement |

### 21 条 gap requirement

| requirement PK | 现值与裁决 | 来源检查、卡片同步和不应改成 available 的原因 |
|---|---|---|
| `REQ-M2NA-GAP-0001` | `not_applicable`，保留 | 架构代际没有实现无关的总 AI TOPS；A100 产品峰值不得下放。卡片第 74 行保留 |
| `REQ-M2NA-GAP-0002`、`REQ-M2NA-GAP-0003`、`REQ-M2NA-GAP-0004` | `not_applicable`，保留 | process、die count、package 属于 GA100 die 或封装，不属于架构对象。卡片第 75-77 行保留 |
| `REQ-M2NA-GAP-0005` | `not_found`，保留 | 没有同精度、同 scope 的架构计算与带宽对；A100 产品峰值和 HBM 带宽不能拼成架构 ratio。卡片第 78 行保留 |
| `REQ-M2NA-GAP-0006` | `not_found`，保留 | 没有兼容 precision、scope、operation-count 的 matrix/vector pair。notes 中无关的 `CDNA 4 is populated...` 是生成残留，应删除。卡片第 79 行保留 |
| `REQ-M2NA-GAP-0059`、`REQ-M2NA-GAP-0060`、`REQ-M2NA-GAP-0061`、`REQ-M2NA-GAP-0062`、`REQ-M2NA-GAP-0063` | `not_found`，保留 | 白皮书 Table 3、ISSCC Figure 3.2.2 和 PTX 只公开程序员可见 accumulator，不公开物理 accumulator width。`last_searched_date` 更新为 `2026-08-21`；卡片第 80-84 行保留 |
| `REQ-M2NA-GAP-0064` | `not_applicable`，保留 | `PPATH-M2NA-AMPERE-CUDA-FP32` 不是 matrix/vector accumulation path。卡片第 85 行保留 |
| `REQ-M2NA-GAP-0109`、`REQ-M2NA-GAP-0110` | `not_found`，保留 | 当前三份允许输入没有给 Ampere generation-level register-file read/write byte/s。Figure 7 的结构和 256 KB/SM 不是带宽。更新检索日期；卡片第 86-87 行保留 |
| `REQ-M2NA-GAP-0111`、`REQ-M2NA-GAP-0112` | `not_found`，保留 | 192 KB combined capacity 和 async-copy 行为不等于 L1/shared read/write bandwidth。更新检索日期；卡片第 88-89 行保留 |
| `REQ-M2NA-GAP-0113`、`REQ-M2NA-GAP-0114` | `not_found`，保留 | 5120 B/clk 明确绑定 A100 L2 read，且时钟域未公开；不能提升为所有 Ampere 实现的 byte/s，更不能补 write bandwidth。更新检索日期；卡片第 90-91 行保留 |
| `REQ-M2NA-GAP-0151` | `not_applicable`，保留 | link 只记录架构协议；12-link 和 600 GB/s 是 A100 device 配置。卡片第 92 行保留 |
| `REQ-M2NA-GAP-0163`、`REQ-M2NA-GAP-0164` | `not_found`，保留 | 白皮书、ISSCC 和 CUDA/PTX 官方阅读均未显示专用 MoE routing 或 top-k 模块/指令；通用 CUDA/Tensor Core 实现不算专用硬件。更新检索日期；卡片第 93-94 行保留 |

所有保留的 gap requirement 都应继续区分 `not_found` 和 `not_applicable`。本轮没有证据把任何一个未知值改成 0，也没有理由把产品或 GA100 数值抬到 architecture generation。

## 新增 PK 汇总

为便于总控生成 staging，下面汇总本报告要求的新增主键。正式写入前仍须做全库唯一性检查。

| 表 | 新 PK |
|---|---|
| `precision-paths.csv` | `PPATH-R1-GA100-AMPERE-TENSOR-INT4`；`PPATH-R1-GA100-AMPERE-TENSOR-BINARY` |
| `condition-sets.csv` | `COND-R1-GA100-AMPERE-BF16-SP24`；`COND-R1-GA100-AMPERE-TF32-SP12`；`COND-R1-GA100-AMPERE-INT8-SP24`；`COND-R1-GA100-AMPERE-INT4-PAIR48`；`COND-R1-GA100-AMPERE-CUDA110-SM80`；另修订既有 `COND-M2NA-AMPERE-2OF4` |
| `facts.csv` | `FACT-R1-GA100-AMPERE-BARRIER-SCHED`；`FACT-R1-GA100-AMPERE-BF16-B`；`FACT-R1-GA100-AMPERE-TF32-B`；`FACT-R1-GA100-AMPERE-TF32-CONVERSION`；`FACT-R1-GA100-AMPERE-FP64-B`；`FACT-R1-GA100-AMPERE-FP64-ACC`；`FACT-R1-GA100-AMPERE-INT8-B`；`FACT-R1-GA100-AMPERE-INT8-ACC`；`FACT-R1-GA100-AMPERE-INT4-A`；`FACT-R1-GA100-AMPERE-INT4-B`；`FACT-R1-GA100-AMPERE-INT4-ACC`；`FACT-R1-GA100-AMPERE-BINARY-A`；`FACT-R1-GA100-AMPERE-BINARY-B`；`FACT-R1-GA100-AMPERE-BINARY-ACC`；`FACT-R1-GA100-AMPERE-SPARSE-FP16`；`FACT-R1-GA100-AMPERE-SPARSE-BF16`；`FACT-R1-GA100-AMPERE-SPARSE-TF32`；`FACT-R1-GA100-AMPERE-SPARSE-INT8`；`FACT-R1-GA100-AMPERE-SPARSE-INT4`；`FACT-R1-GA100-AMPERE-SW-MATURITY` |
| `field-requirements.csv` | `REQ-R1-GA100-AMPERE-BARRIER-SCHED`；`REQ-R1-GA100-AMPERE-BF16-B`；`REQ-R1-GA100-AMPERE-TF32-B`；`REQ-R1-GA100-AMPERE-TF32-CONVERSION`；`REQ-R1-GA100-AMPERE-FP64-B`；`REQ-R1-GA100-AMPERE-FP64-ACC`；`REQ-R1-GA100-AMPERE-INT8-B`；`REQ-R1-GA100-AMPERE-INT8-ACC`；`REQ-R1-GA100-AMPERE-INT4-A`；`REQ-R1-GA100-AMPERE-INT4-B`；`REQ-R1-GA100-AMPERE-INT4-ACC`；`REQ-R1-GA100-AMPERE-BINARY-A`；`REQ-R1-GA100-AMPERE-BINARY-B`；`REQ-R1-GA100-AMPERE-BINARY-ACC`；`REQ-R1-GA100-AMPERE-SPARSE-FP16`；`REQ-R1-GA100-AMPERE-SPARSE-BF16`；`REQ-R1-GA100-AMPERE-SPARSE-TF32`；`REQ-R1-GA100-AMPERE-SPARSE-INT8`；`REQ-R1-GA100-AMPERE-SPARSE-INT4`；`REQ-R1-GA100-AMPERE-SW-MATURITY` |
| `fact-assertions.csv` | `ASSERT-R1-GA100-AMPERE-SM-SIMT-PTX70`；`ASSERT-R1-GA100-AMPERE-CUDA-SIMT-PTX70`；`ASSERT-R1-GA100-AMPERE-BARRIER-WP`；`ASSERT-R1-GA100-AMPERE-ASYNC-PTX70`；`ASSERT-R1-GA100-AMPERE-BF16-B-WP`；`ASSERT-R1-GA100-AMPERE-TF32-B-WP`；`ASSERT-R1-GA100-AMPERE-TF32-CONVERSION-WP`；`ASSERT-R1-GA100-AMPERE-FP64-B-WP`；`ASSERT-R1-GA100-AMPERE-FP64-ACC-WP`；`ASSERT-R1-GA100-AMPERE-INT8-B-WP`；`ASSERT-R1-GA100-AMPERE-INT8-ACC-WP`；`ASSERT-R1-GA100-AMPERE-INT4-A-WP`；`ASSERT-R1-GA100-AMPERE-INT4-B-WP`；`ASSERT-R1-GA100-AMPERE-INT4-ACC-WP`；`ASSERT-R1-GA100-AMPERE-BINARY-A-WP`；`ASSERT-R1-GA100-AMPERE-BINARY-B-WP`；`ASSERT-R1-GA100-AMPERE-BINARY-ACC-WP`；`ASSERT-R1-GA100-AMPERE-SPARSE-SELECT-WP`；`ASSERT-R1-GA100-AMPERE-SPARSE-METADATA-PTX72`；`ASSERT-R1-GA100-AMPERE-SPARSE-FP16-PTX72`；`ASSERT-R1-GA100-AMPERE-SPARSE-BF16-PTX72`；`ASSERT-R1-GA100-AMPERE-SPARSE-TF32-PTX72`；`ASSERT-R1-GA100-AMPERE-SPARSE-INT8-PTX72`；`ASSERT-R1-GA100-AMPERE-SPARSE-INT4-PTX72`；`ASSERT-R1-GA100-AMPERE-SW-MODEL-CUDAPG110`；`ASSERT-R1-GA100-AMPERE-SW-MODEL-PTX70`；`ASSERT-R1-GA100-AMPERE-SW-MATURITY-CUDAPG110` |

## 不应在本包扩大的事项

本包不新增或下放 GA100 物理数量。full GA100 的 128 SM、8192 FP32 core、512 Tensor Core、12 个 512-bit memory controller，以及 N7、54.2B、826 mm²，应由 GA100 die 事务另建 object/component/fact；A100 的 108 SM、432 Tensor Core、40 MB L2、1410 MHz、产品峰值、12-link 聚合、HBM 和 MIG 7-way 仍是 enabled product configuration，不得改成无条件 Ampere 或 full GA100 事实。

本包也不建立 Tensor Core physical array、metadata SRAM、selector RTL、physical accumulator width、`cp.async` engine 数量、queue depth、持续带宽或延迟。PTX 是虚拟 ISA；`mma.sp`、`cp.async` 和 `mbarrier` 只能证明 programmer-visible instruction semantics 和 target requirement。

`compute data compression` 与 2:4/1:2/pair-wise 4:8 Sparse MMA 是两种机制，不能合并。L2 residency control 不是 KV Cache manager，warp reduce 不是 Softmax 专用单元，NVLink 不是 network collective offload，通用 CUDA 实现也不证明专用 MoE route 或 top-k 硬件。本包不新增这些 capability。

ISSCC 的 `supported in CUDA 8.0` 不进入事实库。它可以在后续 conflict 记录中与 CUDA 11.0 官方开发文档并列，但“作者把 Compute Capability 8.0 写成 CUDA 8.0”只能标为推断。

## 卡片和正式事务的同步顺序

总控若采纳本审计，建议先固定 PTX/CUDA 来源版本，再生成 source family、source、endpoint；随后修 precision path 和 condition set；再执行事实、assertion、requirement 的删除、更新和新增；最后按 fact_id 重建 Ampere 卡片对应表。卡片不能先改，因为当前来源生命周期仍有 `source/source-family/endpoint=draft` 与卡片 `accepted` 不一致的问题。

正式事务完成后，至少检查：21 个旧 fact 的裁决无遗漏；42 个旧 requirement 每个都有保留、修正或删除结论；每个新增 fact 恰有一个 subject 和匹配的 value-available requirement；每条 assertion 指向已存在 source；condition 的 precision path 与 datatype 一致；card 中不存在已删除的 `FACT-M2NA-AMPERE-TENSOR-FORMATS`；`FACT-M2NA-AMPERE-SPARSE-DETAIL` 不再出现“hardware selects two nonzero values from each group of four”。

## 验证与逆向复读

本轮逐行比对了 `facts.csv` 的 21 条 Ampere 事实、`field-requirements.csv` 的 42 条 Ampere requirement、`fact-assertions.csv` 的 21 条 assertion、相关 component/precision path/capability/link、唯一 Ampere condition，以及架构卡中的对应行。报告没有引用输入边界外的事实来补数。

人工逆向复读从拟写事实回到来源后确认：SIMT 必须依赖 PTX/CUDA machine model 与 GA100 Figure 7 的组合；Table 3 证明的是 A/B 和 programmer-visible accumulator，不是 physical accumulator；Figure 12 的 `Select` 选择的是与压缩权重 index 对应的 dense activation；PTX 的 FP16/BF16 2:4、TF32 1:2、INT8 2:4、INT4 pair-wise 4:8 不能合成一条无条件 2:4。结尾未加入 GA100 数量、A100 峰值或软件版本之外的推断。

机器扫描和人工自然化检查结果见交付时的验证记录。本报告属于 evidence-led engineering audit，保留精确 PK 和英文规范值，未为了语气自然化而改动技术限定。
