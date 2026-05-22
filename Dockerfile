# =============================================
# STAGE 1: Build con Maven
# =============================================
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .

RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn package -DskipTests

# =============================================
# STAGE 2: Run solo con JRE liviano
# =============================================
FROM eclipse-temurin:17-jre-alpine AS production

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=builder /app/target/Springboot-API-REST-DESPACHO-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8081

CMD ["java", "-jar", "app.jar"]