DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

-- Create table: stations
CREATE TABLE stations (
    station_id   INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city         VARCHAR(40) NOT NULL,
    capacity     INT NOT NULL
);

-- Create table: bikes
CREATE TABLE bikes (
    bike_id    INT PRIMARY KEY,
    model      VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);

-- Create table: members
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city      VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);

-- Create table: rentals
CREATE TABLE rentals (
    rental_id  INT PRIMARY KEY,
    member_id  INT REFERENCES members(member_id),
    bike_id    INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date   DATE,
    fee        NUMERIC(8,2)
);

INSERT INTO stations VALUES
 (10, 'Central Park', 'Almaty',   4),
 (20, 'Riverside',    'Almaty',   3),
 (30, 'Expo Gate',    'Astana',   5),
 (40, 'Old Town',     'Shymkent', 2),
 (50, 'Depot',        'Astana',   0);

INSERT INTO bikes VALUES
 (101, 'City Cruiser', 10,  4.50),
 (102, 'City Cruiser', 10,  4.50),
 (103, 'Mountain X',   20,  7.00),
 (104, 'Mountain X',   30,  7.00),
 (105, 'Road Sprint',  30,  9.25),
 (106, 'Folding Mini', 40,  3.75),
 (107, 'Cargo Hauler', 20, 12.00),
 (108, 'Road Sprint',  10,  9.25);

INSERT INTO members VALUES
 (1, 'Aisha Nurlanova', 'Almaty',   DATE '2023-03-14'),
 (2, 'Daniyar Serik',   'Almaty',   DATE '2023-07-02'),
 (3, 'Marta Kowalski',  'Astana',   DATE '2024-01-20'),
 (4, 'Chen Wei',        'Astana',   DATE '2024-05-11'),
 (5, 'Omar Haddad',     'Shymkent', DATE '2024-09-30'),
 (6, 'Elena Petrova',   'Almaty',   DATE '2025-02-05');

INSERT INTO rentals VALUES
 ( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
 ( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
 ( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
 ( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
 ( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02',  4.50),
 ( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
 ( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
 ( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
 ( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
 (10, 3, 104, DATE '2025-01-09', DATE '2025-01-10',  7.00),
 (11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
 (12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
 (13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
 (14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
 (15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
 (16, 5, 106, DATE '2025-01-18', DATE '2025-01-20',  7.50),
 (17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
 (18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
 (19, 1, 101, DATE '2025-10-10', NULL,              NULL),
 (20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
 (21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
 (22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);

-- Exercise 2.1: A function over one row
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
DECLARE
    v_days INT;
BEGIN
    SELECT (end_date - start_date) INTO v_days
    FROM rentals
    WHERE rental_id = p_rental_id;

    RETURN v_days;
END;
$$ LANGUAGE plpgsql;

SELECT rental_days(2);   -- : 5 (2024-06-16 - 2024-06-11)
SELECT rental_days(11);  -- : 8 (2025-06-09 - 2025-06-01)
SELECT rental_days(19);  -- : NULL
SELECT rental_days(999); -- : NULL

-- Exercise 2.2: A function over many rows
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

SELECT member_rental_count(1);  --  5
SELECT member_rental_count(5);  --  4
SELECT member_rental_count(6);  -- 0
SELECT member_rental_count(99); --  0

-- Exercise 2.3: Returning text
CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR AS $$
DECLARE
    v_city VARCHAR(40);
BEGIN
    SELECT city INTO v_city
    FROM stations
    WHERE station_id = p_station_id;

    RETURN v_city;
END;
$$ LANGUAGE plpgsql;

SELECT station_city(30); --  'Astana'
SELECT station_city(77); --  NULL

-- Exercise 2.4: Using a function inside a query
SELECT
    rental_id,
    member_id,
    rental_days(rental_id) AS duration_days
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY duration_days DESC;

-- Exercise 3.1: IN parameters
CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100.0), 2);
END;
$$ LANGUAGE plpgsql;

SELECT fee_with_discount(74.00, 15); -- 62.90

-- Exercise 3.2: OUT parameters
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
) AS $$
BEGIN
    SELECT
        COUNT(*)::INT,
        COALESCE(SUM(fee), 0),
        MAX(start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals
    WHERE member_id = p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6);

-- Exercise 3.3: INOUT parameters
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC)
AS $$
BEGIN
    p_fee := p_fee + 5.00;
END;
$$ LANGUAGE plpgsql;

SELECT apply_late_fee(fee) AS updated_fee
FROM rentals
WHERE rental_id = 1; -- 13.50 + 5.00 = 18.50

-- Exercise 3.4: VARIADIC parameters
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
) AS $$
BEGIN
    SELECT
        SUM(p_fees[i]),
        ROUND(AVG(p_fees[i]), 2),
        MAX(p_fees[i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);

-- Exercise 4.1: A function with one parameter
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1); -- Ожидается: 98.50
SELECT total_fees(6); -- Ожидается: 0

-- Exercise 4.2: Overloading the name
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01'); --  98.50
SELECT total_fees(1, DATE '2025-01-01'); -- 50.00 (18.50 + 31.50)

-- check
SELECT proname, pg_get_function_identity_arguments(oid) AS args
FROM pg_proc
WHERE proname = 'total_fees';

-- Exercise 4.3: Giving a parameter a default value
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01'
) RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- The next call causes an ambiguity error (commented out to run the script):`
-- SELECT total_fees(1);

-- Exercise 4.4: Resolving the ambiguity
DROP FUNCTION total_fees(INTEGER);

SELECT total_fees(1); --  50.00

-- Exercise 4.5: Overloading on type, not just on count
CREATE OR REPLACE FUNCTION total_fees(p_full_name VARCHAR)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0) INTO v_total
    FROM members m
    LEFT JOIN rentals r ON m.member_id = r.member_id
    WHERE m.full_name = p_full_name;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova'); -- 98.50
SELECT total_fees(1);                  -- 50.00

-- Exercise 5.1: Search by pattern
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE (
    found_id INT,
    found_model VARCHAR,
    found_rate NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model, daily_rate
    FROM bikes
    WHERE model ILIKE p_pattern
    ORDER BY bike_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
SELECT find_bikes('%road%'); -- without FROM

-- Exercise 5.2: A table from a join
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE (
    rental_id INT,
    bike_model VARCHAR,
    station_name VARCHAR,
    duration_days INT,
    fee NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.rental_id,
        b.model,
        s.station_name,
        (r.end_date - r.start_date)::INT,
        r.fee
    FROM rentals r
    JOIN bikes b ON r.bike_id = b.bike_id
    JOIN stations s ON b.station_id = s.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);

-- Exercise 5.3: When the column names collide
-- not correct
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

/*
 ERROR:  column reference "bike_id" is ambiguous
LINE 1: SELECT bike_id, model FROM bikes WHERE station_id = p_statio...
               ^
DETAIL:  It could refer to either a PL/pgSQL variable or a table column.
QUERY:  SELECT bike_id, model FROM bikes WHERE station_id = p_station_id
CONTEXT:  PL/pgSQL function bike_list(integer) line 3 at RETURN QUERY
 */

-- Исправление 1: Переименование выходных колонок
CREATE OR REPLACE FUNCTION bike_list_v1(p_station_id INT)
RETURNS TABLE (out_bike_id INT, out_model VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model
    FROM bikes
    WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list_v1(10);

--  Использование алиаса таблицы
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model
    FROM bikes b
    WHERE b.station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);


-- Exercise 5.4: Casting the output
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.station_name,
        COUNT(b.bike_id)::INT,
        (s.capacity - COUNT(b.bike_id))::INT
    FROM stations s
    LEFT JOIN bikes b ON s.station_id = b.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM station_board('Almaty');
SELECT * FROM station_board('Astana');

-- Exercise 6.1: An anonymous block
DO $$
<<rental_report>>
DECLARE
    total_rentals INTEGER := 0;
BEGIN
    SELECT COUNT(*) INTO total_rentals FROM rentals;
    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
END rental_report $$;

-- Exercise 6.2: A subblock and a hidden variable
DO $$
<<outer_block>>
DECLARE
    fee_total NUMERIC;
BEGIN
    SELECT SUM(fee) INTO fee_total FROM rentals;
    RAISE NOTICE '1. Outer before subblock: %', fee_total;

    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT SUM(fee) INTO fee_total
        FROM rentals
        WHERE start_date >= DATE '2025-01-01';

        RAISE NOTICE '2. Subblock own fee_total (2025+): %', fee_total;
        RAISE NOTICE '3. Outer fee_total via label: %', outer_block.fee_total;
    END;

    RAISE NOTICE '4. Outer after subblock: %', fee_total;
END outer_block $$;
/*
 6.2 result
 NOTICE:  1. Outer before subblock: 604.25
NOTICE:  2. Subblock own fee_total (2025+): 332.75
NOTICE:  3. Outer fee_total via label: 604.25
NOTICE:  4. Outer after subblock: 604.25
 */

-- Exercise 6.3: Declarations are local
-- Вариант с ошибкой (subblock 2 обращается к переменной subblock 1):
/*
DO $$
BEGIN
    DECLARE
        sub_var INT := 42;
    BEGIN
        RAISE NOTICE 'Subblock 1: %', sub_var;
    END;

    BEGIN
        RAISE NOTICE 'Subblock 2: %', sub_var; -- ERROR: column "sub_var" does not exist
    END;
END $$;
*/

-- Исправленный вариант (переменная перенесена во внешний блок):
DO $$
DECLARE
    shared_var INT := 42;
BEGIN
    BEGIN
        RAISE NOTICE 'Subblock 1 reads: %', shared_var;
        shared_var := 100;
    END;

    BEGIN
        RAISE NOTICE 'Subblock 2 reads: %', shared_var;
    END;
END $$;

-- Exercise 6.4: From a block to a function
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
) AS $$
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO before_total
    FROM rentals
    WHERE start_date < p_from_date;

    SELECT COALESCE(SUM(fee), 0) INTO after_total
    FROM rentals
    WHERE start_date >= p_from_date;
END;
$$ LANGUAGE plpgsql;

SELECT
    before_total,
    after_total,
    (before_total + after_total) AS combined_sum,
    (SELECT SUM(fee) FROM rentals) AS actual_table_sum
FROM fee_split(DATE '2025-01-01');

-- Exercise 7.1: Station occupancy
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
) AS $$
DECLARE
    v_capacity INT;
BEGIN
    SELECT s.capacity, COUNT(b.bike_id)::INT
    INTO v_capacity, bikes_parked
    FROM stations s
    LEFT JOIN bikes b ON s.station_id = b.station_id
    WHERE s.station_id = p_station_id
    GROUP BY s.station_id, s.capacity;

    IF v_capacity IS NULL OR v_capacity = 0 THEN
        capacity_pct := NULL;
    ELSE
        capacity_pct := ROUND((bikes_parked::NUMERIC / v_capacity) * 100, 1);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT s.station_id, s.station_name, l.*
FROM stations s, LATERAL station_load(s.station_id) l;

-- Exercise 7.2: Top members, with a default
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE (
    member_name VARCHAR,
    rental_count INT,
    total_spent NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.full_name,
        COUNT(r.rental_id)::INT,
        COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r ON m.member_id = r.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY total_spent DESC, m.full_name ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);

-- Exercise 7.3: An invoice for an open rental
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE (
    member_name VARCHAR,
    bike_model VARCHAR,
    days INT,
    amount_owed NUMERIC,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.full_name,
        b.model,
        (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT AS calc_days,
        ROUND((COALESCE(r.end_date, CURRENT_DATE) - r.start_date) * b.daily_rate, 2),
        CASE WHEN r.end_date IS NULL THEN 'OPEN'::VARCHAR ELSE 'CLOSED'::VARCHAR END
    FROM rentals r
    JOIN members m ON r.member_id = m.member_id
    JOIN bikes b ON r.bike_id = b.bike_id
    WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);

-- Exercise 7.4: A report per city
-- Версия 1: без даты
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
RETURNS TABLE (
    member_cnt INT,
    rental_cnt INT,
    total_revenue NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT m.member_id)::INT,
        COUNT(r.rental_id)::INT,
        COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r ON m.member_id = r.member_id
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

-- Версия 2: с датой (условие в ON)
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR, p_from_date DATE)
RETURNS TABLE (
    member_cnt INT,
    rental_cnt INT,
    total_revenue NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT m.member_id)::INT,
        COUNT(r.rental_id)::INT,
        COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r
        ON m.member_id = r.member_id
        AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty', DATE '2025-01-01');

/*
Exercise 2.1:
Both rental 19 and rental 999 return NULL, but for different reasons. Rental 19 exists in the table, but its end_date is NULL (it is still open), so subtracting start_date from NULL produces NULL. Rental 999 does not exist in the table at all, so SELECT INTO finds no row and assigns NULL to the variable.

Exercise 2.2:
COUNT(*) always returns a count of matching rows (0 when no rows match), whereas aggregates such as SUM() or MAX() return NULL when there are no rows to aggregate.

Exercise 3.2:
SELECT member_stats(3) returns a single column of composite/record type such as (5,164.75,2025-06-01), whereas SELECT * FROM member_stats(3) expands the OUT parameters into separate named columns. Inside a larger query, SELECT * FROM member_stats(...) (via LATERAL) is better because you can reference each output column directly by name. For member 6, it returns 0 rentals, 0 total fee, and NULL for the latest start date.

Exercise 3.3:
Because OUT and INOUT parameters define the function's output structure directly, no RETURNS clause is used, and the final values of those parameters are automatically returned when execution reaches END; without needing an explicit RETURN statement.

Exercise 3.4:
Calling fee_summary() with no arguments causes generate_subscripts to yield no rows, so the aggregate functions return NULL values for total, average, and largest. A VARIADIC parameter must be last because otherwise PostgreSQL could not tell where the variable-length array arguments end and the following parameters begin.

Exercise 3.5:
(a) IN — the row identifier is read-only input used to filter the lookup.
(b) INOUT — the caller passes an initial balance and receives the updated balance back.
(c) VARIADIC — allows passing an arbitrary number of station IDs as separate arguments collected into an array.
(d) OUT — lets one function return multiple computed summary values from a single pass without defining a custom type.

Exercise 4.3:
PostgreSQL cannot choose between total_fees(integer) (an exact match on one argument) and total_fees(integer, date DEFAULT ...) (which also matches a one-argument call using its default value), as both candidate functions are equally valid.

Exercise 4.4:
After dropping total_fees(integer), the call is handled by total_fees(integer, date DEFAULT DATE '2025-01-01') and returns 50.00 (the sum of fees for rentals starting from 2025-01-01 onwards). Dropping the two-parameter version instead would have left total_fees(integer), returning 98.50 (all fees for member 1).

Exercise 4.5:
The string literal 'Aisha Nurlanova' does not match INTEGER, so there is no ambiguity: the first call invokes total_fees(VARCHAR) and returns 98.50 across all rentals, while the second call invokes total_fees(INT, DATE DEFAULT '2025-01-01') and returns 50.00 for rentals from 2025-01-01 onwards.

Exercise 5.1:
Without FROM, calling SELECT find_bikes('%road%') returns a single column of record tuples in parentheses rather than separate table columns with column headers.

Exercise 5.3:
CREATE FUNCTION only checks basic syntax, while name resolution inside PL/pgSQL queries happens when the function is executed. Because RETURNS TABLE columns act as variables in the function's scope, unqualified column names like bike_id clash with columns of the bikes table.

Exercise 6.1:
If the label after END does not match the opening label (or appears when no opening label was given), PostgreSQL raises a syntax error stating that the end label differs from the block's label.

Exercise 6.2:
The four values printed are 604.25, 332.75, 604.25, and 604.25. Assigning inside the subblock did not change the outer variable because declaring a variable with the same name in a subblock shadows the outer variable within that subblock's scope.

Exercise 7.1:
For station 50 (capacity 0), returning NULL for capacity_pct avoids division by zero and accurately represents an undefined percentage rather than a misleading 0.0% (which would imply available capacity).

Exercise 7.2:
Aisha Nurlanova has 5 rentals yet ranks below Daniyar Serik (4 rentals) and Marta Kowalski (5 rentals) because rows are ordered by total amount spent descending, not by rental count (her rental 19 is still open with a NULL fee, and her completed rentals had lower totals).

Exercise 7.3:
For rental 11, the calculated amount (74.00) matches the stored fee. For rental 19, the amount increases every day because an open rental is billed up to CURRENT_DATE; a function depending on CURRENT_DATE cannot be marked IMMUTABLE because its output changes over time for the same input (it is STABLE).

Exercise 7.4:
The date condition r.start_date >= p_from_date belongs in the ON clause, not the WHERE clause. Putting it in WHERE filters out rows where r.start_date is NULL (such as members with no qualifying rentals), turning the LEFT JOIN into an INNER JOIN and dropping Almaty's member_cnt from 3 to 2.

Lab questions answers:

1. A function's name is just its identifier (such as total_fees), whereas its signature is the name together with the types of its input parameters (such as total_fees(integer, date)). Because overloaded functions can share a name, DROP FUNCTION requires the signature to identify the exact version to remove.
2. Dollar quoting ($$) lets you write a function body as a string literal without doubling single quotes inside SQL statements. Without $$, a body containing single quotes would require escaped/doubled quotes, for example:
CREATE FUNCTION greet_demo() RETURNS TEXT AS 'BEGIN RETURN ''It''''s working!''; END;' LANGUAGE plpgsql;
3. Use multiple OUT parameters when a function returns a single row of scalar values (such as summary metrics for one ID). Use RETURNS TABLE when a function returns a multi-row result set produced by RETURN QUERY.
4. A VARIADIC parameter must come last because otherwise PostgreSQL could not unambiguously separate variadic array elements from subsequent parameters. For example, in a hypothetical function f(VARIADIC a INT[], b INT), a call like f(1, 2, 3) could not be resolved cleanly between extending the array or supplying b.
5. RETURN returns a single scalar value or composite row and immediately exits the function, whereas RETURN QUERY appends rows from a SELECT query to the function's result set and allows execution to continue (including additional RETURN QUERY calls).
6. Adding a DEFAULT parameter makes a function match calls with fewer arguments, which can cause an ambiguity error ("is not unique") if another function already matches that argument count. In production, avoid creating overlapping overloads with default arguments and evolve signatures carefully.
7. A variable declared in a subblock goes out of scope and is discarded when that subblock ends. To read a shadowed variable from an outer block inside a subblock, label the outer block (for example <<outer_block>>) and qualify the reference as outer_block.variable_name.
8. One advantage of moving a business rule into a stored function is centralized enforcement with fewer network round trips when operating on data in the database. One disadvantage is harder version control, testing, and horizontal scaling because CPU work is placed on the database server and tied to that DBMS.
9. A trusted language like PL/pgSQL runs inside a safe sandbox without direct access to the host filesystem or network, so ordinary users with USAGE privilege can create functions in it. An untrusted language like PL/Python can interact with the OS and network, so only a superuser may create functions in it.
10. CREATE OR REPLACE FUNCTION only replaces an existing function if the signature matches; changing argument types creates a separate overloaded function alongside the old one. This leaves behind duplicate overloads and can cause ambiguous calls or callers continuing to hit the old version.
 */