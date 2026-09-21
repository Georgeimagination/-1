# M2 第二波物理实现层准备度审计

> 状态：`completed / ready_for_parent_review`  
> 审计日期：2026-08-13  
> 资料截止日：2026-08-12  
> 写入边界：本审计只写本交接文件，没有修改正式结构化数据表、资料卡、进度、README、AGENTS 或研究计划。

## 术语

AWS 指 Amazon Web Services（亚马逊云服务）；GA 指 Google/AWS 架构工作包，NA 指 NVIDIA/AMD 架构工作包，GHC 指 Groq/华为/寒武纪架构工作包。`package` 是正式数据模型中的封装层对象，SKU（Stock Keeping Unit）指具体产品配置，ID（identifier）表示标识符，OAM（OCP Accelerator Module）指开放计算项目加速器模组。

NCv1、NCv2、NCv4 分别指 NeuronCore v1、v2、v4；NKI（Neuron Kernel Interface）是 AWS Neuron 的自定义内核接口；HBM（High Bandwidth Memory）是高带宽存储器；DMA（Direct Memory Access）是直接存储器访问；DRAM（Dynamic Random-Access Memory）是动态随机存取存储器；SBUF 是状态缓冲区，PSUM 是部分和缓冲区，CC-Core 是集体通信核。FP 与 INT 分别表示浮点和整数格式，BF16 是 bfloat16，TF32 是 TensorFloat-32，MXFP 是带共享尺度的微缩放浮点格式。`GB`、`TB/s` 使用十进制单位，`GiB`、`GiB/s` 使用二进制单位，不能互换标签。

取证记录中的 HTTP 指超文本传输协议，HTML 指超文本标记语言，PDF 指便携文档格式，SHA-256 指 256 位安全散列算法，MIME 指媒体类型，SDK 指软件开发工具包。WAIC 是世界人工智能大会，NV-HBI 指 NVIDIA 高带宽裸片互联。

## 启动建议

第二波物理实现层建议先启动 `M2-A-PACKAGE`（AWS 封装层工作包），范围限定为 Inferentia1、Trainium1、Inferentia2、Trainium2 和 Trainium3 五个单芯片或封装对象。Trainium2 已有正式 `package` 对象、关系和事实，只负责校准对象边界并拆出面向读者的物理卡；其余四个对象需要由总控先预留。这个包可承接第一波 GA 架构包留下的 24 条实现层待办，其中 23 条会形成新事实，`DEF-M2GA-ATRN2-01` 只复用既有事实。

推荐它先做，原因在现有数据里可以直接核对：对象命名能够沿用 Trainium2 的正式模式，四个目标架构对象已经冻结，定量待办和一手 AWS 来源已经逐条登记。NVIDIA GH100/H100 的物理事实已经较完整，新增待办很少；Ascend 950、MLU590 和三个 AMD 产品对象虽然已经建好身份，当前仍缺对象匹配的固定物理规格或可承接的第一波待办。

## 已核输入与口径

本审计完整读取了根目录 `AGENTS.md`、三份 M2 批次计划、`审计/M2_对象范围验收.md`、`审计/M2_对象范围映射.csv`、正式 `数据/objects.csv`、正式 `数据/object-relations.csv`，以及三份 `审计/M2-*-ARCH_实现对象待办.csv`。还核对了正式事实、组件、精度路径、链接、特殊能力、来源、入口、筛选和完整度表，用于复算现有对象的事实与来源覆盖。

总控在 2026-08-13 修正了 `数据/objects.csv` 中 20 个第一波架构对象的陈旧说明，也清理了 GA/NA selection run 的陈旧说明。本审计读取的是修正后的当前文件；对象 ID、对象类型、复核状态、运行 ID 和成员数没有变化。

这里的“物理实现层”只包括 `die`、`chiplet`、`package`、`module` 和 `card`。服务器、机架、云实例和 Pod 的聚合数值不能下沉。架构事实只作为机制背景，通过 `implements_architecture` 关系复用，不复制成物理对象事实。

## 正式物理对象与架构关系

正式库当前有 14 个上述层级的对象。表中的“无直接关系”不等于可以补关系；其中几项是范围验收明确保留的未决状态。

| 正式对象 | 类型与状态 | 已有关系 | 本审计判断 |
|---|---|---|---|
| `OBJ-NVIDIA-GH100-DIE` | `die / reviewed` | H100 通过 `OREL-NVIDIA-H100-SXM5-CONTAINS-GH100` 包含该裸片；GH100 自身没有直接 `implements_architecture` | 物理事实已有 3 条，保留现状；不能把 H100 模组值移到裸片 |
| `OBJ-NVIDIA-H100-SXM5-80GB` | `module / reviewed` | `OREL-NVIDIA-H100-IMPLEMENTS-HOPPER`；另包含 GH100 | 已有 64 条实现事实、3 个入选且固定的主要来源，第一波 NA 没有新增 GH100/H100 待办 |
| `OBJ-AWS-TRAINIUM2-CHIP` | `package / reviewed` | `OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH` | 已有 93 条直接归属该 package 的正式事实；GA 复用图为 110 行、109 个唯一 `fact_id`，适合作为第二波校准对象 |
| `OBJ-CAMBRICON-MLU590-CHIP` | `package / reviewed` | `OREL-CAMBRICON-MLU590-IMPLEMENTS-ARCH` | 只有 6 条正式事实，主要是身份、2022 年状态和软件目标；物理规格仍缺 |
| `OBJ-CAMBRICON-MLU590-H8`、`OBJ-CAMBRICON-MLU590-M9` | `card / needs_resolution` | 没有到 MLU590 package 或架构的正式关系 | CNToolkit 正文不可访问，不能从名称建立包含关系或推断芯片数量 |
| `OBJ-NVIDIA-L20`、`OBJ-NVIDIA-L2` | `card / reviewed` | 分别由 `OREL-NVIDIA-L20-IMPLEMENTS-ADA`、`OREL-NVIDIA-L2-IMPLEMENTS-ADA` 关联 Ada Lovelace | 身份与架构关系已固定，当前不属于首选物理包 |
| `OBJ-AMD-MI308X` | `module / reviewed` | 无直接架构关系 | 范围验收明确暂不关联 CDNA 3，必须继续保持 |
| `OBJ-AMD-MI350P` | `card / reviewed` | `OREL-AMD-MI350P-IMPLEMENTS-CDNA4` | 架构关系可复用，产品层固定规格仍需补取 |
| `OBJ-AMD-MI455X` | `module / reviewed` | `OREL-AMD-MI455X-IMPLEMENTS-CDNA5` | 截止日仍是 announced 对象，不能从 Helios 的 72 加速器聚合配置反推单模组值 |
| `OBJ-HUAWEI-ASCEND-950-DIE` | `die / reviewed` | 被 950PR、950DT 两个 package 包含；没有已确认的架构代际关系 | 目前没有正式事实，等待对象匹配的裸片资料 |
| `OBJ-HUAWEI-ASCEND-950PR`、`OBJ-HUAWEI-ASCEND-950DT` | `package / reviewed` | `OREL-HUAWEI-950PR-CONTAINS-950-DIE`、`OREL-HUAWEI-950DT-CONTAINS-950-DIE` | 两个封装继续分开；Atlas 350、Atlas 950 系统值均不得下沉 |

## 候选准备度比较

| 候选范围 | 身份与关系 | 可承接待办 | 固定证据情况 | 启动判断 |
|---|---|---:|---|---|
| NVIDIA GH100/H100 | 对象、Hopper 关系和包含关系均已存在 | 第一波 NA 没有 GH100/H100 新待办 | 白皮书、数据表和 Hot Chips 固定资料已经在本地 | 可用作边界样例，单独开新包的增量很小 |
| AWS Trainium2 | package 与架构关系已存在 | `DEF-M2GA-ATRN2-01` 复用 109 个唯一事实 | 15 个 Trainium2 快照已固定，正式实现事实链完整 | 最适合作为同厂商 package 模板，不重复抽取 |
| AWS Inferentia1、Trainium1、Inferentia2、Trainium3 | 四个架构对象已存在；四个 package 尚未建 | 23 条新事实候选，定量字段集中 | 9 个一手来源已登记且截止日可访问，当前均没有本地快照 | 准备度最高；先固定来源，再抽取并建冲突组 |
| NVIDIA Blackwell、Rubin 与 GB200 | 架构对象存在，物理 package 或 GB200 module 尚未冻结 | NA 有 9 条待办 | Blackwell 固定白皮书已在本地；Rubin 是截止日观察页 | 可做下一物理包。Blackwell 两裸片 package 的正式产品边界、Rubin 的未来实现和 GB200 module 仍需分开裁决 |
| 华为 Ascend 950 | die、950PR、950DT 与两条包含关系已存在 | GHC 待办只覆盖初代 Da Vinci 或 Ascend-Max 配置，没有 950 可直接承接值 | 2026 产品页动态性高，缺对象匹配的固定规格 | 暂缓；先补 950PR/950DT 固定手册或原厂规格 |
| 寒武纪 MLU590 | package 和 MLUarch05 关系已存在 | GHC 待办没有可安全转入 MLU590 的新定量值 | WAIC 快照和固定源码提交只能支撑身份、历史状态与软件目标；CNToolkit HTTP 401 | 暂缓；不使用搜索摘要或 H8/M9 名称补规格 |
| AMD MI308X、MI350P、MI455X | 三个产品层对象已存在；后两项架构关系已固定 | NA 的 9 条待办都不指向 AMD 产品对象 | 四份 CDNA 白皮书已固定，但主要覆盖架构；产品规格仍依赖网页 | 可排在 AWS 后；先取得对象匹配的产品简报、规格库或手册 |

## `M2-A-PACKAGE` 对象与关系预留

Trainium2 继续复用既有对象，不增加重复对象。其余四个建议使用以下 ID；当前正式表复算没有对象或关系 ID 碰撞。

| 处理 | 对象 ID | 对象类型 | 架构对象 | 关系 ID 与方向 |
|---|---|---|---|---|
| 新建 | `OBJ-AWS-INFERENTIA1-CHIP` | `package` | `OBJ-AWS-INFERENTIA1-ARCH` | `OREL-AWS-INFERENTIA1-CHIP-IMPLEMENTS-ARCH`：chip → `implements_architecture` → architecture |
| 新建 | `OBJ-AWS-TRAINIUM1-CHIP` | `package` | `OBJ-AWS-TRAINIUM1-ARCH` | `OREL-AWS-TRAINIUM1-CHIP-IMPLEMENTS-ARCH`：chip → `implements_architecture` → architecture |
| 新建 | `OBJ-AWS-INFERENTIA2-CHIP` | `package` | `OBJ-AWS-INFERENTIA2-ARCH` | `OREL-AWS-INFERENTIA2-CHIP-IMPLEMENTS-ARCH`：chip → `implements_architecture` → architecture |
| 复用 | `OBJ-AWS-TRAINIUM2-CHIP` | `package` | `OBJ-AWS-TRAINIUM2-ARCH` | 复用 `OREL-AWS-TRAINIUM2-IMPLEMENTS-ARCH` |
| 新建 | `OBJ-AWS-TRAINIUM3-CHIP` | `package` | `OBJ-AWS-TRAINIUM3-ARCH` | `OREL-AWS-TRAINIUM3-CHIP-IMPLEMENTS-ARCH`：chip → `implements_architecture` → architecture |

这四个新关系只表达实现归属。Inf1、Trn1、Inf2、Trn3 云实例的设备数、总内存或系统带宽仍放在后续 instance 或 system 包；当前不建立它们与 package 的数量事实。Trainium4 仍是未来架构观察对象，三条相对量待办继续冻结，直到物理芯片身份和来源条件稳定。

## 待办到对象、架构事实和来源的映射

“架构事实”列只提供可复用的机制或精度上下文。待办中的计数、峰值、容量、带宽、工艺和接口数量仍要形成 package 事实，不能把架构事实改目标对象后复制。

| backlog_id | 目标 package | package 事实 | 可复用的正式架构 fact_id | source_id |
|---|---|---|---|---|
| `DEF-M2GA-AIF1-01` | Inferentia1 | 4 个 NCv1 | `FACT-M2GA-AIF1-EXEC` | `SRC-M2-GA-A01` |
| `DEF-M2GA-AIF1-02` | Inferentia1 | INT8、FP16、BF16 单芯片峰值分别原子化 | `FACT-M2GA-AIF1-I8-IN`、`FACT-M2GA-AIF1-I8-OUT`、`FACT-M2GA-AIF1-FP-IN`、`FACT-M2GA-AIF1-FP-OUT` | `SRC-M2-GA-A01` |
| `DEF-M2GA-AIF1-03` | Inferentia1 | 8 GiB DRAM 与 50 GiB/s 分开 | `FACT-M2GA-AIF1-MEM` 仅作片上软件管理存储背景 | `SRC-M2-GA-A01` |
| `DEF-M2GA-AIF1-04` | Inferentia1 | 每 NCv1 Tensor、Vector、Scalar 吞吐分别保存，频率条件保留缺口 | `FACT-M2GA-AIF1-TENSOR`、`FACT-M2GA-AIF1-VECTOR`、`FACT-M2GA-AIF1-SCALAR` | `SRC-M2-GA-A02` |
| `DEF-M2GA-ATRN1-01` | Trainium1 | 2 个 NCv2 | `FACT-M2GA-ATRN1-EXEC` | `SRC-M2-GA-A03` |
| `DEF-M2GA-ATRN1-02` | Trainium1 | INT8、BF16、FP16、cFP8、TF32、FP32 峰值按精度路径拆分 | `FACT-M2GA-ATRN1-FP-IN`、`FACT-M2GA-ATRN1-FP-ACC`、`FACT-M2GA-ATRN1-CFP8` | `SRC-M2-GA-A03` |
| `DEF-M2GA-ATRN1-03` | Trainium1 | 32 GiB HBM；820 GiB/s 与 820 GB/s 分开取证 | `FACT-M2GA-ATRN1-SBUF`、`FACT-M2GA-ATRN1-DMA` 只说明存储组织 | `SRC-M2-GA-A03`、`SRC-M2-GA-A05` |
| `DEF-M2GA-ATRN1-04` | Trainium1 | 1 TB/s DMA 聚合带宽、32 个 DMA 引擎分开 | `FACT-M2GA-ATRN1-DMA` | `SRC-M2-GA-A03`、`SRC-M2-GA-A05` |
| `DEF-M2GA-ATRN1-05` | Trainium1 | 4 个 NeuronLink-v2 接口 | `FACT-M2GA-ATRN1-NL` | `SRC-M2-GA-A05` |
| `DEF-M2GA-AIF2-01` | Inferentia2 | 2 个 NCv2 | `FACT-M2GA-AIF2-EXEC` | `SRC-M2-GA-A04` |
| `DEF-M2GA-AIF2-02` | Inferentia2 | INT8、BF16、FP16、cFP8、TF32、FP32 峰值按精度路径拆分 | `FACT-M2GA-AIF2-FP-IN`、`FACT-M2GA-AIF2-FP-ACC`、`FACT-M2GA-AIF2-CFP8` | `SRC-M2-GA-A04` |
| `DEF-M2GA-AIF2-03` | Inferentia2 | 32 GiB HBM；820 GiB/s 与 820 GB/s 分开取证 | `FACT-M2GA-AIF2-SBUF`、`FACT-M2GA-AIF2-DMA` 只说明存储组织 | `SRC-M2-GA-A04`、`SRC-M2-GA-A05` |
| `DEF-M2GA-AIF2-04` | Inferentia2 | 1 TB/s DMA 聚合带宽、32 个 DMA 引擎分开 | `FACT-M2GA-AIF2-DMA` | `SRC-M2-GA-A05` |
| `DEF-M2GA-AIF2-05` | Inferentia2 | 2 个 NeuronLink-v2 接口 | `FACT-M2GA-AIF2-NL` | `SRC-M2-GA-A05` |
| `DEF-M2GA-ATRN2-01` | Trainium2 | 不新建事实；复用 `trainium2_existing_reuse_map.csv` 的 110 行、109 个唯一事实 | `FACT-AWS-TRN2-CAP-SPARSE-MATMUL-LEVEL`、`FACT-AWS-TRN2-CAP-TENSOR-TRANSPOSE-LEVEL`、`FACT-AWS-TRN2-CAP-DMA-TRANSPOSE-LEVEL`、`FACT-AWS-TRN2-CAP-VECTOR-REDUCTION-LEVEL`、`FACT-AWS-TRN2-CAP-SCALAR-NONLINEAR-LEVEL`、`FACT-AWS-TRN2-CAP-GPSIMD-CUSTOM-LEVEL`、`FACT-AWS-TRN2-CAP-DGE-DESCRIPTOR-LEVEL`、`FACT-AWS-TRN2-CAP-COLLECTIVE-HW-LEVEL`、`FACT-AWS-TRN2-CAP-COLLECTIVE-NKI-LEVEL`、`FACT-AWS-TRN2-CAP-TOPK-NKI-LEVEL`、`FACT-AWS-TRN2-CAP-MOE-NKI-LEVEL`、`FACT-AWS-TRN2-CAP-DMA-COMPRESS-LEVEL`、`FACT-AWS-TRN2-CAP-DMA-DECOMPRESS-LEVEL`、`FACT-AWS-TRN2-ARCH-SW-RUNTIME`、`FACT-AWS-TRN2-ARCH-SW-MODEL`、`FACT-AWS-TRN2-ARCH-RELEASE-DATE` | `SRC-AWS-TRN2-S01` 至 `SRC-AWS-TRN2-S14` 按既有断言复用；物理事实当前实际涉及 6 个 selected 来源 |
| `DEF-M2GA-ATRN3-01` | Trainium3 | 8 个 NCv4 | `FACT-M2GA-ATRN3-EXEC` | `SRC-M2-GA-A06` |
| `DEF-M2GA-ATRN3-02` | Trainium3 | MXFP8、MXFP4、BF16、FP16、TF32、FP32 和结构化稀疏峰值分开 | `FACT-M2GA-ATRN3-MX-IN`、`FACT-M2GA-ATRN3-MX-ACC`、`FACT-M2GA-ATRN3-MX-OUT`、`FACT-M2GA-ATRN3-BF16-ACC` | `SRC-M2-GA-A06` |
| `DEF-M2GA-ATRN3-03` | Trainium3 | 每 NCv4 的 MX、Vector、Scalar 峰值和 Tensor 频率分开 | `FACT-M2GA-ATRN3-TENSOR-SHAPE`、`FACT-M2GA-ATRN3-TENSOR-IO`、`FACT-M2GA-ATRN3-VECTOR`、`FACT-M2GA-ATRN3-SCALAR` | `SRC-M2-GA-A07`、`SRC-M2-GA-A10` |
| `DEF-M2GA-ATRN3-04` | Trainium3 | 每 NCv4 的 32 MiB SBUF 和 2 MiB PSUM 分开 | `FACT-M2GA-ATRN3-SBUF`、`FACT-M2GA-ATRN3-PSUM` | `SRC-M2-GA-A07` |
| `DEF-M2GA-ATRN3-05` | Trainium3 | 144 GiB HBM、4 个 HBM stack；4.9 TB/s 与 4.7 TB/s 进入冲突组 | `FACT-M2GA-ATRN3-SBUF`、`FACT-M2GA-ATRN3-DMA` 只作层次背景 | `SRC-M2-GA-A06`、`SRC-M2-GA-A07`、`SRC-M2-GA-A08` |
| `DEF-M2GA-ATRN3-06` | Trainium3 | 128 个 DMA 引擎与 4.9 TB/s 聚合带宽分开 | `FACT-M2GA-ATRN3-DMA` | `SRC-M2-GA-A06`、`SRC-M2-GA-A07` |
| `DEF-M2GA-ATRN3-07` | Trainium3 | 16 与 20 个 CC-Core 分别进入冲突组 | `FACT-M2GA-ATRN3-COLL` | `SRC-M2-GA-A06`、`SRC-M2-GA-A07` |
| `DEF-M2GA-ATRN3-08` | Trainium3 | 4 个 NeuronLink-v4 接口与 2.56 TB/s 聚合带宽分开；方向和有效载荷留缺口 | `FACT-M2GA-ATRN3-NL` | `SRC-M2-GA-A06`、`SRC-M2-GA-A07` |
| `DEF-M2GA-ATRN3-09` | Trainium3 | 3 nm 工艺与 HBM3e 类型分开 | `FACT-M2GA-ATRN3-STATUS` 只固定截止日状态 | `SRC-M2-GA-A08` |

## 一手证据组合与固定风险

五张 package 卡的候选证据池共有 15 个已登记 `source_id`。Trainium2 物理事实直接复用 `SRC-AWS-TRN2-S01`、`S02`、`S03`、`S04`、`S05` 和 `S10`。其余四个对象使用 9 个来源：

| 作用 | source_id | 当前固定情况与处理 |
|---|---|---|
| Inferentia1 单芯片总量 | `SRC-M2-GA-A01` | 当前筛选为 `redundant_covered`，因为架构包没有保留它的实现值；package 事实加入后它会获得不可替代的 `core_spec` 职责，必须重新进入选择并保存截止日快照 |
| Inferentia1 NCv1 实现 | `SRC-M2-GA-A02` | Neuron 2.9.1 版本化入口，HTTP 200；没有本地快照，先固定 HTML 与哈希 |
| Trainium1 总量 | `SRC-M2-GA-A03` | Neuron 2.26.1 版本化入口，HTTP 200；先固定本地副本 |
| Inferentia2 总量 | `SRC-M2-GA-A04` | Neuron 2.29.1 版本化入口，HTTP 200；先固定本地副本 |
| NCv2 共同实现与冲突值 | `SRC-M2-GA-A05` | Neuron 2.29.1 版本化入口；同时支撑 Trainium1 与 Inferentia2，但事实目标必须分开 |
| Trainium3 芯片总量 | `SRC-M2-GA-A06` | 入口固定到 2.28.1，来源标签写作 2.28.1/2.29 family；保存时须把实际版本拆清，不能把两版内容并成同一断言 |
| Trainium3 NKI 实现 | `SRC-M2-GA-A07` | `latest` 动态入口，当前为 `dynamic_unfrozen`；这是最高版本漂移风险，必须改用截止日快照或可定位版本，并保留页面版本 |
| Trainium3 工艺、HBM 类型与状态 | `SRC-M2-GA-A08` | 2025-12-02 带日期的一手公告，HTTP 200；页面仍可改写，保存快照和哈希 |
| NCv4 补充实现 | `SRC-M2-GA-A10` | Neuron 2.30.0 版本化入口；先固定本地副本，再做反向移除测试 |

这 9 个 GA 来源目前都没有 `local_path`。因此开工顺序必须是固定版本和快照在前，事实抽取在后。本包不需要增加 PDF；HTML 快照也不会改变 111 份本地 PDF 的资料池基线。新增 endpoint 仍要登记 SHA-256、访问日、快照日和 MIME 字段，并通过正式数据校验器的本地路径与哈希检查。

## 事实、卡片与来源预算

| 产物 | 预算 | 说明 |
|---|---:|---|
| 面向读者的 package 卡 | 5 张 | Inferentia1、Trainium1、Inferentia2、Trainium2、Trainium3；Trainium2 从综合试填卡拆出物理视图，不复制正式事实 |
| 新正式对象 | 4 个 | Trainium2 已存在 |
| 新正式关系 | 4 条 | 均为 package 到已冻结架构的 `implements_architecture` |
| 新事实 | 约 60 至 70 条 | 23 条待办需要按数据格式、容量/带宽、数量/速率和冲突值原子化；Trainium2 不增加重复事实 |
| 新完整度记录 | 36 行 | 四个新对象各 9 个领域；Trainium2 复用既有 9 行并按需要更新，不新建第二套 |
| 候选来源 | 15 个 `source_id` | Trainium2 6 个物理事实来源，加上四个新对象的 9 个来源；最终 selected 数量由全包反向移除测试决定 |
| 冲突组 | 至少 4 组 | Trainium1 HBM 820 GiB/s 对 820 GB/s；Inferentia2 同一单位标签冲突；Trainium3 HBM 4.9 对 4.7 TB/s；Trainium3 CC-Core 16 对 20 |

旧版 Trainium1 的 420 INT8 值已经在待办中标为被当前 380 值取代，按版本关系处理，不再造一个未解决冲突。Inferentia1 每 NCv1 吞吐的频率条件不完整，应保存来源限定与缺口，不能补推频率。Trainium3 NeuronLink-v4 的方向和有效载荷也保持缺失状态。

## 独立验收门

这个工作包进入正式表前，应由非初稿作者完成一次独立复核，重点检查五件事。对象门核对四个新 package 的一手身份和四条关系方向，不接受实例总量反除。事实门逐条覆盖 24 个 backlog_id，并确认 23 条新待办全部拆成原子事实；Trainium2 的 109 个唯一事实只能引用，不能复制。冲突门核对上述四组互斥值、单位换算和版本条件，旧版取代值与同时存在的冲突分开处理。来源门确认 9 个 GA 网页已经固定，`SRC-M2-GA-A01` 因 package 新事实重新进入候选最小集，并对 15 个候选来源运行反向移除测试。交付门要求 5 张卡的九域状态齐全、卡内 fact_id 可回到正式表，临时合并和正式合并都通过 `Validate-ResearchData.ps1`；若只新增 HTML 快照，`Test-SourcePool.ps1` 的 111 PDF 基线应保持不变。

验收抽查不能只看总数。至少逐一复算 Inferentia1 三种精度峰值、Trainium1 和 Inferentia2 的六条精度路径、Trainium3 的七类峰值路径，以及所有 GB/GiB、TB/s、GiB/s 单位。package 卡只能写单器件数据，Trn1/Inf2/Trn3 实例、UltraServer 和机架值留到后续包。

## 暂冻结与后续顺序

`DEF-M2GA-ATRN4-01` 至 `03` 暂冻结。它们只有相对 Trainium3 的倍数，当前没有正式 Trainium4 package 身份，不能据此推绝对峰值、绝对带宽或绝对容量。

NVIDIA 下一物理包可处理 `BACKLOG-M2NA-001` 至 `003` 的 Blackwell 两裸片 package，但需先固定该 package 与 B200/GB200 的产品边界。`BACKLOG-M2NA-004`、`005`、`009` 属于 Rubin 未来双裸片实现，继续按观察对象处理；`BACKLOG-M2NA-006` 至 `008` 需要独立 GB200 module，不能和通用 Blackwell package 合并。

Ascend 950、MLU590 和 AMD 三个已预留产品对象维持当前正式身份。Ascend 950 等对象匹配的 950PR/950DT 固定资料；MLU590 等 CNToolkit 正文和 H8/M9 手册；AMD 等 MI308X、MI350P、MI455X 的固定产品规格。解除条件满足前，不从系统、架构白皮书、软件支持矩阵或相邻 SKU 补物理数值。

## 验证与写入记录

本审计只新增并更新了 `审计/子代理交接/m2_wave2_physical_readiness.md`。没有修改正式数据、资料卡或全局状态文件。

只读复算确认：正式物理对象 14 个；推荐 ID 与正式对象、关系均无碰撞；GA 的 AWS 实现待办中，五个 package 范围共有 24 行，其中 Trainium2 复用图为 110 行、109 个唯一 `fact_id`。一次统计命令把 statement-form `foreach` 直接接到管道，PowerShell 报 `EmptyPipeElement`。这是命令构造的操作错误，命令没有写文件；改成先物化数组、再排序后得到上述计数。一次文档换行插入也曾被写成字面转义标记，写后读取时发现并立即修正。另有两条只读检查命令因联合正则括号未闭合、字符串插值括号不完整而失败，改用分步的 .NET 字符检查后确认替换字符、长破折号、字面换行标记和禁用公式分隔符均为 0。上述情况都属于命令或写入构造的操作错误，没有改动正式数据，也不是沙箱、审批、远端服务或工具运行故障。`report-humanizer` 机器扫描未发现可识别的 AI 痕迹。随后按 `shuorenhua` 的 `docs` 场景做了最小幅度保真回读，核对了对象 ID、关系方向、24 个 backlog_id、109 个唯一事实、来源数量、版本、状态和单位；标题、首段、表格引导和结尾没有发现需要继续改写的模板腔。没有可供模仿的人类样稿，剩余风险来自执行包后续取得的新证据，不是文档语气。