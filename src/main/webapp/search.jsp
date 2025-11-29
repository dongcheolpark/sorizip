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
    String author;
    String categories;
    String city;
    String condition;
    String imageUrl;

    Post(int id, String title, String description, int price, String author, String categories, String city, String condition, String imageUrl) {
      this.id = id;
      this.title = title;
      this.description = description;
      this.price = price;
      this.author = author;
      this.categories = categories;
      this.city = city;
      this.condition = condition;
      this.imageUrl = imageUrl;
    }
  }

  // DB에서 카테고리 목록 가져오기
  List<String> categories = new ArrayList<>();
  try {
    categories = Db.query("SELECT id, name FROM category", (ResultSet rs) -> {
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
    StringBuilder sqlBuilder = new StringBuilder(
      "SELECT sp.id, sp.title, sp.description, sp.price, u.nickname as author, " +
      "       GROUP_CONCAT(DISTINCT c.name SEPARATOR ', ') as categories, " +
      "       (SELECT image_url FROM sell_post_image WHERE post_id = sp.id ORDER BY display_order LIMIT 1) as image_url " +
      "FROM sell_post sp " +
      "LEFT JOIN user u ON sp.author_id = u.id " +
      "LEFT JOIN sell_post_category spc ON sp.id = spc.sell_post_id " +
      "LEFT JOIN category c ON spc.category_id = c.id "
    );

    List<Object> params = new ArrayList<>();
    boolean hasWhere = false;

    // 키워드 검색 조건
    if (!keyword.isEmpty()) {
      sqlBuilder.append("WHERE (sp.title LIKE ? OR sp.description LIKE ?) ");
      params.add("%" + keyword + "%");
      params.add("%" + keyword + "%");
      hasWhere = true;
    }

    // 카테고리 필터 조건
    if (!selectedCategory.isEmpty()) {
      if (hasWhere) {
        sqlBuilder.append("AND ");
      } else {
        sqlBuilder.append("WHERE ");
      }
      sqlBuilder.append("sp.id IN ( " +
        "  SELECT DISTINCT sp2.id FROM sell_post sp2 " +
        "  JOIN sell_post_category spc2 ON sp2.id = spc2.sell_post_id " +
        "  JOIN category c2 ON spc2.category_id = c2.id " +
        "  WHERE c2.name = ? " +
        ") ");
      params.add(selectedCategory);
    }

    sqlBuilder.append("GROUP BY sp.id, sp.title, sp.description, sp.price, u.nickname " +
                     "ORDER BY sp.created_at DESC");

    String sql = sqlBuilder.toString();

    posts = Db.query(sql, (ResultSet rs) -> {
      List<Post> result = new ArrayList<>();
      while (rs.next()) {
        result.add(new Post(
          rs.getInt("id"),
          rs.getString("title"),
          rs.getString("description"),
          rs.getInt("price"),
          rs.getString("author"),
          rs.getString("categories"),
          null, // city - 컬럼 없음
          null, // condition - 컬럼 없음
          rs.getString("image_url")
        ));
      }
      return result;
    }, params.toArray());
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
  <div style="display: flex; align-items: center; margin-bottom: 18px;">
    <h2 style="margin: 0;">검색 결과</h2>
    <p class="muted" style="margin: 10px 0 4px 10px;">
      <% if (!keyword.isEmpty()) { %>
        "<strong><%= keyword %></strong>"에 대한 검색 결과
      <% } else { %>
        검색어와 카테고리 필터를 조합해 원하는 악기를 찾아보세요.
      <% } %>
    </p>
  </div>

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

  <hr style="margin:16px 0; border:none; border-top:1px solid #eee;" />

  <!-- 결과 카드 (DB에서 동적 생성) -->
  <div class="grid-3" id="resultGrid">
    <% if (posts.isEmpty()) { %>
      <p class="muted" style="grid-column: 1 / -1; text-align: center; padding: 40px;">
        조건에 맞는 매물이 없습니다. 검색어와 카테고리를 바꿔보세요.
      </p>
    <% } else { %>
      <% for (Post post : posts) {
         request.setAttribute("productId", post.id);
         request.setAttribute("productTitle", post.title);
         request.setAttribute("productAuthor", post.author);
         request.setAttribute("productPrice", post.price);
         request.setAttribute("productCategories", post.categories);
         request.setAttribute("productCity", post.city);
         request.setAttribute("productCondition", post.condition);
         request.setAttribute("productImageUrl", post.imageUrl);
      %>
        <jsp:include page="WEB-INF/includes/productCard.jsp" />
      <% } %>
    <% } %>
  </div>
</section>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>

<script>
  (function () {
    const keywordInput = document.getElementById("searchInput");
    const categoryChips = document.querySelectorAll(".chip-filter");

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
  })();
</script>

</body>
</html>
