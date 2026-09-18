# Cova Task Manager

Task Manager — Spring Boot, React + Vite, Flutter.  
Déploiement GCP via Docker & GitHub Actions.

---

## Stack

| Domaine | Technologie |
|---------|-------------|
| Backend | Java Spring Boot, Spring Data JPA, Spring Security + JWT, MySQL |
| Frontend | React + Vite + TypeScript, Shadcn UI + Tailwind, TanStack Query |
| Mobile | Flutter + Dart |
| CI/CD | GitHub Actions, Docker, Google Cloud Run, Terraform |

---

## Démarrer rapidement

```bash
git clone https://github.com/AlexNguetcha/cova-task-manager.git
cd cova-task-manager

# Tout avec Docker
docker compose up --build
```

| Service | URL |
|---------|-----|
| Frontend | http://localhost |
| API | http://localhost:8080 |
| Swagger | http://localhost:8080/swagger-ui.html |
| MySQL | localhost:3307 |

**Demo :** `demo@cova.africa` / `demo1234`

---

## Commandes

```bash
make up       # docker compose up -d
make down     # docker compose down
make logs     # docker compose logs -f
make clean    # down + delete volumes
```

---

## API

| Méthode | Endpoint | Auth |
|---------|----------|------|
| POST | `/api/auth/register` | ❌ |
| POST | `/api/auth/login` | ❌ |
| POST | `/api/auth/refresh` | ❌ |
| GET | `/api/tasks?status=&search=&page=&size=` | ✅ |
| POST | `/api/tasks` | ✅ |
| PUT | `/api/tasks/{id}` | ✅ |
| DELETE | `/api/tasks/{id}` | ✅ |

---

## Déploiement GCP

```bash
# Infra
cd deploy/terraform && terraform apply

# Cloud Build (alternative à GitHub Actions)
gcloud builds submit
```

**Secrets GitHub requis :** `GCP_PROJECT_ID`, `GCP_SA_KEY`, `cova-db-user`, `cova-db-password`, `jwt-secret`.

---

## Tests

```bash
cd backend && mvn verify    # JUnit + Mockito
cd frontend && npm test      # Vitest
```

---

## Auteur

**Alex Nguetcha** — [GitHub](https://github.com/AlexNguetcha)
