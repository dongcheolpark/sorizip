#!/bin/bash

set -e

echo "🚀 Sorizip 배포 스크립트"
echo "=========================="

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 환경 변수 파일 확인
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env 파일이 없습니다!${NC}"
    echo "📝 .env.example 파일을 참고하여 .env 파일을 생성하세요."
    exit 1
fi

echo -e "${GREEN}✓ 환경 변수 파일 확인 완료${NC}"
echo "📝 환경 변수는 Docker Compose를 통해 전달됩니다"

# 기존 컨테이너 정리
echo "🧹 기존 컨테이너 정리 중..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# Docker 이미지 빌드
echo "🔨 Docker 이미지 빌드 중..."
docker-compose -f docker-compose.prod.yml build --no-cache

# 컨테이너 시작
echo "🚀 컨테이너 시작 중..."
docker-compose -f docker-compose.prod.yml up -d

# 컨테이너 상태 확인
echo "⏳ 컨테이너 시작 대기 중..."
sleep 10

echo ""
echo "📊 컨테이너 상태:"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "🔍 애플리케이션 로그:"
docker-compose -f docker-compose.prod.yml logs --tail=50 app

echo ""
echo -e "${GREEN}✅ 배포 완료!${NC}"
echo ""
echo "📍 접속 URL: http://localhost"
echo "🔍 로그 확인: docker-compose -f docker-compose.prod.yml logs -f"
echo "⏹️  중지: docker-compose -f docker-compose.prod.yml down"

