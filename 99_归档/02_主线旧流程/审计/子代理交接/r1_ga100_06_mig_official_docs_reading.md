# GA100 的 NVIDIA 官方 MIG 文档精读

> 子任务：`r1_ga100_06_mig_official_docs_reading`  
> 状态：完成，待总控复核  
> 芯片主体：`NVIDIA GA100 die`  
> 访问日期：2026-08-21，Asia/Shanghai  
> 写入边界：只新增本交接文件；未修改正式 CSV、进度文件、资料卡或来源记录，也未下载或保存网页快照

## 调度和虚拟化边界

NVIDIA 当前的 *Multi-Instance GPU User Guide* 足以确认一条芯片绑定机制链：A100 SXM4、A100 PCIe 和 A30 都在支持表中映射到 `GA100`，这些产品可以用 Multi-Instance GPU（MIG，多实例 GPU）进行物理资源分区。GPU Instance（GI，GPU 实例）隔离 SM、L2、memory controller 和 DRAM 路径，并在 GI 粒度提供 memory QoS 与故障隔离；Compute Instance（CI，计算实例）可继续拆分 GI 的 SM，但同一 GI 内的 CI 共享该 GI 的 memory slices 和 engines。这个边界可以进入 0.3 资料卡的 virtualization、scheduling 和 fault isolation 候选事实。

文档不能把 `7`、40/80 GB、`1/8 memory + 1/7 SM`、copy engine 数量或具体 profile 写成完整 GA100 裸片的无条件属性。当前支持表同时列出 A100 最多 7 个实例、A30 最多 4 个实例，而两者都映射到 GA100；这已经证明实例上限和 profile geometry 受到具体产品配置约束。MIG User Guide 也没有确认 SR-IOV 是 MIG 的实现方式，没有说明 CI 的完整地址空间隔离，没有给出 context-switch state、抢占延迟或定量 QoS，更没有给出可执行的 migration/checkpoint 接口。因此，2020 年 A100 白皮书中的 `MIG Migration` 仍只能作为待补证线索，不能据此建立通用 checkpoint/restart 或 live migration 事实。

## 来源身份、版本和本地盘点

### MIG User Guide 来源家族

本轮把下列页面视为同一个来源家族，不按章节或 URL 增加独立来源数。根入口会跳转到 `latest/`；页面脚本的版本选择器显示 `610`，其 `versions1.json` 只有一个 preferred 记录。页面没有给出可供长期引用的出版日期或修订记录。HTTP `Last-Modified` 均为 2026-06-22，但它只反映服务器对象时间，不能替代正式文档版本号。

| 页面与精确 URL | 本轮定位 | 2026-08-21 原始 HTML SHA-256 | HTTP ETag |
|---|---|---|---|
| [Introduction](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/introduction.html) | `Introduction`、Figure 1 | `970cf62e3a98556a48a8298401a45a3b12e22c072676bc8b587186cb87e9f3e0` | `e942aaf1a60a2dd5ae4b43f261f925c3` |
| [Supported GPUs](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-gpus.html) | Table 1 `Supported GPU Products` | `dbb01db2b63712d275812034d115b58deda6d45d01ec2a50617d92b663a3550f` | `8f1b39f1c9853f038a8ed2abfe43bab1` |
| [Supported Configurations](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-configurations.html) | 三种部署配置 | `6842dbd29461b60e346cfabe269e00adce7c9ea1c1088491d1fcdfa9d86b7624` | `31ec371aaf566720135edd5368a24f1e` |
| [Virtualization](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/virtualization.html) | passthrough、MIG-backed vGPU | `9918d361afd314aa5833e9d79ea98679133204970274ecaa6a25b5658e750bb9` | `46f02c0e46347b69b8a6bbdd4bbe8779` |
| [Concepts](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/concepts.html) | `Terminology`、`Partitioning`、Table 2、Table 3 | `4413498cd49a04ef015dc0fd5bc96ac2c909dc35302b7a3625505ce30e4e9057` | `44c53b6dfdf9bea4e7d4d3b11eb0cfbd` |
| [Deployment Considerations](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/deployment-considerations.html) | driver 表、`System Considerations`、`Application Considerations` | `fd8e343f987aada7902d700a083f8b3e0682ee483153d45ddf0de70431219870` | `2e15839b9536640caafd9b1b006d27ca` |
| [Supported MIG Profiles](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-mig-profiles.html) | `A100 MIG Profiles` Table 12、`A30 MIG Profiles` Table 13 | `9db72a775752aca20c2f0974945d902752df1cbccb619d191815548cc62dea6f` | `66978a77e9efeeba871458375fa82aec` |
| [Getting Started with MIG](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/getting-started-with-mig.html) | `Enable MIG Mode`、Ampere reset、GI/CI 创建与销毁、MPS | `c7b6645eaa02601739adc78470e0963a02422f64ae46e2b1c470fac0cd95c9d2` | `f9f6cff55cbff3273649baacbc154d4d` |

这里的 SHA-256 是访问当日对网络响应逐页计算的指纹，没有对应本地文件。`清单/网页与在线资料.csv` 只有两条历史线索：第 819 行 `SRC-2026-NVIDIA-MIG-GPUS` 和第 855 行 `SRC-2026-NVIDIA-MIG-PROFILES`。正式 `source-endpoints.csv`、`sources.csv`、`source-versions.csv` 没有登记 MIG User Guide，本地资料池也没有同源 HTML 或 PDF。按任务边界，本轮没有擅自下载。

正式入库前必须固定快照。建议把上述页面连同表格、图注和引用图片保存为同一内容版本，记录页面 URL、访问时间、`Last-Modified`、ETag、逐文件 SHA-256 和 guide version selector `610`。只保存纯文本会丢失 profile placement 图，无法长期核对物理 placement 与 fragmentation。拟议来源家族可用 `SFAM-R1-NVIDIA-MIG-USER-GUIDE`，具体 ID 仍由总控分配。

### 相关固定来源和辅助来源

本地 A100 白皮书属于另一个来源家族：`论文/NVIDIA_GPU/90_官方白皮书与技术资料/2020_NVIDIA_A100_Architecture_Whitepaper.pdf`，SHA-256 为 `3a800ad7668ec37037fa5870a8e3bb681b75f19668b3d11492ab9b0da0d58815`。它直接给出 CI 独立 context switch、SR-IOV 和概念性的 `MIG Migration`，不能与动态 MIG User Guide 合并计数。

MIG User Guide 还链接了一份固定技术简报 [NVIDIA Multi-Instance GPU and NVIDIA Virtual Compute Server, TB-10226-001_v01](https://www.nvidia.com/content/dam/en-zz/Solutions/design-visualization/solutions/resources/documents1/TB-10226-001_v01.pdf)。该 PDF 标注 2020 年 11 月、17 页，访问当日网络内容 SHA-256 为 `e0c40ad240890c9398472b19cf73cd7db9d1b16053b3826a304c27c546f08563`。它没有本地副本。该文档适合解释 2020 年 vGPU 11.1 的 A100 部署语境，不适合充当 2026 年 vGPU 支持矩阵。

## 原子事实和字段映射

下表中的“可进入”仍表示候选抽取，正式事实需要总控建立对象、条件和来源断言。

| 编号 | 原子事实与定位 | 对象和条件 | 0.3 字段 | 入库判断 |
|---|---|---|---|---|
| MIG-ID-01 | `Supported GPUs` Table 1 把 A100-SXM4 40/80 GB、A100-PCIE 40/80 GB 和 A30 的 `Microarchitecture` 都写为 GA100，`Compute Capability` 为 8.0。 | 产品到 GA100 的映射；不包含发布日期、die 面积或产品可用状态 | `FIELD-VIRT-PARTITIONING`，身份关系由对象表承接 | 可进入产品实现到 GA100 的证据链。支持表使用 `Microarchitecture` 列，需与白皮书的 GA100 die 身份共同使用。 |
| MIG-ID-02 | 同一表给 A100 四种产品行标 `Max Number of Instances=7`，A30 标 `4`。 | A100 或 A30 具体产品配置 | `FIELD-VIRT-PARTITIONING` | 只可条件化记录。两种 GA100 产品的上限不同，不能建立无条件 `GA100 max_instances=7`。 |
| MIG-PART-01 | `Introduction` 说明 GI 的 processor 路径经过独立的 on-chip crossbar ports、L2 cache banks、memory controllers 和 DRAM address busses。 | MIG-enabled NVIDIA Ampere GPU；由支持表和白皮书绑定到 GA100 产品实现 | `FIELD-VIRT-PARTITIONING`、`FIELD-VIRT-MULTI-TENANCY` | 可进入 GA100 绑定机制。文档没有给出 full GA100 的 slice 数量或所有资源的物理总数。 |
| MIG-QOS-01 | 独立路径使一个 GI 在其他 GI 扰动 cache 或 DRAM 时仍获得固定 L2 allocation 和 DRAM bandwidth，文档称其提供可预测 throughput/latency、memory QoS 和 fault isolation。 | 不同 GI 之间；厂商功能声明，没有定量界限 | `FIELD-VIRT-PREEMPTION-QOS`、`FIELD-RAS-FAULT-ISOLATION` | 可记录 `vendor_claimed/documented_supported`。不得派生 latency 上界、带宽保证百分比或错误覆盖率。 |
| MIG-CTX-01 | `Concepts` 的 GPU Context 定义包含 distinct address space、fault isolation 和 individually scheduled。GPU engine 可独立调度并执行不同 context 的工作。 | GPU context；不是 GI 或 CI 的同义词 | `FIELD-COMP-CONTROL-SCHEDULING`、`FIELD-MEM-VIRTUAL-MEMORY` | 只支撑 context 粒度。不能改写成“每个 GI/CI 必有独立地址空间”。 |
| MIG-GI-01 | GI 由 GPU slices 与 DMA、NVDEC 等 engines 组成；GI 内对象共享其 memory slices 和其他 engines，SM slices 还能拆成 CI。GI 的 memory slice 限定可用容量和带宽并提供 memory QoS。 | GI | `FIELD-VIRT-PARTITIONING`、`FIELD-COMP-SHARED-RESOURCE`、`FIELD-VIRT-PREEMPTION-QOS` | 可进入。GI 是 memory/QoS 和主要硬件隔离边界。 |
| MIG-CI-01 | CI 取得父 GI 的部分 SM slices；同一 GI 内各 CI 有 dedicated SM resources，但共享父 GI 的 memory 和 engines。 | 同一 GI 内的多个 CI | `FIELD-VIRT-PARTITIONING`、`FIELD-COMP-SHARED-RESOURCE` | 可进入。不能给 CI 写独立 memory bandwidth QoS、独立 L2 或完整 engine isolation。 |
| MIG-CI-02 | `Getting Started` 的 A100 例子在一个 GI 内创建三个 CI，并运行三个 CUDA process；`Application Considerations` 允许 CUDA IPC 跨 CI，不允许跨 GI。 | A100 40 GB 示例、当时的 driver/CUDA 行为 | `FIELD-SW-CHIP-BOUND-SCHEDULING`、`FIELD-VIRT-MULTI-TENANCY` | 可支持 CI 并发和 GI/CI 边界。示例数值与 profile 不能下放到 full GA100。 |
| MIG-PROF-01 | `Concepts` 明说分区说明以 A100-40GB 为例：8 个 5 GB memory slice、7 个 SM slice。A100 80 GB profile 名按容量比例变化。 | A100 40/80 GB 产品 profile | `FIELD-VIRT-PARTITIONING` | 只作产品条件。`5/10/20/40/80 GB` 均不是 die memory capacity。 |
| MIG-PROF-02 | `Supported MIG Profiles` Table 12 给 A100 1g、2g、3g、4g、7g profiles、L2 比例、copy engine 和 media engine 数；Table 13 给 A30 1g、2g、4g profiles与四分之一粒度。 | 分别绑定 A100 40/80 GB 和 A30 24 GB | `FIELD-VIRT-PARTITIONING`、`FIELD-COMP-UNIT-COUNT` | 若资料卡需要产品投影，可条件化保存；不进入 GA100 裸片的无条件资源字段。 |
| MIG-PLACE-01 | GI 只能按 driver 提供的 profiles 创建；物理 placement 会产生 fragmentation，并限制随后可创建的 profile。R510 以前不支持特定 4-memory/4-compute 与 4-memory/3-compute 组合，后续取消该限制。 | A100 profile placement、driver revision | `FIELD-SW-CHIP-BOUND-SCHEDULING`、`FIELD-COMP-UTILIZATION-LIMIT` | 可记录为资源配置限制。它不是 runtime job scheduler 的队列策略。 |
| MIG-CONC-01 | `Concepts` Table 3 把 Streams、MPS、MIG 分为 single-process、logical、physical partition。MIG 有 SM performance isolation、memory protection、memory bandwidth QoS 和 error isolation；MPS 的 scheduling hardware、memory bandwidth、cache 和 capacity 仍共享，且无 client error isolation。 | CUDA concurrency mechanisms；MIG/MPS 软件条件 | `FIELD-VIRT-MULTI-TENANCY`、`FIELD-VIRT-PREEMPTION-QOS` | 可进入对照事实。Table 3 的 `MIG max partitions=7` 是 A100 时代的概括，不能覆盖当前支持表中的 2/4/7 产品差异。 |
| MIG-MPS-01 | MPS 可以运行在 MIG 之上；最大 48 个 client 按 CI size 比例下降。示例要求每个 MIG GPU instance 使用独立 MPS server，MIG mode 不支持 `EXCLUSIVE_PROCESS`。 | MIG device + MPS；软件版本未冻结 | `FIELD-SW-CHIP-BOUND-SCHEDULING`、`FIELD-VIRT-MULTI-TENANCY` | 可记录 documented support 与限制。MPS 不继承 MIG 的 client 间 error isolation，不能把两层隔离混写。 |
| MIG-VIRT-01 | `Supported Configurations` 和 `Virtualization` 列出 bare metal/container、整卡 GPU passthrough 到 Linux guest，以及 supported hypervisor 上的 vGPU。passthrough 模式沿用 bare-metal workflows/tools/profiles。 | 支持的 Linux 与 hypervisor；具体版本另查 | `FIELD-VIRT-MULTI-TENANCY`、`FIELD-SW-SUPPORT-MATURITY` | 可记录部署形态，不代表 GA100 自身实现 hypervisor 或 orchestration。 |
| MIG-VIRT-02 | MIG-backed vGPU 允许一块支持 MIG 的 GPU 上并行运行多个 vGPU/VM，并保留 vGPU 的 isolation guarantees。 | vGPU 软件栈、Linux guest、supported hypervisor | `FIELD-VIRT-MULTI-TENANCY`、`FIELD-VIRT-PREEMPTION-QOS` | 可记录组合能力。当前链接的 AI Enterprise 锚点已跳到文档总入口，缺少可固定的具体版本支持矩阵。 |
| MIG-MODE-01 | A100/A30 启用 MIG mode 时需要 per-GPU reset，要求管理权限，并需先停止持有 driver handle 的 daemon。Ampere 上 mode state 存于 InfoROM，跨 reboot 持久，直到显式关闭。 | A100/A30，NVIDIA Ampere，Linux driver | `FIELD-VIRT-PARTITIONING`、`FIELD-SW-RUNTIME` | 可进入部署限制。reset 是模式切换条件，不应登记为 RAS recovery。 |
| MIG-DYN-01 | mode 启用后，GI/CI 可动态创建和销毁；创建出的 MIG devices/geometry 不跨 system reset 或 reboot 持久，需要重建。`Concepts` Table 3 同时把 MIG reconfigure 写为 `When Idle`。 | 已启用 MIG mode；目标 instance 空闲 | `FIELD-SW-CHIP-BOUND-SCHEDULING`、`FIELD-VIRT-PARTITIONING` | 可进入。`dynamic` 指管理面创建/销毁，不等于 busy instance 原地 resize、状态保留或 live migration。 |
| MIG-APP-01 | 当前 `Application Considerations` 写明：R570 时只支持同一 GPU 内 MIG instance 的 P2P；不支持跨 GPU 的 MIG P2P 或 MIG 到 non-MIG GPU；跨 GI CUDA IPC 不支持，跨 CI 支持；GI 支持 GPUDirect RDMA；当前 MIG 不支持 NCCL。 | driver R570 或当前指南状态；具体 GPU 与软件版本需另验 | `FIELD-SW-COMMUNICATION-LIBRARY`、`FIELD-INT-REMOTE-MEMORY`、`FIELD-CAP-LIMITATION` | 只作 current software limitation 候选，不能写成 GA100 永久硬件属性。 |
| MIG-MON-01 | Ampere A100/A30 上 NVML 和 `nvidia-smi` 不支持把 utilization 归因到 MIG device，指南建议 DCGM v3 或更新版本。 | Ampere A100/A30、监控工具版本 | `FIELD-RAS-TELEMETRY-BIST`、`FIELD-SW-RUNTIME` | 可记录观测限制。它不表示硬件没有计数器，也不证明 DCGM 能观测所有 shared resource。 |

## GI、CI、MPS 的共享和隔离关系

| 维度 | 不同 GI | 同一 GI 内的不同 CI | 同一 MIG device 内的 MPS clients |
|---|---|---|---|
| SM | 物理分区，指南声明 performance isolation | 每个 CI 有 dedicated SM slices | 可按比例限制，但 scheduling hardware 仍共享 |
| L2、memory controller、DRAM path | GI 之间分配独立路径，GI 提供 memory QoS | 共享父 GI 的 memory slices；没有 CI 级 memory QoS 说明 | memory bandwidth、cache 和 capacity 共享 |
| Copy/media engines | 分配给 GI，具体数量由 product profile 决定 | 指南明确 CI 共享父 GI 的 engines | 共享所在 MIG device 的资源 |
| 地址空间 | 指南只确认 GPU context 有 distinct address space；未直接把它提升为 GI 属性 | 没有 CI 独立地址空间声明，且允许跨 CI CUDA IPC | MPS client 的内存保护与地址空间语义需读 MPS 文档，当前指南只说明逻辑共享 |
| 调度 | client 不应影响其他 GI 的 work/scheduling；engine 可按 context 独立调度 | 可并行运行多个 CI，但当前指南没有披露 CI context-switch state | MPS client 共享 scheduling hardware |
| QoS 和 fault isolation | 有 memory QoS、error/fault isolation 的厂商声明 | 没有完整 CI 级 fault isolation 或 memory QoS 保证 | MPS client 之间无 error isolation |
| IPC | 跨 GI CUDA IPC 不支持 | 跨 CI CUDA IPC 支持 | MPS 使用自己的 IPC control channel，不能据此推导 CUDA IPC 边界 |

这个矩阵说明 GI 是当前 MIG User Guide 能直接支撑的内存与故障隔离边界。CI 提供计算资源拆分和并发，但仍处在同一个 GI 的共享内存与 engine 域内。资料卡若把 CI 也写成“完整硬件隔离实例”，会超过来源。

## SR-IOV、vGPU、context switch 和迁移

SR-IOV（Single Root I/O Virtualization，单根 I/O 虚拟化）、vGPU 与 MIG 是相邻机制，当前证据不允许把三者画等号。MIG User Guide 的 virtualization 页面只列 passthrough 与 MIG-backed vGPU，没有出现 `SR-IOV`。本地 A100 白皮书 pp.17、53 单独说明 A100 支持 SR-IOV，允许一个 PCIe-connected GPU 通过 PF/VF 服务多个 process 或 VM；这能支撑 A100 产品的 PCIe virtualization，不能证明每个 GI 就是一个 SR-IOV VF，也不能证明 MIG-backed vGPU 必须由 SR-IOV 承载。

2020 年 `TB-10226-001_v01` 把 MIG-backed vGPU 描述为空间硬件分区，把 non-MIG vCS vGPU 描述为 temporal software partition。后者用 GPU hardware scheduler 做 time slicing，负载低时可回收空闲 GPU cycles，负载高时会受 context switching 影响；MIG 的空闲 slice 不会自动借给繁忙 partition。该技术简报的 Table 1 对 MIG-backed vGPU 写有 address-space isolation，但主语是 vGPU VM，不足以证明裸机 GI 或同一 GI 内 CI 的虚拟地址空间结构。

当前 MIG User Guide 对 context switch 的表述停在 GPU context individually scheduled 和 engine independently scheduled。它没有说明 CI 的保存状态、切换延迟、抢占边界或 fairness。A100 白皮书 p.51 另行说明每个 CI 可与其他 CI 分别 context switch；若总控接受该事实，应把白皮书作为主断言，MIG User Guide 只用于补 GI/CI 的资源共享边界。

本轮对 MIG User Guide 全部目录页检索了 `migration`、`checkpoint`、`context switch`、`preempt`、`save and restore` 与 `SR-IOV`。除 `Reconfigure=When Idle` 外，没有找到 migration、checkpoint、CI context switch 或 SR-IOV 的支持陈述。A100 白皮书 p.52 的 `MIG Migration` 说 vGPU state 可保存并恢复到具有相同 GPU-slice 数的另一个 GI，也描述了跨 GPU 装箱和维护场景；白皮书没有软件版本、命令/API、hypervisor 支持表、停机时间、内存脏页处理或失败恢复条件。2020 年 vGPU 技术简报也没有出现 migration 或 checkpoint。当前证据只能把 `FIELD-RAS-CHECKPOINT-RESTART` 和 migration 相关 `FIELD-RAS-RECOVERY` 保留为 `pending_verification`。

## 动态配置的状态边界

| 阶段 | 官方文档能确认的动作 | 不能推导的能力 |
|---|---|---|
| MIG mode disabled | A100/A30 按 per-GPU 切换 mode；启用时 driver 尝试 reset | 无 reset 切换、任意用户直接切换 |
| MIG mode enabled | mode state 在 Ampere 上跨 reboot 持久 | GI/CI geometry 也跨 reboot 持久 |
| 创建 geometry | 先按 profile 创建 GI，再创建 CI；driver 决定 mixed-profile placement | 任意 slice 数、任意 placement、无 fragmentation |
| 运行中 | 不同 GI 或 CI 可运行不同 CUDA process；MPS 可叠加 | 空闲 slice 自动借给繁忙 GI、busy GI 原地 resize |
| 重配置 | 空闲时销毁 CI，再销毁 GI，随后按新 profile 重建 | 保留 workload state 的 resize、live migration、transparent checkpoint |
| reset 或 reboot 后 | MIG mode 仍可保持 enabled，但 MIG devices 需要重建 | 自动恢复原有 GI/CI 与应用状态 |

`dynamic instance management` 应按上表解释为控制面生命周期操作。技术简报声称一个 GI 的创建或销毁不影响其他 GI，这可以作为 2020 年 A100 管理语境的辅助陈述；正式采用前仍应由固定 MIG User Guide 快照或当前 NVML 文档复核。

## 冲突、版本异常和缺口

当前 guide version `610` 的 `Deployment Considerations` 与 `Getting Started` 各有一张相同 driver 表。HTML 按行读取后，A100/A30 对应 `CUDA 11 + R525 (>=525.53)`，H100/H200 对应 `CUDA 12 + R450 (>=450.80.02)`。同一指南的 A100 示例却使用 450.80.02，capability 段落也说 `/dev` 控制接口从 450.80.02 起可用；A100 profile 注释又分别提到 R470、R510 和 R525。H100/H200 对应 R450 的顺序也与产品时间线不相容。这个异常来自官方页面本身，不是纯文本抽取错位。本轮不采用 A100/A30 的最低 driver 定值；应在固定快照后通过 NVIDIA release notes 或历史归档确认表格是否把 A100 与 H100 行对调。

指南开头的 `up to seven` 与 `Concepts` 中 `memory slice roughly 1/8`、`SM slice roughly 1/7` 也不能作为所有 MIG GPU 的通则。当前 `Supported GPUs` 已列 2、4、7 三种上限，A30 Table 13 使用 1/4 memory 与 1/4 SM。对 GA100 工作包，应把 1/8 与 1/7 限定到 A100 产品 geometry，把 1/4 与 1/4 限定到 A30。

2020 年技术简报写 A100 MIG 不支持 NVLink，而当前指南写 R570 支持同一 GPU 内 MIG instance P2P。两者时间和软件条件不同，宜解释为功能演进，不建立硬件冲突。任何 `P2P supported` 事实都要带 driver、same-GPU 和 endpoint 类型条件。

尚未关闭的字段如下：

| 字段 | 当前状态 | 缺少的证据 |
|---|---|---|
| `FIELD-MEM-VIRTUAL-MEMORY` 的 GI/CI 地址空间 | `pending_verification` | NVML/CUDA/vGPU 文档对裸机 GI、同 GI CI 和 MIG-backed vGPU 分别给出的 VA、IOMMU 与 memory-protection 语义 |
| `FIELD-COMP-CONTROL-SCHEDULING` 的 CI context switch | 白皮书可作直接候选，MIG guide 未复核 | 固定版 current MIG/NVML 文档中的 CI context-switch 粒度、state 和限制 |
| `FIELD-VIRT-PREEMPTION-QOS` 的抢占和定量 QoS | `pending_verification` | 抢占粒度、优先级、公平性、latency 或 bandwidth guarantee 的公开规格 |
| `FIELD-RAS-CHECKPOINT-RESTART` | `pending_verification` | 已发布 vGPU migration/checkpoint 产品文档、版本、hypervisor matrix、API 和恢复语义 |
| `FIELD-RAS-RECOVERY` 的 MIG migration | `pending_verification` | 证明 2020 白皮书概念已经交付，并区分同 GPU、跨 GPU和跨主机 |
| SR-IOV 与 MIG-backed vGPU 的关系 | `pending_verification` | 明确说明 PF/VF、GI、CI 与 vGPU 对应关系的 A100 vGPU 部署文档 |
| A100/A30 最低 driver | `conflicting_unresolved` | 修正后的 official release matrix 或带版本历史的归档指南 |

## 排除项

下列内容不进入 GA100 裸片的无条件事实：A100 的 7-way 上限、A30 的 4-way 上限、40/80/24 GB memory capacity、5/10/20/40/80 GB profile 名、各 profile 的 SM/L2/copy/media engine 数量、A100/A30 CUDA 与 driver 最低版本、vGPU 11.1、hypervisor 产品名、Kubernetes/Container Toolkit/Slurm 版本、R570 P2P 行为、NCCL 当前限制和 DCGM 版本。它们分别属于产品 profile、软件版本或部署环境。

也不建立以下推断：`MIG=SR-IOV`、`GI=VF`、每个 CI 有独立地址空间、CI 具有完整 memory QoS 与 fault isolation、MIG 可把空闲 SM 周期动态借给其他 GI、GI 可在线改 profile、MIG mode 持久等于 MIG geometry 持久、白皮书中的 migration 等于已交付的透明 checkpoint/restart。GPU Instance 与虚拟 GPU 实例也应分开；前者是 MIG 的资源对象，后者是 vGPU 软件暴露给 VM 的设备。

## 最小来源集与反向移除

若 GA100 最终接受 MIG identity、GI/CI 资源边界、memory QoS、fault isolation、MPS 对照、mode reset/persistence 和 virtualization deployment 这些事实，MIG User Guide 家族不能移除。移除后，白皮书仍能说明 MIG 的 2020 年架构愿景，却会失去当前支持表中 A100/A30 到 GA100 的清楚映射、CI 共享 memory/engines 的规范定义、mode 与 geometry 持久性的区别，以及当前 passthrough、vGPU、IPC、P2P、MPS 和监控限制。建议入选角色为 `identity_support`、`architecture_mechanism` 与 `software_virtualization_evidence`，但在 selection run 中仍只计一个来源家族。

`TB-10226-001_v01` 的独有价值是 2020 年 A100 MIG-backed vGPU 与 non-MIG temporal vGPU 的直接对照，以及 vGPU VM address-space isolation 的特定陈述。若资料卡不接受 vGPU temporal scheduling、MIG-backed vGPU address-space 或空闲 cycle harvesting 事实，这份简报可由白皮书与 MIG User Guide 覆盖，默认不进入最小集。若接受这些事实，它可以作为单独的历史软件来源进入反向移除测试，但必须标注 `vGPU 11.1+ / November 2020 / A100`，不能当成当前支持状态。

正式入库前的最小动作是固定 MIG User Guide 快照并解决 driver 表异常。若要关闭 migration/checkpoint 与 SR-IOV/vGPU 关系，还需定向读取有明确版本的 NVIDIA vGPU release notes、hypervisor support matrix 和 migration feature 文档。没有这些材料时，保留 `pending_verification` 比使用 2020 白皮书的概念描述更稳妥。

## 写入和验证

本轮写入文件只有 `审计/子代理交接/r1_ga100_06_mig_official_docs_reading.md`。网络访问经批准后完成；一次全站关键词扫描因 shell 页面列表分词错误失败，随后改用逐行读取重跑成功，属于操作命令错误，不是审批、沙箱或远程服务问题。重跑覆盖了指南目录中的全部页面，未发现 migration、checkpoint、SR-IOV 或 CI context-switch 的 current-guide 说明。

交付前已用 `report-humanizer` 执行机器扫描，并人工复读标题、各节首段、表格引导、转场和结尾。人工逆向检查重点核对了三类容易显得机械的写法：GI/CI/MPS 对照是否处于同一抽象层级，动态配置是否按状态过程表达，结尾是否落到固定快照和待补证动作。最终稿没有把事实、限制与下一步混成同一层级清单。
