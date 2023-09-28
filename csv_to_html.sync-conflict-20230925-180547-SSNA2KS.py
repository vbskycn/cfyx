# -*- coding: utf-8 -*-

from datetime import datetime
import os
import pandas as pd
import textwrap
import html

def get_file_creation_time(file_path):
    # 获取文件的元数据
    file_stat = os.stat(file_path)
    
    # 获取文件的创建时间
    creation_time = file_stat.st_ctime
    
    # 转换为可读的时间格式
    formatted_time = datetime.fromtimestamp(creation_time).strftime('%Y-%m-%d %H:%M:%S')
    
    return formatted_time

def csv_to_html(csv_file):
    # 读取 CSV 文件
    df = pd.read_csv(csv_file)
    
    # 生成 HTML 表格
    html_table = df.to_html(index=False)
    
    # 获取 CSV 文件的创建时间
    csv_creation_time = get_file_creation_time(csv_file)
    
    # 生成 HTML 页面
    html_content = textwrap.dedent(f'''
        <html>
        <head>
            <title>CloudFlare优质IP自动测试</title>
            <meta charset="utf-8">
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    margin: 0;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                }}
                
                .container {{
                    max-width: 800px;  /* 设置表格最大宽度 */
                }}
                
                table {{
                    border-collapse: collapse;
                    width: 100%;
                    table-layout: fixed;  /* 固定表格布局 */
                }}
                
                th, td {{
                    border: 1px solid #ddd;
                    padding: 8px;
                }}
                
                th {{
                    background-color: #f2f2f2;
                    font-weight: bold;
                }}
                
                tr:nth-child(even) {{
                    background-color: #f9f9f9;
                }}
                
                .header {{
                    text-align: center;
                    margin-bottom: 20px;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h2>CloudFlare优质IP自动测试</h2>
                    <p>测试时间：{html.escape(csv_creation_time)}</p>
                    <p>测试环境：江西电信</p>
                    <p>测试结果如下：</p>
                </div>
                {html_table}
            </div>
        </body>
        </html>
    ''')
    
    return html_content

# 指定 CSV 文件路径
csv_file_path = '/www/wwwroot/cfipopw/result.csv'

# 生成 HTML 内容
html_content = csv_to_html(csv_file_path)

# 将 HTML 内容保存为文件（命名为index.html）
html_file_path = '/www/wwwroot/cfipopw/index.html'
with open(html_file_path, 'w', encoding='utf-8') as html_file:
    html_file.write(html_content)

print(f'HTML 文件已生成：{html_file_path}')
