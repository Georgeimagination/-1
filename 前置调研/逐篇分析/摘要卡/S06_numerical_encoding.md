# S06：Numerical Encoding for DNN Accelerators

## 摘要（100–200 字）

这篇 2021 年 SIGARCH 博客从数值格式解释训练与推理加速器为何分化：作者称推理更能采用低精度提高计算密度，训练反向传播中的梯度动态范围则推高浮点、存储、带宽和功耗需求。HBFP 把点积、卷积置于 8 位块浮点路径，其他操作保留 FP32，说明差异可按操作组合而非绝对二分。证据适用于 CNN、LSTM 和早期 BERT；未覆盖 HBM、互联、KV cache 与现代 LLM 服务。文章属作者个人观点，且与 S02 同属 `WF-COLTRAIN`，不能独立计票。
