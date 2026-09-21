# M2-NA-ARCH 修复日志

> 状态：`ready_for_independent_rereview`  
> 开始日期：2026-08-12  
> 写入边界：只修改本 staging 工作包；不修改正式库、正式资料卡、根目录 README、AGENTS、研究计划或进度文件。

## 修复基线

本轮以独立复核 `审计/子代理交接/m2_review_na_arch.md` 的 `accept_with_fixes` 裁决为输入。开始时工作包有 11 张卡、23 个结构化片段、190 条事实、190 条断言、372 条字段要求；卡片与 README 最近一次已有修改发生在 2026-08-12 21:59 至 22:01，本日志建立在该既有状态之后，不把此前写入冒充为本轮修复。

复核提出四组阻断：断言缺逐条原文摘录且 raw 值混入研究者综合句；CDNA 4 FP16 矩阵吞吐取错列并连带派生值错误；Blackwell 解压占位和 Rubin NV-HBI 仍混用架构层与实现层；Blackwell Ultra、Rubin、CDNA 6 三份动态来源未固定。另需重跑最小来源选择、复核固定资料哈希与页数、检查卡片反向追溯，并在临时正式副本上运行官方校验器。

## 已执行

- 完整读取独立复核报告和工作包 README。
- 读取 `report-humanizer`、`shuorenhua` 与 PDF 处理规范；中文文档将先做事实保真审校，再依次执行两项自然化检查。
- 盘点工作包文件时间戳，确认本轮接手前已有修改；尚未修改结构化数据。


## 机械修复节点（2026-08-12）

不依赖网络的三组阻断项已经写入：

- `FACT-M2NA-CDNA4-MFP16-THR` 已按 AMD CDNA 4 白皮书 PDF 第 8 页 Table 1 的 MI355X 列从 2048 改为 4096 FLOP/cycle/CU；矩阵/向量比由 8 改为 16。
- 删除不符合 `FIELD-DER-COMPUTE-BW-SPEC` 铭牌带宽定义的 LDS 派生事实、派生指标、两条输入、条件和字段要求；`derived-metrics.csv` 现保留 1 条矩阵/向量派生指标，`derived-inputs.csv` 正确保留该指标的 2 条输入。
- 删除 Blackwell 解压占位组件、能力和专用条件；相关候选仍只在 implementation backlog。
- 删除 Rubin NV-HBI 的架构 link、fact、assertion 和两条要求；新增 `BACKLOG-M2NA-009`，把该链路作为双裸片实现候选保存。
- 同步修改 CDNA 4 与 Rubin 卡片、条件、事实证据映射。当前 facts 与 assertions 均为 187 条，components 64 条，special capabilities 37 条，links 11 条，condition sets 28 条，field requirements 369 条，derived metrics 1 条，derived inputs 2 条，implementation backlog 9 条。

本节点的机械复查未再发现上述已删除 ID 的结构化引用；卡片中的对应引用也已移除。最终还需在全包断言修复后重做一次全外键和卡片反向追溯检查。

## 证据与动态来源节点（2026-08-12）

逐来源证据修复已完成 Ampere 21 条、Ada 12 条、Blackwell 架构简报 11 条、Blackwell Hot Chips 3 条、Blackwell Ultra 网页快照 4 条，以及 CDNA 4 的两条已修正数值断言。逐条回源后，Rubin 观察文章没有陈述 CUDA 或其他编程模型映射，因此删除 FACT-M2NA-RUBIN-SW 及其 assertion，把 REQ-M2NA-AVAIL-0073 改为 not_found，并新增 SEARCH-M2NA-0127 与 SRESULT-M2NA-0248。Rubin 剩余 10 条断言已全部补齐。当前 facts 与 assertions 均为 186 条，其中 122 条已有逐条短上下文，64 条仍待处理；没有用统一占位文本。AMD CDNA 2、CDNA 3、CDNA 4 和 CDNA 5 ISA 共 25 条，以及 CDNA 2、CDNA 3 白皮书共 34 条也已完成。Ada 白皮书不能直接支撑编程模型字段，因此删除 `FACT-M2NA-ADA-SW` 及其 assertion，把原字段要求改为 `not_found`，并新增 `SEARCH-M2NA-0126` 与 `SRESULT-M2NA-0247` 保存检索链。删除 Rubin 软件映射事实后，当前 facts 与 assertions 同为 186 条。

四份选入来源均已保存原始 HTML 快照：Blackwell Ultra（273,475 bytes，SHA-256 `1ff2d6a189da948c69e2b578386814b6009c3f688b64d0a41acd7b277161cc3d`）、Rubin（344,864 bytes，`6e31747831a9e985becfd3f395414bbf69c1fde9da4a8182b1abda5b20ed9c83`）、AMD CES 2026 / CDNA 6（120,072 bytes，`c2d36db9db2f7d269dc4db51ba4125e4556dd666270c010ac715eed0d9e6009f`）和 AMD CDNA landing（238,514 bytes，`894598db3beaab36631f476b3a618b53169f0ac59cdb0b6d5d494a4153ed0f71`）。`sources.csv` 已改为 `current` 并登记内容哈希；`source-endpoints.csv` 新增 4 个优选 `web_snapshot` endpoint，远程 endpoint 保留为非优选入口。

首次在默认沙箱中下载网页返回“无法连接到远程服务器”，属于受限网络环境下的连接失败；按规则申请并获得提升权限后，四次下载均成功。随后尝试固定四份 AMD ISA PDF 时，自动审批复核因使用额度耗尽而拒绝，属于自动审批失败，不是用户拒绝、沙箱拒绝或远程服务错误；因此本包没有伪造本地副本，ISA 证据继续从 AMD 官方 PDF 入口逐条核对。工作区依赖探测连续无返回后主动终止，属于工具运行时无响应；PDF 抽取改用已知的 bundled Python 与 Poppler 路径，未降低证据核对范围。
## CDNA 4 证据合同节点（2026-08-12）

CDNA 4 白皮书组已逐条回到 PDF 第 6 至 17 页，完成 32 条断言的 `raw_value_text`、短 `quoted_context` 和定位修复，并同步修正六条事实：矩阵执行不再把来源未说明的 sparse 形式写成 structured；MX 缩放粒度保留“通常为 32”的限定；FP8 改为来源明确列出的 E5M2/E4M3；Infinity Fabric 只记录 XCD 到 IOD 共享内存资源的包内作用；软件事实删除白皮书未出现的 HIP，仅保留 ROCm 生态及其框架、训练、服务和内核支持。

另删除 `FACT-M2NA-CDNA4-L2-BANKS` 及 `ASSERT-M2NA-0144`。白皮书第 9 页给出的是 16 个并行 L2 channel 和 16-way set associativity，不能据此填写 `FIELD-MEM-BANKS`。`REQ-M2NA-AVAIL-0144` 已转为 `not_found / needs_resolution`，并新增 `SEARCH-M2NA-0128`、`SRESULT-M2NA-0249` 保存检索结果。当前 facts 与 assertions 均为 185 条；166 条已有逐条短上下文，只剩 CDNA 5 白皮书组 19 条。
## 完成节点（2026-08-12）

最后 19 条 CDNA 5 白皮书断言已逐条补齐。软件事实删除来源未出现的 HIP；FP4 缩放粒度保留“共享 scale factor 的 block 可为 16 或 32 个元素”；LDS、向量缓存、常量缓存、指令缓存的原始 KB 值与换算说明均已保存；TDM 只保留五维、描述符、异步、bounds check、multicast 和直接 LDS/DRAM 传输等正面机制。至此 185 条断言都有来源 raw 值、短 `quoted_context` 和精确定位，没有统一占位文本。

卡片已按 facts 与 assertions 重建事实表行。185 个 fact_id 在 11 张卡中各出现一次，卡片漏项、已删除 ID 残留和事实值不一致均为 0。`notes/fact-evidence-map.csv` 也按 185 条最终断言重建。Ada、Ampere、Blackwell、Blackwell Ultra、Rubin、CDNA 3、CDNA 4、CDNA 5 的陈旧软件、稀疏、TMA、softmax 和 Infinity Fabric 表述均已同步。

反向移除草案已针对修复后的 185 条事实重跑：17 个最小集成员各自至少独占一条当前事实。四份动态 HTML 快照与 10 个本地 PDF endpoint 再次复算 SHA-256，缺失和哈希不匹配均为 0。

临时合并正式 32 表后，官方校验器通过 75,746 项检查，退出码 0。额外检查的字段目标类型、断言基数、证据合同、卡片追溯、要求状态与派生值复算均无错误。验证中发现并修正 29 条数值断言 raw XOR 错误，以及一条 Rubin NV-HBI 已删除要求的孤儿 requirement evidence；两项都属于 staging 装配错误。

本包最终计数为：64 个组件、23 个 memory level、50 条精度路径、37 项特殊能力、11 条互联、28 组条件、185 条事实、185 条断言、369 条字段要求、128 条检索记录、249 条检索结果、1 项派生指标和 2 条派生输入。包内 `.ps1` 和图片为 0。临时合并副本在完成中文文档扫描后删除。

## 独立复核后修正节点（2026-08-13）

独立语义复核的三项遗留问题已经修正：`FACT-M2NA-CDNA5-IF-PROTOCOL` 补入来源中明确的 coherent 语句和行号；Ampere、Ada 两条 SM 执行事实改用能覆盖复合事实的图示标签或原文短摘录；13 个仅承担结构关系或精度路径归属的组件补充职责说明，并写入对应卡片。没有因此新增架构事实或规格值。

修正后计数不变：64 个组件、185 条事实、185 条断言和 369 条字段要求。语义检查再次确认每条事实恰有一条断言、每个 fact_id 在卡片中恰出现一次、卡片事实值和定位与结构化表一致；13 个组件均有结构化职责并出现在相应卡片。14 个本地 endpoint 的 SHA-256 全部复核一致，17 个最小来源成员覆盖全部 185 条断言。

重新建立临时正式副本后，第一次校验因只链接本包 14 个本地 endpoint，漏了正式库已有的 11 个本地 endpoint，校验器报告 11 个文件缺失。该问题属于临时副本装配错误，不是数据错误、沙箱拒绝或审批失败。补齐正式库的 11 个只读硬链接后，官方校验器通过 75,746 项检查，退出码 0；临时副本随后删除。

修复过程中的额外语义检查命令出现过两次 PowerShell 解析错误：一次是字符串中变量后紧跟冒号，另一次是把 `foreach` 语句结果直接接到管道。两次都属于命令构造失误；分别修正变量边界、先保存集合结果后，检查均通过，没有写坏文件。

本节点需要交由未参与修改的语义审查代理复核；只有其给出最终 `accept` 才能进入总控合并。修复代理尝试触发复核时，协作工具因四个并发槽已满返回 `agent thread limit reached`。这是并发槽限制，不是审批、沙箱或网络失败；总控将在本任务结束并释放槽位后触发原审查代理。

## 每周期传输字段与 Tensor Memory 规范化节点（2026-08-13）

总控在正式字段表登记读、写每周期传输量后，本包同步修正四条事实。`FACT-M2NA-CDNA3-L2-READ`、`FACT-M2NA-CDNA4-LDS-READ` 和 `FACT-M2NA-CDNA4-L2-READ` 现在使用 `FIELD-MEM-READ-TRANSFER-PER-CYCLE`，`FACT-M2NA-CDNA4-L2-WRITE` 使用 `FIELD-MEM-WRITE-TRANSFER-PER-CYCLE`，规范单位统一为 `byte/cycle`。XCD（AMD 计算芯粒）、CU（Compute Unit，计算单元）和通道（channel）的作用域没有揉进单位，继续保存在原条件集及事实、要求说明中；四条要求、事实指纹和资料卡已同步。`notes/fact-evidence-map.csv` 按断言重新生成，原文断言文件没有修改，SHA-256 仍为 `0a5ef16209e1e63b20fb89191b9bd8361082487fa7514a9080aeeb299274623b`。

`FACT-M2NA-BLACKWELL-TMEM-LOGICAL-SPACE` 在 `FIELD-MEM-CAPACITY` 下规范为 262144 byte，计算是 $512 \times 128 \times 32 / 8$。该值完整重表达 PTX 对每 CTA（Cooperative Thread Array，对应一个 CUDA thread block）逻辑数组形状和单元位宽的直接陈述，因此保留 `direct_statement`，不进入 `derived-metrics.csv`；条件、事实说明、要求和卡片均明确它不是物理静态随机存取存储器（SRAM）容量，也不能汇总成 GPU 总容量。AMD CDNA 产品页的 `SELMEM-M2NA-AMD-CDNA-LANDING` 与 `SROLE-M2NA-AMD-CDNA-LANDING` 均改为 `architecture_mechanism`，理由只指向 `FACT-M2NA-CDNA5-IF-PROTOCOL` 的 coherent on-package Infinity Fabric 机制，不再用通用代际身份作为最小集入选理由。

字段契约重验、185 条事实与 185 个卡片 fact_id 的双向检查、17 个来源的反向移除重验均通过。临时副本直接复制正式 `fields.csv`，其 SHA-256 为 `7cf5442800a7e453b34bbda4ac335ccf101ce5cac2dde297be657d4f56a02cae`；staging 没有新增 `fields.csv`。追加 23 个片段并准备 46 个本地 endpoint 后，正式校验器通过 75,776 项检查，退出码为 0。当前仍为 64 个组件、185 条事实、185 条断言和 369 条字段要求；临时副本已删除。

## 剩余风险

Rubin 的 10 条事实仍只由一份已固定官方网页支撑，尚无架构白皮书或 ISA 交叉核验。CDNA 6 只有名称和 announced 状态。四份 AMD ISA 因 auto-review approval usage-limit denial 未能保存本地固定 PDF；本包继续使用可定位的官方 PDF endpoint，不把该失败误记为网络或沙箱问题。Hopper 复用关系、Blackwell Ultra 继承关系和 CUDA ALU 的 `scalar` schema 归类仍由总控裁决。
