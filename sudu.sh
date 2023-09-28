#!/bin/bash

# 获取当前的日期和时间
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%H:%M:%S")

# 读取CSV文件内容
csv_content=$(cat /root/cfipopw/result.csv)

# 构建表格标题
table_header="列1 | 列2 | 列3\n--- | --- | ---"

# 构建表格内容
table_content=$(echo "$csv_content" | awk -F',' 'BEGIN { OFS=" | " } { print $1, $2, $3 , $4, $5, $6 }')

# 构建通知消息，包括日期、时间和表格
pushmessage="测试时间：$current_date $current_time  测试网络：江西电信   测试结果： $table_content"


# 发送Telegram通知
telegramBotToken="6498531824:AAH3r_jkiSBS4kQzJ_8r5hBzimjci8z6Zc8"
telegramBotUserId="615392780"

tgaction() {
  message_text="$pushmessage"
  MODE='html'
  URL="https://api.telegram.org/bot${telegramBotToken}/sendMessage"
  res=$(timeout 20s curl -s -X POST $URL -d chat_id=${telegramBotUserId} -d parse_mode=${MODE} -d text="${message_text}")
  if [ $? == 124 ]; then
    echo 'TG API请求超时，请检查网络是否正常并能够访问Telegram'
    exit 1
  fi
  resSuccess=$(echo "$res" | jq -r ".ok")
  if [[ $resSuccess = "true" ]]; then
    echo "Telegram通知发送成功-欢迎使用"
  else
    echo "Telegram通知发送失败，请检查Telegram Bot Token和User ID是否正确"
  fi
}

# 发送Telegram通知
tgaction

#syncthing
