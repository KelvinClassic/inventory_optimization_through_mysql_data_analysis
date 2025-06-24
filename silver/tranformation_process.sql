/*
 DATA CLEANING AND TRANSFORMATION
*/
-- Create Scehma
CREATE SCHEMA deright_click;


DROP TABLE IF EXISTS product_information;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS external_factors;
DROP TABLE IF EXISTS sales;

USE deright_click;

-- Data Exploration
SELECT * FROM sales LIMIT 4;
SELECT * FROM inventory LIMIT 4;
SELECT * FROM external_factors LIMIT 4;
SELECT * FROM product_information LIMIT 4;

-- Confirm datasets
SHOW COLUMNS FROM product_information;
DESCRIBE inventory;
DESCRIBE sales;
SHOW COLUMNS FROM inventory;

-- Check for missing values in external_factors table
SELECT
SUM(CASE WHEN Sales_Date IS NULL THEN 1 ELSE 0 END) AS Missing_sales_data,
SUM(CASE WHEN GDP IS NULL THEN 1 ELSE 0 END) AS Missing_sales_data,
SUM(CASE WHEN Inflation_Rate IS NULL THEN 1 ELSE 0 END) AS Missing_sales_data,
SUM(CASE WHEN Seasonal_Factor IS NULL THEN 1 ELSE 0 END) AS Missing_sales_data
FROM external_factors;

-- Check for missing values in product_information table
SELECT
SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Product_Category,
SUM(CASE WHEN Product_Category IS NULL THEN 1 ELSE 0 END) AS Missing_Promotions,
SUM(CASE WHEN Promotions IS NULL THEN 1 ELSE 0 END) AS Missing_product_information
FROM product_information;

-- Check for missing values in sales table
SELECT
SUM(CASE WHEN PRODUCT_ID IS NULL THEN 1 ELSE 0 END) AS Missing_PRODUCT_ID,
SUM(CASE WHEN Sales_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Sales_Date,
SUM(CASE WHEN Inventory_Quantity IS NULL THEN 1 ELSE 0 END) AS Missing_Inventory_Quantity,
SUM(CASE WHEN Product_Cost IS NULL THEN 1 ELSE 0 END) AS Missing_Product_Cost
FROM sales;

-- Check for duplicate values in external_factors table
SELECT COUNT(count) total_no_of_duplicates 
FROM (
SELECT Sales_Date, COUNT(*) AS count
FROM external_factors
GROUP BY Sales_Date
HAVING count > 1
) t;

-- Check for duplicate values in product_information table
SELECT COUNT(count) total_no_of_duplicates 
FROM (
SELECT Product_ID, COUNT(*) AS count
FROM product_information
GROUP BY Product_ID
HAVING count > 1
) t;

-- Check for duplicate values in Sales table
SELECT COUNT(count) total_no_of_duplicates 
FROM (
SELECT PRODUCT_ID, Sales_Date, COUNT(*) AS count
FROM Sales
GROUP BY PRODUCT_ID, Sales_Date
HAVING count > 1
) t;