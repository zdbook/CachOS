# 快速入门指南 / Getting Started Guide

## 中文版本

### 什么是这个项目？

这个项目提供了一个完整的GitHub Actions工作流，用于自动构建和发布**CachyOS服务器版x86-64-v4优化的Linux内核和ISO**。

#### 核心特性
- 🚀 **x86-64-v4优化**: 利用AVX-512指令集的最新CPU优化
- 🖥️ **服务器优化**: 针对服务器工作负载的特殊配置
- 🔄 **自动构建**: GitHub Actions工作流自动构建、测试和发布
- 📦 **完整镜像**: 包含常见服务器工具和服务的即用型ISO

### 快速开始（5分钟）

#### 1. **复制仓库到您的账户**
```bash
# 在GitHub上Fork此仓库
# 或克隆到本地
git clone https://github.com/YOUR_USERNAME/CachOS.git
cd CachOS
```

#### 2. **使用快速启动菜单**
```bash
./quick-start.sh
```

这将打开一个交互菜单，您可以选择：
- 本地构建内核
- 本地构建ISO
- 推送到GitHub
- 触发GitHub Actions

#### 3. **或使用Makefile命令**
```bash
# 查看所有可用命令
make help

# 本地构建内核（需要Arch Linux环境）
make build-kernel-gcc

# 本地构建ISO（需要root权限）
sudo make build-iso

# 完整构建
make build-all
```

### 使用GitHub Actions自动构建

#### 方法A：推送代码触发
```bash
# 做出更改
git add .
git commit -m "Your changes"
git push origin main
# ✅ 构建自动开始！
```

#### 方法B：手动触发工作流
```bash
# 使用GitHub CLI
gh workflow run build-server-v4-iso.yml -f build_type=gcc

# 或在GitHub网页界面：
# 1. Actions标签
# 2. "Build CachyOS Server x86-64-v4 ISO"
# 3. 点击"Run workflow"
```

#### 方法C：查看构建状态
```bash
# 查看最新10个运行
gh run list --workflow=build-server-v4-iso.yml --limit=10

# 观看特定运行
gh run watch <run_id>
```

### 下载构建产物

构建完成后，您可以从以下位置获取文件：

1. **GitHub Actions Artifacts** (临时存储)
   - 每个工作流运行都会上传artifacts
   - 保留30天后自动删除

2. **GitHub Releases** (永久发布)
   - 自动创建的Release包含所有文件
   - 包括完整的构建说明

3. **本地输出** (如果本地构建)
   ```bash
   # ISO文件位于
   dist/CachyOS-Server-*.iso
   
   # 内核包位于
   /tmp/cachyos-build-*/linux-cachyos-server/*.pkg.tar.zst
   ```

### 优化参数解释

项目为以下用途进行了优化：

| 参数 | 值 | 优势 |
|------|-----|------|
| **CPU优化** | x86-64-v4 | AVX-512支持，性能提升15-30% |
| **调度器** | EEVDF | 公平的资源分配，适合多任务 |
| **时钟** | 100Hz | 减少上下文切换开销 |
| **抢占** | Full | 平衡延迟和吞吐量 |
| **网络** | BBR3 | 改进的拥塞控制 |

### 系统要求

#### 硬件
- **CPU**: Intel 3代Xeon/AMD Ryzen 3000+ (需要AVX-512)
- **RAM**: 4GB+ (构建时需要)
- **存储**: 50GB+ (构建空间)

#### 软件
- 本地构建: Arch Linux或兼容环境
- GitHub Actions: 自动提供
- CLI工具 (可选): git, gh

### 文件说明

```
CachOS/
├── .github/workflows/               # GitHub Actions配置
│   └── build-server-v4-iso.yml     # 主工作流文件
├── scripts/                         # 构建脚本
│   ├── build-kernel.sh             # 内核构建脚本
│   └── build-iso.sh                # ISO构建脚本
├── config/                          # 配置文件
│   └── build.conf                  # 构建配置参数
├── quick-start.sh                  # 快速启动菜单
├── Makefile                        # Make命令定义
├── README.md                       # 完整文档
├── CONTRIBUTING.md                # 贡献指南
└── LICENSE                         # 许可证
```

### 常见问题

**Q: 我没有AVX-512 CPU怎么办？**
A: 项目仍可构建，但您需要修改`config/build.conf`中的`processor_opt`为`GENERIC_V3`。

**Q: 构建需要多长时间？**
A: 通常15-45分钟，取决于硬件和网络速度。

**Q: 可以修改内核配置吗？**
A: 可以！编辑`config/build.conf`或PKGBUILD中的参数。

**Q: 如何使用Clang而不是GCC？**
A: 在工作流输入中选择"clang"，或运行`./scripts/build-kernel.sh clang`。

**Q: 支持其他架构吗？**
A: 可以！修改脚本中的`_processor_opt`参数即可。

### 获取帮助

1. **查看文档**
   - [README.md](README.md) - 完整功能文档
   - [config/build.conf](config/build.conf) - 所有配置参数
   - [CONTRIBUTING.md](CONTRIBUTING.md) - 贡献指南

2. **检查日志**
   - GitHub Actions: 查看工作流日志
   - 本地: 查看终端输出

3. **提出问题**
   - [GitHub Issues](https://github.com/zdbook/CachOS/issues)
   - [GitHub Discussions](https://github.com/zdbook/CachOS/discussions)

### 下一步

1. 📖 阅读[完整README](README.md)了解所有特性
2. 🔧 探索[config/build.conf](config/build.conf)的优化选项
3. 🚀 触发第一个构建！
4. 📝 考虑为项目做贡献

---

## English Version

### What is this project?

This project provides a complete GitHub Actions workflow to automatically build and release **CachyOS Server x86-64-v4 optimized Linux kernel and ISO**.

#### Key Features
- 🚀 **x86-64-v4 Optimization**: Leveraging latest CPU optimizations with AVX-512 instruction set
- 🖥️ **Server Optimized**: Special configuration for server workloads
- 🔄 **Automated Building**: GitHub Actions automatically builds, tests, and publishes
- 📦 **Complete Image**: Ready-to-use ISO with common server tools

### Quick Start (5 minutes)

#### 1. **Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/CachOS.git
cd CachOS
```

#### 2. **Use quick start menu**
```bash
./quick-start.sh
```

#### 3. **Or use Makefile**
```bash
make help              # See all commands
make build-kernel-gcc # Build kernel locally
sudo make build-iso   # Build ISO (needs root)
```

### Build with GitHub Actions

#### Option A: Push to trigger
```bash
git push origin main  # Automatically starts build!
```

#### Option B: Manual trigger
```bash
gh workflow run build-server-v4-iso.yml -f build_type=gcc
```

#### Option C: Check status
```bash
gh run list --workflow=build-server-v4-iso.yml
```

### Download artifacts

After build completes:
1. **Artifacts** (temporary, 30 days)
2. **Releases** (permanent)
3. **Local output** (if local build)

### Optimization parameters

| Parameter | Value | Benefit |
|-----------|-------|---------|
| CPU Opt | x86-64-v4 | 15-30% performance gain |
| Scheduler | EEVDF | Fair resource allocation |
| Clock | 100Hz | Lower context switch overhead |
| Preemption | Full | Balance latency & throughput |
| Network | BBR3 | Better congestion control |

### System Requirements

- **CPU**: Intel 3rd Gen Xeon / AMD Ryzen 3000+ (AVX-512)
- **RAM**: 4GB+ minimum
- **Storage**: 50GB+ for builds

### Troubleshooting

**No AVX-512 support?**
- Modify `processor_opt` to `GENERIC_V3` in config

**Build taking long?**
- Normal: 15-45 minutes depending on hardware
- Check GitHub Actions logs for details

**Want to use Clang?**
- Select "clang" in workflow or run `./scripts/build-kernel.sh clang`

### Support

- 📖 Full docs: [README.md](README.md)
- 🔧 Config: [config/build.conf](config/build.conf)
- 💬 Issues: [GitHub Issues](https://github.com/zdbook/CachOS/issues)
- 📝 Contributing: [CONTRIBUTING.md](CONTRIBUTING.md)

### Next steps

1. Read [full README](README.md)
2. Explore [config/build.conf](config/build.conf)
3. Trigger your first build!
4. Consider contributing back

---

**Happy building! 🚀**

Questions? [Open an issue](https://github.com/zdbook/CachOS/issues/new)
