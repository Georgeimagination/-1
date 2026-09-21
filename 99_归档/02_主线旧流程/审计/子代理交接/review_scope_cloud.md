# M2 AWS 与 Google 对象身份独立复核

> 状态：`completed`
> 复核日期：2026-08-12
> 复核性质：只读复核；不联网，不改正式 CSV。

## 复核结论

| 裁决项 | 结论 | 是否阻断导入 | 复核意见 |
|---|---|---|---|
| AWS EC2 的 Inf1、Trn1、Trn1n、Inf2、Trn2、Trn2u 候选统一使用 `cloud_instance` | `accept_with_caveat` | 否 | 具体 instance type 明确属于云实例；Inf1 与现有 Trn2 family 则是家族容器。当前枚举没有 `cloud_instance_family`，可暂用 `cloud_instance`，但 notes 必须标明 `family_container`，家族级事实不得冒充某个尺寸的实例事实。三条 Trn2 复用既有对象，不能重复建 ID。 |
| `CAND-GOOGLE-CT6E-STANDARD-FAMILY` 改为 `cloud_instance` | `accept_with_caveat` | 否 | `ct6e-standard-*` 是 TPU VM machine type，不是独立加速器资源。族对象可承接共有事实，`1t/4t/8t` 先作为配置行；任何只属于单一 machine type 的资源、拓扑或供货事实都要另行定域，不能写到族对象上。 |
| TPU v3 建 `Google Cloud TPU v3 Pod` 历史系统卡 | `accept` | 否 | 架构对象与 Pod 系统对象分开符合现有对象模型。系统卡只接 Pod 级规模、拓扑和状态，芯片或架构事实仍归 TPU v3 架构对象。 |
| TPU 8t Superpod、TPU 8i Pod 建观察卡 | `accept_with_caveat` | 否 | 一手材料已给出可辨认的系统称谓，足以建立 `pod` 观察对象；但两者必须保持 `announced` 与 `needs_resolution`。没有 accelerator type、machine type 或稳定配置前，不得建立云配置对象，也不得从架构对象继承规模、拓扑和供货状态。canonical label 应视为暂定描述名，后续正式命名出现时保留版本记录。 |
| `CAND-AWS-TRAINIUM4-NVLINK-FUSION-SYSTEM` 留在候选层 | `accept` | 是，仅阻断该候选导入 | NVLink Fusion 支持和 MGX 机架兼容只能证明技术或部署方向，不能证明已有独立系统产品。正式系统名、EC2 instance type、UltraServer 名称或固定组成出现前，不得导入 `objects.csv`，也不建空卡。 |

## 导入边界

本包可以按“15 条导入或复用、Trainium4 系统候选不导入”推进。导入前应逐条保留对象层级说明；身份页只能证明对象存在，不能自动承担规格和供货状态。TPU 8t/8i、`trn2u.48xlarge` 的状态缺口不阻止建对象，但会阻止把卡片标为完成。

本次已只读检查 `README.md` 与 `AGENTS.md`；两者仍准确说明 M2 处于身份核对阶段，无需修改。