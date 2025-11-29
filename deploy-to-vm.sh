#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Sorizip GCP VM 배포 스크립트       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# 설정
PROJECT_ID="savvy-hybrid-479012-s9"
ZONE="asia-northeast3-a"
VM_NAME="sorizip-vm"

# VM 존재 확인
echo -e "${YELLOW}VM 확인 중...${NC}"
VM_STATUS=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --format="value(status)" 2>/dev/null)

if [ -z "$VM_STATUS" ]; then
    echo -e "${RED}❌ VM '$VM_NAME'을 찾을 수 없습니다.${NC}"
    echo "먼저 ./create-vm.sh 를 실행하세요."
    exit 1
fi

if [ "$VM_STATUS" != "RUNNING" ]; then
    echo -e "${YELLOW}⚠️  VM이 실행 중이 아닙니다. 시작 중...${NC}"
    gcloud compute instances start $VM_NAME --zone=$ZONE
    sleep 10
fi

EXTERNAL_IP=$(gcloud compute instances describe $VM_NAME \
  --zone=$ZONE \
  --format="value(networkInterfaces[0].accessConfigs[0].natIP)")

echo -e "${GREEN}✓ VM 확인 완료${NC}"
echo -e "  외부 IP: ${YELLOW}$EXTERNAL_IP${NC}"
echo ""

# .env 파일 확인
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env 파일이 없습니다!${NC}"
    echo "Cloud SQL Private IP를 설정해주세요:"
    ./setup-env.sh
fi

# Cloud SQL Private IP 확인
echo -e "${YELLOW}Cloud SQL 설정 확인...${NC}"
DB_HOST=$(grep "^DB_HOST=" .env | cut -d'=' -f2 | tr -d '"')

if [[ "$DB_HOST" == "host.docker.internal" || "$DB_HOST" == "127.0.0.1" ]]; then
    echo -e "${RED}❌ .env 파일의 DB_HOST가 로컬 설정입니다.${NC}"
    echo ""
    echo "Cloud SQL Private IP를 확인하세요:"
    echo "  ${GREEN}gcloud sql instances list${NC}"
    echo "  ${GREEN}gcloud sql instances describe <인스턴스명> --format='value(ipAddresses[0].ipAddress)'${NC}"
    echo ""
    read -p "Cloud SQL Private IP를 입력하세요: " CLOUD_SQL_IP

    # .env 파일 업데이트
    sed -i.bak "s/^DB_HOST=.*/DB_HOST=$CLOUD_SQL_IP/" .env
    sed -i.bak "s/^DB_PORT=.*/DB_PORT=3306/" .env
    echo -e "${GREEN}✓ .env 파일 업데이트 완료${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  배포 시작${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 1단계: 프로젝트 파일 압축
echo -e "${YELLOW}[1/5]${NC} 프로젝트 파일 압축 중..."
tar -czf sorizip.tar.gz \
  --exclude='build' \
  --exclude='bin' \
  --exclude='.gradle' \
  --exclude='tomcat.*' \
  --exclude='.git' \
  --exclude='*.tar.gz' \
  .

echo -e "${GREEN}✓ 압축 완료${NC}"

# 2단계: VM에 파일 전송
echo ""
echo -e "${YELLOW}[2/5]${NC} VM에 파일 전송 중..."
gcloud compute scp sorizip.tar.gz $VM_NAME:~ --zone=$ZONE

echo -e "${GREEN}✓ 파일 전송 완료${NC}"

# 3단계: VM에서 Docker 설치 및 설정
echo ""
echo -e "${YELLOW}[3/5]${NC} VM 환경 설정 중..."

gcloud compute ssh $VM_NAME --zone=$ZONE --command="
set -e

echo '⚙️  Docker 설치 중...'
if ! command -v docker &> /dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y docker.io docker-compose git curl -qq
    sudo usermod -aG docker \$USER
    echo '✓ Docker 설치 완료'
else
    echo '✓ Docker 이미 설치되어 있음'
fi

echo ''
echo '📦 프로젝트 압축 해제 중...'
rm -rf sorizip
mkdir -p sorizip
tar -xzf sorizip.tar.gz -C sorizip
cd sorizip

echo '✓ 압축 해제 완료'
"

echo -e "${GREEN}✓ VM 환경 설정 완료${NC}"

# 4단계: 배포 실행
echo ""
echo -e "${YELLOW}[4/5]${NC} 애플리케이션 배포 중..."

gcloud compute ssh $VM_NAME --zone=$ZONE --command="
set -e
cd sorizip

echo '🐳 Docker 이미지 빌드 중...'
sudo docker-compose -f docker-compose.prod.yml build --no-cache

echo ''
echo '🚀 컨테이너 시작 중...'
sudo docker-compose -f docker-compose.prod.yml up -d

echo ''
echo '⏳ 컨테이너 시작 대기 중...'
sleep 10

echo ''
echo '📊 컨테이너 상태:'
sudo docker-compose -f docker-compose.prod.yml ps

echo ''
echo '🔍 애플리케이션 로그:'
sudo docker-compose -f docker-compose.prod.yml logs --tail=30 app
"

echo -e "${GREEN}✓ 배포 완료${NC}"

# 5단계: 헬스체크
echo ""
echo -e "${YELLOW}[5/5]${NC} 헬스체크 중..."
sleep 5

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP/health)

if [ "$HTTP_STATUS" == "200" ]; then
    echo -e "${GREEN}✓ 헬스체크 성공!${NC}"
else
    echo -e "${YELLOW}⚠️  헬스체크 응답: $HTTP_STATUS${NC}"
    echo "컨테이너가 아직 시작 중일 수 있습니다."
fi

# 정리
rm -f sorizip.tar.gz

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}   배포 완료! 🎉${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}접속 URL:${NC} http://$EXTERNAL_IP"
echo -e "  ${YELLOW}헬스체크:${NC} http://$EXTERNAL_IP/health"
echo ""
echo -e "${BLUE}유용한 명령어:${NC}"
echo ""
echo "  ${GREEN}# VM 접속${NC}"
echo "  gcloud compute ssh $VM_NAME --zone=$ZONE"
echo ""
echo "  ${GREEN}# 로그 확인${NC}"
echo "  gcloud compute ssh $VM_NAME --zone=$ZONE --command='cd sorizip && sudo docker-compose -f docker-compose.prod.yml logs -f'"
echo ""
echo "  ${GREEN}# 재시작${NC}"
echo "  gcloud compute ssh $VM_NAME --zone=$ZONE --command='cd sorizip && sudo docker-compose -f docker-compose.prod.yml restart'"
echo ""
echo "  ${GREEN}# VM 중지 (비용 절약)${NC}"
echo "  gcloud compute instances stop $VM_NAME --zone=$ZONE"
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

