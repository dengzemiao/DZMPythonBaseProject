@echo off
chcp 65001 >nul
REM ========================================
REM 项目依赖安装脚本
REM 
REM 适用系统：Windows 系统 (Windows 7/8/10/11)
REM 
REM 使用方法：
REM   方法1: 直接双击运行 install.bat
REM   方法2: 在命令行中执行: install.bat
REM   方法3: 在 PowerShell 中执行: .\install.bat
REM 
REM Mac/Linux 用户请使用: install.sh
REM ========================================

REM 检查 Python 环境是否安装
echo · 检查 Python 环境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ✗ 错误: 未检测到 Python，请先安装 Python
    echo · 提示: 访问 https://www.python.org/downloads/ 下载安装 Python
    pause
    exit /b 1
)

REM 显示 Python 版本
for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo ✓ 检测到 %PYTHON_VERSION%

REM 检查虚拟环境是否存在，不存在则创建
if not exist "venv" (
    echo · 虚拟环境不存在，正在创建...
    python -m venv venv
    if errorlevel 1 (
        echo ✗ 错误: 创建虚拟环境失败
        echo · 可能的原因:
        echo   1. Python 版本过旧，不支持 venv 模块（需要 Python 3.3+）
        echo   2. 磁盘空间不足
        echo   3. 权限问题
        pause
        exit /b 1
    )
    echo ✓ 虚拟环境创建完成
) else (
    echo ✓ 虚拟环境已存在
)

REM 激活虚拟环境
echo · 激活虚拟环境...
call venv\Scripts\activate.bat

REM 升级 pip
echo · 升级虚拟环境 pip...
python -m pip install --upgrade pip

REM 安装依赖
echo.
echo · 安装虚拟环境依赖包...
pip install -r requirements.txt

echo.
echo ✓ 安装完成！
echo.
echo · 虚拟环境已在当前命令行窗口中激活
echo · 可以直接使用 python 命令运行项目
echo.
pause

