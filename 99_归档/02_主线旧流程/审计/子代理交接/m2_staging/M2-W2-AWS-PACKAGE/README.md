# M2-W2-AWS-PACKAGE 启动准备

状态：`source_freeze_and_identity_gate_complete / ready_for_independent_review`  
准备日期：2026-08-13  
范围：Inferentia1、Trainium1、Inferentia2、Trainium3 四个拟建 `package` 对象。Trainium2 只作为既有建模样例，不在本目录重复冻结或抽取。

## 本轮完成了什么

本轮只做开工前准备：核对四个候选对象的单芯片或单 device（器件）边界，固定后续物理事实会用到的 AWS 一手网页，并整理 23 条实现待办的抽取入口。没有创建正式对象、关系、事实、断言、字段要求或资料卡。

四个候选都取得了一手正文支持。AWS 的页面把实例或 UltraServer 与其中的芯片分开，再按 `Each ... chip` 或 `device` 描述单器件组成，因此可以进入对象预留复核。证据没有公开裸片、芯粒或封装构造；`package` 仍是项目建模选择，候选状态应保持 `needs_resolution`。

本包实际需要 A01 至 A08 和 A10，共 9 个既有 `source_id`。A01 与 A07 原为 `latest`，本轮同时保存原入口抓取件和 Neuron 2.31.0 版本化副本；其余版本化或定日页面各保存一份，共 11 个 HTML 文件。A09 只支撑 Trainium4 路线图，超出本包四个对象范围，没有下载。

## 目录内容

| 路径 | 用途 |
|---|---|
| `object-scope.csv` | 四个拟建对象、架构端点、关系候选、身份定位和边界限制 |
| `source-freeze-register.csv` | A01 至 A10 的取舍、原 URL、实际抓取 URL、标题、日期、HTTP 状态、本地路径、SHA-256 和拟 endpoint 处理 |
| `identity-gate.md` | 逐对象解释为什么单器件边界成立，以及哪些物理含义仍未证明 |
| `fixed-candidates/` | 11 份 2026-08-13 获取的 AWS 官方 HTML 候选快照；尚未进入正式快照目录 |

SHA-256 是 256 位安全散列算法；这里用于确认本地 HTML 内容没有在后续搬运中改变。固定文件仍只是 staging 输入，不能直接充当正式 endpoint，须由总控复核后复制到正式快照目录并更新来源表。

## 来源冻结结果

| 来源 | 本包用途 | 固定结果 | 后续采用方式 |
|---|---|---|---|
| A01 / `SRC-M2-GA-A01` | Inferentia1 身份与每芯片总量 | `latest` 与 v2.31.0 各 1 份，HTTP 200 | 以 v2.31.0 为首选固定入口；package 事实加入后重新做来源筛选，A01 不再只是架构包中的 `redundant_covered` |
| A02 / `SRC-M2-GA-A02` | NCv1 实现输入 | v2.9.1，HTTP 200 | 用于 `DEF-M2GA-AIF1-04` 和架构映射补充 |
| A03 / `SRC-M2-GA-A03` | Trainium1 身份与每芯片总量 | v2.26.1，HTTP 200；记录了 `general` 到 `about-neuron` 的跳转 | Trainium1 的主身份页 |
| A04 / `SRC-M2-GA-A04` | Inferentia2 身份与每芯片总量 | v2.29.1，HTTP 200 | Inferentia2 的主身份页 |
| A05 / `SRC-M2-GA-A05` | Trainium1/Inferentia2 的 NCv2、DMA 和 NeuronLink-v2 输入 | v2.29.1，HTTP 200 | 两个对象分别抽取；同页不表示同一物理对象 |
| A06 / `SRC-M2-GA-A06` | Trainium3 身份与每芯片总量 | v2.28.1，HTTP 200 | Trainium3 的主身份页，也是 4.9 TB/s、16 个 CC-Core 一侧的冲突来源 |
| A07 / `SRC-M2-GA-A07` | NCv4、片上存储、引擎和冲突输入 | `latest` 与 v2.31.0 各 1 份，HTTP 200 | 以 v2.31.0 为首选固定入口；保留 4.7 TB/s、20 个 CC-Core 的原文 |
| A08 / `SRC-M2-GA-A08` | Trainium3 定日身份、3 nm、HBM3e 和状态 | 2025-12-02 公告，2026-08-13 获取，HTTP 200 | 只使用明确的单芯片陈述；UltraServer 聚合值不下沉 |
| A09 / `SRC-M2-GA-A09` | Trainium4 路线图 | `not_fetched_out_of_scope` | 本包不使用；Trainium4 继续冻结 |
| A10 / `SRC-M2-GA-A10` | NCv4 引擎实现补充 | v2.30.0，HTTP 200 | 与 A07 做逐事实反向移除，不预设两者都进入最终最小集 |

`source-freeze-register.csv` 同时保留 formal 原入口和拟定的版本化 endpoint ID。总控后续可以更新已有 endpoint 的本地路径，也可以新增 A01/A07 的版本化入口；本稿没有改正式 `sources.csv` 或 `source-endpoints.csv`。

## 后续事实抽取输入清单

下表只给抽取入口和边界，不在本轮生成事实值。所有 deferred ID 均来自 `审计/M2-GA-ARCH_实现对象待办.csv`。

| deferred_id | 目标对象 | 已固定来源 | 起始定位 | 抽取时必须保留的边界 |
|---|---|---|---|---|
| `DEF-M2GA-AIF1-01` | Inferentia1 | A01 v2.31.0 | `Inferentia Architecture` 的每芯片表 | 只记每芯片 NCv1 数量 |
| `DEF-M2GA-AIF1-02` | Inferentia1 | A01 v2.31.0 | 同一每芯片 Compute 行 | 各精度峰值原子化；不写实例合计 |
| `DEF-M2GA-AIF1-03` | Inferentia1 | A01 v2.31.0 | 同一每芯片 Device Memory 行 | 容量与带宽拆开，保留 GiB/GiB/s 标签 |
| `DEF-M2GA-AIF1-04` | Inferentia1 的 NCv1 组件 | A02 v2.9.1 | `TensorEngine`、`VectorEngine`、`ScalarEngine` | 每引擎速率与频率缺口分开，不用 operations/cycle 推频率 |
| `DEF-M2GA-ATRN1-01` | Trainium1 | A03 v2.26.1 | `Trainium Architecture` 的每芯片表 | 只记每芯片 NCv2 数量 |
| `DEF-M2GA-ATRN1-02` | Trainium1 | A03 v2.26.1 | Compute 行 | 精度路径逐条拆分；旧版 420 INT8 作为被替代版本处理 |
| `DEF-M2GA-ATRN1-03` | Trainium1 | A03 v2.26.1、A05 v2.29.1 | 两页 Memory/Device overview | 820 GiB/s 与 820 GB/s 不换标签，建立冲突候选 |
| `DEF-M2GA-ATRN1-04` | Trainium1 | A03 v2.26.1、A05 v2.29.1 | Data Movement、device overview | DMA 聚合带宽与引擎数拆开 |
| `DEF-M2GA-ATRN1-05` | Trainium1 | A05 v2.29.1 | device overview | NeuronLink-v2 接口数只归 Trainium device |
| `DEF-M2GA-AIF2-01` | Inferentia2 | A04 v2.29.1 | `Inferentia2 Architecture` 的每芯片表 | 只记每芯片 NCv2 数量 |
| `DEF-M2GA-AIF2-02` | Inferentia2 | A04 v2.29.1 | Compute 行 | 精度路径逐条拆分，不写 Inf2 实例合计 |
| `DEF-M2GA-AIF2-03` | Inferentia2 | A04 v2.29.1、A05 v2.29.1 | 两页 Memory/Device overview | 820 GiB/s 与 820 GB/s 不换标签，建立冲突候选 |
| `DEF-M2GA-AIF2-04` | Inferentia2 | A05 v2.29.1 | device overview | DMA 聚合带宽与引擎数拆开 |
| `DEF-M2GA-AIF2-05` | Inferentia2 | A05 v2.29.1 | device overview | NeuronLink-v2 接口数只归 Inferentia2 device |
| `DEF-M2GA-ATRN3-01` | Trainium3 | A06 v2.28.1 | Trainium3 device overview | 只记每芯片 NCv4 数量 |
| `DEF-M2GA-ATRN3-02` | Trainium3 | A06 v2.28.1 | 每芯片 Compute 表 | MX、BF16/FP16/TF32、FP32、稀疏路径分开 |
| `DEF-M2GA-ATRN3-03` | Trainium3 的 NCv4 组件 | A07 v2.31.0、A10 v2.30.0 | A07 `Compute Engine Specifications`；A10 引擎段落 | 每 NCv4 与整芯片总量分开；频率保留条件 |
| `DEF-M2GA-ATRN3-04` | Trainium3 的 NCv4 组件 | A07 v2.31.0 | A07 第 2030 行附近 | SBUF 与 PSUM 分成两个存储层事实 |
| `DEF-M2GA-ATRN3-05` | Trainium3 | A06 v2.28.1、A07 v2.31.0、A08 | device/memory 表与定日公告 | 4.9 与 4.7 TB/s 建冲突候选；4 个 HBM stack 单列 |
| `DEF-M2GA-ATRN3-06` | Trainium3 | A06 v2.28.1、A07 v2.31.0 | Data Movement、device overview | DMA 引擎数与聚合带宽拆开 |
| `DEF-M2GA-ATRN3-07` | Trainium3 | A06 v2.28.1、A07 v2.31.0 | 两页 device overview | 16 与 20 个 CC-Core 建冲突候选 |
| `DEF-M2GA-ATRN3-08` | Trainium3 | A06 v2.28.1、A07 v2.31.0 | Interconnect/device overview | 接口数与聚合速率拆开；方向和有效载荷留缺口 |
| `DEF-M2GA-ATRN3-09` | Trainium3 | A08 | 2025-12-02 公告的单芯片句 | 3 nm 与 HBM3e 分成两个事实；供货状态单独处理 |

共 23 条输入：Inferentia1 4 条、Trainium1 5 条、Inferentia2 5 条、Trainium3 9 条。A01 与 A07 的版本化副本应当用于稳定定位；原 `latest` 抓取件只用于证明同日动态入口内容和版本漂移风险。

## 不能在下一步顺手做的事

对象还没有进入正式预留层，因此目前不能生成引用四个 object_id 的正式 facts、requirements 或 cards。也不能把架构事实改目标后复制到 package，对 Trainium3 的 UltraServer 数值做除法，或把 Trainium/Inferentia2 共享 NKI 页面解释成同一物理器件。

本轮 HTML 只保存正文文件，页面引用的图片、样式表和脚本仍在远端。当前身份判断和待办输入都能从正文复核；若以后要以图中独有信息建事实，应先固定相应资源。

## 交给总控的下一步

先由独立复核者核对 `object-scope.csv` 的四个对象、四条关系方向和 `package` 口径。通过后，总控再补范围裁决并预留对象；与此同时，把选定的 9 组来源快照复制到正式快照目录，核对搬运前后 SHA-256，更新或新增 endpoint。对象和来源门都关闭后，事实代理才能按上表开始原子化抽取。

来源集合变化后，需要针对 package 事实重跑筛选。尤其 A01 在架构包中因没有实现事实而被标为 `redundant_covered`；本包采用其每芯片总量后，它会获得新的 `core_spec` 候选职责。A07 与 A10 是否都不可替代，要等事实集合形成后再做反向移除，不能在准备阶段预判。

## 获取与验证记录

第一次用默认沙箱直接下载 A01 时，网络隔离导致请求失败，没有生成文件。随后获得外部网络访问许可，所有纳入范围的 AWS 页面均返回 HTTP 200；这属于已解除的沙箱网络限制，不是远端服务故障、审批拒绝或用搜索摘要降级。

本目录之外没有写入。正式 CSV、资料卡、`进度/`、README、AGENTS 和研究计划均未修改。