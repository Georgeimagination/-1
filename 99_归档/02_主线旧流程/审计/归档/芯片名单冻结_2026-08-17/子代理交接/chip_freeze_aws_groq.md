# AWS 与 Groq 芯片名单冻结初审交接

状态：`ready_for_independent_review`，仅为候选冻结稿，不代表正式冻结。  
核对截止日：2026-08-14。  
任务边界：只核对产品身份、对象层级、时间桶和训练/推理相关性；没有展开规格调研、媒体检索、事实抽取或资料卡生产。

## 结论

早期候选中的 7 个 `package` 已逐一裁决：AWS Inferentia、AWS Trainium、AWS Inferentia2、AWS Trainium2、AWS Trainium3、GroqChip Processor 和 NVIDIA Groq 3 LP30 都有官方“chip”或“processor”身份，可以进入候选冻结稿。LP30 的厂商应从早期候选的 Groq 改为 NVIDIA；它与“NVIDIA Groq 3 LPU”是同一颗芯片的产品名与代际称呼，只计一次。

AWS 还缺一颗已经正式命名、但仍属未来产品的 Trainium4。建议新增为 `include_announced`，单列“未来已宣布”时间桶，不把它写成已经交付。Inferentia3 与 Groq 2 截止日都没有可核验的官方产品身份，继续排除。按这一口径，本组候选冻结稿包含 AWS 5 颗已交付或历史芯片、AWS 1 颗未来已宣布芯片、Groq 1 颗第一代芯片，以及归 NVIDIA 的 LP30 1 颗；不同时间桶不得混报成“当前可用 8 颗”。

## 7 个早期 `package` 候选逐条裁决

这里的 `package` 是保守的事实承接容器：官方把对象称为 chip、processor 或 device，但没有公开足以拆分裸片、芯粒、基板与订货封装的信息。把对象暂定为 `package` 不等于声称其内部只有一颗裸片。

| 候选 ID | 规范芯片名与厂商 | 层级 | 时间边界 | 训练/推理相关性 | 初审状态 | 纳入理由、排除边界与计数关系 | 官方身份来源 |
|---|---|---|---|---|---|---|---|
| `CAND-AWS-INFERENTIA1-CHIP` | AWS Inferentia（第一代），AWS | `package` | 2018-11-28 正式公布；2019-12 随 Inf1 进入正式可用阶段；截止日作历史锚点 | 推理 | `include` | 官方直接称 machine learning inference chip。`Inferentia`、`Inferentia1` 和“第一代 Inferentia”是同一身份，只计 1；Inf1 实例不另计芯片。 | [AWS 2018 发布页](https://aws.amazon.com/about-aws/whats-new/2018/11/announcing-amazon-inferentia-machine-learning-inference-microchip/)；[AWS 官方历史回顾](https://aws.amazon.com/blogs/machine-learning/a-review-of-purpose-built-accelerators-for-financial-services/) |
| `CAND-AWS-TRAINIUM1-CHIP` | AWS Trainium（第一代），AWS | `package` | 2022-10-10 Trn1 正式可用；截止日保留已交付代际 | 训练 | `include` | 官方直接称 AWS Trainium chip。`Trainium`、`Trainium1` 和“第一代 Trainium”归一为 1；Trn1、Trn1n 实例不另计芯片。 | [AWS Trn1 正式可用发布页](https://aws.amazon.com/blogs/aws/amazon-ec2-trn1-instances-for-high-performance-model-training-are-now-available/) |
| `CAND-AWS-INFERENTIA2-CHIP` | AWS Inferentia2，AWS | `package` | 2022 年预览；2023-04-13 Inf2 正式可用；截止日为已交付代际 | 推理 | `include` | 官方直接称 Inferentia2 chip。实例内芯片数量只是部署配置，不生成新的芯片型号。 | [AWS Inf2 正式可用发布页](https://aws.amazon.com/about-aws/whats-new/2023/04/amazon-ec2-inf2-instances-generative-ai-generally-available/) |
| `CAND-AWS-TRAINIUM2-CHIP` | AWS Trainium2，AWS | `package` | 2023-11-28 正式公布；2024-12-03 Trn2 正式可用；截止日为已交付代际 | 训练与推理 | `include` | 早期 173 行已有此候选；M2 映射未再列它，是因为正式库已复用 `OBJ-AWS-TRAINIUM2-CHIP`，不是漏项。Trn2 实例与 UltraServer 均不另计芯片。 | [Amazon 2023 芯片发布稿](https://press.aboutamazon.com/2023/11/aws-unveils-next-generation-aws-designed-chips)；[AWS Trn2 产品页](https://aws.amazon.com/ec2/instance-types/trn2/) |
| `CAND-AWS-TRAINIUM3-CHIP` | AWS Trainium3，AWS | `package` | 2024-12-03 正式公布；2025-12-02 Trn3 UltraServer 正式可用；截止日为已交付代际 | 训练与推理 | `include` | 官方直接称 Trainium3 chip。UltraServer 是系统层对象，其组成数量不增加芯片型号数。 | [AWS Trn3 正式可用发布页](https://aws.amazon.com/about-aws/whats-new/2025/12/amazon-ec2-trn3-ultraservers/) |
| `CAND-GROQ-GROQCHIP-PROCESSOR` | GroqChip Processor（第一代；`GroqChip 1` 为同义称呼），Groq | `package` | 2020 年原始架构论文已公开；2022 v1.5 与 2024 v1.7 为文档/产品资料修订；截止日保留历史及部署身份，不主张可单独采购 | 推理相关；早期资料也泛称 AI、ML 与 HPC | `include` | v1.5 明确称 standalone chip，v1.7 继续使用 GroqChip Processor 身份。v1.0、v1.5、v1.7 是资料修订，不是 3 颗芯片；GroqCard、Node、Rack 只是承载关系。 | [GroqChip v1.7 官方简报](https://groq.com/wp-content/uploads/2024/08/GroqChip%E2%84%A2-Processor-Product-Brief-v1.7.pdf)；[Groq 第一代身份说明](https://groq.com/blog/the-groq-lpu-explained) |
| `CAND-GROQ-LP30` | NVIDIA Groq 3 LP30，NVIDIA | `package`（保守） | 2026-03-16 已由 NVIDIA 正式命名；截至截止日，Vera Rubin 平台页称相关芯片处于 full production，按 `current_production` 处理 | 推理 | `include`，并改归 `VEN-NVIDIA` | NVIDIA 官方表格直接写 `LP30 chips`，足以关闭“芯片还是托盘”的身份问题；图中 module 字样不足以拆出另一颗芯片。`NVIDIA Groq 3 LPU` 是代际/通用称呼，`LP30` 是芯片名，两者合计 1。LPX 托盘和机架均不计。 | [NVIDIA LP30 技术说明](https://developer.nvidia.com/blog/inside-nvidia-groq-3-lpx-the-low-latency-inference-accelerator-for-the-nvidia-vera-rubin-platform)；[NVIDIA LPX 产品页](https://www.nvidia.com/en-gb/data-center/lpx/) |

## 补项与未成立名称

| 候选 ID | 名称与拟定厂商 | 层级 | 时间边界 | 相关性 | 初审状态 | 理由与计数处理 | 官方入口 |
|---|---|---|---|---|---|---|---|
| `CAND-AWS-TRAINIUM4-CHIP`（建议新增） | AWS Trainium4，AWS | `package`（待后续物理资料确认） | 截止日已正式命名、仍在设计；官方预计 2027 开始交付 | 训练与推理 | `include_announced` | “Trainium4”已经是官方芯片名，不能只保留架构或未来系统候选。单独计 1 个“未来已宣布”芯片对象；不得并入当前可用数量，也不得把 NVLink Fusion 系统再计一次。 | [Amazon Trainium3/4 官方说明](https://www.aboutamazon.com/news/aws/trainium-3-ultraserver-faster-ai-training-lower-cost)；[Amazon 2026 年第四季度业绩公告](https://ir.aboutamazon.com/news-release/news-release-details/2026/Amazon-com-Announces-Fourth-Quarter-Results/) |
| `CAND-AWS-INFERENTIA3` | AWS Inferentia3（未成立） | 不建立 `die`/`package` | 截止 2026-08-14 未找到 AWS 正式命名或发布 | 推理方向仅为名称推测 | `exclude_unconfirmed` | AWS 官方 Inferentia 入口只列第一代与 Inferentia2。此结论是截止日的身份缺口，不表示永久不存在；有正式发布后再重开。 | [AWS Inferentia 官方入口](https://aws.amazon.com/ai/machine-learning/inferentia/) |
| `CAND-GROQ-ARCH-LPU2` | Groq 2（未成立） | 不建立 `architecture_generation`、`die` 或 `package` | 截止 2026-08-14 未找到 Groq 正式产品名 | 未确认 | `exclude_unconfirmed` | `world-meet-groq-2` 中的 `-2` 是网页路径后缀，正文并没有“Groq 2”产品身份，不能据此建对象。只有 Groq 正式命名产品或芯片后再重开。 | [Groq 官方文章](https://groq.com/blog/world-meet-groq-2)；[Groq 当前 LPU 入口](https://groq.com/lpu-architecture) |

## 非芯片对象的处理

这些对象可保留既有历史记录或关系，但全部是 `exclude_nonchip`，不进入芯片名单、完成度分母或一芯片一文档数量。

| 候选范围 | 对象层级 | 裁决与官方边界来源 |
|---|---|---|
| Inf1、Trn1/Trn1n、Inf2、Trn2 各实例或实例家族 | `cloud_instance` | 排除；它们是承载芯片的云配置。身份可回到 [AWS Inferentia](https://aws.amazon.com/ai/machine-learning/inferentia/) 和 [AWS Trainium](https://aws.amazon.com/ai/machine-learning/trainium/) 产品入口。 |
| Trn2 UltraServer、Trn3 UltraServer、Trainium4 NVLink Fusion 未来系统 | `server` 或系统候选 | 排除；芯片数量只建立组成关系。来源见 [AWS Trn2](https://aws.amazon.com/ec2/instance-types/trn2/) 与 [Trainium3/4 官方说明](https://www.aboutamazon.com/news/aws/trainium-3-ultraserver-faster-ai-training-lower-cost)。 |
| GroqCard `GC1-010B`、`GC1-0109`、`GC1-0100` | `card` | 排除；三者是承载同一 GroqChip 的卡 SKU，不是三颗芯片。来源：[GroqCard v1.5 官方简报](https://groq.com/wp-content/uploads/2022/10/GroqCard%E2%84%A2-Accelerator-Product-Brief-v1.5-.pdf)。 |
| GroqNode `GN1-B8C` | `server` | 排除；只保留服务器到 GroqCard/GroqChip 的组成关系。来源：[GroqNode 官方简报](https://groq.com/wp-content/uploads/2024/02/GroqNode%E2%84%A2-Server-Product-Brief.pdf)。 |
| GroqRack `GR1-C9A` | `rack` | 排除；只保留机架到 Node/Card/Chip 的组成关系。来源：[GroqRack v1.7 官方简报](https://groq.com/wp-content/uploads/2024/08/GroqRack%E2%84%A2-Compute-Cluster-Product-Brief-v1.7.pdf)。 |
| GroqCloud | `cloud_accelerator` / 服务 | 排除；它是推理服务，不是芯片产品。来源：[GroqCloud 官方入口](https://groq.com/groqcloud)。 |
| NVIDIA Groq 3 LPX compute tray 与 LPX rack | `server`、`rack` | 排除；只把其中的 LP30 芯片计 1 个型号，不按托盘或机架内数量扩增。来源：[NVIDIA LP30 技术说明](https://developer.nvidia.com/blog/inside-nvidia-groq-3-lpx-the-low-latency-inference-accelerator-for-the-nvidia-vera-rubin-platform)。 |

`architecture_generation` 也不计芯片：AWS Inferentia/Trainium 各代架构、Groq 第一代 LPU 和 NVIDIA Groq 3 LPU 只给入选芯片提供架构证据。Groq 2 连架构身份也未成立，继续排除。

## 计数方法

名单同时保留“对象行数”和“去重芯片身份数”，不能把两者混成一个数字。每个官方命名的裸片或单芯片封装可有一行；若后续证明多个封装共享同一裸片，则用同一 `count_group` 连接，并分别报告封装对象数与唯一裸片身份数。没有官方物理关系时不猜共享裸片。

同一物理芯片的简称、代际补写和品牌改写不新增计数。例如 Inferentia 与 Inferentia1、Trainium 与 Trainium1、GroqChip Processor 与 GroqChip 1、NVIDIA Groq 3 LPU 与 LP30 都各归为一个 `count_group`。产品简报版本、软件版本、云实例、系统内芯片数量和服务器配置都不产生新芯片型号。只有厂商给出稳定、独立的单芯片封装名，且能证明物理或产品边界不同，才把封装变体拆成不同对象；同时仍需标明是否共享裸片，避免在“唯一硅片设计数”中重复计数。

## 与正式库的衔接

AWS 的 Inferentia、Trainium、Inferentia2、Trainium2 和 Trainium3 已有正式 `package` 对象；Trainium2 未出现在 M2 第二波映射中是复用既有对象。GroqChip 尚无正式芯片对象，LP30 在 M2 中曾因层级不清而 `defer_candidate`，Trainium4 只有架构和未来系统线索。得到用户确认后，主代理可分别预留 `OBJ-GROQ-GROQCHIP-PROCESSOR`、`OBJ-NVIDIA-GROQ3-LP30` 和 `OBJ-AWS-TRAINIUM4-CHIP`；最终 ID 仍由总控分配。本交接不改全局表，也不重写既有数据。

LP30 的最终厂商归属采用 NVIDIA，与正式库 `OBJ-NVIDIA-GROQ3-ARCH` 的厂商一致。Groq 第一代芯片继续归 Groq。这样既保留技术传承，也不会在 NVIDIA 与 Groq 两个厂商下重复计算 LP30。

## 输入、来源与验证

已完整读取 `AGENTS.md`、`审计/新会话交接_芯片名单冻结.md`、DEC-030、DEC-031，并对照 `object_candidates.csv`、`M2_对象范围映射.csv`、`数据/objects.csv`、AWS 第二波物理对象身份门、两张 Groq 架构卡和 GHC 架构包验收记录。联网核对只访问上表列出的 AWS、Amazon、Groq 与 NVIDIA 官方入口，没有使用媒体或第三方资料。

GroqChip v1.7 本地 PDF 共 2 页，已逐页渲染检查：第一页给出 `GroqChip Processor` 产品身份，第二页继续以单颗 chip/processor 为规格主体并说明其系统承载方式。文件为 `论文/Groq_LPU/90_官方白皮书与技术资料/2024_GroqChip_Processor_Product_Brief_v1.7.pdf`，SHA-256 为 `BC6AA1F5E667D75ABA689A3B336B0A6FC68F6B3A002274550B94C7B9671F5377`。

本次没有修改全局 CSV、README、AGENTS、研究计划、进度文件或正式数据。`README.md` 与 `AGENTS.md` 已检查，无需更新：项目目标、目录职责、范围规则和正式状态均未因这份子代理初审交接改变。

## 待独立复核的争议

独立复核应重点回答两个问题。第一，Trainium4 是否按 `include_announced` 进入完整名单并单列未来时间桶，还是只留观察表；无论选择哪种，都不能把它写成当前已交付。第二，LP30 虽已有明确 chip 身份，但公开材料同时出现 LPU accelerator、chip 和 module 语汇；当前建议以 `package` 保守承接，并把物理封装构造留待后续资料工程，而不是继续阻塞名单冻结。

## 写入文件

- `审计/子代理交接/chip_freeze_aws_groq.md`
