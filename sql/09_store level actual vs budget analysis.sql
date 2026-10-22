/*
Store-Level Actual vs Budget Analysis

Purpose:
- Compare monthly actual revenue against budget by store.
- Calculate monthly and YTD variance.
- Rank stores within each reporting month.
- Preserve future budget while suppressing unavailable actual results.

Grain:
- One row per store per month.

Dependencies:
- pet.vw_ActualVsBudget2026
- pet.vw_GlobalSales
- pet.dim_store
*/
DECLARE @AsOfMonth DATE;
SET @AsOfMonth = (
	SELECT DATETRUNC(month,MAX(OrderDate))
	FROM pet.vw_GlobalSales);

WITH StoreDetail AS (
SELECT
avb.SalesMonth,
avb.StoreNum,
avb.BudgetRevenue,
avb.ActualRevenue,
ds.StoreName,
CONCAT(ds.FirstName,' ',ds.LastName) StoreManager
FROM pet.vw_ActualVsBudget2026 avb
LEFT JOIN pet.dim_store ds
ON avb.StoreNum = ds.StoreNumber
WHERE YEAR(SalesMonth) = YEAR(@AsOfMonth)
),
Basics AS (
SELECT
SalesMonth,
StoreName,
StoreManager,
SUM(ActualRevenue) AS ActualRevenue,
SUM(BudgetRevenue) AS BudgetRevenue,
SUM(SUM(ActualRevenue)) OVER(PARTITION BY StoreNum ORDER BY SalesMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) ActualYTD,
SUM(SUM(BudgetRevenue)) OVER(PARTITION BY StoreNum ORDER BY SalesMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) BudgetYTD
FROM StoreDetail
GROUP BY 
		 SalesMonth,
		 StoreNum,
		 StoreName,
		 StoreManager
),
StoreVariance AS (
SELECT
StoreName,
SalesMonth,
StoreManager,
CASE WHEN SalesMonth < @AsOfMonth THEN ActualRevenue
	 ELSE NULL
END AS ActualRevenue,
BudgetRevenue,
CASE WHEN SalesMonth < @AsOfMonth THEN ActualRevenue - BudgetRevenue 
	 ELSE NULL
END AS MonthlyVariance,
CASE WHEN SalesMonth < @AsOfMonth THEN CAST((ActualRevenue - BudgetRevenue) * 100.0 / NULLIF(BudgetRevenue,0) AS DECIMAL(18,2)) 
	 ELSE NULL
END AS MonthlyVariancePct,
CASE WHEN SalesMonth < @AsOfMonth THEN ActualYTD
	 ELSE NULL
END AS ActualYTD,
BudgetYTD,
CASE WHEN SalesMonth < @AsOfMonth THEN  ActualYTD - BudgetYTD 
	 ELSE NULL
END AS YTDVariance,
CASE WHEN SalesMonth < @AsOfMonth THEN CAST((ActualYTD - BudgetYTD) * 100.0 / NULLIF(BudgetYTD,0) AS DECIMAL(18,2)) 
	 ELSE NULL
END AS YTDVariancePct
FROM Basics
)
SELECT
StoreName,
SalesMonth,
StoreManager,
ActualRevenue,
BudgetRevenue,
MonthlyVariance,
MonthlyVariancePct,
CASE WHEN SalesMonth < @AsOfMonth THEN RANK() OVER(PARTITION BY SalesMonth ORDER BY ActualRevenue DESC) 
	 ELSE NULL
END AS MonthlyRevenueRank,
CASE WHEN MonthlyVariancePct >= 0 THEN 'On or above budget'
	 WHEN MonthlyVariancePct >= -10 THEN 'Slightly below budget'
	 WHEN MonthlyVariancePct < -10 THEN 'Significantly below budget'
	 ELSE 'No actual data'
END AS MonthlyPerformanceStatus,
ActualYTD,
BudgetYTD,
YTDVariance,
YTDVariancePct,
CASE WHEN YTDVariancePct >= 0 THEN 'On or above budget'
	 WHEN YTDVariancePct >= -10 THEN 'Slightly below budget'
	 WHEN YTDVariancePct < -10 THEN 'Significantly below budget'
	 ELSE 'No actual data'
END YTDPerformanceStatus
FROM StoreVariance
ORDER BY StoreName,
		 SalesMonth
