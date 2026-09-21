# M2 第二波排队审计

> 审计日期：2026-08-13。资料截止日沿用项目的 2026-08-12。结论是排队建议，不改变正式对象、关系、事实或项目进度。

## 结论

第一波 29 张架构卡已经合并，下一轮建议同时启动三个相互隔离的包：`M2-W2-AWS-PACKAGE` 处理 AWS 单芯片或封装，`M2-W2-G-CONFIG` 处理 Google Cloud TPU（Tensor Processing Unit，张量处理单元）配置族，`M2-W2-AMD-HELIOS-SYSTEM` 处理 AMD Helios 参考机架。三包分别写物理实现、云配置和机架事实，不共用写入目录，也不要求另一个包先合并。

并行前仍有一次短的总控预处理：为 AWS 四个物理对象和 Google 五个配置族预留正式 ID，并冻结本报告列出的动态页面。预留完成后，AWS 包位于后续实例包的关键路径，应优先保证人力；Google 包的页面最容易原地变化，应最先做快照；Helios 只有一张观察卡，可以作为快速验收通道。三个包不必按固定顺序合并，谁先通过自己的独立验收门，谁先进入总控顺序合并。

## 审计依据与基线

本次完整读取了根 `README.md`、`AGENTS.md`、`研究计划.md`、`进度/当前状态.md`、`进度/任务台账.csv`，三份 M2 批次计划，M2 范围复核与对象映射交接，`审计/M2_对象范围验收.md`、`审计/M2_对象范围映射.csv`、正式 `数据/objects.csv`、`数据/object-relations.csv`，以及三份 `审计/M2-*-ARCH_实现对象待办.csv`。为了核准复用链，又读取了三份架构包正式合并验收，以及正式事实、逐来源断言、来源、入口和选择运行表。

当前正式库有 71 个对象、20 条对象关系、614 条事实、600 条逐来源断言和 786 条字段要求。实现待办共 120 行，其中 Google/AWS 包 65 行、Groq/华为/寒武纪包 46 行、NVIDIA/AMD 包 9 行。总控在本次审计期间修正了 20 个第一波架构对象的陈旧 notes；本报告以修正后的当前 `objects.csv` 为准，没有把旧 notes 误判成架构事实尚待抽取。`M2-GA-ARCH` 与 `M2-NA-ARCH` 的选择运行分别仍有 19 和 17 个成员，状态均为 `reviewed`；第二波要建立自己的选择运行，不改写这两个架构运行。

文中“已有”表示 ID 此刻确实存在于正式 `objects.csv`；“建议预留”表示这是本报告给总控的精确 ID 建议，当前尚不是正式对象；“冻结”表示本包不得创建对象或写事实。候选 ID 只用于追溯范围裁决，不当作事实外键。

## 工作包一：`M2-W2-AWS-PACKAGE`

### 对象和关系

该包承接原计划的 `M2-A-PACKAGE`，对象类型统一使用正式枚举 `package`。现有证据只能稳定支持“芯片或封装”边界，因此本包不另造裸片（die）对象，也不把实例总量反除为芯片值。

| 物理对象 ID | 当前状态 | 架构端点 | 本包关系 |
|---|---|---|---|
| `OBJ-AWS-INFERENTIA1-CHIP` | 建议预留；当前不存在 | `OBJ-AWS-INFERENTIA1-ARCH` | 新建 `implements_architecture` |
| `OBJ-AWS-TRAINIUM1-CHIP` | 建议预留；当前不存在 | `OBJ-AWS-TRAINIUM1-ARCH` | 新建 `implements_architecture` |
| `OBJ-AWS-INFERENTIA2-CHIP` | 建议预留；当前不存在 | `OBJ-AWS-INFERENTIA2-ARCH` | 新建 `implements_architecture` |
| `OBJ-AWS-TRAINIUM2-CHIP` | 已有；`package / reviewed` | `OBJ-AWS-TRAINIUM2-ARCH` | 复用 `OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH` |
| `OBJ-AWS-TRAINIUM3-CHIP` | 建议预留；当前不存在 | `OBJ-AWS-TRAINIUM3-ARCH` | 新建 `implements_architecture` |

四个建议 ID 必须先由总控写入正式对象预留层，包内代理才能用它们作外键。若总控采用其他命名，应先改排队清单，不能让代理自行生成另一组 ID。`OBJ-AWS-TRAINIUM4-ARCH` 虽已存在，Trainium4 的物理产品身份和定值仍未冻结，本包不创建 Trainium4 芯片或封装。未确认的 Inferentia3 同样不进入本包。

AWS 实例与系统关系是下游任务。本包只保留现有 Trainium2 实例关系，不为 Inf1、Trn1、Inf2 或 Trn3 预建 `instance_contains_accelerator`，也不承接 UltraServer 聚合值。

### 实现待办和架构复用

| 目标对象 | 必须处置的 backlog 行 | 实现值现有来源 |
|---|---|---|
| `OBJ-AWS-INFERENTIA1-CHIP` | `DEF-M2GA-AIF1-01..04` | `SRC-M2-GA-A01`、`SRC-M2-GA-A02` |
| `OBJ-AWS-TRAINIUM1-CHIP` | `DEF-M2GA-ATRN1-01..05` | `SRC-M2-GA-A03`、`SRC-M2-GA-A05` |
| `OBJ-AWS-INFERENTIA2-CHIP` | `DEF-M2GA-AIF2-01..05` | `SRC-M2-GA-A04`、`SRC-M2-GA-A05` |
| `OBJ-AWS-TRAINIUM2-CHIP` | `DEF-M2GA-ATRN2-01` | `SRC-AWS-TRN2-S01` 至 `SRC-AWS-TRN2-S14` |
| `OBJ-AWS-TRAINIUM3-CHIP` | `DEF-M2GA-ATRN3-01..09` | `SRC-M2-GA-A06`、`SRC-M2-GA-A07`、`SRC-M2-GA-A08`、`SRC-M2-GA-A10` |

共 24 行。`DEF-M2GA-ATRN2-01` 是对 M1 已有 Trainium2 芯片事实、组件和断言链的复用提示，不产生第二套事实 ID。其余 23 行需要按精度、容量、带宽、端口数量、方向和条件拆成原子事实；一行含多个量时不能把整串文本塞进一个事实。

下表是建议直接引用的正式架构事实。卡片可以通过架构关系解释机制，不能把这些行复制成物理对象的新事实。

| 物理对象 | 可复用的 architecture fact_id | 正式 source_id |
|---|---|---|
| Inferentia1 | `FACT-M2GA-AIF1-NAME`、`FACT-M2GA-AIF1-EXEC`、`FACT-M2GA-AIF1-MEM` | `SRC-M2-GA-A02` |
| Trainium1 | `FACT-M2GA-ATRN1-NAME`；`FACT-M2GA-ATRN1-EXEC`、`FACT-M2GA-ATRN1-SBUF`、`FACT-M2GA-ATRN1-NL` | 前者 `SRC-M2-GA-A03`；后三者 `SRC-M2-GA-A05` |
| Inferentia2 | `FACT-M2GA-AIF2-NAME`；`FACT-M2GA-AIF2-EXEC`、`FACT-M2GA-AIF2-SBUF`、`FACT-M2GA-AIF2-NL` | 前者 `SRC-M2-GA-A04`；后三者 `SRC-M2-GA-A05` |
| Trainium2 | `FACT-AWS-TRN2-ARCH-SW-RUNTIME`、`FACT-AWS-TRN2-CAP-DMA-COMPRESS-LEVEL`、`FACT-AWS-TRN2-CAP-DMA-TRANSPOSE-LEVEL` | `SRC-AWS-TRN2-S14`、`SRC-AWS-TRN2-S01`、`SRC-AWS-TRN2-S02` |
| Trainium3 | `FACT-M2GA-ATRN3-NAME`；`FACT-M2GA-ATRN3-EXEC`、`FACT-M2GA-ATRN3-NL`；`FACT-M2GA-ATRN3-SBUF` | `SRC-M2-GA-A06`；`SRC-M2-GA-A07`；`SRC-M2-GA-A10` |

### 动态来源和最低证据

最低一手证据是每个对象一份对象匹配的 Neuron 设备或 NeuronCore 文档，再加一份带日期的发布或部署状态来源；历史锚点若没有足够的日期证据，只完成规格卡并把日期或当前状态留作 `pending_verification`。实例产品页只能证明映射或部署，不能代替单芯片事实。

`SRC-M2-GA-A01` 与 `SRC-M2-GA-A07` 当前为 `dynamic_unfrozen`，且正式入口没有本地快照，开工时必须保存访问日、标题、合法快照和 SHA-256（256 位安全散列算法）。`SRC-M2-GA-A02`、`A03`、`A04`、`A05`、`A06`、`A10` 虽使用版本化网页地址，也应在本包保存所用版本的内容指纹；`SRC-M2-GA-A08` 是带日期页面，若承担状态事实，同样要固定页面版本。Trainium1 首发页 A-3、Inf2 正式可用（General Availability，GA）页 A-6 若用于状态，先建独立来源版本，不能混进已有架构 source_id。Trainium2 继续使用 M1 已固定的正式快照，不重新下载成另一来源家族。

### 预算和独立验收门

交付预算为 5 张物理卡、4 个新对象、4 条新架构关系和 24 行 backlog 处置记录。结构化写入上限为 70 条新事实、90 条新断言、25 个组件、15 个存储层级、10 条互联、20 条精度路径、30 个条件集、75 条字段要求和 45 条九域完整度记录；Trainium2 不计重复事实。来源侧最多新增 5 个内容版本、10 个入口或快照和 1 个本包选择运行。超过上限说明对象边界或拆分粒度发生变化，应先回总控重排，不能顺手扩包。

该包只有同时满足以下条件才可合并：四个新 ID 已由总控预留；24 行 backlog 全部迁移、复用或带理由保留；没有实例反除值；Trainium3 的 CC-Core（集合通信核心）数量和 HBM（High Bandwidth Memory，高带宽存储器）带宽分歧保留为不同断言与条件，不强裁一个值；Trainium4 和实例/系统事实为零；包内校验通过，并由非初稿作者复核对象层级、单位和来源定位。正式合并后再运行全局数据校验；若新增本地资料，还要运行资料池校验。

不能上卷到架构层的内容包括 NeuronCore 数量、芯片峰值、HBM 容量与带宽、DMA（Direct Memory Access，直接存储器访问）数量与总带宽、NeuronLink 接口数、工艺和封装值。不能从实例或 UltraServer 下放的内容包括实例总算力、聚合 HBM、EFA（Elastic Fabric Adapter，弹性网络适配器）和系统拓扑。Trainium1 与 Inferentia2 可以复用 NeuronCore v2（NCv2）机制来源，但不能据此把两款芯片写成同一物理实现。

## 工作包二：`M2-W2-G-CONFIG`

### 对象和关系

该包承接原计划的六个配置族。通配符名称代表家族，不是一个可购买 SKU（Stock Keeping Unit，具体产品配置）；同一来源快照中的稳定 API（Application Programming Interface，应用程序接口）名作为卡内配置行，除非以后出现独立计费或硬件边界，暂不逐行建对象。

| 候选追溯 | 精确 object_id | 当前状态与类型 |
|---|---|---|
| `CAND-GOOGLE-TPU-V4-SLICE-FAMILY` | `OBJ-GOOGLE-TPU-V4-SLICE-FAMILY` | 建议预留；`cloud_accelerator` |
| `CAND-GOOGLE-TPU-V5LITEPOD-CONFIG-FAMILY` | `OBJ-GOOGLE-TPU-V5LITEPOD-CONFIG-FAMILY` | 建议预留；`cloud_accelerator` |
| `CAND-GOOGLE-TPU-V5P-SLICE-FAMILY` | `OBJ-GOOGLE-TPU-V5P-SLICE-FAMILY` | 建议预留；`cloud_accelerator` |
| `CAND-GOOGLE-TPU-V6E-CONFIG-FAMILY` | `OBJ-GOOGLE-TPU-V6E-CONFIG-FAMILY` | 建议预留；`cloud_accelerator` |
| `CAND-GOOGLE-CT6E-STANDARD-FAMILY` | `OBJ-GOOGLE-CT6E-STANDARD-FAMILY` | 已有；`cloud_instance / reviewed` |
| `CAND-GOOGLE-TPU7X-SLICE-FAMILY` | `OBJ-GOOGLE-TPU7X-SLICE-FAMILY` | 建议预留；`cloud_accelerator` |

只有 `OBJ-GOOGLE-CT6E-STANDARD-FAMILY` 当前在正式表中。其余五个 ID 必须由总控预留后才能成为事实外键。TPU 8t、TPU 8i 没有稳定 accelerator type 或 machine type，本包冻结；TPU v3 Pod、v4/v5p/TPU7x Pod 以及任何 SuperPod 聚合值属于系统包，也不进入这里。

当前没有正式 TPU 物理对象可作为 `exposed_as_cloud_accelerator` 的端点，所以本包关系预算为 0。配置族也不能用 `implements_architecture` 冒充物理实现。`v6e-*` 与 `ct6e-standard-*` 的映射先保存为带来源和条件的配置表；正式关系枚举没有合适类型时，不自造 relation_type。

### 实现待办和架构复用

本包直接承接 10 行 `M2-GA-ARCH` 待办：`DEF-M2GA-GV5E-01..04` 归到 `OBJ-GOOGLE-TPU-V5LITEPOD-CONFIG-FAMILY`，`DEF-M2GA-GV5P-03` 与 `DEF-M2GA-GV5P-06` 归到 `OBJ-GOOGLE-TPU-V5P-SLICE-FAMILY`，`DEF-M2GA-GV6E-01..04` 归到 `OBJ-GOOGLE-TPU-V6E-CONFIG-FAMILY`。`DEF-M2GA-GV5P-03` 中的 95 GiB 是云可见值，96 GiB 是物理表值；本包只接前者，后者继续留给物理对象，不建立架构冲突。v4、`ct6e-standard-*` 和 TPU7x 没有直接 backlog 行，需要从对象匹配的当前配置资料新建事实。

`ct6e-standard-*` 只写机器类型、主机资源和与 Slice 的条件化映射，不复制 `OBJ-GOOGLE-TPU-V6E-CONFIG-FAMILY` 的每芯片值。这样可避免同一 v6e 数值在两个云对象上成为两套规范事实。

| 配置族 | 可复用的 architecture fact_id | 正式 source_id |
|---|---|---|
| v4 | `FACT-M2GA-GV4-NAME`、`FACT-M2GA-GV4-ICI-MECH` | `SRC-M2-GA-G03` |
| v5e / v5litepod | `FACT-M2GA-GV5E-NAME`、`FACT-M2GA-GV5E-ICI-MECH` | `SRC-M2-GA-G08` |
| v5p | `FACT-M2GA-GV5P-NAME`、`FACT-M2GA-GV5P-ICI-MECH` | `SRC-M2-GA-G01` |
| v6e 与 ct6e | `FACT-M2GA-GV6E-NAME`、`FACT-M2GA-GV6E-ICI-MECH` | `SRC-M2-GA-G10` |
| TPU7x | `FACT-M2GA-G7X-NAME`、`FACT-M2GA-G7X-ICI-MECH` | `SRC-M2-GA-G01`、`SRC-M2-GA-G11` |

这些架构事实只负责代际名称和 ICI（Inter-Chip Interconnect，芯片间互联）机制。卡片不复制 TensorCore、MXU（Matrix Multiply Unit，矩阵乘单元）、SparseCore、片上存储或软件栈机制，也不拿固定论文代替当前 API 配置证据。

### 动态来源和最低证据

每个配置族至少需要对应代际页与一份同日的官方配置清单；涉及地区或退役状态时，再加同日区域/可用性页面。正式库已有但尚未固定本地快照的动态来源为 `SRC-M2-GA-G05`、`SRC-M2-GA-G07`、`SRC-M2-GA-G08`、`SRC-M2-GA-G09`、`SRC-M2-GA-G10`、`SRC-M2-GA-G11` 和 `SRC-M2-GA-G15`。这七个入口应在抽取前保存快照、访问日和哈希，不得让六张卡跨不同页面时点抄配置。

还需固定目前没有正式 source_id 的官方配置入口，至少包括 `https://docs.cloud.google.com/compute/docs/tpus/tpu-machines` 和 `https://docs.cloud.google.com/tpu/docs/create-instance-compute`；如果另用 accelerator configuration 或 regions/zones 页面，再分别建立来源版本。新来源 ID 由总控顺序分配，本报告不把网页地址临时名冒充正式 source_id。v6e 的 GA 日期若写入事实，应使用带日期的 Trillium GA 公告建立独立版本。固定论文 `SRC-M2-GA-G01` 和 `SRC-M2-GA-G03` 可复用，不需要重复下载。

动态风险不只在页面是否可访问，还包括 API 名改名、v5litepod 旧名与现行名映射、主机数量、区域、退役状态和配置表原地更新。配置行必须同时带 API 名、主机边界、芯片或加速器数量口径、状态日期和来源定位。`ct6e-standard-4t` 可出现在不同 Slice 中，不能把某一种拓扑写成该 machine type 的永久属性。

### 预算和独立验收门

交付预算为 6 张配置族卡、5 个新对象、1 个复用对象和 0 条新对象关系。允许最多 60 条卡内配置行；结构化上限为 300 条新事实、360 条新断言、80 个条件集、90 条字段要求和 54 条九域完整度记录，来源侧最多新增 6 个内容版本、12 个入口或快照和 1 个本包选择运行。若同日清单超过 60 行或必须把配置行提升为独立对象，应先拆包，不在原预算中扩张。

该包通过验收需要满足：五个建议 ID 已正式预留；六个家族都来自同一快照日；10 行 backlog 全部处置，v5p 的 95/96 GiB 作用域拆开；每个配置行都有 API 名、主机边界、数量口径和状态日期；没有 Pod 聚合值、架构机制复制或自造关系枚举；动态配置由非初稿作者逐行复核。包内校验通过后，单独生成配置包的反向移除记录；页面版本或事实集合变化时重跑，不沿用 `M2-GA-ARCH` 的 19 成员结论。

不能上卷到架构层的内容包括配置成员、区域、主机映射、云可见容量和退役状态。不能从 Pod 下放的是最大系统规模、拓扑和聚合带宽。物理 96 GiB 与云可见 95 GiB、GB 与 GiB、单向与双向聚合都要保持原作用域和原单位。

## 工作包三：`M2-W2-AMD-HELIOS-SYSTEM`

### 对象、关系和待办

这是从原 `AMD-D` 中拆出的单卡系统包，只处理已冻结的参考机架边界。`OBJ-AMD-HELIOS-72-MI455X` 已存在，类型为 `rack`，状态为 `reviewed`；`OBJ-AMD-MI455X` 已存在，类型为 `module`，状态为 `reviewed`；`OBJ-AMD-CDNA5-ARCH` 也已通过第一波验收。正式关系 `OREL-AMD-HELIOS-CONTAINS-MI455X` 和 `OREL-AMD-MI455X-IMPLEMENTS-CDNA5` 均可直接复用，本包不新增对象或关系。

`审计/M2-NA-ARCH_实现对象待办.csv` 的 `BACKLOG-M2NA-001..009` 全部属于 NVIDIA Blackwell、GB200 或 Rubin，不属于 Helios；本包直接承接的 backlog 行为 0。Helios 的系统事实要从对象匹配的 AMD 资料重新抽取。MI455X 模组定值、MI440X、MI430X、MI500 Series 和其他 AMD 平台均冻结在包外，不能借一张机架卡提前处理。

可引用的正式架构事实为 `FACT-M2NA-CDNA5-IF-PROTOCOL`（`SRC-M2NA-AMD-CDNA-LANDING`）和 `FACT-M2NA-CDNA5-SW`（`SRC-M2NA-AMD-CDNA5-WP`）。前者只说明 CDNA 5 的封装内 Infinity Fabric 机制，后者只说明 ROCm（AMD 开放计算软件栈）；二者都不能复制成机架聚合事实。系统卡通过两条正式对象关系回指 MI455X 与 CDNA 5 即可。

### 动态来源和最低证据

最低一手证据是 D-9 的对象匹配页面 `https://www.amd.com/en/products/accelerators/instinct/mi400.html`，加一份带日期的 AMD 发布或状态材料。D-9 当前没有正式 source_id 或本地快照，开工第一步应保存标题、访问日、合法快照和 SHA-256，再由总控分配来源 ID。`SRC-M2NA-AMD-CES2026-RELEASE` 已有 2026-08-12 固定快照，可承担带日期的公告职责；`SRC-M2NA-AMD-CDNA-LANDING` 和固定 PDF `SRC-M2NA-AMD-CDNA5-WP` 只负责架构关系与机制。

如果要把状态从 `announced` 提升到实际交付，还需 OEM 或 ODM（原始设备制造商或原始设计制造商）自己发布、且对象完全匹配的首供或部署材料。伙伴的计划、样机展示或“预计下半年”不能改写为已交付。后来取得的动态页面必须使用真实访问日，不能倒填为 2026-08-12 快照。

### 预算和独立验收门

交付预算为 1 张观察卡、0 个新对象、0 条新关系和 0 行架构 backlog 迁移。结构化上限为 18 条新事实、24 条新断言、6 个条件集、2 个拓扑、4 条系统互联、18 条字段要求和 9 条九域完整度记录；来源侧最多新增 2 个内容版本、3 个入口或快照和 1 个本包选择运行。

该包通过验收需要满足：卡片明确写成 OEM/ODM 参考设计，不是 AMD 可订购成品；“72”有单独的系统事实与来源，不能只靠对象名或关系推断；机架容量、功耗、冷却、互联和拓扑只留在 rack；任何由单模组乘算得到的值都标 `derived` 并保存输入，不能冒充厂商直值；0 行 `M2-NA-ARCH` backlog 被误迁移；状态提升有对象匹配的日期证据。该观察卡仍由非初稿作者复核，包内校验通过后才能交总控。

不能下放到 MI455X 的内容包括 72 模组规模、机架总容量、总功耗、冷却和系统互联。MI455X 的单模组容量、功耗或峰值也不能未经官方机架总值支持就乘成 Helios 直值。CDNA 5 架构机制不复制到系统事实，参考设计更不能写成可购买 SKU 或客户已部署产品。

## 并行方式和总控接收顺序

三包的实际依赖如下：

| 时间点 | 总控动作 | 三包状态 |
|---|---|---|
| T0 | 预留 AWS 4 个、Google 5 个建议 object_id；确认对象类型 | 只做只读抽取准备，不写候选 ID 外键 |
| T1 | 固定 AWS `A01/A07`、Google 七个动态来源和 AMD D-9 | 三包可同时进入各自 staging |
| T2 | 各包由不同代理完成初稿与自检 | 包间不互读草稿，不共享主键分配 |
| T3 | 独立复核；失败只退回本包 | Helios 可先验收；AWS 作为下游实例包前置优先合并；Google 完成逐行动态复核后合并 |
| T4 | 总控逐包合并并运行正式校验 | 只有已验收包改变正式库；其余继续隔离 |

三个包应分别使用自己的 `审计/子代理交接/m2_staging/<work_package>/`，卡片、结构化片段、来源版本和交接说明都不交叉写。共享的正式架构 fact_id 和 source_id 只读引用。任何包新增事实后都建立自己的 selection run；`M2-GA-ARCH` 的 19 个成员和 `M2-NA-ARCH` 的 17 个成员的既有运行不因本轮排队审计而改写。

## 检查记录

本次只写入 `审计/子代理交接/m2_wave2_queue_audit.md`。正式 CSV、资料卡、`README.md`、`AGENTS.md`、`研究计划.md` 和 `进度/` 均未修改。`README.md` 与 `AGENTS.md` 已按当前文件回读：两者已经记录第一波三包合并、71 个对象、20 条关系、614 条事实、600 条断言、786 条字段要求和下一阶段对象层工作，因此本次排队建议尚未被总控接受前无需更新。总控接受、预留对象或启动工作包后，再按项目规则同步进度文件；只有项目入口或长期约定发生变化时才改 README/AGENTS。

一次只读对象存在性复算把 PowerShell 的 `foreach` 语句结果直接接到管道，触发 `EmptyPipeElement` 解析错误。该问题属于命令构造错误，没有执行写入；改为先物化结果后复算成功。没有发生沙箱拒绝、审批失败、用户拒绝或远程服务错误。

`report-humanizer` 机器扫描返回 `No machine-detectable AI tells found`。随后按 `shuorenhua` 的 docs 场景做了最小幅度回读，重点检查标题、首段、表格引导、转场和结尾；object_id、fact_id、source_id、关系 ID、backlog ID、数量、日期、单位、状态和路径均作为保护项，没有改动“已有、建议预留、冻结”三类裁决。正式引用复算核对了 30 个 fact_id、24 个 source_id 和 3 个关系 ID，均存在；正式对象表中未命中的恰好是报告标明“建议预留”的 9 个 ID。文件没有替换字符或禁用的 Markdown 公式分隔符，并以 UTF-8 保存。