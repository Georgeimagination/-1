# M2-W3 AMD MI455X 模组包

> 状态：`ready_for_final_independent_review`  
> 本包最终上限：`ready_for_final_independent_review`  
> 资料截止日与动态页面访问日：2026-08-13  
> 写入边界：本目录；正式 32 表、正式资料卡和项目级文档只读

本文所用缩写：EAM 是 Enhanced Accelerator Module，即增强型加速器模组；XCD 是 accelerated compute die，即加速计算裸片；IOD 是 I/O die，即输入输出裸片；HBM 是 High Bandwidth Memory，即高带宽内存；LDS 是 Local Data Share，即本地数据共享存储。TFLOP/s 与 TOP/s 分别表示每秒万亿次浮点运算和每秒万亿次运算。

## 对象边界

本包只处理 `OBJ-AMD-MI455X`，正式对象类型为 `module`。架构代际通过既有关系 `OREL-AMD-MI455X-IMPLEMENTS-CDNA5` 引用；CDNA 5 的执行模型、缓存、LDS、指令和数值语义没有复制为 MI455X 产品事实。

`OBJ-AMD-HELIOS-72-MI455X` 只作为排除边界。Helios 的 72 模组构成、tray、机架算力、31 TB HBM4、机架通信、供电、冷却分配和拓扑迁移量为 0。MI440X、MI430X、MI500、OAM（Open Accelerator Module，开放加速器模组）、PCIe（Peripheral Component Interconnect Express）卡和合作伙伴系统也不在本包。

## 来源冻结与最小集

本包新增两个内容版本和四个访问入口，达到队列允许的来源上限，但没有为凑数注册媒体或第三方转述。MI455X 专用产品页固定于 2026-08-13，217,833 字节，SHA-256 为 `2fa27618862c42b0b9e6eed2e5c88c360e6eac2650d9fc97bae08c6338315b47`。官方 brochure 的版本标识为 LE-93204-00 07/26、PID 5158303，共 2 页、659,374 字节，SHA-256 为 `6555fef1399a35f472e325dc61936d293e129735ec1e191d5fd0f3b6fa0c4208`。

另外复用 `SRC-M2W2-AMD-MI400-LANDING-20260813` 和 `SRC-M2NA-AMD-CDNA5-WP`。MI400 固定页只提供明确以单个 MI455X 为主语的 3D hybrid-bonded dies、Infinity Fabric、CoWoS-L 和 HBM stack 复核；CDNA 5 白皮书只承担架构关系与架构级语义边界。修复后的 39 条直接事实重新运行反向移除检查后，四个来源仍各有不可替代贡献；选择运行保持 `draft`，等待不同代理复核。

## 修复后的结构化内容

独立复核指出两项关键问题后，本包恢复了截止日 `announced` 状态链，并删除了四条不满足稠密和累加前置条件的存算比。当前共有 39 条事实，全部是直接事实；另有 53 条逐来源断言、44 条字段要求、5 个组件、2 个存储层级、3 条链路、12 条精度路径和 9 个条件集。派生事实、派生指标和派生输入均为 0，`special-capabilities.csv` 与 `topologies.csv` 也保持空表。`card-completeness.csv` 恰有 9 行。

产品状态 `announced` 是受控归一化，只表示截止日已经公开宣布，不等于已出货、`production_ramp` 或 `available`。实际可用日期、功耗、程序员可见累加、物理累加器、MoE（Mixture of Experts，混合专家）/Top-K 专用实现、HBM 总接口宽度、die 面积和版本化 runtime 共 8 项继续使用 `not_found`；每项都有检索日志和四个选定来源的逐一核对结果。

brochure 的 40,265、20,133、5,033 和 10,066 TFLOP/s 或 TOP/s 作为精确规范值；专页的 40.3、20.1、5 和 10.1 PFLOP/s 或 POP/s 只作舍入复核。基准列没有被外推为 dense，只有原表明确标成 `W/STRUCTURED SPARSITY` 的列才记为 `structured_sparse`。厂商性能格式标签不被解释成 A/B 操作数、乘积、累加或输出编码。

## 交付文件

资料卡草稿位于 `card-draft/AMD_Instinct_MI455X_模组资料卡.md`；24 份同表头暂存表位于 `structured/`；两份固定官方候选位于 `fixed-candidates/`。对象边界、来源冻结、来源贡献、对抗核验、修复记录和验证结果分别见本目录的 CSV、Markdown 与 `validation/` 文件。

## 验证结果

24 份暂存表的表头与正式表匹配 24/24。包内主键无重复，与正式库无 ID 碰撞；39 条事实和 44 条要求分别通过主体合同与目标合同；39 条直接事实都有 `source_checked` 断言，证据状态按不同 `source_id` 复算无误。资料卡引用全部 39 条事实和全部 8 条非 `value_available` 要求，不再引用任何已删除派生主键。

把 24 份暂存表叠加到正式库只读副本后，官方验证器在 `gate` 模式通过 32 张表和 102,752 项检查。正式基线本身通过 97,920 项检查。临时镜像删除后，正式 32 份 CSV 与包内基线逐文件相同，按 `relative_path|sha256|bytes` 排序计算的聚合哈希仍为 `6aa1bd6373b9d07b383a25c1355609cc6076ee8e491048d68d9c4ba445c0d165`。

本状态只表示修复已完成并可交给不同代理做最终独立复核，不构成 `accept`，也不授权正式合并或生命周期迁移。