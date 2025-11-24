<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // 파라미터로 받을 값들
  int productId = (Integer) request.getAttribute("productId");
  String productTitle = (String) request.getAttribute("productTitle");
  String productAuthor = (String) request.getAttribute("productAuthor");
  int productPrice = (Integer) request.getAttribute("productPrice");
  String productCategories = (String) request.getAttribute("productCategories");
  String productCity = (String) request.getAttribute("productCity");
  String productCondition = (String) request.getAttribute("productCondition");
  String productImageUrl = (String) request.getAttribute("productImageUrl");
  
  // 기본값 설정
  if (productAuthor == null) productAuthor = "";
  if (productCategories == null) productCategories = "상품";
  if (productCity == null) productCity = "";
  if (productCondition == null) productCondition = "";
  if (productImageUrl == null) productImageUrl = "";
  
  // 가격 포맷팅
  String formattedPrice = String.format("%,d원", productPrice);
  
  // 상태 한글 변환
  String conditionText = "";
  if ("good".equals(productCondition)) {
    conditionText = "good";
  } else if ("like-new".equals(productCondition)) {
    conditionText = "like-new";
  } else if ("excellent".equals(productCondition)) {
    conditionText = "excellent";
  }
  
  // 카테고리 분리 (콤마로 구분된 경우)
  String[] categoryArray = productCategories != null ? productCategories.split(",\\s*") : new String[0];
%>
<a class="product-card" href="show.jsp?id=<%= productId %>" data-category="<%= productCategories %>" data-title="<%= productTitle %>">
  <div class="product-thumb" style="<%= !productImageUrl.isEmpty() ? "background-image: url('" + productImageUrl + "'); background-size: cover; background-position: center;" : "" %>"></div>
  <div class="product-info">
    <h3 class="product-title"><%= productTitle %></h3>
    <p class="product-author"><%= productAuthor %></p>
    
    <div class="product-bottom">
      <p class="product-price"><%= formattedPrice %></p>
      <div class="product-tags">
        <% if (!conditionText.isEmpty()) { %>
          <span class="product-tag"><%= conditionText %></span>
        <% } %>
        <% for (String category : categoryArray) { 
           if (category != null && !category.trim().isEmpty()) { %>
          <span class="product-tag"><%= category.trim() %></span>
        <% } } %>
      </div>
    </div>
    
    <% if (!productCity.isEmpty()) { %>
      <p class="product-location"><%= productCity %></p>
    <% } %>
  </div>
</a>
