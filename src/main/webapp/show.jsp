<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.web.Db" %>
<%@ page import="java.sql.ResultSet" %>
<%
  request.setCharacterEncoding("UTF-8");

  String idParam = request.getParameter("id");
  if (idParam == null || idParam.isEmpty()) {
    response.sendRedirect("search.jsp");
    return;
  }

  int postId = Integer.parseInt(idParam);

  // DB에서 게시글 상세 정보 가져오기
  class PostDetail {
    final int id;
    final String title;
    final String description;
    final int price;
    final String authorEmail;
    final String categories;
    final String createdAt;

    PostDetail(int id, String title, String description, int price, String authorEmail, String categories, String createdAt) {
      this.id = id;
      this.title = title;
      this.description = description;
      this.price = price;
      this.authorEmail = authorEmail;
      this.categories = categories;
      this.createdAt = createdAt;
    }
  }

  PostDetail post = null;
  try {
    String sql =
      "SELECT sp.id, sp.title, sp.description, sp.price, u.email, " +
      "       GROUP_CONCAT(c.name SEPARATOR ', ') as categories, " +
      "       sp.created_at " +
      "FROM sell_post sp " +
      "LEFT JOIN user u ON sp.author_id = u.id " +
      "LEFT JOIN sell_post_category spc ON sp.id = spc.sell_post_id " +
      "LEFT JOIN category c ON spc.category_id = c.id " +
      "WHERE sp.id = ? " +
      "GROUP BY sp.id, sp.title, sp.description, sp.price, u.email, sp.created_at";

    post = Db.query(sql, (ResultSet rs) -> {
      if (rs.next()) {
        return new PostDetail(
          rs.getInt("id"),
          rs.getString("title"),
          rs.getString("description"),
          rs.getInt("price"),
          rs.getString("email"),
          rs.getString("categories"),
          rs.getString("created_at")
        );
      }
      return null;
    }, postId);
  } catch (Exception e) {
    e.printStackTrace();
  }

  if (post == null) {
    response.sendRedirect("search.jsp");
    return;
  }
%>
<%!
  // 가격을 만원 단위로 포맷팅하는 함수
  String formatPrice(int price) {
    double manwon = price / 10000.0;
    if (manwon == (int) manwon) {
      return (int) manwon + "만원";
    } else {
      return String.format("%.1f만원", manwon);
    }
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title><%= post.title %> – 소리집 sorizip</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="css/search.css" />
  <style>
    .post-detail {
      max-width: 900px;
      margin: 0 auto;
      padding: 40px 20px;
    }

    .post-header {
      margin-bottom: 24px;
      border-bottom: 2px solid #f0f0f0;
      padding-bottom: 20px;
    }

    .post-title {
      font-size: 2em;
      font-weight: bold;
      margin-bottom: 12px;
      color: #333;
    }

    .post-meta {
      display: flex;
      gap: 16px;
      color: #666;
      font-size: 0.9em;
    }

    .post-meta span {
      display: flex;
      align-items: center;
    }

    .post-body {
      margin-bottom: 32px;
    }

    .post-section {
      margin-bottom: 24px;
    }

    .post-section-title {
      font-size: 1.2em;
      font-weight: bold;
      margin-bottom: 12px;
      color: #444;
    }

    .post-price {
      font-size: 2em;
      font-weight: bold;
      color: #FF6B35;
      margin-bottom: 16px;
    }

    .post-description {
      line-height: 1.8;
      color: #555;
      white-space: pre-wrap;
      background: #f9f9f9;
      padding: 20px;
      border-radius: 8px;
    }

    .post-categories {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
    }

    .category-badge {
      background: #FF6B35;
      color: white;
      padding: 6px 14px;
      border-radius: 20px;
      font-size: 0.9em;
    }

    .back-button {
      display: inline-block;
      margin-bottom: 20px;
      color: #FF6B35;
      text-decoration: none;
      font-weight: 500;
    }

    .back-button:hover {
      text-decoration: underline;
    }

    .contact-section {
      background: #f0f8ff;
      padding: 20px;
      border-radius: 8px;
      margin-top: 32px;
    }

    .contact-email {
      font-size: 1.1em;
      color: #333;
      font-weight: 500;
    }
  </style>
</head>
<body>

<header class="nav">
  <a href="index.jsp" class="brand">소리집 <span class="sub">sorizip</span></a>
  <nav>
    <a href="index.jsp#features">서비스 소개</a>
    <a href="index.jsp#categories">카테고리</a>
    <a href="search.jsp">검색</a>
    <a href="new.jsp" style="color: #FF6B35; font-weight: 600;">+ 매물 등록</a>
  </nav>
</header>

<div class="post-detail">
  <a href="search.jsp" class="back-button">← 목록으로 돌아가기</a>

  <div class="post-header">
    <h1 class="post-title"><%= post.title %></h1>
    <div class="post-meta">
      <span>📅 <%= post.createdAt %></span>
      <% if (post.categories != null && !post.categories.isEmpty()) { %>
      <span>🎵 <%= post.categories %></span>
      <% } %>
    </div>
  </div>

  <div class="post-body">
    <div class="post-section">
      <div class="post-price"><%= formatPrice(post.price) %></div>
    </div>

    <% if (post.categories != null && !post.categories.isEmpty()) { %>
    <div class="post-section">
      <div class="post-section-title">카테고리</div>
      <div class="post-categories">
        <% for (String cat : post.categories.split(", ")) { %>
        <span class="category-badge"><%= cat %></span>
        <% } %>
      </div>
    </div>
    <% } %>

    <div class="post-section">
      <div class="post-section-title">상세 설명</div>
      <div class="post-description"><%= post.description != null ? post.description : "상세 설명이 없습니다." %></div>
    </div>

    <% if (post.authorEmail != null) { %>
    <div class="contact-section">
      <div class="post-section-title">판매자 정보</div>
      <div class="contact-email">📧 <%= post.authorEmail %></div>
    </div>
    <% } %>
  </div>
</div>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>

</body>
</html>

