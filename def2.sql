CREATE DATABASE airport_db
WITH ENCODING = 'UTF8'
     CONNECTION LIMIT = 30;


CREATE TABLE flights (
    flight_id SERIAL PRIMARY KEY,
    flight_code CHAR(6),
    origin CHAR(3),
    destination CHAR(3),
    departure TIMESTAMPTZ,
    flight_time INTERVAL,
    ticket_price NUMERIC(8,2),
    is_international BOOLEAN DEFAULT true
);


CREATE TABLE passengers (
    passenger_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    birth_date DATE,
    loyalty_points BIGINT,
    notes TEXT,
    registered_at TIMESTAMP
);


ALTER TABLE flights
    ALTER COLUMN flight_code TYPE VARCHAR(8),
    ALTER COLUMN is_international DROP DEFAULT,
    ADD COLUMN gate VARCHAR(5);

ALTER TABLE passengers
    ALTER COLUMN loyalty_points TYPE INTEGER,
    DROP COLUMN notes,
    ADD COLUMN seat_class CHAR(1) DEFAULT 'E';

DROP TABLE IF EXISTS passengers;

ALTER DATABASE airport_db WITH CONNECTION LIMIT 100;



