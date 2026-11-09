DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location  VARCHAR(50)
);

CREATE TABLE employees (
    emp_id    INT PRIMARY KEY,
    emp_name  VARCHAR(50) NOT NULL,
    dept_id   INT,
    salary    DECIMAL(10, 2),
    CONSTRAINT fk_employee_dept FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE projects (
    project_id   INT PRIMARY KEY,
    project_name VARCHAR(50) NOT NULL,
    dept_id      INT,
    budget       DECIMAL(10, 2),
    CONSTRAINT fk_project_dept FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT',        'Building A'),
(102, 'HR',        'Building B'),
(103, 'Finance',   'Building C'),
(104, 'Marketing', 'Building D');

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith',     101, 50000),
(2, 'Jane Doe',       102, 60000),
(3, 'Mike Johnson',   101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown',      NULL, 45000);

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign',   101, 100000),
(2, 'Employee Training',  102,  50000),
(3, 'Budget Analysis',    103,  75000),
(4, 'Cloud Migration',    101, 150000),
(5, 'AI Research',        NULL, 200000);




--  2.1: inner join
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

--  2.2: (dept_statistics)
CREATE OR REPLACE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS maximum_salary,
    MIN(e.salary) AS minimum_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

--  2.3:  (project_overview)
CREATE OR REPLACE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    (SELECT COUNT(*) FROM employees e WHERE e.dept_id = d.dept_id) AS team_size
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id;

--  2.4:  (high_earners)
CREATE OR REPLACE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;


--  3.1: change
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- 3.2:  high_earners -> top_performers
ALTER VIEW high_earners RENAME TO top_performers;
--  3.3:  temp_view and delete it
CREATE OR REPLACE VIEW temp_view AS
SELECT * FROM employees WHERE salary < 50000;

DROP VIEW temp_view;

-- 4.1:  (employee_salaries)
CREATE OR REPLACE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;

--  4.2: update
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';
-- 4.3: insert
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

-- Упражнение 4.4: Представление с CHECK OPTION
CREATE OR REPLACE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

-- Попытка вставить чужой отдел вызовет ошибку (закомментировано, чтобы не ломать скрипт):
-- INSERT INTO it_employees (emp_id, emp_name, dept_id, salary) VALUES (7, 'Bob Wilson', 103, 60000);

DROP MATERIALIZED VIEW IF EXISTS dept_summary_mv CASCADE;
DROP MATERIALIZED VIEW IF EXISTS project_stats_mv CASCADE;
--  5.1: crete view
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    COALESCE(SUM(e.salary), 0) AS total_salaries,
    COUNT(p.project_id) AS total_projects,
    COALESCE(SUM(p.budget), 0) AS total_project_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

-- 5.2:  (REFRESH)
INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES (8, 'Charlie Brown', 101, 54000);
REFRESH MATERIALIZED VIEW dept_summary_mv;

--  5.3: unique index и update (CONCURRENTLY)
CREATE UNIQUE INDEX idx_dept_summary_mv_id ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
-- 5.4: table (WITH NO DATA)
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    (SELECT COUNT(*) FROM employees e WHERE e.dept_id = d.dept_id) AS assigned_employees
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WITH NO DATA;

-- Заполнение данными для возможности запроса:
REFRESH MATERIALIZED VIEW project_stats_mv;

-- 6.1: create base role and user (с проверкой существования для безопасности повторного запуска)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'analyst') THEN
        CREATE ROLE analyst NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'data_viewer') THEN
        CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'report_user') THEN
        CREATE ROLE report_user LOGIN PASSWORD 'report456';
    END IF;
END $$;
--  6.2: role with extended attribues
ALTER ROLE db_creator CREATEDB LOGIN PASSWORD 'creator789';
ALTER ROLE user_manager CREATEROLE LOGIN PASSWORD 'manager101';
-- SUPERUSER требует особой осторожности:
ALTER ROLE admin_user SUPERUSER LOGIN PASSWORD 'admin999';

-- 6.3: privalegy begin
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

-- 6.4: group roles and team users
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'hr_team') THEN CREATE ROLE hr_team; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'finance_team') THEN CREATE ROLE finance_team; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'it_team') THEN CREATE ROLE it_team; END IF;

    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'hr_user1') THEN CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001'; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'hr_user2') THEN CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002'; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'finance_user1') THEN CREATE ROLE finance_user1 LOGIN PASSWORD 'fin001'; END IF;
END $$;

GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

--  6.5: (Revoke)
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

-- 6.6: roles attribute change
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;

-- 7.1: role hierarchy
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'read_only') THEN CREATE ROLE read_only; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'junior_analyst') THEN CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123'; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'senior_analyst') THEN CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123'; END IF;
END $$;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;

-- 7.2: (Object Ownership)
DO $$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'project_manager') THEN CREATE ROLE project_manager LOGIN PASSWORD 'pm123'; END IF; END $$;
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

--  7.3:  (Reassign and Drop)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'temp_owner') THEN CREATE ROLE temp_owner LOGIN; END IF;
END $$;

CREATE TABLE IF NOT EXISTS temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

--  7.4:  (Row-Level Security via Views)
CREATE OR REPLACE VIEW hr_employee AS
SELECT * FROM employees WHERE dept_id = 102;
GRANT SELECT ON hr_employee TO hr_team;

CREATE OR REPLACE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;

--  8.1: (dept_dashboard)
CREATE OR REPLACE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    ROUND(COALESCE(AVG(e.salary), 0), 2) AS average_salary,
    COUNT(DISTINCT p.project_id) AS active_projects,
    COALESCE(SUM(p.budget), 0) AS total_project_budget,
    CASE
        WHEN COUNT(DISTINCT e.emp_id) = 0 THEN 0.00
        ELSE ROUND(COALESCE(SUM(p.budget), 0) / COUNT(DISTINCT e.emp_id), 2)
    END AS budget_per_employee
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name, d.location;

--  8.2: Аудит проектов (добавление колонки даты, создание представления с условиями)
-- Добавляем колонку, если её ещё нет
ALTER TABLE projects ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE OR REPLACE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

-- 8.3: (Access Control System)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'viewer_role') THEN CREATE ROLE viewer_role; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'entry_role') THEN CREATE ROLE entry_role; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'analyst_role') THEN CREATE ROLE analyst_role; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'manager_role') THEN CREATE ROLE manager_role; END IF;

    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'alice') THEN CREATE ROLE alice LOGIN PASSWORD 'alice123'; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'bob') THEN CREATE ROLE bob LOGIN PASSWORD 'bob123'; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'charlie') THEN CREATE ROLE charlie LOGIN PASSWORD 'charlie123'; END IF;
END $$;

-- Уровни привилегий:
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

-- Назначение пользователей в роли:
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;