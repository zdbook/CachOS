# CachyOS Server x86-64-v4 Automated Build & Release

完整的GitHub Actions工作流，用于自动构建、优化和发布CachyOS服务器版x86-64-v4的Linux内核和ISO。

## 功能特性

### 🚀 核心优化
- **架构优化**: x86-64-v4 (AVX-512) CPU指令集优化
- **服务器配置**: 针对服务器工作负载的内核参数优化
- **调度器**: EEVDF调度器 (平衡性能与响应性)
- **编译优化**: GCC或Clang LLVM支持，完整的代码优化

### 📦 构建配置
| 配置项 | 值 | 用途 |
|-------|-----|------|
| **处理器优化** | x86-64-v4 | 最大化AVX-512指令利用 |
| **时钟频率** | 100Hz | 服务器工作负载优化 |
| **抢占方式** | Full | 平衡延迟与吞吐量 |
| **TCP拥塞控制** | BBR3 | 改进的网络性能 |
| **ZFS支持** | 启用 | 现代文件系统 |
| **NVIDIA驱动** | 开源 | GPU支持 |

### 🛠️ 包含的工具
- **Web服务**: Nginx
- **数据库**: PostgreSQL, MariaDB, Redis, SQLite
- **监控**: htop, iotop, sysstat
- **开发**: Python3, Node.js, Perl, Ruby, base-devel
- **系统**: ssh, git, vim, curl, wget, rsync
- **文件系统**: btrfs, ext4, NTFS, exFAT, ZFS

## 快速开始

### 手动构建

#### 1. 构建内核
```bash
# 赋予脚本执行权限
chmod +x scripts/build-kernel.sh

# 使用GCC构建
./scripts/build-kernel.sh gcc

# 或使用Clang
./scripts/build-kernel.sh clang
```

#### 2. 构建ISO
```bash
# 需要root权限
chmod +x scripts/build-iso.sh
sudo ./scripts/build-iso.sh
```

### GitHub Actions 自动构建

#### 方法1: 推送触发 (Push Trigger)
任何对以下文件的推送都会触发自动构建:
- `.github/workflows/build-server-v4-iso.yml`
- `scripts/**/*.sh`
- `config/**/*`

```bash
git push origin main
```

#### 方法2: 手动触发 (Workflow Dispatch)
在GitHub网页界面上:
1. 进入 **Actions** 标签
2. 选择 **Build CachyOS Server x86-64-v4 ISO**
3. 点击 **Run workflow**
4. 选择编译器 (gcc 或 clang)

```bash
# 或使用CLI
gh workflow run build-server-v4-iso.yml \
  -f build_type=gcc
```

#### 方法3: Git标签触发
```bash
# 创建并推送标签
git tag v1.0
git push --tags

# 工作流会自动触发并创建Release
```

## 工作流详解

### 构建流程

```
┌─────────────────────────────────────────┐
│   GitHub Actions Workflow Triggered     │
└──────────────┬──────────────────────────┘
               │
       ┌───────▼────────┐
       │  Build Kernel  │ ◄─ 克隆linux-cachyos-server
       │ (GCC or Clang) │    应用x86-64-v4优化
       └───────┬────────┘
               │
       ┌───────▼────────┐
       │   Build ISO    │ ◄─ 创建Archiso配置
       │  with Kernel   │    添加服务器包
       └───────┬────────┘
               │
       ┌───────▼────────┐
       │Create Release  │ ◄─ 上传到GitHub Releases
       │ & Upload       │    生成构建清单
       └────────────────┘
```

### 工作流步骤

**Job 1: build-kernel**
1. ✅ 检出代码
2. ✅ 设置Arch Linux环境
3. ✅ 配置CachyOS仓库
4. ✅ 克隆linux-cachyos项目
5. ✅ 应用x86-64-v4优化
6. ✅ 编译内核包
7. ✅ 上传kernel artifacts

**Job 2: build-iso**
1. ✅ 检出代码
2. ✅ 设置ISO构建环境
3. ✅ 下载编译好的内核
4. ✅ 克隆CachyOS配置
5. ✅ 准备Archiso配置
6. ✅ 生成ISO镜像
7. ✅ 上传ISO artifacts

**Job 3: create-release**
1. ✅ 下载所有artifacts
2. ✅ 生成发布说明
3. ✅ 创建GitHub Release
4. ✅ 上传所有文件

## 文件结构

```
CachOS/
├── .github/
│   └── workflows/
│       └── build-server-v4-iso.yml      # 主GitHub Actions工作流
├── scripts/
│   ├── build-kernel.sh                  # 内核构建脚本
│   ├── build-iso.sh                     # ISO构建脚本
│   └── optimize-pkgbuild.sh             # PKGBUILD优化工具
├── config/
│   ├── kernel.config                    # 内核配置
│   └── pacman.conf                      # Pacman配置
├── dist/                                # 构建输出目录
├── README.md                            # 项目文档
└── LICENSE                              # 许可证
```

## 环境变量

在GitHub Actions中配置的环境变量:

| 变量 | 默认值 | 说明 |
|-----|-------|------|
| `CCACHE_DIR` | `/home/builder/.ccache` | C编译缓存目录 |
| `BUILD_TYPE` | `gcc` | 编译器类型 |
| `_processor_opt` | `GENERIC_V4` | 处理器优化级别 |

## 优化参数

### 内核优化设置
```bash
# 处理器优化
_processor_opt=GENERIC_V4           # x86-64-v4 ISA

# 调度器
_cpusched=eevdf                      # EEVDF调度器

# 时钟频率 (Hz)
_HZ_ticks=100                        # 服务器优化

# 抢占策略
_preempt=full                        # 完全抢占

# 编译优化
_cc_harder=yes                       # 增强GCC优化
_per_gov=yes                         # 性能调控器

# 功能开启
_build_zfs=yes                       # ZFS支持
_build_nvidia_open=yes               # 开源NVIDIA驱动
_build_r8125=yes                     # r8125网卡驱动
_tcp_bbr3=yes                        # BBR3拥塞控制
_cachy_config=yes                    # CachyOS配置
```

## 性能考虑

### x86-64-v4 的优势
- 更好的向量化计算性能
- 改进的数据库查询速度
- 加速加密操作
- 优化的编译器生成代码

### 服务器配置的好处
- 100Hz 时钟 = 更低的上下文切换开销
- 完全抢占 = 平衡延迟和吞吐量
- EEVDF 调度器 = 公平的资源分配
- BBR3 拥塞控制 = 改进的网络性能

## 系统要求

### 硬件
- **CPU**: Intel/AMD x86-64 with AVX-512 support
  - Intel: 3rd Gen Xeon & newer
  - AMD: Ryzen 3000 series & newer
- **RAM**: 2GB minimum (4GB+ recommended)
- **Storage**: 20GB+ for installation

### 软件
- Arch Linux或兼容的发行版
- Docker (可选，用于容器化构建)
- 足够的磁盘空间用于编译

## 故障排除

### 问题: 构建超时
**解决方案**: 
- 增加运行器超时时间
- 使用更强大的构建机器
- 启用缓存

### 问题: 内存不足
**解决方案**:
- 配置更多RAM的运行器
- 启用swap分区
- 减少并行构建数

### 问题: 网络错误
**解决方案**:
- 检查防火墙设置
- 使用镜像源
- 重新运行工作流

## 贡献

欢迎提交Pull Request和Issue！请确保:
- 遵循现有的代码风格
- 提供清晰的提交信息
- 测试您的更改

## 许可证

本项目遵循 [CachyOS](https://github.com/CachyOS) 的许可证。

## 相关链接

- **CachyOS**: https://cachyos.org
- **linux-cachyos**: https://github.com/CachyOS/linux-cachyos
- **Arch Linux**: https://archlinux.org
- **GitHub Actions**: https://github.com/features/actions

## 联系方式

- 📧 邮箱: [联系方式]
- 💬 讨论: [GitHub Discussions]
- 🐛 问题: [GitHub Issues]

---

**构建时间**: 2026年5月16日  
**版本**: 1.0  
**维护者**: CachyOS Server Build Team