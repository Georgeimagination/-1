# M2 AWS 与 Google 对象身份核对

> 状态：`ready_for_root_review`  
> 资料截止日：2026-08-12  
> 范围：只核对对象身份、对象类型和建卡边界，不采集规格事实，不修改正式 CSV。

## 裁决摘要

Amazon Web Services（AWS）的 11 条 Amazon Elastic Compute Cloud（EC2）候选都属于实例或实例族。Amazon EC2 用户指南说明，instance type 决定实例使用的主机硬件组合；官方 accelerated computing 规格页又把 Inf1、Inf2、Trn1、Trn1n、Trn2 和 Trn2u 列为 instance family，并列出各自的 instance type。它们正式导入时统一使用 `cloud_instance`，不再沿用候选表中的 `cloud_accelerator`。

Google 当前张量处理单元（Tensor Processing Unit，TPU）文档把 `ct6e-standard-1t`、`ct6e-standard-4t` 和 `ct6e-standard-8t` 定义为 TPU 虚拟机（virtual machine，VM）的 machine type。该候选应使用 `cloud_instance`。TPU v3 已有稳定系统名“TPU v3 Pod”，可建 `pod` 历史锚点卡。TPU 8t 和 TPU 8i 尚无可创建的 accelerator type 或 machine type，但 Google 已明确把它们称为两套系统，并分别使用 superpod 和 pod 的系统名词；两者可建 `pod` 观察卡，供货状态保持 `announced`，不能写成现已可用。

Trainium4 的芯片代际身份已经成立，未来系统身份尚未成立。AWS 只说明 Trainium4 正在设计、计划支持 NVIDIA NVLink Fusion，并可能与 Graviton、Elastic Fabric Adapter（EFA）和 MGX 机架协同。官方没有发布独立系统名、EC2 instance type 或固定系统组成。`CAND-AWS-TRAINIUM4-NVLINK-FUSION-SYSTEM` 因此只留候选，不进入 `objects.csv`，也不建系统卡。

## 判定边界

本次把云对象分成两类。`cloud_instance` 是用户创建或选择的虚拟机、EC2 instance type 或 machine type，它同时规定主机资源和加速器挂载边界。`cloud_accelerator` 是独立暴露的加速器资源或 Slice 配置，不等同于承载它的 VM。AWS 的 `trn*.xlarge`、`inf*.xlarge` 和 Google 的 `ct6e-standard-*` 都落在前一类；Google 的 `v6e-*` accelerator type 或 Slice 配置仍留在后一类。

系统对象不要求必须有订货型号（stock keeping unit，SKU），但必须能在一手资料中找到独立的系统名词和系统级边界。官方明确说“Pod”“superpod”或“UltraServer”时，可以建立 `pod` 或 `server` 对象；只说某芯片将支持一种互联技术、可能部署在通用机架中，尚不足以形成系统对象。

## AWS EC2 逐候选裁决

截至 2026-08-12，AWS 当前 accelerated computing 规格页仍列出下表中的全部 instance family 或 instance type。这里的“当前目录可见”只确认对象身份；区域、购买方式、预览、正式可用（general availability，GA）和退役时间仍要作为独立状态事实核对。

| 候选 ID | 官方身份与截止日状态 | 建议正式 `object_type` | 范围角色与 `review_status` | 是否建卡 | 一手依据 |
|---|---|---|---|---|---|
| `CAND-AWS-EC2-INF1-FAMILY` | Amazon EC2 Inf1 instance family；当前目录列出 `inf1.xlarge`、`inf1.2xlarge`、`inf1.6xlarge`、`inf1.24xlarge`。研究窗口内作为历史锚点。 | `cloud_instance`，并在 notes 标 `family_container` | `historical_anchor`；`reviewed` | 建轻量家族卡。家族卡不承载某个尺寸独有的实例事实；以后需要逐尺寸引用时再拆四个实例对象。 | [EC2 accelerated computing 规格](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html)、[Inf1 产品页](https://aws.amazon.com/ec2/instance-types/inf1/) |
| `CAND-AWS-EC2-TRN1-2XLARGE` | 正式 instance type `trn1.2xlarge`；当前目录可见。 | `cloud_instance` | `main_sample`；`reviewed` | 建独立实例卡。 | [EC2 accelerated computing 规格](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html)、[Trn1 产品页](https://aws.amazon.com/ec2/instance-types/trn1/) |
| `CAND-AWS-EC2-TRN1-32XLARGE` | 正式 instance type `trn1.32xlarge`；当前目录可见。 | `cloud_instance` | `main_sample`；`reviewed` | 建独立实例卡。 | [EC2 accelerated computing 规格](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html)、[Trn1 产品页](https://aws.amazon.com/ec2/instance-types/trn1/) |
| `CAND-AWS-EC2-TRN1N-32XLARGE` | 正式 instance type `trn1n.32xlarge`；当前目录把 Trn1n 单列为 family。 | `cloud_instance` | `main_sample`；`reviewed` | 建独立实例卡。网络边界与 `trn1.32xlarge` 分开记录。 | [EC2 accelerated computing 规格](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html)、[Trn1n GA 公告](https://aws.amazon.com/about-aws/whats-new/2023/04/amazon-ec2-trn1n-instances-network-ai-models/) |
| `CAND-AWS-EC2-INF2-XLARGE` | 正式 instance type `inf2.xlarge`；当前目录可见。 | `cloud_instance` | `main_sample`；`reviewed` | 建独立实例卡。 | [EC2 accelerated computing 规格](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html)、[Inf2 产品页](https://aws.amazon.com/ec2/instance-types/inf2/) |
| `CAND-AWS-EC2-INF2-8XLARGE` | 正式 instance type `inf2.8xlarge`；当前目录可见。 | `cloud_instance` | `main_sample`；`reviewed` | 建独立实例卡。 | [EC2 accelerated computing 规格](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html)、[Inf2 产品页](https://aws.amazon.com/ec2/instance-types/inf2/) |
| `CAND-AWS-EC2-INF2-24XLARGE` | 正式 instance type `inf2.24xlarge`；当前目录可见。 | `cloud_instance` | `main_sample`；`reviewed` | 建独立实例卡。 | [EC2 accelerated computing 规格](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html)、[Inf2 产品页](https://aws.amazon.com/ec2/instance-types/inf2/) |
| `CAND-AWS-EC2-INF2-48XLARGE` | 正式 instance type `inf2.48xlarge`；当前目录可见。 | `cloud_instance` | `main_sample`；`reviewed` | 建独立实例卡。 | [EC2 accelerated computing 规格](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html)、[Inf2 产品页](https://aws.amazon.com/ec2/instance-types/inf2/) |
| `CAND-AWS-EC2-TRN2-3XLARGE` | 正式 instance type `trn2.3xlarge`；当前 Trn2 产品页与目录均列出。M1 已有正式对象。 | `cloud_instance` | `main_sample`；复用现有 `reviewed` 对象 | 建独立实例卡，复用 `OBJ-AWS-TRN2-3XLARGE`。 | [Trn2 产品页](https://aws.amazon.com/ec2/instance-types/trn2/)、[EC2 accelerated computing 规格](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html) |
| `CAND-AWS-EC2-TRN2-48XLARGE` | 正式 instance type `trn2.48xlarge`；当前 Trn2 产品页与目录均列出。M1 已有正式对象。 | `cloud_instance` | `main_sample`；复用现有 `reviewed` 对象 | 建独立实例卡，复用 `OBJ-AWS-TRN2-48XLARGE`。 | [Trn2 产品页](https://aws.amazon.com/ec2/instance-types/trn2/)、[EC2 Trn2 GA 公告](https://aws.amazon.com/about-aws/whats-new/2024/12/amazon-ec2-trn2-instances-available/) |
| `CAND-AWS-EC2-TRN2U-48XLARGE` | 正式 instance type `trn2u.48xlarge`；当前 Trn2 产品页和目录均列出，并作为 UltraServer 组成实例。对象身份已确认，首次供货日期及 GA、预览或受限供货的时间线仍未解决。M1 已有正式对象。 | `cloud_instance` | `main_sample`；复用现有 `needs_resolution` 对象 | 建独立实例卡，复用 `OBJ-AWS-TRN2U-48XLARGE`，状态区保留未决。 | [Trn2 产品页](https://aws.amazon.com/ec2/instance-types/trn2/)、[EC2 accelerated computing 规格](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html) |

在当前枚举中，具体实例和配置族都使用 `cloud_instance`。这沿用 M1 的 `OBJ-AWS-TRN2-INSTANCE-FAMILY`。如果以后新增 `cloud_instance_family`，应一次性迁移 Inf1 和 Trn2 等家族对象，不能只为单个厂商做局部例外。

AWS 的通用 accelerated computing 页足以确认 family 与 instance type 身份，但 M1 已发现它的部分 Trn2 accelerator-memory 单元与专门产品资料冲突。本次没有使用这些数值；后续建卡仍按字段选择来源，不能因为身份表可靠就把整张规格表视为无条件可靠。

## Google 逐候选裁决

| 候选 ID | 官方身份与截止日状态 | 建议正式 `object_type` | 范围角色与 `review_status` | 是否建卡 | 一手依据 |
|---|---|---|---|---|---|
| `CAND-GOOGLE-CT6E-STANDARD-FAMILY` | TPU v6e 的 TPU VM machine type family，当前成员为 `ct6e-standard-1t`、`ct6e-standard-4t`、`ct6e-standard-8t`。Google 用 `gcloud compute instances create --machine-type=...` 创建这类 TPU VM。 | `cloud_instance`，notes 标 `machine_type_family` | `main_sample`；`reviewed` | 建一张机器类型族卡，三个 machine type 写卡内配置行。不要与 `v6e-*` Slice 合并。 | [TPU machines in accelerator-optimized machine family](https://docs.cloud.google.com/compute/docs/tpus/tpu-machines)、[创建 TPU VM](https://docs.cloud.google.com/tpu/docs/create-instance-compute)、[TPU v6e](https://docs.cloud.google.com/tpu/docs/v6e) |
| `CAND-GOOGLE-TPU-V3-CLOUD-SYSTEM` | 官方稳定名称为 TPU v3 Pod。当前 v3 页面仍把它作为受支持配置说明；Google 建议用 Google Kubernetes Engine（GKE）管理 v3，Cloud TPU 应用程序接口（API）只接受错误修复和安全更新。 | `pod` | `historical_anchor`；`reviewed` | 建轻量系统卡，建议 canonical label 为 `Google Cloud TPU v3 Pod`。架构事实仍留在 TPU v3 架构对象。 | [TPU v3](https://docs.cloud.google.com/tpu/docs/v3)、[TPU architecture](https://docs.cloud.google.com/tpu/docs/system-architecture-tpu-vm) |
| `CAND-GOOGLE-TPU-8T-CLOUD-SYSTEM` | Google 明确把 TPU 8t 称为第八代的独立系统，并使用 TPU 8t superpod 的系统名词。当前 TPU 产品页状态为 `Coming soon`，尚无稳定 accelerator type 或 machine type。 | `pod` | `observation`、`announced`；`needs_resolution` | 建轻量观察卡，建议 canonical label 为 `Google TPU 8t Superpod`。卡片只保存一手发布中明确属于系统的事实，不建立云配置对象。 | [TPU 8t/8i 架构说明](https://cloud.google.com/blog/products/compute/tpu-8t-and-tpu-8i-technical-deep-dive)、[Next '26 发布](https://cloud.google.com/blog/products/compute/ai-infrastructure-at-next26)、[TPU 产品页](https://cloud.google.com/tpu) |
| `CAND-GOOGLE-TPU-8I-CLOUD-SYSTEM` | Google 明确把 TPU 8i 称为另一套独立系统，并使用 TPU 8i pod 的系统名词。当前 TPU 产品页状态为 `Coming soon`，尚无稳定 accelerator type 或 machine type。 | `pod` | `observation`、`announced`；`needs_resolution` | 建轻量观察卡，建议 canonical label 为 `Google TPU 8i Pod`。卡片只保存一手发布中明确属于系统的事实，不建立云配置对象。 | [TPU 8t/8i 架构说明](https://cloud.google.com/blog/products/compute/tpu-8t-and-tpu-8i-technical-deep-dive)、[Next '26 发布](https://cloud.google.com/blog/products/compute/ai-infrastructure-at-next26)、[TPU 产品页](https://cloud.google.com/tpu) |

`ct6e-standard-4t` 可以出现在单主机和多主机 Slice 中。这个现象进一步说明 machine type 与 Slice 是两类对象：同一个 VM machine type 可以参与多种系统拓扑，Slice 的芯片数或拓扑不能直接写成 `ct6e-standard-4t` 自身的固定系统属性。

TPU 8t 与 TPU 8i 的 system object 和 architecture object 可以同名存在，因为两者由 `object_id` 与 `object_type` 区分。面向读者的系统卡标题追加官方名词 Superpod 或 Pod，避免把架构代际和聚合系统写成同一个实体。发布页中的 `Coming soon` 只说明供货阶段，不能据此创建尚未出现的 `cloud_instance` 或 `cloud_accelerator`。

## Trainium4 未来系统裁决

| 候选 ID | 官方身份与截止日状态 | 建议正式 `object_type` | 范围角色与 `review_status` | 是否建卡 | 一手依据 |
|---|---|---|---|---|---|
| `CAND-AWS-TRAINIUM4-NVLINK-FUSION-SYSTEM` | Trainium4 芯片身份已由 AWS 确认，预计 2027 年开始交付。AWS 只说它将支持 NVLink Fusion，并可能与 Graviton、EFA、Nitro 及 common MGX racks 协同；未发布独立系统产品名、EC2 instance type 或固定组成。 | 暂不分配；候选中的 `system/server` 只是工作假设 | 保留 `observation`；`needs_resolution` | 不建卡，不导入 `objects.csv`。等 AWS 发布正式 UltraServer、实例或机架产品名后再重审。 | [Trainium3 与 Trainium4 路线图](https://www.aboutamazon.com/news/aws/trainium-3-ultraserver-faster-ai-training-lower-cost)、[AWS AI Factories](https://www.aboutamazon.com/news/aws/aws-data-centers-ai-factories)、[OpenAI 与 Amazon 合作公告](https://press.aboutamazon.com/2026/2/openai-and-amazon-announce-strategic-partnership) |

这里不能把“支持 NVLink Fusion”“可在 common MGX racks 中协同”改写为“AWS Trainium4 NVLink Fusion System”。前两项是技术兼容与部署设想，后一项会制造一个官方没有发布的产品实体。Trainium4 架构观察卡可以继续推进；系统候选要等名称和组成边界出现后再进入正式库。

## 无稳定名称时的统一处理

一手资料已经给出独立系统名词，并且至少有一项事实只能归到聚合系统时，可以建立观察对象。canonical label 只拼接厂商名、代际名和一手资料使用的系统名词，例如 `Google TPU 8t Superpod`；`review_status` 保持 `needs_resolution`，供货状态按原文写 `announced` 或 `Coming soon`。这种对象用于承接系统级事实，不代表已有正式云 SKU。

只有路线图、兼容技术或可能的部署形态时，不建立正式对象。候选继续保留，记录最后检索日期、看过的官方入口和再纳入条件；没有对象身份前也不创建空资料卡。Trainium4 的未来 NVLink Fusion 系统属于这一类。

正式产品名、accelerator type、machine type 或实例 SKU 出现后，再决定它与观察对象是同一实体、具体变体，还是新的对象。此时通过关系或版本记录迁移，不能静默改名并覆盖早期状态。

## 总控导入提示

本包共裁决 16 条候选。建议将其中 15 条导入或复用为正式对象：11 条 AWS EC2 实例或实例族、1 条 Google TPU VM machine type family、3 条 Google Pod 或 Superpod 系统。`CAND-AWS-TRAINIUM4-NVLINK-FUSION-SYSTEM` 继续停留在候选层。AWS 三个 Trn2 实例必须复用 M1 的 `OBJ-AWS-TRN2-3XLARGE`、`OBJ-AWS-TRN2-48XLARGE` 和 `OBJ-AWS-TRN2U-48XLARGE`，不要生成第二套对象 ID。

AWS 其余 8 条候选和 Google 4 条候选需要预留新 ID。Inf1 与 `ct6e-standard-*` 都是 family container；在当前枚举下使用 `cloud_instance`，并在 notes 写明 family 属性。具体 SKU 或 machine type 暂放卡内配置行。只有出现跨卡引用、独立计费或独有状态事实时，才拆成新的具体对象。

导入对象本身不等于建立芯片包含关系。`instance_contains_accelerator` 只能在对应芯片或封装对象已冻结，并有一手资料确认实例包含关系后添加。TPU 8t 和 TPU 8i 的 Pod 对象也不能从系统名自动继承架构、芯片或聚合数值。本次裁决只提供身份和类型，不生成规格事实或对象关系。

总控合并后应复核三项计数：候选 ID 是否一一处理、三条 Trn2 是否确实复用、Trainium4 系统候选是否没有进入 `objects.csv`。随后再运行正式数据校验器。

## 仍未解决的事项

`trn2u.48xlarge` 的实例身份已经确认，但首次固定可用日期和 GA、预览、受限供货之间的时间线仍未解决。这个问题不阻止建实例卡，卡片和正式对象继续使用 `needs_resolution`。

TPU 8t 与 TPU 8i 截止日仍没有稳定 accelerator type、machine type、区域和正式可用日期。系统观察卡可以建立，云配置卡暂不建立。后续若 Google 发布配置页，应新增配置对象并保留 2026 年的 announced 状态，不覆盖早期记录。

Trainium4 没有可定位的系统产品身份。触发重审的条件是 AWS 发布正式的 EC2 instance type、UltraServer、机架产品名或一份能固定系统组成的产品文档。

## 交接与检查

本次读取了 `进度/当前状态.md`、`审计/M1_试填合并验收.md`、`审计/子代理交接/m2_cloud_batch_plan.md`、`审计/子代理交接/object_candidates.csv`、`数据/objects.csv`、`数据/object-relations.csv` 和 `数据/enums.csv`。外部核对只使用 AWS、Amazon 和 Google 的官方页面。

本次只写入 `审计/子代理交接/m2_scope_aws_google.md`。已只读检查 `README.md` 与 `AGENTS.md`；两份文件仍准确记录 M2 正在做前置身份核对，本包又等待总控验收，因此本次按分工不修改。正式 CSV、资料卡、进度文件和研究计划也没有改动。

`report-humanizer` 机器扫描未发现可识别的 AI 写作痕迹。按 `shuorenhua` 的 docs 场景做保真回读时，发现首段缩写解释不足和一处标题前空行缺失，均已修正；候选 ID、状态、对象类型和官方术语没有因润色改变。16 条目标候选均有裁决，三张表的 22 行均为六列，18 个外部链接全部属于 AWS、Amazon 或 Google 官方域名。文件未出现替换字符、禁用公式分隔符或异常换行字面量。

剩余风险来自动态产品页：`Coming soon`、当前目录可见和供货状态可能在截止日后改变。总控正式合并时应保存 2026-08-12 快照或固定公告，不能用后续页面状态覆盖本次截止日判断。