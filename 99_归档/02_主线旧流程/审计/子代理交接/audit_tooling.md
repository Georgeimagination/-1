# 资料池校验工具交接

审计日期：2026 年 8 月 12 日  
任务编号：AUDIT-TOOL-001

## 任务状态

待总控验收。校验脚本已经在当前资料汇总目录完成正常路径、无页数工具路径和关键异常路径三类测试。现有资料池通过校验，唯一警告来自一份 PDF 的交叉引用表重建提示。

## 输入

本任务读取了以下内容：

- 根目录的 `AGENTS.md`；
- `研究计划.md` 中阶段 1、子代理交接和长期任务状态规则；
- `审计/子代理交接/README.md`；
- `审计/子代理交接/source_pool_audit.md`；
- `清单/论文PDF清单.csv`、`清单/网页与在线资料.csv`、`清单/待补论文清单.csv` 和 `清单/汇总统计.json`；
- `论文/` 下的 102 份 PDF。

`论文/` 和 `清单/` 全程只读。本任务没有联网检查 URL，也没有修改现有清单、研究计划、进度文件、README 或 AGENTS。

## 已完成

新增 `scripts/validation/Test-SourcePool.ps1`。脚本通过 `-RootPath` 接收项目根目录；不传参数时，从脚本所在位置向上推导根目录。代码中没有个人工作区的绝对路径。`-PdfInfoPath` 可用于明确指定 `pdfinfo.exe`，也就是 Poppler 工具集的 PDF 元信息读取程序。

脚本按以下口径检查当前基线：

| 校验面 | 检查内容 | 关键不一致时的行为 |
|---|---|---|
| 必需输入 | 四个清单和统计文件是否存在，SHA-256 是否等于审计基线。SHA-256 是用于判断文件内容是否变化的哈希 | 输出 `FAIL`，退出码为 1 |
| PDF 清单和磁盘 | 清单行数、磁盘 PDF 数、路径是否越界、重复路径、漏列文件、文件大小和逐文件 SHA-256 | 输出 `FAIL`，退出码为 1 |
| PDF 页数 | 显式找到实际 `pdfinfo.exe` 后，逐文件读取页数并与清单比较，汇总总页数；解析器诊断单独保留为警告 | 页数不一致或解析失败时退出码为 1 |
| 页数工具缺失 | 找不到实际 `pdfinfo.exe` 时不猜测页数，输出 `NOT_VERIFIED` | 只记 `WARN`；其余检查通过时退出码仍为 0 |
| 网页清单 | 行数、空 URL、区分大小写的 Ordinal 唯一数、忽略大小写的 OrdinalIgnoreCase 唯一数 | 输出 `FAIL`，退出码为 1 |
| 汇总统计 | `unique_pdfs`、`combined_online_urls` 和 `pending_papers` 与当前基线是否一致 | 输出 `FAIL`，退出码为 1 |

页数工具发现过程先找 `pdfinfo.exe`。本机 PATH 只有 `pdfinfo.cmd` 包装器时，脚本会顺着包装器引用找到实际 EXE，再直接调用该文件。若包装器不能解析，则降级为页数未验证，不调用 `.cmd` 代替 EXE。

## 验证

正常路径在项目根目录使用 Windows PowerShell 5.1 运行：

~~~powershell
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '.\scripts\validation\Test-SourcePool.ps1' -RootPath '.'
~~~

最终输出 `RESULT: PASS (1 warning(s))`，退出码为 0。不传 `-RootPath` 的默认调用也已实测，脚本推导出的根目录与当前资料汇总根目录一致，结果相同。复现结果如下：

| 项目 | 结果 |
|---|---:|
| PDF 清单行数 | 102 |
| `论文/` 下 PDF 数 | 102 |
| 文件存在、大小和 SHA-256 全部匹配 | 102 |
| PDF 总大小 | 282,552,081 字节 |
| 页数成功读取并与清单匹配 | 102 |
| PDF 总页数 | 2,008 |
| 网页清单行数 | 914 |
| `StringComparer.Ordinal` 唯一 URL 数 | 893 |
| `StringComparer.OrdinalIgnoreCase` 唯一 URL 数 | 892 |
| 待补论文行数 | 11 |

`StringComparer.Ordinal` 按字符串的 Unicode 码位逐字比较，区分大小写；`StringComparer.OrdinalIgnoreCase` 采用同一比较方式但忽略大小写。两个结果因此分别保留 893 和 892 这两个口径。

四个输入文件的当前指纹均通过：

| 文件 | SHA-256 |
|---|---|
| `清单/论文PDF清单.csv` | `54008a90364eb0ce9d98ff189817002a407159457ba5cef8850da80c67da692e` |
| `清单/网页与在线资料.csv` | `f19991c731fcdca8e0dee65601a2637a5568bc1fde46b357757d19292aa1395f` |
| `清单/待补论文清单.csv` | `b5a5993c0a29364c5be3c2d6d35321e3150b5599913e3fafe887bff3a02307bd` |
| `清单/汇总统计.json` | `be7872886b562fe444cc8c4fa4079c0d345e5884036c60d92ea4dec71a501282` |

解析器对 `2020_Google_Training_Chips_TPUv2_TPUv3_HotChips32.pdf` 报告 `Internal Error: xref num 3 not found but needed, try to reconstruct`。该文件仍成功读取 70 页，页数与清单一致，因此脚本保留一条 `WARN`，没有把文件判为失败。

另做了三项行为测试：

1. 把 `-PdfInfoPath` 指向不存在的文件，脚本明确输出 `PDF page count verification: ... NOT_VERIFIED`，其余检查通过，退出码为 0。
2. 在系统临时目录复制四个清单但不复制 PDF，脚本输出 `RESULT: FAIL (9 critical failure(s), 0 warning(s))`，退出码为 1。
3. 在临时副本中移除 PDF 清单的必需字段，脚本明确报告缺少 `汇总后文件`，输出 `RESULT: FAIL (2 critical failure(s), 0 warning(s))`，退出码为 1。

两次异常测试使用的临时目录都在核对绝对路径位于系统临时目录后删除。

首次试跑时，Windows PowerShell 5.1 把 `pdfinfo.exe` 写入标准错误流的诊断信息提升为终止错误。该问题属于脚本的 PowerShell 兼容性遗漏，不是沙箱、审批或远程服务故障。脚本现已在调用期间按非终止方式捕获诊断信息，恢复原错误策略后继续校验；修复后的三类测试结果如上。

脚本当前为 455 行、17,953 字节，SHA-256 为 `915d7cada00c49e8fd21fa312ab9de127f4873c486d8b7b2565cc04ef067ca63`。

## 未解决

脚本只校验离线资料池的一致性，不判断 914 个 URL 是否可访问、是否重定向、是否需要登录，也不判断不同来源的事实覆盖关系。

四个输入文件的哈希和数量是当前基线常量。以后合法更新清单时，脚本会先失败，用来阻止未说明的基线漂移；总控核对变更后，需要一起更新预期哈希和对应数量。

页数工具缺失时，页数检查按任务要求标为 `NOT_VERIFIED`，不会单独造成失败。若后续自动流程要求页数必须经过验证，可在调用环境中显式传入 `-PdfInfoPath`，或再增加严格模式参数。

那份 Hot Chips PDF 的交叉引用表诊断仍存在。现有证据只能确认 `pdfinfo.exe` 可读且页数匹配，未修复原文件。

## 建议下一步

总控验收后，把该脚本登记为阶段 1 的基线校验入口。每次修改 `论文/` 或四个清单前后各运行一次；若修改是有意的，先检查差异，再更新脚本内的基线哈希和数量，不能只为了让校验通过而替换常量。

后续若增加机器可读的审计产物，可以在保持默认只读的前提下增加显式输出参数。URL 存活检查和来源家族整理应由单独任务处理，避免把网络状态和离线文件一致性混为一种失败。

## 写入文件

- `scripts/validation/Test-SourcePool.ps1`
- `审计/子代理交接/audit_tooling.md`

