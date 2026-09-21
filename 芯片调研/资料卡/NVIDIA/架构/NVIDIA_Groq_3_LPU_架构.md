# NVIDIA Groq 3 LPU 架构资料卡

对象 ID：`OBJ-NVIDIA-GROQ3-ARCH`。本卡记录 NVIDIA Groq 3 的 `architecture_generation`，不把第一代 Groq TSP 的结构或格式外推到本代，也不承接裸片、封装、LPX 卡、托盘或机架规格。

## 执行与数值边界

Groq 3 采用确定性的编译器编排执行。代际根组件 `CMP-NVG3-LPU` 承接跨计算、存储和通信的执行模型；MXM、VXM 与 SXM 分别执行稠密乘加、逐点算术与格式转换、向量置换与转置。官方还把 320-byte vector 描述为计算和通信的共同粒度。字段注册表要求 `FIELD-COMP-INSTRUCTION-TILE` 指向 precision path，因此结构化事实挂在 `PP-NVG3-320B-VECTOR`；原始断言仍保留“compute and communication”的完整范围。

公开材料没有给出 MXM 的输入、乘积、累加和输出格式，也没有给标量路径或芯片级向量吞吐。托盘和机架的 FP8 聚合值不能直接除成单 LPU 规格。

## 存储与互联

架构机制是扁平的 SRAM-first 工作存储：权重、激活和键值缓存由编译器与运行时放置，不依赖硬件管理 cache。规范化值为 `compiler_managed`，完整描述保留在来源断言中。500 MB 和 150 TB/s 是 per-LPU 实现规格，只进入实现对象待办。

C2C 的厂商原文是 high-radix point-to-point fabric。现有 `topology_type` 枚举不能无损表达这组限定，所以不再生成拓扑枚举事实；原词保留在 `TOPO-NVG3-HIGH-RADIX` 的 notes 中，`REQ-NVG3-TOPOLOGY-CLASS` 继续为 `pending_verification`。能够入事实层的是编译器确定性安排跨 LPU 路由，以及 plesiosynchronous（近同步、允许微小频差）时序协议。96 links、112 Gbps 和约 2.5 TB/s 都是 per-LPU 实现值，已使用单一来源 ID 存入待办。

## 特殊能力与软件映射

官方系统说明让 LPX 承担前馈网络（FFN）和混合专家模型（MoE）的 expert execution。这是部署分工，不足以证明芯片内存在专用 MoE router 或 Top-K 单元，两项保持 `not_found`。编译器负责计算、数据搬运和跨 LPU 路由的统一编排。

## 事实追溯

| 卡片内容 | fact_id | assertion / source / 定位 |
|---|---|---|
| NVIDIA Groq 3 LPU 架构身份 | `FACT-NVG3-NAME` | `ASRT-NVG3-NAME` → `SRC-NVG3-ARCH-BLOG-2026-03-16`，First look at the architecture |
| 确定性的编译器编排执行 | `FACT-NVG3-EXECUTION` | `ASRT-NVG3-EXECUTION` → `SRC-NVG3-ARCH-BLOG-2026-03-16`，Deterministic, compiler-orchestrated execution |
| 320-byte vector 是计算与通信粒度 | `FACT-NVG3-INSTRUCTION-TILE` | `ASRT-NVG3-INSTRUCTION-TILE` → `SRC-NVG3-ARCH-BLOG-2026-03-16`，Tensor-first compute and explicit data movement |
| MXM 执行固定类型的稠密乘加 | `FACT-NVG3-MXM-FUNCTION` | `ASRT-NVG3-MXM-FUNCTION` → 同源同节 |
| VXM 执行逐点算术、格式转换和激活 | `FACT-NVG3-VXM-FUNCTION` | `ASRT-NVG3-VXM-FUNCTION` → 同源同节 |
| SXM 执行置换、旋转、分发和转置 | `FACT-NVG3-SXM-FUNCTION` | `ASRT-NVG3-SXM-FUNCTION` → 同源同节 |
| SRAM-first 工作存储由编译器和运行时管理 | `FACT-NVG3-SRAM-MANAGEMENT` | `ASRT-NVG3-SRAM-MANAGEMENT` → `SRC-NVG3-ARCH-BLOG-2026-03-16`，MEM enables extreme on-chip memory bandwidth |
| C2C 采用 plesiosynchronous 时序 | `FACT-NVG3-C2C-PROTOCOL` | `ASRT-NVG3-C2C-PROTOCOL` → `SRC-NVG3-C2C-BLOG-2026-05-14`，Hardware-driven plesiosynchronous timing |
| 编译器确定性安排跨 LPU 路由 | `FACT-NVG3-C2C-ROUTING` | `ASRT-NVG3-C2C-ROUTING` → `SRC-NVG3-C2C-BLOG-2026-05-14`，Compiler-scheduled data movement |
| 编译器统一编排计算、搬运和通信 | `FACT-NVG3-SW-COMPILER` | `ASRT-NVG3-SW-COMPILER` → `SRC-NVG3-ARCH-BLOG-2026-03-16`，Deterministic, compiler-orchestrated execution |

上述表覆盖本对象在正式结构化数据中的 10 条事实。被移除的拓扑枚举不是证据丢失：厂商原词仍在 topology notes、字段要求和卡片正文中；per-LPU 数值保存在实现待办。

## 完整度、来源与验收

九域完整度为：identity `complete`；physical `not_applicable`；compute、memory、interconnect、software、evidence 为 `partial`；numerics 和 special_engines 为 `missing_public_data`。结构化记录见 `CC-NVIDIA-GROQ3-ARCH-*`。

最小架构来源保留架构博客和 C2C 专题博客。前者支持执行组织、SRAM 管理和编译器映射；后者独有互联时序与路由机制。LPX 产品页对本卡选定事实集没有新增内容，继续由 `COV-NVG3-PRODUCT-BY-ARCHBLOG` 标为 `fully_covered`。

验收：独立复核结论为 `accept`。总控已将本卡对应的结构化数据与来源链写入正式库；正式验证器通过 46,985 项检查，资料池校验核对 107 份 PDF，并保留 1 个既有解析器警告。