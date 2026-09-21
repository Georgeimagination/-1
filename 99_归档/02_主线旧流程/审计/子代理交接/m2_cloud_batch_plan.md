# M2 云端自研加速器与 Groq LPU 批量建卡执行计划

> 状态：`ready_for_root_review`  
> 资料截止日：2026-08-12  
> 适用范围：Google TPU、AWS Trainium/Inferentia、Groq LPU  
> 性质：M2 批量建卡的范围、分包和验收计划。本文件不采集规格事实，不修改正式 CSV，也不分析训练与推理的架构差异。

## 1. 输入与计数口径

本计划读取了 `研究计划.md`、`资料卡/字段字典.md`、`资料卡/模板.md`、`数据/enums.csv`、`审计/子代理交接/model_inventory.md`、`审计/子代理交接/object_candidates.csv`，并核对了 M1 的 Trainium2 试填卡和正式对象关系。现有候选普查已经在资料截止日核对过官方入口，本次没有再次联网，也没有新增规格断言。

这里把“对象”和“资料卡”分开计数。对象是 `objects.csv` 中可被事实或关系引用的实体；资料卡是面向读者的说明文档。默认一张卡只有一个主对象。Google 的配置族仍可在一张配置族卡中列多行稳定 API 配置，不为每个芯片数机械复制架构卡。正式名称尚未固定的未来系统可以先保留对象候选、字段要求和检索记录，等身份门通过后再建卡，所以卡片数允许小于对象候选数。

| 厂商 | 主样本对象 | 观察对象 | 历史锚点对象 | 排除或只留线索 | 预计资料卡 | 纳入对象候选 |
|---|---:|---:|---:|---:|---:|---:|
| Google TPU | 14 | 4 | 2 | 1 | 17 至 20 | 20 |
| AWS Trainium/Inferentia | 19 | 3 | 3 | 1 | 24 至 25 | 25 |
| Groq LPU | 6 | 4 | 1 | 2 | 11 | 11 |
| 合计 | 39 | 11 | 6 | 4 | 52 至 56 | 56 |

四条排除记录分别是 TPU v2、Inferentia3、“Groq 2”，以及不作为硬件 SKU 建卡的 GroqCloud。GroqCloud 仍可作为部署渠道写入产品部署映射和来源筛选记录。表中的 56 是候选表内的纳入对象；M1 已有的 `OBJ-AWS-TRN2-INSTANCE-FAMILY` 是额外的关系型正式对象，不对应新的候选行或资料卡。若总控继续保留它，三厂商最终会涉及 57 个正式对象。

## 2. 建卡前必须固定的对象边界

### 2.1 四层数据不能相互继承

架构卡只保存一代产品共享的执行模型、计算路径、指令或算子能力、数值格式和公开机制。芯片或封装卡保存单个物理器件的启用单元、存储接口、容量、带宽、功耗和封装事实。云配置或产品 SKU 卡保存用户实际获得或计费的配置。系统卡保存服务器、机架、Pod 或 UltraServer 的设备数量、拓扑、聚合容量、聚合算力和系统带宽。

关系只说明“实现、包含、部署或配置归属”，不会让事实自动向上或向下继承。Pod、UltraServer、节点和机架的聚合值不能除以设备数后写成芯片直接规格；反向把单芯片值乘成系统值时，也只能建立带输入、公式和适用条件的派生记录，不能冒充厂商系统规格。

### 2.2 Google TPU

Cloud TPU accelerator type、虚拟机或 Cluster Director machine type、Slice 和 Pod 是不同边界。`v4-*`、`v5litepod-*`、`v5p-*`、`v6e-*` 和 TPU7x Slice 先各建一张配置族卡，稳定 API 名称写入卡内配置表；只有计费、主机映射或单对象资源边界不同且需要独立引用时，才由总控批准拆成新对象。

TPU Pod 是系统对象。Pod 芯片数、聚合 HBM、互联拓扑和系统带宽只进入 Pod 卡。`ct6e-standard-*` 是机器类型命名，不应直接沿用候选表中的 `cloud_accelerator`；总控需要在导入前根据官方定义决定是否改为正式 `cloud_instance`。TPU 内部的 TensorCore、矩阵单元或向量单元进入 `components.csv`，不另建产品对象。

### 2.3 AWS

Trainium/Inferentia 架构、物理芯片、EC2 计费实例和 UltraServer 分开。候选表把多条 EC2 实例暂记为 `cloud_accelerator`，正式导入时应与 M1 Trainium2 对象保持一致，使用 `cloud_instance`。NeuronCore 是芯片内计算组件，不是可购买芯片或实例。

M1 的 `Trainium2_试填草稿.md` 同时覆盖架构、芯片、三个实例和 UltraServer，适合作为证据与数据模型试填。M2 最终卡应按对象拆开：架构卡、芯片卡、三个实例卡和 UltraServer 卡分别引用同一批已验收事实，不复制原子事实。`OBJ-AWS-TRN2-INSTANCE-FAMILY` 可以保留为配置族关系对象，不承载三个实例的聚合规格。

### 2.4 Groq

第一代 LPU 架构、GroqChip Processor、三种 GroqCard、GroqNode 和 GroqRack 分层。三张 GroqCard 卡只记录各自端口配置和产品边界，共享架构与芯片事实回指对应对象。GroqNode 和 GroqRack 的最大 LPU 数、节点数和互联值不下放到卡或芯片。

Groq 3 LPU/LP30 和 LPX 由 NVIDIA 官方资料定义，不能继承第一代 GroqChip 的制程、存储或吞吐。正式导入前，总控还要决定 Groq 3 对象使用 `VEN-NVIDIA`，还是继续按 Groq 产品线归档并在显示名称中保留 NVIDIA 归属。当前关系枚举没有“收购后产品线归属”关系，子代理不得自行造枚举。GroqCloud 是服务和部署渠道，不建硬件资料卡。

## 3. 可并行工作包

所有工作包只写各自的资料卡目录和 `审计/子代理交接/m2_staging/<work_package_id>/`。结构化片段先留在 staging，主代理按包顺序合并正式 CSV。每包开始前由总控预留对象 ID，完成后再跑全局校验；同一张卡和同一 staging 目录不得由两个代理并发编辑。

### 3.1 Google TPU

| 工作包 | 对象和范围 | 预计卡片/对象 | 最低官方证据组合 | 动态风险 | 验收重点 |
|---|---|---:|---|---|---|
| `M2-G-ARCH` | TPU v3 历史锚点；TPU v4、v5e、v5p、v6e、TPU7x 主样本；TPU 8t、8i 观察项；TPU v2 排除记录 | 8 卡/8 纳入对象，另 1 条排除记录 | 每代 Cloud TPU 官方代际页；Google 原始架构论文或 Hot Chips 材料；首次发布或 GA 的固定公告。现有入口为 G-1 至 G-9，本地可优先读 TPU v4、Ironwood 和五代回顾的官方论文 | 高。代际页会随可用状态和配置更新，8t/8i 仍处于预告到开放的过渡期 | 每张架构卡只写共享机制；发布日期、GA 和当前可用状态分别记录；8t/8i 不建立未出现的稳定 accelerator type |
| `M2-G-CONFIG` | `v4-*`、`v5litepod-*`、`v5p-*`、`v6e-*`、`ct6e-standard-*`、TPU7x Slice 六个配置族 | 6 卡/6 对象；具体 API 名称作为卡内配置行，行数以截止日快照为准 | G-1 系统架构页；对应代际页 G-2 至 G-7；官方 accelerator configuration、机器类型和区域可用性文档的同日快照 | 高。API 名、主机映射、区域和退役状态都可能原地变化 | 配置行必须同时写 API 名、主机边界、芯片或加速器数量口径和状态日期；`ct6e-standard-*` 的正式对象类型先由总控裁决；不复制架构吞吐和片上结构 |
| `M2-G-SYSTEM` | TPU v3 云系统历史候选；v4 Pod、v5p Pod、TPU7x 9216-chip Pod 主样本；TPU 8t、8i 未来系统观察候选 | 3 至 6 卡/6 对象 | G-1 与对应代际页；Google 的 TPU v4 光互联超算、韧性和 Mission Apollo 原始论文；Ironwood 官方 Hot Chips 材料；8t/8i 官方技术深潜和发布材料 | 高。Pod 规模和可用区域可能更新，未来系统名可能尚未固定 | v4、v5p、TPU7x 三张主系统卡必须完成；v3、8t、8i 只有在正式系统身份可定位时建轻量卡，否则保留候选、缺失要求和检索记录，不制造名称 |

Google 的来源筛选要把“当前配置状态”和“架构机制”分开。动态 Cloud 文档通常负责身份、当前配置和状态；固定论文负责阵列、数据流、互联机制或系统设计。若动态页的全部事实已由固定资料覆盖，但它仍是唯一的当前可用状态证据，可以只保留 `status_version_evidence` 角色。

### 3.2 AWS Trainium/Inferentia

| 工作包 | 对象和范围 | 预计卡片/对象 | 最低官方证据组合 | 动态风险 | 验收重点 |
|---|---|---:|---|---|---|
| `M2-A-ARCH` | Inferentia 第一代历史锚点；Trainium 第一代、Inferentia2、Trainium2、Trainium3 主样本；Trainium4 观察项；Inferentia3 排除记录 | 6 卡/6 纳入对象，另 1 条排除记录 | A-1 Neuron 架构文档；各代 Neuron/设备架构页；A-3、A-6、A-8、A-10 等固定发布材料；Trainium4 使用 A-11、A-12 路线图材料 | 高。Neuron 文档随 SDK 版本变化，Trainium4 的对象名和状态尚未冻结 | 一代一张架构卡；架构代际称谓冲突保留原文和冲突组；Inferentia3 只写排除与再纳入条件，不把 “future Inferentia technology” 当产品名 |
| `M2-A-PACKAGE` | Inferentia 第一代、Trainium 第一代、Inferentia2、Trainium2、Trainium3 五个物理芯片或封装对象 | 5 卡/5 对象 | 对应 Neuron 设备架构页和固定技术材料；EC2 产品页只能补产品映射，不能代替单芯片事实；Trainium2 复用 M1 已固定的 15 个官方快照和断言链 | 中高。AWS 常以实例口径公开资源，芯片级字段可能长期缺失 | 只收单芯片直接规格；实例总值不得反除；封装、物理累加位宽或片上带宽没有一手资料时按检索结果写缺失状态 |
| `M2-A-INSTANCE` | Inf1 历史实例家族；`trn1.2xlarge`、`trn1.32xlarge`、`trn1n.32xlarge`；四个 Inf2；`trn2.3xlarge`、`trn2.48xlarge`、`trn2u.48xlarge` | 10 至 11 卡/11 对象 | A-2、A-5、A-7 实例产品页；AWS EC2 accelerated computing instance specifications；A-3、A-4、A-6、A-8 固定 GA 公告；区域和购买方式的同日官方快照 | 高。实例表、区域、Capacity Blocks、预览和 GA 文字会变；`trn2u.48xlarge` 首次状态证据仍不足 | 每个计费 SKU 独立卡并使用 `cloud_instance`；Inf1 家族若只有关系作用可只建轻量卡；M1 已有的三个 Trn2 SKU 事实直接引用，不重新抽取成另一套 ID |
| `M2-A-SYSTEM` | Trn2 UltraServer 观察项；Trn3 UltraServer 主样本；Trainium4 NVLink Fusion 未来系统观察项 | 3 卡/3 对象 | A-7、A-9 系统产品页；A-8、A-10 固定发布或 GA 公告；A-11、A-12 路线图材料；状态页保存截止日快照 | 很高。Trn2 动态页存在 “available now” 与 “available in preview” 并存，Trainium4 预计 2027 交付 | Trn2 冲突继续保持 `conflicting_unresolved`，直到固定版证据解决；Trn3 的“最多”规模和实际最小可用配置分开；Trainium4 不虚构 EC2 实例或最终系统名 |

AWS 的最小来源集合预计会同时保留一份固定发布材料和一份当前产品页。两者内容即使大量重叠，也分别承担首发状态和当前配置职责。只有在逐事实覆盖证明其中一份没有独有角色后，才可标为 `redundant_covered`。

### 3.3 Groq LPU

| 工作包 | 对象和范围 | 预计卡片/对象 | 最低官方证据组合 | 动态风险 | 验收重点 |
|---|---|---:|---|---|---|
| `M2-Q-ARCH` | 第一代 LPU 架构历史锚点；Groq 3 LPU 架构观察项；“Groq 2”排除记录 | 2 卡/2 纳入对象，另 1 条排除记录 | Q-1 官方 papers 入口；第一代原始架构论文；Q-3 架构说明仅在提供独有现行术语时保留；Groq 3 使用 NVIDIA Q-8、Q-9 | 中高。Q-1 的文档入口和 Q-3 博客可更新，Groq 3 状态仍处于生产爬坡 | 两代架构完全隔离；Groq 2 的排除由官方入口检索日志和截止日支撑，不把“未出现”写成永久不存在 |
| `M2-Q-PACKAGE` | GroqChip Processor 主样本；NVIDIA Groq 3 LPU/LP30 观察项 | 2 卡/2 对象 | Q-2 固定版 GroqChip Processor brief 和原始论文；LP30 使用 Q-8 产品页与 Q-9 技术文档，并补固定发布材料或同日快照 | 高。GroqChip PDF 可能在同一 URL 替换版本，LP30 的订货名、形态和功耗可能变化 | PDF 必须记录版本、哈希和获取日；LP30 的厂商归属由总控先裁决；不得沿用第一代芯片规格 |
| `M2-Q-SKU` | GroqCard `GC1-010B`、`GC1-0109`、`GC1-0100` 三个主样本 | 3 卡/3 对象 | Q-4 GroqCard 固定版产品简报；Q-1 文档索引；若 v1.5 与 v1.7 都可取得，两版作为同一来源家族比较 | 中。旧 PDF URL、版本和 “shipping now” 状态可能失效或被替换 | 三个 SKU 只保留各自独有端口和产品事实；共享字段回指 GroqChip；旧版本若独有供货状态或修订差异，不因版本旧而删除 |
| `M2-Q-SYSTEM` | GroqNode `GN1-B8C`、GroqRack `GR1-C9A` 主样本；Groq 3 LPX compute tray 与 256-LPU rack 观察项；GroqCloud 服务映射 | 4 卡/4 硬件对象，另 1 条不建硬件卡的服务记录 | 第一代使用 Q-4、Q-5、Q-6 固定版产品简报；Q-7 只负责 GroqCloud 部署状态；Groq 3 使用 NVIDIA Q-8、Q-9 | 高。最大配置、实际订货配置和现役硬件修订可能不同；LPX 托盘对象类型及交付状态待核 | Node、Rack、tray、LPX rack 各自保存系统聚合值；“最多”配置不当作默认订货配置；GroqCloud 不反推底层硬件代际 |

Groq 的固定版产品简报很可能覆盖博客和新闻稿中的大部分规格。筛选时先把各版本放入同一来源家族，再做事实覆盖比较。旧版如果是唯一的 `shipping now`、SKU 修订或端口差异证据，应以状态或版本角色保留，不能只因为新版存在就自动淘汰。

## 4. 并行顺序和依赖

对象 ID 和正式对象类型由总控在第一波开始前统一预留。随后可以按下表并行，每一波最多三个厂商包；前一波的架构 ID 通过验收后，下一波才能建立正式关系。抽取工作可以提前在 staging 中进行，但不能提前合并。

| 波次 | 并行包 | 进入条件 | 退出条件 |
|---|---|---|---|
| 0 | 总控预处理 | M1 已验收；候选表可读 | 修正 AWS 实例对象类型；裁决 `ct6e-standard-*` 类型和 Groq 3 厂商归属；为 56 个纳入候选预留或复用对象 ID，并复用 M1 已有的 Trainium2 正式对象 |
| 1 | `M2-G-ARCH`、`M2-A-ARCH`、`M2-Q-ARCH` | 波次 0 完成 | 架构卡、排除记录和代际关系通过独立复核 |
| 2 | `M2-G-CONFIG`、`M2-A-PACKAGE`、`M2-Q-PACKAGE` | 对应架构 ID 冻结 | 配置族、芯片/封装卡与架构关系可合并；动态来源已固定版本或快照 |
| 3 | `M2-G-SYSTEM`、`M2-A-INSTANCE`、`M2-Q-SKU` | 下级对象 ID 可引用 | SKU、配置与系统边界检查通过，聚合值没有下放 |
| 4 | `M2-A-SYSTEM`、`M2-Q-SYSTEM`、Google 高风险卡独立复核 | 前三波正式合并 | 三厂商卡片、来源筛选建议和缺口记录齐备 |
| 5 | AWS 与 Groq 高风险卡交叉复核、总控最小集与全局校验 | 所有包交付 | 正式 CSV 顺序合并；来源反向删除测试完成；全局校验通过 |

同一代理不能复核自己的高风险卡。Google 的动态配置、AWS UltraServer 状态冲突、Groq 3 厂商归属和交付状态至少各安排一次独立复核。

## 5. 每个工作包的统一交付与验收

每包交付由四部分组成：范围清单、资料卡、结构化 staging 片段和交接说明。交接说明必须列出实际读取的官方或原始论文、定位方式、来源版本、未找到或无法访问的字段、冲突、筛选建议、全部写入文件和复核人。

验收按以下顺序进行：

1. 范围检查：包内候选 ID 无遗漏、无越界；主样本、观察项、历史锚点和排除项的数量与本计划一致。身份门失败的对象不得用推测名称建卡。
2. 对象检查：架构、封装、云配置或 SKU、系统分层；正式关系只用 `implements_architecture`、`instance_contains_accelerator`、`deployed_in_system` 等已有枚举。
3. 事实检查：进入卡片的数值拆成原子事实，精度、稀疏、方向、峰值或实测、对象作用域和版本条件齐全。系统聚合值没有下放。
4. 缺失检查：九个完整度领域都要有状态。`not_found` 必须有计划检索日志，`not_public` 必须有一手明确表述，动态页面无法固定时用 `pending_verification` 或 `inaccessible_evidence`。
5. 来源检查：最低证据组合中的资料先标 `pending`。事实抽取完成后才判断 `selected`、`redundant_covered`、`superseded` 或 `lead_only`。每个入选来源都要有无法被其余来源替代的事实、状态、冲突或版本职责。
6. 验证检查：包内 staging 的主键、外键、枚举和本地文件哈希先做自检；主代理合并后运行 `Validate-ResearchData.ps1`。新增固定资料时还要运行 `Test-SourcePool.ps1`。

媒体和第三方报道不进入这些包的最低证据组合。本轮如果官方资料明确缺少持续性能或内部实现，可以把独立原始测量论文另开验证包；它不能替代产品身份、供货状态或厂商规格。

## 6. 最小参考资料的执行方式

“最低官方证据组合”只是开工所需的来源角色集合，不等于已经确定的最小参考资料。每个来源先进入同一产品或版本家族，完成逐来源断言后再生成覆盖矩阵。删除候选来源时，需要确认其全部事实、脚注、版本状态和冲突职责都被保留来源覆盖。

固定版数据手册、产品简报、原始架构论文和固定发布公告优先保存本地副本。动态产品页和云配置页保存访问日期、页面标题、入口 URL 和快照哈希。旧版资料如果提供新版删除的 SKU、发布日期、供货状态或接口差异，继续保留；只有内容与职责都被覆盖时才标 `redundant_covered`。

## 7. 需要总控处理的决定

本计划发现四项会影响正式导入的决策，子代理不应自行处理：

- AWS EC2 实例候选应从临时 `cloud_accelerator` 映射为正式 `cloud_instance`。
- `ct6e-standard-*` 是否属于 `cloud_instance`，需要依据官方对象定义统一决定。
- NVIDIA Groq 3 LPU/LP30 的 `vendor_id` 和 Groq 产品线归档方式需要固定。
- Google v3 云系统、TPU 8t/8i 未来系统和 Trainium4 未来系统若没有稳定正式名称，应保留候选与缺失记录，不提前制造卡片。

## 8. README 与 AGENTS 检查

需要总控更新，子代理本次没有修改。总控接收本计划后，`README.md` 应加入 M2 批次计划入口、三厂商候选计数和当前批次状态；`AGENTS.md` 应记录 56 个纳入对象候选（保留 M1 Trn2 配置族时涉及 57 个正式对象）、52 至 56 张预计资料卡、四项导入前决策，以及分层 staging 和顺序合并约定。若总控最终改变对象或卡片计数，应以验收后的正式范围为准同步更新两份文件。

## 9. 本次交接

本次只新增 `审计/子代理交接/m2_cloud_batch_plan.md`。未改动 `数据/*.csv`、`最小参考资料库/*.csv`、`资料卡/`、`进度/`、`README.md`、`AGENTS.md` 或 `研究计划.md`，也没有下载资料或写入规格事实。