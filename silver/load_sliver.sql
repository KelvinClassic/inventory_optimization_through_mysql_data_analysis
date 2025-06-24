/*
 CREATE STORED PROCEDURE TO INSERT DATA FROM BRONZE TO SILVER LAYER
*/
-- Insert into silver.external_factors

delimiter //
CREATE PROCEDURE silver.load_silver
BEGIN
	INSERT INTO silver.external_factors (Sales_Date, GDP, Inflation_Rate, Seasonal_Factor)
	SELECT
		 Sales_Date,
		 GDP,
		 Inflation_Rate,
		 Seasonal_Factor
	FROM
	(SELECT
		 STR_TO_DATE(Sales_Date, '%d/%m/%Y') AS Sales_Date, 
		 ROW_NUMBER() OVER(PARTITION BY Sales_Date ORDER BY Sales_Date) AS rep2,
		 CAST(GDP AS DECIMAL(15, 2)) AS GDP,
		 CAST(Inflation_Rate AS DECIMAL(15, 2)) AS Inflation_Rate,
		 CAST(Seasonal_Factor AS DECIMAL(15, 2)) AS Seasonal_Factor
	FROM external_factors) AS tab2
	WHERE rep2 = 1; -- Handle duplicates;

	-- Insert into silver.product_information
	INSERT INTO silver.product_information (product_id, product_category, promotions)
	SELECT
		Product_ID,
		Product_Category,
		Promotions
	FROM 
	(SELECT
		Product_ID,
		ROW_NUMBER() OVER(PARTITION BY Product_ID ORDER BY Product_ID) rep,
		Product_Category,
		CASE WHEN Promotions = 'YES' THEN 'yes'
			 WHEN Promotions = 'NO' THEN 'no'
		ELSE NULL
		END Promotions
	FROM product_information) AS tab
	WHERE rep = 1; -- Handle duplicates;

	-- Insert into silver.sales
	INSERT INTO silver.sales (product_id, sales_date, inventory_quantity, product_cost)
	SELECT
		PRODUCT_ID,
		STR_TO_DATE(Sales_Date, '%d/%m/%Y') AS Sales_Date, -- Convert Sales_Date DataType to DATE
		Inventory_Quantity,
		CAST(Product_Cost AS DECIMAL(15, 2)) AS Product_Cost
	FROM sales
END;
delimiter //
