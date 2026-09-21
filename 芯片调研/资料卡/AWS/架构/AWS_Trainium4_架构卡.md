# AWS Trainium4 架构资料卡（观察对象）

- 对象：`OBJ-AWS-TRAINIUM4-ARCH`
- 层级：`architecture_generation`
- 资料截止日：2026-08-12
- 状态：前瞻性公告，AWS 预计 2027 年交付
- 取证规则：只采用截止日前一手明示内容；不假定 NCv5，不从相对倍数推导绝对规格。

## 已确认内容

截止日内能够进入架构对象的只有代际身份和前瞻状态：`FACT-M2GA-ATRN4-NAME` 与 `FACT-M2GA-ATRN4-STATUS`。2026-02-05 的 Amazon 投资者关系稿给出预计 2027 年交付，并宣称相对 Trainium3 的 FP4、内存带宽和 HBM 容量倍数。这三项是未来具体芯片的相对实现指标，已分别转入实现 `待办` `DEF-M2GA-ATRN4-01` 至 `DEF-M2GA-ATRN4-03`；没有据此生成绝对峰值、容量、带宽或存算比。

没有一手资料明确 Trainium4 的 Tensor/Vector/Scalar/GpSimd 组织、阵列形态、输入/乘积/累加/输出精度、片上存储层次、DMA、NeuronLink 版本、collective 模块、MoE/Top-K 专用能力或 NKI 映射。邻近 Trainium3/NCv4 的事实不能上卷或外推到本对象。

## 结构化事实明细

本卡对应 2 条 正式事实。下列标识逐条回指 `数据/facts.csv`：

- `FACT-M2GA-ATRN4-NAME`
- `FACT-M2GA-ATRN4-STATUS`

## 完整度与缺口

| 域 | 状态 | 说明 |
|---|---|---|
| identity | complete | 名称、公告日期和预计交付年明确 |
| physical | not_applicable | 未来工艺、封装、HBM 实现归 silicon_package |
| compute | missing_public_data | 执行组织和阵列未公开 |
| numerics | missing_public_data | 只出现相对 FP4 性能，没有精度链 |
| memory | missing_public_data | 只出现相对容量/带宽，没有层级与管理机制 |
| interconnect | missing_public_data | 未公开 NeuronLink 或其他互联机制 |
| special_engines | missing_public_data | 未公开 dedicated collective/MoE/Top-K 等模块 |
| software | missing_public_data | 未公开 Trainium4 专属软件映射 |
| evidence | complete | 已采用内容由一份带日期的一手公告直接支持 |

`SEARCH-M2GA-TRN4-MICRO` 检查官方架构页、版本化 Neuron 文档和带日期发布后为 `no_reliable_result`；`REQ-M2GA-TRN4-MICRO=not_found`。四条 `REQ-M2GA-AWS_TRAINIUM4_ARCH-*` 对架构对象为 `not_applicable`，表示芯片 total 的目标层级不适用，而不是把相对指标判成不存在。

## 最小来源与实现边界

| 来源 | 定位与独有贡献 | 处理 |
|---|---|---|
| `SRC-M2-GA-A09` | Amazon 2026-02-05 earnings release | 必须保留，是 Trainium4 身份、预计 2027 和三项相对指标的唯一一手来源；前瞻性陈述需保留限定 |

目前没有第二个一手架构来源，也没有固定白皮书。未来出现正式架构页时，应先建立对应 silicon_package，再把 `DEF-M2GA-ATRN4-01` 至 `03` 与新值按版本和作用域重审。本卡 facts 只有对象目标，七目标 XOR 成立；没有媒体、实例或 UltraServer 推断。正式合并状态：`accepted / future_explicit_only`。