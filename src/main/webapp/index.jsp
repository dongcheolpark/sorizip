<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>소리집 sorizip – 소리를 담은 집, 중고 악기 장터</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="css/index.css" />
</head>
<body>

<header class="nav">
  <a href="index.jsp" class="brand">소리집 <span class="sub">sorizip</span></a>
  <nav>
    <a href="#features">서비스 소개</a>
    <a href="#categories">카테고리</a>
    <a href="#market">추천 매물</a>
    <a href="#cta">시작하기</a>
    <a href="new.jsp" style="color: #FF6B35; font-weight: 600;">+ 매물 등록</a>
  </nav>
</header>

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

    <div class="cta-row">
      <a class="btn ghost" href="#market">추천 매물 보기</a>
      <a class="btn ghost" href="#features">서비스 소개</a>
    </div>
  </div>
</section>

<section id="features" class="section">
  <h2>왜 소리집인가</h2>
  <div class="grid-3">
    <a class="card" href="#">
      <h3>악기 특화 검색</h3>
      <p>브랜드, 모델, 상태, 도시, 가격으로 정밀 필터를 제공합니다.</p>
    </a>
    <a class="card" href="#">
      <h3>안심 거래 가이드</h3>
      <p>대면 체크리스트와 직거래 안전 수칙으로 분쟁을 줄입니다.</p>
    </a>
    <a class="card" href="#">
      <h3>투명한 매물 정보</h3>
      <p>실사진, 상태표기, 점검 내역을 한눈에 확인할 수 있습니다.</p>
    </a>
  </div>
</section>

<section id="categories" class="section">
  <h2>주요 카테고리</h2>
  <div class="chips">
    <a class="chip" href="search.jsp?category=어쿠스틱 기타">어쿠스틱 기타</a>
    <a class="chip" href="search.jsp?category=일렉 기타">일렉 기타</a>
    <a class="chip" href="search.jsp?category=베이스">베이스</a>
    <a class="chip" href="search.jsp?category=피아노">피아노</a>
    <a class="chip" href="search.jsp?category=신디사이저">신디사이저</a>
    <a class="chip" href="search.jsp?category=관악기">관악기</a>
    <a class="chip" href="search.jsp?category=드럼">드럼</a>
  </div>
</section>

<section id="market" class="section">
  <h2>추천 매물</h2>
  <div class="grid-3">
    <a class="card product" href="#"
       data-title="야마하 업라이트 U1"
       data-brand="Yamaha"
       data-city="서울">
      <div class="thumb"></div>
      <div class="meta">
        <h3>야마하 업라이트 U1</h3>
        <p class="muted">Yamaha</p>
        <div class="row">
          <span class="price">1,800,000원</span>
          <span class="tag">good</span>
          <span class="muted">서울</span>
        </div>
      </div>
    </a>

    <a class="card product" href="#"
       data-title="펜더 스트라토캐스터"
       data-brand="Fender"
       data-city="부산">
      <div class="thumb"></div>
      <div class="meta">
        <h3>펜더 스트라토캐스터</h3>
        <p class="muted">Fender</p>
        <div class="row">
          <span class="price">950,000원</span>
          <span class="tag">like-new</span>
          <span class="muted">부산</span>
        </div>
      </div>
    </a>

    <a class="card product" href="#"
       data-title="롤랜드 디지털피아노 FP-30X"
       data-brand="Roland"
       data-city="대구">
      <div class="thumb"></div>
      <div class="meta">
        <h3>롤랜드 디지털피아노 FP-30X</h3>
        <p class="muted">Roland</p>
        <div class="row">
          <span class="price">680,000원</span>
          <span class="tag">good</span>
          <span class="muted">대구</span>
        </div>
      </div>
    </a>
  </div>
</section>

<section id="cta" class="section cta">
  <h2>지금 시작하세요</h2>
  <p>회원가입 없이도 구경 가능. 로그인 기능은 추후 연동 예정입니다.</p>
  <a class="btn primary" href="search.jsp">매물 보러가기</a>
</section>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>
</body>
</html>
