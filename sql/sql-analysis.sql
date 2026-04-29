-- 产品分析
SELECT 
    product_id,
    product_name,
    category,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit,
    SUM(profit) / NULLIF(SUM(revenue), 0) AS gross_margin_rate
FROM v_sales_cost_fact
GROUP BY product_id, product_name, category
ORDER BY total_profit DESC;

SELECT 
    region,
    SUM(revenue) AS region_revenue,
    SUM(profit) AS region_profit,
    SUM(profit) / NULLIF(SUM(revenue), 0) AS gross_margin_rate
FROM v_sales_cost_fact
GROUP BY region
ORDER BY region_revenue DESC;

-- 问题产品分析：高销量低利润
SELECT
    product_id,
    product_name,
    category,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit,
    SUM(profit) / NULLIF(SUM(revenue), 0) AS gross_margin_rate
FROM v_sales_cost_fact
GROUP BY product_id, product_name, category
HAVING SUM(quantity) > 1000 
    AND SUM(profit) / NULLIF(SUM(revenue), 0) < 0.20
ORDER BY total_quantity DESC;
-- 区域分析
SELECT
    region,
    product_id,
    product_name,
    category, 
    SUM(quantity) AS region_product_quantity,
    SUM(revenue) AS region_product_revenue,
    SUM(profit) AS region_product_profit,
    SUM(profit) / NULLIF(SUM(revenue), 0) AS region_product_gross_margin_rate
FROM v_sales_cost_fact
GROUP BY region, product_id, product_name, category
ORDER BY region, region_product_revenue DESC;

-- 时间趋势分析
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS monthly_orders,
    SUM(quantity) AS monthly_quantity,
    SUM(revenue) AS monthly_revenue,
    SUM(profit) AS monthly_profit,
    SUM(profit) / NULLIF(SUM(revenue), 0) AS monthly_gross_margin_rate
FROM v_sales_cost_fact
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY DATE_FORMAT(order_date, '%Y-%m');

-- 客户分析
SELECT
    customer_id,
    customer_name,
    credit_level,
    COUNT(DISTINCT order_id) AS customer_orders,
    SUM(quantity) AS customer_quantity,
    SUM(revenue) AS customer_revenue,
    SUM(profit) AS customer_profit,
    SUM(profit) / NULLIF(SUM(revenue), 0) AS customer_gross_margin_rate
FROM v_sales_cost_fact
GROUP BY customer_id, customer_name, credit_level
ORDER BY customer_revenue DESC;

-- TOP客户收入占比
WITH ranked AS (
    SELECT
        customer_id,
        SUM(revenue) AS customer_revenue
    FROM v_sales_cost_fact
    GROUP BY customer_id
    ORDER BY customer_revenue DESC
    LIMIT 10
)
SELECT
    SUM(customer_revenue) / NULLIF((SELECT SUM(revenue) FROM v_sales_cost_fact), 0) AS top_10_customers_revenue_ratio
FROM ranked;

-- 成本分析
-- 整体成本结构分析
SELECT
    SUM(material_cost) / NULLIF(SUM(total_cost), 0) AS material_cost_ratio,
    SUM(labor_cost) / NULLIF(SUM(total_cost), 0) AS labor_cost_ratio,
    SUM(manufacturing_cost) / NULLIF(SUM(total_cost), 0) AS manufacturing_cost_ratio,
    SUM(logistics_cost) / NULLIF(SUM(total_cost), 0) AS logistics_cost_ratio,
    SUM(other_cost) / NULLIF(SUM(total_cost), 0) AS other_cost_ratio
FROM v_sales_cost_fact;

-- 产品维度成本结构分析
SELECT
    product_id,
    product_name,
    category,
    SUM(total_cost) AS total_cost,
    SUM(material_cost) / NULLIF(SUM(total_cost), 0) AS material_cost_ratio,
    SUM(labor_cost) / NULLIF(SUM(total_cost), 0) AS labor_cost_ratio,
    SUM(manufacturing_cost) / NULLIF(SUM(total_cost), 0) AS manufacturing_cost_ratio,
    SUM(logistics_cost) / NULLIF(SUM(total_cost), 0) AS logistics_cost_ratio,
    SUM(other_cost) / NULLIF(SUM(total_cost), 0) AS other_cost_ratio
FROM v_sales_cost_fact
GROUP BY product_id, product_name, category
ORDER BY total_cost DESC;

-- 低毛利产品成本结构分析
SELECT
    SUM(material_cost) / NULLIF(SUM(total_cost), 0) AS material_ratio,
    SUM(labor_cost) / NULLIF(SUM(total_cost), 0) AS labor_ratio,
    SUM(manufacturing_cost) / NULLIF(SUM(total_cost), 0) AS manufacturing_ratio,
    SUM(logistics_cost) / NULLIF(SUM(total_cost), 0) AS logistics_ratio,
    SUM(other_cost) / NULLIF(SUM(total_cost), 0) AS other_ratio
FROM v_sales_cost_fact
WHERE product_id IN (
    SELECT product_id
    FROM v_sales_cost_fact
    GROUP BY product_id
    HAVING SUM(profit) / NULLIF(SUM(revenue), 0) < 0.15
);
