# Frontend Dockerfile — CafeBoard
# Multi-stage build: builder (Node) + runtime (nginx)

# ──────────────────────────────────────────────
# Stage 1: Builder — сборка React-приложения
# ──────────────────────────────────────────────
FROM node:20-alpine AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы зависимостей (кэширование слоёв)
COPY package.json package-lock.json* ./

# Устанавливаем зависимости
RUN npm ci

# Копируем исходный код
COPY . .

# Собираем приложение
RUN npm run build

# ──────────────────────────────────────────────
# Stage 2: Development — Vite dev-сервер с hot-reload
# ──────────────────────────────────────────────
FROM node:20-alpine AS development

WORKDIR /app

# Копируем зависимости
COPY package.json package-lock.json* ./
RUN npm ci

# Копируем исходный код
COPY . .

# Открываем порт Vite
EXPOSE 5173

# Запускаем dev-сервер с hot-reload
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# ──────────────────────────────────────────────
# Stage 3: Production — nginx для раздачи статики
# ──────────────────────────────────────────────
FROM nginx:alpine AS production

# Устанавливаем конфигурацию nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Копируем собранное приложение из builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Открываем порт
EXPOSE 80

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"]
