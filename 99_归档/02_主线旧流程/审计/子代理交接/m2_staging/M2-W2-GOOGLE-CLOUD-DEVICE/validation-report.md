# M2-W2-GOOGLE-CLOUD-DEVICE 校验记录

校验日期：2026-08-13  
状态：`ready_for_independent_review`

包内校验器最终通过 106 项检查：

```text
PASS: M2-W2-GOOGLE-CLOUD-DEVICE preparation package; 106 checks executed.
Scope: 3 cloud_accelerator candidates, 3 implements_architecture relations, 15 deferred dispositions, 7 configuration groups, 6 hashed content extracts.
```

检查覆盖三枚对象和三条架构关系的数量、ID 唯一性、对象层级、关系方向、对象 slug、关系指纹、正式 ID 碰撞与架构端点状态；14 个父待办到 15 个持久处置项的闭合；GV5P-03 的 95/96 GiB 双分支和禁止推导；七组配置行不得写入器件；`tpu-machines` 三个总控预留候选；六个本地 extract 的 endpoint 类型、首选状态、notes、字节数和 SHA-256；以及器件范围四源反向移除候选。

正式 32 表没有被本包修改。只读运行项目校验器得到：

```text
PASS: 32-table research data model; 93131 checks executed.
Registry: 323 columns, 488 enum values.
```

## 校验过程中的修正

首次运行时，校验脚本以无 BOM 的 UTF-8 保存，Windows PowerShell 5 对中文脚本按本地代码页解析，报出字符串未终止。这是脚本编码选择错误，属于操作者错误，不是沙箱拒绝、审批失败或远端服务错误；改为带 BOM 的 UTF-8 后解析恢复。

第二次运行出现三条假失败，原因是 PowerShell 对单个管道结果的 `.Count` 处理与预期不一致。校验器改为显式数组 `@(...)` 后重跑通过。一次中间替换命令没有匹配目标文本，随后逐行核对并改正；没有改动正式表，也没有把失败结果当成数据缺陷。

来源直取阶段的失败另行记录在 `source-freeze.md`。提权下载得到批准，但 TLS 握手仍失败；浏览器与 Python 也出现连接关闭或 EOF。它们属于远端或本机网络链路错误，不是用户拒绝、沙箱拒绝或审批失败。总控已经裁定不再重试，改用可哈希的 renderer 内容提取，并明确标为 `other / non-preferred`。

## 未由本包关闭的事项

包内通过不等于可以正式合并。三对象仍要通过独立复核和总控范围验收；`tpu-machines` 记录仍是 staging 候选；六个内容提取不是上游响应体，原始响应体 endpoint 继续 `pending`；配置事实与 v5p 物理 package 要在各自后续门禁中处理。四源最小集也要等事实包冻结后重新运行并签字。

## 成稿检查

README、来源冻结、合并说明和本校验记录均通过 `report-humanizer` 机器扫描，未发现可机器识别的模板化写作特征。随后按 `shuorenhua` 回读对象 ID、关系方向、14/15 条待办计数、95/96 GiB 原值、六份文件哈希、来源门状态与责任边界；没有改动版本、数字、术语或责任归属。