/*
============================
INFLUENCE OF EXTERNAL FACTORS 
============================
*/

-- GDP Influence
SELECT  
product_id,
AVG(CASE WHEN GDP > 0 THEN inventory_quantity ELSE NULL END) AS avg_sales_positive_gdp,
AVG(CASE WHEN GDP <= 0 THEN inventory_quantity ELSE NULL END) AS avg_sales_non_positive_gdp
FROM gold.load_gold
GROUP BY product_id
HAVING avg_sales_positive_gdp IS NOT NULL;

-- Inflation Influence
SELECT  
product_id,
AVG(CASE WHEN Inflation_Rate > 0 THEN inventory_quantity ELSE NULL END) AS avg_sales_positive_inflation,
AVG(CASE WHEN Inflation_Rate <= 0 THEN inventory_quantity ELSE NULL END) AS avg_sales_non_positive_inflation
FROM gold.load_gold
GROUP BY product_id
HAVING avg_sales_positive_inflation IS NOT NULL;
