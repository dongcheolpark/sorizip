# testwebapp

간단한 Apache Tomcat (Jakarta EE 10 Servlet 5.0) 기반 Gradle 웹 애플리케이션 예제.

## 요구사항

- JDK 17 이상
- Gradle Wrapper (동봉된 `./gradlew` 사용 권장)
- (선택) Gretty 같은 개발용 실행 플러그인 (기본 미포함)

## 빌드

```
./gradlew clean build
```

`build/libs/testwebapp-1.0.0-SNAPSHOT.war` 생성.

## 실행

배포:

1. 생성된 WAR(`build/libs/testwebapp-1.0.0-SNAPSHOT.war`)을 Tomcat 10+ `webapps` 폴더에 복사
2. Tomcat 기동 후 브라우저에서 http://localhost:8080/testwebapp/ 또는 /hello 확인

### (선택) Gretty 사용 방법

`build.gradle` plugins 블록에 아래 추가:

```
id 'org.gretty' version '4.0.3'
```

그 후:

```
./gradlew appRun
```

브라우저: http://localhost:8080/testwebapp/

## Tomcat 10 이상 수동 배포 (요약)

1. WAR 복사 (`build/libs/testwebapp-1.0.0-SNAPSHOT.war` → `webapps/`)
2. Tomcat 기동 후 `http://localhost:8080/testwebapp` 접속

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
