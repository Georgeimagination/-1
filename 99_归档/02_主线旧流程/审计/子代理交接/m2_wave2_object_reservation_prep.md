# M2 第二波 T0 对象预留只读预审

状态：预审完成，等待独立复核与总控裁决。本文只给出可复制的候选行，不代表已经预留；正式 `数据/objects.csv` 和 `数据/object-relations.csv` 未修改。

## 预审结论

当前正式表有 71 个对象、20 条关系。下列 9 个建议对象在正式 `object_id` 和 `curator_slug` 中均无碰撞，批内也无重复；4 个 AWS 关系候选的关系 ID 和指纹同样无碰撞。若以后获准按本稿合并，计数应变为 80 个对象、24 条关系。

这 9 个对象在 `审计/M2_对象范围映射.csv` 中都没有裁决行，因此候选表不能直接当作范围批准。AWS 4 个物理对象有逐对象候选行，但候选状态仍是 `draft`；Google 5 个配置族候选为 `needs_resolution`。独立复核尚未完成，所以拟写入状态统一保守取 `needs_resolution`，不得提前写成 `reviewed`。

正式枚举与外键已具备：`VEN-AWS`、`VEN-GOOGLE` 均为已批准厂商；`package`、`cloud_accelerator`、`needs_resolution` 和 `implements_architecture` 均为已批准枚举。它们只证明字段值合法，不替代对象范围和身份裁决。

## 候选来源核对

| 候选表行 | 建议 object_id | vendor / layer / type | 候选状态 | 预留判断 |
|---|---|---|---|---|
| 68，`CAND-AWS-INFERENTIA1-CHIP` | `OBJ-AWS-INFERENTIA1-CHIP` | AWS / `silicon_package` / `package` | `historical_anchor` / `historical_anchor` / `draft` | 类型匹配；仍需独立复核历史锚点是否保留 |
| 71，`CAND-AWS-TRAINIUM1-CHIP` | `OBJ-AWS-TRAINIUM1-CHIP` | AWS / `silicon_package` / `package` | `main_sample` / `cloud_available` / `draft` | 类型匹配；不能把云可用状态当作单芯片规格证据 |
| 76，`CAND-AWS-INFERENTIA2-CHIP` | `OBJ-AWS-INFERENTIA2-CHIP` | AWS / `silicon_package` / `package` | `main_sample` / `cloud_available` / `draft` | 类型匹配；芯片级与实例级边界仍待复核 |
| 88，`CAND-AWS-TRAINIUM3-CHIP` | `OBJ-AWS-TRAINIUM3-CHIP` | AWS / `silicon_package` / `package` | `main_sample` / `cloud_available` / `draft` | 类型匹配；候选日期 `2025-12-02` 不能代替动态状态快照 |
| 49，`CAND-GOOGLE-TPU-V4-SLICE-FAMILY` | `OBJ-GOOGLE-TPU-V4-SLICE-FAMILY` | Google / `product_sku` / `cloud_accelerator` | `main_sample` / `cloud_available` / `needs_resolution` | 配置族边界仍待同日官方快照固定 |
| 52，`CAND-GOOGLE-TPU-V5LITEPOD-CONFIG-FAMILY` | `OBJ-GOOGLE-TPU-V5LITEPOD-CONFIG-FAMILY` | Google / `product_sku` / `cloud_accelerator` | `main_sample` / `cloud_available` / `needs_resolution` | 旧名与现行 API 名仍待映射 |
| 54，`CAND-GOOGLE-TPU-V5P-SLICE-FAMILY` | `OBJ-GOOGLE-TPU-V5P-SLICE-FAMILY` | Google / `product_sku` / `cloud_accelerator` | `main_sample` / `cloud_available` / `needs_resolution` | 配置成员和主机映射仍待固定 |
| 57，`CAND-GOOGLE-TPU-V6E-CONFIG-FAMILY` | `OBJ-GOOGLE-TPU-V6E-CONFIG-FAMILY` | Google / `product_sku` / `cloud_accelerator` | `main_sample` / `cloud_available` / `needs_resolution` | 候选日期 `2024-12-11` 不能代替当前配置快照 |
| 60，`CAND-GOOGLE-TPU7X-SLICE-FAMILY` | `OBJ-GOOGLE-TPU7X-SLICE-FAMILY` | Google / `product_sku` / `cloud_accelerator` | `main_sample` / `cloud_available` / `needs_resolution` | 地区、最小配置和稳定 API 名仍待固定 |

表中“候选状态”依次是 `scope_status / availability_status / review_status`。9 行在范围映射中匹配数为 0。这个结果只说明裁决缺失，既不能据此排除，也不能据此导入；独立复核和总控必须补裁决。

## `objects.csv` 精确候选行

以下文本含正式表头，可由总控在通过全部阻断门后导入；当前不得执行。

```csv
object_id,vendor_id,canonical_label,object_type,curator_slug,review_status,notes
OBJ-AWS-INFERENTIA1-CHIP,VEN-AWS,AWS Inferentia chip,package,aws-inferentia1-chip,needs_resolution,T0 预留候选；对应 CAND-AWS-INFERENTIA1-CHIP（historical_anchor/historical_anchor）；独立复核通过前不承载事实。
OBJ-AWS-TRAINIUM1-CHIP,VEN-AWS,AWS Trainium chip,package,aws-trainium1-chip,needs_resolution,T0 预留候选；对应 CAND-AWS-TRAINIUM1-CHIP（main_sample/cloud_available）；独立复核通过前不承载事实。
OBJ-AWS-INFERENTIA2-CHIP,VEN-AWS,AWS Inferentia2 chip,package,aws-inferentia2-chip,needs_resolution,T0 预留候选；对应 CAND-AWS-INFERENTIA2-CHIP（main_sample/cloud_available）；独立复核通过前不承载事实。
OBJ-AWS-TRAINIUM3-CHIP,VEN-AWS,AWS Trainium3 chip,package,aws-trainium3-chip,needs_resolution,T0 预留候选；对应 CAND-AWS-TRAINIUM3-CHIP（main_sample/cloud_available）；独立复核通过前不承载事实。
OBJ-GOOGLE-TPU-V4-SLICE-FAMILY,VEN-GOOGLE,Google TPU v4 Slice configuration family,cloud_accelerator,google-tpu-v4-slice-configuration-family,needs_resolution,T0 预留候选；对应 CAND-GOOGLE-TPU-V4-SLICE-FAMILY；配置成员与截止日状态待同日官方快照和独立复核，不承载架构事实。
OBJ-GOOGLE-TPU-V5LITEPOD-CONFIG-FAMILY,VEN-GOOGLE,Google TPU v5e v5litepod configuration family,cloud_accelerator,google-tpu-v5e-v5litepod-configuration-family,needs_resolution,T0 预留候选；对应 CAND-GOOGLE-TPU-V5LITEPOD-CONFIG-FAMILY；旧名、现行 API 名和配置成员待同日官方快照及独立复核，不承载架构事实。
OBJ-GOOGLE-TPU-V5P-SLICE-FAMILY,VEN-GOOGLE,Google TPU v5p Slice configuration family,cloud_accelerator,google-tpu-v5p-slice-configuration-family,needs_resolution,T0 预留候选；对应 CAND-GOOGLE-TPU-V5P-SLICE-FAMILY；配置成员与截止日状态待同日官方快照和独立复核，不承载架构事实。
OBJ-GOOGLE-TPU-V6E-CONFIG-FAMILY,VEN-GOOGLE,Google TPU v6e configuration family,cloud_accelerator,google-tpu-v6e-configuration-family,needs_resolution,T0 预留候选；对应 CAND-GOOGLE-TPU-V6E-CONFIG-FAMILY；配置成员与截止日状态待同日官方快照和独立复核，不承载架构事实。
OBJ-GOOGLE-TPU7X-SLICE-FAMILY,VEN-GOOGLE,Google TPU7x Slice configuration family,cloud_accelerator,google-tpu7x-slice-configuration-family,needs_resolution,T0 预留候选；对应 CAND-GOOGLE-TPU7X-SLICE-FAMILY；地区、最小配置和稳定 API 名待同日官方快照及独立复核，不承载架构事实。
```

## `object-relations.csv` 精确候选行

AWS 的物理对象各有一个已复核架构端点，可以沿用 Trainium2 的既有关系模式。候选行如下；关系本身仍随新对象一起受独立复核阻断。

```csv
object_relation_id,subject_object_id,relation_type,object_object_id,relation_fingerprint,review_status,notes
OREL-AWS-INFERENTIA1-IMPLEMENTS-ARCH,OBJ-AWS-INFERENTIA1-CHIP,implements_architecture,OBJ-AWS-INFERENTIA1-ARCH,OBJ-AWS-INFERENTIA1-CHIP|implements_architecture|OBJ-AWS-INFERENTIA1-ARCH,needs_resolution,T0 预留候选；物理端点身份与关系待独立复核，正式写入前不得被下游当作正式关系。
OREL-AWS-TRAINIUM1-IMPLEMENTS-ARCH,OBJ-AWS-TRAINIUM1-CHIP,implements_architecture,OBJ-AWS-TRAINIUM1-ARCH,OBJ-AWS-TRAINIUM1-CHIP|implements_architecture|OBJ-AWS-TRAINIUM1-ARCH,needs_resolution,T0 预留候选；物理端点身份与关系待独立复核，正式写入前不得被下游当作正式关系。
OREL-AWS-INFERENTIA2-IMPLEMENTS-ARCH,OBJ-AWS-INFERENTIA2-CHIP,implements_architecture,OBJ-AWS-INFERENTIA2-ARCH,OBJ-AWS-INFERENTIA2-CHIP|implements_architecture|OBJ-AWS-INFERENTIA2-ARCH,needs_resolution,T0 预留候选；物理端点身份与关系待独立复核，正式写入前不得被下游当作正式关系。
OREL-AWS-TRAINIUM3-IMPLEMENTS-ARCH,OBJ-AWS-TRAINIUM3-CHIP,implements_architecture,OBJ-AWS-TRAINIUM3-ARCH,OBJ-AWS-TRAINIUM3-CHIP|implements_architecture|OBJ-AWS-TRAINIUM3-ARCH,needs_resolution,T0 预留候选；物理端点身份与关系待独立复核，正式写入前不得被下游当作正式关系。
```

Google 本批关系候选为 0 条。五个对象是云配置族，当前正式库没有相应物理实现对象作为 `exposed_as_cloud_accelerator` 的 subject；直接把配置族连到架构并写成 `implements_architecture` 会混淆实现层与云配置层。因此先保留 0 条关系，不能为追求图连通而造关系。

## 碰撞复算

复算口径为当前正式 `objects.csv` 的 71 行、`object-relations.csv` 的 20 行，并同时检查本批内部重复。结果如下：9 个 `object_id` 碰撞 0 个，9 个 `curator_slug` 碰撞 0 个，9 个 `canonical_label` 完全匹配碰撞 0 个；4 个 `object_relation_id` 碰撞 0 个，4 个 `relation_fingerprint` 碰撞 0 个。4 个架构 object 端点均已存在且为 `reviewed`，4 个新 subject 当前均不存在，符合先对象后关系的合并顺序。

碰撞结论只对本次读取快照有效。总控合并前必须重新导入正式表，并按大小写不敏感口径复算 ID、slug、label、关系 ID 和指纹；只要任一结果不再为 0，就停止合并。

## 以后获准时的备份、合并与验证

总控应先为 `数据/objects.csv` 和 `数据/object-relations.csv` 建立不覆盖旧目录的时间戳备份，并记录两个原文件的 SHA-256。随后重新做碰撞与外键预检；确认独立复核已给出明确通过意见后，先追加 9 个对象，再追加 4 个 AWS 关系，Google 不追加关系。写入须保持原表头、UTF-8 编码和现有换行风格。

合并后先核对对象数为 80、关系数为 24，再核对 9 个 ID、9 个 slug、4 个关系 ID 和4 个指纹各自唯一，且所有关系端点和枚举外键都存在。最后运行：

```powershell
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '.\scripts\validation\Validate-ResearchData.ps1' -RootPath '.'
```

校验器退出码不为 0、计数不符或任一唯一性/外键检查失败时，应立刻停止后续事实与卡片写入，并用备份恢复本次两张表。此次不改来源池，所以无需运行来源池基线检查。

## 阻断条件

当前已经命中一项绝对阻断：独立复核尚未完成。以下任一情况也会阻断正式预留：范围映射仍无这 9 个对象的明确补裁决；复核要求更改 object ID、canonical label、type 或 slug；厂商/枚举值不再有效；Google 配置族无法由同日官方快照固定；AWS 物理对象不能与实例总值或架构事实分开；任何碰撞、外键、计数或 validator 检查失败。在这些条件消除前，本稿只能作为总控的导入候选，不能提前写入正式表，也不能被下游事实或卡片当作已存在外键。

## 文档检查

本次正式项目状态、目录、规则和进度均未改变。根 `README.md` 与 `AGENTS.md` 已按只读方式检查，无需修改；正式合并若以后发生，再由总控同步项目状态。交付前已按 `report-humanizer` 处理机器扫描命中的两处表达，再按 `shuorenhua` 的文档场景回读标题、首段、表格引导、转场和结尾；9 个对象行、4 个关系行、枚举、状态、数量、路径及阻断责任均逐字保留。