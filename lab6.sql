CREATE TABLE employees (
    emp_id    INT PRIMARY KEY,
    emp_name  VARCHAR(50),
    dept_id   INT,
    salary    DECIMAL(10, 2)
);

CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location  VARCHAR(50)
);

CREATE TABLE projects (
    project_id   INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id      INT,
    budget       DECIMAL(10, 2)
);

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith',     101, 50000),
(2, 'Jane Doe',       102, 60000),
(3, 'Mike Johnson',   101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown',      NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT',        'Building A'),
(102, 'HR',        'Building B'),
(103, 'Finance',   'Building C'),
(104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign',   101, 100000),
(2, 'Employee Training',  102,  50000),
(3, 'Budget Analysis',    103,  75000),
(4, 'Cloud Migration',    101, 150000),
(5, 'AI Research',        NULL, 200000);

-- 2.1
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;
-- Rows: N x M = 5 x 4 = 20

-- 2.2 a) comma notation
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- 2.2 b) INNER JOIN ON TRUE
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;
-- Both return the same 20 rows.

-- 2.3 employees x projects (availability matrix)
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p
ORDER BY e.emp_name, p.project_name;
-- Rows: 5 x 5 = 25

-- 3.1
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- 4 rows: John/IT, Jane/HR, Mike/IT, Sarah/Finance.
-- Tom Brown excluded: his dept_id is NULL, and NULL = 101 (or any value,
-- even NULL = NULL) evaluates to UNKNOWN, not TRUE -> no match -> dropped.

-- 3.2 USING
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
-- Same 4 rows. Difference: with SELECT *, USING outputs the join column
-- dept_id ONCE (merged); ON outputs it TWICE (e.dept_id and d.dept_id).
-- With USING you also cannot qualify it (write dept_id, not e.dept_id) in
-- the SELECT list of the merged column in most dialects.

-- 3.3 NATURAL
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;
-- Common column names = only dept_id -> same 4 rows.

-- 3.4 three tables
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects    p ON d.dept_id = p.dept_id;
-- 6 rows: John/IT/Website Redesign, John/IT/Cloud Migration,
--         Mike/IT/Website Redesign, Mike/IT/Cloud Migration,
--         Jane/HR/Employee Training, Sarah/Finance/Budget Analysis.
-- (IT has 2 projects -> each IT employee appears twice.)

-- 4.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- 5 rows. Tom Brown: emp_dept = NULL, dept_dept = NULL, dept_name = NULL
-- (kept because he is in the left table, right side filled with NULLs).

-- 4.2 USING
SELECT emp_name, dept_id, dept_name
FROM employees
LEFT JOIN departments USING (dept_id);
-- Same 5 rows; dept_id taken from the left table (NULL for Tom).

-- 4.3 employees without a department
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
-- 1 row: Tom Brown, NULL

-- 4.4 departments with employee count (incl. 0)
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;
-- IT 2, HR 1, Finance 1, Marketing 0
-- COUNT(e.emp_id) (not COUNT(*)) so Marketing gives 0, not 1.

-- 5.1
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
-- 5 rows: John/IT, Mike/IT, Jane/HR, Sarah/Finance, NULL/Marketing

-- 5.2 as LEFT JOIN (swap table order)
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id;

-- 5.3 departments without employees
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;
-- 1 row: Marketing, Building D

-- 6.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
-- 6 rows.
-- NULL on the LEFT side (employees columns): Marketing row
--   (emp_name = NULL, emp_dept = NULL, dept_dept = 104).
-- NULL on the RIGHT side (departments columns): Tom Brown row
--   (dept_dept = NULL, dept_name = NULL).

-- 6.2
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;
-- 6 rows: IT/Website Redesign, IT/Cloud Migration, HR/Employee Training,
--         Finance/Budget Analysis, Marketing/NULL/NULL, NULL/AI Research/200000

-- 6.3 orphaned records
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;
-- 2 rows: 'Employee without department' | Tom Brown | NULL
--         'Department without employees' | NULL | Marketing

-- 7.1 filter in ON (LEFT JOIN)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';
--  John/IT, Mike/IT, Jane/NULL, Sarah/NULL, Tom/NULL

-- 7.2 filter in WHERE (LEFT JOIN)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- 2 rows: John/IT, Mike/IT
-- Difference: ON is part of the matching rule - employees that fail it are
-- still kept (left side preserved) with NULLs on the right. WHERE runs AFTER
-- the join and removes rows where d.location is NULL or <> 'Building A',
-- so the NULL-extended rows are deleted -> LEFT JOIN behaves like INNER JOIN.

-- 7.3 same with INNER JOIN
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- Both: John/IT, Mike/IT (2 rows). No difference: INNER JOIN never creates
-- NULL-extended rows, so filtering in ON or WHERE removes the same rows.

-- 8.1 all departments + employees (if any) + projects (if any)
SELECT d.dept_name, e.emp_name, e.salary, p.project_name, p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects  p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;
-- 7 rows: Finance 1, HR 1, IT 4 (2 employees x 2 projects), Marketing 1 (all NULL).
-- Note: employees and projects are both joined via dept_id, so IT rows multiply.

-- 8.2 self join
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3    WHERE emp_id = 1;
UPDATE employees SET manager_id = 3    WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3    WHERE emp_id = 4;
UPDATE employees SET manager_id = 3    WHERE emp_id = 5;

SELECT e.emp_name AS employee, m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;
-- 5 rows: John/Mike, Jane/Mike, Mike/NULL, Sarah/Mike, Tom/Mike

-- 8.3 avg salary > 50000 (as in the lab)
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;
-- IT 52500, HR 60000, Finance 65000 (Marketing has no employees -> dropped)

-- 8.3 variant: join with an explicit subquery
SELECT d.dept_name, s.avg_salary
FROM departments d
INNER JOIN (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
) s ON s.dept_id = d.dept_id
WHERE s.avg_salary > 50000;

-- 1. inner join returns only rows with a match in both tables. left join
--    returns ALL rows of the left table; where there is no match, right-side
--    columns are NULL.
--
-- 2. cross join when you need every combination: availability matrix
--    (employees x projects), calendar (dates x time slots), product variants
--    (sizes x colors), generating test data.
--
-- 3. In an outer join, ON defines which rows MATCH, and unmatched preserved-side
--    rows survive with NULLs. WHERE filters the finished result, so it also
--    deletes those NULL-extended rows (the LEFT JOIN degrades to INNER). In an
--    inner join there are no preserved/NULL-extended rows, so ON and WHERE
--    give identical results.
--
-- 4. 5 x 10 = 50.
--
-- 5. natural join automatically joins on ALL columns that have the same name
--    in both tables (equality on each), and outputs each such column once.
--    If there are no common names, it degenerates into a CROSS JOIN.
--
-- 6. Risks: silently breaks when columns are added/renamed (e.g. a new
--    "name" or "created_at" in both tables becomes an extra join condition);
--    may join on unintended columns; no common columns -> accidental
--    Cartesian product; hard to read since the join keys are not visible.
--
-- 7. SELECT * FROM B RIGHT JOIN A ON A.id = B.id;
--    (Same rows; column order becomes B's columns first. List columns
--    explicitly if order matters.)
--
-- 8. FULL OUTER JOIN when you need unmatched rows from BOTH sides: reconciling
--    two data sources, finding orphans on both sides (6.3), merging two
--    datasets without losing records.

-- C1. FULL OUTER JOIN via UNION of LEFT and RIGHT joins
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_name, e.dept_id, d.dept_id, d.dept_name
FROM employees e RIGHT JOIN departments d ON e.dept_id = d.dept_id;
-- (UNION removes duplicates; UNION ALL + "WHERE e.emp_id IS NULL" in the
--  second half is the exact, duplicate-safe form.)

-- C2. Employees in departments with more than one project
SELECT DISTINCT e.emp_name
FROM employees e
JOIN (
    SELECT dept_id
    FROM projects
    WHERE dept_id IS NOT NULL
    GROUP BY dept_id
    HAVING COUNT(*) > 1
) p ON p.dept_id = e.dept_id;
-- John Smith, Mike Johnson (only IT has 2 projects)

-- C3. Org structure: employee -> manager -> manager's manager (self-joins)
SELECT e.emp_name AS employee,
       m1.emp_name AS manager,
       m2.emp_name AS managers_manager
FROM employees e
LEFT JOIN employees m1 ON e.manager_id  = m1.emp_id
LEFT JOIN employees m2 ON m1.manager_id = m2.emp_id;

-- C3 (any depth): recursive CTE
WITH RECURSIVE org AS (
    SELECT emp_id, emp_name, manager_id, 1 AS level,
           emp_name::text AS chain
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.emp_name, e.manager_id, o.level + 1,
           o.chain || ' > ' || e.emp_name
    FROM employees e
    JOIN org o ON e.manager_id = o.emp_id
)
SELECT * FROM org ORDER BY level, emp_name;

-- C4. All pairs of employees in the same department
SELECT a.emp_name AS employee_1, b.emp_name AS employee_2, a.dept_id
FROM employees a
JOIN employees b ON a.dept_id = b.dept_id AND a.emp_id < b.emp_id;
-- 1 pair: John Smith - Mike Johnson (a.emp_id < b.emp_id avoids self-pairs
-- and mirrored duplicates)
