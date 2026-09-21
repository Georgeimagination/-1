# MI455X 检索与对抗核验记录

> 方法：`deep-research` 只用于检索扇出、来源抓取和主张对抗核验；本文件不是泛化研究报告，也没有使用 `literature-survey`。  
> 截止日：2026-08-13  
> 对象：`OBJ-AMD-MI455X`，正式类型 `module`

本文所用缩写：EAM 指增强型加速器模组，XCD 指加速计算裸片，IOD 指输入输出裸片，HBM 指高带宽内存，MoE 指混合专家模型，FMA 指融合乘加运算。

## 检索路径

本包从五个方向找证据。第一路固定 AMD MI455X 专页，确认 exact-object 名称、当前产品表和 Launch Date；第二路寻找带版本标识的官方 brochure，取得精确规格表；第三路检查 MI400 官方页面，只抽取明确以单个 MI455X 为主语的封装描述；第四路读取 CDNA 5 白皮书，用于架构关系和产品/架构语义分界；第五路反向搜索功耗、供货、累加、MoE/Top-K、HBM 接口宽度、die 面积及早期 19.6 TB/s 说法，专门寻找反例和口径冲突。

最终注册的最小集是 MI455X 专页、MI455X brochure、MI400 固定页和 CDNA 5 白皮书。媒体转述、论坛讨论和早期 19.6 TB/s 数字没有进入来源注册表，因为它们没有补充强于官方资料的新事实，也不能可靠填补现有缺口。

## 三票核验

每项候选主张连续回答三个问题：来源是否直接支持；主语是否确实是单个 MI455X module，而不是 die、tray、rack 或 Helios；精度、稀疏、峰值、方向、单位和版本是否自洽。任一问题不能通过，主张就不进入 facts；证据成立但条件不完整的，限制必须写进条件集。

| 候选主张 | 来源票 | 对象票 | 条件与反例票 | 处理 |
|---|---|---|---|---|
| 产品对象是 MI455X EAM 模组 | 专页与 brochure 直接命名 | brochure 写 `EAM Module`，与正式 `module` 匹配 | EAM 是形态，不临时建立 OAM/EAM 子对象 | 接收；对象类型说明项目归一化边界 |
| 截止日状态为 `announced` | 固定专页标题和 `Launch Date 7/23/2026` 提供公开宣布语境 | 主语是 exact-object MI455X | 正式范围门固定该状态；launch 不证明出货或一般可用 | 接收受控 `announced`；实际可用日期仍为 `not_found` |
| OCP MXFP4 为 40,265 TFLOP/s | brochure 给精确表值，专页为 40.3 PFLOP/s | 表题是 MI455X platform specifications | 表题明确 `AI PEAK THEORETICAL PERFORMANCE`；未说明稀疏和 FMA 计数 | 接收精确 brochure 数字；专页只作舍入复核 |
| OCP MXFP6、MXFP8、FP8 为 20,133 TFLOP/s | brochure 精确表值，专页舍入为 20.1 PFLOP/s | 单个 MI455X 产品表 | 不把相同数值合并成一种格式，也不补 dense/sparse | 分路径接收，稀疏记 `not_specified` |
| FP16、INT8、BF16 的 5,033/10,066 峰值 | brochure 分为基准列与 `W/STRUCTURED SPARSITY` 列 | 单个 MI455X 产品表 | 基准列未打印 dense，稀疏列未给图样 | 基准列记 `not_specified`，第二列记 `structured_sparse` |
| 封装含 8 个 XCD 和 2 个 IOD | brochure 规格表直接给出 | 主语是 MI455X 多芯粒封装 | 数量不除到每 die，也不与 256 WGP 建立平均关系 | 接收两个带 die 类型条件的事实 |
| 432 GB HBM4、12 stacks、23.3 TB/s | 专页、brochure 和 MI400 页共同覆盖 | 明确是单个 MI455X；Helios 的 31 TB 不参与 | brochure 称 peak theoretical；方向未说明；早期 19.6 被当前官方值覆盖 | 接收；GB/TB 按十进制，方向保留未知 |
| 256 GB/s 主机带宽、3.6 TB/s scale-up、600 GB/s scale-out | 官方产品表直接给值 | 都是产品规格行，不是机架二分带宽 | 方向或 payload 不完整；保留厂商 UALoE/UALink 标签 | 接收三个 link 事实；不建拓扑，不补 PCIe/NIC |
| 四条 FLOP/byte 存算比 | 分子与分母都可回源，除法可复算 | 输入属于同一 MI455X | 分子没有 dense 证明和产品级累加语义，字段合同硬门不成立 | 整链删除，不保留为派生事实或指标 |
| MI455X 模组功耗 | 四来源均无单模组定值 | Helios 冷却不能下放 | EAM 与液冷形态不能反推瓦数 | 否决数值，记 `not_found` |
| 产品级累加器或 MoE/Top-K 专用模块 | 产品来源未直接说明；CDNA 5 只有架构机制 | 架构代际不是产品启用资源定值 | 性能格式标签、指令能力和专用硬件不可互换 | 不建事实；产品缺口记 `not_found` |
| Helios 72 模组和机架规格 | 来源确有系统叙述 | 主语是 rack/tray，不是单个 module | 除以 72 也不能自动得到产品额定值 | 全部拒绝迁移，数量为 0 |

## 主动删减与修复

第一版候选有 45 条。早期审计删除了带 Helios 语境的厂商定位、只表示建卡时间的 data cutoff，并一度误删 `announced` 状态；同时保留了四条派生存算比，形成 42 条事实。独立复核后恢复状态事实，再删除四条不满足字段合同的派生链，最终得到 39 条直接事实和 0 条派生事实。这个过程说明预算是上限，不是填充目标。

同时固定三条口径。brochure 的精确 TFLOP/s 或 TOP/s 表值作为规范数字，动态专页的 PFLOP/s 或 POP/s 舍入值只作复核；基准列不写成 dense，只有明确的 `W/STRUCTURED SPARSITY` 列才标 `structured_sparse`；3.6 TB/s 和 600 GB/s 只保留厂商给出的产品级 peak、bidirectional 语境，不解释成单链路速率、NIC 带宽或机架拓扑。

## 最小集复核与结论边界

事实集合变化后，`SELRUN-M2W3-AMD-MI455X-20260813` 已按 39 条直接事实重跑。产品页、brochure、MI400 固定页和 CDNA 5 白皮书各有独有覆盖，删除任一项都会丢失 exact-object 状态/规格、固定精确表、产品级封装或架构关系边界。选择运行仍保持 `draft`，等待不同代理复核。

本轮没有形成跨产品结论，也没有分析训练导向与推理导向芯片的架构差异。核验结果只回答哪些 MI455X module 事实可以暂存、哪些必须留作缺口、哪些来源对当前证据链仍不可替代。