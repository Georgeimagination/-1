# H100 白皮书固定副本补取记录

获取日期：2026-08-12  
来源家族：NVIDIA H100 Tensor Core GPU Architecture  
内容版本：v1.04

## 结果

总控从 NVIDIA Hopper 架构官方页的 “Read Whitepaper” 入口进入 NVIDIA Resources 落地页，再沿页面中的 Widen 内容窗口取得官方 PDF。固定入口为：

- 官方架构页：<https://www.nvidia.com/en-us/data-center/technologies/hopper-architecture/>
- NVIDIA Resources 落地页：<https://resources.nvidia.com/en-us-hopper-architecture/nvidia-h100-tensor-c>
- Widen 文档入口：<https://nvdam.widen.net/s/lszrvk5jkm/nvidia-h100-tensor-core-hopper-whitepaper>

本地文件：`论文/NVIDIA_GPU/01_厂商直接架构论文/2022_NVIDIA_H100_Tensor_Core_GPU_Architecture_Whitepaper_v1.04.pdf`

- 文件大小：7,880,278 字节
- 页数：71
- SHA-256：`3641614979809a027a8aabdc2e77639efb8fcd0f8dc7873a22ba2125489f5a27`
- PDF 版本：1.4
- 文档作者元数据：NVIDIA
- 封面版本：V1.04；封面注明包含最终 GPU/内存时钟和最终 TFLOPS 规格

总控已把第 1 页渲染为图像并人工核对，标题、NVIDIA 标识、V1.04 及封面版本说明均正常。下载前的沙箱内网络请求无法连接；经批准的网络访问成功。这是网络沙箱边界，不是模型或实现能力限制。随后直接调用 `pdfinfo.cmd` 包装器失败，原因是包装器引用的旧相对路径不存在；改用捆绑的 `pdfinfo.exe` 后成功解析。这是工具包装器可移植性问题，不是沙箱或审批失败。

## 资料池同步

`清单/论文PDF清单.csv` 已新增该文件，`清单/汇总统计.json` 和 `scripts/validation/Test-SourcePool.ps1` 的有意基线随之更新。新基线为 103 份 PDF、290,432,359 字节、2,079 页；校验器重新运行通过，保留原有一条 Google TPU PDF 解析警告。

H100 试填交接中“官方固定 PDF 尚未取得”的缺口至此关闭。后续正式来源表应使用上述内容版本、三个官方入口和本地文件哈希，不再把白皮书记为不可访问。