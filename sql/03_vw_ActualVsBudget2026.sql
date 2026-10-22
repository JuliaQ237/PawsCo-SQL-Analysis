-- Create a resuable view for comparison between Actual and Budget
CREATE VIEW pet.vw_ActualVsBudget2026 AS
WITH BudgetSales AS(
SELECT
DATETRUNC(month,BudgetMonth) SalesMonth,
StoreNum,
ProductCode,
SUM(BudgetRevenue)  BudgetRevenue
FROM pet.fact_budget
WHERE YEAR(DATETRUNC(month,BudgetMonth)) = 2026
GROUP BY DATETRUNC(month,BudgetMonth),
		 StoreNum,
		 ProductCode
),
ActualSales AS(
SELECT
DATETRUNC(month,OrderDate) SalesMonth,
StoreNum,
ProductCode,
SUM(Revenue) AS ActualRevenue
FROM pet.vw_GlobalSales
WHERE YEAR(DATETRUNC(month,OrderDate)) = 2026
GROUP BY DATETRUNC(month,OrderDate),
		 StoreNum,
		 ProductCode
)
SELECT
COALESCE(bs.SalesMonth,acs.SalesMonth) AS SalesMonth,
COALESCE(bs.StoreNum,acs.StoreNum) AS StoreNum,
COALESCE(bs.ProductCode,acs.ProductCode) AS ProductNum,
BudgetRevenue,
ActualRevenue
FROM BudgetSales bs
FULL JOIN ActualSales acs
ON bs.SalesMonth = acs.SalesMonth
AND bs.StoreNum = acs.StoreNum
AND bs.ProductCode = acs.ProductCode;




