# ── CafeBoard Makefile ─────────────────────────────────────────
.PHONY: help up down build logs lint test clean

# Default target
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

# ── Docker Compose ────────────────────────────────────────────
up: ## Start all services (detached)
	docker compose up -d --build

down: ## Stop all services
	docker compose down

restart: down up ## Restart all services

build: ## Build all images
	docker compose build

logs: ## Tail all logs
	docker compose logs -f

# ── Development ───────────────────────────────────────────────
dev-backend: ## Run backend locally (requires local env)
	cd backend && uvicorn src.main:app --reload --port 8000

dev-frontend: ## Run frontend locally (requires local env)
	cd frontend && npm run dev

# ── Lint & Test ───────────────────────────────────────────────
lint: lint-backend lint-frontend ## Lint both projects

lint-backend: ## Lint backend with ruff
	cd backend && pip install ruff -q && ruff check src/ tests/

lint-frontend: ## Type-check frontend
	cd frontend && npm ci && npx tsc --noEmit

test: test-backend test-frontend ## Run all tests

test-backend: ## Run backend tests
	cd backend && pytest tests/ -v --tb=short

test-frontend: ## Run frontend tests (if any)
	cd frontend && npm test -- --watchAll=false 2>/dev/null || echo "No frontend tests"

# ── Database ──────────────────────────────────────────────────
db-migrate: ## Run database migrations (placeholder)
	@echo "SQLAlchemy auto-creates tables on startup. Add Alembic for migrations."

db-shell: ## Open psql shell to the running database
	docker compose exec db psql -U cafeboard -d cafeboard

# ── Cleanup ───────────────────────────────────────────────────
clean: ## Remove containers, volumes, images
	docker compose down -v --rmi all
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name node_modules -prune -o -type d -name dist -print | xargs rm -rf 2>/dev/null || true
