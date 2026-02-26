# J-Parlant Admin

**打造稳定、可控、业务驱动的企业级 AI Agent 低代码开发平台**

J-Parlant Admin 是一个可视化的 AI Agent 编排与管理平台。它深受 Python 开源项目 Parlant 理念启发，致力于解决大模型在复杂业务场景下“不可控”的痛点。通过可视化拖拽与业务代码集成，帮助开发者构建具有确定性逻辑、长期记忆和业务感知力的数字员工。

## 💡 为什么需要 J-Parlant？

在构建生产级 Agent 时，纯粹的 Prompt 工程往往难以应对复杂的业务：

- **行为不可控**：LLM 容易脱离业务范畴“胡言乱语”，难以保证回复的专业性与合规性。
- **逻辑碎片化**：业务流程散落在大量的 Prompt 模板中，难以维护和审计。
- **开发门槛高**：传统的 Agent 开发需要处理复杂的上下文状态、工具调用逻辑和流式输出。
- **集成成本大**：AI 逻辑与现有 Java/Spring 业务系统结合不紧密，难以直接复用业务代码。

J-Parlant Admin 通过 **“逻辑编排 + 业务代码（Low-Code）”** 的模式，让 AI Agent 像传统软件一样稳定运行。

## 📦 项目组成

J-Parlant 采用“**编排与运行分离**”的架构，由以下核心组件构成：

*   **[J-Parlant Admin](https://gitee.com/sylvara/jparlant-admin)** (本项目)：可视化管理后台，负责 Agent 的创建、意图定义、流程编排与对话测试。
*   **[J-Parlant Server](https://gitee.com/sylvara/jparlant-backend)**：Admin配套后端服务，负责存储Agent信息、流程编排等逻辑。
*   **[J-Parlant Starter](https://gitee.com/sylvara/j-parlant)**：**Agent核心工作引擎**。当你在 Admin 中完成流程编排后，需在具体的 Spring Boot 业务项目中引入此 Starter，即可通过 API 轻松调用已编排好的 Agent。



## 🚀 核心理念与能力

### 可视化流程编排

低代码编排，通过拖拽方式设计 Agent 的对话流程，支持：
- 条件分支：根据用户输入走不同的流程路径
- 流程变量：在节点间传递和处理数据
- 业务动作：调用后端服务执行业务逻辑

### 全链路合规与审计

统一管理内容审核和合规检查规则：
- 支持关键词、正则表达式、SpEL 表达式等多种匹配方式
- 可分别配置输入检查和输出检查
- 自定义拦截时的提示语和引导话术

### 术语库管理

建立统一的业务术语库，提升 AI 理解准确性：
- 定义专业术语及其解释
- 配置同义词和相关术语
- 提供使用示例帮助 AI 更好理解

### 对话测试

内置对话测试功能，实时验证配置效果：
- 支持文本和图片输入
- 流式展示 AI 回复
- 快速定位配置问题

## 快速开始

### 环境要求

- Node.js 16+
- 后端服务**[J-Parlant Server](https://gitee.com/sylvara/jparlant-backend)** (需提前启动后端服务)

### 安装和运行

```bash
# 克隆项目
git clone https://gitee.com/sylvara/jparlant-admin.git
cd jparlant-admin

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

启动后访问 http://localhost:3000 即可使用。

### 配置后端地址

在 `vite.config.ts` 中修改[J-Parlant Server](https://gitee.com/sylvara/jparlant-backend)服务地址：

```typescript
proxy: {
  '/api': {
    target: 'http://localhost:9085',  // 修改为你的后端地址
    changeOrigin: true
  }
}
```

## 使用指南

### 🤖 第一步：创建 Agent

1. 进入 Agent 管理页面
2. 点击「新建 Agent」
3. 填写 Agent 名称和系统指令
4. 保存后即可开始配置

### 🎯 第二步：配置意图

1. 进入 Agent 的意图管理页面
2. 创建一个新意图，如「查询订单」
3. 选择合适的流程类型
4. 保存意图配置

### 🔗 第三步：编排流程

1. 点击意图卡片上的「流程编排」按钮
2. 在画布上添加流程节点
3. 配置每个节点的详细参数：
   - 设置节点名称和提示语
   - 配置输入验证规则
   - 绑定业务动作
4. 连接节点形成完整流程
5. 保存流程配置

### ⚙️ 第四步：配置业务处理器（可选）

如果流程中需要调用后端业务服务：

1. 在流程编排页面点击设置图标
2. 配置业务处理器服务地址
3. 在动作节点中选择需要调用的业务方法
4. 配置入参映射和结果提取

### 🔌 第五步：业务集成

当你在 Admin 平台完成流程编排后：

在你的 Java 业务项目 `pom.xml` 中引入 **[J-Parlant Starter](https://gitee.com/sylvara/j-parlant)** 依赖。

> 详情参考：[J-Parlant Starter 使用文档](https://gitee.com/sylvara/j-parlant)


### ✅ 第六步：测试验证

在 `vite.config.ts` 中修改后端服务地址。**注意：此地址必须指向集成了[J-Parlant Starter](https://gitee.com/sylvara/j-parlant)的业务后端，否则无法进行对话测试。**

```typescript
proxy: {
  '/customerAgent': {
    target: 'http://localhost:9085',  // 👈 关键：修改为你的业务后端地址
    changeOrigin: true
  }
}
```

1. 进入意图的对话测试页面
2. 输入测试问题
3. 观察 AI 回复是否符合预期
4. 根据测试结果调整流程配置



## 构建部署

```bash
# 构建生产版本
npm run build

# 构建产物在 dist 目录
```

将 `dist` 目录部署到任意静态文件服务器即可。

## 项目截图

![流程编排](./docs/images/flow.png)

![复杂的变量定义](./docs/images/variable.png)

## 贡献指南

欢迎提交 Issue 和 Pull Request！

- 提交 Issue 前请先搜索是否已有类似问题
- Pull Request 请确保代码通过类型检查
- 新功能请附带相应的说明文档

## 开源协议

[Apache License 2.0](LICENSE)

---

🎯 **J-Parlant：赋予 AI 确定性的业务灵魂。**
