# Ascend 950 物理对象来源与事实审计

> 审计日期：2026-08-13  
> 对象：共享 Ascend 950 裸片、Ascend 950PR 封装、Ascend 950DT 封装  
> 状态：返修完成，待最终独立复核

HBM（High Bandwidth Memory）是高带宽内存，SIMD 是单指令多数据，SIMT 是单指令多线程。

本审计说明 41 条候选事实如何由四个官方来源筛出，以及为什么最小来源集只保留其中三个来源版本。最小集以逐条事实和状态判断不丢失为前提，再做反向移除。

## 来源职责和反向移除

| 来源 | 进入事实断言 | 独有贡献 | 最小集结论 |
|---|---:|---|---|
| H-2，2025-09-18 Huawei Connect 主题演讲 | 35 条，其中 7 条 `inferred` | 共用裸片、PR/DT 封装拆分、共同算力标签、DT 的 HBM/互联路线图和状态窗口 | 保留；移除后会失去三对象的核心身份和 DT 路线图 |
| H-6，2026-08-13 处理器页 | 11 条 | 当前 950PR 的 128 GB、1.6 TB/s、1784 TFLOPS 未决标签和灵衢 2.0；950DT 路由渲染状态 | 保留；移除后会失去当前 PR 参数和 DT 路由审计 |
| H-7，2026-08-13 Atlas 加速卡页 | 0 条 | 在本包范围内只重复 Atlas 350 采用 950PR；其余均为卡级参数 | 筛为 `redundant_covered`；由 H-12 覆盖搭载关系，快照只保留作层级边界审计 |
| H-12，2026-03-20 Atlas 350 上市新闻 | 4 条，其中状态 1 条 `inferred` | 950PR 名称、SKU，以及嵌入已上市 Atlas 350 的日期化状态和部署关系 | 保留；移除后会失去 950PR 嵌入式商用状态的日期证据 |

结构化记录对应 `source-screening.csv`、`source-coverage.csv`、`source-selected-roles.csv`、`selection-runs.csv` 和 `selection-members.csv`。selection run 为 `SELRUN-M2W3-HUAWEI-ASC950-PHYSICAL-20260813`，算法标记为 `reverse-removal-v1+layer-adversarial-check`，成员恰为 H-2、H-6 和 H-12。H-7 的覆盖关系只针对本包的已选事实集合，不表示 H-7 对 Atlas 350 卡级研究没有价值。

## 事实和证据状态

41 条事实的 `fact_kind` 均为 `direct_statement`，共有 50 条逐来源断言；其中 42 条断言是 `direct_statement`，8 条是 `inferred`。事实证据状态仍为 22 条 `single_source`、13 条 `source_with_caveat`、6 条 `corroborated`，来源计数没有因断言模式变化而改变。每条事实至少有一条 `source_checked` 断言；同一来源的两个 H-6 入口不会增加来源计数。全部事实仍是 `provisional`，等待最终独立复核。

H-2 先直接说明 950PR 与 950DT 使用同一颗 Ascend 950 die，随后用共同 “Ascend 950 chips” 主语给出四条低精度算力、SIMD+SIMT、128 byte 粒度和 2 TB/s。七项取值是来源直接内容，但把它们只挂共享裸片是主体规范化推断，所以对应七条断言为 `inferred`、`assertion_relation=qualifies` 不变。四条吞吐仍挂在裸片精度路径，`operation_class=other`，`operation_type` 留空，`operation_count_rule=vendor_label`，以免把未说明的厂商标签误写成矩阵或向量峰值。共同芯片、950DT 路线图和 950PR 当前产品页的三个 2 TB/s 是不同条件记录，不能相加。950PR 的 1784 TFLOPS 采用同样保守的数值口径，但主体和条件仍是 950PR 当前产品页，不与裸片共同标签合并。

H-2 的通用段落写 `MXFP4`，950DT 段落另写 `XMFP4`。本包没有把 `XMFP4` 建成新的精度路径或冲突数值，也没有把它静默改成 `MXFP4`；原文差异保存在断言定位、事实备注和三张资料卡中。因为没有形成两个互斥的规范化事实，本包不新建 conflict group。

## 缺口检索

106 条字段要求中，41 条已有值，53 条是 `not_found`，11 条是 `not_applicable`，950DT 精确可用日期一条为 `pending_verification`。四个官方来源都没有明确宣称某项信息“不公开”，所以 `not_public` 使用数为 0。

每条 `not_found` 要求都有唯一的 `search_id` 和字段特定的 `query_or_path`。每条检索记录都挂四个结果，分别表示 H-2、H-6（同时检查 950DT 路由渲染）、H-7 和 H-12 是否提供对象匹配支持；总计 53 条日志和 212 条结果。日志没有把卡、系统或相邻封装值当作“找到”，也没有用第三方报道替代一手定值。

`pending_verification` 只用于 `REQ-M2W3-HUAWEI-ASC950DT-AVAILABILITY`。H-2 的 2026 年第四季度是未来窗口，结构化 requirement evidence 只支持继续等待核对，不支持 GA（通用可用）、正式上市或客户交付。

## 层级反查

对象归属复算为共享裸片 12 条、950PR 16 条、950DT 13 条。两种封装各自的 HBM 和互联没有写到共享裸片，共同算力和 SIMD/SIMT 没有复制到 PR/DT。H-7 没有任何事实断言。H-12 直接支持 950PR 名称、SKU 和 Atlas 350 部署关系；从 Atlas 350 上市归一化到 950PR package 的嵌入条件 `available` 状态为 `inferred`，deployment 断言保持 `direct_statement`。H-6 在 950DT 上只支持名称和 SKU；其 950PR 正文中的容量、带宽、算力和协议均未转移到 950DT。

本包没有新增 `object_relation_id` 事实、special capability 占位、topology 占位或派生指标。Atlas 350 卡级规格、SuperPoD 系统值、15 条旧 Da Vinci 实现待办和第三方填充值的迁移数均为 0。