# Google 云端器件修复包合并说明

本说明只供独立复核和总控验收。当前包不含与正式 facts 表逐列对齐的片段，也不含资料卡草稿。

## 已由总控完成的范围预留

三枚 `cloud_accelerator` 对象和三条 `implements_architecture` 关系已经以 `needs_resolution` 写入正式库。`object-scope-candidates.csv` 与 `relationship-candidates.csv` 现在只用于核对正式主键、对象类型、架构端点和关系方向。不得再次追加这些行，也不得由本包把状态改成 `reviewed`。

正式对象为：

- `OBJ-GOOGLE-TPU-V5E-CLOUD-DEVICE`
- `OBJ-GOOGLE-TPU-V5P-CLOUD-DEVICE`
- `OBJ-GOOGLE-TPU-V6E-CLOUD-DEVICE`

它们只能承接单器件事实。VM（Virtual Machine，虚拟机）、机器类型、slice 与 Pod 的数量和聚合值继续留在配置或系统层。

## 独立复核后可考虑的来源记录

`source-candidates.csv` 中 `tpu-machines` 的 family、source、远端 `html_page` 和本地 `other` endpoint 可以进入临时正式副本验证：

- `SFAM-M2-W2-G-TPU-MACHINES`
- `SRC-M2-W2-G-TPU-MACHINES-20260813`
- `END-M2-W2-G-TPU-MACHINES-PRIMARY`
- `END-M2-W2-G-TPU-MACHINES-EXTRACT-20260813`

G05、G08、G09、G10 复用已有 source，只新增 2026-08-13 的 `other` endpoint 候选。五个可用本地提取都必须保持 `is_preferred_endpoint=false`，notes 逐字为 `renderer-extracted text wrapped as HTML / not upstream response body`。复制到拟落路径后，要重算字节数和 SHA-256（安全哈希算法），再与候选表逐行比较。

G15 不在这组可接收记录中。`END-M2-GA-G15-EXTRACT-20260813` 的文件从 `L148` 开始，状态为 `pending_verification`，正式拟落路径为空。不得把它加入正式 endpoint 表，不得改成 `accessible`，也不得用远端页面可读这一事实替代本地文件完整性检查。

## 不直接合并的审计记录

`deferred-dispositions.csv` 仍是 14 个父待办到 15 个持久处置项的审计表，不转成 facts。`DEF-M2GA-GV5P-03` 的 95 GiB 与 96 GiB 分支保持分离；物理 package 身份未关闭前，不生成 1 GiB 预留或跨对象冲突结论。

`configuration-row-dispositions.csv` 也不直接转成 facts。v5e 机器类型行只保留实际包含 v5e 的来源。CT6E 家族到 v6e 器件的关系候选、命名机器类型、slice 与 Pod 都留给后续配置范围门。

`source-selection-candidates.csv` 是重新筛选的候选结果，不是可直接追加的正式行。本轮入选 G08、G09、G10 与 `tpu-machines`，G05 和 G15 为 `redundant_covered`。四条 `coverage_candidate` 每行只有一个覆盖来源。事实集合冻结后，仍要由未参与修复者复核选择成员，再由总控决定是否转换成正式 screening、coverage、selection run 与 selection member。

## 验证顺序

先运行包内校验器：

```powershell
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File '.\审计\子代理交接\m2_staging\M2-W2-GOOGLE-CLOUD-DEVICE-REMEDIATED\Validate-Package.ps1'
```

校验器会检查固定文件的字节数和哈希，也会实际读取定位。G15 必须从 `L148` 开始且缺少 `L69-L87`；`tpu-machines L624-L639` 必须包含 per-chip 表；v5e 配置映射不得再引用 `tpu-machines`。它还会核对总控已预留对象和关系的正式值，不把预留误判为 ID 冲突。

总控若接收来源记录，应先在受控临时正式副本中追加获准行，再运行 `scripts/validation/Validate-ResearchData.ps1`。G15 endpoint、配置事实、物理 package、器件 facts 和资料卡都不在本次合并范围内。