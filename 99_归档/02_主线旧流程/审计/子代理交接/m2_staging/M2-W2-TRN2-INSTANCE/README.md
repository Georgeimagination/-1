# M2-W2-TRN2-INSTANCE 暂存包

- 状态：`ready_for_independent_review`
- 工作包：`M2-W2-TRN2-INSTANCE`
- 资料截止日：2026-08-13
- 写入边界：只写本目录；不修改正式表、正式资料卡、进度、README 或 AGENTS
- 主对象：`OBJ-AWS-TRN2-3XLARGE`、`OBJ-AWS-TRN2-48XLARGE`、`OBJ-AWS-TRN2U-48XLARGE`

## 当前边界

按三个实例对象及其拥有的组件、链路、精度路径、拓扑和“以实例为主语”的关系复算，正式库命中 49 条事实。第 49 条是 `FACT-AWS-TRN2-ULTRA64-INSTANCE-QTY`，目标为 `OREL-AWS-TRN2U-48XLARGE-DEPLOYED-IN-ULTRASERVER`，表示一个 UltraServer 包含 4 个 `trn2u.48xlarge`。它属于系统组成，连同 `REQ-AWS-TRN2-0092` 排除后，本包实例事实为 48 条，分布为 4、23、21；字段要求为 51 条，分布为 5、24、22。

`OBJ-AWS-TRN2-INSTANCE-FAMILY` 只作 `sku_variant_of` 端点；`OBJ-AWS-TRAINIUM2-CHIP` 和 `OBJ-AWS-TRAINIUM2-ARCH` 只作关系与正式事实引用；`OBJ-AWS-TRN2-ULTRASERVER-64` 保持包外。架构和芯片事实不复制到实例事实表。

## S07 固定结果

2026-08-13 已重新取得 AWS 官方 EC2 Trn2 产品页，HTTP 状态为 200。快照为 487,377 bytes，SHA-256 为 `94ceea74234b30d6568127badd6a4df68a46b861d1d989c21463fea3b0690edb`。它与 2026-08-12 快照的原始哈希不同，但行数、字节数一致，只改了两行服务器 nonce；归一化 nonce 后全文逐字相同，归一化 SHA-256 均为 `3070baef5d94db45396bd210d4f16f1bf8f8aa1b2586d1215530f82e2acf473e`。

因此本包保留 `SRC-AWS-TRN2-S07` 的正式 source 行、`observed-2026-08-12` 版本标签与旧 `content_fingerprint`，不覆盖既有内容版本。合并候选只新增访问日正确的 snapshot endpoint，并把旧快照 endpoint 改为非首选。四条 S07 实例事实的语义、原值和定位没有变化，不新增平行 source、fact 或 assertion。

## 预计交付

| 产物 | 预计数量 | 当前状态 |
|---|---:|---|
| 实例卡 | 3 张 | 已完成初稿 |
| 卡片到正式事实映射 | 48 行 | 已生成 |
| 明确排除的系统事实 | 1 行 | 已生成 |
| 九域完整度 | 27 行 | 已写入 |
| 正式同表头 structured CSV | 32 份 | 已建表头；非空片段待写入 |
| S07 固定快照 | 1 份 | 已固定并复算哈希 |
| source 行变更 | 0 行 | 保留正式内容版本；另有 1 行 `no_source_row_change` 合并判定 |
| endpoint 合并候选 | 2 行 | 旧 PK 更新 1 行、新 PK 追加 1 行 |
| 包级来源筛选 | 5 行 | 已写入 |
| 反向移除运行与成员 | 1 个运行、4 个成员 | 已写入，均为 `draft` |
| 包内自检与临时正式合并 | 各 1 次 | 109 项 0 错误；官方校验 92,374 项通过 |

## 已持久化文件

- `object-scope.csv`：七个相关对象在本包中的角色、正式状态和边界
- `source-freeze-register.csv`：S07 新旧快照、HTTP、字节数、原始哈希和 nonce 归一化比较
- `sources/card-fact-map.csv`：48 条实例事实到三张卡的唯一映射，不复制正式事实
- `sources/scope-exclusions.csv`：系统关系事实与字段要求的排除依据
- `fixed-candidates/S07_ec2_trn2_product_2026-08-13.html`：AWS 官方同日快照
- `structured/`：32 张正式表的同表头暂存片段

三张卡、九域完整度、来源筛选与反向移除、自检和临时正式合并验证已经完成。当前 staging 已冻结为独立复核输入；独立复核由未参与本包初稿的代理承担。
