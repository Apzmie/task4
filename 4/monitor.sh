#!/bin/bash

# 1. 환경 변수 및 경로 설정
source /etc/profile.d/agent_env.sh
DATE=$(date "+%Y-%m-%d %H:%M:%S")
LOG_PATH="/var/log/agent-app/monitor.log"
APP_NAME="agent_app"

# 2. Health Check
PID=$(pgrep -f "$APP_NAME" | tr '\n' ',' | sed 's/,$//')
if [ -z "$PID" ]; then
    echo "[$DATE] [ERROR] Process not found" >> $LOG_PATH
    exit 1
fi

# 3. 방화벽 상태 점검
UFW_STATUS=$(ufw status 2>&1)
if [[ "$UFW_STATUS" != *"Status: active"* ]]; then
    echo "[WARNING] Firewall is inactive"
fi

# 4. 자원 수집
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
DISK_USED=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

# 5. 임계값 경고 (bc 대신 awk 사용으로 오류 방지)
# CPU > 20%
[[ $(awk -v n1="$CPU_USAGE" -v n2="20" 'BEGIN{print (n1>n2)?1:0}') -eq 1 ]] && echo "[WARNING] CPU threshold exceeded ($CPU_USAGE%)"
# MEM > 10%
[[ $MEM_USAGE -gt 10 ]] && echo "[WARNING] MEM threshold exceeded ($MEM_USAGE%)"
# DISK > 80%
[[ $DISK_USED -gt 80 ]] && echo "[WARNING] DISK threshold exceeded ($DISK_USED%)"

# 6. 로그 기록
echo "[$DATE] PID:$PID CPU:$CPU_USAGE% MEM:$MEM_USAGE% DISK_USED:$DISK_USED%" >> $LOG_PATH

# 7. 로그 로테이션
if [ -f "$LOG_PATH" ] && [ $(stat -c%s "$LOG_PATH") -gt 10485760 ]; then
    mv "$LOG_PATH" "${LOG_PATH}.old"
    touch "$LOG_PATH"
    chmod 660 "$LOG_PATH"
fi

LOG_DIR="/var/log/agent-app"
LOG_FILE="$LOG_DIR/monitor.log"

# 로그 크기 확인 (bytes)
if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -ge 10485760 ]; then

    # 기존 로그 밀기 (10개 유지)
    for i in 9 8 7 6 5 4 3 2 1; do
        if [ -f "$LOG_FILE.$i" ]; then
            mv "$LOG_FILE.$i" "$LOG_FILE.$((i+1))"
        fi
    done

    # 현재 로그 -> .1
    mv "$LOG_FILE" "$LOG_FILE.1"

    # 새 로그 생성
    touch "$LOG_FILE"
fi
