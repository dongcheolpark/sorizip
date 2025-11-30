#!/bin/bash
# 초간단 재배포 스크립트 (.env 파일 보호)

ZONE="asia-northeast3-a"
VM_NAME="sorizip-vm"

echo "🚀 빠른 재배포 시작..."

# .env 파일 제외하고 압축
tar -czf sorizip.tar.gz \
  --exclude='build' \
  --exclude='bin' \
  --exclude='.gradle' \
  --exclude='tomcat.*' \
  --exclude='.git' \
  --exclude='*.tar.gz' \
  --exclude='.env' \
  . && \
echo "✓ 압축 완료 (.env 제외)" && \

# VM에 전송
gcloud compute scp sorizip.tar.gz $VM_NAME:~ --zone=$ZONE --quiet && \
echo "✓ 파일 전송 완료" && \

# VM에서 배포 (.env 파일 백업 후 복원)
gcloud compute ssh $VM_NAME --zone=$ZONE --command='
cd ~ &&
cp sorizip/.env sorizip_env_backup 2>/dev/null || true &&
tar -xzf sorizip.tar.gz -C sorizip &&
cp sorizip_env_backup sorizip/.env 2>/dev/null || true &&
cd sorizip &&
echo "🐳 Docker 이미지 빌드 중..." &&
sudo docker-compose -f docker-compose.prod.yml build 2>&1 | tail -10 &&
echo "🔄 컨테이너 재시작 중..." &&
sudo docker-compose -f docker-compose.prod.yml down &&
sudo docker-compose -f docker-compose.prod.yml up -d &&
sleep 5 &&
echo "✅ 배포 완료!" &&
sudo docker-compose -f docker-compose.prod.yml ps
' && \

# 정리
rm -f sorizip.tar.gz

EXTERNAL_IP=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --format="value(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 접속 URL:"
echo "   • http://$EXTERNAL_IP"
echo "   • https://sorizip.formabridge.cc"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

