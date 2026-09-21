# M2-W3 AMD MI350P PCIe 卡独立复核

- 复核对象：`OBJ-AMD-MI350P`，单张 AMD Instinct MI350P PCIe 加速卡
- 冻结包：`审计/子代理交接/m2_staging/M2-W3-AMD-MI350P-CARD`
- 复核日期：2026-08-13
- 结论：`accept_with_fixes`
- 可直接合并：否

## 结论

该包的对象边界、绝大多数规格抽取和未知项处理是可靠的，但还不能签字合并。必须先补入产品页已经公开的晶体管数量；三条 FP16、FP32、FP64 向量峰值断言必须改由固定版 brochure 直接支撑；对象级最小来源集还要移除两份没有支撑 MI350P 卡片事实的 CDNA4 架构来源，并在修正后的事实集上重新执行反向移除。

因此本次不生成 signoff，也不授权把生命周期改为 `reviewed`，不授权复制资料卡、来源或结构化片段到正式库。修正版应由另一轮独立复核重新验收。

## 冻结边界与新鲜验证

冻结清单共有 49 行，包内实际文件为 50 个，其中多出的一个正是清单文件本身。逐行复算文件存在性、字节数和 SHA-256 后，差异均为 0。

| 检查项 | 复算结果 |
|---|---|
| `validation/staging-file-manifest.csv` SHA-256 | `e7146b709d5a1a9708603aba14c2d3b1bd0361e7ab271bf43aab07f990a7f0b0` |
| 49 行聚合哈希 | `1332e24e5ef9a30ecaf1c62b5d50ef3f46edbaa59148e5d69faad0cd61b16f46` |
| 资料卡 SHA-256 | `164e650d102482a4a45bbd6658a9edd677dc2c2417dc0437e51c7a6ca046918b` |
| 正式库 32 个 CSV 基线清单 | 32 行，文件、字节数和 SHA-256 差异均为 0 |

在系统临时目录复制整个冻结包后，重新运行包内校验器，结果为 1,043 项检查通过：39 条事实、48 条断言、45 条字段要求，主体合同不匹配为 0；同时确认 5 个组件、2 个存储层级、1 条链路、12 条精度路径、10 个条件集、12 次检索、56 条检索结果和 9 行完整性记录。随后在当前正式库副本上执行临时合并演练，`gate` 模式 111,344 项检查全部通过。当前正式库自身重新校验为 106,160 项通过。临时目录已经清理，正式库 32 个 CSV 的哈希在演练前后没有变化。

## 固定来源复核

我重新读取了 D-1、D-7、精确产品页、2026-05-07 官方文章和两页固定 brochure，并核对固定文件的身份、作用域和哈希：

| 来源 | SHA-256 | 本次复核结论 |
|---|---|---|
| D-1 Accelerator Specifications | `ed6788651672c944b661e120035e1656f19950ca154780cfc9b00d8555c65407` | 嵌入 JSON 只命中一个 MI350P PCIe 卡对象；产品专页覆盖其可迁移字段，继续只作身份门审计 |
| D-7 MI350 Series | `2298403419176d7c473d6342425fe1e1f6cbf66f41f0a08d7c31e95c2247a17c` | 只保留 MI350P PCIe 卡与 MI350X/MI355X platform 的系列边界；288 GB、8 TB/s 等系列或 OAM 值零迁移 |
| MI350P 精确产品页 | `09b3ffd469353dfb2456fc2fca67b421aa8bf5ae48be809fa64f1a30dda3c088` | 支撑当前卡级规格，并新增发现 73 Billion 晶体管；通用 FP16/FP32/FP64 Performance 数值不单独证明向量分类 |
| MI350P brochure `LE-93401-00 05/26` | `a4e93edffc6c2a03668eef72b84d85e1d2586afb331c2228595d1549609afb29` | 第 1 页直接给出三条 VECTOR 峰值，并列出一 IOD、卡形态与 PCIe；第 2 页用于核对四 XCD 和排除每 CU、服务器事实 |
| 2026-05-07 官方文章 | `2bc9cbb81e424e4d1c5d6912b43e7cfb1107081f159b012d8ad9cffd3b66dfb8` | 只保留“截至该日已 available”的日期化状态；最多八卡与 air-cooled systems 保持系统语境 |

48 条冻结断言的 raw value、单位、quoted context 和 locator 均逐项核对。除三条向量断言的责任来源需要改绑外，其余定位足以支撑对应原子事实；没有发现把上下文截断后改变主体、条件或单位的第二处问题。

这些结果说明冻结包内部结构可以通过现有硬门，但硬门不会判断“公开事实是否漏抽”以及“来源最小集是否真的最小”；下面三项仍是合并前必须修正的语义问题。

## 必须修正的问题

### 1. 漏抽晶体管数量

固定产品页 `amd-instinct-mi350p-pcie-2026-08-13.html` 在 HTML 7509 至 7520 行明确写出 `Transistor Count: 73 Billion`。这是单张 MI350P PCIe 卡对应器件的公开物理规格，和当前对象边界一致；现有 39 条事实却没有这条记录。建议补齐一条完整事实链：

| 表 | 建议主键 | 关键内容 |
|---|---|---|
| `facts.csv` | `FACT-M2W3-AMD-MI350P-TRANSISTORS` | 对象 `OBJ-AMD-MI350P`；字段 `FIELD-PHY-TRANSISTORS`；`73000000000 count`；`direct_statement / single_source / provisional` |
| `fact-assertions.csv` | `ASSERT-M2W3-AMD-MI350P-TRANSISTORS-PRODUCT` | 来源 `SRC-M2W3-AMD-MI350P-PRODUCT-20260813`；原值 `73 Billion`；定位 `HTML lines 7509-7520, GPU Specifications` |
| `field-requirements.csv` | `REQ-M2W3-AMD-MI350P-TRANSISTORS` | 对象级要求；`value_available`；证据指向上述事实和断言 |

同时更新资料卡的物理实现段，并把 `COMPLETE-M2W3-AMD-MI350P-PHYSICAL` 的说明加入 73 Billion；完整度仍为 `partial`，因为 HBM 堆栈数和裸片面积依旧没有可靠定值。来源侧不需要注册新内容版本、endpoint 或选择成员，但现有产品页记录要反映这项独有证据：`SELMEM-M2W3-AMD-MI350P-PRODUCT` 的不可替代理由、`SROLE-M2W3-AMD-MI350P-PRODUCT-CORE` 的 rationale 和 `SCREEN-M2W3-AMD-MI350P-PRODUCT` 的 rationale 都应加入晶体管数量。`COV-M2W3-AMD-MI350P-PRODUCT-BY-BROCHURE` 也应明确 brochure 不覆盖该值，因此产品页不能被反向移除。

这是一条在已选产品页上直接找到的正事实，不应为了凑形式另建缺口检索。新增要求本身写 `search_status=completed`、`last_searched_date=2026-08-13` 即可，`search-log.csv` 与 `search-results.csv` 仍保持 12 行和 56 行。`REQ-M2W3-AMD-MI350P-TRANSISTORS` 的 fingerprint 建议为 `M2W3|MI350P|object_id|OBJ-AMD-MI350P|FIELD-PHY-TRANSISTORS`，notes 指向唯一 canonical fact。若下述三条向量断言按替换处理，修正后的主体数量应为 40 条事实、49 条断言和 46 条字段要求。

计数变化还会影响资料卡末尾检查表、`README.md`、`handoff.md`、`fact-extraction-checkpoint.md`、`generation-progress.md`、`source-and-fact-audit.md`、`validation/text-naturalization-result.md` 及两份验证报告。修正完成后应重新生成这些记录和 `validation/staging-file-manifest.csv`，不能手工保留旧的 39/48/45、五来源或旧哈希说明。

### 2. 向量吞吐数值正确，但当前断言没有直接支撑“向量”分类

产品页只把 72、72、36 分别写成 FP16、FP32、FP64 `Performance`，对应定位没有出现 `Vector`。现有三条断言却把产品页当成向量分类的直接依据：

- `ASSERT-M2W3-AMD-MI350P-FP16-VECTOR-PEAK-PRODUCT`
- `ASSERT-M2W3-AMD-MI350P-FP32-VECTOR-PEAK-PRODUCT`
- `ASSERT-M2W3-AMD-MI350P-FP64-VECTOR-PEAK-PRODUCT`

固定版 `amd-instinct-mi350p-product-brochure-2026-08-13.pdf` 第 1 页的 `HPC PEAK PERFORMANCE (ESTIMATED)` 表则明确写出 `FP16 VECTOR (TFLOPS) 72`、`FP32 VECTOR (TFLOPS) 72` 和 `FP64 VECTOR (TFLOPS) 36`。我对 PDF 渲染页进行了人工目视核对，因此三条事实可以保留在现有向量组件和精度路径上，但直接证据必须换成 brochure。

最小修复是删除现有三条产品页断言，并以相同事实目标新建三条 brochure 断言；不要在此基础上再保留三条产品页交叉断言，否则补入晶体管断言后会达到 52 条，超过本包 50 条断言上限。应删除的精确主键是：

- `ASSERT-M2W3-AMD-MI350P-FP16-VECTOR-PEAK-PRODUCT`
- `ASSERT-M2W3-AMD-MI350P-FP32-VECTOR-PEAK-PRODUCT`
- `ASSERT-M2W3-AMD-MI350P-FP64-VECTOR-PEAK-PRODUCT`

替换后的精确主键建议为：

- `ASSERT-M2W3-AMD-MI350P-FP16-VECTOR-PEAK-BROCHURE`
- `ASSERT-M2W3-AMD-MI350P-FP32-VECTOR-PEAK-BROCHURE`
- `ASSERT-M2W3-AMD-MI350P-FP64-VECTOR-PEAK-BROCHURE`

三条新断言的来源统一为 `SRC-M2W3-AMD-MI350P-BROCHURE-202605`，定位写 `p. 1, HPC Peak Performance (Estimated)`，`quoted_context` 分别保留三行原文，并重算 assertion fingerprint。产品页的三个通用数值可以在 notes 或覆盖说明中作为交叉核对提及，也可以不再记录；它们不能继续承担向量分类的正式责任。这样替换前后仍为 48 条断言，加入晶体管断言后为 49 条。

三条 facts 的主键和 precision path 不变，但 `confidence_reason` 与 `notes` 必须改成 brochure 直接给出向量标签，并保留 `estimated` 条件。还要同步修正这些精确记录：`SELMEM-M2W3-AMD-MI350P-BROCHURE`、`SROLE-M2W3-AMD-MI350P-BROCHURE-CORE`、`SCREEN-M2W3-AMD-MI350P-BROCHURE`、`COV-M2W3-AMD-MI350P-PRODUCT-BY-BROCHURE`、`COV-M2W3-AMD-MI350P-BROCHURE-BY-PRODUCT` 和 `COMPLETE-M2W3-AMD-MI350P-COMPUTE`。其中 brochure 的选择理由应加入三条向量标签，`SROLE` 与 `SCREEN` 里“estimated performance 不进入事实”的旧说明必须删除；双向 coverage 要说明产品页能核对数值却没有向量标签。`SRC-M2W3-AMD-MI350P-BROCHURE-202605` 的 notes 也不能继续声称 current peak facts 全部取自后发布产品页。

资料卡第 3.2 节、来源差异段和最小来源段，以及 `source-and-fact-audit.md` 中“所有峰值都来自产品页”的表述都要改写：13 条矩阵峰值继续由产品页承担，3 条向量峰值由固定 brochure 直接承担。`README.md`、`handoff.md` 和相关验证说明中的同类概括也要随新包重生成。

这里不建议另造“通用非矩阵执行”对象级事实。当前 `FIELD-COMP-THROUGHPUT` 的 `allowed_subject_kinds` 只有 `precision_path`；精度路径必须连接组件，而受控枚举只有 `matrix`、`vector`、`scalar` 等具体组件类型，没有 `generic_compute`，操作类型也没有 `not_specified`。如果没有 brochure 这份直接证据，正确处理应是暂缓该分类或先做独立 schema 迁移，不能把通用 `Performance` 强行写成对象级吞吐，也不能凭产品页自行认定为向量。此次 brochure 已经消除了这个建模缺口，直接改绑三条断言即可。

### 3. 五来源选择集不是对象级最小集

产品页、brochure 和 2026-05-07 官方文章各自承担当前卡片规格、brochure 独有结构与向量标签、可供货状态这三类不可替代证据，应该保留。`SRC-M2NA-AMD-CDNA4-WP` 和 `SRC-M2NA-AMD-CDNA4-ISA` 对 39 条 MI350P 卡片事实没有直接断言；架构关系已经在正式库复核，产品页和 brochure 也直接标明 CDNA4。尤其 ISA 在本包中的 `full_text_read_status` 为 `inaccessible`，却仍被列为对象最小集成员，不符合反向移除的证据边界。

建议删除以下选择集记录：

- `SELMEM-M2W3-AMD-CDNA4-WP`
- `SELMEM-M2W3-AMD-CDNA4-ISA`
- `SROLE-M2W3-AMD-CDNA4-WP-RELATION`
- `SROLE-M2W3-AMD-CDNA4-ISA-RELATION`
- `COV-M2W3-AMD-CDNA4-WP-NOT-EQUIV-PRODUCT`
- `COV-M2W3-AMD-CDNA4-ISA-NOT-EQUIV-WP`

并把 `SCREEN-M2W3-AMD-CDNA4-WP-FOR-MI350P` 与 `SCREEN-M2W3-AMD-CDNA4-ISA-FOR-MI350P` 从 `selected` 改为 `lead_only`。两份架构来源仍可保留在检索结果中，状态继续为 `checked_no_support`，也可以继续服务于架构卡，但不应占用 MI350P 对象级最小来源集。补入晶体管事实并改绑三条向量断言后，必须重新执行 `SELRUN-M2W3-AMD-MI350P-20260813`；预期对象最小集为上述三份产品来源。D-1 与 D-7 继续保持审计用途是合理的：D-1 的精确产品行已被产品页覆盖，D-7 只提供系列边界。

## 其余语义检查结果

对象边界通过。39 条事实都落在单张 `OBJ-AMD-MI350P` PCIe 卡或其卡内组件、存储层级、链路和精度路径上，没有迁入 MI350X、MI355X 的 OAM 数值，也没有迁入 8-OAM、服务器、机架或 CDNA4 每 CU 架构数字。XCD 4、IOD 1、CU 128、Matrix Core 512、Stream Processor 8,192、HBM 144 GB、4 TB/s、4,096 bit、Last Level Cache 128 MB、PCIe 5.0 x16、128 GB/s、600 W 最大板卡功耗、450 W 默认功耗和被动散热均能回到固定产品资料。PCIe 的 128 GB/s 没有擅自补成单向或双向，方向保持未知；被动板卡散热也没有改写成系统级风冷。

性能口径通过。矩阵基准峰值和结构化稀疏峰值分别建模，没有把基础口径写成 `dense`，也没有从厂商未说明的内容推断 2:4。INT8 保持 OP/s；理论峰值没有冒充持续实测；没有生成无来源的算强度、每瓦性能或其他派生指标。输入精度、乘积精度、物理累加器位宽、有效累加精度和输出精度仍按 `not_found` 处理，没有从 CDNA4 ISA 或相邻产品复制。

状态口径通过。2026-05-07 官方文章只支持“不晚于该日已 available”，资料卡没有把它扩大成首次上市日；发布日期和首次可供货日继续为 `not_found`。特殊能力、拓扑、派生指标和冲突表为空，与本轮公开证据边界一致。

## 修正版重新验收条件

重新提交时，应同时满足：补齐上述晶体管事实链；三条向量事实由 brochure 直接支撑并保留 `estimated` 条件；对象选择集缩减到实际不可替代的三份来源；相关资料卡、完整性记录、计数、清单和哈希全部同步；在新的冻结包上重新运行包校验与临时正式合并演练，并由未参与修正的复核者重新签字。

## 工具异常记录

一次工作区依赖定位调用超过 60 秒没有输出，已终止，分类为工具或运行时故障，不是沙箱、审批或模型能力限制。随后使用已知的工作区 Python 运行时和 `pypdfium2` 完成 PDF 渲染，未降低复核质量。

一次使用当前 PowerShell 不支持的 `[Convert]::ToHexString`，另一次把 statement-form `foreach` 直接接到管道，均属于模型或操作构造错误；分别改用 `BitConverter` 和先物化结果后再输出，复算结果正常。写报告前还有一次 JavaScript 模板字符串未转义 Markdown 反引号而在调用前触发语法错误，没有写入任何文件；最终复核时又把 formal 基线的 `table_path` 列误写成 `relative_path`，导致一次无效的 32 行 mismatch 输出。两项同样属于模型或操作错误；改用正确列名后复算为 32 行全匹配、0 mismatch、0 missing。整个过程中没有用户拒绝、自动审批拒绝、审批连接失败或沙箱拒绝。

本报告是本次唯一新增文件。按任务边界，冻结 staging、正式 CSV、资料卡目录、来源库、`README.md` 和 `AGENTS.md` 均未修改。
