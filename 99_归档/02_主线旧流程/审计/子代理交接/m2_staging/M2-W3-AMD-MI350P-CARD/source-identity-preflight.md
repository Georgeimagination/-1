# AMD Instinct MI350P PCIe 身份与来源预检

> 工作包：`M2-W3-AMD-MI350P-CARD`  
> 核查日期：2026-08-13  
> 结论：`ready_for_fact_extraction`  
> 本轮边界：只完成来源冻结、身份门和来源价值初筛；没有生成产品定值事实、资料卡草稿或正式来源记录

PCIe（Peripheral Component Interconnect Express）是主机外设互连总线，OAM（OCP Accelerator Module）是开放加速器模组形态，CDNA（Compute DNA）是 AMD 数据中心计算架构。本文中的 SHA-256 是固定内容的 256 位散列值，用来确认后续核查仍读取同一份内容。

## 身份门结论

D-1 和 D-7 都出现了精确的 MI350P 身份，硬门通过。

D-1 的可见正文只显示规格库外壳，产品数据实际放在页面的 `product-specs-table` 嵌入 JSON 中。解析固定 HTML 后得到恰好一个 `AMD Instinct™ MI350P` 条目；该条目的 `gpuFormFactor` 为 `PCIe® Add-in Card`，`busType` 为 `PCIe® 5.0 x16`，`gpuArchitecture` 为 `CDNA4`，英文产品入口指向官方 MI350P 专页。D-1 中通用的 `formFactor=Servers` 不能替代卡级形态字段，后续应以 `gpuFormFactor` 和专页的 Board Specifications 为准。该条目没有可用的 `launchDate`，因此 D-1 不能单独支撑首次发布日期或可用日期。

D-7 在 “What's New”、Benefits 下的 “Platforms Built for Any Enterprise Scale AI” 以及 “Meet the Series / AMD Instinct™ MI350P PCIe® Cards” 三处明确写出 MI350P PCIe card/cards，并链接到 `/en/products/accelerators/instinct/mi350/mi350p.html`。同页还把 MI350P PCIe cards 与 MI350X、MI355X platforms 分开描述。页面后半的 288 GB、8 TB/s 和 MI355X 对比表属于系列、OAM 或平台语境，不能迁到 MI350P 卡。

这两项结果与正式对象 `OBJ-AMD-MI350P`、对象类型 `card` 以及关系 `OREL-AMD-MI350P-IMPLEMENTS-CDNA4` 一致。MI350X、MI355X 和 MI350 8-OAM 平台继续留在排除边界。

## 已固定的官方候选

| 来源键 | 标题或版本 | 固定文件 | 字节数 | SHA-256 | 身份结果 |
|---|---|---|---:|---|---|
| D-1 | Accelerator Specifications | `fixed-candidates/amd-accelerator-specifications-2026-08-13.html` | 955,034 | `ed6788651672c944b661e120035e1656f19950ca154780cfc9b00d8555c65407` | 嵌入 JSON 精确命中 MI350P PCIe 卡 |
| D-7 | AMD Instinct™ MI350 Series GPUs | `fixed-candidates/amd-instinct-mi350-series-2026-08-13.html` | 337,045 | `2298403419176d7c473d6342425fe1e1f6cbf66f41f0a08d7c31e95c2247a17c` | 正文与专页链接精确命中 MI350P PCIe |
| MI350P-EXACT | AMD Instinct™ MI350P PCIe® Cards | `fixed-candidates/amd-instinct-mi350p-pcie-2026-08-13.html` | 196,285 | `09b3ffd469353dfb2456fc2fca67b421aa8bf5ae48be809fa64f1a30dda3c088` | 标题、Product Basics 和 Board Specifications 对象完全匹配 |
| MI350P-BLOG-20260507 | AMD Instinct MI350P PCIe GPUs: Run Enterprise AI on Your Existing Infrastructure | `fixed-candidates/amd-mi350p-pcie-blog-2026-08-13.html` | 184,522 | `2bc9cbb81e424e4d1c5d6912b43e7cfb1107081f159b012d8ad9cffd3b66dfb8` | 2026-05-07 的精确产品文章；带估算口径限制 |
| MI350P-BROCHURE | AMD Instinct™ MI350P PCIe® Card；`LE-93401-00 05/26` | `fixed-candidates/amd-instinct-mi350p-product-brochure-2026-08-13.pdf` | 782,486 | `a4e93edffc6c2a03668eef72b84d85e1d2586afb331c2228595d1549609afb29` | 2 页固定产品简报；标题和规格表精确匹配 |

五个入口均在 2026-08-13 返回 HTTP 200。产品简报的本地页数、标题、文档代码、dual-slot 和 air-cooled 文本已再次用本地 PDF 解析核对。

## 来源价值与最小集预判

MI350P 产品简报是当前最强的固定核心规格候选。它提供稳定版本号和页码，还把卡形态、芯片组成、内存、主机接口、功耗、可靠性和精度表放在同一份两页文档中。正式抽取时应先从这份简报建立产品事实，再用动态专页核对当前值和专页独有字段。

MI350P 专页适合承担当前身份、当前规格和版本状态。它与简报有大量重叠，重叠字段不需要为了增加来源数而保留重复断言；如果动态页记录了简报没有的当前字段或版本变化，则保留相应断言和状态职责。

2026-05-07 的官方文章有日期，并明确描述 dual-slot、standard air-cooled servers 等部署条件。简报已经覆盖大部分物理信息，所以这篇文章只有在支撑日期化状态或简报没有的可用性措辞时才有保留价值。文章末尾说明性能数字来自截至 2026 年 4 月的工程预测或早期测量，后续不能把这些估算值当成稳定核心规格。正文开头有一次 `MI350 PCIe cards` 的省略写法，标题和后续多处均为精确 `MI350P`；这属于文本一致性警告，不改变对象判断。

D-1 和 D-7 是本轮身份门证据，不会自动进入最终最小来源集。D-1 的对象行基本被 MI350P 专页完整覆盖；事实集合冻结后，应优先尝试反向移除 D-1，只在需要证明“截止日仍列入当前规格库”时保留状态职责。D-7 的独有价值是系列边界以及 PCIe 卡与 MI350X/MI355X platform 的区分；卡片正文若不引用这项边界，D-7 也可留在审计层，不进入正式最小集。

`SRC-M2NA-AMD-CDNA4-WP` 和 `SRC-M2NA-AMD-CDNA4-ISA` 继续只服务 `OBJ-AMD-CDNA4-ARCH`。MI350P 卡通过既有架构关系引用这些机制，不复制每 CU 吞吐、缓存或数值路径事实。

在完整事实集合尚未建立前，最小集裁决只能是预判。建议事实抽取阶段先以“固定简报 + 当前专页”为基础，再检查日期化状态是否确实需要 2026-05-07 文章。D-1、D-7 和未产生独有事实的动态来源依次做反向移除，最终新增正式内容版本不超过队列预算的 3 份。

## 访问与解析异常

第一次用受限命令直接下载 D-1 时，网络访问被沙箱拒绝，表现为无法连接远程服务器。经批准的升级访问随后取得 D-1、D-7、MI350P 专页、官方文章和产品简报，均返回 HTTP 200；因此该异常归类为 `sandbox_denial_recovered`，不是 AMD 远端服务错误。

通用网页正文提取没有显示 D-1 的动态规格表。固定原始 HTML 中存在完整的 `data-json`，本地解析后可以稳定定位精确 MI350P 条目。这个问题属于网页正文抽取覆盖不足，不是页面缺少 MI350P，也不影响身份门结论。

## 交接边界

状态设为 `ready_for_fact_extraction`。下一名执行者可以在本目录继续建立产品级原子事实、字段要求和资料卡草稿，但应先为拟正式采用的最多 3 个内容版本申请 source_id 与 endpoint_id。整卡吞吐必须来自 MI350P 对象匹配来源，不能用 CDNA 4 每 CU 数值乘未公开单元数。服务器最多 8 卡、MI350X/MI355X OAM、MI350 Series Platform 和其他系统聚合值继续保持零迁移。