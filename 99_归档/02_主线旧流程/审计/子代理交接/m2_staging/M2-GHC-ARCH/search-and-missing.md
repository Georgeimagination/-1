# 检索、缺口与冲突记录

结构化缺口在 `structured/field-requirements.csv`，每个 `not_found` 都有对应的 `structured/search-log.csv` 和 `structured/search-results.csv`。本包共有 80 条字段要求：37 条 `not_applicable`、40 条 `not_found`、2 条 `inaccessible_evidence`、1 条 `pending_verification`。`conflict-groups.csv` 与 `conflict-members.csv` 只有正式表头，没有冲突行。

Groq 第一代的主要空白是向量总吞吐、物理累加器位宽、TruePoint 缩放粒度、非规格数、MoE routing 与 Top-K。2022 scale-out 论文无法读取，拓扑和集合通信保持 `inaccessible_evidence`。第一代实现与 v1.7 的算力、存储和互联数字已转入物理对象待办，不再作为架构缺口或架构冲突。

Groq 3 的主要空白是 MXM/VXM 具体格式、累加精度、舍入与缩放、向量吞吐、标量路径和专用 MoE/Top-K。厂商给出的 high-radix point-to-point 目前没有无损的拓扑枚举映射，保持 `pending_verification`。每 LPU 的容量、带宽和链路数字不属于架构代际，已转入实现对象待办。

Da Vinci 的物理累加位宽、舍入、缩放、饱和、非规格数、INT8 输出、标量/向量峰值和 MoE/Top-K 均未找到可靠定值。初代人工智能核心（AI Core）没有通用片间拓扑，相关字段为 `not_applicable`。典型 16³ core 和 Ascend-Max 表 5 数字只作为论文示例配置保存，不生成架构通用存算比。

MLUarch05 除既有名称和软件构建目标外，大部分物理架构字段没有可访问一手定值。CNToolkit 3.8.4 返回远端 HTTP 401，BANG v5 与 MLUarch05 的关系记 `inaccessible_evidence`；这不是两个来源互相矛盾，所以不建立 `conflicting_unresolved` 或冲突组。

本次检索还遇到三个远端限制：Groq 2019 白皮书官方入口 HTTP 404；ISCA 2022 的 ACM DOI HTTP 403、Groq 官方地区 PDF 镜像 HTTP 522；寒武纪官方 GitHub 组织 API 的匿名查询达到远端 rate limit。固定原始提交仍能直接读取。以上都不是模型、沙箱或审批失败。
