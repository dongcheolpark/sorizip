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

  // 게시글의 이미지 목록 가져오기
  List<String> existingImages = new ArrayList<>();
  try {
    String imageSql = "SELECT image_url FROM sell_post_image WHERE post_id = ? ORDER BY display_order ASC";
    existingImages = Db.query(imageSql, (ResultSet rs) -> {
      List<String> result = new ArrayList<>();
      while (rs.next()) {
        result.add(rs.getString("image_url"));
      }
      return result;
    }, postId);
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
  <link rel="stylesheet" href="css/index.css" />
  <link rel="stylesheet" href="css/form.css" />
</head>
<body>

<%@ include file="WEB-INF/includes/header.jsp" %>

<div class="form-container">
  <a href="show.jsp?id=<%= post.id %>" class="back-link">← 게시글로 돌아가기</a>

  <div class="form-header">
    <h1 class="form-title">악기 매물 수정</h1>
  </div>

  <form method="post" action="editPost" enctype="multipart/form-data">
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
      <!-- 삭제할 이미지 URL 목록 (hidden) -->
      <input type="hidden" name="deleteImages" id="deleteImagesInput" value="" />
      <!-- 이미지 순서 정보 (hidden) -->
      <input type="hidden" name="imageOrder" id="imageOrderInput" value="" />
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

  // 기존 이미지와 새 파일 관리
  const existingImages = [
    <% for (int i = 0; i < existingImages.size(); i++) { %>
      '<%= existingImages.get(i) %>'<%= i < existingImages.size() - 1 ? "," : "" %>
    <% } %>
  ];

  let keepExistingImages = [...existingImages];
  let selectedFiles = [];
  const fileInput = document.querySelector('input[name="images"]');

  // 이미지 미리보기 렌더링
  function renderImagePreviews() {
    const previewContainer = document.getElementById('imagePreviewContainer');
    previewContainer.innerHTML = '';

    const allImages = [...keepExistingImages, ...selectedFiles];

    allImages.forEach((item, index) => {
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
      const isExisting = index < keepExistingImages.length;
      
      if (isExisting) {
        img.src = item;
        img.onerror = function() {
          img.style.border = '2px solid #f44336';
          img.alt = '이미지 로드 실패';
        };
      } else {
        img.src = item.dataUrl;
      }
      
      img.className = 'image-preview';

      const removeBtn = document.createElement('button');
      removeBtn.innerHTML = '×';
      removeBtn.type = 'button';
      removeBtn.className = 'image-remove-btn';
      removeBtn.onclick = function() {
        if (isExisting) {
          keepExistingImages.splice(index, 1);
        } else {
          selectedFiles.splice(index - keepExistingImages.length, 1);
          updateFileInput();
        }
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
      // 전체 이미지 배열 생성
      const allImages = [...keepExistingImages, ...selectedFiles];
      
      // 배열에서 항목 이동
      const draggedItem = allImages[draggedIndex];
      allImages.splice(draggedIndex, 1);
      allImages.splice(dropIndex, 0, draggedItem);

      // keepExistingImages와 selectedFiles 재분배
      keepExistingImages.length = 0;
      selectedFiles.length = 0;

      allImages.forEach(item => {
        if (typeof item === 'string') {
          keepExistingImages.push(item);
        } else {
          selectedFiles.push(item);
        }
      });

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

  // 페이지 로드 시 기존 이미지 표시
  renderImagePreviews();

  // 파일 선택 시 기존 파일에 추가
  fileInput.addEventListener('change', function(e) {
    const files = Array.from(e.target.files);
    const maxFileSize = 10 * 1024 * 1024; // 10MB
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
        return;
      }

      if (file.type.startsWith('image/')) {
        const reader = new FileReader();
        reader.onload = function(event) {
          selectedFiles.push({
            file: file,
            dataUrl: event.target.result
          });
          updateFileInput();
          renderImagePreviews();
        };
        reader.readAsDataURL(file);
      }
    });

    // input 초기화 (같은 파일 재선택 가능하도록)
    e.target.value = '';
  });

  // 폼 제출 시 삭제된 기존 이미지 정보 및 순서 정보 추가
  document.querySelector('form').addEventListener('submit', function(e) {
    // 삭제된 기존 이미지 URL을 hidden input으로 추가
    const deletedImages = existingImages.filter(img => !keepExistingImages.includes(img));
    deletedImages.forEach(imgUrl => {
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = 'deleteImages';
      input.value = imgUrl;
      this.appendChild(input);
    });

    // 이미지 순서 정보를 JSON으로 저장
    const allImages = [...keepExistingImages, ...selectedFiles];
    let newFileCounter = 0;
    const imageOrder = allImages.map((item, index) => {
      if (typeof item === 'string') {
        // 기존 이미지
        return {
          url: item,
          order: index + 1
        };
      } else {
        // 새 파일
        const result = {
          url: 'NEW_FILE_' + newFileCounter,
          order: index + 1
        };
        newFileCounter++;
        return result;
      }
    });
    document.getElementById('imageOrderInput').value = JSON.stringify(imageOrder);
  });
</script>

</body>
</html>
