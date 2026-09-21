# 型号候选规范化交接

## 任务状态

状态为 `待总控验收`。INVENTORY-NORM-001 已把型号普查改写成一行一个对象候选的逗号分隔值（CSV）文件。候选标识使用 `CAND-<VENDOR>-...`，只供范围冻结前使用，不占用正式的 `OBJ` 标识。

## 输入

研究输入为：

- `AGENTS.md`
- `审计/子代理交接/README.md`
- `审计/子代理交接/model_inventory.md`
- `资料卡/字段字典.md`

本任务没有访问网页，也没有增加型号事实。日期、状态和官方来源键都来自 `model_inventory.md`；原普查只给出年份、季度或“当前”时，`release_or_status_date` 留空。

文风复核读取了本机的 `report-humanizer` 与 `shuorenhua` 规则。最终扫描结果见“验证”。

## 已完成

`object_candidates.csv` 共 173 行，已将同一表格单元里的架构、芯片或封装、产品配置（Stock Keeping Unit，SKU）和系统拆开。系统配置也单独成行，包括 Atlas 950 SuperPoD 的 64、1024 和 8192 NPU 配置、Trn2 UltraServer、Groq 3 LPX 托盘与机架，以及 AMD Helios 参考机架。

| 厂商 | 候选行数 |
|---|---:|
| NVIDIA | 44 |
| Google | 21 |
| AWS | 26 |
| Groq | 13 |
| 寒武纪 | 17 |
| 华为 | 28 |
| AMD | 24 |

对象层级分布为：架构 34 行、芯片或封装 22 行、产品 SKU 74 行、系统 43 行。范围状态分布为：主样本 106 行、观察项 35 行、历史锚点 20 行、排除项或线索 12 行。

所有正式来源键仍沿用普查中的 64 个键。每个非空键都能回到 `model_inventory.md` 的官方入口定义。候选之间只通过 `parent_or_related_hint` 提示关系，系统聚合值不会因此继承给芯片或卡。

## 验证

已执行可重复的导入、枚举和引用检查，结果如下。

| 检查 | 结果 |
|---|---|
| CSV 导入 | 通过，共 173 行、17 列 |
| 表头 | 17 个要求字段全部存在，无额外字段 |
| 候选标识 | 全部符合 `^CAND-[A-Z0-9-]+$`，无重复 |
| 厂商覆盖 | 七家厂商均有候选行 |
| `scope_status` | 仅使用四个规定值 |
| `object_layer` | 仅使用四层对象值 |
| `object_type` | 全部属于字段字典枚举 |
| 来源键 | 使用 64 个，未发现未定义键 |
| 关系提示 | 所有非空候选引用都能找到对应行 |
| 日期 | 非空日期均为 `YYYY-MM-DD` |
| UTF-8 | 严格解码通过，替换字符为 0 |
| SHA-256 | `B0781AFD54DF20D4D072706317164876D5B0FFC3FA30CE7B14EA66F7DCC544C6` |

有 13 行的 `availability_status` 留空。这些行已有身份线索，但普查没有提供足够的一手供货或开放证据；空值集中在 A800 40GB Active、HGX B100、寒武纪 MLU370-M8 与 MLU500 系列若干对象、Atlas 150、Atlas 800 A3 总称和 AMD `-HF` 软件别名。空值均配有 `open_questions`，并标为 `needs_resolution`。

文风机器扫描未发现可识别的 AI 写作痕迹。人工复核按 `shuorenhua` 的 `docs/status` 边界完成，保留了术语、日期、状态和责任归属；没有为了口语化改写字段名或对象关系。

## 未解决

下面这些名称仍不能可靠拆成最终对象。候选表保留了可审查的临时边界，没有根据相邻产品推断。

| 对象组 | 当前保存方式 | 待总控判断 |
|---|---|---|
| NVIDIA A800 | “A800 数据中心加速器”和“A800 40GB Active”各一行 | 正式订货名、容量、PCIe 或 SXM 形态，以及两者关系 |
| NVIDIA HGX B100 | 作为 `excluded_lead` 的 `baseboard` 候选保存 | 当前产品组合是否形成最终可保留的 HGX B100 系统 |
| Google TPU 配置族 | `v4-*`、`v5litepod-*`、`v5p-*`、`v6e-*`、`ct6e-standard-*` 和 TPU7x Slice 各保留一条配置族候选 | 等稳定 API 名清单后进入配置子表，不把通配符当成单个可购买 SKU |
| Google TPU v3、8t、8i 系统 | 架构与云系统分别成行，系统正式名称暂未确定 | 是否确有独立 Pod 或云系统对象，以及稳定配置名 |
| Groq 3 | 架构、LP30、8-LPU compute tray 和 256-LPU rack 分开 | LP30 的芯片或加速器边界，以及 compute tray 应归为 baseboard 还是 server |
| GroqCloud | 作为 `excluded_lead` 的 `cloud_accelerator` 映射实体保留 | 它是部署渠道，不能进入硬件资料卡；正式数据模型是否需要部署实体类型 |
| 寒武纪 MLU580 | 暂按 `silicon_package/package` 保存观察项 | 官方资料尚未确定它是芯片、封装还是板卡 |
| 华为 Atlas 800 A3 | 总称线索标为 `excluded_lead`，800T A3 与 800I A3 已分开 | 总称、改名还是独立系统 |
| AMD MI350 Series Platform | 保留一个 8-OAM 平台候选，配置字段注明 MI350X 或 MI355X 待核 | 没有足够依据拆成两个正式平台对象 |
| AMD MI500 Series | 与 CDNA 6 架构分开保留产品系列占位 | 正式 SKU 出现后再拆，当前不能把系列名当具体型号 |

NVIDIA GeForce、桌面或工作站 RTX 这类范围规则没有转成候选行，因为它们不是单一对象。普查明确点名的 A30、A40 和 V100 已各自保留一条 `excluded_lead`。

## 建议下一步

总控可先审查 96 条 `needs_resolution`，优先处理会改变对象层级或卡片数量的边界：A800、Google 配置族、Groq LP30、MLU580、Atlas 800 A3 和 MI350 Series Platform。确认后再把候选行转换成正式 `objects.csv` 与关系表；候选标识不应直接改名前缀后复用。

供货状态和精确日期应在固定版产品页、数据手册或正式发布材料确认后补入。当前空值不能用软件支持、动态导航页或年份级信息替代。

## 写入文件

- `审计/子代理交接/object_candidates.csv`
- `审计/子代理交接/inventory_normalization.md`
