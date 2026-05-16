#!/usr/bin/env bash
# Quick Start Script for CachyOS Server x86-64-v4 Builds
# This script provides an interactive way to start builds

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  CachyOS Server x86-64-v4 Build Tool${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_menu() {
    echo "选择一个选项 / Select an option:"
    echo ""
    echo "1) 本地构建内核 (Local kernel build - GCC)"
    echo "2) 本地构建内核 (Local kernel build - Clang)"
    echo "3) 本地构建ISO (Local ISO build - requires root)"
    echo "4) 构建完整项目 (Build kernel + ISO)"
    echo ""
    echo "5) 推送到GitHub并触发Actions (Push & trigger GitHub Actions)"
    echo "6) 手动触发GitHub Actions (Manually trigger workflow)"
    echo "7) 查看工作流运行状态 (View workflow status)"
    echo ""
    echo "8) 清理构建产物 (Clean build artifacts)"
    echo "9) 帮助 (Show help)"
    echo "0) 退出 (Exit)"
    echo ""
}

build_kernel_gcc() {
    echo -e "${GREEN}Starting GCC kernel build...${NC}"
    chmod +x scripts/build-kernel.sh
    ./scripts/build-kernel.sh gcc
}

build_kernel_clang() {
    echo -e "${GREEN}Starting Clang kernel build...${NC}"
    chmod +x scripts/build-kernel.sh
    ./scripts/build-kernel.sh clang
}

build_iso() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}Error: ISO build requires root privileges${NC}"
        echo "Please run: sudo ./quick-start.sh"
        return 1
    fi
    
    echo -e "${GREEN}Starting ISO build...${NC}"
    chmod +x scripts/build-iso.sh
    ./scripts/build-iso.sh
}

build_all() {
    echo -e "${GREEN}Building kernel...${NC}"
    build_kernel_gcc
    
    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${GREEN}Building ISO...${NC}"
        build_iso
    else
        echo -e "${YELLOW}Warning: Cannot build ISO without root privileges${NC}"
        echo "Run with sudo to build ISO: sudo ./quick-start.sh"
    fi
}

push_to_github() {
    echo -e "${GREEN}Pushing to GitHub...${NC}"
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: git is not installed${NC}"
        return 1
    fi
    
    # Add and commit
    if [ -z "$(git status --porcelain)" ]; then
        echo "Nothing to commit"
        return 0
    fi
    
    git add -A
    git commit -m "CachyOS Server x86-64-v4: Automated build configuration update"
    git push origin main
    
    echo -e "${GREEN}✅ Successfully pushed to GitHub${NC}"
}

trigger_workflow() {
    echo -e "${GREEN}Triggering GitHub Actions workflow...${NC}"
    
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
        echo "Install from: https://cli.github.com"
        return 1
    fi
    
    read -p "Select compiler (gcc/clang) [gcc]: " compiler
    compiler=${compiler:-gcc}
    
    gh workflow run build-server-v4-iso.yml -f build_type=$compiler
    
    echo -e "${GREEN}✅ Workflow triggered${NC}"
}

check_workflow_status() {
    echo -e "${GREEN}Checking workflow status...${NC}"
    
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
        return 1
    fi
    
    gh run list --workflow=build-server-v4-iso.yml --limit=10
}

cleanup() {
    echo -e "${GREEN}Cleaning up build artifacts...${NC}"
    rm -rf /tmp/cachyos-build-*
    rm -rf /tmp/cachyos-iso-build*
    rm -rf dist/*.iso dist/*.tar.*
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

show_help() {
    cat << 'EOF'
CachyOS Server x86-64-v4 Build System

使用方法 (Usage):
  ./quick-start.sh                    # 启动交互菜单 (Interactive menu)
  make help                            # 显示make命令 (Show make commands)
  
本地构建 (Local builds):
  make build-kernel-gcc               # 使用GCC构建内核
  make build-kernel-clang             # 使用Clang构建内核
  make build-iso                      # 构建ISO (需要root)
  make build-all                      # 完整构建
  
GitHub Actions:
  gh workflow run build-server-v4-iso.yml    # 触发工作流
  gh run list                                 # 查看运行列表
  
清理 (Cleanup):
  make clean                          # 清理构建产物
  make dist-clean                     # 完整清理

更多信息请查看:
  - README.md                         # 项目文档
  - CONTRIBUTING.md                   # 贡献指南
  - config/build.conf                 # 构建配置

EOF
}

# Main loop
main() {
    print_header
    
    while true; do
        print_menu
        read -p "选择 / Choose [0-9]: " choice
        
        case $choice in
            1)
                build_kernel_gcc
                ;;
            2)
                build_kernel_clang
                ;;
            3)
                build_iso
                ;;
            4)
                build_all
                ;;
            5)
                push_to_github
                ;;
            6)
                trigger_workflow
                ;;
            7)
                check_workflow_status
                ;;
            8)
                cleanup
                ;;
            9)
                show_help
                ;;
            0)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
        print_header
    done
}

# Run main function
main
