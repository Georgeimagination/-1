# M2：NVIDIA 与 AMD 批量建卡计划

> 文档性质：M2 执行排期与验收边界，不是规格表。  
> 资料截止日：2026-08-12。  
> 适用数据模型：资料卡模板 0.2、32 张正式 CSV（Comma-Separated Values，逗号分隔值）表、`数据/enums.csv` 中的正式枚举。  
> 当前输入：`object_candidates.csv` 中 NVIDIA 44 条、AMD 24 条候选；正式库已有 NVIDIA Hopper、GH100 和 H100 SXM5 试填对象，AMD 尚无正式对象。  
> 写入边界：本文件不改正式 CSV、资料卡、进度、README、AGENTS 或研究计划。

本文使用这些缩写：GPU（Graphics Processing Unit，图形处理器）、CPU（Central Processing Unit，中央处理器）、SKU（Stock Keeping Unit，具体产品配置）、OAM（OCP Accelerator Module，开放计算项目加速器模组）、APU（Accelerated Processing Unit，加速处理器）和 HBM（High Bandwidth Memory，高带宽存储器）。

## 1. 执行口径

M2 先冻结对象身份和层级，再分卡抽取事实。共享架构机制只写在 `architecture_generation` 卡；裸片、芯粒和封装内实现写在 `die`、`chiplet` 或 `package` 卡；容量、启用单元、时钟、功耗、形态和主机接口留在 `module` 或 `card` 卡；底板、服务器和机架只记录设备数量、拓扑及聚合值。系统值不得除以设备数后回填产品卡，软件支持标签也不能直接证明市场 SKU。

每个工作包按同一顺序交付：候选身份决议、对象与关系片段、字段要求、资料卡草稿、逐来源断言和来源筛选建议。进入正式库的对象类型、产品状态、关系类型、筛选状态和入选角色必须使用现有枚举。主样本至少核对 `identity`、`physical`、`compute`、`numerics`、`memory`、`interconnect`、`special_engines`、`software`、`evidence` 九个完整度领域；没有公开值时写字段要求状态，不制造空值事实。

最低官方证据组合中的“固定规格”指对象完全匹配的数据手册或产品简报；“架构机制”指白皮书、架构论文或开发文档；“状态证据”指带日期的产品页、正式发布材料或支持生命周期页面；“系统证据”指官方系统规格、平台参考文档或部署指南。固定规格能够同时承担身份和状态时可以少留一份，但每份入选来源必须保留不可替代的事实或证据职责。

## 2. NVIDIA 对象树与纳入边界

NVIDIA 的 44 条候选中，40 条进入建卡排期：6 个架构代际、1 个 CPU+GPU 封装对象、23 个产品 SKU 和 10 个系统对象。H100 SXM5 试填卡已经存在，M2 对它做正式化和同代一致性复核。三条旧产品线索与 HGX B100 不建正式卡。裸片、芯粒和其他封装对象要等固定资料确认后再增加，因此不包含在这 40 张候选卡里。

按候选表的范围状态，Ampere 架构与 A100 是 2 个 `historical_anchor`；B100、H20BFX、RTX PRO 6000D、Rubin 架构、Rubin GPU、Rubin CPX GPU 和 Vera Rubin NVL72 是 7 个 `observation`；A30、A40、V100 与 HGX B100 是 4 个 `excluded_lead`。其余 31 个候选按 `main_sample` 排期，后续仍须通过身份和状态证据验收。

| 架构代际 | 裸片或封装边界 | 产品 SKU | 系统边界 | 处理 |
|---|---|---|---|---|
| Ampere | 先建立 A100/A800 所需的物理对象；只有固定资料证明共用裸片或封装时才共用 | A100 SXM4 80 GB；A800 数据中心加速器；A800 40GB Active | 无 | A100 为历史锚点；两条 A800 记录先消歧，再决定是两个 SKU，还是产品身份加配置 |
| Hopper | 复用已建 GH100 裸片；GH200 另建 CPU+GPU `package`，不要归入 H100/H200 SKU | H100 SXM5 80 GB、H100 PCIe 80 GB、H100 NVL、H200 SXM 141 GB、H200 NVL 141 GB | GH200 NVL2、GH200 NVL4、HGX H100、HGX H200 | 五个 H100/H200 SKU 可共用 Hopper 架构卡，但形态、设备数量与互联限制各自保留 |
| Ada Lovelace | 数据中心 SKU 需要的物理对象按固定资料决定；不要由桌面 Ada 白皮书反推卡级规格 | L40、L40S、L4 | 无 | 三张卡共用 Ada Lovelace 架构卡；显存、功耗、被动或主动散热、视频模块和 NVLink 适用性不得合并 |
| Blackwell | 建立产品资料明确命名的计算裸片、封装或 Superchip 对象；不要把 GB200 系统当作 B200 单模组 | B100、B200 SXM 180 GB、RTX PRO 6000 Blackwell Server Edition、RTX PRO 6000D | HGX B200、GB200 NVL4、GB200 NVL72 | B100 保持观察项；其余对象共用 Blackwell 架构卡，但服务器 RTX、SXM 和 Grace Blackwell 系统必须分开 |
| Blackwell Ultra | 与 Blackwell 的关系须有厂商明确依据，不可只凭命名推断 | B300 SXM 288 GB | HGX B300、GB300 NVL72 | 共用 Blackwell Ultra 架构卡；模组和机架卡分别记录单设备与系统值 |
| Rubin | 产品和系统最终形态尚在生产爬坡，物理对象只在官方资料足以冻结名称时建立 | Rubin GPU、Rubin CPX GPU | Vera Rubin NVL72 | 全部为观察卡；状态按截止日保存，不用伙伴计划替代客户交付 |
| 架构待核的地区产品 | 在官方资料确认架构与物理实现前不挂入相邻代际 | H800、H20、L20、L2、H20BFX | 无 | 身份可先建，架构关系保持待核；不得从名称或驱动家族外推规格 |

`A30`、`A40`、`V100` 不建卡，A100 已承担代际锚点。`HGX B100` 保留 `excluded_lead`，除非找到最终量产系统的一手对象证据。GeForce、工作站 RTX 和没有独立硬件边界的营销集合不进入本批；RTX PRO 6000 Blackwell Server Edition 与 RTX PRO 6000D 是明确服务器或地区候选，不能和工作站版共卡。

## 3. AMD 对象树与纳入边界

AMD 的 24 条候选中，22 条进入建卡排期：5 个架构代际、13 个产品 SKU 和 4 个系统或参考设计对象。两条 `-HF` 软件别名不建市场产品卡。裸片、芯粒和封装对象等固定资料确认后再增加，不计入 22 张候选卡。

CDNA 2 与 MI250X 是 2 个 `historical_anchor`；CDNA 6、MI440X、MI430X、Helios 和 MI500 Series 是 5 个 `observation`；MI300X-HF 与 MI308X-HF 是 2 个 `excluded_lead`。其余 15 个候选按 `main_sample` 排期，其中 CDNA 5 与 MI455X 的产品状态仍是 `production_ramp`。

| 架构代际 | 裸片或封装边界 | 产品 SKU | 系统边界 | 处理 |
|---|---|---|---|---|
| CDNA 2 | 建立 MI200 系列必要的计算裸片或多裸片封装对象，以固定架构资料为准 | MI250X OAM、MI210 PCIe | 无 | MI250X 为历史锚点，MI210 为主样本；OAM 与 PCIe 规格不共用 |
| CDNA 3 | MI300A 与 MI300X 的 APU/加速器封装分别建对象；MI308X 是否共用封装须核对 | MI300A APU、MI300X OAM、MI308X OAM、MI325X OAM | MI300X Platform（8 OAM）、MI325X Platform（8 OAM） | 四张 SKU 卡共用 CDNA 3 架构卡，但 CPU 参与、统一内存、HBM 容量、功耗模式和地区限制逐卡保存 |
| CDNA 4 | MI350 系列的计算芯粒、I/O 裸片与 OAM 封装按官方架构资料拆分 | MI350X OAM、MI355X OAM、MI350P PCIe | MI350 Series Platform（8 OAM） | 三张 SKU 卡共用 CDNA 4 架构卡；OAM/PCIe、冷却、功耗和启用配置不得合并 |
| CDNA 5 | EAM（Enhanced Accelerator Module，增强型加速器模组）边界先确认，再建立封装对象 | MI455X、MI440X、MI430X | AMD Helios（72×MI455X）参考机架 | MI455X 按生产爬坡主样本处理；MI440X、MI430X 和 Helios 为观察卡，Helios 明确标为参考设计 |
| CDNA 6 | 没有正式裸片或封装名称时不建物理对象 | MI500 Series 仅作系列占位 | 无 | CDNA 6 架构卡和 MI500 Series 观察卡分别保留；等具体 SKU 后再拆 |
| 软件别名 | 无 | MI300X-HF、MI308X-HF | 无 | `excluded_lead`；只记录筛除理由和重新纳入条件 |

架构共享不等于产品继承。MI300A、MI300X、MI308X 和 MI325X 可以引用 CDNA 3 的执行模型与指令机制；每张产品卡仍须保留自己的芯粒组合、HBM、功耗、时钟、互联和产品状态。MI350X、MI355X 与 MI350P 同理。平台卡只记录 8 OAM 系统事实，Helios 卡只记录参考机架及其状态，不能成为单 MI455X 规格来源。

## 4. 可并行工作包

下表按对象依赖切包。同一时刻可以并行不同架构族；同一架构包内先完成架构和物理对象，再由多个 SKU 子任务引用。每包验收时既核卡片，也核对象关系和最小来源职责。预计数量是排期数，不是预先批准的正式对象数；候选消歧后允许减少。

表中的 `NV-*` 与 `D-*` 是 `model_inventory.md` 里的官方起始入口键，只用于启动检索；进入正式最小资料库的仍是经过版本固定和事实覆盖审查的 `source_id`。

| 工作包 | 范围与拟交付 | 预计卡片 / 对象 | 最低官方证据组合 | 动态状态风险 | 验收重点 |
|---|---|---:|---|---|---|
| NV-A | Ampere：架构；A100 SXM4 80 GB；A800 两条候选；必要物理对象 | 4 卡 / 5 至 7 对象 | `NV-1`/`NV-2`/`NV-3` 起始；A100 固定数据手册或产品简报；Ampere 白皮书；A800 正式产品或订货资料；当前支持或生命周期页 | A800 正式卡型、容量和地区页面可能已下线；A100 生命周期会变化 | A100 只作轻量锚点；A800 名称碰撞消解；不把 A100 规格复制给 A800 |
| NV-B1 | Hopper 核心：复用架构与 GH100；H100 SXM 试填正式化；H100 PCIe、H100 NVL、H200 SXM、H200 NVL | 6 卡 / 7 至 9 对象 | `NV-1`/`NV-2`/`NV-4` 起始；H100/H200 对象匹配的数据手册；Hopper 白皮书或官方架构论文；CUDA Hopper 开发文档；带日期产品状态页 | H100/H200 动态合并页会改写现行组合；NVL 的设备数和容量口径易混 | 每个形态独立；H100 NVL 和 H200 NVL 不写成单 GPU；架构事实只保留一份 |
| NV-B2 | 地区与出口候选（架构待核）：H800、H20、L20、L2、H20BFX | 5 卡 / 5 至 7 对象 | `NV-2`/`NV-3` 起始；设备身份、订货或产品资料；官方驱动与 GPU Operator 支持矩阵；有日期的发布或生命周期材料 | 出口政策和产品名变化快；驱动支持不等于供货；部分固定页可能不可访问 | 先定身份、地区、形态和状态；没有对象匹配资料时规格保持缺失，不套 H100/L40 数据 |
| NV-B3 | Grace Hopper 与 Hopper 系统：GH200 package、GH200 NVL2/NVL4、HGX H100/H200 | 5 卡 / 5 至 8 对象 | `NV-1`/`NV-2` 起始；GH200 固定产品简报或架构资料；NVLink-C2C 开发文档；HGX/NVL 系统规格；当前 line card | GH200 的 96/144 GB 配置与 H100/H200 GPU 映射可能随系统版本变化 | CPU、GPU、Superchip 与系统四层关系清楚；系统聚合值不下放 |
| NV-C | Ada 数据中心：架构、L40、L40S、L4 | 4 卡 / 5 至 7 对象 | `NV-1`/`NV-2`/`NV-5` 起始；Ada 官方架构白皮书；三款对象匹配的数据手册；数据中心 line card 或产品状态页 | L40 历史页面与 L40S 现行页面可能替换；当前供货状态变化 | 三款 SKU 共用机制但不共用显存、功耗、散热、媒体能力和互联字段 |
| NV-D1 | Blackwell 模组与服务器卡：架构、B100、B200 SXM、RTX PRO 6000 Blackwell Server Edition、RTX PRO 6000D、必要物理对象 | 5 卡 / 7 至 10 对象 | `NV-1`/`NV-2`/`NV-3`/`NV-6` 起始；Blackwell 技术简报和架构演讲或论文；B200 固定数据手册；各 RTX 对象产品资料；B100 发布与当前状态材料 | B100 最终身份、RTX PRO 6000D 供货和规格仍可能变化 | B100/RTX 观察状态独立；服务器卡不使用工作站规格；规格版本要固定 |
| NV-D2 | Blackwell 系统：HGX B200、GB200 NVL4、GB200 NVL72 | 3 卡 / 3 至 6 对象 | `NV-1`/`NV-6` 起始；HGX 与 NVL 固定系统规格；GB200 组成和互联官方资料；line card | NVL4 名称和配置边界、NVL72 系统版本及交付状态会变 | 底板、服务器、机架分层；Grace Blackwell Superchip 如需建对象，须有正式命名证据 |
| NV-E | Blackwell Ultra：架构、B300 SXM、HGX B300、GB300 NVL72、必要物理对象 | 4 卡 / 6 至 8 对象 | `NV-1`/`NV-7` 起始；Blackwell Ultra/B300 架构或技术资料；B300 固定规格；HGX/GB300 系统规格；带日期状态材料 | 截止日可用区域、首批交付和系统修订可能变化 | 与 Blackwell 的边界有来源；单模组与系统事实分开；不从 NVL72 反推 B300 |
| NV-F | Rubin：架构、Rubin GPU、Rubin CPX GPU、Vera Rubin NVL72 | 4 观察卡 / 4 至 7 对象 | `NV-8`/`NV-9` 起始；官方生产公告；架构或平台技术资料；GPU/CPX/NVL72 对象页；伙伴交付只作补充状态证据 | 处于生产爬坡，时钟、功耗、模组形态、客户交付都可能变化 | 所有状态带截止日；预告值标暂定；不把 full production 写成客户已交付 |
| AMD-A | CDNA 2：架构、MI250X OAM、MI210 PCIe、必要物理对象 | 3 卡 / 5 至 7 对象 | `D-1`/`D-2`/`D-3` 起始；MI200 系列固定产品简报；CDNA 2 架构资料；MI210 当前生命周期页 | MI250X/MI210 旧资料可能转入归档，生命周期状态会变 | 历史锚点与主样本分开；OAM、PCIe 和多裸片边界清楚 |
| AMD-B1 | CDNA 3 核心：架构、MI300A、MI300X、必要物理对象 | 3 卡 / 6 至 9 对象 | `D-3`/`D-4` 起始；MI300 固定产品简报或数据表；CDNA 3 架构资料或 Hot Chips 原始演讲；2023-12-06 发布材料；当前产品页 | 产品页可能更新功耗模式；MI300A/MI300X 内存口径易混 | APU 与 GPU OAM 分卡；CPU+GPU 统一内存只属于 MI300A 对象 |
| AMD-B2 | CDNA 3 变体与平台：MI308X、MI325X、MI300X Platform、MI325X Platform | 4 卡 / 4 至 7 对象 | `D-1`/`D-5`/`D-6` 起始；MI325X 固定规格；MI308X 正式产品或运维资料；两个 8 OAM 平台规格；官方支持或安全文档 | MI308X 地区、首供和稳定产品页不确定；平台订货边界会变 | 软件矩阵只确认设备身份；平台事实不回填 OAM；无法固定 MI308X 规格时保留缺失 |
| AMD-C | CDNA 4：架构、MI350X、MI355X、MI350P、MI350 8-OAM Platform、必要物理对象 | 5 卡 / 8 至 12 对象 | `D-7`/`D-8` 起始；MI350 系列固定规格；CDNA 4 架构资料；三款 SKU 产品页；8 OAM 平台资料；正式发布材料 | MI350P 首供和订货号、冷却与功耗配置可能更新 | X/355X/P 的启用配置、形态、冷却和功耗独立；平台版本不合并 |
| AMD-D | CDNA 5：架构、MI455X、MI440X、MI430X、Helios、必要物理对象 | 5 卡 / 7 至 11 对象 | `D-9`/`D-10`/`D-11` 起始；CDNA 5/MI400 架构与产品页；官方规格库；2026 发布材料；Helios 参考设计；交付状态材料 | MI455X 生产爬坡，MI440X/MI430X 为预告，规格和交付仍会变化 | 主样本与观察项分开；EAM 边界有证据；Helios 明确为参考设计 |
| AMD-E | CDNA 6 与 MI500 Series | 2 观察卡 / 2 对象 | `D-11` 起始；官方路线图或发布材料；正式架构或产品页出现后再扩充 | 计划 2027，名称和规格均可能变化 | 不创建虚构具体 SKU，不填推测规格；只保留系列身份、状态与再检索条件 |

## 5. 并发顺序与合并门

第一波可并行 `NV-A`、`NV-C`、`AMD-A`，它们依赖少，适合校准架构卡与轻量历史锚点。第二波并行 `NV-B1`、`NV-B2`、`AMD-B1`；Hopper 地区变体由独立任务处理，避免把 H100 的成熟规格误带过去。第三波并行 `NV-B3`、`NV-D1`、`AMD-B2`。第四波并行 `NV-D2`、`NV-E`、`AMD-C`。最后处理 `NV-F`、`AMD-D`、`AMD-E`，因为这些对象动态状态风险最高，状态页应尽量接近最终合并日核查。

每个包通过以下合并门后才能进入正式 CSV：

1. 候选对象逐条决定 `main_sample`、`observation`、`historical_anchor` 或 `excluded_lead`，并映射为正式 `product_status`；
2. `architecture_generation`、物理对象、`module`/`card` 和系统对象的关系方向能够用正式 `relation_type` 表达；
3. 主样本卡覆盖九个完整度领域，观察项和历史锚点按范围裁剪，但所有省略项有理由；
4. 每条已接收事实有对象匹配、定位明确的来源断言；地区变体和系统卡不得借用相邻 SKU 的断言；
5. 入选来源至少承担一个 `identity`、`core_spec`、`architecture_mechanism`、`status_version_evidence` 或其他正式角色；重复转述列为 `redundant_covered` 或 `lead_only`；
6. 动态页已记录访问日，固定文档已记录版本、页数、SHA-256（256 位安全散列算法）和公开入口；
7. 包内结构数据通过暂存校验，合并后再运行全局校验；高风险包由非初稿作者复核。

## 6. 数量预算与最小资料库策略

按当前候选表，NVIDIA 拟交付 40 张候选卡：6 张架构卡、1 张 GH200 封装卡、23 张 SKU 卡和 10 张系统卡，其中 H100 SXM5 试填卡已存在。AMD 拟交付 22 张候选卡：5 张架构卡、13 张 SKU 卡和 4 张系统或参考设计卡。两厂商合计 62 张候选卡。固定资料确认后还会增加裸片、芯粒或封装对象；预计正式对象总数约为 75 至 100 个，最终数量以对象边界审查为准。

现有本地资料池有 65 份 NVIDIA PDF，已经包含 H100、Hopper、Ampere、Ada、Blackwell 的一手资料和相关原始论文；AMD 当前没有本地 PDF。执行时先使用本地 NVIDIA 固定资料，缺口检索只针对对象身份、版本、状态和卡片未覆盖字段。AMD 各包先固定产品简报、架构材料和系统文档，再开始抽取，避免以动态产品页承担全部规格事实。

来源按职责最小化，不按厂商或卡片简单去重。同一架构白皮书可支持多个 SKU 的共享机制，但每个 SKU 仍需对象匹配的固定规格或产品资料。动态产品页主要固定现行状态；旧版数据手册若保留新版删除的规格、旧状态或冲突值，仍有独立职责。媒体复述和没有新增事实的第三方汇总不进入正式最小集。本批只允许厂商一手资料和原始论文进入候选来源池；后续若要补独立实测，另开复核包，不在本计划阶段采集规格事实。

## 7. 风险控制

地区或出口变体是 NVIDIA 的首要风险。驱动、Operator 和安全文档可以确认设备身份与软件支持，不能证明卡型、内存、互联或供货状态。找不到对象匹配的一手规格时，把字段留作 `not_found`、`inaccessible_evidence` 或 `pending_verification`，不要从 H100、L40S 或其他邻近产品复制。

系统命名是第二个风险。H100 NVL、H200 NVL、GH200 NVL2/NVL4、GB200/GB300 NVL72、AMD 8 OAM Platform 和 Helios 的设备数量及产品边界不同。先把对象关系建清楚，再抽取带宽与容量；任何聚合值都留在产生它的系统对象。

生产爬坡与预告对象的状态会持续变化。Rubin、MI455X、MI440X、MI430X、CDNA 6/MI500、H20BFX、RTX PRO 6000D 和 B100 在最终合并前复核一次带日期的一手状态页。`production_ramp`、`announced` 和 `available` 不能互换；发布、开始生产、伙伴部署和客户可用是不同事实。

README 和 AGENTS 需要由总控更新。本任务没有修改它们。接收本计划后，README 应增加 M2 已进入两厂商批量排期的状态；AGENTS 应记录本批工作包、对象数量预算、AMD 本地固定资料缺口，以及地区变体和生产爬坡对象的复核要求。

## 8. 交接状态与验证

任务状态为已完成，等待总控接收。本计划读取了 `研究计划.md`、`资料卡/字段字典.md`、`资料卡/模板.md`、`审计/子代理交接/object_candidates.csv`、`审计/子代理交接/model_inventory.md`、`数据/enums.csv`，并只读核对了正式对象、关系和现有来源表。没有联网采集规格，也没有写入任何正式数据。

候选表复算结果为：NVIDIA 44 条候选，排除 4 条后进入排期 40 条，其中架构 6、封装 1、SKU 23、系统 10；AMD 24 条候选，排除 2 条后进入排期 22 条，其中架构 5、SKU 13、系统 4。15 个工作包的卡片预算分别合计 NVIDIA 40 张、AMD 22 张。资料池复查得到 NVIDIA 本地 PDF 65 份、AMD 0 份，与本计划的缺口判断一致。

`report-humanizer` 机器扫描已通过。人工回读按 `shuorenhua` 的 docs 场景做最小修改，并把 H800、H20、L20、L2、H20BFX 从 Hopper 行移到“架构待核的地区产品”，避免在证据确认前建立架构关系。型号、数量、日期、枚举、来源键和对象关系均已保留；文件按 UTF-8 保存，未发现替换字符和禁用公式分隔符。

仍待执行阶段解决的事项包括 A800 两条候选的身份关系、NVIDIA 地区产品的对象匹配规格、B100 与 Rubin 的最终状态、AMD MI308X 的稳定产品资料、MI350P 订货边界，以及 CDNA 5/6 对象的截止日状态。这些问题不妨碍按工作包启动，但会影响最终对象数与卡片完成度。

总控接收后可先派发第一波 `NV-A`、`NV-C` 和 `AMD-A`。本任务只写入 `审计/子代理交接/m2_nvidia_amd_batch_plan.md`。README 与 AGENTS 已检查但未修改，因为任务边界明确禁止子代理改全局状态；两者需要总控在接收后同步。
