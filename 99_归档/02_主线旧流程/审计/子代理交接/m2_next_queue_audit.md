# M2 后续队列审计

> 审计日期：2026-08-13。资料截止日沿用项目当前口径。本文只决定后续排队，不改正式对象、关系、事实、资料卡或已有暂存目录（staging）。

## 已核输入与当前基线

本次已完整读取 `研究计划.md`、`进度/当前状态.md`、`进度/任务台账.csv`、`审计/子代理交接/object_candidates.csv`、七厂商候选普查 `审计/子代理交接/model_inventory.md`、`审计/子代理交接/m2_nvidia_amd_batch_plan.md`、三个第一波架构包的实现对象待办、正式 `数据/objects.csv` 与 `数据/object-relations.csv`、`资料卡/型号索引.md`、`参考资料总览.md` 及来源、入口、事实和字段要求表。根目录 `README.md` 与 `AGENTS.md` 也已只读检查。

审计时正式库为 78 个对象、27 条关系、621 条事实、611 条逐来源断言和 792 条字段要求。同期的字段主体合同预审另发现 132 行既有事实或字段要求的实际主体类型不在 `fields.csv.allowed_subject_kinds` 中，当前校验器尚未覆盖该规则；新包不能沿用这些旧写法。AWS 四代物理对象包正在最终独立复核；Google v5e、v5p、v6e 云端器件已预留对象与关系，仍在关闭来源冻结门；Helios 参考机架和 Trainium2 三实例纠错包已经正式合并。因此下一批不得并发改写 AWS、Google、Helios 或 Trainium2 的现有暂存目录和正式链。

与候选包直接相关的资料覆盖并不均衡。AMD 已固定 CDNA（Compute DNA，AMD 数据中心计算架构）2 至 5 的四份架构白皮书，并有 MI400 产品页快照，但没有 MI350P 的固定产品页；华为虽有 15 份本地 PDF，Ascend 950 的对象匹配资料仍主要是动态官网；NVIDIA 有 65 份本地 PDF 和较完整的 Blackwell 一手资料，但 B200 的正式物理对象尚未冻结；Groq 的两份本地一手资料不足以解决 GroqChip 修订关系。这个差异决定了本轮先做 AMD 和华为已冻结对象，而不是简单按资料数量排队。

开工前要固定的动态入口如下。表中的 D-*、H-* 是候选普查的入口键，只有总控分配 source_id（来源内容版本标识）后才能写入正式来源表。

| 工作包 | 入口 | URL | 不可替代职责 |
|---|---|---|---|
| MI455X | 专用规格页 | `https://www.amd.com/en/products/accelerators/instinct/mi400/mi455x.html` | 精确 SKU、形态、功耗和当前状态 |
| MI350P | D-1 | `https://www.amd.com/en/products/specifications/accelerators.html` | 当前规格数据库中的精确型号行 |
| MI350P | D-7 | `https://www.amd.com/en/products/accelerators/instinct/mi350.html` | MI350P 产品定位、产品族边界和对象匹配规格 |
| Ascend 950 | H-2 | `https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech` | Ascend 950 裸片、950PR/950DT 路线与时间状态 |
| Ascend 950 | H-6 | `https://www.hiascend.com/hardware/processor` | 当前处理器身份与封装入口 |
| Ascend 950 | H-7 | `https://www.hiascend.com/hardware/accelerator-card` | 950PR 与 Atlas 350 卡级边界 |
| Ascend 950 | H-12 | `https://www.hiascend.com/activities/dynamic-news/20260320-3` | Atlas 350 正式上市日期与搭载关系 |

## 排队结论

下一批建议启动三个彼此隔离的小包。顺序按“能否立即形成对象匹配事实”排列；第一、第二包可并行，第三包先冻结华为页面再抽取。

| 推荐顺序 | 工作包 | 精确对象 | 对象层级 | 候选卡数 | 当前可启动性 |
|---:|---|---|---|---:|---|
| 1 | `M2-W3-AMD-MI455X-MODULE` | `OBJ-AMD-MI455X` | `module` | 1 | 可立即启动；正式对象、架构关系和 2026-08-13 产品页快照均已有 |
| 2 | `M2-W3-AMD-MI350P-CARD` | `OBJ-AMD-MI350P` | `card` | 1 | 可启动；先同日冻结 D-1 与 D-7 两个官方动态页 |
| 3 | `M2-W3-HUAWEI-ASCEND950-PHYSICAL` | `OBJ-HUAWEI-ASCEND-950-DIE`、`OBJ-HUAWEI-ASCEND-950PR`、`OBJ-HUAWEI-ASCEND-950DT` | `die` + 2 个 `package` | 3 | 可启动来源冻结与抽取；正式对象和封装关系已有，架构继承仍冻结 |

这组安排不与当前 AWS、Google 两包争用对象或来源链。AMD 从已经验收的 CDNA 4/5 架构卡落到两张实现卡；华为从架构卡转到一组已冻结身份的裸片/封装卡。NVIDIA 已有 H100 实现卡且本地资料最充足，Groq 和寒武纪的下一批物理对象仍卡在身份或关系门，因此本轮不强行追求厂商数量上的机械平均。

## 工作包一：`M2-W3-AMD-MI455X-MODULE`

对象只包含 `OBJ-AMD-MI455X`，复用 `OREL-AMD-MI455X-IMPLEMENTS-CDNA5`。`OBJ-AMD-HELIOS-72-MI455X` 的机架事实和 `OREL-AMD-HELIOS-CONTAINS-MI455X` 只用于反向检查作用域，不进入本包。

可复用而不得复制的正式架构事实包括 `FACT-M2NA-CDNA5-WGP-EXEC`、`FACT-M2NA-CDNA5-MATRIX-EXEC`、`FACT-M2NA-CDNA5-VECTOR-WIDTH`、`FACT-M2NA-CDNA5-FP4-A`、`FACT-M2NA-CDNA5-FP4-ACC`、`FACT-M2NA-CDNA5-FP8-A`、`FACT-M2NA-CDNA5-FP8-ACC16`、`FACT-M2NA-CDNA5-FP8-ACC32`、`FACT-M2NA-CDNA5-LDS-CAP`、`FACT-M2NA-CDNA5-VCACHE-CAP`、`FACT-M2NA-CDNA5-IF-PROTOCOL`、`FACT-M2NA-CDNA5-TDM-EXEC`、`FACT-M2NA-CDNA5-SPARSE-LEVEL` 和 `FACT-M2NA-CDNA5-SW`。卡片通过正式架构关系引用这些机制，产品定值另建 MI455X 原子事实。

`审计/M2-NA-ARCH_实现对象待办.csv` 的 `BACKLOG-M2NA-001..009` 全部属于 NVIDIA Blackwell 或 Rubin，本包迁移集合为 0。MI455X 产品规格直接从对象匹配来源抽取，不能为消耗 backlog 而错迁 NVIDIA 行。

最低一手来源组合是 `SRC-M2W2-AMD-MI400-LANDING-20260813` 的固定产品页、`SRC-M2NA-AMD-CDNA5-WP` 的固定白皮书，以及一份对象匹配且带日期的规格/状态页面。现有 MI400 快照已经直接陈述每颗 MI455X 的 432 GB HBM4（High Bandwidth Memory 4，第四代高带宽存储器）、23.3 TB/s 和最高 40 PFLOPS（每秒千万亿次浮点运算）FP4（4-bit floating point，4 位浮点），但专用 MI455X 页面 `/en/products/accelerators/instinct/mi400/mi455x.html` 仍须以真实访问日冻结后再承担 SKU（Stock Keeping Unit，具体产品配置）版本、功耗、形态和状态事实。`SRC-M2NA-AMD-CES2026-RELEASE` 只能承担公告时间或组合关系，不能替代当前产品规格。

主要风险是 EAM（Enhanced Accelerator Module，增强型加速器模组）订货边界、`production_ramp` 与实际客户交付的区别、FP4 数值的格式与稠密条件，以及 Helios 机架聚合值误下放。结构化预算、前置条件与独立验收门将在下节补齐。

## 工作包二：`M2-W3-AMD-MI350P-CARD`

对象只包含 `OBJ-AMD-MI350P`，复用 `OREL-AMD-MI350P-IMPLEMENTS-CDNA4`。MI350X、MI355X 和 8-OAM（OCP Accelerator Module，开放计算项目加速器模组）平台不在本包。

可复用而不得复制的正式架构事实包括 `FACT-M2NA-CDNA4-CU-EXEC`、`FACT-M2NA-CDNA4-MATRIX-EXEC`、`FACT-M2NA-CDNA4-IF-PROTOCOL`、`FACT-M2NA-CDNA4-LDS-CAP`、`FACT-M2NA-CDNA4-LDS-READ`、`FACT-M2NA-CDNA4-L1-CAP`、`FACT-M2NA-CDNA4-L2-CAP`、`FACT-M2NA-CDNA4-FP16-A`、`FACT-M2NA-CDNA4-FP8-A`、`FACT-M2NA-CDNA4-MX-A`、`FACT-M2NA-CDNA4-INT8-ACC`、`FACT-M2NA-CDNA4-SOFTMAX-DETAIL` 和 `FACT-M2NA-CDNA4-SW`。产品卡只写 PCIe（Peripheral Component Interconnect Express，高速外设互连）卡自身的容量、启用配置、功耗、散热、主机接口和状态。

该包同样不迁移 `BACKLOG-M2NA-001..009`，迁移集合为 0。最低一手来源组合为 D-1 的 AMD 加速器规格数据库、D-7 的 MI350 Series 产品页、固定白皮书 `SRC-M2NA-AMD-CDNA4-WP`，以及需要时使用的 `SRC-M2NA-AMD-CDNA4-ISA`。D-1 和 D-7 目前没有正式固定内容版本，必须在同一访问日保存页面、标题、URL、内容指纹和 SHA-256（256 位安全散列算法），再由总控分配正式来源 ID。

主要风险是把 MI350X/MI355X 的 OAM 配置套给 MI350P、把平台聚合值下放到 PCIe 卡、把架构级每 CU（Compute Unit，计算单元）吞吐当作整卡吞吐，以及产品状态、订货号、冷却和功耗模式随页面更新。结构化预算、前置条件与独立验收门将在下节补齐。

## 工作包三：`M2-W3-HUAWEI-ASCEND950-PHYSICAL`

本包交付三张物理卡：`OBJ-HUAWEI-ASCEND-950-DIE`、`OBJ-HUAWEI-ASCEND-950PR` 和 `OBJ-HUAWEI-ASCEND-950DT`。直接复用 `OREL-HUAWEI-950PR-CONTAINS-950-DIE` 与 `OREL-HUAWEI-950DT-CONTAINS-950-DIE`。正式库没有三者到 `OBJ-HUAWEI-DA-VINCI-INITIAL-ARCH` 的 `implements_architecture` 关系，所以本包没有可继承的正式架构事实；不能仅凭“Da Vinci”提示复制初代架构卡。

本包迁移 backlog 的集合为 0。`IMPL-FACT-HUAWEI-DV-MAX-CLOCK`、`IMPL-FACT-HUAWEI-DV-CUBE-SHAPE`、`IMPL-FACT-HUAWEI-DV-CUBE-MULTIPLIERS`、`IMPL-FACT-HUAWEI-DV-CUBE-ACCUMULATORS`、`IMPL-FACT-HUAWEI-DV-VECTOR-WIDTH-HC31`、`IMPL-FACT-HUAWEI-DV-VECTOR-WIDTH-MAX`、`IMPL-FACT-HUAWEI-DV-L0A-CAPACITY`、`IMPL-FACT-HUAWEI-DV-L0B-CAPACITY`、`IMPL-FACT-HUAWEI-DV-L0C-CAPACITY`、`IMPL-FACT-HUAWEI-DV-UB-CAPACITY`、`IMPL-FACT-HUAWEI-DV-L1-CAPACITY`、`IMPL-FACT-HUAWEI-DV-MAX-CUBE-PER-CYCLE`、`IMPL-FACT-HUAWEI-DV-MAX-L1-A-BW`、`IMPL-FACT-HUAWEI-DV-MAX-L1-B-BW` 和 `IMPL-FACT-HUAWEI-DV-MAX-UB-BW` 都是 2019 图示或 Ascend-Max 配置事实，不能附到 Ascend 950。

最低一手来源组合为 H-2 的 Huawei Connect 2025 路线图/主题演讲、H-6 的昇腾 NPU（Neural Processing Unit，神经网络处理器）处理器页；950PR 再加 H-12 的 Atlas 350 正式上市材料和 H-7 的加速卡页。H-2、H-6、H-7、H-12 均须建立固定内容版本；H-6 与 H-7 要使用同一访问日。950DT 在没有对象匹配的 GA（General Availability，正式可用）或客户交付证据时只能保留 `announced` 或 `pending_verification`，页面出现产品入口不能自动提升状态。

主要风险是把共同裸片与两种封装的内存、带宽和状态混在一起，把 Atlas 350 卡级事实下放到 950PR，把路线图数值写成已交付规格，以及使用第三方转述填补官方未披露字段。结构化预算、前置条件与独立验收门将在下节补齐。

## 暂不启动的候选

- NVIDIA L20/L2 虽已有 `OBJ-NVIDIA-L20`、`OBJ-NVIDIA-L2` 和到 Ada Lovelace 的正式关系，但当前一手来源只稳定支持设备身份和软件兼容，尚无对象匹配的固定规格。只能先做来源预审，不能开始填定值卡。
- NVIDIA B200/Blackwell 物理包的本地一手资料较强，但 `CAND-NVIDIA-B200-SXM-180GB` 尚未进入正式对象表，`BACKLOG-M2NA-001..003` 属于两裸片硅封装，`BACKLOG-M2NA-006..008` 又属于 GB200 Superchip GPU 实现。物理对象和关系未冻结前不能把两组待办塞进同一张 B200 卡。
- 第一代 GroqChip Processor 有两份本地一手资料，但 2020 ASIC（Application-Specific Integrated Circuit，专用集成电路）与 2024 v1.7 产品简报的修订关系未决，正式库也没有可承接实现待办的产品对象。
- NVIDIA Groq 3 的 `OBJ-NVIDIA-GROQ3-LPX-TRAY` 已冻结，但五条 `IMPL-FACT-NVG3-*` 是每 LPU（Language Processing Unit，语言处理单元）实现值；`CAND-GROQ-LP30` 尚无正式物理对象，不能把它们写到托盘。
- 寒武纪 MLU590-H8/M9、MLU570/580 仍缺对象匹配的一手规格或物理包含关系；现有软件矩阵不能替代硬件产品资料。
- `OBJ-AMD-MI308X` 尚无已复核的 CDNA 3 关系和稳定对象匹配来源；MI440X、MI430X、MI500、Rubin、TPU（Tensor Processing Unit，张量处理单元）8t/8i、Trainium4 等观察对象仍处于预告、生产爬坡或范围未冻结状态。
- AWS、Google、Helios 和 Trainium2 不进入本次新队列：前两者仍有在途工作包，后两者已经完成相应合并，重开会造成对象或来源链冲突。

## 结构化预算

预算是强制回看边界的上限，不是要求填满。字段没有可靠一手证据时应写要求状态，不应为了接近预算制造事实。若任何包超过上限，先停止抽取并检查对象是否混入兄弟 SKU、系统聚合值或架构复制。

| 写入项 | MI455X module | MI350P card | Ascend 950 physical |
|---|---:|---:|---:|
| 资料卡 | 1 | 1 | 3 |
| 新对象 / 新关系 | 0 / 0 | 0 / 0 | 0 / 0 |
| 新事实 `facts` | 最多 45 | 最多 40 | 最多 70 |
| 新逐来源断言 `fact-assertions` | 最多 55 | 最多 50 | 最多 85 |
| 新组件 `components` | 最多 12 | 最多 10 | 最多 15 |
| 新存储层级 `memory-levels` | 最多 6 | 最多 5 | 最多 10 |
| 新互联 `links` | 最多 5 | 最多 4 | 最多 8 |
| 新精度路径 `precision-paths` | 最多 12 | 最多 12 | 最多 15 |
| 新特殊能力 `special-capabilities` | 最多 6 | 最多 5 | 最多 8 |
| 新拓扑 `topologies` | 0 | 0 | 0 |
| 新条件集 `condition-sets` | 最多 20 | 最多 18 | 最多 30 |
| 新派生指标 / 派生输入 | 最多 8 / 16 | 最多 8 / 16 | 最多 10 / 20 |
| 新字段要求 `field-requirements` | 最多 50 | 最多 50 | 最多 120 |
| 九域完整度记录 | 9 | 9 | 27 |
| 新来源内容版本 / endpoint | 最多 2 / 4 | 最多 3 / 6 | 最多 4 / 8 |
| 新选择运行 | 1 | 1 | 1 |

MI455X 与 MI350P 的派生指标预算主要留给有完整输入的存算比和每瓦或每卡归一值；没有输入精度、累加精度、稠密/稀疏条件和峰值口径时不计算。Ascend 950 只允许在同一对象、同一条件的一手输入上派生；不得用 Atlas 350、Atlas 650E 或 SuperPoD 聚合值反除封装规格。

三个包共用一条当前校验器尚未自动执行的门：每条新事实和字段要求都要人工核对 `fields.csv.allowed_subject_kinds`。整卡吞吐挂到 `precision_path`，存储容量和带宽挂到 `memory_level`，互联速率和聚合带宽挂到 `link`，特殊算子实现挂到 `capability`；只有字段合同允许时才以 `object` 为主体。验收记录必须给出零新增主体合同不一致的复算结果，不能为了容纳产品页数值批量放宽字段合同。

## 开工前置条件

### MI455X

总控先为专用 MI455X 规格页分配正式来源与访问入口（endpoint）ID，并用真实访问日固定页面；现有 `SRC-M2W2-AMD-MI400-LANDING-20260813`、`SRC-M2NA-AMD-CDNA5-WP` 及其 endpoint 在本包进入最小集前，要完成包内使用角色与生命周期复核。对象类型继续使用正式 `module`，不得由执行代理自行增加 EAM 封装对象。状态截止点固定为项目截止日；合作伙伴“计划部署”不能提升为客户已交付。

### MI350P

总控先把 D-1 规格数据库和 D-7 MI350 Series 页面保存为同日固定版本并分配正式来源 ID。开工检查必须在两个页面中找到完全匹配的 `MI350P` 或 `MI350P PCIe` 条目；如果只能找到 MI350 Series、MI350X 或 MI355X，工作包退回来源预审，不生成产品定值事实。`SRC-M2NA-AMD-CDNA4-WP` 与 `SRC-M2NA-AMD-CDNA4-ISA` 只负责架构机制和数值语义，不替代产品规格。

### Ascend 950 physical

总控先固定 H-2、H-6、H-7、H-12，并给四个内容版本分配正式来源 ID；H-6 与 H-7 使用同一访问日。开工前逐项确认三件事：H-6 能区分 Ascend 950、950PR 与 950DT；H-12 明确 Atlas 350 与 950PR 的搭载关系；H-2 对 950DT 的表述是路线图还是已可用状态。任何一项无法确认，都只影响相应对象的字段状态，不允许用媒体转述补数。三张对象卡继续复用现有 `package_contains_die` 关系，本包不申请 Da Vinci 架构关系。

## 独立验收门

### `M2-W3-AMD-MI455X-MODULE`

合并前必须同时满足以下条件：

1. 432 GB、23.3 TB/s、最高 40 PFLOPS FP4 等数值只有在原文明确以单个 MI455X 为主语时才可写入，并保留 HBM4、峰值理论值、格式、稠密/稀疏和其他限定；产品页若改版，旧快照与新版本不能合并成一个无日期断言。
2. Helios 的 72 模组、机架内存、机架功耗、机架拓扑和聚合带宽为零迁移；CDNA 5 架构机制也不复制为 MI455X 产品事实。
3. EAM、功耗、冷却、主机接口和客户交付状态若没有对象匹配的一手证据，分别保留 `pending_verification` 或 `not_found`，不得由相邻 MI400 型号补齐。
4. 九个完整度领域恰有九行；所有新事实能回到稳定定位；本包 selection run 按最终事实集重做反向移除，不能沿用 Helios 或 `M2-NA-ARCH` 的成员结论。
5. 初稿以外的代理逐项复核对象层级、精度路径、累加精度、理论/实测口径、GB（十进制吉字节）/GiB（二进制吉比字节）和互联方向；暂存校验通过后再交总控顺序合并。

### `M2-W3-AMD-MI350P-CARD`

合并前必须同时满足以下条件：

1. 每条规格都以 MI350P PCIe 为对象，MI350X/MI355X 的 OAM 容量、启用单元、冷却或功耗事实为零迁移；8-OAM 平台聚合值不得下放。
2. 卡级矩阵、向量或总吞吐不能由 CDNA 4 每 CU 数值与未公开单元数相乘得到。若官方只给架构级每 CU 值，卡片引用架构关系并把整卡字段留为缺口。
3. D-1 与 D-7 的同日快照均有标题、URL、访问日、哈希和稳定定位；正式来源角色能说明各自不可替代的信息。若两个页面只是彼此重复，最小集只留覆盖更完整且版本更稳定的一份，另一份保留筛选记录。
4. 产品身份、PCIe 形态、内存、带宽、功耗/冷却、主机接口、精度和状态的作用域清楚；九域完整度、字段缺口和条件集闭合。
5. 由非初稿作者复核并通过暂存校验；事实集合冻结后建立独立 selection run 和反向移除记录。

### `M2-W3-HUAWEI-ASCEND950-PHYSICAL`

合并前必须同时满足以下条件：

1. 三张卡分别承担共享裸片、950PR 封装和 950DT 封装事实。共同裸片事实不得重复写入两张封装卡，封装特有的内存、带宽、形态和状态也不得写回裸片。
2. Atlas 350 的卡级功耗、主机接口、散热或系统聚合值不得下放到 950PR；Atlas 650E、Atlas 950 SuperPoD 及任何第三方路线图数字为零迁移。
3. 950DT 没有对象匹配的正式可用或客户交付证据时，状态保持 `announced` 或 `pending_verification`。产品导航出现入口不等于已供货。
4. 15 条 `IMPL-FACT-HUAWEI-DV-*` 仍全部保持 deferred；没有正式架构关系，也没有从 `OBJ-HUAWEI-DA-VINCI-INITIAL-ARCH` 复制的事实。
5. H-2、H-6、H-7、H-12 的内容版本、入口、访问日和定位闭合；三张卡各有九域完整度记录。未公开与检索后未找到分别使用正确状态，不以零或第三方估值代替。
6. 由未参与初稿的代理重点复核裸片/封装/卡三级边界、状态日期、原始单位和来源职责；暂存校验通过后生成本包独立 selection run。

## 调度和推荐合并顺序

| 时间点 | 总控动作 | 可并行工作 |
|---|---|---|
| T0 | 分配新 source/endpoint ID；冻结 MI455X 专页、D-1/D-7、H-2/H-6/H-7/H-12 | 三包只做只读定位，不写候选外键 |
| T1 | 确认页面对象匹配与来源生命周期 | MI455X、MI350P 可同时进入各自 staging；华为包完成三对象来源切分 |
| T2 | 冻结各包事实集合 | 三包分别生成 selection run、反向移除记录和自检 |
| T3 | 指派非初稿作者独立复核 | AMD 两包不能由同一初稿作者自审；华为另行复核 |
| T4 | 总控顺序合并 | 建议 MI455X → MI350P → Ascend 950 physical；谁未过门谁继续留在 staging，不阻塞已过门的包 |

推荐先合并 MI455X，因为对象、关系、固定产品页和架构来源最完整；MI350P 紧随其后，但以 D-1/D-7 对象匹配为硬门；Ascend 950 先启动来源冻结并与 AMD 并行抽取，因裸片/封装/卡三级混用风险最高，放在最后验收。合并任一包后都要运行全局结构化数据校验；只有新增本地 PDF 或改变四个资料清单时才需要另外运行资料池校验。

## 交接状态

本次只做排队审计，没有联网补证，没有创建 staging，也没有修改正式库、正式资料卡、现有 staging、进度文件、README 或 AGENTS。交付文件只有 `审计/子代理交接/m2_next_queue_audit.md`。