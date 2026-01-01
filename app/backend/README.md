# Spring Boot Backend

Simple REST API used by the frontend and Kubernetes health checks.

## Endpoints
- `GET /api/hello` returns a greeting
- `GET /api/` returns a basic status payload

## Run locally
```bash
mvn clean package
mvn spring-boot:run
```

The server listens on port 8080 by default.