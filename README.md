# Task Manager Database Project

Система управления задачами с возможностью создавать проекты, назначать задачи и отслеживать статус.

## Технологии

- **PostgreSQL** — реляционная база данных
- **Python 3** — язык программирования
- **psycopg2** — драйвер для подключения к PostgreSQL
- **prettytable** — для красивого вывода таблиц в консоли

## Установка и запуск

### 1. Установка PostgreSQL

**Вариант 1: Docker (рекомендуется)**
```bash
docker run --name postgres -e POSTGRES_PASSWORD=123 -e POSTGRES_DB=task_manager -d -p 5432:5432 postgres
