# GA100 v3 官方网页与 PDF 快照独立复核

状态：`reject`

复核日期：2026-08-21。本轮只读检查 `r1_ga100_source_staging_v3_official_web/`，没有改动暂存包、正式资料池、32 张正式表、来源表或进度文件。本文件是唯一写入项目目录的产物。

## 裁决

27 个已获取 payload 的内容和传输记录可以复现：磁盘集合与 manifest 集合相等，bytes、SHA-256、PDF 页数、响应类型、最终地址和正文内容均通过独立检查；两条 `rejected_candidate` 也没有落入 payload。当前拒收只由一个来源家族一致性 blocker 造成。

`R1GA100-WEB-010` 在 `snapshot-manifest.csv` 中的 `source_family` 是 `NVIDIA AI Enterprise Infra support matrix`，在 `source-family-map.csv` 中则是 `NVIDIA AI Enterprise Infra 8.2 support matrix`。两个文件使用同名字段，却给同一 endpoint 写了不同值；manifest 又没有 `source_family_id` 可直接作为外键。若后续按名称生成正式 source family，这一差异可能把同一作品拆成两个家族，或迫使合并脚本依赖未声明的字符串归一化规则。

最小修复是统一这两个字符串，保留现有 `SFAM-R1GA100-NVIDIA-AI-ENTERPRISE-INFRA-8-2` 和 endpoint 归属不变，然后重新执行 family label、endpoint membership 与 manifest 全集的精确相等检查。该修复不要求重新下载任何 payload。除此以外，本轮没有发现第二个接收 blocker。

## payload、manifest 与路径复算

独立按磁盘枚举得到 27 个 payload，共 15,817,628 bytes。其中 22 个 HTML 共 7,126,538 bytes，5 个 PDF 共 8,691,090 bytes。manifest 有 29 行，恰好是 27 行 `captured_success` 和 2 行 `rejected_no_payload`。成功行的 `local_payload_path` 集合与磁盘 payload 集合完全相等，没有缺项、额外文件、重复路径、重复 SHA-256 或重复 snapshot ID。

27 个文件逐一重新计算 byte count 与 SHA-256，全部与 manifest 相同；对应的 27 个 transfer metadata、27 个 header 文件和 27 个空 stderr 文件也一一齐全。`capture-input.tsv` 的 endpoint 集合等于 27 个成功 ID，`download-or-capture-log.csv` 的 ID 集合等于 manifest 全部 29 个 ID。暂存包中没有 JSON 文件，因此本轮没有遗漏待读的 JSON 记录。

所有 payload 和 header 路径均为正斜杠分隔的相对路径，不含绝对路径、`..`、反斜杠或符号链接；解析后都留在暂存根内。最长 payload 相对路径为 92 个字符。两条拒绝记录的 payload path、bytes 和 SHA-256 均为空，磁盘也没有名称涉及 DGX price 或 Developer Forum 的 payload。

## HTTP、Content-Type 与最终地址

27 个成功 endpoint 的 transfer metadata 均为 HTTP 200，记录的 Content-Type、最终 URL 和传输字节数与 manifest 逐字段相同。header 最后一个响应块的状态和 Content-Type 也与两者一致。24 个 endpoint 的 header 序列只有一个 200 响应；三个 TensorRT endpoint 的序列均为 301 后接 200，`Location` 分别精确等于 manifest 中对应的 `https://archive.docs.nvidia.com/tensorrt/tensorrt-861/...` 最终地址。PDF 均有 `%PDF-` 文件签名，HTML 均有 HTML 文档结构，未发现把错误响应按目标扩展名保存的情况。

## PDF 页数、版本与可读性

Poppler `pdfinfo` 复算页数如下：Newsroom PDF 3 页、40 GB Product Brief 19 页、80 GB Product Brief 20 页、MIG User Guide 74 页、vGPU User Guide 360 页。五份文件均未加密，`pdftotext` 全文解析成功；`pypdf` 逐页读取后，除 MIG 和 vGPU 各自有一张预期的空白第 2 页外，其余页面均能抽取文本。首尾页以及 80 GB brief 的 Document History 页已另行渲染检查，文字、表格、页眉和页脚可读，没有裁切、黑块或登录/错误提示。

两份 Product Brief 会触发 `pypdf` 的非零起始 xref 修正提示，通用 `file` 识别器也给出不可靠的页数；这没有阻止 Poppler、`pypdf` 或实际渲染。40 GB 和 80 GB 文件分别完整渲染出 19 页和 20 页，故该提示记为非阻塞兼容性风险，不改写成“文件损坏”。

80 GB brief 的请求与最终 URL 都仍以 `PB-10577-001_v02.pdf` 结尾，但封面和 Document History 明确写明 `PB-10577-001_v03 | March 2022`，history 同时列出 01、02、03 三次修订；manifest 以内部 v03 为 source version 的处理正确。40 GB brief 的封面和 history 均为 `PB-10137-001_v03 | September 2020`。MIG PDF 封面为 `Release r580`、`Nov 14, 2025`，页数为 74；vGPU PDF 封面为 `Release 20.0-20.2`、`Jul 31, 2026`，页数为 360。这四项均与 manifest 和 README 一致。

## HTML 正文与动态壳检查

22 个 HTML payload 均逐一解析标题、一级或二级标题和可见正文，并检索与各自 evidence role 对应的版本、产品或功能词。可见正文长度从 MIG latest 首页的 884 个字符到 TensorRT Release Notes 的 539,593 个字符不等。最短的 MIG 首页仍含指南说明、章节目录及 Introduction 链接；supported-GPUs 页面直接给出 A100-SXM4、A100-PCIE、GA100、compute capability 8.0 和实例上限表。它们不是只依靠 JavaScript 再取正文的空壳。

其余页面也都保留服务器返回的证据正文，包括 Technical Blog 的 A100/GA100 架构段落、Newsroom 的 full production 与 shipping 文本、AI Enterprise 8.2 support matrix、A100 vGPU profile 和四个 feature 页面、20.06/20.07 framework release notes、CUDA 11.0 GA、NCCL 2.7.6、cuDNN 8.x archive、cuSPARSELt 0.0.1，以及 TensorRT 8.6.1 的三份文档。没有 payload 出现 password input，也没有命中 access denied、404、page not found、sign in to continue、log in to continue 或 enable JavaScript to continue 等错误正文。页面中的 form 属于站内搜索或联系功能，不是登录门。

vGPU lifecycle 页面标题为 `August 3, 2026`，正文列出 A100 系列，页脚为 `Last updated on Aug 4, 2026`；AI Enterprise support matrix 正文和标题均明确为 8.2。三个 TensorRT payload 的标题、正文和 archive context 与重定向后的最终地址一致。HTML 外链样式、脚本和图片没有镜像，但本轮要求核对的主文档正文已经落盘；现有 README 对这一边界的描述准确。

## 来源家族去重

`source-family-map.csv` 有 19 个唯一 family ID，对 manifest 的 29 个 endpoint 实现恰好一次覆盖，没有漏项或一项多属。17 个已获取来源家族和 2 个拒绝家族的 candidate role 均与 manifest 一致。Newsroom HTML/PDF、两份 Product Brief、MIG 三入口、AI Enterprise vGPU 五个 companion 页面、PyTorch 两个版本和 TensorFlow 两个版本均已按作品家族归并；三份 TensorRT 文档作为不同作品家族保留，没有发现相同 payload hash 被当作独立佐证。

这部分的集合与角色关系通过，但 family label 仍有前述 `R1GA100-WEB-010` 单点不一致。接收结论因此保持 `reject`，不能用“endpoint membership 已覆盖”替代字符串一致性修复。

## 运行边界

本机没有 `pwsh`、`powershell` 或 `powershell.exe`。这属于 tool/runtime limitation，不是 sandbox denial、审批失败、远端服务错误、用户拒绝或脚本失败。本任务只复核隔离的网页/PDF 暂存包，也没有改正式数据，因此未运行 `Test-SourcePool.ps1`、`Test-ChipScope.ps1` 或 `Validate-ResearchData.ps1`，本报告不声明三道 Windows hard gate 通过。

修复 family label 后，只需重跑本报告所列的暂存包只读检查并重新申请独立接收；正式来源建模、逐事实断言和 reverse removal 仍由总控在后续阶段完成。

## 文本复核

本报告按工程审计文档处理。完成机器扫描后，人工从结尾向前复读了运行边界、来源家族、HTML 正文、PDF 版本、HTTP 元数据、路径和最终裁决，重点核对 29/27/2 行状态、22/5 文件类型、15,817,628 bytes、19/20/74/360 页、v02 URL 对 v03 文档、三条 TensorRT 重定向，以及唯一 blocker 的两个原始字符串。没有把未运行的 Windows hard gate、自动修正过的 PDF xref 提示或 family endpoint 覆盖写成正式接收通过。
