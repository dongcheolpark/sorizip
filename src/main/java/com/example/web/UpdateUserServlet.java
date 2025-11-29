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
      // 닉네임 중복 확인 (본인 제외)
      String existingNickname = Db.query(
          "SELECT nickname FROM user WHERE nickname = ? AND id != ?",
          rs -> rs.next() ? rs.getString("nickname") : null,
          nickname, userId);

      if (existingNickname != null) {
        req.setAttribute("updateError", "이미 사용 중인 닉네임입니다.");
        req.getRequestDispatcher("mypage.jsp").forward(req, resp);
        return;
      }

      // 이메일 중복 확인 (본인 제외)
      String existingEmail = Db.query(
          "SELECT email FROM user WHERE email = ? AND id != ?",
          rs -> rs.next() ? rs.getString("email") : null,
          email, userId);

      if (existingEmail != null) {
        req.setAttribute("updateError", "이미 사용 중인 이메일입니다.");
        req.getRequestDispatcher("mypage.jsp").forward(req, resp);
        return;
      }

      // 비밀번호 변경 여부에 따라 쿼리 분기
      if (password != null && !password.trim().isEmpty()) {
        // 비밀번호 검증 (7자리 이상, 영어+숫자 포함)
        if (password.length() < 7) {
          req.setAttribute("updateError", "비밀번호는 7자리 이상이어야 합니다.");
          req.getRequestDispatcher("mypage.jsp").forward(req, resp);
          return;
        }

        boolean hasLetter = false;
        boolean hasDigit = false;
        for (char c : password.toCharArray()) {
          if (Character.isLetter(c)) hasLetter = true;
          if (Character.isDigit(c)) hasDigit = true;
        }

        if (!hasLetter || !hasDigit) {
          req.setAttribute("updateError", "비밀번호는 영어와 숫자를 모두 포함해야 합니다.");
          req.getRequestDispatcher("mypage.jsp").forward(req, resp);
          return;
        }

        String sql = "UPDATE user SET name = ?, nickname = ?, email = ?, password = ? WHERE id = ?";
        Db.execute(sql, name, nickname, email, password, userId);
      } else {
        String sql = "UPDATE user SET name = ?, nickname = ?, email = ? WHERE id = ?";
        Db.execute(sql, name, nickname, email, userId);
      }

      // 닉네임이 변경되었으면 세션도 업데이트
      HttpSession updateSession = req.getSession(false);
      if (updateSession != null) {
        updateSession.setAttribute("userNickname", nickname);
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
