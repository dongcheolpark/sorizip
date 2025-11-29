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
      String sql = "SELECT id, password, nickname FROM user WHERE uId = ?";

      // 로그인 성공 시 사용자 정보를 담을 클래스
      class LoginUser {
        final int id;
        final String nickname;
        LoginUser(int id, String nickname) {
          this.id = id;
          this.nickname = nickname;
        }
      }

      LoginUser loginUser = Db.query(sql, rs -> {
        if (rs.next()) {
          String dbPass = rs.getString("password");
          int id = rs.getInt("id");
          String nickname = rs.getString("nickname");
          if (dbPass != null && dbPass.equals(password)) {
            return new LoginUser(id, nickname);
          }
        }
        return null;
      }, userIdInput);

      if (loginUser != null) {
        HttpSession session = req.getSession(true);
        session.setAttribute("userId", loginUser.id); // 내부 ID (INT)
        session.setAttribute("userUId", userIdInput); // 로그인 ID (VARCHAR)
        session.setAttribute("userNickname", loginUser.nickname); // 닉네임

        // 이전 페이지로 리다이렉트 (없으면 index.jsp)
        String returnUrl = (String) session.getAttribute("returnUrl");
        session.removeAttribute("returnUrl"); // 사용 후 제거
        resp.sendRedirect(returnUrl != null ? returnUrl : "index.jsp");
      } else {
        req.setAttribute("error", "로그인에 실패했습니다.\n 아이디/비밀번호를 확인하세요.");
        req.getRequestDispatcher("login.jsp").forward(req, resp);
      }
    } catch (SQLException e) {
      throw new ServletException(e);
    }
  }
}
