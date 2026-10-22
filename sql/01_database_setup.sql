USE master;
GO

-- Drop and recreate the 'PetSupplies' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'PetSupplies')
BEGIN
    ALTER DATABASE PetSupplies SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PetSupplies;
END;
GO

-- Create the 'PetSupplies' database
CREATE DATABASE PetSupplies;
GO

USE PetSupplies;
GO

-- Create Schemas

CREATE SCHEMA pet;
GO

CREATE TABLE pet.dim_customer(
	CustNum nvarchar(50),
	FirstName nvarchar(50),
	LastName nvarchar(50),
	Birthdate date,
	CreateDate date,
	Country nvarchar(50),
	PetType nvarchar(50),
	PetCount int,
	PreferredChannel nvarchar(50),
);
GO

CREATE TABLE pet.dim_product(
	ProductCode nvarchar(50),
	ProductName nvarchar(50),
	CategoryID nvarchar(50),
	PetType nvarchar(50),
	UnitCost decimal(10,2),
	UnitRetailPrice decimal(10,2)
);
GO

CREATE TABLE pet.dim_ProductDetail(
	CategoryID nvarchar(50),
	CategoryL1 nvarchar(50),
	CategoryL2 nvarchar(50),
	CategoryL3 nvarchar(50),
	CategoryL4 nvarchar(50),
	Description nvarchar(50),
	TypicalUse nvarchar(50)
);
GO

CREATE TABLE pet.dim_store(
	StoreNumber nvarchar(50),
	StoreName nvarchar(50),
	StoreCity nvarchar(50),
	StoreState nvarchar(50),
	StoreCountry nvarchar(50),
	StoreRegion nvarchar(50),
	FirstName nvarchar(50),
	LastName nvarchar(50),
	EmployeeID INT,
	SuperID INT
);
GO

CREATE TABLE pet.fact_AUSales(
	StoreNum nvarchar(50),
	TransactionNum int,
	CustNum nvarchar(50),
	ProductCode nvarchar(50),
	TypeNum int,
	Quantity tinyint,
	UnitSalesPrice decimal(10,2),
	OrderDate date,
	ShipmentDate date
);
GO

CREATE TABLE pet.fact_EUSales(
	StoreNum nvarchar(50),
	TransactionNum int,
	CustNum nvarchar(50),
	ProductCode nvarchar(50),
	TypeNum int,
	Quantity tinyint,
	UnitSalesPrice decimal(10,2),
	OrderDate date,
	ShipmentDate date
);
GO

CREATE TABLE pet.fact_budget(
	StoreNum nvarchar(50),
	ProductCode nvarchar(50),
	BudgetMonth date,
	BudgetRevenue decimal(10,2)
);
GO

TRUNCATE TABLE pet.dim_customer;
GO

BULK INSERT pet.dim_customer
FROM 'C:\YourProjectFolder\data\PawsCo_Customer.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE pet.dim_product;
GO

BULK INSERT pet.dim_product
FROM 'C:\YourProjectFolder\data\PawsCo_Product.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE pet.dim_ProductDetail;
GO

BULK INSERT pet.dim_ProductDetail
FROM 'C:\YourProjectFolder\data\PawsCo_ProductDetail.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE pet.dim_store;
GO

BULK INSERT pet.dim_store
FROM 'C:\YourProjectFolder\data\PawsCo_Store.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE pet.fact_AUSales;
GO

BULK INSERT pet.fact_AUSales
FROM 'C:\YourProjectFolder\data\PawsCo_AU sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE pet.fact_EUSales;
GO

BULK INSERT pet.fact_EUSales
FROM 'C:\YourProjectFolder\data\PawsCo_EU sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO


TRUNCATE TABLE pet.fact_budget;
GO

BULK INSERT pet.fact_budget
FROM 'C:\YourProjectFolder\data\PawsCo_Budget_2026.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO