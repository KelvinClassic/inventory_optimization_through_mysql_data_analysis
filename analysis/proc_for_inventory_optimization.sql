/*
=================================================================================================
>> CREATION OF STORED PROCEDURE AND TRIGGER FOR THE RECALCULATION OF INVENTORY OPTIMIZATION <<
=================================================================================================
*/


-- Step 1: Create the inventory_optimization table
CREATE TABLE IF NOT EXISTS inventory_optimization(
	product_id INT,
    reorder_point DOUBLE
);

-- Step 2: Create the Stored Procedure to Recalculate Reorder Point
DELIMITER //
CREATE PROCEDURE recalculate_recorder_point(product_id_var INT)
BEGIN
	DECLARE avg_rolling_sales_var DOUBLE;
    DECLARE avg_rolling_variance_var DOUBLE;
    DECLARE lead_time_demand_var DOUBLE;
    DECLARE safety_stock_var DOUBLE;
    DECLARE record_point_var DOUBLE;
        
	SELECT 
		AVG(rolling_avg_sales) AS avg_rolling_sales, AVG(rolling_variance) AS avg_rolling_variance
	INTO avg_rolling_sales_var, avg_rolling_variance_var
	FROM (
		SELECT 
			product_id,
			AVG(daily_sales) OVER(PARTITION BY product_id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
			AVG(squared) OVER(PARTITION BY product_id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_variance
		FROM (
			SELECT 
				product_id,
				sales_date,
				inventory_quantity * product_cost AS daily_sales,
				(inventory_quantity * product_cost - AVG(inventory_quantity * product_cost) OVER(PARTITION BY product_id ORDER BY sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) * (inventory_quantity * product_cost - AVG(inventory_quantity * product_cost) OVER(PARTITION BY product_id ORDER BY sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared
			FROM gold.load_gold
		) inner_derived
	) outer_derived;
	SET lead_time_demand_var = avg_rolling_sales_var * 7;
    SET safety_stock_var = 1.645 * (avg_rolling_variance_var * 7);
    SET record_point_var = (avg_rolling_sales_var * 7) + (1.645 * (avg_rolling_variance_var * 7));
	
	INSERT INTO inventory_optimization (product_id, reorder_point)
		VALUES (product_id_var, record_point_var)
	ON DUPLICATE KEY UPDATE reorder_point = record_point_var;
END //
DELIMITER ;


-- Step 3: Make gold.load_gold a permanent table
CREATE TABLE IF NOT EXISTS gold.inventory_table AS SELECT * FROM gold.load_gold;

-- Step 4: Create Trigger
DELIMITER //
CREATE TRIGGER gold.after_insert_to_unified_table
AFTER INSERT ON gold.inventory_table
FOR EACH ROW
BEGIN
	CALL recalculate_recorder_point(NEW.product_id);
END //
DELIMITER ;
