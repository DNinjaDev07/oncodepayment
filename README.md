# OnCode Payment Recorder

OnCode Payment Recorder is a DEMO full-stack CRUD app for payment records. It will use DevOps practices for the entire flow.

## Stack

- Backend: Java 17, Spring Boot, Spring Data JPA
- Database: PostgreSQL in Docker Compose
- Frontend: HTML, CSS, JavaScript, Nginx
- Containers: Docker, Docker Compose

## Run Locally with Docker

1. Start:
```bash
docker compose up --build
```

2. Open:
- Frontend: `http://localhost`
- Backend API: `http://localhost:8098/oncode/getpayments`

3. Stop:
```bash
docker compose down
```

4. Stop and remove database volume:
```bash
docker compose down -v
```

## API Endpoints

Base path: `/oncode`

- `GET /getpayments`
- `GET /getpayment/{id}`
- `POST /addpayment`
- `PUT /updatepayment/{id}`
- `DELETE /deletepayment/{id}`

Sample payload for create or update:

```json
{
  "amount": 42.42,
  "fromAccount": 1111111,
  "toAccount": 2222222
}
```

## Configuration

Backend reads environment values from `src/main/resources/application.properties`.

Key values:
- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `DB_DRIVER`
- `JPA_DDL_AUTO`
- `JPA_DIALECT`
- `CORS_ORIGINS`

Frontend proxy target:
- `API_UPSTREAM` in `docker-compose.yml`
- Current local value: `backend:8098`

## Repo Notes

- Current local orchestration file is `docker-compose.yml`.

## TO-DO List
Tidy up DevOps components (helm charts, terraform and argocd).
