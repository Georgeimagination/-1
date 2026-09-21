# M2 第二波 Google 云端器件范围补充验收

验收日期：2026 年 8 月 13 日  
状态：对象与架构关系预留通过；来源与事实门继续待核  
范围：Google Cloud TPU v5e、v5p、v6e 三个云端单器件对象及其架构关系

## 验收依据

本次补裁决以 `审计/子代理交接/m2_google_config_model_independent_review.md` 的三层模型复核为前置，以准备包 `审计/子代理交接/m2_staging/M2-W2-GOOGLE-CLOUD-DEVICE/` 和独立报告 `审计/子代理交接/m2_review_google_cloud_device_gate.md` 为直接依据。

独立复核确认，三个厂商页面都把单芯片规格与 VM（Virtual Machine，虚拟机）、machine type（机器类型）、slice 或 Pod 配置分开陈述。`cloud_accelerator` 和 `implements_architecture` 均为正式枚举，三个拟用对象 ID、slug、关系 ID 和关系指纹在正式库中没有碰撞，三个架构端点都已存在且为 `reviewed`。

## 正式预留

`审计/M2_对象范围映射.csv` 新增三行，范围映射由 60 行增至 63 行。正式对象表新增：

| 对象 | 类型 | 边界 |
|---|---|---|
| `OBJ-GOOGLE-TPU-V5E-CLOUD-DEVICE` | `cloud_accelerator` | 只承接 v5e 单器件事实；VM、机器类型、slice 与 Pod 另层。 |
| `OBJ-GOOGLE-TPU-V5P-CLOUD-DEVICE` | `cloud_accelerator` | 只承接 v5p 云端单器件事实；95 GiB 云端值与 96 GiB 物理候选分开，不推导 1 GiB 预留。 |
| `OBJ-GOOGLE-TPU-V6E-CLOUD-DEVICE` | `cloud_accelerator` | 只承接 v6e 单器件事实；ct6e 机器类型、slice 与 Pod 另层。 |

三条 `implements_architecture` 关系分别把上述器件连到 `OBJ-GOOGLE-TPU-V5E-ARCH`、`OBJ-GOOGLE-TPU-V5P-ARCH` 和 `OBJ-GOOGLE-TPU-V6E-ARCH`。关系只表达器件实现哪一代架构，不携带容量、带宽、算力、每实例芯片数或系统拓扑，也不建立尚未证明的物理 package 到云端器件关系。

六行新增记录均保持 `needs_resolution`。正式计数从 75 个对象、24 条关系变为 78 个对象、27 条关系；本次没有新增事实、断言、字段要求、来源或资料卡。

## 暂不接收的来源记录

准备包的来源部分没有随对象预留进入正式库。独立复核发现两处会改变来源筛选结论的问题：

1. `openxla-sparsecore-2026-08-13.html` 从页面行 `L148` 开始，缺少正式 G15 断言所需的 `L69-L87`。现有文件只能作为 partial extract（部分提取）审计件，不能证明 G15 已固定，也不能作为可访问证据入口。
2. `tpu-machines` 提取在 `L624-L639` 直接列出 v5p、v6e 的单芯片规格和 SparseCore 数量，不能标为器件事实范围之外。G05、G08、G09、G10、G15 与 `tpu-machines` 必须放入同一候选池重跑覆盖和反向移除。

因此，本次不接收 G15 endpoint、来源筛选、覆盖、selection run、selection members、七组配置事实或 15 条 deferred 向正式 facts 的转换。六个渲染文本包装文件也不能标为 `web_snapshot` 或上游原始响应体。原始页面抓取曾出现 `ERR_CONNECTION_CLOSED`、EOF 和 Schannel TLS 错误；这是远端或本机网络链路错误，不是用户拒绝、沙箱拒绝或审批失败。

## 备份与验证

写入前将 `objects.csv`、`object-relations.csv` 和 `M2_对象范围映射.csv` 备份到 `审计/合并备份/M2-W2-GOOGLE-CLOUD-DEVICE-RESERVATION-20260813/`。三行备份 manifest 的 SHA-256 为 `ef5c77e677a38f31f6bc3d6dfa61bb7c3a3b54924cf567f3df6ab50b65588105`。

写入后逐表与备份比较：三个文件各追加三行，原有主键和单元格变化为 0。正式校验通过：

```text
PASS: 32-table research data model; 93251 checks executed.
Registry: 323 columns, 488 enum values.
```

## 后续工作

下一包只修来源门：取得可覆盖 G15 定位的完整官方内容，或把 G15 保持为不可用的部分提取；修正 `tpu-machines` 的器件事实作用域和 v5e 配置来源映射；再按真实候选池重跑逐事实覆盖与反向移除。新的准备包仍须由未参与修复的代理复核。来源门通过后，才能开始三张器件卡和单器件事实抽取。
