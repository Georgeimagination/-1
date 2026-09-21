# GA100 v3 官方网页与 PDF 快照 v2 独立复核

状态：`accept`

复核日期：2026-08-21。本轮对照冻结的 v1 拒收报告、v1 暂存包与 `r1_ga100_source_staging_v3_official_web_v2/` 重新计算，没有采用 v2 README 或 validation report 的计数作为验收依据。v1、v2、正式资料池、正式来源表、32 张正式表和进度文件均未改动；本文件是唯一新增项目文件。

## 裁决

v1 的唯一 blocker 已关闭。`R1GA100-WEB-010` 在 v2 `snapshot-manifest.csv`、`source-family-map.csv` 和 `capture-input.tsv` 中均精确使用 `NVIDIA AI Enterprise Infra 8.2 support matrix`，三者逐字符相等。family ID 仍为 `SFAM-R1GA100-NVIDIA-AI-ENTERPRISE-INFRA-8-2`，endpoint membership 仍只有 `R1GA100-WEB-010`，candidate role 仍为 `selected_candidate`。

v2 的 payload、headers、transfer metadata 和 transfer errors 与 v1 按相对路径逐文件比较，108 个文件全部 byte-identical。manifest、family map 与 capture input 的 v1/v2 diff 只涉及 `R1GA100-WEB-010` 这一行：manifest 和 capture input 改正 family label，family map 保留原有 canonical label 并补充 v2 说明；没有出现新的 endpoint、payload 或来源家族变动。未发现接收 blocker，v2 可以进入总控后续来源建模准备。

本次 `accept` 只接收隔离的网页/PDF 快照暂存包，不表示这些 candidate 已进入正式 source selection，也不表示正式断言、reverse removal 或三道 Windows hard gate 已完成。

## 集合、字节与哈希

独立枚举得到 29 个 manifest 条目，其中 27 个 `captured_success`、2 个 `rejected_no_payload`。磁盘有 27 个 payload，恰好由 22 个 HTML 和 5 个 PDF 组成；成功 manifest 的 `local_payload_path` 集合与磁盘集合完全相等，没有漏项、额外文件、重复 snapshot ID、重复路径或重复 SHA-256。

27 个 payload 共 15,817,628 bytes，逐文件重新计算的 byte count 和 SHA-256 均与 manifest 相同。对应的 27 个 header、27 个 transfer metadata 和 27 个空 stderr 文件一一齐全；`capture-input.tsv` 的 ID 集合等于 27 个成功 endpoint，capture log 的 ID 集合等于 manifest 全部 29 个 endpoint。v2 暂存包没有 JSON 文件。

v1 与 v2 的四个原始载荷目录比较结果如下：payload 为 27/27 相同，headers 为 27/27 相同，transfer metadata 为 27/27 相同，transfer errors 为 27/27 相同。比较同时核对了相对路径集合和每个文件的 SHA-256，不是只比较文件数量。

## HTTP、URL 与 Content-Type

27 个成功 endpoint 的 transfer metadata 均为 HTTP 200，其 Content-Type、final URL 和传输字节数与 manifest 逐字段相同。每个 header 最后一个响应块的状态和 Content-Type 也与 manifest 相同。24 个 endpoint 只有一个 200 响应；三个 TensorRT endpoint 均为 301 后接 200，`Location` 精确指向各自的 `https://archive.docs.nvidia.com/tensorrt/tensorrt-861/...` final URL。

五个 PDF 均以 `%PDF-` 开始，22 个 HTML 均有 HTML 文档结构，没有把错误响应按目标扩展名保存。80 GB Product Brief 的 requested URL 与 final URL 仍含 `PB-10577-001_v02.pdf`，PDF 封面和 Document History 则明确为 `PB-10577-001_v03 | March 2022`；manifest 按内部 v03 建模的边界没有漂移。

## PDF 页数与可读性

Poppler 独立复算得到：Newsroom PDF 3 页，40 GB Product Brief 19 页，80 GB Product Brief 20 页，MIG User Guide 74 页，vGPU User Guide 360 页。五份文件均未加密，`pdftotext` 全文解析成功；`pypdf` 逐页读取后，只有 MIG 与 vGPU 各自的空白第 2 页不含文本，其余页面均能抽取内容。

80 GB brief 的 Document History 页、MIG r580 封面和 vGPU 20.0-20.2 封面另行渲染检查，版本号、日期、表格、页眉和页脚清晰可读。MIG 封面为 `Release r580`、`Nov 14, 2025`；vGPU 封面为 `Release 20.0-20.2`、`Jul 31, 2026`。v2 PDF 与 v1 PDF 逐文件 byte-identical；结合本轮解析和渲染结果，v1 记录的两份 Product Brief xref 兼容性提示仍是非阻塞风险，没有产生新的解析或渲染问题。

## HTML 正文

22 个 HTML 均重新解析标题、一级或二级标题及可见正文。可见正文长度仍从 MIG latest 首页的 884 个字符到 TensorRT Release Notes 的 539,593 个字符不等；最短页面含 MIG 指南说明、章节目录和正文导航，supported-GPUs 页面含 A100、GA100、compute capability 8.0 与实例上限表，不是依赖后续脚本取正文的动态空壳。

其余页面保留各自的证据正文，包括 Technical Blog、Newsroom、AI Enterprise 8.2 support matrix、A100 vGPU profile 与四个 feature 页面、20.06/20.07 framework release notes、CUDA 11.0 GA、NCCL 2.7.6、cuDNN 8.x archive、cuSPARSELt 0.0.1，以及三份 TensorRT 8.6.1 文档。所有页面均无 password input，也没有命中 access denied、404、page not found、sign in to continue、log in to continue 或 enable JavaScript to continue 等错误正文。v2 的 22 个 HTML 与 v1 对应文件逐字节相同，正文未在修复 family label 时被改写。

## 来源家族、拒绝项与路径

`source-family-map.csv` 有 19 个唯一 family ID，对 manifest 的 29 个 endpoint 恰好覆盖一次，没有漏项、一项多属、重复 family ID 或 candidate role 分歧。manifest 与 family map 的 family label 对 29 个 ID 全部相等；对 27 个成功 endpoint 再加入 capture input 比较后，三方 label 仍全部相等。Newsroom HTML/PDF、两份 Product Brief、MIG 三入口、AI Enterprise vGPU 五个 companion 页面、PyTorch 两个版本和 TensorFlow 两个版本继续按作品家族归并；三份 TensorRT 文档继续作为三个不同作品家族保存。

两条 rejected 行的 payload path、bytes、SHA-256 和 header path 均为空。磁盘没有 DGX price 或 Developer Forum payload，拒绝项未因完整复制 v1 暂存包而落入载荷目录。

所有 payload 与 header 路径均为正斜杠分隔的相对路径，不含绝对路径、`..`、反斜杠或符号链接；解析后均位于 v2 暂存根内。最长 payload 相对路径为 92 个字符。路径检查没有发现可逃逸暂存根或依赖本机绝对目录的记录。

## 运行边界

本机没有 `pwsh`、`powershell` 或 `powershell.exe`，属于 tool/runtime limitation，不是 sandbox denial、审批失败、远端服务错误、用户拒绝或脚本失败。v2 是隔离暂存包，本轮也没有改正式数据，因此没有运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 或 `Validate-ResearchData.ps1`，本报告不声明三道 Windows hard gate 通过。

后续总控可以在保留本次快照哈希与 family ID 的前提下建立正式 source/version/endpoint 元数据，再按字段生成 assertion、screening、selection 与 reverse-removal 记录。动态 `latest` URL 仍须引用本地快照，不应把本次 `accept` 解释为在线页面已经固定不变。

## 文本复核

本报告按工程审计文档处理。机器扫描后，人工从结尾向前复读运行边界、路径、拒绝项、来源家族、HTML、PDF、HTTP 元数据和最终裁决，重新核对 29/27/2、22/5、15,817,628 bytes、108 个 v1/v2 byte-identical 文件、19 个 family、三条 TensorRT 重定向，以及 `R1GA100-WEB-010` 的三个 canonical family string。未发现数字、版本、对象边界或验收状态前后冲突。
