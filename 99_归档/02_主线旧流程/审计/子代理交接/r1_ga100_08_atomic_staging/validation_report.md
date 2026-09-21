# GA100 staging overlay 验证报告

## 结论

本目录包含 23 个正式 CSV fragment、4 个审计辅助 CSV、`README.md`、`operations.csv` 和本报告，共 30 个交付文件。静态验证在 formal+staging 联合集合上执行，先应用 3 个 delete 和 48 个 update，再检查最终态。overlay 增量检查无 error；正式基线另有 9 个 source 已存在重复 screening 行，属于本任务未修改的历史问题，不能写成全库“一源一行”已经关闭。

PowerShell 缺失属于 tool/runtime failure，不是模型能力限制，也不是已经通过正式三道硬门。正式 endpoint 的 stable target 还没有执行复制；本地文件核验通过 `payload_copies.csv` 将 candidate target 回映到 staging source，不能据此声称 formal 路径已经落位。

## 机器校验结果

独立脚本返回 `RESULT PASS`、`ERROR_COUNT 0`。23 个 fragment 的表头与正式表逐列相同，全部非空记录行宽正确；staged PK 唯一，insert 不与正式 PK 冲突，每个 update/delete 都恰好命中一个正式 PK。formal+staging 的 nullable、enum、分号禁用与 FK 检查通过。

Facts 与 requirements 均只有一个合法 target。Fact 的 text/number XOR、field value kind、enum 与 canonical unit 通过；128 条 staged requirement 中，所有 `value_available` 都能在相同 target-field 找到 fact，`FIELD-ID-ARCH` 由 `implements_architecture` relation 关闭。Assertion raw-value XOR 通过，最终态没有同 subject-field-value-condition 重复。

10 个新增 source 各有一个 screening 和一个 preferred endpoint。正式基线已有 9 个 source ID 各出现两条 screening：`SRC-AWS-TRN2-S06`、`S07`、`S09`、`S10`、`S15`、`SRC-M2NA-AMD-CDNA4-ISA`、`SRC-M2NA-AMD-CDNA4-WP`、`SRC-M2NA-AMD-CDNA5-WP`、`SRC-M2W2-AMD-MI400-LANDING-20260813`。这批重复行不是 GA100 overlay 产生，operations 也没有越权修理。6 个 selection member 全部使用 source_id。ISSCC 已降为 lead_only；PTX 7.0 和 7.2 的 mandatory reason 明写同一家族版本不构成独立 corroboration。

formal+staging 共 102 个 local endpoint 全部可解析并匹配 SHA-256。19 个 stable target 还未复制，校验器依据 `payload_copies.csv` 回放 staging source；19 份 payload 的 hash 与 byte count 全部匹配。这个结果证明复制计划与 endpoint 绑定一致，不证明 stable target 已正式落位。

高风险语义检查通过：`FIELD-COMP-ISSUE-WIDTH=32` 与 `FIELD-COMP-THROUGHPUT=1024` 使用 number 列，normalized unit 留空，per processing block、per SM、per clock 和 FMA vendor label 均在 condition/notes；register file 262144 byte、combined L1/shared 196608 byte 及 RF instance count 4 均为 per-SM 条件。PCIe 4.0 x16 使用真实 link subject，NVLink 3 error detection/recovery 使用 `FIELD-INT-FAULT`。没有 die_count=1、historical_anchor fact、cycle-as-seconds、A100 1400/1600 GB/s、64 GB cliff 或 14 groups fact。54.2B transistor fact 保持 `source_with_caveat`，ISSCC 54B 仅为 `qualifies`。

修改过的旧 Ampere fact、requirement、assertion、condition、precision path 和 capability 均为 draft 或 needs_resolution，没有沿用旧 reviewed 状态。源和实体没有被 staging 静默提升生命周期。

只读恢复检查另行实跑通过：`formal_tables=32`、`endpoint_rows=153`、`local_paths=79`、`hashes_checked=79`、`selection_runs=11`、`selection_members=106`。这项 Python 检查读取的是未修改的正式根，证明 overlay 制作期间没有破坏正式恢复链；它不读取候选 fragments，也不替代 PowerShell gate。

| fragment | 行数 |
|---|---:|
| objects.csv | 1 |
| object-relations.csv | 1 |
| components.csv | 11 |
| links.csv | 1 |
| precision-paths.csv | 4 |
| special-capabilities.csv | 15 |
| memory-levels.csv | 3 |
| condition-sets.csv | 13 |
| facts.csv | 79 |
| field-requirements.csv | 128 |
| card-completeness.csv | 13 |
| source-families.csv | 8 |
| sources.csv | 10 |
| source-endpoints.csv | 28 |
| fact-assertions.csv | 98 |
| requirement-evidence.csv | 8 |
| search-log.csv | 33 |
| search-results.csv | 66 |
| source-screening.csv | 10 |
| source-selected-roles.csv | 6 |
| source-coverage.csv | 2 |
| selection-runs.csv | 1 |
| selection-members.csv | 6 |

`operations.csv` 有 567 行，含 insert 516、update 48、delete 3。insert 中有 19 条 payload copy，其余对应正式表 fragment。辅助表为 `payload_copies.csv` 19 行、`field_coverage_summary.csv` 141 行、`capability_coverage.csv` 14 行、`claim_dispositions.csv` 12 行。

## 141 字段和特殊机制

`field_coverage_summary.csv` 恰有 141 个唯一 field，与正式 fields 集合相等。disposition 为 value 44、conditional 24、not_found 35、not_applicable 13、pending 23、excluded 2。`FIELD-ID-STATUS`、`FIELD-ID-DATA-CUTOFF` 和 `FIELD-PHY-DIE-COUNT` 被强制复核为 pending，没有沿用 coverage map 中的行政 metadata 或 object-type 推导。

Field-level 汇总不能替代机制覆盖。`capability_coverage.csv` 分开列出 Attention data move、Softmax、reduction、Top-k、MoE route、MoE dispatch、collective offload、sparse skip、quantize、dequantize、transpose or permute、compression、KV cache management 和 media or OFA，共 14 组。Reduction、sparse skip、OFA 和 video decode 使用真实 capability；Compression 是 pending evidence target，其余缺失机制各有独立 not_found target 和 search record。

## 人工逆向复读

人工从候选记录逆向读回来源与对象边界。对象 label 与冻结名单一致，full-design 只在 notes/condition 出现；8 GPC、64 TPC、128 SM、8192 FP32、512 Tensor Core、12 controllers、per-SM 256 KiB RF、192 KiB combined L1/shared 和 1024 FMA/SM/clock 都能回到白皮书明确位置。A100 enabled count、HBM、clock、power 和 peak 没有混入。

数值路径复读确认 TF32 operand、FP32-to-TF32 conversion、FP32 output 和 FP32 programmer-visible accumulator 分开。其他路径没有从 accumulator 列反推 output。Sparse MMA 的 metadata 方向、datatype pattern 和 software target 没有压成一条普通 2:4。

特殊机制复读确认 Table 7 的 GA100 video-decode 格式可以进入，A100 5×NVDEC 与 1410 MHz throughput 留在 claim disposition；warp reduce 只覆盖指定 warp-level operations；CUDA Graph、MIG profiles、HPEC cycles 和 random-access observations 仍保留产品或 workload 条件。RAS 五条 fact 的主体均为 object，外部 HBM、driver、InfoROM、application termination 和 reset 没有从 condition 中丢失。

来源链复读确认 endpoint 不重复变成 source，manifest 不成为 member，ISSCC 没有因 die photo 或舍入 qualifier 强留 minimum set，PTX 两个版本没有被称为独立交叉证据。改写旧事实后的 lifecycle 回到 draft。逐段倒读 README 的合并顺序后，没有发现先插 endpoint 后复制 payload、先写 fact 后建实体，或把 Python recovery pass 写成正式三硬门通过的倒置。

## 失败分类与剩余风险

本轮没有 sandbox denial、approval failure、remote service error、user interruption 或 destructive action。一次复验在已经切入主线根后仍把主线目录前缀写进 validator 路径，导致 Python 报文件不存在，分类为 `operator mistake`；该命令没有写入，随后用正确相对路径重跑，静态 overlay validator 与 Python recovery check 均正常退出。两次 `git status` 只读检查因当前 workspace 没有 `.git` 元数据而退出，分类为 `tool/runtime failure` 的 non-Git workspace boundary，不是 sandbox denial；本轮写入路径由 apply-patch 记录和最终 30 文件清单核对，只出现在本 overlay 目录。

三道正式硬门未运行，原因是当前环境没有 `pwsh`、`powershell` 或 `powershell.exe`，分类为 `tool/runtime failure`。当前正式 `论文/` 仍是 113 份 PDF、315363681 bytes，而 `Test-SourcePool.ps1` 冻结预期是 111 份、313921821 bytes；即使切到 Windows，这个既有 baseline difference 也必须先由总控裁决。它不是 GA100 overlay 的 schema error，也不能被本任务越权修复。

剩余合并风险有三项：19 个 stable payload 尚未复制；正式基线 9 个 source 的重复 screening 未关闭；Windows 上的 SourcePool、ChipScope 和 ResearchData 三道 gate 未执行。只有完成 payload transaction、临时联合镜像复核、独立签字并在 Windows 正式根三门退出 0 后，才能把本报告的 staging PASS 升级为 formal PASS。
