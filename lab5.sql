--Malikova Aisha 25B052399
--1.1
drop table if exists employees cascade;
create table employees(
    employee_id   integer,
    first_name text,
    last_name  text,
    age integer check( age between 18 and 65), --checks if it is between 18 and 65
    salary numeric check(salary > 0) --salary check if it is >0
);
--1.2
create table products_catalog (
    product_id integer,
    product_name text,
    regular_price numeric,
    discount_price numeric,
     constraint  valid_discount --checks 3 statements
    check(regular_price > 0 and discount_price > 0 and discount_price < regular_price)
);
--1.3
create table bookings (
    booking_id integer,
    check_in_date date,
    check_out_date date,
    num_guests integer,
    check( num_guests between 1 and 10),
    check(check_out_date > check_in_date)
);
--1.4
insert into employees values(1, 'Ailana', 'Shaikemn', 25, 300000);
insert into employees values(2, 'Murat', 'Ramazan', 37, 450000);
insert into employees values(3, 'Azamat', 'Serikbay', 16, 200000); --age
insert into employees values(4, 'Aidana', 'Seidan',22, -5000 ); --salary
--postgres.public> insert into employees values(1, 'Ailana', 'Shaikemn', 25, 300000) 1 row affected in 5 ms
-- postgres.public> insert into employees values(2, 'Murat', 'Ramazan', 37, 450000) 1 row affected in 1 ms
--postgres.public> insert into employees values(3, 'Azamat', 'Serikbay', 16, 200000)
--[23514] ERROR: new row for relation "employees" violates check constraint "employees_age_check"
-- Detail: Failing row contains (3, Azamat, Serikbay, 16, 200000).
insert into products_catalog values(1, 'laptop', 500000, 470000);
insert into products_catalog values(2, 'phone', 390000, 365000);
insert into products_catalog values(3, 'tablet', -10000, 50000); --regular
insert into products_catalog values (4, 'mouse', 5000, 0); --discount
insert into products_catalog values (5, 'keyboard', 20000, 25000);
-- postgres.public> insert into products_catalog values(1, 'laptop', 500000, 470000) 1 row affected in 6 ms
--postgres.public> insert into products_catalog values(2, 'phone', 390000, 365000) 1 row affected in 2 ms
--postgres.public> insert into products_catalog values(3, 'tablet', -10000, 50000)
--[23514] ERROR: new row for relation "products_catalog" violates check constraint "valid_discount"
-- Detail: Failing row contains (3, tablet, -10000, 50000).
insert into bookings values (1, '2026-10-12', '2026-10-15', 2);
insert into bookings values (2, '2026-11-01', '2026-11-05', 5);
insert into bookings values (3, '2026-10-12', '2026-10-15', 12); -->10
insert into bookings values (4, '2026-10-15', '2026-10-12', 3); --<=
--2.1
create table customers(
    customer_id integer not null, --id must
    email text not null, --email must
    phone text null,
    registration_date date not null --must
);

--2.2
create table inventory(
    item_id integer not null,
    item_name text not null,
    quantity integer not null check(quantity >= 0), --cannot be negative
    unit_price numeric not null check( unit_price > 0), -- must be >0
    last_updated timestamp not null --must
);
--2.3
insert into customers values (1, 'aisha@gmail.com', '87071234567', '2026-10-11');
insert into customers values (2, null, '87017017001', '2026-10-11'); --null into not null
insert into customers values (3, 'notmail@gmail.com', '87474555555', null);
insert into customers values (4, 'iosig@gamil.com', null, '2026-10-11'); --null into nullable column


--3.1
create table users(
    user_id integer, --must be unique
    username text unique, --also unique
    email text unique,
    created_at timestamp
);
--3.2
create table course_enroll(
    enrollment_id integer,
    student_id integer,
    course_code text,
    semester text,
    constraint unique(student_id, course_code, semester) --cannot  sign 2 times
    --to 1 course
);
--3.3
drop table users;
create table users(
    user_id integer,
    username text,
    email text,
    created_at timestamp,
    constraint unique_username unique(username), -- limit for name
    constraint unique_email unique(email) -- limit for email
);
insert into users values (1, 'aisha', 'aisha@gmail.com', current_timestamp);
insert into users values (2, 'aisha', 'other@gmail.com', current_timestamp);
insert into users values (3, 'other_user', 'aisha@gmail.com', current_timestamp);
--postgres.public> insert into users values (1, 'aisha', 'aisha@gmail.com', current_timestamp) 1 row affected in 6 ms
--postgres.public> insert into users values (2, 'aisha', 'other@gmail.com', current_timestamp)
-- [23505] ERROR: duplicate key value violates unique constraint "unique_username" Detail: Key (username)=(aisha) already exists.
--4.1
create table departments(
    dept_id integer primary key,--primary key unique and cannot be not null
    dept_name text not null,
    location text
);
insert into departments values(1, 'IT', 'Almaty');
insert into departments values(2, 'HR', 'Astana');
insert into departments values(3, 'Finance', 'Shymkent');
insert into departments values(1, 'Marketing', 'Almaty');
insert into departments values(null, 'Sales', 'Astana');

--4.2
create table student_course(
    student_id integer,
    course_id integer,
    enrollment_date date,
    grade text,
    primary key(student_id, course_id) --builded primary key
);
--4.3
--write
--5.1
create table employees_dept(
    emp_id integer primary key,
    emp_name text not null,
    dept_id integer references  departments(dept_id), --refers to departments
    hire_date date
);
insert into employees_dept values(1, 'Aisha', 1, '2026-01-10');
insert into employees_dept values(2, 'Damir', 2, '2026-02-15');
insert into employees_dept values(3, 'Dana', 99, '2026-03-01');
--result postgres.public> insert into employees_dept values(3, 'Dana', 99, '2026-03-01')
--[23503] ERROR: insert or update on table "employees_dept" violates foreign key constraint "employees_dept_dept_id_fkey"
--Detail: Key (dept_id)=(99) is not present in table "departments".
--5.2
create table authors(
    author_id integer primary key,
    author_name text not null,
    country text
);
create table publishers(
    publisher_id integer primary key,
    publisher_name text not null,
    city text
);
create table books(
    book_id integer primary key, --multiple foreign keys
    title text not null,
    author_id integer references authors(author_id),
    publisher_id integer references publishers(publisher_id),
    publication_year integer,
    isbn text unique
);
insert into authors values
(1, 'Abai Kunanbayev', 'Kazakhstan'),
(2, 'J.K.Rowling', 'United Kingdom'),
(3, 'Leo Tolstoy', 'Russia');
insert into publishers values
(1,'Kazakh Press', 'Almaty'),
(2, 'BloomsBury', 'London'),
(3, 'Penguin Books', 'London'); --3 rows affected in 4 ms
insert into books values(1, 'Words of Edification', 1, 1, 1890, '9781111111111');
insert into books values(2, 'Harry Potter', 2, 2, 1997, '9782222222222');
insert into books values(3, 'War and Peace', 3, 3, 1869, '9783333333333');
-- postgres.public> insert into books values(1, 'Words of Edification', 1, 1, 1890, '9781111111111') 1 row affected in 5 ms
-- postgres.public> insert into books values(2, 'Harry Potter', 2, 2, 1997, '9782222222222') 1 row affected in 2 ms
--postgres.public> insert into books values(3, 'War and Peace', 3, 3, 1869, '9783333333333') 1 row affected in 1 ms
--5.3
drop table if exists order_items cascade;
drop table if exists orders cascade;
drop table if exists products_fk cascade;
drop table if exists categories cascade;
create table categories(
    category_id integer primary key ,
    category_name text not null
);
create table products_fk( --if anyting refers here, you cannot delete categories
    product_id integer primary key ,
    product_name text not null,
    category_id integer references categories(category_id)
    on delete restrict
);
create table orders(
    order_id integer primary key ,
    order_date text not null
);
create table order_items( -- if deleted, linked elemets also deleted
    item_id integer primary key ,
    order_id integer references orders(order_id)
    on delete cascade,
    product_id integer references products_fk(product_id),
    quantity integer check(quantity > 0)
);
insert into categories values
(1, 'Electronics'),
(2, 'Books');
insert into products_fk values
(1, 'Laptop', 1),
(2, 'Phone', 1),
(3, 'Novel', 2);
insert into orders values
(1, '2026-10-10'),
(2, '2026-10-11');
insert into order_items values
(1, 1, 1, 2),
(2,1, 2, 1),
(3, 2, 3, 3);

delete from categories where category_id = 1;
delete from orders where order_id = 1;
select * from order_items;
--postgres.public> delete from categories where category_id = 1
-- [23001] ERROR: update or delete on table "categories" violates RESTRICT setting of foreign key constraint "products_fk_category_id_fkey" on table "products_fk"
--Detail: Key (category_id)=(1) is referenced from table "products_fk".
--6.1
create table customers (
    customer_id integer primary key,
    name text not null,
    email text not null unique, --unique email for every user
    phone text,
    registration_date date not null
);

create table products (
    product_id integer primary key,
    name text not null,
    description text,
    price numeric(10, 2) not null check (price >= 0), --price cannot be negative
    stock_quantity integer not null check (stock_quantity >= 0) --quantity cannot be negative
);

create table orders (
    order_id integer primary key,
    customer_id integer references customers(customer_id) --connected with client, delete of order is restricted
        on delete restrict,
    order_date date not null,
    total_amount numeric(10, 2) not null check (total_amount >= 0), --total cannot be negative
    status text not null check (
        status in ('pending', 'processing', 'shipped', 'delivered', 'cancelled')
    ) --status is limited
);

create table order_details (
    order_detail_id integer primary key,
    order_id integer not null references orders(order_id) --connected with client, if orded deleted details deleted too
        on delete cascade,
    product_id integer not null references products(product_id) --delete is restricted if order in the cart
        on delete restrict,
    quantity integer not null check (quantity > 0), --quantity cannot be negative
    unit_price numeric(10, 2) not null check (unit_price >= 0)
);
--6.2
insert into customers values
(1, 'aisha', 'aisha@gmail.com', '87001111111', '2026-01-10'),
(2, 'ali', 'ali@gmail.com', '87002222222', '2026-01-15'),
(3, 'dana', 'dana@gmail.com', null, '2026-02-01'),
(4, 'arman', 'arman@gmail.com', '87004444444', '2026-02-10'),
(5, 'madina', 'madina@gmail.com', null, '2026-03-05');

insert into products values
(1, 'laptop', 'work laptop', 350000, 10),
(2, 'mouse', 'wireless mouse', 5000, 50),
(3, 'keyboard', 'mechanical keyboard', 15000, 25),
(4, 'headphones', 'bluetooth headphones', 25000, 15),
(5, 'monitor', '24-inch monitor', 80000, 8);

insert into orders values
(1, 1, '2026-10-01', 355000, 'pending'),
(2, 2, '2026-10-02', 15000, 'processing'),
(3, 3, '2026-10-03', 25000, 'shipped'),
(4, 4, '2026-10-04', 80000, 'delivered'),
(5, 5, '2026-10-05', 40000, 'cancelled');

insert into order_details values
(1, 1, 1, 1, 350000),
(2, 1, 2, 1, 5000),
(3, 2, 3, 1, 15000),
(4, 3, 4, 1, 25000),
(5, 4, 5, 1, 80000);
--6.3
-- test 1: duplicate email
insert into customers values
(6, 'test', 'aisha@gmail.com', null, '2026-10-11');
--ERROR: duplicate key value violates unique constraint "customers_email_key"
-- Detail: Key (email)=(aisha@gmail.com) already exists.

-- test 2: negative price
insert into products values
(6, 'tablet', 'test product', -100, 5);
-- ERROR: new row for relation "products" violates check constraint "products_price_check"
-- Detail: Failing row contains (6, tablet, test product, -100.00, 5).


-- test 3: invalid order status
insert into orders values
(6, 1, '2026-10-11', 1000, 'waiting');
-- ERROR: new row for relation "orders" violates check constraint "orders_status_check"
-- Detail: Failing row contains (6, 1, 2026-10-11, 1000.00, waiting).
-- test 4: non-existent customer
insert into orders values
(7, 99, '2026-10-11', 1000, 'pending');
-- ERROR: insert or update on table "orders" violates foreign key constraint "orders_customer_id_fkey"
-- Detail: Key (customer_id)=(99) is not present in table "customers".


-- test 5: zero quantity
insert into order_details values
(6, 1, 1, 0, 350000);
--ERROR: new row for relation "order_details" violates check constraint "order_details_quantity_check"
-- Detail: Failing row contains (6, 1, 1, 0, 350000.00).


-- test 6: null in required column
insert into customers values
(7, null, 'test@gmail.com', null, '2026-10-11');
--ERROR: null value in column "name" of relation "customers" violates not-null constraint
-- Detail: Failing row contains (7, null, test@gmail.com, null, 2026-10-11).

--6.4
select * from customers;
select * from products;
select * from orders;
select * from order_details;



