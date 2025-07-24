/*
============================
INVENTORY OPTIMIZATION
============================
---------------------------------------------------------------------------------------------------------------
>> Determine the optimal reorder point for each product based on historical sales data and external factors <<
Definition of parameters:
		- 'Reorder Point' is the level at which new order should be placed
        - 'Lead Time' the duration between placing an order for inventory and the actual receipt of that inventory
        - 'Safety Stock' is an extra buffer stock to account for vulnarability in the demand and supply 
        - Reorder point = Lead Time Demand + Safety Stock
        - Lead Time Demand = Rolling Average Sales * Lead Time
        - Safety Stock = Z * (Lead Time)^2 * Standard Deviation of Demand
        - Z = 1.645
        - A constant Lead Time of 7 days for all products
        - We aim for a 95% service level
        
        >> Formula in Summary <<
        - Reorder point = (Rolling Average Sales * Lead Time) + (Z * (Lead Time)^2 * Standard Deviation of Demand)
        
------------------------------------------------------------------------------------------------------------------
*/
-- 

WITH inventory_calculations AS (
	SELECT 
		product_id,
		AVG(rolling_avg_sales) AS avg_rolling_sales,
		AVG(rolling_variance) AS avg_rolling_variance
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
		) subquery_1
	) subquery_2
    GROUP BY product_id
)

SELECT 
product_id,
ROUND(avg_rolling_sales * 7, 2) AS lead_time_demand,
ROUND(1.645 * (avg_rolling_variance * 7), 2) AS safety_stock,
ROUND((avg_rolling_sales * 7) + (1.645 * (avg_rolling_variance * 7)), 2) AS reorder_point
FROM inventory_calculations;