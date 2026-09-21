# GA100 v3 软件栈来源族缺口补救

> 状态：官方版本化来源已逐项核验，供 v3 重建使用，不授权正式写入  
> 对象边界：软件事实写入 `OBJ-NVIDIA-AMPERE-ARCH`，以 CUDA Compute Capability 8.0（CC8.0）为架构目标；A100/GA100 只作为产品可达性和版本条件，不投影为 full GA100 die 的无条件属性  
> 写入边界：本轮只新增本报告，未修改正式表、资料卡、validator、进度、既有 staging 或来源快照  
> 联网核验日期：2026-08-21，Asia/Shanghai

## 裁决

r20 留下的五个软件字段都已找到条件完整的官方来源链，可以由 `pending` 改为 `value`。这里的 `value` 只表示指定版本的软件在 Ampere/CC8.0 目标上有官方支持或能力说明，不表示 GA100 裸片自带该软件。正式建模时必须保存版本、CUDA 条件、生命周期状态和产品可达性，不能把 A100 container 的条件下放为 full GA100 die 属性。

`FIELD-SW-FRAMEWORK` 可记录 NVIDIA PyTorch 20.06/20.07 container 与 NVIDIA TensorFlow 20.07 container。PyTorch 20.06 直接写明以 CUDA 11、cuDNN 8 支持 A100；20.07 把栈更新到 CUDA 11.0.194、cuDNN 8.0.1、NCCL 2.7.6、TensorRT 7.1.3。TensorFlow 20.07 同时给出 TensorFlow 1.15.3/2.2.0、同一 CUDA/库版本和 A100 支持。两类 container 是两个 source family；同一 container release-notes family 的 20.06 与 20.07 只是版本修订，不能当成两份独立来源。

`FIELD-SW-COMMUNICATION-LIBRARY` 可记录 NCCL 2.7.6。NCCL 2.7.6 release notes 明确支持 CUDA 11.0，PyTorch/TensorFlow 20.07 container 又把它与 A100/CUDA 11.0.194 绑定。20.06 TensorFlow 在 A100/GA100 上曾出现 `CUDA_ERROR_UNKNOWN`，官方 workaround 是把 2.7.5 换成 2.7.6-1；因此 2.7.5 只能保留为 launch-time 已知问题背景，不能与 2.7.6 写成同等成熟的推荐值。

`FIELD-SW-OPERATOR-LIBRARY` 应拆成多条版本化事实，而不是一条逗号清单。可接受的首发/早期栈包括 cuBLAS 11.1.0.229、cuDNN 8.0.1、TensorRT 7.1.3 CUDA 11 build 和 cuSPARSELt 0.0.1。它们的能力边界不同：cuBLAS 是 dense BLAS/GEMM 路径，cuDNN 是深度学习算子库，TensorRT 是 inference optimizer/runtime，cuSPARSELt 是 structured-sparse matrix multiplication 库。库存在不等于所有 datatype、operator、shape 或模型都被支持。

`FIELD-SW-DYNAMIC-SHAPE` 与 `FIELD-SW-QUANTIZATION-TOOL` 都可以由 TensorRT 建立 `value`。TensorRT 7.1.3 已公开 dynamic shape、optimization profile、INT8 calibration 与 Q/DQ/per-tensor symmetric quantization，但其 CUDA 11.0/A100 build 是 Preview；TensorRT 8.6.1 的固定 support matrix、release notes 与 Developer Guide 则把 CUDA 11.0 Update 1、CC8.0 A100/GA100、dynamic shape 和 INT8 calibration 连成稳定的版本化来源链。前者用于说明 2020 年首发成熟度，后者用于关闭字段。CUDA kernel interface、PTX 低精度指令和 cuSPARSELt pruning/compression 都不能替代这两个工具能力。

本轮没有运行 A100、container 或 TensorRT sample，所有软件事实的 evidence maturity 最高为 `documented_supported`。TensorRT 7.1.3 的 A100/CUDA 11 build 还需另存 lifecycle qualifier `preview`；不得写成 `runnable_verified` 或 `benchmarked`。

## 固定来源与实际 endpoint

以下 ID 都是 v3 草案名，本轮没有向正式 `source-families.csv`、`sources.csv` 或 endpoint 表写入任何 row。所有页面均通过 NVIDIA 官方站点实际读取；endpoint 类型是 HTML。带 `/archive/` 或 `/archives/` 的页面是版本化 archive HTML，container 页面是以 `rel_20-06.html`、`rel_20-07.html` 固定的 release-note HTML。它们尚未保存为项目本地快照，因此正式选择前仍需下载 payload、计算 fingerprint 并登记 endpoint。

| 草案 source family / version | 官方 URL、实际 endpoint 类型 | 精确 locator | 本轮用途 |
|---|---|---|---|
| `SFAM-NVIDIA-PYTORCH-CONTAINER-RELEASE-NOTES`；20.06、20.07 | [PyTorch 20.06](https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/rel_20-06.html)、[PyTorch 20.07](https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/rel_20-07.html)；版本化 release-note HTML | `Contents of the PyTorch container`、`GPU Requirements`、`Key Features and Enhancements`、`NVIDIA PyTorch Container Versions`、`Known Issues` | PyTorch 版本、CUDA/cuBLAS/cuDNN/NCCL/TensorRT 绑定、A100 支持和已知问题。20.06/20.07 同 family，只计一个来源家族。 |
| `SFAM-NVIDIA-TENSORFLOW-CONTAINER-RELEASE-NOTES`；20.06、20.07 | [TensorFlow 20.06](https://docs.nvidia.com/deeplearning/frameworks/tensorflow-release-notes/rel_20-06.html)、[TensorFlow 20.07](https://docs.nvidia.com/deeplearning/frameworks/tensorflow-release-notes/rel_20-07.html)；版本化 release-note HTML | 同名 `Contents`、`GPU Requirements`、`Key Features and Enhancements`、`Known Issues` | TensorFlow 版本与 A100/CUDA 11 backend；20.06 NCCL 2.7.5 故障和 2.7.6-1 workaround；20.07 组件清单。两个版本只计一个 family。 |
| `SFAM-NVIDIA-CUDA-TOOLKIT-RELEASE-NOTES`；CUDA 11.0 GA/Update 1 | [CUDA 11.0 GA Release Notes](https://docs.nvidia.com/cuda/archive/11.0_GA/cuda-toolkit-release-notes/index.html)；版本化 archive HTML | `CUDA Toolkit Major Component Versions`、`General CUDA`、`CUDA Libraries` → `cuBLAS Library` | `compute_80/sm_80`、A100、cuBLAS 11.1.0.229、BF16/TF32 与 Ampere 路径。CUDA 11.0 的后续修订仍属一个 release-notes family。 |
| `SFAM-NVIDIA-NCCL-RELEASE-NOTES`；2.7.5、2.7.6 | [NCCL 2.7.6 archived Release Notes](https://docs.nvidia.com/deeplearning/nccl/archives/nccl_276/release-notes/rel_2-7-6.html)；版本化 archive HTML | `Compatibility`、`Known Issues`、`Fixed Issues` | NCCL 2.7.6 与 CUDA 11.0、framework containers 的兼容性及 send/receive 限制。2.7.5 与 2.7.6 是同一 release-notes family 的版本条目。 |
| `SFAM-NVIDIA-CUDNN-RELEASE-NOTES`；8.0.0/8.0.1 历史条目 | [cuDNN 8.x archived Release Notes](https://docs.nvidia.com/deeplearning/cudnn/archives/cudnn-860/release-notes/rel_8.html)；版本化 archive HTML | `cuDNN 8.0.0 Preview` → `NVIDIA Ampere Architecture GPU support` | A100 支持起点、1D/2D convolution 的 TF32、fusion 与后续支持边界。8.0.1 的精确 container 绑定由 20.06/20.07 container pages 承担。 |
| `SFAM-NVIDIA-CUSPARSELT-GUIDE`；0.0.1 | [cuSPARSELt 0.0.1 Guide](https://docs.nvidia.com/cuda/archive/11.0/cusparselt/index.html)；版本化 archive HTML | `Key Features`、`Support`、`Prerequisites` | SM8.0、CUDA 11.0、FP16/BF16/INT8 sparse MMA、pruning/compression 与 autotuning。 |
| `SFAM-NVIDIA-CUSPARSELT-RELEASE-NOTES`；0.0.1、0.1.0 | [cuSPARSELt 0.1.0 Release Notes](https://docs.nvidia.com/cuda/archive/11.4.0/cusparselt/release_notes.html)；版本化 archive HTML | `cuSPARSELt v0.0.1`、`cuSPARSELt v0.1.0` | 版本演进：0.0.1 要求 CUDA 11.0+、SM8.0；0.1.0 要求 CUDA 11.2+，增加 SM8.6、TF32/FP32 kernels 和解耦的 compression/pruning APIs。同一 release-notes family 只计一次。 |
| `SFAM-NVIDIA-TENSORRT-RELEASE-NOTES`；7.1.3 历史条目、8.6.1 archive | [TensorRT 8.6.1 archived Release Notes](https://docs.nvidia.com/deeplearning/tensorrt/archives/tensorrt-861/release-notes/index.html)；版本化 archive HTML | `TensorRT Release 7.1.3` 的 `Attention`、`Key Features and Enhancements`、`Compatibility`、`Limitations`；8.6.1 `Compatibility` | 7.1.3 CUDA 11/A100 Preview、dynamic-shape calibration、INT8/QDQ 限制；8.6.1 的 CUDA 11.0 Update 1 兼容性。历史条目与当前条目仍是一个 release-notes family。 |
| `SFAM-NVIDIA-TENSORRT-SUPPORT-MATRIX`；8.6.1 | [TensorRT 8.6.1 Support Matrix](https://docs.nvidia.com/deeplearning/tensorrt/archives/tensorrt-861/support-matrix/index.html)；版本化 archive HTML | `Hardware and Precision` 表：CC8.0 / NVIDIA A100/GA100 GPU 行 | CC8.0 对 TF32、FP32、FP16、INT8、FP16/INT8 Tensor Cores 的支持；只作架构 reachability，不建立 full GA100 产品规格。 |
| `SFAM-NVIDIA-TENSORRT-DEVELOPER-GUIDE`；8.6.1 | [TensorRT 8.6.1 Developer Guide](https://docs.nvidia.com/deeplearning/tensorrt/archives/tensorrt-861/developer-guide/index.html)；版本化 archive HTML | `Working with Dynamic Shapes`，§8.1、§8.6-8.10；`Working with INT8`，§7.1、§7.4 | runtime dimension `-1`、optimization profile、shape tensor、dynamic-shape restriction、INT8 calibration、Q/DQ 与 dynamic-shape calibration profile。 |

作为旁证，本轮还核验了 [NCCL 2.7.6 Installation Guide](https://docs.nvidia.com/deeplearning/nccl/archives/nccl_276/install-guide/index.html) 的版本、collective 列表和 CUDA device 前提，以及 [cuBLAS 11.0 Guide](https://docs.nvidia.com/cuda/archive/11.0_GA/cublas/index.html) 的 Ampere compute-mode 表。它们没有提供上述选定来源链无法替代的字段值，先保留 `lead_only`，不为增加来源数而纳入最小集。

## 版本绑定与成熟度核验

### Framework containers

| 发布切片 | 版本与 backend 绑定 | A100/CC8.0 可达性 | 成熟度与边界 |
|---|---|---|---|
| PyTorch 20.06 | PyTorch `1.6.0a0+9907a3e`；CUDA `11.0.167`，cuBLAS `11.1.0`，cuDNN `8.0.1`，NCCL `2.7.5`，TensorRT `7.1.2` | `Key Features` 直接写明以 CUDA 11、cuDNN 8 支持 A100，并启用 Ampere 默认 TF32 | `documented_supported`，不是运行验证。channels-last 仍为 experimental。 |
| PyTorch 20.07 | PyTorch `1.6.0a0+9907a3e`；CUDA `11.0.194`，cuBLAS `11.1.0`，cuDNN `8.0.1`，NCCL `2.7.6`，TensorRT `7.1.3` | 20.07 的 `GPU Requirements` 旧文本只列 Pascal/Volta/Turing，但同页有 Ampere-specific cuDNN race known issue；A100 正向支持必须由同 family 的 20.06 直接声明与 CUDA CC8.0 链承接，不能从“出现已知问题”单独反推 | `documented_supported` 且有已知问题：Ampere 上 channels-last 路径可能因 cuDNN race 出现 NaN。不能写“20.07 对所有模型稳定”。 |
| TensorFlow 20.06 | TensorFlow `1.15.2/2.2.0`；CUDA `11.0.167`，cuBLAS `11.1.0`，cuDNN `8.0.1`，NCCL `2.7.5`，TensorRT `7.1.2` | 页面直接讨论 A100/GA100 | launch-time 有条件支持；某些 A100/GA100 情况会 `CUDA_ERROR_UNKNOWN`，官方 workaround 是 NCCL `2.7.6-1+cuda11.0`。 |
| TensorFlow 20.07 | TensorFlow `1.15.3/2.2.0`；CUDA `11.0.194`，cuBLAS `11.1.0`，cuDNN `8.0.1`，NCCL `2.7.6`，TensorRT `7.1.3`，Horovod `0.19.5` | `GPU Requirements` 明确包含 Ampere；`Key Features` 直接写明以 CUDA 11、cuDNN 8 支持 A100 | `documented_supported`。20.07 改用 2.7.6 与 20.06 workaround 一致，但“20.07 未再列出该故障”不能扩写为所有 20.06 问题均已修复。 |

PyTorch 20.07 的 `GPU Requirements` 遗漏 Ampere 是官方页面内部的陈旧文本，不构成否定性支持矩阵。正式 assertion 应把 PyTorch A100 支持定位到 20.06 的直接句子，再把 20.07 用作组件版本更新和已知问题限定；不能只取 20.07 的 container 清单便声称 backend 支持 A100。

### Libraries 与 TensorRT

| 组件 | 可接受的版本化结论 | 不可接受的扩写 |
|---|---|---|
| cuBLAS | CUDA 11.0.194 component table 给出 cuBLAS `11.1.0.229`；container 以缩略形式列 `11.1.0`。CUDA 11.0 release notes 将 BF16、TF32 与 Ampere 优化绑定到 cuBLAS/cuBLASLt。 | 缩略版与四段式版本不是冲突；不得把某种 GEMM compute type 写成所有 BLAS operator 都支持该 datatype，也不得忽略 early Ampere `cublasGemmEx` algorithm-selection 限制。 |
| cuDNN | 20.06/20.07 container 直接绑定 cuDNN `8.0.1`；cuDNN release notes 说明 8.0.0 已支持 A100，TF32 当时只覆盖 1D/2D convolution，grouped/3D 仍待后续。 | 不得写成 cuDNN 8.0.1 对全部 convolution、layout 和 fusion 路径都有完整 TF32；PyTorch 20.07 还记录了 Ampere cuDNN race。 |
| TensorRT | 20.07 container 绑定 `7.1.3`；release notes 说明 7.1.3 的 CUDA 11.0/A100 build 是 Preview，支持 dynamic shape、INT8 calibration 和 limited symmetric per-tensor Q/DQ。TensorRT 8.6.1 以后可由 release notes + support matrix + Developer Guide 建立 CUDA 11.0 Update 1、CC8.0 与完整文档化能力链。 | `7.1.3 GA` 是产品总标签，不代表 CUDA 11/A100 build 为 production GA；不得把 8.6.1 的 per-channel/explicit-quantization 能力倒填到 7.1.3。 |
| cuSPARSELt | `0.0.1` 明确要求 CUDA 11.0，支持 SM8.0，提供 FP16/BF16/INT8 structured-sparse MMA、pruning/compression 和 autotuning；`0.1.0` 要求 CUDA 11.2，新增 SM8.6、TF32/FP32 kernels 与解耦的 pruning/compression API。 | pruning/compression 是 structured sparsity 数据准备，不是量化或 calibration tool；0.1.0 的 CUDA 11.2 条件不能写成 11.0 首发能力。 |
| NCCL | `2.7.6` release notes 明确支持 CUDA 11.0，并由 PyTorch/TensorFlow 20.07 与 A100/CUDA 11.0.194 绑定；container 标注 `optimized for NVLink`。 | 不能由 `optimized for NVLink` 推断 NCCL 覆盖全部 NVLink/NVSwitch/PCIe/GDR 拓扑，也不能把 NCCL collective 写成 GA100 硬件 collective offload。2.7.6 仍有 send/receive concurrency、FIFO、GDR resource 和 DGX-1 topology 限制。 |

## 五个字段的原子裁决

| requirement / target | 状态 | 建议 value 与条件 | 精确来源链 | evidence maturity |
|---|---|---|---|---|
| `REQ-R1-GA100-V2-SW-FRAMEWORK`；`OBJ-NVIDIA-AMPERE-ARCH / FIELD-SW-FRAMEWORK` | `value` | 至少拆两条：① NVIDIA PyTorch container 20.06/20.07，PyTorch `1.6.0a0+9907a3e`，CUDA 11.0，A100 product reachability；② NVIDIA TensorFlow container 20.07，TensorFlow `1.15.3/2.2.0`，CUDA `11.0.194`，Ampere/A100 reachability。backend 是 CUDA，不是“GA100 backend”。 | PyTorch release-note family 20.06 direct A100 statement + 20.07 component update；TensorFlow 20.07 `GPU Requirements` + `Key Features`；CUDA 11.0 `compute_80/sm_80` 只作 reachability。 | `documented_supported`；未运行。 |
| `REQ-R1-GA100-V2-SW-COMMUNICATION-LIBRARY`；同一 target | `value` | NCCL `2.7.6`，CUDA 11.0，A100-capable 20.07 framework container；已公开范围为 multi-GPU collective library、container 标注 NVLink-optimized，并保留 GDR/send-receive 限制。闭合的 interconnect matrix 未公开，需在 value 中写 `exact topology matrix not specified`。 | NCCL 2.7.6 `Compatibility/Known Issues` + PyTorch/TensorFlow 20.07 component list；TensorFlow 20.06 issue/workaround 作成熟度限定。 | `documented_supported`；未运行。 |
| `REQ-R1-GA100-V2-SW-OPERATOR-LIBRARY`；同一 target | `value` | 分条记录 cuBLAS `11.1.0.229`、cuDNN `8.0.1`、TensorRT `7.1.3` CUDA 11/A100 Preview、cuSPARSELt `0.0.1`。每条保留自身 datatype/operator/shape 与 CUDA 条件；TensorRT 8.6.1 可另建稳定版本事实。 | CUDA 11.0 release notes；cuDNN 8.x release notes + containers；TensorRT release notes + support matrix；cuSPARSELt 0.0.1 guide。 | `documented_supported`；TensorRT 7.1.3/A100 lifecycle=`preview`。 |
| `REQ-R1-GA100-V2-SW-DYNAMIC-SHAPE`；同一 target | `value` | TensorRT `8.6.1`：runtime dimension `-1`、optimization profiles、runtime shape 设置、shape tensor 与限制；CUDA 11.0 Update 1；CC8.0。另保留 7.1.3 的 2020 launch snapshot，但标为 CUDA 11/A100 Preview。 | TensorRT 8.6.1 Developer Guide `Working with Dynamic Shapes` + 8.6.1 Support Matrix CC8.0 row + 8.6.1 Release Notes CUDA compatibility；7.1.3 release-note entry 作首发成熟度。 | `documented_supported`；未运行。 |
| `REQ-R1-GA100-V2-SW-QUANTIZATION-TOOL`；同一 target | `value` | TensorRT `8.6.1` INT8 calibration 与 Q/DQ explicit quantization；校准使用 representative data、calibrator/dynamic range，dynamic shapes 需 calibration optimization profile；CC8.0。7.1.3 只允许 symmetric per-tensor scale，且 CUDA 11/A100 build 为 Preview。 | TensorRT 8.6.1 Developer Guide `Working with INT8`、§8.10 + Support Matrix CC8.0 INT8/Tensor Core row + Release Notes；7.1.3 `Calibration with dynamic shapes/Limitations`。 | `documented_supported`；未运行。 |

动态形状字段的主体是 TensorRT inference runtime，不能泛化为 PyTorch/TensorFlow 任意 graph 的 dynamic-shape 支持。TensorFlow 20.06 的 XLA known issue 只说一种 compilation strategy 会避免 dynamic-shape 模型的重复编译，并没有给 shape contract、版本化 API 或 A100 backend 支持边界；它不承担该字段的正向 value。

量化工具字段同样只到 TensorRT 的 calibration/QDQ workflow。cuBLAS INT8 compute、PTX `mma`、Tensor Core INT8 支持与 cuSPARSELt INT8 kernel 都是执行能力，不是 quantization tool。`torch.cuda.amp` 和 Apex AMP 是 mixed precision 机制，也不是 INT8 quantization/calibration tool。

## Search-log 与 result 草案

以下仅是 v3 新 run 的草案语义，不复用 v2 的 `SEARCH-R1-GA100-V2-*` 主键，也不写入现有 staging。`source_types_checked` 应保存具体 family，而不是只写宽泛的 `developer_documentation`。

| 草案 search_id / requirement | query_or_path 草案 | result_status | result 草案 |
|---|---|---|---|
| `SEARCH-R1-GA100-V3-SW-FRAMEWORK` / `REQ-R1-GA100-V2-SW-FRAMEWORK` | 逐节检查 NVIDIA PyTorch container 20.06/20.07 与 TensorFlow container 20.06/20.07 的 `Contents`、`GPU Requirements`、`Key Features`、`Known Issues`；再用 CUDA 11.0 `compute_80/sm_80` 做 target reachability | `candidate_found` | PyTorch 20.06=`candidate`；PyTorch 20.07=`candidate` 但只承担版本更新/known issue；TensorFlow 20.07=`candidate`；TensorFlow 20.06=`candidate` 但限定为 launch issue；CUDA 11.0=`candidate` 只作 reachability，不能替代 framework fact。 |
| `SEARCH-R1-GA100-V3-SW-COMM` / `REQ-R1-GA100-V2-SW-COMMUNICATION-LIBRARY` | 检查 NCCL 2.7.5/2.7.6 `Compatibility/Known Issues`，PyTorch/TensorFlow 20.07 component list，TensorFlow 20.06 A100/GA100 workaround | `candidate_found` | NCCL 2.7.6=`candidate`；20.07 container families=`candidate`；TensorFlow 20.06=`candidate` qualifier。CUDA Programming Guide/PTX 的 warp reduction、IPC 和 NVLink 描述沿用 r20 的 `checked_no_support`，不能当 NCCL。 |
| `SEARCH-R1-GA100-V3-SW-OPLIB` / `REQ-R1-GA100-V2-SW-OPERATOR-LIBRARY` | 检查 CUDA 11.0 component table/cuBLAS notes、cuDNN 8.0.x Ampere section、TensorRT 7.1.3/8.6.1 compatibility、cuSPARSELt 0.0.1 `Support/Prerequisites` | `candidate_found` | CUDA/cuBLAS、cuDNN、TensorRT、cuSPARSELt 均=`candidate`；r16 的 cuSOLVER/A100 句只保留 A100 product condition，不用来替代 architecture-target 版本链；r20 的 Cooperative Groups primitive 继续 `checked_no_support`。 |
| `SEARCH-R1-GA100-V3-SW-DYNAMIC-SHAPE` / `REQ-R1-GA100-V2-SW-DYNAMIC-SHAPE` | 检查 TensorRT 7.1.3 release-note entry，8.6.1 Developer Guide §8、Support Matrix CC8.0 row、Release Notes compatibility；同时检查 TensorFlow 20.06 XLA known issue | `candidate_found` | TensorRT release notes、Developer Guide、Support Matrix=`candidate`；TensorFlow 20.06 XLA text=`checked_no_support` 于 condition-complete dynamic-shape value；CUDA/PTX sources 沿用 r20 `checked_no_support`。 |
| `SEARCH-R1-GA100-V3-SW-QUANTIZATION` / `REQ-R1-GA100-V2-SW-QUANTIZATION-TOOL` | 检查 TensorRT 7.1.3 calibration/QDQ/limits、8.6.1 Developer Guide §7/§8.10、Support Matrix INT8 row；反查 cuSPARSELt pruning/compression、CUDA/PTX low-precision paths | `candidate_found` | TensorRT release notes、Developer Guide、Support Matrix=`candidate`；cuSPARSELt=`checked_no_support` 于 quantization tool，仍是 operator-library candidate；CUDA/PTX low-precision execution=`checked_no_support`。 |

写入 search-result 时，20.06/20.07 可各有 source-version row，但 selection 的 source-family 去重不能把两个月份当独立 corroboration。相同原则适用于 CUDA 11.0 GA/Update、NCCL 2.7.5/2.7.6、cuDNN 8.0.x、cuSPARSELt 0.0.1/0.1.0 与 TensorRT cumulative release notes。

## 来源筛选角色与反向移除

下表是“若上述 value 被 v3 接受”的 selection 建议。正式 `selected_role` 只使用项目允许的枚举；没有使用 `software_evidence`、`framework_support` 等自造角色。

| source family | screening 建议 | selected_role | reverse-removal 裁决 |
|---|---|---|---|
| NVIDIA PyTorch Container Release Notes | `selected` candidate | `status_version_evidence` | 删除会失去 PyTorch 1.6.0a0、CUDA 11、A100 支持、20.07 component update 与 Ampere known issue 的同族版本链，`FIELD-SW-FRAMEWORK` 不再能完整保留 PyTorch 条目。 |
| NVIDIA TensorFlow Container Release Notes | `selected` candidate | `status_version_evidence` | 删除会失去 TensorFlow 1.15.3/2.2.0 对 A100/CUDA 11 的直接绑定，也会失去 NCCL 2.7.5→2.7.6 的 launch issue 边界。PyTorch family 不能替代 TensorFlow fact。 |
| NVIDIA NCCL Release Notes | `selected` candidate | `status_version_evidence` | 删除后只剩 container “包含 NCCL 2.7.6”，无法直接证明 NCCL 2.7.6 自身支持 CUDA 11.0及已知 send/receive/GDR 限制；通信库 value 的版本边界不完整。 |
| NVIDIA CUDA Toolkit Release Notes 11.0 family | `selected` candidate | `architecture_mechanism` | 删除会失去 `compute_80/sm_80`、A100/CUDA 11 reachability 和 cuBLAS 11.1.0.229/BF16/TF32 的直接官方链。container 的缩略组件名不能替代。 |
| NVIDIA cuDNN Release Notes | `selected` candidate | `architecture_mechanism` | 删除后仍知 container 含 cuDNN 8.0.1，却不知道 A100 支持起点和 TF32 convolution 的部分覆盖边界；operator-library fact 会退化成“库存在”。 |
| NVIDIA cuSPARSELt 0.0.1 Guide | `selected` candidate | `architecture_mechanism` | 删除会完全失去 CUDA 11.0/SM8.0、supported datatype 与 structured-sparse MMA 的直接版本化事实。CUDA/PTX sparse MMA 不能替代库/API。 |
| NVIDIA TensorRT Release Notes | `selected` candidate | `status_version_evidence` | 删除会失去 7.1.3 CUDA 11/A100 Preview、dynamic-shape calibration、QDQ 限制以及 8.6.1 CUDA compatibility。Support Matrix 与 Developer Guide 不承担首发生命周期。 |
| NVIDIA TensorRT 8.6.1 Support Matrix | `selected` candidate | `architecture_mechanism` | 删除会失去 TensorRT 8.6.1 对 CC8.0 A100/GA100 和 INT8/Tensor Core 的显式硬件绑定；Developer Guide 的通用 API 不能单独完成 architecture reachability。 |
| NVIDIA TensorRT 8.6.1 Developer Guide | `selected` candidate | `architecture_mechanism` | 删除会失去 dynamic-shape runtime contract、optimization profiles、INT8 calibration/QDQ workflow 与限制；release notes 只能证明功能被宣布，不能替代操作语义。 |
| NVIDIA cuSPARSELt Release Notes 0.1.0 archive | `lead_only`；若正式记录 0.1.0 版本演进则再选 | `status_version_evidence`，仅在选入时 | 当前五字段以 0.0.1 launch binding 已可闭合。若删除只损失 CUDA 11.2/SM8.6/解耦 API 的后续版本事实，不影响 0.0.1 value。 |
| NCCL 2.7.6 Installation Guide、cuBLAS 11.0 Guide | `lead_only` | 不进入 selection | collective 名称和 compute-mode 表可帮助解释，但当前 value 已由 release notes/container 直接覆盖。删除不损失已接受原子事实。 |

这不是最终最小来源数量。v3 若只保留 2020 launch snapshot，可以不选 TensorRT 8.6.1 Support Matrix/Developer Guide，但 dynamic-shape 与 quantization 两字段必须同时保留 `preview`，不能伪装成稳定支持。若按本报告建议用 8.6.1 闭合稳定 value，则 release notes、support matrix、Developer Guide 三个不同 work family 都有不可替代作用；不能把同一 TensorRT 产品名误当成同一 source family。

## 对象和能力边界

软件支持链应写成：`TensorRT/cuDNN/cuBLAS/cuSPARSELt/NCCL or framework version` → `CUDA version` → `CC8.0/Ampere target` → `A100 product example/reachability`。这里没有任何一步证明 full GA100 die 的 enabled SM 数、HBM 容量、板卡形态或产品状态。Support Matrix 的 `NVIDIA A100/GA100 GPU` 是 CC8.0 行的 example device，不授权把软件版本写入 GA100 die 的无条件事实。

`FIELD-ID-ARCH` 可以继续使用项目已批准的特殊投影规则；本报告没有新增或修改该字段。其余五个软件字段都留在 `OBJ-NVIDIA-AMPERE-ARCH`，A100/GA100 只进入 condition 或 reachability assertion。

“library exists”与“library supports a capability”必须分层。container 清单只能证明组件被打包；cuDNN/cuBLAS/cuSPARSELt/TensorRT 自己的版本文档才证明 datatype、operator、shape 或 calibration 能力。framework container 对 A100 的声明又只证明该 container/backend 组合受到官方支持，不等于任意 upstream wheel、任意 build flag 或任意模型都可运行。

## 网络、运行时、沙箱与操作异常

本轮官方页面通过联网检索接口正常读取，没有 remote service error，也没有运行时或模型能力限制。一次对 TensorRT 8.0.3 PDF 旧路径的直接 header 检查在 shell 内因 DNS 解析被 workspace sandbox 拒绝，错误为 `curl: (6) Could not resolve host: docs.nvidia.com`；这是 sandbox network denial，不是 NVIDIA endpoint 不可访问，也不是实现错误。该检查并非完成任务所必需，后续固定来源链全部改用已由联网接口实际读取的 TensorRT 8.6.1 archive HTML，因此没有降低字段裁决质量。

联网工具的前两次 direct-open 调用没有打印结果，是本轮输出处理方式错误，分类为 operator mistake；随后改用同一工具的 search/open 结果对象重新读取并获得完整官方内容。`report-humanizer` 第一次机器扫描又因工作目录拼写错误而无法创建进程，同样属于 operator mistake；修正路径后扫描正常完成。末次变更检查误把当前目录当作 Git checkout，`git status/diff` 返回 `not a git repository`；同一检查中的未转义反引号又被 shell 当成命令，二者均属 operator mistake，不影响文件内容，随后改用直接文件检查。没有 user interruption、approval denial、approval-review connection failure 或远程服务故障。

## 写入前要求

本报告只证明“存在可接收来源链”，不代表正式 source/endpoint 已完成。总控若据此生成 v3，应先把上述九个 selected candidate family 的实际 HTML 保存到新的、独立的 v3 source staging，记录访问日期、最终解析 URL、HTTP content type、bytes 与 SHA-256；不能覆盖 r1_ga100_14 staging，也不能只保存搜索摘要。

然后应按本报告的 source-version 去重规则生成 source family、source、endpoint、fact assertion、field requirement、search log/result 与 selection member。五个 requirement 可把结果改为 `value`，但只有在对应 value fact 和 assertion 已通过 validator、selection reverse-removal 也已重跑后，才能发布为 completed。若正式流程无法固定某个 payload，受影响的是 ingestion readiness，不应把已经找到的字段值改写成 `not_found`；应单独记 endpoint/fingerprint blocker。

## 文本复核

本文件完成后使用 `report-humanizer` 做了单文件机器扫描，并人工从结尾向前逆向复读。复读重点是五个字段状态、TensorRT 7.1.3 Preview 与 8.6.1 documented support 的时间切片、PyTorch 20.07 Ampere 文本遗漏、NCCL 2.7.5/2.7.6、cuBLAS 缩略/完整版本、A100 product condition 与 CC8.0 architecture target、library presence 与 capability、dynamic shape 与 quantization tool 的边界。修正扫描指出的一处对称否定句后，复扫结果为 `No machine-detectable AI tells found`。剩余风险是正式 payload 尚未本地固定、没有 A100 运行验证，而且 v3 source/endpoint/fact/search/selection row 尚未生成；本报告没有改写正式数据。
