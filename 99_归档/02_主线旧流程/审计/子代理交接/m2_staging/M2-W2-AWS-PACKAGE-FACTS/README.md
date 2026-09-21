# M2-W2-AWS-PACKAGE-FACTS staging

状态：`ready_for_independent_review`。本目录只保存 M2 第二波 AWS package 实现事实候选，不修改正式 32 表、正式资料卡、项目状态文件或项目说明。

## 当前结构计数

截至 2026-08-13，已形成 4 张单芯片/package 资料卡、56 条事实候选和 66 条逐来源断言。实现实体包括 24 个组件、6 个存储层、3 条芯片级互连和 17 条精度路径，并由 28 个条件集限定。字段要求共 70 条，其中 50 条对应已抽取字段，20 条物理构造字段为 `not_found`；20 条检索日志和 50 条逐来源检索结果记录了缺失结论。五组未决冲突含 10 个候选成员：Trainium1 与 Inferentia2 的 820 GiB/s、820 GB/s 单位差异，以及 Trainium3 的 144 GiB、144 GB 容量差异、4.9 TB/s、4.7 TB/s 带宽差异和 16、20 个 CC-Core 数量差异。九域完整度为 4 个对象各 9 行，共 36 行。

原 M2-GA 架构包的 23 条 implementation backlog 均已分流到本包，拆成 56 条可定位事实；Trainium2 的 `DEF-M2GA-ATRN2-01` 复用既有正式 M1 来源链，不重复建事实。因此 `audit/backlog-disposition.csv` 共 24 行。`audit/card-fact-coverage.csv` 以 56 行建立资料卡与 fact_id 的双向覆盖。

## 对象边界

四个对象均复用正式预留 ID：`OBJ-AWS-INFERENTIA1-CHIP`、`OBJ-AWS-TRAINIUM1-CHIP`、`OBJ-AWS-INFERENTIA2-CHIP` 和 `OBJ-AWS-TRAINIUM3-CHIP`。正式 `implements_architecture` 关系已经存在，本包不复制执行机制、数值语义或软件接口，也不把云实例、服务器和机架聚合值下放到 package。这里的 `package` 是保守的芯片实现事实容器；公开页面没有证明裸片数、芯粒构成、封装方式、中介层、裸片面积和晶体管数，这些字段保持 `not_found`，而不是推断为单裸片。

## 来源门

11 个 HTML 抓取件实际取得于 2026-08-13，均作为新的 `web_snapshot` endpoint 候选，`access_date` 与 `snapshot_date` 都是 `2026-08-13`。候选 `local_path` 指向拟正式位置 `最小参考资料库/快照/AWS/PackageImplementations/2026-08-13/`；现有文件仍只保存在本 staging 的 `fixed-candidates/`，总控合并时应按 `source-gate/source-freeze-register.csv` 的 `staging_local_path → local_path` 映射复制并复核 SHA-256。不能把它们补挂到 2026-08-12 旧 endpoint。

A01 和 A07 的 latest 与 v2.31.0 完整页哈希不同，但 `<article>` 正文逐字符相同；两组各只计一个 `source_id`，版本化 endpoint 是首选，latest 只作入口审计。`structured/source-endpoints.csv` 是 11 条 append 候选；既有主入口的 `is_preferred_endpoint=false` 更新单列在 `audit/source-endpoint-updates.csv`。既有 source 的版本/哈希/冻结状态更新和 A01 screening 更新分别放在 `audit/source-updates.csv`、`audit/source-screening-updates.csv`，不能作为新行 append。

九个 package 事实来源均有不可替代事实，进入 `SELRUN-M2W2-AWS-PKG-20260813` 的最小来源候选；A09 只支持状态信息，本包没有抽取供货状态，因此排除。selection run 仍为 `draft`，必须由不同代理独立复核后才能升级。

## 验证状态

staging 专用校验器 `scripts/Test-Staging.ps1` 已通过 8,322 项检查，覆盖 32 个正式表头、必填值、枚举、外键、主键碰撞、事实/断言 XOR、证据数量、缺失检索、冲突、来源门、backlog、九域完整度和卡片双向覆盖。临时合并脚本 `scripts/Test-TemporaryFormalMerge.ps1` 已把 append 候选与既有 PK overlay 分流合并到临时目录，正式 validator 通过 99,503 项检查。验证前后 32 张正式表的 SHA-256 全部不变，临时目录也已删除。两份一次性 Build 脚本已在冻结前删除；长期保留两份只读验证器。

## 目录

- `card-draft/`：4 张可独立复核的中文 package 实现资料卡。
- `structured/`：与正式 32 表同表头的 append 候选；无新增行的表只保留表头。
- `audit/`：既有 PK 的 overlay 更新、backlog 分流、反向移除、卡片覆盖和验证记录。
- `source-gate/`：11 个快照的拟正式路径、staging 路径、哈希与 endpoint 正文等价审计。
- `fixed-candidates/`：只读的 2026-08-13 HTML 抓取件，正式合并前的来源载体。
- `scripts/`：独立 staging 校验器和临时合并正式 validator。