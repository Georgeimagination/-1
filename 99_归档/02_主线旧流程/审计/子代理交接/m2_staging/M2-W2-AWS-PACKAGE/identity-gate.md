# AWS 四个物理对象身份门预审

状态：`ready_for_independent_review`  
预审日期：2026-08-13  
写入边界：只完成来源冻结与身份预审，不创建正式对象、关系或事实。

## 预审结论

AWS（Amazon Web Services，亚马逊云服务）的一手设备页已经把 Inferentia1、Trainium1、Inferentia2 和 Trainium3 分别描述为可独立计数的 `chip` 或 `device`，并给出“每颗芯片由什么组成”的表格。四个候选都通过“单器件边界”门，可以进入总控的对象预留复核。

这批证据没有说明裸片数量、芯粒数量、封装基板或订货形态。因此，项目把它们暂放在 `package` 层，只是沿用 Trainium2 的既有建模方式和第一波待办的 `silicon_package` 目标，并不是认定它们已经被证明为某种具体封装。四个对象和四条 `implements_architecture` 关系如果以后进入正式表，`review_status` 仍应先用 `needs_resolution`。

| 候选对象 | 单器件边界 | `package` 类型 | 实例或系统隔离 | 预审结果 |
|---|---|---|---|---|
| `OBJ-AWS-INFERENTIA1-CHIP` | 一手页先区分 Inf1 实例内的 16 颗 Inferentia，再逐项列出每颗芯片的 NCv1、设备内存和链路 | 未公开封装构造 | 16 颗是 Inf1 实例配置，不写成单芯片事实 | `pass_with_caveat` |
| `OBJ-AWS-TRAINIUM1-CHIP` | 一手页区分 Trn1 实例内的 16 颗 Trainium，并给出每颗芯片的组件表 | 未公开封装构造 | 16 颗是 Trn1 实例配置 | `pass_with_caveat` |
| `OBJ-AWS-INFERENTIA2-CHIP` | 一手页区分 Inf2 实例内最多 12 颗 Inferentia2，并给出每颗芯片的组件表 | 未公开封装构造 | 最多 12 颗是 Inf2 实例配置 | `pass_with_caveat` |
| `OBJ-AWS-TRAINIUM3-CHIP` | 架构页同时使用 `chip` 和 `device`，明确每个器件含 8 个 NCv4；定日公告另给单芯片陈述 | 未公开封装构造 | UltraServer 最多 144 颗及系统总量不得下沉 | `pass_with_caveat` |

NCv1、NCv2 和 NCv4 分别指 NeuronCore v1、v2 和 v4。这里的“单器件”是事实归属边界，不表示已知其内部有几颗裸片。

## 四个对象的证据链

### Inferentia1

主证据是版本化的 [A01 Inferentia Architecture 2.31.0](fixed-candidates/A01-inferentia-v2.31.0-2026-08-13.html)。HTML（HyperText Markup Language，超文本标记语言）第 1977 行把 Inf1 实例与其中的 Inferentia 芯片分开，第 1980 行开始使用 “Each Inferentia chip consists of” 组织每芯片组件。`SRC-M2-GA-A02` 的 NCv1 页面另说明 NCv1 驱动 Inferentia NeuronDevices，可作为架构映射的补充。

这组证据足以建立一个 Inferentia 单器件候选，并将 `DEF-M2GA-AIF1-01` 至 `04` 的 `per chip` 或 `per NCv1 engine` 输入保留在该对象及其组件下。Inf1 实例的 16 芯片数量不属于这个对象。

### Trainium1

[A03 Trainium Architecture 2.26.1](fixed-candidates/A03-trainium-v2.26.1-2026-08-13.html) 第 1562 至 1566 行先给出 Trn1 实例和 Trainium 芯片的区别，随后以每芯片组件表承接 NCv2、设备内存和数据搬运。A05 的 NKI（Neuron Kernel Interface，Neuron 内核接口）指南第 1923 至 1935 行又把 Trainium 和 Inferentia2 分别称为 device，并列出两者各自的 NeuronLink-v2 数量。

因此，Trainium1 可以单独建候选对象。A05 是共享实现资料，不能据此把 Trainium1 与 Inferentia2 合并成一个物理对象。

### Inferentia2

[A04 Inferentia2 Architecture 2.29.1](fixed-candidates/A04-inferentia2-v2.29.1-2026-08-13.html) 第 1878 至 1881 行区分 Inf2 实例与其中的 Inferentia2 芯片，后续表格明确按每芯片给出 NCv2、设备内存和数据搬运。A05 的设备图可作补充，但身份以 A04 为主。

“最多 12 颗”只描述 Inf2 实例上限，不能成为 Inferentia2 单芯片的数量属性，也不能用来反除其他实例规格。

### Trainium3

[A06 Trainium3 Architecture 2.28.1](fixed-candidates/A06-trainium3-v2.28.1-2026-08-13.html) 第 1887 行把 Trainium3 称为 AWS 的机器学习芯片，并说明一个 Trainium3 device 含 8 个 NCv4；第 1891 行开始列出每颗芯片的组件。定日的 [A08 Trn3 UltraServers 公告](fixed-candidates/A08-trn3-ultraservers-2025-12-02-fetched-2026-08-13.html) 第 2113 至 2119 行分别陈述每颗 Trainium3 芯片和 UltraServer 聚合配置。A10 第 1920 行说明 NCv4 驱动 Trainium3 芯片。

这三份资料共同支持 Trainium3 单器件身份和架构映射。A08 中最多 144 颗芯片、20.7 TB 内存与 706 TB/s 等 UltraServer 数值全部留在系统层。

## 拟预留关系

四条关系只表达物理对象实现哪个已冻结架构，不携带芯片数量、带宽或供货状态：

| 拟关系 ID | 方向 | 证据判断 |
|---|---|---|
| `OREL-AWS-INFERENTIA1-IMPLEMENTS-ARCH` | `OBJ-AWS-INFERENTIA1-CHIP` → `implements_architecture` → `OBJ-AWS-INFERENTIA1-ARCH` | A01 的 Inferentia 芯片组件表与 A02 的 NCv1 和 Inferentia 映射足以进入预留复核 |
| `OREL-AWS-TRAINIUM1-IMPLEMENTS-ARCH` | `OBJ-AWS-TRAINIUM1-CHIP` → `implements_architecture` → `OBJ-AWS-TRAINIUM1-ARCH` | A03 直接把 Trainium 芯片与 NCv2 组织在同一器件表中 |
| `OREL-AWS-INFERENTIA2-IMPLEMENTS-ARCH` | `OBJ-AWS-INFERENTIA2-CHIP` → `implements_architecture` → `OBJ-AWS-INFERENTIA2-ARCH` | A04 直接给出 Inferentia2 芯片架构和每芯片组件 |
| `OREL-AWS-TRAINIUM3-IMPLEMENTS-ARCH` | `OBJ-AWS-TRAINIUM3-CHIP` → `implements_architecture` → `OBJ-AWS-TRAINIUM3-ARCH` | A06 的 Trainium3 芯片架构页与 A10 的 NCv4 映射互相闭合 |

这些关系仍只是 staging 候选。它们没有写入 `数据/object-relations.csv`，也不能在正式预留前被事实外键引用。

## 来源冻结对身份门的影响

A01 与 A07 的正式入口原来使用 `latest`。本轮既保存原入口抓取件，也取得同日可访问的 Neuron 2.31.0 版本化副本；后续定位优先用版本化副本。A03 的旧 `general` 路径会跳转到 `about-neuron`，原 URL 和最终 URL 已分别登记。

A05 与 A06 的页面顶部“适用实例”提示和正文对象命名并不完全一致。身份判断只使用正文中的设备或芯片段落，不用导航提示扩张适用范围。A08 虽然有发布日期，网页本身仍可能被改写，所以也保存了 HTML 与 SHA-256（256 位安全散列算法）。

本地 HTML 没有连同图片、样式表和脚本做完整网页归档。四个身份门都由 HTML 正文直接支撑，不依赖未保存的图；如果后续事实需要读取图中独有信息，必须另行固定对应资源。

## 尚未解除的门

四个对象虽通过单器件身份预审，仍须由未参与本稿的复核者确认对象 ID、`package` 建模、关系方向和范围补裁决。未完成正式对象预留前，后续抽取只能准备输入，不能创建引用这些 object_id 的正式事实。

物理构造仍是公开缺口。没有一手资料时，不得把 `chip` 翻译成单裸片，也不得从实例芯片数、UltraServer 数量或架构组件数推断封装内裸片数量。

## 获取异常分类

第一次在默认沙箱中直接请求 A01 时，系统网络隔离导致“无法连接到远程服务器”，文件没有生成。这是沙箱网络限制，不是 AWS 远端错误、审批拒绝或模型能力问题。随后使用获准的外部网络访问重新下载，A01 至 A08、A10 及 A01/A07 的 2.31.0 版本化副本均返回 HTTP 200；没有用搜索摘要替代正文。