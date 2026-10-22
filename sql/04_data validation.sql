-- Data Validation

-- Validate yearly sales
SELECT
YEAR(OrderDate) AS OrderYear,
CAST(SUM(UnitSalesPrice * Quantity) AS INT) AS TotalRevenue,
COUNT(Distinct CustNum) AS CustomerNumber,
SUM(Quantity) AS TotalQuantity
From pet.vw_GlobalSales gs
GROUP BY YEAR(OrderDate)
ORDER BY YEAR(OrderDate) DESC;

-- Validate monthly sales
SELECT
DATETRUNC(month,orderdate) AS OrderDate,
CAST(SUM(UnitSalesPrice * Quantity) AS INT) AS TotalRevenue,
COUNT(Distinct CustNum) AS CustomerNumber,
SUM(Quantity) AS TotalQuantity
From pet.vw_GlobalSales gs
GROUP BY DATETRUNC(month,orderdate)
ORDER BY DATETRUNC(month,orderdate) DESC;

-- Validate sales by region
SELECT 
CASE WHEN LEFT(ds.StoreRegion,2) = 'Au' THEN 'AU'
	 WHEN LEFT(ds.StoreRegion,2) = 'Eu' THEN 'EU'
	 ELSE 'Unknown'
END AS Region,
YEAR(OrderDate) Year,
CAST(SUM(Revenue) AS INT) TotalRevenue,
CAST(SUM(SUM(Revenue)) OVER() AS INT) AllTotal
FROM pet.vw_GlobalSales gs
LEFT JOIN pet.dim_store ds
ON gs.StoreNum = ds.StoreNumber
GROUP BY 
	 CASE WHEN LEFT(ds.StoreRegion,2) = 'Au' THEN 'AU'
		  WHEN LEFT(ds.StoreRegion,2) = 'Eu' THEN 'EU'
		  ELSE 'Unknown'
	 END,
     YEAR(OrderDate)	 
ORDER BY 
	   CASE WHEN LEFT(ds.StoreRegion,2) = 'Au' THEN 'AU'
		  WHEN LEFT(ds.StoreRegion,2) = 'Eu' THEN 'EU'
		  ELSE 'Unknown'
	   END,
	   YEAR(OrderDate) DESC;

-- Check duplicate transaction numbers from GlobalSales
SELECT
TransactionNum,
COUNT(*) NumberOfRows
FROM pet.vw_GlobalSales gs
GROUP BY TransactionNum
HAVING COUNT(*)>1
ORDER BY TransactionNum;

-- -- Check for source transactions missing from the global sales view
WITH SourceTransactions AS(
SELECT
TransactionNum
FROM pet.fact_AUsales
UNION All
SELECT
TransactionNum
FROM pet.fact_EUsales)

SELECT
TransactionNum
FROM SourceTransactions

EXCEPT

SELECT
TransactionNum
FROM pet.vw_GlobalSales;

-- Check for unexpected transactions in the global sales view 
WITH SourceTransactions AS(
SELECT
TransactionNum
FROM pet.fact_AUsales
UNION All
SELECT
TransactionNum
FROM pet.fact_EUsales)

SELECT
TransactionNum
FROM pet.vw_GlobalSales

EXCEPT

SELECT
TransactionNum
FROM SourceTransactions;

-- Check duplicate CategoryID from ProductDetail
SELECT
CategoryID,
COUNT(*) CountOfRow
FROM pet.dim_ProductDetail
GROUP BY CategoryID
HAVING COUNT(*) > 1;




