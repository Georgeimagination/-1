# 寒武纪 MLUarch05 架构资料卡

对象 ID：`OBJ-CAMBRICON-MLU590-ARCH`，正式名称事实沿用库内已有的 `MLUarch05`，不新增重复事实。本卡是架构代际卡，不是思元590 裸片、封装或加速卡，也不是 BANG 软件版本对象。

## 当前能确认的内容

寒武纪 2022 年 WAIC 官方页面把思元590与 MLUarch05 直接关联；这个名称事实和相应对象关系已经在正式库中，本卡只复用。固定的 MLU-OPS 提交还显示 `--mlu590` 会选择 `mtp_592`，帮助文本列出 `__BANG_ARCH__=592`。这些是软件构建目标和编译宏，可以证明工具链存在一个 592 目标，但不能证明片上存储容量、物理单元数量，也不能证明它与 MLUarch05 或 BANG v5 完全等价。

可访问的一手资料没有公开 MLUarch05 的矩阵、向量或标量执行组织，也没有给出架构级数据格式、累加精度、存储层级与带宽、存算比、互联拓扑或通信带宽。上述字段全部按 `not_found` 记录，没有用媒体数字、相邻产品参数或软件宏补空。制程、时钟、面积、晶体管和功耗属于具体物理对象，在本架构代际卡中标为 `not_applicable`。

## BANG 与物理架构的分层

BANG v2、v3、v5 目前都只保留候选身份，不建立正式架构对象。官方思元370页面直接写的是物理架构 `MLUarch03`，这说明 BANG v3 不能默认等同于 MLUarch03。思元290-M5 / 玄思1000 页面只确认产品身份，没有给 BANG v2 或物理架构名。对于 v5，`MLUarch05`、`BANG v5.0`、`compute_50`、`mtp_592` 和 `__BANG_ARCH__=592` 分属物理架构、软件版本、计算目标、平台目标与编译宏等不同语义层，数字相近不足以合并。

CNToolkit 3.8.4 Components 的正文已知存在，但 2026-08-12 直接访问返回远端 HTTP 401 Unauthorized。这是远端访问限制，不是沙箱、审批或模型能力问题。正文不可访问且等价关系未证实，所以状态是 `inaccessible_evidence`，不是 `conflicting_unresolved`；当前没有两个可靠来源对同一对象提出互斥命题，因此不建立冲突组。

## 特殊能力与软件映射

可访问来源没有说明专用 MoE routing 或 Top-K 物理模块，两项均记为 `not_found`。即使以后在 CNNL 或 BANG 文档中找到同名算子，也只能先证明软件接口支持，不能自动推出专用硬件。

## 最小来源集

正式事实继续复用现有 WAIC 页面和固定 MLU-OPS 提交，不重复注册。思元370产品页只用于 BANG v3 身份审计，思元290-M5 页面只作 v2 线索。CNToolkit 3.8.4 保留为受限入口，待获得可访问固定正文后再验证标识映射。

## 追溯合同

本卡不新增直接事实。架构正式名称复用 `FACT-CAMBRICON-MLUARCH05-OFFICIAL-NAME`，由 `SRC-2022-CAMBRICON-WAIC-MLU590` 支撑，定位为 2022 WAIC 页面中“思元590”“MLUarch05”。软件构建目标复用 `FACT-CAMBRICON-MLU590-MLUOPS-BUILD-TARGET-67B3707F`，但该事实的 owner 是正式芯片对象 `OBJ-CAMBRICON-MLU590-CHIP`，不是本架构对象；其来源 `SRC-CAMBRICON-MLU-OPS-COMMIT-67B3707F` 定位为固定提交 `independent_build.sh` 的 `--mlu590` / `mtp_592` 和帮助文本 `__BANG_ARCH__=592`。它只作为身份分层旁证，不能写进 MLUarch05 的架构事实。

九域完整度为：identity `complete`；physical `not_applicable`；compute、numerics、memory、interconnect、special_engines、software 为 `missing_public_data`；evidence 为 `partial`。结构化记录见 `CC-CAMBRICON-MLU590-ARCH-*`。

执行组织、矩阵/向量/标量、格式、累加、存储、互联、MoE 与 Top-K 均通过 `REQ-CAMBRICON-MLUARCH05-*` 记录为 `not_found`，对应 `SEARCH-CAMBRICON-MLUARCH05-*`。BANG 映射为 `REQ-CAMBRICON-MLUARCH05-BANG-MAPPING` / `SEARCH-CAMBRICON-MLUARCH05-BANG-MAPPING` 的 `inaccessible_evidence`；要求证据 `REQE-CAMBRICON-BANG-MAPPING-INACCESSIBLE` 指向正式来源 `SRC-CAMBRICON-CNTOOLKIT-3-8-4-COMPONENTS` 的 HTTP 401 入口。没有 `conflicting_unresolved`，也没有冲突组。

正式事实来源复用 `SRC-2022-CAMBRICON-WAIC-MLU590` 与 `SRC-CAMBRICON-MLU-OPS-COMMIT-67B3707F`。本次整理另将 `SRC-CAMBRICON-MLU370-PRODUCT-2026-08-12` 用于 v3 身份审计；`SRC-CAMBRICON-MLU290M5-PRODUCT-2026-08-12` 只作 v2 线索，筛选状态为 `lead_only`。CNToolkit 正文不可访问，未采用搜索摘要生成事实。

对象与实现待办边界：MLUarch05 是 architecture_generation；思元590 的制程、时钟、面积、功耗、吞吐、容量和互联定值需要后续 die/package/card 对象，不能写入本卡。BANG v2/v3/v5、compute_50、mtp_592 与 `__BANG_ARCH__=592` 均保持不同语义层。

验收：独立复核结论为 `accept`。总控已将本卡对应的结构化数据与来源链写入正式库；正式验证器通过 46,985 项检查，资料池校验核对 107 份 PDF，并保留 1 个既有解析器警告。