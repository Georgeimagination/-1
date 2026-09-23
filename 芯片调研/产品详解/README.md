# 训练与推理芯片：产品详解

本版覆盖现有 7 家厂商的 36 个产品，每篇先看架构图，再介绍计算、存储、互联和规格。旧资料卡保留作为事实追溯入口。

[打开图文阅读版](产品详解-阅读版.html)

[比较维度与数据支持范围](../比较分析/比较维度与数据支持范围.md)：第一层主图、补充表和第二层机制比较的取舍依据及数据覆盖。

[全产品比较报告](../比较分析/训练与推理架构比较.md)：第一层覆盖 36 个产品的共同维度，第二层比较 12 个家族内或代际产品组。每张图提供 SVG、PDF 和 PNG。

图是按公开资料重绘的功能与层级示意，不是物理版图。确认过的 DRAM 数量直接画出；数量、布局或容量未确认的部分会明确标注。SVG 为可编辑矢量原图，PNG 用于兼容 Markdown 阅读器。各篇保留精确引用与现有来源分歧。

产品详解在 9 月 18 日完成逐厂商扩充及独立代理核对。本轮按 12 个产品组补读官方资料，由主会话合并新增事实与比较分析。官方规格、源码中的软件资源、条件推导和微基准测量分别注明；尚无依据的参数保留缺口，原文冲突并列说明。

## NVIDIA

- [NVIDIA A100 SXM4 80GB](NVIDIA/NVIDIA_A100_SXM4_80GB.md)
- [NVIDIA H100 SXM5 80GB](NVIDIA/NVIDIA_H100_SXM5_80GB.md)
- [NVIDIA H100 PCIe 80GB](NVIDIA/NVIDIA_H100_PCIe_80GB.md)
- [NVIDIA H100 NVL 94GB](NVIDIA/NVIDIA_H100_NVL_94GB.md)
- [NVIDIA L4 24GB](NVIDIA/NVIDIA_L4_24GB.md)
- [NVIDIA L40S 48GB](NVIDIA/NVIDIA_L40S_48GB.md)
- [NVIDIA H200 SXM5 141GB](NVIDIA/NVIDIA_H200_SXM5_141GB.md)
- [NVIDIA H200 NVL 141GB](NVIDIA/NVIDIA_H200_NVL_141GB.md)
- [NVIDIA B200 SXM6 180GB](NVIDIA/NVIDIA_B200_SXM6_180GB.md)
- [NVIDIA B300 SXM 288GB](NVIDIA/NVIDIA_B300_SXM6_288GB.md)

## AMD

- [AMD Instinct MI300X 192GB](AMD/MI300X.md)
- [AMD Instinct MI325X 256GB](AMD/MI325X.md)
- [AMD Instinct MI350P 144GB PCIe](AMD/MI350P.md)
- [AMD Instinct MI350X 288GB](AMD/MI350X.md)
- [AMD Instinct MI355X 288GB](AMD/MI355X.md)
- [AMD Instinct MI455X 432GB EAM](AMD/MI455X.md)

## Google-TPU

- [Google Cloud TPU v4：矩阵计算与 embedding 分工的训练芯片](Google-TPU/Google_Cloud_TPU_v4_one_chip_产品详解.md)
- [Google Cloud TPU v5e：以单个 TensorCore 组织训练与推理](Google-TPU/Google_Cloud_TPU_v5e_one_chip_产品详解.md)
- [Google Cloud TPU v5p：更大的本地存储与三维训练互联](Google-TPU/Google_Cloud_TPU_v5p_one_chip_产品详解.md)
- [Google Cloud TPU v6e（Trillium）：更大的矩阵阵列与独立稀疏路径](Google-TPU/Google_Cloud_TPU_v6e_one_chip_产品详解.md)
- [Google Cloud TPU7x（Ironwood）：双计算 chiplet 的训练与推理加速器](Google-TPU/Google_Cloud_TPU7x_one_chip_产品详解.md)
- [Google TPU 8t：围绕训练的数据供给与矩阵计算](Google-TPU/Google_TPU_8t_one_chip_产品详解.md)
- [Google TPU 8i：为 decoding 配置更大片上存储与归约引擎](Google-TPU/Google_TPU_8i_one_chip_产品详解.md)

## AWS

- [AWS Inferentia1：四个 NeuronCore 与 DDR4 的推理加速器](AWS/AWS_Inferentia1_one_chip_产品详解.md)
- [AWS Inferentia2：HBM 与异步多引擎的推理芯片](AWS/AWS_Inferentia2_one_chip_产品详解.md)
- [AWS Trainium1：双 NeuronCore 的训练数据通路](AWS/AWS_Trainium1_one_chip_产品详解.md)
- [AWS Trainium2：八个核心与结构化稀疏矩阵执行](AWS/AWS_Trainium2_one_chip_产品详解.md)
- [AWS Trainium3：MX 低精度与更大的局部数据通路](AWS/AWS_Trainium3_one_chip_产品详解.md)

## 华为昇腾

- [华为 Ascend 310](华为昇腾/华为_Ascend310.md)
- [华为 Ascend 910](华为昇腾/华为_Ascend910.md)
- [华为 Ascend 950DT](华为昇腾/华为_Ascend950DT.md)
- [华为 Ascend 950PR](华为昇腾/华为_Ascend950PR.md)
- [华为 Atlas 300I A2 32GB](华为昇腾/华为_Atlas300I_A2_32GB.md)
- [华为 Atlas 300I A2 64GB](华为昇腾/华为_Atlas300I_A2_64GB.md)

## Groq

- [Groq GroqChip Processor（第一代）](Groq/Groq_GroqChip_Processor_第一代.md)

## 寒武纪

- [寒武纪思元 590 / MLU590](寒武纪/寒武纪_思元590_MLU590.md)

## 阅读与引用

每篇文末保留本篇实际使用的参考资料，编号与正文一致。架构图中的位置用于说明归属与访问关系，不能据此推断真实版图、缓存必经路径或未公开的 die-to-die 拓扑。理论峰值、稀疏条件、带宽方向及来源冲突随正文保留；没有把旧卡标为已完成理解成所有字段都已有公开答案。
