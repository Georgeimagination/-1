# M2 华为昇腾与寒武纪范围裁决独立复核

> 复核日期：2026-08-12  
> 状态：`review_complete`  
> 方法：离线复核候选表、正式对象与关系、受控枚举、批次计划和 MLU590 验收记录；未重新访问网页。

## 复核结论

| 范围组 | 裁决 | 是否阻断导入 |
|---|---|---|
| `MLUarch05` / BANG v5.0 / `__BANG_ARCH__=592` | `accept_with_caveat` | 只阻断 BANG v5.0 作为正式物理架构对象导入 |
| MLU570、MLU590 芯片与板卡 | `accept_with_caveat` | 阻断依赖不可访问 CNToolkit 正文的新对象导入；不影响 M1 已有 MLU590 对象 |
| CloudMatrix384 | `accept` | 不阻断硬件 `pod` 对象；阻断未定名云服务对象和服务状态迁移 |
| Atlas 800 A3 | `accept_with_caveat` | 不阻断独立 `pod` 身份导入；阻断物理组成和与 800T/800I 的关系 |
| Atlas 850、850E、860 | `accept_with_caveat` | 不阻断三个独立身份导入；阻断供货状态和改名、继承关系 |
| Atlas 950 SuperPoD | `accept_with_caveat` | 不阻断合并为一个 `pod`；阻断把三种配置写成同一状态事实 |
| Ascend 950PR、950DT 与共享 Die | `accept_with_caveat` | 不阻断两个 `package`、一个 `die` 及两条 `package_contains_die`；阻断无条件的 950PR `available` 事实 |

## 裁决说明

寒武纪三种标识的分层正确。`MLUarch05` 是已有一手材料支撑的架构名，BANG v5.0 目前只是待核的软件架构代际候选，`__BANG_ARCH__=592` 是固定源码中的编译标识。继续保留正式 `MLUarch05` 及其与思元590的关系；BANG v5.0 留在候选层，不能写等价关系或承接物理规格。

MLU570 芯片与同名板卡、MLU590 芯片与 H8/M9 板卡、MLU370-M8 分层方向成立，但正式身份仍依赖不可访问的 CNToolkit 正文。MLU570 两个候选和 MLU370-M8 暂不导入；H8/M9 保留现有 `needs_resolution` 占位。尤其不能在“思元590 = MLU590”尚未取证时，把 `CAND-CAMBRICON-MLU590-PACKAGE` 直接合并为既有芯片对象。

CloudMatrix384 的官方“超节点”称谓支持把硬件建为 `pod`，云服务应另建对象。原候选的 `cloud_available` 属于服务层，不能带到硬件对象。Atlas 800 A3 的独立导航入口足以支持独立产品身份，但还不足以证明它与 800T A3、800I A3 的物理边界；因此可按 `pod`、`needs_resolution` 导入，不建立改名、变体或包含关系。

Atlas 850、850E、860 应分别建对象。现有证据只支持独立名称及带日期的发布或展示状态，不能写 `renamed_from`、`supersedes_product`，也不能把当前页面展示等同于供货。850/850E 后续若出现“标准服务器”和“超节点”不同订货边界，再拆配置或对象。

Atlas 950 的 64、1024、8192 NPU 是同一 SuperPoD 的条件化规模，合并为一个 `pod` 合理。三种规模仍须分别保存来源日期、配置条件和状态；1024 真机展示不等于正式可用，8192 的路线图状态不能覆盖 64/1024。

950PR 与 950DT 分为两个 `package`、共享一个 Ascend 950 `die`，与现有枚举和关系类型一致，可以导入。Atlas 350 上市能证明 950PR 被用于已上市产品，但未必证明它作为独立处理器可订购；`available` 必须注明“随 Atlas 350 部署”或继续待核。950DT 保持 `announced`。

这份复核没有发现需要整体退回的范围组。可执行部分导入；所有基于动态页面的身份先保留访问日期和 `needs_resolution`，状态与物理关系等到固定文档或对象匹配的一手证据后再升级。