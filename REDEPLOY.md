# 🚀 VM 재배포 가이드

## 가장 빠른 방법

```bash
cd /Users/parkdongcheol/school/web/sorizip
./redeploy.sh
```

## 또는 상세 버전

```bash
./deploy-to-vm.sh
```

---

## 📝 각 방법의 차이

### `./redeploy.sh` (빠른 재배포 - 추천)
- **용도**: 코드 변경 후 빠른 재배포
- **특징**: 최소 출력, 빠른 실행
- **시간**: ~2-3분

### `./deploy-to-vm.sh` (상세 배포)
- **용도**: 첫 배포 또는 문제 확인이 필요할 때
- **특징**: 상세한 진행 상황 표시
- **시간**: ~3-5분

---

## 수동 배포 (단계별)

### 1. 압축
```bash
cd /Users/parkdongcheol/school/web/sorizip
tar -czf sorizip.tar.gz --exclude='build' --exclude='bin' --exclude='.gradle' --exclude='tomcat.*' --exclude='.git' --exclude='*.tar.gz' .
```

### 2. 전송
```bash
gcloud compute scp sorizip.tar.gz sorizip-vm:~ --zone=asia-northeast3-a
```

### 3. 배포
```bash
gcloud compute ssh sorizip-vm --zone=asia-northeast3-a --command='
  cd ~ && 
  tar -xzf sorizip.tar.gz -C sorizip && 
  cd sorizip && 
  sudo docker-compose -f docker-compose.prod.yml down && 
  sudo docker-compose -f docker-compose.prod.yml build && 
  sudo docker-compose -f docker-compose.prod.yml up -d
'
```

### 4. 로그 확인
```bash
gcloud compute ssh sorizip-vm --zone=asia-northeast3-a --command='cd sorizip && sudo docker-compose -f docker-compose.prod.yml logs -f app'
```

---

## 유용한 명령어

### 컨테이너 상태 확인
```bash
gcloud compute ssh sorizip-vm --zone=asia-northeast3-a --command='cd sorizip && sudo docker-compose -f docker-compose.prod.yml ps'
```

### 컨테이너 재시작 (코드 변경 없이)
```bash
gcloud compute ssh sorizip-vm --zone=asia-northeast3-a --command='cd sorizip && sudo docker-compose -f docker-compose.prod.yml restart'
```

### VM 접속
```bash
gcloud compute ssh sorizip-vm --zone=asia-northeast3-a
```

### 이전 버전으로 롤백
```bash
gcloud compute ssh sorizip-vm --zone=asia-northeast3-a --command='
  cd ~ && 
  sudo docker-compose -f sorizip/docker-compose.prod.yml down && 
  rm -rf sorizip && 
  mv sorizip_old sorizip && 
  cd sorizip && 
  sudo docker-compose -f docker-compose.prod.yml up -d
'
```

---

## 접속 URL

- **IP**: http://34.64.93.67
- **도메인**: https://sorizip.formabridge.cc

---

## 트러블슈팅

### 배포 실패 시
```bash
# 로그 확인
gcloud compute ssh sorizip-vm --zone=asia-northeast3-a --command='cd sorizip && sudo docker-compose -f docker-compose.prod.yml logs --tail=100'

# 컨테이너 완전 재시작
gcloud compute ssh sorizip-vm --zone=asia-northeast3-a --command='cd sorizip && sudo docker-compose -f docker-compose.prod.yml down -v && sudo docker-compose -f docker-compose.prod.yml up -d'
```

### VM 용량 확인
```bash
gcloud compute ssh sorizip-vm --zone=asia-northeast3-a --command='df -h'
```

### Docker 이미지 정리
```bash
gcloud compute ssh sorizip-vm --zone=asia-northeast3-a --command='sudo docker system prune -a -f'
```

