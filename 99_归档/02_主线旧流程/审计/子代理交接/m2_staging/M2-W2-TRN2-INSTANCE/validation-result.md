# M2-W2-TRN2-INSTANCE 校验记录

- 状态：`ready_for_independent_review`
- 校验日期：2026-08-13
- 正式库：只读

## 包内结果

包内脚本完成 109 项检查，错误为 0。检查包括 32 张 structured CSV 与正式表头一致、映射行和正式外键、三卡 fact_id 双向覆盖、九域完整度、来源分布、S07 endpoint 日期与哈希，以及必须为空的正式事实片段。

| 检查 | 结果 |
|---|---|
| `card-fact-map.csv` | 48 行；三个 `owner_object_id` 分布为 4 / 23 / 21 |
| `card_id` 和 `owner_object_id` 空值 | 0 |
| 映射 fact_id 重复或正式库缺失 | 0 / 0 |
| 每条映射事实的正式断言 | 恰 1 条，共 48 条，均复用正式记录 |
| 三张卡漏引映射 fact_id | 0 |
| 九域完整度 | 27 行；三对象各 9 域 |
| 系统层排除 | `FACT-AWS-TRN2-ULTRA64-INSTANCE-QTY` 与 `REQ-AWS-TRN2-0092` 各 1 条 |
| staging `facts` / `fact-assertions` / `field-requirements` / `object-relations` | 0 / 0 / 0 / 0，未复制正式记录 |
| 来源断言分布 | S06=33、S07=4、S09=1、S10=8、S15=2 |
| S07 新快照 | 487,377 bytes；SHA-256 `94ceea74234b30d6568127badd6a4df68a46b861d1d989c21463fea3b0690edb`，本地复算一致 |

## endpoint 与 source 合并边界

`structured/source-endpoints.csv` 有两行：

- `END-AWS-TRN2-S07-SNAPSHOT` 是 `update_existing_pk`，只把 `is_preferred_endpoint` 改为 `false`；保留 2026-08-12 的 access/snapshot 日期、路径和哈希。
- `END-AWS-TRN2-S07-SNAPSHOT-20260813` 是 `append_new_pk`，`access_date` 与 `snapshot_date` 都是 2026-08-13，`is_preferred_endpoint=true`。

两条动作另在 `sources/endpoint-merge-plan.csv` 明确分流，不能一起按 append 合并。

`structured/sources.csv` 保持 0 行。2026-08-13 原始 HTML 与前一日只差两行 nonce，归一化内容一致，但原始哈希不同。为保护旧断言的内容版本稳定性，本包不改 `SRC-AWS-TRN2-S07` 的 `observed-2026-08-12`、旧 `content_fingerprint` 或 `last_verified_date`，也不新建 source version；只新增 endpoint，并在 `sources/source-merge-plan.csv` 记录 `no_source_row_change`。这项判定仍需独立复核。

## 临时正式合并

第一次临时验证直接复制 32 表和最小参考资料库，因临时根目录没有正式 PDF 与审计快照路径而报 25 个 endpoint 文件缺失。该结果属于临时验证环境构造不完整，不是 staging 数据、沙箱、审批或远程服务错误。

随后在受控临时根目录为正式 `论文/`、`审计/`、`资料卡/` 和 `清单/` 建只读 junction，再按 PK 更新 S07 旧 endpoint、追加新 endpoint，并追加 27 条完整度、5 条筛选、4 条来源角色、1 个选择运行、4 个成员和 1 条覆盖关系。`Validate-ResearchData.ps1` 结果为：

```text
PASS: 32-table research data model; 92374 checks executed.
Registry: 323 columns, 488 enum values.
```

正式根目录随后单独验证：

```text
PASS: 32-table research data model; 91827 checks executed.
Registry: 323 columns, 488 enum values.
```

临时目录 `.validation-temp-merge` 已在确认绝对路径属于本包后删除。正式对象、关系、事实、字段要求、断言、sources 和 endpoints 的终检行数及哈希为：

| 正式文件 | 行数 | SHA-256 |
|---|---:|---|
| `数据/objects.csv` | 75 | `13A001E67F8BA83D5A236A75F51AAB5454E690174BF421A3E663786180334BEC` |
| `数据/object-relations.csv` | 24 | `6102A347F1A7575BBB9DB23701F93DE85D0DFD1CC32D729A0A2F7E2FF257B116` |
| `数据/facts.csv` | 614 | `634ABA9D93229219DDD4DA9952612E97841C1937C9D032B45FA4C3FF42F3DEA2` |
| `数据/field-requirements.csv` | 786 | `429DD029364820A8F5E428F62EDAF4C80AE692230AF13A7B7090EB1B32A4BC19` |
| `最小参考资料库/fact-assertions.csv` | 600 | `173BB2406374C25767AAFF6404BC2E9854E5EF133A154668AB167E9BE367C0BF` |
| `最小参考资料库/sources.csv` | 81 | `3FFF1FBFA2A880525432FF414CFB5CCEB2DB8BAA474D43A4BE97ADA767580C22` |
| `最小参考资料库/source-endpoints.csv` | 116 | `8DE1EE64763E2F2C7E24C995E776D343033D782F3C0458C1E4BE2B3515DF8D1A` |

这些正式文件没有被本包修改。

## 中文文档检查

README、三张实例卡、自检、来源选择说明和本校验记录均通过 `report-humanizer` 机器扫描，未发现可检测的 AI 写作痕迹。人工检查了标题、首段、表格引导、转场和结尾，没有发现空泛总结或机械对称结构。

随后按 `shuorenhua` 的 `docs / minimal` 口径完成事实保真回读。三对象 ID、48 条 fact_id、4/23/21 分布、51 条要求、来源数量、端点 update/append 方向、日期、字节数、SHA-256、状态枚举和包外责任均未漂移。回读中特别确认：49 条原始命中与 48 条实例事实的差异只来自 UltraServer 组成事实；S07 的 source 行保持不变；三卡没有把 package、architecture 或 system 事实复制成实例事实。没有人类风格样本可供比对，剩余风险只在内容裁决，交由独立复核处理。

根 `README.md` 与 `AGENTS.md` 已按只读方式检查。本包只写 staging，不改变正式项目状态、目录职责或协作规则，因此无需修改。
