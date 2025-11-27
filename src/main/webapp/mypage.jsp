<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.web.Db" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
  request.setCharacterEncoding("UTF-8");

  // 로그인 확인
  Integer currentUserId = (Integer) session.getAttribute("userId");
  if (currentUserId == null) {
%>
<script>
  alert('로그인이 필요한 서비스입니다.');
  location.href = 'login.jsp?returnUrl=' + encodeURIComponent('mypage.jsp');
</script>
<%
    return;
  }

  // 사용자 정보 클래스
  class UserInfo {
    final String uId;
    final String name;
    final String nickname;
    final String email;

    UserInfo(String uId, String name, String nickname, String email) {
      this.uId = uId;
      this.name = name;
      this.nickname = nickname;
      this.email = email;
    }
  }

  // 내 게시글 클래스
  class MyPost {
    final int id;
    final String title;
    final int price;
    final String createdAt;
    final String status; // 판매중, 판매완료 등 (현재 스키마에는 없지만 추후 확장 가능성 고려, 일단은 없음)

    MyPost(int id, String title, int price, String createdAt) {
      this.id = id;
      this.title = title;
      this.price = price;
      this.createdAt = createdAt;
      this.status = "판매중"; // 기본값
    }
  }

  // 내 댓글 클래스
  class MyComment {
    final int id;
    final int postId;
    final String postTitle;
    final String content;
    final String createdAt;

    MyComment(int id, int postId, String postTitle, String content, String createdAt) {
      this.id = id;
      this.postId = postId;
      this.postTitle = postTitle;
      this.content = content;
      this.createdAt = createdAt;
    }
  }

  UserInfo userInfo = null;
  List<MyPost> myPosts = new ArrayList<>();
  List<MyComment> myComments = new ArrayList<>();

  try {
    // 1. 사용자 정보 가져오기
    String userSql = "SELECT uId, name, nickname, email FROM user WHERE id = ?";
    userInfo = Db.query(userSql, rs -> {
      if (rs.next()) {
        return new UserInfo(
          rs.getString("uId"),
          rs.getString("name"),
          rs.getString("nickname"),
          rs.getString("email")
        );
      }
      return null;
    }, currentUserId);

    // 2. 내 게시글 가져오기
    String postSql = "SELECT id, title, price, DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') as created_at FROM sell_post WHERE author_id = ? ORDER BY created_at DESC";
    myPosts = Db.query(postSql, rs -> {
      List<MyPost> list = new ArrayList<>();
      while (rs.next()) {
        list.add(new MyPost(
          rs.getInt("id"),
          rs.getString("title"),
          rs.getInt("price"),
          rs.getString("created_at")
        ));
      }
      return list;
    }, currentUserId);

    // 3. 내 댓글 가져오기
    String commentSql = 
      "SELECT c.id, c.post_id, p.title, c.content, DATE_FORMAT(c.created_at, '%Y-%m-%d %H:%i') as created_at " +
      "FROM sell_post_comment c " +
      "JOIN sell_post p ON c.post_id = p.id " +
      "WHERE c.user_id = ? " +
      "ORDER BY c.created_at DESC";
    
    myComments = Db.query(commentSql, rs -> {
      List<MyComment> list = new ArrayList<>();
      while (rs.next()) {
        list.add(new MyComment(
          rs.getInt("id"),
          rs.getInt("post_id"),
          rs.getString("title"),
          rs.getString("content"),
          rs.getString("created_at")
        ));
      }
      return list;
    }, currentUserId);

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
  <title>마이페이지 – 소리집 sorizip</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="css/index.css" />
  <link rel="stylesheet" href="css/mypage.css" />
</head>
<body>

<%@ include file="WEB-INF/includes/header.jsp" %>

<div class="mypage-container">
  <h1 class="page-title">마이페이지</h1>

  <div class="mypage-grid">
    <!-- 왼쪽: 회원 정보 수정 -->
    <div class="profile-section">
      <h2 class="section-title">회원 정보</h2>
      
      <% 
        String updateError = (String) request.getAttribute("updateError");
        String updateSuccess = request.getParameter("update");
        if (updateError != null) { 
      %>
        <div class="alert error"><%= updateError %></div>
      <% } else if ("success".equals(updateSuccess)) { %>
        <div class="alert success">회원 정보가 수정되었습니다.</div>
      <% } %>

      <form action="updateUser" method="post" class="profile-form">
        <div class="form-group">
          <label>아이디</label>
          <input type="text" value="<%= userInfo.uId %>" disabled class="form-input disabled" />
        </div>
        
        <div class="form-group">
          <label for="name">이름</label>
          <input type="text" id="name" name="name" value="<%= userInfo.name %>" class="form-input" required />
        </div>

        <div class="form-group">
          <label for="nickname">닉네임</label>
          <input type="text" id="nickname" name="nickname" value="<%= userInfo.nickname %>" class="form-input" required />
        </div>

        <div class="form-group">
          <label for="email">이메일</label>
          <input type="email" id="email" name="email" value="<%= userInfo.email %>" class="form-input" required />
        </div>

        <div class="form-group">
          <label for="password">새 비밀번호 (변경 시 입력)</label>
          <input type="password" id="password" name="password" class="form-input" placeholder="변경하지 않으려면 비워두세요" />
        </div>

        <button type="submit" class="btn primary full-width">정보 수정 저장</button>
      </form>
    </div>

    <!-- 오른쪽: 활동 내역 -->
    <div class="activity-section">
      <!-- 내 게시글 -->
      <div class="activity-block">
        <h2 class="section-title">내 판매글 (<%= myPosts.size() %>)</h2>
        <% if (myPosts.isEmpty()) { %>
          <div class="empty-state">작성한 판매글이 없습니다.</div>
        <% } else { %>
          <ul class="activity-list">
            <% for (MyPost p : myPosts) { %>
            <li>
              <a href="show.jsp?id=<%= p.id %>" class="activity-item">
                <div class="activity-main">
                  <span class="post-title"><%= p.title %></span>
                  <span class="post-price"><%= formatPrice(p.price) %></span>
                </div>
                <div class="activity-meta"><%= p.createdAt %></div>
              </a>
            </li>
            <% } %>
          </ul>
        <% } %>
      </div>

      <!-- 내 댓글 -->
      <div class="activity-block">
        <h2 class="section-title">내 댓글 (<%= myComments.size() %>)</h2>
        <% if (myComments.isEmpty()) { %>
          <div class="empty-state">작성한 댓글이 없습니다.</div>
        <% } else { %>
          <ul class="activity-list">
            <% for (MyComment c : myComments) { %>
            <li>
              <a href="show.jsp?id=<%= c.postId %>#comment-<%= c.id %>" class="activity-item">
                <div class="activity-main">
                  <span class="comment-content"><%= c.content %></span>
                </div>
                <div class="activity-meta">
                  <div class="comment-post-title">On: <%= c.postTitle %></div>
                  <div class="comment-date"><%= c.createdAt %></div>
                </div>
              </a>
            </li>
            <% } %>
          </ul>
        <% } %>
      </div>
    </div>
  </div>
</div>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>

</body>
</html>
