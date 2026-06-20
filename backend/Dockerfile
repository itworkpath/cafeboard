# Backend Dockerfile — CafeBoard
# Multi-stage build: builder + runtime

# ──────────────────────────────────────────────
# Stage 1: Builder — установка зависимостей
# ──────────────────────────────────────────────
FROM python:3.12-slim AS builder

# Устанавливаем системные зависимости для сборки
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Создаём рабочую директорию
WORKDIR /app

# Копируем файл зависимостей (кэширование слоёв)
COPY requirements.txt .

# Устанавливаем зависимости в виртуальное окружение
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ──────────────────────────────────────────────
# Stage 2: Runtime — финальный образ
# ──────────────────────────────────────────────
FROM python:3.12-slim AS runtime

# Устанавливаем только необходимые runtime-зависимости
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Создаём непривилегированного пользователя
RUN groupadd --gid 1000 appuser && \
    useradd --uid 1000 --gid appuser --create-home appuser

# Копируем виртуальное окружение из builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем исходный код
COPY --chown=appuser:appuser src/ ./src/

# Переключаемся на непривилегированного пользователя
USER appuser

# Открываем порт
EXPOSE 8000

# Запуск FastAPI через uvicorn с hot-reload
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
