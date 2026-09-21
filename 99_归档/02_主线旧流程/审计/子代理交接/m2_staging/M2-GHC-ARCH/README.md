# M2-GHC-ARCH 架构工作包

> 状态：`ready_for_independent_rereview`  
> 资料截止日：2026-08-12  
> 写入边界：只写本目录；未修改正式资料卡、正式 CSV、正式最小参考资料库、`进度/` 或根文档。

## 范围与对象边界

本包处理四个已预留的 `architecture_generation` 对象：`OBJ-GROQ-LPU1-ARCH`、`OBJ-NVIDIA-GROQ3-ARCH`、`OBJ-HUAWEI-DA-VINCI-INITIAL-ARCH` 和 `OBJ-CAMBRICON-MLU590-ARCH`。Groq 第一代与 NVIDIA Groq 3 分开建卡；Da Vinci 只承接原始论文明确描述的共享核心机制；MLUarch05 复用正式库已有名称事实。

BANG v2、v3、v5 只做身份审计，不建立正式对象。`MLUarch05`、BANG 版本、`compute_50`、`mtp_592` 和 `__BANG_ARCH__=592` 分属物理架构、软件版本与构建目标等不同语义层，数字相近不足以合并。

## 交付内容

`cards/` 有四张架构卡草稿。四卡合计覆盖本包 35 条 staged facts，每条都能追到 assertion、source 和定位；寒武纪卡另复用两条正式库事实，并明确其 owner。`structured/` 有 24 张与正式库同表头的 CSV：35 条事实、35 条断言、80 条字段要求、43 条检索记录、43 条检索结果和 36 条九域完整度记录。派生指标与冲突表只保留表头。

`implementation-object-backlog.csv` 有 46 行原子候选：Groq 第一代 26 行、Groq 3 5 行、华为 15 行。每行只指向一个 `source_id`，不再使用复合来源；Groq ISCA 2020 的定位已收紧到具体页码、章节或公式。25×29 mm、300 W / 215 W / 185 W、PCIe Gen4×16 和 PCIe CEM 已补齐，1 GHz 条件也已显式写入。

华为原先作为架构事实保留的 13 条具体配置已经全部移出，包括典型 cube 形状与单元数、向量宽度、五级容量、Ascend-Max 每周期吞吐和三项带宽。它们拆成 14 条原子待办；连同原有的 Ascend-Max 1 GHz 时钟，华为共有 15 条实现对象待办。来源、定位、配置条件和原始单位均保留；原文没有说明带宽方向时，不推断为读、写或双向。FP32 destination 也不再被解释为 FP32 accumulation。

## 字段目标口径

`fields.allowed_subject_kinds` 约束正式 facts 的目标类型。`field-requirements` 是审计问题，可以挂在上层 object，也可以挂在字段允许的具体目标上。本包采用的检查规则是：每条 requirement 的目标必须为 object，或属于该字段允许的目标类型。

独立复核报告列出的 26 条 requirement 若挂在 object 上，不需要重定向。实际挂在错误具体目标类型上的 9 条已经修复。35 条 facts 与 80 条 requirements 按上述规则复算，目标类型不匹配均为 0。

## 来源与访问状态

来源筛选仍以“是否为本包事实提供不可替代证据”为准。Groq 2019 白皮书未取得正文，不能判为已被其他资料覆盖；NVIDIA LPX 产品页只在本包所选事实集合上由架构博客完全覆盖；媒体没有进入事实链。华为两篇论文既支撑架构机制，也为实现待办保留具体配置线索，但这些数字不再进入架构事实。

不可访问入口已拆成一行一个 URL，并使用单一整数状态：2019 白皮书官方 URL 为 HTTP 404，ISCA 2022 ACM DOI 为 HTTP 403，Groq 官方地区 PDF 镜像为 HTTP 522。challenge 等访问现象只写在 accessibility 或 notes 中；没有可复现 URL 的镜像没有被伪造成 endpoint。寒武纪 CNToolkit 3.8.4 的 HTTP 401 属于远端访问限制，搜索摘要未用于生成事实。

## 验证结果

`validate-staging.ps1` 已实跑通过。它检查 24 张表的正式同表头、必填值、主键、临时合并主键碰撞、外键、枚举、分号规则、事实与要求的七目标 XOR、事实值 XOR，以及每条 `not_found` 是否有检索记录。

独立语义检查也已通过：35 条 facts 全部匹配字段允许的目标类型；80 条 requirements 全部满足“object 或字段允许类型”；35 条事实各有且仅有一条断言；35 条 staged facts 全部进入四卡追溯表，被移出的 17 条 fact ID 未残留在卡片中。46 条实现待办无复合 `source_id`，所有保留的 `http_status` 均为整数。

本包还在系统临时目录复制正式库，追加 staging 后运行官方 `Validate-ResearchData.ps1`。结果为 32 张表通过 46,867 项检查，注册表为 323 列、488 个枚举值；引用的 32 个本地 endpoint 文件均复制到临时库，临时目录随后清理。正式库本身未写入，并单独通过原有 40,237 项检查。总控正式合并后仍需在真实工作目录重跑官方校验器。

具体修复过程、计数和剩余风险见 `remediation-log.md`；临时合并细节见 `temporary-merge-notes.md`，最终验证摘要见 `validation-result.md`。