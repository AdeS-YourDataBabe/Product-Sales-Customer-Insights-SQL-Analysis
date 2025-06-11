--------------------------------------------------------------------------------------------------------------- 
-- 1. Which product categories generate the most revenue overall and which are underperforming?
--------------------------------------------------------------------------------------------------------------- 

SELECT 
		p.category AS category,
		CONCAT('$', SUM(f.sales_amount)) AS revenue
FROM 
		gold.dim_products p
INNER JOIN 
		gold.fact_sales f
	ON p.product_key = f.product_key
GROUP BY 
		category
ORDER BY 
		SUM(f.sales_amount) DESC; 

-- Insight: Bike sales lead with a significant margin in revenue (millions), while others lag behind in the thousands.

-- Note: The 'Component' category had no purchases recorded.

-- Suggestion: Conduct customer preference surveys and investigate competitors by region

--------------------------------------------------------
-- 1.1. Does Number of Subcategories Influence Revenue?
--------------------------------------------------------

SELECT
		category,
		COUNT(DISTINCT subcategory) AS no_of_subcategory
FROM gold.dim_products
GROUP BY category;

-- Insight: Although the 'Bike' category has the fewest subcategories, it generated the highest revenue

-------------------------------------------------------
-- 1.2. avg amount spent by customers for each category
-------------------------------------------------------
SELECT 
		p.category AS category,
		AVG(f.sales_amount) AS avg_amount_per_catg
FROM 
		gold.dim_products p
INNER JOIN 
		gold.fact_sales f
	ON p.product_key = f.product_key
GROUP BY 
		category
ORDER BY 
		avg_amount_per_catg DESC; 

-- Insight: Customers spend the most per transaction on Bike products.

--------------------------------------
-- 1.3. Number of orders for each category
---------------------------------------

SELECT 
		p.category AS category,
		COUNT(f.order_number) AS num_of_orders_per_catg
FROM 
		gold.dim_products p
INNER JOIN 
		gold.fact_sales f
	ON p.product_key = f.product_key
GROUP BY 
		category
ORDER BY 
		COUNT(f.order_number) DESC; 

-- Insight: Accessories have the highest number of orders.

-- Observation: Despite high order volume, lower average purchase value results in lower total revenue for accessories compared to bikes.

--------------------------------------------------------------------------------------------------------------- 
-- 2. What are the top 5 products by total sales, and how do their quantities sold compare to revenue generated?
--------------------------------------------------------------------------------------------------------------- 

SELECT TOP 5
		p.product_name AS product_name,
		SUM(f.sales_amount) AS total_sales,
		SUM(f.quantity) AS total_quantity
FROM 
		gold.dim_products p
LEFT JOIN 
		gold.fact_sales f
	ON p.product_key = f.product_key
GROUP BY 
		p.product_name
ORDER BY 
		total_sales DESC;

-- Insight: The top products by revenue also tend to have high quantities sold.

-- However, earlier analysis indicates this trend does not hold consistently across categories.

-- Check for correlation between revenue and quantity using Pearson correlation coefficient

SELECT 
   ROUND((COUNT(*) * SUM(CAST(sales_amount AS FLOAT) * CAST(quantity AS FLOAT)) 
        - SUM(CAST(sales_amount AS FLOAT)) * SUM(CAST(quantity AS FLOAT))) /
    (SQRT(COUNT(*) * SUM(CAST(sales_amount AS FLOAT) * CAST(sales_amount AS FLOAT)) 
        - POWER(SUM(CAST(sales_amount AS FLOAT)), 2)) *
     SQRT(COUNT(*) * SUM(CAST(quantity AS FLOAT) * CAST(quantity AS FLOAT)) 
        - POWER(SUM(CAST(quantity AS FLOAT)), 2))), 3) AS correlation
FROM gold.fact_sales; 

-- Result: -0.004 — indicates no linear correlation between quantity sold and revenue.

--------------------------------------------------------------------------------------------------------------- 
-- 3. Which customer segments (e.g., by country, gender, or marital status) are contributing most to revenue?
---------------------------------------------------------------------------------------------------------------  

------------------
-- 3.1. Country
------------------

SELECT
		c.country AS country,
		SUM(f.sales_amount) AS revenue
FROM 
		gold.dim_customers c
LEFT JOIN 
		gold.fact_sales f
	ON c.customer_key = f.customer_key
GROUP BY 
		c.country
ORDER BY
		revenue DESC;

-- Insight: United States and Australia contribute the most revenue, with the UK following at a distance.

-- Suggestion: Further analysis on purchasing behavior by region may help explain this trend

------------------
--3.2. Gender
------------------

SELECT
		c.gender AS gender,
		SUM(f.sales_amount) AS revenue
FROM 
		gold.dim_customers c
LEFT JOIN 
		gold.fact_sales f
	ON c.customer_key = f.customer_key
WHERE 
		gender != 'n/a'
GROUP BY 
		c.gender
ORDER BY
		revenue DESC;

-- Insight: Female customers contribute slightly more revenue than male customers.

-----------------------
-- 3.3. Marital Status
-----------------------

SELECT
		c.marital_status AS marital_status,
		SUM(f.sales_amount) AS revenue
FROM 
		gold.dim_customers c
LEFT JOIN 
		gold.fact_sales f
	ON c.customer_key = f.customer_key
GROUP BY 
		c.marital_status
ORDER BY
		revenue DESC;

-- Insight: Married customers contribute the highest revenue.

--------------------------------------------------------------------------------------------------------------- 
-- 4. What is the average order value across different customer demographics (age group, country)?
--------------------------------------------------------------------------------------------------------------- 

----------------------
-- 4.1. Age Group
----------------------

WITH ages 
	AS (
SELECT 
		*,
		DATEDIFF(YEAR, birthdate, GETDATE()) 
		- CASE 
            WHEN MONTH(birthdate) > MONTH(GETDATE()) 
                 OR (MONTH(birthdate) = MONTH(GETDATE()) AND DAY(birthdate) > DAY(GETDATE()))
            THEN 1 
            ELSE 0 
          END AS age
FROM 
		gold.dim_customers
), 

age_groups 
	AS (
SELECT
		*, 
		CASE
			WHEN age <= 69 THEN 'Adult'
			WHEN age >= 70 THEN 'Old'
		END AS age_group
FROM 
		ages
), 

orders_per_age_grp
	AS(
SELECT 
		f.order_number AS order_number,
		f.sales_amount AS sales_amount,
		age_group
FROM 
		age_groups a
LEFT JOIN 
		gold.fact_sales f
	ON 
		a.customer_key = f.customer_key
WHERE 
		age_group IS NOT NULL
),

total_revenue 
	AS(
SELECT 
		order_number,
		age_group,
		SUM(sales_amount) AS total_amount
FROM 
		orders_per_age_grp
GROUP BY 
		order_number, age_group
)

SELECT 
		age_group,
		AVG(total_amount) AS avg_order_value
FROM 
		total_revenue
GROUP BY 
		age_group;

-- Insight: Adults have a higher average order value than older customers.

----------------------
-- 4.2. Country
----------------------

WITH total_revenue AS
(
SELECT 
		c.country AS country,
		f.order_number AS order_number,
		SUM(f.sales_amount) AS sales_amount
FROM 
		gold.dim_customers c
LEFT JOIN 
		gold.fact_sales f
	ON 
		c.customer_key = f.customer_key
GROUP BY 
		country,
		order_number
) 

SELECT 
		country,
		AVG(sales_amount) AS avg_order_value_per_country
FROM 
		total_revenue 
GROUP BY 
		country
ORDER BY avg_order_value_per_country DESC;

-- Insight: Australia has the highest average order value per customer.

--------------------------------------------------------------------------------------------------------------- 
-- 5. What is the trend of monthly sales over time — are there seasonal patterns or declines?
--------------------------------------------------------------------------------------------------------------- 

SELECT 
		DATEPART(month, order_date) AS #, 
		FORMAT(order_date, 'MMM') AS month_name,
		SUM(sales_amount) AS monthly_sales_amount,
		RANK() OVER(ORDER BY SUM(sales_amount) DESC) AS seasonal_pattern
FROM 
		gold.fact_sales
WHERE 
		YEAR(order_date) = 2013
GROUP BY 
		DATEPART(month, order_date), 
		FORMAT(order_date, 'MMM')
ORDER BY 
		# ASC;

-- Insight: Sales increase mid-year and peak in December, showing clear seasonal patterns.

-- Observation: Sales in 2013 showed a strong upward trend toward year-end.