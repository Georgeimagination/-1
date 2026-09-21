# 芯片名单冻结初审交接：寒武纪、华为、AMD

## 任务状态与边界

状态：候选冻结初审完成，待不同代理独立复核；不是正式冻结结论。

本交接按 `AGENTS.md`、`审计/新会话交接_芯片名单冻结.md`、DEC-030 和 DEC-031 执行。核对范围只包括产品身份、物理层级、时间边界以及训练或推理相关性；没有展开规格调研、媒体检索、事实抽取或资料卡生产。时间截止日为 2026-08-14。主样本期按 2022-01-01 至截止日处理；主样本期之前但对代际连续性必要的对象标为历史锚点；厂商只公布未来计划、尚不能闭合芯片物理身份的对象保留为观察项，不计入冻结芯片数。

输入包括早期 173 行候选表 `审计/子代理交接/object_candidates.csv`、现有正式对象和关系、第三波华为与 AMD 本地固定来源、四份 AMD CDNA 架构白皮书，以及定向核对的厂商官方入口。MI455X 模组和 MI350P PCIe 卡按用户裁决退出芯片主线，既有历史记录不删除；Ascend 950 die、950PR 和 950DT 保留。

## 计数方法

名单按“对象行”和“底层计算裸片设计”两个口径并列说明，不能把二者相加：

- `die` 是可稳定命名的计算裸片设计。相同裸片被多个封装复用时，裸片只列一行、只计一次；封装里出现的 2、6 或 8 颗相同裸片是组成数量，不增列为多个裸片对象。AMD 的 IOD（I/O die）、FCD 等非 AI 计算裸片不进入本名单。
- `package` 是厂商证据能与外层 PCIe 卡、OAM/EAM 模组明确分离的单颗或多裸片芯片封装。同一计算裸片形成具有稳定官方产品名的不同封装型号时，每个封装型号各列一行；共享裸片关系另行说明。
- `module`、`accelerator_card`、服务器、机架和 Pod 不计芯片。若市场型号同时用于外层载体，只有官方资料明确给出内层 `package` 结构时才另建封装行；不能闭合时不凭产品名猜成封装。
- 同一行的“训练/推理相关性”只回答是否属于研究范围，不代表性能定位。`纳入_主样本` 与 `纳入_历史锚点` 计入芯片名单；`观察_不计数`、`待决_不计数` 和 `排除` 均不计。

## 早期 22 个 `package` 候选覆盖

173 行候选中共有 22 行 `object_type=package`。本子任务逐条审查其中寒武纪 6 行、华为 8 行，共 14 行；其余 8 行由 NVIDIA、AWS 和 Groq 的对应初审代理处理。这样可以把“本交接审查了 14 行”与“全局需覆盖 22 行”区分开，避免误报漏项。

| 厂商 | 早期 `package` 候选数 | 本交接覆盖 | 候选 ID |
|---|---:|---:|---|
| NVIDIA | 1 | 0 | `CAND-NVIDIA-GH200-SUPERCHIP` |
| AWS | 5 | 0 | `CAND-AWS-INFERENTIA1-CHIP`、`CAND-AWS-TRAINIUM1-CHIP`、`CAND-AWS-INFERENTIA2-CHIP`、`CAND-AWS-TRAINIUM2-CHIP`、`CAND-AWS-TRAINIUM3-CHIP` |
| Groq | 2 | 0 | `CAND-GROQ-GROQCHIP-PROCESSOR`、`CAND-GROQ-LP30` |
| 寒武纪 | 6 | 6 | `CAND-CAMBRICON-MLU290-PACKAGE`、`CAND-CAMBRICON-MLU370-PACKAGE`、`CAND-CAMBRICON-MLU570-PACKAGE`、`CAND-CAMBRICON-MLU590-PACKAGE`、`CAND-CAMBRICON-MLU580`、`CAND-CAMBRICON-MLU690` |
| 华为 | 8 | 8 | `CAND-HUAWEI-ASCEND-310`、`CAND-HUAWEI-ASCEND-910`、`CAND-HUAWEI-ASCEND-910B`、`CAND-HUAWEI-ASCEND-910C`、`CAND-HUAWEI-ASCEND-950PR`、`CAND-HUAWEI-ASCEND-950DT`、`CAND-HUAWEI-ASCEND-960`、`CAND-HUAWEI-ASCEND-970` |
| 合计 | 22 | 14 | 其余 8 行待相应厂商复核汇总 |
## 寒武纪候选矩阵

寒武纪官方 CNToolkit 组件兼容表把 MLU290、MLU370、MLU570 和 MLU590放在 `Chip Level`，并把 MLU290-M5、MLU370-S4/X4/X8/M8、MLU570/590-H8/M9 等放在 `Board Level`。这组对照足以建立芯片与板卡边界。思元 370 官方产品页还说明其两个 AI 计算芯粒（chiplet）封装成一颗 AI 芯片，因此 MLU370 是一个封装对象，内部两颗芯粒的数量不另增名单行。

| 候选 ID | 芯片名称 | 对象层级 | 时间边界 | 训练/推理相关性 | 初审状态 | 排除理由或计数关系 | 官方身份来源 |
|---|---|---|---|---|---|---|---|
| `CAND-CAMBRICON-MLU290-PACKAGE` | Cambricon MLU290 / 思元 290 | `package` | 历史锚点；官方 2021 年材料已出现 | 训练为主，兼具推理相关性 | `纳入_历史锚点` | MLU290 芯片计 1 个封装型号；MLU290-M5 是板卡，不另计芯片 | [寒武纪 2021 WAIC 官方新闻](https://www.cambricon.com/index.php?a=show&c=index&catid=127&id=41&m=content)；[CNToolkit 官方兼容表](https://sdk.cambricon.com/static/independent/CNToolkit/3.8.4/releasenote/3.8.4/build/html/chapter_components/index.html) |
| `CAND-CAMBRICON-MLU370-PACKAGE` | Cambricon MLU370 / 思元 370 | `package` | 历史锚点；官方 2021 至 2022 年材料已出现 | 训练与推理 | `纳入_历史锚点` | 一个 MLU370 封装含两个 AI 计算芯粒，但名单按封装型号计 1；MLU370-X8 是含两颗 MLU370 芯片的卡，不计芯片 | [思元 370 官方产品页](https://www.cambricon.com/index.php?a=lists&c=index&catid=360&m=content)；[MLU370-X8 官方新闻](https://www.cambricon.com/index.php?a=show&c=index&catid=127&id=48&m=content) |
| `CAND-CAMBRICON-MLU570-PACKAGE` | Cambricon MLU570 | `package` | 主样本；截至截止日仍在官方软件芯片级支持表 | 训练与推理相关 | `纳入_主样本` | 与 MLU570/590-H8/M9 板级产品分开；封装型号计 1 | [CNToolkit 官方兼容表](https://sdk.cambricon.com/static/independent/CNToolkit/3.8.4/releasenote/3.8.4/build/html/chapter_components/index.html)；[CNNL 官方发布说明](https://sdk.cambricon.com/static/independent/CNNL/1.23.2/releasenote/1.23.2/build/html/cnnl.html) |
| `CAND-CAMBRICON-MLU590-PACKAGE` | Cambricon MLU590 / 思元 590 | `package` | 主样本；2022 年官方预告，截止日已有芯片级软件支持 | 训练芯片，推理工作负载亦在软件支持范围 | `纳入_主样本` | MLU590 芯片计 1 个封装型号；H8/M9 等板级产品不计 | [寒武纪 2022 WAIC 官方新闻](https://www.cambricon.com/index.php?a=show&c=index&catid=127&id=51&m=content)；[CNToolkit 官方兼容表](https://sdk.cambricon.com/static/independent/CNToolkit/3.8.4/releasenote/3.8.4/build/html/chapter_components/index.html) |
| `CAND-CAMBRICON-MLU580` | Cambricon MLU580 | `package`（暂定，边界未闭合） | 主样本期官方软件发布说明可见；产品层级未闭合 | AI 训练/推理硬件相关，具体定位本轮不展开 | `观察_边界待决_不计数` | CNNL 只明确“新增硬件支持 MLU580”；同一时期 CNToolkit 的 `Chip Level` 列表没有 MLU580，也未找到可区分封装与板卡的产品入口。身份线索保留，但冻结总数不计 | [CNNL 官方发布说明](https://sdk.cambricon.com/static/independent/CNNL/1.23.2/releasenote/1.23.2/build/html/cnnl.html)；[CNToolkit 官方兼容表](https://sdk.cambricon.com/static/independent/CNToolkit/3.8.4/releasenote/3.8.4/build/html/chapter_components/index.html) |
| `CAND-CAMBRICON-MLU690` | Cambricon MLU690 | `package`（早期候选假定） | 截止日未核到官方产品身份 | 未能由官方来源确认 | `排除_无官方身份` | 早期线索未被厂商入口闭合，不能仅凭型号规律纳入 | [寒武纪官方产品入口](https://www.cambricon.com/index.php?a=lists&c=index&catid=358&m=content) |

寒武纪初审计数为 4 个纳入封装型号，其中 2 个历史锚点、2 个主样本；MLU580 观察但不计，MLU690 排除。这里的“4”是封装型号数，不把 MLU370 内部两个芯粒拆成两个对象。

## 华为候选矩阵

华为 2025 年官方主题演讲给出了本轮最关键的物理关系：Ascend 950PR 与 950DT 使用同一 Ascend 950 Die（裸片），再以不同 HBM 组合形成两个芯片产品。正式库现有 `OBJ-HUAWEI-ASCEND-950-DIE`，以及 PR、DT 到该裸片的 `package_contains_die` 关系，与此口径一致。三行都保留，但按底层硅设计口径是一个共享计算裸片、两个封装变体。

| 候选 ID 或建议键 | 芯片名称 | 对象层级 | 时间边界 | 训练/推理相关性 | 初审状态 | 排除理由或计数关系 | 官方身份来源 |
|---|---|---|---|---|---|---|---|
| `CAND-HUAWEI-ASCEND-310` | Huawei Ascend 310 | `package`（官方芯片产品） | 历史锚点；官方称 2018 年推出 | 推理 | `纳入_历史锚点` | 计 1 个封装型号；Atlas 卡或边缘设备不计芯片 | [Huawei Connect 2025 官方演讲](https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech) |
| `新增-HUAWEI-ASCEND-310P` | Huawei Ascend 310P | `package`（官方称 AI 处理器） | 历史锚点；官方文档版本延续至主样本期，首次日期不在本轮扩搜 | 推理 | `纳入_历史锚点` | 早期 173 行遗漏。官方文档直接称“昇腾 310P AI 处理器”，不把承载它的推理卡计入 | [昇腾 CANN 310P 官方开发文档](https://www.hiascend.com/document/detail/zh/canncommercial/601/inferapplicationdev/graphdevg/graphdevg_geapi_0101.html) |
| `新增-HUAWEI-ASCEND-310B` | Huawei Ascend 310B | `package`（官方称 AI 处理器/NPU 芯片） | 主样本；官方 CANN 6.2 RC2 与 Atlas 200I A2 文档可核身份 | 推理 | `纳入_主样本` | 早期 173 行遗漏；计 1 个芯片封装型号，Atlas 200I A2 等设备不计 | [CANN 6.2 RC2 ATC 官方指南（PDF）](https://www.hiascend.com/doc_center/source/zh/canncommercial/62RC2/inferapplicationdev/atctool/CANN%206.2.RC2%20ATC%E5%B7%A5%E5%85%B7%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97%2001.pdf)；[Ascend 310B DCMI 官方参考（PDF）](https://www.hiascend.com/doc_center/source/zh/Atlas%20200I%20A2/23.0.RC3/re/api/Ascend%20310B%2023.0.RC3%20DCMI%20API%E5%8F%82%E8%80%83.pdf) |
| `CAND-HUAWEI-ASCEND-910` | Huawei Ascend 910 | `package`（官方芯片产品） | 历史锚点；官方称 2019 年推出 | 训练，亦属通用 AI 计算范围 | `纳入_历史锚点` | 计 1 个封装型号；Atlas 训练卡、服务器等外层产品不计 | [Huawei Connect 2025 官方演讲](https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech) |
| `CAND-HUAWEI-ASCEND-910B` | Huawei Ascend 910B | `package`（官方芯片产品；封装细节未公开） | 主样本；截止日官方演讲明确芯片身份 | 训练与推理相关 | `纳入_主样本` | 计 1 个官方芯片型号；不以服务器或超节点数量替代芯片数 | [Huawei Connect 2025 官方演讲](https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech) |
| `CAND-HUAWEI-ASCEND-910C` | Huawei Ascend 910C | `package`（官方芯片产品；封装细节未公开） | 主样本；截止日官方演讲明确已部署于 Atlas 900 A3 | 训练与推理相关 | `纳入_主样本` | 计 1 个官方芯片型号；Atlas 900 A3 是系统层，不另计芯片 | [Huawei Connect 2025 官方演讲](https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech) |
| `OBJ-HUAWEI-ASCEND-950-DIE` | Huawei Ascend 950 Die | `die` | 主样本；2025 年官方演讲明确命名 | PR 对应预填充/推荐，DT 对应解码/训练；裸片本身属两者共同计算核心 | `纳入_主样本` | 共享裸片只计 1 个 die；950PR、950DT 通过关系指向它 | [Huawei Connect 2025 官方演讲](https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech) |
| `CAND-HUAWEI-ASCEND-950PR` / `OBJ-HUAWEI-ASCEND-950PR` | Huawei Ascend 950PR | `package` | 主样本；官方路线图称 2026 Q1，截止日官方处理器页与产品发布入口可见 | 推理预填充与推荐 | `纳入_主样本` | 计 1 个封装变体；与 950DT 共享同一 Ascend 950 Die | [昇腾处理器官方入口](https://www.hiascend.com/hardware/processor)；[Atlas 350 官方发布](https://www.hiascend.com/activities/dynamic-news/20260320-3)；[Huawei Connect 2025 官方演讲](https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech) |
| `CAND-HUAWEI-ASCEND-950DT` / `OBJ-HUAWEI-ASCEND-950DT` | Huawei Ascend 950DT | `package` | 主样本；官方路线图称 2026 Q4，截止日已有官方处理器身份，供货状态仍应保留 `pending_verification` | 训练与推理解码 | `纳入_主样本`（按用户明确裁决） | 计 1 个封装变体；与 950PR 共享同一 Ascend 950 Die。纳入身份不等于宣称已普遍供货 | [昇腾处理器官方入口](https://www.hiascend.com/hardware/processor)；[Huawei Connect 2025 官方演讲](https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech) |
| `CAND-HUAWEI-ASCEND-960` | Huawei Ascend 960 | `package`（路线图产品） | 未来观察；官方目标 2027 Q4 | 训练与推理相关 | `观察_不计数` | 截止日只有未来路线图身份，不进入当前冻结芯片计数 | [Huawei Connect 2025 官方演讲](https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech) |
| `CAND-HUAWEI-ASCEND-970` | Huawei Ascend 970 | `package`（路线图产品） | 未来观察；官方目标 2028 Q4 | 训练与推理相关 | `观察_不计数` | 截止日只有未来路线图身份，不进入当前冻结芯片计数 | [Huawei Connect 2025 官方演讲](https://www.huawei.com/en/news/2025/9/hc-xu-keynote-speech) |

华为初审计数为 9 个纳入对象：1 个共享 die、8 个封装型号。8 个封装为 Ascend 310、310P、310B、910、910B、910C、950PR 和 950DT；960 与 970 只作观察。若按“底层硅设计”汇总，950 三行不能说成三种硅设计，而应写成“一种 Ascend 950 裸片设计 + 两个封装变体”。
## AMD 候选矩阵

AMD 的市场型号经常同时指向 PCIe 卡、OAM（OCP Accelerator Module，开放计算项目加速模组）或 EAM（Enterprise Accelerator Module，企业加速模组）。本轮不把这些外层产品直接改名为 `package`，而是先找厂商白皮书能否单独命名内部计算裸片与多裸片封装。CDNA2 的 GCD（Graphics Compute Die，图形/计算裸片）以及 CDNA3、CDNA4、CDNA5 的 XCD（Accelerator Complex Die，加速器复合裸片）均有稳定官方名称，可以建立 `die`。IOD、FCD 等承担 I/O 或互连的裸片不是 AI 计算裸片，本名单不纳入。

对于封装，初审只接受白皮书同时出现内层 `package` 结构和外层 OAM/EAM/PCIe 形态的对象。MI308X 没有找到同等层级的封装闭合证据，因此不猜。MI210 与 MI350P 的公开产品身份分别是 PCIe 卡；白皮书或 brochure 只证明卡内有计算裸片，不能据此虚构一个同名封装。

| 建议键 | 芯片或对象名称 | 对象层级 | 时间边界 | 训练/推理相关性 | 初审状态 | 排除理由或计数关系 | 官方身份来源 |
|---|---|---|---|---|---|---|---|
| `新增-AMD-CDNA2-MI200-GCD` | AMD Instinct MI200 Graphics Compute Die (GCD) | `die` | 历史锚点；CDNA2/MI200 世代 | 训练与推理通用计算 | `纳入_历史锚点` | 共享计算裸片设计只计 1：MI210 使用 1 颗，MI250/MI250X 封装各使用 2 颗；组成数量不增列 | [AMD CDNA2 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-business-docs/white-papers/amd-cdna2-white-paper.pdf) |
| `CAND-AMD-MI210-PCIE-CARD` | AMD Instinct MI210 | `accelerator_card`（PCIe） | 历史锚点世代 | 训练与推理相关 | `排除_非芯片_历史保留` | 官方身份是 PCIe 卡。卡内 MI200 GCD 已作为共享 die 纳入；没有证据建立“MI210 package”，不重复计 | [AMD MI200 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi200.html)；[AMD CDNA2 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-business-docs/white-papers/amd-cdna2-white-paper.pdf) |
| `新增-AMD-MI250-PACKAGE` | AMD Instinct MI250 multi-chip package | `package` | 历史锚点 | 训练与推理相关 | `纳入_历史锚点` | CDNA2 白皮书把两个 GCD 的 MCM 封装与 OAM accelerator 分层描述；计 1 个封装变体，与 MI250X 共享同一 GCD 设计 | [AMD CDNA2 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-business-docs/white-papers/amd-cdna2-white-paper.pdf) |
| `CAND-AMD-MI250-OAM` | AMD Instinct MI250 OAM accelerator | `module`（OAM） | 历史锚点世代 | 训练与推理相关 | `排除_非芯片` | 外层 OAM 模组不计；内部 MI250 package 另列 | [AMD MI200 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi200.html) |
| `新增-AMD-MI250X-PACKAGE` | AMD Instinct MI250X multi-chip package | `package` | 历史锚点 | 训练与推理相关 | `纳入_历史锚点` | CDNA2 白皮书明确两个 GCD 集成于单一封装并处在 OAM 产品内；计 1 个封装变体，GCD 不重复计 | [AMD CDNA2 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-business-docs/white-papers/amd-cdna2-white-paper.pdf) |
| `CAND-AMD-MI250X-OAM` | AMD Instinct MI250X OAM accelerator | `module`（OAM） | 历史锚点世代 | 训练与推理相关 | `排除_非芯片` | 外层 OAM 模组不计；内部 MI250X package 另列 | [AMD MI200 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi200.html) |
| `新增-AMD-CDNA3-XCD` | AMD CDNA 3 Accelerator Complex Die (XCD) | `die` | 主样本；MI300 世代 | 训练与推理通用计算 | `纳入_主样本` | CDNA3 共享计算裸片设计只计 1；MI300A 使用 6 颗，MI300X/MI325X 各使用 8 颗。IOD 不计 AI compute die | [AMD CDNA3 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/white-papers/amd-cdna-3-white-paper.pdf) |
| `新增-AMD-MI300A-PACKAGE` | AMD Instinct MI300A APU package | `package` | 主样本；2023 年官方发布 | 训练与推理通用计算 | `纳入_主样本` | 官方明确 CPU、GPU 与内存在单一封装中；这是 SH5 插槽封装，不是 PCIe/OAM 卡。计 1 个封装型号，共享 CDNA3 XCD 只计一次 | [AMD MI300 官方发布](https://www.amd.com/en/newsroom/press-releases/2023-12-6-amd-delivers-leadership-portfolio-of-data-center-a.html)；[AMD CDNA3 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/white-papers/amd-cdna-3-white-paper.pdf) |
| `新增-AMD-MI300X-PACKAGE` | AMD Instinct MI300X multi-chip package | `package` | 主样本；2023 年官方发布 | 训练与推理通用计算 | `纳入_主样本` | 官方资料把 heterogeneous/multi-chip package 与 OAM module 分别表述；计 1 个封装型号，8 颗 XCD 是组成数量 | [MI300X 官方数据表（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/data-sheets/amd-instinct-mi300x-data-sheet.pdf)；[AMD CDNA3 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/white-papers/amd-cdna-3-white-paper.pdf) |
| `CAND-AMD-MI300X-OAM` | AMD Instinct MI300X OAM module | `module`（OAM） | 主样本 | 训练与推理相关 | `排除_非芯片` | 外层 OAM 模组不计；内部 MI300X package 另列 | [AMD MI300 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi300.html)；[MI300X 官方数据表（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/data-sheets/amd-instinct-mi300x-data-sheet.pdf) |
| `CAND-AMD-MI308X-OAM` | AMD Instinct MI308X | `module`（官方规格入口为 OAM） | 主样本 | 训练与推理相关 | `待决_不计数` | 可核官方产品身份，但截至本轮没有把内部 package 或 XCD 映射与 OAM 清楚分开的证据；不沿用 MI300X/325X 推测 | [AMD 加速器官方规格入口](https://www.amd.com/en/products/specifications/accelerators.html)；[AMD SMI 官方变更记录](https://rocm.docs.amd.com/projects/amdsmi/en/docs-7.2.2/reference/changelog.html) |
| `新增-AMD-MI325X-PACKAGE` | AMD Instinct MI325X multi-chip package | `package` | 主样本；2024 年官方产品 | 训练与推理通用计算 | `纳入_主样本` | CDNA3 白皮书建立离散 GPU 封装身份，产品数据表另给 OAM module；计 1 个封装型号，与 MI300X 共享 CDNA3 XCD | [MI325X 官方产品页](https://www.amd.com/en/products/accelerators/instinct/mi300/mi325x.html)；[MI325X 官方数据表（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/product-briefs/instinct-mi325x-datasheet.pdf)；[AMD CDNA3 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/white-papers/amd-cdna-3-white-paper.pdf) |
| `CAND-AMD-MI325X-OAM` | AMD Instinct MI325X OAM module | `module`（OAM） | 主样本 | 训练与推理相关 | `排除_非芯片` | 外层 OAM 模组不计；内部 MI325X package 另列 | [MI325X 官方产品页](https://www.amd.com/en/products/accelerators/instinct/mi300/mi325x.html) |
| `新增-AMD-CDNA4-XCD` | AMD CDNA 4 Accelerator Complex Die (XCD) | `die` | 主样本；MI350 世代 | 训练与推理通用计算 | `纳入_主样本` | CDNA4 共享计算裸片设计只计 1；MI350P 卡含 4 颗，MI350X/MI355X 封装各含 8 颗。IOD 不计 AI compute die | [AMD CDNA4 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/white-papers/amd-cdna-4-architecture-whitepaper.pdf) |
| `新增-AMD-MI350X-PACKAGE` | AMD Instinct MI350X heterogeneous package | `package` | 主样本；2025 年官方产品 | 训练与推理通用计算 | `纳入_主样本` | CDNA4 白皮书单列 MI350 Series heterogeneous package，并另列 OAM form factor；计 1 个封装型号，共享 XCD 不重复计 | [AMD MI350 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi350.html)；[AMD CDNA4 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/white-papers/amd-cdna-4-architecture-whitepaper.pdf) |
| `CAND-AMD-MI350X-OAM` | AMD Instinct MI350X OAM module | `module`（OAM） | 主样本 | 训练与推理相关 | `排除_非芯片` | 外层 OAM 模组不计；内部 MI350X package 另列 | [AMD MI350 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi350.html) |
| `新增-AMD-MI355X-PACKAGE` | AMD Instinct MI355X heterogeneous package | `package` | 主样本；2025 年官方产品 | 训练与推理通用计算 | `纳入_主样本` | CDNA4 白皮书区分 heterogeneous package 与 OAM form factor；计 1 个封装型号，与 MI350X 共享 CDNA4 XCD | [AMD MI350 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi350.html)；[AMD CDNA4 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/white-papers/amd-cdna-4-architecture-whitepaper.pdf)；[MI355X 官方 brochure（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/product-briefs/amd-instinct-mi355x-gpu-brochure.pdf) |
| `CAND-AMD-MI355X-OAM` | AMD Instinct MI355X OAM module | `module`（OAM） | 主样本 | 训练与推理相关 | `排除_非芯片` | 外层 OAM 模组不计；内部 MI355X package 另列 | [AMD MI350 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi350.html) |
| `OBJ-AMD-MI350P-PCIE-CARD` | AMD Instinct MI350P PCIe card | `accelerator_card` | 主样本；2026 年官方产品 | 训练与推理相关 | `排除_非芯片_历史保留` | 用户已明确退出主线。官方只闭合“PCIe 卡内含 4 个 XCD”，未建立 MI350P 同名 package；CDNA4 XCD die 已纳入 | [MI350P 官方产品页](https://www.amd.com/en/products/accelerators/instinct/mi350/mi350p.html)；[MI350P 官方 brochure（PDF）](https://www.amd.com/content/dam/amd/en/documents/epyc-business-docs/other/amd-instinct-mi350p-product-brochure.pdf) |
| `新增-AMD-CDNA5-MI455X-XCD` | AMD CDNA 5 Accelerator Complex Die (XCD)，由 MI455X 证实 | `die` | 主样本；MI455X/CDNA5 世代 | 训练与推理通用计算 | `纳入_主样本` | 共享裸片先只按 MI455X 证据计 1；不在缺证据时假定 MI430X、MI440X 必然复用同一 XCD。IOD/FCD 不计 | [AMD CDNA5 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/white-papers/amd-cdna5-whitepaper.pdf) |
| `新增-AMD-MI455X-PACKAGE` | AMD Instinct MI455X GPU package | `package` | 主样本；截至截止日官方产品已发布 | 训练与推理通用计算 | `纳入_主样本` | CDNA5 白皮书明确 MI455X GPU package，官方 brochure 说明一个 EAM 承载四个 GPU packages，内外层已分离；每个封装含 8 个 XCD，但封装型号只计 1 | [AMD CDNA5 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/white-papers/amd-cdna5-whitepaper.pdf)；[AMD MI400 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi400.html) |
| `OBJ-AMD-MI455X-MODULE` | AMD Instinct MI455X EAM module | `module`（EAM） | 主样本；截至截止日官方产品已发布 | 训练与推理相关 | `排除_非芯片_历史保留` | 用户已明确退出主线。一个 EAM 是承载四个 MI455X GPU packages 的外层模组；内部 package 与 CDNA5 XCD 已分别纳入 | [AMD MI400 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi400.html)；[AMD CDNA5 官方白皮书（PDF）](https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/white-papers/amd-cdna5-whitepaper.pdf) |
| `新增-AMD-MI440X-OBS` | AMD Instinct MI440X GPU | 物理层级待定 | 主样本期公告；2026-01-05 官方发布身份 | AI/HPC 计算，训练或推理具体边界本轮不扩展 | `观察_边界待决_不计数` | 官方公告建立 GPU 产品名和 8-GPU 形态，但本轮没有闭合单颗 die/package 与外层形态；不凭 MI455X 类推 | [AMD CES 2026 官方新闻](https://newsroom.amd.com/news/amd-and-its-partners-share-their-vision-for-ai-ev/) |
| `新增-AMD-MI430X-OBS` | AMD Instinct MI430X GPU | 物理层级待定 | 未来观察；官方页面指向 2027 | AI/HPC 计算，训练或推理具体边界本轮不扩展 | `观察_未来_不计数` | 有官方未来产品名，但截止日没有可冻结的独立 die/package 身份；不能假定与 MI455X 共用 XCD | [AMD CDNA 技术官方页](https://www.amd.com/en/technologies/cdna.html)；[AMD MI400 系列官方页](https://www.amd.com/en/products/accelerators/instinct/mi400.html) |
| `新增-AMD-MI500-SERIES-OBS` | AMD Instinct MI500 Series | `product_series` / 物理层级待定 | 未来观察；官方称计划于 2027 年推出 | AI 训练与推理相关产品线 | `观察_系列_不计数` | 只有系列级路线图，没有稳定 SKU、计算 die 或 package 身份；系列名不算芯片 | [AMD CES 2026 官方新闻](https://newsroom.amd.com/news/amd-and-its-partners-share-their-vision-for-ai-ev/) |

AMD 初审计数为 12 个纳入芯片对象：4 个计算 die、8 个封装型号。4 个 die 为 MI200 GCD、CDNA3 XCD、CDNA4 XCD 和由 MI455X 证实的 CDNA5 XCD；8 个封装为 MI250、MI250X、MI300A、MI300X、MI325X、MI350X、MI355X 和 MI455X。MI210、MI350P 由共享计算 die 代表其芯片本体，不建立同名封装；MI308X 因 package/OAM 边界未闭合而暂不计。MI440X、MI430X 和 MI500 Series 保留观察，不占冻结总数。
## 汇总与主要争议

本子任务建议纳入 25 个芯片对象，即 5 个计算 die + 20 个封装型号。按时间边界，其中 8 个是历史锚点，17 个属于主样本。分厂商看，寒武纪为 4 个封装；华为为 1 个共享 die 与 8 个封装；AMD 为 4 个共享 die 与 8 个封装。这个数字是初审候选总数，必须在不同代理独立复核后才能并入全局候选冻结稿。

| 争议 | 初审判断 | 独立复核硬门 |
|---|---|---|
| AMD 市场型号能否从 OAM/EAM 中拆出 `package` | MI250/250X、MI300X/325X、MI350X/355X 的架构白皮书分别命名内部多裸片或异构封装，并把 OAM 作为外层形态；MI455X 的 EAM 与四个 GPU packages 分离最明确；MI300A 是单一插槽封装 | 复核者应直接检查白皮书的 layer wording 与图示。若某型号仍可能把 `package` 与 OAM 当同一物体，单独把该封装降为 `needs_resolution`，但不要删除已闭合的共享 GCD/XCD die |
| MI210 与 MI350P 是否另建同名 package | 不建。两者公开身份均是 PCIe 卡；只证明卡内有 GCD/XCD，不足以发明同名封装 | 必须有新的官方内层封装身份才能改变；产品名稳定本身不是证据。MI350P 卡和既有历史数据继续保留但退出主线 |
| MI308X 是否跟随 MI300X/325X 归入 CDNA3 package | 不类推，暂为 `待决_不计数` | 需官方资料直接闭合 MI308X 的计算 die/package 与 OAM 关系；同系列或相似命名不够 |
| AMD GCD/XCD 怎样计数 | CDNA2 GCD、CDNA3 XCD、CDNA4 XCD、MI455X 所证实的 CDNA5 XCD各计一个共享计算 die；封装内 2/6/8 颗是组成数量 | 不把 IOD/FCD/MID 纳入 AI compute die；不把裸片颗数当作对象型号数；也不在缺证据时把 MI430X/MI440X挂到 MI455X XCD |
| Ascend 950 三个对象是否重复 | 不重复：1 个共享 Ascend 950 Die，加 950PR、950DT 两个封装变体。对象行是 3，底层硅设计是 1 | 保留现有两个 `package_contains_die` 关系；不得把两个封装各复制成新的 die。950DT 身份纳入与供货状态分开，状态可继续 `pending_verification` |
| Ascend 310P、310B 是否应补入 | 应补。官方 CANN/设备文档直接称二者为 AI 处理器或 NPU 芯片，早期 173 行遗漏 | 独立复核产品层级，不把承载它们的 Atlas 卡或设备误计为芯片；首次发布日期若需精确值，留到名单确认后的正式研究阶段 |
| MLU580 是否纳入 | 暂不计。官方 CNNL 证明“硬件支持”身份，但未像 290/370/570/590 那样进入 CNToolkit `Chip Level` 清单，芯片/板级边界没有闭合 | 若能在截止日前官方入口找到明确芯片级或封装级身份，可转纳入；不能用命名规律补齐 |
| MLU690 是否纳入 | 排除 | 截止日前没有核到官方身份；非官方线索或型号推演不能过身份门 |

建议正式关系只表达已闭合的物理复用：Ascend 950PR、950DT 分别 `package_contains_die` Ascend 950 Die；MI250/250X 指向 MI200 GCD；MI300A/300X/325X 指向 CDNA3 XCD；MI350X/355X 指向 CDNA4 XCD；MI455X 指向本轮证实的 CDNA5 XCD。组成数量属于关系属性或后续事实，不应生成重复对象。MI455X EAM 到四个 GPU packages、MI350P 卡到四个 XCD 等非芯片历史关系可以保留审计价值，但不启动新的模组或卡工作包。

## 已读取来源

本地材料包括：

- `审计/子代理交接/object_candidates.csv`；
- `审计/新会话交接_芯片名单冻结.md` 与 `进度/决策记录.md` 的 DEC-030、DEC-031；
- `数据/objects.csv`、`数据/object_relationships.csv` 中 Ascend 950、MI455X、MI350P 的现有对象和关系；
- `审计/子代理交接/m2_staging/M2-NA-ARCH/fixed-candidates/` 内 AMD CDNA2、CDNA3、CDNA4、CDNA5 官方白皮书；
- `审计/子代理交接/m2_staging/M2-W3-HUAWEI-ASCEND950-PHYSICAL/fixed-candidates/` 内华为官方页面快照；
- `审计/子代理交接/m2_staging/M2-W3-AMD-MI455X-MODULE/fixed-candidates/` 与 `M2-W3-AMD-MI350P-CARD/fixed-candidates/` 内 AMD 官方 brochure 和页面快照。

在线只定向核对了表格中列出的厂商官方产品页、发布稿、开发文档和架构白皮书，没有做媒体扩搜。若同一身份同时有本地固定版和官方网址，本交接优先以固定版核物理层级，并把官方网址作为冻结名单的身份入口。

## 验证、工具异常与写入文件

完成后按 UTF-8 无 BOM 写入并回读本文件；重新计算早期候选表共有 173 行，其中 `object_type=package` 恰好 22 行，本交接覆盖的寒武纪 6 行与华为 8 行恰好 14 行。逐表人工检查了对象层级、时间边界、训练/推理相关性、状态、排除或计数关系和官方 URL，所有候选行均至少有一个截至 2026-08-14 可识别的官方身份入口。未修改任何全局 CSV、正式对象、事实、资料卡、`README.md`、`AGENTS.md`、研究计划或 `进度/` 文件；README 和 AGENTS 已检查，任务只增加子代理审计交接，不改变项目目标、目录规则或全局状态，因此无需同步修改。

交付前已按 report-humanizer 运行机器扫描，结果为 No machine-detectable AI tells found；随后按 shuorenhua 做人工反向检查，重点核对表格引导、重复句式、术语、数字、状态枚举、路径和责任归属，未再改动受保护的事实内容。Markdown 表格共 5 张，各表列数一致；禁用的公式分隔符为 0；25 行纳入对象均能在表格中命中。

工具层面有三项已分类异常：工作区依赖定位调用曾长时间无返回，属于工具/运行时故障，终止后改用已配置的只读环境，没有影响身份核对；一次本地 PDF 文本输出因终端 GBK 编码触发 `UnicodeEncodeError`，属于命令构造/操作失误，改为 UTF-8 后已纠正；AMD 两个动态文档入口曾返回 HTTP 429，属于远端服务限流，相关身份由同厂商固定白皮书、本地快照及其他官方入口交叉闭合。寒武纪部分 SDK 页面对直接抓取有访问限制，正文身份由同一官方域名的兼容表索引和公司产品/新闻入口核对。上述异常没有引入媒体或第三方替代证据；MLU580、MI308X 等因证据不足的对象已经明确不计数。

全部写入文件只有：

- `审计/子代理交接/chip_freeze_china_amd.md`
