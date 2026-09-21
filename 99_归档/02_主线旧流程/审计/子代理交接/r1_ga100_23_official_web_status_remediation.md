# GA100 v3：官方网页、产品状态与虚拟化交付补证

访问日期为 2026-08-21。检索范围只含 NVIDIA 官方网页与官方 PDF，未使用媒体报道、经销商报价、二手市场或云厂商价格替代 NVIDIA 原始材料。本轮只提交审计交接报告，没有改正式表、资料卡、模板、validator、进度文件或既有 staging。

本轮补证能确定三件事。GA100 最迟在 2020-05-14 已由 NVIDIA 技术博客直接公开命名，同日 A100 作为基于 Ampere 的产品被正式宣布进入量产并向客户发货。到 2026-08，A100 系列仍处于 NVIDIA vGPU 软件 full support 阶段，并列入 NVIDIA AI Enterprise Infra 8.2 的支持矩阵。vGPU Live Migration、Suspend-Resume 和 time-sliced vGPU 的时间片抢占均已有当前交付文档；这些能力依赖 A100 产品、vGPU 软件、license、hypervisor 与兼容配置，不能写成 GA100 full die 的无条件能力。GA100 full die 的公开目录价仍未找到，DGX A100 系统的 199,000 美元起售价也不能换算或下放为 die price。

## 对象边界

| 对象 | 本轮允许写入的事实 | 禁止下放的事实 |
| --- | --- | --- |
| `OBJ-NVIDIA-GA100-DIE` | 官方直接命名 GA100 的日期；full GA100 与 A100 enabled implementation 的身份边界 | A100 卡的 HBM 容量、TDP、价格、产品 support phase、vGPU profile、hypervisor 能力 |
| A100 enabled GPU implementation | 108-SM enabled implementation、基于 GA100、2020-05-14 量产和发货事件 | full GA100 128-SM 资源总数之外的推导；独立 GA100 die 销售状态 |
| A100 PCIe、SXM4、HGX SKU | card/module 规格、GPU SKU、MIG profile、vGPU type、软件支持条件 | GA100 full die price、die power、die availability |
| DGX/HGX system 与 cloud instance | 系统/服务价格、系统可用性、系统部署 | 单卡价格、module 价格、die 价格 |
| NVIDIA vGPU / AI Enterprise 软件栈 | Live Migration、Suspend-Resume、vGPU scheduler、支持的产品与平台版本 | raw MIG 自动具备迁移；GA100 die 自动具备 checkpoint；所有 hypervisor 均支持 |

投影规则不变。只有 `FIELD-ID-ARCH` 可沿已经批准的 `implements_architecture` 关系投影。A100 产品状态、vGPU 迁移、Suspend-Resume、scheduler preemption 和产品价格均应保留在直接命名的产品或软件对象上，再由资料卡 reachability 展示；不能复制为 `OBJ-NVIDIA-GA100-DIE` 的 same-target fact。

## 身份、首次公开与发布日期

NVIDIA Technical Blog 的 [NVIDIA Ampere Architecture In-Depth](https://developer.nvidia.com/blog/nvidia-ampere-architecture-in-depth/) 页面显示发布日期 2020-05-14。`Key features` 首段直接写出 GA100 powers A100；`A100 GPU hardware architecture` 又分别列出 full GA100 的 128 SM 与 A100 implementation 的 108 SM。它给出了当前计划内最早可复查的 GA100 官方直接命名日期，也把 full design 和 enabled product implementation 分开。

NVIDIA Newsroom 的 [A100 launch press release](https://nvidianews.nvidia.com/news/nvidias-new-ampere-data-center-gpu-in-full-production) 同样标注 2020-05-14，首段写明 A100 当日宣布、已进入 full production 并向全球客户发货。Newsroom 同时提供 [固定 PDF endpoint](https://nvidianews.nvidia.com/_gallery/download_pdf/5ebd41a5ed6ae54cffe0332f/)，PDF p.1 保留相同的 production/shipping 陈述。该日期属于 A100 产品事件。它证明 A100 在该日量产和发货，不能单独证明 NVIDIA 对外销售 standalone GA100 die，也不能自动成为 GA100 die 的 availability date。

据此，`REQ-R1-GA100-V2-ID-RELEASE-DATE` 可以拆成两种语义裁决。若字段定义接受“首次由厂商公开命名”，2020-05-14 可作为直接命名 GA100 的 `first_official_publication_date`；raw value 必须保留该措辞。若字段要求 standalone die 的产品发布或销售日期，则本轮仍为 `not_found`。`REQ-R1-GA100-ID-AVAIL` 对 GA100 die 维持 `not_found`，但可建立一条关联 A100 产品的 `2020-05-14, in full production and shipping` 事实。两条日期不能合并成一个无条件的 die release/availability 值。

40 GB PCIe Product Brief `PB-10137-001_v03` 的 PDF viewer pp.5、7（document pp.1、3）写明 A100 PCIe card 基于 Ampere GA100，并给出 `GPU SKU GA100-883AA-A1`。80 GB PCIe Product Brief 虽然 URL 文件名仍含 `v02`，PDF 内部文档标识为 `PB-10577-001_v03`，同样在 viewer pp.5、7（document pp.1、3）写明 card 基于 GA100 并列出 `GA100-893...` GPU SKU。它们适合补 A100 card 到 GA100 SKU 的身份链，不参与 full-die 数量、价格或产品状态投影。

## 当前支持状态与硬件状态

[NVIDIA Virtual GPU Software Lifecycle on Supported GPUs](https://docs.nvidia.com/vgpu/news/vgpu-software-lifecycle-on-supported-gpus/index.html) 的标题日期为 2026-08-03，页脚更新日期为 2026-08-04。Appendix A 的 `have not reached the end of the full support phase and remain fully supported` 列表包含 NVIDIA A100、A100 DX、A100 PCIe、A100 PCIe 80GB 和 A100X。这个结论只描述 vGPU software support phase。

[NVIDIA AI Enterprise 8.2 Support Matrix](https://docs.nvidia.com/ai-enterprise/release-8/latest/support/support-matrix-8/8.2.html) 是页面自述的 version-pinned 8.2 矩阵，2026-08-17 更新。`Supported NVIDIA Infrastructure Software` 给出 Data Center GPU Driver 595.91.07、Virtual GPU Manager 595.91.04、Linux Guest Driver 595.91.07 和 Windows Guest Driver 596.86；`Supported NVIDIA GPUs and Networking` 的 Ampere 列表含 A100 与 A100X，系统列表含 DGX A100 与 HGX A100。该矩阵证明 A100 仍在 Infra 8.2 的软件和平台支持范围内。

这两份来源足以建立 A100 产品的当前软件支持事实。它们不回答 2026-08 的 A100 production、new-order availability、last-time-buy 或 hardware end-of-sale。A100 产品主页在访问日仍可打开，当前页面存在也不能代替销售生命周期公告。NVIDIA 官方硬件 EOL/EOS 定向检索没有找到 A100 的正式通知，因此 `REQ-R1-GA100-ID-STATUS` 在 GA100 die exact target 上仍为 `not_found`；另建 A100 product/vGPU software `fully_supported as of 2026-08-03/04` 的条件化事实。

## 当前虚拟化交付状态

| 能力 | 2026-08 官方交付状态 | 适用条件 | GA100 卡片裁决 |
| --- | --- | --- | --- |
| MIG 分区 | 已交付。MIG guide 的 Supported GPUs Table 1 列出 A100 SXM4/PCIe 40/80 GB，microarchitecture 为 GA100，最大 7 instances | 支持 MIG 的具体 A100 产品、driver 与 MIG mode；profile geometry 绑定产品 | 保留 `FIELD-VIRT-PARTITIONING` 与 multi-tenancy 的条件化 value。分区本身不等于 migration 或 checkpoint |
| vGPU Live Migration | 已交付。AI Enterprise Infra 8 文档给出 RHEL KVM 9.4/9.6/10.0、Ubuntu KVM 24.04、VMware vSphere 8/9；vGPU 20.0-20.2 User Guide 给出 XenMotion、`virsh migrate --live`、Hyper-V/Azure Local 与 vMotion 流程 | 源、目的物理 GPU type 相同；ECC 配置相同；GPU topology 与 NVLink width 相同；vGPU type 不变。启用 Unified Memory、debugger 或 profiler 时禁用 migration。还需满足对应 hypervisor release notes | 建立 A100 product + vGPU software + hypervisor 的 reachable fact。不得写成 raw MIG 或 GA100 die 无条件 Live Migration |
| MIG-backed vGPU Live Migration | 文档给出可执行约束。AI Enterprise 8 的 MIG-Backed vGPU 页明确排除不同 MIG profile 间 live migration，目标 host 必须有 matching MIG configuration | A100 要先由 A100 vGPU type 表确认具体 MIG-backed profile；迁移需匹配 profile/configuration，并满足 Live Migration 平台条件 | 可以关闭“A100 MIG-backed vGPU 是否存在当前迁移交付”的产品级缺口，不能证明 GI 可独立脱离 vGPU stack 迁移 |
| Suspend-Resume | 已交付。AI Enterprise 8 写明完整 VM state，包括 GPU 与 compute resources，会保存到 disk 后恢复；vGPU 20.0-20.2 User Guide 给出 Linux KVM 的 `virsh save`/`virsh restore` 和 vSphere Suspend/Power On | 有 downtime；跨 host 需 GPU type、vGPU Manager version、memory configuration、NVLink topology 等兼容；具体支持随 hypervisor、release 与 guest OS 变化 | 这是 VM-level checkpoint-like operation。可形成产品软件条件化事实，不能改写成 general GA100 die checkpoint/restart 或任意 CUDA job restart |
| time-sliced vGPU preemption | 已交付。AI Enterprise 8 Scheduling Policies 写明 scheduler 以 time slice 决定 VM 在 preemption 前可运行多久，并提供 Best Effort、Equal Share、Fixed Share | 只适用于 time-sliced vGPU；policy 由 vGPU Manager 控制 | A100 vGPU type 表同时列出 time-sliced profiles，因此可建立 A100 产品级条件事实。raw MIG/GI/CI 的抢占点、状态量、抢占 latency 仍未公开 |
| 1:1 MIG-backed vGPU preemption | 没有正向证据。当前文档写明 MIG-backed vGPU 使用 dedicated hardware resources，不使用 time-slicing | 1:1 MIG-backed profile | 不能把 time-sliced vGPU scheduler 的 preemption 下放给 MIG-backed vGPU 或 GA100 die |
| MIG GI/CI reconfiguration | 已交付 create/destroy 与 idle-time reconfigure | MIG mode；instance idle；geometry 通常需重建 | 不代表 state-preserving resize、automatic restore、Live Migration 或 checkpoint |

2020 白皮书 p.52 的 `MIG Migration` 仍应保留为历史 concept lead。当前 vGPU 文档证明了另一条可交付的 VM/vGPU migration 与 Suspend-Resume 链，但没有证明 raw GI state 以白皮书描述的方式脱离 vGPU 软件栈迁移。两条语义不能静默合并。

## 候选来源台账与反向移除

下表所有动态 endpoint 均在 2026-08-21 实际访问。HTML 页建议保存 raw HTML、正文抽取、页面截图或 print-to-PDF 与 SHA-256；PDF 建议保存原文件、内部版本、页数、字节数和 SHA-256。`selected_role` 只使用现有枚举。

| 候选 source family / version / endpoint | 精确 locator 与筛选用途 | 可支撑事实或 requirement | 反向移除结果 | 建议状态 | `selected_role` |
| --- | --- | --- | --- | --- | --- |
| `NVIDIA Technical Blog / 2020-05-14`；[HTML](https://developer.nvidia.com/blog/nvidia-ampere-architecture-in-depth/) | 页首标题与日期；`Key features` 首段；`A100 GPU hardware architecture` 中 full GA100 128 SM、A100 108 SM | GA100 直接命名日期；GA100 powers A100；full design 与 enabled implementation 边界 | 移除后失去有日期的 GA100 直接命名锚点，也失去同页的 full/enabled 边界 | `selected` | `identity,status_version_evidence` |
| `NVIDIA Newsroom A100 launch / 2020-05-14`；[HTML](https://nvidianews.nvidia.com/news/nvidias-new-ampere-data-center-gpu-in-full-production)；[PDF mirror](https://nvidianews.nvidia.com/_gallery/download_pdf/5ebd41a5ed6ae54cffe0332f/) | HTML 标题、日期、首段；PDF p.1 `full production and shipping`，p.2 A100 system/cloud availability context | A100 announce/production/shipping event；不是 GA100 die sales event | 移除后失去 2020-05-14 A100 production/shipping 的正式发布来源 | `selected` | `status_version_evidence` |
| `A100 PCIe Product Briefs`；40 GB `PB-10137-001_v03` [PDF](https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/a100/pdf/A100-PCIE-Prduct-Brief.pdf)；80 GB `PB-10577-001_v03` [PDF](https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/a100/pdf/PB-10577-001_v02.pdf) | 两份均为 viewer pp.5、7（document pp.1、3）。URL 的 `v02` 与 PDF 内部 `v03` 不一致，版本以 PDF 封面和 history 为准 | A100 card based on GA100；card Product SKU/GPU SKU；历史 driver/vGPU 最低版本 | 白皮书和技术博客已覆盖主身份。移除只损失 card-level SKU 粒度，不损失 GA100 主身份 | `lead_only` |  |
| `A100 product page current`；[HTML](https://www.nvidia.com/en-us/data-center/a100/)；`2188504 May22` [datasheet PDF](https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/a100/pdf/nvidia-a100-datasheet-nvidia-us-2188504-web.pdf) | HTML 标题、产品说明、规格和 `Where to Buy`；PDF p.1-p.3，内部日期 May22 | 产品家族、PCIe/SXM 规格与历史 availability wording；价格检索范围 | 页面仍在线不能证明当前生产或销售。移除不损失已选身份、发布日期或软件支持事实 | `lead_only` |  |
| `NVIDIA MIG User Guide`；[latest HTML](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/latest/index.html) 与 [Supported GPUs](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-gpus.html)；[unversioned PDF endpoint](https://docs.nvidia.com/datacenter/tesla/pdf/MIG_User_Guide.pdf) 当前内部标识 `Release r580` | Supported GPUs Table 1；PDF viewer pp.10-11（document pp.5-6）。现有本地 staging 的 610 快照继续由 r21 管理，本轮未改动 | A100 SXM4/PCIe 40/80 GB 到 GA100 映射；MIG instance 上限与分区对象；对 migration/checkpoint/preemption 的 checked-scope closure | 移除后失去当前产品映射和 raw MIG 边界，也无法证明 MIG guide 本身没有交付 migration API | `selected` | `identity,architecture_mechanism,coverage_obligation_evidence` |
| `NVIDIA vGPU software lifecycle / 2026-08-03`；[HTML](https://docs.nvidia.com/vgpu/news/vgpu-software-lifecycle-on-supported-gpus/index.html) | Appendix A，`remain fully supported` 列表；页脚 `Last updated on Aug 4, 2026` | A100、A100 DX、A100 PCIe、A100 PCIe 80GB、A100X 尚未结束 full support | 移除后失去明确的 support phase 与日期，8.2 support matrix 只能证明某一 release 支持 | `selected` | `status_version_evidence` |
| `NVIDIA AI Enterprise Infra 8.2 support matrix / 2026-08-17`；[version-pinned HTML](https://docs.nvidia.com/ai-enterprise/release-8/latest/support/support-matrix-8/8.2.html) | 标题与首段；Table 4 software versions；Ampere GPU list；DGX/HGX list；页脚日期 | A100/A100X 在 Infra 8.2 支持范围；driver 与 vGPU Manager/guest driver exact versions | 移除后失去 A100 与 8.2/595.91.x 的明确版本绑定 | `selected` | `status_version_evidence` |
| `NVIDIA AI Enterprise Infra 8.2 vGPU docs / 2026-08-17`；[A100 vGPU types](https://docs.nvidia.com/ai-enterprise/release-8/latest/infra-software/vgpu/reference/ampere-a100.html)、[Live Migration](https://docs.nvidia.com/ai-enterprise/release-8/latest/infra-software/vgpu/features/live-migration.html)、[Suspend-Resume](https://docs.nvidia.com/ai-enterprise/release-8/latest/infra-software/vgpu/features/suspend-resume.html)、[MIG-Backed vGPU](https://docs.nvidia.com/ai-enterprise/release-8/latest/infra-software/vgpu/features/mig-backed-vgpu.html)、[Scheduling Policies](https://docs.nvidia.com/ai-enterprise/release-8/latest/infra-software/vgpu/features/scheduling.html) | A100 page Tables 137-148；Live Migration `Platform Support` 与 `vGPU Support for Live Migration`；Suspend-Resume 首段与 platform table；MIG-backed `Limitations`；Scheduling 首段与 limitations | A100 profile 到 current vGPU feature 的 binding；平台版本；matching MIG profile；VM state save/restore；time-slice preemption 边界 | 移除 A100 endpoint 后，通用 feature 无法绑定 A100。移除 feature endpoints 后，A100 profile 表不能证明 migration、checkpoint-like save/restore 或 preemption semantics | `selected` | `architecture_mechanism,status_version_evidence` |
| `NVIDIA Virtual GPU Software User Guide / Release 20.0-20.2 / 2026-07-31`；[fixed PDF](https://docs.nvidia.com/vgpu/20.0/pdf/grid-vgpu-user-guide.pdf) | cover；PDF viewer pp.158-164（printed §5.3 pp.146-152）；printed p.146 prerequisites、p.148 `virsh migrate --live`、p.149 `virsh save/restore`、pp.150-152 vMotion 与 suspend/resume | delivered operation、命令级接口、same-GPU/ECC/topology 条件、禁用 Unified Memory/debugger/profiler 的限制 | 移除后仍知道 feature 存在，但失去固定版本 PDF、操作命令和一致性条件 | `selected` | `architecture_mechanism,status_version_evidence` |
| `NVIDIA AI Enterprise EOL notices / current`；[HTML](https://docs.nvidia.com/ai-enterprise/lifecycle/latest/eol-notices.html) | `Deprecated Hardware` migration path 列出 A100 40/80 GB 为 Infra 8.x currently supported GPU | 对 current support 的旁证 | vGPU lifecycle 与 8.2 matrix 已直接覆盖。移除不损失必需事实 | `lead_only` |  |
| `DGX A100 launch / 2020-05-14`；[Newsroom HTML](https://nvidianews.nvidia.com/news/nvidia-ships-worlds-most-advanced-ai-system-nvidia-dgx-a100-to-fight-covid-19-third-generation-dgx-packs-record-5-petaflops-of-ai-performance) | `Availability` 段，DGX A100 systems start at USD 199,000 | 只支撑 8-GPU DGX A100 system launch price | 对 GA100 die price 移除后无事实损失。系统价不可除以 8 反推 GPU 或 die price | `rejected` |  |
| `NVIDIA Developer Forum / 2023 A100 EOL reply`；[forum thread](https://forums.developer.nvidia.com/t/a100-80g-end-of-life/243636) | 员工账号的非正式回复，且时间停在 2023 | 只能作为定向检索线索 | 移除后无正式状态事实损失；不满足正式 lifecycle/EOL endpoint 要求 | `rejected` |  |

这些 `selected` 来源均来自 NVIDIA，不能按多个 publisher 计 independent validation。它们的保留理由是 obligation 不同：技术博客负责 GA100 direct identity，Newsroom 负责 dated A100 launch，lifecycle 与 8.2 matrix 负责 current version/status，AI Enterprise 与 vGPU User Guide 负责交付语义和运行条件，MIG Guide 负责 raw partitioning 边界。

## Requirement 与 factor closure 建议

| requirement / field | 本轮建议 | 可写的 raw 事实 | 仍需保留的边界 |
| --- | --- | --- | --- |
| `REQ-R1-GA100-V2-ID-RELEASE-DATE / FIELD-ID-RELEASE-DATE` | 按字段语义二选一。`first_official_publication_date` 可 `value_available`；standalone die release 维持 `not_found` | `2020-05-14, NVIDIA Technical Blog directly names GA100 and states GA100 powers A100` | 不写 A100 shipping 等于 GA100 die availability |
| `REQ-R1-GA100-ID-AVAIL / FIELD-ID-AVAILABILITY-DATE` | GA100 die `not_found`；另建 A100 product value | `2020-05-14, A100 in full production and shipping to customers worldwide` | A100 product event 不下放 die |
| `REQ-R1-GA100-ID-STATUS / FIELD-ID-STATUS` | GA100 hardware/die status `not_found`；A100 vGPU software support 建 reachable value | `A100 variants remain fully supported in vGPU lifecycle notice dated 2026-08-03; A100 is supported in AI Enterprise Infra 8.2` | full software support 不等于 current production、new sale、hardware warranty 或 EOS |
| `REQ-R1-GA100-ECON-PRICE` | `not_found` | NVIDIA 官方计划来源未见 standalone GA100 die MSRP/list price | DGX system、A100 card、cloud hourly price和 reseller price全部排除 |
| `REQ-R1-GA100-V2-VIRT-MULTI-TENANCY` | 维持产品/MIG 条件化 `value_available` | A100 支持 MIG-backed 与 time-sliced vGPU profiles；不同 GI 可隔离运行 | 不把具体 profile、7-way 或 vGPU license 下放 full die |
| `REQ-R1-GA100-V2-VIRT-PARTITIONING` | 维持条件化 `value_available` | A100 SXM4/PCIe 40/80 GB 映射 GA100，支持最多 7 MIG instances | A30 同为 GA100 但最多 4 instances，证明上限依赖产品配置 |
| `REQ-R1-GA100-V2-VIRT-PREEMPTION-QOS` | 合并字段仍可由 MIG QoS/isolation 关闭；preemption factor 分开裁决 | time-sliced A100 vGPU 使用 time-slice scheduler，时间片结束前后发生 scheduler preemption | raw MIG、GI、CI 与 GA100 hardware preemption mechanics 仍为 `not_found`；1:1 MIG-backed vGPU 不使用 time-slicing |
| `REQ-R1-GA100-RAS-CKPT / FIELD-RAS-CHECKPOINT-RESTART` | GA100 die/general job checkpoint 改为 `not_found`；A100 vGPU VM Suspend-Resume 建 product/software reachable value | 完整 VM state 含 GPU/compute resources 保存到 disk 后恢复；Linux KVM 使用 `virsh save/restore` | 有 downtime；不证明 CUDA job checkpoint、transparent restart、raw GI checkpoint 或 failure recovery |
| `FIELD-RAS-RECOVERY` 的 MIG migration factor | raw MIG/GA100 die migration `not_found`；A100 vGPU Live Migration 建条件化 reachable value | RHEL KVM、Ubuntu KVM、vSphere 当前支持；same GPU type/ECC/topology；matching MIG profile | 不证明所有 A100 SKU、所有 hypervisor、跨 profile、跨 GPU type 或无停机状态一致性 |

这里没有创建新的 requirement_id、field_id、object_id 或 enum。正式写入若只能挂到 `OBJ-NVIDIA-GA100-DIE`，上述产品/软件 value 应留在 reachability 侧，die exact-target 继续使用 `not_found` 或既有条件化事实。`FIELD-ID-ARCH` 之外不做关系投影。

## GA100 full-die 价格 search log

本轮价格结论的检索计划覆盖官方产品页、datasheet、两份 PCIe Product Brief、launch release、官方 marketplace 定向检索，以及 r16 已查的白皮书/ISSCC。每个来源均按 `price`、`pricing`、`MSRP`、`list price`、`USD`、`dollar` 或页面可见购买入口回查正文。

| 实际 query 或 endpoint | 实际结果 | 裁决 |
| --- | --- | --- |
| `site:nvidia.com/en-us/data-center/a100 NVIDIA A100 price MSRP` | 返回 A100 产品页、datasheet 和 Product Brief；页面正文没有 price/MSRP | 无 GA100 die 价格 |
| `site:nvidianews.nvidia.com A100 price MSRP` | 返回 A100 与 DGX A100 launch release；A100 launch release 无 price，DGX A100 release 有 system price | DGX system price 排除 |
| `site:nvidia.com/content/dam/en-zz/Solutions/Data-Center/a100/pdf A100 price` | 返回 A100 datasheet 与 Product Brief；逐 PDF 搜索 `price`/`MSRP` 无命中 | 无 card 或 die 官方目录价 |
| `site:marketplace.nvidia.com A100 GPU price` | 检索结果为 RTX A1000 等无关条目，没有 A100 data-center accelerator 的官方商品价 | 无相关结果，rejected |
| [A100 current product page](https://www.nvidia.com/en-us/data-center/a100/) | `price`、`MSRP`、`Contact Sales` 无命中；页尾只有 generic `Where to Buy` | 购买导航不构成价格 |
| [A100 May22 datasheet](https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/a100/pdf/nvidia-a100-datasheet-nvidia-us-2188504-web.pdf) | `price`、`MSRP` 无命中 | 无价格 |
| [A100 40 GB Product Brief](https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/a100/pdf/A100-PCIE-Prduct-Brief.pdf) | `price`、`MSRP` 无命中 | 无价格 |
| [A100 80 GB Product Brief](https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/a100/pdf/PB-10577-001_v02.pdf) | `price`、`MSRP` 无命中 | 无价格 |
| [A100 launch release](https://nvidianews.nvidia.com/news/nvidias-new-ampere-data-center-gpu-in-full-production) | `price` 无命中 | 无 A100/GA100 价格 |
| r16 已核对 whitepaper v1.0 与 ISSCC | `price`、`pricing`、`MSRP`、`list price`、`USD`、`dollar` 无 bare-die 命中 | 与本轮网页结果一致 |
| [DGX A100 launch release](https://nvidianews.nvidia.com/news/nvidia-ships-worlds-most-advanced-ai-system-nvidia-dgx-a100-to-fight-covid-19-third-generation-dgx-packs-record-5-petaflops-of-ai-performance) | `Availability` 明确 `DGX A100 systems start at $199,000` | 对 GA100 die price rejected；不得按 8 GPU 平均 |

在上述计划来源范围内，`REQ-R1-GA100-ECON-PRICE` 可维持 `not_found`。这个结论表示 NVIDIA 官方公开材料未提供 standalone GA100 die price，不表示可以用非官方 A100 card 市价补空。

## Hardware lifecycle 与销售状态 search log

| 实际 query / source | 结果 | 裁决 |
| --- | --- | --- |
| `site:nvidia.com A100 End of Sale` | 主要命中 NVIDIA Developer Forum 讨论，没有正式产品 EOS/EOL notice | forum rejected |
| `site:nvidia.com A100 End of Life hardware` | 命中 forum、DGX manuals 与软件文档，没有 standalone A100/GA100 hardware lifecycle notice | current hardware lifecycle 未找到 |
| `site:docs.nvidia.com A100 end of support` | 命中 2026 vGPU software lifecycle，A100 variants remain fully supported | 建 A100 software support value |
| `site:nvidianews.nvidia.com A100 availability shipping production` | 命中 2020-05-14 A100 full production/shipping release | 只固定 launch-date status |
| A100 current product page | 页面仍在线并链接 datasheet/Product Brief/Where to Buy | 不能推导 current production 或 orderability |
| AI Enterprise 8.2 support matrix | A100/A100X、DGX A100、HGX A100 均在支持列表 | 证明 Infra 8.2 compatibility，不证明 hardware sale status |

`FIELD-ID-STATUS` 若要求 die 或 hardware product lifecycle，当前 official-public 结果为 `not_found`。若字段允许 software support status，则应另建 A100 product/vGPU software 条件事实并保留日期和 release。

## Endpoint 固定策略

| Endpoint 类型 | 观察到的版本风险 | 固定方式 |
| --- | --- | --- |
| dated Technical Blog HTML | URL 稳定但正文可修订，页面未显示 revision history | 保存 raw HTML、正文抽取、页面截图/print-to-PDF、访问日期和 SHA-256；locator 同时记录标题、日期与 heading |
| Newsroom HTML + `_gallery/download_pdf` | HTML 含发布日期，PDF 内容固定但抽取正文未显示日期行 | HTML 与 PDF 成对保存；日期取 HTML，正文以两端点交叉核对；分别记录 hash |
| Product Brief PDF | URL 文件名可能滞后于内部版本，80 GB 的 URL 为 `v02` 而 PDF 内部为 `v03` | source version 取 PDF 封面和 Document History，URL 原样保存；记录 endpoint/version mismatch |
| MIG `latest` HTML | 会随指南更新，页面正文没有可靠 release number | 不把 `latest` 当 immutable；保存访问日快照与 hash，并与既有 610 staging manifest 关联 |
| MIG `/pdf/MIG_User_Guide.pdf` | 文件名不带版本，本轮返回内部 `Release r580`，可被覆盖 | 以内部 release、访问日期、页数、字节数与 hash 固定；不能只凭 PDF endpoint 声称 current 610 |
| AI Enterprise `release-8/latest/.../8.2.html` | 内容路径含 `latest`，但正文自述 version-pinned 8.2 并有 last-updated date | 保存完整 HTML/print-to-PDF 与 hash，source version 写 `Infra 8.2`，同时记录 2026-08-17 update date |
| vGPU lifecycle dated HTML | URL 不含版本号，但标题含 2026-08-03，页脚含 2026-08-04 update | 保存 HTML/print-to-PDF、标题日期、footer update 和 hash |
| `/vgpu/20.0/pdf/grid-vgpu-user-guide.pdf` | version path 固定，封面写 Release 20.0-20.2 与 2026-07-31 | 直接保存 PDF、页数、字节数、hash 与 viewer pp.158-164（printed pp.146-152）locator；优先于 `/latest/` HTML 作为 frozen endpoint |

本轮没有下载或覆盖任何 staging 文件。后续正式来源工程若采纳这些 source，应在 canonical manifest 中保存 endpoint、访问日期、内容 hash、内部版本和 locator，再运行反向移除；不能只保存网页标题。

## 交接裁决

建议最小 selected source family 为六组：GA100 technical blog、A100 launch release、MIG User Guide、vGPU lifecycle notice、AI Enterprise Infra 8.2 support/vGPU docs、vGPU 20.0-20.2 User Guide。A100 Product Brief 保留为 card SKU lead，A100 product page 保留为价格与当前页面状态的 search lead，AI Enterprise EOL notices 只作旁证。DGX A100 系统价格和 Developer Forum EOL 回复均不进入 GA100 selected set。

正式数据层应同时保留四条负边界：A100 launch 不等于 standalone GA100 die availability；A100 software full support 不等于 current hardware production/sale；MIG partition 不等于 migration/checkpoint；vGPU Live Migration、Suspend-Resume 与 scheduler preemption 不等于 GA100 die 的无条件能力。这样既能关闭产品软件层的 current delivery 缺口，也不会破坏 exact-target 与唯一投影规则。

## 质量检查与失败分类

`report-humanizer` 已对本文件单独运行机器扫描，结果为 `No machine-detectable AI tells found`。人工逆向复读从本节开始，依次核对 endpoint 固定、hardware lifecycle search log、price search log、requirement closure、source reverse-removal、virtualization 状态、support status、identity/date 与开头裁决。复读时修正了 Product Brief、MIG Guide 和 vGPU User Guide 的 PDF viewer 页码与 document/printed 页码表达，也补上 Live Migration 对 support matrix 的 locator。GA100/A100、die/card/module/system/cloud、MIG/vGPU、migration/checkpoint/preemption 的主体未发现倒置。当前剩余风险是 AI Enterprise `latest` HTML 与未带版本的 MIG PDF 会继续更新，正式采纳时必须固定快照和 hash。

本轮没有 sandbox denial、approval denial、approval-review connection failure 或 remote service error。两次网页工具编排因 JavaScript 参数语法写错而立即失败，修正后重跑成功，分类为 model/operator mistake；没有遗漏 source。一次在非 Git 内层目录执行只读 `git status` 得到 `not a git repository`，分类同为 operator/context mistake，没有产生写入。一次四查询合并的 price search 输出被工具长度上限截断，分类为 tool/runtime output truncation；随后逐一打开官方产品页、PDF 与 Newsroom 页面，并对 `price`/`MSRP` 做单端点复查，未降低 not_found 裁决的覆盖度。
