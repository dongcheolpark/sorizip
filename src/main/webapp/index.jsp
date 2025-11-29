<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.web.Db" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
  request.setCharacterEncoding("UTF-8");

  // DB에서 최신 매물 3개 가져오기
  class RecentPost {
    final int id;
    final String title;
    final String author;
    final int price;
    final String categories;
    final String city;
    final String condition;
    final String imageUrl;

    RecentPost(int id, String title, String author, int price, String categories, String city, String condition, String imageUrl) {
      this.id = id;
      this.title = title;
      this.author = author;
      this.price = price;
      this.categories = categories;
      this.city = city;
      this.condition = condition;
      this.imageUrl = imageUrl;
    }
  }

  List<RecentPost> recentPosts = new ArrayList<>();
  try {
    String sql =
      "SELECT sp.id, sp.title, sp.price, u.nickname as author, " +
      "       GROUP_CONCAT(DISTINCT c.name SEPARATOR ', ') as categories, " +
      "       (SELECT image_url FROM sell_post_image WHERE post_id = sp.id ORDER BY display_order LIMIT 1) as image_url " +
      "FROM sell_post sp " +
      "LEFT JOIN user u ON sp.author_id = u.id " +
      "LEFT JOIN sell_post_category spc ON sp.id = spc.sell_post_id " +
      "LEFT JOIN category c ON spc.category_id = c.id " +
      "GROUP BY sp.id, sp.title, sp.price, u.nickname, sp.created_at " +
      "ORDER BY sp.created_at DESC " +
      "LIMIT 3";

    recentPosts = Db.query(sql, (ResultSet rs) -> {
      List<RecentPost> result = new ArrayList<>();
      while (rs.next()) {
        result.add(new RecentPost(
          rs.getInt("id"),
          rs.getString("title"),
          rs.getString("author"),
          rs.getInt("price"),
          rs.getString("categories"),
          null, // city - 컬럼 없음
          null, // condition - 컬럼 없음
          rs.getString("image_url")
        ));
      }
      return result;
    });
  } catch (Exception e) {
    e.printStackTrace();
  }
%>
<%!
  // 가격 포맷팅 함수
  String formatPrice(int price) {
    return String.format("%,d원", price);
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>소리집 sorizip – 소리를 담은 집, 중고 악기 장터</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="css/index.css" />
</head>
<body>

<%@ include file="WEB-INF/includes/header.jsp" %>

<section class="hero">
  <div class="hero-text">
    <h1>소리를 담은 집, <span>sorizip</span></h1>
    <p>기타, 피아노, 드럼부터 관악기까지. 믿고 거래하는 중고 악기 장터.</p>

    <!-- 검색바 -->
    <form id="searchForm" class="search-bar" method="get" action="search.jsp">
      <input
        type="text"
        name="q"
        id="searchInput"
        class="search-input"
        placeholder="악기 이름, 브랜드, 도시로 검색해보세요"
      />
      <button type="submit" class="btn primary">검색</button>
    </form>

    <!-- 주요 카테고리 + 전체보기 -->
    <div class="category-section">
      <div class="chips">
        <a class="chip" href="search.jsp?category=어쿠스틱 기타">어쿠스틱 기타</a>
        <a class="chip" href="search.jsp?category=일렉 기타">일렉 기타</a>
        <a class="chip" href="search.jsp?category=베이스">베이스</a>
        <a class="chip" href="search.jsp?category=피아노">피아노</a>
        <a class="chip" href="search.jsp?category=신디사이저">신디사이저</a>
        <a class="chip" href="search.jsp?category=관악기">관악기</a>
        <a class="chip" href="search.jsp?category=드럼">드럼</a>
      </div>
      <a class="view-all-btn" href="search.jsp">
        매물 전체보기 →
      </a>
    </div>
  </div>
</section>

<section id="features" class="section">
  <h2>왜 소리집인가</h2>
  <div class="grid-3">
    <div class="card">
      <h3>쉽고 빠른 악기 검색</h3>
      <p>복잡한 검색 없이 카테고리별로 원하는 악기를 빠르게 찾아보세요.</p>
    </div>
    <div class="card">
      <h3>신뢰할 수 있는 거래</h3>
      <p>회원 기반 서비스로 판매자의 정보를 확인하고 직거래로 안전하게.</p>
    </div>
    <div class="card">
      <h3>상세한 매물 확인</h3>
      <p>고화질 이미지 슬라이더와 상세 설명으로 악기의 상태를 꼼꼼히 확인하세요.</p>
    </div>
  </div>
</section>

<section id="market" class="section">
  <div class="section-header">
    <h2>최신 매물 <a href="search.jsp" class="more-link">더보기 →</a></h2>
  </div>
  <div class="grid-3">
    <% if (recentPosts.isEmpty()) { %>
      <p class="muted empty-message">
        등록된 상품이 없습니다.
      </p>
    <% } else { %>
      <% for (RecentPost post : recentPosts) {
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
</body>
</html>
