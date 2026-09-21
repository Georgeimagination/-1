# M2 第二波排队建议独立红队复核

- 状态：`ready_for_parent_review`
- 复核日期：2026-08-13
- 写入边界：仅本文件
- 复核对象：`M2-W2-AWS-PACKAGE`、`M2-W2-G-CONFIG`、`M2-W2-AMD-HELIOS-SYSTEM`，以及 Trainium2 三实例轻量包

## 先给裁决

| 工作包 | 裁决 | 能否按原建议立即启动 | 关键原因 |
|---|---|---:|---|
| AWS package | `accept_with_fixes` | 否；先完成来源冻结与对象身份门 | `package` 层级与既有 Trainium2 建模一致，backlog 归属和 `implements_architecture` 关系可用；但动态网页尚未固定，来源预算与候选来源数量尚未对齐。 |
| Google config | `reject` | 否 | 建议把“配置族”对象统一建成 `cloud_accelerator`，会把云端配置容器与单设备事实混在同一对象；五个待建 ID 也尚未经过正式范围映射。应先单独裁定对象模型，再重写工作包。 |
| AMD Helios system | `accept_with_fixes` | 否；先固定产品页并补足 72 模组证据 | 正式 `rack` 对象及关系已经存在，且无架构 backlog 需要迁移；但机架总量不能在 MI455X 模组事实尚空时靠乘算补齐。 |
| Trainium2 三实例 | `accept_with_fixes` | 可作为轻量先行子包 | 三个 `cloud_instance` 对象已经存在，事实、来源和缺口边界清楚；它不能替代 Google 配置包，只能在 Google 对象模型修正期间暂时占用执行槽位。 |

当前可执行的三包组合应为：AWS package、AMD Helios system、Trainium2 三实例轻量包。Google config 不从 M2 范围删除，而是先退回“对象模型与来源冻结”准备门，修正后再排入下一执行槽。

> 独立性说明：本复核人上一轮起草过 `m2_wave2_sku_readiness.md`，因此对 Trainium2 三实例的判断属于基于正式表的红队复查，不构成对该建议的独立验收。若总控要把该轻量包直接合并，应另派未参与起草者验收。AWS、Google 与 Helios 三项并非本复核人起草。

## AWS package：`accept_with_fixes`

建议边界包含五张封装卡：新建 `OBJ-AWS-INFERENTIA1-CHIP`、`OBJ-AWS-TRAINIUM1-CHIP`、`OBJ-AWS-INFERENTIA2-CHIP`、`OBJ-AWS-TRAINIUM3-CHIP`，复用现有 `OBJ-AWS-TRAINIUM2-CHIP`。对象类型用 `package` 可以接受：这与 Trainium2 已验收对象一致，也符合四组实现待办的 `silicon_package` 目标；ID 中的 `CHIP` 只是命名，不能再被解释成已证明裸片数量或封装结构。

四条待建关系使用现有枚举 `implements_architecture` 足够，分别指向 Inferentia、Trainium、Inferentia2 与 Trainium3 架构对象；Trainium2 的关系已经存在，不应重复创建。实现待办共 24 行，其中 23 行属于四个新封装对象，`DEF-M2GA-ATRN2-01` 只复用既有 Trainium2 事实链，不迁移或复制架构共性。

原建议的事实量级约 60 至 70 条可以作为规划区间，不能作为验收硬上限。原因是 23 行待办中有多项复合精度、内存与互联声明，原子化后可能超过估算。更直接的启动阻断是 AWS 官方页面尚未全部形成固定快照；来源版本上限和 endpoint（访问入口）预算也没有与待固定页面数完全对齐。

启动前必须完成三项修正：先逐对象用一手身份页证明它确实是单个封装边界，并以非 `reviewed` 状态预留待建对象；再固定本包采用的动态 AWS 页面并登记哈希、获取日期和本地入口；最后重算实际来源、原子事实与完整性预算。完成这些修正后，本包可启动。

## Google config：`reject`

该建议把 `OBJ-GOOGLE-TPU-V4-SLICE-FAMILY`、`OBJ-GOOGLE-TPU-V5LITEPOD-CONFIG-FAMILY`、`OBJ-GOOGLE-TPU-V5P-SLICE-FAMILY`、`OBJ-GOOGLE-TPU-V6E-CONFIG-FAMILY`、`OBJ-GOOGLE-TPU7X-SLICE-FAMILY` 统一设计为 `cloud_accelerator`，同时复用现有 `OBJ-GOOGLE-CT6E-STANDARD-FAMILY`（`cloud_instance`）。这个边界不能直接执行。

问题不在于缺少一个关系枚举，而在于对象本身混层：Slice 或配置族是云端可选配置的容器；待办中的部分 HBM、峰值与芯片数量却是单个云端设备或物理实现事实。把两者写到同一个 `cloud_accelerator` 对象，会把实例/配置聚合值和设备定值混为一谈。五个待建 ID 也未出现在正式 M2 对象范围映射中，不能只凭排队建议直接进入对象表。`GV5P-03` 已明确要求把云可见 95 GiB 与未来物理封装的 96 GiB 分开，反而说明当前统一配置族模型不成立。

对应十行实现待办（`GV5E-01` 至 `GV5E-04`、`GV5P-03`、`GV5P-06`、`GV6E-01` 至 `GV6E-04`）可以继续作为检索与边界线索，但不能在对象裁定前迁移。正式关系枚举中已有 `exposed_as_cloud_accelerator`，是否使用它取决于后续是否建立物理端点；目前不能用“没有物理端点”来证明零关系就是最终模型。

本裁决拒绝的是“六张配置卡按现有对象设计立即实施”，不是把 Google 配置从 M2 范围删除。总控应先开一个不产出正式事实的准备门：冻结配置页，区分设备、配置族和机器类型，裁定待建 ID 与类型，再按裁定结果拆包。原建议的 300 条事实、360 条断言预算在对象边界未定时没有约束力，应在重设计后重算。

## AMD Helios system：`accept_with_fixes`

`OBJ-AMD-HELIOS-72-MI455X` 已是正式 `rack` 对象；`OBJ-AMD-MI455X` 是正式 `module` 对象；`OREL-AMD-HELIOS-CONTAINS-MI455X`（`physically_contains`）和 `OREL-AMD-MI455X-IMPLEMENTS-CDNA5` 已存在。现有关系枚举足够，不需另造系统聚合关系。三份架构实现待办中没有 Helios 待迁移项，因此 backlog 为零是合理结论。

可复用的架构事实只用于解释互联或软件机制，不应写成机架定值，例如 `FACT-M2NA-CDNA5-IF-PROTOCOL` 与 `FACT-M2NA-CDNA5-SW`。产品页和 `SRC-M2NA-AMD-CES2026-RELEASE` 可共同承担身份、发布时间点与直接机架声明；动态产品页必须先固定。本包还必须找到一手来源明确支撑 72 个 MI455X 模组，不能因为对象 ID 含 72 就把数量当成事实。

在 MI455X 模组产品事实尚未验收前，不得用“72 × 单模组容量/带宽/算力”生成机架总量。即使以后允许派生，也必须同时具备已验收的关系数量、同一配置适用的模组输入、公式、单位和条件。本轮只抽取来源直接陈述的机架事实。满足产品页冻结、72 数量证据与产品状态口径三项门槛后，本包可启动；预算应作为上限，不是凑数目标。

## Trainium2 三实例：轻量先行，不替代 Google

建议范围是已经存在的 `OBJ-AWS-TRN2-3XLARGE`、`OBJ-AWS-TRN2-48XLARGE`、`OBJ-AWS-TRN2U-48XLARGE` 三个 `cloud_instance` 对象；前两者为 `reviewed`，后者因首次固定可用日期未决而为 `needs_resolution`。它们与 `OBJ-AWS-TRAINIUM2-CHIP` 的封装事实边界不同：实例卡只记录实例内芯片数量、实例级内存与网络等聚合配置；Trainium2 芯片或架构定值只通过既有 fact/source 引用复用，不复制成实例事实。

该子包可以先行，是因为三个对象、三条 `sku_variant_of` 关系、三条 `instance_contains_accelerator` 关系和 `OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH` 都已存在。现有 48 条实例事实可按原 `fact_id` 引用，待办集中在实例聚合配置与动态页面冻结，规模明显小于六族 Google 配置包。但它属于 AWS 产品配置，不能替代 Google 配置的厂商覆盖和对象模型工作。它最多是在 Google config 退回准备门期间暂时占用一个执行槽；Google 修正完成后仍需单独实施。

## 总控执行顺序与合并门

第一步同时准备 AWS package 与 Helios 的动态页面快照，并对 Trainium2 三实例做一次独立验收。第二步在 AWS 身份门、Helios 72 数量门通过后，启动三包抽取；Google 只进行对象模型裁定和来源冻结。第三步把 Google 重写为边界清楚的新工作包，再替换已经完成的轻量槽位。

三包进入合并前都必须通过相同底线：待建 object_id 与类型有一手身份依据；对象到架构的关系或包含关系使用正式枚举；架构事实不复制到 SKU、实例或系统对象；实例/机架聚合值不冒充芯片定值；动态来源有固定快照、SHA-256、日期和本地 endpoint；每条事实有断言、定位和卡片双向引用；预算偏差必须解释，不能用删事实维持预算。

## 验证记录

结构化引用已按正式表复算：本报告列出的 7 个既有对象、9 条既有关系、5 条抽查事实和 3 个抽查来源均唯一存在；9 个待建 AWS/Google `OBJ-*` 与正式对象表无碰撞，三个已纠正的 Trainium2 实例 ID 均唯一存在，三个错误 ID 在报告中无残留。AWS 的 24 个和 Google 的 10 个 GA 实现待办 ID 均存在；Helios 在 NA 实现待办中的命中数为 0。Trainium2 准备度报告中的 93 个去重 `FACT-AWS-TRN2*` 引用和 4 个 `REQ-AWS-TRN2-*` 引用也全部存在。

存在性不等于完成验收：抽查的 Trainium2 与 CDNA5 事实当前 `review_status` 为 `draft`；`SRC-AWS-TRN2-S01`、`SRC-AWS-TRN2-S14` 和 `SRC-M2NA-AMD-CES2026-RELEASE` 的 `source_status` 为 `current`、`review_status` 为 `draft`。后续工作包必须沿用这些真实状态，不能因为本复核接受排队边界就改写成 `reviewed`。

文件已通过严格 UTF-8 解码，禁用公式分隔符命中数为 0。`report-humanizer` 机器扫描未发现可检测的 AI 写作痕迹；随后按 `shuorenhua` 逐段回读标题、开头、转场、结尾及受保护的 ID、数字、状态和责任归属，未再改动事实。