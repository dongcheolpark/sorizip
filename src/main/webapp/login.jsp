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
  <link rel="stylesheet" href="css/auth.css" />
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
