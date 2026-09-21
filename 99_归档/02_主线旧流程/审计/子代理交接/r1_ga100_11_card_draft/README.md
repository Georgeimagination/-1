# r1_ga100_11_card_draft 交接说明

## 任务状态

本目录提供一份只读 staging 生成的 GA100 资料卡候选，状态为 `draft / provisional`。它没有写入正式 `资料卡/`、32 张正式 CSV、`最小参考资料库/` 或任何进度文件，也没有更改已有原子事实、断言、字段要求、覆盖裁决和 claim disposition。

交付文件是 `NVIDIA_GA100_die_资料卡_候选.md`。资料卡按模板 0.3 的 15 个章节组织，但主语固定为 `OBJ-NVIDIA-GA100-DIE` 的 full GA100 physical die design；A100 enabled implementation、产品 SKU、模组、卡、HBM 配置、MIG profile、系统和第三方测量均没有下放。

## 已读取的输入

本轮先读取项目根与主线 `AGENTS.md`，再读取冻结名单中的 `NVIDIA GA100 die` 行、`资料卡/模板.md`、`资料卡/字段字典.md`、GA100 03 至 09 阅读/边界/原子化/语义红队报告，以及 `r1_ga100_08_atomic_staging/` 下全部平铺 CSV fragments、coverage、claim dispositions、README 与 validation report。卡内事实只来自 staging 中有 accepted/value 处置并能回到 `facts.csv` 与 `fact-assertions.csv` 的记录；`field_coverage_summary.csv` 只用于确定缺失或条件状态，没有被当作事实来源。

主要证据链包括：

| 证据职责 | source_id | 用法 |
|---|---|---|
| full GA100 核心规格与多数公共架构机制 | `SRC-M2NA-NVIDIA-AMPERE-WP-2020` | direct die facts 或 Ampere architecture facts 的逐条 source assertion |
| GA100 memory-error management | `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001` | DPO、row remapping、containment 与 driver/HBM/reset process chain |
| public CUDA/PTX contract | `SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0`、`SRC-NVIDIA-PTX-ISA-7-0`、`SRC-NVIDIA-PTX-ISA-7-2` | 只通过 architecture relation 投影 software/ISA mechanism |
| 身份边界 | `SRC-NVIDIA-MIG-USER-GUIDE-610` | 只限定 A100-SXM4/PCIe 到 GA100 的 mapping，不导入 MIG product facts |

## 对象模型与写法

`OBJ-NVIDIA-GA100-DIE` 只承载 full-die direct facts。Ampere architecture facts 仍属于 `OBJ-NVIDIA-AMPERE-ARCH`、其 component、precision path、capability 或 link，并明确经 `OREL-NVIDIA-GA100-IMPLEMENTS-AMPERE` 投影。资料卡没有为 architecture capability 在 die 上复制同义事实。

数值的处理遵循原子 staging：826 mm²、54.2B、8 GPC、64 TPC、128 SM、8192 FP32 CUDA Cores、512 third-generation Tensor Cores、12 个 512-bit memory controllers、per-SM 256 KiB register file、per-SM 192 KiB combined L1/shared、每 processing block 32-wide issue 与 1024 FP16 FMA per SM per clock 都保留原作用域和 count rule。没有把 controller 数乘成 6144-bit HBM interface，没有把 FMA 乘二或乘 128 生成 peak，也没有把 A100 enabled count、HBM/L2、clock、power、MIG 或 NVLink aggregate 值写成 GA100 die 属性。

## 已完成与核验

本轮完成了模板化候选卡、对象边界复核、critical value 的 source_id/locator 回链、architecture projection 标注、缺失状态整理、claim exclusions 摘要和 provisional source table。两个 Markdown 文件分别运行了 `report-humanizer` 机器扫描。首轮发现的中文破折号、一个对称否定句和 README 中的连接号均已修正，修改后的两份文件都返回 `No machine-detectable AI tells found`。

人工逆向复读从结尾、完整度、来源、冲突、机制表逐节回到对象定义，并单独复读 README。复读中发现并修正了合并写法造成的伪 `fact_id`、一个不存在的 assertion id、若干关键值只写“同源同定位”而没有重复 source_id 的问题，以及一处缺少空格。最终只读核对确认，卡内 73 个 fact_id、23 个 requirement_id、9 个 source_id 和 1 个 assertion_id 都能在正式表与 staging 的并集中找到；两份 Markdown 的表格列数一致。剩余风险来自尚未执行的正式事务和下节 blocker，不来自本轮机器扫描。

本轮只对文件内容和 staging 语义做审计区检查。`r1_ga100_08_atomic_staging/validation_report.md` 的静态 overlay validation 报告 PASS，但这不是正式数据校验通过。

## 未完成、未验证与明确排除

19 个 stable payload 仍只登记在 `payload_copies.csv`，尚未复制到 `最小参考资料库/快照/NVIDIA/GA100/`。`SELRUN-GA100-DIE-20260821-PROVISIONAL` 仍是 `reverse-removal-v1-staging` 的 draft run；payload copy、formal merge、assertion review 或事实/来源变化后必须重跑，不能把当前六个成员称为最终最小来源集。

Windows hard gates 尚未运行，包括 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 和 `Validate-ResearchData.ps1`。staging 报告还记录了正式 source pool 基线为 expected 111、existing 113，差额来自与 GA100 无关的 AMD brochures；本候选没有处理该基线偏差。上述状态是外部事务未执行，不是本卡内容校验的通过证明。

明确排除项包括 A100 enabled implementation 的资源数、HBM/L2、时钟、功耗、峰值、MIG profile、媒体引擎数量、NVLink device aggregate，以及条件不完整的 A100 microbenchmark/random-access 结果。ISSCC 的 `CUDA 8.0` 保持 conflicting/rejected value，HPEC Table III 的 `GB/s` claim 保持 rejected；本轮没有替来源纠错。

## 给总控的 blocker

第一，模板 0.3 的“对象层级（资料卡阅读层）”枚举只有 `architecture / silicon_package / product_sku / system`，没有冻结对象实际需要的 `die`。候选卡暂写 full GA100 bare die design，但正式卡需要总控决定扩展模板枚举，或明确 die 在阅读层的规范映射；不能把它伪装成 silicon package。

第二，模板把“HBM 堆叠和接口”放在同一行，而字段字典与 staging 将 stack applicability 和 interface width 分开：对 bare die，HBM stack 为 `not_applicable`，总 interface width 则为 `pending_verification`。候选卡已经拆行；正式模板是否同步拆分需要总控裁决。

第三，`FIELD-ID-STATUS=historical_anchor` 与 `FIELD-ID-DATA-CUTOFF=2026-08-21` 在工作包中仍为 `pending_contract_gap`。它们是项目范围/管理元数据，当前没有合规的 vendor fact evidence chain。候选卡保留状态而未造事实，正式落位方式需要总控决定。

除以上模板/契约问题外，本轮没有发现需要擅自改动 atomic staging 裁决的矛盾。GA100 link count、die count、HBM interface total、cycle metric schema、上层 A100 object 是否建立，以及最终 reverse-removal scope 继续保留给总控。

## 建议后续动作

总控若接受本候选，应先处理三个 blocker，并完成 19 个 payload 的受控复制与 hash 验证；随后审查并合并 atomic overlay，重跑 selection，再在 Windows 执行三项 hard gates。只有这些步骤全部通过，才能将候选内容转写到正式 `资料卡/`。本目录本身不授权任何正式写入。
