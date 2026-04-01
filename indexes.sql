-- indexes.sql
-- Индексы для ускорения работы запросов

-- Базовые индексы на внешние ключи (ускоряют JOIN)
CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_assignee_id ON tasks(assignee_id);
CREATE INDEX IF NOT EXISTS idx_tasks_created_by_id ON tasks(created_by_id);
CREATE INDEX IF NOT EXISTS idx_project_members_project_id ON project_members(project_id);
CREATE INDEX IF NOT EXISTS idx_project_members_user_id ON project_members(user_id);

-- Индекс для фильтрации по статусу (часто используем WHERE status)
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);

-- Составной индекс для частых запросов (статус + дедлайн)
CREATE INDEX IF NOT EXISTS idx_tasks_status_due_date ON tasks(status, due_date);

-- Индекс для поиска просроченных задач
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date) 
WHERE status != 'done';

-- Индекс для сортировки по дате создания
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at);

-- Индекс для поиска по приоритету
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);

-- Индекс для поиска пользователей по имени
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Индекс для поиска проектов по владельцу
CREATE INDEX IF NOT EXISTS idx_projects_owner_id ON projects(owner_id);

-- Вывод информации о созданных индексах
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;