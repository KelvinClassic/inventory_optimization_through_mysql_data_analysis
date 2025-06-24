/*
 DEFINITION OF GOLD LAYER
 	Procedure
		- 
 		- Make sure to load inventory_data.csv after executing "USE gold" 
*/

-- Create gold schema
CREATE SCHEMA IF NOT EXISTS gold; 

-- Load data into gold layer
CREATE VIEW gold.load_gold AS
SELECT
	s.product_id, 
	s.sales_date, 
	s.inventory_quantity, 
	s.product_cost,
	p.product_category, 
	p.promotions,
	e.GDP AS gdp, 
	e.Inflation_Rate AS inflation_rate, 
	e.Seasonal_Factor AS seasonal_factor
FROM silver.sales s
LEFT JOIN silver.product_information p ON s.product_id = p.product_id
LEFT JOIN silver.external_factors e ON s.sales_date = e.Sales_Date;


-- Confirm Load

USE gold;

SELECT * FROM gold.load_gold;



