#!/bin/bash

# ========================================
# 项目依赖安装脚本
# 
# 功能说明：
#   1. 检查 Python 3 环境是否已安装
#   2. 创建或使用现有的 Python 虚拟环境
#   3. 激活虚拟环境
#   4. 升级 pip 到最新版本
#   5. 安装 requirements.txt 中列出的所有依赖包
# 
# 适用系统：macOS / Linux / Unix / Windows (Git Bash)
# 
# 使用方法：
#   ./install.sh              # 直接执行（推荐）
#   或
#   source install.sh          # 执行后虚拟环境会在当前 shell 中保持激活
#   或
#   . install.sh               # 同上，更简洁的写法
# 
# Windows 用户：可以使用 Git Bash 运行此脚本
# ========================================

# ========================================
# 颜色定义（ANSI 转义码）
# ========================================
# 用于在终端中输出彩色文本，提升用户体验
# \033[0;32m 表示绿色，\033[0m 表示重置颜色
GREEN='\033[0;32m'      # 绿色：用于成功信息
YELLOW='\033[1;33m'     # 黄色：用于警告或提示信息
BLUE='\033[0;34m'       # 蓝色：用于普通进度信息
RED='\033[0;31m'        # 红色：用于错误信息
NC='\033[0m'            # No Color：重置颜色，恢复终端默认颜色

# ========================================
# 步骤 1: 检查 Python 环境是否安装
# ========================================
printf "${BLUE}· 检查 Python 环境...${NC}\n"

# command -v python3: 检查 python3 命令是否存在于系统 PATH 中
# &> /dev/null: 将标准输出和错误输出都重定向到 /dev/null（丢弃输出）
# ! : 逻辑非，如果命令不存在则执行 if 块
if ! command -v python3 &> /dev/null; then
    # Python 3 未安装，输出错误信息并退出脚本
    printf "${RED}✗ 错误: 未检测到 Python 3，请先安装 Python 3${NC}\n"
    printf "${YELLOW}· 提示: 访问 https://www.python.org/downloads/ 下载安装 Python${NC}\n"
    exit 1  # 退出码 1 表示错误
fi

# ========================================
# 步骤 2: 显示检测到的 Python 版本
# ========================================
# python3 --version: 获取 Python 版本信息
# 2>&1: 将标准错误重定向到标准输出（确保错误信息也被捕获）
# $(...): 命令替换，将命令的输出结果赋值给变量
PYTHON_VERSION=$(python3 --version 2>&1)
printf "${GREEN}✓ 检测到 ${PYTHON_VERSION}${NC}\n"

# ========================================
# 步骤 3: 检查虚拟环境是否存在，不存在则创建
# ========================================
# [ ! -d "venv" ]: 检查 venv 目录是否存在
# ! : 逻辑非
# -d : 测试是否为目录
if [ ! -d "venv" ]; then
    # 虚拟环境不存在，需要创建
    printf "${YELLOW}· 虚拟环境不存在，正在创建...${NC}\n"
    
    # python3 -m venv venv: 使用 Python 的 venv 模块创建虚拟环境
    # -m venv: 以模块方式运行 venv
    # venv: 虚拟环境的目录名称
    python3 -m venv venv
    
    # $?: 上一个命令的退出状态码
    # -ne 0: 不等于 0（0 表示成功，非 0 表示失败）
    if [ $? -ne 0 ]; then
        # 创建虚拟环境失败，输出错误信息和可能的原因
        printf "${RED}✗ 错误: 创建虚拟环境失败${NC}\n"
        printf "${YELLOW}· 可能的原因:${NC}\n"
        printf "${YELLOW}  1. Python 版本过旧，不支持 venv 模块（需要 Python 3.3+）${NC}\n"
        printf "${YELLOW}  2. 磁盘空间不足${NC}\n"
        printf "${YELLOW}  3. 权限问题${NC}\n"
        exit 1  # 退出脚本
    fi
    printf "${GREEN}✓ 虚拟环境创建完成${NC}\n"
else
    # 虚拟环境已存在，跳过创建步骤
    printf "${GREEN}✓ 虚拟环境已存在${NC}\n"
fi

# ========================================
# 步骤 4: 激活虚拟环境
# ========================================
printf "${BLUE}· 激活虚拟环境...${NC}\n"

# 初始化 Windows 标识变量（0 表示非 Windows，1 表示 Windows）
IS_WINDOWS=0

# 检测操作系统类型
# Windows 系统：虚拟环境的激活脚本位于 venv/Scripts/activate
# macOS/Linux 系统：虚拟环境的激活脚本位于 venv/bin/activate
# [ -f "path" ]: 检查文件是否存在且为普通文件

if [ -f "venv/Scripts/activate" ]; then
    # Windows 系统 (Git Bash)
    # source: 在当前 shell 中执行脚本（而不是创建子 shell）
    # 这样可以确保虚拟环境变量在当前 shell 中生效
    source venv/Scripts/activate
    
    # 设置 Windows 标识
    IS_WINDOWS=1
    
    # Windows 环境下设置 UTF-8 编码环境变量
    # 原因：Windows 默认使用 GBK 编码，pip 读取包含中文的 requirements.txt 时会报编码错误
    # PYTHONIOENCODING=utf-8: 强制 Python 使用 UTF-8 编码处理输入输出
    # PYTHONUTF8=1: 启用 Python 的 UTF-8 模式（Python 3.7+）
    export PYTHONIOENCODING=utf-8
    export PYTHONUTF8=1
    
elif [ -f "venv/bin/activate" ]; then
    # macOS / Linux 系统
    # 在 Unix 系统中，激活脚本位于 bin 目录
    source venv/bin/activate
else
    # 两个激活脚本都不存在，说明虚拟环境创建异常
    printf "${RED}✗ 错误: 找不到虚拟环境激活脚本${NC}\n"
    printf "${YELLOW}· 虚拟环境可能未正确创建${NC}\n"
    exit 1
fi

# ========================================
# 步骤 5: 根据操作系统选择 pip 命令
# ========================================
# 在 Windows 上，直接使用 pip 命令升级 pip 可能会失败
# 需要使用 python -m pip 的方式，通过 Python 模块机制执行 pip
# 这样可以避免权限问题和路径问题

if [ $IS_WINDOWS -eq 1 ]; then
    # Windows 系统：使用 python -m pip 方式
    PIP_CMD="python -m pip"
else
    # macOS / Linux 系统：直接使用 pip 命令即可
    PIP_CMD="pip"
fi

# ========================================
# 步骤 6: 升级 pip 到最新版本
# ========================================
printf "${BLUE}· 升级虚拟环境 pip...${NC}\n"

# 使用之前确定的 pip 命令升级 pip
# --upgrade: 升级到最新版本
# 注意：这里使用的是虚拟环境中的 pip，不是系统全局的 pip
$PIP_CMD install --upgrade pip

# 检查升级是否成功
if [ $? -ne 0 ]; then
    # 升级失败，输出错误信息
    printf "${RED}✗ 错误: 升级 pip 失败${NC}\n"
    printf "${YELLOW}· 请检查网络连接或 pip 配置${NC}\n"
    exit 1
fi
printf "${GREEN}✓ pip 升级完成${NC}\n"

# ========================================
# 步骤 7: 安装项目依赖包
# ========================================
# 输出空行，使输出更清晰
printf "\n"
printf "${BLUE}· 安装虚拟环境依赖包...${NC}\n"

# 从 requirements.txt 文件安装所有依赖包
# -r requirements.txt: 从指定文件读取依赖列表并安装
# requirements.txt 文件应包含项目所需的所有 Python 包及其版本要求
$PIP_CMD install -r requirements.txt

# 检查安装是否成功
if [ $? -ne 0 ]; then
    # 安装失败，输出错误信息
    printf "${RED}✗ 错误: 安装依赖包失败${NC}\n"
    printf "${YELLOW}· 请检查 requirements.txt 文件是否存在或网络连接是否正常${NC}\n"
    exit 1
fi

# ========================================
# 步骤 8: 安装完成提示
# ========================================
printf "\n"
printf "${GREEN}✓ 安装完成！${NC}\n"

# 脚本执行完毕
# 如果使用 source 或 . 命令执行脚本，虚拟环境会在当前 shell 中保持激活状态
# 如果使用 ./install.sh 执行，虚拟环境会在脚本结束后自动退出
