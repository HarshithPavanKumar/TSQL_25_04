--------------------------------------------------------------------1----------------------------------------------------------------------------------------------------
-- 1.Create Employees table
USE QUES_26_04;
CREATE TABLE Employees (
    EmployeeID INT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);
-- Insert sample data
INSERT INTO Employees (EmployeeID, FirstName, LastName, Department, Salary)
VALUES
(1, 'Biswanth', 'Ch', 'HR', 60000),
(2, 'Nageswara Rao', 'T', 'HR', 65000),
(3, 'Dheeraj', 'K', 'HR', 60000),
(4, 'Yaswanth', 'B', 'IT', 80000),
(5, 'Niteesh', 'R', 'IT', 85000);
-- 2. Assign ranks based on salary within each department using RANK()
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Department,
    Salary,
    RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryRank FROM Employees
-- 3. Use DENSE_RANK() to rank employees and compare with RANK()
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Department,
    Salary,
    DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryDenseRank FROM Employees
-- 4. Generate a sequential number for each employee irrespective of department using ROW_NUMBER()
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Department,
    Salary,
    ROW_NUMBER() OVER (ORDER BY EmployeeID) AS RowNum
FROM Employees

--------------------------------------------------------------------2----------------------------------------------------------------------------------------------------
-- 1. Create Sales table
CREATE TABLE Sales (
    SaleID INT,
    SalespersonID INT,
    Region VARCHAR(50),
    TotalSales DECIMAL(12, 2)
);
-- Insert sample data
INSERT INTO Sales (SaleID, SalespersonID, Region, TotalSales)
VALUES
(1, 101, 'Vijayawada', 50000),
(2, 102, 'Guntur', 55000),
(3, 103, 'Tenali', 40000),
(4, 104, 'Vijayawada', 70000),
(5, 105, 'Tenali', 65000),
(6, 106, 'Guntur', 72000),
(7, 107, 'Vijayawada', 30000),
(8, 108, 'Tenali', 35000),
(9, 109, 'Guntur', 32000);
-- 2. Query to find salespeople whose total sales exceed the average sales in their region
SELECT *
FROM Sales S
WHERE TotalSales > (
    SELECT AVG(TotalSales)
    FROM Sales
    WHERE Region = S.Region
)
-- 3. Use subquery in SELECT clause to show salesperson's rank within their region
SELECT 
    SaleID,
    SalespersonID,
    Region,
    TotalSales,
    (
        SELECT COUNT(*)
        FROM Sales AS InnerSales
        WHERE InnerSales.Region = OuterSales.Region
          AND InnerSales.TotalSales > OuterSales.TotalSales
    ) + 1 AS SalesRankInRegion
FROM Sales AS OuterSales
--------------------------------------------------------------------3----------------------------------------------------------------------------------------------------
-- Create GetHighEarningEmployees procedure
CREATE PROCEDURE GetHighEarningEmployees
    @SalaryThreshold DECIMAL(10,2)
AS
BEGIN
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        Department,
        Salary
    FROM 
        Employees
    WHERE 
        Salary > @SalaryThreshold
    ORDER BY Salary DESC;
END;
GO
-- Create UpdateEmployeeSalary procedure
CREATE PROCEDURE UpdateEmployeeSalary
    @DepartmentName VARCHAR(50),
    @PercentageIncrease DECIMAL(5,2)
AS
BEGIN
    UPDATE Employees
    SET Salary = Salary + (Salary * @PercentageIncrease / 100)
    WHERE Department = @DepartmentName;
    
    SELECT @@ROWCOUNT AS RowsUpdated;
END;
GO

-- Test the GetHighEarningEmployees procedure
EXEC GetHighEarningEmployees @SalaryThreshold = 60000;
GO

-- Test the UpdateEmployeeSalary procedure
EXEC UpdateEmployeeSalary 
    @DepartmentName = 'Finance', 
    @PercentageIncrease = 10;
GO

-- View updated employee data
SELECT * FROM Employees;
GO
--------------------------------------------------------------------4----------------------------------------------------------------------------------------------------
--1.	Create a MonthlySales table with columns: Month, Region, and TotalSales.
CREATE TABLE MonthlySales (
    SaleID INT, 
    SaleMonth INT,               -- Month number (1 = Jan, 2 = Feb, etc.)
    Region VARCHAR(50),          -- Region name
    TotalSales DECIMAL(12,2)     -- Total sales for the month
);

INSERT INTO MonthlySales (SaleMonth, Region, TotalSales) VALUES
(1, 'Tenali', 50000),
(2, 'Tenali', 52000),
(3, 'Tenali', 48000),
(1, 'Guntur', 60000),
(2, 'Guntur', 62000),
(3, 'Guntur', 61000),
(1, 'Vijayawada', 45000),
(2, 'Vijayawada', 44000),
(3, 'Vijayawada', 47000);
-- 2.	Use LAG() to find the difference in sales between the current month and the previous month for each region.
SELECT 
    SaleMonth,
    Region,
    TotalSales,
    LAG(TotalSales) OVER (PARTITION BY Region ORDER BY SaleMonth) AS PreviousMonthSales,
    (TotalSales - LAG(TotalSales) OVER (PARTITION BY Region ORDER BY SaleMonth)) AS SalesDifference
FROM MonthlySales
-- 3.	Add a column to identify months with a sales decrease.
SELECT 
    SaleMonth,
    Region,
    TotalSales,
    LAG(TotalSales) OVER (PARTITION BY Region ORDER BY SaleMonth) AS PreviousMonthSales,
    (TotalSales - LAG(TotalSales) OVER (PARTITION BY Region ORDER BY SaleMonth)) AS SalesDifference,
    CASE
        WHEN TotalSales < LAG(TotalSales) OVER (PARTITION BY Region ORDER BY SaleMonth) THEN 'Decrease'
        ELSE 'No Decrease'
    END AS SalesTrend
FROM MonthlySales
--------------------------------------------------------------------5---------------------------------------------------------------------------------------------------
-- 1.	Use the MonthlySales table from the previous activity.
-- 2.	Use LEAD() to calculate the predicted sales for the next month in each region.
SELECT 
    SaleMonth,
    Region,
    TotalSales,
    LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY SaleMonth) AS NextMonthSales
FROM MonthlySales
-- 3.	Add a column to compare current sales with the predicted future sales.
SELECT 
    SaleMonth,
    Region,
    TotalSales,
    LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY SaleMonth) AS NextMonthSales,
    CASE
        WHEN LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY SaleMonth) IS NULL THEN 'No Data'
        WHEN TotalSales < LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY SaleMonth) THEN 'Expected Increase'
        WHEN TotalSales > LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY SaleMonth) THEN 'Expected Decrease'
        ELSE 'No Change'
    END AS FutureTrend
FROM MonthlySales
