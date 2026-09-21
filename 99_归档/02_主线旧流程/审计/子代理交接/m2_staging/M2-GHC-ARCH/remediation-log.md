# M2-GHC-ARCH 修复记录

更新时间：2026-08-12  
状态：`ready_for_independent_rereview`

## 已读范围与执行边界

修复前已完整读取独立复核报告、工作包 README、四张资料卡、`structured/` 下 24 张 CSV，以及实现对象待办、来源登记、缺口登记和临时合并记录。为核对字段语义，另读取了正式 `fields.csv`、`enums.csv` 和官方校验器。所有写入都限于 `审计/子代理交接/m2_staging/M2-GHC-ARCH/`；正式资料卡、正式 CSV、根 README、AGENTS、研究计划和 `进度/` 均未修改。

## 总控口径

`fields.allowed_subject_kinds` 约束正式 facts 的目标类型。`field-requirements` 是审计问题，可以挂在上层 object，也可以挂在字段允许的具体目标上。因此，本包对 requirements 的检查规则是：目标必须为 object，或属于该字段允许的目标类型。

独立复核报告列出的 26 条 requirement 若挂在 object 上，本身不构成目标类型错误。实际挂在错误具体目标上的 9 条已经修正。复算结果为：35 条 facts 的字段目标不匹配为 0，80 条 requirements 按上述规则的不匹配也为 0。

## 已完成修复

结构化事实从 52 条缩减为 35 条，断言从 53 条缩减为 35 条。华为 13 条具体配置事实已经从架构 facts、assertions、value-available requirements 和卡内正式追溯中移出；连同两条证据不足的数值推断、Groq 舍入模式和 Groq 3 拓扑枚举，共有 17 个旧 fact ID 不再属于 staged facts。保留的 35 条事实各有且仅有一条断言，并已全部进入四张卡的追溯内容。

华为配置线索没有丢失。典型 cube 形状与单元数、两种来源下的向量宽度、五级容量、Ascend-Max 每周期吞吐和三项带宽被拆成 14 条原子待办；加上原有 1 GHz 时钟，华为共有 15 条实现对象待办。原文中的 KB、MB 和 TB/s 保持原样，未擅自换算成二进制单位；A、B、UB 带宽方向未说明时，没有强填读、写或双向。FP32 destination 不再被解释为 FP32 accumulation，向量“支持 FP32 operations”也没有强塞进 Operand A 字段。

字段目标与枚举阻断已修复。三条执行组织事实改挂实际 component；Groq 3 的 320-byte 向量粒度和华为向量格式转换改挂 precision path。Groq 的单次末端舍入只作为阶段描述保留，不伪装成舍入模式枚举；Groq 3 的 high-radix point-to-point 原文保留在 topology notes 与 requirement 中，不强映射到现有拓扑枚举。两条内存管理事实使用合法值 `compiler_managed`。

`implementation-object-backlog.csv` 由 26 行增至 46 行，其中 Groq 第一代 26 行、Groq 3 5 行、华为 15 行。复合 `source_id` 为 0，Groq ISCA 2020 的宽泛 `pp.1-12` 定位为 0。新增候选包括 25×29 mm、300 W / 215 W / 185 W、PCIe Gen4×16 和 PCIe CEM；820 TeraOps/s 候选明确限定在 1 GHz。组件与链路 notes 中的具体实现数字已移到待办。

不可访问资料改成一行一个 endpoint：2019 白皮书官方 URL 为 HTTP 404，ISCA 2022 ACM DOI 为 HTTP 403，Groq 官方地区 PDF 镜像为 HTTP 522。所有非空 `http_status` 都是整数，challenge 等访问现象只写在 accessibility 或 notes 中；没有可复现 URL 的镜像没有被伪造出来。本机直接取得 Groq 镜像仍返回 522，这是远端服务错误，不是沙箱、审批或模型限制。

## 验证结果

包内 `validate-staging.ps1` 实跑通过，覆盖表头、必填值、主键、临时合并主键碰撞、外键、枚举、分号规则、七目标 XOR、事实值 XOR 和 `not_found` 检索链。独立语义检查也通过：facts 目标类型错误 0，requirements 目标类型错误 0，断言基数错误 0，卡片漏追溯 0，被移出 fact ID 的卡片残留 0。

随后在系统临时目录复制当前正式库，追加本包 staging，并复制 32 个实际引用的本地 endpoint 文件。官方 `Validate-ResearchData.ps1` 通过 32 张表的 46,867 项检查，注册表为 323 列、488 个枚举值；临时目录已清理。正式库没有被写入，原库单独运行官方校验器仍通过 40,237 项检查。

四张中文卡、README、本记录和两份验证说明在交付前完成了报告自然化扫描与人工事实保真检查。数字、标识符、路径、访问状态和责任边界均保持不变。

## 剩余风险

本包仍是 staging，不代表已经写入正式库。总控顺序合并后必须在真实工作目录重跑官方校验器。Groq 2019 白皮书、ISCA 2022 正文和寒武纪受限文档仍不可用；相关状态继续保留为 `inaccessible_evidence` 或 `not_found`。华为和 Groq 的实现待办还缺少经冻结的 die、SoC、package 或 card 对象，不能提前回填正式事实。