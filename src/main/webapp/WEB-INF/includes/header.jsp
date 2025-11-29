<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="css/header.css" />
<%
  // 로그인 상태 확인
  Integer userId = (Integer) session.getAttribute("userId");
  String userNickname = (String) session.getAttribute("userNickname");
  boolean isLoggedIn = (userId != null);
  
  // 현재 페이지 URL 추출 (returnUrl용)
  String currentPage = request.getRequestURI();
  String queryString = request.getQueryString();
  String currentUrl = currentPage.substring(currentPage.lastIndexOf("/") + 1);
  if (queryString != null && !queryString.isEmpty()) {
    currentUrl += "?" + queryString;
  }
  
  // 로그인/회원가입 페이지인지 확인 (returnUrl 누적 방지)
  boolean isAuthPage = currentUrl.startsWith("login.jsp") || currentUrl.startsWith("signup.jsp");
%>
<header class="nav">
  <a href="index.jsp" class="brand">소리집 <span class="sub">sorizip</span></a>
  
  <div class="nav-right">
    <% if (isLoggedIn) { %>
      <span class="user-info"><%= userNickname %>님</span>
      <a href="mypage.jsp" class="btn-mypage">마이페이지</a>
      <a href="#" onclick="return confirmLogout();" class="btn-logout">로그아웃</a>
    <% } else if (!isAuthPage) { %>
      <a href="login.jsp?returnUrl=<%= java.net.URLEncoder.encode(currentUrl, "UTF-8") %>" class="btn-login">로그인</a>
    <% } %>
    <a href="new.jsp" class="btn-post">+ 매물 등록</a>
  </div>
</header>

<script>
  function confirmLogout() {
    if (confirm('로그아웃 하시겠습니까?')) {
      window.location.href = 'logout';
      return true;
    }
    return false;
  }
</script>
