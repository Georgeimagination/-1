# GA100 正式写入硬门运行时审计

状态：`blocked_for_formal_merge`。本机可以继续只读审计和 staging 准备，但不能安全合并 GA100 的正式 CSV。  
日期：2026-08-21  
对象：`NVIDIA GA100 die` 工作包  
写入边界：本任务只新增本交接文件；没有修改 `数据/`、`最小参考资料库/`、资料卡、来源清单、原始资料或进度文件。

## 裁决

当前 macOS 26.3.1（arm64）没有 `pwsh`、`powershell` 或 `powershell.exe` 可执行文件；项目目录、常见本机安装目录和 Codex bundled runtime 中也没有 PowerShell。三个正式硬门都依赖 PowerShell，且 `Test-ChipScope.ps1` 与 `Validate-ResearchData.ps1` 明确要求 5.1 以上版本。因此，本环境不能执行三道硬门，正式 CSV 不得在此合并。

这不是 sandbox denial、approval failure 或 remote service error。命令本身没有被拒绝，也没有请求安装或下载软件；阻断原因是 `tool/runtime failure`，即缺少项目规定的 PowerShell 运行时。项目的长期约定进一步要求 Windows PowerShell 和 Windows 运行根完成正式写入前检查，所以即使未来在本机单独装入跨平台 `pwsh`，也不能自动替代该关闭条件。

此外，即使切换到 Windows，当前 `Test-SourcePool.ps1` 也预期不能关闭：脚本冻结的 PDF 数为 111、总字节数为 313,921,821，而当前目录已有 113 份 PDF、315,363,681 bytes，其中 MI455X 与 MI350P 两份官方 brochure 尚未登记。根据脚本逻辑，这至少会触发磁盘 PDF 数、清单与磁盘行数、未登记文件和总字节数四项关键失败。它是已知资料池基线差异，不是 GA100 数据语义错误，但未完成有意资料池变更的审计和基线更新前，不能把 `Test-SourcePool` 记为通过。

## 三道硬门的实际覆盖和本机可运行性

| 硬门 | 脚本实际检查 | 当前环境 | 对 GA100 正式合并的意义 |
|---|---|---|---|
| `Test-SourcePool.ps1` | 四个资料池清单的冻结 SHA-256、必需列、111/914/11 行基线、PDF 路径、大小、SHA-256、总字节数、URL 两种大小写口径和汇总 JSON；`pdfinfo.exe` 可用时再核验页数 | 未运行：缺少 PowerShell，属于 `tool/runtime failure` | 即使有 PowerShell，当前 113 对 111 的已知差异也会使门失败；`pdfinfo` 缺失仅为非关键 warning，不是关闭阻断 |
| `Test-ChipScope.ps1` | objects 与 DEC-031 范围登记的一一对应、对象类型到范围分类、覆盖计数标记、facts 与 field-requirements 的可解析 owner、selection run 与范围登记的一致性 | 未运行：缺少 PowerShell，属于 `tool/runtime failure` | 防止把 card、server、instance 等非芯片对象重新混入主线，以及 selection run 脱离范围登记 |
| `Validate-ResearchData.ps1` | 32 张表的表头、非空、分号禁用、受控枚举、主键、外键、七个目标外键唯一性、事实/断言值 XOR、证据状态、已审事实的已审断言、endpoint 相对路径和 SHA-256、筛选覆盖、最小集成员、缺口理由、事实与 field-requirement 主体合同、派生指标 | 未运行：缺少 PowerShell，属于 `tool/runtime failure` | 是正式结构和证据链的 gate；默认 `SubjectContractMode=gate`，不能以 `audit` 模式替代 |

三者均为只读检查。`Test-SourcePool.ps1` 没有 `#Requires` 行，但使用 PowerShell cmdlet；另两个含 `#Requires -Version 5.1`。`Validate-ResearchData.ps1` 的 `audit` 仅把部分主体合同问题列为审计输出，正式关闭必须保持默认 `gate`。

## 已完成的跨平台检查及其边界

本机的系统 Python 3.9.6 与 Codex bundled Python 3.12.13 均可用。使用 bundled Python 对 `scripts/validation/verify_recovery_paths.py --root .` 实跑通过：32 张正式表存在，153 个 endpoint 中 79 个本地路径均为主线根下的安全相对路径且 SHA-256 全匹配，11 个 selection run 与 106 个 selection member 的引用完整。脚本也已通过 Python 语法编译检查。

该恢复检查证明当前目录仍能恢复正式表、固定本地证据与选择运行引用；它没有读取 CSV 表头、枚举、主键、外键、字段主体合同、事实数值 XOR、evidence state、已审断言、筛选覆盖、派生指标或 DEC-031 的 chip-only 分类。因此，它不能替代任何 PowerShell 硬门，也不能证明将来 staging overlay 的内容可以合并。

项目已记录的 0.3 跨平台结构检查为 130,411 项通过，覆盖表头、类型、枚举、主外键、主体合同、旧行保持和本轮增量边界；其与恢复检查共同证明 0.3 迁移后的当前正式基线没有明显结构或恢复断裂。该结果是历史审计证据，不是本轮重新执行的正式 gate，且不覆盖 GA100 尚未合并的候选对象、事实、断言、来源或 selection run。

## staging 可以推进到的边界

在不改动正式数据的前提下，可以继续：核对 GA100 对象层级和 Ampere 关系，精读并固定来源，制作候选来源登记、字段映射、缺口与冲突表，构造独立 staging overlay，检查 UTF-8、表头、主键碰撞、候选外键、受控枚举和候选文件哈希，并在正式库不变的前提下重跑 Python 恢复检查。任何这类检查都必须标为 staging 或只读审计，不能写成“正式校验通过”。

在下列事项完成前，不可将 overlay 写入正式 CSV，不可更新正式 selection run，也不可把 GA100 卡标为完成：Windows 硬门运行环境就绪、资料池基线差异有正式裁决并使 `Test-SourcePool` 回到通过状态、GA100 staging 由主代理审阅并在临时合并副本上先通过范围与数据 gate，最后才对正式根执行三道只读硬门。

## 关闭条件

关闭本阻断需要一台可访问完整主线副本的 Windows 环境，至少具有 Windows PowerShell 5.1、可读取 UTF-8 CSV 和本地证据文件的权限，并从主线根以默认 `gate` 模式执行：

```powershell
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '.\scripts\validation\Test-SourcePool.ps1' -RootPath '.'
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '.\scripts\validation\Test-ChipScope.ps1' -RootPath '.'
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '.\scripts\validation\Validate-ResearchData.ps1' -RootPath '.' -SubjectContractMode gate
```

在这之前，主代理还需对两份未登记 AMD brochure 作明确资料池处理：若纳入清单，应登记来源信息并同步更新 `Test-SourcePool.ps1` 的冻结数量和哈希常量；若不纳入，应按项目资料池规则将其移出正式 `论文/` 范围或作等价的可审计处置。该处置不属于本任务授权范围。三条命令必须在目标正式根都退出 0；资料池页数核验工具缺失可以留下脚本定义的 warning，但任何 critical failure 都不能接受。

## 操作与失败分类

本任务没有安装、下载、外部请求、审批请求或文件删除；因此没有 sandbox denial、approval failure 或 remote service error。两项只读命令曾因路径使用错误未读取目标文件：首次把 `verify_recovery_paths.py` 误写为 `scripts/verify_recovery_paths.py`，另一次在已进入主线根后仍使用重复的相对研究计划路径。这两项都是 `operator mistake`，没有产生写入，随后已用正确路径完成读取和 Python 运行。一次宽泛文本检索因工具输出长度限制而截断，属于 `tool/runtime failure` 的输出限制；后续改用目标文件和目标关键词检索，没有影响裁决。

## 自然化复读

本文件已按 `report-humanizer` 完成机器扫描，并人工复读标题、首段、三个硬门表、staging 边界和关闭条件。机器扫描没有发现可检测的 AI 套路；人工复读没有发现模板化开场、把运行时缺失写成数据失败，或把 staging 能力误说成正式通过。剩余风险是 Windows 实跑和资料池基线裁决尚未发生，不能由文字审计消除。
