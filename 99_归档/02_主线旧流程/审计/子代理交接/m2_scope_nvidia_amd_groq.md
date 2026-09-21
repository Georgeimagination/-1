# M2 前置身份核对：NVIDIA、AMD 与 Groq 相关候选

> 状态：`ready_for_root_review`  
> 资料截止日：2026-08-12  
> 写入边界：只处理对象身份、厂商归属、对象层级、范围与架构关系，不采集产品规格。本文件不修改正式 CSV、资料卡、进度、README、AGENTS 或研究计划。

## 输入与判定口径

本次读取 `进度/当前状态.md`、`审计/M1_试填合并验收.md`、两份 M2 批次计划、`object_candidates.csv` 和 `数据/enums.csv`。正式对象建议只使用现有 `object_type`、`relation_type`、`product_status` 与 `review_status` 枚举。软件支持矩阵可以确认厂商使用的产品名和架构归类，但不会单独证明订货形态、供货地区或卡级规格。

以下裁决都以 2026-08-12 为截止日。`main_sample`、`observation`、`historical_anchor` 和 `excluded_lead` 是研究范围标签，不等同于正式 `product_status`；正式导入时仍需分别填写范围决定和产品状态。

## 已确认裁决（阶段记录）

### NVIDIA Groq 3 LPU、LP30 与 LPX

NVIDIA 的 2026-03-16 Vera Rubin 发布材料把语言处理单元（Language Processing Unit，LPU）产品 `NVIDIA Groq 3 LPU` 列为 Vera Rubin 平台的七颗芯片之一，并把 `NVIDIA Groq 3 LPX` 列为 NVIDIA 数据中心产品。NVIDIA 自己的技术博客和产品页继续使用 `NVIDIA Groq 3 LPU`、`LP30 chip`、`LPX compute tray` 与 `LPX rack`。因此这组对象的正式厂商应为 `VEN-NVIDIA`，归入 NVIDIA 数据中心产品线；名称中的 Groq 表示技术与品牌来源，不能据此继续使用 `VEN-GROQ`。NVIDIA 同期披露的是与 Groq 的非独家许可协议，而非 Groq 公司整体并入 NVIDIA，第一代 GroqChip、GroqCard、GroqNode 和 GroqRack 仍归 `VEN-GROQ`。

建议对象边界如下：

| 候选 | 建议正式身份 | `object_type` | 范围 / 截止日状态 | 关系与复核状态 |
|---|---|---|---|---|
| `CAND-GROQ-ARCH-LPU3` | NVIDIA Groq 3 LPU architecture | `architecture_generation` | `observation` / `production_ramp` | `VEN-NVIDIA`；保留观察项 |
| `CAND-GROQ-LP30` | NVIDIA Groq 3 LP30 | `package`（暂定） | `observation` / `production_ramp` | `implements_architecture` 指向上行；固定产品资料尚未说明 LP30 是裸片名还是封装后加速器名，故 `needs_resolution` |
| `CAND-GROQ-LPX-COMPUTE-TRAY-8` | NVIDIA Groq 3 LPX compute tray | `server` | `observation` / `production_ramp` | 1U 计算托盘是含主机处理器、LPU 加速器与其他部件的系统对象，不建议用 `baseboard`；通过 `deployed_in_system` 或系统包含关系表达，正式关系方向由总控统一 |
| `CAND-GROQ-LPX-RACK-256` | NVIDIA Groq 3 LPX rack | `rack` | `observation` / `production_ramp` | 与 compute tray 分开；保留 `needs_resolution` 直到交付状态有对象匹配证据 |

这四行应从 Groq 厂商批次移到 NVIDIA/Vera Rubin 相关批次，但可在显示名和索引中保留 `Groq 3`，避免把许可技术来源抹掉。

官方入口：

- NVIDIA 2026-03-16 Vera Rubin 发布稿：https://nvidianews.nvidia.com/news/nvidia-vera-rubin-platform
- NVIDIA Groq 3 LPX 产品页：https://www.nvidia.com/en-gb/data-center/lpx/
- NVIDIA 2026-03-16 技术说明：https://developer.nvidia.com/blog/inside-nvidia-groq-3-lpx-the-low-latency-inference-accelerator-for-the-nvidia-vera-rubin-platform/
- NVIDIA FY2026 财务结果，记录与 Groq 的非独家许可协议：https://investor.nvidia.com/news/press-release-details/2026/NVIDIA-Announces-Financial-Results-for-Fourth-Quarter-and-Fiscal-2026/
- NVIDIA 2026-05-31 生产爬坡状态：https://nvidianews.nvidia.com/news/vera-rubin-full-production-agentic-ai-factory

### A800 两条候选

两条候选不是同一硬件身份的重复记录。`NVIDIA A800 40GB Active` 是 NVIDIA 工作站产品页明确命名的主动散热 PCIe 卡；数据中心 `NVIDIA A800` 则在 NVIDIA AI Enterprise 与数据中心驱动文档中分成 `A800 PCIe 80GB`、`A800 PCIe 80GB Liquid Cooled`、`A800 HGX 80GB` 等边界。当前 `CAND-NVIDIA-A800-DATACENTER` 过宽，不能直接作为一个 `card` 导入；它应先作为消歧父线索，再按固定对象名拆成卡或模组。

| 候选 | 裁决 | 建议范围 | 正式对象建议 |
|---|---|---|---|
| `CAND-NVIDIA-A800-DATACENTER` | 不是单一 SKU；`needs_resolution` | `VEN-NVIDIA`；`main_sample` / `available` | 不直接建 `card`。至少核对并拆出 `NVIDIA A800 PCIe 80GB`、`NVIDIA A800 PCIe 80GB Liquid Cooled` 与 `NVIDIA A800 HGX/SXM4 80GB`；PCIe 形态用 `card`，HGX/SXM 物理加速器用 `module` |
| `CAND-NVIDIA-A800-40GB-ACTIVE` | 独立工作站卡，不是上述数据中心 80GB SKU 的配置行 | `VEN-NVIDIA`；`excluded_lead`；截止日供货状态仍 `needs_resolution` | 若仅为保存身份，可写 `card`、Ampere；当前研究范围不建正式资料卡，也不建立 `sku_variant_of` |

官方入口：

- A800 40GB Active 工作站产品页：https://www.nvidia.com/en-us/products/workstations/a800/
- NVIDIA AI Enterprise 5.0 Release Notes，列出各 A800 物理产品名：https://docs.nvidia.com/ai-enterprise/5.0/release-notes/index.html
- NVIDIA AI Enterprise 6 Ampere vGPU reference：https://docs.nvidia.com/ai-enterprise/release-6/latest/infra-software/vgpu/reference/ampere.html
- NVIDIA DGX OS 归档说明中的 `A800-SXM4-80GB` 身份：https://docs.nvidia.com/dgx/archives/dgx-os-5-user-guide/known_issues.html

### NVIDIA 地区产品的架构关系

现有 NVIDIA 一手文档足以确认 H800、H20、L20 和 L2 的架构关系；H20 BFX 则出现官方版本冲突，必须单独待核。对象的形态、容量变体、地区供货与当前可购状态仍需在规格包中单独核实。

| 候选 | 官方架构归类 | 建议关系 | 范围 / 状态处理 |
|---|---|---|---|
| `CAND-NVIDIA-H800` | Hopper | `implements_architecture` → Hopper | `VEN-NVIDIA`；`main_sample` / `available`；产品名覆盖 PCIe、SXM5 与 NVL 等多个物理 SKU，`object_type` 仍为 `needs_resolution`，不得只建一张无形态 `card` |
| `CAND-NVIDIA-H20` | Hopper | `implements_architecture` → Hopper | `VEN-NVIDIA`；`main_sample` / `available`；官方文档区分多个 SXM5 SKU，`object_type` 仍为 `needs_resolution`，须先拆对象 |
| `CAND-NVIDIA-L20` | Ada Lovelace | `implements_architecture` → Ada Lovelace | `VEN-NVIDIA`；`card`；`main_sample` / `available`；架构项可改为已确认 |
| `CAND-NVIDIA-L2` | Ada Lovelace | `implements_architecture` → Ada Lovelace | `VEN-NVIDIA`；`card`；`main_sample` / `available`；架构项可改为已确认 |
| `CAND-NVIDIA-H20BFX` | 证据冲突 | 暂不建立正式架构关系 | `VEN-NVIDIA`；`card` 暂定；`observation` / `announced`；NVIDIA R581/R595 驱动资料分别把 `H20 BFX` 放在 Hopper 产品表和 Blackwell family 表中，架构与最终形态保持 `needs_resolution` |

官方入口：

- NVIDIA AI Enterprise Hopper reference：https://docs.nvidia.com/ai-enterprise/release-8/latest/infra-software/vgpu/reference/hopper.html
- NVIDIA AI Enterprise 架构索引（H100/H200/H800/H20；L4/L20/L40/L40S）：https://docs.nvidia.com/ai-enterprise/release-6/latest/infra-software/vgpu/reference/index.html
- NVIDIA AI Enterprise UVM 架构分组（含 L2/L20）：https://docs.nvidia.com/ai-enterprise/release-8/latest/infra-software/vgpu/features/uvm.html
- R581 Windows 驱动说明，把 H20 BFX 列为 Hopper：https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-581-15/index.html
- R595 数据中心驱动说明，把 H20BFX 列入 Blackwell family：https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-595-71-05/index.html

## AMD 候选裁决

### MI308X 与 MI308X-HF

候选名中的 OAM（OCP Accelerator Module，OCP 加速器模组）表示目标物理层级。AMD Instinct Customer Acceptance Guide 已把 MI308X 列为独立产品，并给出对应设备标识；AMD SMI（System Management Interface，系统管理接口）也使用 `MI308X` 市场名。AMD 2025 年报进一步说明，MI308 产品已在 2025 财年第四季度开始向取得许可的中国客户发货。因此 `CAND-AMD-MI308X-OAM` 的厂商、产品身份和已发货状态可以确认，但公开材料没有直接把 MI308X 写成“CDNA 3 产品”。`gfx942` 软件目标只能作为关系线索，不能替代厂商对架构代际的明确命名。

`MI308X-HF` 出现在 AMD 软件支持材料中，却没有独立产品页或物理形态说明。它暂时只保留为软件变体线索，不能当成 MI308X 的同义名，也不能直接建立 `sku_variant_of`。

| 候选 | 截止日裁决 | 建议正式记录 |
|---|---|---|
| `CAND-AMD-MI308X-OAM` | 独立 AMD Instinct 产品，已实际发货；具体销售受出口许可约束 | `VEN-AMD`；`module`；`main_sample`；`available`。产品身份可 `reviewed`，`implements_architecture` → CDNA 3 仍为 `needs_resolution` |
| `CAND-AMD-MI308X-HF` | 只确认到软件侧变体名，物理对象边界未公开 | 保持 `excluded_lead`，不导入正式硬件对象；不建立同义或 SKU 关系 |

官方入口：

- AMD Instinct Customer Acceptance Guide：https://instinct.docs.amd.com/projects/system-acceptance/en/latest/common/health-checks.html
- AMD SMI 变更记录：https://rocm.docs.amd.com/projects/amdsmi/en/docs-6.3.2/reference/changelog.html
- AMD 产品安全公告：https://www.amd.com/en/resources/product-security/bulletin/amd-sb-6024.html
- AMD 2025 年报，MI308 发货状态见 PDF 第 43 页：https://ir.amd.com/financial-information/sec-filings/content/0001193125-26-129106/0001193125-26-129106.pdf

### MI350P

AMD 已建立 MI350P 独立产品页，正式名称为 `AMD Instinct MI350P`，系列为 Instinct MI350，物理形态为 PCIe add-in card，并明确归入 CDNA 4。AMD 2026-05-07 的官方文章称该卡已用于风冷系统。因此当前候选不再需要身份消歧。

| 候选 | 截止日裁决 | 建议正式记录 |
|---|---|---|
| `CAND-AMD-MI350P-PCIE` | 独立可部署的 PCIe 卡，身份、形态、架构与供货状态均有一手依据 | `VEN-AMD`；`card`；`main_sample`；`available`；`implements_architecture` → CDNA 4；身份关系可 `reviewed` |

官方入口：

- AMD MI350P 产品页：https://www.amd.com/en/products/accelerators/instinct/mi350/mi350p.html
- AMD 2026-05-07 官方文章：https://www.amd.com/en/blogs/2026/amd-instinct-mi350p-pcie-gpus-run-enterprise-ai-on-your.html

### CDNA 5、MI400 系列与 Helios

AMD 已正式命名 CDNA 5，并在 MI455X 产品页中直接建立两者关系。MI455X 的发布日期为 2026-07-23，物理形态是 EAM（Enhanced Accelerator Module，增强型加速器模组）。不过，AMD 2025 年报仍把 MI400 系列的生产发货写成 2026 年下半年将要开始，MI400 系列页也只说 Helios 量产部署预计在 2026 年下半年。截止 2026-08-12，已找到的官方材料可以证明产品发布和量产准备，不能证明 MI455X 已开始客户交付。建议把候选中的 `production_ramp` 收紧为 `announced`；若后续取得明确的首批发货公告，再改为 `production_ramp` 或 `available`。

Helios 的边界由 AMD FAQ 直接说明：它是供原始设备制造商（OEM）和原始设计制造商（ODM）采用的参考设计，不是 AMD 对外销售的成品机架。它可以作为观察范围内的 `rack` 参考对象，不能与合作伙伴的可订购机架混成一个 SKU。

| 候选 | 截止日裁决 | 建议正式记录 |
|---|---|---|
| `CAND-AMD-ARCH-CDNA5` | AMD 已正式命名的架构代际 | `VEN-AMD`；`architecture_generation`；`main_sample`；`announced`；身份可 `reviewed` |
| `CAND-AMD-MI455X` | 独立 MI400 系列产品；EAM 形态和 CDNA 5 关系已确认；未找到已发货证据 | `VEN-AMD`；`module`；`main_sample`；`announced`；`implements_architecture` → CDNA 5；身份关系可 `reviewed` |
| `CAND-AMD-MI440X` | 2026-01-05 正式发布的 MI400 系列成员；官方发布稿未给出可直接映射到枚举的物理形态 | `VEN-AMD`；`observation`；`announced`；通过 MI400 系列归入 CDNA 5。`object_type` 暂保留 `module` 但标 `needs_resolution` |
| `CAND-AMD-MI430X` | MI400 系列成员，AMD 预计 2027 年可用；最终物理形态仍缺直接定义 | `VEN-AMD`；`observation`；`announced`；通过 MI400 系列归入 CDNA 5。`object_type` 暂保留 `module` 但标 `needs_resolution` |
| `CAND-AMD-HELIOS-72-MI455X` | 72-GPU Helios 参考机架，不是 AMD 销售产品 | `VEN-AMD`；`rack`；`observation`；`announced`；`physically_contains` → MI455X 模组，数量另存事实；身份可 `reviewed` |

官方入口：

- AMD MI455X 产品页：https://www.amd.com/en/products/accelerators/instinct/mi400/mi455x.html
- AMD MI400 系列与 Helios FAQ：https://www.amd.com/en/products/accelerators/instinct/mi400.html
- AMD 2026-01-05 发布稿，含 MI440X 与 MI500 预告：https://www.amd.com/en/newsroom/press-releases/2026-1-5-amd-and-its-partners-share-their-vision-for-ai-ev.html
- AMD 2025 年报，MI400 与 Helios 发货计划见 PDF 第 4 页：https://ir.amd.com/financial-information/sec-filings/content/0001193125-26-129106/0001193125-26-129106.pdf

### CDNA 6 与 MI500 Series

AMD 已把 CDNA 6 作为下一代架构正式对外命名，并说明计划于 2027 年发布的 MI500 Series 将采用该架构。这里的身份风险不在名称或关系，而在对象层级：`MI500 Series` 目前是产品系列，尚无具体 SKU 或物理形态；现有 `object_type` 枚举又没有 `product_family`。把它写成 `module` 会把路线图系列误作一块确定模组。

| 候选 | 截止日裁决 | 建议正式记录 |
|---|---|---|
| `CAND-AMD-ARCH-CDNA6` | 已正式命名的未来架构，计划随 2027 年产品落地 | `VEN-AMD`；`architecture_generation`；`observation`；`announced`；身份可 `reviewed` |
| `CAND-AMD-MI500-SERIES` | 已正式预告的产品系列，不是已定型物理 SKU | `VEN-AMD`；`observation`；`announced`；候选关系为 `implements_architecture` → CDNA 6。正式导入前保持 `needs_resolution`，不可沿用当前 `module` 类型；等待具体 SKU，或由总控决定是否扩充产品系列类型 |

官方入口：

- AMD 2026-01-05 发布稿：https://www.amd.com/en/newsroom/press-releases/2026-1-5-amd-and-its-partners-share-their-vision-for-ai-ev.html

## 仍需总控决定的边界

本子包留下五项 `needs_resolution`：LP30 的裸片或封装对象层级；H20 BFX 在 NVIDIA 两版驱动资料中的 Hopper/Blackwell 冲突；MI308X 与 CDNA 3 的正式关系；MI440X、MI430X 的物理对象类型；MI500 Series 缺少适用的产品系列枚举。其余裁决可以进入总控的对象拆分与顺序合并。

本轮只写入此交接文件，没有改动正式 CSV、资料卡、进度、README、AGENTS 或研究计划。README 与 AGENTS 已检查；本次没有改变项目目标、目录、数据模型或运行方式，因此无需修改。

## 交付检查

- 任务边界：仅核对身份、厂商、对象层级、范围、状态与关系，没有抄录规格数据。
- 来源边界：所列入口均为 NVIDIA、AMD 或其官方开发文档、投资者文件；未使用媒体和第三方分析作裁决。
- 截止日：所有动态状态按 2026-08-12 判断。
- 写入文件：`审计/子代理交接/m2_scope_nvidia_amd_groq.md`。