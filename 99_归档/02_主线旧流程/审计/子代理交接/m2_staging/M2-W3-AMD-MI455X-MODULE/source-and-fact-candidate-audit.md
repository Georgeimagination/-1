# MI455X 来源、对象匹配与事实候选审计

> 记录日期：2026-08-13  
> 工作包：`M2-W3-AMD-MI455X-MODULE`  
> 当前阶段：定点修复完成，待最终独立复核

本文所用缩写：EAM 指增强型加速器模组，XCD 指加速计算裸片，IOD 指输入输出裸片，HBM 指高带宽内存，ECC 指纠错码，MoE 指混合专家模型。

## 对象匹配

AMD 专用产品页标题为 “AMD Instinct™ MI455X GPUs”，固定 brochure 的产品表题为 “AMD Instinct™ MI455X Platform Specifications”。两份资料都与正式对象 `OBJ-AMD-MI455X` 匹配；正式对象类型为 `module`，所以本包只接收明确落在单个 MI455X 模组上的事实。

`OBJ-AMD-CDNA5-ARCH` 只通过既有关系 `OREL-AMD-MI455X-IMPLEMENTS-CDNA5` 投影。CDNA 5 白皮书中的执行模型、片上存储、精度语义和指令机制不复制为 MI455X 产品事实。`OBJ-AMD-HELIOS-72-MI455X` 只用于排除范围：72 模组、tray、机架算力、31 TB HBM4、机架通信、冷却分配和拓扑迁移量均为 0。

## 固定来源及独有贡献

| 来源 | 固定状态 | SHA-256 | 独有贡献 |
|---|---|---|---|
| MI455X 专用产品页，访问日 2026-08-13 | 新固定候选；HTTP 200；217,833 字节 | `2fa27618862c42b0b9e6eed2e5c88c360e6eac2650d9fc97bae08c6338315b47` | exact-object 身份、WGP、L2、晶体管、Launch Date、受控 `announced` 语境、UALoE/UALink 标签和舍入规格 |
| MI455X brochure，LE-93204-00 07/26、PID 5158303 | 新固定候选；HTTP 200；2 页；659,374 字节 | `6555fef1399a35f472e325dc61936d293e129735ec1e191d5fd0f3b6fa0c4208` | 精确峰值表、8 个 XCD、2 个 IOD、CPU-to-GPU Infinity Fabric 带宽、全芯片 ECC 和 page retirement |
| MI400 landing 固定快照 | 复用既有固定内容版本 | `aa5603704c4d77d1e912a5921e289ccabaa45111bab209c2ce08975aedc58a7e` | 明确以单个 MI455X 为主语的 stacked 3D hybrid-bonded compute dies、Infinity Fabric、CoWoS-L 和 12 stacks 复核 |
| CDNA 5 白皮书 | 复用既有固定 PDF | `2381d60185f79989d3d5e4260c86f72504fcab256b40bb85fe4a6dd782afb3ef` | 支撑既有架构关系及数值语义边界，不支撑本包产品定值 |

专页是动态网页，事实引用落到 2026-08-13 的固定候选；网页以后变化不能反写本次截止日。brochure 第 2 页的四 GPU tray、18 trays、72-GPU rack、虚拟 pod 和 Oracle 计划部署属于系统或未来计划，本包迁移量为 0。

产品页标题和 `Launch Date 7/23/2026` 与正式范围门共同支持截止日受控状态 `announced`。这项归一化不证明已经出货、量产爬坡或一般可用；实际可用日期继续保持 `not_found`。

## 修复后的事实集合

`facts.csv` 共有 39 条，全部是直接事实，低于 45 条预算上限。按事实主体拆分如下：

| 主体类型 | 行数 | 内容边界 |
|---|---:|---|
| `object` | 17 | 身份、launch date、`announced` 状态、制程与封装、XCD/IOD 数量、晶体管、时钟、形态、冷却、HBM stack 数量和 RAS |
| `component` | 4 | WGP 数量、HBM4 容量、L2 容量和 HBM4 峰值带宽 |
| `precision_path` | 15 | 厂商性能表中的矩阵与向量理论峰值；不相加成“总算力” |
| `link` | 3 | CPU-to-GPU、UALoE scale-up 和厂商标为 UALink 的 scale-out 聚合带宽 |

39 条事实都只有一个主体外键，并满足 `fields.csv` 的 `allowed_subject_kinds`。44 条字段要求也逐条满足 `allowed_requirement_target_kinds`。当前另有 5 个组件、12 条精度路径、2 个存储层级、3 条链路和 9 个条件集；派生指标、派生输入、特殊能力和拓扑均为 0。

brochure 把 FP16、INT8 和 BF16 分成基准列与 `W/STRUCTURED SPARSITY` 列，但基准列没有打印 dense，稀疏列也没有公布稀疏图样。因此基准列使用 `not_specified`，第二列使用 `structured_sparse`，且不补成 2:4。OCP MXFP4、MXFP6、MXFP8 和 FP8 行同样没有给出稀疏条件。precision-path 名称只表示厂商性能表标签，不证明操作数 A/B、乘积、累加或输出编码。

独立复核否决了四条 FLOP/byte 存算比。虽然除法本身可以复算，字段 `FIELD-DER-COMPUTE-BW-SPEC` 要求“矩阵稠密峰值除以铭牌带宽”；当前分子没有 dense 证明，也没有 MI455X 产品级累加语义，HBM4 方向仍未说明。四条事实、四条要求、四个条件集、四条派生指标和八条派生输入已经整链删除，没有把结果留在说明文字中冒充正式指标。

## 来源去重与反向移除

修复后以 39 条直接事实重跑 `SELRUN-M2W3-AMD-MI455X-20260813`。产品页不能由 brochure 替代，因为它独有 exact-object 状态语境、WGP、L2、晶体管和接口标签；brochure 不能由产品页替代，因为它独有精确峰值、XCD/IOD、CPU-to-GPU 和 RAS；MI400 固定页独有产品级封装句子；CDNA 5 白皮书承担架构关系和语义边界。删除任一成员都会失去相应覆盖，所以四个成员继续保留。

媒体、论坛和早期 19.6 TB/s 转述没有进入来源注册表。它们既不能取代截止日官方 23.3 TB/s，也没有提供可采用的一手功耗、可用日期、累加或专用模块定值。来源选择运行仍是 `draft`，必须由不同代理最终复核后才能签字。

## 仍未找到的字段

实际可用日期、单模组功耗、程序员可见累加、物理累加器、MoE/Top-K 等专用实现、HBM 总接口宽度、die 面积和版本化 runtime 共 8 项使用 `not_found`。每项都有一条检索日志及四条来源检查结果。未知数值没有写成零，也没有从液冷形态、邻近型号、Helios 聚合值或第三方报道推断。

## 访问与工具记录

初次固定资料时，本地沙箱访问 AMD 页面被沙箱拒绝；获批的升级请求随后返回 HTTP 200，所以不是远端服务故障。依赖定位调用超时、PDF 包装器路径失效和早期临时 junction 清理异常属于工具运行时故障，均已通过替代路径完成核验和清理。定点修复阶段出现的换行定位与哈希脚本构造错误属于执行代理操作错误，修正后的成功检查已经覆盖失败结果。没有审批拒绝或远端服务错误降低本包证据质量。