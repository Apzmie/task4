#!/bin/bash

# 로그 파일 경로 설정
LOG_FILE="/home/mission-user/mission/logs/monitor.log"

echo "시작 시간: $(date)" > $LOG_FILE
echo "시간 | 프로세스ID | 메모리사용량(KB) | 메모리(%) | CPU(%)" >> $LOG_FILE
echo "--------------------------------------------------------"

while true; doㄴ
    # agent-leak-app의 PID(프로세스 번호)를 찾습니다.
    PID=$(pgrep -f agent-leak-app)

    if [ -n "$PID" ]; then
        # ps 명령어로 메모리(rss), 메모리비율(pmem), CPU비율(pcpu)을 가져옵니다.
        STATS=$(ps -p $PID -o rss,pmem,pcpu --no-headers)
        TIMESTAMP=$(date +%H:%M:%S)
        
        # 화면과 로그 파일에 동시에 출력
        echo "$TIMESTAMP | $PID | $STATS" | tee -a $LOG_FILE
    else
        echo "$(date +%H:%M:%S) | [경고] agent-leak-app이 실행 중이 아닙니다."
    fi

    # 1초마다 반복
    sleep 1
done
