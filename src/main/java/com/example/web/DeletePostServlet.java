package com.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * 게시글 삭제 서블릿
 * - 게시글과 관련된 모든 데이터 삭제 (이미지, 카테고리, 댓글)
 * - 작성자 권한 확인
 */
public class DeletePostServlet extends HttpServlet {

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) {
      response.sendRedirect("search.jsp");
      return;
    }

    try {
      int postId = Integer.parseInt(idParam);

      // 세션에서 현재 사용자 ID 가져오기
      Integer currentUserId = (Integer) request.getSession().getAttribute("userId");
      if (currentUserId == null) {
        request.getSession().setAttribute("returnUrl", "show.jsp?id=" + postId);
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

      // 1. 게시글 이미지 삭제
      String deleteImagesSql = "DELETE FROM sell_post_image WHERE post_id = ?";
      Db.execute(deleteImagesSql, postId);

      // 2. 게시글 카테고리 삭제
      String deleteCategoriesSql = "DELETE FROM sell_post_category WHERE sell_post_id = ?";
      Db.execute(deleteCategoriesSql, postId);

      // 3. 게시글 댓글 삭제
      String deleteCommentsSql = "DELETE FROM sell_post_comment WHERE post_id = ?";
      Db.execute(deleteCommentsSql, postId);

      // 4. 게시글 삭제
      String deletePostSql = "DELETE FROM sell_post WHERE id = ?";
      Db.execute(deletePostSql, postId);

      // 삭제 완료 후 목록으로 이동
      response.sendRedirect("search.jsp");

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
