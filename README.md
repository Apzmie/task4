# task4

- [x] SSH 포트 변경(20022) 및 Root 원격 접속 차단 설정 확인 내역
- [x] 방화벽(UFW 또는 firewalld) 활성화 및 20022/tcp, 15034/tcp만 허용 내역
- [x] 계정/그룹(agent-admin/dev/test, agent-common/core) 생성 확인 내역
- [x] 디렉토리 구조 및 권한(ACL 포함) 확인 내역
- [x] 앱 Boot Sequence 5단계 [OK] 및 “Agent READY” 확인 내역
- [x] monitor.sh 실행 결과(프로세스/포트/리소스/경고) 내역
- [x] /var/log/agent-app/monitor.log 누적 기록 확인(최근 라인) 내역
- [x] crontab 매분 실행 등록 및 자동 실행 확인(1분 후 로그 증가) 내역

## 1
```bash
docker run -d --name linux-mission -p 20022:20022 -p 15034:15034 ubuntu:22.04 sleep infinity
docker exec -it linux-mission /bin/bash
apt update && apt install -y nano ssh ufw systemctl iproute2 net-tools acl cron

nano /etc/ssh/sshd_config
Port 22 -> Port 20022, PermitRootLogin prohibit-password -> PermitRootLogin no
service ssh start

ss -tulnp | grep sshd
tcp   LISTEN 0      128          0.0.0.0:20022      0.0.0.0:*    users:(("sshd",pid=3948,fd=3))
tcp   LISTEN 0      128             [::]:20022         [::]:*    users:(("sshd",pid=3948,fd=4))

grep "PermitRootLogin" /etc/ssh/sshd_config
PermitRootLogin no
```

## 2
```bash
ufw allow 20022/tcp
ufw allow 15034/tcp
ufw enable
ufw status
(Permission denied)

grep "###" -A 5 /etc/ufw/user.rules
### tuple ### allow tcp 20022 0.0.0.0/0 any 0.0.0.0/0 in
-A ufw-user-input -p tcp --dport 20022 -j ACCEPT
### tuple ### allow tcp 15034 0.0.0.0/0 any 0.0.0.0/0 in
-A ufw-user-input -p tcp --dport 15034 -j ACCEPT
```

## 3
```bash
adduser agent-admin
adduser agent-dev
adduser agent-test

groupadd agent-common
groupadd agent-core

usermod -aG agent-common agent-admin
usermod -aG agent-common agent-dev
usermod -aG agent-common agent-test

usermod -aG agent-core agent-admin
usermod -aG agent-core agent-dev

id agent-admin
uid=1000(agent-admin) gid=1000(agent-admin) groups=1000(agent-admin),1003(agent-common),1004(agent-core)

id agent-test
uid=1002(agent-test) gid=1002(agent-test) groups=1002(agent-test),1003(agent-common)
```

## 4
```bash
mkdir -p /home/agent-admin/upload_files
mkdir -p /home/agent-admin/api_keys
mkdir -p /var/log/agent-app

chgrp agent-common /home/agent-admin/upload_files
chgrp agent-core /home/agent-admin/api_keys
chgrp agent-core /var/log/agent-app

chmod 770 /home/agent-admin/upload_files
chmod 770 /home/agent-admin/api_keys
chmod 770 /var/log/agent-app

getfacl /home/agent-admin/upload_files
getfacl: Removing leading '/' from absolute path names
# file: home/agent-admin/upload_files
# owner: root
# group: agent-common
user::rwx
group::rwx
other::---

ls -ld /home/agent-admin/api_keys
drwxrwx--- 1 root agent-core 0 May 11 06:39 /home/agent-admin/api_keys

ls -ld /var/log/agent-app
drwxrwx--- 1 root agent-core 0 May 11 06:39 /var/log/agent-app
```

## 5
```bash
mkdir -p /home/agent-admin/agent-app/
mkdir -p /home/agent-admin/agent-app/api_keys
mkdir -p /home/agent-admin/agent-app/upload_files

cat <<EOF > /etc/profile.d/agent_env.sh
export AGENT_HOME=/home/agent-admin/agent-app
export AGENT_PORT=15034
export AGENT_UPLOAD_DIR=\$AGENT_HOME/upload_files
export AGENT_KEY_PATH=\$AGENT_HOME/api_keys/t_secret.key
export AGENT_LOG_DIR=/var/log/agent-app
EOF

source /etc/profile.d/agent_env.sh

echo $AGENT_PORT
15034

echo "agent_api_key_test" > $AGENT_KEY_PATH

chown -R agent-admin:agent-common /home/agent-admin/agent-app
chown -R agent-admin:agent-core /home/agent-admin/agent-app/api_keys
chown -R agent-admin:agent-core /var/log/agent-app

chmod 770 /home/agent-admin/agent-app/upload_files
chmod 770 /home/agent-admin/agent-app/api_keys
chmod 770 /var/log/agent-app
chmod +x /home/agent-admin/agent-app/agent_app

su - agent-admin

~/agent-app/agent_app
>>> Starting Agent Boot Sequence...
[1/5] Checking User Account               [OK]
 ... Running as service user 'agent-admin' (uid=1001)
[2/5] Verifying Environment Variables     [OK]
 ... All required Envs correct
[3/5] Checking Required Files             [OK]
 ... Verified 'secret.key' with correct key string.
[4/5] Checking Port Availability          [OK]
 ... Port 15034 is available.
[5/5] Verifying Log Permission            [OK]
 ... Log directory is writable: /var/log/agent-app
------------------------------------------------------------
All Boot Checks Passed!
Agent READY
```

## 6
```bash
mkdir -p /home/agent-admin/agent-app/bin

cat << 'EOF' > /home/agent-admin/agent-app/bin/monitor.sh
...
EOF

chown agent-dev:agent-core /home/agent-admin/agent-app/bin/monitor.sh
chmod 750 /home/agent-admin/agent-app/bin/monitor.sh
service cron start

su - agent-admin
~/agent-app/agent_app

pgrep -f "agent_app"
5392
5393

ss -tln | grep :15034
LISTEN 0      1            0.0.0.0:15034      0.0.0.0:*

pkill -f agent_app
/home/agent-admin/agent-app/bin/monitor.sh
echo $?
1

tail -f /var/log/agent-app/monitor.log
[2026-05-13 13:55:19] [WARNING] Firewall is inactive
[2026-05-13 13:55:19] PID:60,505,506 CPU:0% MEM:4% DISK_USED:1%
[2026-05-13 13:55:35] [WARNING] Firewall is inactive
[2026-05-13 13:55:35] PID:60,505,506 CPU:0% MEM:4% DISK_USED:1%
[2026-05-13 13:56:01] [WARNING] Firewall is inactive
[2026-05-13 13:56:01] PID:60,505,506 CPU:0% MEM:3% DISK_USED:1%

crontab -e
* * * * * /home/agent-admin/agent-app/bin/monitor.sh

tail -f /var/log/agent-app/monitor.log
[2026-05-12 16:08:01] PID:5095
5096 CPU:0% MEM:5% DISK_USED:1%
[2026-05-12 16:09:01] PID:5095
5096 CPU:0% MEM:4% DISK_USED:1%
```
