# GA100 v3 RAS 与 MIG 来源级缺口补救

> 状态：来源精读完成，供 v3 重建使用，不授权正式写入  
> 对象边界：`NVIDIA GA100 die`；A100/A30 产品、外部 HBM、driver 与虚拟化软件栈只作带条件实现  
> 写入边界：本轮只新增本报告，未修改正式表、v2、合同、资料卡、来源快照或进度文件  
> 核验日期：2026-08-21，Asia/Shanghai

## 裁决

v2 的 RAS 与 virtualization 缺口可以收紧，但不能沿用原来的模板检索结论。`REQ-R1-GA100-RAS-BIST` 不应继续保持整体 `not_found`：固定版 RAS 文档已经直接给出 XID、NVML、`nvidia-smi`、SMBPBI、InfoROM row-remap statistics 和 NVIDIA Field Diagnostics，足以为 `FIELD-RAS-TELEMETRY-BIST` 建立有条件的 telemetry/field-diagnostic value；公开 BIST 结构本身仍未找到。`REQ-R1-GA100-RAS-SDE` 可以保留 `not_found`，但依据必须改成对 RAS PDF、R595 快照和白皮书的实际检索，且结论只限“没有公开 GA100 Tensor/CUDA compute datapath silent-data-error detection coverage”。Memory ECC、parity、contained UCE 与“不继续传播”都不能改写成完整的 silent data error（SDE，静默数据错误）覆盖。

ECC、protection scope、error detection、correction/replay、fault isolation 与 recovery 均已有可用证据，不过需要按 on-die SRAM、外部 HBM、NVLink、MIG GPU Instance（GI，GPU 实例）、driver 和 service-window reset 拆开。任何一句“全芯片受保护”都会超过来源。公开资料也没有给出 compute datapath、控制状态和所有 SRAM 的完整保护图。

MIG 610 能支撑 GA100 产品实现上的 GI 物理分区、GI memory QoS、GI fault isolation、Compute Instance（CI，计算实例）专用 SM 与共享 memory/engines，以及 mode/geometry 生命周期。它没有出现 preemption、CI context-switch state、checkpoint、migration、save-and-restore 或 SR-IOV。`GPU Context` 的 distinct address space 不能提升为 CI 独立地址空间；`MIG-backed vGPU` 也不能等同于 Single Root I/O Virtualization（SR-IOV，单根 I/O 虚拟化）。白皮书 p.52 的 `MIG Migration` 仍只是 2020 年概念性状态保存与恢复描述，缺少当前产品版本、API、hypervisor matrix 和一致性条件，不能当成已交付的 migration/checkpoint 实现。

MIG 610 在 v2 中只给两条已由白皮书直接支持的 identity fact 作 `qualifies`。按当前事实集合反向移除，它可以删除，source screening 应改为 `lead_only`。如果 v3 接受本报告列出的 GI/CI、QoS、lifecycle 或 virtualization 条件化事实，MIG 610 才可能以 `software_virtualization_evidence` 或 `architecture_mechanism` 重新参加选择；它仍不应使用 `identity` 作为不可替代理由。

## 本轮实际读取的固定内容

本报告区分 source、endpoint 与当前磁盘文件。v2 的候选 endpoint 把目标路径写到 `最小参考资料库/快照/NVIDIA/GA100/`，这些稳定目标目前尚未复制；本轮实际读取的是 `r1_ga100_source_staging/downloads/` 中的 payload。以下 endpoint ID 可供 v3 绑定，但不能据此声称 payload 已进入正式资料库。

| 简称 | source_id、版本与来源家族 | endpoint 与本轮实际文件 | 固定性和用途 |
|---|---|---|---|
| `RAS-PDF` | `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001`；`DA-09826-002_v001`，June 2023；`SFAM-NVIDIA-GPU-MEMORY-ERROR-MGMT` | `END-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001-LOCAL`；实际文件 `审计/子代理交接/r1_ga100_source_staging/downloads/nvidia-gpu-mem-error-mgmt-DA-09826-002_v001.pdf` | 16 页，352370 bytes，SHA-256 `5d484fe6ce3b577cfbdd378ebf6b3cf3eb18cedc0ec99ec557832bad424306d4`。GA100 正向 RAS 与 A100 telemetry 的首选固定版本。 |
| `RAS-595` | `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-R595`；R595 snapshot 2026-08-21；与 `RAS-PDF` 同一 source family | 六个 `END-NVIDIA-GPU-MEM-ERROR-MGMT-R595-*` endpoint；实际文件在 `审计/子代理交接/r1_ga100_source_staging/downloads/ras-r595-*.html` | 六文件 manifest SHA-256 `40a8e5b6617b2f70c85947e1134d60f3766d705509f9344bc77d797767053d4c`。用于当前 support matrix 与 Blackwell-only repair 排除，不增加独立 evidence count。 |
| `MIG-610` | `SRC-NVIDIA-MIG-USER-GUIDE-610`；version 610 snapshot 2026-08-21；`SFAM-NVIDIA-MIG-USER-GUIDE` | 九个 `END-NVIDIA-MIG-USER-GUIDE-610-*` endpoint；实际文件在 `审计/子代理交接/r1_ga100_source_staging/downloads/mig-user-guide-610/` | 八个 HTML 加 `versions1.json`，manifest SHA-256 `db5c3ac2017d7e40d4f4fa9e82e484166e3a7ee64f1ddd904a7c6b4b696fc91b`。version metadata 只列 preferred `610`。一个 guide family，不按页面增加来源数。 |
| `WP-1.0` | `SRC-M2NA-NVIDIA-AMPERE-WP-2020`；v1.0 | `END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`；正式本地文件 `论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf` | 82 页，SHA-256 `3a800ad7668ec37037fa5870a8e3bb681b75f19668b3d11492ab9b0da0d58815`。只补 on-die ECC、NVLink replay、A100 MIG context switch 和概念性 migration。 |

`RAS-595` 的六个 endpoint 分别为：

| endpoint_id | 实际 payload | 本轮定位用途 |
|---|---|---|
| `END-NVIDIA-GPU-MEM-ERROR-MGMT-R595-SUPPORTED` | `ras-r595-supported-gpus.html` | `Supported GPUs` Table 1，GA100 三项支持和 `RAS Repair: GPU Memory` 空白格 |
| `END-NVIDIA-GPU-MEM-ERROR-MGMT-R595-CONTAINMENT` | `ras-r595-error-containment.html` | `Error Containment` 首段与末尾 Note |
| `END-NVIDIA-GPU-MEM-ERROR-MGMT-R595-DPO` | `ras-r595-dynamic-page-offlining.html` | `Dynamic Page Offlining` 全节 |
| `END-NVIDIA-GPU-MEM-ERROR-MGMT-R595-ROW-REMAP` | `ras-r595-row-remapping.html` | `Row Remapping` 首段与 Table 2 |
| `END-NVIDIA-GPU-MEM-ERROR-MGMT-R595-CONTAINED-UCE-RESPONSE` | `ras-r595-contained-uce-response.html` | `Response to Uncorrectable Contained ECC Errors` 全节与 Figure 1 |
| `END-NVIDIA-GPU-MEM-ERROR-MGMT-R595-REPAIR` | `ras-r595-gpu-memory-repair.html` | `RAS Repair` → `GPU Memory Repair`，限定 select Blackwell products |

`MIG-610` 的 endpoint 与用途如下。`versions1.json` 只用于版本绑定，不支持功能事实。

| endpoint_id | 实际 payload | 本轮定位用途 |
|---|---|---|
| `END-NVIDIA-MIG-USER-GUIDE-610-SUPPORTED-GPUS` | `supported-gpus.html` | `Supported GPUs` Table 1，A100-SXM4/A100-PCIE/A30 → GA100；产品实例上限 |
| `END-NVIDIA-MIG-USER-GUIDE-610-INTRODUCTION` | `introduction.html` | `Introduction`，GI 独立路径、memory QoS、fault isolation 与 multi-tenancy |
| `END-NVIDIA-MIG-USER-GUIDE-610-CONCEPTS` | `concepts.html` | `Terminology`、`Partitioning`、`Profile Placement`、Table 3 `CUDA Concurrency Mechanisms` |
| `END-NVIDIA-MIG-USER-GUIDE-610-GETTING-STARTED` | `getting-started-with-mig.html` | `Enable MIG Mode`、`Creating GPU Instances`、`Destroying GPU Instances`、`Monitoring MIG Devices` |
| `END-NVIDIA-MIG-USER-GUIDE-610-DEPLOYMENT` | `deployment-considerations.html` | `System Considerations`、`Application Considerations`，reset、InfoROM persistence 与 software limits |
| `END-NVIDIA-MIG-USER-GUIDE-610-SUPPORTED-CONFIGURATIONS` | `supported-configurations.html` | bare metal/container、GPU passthrough、vGPU 三种部署形态 |
| `END-NVIDIA-MIG-USER-GUIDE-610-VIRTUALIZATION` | `virtualization.html` | Linux guest passthrough 与 MIG-backed vGPU |
| `END-NVIDIA-MIG-USER-GUIDE-610-PROFILES` | `supported-mig-profiles.html` | `A100 MIG Profiles` Table 12、`A30 MIG Profiles` Table 13，仅作产品条件 |
| `END-NVIDIA-MIG-USER-GUIDE-610-VERSION-METADATA` | `versions1.json` | version `610`、preferred 状态 |

## RAS 字段闭合

下表的状态是 v3 建模建议。`value_available` 表示来源足以建立一条或多条条件完整的原子事实；它不表示该字段的所有子机制都已经公开。

| field/factor | v3 建议状态 | 实际 source、endpoint 与 locator | 可接受的原子结论与边界 |
|---|---|---|---|
| `FIELD-RAS-ECC`：on-die SRAM | `value_available`，单独一条 | `SRC-M2NA-NVIDIA-AMPERE-WP-2020` v1.0，`END-M2NA-NVIDIA-AMPERE-WP-2020-LOCAL`，PDF p.35，`ECC Memory Resiliency`，关键词 `L2 cache`、`L1 caches`、`register files inside all the SMs` | A100 enabled implementation 的 L2、L1 与全部 SM register file 使用 SECDED ECC。可投影到 GA100 on-die implementation，但必须保留 A100 enabled condition；不能扩到 Tensor/CUDA datapath 或全部控制状态。 |
| `FIELD-RAS-ECC`：外部 HBM | `value_available`，与 on-die 分开 | 同一 whitepaper endpoint，PDF p.35，`A100 HBM2 memory subsystem supports SECDED ECC`；`RAS-PDF` PDF p.3/文档 p.1 `Overview` 明确本文聚焦 uncorrectable HBM errors、correctable HBM errors 不在范围内 | HBM2 SECDED 属 A100 memory subsystem/外部 HBM，不是 GA100 裸片内存容量或内部 datapath 属性。 |
| `FIELD-RAS-PROTECTION-SCOPE` | `value_available`，至少拆三条 | 存储见 whitepaper p.35；互联见同 endpoint p.52 `Third-Generation NVLink`；GI 隔离见 `SRC-NVIDIA-MIG-USER-GUIDE-610` v610，`END-...-INTRODUCTION`，关键词 `separate and isolated paths`、`fault isolation` | 可分别写 on-die L2/L1/RF、NVLink link-level detection/replay、GI memory path/fault isolation。不能合并成 whole-chip protection；compute datapath、控制状态、BIST 与 SDE coverage 仍缺。 |
| `FIELD-RAS-ERROR-DETECTION`：framebuffer UCE | `value_available` | `RAS-PDF`，`END-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001-LOCAL`，PDF p.6/文档 p.4 `Dynamic Page Offlining`，关键词 `driver identifies the location` | NVIDIA driver 定位 framebuffer uncorrectable ECC error 后标记 page。它不是公开的 on-die detector microarchitecture。 |
| `FIELD-RAS-ERROR-DETECTION`：SRAM/互联 | `value_available`，需限定 | whitepaper p.35 SECDED；whitepaper p.52 `link-level error detection`；`RAS-PDF` PDF p.15/文档 p.13 `RMA Policy Thresholds for SRAM Failure Modes` 提到较新 GPU 的 ECC/parity | NVLink 可写 link-level detection。SRAM ECC/parity 的一般说明不能单独证明 GA100 完整 map；GA100 的具体 L2/L1/RF 仍以 whitepaper p.35 为主。 |
| `FIELD-RAS-CORRECTION-REPLAY`：ECC | `value_available` | whitepaper p.35，SECDED；`RAS-PDF` PDF p.3/文档 p.1，关键词 `ECC correction of single bit errors` | 只写相应 storage scope 的 single-bit correction/double-bit detection，不写 compute replay。 |
| `FIELD-RAS-CORRECTION-REPLAY`：row remap | `value_available` | `RAS-PDF` PDF p.4/文档 p.2 Table 1；PDF p.7/文档 p.5 `Row-Remapping`；`RAS-595` `END-...-ROW-REMAP` 同名章节与 Table 2 | GA100 支持 row remapping；HBM/DRAM bank spare row、driver/InfoROM、reset 与 service window 是条件。R595 与固定 PDF 同 family，不能把两条 assertion 算成两个独立来源。 |
| `FIELD-RAS-CORRECTION-REPLAY`：NVLink | `value_available`，单独一条 | whitepaper p.52，`Third-Generation NVLink`，关键词 `packet replay mechanisms` | 仅支持第三代 NVLink successful transmission 的 packet replay；不证明 on-chip network replay、compute replay 或全芯片 RAS。 |
| `FIELD-RAS-FAULT-ISOLATION` | `value_available` | `RAS-PDF` PDF p.4/文档 p.2 Table 1，PDF p.5/文档 p.3 `Error Containment`；`RAS-595` `END-...-CONTAINMENT` 同名章节 | GA100 支持 error containment；contained UCE 影响限于遇到错误的应用，其余 workload 可继续。必须同时保存 rare uncontained UCE 例外。accuracy/performance 不受影响是 vendor statement，不是独立实测保证。 |
| `FIELD-RAS-RECOVERY`：DPO | `value_available` | `RAS-PDF` PDF p.6/文档 p.4 `Dynamic Page Offlining`；PDF p.8/文档 p.6 `Response to Uncorrectable Contained ECC Errors` | Driver 把错误 page 标为 unusable；大多数 UCE 无需立即 GPU reset；affected application 终止。DPO 不是物理 memory repair。 |
| `FIELD-RAS-RECOVERY`：service/reset | `value_available` | `RAS-PDF` PDF pp.8、10/文档 pp.6、8；`Response...` 与 `Error Recovery and Response Flags` | 正常 GPU/VM service window reset 后 row remap 生效并回收 offlined page；uncontained error 需要尽快 reset。MIG drain-and-reset flag 只表明至少一个实例受影响、其他实例先 drain；它不提供作业状态恢复。 |
| recovery 中的 degrade 模式 | `not_found`，保留字段特定缺口 | `RAS-PDF` Chapters 3 至 10；`RAS-595` containment/DPO/remap/response 页面，关键词 `degrade`、`degraded`、`continue running` | 只找到错误 page 隔离、affected application termination 和 unaffected workload continuation。没有公开 compute-unit disable、capacity derating、性能降档或有状态 graceful degradation。 |
| `FIELD-RAS-TELEMETRY-BIST`：health telemetry | `value_available`，修正 v2 | `RAS-PDF` PDF pp.11-12/文档 pp.9-10 `User Visible Statistics`：XID 94/95/63/64、NVML/`nvidia-smi`、SMBPBI、InfoROM count、pending/failure/bucketized count | 这是直接 telemetry 证据。计数是 InfoROM entry，不等同于硬件中已完成的 remap；XID/NVML/SMBPBI 是软件、固件或带外接口条件。 |
| `FIELD-RAS-TELEMETRY-BIST`：field diagnostic | `value_available`，与 BIST 分开描述 | `RAS-PDF` PDF pp.14-15/文档 pp.12-13，`RMA Policy Thresholds...`，关键词 `NVIDIA Field Diagnostic(s)` | 可写 NVIDIA Field Diagnostics 用于 RMA 判定与阈值验证。不能把外部 field diagnostic 工具改写成 GA100 内建 BIST。 |
| BIST structure 子因素 | `not_found` | `RAS-PDF` 全文实际检索 `BIST`、`built-in`、`self-test` 均无命中；`RAS-595` 六个固定页面同词无命中 | v3 若按 field 记一条 requirement，应由上述 telemetry value 关闭；若合同允许 factor-level gap，另保留 “公开 BIST 结构未找到”。不得再用 whitepaper+CUDA Guide 两条模板 result 证明。 |
| `FIELD-RAS-SILENT-DATA-ERROR` | `not_found`，用真实 RAS search 重建 | `RAS-PDF` 全文与 `RAS-595` 六页实际检索 `silent`、`SDC`、`silent data`、`silent corruption` 无命中；whitepaper v1.0 同词无命中 | ECC/parity、detected UCE、containment 和 `erroneous data does not continue to propagate` 都以错误已被检测为前提。当前 corpus 没有 GA100 Tensor/CUDA datapath SDE detection、redundant execution 或 end-to-end checker。 |
| `FIELD-RAS-CHECKPOINT-RESTART` | `pending_verification` | whitepaper v1.0 `END-M2NA...LOCAL` PDF p.52 `MIG Migration`；`RAS-PDF` PDF p.10/文档 p.8 只说 row-remap pending flag 可判断是否适合接收 live VM migration；`MIG-610` 相关 endpoint 无 checkpoint/migration 说明 | 白皮书只描述 vGPU GPU-slice state 被 save/restore 到 slice 数相同的另一 GI。没有交付版本、命令/API、guest memory consistency、downtime、failure recovery 或通用 job restart。不能建立 general checkpoint/restart value。 |
| GA100 `RAS Repair: GPU Memory` | 正向事实排除；search 记 `checked_no_support` | `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-R595`，`END-...-SUPPORTED` Table 1 的 GA100 列为空；`END-...-REPAIR` → `GPU Memory Repair` 明确限定 select Blackwell products | 不得给 GA100 写 DRAM channel swap、L2 slice swap、XID 160 repair 或 reboot-to-apply。表格空白宜作排除结果，不应反写成数值事实。 |

上述判断会直接改变 v2 的两条 requirement：`REQ-R1-GA100-RAS-BIST` 从整体 `not_found` 改为 `value_available`，对应的 value 只承接 telemetry/Field Diagnostics；`REQ-R1-GA100-RAS-SDE` 仍可为 `not_found`，但必须以 `RAS-PDF`、`RAS-595` 和 whitepaper 的实际 endpoint search result 重建。`REQ-R1-GA100-V2-RAS-ECC` 与 `REQ-R1-GA100-V2-RAS-PROTECTION-SCOPE` 都可从 `pending_verification` 推进为拆分后的 `value_available`。

## MIG、虚拟化与调度闭合

MIG 的数值 profile 不能下放到 full GA100。`Supported GPUs` Table 1 同时给 A100-SXM4/A100-PCIE 最多 7 个 instance、A30 最多 4 个 instance，而这些产品都标为 GA100；这已经证明 instance 上限与 geometry 是产品配置。

Version 610 自身还有一处 driver table 异常。`Deployment Considerations` 与 `Getting Started with MIG` 都把 A100/A30 写成 CUDA 11 + R525（`>=525.53`），却把更晚的 H100/H200 写成 CUDA 12 + R450（`>=450.80.02`）；同一 guide 的 A100 命令示例又使用 450.80.02。这个顺序不能当作可靠的最低版本表。本报告只把它记录为官方页面的 unresolved inconsistency，v3 不应从该表建立 A100/A30 minimum-driver value；产品级软件事实必须再由对应 release notes 或固定历史 support matrix 裁决。

| field/factor | v3 建议状态 | 实际 source、endpoint 与 locator | 可接受的结论与明确禁止的推断 |
|---|---|---|---|
| GA100 产品映射 | identity 辅助线索；不进入最小集的 identity role | `SRC-NVIDIA-MIG-USER-GUIDE-610` v610，`END-NVIDIA-MIG-USER-GUIDE-610-SUPPORTED-GPUS`，`Supported GPUs` Table 1 | A100-SXM4、A100-PCIE、A30 的 Microarchitecture 为 GA100、Compute Capability 为 8.0。它不能证明 full-design 资源、日期、状态或任意 MIG profile。白皮书已直接证明 GA100 identity。 |
| `FIELD-VIRT-MULTI-TENANCY` | `value_available`，带产品/软件条件 | `MIG-610` `END-...-INTRODUCTION`，首三段，关键词 `one client cannot impact`、`multiple GPU Instances ... in parallel` | 对支持 MIG 的 GA100 产品，可记录不同 GI 的多租户隔离与并行。作用域是 A100/A30 产品、MIG mode 与软件栈，不是裸片在所有模式下的无条件行为。 |
| GI isolation | `value_available` | `END-...-INTRODUCTION`，`separate and isolated paths through the entire memory system`；`END-...-CONCEPTS` → `Terminology` → `GPU Instance` | GI 分配独立 crossbar ports、L2 banks、memory controllers 与 DRAM address buses，并有 memory QoS/fault isolation。它不证明所有 compute/control state 都隔离。 |
| CI isolation/shared resources | `value_available`，必须写成不对称边界 | `END-...-CONCEPTS` → `Terminology` → `Compute Instance`，以及 `Partitioning` → `Compute Instance`，关键词 `CIs share memory and engines`、`dedicated SM resources` | 同一 GI 内 CI 有 dedicated SM resources，但共享父 GI 的 memory 与 engines。不得给 CI 写独立 L2、独立 memory-bandwidth QoS、完整 fault isolation 或独立 media/copy engine。 |
| CI independent address space | `not_found` | `END-...-CONCEPTS` → `GPU Context` 只对 context 写 `distinct address space`；同页 CI 段没有该陈述。`Deployment Considerations` 又写跨 CI CUDA IPC 支持、跨 GI 不支持 | GPU context 不等于 GI 或 CI。不能从 context 属性、device UUID 或 IPC 行为推导 CI 独立 VA/IOMMU 域。 |
| `FIELD-VIRT-PARTITIONING` | `value_available`，带 A100/A30 condition | `END-...-INTRODUCTION`；`END-...-CONCEPTS` → `Partitioning`、`Profile Placement`；`END-...-PROFILES` → A100 Table 12/A30 Table 13 | 可写 GI 切分 SM、memory path 和 engines，CI 再切 SM。`1/8 memory`、`1/7 SM`、7-way、capacity、copy/media engine count 与 placement 都属于特定产品/profile/driver，不是 full GA100 常量。 |
| GI qualitative QoS | `value_available` | `END-...-INTRODUCTION`，关键词 `predictable throughput and latency`、`same L2 cache allocation and DRAM bandwidth`、`defined QoS`；`END-...-CONCEPTS` → `GPU Instance` | 可记录厂商声称的 GI memory QoS 与干扰隔离。没有 latency bound、bandwidth percentage、priority policy、fairness 或 service-level guarantee。 |
| preemption 子因素 | `not_found` | `MIG-610` 八个 article body 实际检索 `preempt`、`context switch` 无命中；`END-...-CONCEPTS` Table 3 只有 `Reconfigure=When Idle` | QoS 或独立 scheduling 不等于 preemption。whitepaper p.51 的 CI 可独立 context switch 是 A100 scheduling statement，也没有 preemption point、保存状态或切换 latency。 |
| `FIELD-VIRT-PREEMPTION-QOS` | `value_available`，value 只写 isolation/QoS；notes 保留 preemption gap | QoS 证据见 `END-...-INTRODUCTION` 与 `END-...-CONCEPTS` Table 3；context switch 辅助证据见 whitepaper p.51 `Compute Instances Enable Simultaneous Context Execution` | 该合并字段可以由 GI QoS/isolation 关闭，但 normalized text 不能声称已证明抢占。若 v3 能记录 factor gap，应同时保留 preemption `not_found`。 |
| `FIELD-SW-CHIP-BOUND-SCHEDULING` | `value_available`，拆管理面与硬件调度 | whitepaper p.48：Sys Pipe communicates with host CPU and schedules work to GPC/SM；p.51：different CI context-switch separately；`MIG-610` `END-...-INTRODUCTION` 只说 virtual GPU instances 可像 physical GPU 一样被 view/schedule | 可写 Sys Pipe/CI 粒度的 A100 scheduling 与 context-switch statement。MIG Guide 不公开 queue structure、priority、fairness、save state 或 latency；不能用 CUDA Graph product lead 代替这些事实。 |
| MIG mode lifecycle | `value_available`，Ampere/A100/A30 + driver condition | `END-...-DEPLOYMENT` → `System Considerations`；`END-...-GETTING-STARTED` → `Enable MIG Mode` → `GPU Reset on NVIDIA Ampere Architecture GPUs` | A100/A30 切换 MIG mode 需要 per-GPU reset、管理权限并停止持有 driver handle 的 daemon；Ampere mode bit 在 InfoROM 中跨 reboot 持久。reset 是 mode transition，不是 RAS recovery。 |
| GI/CI geometry lifecycle | `value_available` | `END-...-GETTING-STARTED` → `Creating GPU Instances` 的 Note：created MIG devices 不跨 system reboot 持久；`Destroying GPU Instances`：GI/CI 可动态配置和销毁；`END-...-CONCEPTS` Table 3：`Reconfigure=When Idle` | `dynamic` 只表示控制面 create/destroy。不能推导 busy instance 原地 resize、state-preserving reconfigure、automatic restore 或 live migration。mode persistence 与 geometry persistence 必须分开。 |
| virtualization deployment | `value_available`，软件/平台条件 | `END-...-SUPPORTED-CONFIGURATIONS`；`END-...-VIRTUALIZATION`，小标题 `Virtualization` | 可记录 bare metal/container、whole-GPU passthrough to Linux guest、MIG-backed vGPU。hypervisor、guest OS、driver 与 vGPU stack 是条件；不证明 GA100 die 自带 hypervisor。 |
| SR-IOV 与 MIG 的关系 | `not_found` for equivalence；A100 SR-IOV 是另一条产品事实 | `MIG-610` 八个 article body 检索 `SR-IOV`/`Single Root` 无命中；whitepaper p.53 `PCIe Gen 4 with SR-IOV` 单独写 A100 PF/VF | 不得写 `MIG=SR-IOV`、`GI=VF` 或 MIG-backed vGPU 必由 SR-IOV 承载。若记录 SR-IOV，只能是 A100 PCIe product 的独立 virtualization statement。 |
| migration | `pending_verification` | whitepaper p.52 `MIG Migration`；`MIG-610` 的 Concepts、Getting Started、Virtualization、Deployment article body 对 `migration`、`checkpoint`、`save and restore` 均无命中 | 只保留 2020 年 vGPU state save/restore 概念与 “same number of GPU slices” 限制。当前 guide 没有 API、命令、支持矩阵、停机或一致性语义，不能生成 delivered migration fact。 |
| MIG monitoring | `value_available`，软件限制 | `END-...-GETTING-STARTED` → `Monitoring MIG Devices`：推荐 DCGM v3+；A100/A30 上 NVML/`nvidia-smi` 不支持 MIG utilization attribution | 这是版本化 observability 能力与限制，不是 GA100 BIST，也不证明 DCGM 能观测全部 shared resources。 |
| current interop limitations | product/software lead，不下放成永久芯片事实 | `END-...-DEPLOYMENT` → `Application Considerations`，R570 same-GPU P2P、跨 GI/CI CUDA IPC、GPUDirect RDMA、NCCL 与 profiling 限制 | 必须带 driver/version/same-GPU/跨 GI 或 CI 条件。它们不应成为 GA100 硬件永久 limitation。 |

因此，v2 的 `REQ-R1-GA100-V2-VIRT-MULTI-TENANCY` 与 `REQ-R1-GA100-V2-VIRT-PARTITIONING` 可转为条件化 `value_available`。`REQ-R1-GA100-V2-VIRT-PREEMPTION-QOS` 也可由 QoS/isolation 的精确 value 关闭，但必须在 notes 或 factor closure 中明确 preemption 未找到。`REQ-R1-GA100-V2-SW-CHIP-BOUND-SCHEDULING` 可由 whitepaper pp.48、51 与 MIG 610 的 lifecycle/management 证据关闭；A100 CUDA Graph dependency tracking 不需要参与这条 GA100 die 事实。

## 可直接重建的 search closure

v2 的 `SEARCH-R1-GA100-RAS-BIST` 与 `SEARCH-R1-GA100-RAS-SDE` 只有 whitepaper+CUDA Guide 两个模板 result，不能保留。v3 可按下面的最小相关来源集重建，不需要机械扩成所有 endpoint 的笛卡尔积。

| requirement | 实际检索范围与关键词 | 结果 |
|---|---|---|
| `REQ-R1-GA100-RAS-BIST` | `RAS-PDF` 的 `User Visible Statistics`、`RMA Policy Thresholds for Row-Remapping`、`RMA Policy Thresholds for SRAM Failure Modes`；关键词 `XID`、`NVML`、`SMBPBI`、`Field Diagnostic`、`BIST`、`built-in`、`self-test` | telemetry/Field Diagnostics 有直接命中，故 requirement 为 `value_available`；BIST structure 单独 `checked_no_support`。 |
| `REQ-R1-GA100-RAS-SDE` | `RAS-PDF` 全文，`RAS-595` 六个固定 article body，whitepaper v1.0；关键词 `silent`、`SDC`、`silent data`、`silent corruption`、`redundant execution` | `no_reliable_result`。ECC/parity 与 detected UCE 只能进入 ECC/error-detection/protection-scope，不能替代 SDE。 |
| `REQ-R1-GA100-RAS-CKPT` | whitepaper p.52 `MIG Migration`；`RAS-PDF` p.10/文档 p.8 live-VM readiness flag；`MIG-610` Concepts、Getting Started、Virtualization、Deployment，关键词 `migration`、`checkpoint`、`save and restore`、`restart` | 只有概念性 lead，无 current delivered support；维持 `pending_verification`，下一来源应是有固定版本的 NVIDIA vGPU migration/release/support matrix。 |
| `REQ-R1-GA100-V2-RAS-ECC` | whitepaper p.35 `ECC Memory Resiliency`；`RAS-PDF` Overview 与 SRAM failure modes | `value_available`，按 on-die L2/L1/RF 与外部 HBM 拆分。 |
| `REQ-R1-GA100-V2-RAS-PROTECTION-SCOPE` | whitepaper pp.35、52；`MIG-610` Introduction/Concepts；`RAS-PDF` containment/DPO/row-remap | `value_available`，按 storage、link、GI、driver/HBM 分开，不生成 whole-chip scope。 |
| `REQ-R1-GA100-V2-VIRT-PREEMPTION-QOS` | `MIG-610` Introduction、Concepts Table 3；whitepaper p.51；关键词 `QoS`、`predictable throughput and latency`、`context switch`、`preempt` | QoS/isolation 有值；preemption 无支持。合并字段可 `value_available`，limitation 必须保留。 |

每个 search-result 应绑定本报告列出的实际 endpoint，而不是只写 source_id 与通用句。固定 PDF 的 locator 使用 PDF page 加文档页码；HTML 使用 article heading、subheading、table/figure 与关键词。一个 source 下的多个 endpoint 只增加 locator 精度，不增加 distinct-source evidence count。

## Assertion 与 endpoint 重建

v2 `fact-assertions.csv` 有 109 行。删除两条冗余 MIG identity qualifier 后，剩余 107 条 assertion 的 `raw_value_*` 与 locator 可作为 v3 重建输入，但不能字节级 `retain_as_is`。新合同给 `fact-assertions` 增加 `endpoint_id` 后，每一条 assertion 都必须绑定实际 endpoint，并按新列重算 `assertion_fingerprint`；同一 source 的两个 endpoint 仍只算一个 distinct source。

五条现有 RAS assertion 的 raw value 语义可复用，现有 locator `GA100 feature matrix and mechanism sections` 太宽，v3 应按下表收紧：

| v2 assertion_id | endpoint_id | 精确 locator |
|---|---|---|
| `ASSERT-R1-GA100-RAS-CONTAINMENT-01` | `END-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001-LOCAL` | PDF p.4/文档 p.2 Table 1；PDF p.5/文档 p.3 `Error Containment` 与末尾 rare-uncontained Note |
| `ASSERT-R1-GA100-RAS-DETECTION-01` | 同上 | PDF p.6/文档 p.4 `Dynamic Page Offlining` 首段，关键词 `driver identifies the location` |
| `ASSERT-R1-GA100-RAS-DPO-01` | 同上 | PDF p.4/文档 p.2 Table 1；PDF p.6/文档 p.4 全节 |
| `ASSERT-R1-GA100-RAS-RECOVERY-01` | 同上 | PDF p.8/文档 p.6 `Response to Uncorrectable Contained ECC Errors`；PDF p.10/文档 p.8 `Error Recovery and Response Flags` |
| `ASSERT-R1-GA100-RAS-ROW-REMAP-01` | 同上 | PDF p.4/文档 p.2 Table 1；PDF p.7/文档 p.5 `Row-Remapping` 首段与 Table 2；PDF p.8/文档 p.6 service-window flow |

两条需要删除的 v2 assertion 是 `ASSERT-R1-GA100-ID-FAMILY-01-MIG` 与 `ASSERT-R1-GA100-ID-NAME-01-MIG`。`FACT-R1-GA100-ID-FAMILY` 和 `FACT-R1-GA100-ID-NAME` 均已由 whitepaper 的直接 assertion 支持，删除 qualifier 后 evidence state 应按一个 source_id 重算为 `single_source`。

## 最小来源角色与反向移除

| source | 当前建议角色 | 反向移除影响 |
|---|---|---|
| `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001` | 继续 selected；`core_spec`、`reliability_process`、`telemetry_evidence` | 移除会失去 GA100 DPO/row-remap/containment 支持表、contained/uncontained 边界、ordered recovery flow、A100 XID/NVML/SMBPBI/InfoROM telemetry 与 Field Diagnostics。白皮书不能替代。 |
| `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-R595` | 默认 `lead_only`；可用 `current_limit_qualifier` | 与 fixed PDF 同 family，不能提升 evidence_state。若 v3 不把 “GA100 未列 RAS Repair” 作为 current negative boundary，移除不损失正向 GA100 事实；若正式保留该排除结果，才把 R595 作为当前版本 qualifier 纳入 reverse-removal。 |
| `SRC-M2NA-NVIDIA-AMPERE-WP-2020` | 已因 identity/architecture selected；在 RAS 子集中承担 `protection_scope`、`link_replay`、`migration_lead` | 移除会失去 A100 enabled L2/L1/RF SECDED、NVLink packet replay、CI separate context-switch 与 2020 migration concept。它仍不能替代 RAS-PDF 的 field process/telemetry。 |
| `SRC-NVIDIA-MIG-USER-GUIDE-610` | 当前 v2 identity-only 集合改 `lead_only` | 按 v2 事实集合移除只损失两条冗余 identity qualifier，不损失 canonical identity 或 implements-Ampere relation。删除 member `SELMEM-R1-GA100-V2-MIG610` 与 role `SROLE-R1-GA100-NVIDIA-MIG-USER-GUIDE-610-IDENTITY` 后重跑 selection。 |
| `SRC-NVIDIA-MIG-USER-GUIDE-610`，若 v3 接受本报告的 VIRT facts | 候选 selected；`software_virtualization_evidence`、`architecture_mechanism`，不再用 identity role | 此时移除会失去 current GI/CI shared-resource definition、mode/geometry persistence distinction、create/destroy lifecycle、passthrough/vGPU deployment 与 Ampere MIG monitoring limits。必须在事实集合稳定后重新跑 reverse-removal，不能预先沿用 v2 结论。 |

`RAS-PDF` 与 `RAS-595` 是同一家族的不同内容版本。即便二者都因不同角色被保留，也不能把版本差异伪装成独立 corroboration。当前 validator 会按不同 `source_id` 机械计数，因此 v3 不应给同一 canonical fact 同时挂两条同义 `supports`；正向 assertion 由固定 PDF 承担，R595 只保留 current-limit qualifier 或 lead。MIG 610 的八个 HTML endpoint 也只是一份 guide 的章节，不是八个来源。

## v3 最小交接

v3 不需要重新提取五条 RAS 正向事实的 raw value；需要做的是换用本报告的精确 locator、补 `endpoint_id`、重算 fingerprint，并把所有修改行回到 draft。新增信息集中在四处：telemetry/Field Diagnostics 使 `FIELD-RAS-TELEMETRY-BIST` 有值；whitepaper p.35 关闭 ECC 与 storage protection scope；whitepaper p.52 分别关闭 NVLink detection/replay；MIG 610 为 GI/CI partition、GI QoS、mode/geometry lifecycle 和 virtualization deployment 提供条件化 value。

仍需保留的真实缺口只有公开 BIST structure、compute-datapath SDE coverage、hardware degradation modes、CI independent address space、MIG preemption mechanics、量化 QoS、current delivered migration 与 general checkpoint/restart。每个缺口已有字段特定的 checked scope，不应再用白皮书+CUDA Guide 的通用模板句。

## 核验记录

本轮对 `RAS-PDF` 16 页做了全文抽取，并视觉复核 PDF pp.4、7、10、11、15，确认 supported table、row-remap table、recovery flags、telemetry 和 SRAM diagnostic 段没有抽取错列。MIG 610 的八个 article body 逐页抽取，单独检索了 `migration`、`checkpoint`、`restart`、`preempt`、`context switch`、`save and restore`、`SR-IOV`、`distinct address space`、`fault isolation`、`memory QoS`、`reconfigure` 与 `when idle`；零命中和命中均回到相应 heading 与表格核对。所有 payload 的 SHA-256 与 v2 endpoint/manifest 一致，三个候选 stable target 仍不存在，因而本报告没有把 candidate endpoint 误写成正式已落盘 endpoint。

HTML 首次尝试用 BeautifulSoup 解析时，本机缺少 `bs4`，报 `ModuleNotFoundError`。这属于 tool/runtime dependency failure，不是 sandbox denial、approval failure、远程服务错误或来源失效；随后改用 Python 标准库 `html.parser` 对同一 article body 重跑，结果与原始 HTML 定向检索一致。并行子任务调度因 `agent thread limit reached` 未能创建，属于协作运行时容量限制；本轮由当前代理完成全部来源复读，没有缩减来源范围。

本机没有 Windows PowerShell，本报告也没有更改 32 张正式表，因此未运行或声称通过三道 Windows 硬门。交付检查只覆盖来源、locator、边界、hash 与文档表达，不构成正式数据验收。

`report-humanizer` 已对本文件单独扫描。人工逆向复读从 v3 交接、reverse-removal、assertion endpoint、search closure、MIG、RAS、来源身份和开头裁决倒序进行，重点核对了 BIST 与 telemetry 的拆分、SDE 的证据强度、CI shared-memory 边界、MIG 与 SR-IOV 的分离、migration 的交付状态，以及 fixed RAS/R595 同 family 的 evidence count。
