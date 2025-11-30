#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Sorizip VM 빠른 배포 🚀            ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# 설정
ZONE="asia-northeast3-a"
VM_NAME="sorizip-vm"

# 1단계: 프로젝트 파일 압축
echo -e "${YELLOW}[1/3]${NC} 프로젝트 압축 중..."
tar -czf sorizip.tar.gz \
  --exclude='build' \
  --exclude='bin' \
  --exclude='.gradle' \
  --exclude='tomcat.*' \
  --exclude='.git' \
  --exclude='*.tar.gz' \
  . 2>/dev/null
echo -e "${GREEN}✓ 압축 완료${NC}"

# 2단계: VM에 파일 전송
echo ""
echo -e "${YELLOW}[2/3]${NC} VM에 파일 전송 중..."
gcloud compute scp sorizip.tar.gz $VM_NAME:~ --zone=$ZONE --quiet
echo -e "${GREEN}✓ 전송 완료${NC}"

# 3단계: VM에서 배포 실행
echo ""
echo -e "${YELLOW}[3/3]${NC} 배포 실행 중..."
echo ""

gcloud compute ssh $VM_NAME --zone=$ZONE --command='
cd ~ &&
rm -rf sorizip_old &&
mv sorizip sorizip_old 2>/dev/null || true &&
mkdir -p sorizip &&
tar -xzf sorizip.tar.gz -C sorizip &&
cd sorizip &&
echo "🐳 Docker 이미지 빌드 중..." &&
sudo docker-compose -f docker-compose.prod.yml build --no-cache 2>&1 | tail -20 &&
echo "" &&
echo "🚀 컨테이너 재시작 중..." &&
sudo docker-compose -f docker-compose.prod.yml down &&
sudo docker-compose -f docker-compose.prod.yml up -d &&
echo "" &&
sleep 8 &&
echo "📊 상태 확인:" &&
sudo docker-compose -f docker-compose.prod.yml ps &&
echo "" &&
echo "🔍 최근 로그:" &&
sudo docker-compose -f docker-compose.prod.yml logs --tail=20 app
'

# VM IP 조회
EXTERNAL_IP=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --format="value(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null)

# 정리
rm -f sorizip.tar.gz

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}   배포 완료! 🎉${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}접속 URL:${NC}"
echo -e "    • http://$EXTERNAL_IP"
echo -e "    • https://sorizip.formabridge.cc"
echo ""
echo -e "  ${YELLOW}빠른 명령어:${NC}"
echo -e "    로그 보기: ${GREEN}gcloud compute ssh $VM_NAME --zone=$ZONE --command='cd sorizip && sudo docker-compose -f docker-compose.prod.yml logs -f app'${NC}"
echo ""
#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Sorizip GCP VM 생성 스크립트      ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# GCP 프로젝트 설정
PROJECT_ID="savvy-hybrid-479012-s9"
ZONE="asia-northeast3-a"
VM_NAME="sorizip-vm"
MACHINE_TYPE="e2-small"

echo -e "${YELLOW}프로젝트 ID:${NC} $PROJECT_ID"
echo -e "${YELLOW}Zone:${NC} $ZONE"
echo -e "${YELLOW}VM 이름:${NC} $VM_NAME"
echo -e "${YELLOW}머신 타입:${NC} $MACHINE_TYPE"
echo ""

read -p "계속하시겠습니까? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "취소되었습니다."
    exit 0
fi

echo ""
echo -e "${BLUE}1. VM 인스턴스 생성 중...${NC}"

gcloud compute instances create $VM_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=$MACHINE_TYPE \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=30GB \
  --boot-disk-type=pd-standard \
  --scopes=cloud-platform \
  --tags=http-server,https-server \
  --metadata=enable-oslogin=true

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ VM 생성 실패${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ VM 생성 완료${NC}"

echo ""
echo -e "${BLUE}2. 방화벽 규칙 생성 중...${NC}"

# HTTP 방화벽 규칙
gcloud compute firewall-rules create allow-http \
  --project=$PROJECT_ID \
  --allow=tcp:80 \
  --target-tags=http-server \
  --description="Allow HTTP traffic" \
  --direction=INGRESS 2>/dev/null || echo "allow-http 규칙이 이미 존재합니다."

# HTTPS 방화벽 규칙
gcloud compute firewall-rules create allow-https \
  --project=$PROJECT_ID \
  --allow=tcp:443 \
  --target-tags=https-server \
  --description="Allow HTTPS traffic" \
  --direction=INGRESS 2>/dev/null || echo "allow-https 규칙이 이미 존재합니다."

echo ""
echo -e "${GREEN}✓ 방화벽 규칙 설정 완료${NC}"

echo ""
echo -e "${BLUE}3. VM 정보 조회 중...${NC}"

EXTERNAL_IP=$(gcloud compute instances describe $VM_NAME \
  --zone=$ZONE \
  --format="value(networkInterfaces[0].accessConfigs[0].natIP)")

INTERNAL_IP=$(gcloud compute instances describe $VM_NAME \
  --zone=$ZONE \
  --format="value(networkInterfaces[0].networkIP)")

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}   VM 생성 완료!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "  ${YELLOW}VM 이름:${NC} $VM_NAME"
echo -e "  ${YELLOW}외부 IP:${NC} $EXTERNAL_IP"
echo -e "  ${YELLOW}내부 IP:${NC} $INTERNAL_IP"
echo -e "  ${YELLOW}Zone:${NC} $ZONE"
echo ""
echo -e "${BLUE}다음 단계:${NC}"
echo "  1. VM에 접속:"
echo "     ${GREEN}gcloud compute ssh $VM_NAME --zone=$ZONE${NC}"
echo ""
echo "  2. 배포 스크립트 실행:"
echo "     ${GREEN}./deploy-to-vm.sh${NC}"
echo ""

