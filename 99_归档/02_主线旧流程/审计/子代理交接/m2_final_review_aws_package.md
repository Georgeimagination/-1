# M2-W2 AWS（Amazon Web Services，亚马逊云服务）四代物理对象事实包最终独立复核

> 最终裁决：`accept`  
> 复核对象：`审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS-REMEDIATED/`  
> 复核者：`m2_final_review_aws_package`  
> 复核日期：2026-08-13

## 裁决

修正版可以合并，但授权严格限于随本报告签发的 `m2_final_review_aws_package_merge_signoff.csv`。该清单有 486 行：478 行是精确写入授权，另外 8 行是四个既有对象和四条既有关系的禁止写入守卫。478 项写入由 457 个生命周期主键、1 个字段合同单元格、1 个来源选择运行（selection run）业务签字、4 个 evidence（证据）完整度签字、11 个快照文件和 4 张收口后的正式卡组成。清单 SHA-256 为 `58f2368764e4fb132fe63a5acc427f22cdace7c38538270a7457e566d19bbd05`。

本裁决绑定三项冻结值：77 文件汇总哈希（aggregate）为 `46fd41d8b19a82dc22c24ddee5c1b4e3534cacfe56bc4258cd1c9756ed67b552`，freeze manifest SHA-256 为 `74fe487790a0d2fbcaf012c1d60b409fd065dad5480a769843c28dab070036c4`，457 行 lifecycle candidate SHA-256 为 `f2682bdaf3ee4bee58aa95e20aa60461cc96a1f1fbc20a04b93bdcd2e98bc880`。正式静止基线的 32 表哈希 aggregate 为 `0b4c6106bde7e2a62b1ffd6a0df7246ded62177d941c7fb9303a2cbac62f92bf`。任一冻结件或正式基线发生变化，都不能沿用本签字，必须重新构造隔离合并并复核差异。

## 正式基线与隔离合并

Google 范围包在本轮期间正式预留了 3 个 `cloud_accelerator` 对象和 3 条 `implements_architecture` 关系。独立复核因此以当前 78 个对象、27 条关系为静止基线，而不是修正版冻结时记录的 75 个对象、24 条关系。正式校验器在当前库通过 93,251 项检查，注册表为 323 列、488 个枚举值；修正版内 `final-counts.json`、`formal-baseline-validation.txt` 和旧临时合并记录中的 75/24、93,179、101,048 是冻结当时的历史记录，不是当前基线，也不是包损坏。

我按签字清单的最终边界重建了隔离副本：先从当前 78/27 基线复制 32 张正式表，再按 457 个主键写入并执行生命周期状态，单独更新 `FIELD-PHY-CLOCK`、selection run 和四个 evidence 完整度行，复制 11 个快照，并生成四张收口卡。官方 `Validate-ResearchData.ps1` 在隔离副本通过 101,184 项检查，退出码为 0。正式 32 表哈希 aggregate 在操作前后均为 `0b4c6106bde7e2a62b1ffd6a0df7246ded62177d941c7fb9303a2cbac62f92bf`，变化表数为 0；隔离目录和驱动文件均已删除。这里的 aggregate 按表路径排序，把每个 `table_path|sha256` 以 LF 连接且末尾不加换行，再对 UTF-8 无 BOM 文本计算。

## B01 至 B09 关闭情况

| 问题 | 裁决 | 复核依据 |
|---|---|---|
| B01 来源说明误称多入口等价 | 已关闭 | 只有 A01、A07 保留 latest 与版本化入口正文等价说明；A02 至 A06、A08、A10 均明确为单一固定快照。 |
| B02 A07 漏证两条 1.2 TFLOPS，A10 误留最小集 | 已关闭 | A07 与 A10 都直接支持 Vector、Scalar 两条 1.2 TFLOPS 事实。A10 的五条本包事实全部被 A07 覆盖，故退出本轮八源最小集，但其来源、访问入口（endpoint）、断言和既有架构链不删除。 |
| B03 A08 通用 FP8 2.52 PFLOPS 缺链 | 已关闭 | 已建立独立 component、precision path、condition、fact、assertion、requirement、卡片和 backlog 映射；规范值为 `2520000000000000 FLOP/s`，不与 A06 的 `2517000000000000 FLOP/s` MXFP8/MXFP4 链归一。 |
| B04 摘录不是逐字证据 | 已关闭 | 69 条摘录全部在首选固定件中逐字命中，定位符（locator）行号有效，摘录也都位于指定单行或行段内；三类失败数均为 0。 |
| B05 事实主体不符合字段合同 | 已关闭，本包局部修复 | Inferentia1 的 Vector/Scalar 每周期运算量改挂 `precision_path`，Trainium1 和 Inferentia2 的 CC-Core 数量改挂 `component`，Trainium3 Tensor Engine 2.4 GHz 保持 `component`。本包只授权 `FIELD-PHY-CLOCK` 的 `object → object;component`。 |
| B06 not_found 检索夸大来源类型 | 已关闭 | 前 15 条只登记 `developer_documentation`；Trainium3 的 5 条登记 `developer_documentation;press_release`。50 条逐来源检索结果与声明范围一致，没有声称检查未登记的云服务文档。 |
| B07 A09 排除理由错误 | 已关闭 | A09 只支持 Trainium4 路线图及 6×、4×、2× 相对声明；当前四个 package 对象不含 Trainium4。排除只作用于本包，不删除既有架构 selection run。 |
| B08 A01 screening 生命周期倒退 | 已关闭 | `SCREEN-M2-GA-A01` 的筛选语义改为 `selected`，生命周期保持 `reviewed → reviewed`，没有降级。 |
| B09 相对 RootPath 校验失败 | 已关闭 | 修正版先规范化根路径；相对和绝对 RootPath 均通过 9,289 项 staging 检查。 |

## FIELD-PHY-CLOCK 的局部合同

正式 `FIELD-PHY-CLOCK.allowed_subject_kinds` 当前只有 `object`。现有正式库已经有 4 条 Trainium2 组件时钟事实和 4 条 `value_available` 组件时钟要求；本包又新增 Trainium3 Tensor Engine 2.4 GHz 组件事实。因此，`component` 是事实主体合同所必需的类型，本包精确授权把该单元格改为 `object;component`，其他字段列不变。

本包不授权加入 `precision_path`。正式库确有 3 条 H100 `precision_path` 不匹配，但它们全是 `not_found` 字段要求，用来表达 FP16、BF16 和 INT32 路径缺少可归属频率，并不是以路径为主体的频率事实。不能仅因为缺失覆盖要求采用了路径目标，就无意放宽事实主体合同。总控完成的全库预审共有 132 条主体不匹配，涉及 8 条事实、124 条要求、26 个字段和 28 个分组；其 CSV SHA-256 为 `447ffbc05cbe387028037d5c30a8f218993712cfbe6063146a8c2b324d2855f5`。这些问题另案审查，本裁决只关闭 AWS 包对 `component` 的局部需要，不声称全库字段主体已经闭合。

## 事实、要求、断言与资料卡闭环

结构化表可复算为 27 个组件、6 个存储层、3 条链路、20 条精度路径和 29 个条件集。核心记录有 57 条事实、69 条逐来源断言和 71 条字段要求。字段要求由 46 条 `value_available`、5 条 `conflicting_unresolved` 和 20 条 `not_found` 组成。事实按对象分布为 Inferentia1 8 条、Trainium1 11 条、Inferentia2 11 条、Trainium3 27 条，没有缺失主体或越界主体。

`audit/fact-requirement-map.csv` 有 57 行，含义是每条事实恰好映射一次，不是只有 57 个唯一 requirement；同一冲突 requirement 可以对应两个互斥事实。69 条断言中，67 条数值断言按 TFLOPS、PFLOPS、TOPS、GB/GiB/MiB、GB/s/GiB/s/TB/s 和 GHz 的十进制或二进制因子独立复算，转换失败为 0；另外两条文字事实是 3 nm 和 HBM3e，原文标签保持不变。

四张卡与 57 条事实双向闭合，卡内断言摘录也能回到 69 条结构化断言。`card-completeness.csv` 有 36 行，即四个对象各九域：identity、physical、compute、numerics、memory、interconnect、special_engines、software 和 evidence。最终签字把四个 evidence 行从 `needs_review` 收口为 `complete`，把 `assessor` 从 `m2_w2_aws_package_facts` 改为 `m2_final_review_aws_package`，notes 统一记录 11 个固定件、A01/A07 同正文去重和独立复核通过；其余完整度语义不变。457 行 lifecycle manifest 保持冻结，不需改版：它只负责把这四行的 `review_status` 升为 `reviewed`，上述三项业务收口由独立签字另行授权。

四张收口后的最终字节已经另存到 `审计/子代理交接/m2_final_review_aws_package_cards/`，不需要总控重新执行字面替换。正式合并只允许从该目录逐字节复制到以下目标；每个来源成品文件（payload）的 SHA-256 和字节数都与签字清单的 `expected_output_sha256`、`expected_output_bytes` 一致：

| 正式目标 | 字节数 | 最终 SHA-256 |
|---|---:|---|
| `资料卡/AWS/封装/AWS_Inferentia1_芯片实现资料卡.md` | 7,481 | `b056efebdfc9423c95b00605b2c62dd8ed9418198e02ff12c4c61438116c7704` |
| `资料卡/AWS/封装/AWS_Inferentia2_芯片实现资料卡.md` | 8,795 | `c5f78d35d83a53512e252d12756c4b80bd5da78089a88c163189667f5ca0224d` |
| `资料卡/AWS/封装/AWS_Trainium1_芯片实现资料卡.md` | 8,749 | `6addea13a0251e1bc09eb6d545327abbac9cbffe2cee16ec810d72b6f23afc99` |
| `资料卡/AWS/封装/AWS_Trainium3_芯片实现资料卡.md` | 16,149 | `b3ad398adad27f99180371ccec74839575947d9f9d61c8a88c4c024dab53f898` |

四卡首页最终状态为 `accepted`，使用“正式事实”“实现事实”和“最小来源集”，evidence 为 `complete`。对象层级仍是保守的 `package`，卡片验收不等于封装构造已知。

## 最小来源集、反向移除与冲突

本轮最小来源集是 A01 至 A08。独立按 57 条事实反向移除，结果如下：

| 来源 | 支持事实数 | 移除后失去唯一直接证据的事实数 | 本轮裁决 |
|---|---:|---:|---|
| A01 | 5 | 5 | 保留 |
| A02 | 3 | 3 | 保留 |
| A03 | 7 | 5 | 保留 |
| A04 | 7 | 5 | 保留 |
| A05 | 12 | 8 | 保留 |
| A06 | 10 | 7 | 保留 |
| A07 | 15 | 8 | 保留 |
| A08 | 5 | 4 | 保留 |
| A09 | 0 | 0 | 按对象范围排除 |
| A10 | 5 | 0 | 被 A07 完整覆盖，不入本轮最小集 |

`SELRUN-M2W2-AWS-PKG-20260813` 的业务 `status` 明确授权从 `draft` 改为 `reviewed`，`reviewer` 从 `pending_independent_reviewer` 改为 `m2_final_review_aws_package`，notes 末句从“等待独立复核。”改为“最终独立复核已通过。”，其他业务列不变。A01 至 A08 对应的 8 个 selection member 均由各自生命周期主键授权把 `review_status` 从 `draft` 改为 `reviewed`。

五组冲突保留 10 个成员，没有 `preferred_fact_id`，也没有通过单位换算静默选值：Trainium1 的 820 GiB/s 与 820 GB/s、Inferentia2 的 820 GiB/s 与 820 GB/s、Trainium3 的 144 GiB 与 144 GB、4.9 TB/s 与 4.7 TB/s，以及 16 与 20 个 CC-Core。相关 component、memory level、fact、assertion、requirement、conflict group 和 conflict member 继续使用 `needs_resolution`。

## 固定来源与逐字证据

冻结 manifest 有 76 条文件记录；连同 manifest 自身，包内共 77 个文件。逐条复算后，文件存在性、字节数和 SHA-256 全部吻合，没有漏记或多余文件。77 文件 aggregate 的算法是沿 manifest 当前行序，把 `relative_path|sha256|bytes` 以 LF 连接且末尾不加换行，再对 UTF-8 无 BOM 文本计算 SHA-256。

11 个 HTML 固定件均已完整读取。每个固定件对应一个 2026-08-13 的 `web_snapshot` endpoint，`access_date` 和 `snapshot_date` 都是 2026-08-13，HTTP 状态为 200，MIME 类型为 `text/html`，文件路径、字节数和哈希与登记值一致。A01 和 A07 各有 latest 与版本化入口；抽取正文后逐字符相同，正文长度分别为 1,788 和 31,435，因此每组只计一个 `source_id`。其他来源只有单一固定快照。

69 条 `quoted_context` 全部在对应首选固定件中逐字命中。69 个 locator 都落在有效行号范围内，摘录也全部出现在 locator 指定的单行或行段中。A08 的通用 FP8 2.52 PFLOPS 已有自己的逐字证据和 locator；A07 新增的 Vector、Scalar 1.2 TFLOPS 证据同样通过。

## 457 行生命周期签字

生命周期候选有 457 个唯一 `table_path + pk_value`，由 438 个 structured 主键和 19 个 overlay 主键组成。写入动作是 389 个 `append_then_promote_review_status`、49 个 `append_without_review_promotion`、18 个 `update_existing_then_promote_review_status` 和 1 个 `update_existing_preserve_review_status`。按当前正式库逐主键重建，没有碰撞、缺项、多余项或字段摘要不一致。

其中 407 行把 `draft` 提升为 `reviewed`；49 行保持 `needs_resolution`；`SCREEN-M2-GA-A01` 保持 `reviewed → reviewed`。49 个未决主键由 4 个 component、3 个 memory level、10 个 fact、5 个 requirement、12 个 assertion、5 个 conflict group 和 10 个 conflict member 组成。断言是 12 行而不是 10 行，因为部分冲突事实有两条来源断言。

签字 CSV 对 457 行逐一写明目标表、主键列、主键值、冻结来源文件及 SHA-256、正式表合并前 SHA-256、正式存在状态、候选与授权后的 review status、语义状态和三项冻结绑定。它不是“整个 staging 目录均可合并”的宽泛授权。

## 四个既有对象与四条关系继续未决

以下四个对象和四条 `implements_architecture` 关系已经在正式库中，但不在 457 行生命周期候选内，本报告也不授权更改：

- `OBJ-AWS-INFERENTIA1-CHIP`、`OBJ-AWS-TRAINIUM1-CHIP`、`OBJ-AWS-INFERENTIA2-CHIP`、`OBJ-AWS-TRAINIUM3-CHIP`；
- `OREL-AWS-INFERENTIA1-IMPLEMENTS-ARCH`、`OREL-AWS-TRAINIUM1-IMPLEMENTS-ARCH`、`OREL-AWS-INFERENTIA2-IMPLEMENTS-ARCH`、`OREL-AWS-TRAINIUM3-IMPLEMENTS-ARCH`。

一手材料足以证明四个单器件边界，并支持它们分别复用对应架构；但仍没有公开裸片数、芯粒数、基板、封装外形或订货形态。`package` 只是保守的事实归属容器。把关系升为 `reviewed` 也会掩盖其主体容器尚未解决的物理身份，因此八个主键都继续为 `needs_resolution`，所有列保持不变。签字清单专门列出 8 个 `no_write_guard`，避免合并时把“事实包验收”误读成对象身份升级。

## 精确合并边界

`m2_final_review_aws_package_merge_signoff.csv` 是唯一写入授权。总控合并时应逐行执行，并遵守以下边界：

1. 457 个 lifecycle 主键只按各自行的 `source_path`、`source_sha256` 和 `write_action` 写入；除授权的 review status 外，语义列必须与冻结来源行一致。
2. `FIELD-PHY-CLOCK` 只改一个单元格；selection run 只改 `status`、`reviewer` 和 notes 末句；四个 evidence 行只改 `completeness_status`、`assessor` 和 notes；11 个快照仅在目标不存在时逐字节复制；四张卡只从 `m2_final_review_aws_package_cards/` 复制并命中最终字节哈希，不能重新生成或改写。
3. 8 个 `no_write_guard` 不构成写入许可。`objects.csv` 和 `object-relations.csv` 不能因本包验收而改动。
4. `资料卡/型号索引.md`、进度文件、README 和 AGENTS 不在本签字内。总控完成真实合并并重新校验后，再按项目规则更新这些全局文件。

本轮不签发 m2_final_review_aws_package_replay.ps1。最终隔离驱动是临时副本构造器：它从正式根复制 32 表、创建并清理 junction（目录连接）和临时目录，合并步骤也写在驱动内部；它并不逐行解释 486 行 signoff，也没有面向任意 TargetRoot 的目标存在即停和禁止覆盖保护。把它临时改造成正式写入器风险过高。总控应以签字 CSV 为准实现或人工执行受控合并，不能直接复用隔离驱动。

## 工具异常与文档检查

复核过程中有几次临时自动化命令构造错误：一个 Windows PowerShell 临时驱动因缺少 UTF-8 BOM 在解析中文时失败，一个筛选表达式缺空格导致语法错误，一个语句结果直接接管道触发解析错误，一次终检又把卡片状态行的通配匹配条件写错；另一次隔离合并已经通过 101,184 项校验，但外层断言错误地期待带千位分隔符的 `101,184`，而脚本实际输出 `101184`，因此被包装器标成失败。它们都属于复核者的命令或断言构造错误，不是沙箱拒绝、审批失败、远程服务错误或工具运行时故障。失败轮次均未写正式库或 staging，临时目录已清除；修正后从静止基线重新完整执行并通过。

已检查项目级 `README.md` 和 `AGENTS.md`。它们已经记录当前 78/27 基线、AWS 包修正状态和全库 132 条主体预审；本子代理的授权范围又禁止修改全局文档，因此本轮不更新。总控真实合并后应再同步项目状态、型号索引和运行计数。

## 最终结论

B01 至 B09 均已在本包边界内关闭。事实、要求、逐来源断言、四卡、九域完整度、八源最小集、五组未决冲突、11 个固定件和 457 个生命周期主键都能独立复算；最终隔离合并通过官方校验，正式 32 表未发生变化，临时文件已删除。因此裁决为 `accept`。该结论不解决全库字段主体审计，也不把四个保守 package 对象及其关系升级为 `reviewed`。