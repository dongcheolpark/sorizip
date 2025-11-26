<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.web.Db" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
  request.setCharacterEncoding("UTF-8");

  // 세션에 저장된 사용자 ID를 사용 (로그인 필요)
  Integer currentUserId = (Integer) session.getAttribute("userId");
  if (currentUserId == null) {
    session.setAttribute("returnUrl", "new.jsp");
    response.sendRedirect("login.jsp");
    return;
  }

  // 폼 제출 처리
  String action = request.getParameter("action");
  if ("submit".equals(action)) {
    String title = request.getParameter("title");
    String description = request.getParameter("description");
    String priceStr = request.getParameter("price");
    String[] categoryIds = request.getParameterValues("categories");

    if (title != null && !title.trim().isEmpty() && priceStr != null && !priceStr.trim().isEmpty()) {
      try {
        int price = Integer.parseInt(priceStr);

        // sell_post 테이블에 insert
        String insertPostSql = "INSERT INTO sell_post (title, description, price, author_id) VALUES (?, ?, ?, ?)";
        Db.execute(insertPostSql, title, description, price, currentUserId);

        // 방금 insert한 id 가져오기
        String getIdSql = "SELECT LAST_INSERT_ID() as id";
        int postId = Db.query(getIdSql, (ResultSet rs) -> {
          if (rs.next()) {
            return rs.getInt("id");
          }
          return -1;
        });

        // 카테고리 연결
        if (categoryIds != null && categoryIds.length > 0 && postId > 0) {
          String insertCategorySql = "INSERT INTO sell_post_category (sell_post_id, category_id) VALUES (?, ?)";
          for (String categoryId : categoryIds) {
            Db.execute(insertCategorySql, postId, Integer.parseInt(categoryId));
          }
        }

        // 작성 완료 후 상세 페이지로 리다이렉트
        if (postId > 0) {
          response.sendRedirect("show.jsp?id=" + postId);
          return;
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }

  // DB에서 카테고리 목록 가져오기
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
  <title>매물 등록 – 소리집 sorizip</title>
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
  <a href="search.jsp" class="back-link">← 목록으로 돌아가기</a>

  <div class="form-header">
    <h1 class="form-title">악기 매물 등록</h1>
  </div>

  <form method="post" action="post" enctype="multipart/form-data">
    <input type="hidden" name="action" value="create" />

    <div class="form-group">
      <label class="form-label">
        제목<span class="required">*</span>
      </label>
      <input
        type="text"
        name="title"
        class="form-input"
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
        <% for (Category category : categories) { %>
        <div class="checkbox-item">
          <input
            type="checkbox"
            name="categories"
            id="cat_<%= category.id %>"
            value="<%= category.id %>"
          />
          <label for="cat_<%= category.id %>"><%= category.name %></label>
        </div>
        <% } %>
      </div>
      <div class="form-hint">하나 이상의 카테고리를 선택해주세요</div>
    </div>

    <div class="form-group">
      <label class="form-label">
        이미지 업로드
      </label>
      <input
        type="file"
        name="images"
        class="form-input"
        accept="image/*"
        multiple
      />
      <div class="form-hint">여러 개의 이미지를 선택할 수 있습니다 (최대 10MB per file)</div>
      <div id="imagePreviewContainer" style="display: flex; flex-wrap: wrap; gap: 10px; margin-top: 12px;"></div>
    </div>

    <div class="form-group">
      <label class="form-label">
        상세 설명
      </label>
      <textarea
        name="description"
        class="form-textarea"
        placeholder="악기의 상태, 구매 시기, 사용 기간 등을 자세히 작성해주세요"
      ></textarea>
      <div class="form-hint">구매자가 알아야 할 정보를 상세히 작성해주세요</div>
    </div>

    <div class="form-actions">
      <a href="search.jsp" class="btn btn-secondary">취소</a>
      <button type="submit" class="btn btn-primary">등록하기</button>
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

  // 이미지 관리용 배열
  let selectedFiles = [];
  const fileInput = document.querySelector('input[name="images"]');

  // 이미지 미리보기 렌더링
  function renderImagePreviews() {
    const previewContainer = document.getElementById('imagePreviewContainer');
    previewContainer.innerHTML = '';

    selectedFiles.forEach((file, index) => {
      const wrapper = document.createElement('div');
      wrapper.style.position = 'relative';
      wrapper.style.display = 'inline-block';

      const img = document.createElement('img');
      img.src = file.dataUrl;
      img.style.width = '120px';
      img.style.height = '120px';
      img.style.objectFit = 'cover';
      img.style.borderRadius = '8px';
      img.style.border = '2px solid #ddd';

      const removeBtn = document.createElement('button');
      removeBtn.innerHTML = '×';
      removeBtn.type = 'button';
      removeBtn.style.position = 'absolute';
      removeBtn.style.top = '4px';
      removeBtn.style.right = '4px';
      removeBtn.style.width = '24px';
      removeBtn.style.height = '24px';
      removeBtn.style.borderRadius = '4px';
      removeBtn.style.background = 'rgba(0, 0, 0, 0.5)';
      removeBtn.style.color = 'white';
      removeBtn.style.border = 'none';
      removeBtn.style.cursor = 'pointer';
      removeBtn.style.fontSize = '18px';
      removeBtn.style.lineHeight = '1';
      removeBtn.style.padding = '0';
      removeBtn.style.transition = 'background 0.2s';
      removeBtn.onmouseover = function() {
        this.style.background = 'rgba(0, 0, 0, 0.7)';
      };
      removeBtn.onmouseout = function() {
        this.style.background = 'rgba(0, 0, 0, 0.5)';
      };
      removeBtn.onclick = function() {
        selectedFiles.splice(index, 1);
        updateFileInput();
        renderImagePreviews();
      };

      wrapper.appendChild(img);
      wrapper.appendChild(removeBtn);
      previewContainer.appendChild(wrapper);
    });
  }

  // FileInput 업데이트
  function updateFileInput() {
    const dt = new DataTransfer();
    selectedFiles.forEach(file => dt.items.add(file.file));
    fileInput.files = dt.files;
  }

  // 파일 선택 시 기존 파일에 추가
  fileInput.addEventListener('change', function(e) {
    const files = Array.from(e.target.files);

    files.forEach(file => {
      if (file.type.startsWith('image/')) {
        const reader = new FileReader();
        reader.onload = function(event) {
          selectedFiles.push({
            file: file,
            dataUrl: event.target.result
          });
          renderImagePreviews();
        };
        reader.readAsDataURL(file);
      }
    });
  });
</script>

</body>
</html>

