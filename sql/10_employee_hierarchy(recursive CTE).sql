/*
Employee Hierarchy Analysis

Purpose:
- Display each employee's level within the company hierarchy.
- Identify reporting relationships using EmployeeID and SuperID.

Grain:
- One row per employee.

Technique:
- Recursive CTE
*/

WITH EmployeeHierarchy  AS(
-- Anchor query: top-level employee
SELECT 
	StoreName,
	StoreCountry,
	FirstName,
	LastName,
	EmployeeID,
	SuperID,
	1 AS HierarchyLevel
FROM pet.dim_store
WHERE SuperID = 0

UNION ALL

-- Recursive query: employees reporting to the previous level
SELECT
	s.StoreName,
	s.StoreCountry,
	s.FirstName,
	s.LastName,
	s.EmployeeID,
	s.SuperID,
	HierarchyLevel + 1
FROM pet.dim_store AS s
INNER JOIN  EmployeeHierarchy AS eh
ON eh.EmployeeID = s.SuperID
)
-- Main Query
SELECT
StoreName,
StoreCountry,
CONCAT(FirstName,' ',LastName) AS EmployeeName,
EmployeeID,
SuperID,
HierarchyLevel
FROM EmployeeHierarchy
ORDER BY
    HierarchyLevel,
    SuperID,
    EmployeeID
OPTION (MAXRECURSION 100)
