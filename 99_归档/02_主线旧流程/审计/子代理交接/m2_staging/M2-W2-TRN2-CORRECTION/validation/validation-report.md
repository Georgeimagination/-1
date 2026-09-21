# Trainium2 correction 验证报告

验证日期：2026-08-13

## 正式基线

本包以 Helios 合并后的静止正式库为基线：75 个对象、24 条关系、632 条事实、622 条逐来源断言、803 条字段要求。`baseline-hashes.csv` 固定了全部 32 张正式表。制作和验证 correction 包后重新计算，`validation/formal-hash-comparison.csv` 的 32 行全部为 `unchanged=true`。正式校验器在前后均通过：

```text
PASS: 32-table research data model; 93799 checks executed.
Registry: 323 columns, 488 enum values.
```

## 包内结构检查

24 个 overlay CSV 与对应正式表表头逐字一致，共 188 行操作。delete 和 update 的主键全部存在于当前正式表，append 的主键全部不存在；文件内及跨操作均无重复主键。`operation-manifest.csv` 有 196 行，其中 188 行对应表操作，8 行对应文件 create 或 replace；所有“表路径 + 操作 + 主键”组合唯一。

只读并行审计复算了同一组表头、主键和内存模拟结果。它指出 M1 卡的断言计数和 S15 裁决措辞两项问题；本包已把断言数改为 154，并把 S15 表述改为来源筛选结论而非事实优选裁决。

## 隔离副本

完整复制正式校验所需目录到项目外的同盘隔离目录，再用 `scripts/Apply-Correction.ps1` 应用全部 delete、update、append 和文件复制计划。合并结果为 621 条事实、611 条断言、792 条字段要求、141 个条件集、15 个冲突组和 31 个冲突成员。官方校验器通过：

```text
PASS: 32-table research data model; 93131 checks executed.
Registry: 323 columns, 488 enum values.
```

第一次运行应用脚本时，Windows PowerShell 5.1 把无 BOM 的 UTF-8 脚本中的中文路径误解码；第二次发现脚本用单个反斜杠作为正则替换模式。两次都属于本地脚本编码或命令构造错误，不是沙箱、审批或远端服务问题。脚本改为 UTF-8 BOM，并改用字符替换后，隔离应用成功。官方校验器第一次指出新 S07 断言为 `draft`，而对应事实是 accepted；把该行纳入 17 行显式生命周期清单并标为 `reviewed` 后，校验通过。

## 语义检查

`validation/semantic-check.txt` 的结果为 PASS：

- S10 历史稀疏事实只剩芯片 FP8 和 `trn2.48xlarge` FP8 两条；
- UltraServer 3.2 Tbps 错主体事实、断言、要求、条件集和冲突组均不存在；
- 三条实例 EFA 使用 `FIELD-INT-INJECTION-BW`，数值分别为 25,000,000,000、400,000,000,000、400,000,000,000 byte/s；UltraServer 12.8 Tbps 使用 `FIELD-INT-AGGREGATE-BW`，为 1,600,000,000,000 byte/s；
- `trn2.3xlarge` 芯片数只有 S07 Product details 表断言；
- 41 条卡片映射按对象为 4/20/17，按来源为 S06=32、S07=5、S09=1、S10=1、S15=2；
- 39 条可采纳事实的最小来源运行只含 S06、S07、S09、S10；
- 芯片 BF16、FP16、TF32 当前事实仍各有一个 `CG-AWS-TRN2-007-*` 成员，没有误判为已解决。

## 清理

隔离目录只用于本轮验证。完成最终哈希和文档检查后按已解析的单一绝对路径删除，并再次确认路径不存在；正式库没有被用作应用目标。