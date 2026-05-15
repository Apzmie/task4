# task5
```bash
docker run -d --name linux-mission2 --privileged -p 20023:15034 ubuntu:24.04 sleep infinity
apt update && apt install -y python3 procps net-tools iproute2 curl adduser nano

adduser mission-user
mkdir -p /home/mission-user/mission/upload_files
mkdir -p /home/mission-user/mission/api_keys
mkdir -p /home/mission-user/mission/logs

chown -R mission-user:mission-user /home/mission-user/mission
su - mission-user

# .bashrc에 환경변수 추가 (로그아웃 후 재접속해도 유지되도록)
cat <<EOF >> ~/.bashrc
export AGENT_HOME=/home/mission-user/mission
export AGENT_PORT=15034
export AGENT_UPLOAD_DIR=\$AGENT_HOME/upload_files
export AGENT_KEY_PATH=\$AGENT_HOME/api_keys
export AGENT_LOG_DIR=\$AGENT_HOME/logs
export MEMORY_LIMIT=256
export CPU_MAX_OCCUPY=70
export MULTI_THREAD_ENABLE=true
EOF

# 환경변수 즉시 적용
source ~/.bashrc

# secret.key 생성
echo "agent_api_key_test" > $AGENT_HOME/api_keys/secret.key

chmod +x /home/mission-user/mission/monitor.sh
chmod +x /home/mission-user/mission/agent-leak-app
/home/mission-user/mission/agent-leak-app
/home/mission-user/mission/monitor.sh
--------------------------------------------------------
06:32:37 | PID:3883 | 2212KB | 0.0% | 1.8%
06:32:37 | PID:3884 | 72852KB | 0.4% | 2.0%
06:32:38 | PID:3883 | 2212KB | 0.0% | 1.5%
06:32:38 | PID:3884 | 72852KB | 0.4% | 1.7%
06:32:39 | PID:3883 | 2212KB | 0.0% | 1.4%
06:32:39 | PID:3884 | 98456KB | 0.5% | 2.0%
06:32:40 | PID:3883 | 2212KB | 0.0% | 1.2%
06:32:40 | PID:3884 | 98456KB | 0.5% | 1.8%
```
