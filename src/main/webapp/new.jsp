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
    categories = Db.query("SELECT id, name FROM category", (ResultSet rs) -> {
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
  <link rel="stylesheet" href="css/form.css" />
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
      <div id="imagePreviewContainer"></div>
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
      wrapper.className = 'image-preview-wrapper';
      wrapper.draggable = true;
      wrapper.dataset.index = index;

      // 대표 사진 뱃지 (첫 번째 이미지)
      if (index === 0) {
        const badge = document.createElement('div');
        badge.className = 'representative-badge';
        badge.textContent = '대표 사진';
        wrapper.appendChild(badge);
      }

      const img = document.createElement('img');
      img.src = file.dataUrl;
      img.className = 'image-preview';

      const removeBtn = document.createElement('button');
      removeBtn.innerHTML = '×';
      removeBtn.type = 'button';
      removeBtn.className = 'image-remove-btn';
      removeBtn.onclick = function() {
        selectedFiles.splice(index, 1);
        updateFileInput();
        renderImagePreviews();
      };

      // 드래그 이벤트
      wrapper.addEventListener('dragstart', handleDragStart);
      wrapper.addEventListener('dragend', handleDragEnd);
      wrapper.addEventListener('dragover', handleDragOver);
      wrapper.addEventListener('drop', handleDrop);
      wrapper.addEventListener('dragenter', handleDragEnter);
      wrapper.addEventListener('dragleave', handleDragLeave);

      wrapper.appendChild(img);
      wrapper.appendChild(removeBtn);
      previewContainer.appendChild(wrapper);
    });
  }

  // 드래그 앤 드롭 관련 변수
  let draggedIndex = null;

  function handleDragStart(e) {
    draggedIndex = parseInt(e.currentTarget.dataset.index);
    e.currentTarget.classList.add('dragging');
    e.dataTransfer.effectAllowed = 'move';
  }

  function handleDragEnd(e) {
    e.currentTarget.classList.remove('dragging');
    document.querySelectorAll('.image-preview-wrapper').forEach(el => {
      el.classList.remove('drag-over');
    });
  }

  function handleDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    return false;
  }

  function handleDragEnter(e) {
    e.currentTarget.classList.add('drag-over');
  }

  function handleDragLeave(e) {
    e.currentTarget.classList.remove('drag-over');
  }

  function handleDrop(e) {
    e.preventDefault();
    e.stopPropagation();

    const dropIndex = parseInt(e.currentTarget.dataset.index);

    if (draggedIndex !== null && draggedIndex !== dropIndex) {
      // 배열에서 항목 이동
      const draggedItem = selectedFiles[draggedIndex];
      selectedFiles.splice(draggedIndex, 1);
      selectedFiles.splice(dropIndex, 0, draggedItem);

      updateFileInput();
      renderImagePreviews();
    }

    return false;
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
    const maxFileSize = 10 * 1024 * 1024; // 10MB
    let filesProcessed = 0;
    let validFilesProcessed = 0;
    let rejectedFiles = [];

    // 먼저 거부된 파일 확인
    files.forEach(file => {
      if (file.size > maxFileSize) {
        rejectedFiles.push(file.name);
      }
    });

    // 거부된 파일이 있으면 즉시 알림
    if (rejectedFiles.length > 0) {
      alert('다음 파일은 10MB를 초과하여 업로드할 수 없습니다:\n' + rejectedFiles.join('\n'));
    }

    files.forEach(file => {
      // 파일 크기 체크
      if (file.size > maxFileSize) {
        filesProcessed++;
        return;
      }

      if (file.type.startsWith('image/')) {
        const reader = new FileReader();
        reader.onload = function(event) {
          selectedFiles.push({
            file: file,
            dataUrl: event.target.result
          });
          filesProcessed++;
          validFilesProcessed++;
          
          // 모든 파일 처리 완료 후 input 업데이트
          if (filesProcessed === files.length) {
            updateFileInput();
            renderImagePreviews();
          }
        };
        reader.readAsDataURL(file);
      } else {
        filesProcessed++;
      }
    });

    // input 초기화 (같은 파일 재선택 가능하도록)
    e.target.value = '';
  });
</script>

</body>
</html>

