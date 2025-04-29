CREATE DATABASE WALMART;

-- Create table--
CREATE TABLE IF NOT EXISTS sales(
       invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
       branch VARCHAR(5) NOT NULL,
       city VARCHAR(30) NOT NULL,
       customer_type VARCHAR(30) NOT NULL,
       gender VARCHAR(10) NOT NULL,
       product_line VARCHAR(100) NOT NULL,
       unit_price DECIMAL(10, 2) NOT NULL,
       quantity INT NOT NULL,
       VAT FLOAT(6,4) NOT NULL,
       total DECIMAL(12, 4) NOT NULL,
       date DATETIME NOT NULL,
       time TIME NOT NULL,
       payment_method VARCHAR(15) NOT NULL,
       cogs DECIMAL(10, 2) NOT NULL,
       gross_margin_pct FLOAT(11,9),
       gross_income DECIMAL(12, 4) NOT NULL,
       rating FLOAT(2, 1)
       );
       
	------Feature Engineering------
	--time of the day---
       
	SELECT 
            time,
             (CASE
                 WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
                 WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
				 ELSE "Evening"
            END
            ) AS time_of_date
	   FROM sales;
       
    ALTER TABLE sales
    ADD COLUMN time_of_day VARCHAR(20);
    
    UPDATE sales
SET time_of_day = (CASE
                 WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
                 WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
				 ELSE "Evening"
            END
            );
            
----day of the week---
SELECT
          date,
          DAYNAME(date) AS DAY
	FROM sales;
    
    ALTER TABLE sales
    ADD COLUMN day_of_the_week VARCHAR(20);
    
    UPDATE sales
    SET day_of_the_week = DAYNAME(date);
	
    
----month-----
SELECT
      date,
      MONTHNAME(date)
FROM sales;

ALTER TABLE sales
ADD COLUMN month VARCHAR(20);
    
UPDATE sales
SET month = MONTHNAME(date);
		

-----------------------------------------------
-----------------------------------------------
-----------------------------------------------
------EXPLORATORY DATA ANALYSIS-----

-- How many unique cities does the data have?
SELECT
      DISTINCT city
FROM sales;

-- In wbich city are each branches?--
SELECT
     DISTINCT branch
FROM sales;
      
SELECT
     DISTINCT city,
     branch
FROM sales;    

-- How many unique product lines does the data have? --
SELECT
     DISTINCT product_line
FROM sales;

SELECT
     COUNT(DISTINCT product_line)
FROM sales;

-- What is the most common payment method?--
SELECT
     payment_method,
     COUNT(payment_method) AS countpm
FROM sales
GROUP BY payment_method
ORDER BY Countpm DESC;

-- What is the most selling product line?---
SELECT
	product_line,
    COUNT(product_line) AS productline
FROM sales
GROUP BY product_line
ORDER BY productline DESC;

-- What is the total revenue by month?--
SELECT 
     month,
     SUM(total) AS total_revenue
FROM sales
GROUP BY month
ORDER BY total_revenue DESC;

-- What month had the largest cost of good sold (COGS)?--
SELECT 
     month,
     SUM(cogs) AS total_cogs
FROM sales
GROUP BY month
ORDER BY total_cogs DESC;

-- What product line had the largest revenue?--
SELECT 
     product_line,
     SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?--
SELECT 
     branch,
     city,
     SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- What product line had the highest VAT? --
SELECT 
     product_line,
     AVG(VAT) AS avg_vat
FROM sales
GROUP BY product_line
ORDER BY avg_vat DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if is greater than average sales --
SELECT 
	 product_line,
             (CASE
                 WHEN `product_line` > AVG(total) THEN "Good"
                 ELSE "Bad"
            END
            ) AS Ratings
	   FROM sales
       GROUP BY  product_line;
       
-- Which branch sold more products than average products? --
SELECT 
     branch,
     SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);


-- What is the most common product line by gender? --
SELECT 
     gender,
     product_line,
     COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line? --
 SELECT
 	 ROUND(AVG(rating), 2) AS avg_rating,
     product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;     