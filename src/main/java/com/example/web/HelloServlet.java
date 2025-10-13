package com.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class HelloServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    resp.setContentType("text/plain;charset=UTF-8");
    try (PrintWriter out = resp.getWriter()) {
      out.println("Hello from HelloServlet");
      out.println();
      // DB 연결 테스트
      try (Connection conn = Db.getConnection();
           PreparedStatement ps = conn.prepareStatement("SELECT 1 AS ok");
           ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          out.println("DB Connection OK (SELECT 1 = " + rs.getInt("ok") + ")");
        } else {
          out.println("DB Connection query returned no rows");
        }
      } catch (SQLException e) {
        out.println("DB ERROR: " + e.getMessage());
      }
    }
  }
}
