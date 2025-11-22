package com.example.web;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Simple singleton-style DB access using HikariCP.
 */
public final class Db {
  private static HikariDataSource dataSource;

  static {
    try {
      Properties props = new Properties();
      try (InputStream in = Db.class.getClassLoader().getResourceAsStream("db.properties")) {
        if (in == null) {
          throw new IllegalStateException("db.properties not found in classpath");
        }
        props.load(in);
      }

      HikariConfig config = new HikariConfig();
      config.setDriverClassName(props.getProperty("db.driver"));

      // 환경 변수에서 읽기 (없으면 properties 파일에서)
      String jdbcUrl = System.getenv("MYSQL_URL");
      if (jdbcUrl == null || jdbcUrl.isEmpty()) {
        jdbcUrl = props.getProperty("db.jdbcUrl");
      }

      String username = System.getenv("MYSQL_USERNAME");
      if (username == null || username.isEmpty()) {
        username = props.getProperty("db.username");
      }

      String password = System.getenv("MYSQL_PASSWORD");
      if (password == null || password.isEmpty()) {
        password = props.getProperty("db.password");
      }

      config.setJdbcUrl(jdbcUrl);
      config.setUsername(username);
      config.setPassword(password);

      String maxPool = props.getProperty("hikari.maximumPoolSize", "10");
      config.setMaximumPoolSize(Integer.parseInt(maxPool));
      String timeout = props.getProperty("hikari.connectionTimeoutMs", "30000");
      config.setConnectionTimeout(Long.parseLong(timeout));

      dataSource = new HikariDataSource(config);
    } catch (IOException e) {
      throw new ExceptionInInitializerError(e);
    }
  }

  private Db() {
  }

  public static Connection getConnection() throws SQLException {
    return dataSource.getConnection();
  }

  /**
   * SQL 쿼리를 실행하고 결과를 처리하는 간편 메서드
   * @param sql SQL 쿼리
   * @param handler ResultSet을 처리하는 람다
   * @param params PreparedStatement 파라미터 (optional)
   * @return handler가 반환한 결과
   */
  public static <T> T query(String sql, ResultSetHandler<T> handler, Object... params) throws SQLException {
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
      for (int i = 0; i < params.length; i++) {
        ps.setObject(i + 1, params[i]);
      }
      try (ResultSet rs = ps.executeQuery()) {
        return handler.handle(rs);
      }
    }
  }

  /**
   * INSERT, UPDATE, DELETE 등을 실행하는 간편 메서드
   * @param sql SQL 쿼리
   * @param params PreparedStatement 파라미터 (optional)
   * @return 영향받은 행 수
   */
  public static int execute(String sql, Object... params) throws SQLException {
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
      for (int i = 0; i < params.length; i++) {
        ps.setObject(i + 1, params[i]);
      }
      return ps.executeUpdate();
    }
  }

  /**
   * ResultSet을 처리하는 함수형 인터페이스
   */
  @FunctionalInterface
  public interface ResultSetHandler<T> {
    T handle(ResultSet rs) throws SQLException;
  }
}

