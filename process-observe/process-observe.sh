#!/bin/sh

commname="/usr/sbin/nginx"       #edit me
webhook="I" #edit me
HOSTNAME=$(hostname)

#프로세스 카운트 조회 후 개수가 0개일 경우 웹훅으로 알림 전송
count=$(ps ax -o command | grep "$commname" | grep -v "^grep" | wc -l)

if [ "$count" -eq 0 ]; then
curl -X POST -H 'Content-type: application/json' --data '{"text":"'"${HOSTNAME}"' Server '"${comname}"' process down please check server"}' $webhook
fi