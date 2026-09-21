# 工具与访问异常记录

> 日期：2026-08-12。本记录只保存会影响复现或质量判断的异常，并按原因分类。

## 来源访问

四份动态网页首次在默认沙箱中下载时无法连接，属于受限网络环境下的连接失败；提升权限获批后，Blackwell Ultra、Rubin、AMD CES 2026 和 AMD CDNA 产品页的官方 HTML 快照均保存成功。四份 AMD 架构白皮书也已完成可读性、页数和 SHA-256 核对，固定候选保存在 `fixed-candidates/`。

随后尝试固定四份 AMD ISA PDF，自动审批复核因使用额度耗尽而拒绝。这属于 auto-review denial，不是用户拒绝、沙箱拒绝、远程服务错误或模型能力限制；因此本包保留官方在线 PDF endpoint，没有伪造本地快照。

AMD CES 2026 官方演示文稿的远程传输在 60 秒处超时，留下约 58 MB 的不完整文件。该问题归类为 remote service/tool timeout；已核对目标路径后删除半成品。CDNA 6 的名称与状态仍可由官方新闻稿复核，因此没有把“下载超时”误记为“来源不存在”。

本机没有可用的 `pdftotext` 或 `mutool`，属于本地工具缺失；PDF 文本核对改用现有 Python PDF 解析库。这个替代不改变固定文件的哈希，页码定位仍按原 PDF 核对。

## 数据装配与校验

工作过程中出现过 PowerShell 语句构造、命令长度、文本编码和卡片聚合错误；这些均属于 operator mistake，逐项回读后已纠正。尤其是早期 staging 验证器在正则替换中损坏了 Unicode 路径并把两条语句拼接在一起，导致大量伪枚举错误。损坏脚本已删除且不重建，不能作为验收证据。

随后改用“临时合并正式库副本 + 项目正式 `Validate-ResearchData.ps1`”验证。证据修复完成后的第一次实跑发现 29 条数值断言同时填写 raw 文本与数字，以及一条已删除 Rubin 要求的孤儿 requirement evidence；二者都属于 staging 装配错误。清理后重跑通过 75,746 项检查，退出码 0。

`source-endpoints.csv` 曾因一次错误编码写入而出现中文路径乱码，属于 operator/encoding mistake。现在 10 个本地 PDF endpoint 和 4 个 HTML snapshot endpoint 的项目相对路径均已按 UTF-8 回读并逐一验证存在；正式校验器复核了文件 SHA-256 和 PDF 页数。