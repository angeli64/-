-- 确认当前数据库
CREATE DATABASE manufacturing_sales;
USE manufacturing_sales;
SELECT DATABASE();

-- 创建表
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    order_date DATE,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    unit_price DECIMAL(10, 2),
    order_status VARCHAR(20),
    sales_person VARCHAR(50),
    channel VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_cost DECIMAL(10, 2),
    standard_price DECIMAL(10, 2),
    supplier VARCHAR(100)
);
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    region VARCHAR(50),
    province VARCHAR(50),
    customer_type VARCHAR(50),
    credit_level VARCHAR(10)
);
CREATE TABLE cost_details (
    order_id VARCHAR(20) PRIMARY KEY,
    material_cost DECIMAL(12, 2),
    labor_cost DECIMAL(12, 2),
    manufacturing_cost DECIMAL(12, 2),
    logistics_cost DECIMAL(12, 2),
    other_cost DECIMAL(12, 2)
);

-- 插入数据
/*
检查环境先运行下面语句
SHOW VARIABLES LIKE 'local_infile';
如果为OFF，启用local_infile
SET GLOBAL local_infile = 1;
*/

-- 导入customers
LOAD DATA INFILE 'D:/MySQLData/Uploads/customers.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- 导入products
LOAD DATA INFILE 'D:/MySQLData/Uploads/products.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- 导入orders
LOAD DATA INFILE 'D:/MySQLData/Uploads/orders.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- 导入cost_details
LOAD DATA INFILE 'D:/MySQLData/Uploads/cost_details.csv'
INTO TABLE cost_details
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- 构建销售成本分析宽表
CREATE VIEW v_sales_cost_fact AS
SELECT 
    o.order_id,
    o.order_date,
    o.customer_id,
    c.customer_name,
    c.region,
    p.product_id,
    p.product_name,
    p.category,
    o.quantity,
    o.unit_price,

    COALESCE(cd.material_cost, 0) AS material_cost,
    COALESCE(cd.labor_cost, 0) AS labor_cost,
    COALESCE(cd.manufacturing_cost, 0) AS manufacturing_cost,
    COALESCE(cd.logistics_cost, 0) AS logistics_cost,
    COALESCE(cd.other_cost, 0) AS other_cost,

    o.quantity * o.unit_price AS revenue,

    COALESCE(cd.material_cost, 0)
    + COALESCE(cd.labor_cost, 0)
    + COALESCE(cd.manufacturing_cost, 0)
    + COALESCE(cd.logistics_cost, 0)
    + COALESCE(cd.other_cost, 0) AS total_cost,

    o.quantity * o.unit_price
    - (
        COALESCE(cd.material_cost, 0)
        + COALESCE(cd.labor_cost, 0)
        + COALESCE(cd.manufacturing_cost, 0)
        + COALESCE(cd.logistics_cost, 0)
        + COALESCE(cd.other_cost, 0)
      ) AS profit,

    (
        o.quantity * o.unit_price
        - (
            COALESCE(cd.material_cost, 0)
            + COALESCE(cd.labor_cost, 0)
            + COALESCE(cd.manufacturing_cost, 0)
            + COALESCE(cd.logistics_cost, 0)
            + COALESCE(cd.other_cost, 0)
          )
    ) / NULLIF(o.quantity * o.unit_price, 0) AS gross_margin_rate

FROM orders o 
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN products p ON o.product_id = p.product_id
LEFT JOIN cost_details cd ON o.order_id = cd.order_id
WHERE o.order_status = '已完成'
  AND o.quantity > 0
  AND o.unit_price > 0;


