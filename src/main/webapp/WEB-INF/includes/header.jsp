<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="css/header.css" />
<%
  // 로그인 상태 확인
  Integer userId = (Integer) session.getAttribute("userId");
  String userUId = (String) session.getAttribute("userUId");
  boolean isLoggedIn = (userId != null && userUId != null);
%>
<header class="nav">
  <a href="index.jsp" class="brand">소리집 <span class="sub">sorizip</span></a>
  
  <nav class="nav-center">
    <a href="index.jsp#features">서비스 소개</a>
    <a href="index.jsp#categories">카테고리</a>
    <a href="search.jsp">검색</a>
  </nav>
  
  <div class="nav-right">
    <% if (isLoggedIn) { %>
      <span class="user-info"><%= userUId %>님</span>
      <a href="#" onclick="return confirmLogout();" class="btn-logout">로그아웃</a>
    <% } else { %>
      <a href="login.jsp" class="btn-login">로그인</a>
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
