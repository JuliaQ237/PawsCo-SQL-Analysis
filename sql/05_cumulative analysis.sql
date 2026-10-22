/*
Cumulative Sales Analysis

Purpose:
    - Calculate monthly revenue for the latest two calendar years.
    - Calculate a running total that resets each year.
    - Calculate a six-month rolling total.
    - Measure month-over-month revenue change.
    - Compare each month with the highest-revenue month of its year.

Techniques:
    - CTEs
    - Aggregate functions
    - Window functions
    - Running totals
    - Rolling calculations
    - LAG()
    - Conditional calculations
*/

WITH MonthlySales AS ( 
SELECT
DATETRUNC(month,OrderDate) AS SalesMonth,
SUM(Revenue) AS MonthlyRevenue
FROM pet.vw_GlobalSales
GROUP BY DATETRUNC(month,OrderDate) 
),

Metrics AS (
SELECT
SalesMonth,
MonthlyRevenue,
SUM(MonthlyRevenue) OVER (PARTITION BY YEAR(SalesMonth) ORDER BY SalesMonth) AS YearRunningTotal,
SUM(MonthlyRevenue) OVER (ORDER BY SalesMonth ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS SixMonthRollingTotal,
LAG(MonthlyRevenue,1) OVER (ORDER BY SalesMonth) AS PreviousMonthRevenue,
MAX (MonthlyRevenue) OVER( PARTITION BY YEAR(SalesMonth) ORDER BY MonthlyRevenue DESC) AS LargestMonthlyRevenue,
CAST(AVG(MonthlyRevenue) OVER( PARTITION BY YEAR(SalesMonth)) AS DECIMAL(18,2)) AS YearlyAvgRevenue
FROM MonthlySales
)

SELECT
SalesMonth,
MonthlyRevenue,
YearRunningTotal,
SixMonthRollingTotal,
PreviousMonthRevenue,
CAST((MonthlyRevenue - PreviousMonthRevenue) * 100.0 / NULLIF(PreviousMonthRevenue,0) AS DECIMAL(18,2)) AS MOMChangePct,
LargestMonthlyRevenue,
MonthlyRevenue - LargestMonthlyRevenue AS GapFromLargestMonth,
YearlyAvgRevenue,
CASE WHEN MonthlyRevenue > YearlyAvgRevenue THEN 'Above average'
     WHEN MonthlyRevenue < YearlyAvgRevenue THEN 'Below average'
     ELSE 'On average'
END AS MonthlyPerformance
FROM Metrics
WHERE YEAR(SalesMonth) >= (
    SELECT
    MAX(YEAR(OrderDate)) - 1
    FROM pet.vw_GlobalSales )
ORDER BY SalesMonth