# MLU590 结构化候选

状态：`accepted_and_merged`  
日期：2026-08-12

> 总控已于 2026-08-12 接受并合并本批次；本目录保留为可复查的交接快照。

本目录保存 MLU590 低披露试填的待合并候选。它引用正式对象 `OBJ-CAMBRICON-MLU590-ARCH`、`OBJ-CAMBRICON-MLU590-CHIP`、`OBJ-CAMBRICON-MLU590-H8` 和 `OBJ-CAMBRICON-MLU590-M9`，不新增对象，也没有修改全局 CSV。

## 候选内容

| 文件组 | 行数 | 用途 |
|---|---:|---|
| `facts.csv`、`fact-assertions.csv` | 7、7 | 六条世界人工智能大会（WAIC）页面事实和一条固定 MLU-OPS 提交的软件目标事实 |
| `field-requirements.csv` | 49 | 芯片、架构关系及 H8/M9 板卡的字段要求 |
| `search-log.csv`、`search-results.csv` | 40、40 | `not_found`、`pending_verification` 和 `inaccessible_evidence` 的检索过程 |
| `requirement-evidence.csv` | 13 | 不可访问证据、历史状态边界和架构关系证据 |
| `card-completeness.csv` | 9 | MLU590 芯片的九个完整度领域 |
| `special-capabilities.csv` | 3 | Top-K、MoE 路由和 Attention 的待核能力对象；不表示能力已存在 |
| 来源相关候选 | 8 | MLU-OPS 来源家族、固定提交、入口、筛选、角色和三条不等价覆盖记录 |
| `condition-sets.csv` | 2 | 2022 WAIC 历史语境和 MLU-OPS 固定提交的软件条件 |

WAIC 页面只支撑 2022 年的“思元590”名称、当时“在研”状态、厂商定位和 `MLUarch05`。CNToolkit 3.8.4 与 CNNL 1.23.2 在 2026-08-12 的直接请求均返回远端 HTTP 401，依赖这两页的内容没有生成确认性事实或来源断言。搜索索引摘要只用于发现入口。

MLU-OPS 固定到提交 `67b3707f9ce55718490534955903a007ae86f517`。`independent_build.sh` 直接把 `--mlu590` 写成 MLU590 目标，并给出 `__BANG_ARCH__=592`，所以本候选只记录软件构建目标。相邻的 512 KB、512 KB、2048 KB 宏以及开发指南中的样例缓冲上限没有进入物理存储事实。

## 校验

运行：

```powershell
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '.\审计\子代理交接\mlu590_structured_staging\Validate-Staging.ps1' -RootPath '.'
```

脚本只复制正式数据表和校验器到临时目录，把本目录候选逐表追加后运行项目正式校验器。总控补入 WAIC 固定网页快照后重新合并验证，当时的结果为：

```text
PASS: 32-table research data model; 37982 checks executed.
Registry: 323 columns, 488 enum values.
```

脚本结束后会核对临时目录仍位于系统临时根目录，再删除该副本。本批次已进入全局表；候选中的 `draft`、`provisional` 与 `needs_resolution` 状态按证据边界保留，不能因为完成合并就自动提升。