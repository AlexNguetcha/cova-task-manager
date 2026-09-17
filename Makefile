# ─────────────────────────────────────────────
# Cova Task Manager - Makefile
# Commandes simplifiées pour le développement
# ─────────────────────────────────────────────

.DEFAULT_GOAL := help

.PHONY: help build up down restart logs clean \
        build-backend build-frontend \
        test-backend test-frontend lint-frontend \
        dev-backend dev-frontend \
        init-db shell-backend shell-frontend shell-mysql

# ─────────────────────────────────────────────
# 🐳 Docker
# ─────────────────────────────────────────────

build: ## Build all Docker images
	docker compose build

up: ## Start all services (detached)
	docker compose up -d
	@echo "✅ Backend:  http://localhost:8082"
	@echo "✅ Swagger:  http://localhost:8082/swagger-ui.html"
	@echo "✅ MySQL:    localhost:3307"
	@echo ""
	@echo "⚠️  Frontend: run 'make dev-frontend' for hot reload"

down: ## Stop all services
	docker compose down

restart: down up ## Restart all services

logs: ## Tail logs from all services
	docker compose logs -f

clean: ## Stop and remove volumes (reset database)
	docker compose down -v

ps: ## List running services
	docker compose ps

# ─────────────────────────────────────────────
# 📦 Backend
# ─────────────────────────────────────────────

build-backend: ## Build backend with Maven
	cd backend && ./mvnw clean package -DskipTests

dev-backend: ## Run backend in dev mode
	cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

test-backend: ## Run backend tests
	cd backend && ./mvnw verify

shell-backend: ## Open a shell in the backend container
	docker compose exec backend sh

# ─────────────────────────────────────────────
# ⚛️ Frontend
# ─────────────────────────────────────────────

build-frontend: ## Build frontend for production
	cd frontend && npm run build

dev-frontend: ## Run frontend with hot reload (Vite) — http://localhost:5173
	cd frontend && npx vite

lint-frontend: ## Lint frontend code
	cd frontend && npm run lint

test-frontend: ## Run frontend tests
	cd frontend && npm test

shell-frontend: ## Open a shell in the frontend container
	docker compose exec frontend sh

# ─────────────────────────────────────────────
# 🗄️ Database
# ─────────────────────────────────────────────

init-db: ## Initialize database schema
	@echo "Creating database (if not exists)..."
	docker compose exec mysql mysql -u root -proot_pass -e \
		"CREATE DATABASE IF NOT EXISTS cova_tasks; \
		 CREATE USER IF NOT EXISTS 'cova_user'@'%' IDENTIFIED BY 'cova_pass'; \
		 GRANT ALL PRIVILEGES ON cova_tasks.* TO 'cova_user'@'%'; \
		 FLUSH PRIVILEGES;"

shell-mysql: ## Open MySQL CLI
	docker compose exec mysql mysql -u cova_user -pcova_pass cova_tasks

# ─────────────────────────────────────────────
# 🔧 Utils
# ─────────────────────────────────────────────

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'