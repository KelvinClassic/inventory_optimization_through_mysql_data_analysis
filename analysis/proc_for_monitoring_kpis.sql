/*
============================
CREATE PROCEDURES FOR MONITORING
============================
*/

-- Monitor inventory levels
DELIMITER //
CREATE PROCEDURE monitor_inventory_levels()
BEGIN
	SELECT 
		product_id,
		AVG(inventory_quantity) AS avg_inventory
	FROM gold.inventory_table
    GROUP BY product_id
    ORDER BY avg_inventory DESC;
END //
DELIMITER ;

-- Monitor sales trends
DELIMITER //
CREATE PROCEDURE monitor_sales_trends()
BEGIN
	SELECT 
		product_id, 
        sales_date,
		AVG(inventory_quantity * product_cost) OVER (PARTITION BY product_id ORDER BY sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales
	FROM gold.inventory_table
    ORDER BY product_id, sales_date;
END //
DELIMITER ;

-- Monitor stockout frequencies
DELIMITER //
CREATE PROCEDURE monitor_stockouts()
BEGIN
	SELECT 
		product_id, 
        COUNT(*) AS stockout_days
	FROM gold.inventory_table
    WHERE inventory_quantity = 0
    GROUP BY product_id;
END //
DELIMITER ;