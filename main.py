#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
========================================
curl 命令转换工具 - 快速获取接口数据
========================================

功能说明：
    1. 从浏览器复制 curl 命令
    2. 粘贴到代码中
    3. 自动解析并发送请求
    4. 将响应数据保存到 JSON 文件

使用场景：
    - 快速测试接口
    - 获取接口数据进行分析
    - 模拟浏览器请求，绕过反爬虫检测

依赖库：
    - uncurl: 解析 curl 命令
    - curl-cffi: 模拟真实浏览器指纹，发送请求
"""

import json
import re
import uncurl
from curl_cffi import requests


def convert_cookie_format(curl_command: str) -> str:
    """
    Cookie 格式转换函数：将 -b 格式转换为 -H 'Cookie:' 格式
    
    功能说明：
        某些 curl 命令使用 -b 或 --cookie 参数传递 Cookie，
        但 uncurl 库可能无法正确解析，需要转换为标准的 -H 'Cookie:' 格式
    
    转换规则：
        -b 'cookie_value'           → -H 'Cookie: cookie_value'
        -b "cookie_value"           → -H "Cookie: cookie_value"
        --cookie 'cookie_value'     → -H 'Cookie: cookie_value'
        --cookie "cookie_value"     → -H "Cookie: cookie_value"
        -b'cookie_value'            → -H 'Cookie: cookie_value'
        --cookie='cookie_value'     → -H 'Cookie: cookie_value'
    
    参数说明：
        curl_command (str): 原始 curl 命令字符串
    
    返回值：
        str: 转换后的 curl 命令字符串
    
    使用示例：
        # 示例 1: 基础使用
        original = "curl 'http://example.com' -b 'session=abc123'"
        converted = convert_cookie_format(original)
        # 结果: "curl 'http://example.com' -H 'Cookie: session=abc123'"
        
        # 示例 2: 在 fetch_from_curl 前使用
        curl_command = '''curl 'http://api.com' -b 'token=xyz' '''
        curl_command = convert_cookie_format(curl_command)  # 转换格式
        fetch_from_curl(curl_command, "output.json")        # 发送请求
    
    注意事项：
        - 如果不需要转换，直接注释掉调用这个函数的代码即可
        - 此函数不会修改已经是 -H 'Cookie:' 格式的命令
        - 支持单引号和双引号两种格式
    """
    
    # ========================================
    # 转换逻辑
    # ========================================
    
    # 正则表达式模式说明：
    # (-b|--cookie)     : 匹配 -b 或 --cookie
    # \s*               : 匹配 0 或多个空格（处理有无空格的情况）
    # =?                : 匹配可选的等号（处理 --cookie= 的情况）
    # \s*               : 匹配 0 或多个空格
    # (['"])            : 匹配单引号或双引号，并捕获（用于保持原格式）
    # (.*?)             : 非贪婪匹配任意字符（Cookie 内容）
    # \2                : 反向引用，匹配与第一个引号相同的结束引号
    
    pattern = r'(-b|--cookie)\s*=?\s*([\'\"])(.*?)\2'
    
    # 替换函数：将匹配到的内容转换为 -H 'Cookie: xxx' 格式
    # match.group(2): 引号类型（单引号或双引号）
    # match.group(3): Cookie 内容
    def replace_func(match):
        quote = match.group(2)      # 获取引号类型（保持原格式）
        cookie_value = match.group(3)  # 获取 Cookie 内容
        return f"-H {quote}Cookie: {cookie_value}{quote}"
    
    # 执行替换
    converted = re.sub(pattern, replace_func, curl_command)
    
    return converted


def fetch_from_curl(curl_command: str, output_file: str = "output.json"):
    """
    核心功能：解析 curl 命令并发送请求，将响应数据保存到 JSON 文件
    
    参数说明：
        curl_command (str): curl 命令字符串（从浏览器复制）
        output_file (str): 输出文件名，默认为 "output.json"
    
    返回值：
        dict/None: 成功返回响应数据字典，失败返回 None
    
    使用示例：
        curl_cmd = '''curl 'https://api.example.com/data' -H 'Authorization: Bearer xxx' '''
        fetch_from_curl(curl_cmd, "my_data.json")
    """
    
    try:
        # ========================================
        # 步骤 1: 解析 curl 命令
        # ========================================
        print("🔄 正在解析 curl 命令...")
        
        # 使用 uncurl 库解析 curl 命令，提取 URL、请求头、Cookie、请求体等信息
        parsed = uncurl.parse_context(curl_command)
        
        # 提取解析后的信息
        url = parsed.url                    # 请求的 URL 地址
        method = parsed.method or 'GET'     # 请求方法（GET/POST等），默认为 GET
        headers = parsed.headers or {}      # 请求头字典
        cookies = parsed.cookies or {}      # Cookie 字典
        data = parsed.data                  # 请求体数据（POST 等方法使用）
        
        # 输出解析结果，便于调试
        print(f"📍 URL: {url}")
        print(f"📮 请求方法: {method}")
        print(f"🔑 请求头数量: {len(headers)}")
        print(f"🍪 Cookie 数量: {len(cookies)}")
        
        # ========================================
        # 步骤 2: 准备请求参数
        # ========================================
        # 处理 POST 请求的数据格式
        # 需要判断数据是 JSON 格式还是表单格式
        json_data = None    # JSON 格式数据（Content-Type: application/json）
        form_data = None    # 表单格式数据（Content-Type: application/x-www-form-urlencoded）
        
        if data:
            try:
                # 尝试将数据解析为 JSON 格式
                # 如果数据是字符串，先转换为字典；如果已是字典，直接使用
                json_data = json.loads(data) if isinstance(data, str) else data
            except (json.JSONDecodeError, TypeError):
                # 如果解析失败，说明是表单数据，直接使用原始数据
                form_data = data
        
        # ========================================
        # 步骤 3: 发送请求
        # ========================================
        print("🌐 正在发送请求...")
        
        # 使用 curl-cffi 发送请求
        # impersonate='chrome110': 模拟 Chrome 110 浏览器的 TLS/HTTP2 指纹，绕过反爬虫检测
        # timeout=30: 请求超时时间为 30 秒
        response = requests.request(
            method=method,              # 请求方法
            url=url,                    # 请求 URL
            headers=headers,            # 请求头
            cookies=cookies,            # Cookie
            json=json_data,             # JSON 数据（如果有）
            data=form_data,             # 表单数据（如果有）
            impersonate='chrome110',    # 模拟浏览器指纹
            timeout=30                  # 超时时间
        )
        
        # ========================================
        # 步骤 4: 检查响应状态
        # ========================================
        # raise_for_status(): 如果状态码不是 2xx，会抛出异常
        response.raise_for_status()
        
        print(f"✅ 请求成功！状态码: {response.status_code}")
        
        # ========================================
        # 步骤 5: 解析响应数据
        # ========================================
        try:
            # 尝试将响应解析为 JSON 格式
            result_data = response.json()
        except json.JSONDecodeError:
            # 如果响应不是 JSON 格式（如 HTML 或纯文本），将内容包装为字典
            print("⚠️  响应不是 JSON 格式，保存为文本内容")
            result_data = {
                "content": response.text,           # 响应的文本内容
                "status_code": response.status_code # HTTP 状态码
            }
        
        # ========================================
        # 步骤 6: 保存到 JSON 文件
        # ========================================
        with open(output_file, 'w', encoding='utf-8') as f:
            # json.dump: 将 Python 字典写入 JSON 文件
            # ensure_ascii=False: 不转义中文字符，保持中文可读
            # indent=2: 格式化输出，每层缩进 2 个空格
            json.dump(result_data, f, ensure_ascii=False, indent=2)
        
        print(f"💾 数据已保存到 {output_file}")
        print(f"📊 数据大小: {len(json.dumps(result_data))} 字符")
        
        # 返回解析后的数据
        return result_data
        
    except requests.RequestException as e:
        # ========================================
        # 错误处理：网络请求相关错误
        # ========================================
        print(f"❌ 请求失败: {e}")
        
        # 如果有响应内容，输出前 500 个字符用于调试
        if hasattr(e, 'response') and e.response is not None:
            print(f"📄 响应内容（前 500 字符）: {e.response.text[:500]}")
        
        return None
    
    except Exception as e:
        # ========================================
        # 错误处理：其他错误（解析错误、文件写入错误等）
        # ========================================
        print(f"❌ 发生错误: {e}")
        return None


# ========================================
# 主程序入口
# ========================================
if __name__ == "__main__":
    """
    使用说明：
    
    1. 打开浏览器开发者工具（F12）
    2. 切换到 Network（网络）标签
    3. 刷新页面或执行操作，找到目标接口请求
    4. 右键点击请求 -> Copy -> Copy as cURL (bash)
    5. 将复制的内容粘贴到下面的 curl_command 变量中
    6. 运行脚本：python main.py
    7. 数据会自动保存到 output.json 文件
    
    注意事项：
    - curl 命令可以使用三引号 ''' 包裹，支持多行
    - 如果需要保存到不同文件，修改第二个参数：fetch_from_curl(curl_command, "my_file.json")
    - 默认模拟 Chrome 110 浏览器，可以绕过大部分反爬虫检测
    """
    
    # ========================================
    # 在这里粘贴你的 curl 命令
    # ========================================
    curl_command = '''
    curl 'https://channels.weixin.qq.com/micro/content/cgi-bin/mmfinderassistant-bin/component/get-finder-native-drama-statistics-list?_aid=468b5399-796b-4601-b39a-d0cef98ab4fb&_rid=694bb1d6-569e6852&_pageUrl=https:%2F%2Fchannels.weixin.qq.com%2Fmicro%2Fcontent%2Fplaylet%2Fstatistic' \
    -H 'Accept: */*' \
    -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8' \
    -H 'Connection: keep-alive' \
    -H 'Content-Type: application/json' \
    -H 'Origin: https://channels.weixin.qq.com' \
    -H 'Referer: https://channels.weixin.qq.com/micro/content/playlet/statistic' \
    -H 'Sec-Fetch-Dest: empty' \
    -H 'Sec-Fetch-Mode: cors' \
    -H 'Sec-Fetch-Site: same-origin' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36' \
    -H 'X-WECHAT-UIN: 2554554891' \
    -H 'finger-print-device-id: 0b48af1d4954cdc03a914ce6e797a069' \
    -H 'sec-ch-ua: "Google Chrome";v="143", "Chromium";v="143", "Not A(Brand";v="24"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "macOS"' \
    --data-raw '{"pageSize":5,"currentPage":1,"startTs":"1763913600","endTs":"1766419200","queryString":"","timestamp":"1766568406685","_log_finder_uin":"","_log_finder_id":"v2_060000231003b20faec8c4e58110c1d4c703e933b07734b84e170b7efafdfd2e42110c3ee8b0@finder","rawKeyBuff":null,"pluginSessionId":null,"scene":7,"reqScene":7}'
    '''
    
    # ========================================
    # 可选步骤：转换 Cookie 格式（如果需要）
    # ========================================
    # 如果你的 curl 命令使用了 -b 参数，可以取消下面这行的注释来转换格式
    # curl_command = convert_cookie_format(curl_command)
    
    # ========================================
    # 执行请求并保存数据
    # ========================================
    # 参数 1: curl 命令字符串
    # 参数 2: 输出文件名（可选，默认为 output.json）
    fetch_from_curl(curl_command, "output.json")
    
    # ========================================
    # 更多使用示例
    # ========================================
    
    # 示例 1: 转换 Cookie 格式后发送请求
    # curl_command = '''curl 'https://api.example.com/data' -b 'session=abc123; token=xyz' '''
    # curl_command = convert_cookie_format(curl_command)  # 转换 -b 为 -H 'Cookie:'
    # fetch_from_curl(curl_command, "data.json")
    
    # 示例 2: 简单的 GET 请求
    # curl_command = '''curl 'https://api.github.com/users/github' '''
    # fetch_from_curl(curl_command, "github_user.json")
    
    # 示例 3: 带认证的 POST 请求
    # curl_command = '''
    # curl 'https://api.example.com/login' \
    #   -H 'Content-Type: application/json' \
    #   --data-raw '{"username":"admin","password":"123456"}'
    # '''
    # fetch_from_curl(curl_command, "login_response.json")
    
    # 示例 4: 批量请求多个接口
    # curl_commands = [
    #     ('''curl 'https://api.example.com/user/1' ''', "user1.json"),
    #     ('''curl 'https://api.example.com/user/2' ''', "user2.json"),
    #     ('''curl 'https://api.example.com/user/3' ''', "user3.json"),
    # ]
    # for cmd, output in curl_commands:
    #     fetch_from_curl(cmd, output)
