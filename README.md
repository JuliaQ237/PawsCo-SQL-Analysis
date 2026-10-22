# PawsCo Sales Performance Analysis

## Project overview

This project uses SQL Server to analyse the sales performance of PawsCo, a fictional international pet-supplies retailer operating in Australia and Europe.

I created a relational database from multiple synthetic CSV files, combined regional transaction tables, validated the data and developed reusable SQL views and analytical reports. The project focuses on sales trends, product profitability, customer behaviour and actual-versus-budget performance.

The dataset is synthetic and was created specifically for portfolio use. It contains no real customer or confidential business information.

## Business objectives

The analysis addresses the following questions:

1. How are revenue and sales volume changing over time?
2. Which products generate the most revenue and profit?
3. How does each product compare with its previous-year and historical performance?
4. Which customers generate the most value, and how can they be segmented?
5. Is the business achieving its monthly and year-to-date revenue budget?
6. Which stores are performing above or below budget?
7. How are store managers organised within the employee hierarchy?

## Tools and techniques

- SQL Server and SQL Server Management Studio
- T-SQL
- Relational database design
- Fact and dimension tables
- Common table expressions and recursive CTEs
- Window functions
- Running and rolling calculations
- `LAG`, `RANK`, `AVG OVER` and `MAX OVER`
- `UNION ALL`, `FULL JOIN` and `LEFT JOIN`
- Reusable views
- Actual-versus-budget variance analysis
- Data-quality validation and reconciliation

## Dataset

| File | Description | Rows |
|---|---|---:|
| PawsCo_AU sales | Australian sales transactions | 113,534 |
| PawsCo_EU sales | European sales transactions | 38,546 |
| PawsCo_Budget_2026 | Monthly product-level revenue budgets by store | 43,080 |
| PawsCo_Customer | Customer demographics and pet ownership attributes | 5,840 |
| PawsCo_Product | Product, price and cost information | 359 |
| PawsCo_ProductDetail | Product category hierarchy and descriptions | 78 |
| PawsCo_Store | Store location and management information | 10 |

The sales data contains **152,080 transactions** from January 2022 to 21 October 2026. The budget contains monthly targets for the full 2026 calendar year.

## Database design

The database uses the `pet` schema.

### Fact tables

- `pet.fact_AUSales`
- `pet.fact_EUSales`
- `pet.fact_budget`

### Dimension tables

- `pet.dim_customer`
- `pet.dim_product`
- `pet.dim_ProductDetail`
- `pet.dim_store`

### Views

- `pet.vw_GlobalSales` combines Australian and European transactions into one reusable sales source.
- `pet.vw_ActualVsBudget2026` aligns actual and budget revenue at month–store–product grain.

## Data validation

The validation process checks:

- Annual and monthly revenue totals
- Customer counts and sales quantities
- Revenue by region
- Duplicate transaction numbers
- Transactions missing from the global sales view
- Unexpected transactions appearing in the view
- Duplicate product-category keys
- Products without matching cost information

The reviewed source files contain unique dimension keys, no duplicate transaction numbers and no unmatched store, customer, product, category or budget references. Missing shipment dates are retained as transactions without a recorded shipment date.

## Analysis

### Cumulative sales analysis

- Monthly revenue for the latest two calendar years
- Running revenue total that resets each year
- Six-month rolling revenue
- Month-over-month revenue change
- Comparison with the highest and average month of each year

### Product performance analysis

- Annual quantity, revenue, cost and profit by product
- Estimated discount rate against retail value
- Year-over-year revenue and profit change
- Comparison with each product's average annual profit
- Revenue and profitability trend classifications

### Customer report

- Revenue, quantity and order count by customer
- Average order value and average monthly spend
- Customer recency and purchasing lifespan
- Customer segmentation by spending, relationship length and age group

### Actual-versus-budget analysis

- Monthly actual and budget revenue
- Monthly and year-to-date variance
- Monthly revenue ranking
- Store-level revenue and budget performance
- Performance categories based on variance percentage
- Future budget retention without presenting unavailable actual results

### Employee hierarchy

- Recursive CTE showing employee reporting levels using `EmployeeID` and `SuperID`

## Selected findings

- The complete sales dataset contains **$47.28 million** in revenue and approximately **$13.36 million** in gross profit.
- Annual revenue increased from **$4.40 million in 2022** to **$13.66 million in 2026 through 21 October**.
- For the completed January–September 2026 period, actual revenue was **$12.58 million**, compared with a budget of **$13.18 million**. This was a **$594,059 shortfall**, or **4.51% below budget**.
- Sydney, Melbourne, Brisbane and Milan were above their year-to-date budgets through September 2026.
- Sydney had the strongest store result at approximately **31.29% above budget**, followed by Melbourne at **26.42% above budget**.
- `Soft-sided Pet Carrier - Small - Sand` generated the highest cumulative product revenue at approximately **$2.58 million**.

## Repository structure

```text
pawsco-sales-performance-analysis/
├── README.md
├── data/
│   ├── PawsCo_AU_sales.csv
│   ├── PawsCo_EU_sales.csv
│   ├── PawsCo_Budget_2026.csv
│   ├── PawsCo_Customer.csv
│   ├── PawsCo_Product.csv
│   ├── PawsCo_ProductDetail.csv
│   └── PawsCo_Store.csv
└── sql/
    ├── 01_database_setup.sql
    ├── 02_vw_GlobalSales.sql
    ├── 03_vw_ActualVsBudget2026.sql
    ├── 04_data_validation.sql
    ├── 05_cumulative_analysis.sql
    ├── 06_performance_analysis.sql
    ├── 07_customer_report.sql
    ├── 08_monthly_actual_vs_budget_analysis.sql
    ├── 09_store_actual_vs_budget_analysis.sql
    └── 10_employee_hierarchy.sql
```

## How to run the project

1. Download or clone the repository.
2. Open the scripts in SQL Server Management Studio.
3. In `01_database_setup.sql`, update the `BULK INSERT` paths to the location of the CSV files on your computer.
4. Run the SQL scripts in numerical order.
5. Review the validation results before using the analytical queries.

The scripts use `DATETRUNC`, which requires SQL Server 2022 or a compatible SQL platform.

> The setup script drops and recreates the `PetSupplies` database. It is intended for a local portfolio environment and should not be used against a production database.

## Future development

The SQL views can be connected to Power BI to build an interactive dashboard for sales, profitability, customer and budget analysis.
