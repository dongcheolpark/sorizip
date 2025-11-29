#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Sorizip Cloud SQL Private IP 찾기   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# GCP 프로젝트 ID 확인
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}❌ GCP 프로젝트가 설정되지 않았습니다.${NC}"
    echo "다음 명령어로 프로젝트를 설정하세요:"
    echo "  gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo -e "${GREEN}✓ 현재 프로젝트: ${PROJECT_ID}${NC}"
echo ""

# Cloud SQL 인스턴스 목록 조회
echo -e "${YELLOW}Cloud SQL 인스턴스 검색 중...${NC}"
INSTANCES=$(gcloud sql instances list --format="table(name,region,databaseVersion)" 2>/dev/null)

if [ -z "$INSTANCES" ]; then
    echo -e "${RED}❌ Cloud SQL 인스턴스를 찾을 수 없습니다.${NC}"
    exit 1
fi

echo "$INSTANCES"
echo ""

# 인스턴스 이름 입력 받기
read -p "사용할 인스턴스 이름을 입력하세요: " INSTANCE_NAME

if [ -z "$INSTANCE_NAME" ]; then
    echo -e "${RED}❌ 인스턴스 이름이 입력되지 않았습니다.${NC}"
    exit 1
fi

# Private IP 조회
echo ""
echo -e "${YELLOW}Private IP 조회 중...${NC}"
PRIVATE_IP=$(gcloud sql instances describe $INSTANCE_NAME \
    --format="value(ipAddresses.filter(type:PRIVATE).ipAddress)" 2>/dev/null)

PUBLIC_IP=$(gcloud sql instances describe $INSTANCE_NAME \
    --format="value(ipAddresses.filter(type:PRIMARY).ipAddress)" 2>/dev/null)

if [ -z "$PRIVATE_IP" ]; then
    echo -e "${RED}❌ Private IP를 찾을 수 없습니다.${NC}"
    echo ""
    echo "Private IP를 활성화하려면:"
    echo "  1. GCP Console > Cloud SQL > 인스턴스 선택"
    echo "  2. 연결 > Private IP 활성화"
    echo "  3. VPC 네트워크 선택"
    echo ""

    if [ -n "$PUBLIC_IP" ]; then
        echo -e "${YELLOW}⚠️  Public IP만 사용 가능: ${PUBLIC_IP}${NC}"
        echo -e "${YELLOW}   (프로덕션에서는 Private IP 사용을 권장합니다)${NC}"
        PRIVATE_IP=$PUBLIC_IP
    else
        exit 1
    fi
else
    echo -e "${GREEN}✓ Private IP: ${PRIVATE_IP}${NC}"
    if [ -n "$PUBLIC_IP" ]; then
        echo -e "  Public IP: ${PUBLIC_IP}${NC}"
    fi
fi

# 데이터베이스 정보 입력
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}   데이터베이스 정보 입력${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

read -p "데이터베이스 이름 [sorizip]: " DB_NAME
DB_NAME=${DB_NAME:-sorizip}

read -p "데이터베이스 사용자 [root]: " DB_USER
DB_USER=${DB_USER:-root}

read -s -p "데이터베이스 비밀번호: " DB_PASSWORD
echo ""

if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}❌ 비밀번호를 입력해야 합니다.${NC}"
    exit 1
fi

# GCP 정보
GCP_PROJECT_ID="savvy-hybrid-479012-s9"
GCS_BUCKET_NAME="sorizip-images"

# .env 파일 생성
echo ""
echo -e "${YELLOW}.env 파일 생성 중...${NC}"

cat > .env << EOF
# Database Configuration
# Cloud SQL Private IP
DB_HOST=${PRIVATE_IP}
DB_PORT=3306
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}

# GCP Configuration
GCP_PROJECT_ID=${GCP_PROJECT_ID}
GCS_BUCKET_NAME=${GCS_BUCKET_NAME}

# Application Configuration
TOMCAT_PORT=8080
ENVIRONMENT=production
EOF

chmod 600 .env

echo -e "${GREEN}✓ .env 파일이 생성되었습니다!${NC}"
echo ""
echo "생성된 설정:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  DB Host: ${PRIVATE_IP}"
echo "  DB Name: ${DB_NAME}"
echo "  DB User: ${DB_USER}"
echo "  Project: ${GCP_PROJECT_ID}"
echo "  Bucket: ${GCS_BUCKET_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✅ 이제 ./deploy.sh 를 실행하여 배포할 수 있습니다!${NC}"

