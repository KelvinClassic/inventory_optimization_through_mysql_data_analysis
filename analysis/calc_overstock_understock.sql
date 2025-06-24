/*
=====================================================
CALCULATION OF OVERSTOCKING AND UNDERSTOCKING ITEMS
=====================================================
*/

WITH rolling_sales As (
	SELECT
		product_id,
		sales_date,
		AVG(inventory_quantity * product_cost) OVER (PARTITION BY product_id ORDER BY sales_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales
	FROM gold.inventory_table
),
-- Calculate the number of days a product was out of stock
stockout_days AS (
	SELECT 
		product_id,
		COUNT(*) AS stockout_days
	FROM gold.inventory_table
	WHERE inventory_quantity = 0
	GROUP BY product_id
)
-- Join the above CTEs with the main table to get the results
SELECT 
	m.product_id,
	ROUND(AVG(m.inventory_quantity * m.product_cost), 2) AS avg_inventory_value,
	ROUND(AVG(rs.rolling_avg_sales), 2) AS avg_rolling_sales,
	COALESCE(sd.stockout_days, 0) AS stockout_days
FROM gold.inventory_table m
JOIN rolling_sales rs ON m.product_id = rs.product_id AND m.sales_date = rs.sales_date
LEFT JOIN stockout_days sd ON m.product_id = sd.product_id
GROUP BY m.product_id, sd.stockout_days;