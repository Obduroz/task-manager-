# app.py
# Простое приложение для работы с базой данных

import psycopg2
from psycopg2 import sql
from prettytable import PrettyTable
from datetime import datetime

# Конфигурация подключения к БД
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'task_manager',
    'user': 'postgres',
    'password': '123'  # Замени на свой пароль
}

class TaskManager:
    def __init__(self):
        """Подключение к базе данных"""
        try:
            self.conn = psycopg2.connect(**DB_CONFIG)
            self.cursor = self.conn.cursor()
            print("✅ Подключение к базе данных успешно!")
        except Exception as e:
            print(f"❌ Ошибка подключения: {e}")
            raise
    
    def close(self):
        """Закрытие соединения"""
        self.cursor.close()
        self.conn.close()
        print("🔌 Соединение закрыто")
    
    def show_overdue_tasks(self):
        """Показать все просроченные задачи"""
        self.cursor.execute("""
            SELECT 
                t.id,
                t.title,
                p.name AS project_name,
                u.username AS assigned_to,
                t.due_date,
                CURRENT_DATE - t.due_date AS days_overdue
            FROM tasks t
            JOIN projects p ON t.project_id = p.id
            LEFT JOIN users u ON t.assignee_id = u.id
            WHERE t.status != 'done' 
              AND t.due_date < CURRENT_DATE
            ORDER BY days_overdue DESC
        """)
        
        rows = self.cursor.fetchall()
        
        if rows:
            table = PrettyTable(['ID', 'Задача', 'Проект', 'Ответственный', 'Дедлайн', 'Дней просрочено'])
            for row in rows:
                table.add_row(row)
            print("\n📋 ПРОСРОЧЕННЫЕ ЗАДАЧИ:")
            print(table)
        else:
            print("\n✅ Нет просроченных задач!")
    
    def show_project_stats(self):
        """Показать статистику по проектам"""
        self.cursor.execute("""
            SELECT 
                p.name AS project_name,
                COUNT(DISTINCT pm.user_id) AS members_count,
                COUNT(t.id) AS tasks_count,
                COUNT(CASE WHEN t.status = 'done' THEN 1 END) AS completed_count,
                ROUND(COUNT(CASE WHEN t.status = 'done' THEN 1 END) * 100.0 / 
                      NULLIF(COUNT(t.id), 0), 2) AS completion_percentage
            FROM projects p
            LEFT JOIN project_members pm ON p.id = pm.project_id
            LEFT JOIN tasks t ON p.id = t.project_id
            GROUP BY p.id
            ORDER BY completion_percentage DESC
        """)
        
        rows = self.cursor.fetchall()
        
        table = PrettyTable(['Проект', 'Участников', 'Задач', 'Выполнено', 'Процент'])
        for row in rows:
            table.add_row(row)
        print("\n📊 СТАТИСТИКА ПО ПРОЕКТАМ:")
        print(table)
    
    def show_busy_users(self):
        """Показать самых занятых пользователей"""
        self.cursor.execute("""
            SELECT 
                u.username,
                COUNT(t.id) AS total_assigned,
                COUNT(CASE WHEN t.status != 'done' THEN 1 END) AS active_tasks
            FROM users u
            LEFT JOIN tasks t ON u.id = t.assignee_id
            GROUP BY u.id
            ORDER BY active_tasks DESC
            LIMIT 5
        """)
        
        rows = self.cursor.fetchall()
        
        table = PrettyTable(['Пользователь', 'Всего задач', 'Активных задач'])
        for row in rows:
            table.add_row(row)
        print("\n👥 САМЫЕ ЗАНЯТЫЕ ПОЛЬЗОВАТЕЛИ:")
        print(table)
    
    def add_task(self, title, project_id, assignee_id, priority=1):
        """Добавить новую задачу"""
        try:
            self.cursor.execute("""
                INSERT INTO tasks (title, project_id, assignee_id, priority, status)
                VALUES (%s, %s, %s, %s, 'pending')
                RETURNING id
            """, (title, project_id, assignee_id, priority))
            
            task_id = self.cursor.fetchone()[0]
            self.conn.commit()
            print(f"✅ Задача '{title}' создана с ID {task_id}")
            return task_id
        except Exception as e:
            self.conn.rollback()
            print(f"❌ Ошибка при создании задачи: {e}")
            return None
    
    def complete_task(self, task_id):
        """Отметить задачу выполненной"""
        try:
            self.cursor.execute("""
                UPDATE tasks 
                SET status = 'done', 
                    completed_at = CURRENT_TIMESTAMP
                WHERE id = %s AND status != 'done'
                RETURNING title
            """, (task_id,))
            
            task = self.cursor.fetchone()
            if task:
                self.conn.commit()
                print(f"✅ Задача '{task[0]}' отмечена как выполненная!")
                return True
            else:
                print(f"⚠️ Задача {task_id} не найдена или уже выполнена")
                return False
        except Exception as e:
            self.conn.rollback()
            print(f"❌ Ошибка: {e}")
            return False
    
    def show_all_projects(self):
        """Показать все проекты"""
        self.cursor.execute("""
            SELECT id, name, description 
            FROM projects 
            ORDER BY name
        """)
        
        rows = self.cursor.fetchall()
        
        table = PrettyTable(['ID', 'Название', 'Описание'])
        for row in rows:
            table.add_row(row)
        print("\n📁 ВСЕ ПРОЕКТЫ:")
        print(table)
    
    def show_all_users(self):
        """Показать всех пользователей"""
        self.cursor.execute("""
            SELECT id, username, email 
            FROM users 
            ORDER BY username
        """)
        
        rows = self.cursor.fetchall()
        
        table = PrettyTable(['ID', 'Имя пользователя', 'Email'])
        for row in rows:
            table.add_row(row)
        print("\n👤 ВСЕ ПОЛЬЗОВАТЕЛИ:")
        print(table)
    
    def run_menu(self):
        """Интерактивное меню"""
        while True:
            print("\n" + "="*50)
            print("СИСТЕМА УПРАВЛЕНИЯ ЗАДАЧАМИ")
            print("="*50)
            print("1. Показать просроченные задачи")
            print("2. Показать статистику по проектам")
            print("3. Показать самых занятых пользователей")
            print("4. Показать все проекты")
            print("5. Показать всех пользователей")
            print("6. Добавить новую задачу")
            print("7. Отметить задачу выполненной")
            print("0. Выход")
            print("="*50)
            
            choice = input("Выберите действие: ")
            
            if choice == '1':
                self.show_overdue_tasks()
            elif choice == '2':
                self.show_project_stats()
            elif choice == '3':
                self.show_busy_users()
            elif choice == '4':
                self.show_all_projects()
            elif choice == '5':
                self.show_all_users()
            elif choice == '6':
                print("\n📝 ДОБАВЛЕНИЕ НОВОЙ ЗАДАЧИ")
                title = input("Название задачи: ")
                self.show_all_projects()
                project_id = input("ID проекта: ")
                self.show_all_users()
                assignee_id = input("ID исполнителя: ")
                priority = input("Приоритет (1-низкий, 2-средний, 3-высокий) [1]: ") or "1"
                self.add_task(title, int(project_id), int(assignee_id), int(priority))
            elif choice == '7':
                print("\n✅ ОТМЕТИТЬ ЗАДАЧУ ВЫПОЛНЕННОЙ")
                task_id = input("ID задачи: ")
                self.complete_task(int(task_id))
            elif choice == '0':
                print("До свидания!")
                break
            else:
                print("❌ Неверный выбор. Попробуйте снова.")

def main():
    """Главная функция"""
    print("Запуск приложения Task Manager...")
    print("="*50)
    
    # Создаем экземпляр менеджера
    tm = TaskManager()
    
    # Запускаем меню
    tm.run_menu()
    
    # Закрываем соединение
    tm.close()

if __name__ == "__main__":
    main()