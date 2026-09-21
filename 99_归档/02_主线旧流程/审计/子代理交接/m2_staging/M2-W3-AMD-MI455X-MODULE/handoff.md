# M2-W3 AMD MI455X 模组包交接

> 任务状态：`ready_for_final_independent_review`  
> 修复完成日期：2026-08-13  
> 写入范围：`审计/子代理交接/m2_staging/M2-W3-AMD-MI455X-MODULE/`

本文所用缩写：EAM 是增强型加速器模组，HBM 是高带宽内存，MoE 是混合专家模型；TFLOP/s 与 TOP/s 分别表示每秒万亿次浮点运算和每秒万亿次运算。

## 输入、对象与来源

本包按 `m2_next_queue_audit.md` 的预算处理正式对象 `OBJ-AMD-MI455X`，对象类型为 `module`。架构只通过既有关系 `OREL-AMD-MI455X-IMPLEMENTS-CDNA5` 引用；`OBJ-AMD-CDNA5-ARCH` 的机制事实没有复制。`OBJ-AMD-HELIOS-72-MI455X` 只作排除检查，Helios、tray、rack 和 72 模组事实迁移量为 0。

证据链包含四个固定来源：MI455X 专页 `SRC-M2W3-AMD-MI455X-PRODUCT-20260813`、MI455X brochure `SRC-M2W3-AMD-MI455X-BROCHURE-202607`、既有 MI400 固定页 `SRC-M2W2-AMD-MI400-LANDING-20260813`，以及既有 CDNA 5 白皮书 `SRC-M2NA-AMD-CDNA5-WP`。前两个固定候选的哈希和访问记录见 `source-freeze-register.csv`。

## 定点修复结果

独立复核要求的阻断项已经逐条关闭。截止日产品状态恢复为 `announced`，同时保留“实际可用日期 `not_found`”这一独立缺口；状态断言只依据固定专页标题、Launch Date 和正式范围门，不把宣布解释成出货或一般可用。与状态相冲突的一条无结果日志和四条检索结果已经删除。

四条存算比及其事实、要求、条件、派生指标和派生输入已经整链删除。除法可以复算，但字段合同要求矩阵稠密峰值；当前资料没有把基准列标为 dense，也没有 MI455X 产品级累加语义。三个 precision-path 备注和条件指纹中的 Dense 外推已清除。七条产品页 locator 已照固定 HTML 的真实标签修正，十五条置信理由也只保留该事实已登记的断言来源。

资料卡同步恢复 `announced`，把“输入格式”改成“厂商性能格式标签”，并明确 A/B 操作数、乘积、程序员可见累加、物理累加和输出编码都没有产品级证据。卡片现能双向映射 39 条直接事实与 8 条非 `value_available` 要求，不再出现已删除的派生主键。

## 结构化计数

当前共有直接事实 39 条、派生事实 0 条、断言 53 条、字段要求 44 条、条件集 9 个、派生指标 0 条、派生输入 0 条、无结果检索日志 8 条、检索结果 32 条。其余计数为组件 5、存储层级 2、链路 3、精度路径 12、特殊能力 0、拓扑 0、九域完整度 9、新来源 2、新 endpoint 4、selection run 1、selection member 4。

39 条事实按主体分为 object 17 条、component 4 条、precision_path 15 条和 link 3 条。证据状态为 `single_source` 23 条、`corroborated` 14 条、`source_with_caveat` 2 条，按不同 `source_id` 复算均一致。44 条要求中 36 条为 `value_available`、8 条为 `not_found`。

## 验证与静态性

正式基线以官方验证器 `gate` 模式通过 32 张表和 97,920 项检查。把本包 24 份暂存表叠加到只读副本后，临时镜像通过 102,752 项检查。包内表头、主键、ID 碰撞、事实与要求合同、断言 XOR、证据状态、搜索闭环、endpoint 哈希、九域完整度、卡片映射和七条 locator 均已复算通过。

临时镜像和包内 `tmp/` 均已删除，正式 `论文/` 仍有 111 份 PDF。正式 32 份 CSV 与基线匹配 32/32，变化数为 0；聚合哈希为 `6aa1bd6373b9d07b383a25c1355609cc6076ee8e491048d68d9c4ba445c0d165`。

## 仍需外部完成的工作

本包只到 `ready_for_final_independent_review`。下一位、且必须不同于本包作者的复核者，应确认状态归一化、四条派生整链删除、七条 locator、十五条置信理由、资料卡双向映射和修复后的四来源反向移除。复核者给出 `accept` 前，不得把暂存表或资料卡移入正式区，也不得把任何 `draft` 生命周期改为 `reviewed`、`accepted` 或 `approved`。

当前仍未解决的产品字段是实际可用日期、单模组功耗、程序员可见累加、物理累加器、MoE/Top-K 专用实现、HBM 总接口宽度、die 面积和版本化 runtime。不要用 launch date、液冷形态、邻近 SKU、Helios 聚合值或第三方数字补齐。

本包作者没有修改正式 32 表、正式资料卡、项目根 README、项目根 AGENTS、研究计划或进度文件。根 README 与 AGENTS 已检查；本轮是隔离暂存修复，项目范围、结构、运行方式和正式状态均未改变，因此不应在本包越权同步它们。