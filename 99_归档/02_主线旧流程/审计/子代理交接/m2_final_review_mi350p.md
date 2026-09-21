# M2-W3 AMD MI350P PCIe 卡最终独立复核

- 复核对象：`OBJ-AMD-MI350P`，单张 AMD Instinct MI350P PCIe 加速卡
- 修正包：`审计/子代理交接/m2_staging/M2-W3-AMD-MI350P-CARD`
- 复核日期：2026-08-13
- 结论：`accept`
- 可进入后续事务准备：是
- 正式库写入：无
- 精确签字：`审计/子代理交接/m2_final_review_mi350p_signoff.csv`
- 签字 SHA-256：`74ac69c299f5ce817c03236ef97df4e13f08f2d6724bb1c0178376661be5dad1`

PCIe 是 Peripheral Component Interconnect Express，即高速外设互联。PK 是 primary key，即结构化表主键。SHA-256 是 256 位安全散列值，用来确认复核和后续事务读取的是同一份内容。

## 裁决

修正包可以接收。第一次独立复核提出的三项阻断已经全部消除：产品页公开的 73 Billion 晶体管数已经形成对象级事实链；FP16、FP32、FP64 三条向量峰值只由固定简报第 1 页带 `VECTOR` 标签的行直接支撑；对象级最小来源集已经缩减为产品页、固定简报和 2026-05-07 官方文章三份来源。CDNA 4 whitepaper 和指令集架构资料只保留为 `lead_only`，不再占用对象最小集。

本次 `accept` 只允许总控依据精确签字准备后续事务。它没有把任何 staging 行写入正式 32 表，也没有复制资料卡、HTML 快照或 PDF。正式写入前仍要重新核对签字、冻结包、正式基线和四个目标文件；任一哈希、主键或目标存在性发生变化，签字立即失效。

## 冻结边界

`validation/staging-file-manifest.csv` 有 50 行。包内实际文件为 51 个，清单自身不列入清单；除此之外没有未登记文件。逐项复算文件存在性、字节数和 SHA-256 后，差异均为 0。

| 项目 | 复算结果 |
|---|---|
| manifest SHA-256 | `1cb279b56f4fbfc688ed2f798646a93baed02ffbd34a647ffecf4cb6672f0e01` |
| 50 行聚合哈希 | `152df43e8b64c2b78c54a41c6cf9bd7acfa4d3315fcf33d6128399b22f2f8825` |
| 聚合算法 | 按 `relative_path` 排序，以 `relative_path|sha256|byte_size` 组成每行，UTF-8、LF 连接后计算 SHA-256 |
| 资料卡 SHA-256 | `53458fc9a9662a1c17230fddb067e4365ad4b3f2f7755d072d674ffeface3b36` |
| 正式基线清单 SHA-256 | `68773358da2fe590aaaecdcccdaf0e68d61176df35d4b759dad14b4ae1174e5c` |
| 正式 32 表聚合哈希 | `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10` |

当前正式库的 32 张 CSV 与包内基线清单逐文件比较，文件、字节数和哈希差异均为 0。正式校验器在 `gate` 模式重新通过 106,160 项检查，注册表为 324 个列定义、488 个枚举值。

## 修正项核对

### 73 Billion 晶体管事实链

固定产品页标题和正文都明确指向 AMD Instinct MI350P PCIe Cards。该 HTML 的 7509 至 7520 行给出 `Transistor Count: 73 Billion`。修正包据此建立了完整、单一对象的事实链：

| 记录 | 主键与内容 |
|---|---|
| 规范事实 | `FACT-M2W3-AMD-MI350P-TRANSISTORS`；主体 `OBJ-AMD-MI350P`；字段 `FIELD-PHY-TRANSISTORS`；`73000000000 count` |
| 来源断言 | `ASSERT-M2W3-AMD-MI350P-TRANSISTORS-PRODUCT`；来源 `SRC-M2W3-AMD-MI350P-PRODUCT-20260813`；定位 `HTML lines 7509-7520, GPU Specifications` |
| 字段要求 | `REQ-M2W3-AMD-MI350P-TRANSISTORS`；`value_available`；检索状态 `completed` |

该数值只落在整卡对象，没有拆分到四个 XCD 或一个 IOD。XCD 是 Accelerated Compute Die，即加速计算裸片；IOD 是 I/O Die，即输入输出裸片。资料没有公开各裸片的晶体管分配，卡片也没有补做这种推断。物理完整度仍是 `partial`，因为 HBM 堆叠数和裸片面积继续为 `not_found`。

### 三条向量峰值的责任来源

固定简报 `LE-93401-00 05/26` 第 1 页已经重新渲染并目视核对。`HPC PEAK PERFORMANCE (ESTIMATED)` 表明确给出：

| 路径 | 简报原值 | 正式断言 |
|---|---:|---|
| FP16 VECTOR | 72 TFLOPS | `ASSERT-M2W3-AMD-MI350P-FP16-VECTOR-PEAK-BROCHURE` |
| FP32 VECTOR | 72 TFLOPS | `ASSERT-M2W3-AMD-MI350P-FP32-VECTOR-PEAK-BROCHURE` |
| FP64 VECTOR | 36 TFLOPS | `ASSERT-M2W3-AMD-MI350P-FP64-VECTOR-PEAK-BROCHURE` |

三条断言的来源均为 `SRC-M2W3-AMD-MI350P-BROCHURE-202605`，定位均为 `p. 1, HPC Peak Performance (Estimated)`。旧的 `*-VECTOR-PEAK-PRODUCT` 断言数量为 0。产品页虽然给出相同的 72、72、36 数值，但没有 `vector` 标签，因此只在说明中用于数值交叉核对，不作为正式向量分类断言，也不增加证据来源数。

三条规范事实继续标为 `theoretical_peak`，保留简报的 `Estimated` 限定。它们没有推断 lane 数、物理累加器或产品级累加格式。`evidence_state` 为 `single_source`，与当前直接断言来源数一致。

### 三来源最小集

修正版重新执行 `SELRUN-M2W3-AMD-MI350P-20260813`。对象最小集恰有三个成员：

| 来源 | 直接断言数 | 反向移除后丢失的不可替代事实 |
|---|---:|---|
| MI350P 精确产品页 | 33 | 24 条，包括精确对象身份、730 亿晶体管、被动散热、资源数、LLC、HBM 接口和矩阵峰值 |
| 固定产品简报 | 15 | 6 条，包括四 XCD、一 IOD、PCIe 128 GB/s 和三条直接标注的向量峰值 |
| 2026-05-07 官方文章 | 1 | 日期化的 `available` 状态 |

删除任一成员都会让当前事实集失去直接事实或必要分类证据。`source-selected-roles.csv` 有 4 行，`source-coverage.csv` 有 3 行，分别说明产品页与简报的部分覆盖以及文章状态证据的不可替代性。

`SRC-M2NA-AMD-CDNA4-WP` 和 `SRC-M2NA-AMD-CDNA4-ISA` 在 selection member、selected role 和 coverage 中均为 0 行；两条 screening 都是 `lead_only`。它们仍可服务 CDNA 4 架构卡和产品缺口检索，但不直接支撑 MI350P 卡事实。D-1 与 D-7 固定快照继续留在身份审计中，没有注册成对象最小集内容版本。

## 事实、缺口和对象边界

结构化包有 40 条直接事实、49 条 `source_checked` 断言和 46 条字段要求。字段要求中 34 条为 `value_available`，12 条为 `not_found`。40 条事实全部保持 `provisional`，本次只授权把 `review_status` 从 `draft` 提升为 `reviewed`，没有把语义解决状态改成 `accepted`。

12 条缺口要求分别有一条检索日志，总计 12 条 `search-log` 和 56 条 `search-result`；56 条结果均为 `checked_no_support`，没有孤立日志或孤立结果。九个完整度领域各有一行：identity、physical、compute、numerics、memory、interconnect、special_engines、software 和 evidence。特殊能力、拓扑、派生指标、派生输入和冲突表保持 0 行。

16 条峰值事实按矩阵与向量分开。矩阵基础行没有被写成 `dense`，结构化稀疏行使用 `structured_sparse`，但没有推断 2:4 图样。INT8 使用 OP/s，其余浮点峰值使用 FLOP/s。所有峰值都是厂商理论值，不冒充持续实测。输入 A、输入 B、乘积、程序员可见累加、物理累加器和输出格式继续为 `not_found`，因此没有计算存算比或每瓦性能。

HBM3E 容量 144 GB、LLC 容量 128 MB、HBM3E 带宽 4 TB/s 和 PCIe 128 GB/s 保留来源的十进制单位。两个带宽值都没有擅自拆成单向或双向；PCIe 值也没有折半或翻倍。`Passive` 只描述卡级散热，官方文章中的 air-cooled systems 只作为服务器部署语境。

事实主体、组件 owner、链路 owner 和字段要求目标均指向 `OBJ-AMD-MI350P` 或它的本包子实体。MI350X、MI355X、OAM、八 OAM 平台、服务器、机架、系统聚合值和每 CU 数值没有进入规范事实。OAM 是 OCP Accelerator Module，即开放加速器模组；CU 是 Compute Unit，即计算单元。CDNA 4 的每 CU 缓存、指令和累加语义只通过既有架构关系引用，没有复制到产品卡。

## 新鲜验证

包内校验器重新通过 1,082 项检查：40 facts、49 assertions、46 requirements，事实主体合同和字段要求目标合同不一致均为 0，九域完整度恰有九行。随后在当前 f152 正式库副本上重新执行隔离临时合并，正式校验器在 `gate` 模式通过 111,343 项检查。临时镜像已经删除；正式 32 表在演练前后仍与基线逐文件一致，哈希和字节数差异均为 0。

固定简报的目视核对使用本地 Python 运行时与 `pypdfium2` 渲染第 1 页。渲染图只用于人工检查，检查后已从系统临时目录删除，没有进入资料池或签字范围。

## 精确签字

`m2_final_review_mi350p_signoff.csv` 有 274 行、25 列，文件大小 236,397 字节，SHA-256 为 `74ac69c299f5ce817c03236ef97df4e13f08f2d6724bb1c0178376661be5dad1`。其中 270 行逐一绑定结构化 PK，另外 4 行绑定资料卡、产品页快照、固定简报和日期化文章快照。签字 ID、`target_path|pk_value` 均无重复，270 个来源主键都能在冻结 CSV 中唯一找到；274 行全部绑定 f152 正式基线和 111,343 项临时合并校验结果。

结构化行默认只授权 `review_status: draft -> reviewed`。选择运行另授权 `status: draft -> reviewed`；三个本地 endpoint 另授权把 staging `local_path` 改为签字中指定的正式卡外资料路径。每个 `source_line_sha256` 使用同一行对象经 `ConvertTo-Csv -NoTypeInformation` 生成表头和单行、以 LF 连接、UTF-8 无 BOM 编码后计算，后续事务可以重放验证。

四个非结构化目标当前都不存在：

| 类型 | 目标 |
|---|---|
| 资料卡 | `资料卡/AMD/产品/AMD_Instinct_MI350P_PCIe_卡资料卡.md` |
| 产品页快照 | `最小参考资料库/快照/AMD/MI350P/2026-08-13/amd-instinct-mi350p-pcie-2026-08-13.html` |
| 固定简报 | `论文/AMD_Instinct/02_厂商产品资料/2026_AMD_Instinct_MI350P_PCIe_Card_Brochure.pdf` |
| 日期化文章快照 | `最小参考资料库/快照/AMD/MI350P/2026-08-13/amd-mi350p-pcie-blog-2026-08-13.html` |

D-1 与 D-7 只承担身份审计角色，不在四个复制目标内。签字不授权复制生成脚本、验证报告或其他 staging 文件。

## 工具与操作异常

工作区依赖定位调用超过 60 秒没有返回，随后被终止，分类为工具或运行时故障。固定 PDF 改用已知的本地 Python 运行时完成渲染和目视核对，没有降低证据检查质量。

复核期间有三类 PowerShell 操作错误：两次把 statement-form `foreach` 直接接到管道；一次用内置别名 `h` 作为自定义哈希函数名；数次在临时签字脚本中漏写运算符或 `in` 后的空格。临时签字脚本第一次执行还因 UTF-8 无 BOM 被 Windows PowerShell 5.1 按本地代码页读取而解析失败。另有一条哈希试算表达式括号错误。以上均属于复核者的命令或脚本构造错误，或已知的运行时编码兼容问题，不是用户拒绝、自动审批拒绝、审批连接失败、沙箱拒绝或远端服务错误。失败步骤都发生在只读试算、静态解析或 signoff 文件创建前；最终 signoff 由通过静态解析的 UTF-8 BOM 临时脚本生成，并完成行数、列数、主键唯一性和来源 PK 复核。

## 文档与项目状态

本报告先通过 `report-humanizer` 机器扫描，再按 `shuorenhua` 的文档场景做人工保真回读。标题、首段、表格引导、转场和结尾没有明显模板腔；对象 ID、事实 ID、数值、单位、日期、哈希、路径、责任来源和裁决边界均保持不变。`README.md` 和 `AGENTS.md` 已只读检查。此次只生成独立复核报告和精确签字，尚未正式合并 MI350P 包，因此没有修改两份根文档，也没有修改任务台账、型号索引、正式资料卡或正式 32 表。总控完成正式事务和合并后验收时，再同步这些全局状态文件。