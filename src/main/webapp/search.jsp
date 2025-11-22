<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  request.setCharacterEncoding("UTF-8");

  String q = request.getParameter("q");
  if (q == null) q = "";
  String keyword = q.trim();

  String categoryParam = request.getParameter("category");
  if (categoryParam == null) categoryParam = "";
  String selectedCategory = categoryParam.trim();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>검색 결과 – 소리집 sorizip</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="css/search.css" />
</head>
<body>

<header class="nav">
  <a href="index.jsp" class="brand">소리집 <span class="sub">sorizip</span></a>
  <nav>
    <a href="index.jsp#features">서비스 소개</a>
    <a href="index.jsp#categories">카테고리</a>
    <a href="index.jsp#market">추천 매물</a>
    <a href="index.jsp#cta">시작하기</a>
  </nav>
</header>

<section class="section">
  <h2>검색 결과</h2>

  <!-- 상단 검색창 -->
  <form class="search-bar" method="get" action="search.jsp">
    <input
      type="text"
      name="q"
      id="searchInput"
      class="search-input"
      placeholder="악기 이름, 브랜드, 도시로 검색해보세요"
      value="<%= keyword %>"
    />
    <button type="submit" class="btn primary">검색</button>
  </form>

  <!-- 상세 검색 필터 (카테고리만) -->
  <div class="filter-bar">
  <div class="filter-group">
    <span class="filter-label">카테고리</span>

    <button type="button"
            class="chip chip-filter <%= selectedCategory.isEmpty() ? "active" : "" %>"
            data-category="">
      전체
    </button>

    <button type="button"
            class="chip chip-filter <%= "어쿠스틱 기타".equals(selectedCategory) ? "active" : "" %>"
            data-category="어쿠스틱 기타">
      어쿠스틱 기타
    </button>

    <button type="button"
            class="chip chip-filter <%= "일렉 기타".equals(selectedCategory) ? "active" : "" %>"
            data-category="일렉 기타">
      일렉 기타
    </button>

    <button type="button"
            class="chip chip-filter <%= "베이스".equals(selectedCategory) ? "active" : "" %>"
            data-category="베이스">
      베이스
    </button>

    <button type="button"
            class="chip chip-filter <%= "피아노".equals(selectedCategory) ? "active" : "" %>"
            data-category="피아노">
      피아노
    </button>

    <button type="button"
            class="chip chip-filter <%= "신디사이저".equals(selectedCategory) ? "active" : "" %>"
            data-category="신디사이저">
      신디사이저
    </button>

    <button type="button"
            class="chip chip-filter <%= "관악기".equals(selectedCategory) ? "active" : "" %>"
            data-category="관악기">
      관악기
    </button>

    <button type="button"
            class="chip chip-filter <%= "드럼".equals(selectedCategory) ? "active" : "" %>"
            data-category="드럼">
      드럼
    </button>
  </div>
</div>

  <p class="muted" style="margin-top:6px;">
    <% if (!keyword.isEmpty()) { %>
      "<strong><%= keyword %></strong>"에 대한 검색 결과
    <% } else { %>
      검색어와 카테고리 필터를 조합해 원하는 악기를 찾아보세요.
    <% } %>
  </p>

  <hr style="margin:16px 0; border:none; border-top:1px solid #eee;" />

  <!-- 결과 카드 (지금은 예시 데이터) -->
  <div class="grid-3" id="resultGrid">
    <a class="card product"
       href="#"
       data-category="피아노"
       data-brand="Yamaha"
       data-city="서울"
       data-title="야마하 업라이트 U1">
      <div class="thumb"></div>
      <div class="meta">
        <h3>야마하 업라이트 U1</h3>
        <p class="muted">Yamaha · 서울</p>
        <div class="row">
          <span class="price">1,800,000원</span>
          <span class="tag">good</span>
        </div>
      </div>
    </a>

    <a class="card product"
       href="#"
       data-category="일렉 기타"
       data-brand="Fender"
       data-city="부산"
       data-title="펜더 스트라토캐스터">
      <div class="thumb"></div>
      <div class="meta">
        <h3>펜더 스트라토캐스터</h3>
        <p class="muted">Fender · 부산</p>
        <div class="row">
          <span class="price">950,000원</span>
          <span class="tag">like-new</span>
        </div>
      </div>
    </a>

    <a class="card product"
       href="#"
       data-category="피아노"
       data-brand="Roland"
       data-city="대구"
       data-title="롤랜드 디지털피아노 FP-30X">
      <div class="thumb"></div>
      <div class="meta">
        <h3>롤랜드 디지털피아노 FP-30X</h3>
        <p class="muted">Roland · 대구</p>
        <div class="row">
          <span class="price">680,000원</span>
          <span class="tag">good</span>
        </div>
      </div>
    </a>
  </div>

  <p id="emptyMessage" style="display:none; margin-top:10px;">
    조건에 맞는 매물이 없습니다. 검색어와 카테고리를 바꿔보세요.
  </p>
</section>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>

<script>
  (function () {
    const keywordInput = document.getElementById("searchInput");
    const categoryChips = document.querySelectorAll(".chip-filter");
    const cards = document.querySelectorAll(".card.product");
    const emptyMessage = document.getElementById("emptyMessage");

    let currentCategory = "<%= selectedCategory %>";

    function applyFilter() {
      const q = (keywordInput.value || "").trim().toLowerCase();
      let visibleCount = 0;

      cards.forEach((card) => {
        const title = (card.dataset.title || "").toLowerCase();
        const brand = (card.dataset.brand || "").toLowerCase();
        const city = (card.dataset.city || "").toLowerCase();
        const category = card.dataset.category || "";

        const text = title + " " + brand + " " + city;

        const matchKeyword = !q || text.includes(q);
        const matchCategory = !currentCategory || category === currentCategory;

        const show = matchKeyword && matchCategory;
        card.style.display = show ? "" : "none";
        if (show) visibleCount++;
      });

      emptyMessage.style.display = visibleCount === 0 ? "block" : "none";
    }

    // 카테고리 칩 클릭
    categoryChips.forEach((chip) => {
      chip.addEventListener("click", () => {
        categoryChips.forEach((c) => c.classList.remove("active"));
        chip.classList.add("active");
        currentCategory = chip.dataset.category || "";
        applyFilter();
      });
    });

    // 키워드 변경
    keywordInput.addEventListener("input", applyFilter);

    document.addEventListener("DOMContentLoaded", applyFilter);
  })();
</script>

</body>
</html>
