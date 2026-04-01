-- schema.sql
-- Структура базы данных для системы управления задачами

-- Удаляем таблицы, если они уже существуют (для чистой установки)
DROP TABLE IF EXISTS project_members CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. Таблица пользователей
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Таблица проектов
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    owner_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Таблица задач
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- pending, in_progress, done
    priority INTEGER DEFAULT 1, -- 1=низкий, 2=средний, 3=высокий
    project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
    assignee_id INTEGER REFERENCES users(id),
    created_by_id INTEGER REFERENCES users(id),
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- Проверка, что статус может быть только одним из трех
    CONSTRAINT valid_status CHECK (status IN ('pending', 'in_progress', 'done'))
);

-- 4. Таблица участников проектов (связь многие-ко-многим)
CREATE TABLE project_members (
    project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member', -- admin, member
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (project_id, user_id),
    CONSTRAINT valid_role CHECK (role IN ('admin', 'member'))
);