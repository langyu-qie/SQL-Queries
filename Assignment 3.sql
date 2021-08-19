-- In SQL Server, assuming you can find the result by using both joins and subqueries, which one would you prefer to use and why?
-- I prefer to use JOINs than Subqueries. Because Joins performs better than subqueries, and they execute faster.

--What is CTE and when to use it?
--CTE is short for common table expression. We use CTE when we need to write recursive queries

--What are Table Variables? What is their scope and where are they created in SQL Server?
--Table variable is a special type of the local variable that helps to store data temporarily. 
--A table variable is scoped to stored procedure, batch, or user-defined function. Table variables are created in the memory.

--What is the difference between DELETE and TRUNCATE? Which one will have better performance and why?
--Truncate always removes all the rows from a table, leaving the table empty and the table structure intact 
--DELETE may remove conditionally if the where clause is used
--Truncate is faster compared to delete as it makes less use of the transaction log.



--What is Identity column? How does DELETE and TRUNCATE affect it?
--Identity columns is a special type of column that is used to automatically generate key values based on a provided seed and increment.
--DELETE retains the identity and does not reset it to the seed value, TRUNCATE resets the identity to its seed value


--What is difference between ¡°delete from table_name¡± and ¡°truncate table table_name¡±?
--"delete from table_name" removes the rows matched with the where clause.
--"truncate table table_name" removes all rows from a table



--Use database Northwind
Use Northwind
GO


--1 List all cities that have both Employees and Customers.

SELECT DISTINCT City 
FROM Employees 
WHERE City IN 
(
  SELECT City FROM Customers
)


--2 List all cities that have Customers but no Employee
    -- use subquery
SELECT DISTINCT City 
FROM Customers 
WHERE City NOT IN 
(
  SELECT City FROM Employees
)

    --do not use subquery
SELECT DISTINCT  c.city 
FROM Customers c LEFT JOIN Employees e on e.City = c.City
WHERE e.City is NULL


--3 List all products and their total order quantities throughout all orders.
SELECT p.ProductName, 
(SELECT COUNT(OrderID) FROM [Order Details] od where p.ProductID = od.ProductID) AS  TotalOrderQuantity
FROM Products p
Order BY 1

select productname from products


--4 List all Customer Cities and total products ordered by that city.  
SELECT City, SUM(ProductsOrdered)
FROM
(
SELECT c.City, 
(SELECT COUNT(OrderID) 
From Orders o 
WHERE c.CustomerID = o.CustomerID) AS ProductsOrdered
FROM Customers c
) dt
Group by dt.City
ORDER By 1

select * from orders

--5 List all Customer Cities that have at least two customers. 
--Use union                                                             
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID)>2
UNION
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID)=2

--Use sub-query and no union
--SELECT * from Customers

SELECT DISTINCT City
FROM Customers
WHERE City in
(
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID)>=2
)



--6 List all Customer Cities that have ordered at least two different kinds of products
SELECT c.City AS [Customer City], COUNT(DISTINCT p.CategoryID) AS NumOfKindsOfProducts
FROM Products p LEFT JOIN [Order Details] od on p.ProductID = od.ProductID LEFT JOIN Orders o on od.OrderID = o.OrderID LEFT JOIN Customers c on o.CustomerID = C.CustomerID
GROUP BY c.City
Order BY 1

--7 List all Customers who have ordered products, but have the ¡®ship city¡¯ on the order different from their own customer cities.
SELECT c.ContactName
FROM Customers c FULL OUTER JOIN Orders o on o.CustomerID = c.CustomerID
WHERE c.City != o.ShipCity


--8 List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
SELECT * FROM
(
SELECT  dt1.ProductName, dt1.City FROM
(
SELECT p.ProductName, c.City, SUM(od.Quantity*od.UnitPrice)/SUM(od.Quantity) AS AvgPrice, SUM(od.quantity) AS SumOfQuantity,
RANK() OVER(PARTITION BY p.ProductName ORDER BY SUM( od.Quantity) DESC) as RNK
FROM Products p LEFT JOIN [Order Details] OD ON p.ProductID = od.ProductID LEFT JOIN Orders o on o.OrderID = od.OrderID LEFT JOIN Customers c on c.CustomerID = o.CustomerID
GROUP BY p.ProductName, c.City
) dt1
WHERE RNK=1
) DT11
inner JOIN
(
SELECT dt2.ProductName, dt2.AvgPrice, dt2.SumOfQuantity
FROM
(SELECT  p.ProductName, SUM(od.Quantity*od.UnitPrice)/SUM(od.Quantity) AS AvgPrice, SUM(od.quantity) AS SumOfQuantity, RANK() OVER(ORDER BY SUM( od.Quantity) DESC) as RNK
FROM Products p LEFT JOIN [Order Details] OD ON p.ProductID = od.ProductID LEFT JOIN Orders o on o.OrderID = od.OrderID LEFT JOIN Customers c on c.CustomerID = o.CustomerID
GROUP BY p.ProductName
) dt2
WHERE RNK <=5
) DT12
on DT11.ProductName = DT12.ProductName
ORDER BY 5 DESC

--9 List all cities that have never ordered something but we have employees there.
--Use sub-query
SELECT City
FROM Employees
WHERE City NOT IN 
(
  SELECT c.City
  FROM Customers C LEFT JOIN Orders O ON o.CustomerID = c.CustomerID
)

--Do not use sub-query
SELECT DISTINCT  e.city 
FROM Employees e LEFT JOIN Customers c on e.City = c.City
WHERE c.City is NULL



--10 List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)
SELECT TOP 1 e.City, COUNT(O.OrderID) AS OrderCounts FROM Employees e LEFT JOIN Orders o on o.EmployeeID = e.EmployeeID
GROUP BY e.City
ORDER BY 2 DESC

SELECT TOP 1 c.City, SUm(od.OrderID) AS SumOrderQuantity FROM Customers c LEFT JOIN Orders o on o.CustomerID = c.CustomerID LEFT JOIN [Order Details] od  on O.OrderID=OD.OrderID
GROUP BY C.City
ORDER BY 2 DESC



--11 How do you remove the duplicates record of a table?
--use ROW_NUMBER() in common table expression to find  the duplicate rows specified by values in columns. 
--Then use the DELETE statement deletes all the duplicate rows but keeps only one occurrence of each duplicate group


/*12 Sample table to be used for solutions below- 
Employee (empid integer, mgrid integer, deptid integer, salary money) 
Dept (deptid integer, deptname varchar(20)) 
Find employees who do not manage anybody.*/


CREATE TABLE Employee(
 empid INT,
 mgrid INT,
 deptid INT,
 salary money)
CREATE TABLE Dept(
deptid INT,
deptname VARCHAR(20)
)

SELECT m.empid 
FROM Employee m left join Employee e on m.mgrid = e.empid
WHERE e.empid is NULL


/*13
Find departments that have maximum number of employees. (solution should 
consider scenario having more than 1 departments that have maximum number of 
employees). Result should only have - deptname, count of employees sorted by deptname.
*/
SELECT dt.deptname, dt.NumOfEmp
FROM
(SELECT d.deptname, COUNT(DISTINCT e.empid) AS NumOfEmp, RANK()OVER(Partition by d.deptname ORDER BY COUNT(DISTINCT e.empid)) AS RNK
FROM Employee e LEFT JOIN Dept d on d.deptid = e.deptid
GROUP BY d.deptname) dt
WHERE RNK =1


/* 14 Find top 3 employees (salary based) in every department. Result should have deptname, empid,
salary sorted by deptname and then employee with high to low
*/
SELECT dt.deptname, dt.empid,dt.salary
FROM 
(
SELECT d.deptname, e.empid, e.salary, RANK()OVER(Partition BY d.deptname ORDER BY e.salary) AS RNK
FROM Dept d LEFT JOIN Employee e on e.deptid = d.deptid
) dt
WHERE RNK<=3
