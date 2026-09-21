# M2 Ascend 950 物理对象包独立复核

- 工作包：`M2-W3-HUAWEI-ASCEND950-PHYSICAL`
- 复核日期：2026-08-13
- 复核方式：独立、只读；复核者未参与该包生成
- 结论：`accept_with_fixes`

## 结论

本包的三个对象、状态边界、来源职责和结构化数量基本成立。Ascend 950 共享裸片、950PR 封装和 950DT 封装没有混成一个对象；950PR 的 `available` 已限定为随 Atlas 350 嵌入商用，950DT 仍是 `announced`；Atlas 350 卡级参数、15 条旧 Da Vinci 待办和第三方数字的迁移数都是 0。包校验、正式库静态性和基于当前正式库的临时合并也都通过。

当前阻断由两类、共八条断言的主体模式组成。H-2（Huawei Connect 2025 主题演讲）先说明 950PR 与 950DT 使用同一颗 Ascend 950 die，随后把算力、向量机制、访存粒度和互联写给复数主语 “Ascend 950 chips”。把这些共同规格只存一次、避免复制到两个封装的方向合理，但从 “chips” 落到共享 die 是依据上下文完成的主体规范化，不是来源逐字给出的 die 级陈述。另一个同类问题是 H-12（2026-03-20 Atlas 350 官方发布材料）直接陈述 Atlas 350 搭载 950PR 并正式上市，包内据此把 950PR package 的状态归一化为带嵌入条件的 `available`；这个状态主体转换同样是推断。八条断言现为 `direct_statement`，应改为 `inferred`。修复、重跑校验并由独立复核者确认前，本报告不授权正式合并，也不授权生命周期迁移。

## 1. 复核范围和基线

本次完整读取了根目录 `AGENTS.md`、`研究计划.md`、`进度/当前状态.md`，以及对象范围验收、华为/寒武纪批次计划、下一队列审计、物理对象就绪审计和本包的 README、handoff、三张资料卡、来源预审、身份门、来源冻结、事实冻结、结构化表、验证脚本与验证结果。正式库在复核期间保持 AWS（Amazon Web Services）合并后的 32 表基线，没有并发合并。

复核只写本报告。暂存包、正式 32 表、正式资料卡、来源快照、项目 README、`AGENTS.md`、研究计划和进度文件均未修改。需要写入的校验在系统临时目录内复制后执行，结束后已核对目标位于临时目录并清理。

## 2. 阻断项和精确修复

### 2.1 八条断言需要改模式

H-2 的相邻原文形成两层证据：第一层直接说明 950PR 与 950DT 使用同一颗 Ascend 950 die；第二层以 “Ascend 950 chips” 为主语给出四种算力标签、SIMD 与 SIMT 混合向量设计、128 byte 访存粒度和 2 TB/s 互联。SIMD 是单指令多数据，SIMT 是单指令多线程。第二层没有逐字说这些规格的主语就是 die。

以下七个 H-2 主键的 `assertion_mode` 必须从 `direct_statement` 改为 `inferred`：

- `ASSERT-M2W3-HUAWEI-DIE-FP8-H2`
- `ASSERT-M2W3-HUAWEI-DIE-MXFP8-H2`
- `ASSERT-M2W3-HUAWEI-DIE-HIF8-H2`
- `ASSERT-M2W3-HUAWEI-DIE-MXFP4-H2`
- `ASSERT-M2W3-HUAWEI-DIE-VECTOR-H2`
- `ASSERT-M2W3-HUAWEI-DIE-GRAN-H2`
- `ASSERT-M2W3-HUAWEI-DIE-LINK-H2`

第八个主键是 `ASSERT-M2W3-HUAWEI-PR-STATUS-H12`。H-12 的直接主语是正式上市的 Atlas 350；从“Atlas 350 搭载 950PR 并上市”转成“950PR package 在嵌入条件下 available”属于主体和状态归一化推断。`ASSERT-M2W3-HUAWEI-PR-DEPLOY-H12` 直接记录搭载关系及基于 Atlas 350 的伙伴整机，仍可保持 `direct_statement`。

七条 H-2 断言的 `notes` 应明确写出：来源直接主语是 “Ascend 950 chips”；共享 die 主体来自同段 “same Ascend 950 Die” 的规范化；它不证明共享 2 TB/s、950DT 的 2 TB/s 和 950PR 灵衢 2.0 的 2 TB/s 是三套可相加带宽。这七行的 `assertion_relation=qualifies` 不变。H-12 状态断言的 `notes` 应写明 Atlas 350 上市到 package 状态的推断，`assertion_relation=supports` 不变。八行的 `claim_role`、原始值、原始单位、来源定位、抽取状态和断言指纹均不需要改变；断言指纹当前不含 `assertion_mode`，修复不需要更换主键或指纹。

### 2.2 不应随之改动的事实列

七条共同规格的值仍是来源直接给出的，因此对应事实的 `fact_kind=direct_statement` 不变。它们各只有一个不同的 `source_id`，把断言模式改为 `inferred` 不会改变来源数；`evidence_state=source_with_caveat` 仍恰当。`resolution_state=provisional`、`confidence=medium` 以及现有 `confidence_reason` 已经写明“先确认同 die，再把共同芯片陈述只存一次”，也不需要改。

950PR 状态事实也不改值或 `fact_kind`：H-2 直接给过芯片的 2026 年第一季度可用路线图，H-12 又直接给出搭载它的 Atlas 350 上市；需要修正的是 H-12 到 package 状态的归一化方式。该事实仍有两个不同来源，但二者分别是早期路线图和后续嵌入商用证据，并不共同证明独立 package 交付，因此 `evidence_state=source_with_caveat`、`confidence=medium` 和嵌入条件均保持不变。

以下内容同样不动：41 条事实及其数值、106 条字段要求、11 个条件集、6 个组件、3 条链路、2 个内存层级、5 条精度路径、来源集、选择成员和三对象关系。特别是不能为了消除模式错误，把七条共同事实复制到 950PR、950DT，也不能新造 Da Vinci 架构关系。

### 2.3 随结构化修复同步改的包内说明

`object-scope.csv` 的 `SCOPE-ASC950-DIE-PRIMARY` 目前只允许“明确 die 级属性”，与包内七条共同芯片陈述的处理不完全一致。该行的 `allowed_use` 和 `notes` 应补充：共同 “Ascend 950 chips” 陈述只有在 `source_with_caveat` 且断言模式为 `inferred` 时，才可作为共享主体规范化存到 die。

三张卡片不需要改数字，但要把建模性质说清楚。共享裸片卡第 3、8、10 节应明确七项是“值由来源直接给出、主体归一化为推断”，并说明三个 2 TB/s 记录不能相加；950PR 和 950DT 卡第 3 节应说明“只读共享 die”是数据模型复用，不是厂商逐字把共同规格写给 die。950PR 卡的状态节还应明确：`available` 是从 Atlas 350 上市归一化得到的带嵌入条件状态，不是 H-12 对独立 package 状态的直接陈述；deployment 事实仍是直接搭载证据。README、handoff、事实冻结和事实审计里凡是把七项共同规格或 package 状态简称为“直接主体事实”的句子也应作同样的最小澄清。

`validation/Validate-Package.ps1` 应增加固定集合检查：上述八条恰为 `inferred`，其中七条来自 H-2，另一条是 H-12 状态断言；H-12 deployment 断言及其余断言模式不因本次修复改变。随后重跑包校验、临时合并和清单生成。修复文件变化后，现有 52 行 manifest 必须重新生成，不能沿用本报告核到的旧哈希。

## 3. 对象、状态和降层边界

三对象边界通过。`OBJ-HUAWEI-ASCEND-950-DIE` 是共享裸片；`OBJ-HUAWEI-ASCEND-950PR` 和 `OBJ-HUAWEI-ASCEND-950DT` 是两个 `package`，分别复用 `OREL-HUAWEI-950PR-CONTAINS-950-DIE` 与 `OREL-HUAWEI-950DT-CONTAINS-950-DIE`。正式库没有这三者到初代 Da Vinci 架构的正式关系，本包也没有建立或暗示该关系。

950PR 的状态链没有越界。H-12 证明 2026-03-20 正式上市的 Atlas 350 搭载 950PR，并证明七家伙伴展示基于 Atlas 350 的整机。`FACT-M2W3-HUAWEI-ASC950PR-STATUS` 使用 `available`，但条件集、事实说明、断言和资料卡都限定为“嵌入已上市卡”；独立封装的可订购、零售、客户交付和首次可用日期没有被声称，`REQ-M2W3-HUAWEI-ASC950PR-AVAILABILITY` 仍是 `not_found`。这一状态值和条件符合此前范围复核给出的“注明随 Atlas 350 部署，或继续待核”的门槛；但 `ASSERT-M2W3-HUAWEI-PR-STATUS-H12` 必须用 `inferred` 表达 Atlas 350 上市到 package 状态的归一化。deployment 断言只记录直接搭载关系，保持 `direct_statement`。

950DT 的状态链也正确。H-2 给出 2026 年第四季度的未来路线图，截止日尚未到达；H-6（昇腾官方处理器页）的 `?tag=950dt` 路由和导航能证明入口身份，但固定响应正文仍是 950PR。包内只从 H-6 给 950DT 的名称和 SKU（具体型号标识）提供补强，没有迁移 PR 的 128 GB、1.6 TB/s、1784 TFLOPS 或灵衢 2.0，也没有用入口存在把状态提升为已上市。950DT 保持 `announced`，精确可用日期保持 `pending_verification`。

H-7（官方 Atlas 加速卡页）没有事实断言。卡级吞吐、112 GB、1.4 TB/s、PCIe（高速外设互联）、卡间互联、600 W、散热、尺寸和重量均未进入三对象事实。逐一搜索下一队列审计列出的 15 个 `IMPL-FACT-HUAWEI-DV-*` 主键，结构化包命中数为 0。四个来源全部是华为一手来源，事实断言只来自 H-2、H-6 和 H-12，第三方迁移数为 0。

## 4. 结构化数量、合同和缺口检索

机械复算与包内声明一致：

| 检查项 | 复算结果 |
|---|---:|
| 事实 | 41；共享裸片 12、950PR 16、950DT 13 |
| 逐来源断言 | 50；H-2 35、H-6 11、H-12 4、H-7 0 |
| 字段要求 | 106；`value_available` 41、`not_found` 53、`not_applicable` 11、`pending_verification` 1 |
| 缺口检索 | 53 条日志、212 条结果 |
| 完整度 | 27 行，即三个对象各九域 |
| 结构对象 | 6 个组件、3 条链路、2 个内存层级、5 条精度路径、11 个条件集 |
| 未创建占位项 | special capability、topology、derived input、derived metric 均为 0 |

三个对象的九域都是 identity、physical、compute、numerics、memory、interconnect、special_engines、software 和 evidence，域内没有重复。41 条事实全部能在三张卡中找到对应主键。50 条断言都具有稳定来源定位，并至少有原始文本、原始数值或引用上下文之一。

13 条数值断言的十进制单位换算复算正确，包括 PFLOPS/TFLOPS（每秒千万亿/万亿次浮点运算）到 FLOP/s、GB 到 byte、TB/s 到 byte/s，以及 128 byte 访存粒度。没有把 GB 写成 GiB，也没有把方向不明的带宽改成单向值。950PR 灵衢 2.0 的 2 TB/s 单独保留 `bidirectional_aggregate`；共享与 950DT 的 2 TB/s 都保留 `direction_not_specified`。

53 个 `not_found` 要求各有且仅有一条检索日志，每条日志各有且仅有 H-2、H-6、H-7、H-12 四个不同来源的结果，合计 212 条，关系均为 `checked_no_support`。H-6 的基础页和 950DT 路由是同一内容版本的两个入口，不会虚增为第五个来源。这里的 `not_found` 只表示工作包预定的四个固定一手来源未给对象匹配值，不表示公开世界中永远不存在该信息。

主体合同复算没有错误。正式校验器在临时合并后也通过 `subject_contract_mode=gate`，说明事实主体和字段要求目标与当前字段注册表相容。八条阻断只涉及来源陈述方式，不是字段主体合同失败。

## 5. 最小来源集和反向移除

暂存包登记 4 个来源家族、4 个内容版本和 5 个入口。H-6 基础页与 950DT 查询页属于同一个来源，后者只保留渲染状态，不承担独立规格。

最小集保留 H-2、H-6 和 H-12，反向移除成立：移除 H-2 会丢失共享 die、两封装拆分、共同标签以及 950DT 路线图；移除 H-6 会丢失 950PR 当前产品页的 128 GB、1.6 TB/s、1784 TFLOPS 和灵衢 2.0，并丢失 950DT 路由审计；移除 H-12 会丢失带日期的 950PR 嵌入商用更新。H-7 对当前入选事实只重复 Atlas 350 搭载 950PR 的关系，H-12 还增加日期和状态；H-7 的其余内容都是越层的卡级规格。因此 H-7 标为 `redundant_covered`、保留筛选记录但不进入三源最小集是合理的。

八条断言模式修复不改变事实集合或来源覆盖，所以三源最小集成员和反向移除结论不变。选择运行仍应在独立复核完成前保持 `draft`。

## 6. 清单、正式基线和临时合并

对 `manifest`（文件清单）独立复算得到 52 行，包内除 `manifest` 自身外也恰有 52 个文件；缺失、大小不符、内容哈希不符、未登记和登记后不存在均为 0。按 `relative_path|sha256|byte_size` 排序、UTF-8、`LF` 换行连接且末尾无换行的聚合 SHA-256（安全哈希算法）为 `169e8402c5aeae5074d59bcab633eb55e3c28d1413c39780636d64603d370ac1`；manifest 文件本身的 SHA-256 为 `d7e2db27fbd5600c7af7725527e780043d0bfd8a4a39e8e952d2310cde57a688`。

正式 32 表逐文件与 AWS 合并后基线相同，变化数为 0。按项目事务算法复算的路径聚合为 `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10`；含 Windows 相对路径、哈希和字节数的包算法聚合为 `f58d455018ba4a9580427e23948acdd553ad3d61da9e6177c2ca20d9af3633cd`。当前正式校验器通过 106,160 项检查。

为避免触碰暂存包，包校验和临时合并在系统临时目录的副本中重跑。包校验通过 1,078 项检查。把 24 张暂存表追加到当前正式基线副本后，正式校验器通过 115,461 项检查；合并副本共核 74 个本地入口文件，74 个使用硬链接，复制回退为 0，临时合并根已清理。由此确认：除了本报告指出的八条断言语义模式，现有结构在当前 AWS 后基线上可以机械合并。

## 7. 合并和生命周期裁决

裁决为 `accept_with_fixes`，不是 `accept`。当前不提供正式合并授权，也不提供把任何暂存行升级为 `reviewed`、`accepted` 或其他生命周期状态的授权。

返修应保持行数和事实值不变，完成八条断言模式与说明修正、`SCOPE-ASC950-DIE-PRIMARY` 口径修正、三卡和包内说明同步、校验器增加固定集合门、manifest 重建后，再运行一次独立复核。复核者应重点确认：上述八条且仅上述八条断言为 `inferred`；对应事实的 `fact_kind`、`evidence_state`、来源数和数值未变；共同 2 TB/s、950DT 2 TB/s 和 950PR 当前 2 TB/s 在资料卡中明确为不可相加的不同条件记录。全部通过后，才可另行签署精确生命周期清单和合并授权。

## 8. 工具与文档边界记录

复核中有几次只读诊断命令构造或运行时兼容错误，包括错误文件/目录名、反斜杠正则、旧版 .NET 不支持的哈希便捷接口、路径分隔符未规范化和 PowerShell 管道语法。它们均属于模型/操作命令错误，不是用户拒绝、审批失败、沙箱拒绝、远程服务错误或实现能力限制；相应命令已用短命令更正。第一次报告骨架写入尝试在 PowerShell 解析阶段失败，目标文件当时没有写入。其余失败命令全部只读，没有改动暂存包或正式库。最终校验结果来自更正后的独立运行。

项目级 README 和 `AGENTS.md` 已检查，无需修改。本次只增加独立复核报告，项目目标、目录、数据模型、正式进度和协作规则没有变化；同时，任务边界明确禁止修改这两个文件。