# 📋 Cova Task Manager

> **Application complète de gestion de tâches** — Backend Spring Boot, Frontend React + Vite + TypeScript, Mobile Flutter.
>
> Déploiement automatisé sur Google Cloud Platform via Docker & GitHub Actions.

---

## 📑 Table des Matières

- [Architecture](#-architecture)
- [Stack Technique](#-stack-technique)
- [Structure du Projet](#-structure-du-projet)
- [Prérequis](#-prérequis)
- [Installation & Exécution Locale](#-installation--exécution-locale)
- [Docker (Recommandé)](#-docker-recommandé)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Déploiement GCP](#-déploiement-gcp)
- [API Endpoints](#-api-endpoints)
- [Captures d'Écran](#-captures-décran)

---

## 🏗️ Architecture

```
                    ┌─────────────┐
                    │   MySQL 8    │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │  Spring Boot API (:8080) │
              │  JWT Auth + CRUD Tasks   │
              └────────────┬────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                   │
   ┌────┴─────┐     ┌─────┴─────┐      ┌──────┴──────┐
   │  React    │     │   Nginx    │      │   Flutter    │
   │   + Vite  │     │  (Proxy)   │      │   Mobile     │
   └──────────┘     └───────────┘      └─────────────┘
        Web                Web              Mobile
                      (Production)
```

### Flux de données :
1. L'utilisateur s'authentifie → reçoit un **JWT**
2. Le token est stocké (localStorage web / secure storage mobile)
3. Chaque requête API inclut le JWT dans le header `Authorization: Bearer <token>`
4. Le backend valide le token via Spring Security Filter Chain
5. Les réponses sont filtrées par utilisateur (chaque utilisateur ne voit que ses tâches)

---

## 🛠️ Stack Technique

| Domaine | Technologie | Version |
|---------|-------------|---------|
| **Backend** | Java Spring Boot | 3.2.x |
| | Spring Data JPA | 3.2.x |
| | Spring Security + JWT | 3.2.x |
| | MySQL | 8.0 |
| | OpenAPI / Swagger | 2.5.x |
| **Frontend Web** | React | 18.x |
| | Vite | 5.x |
| | TypeScript | 5.x |
| | Shadcn UI + Tailwind CSS | Latest |
| | TanStack React Query | 5.x |
| **Mobile** | Flutter + Dart | 3.x |
| **Infrastructure** | Docker & Docker Compose | Latest |
| | GitHub Actions | CI/CD |
| | Google Cloud Run | Serverless |
| | Terraform (optionnel) | IaC |

---

## 📂 Structure du Projet

```
cova-task-manager/
├── backend/                         # 🖥️ Spring Boot API
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/covataskmanager/
│       │   │   ├── config/          # Configuration (CORS, Security, Swagger)
│       │   │   ├── controller/      # REST Controllers
│       │   │   ├── dto/             # Data Transfer Objects
│       │   │   ├── entity/          # JPA Entities
│       │   │   ├── exception/       # Global Exception Handler
│       │   │   ├── repository/      # Spring Data Repositories
│       │   │   ├── security/        # JWT & Security Filters
│       │   │   ├── service/         # Business Logic
│       │   │   └── CovaTaskManagerApplication.java
│       │   └── resources/
│       │       ├── application.yml
│       │       └── application-docker.yml
│       └── test/
│
├── frontend/                        # ⚛️ React + Vite + TypeScript
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   ├── tailwind.config.ts
│   └── src/
│       ├── components/ui/           # Shadcn UI Components
│       ├── contexts/                # AuthContext (JWT)
│       ├── hooks/                   # useAuth, useTasks (React Query)
│       ├── lib/                     # API client (Axios), utils
│       ├── pages/                   # Login, Register, Dashboard
│       └── types/                   # TypeScript interfaces
│
├── mobile/                          # 📱 Flutter App (Bonus)
│   └── lib/
│       ├── models/
│       ├── screens/
│       ├── services/
│       └── widgets/
│
├── docker/                          # 🐳 Docker Configuration
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   └── nginx/default.conf
│
├── deploy/                          # ☁️ Déploiement
│   ├── cloudbuild.yaml              # GCP Cloud Build
│   └── terraform/                   # Infrastructure as Code
│       ├── main.tf
│       └── variables.tf
│
├── .github/workflows/               # 🤖 GitHub Actions CI/CD
│   └── ci-cd.yml
│
├── docker-compose.yml               # Orchestration locale
├── .env.example                     # Variables d'environnement
├── Makefile                         # Commandes simplifiées
└── README.md
```

---

## ✅ Prérequis

- **Java 17+** (JDK)
- **Node.js 20+** & npm
- **Docker** & Docker Compose (recommandé)
- **MySQL 8.0** (si exécution native)
- **Compte GCP** (pour déploiement)
- **Flutter 3.x** (pour le mobile)

---

## 🚀 Installation & Exécution Locale

### 1. Cloner le projet

```bash
git clone https://github.com/AlexNguetcha/cova-task-manager.git
cd cova-task-manager
```

### 2. Backend (Spring Boot)

```bash
# Avec Maven wrapper
cd backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Ou avec Maven global
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

Le backend démarre sur `http://localhost:8080`.
Swagger UI : `http://localhost:8080/swagger-ui.html`

### 3. Frontend (React + Vite)

```bash
cd frontend
npm install
npm run dev
```

Le frontend démarre sur `http://localhost:5173`.

---

## 🐳 Docker (Recommandé)

La façon la plus simple de tout lancer localement :

```bash
# Lancer tous les services (MySQL + Backend + Frontend)
docker compose up --build

# Lancer en arrière-plan
docker compose up -d

# Voir les logs
docker compose logs -f

# Arrêter
docker compose down

# Arrêter et supprimer les volumes (reset DB)
docker compose down -v
```

**Services disponibles :**

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost | Interface utilisateur |
| Backend API | http://localhost:8080 | API REST |
| Swagger UI | http://localhost:8080/swagger-ui.html | Documentation API |
| MySQL | localhost:3307 | Base de données |

### Commandes Make :

```bash
make build          # Build tous les services
make up             # Démarrage complet
make down           # Arrêt complet
make logs           # Logs en temps réel
make test-backend   # Tests backend
make lint-frontend  # Lint frontend
```

---

## 🤖 CI/CD Pipeline

Le pipeline GitHub Actions s'exécute automatiquement sur `push` vers `main` et `develop`.

### Pipeline stages :

```
┌──────────┐    ┌──────────────┐    ┌───────────────┐    ┌──────────┐
│  Backend  │    │   Frontend    │    │   Docker       │    │  Deploy   │
│  Tests    │ →  │   Lint/Build  │ →  │   Build/Push   │ →  │  CloudRun │
└──────────┘    └──────────────┘    └───────────────┘    └──────────┘
```

🔒 **Secrets GitHub requis :**

| Secret | Description |
|--------|-------------|
| `GCP_PROJECT_ID` | ID du projet GCP |
| `GCP_SA_KEY` | JSON de la Service Account GCP |
| `cova-db-user` | Secret Manager: DB username |
| `cova-db-password` | Secret Manager: DB password |
| `jwt-secret` | Secret Manager: JWT secret |

---

## ☁️ Déploiement GCP

### Prérequis GCP

```bash
# 1. Créer un projet GCP
gcloud projects create cova-task-manager

# 2. Activer les services requis
gcloud services enable \
    cloudrun.googleapis.com \
    sqladmin.googleapis.com \
    secretmanager.googleapis.com \
    artifactregistry.googleapis.com

# 3. Créer le repository Artifact Registry
gcloud artifacts repositories create cova-task-manager \
    --repository-format=docker \
    --location=europe-west1

# 4. Créer une instance Cloud SQL MySQL
gcloud sql instances create cova-mysql \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=europe-west1
```

### Déploiement manuel

```bash
# Backend
gcloud run deploy cova-backend \
    --source=. \
    --region=europe-west1 \
    --allow-unauthenticated

# Frontend
gcloud run deploy cova-frontend \
    --source=./frontend \
    --region=europe-west1 \
    --allow-unauthenticated
```

### Terraform (Infrastructure as Code)

```bash
cd deploy/terraform
terraform init
terraform plan
terraform apply
```

---

## 📡 API Endpoints

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| **POST** | `/api/auth/register` | Inscription | ❌ |
| **POST** | `/api/auth/login` | Connexion → JWT | ❌ |
| **POST** | `/api/auth/refresh` | Rafraîchir le token | ❌ |
| **GET** | `/api/tasks` | Liste des tâches | ✅ |
| **POST** | `/api/tasks` | Créer une tâche | ✅ |
| **PUT** | `/api/tasks/{id}` | Modifier une tâche | ✅ |
| **DELETE** | `/api/tasks/{id}` | Supprimer une tâche | ✅ |

**Filtres pour `GET /api/tasks` :**
- `?status=TODO|IN_PROGRESS|COMPLETED`
- `?search=keyword` (recherche dans le titre)
- `?page=0&size=10` (pagination)

Documentation interactive Swagger : [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)

---

## 📸 Captures d'Écran

<!-- À remplacer par des screenshots réels lors de la soumission -->

| Page | Aperçu |
|------|--------|
| Login | ![](screenshots/login.png) |
| Dashboard | ![](screenshots/dashboard.png) |
| Mobile | ![](screenshots/mobile.png) |

---

## 🧪 Tests

```bash
# Backend (JUnit + Mockito + Integration)
cd backend && mvn verify

# Frontend
cd frontend && npm test
```

---

## 👨‍💻 Auteur

**Alex Nguetcha** — [GitHub](https://github.com/AlexNguetcha)

---

## 📄 Licence

Ce projet a été réalisé dans le cadre d'un test de recrutement.
Toute réutilisation est libre.
