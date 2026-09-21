# MI350P 来源与事实审计

> 工作包：`M2-W3-AMD-MI350P-CARD`  
> 截止日：2026-08-13  
> 当前状态：`ready_for_final_independent_review`

## 事实边界

本包只处理 `OBJ-AMD-MI350P`，也就是单张 AMD Instinct MI350P PCIe 加速卡。修正后的事实集有 40 条直接事实，恰好达到预算上限；没有系统、OAM（OCP Accelerator Module，开放加速器模组）、机架、相邻 SKU 或每 CU（Compute Unit，计算单元）数值进入事实表，也没有派生事实。

独立复核发现产品页明确列出 `Transistor Count: 73 Billion`，原冻结包却漏记。修正新增 `FACT-M2W3-AMD-MI350P-TRANSISTORS`，把 73 Billion 规范化为 73,000,000,000 count；配套断言是 `ASSERT-M2W3-AMD-MI350P-TRANSISTORS-PRODUCT`，定位到产品页 `HTML lines 7509-7520, GPU Specifications`；字段要求是 `REQ-M2W3-AMD-MI350P-TRANSISTORS`。该事实只落在整卡对象，不拆分到四个 XCD（Accelerated Compute Die，加速计算裸片）或一个 IOD（I/O Die，输入输出裸片）。

40 条事实包括 6 条身份与状态、10 条物理、3 条产品级计算资源数、3 条存储、2 条 PCIe，以及 16 条矩阵或向量峰值。基础行的稀疏状态保留 `not_specified`，结构化稀疏行保留 `structured_sparse`；INT8 使用 OP/s，其他行使用 FLOP/s。峰值都是厂商理论值，不写成持续实测性能。

MoE（Mixture of Experts，混合专家）routing、Top-K 等没有产品级专用硬件证据，所以不创建占位 capability。相关结论只写入字段要求和检索日志。存算比、每瓦性能和 PCIe 单向或双向换算也因前置条件不闭合而不计算。

## 峰值责任来源修正

产品页的矩阵峰值有明确的 matrix 标签，因此继续直接承担 13 条矩阵峰值断言。固定简报第 1 页的 `HPC Peak Performance (Estimated)` 表明确列出 `FP16 VECTOR`、`FP32 VECTOR` 和 `FP64 VECTOR`，因此三条向量事实改由简报直接承担。原来的三个 `*-VECTOR-PEAK-PRODUCT` 断言已经删除，替换为：

- `ASSERT-M2W3-AMD-MI350P-FP16-VECTOR-PEAK-BROCHURE`
- `ASSERT-M2W3-AMD-MI350P-FP32-VECTOR-PEAK-BROCHURE`
- `ASSERT-M2W3-AMD-MI350P-FP64-VECTOR-PEAK-BROCHURE`

产品页仍给出 72、72、36 TFLOP/s 的同值 performance 行，但没有 vector 标签。它只作数值交叉核对，不再保留重复断言。三条向量事实继续使用 `theoretical_peak`，并保留简报的 `Estimated` 条件。

## 来源选择与反向移除

修正后重新对 40 条事实运行 `SELRUN-M2W3-AMD-MI350P-20260813`。对象最小集只含三个来源：精确产品页承担当前身份、730 亿晶体管、卡级资源、内存、散热和矩阵峰值；固定简报 `LE-93401-00 05/26` 独有四 XCD、一 IOD、完整 FHFL CEM 形态、PCIe 128 GB/s 与直接向量分类；2026-05-07 官方文章独有日期化 available 状态。删除其中任一来源，都会丢失正式事实或必要的分类证据。

`SRC-M2NA-AMD-CDNA4-WP` 和 `SRC-M2NA-AMD-CDNA4-ISA` 不直接支持 MI350P 卡事实，已经从 selection member、selected role 和 coverage 中移除。两条 screening 改为 `lead_only`，仍可用于架构边界和 `checked_no_support` 缺口检索。白皮书中的 MI350X、MI355X OAM、八 OAM 平台、8 XCD、2 IOD、288 GB、8 TB/s、1000 W 与 1400 W 等值迁移量为 0；ISA 的 C/D、累加和稀疏指令语义也没有复制到产品卡。

D-1 与 D-7 完成身份门后被反向移除出结构化最小集。D-1 的精确 MI350P 数据行被产品页覆盖；D-7 的作用是区分 PCIe 卡与 MI350X、MI355X platform。原始快照仍保留在 `fixed-candidates/`，没有删除。

## 重叠、差异与冲突

产品页和简报存在大量重叠。名称、制程、时钟、两个 TBP 条件、卡形态、HBM 容量与带宽、PCIe 协议继续保留双来源支持；其余重叠不为增加来源数而重复录入。修正后 49 条断言覆盖 40 条事实，其中 9 条是第二来源支持。

当前差异不构成 unresolved true conflict。产品页的 Passive 是卡级散热，air-cooled systems 是服务器部署条件；简报直接提供 estimated vector 分类，产品页的同值通用 performance 行只交叉核对数值；D-1 的内部数据表示不替代可见的 4 TB/s；Product Basics 的 Servers 是目录分类，不替代 Board Specifications 的 PCIe Add-in Card。因此 `conflict-groups.csv` 和 `conflict-members.csv` 保持空表。

## 缺口与检索

46 条字段要求中，34 条为 `value_available`，12 条为 `not_found`。缺口包括发布日期、首次可用日期、HBM 堆叠数、裸片面积、A/B/乘积/累加/物理累加/OCP-FP8 输出、MoE/Top-K 专用实现和版本化 runtime。检索规模没有因修正扩大，仍是 12 条日志和 56 条逐来源结果；身份与日期缺口检查三个产品来源，数值语义和特殊实现缺口还把 CDNA 4 白皮书与 ISA 作为 `lead_only` 线索检查。

`not_found` 表示按计划检查后没有找到可靠的对象匹配证据，不代表厂商明确声明未公开，因此不使用 `not_public`。未知值没有写成零。

## 当前验证节点

修正后的包级校验通过 1,082 项检查，事实主体合同和字段要求目标合同不一致均为 0，九域完整度恰有九行，本地 endpoint 的 SHA-256 与冻结文件一致。以 f152 正式基线执行临时合并后，正式验证器在 `gate` 模式通过 111,343 项检查，字段注册表为 324 列、488 个枚举值。临时镜像已经清理；正式库随后再次通过 106,160 项检查，32 张 CSV 的逐文件哈希与基线一致。