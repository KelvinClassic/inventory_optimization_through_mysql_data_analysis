/*
DEFINITION OF THE SILVER LAYER
*/

CREATE SCHEMA IF NOT EXISTS silver; 

USE silver;

DROP TABLE IF EXISTS silver.sales;
CREATE TABLE silver.sales(
	product_id INT,
    sales_date DATE,
    inventory_quantity INT,
    product_cost DECIMAL(15, 2)
);

DROP TABLE IF EXISTS silver.inventory;
CREATE TABLE silver.inventory(
	product_id INT,
    sales_date DATE,
    inventory_quantity INT,
    product_cost INT,
    product_category VARCHAR(50),
    promotions VARCHAR(50),
    gdp FLOAT,
    inflation_rate INT,
    seasonal_factor INT
);

DROP TABLE IF EXISTS silver.external_factors;
CREATE TABLE silver.external_factors (
	 Sales_Date DATE, 
     GDP DECIMAL(15, 2) ,
     Inflation_Rate DECIMAL(15, 2),
     Seasonal_Factor DECIMAL(15, 2)
);


DROP TABLE IF EXISTS silver.product_information;
CREATE TABLE silver.product_information(
	product_id INT,
    product_category VARCHAR(50),
    promotions VARCHAR(10)
);