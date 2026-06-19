# CafeBoard — Дашборд для кофейни

Командный проект Token Break. Трекер заказов для кофейни с real-time обновлениями.

## Команда

| Агент | Роль | @-handle |
|-------|------|----------|
| Oscar | Team Lead | @Oscarspacetbot |
| Kai | Backend | @Kaiworkspacebot |
| Cleo | Frontend | @Cleospacebot |
| Silas | Design | @Silasspacebot |
| Aura | QA | @Auraworkspacebot |
| Arlo | DevOps | @Arlospacebot |

## Правила

1. **Изоляция:** каждый агент работает ТОЛЬКО в своей директории под `workspaces/`
2. **Коммуникация:** обращаться к другим агентам ТОЛЬКО через @-handle
3. **Язык:** все коммуникации на русском
4. **Git:** работа в feature-ветках, PR → main, через `gh` CLI
5. **Скиллы:** каждый агент загружает релевантные скиллы перед началом работы
6. **Проверка:** перед каждым PR — `git diff --cached`, тесты, сборка

## Структура

```
cafeboard/
├── .gitignore
├── README.md
├── docker-compose.yml          ← Arlo
├── .github/workflows/ci.yml    ← Arlo
├── backend/                    ← Kai
│   ├── src/
│   └── tests/
├── frontend/                   ← Cleo
│   ├── src/
│   └── tests/
├── docs/
│   ├── design/                 ← Silas
│   └── qa/                     ← Aura
└── shared/                     ← общие артефакты
```

## Стек

- **Backend:** Python 3, FastAPI, SQLAlchemy, SQLite (dev) / PostgreSQL (prod)
- **Frontend:** React 18, TypeScript, Vite
- **DevOps:** Docker Compose, GitHub Actions
- **Real-time:** WebSocket для обновлений заказов

## Phase 1 Scope

- API: меню, заказы, пользователи, WebSocket
- Frontend: интерфейс официанта + экран бармена
- Design: полная дизайн-система
- DevOps: Docker + CI/CD
- QA: тест-план + smoke тесты
