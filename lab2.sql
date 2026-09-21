CREATE DATABASE university_main
    WITH OWNER = CURRENT_USER
    TEMPLATE = template0
    ENCODING = 'UTF8';[cite: 1]

CREATE DATABASE university_archive
    WITH CONNECTION LIMIT = 50
    TEMPLATE = template0;[cite: 1]

CREATE DATABASE university_test
    WITH IS_TEMPLATE = true
    CONNECTION LIMIT = 10;[cite: 1]

-- Task 1.2
CREATE TABLESPACE student_data LOCATION '/data/students';[cite: 1]

CREATE TABLESPACE course_data
    OWNER CURRENT_USER
    LOCATION '/data/courses';[cite: 1]

CREATE DATABASE university_distributed
    TABLESPACE = student_data
    ENCODING = 'LATIN9';[cite: 1]

-- Task 2.1
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(3, 2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);[cite: 1]

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary NUMERIC(12, 2),
    is_tenured BOOLEAN,
    years_experience INTEGER
);[cite: 1]

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8),
    course_title VARCHAR(100),
    description TEXT,
    credits SMALLINT,
    max_enrollment INTEGER,
    course_fee NUMERIC(8, 2),
    is_online BOOLEAN,
    created_at TIMESTAMP
);[cite: 1]

-- Task 2.2:
CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INTEGER,
    professor_id INTEGER,
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME,
    end_time TIME,
    duration INTERVAL
);[cite: 1]

CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    course_id INTEGER,
    semester VARCHAR(20),
    year INTEGER,
    grade CHAR(2),
    attendance_percentage NUMERIC(4, 1),
    submission_timestamp TIMESTAMPTZ,
    last_updated TIMESTAMPTZ
);[cite: 1]

-- Task 3.1

-- Modify students table[cite: 1]
ALTER TABLE students
    ADD COLUMN middle_name VARCHAR(30),
    ADD COLUMN student_status VARCHAR(20),
    ALTER COLUMN phone TYPE VARCHAR(20),
    ALTER COLUMN student_status SET DEFAULT 'ACTIVE',
    ALTER COLUMN gpa SET DEFAULT 0.00;[cite: 1]

-- Modify professors table[cite: 1]
ALTER TABLE professors
    ADD COLUMN department_code CHAR(5),
    ADD COLUMN research_area TEXT,
    ALTER COLUMN years_experience TYPE SMALLINT,
    ALTER COLUMN is_tenured SET DEFAULT false,
    ADD COLUMN last_promotion_date DATE;[cite: 1]

-- Modify courses table[cite: 1]
ALTER TABLE courses
    ADD COLUMN prerequisite_course_id INTEGER,
    ADD COLUMN difficulty_level SMALLINT,
    ALTER COLUMN course_code TYPE VARCHAR(10),
    ALTER COLUMN credits SET DEFAULT 3,
    ADD COLUMN lab_required BOOLEAN DEFAULT false;[cite: 1]

-- Task 3.2

-- For class_schedule table[cite: 1]
ALTER TABLE class_schedule
    ADD COLUMN room_capacity INTEGER,
    DROP COLUMN duration,
    ADD COLUMN session_type VARCHAR(15),
    ALTER COLUMN classroom TYPE VARCHAR(30),
    ADD COLUMN equipment_needed TEXT;[cite: 1]

-- For student_records table[cite: 1]
ALTER TABLE student_records
    ADD COLUMN extra_credit_points NUMERIC(3, 1),
    ALTER COLUMN grade TYPE VARCHAR(5),
    ALTER COLUMN extra_credit_points SET DEFAULT 0.0,
    ADD COLUMN final_exam_date DATE,
    DROP COLUMN last_updated;[cite: 1]

-- Task 4.1:
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    department_code CHAR(5),
    building VARCHAR(50),
    phone VARCHAR(15),
    budget NUMERIC(15, 2),
    established_year INTEGER
);[cite: 1]

CREATE TABLE library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    title VARCHAR(200),
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price NUMERIC(8, 2),
    is_available BOOLEAN,
    acquisition_timestamp TIMESTAMP
);[cite: 1]

CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    book_id INTEGER,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount NUMERIC(6, 2),
    loan_status VARCHAR(20)
);[cite: 1]

-- Task 4.2: Table Modifications for Integration[cite: 1]
-- 1. Add foreign key columns (just columns)[cite: 1]
ALTER TABLE professors ADD COLUMN department_id INTEGER;[cite: 1]
ALTER TABLE students ADD COLUMN advisor_id INTEGER;[cite: 1]
ALTER TABLE courses ADD COLUMN department_id INTEGER;[cite: 1]

-- 2. Create lookup tables[cite: 1]
CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage NUMERIC(4, 1),
    max_percentage NUMERIC(4, 1),
    gpa_points NUMERIC(3, 2)
);[cite: 1]

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMPTZ,
    is_current BOOLEAN
);[cite: 1]

-- Task 5.1
-- 1. Drop tables if they exist[cite: 1]
DROP TABLE IF EXISTS student_book_loans;[cite: 1]
DROP TABLE IF EXISTS library_books;[cite: 1]
DROP TABLE IF EXISTS grade_scale;[cite: 1]

-- 2. Recreate grade_scale table with additional column[cite: 1]
CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage NUMERIC(4, 1),
    max_percentage NUMERIC(4, 1),
    gpa_points NUMERIC(3, 2),
    description TEXT
);[cite: 1]

-- 3. Drop and recreate with CASCADE[cite: 1]
DROP TABLE IF EXISTS semester_calendar CASCADE;[cite: 1]

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMPTZ,
    is_current BOOLEAN
);[cite: 1]

-- Task 5.2: Database Cleanup[cite: 1]
DROP DATABASE IF EXISTS university_test;[cite: 1]
DROP DATABASE IF EXISTS university_distributed;[cite: 1]

CREATE DATABASE university_backup
    TEMPLATE = university_main;[cite: 1]