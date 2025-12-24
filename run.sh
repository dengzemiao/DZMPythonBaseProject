#!/bin/bash

# ========================================
# Python 项目运行脚本
# 
# 功能说明：
#   1. 检查虚拟环境是否存在
#   2. 智能激活虚拟环境（避免重复激活）
#   3. 运行 main.py 脚本
# 
# 适用系统：macOS / Linux / Unix / Windows (Git Bash)
# 
# 使用方法：
#   ./run.sh              # 直接执行
#   或
#   source run.sh         # 执行后虚拟环境会在当前 shell 中保持激活
#   或
#   . run.sh              # 同上，更简洁的写法
# 
# Windows 用户：可以使用 Git Bash 运行此脚本
# ========================================

# ========================================
# 颜色定义（ANSI 转义码）
# ========================================
GREEN='\033[0;32m'      # 绿色：用于成功信息
YELLOW='\033[1;33m'     # 黄色：用于警告或提示信息
BLUE='\033[0;34m'       # 蓝色：用于普通进度信息
RED='\033[0;31m'        # 红色：用于错误信息
NC='\033[0m'            # No Color：重置颜色

# ========================================
# 全局变量
# ========================================
# 获取当前脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PATH="${SCRIPT_DIR}/venv"
IS_WINDOWS=0  # Windows 标识变量

# ========================================
# 函数：激活虚拟环境
# ========================================
activate_venv() {
    if [ -f "venv/Scripts/activate" ]; then
        # Windows 系统 (Git Bash)
        source venv/Scripts/activate
        IS_WINDOWS=1
        # Windows 环境下设置 UTF-8 编码
        export PYTHONIOENCODING=utf-8
        export PYTHONUTF8=1
    elif [ -f "venv/bin/activate" ]; then
        # macOS / Linux 系统
        source venv/bin/activate
    else
        # 找不到激活脚本
        printf "${RED}✗ 错误: 找不到虚拟环境激活脚本${NC}\n"
        printf "${YELLOW}· 虚拟环境可能未正确创建，请重新运行 rinstall.sh${NC}\n"
        exit 1
    fi
}

# ========================================
# 步骤 1: 检查虚拟环境是否存在
# ========================================
if [ ! -d "venv" ]; then
    # 虚拟环境不存在，提示用户先运行安装脚本
    printf "${RED}✗ 错误: 虚拟环境不存在${NC}\n"
    printf "${YELLOW}· 请先运行安装脚本创建虚拟环境:${NC}\n"
    printf "${YELLOW}  source rinstall.sh${NC}\n"
    printf "${YELLOW}  或${NC}\n"
    printf "${YELLOW}  ./rinstall.sh${NC}\n"
    exit 1
fi

# ========================================
# 步骤 2: 智能检测并激活虚拟环境
# ========================================
# VIRTUAL_ENV 是虚拟环境激活后自动设置的环境变量
if [ -n "$VIRTUAL_ENV" ]; then
    # 已经在虚拟环境中，检查是否是当前项目的虚拟环境
    if [ "$VIRTUAL_ENV" = "$VENV_PATH" ] || [ "$VIRTUAL_ENV" = "$(cd "$VENV_PATH" 2>/dev/null && pwd)" ]; then
        # 当前项目的虚拟环境已激活，跳过激活步骤
        printf "${GREEN}✓ 虚拟环境已激活（当前项目）${NC}\n"
        
        # 检测操作系统类型（用于后续选择 Python 命令）
        if [ -f "venv/Scripts/activate" ]; then
            IS_WINDOWS=1
            # Windows 环境下确保设置 UTF-8 编码
            export PYTHONIOENCODING=utf-8
            export PYTHONUTF8=1
        fi
    else
        # 激活的是其他项目的虚拟环境，提示并切换
        printf "${YELLOW}⚠ 检测到已激活其他虚拟环境${NC}\n"
        printf "${YELLOW}· 切换到当前项目的虚拟环境...${NC}\n"
        activate_venv
    fi
else
    # 未激活任何虚拟环境，执行激活
    printf "${BLUE}· 激活虚拟环境...${NC}\n"
    activate_venv
fi

# ========================================
# 步骤 3: 检查 main.py 文件是否存在
# ========================================
if [ ! -f "main.py" ]; then
    printf "${RED}✗ 错误: 找不到 main.py 文件${NC}\n"
    printf "${YELLOW}· 请确保 main.py 文件存在于当前目录${NC}\n"
    exit 1
fi

# ========================================
# 步骤 4: 运行 Python 脚本
# ========================================
printf "${BLUE}· 运行 main.py...${NC}\n"
printf "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# 根据操作系统选择 Python 命令
# Windows 使用 python，macOS/Linux 使用 python3
if [ $IS_WINDOWS -eq 1 ]; then
    python main.py
else
    python3 main.py
fi

# 保存脚本的退出状态码
EXIT_CODE=$?

printf "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# ========================================
# 步骤 5: 检查运行结果
# ========================================
if [ $EXIT_CODE -eq 0 ]; then
    printf "${GREEN}✓ 脚本执行完成${NC}\n"
else
    printf "${RED}✗ 脚本执行失败，退出码: ${EXIT_CODE}${NC}\n"
    exit $EXIT_CODE
fi
