# M2-W3 AMD MI455X 模组包定点修复记录

> 依据：`审计/子代理交接/m2_review_mi455x_module.md`  
> 修复日期：2026-08-13  
> 当前状态：`ready_for_final_independent_review`  
> 写入边界：仅 `M2-W3-AMD-MI455X-MODULE/`

本文所用缩写：HBM 是高带宽内存，OCP 是 Open Compute Project，TFLOP/s 与 TOP/s 分别表示每秒万亿次浮点运算和每秒万亿次运算。

## 修复边界

本轮只关闭独立复核列出的阻断项。正式 32 表、正式资料卡、项目根 README、AGENTS、研究计划和进度文件保持只读；不改变任何暂存行的 `draft` 生命周期，也不自行签署独立复核结论。

## 修复前基线

修复前共有 42 条事实，其中直接事实 38 条、派生事实 4 条；断言 52 条；字段要求 48 条；条件集 13 个；派生指标与输入分别为 4 条和 8 条；无结果检索日志与检索结果分别为 9 条和 36 条。README 当时标为 `ready_for_independent_review`。

## 已完成的定点修改

截止日状态链已经恢复。新增 `FACT-M2W3-AMD-MI455X-STATUS`，规范值为 `announced`；`REQ-M2W3-AMD-MI455X-STATUS` 已改为 `value_available`；新增产品页断言 `ASSERT-M2W3-AMD-MI455X-STATUS-PRODUCT`，用固定页面标题和 `Launch Date 7/23/2026` 限定受控状态归一化。`announced` 只表示已公开宣布，不作为出货、量产爬坡或一般可用的证据。`SEARCH-M2W3-AMD-MI455X-STATUS` 及以下四条检索结果已删除：

- `SRESULT-M2W3-AMD-MI455X-STATUS-PRODUCT`
- `SRESULT-M2W3-AMD-MI455X-STATUS-BROCHURE`
- `SRESULT-M2W3-AMD-MI455X-STATUS-MI400`
- `SRESULT-M2W3-AMD-MI455X-STATUS-CDNA5`

四条存算比已整链删除。删除的事实为：

- `FACT-M2W3-AMD-MI455X-DER-MXFP4-HBM4`
- `FACT-M2W3-AMD-MI455X-DER-MXFP8-HBM4`
- `FACT-M2W3-AMD-MI455X-DER-FP16-HBM4`
- `FACT-M2W3-AMD-MI455X-DER-FP32-HBM4`

对应的四条要求、四个条件集、四条派生指标和八条派生输入也已删除；`derived-metrics.csv` 和 `derived-inputs.csv` 现为只有表头的空表。三个 precision-path 备注已统一为 “Base-column and vendor-labeled structured-sparsity peaks are separate facts; the source does not label the base column dense”，条件指纹中已无 `dense` 外推。

七条产品页断言定位已经照固定 HTML 修正：

- `ASSERT-M2W3-AMD-MI455X-PROCESS-PRODUCT`：raw text 为 `TSMC 2nm | 3nm FinFET`，定位为 `HTML, GPU Specifications, Lithography`
- `ASSERT-M2W3-AMD-MI455X-HBM-STACKS-PRODUCT`：`HTML, Board Specifications, Stacks of Memory`
- `ASSERT-M2W3-AMD-MI455X-FORM-FACTOR-PRODUCT`：`HTML, Board Specifications, GPU Form Factor`
- `ASSERT-M2W3-AMD-MI455X-COOLING-PRODUCT`：`HTML, Board Specifications, Cooling`
- `ASSERT-M2W3-AMD-MI455X-HBM4-CAPACITY-PRODUCT`：`HTML, Board Specifications, Dedicated Memory Size`
- `ASSERT-M2W3-AMD-MI455X-SCALEUP-BW-PRODUCT`：`HTML, Board Specifications, Scale-up (Peak) UALoE Bi-directional Bandwidth`
- `ASSERT-M2W3-AMD-MI455X-SCALEOUT-BW-PRODUCT`：`HTML, Board Specifications, Scale-out (Peak) UALink™ Bi-directional Bandwidth`

以下 15 条事实的 `confidence_reason` 已改为只引用该事实已登记的断言来源：`FACT-M2W3-AMD-MI455X-PACKAGE`、`FACT-M2W3-AMD-MI455X-WGP-COUNT`、`FACT-M2W3-AMD-MI455X-MXFP6-PEAK`、`FACT-M2W3-AMD-MI455X-FP8-PEAK`、`FACT-M2W3-AMD-MI455X-FP16-VECTOR-PEAK`、`FACT-M2W3-AMD-MI455X-FP16-MATRIX-SPARSE-PEAK`、`FACT-M2W3-AMD-MI455X-FP32-VECTOR-PEAK`、`FACT-M2W3-AMD-MI455X-FP64-MATRIX-PEAK`、`FACT-M2W3-AMD-MI455X-FP64-VECTOR-PEAK`、`FACT-M2W3-AMD-MI455X-INT8-MATRIX-BASE-PEAK`、`FACT-M2W3-AMD-MI455X-INT8-MATRIX-SPARSE-PEAK`、`FACT-M2W3-AMD-MI455X-BF16-MATRIX-BASE-PEAK`、`FACT-M2W3-AMD-MI455X-BF16-MATRIX-SPARSE-PEAK`、`FACT-M2W3-AMD-MI455X-SCALEUP-BW`、`FACT-M2W3-AMD-MI455X-SCALEOUT-BW`。

资料卡已恢复 `announced`，把“输入格式”改成“厂商性能格式标签”，明确 A/B 操作数、乘积、程序员可见累加、物理累加和输出编码均没有 MI455X 产品级证据；第 6 节改为说明为何不计算产品级存算比。来源筛选、反向移除、覆盖和九域完整度也已按修复后的事实集合重算。

## 当前结构化计数

当前主计数与独立复核预期一致：直接事实 39、派生事实 0、断言 53、字段要求 44、条件集 9、派生指标 0、派生输入 0、无结果检索日志 8、检索结果 32。组件 5、存储层级 2、链路 3、精度路径 12、特殊能力 0、拓扑 0、九域完整度 9 行；新增来源 2 个、endpoint 4 个、selection run 1 次、selection member 4 个。

## 验证与交付收口

包内复算结果为 0 项失败。24 份暂存表的表头、主键和正式 ID 碰撞均通过；39 条事实和 44 条要求分别通过主体合同与目标合同；53 条断言通过 XOR、locator、证据状态和来源计数检查；8 条 `not_found` 要求各有一条检索日志和四条来源结果。九域完整度恰有 9 行，资料卡映射 39/39 facts 和 8/8 非 `value_available` 要求。

正式基线官方验证器通过 97,920 项检查；临时正式合并镜像通过 102,752 项检查。镜像已删除，包内 `tmp/` 不存在，正式 `论文/` 仍有 111 份 PDF。正式 32 份 CSV 与基线匹配 32/32，变化数为 0，聚合哈希为 `6aa1bd6373b9d07b383a25c1355609cc6076ee8e491048d68d9c4ba445c0d165`。

包内 README、handoff、来源审计、对抗核验、资料卡和验证报告已经按修复后事实集合重写。交付前完成 report-humanizer 机器扫描，再按 shuorenhua 做事实保真检查；受保护的 ID、数字、日期、哈希、路径、单位和状态不得变化。机器可读验证、卡片映射、文本保真和冻结清单保存在 `validation/`。

本包现只到 `ready_for_final_independent_review`，没有自行签署 `accept`，也没有授权正式合并或生命周期迁移。下一步必须由不同代理进行最终独立复核。