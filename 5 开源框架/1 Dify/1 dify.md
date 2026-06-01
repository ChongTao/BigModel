# 一 Dify介绍

Dify（Do It For You）是一个开源的低代码平台，旨在简化大模型（LLM）驱动的AI应用开发与部署。它融合了“后端即服务 (BaaS)”与 LLMOps 概念，提供涵盖模型接入、提示设计、知识库检索、智能代理、数据监控等在内的一站式解决方案。通过直观的可视化界面和预构建组件，开发者和非技术人员都可以快速构建如聊天机器人、内容生成、数据分析等各类生成式AI应用。



# 二 Dify 本地部署-Windows

1. 下载docker后，运行docker 

2. 下载dify, 关键是配置代理：https://zhuanlan.zhihu.com/p/28744712219, 其中Docker的启动命令和停止命令：

  ```sh
  docker compose down
  docker compose up -d
  ```

3. 下载olloma, 执行命令ollama run deepseek-r1:1.5b, 运行模型。

4. dify下载ollama的插件，配置deepseek的地址。
4. 输入网址 ：http://localhost，创建编排流程。
