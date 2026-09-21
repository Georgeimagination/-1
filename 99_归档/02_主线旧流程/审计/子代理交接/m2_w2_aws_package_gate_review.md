# M2-W2-AWS-PACKAGE 来源冻结与身份门独立复核

状态：`accept_with_fixes`  
复核日期：2026-08-13  
复核范围：四个 AWS（Amazon Web Services，亚马逊云服务）单器件候选、四条架构关系、A01 至 A10 的包内取舍和 11 份 HTML（HyperText Markup Language，超文本标记语言）固定件。  
写入边界：只写本复核文件，没有修改 staging、正式数据表、来源表或进度文件。

## 裁决

现有一手正文足以区分 Inferentia1、Trainium1、Inferentia2 和 Trainium3 的单颗 `chip` 或单个 `device`。四个对象都可以进入正式预留层，四条 `implements_architecture` 关系的方向也与既有 Trainium2 关系一致。总控补写这四个候选的范围裁决后，可以按下文精确 ID 预留；不需要再做一轮外部身份检索。

`package` 在这里是单个物理器件的保守建模容器。材料没有公开裸片数、芯粒数、基板、封装外形或订货料号，因此对象和关系都应保留 `needs_resolution`。该类型不能解释成已经证实了封装构造，也不能据此新建 `package_contains_die`。

来源冻结还有两处要修正。第一，正式主入口记录的是 2026-08-12 访问，固定文件实际取得于 2026-08-13，不能把后一天的本地文件直接补进前一天的 endpoint（访问入口）记录。第二，A08 写的是 144 GB（十进制吉字节），A06 和 A07 写的是 144 GiB（二进制吉字节）；现有待办只登记了 4.9 与 4.7 TB/s、16 与 20 个 CC-Core（Collective Communication Core，集合通信核心）两组分歧，还需把容量单位差异纳入后续断言或明确限制 A08 的用途。两项修正不阻止对象预留，但在创建实现事实前必须完成。

## 允许预留的对象

当前正式库有 71 个对象。下列 ID、标签和 slug 按大小写不敏感口径复算均无碰撞，四个架构端点都已存在且为 `reviewed`。只合并本复核接受的四个对象后，对象数应为 75。NCv1、NCv2 和 NCv4 分别指 NeuronCore v1、v2 和 v4；DMA（Direct Memory Access，直接存储器访问）是独立的数据搬运引擎。`curator_slug` 是对象的稳定可读标识。

| object_id | canonical_label | object_type | curator_slug | review_status | 身份依据和限制 |
|---|---|---|---|---|---|
| `OBJ-AWS-INFERENTIA1-CHIP` | AWS Inferentia chip | `package` | `aws-inferentia1-chip` | `needs_resolution` | A01 v2.31.0 第 1977 至 1992 行先区分 Inf1 实例中的 16 颗芯片，再按每颗芯片列组件；A02 第 1745 至 1748 行把 NCv1 与 Inferentia NeuronDevice 相连。对象保留为历史锚点，实例数量不下放。 |
| `OBJ-AWS-TRAINIUM1-CHIP` | AWS Trainium chip | `package` | `aws-trainium1-chip` | `needs_resolution` | A03 第 1562 至 1583 行区分 Trn1 实例和每颗 Trainium 芯片；A05 第 1923 至 1935 行以 Trainium device 为边界补充 NCv2、DMA 和 NeuronLink-v2。 |
| `OBJ-AWS-INFERENTIA2-CHIP` | AWS Inferentia2 chip | `package` | `aws-inferentia2-chip` | `needs_resolution` | A04 第 1878 至 1898 行区分 Inf2 实例和每颗 Inferentia2 芯片；A05 只作共享 NCv2 实现补充。实例“最多 12 颗”不属于单器件属性。 |
| `OBJ-AWS-TRAINIUM3-CHIP` | AWS Trainium3 chip | `package` | `aws-trainium3-chip` | `needs_resolution` | A06 第 1887 至 1917 行同时使用 chip 和 device，并列出每颗芯片组成；A08 第 2113 至 2119 行把单芯片陈述和 UltraServer 聚合值分开；A10 第 1919 至 1920 行给出 NCv4 到 Trainium3 的映射。A08 的一般可用状态只直接属于 Trn3 UltraServer。 |

四行在 `审计/M2_对象范围映射.csv` 中仍没有裁决记录。独立复核已经给出可预留结论，但总控写入 `objects.csv` 前仍须补上对应的范围裁决，不能只凭 M0 候选行导入。

## 允许预留的关系

当前正式库有 20 条关系。四个关系 ID 和关系指纹均无碰撞，方向与 `OBJ-AWS-TRAINIUM2-CHIP` 到 `OBJ-AWS-TRAINIUM2-ARCH` 的既有关系相同。合并后关系数应为 24。

| object_relation_id | subject_object_id | relation_type | object_object_id | review_status |
|---|---|---|---|---|
| `OREL-AWS-INFERENTIA1-IMPLEMENTS-ARCH` | `OBJ-AWS-INFERENTIA1-CHIP` | `implements_architecture` | `OBJ-AWS-INFERENTIA1-ARCH` | `needs_resolution` |
| `OREL-AWS-TRAINIUM1-IMPLEMENTS-ARCH` | `OBJ-AWS-TRAINIUM1-CHIP` | `implements_architecture` | `OBJ-AWS-TRAINIUM1-ARCH` | `needs_resolution` |
| `OREL-AWS-INFERENTIA2-IMPLEMENTS-ARCH` | `OBJ-AWS-INFERENTIA2-CHIP` | `implements_architecture` | `OBJ-AWS-INFERENTIA2-ARCH` | `needs_resolution` |
| `OREL-AWS-TRAINIUM3-IMPLEMENTS-ARCH` | `OBJ-AWS-TRAINIUM3-CHIP` | `implements_architecture` | `OBJ-AWS-TRAINIUM3-ARCH` | `needs_resolution` |

这些关系只表达器件实现哪个已冻结架构。NeuronCore 数量、峰值、存储容量、互联数量、工艺和状态都要另建事实，不能放在关系 notes 中充当事实。

## A01 至 A10 的包内取舍

本包需要 9 个既有 `source_id`。A01 与 A07 各有一个 `latest` 抓取件和一个 v2.31.0 版本化抓取件，因此本地文件数为 11。A09 继续服务 Trainium4 架构观察对象，但不属于四个物理对象的实现包。HBM（High Bandwidth Memory，高带宽存储器）相关数值继续按来源原单位记录。

| 来源 | 裁决 | 本包职责 |
|---|---|---|
| A01 / `SRC-M2-GA-A01` | 纳入；v2.31.0 为首选，`latest` 只作同日入口审计 | Inferentia1 单芯片身份、4 个 NCv1、芯片峰值、8 GiB 与 50 GiB/s。架构包中原有 `redundant_covered` 结论只适用于 141 条架构事实；加入实现事实后必须重跑筛选。 |
| A02 / `SRC-M2-GA-A02` | 纳入 | NCv1 到 Inferentia 的映射及 `DEF-M2GA-AIF1-04` 的引擎输入。它不证明封装构造。 |
| A03 / `SRC-M2-GA-A03` | 纳入，Trainium1 主身份页 | 每芯片 NCv2、峰值、HBM 和 DMA。820 GiB/s 保留原单位标签。 |
| A04 / `SRC-M2-GA-A04` | 纳入，Inferentia2 主身份页 | 每芯片 NCv2、峰值、HBM 和 DMA。实例上限只作边界上下文。 |
| A05 / `SRC-M2-GA-A05` | 纳入，作为共享实现和冲突来源 | Trainium1 与 Inferentia2 各自的 device 组成、32 个 DMA、6 个 CC-Core 和 2 或 4 个 NeuronLink-v2。正文可用；页首“Trn2, Trn3”提示不能扩张对象范围。820 GB/s 与 A03/A04 的 820 GiB/s 分开保留。 |
| A06 / `SRC-M2-GA-A06` | 纳入，Trainium3 主身份与产品表 | 8 个 NCv4、芯片峰值、144 GiB、4.9 TB/s、2.56 TB/s 和 16 个 CC-Core。页首同时列 Trn1 与 Trn3，身份判断只用 Trainium3 正文。 |
| A07 / `SRC-M2-GA-A07` | 纳入；v2.31.0 为首选，`latest` 只作同日入口审计 | 4 个 HBM stack、144 GiB、4.7 TB/s、128 个 DMA、20 个 CC-Core、4 个 NeuronLink-v4，以及 NCv4 两个厂商命名的片上存储 SBUF、PSUM、数据通路和频率。与 A06 的互斥值要进入冲突链。 |
| A08 / `SRC-M2-GA-A08` | 纳入，但严格限制作用域 | 支撑 2025-12-02 的 Trn3 UltraServer 发布事件、Trainium3 单芯片身份、3 nm 和 HBM3e。最多 144 颗、20.7 TB 和 706 TB/s 只属于系统；144 GB 不与 A06/A07 的 144 GiB 合并。 |
| A09 / `SRC-M2-GA-A09` | 本包排除，不下载 | 只支撑 Trainium4 路线图。正式架构选择运行中的 A09 成员不因本包排除而删除。 |
| A10 / `SRC-M2-GA-A10` | 保留为实现抽取候选，不作为身份门必需来源 | NCv4 到 Trainium3 的映射及引擎、SRAM（Static Random-Access Memory，静态随机存取存储器）和稀疏实现补充。A06 已直接给出 8 个 NCv4，A07 与 A10 是否都不可替代，要在原子事实形成后做反向移除。 |

23 条实现待办完整落在四个对象上：Inferentia1 4 条、Trainium1 5 条、Inferentia2 5 条、Trainium3 9 条。`DEF-M2GA-ATRN2-01` 继续复用既有 Trainium2 链，不计入这 23 条，也不在本目录复制事实。

## 11 份固定件的哈希和定位

下表按登记值重新计算文件大小和 SHA-256（256 位安全散列算法），11 份均一致。行号只对当前哈希对应的文件有效；复制到正式快照目录后必须再次核对哈希。

| 文件 | 字节 | SHA-256 | 已核定位 |
|---|---:|---|---|
| `A01-inferentia-latest-2026-08-13.html` | 233120 | `76c26100a0a84ab09b4ec722b522c079e0f171c6c0730a1d02e86f6f80d822a2` | 第 2101、2104 行可见实例与每芯片边界；正文与 v2.31.0 完全相同。 |
| `A01-inferentia-v2.31.0-2026-08-13.html` | 215997 | `8810e9d6ffa5aa84b6fd1a0a79dee9840d6972f9586dbc0c4fd5e49b3f6445ce` | 第 1977 至 1992 行；`readthedocs-version-slug=v2.31.0`。 |
| `A02-neuroncore-v1-v2.9.1-2026-08-13.html` | 62202 | `06d7b61ef030db81956e2f814c5266138bd317e3354951e2a2071601cdd745cd` | 第 1745 至 1748 行；`version=v2.9.1`。 |
| `A03-trainium-v2.26.1-2026-08-13.html` | 166258 | `6257908ff6d5febd52f974340d35e2f5dcfe2c1c14b9c4132dcb3dc3124c7079` | 第 1562 至 1583 行；原 `general` 路径解析到 `about-neuron`，版本仍为 v2.26.1。 |
| `A04-inferentia2-v2.29.1-2026-08-13.html` | 203185 | `cc1c79f5255f6cc851dab448098adc54fea713a626c205bba4a5a2b5ef2372dd` | 第 1878 至 1898 行；版本 v2.29.1。 |
| `A05-trainium-inferentia2-nki-v2.29.1-2026-08-13.html` | 292064 | `4d2318ec97548a8cb970ec06fb0c2f167a97aa17e361bb89563d057cb36b50cf` | 第 1923 至 1935 行；正文对象与页首适用提示分开使用。 |
| `A06-trainium3-v2.28.1-2026-08-13.html` | 206604 | `2fad4aca914e1a10289f636a273464d5f5f86ad6c5cc830092dfabb0bf786dcb` | 第 1887 至 1917 行；版本 slug 与编辑链接均指 v2.28.1，页框公告中的 2.28.0 不作版本依据。 |
| `A07-trainium3-nki-latest-2026-08-13.html` | 268399 | `aa22cfcffd97e35e1d1c17a14480a1f5ace87f2adf7b5f46e26ba512d0ef209f` | 第 2140 至 2156 行；正文与 v2.31.0 完全相同。 |
| `A07-trainium3-nki-v2.31.0-2026-08-13.html` | 251687 | `4bb6e756d37069f83f36fca4144e494688a23396728b52338385a4ee8be6a2f2` | 第 2016 至 2032 行为 device 与 SRAM；第 2040 至 2065 行为引擎宽度和频率。 |
| `A08-trn3-ultraservers-2025-12-02-fetched-2026-08-13.html` | 329595 | `d10e887199750363ffb679347c78d27012a2d63c2cc2bf2a49704d16aee449cb` | 第 2107 至 2119 行包含标题、发布日期、单芯片句和系统句。 |
| `A10-neuroncore-v4-v2.30.0-2026-08-13.html` | 211890 | `2ab8e86e39a059e611cfca5bcdcc6b5c5b3acb8077e7006fd515d3543146a45a` | 第 1917 至 1926 行；版本 v2.30.0。 |

## `latest`、v2.31.0 与截止日

A01 两份文件的整页哈希不同，但提取出的 `<article class="bd-article" role="main">` 块均为 1788 个字符，逐字符相同。A07 两份正文块均为 31435 个字符，逐字符相同。差异位于正文外的 Read the Docs 页面框和导航。两组 `latest` 与 v2.31.0 不能作为两个独立来源计数，稳定定位应使用版本化文件。

Neuron 2.31.0 已由正式来源 `SRC-AWS-TRN2-S12` 固定为 2026-07-08 发布，早于 2026-08-12 截止日。A01 和 A07 的版本化页面又通过 `readthedocs-version-slug` 及指向 v2.31.0 标签的编辑链接确认版本身份。A02、A03、A04、A05、A06 和 A10 也各自绑定版本 slug 或版本标签；这些页面的相关原文已在第一波于 2026-08-12 形成断言或实现待办。

11 份本地 HTML 的获取日期仍是 2026-08-13。它们可以作为截止日前版本或定日事件的后续固定件，不能标成 2026-08-12 的字节快照。A08 页面标注 2025-12-02，后一天抓取可以固定所见正文，却不能单独证明页面在截止日后的 24 小时内没有改写。涉及“截至 2026-08-12 当前可用”的事实，仍要引用第一波 2026-08-12 的来源核对记录或另有对象匹配的截止日证据。

`source-freeze-register.csv` 对 9 个既有主入口使用 `enrich_existing_endpoint_after_copy`。正式主入口已经登记 `access_date=2026-08-12`，直接挂接 2026-08-13 文件会混淆访问记录。总控应保留原主入口，另建 `web_snapshot` endpoint，写明 `access_date` 和 `snapshot_date` 都为 2026-08-13；A01、A07 的版本化快照可以作为首选入口。搬运后再核对大小和哈希。这个修正完成前，来源冻结门保持未关闭。

## 仍不得承载的事实

四个预留对象不能承载下列内容：

| 类别 | 暂不允许写入的内容 |
|---|---|
| 物理构造 | 单裸片、裸片数量、芯粒数量、封装基板、封装外形、订货料号及 `package_contains_die` 关系。 |
| 实例和系统下放 | Inf1/Trn1 的 16 颗、Inf2 的最多 12 颗、Trn3 UltraServer 的最多 144 颗，以及 20.7 TB、706 TB/s、EFA（Elastic Fabric Adapter，弹性网络适配器）、机架或集群拓扑。 |
| 供货状态 | Inf1、Trainium1、Inferentia2 单芯片的当前供货或退役状态；Trainium3 芯片作为独立可订购产品的一般可用状态。A08 直接宣布的是 Trn3 UltraServer。 |
| 未处理分歧 | Trainium1 和 Inferentia2 的 820 GiB/s 与 820 GB/s；Trainium3 的 4.9 与 4.7 TB/s、16 与 20 个 CC-Core、144 GiB 与 144 GB。原标签必须保留，不能先换算后选一个值。 |
| 未固定口径 | A06 的 2517 TFLOP/s（每秒万亿次浮点运算）与 A08 的 2.52 PFLOP/s（每秒千万亿次浮点运算）在格式和显示精度未对齐前不能合并；NeuronLink-v4 的方向、线路速率与有效载荷也不能补猜。 |
| 来源独立性 | A01、A07 的 `latest` 和 v2.31.0 正文相同，不增加来源数；A07 与 A10 是否都进入最小集要等事实形成后反向移除。 |

A05、A06 页首的“适用实例”提示与正文对象名不完全一致。卡片和断言使用正文的 chip、device 和 NeuronCore 句，不用页框提示扩张适用范围。图像、样式表和脚本没有完整归档；后续若要使用图中独有信息，须先固定对应资源。

## 预留与开工顺序

总控可以据此关闭身份研究门，执行顺序仍要保持：先补四行范围裁决，再按 `needs_resolution` 追加四个对象和四条关系；随后把 11 份文件复制为 2026-08-13 快照，并按新的 endpoint 记录登记；最后才允许事实代理处置 23 条待办。实现事实形成后要新建本包 selection run，重跑 A01 至 A10 的筛选和反向移除。

复核结束时只读重跑正式数据校验，32 张表通过 91,190 项检查；注册表仍为 323 列和 488 个枚举值。

本复核只改变了独立裁决记录。根 `README.md` 和 `AGENTS.md` 已检查；在总控尚未接受并写入正式预留前，项目计数、目录职责和长期约定没有变化，无需由本复核修改。