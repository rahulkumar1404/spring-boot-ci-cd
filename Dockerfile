# Dockerfile

# Use a multi-stage build to create a Docker image

# Stage 1: Build the Spring Boot application
FROM maven:3.8.6-jdk-11 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Create the Docker image for the Spring Boot app
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]