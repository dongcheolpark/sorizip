<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>회원가입 – 소리집 sorizip</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="css/index.css" />
  <link rel="stylesheet" href="css/auth.css" />
</head>
<body>

<%@ include file="WEB-INF/includes/header.jsp" %>

<section class="auth-wrapper">
  <form class="auth-card" method="post" action="signup">
    <h1 class="auth-title">회원가입</h1>
    <p class="auth-sub">소리집 계정을 만들고 중고 악기를 편하게 거래해보세요.</p>

    <% String error = (String) request.getAttribute("error");
       if (error != null) { %>
    <div style="color:#b00020; margin-bottom:12px; font-weight:600; padding:8px; background:#ffebee; border-radius:6px;"><%= error %></div>
    <% } %>

    <div class="auth-field">
      <label class="auth-label" for="userUId">아이디</label>
      <input
        type="text"
        id="userUId"
        name="userUId"
        class="auth-input"
        placeholder="로그인에 사용할 아이디 (4자리 이상)"
        minlength="4"
        required
      />
      <small style="color:#666; font-size:12px;">4자리 이상 입력해주세요.</small>
    </div>

    <div class="auth-field">
      <label class="auth-label" for="userPassword">비밀번호</label>
      <input
        type="password"
        id="userPassword"
        name="userPassword"
        class="auth-input"
        placeholder="비밀번호를 입력하세요 (7자리 이상, 영어+숫자)"
        minlength="7"
        pattern="^(?=.*[A-Za-z])(?=.*\d).{7,}$"
        title="비밀번호는 7자리 이상이며, 영어와 숫자를 모두 포함해야 합니다."
        required
      />
      <small style="color:#666; font-size:12px;">7자리 이상, 영어와 숫자를 모두 포함해야 합니다.</small>
    </div>

    <div class="auth-field">
      <label class="auth-label" for="userEmail">이메일</label>
        <input
          type="email"
          id="userEmail"
          name="userEmail"
          class="auth-input"
          placeholder="이메일을 입력해주세요"
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
        placeholder="실명을 입력해주세요"
        required
      />
    </div>

    <div class="auth-field">
        <label class="auth-label" for="userNickname">닉네임</label>
        <input
            type="text"
            id="userNickname"
            name="userNickname"
            class="auth-input"
            placeholder="사용할 별명을 입력해주세요"
            required
        />
    </div>

    <div class="auth-actions">
      <button type="submit" class="btn primary full">가입하기</button>
      <a href="login.jsp" class="btn ghost full">이미 계정이 있어요 (로그인)</a>
      <a href="index.jsp" class="btn ghost full">메인으로 돌아가기</a>
    </div>
  </form>
</section>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: contact@formabridge.cc</div>
</footer>
</body>
</html>
