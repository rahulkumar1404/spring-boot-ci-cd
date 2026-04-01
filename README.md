# 🚀 Spring Boot CI/CD Pipeline — AWS EC2 Auto Deployment

![Java](https://img.shields.io/badge/Java-25-orange?style=for-the-badge&logo=java)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.5-brightgreen?style=for-the-badge&logo=springboot)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![AWS EC2](https://img.shields.io/badge/AWS%20EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)

> **Every commit to `main` is automatically built, containerized, and deployed to an AWS EC2 instance — zero manual steps.**

---

## 📌 Project Overview

This project demonstrates a complete end-to-end **CI/CD pipeline** for a Spring Boot REST API using **GitHub Actions**, **Docker**, and **AWS EC2**. The pipeline triggers on every push to the `main` branch and handles building, containerizing, pushing to Docker Hub, and deploying the application to EC2 — all automatically.

---

## 🏗️ Architecture

```
Developer → git push → GitHub (main branch)
                               │
                        GitHub Actions
                               │
               ┌───────────────────────────────┐
               │           Single Job           │
               │  1. Checkout code              │
               │  2. Setup Java 25 (Temurin)    │
               │  3. mvn clean package          │
               │  4. Login to Docker Hub        │
               │  5. Build Docker image         │
               │  6. Push image to Docker Hub   │
               │  7. SSH into EC2               │
               │     └─ Stop old container      │
               │     └─ Pull latest image       │
               │     └─ Run new container       │
               └───────────────────────────────┘
                               │
                        AWS EC2 Instance
                        :8080 (Live App)
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Java 25 |
| Framework | Spring Boot 4.0.5 |
| Build Tool | Maven 3.9 |
| Base Image | eclipse-temurin:25 (Temurin JDK/JRE) |
| Containerization | Docker (multi-stage build) |
| Registry | Docker Hub |
| CI/CD | GitHub Actions |
| Deployment | AWS EC2 via `appleboy/ssh-action` |

---

## 📂 Project Structure

```
spring-boot-ci-cd/
├── Spring-boot-ci-cd/          # Maven project root
│   ├── src/main/java/...       # Application source code
│   ├── pom.xml                 # Maven config (Spring Boot 4.0.5, Java 25)
│   └── target/                 # Built JAR (generated)
├── .github/
│   └── workflows/
│       └── cicd.yml            # GitHub Actions pipeline
├── Dockerfile                  # Multi-stage Docker build
└── README.md
```

---

## ⚙️ CI/CD Pipeline — How It Works

### Pipeline File: `.github/workflows/cicd.yml`

Triggers on every push to `main`. Runs a single job on `ubuntu-latest`:

| Step | Action |
|---|---|
| Checkout Code | `actions/checkout@v4` |
| Setup Java 25 | `actions/setup-java@v5` with Temurin distribution |
| Build JAR | `mvn clean package -DskipTests` inside `Spring-boot-ci-cd/` |
| Docker Hub Login | `docker/login-action@v4` using secrets |
| Build Docker Image | Multi-stage build → `springboot-ci-demo:latest` |
| Push to Docker Hub | Pushes image to Docker Hub registry |
| SSH Deploy to EC2 | `appleboy/ssh-action@v1` — stops old container, pulls new image, runs fresh container |

### Deploy Script (runs on EC2 via SSH)
```bash
docker stop spring-demo || true
docker rm spring-demo   || true
docker pull <DOCKERHUB_USERNAME>/springboot-ci-demo:latest
docker run -d --name spring-demo -p 8080:8080 \
  <DOCKERHUB_USERNAME>/springboot-ci-demo:latest
```

---

## 🐳 Dockerfile — Multi-Stage Build

```dockerfile
# Stage 1: Build (Maven + JDK 25)
FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /app
COPY . .
RUN cd Spring-boot-ci-cd && mvn clean package -DskipTests

# Stage 2: Runtime (lean JRE only)
FROM eclipse-temurin:25-jre-jammy
WORKDIR /app
COPY --from=build /app/Spring-boot-ci-cd/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

> Multi-stage build keeps the final image lean — only the JRE + JAR, no Maven or source code.

---

## 🔐 GitHub Secrets Required

Go to repo → **Settings → Secrets and Variables → Actions** and add:

| Secret Name | Description |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |
| `EC2_HOST` | Public IP or DNS of your AWS EC2 instance |
| `EC2_USER` | SSH user (e.g. `ubuntu`) |
| `EC2_SSH_KEY` | Contents of your `.pem` private key file |

---

## ☁️ AWS EC2 Setup

### 1. Launch EC2 Instance
- AMI: **Ubuntu 22.04 LTS (Jammy)**
- Instance type: `t2.micro` (free tier eligible)
- Security Group inbound rules:
  - Port **22** → SSH
  - Port **8080** → Application (0.0.0.0/0)

### 2. Install Docker on EC2
```bash
sudo apt update
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
```

---

## 🚀 Local Setup & Run

### Prerequisites
- Java 25+
- Maven 3.9+
- Docker

### Steps

```bash
# Clone the repo
git clone https://github.com/rahulkumar1404/spring-boot-ci-cd.git
cd spring-boot-ci-cd

# Build
cd Spring-boot-ci-cd
mvn clean package -DskipTests

# Run locally
java -jar target/*.jar

# Or via Docker
cd ..
docker build -t springboot-ci-demo .
docker run -p 8080:8080 springboot-ci-demo
```

---

## 🔁 Triggering the Pipeline

```bash
git add .
git commit -m "feat: your change"
git push origin main
```

GitHub Actions picks it up → builds JAR → builds + pushes Docker image → SSHs into EC2 → redeploys container. All within minutes.

---

## 📡 Accessing the Application

```
http://<your-ec2-public-ip>:8080
```

---

## 📝 Key Learnings

- Writing a **GitHub Actions** single-job pipeline with ordered steps
- **Multi-stage Docker builds** for lean production images
- Secure credential management via **GitHub Secrets**
- Zero-downtime-style redeploy using `docker stop → pull → run`
- Remote EC2 deployment via `appleboy/ssh-action`
- Running **Spring Boot 4.0.5** on cutting-edge **Java 25**

---

## 👤 Author

**Rahul Kumar**  
Junior Software Engineer — Cognizant Technology Solutions  
[GitHub](https://github.com/rahulkumar1404) · [LinkedIn](https://www.linkedin.com/in/rahulkumar1404)
