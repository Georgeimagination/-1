# M2-GHC-ARCH 独立复核

首次复核日期：2026-08-12  
修复后再复核日期：2026-08-12  
复核对象：`审计/子代理交接/m2_staging/M2-GHC-ARCH/`  
复核角色：独立复核，未参与初稿或修复  
最终裁决：`accept`

## 裁决

首次复核给出的裁决是 `accept_with_fixes`，并设置了五项合并前门槛。修复后的工作包已经全部通过。当前未发现剩余阻断，可以进入总控顺序合并；`accept` 只表示该 staging 包达到合并条件，不表示已经写入正式库。

## 五项门槛

| 门槛 | 再复核结果 |
|---|---|
| 华为配置事实 | 通过。原来的 13 条典型或 Ascend-Max 配置事实已从架构 facts、assertions、`value_available` requirements 和卡片正式追溯中移出。两种向量宽度按来源拆开，容量保留原始 KB/MB，方向不明的带宽没有强填读、写或双向，FP32 destination 没有继续解释为 FP32 accumulation。相关线索与 Ascend-Max 1 GHz 一起形成 15 条实现对象待办。 |
| facts、枚举和 requirements | 通过。独立复算 35 条 facts：字段允许目标类型错误 0，事实值枚举错误 0，七目标异或（XOR）错误 0。按总控规则，field requirement 可以挂上层 object，也可以挂字段允许的具体目标；80 条 requirements 按此规则错误 0。35 条事实各有且仅有 1 条 assertion。 |
| 不可访问端点 | 通过。`END-GROQ-WHITEPAPER-2019-OFFICIAL` 为单一 URL 和 HTTP 404；`END-GROQ-TSP-ISCA2022-DOI` 为 HTTP 403；`END-GROQ-TSP-ISCA2022-GROQ-MIRROR` 为 HTTP 522。所有非空 `http_status` 都是整数，challenge 等访问现象只留在访问状态或 notes。 |
| 35 条 facts 的卡片闭环 | 通过。四张卡显式覆盖全部 35 条 staged facts，没有卡片漏项；17 个被移出的旧 fact ID 没有继续出现在正式追溯表中。每条卡片事实都能连到 assertion、source 和非空 locator。寒武纪卡另复用两条正式事实，并明确区分架构 owner 与芯片 owner。 |
| 46 条实现待办 | 通过。46 个 `backlog_id` 全部唯一；Groq 第一代 26 条、Groq 3 5 条、华为 15 条。空 `source_id`、复合 `source_id`、未知来源、空 locator 和 ISCA 2020 的宽泛 `pp.1-12` 均为 0。25×29 mm、三种功耗口径、PCIe Gen4×16、PCIe CEM 和 1 GHz 条件均已保留。 |

## 证据合同

`fact-assertions.csv` 的 35 条断言都包含非空 `raw_value_text` 和可复现 locator。数值格式事实直接保留 FP16、FP32、INT8、INT32 等原值；机制事实保留与规范事实等价的来源措辞。PDF 定位至少到页码并在需要时补章节，网页定位到小标题，达到当前正式项目合同的要求，也不弱于正式库已有的断言记录。

35 条 `quoted_context` 都使用同一句审核性占位文本，而不是逐条原文短上下文。该列在正式 schema 中可空，正式库现有断言也普遍为空，因此这不构成合并阻断。不过它没有发挥“短上下文”字段的用途。后续批次宜保存事实附近的短原文，至少不要继续批量写同一句占位语。

## 来源角色和最小性

来源角色与事实链一致。Groq 第一代保留 ISCA 2020 架构论文和 v1.7 产品简报：前者提供代际机制，后者提供不能由前者替代的 VXM 程序员可见格式与产品修订线索。NVIDIA Groq 3 保留架构博客和 C2C 专题博客，后者有互联时序与路由的独有信息。华为 Hot Chips 2019 与 HPCA 2021 分别承担初代组件/层级和共享机制/数值路径，不能互相替代。

`SRC-NVG3-LPX-PRODUCT-2026-08-12` 对本包选定事实集仍可由架构博客完全覆盖，`COV-NVG3-PRODUCT-BY-ARCHBLOG` 的范围限定清楚。Groq 2019 白皮书和 ISCA 2022 正文未取得，没有误标成 `redundant_covered`。媒体没有进入事实链。寒武纪的 MLUarch05、BANG 版本、`compute_50`、`mtp_592` 和 `__BANG_ARCH__=592` 继续保持不同语义层。

## 独立验证

| 验证 | 结果 |
|---|---|
| `validate-staging.ps1` | 通过。 |
| 独立语义检查 | 通过：facts 目标类型、事实枚举、requirements 总控规则、断言基数、卡片覆盖、端点状态类型和 backlog 原子性均为 0 项错误。 |
| 临时副本合并后运行正式 `Validate-ResearchData.ps1` | 通过：`PASS: 32-table research data model; 46867 checks executed.` 注册表为 323 列、488 个枚举值。32 个实际引用的本地 endpoint 文件已复制到临时库；临时目录在验证后删除。 |

正式目录未被修改。总控实际合并后仍应在真实工作目录重跑官方校验器，这属于正式入库验收，不是本包的剩余阻断。

## 非阻断改进

检索链的数量已经闭合，但部分 `search-log.csv` notes 仍概括了多个入口，而 `search-results.csv` 只保留一条汇总结果。当前 `not_found`、`inaccessible_evidence` 和 `pending_verification` 都有正式要求与检索记录，所以可以合并；后续工作包可按实际访问入口逐条保存结果。

华为三条方向未说明的带宽待办把 `field_id` 留空，这是有意避免误用 `READ_BW` 或 `BIDIR_BW`。待总控以后新增可表达厂商原始带宽标签的字段，或建立明确方向的实现证据后再落正式事实。

## 运行说明

本轮没有审批失败、沙箱拒绝、用户拒绝或远端工具错误。包校验、语义复算和临时合并均为新鲜实跑结果。报告只更新本文件，没有修改 staging、正式库、README、AGENTS 或其他根文档。