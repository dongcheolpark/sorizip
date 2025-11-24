package com.example.web;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;

import java.io.IOException;
import java.io.InputStream;
import java.util.UUID;

/**
 * GCP Cloud Storage를 사용한 이미지 업로드 유틸리티
 */
public final class ImageUploader {
  private static Storage storage;
  private static boolean initialized = false;

  private ImageUploader() {
  }

  private static String getFromEnvOrProperties(String key) {
    // 환경변수에서 먼저 확인
    String value = System.getenv(key);
    if (value != null && !value.isEmpty()) {
      return value;
    }

    // properties에서 확인
    try (java.io.InputStream in = ImageUploader.class.getClassLoader().getResourceAsStream("db.properties")) {
      if (in != null) {
        java.util.Properties props = new java.util.Properties();
        props.load(in);
        value = props.getProperty(key);
      }
    } catch (Exception ignored) {
    }

    return value;
  }

  private static synchronized void initialize() {
    if (initialized) {
      return;
    }

    String projectId = getFromEnvOrProperties("GCP_PROJECT_ID");
    System.out.println("🔍 GCP_PROJECT_ID: " + projectId);

    try {
      if (projectId != null && !projectId.isEmpty()) {
        System.out.println("🔧 GCP 인증 시도 중...");
        storage = StorageOptions.newBuilder()
            .setProjectId(projectId)
            .build()
            .getService();
        System.out.println("✅ GCP Cloud Storage 초기화 성공");
      } else {
        System.out.println("🔧 기본 GCP 인증 사용 시도 중...");
        storage = StorageOptions.getDefaultInstance().getService();
        System.out.println("✅ GCP Cloud Storage 초기화 성공 (기본 인증)");
      }
      initialized = true;
    } catch (Exception e) {
      System.err.println("❌ Cloud Storage 초기화 실패");
      System.err.println("⚠️  GCP 인증이 설정되지 않았습니다.");
      System.err.println("💡 다음 중 하나를 설정해주세요:");
      System.err.println("   1. 환경변수: export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json");
      System.err.println("   2. gcloud CLI: gcloud auth application-default login");
      System.err.println("📝 에러 상세: " + e.getMessage());
      // 초기화 실패를 표시하되, 예외는 던지지 않음
      initialized = true; // 반복 시도 방지
      storage = null;
    }
  }

  /**
   * 이미지를 Cloud Storage에 업로드하고 공개 URL을 반환
   *
   * @param inputStream 업로드할 파일의 InputStream
   * @param fileName    원본 파일명
   * @param contentType 파일의 MIME 타입
   * @return 업로드된 이미지의 공개 URL
   * @throws IOException 업로드 실패 시
   */
  public static String uploadImage(InputStream inputStream, String fileName, String contentType)
      throws IOException {
    // 초기화
    initialize();

    // 고유한 파일명 생성 (UUID + 원본 확장자)
    String extension = "";
    int lastDot = fileName.lastIndexOf('.');
    if (lastDot > 0) {
      extension = fileName.substring(lastDot);
    }
    String uniqueFileName = UUID.randomUUID() + extension;

    // GCP Storage가 사용 가능한 경우
    if (storage != null) {
      String bucketName = getFromEnvOrProperties("GCS_BUCKET_NAME");
      System.out.println("🔍 GCS_BUCKET_NAME: " + bucketName);

      if (bucketName != null && !bucketName.isEmpty()) {
        try {
          // 저장 경로: images/ 폴더 아래
          String objectName = "images/" + uniqueFileName;

          // Cloud Storage에 업로드
          BlobId blobId = BlobId.of(bucketName, objectName);
          BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
              .setContentType(contentType)
              .build();

          byte[] bytes = inputStream.readAllBytes();
          storage.create(blobInfo, bytes);

          // 공개 URL 반환
          String url = String.format("https://storage.googleapis.com/%s/%s", bucketName, objectName);
          System.out.println("✅ GCS 업로드 성공: " + url);
          return url;
        } catch (Exception e) {
          System.err.println("⚠️ GCS 업로드 실패, 로컬 저장으로 전환: " + e.getMessage());
        }
      }
    }

    // GCP 사용 불가 시 로컬에 저장 (개발용)
    System.out.println("💾 로컬 저장 모드 (개발용)");
    java.io.File uploadDir = new java.io.File("src/main/webapp/uploads/images");
    if (!uploadDir.exists()) {
      uploadDir.mkdirs();
    }

    java.io.File destFile = new java.io.File(uploadDir, uniqueFileName);
    byte[] bytes = inputStream.readAllBytes();
    java.nio.file.Files.write(destFile.toPath(), bytes);

    String localUrl = "/uploads/images/" + uniqueFileName;
    System.out.println("✅ 로컬 저장 완료: " + localUrl);
    return localUrl;
  }

  /**
   * 이미지 URL에서 객체 이름 추출 후 삭제
   *
   * @param imageUrl 삭제할 이미지의 URL
   * @return 삭제 성공 여부
   */
  public static boolean deleteImage(String imageUrl) {
    initialize();

    if (storage == null || imageUrl == null || imageUrl.isEmpty()) {
      return false;
    }

    String bucketName = getFromEnvOrProperties("GCS_BUCKET_NAME");
    if (bucketName == null || bucketName.isEmpty()) {
      return false;
    }

    try {
      // URL에서 객체 이름 추출
      String objectName = imageUrl.substring(imageUrl.indexOf("images/"));
      BlobId blobId = BlobId.of(bucketName, objectName);
      return storage.delete(blobId);
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }
}
