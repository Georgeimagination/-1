# M2 西侧范围独立复核

> 状态：`ready_for_root_review`  
> 对象：`m2_scope_nvidia_amd_groq.md`  
> 方法：只读比对对象候选、正式对象和枚举；未联网，未改正式 CSV、README 或 AGENTS。

## 结论

主线判断可采用，但不能整包导入。只有身份确定且现有枚举能准确表达的对象可以先合并；产品族、多物理 SKU 集合、类型未定项和架构冲突项继续留在候选层。

| 复核组 | 裁决 | 是否阻断导入 |
|---|---|---|
| Groq 3 厂商 | `accept` | 不阻断。NVIDIA Groq 3 LPU 与 LPX 系统归 `VEN-NVIDIA`；第一代 Groq 产品仍归 `VEN-GROQ`。 |
| LP30 层级 | `accept_with_caveat` | 阻断 LP30。`package` 只是暂定值，现有证据未排除裸片名或更高层加速器名；必填 `object_type` 不能靠 `needs_resolution` 修饰错误类型。compute tray 可按 `server`、LPX rack 可按 `rack` 导入。 |
| A800 拆分 | `accept_with_caveat` | 阻断数据中心父项。PCIe 80 GB、液冷 PCIe 80 GB 与 A800-SXM4-80GB 应按固定名称拆开；HGX 是系统语境，不能和 SXM4 模组混为一个对象。40GB Active 仍作范围外线索。 |
| H800、H20 | `accept_with_caveat` | 阻断两个父项。Hopper 归类可接受，但候选覆盖多个物理 SKU；先按厂商固定名称拆分，再给具体对象建立架构关系。 |
| L20、L2 | `accept` | 不阻断。两者可按 `card` 导入，并建立 Ada Lovelace 架构关系。 |
| H20 BFX | `accept_with_caveat` | 阻断。官方驱动资料分别归入 Hopper 与 Blackwell，`card` 形态也未确认；只保留候选和冲突记录。 |
| MI308X、MI308X-HF | `accept_with_caveat` | MI308X 可按 `module`、`available` 导入，但先不连 CDNA 3。MI308X-HF 只作软件线索，不建对象或 `sku_variant_of`。 |
| MI350P | `accept` | 不阻断。可按 `card`、`available` 导入，并连接 CDNA 4。 |
| CDNA 5、MI455X | `accept` | 不阻断。CDNA 5 按架构代际导入；MI455X 按 EAM 对应的 `module` 导入并连接 CDNA 5。截止日状态用 `announced`，不能把计划发货写成已经交付。 |
| MI440X、MI430X | `accept_with_caveat` | 阻断。物理形态缺少直接定义，不能暂填 `module` 后导入；对象边界确定前也不建架构关系。 |
| Helios | `accept` | 不阻断。可按 `rack` 参考设计导入，并注明不是 AMD 可订购成品；用 `physically_contains` 连接 MI455X，数量另作事实。 |
| CDNA 6、MI500 Series | `accept_with_caveat` | CDNA 6 不阻断。MI500 Series 是产品系列，现有 `object_type` 无法无损表达，不能沿用 `module`；等待具体 SKU 或另行调整模型。 |

## 合并边界

可先导入 Groq 3 架构与两个 LPX 系统、L20、L2、MI308X、MI350P、CDNA 5、MI455X、Helios 和 CDNA 6。`product_status` 应写成事实；`main_sample`、`observation`、`excluded_lead` 是范围标签，不能混入产品状态。

LP30、A800/H800/H20 父项、H20 BFX、MI440X、MI430X 和 MI500 Series 继续留在候选层，但不阻断其他对象顺序合并。