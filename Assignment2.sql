--1 What  is a result set?
-- Result set is a set of data, could be empty or not, returned by a select statement, or a stored procedure, that is saved in RAM or displayed on the screen

--2 What is the difference between Union and Union All?
--Union extracts the rows that are being specified in the query while Union ALL extracts all the rows including the duplicates

--3 What are the other Set Operators SQL Server has?
--INTERSECT, EXCEPT

--4 What is the difference between Union and Join?
--join is used to combine columns from different tables, the union is used to combine rows.

--5 What is the difference between INNER JOIN and FULL JOIN?
--inner join only returns the matching rows between both the tables, non-matching row are eliminated. Full join returns all rows from both the tables, including non-matching rows from both the tables

--6 What is difference between left join and outer join
--left join returns all rows from the left table, even if there are no matches in the right table. Full outer join returns all rows from both the tables, including non-matching rows from both the tables

--7	What is cross join?
--cross join returns the Cartesian product of rows from the rowsets in the join.

--8	What is the difference between WHERE clause and HAVING clause?
-- WHERE clause is used to filter the records from the table based on the specified condition. HAVING clause is used to filter the records from the group based on specified condition

--9	Can there be multiple group by columns?
--Yes

--Using database AdventureWorks2019
Use AdventureWorks2019
GO

--1. How many products can you find in the production.product table?
SELECT TOP 50 * FROM Production.Product WHERE WeightUnitMeasureCode is not null
SELECT COUNT(DISTINCT ProductID) 
FROM Production.Product

--2. Retrieves the number of products in the Production.Product table that are included in a subcategory. The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory.
SELECT COUNT(DISTINCT ProductID)
FROM Production.Product
WHERE ProductSubcategoryID  is NOT NULL

/* 3 
How many Products reside in each SubCategory? Write a query to display the results with the following titles.
ProductSubcategoryID CountedProducts
-------------------- ---------------
*/
SELECT ProductSubcategoryID, COUNT(ProductID) AS CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID  is NOT NULL
GROUP BY ProductSubcategoryID
ORDER BY ProductSubcategoryID

--4 How many products that do not have a product subcategory? 
SELECT COUNT(DISTINCT ProductID)
FROM Production.Product
WHERE ProductSubcategoryID  is NULL

--5 list the sum of products quantity in the Production.ProductInventory table.
SELECT SUM(Quantity)
FROM Production.ProductInventory 

/* 6
list the sum of products in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100.
              ProductID    TheSum
-----------        ----------
*/
SELECT ProductID, Quantity as TheSum
FROM Production.ProductInventory 
where LocationID= 40 AND Quantity< 100

/*7
list the sum of products with the shelf information in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100
Shelf      ProductID    TheSum
---------- -----------        -----------
*/

SELECT Shelf, ProductID, Quantity as TheSum 
from Production.ProductInventory 
where LocationID=40 AND shelf !='N/A' AND Quantity<100


--8 list the average quantity for products where column LocationID has the value of 10 from the table Production.ProductInventory table.
SELECT AVG(Quantity)
FROM Production.ProductInventory
WHERE LocationID = 10

/* 9
See the average quantity  of  products by shelf  from the table Production.ProductInventory
ProductID   Shelf      TheAvg
----------- ---------- -----------
*/
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY Shelf, ProductID
ORDER BY Shelf

/* 10  see the average quantity  of  products by shelf excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory
ProductID   Shelf      TheAvg
----------- ---------- -----------
*/
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE Shelf!='N/A'
GROUP BY Shelf, ProductID
ORDER BY Shelf

/* 11 List the members (rows) and average list price in the Production.Product table. This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null.
Color           	Class 	TheCount   	 AvgPrice
--------------	- ----- 	----------- 	---------------------
*/
SELECT Color, Class, Count(DISTINCT ProductID) as TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.Product
Where Color is not null and Class is not null
GROUP BY Color, Class


select top 100 * from production.Product

/* 12
list the country and province names from person. CountryRegion and person. StateProvince tables. Join them and produce a result set similar to the following. 

Country                        Province
---------                          ----------------------
*/
select c.Name AS Country, s. Name AS Province
from person.CountryRegion c JOIN person.StateProvince s on c.CountryRegionCode=s.CountryRegionCode



/* 13
list the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following.

Country                        Province
---------                          ----------------------
*/
select c.Name AS Country, s. Name AS Province
from person.CountryRegion c JOIN person.StateProvince s on c.CountryRegionCode=s.CountryRegionCode
WHERE c.Name = 'Germany' OR c.Name= 'Canada'




--Using Northwind
Use Northwind
GO


--14 List all Products that has been sold at least once in last 25 years.

SELECT DISTINCT p.ProductName, o.orderdate
FROM Products p JOIN [Order Details] od ON p.ProductID = od.ProductID INNER JOIN Orders o on o.OrderID=od.OrderID
WHERE Year(getDate())-Year(o.OrderDate)<25



--15 List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 o.ShipPostalCode
FROM Orders o JOIN [Order Details] od on o.OrderID= od.OrderID
WHERE o.ShipPostalCode is not null
GROUP BY o.ShipPostalCode
ORDER BY COUNT(od.productID) DESC


--16  List top 5 locations (Zip Code) where the products sold most in last 25 years.
SELECT TOP 5 o.ShipPostalCode
FROM Orders o JOIN [Order Details] od on o.OrderID= od.OrderID
WHERE Year(getDate())-Year(o.OrderDate)<25
GROUP BY o.ShipPostalCode
ORDER BY COUNT(od.productID) DESC


--17  List all city names and number of customers in that city.     

SELECT COUNT(DISTINCT CustomerID) As [Number of Customers], City
from Customers
GROUP BY City


--18 List city names which have more than 2 customers, and number of customers in that city
SELECT COUNT(DISTINCT CustomerID) As [Number of Customers], City
from Customers
GROUP BY City
Having COUNT(DISTINCT CustomerID)>2


--19 List the names of customers who placed orders after 1/1/98 with order date.
SELECT c.ContactName, o.OrderDate
FROM Customers c JOIN Orders o on  o.CustomerID = c.CustomerID
WHERE o.OrderDate>'1998-01-01'


--20 List the names of all customers with most recent order dates
SELECT c.ContactName, MAX(o.OrderDate) as TheMostRecentOrderDate
FROM Customers c JOIN Orders o on  o.CustomerID = c.CustomerID
GROUP BY c.ContactName




--21 Display  the names of all customers  along with the  count of products they bought 
SELECT c.ContactName, COUNT(od.ProductID) as CountOfProducts
FROM Customers c JOIN Orders o on  o.CustomerID = c.CustomerID JOIN [Order Details] od on od.OrderID= o.OrderID
GROUP BY c.ContactName



--22 Display the customer ids who bought more than 100 Products with count of products. 
SELECT o.CustomerID, count(OD.ProductID) as CountOfProducts
FROM Orders o JOIN [Order Details] od on O.OrderID = OD.OrderID
GROUP BY o.CustomerID
Having COUNT(od.ProductID)>100




/*23
23.	List all of the possible ways that suppliers can ship their products. Display the results as below
Supplier Company Name   	Shipping Company Name
---------------------------------            ----------------------------------
*/
SELECT s.CompanyName, sh.CompanyName
FROM Suppliers s join Products p on s.SupplierID = p. SupplierID JOIN [Order Details] od on p.ProductID = od.ProductID JOIN Orders o on od.OrderID = o.OrderID JOIN Shippers sh on o.ShipVia= sh.ShipperID
GROUP BY s.CompanyName, sh.CompanyName
ORDER BY s.CompanyName



--24  Display the products order each day. Show Order date and Product Name.
SELECT o.OrderDate, p.ProductName
FROM Orders o JOIN [Order Details] od on o.OrderID = OD.OrderID JOIN Products p on p.ProductID = od.ProductID
GROUP BY o.OrderDate, P.ProductName


--25  	Displays pairs of employees who have the same job title.
SELECT CONCAT(E.FirstName, E.LastName) AS EMPLOYEE1,  CONCAT(m.FirstName, m.LastName) AS EMPLOYEE2, E.TITLE
FROM Employees E JOIN Employees m on (E.Title = m.Title AND e.EmployeeID<>m.EmployeeID)


--26   Display all the Managers who have more than 2 employees reporting to them.

SELECT CONCAT(m.FirstName ,' ' ,m.LastName)  AS Manager, COUNT(e.FirstName) As NumberOfEmployeesReportstoThem
FROM Employees e LEFT JOIN Employees m ON e.ReportsTo = m.EmployeeID
GROUP BY CONCAT(m.FirstName ,' ' ,m.LastName)
HAVING COUNT(E.FirstName)>2




/*27
27.	Display the customers and suppliers by city. The results should have the following columns 
City 
Name 
Contact Name,
Type (Customer or Supplier)
*/
SELECT City,CompanyName, ContactName, Type ='Supplier'
FROM Suppliers
UNION 
SELECT City, CompanyName, ContactName , Type ='Customer'
FROM Customers
ORDER BY City



/*28
Have two tables T1 and T2
F1.T1	F2.T2
1	     2
2	     3
3	     4

 inner join these two tables and write down the result of this query.

*/

Create table T1(
    F1_T1 INT)
INSERT INTO T1 (F1_T1)  values (1),(2),(3)
select * from T1


Create table T2(
    F2_T2 INT)
INSERT INTO T2 (F2_T2)  values (2),(3),(4)
select * from T2

SELECT t1.F1_T1, t2.F2_T2
From T1 t1 INNER JOIN T2 t2 on t1.F1_T1=T2.F2_T2

/* 29
left outer join these two tables and write down the result of this query.

*/

SELECT t1.F1_T1, t2.F2_T2
From T1 t1 LEFT JOIN  T2 t2 on t1.F1_T1=T2.F2_T2






