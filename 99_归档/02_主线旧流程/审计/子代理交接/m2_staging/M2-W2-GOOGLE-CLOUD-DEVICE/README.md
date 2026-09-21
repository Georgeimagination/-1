# M2-W2-GOOGLE-CLOUD-DEVICE

状态：`ready_for_independent_review`  
资料截止日：`2026-08-13`  
写入边界：仅本 staging 包；未改正式 CSV、资料卡、索引、README、AGENTS、研究计划或进度。

## 结论

TPU v5e、v5p、v6e 可以分别建立 `cloud_accelerator` 对象，并各自通过 `implements_architecture` 指向已经验收的架构对象。三个产品页都先给出单芯片规格，再单列 VM、machine type、slice 或 Pod 配置，足以把单器件与系统聚合值分开。三对象与三关系的候选 ID、slug 和关系指纹在当前正式库中没有碰撞。

来源门按总控裁决记为 `accept_with_caveat`。六份 2026-08-13 内容提取文件已固定字节数和 SHA-256，包括独立复核补要求的 `SRC-M2-GA-G15`，以及新建来源候选的 `tpu-machines` 页面。它们是渲染文本包装成的 HTML，不是上游响应体；正式 endpoint 只能用 `other / non-preferred`，不能写成 `web_snapshot`，也不能替代原 `html_page`。这个限制不阻断三对象范围候选，但原始响应体 endpoint 仍待以后补齐。

## 对象与待办边界

`object-scope-candidates.csv` 给出三枚对象候选，`relationship-candidates.csv` 给出三条架构关系。正式预留时应先用 `needs_resolution`，独立复核和总控范围验收后再决定是否晋级。

14 条 GA 实现待办已经拆成 15 个持久处置项。九条完整归云端器件；`DEF-M2GA-GV5P-03` 另拆成 95 GiB 云端子项和 96 GiB 物理 package 子项；其余四条 v5p 物理待办继续留在 package 门。两条容量记录只保存各自来源、原值与作用域，不推导 1 GiB 预留，也不因拆到两个对象就宣布差异已经解决。

## 配置行落点

`configuration-row-dispositions.csv` 把机器类型和 slice/Pod 行从器件事实中排除。现有 `OBJ-GOOGLE-CT6E-STANDARD-FAMILY` 只作分组容器，可以提出一条不带数量的 `instance_contains_accelerator` 关系候选。正式条件集没有 machine type 或 API 名字段，因此 1t、4t、8t 的独有参数不能靠 notes 或 `software_version` 区分；后续一旦导入这些行，应先把命名机器类型升为独立 `cloud_instance`，再把芯片数量写到各自的包含关系。具有独立身份、拓扑或生命周期的 slice/Pod 才建立 `pod` 对象，其余参数化支持表留在配置审计中。

这项规则关闭了“配置行写到哪里”的准备问题，但不在本包创建机器类型对象、数量事实或 Pod。所有 VM 总 HBM、总芯片数、Pod 算力与系统带宽都明确禁止写入三张器件卡。

## 来源筛选候选

新器件事实范围不能沿用架构包的来源结论。候选四源最小集为 G08、G09、G10、G15：前三页分别承担 v5e、v5p、v6e 的单器件定值，G15 保留 `DEF-M2GA-GV6E-01` 的 2 个 SparseCore 原来源链。G09 在架构事实范围曾是 `redundant_covered`，在本范围必须改为 `selected`。G05 已冻结，但其计划采用内容由三代产品页和 G15 组合覆盖，只作为对象模型核查来源保留。`tpu-machines` 对器件事实是 `out_of_scope`，对机器类型与拓扑配置审计则是 `selected`。候选筛选、覆盖束和反向移除理由见 `source-selection-candidates.csv`；事实集合或页面哈希变化后必须重跑。

## 文件

| 文件 | 用途 |
|---|---|
| `object-scope-candidates.csv` | 三对象范围映射候选 |
| `relationship-candidates.csv` | 三条 `implements_architecture` 关系候选 |
| `deferred-dispositions.csv` | 14 个父待办拆成 15 个持久处置项 |
| `configuration-row-dispositions.csv` | machine type、slice 与 Pod 的结构化落点规则 |
| `source-candidates.csv` | `tpu-machines` family/source/endpoint 与六个 extract endpoint 候选 |
| `source-selection-candidates.csv` | 范围内筛选、覆盖和反向移除候选 |
| `source-freeze.md` | URL、访问日、字节数、哈希、拟落路径与获取限制 |
| `snapshots/2026-08-13/` | 六份可复核的内容提取文件 |
| `merge-instructions.md` | 临时正式副本合并顺序与禁止项 |
| `Validate-Package.ps1`、`validation-report.md` | 包内校验器与实跑结果 |

## 正式合并前仍需关闭

当前包可以进入独立复核，但不能直接正式合并。总控还需完成三对象范围补验收，正式预留 `tpu-machines` 的 family/source/extract endpoint ID，并决定建议的远端 `html_page` endpoint ID。六个 extract endpoint 只能按 `other / non-preferred` 接收；原始响应体 endpoint 的补取仍是独立待办。后续事实包还要按最终事实集合重跑来源选择，v5p 物理 package 也要另做身份门。

根 `README.md` 与 `AGENTS.md` 已检查，无需修改：本次只形成子代理 staging 准备包，没有改变正式项目范围、全局结构或已验收进度。