# Trainium2 总控抽查记录

抽查日期：2026-08-12  
用途：复核试填草稿中的关键规格、对象边界和冲突；不是新增一轮全面检索。

## 抽查结果

AWS Neuron 2.29.1 的 Trainium2 高层架构页在同一张芯片规格表中给出 8 个 NeuronCore-v3，以及 1,299 FP8、667 BF16/FP16/TF32、2,563 稀疏和 181 FP32 TFLOPS。该页同时给出 96 GiB、2.9 TB/s HBM，3.5 TB/s DMA、1.28 TB/s NeuronLink 和 16 个 CC-Cores。入口：<https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/about-neuron/arch/neuron-hardware/trainium2.html>，定位为 “Trainium2 chip components”。

同版本 NKI 架构指南写 8 个 NeuronCore-v3、4 个 HBM stack、128 个 DMA engine、20 个 CC-Cores 和 4 个 NeuronLink-v3，并给出每核 Tensor Engine 的 158/79/20/316 TFLOPS。因此，CC-Core 的 16/20 和芯片总值与 8 倍单核值的差异确实存在于同一文档版本内，不能靠版本新旧解释。入口：<https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/nki/guides/architecture/trainium2_arch.html>，定位为设备框图段和 Table 11。

Trn2 架构页确认 `trn2.48xlarge`、`trn2u.48xlarge` 各含 16 个 Trainium2，实例内为 4×4 二维 torus；UltraServer 由 4 个 `trn2u.48xlarge`、共 64 个芯片组成，相同坐标的芯片跨实例成 ring。该页还给出实例内 1,024 GB/s/chip、UltraServer 实例间 256 GB/s/chip，以及 EFAv3 3,200 Gbps；表头没有把 UltraServer 的 3,200 Gbps 明确写成单实例还是整系统统计。入口：<https://awsdocs-neuron.readthedocs-hosted.com/en/v2.29.1/about-neuron/arch/neuron-hardware/trn2-arch.html>，定位为 “Trn2 instance specifications”。

动态 Trn2 产品页在同一页面一处写 “Trn2 UltraServers are available now”，另一处仍写 “available in preview”；页面给 UltraServer 12.8 Tbps EFAv3。固定的 2024-12-03 AWS What's New 公告只确认 `trn2.48xlarge` 正式可用、UltraServer 处于 preview。总控以 AWS 官方域名检索 “Trn2 UltraServers generally available”，截至截止日没有找到后续固定 GA 公告。因此，UltraServer 当前状态继续记 `conflicting_unresolved`，EFA 数值继续按统计范围冲突保存。

动态产品页入口：<https://aws.amazon.com/ec2/instance-types/trn2/>。固定公告入口：<https://aws.amazon.com/about-aws/whats-new/2024/12/amazon-ec2-trn2-instances-available/>。

## 对草稿和入库的影响

试填草稿的芯片、实例和 UltraServer 分层成立。当前芯片规格可以把高层表的数值作为优选卡片值，但必须把单核直值及其 8 倍结果保留为冲突成员；CC-Core 数量不能写成唯一已解决值。UltraServer 的产品状态和 EFA 聚合口径也不能在正式事实表中静默裁决。

本次抽查没有解决工艺、面积、晶体管、功耗、SBUF/PSUM 数值带宽、NeuronLink 方向和专用 MoE router/top-K 硬件等缺口；这些仍按既定检索记录使用 `not_found`，不能用推算补齐。