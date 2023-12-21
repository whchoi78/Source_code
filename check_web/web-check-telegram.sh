#! /bin/bash

url=""     # edit me
telegram_webhook=""  # edit me
date_str=$(date '+%Y/%m/%d %H:%M:%S')
date=$(date '+%Y%m%d')

httpstatus=$(curl -k -s "$url" -o /dev/null -w "%{http_code}")
curlresult=$?

if [ "$curlresult" -ne 0 ]; then
curl -k $telegram_webhook -d "chat_id=" --data-urlencode "text=HTTP 접속 불가"
elif [ "$httpstatus" -ge 400 ]; then
curl -k $telegram_webhook -d "chat_id=" --data-urlencode "text=HTTP 상태 이상"
sleep 60s
httpstatus_2=$(curl -s "$url" -o /dev/null -w "%{http_code}")
curlresult_2=$?
if [ "$httpstatus_2" -eq 200 ]; then
curl -k $telegram_webhook -d "chat_id=" --data-urlencode "text=HTTP 정상 작동"
fi
fi