# GA100 原子事实 staging overlay v2 验证报告

## 结论

本轮 staging 级验证通过。独立 checker 在内存中重放“正式 32 表 + v2 fragments + 显式 delete/update/insert”，共执行 19296 项检查，结果为 0 error、1 个既有正式库 warning。24 个正式 fragment 共 999 行，1021 个 operation 与各行逐一对应；141 个 field 和 9×12 个 Tensor path 单元都能解析到真实 fact 或 requirement。

这个 PASS 不是正式合并许可。当前机器没有 PowerShell runtime，三道 Windows gate 未运行；19 个 payload 也只验证了 staging source 与 stable target 的复制计划，没有移动到正式来源池。正式资料池的 113/111 PDF 基线差异仍待总控裁决。

## 验证输入与重放方式

checker 读取正式 `数据/schema-columns.csv` 和 `数据/enums.csv`，以正式 32 表为 baseline，再按 `operations.csv` 在内存中执行 3 个 delete、76 个 update 和 942 个 insert。payload 文件不写入临时或正式来源池，而是把 candidate endpoint 的 stable local path 与 `payload_copies.csv` 中的 staging source、SHA-256 和 byte count 绑定。这样既能检查合并后的外键和证据链，也不会越过本任务的只写审计区边界。

验证规模如下：

| 项目 | 数量 |
|---|---:|
| 正式 schema 表 | 32 |
| 正式表 fragment | 24 |
| fragment 行 | 999 |
| facts / requirements / assertions | 89 / 272 / 109 |
| sources / endpoints | 10 / 28 |
| search log / search result | 132 / 250 |
| selection run / member | 1 / 7 |
| payload copy | 19 |
| field coverage | 141 |
| path-by-field closure | 108 |
| operations | 1021 |

所有 30 个 CSV 的行宽与各自表头一致。24 个正式 fragment 的表头与正式表逐列相同，fragment 内主键唯一；与正式主键相同的行只能通过 update 出现，不同主键只能通过 insert 出现，3 个旧错误记录均以 delete 明列。delete 的目标在正式表中存在，且没有同时出现在 fragment 中。未发现静默覆盖或孤立 operation。

## 32 表合同检查

formal+staging 联集的 PK、FK、required value、semicolon 约束和枚举均可解析。facts 与 requirements 都满足七目标列 XOR，主体类型符合 `fields.csv` 的 fact/requirement target contract。所有 `value_available` 或 `conflicting_unresolved` requirement 都有同 target、同 field 的 fact；`FIELD-ID-ARCH` 继续使用 `implements_architecture` relation 的合同特例。

fact 的 text/number XOR、invariant number 解析、`value_kind` 列位置和 canonical unit 检查通过。`FIELD-COMP-ISSUE-WIDTH=32` 与 `FIELD-COMP-THROUGHPUT=1024` 均写在 `normalized_value_number`，单位为空，per processing block、per SM、per clock 与 FMA 计数口径留在 condition/notes。`FIELD-MEM-CAPACITY` 使用 byte；`FIELD-MEM-LATENCY` 没有被 cycle 结果占用，正式单位仍为秒。

facts 的同 target、field、value、unit、condition 组合没有 overlay 新增重复。modified formal rows 均回到 `draft` 或 `needs_resolution`；没有让语义改写后的旧记录沿用 reviewed/approved 生命周期。

## 证据、来源与选源检查

正式 validator 使用的 distinct source 规则与本轮更严格的语义规则都已重算。后者只把 `supports` 或 `qualifies` 计入有效证据，并另查 source family；`contradicts` 与 `supersedes` 不用于抬高 evidence state。`FACT-R1-GA100-AMPERE-SW-MATURITY` 只有一条语义相符来源，状态为 `single_source`。`FACT-M2NA-AMPERE-SPARSE-LEVEL` 有 whitepaper 与 PTX 7.2 两条相符断言；PTX 7.0/7.2 的其他记录仍共享同一 family，不互算独立复核。

ISSCC screening 为 selected，roles 同时包含 `conflict_evidence` 和 `independent_validation`，并进入七源 draft selection run。selection member 逐行使用 source ID，没有把 endpoint 当成 source，也没有把同一内容版本的多个 endpoint 拆成来源。10 个 staged source 的 content fingerprint 唯一，新增 source 各有一条 source-level screening。七个 member 都有逐源 reverse-removal 理由。

联集仍有 9 个正式库既有 source_id 各出现两条 screening：`SRC-AWS-TRN2-S06`、`SRC-AWS-TRN2-S07`、`SRC-AWS-TRN2-S09`、`SRC-AWS-TRN2-S10`、`SRC-AWS-TRN2-S15`、`SRC-M2NA-AMD-CDNA4-WP`、`SRC-M2NA-AMD-CDNA4-ISA`、`SRC-M2NA-AMD-CDNA5-WP`、`SRC-M2W2-AMD-MI400-LANDING-20260813`。这是本次唯一 warning，与正式 baseline 相同；v2 没有新增第十个重复，也不把它误报为全库已关闭。

## requirement、检索与覆盖检查

272 条 staged requirement 中，118 条为 `not_found`、90 条为 `value_available`、49 条为 `pending_verification`、15 条为 `not_applicable`。每条 staged `not_found` 都有字段和目标明确的 search log，并至少有一条 explicit search-result；search 文本中列出的 source ID 与结果表逐项相等。早期 v1 中“查过固定整包”但只列两份结果的语义失配已消除，检索范围按实际 result 缩到相关的最小来源集合。`not_applicable` 每条都有结构性理由，没有用它替代“没找到”。

`field_coverage_summary.csv` 恰有 141 个唯一 field，与正式 `fields.csv` 集合完全相等。每行 `formal_record_ids` 非空，ID 均存在于 formal+staging fact/requirement 联集，且记录 field 与 summary field 相同；没有 `coverage_only`。disposition 为 value 38、conditional 7、pending 49、not_found 35、not_applicable 12。

`path_by_field_closure.csv` 恰有 108 个唯一单元，对应 9 条 Tensor path 和 12 个数值字段。每个 `formal_record_id` 都存在，且精确匹配该 precision path 与 field；新增 FP16→FP16 path 在矩阵中。没有用 field-global requirement 冒充 path-specific closure。

14 类特殊机制各有独立 capability target 以及对应 fact 或 requirement。Attention data move、Softmax/reduction、Top-k、MoE route/dispatch、collective offload、sparse skip、quant/dequant、transpose/permute、compression、KV Cache management 和 media/OFA 没有合并成一条笼统 limitation。

## 对象边界与高风险字段

所有 staged `FIELD-RAS-*` fact/requirement 的主体都是 object。NVLink link 范围使用 `FIELD-INT-FAULT`；GA100 RAS 的 DPO、row remap、containment、detection 和 recovery 条件继续保留 external HBM、driver、InfoROM、application termination、service/reset 流程，没有写成无条件的全芯片能力。

`LINK-R1-GA100-NVLINK-INTERFACE` 与 `TOPO-R1-GA100-NVLINK-GAP` 均能在联集中解析。logical/physical link count、lane count、per-link rate、injection/aggregate bandwidth 和 absolute latency 都有分别落位的 requirement。没有建立 full-GA100 link count fact，也没有把 ISSCC 50 Gbps LR-PHY 当作 logical-link rate。

staged normalized values 中没有 40/80 GB HBM、250/400 W、108 SM、1400/1600 GB/s、64 GB cliff 或 14 groups。没有 `FIELD-PHY-DIE-COUNT`、`FIELD-ID-STATUS` 或 `FIELD-ID-DATA-CUTOFF` 伪 fact。价格 requirement 是基于实际固定 PDF 文本检索的 `not_found`，economics 为 `missing_public_data`；process 为 `source_with_caveat`。

## 本地文件、hash 与恢复检查

28 个 staged endpoint 中有 23 个 local path：4 个继续指向现有 `论文/` PDF，19 个指向尚未复制的 stable snapshot target。现有 4 个文件逐个核对 SHA-256 和 notes 中的 byte count。19 个 future endpoint 逐个核对 staging source 存在、payload byte count、payload SHA-256、endpoint SHA-256、endpoint notes byte count、endpoint ID 与 operation target，一致后才视为候选联集可解析。计划合并后的本地 endpoint 总数为 baseline 79 加本轮 23，即 102；其中 19 个必须先执行 payload copy。

正式根的 `scripts/validation/verify_recovery_paths.py` 已单独实跑通过，输出为：`PASS: formal_tables=32; endpoint_rows=153; local_paths=79; hashes_checked=79; selection_runs=11; selection_members=106`。它只证明当前正式 baseline 可恢复，不代表 v2 已合并，也不替代 Windows gate。

## 未执行的硬门与既有 blocker

本机 `command -v pwsh` 和 `command -v powershell` 都没有结果，因此没有运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 或 `Validate-ResearchData.ps1`。分类为 tool/runtime failure，不是 sandbox denial、approval failure、remote service error，也不是已通过。正式资料池当前为 113 份 PDF，而冻结 baseline 仍是 111 份；总控必须先裁决这个既存差异，再在包含 19 个 stable payload 的完整临时根运行三道 gate。

当前 staging 仍需独立数据复核签字。`FIELD-ID-DATA-CUTOFF` 的行政元数据合同、通用 coverage gate 的正式结构，以及 GA100 Markdown 资料卡都留给总控后续事务；本目录没有擅自增加第 33 张表、coverage manifest 或 card-completeness 新列。

## 执行异常分类

执行期间没有 user interruption、sandbox denial、approval denial、approval-review connection failure、remote service error 或破坏性正式写入。出现的异常均已留在审计口径内：

| 现象 | 分类 | 影响与处置 |
|---|---|---|
| 协作 agent 启动返回 `agent thread limit reached` | tool/runtime failure | 未获得额外并行复核，主 agent 继续完成全部检查 |
| 两次只读统计使用了错误列名 | model/operator mistake | 查询报错后查正式表头重跑，没有写文件 |
| 一次 here-doc 未声明 UTF-8 编码 | model/operator mistake | 只读统计未运行；补 coding cookie 后重跑 |
| recovery 命令重复拼接主线路径 | model/operator mistake | 首次找不到脚本；改为正确工作目录后通过 |
| 初次 apply-patch 使用了相对主线的输出路径 | model/operator mistake | 30 个候选 CSV 短暂落到外层空审计目录；立即全部删除并清理空目录，正式目录与 v1 未受影响 |
| builder 中局部变量覆盖 helper 名称 | model/operator mistake | clean regeneration 在生成首个文件前中止；改名后重新生成 |
| 初版 union checker 报 28 个旧 search 链语义错误 | implementation defect caught by validation | 将相关 formal search/result 纳入 update，逐条改为 field/target/source 对齐；最终 0 error |
| PowerShell 可执行文件缺失 | tool/runtime failure | 三道 Windows gate 未运行，验收层级保持 staging |
| 最终 scoped `git status` 返回 not a git repository | tool/runtime failure | 当前可见主线根不是 Git worktree；改用输出目录清单、临时脚本清空和正式 recovery 实跑核对写入边界 |

## 最终复读状态

`report-humanizer final scan: PASS; no machine-detectable AI tells found`

README 与本报告分别完成单文件机器扫描。人工逆向复读：PASS。按执行异常、未执行硬门、本地文件、对象边界、requirement/coverage、证据来源、32 表合同、重放方式和结论逆序核对，再单独检查首尾段、表格数字、主体与限定词。19296 项检查、0 error、1 个 baseline warning、999 个 fragment 行、1021 个 operation、141 个 field、108 个 path cell、102 个计划联集 local endpoint、19 个 payload 和 113/111 基线差异前后一致；未把 staging PASS 写成正式验收。
