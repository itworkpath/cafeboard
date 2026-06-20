# Makefile для CafeBoard — команды управления инфраструктурой

# ──────────────────────────────────────────────
# Переменные
# ──────────────────────────────────────────────
COMPOSE = docker compose -f docker-compose.yml
BACKEND = cafeboard-backend
FRONTEND = cafeboard-frontend

# ──────────────────────────────────────────────
# Основные команды
# ──────────────────────────────────────────────

# Запуск всех сервисов с пересборкой
up:
	$(COMPOSE) up --build -d
	@echo "✅ CafeBoard запущен: http://localhost:5173"

# Остановка всех сервисов
down:
	$(COMPOSE) down
	@echo "🛑 CafeBoard остановлен"

# Остановка с удалением томов (сброс БД)
down-clean:
	$(COMPOSE) down -v
	@echo "🗑️  CafeBoard остановлен, тома удалены"

# Перезапуск сервисов
restart: down up

# ──────────────────────────────────────────────
# Логи
# ──────────────────────────────────────────────

# Просмотр логов всех сервисов (follow)
logs:
	$(COMPOSE) logs -f

# Логи конкретного сервиса
logs-backend:
	$(COMPOSE) logs -f $(BACKEND)

logs-frontend:
	$(COMPOSE) logs -f $(FRONTEND)

logs-db:
	$(COMPOSE) logs -f cafeboard-db

# ──────────────────────────────────────────────
# Тесты
# ──────────────────────────────────────────────

# Запуск всех тестов
test:
	@echo "🧪 Запуск тестов бэкенда..."
	$(COMPOSE) exec $(BACKEND) pytest --tb=short -v
	@echo "🧪 Запуск тестов фронтенда..."
	$(COMPOSE) exec $(FRONTEND) npm test
	@echo "✅ Все тесты пройдены"

# Тесты бэкенда
test-backend:
	$(COMPOSE) exec $(BACKEND) pytest --tb=short -v

# Тесты фронтенда
test-frontend:
	$(COMPOSE) exec $(FRONTEND) npm test

# ──────────────────────────────────────────────
# Линтинг
# ──────────────────────────────────────────────

# Линтинг бэкенда (ruff) и фронтенда (eslint)
lint:
	@echo "🔍 Линтинг бэкенда..."
	$(COMPOSE) exec $(BACKEND) ruff check src/
	@echo "🔍 Линтинг фронтенда..."
	$(COMPOSE) exec $(FRONTEND) npx eslint src/
	@echo "✅ Линтинг завершён"

# Линтинг только бэкенда
lint-backend:
	$(COMPOSE) exec $(BACKEND) ruff check src/

# Линтинг только фронтенда
lint-frontend:
	$(COMPOSE) exec $(FRONTEND) npx eslint src/

# ──────────────────────────────────────────────
# Утилиты
# ──────────────────────────────────────────────

# Статус сервисов
status:
	$(COMPOSE) ps

# Выполнение команды в контейнере бэкенда
exec-backend:
	$(COMPOSE) exec $(BACKEND) $(cmd)

# Выполнение команды в контейнере фронтенда
exec-frontend:
	$(COMPOSE) exec $(FRONTEND) $(cmd)

# Очистка Docker (не используемые образы, контейнеры, сети)
clean:
	docker system prune -f
	@echo "🧹 Docker очищен"

# Справка
help:
	@echo "Доступные команды:"
	@echo "  make up          — Запуск всех сервисов"
	@echo "  make down        — Остановка всех сервисов"
	@echo "  make down-clean  — Остановка с удалением томов"
	@echo "  make restart     — Перезапуск"
	@echo "  make logs        — Логи всех сервисов"
	@echo "  make test        — Все тесты"
	@echo "  make lint        — Линтинг бэкенда и фронтенда"
	@echo "  make status      — Статус контейнеров"
	@echo "  make clean       — Очистка Docker"
	@echo "  make help        — Эта справка"

.PHONY: up down down-clean restart logs logs-backend logs-frontend logs-db test test-backend test-frontend lint lint-backend lint-frontend status exec-backend exec-frontend clean help
