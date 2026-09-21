# 华为 Ascend 950 三对象身份与来源预检

> 工作包：`M2-W3-HUAWEI-ASCEND950-PHYSICAL`  
> 核查日期：2026-08-13  
> 结论：`ready_for_fact_extraction`  
> 本轮边界：固定官方来源、核对三对象身份与状态，不生成完整事实包或资料卡

NPU（Neural Processing Unit）指神经网络处理器，HBM（High Bandwidth Memory）指高带宽内存，PCIe（Peripheral Component Interconnect Express）是一种高速外设互联。本文所说的裸片是封装内的硅片，封装则把裸片与相应存储器等部件组合成可集成产品；Atlas 350 是更上一层的 PCIe 加速卡。SHA-256 是固定内容的 256 位散列值，用来确认后续抽取仍读取同一份页面。

## 三对象结论

`OBJ-HUAWEI-ASCEND-950-DIE` 的身份门通过，可以进入共享裸片事实抽取。H-2 在 2025 年 9 月 18 日的主题演讲中直接写明，Ascend 950PR 与 Ascend 950DT 使用同一颗 Ascend 950 Die。这项陈述支持当前两条 `package_contains_die` 关系，但不能据此给裸片写入独立供货状态，也不能把两种封装的 HBM 容量或带宽写到裸片。

`OBJ-HUAWEI-ASCEND-950PR` 的身份门通过，可以进入事实抽取。H-2 先把它定义为与 HiBL 1.0 组合的封装变体，并预告 2026 年第一季度可用；H-6 在截止日仍把 950PR 列为独立处理器产品；H-7 直接说明 Atlas 350 加速卡采用 Ascend 950PR。H-12 在 2026 年 3 月 20 日记录了搭载 950PR 的 Atlas 350 正式上市，以及七家伙伴首发整机。因此，950PR 可以记录“通过已上市 Atlas 350 进入商用产品”的状态证据。该表述不等于 950PR 作为独立封装已经零售，也不等于已经找到客户交付数量。

`OBJ-HUAWEI-ASCEND-950DT` 的身份门也通过，但状态只到 `announced`。H-2 明确给出 950DT 身份、与共享裸片及 HiZQ 2.0 的组合，并把可用时间写为 2026 年第四季度。H-6 的导航在截止日存在独立 950DT 路由；然而同日固定的 `?tag=950dt` 页面在服务器渲染正文中仍显示 950PR 内容，没有 950DT 独立产品正文、正式可用或客户交付陈述。H-7 与 H-12 也没有提供 950DT 的正式上市证据。因此后续只能抽取身份、封装和路线图事实，不能把它提升为正式可用。

## 固定来源

| 来源键 | 官方标题或页面 | 固定文件 | 字节数 | SHA-256 | 当前职责 |
|---|---|---|---:|---|---|
| H-2 | Groundbreaking SuperPoD Interconnect: Leading a New Paradigm for AI Infrastructure | `fixed-candidates/huawei-connect-2025-ascend-roadmap-2026-08-13.html` | 132,684 | `8bf0f453e143562c7b5f3ead61f54a35da6020689dbc20aede772da0d00d7499` | 共享裸片、两种封装及路线图状态 |
| H-6 | 昇腾NPU处理器 | `fixed-candidates/hiascend-processor-2026-08-13.html` | 155,776 | `33f477a551103a772c6e7e8b1ca24f3d17af590088927e7cbf0005e5a0ba7102` | 当前处理器列表与 950PR 产品正文 |
| H-6-DT-QUERY | 昇腾NPU处理器，`tag=950dt` | `fixed-candidates/hiascend-processor-950dt-2026-08-13.html` | 155,931 | `6bc823f2bf7328f8fa9838f6b7b7f6ee1cde23e9ccb8b41f0d9a4067e7706b07` | 记录 950DT 路由及服务器渲染错位，不承担产品规格 |
| H-7 | Atlas 加速卡 | `fixed-candidates/hiascend-accelerator-card-2026-08-13.html` | 202,198 | `3cfdeba7221d272ac307a3a2ca6404433804b9d6c7922677f56216bf24c4d978` | Atlas 350 使用 950PR 的当前关系与卡级边界 |
| H-12 | 技术创新赋能千行万业 昇腾人工智能伙伴峰会2026圆满举办 | `fixed-candidates/hiascend-atlas350-launch-2026-08-13.html` | 146,149 | `bdf89863ce0321f24f6c42ebfebda09d62cfad3468ef953e1277f6bda240a9dd` | 2026-03-20 Atlas 350 上市及 950PR 嵌入式商用证据 |

H-6 与 H-7 均在 2026 年 8 月 13 日访问和固定。四个必核入口都返回 HTTP 200。首次受限下载 H-2 时，网络请求被沙箱拒绝；经批准的升级访问取得页面，归类为 `sandbox_denial_recovered`。后续四次官方访问均成功，没有华为远端服务错误。最初一次下载命令的 PowerShell 方法调用括号写错，属于操作构造错误，未生成文件；改正后再发起访问。

## 来源价值与去重

H-2 不能被其他三页替代。它是当前唯一直接说明共用裸片、两种封装差异和 950DT 路线图时间的一手固定来源，也是后续把共享裸片事实与封装事实分开的基础。

H-12 也应保留。H-7 能说明 Atlas 350 采用 950PR，H-12 进一步给出 2026 年 3 月 20 日的正式上市时间和伙伴整机状态，二者不是完全重复。若最终事实集只引用日期化上市和搭载关系，H-7 可以反向移除；若需要当前卡级产品页证明作用域边界，则 H-7 保留为关系或边界来源。H-6 的价值在于当前处理器身份和 950PR 独立产品正文，不能用 H-12 的卡级新闻替代。

H-6-DT-QUERY 不进入最小集。它只是说明页面的动态标签没有在服务器快照里正确切出 950DT 正文，不能贡献新的产品事实。第三方报道没有进入候选来源，也没有用于补任何数字或状态。

## 对象层级限制

H-7 的 1.56 PFLOPS、112 GB HBM、1.4 TB/s、PCIe 5.0 x16、卡间灵衢带宽、600 W、被动散热、尺寸和重量，主语都是 Atlas 350 加速卡。本包不抽取这些数值，更不把它们下放到 950PR。H-12 的伙伴整机数量和“昇腾 950 代际推理算力正式进入商用阶段”同样不能改写成 950DT 已商用。

H-2 的路线图数字在后续抽取时还要按主语分层：明确写为 Ascend 950 chips/series 的共同规格，可以候选为共享裸片或系列陈述，但必须先确认字段允许的主体；HiBL 1.0 与 HiZQ 2.0 的容量、带宽和场景属于各自封装条件，不能写到共享裸片。路线图里的 “will” 保留为发布时的未来态，不改成已经交付。

## 旧架构待办与下一步

正式库没有 Ascend 950 三对象到 `OBJ-HUAWEI-DA-VINCI-INITIAL-ARCH` 的 `implements_architecture` 关系。本包核对的 15 条 `IMPL-FACT-HUAWEI-DV-*` 都来自 2019 图示或 2021 Ascend-Max 配置，迁移数为 0。后续事实抽取仍不得推断 Da Vinci 关系，也不得复制初代架构卡的 Cube、Vector、缓存、时钟或带宽事实。

三个对象均可进入身份与物理事实抽取，状态上限仍为 `ready_for_fact_extraction`。执行时先由总控为拟采用的 H-2、H-6、H-12 及必要时的 H-7 分配正式来源和入口标识，再逐条确定共享裸片、950PR 封装、950DT 封装的主语。950DT 的正式可用和客户交付保持缺口，直到出现对象匹配的一手更新。