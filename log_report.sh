#!/bin/bash


LOG="/home/leo/access.log"
EMAIL="z16041987@mail.ru"
HOUR_AGO=$(date -d "1 hour ago" "+%d/%b/%Y:%H:%M:%S")
NOW=$(date "+%d/%b/%Y:%H:%M:%S")

IP=$(awk '{ip[$1]++} END {for (i in ip) print ip[i], i}' "$LOG" | sort -rn | head -1 | awk '{print "Самый частый IP:", $2, "-", $1, "запросов"}')
URL=$(awk '{url[$7]++} END {for (u in url) print url[u], u}' "$LOG" | sort -rn | head -1 | awk '{print "Самый частый URL:", $2, "-", $1, "запросов"}')
ERR=$(awk '{if ($9 ~ /^[45]/) errors[$9 " " $7]++} END {for (e in errors) print errors[e], e}' "$LOG" | sort -rn)
HTTP=$(awk '{http[$9]++} END {for (h in http) print http[h], h}' "$LOG" | sort -rn)
{
echo "===================================================="
echo "ОТЧЁТ ЗА ЧАС"
echo "Период: $HOUR_AGO - $NOW"
echo "===================================================="
echo "$IP"
echo " "
echo "$URL"
echo " "
echo "Ошибки веб-сервера:"
echo "$ERR"
echo " "
echo "HTTP-коды ответов:"
echo "$HTTP"
} | mail -s "Web report $(date '+%Y-%m-%d %H:00')" "$EMAIL"
