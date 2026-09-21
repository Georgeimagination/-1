# M2-W2-AMD-HELIOS-SYSTEM 修复后校验记录

- 状态：`ready_for_independent_review`
- 校验日期：2026-08-13
- 校验对象：`OBJ-AMD-HELIOS-72-MI455X`
- 写入范围：仅本 staging 包

## 结果

本包保留 18 条事实、22 条断言、17 条字段要求和九域完整度记录。修复后的 `condition-sets.csv` 有 6 行，`source-selected-roles.csv` 有 6 行；24 个 structured CSV 合计 102 行非空片段。所有事实仍能回到至少一条断言、一个 subject-field 要求和观察卡中的事实 ID，没有派生事实、派生输入或单模组乘算。

## 五项修复

拓扑事实 `FACT-M2W2-AMD-HELIOS-SCALEUP-TOPOLOGY` 已改为 `switched_fabric`。`ASSERT-M2W2-AMD-HELIOS-0020` 保留原文 “UALoE multi-plane network with all-to-all GPU connectivity”，以 multi-plane network 支持交换网络归一，并把 all-to-all 限定为 GPU 全互达；不再推断完全图物理直连、单跳或无阻塞。

`COND-M2W2-AMD-HELIOS-SCALEUP` 与 `COND-M2W2-AMD-HELIOS-SCALEOUT` 的 `performance_basis` 均改为 `vendor_label_unresolved`。260 TB/s 与 43 TB/s 仍保留厂商原值、系统总量和方向未说明条件，但不再写成理论峰值。

`ASSERT-M2W2-AMD-HELIOS-0015` 继续以 MI400 第 7531 行的 1.67 PB/s 为原始精确值，同时定位第 8252 行的 “up to 1.7 PB/s Peak Theoretical Memory Bandwidth” 以确定性能口径；1.7 不替换 1.67。`ASSERT-M2W2-AMD-HELIOS-0012`、`0013`、`0021`、`0022` 已分别补入 Helios 第 11722 行或 MI400 第 13098 行的 MI400-005 脚注，记录 AMD Performance Labs 计算、理论峰值、2026 年 6 月和系统厂商配置可能不同。

CES 新闻稿已在 `source-selected-roles.csv` 增加 `core_spec` 角色。`SELMEM-M2W2-AMD-CES2026-RELEASE` 的反向移除理由同时覆盖 3 AI exaflops 唯一直接证据和 2026-01-05 early-look 日期锚点。三源选择运行仍为 `draft`，等待不同代理最终签字。

条件集从 8 行减到 6 行。OCP MXFP4 与 OCP MXFP8 仍是两条独立 precision path，但共同引用 `COND-M2W2-AMD-HELIOS-OCP-MXFP-PEAK`；31 TB HBM4 容量改为复用 `COND-M2W2-AMD-HELIOS-OBS-20260812`。两处合并没有删除精度、数值、单位、日期或限定条件。

## 包内检查

修复后重新执行 438 项只读检查，错误为 0。检查覆盖 24 个 structured CSV 与正式表头逐字一致、主键唯一、目标列唯一、字段和条件外键、事实与断言证据数、事实、断言、要求与卡片之间的闭合、6 条件集上限、CES 双角色、共享 OCP 条件、HBM4 容量条件复用、`switched_fabric` 归一、九域状态、空表，以及两份新 HTML 的文件、字节与 SHA-256。

固定 Helios HTML 仍为 282127 字节，SHA-256 为 `ed1642ec9ec16f9a5db4a8956b367e9859a3b2f47f9b18fcfe441fc56c34c6b7`；固定 MI400 HTML 仍为 318594 字节，SHA-256 为 `aa5603704c4d77d1e912a5921e289ccabaa45111bab209c2ce08975aedc58a7e`。

## 临时正式副本

staging 的 102 行非空片段已追加到受控临时正式副本。官方 `Validate-ResearchData.ps1` 结果为：

```text
PASS: 32-table research data model; 93775 checks executed.
Registry: 323 columns, 488 enum values.
```

临时目录 `codex-helios-remediation-32ca8a1b25d7492bb0ea0f228aca9f8a` 已删除并确认不存在，三个链接目标均存在。正式 32 张 CSV 在校验前后逐文件计算 SHA-256，变化数为 0。

## 剩余边界

3 AI exaflops 仍缺数据格式与运算计数定义；OCP MXFP4/MXFP8 仍缺稠密或稀疏说明，系统厂商配置可能不同。1.67 PB/s 的读写方向未说明；260 TB/s 和 43 TB/s 还缺方向、有效载荷及理论峰值/持续值分类。Helios 仍是 `announced` 的 reference design，不是 AMD 直接销售的 rack SKU；预计 2026 年下半年规模部署不能作为已供货证据。

正式表、正式资料卡、根 `README.md`、根 `AGENTS.md`、计划和进度均未修改。本包现已冻结，等待不同代理独立复核。