# 2022 至 2026 年 AI 加速芯片型号候选普查

> 性质：阶段 0/2 的型号范围交接，不是完成版型号索引，也不包含训练/推理架构差异结论。  
> 资料截止日：2026-08-12。动态网页均按该日访问结果记录。  
> 覆盖：NVIDIA GPU（图形处理器）、Google TPU（Tensor Processing Unit，张量处理单元）、AWS Trainium/Inferentia、Groq LPU（Language Processing Unit，语言处理单元）、寒武纪 MLU、华为昇腾 NPU（Neural Processing Unit，神经网络处理器）和 AMD Instinct。

## 1. 普查口径

这份清单先回答“有哪些正式对象值得建卡”，不提前填满规格。旧调研和现有清单只作入口线索；型号身份、发布日期、云端开放或供货状态，优先回到厂商产品页、数据手册、云文档和原始发布材料。没有厂商一手身份的传闻型号只留在线索区。

### 1.1 暂定处理

| 暂定处理 | 本次判定口径 | 后续动作 |
|---|---|---|
| 主样本 | 具体 SKU（Stock Keeping Unit，产品配置）在 2022-01-01 至 2026-08-12 已正式供货、开放云服务或有可验证生产部署 | 建完整资料卡；身份和状态仍须由总控复核 |
| 观察项 | 已由厂商正式公布，但截至资料截止日仍属于预告、未来供货、生产爬坡，或现有页面没有消除供货矛盾 | 建观察卡或接近完整的草稿卡，不与现役型号混排 |
| 历史锚点 | 早于 2022 年，但能解释当前架构、软件兼容或代际演进 | 只建轻量卡，不扩展成完整旧产品谱系 |
| 排除项/线索 | 超出大模型数据中心范围、仅有媒体传闻、名称无法对应正式对象，或只是没有独立硬件边界的营销集合 | 不建正式卡；保留筛除理由和再检索条件 |

“主样本候选”表示本轮已有足够的一手身份依据，但并不等于资料卡已经完成。发布日期、可购买日期、云端开放日期和生产部署日期是不同事实，不互相替代。

### 1.2 对象层级

后续建卡须保留四层关系：架构代际承载共享的计算核心和执行模型；裸片或封装承载芯粒、封装内互联和 HBM；产品 SKU 承载卡、模组或云实例的容量、功耗和频率；系统对象承载底板、服务器、机架、Pod 和集群拓扑。OAM 指 OCP Accelerator Module，即开放计算项目加速器模组。

同一名称出现在不同层级时不合并。例如 Trainium2 是芯片，`trn2.48xlarge` 是云实例，Trn2 UltraServer 是四实例构成的系统；Atlas 950 SuperPoD 的 1024-NPU 产品配置与 8192-NPU 路线图配置也不能写成同一条现役事实。

Google TPU 的大量 Slice 拓扑先作为“配置子表”记录；只有主机与芯片映射、单对象容量或可计费边界发生变化时才拆成独立 SKU 卡。AWS 的实例类型本身就是正式计费 SKU，应逐一建卡。容量或冷却差异若没有独立订货号，先作为同一卡的配置变体，不擅自制造新 SKU。

## 2. NVIDIA GPU

NVIDIA 候选很多，旧材料又经常混写芯片、SXM 模组、PCIe 卡、双 GPU 产品和机架系统。本轮建议按 Ampere、Hopper、Ada Lovelace、Blackwell、Blackwell Ultra 和 Rubin 建架构页，再把具体模组与系统挂接进去。

| 候选对象 | 层级 | 时间或现状（暂定） | 暂定处理与拆卡建议 | 核对入口 | 主要缺口 |
|---|---|---|---|---|---|
| Ampere；A100 SXM4 80 GB | 架构；产品 SKU | A100 早于时间窗，但仍是 Hopper 前的重要锚点 | 历史锚点；只保留一个 SXM 80 GB 代表卡 | NV-1、NV-2 | 固定版数据手册的版本和发布日期 |
| NVIDIA A800 数据中心加速器 | 产品 SKU；地区变体 | 官方驱动与支持矩阵确认身份，具体卡型在旧材料中混杂 | 主样本候选；与“A800 40GB Active”分别建身份记录 | NV-2、NV-3 | 中国市场数据中心 A800 的 40/80 GB、PCIe/SXM 正式订货名和发布日期 |
| Hopper；H100 SXM5 80 GB、H100 PCIe 80 GB、H100 NVL | 架构；产品 SKU | 2022 起正式产品 | 主样本；三种物理对象分卡，H100 NVL 不写成单颗 H100 | NV-1、NV-2、NV-4 | H100 NVL 的双 GPU 边界、容量变体和固定版规格页 |
| H200 SXM 141 GB、H200 NVL 141 GB | 产品 SKU | 当前官方产品组合 | 主样本；SXM 与 NVL 分卡 | NV-1、NV-4 | 首次供货日期、NVL 设备数与带宽口径 |
| H800、H20、L20、L2 | 产品 SKU；地区/出口变体 | 官方驱动与 GPU Operator 文档确认正式身份 | 主样本候选；每个正式卡型独立行，不能用相邻型号推规格 | NV-2、NV-3 | 各型号发布日期、内存/互联限制、地区与出口管制版本沿革 |
| H20BFX、RTX PRO 6000D | 产品 SKU；地区/出口变体 | 2026 驱动发布说明出现正式市场名 | 观察项，先建身份占位，不把驱动支持等同于公开供货 | NV-3 | 独立产品页、订货号、地区、容量和首供日期 |
| Ada Lovelace；L40、L40S、L4 | 架构；产品 SKU | 2022 至 2023 年 进入数据中心产品线，L40S/L4 仍列于当前产品组合 | 主样本；L40、L40S、L4 分卡 | NV-1、NV-2、NV-5 | L40 与 L40S 的正式首供日期；固定版规格文件 |
| Grace Hopper Superchip（GH200） | 封装/模组 | 当前产品与支持矩阵确认 | 主样本；CPU+GPU 超级芯片单独建卡，不归并为 H100/H200 卡 | NV-1、NV-2 | 96/144 GB 等配置、GPU 版本与首次供货映射 |
| GH200 NVL2、GH200 NVL4 | 系统对象 | 当前官方 line card 列出 | 主样本；系统卡仅承载聚合与互联事实 | NV-1 | 具体 Superchip 配置、系统拓扑与供货区域 |
| Blackwell；B100、B200 SXM 180 GB | 架构；产品 SKU | B200 已进入当前产品组合；B100 有正式发布但当前组合弱化 | B200 为主样本；B100 暂列观察/有限供货候选，不能用 B200 规格代填 | NV-1、NV-2、NV-6 | B100 最终量产规格、实际供货和是否形成独立长期 SKU |
| Blackwell Ultra；B300 SXM 288 GB | 架构；产品 SKU | 当前官方组合含 HGX B300、GB300 NVL72 | 主样本 | NV-1、NV-7 | 单模组固定版数据手册与首供日期 |
| RTX PRO 6000 Blackwell Server Edition | 产品 SKU | 当前 NVIDIA 数据中心组合列出 | 主样本；与工作站版及 RTX 6000D 分开 | NV-1 | Server Edition 的容量/功耗变体及供货日期 |
| HGX H100、HGX H200、HGX B200、HGX B300 | 系统/底板 | 当前官方产品组合 | 主系统对象；只有解释 8-GPU 拓扑和 NVLink/NVSwitch 时建卡 | NV-1、NV-6 | B100 是否存在需保留的最终 HGX 系统；各代底板版本 |
| GB200 NVL4、GB200 NVL72 | 系统对象 | 当前官方产品组合 | 主样本；NVL4 和 NVL72 分卡 | NV-1、NV-6 | NVL4 的组成、NVL72 计算托盘/机架边界和固定版规格 |
| GB300 NVL72 | 系统对象 | 官方页面标示可用，line card 列入当前组合 | 主样本 | NV-1、NV-7 | 可用区域、首次客户交付日期和系统版本 |
| Rubin GPU、Rubin CPX GPU、Vera Rubin NVL72 | 架构；产品 SKU；系统 | 2026 官方发布称平台进入 full production，合作伙伴产品计划 2026 年下半年 | 观察项（生产爬坡）；Rubin 与 Rubin CPX 分卡，NVL72 为系统卡 | NV-8、NV-9 | 截止日是否已有可验证客户交付；最终时钟、功耗、有效互联载荷 |

范围外处理：A30、A40、V100 等不再扩展；如需解释 PCIe 或 Tensor Core 演进，优先由 A100 历史锚点承担。GeForce 和桌面/工作站 RTX 不进入主范围，只有明确标为服务器或数据中心产品的 RTX PRO 型号例外。`A800` 存在同名碰撞，必须以完整市场名、容量、形态和设备标识消歧。

## 3. Google TPU

TPU 是云端产品，芯片代际、TensorCore 数量、Cloud TPU accelerator type、Slice 和 Pod 不能视为同一个 SKU。每代建一张芯片/架构卡；云配置按稳定 API 名称进入配置表；Pod 只在互联规模或拓扑需要时建系统卡。

| 候选对象 | 层级 | 时间或现状（暂定） | 暂定处理与拆卡建议 | 核对入口 | 主要缺口 |
|---|---|---|---|---|---|
| TPU v3 | 架构；云系统 | 早于 2022 | 历史锚点，仅用于解释后续 MegaCore/Pod 演进 | G-1 | 是否确有必要保留到最终历史锚点 |
| TPU v4；`v4-*` Slice；v4 Pod | 架构；云配置；系统 | 2022 正式对外提供 | 主样本；芯片/架构一张卡，Slice 拓扑为子表，Pod 单独系统卡 | G-1、G-2 | 首次 GA 日期、所有仍有效 accelerator type 和退役状态 |
| TPU v5e；`v5litepod-*`/对应现行 API 类型 | 架构；云配置 | 2023 对外提供，官方明确用于训练与推理 | 主样本；不为每个芯片数机械复制架构事实 | G-1、G-3 | 旧名与现行 API 名映射、单主机与多主机边界 |
| TPU v5p；`v5p-*` Slice；v5p Pod | 架构；云配置；系统 | 2023 至 2024 年 对外提供 | 主样本 | G-1、G-4 | 正式 GA 日期、最大 Pod 规模和可用区域的时点快照 |
| TPU v6e（Trillium）；`v6e-*` 与 `ct6e-standard-*` | 架构；云配置 | 2024-12-11 正式 GA | 主样本；云 TPU 拓扑与 Cluster Director 机器类型映射分表 | G-5、G-6 | `v6e-1/4/8` 与 `ct6e-standard-1t/4t/8t` 的准确主机与芯片对应 |
| TPU7x（Ironwood）；TPU7x Slice 与 9216-chip Pod | 架构；云配置；系统 | 截止日官方称最新且可在 Google Cloud 使用 | 主样本 | G-1、G-7 | 首次公开可用/GA 日期、地区、最小配置与 Pod 内拓扑 |
| TPU 8t | 架构；未来云系统 | 2026-04-22 正式公布，官方称即将向 Cloud 客户提供 | 观察项；与 8i 分卡 | G-8、G-9 | GA/预览日期、稳定 accelerator type、最终配置 |
| TPU 8i | 架构；未来云系统 | 2026-04-22 正式公布，官方称即将提供 | 观察项；与 8t 分卡 | G-8、G-9 | GA/预览日期、稳定 accelerator type、最终配置 |

TPU v2 不再建锚点；TPU 8t/8i 的预告算力和系统值只能留在观察卡。第三方把 `TPU7x`、Ironwood、单芯片和一个 Pod 混称“第七代 TPU”的记录，后续都应拆回官方对象。

## 4. AWS Trainium / Inferentia

AWS 需要同时记录芯片、NeuronCore 架构、EC2 实例和 UltraServer。实例型号是用户实际获得的产品边界，必须逐一建卡；同一芯片的实例聚合值不能除以设备数后冒充芯片公开值，除非厂商同时给出单芯片事实。

| 候选对象 | 层级 | 时间或现状（暂定） | 暂定处理与拆卡建议 | 核对入口 | 主要缺口 |
|---|---|---|---|---|---|
| Inferentia（第一代）；Inf1 | 架构/芯片；云实例 | 2019 起提供，早于窗口 | 历史锚点；只保留芯片和一条实例家族关系 | A-1 | 是否仍需记录具体 Inf1 规格和退役状态 |
| Trainium（第一代）；`trn1.2xlarge`、`trn1.32xlarge` | 架构/芯片；云 SKU | 2022 正式提供 | 主样本；芯片卡与两个实例 SKU 分开 | A-2、A-3 | 首次 GA 日期的固定发布页；实例芯片数与网络配置复核 |
| `trn1n.32xlarge` | 云 SKU | 2023-04-13 GA | 主样本；因 EFA 网络边界不同独立建卡 | A-4 | 与 `trn1.32xlarge` 的共享事实去重 |
| Inferentia2；`inf2.xlarge`、`inf2.8xlarge`、`inf2.24xlarge`、`inf2.48xlarge` | 架构/芯片；云 SKU | Inf2 于 2023 正式 GA | 主样本；四个实例逐一建卡 | A-5、A-6 | 芯片级与实例级带宽的来源边界；区域时点 |
| Trainium2；`trn2.3xlarge` | 架构/芯片；云 SKU | 单芯片实例已列入当前产品页；首次加入日期待核 | 主样本候选；单独建卡 | A-7 | 首次可用日期、地区与购买方式 |
| `trn2.48xlarge` | 云 SKU | 2024-12-03 GA | 主样本 | A-7、A-8 | 后续区域扩展不覆盖首发状态 |
| `trn2u.48xlarge` | 云 SKU | 当前产品页列为可组成 UltraServer 的正式实例类型 | 主样本候选；与普通 `trn2.48xlarge` 分卡 | A-7 | 正式加入日期、GA/预览状态的固定证据 |
| Trn2 UltraServer（64 Trainium2） | 系统对象 | 2024 发布时为 preview；当前页面同时残留“available now”和“available in preview” | 观察项，直到固定版 GA 证据消除页面自相矛盾 | A-7、A-8 | 首次 GA 日期、可用区域、四实例拓扑的正式版本 |
| Trainium3；Trn3 UltraServer（最多 144 芯片） | 架构/芯片；系统/云产品 | 2025-12-02 GA | 主样本；芯片卡和 UltraServer 系统卡分开，不虚构普通 Trn3 单实例 SKU | A-9、A-10 | 是否存在未在当前页面公开的实例大小；地区和最小配置 |
| Trainium4；未来 NVLink Fusion 系统 | 架构；未来系统 | 官方称正在设计，预计 2027 交付 | 观察项 | A-11、A-12 | 正式 SKU、封装、云实例与交付日 |
| “Inferentia3” | 未确认对象 | 截止日未找到 AWS 正式产品身份 | 排除项/线索；不得从“future Inferentia technology”推导产品名 | A-1、A-10 | 只有 AWS 正式发布产品名后再纳入 |

## 5. Groq LPU

Groq 当前公开材料主要覆盖第一代 14 nm GroqChip 产品栈，以及 2026 年由 NVIDIA 正式公布的 Groq 3 LPU/LPX。没有足够一手依据把中间演进命名为“Groq 2”。

| 候选对象 | 层级 | 时间或现状（暂定） | 暂定处理与拆卡建议 | 核对入口 | 主要缺口 |
|---|---|---|---|---|---|
| 第一代 LPU 架构；GroqChip Processor | 架构；芯片/封装 | 架构论文早于 2022，当前 14 nm 产品仍在部署 | 历史锚点（架构）+ 主样本候选（现役芯片产品身份） | Q-1、Q-2、Q-3 | 芯片首次量产日期、当前订货号与产品修订版 |
| GroqCard `GC1-010B`、`GC1-0109`、`GC1-0100` | 产品 SKU | 2022 产品资料标示 shipping now | 主样本；三种 C2C 端口配置逐一建卡 | Q-1、Q-4 | v1.5 与 v1.7 规格修订差异、各卡实际供货期 |
| GroqNode `GN1-B8C` | 系统对象 | 8 GroqCard 服务器，官方产品资料 | 主样本 | Q-1、Q-5 | 服务器修订版、卡 SKU 与节点拓扑的固定映射 |
| GroqRack `GR1-C9A` | 系统对象 | 最多 9 个 GroqNode，官方产品资料标示供货 | 主样本 | Q-1、Q-6 | 72-LPU 最大配置与实际订货配置差异 |
| GroqCloud | 云服务/部署渠道 | 2024 已有公开生产使用 | 不作为芯片 SKU 建卡；在产品与部署映射表记录 | Q-7 | 底层硬件修订是否公开、地区与服务代际 |
| NVIDIA Groq 3 LPU（技术文档称 LP30） | 架构；芯片/加速器 | 2026 正式公布，属于 Vera Rubin 平台 | 观察项（生产爬坡）；不得沿用第一代 GroqChip 规格 | Q-8、Q-9 | 截止日可购买/交付证据、最终产品订货名和功耗 |
| Groq 3 LPX compute tray（8 LPU）与 LPX rack（256 LPU） | 系统对象 | 2026 正式公布 | 观察项；托盘和机架分卡 | Q-8、Q-9 | 与 Rubin NVL72 的部署边界、机架交付状态和跨架拓扑 |
| “Groq 2” | 未确认对象 | 未找到厂商正式产品页或规格文件 | 排除项/线索 | Q-1 | 只有正式命名出现后再建卡 |

## 6. 寒武纪 MLU

寒武纪目前最可靠的一手身份线索来自开发套件的“芯片、板卡与 BANG 架构编号”矩阵。软件支持能证明产品身份和兼容对象，但不能单独证明首次供货日期，也不能替代板卡数据手册。

| 候选对象 | 层级 | 时间或现状（暂定） | 暂定处理与拆卡建议 | 核对入口 | 主要缺口 |
|---|---|---|---|---|---|
| BANG v2.0；MLU290；MLU290-M5 | 架构；芯片；板卡 | 早于 2022 | 历史锚点；只保留 MLU290-M5 代表卡 | C-1 | 是否需要为软件兼容保留更多 v2 型号 |
| BANG v3.0；MLU370 | 架构；芯片/封装 | 芯片代际早于 2022，仍有现行软件支持 | 历史架构锚点；封装事实独立于板卡 | C-1、C-2 | MLU370 的裸片/芯粒物理边界固定来源 |
| MLU370-S4、MLU370-X4 | 产品 SKU | 官方工具链确认身份，首发早于或接近窗口起点 | 历史兄弟型号；不作为主样本扩写，除非发布日期复核进入窗口 | C-1、C-3 | 固定版产品手册与首次供货日 |
| MLU370-X8 | 产品 SKU | 2022-03-21 官方发布 | 主样本；双芯片/四芯粒板卡，不能把整卡值写成单芯片值 | C-2、C-3 | X8 产品手册版本、板内拓扑和持续供货状态 |
| MLU370-M8 | 产品 SKU | 当前官方工具链列出正式板卡名 | 主样本候选，先建身份占位 | C-1 | 首次发布/供货、规格书和与 X8 的物理差异 |
| BANG v5.0；MLU570、MLU590 | 架构；芯片/封装 | 当前 CNToolkit 与 CNNL 正式支持 | 主样本候选；v5.0 共享架构页，MLU570/590 分封装卡 | C-1、C-4 | 首次发布、封装组成、芯片级算力/内存和供货状态 |
| MLU570 板卡 | 产品 SKU | 官方矩阵中芯片名与板卡名相同 | 主样本候选；必须用对象层级字段消歧 | C-1、C-4 | 独立板卡数据手册、容量/功耗变体、首供日期 |
| MLU590-H8、MLU590-M9 | 产品 SKU | 官方工具链确认板卡名，现行软件/论坛可见实际设备 | 主样本候选；H8、M9 分卡 | C-1、C-4 | 正式产品页、供货日期、H8/M9 的内存、功耗、冷却和互联差异 |
| MLU580 | 芯片或产品身份待定 | CNNL v1.19.0 明确新增硬件支持，但 CNToolkit v5.0 板卡矩阵未给独立板卡 | 观察项/身份占位 | C-4 | 芯片/卡对象边界、正式板卡名、发布时间和规格 |
| MLU690 | 未确认对象 | 本轮未找到寒武纪正式产品页、数据手册或工具链身份 | 排除项/线索；第三方数字不得进入事实表 | C-1、C-4 | 只有厂商一手产品身份出现后再纳入 |

## 7. 华为昇腾

华为常以 Atlas 卡、服务器和 SuperPoD 对外提供产品，而不单独公开芯片卡。建卡时应把 Ascend 芯片、Atlas 产品和云实例分层。2026 年官方页面已经比旧调研多出 Ascend 950PR、Atlas 350、Ascend 950DT、Atlas 650E、Atlas 850E 和 Atlas 950 SuperPoD，不能继续把这些全部当路线图。

| 候选对象 | 层级 | 时间或现状（暂定） | 暂定处理与拆卡建议 | 核对入口 | 主要缺口 |
|---|---|---|---|---|---|
| Da Vinci 初代；Ascend 310、Ascend 910 | 架构；芯片 | 2018/2019 发布 | 历史锚点；分别代表早期推理和训练芯片 | H-1、H-2 | 最终是否需要两张锚点，或只保留 910 |
| Ascend 910B | 芯片/封装 | 官方 2025 讲话确认现有设计和客户需求 | 主样本候选；不从非官方材料补裸片规格 | H-2 | 首次发布/供货日期、正式封装/卡型和公开技术规格 |
| Ascend 910C | 芯片/封装 | 2025 随 Atlas 900 A3 SuperPoD 规模部署 | 主样本；芯片卡与 A3 系统卡分开 | H-2、H-3 | 封装组成、单芯片与单模组边界、固定版规格 |
| Atlas 300I A2（32 GB、64 GB 配置） | 产品 SKU/配置 | 当前正式产品页，面向生成式大模型推理 | 主样本；没有独立订货号前用一张卡记录两个配置 | H-1、H-4 | 首次发布/供货日期、配置订货号和芯片映射 |
| Atlas 800T A2、Atlas 800I A2 | 系统对象 | 当前正式产品组合 | 主样本；训练服务器和推理服务器分卡 | H-1、H-5 | 首次供货、具体 NPU 型号、系统修订版 |
| Atlas 900 A2 PoD | 系统对象 | 当前正式产品组合 | 主样本候选 | H-1、H-3 | 产品状态、规模配置与 A3 的继承关系 |
| Atlas 800T A3、Atlas 800I A3（另见“Atlas 800 A3”） | 系统对象 | 当前正式产品组合 | 主样本；T/I 分卡；“Atlas 800 A3”是否总称需独立核对 | H-1、H-5 | A3 命名映射、NPU 数量、910C 组件映射和首供日期 |
| Atlas 900 A3 SuperPoD；CloudMatrix384 | 系统；云服务实例 | 2025 正式发布，最多 384 个 Ascend 910C，已有规模部署；CloudMatrix384 是其上的云服务实例 | 主样本；SuperPoD 与云实例分卡/映射 | H-2、H-3 | 384/其他配置、云服务正式名称和首次开放日期 |
| Ascend 950PR；Atlas 350 | 芯片/封装；产品 SKU | Atlas 350 搭载 950PR，于 2026-03-20 官方宣布正式上市 | 主样本；芯片卡与 PCIe 卡分开 | H-6、H-7、H-12 | Ascend 950PR 的芯片级数据与 Atlas 350 卡级数据边界；正式白皮书版本 |
| Atlas 150 | 产品 SKU | 2026 当前官方产品导航出现正式产品名 | 主样本候选，先建身份占位 | H-6 | 搭载芯片、发布时间、规格页内容与供货状态 |
| Ascend 950DT | 芯片/封装 | 2025 路线图称 2026 年第四季度可用；2026 当前官网已有产品入口 | 观察项（产品化前期），不因页面存在就提前判定 GA | H-2、H-6 | 正式上市/交付证据、最终封装内存配置 |
| Atlas 650E | 系统对象 | 当前官方页面给出 8×Ascend 950DT 系统规格 | 观察项（接近完整卡）；等待明确上市/交付 | H-5 | 正式上市日期、配置订货号和供货区域 |
| Atlas 850（2025 公布）、Atlas 850E（2026 当前产品名）、Atlas 860 | 系统对象 | 850/860 已正式公布；当前官网列 850E | 观察项；850、850E、860 不预设为同一修订版 | H-8、H-3 | 型号继承/改名关系、所用 NPU、上市与交付状态 |
| Atlas 950 SuperPoD：64/1024-NPU 产品配置 | 系统对象 | 2026 当前官网给出 64 或 1024 卡配置及完整规格，实物已公开展示 | 观察项（生产爬坡/状态待核）；1024 配置单独系统卡 | H-3、H-11 | 明确上市/客户交付证据、64 与 1024 的订货边界 |
| Atlas 950 SuperPoD：8192-NPU 全配置 | 未来系统配置 | 2025 路线图称 2026 年第四季度可用 | 观察项；与当前 1024-NPU 产品配置分开 | H-2、H-8 | 8192 是否同一订货产品、最终机柜数、交付日 |
| Ascend 960、Ascend 970、Atlas 960 SuperPoD | 未来芯片/系统 | 官方路线图：960/Atlas 960 计划 2027 年第四季度，970 计划 2028 年第四季度 | 观察项；只保留路线图事实 | H-2 | 最终 SKU、规格和发布日期 |

中国站、全球站或昇腾社区页面的可见性不同，不等于存在不同硅片版本。只有正式型号、设备标识或明确规格差异出现时，才建立地区变体。

## 8. AMD Instinct

AMD 应按 CDNA 架构、OAM/PCIe 产品和 8-GPU/机架参考系统拆分。MI300A 是 CPU+GPU APU（Accelerated Processing Unit，加速处理器），不能与 MI300X OAM 归并。区域型号 MI308X 由 AMD 官方运维和 ROCm 文档确认，但需要继续找固定产品页。

| 候选对象 | 层级 | 时间或现状（暂定） | 暂定处理与拆卡建议 | 核对入口 | 主要缺口 |
|---|---|---|---|---|---|
| CDNA 2；MI250X OAM | 架构；产品 SKU | 2021 发布，仍是 CDNA 3 的必要锚点 | 历史锚点 | D-1、D-2 | 固定版产品简报和首供日期 |
| MI210 PCIe | 产品 SKU | 2022 正式产品 | 主样本；保留 CDNA 2 的 PCIe 形态 | D-1、D-3 | 首次供货日期、当前生命周期状态 |
| CDNA 3；MI300A APU、MI300X OAM | 架构；产品 SKU | 2023-12-06 正式发布/供货 | 主样本；A 与 X 分卡 | D-3、D-4 | MI300X 各功耗模式、MI300A 系统内存/统一内存口径 |
| MI300X Platform（8 OAM） | 系统/平台 | AMD 正式平台对象 | 主系统对象；系统值不回填单 OAM | D-3 | 平台是参考设计还是可订购对象、版本与互联拓扑 |
| MI308X OAM | 产品 SKU；地区/出口变体 | AMD Instinct 运维、GPU Operator 和安全公告确认正式设备身份 | 主样本候选；与 MI300X 分卡 | D-5、D-6 | 产品页、首发地区/日期、内存和互联的固定版规格 |
| MI325X OAM；MI325X Platform | 产品 SKU；系统/平台 | 2024 正式推出，当前软件支持 | 主样本；OAM 与 8-GPU 平台分卡 | D-1、D-5 | 首次供货日期和平台订货边界 |
| CDNA 4；MI350X、MI355X OAM | 架构；产品 SKU | 2025 正式产品，当前产品页 | 主样本；X 与 355X 分卡 | D-7、D-8 | 空冷/液冷、功耗和平台配置的准确差异 |
| MI350P PCIe | 产品 SKU | 当前 MI350 系列产品页列出企业 PCIe 卡 | 主样本候选；与 OAM 产品分卡 | D-7 | 首次正式发布/供货日期、规格数据库条目与订货号 |
| MI350 Series Platform（8 OAM） | 系统/平台 | 当前正式平台对象 | 主系统对象 | D-7 | MI350X 与 MI355X 平台版本、系统是否可独立订购 |
| CDNA 5；MI455X | 架构；产品 SKU | 2026-07-23 进入 AMD 官方规格库，当前产品页给出完整规格；合作伙伴量产部署预期 2026 年下半年 | 主样本（生产爬坡），醒目标注截止日 | D-9、D-10 | 截止日客户交付、最终功耗和 EAM（Enhanced Accelerator Module）订货边界 |
| MI440X | 产品 SKU | 2026-01-05 官方公布，面向 8-GPU 企业系统；当前 MI400 页面未给独立规格段 | 观察项 | D-9、D-11 | 正式规格页、供货日期、平台名称和与 MI430X 的关系 |
| MI430X | 产品 SKU | 当前产品页称预计 2027 可用 | 观察项 | D-9、D-10 | 最终规格、订货形态和交付日期 |
| AMD Helios（72×MI455X） | 机架参考设计 | AMD 明确说明是参考设计，不是直接销售产品；伙伴系统预计 2026 年下半年量产部署 | 观察项/系统参考卡，不列作可购 AMD SKU | D-9 | 首批 OEM/ODM 正式系统名和实际交付 |
| MI500 Series / CDNA 6 | 未来架构/系列 | 2026 官方预告，计划 2027 | 观察项；没有正式 SKU 前不拆型号 | D-11 | 正式产品名、规格与上市日期 |
| MI300X-HF、MI308X-HF | 软件设备别名/变体待定 | AMD GPU Operator 测试矩阵出现 | 排除项/线索；不能仅凭软件标签建市场 SKU 卡 | D-6 | 正式市场名、硬件差异和产品页 |

## 9. 跨厂商范围决策

本轮最重要的边界有四个。第一，云实例和机架不是“更多芯片型号”，但它们是解释互联、主机映射和聚合带宽不可缺的系统对象。第二，当前产品页出现不等于已经普遍供货；Trn2 UltraServer、Ascend 950DT/Atlas 950、Rubin 和部分 MI400 型号需保留状态证据。第三，地区/出口变体必须独立记录：NVIDIA A800/H800/H20/L20/L2/H20BFX/RTX PRO 6000D 与 AMD MI308X 均不能套用原版型号数据。第四，软件支持矩阵只能确认身份和兼容范围；寒武纪 MLU500 系列、AMD `-HF` 标签等仍需产品资料确定真实 SKU 边界。

建议主索引使用稳定的工作标识，例如 `nvidia-h100-sxm5-80gb`、`aws-ec2-trn2-48xlarge`、`huawei-atlas950-superpod-1024`；厂商显示名原样保存。产品、架构和系统之间只通过外键关联，不在名称字段里拼接推断关系。

## 10. 官方核对入口

以下均为厂商一手资料，访问日期统一为 2026-08-12。它们用于确认候选身份和暂定状态；进入最小参考资料库前，仍要按事实覆盖和版本稳定性筛选。

### NVIDIA

- NV-1：[NVIDIA Data Center GPU Line Card](https://docs.nvidia.com/data-center-gpu/line-card.pdf)
- NV-2：[NVIDIA GPU Operator Platform Support](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/24.9/platform-support.html)
- NV-3：[NVIDIA Data Center GPU Driver Release Notes 595 v2.0](https://docs.nvidia.com/datacenter/tesla/pdf/NVIDIA_Data_Center_GPU_Driver_Release_Notes_595_v2.0.pdf)
- NV-4：[NVIDIA H100 / H200 Tensor Core GPUs](https://www.nvidia.com/en-us/data-center/h100/)
- NV-5：[NVIDIA L40S](https://www.nvidia.com/en-us/data-center/l40s/)
- NV-6：[NVIDIA Blackwell](https://www.nvidia.com/en-us/data-center/blackwell/)
- NV-7：[NVIDIA GB300 NVL72](https://www.nvidia.com/en-gb/data-center/gb300-nvl72/)
- NV-8：[NVIDIA Vera Rubin NVL72](https://www.nvidia.com/en-us/data-center/vera-rubin-nvl72/)
- NV-9：[NVIDIA Rubin platform production announcement](https://investor.nvidia.com/news/press-release-details/2026/NVIDIA-Kicks-Off-the-Next-Generation-of-AI-With-Rubin--Six-New-Chips-One-Incredible-AI-Supercomputer/default.aspx)

### Google Cloud

- G-1：[Cloud TPU system architecture](https://docs.cloud.google.com/tpu/docs/system-architecture-tpu-vm)
- G-2：[TPU v4](https://docs.cloud.google.com/tpu/docs/v4)
- G-3：[TPU v5e](https://docs.cloud.google.com/tpu/docs/v5e)
- G-4：[TPU v5p](https://docs.cloud.google.com/tpu/docs/v5p)
- G-5：[TPU v6e](https://docs.cloud.google.com/tpu/docs/v6e)
- G-6：[Trillium TPU generally available](https://cloud.google.com/blog/products/compute/trillium-tpu-is-ga)
- G-7：[TPU7x / Ironwood](https://docs.cloud.google.com/tpu/docs/tpu7x)
- G-8：[TPU 8t and TPU 8i architecture deep dive](https://cloud.google.com/blog/products/compute/tpu-8t-and-tpu-8i-technical-deep-dive)
- G-9：[Google Cloud AI infrastructure at Next '26](https://cloud.google.com/blog/products/compute/ai-infrastructure-at-next26)

### AWS

- A-1：[AWS Neuron architecture documentation](https://awsdocs-neuron.readthedocs-hosted.com/en/latest/about-neuron/arch/)
- A-2：[Amazon EC2 Trn1 instances](https://aws.amazon.com/ec2/instance-types/trn1/)
- A-3：[Trainium-powered EC2 Trn1 launch](https://aws.amazon.com/blogs/aws/amazon-ec2-trn1-instances-for-high-performance-model-training-are-now-available/)
- A-4：[EC2 Trn1n general availability](https://aws.amazon.com/about-aws/whats-new/2023/04/amazon-ec2-trn1n-instances-network-ai-models/)
- A-5：[Amazon EC2 Inf2 instances](https://aws.amazon.com/ec2/instance-types/inf2/)
- A-6：[EC2 Inf2 general availability](https://aws.amazon.com/blogs/aws/amazon-ec2-inf2-instances-for-low-cost-high-performance-generative-ai-inference-are-now-generally-available/)
- A-7：[Amazon EC2 Trn2 instances and UltraServers](https://aws.amazon.com/ec2/instance-types/trn2/)
- A-8：[EC2 Trn2 general availability / UltraServer preview](https://aws.amazon.com/about-aws/whats-new/2024/12/amazon-ec2-trn2-instances-available/)
- A-9：[Amazon EC2 Trn3 UltraServers](https://aws.amazon.com/ec2/instance-types/trn3/)
- A-10：[EC2 Trn3 UltraServers general availability](https://aws.amazon.com/about-aws/whats-new/2025/12/amazon-ec2-trn3-ultraservers/)
- A-11：[Amazon on Trainium3 and Trainium4](https://www.aboutamazon.com/news/aws/trainium-3-ultraserver-faster-ai-training-lower-cost)
- A-12：[AWS AI Factories and Trainium4 NVLink Fusion](https://www.aboutamazon.com/news/aws/aws-data-centers-ai-factories)

### Groq / NVIDIA Groq

- Q-1：[Groq papers and product spec sheets](https://groq.com/papers)
- Q-2：[GroqChip Processor product brief](https://groq.com/wp-content/uploads/2024/08/GroqChip%E2%84%A2-Processor-Product-Brief-v1.7.pdf)
- Q-3：[Groq LPU architecture explanation](https://groq.com/blog/the-groq-lpu-explained)
- Q-4：[GroqCard Accelerator product brief](https://www.groq.com/wp-content/uploads/2022/10/GroqCard%E2%84%A2-Accelerator-Product-Brief-v1.5-.pdf)
- Q-5：[GroqNode Server product brief](https://groq.com/wp-content/uploads/2024/08/GroqNode%E2%84%A2-Server-Product-Brief-v1.7.pdf)
- Q-6：[GroqRack Compute Cluster product brief](https://groq.com/wp-content/uploads/2024/08/GroqRack%E2%84%A2-Compute-Cluster-Product-Brief-v1.7.pdf)
- Q-7：[GroqCloud production-use announcement](https://groq.com/newsroom/demand-for-real-time-ai-inference-from-groq-accelerates-week-over-week)
- Q-8：[NVIDIA Groq 3 LPX](https://www.nvidia.com/en-gb/data-center/lpx/)
- Q-9：[Inside NVIDIA Groq 3 LPX](https://developer.nvidia.com/blog/inside-nvidia-groq-3-lpx-the-low-latency-inference-accelerator-for-the-nvidia-vera-rubin-platform)

### 寒武纪

- C-1：[CNToolkit 3.8.4 组件与产品矩阵](https://sdk.cambricon.com/static/independent/CNToolkit/3.8.4/releasenote/3.8.4/build/html/chapter_components/index.html)
- C-2：[寒武纪 MLU370 产品页](https://www.cambricon.com/index.php?a=lists&c=index&catid=360&m=content)
- C-3：[MLU370-X8 发布资料](https://www.cambricon.com/index.php?a=show&c=index&catid=127&id=48&m=content)
- C-4：[CNNL 1.23.2 版本说明与硬件支持](https://sdk.cambricon.com/static/independent/CNNL/1.23.2/releasenote/1.23.2/build/html/cnnl.html)

### 华为昇腾

- H-1：[华为企业业务昇腾计算产品目录](https://e.huawei.com/cn/products/computing/ascend)
- H-2：[Huawei Connect 2025 Ascend roadmap and SuperPoD keynote](https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech)
- H-3：[昇腾超节点产品页](https://www.hiascend.com/hardware/cluster)
- H-4：[Atlas 300I A2 产品页](https://e.huawei.com/cn/products/computing/ascend/atlas-300i-a2)
- H-5：[昇腾 AI 服务器产品页](https://www.hiascend.com/hardware/ai-server)
- H-6：[昇腾 NPU 处理器产品页](https://www.hiascend.com/hardware/processor)
- H-7：[Atlas 加速卡产品页](https://www.hiascend.com/hardware/accelerator-card)
- H-8：[华为 2025 超节点与 Atlas 新品发布](https://www.huawei.com/cn/news/2025/9/hc-superpod-innovation)
- H-11：[昇腾 950 超节点实机亮相](https://www.huawei.com/cn/news/2026/7/atlas-950-superpod)
- H-12：[Atlas 350 正式上市](https://www.hiascend.com/activities/dynamic-news/20260320-3)

### AMD

- D-1：[AMD accelerator specifications database](https://www.amd.com/en/products/specifications/accelerators.html)
- D-2：[AMD Instinct GPU family brochure](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/product-briefs/amd-instinct-gpu-family-brochure.pdf)
- D-3：[AMD Instinct MI300 Series](https://www.amd.com/en/products/accelerators/instinct/mi300.html)
- D-4：[AMD MI300 portfolio launch, 2023-12-06](https://www.amd.com/en/newsroom/press-releases/2023-12-6-amd-delivers-leadership-portfolio-of-data-center-a.html)
- D-5：[AMD Instinct Customer Acceptance Guide](https://instinct.docs.amd.com/projects/system-acceptance/en/latest/common/health-checks.html)
- D-6：[AMD GPU Operator supported test recipes](https://instinct.docs.amd.com/projects/gpu-operator/en/main/test/appendix-test-recipe.html)
- D-7：[AMD Instinct MI350 Series](https://www.amd.com/en/products/accelerators/instinct/mi350.html)
- D-8：[AMD Instinct roadmap expansion, 2024](https://www.amd.com/en/newsroom/press-releases/2024-6-2-amd-accelerates-pace-of-data-center-ai-innovation-.html)
- D-9：[AMD Instinct MI400 Series and Helios](https://www.amd.com/en/products/accelerators/instinct/mi400.html)
- D-10：[AMD CDNA architecture](https://www.amd.com/en/technologies/cdna.html)
- D-11：[AMD CES 2026 MI400 portfolio announcement](https://www.amd.com/en/newsroom/press-releases/2026-1-5-amd-and-its-partners-share-their-vision-for-ai-ev.html)

## 任务状态

已完成阶段 0/2 的七厂商候选型号普查草案，状态为“待总控复核并写入共享型号索引”。本文件没有改动共享 CSV、README、AGENTS.md 或研究计划。

## 输入

输入包括 `研究计划.md`，根目录 `清单/` 中的历史汇总，两个相邻历史调研目录中的型号选择与厂商资料（只读），以及上节列出的厂商一手网页和固定版文档。没有使用 `literature-survey`。

## 已完成

已区分主样本、观察项、历史锚点和排除项，并按架构代际、裸片/封装、产品 SKU/云配置和系统对象拆分候选。已补入旧调研遗漏或状态发生变化的对象，包括 `trn2.3xlarge`、`trn2u.48xlarge`、Trainium3、TPU 8t/8i、Ascend 950PR/950DT、Atlas 350/650E/850E/950、AMD MI350P/MI440X/MI455X，以及 NVIDIA Groq 3 LPX。已明确 A800 同名碰撞、Atlas 950 的 1024/8192 配置、Helios 参考设计和寒武纪软件支持证据的边界。

## 验证

已对所有厂商至少用一个官方产品目录或架构/支持矩阵复核，并对 2025 至 2026 年的 Trainium3、TPU 8t/8i、Rubin、Ascend 950 和 MI400 状态使用原始发布资料交叉核对。文件按 UTF-8 写入；来源键、链接、表格列数、替换字符和 Markdown 公式分隔符已做机器检查。`report-humanizer` 扫描未发现机器可识别的 AI 写作痕迹，并按 `shuorenhua` 要求做了人工复核。

## 未解决

最高优先级缺口是 NVIDIA 地区/出口变体的正式 SKU 与首供日期、Trn2 UltraServer 动态页面的 GA/preview 自相矛盾、寒武纪 MLU570/580/590 的固定版产品资料与首供日期、Ascend 950DT/Atlas 650E/850E/950 截止日的明确上市或客户交付证据，以及 AMD MI308X/MI350P/MI440X 的稳定产品页。Groq 3 LPX、Rubin 和 MI455X 已到生产或量产部署窗口，但截止日实际交付边界仍需总控统一判定。

## 建议下一步

总控先把本表转换为 `products.csv` 和型号索引的候选行，为每个对象分配稳定 ID；然后优先核对上述状态缺口，再冻结试填范围。Google TPU 的拓扑、AWS 的实例、NVIDIA/AMD 的 8-GPU 平台以及华为 SuperPoD 应分别建立配置或系统子表，避免在产品卡中重复架构事实。

## 写入文件

`审计/子代理交接/model_inventory.md`