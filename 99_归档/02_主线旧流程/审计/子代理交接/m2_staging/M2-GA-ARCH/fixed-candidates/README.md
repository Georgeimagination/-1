# 固定资料候选与页面核对

本目录不复制正式资料池中的 PDF，只登记本工作包实际核对过的固定材料。四份文件均已存在于项目 `论文/Google_TPU/01_厂商直接架构论文/`，是否进入全局最小资料集由总控合并后的反向移除决定。

| 来源 ID | 固定文件 | 核对位置 | 本包结论 |
|---|---|---|---|
| G01 | `2026_TPUv2_to_Ironwood_Five_Generations.pdf` | PDF 第 2 页表 1；第 3至7 页执行组织、DMA、SparseCore 和软件映射 | 是 v3、v4、v5p、Ironwood 的主要跨代固定来源。芯片总量转入 deferred，实现机制进入架构事实。 |
| G02 | `2020_TPUv2_TPUv3_Domain_Specific_Supercomputer.pdf` | TensorCore、VPU、MXU、软件管理存储与数值语义章节 | 补足 v3 的执行路径，不能由 G01 完全替代。 |
| G03 | `2023_TPUv4_Optically_Reconfigurable_Supercomputer.pdf` | PDF 第 7 页表 4及芯片架构章节 | 补足 v4 的阵列和存储层次；光交换、Pod 规模和实现数值不进入架构卡。 |
| G04 | `2025_Ironwood_HotChips37.pdf` | 双 die、HBM3E、I/O 与 SparseCore 图页 | 在纯架构事实层被 G01 与 G11 覆盖，暂作为反向移除候选；物理封装信息留给实现对象。 |

PDF 页图只用于确认表头、数字与对象作用域。`pdf-renders/` 的临时 PNG 已删除；交付中不保留批量页面图片。