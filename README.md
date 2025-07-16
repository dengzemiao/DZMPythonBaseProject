## DZMPythonBaseProject

* 自用 `Python` 基础工程，`Python 3.3+` 版本使用。

## 虚拟环境

* 创建虚拟环境

  ```sh
  $ python -m venv venv
  ```

* 运行虚拟环境

  ```sh
  # mac
  $ source venv/bin/activate

  # windows
  $ venv\Scripts\activate
  ```

* 导出虚拟环境依赖

  ```sh
  $ pip freeze > requirements.txt
  ```

* 退出虚拟环境

  ```sh
  $ deactivate
  ```

* 其他机器运行项目

  ```sh
  # 创建虚拟环境
  $ python -m venv venv

  # 运行虚拟环境（根据系统使用不同命令）
  $ source venv/bin/activate
  
  # 恢复虚拟环境
  $ pip install -r requirements.txt
  ```