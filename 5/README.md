# task5
```bash
docker run -d --name linux-mission2 --privileged -p 20023:15034 ubuntu:24.04 sleep infinity
apt update && apt install -y python3 procps net-tools iproute2 curl

useradd -m mission-user
mkdir -p /home/mission-user/mission
chown -R mission-user:mission-user /home/mission-user/mission
su - mission-user

# 디렉토리 생성
export AGENT_HOME=/home/mission-user/mission
mkdir -p $AGENT_HOME/upload_files
mkdir -p $AGENT_HOME/api_keys
mkdir -p $AGENT_HOME/logs

# secret.key 생성
echo "agent_api_key_test" > $AGENT_HOME/api_keys/secret.key

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
```
