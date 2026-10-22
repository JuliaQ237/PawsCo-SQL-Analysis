/*
Customer Report — Latest Three Calendar Years

Purpose:
- Aggregate customer-level sales and transaction metrics.
- Segment customers by spending and relationship length.
- Categorise customers into age groups.
- Calculate recency, average order value and average monthly spend.

Grain:
- One row per customer.

Segmentation period:
- Metrics are based on all available history
  in the sales dataset.
*/

-- Basic Query: retrive customer detail from tables

WITH BasicQuery AS (
SELECT
gs.TransactionNum,
gs.CustNum AS CustomerNum,
gs.Revenue,
gs.Quantity,
gs.OrderDate,
CONCAT(dc.FirstName,' ',COALESCE(dc.LastName,'')) AS CustomerName,
DATEDIFF(year,dc.Birthdate,GETDATE()) AS CustomerAge
FROM pet.vw_GlobalSales gs
LEFT JOIN pet.dim_customer dc
ON gs.CustNum = dc.CustNum

),
-- Aggregation at customer level
CustomerSpending AS (
SELECT
CustomerNum,
CustomerName,
CustomerAge,
COUNT(DISTINCT TransactionNum) AS TotalOrder,
SUM(Revenue) AS TotalRevenue,
SUM(Quantity) AS TotalQuantity,
MIN(OrderDate) AS FirstOrder,
MAX(OrderDate) AS LastOrder,
DATEDIFF(month,MIN(OrderDate),MAX(OrderDate)) AS Lifespan
FROM BasicQuery
GROUP BY CustomerNum,
         CustomerName,
         CustomerAge
)
--Segment Customer into categories (VIP, Regular,New), age groups and calculate key metircs

SELECT
CustomerNum,
CustomerName,
CASE WHEN CustomerAge IS NULL THEN 'Unknown'
     WHEN CustomerAge < 20 THEN 'Under 20'
     WHEN CustomerAge BETWEEN 20 AND 29 THEN '20-29'
     WHEN CustomerAge BETWEEN 30 AND 39 THEN '30-39'
     WHEN CustomerAge BETWEEN 40 AND 49 THEN '40-49'
     ELSE '50 and above'
END AS AgeGroup,
CASE WHEN Lifespan >= 12 AND TotalRevenue > 10000 THEN 'VIP'
     WHEN Lifespan >= 12 AND TotalRevenue <= 10000 THEN 'Regular'
     ELSE 'New'
END AS CustomerSegment,
DATEDIFF(month,LastOrder,GETDATE()) Recency,
Lifespan,
TotalQuantity,
TotalRevenue,
TotalOrder,
CAST(TotalRevenue / NULLIF(TotalOrder,0) AS DECIMAL(18,2)) AS AvgOrderValue,
CAST(TotalRevenue / (DATEDIFF(month,FirstOrder,LastOrder)+1) AS DECIMAL(18,2)) AS AvgMonthlySpend
FROM CustomerSpending
ORDER BY TotalRevenue DESC;


