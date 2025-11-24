package com.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * 게시글 및 이미지 업로드를 처리하는 서블릿
 */
@WebServlet("/post")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,        // 10MB
    maxRequestSize = 1024 * 1024 * 50      // 50MB
)
public class PostServlet extends HttpServlet {

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    req.setCharacterEncoding("UTF-8");

    System.out.println("🔍 PostServlet 호출됨");
    System.out.println("   Content-Type: " + req.getContentType());

    // multipart/form-data의 경우 getParts()를 먼저 호출해야 파라미터를 읽을 수 있음
    String action = null;
    try {
      // action 파라미터 찾기
      for (Part part : req.getParts()) {
        if ("action".equals(part.getName())) {
          action = new String(part.getInputStream().readAllBytes(), "UTF-8");
          System.out.println("   action 파라미터 발견: " + action);
          break;
        }
      }
    } catch (Exception e) {
      System.err.println("❌ 파라미터 읽기 실패: " + e.getMessage());
    }

    System.out.println("   action: " + action);

    if ("create".equals(action)) {
      handleCreatePost(req, resp);
    } else if ("uploadImages".equals(action)) {
      handleUploadImages(req, resp);
    } else {
      System.err.println("❌ 알 수 없는 action: " + action);
      resp.sendRedirect("search.jsp");
    }
  }

  /**
   * 게시글 생성 처리
   */
  private void handleCreatePost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    System.out.println("📝 게시글 생성 요청 받음");

    String title = req.getParameter("title");
    String description = req.getParameter("description");
    String priceStr = req.getParameter("price");
    String[] categoryIds = req.getParameterValues("categories");

    System.out.println("   제목: " + title);
    System.out.println("   가격: " + priceStr);
    System.out.println("   카테고리 개수: " + (categoryIds != null ? categoryIds.length : 0));

    // 임시로 user id 1번으로 로그인되어있다고 가정
    int currentUserId = 1;

    if (title == null || title.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty()) {
      System.err.println("❌ 필수 항목 누락");
      resp.sendRedirect("new.jsp?error=required");
      return;
    }

    try {
      int price = Integer.parseInt(priceStr);

      // 게시글 생성
      int postId = createPost(title, description, price, currentUserId);

      if (postId <= 0) {
        resp.sendRedirect("new.jsp?error=failed");
        return;
      }

      // 카테고리 연결
      if (categoryIds != null && categoryIds.length > 0) {
        linkCategories(postId, categoryIds);
      }

      // 이미지 업로드 처리
      Collection<Part> parts = req.getParts();
      List<String> imageUrls = new ArrayList<>();

      System.out.println("📷 이미지 업로드 처리 시작");
      System.out.println("   총 파트 수: " + parts.size());

      try {
        for (Part part : parts) {
          System.out.println("   파트: " + part.getName() + ", 크기: " + part.getSize() + " bytes, 타입: " + part.getContentType());
          if ("images".equals(part.getName()) && part.getSize() > 0) {
            String contentType = part.getContentType();
            if (contentType != null && contentType.startsWith("image/")) {
              String fileName = getFileName(part);
              try {
                String imageUrl = ImageUploader.uploadImage(
                    part.getInputStream(),
                    fileName,
                    contentType
                );
                imageUrls.add(imageUrl);
                System.out.println("✅ 이미지 업로드 성공: " + fileName);
              } catch (Exception imageError) {
                System.err.println("⚠️ 이미지 업로드 실패: " + fileName);
                System.err.println("   에러: " + imageError.getMessage());
                // 이미지 업로드 실패해도 계속 진행
              }
            }
          }
        }

        // 이미지 URL을 DB에 저장
        if (!imageUrls.isEmpty()) {
          saveImageUrls(postId, imageUrls);
          System.out.println("✅ " + imageUrls.size() + "개 이미지 정보 DB 저장 완료");
        } else {
          System.out.println("ℹ️ 업로드된 이미지 없음");
        }
      } catch (Exception e) {
        System.err.println("⚠️ 이미지 처리 중 오류 발생: " + e.getMessage());
        // 이미지 업로드 실패해도 게시글은 생성됨
      }

      // 생성된 게시글로 리다이렉트
      resp.sendRedirect("show.jsp?id=" + postId);

    } catch (Exception e) {
      e.printStackTrace();
      resp.sendRedirect("new.jsp?error=exception");
    }
  }

  /**
   * 기존 게시글에 이미지 추가
   */
  private void handleUploadImages(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    String postIdStr = req.getParameter("postId");

    if (postIdStr == null || postIdStr.isEmpty()) {
      resp.sendRedirect("search.jsp");
      return;
    }

    try {
      int postId = Integer.parseInt(postIdStr);

      // 이미지 업로드 처리
      Collection<Part> parts = req.getParts();
      List<String> imageUrls = new ArrayList<>();

      for (Part part : parts) {
        if ("images".equals(part.getName()) && part.getSize() > 0) {
          String contentType = part.getContentType();
          if (contentType != null && contentType.startsWith("image/")) {
            String fileName = getFileName(part);
            String imageUrl = ImageUploader.uploadImage(
                part.getInputStream(),
                fileName,
                contentType
            );
            imageUrls.add(imageUrl);
          }
        }
      }

      // 이미지 URL을 DB에 저장
      if (!imageUrls.isEmpty()) {
        saveImageUrls(postId, imageUrls);
      }

      resp.sendRedirect("show.jsp?id=" + postId);

    } catch (Exception e) {
      e.printStackTrace();
      resp.sendRedirect("search.jsp");
    }
  }

  /**
   * 게시글 생성
   */
  private int createPost(String title, String description, int price, int authorId)
      throws Exception {
    String sql = "INSERT INTO sell_post (title, description, price, author_id) VALUES (?, ?, ?, ?)";

    try (Connection conn = Db.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
      ps.setString(1, title);
      ps.setString(2, description);
      ps.setInt(3, price);
      ps.setInt(4, authorId);

      ps.executeUpdate();

      try (ResultSet rs = ps.getGeneratedKeys()) {
        if (rs.next()) {
          return rs.getInt(1);
        }
      }
    }
    return -1;
  }

  /**
   * 카테고리 연결
   */
  private void linkCategories(int postId, String[] categoryIds) throws Exception {
    String sql = "INSERT INTO sell_post_category (sell_post_id, category_id) VALUES (?, ?)";

    try (Connection conn = Db.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
      for (String categoryId : categoryIds) {
        ps.setInt(1, postId);
        ps.setInt(2, Integer.parseInt(categoryId));
        ps.addBatch();
      }
      ps.executeBatch();
    }
  }

  /**
   * 이미지 URL들을 DB에 저장
   */
  private void saveImageUrls(int postId, List<String> imageUrls) throws Exception {
    String sql = "INSERT INTO sell_post_image (post_id, image_url, display_order) VALUES (?, ?, ?)";

    // 기존 이미지의 최대 display_order 가져오기
    int maxOrder = getMaxDisplayOrder(postId);

    try (Connection conn = Db.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
      for (int i = 0; i < imageUrls.size(); i++) {
        ps.setInt(1, postId);
        ps.setString(2, imageUrls.get(i));
        ps.setInt(3, maxOrder + i + 1);
        ps.addBatch();
      }
      ps.executeBatch();
    }
  }

  /**
   * 기존 이미지의 최대 display_order 가져오기
   */
  private int getMaxDisplayOrder(int postId) throws Exception {
    String sql = "SELECT COALESCE(MAX(display_order), 0) as max_order FROM sell_post_image WHERE post_id = ?";

    return Db.query(sql, rs -> {
      if (rs.next()) {
        return rs.getInt("max_order");
      }
      return 0;
    }, postId);
  }

  /**
   * Part에서 파일명 추출
   */
  private String getFileName(Part part) {
    String contentDisposition = part.getHeader("content-disposition");
    String[] tokens = contentDisposition.split(";");

    for (String token : tokens) {
      if (token.trim().startsWith("filename")) {
        return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
      }
    }
    return "unknown";
  }
}

