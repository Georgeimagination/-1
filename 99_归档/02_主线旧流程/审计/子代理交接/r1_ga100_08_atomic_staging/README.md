# GA100 原子事实与来源 staging overlay

## 状态与对象边界

本目录是待审计的事务 overlay，没有写入正式表。冻结对象是 `OBJ-NVIDIA-GA100-DIE`，含义为 full GA100 physical die design。A100 enabled implementation、SXM 或 PCIe 产品、HBM 堆栈、封装、卡、系统、MIG profile 和第三方测试对象均不在这个对象内。Ampere 架构机制只通过 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` 复用；实现数量和 full-die 物理值留在 GA100 组件上。

overlay 共有 545 条 fragment 行、567 条操作，其中 insert=516、update=48、delete=3。`operations.csv` 是正式合并清单。fragment 使用正式表原表头，不能把目录整体追加到正式表；必须按 operation 执行。

## 关键取舍

正式候选只接受来源明确指向 full GA100 或 Ampere architecture、且字段合同能承载的原子值。对象名与冻结名单保持 `NVIDIA GA100 die`，full-design 解释只放 notes。full GA100 的 8 GPC、64 TPC、128 SM、8192 FP32 CUDA Core、512 Tensor Core 和 12 个 512-bit memory controller 分别建组件与 count fact。`FIELD-COMP-COUNT-RULE` 的合同定义是运算计数，不用来保存 8×8×2 的结构乘法；FP16 per-SM throughput 采用来源的 FMA vendor label，不能静默乘二。12×512 bit 没有被派生为 `FIELD-PHY-HBM-INTERFACE=6144 bit`。`FIELD-PHY-DIE-COUNT` 也没有从 object type 或 die photo 推导出 1。

Figure 7 与 Table 4 直接支持每 SM 四组 register file 合计 256 KiB，以及 192 KiB combined L1 data cache/shared memory。overlay 分别保存 262144 byte 与 196608 byte，并把 register-file aggregation 限为 capacity only；没有乘成 full-die aggregate，也没有把 164 KB maximum shared allocation 再加到 192 KB。Figure 6 的 `PCI Express 4.0 x16 Host Interface` 通过一个真实 GA100 host-device link 承载 `FIELD-INT-PROTOCOL`，没有附带卡形态或链路吞吐。

A100 产品峰值、启用数量、时钟、功耗、HBM 容量或带宽、NVLink 总数、MIG profile 和 product benchmark 没有下放。HPEC latency cycle 不能写入以秒为正式单位的 `FIELD-MEM-LATENCY`。随机访存约 1400 或 1600 GB/s、约 64 GB cliff 和 14 groups 留在 `claim_dispositions.csv`，没有伪造成 GA100 固有事实。`FIELD-ID-STATUS` 保持 pending，因为项目的 historical-anchor 纳入状态不是产品状态。`FIELD-ID-DATA-CUTOFF` 也保持 pending，原因是当前 fact 合同要求外部证据链，而日期本身是卡片行政元数据。

白皮书 Table 7 的标题直接写 `GA100 HW decode support`，因此 overlay 建了 GA100 video-decode component 和 media capability，只保留格式支持；A100 的 5 个 NVDEC、1410 MHz 条件吞吐、NVJPG 5-core、NVENC、RT 或 display absence 均未转入。白皮书 p.67 的 warp-wide reduction 指令补在 Ampere capability 上，范围限于 arithmetic ADD/MIN/MAX 和 logical AND/OR/XOR，其他类型或操作仍走 software。它不等同于 Softmax unit 或 collective offload。TF32 conversion、operand 和 output 分开，`FIELD-NUM-OUTPUT=FP32` 只用于来源明确写 standard IEEE FP32 output 的 TF32 path。

模板特殊机制没有合并成一条 limitation。Attention data move、Softmax、Top-k、MoE route、MoE dispatch、collective offload、quantize、dequantize、transpose or permute、compression 和 KV cache management 各有独立 capability evidence target 与 requirement。evidence target 是结构化检索锚点，不宣称模块、指令或引擎存在。Compression 因 A100 L2 线索仍有产品边界问题而保持 pending，其余在已读固定来源内为 not_found。Sparse skip、warp reduction、OFA 和 video decode 使用真实 capability 主体。

GA100 reliability fact 的主体全部是 object，没有把 `FIELD-RAS-*` 挂到 link、component 或 software。Dynamic page offlining、row remapping、error containment、detection 和 recovery 各自保留 framebuffer UCE、driver、external HBM spare row、InfoROM、application termination、reset 或 service window 条件。NVLink 3 的 improved error detection and recovery 写在既有 architecture link 的 `FIELD-INT-FAULT`，没有扩成 whole-chip RAS、物理 link count、FEC mode 或 BER。

Ampere 修复显式删除 `FACT-M2NA-AMPERE-TENSOR-FORMATS`、`REQ-M2NA-AVAIL-0003` 和 `ASSERT-M2NA-0003`，并用 precision-path facts 取代错误的 shared-resource 聚合。async copy 改到 `FIELD-MEM-DMA`，barrier 分开；INT8、INT4 和 Binary 拆 path；Sparse MMA 高层 capability 不再无条件绑定普通 2:4，FP16/BF16 2:4、TF32 1:2、INT8 2:4 和 INT4 pair-wise 4:8 分条件保存。ISSCC 的 `CUDA 8.0` 只作为 contradicts assertion 保留，没有生成可接受 CUDA-8 fact。54B 只作为 54.2B 的 rounded qualifier，transistor fact 使用 `source_with_caveat`，没有伪装成 exact corroboration。所有被改写的旧 fact、requirement 和 assertion 回到 draft；既有 architecture entity 和 source 也没有被本 overlay 静默抬为 reviewed。生命周期提升必须由独立签字和正式硬门后的显式 operations 完成。

## 来源 payload 与 endpoint

已有 `论文/` 下的白皮书、ISSCC、IEEE Micro 和两篇 independent measurement PDF 继续复用原路径。`r1_ga100_source_staging/downloads/` 内新增固定文件仍留在 staging；`payload_copies.csv` 给出 19 个 stable target、sha256 与 byte count。candidate `source-endpoints.csv` 已写 stable `最小参考资料库/快照/NVIDIA/GA100/...` 路径。正式事务必须先复制并核 hash，再插 endpoint，不能让正式 endpoint 长期指向 audit staging，也不能把 manifest 当作独立 source 或 selection member。

Source screening 以 source 为单位，每个新 source 一行。ISSCC、HPEC、random-access、IEEE Micro 和 moving R595 source 留作 lead_only，因为本 overlay 没有不可由已选来源替代的 accepted full-GA100 fact 依赖它们。ISSCC 的 LR PHY 细节没有进入 overlay，因此不能仅凭 die photo 或 rounded qualifier 留在 minimum set。PTX 7.0 与 7.2 是同一家族的两个版本，mandatory reason 分别限定为 contemporaneous sm_80 machine-model boundary 和 datatype-specific `mma.sp` contract，不能当成两条独立 corroboration。Selection members 只存 source_id，不存 endpoint_id。当前 run 是 provisional，payload copy、正式合并和 assertion review 后必须重新做 reverse removal。

## 未解决项

full GA100 link count、die count、HBM interface total、die-only clock 或 power、product availability 和 card administrative cutoff 尚未闭合。A100 product measurement 也缺正式 product subject，不能用 GA100 die 替代。CUDA Graph dependency tracking 或 launch optimization 留作 A100 product-conditioned software lead，不足以把 scheduling 字段标成全面覆盖。MIG driver table anomaly、HPEC Table III unit 和 random-access TLB explanation 没有通过制造规范化 fact 来“解决”。

本机没有 PowerShell，三道正式硬门不能在此运行。现有 runtime audit 还记录了正式 source-pool count 与 Windows gate 预期不一致。这里的 union 校验只证明 overlay 的静态合同一致性，不能替代 Windows 硬门或总控 merge review。

## 正式合并顺序

先按 `payload_copies.csv` 复制新增固定 payload 到 stable snapshot，并逐个核对 bytes 与 sha256。随后依次执行 source family/source、endpoint、object graph/component/precision path/capability/memory level、condition set、fact delete/update/insert、field requirement、assertion/search evidence、screening/roles/coverage、selection run/member、card completeness。每组完成后在 formal+staging 临时联合镜像重跑 PK、FK、enum、target、fact-value、requirement-match 和 endpoint preferred checks。

最后更新人类资料卡并检查删掉的 aggregate format fact 不再出现，再在有 PowerShell 的 Windows runner 依次执行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1`。`verify_recovery_paths.py` 另行执行，但不替代三道 PowerShell 硬门。任何一步失败都按 AGENTS.md 分类并回滚整个 GA100 事务，不能留下半合并状态。

## 不变的正式表

本 overlay 不生成以下 fragment：`数据/vendors.csv`, `数据/fields.csv`, `数据/enums.csv`, `数据/schema-columns.csv`, `数据/topologies.csv`, `数据/derived-inputs.csv`, `数据/derived-metrics.csv`, `最小参考资料库/conflict-groups.csv`, `最小参考资料库/conflict-members.csv`。topologies 不变是刻意裁决：目前没有条件完整的 full-GA100 link count 或 topology 原子事实。links fragment 只建直接图示的 PCIe 4.0 x16 host interface；物理 NVLink count 继续 pending。derived tables 不变，因为缺少同对象、同 scope、同方向、同 precision 的可派生输入闭包。conflict tables 不变，因为 CUDA 8.0 的不一致可由 contradicts assertion 保留，不需要强造第二个可接受 fact。

