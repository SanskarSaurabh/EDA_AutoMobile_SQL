-- Here We Created A Table
CREATE TABLE car_data (
    symboling INT,
    normalized_losses TEXT,
    make TEXT,
    fuel_type TEXT,
    aspiration TEXT,
    num_of_doors TEXT,
    body_style TEXT,
    drive_wheels TEXT,
    engine_location TEXT,
    wheel_base FLOAT,
    length FLOAT,
    width FLOAT,
    height FLOAT,
    curb_weight INT,
    engine_type TEXT,
    num_of_cylinders TEXT,
    engine_size INT,
    fuel_system TEXT,
    bore TEXT,
    stroke TEXT,
    compression_ratio FLOAT,
    horsepower TEXT,
    peak_rpm TEXT,
    city_mpg INT,
    highway_mpg INT,
    price TEXT
);


-- Here Copying data from csv file
COPY car_data FROM 'E:\Reading\SQL\EDA Project\automobile_data.csv'
DELIMITER ',' CSV HEADER;


select * from car_data

-- Replacing ? with Null
UPDATE car_data SET normalized_losses = NULL WHERE normalized_losses = '?';
UPDATE car_data SET num_of_doors = NULL WHERE num_of_doors = '?';
UPDATE car_data SET bore = NULL WHERE bore = '?';
UPDATE car_data SET stroke = NULL WHERE stroke = '?';
UPDATE car_data SET horsepower = NULL WHERE horsepower = '?';
UPDATE car_data SET peak_rpm = NULL WHERE peak_rpm = '?';
UPDATE car_data SET price = NULL WHERE price = '?';

-- converting text data type to numeric, float
ALTER TABLE car_data ALTER COLUMN normalized_losses TYPE FLOAT USING normalized_losses::FLOAT;
ALTER TABLE car_data ALTER COLUMN bore TYPE FLOAT USING bore::FLOAT;
ALTER TABLE car_data ALTER COLUMN stroke TYPE FLOAT USING stroke::FLOAT;
ALTER TABLE car_data ALTER COLUMN horsepower TYPE FLOAT USING horsepower::FLOAT;
ALTER TABLE car_data ALTER COLUMN peak_rpm TYPE FLOAT USING peak_rpm::FLOAT;
ALTER TABLE car_data ALTER COLUMN price TYPE FLOAT USING price::FLOAT;


-- Which company manufactured the most expensive car and at what price?
SELECT make, price
FROM car_data
WHERE price = (SELECT MAX(price) FROM car_data);


-- Calculate the maximum horsepower for each company
SELECT make, MAX(horsepower::FLOAT) AS max_horsepower
FROM car_data
GROUP BY make
ORDER BY max_horsepower DESC;


-- What is the total count of cars manufactured by each company
SELECT make, COUNT(*) AS total_cars
FROM car_data
GROUP BY make
ORDER BY total_cars DESC;


/* Based on new regulations, companies decided to change the prices of the car. The
new update price is calculated as - if the engine is in front, price will be same else if
the engine is in rear, price will be doubled. Add a new column with the updated prices.*/

-- Adding New Column of Updated Price
ALTER TABLE car_data
ADD COLUMN updated_price FLOAT;

UPDATE car_data
SET updated_price = 
    CASE 
        WHEN engine_location = 'rear' THEN price::FLOAT * 2
        ELSE price::FLOAT
    END;

select * from car_data


-- Sort the dataframe according to car and price combined.
SELECT *
FROM car_data
ORDER BY make ASC, price::FLOAT ASC;


-- Create a new column which stores the number of doors in a car as integers

-- Adding new column
ALTER TABLE car_data
ADD COLUMN num_doors_int INT;

select * from car_data

UPDATE car_data
SET num_doors_int = CASE
    WHEN num_of_doors = 'two' THEN 2
    WHEN num_of_doors = 'four' THEN 4
    ELSE NULL
END;


-- Calculate which variable/feature/attribute is impacting the price of the car the most.
SELECT feature, correlation
FROM (
    SELECT 'normalized_losses' AS feature, CORR(price, normalized_losses) AS correlation FROM car_data
    UNION
    SELECT 'wheel_base', CORR(price, wheel_base) FROM car_data
    UNION
    SELECT 'length', CORR(price, length) FROM car_data
    UNION
    SELECT 'width', CORR(price, width) FROM car_data
    UNION
    SELECT 'height', CORR(price, height) FROM car_data
    UNION
    SELECT 'curb_weight', CORR(price, curb_weight) FROM car_data
    UNION
    SELECT 'engine_size', CORR(price, engine_size) FROM car_data
    UNION
    SELECT 'bore', CORR(price, bore) FROM car_data
    UNION
    SELECT 'stroke', CORR(price, stroke) FROM car_data
    UNION
    SELECT 'compression_ratio', CORR(price, compression_ratio) FROM car_data
    UNION
    SELECT 'horsepower', CORR(price, horsepower) FROM car_data
    UNION
    SELECT 'peak_rpm', CORR(price, peak_rpm) FROM car_data
    UNION
    SELECT 'city_mpg', CORR(price, city_mpg) FROM car_data
    UNION
    SELECT 'highway_mpg', CORR(price, highway_mpg) FROM car_data
) AS correlations
ORDER BY ABS(correlation) DESC;


/* Concatenate the two data frames given below firstly row wise and secondly column
wise.
GermanCars = {'Company': ['Ford', 'Mercedes', 'BMV', 'Audi'], 'Price': [23845,
171995, 135925 , 71400]}
japaneseCars = {'Company': ['Toyota', 'Honda', 'Nissan', 'Mitsubishi '], 'Price': [29995,
23600, 61500 , 58900]} */

-- creating and storing german car in table
CREATE TABLE german_cars (
    company TEXT,
    price INT
);

INSERT INTO german_cars (company, price) VALUES
('Ford', 23845),
('Mercedes', 171995),
('BMV', 135925),
('Audi', 71400);

-- creating and storing japanese car in table
CREATE TABLE japanese_cars (
    company TEXT,
    price INT
);

INSERT INTO japanese_cars (company, price) VALUES
('Toyota', 29995),
('Honda', 23600),
('Nissan', 61500),
('Mitsubishi', 58900);

-- Row-wise concatenation
SELECT * FROM german_cars
UNION ALL
SELECT * FROM japanese_cars;


-- Column-wise concatenation of german_cars and japanese_cars
WITH german AS (
    SELECT 
        ROW_NUMBER() OVER () AS rn, 
        company AS german_company, 
        price AS german_price 
    FROM german_cars
),
japanese AS (
    SELECT 
        ROW_NUMBER() OVER () AS rn, 
        company AS japanese_company, 
        price AS japanese_price 
    FROM japanese_cars
)
SELECT 
    german.german_company, 
    german.german_price,
    japanese.japanese_company, 
    japanese.japanese_price
FROM german
JOIN japanese ON german.rn = japanese.rn;


-- Save the first and last 15 records of the dataframe in a separate excel sheet

SELECT ctid, * FROM car_data;          -- ctid is by default automatically created in postgre sql

-- first 15 data
COPY (
    SELECT * FROM car_data
    ORDER BY ctid
    LIMIT 15
) TO 'E:\Reading\SQL\EDA Project\car_data_first_15.csv' WITH CSV HEADER;


-- last 15 data
COPY (
    SELECT * FROM car_data
    ORDER BY ctid DESC
    LIMIT 15
) TO 'E:\Reading\SQL\EDA Project\car_data_last_15.csv' WITH CSV HEADER;