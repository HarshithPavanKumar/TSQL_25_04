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
SELECT *, RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryRank FROM Employees
-- 3. Use DENSE_RANK() to rank employees and compare with RANK()
SELECT *, DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS SalaryDenseRank FROM Employees
-- 4. Generate a sequential number for each employee irrespective of department using ROW_NUMBER()
SELECT *, ROW_NUMBER() OVER (ORDER BY EmployeeID DESC) AS RowNum FROM Employees

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
FROM Sales AS S
WHERE TotalSales > (
    SELECT AVG(TotalSales)
    FROM Sales
    WHERE Region = S.Region
)
-- 3. Use subquery in SELECT clause to show salesperson's rank within their region
SELECT *,
    RANK() OVER (PARTITION BY Region ORDER BY TotalSales DESC) AS RankInRegion
FROM Sales
--------------------------------------------------------------------3----------------------------------------------------------------------------------------------------
-- Create GetHighEarningEmployees procedure
CREATE PROCEDURE GetHighEarningEmployees
    @SalaryThreshold DECIMAL(10,2)
AS
BEGIN
    SELECT *
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
    Month VARCHAR(20),
    Region VARCHAR(50),
    TotalSales DECIMAL(10,2)
);
INSERT INTO MonthlySales VALUES
('January', 'North', 20000),
('February', 'North', 42000),
('March', 'North', 10000),
('January', 'South', 9000),
('February', 'South', 8500),
('March', 'South', 8700);
--lag() to find difference
SELECT *,
LAG(TotalSales) OVER(PARTITION BY Region ORDER BY Month) AS PreviousMonthSales,
(TotalSales - LAG(TotalSales) OVER (PARTITION BY Region ORDER BY Month)) AS SalesDifference
FROM MonthlySales;
--Add column to identify sales decrease
SELECT *,
    LAG(TotalSales) OVER (PARTITION BY Region ORDER BY Month) AS PreviousMonthSales,
    (TotalSales - LAG(TotalSales) OVER (PARTITION BY Region ORDER BY Month)) AS SalesDifference,
    CASE 
        WHEN TotalSales < LAG(TotalSales) OVER (PARTITION BY Region ORDER BY Month) THEN 'Decrease'
        ELSE 'No Decrease'
    END AS SalesTrend
FROM MonthlySales;
--------------------------------------------------------------------5---------------------------------------------------------------------------------------------------
-- 1.	Use the MonthlySales table from the previous activity.
-- 2.	Use LEAD() to calculate the predicted sales for the next month in each region.
SELECT *,
LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) AS NextMonthSales,
(LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) - TotalSales) AS PredictedChange
FROM MonthlySales;
-- 3.	Add a column to compare current sales with the predicted future sales.
SELECT *,
    LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) AS NextMonthSales,
    CASE 
        WHEN LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) > TotalSales THEN 'Predicted Increase'
        WHEN LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) < TotalSales THEN 'Predicted Decrease'
        ELSE 'No Change'
    END AS PredictedTrend
FROM MonthlySales;
