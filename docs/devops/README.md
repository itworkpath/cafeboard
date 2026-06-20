# DevOps — CafeBoard

Документация по инфраструктуре, CI/CD и развёртыванию.

## Архитектура

```
┌─────────────────────────────────────────────────┐
│                   Docker Compose                 │
│                                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐   │
│  │ Frontend │    │ Backend  │    │    DB    │   │
│  │ React    │───▶│ FastAPI  │───▶│ Postgres │   │
│  │ Vite     │    │ Python   │    │ 16       │   │
│  │ :5173    │    │ :8000    │    │ :5432    │   │
│  └──────────┘    └──────────┘    └──────────┘   │
│       │               │               │          │
│       └───────────────┴───────────────┘          │
│                 cafeboard-network                │
└─────────────────────────────────────────────────┘
```

### Сервисы

| Сервис | Порт | Описание |
|--------|------|----------|
| `frontend` | 5173 | React-приложение на Vite (dev) или nginx (prod) |
| `backend` | 8000 | FastAPI-сервер на Python 3.12 |
| `db` | 5432 | PostgreSQL 16 |

### Сеть

Все сервисы работают в изолированной сети `cafeboard-network` (bridge).

## Локальный запуск

### Предварительные требования

- Docker Engine 24+
- Docker Compose v2
- Make (опционально)

### Быстрый старт

```bash
# 1. Клонировать репозиторий
git clone git@github.com:itworkpath/cafeboard.git
cd cafeboard

# 2. Создать .env из шаблона
cp .env.example .env

# 3. Запустить все сервисы
make up

# Или напрямую через Docker Compose:
docker compose up --build -d
```

### Проверка работоспособности

```bash
# Статус контейнеров
make status

# Логи
make logs

# Healthcheck бэкенда
curl http://localhost:8000/health

# Фронтенд
curl http://localhost:5173
```

### Остановка

```bash
make down          # Остановить
make down-clean    # Остановить + удалить данные БД
```

## Переменные окружения

Скопируйте `.env.example` в `.env` и настройте:

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `DATABASE_URL` | `sqlite:///./data/cafeboard.db` | URL базы данных |
| `POSTGRES_DB` | `cafeboard` | Имя БД PostgreSQL |
| `POSTGRES_USER` | `cafeboard` | Пользователь БД |
| `POSTGRES_PASSWORD` | `cafeboard-secret` | Пароль БД |
| `SECRET_KEY` | `dev-secret-key-change-in-production` | Секретный ключ JWT |
| `CORS_ORIGINS` | `http://localhost:5173` | Разрешённые CORS-источники |
| `VITE_API_URL` | `http://localhost:8000` | URL бэкенда для фронтенда |

### Переключение на PostgreSQL

В `.env`:

```env
DATABASE_URL=postgresql://cafeboard:cafeboard-secret@db:5432/cafeboard
```

## CI/CD Pipeline

### Схема

```
Push/PR → main
    │
    ├── backend-test ─── Python 3.12 → pip install → pytest
    │
    ├── frontend-test ── Node 20 → npm ci → npm run build
    │
    └── build ────────── (зависит от backend-test + frontend-test)
                        → docker build backend
                        → docker build frontend
```

### Этапы

1. **backend-test** — установка зависимостей Python 3.12, запуск pytest
2. **frontend-test** — установка зависимостей Node 20, сборка проекта
3. **build** — Docker-сборка образов backend и frontend (только после успешных тестов)

### Кэширование

- pip-кэш через `actions/setup-python` с `cache: "pip"`
- npm-кэш через `actions/setup-node` с `cache: "npm"`
- Docker-кэш через `type=gha` (GitHub Actions Cache)

## Команды Makefile

| Команда | Описание |
|---------|----------|
| `make up` | Запуск всех сервисов с пересборкой |
| `make down` | Остановка всех сервисов |
| `make down-clean` | Остановка + удаление томов |
| `make restart` | Перезапуск |
| `make logs` | Логи всех сервисов |
| `make test` | Тесты бэкенда и фронтенда |
| `make lint` | Линтинг (ruff + eslint) |
| `make status` | Статус контейнеров |
| `make clean` | Очистка Docker |
| `make help` | Справка по командам |

## Структура файлов

```
cafeboard/
├── docker-compose.yml          # Конфигурация Docker Compose
├── Makefile                    # Команды управления
├── .env.example                # Шаблон переменных окружения
├── backend/
│   └── Dockerfile              # Multi-stage сборка бэкенда
├── frontend/
│   ├── Dockerfile              # Multi-stage сборка фронтенда
│   └── nginx.conf              # Конфигурация nginx
├── .github/
│   └── workflows/
│       └── ci.yml              # CI/CD Pipeline
└── docs/
    └── devops/
        └── README.md           # Этот файл
```
