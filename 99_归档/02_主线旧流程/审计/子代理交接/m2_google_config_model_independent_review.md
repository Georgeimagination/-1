# Google TPU 云配置对象模型独立复核

复核日期：2026-08-13  
复核角色：未参与 `m2_google_config_model_review.md` 的撰写  
裁决：`accept_with_fixes`  
写入范围：仅本报告；初稿、正式对象表、关系表、来源库和资料卡均未修改。

## 裁决

三层边界的主方向成立：单个云端 TPU 器件用 `cloud_accelerator`，TPU VM 或机器类型家族用 `cloud_instance`，有独立系统身份和拓扑事实的 Slice、Pod 或 Superpod 用 `pod`。所需的 `object_type` 均是正式已批准枚举。三种关系也已有正式枚举：云端器件指向架构使用 `implements_architecture`，机器类型指向器件使用 `instance_contains_accelerator`，未来物理封装指向云端器件使用 `exposed_as_cloud_accelerator`。关系方向与正式 AWS 实例关系的现有用法一致。

当前不能按初稿直接预留对象或开工。精确阻断有四项：十条待办中只有九条能被三张器件卡完整关闭，`DEF-M2GA-GV5P-03` 还含 96 GiB 物理分支；v5p 的 95/96 GiB 只能先做跨对象作用域假设，不能写成已经证实的“云可见容量与物理容量”；来源冻结清单漏了 `SRC-M2-GA-G15`，并且 `tpu-machines` 尚无正式 source/endpoint；第三层所说的“配置行”还需明确结构化事实挂在哪个正式对象上。修正这四项并完成范围补裁决后，三器件包可以启动。

## 正式模型与关系方向

正式枚举复算如下：`cloud_accelerator`、`cloud_instance`、`pod`、`package` 均为已批准 `object_type`；`implements_architecture`、`instance_contains_accelerator`、`exposed_as_cloud_accelerator` 均为已批准 `relation_type`。现有 `OBJ-GOOGLE-CT6E-STANDARD-FAMILY` 是 `cloud_instance / reviewed`，范围映射明确把它定义为 TPU VM machine type 家族，1t、4t、8t 先作为配置行。正式库当前没有任何指向或发自该对象的关系，也没有其他 Google 对象关系。

三条器件到架构的关系方向正确，候选应固定为：

| subject | relation_type | object |
|---|---|---|
| `OBJ-GOOGLE-TPU-V5E-CLOUD-DEVICE` | `implements_architecture` | `OBJ-GOOGLE-TPU-V5E-ARCH` |
| `OBJ-GOOGLE-TPU-V5P-CLOUD-DEVICE` | `implements_architecture` | `OBJ-GOOGLE-TPU-V5P-ARCH` |
| `OBJ-GOOGLE-TPU-V6E-CLOUD-DEVICE` | `implements_architecture` | `OBJ-GOOGLE-TPU-V6E-ARCH` |

三个架构端点都已存在并为 `reviewed`。三枚新 object ID、建议 slug `google-tpu-v5e-cloud-device`、`google-tpu-v5p-cloud-device`、`google-tpu-v6e-cloud-device` 以及相应关系 ID 在当前正式库中的碰撞数均为 0；它们仍未进入 `M2_对象范围映射.csv`，所以碰撞为 0 不能代替范围批准。预留时对象和新关系均应先用 `needs_resolution`，等固定身份页、关系端点和独立验收闭合后再晋级。

`OBJ-GOOGLE-CT6E-STANDARD-FAMILY` 到 v6e 器件应使用以下方向：

```text
OBJ-GOOGLE-CT6E-STANDARD-FAMILY
  | instance_contains_accelerator
  v
OBJ-GOOGLE-TPU-V6E-CLOUD-DEVICE
```

这条关系目前不存在，属于待建关系。1t、4t、8t 的 1、4、8 芯片数量不能写进关系备注或从家族关系推断；应作为以该关系为目标、带机器类型条件的 `FIELD-REL-QUANTITY` 事实。若以后某个机器类型需要独立生命周期或被其他事实引用，再从家族配置行升级为独立 `cloud_instance` 对象。

初稿对第三层的表述还差一个结构化落点。“配置行”只是资料卡展示形式，不能成为无外键的事实所有者。机器类型的参数化配置可以挂在 `cloud_instance` 家族或相应关系上，并用条件集区分；具有独立拓扑、主机数、总芯片数、生命周期或可调度上限的 Slice/Pod 应建立 `pod` 对象，再把拓扑实体和系统事实挂到该对象。三张器件卡不受这个缺口影响，后续配置包在落表前必须先补这条规则。

## 十条 GA deferred 的承接边界

正式待办中，v5e 有 4 条、v5p 有 6 条、v6e 有 4 条，共 14 条。三张云端器件卡对应的云端范围是 v5e 的 4 条、v5p 的 `03` 与 `06`、v6e 的 4 条，表面计数为 10。逐行复核后，准确说法应是“完整承接 9 条，再承接 1 条混合待办的云端分支”。

| 器件卡 | 可完整承接 | 需要保留的边界 |
|---|---|---|
| v5e | `DEF-M2GA-GV5E-01..04` | 组件数量、峰值、HBM、ICI 都按单个云端 TPU 器件建模；`16 GB` 与 `800 GiB/s` 的原始单位分别保留，ICI 带宽保留双向聚合条件 |
| v5p | `DEF-M2GA-GV5P-06`；`DEF-M2GA-GV5P-03` 的 95 GiB 分支 | `GV5P-03` 不能整行关闭，96 GiB 分支继续留在物理实现待办 |
| v6e | `DEF-M2GA-GV6E-01..04` | `GV6E-01` 的 SparseCore 数量依赖 `SRC-M2-GA-G15`；ICI 保留端口数和双向聚合范围 |

`DEF-M2GA-GV5P-01`、`02`、`04`、`05` 仍是纯 `silicon_package` 待办。加上 `GV5P-03` 的 96 GiB 分支，物理包还有五个需要处理的项目，其中一个与云端包共享原始 deferred ID。正式 staging 不应把一个主键标成“已处理一半”。开工前应把 `GV5P-03` 拆成两个有持久 ID 的处置项，或者保留一张父待办并建立两个子处置记录；云端包只能关闭 95 GiB 子项。

每条复合待办落表时仍要拆成原子事实。执行单元数量归相应组件，峰值归精度路径，HBM 归器件拥有的存储组件，ICI 端口和带宽归互联或关系实体。把它们放进同一张器件卡不等于把多项原值塞进一条 `facts.csv` 记录。

## v5p 的 95/96 GiB

现有边界日志把这组差异定为 `implementation_scope_or_reserved_capacity_ambiguity`，并明确禁止擅自解释为预留量。`SRC-M2-GA-G09` 的云产品页给出 95 GiB，固定架构论文 `SRC-M2-GA-G01` 的物理表给出 96 GiB；`SRC-M2-GA-G15` 只用于 v6e SparseCore，不支持这组容量值。初稿把 95 GiB 直接归云端器件、96 GiB 直接归未来物理封装，适合作为建模候选，但证据尚未证明这两个对象就是差值的完整原因。

安全写法是分别保存来源原值、单位、定位和对象作用域：95 GiB 在云端器件身份闭合后可写为该云端器件的直接事实；96 GiB 等物理 package 身份闭合后再写到物理对象。两条事实都应先保持 `provisional` 或相应待核状态，并保留跨对象边界记录。不得推导 1 GiB 被系统预留，不得平均、换成一个“约 96 GiB”，也不得仅因分到两个对象就宣布差异已经解决。未来建立 `package -> exposed_as_cloud_accelerator -> cloud device` 关系后，再审查两条事实的有效期、页面版本和可见容量定义。

## 五个旧 ID

以下五个旧 ID 在当前 `objects.csv`、`object-relations.csv` 和 `M2_对象范围映射.csv` 中命中均为 0，可以撤回，不需要从正式库删除任何行：

- `OBJ-GOOGLE-TPU-V4-SLICE-FAMILY`
- `OBJ-GOOGLE-TPU-V5LITEPOD-CONFIG-FAMILY`
- `OBJ-GOOGLE-TPU-V5P-SLICE-FAMILY`
- `OBJ-GOOGLE-TPU-V6E-CONFIG-FAMILY`
- `OBJ-GOOGLE-TPU7X-SLICE-FAMILY`

它们仍出现在旧排队审计、对象预留候选报告和红队报告中，这些文件是历史审计记录，不应回写删除。总控只需在当前排队或对象预留决策中把五个 ID 标为 `superseded/withdrawn`，并确保后续脚本不再把旧报告里的 CSV 候选块当作可执行输入。原始 `object_candidates.csv` 同样保留，不把历史候选误改成正式裁决。

## 来源冻结缺口

初稿列出的 v5e、v5p、v6e、TPU VM system architecture 和 `tpu-machines` 五页方向正确，但还不完整。当前正式来源状态如下：

| 页面或来源 | 当前正式状态 | 本包处理 |
|---|---|---|
| `SRC-M2-GA-G08`，v5e | `dynamic_unfrozen / draft`，endpoint 无本地路径和 SHA-256 | 固定 HTML，承担 v5e 四条待办 |
| `SRC-M2-GA-G09`，v5p | `dynamic_unfrozen / draft`，在架构事实集合中为 `redundant_covered` | 固定 HTML；新器件事实集合变化后重做 screening 和 selection，不能沿用架构包的冗余结论 |
| `SRC-M2-GA-G10`，v6e | `dynamic_unfrozen / draft` | 固定 HTML，承担 v6e 主要器件事实 |
| `SRC-M2-GA-G15`，SparseCore | `dynamic_unfrozen / draft` | 初稿漏列；必须固定，否则 `DEF-M2GA-GV6E-01` 的 2 个 SparseCore 没有完整冻结证据 |
| `SRC-M2-GA-G05`，TPU VM system architecture | `dynamic_unfrozen / draft` | 固定 HTML，用于器件、VM、worker 与 sub-host 的术语边界 |
| `tpu-machines` | 只在 `清单/网页与在线资料.csv` 有线索，正式 sources/endpoints 中命中 0 | 先建 source family、source 和 endpoint，再固定 HTML；用于机器类型与芯片数交叉核对 |
| `SRC-M2-GA-G01` | 固定本地 PDF，SHA-256 已登记 | 只复用 96 GiB 物理分支，不把它复制成云端 95 GiB 的支持来源 |

每个动态页面都要记录最终 URL、标题、页面更新时间、访问日、HTTP 状态、字节数、本地相对路径和 SHA-256。快照后应创建新的器件事实选择运行；GA 架构包现有 selection 只对 141 条架构事实成立，不能覆盖新的云端器件事实集合。网页尚未固定时可以做只读抽取准备，但不得据此合并器件事实或把新来源选择标为 `reviewed`。

## 合并前阻断

本复核接受三器件模型，以下事项在正式对象预留或 staging 写入前必须全部关闭：

1. 补范围映射裁决，冻结三枚 object ID、slug、`cloud_accelerator / needs_resolution` 状态，以及三条架构关系和一条 CT6E 包含关系的完整候选行。
2. 将 `DEF-M2GA-GV5P-03` 拆成云端 95 GiB 与物理 96 GiB 两个可独立关闭的处置项，保留作用域不确定性。
3. 把 `SRC-M2-GA-G15` 加入冻结清单，为 `tpu-machines` 建正式来源记录，并固定本节列出的动态页面。
4. 明确配置行的结构化目标规则；有独立系统事实的 Slice/Pod 使用 `pod`，其余参数化配置必须挂到已有对象或关系并带条件集。
5. 在新器件事实集合上重跑来源筛选与反向移除；不得沿用 `SRC-M2-GA-G09` 在架构集合中的 `redundant_covered` 结论。

关闭后，裁决可升为 `accept`。在此之前，三张器件卡可以准备字段拆分和来源定位，但不能写入正式对象、关系、事实、断言或最小来源选择。

## 验证与文档检查

本复核只读取初稿、正式 `objects.csv`、`object-relations.csv`、`enums.csv`、范围映射、GA 实现待办、正式来源和 endpoint 记录，以及对应 staging 边界日志。没有把未冻结网页的当前内容当作新证据。

复算结果为：14 条 v5e/v5p/v6e deferred 中，9 条完整属于云端器件，1 条为云端与物理混合，4 条完整属于物理实现；三枚新 ID、三枚建议 slug 和四枚建议关系 ID 均无正式碰撞；三个架构端点存在且为 `reviewed`；CT6E 家族存在且为 `reviewed`，其现有关系数为 0；五个旧 ID 在正式对象、关系和范围映射中的命中数均为 0。

一次只读碰撞命令把简写形式的 `Where-Object` 与 `-and` 混用，触发参数集解析错误。这是操作者的命令构造问题；改用脚本块后复算成功，没有写文件，也不影响上述结论。根 `README.md` 与 `AGENTS.md` 已按只读方式检查，本次独立复核没有改变正式项目状态或规则，无需修改。

成稿已通过 `report-humanizer` 机器扫描；随后按 `shuorenhua` 逐项回读对象 ID、关系方向、数量、来源 ID、状态和责任边界，修正了 v5p 96 GiB 来源归属，未改动其余事实口径。
