# task4

- [x] SSH 포트 변경(20022) 및 Root 원격 접속 차단 설정 확인 내역
- [x] 방화벽(UFW 또는 firewalld) 활성화 및 20022/tcp, 15034/tcp만 허용 내역
- [ ] 계정/그룹(agent-admin/dev/test, agent-common/core) 생성 확인 내역
- [ ] 디렉토리 구조 및 권한(ACL 포함) 확인 내역
- [ ] 앱 Boot Sequence 5단계 [OK] 및 “Agent READY” 확인 내역
- [ ] monitor.sh 실행 결과(프로세스/포트/리소스/경고) 내역
- [ ] /var/log/agent-app/monitor.log 누적 기록 확인(최근 라인) 내역
- [ ] crontab 매분 실행 등록 및 자동 실행 확인(1분 후 로그 증가) 내역

## 1
```bash
docker run -d --name linux-mission -p 20022:20022 -p 15034:15034 ubuntu:22.04 sleep infinity
docker exec -it linux-mission /bin/bash
apt update && apt install -y nano ssh ufw systemctl iproute2 net-tools

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
