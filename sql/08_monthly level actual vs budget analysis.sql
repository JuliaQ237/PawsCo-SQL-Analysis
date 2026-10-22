/*
Monthly-Level Actual vs Budget Analysis

Purpose:
- Compare monthly actual revenue against budget.
- Calculate monthly and YTD variance.
- Rank sales performance of each reporting month.
- Preserve future budget while suppressing unavailable actual results.

Grain:
- One row per month.

Dependencies:
- pet.vw_ActualVsBudget2026
- pet.vw_global_sales
- pet.dim_store
*/
DECLARE @AsOfMonth DATE;
SET @AsOfMonth = (
	SELECT DATETRUNC(month,MAX(OrderDate))
	FROM pet.vw_GlobalSales);

WITH BasicQuery AS(
SELECT
SalesMonth,
SUM(BudgetRevenue) AS BudgetRevenue,
SUM(ActualRevenue) AS ActualRevenue,
SUM(SUM(BudgetRevenue)) OVER(ORDER BY SalesMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS BudgetYTD,
SUM(SUM(ActualRevenue)) OVER(ORDER BY SalesMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ActualYTD
FROM pet.vw_ActualVsBudget2026
WHERE YEAR(SalesMonth) = YEAR(@AsOfMonth)
GROUP BY SalesMonth
),
RevenueRank AS (
SELECT
SalesMonth,
CASE WHEN SalesMonth < @AsOfMonth THEN ActualRevenue
	 ELSE NULL
END AS ActualRevenue,
BudgetRevenue,
CASE WHEN SalesMonth < @AsOfMonth THEN ActualRevenue - BudgetRevenue 
	 ELSE NULL
END AS MonthlyVariance,
CASE WHEN SalesMonth < @AsOfMonth THEN CAST((ActualRevenue - BudgetRevenue) *100.0 / NULLIF(BudgetRevenue,0) AS DECIMAL(18,2)) 
	 ELSE NULL
END AS MonthlyVariancePct,
CASE WHEN SalesMonth < @AsOfMonth THEN RANK() OVER (ORDER BY ActualRevenue DESC) 
	 ELSE NULL
END AS RevenueRank,
CASE WHEN SalesMonth < @AsOfMonth THEN ActualYTD
	 ELSE NULL
END AS ActualYTD,
BudgetYTD,
CASE WHEN SalesMonth < @AsOfMonth THEN ActualYTD - BudgetYTD
	 ELSE NULL
END AS YTDVariance,
CASE WHEN SalesMonth < @AsOfMonth THEN CAST((ActualYTD - BudgetYTD)  *100.0 / NULLIF(BudgetYTD,0) AS DECIMAL(18,2))  
	 ELSE NULL
END AS YTDVariancePct 
FROM BasicQuery
)
SELECT
SalesMonth,
ActualRevenue,
BudgetRevenue,
MonthlyVariance,
MonthlyVariancePct,
CASE WHEN MonthlyVariancePct >= 0 THEN 'On or above budget'
	 WHEN MonthlyVariancePct < 0 THEN 'Below budget'
	 ELSE 'No actual data'
END MonthlyPerformanceStatus,
RevenueRank,
ActualYTD,
BudgetYTD,
YTDVariance,
YTDVariancePct,
CASE WHEN YTDVariancePct >= 0 THEN 'On or above budget'
	 WHEN YTDVariancePct < 0 THEN 'Below budget'
	 ELSE 'No actual data'
END YTDPerformanceStatus
FROM RevenueRank
ORDER BY SalesMonth;
