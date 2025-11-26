package com.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * 게시글 수정 서블릿
 * - 제목, 설명, 가격, 카테고리 정보 업데이트
 * - 작성자 권한 확인
 */
public class EditPostServlet extends HttpServlet {

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String idParam = request.getParameter("id");
    String title = request.getParameter("title");
    String description = request.getParameter("description");
    String priceParam = request.getParameter("price");
    String[] categoryIds = request.getParameterValues("categories");

    if (idParam == null || idParam.isEmpty() ||
        title == null || title.trim().isEmpty() ||
        priceParam == null || priceParam.trim().isEmpty()) {
      response.sendRedirect("search.jsp");
      return;
    }

    try {
      int postId = Integer.parseInt(idParam);
      int price = Integer.parseInt(priceParam);

      // 세션에서 현재 사용자 ID 가져오기
      Integer currentUserId = (Integer) request.getSession().getAttribute("userId");
      if (currentUserId == null) {
        request.getSession().setAttribute("returnUrl", "edit.jsp?id=" + postId);
        response.sendRedirect("login.jsp");
        return;
      }

      // 게시글 작성자 확인
      String checkAuthorSql = "SELECT author_id FROM sell_post WHERE id = ?";
      Integer authorId = Db.query(checkAuthorSql, rs -> {
        if (rs.next()) {
          return rs.getInt("author_id");
        }
        return null;
      }, postId);

      // 게시글이 없거나 작성자가 아니면 거부
      if (authorId == null || authorId != currentUserId) {
        response.sendRedirect("show.jsp?id=" + postId);
        return;
      }

      // 1. 게시글 정보 업데이트
      String updatePostSql = "UPDATE sell_post SET title = ?, description = ?, price = ? WHERE id = ?";
      Db.execute(updatePostSql, title.trim(), description != null ? description.trim() : null, price, postId);

      // 2. 기존 카테고리 삭제
      String deleteCategoriesSql = "DELETE FROM sell_post_category WHERE sell_post_id = ?";
      Db.execute(deleteCategoriesSql, postId);

      // 3. 새 카테고리 추가
      if (categoryIds != null && categoryIds.length > 0) {
        String insertCategorySql = "INSERT INTO sell_post_category (sell_post_id, category_id) VALUES (?, ?)";
        for (String categoryId : categoryIds) {
          Db.execute(insertCategorySql, postId, Integer.parseInt(categoryId));
        }
      }

      // 수정 완료 후 상세 페이지로 리다이렉트
      response.sendRedirect("show.jsp?id=" + postId);

    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect("search.jsp");
    }
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    // GET 요청은 허용하지 않음
    response.sendRedirect("search.jsp");
  }
}
