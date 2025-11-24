package com.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

public class LoginServlet extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.setCharacterEncoding("UTF-8");
    String userIdInput = req.getParameter("userUId");
    String password = req.getParameter("userPassword");

    if (userIdInput == null || password == null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    try {
      String sql = "SELECT id, password FROM user WHERE uId = ?";

      Integer foundId = Db.query(sql, rs -> {
        if (rs.next()) {
          String dbPass = rs.getString("password");
          int id = rs.getInt("id");
          if (dbPass != null && dbPass.equals(password)) {
            return id;
          }
        }
        return -1;
      }, userIdInput);

      if (foundId != null && foundId > 0) {
        HttpSession session = req.getSession(true);
        session.setAttribute("userId", foundId); // 내부 ID (INT)
        session.setAttribute("userUId", userIdInput); // 로그인 ID (VARCHAR)
        resp.sendRedirect("index.jsp");
      } else {
        req.setAttribute("error", "로그인에 실패했습니다.\n 아이디/비밀번호를 확인하세요.");
        req.getRequestDispatcher("login.jsp").forward(req, resp);
      }
    } catch (SQLException e) {
      throw new ServletException(e);
    }
  }
}
