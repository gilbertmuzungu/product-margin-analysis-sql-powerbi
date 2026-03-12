
-- COMBINING Order years

With all_orders AS (

SELECT
OrderID,
CustomerID,
ProductID,
OrderDate,
Quantity,
Revenue,
COGS
FROM orders_2023

Union all

SELECT
OrderID,
CustomerID,
ProductID,
OrderDate,
Quantity,
Revenue,
COGS
FROM orders_2024

Union all

SELECT
OrderID,
CustomerID,
ProductID,
OrderDate,
Quantity,
Revenue,
COGS
FROM orders_2025

)
--  Building the main dataset query

SELECT 
a.OrderID,
a.CustomerID,
c.Region,
a.ProductID,
a.OrderDate,
c.CustomerJoinDate,
a.Quantity,
a.Revenue,
CASE when a.Revenue is null then p.price*a.Quantity else a.Revenue End AS Cleaned_Revenue,
Round(a.Revenue - a. COGS, 2) AS Profit,
a.COGS,
p.ProductName,
p.ProductCategory,
p.Price,
p.Base_Cost
FROM all_orders a 
Left JOIN customers c
ON a.CustomerID = c.CustomerID
Left Join products  p
ON a.ProductID = p.ProductID
WHERE a.CustomerID IS NOT NULL;





