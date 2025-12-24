## DZMPythonBaseProject

* 自用 `Python3` 基础空框架，方便快速进入开发调试

* [Mac Python 使用 pyenv 多版本管理](https://blog.csdn.net/zz00008888/article/details/123041126)

* [Python 安装 pyenv 版本管理（Windows）](https://blog.csdn.net/zz00008888/article/details/155769018)

* [venv 虚拟环境使用文档](https://blog.csdn.net/zz00008888/article/details/155735792)

* 快速安装依赖环境，并使用虚拟环境

  * 初始化环境、安装依赖、进入虚拟环境：`mac/linux` 执行 `$ source rinstall.sh`

  * 初始化环境、安装依赖、进入虚拟环境：`windows` 使用 `Git Bash` 执行 `$ source rinstall.sh`
  
    不要使用 `PowerShell`，`rinstall.sh` 不支持 `PowerShell`

  * 手动进入虚拟环境：

      `Mac/Liunx`: `$ source venv/bin/activate`

      `Winodws`: `$ source venv/Scripts/activate`

  * 手动生成依赖清单 `$ pip freeze > requirements.txt`

  * 手动退出虚拟环境 `$ deactivate`