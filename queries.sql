-- queries.sql
-- Коллекция сложных запросов для демонстрации навыков

-- 1. Количество задач по статусам для каждого проекта
SELECT 
    p.name AS project_name,
    COUNT(CASE WHEN t.status = 'pending' THEN 1 END) AS pending_tasks,
    COUNT(CASE WHEN t.status = 'in_progress' THEN 1 END) AS in_progress_tasks,
    COUNT(CASE WHEN t.status = 'done' THEN 1 END) AS done_tasks,
    COUNT(t.id) AS total_tasks
FROM projects p
LEFT JOIN tasks t ON p.id = t.project_id
GROUP BY p.id, p.name
ORDER BY total_tasks DESC;

-- 2. Самые занятые пользователи (количество назначенных задач)
SELECT 
    u.username,
    u.email,
    COUNT(t.id) AS total_assigned,
    COUNT(CASE WHEN t.status != 'done' THEN 1 END) AS active_tasks,
    ROUND(AVG(CASE WHEN t.status = 'done' THEN EXTRACT(EPOCH FROM (t.completed_at - t.created_at))/3600 ELSE NULL END), 2) AS avg_hours_to_complete
FROM users u
LEFT JOIN tasks t ON u.id = t.assignee_id
GROUP BY u.id
ORDER BY active_tasks DESC;

-- 3. Просроченные задачи (дедлайн прошел, а задача не выполнена)
SELECT 
    t.id,
    t.title,
    p.name AS project_name,
    u.username AS assigned_to,
    t.due_date,
    CURRENT_DATE - t.due_date AS days_overdue,
    t.priority,
    CASE t.priority
        WHEN 1 THEN 'Низкий'
        WHEN 2 THEN 'Средний'
        WHEN 3 THEN 'Высокий'
    END AS priority_name
FROM tasks t
JOIN projects p ON t.project_id = p.id
LEFT JOIN users u ON t.assignee_id = u.id
WHERE t.status != 'done' 
  AND t.due_date < CURRENT_DATE
ORDER BY days_overdue DESC, t.priority DESC;

-- 4. Статистика по проектам: сколько участников и задач
SELECT 
    p.name AS project_name,
    COUNT(DISTINCT pm.user_id) AS members_count,
    COUNT(t.id) AS tasks_count,
    COUNT(CASE WHEN t.status = 'done' THEN 1 END) AS completed_count,
    ROUND(COUNT(CASE WHEN t.status = 'done' THEN 1 END) * 100.0 / NULLIF(COUNT(t.id), 0), 2) AS completion_percentage
FROM projects p
LEFT JOIN project_members pm ON p.id = pm.project_id
LEFT JOIN tasks t ON p.id = t.project_id
GROUP BY p.id
ORDER BY completion_percentage DESC;

-- 5. Задачи, над которыми работает пользователь (с информацией о проекте и создателе)
-- Это запрос с JOIN трех таблиц
SELECT 
    t.title AS task,
    p.name AS project,
    u_assignee.username AS assigned_to,
    u_creator.username AS created_by,
    t.status,
    t.due_date
FROM tasks t
JOIN projects p ON t.project_id = p.id
JOIN users u_assignee ON t.assignee_id = u_assignee.id
JOIN users u_creator ON t.created_by_id = u_creator.id
WHERE t.status != 'done'
ORDER BY t.due_date NULLS LAST;

-- 6. Среднее время выполнения задачи по приоритетам
SELECT 
    CASE t.priority
        WHEN 1 THEN 'Низкий'
        WHEN 2 THEN 'Средний'
        WHEN 3 THEN 'Высокий'
    END AS priority,
    COUNT(t.id) AS completed_tasks,
    ROUND(AVG(EXTRACT(EPOCH FROM (t.completed_at - t.created_at))/3600), 2) AS avg_hours,
    MIN(EXTRACT(EPOCH FROM (t.completed_at - t.created_at))/3600) AS min_hours,
    MAX(EXTRACT(EPOCH FROM (t.completed_at - t.created_at))/3600) AS max_hours
FROM tasks t
WHERE t.status = 'done' AND t.completed_at IS NOT NULL
GROUP BY t.priority
ORDER BY t.priority DESC;

-- 7. Пользователи, которые владеют проектами, но не имеют в них задач
SELECT 
    u.username,
    u.email,
    p.name AS project_name
FROM users u
JOIN projects p ON u.id = p.owner_id
LEFT JOIN tasks t ON p.id = t.project_id
WHERE t.id IS NULL;

-- 8. Прогресс по проектам (сколько задач выполнено от общего числа)
SELECT 
    p.name,
    COUNT(t.id) AS total,
    SUM(CASE WHEN t.status = 'done' THEN 1 ELSE 0 END) AS completed,
    ROUND(100.0 * SUM(CASE WHEN t.status = 'done' THEN 1 ELSE 0 END) / COUNT(t.id), 2) AS percent
FROM projects p
JOIN tasks t ON p.id = t.project_id
GROUP BY p.id
HAVING COUNT(t.id) > 0
ORDER BY percent DESC;