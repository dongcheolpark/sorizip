package com.example.web;

import java.io.File;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;
import org.apache.catalina.Context;
import org.apache.catalina.WebResourceRoot;

public class TomcatServer {
  public static void main(String[] args) throws Exception {
    // 환경에 따라 포트 설정
    String portStr = System.getenv("TOMCAT_PORT");
    int port = (portStr != null) ? Integer.parseInt(portStr) : 8081;

    // 환경에 따라 webapp 디렉토리 설정
    String environment = System.getenv("ENVIRONMENT");
    String webappDirLocation = (environment != null && environment.equals("production"))
        ? "webapp"
        : "src/main/webapp";

    Tomcat tomcat = new Tomcat();
    tomcat.setPort(port);
    tomcat.getConnector(); // 커넥터 초기화

    // 웹앱 설정
    Context ctx = tomcat.addWebapp("/", new File(webappDirLocation).getAbsolutePath());

    // 클래스 파일 위치 등록 (IDE 실행용 또는 프로덕션)
    String classesDirLocation = (environment != null && environment.equals("production"))
        ? "classes"
        : "build/classes/java/main";

    File additionWebInfClasses = new File(classesDirLocation);
    if (additionWebInfClasses.exists()) {
      WebResourceRoot resources = new StandardRoot(ctx);
      resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
          additionWebInfClasses.getAbsolutePath(), "/"));
      ctx.setResources(resources);
    }

    System.out.println("🚀 톰캣 서버 시작 [" + (environment != null ? environment : "development") + "]: http://localhost:" + port);
    tomcat.start();
    tomcat.getServer().await();
  }
}