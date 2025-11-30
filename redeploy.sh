#!/bin/bash
# 초간단 재배포 스크립트 (한 줄 명령)

ZONE="asia-northeast3-a"
VM_NAME="sorizip-vm"

echo "🚀 빠른 재배포 시작..."

# 압축 -> 전송 -> 배포
tar -czf sorizip.tar.gz --exclude='build' --exclude='bin' --exclude='.gradle' --exclude='tomcat.*' --exclude='.git' --exclude='*.tar.gz' . && \
gcloud compute scp sorizip.tar.gz $VM_NAME:~ --zone=$ZONE --quiet && \
gcloud compute ssh $VM_NAME --zone=$ZONE --command='cd ~ && tar -xzf sorizip.tar.gz -C sorizip && cd sorizip && sudo docker-compose -f docker-compose.prod.yml down && sudo docker-compose -f docker-compose.prod.yml build && sudo docker-compose -f docker-compose.prod.yml up -d && echo "✅ 배포 완료!" && sudo docker-compose -f docker-compose.prod.yml ps' && \
rm -f sorizip.tar.gz

EXTERNAL_IP=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --format="value(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null)
echo ""
echo "🌐 접속: http://$EXTERNAL_IP"
echo "🌐 도메인: https://sorizip.formabridge.cc"

