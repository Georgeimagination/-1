# S05｜Hardware Accelerators for Training Deep Neural Networks

## 摘要（100–200 字）

这份 2019 年 ISCA 教程从训练侧梳理反向传播、激活保存、混合精度、稀疏化与分布式同步。它指出，小批量可把低利用率 GEMV 转成 GEMM，但会牵动收敛；训练还需保存激活、梯度和优化器状态，并以重计算、分级精度及集合通信换取效率。资料主要面向 CNN 和早期 Transformer，推理只零星提及，不能单独支撑训练—推理双边结论。