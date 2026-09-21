# Google TPU 云配置对象模型重审

状态：`ready_for_independent_review`  
日期：2026-08-13  
范围：只裁定对象模型与下一工作包边界，不新增正式对象、关系、事实或资料卡。

## 为什么原方案不能继续

原 `M2-W2-G-CONFIG` 把 TPU（Tensor Processing Unit，张量处理器）的 slice 配置族统一建成 `cloud_accelerator`，又准备把每芯片峰值、HBM（High Bandwidth Memory，高带宽存储器）容量和 ICI（Inter-Chip Interconnect，芯片间互联）带宽写到这些对象上。这里混了三层东西：单个云端 TPU 器件、承载器件的 VM（Virtual Machine，虚拟机）类型，以及由若干芯片和 VM 组成的 slice 拓扑。配置容器不是芯片，不能承接每芯片规格；同一个机器类型又可能出现在多个 slice 规模中，也不能用一张“配置族卡”代替物理器件卡。

官方页面本身把这三层分得很清楚。TPU v5e 页面按 `per chip` 给出算力、HBM 和 ICI，再单独列 1、4、8 芯片 VM 和训练 slice；TPU v6e 页面也先列每芯片规格，再列 `ct6e-standard-1t/4t/8t` 与 1、4、8 芯片映射。TPU v5p 和 TPU7x 页面同样把每芯片定值、每 VM 芯片数及 slice 拓扑分栏陈述。因此，原来的五个 `*-SLICE-FAMILY` / `*-CONFIG-FAMILY` 待建 ID 不应预留。

## 修正后的三层模型

第一层是云端可见的单个 TPU 器件。它承接官方页面明确写成 `per chip` 的峰值、执行单元数量、HBM、ICI 端口和带宽，类型使用 `cloud_accelerator`。本轮十条实现待办应归到这一层。

第二层是 VM 或机器类型。它承接 vCPU、主机内存、NUMA（Non-Uniform Memory Access，非统一内存访问）节点、每 VM 芯片数和网络接口等配置，类型使用 `cloud_instance`。现有 `OBJ-GOOGLE-CT6E-STANDARD-FAMILY` 可以继续作为家族容器；1t、4t、8t 暂写为带条件的配置行。只有当某个机器类型拥有需要独立引用、比较或生命周期跟踪的事实时，才升级为独立对象。

第三层是 slice、Pod 或 Superpod。它承接拓扑形状、总芯片数、主机数、可调度上限和系统聚合指标，使用配置行或既有 `pod` 对象。`v4-8`、`v5litepod-16`、`2x2x2` 之类名称描述的是规模或拓扑，不为每一种组合创建芯片对象。

这三层通过关系连接，数值不复制到上下层：VM 家族用 `instance_contains_accelerator` 指向单器件；未来若建立物理封装对象，再用 `exposed_as_cloud_accelerator` 指向云端可见器件。关系只表达身份和包含方向，芯片数量仍由带条件的事实记录。

## 建议重写为三张器件卡

| 拟建对象 | 类型与状态 | 承接待办 | 对应架构 | 说明 |
|---|---|---|---|---|
| `OBJ-GOOGLE-TPU-V5E-CLOUD-DEVICE` | `cloud_accelerator / needs_resolution` | `DEF-M2GA-GV5E-01` 至 `04` | `OBJ-GOOGLE-TPU-V5E-ARCH` | 官方页直接按每颗 v5e 芯片给出执行单元、峰值、HBM 与 ICI；VM 和 slice 另层记录。 |
| `OBJ-GOOGLE-TPU-V5P-CLOUD-DEVICE` | `cloud_accelerator / needs_resolution` | `DEF-M2GA-GV5P-03` 的 95 GiB 云端值、`DEF-M2GA-GV5P-06` | `OBJ-GOOGLE-TPU-V5P-ARCH` | 95 GiB 只归云端可见器件。固定论文中的 96 GiB 留给后续物理 `package` 对象，不把二者强判成同一口径。 |
| `OBJ-GOOGLE-TPU-V6E-CLOUD-DEVICE` | `cloud_accelerator / needs_resolution` | `DEF-M2GA-GV6E-01` 至 `04` | `OBJ-GOOGLE-TPU-V6E-ARCH` | 官方页直接按每颗 v6e 芯片给出执行单元、峰值、HBM 与 ICI；`ct6e-standard-*` 配置不进入此卡。 |

三条 `implements_architecture` 关系方向均为云端器件指向相应架构对象。另建议补一条 `OBJ-GOOGLE-CT6E-STANDARD-FAMILY` → `instance_contains_accelerator` → `OBJ-GOOGLE-TPU-V6E-CLOUD-DEVICE` 的关系；1、4、8 芯片数量按机器类型条件化，不能写在关系本身。v5e 和 v5p 的机器类型家族对象暂不在本门预留，等配置事实集形成后再判断是建家族卡还是只保留配置表。

## 暂不进入本工作包的对象

TPU v4、TPU v5p 的物理实现和 TPU7x 属于后续 `package` 波次。它们有固定论文或明确的封装线索，适合承接 `DEF-M2GA-GV4-*`、v5p 的 96 GiB 物理值以及 `DEF-M2GA-G7X-*`，不应为了凑齐“配置卡”而塞进本包。TPU 8t 和 8i 继续保持观察对象；在未来封装身份和稳定可用状态没有复核前，不下沉路线图规格。

原来建议的以下对象 ID 全部撤回，不写入正式范围映射或 `objects.csv`：

- `OBJ-GOOGLE-TPU-V4-SLICE-FAMILY`
- `OBJ-GOOGLE-TPU-V5LITEPOD-CONFIG-FAMILY`
- `OBJ-GOOGLE-TPU-V5P-SLICE-FAMILY`
- `OBJ-GOOGLE-TPU-V6E-CONFIG-FAMILY`
- `OBJ-GOOGLE-TPU7X-SLICE-FAMILY`

## 必须固定的同日来源

本门使用 Google 官方页面，不采用媒体转述。正式开工前应在同一天保存以下 HTML，并登记最终 URL、标题、页面更新时间、访问日、HTTP 状态、字节数和 SHA-256：

| 页面 | 用途 | 当前直接证据 |
|---|---|---|
| `https://docs.cloud.google.com/tpu/docs/v5e` | v5e 单器件与 VM 分层 | 每芯片定值；1、4、8 芯片 VM；训练和推理 slice 映射 |
| `https://docs.cloud.google.com/tpu/docs/v5p` | v5p 云端器件与单一 4t VM | 95 GiB 每芯片 HBM、1200 GB/s 双向 ICI、4 芯片 VM |
| `https://docs.cloud.google.com/tpu/docs/v6e` | v6e 单器件与 `ct6e-standard` 分层 | 每芯片定值；1t/4t/8t 分别对应 1/4/8 芯片 |
| `https://docs.cloud.google.com/compute/docs/tpus/tpu-machines` | 机器类型交叉核对 | VM 的 vCPU、主机内存、NIC、芯片数、NUMA 与总 HBM |
| `https://docs.cloud.google.com/tpu/docs/system-architecture-tpu-vm` | 术语边界 | TPU VM 是可访问底层 TPU 的 worker；sub-host 不等于一颗芯片 |

2026-08-13 的官方在线页仍明确显示上述分层，但这些是动态页面；网页检索结果只用于本次模型裁定，不能替代本地固定快照或逐事实断言。

## 下一工作包边界

重写后的包建议命名为 `M2-W2-GOOGLE-CLOUD-DEVICE`，先做三张器件卡，不做六张配置族卡。预算按十条待办逐项拆解，不能沿用原方案的 300 条事实和 360 条断言估算。三张卡完成后，再用它们作为机器类型和 slice 配置的关系端点；配置包只记录聚合配置，不复制每芯片事实。

开工门有四项：三份器件对象身份由固定页直接支持；三个拟建 ID 和三条架构关系经过范围补裁决；v5p 的 95/96 GiB 明确分属云端可见器件和未来物理对象；未冻结页面不进入正式最小来源库。任何一项未通过，都只保留本模型报告和十条待办，不预留对象。

## 本次裁定

原 `M2-W2-G-CONFIG` 保持 `reject`。修正后的三器件模型为 `accept_with_fixes`：对象边界已经清楚，但仍缺同日 HTML 固定、正式范围补映射和未参与本稿的独立复核。本报告没有改动正式 CSV、资料卡、来源库、README、AGENTS、研究计划或进度文件。