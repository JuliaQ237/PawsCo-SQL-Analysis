-- Task: provide view that combines sales detail from AU and EU
CREATE VIEW pet.vw_GlobalSales AS 
SELECT
StoreNum,
TransactionNum,
CustNum,
ProductCode,
TypeNum,
Quantity,
UnitSalesPrice,
Quantity * UnitSalesPrice AS Revenue,
OrderDate,
ShipmentDate
FROM pet.fact_AUSales

UNION ALL

SELECT
StoreNum,
TransactionNum,
CustNum,
ProductCode,
TypeNum,
Quantity,
UnitSalesPrice,
Quantity * UnitSalesPrice AS Revenue,
OrderDate,
ShipmentDate
FROM pet.fact_EUSales 