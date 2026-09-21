# M2 第二波 AWS 物理对象范围补充验收

验收日期：2026 年 8 月 13 日  
状态：对象预留已通过，事实抽取仍有来源登记门  
范围：Inferentia1、Trainium1、Inferentia2、Trainium3 四个单器件对象及其架构关系

## 验收依据

本次补裁决以 `审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE/` 的来源冻结与身份预审为初稿，以 `审计/子代理交接/m2_w2_aws_package_gate_review.md` 为独立复核。复核重新检查了 11 份 AWS 官方 HTML 的字节数和 SHA-256，并核对 23 条实现对象待办。四个候选都取得了以 `chip` 或 `device` 为主语的单器件正文，实例和 UltraServer 的聚合数量没有下放。

AWS 没有公开这四代器件的裸片、芯粒、基板或订货形态。项目沿用 Trainium2 的既有对象模型，把单器件保守放在 `package` 层；这只是事实归属容器，不表示封装构造已知。四个对象与关系均保持 `needs_resolution`。

## 正式预留

`审计/M2_对象范围映射.csv` 新增四行补裁决，行数由 56 增至 60。正式对象表新增：

| 对象 | 类型 | 边界 |
|---|---|---|
| `OBJ-AWS-INFERENTIA1-CHIP` | `package` | 历史单器件对象；Inf1 实例内 16 颗不属于单器件属性。 |
| `OBJ-AWS-TRAINIUM1-CHIP` | `package` | 与 Trn1 实例分开；不从云可用状态推导芯片供货。 |
| `OBJ-AWS-INFERENTIA2-CHIP` | `package` | 与 Inf2 实例分开；实例最多 12 颗只留在配置层。 |
| `OBJ-AWS-TRAINIUM3-CHIP` | `package` | 与 Trn3 UltraServer 分开；系统内最多 144 颗及聚合规格不下放。 |

四条 `implements_architecture` 关系分别把上述对象连到 `OBJ-AWS-INFERENTIA1-ARCH`、`OBJ-AWS-TRAINIUM1-ARCH`、`OBJ-AWS-INFERENTIA2-ARCH` 和 `OBJ-AWS-TRAINIUM3-ARCH`。关系不携带器件数量、算力、存储、互联、工艺或供货状态。

正式计数由 71 个对象、20 条关系变为 75 个对象、24 条关系。新增 object ID、slug、关系 ID 和关系指纹均无碰撞，四个架构端点都已存在且为 `reviewed`，关系外键没有断链。

## 事实抽取前仍要关闭的门

对象预留不等于来源冻结已经可以正式入库。11 份 HTML 实际获取于 2026-08-13，不能挂到 `access_date=2026-08-12` 的旧 endpoint。后续应保留原入口，并为这些文件另建访问日与快照日均为 2026-08-13 的 `web_snapshot` endpoint；A01 和 A07 的 v2.31.0 版本化文件作为稳定定位首选，`latest` 抓取件只用于同日入口审计。两组正文与版本化副本逐字符相同，不能按两个独立来源计数。

Trainium3 还有一项新增口径差异：A08 写 144 GB，A06/A07 写 144 GiB。它与已有的 4.9/4.7 TB/s、16/20 个 CC-Core 分歧一样，必须保留原标签并进入断言或冲突处理；不能先换算再静默选值。上述两项完成前，不开始 23 条实现事实的正式合并。

## 备份与验证

写入前备份位于 `审计/合并备份/M2-W2-AWS-RESERVATION-20260813/`，包含原 `objects.csv`、`object-relations.csv`、范围映射和 SHA-256 清单。写入后正式校验通过：

```text
PASS: 32-table research data model; 91286 checks executed.
Registry: 323 columns, 488 enum values.
```

本次只改变对象范围、对象表和关系表，没有创建 AWS 实现事实、断言、字段要求、来源筛选或资料卡。下一步先修正快照 endpoint 与 Trainium3 单位分歧登记，再按四个对象拆分 23 条待办，并由独立复核者验收后顺序合并。