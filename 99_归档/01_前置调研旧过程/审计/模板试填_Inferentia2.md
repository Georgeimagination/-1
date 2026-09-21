# 模板只读试填：AWS Inferentia2芯片实现

> 目的：检查模板能否容纳披露较少、厂商定位偏推理的芯片。  
> 输入只读：`资料卡/AWS/封装/AWS_Inferentia2_芯片实现资料卡.md` 与 `资料卡/AWS/架构/AWS_Inferentia2_架构卡.md`。  
> 本文件不新增正式事实，也不修改32张正式数据表。

## 对象与边界

试填对象是 `OBJ-AWS-INFERENTIA2-CHIP`，项目用 `package` 作为保守事实容器。公开资料没有证明它是单裸片，也没有给出封装方式、芯粒数、中介层、裸片面积或晶体管数。EC2 Inf2实例中的芯片数、主机内存和网络属于外部对象，不能回填。

| 字段 | 原始值 | 规范值/单位 | 对象与口径 | 定位 | 状态 |
| --- | --- | --- | --- | --- | --- |
| NeuronCore-v2数量 | 2 per chip/device | 2 count | Inferentia2芯片实现 | A04行1878至1888；A05行1928至1932 | `confirmed` |
| 混合浮点峰值 | 190 FP16/BF16/cFP8/TF32 TFLOPS | 190,000,000,000,000 FLOP/s | 芯片；理论峰值；原文把四格式合并 | A04行1884至1888 | `confirmed` |
| FP32峰值 | 47.5 FP32 TFLOPS | 47,500,000,000,000 FLOP/s | 芯片；理论峰值 | A04行1884至1888 | `confirmed` |
| INT8峰值 | 380 INT8 TOPS | 380,000,000,000,000 OP/s | 芯片；理论峰值 | A04行1884至1888 | `confirmed` |
| HBM容量 | 32 GiB | 34,359,738,368 byte | 芯片实现；二进制单位 | A04行1890至1894；A05行1928至1933 | `confirmed` |
| HBM带宽口径一 | 820 GiB/sec | 880,468,295,680 byte/s | 同一对象；官方A04口径 | A04行1890至1894 | `conflicting_unresolved` |
| HBM带宽口径二 | 820 GB/s | 820,000,000,000 byte/s | 同一对象；官方A05口径 | A05行1928至1935 | `conflicting_unresolved` |
| DMA带宽 | 1 TB/sec | 1,000,000,000,000 byte/s | 芯片DMA路径；不能替代HBM带宽 | A04行1896至1899 | `confirmed` |
| CC-Core数量 | 6 per device | 6 count | 集合通信核 | A05行1933至1935 | `confirmed` |
| NeuronLink-v2接口 | 2 per device | 2 count | 芯片端点；速率和方向未公开 | A05行1933至1935 | `confirmed` |

## 数值、存储与软件边界

架构资料说明NCv2含Tensor、Vector、Scalar和GpSimd四类执行引擎，Tensor Engine使用128×128脉动阵列；BF16/FP16 Tensor路径采用FP32累加。cFP8与TF32虽被列为支持格式，但完整乘积、累加、输出与舍入语义未找到，不能从相邻格式补齐。

资料还确认软件管理的SBUF scratchpad、PSUM累加存储、HBM到SBUF的异步DMA、压缩/解压、CC-Core和NeuronLink-v2。公开材料没有给出SBUF/PSUM容量或带宽，也没有给出NeuronLink速率、有效载荷和系统拓扑。Neuron Compiler插入引擎同步属于软件行为，不应写成芯片物理规格。

AWS把Inferentia2用于推理服务，但当前资料卡没有提供模型、batch、序列长度、并发、权重驻留、KV cache、TTFT、TPOT或尾延迟。厂商定位可以记录为设计意图，不能替代逐阶段性能证据。

## 派生指标试算

选择190 TFLOP/s混合浮点峰值时，HBM带宽有两个未决官方口径，因此机器平衡点必须并列，不能挑一个“更合理”的值。

按820 GB/s：

$$
R_{P/B}=231.71\ \text{FLOP/byte},\qquad R_{B/P}=0.004316\ \text{byte/FLOP}
$$

按820 GiB/s并换算为880,468,295,680 byte/s：

$$
R_{P/B}=215.79\ \text{FLOP/byte},\qquad R_{B/P}=0.004634\ \text{byte/FLOP}
$$

容量相对算力使用已确认的32 GiB与190 TFLOP/s：

$$
R_{C/P}=\frac{34{,}359{,}738{,}368}{190\times10^{12}}=1.808\times10^{-4}\ \text{byte·s/FLOP}
$$

$R_{P/B}$和$R_{B/P}$是互为倒数的Roofline机器配比；$R_{C/P}$仅按模板要求保留为描述性比值，现有证据没有确认它具有通用诊断含义。三者都不能单独预测工作负载性能。混合峰值把FP16、BF16、cFP8和TF32并列，不能证明四条路径在所有条件下完全等价。训练状态适配比和推理运行状态适配比均未计算，因为缺少同口径状态字节量。

## 试填结论

模板允许把“有值”“冲突”和“未披露”同时保留下来，没有逼迫低披露对象生成假精度。Inferentia2可以记录为AWS的推理设计意图，也能看出其HBM、DMA、集合通信和多类执行引擎，但现有资料不足以仅凭规格证明它相对训练芯片的阶段优势。HBM带宽单位冲突尤其说明，先冻结原值和口径，比急于得到一个存算比更重要。