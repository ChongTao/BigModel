# nndeploy 项目介绍

[nndeploy](https://github.com/nndeploy/nndeploy)是一款简单易用和高性能的 AI 部署框架。解决的是 AI 算法在端侧部署的问题，包含桌面端（Windows、macOS）、移动端（Android、iOS）、边缘计算设备（NVIDIA Jetson、Ascend310B、RK 等）以及单机服务器（RTX 系列、T4、Ascend310P 等），**基于可视化工作流和多端推理，可让 AI 算法在上述平台和硬件更高效、更高性能的落地。**

## 1.1 体验

1. 安装

   ```sh
   pip install --upgrade nndeploy
   ```

   > 要求 Python 3.10+，默认会带 ONNXRuntime、MNN 等；更多后端需从源码用开发者模式编译。

2. 启动可视化工作流

   ```sh
   nndeploy-app --port 8000
   ```

   浏览器打开 http://localhost:8000 即可拖拽节点、调参、预览。

3. 导出与运行

   - 保存后得到 workflow.json。

   - 命令行调试：nndeploy-run-json --json_file path/to/workflow.json。

   - 集成到业务：用 Python 的 nndeploy.dag.Graph 或 C++ 的 dag::Graph 加载该 JSON，再 init → set input → run → get output → deinit。

## 1.2 对接外部推理框架

推理能力 = 外部集成 + 自研默认实现。

1. 统一编排：用一张 DAG 描述「前处理 → 推理 → 后处理」整条流水线，多阶段、多模型一次搭好，而不是为每个外部推理框架各写一套流程。

1. 前后处理现成可用：提供与模型对齐的预处理 + 后处理节点（检测框解码/NMS、分类、分割、OCR 等），减少自写、自维护成本，并与可视化预览一致。

1. 流水线/任务并行：预处理、推理、后处理作为图中节点，由执行器调度，支持流水线或任务并行，有利于端到端吞吐，而不只是单次推理加速。

1. 一套图可换后端：同一工作流 JSON 可切换 ONNXRuntime、TensorRT、MNN 等，适合多平台或多产线复用；单条产线若后端已固定，则更多是可选便利。

1. 可视化 + JSON 部署：界面搭图、调参、导出 JSON，生产用同一 JSON 加载运行，降低「原型与部署不一致」和集成成本。

一句话：在对接外部推理框架时，项目主要提供流水线编排、现成前后处理节点、多种执行策略和可视化/JSON 工具链；若你自写规范化与后处理且生产推理框架已固定，可不用本项目，用则是提高效率和一致性，而非推理正确性的必要条件。