# M2-W2-AMD-HELIOS-SYSTEM 暂存包

- 状态：`ready_for_independent_review`
- 工作包：`M2-W2-AMD-HELIOS-SYSTEM`
- 主对象：`OBJ-AMD-HELIOS-72-MI455X`
- 写入边界：只写本目录，不改正式 CSV、正式资料卡或全局文档
- 资料截止日：2026-08-12；动态页面快照取得日：2026-08-13

## 这次交付了什么

本包已经固定 AMD Helios 产品页和 AMD Instinct MI400 页面，并通过对象身份、“72 个 MI455X”、日期状态与 rack 直报规格四道来源门。两页均为 AMD 官方 HTML，HTTP 状态为 200；本地快照的字节数、SHA-256、Last-Modified 和逐项定位见 `source-freeze-register.csv` 与 `identity-and-72-gate.md`。

轻量观察卡共有 18 条 rack 级直接事实、22 条逐来源断言和 17 条字段要求。事实覆盖身份与参考设计边界、72 个 MI455X、三种厂商直报算力口径、HBM4 容量与机架内存带宽、scale-up 和 scale-out 的协议与带宽、UALoE 多平面交换网络及 GPU 全互达描述，以及液冷。没有派生事实，也没有把单模组规格乘以 72。

## 已核输入与对象边界

已完整读取 `m2_wave2_independent_review.md`、`m2_wave2_queue_audit.md`、`m2_nvidia_amd_batch_plan.md`，并核对正式 `objects.csv`、`object-relations.csv`、M2 对象范围映射、M2-NA 来源与入口、M2-NA 实现对象待办以及 AMD CES 2026 固定快照。

正式边界保持不变：Helios 是 `rack / reviewed` 观察对象，MI455X 是 `module / reviewed`，CDNA 5 是 `architecture_generation / reviewed`。本包只使用既有关系 `OREL-AMD-HELIOS-CONTAINS-MI455X` 和 `OREL-AMD-MI455X-IMPLEMENTS-CDNA5`，不新增对象或关系，也不迁移 M2-NA 架构 backlog；迁移行数为 0。

## 来源门结论

Helios 产品页第 11208 行同时支持参考设计身份、double-wide ORW rack 和 72 个 MI455X；第 11268 行说明它不是销售产品；第 11288 行写的是 2026 年下半年预计规模部署。MI400 页面第 6935 行再次直接写出 72，第 7531 行给出机架 1.67 PB/s 内存带宽，第 8252 行把同一指标定性为 “up to 1.7 PB/s Peak Theoretical Memory Bandwidth”。结构化事实继续保留 1.67 这个精确原值，1.7 只作理论峰值口径说明。已有 CES 2026 快照提供 2026-01-05 的 early-look 日期锚点和单机架 3 AI exaflops 原词。

据此，产品状态只规范为 `announced`。`expected in 2H 2026` 不能上卷为 available、production_ramp 或已经交付。“AI exaflops”没有数据格式与运算计数定义，因此单列 `PPATH-M2W2-AMD-HELIOS-AI-UNSPEC` 并保持 `needs_resolution`；不把它等同于 OCP MXFP4 或 MXFP8。

MI455X 独立产品页没有固定，登记为 `deferred_out_of_scope`。这不是访问失败，也不是“未公开”：当前三道关键门已由对象匹配的 rack 页面、MI400 页面与带日期 CES 新闻稿覆盖，而 module 数值又明确不在本包抽取范围。

## 结构化片段

`structured/` 保留与正式 32 表完全相同的表头。非空片段如下：

| 片段 | 行数 | 作用 |
|---|---:|---|
| `facts.csv` | 18 | 全部为 rack 直报或直接规范化事实 |
| `fact-assertions.csv` | 22 | 每条事实至少一条短摘录、原值与本地定位 |
| `field-requirements.csv` | 17 | 每组 subject-field 恰有一条 `value_available` 要求 |
| `card-completeness.csv` | 9 | 九域完整度；special engines 对 rack 观察卡为不适用 |
| `condition-sets.csv` | 6 | 两条 OCP precision path 共享计算条件；HBM4 容量复用观察日条件；带宽保留未决口径 |
| `components.csv`、`memory-levels.csv` | 2、1 | 逻辑机架聚合组件，不代表新物理单元 |
| `precision-paths.csv` | 3 | AI-unspecified、OCP MXFP4、OCP MXFP8 分开 |
| `links.csv`、`topologies.csv` | 2、1 | scale-up、scale-out 与多平面 switched-fabric 规范化 |
| 来源与选择相关片段 | 21 | 两个新来源版本、四个入口、筛选、覆盖、六条来源角色与三源最小集草案 |

`derived-inputs.csv`、`derived-metrics.csv`、`special-capabilities.csv`、`search-log.csv`、`search-results.csv` 和 `requirement-evidence.csv` 只有正式表头，没有数据行。本包没有为了凑足 18 条而增加无关事实。

## 最小来源草案

本包选择三份一手材料。Helios 产品页是对象匹配的主来源，移除后会失去参考设计边界、72 数量和大部分 rack 规格；MI400 页面保留唯一的 1.67 PB/s 机架内存带宽，并给 OCP MXFP4、MXFP8 与 72 的交叉支持；CES 2026 新闻稿同时承担 `core_spec` 和 `status_version_evidence` 角色，移除后会失去 3 AI exaflops 的唯一直接证据，以及 2026-01-05 dated early look。MI400 与 Helios 的重叠已登记为 `partially_covered`，没有把重复内容误当成保留理由。

选择运行 `SELRUN-M2W2-AMD-HELIOS-20260813` 仍是 `draft`。本次修复后已重跑人工反向移除，三源集合仍为最小集；最终独立签字前不能改成 reviewed。事实集合或页面内容哈希再次改变时必须重跑。

## 独立复核修复

独立复核提出的五项问题已经在 staging 内修正。拓扑从 `fully_connected` 改为 `switched_fabric`，原文中的 multi-plane network 和 all-to-all reachability 分开保留；scale-up 与 scale-out 的 `performance_basis` 改为 `vendor_label_unresolved`。HBM4 带宽断言同时定位 1.67 PB/s 精确值与 1.7 PB/s 理论峰值定性，四条 OCP MXFP4/MXFP8 断言也补入 AMD 计算脚注和系统配置可变条件。

条件集从 8 行减到 6 行：MXFP4 与 MXFP8 仍是两条 precision path，但共同引用 `COND-M2W2-AMD-HELIOS-OCP-MXFP-PEAK`；31 TB HBM4 容量复用观察日条件。CES 新闻稿增加 `core_spec` 来源角色，反向移除理由同时覆盖 3 AI exaflops 唯一证据和 dated early-look 状态锚点。正式表和正式资料卡没有改动。

## 校验与已知风险

修复后包内检查覆盖表头、18 条事实上限、事实目标唯一、断言原值二选一、短摘录与定位、事实、断言、要求和卡片之间的闭合、6 条件集上限、来源角色、空表和本地快照哈希，共 438 项，错误为 0。临时正式副本合并 102 行非空片段后，官方 32 表校验器通过 93,775 项检查。临时目录已经删除，正式 32 张 CSV 前后哈希变化为 0，两份固定快照仍在本包中。

当前风险集中在三个地方：产品页仍会变化，Helios 仍处于预期部署阶段，部分口径也没有公开完整条件。3 AI exaflops 的数据格式未知；MXFP4 与 MXFP8 未说明稠密或稀疏，系统厂商配置也可能不同；1.67 PB/s 的方向未说明，260 TB/s 和 43 TB/s 还缺方向、有效载荷及理论峰值/持续值分类。all-to-all 只说明 GPU 全互达，不能推成完全图物理直连、单跳或无阻塞。卡片保留这些条件，不做补推。

固定过程中，PowerShell 首次请求没有生成文件且缺少可用诊断，按工具或运行时失败记录；`curl` 的 `SEC_E_NO_CREDENTIALS` 是本机 Schannel 凭据运行时错误；首次 Python 保存路径乱码是命令构造与编码处理错误。随后改用 ASCII 文件名成功固定两页。没有沙箱拒绝、审批拒绝或远程 HTTP 错误。清理临时校验目录时，PowerShell 对 junction 单独删除报 `NullReferenceException`，但受控父目录删除成功，且两个链接目标均复核未受影响。

## 文件清单

- `object-scope.csv`：三个正式对象在本包中的角色与冻结边界
- `source-freeze-register.csv`：来源 URL、本地路径、日期、HTTP、字节数与哈希
- `identity-and-72-gate.md`：四道来源门及禁止推导
- `fixed-candidates/`：两份 AMD 官方 HTML 固定候选
- `structured/`：与正式表同表头的轻量片段
- `card-draft/AMD_Helios_72_MI455X_参考机架观察卡.md`：18 条事实的观察卡草稿
- `validation-report.md`：校验、自然化与剩余风险记录

根 `README.md`、根 `AGENTS.md`、研究计划、进度、正式表和正式资料卡均已检查，无需修改：这次交付受限于子代理 staging，项目目标、全局结构和正式状态没有改变。