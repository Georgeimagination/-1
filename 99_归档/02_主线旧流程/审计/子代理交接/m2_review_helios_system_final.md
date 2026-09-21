# M2-W2-AMD-HELIOS-SYSTEM 最终独立复核

复核日期：2026-08-13  
裁决：`accept`  
独立复核者：`m2_final_review_helios`  
复核独立性：未参与初稿、五项修复或修复后清单生成。  
写入范围：本报告、行级生命周期清单及其独立签字；冻结 staging（待合并区）、正式 32 表、正式资料卡和全局文档均未修改。

## 裁决

修复后的 `M2-W2-AMD-HELIOS-SYSTEM` 可以交由总控顺序合并。初次复核提出的 B1 至 B5 已全部关闭，包内 18 条事实、22 条逐来源断言、17 条字段要求和 9 条完整度记录能够闭合到观察卡和固定来源。尚未公开或尚未定清的口径都保留在条件、注释或 `needs_resolution` 状态中，没有被当作定值补齐。

这项 `accept` 不等于把所有语义缺口判为已解决。3 AI exaflops 仍缺数据格式和运算计数定义；OCP（Open Compute Project，开放计算项目）MXFP4/MXFP8 微缩放浮点格式没有稠密或稀疏说明，且 AMD 提醒系统厂商配置可能不同；1.67 PB/s 没有读写方向；260 TB/s 和 43 TB/s 仍缺方向、有效载荷及理论峰值或持续值分类。Helios 仍是 AMD 提供给 OEM（Original Equipment Manufacturer，原始设备制造商）/ODM（Original Design Manufacturer，原始设计制造商）的参考设计，不是 AMD 直接销售的机架型号（Stock Keeping Unit，SKU）；预计 2026 年下半年规模部署也不能写成已供货。

## B1 至 B5 关闭情况

| 项目 | 最终核对 |
|---|---|
| B1 拓扑语义 | `FACT-M2W2-AMD-HELIOS-SCALEUP-TOPOLOGY` 的规范值为 `switched_fabric`，事实指纹、断言指纹、拓扑行和观察卡一致。来源原文 “multi-plane network with all-to-all GPU connectivity” 仍被逐字定位；all-to-all 只解释为 GPU 全互达，不推断完全图物理直连、单跳或无阻塞。 |
| B2 带宽口径 | scale-up 和 scale-out 条件的 `performance_basis` 均为 `vendor_label_unresolved`，方向为 `direction_not_specified`。HBM4（第四代高带宽存储器）带宽断言同时定位 MI400 第 7531 行的精确值 1.67 PB/s 与第 8252 行的 “up to 1.7 PB/s Peak Theoretical Memory Bandwidth”；1.7 只用于定性口径，不替换 1.67。 |
| B3 MXFP 脚注 | `ASSERT-M2W2-AMD-HELIOS-0012`、`0013`、`0021`、`0022` 均绑定 MI400-005 脚注：前两条定位 Helios 第 11722 行，后两条定位 MI400 第 13098 行；四条都记录 AMD Performance Labs、2026 年 6 月、理论峰值、系统厂商配置可能不同和稠密/稀疏未说明。 |
| B4 CES（国际消费电子展）来源角色 | `SRC-M2NA-AMD-CES2026-RELEASE` 同时具有 `core_spec` 与 `status_version_evidence` 角色。反向移除理由同时覆盖唯一直接的 up-to-3 AI-exaflops 事实和 2026-01-05 early-look 日期锚点。 |
| B5 条件与精度路径 | 条件集恰为 6 行。OCP MXFP4 和 OCP MXFP8 保持两个独立精度路径（precision path） 与两条独立事实，只共享 `COND-M2W2-AMD-HELIOS-OCP-MXFP-PEAK`；共享条件没有错误绑定到其中一条路径。31 TB HBM4 容量复用观察日条件，没有丢失限定。 |

## 结构化闭环与来源核对

24 个结构化 CSV（Comma-Separated Values，逗号分隔值）文件的表头与正式对应表逐字一致，合计 102 行非空片段；主键为空、重复或与正式库碰撞的记录均为 0。事实全部是 `direct_statement`，且每条事实都只有一个目标、一个规范值、至少一条断言和一个同目标同字段的要求。18 个事实 ID 与观察卡中的 18 个唯一事实 ID 全量相等。证据状态复算为 13 条 `single_source`、4 条 `corroborated` 和 1 条 `source_with_caveat`，与不同 source_id 数量及未决链一致。

九域完整度恰有 identity、physical、compute、numerics、memory、interconnect、special_engines、software 和 evidence 九行；special_engines 为 `not_applicable`，其余为 `partial`。包内没有派生指标、派生输入、单模组乘算或误迁移的 M2-NA 架构 backlog。预算内实际数量为 18 facts、22 assertions、6 condition sets、1 topology、2 links、17 requirements 和 9 completeness records。

来源最小集由三份一手内容版本构成。Helios 产品页承担参考设计身份、72 个 MI455X 和多数机架事实；MI400 产品页不可替代地承担精确 1.67 PB/s 及同页 peak-theoretical 定性；2026-01-05 CES 新闻稿不可替代地承担 up-to-3 AI exaflops 和 early-look 日期。移除任一来源都会丢失当前事实集或版本状态锚点，因此三源集合已通过独立反向移除核对。

固定 Helios HTML（HyperText Markup Language，超文本标记语言）为 282,127 字节，SHA-256（256 位安全散列算法）为 `ed1642ec9ec16f9a5db4a8956b367e9859a3b2f47f9b18fcfe441fc56c34c6b7`；固定 MI400 HTML 为 318,594 字节，SHA-256 `aa5603704c4d77d1e912a5921e289ccabaa45111bab209c2ce08975aedc58a7e`；复用的 CES HTML 为 120,072 字节，SHA-256 `c2d36db9db2f7d269dc4db51ba4125e4556dd666270c010ac715eed0d9e6009f`。三者都与访问入口（endpoint）记录一致。冻结 staging 共 32 个文件。DEC-025 逐行清单（manifest）采用的规范聚合 SHA-256 为 `9f87160dcafd5061abd1b01a57b5df2a63c2c662446bd3a436f2d9da5034fad5`：按相对路径的 Unicode 序数（ordinal）顺序排列 32 行，每行写成 `relative_path<TAB>byte_length<TAB>lowercase_file_sha256`，行间和末尾均用换行符（Line Feed，LF），对 3,213 字节、采用 UTF-8 编码且不含字节顺序标记（Byte Order Mark，BOM）的文本计算 SHA-256。修复代理的即时消息曾报告 `2f972e93fcad3ee39b9cf341b4431c0d223cf1aac09ced88433e08b152f3fe51`；我已复算出它使用同一批 32 个文件、同一顺序和同一文件哈希，但每行改用 `relative_path|byte_length|lowercase_file_sha256`，行间用 LF、末行不加 LF，对 3,212 字节文本计算。两个值只是序列化算法不同，不表示冻结内容不同；执行合同以本报告公开、并写入逐行 manifest 的 `9f87160d…` 口径为准。

## 选择运行语义签字

我允许 `SELRUN-M2W2-AMD-HELIOS-20260813.status` 从 `draft` 改为 `reviewed`。这是对 `manual-reverse-removal-v1` 三源选择结论的语义签字：事实集合、截止日、三个成员和不可替代理由均已独立核过。该许可不属于 DEC-025 的行级 `review_status` 迁移，也不授权改动选择运行的其他语义列。

同一行的 `review_status: draft → reviewed` 由独立的行级生命周期 manifest 授权；总控应在同一合并事务中分别执行这两种状态变化，并在差异检查中分开计数。

## DEC-025 行级生命周期签字

冻结包 102 行中，97 行当前为 `review_status=draft`，另有 5 行为 `needs_resolution`。逐主键清单位于 `审计/子代理交接/m2_review_helios_system_lifecycle_manifest.csv`，共 97 行，SHA-256 为 `263e4b176f2eb5cb73890d5d50ee8635d75e19af384ab56dbd1f03100a17b46b`。独立签字位于 `审计/子代理交接/m2_review_helios_system_lifecycle_signoff.md`。

5 条被排除的记录是同一条 3 AI exaflops 未决链：`COND-M2W2-AMD-HELIOS-AI-UNSPEC-20260105`、`ASSERT-M2W2-AMD-HELIOS-0011`、`FACT-M2W2-AMD-HELIOS-AI-EXAFLOPS-UNSPEC`、`REQ-M2W2-AMD-HELIOS-0008` 和 `PPATH-M2W2-AMD-HELIOS-AI-UNSPEC`。合并时这 5 行继续保留 `needs_resolution`。其余 97 行只允许按 manifest 把 `review_status` 从 `draft` 改为 `reviewed`，不得连带修改 `resolution_state`、`extraction_status`、`requirement_status` 或其他列。

## 新鲜验证证据

最终复核重新执行了 1,188 项只读包内检查，失败为 0。检查覆盖 24 个表头、逐表计数、主键、外键、目标和值的唯一性、事实、断言、要求与卡片闭环、证据状态、九域完整度、B1 至 B5、最小来源集、预算、固定文件字节与哈希。行级 manifest 又执行 98 项独立回查，确认 97 个“表名 + 主键”唯一、全部来自冻结包的 `draft` 行，并且完整覆盖全部 97 条 `draft` 记录，失败为 0。

把 102 行片段追加到受控临时正式副本后，官方校验器通过：

```text
PASS: 32-table research data model; 93775 checks executed.
Registry: 323 columns, 488 enum values.
```

临时目录已删除并确认不存在。正式 32 张 CSV 在临时校验前后逐文件核算，变化数为 0；冻结 staging 的 32 个文件前后变化数也为 0。

第一次临时校验只复制了 32 张 CSV 和最小参考资料库快照，没有复制正式访问入口所指向的 25 份本地 PDF（Portable Document Format，便携式文档格式），校验器因此报告 25 个本地文件缺失。这是临时副本构造不完整的操作错误，不是待合并数据错误、沙箱拒绝、用户拒绝、审批失败或远端服务错误。补齐这 25 个只读来源文件后，同一临时副本通过上述 93,775 项检查；没有为绕过错误而改写任何数据。

## 总控合并边界

合并前应重算冻结包聚合哈希和 manifest 哈希；任一不符，本签字自动失效。总控须先备份正式目标表，再追加 102 行，按 manifest 迁移 97 行 `review_status`，保留 5 行 `needs_resolution`，并单独执行选择运行语义 `status: draft → reviewed`。合并后逐表确认只有获准状态变化，随后运行正式 32 表校验器，并重新生成该事实集合的正式反向移除记录。

根 `README.md` 和 `AGENTS.md` 已只读检查。本次只增加独立复核、生命周期清单和签字，没有改变项目目标、目录职责、正式数据、全局进度或长期约定，因此未修改两份根文档。正式合并完成后，由总控按项目规则同步 README、AGENTS、当前状态、任务台账、里程碑和验收记录。
