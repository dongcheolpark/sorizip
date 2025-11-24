<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.web.Db" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
  request.setCharacterEncoding("UTF-8");

  String q = request.getParameter("q");
  if (q == null) q = "";
  String keyword = q.trim();

  String categoryParam = request.getParameter("category");
  if (categoryParam == null) categoryParam = "";
  String selectedCategory = categoryParam.trim();

  // DB에서 판매 게시글 가져오기
  class Post {
    int id;
    String title;
    String description;
    int price;
    String authorEmail;
    String categories;

    Post(int id, String title, String description, int price, String authorEmail, String categories) {
      this.id = id;
      this.title = title;
      this.description = description;
      this.price = price;
      this.authorEmail = authorEmail;
      this.categories = categories;
    }
  }

  // DB에서 카테고리 목록 가져오기
  List<String> categories = new ArrayList<>();
  try {
    categories = Db.query("SELECT name FROM category ORDER BY name", (ResultSet rs) -> {
      List<String> result = new ArrayList<>();
      while (rs.next()) {
        result.add(rs.getString("name"));
      }
      return result;
    });
  } catch (Exception e) {
    e.printStackTrace();
  }

  List<Post> posts = new ArrayList<>();
  try {
    String sql;
    if (!selectedCategory.isEmpty()) {
      // 카테고리 필터가 있을 때
      sql =
        "SELECT sp.id, sp.title, sp.description, sp.price, u.email, " +
        "       GROUP_CONCAT(c.name SEPARATOR ', ') as categories " +
        "FROM sell_post sp " +
        "LEFT JOIN user u ON sp.author_id = u.id " +
        "LEFT JOIN sell_post_category spc ON sp.id = spc.sell_post_id " +
        "LEFT JOIN category c ON spc.category_id = c.id " +
        "WHERE sp.id IN ( " +
        "  SELECT DISTINCT sp2.id FROM sell_post sp2 " +
        "  JOIN sell_post_category spc2 ON sp2.id = spc2.sell_post_id " +
        "  JOIN category c2 ON spc2.category_id = c2.id " +
        "  WHERE c2.name = ? " +
        ") " +
        "GROUP BY sp.id, sp.title, sp.description, sp.price, u.email " +
        "ORDER BY sp.created_at DESC";

      posts = Db.query(sql, (ResultSet rs) -> {
        List<Post> result = new ArrayList<>();
        while (rs.next()) {
          result.add(new Post(
            rs.getInt("id"),
            rs.getString("title"),
            rs.getString("description"),
            rs.getInt("price"),
            rs.getString("email"),
            rs.getString("categories")
          ));
        }
        return result;
      }, selectedCategory);
    } else {
      // 전체 조회
      sql =
        "SELECT sp.id, sp.title, sp.description, sp.price, u.email, " +
        "       GROUP_CONCAT(c.name SEPARATOR ', ') as categories " +
        "FROM sell_post sp " +
        "LEFT JOIN user u ON sp.author_id = u.id " +
        "LEFT JOIN sell_post_category spc ON sp.id = spc.sell_post_id " +
        "LEFT JOIN category c ON spc.category_id = c.id " +
        "GROUP BY sp.id, sp.title, sp.description, sp.price, u.email " +
        "ORDER BY sp.created_at DESC";

      posts = Db.query(sql, (ResultSet rs) -> {
        List<Post> result = new ArrayList<>();
        while (rs.next()) {
          result.add(new Post(
            rs.getInt("id"),
            rs.getString("title"),
            rs.getString("description"),
            rs.getInt("price"),
            rs.getString("email"),
            rs.getString("categories")
          ));
        }
        return result;
      });
    }
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
  <title>검색 결과 – 소리집 sorizip</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="css/search.css" />
</head>
<body>

<%@ include file="WEB-INF/includes/header.jsp" %>

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

    <% for (String category : categories) { %>
    <button type="button"
            class="chip chip-filter <%= category.equals(selectedCategory) ? "active" : "" %>"
            data-category="<%= category %>">
      <%= category %>
    </button>
    <% } %>
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

  <!-- 결과 카드 (DB에서 동적 생성) -->
  <div class="grid-3" id="resultGrid">
    <% for (Post post : posts) {
       String categoriesDisplay = post.categories != null ? post.categories : "미분류";
       String priceFormatted = formatPrice(post.price);
    %>
    <a class="card product"
       href="show.jsp?id=<%= post.id %>"
       data-category="<%= categoriesDisplay %>"
       data-title="<%= post.title %>">
      <div class="thumb"></div>
      <div class="meta">
        <h3><%= post.title %></h3>
        <p class="muted"><%= categoriesDisplay %></p>
        <div class="row">
          <span class="price"><%= priceFormatted %></span>
        </div>
        <% if (post.description != null && !post.description.isEmpty()) { %>
        <p class="muted" style="font-size:0.85em; margin-top:4px;"><%= post.description %></p>
        <% } %>
      </div>
    </a>
    <% } %>
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
        const category = card.dataset.category || "";

        const text = title + " " + category;

        // 키워드만 클라이언트 사이드에서 필터링 (카테고리는 서버에서 이미 필터링됨)
        const matchKeyword = !q || text.includes(q);

        card.style.display = matchKeyword ? "" : "none";
        if (matchKeyword) visibleCount++;
      });

      emptyMessage.style.display = visibleCount === 0 ? "block" : "none";
    }

    // 카테고리 칩 클릭 - 서버 사이드 필터링을 위해 페이지 리로드
    categoryChips.forEach((chip) => {
      chip.addEventListener("click", () => {
        const category = chip.dataset.category || "";
        const currentKeyword = keywordInput.value.trim();

        // URL 파라미터 구성
        let url = "search.jsp?";
        if (currentKeyword) {
          url += "q=" + encodeURIComponent(currentKeyword) + "&";
        }
        if (category) {
          url += "category=" + encodeURIComponent(category);
        }

        // 페이지 이동
        window.location.href = url;
      });
    });

    // 키워드 변경
    keywordInput.addEventListener("input", applyFilter);

    document.addEventListener("DOMContentLoaded", applyFilter);
  })();
</script>

</body>
</html>
