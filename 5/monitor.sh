#!/bin/bash

# 로그 파일 경로 설정
LOG_FILE="/home/mission-user/mission/logs/monitor.log"

echo "시작 시간: $(date)" > $LOG_FILE
echo "시간 | 프로세스ID | 메모리사용량(KB) | 메모리(%) | CPU(%)" >> $LOG_FILE
echo "--------------------------------------------------------"

while true; do
    # agent-leak-app의 PID들을 가져와서 공백으로 구분된 한 줄로 만듭니다.
    PIDS=$(pgrep -f agent-app-leak | tr '\n' ',' | sed 's/,$//')

    if [ -n "$PIDS" ]; then
        # 여러 PID를 콤마(,)로 연결하여 ps 명령어에 전달합니다.
        TIMESTAMP=$(date +%H:%M:%S)
        
        # ps 결과가 여러 줄 나올 수 있으므로, 각 줄마다 앞에 시간을 붙여서 출력합니다.
        ps -p "$PIDS" -o pid,rss,pmem,pcpu --no-headers | while read -r pid rss pmem pcpu; do
            echo "$TIMESTAMP | PID:$pid | ${rss}KB | ${pmem}% | ${pcpu}%" | tee -a $LOG_FILE
        done
    else
        echo "$(date +%H:%M:%S) | [경고] agent-app-leak이 실행 중이 아닙니다."
    fi

    # 1초마다 반복
    sleep 1
done
