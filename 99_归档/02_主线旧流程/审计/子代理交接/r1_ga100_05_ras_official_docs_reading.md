# GA100 官方 RAS 资料来源级精读

状态：完成，待总控复核  
日期：2026-08-21  
对象：`NVIDIA GA100 die` 及采用 GA100 的 A100 设备  
任务边界：只做来源身份、版本差分和原子事实提取；未修改正式 CSV、进度文件、资料卡、来源表或选择运行

## 审计裁决

NVIDIA 的 `GPU Memory Error Management` 文档家族可以直接证明 GA100 支持 `error containment`、`row remapping` 和 `dynamic page offlining`。三项能力的主体并不完全相同。`error containment` 是 GPU architecture 中的故障限制能力，能够作为 GA100 绑定机制候选；`row remapping` 涉及 GPU 侧机制、HBM/DRAM spare row 和复位生效过程；`dynamic page offlining` 明确由 NVIDIA driver 定位错误并把 framebuffer page 标为不可用。后两项只能按芯片、外部显存、驱动和服务流程的组合能力记录，不能全部压成 GA100 裸片内部电路事实。

当前 R595 文档的 `Supported GPUs` 表没有给 GA100 标记 `RAS Repair for GPU Memory`，其 `GPU Memory Repair` 章节又把该能力限定到部分 Blackwell 产品。GA100 因此不得登记 DRAM channel swap、L2 slice swap 或 XID 160 repair 能力。文档 `Overview` 把多个代际的能力写在同一个概览列表中，不能越过逐 GPU 支持表给 GA100 增加后期功能。

该文档家族的 GA100 核心价值很高，但当前 HTML 会随驱动分支更新。正式入池前应固定一份与 GA100 直接对应的版本。优先选择带文档号和日期的 June 2023 Application Note `DA-09826-002_v001`；如果还要保存 R595 的当前支持矩阵和对 `RAS Repair` 的排除证据，则另存 R595 的 `Supported GPUs` 与 `GPU Memory Repair` 页面。只登记 `latest` URL 不足以支撑长期可复核的正式断言。

## 来源身份和版本

本轮访问日期均为 2026-08-21。下表中的页面均由 NVIDIA 官方站点发布。

| 来源或内容版本 | 精确定位 | 本轮用途 | 固定性判断 |
|---|---|---|---|
| [NVIDIA GPU Memory Error Management, R595](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/index.html) | R595 版本入口；`latest` 当前解析到同一文档结构 | 当前支持矩阵、机制定义、恢复流程和遥测接口 | 版本化 HTML 仍可能被站点内更新。正式入池前应保存页面快照并计算 SHA-256。 |
| [Supported GPUs](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/supported-gpus.html#supported-gpus) | `Supported GPUs`，Table 1 | GA100 三项支持标记与 `RAS Repair` 排除边界 | GA100 对象裁决的关键页，必须固定。 |
| [Error Containment](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/error-containment.html#error-containment) | `Error Containment` 全节及末尾 Note | contained/uncontained 边界和应用影响 | 必须随支持表固定。 |
| [Dynamic Page Offlining](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/dynamic-page-offlining.html#dynamic-page-offlining) | `Dynamic Page Offlining` 全节 | driver 标页、CUDA address-space 排除和无需立即 reset 的条件 | 必须随支持表固定。 |
| [Row Remapping](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/row-remapping.html#row-remapping) | `Row Remapping`，Table 2 | hardware repair 语义、reset、生效持久性和 512 条上限 | 必须随支持表固定。 |
| [Response to Uncorrectable Contained ECC Errors](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/response-to-uncorrectable-contained-ecc-errors.html#response-to-uncorrectable-contained-ecc-errors) | 同名章节，Figure 1 | driver recovery、应用终止、offlining 到 remapping 的过程链 | 适合与前三节保存为同一家族快照。 |
| [Error Recovery and Response Flags](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/error-recovery-and-response-flags.html#error-recovery-and-response-flags) | 同名章节 | 当前 client recovery action 与 SMBPBI 暴露方式 | 软件接口容易变化。只有正式字段需要时才固定并保留。 |
| [User Visible Statistics](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/user-visible-statistics.html#user-visible-statistics) | 同名章节，Table 3 至 Table 6 | XID、NVML、`nvidia-smi`、SMBPBI、InfoROM 统计口径 | 只支持遥测和运维层，不增加独立来源数。 |
| [RAS Repair: GPU Memory Repair](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/hbm-channel-repair.html#gpu-memory-repair) | `GPU Memory Repair` | 证明该 repair 仅面向部分 Blackwell 产品 | 只作 GA100 排除证据，不能当成 GA100 正向能力。 |
| [RMA Policy](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/rma-policy-thresholds-for-row-remapping.html#rma-policy) 与 [SRAM Uncorrectable Errors](https://docs.nvidia.com/deploy/a100-gpu-mem-error-mgmt/595/sram-uncorrectable-errors.html#sram-uncorrectable-errors) | `GPU DRAM Memory RMA Policy`、`GPU L2 Memory RMA Policy`、`SRAM Uncorrectable Errors` | 当前 Field Diagnostic 与 RMA 阈值 | 属于诊断和返修政策；页面没有把每个阈值逐项绑定 GA100。 |
| [June 2023 Application Note](https://docs.nvidia.com/deploy/pdf/nvidia-gpu-mem-error-mgmt.pdf) | `DA-09826-002_v001`，June 2023，16 页；Chapter 2 至 Chapter 10 | GA100/A100 时间对齐的固定版候选 | 有文档号、修订号和日期，适合作为 GA100 正向事实的正式内容版本。当前项目未保存本地副本。 |
| [Release r575 PDF](https://docs.nvidia.com/deploy/pdf/NVIDIA-GPU-Memory-Error-Management.pdf) | Release r575，2025-04-30，30 页 | 检查 Blackwell/Hopper repair 加入后的版本漂移 | 不需要为 GA100 正向事实进入最小集。 |
| [R450 450.51.05/451.48 Release Notes](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-51-05/index.html#new-features) | `1.2 New Features`，driver release date 2020-07-07，last updated 2020-09-29 | 核对 A100 首代公开软件支持、NVML/SMBPBI 和 reset 后 remapping | 只能证明该版本已提供的实现和接口，不能据此宣称所有功能的最低版本。 |

这些章节属于一个 NVIDIA application note 家族。拆成多个 URL 是为了定位原文，不能在 `evidence_state` 中算作多个独立来源。R450 release notes 和 A100 architecture whitepaper 是另外两个来源家族。

## 本地同源资料盘点

在 `论文/`、`最小参考资料库/快照/`、`清单/论文PDF清单.csv`、`清单/网页与在线资料.csv`、`最小参考资料库/source-families.csv`、`sources.csv` 与 `source-endpoints.csv` 中，没有找到 `GPU Memory Error Management`、`DA-09826` 或 `a100-gpu-mem-error-mgmt` 的本地文件或正式登记。因而本轮没有可报告的同源本地 SHA-256，也没有下载网页或 PDF。

现有本地 NVIDIA A100 architecture whitepaper 是补充来源，并非上述文档家族的副本：

| 本地文件 | SHA-256 | 与本任务的关系 |
|---|---|---|
| `论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf` | `3a800ad7668ec37037fa5870a8e3bb681b75f19668b3d11492ab9b0da0d58815` | PDF p.35 给出 A100 HBM2、L2、L1 和 SM register files 的 SECDED ECC 覆盖。它补齐 ECC protection scope，但主体是 A100 enabled implementation，不是无条件的 full GA100 die。 |

## 能力所在层级

| 能力 | 可直接归入的层级 | 不能跨越的边界 |
|---|---|---|
| Error containment | GA100 绑定的 GPU architecture 能力 | “受影响应用终止、其余应用继续运行、新任务可启动”是驱动和运行时共同呈现的结果；厂商关于 accuracy 与 performance 不受影响的表述没有定量验证。 |
| Dynamic page offlining | GA100 支持的 device capability，加 NVIDIA driver 的页面管理 | 定位错误、标记 page 和阻止 CUDA mapping 由 driver 执行。不能写成纯 on-die 自治修复，也不能写入未公开的 page size。 |
| Row remapping | GA100 支持的 hardware repair capability，作用于 framebuffer/HBM | spare rows 位于 HBM/DRAM bank，reset 和 InfoROM/driver 管理参与生效。公开资料没有定位 row-remapper 的具体 on-die block。 |
| ECC | A100 memory subsystem 与 GA100 enabled implementation 中的 cache/register protection | HBM 位于外部 memory stack；白皮书只明确 A100 配置。不能把产品配置的 ECC 覆盖自动扩成 full GA100 每个 SRAM 或 compute path 的覆盖。 |
| Telemetry 与 recovery flags | NVML、`nvidia-smi`、XID、SMBPBI、InfoROM 和 client policy | 属于驱动、管理接口、固件/板级带外管理和部署流程。XID 数字不是芯片物理属性。 |
| Field Diagnostic 与 RMA | NVIDIA 诊断工具和售后政策 | 阈值不能写成 GA100 裸片的故障率、寿命或内建自测试能力。 |
| RAS Repair for GPU Memory | 部分 Blackwell 产品 | GA100 不支持。DRAM channel swap、L2 slice swap 和 XID 160 repair 都应从 GA100 正向事实中排除。 |

## 原子事实和字段映射

下表保留来源主语、适用条件和对象层级。`字段建议` 只供总控建模时参考，不代表已经创建正式事实。

| 编号 | 原子事实 | 精确定位 | 适用对象和条件 | 字段建议 | 裁决 |
|---|---|---|---|---|---|
| RAS-SUP-01 | R595 Table 1 给 GA100 的 `Error Containment` 标记为支持。 | `Supported GPUs`，Table 1 | GA100，功能存在性 | `FIELD-RAS-FAULT-ISOLATION`；可辅以 `FIELD-RAS-CAPABILITY` | 可作为 GA100 绑定事实。不要只写笼统的“支持 RAS”。 |
| RAS-SUP-02 | R595 Table 1 给 GA100 的 `Row remapping` 标记为支持。 | `Supported GPUs`，Table 1 | GA100 及其 framebuffer/HBM 组合 | `FIELD-RAS-CORRECTION-REPLAY`、`FIELD-RAS-RECOVERY` | 可进入，但 notes 应写明 HBM spare row、reset 和软件管理边界。 |
| RAS-SUP-03 | R595 Table 1 给 GA100 的 `Dynamic Page Offlining` 标记为支持。 | `Supported GPUs`，Table 1 | GA100 加 NVIDIA driver | `FIELD-RAS-RECOVERY`、`FIELD-RAS-PROTECTION-SCOPE` | 可作为组合能力，不能标成纯硬件修复。 |
| RAS-EC-01 | Ampere 引入 error containment，用来限制 uncorrectable ECC error 对 GPU applications 的影响。 | `Error Containment` 首段 | GA100；uncorrectable ECC；containment 成功 | `FIELD-RAS-FAULT-ISOLATION`、`FIELD-RAS-PROTECTION-SCOPE` | GA100 绑定机制。错误类型应保留为 UCE，不能泛化到所有故障。 |
| RAS-EC-02 | 成功 containment 时，影响限于遇到错误的应用；其余 workload 可继续，新 workload 可启动。 | `Error Containment` 首段；`Response to Uncorrectable Contained ECC Errors` | contained UCE；兼容驱动与运行时 | `FIELD-RAS-FAULT-ISOLATION`、`FIELD-RAS-RECOVERY` | 属于设备与软件共同呈现的运行行为。厂商的 accuracy/performance 声明应保留为原文口径，不改写成实测保证。 |
| RAS-EC-03 | 仍存在少量 uncontained UCE，可能影响 GPU 上所有正在处理的 workload。 | `Error Containment` 末尾 Note | rare uncontained UCE | `FIELD-RAS-FAULT-ISOLATION` | 必须与 RAS-EC-02 同时保留，防止把 containment 写成绝对隔离。 |
| RAS-DPO-01 | NVIDIA driver 定位 framebuffer memory 中的 uncorrectable error，并把包含该错误的 page 标为 unusable。 | `Dynamic Page Offlining` 首段 | GA100 device、framebuffer UCE、NVIDIA driver | `FIELD-RAS-ERROR-DETECTION`、`FIELD-RAS-RECOVERY` | driver 行为。来源未说明定位电路、page size 或 firmware 分工。 |
| RAS-DPO-02 | 标记后的 page 不再分配给当前或新启动 workload，也不映射到当前或新启动 CUDA kernel 的 address space。 | `Dynamic Page Offlining` 首段和末段 | page 已被 driver offlined | `FIELD-RAS-PROTECTION-SCOPE`、`FIELD-RAS-RECOVERY` | 软件可见隔离行为。不能解释为物理 memory row 已修复。 |
| RAS-DPO-03 | 支持 dynamic page offlining 的 GPU 可从大多数 uncorrectable ECC errors 中恢复，无需立即 GPU reset。 | `Dynamic Page Offlining` 中段 | most UCE；仅限支持 DPO 的 GA100 | `FIELD-RAS-RECOVERY` | “大多数”必须保留。uncontained error 或后续 row remap 仍可能要求 reset。 |
| RAS-RR-01 | Row remapping 是 Ampere 起用于 framebuffer reliability 的 hardware mechanism；HBM/DRAM bank 有 spare rows，用 spare row 替换 degraded memory location。 | `Row Remapping` 首段；June 2023 PDF Chapter 5 | GA100/A100 framebuffer，HBM bank | `FIELD-RAS-CORRECTION-REPLAY`、`FIELD-RAS-PROTECTION-SCOPE` | hardware capability，但 repair 介质跨越 GA100 die 与外部 HBM。 |
| RAS-RR-02 | Row remapping 生效需要 GPU reset，生效后保持持久；与 software offlining 不同，地址空间不留下 software-visible hole。 | `Row Remapping` 首段与 Table 2 | remapping pending；GPU reset/service window | `FIELD-RAS-RECOVERY` | reset 是生效条件。不能改写成错误出现当下已完成物理修复。 |
| RAS-RR-03 | 文档给 Ampere and later framebuffer 的 row remapping 上限为 512 条。June 2023 Table 2 的列名更具体地写作 A100/H100。 | `Row Remapping`，Table 2；June 2023 PDF p.6 | A100/GA100-based device framebuffer；具体实现范围待正式快照复核 | `FIELD-RAS-CAPABILITY` 或 `FIELD-RAS-RECOVERY` | 可作候选数值，但主体宜写 A100 device 或 GA100-based implementation，不能无条件登记为 full GA100 die 常量。 |
| RAS-FLOW-01 | 检测到 UCE 后由 driver 做 recovery；affected application 终止。DPO 阻止新 allocation，之后在正常 GPU/VM service window reset 时由 row remapping 完成 hardware repair，并回收 offlined page。 | `Response to Uncorrectable Contained ECC Errors` 全节，Figure 1 | contained UCE；driver；service-window reset | `FIELD-RAS-RECOVERY`、`FIELD-RAS-CORRECTION-REPLAY` | 应保存为有先后关系的恢复流程，不拆成三个互不相关的芯片能力。 |
| RAS-TEL-01 | A100 memory error reporting 使用 XID 94/95 表示 contained/uncontained ECC，XID 63/64 表示 row-remapping entry 写入 InfoROM 成功/失败。 | `User Visible Statistics`，XID list 与 Table 3；June 2023 PDF pp.10-11 | A100 device、driver log | `FIELD-RAS-TELEMETRY-BIST`、`FIELD-RAS-ERROR-DETECTION` | telemetry 事实。XID 编码和日志格式属于软件接口。 |
| RAS-TEL-02 | NVML/`nvidia-smi` 与 SMBPBI 暴露 correctable/uncorrectable remapped-row count、pending、failure 和 bucketized count；数量是 InfoROM entry，不等同于已在 hardware 中完成的 remap 数。 | `User Visible Statistics`，NVML/`nvidia-smi` 与 SMBPBI 两段 | 支持对应接口的 driver、firmware 和平台 | `FIELD-RAS-TELEMETRY-BIST` | 计数口径必须保留。in-band 与 out-of-band 是两个 endpoint，不是两条独立硬件证据。 |
| RAS-SW-01 | R450 450.51.05/451.48 已加入 A100 支持、`nvmlDeviceGetRemappedRows`、SMBPBI 的 remap failure/pending/count API；release notes 还说明 reset 时 hardware 执行 row remap。 | R450 release notes，`1.2 New Features`，lines corresponding to NVML、Systems 和 SMBPBI | 2020-07-07 版本；A100 40GB 产品与 HGX A100 环境 | `FIELD-RAS-TELEMETRY-BIST`、`FIELD-SW-SUPPORT-MATURITY`、`FIELD-RAS-RECOVERY` | 证明该历史版本已提供相关接口和流程。它不证明 450.51.05 是所有 A100 形态或所有 RAS 功能的最低要求。 |
| RAS-ECC-01 | A100 HBM2 subsystem 使用 SECDED ECC；A100 的 L2、L1 和所有 SM 内 register files 也受 SECDED ECC 保护。 | 本地 A100 architecture whitepaper PDF p.35，`ECC Memory Resiliency` | A100 enabled implementation of GA100；HBM2、L2、L1、register files | `FIELD-RAS-ECC`、`FIELD-RAS-PROTECTION-SCOPE`、`FIELD-RAS-CORRECTION-REPLAY` | 可作为 A100 实现事实。HBM 是产品 memory subsystem；cache/register 在 die 上，但来源没有用 full GA100 主语。 |

## 明确排除项

R595 `Supported GPUs` 的 GA100 列只对前三项打勾，`RAS Repair for GPU Memory` 为空；`GPU Memory Repair` 又明确说该功能只在部分 Blackwell 产品可用。因此下列内容不能进入 GA100 正向事实：DRAM channel swap、L2 cache slice swap、两次同 bank remap 后触发 repair、XID 160 repair 事件，以及 repair 生效所需的 reboot。`User Visible Statistics` 把 XID 160 列在通用遥测清单中，不会改变其产品适用范围。

R595 `Overview` 还列出 “uncorrectable error to correctable error coverage improved by 10%” 和 single-bit ECC correction。10% 没有给出比较基线、故障分布或 GA100 专属主语，不建议录成 GA100 数值。single-bit correction 应由白皮书中有明确保护对象的 SECDED 段落承接，不从跨代概览列表生成一条覆盖全芯片的事实。

R595 的 SRAM threshold、Field Diagnostic 判定和 RMA 条件属于当前诊断/售后政策。页面没有逐项把新阈值绑定 GA100，也没有证明 Field Diagnostic 是 GA100 die 内建 BIST。它们可作为运维线索，不能写成 GA100 的 SRAM 故障率、芯片寿命或自检机制。

Table 5 和 Table 6 的 `640 banks`、`8 remap availability` 是 bucketized-count 示例。文档还明确说 bank remap availability 的精确数不通过 API 或 `nvidia-smi` 提供。不能用示例反推 GA100 的物理 HBM bank 数、每 bank spare-row 数或某个 A100 容量变体的内部组织。

动态 page offlining 没有公开 page size、错误定位硬件、driver 与 firmware 的分工，也没有声明所有 uncorrectable error 均无需 reset。Row remapping 没有公开 remapper block 的位置、InfoROM 具体实现或不同 HBM2/HBM2e SKU 是否共享相同内部预算。这些字段应保留 `not_public` 或 `pending_verification` 的候选状态，不能用常见 CUDA page size、HBM 标准或后代 GPU 资料补齐。

## 版本漂移、冲突和缺口

June 2023 Application Note 是 `DA-09826-002_v001`，支持表覆盖 GA100、GA10x、Ada AD10x 与 GH100。它直接把 Table 2 的 row-remapping 列写作 A100/H100，适合为 GA100/A100 建立时间对齐的正向事实。Release r575 在 2025-04-30 加入 GB100 和 `HBM Channel Repair`，正文一度写成部分 Blackwell/Hopper boards，但支持矩阵只在 GB100 列给出标记。R595 又把名称改为 `RAS Repair for GPU Memory`，支持矩阵只标 GB10x，正文限制到部分 Blackwell 产品，并把 repair 范围扩到 DRAM channel 或 L2 slice。r575 的 “Blackwell/Hopper boards” 与 R595 的 Blackwell-only 文字不一致；两版都没有给 GA100 repair 支持，故该分歧不影响 GA100 排除裁决。

三版稳定不变的部分是 GA100 对 error containment、dynamic page offlining 和 row remapping 的支持，以及 contained UCE、offlined page、service-window reset 和 hardware remap 组成的恢复过程。变化较大的部分集中在新 GPU、repair、XID 列表、recovery action flags 和 RMA/SRAM policy。这说明硬件能力与当前运维接口必须拆开记录。

R450 release notes 给出了 A100 上市期的一个已知可用软件点：2020-07-07 的 driver 已有 A100 支持、NVML remapped-row query、SMBPBI row-remap status 和 reset 后 hardware remap。该文档没有宣称这是唯一最低版本。后续 driver 的新增 flag 或改名只应作为对应版本的软件事实，不能倒灌为 2020 年 GA100 silicon revision 的新增属性。

公开资料仍缺少 GA100 compute datapath 的 silent data corruption 检测覆盖、Tensor Core/CUDA Core 计算结果校验、完整 SRAM parity/ECC map、片上互联 CRC/replay 范围、BIST 结构、现场故障率、FIT rate 和有条件降级模式。`FIELD-RAS-SILENT-DATA-ERROR`、片上互联保护和完整 BIST 不应因存在 memory RAS 文档而标成已覆盖。

## 进入 GA100 最小来源集的价值

`GPU Memory Error Management` 家族应保留。移除该家族后，GA100 的 error containment、dynamic page offlining、row remapping、contained/uncontained 分界和恢复过程都失去直接一手依据，A100 architecture whitepaper 无法替代。正式来源表中宜把整个 application note 作为一个 `source_family`，各章节和 PDF 只作 content version 或 endpoint，不按 URL 增加来源数。

在内容版本选择上，June 2023 `DA-09826-002_v001` 最适合承担 GA100 正向事实。它有固定文档号和日期，且正文直接使用 A100/H100 语境。若只保留该固定版，GA100 三项正向能力和 A100 telemetry 已足够；R595 页面可从正向最小集中移除。若资料卡需要明确记录 “GA100 不具备 Blackwell RAS Repair”，则 R595 `Supported GPUs` 与 `GPU Memory Repair` 的固定快照有不可替代的当前排除价值，应作为同一家族的新内容版本保留。

本地 A100 architecture whitepaper 对 ECC protection scope 仍不可替代。Memory Error Management 明确说 correctable HBM errors 不在 application note 的讨论范围，无法独自支撑 HBM2、L2、L1 和 register files 的 SECDED 覆盖。若 GA100 卡不写 A100 enabled implementation 的 ECC 范围，whitepaper 的这项 RAS 角色才可能从 GA100 RAS 子集中移除；它仍会因身份和架构事实留在整体 GA100 最小来源集。

R450 release notes 只在需要 `FIELD-SW-SUPPORT-MATURITY`、上市期 telemetry availability 或历史 deployment 条件时保留。若正式事实只记录硬件支持和机制语义，它可以移除。Release r575 对 GA100 没有独有事实，适合作为版本审计材料，不进入 GA100 最小来源成员。

## 固定快照后的登记建议

正式入池时可按以下证据链登记：一个 `NVIDIA GPU Memory Error Management` 来源家族；June 2023 PDF 为 GA100 正向主内容版本；R595 两个页面快照仅在保留 repair 排除事实时作为较新内容版本；`latest` 和 `/595/` 是同一版本的不同访问入口，不增加来源数。每个本地文件都应记录原始 URL、访问日期 2026-08-21、MIME、页数或快照文件数、SHA-256 和页面标题。

快照完成前，当前网页只应处于候选或 `pending_verification`。版本化 URL 提高了可定位性，但没有提供内容哈希，NVIDIA Notices 也保留随时修改文档的权利。June 2023 PDF 和 R595 HTML 不能假定内容相同；二者应分别哈希，按 content version 保存。

## 验证和写入边界

本轮逐页核对了 R595 的 Overview、Supported GPUs、Error Containment、Dynamic Page Offlining、Row Remapping、GPU Memory Repair、Response to Uncorrectable Contained ECC Errors、Error Recovery and Response Flags、User Visible Statistics、RMA Policy、SRAM Uncorrectable Errors 与 Notices；同时比对 June 2023 PDF、Release r575 PDF、R450 release notes 和本地 A100 architecture whitepaper p.35。

命令行直接请求 NVIDIA 站点时因当前沙箱的网络/DNS 限制被拒绝，属于 sandbox denial，不是来源失效或解析错误。官方页面随后通过网页读取工具正常访问，未影响正文和表格取证；但没有取得原始 HTML 字节流，因而本轮没有给远程页面计算 SHA-256，也没有把网络内容写入项目。

最终文件已按 `report-humanizer` 的 research note 口径检查。机器扫描结果为 `No machine-detectable AI tells found`。人工逆向复读覆盖了全部标题、各节首段、表格引导、版本转场和结尾，未发现模板化标题、空泛开场或整齐收口；字段标识复核时发现一处未注册的简写，已改为正式的 `FIELD-SW-SUPPORT-MATURITY`。当前没有作者样稿可供语气比对，剩余表达风险主要是英文术语密度较高；这些术语对应官方功能名、接口名和正式字段，未为追求口语化而改写。

本次只新增：

`审计/子代理交接/r1_ga100_05_ras_official_docs_reading.md`

正式 CSV、进度文件、资料卡、来源记录、selection run 和本地资料池均未修改。
