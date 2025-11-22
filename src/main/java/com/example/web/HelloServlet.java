package com.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

public class HelloServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    resp.setContentType("text/plain;charset=UTF-8");
    try (PrintWriter out = resp.getWriter()) {
      out.println("Hello from HelloServlet");
      out.println();

      Db.query("SELECT * FROM user", rs -> {
        rs.next();
          while (true) {
            int id = rs.getInt("id");
            String password = rs.getString("password");
            String email = rs.getString("email");
            out.printf("id=%d, password=%s, email=%s%n", id, password, email);
            if (!rs.next()) {
              break;
            }
          }
        return null;
      });
    } catch (SQLException e) {
      throw new RuntimeException(e);
    }
  }
}
