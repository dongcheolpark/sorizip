<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>소리집 sorizip – 소리를 담은 집, 중고 악기 장터</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    *{box-sizing:border-box}
    body{margin:0;font-family:system-ui,Apple SD Gothic Neo,Segoe UI,Roboto}
    .nav{display:flex;gap:16px;align-items:center;justify-content:space-between;padding:12px 18px;border-bottom:1px solid #eee;background:#fff;position:sticky;top:0}
    .brand{font-weight:700}.brand .sub{font-weight:400;color:#9a6a00}
    .nav nav a{margin:0 8px;color:#444;text-decoration:none}
    .btn{padding:8px 14px;border:1px solid #ff8a00;border-radius:10px;background:#fff;text-decoration:none}
    .btn.primary{background:#ff8a00;color:#fff;border-color:#ff8a00}
    .btn.ghost{border-color:#ccc;color:#333}
    .hero{height:360px;background:url('assets/img/hero.jpg') center/cover no-repeat;display:flex;align-items:center;justify-content:center;position:relative}
    .hero::after{content:"";position:absolute;inset:0;background:rgba(255,255,255,.55)}
    .hero-text{position:relative;text-align:center;padding:0 12px}
    .hero-text h1{margin:0 0 8px}
    .section{padding:36px 18px;max-width:980px;margin:0 auto}
    .grid-3{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}
    .card{border:1px solid #eee;border-radius:14px;padding:14px;background:#fff;box-shadow:0 2px 10px rgba(0,0,0,.03);text-decoration:none;color:inherit}
    .card h3{margin:0 0 6px}
    .card.product{padding:0;overflow:hidden;display:block}
    .card .thumb{height:160px;background:#f5f5f5 center/cover no-repeat}
    .card .meta{padding:12px}
    .row{display:flex;gap:10px;align-items:center;flex-wrap:wrap}
    .muted{color:#888;font-size:.9rem}
    .price{font-weight:700}
    .tag{padding:2px 8px;border:1px solid #ddd;border-radius:999px;font-size:.8rem}
    .chips{display:flex;flex-wrap:wrap;gap:8px}
    .chip{padding:8px 10px;background:#fff;border:1px solid #eee;border-radius:999px}
    .cta{text-align:center;background:#fff7ee;border:1px solid #ffe1c2;border-radius:16px}
    .footer{padding:18px;color:#777;text-align:center;border-top:1px solid #eee}
    @media (max-width:900px){.grid-3{grid-template-columns:1fr 1fr}}
    @media (max-width:560px){.grid-3{grid-template-columns:1fr}}
  </style>
</head>
<body>

<header class="nav">
  <div class="brand">소리집 <span class="sub">sorizip</span></div>
  <nav>
    <a href="#features">서비스 소개</a>
    <a href="#categories">카테고리</a>
    <a href="#market">추천 매물</a>
    <a href="#cta">시작하기</a>
  </nav>
</header>

<section class="hero">
  <div class="hero-text">
    <h1>소리를 담은 집, <span>sorizip</span></h1>
    <p>기타, 피아노, 드럼부터 관악기까지. 믿고 거래하는 중고 악기 장터.</p>
    <div class="cta-row" style="display:flex;gap:10px;justify-content:center;margin-top:10px">
      <a class="btn primary" href="#market">추천 매물 보기</a>
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
    <span class="chip">어쿠스틱 기타</span>
    <span class="chip">일렉 기타</span>
    <span class="chip">베이스</span>
    <span class="chip">피아노</span>
    <span class="chip">신디사이저</span>
    <span class="chip">관악기</span>
    <span class="chip">드럼</span>
  </div>
</section>

<section id="market" class="section">
  <h2>추천 매물</h2>
  <div class="grid-3">
    <a class="card product" href="#">
      <div class="thumb" style="background-image:url('assets/img/u1.jpg')"></div>
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

    <a class="card product" href="#">
      <div class="thumb" style="background-image:url('assets/img/strat.jpg')"></div>
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

    <a class="card product" href="#">
      <div class="thumb" style="background-image:url('assets/img/fp30x.jpg')"></div>
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
  <a class="btn primary" href="#market">매물 보러가기</a>
</section>

<footer class="footer">
  <div>© <%= java.time.Year.now() %> sorizip</div>
  <div>문의: support@sorizip.example</div>
</footer>

</body>
</html>
