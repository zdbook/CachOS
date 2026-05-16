# Contributing to CachyOS Server x86-64-v4

感谢您对CachyOS项目的兴趣！本文档说明如何贡献代码和改进。

## 行为守则

请阅读并遵守我们的[行为守则](CODE_OF_CONDUCT.md)。我们致力于为所有人创建一个热情、包容和友好的社区。

## 如何贡献

### 报告问题

如果您发现了bug或有功能请求，请[创建GitHub Issue](https://github.com/zdbook/CachOS/issues/new)。

请提供：
- 清晰的问题标题
- 详细的问题描述
- 重现步骤（如果是bug）
- 系统信息（OS、硬件、内核版本等）
- 错误日志或截图

### 提交代码更改

#### 1. Fork仓库
```bash
git clone https://github.com/YOUR_USERNAME/CachOS.git
cd CachOS
```

#### 2. 创建功能分支
```bash
git checkout -b feature/your-feature-name
# 或修复分支
git checkout -b fix/your-fix-name
```

#### 3. 做出更改
- 遵循现有的代码风格
- 添加测试（如适用）
- 更新文档

#### 4. 测试更改
```bash
# 验证脚本语法
bash -n scripts/*.sh

# 本地构建测试（如果可能）
make validate
make test
```

#### 5. 提交更改
```bash
git add .
git commit -m "清晰的提交消息"
```

提交消息应该：
- 使用现在时 ("Add feature" 而不是 "Added feature")
- 使用命令式语气 ("Move cursor to..." 而不是 "Moves cursor to...")
- 限制第一行在72个字符以内
- 参考相关的issues (#123)

#### 6. 推送并创建Pull Request
```bash
git push origin feature/your-feature-name
```

然后在GitHub上创建Pull Request。

### Pull Request指南

- 提供清晰的PR标题和描述
- 参考相关的issues
- 包含测试（如果适用）
- 更新README（如果需要）
- 遵循代码风格
- 确保CI通过

## 开发指南

### 环境设置

```bash
# 克隆仓库
git clone https://github.com/zdbook/CachOS.git
cd CachOS

# 创建虚拟环境（如果使用Python）
python3 -m venv venv
source venv/bin/activate
```

### 构建和测试

```bash
# 查看可用命令
make help

# 运行测试
make test

# 验证工作流
make validate

# 本地构建（需要Docker/Arch Linux）
make build-all
```

### 代码风格

- Bash脚本: 使用ShellCheck
- YAML: 使用标准缩进（2个空格）
- 注释: 清晰描述代码意图
- 文档: 保持更新

### 文档

- 使用Markdown格式
- 包含代码示例
- 保持README最新
- 记录新功能

## 项目结构

```
CachOS/
├── .github/workflows/       # GitHub Actions工作流
├── scripts/                 # 构建和辅助脚本
├── config/                  # 配置文件
├── dist/                    # 构建输出
├── README.md                # 项目文档
├── Makefile                 # 构建系统
└── CONTRIBUTING.md          # 本文件
```

## 提交工作流程

1. **Fork** 仓库
2. **创建** 功能分支
3. **做出** 更改并提交
4. **推送** 到您的fork
5. **创建** Pull Request
6. **参与** 审查
7. **合并** 到主分支

## 问题和讨论

- **Bugs**: 使用[Issues](https://github.com/zdbook/CachOS/issues)
- **功能请求**: 使用[Issues](https://github.com/zdbook/CachOS/issues)
- **讨论**: 使用[Discussions](https://github.com/zdbook/CachOS/discussions)

## 许可证

通过提交代码，您同意您的贡献在项目的许可证下发布。

## 问题？

欢迎提问！请创建Issue或参与讨论。

---

感谢您的贡献！❤️
