# M2-W2 AWS package facts 修正版 staging

状态：`ready_for_independent_review`。本目录是原冻结包 `M2-W2-AWS-PACKAGE-FACTS` 的独立修正版，只保存 Amazon Web Services（AWS）四个单芯片或单器件封装对象的候选数据。原冻结包、正式 32 表、正式资料卡和全局文档均未修改。

## 当前内容

修正版有 4 张资料卡、57 条事实、69 条逐来源断言和 71 条字段要求。实现层结构包括 27 个组件、6 个存储层、3 条芯片级互连、20 条精度路径和 29 个条件集。字段要求中，46 条为 `value_available`、5 条为 `conflicting_unresolved`、20 条为 `not_found`；后 20 条均有检索日志和逐来源检查结果。四个对象各有九域完整度记录，共 36 行。

五组冲突和 10 个成员原样保留：Trainium1 与 Inferentia2 分别保留 820 GiB/s 和 820 GB/s；Trainium3 分别保留 144 GiB 与 144 GB、4.9 与 4.7 TB/s、16 与 20 个集合通信核心（CC-Core）。没有换算后选值，也没有设置 preferred fact。

## 本次修正

B01 至 B09 的数据修正已写入本目录，验证状态见 `remediation-log.md`。其中三项会改变数据模型或来源选择：

1. A07 现在同时支撑 NCv4 Vector Engine 和 Scalar Engine 的 1.2 TFLOPS。两个事实均改为两个 source_id 交叉支持；A10 仍保留来源、endpoint 和断言，但退出 package 最小集。本轮最小集由九源改为八源。
2. A08 的 `2.52 PFLOPS generic FP8` 已建立独立 component、precision path、condition、fact、assertion、requirement、卡片和 backlog 映射。它与 A06 的 `2,517 MXFP8/MXFP4 TFLOPS` 标签和显示精度不同，两条事实不合并。
3. 五组字段主体已按字段合同重建。Inferentia1 的 Vector/Scalar `OP/cycle` 改挂 precision path，Trainium1 与 Inferentia2 的 CC-Core 数量改挂 component。Trainium3 的 2.4 GHz 主语确实是 Tensor Engine；正式 Trainium2 已有四条 reviewed 组件时钟先例，因此 `audit/field-contract-change-candidate.csv` 提出最小全局变更 `FIELD-PHY-CLOCK: object → object;component`。本包没有修改任何 `fields.csv`；正式合并前必须由总控批准该合同变更。

七条错误 source notes、七条非逐字 `quoted_context`、20 条夸大的 search 类型、A09 的 Trainium4 排除理由和 `SCREEN-M2-GA-A01` 生命周期也已修正。69 条引文已经逐条在固定 HTML 的规范化正文中匹配；A01 与 A07 仍是仅有的两组 latest/版本化正文等价入口。

## 来源与最小集

11 个 HTML 抓取件均取得于 2026-08-13，并登记为新的 `web_snapshot` endpoint 候选。拟正式路径是 `最小参考资料库/快照/AWS/PackageImplementations/2026-08-13/`；复制映射和 SHA-256 见 `source-gate/source-freeze-register.csv`。A01 和 A07 的版本化入口为首选，latest 只作审计；同一正文不增加独立证据数量。

八源选择包括 A01、A02、A03、A04、A05、A06、A07 和 A08。A10 的五条 package 事实全部由 A07 直接覆盖，因此 `structured/source-coverage.csv` 将其记为当前事实集内 `fully_covered`。A09 只支撑 Trainium4 路线图及 6×、4×、2× 相对声明；当前四个 package 对象不含 Trainium4，所以仅在本包排除，既有架构 selection run 不删除。

原 M2-GA 架构包的 23 条 implementation backlog 拆成 57 条互异事实。Trainium2 的 `DEF-M2GA-ATRN2-01` 继续复用正式 M1 链，不复制事实。`audit/card-fact-coverage.csv` 与 `audit/fact-requirement-map.csv` 均有 57 行，实现事实、字段要求和四张卡的双向覆盖。

## 生命周期候选

`audit/lifecycle-manifest-candidate.csv` 按 DEC-025 列出实际拟写正式库的 457 个“表名＋主键”组合，其中 438 行来自非空 structured 表，19 行来自 source、endpoint 和 screening overlay。候选拟把 407 行从 `draft` 升为 `reviewed`；49 行未决冲突链保持 `needs_resolution`，`SCREEN-M2-GA-A01` 的 update_existing 行保持 `reviewed → reviewed`。该文件只是候选，`package_review`、独立 signoff 和冻结绑定均仍为 pending；修正者不能自行签字。

## 验证入口

`scripts/Test-Staging.ps1` 同时支持相对和绝对 `RootPath`，并额外检查字段主体合同、69 条逐字引文、B01 来源说明、20 条检索类型、八源反向移除和生命周期候选。`scripts/Test-TemporaryFormalMerge.ps1` 只在本 staging 内建立临时正式库，运行官方 validator 后删除临时目录，并记录正式 32 表前后哈希。最终检查结果写入 `validation-report.md`。相对路径和绝对路径调用各通过 9,289 项检查；当前正式基线通过 93,179 项检查，隔离临时合并通过 101,048 项检查，32 张正式表前后哈希一致，临时目录已删除。

目录中的 `scripts/Apply-Remediation.ps1`、`Apply-Card-Remediation.ps1` 和 `Build-LifecycleManifestCandidate.ps1` 保留本次修正与清单生成步骤，方便独立复核者复算；不要在已修正目录上重复运行前两份一次性转换脚本。