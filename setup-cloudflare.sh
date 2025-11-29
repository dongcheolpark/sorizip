#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Cloudflare DNS 설정 스크립트        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# 설정
DOMAIN="formabridge.cc"
SUBDOMAIN="sorizip"
FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"
VM_IP="34.64.93.67"

echo -e "${YELLOW}도메인:${NC} $FULL_DOMAIN"
echo -e "${YELLOW}VM IP:${NC} $VM_IP"
echo ""

# Cloudflare API 토큰 확인
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  CLOUDFLARE_API_TOKEN 환경 변수가 설정되지 않았습니다.${NC}"
    echo ""
    echo "다음 단계를 따라 설정하세요:"
    echo ""
    echo "1. Cloudflare 대시보드 접속: https://dash.cloudflare.com"
    echo "2. 프로필 > API Tokens"
    echo "3. 'Create Token' 클릭"
    echo "4. 'Edit zone DNS' 템플릿 사용"
    echo "5. 생성된 토큰을 복사"
    echo ""
    read -sp "Cloudflare API Token을 입력하세요: " CLOUDFLARE_API_TOKEN
    echo ""
    echo ""

    if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
        echo -e "${RED}❌ API 토큰이 필요합니다.${NC}"
        exit 1
    fi

    # .env 파일에 저장할지 물어보기
    read -p "이 토큰을 저장하시겠습니까? (y/n): " save_token
    if [[ "$save_token" == "y" || "$save_token" == "Y" ]]; then
        echo "export CLOUDFLARE_API_TOKEN='$CLOUDFLARE_API_TOKEN'" >> ~/.zshrc
        echo -e "${GREEN}✓ ~/.zshrc에 저장되었습니다${NC}"
    fi
fi

echo -e "${YELLOW}1. Zone ID 조회 중...${NC}"

# Zone ID 가져오기
ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json")

ZONE_ID=$(echo $ZONE_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$ZONE_ID" ]; then
    echo -e "${RED}❌ Zone ID를 찾을 수 없습니다.${NC}"
    echo "응답: $ZONE_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✓ Zone ID: $ZONE_ID${NC}"

echo ""
echo -e "${YELLOW}2. 기존 DNS 레코드 확인 중...${NC}"

# 기존 레코드 확인
EXISTING_RECORD=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${FULL_DOMAIN}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json")

RECORD_ID=$(echo $EXISTING_RECORD | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$RECORD_ID" ]; then
    echo -e "${YELLOW}⚠️  기존 레코드 발견 (ID: $RECORD_ID)${NC}"

    # 기존 레코드 업데이트
    echo -e "${YELLOW}3. DNS 레코드 업데이트 중...${NC}"

    UPDATE_RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"${SUBDOMAIN}\",\"content\":\"${VM_IP}\",\"ttl\":1,\"proxied\":true}")

    SUCCESS=$(echo $UPDATE_RESPONSE | grep -o '"success":[^,]*' | cut -d':' -f2)

    if [ "$SUCCESS" == "true" ]; then
        echo -e "${GREEN}✓ DNS 레코드 업데이트 완료${NC}"
    else
        echo -e "${RED}❌ DNS 레코드 업데이트 실패${NC}"
        echo "응답: $UPDATE_RESPONSE"
        exit 1
    fi
else
    # 새 레코드 생성
    echo -e "${YELLOW}3. DNS 레코드 생성 중...${NC}"

    CREATE_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"${SUBDOMAIN}\",\"content\":\"${VM_IP}\",\"ttl\":1,\"proxied\":true}")

    SUCCESS=$(echo $CREATE_RESPONSE | grep -o '"success":[^,]*' | cut -d':' -f2)

    if [ "$SUCCESS" == "true" ]; then
        echo -e "${GREEN}✓ DNS 레코드 생성 완료${NC}"
    else
        echo -e "${RED}❌ DNS 레코드 생성 실패${NC}"
        echo "응답: $CREATE_RESPONSE"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}   DNS 설정 완료! 🎉${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}도메인:${NC} https://${FULL_DOMAIN}"
echo -e "  ${YELLOW}VM IP:${NC} ${VM_IP}"
echo -e "  ${YELLOW}Cloudflare Proxy:${NC} 활성화됨 (SSL 자동 설정)"
echo ""
echo -e "${BLUE}다음 단계:${NC}"
echo "  1. DNS 전파 대기 (1-5분)"
echo "  2. 브라우저에서 https://${FULL_DOMAIN} 접속"
echo ""
echo -e "${YELLOW}참고:${NC}"
echo "  • Cloudflare가 자동으로 SSL을 제공합니다"
echo "  • HTTP → HTTPS 리다이렉트가 자동으로 설정됩니다"
echo "  • DNS 전파 확인: ${GREEN}dig ${FULL_DOMAIN}${NC}"
echo ""

