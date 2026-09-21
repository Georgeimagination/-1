# Trainium2 试填子代理交接

## 任务状态

- 状态：`completed_draft`，等待总控复核与正式入库。
- 资料截止：2026-08-12。
- 完成范围：AWS Trainium2 架构/芯片及相关 Trn2 云对象的试填资料卡、来源筛选、冲突和缺口记录。
- 未做事项：没有修改任何全局 CSV、型号索引、README、AGENTS、研究计划或进度文件；没有创建结构化候选 CSV；没有做跨厂商训练/推理架构分析。
- 方法边界：本轮技术检索只使用 AWS/Amazon 一手页面和 AWS Neuron 版本化文档；没有以第三方资料补一手缺口，也没有使用 `literature-survey`。

## 输入与已读项目文件

执行前已读：

- `AGENTS.md`
- `研究计划.md`
- `进度/当前状态.md`
- `资料卡/字段字典.md` 0.2
- `资料卡/模板.md` 0.2
- `审计/子代理交接/model_inventory.md`
- `审计/子代理交接/object_candidates.csv`
- `审计/子代理交接/schema_tables.md`
- `report-humanizer` 与 `shuorenhua` 的 SKILL 说明及相关规则文件

对象候选沿用现有 `CAND-*` 标识。本次没有生成正式 `product_id`、`fact_id` 或 `source_id`，避免绕过总控的全局标识分配。

## 对象边界

已明确拆分以下六层对象：

| 候选对象 | 层级 | 边界与关系 |
|---|---|---|
| `CAND-AWS-ARCH-TRAINIUM2` | `architecture` | Trainium2 / NeuronCore-v3 的架构能力 |
| `CAND-AWS-TRAINIUM2-CHIP` | `silicon_package/package` | 单个 8-NCv3 Trainium2 器件；不含云实例聚合值 |
| `CAND-AWS-EC2-TRN2-3XLARGE` | `product_sku/cloud_accelerator` | 1 个 Trainium2 的 EC2 实例 |
| `CAND-AWS-EC2-TRN2-48XLARGE` | `product_sku/cloud_accelerator` | 16 个 Trainium2、4×4 torus 的普通 Trn2 实例 |
| `CAND-AWS-EC2-TRN2U-48XLARGE` | `product_sku/cloud_accelerator` | 16 个 Trainium2、作为 UltraServer 组成单元的实例 |
| `CAND-AWS-TRN2-ULTRASERVER-64` | `system/server` | 4 个 `trn2u.48xlarge`、64 个 Trainium2 的系统 |

卡中所有实例和 UltraServer 聚合值均保留在本层。没有把 16/64 芯片系统值除算为单芯片事实。

## 已确认的主要事实

架构方面，每个 Trainium2 含 8 个独立 NeuronCore-v3（NCv3）。每个 NCv3 有 Tensor、Vector、Scalar 和 GPSIMD 四条计算路径；Tensor Engine 的物理脉动阵列为 128×128，FP8 double-row 模式在编程上呈现 256×128 收缩形态。当前高层架构页直接给出单芯片 1,299 FP8 dense、667 BF16/FP16/TF32 dense、181 FP32 dense 和 2,563 structured-sparse TFLOPS。单核页另给 158/79/20/316 TFLOPS，二者不能互相覆盖，已建立冲突记录。

向量和标量路径的直接公开值分别为每 NCv3 1.0 FP32 TFLOPS 和 1.2 FP32 TFLOPS。卡中列出 8.0/9.6 TFLOPS 的芯片简单乘算，但只标 `public_derived/pending_verification`，未作为正式芯片峰值。GPSIMD 每个引擎有 8 个 512-bit 可编程处理器，能执行 C/C++，但没有一手算术 FLOPS 数值。

矩阵乘输入支持 FP8 E4M3/E5M2、BF16、FP16、TF32、FP32；S2 还记载 FP8_E3 可执行但不具 double-FP8 吞吐。Tensor Engine 内部累加语义与 NCv3 PSUM 目标均为 FP32。Vector Engine 的 BF16/FP16 性能模式仍以 FP32 计算。RNE 和 stochastic rounding 均已确认；cFP8 支持可调指数偏置。物理累加器位宽和中间乘积位宽没有找到。

存储为 HBM→SBUF→PSUM 三级。单芯片有 4 个 HBM stack、96 GiB、2.9 TB/s；每 NCv3 的 SBUF 为 28 MiB（128×224 KiB），PSUM 为 2 MiB。SBUF 是软件管理 SRAM，不能写成硬件 cache。主 DMA 为 128 个 engine、芯片聚合 3.5 TB/s，支持 inline compression/decompression。GPSIMD 集成 DMA 的 307 GB/s 是每个 NCv3 内 8 个 GPSIMD 处理器合计，读写方向各 153 GB/s，不能混入芯片主 DMA 聚合值。

数据搬运方面，DMA 支持 HBM→SBUF 和 SBUF→SBUF 的 bit-accurate transpose；官方给出最高 90% 与 50% DMA 利用率。每 NCv3 有 2 个 DGE（Descriptor Generation Engine）硬件块，用于按需生成 copy/transpose 描述符；当前不支持 indirect gather/scatter，从 Scalar Engine 触发的一条 DGE DMA 指令约 600 ns。

互联方面，单芯片有 4 个 NeuronLink-v3 接口，公开芯片聚合带宽为 1.28 TB/s，但方向和有效载荷口径未说明。16 芯片实例内为 4×4 2D torus，架构表给 1,024 GB/s/chip intra-instance。UltraServer 由四个 `trn2u.48xlarge` 组成，对应 XY 坐标的芯片再连成 ring，另有 256 GB/s/chip inter-instance。EFAv3 属于实例/系统 scale-out 网络，不是芯片互联。

特殊算子方面，Tensor Engine 支持 M:N structured sparsity，官方列出 4:16、4:12、4:8、2:8、2:4、1:4、1:2。Scalar Engine 加速 GELU、sqrt；Vector Engine承担 reduction 和 elementwise 一般路径。Attention 相关一手证据是 DMA transpose 能转换 K-cache 布局并适用于 self-attention，不能写成专用 attention engine。2026 年 NKI Library 已有实验性融合 RMSNorm/Router Top-K 和 MoE collective 内核，但这是软件实现；未找到 Trainium2 专用 MoE routing 或 top-K 物理模块。

单芯片峰值/HBM 带宽候选派生为：FP8 dense 447.9、BF16/FP16/TF32 dense 230.0、FP32 dense 62.4、structured sparse 883.8 FLOP/byte。SBUF 和 PSUM 数值带宽未找到，因此没有计算相应层级存算比。

## 来源审计与最小集建议

下列来源均有不能被更强来源完全替代的贡献。正式入库时应把“来源家族、内容版本、访问入口”拆开；同一 2.29.1 内容的 HTML、RST 和 PDF 入口不能算成三份独立来源。

| 草稿来源 | 来源家族 / 版本 | 独有贡献 | 建议状态 |
|---|---|---|---|
| Trainium2 Architecture | AWS Neuron 2.29.1 | 芯片聚合算力、HBM、DMA、NeuronLink、SBUF 聚合、CC-Core=16 | `selected_core` |
| Trainium2 Architecture Guide for NKI | AWS Neuron 2.29.1 | 引擎通路与频率、FP8 模式、SBUF/PSUM、GPSIMD DMA、transpose、DGE、CC-Core=20 | `selected_core` |
| NeuronCore-v3 Architecture | AWS Neuron 2.29.1 | 稀疏模式全集、向量/标量格式、GPSIMD 512-bit | `selected_supplement` |
| `nki.isa.nc_matmul` | AWS Neuron 2.29.1 | 物理阵列、输入组合限制、FP32 内部累加与 PSUM 输出 | `selected_supplement` |
| Logical NeuronCore configuration | AWS Neuron 2.29.1 | LNC=1/2、HBM bank 和物理核心共享关系 | `selected_supplement` |
| Amazon EC2 Trn2 Architecture | AWS Neuron 2.29.1 | 16/64 芯片拓扑、实例/系统聚合值、NeuronLink 分层 | `selected_core` |
| EC2 Trn2 product page | 动态页，2026-08-12 观察 | `trn2.3xlarge`、`trn2u.48xlarge` 当前配置，UltraServer EFA 和状态冲突 | `selected_dynamic` |
| NKI Collectives index | AWS Neuron 2.29.1 | all-reduce/gather、reduce-scatter、all-to-all(-v)、permute API 集合 | `selected_supplement` |
| Trn2 GA What's New | 2024-12-03 固定公告 | `trn2.48xlarge` GA 与 UltraServer preview 日期 | `selected_status` |
| Trn2 launch AWS News Blog | 2024-12-03 固定发布帖 | 当时区域、95% HBM 利用率声明、稀疏值历史冲突 | `selected_conflict_history` |
| Trainium2 press announcement | 2023-11-28 固定新闻稿 | Trainium2 正式公布日期和原始产品定位 | `selected_status` |
| Neuron 2.21 What's New | 2024-12-23 固定公告 | 首次 Trainium2 SDK 支持与当时软件能力 | `selected_software_history` |
| Neuron 2.31 What's New | 2026-07-08 固定公告 | 截止日前软件状态、MoE/attention 实验内核、Trn2 默认编译后端 | `selected_software` |
| RMSNorm Router Top-K TKG API | latest，2026-08-12 观察 | 证明 Router Top-K 是实验性 NKI Library 内核，不是已证实专用硬件 | `selected_software_dynamic` |

已建议筛除或降级：

- 同一内容版本的 RST、PDF、HTML 镜像入口：`duplicate_endpoint`。
- AWS What's New 的翻译/地区镜像：`duplicate_endpoint`，除非英文主入口不可访问。
- 旧 Neuron 版本架构页：若没有独有历史数值，则 `superseded`。
- 只复述 AWS 规格的媒体文章：`covered_by_primary`。
- AWS EC2 通用 accelerated-instance 规格页：其 Trn2 accelerator-memory 单元写成 512 GiB/chip 和 8,192 GiB/16 chips，并把 `trn2u.48xlarge` 写成无 accelerator，与三份专页冲突；相关单元建议 `rejected_unreliable`，页面只可按字段择用其独有的通用实例属性。

## 未解决冲突

1. 同一 Neuron 2.29.1 文档集内，芯片总值 1,299/667/181/2,563 TFLOPS 与 8×单核的 1,264/632/160/2,528 TFLOPS 不一致。原因没有公开解释。建议芯片规范候选采用高层芯片表，同时保留单核直接事实和 `conflicting` 状态。
2. 同一版本的 Trainium2 高层页写 16 个 CC-Cores，NKI 架构指南写 20 个。不能选一个后静默删除另一个。
3. 2024-12-03 发布博客写 5.2 sparse FP8 PFLOPS/chip、83.2 PFLOPS/instance；当前 2.29.1 高层页和实例表写 2.563/41。建议当前规范候选取互相一致的 S1/S6，发布博客保留为历史冲突证据。
4. UltraServer 在 2024-12-03 固定公告为 preview；当前动态产品页同页同时写 “available now” 和 “available in preview”。截至 2026-08-12 的正式供货状态仍需固定公告确认。
5. UltraServer EFAv3 在 2.29.1 架构表为 3,200 Gbps，在产品页为 12.8 Tbps。可能分别是每组成实例和系统聚合，但原表未注明，故保留 `conflicting_scope`。
6. AWS EC2 通用规格表的 Trn2 accelerator memory 和 `trn2u` accelerator 身份与专门产品文档冲突，建议拒绝这些具体单元。

## 尚未核实的字段

以下字段已在官方域名和 AWS Neuron 版本文档中检索，但本轮未找到定值，均写为 `not_found`，不等同于“厂商从未公开”：

- SBUF/PSUM 数值带宽、片上存储访问延迟、主 DMA 读写方向口径；
- 工艺节点、代工厂、晶体管数、裸片面积、封装类型/尺寸、TDP/典型功耗、HBM 接口位宽；
- NeuronLink 单向/双向口径、每链路带宽、有效载荷、延迟、对分带宽、超售和故障降级；
- 物理累加器位宽、乘积中间位宽、完整舍入点；
- 专用 sort、sampling、MoE router、router top-K 物理模块；
- 芯片级 ECC/RAS、故障域、分区/虚拟化、安全隔离和完整遥测清单。

状态类缺口：`trn2.3xlarge` 和 `trn2u.48xlarge` 的首个固定可用日期记 `pending_verification`；UltraServer 截止日供货状态同时记 `pending_verification` 和 `conflicting`。

## 写入文件

- `资料卡/AWS/Trainium2_试填草稿.md`
- `审计/子代理交接/trainium2_pilot.md`

没有写入其他文件。

## 验证与交付检查

- 已用 UTF-8（无 BOM）写入两个 Markdown 文件，并在每次写入后用 `Test-Path` 和 `Get-Content -Encoding UTF8` 检查。
- 资料卡中的芯片、实例和 UltraServer 数值均按对象层级回读；未发现把 16/64 芯片聚合值下放到芯片层的情况。
- 派生的 FLOP/byte 使用单芯片直接公开值和 2.9 TB/s 复算；向量/标量芯片乘算保留 `public_derived/pending_verification`。
- 已检查 Markdown 公式分隔符；公式只使用美元符号语法。
- 两份文档均已通过 `report-humanizer` 机器扫描；随后按 `shuorenhua` 的保真规则人工回读，保留数字、状态、对象责任和来源定位。

## 建议下一步

总控复核时先处理对象标识和六项冲突，再决定哪些草稿来源进入正式最小集。正式结构化导入应把芯片聚合峰值、单核直值、系统聚合值分成不同事实行；每条保留 source assertion、原始单位和原文 locator。三张试填卡完成后，应重点复审 `fact_status`、`implementation_level`、`bandwidth_basis`、动态页 observation 时间和 conflict 表的枚举是否足以表达本卡出现的情况。