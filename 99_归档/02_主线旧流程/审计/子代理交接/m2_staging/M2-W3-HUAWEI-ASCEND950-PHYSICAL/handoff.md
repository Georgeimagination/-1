# M2-W3 Ascend 950 物理对象子代理交接

> 交接状态：`ready_for_final_independent_review`  
> 资料截止日：2026-08-13  
> 作者：`m2_w3_huawei_asc950_physical`

## 任务和输入

HBM（High Bandwidth Memory）是高带宽内存，MoE（Mixture of Experts）是专家混合模型，Top-k 指选取最高的 k 项，Attention 是注意力计算，KV Cache 是键值缓存。

本任务以正式对象 `OBJ-HUAWEI-ASCEND-950-DIE`、`OBJ-HUAWEI-ASCEND-950PR`、`OBJ-HUAWEI-ASCEND-950DT` 及两条既有 `package_contains_die` 关系为边界，读取了项目规则、研究计划、字段字典、资料卡模板、第二波队列审计、华为架构卡、旧 Da Vinci 待办和既有来源审计。H-2、H-6、H-7、H-12 四个官方来源版本及 H-6 的 950DT 路由入口已经固定；没有采用第三方资料。

## 已完成事项

三张资料卡位于 `card-draft/`。24 份同表头结构化增量位于 `structured/`，包含 41 条事实、50 条断言、106 条字段要求和 27 条九域完整度记录。来源筛选、逐来源角色、覆盖关系、最小集 selection run、成员不可替代理由、53 条字段特定检索日志、212 条检索结果和一条 950DT 路线图 pending evidence 均已填写。

对象分层已经固定。共享裸片承担 12 条事实；950PR 承担 16 条封装和当前产品页事实；950DT 承担 13 条封装路线图事实。H-2 共同规格中有七项值直接来自复数 “Ascend 950 chips” 陈述，把它们挂到共享裸片是依据前一句同 die 陈述完成的主体归一化推断。`ASSERT-M2W3-HUAWEI-PR-STATUS-H12` 也改为 `inferred`，因为 H-12 直接上市的主体是搭载 950PR 的 Atlas 350；`ASSERT-M2W3-HUAWEI-PR-DEPLOY-H12` 仍是直接搭载证据。八条之外的断言模式不变。Atlas 350 卡值、SuperPoD 系统值、旧 Da Vinci 实现事实和第三方填充值的迁移数均为 0。包内没有新增对象关系、special capability 占位、topology 占位或派生指标。

最小来源集保留 H-2、H-6 和 H-12。H-7 在本包已选事实集合中由 H-12 覆盖，筛为 `redundant_covered`；其固定快照仍用于证明卡级边界。H-6 的 950DT 路由快照保留“路由为 950DT、服务器正文仍为 950PR”的限制，不承担 950DT 规格或上市状态。

## 已验证事项

包级验证通过 1,087 项检查，其中新增固定门锁定恰好八条 `inferred`。把暂存增量叠加到正式库只读副本后，正式验证器通过 115,461 项检查；临时副本已删除。正式库自身通过 106,160 项检查，32 份正式 CSV 与 AWS 合并后的刷新基线逐文件哈希和字节数一致，变化数为 0。详细结果和修复记录见 `validation/validation-report.md` 与 `remediation-log.md`。

所有中文 Markdown 已按项目要求进入 `report-humanizer` 机器扫描和 `shuorenhua` 人工复核流程；最终扫描结果和文件哈希记录在本包验证目录。Markdown 公式只使用 `$...$`，没有使用反斜杠圆括号或方括号形式的公式分隔符。临时合并根目录和其他临时文件均已清理。

## 仍待核实的内容

950DT 的正式可用、通用供货和客户交付仍未出现对象匹配的一手证据，状态必须保持 `announced`，精确可用日期保持 `pending_verification`。950PR 的 `available` 是从 2026-03-20 Atlas 350 上市归一化得到的嵌入条件状态，相关断言为 `inferred`；它不是 H-12 对独立封装供货的直接陈述。独立封装可用日期、独立零售和客户交付仍是缺口，deployment 搭载证据保持直接。

两种封装的制程、裸片面积和晶体管数不在封装层重复，使用既有包含关系读取共享裸片；共享裸片本身也没有一手定值。封装内裸片数、HBM 堆叠数、接口宽度、中介层或基板、封装功耗、内存延迟和读写模型仍是 `not_found`。计算标签的矩阵或向量归属、稠密或稀疏口径、运算计数、频率和功耗条件没有披露；累加精度、专用 MoE/Top-k/Attention/KV Cache 模块、拓扑、单链路速率、编译器和运行时版本也没有对象匹配定值。

H-2 的通用段落为 `MXFP4`，950DT 段落为 `XMFP4`。本包保留文本差异，但没有把后者建立成新精度路径或冲突数值。独立复核者应确认这种处理，不要静默纠正原文，也不要在没有第二个规范化定值时新建形式化冲突组。

## 独立复核建议

最终独立复核者应先运行 `validation/Validate-Package.ps1`，确认固定门只允许七条 H-2 共同规格和 `ASSERT-M2W3-HUAWEI-PR-STATUS-H12` 为 `inferred`，并确认 H-12 deployment 与其余断言仍为 `direct_statement`。随后阅读三张卡及 `source-and-fact-audit.md`，核对七条共同规格的事实值、`fact_kind`、`evidence_state` 与来源数未变，950PR 1784 TFLOPS 的条件仍未决，PR 的 `available` 仍限于嵌入商用，DT 仍是 `announced`，H-6 950DT 渲染错位与 H-7 零事实断言也都保留。若最终裁决为接受，应由总控另行生成正式合并事务和生命周期清单；本包不自行改写正式表或签署验收。

## 写入文件

完整文件及 SHA-256 见 `manifest.csv`。主要新增或更新内容包括三张 `card-draft/*.md`、24 份 `structured/*.csv`、`source-and-fact-audit.md`、本交接文件、`fact-candidate-freeze.md`、完整 README、`remediation-log.md`，以及 `validation/` 下的包级验证器、可复现生成脚本、临时合并脚本、验证结果、基线与静态性证据。`fixed-candidates/` 的五份官方快照和身份门文件沿用来源预检阶段产物。