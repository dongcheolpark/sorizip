package com.example.web;

import java.io.File;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;
import org.apache.catalina.Context;
import org.apache.catalina.WebResourceRoot;

public class TomcatServer {
  public static void main(String[] args) throws Exception {
    String webappDirLocation = "src/main/webapp";

    Tomcat tomcat = new Tomcat();
    tomcat.setPort(8081); // 포트 설정
    tomcat.getConnector(); // 커넥터 초기화

    // 웹앱 설정
    Context ctx = tomcat.addWebapp("/", new File(webappDirLocation).getAbsolutePath());

    // 클래스 파일 위치 등록 (IDE 실행용)
    File additionWebInfClasses = new File("build/classes/java/main");
    WebResourceRoot resources = new StandardRoot(ctx);
    resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
        additionWebInfClasses.getAbsolutePath(), "/"));
    ctx.setResources(resources);

    System.out.println("🚀 톰캣 서버 시작: http://localhost:8081");
    tomcat.start();
    tomcat.getServer().await();
  }
}