# 训练与推理芯片名单候选稿独立复核

> 复核结论：`accept_for_user_confirmation`。当前稿可以提交用户确认，但不能据此标为正式冻结。

## 复核范围

本次复核以 `AGENTS.md`、`审计/新会话交接_芯片名单冻结.md`、DEC-030、DEC-031，以及厂商初审交接为边界，逐行检查了 `审计/训练推理芯片名单冻结.csv` 和 `审计/训练推理芯片名单冻结验收.md`。复核者没有参与全局候选稿的合并，也没有改动这两个全局文件。

核对只涉及产品身份、物理对象层级、时间桶和纳入边界。die 指厂商稳定命名的计算裸片，package 指能与外层板卡或模组分开的单颗芯片封装。本次没有展开规格调研、媒体检索、事实抽取或资料卡生产，也没有继续模组、PCIe 卡、云实例、服务器、机架和 Pod 工作包。

## 最终复算

复核时的 CSV 共 73 行。当前计入完成度的对象为 41 个，其中主样本 30 个、历史锚点 11 个；按对象层级分为 11 个 die 和 30 个 package。41 个对象归入 38 个 `silicon_design_group`。其余为 7 个观察对象、5 个边界待决对象、1 个用户计数待决对象和 19 个排除对象。

| 厂商 | 主样本 | 历史锚点 | 计数对象 | die | package | 硅设计组 |
|---|---:|---:|---:|---:|---:|---:|
| NVIDIA | 9 | 1 | 10 | 6 | 4 | 10 |
| Google | 5 | 2 | 7 | 0 | 7 | 7 |
| AWS | 4 | 1 | 5 | 0 | 5 | 5 |
| Groq | 0 | 1 | 1 | 0 | 1 | 1 |
| 寒武纪 | 2 | 2 | 4 | 0 | 4 | 4 |
| 华为 | 6 | 3 | 9 | 1 | 8 | 7 |
| AMD | 4 | 1 | 5 | 4 | 1 | 4 |
| 合计 | 30 | 11 | 41 | 11 | 30 | 38 |

38 个硅设计组少于 41 个对象，差额来自两组共享设计：Ascend 950 Die、950PR、950DT 三行共用一个设计组；CDNA 3 XCD 与 MI300A APU package 两行共用一个设计组。若用户同意纳入 MI455X GPU package，计数对象会由 41 增至 42，但它与 CDNA 5 XCD 共用设计组，因此设计组仍为 38 个。

早期候选表实有 173 行，其中 `object_type=package` 的 22 行全部闭环：17 行进入当前计数，2 行进入未来观察，1 行保持边界待决，1 行因 GH200 是多处理器模组而排除，1 行因 MLU690 未通过官方命名门而排除。22 个候选 ID 均恰好命中一次，没有遗漏或重复。全表共引用 50 个早期候选 ID，50 个引用均唯一且有效。

## 复核中完成的修正

初稿中的几处高风险判断已经在最终 73 行稿中改正。

GB203 不应排除。NVIDIA 的 [RTX PRO 4500 Blackwell Server Edition 产品页](https://www.nvidia.com/en-us/data-center/rtx-pro-4500-blackwell-server-edition/)明确写有 “Available Now”，并把产品用于数据中心、边缘、云和 AI 推理；[MIG 支持表](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-gpus.html)又把该产品映射到 GB203。最终稿据此把 GB203 die 纳入主样本，并只把 RTX PRO 4500 Server Edition 视为外层卡。

GroqChip 不能因为 2022 年或 2024 年的文档修订而算作主样本期新芯片。Groq 的 [2020 年 ISCA 论文](https://groq.com/wp-content/uploads/2020/06/ISCA-TSP.pdf)已经公开第一代实现，[2021 年官方融资稿](https://groq.com/newsroom/groq-closes-300-million-fundraise)也确认首款产品已经推出。最终稿将第一代 GroqChip 改为历史锚点；v1.5、v1.7 只作同一产品的文档版本，不增加对象。

L2 与 H20 BFX 原先没有逐项闭环。最终稿新增两条不计数的 `pending_boundary`：L2 的官方驱动文档只把产品映射到 Ada Lovelace 架构，没有给出底层 die 或 package；H20 BFX 在同一版官方驱动文档中分别被放入 Blackwell 和 Hopper，两处口径冲突，DOCA 文档又称其为 BFx H20 converged accelerator。现阶段不能把它强行并入 GH100 或某个 Blackwell package。两条新增行只补齐候选闭环，不改变 41 个对象的基数。

RTX PRO 6000D 则不属于待决项。[NVIDIA NuRec 硬件页](https://docs.nvidia.com/nurec/basics/hardware.html)在 Blackwell 段直接给出 `Board: RTX Pro 6000D` 和 `GPU (Codename): GB202`，足以把该卡闭环到现有 GB202 die。最终稿保留 6000D 与 GB202 的关系，没有另建芯片行。

AMD 采用保守且可复核的物理边界：CDNA 2 的 GCD，以及 CDNA 3、4、5 的 XCD，均按共享计算裸片设计各计一次，不按一个产品内的裸片数量放大。MI300A 由官方“单一封装”表述支持，作为 package 另计。MI210、MI350P 是 PCIe 卡；MI250/250X、MI300X/325X、MI350X/355X 是 OAM（OCP Accelerator Module，开放计算项目加速模组）市场对象，现有官方材料不足以把同名内层 package 与外层 OAM 稳定分开，因此不另造封装对象。MI455X 例外：其[官方 brochure](https://www.amd.com/content/dam/amd/en/documents/products/accelerators/instinct/amd-instinct-mi455x_brochure.pdf)明确区分内层 multi-chip GPU package 与承载四个 GPU packages 的外层 EAM（Enterprise Accelerator Module，企业加速模组）。最终稿仍把内层 package 留给用户裁决，外层 EAM 继续排除。MI455X 模组和 MI350P 卡的历史正式数据均未删除。

## 高风险边界结论

NVIDIA GH200 是 Grace CPU 与 GH100 GPU 的组合模组，不计芯片对象，只由 GH100 die 承接 GPU 本体。Blackwell、Blackwell Ultra 和 Rubin 均有官方资料说明多个内部裸片作为一个统一 GPU 或位于单一 package，且内部 reticle 级裸片没有稳定独立产品名，因此各按一个 package 计数。Rubin CPX 已正式命名，但官方预计 2026 年末可用，保持未来观察，不进入当前分母。

华为官方明确 950PR 与 950DT 共用一个 Ascend 950 Die，并采用不同的高带宽内存封装。按用户已给出的边界，名单保留 1 个 die 和 2 个 package，共三行、一个硅设计组。这个处理没有把共享裸片重复计为三种设计。

未来时间桶也一致：主样本仍是 2022-01-01 至 2026-08-12，2026-08-13 至 2026-08-14 只用于身份核对。已经正式命名但尚未交付的对象进入观察桶；身份或物理层级未闭合的对象进入待决桶；没有官方命名的推测型号排除。GroqChip 改为历史锚点后，未再发现把文档更新时间误当作新芯片发布时间的硬问题。

## 结构、来源与正式数据保护

CSV 的 73 个行 ID 全部唯一，厂商加规范名称也没有重复；24 个字段中，按本轮合同检查的必填字段空值为 0，日期格式错误、计数布尔值错误、计数状态不一致和占位符命中均为 0。文件是有效 UTF-8，带 BOM，共 74 个物理行。七个厂商均有记录。

73 行各有一个 HTTPS 官方入口，域名均属于对应厂商或其官方文档、研究、新闻站点；没有用媒体来源支撑产品身份。NVIDIA L2、H20 BFX 等官方口径未闭合的对象没有用第三方资料补推。DEC-030 的“官方一手来源覆盖后停止媒体扩搜”得到遵守。

所有 73 行的 `freeze_state` 仍是 `candidate_pending_user_confirmation`，候选稿没有被写成正式冻结。复核签字形成后，主代理已把 73 行 `independent_review_status` 精确回填为 `reviewed_accept_for_user_confirmation`。只读校验器复跑结果如下：

- `Validate-ResearchData.ps1`：通过，32 张正式表、125,619 项检查，注册列 324 个、枚举值 488 个；
- `Test-ChipScope.ps1`：通过，正式库仍是 78 个对象，其中 10 个 `chip_primary`、29 个架构证据对象、39 个非芯片对象；
- 32 张正式表按既定算法复算的聚合 SHA-256 为 `5f62191bfc737535802cd6e0524b1fdf7a742ca36300db11b5a9233d4540052a`，与项目当前正式基线一致。

本次实质复核绑定的 CSV 快照 SHA-256 为 1b31c1b1a346e9be6affc7f79511897d1732f26e8995ec2940d1e47c687ba29f。主代理随后只把 73 个 `independent_review_status` 从 `pending` 回填为 `reviewed_accept_for_user_confirmation`，回填后 CSV SHA-256 为 51a9010c2790b48da8c221b8954757e0f6338742bb1a95bbf1a34ed4cbe100b3；将这 73 个状态值在内存中还原为 `pending`，可精确重建前述签字快照哈希。候选验收稿的实质复核快照 SHA-256 为 40d9e3223be8bbe8c289ce80e42be1210d91b739d67d46cf245ff589a60e8cb2；主代理回填独立复核结论和修正摘要后，当前 SHA-256 为 386e554c3b91716a2f32f4f0df9a879827250ba34965c2ceca1803ac67bfda95。

这说明本轮只新增候选冻结与审计材料，没有改写现有正式对象、事实、断言、来源选择或资料卡。

## 提交用户确认前仍需决定的事项

唯一会立刻改变计数基数的问题是 MI455X GPU package。现有官方证据已经清楚区分内层 package 与外层 EAM，我的建议是纳入：这样总数为 42，AMD 为 6，硅设计组仍为 38；无论是否纳入，MI455X EAM 都不进主线。

其余问题不会立刻改变当前基数，但需要用户确认是否维持保守口径：其他 AMD OAM/PCIe 市场型号继续只由共享 GCD/XCD 承接；Rubin CPX、TPU 8t/8i、Trainium4、Ascend 960/970、MI430X 保持观察；L2、H20 BFX、MLU580、MI308X、MI440X 保持边界待决。若用户维持这些口径，当前 41 个对象即可作为候选冻结基数。

## 签字结论

结论为 `accept_for_user_confirmation`。当前 73 行稿没有剩余的硬性结构、来源、对象层级或时间边界阻断，可以把完整候选名单和上述争议提交用户确认。独立复核状态已经回填，但此结论仍只授权进入用户确认门，不授权把名单标为正式冻结；收到用户确认并处理 MI455X 等指定选择后，主代理还需再次复算，才能执行正式冻结。

本代理只写入本交接文件。按分工约束，没有修改全局 CSV、验收稿、`进度/`、`README.md` 或 `AGENTS.md`；后两者已检查，本次独立复核没有改变项目长期目标、目录、运行方式或协作规则，因此无需由本代理更新。
