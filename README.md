# 🚀 Back Despachos — ITPCargo

Microservicio de gestión de despachos de **ITPCargo**, desarrollado en Spring Boot y contenedorizado con Docker.

## 📋 Descripción

API REST que gestiona las órdenes de despacho de la plataforma ITPCargo. Se comunica con la base de datos PostgreSQL y responde las peticiones del Frontend.

## 🛠️ Tecnologías

- Java 17
- Spring Boot
- PostgreSQL 15
- Docker (multi-stage build)
- GitHub Actions (CI/CD)

## 🐳 Ejecutar con Docker

```bash
docker pull cristian102711/back-despachos:latest
docker run -p 8081:8081 cristian102711/back-despachos:latest
```

## 🔧 Ejecutar localmente con Docker Compose

```bash
docker compose up --build
```

## ⚙️ Pipeline CI/CD

Cada push a la rama `deploy` activa automáticamente el pipeline de GitHub Actions que:

1. Construye la imagen Docker
2. Publica en Docker Hub
3. Despliega en EC2

## 👤 Autor

Cristian Velásquez — [github.com/cristian102711](https://github.com/cristian102711)
