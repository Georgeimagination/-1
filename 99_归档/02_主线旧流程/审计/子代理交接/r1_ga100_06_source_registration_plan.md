# GA100 候选来源登记与最小集元数据计划

状态：完成，待总控复核；本文件是候选登记计划，不是正式来源写入。  
日期：2026-08-21  
对象：`OBJ-NVIDIA-GA100-DIE`，对象层级为 `die`。

## 本次结论

GA100 可以先以既有 Ampere 白皮书、ISSCC 2021 论文、MIG User Guide 610 快照和 June 2023 的 NVIDIA RAS Application Note 组成最小来源集的稳定骨架。白皮书不复制为新 `source_id`：它已经是 `SRC-M2NA-NVIDIA-AMPERE-WP-2020`，但必须在 GA100 对象范围下重新筛选、建立断言并重跑反向移除。ISSCC 论文补充固定的 A100 die 实现摘要；它与白皮书共同使用时，仍要把 A100 的 108-SM 启用配置与 full GA100 的 128-SM 设计分开。MIG 的 `Supported GPUs` 表把 A100 SXM4/PCIe 与 GA100、Compute Capability 8.0 直接对应；`Supported MIG Profiles` 的 Table 12 和 Table 13 则分别给出 A100 与 A30 产品条件。两页中的容量、profile 和最多七实例都不能改写为 full GA100 常量。

R595 的六份 HTML 快照与 June 2023 PDF 属于同一个 `NVIDIA GPU Memory Error Management` 家族。前者的多个章节只用于精确定位和当前的 GA100 支持矩阵，不能按页面数增加来源数。R595 中 `RAS Repair` 对 GA100 是排除证据，不能成为 GA100 的正向能力。执行期间出现的 CUDA C++ Programming Guide 11.0、PTX ISA 7.0/7.2 固定 PDF 能补软件和 ISA 绑定；PTX 7.0 与 7.2 是同一 revision series，不能作为独立确认。2022 微基准和 2024 random-access 论文各有独有实测价值，但只有相应的条件化事实进入最终集合时才保留。IEEE Micro 文章的压缩软件绑定细节目前仅作线索；92 页整期文件是同一篇 7 页文章的容器，不能再登记一个来源。

最终事实集合尚未冻结，因此下列 `selected` 都是候选状态，选择运行也只能是 `draft`、`provisional`。正式合并前不得把本文件中的建议状态改写为已审阅或已批准。

## 候选关系和去重口径

| 候选内容 | 拟用来源家族和内容版本 | 筛选结论 | 对最小集的作用 |
|---|---|---|---|
| 2020 NVIDIA 白皮书 | 已有 `SFAM-M2NA-NVIDIA-AMPERE-WP-2020` / `SRC-M2NA-NVIDIA-AMPERE-WP-2020` | `selected`，复用 | 直接支撑 GA100 命名、物理实现、full design 与 A100 enabled implementation 的边界；同一 PDF 的远程和本地端点不增加来源数。 |
| ISSCC 2021 | `SFAM-NVIDIA-A100-ISSCC-2021` / `SRC-NVIDIA-A100-ISSCC-2021` | `selected` | 固定的第一方同行评审实施摘要、die photo，以及 N7、面积、晶体管数的交叉定位；`54B` 仅是对白皮书 `54.2B` 的取整。 |
| IEEE Micro 2021 | `SFAM-NVIDIA-A100-IEEE-MICRO-2021` / `SRC-NVIDIA-A100-IEEE-MICRO-2021` | `lead_only` | 只在最终事实保留「CUDA API 标记可压缩 buffer、L2 内 pattern-gated compression」而又没有更强固定 CUDA 文档覆盖时升为 `selected`。它不是独立第三方确认。 |
| IEEE Micro 41(2) 整期 PDF | 不建新 family 或 source；作为上一行的 endpoint container | `redundant_covered` | 独立 7 页 PDF 与整期 PDF pp.31-37 已确认逐字节相同；容器只保留修复与页码上下文价值。 |
| 2022 HPEC / arXiv v1 | `SFAM-NVIDIA-AMPERE-MICROBENCH-2022` / `SRC-NVIDIA-AMPERE-MICROBENCH-ARXIV-V1-2022` | `selected`，条件化 | 仅支撑已接受的 PTX-to-SASS、WMMA Tile 或条件化 L1/L2/shared-memory cycles。HPEC publisher version 与本地 arXiv v1 尚未比对，不能冒充正式会议 PDF。 |
| 2024 random access | `SFAM-NVIDIA-A100-RANDOM-ACCESS-2024` / `SRC-NVIDIA-A100-RANDOM-ACCESS-ARXIV-V1-2024` | `selected`，条件化 | 仅支撑 A100 SXM4 80GB 上的约 64 GB random-read cliff、group-to-chunk 规避和作者推断的分离记录；不把 14 groups、64 GB TLB 或 80 GB HBM 写成 full GA100 常量。 |
| CUDA C++ Programming Guide 11.0 | `SFAM-NVIDIA-CUDA-C-PROGRAMMING-GUIDE` / `SRC-NVIDIA-CUDA-C-PROGRAMMING-GUIDE-11-0` | `selected`，条件化 | 只有最终事实保存 CUDA 11.0 的 experimental async copy、barrier、L2 access-policy 或 MIG-mode L2 set-aside 限制时才保留。 |
| PTX ISA 7.0/7.2 | `SFAM-NVIDIA-PTX-ISA` / 7.0 与 7.2 两个内容版本 | 7.2 `selected`，条件化；7.0 `lead_only` | 7.2 承担 `mma.sp` 的 sparse metadata、数据类型粒度和 `sm_80+` 限制；7.0 只在最终事实要明确首发版本或 SIMT/cp.async/mbarrier 语义时保留。 |
| MIG User Guide 610 | `SFAM-NVIDIA-MIG-USER-GUIDE` / `SRC-NVIDIA-MIG-USER-GUIDE-610` | `selected`，条件化 | `Supported GPUs` 为 GA100/A100 映射和 MIG 支持边界的一手快照；`Supported MIG Profiles` 的 Table 12（A100）和 Table 13（A30）可保留为产品条件；其余章节只补软件可见的实例隔离、pass-through 与部署条件。 |
| June 2023 RAS PDF | `SFAM-NVIDIA-GPU-MEMORY-ERROR-MGMT` / `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-DA-09826-002-V001` | `selected` | 固定文档号、月份和页数，承担 GA100 error containment、dynamic page offlining、row remapping 及其恢复边界的正向一手证据。 |
| R595 HTML 快照 | 同一 family 的 `SRC-NVIDIA-GPU-MEM-ERROR-MGMT-R595`，六个 `web_snapshot` endpoint | `selected`，仅限排除/版本边界 | 只有最终事实明确记录 GA100 不支持 `RAS Repair for GPU Memory` 时才作为 `conflict_evidence` 成员；它与 June 2023 PDF 是同一家族的两个版本，不是独立确认。 |

筛选是 source 级动作：正式 `source-screening.csv` 对每个 `source_id` 至多登记一条筛选结论。候选 CSV 的 `source_level_screening_status` 也只描述来源候选；endpoint 的产品条件、重复容器或排除用法由 `record_kind` 和 notes 表达，不能伪装成第二条 source screening。因而 `rejected_unreliable`、`out_of_scope` 和 `redundant_covered` 在本计划中分别是 HPEC Table III 的 claim、R595 Repair 的正向误用和 IEEE Micro full-issue container 的处置，而不是整篇 HPEC、R595 或 IEEE Micro article 的筛选状态。HPEC Table III 把与峰值量级相符的数写成 `GB/s`，当前没有足够依据替作者改为 TFLOPS/TOPS；R595 `GPU Memory Repair` 页面可确认 GA100 缺少该 Blackwell 能力，但不得推出 GA100 的 DRAM channel swap 或 L2 slice swap 正向事实。

本计划已将执行期间出现的 CUDA 和 MIG 固定文件纳入候选 CSV，并逐个复算 SHA-256、字节数及页数或 HTML title。尚未出现的 Ampere Tuning Guide、CUDA 11.2.1 Programming Guide 和任何其他 MIG 页面继续保持 `lead_only`；本任务没有下载它们。

## 建议的 provisional selection run

拟建运行是 `SELRUN-GA100-DIE-20260821-PROVISIONAL`，字段应为 `scope_kind=object`、`scope_id=OBJ-NVIDIA-GA100-DIE`、`cutoff_date=2026-08-21`、`algorithm_version=reverse-removal-v1`、`status=draft`、`review_status=draft`。`provisional` 只写入 notes，不替代受控的运行状态。

反向移除不应以“读过”或“来源较多”为理由。白皮书移除后，GA100 的直接命名、full 设计资源与 A100 启用资源的边界会缺失；ISSCC 移除后，固定的同行评审 die 实现摘要和 die photo 会缺失；June 2023 PDF 移除后，三项 GA100 memory-RAS 能力及其恢复过程没有直接的一手载体。R595 只有在最终事实明确保存 RAS Repair 的 GA100 排除边界时不可移除。两篇独立微基准也各有单独触发条件：HPEC 至少保留一项可接受的指令级或 memory-cycle 实测；random-access 至少保留一条直接观察到的 window/cliff/规避事实。IEEE Micro 只有在其 API-to-L2 compression 链没有被固定 CUDA 资料覆盖时才保留。

最终断言、条件集、对象关系或字段合同任一改变后，都应重新运行。尤其不能用现有 `SELRUN-M2NA-ARCH-20260812` 代替这个 GA100 对象范围的运行。

正式合并时，对每个新 `source_id` 生成同源的 `SCREEN-...` 与必要的 `SROLE-...` 行；来源自身的 screening 和 source-selected role 不能由 endpoint 行替代。候选 CSV 的 `source_level_screening_status` 和 `proposed_selected_role` 是这些行的输入。`SELMEM-...` 只为实际存活的 source 建立一行，不能把 R595 的多个章节、MIG 的多个页面或 PDF 的 DOI 再各建一名 member。

## 覆盖记录的候选写法

| 拟用 `coverage_id` | 覆盖关系 | `coverage_scope` / `equivalence_status` | 合并裁决 |
|---|---|---|---|
| `COV-GA100-IEEE-MICRO-FULL-ISSUE-BY-ARTICLE` | full issue container → IEEE Micro standalone article | `selected_fact_set` / `fully_covered` | 容器中的 pp.31-37 与 7 页文章逐字节相同，不产生第二个 source。 |
| `COV-GA100-IEEE-MICRO-BY-AMPERE-WP` | IEEE Micro article → existing Ampere whitepaper | `selected_fact_set` / `partially_covered` | 物理规格、MIG、NVLink 和 async-copy 已有更完整白皮书支持；API 到 L2 的 pattern-gated compression 链仍是潜在缺口。 |
| `COV-GA100-PTX-7-0-BY-PTX-7-2` | PTX 7.0 → PTX 7.2 | `selected_fact_set` / `partially_covered` | 现行语义由后版承接，但「首发于 7.0/CUDA 11.0」的时间断言不能由 7.2 替代。 |
| `COV-GA100-RAS-R595-BY-2023-PDF` | R595 → June 2023 PDF | `selected_fact_set` / `not_equivalent` | 两者同 family，不计独立确认；R595 的 GA100 RAS Repair 排除边界是较新版本的独有信息。 |

这些记录在 source、endpoint 和事实断言全部落位后才创建，当前不能标记为 `reviewed`。

## RAS staged 文件复核

所有 payload 文件仍位于 `审计/子代理交接/r1_ga100_source_staging/downloads/`，没有移动进 `论文/` 或任何正式来源目录。PDF 的标题为 *NVIDIA GPU Memory Error Management*、16 页、未加密、352,370 bytes。六份 HTML 都含预期的 `<title>` 和 `article`/目标 `section`，且未发现 `404`、`Access Denied`、`Not Found` 或 Cloudflare 错误页标记。集合指纹固定在 `审计/子代理交接/r1_ga100_source_staging/manifests/ras-r595-manifest.tsv`：它以相对路径、制表符和 payload SHA-256 的 C-locale 顺序逐行列出六个 HTML，文件自身 SHA-256 为 `40a8e5b6617b2f70c85947e1134d60f3766d705509f9344bc77d797767053d4c`。manifest 文件本身不是额外 endpoint 或 source；单页 hash 仍以 CSV endpoint 行为准。

| staged 文件 | bytes | SHA-256 | 页数或 HTML title | 内容判定 |
|---|---:|---|---|---|
| `nvidia-gpu-mem-error-mgmt-DA-09826-002_v001.pdf` | 352,370 | `5d484fe6ce3b577cfbdd378ebf6b3cf3eb18cedc0ec99ec557832bad424306d4` | 16 pp; *NVIDIA GPU Memory Error Management* | 可用的 June 2023 固定 PDF。 |
| `ras-r595-supported-gpus.html` | 16,575 | `4813fafec19b1508358bc0aedfcbd212e0f4695770a39fa0b3b75f1e8fc7c44f` | Supported GPUs, NVIDIA GPU Memory Error Management | 可用，含预期 `supported-gpus` section。 |
| `ras-r595-error-containment.html` | 16,326 | `d50618920ae48febbf894af8aa4455d6af541e794a8068996ca6d44980bbfbd5` | Error Containment, NVIDIA GPU Memory Error Management | 可用。 |
| `ras-r595-dynamic-page-offlining.html` | 16,144 | `39e16e20f234e40f666a4d79a8acc2bd28eae06a8fc577cbe523c06bcff2d4e3` | Dynamic Page Offlining, NVIDIA GPU Memory Error Management | 可用。 |
| `ras-r595-row-remapping.html` | 17,904 | `7473e17f6c97e8d9d616faf72efdf41cc142e47216a7d5278fa8651b93fbd7f6` | Row Remapping, NVIDIA GPU Memory Error Management | 可用。 |
| `ras-r595-contained-uce-response.html` | 17,041 | `cab5cfc6c98e76b24e5320cb0d323e7e103b97776a04e442ae8eeaf622bc9704` | Response to Uncorrectable Contained ECC Errors, NVIDIA GPU Memory Error Management | 可用。 |
| `ras-r595-gpu-memory-repair.html` | 17,169 | `9a44db8d6ab692c7fd1833e05cc42ee45a8012d75c3479a4d8917955cef03389` | RAS Repair, NVIDIA GPU Memory Error Management | 可用作 GA100 排除证据，不能生成正向 GA100 repair 事实。 |

## CUDA 与 MIG staged 文件复核

三个 CUDA PDF 的 PDF title、作者、页数和首页版本均可读，没有加密或错误页。MIG bundle 的 `versions1.json` 指明文档版本为 `610` 且为 `preferred`；其中八份 HTML 都带预期标题与正文 `article`，没有发现错误页标记。集合指纹固定在 `审计/子代理交接/r1_ga100_source_staging/manifests/mig-user-guide-610-manifest.tsv`：它以含 `mig-user-guide-610/` 前缀的相对路径、制表符和 payload SHA-256 的 C-locale 顺序列出八份 HTML 与 `versions1.json`，文件自身 SHA-256 为 `db5c3ac2017d7e40d4f4fa9e82e484166e3a7ee64f1ddd904a7c6b4b696fc91b`。manifest 文件本身不是额外 endpoint 或 source。MIG 的 Supported GPUs 表直接列出 A100-SXM4 40/80GB、A100-PCIe 40/80GB 和 A30 的 `Microarchitecture=GA100`、`Compute Capability=8.0`；Supported MIG Profiles 的 Table 12 是 A100、Table 13 是 A30。它们都是产品实现或产品 profile 条件，不能把容量、7-way/profile 或七实例上限下放为 full GA100 裸片数值。

| staged 文件或快照集合 | bytes | SHA-256 或 manifest | 版本/标题 | 使用边界 |
|---|---:|---|---|---|
| `cuda-c-programming-guide-11.0.pdf` | 4,252,150 | `af4235e08e4ebb0f7651896db7ed05344f5e4ae6e9ce5da3cba3bc5ec6c69174` | *CUDA C++ Programming Guide*; `PG-02829-001_v11.0`; August 2020; 405 pp | CUDA 11.0 API、experimental、L2 policy 与 MIG 条件。 |
| `ptx-isa-7.0.pdf` | 4,107,461 | `a79f4e074eb8f03314025c690ec51fbb79231e35bde612a60d50f4f8ec31f924` | *Parallel Thread Execution ISA*; v7.0; August 2020; 414 pp | SIMT、`cp.async`、`mbarrier` 和 `sm_80` 的发布期语义。 |
| `ptx-isa-7.2.pdf` | 3,931,305 | `9a89c6817d1fd0d3b6357aaf71fbf3c29d08d9c4e12b5eaa6c851297b7d18b97` | *Parallel Thread Execution ISA*; v7.2; February 2021; 433 pp | `mma.sp`、metadata、datatype-specific sparse constraints；同家族，不作独立确认。 |
| `mig-user-guide-610/` | 270,937 | manifest file SHA-256 `db5c3ac2017d7e40d4f4fa9e82e484166e3a7ee64f1ddd904a7c6b4b696fc91b` | version 610; eight HTML pages plus `versions1.json` | 只把 GA100/A100 identity、明示的 MIG 软件可见行为及 A100/A30 profile 产品条件建为候选；不把 Table 12/13 的容量、7-way/profile 或实例上限下放为 full GA100。 |

## 合并前需要固定的入口

候选 CSV 已给出 ISSCC、IEEE Micro、arXiv 和 NVIDIA RAS 的正式 endpoint 关系。正式合并时，ISSCC DOI 与 IEEE DOI 只能作为 publisher landing endpoint；它们没有替代本地 PDF 的内容 hash。June 2023 RAS PDF 的远程 URL也必须以本地已核 SHA-256 复验，因为无版本文件名的发布地址将来可能更新。R595 六页应继续作为一个内容版本下的 endpoint 集合，不应拆成六个 source 或六名 selection member。

待补入口是 Ampere Tuning Guide、CUDA 11.2.1 Programming Guide 和其他未保存的 MIG 页面。它们必须先取得完整、固定的本地文件或 HTML 快照；在此之前，它们不能补写 GA100 身份、软件或 virtualization 事实。

## 写入边界与复核

本次只创建本计划和同目录的候选 CSV。没有修改 `最小参考资料库/`、`数据/`、`资料卡/`、`进度/`、`论文/` 或清单。候选 ID 均已与当前正式来源表的同名前缀检索核对，未发现冲突；现有白皮书沿用正式 ID，避免重复来源。

已按 `report-humanizer` 进行机器扫描，并人工逆向复读标题、首段、表格引导、状态区分、转场和结尾。复读时保留了 `selected` 的 provisional 条件、同源非独立性和对象边界，没有把这些限定润色掉。候选 CSV 当前有 33 条数据行和 29 列：`new_source_and_endpoint` 10 条、`new_endpoint_only` 16 条、其余 record kind 各见 CSV。按真正承载 source 的 12 条候选记录计，`selected` 为 9、`lead_only` 为 3；重复 endpoint 只是带回 parent 的 source-level 状态，不能据此新增 SCREEN 行。MIG 为 9 个 endpoint，恰覆盖固定 manifest 的八份 HTML 与 `versions1.json`。扫描结果及 CSV 结构检查见本任务的最终验证记录。
