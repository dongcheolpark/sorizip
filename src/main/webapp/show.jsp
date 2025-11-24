<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.web.Db" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
  request.setCharacterEncoding("UTF-8");

  String idParam = request.getParameter("id");
  if (idParam == null || idParam.isEmpty()) {
    response.sendRedirect("search.jsp");
    return;
  }

  int postId = Integer.parseInt(idParam);

  // 임시로 user id 1번으로 로그인되어있다고 가정
  int currentUserId = 1;

  // 댓글 작성 처리
  String commentAction = request.getParameter("commentAction");
  if ("submit".equals(commentAction)) {
    String commentContent = request.getParameter("content");
    if (commentContent != null && !commentContent.trim().isEmpty()) {
      try {
        String insertCommentSql = "INSERT INTO sell_post_comment (post_id, user_id, content) VALUES (?, ?, ?)";
        Db.execute(insertCommentSql, postId, currentUserId, commentContent.trim());

        // 방금 작성한 댓글의 ID 가져오기
        String getLastCommentIdSql = "SELECT LAST_INSERT_ID() as id";
        int lastCommentId = Db.query(getLastCommentIdSql, (ResultSet rs) -> {
          if (rs.next()) {
            return rs.getInt("id");
          }
          return -1;
        });

        // 댓글 작성 후 해당 댓글로 스크롤되도록 앵커 추가
        response.sendRedirect("show.jsp?id=" + postId + "#comment-" + lastCommentId);
        return;
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }

  // DB에서 게시글 상세 정보 가져오기
  class PostDetail {
    final int id;
    final String title;
    final String description;
    final int price;
    final int authorId;
    final String authorEmail;
    final String categories;
    final String createdAt;

    PostDetail(int id, String title, String description, int price, int authorId, String authorEmail, String categories, String createdAt) {
      this.id = id;
      this.title = title;
      this.description = description;
      this.price = price;
      this.authorId = authorId;
      this.authorEmail = authorEmail;
      this.categories = categories;
      this.createdAt = createdAt;
    }
  }

  // 댓글 클래스
  class Comment {
    final int id;
    final int userId;
    final String userEmail;
    final String content;
    final String createdAt;

    Comment(int id, int userId, String userEmail, String content, String createdAt) {
      this.id = id;
      this.userId = userId;
      this.userEmail = userEmail;
      this.content = content;
      this.createdAt = createdAt;
    }
  }

  PostDetail post = null;
  try {
    String sql =
      "SELECT sp.id, sp.title, sp.description, sp.price, sp.author_id, u.email, " +
      "       GROUP_CONCAT(c.name SEPARATOR ', ') as categories, " +
      "       sp.created_at " +
      "FROM sell_post sp " +
      "LEFT JOIN user u ON sp.author_id = u.id " +
      "LEFT JOIN sell_post_category spc ON sp.id = spc.sell_post_id " +
      "LEFT JOIN category c ON spc.category_id = c.id " +
      "WHERE sp.id = ? " +
      "GROUP BY sp.id, sp.title, sp.description, sp.price, sp.author_id, u.email, sp.created_at";

    post = Db.query(sql, (ResultSet rs) -> {
      if (rs.next()) {
        return new PostDetail(
          rs.getInt("id"),
          rs.getString("title"),
          rs.getString("description"),
          rs.getInt("price"),
          rs.getInt("author_id"),
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

  // 댓글 목록 가져오기
  List<Comment> comments = new ArrayList<>();
  try {
    String commentSql =
      "SELECT c.id, c.user_id, u.email, c.content, c.created_at " +
      "FROM sell_post_comment c " +
      "LEFT JOIN user u ON c.user_id = u.id " +
      "WHERE c.post_id = ? " +
      "ORDER BY c.created_at ASC";

    comments = Db.query(commentSql, (ResultSet rs) -> {
      List<Comment> result = new ArrayList<>();
      while (rs.next()) {
        result.add(new Comment(
          rs.getInt("id"),
          rs.getInt("user_id"),
          rs.getString("email"),
          rs.getString("content"),
          rs.getString("created_at")
        ));
      }
      return result;
    }, postId);
  } catch (Exception e) {
    e.printStackTrace();
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

    .comments-section {
      margin-top: 48px;
      padding-top: 32px;
      border-top: 2px solid #f0f0f0;
    }

    .comments-title {
      font-size: 1.5em;
      font-weight: bold;
      margin-bottom: 24px;
      color: #333;
    }

    .comment-form {
      background: #f9f9f9;
      padding: 20px;
      border-radius: 8px;
      margin-bottom: 32px;
    }

    .comment-textarea {
      width: 100%;
      min-height: 100px;
      padding: 12px;
      border: 2px solid #ddd;
      border-radius: 6px;
      font-size: 1em;
      resize: vertical;
      font-family: inherit;
      box-sizing: border-box;
    }

    .comment-textarea:focus {
      outline: none;
      border-color: #FF6B35;
    }

    .comment-submit {
      margin-top: 12px;
      padding: 10px 24px;
      background: #FF6B35;
      color: white;
      border: none;
      border-radius: 6px;
      font-size: 1em;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }

    .comment-submit:hover {
      background: #e55a2a;
      transform: translateY(-1px);
    }

    .comments-list {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    .comment-item {
      background: white;
      padding: 16px;
      border-radius: 8px;
      border: 1px solid #e0e0e0;
    }

    .comment-item.author {
      background: #fff8f5;
      border: 2px solid #FF6B35;
    }

    .comment-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 12px;
    }

    .comment-author {
      font-weight: 600;
      color: #333;
    }

    .comment-author.is-seller {
      color: #FF6B35;
    }

    .comment-author .seller-badge {
      background: #FF6B35;
      color: white;
      font-size: 0.75em;
      padding: 2px 8px;
      border-radius: 12px;
      margin-left: 8px;
    }

    .comment-date {
      color: #999;
      font-size: 0.9em;
    }

    .comment-content {
      color: #555;
      line-height: 1.6;
      white-space: pre-wrap;
    }

    .no-comments {
      text-align: center;
      color: #999;
      padding: 40px 20px;
      background: #f9f9f9;
      border-radius: 8px;
    }

    .comment-item.highlight {
      animation: highlightFade 2s ease-in-out;
    }

    @keyframes highlightFade {
      0% {
        background-color: #fff3cd;
        transform: scale(1.02);
      }
      100% {
        background-color: inherit;
        transform: scale(1);
      }
    }

    .comment-item.author.highlight {
      animation: highlightFadeAuthor 2s ease-in-out;
    }

    @keyframes highlightFadeAuthor {
      0% {
        background-color: #ffe8d9;
        transform: scale(1.02);
      }
      100% {
        background-color: #fff8f5;
        transform: scale(1);
      }
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

  <!-- 댓글 섹션 -->
  <div class="comments-section">
    <h2 class="comments-title">댓글 (<%= comments.size() %>)</h2>

    <!-- 댓글 작성 폼 -->
    <div class="comment-form">
      <form method="post" action="show.jsp">
        <input type="hidden" name="id" value="<%= postId %>" />
        <input type="hidden" name="commentAction" value="submit" />
        <textarea
          name="content"
          class="comment-textarea"
          placeholder="댓글을 작성해주세요..."
          required
        ></textarea>
        <button type="submit" class="comment-submit">댓글 작성</button>
      </form>
    </div>

    <!-- 댓글 리스트 -->
    <% if (comments.isEmpty()) { %>
    <div class="no-comments">
      아직 댓글이 없습니다. 첫 댓글을 작성해보세요!
    </div>
    <% } else { %>
    <div class="comments-list">
      <% for (Comment comment : comments) {
         boolean isAuthor = comment.userId == post.authorId;
      %>
      <div id="comment-<%= comment.id %>" class="comment-item <%= isAuthor ? "author" : "" %>">
        <div class="comment-header">
          <div class="comment-author <%= isAuthor ? "is-seller" : "" %>">
            <%= comment.userEmail %>
            <% if (isAuthor) { %>
            <span class="seller-badge">판매자</span>
            <% } %>
          </div>
          <div class="comment-date"><%= comment.createdAt %></div>
        </div>
        <div class="comment-content"><%= comment.content %></div>
      </div>
      <% } %>
    </div>
    <% } %>
  </div>
</div>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>

<script>
  // 페이지 로드 시 URL 해시에 해당하는 댓글로 스크롤
  document.addEventListener('DOMContentLoaded', function() {
    const hash = window.location.hash;
    if (hash && hash.startsWith('#comment-')) {
      const commentElement = document.querySelector(hash);
      if (commentElement) {
        // 부드럽게 스크롤
        setTimeout(function() {
          commentElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
          // 하이라이트 효과 추가
          commentElement.classList.add('highlight');
        }, 100);
      }
    }
  });
</script>

</body>
</html>

