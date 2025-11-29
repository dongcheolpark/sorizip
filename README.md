# 🎵 Sorizip (소리집)

중고 악기 거래 플랫폼 - Apache Tomcat (Jakarta EE 10 Servlet 5.0) 기반 웹 애플리케이션

## ✨ 주요 기능

- 🎸 중고 악기 게시글 작성/수정/삭제
- 🔍 악기 검색 기능
- 👤 사용자 회원가입/로그인
- 📸 이미지 업로드 (GCP Cloud Storage)
## 🚀 빠른 시작
### 프로덕션 배포
### 로컬 개발 환경 실행
- GCP Cloud SQL (MySQL)
```bash
# 1. 데이터베이스 시작 (Docker)
docker-compose up -d

# 2. 애플리케이션 실행


# 3. 브라우저에서 접속
# http://localhost:8081
```

### 빌드

```bash
./gradlew clean build
1. 생성된 WAR(`build/libs/testwebapp-1.0.0-SNAPSHOT.war`)을 Tomcat 10+ `webapps` 폴더에 복사
2. Tomcat 기동 후 브라우저에서 http://localhost:8080/testwebapp/ 또는 /hello 확인
`build/libs/sorizip.war` 생성됩니다.
### (선택) Gretty 사용 방법
## 🌐 프로덕션 배포 (GCP)
`build.gradle` plugins 블록에 아래 추가:
### 빠른 배포 (3단계)

```bash
# 1. 환경 변수 설정 (Cloud SQL Private IP 필요)
./setup-env.sh

# 2. Docker로 로컬 테스트
./deploy.sh

# 3. GCP VM에 배포 (QUICKSTART.md 참조)
```
## 📁 프로젝트 구조

```
sorizip/
├── src/main/
│   ├── java/com/example/web/
│   │   ├── TomcatServer.java      # 임베디드 Tomcat 서버
│   │   ├── LoginServlet.java      # 로그인
│   │   ├── SignupServlet.java     # 회원가입
│   │   ├── PostServlet.java       # 게시글 작성
│   │   ├── EditPostServlet.java   # 게시글 수정
│   │   ├── DeletePostServlet.java # 게시글 삭제
│   │   ├── ImageUploader.java     # GCS 이미지 업로드
│   │   └── Db.java                # HikariCP DB 연결
│   ├── resources/
│   │   ├── db.properties          # 개발 환경 설정
│   │   ├── db.properties.production # 프로덕션 설정
│   │   └── schema.sql             # DB 스키마
│   └── webapp/
│       ├── index.jsp              # 메인 페이지
│       ├── login.jsp              # 로그인
│       ├── signup.jsp             # 회원가입
│       ├── new.jsp                # 게시글 작성
│       ├── show.jsp               # 게시글 상세
│       ├── edit.jsp               # 게시글 수정
│       ├── search.jsp             # 검색
│       └── mypage.jsp             # 마이페이지
├── Dockerfile                     # 프로덕션 Docker 이미지
├── docker-compose.yml             # 개발 환경 (MySQL)
├── docker-compose.prod.yml        # 프로덕션 환경
├── nginx/nginx.conf               # Nginx 리버스 프록시 설정
├── deploy.sh                      # 배포 스크립트
├── setup-env.sh                   # 환경 변수 설정 스크립트
└── build.gradle                   # 빌드 설정
```

## 🛠️ 기술 스택

### Backend
- Java 17
- Jakarta Servlet 5.0
- Apache Tomcat 10.1 (Embedded)
- Gradle 8.5

### Database
- MySQL 8.0
- HikariCP (Connection Pool)

### Infrastructure
- Docker & Docker Compose
- Nginx (Reverse Proxy)
- GCP Cloud SQL (MySQL)
- GCP Cloud Storage (Image Storage)
- GCP Compute Engine (VM)

### Frontend
- JSP (JavaServer Pages)
- HTML5/CSS3
- Vanilla JavaScript

## 📚 참고 문서

- [QUICKSTART.md](QUICKSTART.md) - 빠른 배포 가이드 (5분)
- [DEPLOYMENT.md](DEPLOYMENT.md) - 상세 배포 가이드
- [IMAGE_UPLOAD_GUIDE.md](IMAGE_UPLOAD_GUIDE.md) - 이미지 업로드 가이드
- [BUGFIX.md](BUGFIX.md) - 버그 수정 내역

## 📝 License

이 프로젝트는 MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 👥 Contributors

- 학교 웹 프로그래밍 프로젝트

---

Made with ❤️ for music lovers 🎵

## 구조

```
 testwebapp/
  build.gradle
  settings.gradle
   src/main/java/com/example/web/HelloServlet.java
   src/main/webapp/WEB-INF/web.xml
   src/main/webapp/index.jsp
```

## 데이터베이스 (MySQL) 연동

이 프로젝트는 간단한 DB 커넥션 풀(HikariCP) + MySQL 예시가 포함되어 있습니다. 서블릿 `/hello` 호출 시 `SELECT 1` 테스트 결과를 출력합니다.

### 1. 로컬 MySQL 컨테이너 실행 예시

이미 3308 포트에서 컨테이너가 동작 중이라면 이 단계는 건너뛰세요.

```bash
docker run -d \
   --name db_class_mysql \
   -e MYSQL_ROOT_PASSWORD=3057 \
   -e MYSQL_DATABASE=db_class \
   -e MYSQL_USER=student \
   -e MYSQL_PASSWORD=3057 \
   -p 3308:3306 \
   mysql:8.3 \
   --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

### 2. 설정 파일

`src/main/resources/db.properties`

```properties
db.driver=com.mysql.cj.jdbc.Driver
db.jdbcUrl=jdbc:mysql://localhost:3308/db_class?useSSL=false&characterEncoding=UTF-8&serverTimezone=UTC
db.username=student
db.password=3057
hikari.maximumPoolSize=5
hikari.connectionTimeoutMs=30000
```

필요 시 비밀번호 / DB명 / 포트를 수정하십시오.

### 3. 커넥션 테스트

빌드 & 실행 후:

```
./gradlew appRun
```

브라우저 또는 curl:

```
curl http://localhost:8081/testwebapp/hello
```

예상 출력 (정상):

```
Hello from HelloServlet

DB Connection OK (SELECT 1 = 1)
```

실패 시 예시:

```
DB ERROR: Communications link failure
```

이 경우:

1. 컨테이너 기동 여부: `docker ps`
2. 포트 개방 여부: `lsof -iTCP:3308 -sTCP:LISTEN`
3. 방화벽/로컬 포트 충돌 확인
4. 계정/비밀번호 재확인 (`mysql -h 127.0.0.1 -P 3308 -u root -p`)

### 4. 의존성

`build.gradle` 주요 추가 항목:

```gradle
implementation 'com.zaxxer:HikariCP:5.1.0'
implementation 'com.mysql:mysql-connector-j:8.3.0'
```

### 5. 커넥션 풀 동작 방식

`com.example.web.Db` 클래스가 애플리케이션 로딩 시 `db.properties`를 읽어 `HikariDataSource`를 초기화하고, 서블릿에서 `Db.getConnection()` 으로 커넥션을
얻습니다.

### 6. 환경별 분리 (선택)

간단히 다른 설정 파일을 두고 빌드 프로필로 교체하거나, 시스템 프로퍼티를 통해 오버라이드 할 수 있습니다. 예:

```
./gradlew appRun -Ddb.password=secret -Ddb.jdbcUrl=jdbc:mysql://localhost:3308/otherdb
```

`Db` 클래스를 수정하여 `System.getProperty(key, props.getProperty(key))` 형태로 우선순위를 주면 런타임 오버라이드 가능.

---
