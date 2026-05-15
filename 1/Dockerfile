# 1. 베이스 이미지 선택 (과제 요건 A)
FROM nginx:alpine

# 2. 커스텀 포인트: 환경 변수 설정 (관리용)
ENV APP_VERSION=1.0

# 3. 커스텀 포인트: 정적 콘텐츠 교체
COPY ./html /usr/share/nginx/html

# 4. 라벨 추가
LABEL maintainer="yourname@example.com"
