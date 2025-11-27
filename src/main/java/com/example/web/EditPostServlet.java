package com.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * 게시글 수정 서블릿
 * - 제목, 설명, 가격, 카테고리 정보 업데이트
 * - 작성자 권한 확인
 * - 이미지 업로드 지원
 */
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10, // 10MB
    maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class EditPostServlet extends HttpServlet {

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String idParam = request.getParameter("id");
    String title = request.getParameter("title");
    String description = request.getParameter("description");
    String priceParam = request.getParameter("price");
    String[] categoryIds = request.getParameterValues("categories");

    if (idParam == null || idParam.isEmpty() ||
        title == null || title.trim().isEmpty() ||
        priceParam == null || priceParam.trim().isEmpty()) {
      response.sendRedirect("search.jsp");
      return;
    }

    try {
      int postId = Integer.parseInt(idParam);
      int price = Integer.parseInt(priceParam);

      // 세션에서 현재 사용자 ID 가져오기
      Integer currentUserId = (Integer) request.getSession().getAttribute("userId");
      if (currentUserId == null) {
        request.getSession().setAttribute("returnUrl", "edit.jsp?id=" + postId);
        response.sendRedirect("login.jsp");
        return;
      }

      // 게시글 작성자 확인
      String checkAuthorSql = "SELECT author_id FROM sell_post WHERE id = ?";
      Integer authorId = Db.query(checkAuthorSql, rs -> {
        if (rs.next()) {
          return rs.getInt("author_id");
        }
        return null;
      }, postId);

      // 게시글이 없거나 작성자가 아니면 거부
      if (authorId == null || authorId != currentUserId) {
        response.sendRedirect("show.jsp?id=" + postId);
        return;
      }

      // 1. 게시글 정보 업데이트
      String updatePostSql = "UPDATE sell_post SET title = ?, description = ?, price = ? WHERE id = ?";
      Db.execute(updatePostSql, title.trim(), description != null ? description.trim() : null, price, postId);

      // 2. 기존 카테고리 삭제
      String deleteCategoriesSql = "DELETE FROM sell_post_category WHERE sell_post_id = ?";
      Db.execute(deleteCategoriesSql, postId);

      // 3. 새 카테고리 추가
      if (categoryIds != null && categoryIds.length > 0) {
        String insertCategorySql = "INSERT INTO sell_post_category (sell_post_id, category_id) VALUES (?, ?)";
        for (String categoryId : categoryIds) {
          Db.execute(insertCategorySql, postId, Integer.parseInt(categoryId));
        }
      }

      // 4. 삭제할 이미지 처리
      String[] deleteImages = request.getParameterValues("deleteImages");
      if (deleteImages != null && deleteImages.length > 0) {
        String deleteImageSql = "DELETE FROM sell_post_image WHERE post_id = ? AND image_url = ?";
        for (String imageUrl : deleteImages) {
          Db.execute(deleteImageSql, postId, imageUrl);
        }
      }

      // 5. 이미지 순서 정보 처리
      String imageOrderJson = request.getParameter("imageOrder");
      if (imageOrderJson != null && !imageOrderJson.trim().isEmpty()) {
        // JSON 파싱 대신 간단하게 기존 이미지들의 순서를 업데이트
        // 형식: [{"url":"https://...","order":1},{"url":"NEW_FILE_0","order":2},...]
        try {
          // 기존 이미지들의 순서만 업데이트
          String updateOrderSql = "UPDATE sell_post_image SET display_order = ? WHERE post_id = ? AND image_url = ?";

          // 간단한 JSON 파싱 (라이브러리 없이)
          String[] entries = imageOrderJson.split("\\},\\{");
          for (String entry : entries) {
            entry = entry.replace("[{", "").replace("}]", "").replace("{", "").replace("}", "");
            String[] pairs = entry.split(",");

            String url = null;
            int order = 0;

            for (String pair : pairs) {
              if (pair.contains("\"url\"")) {
                url = pair.split(":")[1].replace("\"", "").trim();
              } else if (pair.contains("\"order\"")) {
                order = Integer.parseInt(pair.split(":")[1].trim());
              }
            }

            // 기존 이미지인 경우에만 순서 업데이트 (NEW_FILE은 나중에 추가됨)
            if (url != null && !url.startsWith("NEW_FILE")) {
              Db.execute(updateOrderSql, order, postId, url);
            }
          }
        } catch (Exception e) {
          System.err.println("⚠️ 이미지 순서 업데이트 실패: " + e.getMessage());
          // 순서 업데이트 실패해도 계속 진행
        }
      }

      // 6. 새 이미지 업로드 및 추가
      Collection<Part> parts = request.getParts();
      List<String> newImageUrls = new ArrayList<>();

      for (Part part : parts) {
        if ("images".equals(part.getName()) && part.getSize() > 0) {
          String contentType = part.getContentType();
          if (contentType != null && contentType.startsWith("image/")) {
            String fileName = getFileName(part);
            try {
              String imageUrl = ImageUploader.uploadImage(
                  part.getInputStream(),
                  fileName,
                  contentType);
              newImageUrls.add(imageUrl);
            } catch (Exception imageError) {
              System.err.println("⚠️ 이미지 업로드 실패: " + fileName);
              System.err.println("   에러: " + imageError.getMessage());
              // 이미지 업로드 실패해도 계속 진행
            }
          }
        }
      }

      // 7. 새 이미지가 있으면 DB에 추가 (imageOrder에서 NEW_FILE의 순서 사용)
      if (!newImageUrls.isEmpty()) {
        String insertImageSql = "INSERT INTO sell_post_image (post_id, image_url, display_order) VALUES (?, ?, ?)";

        // imageOrderJson에서 NEW_FILE의 순서 찾기
        int newFileIndex = 0;
        for (String imageUrl : newImageUrls) {
          int displayOrder = 999 + newFileIndex; // 기본값

          if (imageOrderJson != null && !imageOrderJson.trim().isEmpty()) {
            try {
              String searchKey = "NEW_FILE_" + newFileIndex;
              if (imageOrderJson.contains(searchKey)) {
                // 해당 NEW_FILE의 order 찾기
                String[] entries = imageOrderJson.split("\\},\\{");
                for (String entry : entries) {
                  if (entry.contains(searchKey)) {
                    String[] pairs = entry.split(",");
                    for (String pair : pairs) {
                      if (pair.contains("\"order\"")) {
                        displayOrder = Integer.parseInt(pair.split(":")[1].trim().replace("}", ""));
                        break;
                      }
                    }
                    break;
                  }
                }
              }
            } catch (Exception e) {
              System.err.println("⚠️ NEW_FILE 순서 파싱 실패, 기본값 사용");
            }
          }

          Db.execute(insertImageSql, postId, imageUrl, displayOrder);
          newFileIndex++;
        }
      }

      // 수정 완료 후 상세 페이지로 리다이렉트
      response.sendRedirect("show.jsp?id=" + postId);

    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect("search.jsp");
    }
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

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    // GET 요청은 허용하지 않음
    response.sendRedirect("search.jsp");
  }
}
