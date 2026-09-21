# M2 Google Cloud TPU 器件范围与来源冻结独立复核

- 复核状态：`completed`
- 复核日期：2026-08-13
- 复核对象：`审计/子代理交接/m2_staging/M2-W2-GOOGLE-CLOUD-DEVICE/`
- 总裁决：`accept_with_caveat`
- 写入边界：只写本报告；未修改 staging、正式 32 表、资料卡或全局进度文档

TPU（Tensor Processing Unit，张量处理器）v5e、v5p、v6e 三个云端单器件对象及三条架构关系可以进入总控范围补验收。它们只能先以 `needs_resolution` 预留。来源部分还不能整体接收：OpenXLA SparseCore 的 G15 本地提取缺少承担证据的前 148 行，`tpu-machines` 又被错误排除在器件事实范围之外。因此，原始响应体门继续为 `pending`，G15 提取 endpoint（访问入口）和本包的来源筛选、覆盖、四源反向移除候选均不得写入正式库。

## 分门裁决

| 子门 | 裁决 | 允许的动作 |
|---|---|---|
| 三个 `cloud_accelerator` 对象 | `accept` | 总控可补范围验收，并以 `needs_resolution` 预留三枚对象 ID |
| 三条 `implements_architecture` 关系 | `accept` | 可随对象预留；关系方向为器件指向已验收架构 |
| 14→15 deferred 处置 | `accept` | 作为审计处置保留；不能直接转换成正式 facts |
| 七组机器类型、VM、slice/Pod 配置落点 | `accept_with_fix` | 分层规则成立；先修正 v5e 行对 `tpu-machines` 的错误来源映射 |
| `tpu-machines` family/source/endpoint 标识 | `accept_with_caveat` | 标识可预留；source 保持待核，提取 endpoint 只能是 `other / non-preferred` |
| 六个渲染器文本提取 endpoint | `partial_accept` | G05、G08、G09、G10 和 `tpu-machines` 五行可作为非首选内容提取候选；G15 当前文件不得接收 |
| 器件范围筛选、覆盖与四源反向移除 | `reject_for_formal_merge` | 修正来源范围后重跑；当前候选不得追加到正式选择表 |
| 上游原始响应体 | `pending` | 六个提取文件都不能标成 `web_snapshot`，也不能宣称是上游响应体 |

## 对象和关系

三个产品页都明确区分单芯片规格与 VM（Virtual Machine，虚拟机）、机器类型、slice 或 Pod 配置。v5e 提取的 `L136`、`L140`、`L144`，v5p 的 `L136`、`L138`、`L145-L157`，以及 v6e 的 `L136`、`L138`、`L143-L152`，分别支持三个云端器件身份和单器件边界。

独立复算确认：`cloud_accelerator` 和 `implements_architecture` 都是已批准枚举；三枚对象 ID、三个 slug、三枚关系 ID 与三个关系指纹在正式库中的碰撞数均为 0；每个对象恰有一条候选关系，关系 object 端与对象行登记的架构 ID 一致；三个架构端点均存在且为 `reviewed`。关系方向如下：

| subject | relation_type | object |
|---|---|---|
| `OBJ-GOOGLE-TPU-V5E-CLOUD-DEVICE` | `implements_architecture` | `OBJ-GOOGLE-TPU-V5E-ARCH` |
| `OBJ-GOOGLE-TPU-V5P-CLOUD-DEVICE` | `implements_architecture` | `OBJ-GOOGLE-TPU-V5P-ARCH` |
| `OBJ-GOOGLE-TPU-V6E-CLOUD-DEVICE` | `implements_architecture` | `OBJ-GOOGLE-TPU-V6E-ARCH` |

对象范围门可以接收，但不等于器件事实包已经通过。本包没有 facts 或资料卡正式片段，也没有证明物理 package 与云端器件之间的 `exposed_as_cloud_accelerator` 关系。

## deferred 与 95/96 GiB 边界

原 `M2-GA-ARCH_实现对象待办.csv` 中 v5e、v5p、v6e 共 14 个父待办。包内处置表逐项覆盖这 14 个主键，没有遗漏或额外父项；只有 `DEF-M2GA-GV5P-03` 拆成两行，因此得到 15 个持久处置项。

| 去向 | 数量 | 内容 |
|---|---:|---|
| 完整云端器件项 | 9 | v5e 四项、v5p 一项、v6e 四项 |
| 云端分支 | 1 | `95 GiB`，来源 `SRC-M2-GA-G09`，目标 v5p 云端器件 |
| 完整物理 package 项 | 4 | v5p 的 `01`、`02`、`04`、`05` |
| 物理分支 | 1 | `96 GiB`，来源 `SRC-M2-GA-G01`，等待物理 package 身份门 |

两条分支均保留原值、来源和作用域，notes 都明确禁止推导 `1 GiB` 预留。当前证据没有说明 95 与 96 GiB 的差值原因；拆成两个对象候选也没有消除这项作用域歧义。两个 `boundary_member` 可以继续留在审计层，但其 `conflict_evidence` 标签不能直接生成正式冲突组或冲突来源角色，除非以后证明对象、条件和有效期一致。

## 七组配置的落点

七组配置行完整覆盖 v5e、v5p、v6e 的机器类型及 slice/Pod 范围。七行的 `device_value_action` 都是 `do_not_write_to_cloud_accelerator`。机器类型的 vCPU、主机内存、网络接口、NUMA（Non-Uniform Memory Access，非统一内存访问）节点、每 VM 芯片数和总 HBM（High Bandwidth Memory，高带宽存储器）不会下沉到单器件；slice/Pod 的拓扑、总芯片数、总算力和系统带宽也不会下沉。

命名机器类型在导入独有参数前升为独立 `cloud_instance`，再把数量写到各自的 `instance_contains_accelerator` 关系，这个规则正确。现有 `OBJ-GOOGLE-CT6E-STANDARD-FAMILY` 只作分组容器，不在家族关系或 notes 中塞入 1、4、8 芯片数量，也符合 DEC-024。`OREL-GOOGLE-CT6E-STANDARD-FAMILY-CONTAINS-V6E-DEVICE` 仍是后续配置范围候选，不属于本次三条架构关系的可合并集合。

这里有一项来源映射需修正：`CFGDISP-GOOGLE-V5E-MACHINE-TYPES` 同时列了 G08 和 `tpu-machines`。本地 `tpu-machines` 提取在 `L518-L523` 明确只列 TPU7x、v6e、v5p，后续机器类型表也没有 v5e；v5e 的 `ct5lp-hightpu-*` 行只能由 G08 等实际包含 v5e 的页面支持。删除该行中的 `SRC-M2-W2-G-TPU-MACHINES-20260813` 不改变配置落点结论。

## 来源标识与 endpoint

`tpu-machines` 的 family、source、远端入口和内容提取共四个建议 ID 在包内各出现一次，在正式 family/source/endpoint 表中的碰撞数均为 0。`dynamic_page_history`、`cloud_service_documentation`、`html_page` 和 `other` 都是已批准枚举，父子引用闭合，来源类型合理。

六个带本地路径的候选行在元数据层全部满足要求：`endpoint_type=other`、`is_preferred_endpoint=false`，notes 逐字为 `renderer-extracted text wrapped as HTML / not upstream response body`。六个文件的字节数和 SHA-256（安全哈希算法）均与候选表一致，没有任何一行使用 `web_snapshot`。

元数据一致不代表正文完整。`openxla-sparsecore-2026-08-13.html` 的首个页面行标记是 `L148`，文件中没有 `L0-L147`，也检索不到 `Trillium`、`v6e`、`96 GiB` 或 SparseCore 代际数量表。正式 G15 断言原本定位到该页面 `L69-L87`，恰好落在缺失区间。文件仍与登记的 36,858 字节和哈希 `9F77BA67B06EA8B3091B2842157F6422E261A5D076ACDA1A7203832529935AAD` 一致，这只能证明文件没有在登记后变化，不能证明它覆盖了声称的证据。`source-freeze.md` 中“完整抽取到正文第 409 行”和“G15 已固定并支撑 v6e 2 个 SparseCore”的结论目前不成立。

因此：

- `END-M2-GA-G15-EXTRACT-20260813` 不得按当前内容以 `accessible` 正式接收。应重新取得包含 `L69-L87` 的完整提取；若只保留现文件，则 notes 必须明确写成 `partial extract`，且 `accessibility_status` 保持 `pending_verification`，不能支撑 G15 事实。
- G05、G08、G09、G10 和 `tpu-machines` 五个提取文件包含本门所需正文，可以作为 `other / non-preferred` 内容提取候选。它们仍不是上游响应体。
- `END-M2-W2-G-TPU-MACHINES-PRIMARY` 可以作为远端 `html_page` 入口候选预留，但不能据此宣称已经保存原始响应体。

## 筛选、覆盖与反向移除

当前四源候选为 G08、G09、G10、G15。G08 对 v5e 的不可替代作用成立。G09、G10 和 G15 的筛选说明还没有覆盖整个候选来源池：`tpu-machines` 在 `L624-L639` 直接列出 v5p、v6e 的每芯片峰值、HBM、TensorCore、SparseCore 和双向 ICI（Inter-Chip Interconnect，芯片间互联）带宽。它不是器件事实范围的 `out_of_scope` 来源，只是没有提供新的独有定值。

正式筛选前应把 `SCREEN-M2W2-G-TPUMACH-DEVICE` 改为以下两种状态之一：若产品专页和 G15 承担最终事实，就将其标为 `redundant_covered` 并逐事实登记覆盖；若它承担机器类型交叉核对外的器件规格角色，就标为 `selected`。当前 `out_of_scope` 结论及其理由不能保留。

这项修正不必强迫选择绝对篇数最少的集合。四源方案仍可能在对象匹配和定位更强的前提下成立，但必须把 `tpu-machines`、G05 和 G15 放进同一个候选池重跑反向移除。G05 在 `L211` 也直接给出 v6e 的 2 个 SparseCore，G15 的不可替代理由只能相对于最终入选集合成立，不能写成全资料池唯一支持。再加上 G15 本地提取缺页，当前四源 selection run、G05 组合覆盖束和 G15 member 均不能签为 `reviewed`。

G05 的组合覆盖候选仍不能直接追加到正式 `source-coverage.csv`；该表每行只有一个 `covering_source_id`。总控应在事实集合冻结后按具体覆盖范围拆行，不能把多源组合改写成任一单源“全文 fully covered”。

## 独立验证

包内脚本原样运行，得到：

```text
PASS: M2-W2-GOOGLE-CLOUD-DEVICE preparation package; 106 checks executed.
Scope: 3 cloud_accelerator candidates, 3 implements_architecture relations, 15 deferred dispositions, 7 configuration groups, 6 hashed content extracts.
```

我另行复算了对象、slug、关系 ID 和指纹碰撞，枚举存在性，14 个父待办到 15 个处置项的集合等价，七组配置的器件禁写标记，九个来源候选 ID 的唯一性和父子引用，以及六个本地文件的字节数、哈希、endpoint 类型、首选状态和 notes。结果与脚本的结构检查一致。包内 17 个文件按相对路径、字节数和小写 SHA-256 汇总后的聚合哈希为 `d046da25119e63b227902a49d6d4002b29c5e9889e961ee69b0e270f87ccc9b0`。

106 项通过没有覆盖两类语义检查：它只核对 G15 文件是否存在且哈希匹配，没有检查证据行是否真的在文件内；它还强制检查 `tpu-machines=out_of_scope` 候选行存在，却没有读取该页面的 per-chip 表。因此，这两个发现与 106 项 PASS 不矛盾。

复核开始时，正式 32 个 CSV 的只读校验为：

```text
PASS: 32-table research data model; 93131 checks executed.
Registry: 323 columns, 488 enum values.
```

同一时段按“相对路径、字节数、小写 SHA-256”聚合得到 `e060d53fc6afa2734b675a890c7319b3f0d349df731c1fba6173b87c7fc1ec10`。复核过程中，总控执行了已验收的 Trainium2 后置生命周期迁移；计划内变化只涉及 `最小参考资料库/selection-runs.csv` 和 `最小参考资料库/selection-members.csv`，覆盖清单中的 25 行、27 个状态单元格，没有越界，另外 30 张正式表的文件哈希不变。相关验收和独立签字分别见 `审计/M2_Trainium2_纠错包正式合并验收.md` 与 `审计/子代理交接/m2_review_trn2_correction_postmerge_signoff.md`。这项并发正式更新不是本复核造成的。

迁移完成并静止后，我重新运行正式校验器：

```text
PASS: 32-table research data model; 93179 checks executed.
Registry: 323 columns, 488 enum values.
```

正式 32 个 CSV 的新聚合哈希为 `9b16a100c4cb7af0f0b9966ba5f7003bf326e26fa51df1e69d9e942f639571a2`；复算后保持不变。本复核没有写入 staging 或正式 32 表。

第一次独立枚举查询误用了不存在的 `enum_group` 列，得到空结果。这是只读查询的操作者构造错误；改用正式列名 `enum_name` 后复算通过，没有写文件。重建聚合格式时，一次只读穷举命令因重复计算文件哈希，在 60 秒后超时；缓存文件元数据后复算成功。最终复算中还误用了当前 .NET 版本不提供的静态 `SHA256.HashData`，改回兼容的实例方法后得到同一哈希。这两项分别属于命令效率问题和操作者的运行时兼容性判断错误，均未写文件。除此之外，没有发生用户拒绝、沙箱拒绝、审批失败或远端服务错误。

## 正式预留边界

总控完成范围补验收后，可以预留三枚对象和三条架构关系，状态保持 `needs_resolution`。`tpu-machines` 的 family/source/远端入口/内容提取 ID 也可以预留；source 和上游响应体状态继续待核。G05、G08、G09、G10 与 `tpu-machines` 的五个内容提取 endpoint 可按 `other / non-preferred` 接收，notes 和非上游响应体边界必须原样保留。

以下内容当前不能写入正式库：G15 内容提取 endpoint；任何把六个本地文件记作 `web_snapshot` 或上游响应体的记录；本包的 screening、coverage、selection run 和 selection members；七组配置事实、CT6E 家族包含关系和任一 slice/Pod 对象；15 个 deferred 处置向 facts 的直接转换；三张器件卡或器件事实。G15 完整提取和来源范围修正完成后，应由未参与修复者复核，再决定来源门是否升为 `accept`。

## 输入与写入

本复核读取了根 `AGENTS.md`、`研究计划.md`、DEC-024、两份 Google 三层模型报告、v5e/v5p/v6e 正式架构卡、14 条相关 GA deferred、本包全部 17 个文件，以及正式对象、关系、枚举和来源表。唯一写入文件为 `审计/子代理交接/m2_review_google_cloud_device_gate.md`。根 `README.md` 与 `AGENTS.md` 仅只读检查；本复核没有改变项目范围或正式状态，因此不修改。