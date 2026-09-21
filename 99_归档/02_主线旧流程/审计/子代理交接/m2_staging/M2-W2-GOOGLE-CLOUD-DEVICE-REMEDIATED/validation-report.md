# M2-W2-GOOGLE-CLOUD-DEVICE-REMEDIATED 校验记录

校验日期：`2026-08-13`  
状态：`ready_for_independent_review`

## 包内校验

修复版校验器通过 282 项检查：

```text
PASS: M2-W2-GOOGLE-CLOUD-DEVICE-REMEDIATED preparation package; 282 checks executed.
Scope: 3 reserved cloud_accelerator references, 3 reserved implements_architecture relations, 15 deferred dispositions, 7 configuration groups, 5 usable extracts, 1 partial G15 extract, 6-source device pool, 4 selection members.
```

检查范围包括三枚正式预留对象和三条正式预留关系的逐字段匹配；14 个父待办到 15 个处置项的闭合；95/96 GiB 分层和禁止推导；七组配置不得下沉器件；v5e 机器类型行移除 `tpu-machines`；六个本地提取的字节数与 SHA-256（安全哈希算法）；五个可用 endpoint（访问入口）的类型、首选状态、notes 和拟落路径；G15 的局部提取边界；六源器件候选池、四个选择成员和四条单源覆盖。

校验器还读取固定内容，验证 G05 `L211`、G08 `L144/L154/L158`、G09 `L149/L156/L159`、G10 `L143/L148/L152/L156` 和 `tpu-machines L624-L639`。G15 的第一个行标记必须是 `L148`，文件中不得出现 `L69-L87`，同时保留末尾 `L409`。因此，哈希匹配不会再被误当成 G15 证据定位存在。

正式 32 表没有被本修复包修改。总控已在本包修复前根据上一轮独立范围复核，预留三枚 Google Cloud TPU 器件对象和三条架构关系；校验器核对这些既有正式行，而不再把它们报成碰撞。项目正式校验器本轮只读运行结果为：

```text
PASS: 32-table research data model; 93251 checks executed.
Registry: 323 columns, 488 enum values.
```

## 来源补取与错误分类

OpenXLA 官方页面可通过联网读取器看到 410 行正文和 `L69-L87`，但原始响应体下载没有成功。普通权限调用 Windows `curl.exe` 返回退出码 35 和 `SEC_E_NO_CREDENTIALS`；已批准的提权重试仍返回退出码 35 和 `SSL/TLS connection failed`。两次都没有生成文件。这属于远端或本机 TLS（Transport Layer Security，传输层安全）链路错误，不是用户拒绝、沙箱拒绝、自动审批拒绝或审批连接故障。

远端规格通过三路官方内容核对，并不改变本地 endpoint 裁决。G15 本地文件仍从 `L148` 开始，已改为 `pending_verification`，正式拟落路径为空。v6e 的 2 SparseCore（稀疏计算核）固定证据改由 `tpu-machines` 承担，G05 作为交叉来源。没有使用第三方页面补洞。

## 修复点复核

`tpu-machines` 的器件 screening 已从 `out_of_scope` 改为 `selected`，并进入反向移除成员。G05、G08、G09、G10、G15 与 `tpu-machines` 六源处于同一候选池。G05 和 G15 的 SparseCore 覆盖分别拆成一行一个覆盖来源，G15 的 96/32 GiB 没有用于改写 G09/G10 的 95 GiB/32 GB。

`CFGDISP-GOOGLE-V5E-MACHINE-TYPES` 只保留 G08。v6e 组件处置行改为 G10 与 `tpu-machines`，不再引用当前不可用的 G15 endpoint。14→15 条处置、所有配置禁写规则和 95/96 GiB 分支保持不变。

## 成稿与冻结

README、来源冻结、远端补取日志、合并说明和本校验记录在冻结前按 `report-humanizer` 与 `shuorenhua` 做最后一轮检查。数字、路径、哈希、ID、单位、错误类型和责任归属作为 protected spans（禁改片段）原样保留。最终文件清单与哈希见 `package-manifest.csv`，清单文件自身的 SHA-256 见 `package-freeze.sha256`。