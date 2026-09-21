# Ascend 950 physical 事实候选冻结

> 冻结日期：2026-08-13  
> 状态：返修后冻结，待最终独立复核

HBM（High Bandwidth Memory）是高带宽内存。结构化去重后冻结 41 条直接事实和 50 条逐来源断言；断言模式为 42 条 `direct_statement`、8 条 `inferred`。共享裸片承担 12 条事实，Ascend 950PR 封装承担 16 条，Ascend 950DT 封装承担 13 条；候选阶段多计的一条共享身份记录未重复建事实。包内同时生成 6 个组件、2 个 HBM 存储层级、3 条互联、5 条精度路径、11 个条件集、106 条字段要求和恰好 27 条九域完整度记录；不创建派生指标、特殊能力占位对象或拓扑占位对象。106 条要求已逐字段去重，包含 41 条 `value_available`、53 条 `not_found`、11 条 `not_applicable` 和 1 条 `pending_verification`。

H-2 先直接说明 950PR 与 950DT 使用同一颗 Ascend 950 裸片，随后以复数 “Ascend 950 chips” 给出四条低精度厂商吞吐、SIMD（单指令多数据）与 SIMT（单指令多线程）混合执行、128 byte 访问粒度和 2 TB/s 互联。七项值由来源直接给出，但共享裸片主体来自上下文归一化，所以恰好七条 H-2 断言为 `inferred`；事实的 `fact_kind`、`evidence_state` 和来源数不变。吞吐来源没有说明矩阵阵列或向量路径，因此使用“厂商低精度 AI 吞吐”逻辑组件，并把运算类别保留为 `other`；不把这些数字擅自改写为矩阵峰值。共同芯片、950DT 路线图和 950PR 当前产品页的三个 2 TB/s 分属不同条件，不能相加。

950PR 只保存封装和当前产品页特有内容，包括 HiBL 1.0、最大 128 GB、1.6 TB/s、未注明精度的最大 1784 TFLOPS、灵衢 2.0 与最大 2 TB/s 双向互联。H-12 直接上市的主体是搭载 950PR 的 Atlas 350；把它归一化为 package 在嵌入条件下 `available` 的状态断言为 `inferred`，deployment 搭载断言保持 `direct_statement`。事实和资料卡保留“嵌入已上市卡、不是独立封装交付”的限定。Atlas 350 的 1561/804/425 TFLOPS、112 GB、1.4 TB/s、PCIe、卡间互联、600 W、散热、尺寸和重量迁移数均为 0。

950DT 只保存 H-2 的路线图对象事实：HiZQ 2.0、144 GB、4 TB/s、2 TB/s 总互联及 decode/训练定位。产品状态固定为 `announced`；2026 年第四季度是路线图窗口，不是正式可用、客户交付或通用供货证据。H-6 的 `?tag=950dt` 快照继续保留“路由为 DT、服务器正文仍为 PR”的渲染不一致，不从该正文抽取 DT 规格。

正式库既有两条 `package_contains_die` 关系仅由资料卡引用，不新增关系事实，也不推断 Da Vinci `implements_architecture`。15 条旧 Da Vinci 实现待办迁移数为 0，第三方填充值迁移数为 0。字段缺口只使用 `not_found`、`not_applicable` 或 `pending_verification`；四份一手资料均未明确宣称某项“不公开”，所以本包不使用 `not_public`。