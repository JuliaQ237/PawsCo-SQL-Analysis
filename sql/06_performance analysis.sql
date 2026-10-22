/*
Performance Analysis (Year-over-Year, Month-over-Month)

Purpose:
    - Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales
    - Measure the performance of products, customers, or regions over time.
    - Identifying high-performing products.
    - Track yearly trends and growth.

Techniques:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
*/

-- Data quality check - to make sure no product cost is missing
   		
SELECT DISTINCT 
gs.ProductCode
FROM pet.vw_GlobalSales gs
LEFT JOIN pet.dim_product dp
ON gs.ProductCode = dp.ProductCode
WHERE dp.ProductCode IS NULL;

-- Product Performance Analysis

WITH BasicQuery AS(
SELECT
    gs.ProductCode,
    gs.Quantity,
    gs.Revenue,
    gs.OrderDate,
    gs.UnitSalesPrice,
    dp.ProductName,
    dp.UnitRetailPrice,
    dp.UnitRetailPrice * gs.Quantity AS RetailValue,
    dp.UnitCost,
    dp.UnitCost * gs.Quantity AS TotalCost,
    gs.Revenue - dp.UnitCost * gs.Quantity AS Profit
FROM pet.vw_GlobalSales AS gs
LEFT JOIN pet.dim_product AS dp
ON gs.ProductCode = dp.ProductCode
WHERE YEAR(OrderDate) >= (
      SELECT
      MAX(YEAR(OrderDate))-4
      FROM pet.vw_GlobalSales)
),
ProductSales AS (
SELECT
    Year(OrderDate) SalesYear,
    ProductName,
    SUM(RetailValue) AS TotalRetailValue,
    SUM(Quantity) AS TotalQuantity,
    SUM(Revenue) AS TotalRevenue,
    SUM(TotalCost) AS TotalCost,
    SUM(Profit) AS TotalProfit
FROM BasicQuery
GROUP BY 
    ProductName,
    Year(OrderDate)
    
),
Metrics AS (
SELECT
    ProductName,
    SalesYear,
    TotalQuantity,
    TotalRevenue,
    TotalCost,
    TotalProfit,
    (TotalRetailValue - TotalRevenue) / TotalRetailValue AS EstimatedDiscountRate,
    AVG(TotalProfit) OVER(PARTITION BY ProductName) AvgProfit,
    MAX(TotalRevenue) OVER(PARTITION BY ProductName) LargestRevenue,
    MIN(TotalRevenue) OVER(PARTITION BY ProductName) SmallestRevenue,
    LAG(TotalRevenue) OVER(PARTITION BY ProductName ORDER BY SalesYear) PreviousYearRevenue,
    LAG(TotalProfit) OVER(PARTITION BY ProductName ORDER BY SalesYear) PreviousYearProfit
FROM ProductSales
)
SELECT
ProductName,
SalesYear,
TotalQuantity,
TotalRevenue,
LargestRevenue,
LargestRevenue - TotalRevenue AS GapFromLargestRevenue,
PreviousYearRevenue,
CAST((TotalRevenue - PreviousYearRevenue) * 100.0 / NULLIF(ABS(PreviousYearRevenue),0) AS DECIMAL(18,2))AS YOYRevenueChangePct,
CASE WHEN PreviousYearRevenue IS NULL THEN 'No prior year data'
     WHEN TotalRevenue > PreviousYearRevenue THEN 'Above PY'
     WHEN TotalRevenue < PreviousYearRevenue THEN 'Below PY'
     ELSE 'No change'
END AS RevenueTrend,
TotalCost,
TotalProfit,
CAST(EstimatedDiscountRate * 100.0 AS DECIMAL(10,2)) AS EstimatedDiscountRate,
CAST(AvgProfit AS DECIMAL(10,2)) AS ProductAvgProfit,
CASE WHEN TotalProfit < 0 THEN 'Loss'
     WHEN TotalProfit > AvgProfit THEN 'Above Average'
ELSE 'Below Average'
END AS Profitability,
PreviousYearProfit,
CAST((TotalProfit - PreviousYearProfit) * 100.0/ NULLIF(ABS(PreviousYearProfit),0) AS DECIMAL(10,2)) AS YOYProfitChangePct,
CASE WHEN PreviousYearProfit IS NULL THEN 'No prior year data'
     WHEN PreviousYearProfit <= 0 AND TotalProfit >0 THEN 'Turned profitable'
     WHEN PreviousYearProfit >0 AND TotalProfit <=0 THEN 'Turned into loss'
     WHEN TotalProfit > PreviousYearProfit THEN 'Improved'
     WHEN TotalProfit < PreviousYearProfit THEN 'Declined'
     ELSE 'No change'
END AS ProfitTrend
FROM Metrics
ORDER BY 
      ProductName,
      SalesYear;