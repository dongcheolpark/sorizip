<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head><title>Session Debug</title></head>
<body>
<h1>현재 세션 정보</h1>
<p>userId: <%= session.getAttribute("userId") %></p>
<p>userUId: <%= session.getAttribute("userUId") %></p>
<p>Session ID: <%= session.getId() %></p>
<hr>
<a href="index.jsp">메인으로</a>
</body>
</html>
