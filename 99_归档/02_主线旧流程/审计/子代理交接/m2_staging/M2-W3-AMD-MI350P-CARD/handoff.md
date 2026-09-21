# M2-W3 AMD MI350P PCIe 卡交接

- 任务状态：`ready_for_final_independent_review`
- 截止日：2026-08-13
- 对象：`OBJ-AMD-MI350P`，`card`
- 既有关系：`OREL-AMD-MI350P-IMPLEMENTS-CDNA4`
- 写入范围：仅 `审计/子代理交接/m2_staging/M2-W3-AMD-MI350P-CARD/`

## 已完成

身份门通过后，本包建立 1 张卡片草稿、26 份同表头结构化片段、来源筛选与反向移除、逐来源断言、缺口检索、九域完整度以及验证记录。定点修正后的事实集合为 40 条直接事实；49 条断言全部 `source_checked`。46 条字段要求中有 34 条 `value_available`、12 条 `not_found`。新增的是 73 Billion 晶体管事实、产品页断言和字段要求。

新增来源候选仍为三个：MI350P 精确产品页、固定产品简报 `LE-93401-00 05/26`、2026-05-07 官方文章。三条向量峰值的断言责任已从缺少 vector 标签的产品页改绑到简报第 1 页；产品页保留矩阵峰值和晶体管等卡级规格。对象级最小集只含这三个来源。CDNA 4 白皮书与 ISA 改为 `lead_only`，继续用于边界与缺口检索，不再作为 selection member、selected role 或 coverage 成员。D-1/D-7 完成身份门后只保留审计角色。

MI350X、MI355X OAM、8-OAM 平台、服务器最多八卡、机架聚合值和 CDNA 4 每 CU 事实迁移量为 0。没有派生指标、占位 capability 或 topology。

## 验证

- 包内检查：1,082 项，0 error；事实主体合同不一致 0，字段要求目标合同不一致 0；
- 临时正式合并：f152 基线上 `gate` 模式 111,343 项通过，324 columns / 488 enum values；
- 完整度：9 行、9 域；
- 新来源/endpoint：3/6，固定本地入口哈希一致；
- 临时镜像：已删除；
- 正式 32 表：f152 基线前后逐文件哈希不变；临时镜像清理后，正式库再次通过 106,160 项 `gate` 检查。

初次建包曾修复 raw value XOR、缺省 assertion relation、未注册 coverage scope、镜像快照映射，以及 PowerShell 标量/数组和脚本编码问题。本轮定点修正又出现过一次 Windows 命令行长度超限、数次锚点或数组写法错误，以及 UTF-8 无 BOM 被 Windows PowerShell 5.1 误读的问题；这些分别属于命令构造/运行时限制和执行者操作错误，不是用户拒绝、审批失败、沙箱拒绝或远端服务故障。受影响步骤均在写后校验中修正，最终生成、包级校验和临时合并已重新通过。

## 仍待复核

最终独立复核需要逐项检查：73 Billion 晶体管是否只落在单卡对象；available 的日期解释是否保持“最早证据日而非首次供货日”；Passive 与 air-cooled systems 是否继续按卡/服务器分层；16 条峰值的矩阵/向量、FLOP/s/OP/s、基础/结构化稀疏和理论峰值条件；三条向量断言是否由简报直接承担；A/B/product/accumulate/output 缺口；PCIe 128 GB/s 的方向未说明；三来源最小集是否确有不可替代性。

## 写入文件

本包全部文件可由 `validation/staging-file-manifest.csv` 复核。主要交付是：

- `README.md`
- `handoff.md`
- `card-draft/AMD_Instinct_MI350P_PCIe_卡资料卡.md`
- `structured/` 下 26 份 CSV
- `source-and-fact-audit.md`
- `source-identity-preflight.md`
- `source-freeze-register.csv`
- `fixed-candidates/` 下 5 份固定候选
- `validation/package-validation-result.json`
- `validation/temporary-formal-merge-result.json`
- `validation/formal-32-csv-baseline.csv`

本包没有修改正式资料卡、正式 32 表、README、AGENTS、研究计划或全局进度文件。