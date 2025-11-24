package com.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

public class SignupServlet extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.setCharacterEncoding("UTF-8");

    String uId = req.getParameter("userUId");
    String password = req.getParameter("userPassword");
    String email = req.getParameter("userEmail");
    String name = req.getParameter("userName");
    String nickname = req.getParameter("userNickname");

    // 입력 검증
    if (uId == null || uId.trim().isEmpty() ||
        password == null || password.trim().isEmpty() ||
        email == null || email.trim().isEmpty() ||
        name == null || name.trim().isEmpty() ||
        nickname == null || nickname.trim().isEmpty()) {
      req.setAttribute("error", "모두 입력해야 합니다.");
      req.getRequestDispatcher("signup.jsp").forward(req, resp);
      return;
    }

    try {
      // 아이디 중복 확인
      String existingUId = Db.query(
          "SELECT uId FROM user WHERE uId = ?",
          rs -> rs.next() ? rs.getString("uId") : null,
          uId);

      if (existingUId != null) {
        req.setAttribute("error", "이미 사용 중인 아이디입니다.");
        req.getRequestDispatcher("signup.jsp").forward(req, resp);
        return;
      }

      // 사용자 등록
      String sql = "INSERT INTO user (uId, password, email, name, nickname) VALUES (?, ?, ?, ?, ?)";

      Db.execute(sql, uId, password, email, name, nickname);

      // 회원가입 성공 - 로그인 페이지로 리다이렉트
      resp.sendRedirect("login.jsp?signup=success");

    } catch (SQLException e) {
      req.setAttribute("error", "회원가입 중 오류가 발생했습니다: " + e.getMessage());
      req.getRequestDispatcher("signup.jsp").forward(req, resp);
    }
  }
}
