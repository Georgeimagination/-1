# H100 SXM5 80 GB 试填交接

## 任务状态

状态为 `complete_draft_pending_parent_review`。资料卡草稿已写入指定厂商目录；未修改全局 CSV、README、AGENTS、研究计划或进度文件，也未创建结构化候选片段。本次交付只覆盖 `OBJ-NVIDIA-H100-SXM5-80GB`，并用 `OREL-NVIDIA-H100-IMPLEMENTS-HOPPER` 关联 `OBJ-NVIDIA-HOPPER-ARCH`。

## 输入与对象边界

开始前已完整阅读 `AGENTS.md`、`研究计划.md`、`进度/当前状态.md`、`资料卡/字段字典.md` 0.2、`资料卡/模板.md` 0.2、`审计/子代理交接/h100_source_prep.md`、`schema_tables.md` 和 `model_inventory.md`。资料卡的对象层级固定为 H100 SXM5 80 GB 模组；GH100 裸片、H100 PCIe/H800、Grace Hopper、HGX/DGX 和 NVLink Switch System 只用于边界判断，不把其规格回填到本对象。

## 已读取与采用的来源

本次最小来源候选为四个来源家族：

| 来源 | 版本或本地位置 | 用途 | 处理意见 |
|---|---|---|---|
| NVIDIA H100 Tensor Core GPU Datasheet | 当前 PDF，元数据日期 2024-09-24；稳定入口 `https://nvdam.widen.net/s/q6rttxs2pw/h100-datasheet-2287922` | H100 SXM 当前定版产品规格 | 选入 `core_spec` |
| NVIDIA H100 Tensor Core GPU Architecture | v1.04，封面注明最终 GPU/内存时钟和 TFLOPS | 稠密/稀疏吞吐、累加格式、存储层次、TMA/DSM/集群、NVLink/PCIe 与固定功能 | 选入 `architecture_mechanism`；官方固定 PDF 尚待重新取得 |
| NVIDIA CUDA Hopper Tuning Guide | 13.3，2026-06-25；`https://docs.nvidia.com/cuda/pdf/Hopper_Tuning_Guide.pdf` | 当前 CUDA 资源限制、TMA/DSM、共享内存 carveout、DPX、NVLink | 选入 `architecture_mechanism` / `programming_limit` |
| NVIDIA Hopper H100 GPU，Hot Chips 34 | `论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_Hopper_H100_GPU_HotChips34.pdf` | 2022 发布期 3 TB/s 与未定版脚注 | 仅选入 `status_version_evidence` |

当前 H100 产品页对定版数据手册的核心规格没有新增信息，建议 `redundant_covered`，只在需要动态在售状态时另设访问记录。`2023_NVIDIA_Hopper_H100_GPU_IEEE_Micro.pdf` 的架构内容与白皮书和 Hot Chips 高度重合，建议暂不进入最小集合。`2024_Benchmarking_Dissecting_NVIDIA_Hopper.pdf` 和 `2025_Dissecting_NVIDIA_Hopper_Extended.pdf` 的测试对象为 H800，本卡筛为 `out_of_scope`；后者即使在 Hopper 架构层有独有微基准，也应由架构对象单独评估，不能给 H100 SXM5 回填实测带宽。Grace Hopper、DGX/HGX 和 NVSwitch 系统资料同理只作关系或边界来源。

## 已完成内容

已在 `资料卡/NVIDIA/产品/H100_SXM5_80GB_试填草稿.md` 建立完整人读草稿，内容包括：

1. 模组、裸片、架构与系统对象的严格区分；
2. 132 SM、66 TPC、8 GPC、CUDA core 与 Tensor Core 数量，以及 GH100 工艺事实的正确对象层级；
3. FP8、FP16、BF16、TF32、FP64、INT8 Tensor Core 的稠密/稀疏峰值和已公开累加格式；
4. FP16、BF16、FP32、FP64、INT32 非 Tensor Core 峰值，并解释厂商未单列独立向量/标量总峰值；
5. 寄存器、组合 L1/纹理/共享内存、L2、HBM3 的容量、组织、带宽状态与 ECC/压缩边界；
6. 基于当前 3.35 TB/s HBM3 名义带宽复算的稠密计算/带宽比；
7. 18 条 NVLink 4 链路、每方向与双向聚合口径、PCIe 5.0 x16 带宽，以及 HGX/NVSwitch 拓扑的系统层边界；
8. TMA、线程块集群、DSM、DPX、Transformer Engine 的机制和“不是任意 Top-K/MoE 专用模块”的边界；
9. 发布期 3 TB/s、v1.04 的 3,352 GB/s 与当前数据手册 3.35 TB/s 的版本关系；
10. 最小来源候选、重复/越界来源筛选和未解决字段。

## 已确认的关键数值

H100 SXM5 的 Tensor Core 稠密峰值为：FP8 1,978.9 TFLOP/s，FP16/BF16 989.4 TFLOP/s，TF32 494.7 TFLOP/s，FP64 66.9 TFLOP/s，INT8 1,978.9 TOPS；支持的结构化稀疏口径把 FP8、FP16/BF16、TF32 和 INT8 分别提高到 3,957.8、1,978.9、989.4 TFLOP/s 与 3,957.8 TOPS。FP8 支持 FP16 或 FP32 累加，FP16 支持 FP16 或 FP32 累加，BF16 支持 FP32 累加。

非 Tensor Core 峰值为 FP16 133.8、BF16 133.8、FP32 66.9、FP64 33.5 TFLOP/s，以及 INT32 33.5 TOPS。HBM3 为 80 GB、五个栈、5,120-bit 接口，当前名义带宽 3.35 TB/s；L2 为 50 MB；组合 L1/纹理/共享内存为 256 KB/SM，共享内存最多 228 KB/SM；寄存器文件为 65,536 个 32-bit 寄存器/SM，即 256 KB/SM。

NVLink 4 为 18 条链路，每条每方向 25 GB/s、双向合计 50 GB/s，模组全部链路双向聚合为 900 GB/s。PCIe 5.0 x16 为每方向 64 GB/s、双向合计 128 GB/s。TDP 最高 700 W，可配置。

## 版本与来源问题

2022 发布期资料中的 3 TB/s 带有“内存数据率未最终确定”条件；白皮书 v1.04 的 Table 3 给出 3,352 GB/s；当前数据手册给出 3.35 TB/s。本次按版本变化处理，不登记为矛盾。正式入表时应让 3 TB/s 只承担历史版本证据，当前事实与所有派生比值使用 3.35 TB/s。

子代理交付时，白皮书官方固定 PDF 仍无法取得。总控随后从 NVIDIA Hopper 架构页的官方 “Read Whitepaper” 链路进入 NVIDIA Resources 和 Widen，成功下载 v1.04 固定 PDF，并登记 71 页、文件大小和 SHA-256。该复现性缺口已经关闭，详情见 `审计/子代理交接/h100_whitepaper_acquisition.md`。

## 尚未核实或不应猜测的字段

所选一手来源没有发布独立的向量峰值和标量峰值，也没有发布寄存器、L1/共享内存和 L2 的官方带宽。TF32、FP64 Tensor Core 与 INT8 Tensor Core 的累加格式在本次最小来源中未形成可直接入表的明确表项。Tensor Core 内部数据通路宽度、有效 NVLink/PCIe payload、持续性能，以及专用 MoE routing 或通用 Top-K 模块也没有一手定值。上述字段没有“厂商明确声明未公开”的证据，应使用 `not_found`，不能写成零、false，也不能用 H800 或系统聚合值代替。

精确首发供货日和当前供货状态未在本次交付中固定。产品页存在只能说明有当前官方入口，不能单独证明特定地区或渠道的供货状态。

## 验证与工具情况

资料卡与交接文件均使用 UTF-8 无 BOM 单独写入，并在写入后检查文件存在、长度和首行。数据手册三页及 Tuning Guide 的关键页已渲染并人工核对版面，避免从提取文本误读表头或脚注。没有改动 `论文/` 和四个清单，因此没有触发资料池基线变化；没有写结构化数据，因此没有改动全局外键。

工具方面，最初一次同时加载工作区依赖与技能说明的调用长时间无输出后被终止，分类为工具/运行时故障，随后改为逐项读取并完成，未降低结果质量。第一次在沙箱内下载官方 PDF 时网络连接失败，随后经批准的网络访问成功；这不是模型能力或实现错误。官方白皮书入口不可用和镜像 403 均为远端服务问题，已在上文保留。

## 写入文件

- `资料卡/NVIDIA/产品/H100_SXM5_80GB_试填草稿.md`
- `审计/子代理交接/h100_pilot.md`

## 建议下一步

总控复核时，建议先检查三个地方：第一，矩阵吞吐事实是否按稠密/稀疏、时钟和累加格式拆成独立 condition set；第二，3 TB/s 与 3.35 TB/s 是否通过来源版本关系保存，而不是覆盖旧值；第三，NVSwitch 集合通信和 HGX 拓扑是否留在系统对象。随后再把草稿拆成正式 `facts`、`condition-sets`、`precision-paths`、`memory-levels`、`links`、`special-capabilities` 以及来源断言，补取官方白皮书 PDF 后完成固定文件哈希。