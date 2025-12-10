#!/bin/bash

# ========================================
# 项目依赖安装脚本
# 
# 适用系统：macOS / Linux / Unix / Windows (Git Bash)
# 
# 使用方法：
#   ./install.sh              # 直接执行
#   或
#   source install.sh          # 执行后虚拟环境会在当前 shell 中保持激活
#   或
#   . install.sh               # 同上，更简洁的写法
# 
# Windows 用户：可以使用 Git Bash 运行此脚本
# ========================================

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查 Python 环境是否安装
printf "${BLUE}· 检查 Python 环境...${NC}\n"
if ! command -v python3 &> /dev/null; then
    printf "${RED}✗ 错误: 未检测到 Python 3，请先安装 Python 3${NC}\n"
    printf "${YELLOW}· 提示: 访问 https://www.python.org/downloads/ 下载安装 Python${NC}\n"
    exit 1
fi

# 显示 Python 版本
PYTHON_VERSION=$(python3 --version 2>&1)
printf "${GREEN}✓ 检测到 ${PYTHON_VERSION}${NC}\n"

# 检查虚拟环境是否存在，不存在则创建
if [ ! -d "venv" ]; then
    printf "${YELLOW}· 虚拟环境不存在，正在创建...${NC}\n"
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        printf "${RED}✗ 错误: 创建虚拟环境失败${NC}\n"
        printf "${YELLOW}· 可能的原因:${NC}\n"
        printf "${YELLOW}  1. Python 版本过旧，不支持 venv 模块（需要 Python 3.3+）${NC}\n"
        printf "${YELLOW}  2. 磁盘空间不足${NC}\n"
        printf "${YELLOW}  3. 权限问题${NC}\n"
        exit 1
    fi
    printf "${GREEN}✓ 虚拟环境创建完成${NC}\n"
else
    printf "${GREEN}✓ 虚拟环境已存在${NC}\n"
fi

# 激活虚拟环境
printf "${BLUE}· 激活虚拟环境...${NC}\n"
# 检测操作系统类型，Windows 使用 Scripts/activate，macOS/Linux 使用 bin/activate
if [ -f "venv/Scripts/activate" ]; then
    # Windows (Git Bash)
    source venv/Scripts/activate
    # Windows 环境下设置 UTF-8 编码，避免 pip 读取 requirements.txt 时出现编码错误
    export PYTHONIOENCODING=utf-8
    export PYTHONUTF8=1
elif [ -f "venv/bin/activate" ]; then
    # macOS / Linux
    source venv/bin/activate
else
    printf "${RED}✗ 错误: 找不到虚拟环境激活脚本${NC}\n"
    printf "${YELLOW}· 虚拟环境可能未正确创建${NC}\n"
    exit 1
fi

# 升级 pip（在 Windows 上需要 UTF-8 编码支持）
printf "${BLUE}· 升级虚拟环境 pip...${NC}\n"
pip install --upgrade pip
if [ $? -ne 0 ]; then
    printf "${RED}✗ 错误: 升级 pip 失败${NC}\n"
    printf "${YELLOW}· 请检查网络连接或 pip 配置${NC}\n"
    exit 1
fi
printf "${GREEN}✓ pip 升级完成${NC}\n"

# 安装依赖
printf "\n"
printf "${BLUE}· 安装虚拟环境依赖包...${NC}\n"
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    printf "${RED}✗ 错误: 安装依赖包失败${NC}\n"
    printf "${YELLOW}· 请检查 requirements.txt 文件是否存在或网络连接是否正常${NC}\n"
    exit 1
fi

printf "\n"
printf "${GREEN}✓ 安装完成！${NC}\n"
