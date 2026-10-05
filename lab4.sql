-- Create tables
DROP TABLE IF EXISTS projects CASCADE;
CREATE TABLE employees (
employee_id SERIAL PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
department VARCHAR(50),
salary NUMERIC(10,2),
hire_date DATE,
manager_id INTEGER,
email VARCHAR(100)
);
CREATE TABLE projects (
project_id SERIAL PRIMARY KEY,
project_name VARCHAR(100),
budget NUMERIC(12,2),
start_date DATE,
end_date DATE,
status VARCHAR(20)
);
CREATE TABLE assignments (
assignment_id SERIAL PRIMARY KEY,
employee_id INTEGER REFERENCES employees(employee_id),
project_id INTEGER REFERENCES projects(project_id),
hours_worked NUMERIC(5,1),
assignment_date DATE
);
-- Insert sample data
INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');
INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');
INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');
--task1
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    department,
    salary
FROM employees;

SELECT DISTINCT employees.department from employees;

SELECT
    project_name,
    budget,
    CASE
        WHEN budget > 150000 THEN 'Large'
        WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
        ELSE 'Small'
    END AS budget_category
FROM projects;

SELECT
    first_name || ' ' || last_name AS full_name,
    COALESCE(email, 'No email provided') AS email
FROM employees;

--task2
SELECT *
from employees
where hire_date > '2020-01-01';

SELECT *
from employees
where salary between 60000 and 70000;

SELECT *
from employees
where last_name like 'S%' or last_name like 'J%';

SELECT *
from employees
where manager_id is not null and department = 'IT';

--task3
SELECT
    UPPER(first_name || ' ' || last_name) AS upper_full_name,
    LENGTH(last_name) AS last_name_length,
    SUBSTRING(email FROM 1 FOR 3) AS email_prefix
FROM employees;

SELECT
    first_name || ' ' || last_name AS full_name,
    salary AS annual_salary,
    ROUND(salary / 12, 2) AS monthly_salary,
    salary * 0.10 AS raise_amount
FROM employees;

SELECT
    FORMAT('Project: %s - Budget: $%s - Status: %s', project_name, budget, status) AS project_details
FROM projects;

SELECT
    first_name || ' ' || last_name AS full_name,
    hire_date,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_with_company
FROM employees;

--task4
SELECT
    department,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department;

SELECT
    p.project_name,
    SUM(a.hours_worked) AS total_hours
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_name;

SELECT department
from employees
group by department
having count(*) > 1;

select
    max(salary) as mx,
    min(salary) as mn,
    sum(salary) as sm
from employees;

--task5
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary > 65000

UNION

SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE hire_date > '2020-01-01';


select employee_id, first_name, last_name, department, salary
from employees
where department = 'IT'
intersect
select employee_id, first_name, last_name, department, salary
from employees
    where salary > 65000;

SELECT employee_id
FROM employees

EXCEPT

SELECT employee_id
FROM assignments;
--task6
SELECT employee_id, first_name, last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM assignments a
    WHERE a.employee_id = e.employee_id
);
select *
from projects
where status in('Active');

SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Sales'
);

--task7
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    AVG(a.hours_worked) AS avg_hours,
    e.salary
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary
ORDER BY e.department, e.salary DESC;

SELECT
    p.project_name,
    SUM(a.hours_worked) AS total_hours,
    COUNT(DISTINCT a.employee_id) AS total_employees
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150;

SELECT
    department,
    COUNT(*) AS total_employees,
    AVG(salary) AS avg_salary,
    MAX(salary) AS highest_paid
FROM employees
GROUP BY department;












