# GA100 的 A100 随机访存独立来源精读

> 子任务：`r1_ga100_06_random_access_memory_reading`  
> 状态：`completed_read_only`，待总控复核  
> 对象：`NVIDIA GA100 die`，以及采用该裸片的 A100 SXM4 80GB 实验设备  
> 资料截止日：2026-08-21  
> 写入边界：只新增本报告和同名 `_assets/` 中的六张逐页渲染图；没有修改正式 CSV、资料卡、来源选择、进度或原始 PDF

## 来源身份和本地副本

本轮精读的来源是 Alden Walker 的 *Enabling Full-Speed Random Access to the Entire Memory on the A100 GPU*。首页标记为 `arXiv:2405.11425v1 [cs.PF]`，提交日期为 2024-05-19。它是六页 arXiv v1 预印本，不是已核实的会议或期刊最终版。首页只列作者姓名，没有单位、通信地址、基金脚注或版本说明。

| 项目 | 核验结果 |
|---|---|
| 本地路径 | `论文/NVIDIA_GPU/02_独立逆向与微基准/2024_A100_Full_Speed_Random_Access_Memory.pdf` |
| SHA-256 | `6ca888b92691f06de9d5d15b268f2e2c738c9f0ef44441e6fd785f65a113a8a9` |
| 文件大小 | 587,055 bytes |
| 页数和版式 | 6 页，US Letter，612 x 792 pt，无旋转、无加密、无表单 |
| PDF 生成信息 | LaTeX with hyperref；pdfTeX 1.40.25；生成时间 2024-05-21 08:32:05 CST |
| 清单一致性 | 路径、页数、大小、哈希、arXiv PDF 入口与 `清单/论文PDF清单.csv` 第 58 行一致 |
| 版本边界 | 首页的 2024-05-19 是 arXiv v1 提交标记，PDF 元数据的 2024-05-21 是文件生成时间；两者用途不同，不构成内容版本冲突 |

清单把作者写作“当前清单未完整著录”，但 PDF 首页清楚列出 Alden Walker。这个差异是清单著录缺口，本任务没有修改清单。PDF 的标题、作者元数据字段为空，身份判断来自首页可见内容和 arXiv 水印。

## 实验对象和条件完整度

论文唯一明确的实验设备是 `SXM4-80GB GPU`，上下文主语为 A100。这个表述足以确定 A100 SXM4 80GB 产品形态，不能据此把 80 GB HBM 容量、约 1900 GB/s 产品带宽或 SXM4 功耗写到 GA100 裸片。论文还介绍 A100 启用 7 个 GPC、每个 GPC 启用 7 或 8 个 TPC、总计 108 个 SM。这是 A100 启用配置，与白皮书的 full GA100 128 SM 物理设计上限分属两套条件。

| 条件维度 | 论文披露 | 证据使用边界 |
|---|---|---|
| GPU 和形态 | A100 SXM4 80GB，单数设备语境 | 只能作为具体 A100 产品上的测量；没有设备序列、VBIOS 或 SKU 编号 |
| 主机 | 未报告 CPU、内存、操作系统、PCIe 或 NUMA 配置 | 不能复现实验主机条件，也不能排除主机侧控制路径影响 |
| driver、CUDA 和编译链 | 未报告 | 不得补用论文引用的 Ampere Tuning Guide 版本，也不能从发表年份推定 CUDA 或 driver |
| 频率和功耗 | 未报告 GPU 频率、锁频、功耗模式、温度或实测功率 | 周期和吞吐不得转换为其他功耗或能效口径 |
| kernel | 描述为 memory access kernel；没有 kernel 名称、源代码、仓库、grid/block 配置、每个 warp 的迭代次数或定时方法 | 可保留访问行为，不能宣称可复现实现 |
| 基本访问 | 每个 warp 随机读取 coalesced 的 32 个 32-bit word，即每次 warp 合并访问 128 bytes | 这是 benchmark 选择的访问大小，不是 GA100 固定事务粒度或 cache-line 规格 |
| 较大访问 | 正文另说 32 个 64-bit word 和 32 个 128-bit word，分别对应 256 bytes 和 512 bytes | 只用于作者给出的近似带宽对照，不代表主图 kernel 的访问粒度 |
| 工作集 | 主图改变总 memory window size；正文只明确阈值在约 64 GB，图中横轴覆盖约 50 至 78 GB；group-pair 实验让两组分别访问不同的 40 GB region | 除 40 GB 和“约 64 GB”外，不从折线节点反读精确工作集数值；论文未说明 GB 是否按十进制 |
| 地址和页条件 | 随机 cache-line 访问；未报告随机分布、种子、虚拟地址分配 API、物理页大小、页映射、prefetch、cache operator、L2 bypass 或 Unified Memory 状态 | 不能由 64 GB threshold 反推 page size、TLB entry 数或 page-walk latency |
| SM 选择 | 使用 `%smid` 和 `%nsmid` 识别 SM；对指定 SM pair、单个 group、group pair 和全部 group 分别运行 | 论文未给出 block 固定到指定 SM 的实现，SM index 与 GPC 的对应关系还被作者明确说明可能因卡而异 |
| 指标口径 | 图中为 `Total throughput (GB/s)`；没有吞吐公式、读字节统计方式、运行时长、warm-up、重复次数、均值、中位数、方差、置信区间或误差条 | 图线只能支持定性趋势和正文明确写出的近似数值，不能按像素估读后生成精确事实 |

由于 host、software、frequency、power 和 statistic basis 都缺失，这个来源没有形成模板要求的完整 `condition_set_id`。后续若结构化，缺失项应原样写入条件说明，不能用 contemporaneous A100 软件环境或官方默认频率补齐。

## 逐页视觉核验

六页均以 150 dpi 渲染为 1275 x 1650 PNG，并逐页人工查看。页面没有脚注；参考文献和链接位于 PDF 第 5 至 6 页。渲染图保存在 `审计/子代理交接/r1_ga100_06_random_access_memory_reading_assets/`。

| PDF 页 | 人工核验内容 | 使用时需要保留的限制 |
|---:|---|---|
| 1 | 标题、作者、arXiv v1 水印、A100 SXM4 80GB、108 SM 产品配置、Tuning Guide 的 incoming remote NVLink TLB 引述、128-byte warp-coalesced 访问定义 | remote NVLink TLB 是引用背景，不能与本文本地 HBM 路径中推测的 TLB 合并 |
| 2 | Figure 1 的两条曲线、横纵轴、64 GB 附近的折点；正文的约 1900、1400 和 1600 GB/s | 1400/1600 是正文写出的近似值；Figure 1 上的点值没有数据表，不做图上估读 |
| 3 | Figure 2 的 SM-pair heatmap、色标和 2 x 2 深色块；14 个 group、每组 6 或 8 个 SM 的说明 | 连续 SM index 属于同一 TPC、half-GPC memory controller 都是作者解释，不是直接测得的电路拓扑 |
| 4 | Figure 3 的重排索引和 14 个对角分块；Figure 4 的单 group 曲线及两组较低曲线 | 颜色曲线没有图例到具体 group 的稳定映射，不把视觉顺序写成硬件 ID |
| 5 | Figure 5 的 group-pair heatmap；两组访问不同 40 GB region；正文从近似双倍吞吐推到 group independence；结论中的 `Apparently` | group 不共享 TLB、每组独有 64 GB TLB 均带推断语气 |
| 6 | Figure 6 的 fully random、SM-to-chunk 和 group-to-chunk 三条曲线及横纵轴；Ampere Tuning Guide 引用 | group-to-chunk 在图示范围保持高位是可见趋势，缺少原始数据时不登记精确带宽 |

## 测量、推断和不可支持事项

论文的直接观测与作者的微架构解释需要拆开。直接观测包括：在所有 warp 对一个大区域进行 128-byte coalesced random reads 时，吞吐在工作窗口超过约 64 GB 后显著下降；只把每个 SM 随机分配到一个 memory half 并不能消除下降；把启用 SM 按探测得到的 14 个 resource group 组织，并让同组 SM 只访问同一个小于 64 GB 的窗口后，整个 80 GB 范围不再出现该下降。单 group 测试观察到 14 个 group，每组有 6 或 8 个 SM；group-pair 测试中，两组分别访问不同 40 GB 区域时，吞吐接近单组的两倍。

正文还明确给出三个近似数值。在 128-byte random access 下，论文的“full speed”是 Figure 1 和 Figure 6 中的该 kernel 基线，不等于产品理论 HBM 带宽。作者称 A100 80GB 的 theoretical bandwidth 约 1900 GB/s，256-byte 和 512-byte warp access 分别达到约 1400 GB/s 和 1600 GB/s，并认为 sequential read 还会更高。这里的 1900 GB/s 是产品语境的参照值，1400/1600 GB/s 是缺少完整条件的近似实测值。三者都不能登记为 GA100 die 的无条件 HBM 带宽。

作者据此提出三层解释。Figure 2 的 2 x 2 深色块“most likely”来自同一 TPC 内两个 SM 的连续 index；14 个 group “reasonable explanation”是每个 GPC 的两半分别由某种 memory controller 服务；结论用 “Apparently” 表述每个 SM group 有自己的 64 GB TLB。这些话可以保存为 `author_inference`，但实验没有直接观测 TLB 实例、page entry、page walk 或 controller RTL。更稳妥的规范化表述是：测试卡上存在与 SM resource group 相关的约 64 GB 地址翻译或内存访问 reach 现象，按 group 限制访问窗口可以避开吞吐崩落。

论文摘要写“any particular thread”访问小于 64 GB 的窗口，但正文先证明按 SM 任意分 half 没有效果，随后要求一个 group 内所有 SM 的所有 warp 协调到同一窗口。正式断言必须采用正文的 group-level 约束。只写“每线程小于 64 GB”会丢掉共享资源边界，也会把一个不充分条件误写成充分条件。

这篇论文没有测量或披露 L2 容量、L2 带宽、L2 latency、page size、TLB entry count、translation latency、HBM channel 映射、memory-controller 数量、read/write 混合、ECC 开销或能耗。大工作集随机读取很可能以 HBM 流量为主，但论文没有给 cache operator 或 L2 bypass 条件，因此图中的 `Total throughput` 不宜改名为纯 HBM bus bandwidth。

## 向 GA100 die 转移证据时的对象边界

| 来源内容 | 合理主体 | GA100 使用裁决 |
|---|---|---|
| A100 SXM4 80GB、80 GB memory、约 1900 GB/s 参照值 | A100 产品、SXM4 模组及其 HBM 子系统 | 不下放到 GA100 die |
| 108 个 enabled SM、14 个观测 group、每组 6 或 8 个 SM | 测试卡上的 A100 enabled configuration | 可作为 GA100 上测得的条件化布局证据；不能变成 full GA100 128 SM 的 group count 或固定 SM-index map |
| 约 64 GB threshold 和 group-to-chunk 规避效果 | A100 SXM4 80GB 上的完整 GPU memory path | 可成为 GA100 address-translation/memory-access 机制的条件化微架构证据，必须保留 tested product、access size、working-window 和条件缺失 |
| “每个 group 有自己的 64 GB TLB” | 作者对 on-die translation resource 的解释 | 只能建推断型断言，不能写成无条件 GA100 结构事实 |
| 256-byte、512-byte random read 的约 1400、1600 GB/s | A100 SXM4 80GB 产品实测 | 可选的产品级近似 benchmark；对 GA100 die 不构成额定或可持续带宽 |

把 14 个 group 直接写成 full GA100 的物理单元数量风险很高。白皮书明确区分 full GA100 的 128 SM 和 A100 启用的 108 SM；本文只测了后者。禁用 TPC 会让启用组出现 6 个 SM，未证明完整裸片上的 group 数量、成员数量和 index 映射保持不变。类似地，translation reach 可能受 page configuration、driver 和产品 memory size 影响，当前来源没有足够信息把它提升为所有 GA100 部署恒定的 64 GB 参数。

## 与白皮书、ISSCC 和 HPEC 微基准的增量与差异

| 主题 | 2020 NVIDIA 白皮书 | 2021 ISSCC | 2022 HPEC 微基准 | 本来源的独有增量和裁决 |
|---|---|---|---|---|
| full die 与产品启用资源 | full GA100 128 SM；A100 enabled 108 SM；给出 GPC/TPC/SM 和 HBM controller 结构 | A100 108 SM，die photo 和产品实现 | background 的 124 SM 已被前轮拒绝 | 本文 108 SM 与一手来源相容；14 个 6/8-SM resource group 是测试卡上的新观察，不改写 full design |
| HBM 产品配置 | 2020 A100 SXM4 40 GB、1555 GB/s | 40 GB A100，约 1.56 TB/s | A100 SKU 和容量未报告，global memory 只给 290 cycles | 本文测的是后续 A100 SXM4 80GB，并引用约 1900 GB/s；差异来自产品版本和 HBM 配置，不是 GA100 die 冲突 |
| L2 和片上 memory | 40 MB L2、分区、slice、5120 B/clk 等官方结构 | L2 分区和层级 crossbar | L1/L2/shared 的 pointer-chasing cycles | 本文不增加 L2 容量或 latency，只增加大窗口随机读的 aggregate throughput 现象 |
| 地址翻译 | 没有给本地随机访问的 TLB reach 定值 | 未覆盖 TLB/page translation | 明确未覆盖 TLB；global 290 cycles 也不能反推 translation | 约 64 GB cliff、group-local 避免方法和 TLB 解释均为独有内容；其中 cliff 和规避效果是测量，TLB ownership 是推断 |
| SM 资源共享 | 官方给 GPC/TPC/SM 组织和内存控制器框图 | die photo 只确认区域存在 | 没有 SM-to-memory group 探测 | SM-pair、单 group、group-pair 三组 probe 构成独有验证；half-GPC/controller 对应仍未被官方确认 |
| throughput 口径 | 额定和理论产品带宽 | 产品峰值 | latency cycles 和误写单位的 Tensor throughput，测试方法不同 | 本文是 warp-coalesced random-read aggregate GB/s，不能与 sequential peak、pointer-chasing latency 或 Tensor throughput 比较 |

没有发现需要登记为同条件数值冲突的项目。40 GB 与 80 GB、1555/1560 GB/s 与约 1900 GB/s 都属于不同 A100 产品版本。108 enabled SM 与 128 full-design SM 也是一手来源已经明确的启用状态差异。本文的 128-byte random-read baseline 低于理论带宽，作者已用 HBM 对大 transaction size 的需求解释，两者不是同一性能口径。

真正需要保留的是证据强度差异。官方 Tuning Guide 被本文引用的 `64GB NVLink TLB for incoming remote requests` 属于 incoming remote NVLink 路径；本文 kernel 测的是本地 A100 memory access。两者数值相同不能证明它们是同一个 TLB。当前只能说官方 remote-path 限制为作者提供了线索，本文另外观察到本地路径上的约 64 GB 现象。

## 0.3 字段合同承接情况

当前合同只能部分承接本来源。它能保存定性机制和带条件吞吐，却没有专门的 TLB reach、TLB sharing scope、page size、page-walk latency 或 SM resource-group mapping 字段。条件表也没有 host、address-allocation 和 random-distribution 专列，只能把这些内容放在 `notes`，并把已注册的 `software_version`、`frequency`、`power_mode` 和 `statistic_basis` 标为未报告。

| 候选内容 | 可用字段 | 承接判断 |
|---|---|---|
| 约 64 GB cliff 和 group-local window 规避 | `FIELD-MEM-VIRTUAL-MEMORY` | 可用 text 保存测量现象、产品对象、访问条件和作者解释；字段过宽，必须把 direct measurement 与 author inference 拆成不同来源断言 |
| group 内共享 memory-access resource | `FIELD-COMP-SHARED-RESOURCE` | 只能保存“测试观察到共享关系”；不能据此登记 controller 或 TLB 的物理实例 |
| resource group 的局部性 | `FIELD-MEM-LOCALITY-SCOPE` | `compute_cluster` 枚举可作后续规范化候选，但本文的 resource group 尚未与正式 compute cluster 对象等同，当前不宜直接填入 |
| 约 1400/1600 GB/s random-read throughput | `FIELD-MEM-READ-BW`，或产品 benchmark 的 `FIELD-BENCH-THROUGHPUT` | 数值在正文可定位，但条件不完整、主体为 A100 SXM4 80GB；若主线只接受 GA100 die 事实，不应写入 die |
| 128/256/512-byte warp access | 条件集的 `workload_operator`、`message_size_bytes` 和 `notes` | 应作为 benchmark 条件。`FIELD-MEM-GRANULARITY` 描述存储层固有粒度，不应用来保存测试者选择的访问大小 |
| 14 个 TLB instance 或固定 64 GB TLB capacity | 无可直接采用的精确字段；`FIELD-MEM-INSTANCE-COUNT` 也不合适 | 拒绝。14 是 resource group 的观察数量，TLB instance 和 64 GB reach 均为作者解释，且只覆盖一张启用 108 SM 的卡 |
| Figure 1、4、5、6 曲线点 | `FIELD-MEM-READ-BW` 理论上可容纳 | 原始数据未提供，禁止从图上估读成正式数值；可以保存趋势和原文定位 |

如果总控接收这篇来源，建议先建立两条窄断言。一条记录 A100 SXM4 80GB、128-byte warp-coalesced random-read、总窗口超过约 64 GB 时出现 throughput cliff，以及 group-to-chunk 方法消除该 cliff；证据类型为第三方实测。另一条单独记录作者推断的 group-local 64 GB TLB，证据类型为作者解释。两条都不应使用 `COND-NONE`。

## 最小来源集和反向移除

本来源值得有条件进入 GA100 工作包的最小来源集，角色限定为 `independent_validation`。入选前提是总控接受上述虚拟内存或 memory-access limitation 的条件化事实。反向移除后，白皮书、ISSCC 和 2022 HPEC 都不能覆盖以下证据：A100 SXM4 80GB 上约 64 GB 工作窗口的随机读取 cliff、14 个启用 SM resource group 的 probe、按 group 约束访问窗口后恢复全 80 GB 随机访问的结果。只要其中任一项成为正式接受事实，移除本来源就会留下不可替代缺口。

入选理由不能写成 A100 身份、80 GB HBM 容量、约 1900 GB/s 产品带宽、108 SM 或 GPC/TPC/SM 基本组织。这些内容分别属于产品级作用域，或已被一手来源覆盖。1400/1600 GB/s 也不宜承担不可替代理由，因为实验条件和统计口径不完整。

如果总控不接受定性 translation/resource-group 证据，或者要求所有 benchmark 必须披露 driver、CUDA、频率和统计方法后才能建立正式事实，那么本来源应标为 `lead_only`，不能因已经精读就进入最小集。当前建议是保留为待建条件化断言的 `selected` 候选，完成对象关系和断言拆分后再执行正式反向移除，不直接修改现有 selection run。

## 尚未核实和建议的后续处理

本文没有代码和原始数据，作者单位也未列出，当前无法独立复现 14-group map 或核对吞吐曲线。若需要提升证据强度，应先寻找作者代码、补充材料或后续版本，重点核对 device query、driver/CUDA、锁频、page size、memory allocation、随机地址生成、kernel launch、计时公式、重复次数和原始数据。没有这些材料时，正式文本应继续使用“约 64 GB threshold”“测试卡上观察到”和“作者推断”等限定语。

还应定向核对论文引用的发布期 Ampere Tuning Guide §1.4.3，确认 `64GB NVLink TLB` 的原始版本、主语和 incoming remote request 条件。即使官方表述得到固定版本支持，也只能形成 remote NVLink path 的独立事实，不能反向证明本文本地 memory kernel 使用同一 translation structure。

## 验证、运行情况和写入文件

本地 PDF 已完成身份、SHA-256、页数、元数据和清单一致性核对。六页均完成文本提取辅助阅读、逐页渲染和人工视觉检查，图轴、图例、色标、正文限定语、参考文献和页面链接可读。没有发现脚注。所有 PNG 都是 1275 x 1650、8-bit RGB，文件可正常解析。

Poppler 渲染返回退出码 0，并成功生成六张页面图。运行时反复出现 Fontconfig 配置和 cache 目录不可写警告，属于 tool/runtime warning；页面没有缺字、黑块、裁切或图表损坏。首次批量调用图片查看工具时使用了外层目录作为相对路径基准，因而报告 `No such file or directory`；改用主线内绝对路径后六页全部打开。这次失败归类为 model/operator mistake，未造成文件丢失或证据降级。没有发生用户中断、sandbox denial、approval failure 或 remote service error。

本报告按研究审计记录处理，并完成 `report-humanizer` 两轮检查。机器扫描结果为 `No machine-detectable AI tells found`。人工逆向复读覆盖全部标题、每节首段、表格引导、对象边界转场和结尾，重点检查了模板化开场、重复收束、机械对称分项以及限定词是否被润色掉。没有发现需要继续修改的 AI 套路；文中较多的“不能”和条件限定来自证据边界，予以保留。项目没有提供同类人工写作样本，剩余风险是无法进行样本文风对照，不影响技术事实和来源裁决。

本子任务写入以下文件：

- `审计/子代理交接/r1_ga100_06_random_access_memory_reading.md`
- `审计/子代理交接/r1_ga100_06_random_access_memory_reading_assets/page-1.png` 至 `page-6.png`

没有修改 `数据/`、`最小参考资料库/`、`资料卡/`、`进度/`、`清单/`、`论文/`、README 或 AGENTS 文件。
