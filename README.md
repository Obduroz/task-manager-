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
```
**Вариант 2**
### 1. Клонировать репозиторий
```bash
git clone https://github.com/your-username/task-manager.git
```
# 2. Создать базу данных
```bash
psql -U postgres -c "CREATE DATABASE task_manager;"
```
# 3. Выполнить миграции
```bash
psql -U postgres -d task_manager -f schema.sql
psql -U postgres -d task_manager -f seed.sql
psql -U postgres -d task_manager -f indexes.sql
```
# 4. Запустить приложение
```bash
python app.py
