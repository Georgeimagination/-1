# M2 华为昇腾与寒武纪前置身份核对

> 核对日期：2026-08-12  
> 状态：`ready_for_root_review`  
> 范围：只处理指定对象的身份、类型、范围和关系，不采集规格。

## 本次给总控的裁决

这份交接只回答四组边界问题：寒武纪的软件架构标识与板卡名，CloudMatrix384 的对象类型，Atlas 800 A3 与 850 系列的命名层级，以及 Atlas 950 与 Ascend 950 的对象拆分。证据截止日为 2026-08-12。

### 寒武纪：三个架构标识不能合并

`MLUarch05`、Cambricon BANG v5.0 和 `__BANG_ARCH__=592` 处在不同语义层，当前证据不能把它们建成同一个架构对象。

寒武纪 2022 年 WAIC 官网正文写明“思元590采用MLUarch05全新架构”。因此，思元590与 `MLUarch05` 的 `implements_architecture` 关系已经有可读取的一手证据。固定到提交 `67b3707f9ce55718490534955903a007ae86f517` 的 MLU-OPS 构建脚本则确认：构建目标 `--mlu590` 会设置 `__BANG_ARCH__=592`。后者只是构建期宏，不能改写成物理架构名。

CNToolkit 3.8.4 的官方搜索索引显示另一套软件可见映射：BANG v5.0、`compute_50`、`mtp_592`、MLU570 和 MLU590 出现在同组表格中。不过，原始入口在 2026-08-12 直接访问返回 HTTP 401；更早一次远端抓取还返回 400 timeout。搜索索引只能当入口线索，不能作为正式关系证据。BANG v5.0 与 `MLUarch05` 的等价关系、BANG v5.0 与 `__BANG_ARCH__=592` 的等价关系、`MLUarch05` 与该宏的等价关系，结论均为“尚未证明”。

对象处理建议是：继续使用正式 `MLUarch05` 架构对象；BANG v5.0 另留 `architecture_generation` 候选，并标记 `needs_resolution`；`compute_50`、`mtp_592` 和 `__BANG_ARCH__=592` 进入软件目标或编译标识记录，不另建物理架构对象。

### 寒武纪：芯片层与板卡层分开保留

CNToolkit 3.8.4 的官方搜索索引分别展示 Chip Level 和 Board Level。索引中，MLU570 同时出现在两个层级；MLU590-H8、MLU590-M9 和 MLU370-M8 出现在 Board Level。这个结果支持现有拆分方向，但原始正文不可读，四个板卡身份都不能转为 `reviewed`。

| 候选 | 建议对象类型 | 范围建议 | 关系与裁决 | 复核状态 |
|---|---|---|---|---|
| `CAND-CAMBRICON-ARCH-BANG-V5` | `architecture_generation` | `observation` | 与正式 `MLUarch05` 分开；不写等价关系 | `needs_resolution` |
| `CAND-CAMBRICON-MLU570-PACKAGE` | `package` | `main_sample` 候选 | 与同名板卡分开；暂不写 `card_uses_module` | `needs_resolution` |
| `CAND-CAMBRICON-MLU570-CARD` | `card` | `main_sample` 候选 | 同名不构成芯片或封装关系证据 | `needs_resolution` |
| `CAND-CAMBRICON-MLU590-PACKAGE` | `package` | `main_sample` | 映射到既有 MLU590 芯片对象；“思元590 = MLU590”仍待同页证据 | `needs_resolution` |
| `CAND-CAMBRICON-MLU590-H8` | `card` | `main_sample` 候选 | 保留既有占位对象；不从名称推断所含芯片数量 | `needs_resolution` |
| `CAND-CAMBRICON-MLU590-M9` | `card` | `main_sample` 候选 | 保留既有占位对象；不从名称推断所含芯片数量 | `needs_resolution` |
| `CAND-CAMBRICON-MLU370-M8` | `card` | `main_sample` 候选 | 与 MLU370 封装候选分开；不套用 X8 身份 | `needs_resolution` |

解除这些待核状态需要可读取的版本化 CNToolkit 正文、固定原厂手册或产品页。证据必须同时写出芯片层和板卡层，或明确给出板卡所用芯片；搜索摘要、论坛设备日志和既有占位对象均不够。

### CloudMatrix384：硬件是超节点，云服务另建对象

华为云 2025-04-10 的官方发布把 CloudMatrix384 称为“超节点”，并称其已在芜湖数据中心规模上线。后续官方材料使用的是“基于 CloudMatrix384 的 AI 云服务”与“CloudMatrix384 AI Token 推理服务”。这说明 CloudMatrix384 本身是底层硬件系统，云服务是建立在该系统上的另一层产品。

`CAND-HUAWEI-CLOUDMATRIX384` 建议改名为 `Huawei CloudMatrix384 supernode`，对象层级为 `system`，`object_type=pod`，范围保留 `main_sample`。它不应继续作为 `cloud_accelerator` 或 `cloud_instance`。若项目要记录客户获得的云服务，应另建 `cloud_accelerator` 对象，例如 `AI Computing Service on CloudMatrix`，再由该云服务指向 CloudMatrix384；不要把服务开放状态写到硬件对象上。

硬件身份可以转为 `reviewed`。云服务的正式服务对象仍需稳定产品标识、购买或计费文档，才能从公告名升级为正式对象。

### Atlas 800 A3：不是 800T/800I 的总称

华为当前昇腾产品导航把“Atlas 800 A3 风冷超节点”列为独立超节点入口。官方产品形态文档同时把 Atlas 800T A3 与 Atlas 800I A3 列为两个独立的超节点服务器。现有证据不支持把 Atlas 800 A3 当作这两款服务器的总称，也没有证明 Atlas 800 A3 是 800T A3 的改名。

| 候选 | 建议对象类型 | 范围建议 | 关系与裁决 | 复核状态 |
|---|---|---|---|---|
| `CAND-HUAWEI-ATLAS-800-A3-UMBRELLA` | `pod` | 由 `excluded_lead` 改为 `main_sample` 候选 | 更名为 Atlas 800 A3 风冷超节点；不是总称 | `needs_resolution` |
| `CAND-HUAWEI-ATLAS-800T-A3` | `server` | `main_sample` | 继续独立保存 | `reviewed`（身份） |
| `CAND-HUAWEI-ATLAS-800I-A3` | `server` | `main_sample` | 继续独立保存 | `reviewed`（身份） |

三者暂不建立 `renamed_from`、`supersedes_product`、`sku_variant_of` 或包含关系。Atlas 800 A3 只有在固定原厂手册或订货文档明确给出构成、型号映射或与 800T/800I 的关系后，才能解除 `needs_resolution`。

### Atlas 850、850E、860：三个型号分别建对象

2025-09-18 的华为官方发布分别推出 Atlas 850 和 Atlas 860，并称两者为企业级风冷 AI 超节点服务器。2026 年当前昇腾导航展示 Atlas 850E；CANN 9.0.X 官方文档还分别列出 Atlas 850 超节点、Atlas 850E 超节点、Atlas 850 标准服务器和 Atlas 850E 标准服务器。没有官方材料说明 850E 是 850 的改名或后继型号。

| 候选 | 建议对象类型 | 范围与截止日状态 | 关系与裁决 | 复核状态 |
|---|---|---|---|---|
| `CAND-HUAWEI-ATLAS-850` | `server` | `observation`；2025-09-18 `announced` | 与 850E、860 分开 | `needs_resolution` |
| `CAND-HUAWEI-ATLAS-850E` | `server` | `observation`；2026 当前产品名，供货状态待核 | 与 850、860 分开 | `needs_resolution` |
| `CAND-HUAWEI-ATLAS-860` | `server` | `observation`；2025-09-18 `announced` | 与 850、850E 分开 | `needs_resolution` |

850 和 850E 后续还要区分“超节点”与“标准服务器”配置。若固定手册给出共同订货主体和配置关系，可在一个产品对象下建变体；否则继续分对象。三者之间只有在原厂变更公告、订货映射或生命周期文档明确写出关系后，才允许使用 `renamed_from` 或 `supersedes_product`。

### Atlas 950：一个 SuperPoD 对象，三种条件化配置

华为当前产品页把 64 卡和 1024 卡写成同一 Atlas 950 SuperPoD 的多种配置。2025 路线图与 2026 MWC 官方发布又把 8192 NPU 写成该产品的完整或最大扩展配置。三种数字描述的是同一个 `pod` 对象在不同规模与时间条件下的配置，不需要建立三个产品对象。

| 候选 | 建议处理 | 截止日状态 |
|---|---|---|
| `CAND-HUAWEI-ATLAS-950-SUPERPOD-64` | 合并到一个 `Atlas 950 SuperPoD`；64 作为配置 | 当前产品页列出的配置；不单独判定供货 |
| `CAND-HUAWEI-ATLAS-950-SUPERPOD-1024` | 合并到同一对象；1024 作为配置 | 2026-07-17 真机公开展示；仍不足以证明 GA |
| `CAND-HUAWEI-ATLAS-950-SUPERPOD-8192` | 合并到同一对象；8192 作为未来完整配置 | 计划 2026 年第四季度可用，截止日仍为 `announced` |

合并后的对象建议 `object_type=pod`、范围 `observation`、状态 `announced`。1024 卡真机展示不能替代正式上市、订货或客户交付证据。取得对象匹配的 GA 公告、订单入口或客户部署证明后，再重判 `available` 或 `production_ramp`。

### Ascend 950PR 与 950DT：两个封装，共享一个裸片候选

华为 2025 路线图说明，厂商把两种内存分别与 Ascend 950 Die 封装，从而形成 Ascend 950PR 和 Ascend 950DT；当前处理器导航也把二者列成两个入口。两者应保留为两个 `package` 对象，不能用“Ascend 950”泛称合并。

| 候选 | 建议对象类型 | 范围与截止日状态 | 关系与裁决 | 复核状态 |
|---|---|---|---|---|
| `CAND-HUAWEI-ASCEND-950PR` | `package` | `main_sample`；随 Atlas 350 进入正式上市产品 | 新增共享 Ascend 950 `die` 候选，并写 `package_contains_die` | `reviewed`（身份层级） |
| `CAND-HUAWEI-ASCEND-950DT` | `package` | `observation`；当前有产品入口，正式供货待核 | 指向同一 Ascend 950 `die` 候选 | `reviewed`（身份层级），状态待核 |

产品页存在只能确认当前展示身份。950DT 的 `available` 仍需对象匹配的正式上市、订货或客户部署证据；系统页面列出该处理器不能单独代替产品状态证据。

## 官方入口与访问结果

| 官方入口 | 访问结果 | 支持的身份判断 |
|---|---|---|
| https://www.cambricon.com/index.php?a=show&c=index&catid=127&id=51&m=content | 可访问；项目已有 2026-08-12 快照 | 思元590、MLUarch05、二者关系 |
| https://sdk.cambricon.com/static/independent/CNToolkit/3.8.4/releasenote/3.8.4/build/html/chapter_components/index.html | 2026-08-12 直接访问 HTTP 401；早先抓取为 400 timeout；搜索索引可见正文片段 | 只作 BANG v5.0、MLU570、H8/M9、M8 的不可访问线索 |
| https://github.com/Cambricon/mlu-ops/blob/67b3707f9ce55718490534955903a007ae86f517/independent_build.sh#L123-L126 | 可访问；固定提交 | `--mlu590` 与 `__BANG_ARCH__=592` 的软件构建关系 |
| https://www.huaweicloud.com/intl/zh-cn/news/20250424094932570.html | 可访问 | CloudMatrix384 超节点身份与硬件部署 |
| https://support.huaweicloud.com/intl/en-us/wtsnew-modelarts/index.html | 可访问 | `AI Computing Service on CloudMatrix` 是云服务名 |
| https://www.huaweicloud.com/news/2025/20250919104714436.html | 可访问 | 基于 CloudMatrix384 的 AI 云服务与 Token 服务上线 |
| https://www.hiascend.com/hardware/cluster | 可访问；动态页面 | Atlas 800 A3、850E、950 的当前产品入口 |
| https://www.hiascend.com/document/detail/zh/AscendFAQ/ProduTech/productform/hardwaredesc_0001.html | 可访问 | Atlas 800T A3 与 Atlas 800I A3 的独立产品形态 |
| https://www.huawei.com/cn/news/2025/9/hc-superpod-innovation | 可访问 | Atlas 850、Atlas 860、Atlas 350 的发布身份 |
| https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/900/softwareinst/instg/instg_0101.html | 可访问 | Atlas 850/850E 的超节点与标准服务器名称 |
| https://www.huawei.com/cn/news/2026/3/mwc-superpod-ai | 可访问 | Atlas 850E 与 Atlas 950 的 2026 产品身份；8192 NPU 最大扩展 |
| https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech | 可访问 | Ascend 950PR/DT 的封装层级、共享 Die 与 Atlas 950 完整配置计划 |
| https://www.hiascend.com/hardware/processor | 可访问；动态页面 | Ascend 950PR 与 950DT 是两个当前处理器入口 |
| https://www.huawei.com/cn/news/2026/7/atlas-950-superpod | 可访问 | Atlas 950 的 1024 卡真机展示；不证明 GA |

CNToolkit 的失败是远端 HTTP 访问限制，不是沙箱、审批或模型能力问题。本轮没有用搜索摘要生成正式身份事实。

## 总控合并时需要做的修改

总控若接受上述裁决，需要在候选表中完成四项变更：CloudMatrix384 改为 `pod` 并另建云服务候选；Atlas 800 A3 从“总称排除项”改为独立 `pod` 候选；Atlas 950 的三行合并为一个对象和三条配置；Ascend 950PR/DT 新增共享 Ascend 950 `die` 候选。寒武纪候选继续保留待核，不把不可访问正文或编译宏升级为物理架构关系。

本代理按任务边界没有修改正式 CSV、资料卡、进度、README、AGENTS 或研究计划。README 与 AGENTS 已检查：本次只新增前置身份裁决，没有改变已经记录的阶段、目录、运行方式或全局统计，因此无需由本代理更新；总控接受并合并候选后再同步项目记忆。