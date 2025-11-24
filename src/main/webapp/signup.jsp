<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>회원가입 – 소리집 sorizip</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <!-- 공통 스타일 재사용 -->
  <link rel="stylesheet" href="css/index.css" />
  <style>
    .auth-wrapper {
      min-height: calc(100vh - 60px);
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 40px 18px;
    }

    .auth-card {
      width: 100%;
      max-width: 380px;
      border-radius: 16px;
      border: 1px solid #eee;
      background: #fff;
      padding: 24px 22px 22px;
      box-shadow: 0 4px 18px rgba(0, 0, 0, 0.06);
    }

    .auth-title {
      margin: 0 0 4px;
      font-size: 1.2rem;
      font-weight: 600;
    }

    .auth-sub {
      margin: 0 0 18px;
      font-size: 0.9rem;
      color: #777;
    }

    .auth-field {
      display: flex;
      flex-direction: column;
      gap: 4px;
      margin-bottom: 14px;
    }

    .auth-label {
      font-size: 0.85rem;
      color: #555;
    }

    .auth-input,
    .auth-select {
      padding: 8px 10px;
      border-radius: 8px;
      border: 1px solid #ccc;
      font-size: 0.95rem;
    }

    .auth-input:focus,
    .auth-select:focus {
      outline: none;
      border-color: #ff8a00;
      box-shadow: 0 0 0 1px #ffedd5;
    }

    .auth-actions {
      margin-top: 10px;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .btn.full {
      width: 100%;
      text-align: center;
      display: inline-block;
    }

    .auth-helper {
      margin-top: 10px;
      font-size: 0.8rem;
      color: #999;
      text-align: center;
    }
  </style>
</head>
<body>

<header class="nav">
  <a href="index.jsp" class="brand">소리집 <span class="sub">sorizip</span></a>
  <nav>
    <a href="index.jsp#features">서비스 소개</a>
    <a href="index.jsp#categories">카테고리</a>
    <a href="index.jsp#market">추천 매물</a>
    <a href="index.jsp#cta">시작하기</a>
    <a href="login.jsp" style="color: #FF6B35; font-weight: 600;">+ 매물 등록</a>
  </nav>
</header>

<section class="auth-wrapper">
  <!-- 아직 DB 연동 전: action은 임시로 # 또는 index.jsp -->
  <form class="auth-card" method="post" action="#">
    <h1 class="auth-title">회원가입</h1>
    <p class="auth-sub">소리집 계정을 만들고 중고 악기를 편하게 거래해보세요.</p>

    <div class="auth-field">
      <label class="auth-label" for="userId">아이디</label>
      <input
        type="text"
        id="userId"
        name="userId"
        class="auth-input"
        placeholder="로그인에 사용할 아이디"
        required
      />
    </div>

    <div class="auth-field">
      <label class="auth-label" for="userPw">비밀번호</label>
      <input
        type="password"
        id="userPw"
        name="userPw"
        class="auth-input"
        placeholder="비밀번호를 입력하세요"
        required
      />
    </div>

    <div class="auth-field">
      <label class="auth-label" for="userPw2">비밀번호 확인</label>
      <input
        type="password"
        id="userPw2"
        name="userPw2"
        class="auth-input"
        placeholder="비밀번호를 한 번 더 입력하세요"
        required
      />
    </div>

    <div class="auth-field">
      <label class="auth-label" for="userName">이름</label>
      <input
        type="text"
        id="userName"
        name="userName"
        class="auth-input"
        placeholder="실명을 입력하세요"
        required
      />
    </div>

    <div class="auth-field">
      <label class="auth-label" for="city">지역</label>
      <input
        type="text"
        id="city"
        name="city"
        class="auth-input"
        placeholder="예) 서울, 부산"
      />
    </div>

    <div class="auth-actions">
      <button type="submit" class="btn primary full">가입하기</button>
      <a href="login.jsp" class="btn ghost full">이미 계정이 있어요 (로그인)</a>
      <a href="index.jsp" class="btn ghost full">메인으로 돌아가기</a>
    </div>

    <p class="auth-helper">
      실제 회원 정보 저장/검증은 추후 DB와 연동해서 구현할 수 있습니다.
    </p>
  </form>
</section>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>

</body>
</html>
