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

  // 세션에서 현재 사용자 ID 가져오기 (로그인 필요)
  Integer currentUserId = (Integer) session.getAttribute("userId");
  if (currentUserId == null) {
    session.setAttribute("returnUrl", "edit.jsp?id=" + postId);
    response.sendRedirect("login.jsp");
    return;
  }

  // DB에서 게시글 상세 정보 가져오기
  class PostDetail {
    final int id;
    final String title;
    final String description;
    final int price;
    final int authorId;
    final List<Integer> categoryIds;

    PostDetail(int id, String title, String description, int price, int authorId, List<Integer> categoryIds) {
      this.id = id;
      this.title = title;
      this.description = description;
      this.price = price;
      this.authorId = authorId;
      this.categoryIds = categoryIds;
    }
  }

  PostDetail post = null;
  try {
    String sql =
      "SELECT sp.id, sp.title, sp.description, sp.price, sp.author_id " +
      "FROM sell_post sp " +
      "WHERE sp.id = ?";

    post = Db.query(sql, (ResultSet rs) -> {
      if (rs.next()) {
        return new PostDetail(
          rs.getInt("id"),
          rs.getString("title"),
          rs.getString("description"),
          rs.getInt("price"),
          rs.getInt("author_id"),
          new ArrayList<>()
        );
      }
      return null;
    }, postId);
  } catch (Exception e) {
    e.printStackTrace();
  }

  // 게시글이 없거나 작성자가 아니면 접근 거부
  if (post == null || post.authorId != currentUserId) {
    response.sendRedirect("show.jsp?id=" + postId);
    return;
  }

  // 게시글의 카테고리 가져오기
  try {
    String categorySql = "SELECT category_id FROM sell_post_category WHERE sell_post_id = ?";
    List<Integer> categoryIds = Db.query(categorySql, (ResultSet rs) -> {
      List<Integer> result = new ArrayList<>();
      while (rs.next()) {
        result.add(rs.getInt("category_id"));
      }
      return result;
    }, postId);
    post.categoryIds.addAll(categoryIds);
  } catch (Exception e) {
    e.printStackTrace();
  }

  // DB에서 전체 카테고리 목록 가져오기
  class Category {
    final int id;
    final String name;

    Category(int id, String name) {
      this.id = id;
      this.name = name;
    }
  }

  List<Category> categories = new ArrayList<>();
  try {
    categories = Db.query("SELECT id, name FROM category ORDER BY name", (ResultSet rs) -> {
      List<Category> result = new ArrayList<>();
      while (rs.next()) {
        result.add(new Category(rs.getInt("id"), rs.getString("name")));
      }
      return result;
    });
  } catch (Exception e) {
    e.printStackTrace();
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>매물 수정 – 소리집 sorizip</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="css/search.css" />
  <style>
    .form-container {
      max-width: 800px;
      margin: 0 auto;
      padding: 40px 20px;
    }

    .form-header {
      margin-bottom: 32px;
      border-bottom: 2px solid #f0f0f0;
      padding-bottom: 20px;
    }

    .form-title {
      font-size: 2em;
      font-weight: bold;
      color: #333;
    }

    .form-group {
      margin-bottom: 24px;
    }

    .form-label {
      display: block;
      font-weight: 600;
      margin-bottom: 8px;
      color: #444;
      font-size: 1.1em;
    }

    .form-label .required {
      color: #FF6B35;
      margin-left: 4px;
    }

    .form-input,
    .form-textarea {
      width: 100%;
      padding: 12px;
      border: 2px solid #ddd;
      border-radius: 6px;
      font-size: 1em;
      transition: border-color 0.2s;
      box-sizing: border-box;
    }

    .form-input:focus,
    .form-textarea:focus {
      outline: none;
      border-color: #FF6B35;
    }

    .form-textarea {
      min-height: 200px;
      resize: vertical;
      font-family: inherit;
    }

    .form-hint {
      font-size: 0.9em;
      color: #666;
      margin-top: 6px;
    }

    .checkbox-group {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
      gap: 12px;
      margin-top: 12px;
    }

    .checkbox-item {
      display: flex;
      align-items: center;
    }

    .checkbox-item input[type="checkbox"] {
      width: 18px;
      height: 18px;
      margin-right: 8px;
      cursor: pointer;
    }

    .checkbox-item label {
      cursor: pointer;
      user-select: none;
    }

    .form-actions {
      display: flex;
      gap: 12px;
      margin-top: 32px;
      padding-top: 24px;
      border-top: 2px solid #f0f0f0;
    }

    .btn {
      padding: 12px 24px;
      border: none;
      border-radius: 6px;
      font-size: 1em;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }

    .btn-primary {
      background: #FF6B35;
      color: white;
      flex: 1;
    }

    .btn-primary:hover {
      background: #e55a2a;
      transform: translateY(-1px);
    }

    .btn-secondary {
      background: #f0f0f0;
      color: #333;
      padding: 12px 24px;
      text-decoration: none;
      display: inline-block;
      text-align: center;
    }

    .btn-secondary:hover {
      background: #e0e0e0;
    }

    .back-link {
      display: inline-block;
      margin-bottom: 20px;
      color: #FF6B35;
      text-decoration: none;
      font-weight: 500;
    }

    .back-link:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>

<%@ include file="WEB-INF/includes/header.jsp" %>

<div class="form-container">
  <a href="show.jsp?id=<%= post.id %>" class="back-link">← 게시글로 돌아가기</a>

  <div class="form-header">
    <h1 class="form-title">악기 매물 수정</h1>
  </div>

  <form method="post" action="editPost">
    <input type="hidden" name="id" value="<%= post.id %>" />

    <div class="form-group">
      <label class="form-label">
        제목<span class="required">*</span>
      </label>
      <input
        type="text"
        name="title"
        class="form-input"
        value="<%= post.title != null ? post.title : "" %>"
        placeholder="예) 야마하 업라이트 피아노 U1"
        required
      />
      <div class="form-hint">악기 이름과 모델명을 간단히 입력해주세요</div>
    </div>

    <div class="form-group">
      <label class="form-label">
        가격 (원)<span class="required">*</span>
      </label>
      <input
        type="number"
        name="price"
        class="form-input"
        value="<%= post.price %>"
        placeholder="예) 1800000"
        min="0"
        step="1000"
        required
      />
      <div class="form-hint">숫자만 입력해주세요 (단위: 원)</div>
    </div>

    <div class="form-group">
      <label class="form-label">
        카테고리<span class="required">*</span>
      </label>
      <div class="checkbox-group">
        <% for (Category category : categories) { 
           boolean isChecked = post.categoryIds.contains(category.id);
        %>
        <div class="checkbox-item">
          <input
            type="checkbox"
            name="categories"
            id="cat_<%= category.id %>"
            value="<%= category.id %>"
            <%= isChecked ? "checked" : "" %>
          />
          <label for="cat_<%= category.id %>"><%= category.name %></label>
        </div>
        <% } %>
      </div>
      <div class="form-hint">하나 이상의 카테고리를 선택해주세요</div>
    </div>

    <div class="form-group">
      <label class="form-label">
        상세 설명
      </label>
      <textarea
        name="description"
        class="form-textarea"
        placeholder="악기의 상태, 구매 시기, 사용 기간 등을 자세히 작성해주세요"
      ><%= post.description != null ? post.description : "" %></textarea>
      <div class="form-hint">구매자가 알아야 할 정보를 상세히 작성해주세요</div>
    </div>

    <div class="form-actions">
      <a href="show.jsp?id=<%= post.id %>" class="btn btn-secondary">취소</a>
      <button type="submit" class="btn btn-primary">수정하기</button>
    </div>
  </form>
</div>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>

<script>
  // 폼 제출 전 유효성 검사
  document.querySelector('form').addEventListener('submit', function(e) {
    const categories = document.querySelectorAll('input[name="categories"]:checked');
    if (categories.length === 0) {
      e.preventDefault();
      alert('최소 하나의 카테고리를 선택해주세요.');
      return false;
    }
  });
</script>

</body>
</html>
