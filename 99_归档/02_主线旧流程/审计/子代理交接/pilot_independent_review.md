# 三张 M1 试填资料卡独立复核

> 复核日期：2026-08-12  
> 任务状态：`complete`  
> 复核范围：三张试填卡、对应 source_prep / pilot 交接、`研究计划.md`、`资料卡/字段字典.md`、`资料卡/模板.md`、`数据/enums.csv`、`数据/schema-columns.csv`，以及复核期间由总控补入的修正记录和 H100 结构化 staging。  
> 写入边界：本次只写本文件；没有修改资料卡、全局 CSV、README、AGENTS 或进度文件。

## 结论

三张草稿目前还不能作为一个整体通过 M1，但需要修改的重点已经很集中。H100 的大部分关键规格、来源版本和派生计算已经形成结构化候选，主要剩下对象层级、单位写法、时钟条件和来源筛选细节。Trainium2 的主要数值可以回到 AWS 官方固定版本，真正需要处理的是每核值与芯片聚合值之间尚未解释的汇聚口径，以及若干命名、单位和动态状态问题。MLU590 的处理原则最稳妥，没有把第三方规格或软件接口误写成硬件能力；它的主要阻碍是两份关键开发文档仍未完整取得，却已经在卡中承担了确认性证据角色。

复核期间，总控已经关闭三项早先暴露的问题：字段字典与正式枚举已对齐；Trainium2 正式对象 ID、`cloud_instance` 类型和来源/实现层级枚举已规范；H100 白皮书 v1.04 的官方固定 PDF 已取得并登记。因此，下文把这些问题列入“已关闭”，不再作为当前阻断。

派生公式本身没有发现算术错误。H100 的 19.97、147.67、295.34、590.72、10.00，以及 Trainium2 的 447.9、230.0、62.4、883.8，均与卡内输入相符。H100 staging 现有七条对应派生事实和十四条输入关系；Trainium2 仍需要用同样方式落入正式派生表。

## 阻断

| 编号 | 文件与具体位置 | 审查发现 | 理由 | 建议修正 |
|---|---|---|---|---|
| B-01 | `资料卡/NVIDIA/产品/H100_SXM5_80GB_试填草稿.md` §1 第 11 行、§2“裸片工艺、晶体管、面积”；`数据/objects.csv`；`审计/子代理交接/h100_structured_staging/README.md` | 卡片仍展示 TSMC 4N、800 亿晶体管和 814 mm²，但明确说它们属于 GH100 裸片；正式对象表目前只有 Hopper 架构和 H100 SXM 模组，没有 GH100 裸片对象。H100 staging 已正确地没有导入这三项。 | 每条规范事实只能指向一个正式对象。把裸片事实导入模组会造成层级错误；没有裸片对象时又无法为这三项建立合法目标外键。 | 两种做法任选其一：建立 `OBJ-NVIDIA-GH100-DIE` 及 `package_contains_die` 或合适关系，再把三项事实归到裸片；或者在 M1 阶段只保留边界说明，不把该表项当作本卡规格字段。 |
| B-02 | `资料卡/AWS/Trainium2_试填草稿.md` §2.2“Tensor Engine”、§9 冲突 001；`审计/子代理交接/trainium2_pilot.md`“未解决冲突”第 1 项；`审计/子代理交接/trainium2_root_spotcheck.md`“抽查结果” | 同一 Neuron 2.29.1 文档集直接给出每核 158/79/20/316 TFLOPS，也直接给出芯片 1,299/667/181/2,563 TFLOPS。两组直接断言都应保留；真正未解决的是从每核到整芯片的汇聚条件。卡中的 8 倍值是公开数据的算术派生，不是第三条厂商直接规格。 | 每核值与芯片值的对象和作用域不同，不能因为 8 倍结果不等于芯片表就简单写成同对象数值冲突；但差异也不能删掉，因为同版文档确实没有解释全核并发、频率或预留资源。向量 8.0 和标量 9.6 TFLOPS 同样缺少芯片并发证据。 | 保留两组直接断言。8 倍结果单独写成 `derived`，并将 `aggregation_validity=unresolved`；冲突组宜表述为 `scope_disagreement` 或“聚合规则待解释”，不要让派生值覆盖芯片直值。正式芯片向量/标量峰值在汇聚条件核实前保持 `pending_verification` 或不生成。 |
| B-03 | `资料卡/寒武纪/MLU590_试填草稿.md` §1 第 13、20 至 21 行，§2 第 29 至 37 行，§3 第 45 至 49 行，§4 第 55 行，§5 第 76 至 77 行；`审计/子代理交接/mlu590_source_prep.md`；`最小参考资料库/sources.csv`、`source-screening.csv`、`source-endpoints.csv` | CNToolkit 3.8.4 和 CNNL 1.23.2 在正式记录中仍为 `inaccessible`、`partially_read`、`pending`、`needs_resolution`。卡片却把搜索索引片段写成了已确认的对象层级、目标映射、软件首个支持版本和算子限制，并把两者计入“三份来源的当前最小组合”。 | 研究计划明确规定，无法打开或尚未完整读取正文的来源不能支撑关键事实。搜索索引可能省略表头、脚注或限定条件；MLU590 又恰好是对象层级和单位最容易误读的低披露样本。 | 取得同版本固定副本并核对相关表格/条目之前，把依赖两份文档的字段改为 `inaccessible_evidence` 或 `pending_verification`；筛选状态继续 `pending`，不能写成已选最小集。WAIC 来源可继续承担 2022 年身份、当时“在研”状态和 `MLUarch05` 关系。 |
| B-04 | 三张卡与正式表的整体验收；`数据/facts.csv`、`field-requirements.csv`、`最小参考资料库/fact-assertions.csv` 当前全局表；H100 staging | 全局正式事实、字段要求和逐来源断言仍为空；H100 已有 staging，Trainium2 和 MLU590 尚未形成同等的正式候选链。资料卡中的 S1、S2、C590-S1 等只是卡内工作编号。 | `研究计划.md` §3、§5.2 和 M1 验收条件要求关键事实由 `fact_id` 回到来源版本、访问入口和原文定位。人读表格有页码并不等于正式证据链已经进入可校验数据模型。 | 先验收并合并 H100 staging，再为 Trainium2 与可合法取证的 MLU590 事实建立正式来源、事实、断言、字段要求和搜索日志。三张卡同步引用正式 `fact_id`；结构化校验通过后再判 M1。 |

## 应修

### H100

| 编号 | 文件与具体位置 | 审查发现 | 建议修正 |
|---|---|---|---|
| H-01 | H100 卡 §4“寄存器文件” | `65,536 × 32 bit = 262,144 byte = 256 KiB`，不是按项目默认十进制含义的 256 KB。132 个 SM 的简单总量是 34,603,008 byte，即 33 MiB 或 33,792 KiB；而且这些寄存器按 SM 分布，不能写成一个全 GPU 共享池。 | 卡片原文可保留厂商“KB”写法，但规范值用 byte，并写 `pooling_mode=distributed_not_pooled`。如果展示整卡算术和，注明它是分布式容量汇总，不代表可统一寻址或共享。H100 staging 当前只保留每 SM 的 262,144 byte，方向正确。 |
| H-02 | H100 卡 §3.2 第 51 至 59 行；staging `condition-sets.csv` 中 FP16 CUDA、BF16 CUDA、INT32 CUDA 条件 | 卡片列出 FP16/BF16/INT32 非 Tensor 峰值，却只为 FP32/FP64 非 Tensor 路径写出 1,980 MHz。对应 staging 条件的频率也为空，但 fingerprint 尾部仍带 `|MHz`。 | 不能从邻近路径补频率。应从 Table 3 为这三条逐项取出适用时钟；若表中没有明确绑定，就把频率状态写成 `not_found`，并移除 fingerprint 中无值的 `MHz` 占位。 |
| H-03 | H100 卡 §5 NVLink/PCIe 表；staging `condition-sets.csv` | 方向和聚合范围已经写清，但人读卡没有说 900 GB/s、64/128 GB/s 属于线路、协议载荷还是厂商铭牌口径。staging 已使用 `traffic_basis=vendor_nameplate`。 | 把该口径同步回资料卡，并把有效载荷/持续带宽作为独立 `not_found` 要求，避免读者把铭牌峰值理解为应用有效带宽。 |
| H-04 | H100 卡 §8 第 140 行；`数据/enums.csv` 的 `selected_role` | `programming_limit` 不是正式入选来源角色。 | Tuning Guide 的正式角色只写 `architecture_mechanism`；“编程限制”保留在 rationale 或具体断言的说明中。 |
| H-05 | H100 卡 §8 第 134、143 行；staging `source-screening.csv` | “四者角色不重叠”和产品网页“基本重复”的判断还没有完整事实覆盖矩阵。staging 已把 IEEE Micro 记为 `redundant_covered`，但备注也承认全局合并前必须补 `source-coverage`。动态产品页还可能承担当前产品状态，而这不是静态数据手册的等价覆盖。 | 入库前为 IEEE Micro 建 `fully_covered` 关系。H100 产品页在供货/当前状态字段尚未完成前保持 `pending` 或 `lead_only`，不要先判规格冗余后连状态入口一起排除。H800 微基准对本 SKU 数值可继续 `out_of_scope`；是否用于 Hopper 架构对象以后单独审。 |
| H-06 | H100 卡 §9；H100 staging 仍含旧白皮书缺口记录 | 官方 v1.04 固定 PDF 已取得，但 staging 的 `field-requirements.csv` 仍有 `REQ-NVIDIA-H100-WHITEPAPER-FIXED=pending_verification`，部分 condition/notes 仍写“不可复现”或“待登记固定副本”。 | 删除或关闭该要求，并统一清理旧备注。应使用 71 页固定文件和 SHA-256 `3641614979809a027a8aabdc2e77639efb8fcd0f8dc7873a22ba2125489f5a27`。 |
| H-07 | H100 卡 §1、§9；模板 §1 身份表 | 卡片仍未给出精确首次可用日期和当前产品状态；staging 已正确记 `pending_verification`。 | 在 M1 完整度中明确 identity 为 `partial`，不要因架构规格完整而把产品身份域判为完成。 |
| H-08 | H100 卡 §4.1 与 Trainium2 卡 §5 的术语 | H100 把计算峰值/带宽称为“理论屋顶线的算术强度拐点”。更准确的名称是机器平衡或 roofline ridge point（屋顶线脊点）；它是硬件比值，不是工作负载自身的算术强度。 | 全项目统一称“规格机器平衡值”或“屋顶线脊点”，并继续保留“非实测利用率”的限定。 |

### Trainium2

| 编号 | 文件与具体位置 | 审查发现 | 建议修正 |
|---|---|---|---|
| T-01 | Trainium2 卡 §1 第 7 行；S1、S2、S11 的命名断言 | 卡片断言 third-generation NeuronDevice“指 Neuron 设备与核心架构代际”。官方材料确实同时出现“Trainium2 是第三代 purpose-built ML chip”“third-generation NeuronDevices: Trainium2”以及“第二代 Trainium”等不同说法，但现有证据没有明确把“第三代”唯一归因到核心架构。 | 分别保存厂商原文，建立 `terminology_ambiguity`。可写“Trainium 产品序列通常称第二代；AWS 某些 Neuron 文档另称第三代芯片/NeuronDevice，计数基准未解释”，不要替厂商补一个唯一解释。 |
| T-02 | Trainium2 卡 §4 第 66 行、§7.2 第 125 至 128 行 | S1/S6 使用 GiB，动态产品页部分位置使用 GB；卡片又在同一表中混用 96 GB、1,536 GiB、6,144 GiB。不能把 GB 自动当 GiB，也不能让不同原始单位共同支撑同一规范断言。 | `fact-assertions` 分别保留原值和原单位。规范 96/1,536/6,144 GiB 可由明确使用 GiB 的固定来源支撑；动态页的 GB 表述单独保留，必要时建立 `unit_disagreement`，不做静默换算。S2 的“24 GB bank”也先保留原始标签。 |
| T-03 | Trainium2 卡 §6 第 99 至 106 行 | 转置一行同时写 `dedicated_instruction / configurable_engine`，集体通信一行同时写 `dedicated_physical_module + library_implementation`。正式事实模型要求一个能力、一个实现层级；硬件模块与软件 API 不是同一断言。 | 拆成独立能力事实：Tensor transpose、DMA transpose、CC-Core/NeuronLink 硬件、NKI collectives API 分开。CC-Core 的硬件层级宜使用 `network_offload`；NKI API 使用 `library_implementation`。 |
| T-04 | Trainium2 卡 §6 第 98 至 100 行 | “结构化稀疏”“Attention 数据布局”的实现层级仍带判断成分。官方能证明稀疏模式和 DMA transpose 行为，但未必足以在所有情况下区分 `dedicated_instruction` 与 `configurable_engine`。 | 每个实现层级都要有直接机制断言；证据只说明功能存在时，先 `provisional`，不要因为文档章节名直接推定物理模块。 |
| T-05 | Trainium2 卡 §7.2、§9 冲突 004 和 005 | UltraServer 的 2024 固定状态是 preview；动态页同页出现 available now 与 preview。EFA 则为 3,200 Gbps 与 12.8 Tbps，表头范围不明。当前保留差异是正确的，但分类还应更具体。 | 产品状态用带有效期的状态事实和 `conflicting_unresolved`；EFA 建 `scope_disagreement`。3,200 Gbps 不自动解释成单实例，12.8 Tbps 也不反除为每实例。 |
| T-06 | Trainium2 卡 §9 冲突 003 | 2024 发布材料的 5.2 PFLOPS/chip 与当前 2.563 PFLOPS/chip 差异巨大，但来源日期、版本和稀疏定义未先调和。 | 先按 `version_change` 与 `condition_disagreement` 审查；只有对象、精度、稀疏模式、计数规则和版本均一致时，才升级为同一事实的未解数值冲突。 |
| T-07 | Trainium2 卡 §8.1“冷却、板卡形态” | 一个单元格把独立板卡形态 `not_applicable` 与封装/冷却 `not_found` 合并。 | 按字段和对象拆行：Trainium2 芯片没有独立板卡 SKU，形态字段可 `not_applicable`；芯片/封装功耗可 `not_found`；实例或服务器冷却属于相应系统对象。 |
| T-08 | Trainium2 卡 §11 的 14 个来源候选 | 每个来源都写了独有贡献，但尚无逐事实覆盖矩阵，暂时不能证明 14 份都属于最小集。动态 S7、S13 也只有观察时间，没有固定内容版本。 | 完成 `fact-assertions` 和覆盖矩阵后做反向移除测试。只为保留旧软件状态的 S14，在对应历史字段不入卡时可降级；S7/S13 建网页快照或内容指纹。同一 HTML/RST/PDF 只登记为一个 source 的多个 endpoint。 |
| T-09 | Trainium2 卡 §2 第 28 行、§7 第 113 至 119 行、§8 第 138 至 157 行、§10 | 多处使用 `not_found`，但正式 `field-requirements` 与 `search-log` 尚未建立。 | 将每个缺失字段连接到搜索范围、日期和 `search_id`。不要用卡片的一段“经过官方域名检索”替代逐要求日志。 |

### MLU590

| 编号 | 文件与具体位置 | 审查发现 | 建议修正 |
|---|---|---|---|
| M-01 | MLU590 卡 §2 第 37 行；`最小参考资料库/source-endpoints.csv` | 卡片把两次访问失败都概括为 `Internal Error`；正式 endpoint 记录分别是远端抓取 400 Timeout 和 401 Unauthorized。 | 以 endpoint 表的实际错误为准，分别保留。这样后续才能判断是重试、身份验证还是另找合法固定入口。 |
| M-02 | MLU590 卡 §4 第 55 行；`mlu590_source_prep.md` 的 C590-S4 | 卡片引用官方 MLU-OPS 动态仓库中的 512 KB/512 KB/2048 KB 与样例宏，却在 §2 的来源表和“三份来源最小组合”中没有登记 C590-S4。 | 若保留这段比较，就将 C590-S4 注册为 `pending` 或 `lead_only`，固定具体提交哈希后再做断言；否则暂时从卡片删去这些具体数值。 |
| M-03 | MLU590 卡 §4 第 55 行；`mlu590_source_prep.md`“可确认字段” | `mtp_592.{18}` 的原始记法本身不直观，现有可访问证据不足以判断它是集合、范围还是转义后的目标表达。 | 在固定 CNToolkit 原文前只逐字保存 raw text，不解释 `{18}`，也不据此推导核心数、并行度或虚拟化。 |
| M-04 | MLU590 卡 §5“板卡形态、功耗、冷却” | 本卡对象是芯片/封装。板卡形态和板卡冷却对芯片对象属于对象不适用；芯片或封装功耗仍是应查字段。 | 把板卡字段移到 H8/M9 卡并在芯片卡记 `not_applicable`；芯片/封装功耗保持 `not_found`，不要用第三方板卡数字补齐。 |
| M-05 | MLU590 卡 §6 第 84 行 | 在 CNNL 1.23.2 尚未完整读取时，不能判断旧版 1.14.x 至 1.22.x 页面已被“累积说明”完全覆盖。 | 旧页先保持 `pending`。取得全文并建立 `source-coverage` 后，只有被逐项完整覆盖的来源才能标 `redundant_covered`。 |
| M-06 | MLU590 卡 §3 至 §5 多个 `not_found`；§8 完整度 | 低披露处理方向正确，但全局还没有正式字段要求和搜索日志。卡片的 `missing_public_data` 是完整度状态，不能替代每个字段的 `not_found`。 | 把预审的检索范围拆成正式 `field-requirements` 与 `search-log`。尚未完整读取、但已知可能含证据的字段优先使用 `inaccessible_evidence`，而不是 `not_found`。 |
| M-07 | MLU590 卡 §6 第 66 行 | 80/96/192 GB、300 至 345 TFLOPS、2.0 至 2.7 TB/s、372 GB/s 等第三方数字没有 source ID 或筛选记录，却直接出现在人读卡中。 | 若这些数字继续作为检索线索存在，必须登记对应来源并标 `lead_only`、`rejected_unreliable` 或冲突候选；否则卡片只写“存在互相冲突的第三方口径”，不列孤立数字。 |
| M-08 | MLU590 卡 §8 第 106 行 | “三份一手来源尚缺本地固定副本”已不准确：WAIC 页面可直接读取，真正未解决的是 WAIC 尚无快照，以及 CNToolkit/CNNL 尚不可完整访问。 | 完整度说明拆开写：WAIC 为动态未冻结；CNToolkit/CNNL 为不可访问证据。不要把三者归为同一种缺口。 |

### 模板和结构化规则

| 编号 | 文件与具体位置 | 审查发现 | 建议修正 |
|---|---|---|---|
| S-01 | `资料卡/模板.md` §1 身份表第 21 行、§1.1；`资料卡/字段字典.md` §2.2、`FIELD-ID-ARCH` | 模板要求“架构代际”填 `fact_id`，同时又在关系表用 `implements_architecture`。正式模型中架构关系已由 `object-relations.csv` 承担；若再把关系伪装成普通文本事实，会形成重复真值。 | 决定一种唯一约定：身份表的架构单元引用 `object_relation_id`，或明确 `FIELD-ID-ARCH` 的 relation 值如何在 facts 中合法编码。不要同时维护两套独立关系。 |
| S-02 | `资料卡/模板.md` §12 第 197 至 206 行；`数据/enums.csv` 的 `completeness_domain` | 正式完整度枚举含 `software`，模板表却没有“软件”行；MLU590 卡已自行补了软件，说明模板确实遗漏。H100 和 Trainium2 也没有按统一九域给出完整度表。 | 模板加入软件域，三张卡统一按 identity、physical、compute、numerics、memory、interconnect、special_engines、software、evidence 九域填写。 |
| S-03 | `资料卡/字段字典.md` §5.1；`数据/enums.csv` 的 `component_type` | 字段字典仍使用 `address_control`、`data_movement`、`fixed_function`、`sparse_embedding`、`network_collective`，正式枚举则使用 `control`、`dma`、`async_copy`、`network_offload` 等。 | 像 DEC-011 修正存储与带宽枚举一样，同步这组计算单元类型；如果字典只是在讲概念分类，应明确它不是 `component_type` 的可写值并给映射。 |

## 可后续

| 编号 | 位置 | 后续事项 | 处理边界 |
|---|---|---|---|
| L-01 | H100 卡 §8；H800 两篇微基准 | H800 数值不应进入 H100 SXM5 产品事实，但可能对 Hopper 架构层的缓存、调度或指令机制提供独立验证。 | 等建立架构级测量对象和环境条件后再审，不影响本轮 H100 产品卡。 |
| L-02 | H100 卡 §9 | 精确首供日和当前供货状态仍待固定来源。 | M1 可将身份完整度保留为 `partial`；批量建卡前再补。 |
| L-03 | Trainium2 卡 §8.2、§11 | 2024 与 2026 的 Neuron 软件状态是否都保留，取决于正式卡是否要展示软件演进。 | 先定义需要的历史软件字段，再决定 S12/S14 是否同时进入最小集。 |
| L-04 | MLU590 卡 §6、§7 | 第三方监管文件和论坛设备日志可用来观察型号存在和部署，但不能替代寒武纪规格或供货公告。 | 后续可作为 `independent_validation` 或 `lead_only` 审查；不用于填总算力、HBM、功耗或首供时间。 |
| L-05 | 三张卡 | 片上带宽、持续性能、有效载荷和延迟仍有大量公开缺口。 | 缺口保持为空并记录搜索；只有对象完全匹配、方法可复现的独立测量才进入事实链。 |

## 已关闭项

| 原问题 | 当前状态 | 证据 |
|---|---|---|
| 字段字典的存储层级、带宽方向和流量口径与正式枚举不一致 | 已关闭。字典已改用 `llc`、`onchip_sram`、`per_direction_symmetric`、`raw_line_rate` 等正式值，并新增 DEC-011。 | `资料卡/字段字典.md` §7.1、§8.2；`进度/决策记录.md` DEC-011 |
| Trainium2 使用候选 ID、把 EC2 实例写成 `cloud_accelerator` | 总控已关闭。正式对象已登记为 `OBJ-AWS-TRN2-3XLARGE`、`OBJ-AWS-TRN2-48XLARGE`、`OBJ-AWS-TRN2U-48XLARGE`，类型为 `cloud_instance`。交接中的旧 CAND 表述只作为历史草稿，不应再复制。 | `数据/objects.csv`、`object-relations.csv` |
| Trainium2 草稿中的非正式筛选状态和实现层级值 | 总控已关闭。当前卡片已使用正式 `selected` / `selected_role` 和 `implementation_level` 取值。 | Trainium2 卡 §6、§11；`数据/enums.csv` |
| H100 白皮书 v1.04 官方固定 PDF 缺失 | 已关闭。官方固定文件共 71 页，SHA-256 为 `3641614979809a027a8aabdc2e77639efb8fcd0f8dc7873a22ba2125489f5a27`。 | `审计/子代理交接/h100_whitepaper_acquisition.md`；`清单/论文PDF清单.csv` |

## 派生值复算

| 对象与路径 | 复算 | 结果 | 审查结论 |
|---|---:|---:|---|
| H100 FP64 Tensor | $66.9 / 3.35$ | 19.9701 FLOP/byte | 卡片 19.97，正确 |
| H100 TF32 Tensor | $494.7 / 3.35$ | 147.6716 FLOP/byte | 卡片 147.67，正确 |
| H100 FP16/BF16 Tensor | $989.4 / 3.35$ | 295.3433 FLOP/byte | 卡片 295.34，正确 |
| H100 FP8 Tensor | $1978.9 / 3.35$ | 590.7164 FLOP/byte | 卡片 590.72，正确 |
| H100 FP64 非 Tensor | $33.5 / 3.35$ | 10.0000 FLOP/byte | 卡片 10.00，正确 |
| Trainium2 FP8 dense | $1299 / 2.9$ | 447.9310 FLOP/byte | 卡片 447.9，正确 |
| Trainium2 BF16/FP16/TF32 dense | $667 / 2.9$ | 230.0000 FLOP/byte | 卡片 230.0，正确 |
| Trainium2 FP32 dense | $181 / 2.9$ | 62.4138 FLOP/byte | 卡片 62.4，正确 |
| Trainium2 structured sparse | $2563 / 2.9$ | 883.7931 FLOP/byte | 卡片 883.8，正确；其输入事实的版本/聚合口径仍要保留 |

## M1 验收意见与建议顺序

当前结论为“不通过，修正后复审”。这不是因为 MLU590 公开字段少；大量空白本来就是试填要验证的场景。真正影响验收的是：GH100 裸片事实还没有合法对象；Trainium2 的每核与芯片聚合关系尚未按直接断言、派生值和聚合有效性拆开；MLU590 有关键字段依赖未完整取得的来源；正式全局事实链尚未完成合并。

建议按一条依赖链处理：先解决 B-01 至 B-03 的对象与证据边界，再把三张卡能成立的事实和缺失要求写入正式表；随后生成来源覆盖矩阵并做反向移除测试；最后运行结构化校验，并逐项回查关键数字、单位、条件、方向和来源定位。这样通过的 M1 才足以作为后续七厂商批量建卡的模板。

## 复核与验证记录

本次完整读取了任务指定的研究计划、字段字典、模板、枚举和表头注册表，逐行审查三张资料卡及 H100、Trainium2、MLU590 的相关交接。复核期间仅重开卡中已有的 AWS 官方 2.29.1 固定入口以核对关键段落，没有启动新的大范围网络检索。H100 固定白皮书补取、字段字典修正和 Trainium2 对象/枚举修正由总控完成，本文件只复核并记录状态。

交付前已使用 `report-humanizer` 的报告扫描工具检查本文，结果为 `No machine-detectable AI tells found`；随后按 `shuorenhua` 的文档场景规则做事实保真回读。数字、单位、文件路径、正式 ID、枚举值和责任归属没有因润色改变。文件以 UTF-8 无 BOM 写入，并在交接完成时重新核对哈希。
