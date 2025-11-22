## 🐛 버그 수정: ${MYSQL_URL} 에러

### 문제
```
java.lang.RuntimeException: Driver com.mysql.cj.jdbc.Driver claims to not accept jdbcUrl, ${MYSQL_URL}
```

### 원인
`db.properties` 파일에 `${MYSQL_URL}` 플레이스홀더가 그대로 들어가 있었고, 환경 변수가 없을 때 이 문자열이 그대로 JDBC URL로 사용됨.

Java Properties는 자동으로 환경 변수를 치환하지 않습니다!

### 해결
`db.properties`에 실제 기본값을 설정:
```properties
db.jdbcUrl=jdbc:mysql://127.0.0.1:3306/sorizip?useSSL=false&characterEncoding=UTF-8&serverTimezone=UTC
db.username=root
db.password=V%MsJN&Dh3@p4
```

`Db.java`는 다음 우선순위로 설정을 읽습니다:
1. **환경 변수** (MYSQL_URL, MYSQL_USERNAME, MYSQL_PASSWORD)
2. **db.properties 파일** (환경 변수가 없을 때)

---

## ✅ 실행 방법

### 방법 1: 환경 변수 없이 실행 (기본값 사용)
```bash
./gradlew appRun
```
→ Cloud SQL Proxy가 실행 중이고 `localhost:3306`으로 연결 가능하면 작동

### 방법 2: 환경 변수로 오버라이드
```bash
export MYSQL_URL='jdbc:mysql://127.0.0.1:3306/sorizip?useSSL=false&characterEncoding=UTF-8&serverTimezone=UTC'
export MYSQL_USERNAME='root'
export MYSQL_PASSWORD='V%MsJN&Dh3@p4'
./gradlew appRun
```

### 방법 3: 스크립트 사용
```bash
./run-with-env.sh
```

---

## 🚀 완전한 실행 순서

### 터미널 1: Cloud SQL Proxy 실행
```bash
./quick-connect.sh
# 또는
./cloud-sql-proxy --port 3306 PROJECT:REGION:INSTANCE
```

### 터미널 2: 애플리케이션 실행
```bash
./gradlew appRun
```

### 테스트
브라우저에서: http://localhost:8081/hello

기대 출력:
```
Hello from HelloServlet

DB Connection OK (SELECT 1 = 1)
```

---

## 💡 정리

- ✅ `db.properties`에 실제 기본값 설정 완료
- ✅ 환경 변수 우선 사용 (있으면)
- ✅ Cloud SQL Proxy 사용 시 `localhost:3306` 연결
- ✅ 빌드 성공

이제 Cloud SQL Proxy만 실행하면 바로 작동합니다! 🎉

---

## 🐛 추가 에러: Public Key Retrieval is not allowed

### 문제
```
Public Key Retrieval is not allowed
```

### 원인
MySQL 8.0+ 에서 `caching_sha2_password` 인증 방식 사용 시 발생하는 에러입니다.

### 해결
JDBC URL에 `allowPublicKeyRetrieval=true` 추가:

```properties
# 수정 전
jdbc:mysql://127.0.0.1:3306/sorizip?useSSL=false&characterEncoding=UTF-8&serverTimezone=UTC

# 수정 후
jdbc:mysql://127.0.0.1:3306/sorizip?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8&serverTimezone=UTC
```

✅ **이미 수정 완료**:
- `src/main/resources/db.properties` ✅
- `.env` 파일 ✅

이제 다시 실행하면 작동합니다!

