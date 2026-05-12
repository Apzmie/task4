#!/bin/bash

# 환경 변수 로드
source /etc/profile.d/agent_env.sh

# 날짜 포맷
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# 1. Health Check (프로세스 및 포트)
# 프로세스 확인 (파일명에 맞게 수정: agent_app 또는 agent_app.py)
PID=$(pgrep -f "agent_app")
if [ -z "$PID" ]; then
    echo "[$DATE] [ERROR] Process not found" >> /var/log/agent-app/monitor.log
    exit 1
fi

# 포트 15034 LISTEN 확인
ss -tuln | grep -q ":15034"
if [ $? -ne 0 ]; then
    echo "[$DATE] [ERROR] Port 15034 not listening" >> /var/log/agent-app/monitor.log
    exit 1
fi

# 2. 방화벽 상태 점검 (경고만)
ufw status | grep -q "Status: active"
if [ $? -ne 0 ]; then
    echo "[WARNING] Firewall is inactive"
fi

# 3. 자원 수집
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
DISK_USED=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

# 4. 임계값 경고 출력 (콘솔용)
[[ $(echo "$CPU_USAGE > 20" | bc -l) -eq 1 ]] && echo "[WARNING] CPU threshold exceeded ($CPU_USAGE% > 20%)"
[[ $MEM_USAGE -gt 10 ]] && echo "[WARNING] MEM threshold exceeded ($MEM_USAGE% > 10%)"
[[ $DISK_USED -gt 80 ]] && echo "[WARNING] DISK threshold exceeded ($DISK_USED% > 80%)"

# 5. 로그 파일 기록
echo "[$DATE] PID:$PID CPU:$CPU_USAGE% MEM:$MEM_USAGE% DISK_USED:$DISK_USED%" >> /var/log/agent-app/monitor.log

# 6. 로그 파일 관리 (10MB 초과 시 정리 - 단순 구현)
FILE_SIZE=$(stat -c%s "/var/log/agent-app/monitor.log")
if [ $FILE_SIZE -gt 10485760 ]; then
    mv /var/log/agent-app/monitor.log /var/log/agent-app/monitor.log.old
    touch /var/log/agent-app/monitor.log
    chown agent-admin:agent-core /var/log/agent-app/monitor.log
fi
