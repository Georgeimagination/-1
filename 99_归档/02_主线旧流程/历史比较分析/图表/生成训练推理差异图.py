#!/usr/bin/env python3
"""Generate the data appendix and figures for the training/inference chip report.

The source values below are condensed from the 36 completed chip cards.  Text
fields preserve scope and caveats; numeric columns are only used when the card
exposes a value that is meaningful at the selected SKU/per-chip level.
"""

from __future__ import annotations

import csv
import math
import re
from collections import Counter, defaultdict
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont


HERE = Path(__file__).resolve().parent
ROOT = HERE.parent

TRAIN = "训练主定位"
INFER = "推理主定位"
UNIFIED = "训推共用/非排他"

PALETTE = {
    TRAIN: "#2F6B9A",
    INFER: "#D97732",
    UNIFIED: "#6F7D6A",
}
TEXT = "#1F2933"
MUTED = "#5B6573"
GRID = "#D9DEE5"
LIGHT = "#F5F7F9"
WHITE = "#FFFFFF"

FONT_PATH = "/System/Library/Fonts/Hiragino Sans GB.ttc"


# The indicator scope is defined before coverage is counted.  It combines the
# current fact-card contract, the pre-research workload framework, and the two
# earlier local comparison projects.  Rows marked as external validation are
# intentionally not back-filled from server or benchmark data into chip cards.
INDICATOR_REGISTRY = [
    ("对象与分组", "SKU/版本/发布时间、对象层级、厂商定位、目标 workload、产品目标",
     "按厂商、年代、部署、可比家族分层",
     "36 产品均保留主语和定位；workload/产品目标按原卡汇总"),
    ("Core 身份与执行", "Core/IP 共享关系、执行模型、调度、指令/数据流组织",
     "同 Core/die 家族对照；执行模型分类",
     "Core 身份 36；执行模型 33 可分类"),
    ("Core 资源配比", "矩阵/张量单元数与阵列形状、向量/SIMD、标量/控制、实际使能资源、时钟",
     "物理 M:V:S 比；同 SKU、同精度、同 dense 条件的矩阵/非矩阵吞吐比",
     "9 个 SKU 可列物理 M:V:S；4 个可列完整同精度 M:V:S 吞吐；13 个可列更宽口径的矩阵/Vector 或 non-Tensor 比；跨厂商单元数不做统一排名"),
    ("Core 数值通路", "输入/权重/乘积/累加/输出格式、缩放、舍入、饱和、稠密/稀疏条件",
     "按格式的支持分布；累加语义证据层级",
     "格式支持 36 产品全量检查；完整 datapath 仅能在严格子集比较"),
    ("Core 非矩阵机制", "SFU、归约、Top-K、transpose/permute、embedding、结构化/非结构化稀疏、数据搬运引擎",
     "按物理单元/数据通路/专用指令分类；不与矩阵峰值相加",
     "结构化稀疏和专用机制已分列；原卡未披露不作硬件不存在的反证"),
    ("片上存储与数据流", "register/accumulator、local SRAM/scratchpad、shared SRAM/cache/LLC、管理语义、数据驻留、DMA/预取/压缩、重算/分页",
     "同物理层级家族对照；片上容量/矩阵单元或峰值",
     "27 产品至少有一层定量；不同存储层级不合并成‘总 SRAM’"),
    ("Die/chiplet", "满配计算资源、计算/I/O die 数、工艺、面积、晶体管、片上 NoC、controller/PHY",
     "计算 die 组织；按年代和物理主语去重",
     "11 单逻辑计算 die、2 一颗计算 die+辅助 die、10 多计算 die、13 物理组织不足；面积/晶体管独立对象过少"),
    ("Package 与 D2D", "die/HBM/interposer/基板组成、D2D 协议、拓扑、链路数/速率/方向、封装 RAS",
     "D2D 带宽/计算峰值；package bisection 单列",
     "机制与对象全量列出；绝对带宽的物理主语不同，暂不做统一数值排名"),
    ("SKU 外部存储", "介质、容量、带宽、stack/bus/controller、方向、一致性/远程访问/显式搬运语义",
     "P/B、B/P、C/P；容量/带宽家族方向；工作集适配比需外部 workload",
     "介质 36；外部 DRAM 容量+带宽 33；严格存算比样本不含训练主定位"),
    ("主机与设备端点", "PCIe/CXL/主机接口、设备直连端口、每设备注入带宽、方向、payload、持续值、collective offload",
     "端点带宽/计算峰值；按 endpoint/bridge/raw-pin 主语分层",
     "端点描述或明确无专用端点 35；20 有正数名义值，payload/持续口径仍不统一"),
    ("Scale-up", "最大单一工作域、拓扑、交换结构、每设备度数、跳数、二分带宽、延迟、集合通信、故障域",
     "工作域大小和拓扑质量分开；bridge/server/Pod/rack 不混用",
     "28 有数值工作域；拓扑质量多为定性或系统对象"),
    ("Scale-out", "集成 NIC/DCN 端点、每 SKU/NPU 带宽、方向/payload、网络拓扑、路由和集合通信",
     "端点注入/峰值；小消息与 all-to-all 验证需实测",
     "严格 package/SKU 端点只有 MI455X 1 项；Ascend 950DT 另有 per-NPU 服务器配置，但 NIC 位置未确认"),
    ("功耗、散热与部署", "TDP/TBP/典型/上限/fleet average、可配置档、形态、冷却、边缘/PCIe/云内/高密度部署",
     "同功耗口径的性能/W；部署分层后比较",
     "24 有数字功耗；不同口径不合并为能效排名"),
    ("RAS 与分区", "ECC/SDC、检测/重放/隔离/降级、备份、checkpoint、虚拟化/分区、die/package/设备/系统故障域",
     "长作业可用性与服务尾延迟需外部实测",
     "18 产品有具体芯片/package 机制，1 产品只有 RAS Engine 名称；系统冗余不下放为芯片 RAS"),
    ("工作负载与系统验证", "训练前向/反向/更新、prefill、decode、MoE 的状态、shape、batch、序列、并行、软件版本",
     "MFU/HFU/MBU、TTFT/TPOT/ITL、goodput、可持续带宽、实际流量、扩展效率、单位工作能耗",
     "不属于 36 张芯片事实卡；只作为验证层，不用系统 benchmark 回填芯片属性"),
]


# Strict within-SKU ratios.  Each row uses a dense theoretical matrix path and
# a non-matrix path at the same precision and product scope.  NVIDIA labels the
# latter "non-Tensor" rather than a pure vector engine, so those rows are kept
# as an explicit proxy instead of being silently relabelled as vector compute.
CORE_BALANCE_RECORDS = [
    dict(short="A100", family="NVIDIA Ampere", precision="BF16", matrix=312.0, nonmatrix=39.0, nonmatrix_label="non-Tensor", evidence="proxy"),
    dict(short="H100 SXM", family="NVIDIA Hopper", precision="BF16", matrix=989.4, nonmatrix=133.8, nonmatrix_label="non-Tensor", evidence="proxy"),
    dict(short="H100 PCIe", family="NVIDIA Hopper", precision="BF16", matrix=756.0, nonmatrix=102.4, nonmatrix_label="non-Tensor", evidence="proxy"),
    dict(short="Trainium1", family="AWS NCv2", precision="FP32", matrix=23.0, nonmatrix=2.3, nonmatrix_label="VectorEngine", evidence="direct"),
    dict(short="Inferentia2", family="AWS NCv2", precision="FP32", matrix=23.0, nonmatrix=2.3, nonmatrix_label="VectorEngine", evidence="direct"),
    dict(short="Trainium2", family="AWS NCv3", precision="FP32", matrix=20.0, nonmatrix=1.0, nonmatrix_label="Vector Engine", evidence="direct"),
    dict(short="Trainium3", family="AWS NCv4", precision="FP32", matrix=20.0, nonmatrix=1.2, nonmatrix_label="Vector Engine", evidence="direct"),
    dict(short="MI300X", family="AMD CDNA 3", precision="FP32", matrix=163.4, nonmatrix=163.4, nonmatrix_label="Vector", evidence="direct"),
    dict(short="MI325X", family="AMD CDNA 3", precision="FP32", matrix=163.4, nonmatrix=163.4, nonmatrix_label="Vector", evidence="direct"),
    dict(short="MI350P", family="AMD CDNA 4", precision="FP16", matrix=1150.0, nonmatrix=72.0, nonmatrix_label="Vector", evidence="direct"),
    dict(short="MI350X", family="AMD CDNA 4", precision="FP16", matrix=2309.6, nonmatrix=144.2, nonmatrix_label="Vector", evidence="direct"),
    dict(short="MI355X", family="AMD CDNA 4", precision="FP16", matrix=2516.6, nonmatrix=157.3, nonmatrix_label="Vector", evidence="direct"),
    dict(short="MI455X", family="AMD CDNA 5", precision="FP16", matrix=5033.0, nonmatrix=315.0, nonmatrix_label="Vector", evidence="direct"),
]
CORE_BALANCE_BY_SHORT = {item["short"]: item for item in CORE_BALANCE_RECORDS}

PHYSICAL_MVS_RECORDS = [
    ("TPU v4", "8 MXU", "2 VPU", "2 scalar", "4:1:1", "128×128 MXU；物理数量比"),
    ("TPU v5e", "4 MXU", "1 vector", "1 scalar", "4:1:1", "128×128 MXU；物理数量比"),
    ("TPU v5p", "8 MXU", "2 vector", "2 scalar", "4:1:1", "128×128 MXU；物理数量比"),
    ("TPU v6e", "2 MXU", "1 vector", "1 scalar", "2:1:1", "256×256 MXU；数量比不能代替吞吐比"),
    ("Inferentia1", "1 Tensor/Core", "1 Vector/Core", "1 Scalar/Core", "1:1:1", "每 NCv1；GpSIMD 不适用"),
    ("Inferentia2", "1 Tensor/Core", "1 Vector/Core", "1 Scalar/Core", "1:1:1", "每 NCv2；另有 GpSIMD"),
    ("Trainium1", "1 Tensor/Core", "1 Vector/Core", "1 Scalar/Core", "1:1:1", "每 NCv2；另有 GpSIMD"),
    ("Trainium2", "1 Tensor/Core", "1 Vector/Core", "1 Scalar/Core", "1:1:1", "每 NCv3；另有 GpSIMD"),
    ("Trainium3", "1 Tensor/Core", "1 Vector/Core", "1 Scalar/Core", "1:1:1", "每 NCv4；另有 GpSIMD"),
]
PHYSICAL_MVS_BY_SHORT = {item[0]: item for item in PHYSICAL_MVS_RECORDS}

# Complete same-precision matrix:vector:scalar throughput is available only
# for four NeuronCore products.  Values are per Core FP32 theoretical peaks.
CORE_MVS_THROUGHPUT_RECORDS = [
    dict(short="Inferentia2", family="AWS NCv2", precision="FP32", matrix=23.0, vector=2.3, scalar=2.9),
    dict(short="Trainium1", family="AWS NCv2", precision="FP32", matrix=23.0, vector=2.3, scalar=2.9),
    dict(short="Trainium2", family="AWS NCv3", precision="FP32", matrix=20.0, vector=1.0, scalar=1.2),
    dict(short="Trainium3", family="AWS NCv4", precision="FP32", matrix=20.0, vector=1.2, scalar=1.2),
]
CORE_MVS_BY_SHORT = {item["short"]: item for item in CORE_MVS_THROUGHPUT_RECORDS}


# Data-management categories retain the management boundary that is lost when
# every local memory is called "SRAM".  The mapping is deliberately categorical:
# cache capacity, scratchpad capacity and DMA bandwidth remain separate raw
# fields and are never added into a synthetic on-chip-memory total.
DATA_MANAGEMENT_CLASS = {
    **{name: "硬件 cache + 显式 local/shared memory" for name in (
        "A100", "H100 SXM", "H100 PCIe", "H100 NVL", "L4", "L40S",
        "H200 SXM", "H200 NVL", "B200", "B300",
        "MI300X", "MI325X", "MI350P", "MI350X", "MI355X", "MI455X",
        "Ascend 310", "Ascend 910", "Ascend 950PR", "Ascend 950DT",
    )},
    **{name: "编译器/软件管理 local store + 显式搬运" for name in (
        "TPU v4", "TPU v5p", "TPU v6e", "TPU7x",
        "Inferentia1", "Inferentia2", "Trainium1", "Trainium2", "Trainium3",
    )},
    **{name: "local store 存在，管理语义未公开" for name in (
        "TPU v5e", "TPU 8t", "TPU 8i",
    )},
    "GroqChip": "静态编译路由的共享 SRAM/stream",
    "Atlas A2 32": "证据不足",
    "Atlas A2 64": "证据不足",
    "MLU590": "证据不足",
}

DATA_MOVEMENT_CLASS = {
    **{name: "Hopper TMA 异步 tensor 搬运" for name in (
        "H100 SXM", "H100 PCIe", "H100 NVL", "H200 SXM", "H200 NVL",
    )},
    **{name: "软件/编译器控制 HBM-local DMA" for name in (
        "TPU v4", "TPU v5p", "TPU7x", "Inferentia2", "Trainium1", "Trainium2", "Trainium3",
    )},
    **{name: "Ascend MTE/local 显式搬运" for name in (
        "Ascend 310", "Ascend 910", "Ascend 950PR", "Ascend 950DT",
    )},
    "TPU 8t": "Memory and DMA Interconnect；管理/带宽未公开",
    "TPU 8i": "Memory and DMA Interconnect；管理/带宽未公开",
    "GroqChip": "静态编译 streaming",
    "MI455X": "TDM 数据搬运单元",
    "MLU590": "证据不足",
}
DMA_BANDWIDTH_TBPS = {
    "Inferentia2": 1.0,
    "Trainium1": 1.0,
    "Trainium2": 3.5,
    "Trainium3": 4.9,
}

# Strict device endpoint injection ratios use a per-direction value.  Public
# bidirectional aggregates are halved only where the source identifies a
# symmetric full-duplex endpoint.  Bridge, raw-pin and EAM aggregates are kept
# in the raw endpoint table but excluded from this derived metric.
STRICT_DEVICE_ENDPOINT_PER_DIRECTION_TBPS = {
    "A100": 0.300,
    "H100 SXM": 0.450,
    "B200": 0.900,
    "B300": 0.900,
    "MI355X": 0.5376,
}


def r(
    vendor, product, short, position, official_positioning, deployment,
    core_family, execution, compute_units, onchip_storage, precision, special,
    die_package, process, form_factor, memory_domain, memory_type,
    memory_capacity, memory_capacity_unit, memory_bw, memory_bw_unit,
    bf16_dense, bf16_status, low_precision_peak, low_precision_format,
    power, power_basis, device_link, device_link_tbps, scaleup_domain,
    scaleup_topology, collective_hw, source_card, reuse_family="", reuse_scope="",
):
    return dict(
        vendor=vendor, product=product, short=short, position_group=position,
        official_positioning=official_positioning, deployment=deployment,
        core_family=core_family, execution_model=execution,
        compute_units=compute_units, onchip_storage=onchip_storage,
        precision_path=precision, sparsity_and_special_units=special,
        die_and_package=die_package, process_and_scale=process,
        form_factor=form_factor, memory_domain=memory_domain,
        memory_type=memory_type, memory_capacity_value=memory_capacity,
        memory_capacity_unit=memory_capacity_unit,
        memory_bandwidth_value=memory_bw, memory_bandwidth_unit=memory_bw_unit,
        advertised_bf16_fp16_peak_tflops=bf16_dense,
        bf16_fp16_peak_condition=bf16_status,
        low_precision_peak=low_precision_peak,
        low_precision_format=low_precision_format,
        power_w=power, power_basis=power_basis,
        device_interconnect=device_link,
        device_link_nominal_tbps=device_link_tbps,
        max_scaleup_domain=scaleup_domain,
        scaleup_topology=scaleup_topology,
        collective_hardware=collective_hw,
        source_card=source_card, reuse_family=reuse_family,
        reuse_scope=reuse_scope,
    )


ROWS = [
    r("NVIDIA", "A100 SXM4 80GB", "A100", UNIFIED,
      "AI training、inference、data analytics、HPC", "高密度数据中心模组",
      "Ampere SM / 第三代 Tensor Core", "warp/SIMT",
      "108 SM；432 Tensor Core", "40MB L2；SM 内 register/L1/shared memory",
      "BF16/FP16/TF32/FP64/INT8/INT4；产品卡未单列累加语义",
      "2:4 structured sparsity；MIG", "单片 GA100 + HBM2e，SXM4",
      "TSMC N7；826mm²；54.2B transistor", "SXM4 模组",
      "外部DRAM", "HBM2e", 80, "GB", 2.039, "TB/s", 312, "可比",
      1248, "INT4 dense TOPS", 400, "最大 TDP；CTS 另有 500W",
      "12-link NVLink，600GB/s", 0.600, 8, "明确的 8-GPU DGX/NVSwitch 域；另有 16-GPU partner system，但单一 NVSwitch 域未确认",
      "单模组未找到独立 collective engine；NVSwitch/软件位于系统层", "资料卡/NVIDIA/产品/NVIDIA_A100_SXM4_80GB_资料卡.md"),
    r("NVIDIA", "H100 SXM5 80GB", "H100 SXM", UNIFIED,
      "数据中心 AI/HPC；training 与 inference", "高密度数据中心模组",
      "Hopper SM / 第四代 Tensor Core", "warp/SIMT + Thread Block Cluster",
      "132 SM；528 Tensor Core", "50MB L2；每 SM 256KB L1/shared memory",
      "FP8/FP16/BF16/TF32/FP64/INT8；FP8 可 FP16/FP32 累加",
      "2:4 structured sparsity；TMA、DSMEM、DPX", "单片 GH100 + 5-stack HBM3，SXM5",
      "TSMC 4N；814mm²；80B transistor", "SXM5 模组",
      "外部DRAM", "HBM3", 80, "GB", 3.35, "TB/s", 989.4, "可比",
      1978.9, "FP8 dense TFLOPS", 700, "最高可配置功耗",
      "18-link NVLink，900GB/s", 0.900, 8, "HGX 8-GPU NVSwitch 域",
      "SHARP 位于外部 NVSwitch", "资料卡/NVIDIA/产品/NVIDIA_H100_SXM5_80GB_资料卡.md",
      "GH100 / Hopper", "同 die"),
    r("NVIDIA", "H100 PCIe 80GB", "H100 PCIe", UNIFIED,
      "AI、data analytics 与 HPC；非排他", "标准 PCIe 卡",
      "Hopper SM / 第四代 Tensor Core", "warp/SIMT + Thread Block Cluster",
      "114 SM；456 Tensor Core", "50MB L2；每 SM 256KB L1/shared memory",
      "FP8/FP16/BF16/TF32/FP64/INT8；FP8 可 FP16/FP32 累加",
      "2:4 structured sparsity；TMA、DSMEM、DPX", "单片 GH100 + HBM2e，PCIe 卡",
      "TSMC 4N；814mm²；80B transistor", "双槽 FHFL PCIe",
      "外部DRAM", "HBM2e", 80, "GB", 2.0, "TB/s", 756, "可比",
      1513, "FP8 dense TFLOPS", 350, "maximum board power",
      "三块 NVLink bridge，600GB/s", 0.600, 2, "相邻双卡 bridge",
      "未找到卡内独立 collective engine", "资料卡/NVIDIA/产品/NVIDIA_H100_PCIe_80GB_资料卡.md",
      "GH100 / Hopper", "同 die"),
    r("NVIDIA", "H100 NVL 94GB", "H100 NVL", INFER,
      "LLM inference 优化，同时覆盖 AI/HPC", "标准 PCIe 卡",
      "Hopper SM / 第四代 Tensor Core", "warp/SIMT + Thread Block Cluster",
      "实际 SM/Tensor Core 数未公开", "Hopper SM 本地存储组织；实际 L2 未公开",
      "FP8/FP16/BF16/TF32/FP64/INT8；公开 BF16/FP16 与 FP8 headline 为 with sparsity，dense 值未公开",
      "2:4 structured sparsity；TMA、DSMEM、DPX", "单片 GH100 + 94GB HBM3，PCIe 卡",
      "TSMC 4N；814mm²；80B transistor", "双槽 FHFL PCIe",
      "外部DRAM", "HBM3", 94, "GB", 3.938, "TB/s", 1671, "条件不完整",
      3341, "FP8 headline TFLOPS", 400, "default/maximum；可降至 310W",
      "双卡 NVLink bridge，600GB/s", 0.600, 2, "相邻双卡 bridge",
      "未找到卡内独立 collective engine", "资料卡/NVIDIA/产品/NVIDIA_H100_NVL_94GB_资料卡.md",
      "GH100 / Hopper", "同 die"),
    r("NVIDIA", "L4 24GB", "L4", INFER,
      "cloud/edge inference、媒体、图形；也覆盖部分 training", "低功耗 PCIe 卡",
      "Ada SM / 第四代 Tensor Core", "warp/SIMT",
      "58 SM；232 Tensor Core", "49,152KB L2（48MiB）；每 SM 128KB L1/shared memory",
      "FP8/FP16/BF16/TF32/INT8/INT4；BF16 使用 FP32 accumulator",
      "2:4 structured sparsity；媒体编解码", "单片 AD104 + 板上 GDDR6",
      "TSMC 4N", "单槽 low-profile PCIe",
      "外部DRAM", "GDDR6", 24, "GB", 0.300, "TB/s", 121, "可比",
      242, "FP8 dense TFLOPS", 72, "default/maximum board power",
      "无专用 GPU-to-GPU 端点", 0.0, 1, "仅单卡；无专用 scale-up",
      "未找到", "资料卡/NVIDIA/产品/NVIDIA_L4_24GB_资料卡.md",
      "Ada SM", "同 Core 家族"),
    r("NVIDIA", "L40S 48GB", "L40S", UNIFIED,
      "generative AI training/inference、图形、媒体", "标准 PCIe 卡",
      "Ada SM / 第四代 Tensor Core", "warp/SIMT",
      "142 SM；568 Tensor Core", "每 SM 128KB L1/shared memory；L40S 实际 L2 未直接公开",
      "FP8/FP16/BF16/TF32/INT8/INT4",
      "2:4 structured sparsity；媒体/RT 单元", "单片 AD102 + 板上 GDDR6",
      "TSMC 4N；608.5mm²；76.3B transistor", "双槽 FHFL PCIe",
      "外部DRAM", "GDDR6", 48, "GB", 0.864, "TB/s", 362.05, "可比",
      733, "FP8 dense TFLOPS", 350, "default/maximum board power",
      "无专用 GPU-to-GPU 端点", 0.0, 1, "仅单卡；无专用 scale-up",
      "未找到", "资料卡/NVIDIA/产品/NVIDIA_L40S_48GB_资料卡.md",
      "Ada SM", "同 Core 家族"),
    r("NVIDIA", "H200 SXM5 141GB", "H200 SXM", UNIFIED,
      "generative AI 与 HPC；LLM training/inference", "高密度数据中心模组",
      "Hopper SM / 第四代 Tensor Core", "warp/SIMT + Thread Block Cluster",
      "132 SM；528 Tensor Core（由官方结构复算）", "50MB L2；每 SM 256KB L1/shared memory",
      "FP8/FP16/BF16/TF32/FP64/INT8；公开 BF16/FP16 与 FP8 headline 为 with sparsity，dense 值未公开",
      "2:4 structured sparsity；TMA、DSMEM、DPX", "单片 GH100 + 141GB HBM3e，SXM5",
      "TSMC 4N；814mm²；80B transistor", "SXM5 模组",
      "外部DRAM", "HBM3e", 141, "GB", 4.8, "TB/s", 1979, "条件不完整",
      3958, "FP8 headline TFLOPS", 700, "up to；configurable",
      "NVLink，900GB/s", 0.900, 8, "HGX 8-GPU NVSwitch 域",
      "SHARP 位于外部 NVSwitch", "资料卡/NVIDIA/产品/NVIDIA_H200_SXM5_141GB_资料卡.md",
      "GH100 / Hopper", "同 die"),
    r("NVIDIA", "H200 NVL 141GB", "H200 NVL", INFER,
      "enterprise inference、AI/HPC", "标准 PCIe 卡",
      "Hopper SM / 第四代 Tensor Core", "warp/SIMT + Thread Block Cluster",
      "实际 SM/Tensor Core 数未公开", "Hopper SM 本地存储组织；实际 L2 未公开",
      "FP8/FP16/BF16/TF32/FP64/INT8；公开 BF16/FP16 与 FP8 headline 为 with sparsity，dense 值未公开",
      "2:4 structured sparsity；TMA、DSMEM、DPX", "单片 GH100 + 141GB HBM3e，PCIe 卡",
      "TSMC 4N；814mm²；80B transistor", "双槽 PCIe",
      "外部DRAM", "HBM3e", 141, "GB", 4.813, "TB/s", 1671, "条件不完整",
      3341, "FP8 headline TFLOPS", 600, "maximum/default",
      "NVLink bridge，900GB/s per GPU", 0.900, 4, "最多四卡 bridge",
      "未找到卡内独立 collective engine", "资料卡/NVIDIA/产品/NVIDIA_H200_NVL_141GB_资料卡.md",
      "GH100 / Hopper", "同 die"),
    r("NVIDIA", "B200 SXM6 180GB", "B200", UNIFIED,
      "AI training/inference 与 HPC", "高密度数据中心模组",
      "Blackwell SM / 第五代 Tensor Core", "warp/SIMT；双 die coherent GPU",
      "148 SM；Tensor Core 实际数未公开", "L2 容量未公开；SM 内 TMEM/shared/register",
      "NVFP4/FP8/FP6/FP16/BF16/TF32/FP64/INT8",
      "structured sparsity；Transformer Engine", "双 compute die + NV-HBI + HBM3e",
      "TSMC 4NP；208B transistor（双 die GPU）", "SXM6 模组",
      "外部DRAM", "HBM3e", 180, "GB", 7.7, "TB/s", 2200, "可比",
      9000, "NVFP4 dense TFLOPS", 1000, "configurable up to",
      "第五代 NVLink，1.8TB/s", 1.800, 8, "HGX 8-GPU NVSwitch 域",
      "系统侧 NVSwitch", "资料卡/NVIDIA/产品/NVIDIA_B200_SXM6_180GB_资料卡.md"),
    r("NVIDIA", "B300 SXM6 288GB", "B300", UNIFIED,
      "training 与 test-time-scaling inference", "高密度数据中心模组",
      "Blackwell Ultra SM / 第五代 Tensor Core", "warp/SIMT；双 die coherent GPU",
      "实际 SM/Core 数未公开", "每 SM 256KB TMEM；coherent L2 容量未公开",
      "FP4/FP8/FP6/FP16/BF16/TF32/FP64/INT8",
      "structured sparsity；指数函数/softmax 路径增强", "双 compute die + NV-HBI + HBM3e",
      "TSMC 4NP；208B transistor（双 die GPU）", "SXM6 模组",
      "外部DRAM", "HBM3e", 288, "GB", 8.0, "TB/s", 2200, "可比",
      14000, "FP4 dense TFLOPS", 1100, "TDP",
      "第五代 NVLink，1.8TB/s", 1.800, 8, "HGX 8-GPU NVSwitch 域",
      "系统侧 NVSwitch", "资料卡/NVIDIA/产品/NVIDIA_B300_SXM6_288GB_资料卡.md"),

    r("Google", "TPU v4 one chip", "TPU v4", TRAIN,
      "大规模训练主定位", "云内芯片",
      "TensorCore + SparseCore", "VLIW/control + systolic MXU",
      "2 TensorCore；8×128² MXU；4 SparseCore；每 TensorCore 有 128-lane VPU 与 scalar unit", "128MiB CMEM；32MiB VMEM；10MiB SpMEM；每 TensorCore 0.25MiB register file",
      "BF16 或 INT8 headline；MXU 为 BF16 输入、FP32 累加",
      "SparseCore：embedding/稀疏与部分 collective", "单 ASIC + HBM2",
      "7nm；die <600mm²；22B transistor", "Cloud TPU 芯片",
      "外部DRAM", "HBM2", 32, "GiB", 1.2, "TB/s", 275, "精度二选一标签",
      275, "BF16 或 INT8 headline", 170, "fleet production mean；非 TDP",
      "6 条 ICI，每条 50GB/s；方向口径未公开，不能合并成双向值", None, 4096, "3D mesh/torus + OCS；4096-chip Pod",
      "SparseCore 可卸载部分 collective", "资料卡/Google-TPU/产品/Google_Cloud_TPU_v4_one_chip_资料卡.md"),
    r("Google", "TPU v5e one chip", "TPU v5e", UNIFIED,
      "training 与 inference", "云内芯片",
      "TPU TensorCore", "systolic MXU + vector/scalar",
      "1 TensorCore；4×128² MXU", "片上存储容量未公开",
      "BF16 multiply + FP32 accumulation；INT8 路径",
      "未找到该 SKU 的 SparseCore", "单 ASIC；物理封装未公开",
      "未公开", "Cloud TPU 芯片",
      "外部DRAM", "HBM/HBM2E", 16, "GB/GiB", 0.858993, "TB/s（原始资料为 800 GiB/s；论文另有 819 GB/s）", 197, "可比",
      393, "INT8 TOPS", 66, "fleet average；非 TDP",
      "4-port ICI，400GB/s", 0.400, 256, "2D torus；256-chip Pod",
      "未公开独立 engine", "资料卡/Google-TPU/产品/Google_Cloud_TPU_v5e_one_chip_资料卡.md"),
    r("Google", "TPU v5p one chip", "TPU v5p", TRAIN,
      "训练强调，兼顾 serving", "云内芯片",
      "TensorCore + SparseCore", "VLIW/control + systolic MXU",
      "2 TensorCore；8×128² MXU；4 SparseCore", "128MiB VMEM；每 SparseCore 2.5MiB SpMEM",
      "BF16 multiply + FP32 accumulation；FP8/BF8 路径",
      "SparseCore：embedding、Top-K、部分 collective", "compute die/chiplet 边界未公开；package 周围 6 个 HBM stack，采用液冷；interposer/基板未公开",
      "未公开", "Cloud TPU 芯片",
      "外部DRAM", "HBM2E", 95, "GiB", 2.765, "TB/s", 459, "可比",
      459, "FP8/BF8 TFLOPS", 331, "fleet average；非 TDP",
      "6-link ICI，1.2TB/s", 1.200, 6144, "3D torus；物理 Pod 8960 chip，单 workload 最大 slice 6144 chip",
      "SparseCore 可卸载部分 collective", "资料卡/Google-TPU/产品/Google_Cloud_TPU_v5p_one_chip_资料卡.md"),
    r("Google", "TPU v6e one chip", "TPU v6e", UNIFIED,
      "training、fine-tuning、serving", "云内芯片",
      "TensorCore + SparseCore", "systolic MXU + vector/scalar",
      "1 TensorCore；2×256² MXU；2 SparseCore", "VMEM/SPMEM 存在，容量未公开",
      "BF16 multiply + FP32 accumulation；FP8/INT8 路径",
      "第三代 SparseCore：embedding/不规则访问", "单 ASIC；物理封装未公开",
      "未公开", "Cloud TPU 芯片",
      "外部DRAM", "HBM", 32, "GB/GiB", 1.638, "TB/s", 918, "可比",
      1836, "INT8 TOPS", 153, "fleet average；非 TDP",
      "4-port ICI，800GB/s", 0.800, 256, "2D torus；256-chip Pod",
      "未找到 v6e 单芯片专用 collective engine 或硬件 offload 吞吐", "资料卡/Google-TPU/产品/Google_Cloud_TPU_v6e_one_chip_资料卡.md"),
    r("Google", "TPU7x one chip", "TPU7x", UNIFIED,
      "首发 inference，当前覆盖 training 与 inference", "云内芯片",
      "TensorCore + 第四代 SparseCore", "systolic MXU + vector/scalar",
      "2 TensorCore；4 MXU；4 SparseCore", "128MiB VMEM（两 TensorCore 各 64MiB view）",
      "BF16 multiply + FP32 accumulation；FP8 路径",
      "SparseCore：embedding、排序/过滤、collective", "2 compute chiplet + SerDes chiplet + HBM3E",
      "未公开", "Cloud TPU 芯片",
      "外部DRAM", "HBM3E", 192, "GiB", 7.38, "TB/s", 2307, "可比",
      4614, "FP8 TFLOPS", None, "未公开",
      "6-link ICI，1.2TB/s", 1.200, 9216, "3D mesh/torus；9216-chip Pod",
      "SparseCore 可卸载 collective", "资料卡/Google-TPU/产品/Google_Cloud_TPU7x_one_chip_资料卡.md"),
    r("Google", "TPU 8t one chip", "TPU 8t", TRAIN,
      "pre-training", "云内芯片",
      "TensorCore + SparseCore + LLM Decoder Engine", "systolic MXU + VPU/XLU overlap",
      "公开图示 1 TensorCore block；2 SparseCore；完整使能数未公开", "128MB Vmem",
      "原生 FP4；乘积/累加/缩放细节未公开",
      "SparseCore；LLM Decoder Engine（内部未公开）", "logic chiplet + 独立 ICI/SerDes chiplet + HBM3E",
      "未公开", "Cloud TPU 芯片",
      "外部DRAM", "HBM3E", 216, "GB", 6.528, "TB/s", None, "未公开 BF16/FP16",
      12600, "FP4 TFLOPS", None, "未公开",
      "独立 ICI/SerDes chiplet；绝对带宽未公开", None, 9600, "3D torus；9600-chip Superpod",
      "SparseCore 卸载 data-dependent all-gather", "资料卡/Google-TPU/产品/Google_TPU_8t_one_chip_资料卡.md"),
    r("Google", "TPU 8i one chip", "TPU 8i", INFER,
      "post-training、serving、inference", "云内芯片",
      "TensorCore + CAE", "systolic MXU；片内 reduction/synchronization",
      "2 TensorCore（每个含 2 MXU、2 XLU、VPU+Vmem 与 TCS）；1 CAE", "384MB Vmem",
      "FP4；乘积/累加/缩放细节未公开",
      "CAE 替代公开框图中的 SparseCore", "2 on-core die + CAE/ICI chiplet + HBM3E",
      "未公开", "Cloud TPU 芯片",
      "外部DRAM", "HBM3E", 288, "GB", 8.601, "TB/s", None, "未公开 BF16/FP16",
      10100, "FP4 TFLOPS", None, "未公开",
      "ICI 19.2Tb/s bidirectional", 2.400, 1024, "Boardfly + OCS；1024 active chips",
      "CAE 只负责芯片内两个 TensorCore 间 reduction/synchronization；未找到跨设备 collective engine", "资料卡/Google-TPU/产品/Google_TPU_8i_one_chip_资料卡.md"),

    r("AWS", "Inferentia1 one chip", "Inferentia1", INFER,
      "inference", "云内芯片",
      "NeuronCore-v1", "systolic TensorEngine + SIMD/vector",
      "4 NeuronCore-v1", "software-managed SBUF/PSUM；容量未公开",
      "FP16/BF16→FP32；INT8→INT32",
      "未找到结构化稀疏或独立 collective engine", "chip/package 物理实现未公开",
      "未公开", "Cloud accelerator chip",
      "外部DRAM", "DDR4", 8, "GB/GiB", 0.053687, "TB/s（原始资料为 50 GiB/s）", 64, "可比",
      128, "INT8 TOPS", None, "未公开",
      "NeuronLink-v1，32GiB/s/chip；方向未公开", None, 16, "最多 16-chip instance",
      "未找到独立 engine", "资料卡/AWS/产品/AWS_Inferentia1_one_chip_资料卡.md"),
    r("AWS", "Inferentia2 one chip", "Inferentia2", INFER,
      "generative AI inference", "云内芯片",
      "NeuronCore-v2", "systolic TensorEngine + vector/scalar/GpSimd",
      "2 NCv2；32 DMA；6 CC-Core", "每核 24MiB SBUF + 2MiB PSUM；8×64KB GpSimd local RAM",
      "cFP8/FP16/BF16/TF32/FP32/INT8；matrix 固定 FP32 accumulate",
      "无已知 structured sparsity；6 CC-Core", "官方 device 逻辑图显示 2 HBM stack；单裸片/chiplet、interposer、基板与物理 package 未公开",
      "advanced process（节点未公开）", "Cloud accelerator chip",
      "外部DRAM", "HBM", 32, "GB/GiB", 0.820, "TB/s（官方并存 820 GB/s 与 820 GiB/s）", 190, "可比",
      380, "INT8 TOPS", None, "未公开",
      "2×NeuronLink-v2；192GiB/s/chip；方向未公开", None, 12, "12-chip instance",
      "6 CC-Core；AllReduce/AllGather", "资料卡/AWS/产品/AWS_Inferentia2_one_chip_资料卡.md",
      "NeuronCore-v2", "同 Core 与芯片资源组织"),
    r("AWS", "Trainium1 one chip", "Trainium1", TRAIN,
      "deep-learning training", "云内芯片",
      "NeuronCore-v2", "systolic TensorEngine + vector/scalar/GpSimd",
      "2 NCv2；32 DMA；6 CC-Core", "每核 24MiB SBUF + 2MiB PSUM；8×64KB GpSimd local RAM",
      "cFP8/FP16/BF16/TF32/FP32/INT8；matrix 固定 FP32 accumulate",
      "无已知 structured sparsity；6 CC-Core", "官方 device 逻辑图显示 2 HBM stack；单裸片/chiplet、interposer、基板与物理 package 未公开",
      "未公开", "Cloud accelerator chip",
      "外部DRAM", "HBM", 32, "GB/GiB", 0.820, "TB/s（官方并存 820 GB/s 与 820 GiB/s）", 190, "可比",
      380, "INT8 TOPS", None, "未公开",
      "4×NeuronLink-v2；最高 768GB/s；方向未公开", None, 16, "16-chip 2D torus + EFA",
      "6 CC-Core；collective", "资料卡/AWS/产品/AWS_Trainium1_one_chip_资料卡.md",
      "NeuronCore-v2", "同 Core 与芯片资源组织"),
    r("AWS", "Trainium2 one chip", "Trainium2", UNIFIED,
      "generative AI training 与 inference", "云内芯片",
      "NeuronCore-v3", "128² systolic TensorEngine + vector/scalar/GPSIMD",
      "8 NCv3；128 DMA；CC-Core 数存在版本差异", "224MiB SBUF/chip；每核另 2MiB PSUM",
      "FP8/BF16/FP16/TF32/FP32；PSUM 目标 FP32",
      "多种 M:N structured sparsity；CC-Core", "官方 device 逻辑图显示 4 HBM stack；单裸片/chiplet、interposer、基板与物理 package 未公开",
      "未公开", "Cloud accelerator chip",
      "外部DRAM", "HBM", 96, "GB/GiB", 2.9, "TB/s", 667, "可比",
      1299, "FP8 dense TFLOPS", None, "未公开",
      "4×NeuronLink-v3，1.28TB/s；方向未公开", None, 64, "16-chip torus；64-chip UltraServer",
      "CC-Core；collective", "资料卡/AWS/产品/AWS_Trainium2_one_chip_资料卡.md"),
    r("AWS", "Trainium3 one chip", "Trainium3", UNIFIED,
      "frontier model training 与 serving", "云内芯片",
      "NeuronCore-v4", "128² systolic TensorEngine + vector/scalar/GPSIMD",
      "8 NCv4；128 DMA；CC-Core 数存在版本差异", "256MiB SBUF/chip；每核另 2MiB PSUM",
      "MXFP4/MXFP8/BF16/FP16/TF32/FP32",
      "structured sparsity；fast exponential；CC-Core", "官方 device 逻辑图显示 4 HBM3e stack；单裸片/chiplet、interposer、基板与物理 package 未公开",
      "3nm；其余物理信息未公开", "Cloud accelerator chip",
      "外部DRAM", "HBM3e", 144, "GB/GiB", 4.9, "TB/s（官方另有 4.7）", 671, "可比",
      2517, "MXFP4/MXFP8 TFLOPS", None, "未公开",
      "4×NeuronLink-v4，2.56TB/s；方向未公开", None, 144, "64/144-chip all-to-all UltraServer",
      "CC-Core；NeuronSwitch 系统 fabric", "资料卡/AWS/产品/AWS_Trainium3_one_chip_资料卡.md"),

    r("AMD", "Instinct MI300X 192GB", "MI300X", UNIFIED,
      "generative AI/HPC；training 与 inference", "高密度数据中心模组",
      "CDNA 3 Compute Unit", "SIMD/SIMT wavefront；matrix/vector/scalar",
      "304 CU；1216 Matrix Core", "256MB Infinity Cache；每 XCD 4MB L2",
      "FP8/FP16/BF16/TF32/FP32/FP64/INT8",
      "4:2 structured sparsity；硬件分区", "8 XCD + 4 IOD + 8 HBM3 stack；3D package",
      "TSMC 5nm XCD + 6nm IOD；153B transistor", "OAM 模组",
      "外部DRAM", "HBM3", 192, "GB", 5.3, "TB/s", 1300, "可比",
      2610, "FP8 dense TFLOPS", 750, "peak TBP",
      "7×Infinity Fabric，0.896TB/s aggregate", 0.896, 8, "8-OAM fully connected",
      "未找到独立 collective engine", "资料卡/AMD/产品/AMD_Instinct_MI300X_192GB_资料卡.md"),
    r("AMD", "Instinct MI325X 256GB", "MI325X", UNIFIED,
      "AI training、inference 与 HPC", "高密度数据中心模组",
      "CDNA 3 Compute Unit", "SIMD/SIMT wavefront；matrix/vector/scalar",
      "304 CU；1216 Matrix Core", "256MB Infinity Cache；每 XCD 4MB L2",
      "FP8/FP16/BF16/TF32/FP32/FP64/INT8",
      "4:2 structured sparsity；硬件分区", "8 XCD + 4 IOD + 8 HBM3E stack；3D package",
      "TSMC 5nm XCD + 6nm IOD；153B transistor", "OAM 模组",
      "外部DRAM", "HBM3E", 256, "GB", 6.0, "TB/s", 1307.4, "可比",
      2614.9, "FP8 dense TFLOPS", 1000, "maximum TBP",
      "7×Infinity Fabric，0.896TB/s aggregate", 0.896, 8, "8-OAM fully connected",
      "未找到独立 collective engine", "资料卡/AMD/产品/AMD_Instinct_MI325X_256GB_资料卡.md"),
    r("AMD", "Instinct MI350P 144GB", "MI350P", INFER,
      "generative/agentic AI inference 与 RAG", "标准 PCIe 卡",
      "CDNA 4 Compute Unit", "SIMD/SIMT wavefront；matrix/vector/scalar",
      "128 CU；512 Matrix Core", "128MB Infinity Cache；每 XCD 4MB L2",
      "MXFP4/6/8、OCP-FP8、FP16/BF16、FP32/FP64、INT8",
      "2:4 structured sparsity；硬件分区", "4 XCD + 1 IOD；HBM3E 容量已知，HBM stack 与物理 package 细节未公开",
      "TSMC 3nm/6nm；73B transistor", "双槽 PCIe",
      "外部DRAM", "HBM3E", 144, "GB", 4.0, "TB/s", 1150, "可比",
      4600, "MXFP4 dense TFLOPS", 600, "maximum TBP；可配 450W",
      "无专用卡间 scale-up；仅 PCIe", 0.0, 1, "标准服务器最多八卡，但无公开直连域",
      "未找到", "资料卡/AMD/产品/AMD_Instinct_MI350P_PCIe_卡资料卡.md",
      "CDNA 4 CU", "同一公开 CU 架构"),
    r("AMD", "Instinct MI350X 288GB", "MI350X", UNIFIED,
      "generative AI、inference、training 与 HPC", "高密度数据中心模组",
      "CDNA 4 Compute Unit", "SIMD/SIMT wavefront；matrix/vector/scalar",
      "256 CU；1024 Matrix Core", "256MB Infinity Cache；每 XCD 4MB L2",
      "MXFP4/6/8、OCP-FP8、FP16/BF16、FP32/FP64、INT8",
      "2:4 structured sparsity；硬件分区", "8 XCD + 2 IOD + 8×12-Hi HBM3E",
      "TSMC N3P XCD + N6 IOD；185B transistor", "OAM 模组",
      "外部DRAM", "HBM3E", 288, "GB", 8.0, "TB/s", 2309.6, "可比",
      9227.5, "MXFP4 dense TFLOPS", 1000, "TBP",
      "7×Infinity Fabric，1.0752TB/s aggregate", 1.0752, 8, "8-OAM fully connected",
      "未找到独立 collective engine", "资料卡/AMD/产品/AMD_Instinct_MI350X_288GB_资料卡.md",
      "CDNA 4 CU", "同一公开 CU 架构"),
    r("AMD", "Instinct MI355X 288GB", "MI355X", UNIFIED,
      "高密度 generative AI、inference、training 与 HPC", "高密度数据中心模组",
      "CDNA 4 Compute Unit", "SIMD/SIMT wavefront；matrix/vector/scalar",
      "256 CU；1024 Matrix Core", "256MB Infinity Cache；每 XCD 4MB L2",
      "MXFP4/6/8、OCP-FP8、FP16/BF16、FP32/FP64、INT8",
      "2:4 structured sparsity；硬件分区", "8 XCD + 2 IOD + 8×12-Hi HBM3E",
      "TSMC N3P XCD + N6 IOD；185B transistor", "OAM 模组",
      "外部DRAM", "HBM3E", 288, "GB", 8.0, "TB/s", 2516.6, "可比",
      10066.3, "MXFP4 dense TFLOPS", 1400, "TBP",
      "7×Infinity Fabric，1.0752TB/s aggregate", 1.0752, 8, "8-OAM fully connected",
      "未找到独立 collective engine", "资料卡/AMD/产品/AMD_Instinct_MI355X_288GB_资料卡.md",
      "CDNA 4 CU", "同一公开 CU 架构"),
    r("AMD", "Instinct MI455X", "MI455X", UNIFIED,
      "frontier AI inference、training、fine-tuning", "高密度数据中心模组",
      "CDNA 5 Wave32 WGP", "Wave32；matrix/vector/scalar + Tensor Data Mover",
      "256 WGP", "192MB global L2；每 WGP 320KB LDS",
      "MXFP4/6/8、OCP-FP8、FP16/BF16、FP32/FP64、INT8",
      "structured sparsity；TDM；安全/分区", "8 个 N2 XCD + 2 个节点未公开的 IOD + 2 个 N3P FCD + 12 HBM4；CoWoS-L",
      "XCD 为 TSMC N2，FCD 为 TSMC N3P，IOD 节点未公开；320B transistor 为整个 GPU 产品值", "EAM 液冷模组",
      "外部DRAM", "HBM4", 432, "GB", 23.3, "TB/s", 5033, "可比",
      40265, "MXFP4 dense TFLOPS", None, "未公开",
      "36×UALoE，3.6TB/s scale-up", 3.600, 72, "Helios 72-GPU rack；系统域口径",
      "未找到单 EAM 独立 collective engine", "资料卡/AMD/封装/AMD_Instinct_MI455X_模组资料卡.md"),

    r("Huawei", "Ascend 310 one chip", "Ascend 310", INFER,
      "edge inference SoC", "边缘 SoC",
      "Da Vinci Ascend-Mini AI Core", "Cube/vector/scalar；芯片级调度细节有限",
      "2 AI Core；8 Cortex-A55", "8MB on-chip buffer；3MB LLC",
      "FP16 与 INT8 headline；累加/计数口径未公开",
      "媒体编解码；未找到结构化稀疏/LLM 单元", "单 12nm SoC die；package 未公开",
      "12nm；9.8×10.65mm die", "SoC chip",
      "外部DRAM", "LPDDR4X controller", None, "未公开", None, "未公开", 8, "条件不完整",
      16, "INT8 TOPS", 8, "产品功耗 headline；另写 <8W",
      "无公开 AI scale-up fabric", 0.0, 1, "单芯片；无公开 scale-up",
      "未找到", "资料卡/华为昇腾/产品/华为_Ascend310_one_chip_资料卡.md"),
    r("Huawei", "Ascend 910 one chip", "Ascend 910", TRAIN,
      "AI model training", "高密度数据中心芯片",
      "Da Vinci Ascend-Max AI Core", "Cube/vector/scalar；4×6 mesh NoC",
      "32 AI Core；16 Armv8 CPU", "32MB on-chip buffer；AI/CPU LLC",
      "FP16 与 INT8 headline；累加/计数口径未公开",
      "DVPP；未找到结构化稀疏/LLM 单元", "7+nm compute die + 16nm I/O die + 4 HBM + 2 dummy die",
      "7+nm compute die；16nm I/O die", "processor package",
      "外部DRAM", "HBM2", 32, "GB（官方运行环境佐证）", 1.2, "TB/s", 256, "条件不完整",
      512, "INT8 TOPS", 310, "maximum；另有 300/350W 口径",
      "HCCS 端点存在；单芯片带宽口径不足", None, 4, "server 内四芯片 HCCS group",
      "未找到独立 engine", "资料卡/华为昇腾/产品/华为_Ascend910_one_chip_资料卡.md"),
    r("Huawei", "Atlas 300I A2 32GB", "Atlas A2 32", INFER,
      "data-center inference card", "标准 PCIe 卡",
      "Ascend AI Core（exact submodel 未公开）", "未公开",
      "20 AI Core；8 TaiShan Core", "内部 cache/scratchpad 容量未公开",
      "FP16/FP32/INT8 headline；dense/sparse 与累加未知",
      "媒体单元；inference hard partition", "单 Ascend processor + HBM；物理 die/package 未公开",
      "未公开", "双槽 FHFL PCIe",
      "外部DRAM", "HBM", 32, "GB", 0.8, "TB/s", 280, "条件不完整",
      560, "INT8 TOPS", 350, "maximum；支持 300/350W",
      "仅 PCIe；本卡无 HCCS", 0.0, 1, "单卡；无专用 scale-up",
      "未找到", "资料卡/华为昇腾/产品/华为_Atlas300I_A2_32GB_资料卡.md"),
    r("Huawei", "Atlas 300I A2 64GB", "Atlas A2 64", INFER,
      "data-center inference card", "标准 PCIe 卡",
      "Ascend AI Core（exact submodel 未公开）", "未公开",
      "20 AI Core；8 TaiShan Core", "内部 cache/scratchpad 容量未公开",
      "FP16/FP32/INT8 headline；dense/sparse 与累加未知",
      "媒体单元；inference hard partition", "单 Ascend processor + HBM；物理 die/package 未公开",
      "未公开", "双槽 FHFL PCIe",
      "外部DRAM", "HBM", 64, "GB", 1.6, "TB/s", 280, "条件不完整",
      560, "INT8 TOPS", 350, "maximum；支持 300/350W",
      "仅 PCIe；本卡无 HCCS", 0.0, 1, "单卡；无专用 scale-up",
      "未找到", "资料卡/华为昇腾/产品/华为_Atlas300I_A2_64GB_资料卡.md"),
    r("Huawei", "Ascend 950PR", "Ascend 950PR", INFER,
      "LLM prefill、recommendation inference", "高密度数据中心芯片",
      "Ascend 950 AI Core", "SPMD + SIMD/SIMT mixed programming",
      "AI Core 数未公开", "L1 Buffer、UB；单个 programmable Register 为 256B，层级总容量未公开",
      "FP8/MXFP8/MXFP4/HiF8；1784TFLOPS 标签精度未指明",
      "未找到结构化稀疏/attention/MoE/KV 专用单元", "共享 Ascend 950 die + HiBL 1.0 HBM；可见双 DIE channel",
      "未公开", "processor/package",
      "外部DRAM", "HiBL 1.0 HBM", 128, "GB（最大）", 1.6, "TB/s（最大）", None, "不可比",
      1784, "未指明精度 TFLOPS", None, "未公开",
      "灵衢 2.0，2TB/s bidirectional", 2.0, 4, "Atlas 350 最多四卡互联",
      "未找到 processor-level engine", "资料卡/华为昇腾/封装/华为_Ascend950PR_封装资料卡.md",
      "Ascend 950", "同 die"),
    r("Huawei", "Ascend 950DT", "Ascend 950DT", UNIFIED,
      "inference decode 与 model training", "高密度数据中心芯片",
      "Ascend 950 AI Core", "SPMD + SIMD/SIMT mixed programming",
      "AI Core 数未公开", "L1 Buffer、UB；单个 programmable Register 为 256B，层级总容量未公开",
      "FP8/MXFP8/MXFP4/HiF8；路线图标签条件未完整公开",
      "未找到结构化稀疏/attention/MoE/KV 专用单元", "共享 Ascend 950 die + HiZQ 2.0 HBM；可见双 DIE channel",
      "未公开", "processor/package",
      "外部DRAM", "HiZQ 2.0 HBM", 144, "GB", 4.0, "TB/s", None, "不可比",
      2000, "MXFP4 roadmap TFLOPS", None, "未公开",
      "total interconnect 2TB/s；方向未公开", None, 16, "16-NPU full mesh（跨两 server）",
      "具体 processor-level engine 未公开", "资料卡/华为昇腾/封装/华为_Ascend950DT_封装资料卡.md",
      "Ascend 950", "同 die"),

    r("Groq", "GroqChip Processor 第一代", "GroqChip", INFER,
      "AI inference 主定位", "独立 ASIC",
      "TSP functionally sliced architecture", "compiler 静态、cycle-accurate spatial schedule",
      "4×320² MXM；5120 vector ALU；88 MEM slice；144 个 ICU queue", "230MB globally shared on-die SRAM；80TB/s",
      "INT8→INT32；FP16→FP32；单次最终 rounding",
      "明确不采用 pruning/sparsity；SXM 数据重排", "单 14nm die；package 未公开",
      "14nm；25×29mm；26.8B transistor", "processor chip",
      "片上SRAM", "SRAM", 0.230, "GB", 80.0, "TB/s on-die", 188, "FP16 可用但非外部 DRAM 比较",
      750, "INT8 TOPS @900MHz", 215, "TDP；另有 185W average/300W max",
      "16×RealScale C2C；3.84Tb/s raw bidirectional", 0.480, None, "最大直接域未公开",
      "C2C send/receive；无硬件 reduction engine 证据", "资料卡/Groq/产品/Groq_GroqChip_Processor_第一代_资料卡.md"),
    r("Cambricon", "MLU590", "MLU590", TRAIN,
      "云端智能训练芯片", "云端训练芯片；具体模组和部署形态未公开",
      "MLUarch05", "未公开",
      "未公开", "software target descriptor 中出现 NRAM/WRAM/SRAM 名称；物理作用域与容量未公开",
      "硬件精度与累加路径未公开",
      "未公开", "die/package 未公开",
      "未公开", "chip",
      "未知", "未公开", None, "未公开", None, "未公开", None, "未公开",
      None, "未公开", None, "未公开",
      "未公开", None, None, "未找到专属拓扑/域",
      "仅软件多卡 API；硬件 offload 未公开", "资料卡/寒武纪/产品/寒武纪_思元590_MLU590_资料卡.md"),
]


# Evidence metadata used by charts.  The advertised BF16/FP16 number is kept
# separate from the evidence that it is a dense/base value.
STRICT_DENSE = {
    "A100", "H100 SXM", "H100 PCIe", "L4", "L40S", "B200", "B300",
    "Trainium2", "Trainium3", "MI300X", "MI325X", "MI350P", "MI350X",
    "MI355X", "MI455X",
}
PEAK_CONDITION_PARTIAL = {
    "TPU v5e", "TPU v5p", "TPU v6e", "TPU7x",
    "Inferentia1", "Inferentia2", "Trainium1",
}
WITH_SPARSITY = {"H100 NVL", "H200 SXM", "H200 NVL"}
PEAK_EVIDENCE_CLASS = {
    **{name: "多精度 dense/sparse + 同精度非矩阵直接值或代理" for name in (
        "A100", "H100 SXM", "H100 PCIe", "MI300X", "MI325X", "MI350P",
        "MI350X", "MI355X", "MI455X",
    )},
    **{name: "dense/sparse 明确；无同精度非矩阵路径" for name in (
        "L4", "L40S", "B200", "B300", "Trainium2",
    )},
    **{name: "仅 sparse/with-sparsity headline；缺同表 dense/base" for name in (
        "H100 NVL", "H200 SXM", "H200 NVL", "Trainium3",
    )},
    **{name: "有峰值；dense/sparse、FMA、累加或计数条件不完整" for name in (
        "TPU v4", "TPU v5e", "TPU v5p", "TPU v6e", "TPU7x", "TPU 8t", "TPU 8i",
        "Inferentia1", "Inferentia2", "Trainium1", "Ascend 310", "Ascend 910",
        "Atlas A2 32", "Atlas A2 64",
    )},
    **{name: "没有 per-product 理论峰值" for name in (
        "Ascend 950PR", "Ascend 950DT", "GroqChip", "MLU590",
    )},
}
PEAK_PRECISION_OVERRIDES = {
    "TPU v4": "BF16 或 INT8",
    "Ascend 310": "FP16",
    "Ascend 910": "FP16",
    "Atlas A2 32": "FP16",
    "Atlas A2 64": "FP16",
    "GroqChip": "FP16",
}

# Analysis metadata derived from the completed cards.  These fields are not
# substitutes for the card text: they only provide controlled cuts for the
# report and remain blank where the cards do not support a stable value.
RELEASE_YEAR = {
    "A100": 2020, "H100 SXM": 2022, "H100 PCIe": 2022,
    "H100 NVL": 2023, "L4": 2023, "L40S": 2023,
    "H200 SXM": 2023, "H200 NVL": 2024, "B200": 2024, "B300": 2025,
    "TPU v4": 2021, "TPU v5e": 2023, "TPU v5p": 2023,
    "TPU v6e": 2024, "TPU7x": 2025, "TPU 8t": 2026, "TPU 8i": 2026,
    "Inferentia1": 2018, "Inferentia2": 2022, "Trainium1": 2021,
    "Trainium2": 2023, "Trainium3": 2024,
    "MI300X": 2023, "MI325X": 2024, "MI350P": 2025,
    "MI350X": 2025, "MI355X": 2025, "MI455X": 2026,
    "Ascend 310": 2018, "Ascend 910": 2019,
    "Ascend 950PR": 2025, "Ascend 950DT": 2025,
    "GroqChip": 2020, "MLU590": 2022,
}

CORE_ANALYSIS_FAMILY = {
    "A100": "Ampere SM",
    "H100 SXM": "Hopper SM / GH100", "H100 PCIe": "Hopper SM / GH100",
    "H100 NVL": "Hopper SM / GH100", "H200 SXM": "Hopper SM / GH100",
    "H200 NVL": "Hopper SM / GH100",
    "L4": "Ada SM", "L40S": "Ada SM",
    "B200": "Blackwell SM", "B300": "Blackwell Ultra SM",
    "TPU v4": "TPU v4 TensorCore", "TPU v5e": "TPU v5e TensorCore",
    "TPU v5p": "TPU v5p TensorCore", "TPU v6e": "TPU v6e TensorCore",
    "TPU7x": "TPU7x TensorCore", "TPU 8t": "TPU 8t TensorCore",
    "TPU 8i": "TPU 8i TensorCore + CAE",
    "Inferentia1": "NeuronCore-v1", "Inferentia2": "NeuronCore-v2",
    "Trainium1": "NeuronCore-v2", "Trainium2": "NeuronCore-v3",
    "Trainium3": "NeuronCore-v4",
    "MI300X": "CDNA 3 CU", "MI325X": "CDNA 3 CU",
    "MI350P": "CDNA 4 CU", "MI350X": "CDNA 4 CU", "MI355X": "CDNA 4 CU",
    "MI455X": "CDNA Next CU",
    "Ascend 310": "Ascend-Mini AI Core", "Ascend 910": "Ascend-Max AI Core",
    "Atlas A2 32": "Ascend AI Core（子型号未公开）",
    "Atlas A2 64": "Ascend AI Core（子型号未公开）",
    "Ascend 950PR": "Ascend 950 AI Core", "Ascend 950DT": "Ascend 950 AI Core",
    "GroqChip": "Groq TSP/LPU", "MLU590": "MLUarch05（Core 未公开）",
}

CORE_RELATION_LEVEL = {
    "Hopper SM / GH100": "相同 die 与 Core 已确认",
    "NeuronCore-v2": "相同 Core 与芯片资源组织",
    "Ascend 950 AI Core": "相同 die 与 Core 已确认",
    "CDNA 4 CU": "同一公开 Core 架构",
    "Ada SM": "同一公开 Core 架构",
}

PAIR_GROUP = {
    "TPU v5e": "TPU v5p / v5e", "TPU v5p": "TPU v5p / v5e",
    "TPU 8t": "TPU 8t / 8i", "TPU 8i": "TPU 8t / 8i",
    "Inferentia2": "Trainium1 / Inferentia2", "Trainium1": "Trainium1 / Inferentia2",
    "H100 SXM": "H100 SXM / NVL", "H100 NVL": "H100 SXM / NVL",
    "H200 SXM": "H200 SXM / NVL", "H200 NVL": "H200 SXM / NVL",
    "MI350P": "MI350P / MI350X", "MI350X": "MI350P / MI350X",
    "Ascend 950PR": "Ascend 950PR / 950DT", "Ascend 950DT": "Ascend 950PR / 950DT",
}

SINGLE_LOGIC_COMPUTE_DIE = {
    "A100", "H100 SXM", "H100 PCIe", "H100 NVL", "L4", "L40S",
    "H200 SXM", "H200 NVL", "TPU v4", "Ascend 310", "GroqChip",
}
SINGLE_COMPUTE_WITH_AUX_DIE = {"TPU 8t", "Ascend 910"}
MULTI_COMPUTE_DIE = {
    "B200", "B300", "TPU7x", "TPU 8i", "MI300X", "MI325X", "MI350P",
    "MI350X", "MI355X", "MI455X",
}
D2D_PRESENT_CONFIRMED = MULTI_COMPUTE_DIE | SINGLE_COMPUTE_WITH_AUX_DIE | {"Ascend 950PR", "Ascend 950DT"}

NOC_EVIDENCE_DETAIL = {
    **{name: "层次/连接事实；无可比 NoC 数值" for name in (
        "H100 SXM", "H100 PCIe", "H100 NVL", "H200 SXM", "H200 NVL",
        "L40S", "TPU v5p", "TPU 8t", "TPU 8i",
    )},
    "Ascend 310": "只公开互联宽度",
    "Ascend 910": "公开拓扑与局部/聚合带宽数值",
    "GroqChip": "公开 stream-register 拓扑与示例/产品聚合值",
}

MEMORY_STACK_COUNT = {
    "H100 SXM": "5", "H100 PCIe": "5", "TPU v4": "4", "TPU v5p": "6",
    "TPU7x": "8", "TPU 8t": "6", "TPU 8i": "8", "Inferentia2": "2",
    "Trainium1": "2", "Trainium2": "4", "Trainium3": "4", "MI300X": "8",
    "MI325X": "8", "MI350X": "8", "MI355X": "8", "MI455X": "12",
    "Ascend 910": "4（stack/die 术语混用）",
}
SKU_MEMORY_CONTROLLER_COUNT = {
    "A100": "10", "H100 SXM": "10", "H100 PCIe": "10", "TPU7x": "8",
    "TPU 8t": "6", "TPU 8i": "8", "Ascend 310": "2",
}
MEMORY_BUS_WIDTH = {
    "A100": "5,120-bit aggregate", "H100 SXM": "5,120-bit aggregate",
    "H100 PCIe": "5,120-bit aggregate", "H100 NVL": "6,016-bit aggregate",
    "L4": "192-bit aggregate", "L40S": "384-bit aggregate",
    "H200 NVL": "6,016-bit aggregate", "MI300X": "8,192-bit aggregate",
    "MI325X": "8,192-bit aggregate", "MI350P": "4,096-bit aggregate",
    "MI350X": "8,192-bit aggregate", "MI355X": "8,192-bit aggregate",
    "MI455X": "2,048-bit per HBM4 stack", "Ascend 310": "64-bit per controller × 2",
}
HBM_STACK_HEIGHT = {
    "TPU7x": "8-hi", "TPU 8t": "12-hi", "TPU 8i": "12-hi",
    "MI350X": "12-Hi", "MI355X": "12-Hi",
}
SERDES_RAW_LABEL = {
    "TPU7x": "6×112G SerDes octals + PCS",
    "TPU 8t": "6×224G SerDes octals",
    "TPU 8i": "6×200G SerDes octals + PCS",
}

RAS_ECC = {
    "A100", "H100 SXM", "H100 PCIe", "H100 NVL", "L4", "L40S",
    "H200 SXM", "H200 NVL", "MI300X", "MI325X", "MI350P", "MI350X",
    "MI355X", "MI455X", "Atlas A2 32", "Atlas A2 64", "GroqChip",
}
RAS_REPAIR = {
    "H100 SXM", "H100 PCIe", "TPU7x", "MI300X", "MI325X", "MI350P",
    "MI350X", "MI355X", "MI455X",
}
RAS_LINK_REPLAY = {"A100", "H100 SXM", "H200 SXM"}
RAS_BIST_SDC = {"TPU7x"}
RAS_CONCRETE_MECHANISM = RAS_ECC | RAS_REPAIR | RAS_LINK_REPLAY | RAS_BIST_SDC

PROCESS_NODE_NM = {
    "A100": 7, "H100 SXM": 4, "H100 PCIe": 4, "H100 NVL": 4,
    "L4": 4, "L40S": 4, "H200 SXM": 4, "H200 NVL": 4,
    "B200": 4, "B300": 4, "TPU v4": 7, "Trainium3": 3,
    "MI300X": 5, "MI325X": 5, "MI350P": 3, "MI350X": 3,
    "MI355X": 3, "MI455X": 2, "Ascend 310": 12,
    "Ascend 910": 7, "GroqChip": 14,
}

D2D_EVIDENCE = {
    "B200": ("绝对值", "NV-HBI 10 TB/s chip-to-chip；方向口径未在卡中展开"),
    "B300": ("绝对值", "NV-HBI 双向 10 TB/s"),
    "TPU7x": ("相对值", "D2D 为一条 1D ICI link 的 6 倍；不反推绝对值"),
    "TPU 8t": ("连接存在，未定量", "logic 与 ICI/SerDes chiplet 有连接；协议、速率未公开"),
    "TPU 8i": ("连接存在，未定量", "两个 logic die 与 ICI/CAE chiplet 相连；D2D 未公开"),
    "MI300X": ("机制公开，未定量", "Infinity Fabric 连接 XCD/IOD；无统一 D2D payload 值"),
    "MI325X": ("机制公开，未定量", "Infinity Fabric 连接 XCD/IOD；无统一 D2D payload 值"),
    "MI350P": ("机制公开，未定量", "4th Gen Infinity Architecture；拓扑与带宽未公开"),
    "MI350X": ("相对值", "双 IOD 路径较 CDNA 3 快约 14%；非 payload 带宽"),
    "MI355X": ("绝对值但对象特殊", "5.5 TB/s advanced-package bisection；非持续 workload 带宽"),
    "MI455X": ("机制公开，未定量", "3D hybrid bonding + Infinity Fabric；D2D 定值未公开"),
    "Ascend 910": ("连接存在，未定量", "compute die 与 I/O die 并置；封装内连接协议和带宽未公开"),
    "Ascend 950PR": ("连接存在，未定量", "D-DIE physical channel 已公开；协议、宽度、拓扑和带宽未公开"),
    "Ascend 950DT": ("连接存在，未定量", "D-DIE physical channel 已公开；协议、宽度、拓扑和带宽未公开"),
}

ACCUMULATION_LEVEL = {
    "A100": "累加语义未公开", "TPU v4": "明确 accumulator 类型",
    "H100 SXM": "明确 accumulator 类型", "H100 PCIe": "明确 accumulator 类型",
    "L4": "明确 accumulator 类型", "L40S": "明确 accumulator 类型",
    "TPU v5e": "明确 accumulator 类型", "TPU v5p": "明确 accumulator 类型",
    "TPU v6e": "明确 accumulator 类型", "TPU7x": "明确 accumulator 类型",
    "Inferentia2": "明确 accumulator 类型", "Trainium1": "明确 accumulator 类型",
    "Trainium2": "明确 accumulator 类型", "Trainium3": "明确 accumulator 类型",
    "GroqChip": "明确 accumulator 类型",
    "Inferentia1": "只公开 C/D 或 destination 类型",
    "MI300X": "只公开 C/D 或 destination 类型", "MI325X": "只公开 C/D 或 destination 类型",
    "MI350X": "只公开 C/D 或 destination 类型", "MI355X": "只公开 C/D 或 destination 类型",
    "MI455X": "只公开 C/D 或 destination 类型",
    "Ascend 310": "只公开 C/D 或 destination 类型", "Ascend 910": "只公开 C/D 或 destination 类型",
    "MLU590": "数值与累加路径未公开",
}
ACCUMULATION_PUBLIC = {"明确 accumulator 类型", "只公开 C/D 或 destination 类型", "只说明宽累加"}
FP32_OUTPUT_ONLY = {"TPU v4", "TPU v5e", "TPU v5p", "TPU v6e", "TPU7x", "Inferentia1", "GroqChip"}


def execution_class(q):
    text = q["execution_model"]
    if text == "未公开":
        return "执行模型未公开"
    if "cycle-accurate spatial" in text:
        return "静态空间调度"
    if "Cube/vector/scalar" in text:
        return "Cube + vector/scalar"
    if "SPMD" in text:
        return "SPMD + SIMD/SIMT"
    if "systolic" in text:
        return "systolic + vector/scalar"
    if "SIMT" in text or "wavefront" in text or "Wave32" in text:
        return "GPU SIMT/wavefront"
    return "其他已公开模型"


def precision_flags(q):
    text = q["precision_path"]
    u = text.upper()
    flags = {
        "precision_fp64": bool(re.search(r"(?<![A-Z0-9])FP64(?![A-Z0-9])", u)),
        "precision_fp32_tf32": ("FP32" in u or "TF32" in u) and q["short"] not in FP32_OUTPUT_ONLY,
        "precision_bf16": "BF16" in u,
        "precision_fp16": bool(re.search(r"(?<![A-Z0-9])FP16(?![A-Z0-9])", u)),
        "precision_fp8_family": any(k in u for k in ("FP8", "BF8", "HIF8")) or "MXFP4/6/8" in u,
        "precision_fp6_family": bool(re.search(r"(?<![A-Z0-9])(?:MX)?FP6(?![A-Z0-9])", u)) or "MXFP4/6/8" in u,
        "precision_fp4_family": "FP4" in u or "MXFP4/6/8" in u,
        "precision_int8": "INT8" in u,
        "precision_int4": "INT4" in u,
    }
    return {k: "公开支持" if v else "未见公开支持" for k, v in flags.items()}


def accumulation_class(q):
    return ACCUMULATION_LEVEL.get(q["short"], "累加语义未公开")


def structured_sparsity_status(text):
    low = text.lower()
    if "明确不采用" in text:
        return "明确不采用"
    if "无已知" in text or "未找到结构化稀疏" in text or "未找到该 SKU" in text:
        return "未找到或未公开"
    if "structured sparsity" in low or "4:2" in text or "2:4" in text or "M:N" in text:
        return "公开支持"
    return "未找到或未公开"


def special_unit_flags(q):
    special = q["sparsity_and_special_units"]
    collective = q["collective_hardware"]
    sparse_engine = "SparseCore" in special and not special.startswith("未找到") and "替代" not in special
    cross_collective = (
        "CC-Core" in special
        or (("collective" in special.lower() or "all-gather" in collective.lower())
            and "未找到" not in collective and "外部" not in collective)
    )
    onchip_reduce = "CAE" in special or "reduction/synchronization" in collective
    data_move = any(k in special for k in ("TMA", "TDM", "SXM 数据重排"))
    math_unit = any(k in special for k in ("softmax", "exponential", "指数函数", "DPX"))
    media = any(k in special for k in ("媒体", "编解码", "RT 单元", "DVPP"))
    return {
        "special_sparse_embedding": "公开" if sparse_engine else "未见公开",
        "special_cross_collective": "公开" if cross_collective else "未见公开",
        "special_onchip_reduction": "公开" if onchip_reduce else "未见公开",
        "special_data_movement": "公开" if data_move else "未见公开",
        "special_math": "公开" if math_unit else "未见公开",
        "special_media_graphics": "公开" if media else "未见公开",
    }


def storage_disclosure_class(text):
    if "容量未公开" in text or "总容量未公开" in text or "物理作用域与容量未公开" in text:
        if re.search(r"\d+(?:[,.]\d+)?\s*(?:B|KB|MB|MiB)", text, re.I):
            return "部分层级定量，其他层级未公开"
        return "层级/对象公开，容量未公开"
    if re.search(r"\d+(?:[,.]\d+)?\s*(?:B|KB|MB|MiB)", text, re.I):
        return "至少一个片上层级有定量容量"
    return "片上存储证据不足"


def clock_basis_class(text):
    """Classify the published clock object before looking at its magnitude."""
    has_numeric_clock = bool(re.search(r"\d[\d,.]*\s*(?:MHz|GHz)", text, re.I))
    if not has_numeric_clock:
        if text in ("资料卡未单列", "资料卡路径不可用"):
            return "资料卡未单列"
        return "明确未公开数值"
    low = text.lower()
    if "engine clock" in low and "peak engine" not in low:
        return "各计算 engine 独立时钟"
    if "peak engine clock" in low:
        return "peak engine clock"
    if "base" in low and "boost" in low:
        return "base + boost"
    if "boost" in low:
        return "boost/峰值计算时钟"
    return "per-chip/product operating point"


def extract_card_row(q, labels):
    path = ROOT / q["source_card"]
    if not path.exists():
        return "资料卡路径不可用"
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) >= 2 and any(cells[0] == label or cells[0].startswith(label) for label in labels):
            return cells[1]
    return "资料卡未单列"


def extract_card_row_joined(q, labels):
    path = ROOT / q["source_card"]
    if not path.exists():
        return "资料卡路径不可用"
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) >= 2 and any(cells[0] == label or cells[0].startswith(label) for label in labels):
            return "；".join(c for c in cells[1:3] if c)
    return "资料卡未单列"


def extract_card_rows_joined(q, labels):
    """Return every matching fact-card row without collapsing its scope.

    Older cards sometimes split Tensor/Vector/Scalar peaks or die/package
    details across several rows.  A first-match extractor would hide those
    rows and recreate the omission this report is intended to correct.
    """
    path = ROOT / q["source_card"]
    if not path.exists():
        return "资料卡路径不可用"
    matches = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 2:
            continue
        if any(cells[0] == label or cells[0].startswith(label) for label in labels):
            value = "：".join((cells[0], "；".join(c for c in cells[1:3] if c)))
            if value not in matches:
                matches.append(value)
    return " ｜ ".join(matches) if matches else "资料卡未单列"


def memory_technology_class(q):
    if q["memory_domain"] == "片上SRAM":
        return "片上 SRAM（非外部 DRAM）"
    if q["memory_type"] == "未公开":
        return "未公开"
    if "HBM" in q["memory_type"]:
        return "HBM family"
    if "GDDR" in q["memory_type"]:
        return "GDDR"
    if "DDR" in q["memory_type"]:
        return "DDR/LPDDR"
    return "其他"


def power_basis_class(q):
    if q["power_w"] is None:
        return "功耗未公开"
    text = q["power_basis"].lower()
    if "fleet" in text or "production mean" in text:
        return "fleet/production average"
    if "tbp" in text or "board power" in text:
        return "TBP/board power"
    if "tdp" in text:
        return "TDP"
    if any(k in text for k in ("maximum", "up to", "configurable", "最高", "上限")):
        return "maximum/configurable limit"
    return "产品功耗 headline"


def endpoint_family(q):
    text = q["device_interconnect"]
    if text == "未公开":
        return "未公开"
    if "无专用" in text or "仅 PCIe" in text or "无公开" in text:
        return "无专用端点/仅 PCIe"
    if "NVLink" in text:
        return "NVLink"
    if "ICI" in text:
        return "ICI"
    if "NeuronLink" in text:
        return "NeuronLink"
    if "Infinity Fabric" in text or "UALoE" in text:
        return "Infinity Fabric / UALoE"
    if any(k in text for k in ("灵衢", "HCCS", "UnifiedBus")):
        return "华为设备互联"
    if "RealScale" in text:
        return "RealScale C2C"
    return "其他已公开端点"


def scaleup_topology_class(q):
    if q["scaleup_status"] == "明确无专用 scale-up":
        return "无专用 scale-up"
    if q["scaleup_status"] == "工作域未公开":
        return "拓扑/工作域未公开"
    text = q["scaleup_topology"]
    if "bridge" in text:
        return "bridge / 点到点"
    if "full mesh" in text or "fully connected" in text:
        return "全连接"
    if "torus" in text or "mesh" in text:
        return "mesh / torus"
    if any(k in text for k in ("NVSwitch", "OCS", "Boardfly", "UltraServer", "rack", "机架")):
        return "交换/分层 fabric"
    return "设备组，拓扑细节不足"


def scaleout_evidence_class(q):
    text = q["scaleout_context"]
    if text == "资料卡未单列":
        return "资料卡未单列"
    if q["short"] in ("MI455X", "Ascend 950DT"):
        return "per-SKU/per-NPU 端点或配置"
    if q["short"] == "H100 SXM":
        return "发布期 roadmap network target"
    if text.startswith("未记录") or text.startswith("未找到"):
        return "未记录独立端点"
    if "software" in text or "software APIs" in text:
        return "仅软件能力"
    return "系统/NIC/DCN 上下文；不下放为芯片"


def host_interface_class(text):
    if text.startswith("未公开单独"):
        return "未公开/未单列"
    for n in (6, 5, 4, 3):
        if re.search(rf"(?:Gen\s*{n}|PCIe\s*{n}\.0)", text, re.I):
            return f"PCIe Gen{n}"
    if "PCIe" in text:
        return "PCIe，代际/通道不完整"
    if text == "资料卡未单列" or "未公开" in text:
        return "未公开/未单列"
    return "其他主机接口"


def cooling_class(text):
    if text == "资料卡未单列" or "未公开" in text:
        return "散热未公开"
    low = text.lower()
    if any(k in text for k in ("由系统决定", "系统配置决定", "由 HGX/OEM 系统", "由 HGX/OEM 系统实现")):
        return "形态已知，散热方式不完整"
    if any(k in low for k in ("liquid", "液冷", "dlc", "cold plate", "冷板")):
        return "液冷/冷板"
    if any(k in low for k in ("passive", "被动")):
        return "被动散热"
    if any(k in low for k in ("active", "fan", "风冷", "风扇")):
        return "主动/风冷"
    return "形态已知，散热方式不完整"


def ras_evidence_class(text):
    if text == "资料卡未单列":
        return "资料卡未单列"
    if "未公开" in text:
        return "核心 RAS 机制未公开"
    if any(k in text for k in ("ECC", "retirement", "replay", "BIST", "logic repair", "RAS Engine")):
        return "公开芯片/package RAS 机制"
    return "只有管理、安全或系统层线索"


def memory_access_evidence_class(text):
    if text == "资料卡未单列":
        return "资料卡未单列"
    if "未公开" in text:
        return "访问/一致性语义未公开"
    if "coherent GPU" in text:
        return "package 内 coherent GPU"
    if any(k in text for k in ("common address", "peer", "远程", "globally addressable", "memory pooling", "SHMEM")):
        return "跨设备寻址/远程访问语义"
    if "coherency" in text or "coherence" in text:
        return "跨设备 coherence 语义"
    if any(k in text for k in ("DMA", "software", "compiler", "显式")):
        return "显式搬运或软件管理"
    return "其他已公开访问语义"


def qualitative_evidence_class(text):
    if text == "资料卡未单列":
        return "资料卡未单列"
    if text.startswith("未公开"):
        return "未公开"
    if re.search(r"\d", text):
        return "有定量或数量事实"
    return "有定性结构事实"


def deployment_class(q):
    deployment = q["deployment"]
    if deployment == "边缘 SoC":
        return "边缘 SoC"
    if deployment == "低功耗 PCIe 卡":
        return "低功耗 PCIe"
    if deployment == "标准 PCIe 卡":
        return "标准 PCIe"
    if deployment in ("高密度数据中心模组", "高密度数据中心芯片"):
        return "高密度数据中心"
    if deployment == "云内芯片":
        return "云内芯片"
    return "其他或未公开"


def scaleup_status_scope(q):
    topology = q["scaleup_topology"]
    domain = q["max_scaleup_domain"]
    if domain is None or topology in ("最大直接域未公开", "未找到专属拓扑/域"):
        return "工作域未公开", "未公开"
    if domain == 1:
        if "无专用" in topology or "无公开直连域" in topology:
            return "明确无专用 scale-up", "无专用端点"
        return "工作域未公开", "未公开"
    if "bridge" in topology:
        return "公开数值工作域", "bridge/直连组"
    if any(k in topology for k in ("Pod", "slice", "SuperPod", "cube")):
        return "公开数值工作域", "Pod/slice"
    if any(k in topology for k in ("rack", "UltraServer", "机架")):
        return "公开数值工作域", "rack/UltraServer"
    if any(k in topology for k in ("DGX", "HGX", "NVSwitch", "server", "服务器", "8-GPU")):
        return "公开数值工作域", "服务器/NVSwitch"
    return "公开数值工作域", "其他公开域"

for _q in ROWS:
    if _q["short"] in STRICT_DENSE:
        _q["bf16_fp16_peak_condition"] = "明确 dense/base"
    elif _q["short"] in PEAK_CONDITION_PARTIAL:
        _q["bf16_fp16_peak_condition"] = "厂商未完整说明 dense/sparse 或计数条件"
    elif _q["short"] in WITH_SPARSITY:
        _q["bf16_fp16_peak_condition"] = "with sparsity；dense 值未公开"
    _q["advertised_peak_precision"] = PEAK_PRECISION_OVERRIDES.get(_q["short"], "BF16/FP16")

    # Plotting values use decimal GB and TB/s. Exact GiB-only capacities are
    # converted; ambiguous GB/GiB disclosures retain the nominal number and
    # are identified by the original-unit field.
    _cap = _q["memory_capacity_value"]
    if _cap is not None and _q["memory_capacity_unit"] == "GiB":
        _cap = float(_cap) * 1.073741824
    _q["memory_capacity_gb"] = _cap
    _q["memory_bandwidth_tbps"] = _q["memory_bandwidth_value"]
    if _q["short"] == "Ascend 950DT":
        _q["availability_status"] = "roadmap target"
    elif _q["short"] == "Ascend 950PR":
        _q["availability_status"] = "最大公开配置"
    else:
        _q["availability_status"] = "当前产品/公开配置"

    _q["release_year"] = RELEASE_YEAR.get(_q["short"])
    _q["deployment_class"] = deployment_class(_q)
    _q["core_analysis_family"] = CORE_ANALYSIS_FAMILY[_q["short"]]
    _q["core_relation_level"] = CORE_RELATION_LEVEL.get(
        _q["core_analysis_family"], "没有跨定位的同 Core 对照"
    )
    if _q["short"] in SINGLE_LOGIC_COMPUTE_DIE:
        _q["compute_die_organization"] = "单逻辑计算 die"
    elif _q["short"] in SINGLE_COMPUTE_WITH_AUX_DIE:
        _q["compute_die_organization"] = "一颗计算 die + 辅助 die"
    elif _q["short"] in MULTI_COMPUTE_DIE:
        _q["compute_die_organization"] = "多计算 die/chiplet"
    else:
        _q["compute_die_organization"] = "物理组织不足"
    _q["comparable_family"] = PAIR_GROUP.get(_q["short"], "")
    _q["scaleup_status"], _q["scaleup_scope"] = scaleup_status_scope(_q)
    if _q["scaleup_status"] != "公开数值工作域":
        _q["max_scaleup_domain"] = None
    _q["execution_class"] = execution_class(_q)
    _q.update(precision_flags(_q))
    _q["accumulation_evidence"] = accumulation_class(_q)
    _q["accumulation_summary"] = extract_card_row_joined(
        _q, ("程序员可见累加", "FP8与累加", "数值格式与累加", "累加与舍入", "MXU数值语义",
             "数值与累加路径", "数值路径", "矩阵与数值路径")
    )
    _q["structured_sparsity_status"] = structured_sparsity_status(
        _q["sparsity_and_special_units"]
    )
    _q.update(special_unit_flags(_q))
    _q["onchip_storage_disclosure"] = storage_disclosure_class(_q["onchip_storage"])

    # Keep the full fact-card rows that define the analysis universe.  These
    # text columns are not coerced into cross-vendor numeric rankings; they let
    # the appendix show what was collected and why some comparisons stop at an
    # evidence boundary.
    _q["target_workload_summary"] = extract_card_row(
        _q, ("目标 workload", "目标workload", "目标负载")
    )
    _q["product_goal_summary"] = extract_card_row(_q, ("产品目标",))
    _q["core_path_detail"] = extract_card_rows_joined(
        _q, ("矩阵、向量、标量与控制路径", "矩阵、向量与控制路径", "TensorCore组成",
             "TensorEngine", "Tensor Engine", "VectorEngine", "Vector Engine", "ScalarEngine", "Scalar Engine",
             "CU执行组织", "CU 执行组织", "AI Core", "Cube", "Vector", "Scalar")
    )
    _q["execution_detail"] = extract_card_rows_joined(
        _q, ("执行模型与调度", "异构执行与调度", "异构执行", "执行组织", "CU执行组织", "CU 执行组织")
    )
    _q["local_storage_and_movement_detail"] = extract_card_rows_joined(
        _q, ("局部存储与数据搬运", "局部存储", "TensorCore局部存储", "Core 本地存储",
             "CU局部存储", "CU 局部存储", "片上存储", "数据搬运",
             "Cache / scratchpad", "Cache", "DMA", "MTE", "TMA")
    )
    _q["numeric_path_detail"] = extract_card_rows_joined(
        _q, ("数值与累加路径", "矩阵与数值路径", "数值路径", "数值格式与稀疏", "数值格式",
             "程序员可见累加", "FP8与累加", "累加与舍入", "MXU数值语义")
    )
    _q["enabled_resources_detail"] = extract_card_rows_joined(
        _q, ("实际使能计算资源", "实际计算资源", "可用加速资源", "A100实际资源", "产品配置")
    )
    _q["clock_detail"] = extract_card_rows_joined(
        _q, ("时钟", "clock", "时钟、功耗与散热")
    )
    _q["theoretical_peak_detail"] = extract_card_rows_joined(
        _q, ("理论峰值", "稠密理论峰值", "dense Tensor 峰值", "芯片与每核Tensor峰值", "NCv2与chip峰值",
             "FP16 / BF16 Matrix 峰值", "FP16 / FP32 / FP64 峰值", "FP32/FP64峰值", "FP16/BF16峰值", "TF32峰值",
             "INT8 峰值", "MXFP 峰值", "OCP-FP8 / INT8 峰值", "结构化稀疏峰值", "sparse峰值")
    )
    _q["theoretical_peak_evidence_class"] = PEAK_EVIDENCE_CLASS[_q["short"]]
    _q["compute_process_nm"] = PROCESS_NODE_NM.get(_q["short"])
    if _q["short"] in D2D_EVIDENCE:
        _q["d2d_evidence_level"], _q["d2d_summary"] = D2D_EVIDENCE[_q["short"]]
    else:
        _q["d2d_evidence_level"], _q["d2d_summary"] = "证据不足", "资料卡未形成可比 D2D 定值"
    if _q["short"] in SINGLE_LOGIC_COMPUTE_DIE:
        _q["logical_d2d_status"] = "逻辑 die 间 D2D 不适用"
    elif _q["short"] in D2D_PRESENT_CONFIRMED:
        _q["logical_d2d_status"] = "确认存在逻辑 die 间连接"
    else:
        _q["logical_d2d_status"] = "package 物理组织不足，D2D 未知"
    if _q["device_interconnect"] == "未公开":
        _q["device_link_evidence_class"] = "端点未公开"
    elif _q["device_link_nominal_tbps"] == 0:
        _q["device_link_evidence_class"] = "明确无专用端点"
    elif _q["device_link_nominal_tbps"] is None:
        _q["device_link_evidence_class"] = "端点已知，名义带宽不可比"
    elif "bidirectional" in _q["device_interconnect"] or "双向" in _q["device_interconnect"]:
        _q["device_link_evidence_class"] = "公开双向名义值"
    else:
        _q["device_link_evidence_class"] = "公开名义值，方向/有效载荷未完全统一"
    _q["host_interface"] = extract_card_row(
        _q, ("主机接口", "Host 接口", "Host接口", "Host interface", "Host / network I/O", "CPU-GPU 互联")
    )
    _q["memory_access_semantics"] = extract_card_row(
        _q, ("内存访问语义", "共享内存语义", "互联与一致性", "主机一致性与统一内存")
    )
    _q["onchip_interconnect"] = extract_card_row(
        _q, ("片内互联", "片上互联", "NoC")
    )
    _q["memory_controller_phy"] = extract_card_row(
        _q, ("内存控制器与 PHY", "内存控制器与PHY", "HBM physical organization", "HBM接口", "外部内存接口")
    )
    _q["memory_stack_count"] = MEMORY_STACK_COUNT.get(_q["short"], "")
    _q["sku_memory_controller_count"] = SKU_MEMORY_CONTROLLER_COUNT.get(_q["short"], "")
    _q["memory_bus_width"] = MEMORY_BUS_WIDTH.get(_q["short"], "")
    _q["hbm_stack_height"] = HBM_STACK_HEIGHT.get(_q["short"], "")
    _q["serdes_raw_label"] = SERDES_RAW_LABEL.get(_q["short"], "")
    _q["ras_summary"] = extract_card_row(
        _q, ("RAS", "虚拟化与 RAS", "虚拟化、RAS", "虚拟化、RAS 与安全")
    )
    _q["system_reliability_summary"] = extract_card_row(
        _q, ("系统可靠性",)
    )
    _q["scaleout_context"] = extract_card_row(_q, ("Scale-out", "实例网络与厂商"))
    _q["cooling_summary"] = extract_card_row(_q, ("形态与散热", "散热"))
    _q["device_endpoint_detail"] = extract_card_row_joined(
        _q, ("设备互联端点", "Scale-up 端点", "scale-up 端点", "Scale-up 拓扑", "Scale-up拓扑")
    )
    endpoint_text = _q["device_endpoint_detail"]
    _q["device_link_direction_evidence"] = (
        "方向已知" if any(k in endpoint_text for k in ("双向", "bidirectional", "per direction", "每方向"))
        else "方向未完整公开"
    )
    if "bridge" in endpoint_text.lower():
        _q["device_endpoint_scope"] = "外部 bridge 配置"
    elif "raw" in endpoint_text.lower():
        _q["device_endpoint_scope"] = "raw pin aggregate"
    elif "EAM" in endpoint_text:
        _q["device_endpoint_scope"] = "EAM aggregate"
    else:
        _q["device_endpoint_scope"] = "设备集成端点"
    if _q["device_link_nominal_tbps"] is not None and _q["device_link_nominal_tbps"] > 0:
        _q["device_link_evidence_class"] = (
            "公开名义值，方向已知；payload/持续口径未统一"
            if _q["device_link_direction_evidence"] == "方向已知"
            else "公开名义值；方向/payload/持续口径未统一"
        )
    _q["memory_technology_class"] = memory_technology_class(_q)
    _q["power_basis_class"] = power_basis_class(_q)
    _q["endpoint_family"] = endpoint_family(_q)
    _q["scaleup_topology_class"] = scaleup_topology_class(_q)
    _q["scaleout_evidence_class"] = scaleout_evidence_class(_q)
    _q["host_interface_class"] = host_interface_class(_q["host_interface"])
    _q["cooling_class"] = cooling_class(_q["cooling_summary"])
    _q["ras_evidence_class"] = ras_evidence_class(_q["ras_summary"])
    if _q["short"] in RAS_CONCRETE_MECHANISM:
        _q["ras_evidence_class"] = "公开具体芯片/package RAS 机制"
    elif _q["short"] == "B200":
        _q["ras_evidence_class"] = "仅公开 RAS Engine 名称"
    _q["ras_ecc"] = "公开" if _q["short"] in RAS_ECC else "未见公开"
    _q["ras_repair_remap"] = "公开" if _q["short"] in RAS_REPAIR else "未见公开"
    _q["ras_link_detection_replay"] = "公开" if _q["short"] in RAS_LINK_REPLAY else "未见公开"
    _q["ras_bist_sdc"] = "公开" if _q["short"] in RAS_BIST_SDC else "未见公开"
    _q["memory_access_evidence_class"] = memory_access_evidence_class(
        _q["memory_access_semantics"]
    )
    _q["onchip_interconnect_evidence"] = qualitative_evidence_class(
        _q["onchip_interconnect"]
    )
    _q["noc_evidence_detail_class"] = NOC_EVIDENCE_DETAIL.get(
        _q["short"], "NoC/片内互联结构未公开或资料卡未单列"
    )
    _q["noc_implementation_family"] = (
        "GH100" if _q["short"] in {"H100 SXM", "H100 PCIe", "H100 NVL", "H200 SXM", "H200 NVL"}
        else "AD102" if _q["short"] == "L40S"
        else _q["short"] if _q["short"] in NOC_EVIDENCE_DETAIL
        else ""
    )
    _q["memory_controller_phy_evidence"] = qualitative_evidence_class(
        _q["memory_controller_phy"]
    )
    _q["clock_basis_class"] = clock_basis_class(_q["clock_detail"])
    _q["clock_numeric_available"] = (
        "是" if _q["clock_basis_class"] not in ("资料卡未单列", "明确未公开数值") else "否"
    )
    _q["data_management_class"] = DATA_MANAGEMENT_CLASS[_q["short"]]
    _q["data_movement_class"] = DATA_MOVEMENT_CLASS.get(
        _q["short"], "load/store/cache 路径存在；具名搬运或吞吐证据不足"
    )
    _q["dma_bandwidth_tbps"] = DMA_BANDWIDTH_TBPS.get(_q["short"])
    _q["dma_bandwidth_evidence"] = (
        "chip-level headline；方向/payload/持续口径未完整"
        if _q["dma_bandwidth_tbps"] is not None else "未形成可比数值"
    )

    # Derived nameplate ratios use the same advertised BF16/FP16 peak already
    # selected for the P/B plot.  B/P is the reciprocal of P/B and is stored for
    # auditability rather than treated as an independent statistical signal.
    _peak = _q["advertised_bf16_fp16_peak_tflops"]
    _bw = _q["memory_bandwidth_tbps"]
    _cap = _q["memory_capacity_gb"]
    _ratio_eligible = (
        _q["memory_domain"] == "外部DRAM"
        and _peak is not None and _peak > 0
        and _q["bf16_fp16_peak_condition"] in (
            "明确 dense/base", "厂商未完整说明 dense/sparse 或计数条件"
        )
    )
    _q["peak_per_memory_bandwidth_tflops_per_tbps"] = (
        _peak / _bw if _ratio_eligible and _bw else None
    )
    _q["memory_bandwidth_per_peak_gbps_per_tflops"] = (
        _bw * 1000 / _peak if _ratio_eligible and _bw else None
    )
    _q["memory_capacity_per_peak_gb_per_tflops"] = (
        _cap / _peak if _ratio_eligible and _cap else None
    )
    _q["nameplate_ratio_evidence"] = (
        "同精度且明确 dense/base"
        if _ratio_eligible and _q["bf16_fp16_peak_condition"] == "明确 dense/base"
        else "同精度，但 dense/sparse 或计数条件不完整"
        if _ratio_eligible else "不可计算"
    )
    _q["nameplate_peak_per_power_tflops_per_w"] = (
        _peak / _q["power_w"]
        if _ratio_eligible and _q["power_w"] is not None and _q["power_w"] > 0
        else None
    )
    _q["peak_per_power_evidence"] = (
        f"{_q['nameplate_ratio_evidence']}；功耗口径={_q['power_basis_class']}"
        if _q["nameplate_peak_per_power_tflops_per_w"] is not None else "不可计算"
    )

    _endpoint = STRICT_DEVICE_ENDPOINT_PER_DIRECTION_TBPS.get(_q["short"])
    _q["device_endpoint_bandwidth_per_peak_gbps_per_tflops"] = (
        _endpoint * 1000 / _peak
        if _endpoint is not None and _endpoint > 0 and _peak is not None and _peak > 0
        else None
    )
    _q["device_endpoint_ratio_evidence"] = (
        "设备集成端点、单向值、峰值明确 dense/base；payload/持续值仍未统一"
        if _q["device_endpoint_bandwidth_per_peak_gbps_per_tflops"] is not None
        else "不可计算"
    )
    _balance = CORE_BALANCE_BY_SHORT.get(_q["short"])
    if _balance:
        _q["core_balance_precision"] = _balance["precision"]
        _q["matrix_peak_tflops_same_precision"] = _balance["matrix"]
        _q["nonmatrix_peak_tflops_same_precision"] = _balance["nonmatrix"]
        _q["nonmatrix_path_label"] = _balance["nonmatrix_label"]
        _q["matrix_to_nonmatrix_peak_ratio"] = _balance["matrix"] / _balance["nonmatrix"]
        _q["core_balance_evidence"] = _balance["evidence"]
    else:
        _q["core_balance_precision"] = ""
        _q["matrix_peak_tflops_same_precision"] = None
        _q["nonmatrix_peak_tflops_same_precision"] = None
        _q["nonmatrix_path_label"] = ""
        _q["matrix_to_nonmatrix_peak_ratio"] = None
        _q["core_balance_evidence"] = "not_comparable"
    _physical = PHYSICAL_MVS_BY_SHORT.get(_q["short"])
    _q["physical_mvs_ratio"] = _physical[4] if _physical else ""
    _q["physical_mvs_evidence"] = _physical[5] if _physical else "不可比/未完整公开"
    _mvs = CORE_MVS_BY_SHORT.get(_q["short"])
    if _mvs:
        _q["complete_mvs_precision"] = _mvs["precision"]
        _q["complete_mvs_matrix_tflops_per_core"] = _mvs["matrix"]
        _q["complete_mvs_vector_tflops_per_core"] = _mvs["vector"]
        _q["complete_mvs_scalar_tflops_per_core"] = _mvs["scalar"]
        _q["complete_mvs_normalized_to_vector"] = (
            f"{_mvs['matrix']/_mvs['vector']:.2f}:1:{_mvs['scalar']/_mvs['vector']:.2f}"
        )
    else:
        _q["complete_mvs_precision"] = ""
        _q["complete_mvs_matrix_tflops_per_core"] = None
        _q["complete_mvs_vector_tflops_per_core"] = None
        _q["complete_mvs_scalar_tflops_per_core"] = None
        _q["complete_mvs_normalized_to_vector"] = ""


CSV_FIELDS = [k for k in ROWS[0].keys() if k not in ("reuse_family", "reuse_scope")]


def write_csv():
    path = HERE / "36款芯片全量比较数据.csv"
    with path.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=CSV_FIELDS, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(ROWS)
    return path


def font(size, index=0):
    return ImageFont.truetype(FONT_PATH, size=size, index=index)


def text_size(draw, value, fnt):
    box = draw.textbbox((0, 0), str(value), font=fnt)
    return box[2] - box[0], box[3] - box[1]


def draw_text(draw, xy, value, fnt, fill=TEXT, anchor=None):
    draw.text(xy, str(value), font=fnt, fill=fill, anchor=anchor)


def draw_multiline(draw, xy, value, fnt, fill=TEXT, spacing=8, anchor=None, align="left"):
    draw.multiline_text(xy, str(value), font=fnt, fill=fill, spacing=spacing,
                        anchor=anchor, align=align)


def shape(draw, x, y, kind, color, radius=10, outline=WHITE, width=2, hollow=False):
    fill = WHITE if hollow else color
    if kind == "square":
        draw.rounded_rectangle((x-radius, y-radius, x+radius, y+radius), radius=3,
                               fill=fill, outline=color if hollow else outline, width=width)
    elif kind == "diamond":
        pts = [(x, y-radius-2), (x+radius+2, y), (x, y+radius+2), (x-radius-2, y)]
        draw.polygon(pts, fill=fill, outline=color if hollow else outline)
        if hollow:
            draw.line(pts + [pts[0]], fill=color, width=width, joint="curve")
    elif kind == "triangle":
        pts = [(x, y-radius-3), (x+radius+3, y+radius), (x-radius-3, y+radius)]
        draw.polygon(pts, fill=fill, outline=color if hollow else outline)
        if hollow:
            draw.line(pts + [pts[0]], fill=color, width=width, joint="curve")
    elif kind == "cross":
        draw.line((x-radius, y-radius, x+radius, y+radius), fill=color, width=width+2)
        draw.line((x-radius, y+radius, x+radius, y-radius), fill=color, width=width+2)
    else:
        draw.ellipse((x-radius, y-radius, x+radius, y+radius), fill=fill,
                     outline=color if hollow else outline, width=width)


def memory_marker(memory_type):
    if memory_type.startswith("GDDR"):
        return "square"
    if "DDR" in memory_type and "HBM" not in memory_type:
        return "diamond"
    return "circle"


def form_factor_marker(form_factor):
    if "PCIe" in form_factor:
        return "square"
    if "SoC" in form_factor:
        return "diamond"
    if "Cloud" in form_factor:
        return "triangle"
    return "circle"


def log_map(value, lo, hi, a, b):
    value = max(value, lo)
    return a + (math.log10(value) - math.log10(lo)) / (math.log10(hi) - math.log10(lo)) * (b - a)


def nice_num(v):
    if v >= 10000:
        return f"{v/1000:.0f}k"
    if v >= 1000:
        return f"{v/1000:.1f}k".replace(".0k", "k")
    if v >= 10:
        return f"{v:g}"
    if v >= 1:
        return f"{v:g}"
    return f"{v:.2g}"


def header(draw, title, subtitle, width):
    draw_text(draw, (110, 70), title, font(52), TEXT)
    draw_text(draw, (110, 142), subtitle, font(28), MUTED)
    draw.line((110, 196, width-110, 196), fill=GRID, width=2)


def legend_position(draw, x, y):
    draw_text(draw, (x, y), "厂商产品定位", font(27), TEXT)
    yy = y + 48
    for group in (TRAIN, INFER, UNIFIED):
        shape(draw, x+12, yy+10, "circle", PALETTE[group], radius=9)
        draw_text(draw, (x+35, yy), group, font(23), TEXT)
        yy += 42
    return yy


def candidate_label_boxes(draw, x, y, label, fnt):
    tw, th = text_size(draw, label, fnt)
    pad = 5
    offsets = [
        (14, -th-12), (-tw-14, -th-12), (14, 10), (-tw-14, 10),
        (18, -th//2), (-tw-18, -th//2), (-tw//2, -th-20), (-tw//2, 16),
    ]
    for ox, oy in offsets:
        x0, y0 = x+ox-pad, y+oy-pad
        yield (x0, y0, x0+tw+2*pad, y0+th+2*pad), (x+ox, y+oy)


def overlaps(box, boxes, margin=3):
    x0, y0, x1, y1 = box
    for a0, b0, a1, b1 in boxes:
        if not (x1+margin < a0 or a1+margin < x0 or y1+margin < b0 or b1+margin < y0):
            return True
    return False


def place_labels(draw, points, bounds, fnt, label_all=True, chosen=None):
    used = []
    x0, y0, x1, y1 = bounds
    chosen = set(chosen or [])
    for p in sorted(points, key=lambda q: (q["x"], q["y"])):
        if not label_all and p["row"]["short"] not in chosen:
            continue
        label = p["row"]["short"]
        selected = None
        for box, pos in candidate_label_boxes(draw, p["x"], p["y"], label, fnt):
            if box[0] >= x0 and box[1] >= y0 and box[2] <= x1 and box[3] <= y1 and not overlaps(box, used):
                selected = (box, pos)
                break
        if selected is None:
            box, pos = next(candidate_label_boxes(draw, p["x"], p["y"], label, fnt))
            box = (max(x0, min(box[0], x1-(box[2]-box[0]))),
                   max(y0, min(box[1], y1-(box[3]-box[1]))), 0, 0)
            box = (box[0], box[1], box[0] + text_size(draw, label, fnt)[0] + 10,
                   box[1] + text_size(draw, label, fnt)[1] + 10)
            pos = (box[0]+5, box[1]+5)
        box, pos = selected if selected else (box, pos)
        used.append(box)
        cx = min(max(p["x"], box[0]), box[2])
        cy = min(max(p["y"], box[1]), box[3])
        draw.line((p["x"], p["y"], cx, cy), fill="#AAB2BD", width=1)
        draw.rounded_rectangle(box, radius=5, fill="#FFFFFFE8", outline="#E3E7EC", width=1)
        draw_text(draw, pos, label, fnt, TEXT)


def draw_axes_log(draw, plot, xticks, yticks, xlabel, ylabel, xlo, xhi, ylo, yhi):
    left, top, right, bottom = plot
    draw.rectangle(plot, fill=WHITE, outline=GRID, width=2)
    tick_font = font(23)
    for v in xticks:
        x = log_map(v, xlo, xhi, left, right)
        draw.line((x, top, x, bottom), fill=GRID, width=1)
        draw_text(draw, (x, bottom+14), nice_num(v), tick_font, MUTED, anchor="ma")
    for v in yticks:
        y = log_map(v, ylo, yhi, bottom, top)
        draw.line((left, y, right, y), fill=GRID, width=1)
        draw_text(draw, (left-16, y), nice_num(v), tick_font, MUTED, anchor="rm")
    draw_text(draw, ((left+right)//2, bottom+78), xlabel, font(27), TEXT, anchor="ma")
    # Build the layer from the measured text width so long Chinese axis labels
    # are not clipped before rotation.
    label_font = font(27)
    tw, th = text_size(draw, ylabel, label_font)
    label_layer = Image.new("RGBA", (tw+40, th+34), (255,255,255,0))
    ld = ImageDraw.Draw(label_layer)
    draw_text(ld, ((tw+40)//2, (th+34)//2), ylabel, label_font, TEXT, anchor="mm")
    label_layer = label_layer.rotate(90, expand=True)
    return label_layer, (22, int((top+bottom-label_layer.height)/2))


def save(img, name):
    path = HERE / name
    img.convert("RGB").save(path, quality=95, optimize=True)
    return path


def figure_core_position():
    families = []
    by_family = defaultdict(list)
    for q in ROWS:
        family = q["core_analysis_family"]
        if family not in by_family:
            families.append(family)
        by_family[family].append(q)
    row_h = 92
    W = 2400
    H = 360 + len(families) * row_h + 220
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "Core 架构与厂商用途定位",
           f"n=36；每行是一种 Core 实现或公开架构家族。三列按厂商定位排列，左侧注明跨定位关系的证据层级。", W)
    role_centers = {TRAIN: 1050, INFER: 1560, UNIFIED: 2070}
    top = 305
    for group, x in role_centers.items():
        draw_text(draw, (x, 250), group, font(26), PALETTE[group], anchor="ma")
    draw.line((720, 275, W-90, 275), fill=GRID, width=2)
    for i, family in enumerate(families):
        y = top + i * row_h
        members = by_family[family]
        if i % 2:
            draw.rectangle((80, y-row_h//2, W-80, y+row_h//2), fill="#FAFBFC")
        roles = {q["position_group"] for q in members}
        relation = members[0]["core_relation_level"]
        if len(roles) < 2:
            relation = "没有跨定位的同 Core 对照"
        draw_text(draw, (100, y-11), family, font(24), TEXT, anchor="lm")
        draw_text(draw, (100, y+22), relation, font(18), MUTED, anchor="lm")
        active = [role_centers[g] for g in (TRAIN, INFER, UNIFIED) if g in roles]
        if len(active) > 1:
            draw.line((min(active)-120, y, max(active)+120, y), fill="#B8C0C8", width=3)
        for group in (TRAIN, INFER, UNIFIED):
            items = [q for q in members if q["position_group"] == group]
            if not items:
                continue
            offsets = np.linspace(-175, 175, len(items)) if len(items) > 1 else [0]
            for offset, q in zip(offsets, items):
                x = role_centers[group] + float(offset)
                shape(draw, x, y, "circle", PALETTE[group], radius=12, outline=WHITE, width=3)
                draw_text(draw, (x, y+25), q["short"], font(17), TEXT, anchor="ma")
    legend_y = top + len(families) * row_h + 35
    draw_multiline(draw, (100, legend_y),
                   "证据层级只说明 Core 关系：同一 die/Core ＞ 相同 Core 与芯片资源组织 ＞ 同一公开 Core 架构。\n"
                   "单独一款产品或只出现在一种定位中的 Core，不能用于判断训推差异。",
                   font(20), MUTED, spacing=8)
    return save(img, "01_Core架构与用途定位.png")


def figure_execution_model():
    categories = [
        "GPU SIMT/wavefront", "systolic + vector/scalar",
        "Cube + vector/scalar", "SPMD + SIMD/SIMT",
        "静态空间调度", "其他已公开模型", "执行模型未公开",
    ]
    W, H = 2400, 1450
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "Core 执行组织与厂商用途定位",
           "n=36；相近的公开执行模型归为同一类。条长为产品数，右侧列出厂商，避免把厂商路线误读成用途规律。", W)
    x0, x1 = 650, 1740
    top, row_h = 300, 112
    max_n = max(sum(q["execution_class"] == c for q in ROWS) for c in categories)
    for i, category in enumerate(categories):
        y = top + i * row_h
        members = [q for q in ROWS if q["execution_class"] == category]
        draw_text(draw, (110, y), category, font(25), TEXT, anchor="lm")
        cursor = x0
        for role in (TRAIN, INFER, UNIFIED):
            n = sum(q["position_group"] == role for q in members)
            if not n:
                continue
            width = n / max_n * (x1 - x0)
            draw.rounded_rectangle((cursor, y-20, cursor+width, y+20), radius=6,
                                   fill=PALETTE[role], outline=WHITE, width=2)
            if width > 45:
                draw_text(draw, (cursor+width/2, y), n, font(20), WHITE, anchor="mm")
            cursor += width
        vendors = "、".join(f"{v} {n}" for v, n in Counter(q["vendor"] for q in members).most_common())
        draw_text(draw, (1800, y), vendors or "—", font(19), MUTED, anchor="lm")
        draw.line((x0, y+48, W-100, y+48), fill="#EEF1F4", width=1)
    legend_position(draw, 110, 1190)
    draw_multiline(draw, (820, 1200),
                   "分类依据是资料卡公开的调度和计算组织，不是性能等级。GPU SIMT/wavefront、systolic、Cube、\n"
                   "SPMD 和静态空间调度都跨越一种以上用途；执行模型的主要分界首先对应厂商架构路线。",
                   font(21), MUTED, spacing=9)
    return save(img, "02_Core执行模型与用途定位.png")


def figure_core_balance():
    """Plot only strictly comparable within-SKU matrix/non-matrix peaks."""
    by_short = {q["short"]: q for q in ROWS}
    families = []
    grouped = defaultdict(list)
    for item in CORE_BALANCE_RECORDS:
        family = item["family"]
        if family not in grouped:
            families.append(family)
        grouped[family].append(item)

    W, H = 2400, 1820
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "同精度矩阵与非矩阵理论峰值配比",
           "n=13 SKU；比值=同一 SKU、同一精度、dense 矩阵峰值 ÷ 向量/non-Tensor 峰值。不可比的 23 个产品不伪造数值。", W)

    x0, x1 = 790, 2130
    plot_top, plot_bottom = 350, 1410
    for tick in (0, 4, 8, 12, 16, 20):
        x = x0 + (x1 - x0) * tick / 20
        draw.line((x, plot_top, x, plot_bottom), fill=GRID, width=1)
        draw_text(draw, (x, plot_bottom + 18), f"{tick}×", font(20), MUTED, anchor="ma")
    draw.line((x0, plot_top, x0, plot_bottom), fill="#9CA6B2", width=2)

    row_y = 382
    family_bounds = {}
    for family in families:
        items = grouped[family]
        start_y = row_y
        for item in items:
            q = by_short[item["short"]]
            ratio = item["matrix"] / item["nonmatrix"]
            draw_text(draw, (360, row_y), item["short"], font(22), TEXT, anchor="lm")
            draw_text(draw, (625, row_y), item["precision"], font(18), MUTED, anchor="lm")
            x = x0 + (x1 - x0) * min(ratio, 20) / 20
            draw.line((x0, row_y, x, row_y), fill="#C9D0D8", width=4)
            shape(draw, x, row_y, "circle", PALETTE[q["position_group"]], radius=12,
                  outline=PALETTE[q["position_group"]] if item["evidence"] == "proxy" else WHITE,
                  width=3, hollow=item["evidence"] == "proxy")
            draw_text(draw, (x + 24, row_y), f"{ratio:.1f}×", font(20), TEXT, anchor="lm")
            row_y += 58
        family_bounds[family] = (start_y, row_y - 58)
        mid_y = (start_y + row_y - 58) / 2
        draw_text(draw, (105, mid_y), family, font(21), MUTED, anchor="lm")
        draw.line((90, row_y - 25, W - 90, row_y - 25), fill="#EEF1F4", width=1)
        row_y += 28

    # Only connect exact same-ratio family comparisons.  A sloped connector
    # would imply an ordered generation trend and would overstate these data.
    for family, (start_y, end_y) in family_bounds.items():
        if start_y == end_y:
            continue
        values = [item["matrix"] / item["nonmatrix"] for item in grouped[family]]
        if max(values) - min(values) < 1e-9:
            x = x0 + (x1 - x0) * min(values[0], 20) / 20
            draw.line((x, start_y, x, end_y), fill="#89939E", width=2)

    legend_position(draw, 110, 1510)
    shape(draw, 980, 1525, "circle", "#4B5563", radius=11, outline=WHITE, width=3)
    draw_text(draw, (1005, 1525), "直接向量峰值", font(19), MUTED, anchor="lm")
    shape(draw, 1280, 1525, "circle", "#4B5563", radius=11, outline="#4B5563", width=3, hollow=True)
    draw_text(draw, (1305, 1525), "NVIDIA non-Tensor 代理值", font(19), MUTED, anchor="lm")
    draw_multiline(draw, (980, 1580),
                   "精度按各家可严格匹配的公开路径选择，因此该图只比较产品内资源倾斜，不比较绝对算力。\n"
                   "物理单元数 M:V:S 另行统计，不与吞吐比混用。",
                   font(19), MUTED, spacing=8)
    return save(img, "03_Core矩阵与非矩阵吞吐配比.png")


def figure_complete_mvs_balance():
    by_short = {q["short"]: q for q in ROWS}
    W, H = 2300, 1080
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "完整同精度矩阵、向量与标量吞吐配比",
           "n=4 SKU；均为每 Core FP32 理论峰值，并归一到 Vector=1。只有 AWS NeuronCore 公开了可对齐的三条路径。", W)
    x0, x1 = 680, 1980
    top, row_h = 350, 125
    for tick in (0, 5, 10, 15, 20):
        x = x0 + (x1-x0) * tick / 22
        draw.line((x, 295, x, 800), fill=GRID, width=1)
        draw_text(draw, (x, 825), f"{tick}×", font(19), MUTED, anchor="ma")
    for i, item in enumerate(CORE_MVS_THROUGHPUT_RECORDS):
        q = by_short[item["short"]]
        y = top + i * row_h
        ratios = [item["matrix"] / item["vector"], 1.0, item["scalar"] / item["vector"]]
        xs = [x0 + (x1-x0) * value / 22 for value in ratios]
        draw_text(draw, (105, y-12), item["short"], font(24), PALETTE[q["position_group"]], anchor="lm")
        draw_text(draw, (105, y+23), item["family"], font(18), MUTED, anchor="lm")
        draw.line((min(xs), y, max(xs), y), fill="#C9D0D8", width=4)
        for x, kind, label, value, yoff, label_y in zip(
            xs, ("circle", "square", "diamond"), ("M", "V", "S"), ratios,
            (0, 8, -8), (-25, 34, -34),
        ):
            shape(draw, x, y+yoff, kind, PALETTE[q["position_group"]], radius=11, outline=WHITE, width=3)
            draw_text(draw, (x, y+label_y), f"{label} {value:.2f}", font(17), TEXT, anchor="ma")
        draw.line((80, y+58, W-80, y+58), fill="#EEF1F4", width=1)
    legend_position(draw, 110, 900)
    for x, kind, label in ((830, "circle", "Matrix"), (1030, "square", "Vector"), (1230, "diamond", "Scalar")):
        shape(draw, x, 914, kind, "#596574", radius=10)
        draw_text(draw, (x+24, 914), label, font(18), MUTED, anchor="lm")
    draw_text(draw, (1510, 914), "Trainium1 与 Inferentia2 三路配比完全相同。", font(19), MUTED, anchor="lm")
    return save(img, "03_Core完整矩阵向量标量吞吐配比.png")


def figure_precision_accumulation():
    columns = [
        ("FP64", "precision_fp64"), ("FP32/TF32 输入", "precision_fp32_tf32"),
        ("BF16", "precision_bf16"), ("FP16", "precision_fp16"),
        ("8-bit float", "precision_fp8_family"), ("FP6", "precision_fp6_family"),
        ("FP4", "precision_fp4_family"), ("INT8", "precision_int8"),
        ("INT4", "precision_int4"),
    ]
    ordered = sorted(ROWS, key=lambda q: (q["vendor"], (TRAIN, INFER, UNIFIED).index(q["position_group"]), q["short"]))
    W, H = 2700, 2360
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "数值精度支持与累加路径",
           "n=36；圆点只表示资料卡存在明确硬件支持证据。空白表示未见公开支持，不能解释为硬件不支持。", W)
    left, top, row_h, col_w = 420, 370, 45, 145
    for j, (label, key) in enumerate(columns):
        x = left + j * col_w
        counts = Counter(q["position_group"] for q in ROWS if q[key] == "公开支持")
        draw_text(draw, (x, 270), label, font(20), TEXT, anchor="ma")
        draw_text(draw, (x, 307), f"n={sum(counts.values())}", font(17), MUTED, anchor="ma")
    acc_x = left + len(columns) * col_w + 80
    draw_text(draw, (acc_x, 270), "累加路径证据", font(22), TEXT, anchor="lm")
    last_vendor = None
    for i, q in enumerate(ordered):
        y = top + i * row_h
        if q["vendor"] != last_vendor:
            draw.line((90, y-24, W-90, y-24), fill="#AEB7C1", width=2)
            last_vendor = q["vendor"]
        if i % 2:
            draw.rectangle((90, y-21, W-90, y+21), fill="#FAFBFC")
        draw_text(draw, (105, y), q["vendor"], font(17), MUTED, anchor="lm")
        draw_text(draw, (235, y), q["short"], font(19), PALETTE[q["position_group"]], anchor="lm")
        for j, (_, key) in enumerate(columns):
            x = left + j * col_w
            if q[key] == "公开支持":
                shape(draw, x, y, "circle", PALETTE[q["position_group"]], radius=9, outline=WHITE)
            else:
                draw.ellipse((x-4, y-4, x+4, y+4), fill="#E5E9EE")
        acc = q["accumulation_evidence"]
        if acc == "明确 accumulator 类型":
            acc_label, acc_color = "accumulator", "#374151"
        elif acc == "只公开 C/D 或 destination 类型":
            acc_label, acc_color = "C/D·dest", "#586472"
        elif acc == "只说明宽累加":
            acc_label, acc_color = "宽累加", "#6F7B86"
        elif acc == "数值与累加路径未公开":
            acc_label, acc_color = "数值未公开", "#B8C0C8"
        else:
            acc_label, acc_color = "累加未公开", "#87929F"
        draw.rounded_rectangle((acc_x, y-14, acc_x+145, y+14), radius=7, fill=acc_color)
        draw_text(draw, (acc_x+72, y), acc_label, font(15), WHITE, anchor="mm")
    legend_position(draw, 110, 2070)
    draw_multiline(draw, (800, 2080),
                   "8-bit float 合并 FP8、cFP8、BF8、HiF8、\nMXFP8/OCP-FP8 等公开家族。\n"
                   "FP4 同理合并 NVFP4/MXFP4。\n\n"
                   "精度支持、峰值大小和累加语义是三件事；\n本图不使用峰值 TFLOPS。",
                   font(20), MUTED, spacing=10)
    return save(img, "03_Core数值精度与累加.png")


def figure_special_units():
    columns = [
        ("结构化稀疏", "structured_sparsity_status"),
        ("Sparse/embedding", "special_sparse_embedding"),
        ("跨设备 collective", "special_cross_collective"),
        ("片内 reduction", "special_onchip_reduction"),
        ("专用搬运", "special_data_movement"),
        ("特殊数学", "special_math"),
        ("媒体/图形", "special_media_graphics"),
    ]
    ordered = sorted(ROWS, key=lambda q: (q["vendor"], (TRAIN, INFER, UNIFIED).index(q["position_group"]), q["short"]))
    W, H = 2260, 2280
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "稀疏与专用硬件机制",
           "n=36；按公开物理单元、数据通路或专用指令归类。灰点表示未见公开证据，叉号仅表示厂商明确不采用。", W)
    left, top, row_h, col_w = 500, 370, 45, 205
    for j, (label, key) in enumerate(columns):
        x = left + j * col_w
        if key == "structured_sparsity_status":
            n = sum(q[key] == "公开支持" for q in ROWS)
        else:
            n = sum(q[key] == "公开" for q in ROWS)
        draw_text(draw, (x, 270), label, font(19), TEXT, anchor="ma")
        draw_text(draw, (x, 307), f"公开 n={n}", font(16), MUTED, anchor="ma")
    last_vendor = None
    for i, q in enumerate(ordered):
        y = top + i * row_h
        if q["vendor"] != last_vendor:
            draw.line((90, y-24, W-90, y-24), fill="#AEB7C1", width=2)
            last_vendor = q["vendor"]
        if i % 2:
            draw.rectangle((90, y-21, W-90, y+21), fill="#FAFBFC")
        draw_text(draw, (105, y), q["vendor"], font(17), MUTED, anchor="lm")
        draw_text(draw, (235, y), q["short"], font(19), PALETTE[q["position_group"]], anchor="lm")
        for j, (_, key) in enumerate(columns):
            x = left + j * col_w
            value = q[key]
            supported = value in ("公开", "公开支持")
            if supported:
                shape(draw, x, y, "square", PALETTE[q["position_group"]], radius=9)
            elif value == "明确不采用":
                draw.line((x-8, y-8, x+8, y+8), fill="#6B7280", width=3)
                draw.line((x-8, y+8, x+8, y-8), fill="#6B7280", width=3)
            else:
                draw.ellipse((x-4, y-4, x+4, y+4), fill="#E5E9EE")
    draw_multiline(draw, (110, 2040),
                   "SparseCore 与结构化稀疏分列：前者是稀疏/embedding 处理引擎，后者是矩阵数据通路的稀疏加速。\n"
                   "CAE 只计入片内 reduction；外部 NVSwitch/网络软件不计作芯片 collective 硬件。披露强度不同，灰点不能作反证。",
                   font(20), MUTED, spacing=8)
    legend_position(draw, 1760, 2035)
    return save(img, "04_Core稀疏与专用机制.png")


def figure_onchip_storage_pairs():
    pairs = [
        ("TPU 8 系列 Vmem", [("TPU 8t", 128, "MB"), ("TPU 8i", 384, "MB")], "同层级；8i 为 3×"),
        ("NeuronCore-v2 SBUF / Core", [("Trainium1", 24, "MiB"), ("Inferentia2", 24, "MiB")], "同 Core 与资源组织；相同"),
        ("CDNA 4 Infinity Cache", [("MI350P", 128, "MB"), ("MI350X", 256, "MB")], "XCD、CU、HBM 与形态同时翻倍"),
        ("Hopper 每 SM L1/shared", [("H200 SXM", 256, "KB"), ("H200 NVL", 256, "KB")], "同 die/Core；总 L2 的 NVL 值未公开"),
    ]
    by_short = {q["short"]: q for q in ROWS}
    W, H = 2400, 1320
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "片上存储的同层级家族对照",
           "只比较物理层级和作用域相同的容量；每组按本组最大值归一化，组间条长不能互相比大小。", W)
    top, group_h = 310, 225
    bar_x0, bar_x1 = 790, 1820
    for i, (title, items, note) in enumerate(pairs):
        y0 = top + i * group_h
        draw_text(draw, (105, y0+40), title, font(26), TEXT, anchor="lm")
        draw_text(draw, (105, y0+79), note, font(19), MUTED, anchor="lm")
        max_v = max(v for _, v, _ in items)
        for j, (short, value, unit) in enumerate(items):
            q = by_short[short]
            y = y0 + j * 66
            width = value / max_v * (bar_x1 - bar_x0)
            draw_text(draw, (620, y), short, font(21), TEXT, anchor="rm")
            draw.rounded_rectangle((bar_x0, y-16, bar_x0+width, y+16), radius=7,
                                   fill=PALETTE[q["position_group"]], outline=WHITE, width=2)
            draw_text(draw, (bar_x0+width+18, y), f"{value:g} {unit}", font(20), TEXT, anchor="lm")
        draw.line((100, y0+177, W-100, y0+177), fill=GRID, width=1)
    legend_position(draw, 1940, 330)
    draw_multiline(draw, (1940, 540),
                   "其余产品的 register、L1/L2、\nscratchpad、SBUF、PSUM、Vmem、\nInfinity Cache 与整片 SRAM 层级不同，\n原始值保留在全量附录，不强行求均值。",
                   font(19), MUTED, spacing=8)
    return save(img, "05_片上存储同层级家族对照.png")


def figure_data_management():
    categories = [
        "硬件 cache + 显式 local/shared memory",
        "编译器/软件管理 local store + 显式搬运",
        "local store 存在，管理语义未公开",
        "静态编译路由的共享 SRAM/stream",
        "证据不足",
    ]
    W, H = 2400, 1240
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "片上数据管理模型与用途定位",
           "n=36；分类依据是 cache/local store 的管理语义与搬运方式，不把 register、cache、scratchpad 和整片 SRAM 相加。", W)
    x0, x1 = 770, 1740
    top, row_h = 330, 132
    max_n = max(sum(q["data_management_class"] == c for q in ROWS) for c in categories)
    for i, category in enumerate(categories):
        y = top + i * row_h
        members = [q for q in ROWS if q["data_management_class"] == category]
        draw_multiline(draw, (105, y-17), category, font(23), TEXT, spacing=5, anchor="lm")
        cursor = x0
        for role in (TRAIN, INFER, UNIFIED):
            n = sum(q["position_group"] == role for q in members)
            if not n:
                continue
            width = n / max_n * (x1 - x0)
            draw.rounded_rectangle((cursor, y-22, cursor+width, y+22), radius=7,
                                   fill=PALETTE[role], outline=WHITE, width=2)
            if width > 42:
                draw_text(draw, (cursor+width/2, y), n, font(20), WHITE, anchor="mm")
            cursor += width
        vendors = "、".join(f"{v} {n}" for v, n in Counter(q["vendor"] for q in members).most_common())
        draw_text(draw, (1810, y), vendors or "—", font(18), MUTED, anchor="lm")
        draw.line((x0, y+56, W-90, y+56), fill="#EEF1F4", width=1)
    legend_position(draw, 110, 1020)
    draw_multiline(draw, (790, 1020),
                   "同一种管理模型跨训练、推理和共用产品出现；类别与厂商架构路线高度重合。\n"
                   "‘管理语义未公开’与‘证据不足’是公开证据状态，不能解释为没有 local memory。",
                   font(20), MUTED, spacing=8)
    return save(img, "05_片上数据管理模型与用途定位.png")


def figure_die_organization():
    categories = [
        "单逻辑计算 die",
        "一颗计算 die + 辅助 die",
        "多计算 die/chiplet",
        "物理组织不足",
    ]
    groups = {c: [q for q in ROWS if q["compute_die_organization"] == c] for c in categories}
    W, H = 2800, 1690
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "计算 die/chiplet 组织与厂商用途定位",
           "n=36；HBM stack 不计作计算 die；I/O、SerDes 等辅助 die 单列，避免把‘一颗计算 die’误写成单 die package。", W)
    col_left = [70, 750, 1430, 2110]
    col_w = 610
    for j, category in enumerate(categories):
        x0 = col_left[j]
        members = groups[category]
        counts = Counter(q["position_group"] for q in members)
        draw.rounded_rectangle((x0, 250, x0+col_w, 350), radius=10, fill="#F5F7F9")
        draw_text(draw, (x0+24, 270), category, font(23), TEXT)
        draw_text(draw, (x0+24, 312),
                  f"n={len(members)}；训练 {counts[TRAIN]} / 推理 {counts[INFER]} / 共用 {counts[UNIFIED]}",
                  font(19), MUTED)
        ordered = sorted(members, key=lambda q: ((TRAIN, INFER, UNIFIED).index(q["position_group"]), q["vendor"], q["short"]))
        y = 405
        for i, q in enumerate(ordered):
            if i % 2:
                draw.rounded_rectangle((x0, y-19, x0+col_w, y+30), radius=5, fill="#FAFBFC")
            shape(draw, x0+20, y, "circle", PALETTE[q["position_group"]], radius=8)
            draw_text(draw, (x0+40, y), f"{q['vendor']}  {q['short']}", font(18), TEXT, anchor="lm")
            year = "年份未公开" if q["release_year"] is None else str(q["release_year"])
            draw_text(draw, (x0+col_w-15, y), year, font(18), MUTED, anchor="rm")
            y += 55
    legend_position(draw, 110, 1440)
    draw_multiline(draw, (890, 1450),
                   "‘物理组织不足’不等于单 die。TPU 8t 与 Ascend 910 都只有一颗主要计算 die，但 package 还含 SerDes 或 I/O die，\n"
                   "因此单列为‘一颗计算 die + 辅助 die’。10 个多计算 die 产品只来自 NVIDIA、Google 和 AMD。",
                   font(20), MUTED, spacing=8)
    return save(img, "06_Die封装组织与用途定位.png")


def figure_process_year():
    data = sorted(
        [q for q in ROWS if q["compute_process_nm"] is not None and q["release_year"] is not None],
        key=lambda q: (q["release_year"], -q["compute_process_nm"], q["vendor"], q["short"]),
    )
    W, H = 2400, 1680
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "主计算 die 工艺节点与首次公开年份",
           f"n={len(data)}；横向位置是等距类别，不是线性物理尺度。节点取资料卡明确对应主计算 die/XCD 的名义值。", W)
    left, right, top, row_h = 580, 1900, 305, 55
    nodes = (2, 3, 4, 5, 7, 12, 14)
    node_x = {node: left + i/(len(nodes)-1)*(right-left) for i, node in enumerate(nodes)}
    for node in nodes:
        x = node_x[node]
        draw.line((x, top-35, x, top+len(data)*row_h), fill=GRID, width=1)
        draw_text(draw, (x, top-70), f"{node} nm", font(20), MUTED, anchor="ma")
    last_year = None
    for i, q in enumerate(data):
        y = top + i * row_h
        if q["release_year"] != last_year:
            draw.line((90, y-26, W-90, y-26), fill="#AEB7C1", width=2)
            last_year = q["release_year"]
        if i % 2:
            draw.rectangle((90, y-24, W-90, y+24), fill="#FAFBFC")
        draw_text(draw, (105, y), q["release_year"], font(18), MUTED, anchor="lm")
        draw_text(draw, (205, y), f"{q['vendor']}  {q['short']}", font(20), TEXT, anchor="lm")
        x = node_x[q["compute_process_nm"]]
        shape(draw, x, y, "circle", PALETTE[q["position_group"]],
              radius=10, hollow=q["availability_status"] != "当前产品/公开配置")
        draw_text(draw, (right+45, y), q["compute_die_organization"].replace("计算 die/chiplet 已确认", "计算 die"),
                  font(18), MUTED, anchor="lm")
    draw_multiline(draw, (105, 1515),
                   "列表按年份排列。12/14 nm 样本集中在 2018–2020 年，4/3/2 nm 样本集中在 2022 年以后；\n"
                   "同一个 4 nm GH100 又同时进入推理主定位与训推共用产品。因此工艺分布首先受年代和共享 die 混杂。",
                   font(21), MUTED, spacing=8)
    legend_position(draw, 1930, 1420)
    return save(img, "07_工艺节点与发布时间.png")


def figure_ras_evidence():
    categories = [
        "公开具体芯片/package RAS 机制",
        "仅公开 RAS Engine 名称",
        "核心 RAS 机制未公开",
        "只有管理、安全或系统层线索",
        "资料卡未单列",
    ]
    W, H = 2400, 1190
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "芯片与 package RAS 的公开证据够不够比较用途",
           "n=36；只把 ECC、SDC、检测、重放、隔离、修复或降级等芯片/package 机制计为有效证据。", W)
    x0, x1 = 760, 1770
    top, row_h = 335, 135
    max_n = max(sum(q["ras_evidence_class"] == c for q in ROWS) for c in categories)
    for i, category in enumerate(categories):
        y = top + i * row_h
        members = [q for q in ROWS if q["ras_evidence_class"] == category]
        draw_text(draw, (105, y), category, font(24), TEXT, anchor="lm")
        cursor = x0
        for role in (TRAIN, INFER, UNIFIED):
            n = sum(q["position_group"] == role for q in members)
            if not n:
                continue
            width = n / max_n * (x1 - x0)
            draw.rounded_rectangle((cursor, y-22, cursor+width, y+22), radius=7,
                                   fill=PALETTE[role], outline=WHITE, width=2)
            if width > 42:
                draw_text(draw, (cursor+width/2, y), n, font(20), WHITE, anchor="mm")
            cursor += width
        draw_text(draw, (1830, y), f"n={len(members)}", font(21), MUTED, anchor="lm")
        draw.line((x0, y+58, W-90, y+58), fill="#EEF1F4", width=1)
    legend_position(draw, 110, 1030)
    draw_text(draw, (790, 1042),
              "训练主定位中没有一款达到‘公开具体 RAS 机制’这一证据层级；图反映披露缺口，不代表训练芯片缺少 RAS。",
              font(20), MUTED, anchor="lm")
    return save(img, "07_RAS公开证据层级.png")


def figure_memory():
    data = [q for q in ROWS if q["memory_domain"] == "外部DRAM" and q["memory_capacity_gb"] is not None and q["memory_bandwidth_tbps"] is not None]
    W, H = 2200, 1500
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "外部 DRAM 容量与带宽", f"n={len(data)}；每个点是一款 SKU/per-chip 配置。颜色按厂商定位，形状按内存类型；坐标均为对数。", W)
    plot = (180, 275, 1640, 1250)
    xlo, xhi, ylo, yhi = 6, 520, 0.04, 30
    layer, pos = draw_axes_log(draw, plot, [8,16,32,64,128,256,512], [0.05,0.1,0.3,1,3,10,30],
                               "外部 DRAM 容量（十进制 GB）", "带宽（十进制 TB/s）", xlo,xhi,ylo,yhi)
    img.alpha_composite(layer, pos)
    left, top, right, bottom = plot
    points = []
    duplicate_count = defaultdict(int)
    for q in data:
        key = (q["memory_capacity_gb"], q["memory_bandwidth_tbps"])
        ndup = duplicate_count[key]
        duplicate_count[key] += 1
        x = log_map(q["memory_capacity_gb"], xlo,xhi,left,right) + (ndup%3-1)*5
        y = log_map(q["memory_bandwidth_tbps"], ylo,yhi,bottom,top) + (ndup//3)*5
        points.append({"x":x,"y":y,"row":q})
    point_by_short = {p["row"]["short"]: p for p in points}
    for family in sorted({q["comparable_family"] for q in data if q["comparable_family"]}):
        members = [q for q in data if q["comparable_family"] == family]
        if len(members) != 2:
            continue
        a, b = (point_by_short[q["short"]] for q in members)
        draw.line((a["x"], a["y"], b["x"], b["y"]), fill="#9AA5B1", width=3)
    for p in points:
        q=p["row"]
        shape(draw,p["x"],p["y"],memory_marker(q["memory_type"]),PALETTE[q["position_group"]],radius=11,
              hollow=q["availability_status"] != "当前产品/公开配置")
    chosen={"Inferentia1","L4","L40S","TPU v5e","TPU v5p","TPU v6e","TPU 8t","TPU 8i",
            "Trainium1","Inferentia2","A100","H100 NVL","B300",
            "MI350P","MI355X","MI455X","Atlas A2 64","Ascend 950PR","Ascend 950DT"}
    place_labels(draw, points, (left+5, top+5, right-5, bottom-5), font(19), label_all=False, chosen=chosen)
    y = legend_position(draw, 1710, 305)
    draw_text(draw, (1710, y+10), "内存类型", font(27), TEXT)
    for kind, label in [("circle","HBM"),("square","GDDR"),("diamond","DDR/LPDDR")]:
        y += 43
        shape(draw,1722,y+8,kind,"#87929F",radius=9)
        draw_text(draw,(1745,y-2),label,font(22),TEXT)
    draw_multiline(draw,(1710,y+95),"灰线连接预先定义的同厂商可比家族。\n数值轴统一为十进制 GB、TB/s；明确\nGiB 已换算。空心点表示 roadmap target\n或最大公开配置。",font(21),MUTED,spacing=9)
    return save(img, "08_DRAM容量与带宽.png")


def figure_compute_balance():
    data = [q for q in ROWS if q["memory_domain"] == "外部DRAM" and q["memory_bandwidth_tbps"] is not None and q["bf16_fp16_peak_condition"] in ("明确 dense/base", "厂商未完整说明 dense/sparse 或计数条件")]
    W,H=2200,1500
    img=Image.new("RGBA",(W,H),WHITE)
    draw=ImageDraw.Draw(img,"RGBA")
    header(draw,"公开 BF16/FP16 矩阵峰值与外部 DRAM 带宽",
           f"n={len(data)}；实心点为明确 dense/base，空心点的 dense/sparse 或计数条件未完整公开。斜线是铭牌峰值/带宽比。",W)
    plot=(180,275,1640,1250)
    xlo,xhi,ylo,yhi=0.04,30,50,7000
    layer,pos=draw_axes_log(draw,plot,[0.05,0.1,0.3,1,3,10,30],[50,100,300,1000,3000,7000],
                            "外部 DRAM 带宽（十进制 TB/s）","公开 BF16/FP16 矩阵峰值（TFLOPS）",xlo,xhi,ylo,yhi)
    img.alpha_composite(layer,pos)
    left,top,right,bottom=plot
    for ratio in [100,200,400,800,1600]:
        vals=[]
        for xv in [xlo,xhi]:
            yv=ratio*xv
            if ylo<=yv<=yhi: vals.append((xv,yv))
        # Intersections with horizontal bounds.
        for yv in [ylo,yhi]:
            xv=yv/ratio
            if xlo<=xv<=xhi: vals.append((xv,yv))
        if len(vals)>=2:
            vals=sorted(vals)
            (xa,ya),(xb,yb)=vals[0],vals[-1]
            x1=log_map(xa,xlo,xhi,left,right); y1=log_map(ya,ylo,yhi,bottom,top)
            x2=log_map(xb,xlo,xhi,left,right); y2=log_map(yb,ylo,yhi,bottom,top)
            draw.line((x1,y1,x2,y2),fill="#B8C0C8",width=2)
            lx,ly=x2-8,y2+4
            draw_text(draw,(lx,ly),f"{ratio}",font(18),MUTED,anchor="ra")
    points=[]; dup=defaultdict(int)
    for q in data:
        key=(q["memory_bandwidth_tbps"],q["advertised_bf16_fp16_peak_tflops"]); ndup=dup[key]; dup[key]+=1
        x=log_map(q["memory_bandwidth_tbps"],xlo,xhi,left,right)+(ndup%3-1)*6
        y=log_map(q["advertised_bf16_fp16_peak_tflops"],ylo,yhi,bottom,top)+(ndup//3)*6
        points.append({"x":x,"y":y,"row":q})
    point_by_short = {p["row"]["short"]: p for p in points}
    for family in sorted({q["comparable_family"] for q in data if q["comparable_family"]}):
        members = [q for q in data if q["comparable_family"] == family]
        if len(members) != 2:
            continue
        if members[0]["advertised_peak_precision"] != members[1]["advertised_peak_precision"]:
            continue
        a, b = (point_by_short[q["short"]] for q in members)
        draw.line((a["x"], a["y"], b["x"], b["y"]), fill="#9AA5B1", width=3)
    for p in points:
        q=p["row"]
        shape(draw,p["x"],p["y"],memory_marker(q["memory_type"]),PALETTE[q["position_group"]],radius=12,
              hollow=q["bf16_fp16_peak_condition"] != "明确 dense/base")
    # Keep the complete numeric sample in the plot, but label only the strict
    # family contrasts and boundary points.  Dense labelling of all 22 points
    # obscures the data in the crowded upper-right region; exact values remain
    # in the appendix and CSV.
    chosen={"Inferentia1","Trainium1","Inferentia2","TPU v5e","TPU v5p","TPU v6e",
            "L4","A100","H100 PCIe","MI350P","B300","MI455X"}
    place_labels(draw,points,(left+5,top+5,right-5,bottom-5),font(20),label_all=False,chosen=chosen)
    y=legend_position(draw,1710,305)
    draw_text(draw, (1710, y+20), "内存类型", font(24), TEXT)
    y += 42
    for kind, label in (("circle","HBM"),("square","GDDR"),("diamond","DDR/LPDDR")):
        y += 40
        shape(draw,1722,y+8,kind,"#87929F",radius=8)
        draw_text(draw,(1745,y),label,font(19),TEXT)
    draw_multiline(draw,(1710,y+60),"实心：厂商明确 dense/base，n=15。\n空心：有 BF16/FP16 铭牌值，但厂商\n未完整说明 dense/sparse 或计数规则，n=7。\n\n图用于查点位与家族内重合，不做训练、\n推理组间统计，也不等同 sustained 性能。",font(20),MUTED,spacing=9)
    return save(img,"09_铭牌存算比.png")


def figure_memory_resource_ratios():
    data = [q for q in ROWS
            if q["peak_per_memory_bandwidth_tflops_per_tbps"] is not None
            and q["memory_capacity_per_peak_gb_per_tflops"] is not None]
    W, H = 2200, 1500
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "外存带宽与容量相对同精度铭牌算力",
           f"n={len(data)}；横轴 P/B，纵轴 C/P。实心为明确 dense/base；空心为 dense/sparse 或计数条件不完整。", W)
    plot = (190, 285, 1640, 1250)
    xlo, xhi, ylo, yhi = 50, 1400, 0.015, 1.2
    layer, pos = draw_axes_log(
        draw, plot, [50, 100, 200, 400, 800, 1200], [0.02, 0.05, 0.1, 0.2, 0.5, 1.0],
        "P/B：BF16/FP16 铭牌峰值 / 外存带宽（TFLOPS/(TB/s)）",
        "C/P：外存容量 / 同精度铭牌峰值（GB/TFLOP）",
        xlo, xhi, ylo, yhi,
    )
    img.alpha_composite(layer, pos)
    left, top, right, bottom = plot
    points = []
    duplicate_count = defaultdict(int)
    for q in data:
        xv = q["peak_per_memory_bandwidth_tflops_per_tbps"]
        yv = q["memory_capacity_per_peak_gb_per_tflops"]
        key = (round(xv, 6), round(yv, 6))
        ndup = duplicate_count[key]
        duplicate_count[key] += 1
        x = log_map(xv, xlo, xhi, left, right) + (ndup % 3 - 1) * 6
        y = log_map(yv, ylo, yhi, bottom, top) + (ndup // 3) * 6
        points.append({"x": x, "y": y, "row": q})
    point_by_short = {p["row"]["short"]: p for p in points}
    for family in sorted({q["comparable_family"] for q in data if q["comparable_family"]}):
        members = [q for q in data if q["comparable_family"] == family]
        if len(members) != 2 or members[0]["advertised_peak_precision"] != members[1]["advertised_peak_precision"]:
            continue
        a, b = (point_by_short[q["short"]] for q in members)
        draw.line((a["x"], a["y"], b["x"], b["y"]), fill="#9AA5B1", width=3)
    for p in points:
        q = p["row"]
        shape(draw, p["x"], p["y"], memory_marker(q["memory_type"]), PALETTE[q["position_group"]],
              radius=12, hollow=q["nameplate_ratio_evidence"] != "同精度且明确 dense/base")
    chosen = {"Inferentia1", "Trainium1", "Inferentia2", "TPU v5e", "TPU v5p", "TPU v6e",
              "L4", "A100", "MI350P", "MI455X", "B300"}
    place_labels(draw, points, (left+5, top+5, right-5, bottom-5), font(19), label_all=False, chosen=chosen)
    legend_position(draw, 1705, 320)
    draw_multiline(draw, (1705, 590),
                   "B/P 是 P/B 的倒数，已经写入 CSV，\n不作为第二个独立信号重复统计。\n\n"
                   "严格样本 n=15，仍没有训练主定位；\n空心点只用于显示数据位置。C/P 和 P/B\n都是铭牌资源比，不代表实际 operational intensity。",
                   font(20), MUTED, spacing=9)
    return save(img, "09_外存容量与带宽相对铭牌算力.png")


def figure_power():
    data=[q for q in ROWS if q["power_w"] is not None]
    categories = ["边缘 SoC", "低功耗 PCIe", "标准 PCIe", "云内芯片", "高密度数据中心", "其他或未公开"]
    W,H=2400,1500
    img=Image.new("RGBA",(W,H),WHITE)
    draw=ImageDraw.Draw(img,"RGBA")
    header(draw,"单设备功耗与部署形态",
           f"n={len(data)}；横轴按部署类别分组，纵轴为公开功耗。空心点是 fleet average，其余保留 TDP/TBP/maximum 原口径。",W)
    plot=(180,285,2210,1240)
    left,top,right,bottom=plot
    ylo,yhi=5,1700
    draw.rectangle(plot,fill=WHITE,outline=GRID,width=2)
    for v in [8,20,50,100,200,500,1000,1600]:
        y=log_map(v,ylo,yhi,bottom,top)
        draw.line((left,y,right,y),fill=GRID,width=1)
        draw_text(draw,(left-18,y),nice_num(v),font(22),MUTED,anchor="rm")
    centers={c:left+(i+.5)*(right-left)/len(categories) for i,c in enumerate(categories)}
    for c,x in centers.items():
        draw.line((x,top,x,bottom),fill="#EEF1F4",width=1)
        draw_text(draw,(x,bottom+28),c,font(20),TEXT,anchor="ma")
    draw_text(draw,(left,top-48),"公开功耗（W，对数坐标）",font(24),TEXT)
    points=[]
    for category in categories:
        items=[q for q in data if q["deployment_class"]==category]
        items=sorted(items,key=lambda q:(q["position_group"],q["power_w"],q["short"]))
        offsets=np.linspace(-125,125,len(items)) if len(items)>1 else [0]
        for offset,q in zip(offsets,items):
            x=centers[category]+float(offset)
            y=log_map(q["power_w"],ylo,yhi,bottom,top)
            points.append({"x":x,"y":y,"row":q})
    for p in points:
        q=p["row"]
        hollow="fleet" in q["power_basis"]
        shape(draw,p["x"],p["y"],"circle",PALETTE[q["position_group"]],radius=11,hollow=hollow,width=3)
    chosen={"Ascend 310","L4","H100 NVL","L40S",
            "TPU v5e","TPU v5p","TPU v6e","H100 SXM","B300","MI355X",
            "Ascend 910","GroqChip"}
    place_labels(draw,points,(left+5,top+5,right-5,bottom-5),font(20),label_all=False,chosen=chosen)
    legend_position(draw,180,1320)
    draw_multiline(draw,(1040,1325),"功耗口径不同，图只比较分布范围和部署混杂，不做能效排名或统一回归。",font(20),MUTED)
    return save(img,"10_功耗与部署形态.png")


def figure_device_endpoints():
    numeric = sorted(
        [q for q in ROWS if q["device_link_nominal_tbps"] is not None and q["device_link_nominal_tbps"] > 0],
        key=lambda q: (q["device_link_nominal_tbps"], q["vendor"], q["short"]),
    )
    statuses = Counter(q["device_link_evidence_class"] for q in ROWS)
    W = 2700
    H = 470 + len(numeric) * 58 + 310
    img = Image.new("RGBA", (W, H), WHITE)
    draw = ImageDraw.Draw(img, "RGBA")
    header(draw, "设备/卡端互联端点的公开名义带宽",
           f"数值样本 n={len(numeric)}；形状区分集成端点、外接 bridge、raw pin 与 EAM aggregate。payload 和持续带宽未统一。", W)
    left, right, top = 650, 1880, 315
    lo, hi = 0.25, 4.0
    for tick in (0.25, 0.5, 1.0, 2.0, 4.0):
        x = log_map(tick, lo, hi, left, right)
        draw.line((x, top-45, x, top+len(numeric)*58), fill=GRID, width=1)
        draw_text(draw, (x, top-75), nice_num(tick), font(20), MUTED, anchor="ma")
    for i, q in enumerate(numeric):
        y = top + i * 58
        if i % 2:
            draw.rectangle((90, y-25, W-90, y+25), fill="#FAFBFC")
        draw_text(draw, (105, y), q["vendor"], font(17), MUTED, anchor="lm")
        draw_text(draw, (235, y), q["short"], font(20), TEXT, anchor="lm")
        x = log_map(q["device_link_nominal_tbps"], lo, hi, left, right)
        draw.line((left, y, x, y), fill=PALETTE[q["position_group"]], width=8)
        endpoint_shapes = {"设备集成端点":"circle", "外部 bridge 配置":"diamond",
                           "raw pin aggregate":"triangle", "EAM aggregate":"square"}
        shape(draw, x, y, endpoint_shapes[q["device_endpoint_scope"]], PALETTE[q["position_group"]], radius=10)
        draw_text(draw, (right+35, y), f"{q['device_link_nominal_tbps']:g} TB/s", font(19), TEXT, anchor="lm")
    base_y = top + len(numeric)*58 + 35
    draw.line((90, base_y, W-90, base_y), fill=GRID, width=2)
    draw_text(draw, (105, base_y+42),
              "全体 36 个产品的端点证据状态：" + "；".join(f"{k} {v}" for k, v in statuses.items()),
              font(20), TEXT)
    known_direction = sum(q["device_link_direction_evidence"] == "方向已知" for q in numeric)
    draw_multiline(draw, (105, base_y+92),
                   f"{known_direction}/{len(numeric)} 个数值点能从资料卡确认双向或 per-direction 口径；剩余限制主要是 raw/payload、持续值和端点对象不统一。\n"
                   "bridge-config 不解释为裸芯片固有带宽；raw pin 和 per-EAM aggregate 也不与集成端点求均值。",
                   font(20), MUTED, spacing=8)
    y = legend_position(draw, 2200, 315)
    draw_text(draw, (2200, y+18), "端点对象", font(24), TEXT)
    for label, kind in (("设备集成端点","circle"),("外部 bridge 配置","diamond"),
                        ("raw pin aggregate","triangle"),("EAM aggregate","square")):
        y += 40
        shape(draw, 2212, y+8, kind, "#87929F", radius=8)
        draw_text(draw, (2235, y), label, font(18), TEXT)
    return save(img, "11_设备互联端点.png")


def figure_scaleup():
    data=[q for q in ROWS if q["scaleup_status"]=="公开数值工作域"]
    data=sorted(data,key=lambda q:(-q["max_scaleup_domain"],q["position_group"],q["vendor"],q["short"]))
    W,H=2400,2200
    img=Image.new("RGBA",(W,H),WHITE)
    draw=ImageDraw.Draw(img,"RGBA")
    header(draw,"最大公开单一 scale-up 工作域",
           f"数值工作域 n={len(data)}；另有明确无专用 scale-up 和工作域未公开两类，单独列在右侧，不再编码成数值 1。",W)
    left,right,top=600,1770,290
    row_h=52; bottom=top+row_h*len(data)
    xlo,xhi=1.8,12000
    for v in [2,4,8,16,64,256,1024,4096,10000]:
        x=log_map(v,xlo,xhi,left,right)
        draw.line((x,top-18,x,bottom),fill=GRID,width=1)
        draw_text(draw,(x,top-28),nice_num(v),font(22),MUTED,anchor="ma")
    scope_shape={"bridge/直连组":"diamond","服务器/NVSwitch":"square","Pod/slice":"triangle","rack/UltraServer":"circle","其他公开域":"cross"}
    for i,q in enumerate(data):
        y=top+i*row_h+row_h//2
        if i%2: draw.rectangle((90,y-row_h//2,1810,y+row_h//2),fill="#FAFBFC")
        draw_text(draw,(110,y),f"{q['vendor']}  {q['short']}",font(22),TEXT,anchor="lm")
        draw_text(draw,(540,y),q["position_group"],font(19),PALETTE[q["position_group"]],anchor="rm")
        x=log_map(q["max_scaleup_domain"],xlo,xhi,left,right)
        draw.line((left,y,x,y),fill="#C7CDD4",width=2)
        shape(draw,x,y,scope_shape[q["scaleup_scope"]],PALETTE[q["position_group"]],radius=10,
              hollow=q["availability_status"] == "roadmap target")
        label=f"{q['max_scaleup_domain']:,}"
        draw_text(draw,(min(x+18,right-3),y),label,font(21),TEXT,anchor="lm" if x<right-80 else "rm")
    draw_text(draw,((left+right)//2,bottom+60),"单一工作域内 accelerator 数（对数坐标）",font(28),TEXT,anchor="ma")
    rx=1840
    draw_text(draw,(rx,290),"没有数值工作域的产品",font(28),TEXT)
    status_groups=["明确无专用 scale-up","工作域未公开"]
    y=350
    for status in status_groups:
        members=[q for q in ROWS if q["scaleup_status"]==status]
        draw_text(draw,(rx,y),f"{status}  n={len(members)}",font(23),TEXT)
        y+=42
        for q in members:
            shape(draw,rx+10,y+8,"circle",PALETTE[q["position_group"]],radius=8)
            draw_text(draw,(rx+30,y),f"{q['vendor']}  {q['short']}",font(19),TEXT)
            y+=38
        y+=34
    draw_text(draw,(rx,y),"工作域对象",font(25),TEXT)
    y+=48
    for scope,kind in scope_shape.items():
        shape(draw,rx+10,y+8,kind,"#87929F",radius=8)
        draw_text(draw,(rx+32,y),scope,font(19),TEXT)
        y+=38
    legend_position(draw,rx,min(y+35,1750))
    return save(img,"12_ScaleUp工作域.png")


def kmeans_pp(X,k,seed):
    rng=np.random.default_rng(seed)
    centers=[X[rng.integers(len(X))]]
    for _ in range(1,k):
        d2=np.min(np.sum((X[:,None,:]-np.array(centers)[None,:,:])**2,axis=2),axis=1)
        if d2.sum()==0: centers.append(X[rng.integers(len(X))]); continue
        centers.append(X[rng.choice(len(X),p=d2/d2.sum())])
    centers=np.array(centers,float)
    labels=np.zeros(len(X),int)
    for _ in range(200):
        new_labels=np.argmin(np.sum((X[:,None,:]-centers[None,:,:])**2,axis=2),axis=1)
        new_centers=np.array([X[new_labels==j].mean(axis=0) if np.any(new_labels==j) else centers[j] for j in range(k)])
        if np.array_equal(new_labels,labels) and np.allclose(new_centers,centers): break
        labels,centers=new_labels,new_centers
    inertia=float(np.sum((X-centers[labels])**2))
    return labels,centers,inertia


def best_kmeans(X,k):
    best=None
    for seed in range(80):
        result=kmeans_pp(X,k,seed)
        if best is None or result[2]<best[2]: best=result
    return best


def silhouette(X,labels):
    D=np.sqrt(np.sum((X[:,None,:]-X[None,:,:])**2,axis=2))
    vals=[]
    for i in range(len(X)):
        same=np.where(labels==labels[i])[0]
        same=same[same!=i]
        if len(same) == 0:
            vals.append(0.0)
            continue
        a=D[i,same].mean()
        bs=[D[i,labels==g].mean() for g in set(labels) if g!=labels[i]]
        b=min(bs) if bs else 0.0
        vals.append((b-a)/max(a,b) if max(a,b)>0 else 0.0)
    return float(np.mean(vals))


def comb2(n): return n*(n-1)/2


def ari(labels_a,labels_b):
    ca=Counter(labels_a); cb=Counter(labels_b); cont=Counter(zip(labels_a,labels_b)); n=len(labels_a)
    s=sum(comb2(v) for v in cont.values()); sa=sum(comb2(v) for v in ca.values()); sb=sum(comb2(v) for v in cb.values())
    expected=sa*sb/comb2(n) if n>1 else 0; maximum=(sa+sb)/2
    return (s-expected)/(maximum-expected) if maximum!=expected else 0.0


def nmi(labels_a,labels_b):
    n=len(labels_a); ca=Counter(labels_a); cb=Counter(labels_b); cont=Counter(zip(labels_a,labels_b))
    mi=0.0
    for (a,b),v in cont.items():
        p=v/n; mi+=p*math.log(p/((ca[a]/n)*(cb[b]/n)))
    ha=-sum((v/n)*math.log(v/n) for v in ca.values()); hb=-sum((v/n)*math.log(v/n) for v in cb.values())
    return mi/math.sqrt(ha*hb) if ha and hb else 0.0


def convex_hull(points):
    pts=sorted(set((float(x),float(y)) for x,y in points))
    if len(pts)<=2: return pts
    def cross(o,a,b): return (a[0]-o[0])*(b[1]-o[1])-(a[1]-o[1])*(b[0]-o[0])
    lower=[]
    for p in pts:
        while len(lower)>=2 and cross(lower[-2],lower[-1],p)<=0: lower.pop()
        lower.append(p)
    upper=[]
    for p in reversed(pts):
        while len(upper)>=2 and cross(upper[-2],upper[-1],p)<=0: upper.pop()
        upper.append(p)
    return lower[:-1]+upper[:-1]


def cluster_analysis():
    data=[q for q in ROWS if q["memory_domain"]=="外部DRAM"
          and q["memory_capacity_gb"] is not None
          and q["memory_bandwidth_tbps"] is not None
          and q["scaleup_status"] == "公开数值工作域"
          and q["availability_status"] != "roadmap target"]
    normalized=[]
    for q in data:
        normalized.append([q["memory_capacity_gb"],q["memory_bandwidth_tbps"],q["max_scaleup_domain"]])
    raw=np.array(normalized,float)
    log=np.log10(raw)
    X=(log-log.mean(axis=0))/log.std(axis=0,ddof=0)
    scores={}
    results={}
    for k in range(2,6):
        labels,centers,inertia=best_kmeans(X,k)
        scores[k]=silhouette(X,labels); results[k]=(labels,centers,inertia)
    best_silhouette_k=max(scores,key=lambda k:(scores[k],-k))
    # Use K=3 for the main view because it is the direct, pre-declared
    # comparison against the three positioning strata.  The K=2..5 scan is
    # reported as a sensitivity check; it does not select a unique taxonomy.
    selected_k=3
    labels,centers,_=results[selected_k]
    # Stable labels ordered by increasing geometric mean of the three raw resources.
    center_raw=10**(centers*log.std(axis=0,ddof=0)+log.mean(axis=0))
    order=np.argsort(np.prod(center_raw,axis=1))
    remap={old:new for new,old in enumerate(order)}
    labels=np.array([remap[x] for x in labels]); center_raw=center_raw[order]
    pos_map={TRAIN:0,INFER:1,UNIFIED:2}
    pos_labels=np.array([pos_map[q["position_group"]] for q in data])
    ari_value=ari(labels,pos_labels)
    association_nmi={
        "用途定位": nmi(labels, pos_labels),
        "厂商": nmi(labels, [q["vendor"] for q in data]),
        "部署类别": nmi(labels, [q["deployment_class"] for q in data]),
    }
    u,s,vt=np.linalg.svd(X,full_matrices=False)
    coords=X@vt[:2].T
    explained=(s*s)/(s*s).sum()
    return data,raw,X,coords,labels,center_raw,scores,selected_k,best_silhouette_k,ari_value,association_nmi,explained


def figure_cluster(cluster):
    data,raw,X,coords,labels,centers,scores,k,best_silhouette_k,ari_value,association_nmi,explained=cluster
    W,H=2300,1520
    img=Image.new("RGBA",(W,H),WHITE)
    draw=ImageDraw.Draw(img,"RGBA")
    header(draw,"外部内存与 scale-up 资源配置聚类",
           f"n={len(data)}；输入为容量、带宽和公开数值工作域，不含用途标签，也不含“无专用 scale-up”的分类编码。展示 K={k}，silhouette={scores[k]:.2f}。",W)
    plot=(150,290,1510,1260); left,top,right,bottom=plot
    draw.rectangle(plot,fill=WHITE,outline=GRID,width=2)
    xmin,xmax=coords[:,0].min(),coords[:,0].max(); ymin,ymax=coords[:,1].min(),coords[:,1].max()
    padx=(xmax-xmin)*.12 or 1; pady=(ymax-ymin)*.12 or 1
    xmin-=padx;xmax+=padx;ymin-=pady;ymax+=pady
    def mx(v): return left+(v-xmin)/(xmax-xmin)*(right-left)
    def my(v): return bottom-(v-ymin)/(ymax-ymin)*(bottom-top)
    draw.line((mx(0),top,mx(0),bottom),fill=GRID,width=1)
    draw.line((left,my(0),right,my(0)),fill=GRID,width=1)
    cluster_colors=["#DCE7F0","#E8E0D2","#E0E8DC","#E6DCE8","#DDE6E8"]
    for g in range(k):
        pts=[(mx(coords[i,0]),my(coords[i,1])) for i in range(len(data)) if labels[i]==g]
        hull=convex_hull(pts)
        if len(hull)>=3: draw.polygon(hull,fill=cluster_colors[g],outline="#AAB4BE")
    shapes=["circle","square","triangle","diamond","circle"]
    points=[];dup=defaultdict(int)
    for i,q in enumerate(data):
        x,y=mx(coords[i,0]),my(coords[i,1]); key=(round(x),round(y)); ndup=dup[key];dup[key]+=1
        x+=(ndup%3-1)*5;y+=(ndup//3)*5
        points.append({"x":x,"y":y,"row":q,"cluster":int(labels[i])})
    for p in points:
        q=p["row"]
        shape(draw,p["x"],p["y"],shapes[p["cluster"]],PALETTE[q["position_group"]],radius=12)
    chosen={"Inferentia1","L4","L40S","Trainium1","Inferentia2","Ascend 910","TPU v4","TPU v5e","TPU v5p","TPU v6e",
            "TPU7x","TPU 8t","TPU 8i","A100","H100 NVL","B300","MI350P","MI455X","Ascend 950PR","Ascend 950DT"}
    place_labels(draw,points,(left+3,top+3,right-3,bottom-3),font(18),label_all=False,chosen=chosen)
    draw_text(draw,((left+right)//2,bottom+65),f"PC1（解释 {explained[0]*100:.0f}% 方差）",font(27),TEXT,anchor="ma")
    ylabel=f"PC2（解释 {explained[1]*100:.0f}% 方差）"
    yf=font(27); tw,th=text_size(draw,ylabel,yf)
    yl=Image.new("RGBA",(tw+40,th+34),(255,255,255,0)); yd=ImageDraw.Draw(yl)
    draw_text(yd,((tw+40)//2,(th+34)//2),ylabel,yf,TEXT,anchor="mm")
    yl=yl.rotate(90,expand=True)
    img.alpha_composite(yl,(25,int((top+bottom-yl.height)/2)))
    # Right panel: cluster centers and positioning composition.
    rx=1600; draw_text(draw,(rx,290),"各簇的几何中心与定位构成",font(30),TEXT)
    y=350
    for g in range(k):
        members=[data[i] for i in range(len(data)) if labels[i]==g]
        counts=Counter(q["position_group"] for q in members)
        shape(draw,rx+12,y+8,shapes[g],"#87929F",radius=10)
        draw_text(draw,(rx+36,y),f"簇 {g+1}  ·  n={len(members)}",font(25),TEXT)
        cap,bw,dom=centers[g]
        draw_text(draw,(rx,y+38),f"几何中心约 {cap:.0f}GB / {bw:.2f}TB/s / {dom:.0f} devices",font(20),MUTED)
        bx,by,bw_total,bh=rx,y+80,560,30
        x=bx
        for group in (TRAIN,INFER,UNIFIED):
            w=bw_total*counts[group]/len(members)
            if w>0: draw.rectangle((x,by,x+w,by+bh),fill=PALETTE[group]); x+=w
        draw.rectangle((bx,by,bx+bw_total,by+bh),outline="#AAB2BD",width=1)
        draw_text(draw,(bx+bw_total+12,by+bh/2)," / ".join(f"{counts[g]}" for g in (TRAIN,INFER,UNIFIED)),font(19),MUTED,anchor="lm")
        y+=175
    legend_position(draw,rx,min(y+10,1130))
    assoc_text="；".join(f"{name} {value:.2f}" for name,value in association_nmi.items())
    draw_multiline(draw,(rx,1310),
                   f"K=2…5 silhouette："+"，".join(f"{kk}:{scores[kk]:.2f}" for kk in sorted(scores))+"\n"
                   f"NMI：{assoc_text}；用途定位 ARI={ari_value:.2f}。\n"
                   "这些关联只描述三项资源形成的分组，不能代表完整 Core/die 架构。",
                   font(20),MUTED,spacing=8)
    return save(img,"13_资源配置聚类.png")


def md_escape(value):
    if value is None or value == "": return "未公开"
    return str(value).replace("|","\\|").replace("\n","；")


def md_link(q):
    return f"[{q['product']}]({q['source_card']})"


def fmt_memory(q):
    if q["memory_capacity_value"] is None and q["memory_bandwidth_value"] is None:
        return f"{q['memory_type']}；容量/带宽未公开"
    cap=f"{q['memory_capacity_value']:g} {q['memory_capacity_unit']}" if q["memory_capacity_value"] is not None else "容量未公开"
    bw=f"{q['memory_bandwidth_value']:g} {q['memory_bandwidth_unit']}" if q["memory_bandwidth_value"] is not None else "带宽未公开"
    status="" if q["availability_status"] == "当前产品/公开配置" else f"；{q['availability_status']}"
    return f"{q['memory_type']}；{cap}；{bw}{status}"


def fmt_compute(q):
    if q["advertised_bf16_fp16_peak_tflops"] is not None:
        return f"{q['advertised_peak_precision']} {q['advertised_bf16_fp16_peak_tflops']:g} TFLOPS（{q['bf16_fp16_peak_condition']}）"
    if q["low_precision_peak"] is not None:
        return f"{q['low_precision_peak']:g} {q['low_precision_format']}"
    return "未公开"


def write_table(lines, headers, rows):
    lines.append("| " + " | ".join(headers) + " |")
    lines.append("|" + "|".join("---" for _ in headers) + "|")
    for row in rows:
        lines.append("| " + " | ".join(md_escape(v) for v in row) + " |")
    lines.append("")


def write_appendix(cluster):
    data,_,_,_,_,_,scores,k,best_silhouette_k,ari_value,association_nmi,_=cluster
    lines=[
        "# 训练与推理芯片架构差异分析：36 个样本全量数据附录",
        "",
        "> 资料截止日：2026 年 8 月 25 日  ",
        "> 数据来源：36 张已完成资料卡；每个产品名均可回到原卡。  ",
        "> 用途：支撑《训练与推理芯片架构差异分析（第一版）》中的图表和判断。",
        "",
        "附录先给出本课题应汇总的完整指标范围，再按 Core、die/package、计算与存储、功耗、互联列出全部 36 个样本。未公开的项目保持缺失，不使用相邻型号、板卡或系统值补空白。可机器读取的同一份数据见[CSV](图表/36款芯片全量比较数据.csv)。",
        "",
        "## 应汇总的指标与当前处理",
        "",
        "这个范围由当前资料卡模板、前置调研的 workload 与架构因果链、早期架构主题调研，以及 Codex v3 的指标口径共同确定。统计不再反过来由当前 CSV 有哪几列决定。",
        "",
    ]
    write_table(lines, ["研究层级", "必须汇总的原始指标", "可派生或检验的指标", "36 张资料卡的当前处理"], INDICATOR_REGISTRY)
    lines += ["## 数据能覆盖到哪里", ""]
    coverage=[
        ("资料卡归纳的厂商定位","36/36","三类颜色是分析分层，不是排他能力标签"),
        ("目标 workload / 产品目标","24/36 与 31/36 有资料卡独立行","其余产品保留厂商定位，不由分析者代写目标"),
        ("Core / IP 身份","36/36（33 项可识别，3 项只有部分线索）","Atlas A2 两款和 MLU590 不具备完整的 SKU 级 Core/IP 信息"),
        ("执行模型","33/36","Atlas A2 两款和 MLU590 未公开"),
        ("已公开的主要计算资源","28 项较完整，7 项部分公开，1 项缺失","各厂商计数单位不同，不做跨厂商 Core 数排名"),
        ("时钟 / 分精度理论峰值",f"{sum(q['clock_numeric_available']=='是' for q in ROWS)}/36 有数值时钟；32/36 有时钟字段；32/36 有分精度峰值","有字段不等于有数值；时钟区分 per-chip、per-engine、base/boost 与 peak engine，峰值保留精度和 dense/sparse"),
        ("矩阵/向量/标量资源与吞吐",f"{len(PHYSICAL_MVS_RECORDS)}/36 有物理 M:V:S；{len(CORE_MVS_THROUGHPUT_RECORDS)}/36 有完整同精度三路吞吐；{len(CORE_BALANCE_RECORDS)}/36 有矩阵/Vector 或 non-Tensor 比","完整三路样本仅 AWS 4 项；宽口径样本中 10 项为直接 Vector，3 项 NVIDIA 为 non-Tensor 代理"),
        ("局部存储与数据搬运",f"{sum(q['local_storage_and_movement_detail'] not in ('资料卡未单列','资料卡路径不可用') for q in ROWS)}/36 有至少一行可归入","包含 cache/scratchpad/DMA/MTE/TMA；功能描述不等于可统一的持续带宽"),
        ("数值精度路径",f"{sum(q['precision_path']!='硬件精度与累加路径未公开' for q in ROWS)}/36","未见某格式的公开支持不等于硬件明确不支持"),
        ("累加/输出语义",f"{sum(q['accumulation_evidence'] in ACCUMULATION_PUBLIC for q in ROWS)}/36 有程序员可见证据","明确 accumulator、C/D/destination 与泛化宽累加分开"),
        ("结构化稀疏",f"{sum(q['structured_sparsity_status']=='公开支持' for q in ROWS)}/36 公开支持；{sum(q['structured_sparsity_status']=='明确不采用' for q in ROWS)}/36 明确不采用","SparseCore 等稀疏处理引擎不等同于矩阵结构化稀疏"),
        ("片上存储",f"{sum(q['onchip_storage_disclosure']=='至少一个片上层级有定量容量' for q in ROWS)}/36 至少一个层级完整定量；{sum(q['onchip_storage_disclosure']=='部分层级定量，其他层级未公开' for q in ROWS)}/36 部分定量","不同层级不合并求总量"),
        ("工艺","21 项有明确节点，另 1 项只有描述","Inferentia2 只披露 advanced process，没有节点"),
        ("D2D","2/36 有 chip-to-chip 绝对值；1/36 有 package bisection 绝对值；2/36 只有相对值","不同物理对象不做横向排名"),
        ("外部主存容量和带宽同时可用",f"{sum(q['memory_domain']=='外部DRAM' and q['memory_capacity_gb'] is not None and q['memory_bandwidth_tbps'] is not None for q in ROWS)}/36（含 1 项 roadmap target）","数值轴统一到十进制单位；GB/GiB 双口径逐项注明"),
        ("公开 BF16/FP16 矩阵峰值","15 项明确 dense/base，另 7 项条件不完整","条件不完整项只作空心点展示，不用于训推组间统计"),
        ("数字化功耗",f"{sum(q['power_w'] is not None for q in ROWS)}/36","混有 TDP、TBP、上限和 fleet average"),
        ("设备互联或明确无专用端点",f"{sum(q['device_interconnect']!='未公开' for q in ROWS)}/36","端点、scale-up 与 scale-out 分层解读"),
        ("公开数值 scale-up 工作域",f"{sum(q['scaleup_status']=='公开数值工作域' for q in ROWS)}/36","明确无专用 scale-up 和工作域未公开另列，不转换成数值"),
    ]
    write_table(lines,["维度","覆盖情况","解释"],coverage)
    lines += ["## Core 字段的分类统计","",
              "下面先给出执行模型、精度、累加和稀疏的分类计数，再列逐产品原始值。计数只反映资料卡中的明确证据；公开资料未写某项时保持缺失。",""]
    exec_counts=[]
    for category in sorted({q["execution_class"] for q in ROWS}):
        members=[q for q in ROWS if q["execution_class"]==category]
        c=Counter(q["position_group"] for q in members)
        exec_counts.append((category,len(members),c[TRAIN],c[INFER],c[UNIFIED],"、".join(sorted({q['vendor'] for q in members}))))
    write_table(lines,["执行模型分类","总数","训练","推理","共用/非排他","涉及厂商"],exec_counts)
    precision_fields=[
        ("FP64","precision_fp64"),("FP32/TF32 输入或计算路径","precision_fp32_tf32"),("BF16","precision_bf16"),
        ("FP16","precision_fp16"),("8-bit float family","precision_fp8_family"),("FP6 family","precision_fp6_family"),
        ("FP4 family","precision_fp4_family"),("INT8","precision_int8"),("INT4","precision_int4"),
    ]
    precision_counts=[]
    for label,key in precision_fields:
        members=[q for q in ROWS if q[key]=="公开支持"]
        c=Counter(q["position_group"] for q in members)
        precision_counts.append((label,len(members),c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["公开支持的格式","总数","训练","推理","共用/非排他"],precision_counts)
    core_state_rows=[]
    for field,label in [("theoretical_peak_evidence_class","理论峰值证据"),("accumulation_evidence","累加路径"),("structured_sparsity_status","结构化稀疏"),("onchip_storage_disclosure","片上存储公开层级")]:
        for state,n in Counter(q[field] for q in ROWS).most_common():
            c=Counter(q["position_group"] for q in ROWS if q[field]==state)
            core_state_rows.append((label,state,n,c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["字段","证据状态","总数","训练","推理","共用/非排他"],core_state_rows)
    clock_rows=[]
    for state,n in Counter(q["clock_basis_class"] for q in ROWS).most_common():
        c=Counter(q["position_group"] for q in ROWS if q["clock_basis_class"]==state)
        clock_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["时钟公开口径","总数","训练","推理","共用/非排他"],clock_rows)
    data_management_rows=[]
    for state,n in Counter(q["data_management_class"] for q in ROWS).most_common():
        members=[q for q in ROWS if q["data_management_class"]==state]
        c=Counter(q["position_group"] for q in members)
        data_management_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED],"、".join(sorted({q['vendor'] for q in members}))))
    write_table(lines,["片上数据管理模型","总数","训练","推理","共用/非排他","涉及厂商"],data_management_rows)
    movement_rows=[]
    for state,n in Counter(q["data_movement_class"] for q in ROWS).most_common():
        members=[q for q in ROWS if q["data_movement_class"]==state]
        c=Counter(q["position_group"] for q in members)
        movement_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED],"、".join(q["short"] for q in members)))
    write_table(lines,["数据搬运机制","总数","训练","推理","共用/非排他","产品"],movement_rows)
    write_table(lines,["产品","定位分层","公开 DMA headline","证据边界"],
                [(md_link(q),q["position_group"],f"{q['dma_bandwidth_tbps']:g} TB/s",q["dma_bandwidth_evidence"])
                 for q in ROWS if q["dma_bandwidth_tbps"] is not None])
    lines += ["### 矩阵、向量与标量资源配比", "",
              "物理单元数和理论吞吐是两种不同指标。前者只在单元定义一致的架构家族内保留；后者只当 SKU、精度、dense/sparse、范围和理论/实测口径一致时计算。", ""]
    physical_balance_rows=[]
    for short,matrix,vector,scalar,ratio,boundary in PHYSICAL_MVS_RECORDS:
        q=next(q for q in ROWS if q["short"]==short)
        physical_balance_rows.append((short,q["position_group"],matrix,vector,scalar,ratio,boundary))
    write_table(lines, ["产品", "定位分层", "矩阵单元", "向量单元", "标量单元", "物理 M:V:S", "边界"], physical_balance_rows)
    complete_mvs_rows=[]
    for item in CORE_MVS_THROUGHPUT_RECORDS:
        q=next(q for q in ROWS if q["short"]==item["short"])
        complete_mvs_rows.append((md_link(q),q["position_group"],item["family"],item["precision"],
                                  f"{item['matrix']:g}",f"{item['vector']:g}",f"{item['scalar']:g}",
                                  f"{item['matrix']/item['vector']:.2f}:1:{item['scalar']/item['vector']:.2f}",
                                  "每 Core 理论峰值；GpSIMD 不并入 Vector"))
    write_table(lines,["产品","定位分层","家族","精度","Matrix TFLOPS/Core","Vector TFLOPS/Core","Scalar TFLOPS/Core","归一到 Vector=1","边界"],complete_mvs_rows)
    ratio_rows=[]
    for item in CORE_BALANCE_RECORDS:
        q=next(q for q in ROWS if q["short"]==item["short"])
        ratio=item["matrix"]/item["nonmatrix"]
        boundary=("向量路径直接值" if item["evidence"]=="direct" else
                  "NVIDIA 只公开 non-Tensor；作为非矩阵代理值，不写成纯 Vector")
        ratio_rows.append((md_link(q),q["position_group"],item["family"],item["precision"],
                           f"{item['matrix']:g} TFLOPS",f"{item['nonmatrix']:g} TFLOPS（{item['nonmatrix_label']}）",f"{ratio:.2f}×",boundary))
    write_table(lines,["产品","定位分层","家族","精度","矩阵 dense 峰值","非矩阵峰值","矩阵/非矩阵","证据边界"],ratio_rows)
    lines += ["## 定位、Core 与执行组织","",
              "Core 表保留实际资源、片上存储、数值路径和专用单元。Core 数量的单位随厂商而异，只用于产品内或家族内比较；SM、MXU、NeuronCore、CU 和 AI Core 不合并计数。","”"]
    lines[-1]=""
    write_table(lines,["产品","定位分层","目标 workload / 产品目标","Core / 执行模型","矩阵、向量、标量与控制原文","实际使能资源","时钟原文","分精度理论峰值原文","片上存储/搬运原文","数据管理/搬运分类","DMA headline","数值与累加原文","结构化稀疏与专用单元"],
                [(md_link(q),q["position_group"],f"{q['target_workload_summary']}；{q['product_goal_summary']}",f"{q['core_family']}；{q['execution_detail']}",q["core_path_detail"],q["enabled_resources_detail"],q["clock_detail"],q["theoretical_peak_detail"],q["local_storage_and_movement_detail"],f"{q['data_management_class']}；{q['data_movement_class']}",("未公开" if q["dma_bandwidth_tbps"] is None else f"{q['dma_bandwidth_tbps']:g} TB/s；{q['dma_bandwidth_evidence']}"),q["numeric_path_detail"],f"{q['structured_sparsity_status']}；{q['sparsity_and_special_units']}") for q in ROWS])
    lines += ["## Die、chiplet、package 与产品形态","",
              "工艺、面积和晶体管数只在主语明确时保留。计算 die 分类把单逻辑 die、一颗计算 die 加辅助 die、多计算 die 和物理组织不足分开；HBM stack 不计作计算 die。NoC 的 SKU 行还按独立实现去重，D2D 先判断是否适用和是否存在，再比较数值证据。","”"]
    lines[-1]=""
    die_evidence_rows=[]
    for field,label in [("noc_evidence_detail_class","片内互联/NoC 细分证据"),("memory_controller_phy_evidence","内存控制器/PHY 混合原文证据"),("logical_d2d_status","逻辑 die 间 D2D 适用性"),("d2d_evidence_level","D2D 数值证据"),("ras_evidence_class","RAS")]:
        for state,n in Counter(q[field] for q in ROWS).most_common():
            c=Counter(q["position_group"] for q in ROWS if q[field]==state)
            die_evidence_rows.append((label,state,n,c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["字段","证据状态","总数","训练","推理","共用/非排他"],die_evidence_rows)
    controller_rows = [
        ("HBM/DRAM stack count", len(MEMORY_STACK_COUNT), "；".join(f"{k}={v}" for k,v in MEMORY_STACK_COUNT.items()), "stack 数不等于 controller 数；AWS device 图不证明封装方式"),
        ("SKU 实际 memory controller count", len(SKU_MEMORY_CONTROLLER_COUNT), "；".join(f"{k}={v}" for k,v in SKU_MEMORY_CONTROLLER_COUNT.items()), "只收直接值；L40S 的 12 个不由 384/32 推导"),
        ("memory bus width", len(MEMORY_BUS_WIDTH), "；".join(f"{k}={v}" for k,v in MEMORY_BUS_WIDTH.items()), "MI455X 保留 per-stack；Ascend 310 保留 per-controller"),
        ("HBM stack height", len(HBM_STACK_HEIGHT), "；".join(f"{k}={v}" for k,v in HBM_STACK_HEIGHT.items()), "只收直接标注的 hi/Hi"),
        ("SerDes raw label", len(SERDES_RAW_LABEL), "；".join(f"{k}={v}" for k,v in SERDES_RAW_LABEL.items()), "不由 octal/lane/编码自行反推聚合带宽"),
    ]
    write_table(lines,["controller/PHY 子指标","产品数","逐产品直接值","边界"],controller_rows)
    ras_mechanism_rows = [
        ("ECC",len(RAS_ECC),"、".join(sorted(RAS_ECC)),"HBM/GDDR/cache/register/full-chip/SRAM 保护对象不同"),
        ("row/page repair、remap 或 logic repair",len(RAS_REPAIR),"、".join(sorted(RAS_REPAIR)),"row remap、page retirement/avoidance 与 logic repair 分属不同对象"),
        ("link detection/replay",len(RAS_LINK_REPLAY),"、".join(sorted(RAS_LINK_REPLAY)),"设备链路端点机制；不含安全 inline protection"),
        ("BIST/SDC mitigation",len(RAS_BIST_SDC),"、".join(sorted(RAS_BIST_SDC)),"仅 TPU7x 有明确证据"),
    ]
    write_table(lines,["RAS 机制","产品数","产品","边界"],ras_mechanism_rows)
    write_table(lines,["产品","定位分层","首次公开年份","部署类别","计算 die 组织","die / package","工艺与物理规模","片内互联/NoC","NoC 证据细分","内存控制器/PHY 原文","controller/PHY 结构化直接值","逻辑 D2D 状态","D2D 数值证据","RAS 原文","RAS 机制结构化状态","产品形态"],
                [(md_link(q),q["position_group"],q["release_year"],q["deployment_class"],q["compute_die_organization"],q["die_and_package"],q["process_and_scale"],q["onchip_interconnect"],q["noc_evidence_detail_class"],q["memory_controller_phy"],
                  f"stack={q['memory_stack_count'] or '未公开'}；controller={q['sku_memory_controller_count'] or '未公开'}；bus={q['memory_bus_width'] or '未公开'}；height={q['hbm_stack_height'] or '未公开'}；SerDes={q['serdes_raw_label'] or '未公开'}",
                  q["logical_d2d_status"],f"{q['d2d_evidence_level']}；{q['d2d_summary']}",q["ras_summary"],
                  f"ECC={q['ras_ecc']}；repair/remap={q['ras_repair_remap']}；link replay={q['ras_link_detection_replay']}；BIST/SDC={q['ras_bist_sdc']}",q["form_factor"]) for q in ROWS])
    lines += ["## 计算峰值与外部内存","",
              "计算峰值逐项保留精度和 dense/sparse 条件。厂商明确的 dense/base 值在图中使用实心点；条件未完整公开的值使用空心点。GroqChip 的 80TB/s 属于片上 SRAM，不进入外部 DRAM 图。","”"]
    lines[-1]=""
    memory_class_rows=[]
    for state,n in Counter(q["memory_technology_class"] for q in ROWS).most_common():
        c=Counter(q["position_group"] for q in ROWS if q["memory_technology_class"]==state)
        memory_class_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED],"、".join(sorted({q['deployment_class'] for q in ROWS if q['memory_technology_class']==state}))))
    write_table(lines,["主存介质分类","总数","训练","推理","共用/非排他","部署类别"],memory_class_rows)
    access_rows=[]
    for state,n in Counter(q["memory_access_evidence_class"] for q in ROWS).most_common():
        c=Counter(q["position_group"] for q in ROWS if q["memory_access_evidence_class"]==state)
        access_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["内存访问语义分类","总数","训练","推理","共用/非排他"],access_rows)
    compute_rows=[]
    for q in ROWS:
        pb=bp=cp="未计算"
        if q["peak_per_memory_bandwidth_tflops_per_tbps"] is not None:
            pb=f"{q['peak_per_memory_bandwidth_tflops_per_tbps']:.1f} TFLOPS/(TB/s)"
            bp=f"{q['memory_bandwidth_per_peak_gbps_per_tflops']:.2f} GB/s/TFLOP"
        if q["memory_capacity_per_peak_gb_per_tflops"] is not None:
            cp=f"{q['memory_capacity_per_peak_gb_per_tflops']:.3f} GB/TFLOP"
        compute_rows.append((md_link(q),q["position_group"],fmt_compute(q),fmt_memory(q),pb,bp,cp,q["nameplate_ratio_evidence"]))
    write_table(lines,["产品","定位分层","公开计算峰值","主存容量与带宽","P/B","B/P","C/P","派生比值证据"],compute_rows)
    lines += ["## 功耗与部署形态","",
              "功耗列保留 TDP、TBP、maximum、configurable cap 和 fleet average 的原始口径。不同口径不合并为能效排名。","”"]
    lines[-1]=""
    power_state_rows=[]
    for state,n in Counter(q["power_basis_class"] for q in ROWS).most_common():
        c=Counter(q["position_group"] for q in ROWS if q["power_basis_class"]==state)
        power_state_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["功耗证据口径","总数","训练","推理","共用/非排他"],power_state_rows)
    cooling_rows=[]
    for state,n in Counter(q["cooling_class"] for q in ROWS).most_common():
        c=Counter(q["position_group"] for q in ROWS if q["cooling_class"]==state)
        cooling_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["散热证据分类","总数","训练","推理","共用/非排他"],cooling_rows)
    power_rows=[]
    for q in ROWS:
        power="未公开" if q["power_w"] is None else f"{q['power_w']:g}W；{q['power_basis']}"
        peak_per_power=("未计算" if q["nameplate_peak_per_power_tflops_per_w"] is None
                        else f"{q['nameplate_peak_per_power_tflops_per_w']:.3f} TFLOPS/W")
        power_rows.append((md_link(q),q["position_group"],q["deployment_class"],q["form_factor"],q["cooling_summary"],power,q["power_basis_class"],peak_per_power,q["peak_per_power_evidence"]))
    write_table(lines,["产品","定位分层","部署类别","产品形态","形态与散热原文","功耗及口径","口径分类","同精度铭牌峰值/功耗","派生值证据"],power_rows)
    lines += ["## 设备互联与系统扩展","",
              "设备端点、单一 scale-up 工作域和跨机 scale-out 分层记录。公开数值、明确无专用 scale-up 和工作域未公开分别保留；bridge、服务器/NVSwitch、Pod/slice 与 rack 的对象边界逐项列出。","”"]
    lines[-1]=""
    endpoint_rows=[]
    for state,n in Counter(q["endpoint_family"] for q in ROWS).most_common():
        c=Counter(q["position_group"] for q in ROWS if q["endpoint_family"]==state)
        endpoint_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["设备端点类型","总数","训练","推理","共用/非排他"],endpoint_rows)
    host_rows=[]
    for state,n in Counter(q["host_interface_class"] for q in ROWS).most_common():
        c=Counter(q["position_group"] for q in ROWS if q["host_interface_class"]==state)
        host_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["主机接口分类","总数","训练","推理","共用/非排他"],host_rows)
    topology_rows=[]
    for state,n in Counter(q["scaleup_topology_class"] for q in ROWS).most_common():
        c=Counter(q["position_group"] for q in ROWS if q["scaleup_topology_class"]==state)
        topology_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["Scale-up 拓扑分类","总数","训练","推理","共用/非排他"],topology_rows)
    scaleout_rows=[]
    for state,n in Counter(q["scaleout_evidence_class"] for q in ROWS).most_common():
        c=Counter(q["position_group"] for q in ROWS if q["scaleout_evidence_class"]==state)
        scaleout_rows.append((state,n,c[TRAIN],c[INFER],c[UNIFIED]))
    write_table(lines,["Scale-out 证据层级","总数","训练","推理","共用/非排他"],scaleout_rows)
    inter_rows=[]
    for q in ROWS:
        domain="未公开" if q["scaleup_status"]!="公开数值工作域" else f"{q['max_scaleup_domain']:,}"
        endpoint_per_peak=("未计算" if q["device_endpoint_bandwidth_per_peak_gbps_per_tflops"] is None
                           else f"{q['device_endpoint_bandwidth_per_peak_gbps_per_tflops']:.3f} GB/s/TFLOP（名义值）")
        inter_rows.append((md_link(q),q["position_group"],q["host_interface"],q["device_endpoint_detail"],q["device_endpoint_scope"],q["device_link_direction_evidence"],q["device_link_evidence_class"],endpoint_per_peak,q["device_endpoint_ratio_evidence"],q["memory_access_semantics"],q["scaleup_status"],domain,q["scaleup_scope"],q["scaleup_topology"],q["collective_hardware"],q["scaleout_evidence_class"],q["scaleout_context"]))
    write_table(lines,["产品","定位分层","主机接口","设备/卡端点原文与条件","端点对象","方向证据","端点数值证据","端点名义带宽/同精度峰值","派生比值证据","内存访问语义","工作域状态","最大公开单一工作域","工作域对象","拓扑/系统边界","collective 硬件","scale-out 证据层级","scale-out 上下文"],inter_rows)
    lines += ["## 聚类所用数据和结果","",
              f"聚类使用 {len(data)} 个同时具有外部 DRAM 容量、带宽和公开数值 scale-up 工作域的当前产品；roadmap target、明确无专用 scale-up 和工作域未公开的产品不进入。三个数值取 log10 后做 z-score，训练/推理定位不进入特征。主图展示 K={k}；K=2 至 5 的 silhouette 为 " + "、".join(f"{kk}:{scores[kk]:.2f}" for kk in sorted(scores)) + f"，最高值出现在 K={best_silhouette_k}。K={k} 与用途定位的 ARI={ari_value:.2f}；NMI 分别为 " + "、".join(f"{name}:{value:.2f}" for name,value in association_nmi.items()) + "。",
              "",
              "聚类只检查三项资源是否自然重现用途标签。它不代表完整 Core、die、数值路径和互联架构，也不能识别用途造成的因果效应。",
              "",
    ]
    path=ROOT/"训练与推理芯片架构差异分析-全量数据附录.md"
    path.write_text("\n".join(lines),encoding="utf-8")
    return path


def main():
    assert len(ROWS)==36, len(ROWS)
    csv_path=write_csv()
    cluster=cluster_analysis()
    outputs=[
        figure_core_position(), figure_execution_model(),
        figure_core_balance(), figure_complete_mvs_balance(),
        figure_precision_accumulation(), figure_special_units(),
        figure_onchip_storage_pairs(), figure_data_management(), figure_die_organization(),
        figure_process_year(), figure_ras_evidence(), figure_memory(), figure_compute_balance(),
        figure_memory_resource_ratios(),
        figure_power(), figure_device_endpoints(), figure_scaleup(),
        figure_cluster(cluster), write_appendix(cluster),
    ]
    data,raw,X,coords,labels,centers,scores,k,best_silhouette_k,ari_value,association_nmi,explained=cluster
    print(f"rows={len(ROWS)} groups={dict(Counter(q['position_group'] for q in ROWS))}")
    print("coverage", {
        "external_memory_complete":sum(q["memory_domain"]=="外部DRAM" and q["memory_capacity_gb"] is not None and q["memory_bandwidth_tbps"] is not None for q in ROWS),
        "core_balance_strict":sum(q["matrix_to_nonmatrix_peak_ratio"] is not None for q in ROWS),
        "physical_mvs_rows":sum(bool(q["physical_mvs_ratio"]) for q in ROWS),
        "complete_mvs_throughput_rows":sum(bool(q["complete_mvs_normalized_to_vector"]) for q in ROWS),
        "clock_fields":sum(q["clock_detail"] not in ("资料卡未单列", "资料卡路径不可用") for q in ROWS),
        "clock_numeric":sum(q["clock_numeric_available"] == "是" for q in ROWS),
        "numeric_dma_bandwidth":sum(q["dma_bandwidth_tbps"] is not None for q in ROWS),
        "full_peak_rows":sum(q["theoretical_peak_detail"] not in ("资料卡未单列", "资料卡路径不可用") for q in ROWS),
        "nameplate_ratio_rows":sum(q["peak_per_memory_bandwidth_tflops_per_tbps"] is not None for q in ROWS),
        "bf16_fp16_explicit_dense":sum(q["bf16_fp16_peak_condition"]=="明确 dense/base" for q in ROWS),
        "bf16_fp16_condition_partial":sum(q["bf16_fp16_peak_condition"]=="厂商未完整说明 dense/sparse 或计数条件" for q in ROWS),
        "power":sum(q["power_w"] is not None for q in ROWS),
        "strict_endpoint_per_peak":sum(q["device_endpoint_bandwidth_per_peak_gbps_per_tflops"] is not None for q in ROWS),
        "scaleup":sum(q["scaleup_status"] == "公开数值工作域" for q in ROWS),
        "ras_concrete_mechanism":sum(q["short"] in RAS_CONCRETE_MECHANISM for q in ROWS),
        "memory_stack_count":sum(bool(q["memory_stack_count"]) for q in ROWS),
        "memory_controller_count":sum(bool(q["sku_memory_controller_count"]) for q in ROWS),
        "memory_bus_width":sum(bool(q["memory_bus_width"]) for q in ROWS),
        "hbm_stack_height":sum(bool(q["hbm_stack_height"]) for q in ROWS),
        "serdes_raw_label":sum(bool(q["serdes_raw_label"]) for q in ROWS),
    })
    print("silhouette", {kk:round(v,4) for kk,v in scores.items()}, "display_k", k, "best_silhouette_k", best_silhouette_k)
    print("ari", round(ari_value,4), "nmi", {name:round(value,4) for name,value in association_nmi.items()}, "pca", [round(float(v),4) for v in explained[:2]])
    for g,c in enumerate(centers):
        members=[data[i]["short"] for i in range(len(data)) if labels[i]==g]
        comp=Counter(data[i]["position_group"] for i in range(len(data)) if labels[i]==g)
        print(f"cluster{g+1}", [round(float(v),3) for v in c], dict(comp), members)
    print("outputs")
    for p in [csv_path,*outputs]: print(p)


if __name__ == "__main__":
    main()
