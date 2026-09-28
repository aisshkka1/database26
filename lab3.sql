CREATE DATABASE advanced_lab;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments(
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    budget DECIMAL(12, 2),
    manager_id INT
);

CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INT REFERENCES departments(dept_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL (12, 2)
);

-- insert with column specification
INSERT INTO employees (first_name, last_name, department, hire_date)
VALUES ('Aisha', 'Malik', 'Marketing', CURRENT_DATE );


-- dfault values
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Aidyn', 'Shaket', 'Sales', DEFAULT, '2026-09-01', DEFAULT);


--  multiple rows in single statement
INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('Engineering', 250000.00, NULL),
    ('Human Resources', 120000.00, NULL),
    ('Finance', 180000.00, NULL);


-- expressions
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Arai', 'Tolegen', 'IT', 50000 * 1.1, CURRENT_DATE);


-- insert from select
CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE 1=0;

INSERT INTO temp_employees
SELECT * FROM employees
WHERE department = 'IT';

--  arithmetic expressions
UPDATE employees
SET salary = salary * 1.10;


--  update with where clause and multiple conditions
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';


-- case expression
UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;


-- default
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


-- subquery
UPDATE departments d
SET budget = sub.avg_sal * 1.20
FROM (
    SELECT department, AVG(salary) AS avg_sal
    FROM employees
    GROUP BY department
) sub
WHERE d.dept_name = sub.department;


--  multiple columns
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees
WHERE status = 'Terminated';


-- complex where
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;


--  delete with subquery
DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT dept_id
    FROM employees
    WHERE dept_id IS NOT NULL
);


--  DELETE with RETURNING clause
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- null values insert
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Aliaskar', 'Medet', NULL, NULL, CURRENT_DATE);


-- null update
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;


-- null delete
DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

-- insert with returning
--  return full_name alongside emp_id
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Christina', 'Kim', 'IT', 75000.00, CURRENT_DATE)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;


-- update with returning
-- Returns emp_id, old salary  and new salary
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, (salary - 5000) AS old_salary, salary AS new_salary;


-- delete with returning all columns
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- 23. Conditional INSERT
-- Вставка сотрудника только если записи с такими же first_name и last_name ещё нет
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Arslan', 'Tokeev', 'Finance', 65000.00, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Arslan'
      AND last_name = 'Tokeev'
);


-- 24. UPDATE with JOIN logic using subqueries
-- Обновление зарплаты в зависимости от бюджета отдела (бюджет > 100000 -> +10%, иначе -> +5%)
UPDATE employees e
SET salary = CASE
    WHEN d.budget > 100000 THEN e.salary * 1.10
    ELSE e.salary * 1.05
END
FROM departments d
WHERE e.department = d.dept_name;

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
    ('Anar', 'Asylzhan', 'IT', 60000.00, CURRENT_DATE),
    ('Roman', 'Scornyakov', 'IT', 62000.00, CURRENT_DATE),
    ('Daniyar', 'Bazarbai', 'HR', 55000.00, CURRENT_DATE),
    ('Ular', 'Zhumakerim', 'HR', 58000.00, CURRENT_DATE),
    ('Leila', 'Rakhymkyzy', 'Sales', 50000.00, CURRENT_DATE);


UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN ('Anar', 'Roman', 'Daniyar', 'Ular', 'Leila')
  AND last_name IN ('Asylzhan', 'Scornyakov', 'Bazarbai', 'Zhumakerim', 'Rakhymkyzy');


--  Data migration simulation
-- Шаг A: Создание таблицы-архива с такой же структурой, как у employees
CREATE TABLE IF NOT EXISTS employee_archive (LIKE employees INCLUDING ALL);

-- Шаг B: Перенос (вставка) неактивных сотрудников в архив
INSERT INTO employee_archive
SELECT * FROM employees
WHERE status = 'Inactive';

-- Шаг C: Удаление перенесённых сотрудников из основной таблицы
DELETE FROM employees
WHERE status = 'Inactive';


-- Продление end_date на 30 дней для проектов с бюджетом > 50000,
-- чей отдел содержит более 3 сотрудников
UPDATE projects p
SET end_date = p.end_date + INTERVAL '30 days'
FROM departments d
WHERE p.dept_id = d.dept_id
  AND p.budget > 50000
  AND d.dept_name IN (
      SELECT department
      FROM employees
      WHERE department IS NOT NULL
      GROUP BY department
      HAVING COUNT(*) > 3
  );