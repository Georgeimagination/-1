# M2-W3 华为 Ascend 950 物理对象暂存包

> 工作包：`M2-W3-HUAWEI-ASCEND950-PHYSICAL`  
> 状态：`ready_for_final_independent_review`  
> 资料截止日：2026-08-13  
> 写入边界：仅限本目录；正式 32 表、正式资料卡、项目根文档、其他暂存包和历史调研目录均未修改

CSV 是逗号分隔表格，HBM（High Bandwidth Memory）是高带宽内存，TFLOPS 表示每秒万亿次浮点运算，PCIe（Peripheral Component Interconnect Express）是一种高速外设互联。`SHA-256` 是用来核对文件内容是否变化的散列值。

本包为三个已预留对象准备待复核资料卡和结构化增量：共享裸片 `OBJ-HUAWEI-ASCEND-950-DIE`、950PR 封装 `OBJ-HUAWEI-ASCEND-950PR`、950DT 封装 `OBJ-HUAWEI-ASCEND-950DT`。两种封装继续复用正式库既有的 `package_contains_die` 关系；本包不新增对象或关系，不推断 Da Vinci `implements_architecture`，也不迁移旧待办中的 15 条实现事实。

## 交付内容

`card-draft/` 有三张资料卡，分别对应共享裸片、950PR 和 950DT。`structured/` 有 24 份与正式表同表头的增量 CSV，共 41 条事实、50 条逐来源断言、106 条字段要求和 27 条九域完整度记录。41 条事实按主体分为共享裸片 12 条、950PR 16 条、950DT 13 条；106 条要求由 41 条 `value_available`、53 条 `not_found`、11 条 `not_applicable` 和 1 条 `pending_verification` 组成。

检索记录和最小来源集也在同一批结构化文件中。53 条 `not_found` 要求各有一条独立、字段特定的检索日志，每条日志都记录了 H-2、H-6（含 950DT 路由状态）、H-7 和 H-12 四个官方来源的检查结果，共 212 条结果。没有把同一条模板日志复制给多个字段。

## 三层边界

H-2 先直接说明 950PR 与 950DT 使用同一颗 Ascend 950 裸片，随后以复数 “Ascend 950 chips” 给出四条低精度吞吐、SIMD（单指令多数据）与 SIMT（单指令多线程）混合执行、128 byte 访问粒度和共同 2 TB/s。七项取值是直接来源事实；把主语归一化到共享裸片则依据前一句完成，因此相应七条逐来源断言为 `inferred`。这些事实只记录一次，`fact_kind=direct_statement`、`evidence_state=source_with_caveat` 和单来源计数不变。来源没有说明矩阵、向量、稠密或稀疏口径，因此吞吐路径的 `operation_class` 保留为 `other`，条件集的 `operation_type` 留空，计数规则写成 `vendor_label`；不能把厂商标签改写成矩阵峰值。

950PR 只保存封装和当前处理器页特有事实，包括 HiBL 1.0、最大 128 GB、1.6 TB/s、未注明精度和运算类别的最大 1784 TFLOPS，以及灵衢 2.0 的最高 2 TB/s 双向互联。H-12 直接说明搭载 950PR 的 Atlas 350 在 2026-03-20 正式上市；把这条卡级上市陈述归一化为 950PR package 在嵌入条件下 `available`，属于主体和状态推断。该状态断言为 `inferred`，Atlas 350 搭载关系及伙伴整机的 deployment 断言仍为 `direct_statement`。这不表示 950PR 独立零售、单独客户交付或已有出货量，精确的独立封装可用日期仍是 `not_found`。

950DT 只保存 H-2 的对象匹配路线图事实：HiZQ 2.0、144 GB、4 TB/s、2 TB/s 总互联，以及 Decode 阶段推理和模型训练定位。截止日状态为 `announced`；2026 年第四季度是未来路线图窗口，精确可用日期保持 `pending_verification`。H-6 的 `?tag=950dt` 路由可访问，但固定的服务器正文仍显示 950PR，因此该入口只支持名称和路由身份，不支持 950DT 规格、正式上市或客户交付。

Atlas 350 的 1561/804/425 TFLOPS、112 GB、1.4 TB/s、PCIe、卡间互联、600 W、散热、尺寸和重量均未下放到封装或裸片。H-12 的七家伙伴整机和代际商用措辞也没有用于提升 950DT 状态。第三方来源迁移数为 0。

## 最小来源集

四个来源版本和五个入口均已固定到 2026-08-13 快照，字节数和 SHA-256 见 `source-freeze-register.csv` 与 `structured/source-endpoints.csv`。反向移除后，最小集保留 H-2、H-6 和 H-12：H-2 不可替代地支撑共用裸片、两种封装和 950DT 路线图；H-6 不可替代地支撑当前 950PR 参数及 950DT 路由审计；H-12 不可替代地给出 950PR 嵌入 Atlas 350 的日期化商用状态。H-7 的当前搭载关系被 H-12 覆盖，卡级参数又不在本包主体范围内，因此筛为 `redundant_covered`，但固定快照仍保留作边界审计。

`source-identity-preflight.md`、`object-scope.csv` 和 `identity-gate-evidence.csv` 是先前身份门检查点，保留当时的 `ready_for_fact_extraction` 结论；本 README 的 `ready_for_final_independent_review` 是完成返修和重验证后的当前包状态。

## 验证结果

包级验证器通过 1,087 项检查，覆盖 24 份表头、主键、正式库碰撞、字段主体合同、字段要求目标合同、证据来源计数、对象层级、状态边界、来源筛选、反向移除、检索日志、快照哈希、资料卡事实映射，以及恰好八条 `inferred` 的固定集合门。

把暂存增量叠加到正式库只读副本后，官方验证器在 `gate` 模式通过 115,461 项检查。临时副本随后删除。正式库自身仍通过 106,160 项检查；32 份正式 CSV 与刷新后的 AWS 合并后基线逐文件 SHA-256 和字节数完全一致，变化数为 0。事务采用的正斜杠 `table_path|sha256` 聚合值仍为 `f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10`；本包使用 Windows 相对路径计算的 `relative_path|sha256|bytes` 聚合值为 `f58d455018ba4a9580427e23948acdd553ad3d61da9e6177c2ca20d9af3633cd`。两者算法不同，静态性结论来自相同逐文件哈希的前后比较。

验证细节见 `validation/validation-report.md`、`validation/package-validation-results.json`、`validation/temp-merge-summary.json` 和 `validation/formal-32-staticity-summary.json`。`validation/temp-merge-root/` 已清理，不存在遗留临时副本。

## 独立复核重点

最终独立复核应先确认断言模式固定集合：七条 H-2 共同芯片规格和 `ASSERT-M2W3-HUAWEI-PR-STATUS-H12` 恰为 `inferred`；`ASSERT-M2W3-HUAWEI-PR-DEPLOY-H12` 及其余 41 条断言保持 `direct_statement`。随后再核对 H-6 的 1784 TFLOPS 仍是未决精度和运算类别、950PR 的 `available` 始终带“嵌入已上市 Atlas 350”条件、950DT 保持 `announced` 与 `pending_verification`，以及 H-7 卡级参数全部未下放。共同芯片、950DT 路线图和 950PR 当前产品页中的三个 2 TB/s 分属不同条件，不能相加。复核通过前，selection run 和所有增量行仍为 `draft` 或 `needs_resolution`，不能合并到正式库。

完整文件清单及哈希见 `manifest.csv`。项目根 `README.md` 和 `AGENTS.md` 已检查；本轮只提交隔离暂存包，未改变项目范围、正式结构或正式进度，因此由总控在独立复核和正式合并后统一更新。