# back-despachos

Microservicio REST de **gestión de despachos y órdenes de envío** para la plataforma logística ITPCargo. Desarrollado con Spring Boot 3.4 + Java 17, expuesto en el puerto 8081, conectado a Amazon RDS MySQL 8.0 mediante Spring Data JPA.

## Tecnologías

| Tecnología | Versión | Uso |
|---|---|---|
| Spring Boot | 3.4.4 | Framework REST |
| Java | 17 (Temurin) | Lenguaje |
| Spring Data JPA / Hibernate | — | ORM y acceso a BD |
| MySQL Connector/J | runtime | Driver JDBC |
| Lombok | provided | Reducción de boilerplate |
| SpringDoc OpenAPI | 2.7.0 | Documentación Swagger |
| Maven | 3.9 | Build tool |

## Endpoints principales

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/v1/despachos` | Listar todos los despachos |
| POST | `/api/v1/despachos` | Registrar nuevo despacho |
| GET | `/api/v1/despachos/{id}` | Obtener despacho por ID |
| PUT | `/api/v1/despachos/{id}` | Actualizar estado de despacho |
| DELETE | `/api/v1/despachos/{id}` | Eliminar registro |
| GET | `/swagger-ui.html` | Documentación interactiva |

> Este servicio escucha en el puerto **8081** (distinto de back-ventas que usa 8080), configurado en `application.properties` con `server.port=8081`.

## Estructura del proyecto

```
Springboot-API-REST-DESPACHO/
├── src/main/java/com/citt/
│   ├── controller/      # Controladores REST
│   ├── model/           # Entidades JPA
│   ├── repository/      # Interfaces Spring Data
│   └── service/         # Lógica de negocio
├── src/main/resources/
│   └── application.properties   # Configuración (variables de entorno)
├── Dockerfile           # Multi-stage: Maven → JRE Alpine
├── .dockerignore
└── pom.xml
```

## Ejecutar en desarrollo local

### Con Maven

```bash
export DB_ENDPOINT=localhost
export DB_PORT=3306
export DB_NAME=innovatech
export DB_USERNAME=appuser
export DB_PASSWORD=Innovatech2025!

./mvnw spring-boot:run
# API disponible en http://localhost:8081
```

### Con Docker Compose (todos los servicios)

Desde la raíz del proyecto semestral:

```bash
docker compose up --build
# API disponible en http://localhost:8081
```

## Variables de entorno requeridas

| Variable | Descripción | Ejemplo |
|---|---|---|
| `DB_ENDPOINT` | Host de la base de datos | `innovatech-db.cmi1jz685kmy.us-east-1.rds.amazonaws.com` |
| `DB_PORT` | Puerto MySQL | `3306` |
| `DB_NAME` | Nombre de la base de datos | `innovatech` |
| `DB_USERNAME` | Usuario MySQL | `appuser` |
| `DB_PASSWORD` | Contraseña MySQL | — |
| `SPRING_DATASOURCE_URL` | URL JDBC completa (overrides application.properties) | Ver nota abajo |

> ⚠️ **Nota importante:** MySQL 8.0 / Amazon RDS usa `caching_sha2_password` por defecto. El conector MySQL 9.x requiere `allowPublicKeyRetrieval=true`:
> ```
> SPRING_DATASOURCE_URL=jdbc:mysql://[DB_ENDPOINT]:3306/innovatech?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC
> ```
> Esta variable se configura como variable de entorno en la Task Definition de ECS, sin modificar el código fuente ni reconstruir la imagen.

## Dockerfile — explicación multi-stage

```dockerfile
# Stage 1: Compilación con Maven
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn package -DskipTests

# Stage 2: Solo JRE Alpine
FROM eclipse-temurin:17-jre-alpine AS production
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
COPY --from=builder /app/target/Springboot-API-REST-DESPACHO-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8081
CMD ["java", "-jar", "app.jar"]
```

## CI/CD con GitHub Actions

```
Push a deploy
  → Checkout código
  → Configurar credenciales AWS (GitHub Secrets)
  → Login en Amazon ECR
  → docker build + docker push → ECR :latest
  → aws ecs update-service --force-new-deployment
```

**Secrets requeridos:**

| Secret | Descripción |
|---|---|
| `AWS_ACCESS_KEY_ID` | Clave de acceso AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | Clave secreta AWS Academy |
| `AWS_SESSION_TOKEN` | Token de sesión (obligatorio en Academy) |

## Despliegue en AWS (ECS Fargate)

| Recurso | Valor |
|---|---|
| Clúster ECS | `innovatech-cluster` |
| Servicio | `back-despachos-service` |
| Task Definition | `back-despachos-task:2` |
| Repositorio ECR | `326709309665.dkr.ecr.us-east-1.amazonaws.com/back-despachos` |
| CPU / Memoria | 256 vCPU / 512 MiB |
| Puerto expuesto | 8081 |
| Ruta ALB | `/api/v1/despachos*` → `back-despachos-tg` |

## Commits convencionales

```
feat: initial commit - Spring Boot Despachos con Dockerfile multi-stage
fix: force remove conflicting back-despachos container before compose up
docs: agregar README profesional del back-despachos
ci: agregar pipeline GitHub Actions para build y push automático
```

## Autores

- **Cristian Velásquez** — ISY1101 Introducción a Herramientas DevOps · DuocUC Las Condes · 2026
