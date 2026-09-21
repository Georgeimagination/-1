# MLU590 证据边界与结构化候选交接

> 日期：2026-08-12  
> 任务状态：`ready_for_parent_review`  
> 写入边界：只写 `审计/子代理交接/mlu590_structured_staging/` 和本文件；没有修改资料卡、全局 CSV、README、AGENTS、研究计划或进度文件。

## 交付判断

MLU590 可以先合并一条小而完整的证据链。寒武纪 2022 年世界人工智能大会（WAIC）页面能直接支撑“思元590”、当时“在研”、厂商定位和 `MLUarch05`。官方 MLU-OPS 仓库固定到提交 `67b3707f9ce55718490534955903a007ae86f517` 后，可以支撑 `--mlu590` 软件构建目标和 `__BANG_ARCH__=592`。这两类内容共形成 7 条候选事实和 7 条逐来源断言。

CNToolkit 3.8.4 与 CNNL 1.23.2 不能进入确认性事实链。2026-08-12 使用浏览器式请求头直接访问，两页都返回远端 HTTP 401 Unauthorized。搜索索引显示的表格或版本片段只用于定位入口；在取得同版本正文或合法固定副本前，别名、板卡层级、BANG/compute/mtp 映射、CNNL 首个支持版本、TopK 限制和 BF16 线索都保持 `inaccessible_evidence`。

## 正式候选范围

候选引用已有的四个对象：`OBJ-CAMBRICON-MLU590-ARCH`、`OBJ-CAMBRICON-MLU590-CHIP`、`OBJ-CAMBRICON-MLU590-H8` 和 `OBJ-CAMBRICON-MLU590-M9`。没有新增对象或关系。

可以建立候选事实的内容如下：

| `fact_id` | 规范值 | 证据边界 |
|---|---|---|
| `FACT-CAMBRICON-MLU590-VENDOR` | 寒武纪 | WAIC 页面发布主体 |
| `FACT-CAMBRICON-MLU590-OFFICIAL-NAME-2022` | 思元590 | 不包含 `MLU590` 别名 |
| `FACT-CAMBRICON-MLU590-OBJECT-TYPE-2022` | `package` | 来源只说“芯片”；项目对象类型映射保持 `provisional` |
| `FACT-CAMBRICON-MLU590-POSITIONING-2022` | 全新一代云端智能训练芯片 | 仅表示 2022-09-02 的厂商措辞 |
| `FACT-CAMBRICON-MLU590-STATUS-2022` | `announced` | 原文是“在研”；受控值映射保持 `provisional`，不表示发布或供货 |
| `FACT-CAMBRICON-MLUARCH05-OFFICIAL-NAME` | `MLUarch05` | 不与 `BANG v5.0`、`compute_50` 或 `mtp_592` 合并 |
| `FACT-CAMBRICON-MLU590-MLUOPS-BUILD-TARGET-67B3707F` | `MLU-OPS build target --mlu590 (__BANG_ARCH__=592)` | 只表示固定提交中的软件目标 |

`OREL-CAMBRICON-MLU590-IMPLEMENTS-ARCH` 已是正式关系。候选用 `FIELD-ID-ARCH` 字段要求和 `requirement-evidence.csv` 连接 WAIC 来源，没有在 `facts.csv` 重复写一份关系文本。

以下内容没有生成事实：`MLU590` 别名、H8/M9 名称与板卡映射、`BANG v5.0`、`compute_50`、`mtp_592.{18}`、CNNL v1.14.0 支持、TopK 接口限制、BF16 硬件支持、任何算力、存储容量、带宽、功耗、制程和互联数字。

## MLU-OPS 固定提交的作用

`git ls-remote` 和一次只取目标提交的临时 `git fetch` 都解析到 `67b3707f9ce55718490534955903a007ae86f517`。提交日期为 2026-08-07，主题为 `[Docs](mlu-ops): docs v1.13.0 (#1328)`。

该提交确实含 MLU590 特定内容：`independent_build.sh` 第 123 至 126 行把 `--mlu590` 写成 MLU590 目标，并列出 `__BANG_ARCH__=592`。它旁边的 NRAM、WRAM、SRAM 宏是构建脚本口径。开发指南第 372 至 378 行又把样例 `MAX_NRAM_SIZE` 和 `MAX_SRAM_SIZE` 按 `__BANG_ARCH__` 分支，注释写的是 `mtp_592`。这些内容能证明软件目标和样例缓冲条件，不能证明物理容量、可用总量或整芯片汇聚规则。因此，候选把该提交选为软件机制来源，不导入 512 KB、512 KB、2048 KB 或样例宏数值。

## B-03 与 M-01 至 M-08 的处理

| 复核项 | 本次处理 | 合并后仍需做什么 |
|---|---|---|
| B-03 | CNToolkit、CNNL 相关字段统一改为 `inaccessible_evidence`，没有从索引摘要生成事实或断言。 | 主代理按下节建议改资料卡，固定副本取得后再复审。 |
| M-01 | 新的直接请求显示 CNToolkit 与 CNNL 均为远端 HTTP 401。全局记录中 CNToolkit 早先的 400 timeout 仍应保留。 | 在全局 endpoint 备注中按时间写“早先 400 timeout；本次 401”，不要覆盖历史。 |
| M-02 | MLU-OPS 已固定具体提交并登记来源候选；只支撑软件目标。 | 物理存储表中不导入脚本宏。 |
| M-03 | `mtp_592.{18}` 没有进入事实、来源引文或容量解释。 | 取得 CNToolkit 正文后只先保存原始字符串，再判断语法。 |
| M-04 | 芯片卡上的板卡形态与板卡冷却要求记为 `not_applicable`；芯片或封装功耗为 `not_found`；H8/M9 另有字段要求。 | H8/M9 手册取得后只在板卡对象填写形态、功耗和冷却。 |
| M-05 | 没有把 CNNL 旧版本页标为 `redundant_covered`。 | 先保持 `pending`，读取 1.23.2 全文并建立逐事实覆盖后再筛。 |
| M-06 | 新增 49 条字段要求、40 条检索记录、40 条检索结果和 13 条要求证据。 | 主代理合并后把资料卡状态与正式 ID 对齐。 |
| M-07 | 80/96/192 GB、300 至 345 TFLOPS、2.0 至 2.7 TB/s、372 GB/s 均未进入候选。 | 未登记来源前从人读卡删除孤立数字。 |
| M-08 | 完整度分开记录：WAIC 为可访问但动态未冻结；CNToolkit/CNNL 为不可访问；MLU-OPS 为固定提交。 | WAIC 后续保存合法快照，不能与 SDK 的 401 混成同一缺口。 |

## 资料卡的精确替换建议

下表按当前 `资料卡/寒武纪/MLU590_试填草稿.md` 行号给出替换文本。主代理应用时可结合正式 `fact_id` 调整表格列宽，但不要改变证据状态。

| 当前位置 | 建议替换 |
|---|---|
| 第 13 至 15 行 | `本卡以 2022 年 WAIC 页面所称的“思元590”芯片为主对象。MLU590、MLU590-H8 和 MLU590-M9 的名称或板卡映射目前依赖尚未完整读取的 CNToolkit 3.8.4，因此只记 inaccessible_evidence。WAIC 能确认思元590采用 MLUarch05；固定 MLU-OPS 提交只能确认 --mlu590 与 __BANG_ARCH__=592 的软件目标，不能证明 BANG v5.0、compute_50、mtp_592 与 MLUarch05 等价。` |
| 第 20 至 21 行 | 将“正式名称”拆成“思元590：`value_available`”和“MLU590 别名：`inaccessible_evidence`”；将“产品层级”写成“WAIC 原文为芯片，项目暂映射为 `package`，`provisional`。H8/M9 板卡层级仍为 `inaccessible_evidence`”。 |
| 第 29 至 37 行 | 改成四类状态：`SRC-2022-CAMBRICON-WAIC-MLU590` 为 `selected`；`SRC-CAMBRICON-MLU-OPS-COMMIT-67B3707F` 为只支撑软件目标的 `selected`；CNToolkit 与 CNNL 保持 `pending`、`inaccessible`，不列入当前最小集合。访问说明写明两页本次均为远端 401；CNToolkit 还要保留早先 400 timeout。 |
| 第 45 至 49 行 | BF16 硬件路径改为 `not_found`；CNNL 的库级 BF16 线索另记 `inaccessible_evidence`。TopK 软件限制记 `inaccessible_evidence`，TopK、MoE 路由和 Attention 专用硬件继续为 `not_found`。 |
| 第 55 至 59 行 | 替换为：`CNToolkit 的目标描述目前不可完整访问，本卡不引用或解释 mtp_592.{18}。固定 MLU-OPS 提交只确认软件构建目标；脚本宏和开发指南样例上限不等于硬件物理容量，因此 NRAM、WRAM、SRAM 容量仍无可接收事实。` |
| 第 66 行 | 替换为：`旧调研中存在互相冲突的第三方规格口径，但尚未登记为可追溯 source_id。本卡不列这些数字，也不把它们当作事实。` |
| 第 72 至 77 行 | 把“板卡形态、功耗、冷却”拆开：芯片或封装功耗为 `not_found`；板卡形态和板卡冷却对芯片对象为 `not_applicable`，移到 H8/M9 要求。CNNL 支持与 BANG/compute/mtp 映射改为 `inaccessible_evidence`；另增一行固定 MLU-OPS 提交支撑的 `--mlu590` 软件目标。 |
| 第 84 行 | 将 CNNL 1.14.x 至 1.22.x 的旧页从 `redundant_covered` 候选改为 `pending`。在 1.23.2 正文和覆盖矩阵完成前，不判断完全覆盖。 |
| 第 90 行 | 改成：`WAIC 页面仍需合法固定快照；CNToolkit 3.8.4 与 CNNL 1.23.2 仍需同版本正文；MLU-OPS 已固定到提交 67b3707f9ce55718490534955903a007ae86f517。` |
| 第 101 至 106 行 | 数值格式改为 `missing_public_data`；存储改为 `needs_review`；软件保持 `partial`，但说明只有固定 MLU-OPS 软件目标已确认；来源证据说明分别写 WAIC 动态未冻结、两份 SDK 不可访问、MLU-OPS 固定。 |

## 候选文件与验证

`mlu590_structured_staging/` 现有 15 张候选 CSV、一个说明文件和一个自校验脚本。主要行数为：49 条字段要求、40 条检索日志、40 条检索结果、13 条要求证据、7 条事实、7 条断言、9 条完整度记录，3 个待核特殊能力对象，以及一个 MLU-OPS 来源版本和三条来源不等价记录。

`Validate-Staging.ps1` 把正式数据表和本目录候选复制到系统临时目录，逐表合并后运行项目正式 `Validate-ResearchData.ps1`。最新结果：

```text
PASS: 32-table research data model; 37969 checks executed.
Registry: 323 columns, 488 enum values.
```

候选主键与当前全局表没有碰撞。临时副本在删除前会核对路径仍位于系统临时根目录。

`report-humanizer` 已扫描本文件和 staging README，两份均返回 `No machine-detectable AI tells found`。随后按 `shuorenhua` 的 `docs` 场景做了最小幅度人工回读，重点核对标题、首段、表格引导、结尾以及数字、HTTP 状态、版本、提交哈希、正式 ID 和责任归属；没有发现需要改变事实或结构的残留模板腔。没有人类写作样本可供语气对照，剩余风险只在内容取舍，不在明显 AI 腔。

## 未解决和下一步

M1 仍缺 MLU590 与“思元590”的同页别名证据、H8/M9 固定板卡手册、正式发布或首供记录，以及几乎全部芯片规格。低披露本身不阻止合并字段要求和缺失状态；CNToolkit/CNNL 正文未取得时，不能提升对应事实。

主代理可以先复核并合并本候选，再按上表修改资料卡。合并时应保留所有 `draft` 状态，复核 2022 状态从“在研”映射到 `announced` 是否接受；如果不接受，保留字段要求和原始断言，暂不接收该规范事实。之后优先取得两份 SDK 的同版本固定副本，再寻找 MLU590 芯片手册和 H8/M9 板卡手册。

## 工具与访问记录

固定提交的 raw 文件先在网页读取工具中出现远端 cache miss，随后在默认网络沙箱中无法连接；使用已批准的受控网络访问后成功。前两次分别属于远端工具缓存失败和网络沙箱边界，不是模型或实现能力问题。GitHub API 返回 403，属于远端服务访问限制；提交日期改由只取目标提交的 `git fetch` 核对。两份寒武纪 SDK 页面均返回远端 401，属于远端服务或访问控制响应，没有发生用户拒绝、自动审批拒绝、审批连接故障或文件系统沙箱拒绝。

执行过程中出现一次 JavaScript 调用构造错误、一次 PowerShell 空管道解析错误和一次 Markdown 反引号转义错误，均为操作错误，已立即改正，没有写坏结构化数据。任务说明中的 `资料卡/资料卡模板.md` 实际不存在，读取时改用项目现有的 `资料卡/模板.md`。

## 写入文件

- `审计/子代理交接/mlu590_structured_staging/README.md`
- `审计/子代理交接/mlu590_structured_staging/Validate-Staging.ps1`
- `审计/子代理交接/mlu590_structured_staging/` 下 15 张候选 CSV
- `审计/子代理交接/mlu590_remediation.md`