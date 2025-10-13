package com.example.web;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
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
      config.setJdbcUrl(props.getProperty("db.jdbcUrl"));
      config.setUsername(props.getProperty("db.username"));
      config.setPassword(props.getProperty("db.password"));
      String maxPool = props.getProperty("hikari.maximumPoolSize", "5");
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
}
