# S16 摘要卡：GPU Domain Specialization via Composable On-Package Architecture

## 摘要（100 至 200 字）

这篇 NVIDIA 论文用 2019 年 MLPerf 和假想 GPU-N 仿真研究可组合封装。训练通常同时受缓存与 HBM 带宽影响，大批量推理更依赖缓存，小批量推理则先受并行度不足限制。其主轴是 HPC 与深度学习，不能直接等同训练与推理；同一 GPU 核心配不同内存模块，反而说明产品可在共用架构上按负载调配资源。证据为经 V100 校准的模拟，无实物芯片，也未覆盖现代 LLM 的预填充、解码和 KV cache。