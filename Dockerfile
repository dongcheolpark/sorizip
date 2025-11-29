# Build stage
FROM gradle:8.5-jdk17 AS builder
WORKDIR /app
# Copy gradle files
COPY build.gradle settings.gradle ./
COPY gradle ./gradle
COPY gradlew ./
# Copy source code
COPY src ./src
# Build the application and copy dependencies
RUN ./gradlew clean build copyDependencies --no-daemon
# Runtime stage
FROM eclipse-temurin:17-jre
WORKDIR /app
# Copy compiled classes and resources
COPY --from=builder /app/build/classes/java/main ./classes
COPY --from=builder /app/build/resources/main ./resources
# Copy source webapp
COPY src/main/webapp ./webapp
# Copy all runtime dependencies
COPY --from=builder /app/build/libs/dependencies ./libs
# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
# Set environment variables
ENV CLASSPATH=/app/classes:/app/resources:/app/libs/*
ENV TOMCAT_PORT=8080
ENV ENVIRONMENT=production
# Expose port
EXPOSE 8080
# Run the application
CMD ["java", "-Dfile.encoding=UTF-8", "-cp", "/app/classes:/app/resources:/app/libs/*", "com.example.web.TomcatServer"]
