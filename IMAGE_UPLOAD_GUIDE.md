# 이미지 업로드 기능 구현 완료

## 구현된 기능

### 1. 데이터베이스
- `sell_post_image` 테이블 사용
  - `post_id`: 게시글 ID (외래키)
  - `image_url`: GCP Cloud Storage에 업로드된 이미지 URL
  - `display_order`: 이미지 표시 순서
  - `created_at`: 생성 시간

### 2. 백엔드
- **PostServlet.java** (새로 생성)
  - 게시글 생성 및 이미지 업로드 처리
  - 여러 이미지 파일을 multipart/form-data로 받아 처리
  - GCP Cloud Storage에 이미지 업로드
  - 업로드된 이미지 URL을 DB에 저장

- **ImageUploader.java** (기존 사용)
  - GCP Cloud Storage 연동
  - db.properties에서 GCP_PROJECT_ID, GCS_BUCKET_NAME 읽기
  - 이미지 업로드 및 삭제 기능

### 3. 프론트엔드

#### new.jsp (게시글 작성 페이지)
- 이미지 파일 선택 input 추가
- multiple 속성으로 여러 이미지 선택 가능
- 선택한 이미지 미리보기 기능
- multipart/form-data로 서블릿에 전송

#### show.jsp (게시글 상세 페이지)
- 이미지 슬라이더 구현
  - 여러 이미지를 좌우 버튼으로 탐색
  - 하단 dot 네비게이션
  - 키보드 화살표 키로 이동 가능
  - 현재 이미지 번호 표시 (예: 1 / 3)
- 이미지가 없을 경우 안내 메시지 표시

### 4. 설정

#### db.properties
```properties
# GCP Cloud Storage Configuration
GCP_PROJECT_ID=savvy-hybrid-479012-s9
GCS_BUCKET_NAME=sorizip-images
```

#### build.gradle
```groovy
// GCP Cloud Storage
implementation 'com.google.cloud:google-cloud-storage:2.29.1'
```

## 사용 방법

### 1. GCP 인증 설정
```bash
# GCP 서비스 계정 키 파일 설정
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"
```

또는 gcloud CLI 인증:
```bash
gcloud auth application-default login
```

### 2. 서버 실행
```bash
./gradlew appRun
```

### 3. 게시글 작성
1. http://localhost:8081/new.jsp 접속
2. 제목, 가격, 카테고리, 상세 설명 입력
3. "이미지 업로드" 섹션에서 파일 선택 (여러 개 가능)
4. 선택한 이미지가 미리보기로 표시됨
5. "등록하기" 버튼 클릭

### 4. 게시글 보기
1. 게시글 상세 페이지에서 이미지 슬라이더 표시
2. 좌우 화살표 버튼으로 이미지 탐색
3. 하단 점(dot)을 클릭해서 특정 이미지로 이동
4. 키보드 좌우 화살표 키로도 이동 가능

## 주요 특징

### 이미지 슬라이더
- **반응형 디자인**: 모바일/데스크톱 모두 지원
- **부드러운 전환**: CSS transition으로 자연스러운 이동
- **다양한 조작 방법**:
  - 좌우 버튼 클릭
  - 하단 dot 네비게이션
  - 키보드 화살표 키
- **현재 위치 표시**: "1 / 3" 형태로 표시

### 이미지 업로드
- **다중 업로드**: 한 번에 여러 이미지 업로드 가능
- **미리보기**: 업로드 전 선택한 이미지 확인
- **파일 크기 제한**: 
  - 파일당 최대 10MB
  - 전체 요청 최대 50MB
- **자동 순서 관리**: display_order로 표시 순서 자동 관리

## 데이터 플로우

```
1. 사용자가 new.jsp에서 이미지 선택
   ↓
2. PostServlet에서 multipart/form-data 수신
   ↓
3. 각 이미지를 ImageUploader를 통해 GCP Cloud Storage에 업로드
   ↓
4. 반환된 공개 URL을 sell_post_image 테이블에 저장
   ↓
5. show.jsp에서 DB에서 이미지 URL 목록 조회
   ↓
6. 슬라이더 UI로 이미지 표시
```

## 테이블 구조

```sql
CREATE TABLE sell_post_image (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES sell_post(id) ON DELETE CASCADE
);
```

## 트러블슈팅

### 1. 이미지 업로드 실패
- GCP 인증이 제대로 되어 있는지 확인
- db.properties의 GCP_PROJECT_ID, GCS_BUCKET_NAME 확인
- 버킷이 공개 읽기 권한이 있는지 확인

### 2. 이미지가 표시되지 않음
- 브라우저 콘솔에서 이미지 URL 확인
- GCS 버킷의 CORS 설정 확인
- 이미지 URL이 DB에 제대로 저장되었는지 확인

### 3. 빌드 오류
```bash
./gradlew clean build --refresh-dependencies
```

## 향후 개선 사항

1. 이미지 삭제 기능 (게시글 수정 시)
2. 이미지 순서 변경 기능
3. 이미지 압축/리사이징
4. 썸네일 생성
5. 드래그 앤 드롭 업로드
6. 진행률 표시

