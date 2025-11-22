<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  request.setCharacterEncoding("UTF-8");
  String q = request.getParameter("q");
  if (q == null) q = "";
  String keyword = q.trim();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>검색 결과 – 소리집 sorizip</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="css/styles.css" />
</head>
<body>

<header class="nav">
  <div class="brand">소리집 <span class="sub">sorizip</span></div>
  <nav>
    <a href="index.jsp#features">서비스 소개</a>
    <a href="index.jsp#categories">카테고리</a>
    <a href="index.jsp#market">추천 매물</a>
    <a href="index.jsp#cta">시작하기</a>
  </nav>
</header>

<section class="section">
  <h2>검색 결과</h2>

  <!-- 검색어 다시 입력할 수 있는 작은 검색창 -->
  <form class="search-bar" method="get" action="search.jsp">
    <input
      type="text"
      name="q"
      class="search-input"
      placeholder="악기 이름, 브랜드, 도시로 검색해보세요"
      value="<%= keyword %>"
    />
    <button type="submit" class="btn primary">검색</button>
  </form>

  <%
    // 나중에: 여기서 DAO로 DB 검색하면 됨.
    // 지금은 화면 구성을 위해 더미 결과 3개만 조건부로 보여줄게.

    boolean hasKeyword = !keyword.isEmpty();
    // 대충 '야마하' 검색했다고 치고, 있을 때는 3개, 없으면 0개 예시
    int dummyCount = hasKeyword ? 3 : 0;
  %>

  <p class="muted" style="margin-top:6px;">
    <% if (hasKeyword) { %>
      "<strong><%= keyword %></strong>" 검색 결과 <strong><%= dummyCount %></strong>건
    <% } else { %>
      검색어를 입력해 주세요.
    <% } %>
  </p>

  <hr style="margin:16px 0; border:none; border-top:1px solid #eee;" />

  <% if (!hasKeyword) { %>
    <p class="muted">위 입력창에 원하는 악기를 입력해 검색해보세요.</p>
  <% } else if (dummyCount == 0) { %>
    <p>일치하는 매물이 없습니다. 다른 키워드로 다시 검색해 보세요.</p>
  <% } else { %>
    <div class="grid-3">

      <!-- 검색 결과 카드 예시 1 -->
      <a class="card product" href="#">
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

      <!-- 검색 결과 카드 예시 2 -->
      <a class="card product" href="#">
        <div class="thumb"></div>
        <div class="meta">
          <h3>야마하 어쿠스틱 기타 FG800</h3>
          <p class="muted">Yamaha · 대구</p>
          <div class="row">
            <span class="price">220,000원</span>
            <span class="tag">like-new</span>
          </div>
        </div>
      </a>

      <!-- 검색 결과 카드 예시 3 -->
      <a class="card product" href="#">
        <div class="thumb"></div>
        <div class="meta">
          <h3>야마하 디지털피아노 P-125</h3>
          <p class="muted">Yamaha · 부산</p>
          <div class="row">
            <span class="price">550,000원</span>
            <span class="tag">good</span>
          </div>
        </div>
      </a>

    </div>
  <% } %>
</section>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>

</body>
</html>
