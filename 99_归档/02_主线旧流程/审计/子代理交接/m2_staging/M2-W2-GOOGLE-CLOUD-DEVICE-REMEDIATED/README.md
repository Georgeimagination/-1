# M2-W2-GOOGLE-CLOUD-DEVICE-REMEDIATED

状态：`ready_for_independent_review`  
资料截止日：`2026-08-13`  
写入边界：全部修改都在本修复包内；没有改正式 CSV、正式资料卡、索引或全局文档。

## 修复结果

TPU（Tensor Processing Unit，张量处理器）v5e、v5p、v6e 的对象范围结论不变。总控已经依据上一轮独立复核，在正式库中以 `needs_resolution` 预留三枚 `cloud_accelerator` 对象及三条 `implements_architecture` 关系。本包只引用这些正式主键，不重复导入，也不改变其状态。

来源部分已按复核意见重做。G05、G08、G09、G10、G15 和 `tpu-machines` 现在处于同一器件候选池。`tpu-machines` 的 `L624-L639` 直接列出 v5p、v6e 的每芯片规格，因此从 `out_of_scope` 改为 `selected`。本轮反向移除成员为 G08、G09、G10 和 `tpu-machines`；G05 与 G15 的本范围事实已按单一覆盖来源拆行，状态为 `redundant_covered`。

G15 的本地文件没有被补写成完整快照。它仍从 `L148` 开始，缺少正式定位使用的 `L69-L87`。普通权限和已批准的提权下载都在 TLS（Transport Layer Security，传输层安全）握手阶段失败，未生成原始响应体。G15 候选 endpoint 因而改为 `partial / pending_verification`，没有正式拟落路径，也不参与本轮选择成员。官方页面中的 Trillium 每芯片 2 个 SparseCore（稀疏计算核）规格，改由 `tpu-machines` 的固定内容承担；G05 继续提供独立交叉核对。错误分类与三路核验见 `remote-retrieval-log.md`。

## 对象、待办与配置边界

`object-scope-candidates.csv` 和 `relationship-candidates.csv` 记录总控已经完成的范围预留，便于独立复核核对主键、类型和关系方向。三枚对象仍只承接单器件事实；虚拟机（VM）、机器类型、slice 与 Pod 保持在配置或系统层。

14 条 GA 实现待办仍拆成 15 个持久处置项。九条完整项归云端器件，`DEF-M2GA-GV5P-03` 保留 95 GiB 云端分支和 96 GiB 物理 package 分支，其余四条 v5p 物理项继续等待 package 身份门。两条容量记录不合并，也不推导 1 GiB 预留。v6e 组件行的 2 个 SparseCore 来源已经从不可用的 G15 提取改为 `tpu-machines L624-L638`。

`configuration-row-dispositions.csv` 仍有七组配置落点，所有 VM 总 HBM（High Bandwidth Memory，高带宽存储器）、总芯片数、NUMA（Non-Uniform Memory Access，非统一内存访问）节点、Pod 算力和系统带宽都禁止写入器件。v5e 机器类型行已经移除 `tpu-machines` 来源，因为该页只列 TPU7x、v6e 和 v5p；v5e 的 `ct5lp-hightpu-*` 继续由 G08 等实际包含该代内容的页面支撑。

## 来源选择与覆盖

四个入选来源各有明确的移除后缺口。G08 承担 v5e 的对象边界和单器件规格；G09 保留 v5p 产品级 3D torus 条件；G10 提供 v6e 的 MXU（Matrix Multiply Unit，矩阵乘法单元）、INT8（8 位整数）、ICI（Inter-Chip Interconnect，芯片间互联）端口与 2D torus；`tpu-machines` 提供 v6e FP8（8 位浮点）、每芯片 DCN（Data Center Network，数据中心网络）和固定的 2 SparseCore 定值。G05 与 G15 不再被描述为全资料池唯一来源。

`source-selection-candidates.csv` 中每条 `coverage_candidate` 只登记一个 `paired_source_ids`。没有把 G09、G10 与 `tpu-machines` 的组合写成任一单源全文覆盖。G15 的 96 GiB 留在物理 package 边界，32 GiB 也不与 G10 的 32 GB 原值合并。

## 包内文件

| 文件 | 用途 |
|---|---|
| `object-scope-candidates.csv` | 三枚已预留对象的范围引用 |
| `relationship-candidates.csv` | 三条已预留架构关系的范围引用 |
| `deferred-dispositions.csv` | 14 个父待办拆成 15 个持久处置项 |
| `configuration-row-dispositions.csv` | 机器类型、slice 与 Pod 的落点规则 |
| `source-candidates.csv` | `tpu-machines` 来源候选、五个可用提取和一个 G15 局部提取 |
| `source-selection-candidates.csv` | 六源器件候选池、单源覆盖与反向移除候选 |
| `source-freeze.md` | URL、访问日、哈希、拟落路径与来源门状态 |
| `remote-retrieval-log.md` | OpenXLA 补取错误分类和三路对抗核验 |
| `snapshots/2026-08-13/` | 六份本地提取文件；其中 G15 仅为局部提取 |
| `merge-instructions.md` | 总控可接收项、禁入项和临时验证顺序 |
| `Validate-Package.ps1`、`validation-report.md` | 包内校验器与实跑结果 |
| `handoff.md` | 任务状态、写入、未关闭事项和复核顺序 |
| `package-manifest.csv`、`package-freeze.sha256` | 最终包文件清单、逐文件哈希和清单哈希 |

## 独立复核边界

独立复核可检查来源门和候选选择，但本包不能直接生成器件 facts 或资料卡。五个可用提取只能按 `other / non-preferred` 处理，notes 必须说明它们是 renderer 提取而非上游响应体。G15 endpoint、全部配置事实、物理 package 分支和三张器件卡仍禁止合并。事实集合或任一来源文件哈希变化后，必须重新执行反向移除。

根 `README.md` 和 `AGENTS.md` 已只读检查。本修复包没有改变项目目标、目录职责或正式项目规则，因此未修改这两个文件。