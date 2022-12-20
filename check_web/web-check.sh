#! /bin/bash

url=""     # edit me
Slack_webhook=""  # edit me
date_str=$(date '+%Y/%m/%d %H:%M:%S')
date=$(date '+%Y%m%d')

httpstatus=$(curl -s "$url" -o /dev/null -w "%{http_code}")
curlresult=$?

if [ "$curlresult" -ne 0 ]; then
curl -X POST -H 'Content-type: application/json' --data '{"text":" HTTP 접속 이상 "}' $Slack_webhook
elif [ "$httpstatus" -ge 400 ]; then
curl -X POST -H 'Content-type: application/json' --data '{"text":" HTTP 상태 이상 "}' $Slack_webhook
fi