# Dockerfile

# Use a multi-stage build to create a Docker image

# Stage 1: Build the Spring Boot application
FROM maven:3.8.6-eclipse-temurin-11 AS build
WORKDIR /app
COPY . .
RUN cd Spring-boot-ci-cd && mvn clean package -DskipTests

# Stage 2: Create the Docker image for the Spring Boot app
FROM eclipse-temurin:11-jre-jammy
WORKDIR /app
COPY --from=build /app/Spring-boot-ci-cd/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]