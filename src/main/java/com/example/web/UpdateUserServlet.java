package com.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

public class UpdateUserServlet extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.setCharacterEncoding("UTF-8");

    HttpSession session = req.getSession(false);
    Integer userId = (Integer) (session != null ? session.getAttribute("userId") : null);

    if (userId == null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    String name = req.getParameter("name");
    String nickname = req.getParameter("nickname");
    String email = req.getParameter("email");
    String password = req.getParameter("password");

    // 기본 유효성 검사
    if (name == null || name.trim().isEmpty() ||
        nickname == null || nickname.trim().isEmpty() ||
        email == null || email.trim().isEmpty()) {
      req.setAttribute("updateError", "이름, 닉네임, 이메일은 필수 입력 항목입니다.");
      req.getRequestDispatcher("mypage.jsp").forward(req, resp);
      return;
    }

    try {
      // 비밀번호 변경 여부에 따라 쿼리 분기
      if (password != null && !password.trim().isEmpty()) {
        String sql = "UPDATE user SET name = ?, nickname = ?, email = ?, password = ? WHERE id = ?";
        Db.execute(sql, name, nickname, email, password, userId);
      } else {
        String sql = "UPDATE user SET name = ?, nickname = ?, email = ? WHERE id = ?";
        Db.execute(sql, name, nickname, email, userId);
      }

      // 성공 시 마이페이지로 리다이렉트 (성공 메시지 파라미터 포함)
      resp.sendRedirect("mypage.jsp?update=success");

    } catch (SQLException e) {
      e.printStackTrace();
      req.setAttribute("updateError", "정보 수정 중 오류가 발생했습니다: " + e.getMessage());
      req.getRequestDispatcher("mypage.jsp").forward(req, resp);
    }
  }
}
