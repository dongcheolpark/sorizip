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

  // 세션에서 현재 사용자 ID 가져오기
  Integer currentUserId = (Integer) session.getAttribute("userId");

  // 댓글 작성 및 삭제 처리 (로그인 필요)
  String commentAction = request.getParameter("commentAction");
  if (currentUserId != null) {
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
    } else if ("delete".equals(commentAction)) {
      String commentIdParam = request.getParameter("commentId");
      if (commentIdParam != null) {
        try {
          int commentId = Integer.parseInt(commentIdParam);
          // 본인 댓글인지 확인 후 삭제 (user_id 조건 추가)
          String deleteCommentSql = "DELETE FROM sell_post_comment WHERE id = ? AND user_id = ?";
          Db.execute(deleteCommentSql, commentId, currentUserId);
          
          response.sendRedirect("show.jsp?id=" + postId + "#comments-section");
          return;
        } catch (Exception e) {
          e.printStackTrace();
        }
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
    final String userNickname;
    final String content;
    final String createdAt;

    Comment(int id, int userId, String userEmail, String userNickname, String content, String createdAt) {
      this.id = id;
      this.userId = userId;
      this.userEmail = userEmail;
      this.userNickname = userNickname;
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

  // 이미지 목록 가져오기
  List<String> images = new ArrayList<>();
  try {
    String imageSql =
      "SELECT image_url " +
      "FROM sell_post_image " +
      "WHERE post_id = ? " +
      "ORDER BY display_order ASC";

    images = Db.query(imageSql, (ResultSet rs) -> {
      List<String> result = new ArrayList<>();
      while (rs.next()) {
        result.add(rs.getString("image_url"));
      }
      return result;
    }, postId);
  } catch (Exception e) {
    e.printStackTrace();
  }

  // 댓글 목록 가져오기
  List<Comment> comments = new ArrayList<>();
  try {
    String commentSql =
      "SELECT c.id, c.user_id, u.email, u.nickname, c.content, c.created_at " +
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
          rs.getString("nickname"),
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
  <link rel="stylesheet" href="css/show.css" />
</head>
<body>

<%@ include file="WEB-INF/includes/header.jsp" %>

<div class="post-detail">
  <a href="search.jsp" class="back-button">← 목록으로 돌아가기</a>

  <div class="post-header">
    <div style="display: flex; justify-content: space-between; align-items: flex-start;">
      <div style="flex: 1;">
        <h1 class="post-title"><%= post.title %></h1>
        <div class="post-meta">
          <span>📅 <%= post.createdAt %></span>
          <% if (post.categories != null && !post.categories.isEmpty()) { %>
          <span>🎵 <%= post.categories %></span>
          <% } %>
        </div>
      </div>
      
      <% if (currentUserId != null && currentUserId == post.authorId) { %>
      <div style="display: flex; gap: 8px;">
        <a href="edit.jsp?id=<%= post.id %>" class="edit-btn">수정</a>
        <button onclick="confirmDelete()" class="delete-btn">삭제</button>
      </div>
      <% } %>
    </div>
  </div>

  <!-- 이미지 슬라이더 -->
  <% if (!images.isEmpty()) { %>
  <div class="image-slider">
    <div class="slider-container">
      <% for (int i = 0; i < images.size(); i++) { %>
      <img src="<%= images.get(i) %>" alt="<%= post.title %>" class="slider-image <%= i == 0 ? "active" : "" %>" />
      <% } %>

      <% if (images.size() > 1) { %>
      <button class="slider-btn prev" onclick="changeSlide(-1)">‹</button>
      <button class="slider-btn next" onclick="changeSlide(1)">›</button>

      <div class="slider-counter">
        <span id="currentSlide">1</span> / <%= images.size() %>
      </div>

      <div class="slider-dots">
        <% for (int i = 0; i < images.size(); i++) { %>
        <div class="slider-dot <%= i == 0 ? "active" : "" %>" onclick="goToSlide(<%= i %>)"></div>
        <% } %>
      </div>
      <% } %>
    </div>
  </div>
  <% } else { %>
  <div class="no-images">
    📷 등록된 이미지가 없습니다
  </div>
  <% } %>

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
  <div class="comments-section" id="comments-section">
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
         boolean isMyComment = currentUserId != null && currentUserId == comment.userId;
      %>
      <div id="comment-<%= comment.id %>" class="comment-item <%= isAuthor ? "author" : "" %>">
        <div class="comment-header">
          <div class="comment-author <%= isAuthor ? "is-seller" : "" %>">
            <%= comment.userNickname %> (<%= comment.userEmail %>)
            <% if (isAuthor) { %>
            <span class="seller-badge">판매자</span>
            <% } %>
          </div>
          <div class="comment-date">
            <%= comment.createdAt %>
            <% if (isMyComment) { %>
            <form action="show.jsp" method="post" style="display: inline; margin-left: 8px;">
              <input type="hidden" name="id" value="<%= postId %>">
              <input type="hidden" name="commentAction" value="delete">
              <input type="hidden" name="commentId" value="<%= comment.id %>">
              <button type="submit" class="comment-delete-btn" onclick="return confirm('댓글을 삭제하시겠습니까?')">삭제</button>
            </form>
            <% } %>
          </div>
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
  // 이미지 슬라이더
  let currentSlideIndex = 0;
  const totalSlides = <%= images.size() %>;

  function showSlide(index) {
    const slides = document.querySelectorAll('.slider-image');
    const dots = document.querySelectorAll('.slider-dot');
    const counter = document.getElementById('currentSlide');

    if (slides.length === 0) return;

    // 인덱스 범위 체크
    if (index >= slides.length) {
      currentSlideIndex = 0;
    } else if (index < 0) {
      currentSlideIndex = slides.length - 1;
    } else {
      currentSlideIndex = index;
    }

    // 모든 슬라이드 숨기기
    slides.forEach(slide => slide.classList.remove('active'));
    dots.forEach(dot => dot.classList.remove('active'));

    // 현재 슬라이드만 표시
    slides[currentSlideIndex].classList.add('active');
    if (dots.length > 0) {
      dots[currentSlideIndex].classList.add('active');
    }
    if (counter) {
      counter.textContent = currentSlideIndex + 1;
    }
  }

  function changeSlide(direction) {
    showSlide(currentSlideIndex + direction);
  }

  function goToSlide(index) {
    showSlide(index);
  }

  // 키보드 화살표 키로 슬라이드 이동
  document.addEventListener('keydown', function(e) {
    if (totalSlides > 1) {
      if (e.key === 'ArrowLeft') {
        changeSlide(-1);
      } else if (e.key === 'ArrowRight') {
        changeSlide(1);
      }
    }
  });

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

  // 게시글 삭제 확인
  function confirmDelete() {
    if (confirm('정말 이 게시글을 삭제하시겠습니까?\n삭제된 게시글은 복구할 수 없습니다.')) {
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = 'deletePost';
      
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = 'id';
      input.value = '<%= post.id %>';
      
      form.appendChild(input);
      document.body.appendChild(form);
      form.submit();
    }
  }
</script>

</body>
</html>

