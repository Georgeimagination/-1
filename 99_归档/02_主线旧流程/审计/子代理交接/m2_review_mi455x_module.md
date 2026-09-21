# M2-W3 AMD MI455X 模组包独立复核

> 复核结论：`accept_with_fixes`  
> 正式合并授权：不授权  
> 复核日期：2026-08-13  
> 被复核包：`审计/子代理交接/m2_staging/M2-W3-AMD-MI455X-MODULE/`  
> 写入边界：只写本报告；暂存包、正式 32 表、正式资料卡、正式快照和根文档均未修改

本文中，EAM 是 Enhanced Accelerator Module（增强型加速器模组），XCD 是 accelerated compute die（加速计算裸片），IOD 是 I/O die（输入输出裸片），WGP 是 Work Group Processor（工作组处理器），HBM 是 High Bandwidth Memory（高带宽内存），ECC 是 Error-Correcting Code（纠错码），OAM 是 Open Accelerator Module（开放加速器模组），PCIe 是 Peripheral Component Interconnect Express（高速外围组件互连），NIC 是 Network Interface Card（网卡），OCP 是 Open Compute Project。TFLOP/s、TOP/s 分别表示每秒万亿次浮点运算和每秒万亿次运算，PFLOP/s、POP/s 分别表示每秒千万亿次浮点运算和每秒千万亿次运算，FLOP/byte 表示每传输一个字节对应的浮点运算次数；UALink 是 Ultra Accelerator Link，UALoE 按 AMD 的原始接口标签保留，不猜测未明示的扩展含义。

## 结论

这个包的对象边界和大部分一手规格抽取是可靠的。42 条暂存事实都限定在单个 `OBJ-AMD-MI455X` 模组；Helios、72-GPU 机架、tray、OAM、PCIe、NIC 和机架拓扑没有下放，800 GB/s 与 1.6 TB/s 也没有进入本包。CDNA 5 的执行、缓存和数值机制没有复制成 MI455X 产品事实。brochure 的精确峰值与专页的舍入值分工正确，432 GB、23.3 TB/s、256 GB/s、3.6 TB/s 和 600 GB/s 的对象、单位与方向限定也基本正确。

现在还不能合并。第一处阻断是产品状态：正式范围门已经把截止日状态固定为 `announced`，暂存包却把它改成了 `not_found`。第二处阻断是四条存算比：它们的算术没错，但字段定义要求“矩阵稠密峰值”，队列审计又明确要求输入、累加、稠密条件和峰值口径齐全；暂存分子仍是 `sparsity_mode=not_specified`，产品级累加语义也没有找到。另有三条 precision-path 备注直接写成 Dense、一个派生条件指纹含 `dense`，以及七条 HTML 定位没有照录固定页面的真实标签。这些都应由初稿代理定点修正，再交不同代理复核。

## 回源结果

固定 MI455X brochure 共 2 页，已逐页视觉核对，文本抽取只作辅助。其 SHA-256 是 `6555fef1399a35f472e325dc61936d293e129735ec1e191d5fd0f3b6fa0c4208`，版本标识为 LE-93204-00 07/26、PID 5158303。固定产品页 SHA-256 是 `2fa27618862c42b0b9e6eed2e5c88c360e6eac2650d9fc97bae08c6338315b47`。复用的 MI400 快照和 CDNA 5 白皮书也已重新计算，分别为 `aa5603704c4d77d1e912a5921e289ccabaa45111bab209c2ce08975aedc58a7e` 与 `2381d60185f79989d3d5e4260c86f72504fcab256b40bb85fe4a6dd782afb3ef`，四个固定候选均与登记值一致。

brochure 第 1 页直接给出单个 MI455X 的 EAM module、TSMC 2nm/3nm、256 compute units、8 个 XCD、2 个 IOD、2.4 GHz、432 GB HBM4、23.3 TB/s、256 GB/s CPU-to-GPU、3.6 TB/s scale-up、600 GB/s scale-out、full-chip ECC memory 和 page retirement。第 2 页的四 GPU tray、18 trays、72-GPU rack、虚拟 pod 与 Oracle 计划部署属于系统或未来计划；本包迁移量为 0。

`AI PEAK THEORETICAL PERFORMANCE` 表的精确值与暂存值一致：OCP MXFP4 为 40,265 TFLOP/s；OCP MXFP6、MXFP8 和 FP8 各为 20,133 TFLOP/s；FP16、INT8、BF16 的基准列各为 5,033 TFLOP/s 或 TOP/s，`W/STRUCTURED SPARSITY` 列各为 10,066；FP16 vector、FP32 matrix、FP32 vector 各为 315 TFLOP/s；FP64 matrix 与 vector 各为 5 TFLOP/s。INT8 规范化为 OP/s，没有误写成 FLOP/s。专页的 40.3、20.1、5 和 10.1 PFLOP/s 或 POP/s 是兼容舍入，规范事实采用 brochure 精确值，这一职责划分成立。

基准列没有打印 `dense`，结构化稀疏列也没有公布稀疏图样。12 条 precision path 能表示厂商性能表中的格式标签和矩阵/向量行，但不能据此证明操作数 A/B、乘积、累加或输出编码。暂存没有建立这些产品级数值语义事实，也没有把 CDNA 5 架构语义复制下来，这一点是对的；资料卡第 3.2 节仍应把“输入格式”改成“厂商性能格式标签”，避免把行名写成已证明的输入接口。

存储与互联的规范化结果如下：432 GB 按十进制写成 432,000,000,000 byte；23.3 TB/s 写成 23,300,000,000,000 byte/s，并保留 peak theoretical、读写方向未说明；256 GB/s 的 CPU-to-GPU 值保留方向、payload 和持续/峰值均未说明；3.6 TB/s UALoE 与 600 GB/s 厂商标注 UALink 都按单个产品的 peak、bidirectional aggregate 记录，不解释为单链路、NIC 或机架带宽。没有发现主体或单位迁移错误。

## 必须修正的行和文件

### 1. 恢复截止日状态 `announced`

正式 `数据/objects.csv` 的 `OBJ-AMD-MI455X` 备注和 `审计/M2_对象范围验收.md` 都明确写着“截止日仍按 announced 处理”。`announced` 只表示产品已经公开宣布，不等于已出货、`production_ramp` 或 `available`；实际可用日期仍可保持 `not_found`。

修复时应把 `structured/field-requirements.csv` 的 `REQ-M2W3-AMD-MI455X-STATUS` 改为 `value_available`，并在 `structured/facts.csv` 新增 `FACT-M2W3-AMD-MI455X-STATUS`，主体为 `OBJ-AMD-MI455X`、字段为 `FIELD-ID-STATUS`、规范值为 `announced`。`structured/fact-assertions.csv` 需新增一条产品页断言，以固定页面标题和 `Launch Date 7/23/2026` 为原始语境，关系用 `qualifies`，明确这是受控状态归一化，不是供货证据。

原来的无结果检索与这项裁决冲突，应删除 `structured/search-log.csv` 的 `SEARCH-M2W3-AMD-MI455X-STATUS`，以及 `structured/search-results.csv` 的四行：

- `SRESULT-M2W3-AMD-MI455X-STATUS-PRODUCT`
- `SRESULT-M2W3-AMD-MI455X-STATUS-BROCHURE`
- `SRESULT-M2W3-AMD-MI455X-STATUS-MI400`
- `SRESULT-M2W3-AMD-MI455X-STATUS-CDNA5`

资料卡第 1、10、12 节以及 `README.md`、`handoff.md`、`research-method-and-adversarial-check.md`、`source-and-fact-candidate-audit.md` 中“删除 announced”“状态 not_found”的文字和计数须一并改正。`REQ-M2W3-AMD-MI455X-AVAILABILITY` 继续保持 `not_found`。

### 2. 删除四条不满足前置条件的派生链

四个结果的复算值分别是 1728.1115879828326、864.0772532188841、216.00858369098712 和 13.519313304721029 FLOP/byte，算术误差为 0，分子和分母也属于同一个 MI455X。问题不在除法，而在字段合同。`FIELD-DER-COMPUTE-BW-SPEC` 定义为“同对象、同精度的矩阵稠密峰值除以铭牌带宽”；四个分子都没有稠密证明，累加精度未找到，HBM 方向也未说明，却把 `precision_check_status` 和 `direction_check_status` 写成了 `passed`。这与 `m2_next_queue_audit.md` 第 102 行的人工硬门冲突。

应从对应文件删除下面整组主键，而不是保留数值再加一句限制：

| 表 | 必须删除的主键 |
|---|---|
| `facts.csv` | `FACT-M2W3-AMD-MI455X-DER-MXFP4-HBM4`、`FACT-M2W3-AMD-MI455X-DER-MXFP8-HBM4`、`FACT-M2W3-AMD-MI455X-DER-FP16-HBM4`、`FACT-M2W3-AMD-MI455X-DER-FP32-HBM4` |
| `field-requirements.csv` | `REQ-M2W3-AMD-MI455X-DER-MXFP4-HBM4`、`REQ-M2W3-AMD-MI455X-DER-MXFP8-HBM4`、`REQ-M2W3-AMD-MI455X-DER-FP16-HBM4`、`REQ-M2W3-AMD-MI455X-DER-FP32-HBM4` |
| `condition-sets.csv` | `COND-M2W3-AMD-MI455X-DER-MXFP4-HBM4`、`COND-M2W3-AMD-MI455X-DER-MXFP8-HBM4`、`COND-M2W3-AMD-MI455X-DER-FP16-HBM4`、`COND-M2W3-AMD-MI455X-DER-FP32-HBM4` |
| `derived-metrics.csv` | `DERMET-M2W3-AMD-MI455X-MXFP4-HBM4`、`DERMET-M2W3-AMD-MI455X-MXFP8-HBM4`、`DERMET-M2W3-AMD-MI455X-FP16-HBM4`、`DERMET-M2W3-AMD-MI455X-FP32-HBM4` |
| `derived-inputs.csv` | `DERIN-M2W3-AMD-MI455X-MXFP4-HBM4-NUM`、`DERIN-M2W3-AMD-MI455X-MXFP4-HBM4-DEN`、`DERIN-M2W3-AMD-MI455X-MXFP8-HBM4-NUM`、`DERIN-M2W3-AMD-MI455X-MXFP8-HBM4-DEN`、`DERIN-M2W3-AMD-MI455X-FP16-HBM4-NUM`、`DERIN-M2W3-AMD-MI455X-FP16-HBM4-DEN`、`DERIN-M2W3-AMD-MI455X-FP32-HBM4-NUM`、`DERIN-M2W3-AMD-MI455X-FP32-HBM4-DEN` |

资料卡第 6 节应改成“不计算产品级存算比，并说明缺少稠密和累加前置条件”。所有声称“4 条派生通过”的包内说明、验证 JSON、验证报告和文本保真记录都要重做。

### 3. 清掉结构化字段中的 Dense 外推

`structured/precision-paths.csv` 的三个主键 `PPATH-M2W3-AMD-MI455X-FP16-MATRIX`、`PPATH-M2W3-AMD-MI455X-INT8-MATRIX`、`PPATH-M2W3-AMD-MI455X-BF16-MATRIX` 目前备注为 “Dense and vendor-labeled structured-sparse peaks are separate facts”。应改成 “Base-column and vendor-labeled structured-sparsity peaks are separate facts; the source does not label the base column dense”。

`COND-M2W3-AMD-MI455X-DER-FP16-HBM4` 的 `condition_fingerprint` 含 `FP16-matrix-dense`；按上一节删除整条派生条件后，该错误会随之消失。其他 base-column 事实和条件已经使用 `not_specified`，不需要改成 dense。资料卡吞吐表继续保留 base column / structured-sparsity 的区别，稀疏图样继续保持未知。

### 4. 把七条 HTML 定位改成固定页面的真实标签

52 条断言目前都有 locator，`quoted_context` 均为空；项目校验允许用稳定 locator 单独定位，所以空 quoted context 本身不是阻断。下面七条 locator 与固定 HTML 的实际字段名不一致，且第一条 raw text 多写了 “Process Technology”，必须照原页修正：

| `assertion_id` | 当前定位或原值 | 应改为 |
|---|---|---|
| `ASSERT-M2W3-AMD-MI455X-PROCESS-PRODUCT` | `FinFET Process Technology`；raw text 为 `TSMC 2nm \| 3nm FinFET Process Technology` | locator 用 `Lithography`；raw text 用 `TSMC 2nm \| 3nm FinFET` |
| `ASSERT-M2W3-AMD-MI455X-HBM-STACKS-PRODUCT` | `Memory Stacks` | `Stacks of Memory` |
| `ASSERT-M2W3-AMD-MI455X-FORM-FACTOR-PRODUCT` | `Form Factor` | `GPU Form Factor` |
| `ASSERT-M2W3-AMD-MI455X-COOLING-PRODUCT` | `Cooling Solution` | `Cooling` |
| `ASSERT-M2W3-AMD-MI455X-HBM4-CAPACITY-PRODUCT` | `Memory Size` | `Dedicated Memory Size` |
| `ASSERT-M2W3-AMD-MI455X-SCALEUP-BW-PRODUCT` | `Scale-up UALoE Link Bandwidth (Peak)` | `Scale-up (Peak) UALoE Bi-directional Bandwidth` |
| `ASSERT-M2W3-AMD-MI455X-SCALEOUT-BW-PRODUCT` | `Scale-out UALink Link Bandwidth (Peak)` | `Scale-out (Peak) UALink™ Bi-directional Bandwidth` |

### 5. 同步卡片语义、置信理由和验证产物

资料卡第 3.2 节的“输入格式”必须改成“厂商性能格式标签”；第 4 节继续明确 A/B、乘积、程序员可见累加、物理累加和输出均没有 MI455X 产品级证据，不得把 precision-path 名称当成这些字段的事实。现有 `REQ-M2W3-AMD-MI455X-ACCUMULATION` 和 `REQ-M2W3-AMD-MI455X-PHYSICAL-ACCUM` 可继续作为对象级缺口，不能改成 CDNA 5 产品事实。

`facts.csv` 中有 15 条 `confidence_reason` 提到了没有登记为该事实断言的另一来源。应统一修正以下主键：`FACT-M2W3-AMD-MI455X-PACKAGE`、`FACT-M2W3-AMD-MI455X-WGP-COUNT`、`FACT-M2W3-AMD-MI455X-MXFP6-PEAK`、`FACT-M2W3-AMD-MI455X-FP8-PEAK`、`FACT-M2W3-AMD-MI455X-FP16-VECTOR-PEAK`、`FACT-M2W3-AMD-MI455X-FP16-MATRIX-SPARSE-PEAK`、`FACT-M2W3-AMD-MI455X-FP32-VECTOR-PEAK`、`FACT-M2W3-AMD-MI455X-FP64-MATRIX-PEAK`、`FACT-M2W3-AMD-MI455X-FP64-VECTOR-PEAK`、`FACT-M2W3-AMD-MI455X-INT8-MATRIX-BASE-PEAK`、`FACT-M2W3-AMD-MI455X-INT8-MATRIX-SPARSE-PEAK`、`FACT-M2W3-AMD-MI455X-BF16-MATRIX-BASE-PEAK`、`FACT-M2W3-AMD-MI455X-BF16-MATRIX-SPARSE-PEAK`、`FACT-M2W3-AMD-MI455X-SCALEUP-BW` 和 `FACT-M2W3-AMD-MI455X-SCALEOUT-BW`。最小修法是让理由只引用已登记断言；不要仅凭说明文字把 `single_source` 提升成 `corroborated`。

完成上述修正后，预期主计数为：39 条直接事实、0 条派生事实、53 条断言、44 条字段要求、9 个条件集、0 条派生指标、0 条派生输入、8 条 `not_found` 检索日志和 32 条检索结果。组件 5、存储层级 2、链路 3、精度路径 12、九域 9 行、两份新增 source、四个新增 endpoint 均不变。若实际计数不同，修复者必须解释新增或删减的具体主键，不能只改验证报告里的数字。

## 合同、最小来源集与卡片映射

独立复算确认，当前 42 条事实的主体合同错误为 0，48 条字段要求的目标合同错误为 0；38 条直接事实都有断言，断言 raw text / raw number 二选一（XOR）的错误为 0，按不同 `source_id` 复算的 evidence state 错误为 0。九域完整度恰有 9 行且没有重复域。当前资料卡能映射 38 条直接事实、4 个 derived metric 和 9 条非 value-available 要求，结构上的双向映射没有漏项；状态和派生链修正后必须重新做一次映射，预期卡片直接引用 39 条直接事实，不再引用四个 derived metric。

四来源最小集的角色成立：产品页独有 exact-object 身份、WGP、L2、晶体管、状态语境和命名接口；brochure 独有精确峰值、XCD/IOD、CPU-to-GPU 与 RAS；MI400 固定页独有 3D hybrid-bonded dies、Infinity Fabric 和 CoWoS-L 句子；CDNA 5 白皮书按队列冻结要求承担既有架构关系和数值语义边界，不支撑模块数值。没有来源可由其余三份完全替代。由于事实集合会改变，`SELRUN-M2W3-AMD-MI455X-20260813` 及四个 `selection-members` 现在不能签字；修复后应按最终事实集重跑反向移除，四成员预计仍保留，并把产品页的不可替代理由补上 `announced` 状态语境。

## 隔离合并、校验和正式库静态性

正式库在复核前后两次运行 `Validate-ResearchData.ps1`，均通过 32 表、97,920 项检查，`subject_contract_mode=gate`。另把 24 份暂存 CSV 追加到只读复制出的隔离镜像，正式校验器通过 103,222 项检查。这个 PASS 证明表头、枚举、外键、主体合同和本地文件哈希能够闭合；它不会检查“稠密峰值前置条件”或“范围门已冻结 announced”这两条人工语义门，因此不推翻本报告的阻断结论。

正式 32 份 CSV 与包内 `formal-32-csv-baseline.json` 逐文件匹配 32/32。按 `relative_path|sha256|bytes` 排序后计算的起止聚合均为 `6aa1bd6373b9d07b383a25c1355609cc6076ee8e491048d68d9c4ba445c0d165`，变化数为 0。隔离镜像、junction 和两张 brochure 临时 PNG 已删除；正式 `论文/` 仍有 111 份 PDF。

复核时，工作区依赖定位器曾超过 60 秒无返回并被终止，分类为工具运行时故障；随后使用已安装的原生 Poppler 完成两页视觉核对，没有降低复核范围。两次 PowerShell 命令构造错误属于复核者操作错误，均已改正并用成功的复算覆盖。没有沙箱拒绝、审批拒绝或远端服务错误影响本结论。

## 授权边界

本次是 `accept_with_fixes`，不是 `accept`。因此：

- 不授权把本包 24 份暂存 CSV 合并进正式 32 表；
- 不授权把 facts、assertions、requirements、sources、endpoints、selection run 或 selection members 的生命周期从 `draft` 改为 `reviewed`、`accepted` 或 `approved`；
- 不授权把资料卡移入正式 AMD 目录，也不授权更新正式型号索引；
- 不授权沿用当前四条派生事实或当前 selection 签字。

初稿代理完成上述定点修复、重新生成验证与文本保真产物、更新 `staging-file-manifest.csv` 后，应由不同代理做一次增量独立复核。只有新的报告给出 `accept`，总控才能另行决定正式合并和生命周期迁移。
---

## 2026-08-13 定点修复终审（进行中）

> 当前复核状态：`in_progress`；尚未签署最终授权。

已读取上一版独立复核、`remediation-log.md`、42 行 `freeze-manifest.csv`、修复后的 24 份结构化 CSV、资料卡和验证产物。冻结清单文件 SHA-256 已独立复算为 `56ca298d6c9b327c3b5ef2babf30a0f5dc109b519381083e5717452a01b1331b`；42 个成员的大小与 SHA-256 全部匹配，按 `relative_path|sha256|bytes` 排序连接后的聚合为 `dfed75716edaff380b35f4b356f4a631a8ce17413a8e339ac2b77448cb94b0a0`。

目前已确认四组修复：`announced` 状态 fact / requirement / assertion 链存在且没有残留状态检索；四条派生链在事实、要求、条件、指标、输入、资料卡映射中均已删除；三个 precision-path 备注已改为 base-column，条件指纹没有 dense 外推；七条 HTML locator 与 Process raw text 已按固定页面更正，15 条 `confidence_reason` 只引用已登记断言来源。主计数独立复算为 39 facts、53 assertions、44 requirements、9 conditions、0 derived metrics、0 derived inputs、8 search logs 和 32 search results。

正式 32 表仍与修复包基线匹配 32/32，聚合哈希为 `6aa1bd6373b9d07b383a25c1355609cc6076ee8e491048d68d9c4ba445c0d165`。尚待本轮新建临时正式合并镜像、运行官方 validator、核起止哈希和清理临时目录；完成后再给最终 `accept` 或保留阻断。