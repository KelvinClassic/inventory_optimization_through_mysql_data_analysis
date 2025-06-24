/*
============================
DESCRIPTIVE ANALYSIS
============================
*/

USE gold;

-- Calculate the average sales by product_id
SELECT 
product_id,
CAST(AVG(inventory_quantity * product_cost) AS DECIMAL(7, 2)) AS avg_sales
FROM gold.load_gold
GROUP BY product_id
ORDER BY avg_sales DESC;

-- Median stock levels (i.e., Inventory Quantity)
SELECT product_id, ROUND(AVG(inventory_quantity)) AS median_stock
FROM
(
SELECT 
	product_id, 
	inventory_quantity,
    ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY inventory_quantity) AS row_num_asc,
    ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY inventory_quantity DESC) AS row_num_desc
FROM gold.load_gold
) AS subquery
WHERE row_num_asc IN (row_num_desc, row_num_desc - 1, row_num_desc + 1)
GROUP BY product_id;

-- Product performance metrics (total sales by product)
SELECT 
product_id, 
ROUND(SUM(inventory_quantity * product_cost)) AS total_sales_by_product
FROM gold.load_gold
GROUP BY product_id
ORDER BY total_sales_by_product DESC;

-- Identify high demand products based on average sales
WITH high_demand AS (
	SELECT product_id, AVG(inventory_quantity) AS avg_sales
	FROM gold.load_gold
	GROUP BY product_id
	HAVING avg_sales > (
		SELECT AVG(inventory_quantity) * 0.95 FROM gold.load_gold -- business rule
        )
)
-- Calculate stockout frequency for high-demand products
SELECT product_id,
COUNT(*) AS stockout_frequency
FROM gold.load_gold s
WHERE s.product_id IN (SELECT product_id FROM high_demand)
AND s.inventory_quantity = 0
GROUP BY s.product_id;







