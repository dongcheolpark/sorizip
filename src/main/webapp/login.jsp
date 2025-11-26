<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // returnUrl 파라미터를 세션에 저장 (있는 경우)
  String returnUrl = request.getParameter("returnUrl");
  if (returnUrl != null && !returnUrl.trim().isEmpty()) {
    session.setAttribute("returnUrl", returnUrl);
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>로그인 – 소리집 sorizip</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
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
      max-width: 360px;
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

    .auth-input {
      padding: 8px 10px;
      border-radius: 8px;
      border: 1px solid #ccc;
      font-size: 0.95rem;
    }

    .auth-input:focus {
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

<%@ include file="WEB-INF/includes/header.jsp" %>

<section class="auth-wrapper">
  <form class="auth-card" method="post" action="login">
    <h1 class="auth-title">로그인</h1>

    <% 
       String signup = request.getParameter("signup");
       if ("success".equals(signup)) { %>
    <div style="color:#2e7d32; margin-bottom:12px; font-weight:600; padding:8px; background:#e8f5e9; border-radius:6px;">
      회원가입이 완료되었습니다! 로그인해주세요.
    </div>
    <% } 
    
       String error = (String) request.getAttribute("error");
       if (error != null) { %>
    <div style="color:#b00020; margin-bottom:12px; font-weight:600"><%= error %></div>
    <% } %>

    <div class="auth-field">
      <label class="auth-label" for="userUId">아이디</label>
      <input
        type="text"
        id="userUId"
        name="userUId"
        class="auth-input"
        placeholder="아이디를 입력하세요"
        required
      />
    </div>

    <div class="auth-field">
      <label class="auth-label" for="userPassword">비밀번호</label>
      <input
        type="password"
        id="userPassword"
        name="userPassword"
        class="auth-input"
        placeholder="비밀번호를 입력하세요"
        required
      />
    </div>

    <div class="auth-actions">
    <!-- 로그인 -->
    <button type="submit" class="btn primary full">로그인</button>

    <!-- 회원가입으로 이동 -->
    <a href="signup.jsp" class="btn ghost full">회원가입</a>

    <!-- 메인으로 -->
    <a href="index.jsp" class="btn ghost full">메인으로 돌아가기</a>
    </div>
  </form>
</section>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>

</body>
</html>
