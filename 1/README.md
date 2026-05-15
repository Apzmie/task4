# task1
터미널(CLI), Docker(OrbStack), Git을 활용한 재현 가능한 개발 환경 및 워크스테이션 구축
## 1) 실행 환경
- OS: macOS 15.7.4 (Build 24G517)
- Shell: /bin/zsh
- Docker: 28.5.2, build ecc6942 (OrbStack)
- Git: 2.53.0

## 2) 수행 체크리스트
- [x] 터미널 조작 로그 기록
- [x] 권한 실습 및 증거 기록
- [x] Docker 설치 및 기본 점검
- [x] Docker 기본 운영 명령 수행
- [x] 컨테이너 실행 실습
- [x] 기존 Dockerfile 기반 커스텀 이미지 제작
- [x] 포트 매핑 및 접속 증거
- [x] Docker 볼륨 영속성 검증
- [x] Git 설정 및 GitHub 연동
- [x] 보안 및 개인정보 보호

## 3) 수행 로그(발췌)
### 터미널 조작 로그 기록

1. 현재 위치 확인
```zsh
% pwd
/Users/user
```
2. 목록 확인(숨김 파일 포함)
```zsh
% ls -a
.			.ssh			Movies
..			.vscode			Music
.CFUserTextEncoding	.zsh_sessions		OrbStack
.DS_Store		Desktop			Pictures
.Trash			Documents		Public
.docker			Downloads
.orbstack		Library
```

3. 생성, 이동, 빈 파일 생성, 파일 내용 확인, 복사, 이동/이름변경, 삭제
```zsh
% mkdir dir1
% cd ~/dir1
% touch empty.txt
% echo "Hello" > empty.txt
% cat empty.txt
Hello
% cp empty.txt copy_test.txt
% mv copy_test.txt renamed.txt
% mkdir sub_folder
% mv renamed.txt sub_folder/
% cd ..
% rm -r dir1

```
### 권한 실습 및 증거 기록
1. 파일 권한 변경 실습
```zsh
% touch script.sh
% ls -l script.sh
-rw-r--r--  1 user  user  0 Mar 31 13:48 script.sh (읽고 쓰기만 가능)
% chmod 755 script.sh
% ls -l script.sh
-rwxr-xr-x  1 user  user  0 Mar 31 13:48 script.sh (프로그램처럼 실행 가능)
```
Read(4) + Write(2) + Execute(1)의 합산

2. 디렉토리 권한 변경 실습
```zsh
% mkdir private_dir
% ls -ld private_dir
drwxr-xr-x  2 user  user  64 Mar 31 14:00 private_dir (누구나 들어와서 목록을 볼 수 있음)
% chmod 700 private_dir
% ls -ld private_dir
drwx------  2 user  user  64 Mar 31 14:00 private_dir (나 외에는 접근 불가)

```
### Docker 설치 및 기본 점검
```zsh
% docker --version
Docker version 28.5.2, build ecc6942

% docker info
Client:
 Version:    28.5.2
 Context:    orbstack
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.29.1
    Path:     /Users/user/.docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.40.3
    Path:     /Users/user/.docker/cli-plugins/docker-compose
```

### Docker 기본 운영 명령 수행
1. 이미지: 다운로드/목록 확인
```zsh
% docker pull alpine 
Using default tag: latest
latest: Pulling from library/alpine
589002ba0eae: Pull complete 
Digest: sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659
Status: Downloaded newer image for alpine:latest
docker.io/library/alpine:latest

% docker images
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
alpine       latest    a40c03cbb81c   2 months ago   8.44MB
```
2. 컨테이너: 실행/목록/중지 확인
```zsh
% docker run -d --name my-test alpine sleep 1000 (-d는 백그라운드 실행)
1deca5aae1778dc41906f61a0f64071ff6a40cbd664b1105bf98e2bc886a9c77

% docker ps
CONTAINER ID   IMAGE     COMMAND        CREATED         STATUS         PORTS     NAMES
1deca5aae177   alpine    "sleep 1000"   3 minutes ago   Up 3 minutes             my-test

% docker stop my-test 
my-test

% docker ps -a
CONTAINER ID   IMAGE     COMMAND        CREATED         STATUS                       PORTS     NAMES
1deca5aae177   alpine    "sleep 1000"   4 minutes ago   Exited (137) 9 seconds ago             my-test
```
이미지: 서비스 실행에 필요한 모든 환경을 담은 읽기 전용(Read-only) 설계도

컨테이너: 이미지를 기반으로 격리된 공간에서 실제 실행 중인 프로세스

3. 운영: 로그 확인, 리소스 확인
```zsh
% docker start my-test
my-test
% docker logs my-test (방금 켰으니 과거 기록 없음)
% docker stats my-test --no-stream
CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT   MEM %     NET I/O         BLOCK I/O     PIDS
1deca5aae177   my-test   0.00%     552KiB / 15.67GiB   0.00%     1.13kB / 126B   1.52MB / 0B   1
```


### 컨테이너 실행 실습
1. hello-world 실행
```zsh
% docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
4f55086f7dd0: Pull complete 
Digest: sha256:452a468a4bf985040037cb6d5392410206e47db9bf5b7278d281f94d1c2d0931
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
```
2. 컨테이너 실행 및 내부 진입
```zsh
% docker run -it --name my-ubuntu ubuntu bash (-it는 터미널로 실행)
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
817807f3c64e: Pull complete 
Digest: sha256:186072bba1b2f436cbb91ef2567abca677337cfc786c86e107d25b7072feef0c
Status: Downloaded newer image for ubuntu:latest

# ls
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
# echo "Hello"
Hello
# exit
exit
```

3. attach/exec 차이
```zsh
% docker start my-ubuntu
my-ubuntu

% docker exec -it my-ubuntu bash

# exit
exit

% docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS          PORTS     NAMES
655841f3bacd   ubuntu    "bash"    12 minutes ago   Up 24 seconds             my-ubuntu

% docker attach my-ubuntu

# exit
exit

% docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

### 기존 Dockerfile 기반 커스텀 이미지 제작
```zsh
% code ~/orbstack-shell/my-web-server/html/index.html
'Hello, OrbStack!'

% code ~/orbstack-shell/my-web-server/Dockerfile
# 1. 베이스 이미지: 웹 서버(Nginx)와 가벼운 리눅스(Alpine)를 기초 재료로 가져옵니다.
FROM nginx:alpine
# 2. 환경 변수: 이 컨테이너의 버전을 '1.0'이라고 이름표를 붙여 관리합니다.
ENV APP_VERSION=1.0
# 3. 파일 복사: 'Hello, OrbStack!'이 화면에 나옵니다.
COPY ./html /usr/share/nginx/html
# 4. 라벨: 이 이미지를 누가 만들었는지 '관리자 정보'를 명시합니다.
LABEL maintainer="yourname@example.com"

% docker build -t my-custom-web:1.0 .
[+] Building 7.3s (7/7) FINISHED                                docker:orbstack
 => [internal] load build definition from Dockerfile                       0.2s
 => => transferring dockerfile: 331B                                       0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine            2.6s

% docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
my-custom-web   1.0       ba7b30634cee   About a minute ago   62.2MB

% docker run -d -p 8080:80 --name my-web-app my-custom-web:1.0 (내 컴퓨터(Host)의 8080번 포트를 컨테이너의 80번 포트로 연결)
fd4e333690d1129c712abbe2a987dc36961c34a0f0b6b7e51b49e8d5f6442c62
컨테이너는 자기만의 가상 공간에 갇혀 있어서, 밖에서 들어올 수 있게 통로(포트)를 뚫어주는 작업이 꼭 필요

% docker ps
CONTAINER ID   IMAGE               COMMAND                  CREATED          STATUS          PORTS                                     NAMES
fd4e333690d1   my-custom-web:1.0   "/docker-entrypoint.…"   32 seconds ago   Up 31 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   my-web-app
```

### 포트 매핑 및 접속 증거
http://localhost:8080
Hello, OrbStack!
```zsh
docker logs my-web-app
192.168.215.1 - - [01/Apr/2026:03:17:55 +0000] "GET / HTTP/1.1" 200 213 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15" "-"
```

### Docker 볼륨 영속성 검증
```zsh
% docker run -d --name vol-test-container -v my-data-vol:/data ubuntu sleep infinity
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
817807f3c64e: Pull complete 
Digest: sha256:186072bba1b2f436cbb91ef2567abca677337cfc786c86e107d25b7072feef0c
Status: Downloaded newer image for ubuntu:latest
d3ca9a1065c7149645009ba2a610aad5d61181faef01675c752aacfbfa4da421

% docker exec -it vol-test-container bash -lc "echo 'Hello, Persistence!' > /data/test.txt"
% docker exec -it vol-test-container cat /data/test.txt
Hello, Persistence!

% docker rm -f vol-test-container
vol-test-container

% docker run -d --name vol-check-container -v my-data-vol:/data ubuntu sleep infinity
9355386b236f27d0d46cdd21a4d015692bc3cf1116f262d1c1b50e3546b11975

% docker exec -it vol-check-container cat /data/test.txt
Hello, Persistence!
```

바인드 마운트 
```zsh
% docker run -d -p 8080:80 --name my-web-app -v $(pwd)/html:/usr/share/nginx/html my-custom-web:1.0
e8844d915eaa7e0c603ef151c6011b32120c169996d69a5f1e757e2d75beb635

% echo "<h1>Bind Mount Success\!</h1>" > ./html/index.html
```
http://localhost:8080 Bind Mount Success!

볼륨(데이터 바구니)은 컨테이너에 붙이는 거고, 바인드 마운트는 내 컴퓨터의 실제 폴더를 컨테이너 폴더에 연결

### Git 설정 및 GitHub 연동
```zsh
% git config --global user.name "user"  
% git config --global user.email "user@example.com"
% git config --global init.defaultBranch main
% git config --list
credential.helper=osxkeychain
user.name=user
user.email=user@example.com
init.defaultbranch=main

% git init
Initialized empty Git repository in /Users/user/orbstack-shell/my-web-server/.git/

% git add .
git commit -m "Docker 실습 완료!"

% git remote add origin https://github.com/Apzmie/task1.gitt

% git push -u origin main
```

트러블슈팅 회고: 1. 오타로 인해 push가 되지 않았지만 원인을 몰라서 --force를 사용했더니 이전에 기록한 README가 사라져서 Activity를 확인하며 다시 작성함. 2. 다시 실습해볼 때, 터미널 켜자마자 바로 해보니 git init할 떄 Reinitialized가 뜨고 git add .해도 아무것도 안 뜸. 이는 최상위 폴더에서 해서 먹통된거고 전용 폴더 만들어서 해야 함.

프로젝트 디렉토리 구조 설계 기준: 소스 코드(html)와 설정 파일(Dockerfile)을 분리하여 관리 편의성을 높임.

포트/볼륨 설정의 재현성 확보 방안: 명령어를 매번 치는 대신 실행 옵션(포트/볼륨)을 적어둔 자동 실행 파일 만듦.

빌드(Build): 이미지를 만드는 과정, 실행(Run): 이미지를 기반으로 컨테이너를 띄우는 과정, 변경(Change): 컨테이너 내부에서 수정한 내용은 컨테이너가 삭제되면 사라지며, 영구히 바꾸려면 이미지를 다시 빌드해야 함.

상대 경로는 .이나 ..을 이용하여 이동, 절대 경로는 /로 전체 주소를 다 적는 위치의 고정성.

포트 충돌(Port already in use) 진단 순서: docker ps 명령어로 포트를 점유 중인 프로세스(범인)를 찾아내고, 필요 없는 프로세스라면 종료하거나 아니면 내가 쓸 포트 번호를 바꿔서 충돌을 피함.
