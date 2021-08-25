--What is View? What are the benefits of using views?
--A view is a virtual table based on the result-set of SQL statement. Like a real table, a view consists of a set of named columns and rows of data. Complex and reusable queries can be simply retrived using view.

--Can data be modified through views?
--Yes, data can be modified throug views, but it is not recommended when view using more than one base table.

--What is stored procedure and what are the benefits of using it?
--A stored procedure is a collection of DML, DDL statements that can be executed together. Store procedures are helpful in maintaining clean scripts and easy testable and isolates business rules etc.

--What is the difference between view and stored procedure?
--View has just select statements but stored procedure has collection of DML and DDL statements

--What is the difference between stored procedure and functions?
--Store procedure can return any number of values or may not return any value, but function must return a value. We can use transaction in stored procedure but it is not possible in functions. We can have both input and output parameters in sp but we can only have input parameters in function.

--Can stored procedure return multiple result sets?
--Yes, they can.

--Can stored procedure be executed as part of SELECT Statement? Why?
--No. Because stored proc may or may not return a value

--What is Trigger? What types of Triggers are there?
--Trigger in sql server is used for business logics to be executed. SQL Server has after trigger and instead of trigger for insert, update and delete statements.

--What are the scenarios to use Triggers?
--We can prevent creation of duplicate records. To create logs and so on.

--What is the difference between Trigger and Stored Procedure?
--Triggers happen on DML statements occurence where as sp should be executed manually.

--use database Northwind
USE Northwind
GO

--1 Lock tables Region, Territories, EmployeeTerritories and Employees. Insert following information into the database. In case of an error, no changes should be made to DB.
-- A new region called ¡°Middle Earth¡±;

begin tran
select * from region
select * from Territories
select * from EmployeeTerritories
select * from Employees
insert into Region values (5,'Middle Earth') 
IF @@ERROR <>0
ROLLBACK
ELSE BEGIN

-- A new territory called ¡°Gondor¡±, belongs to region ¡°Middle Earth¡±;

INSERT INTO Territories VALUES(98105,'Gondor',6)
DECLARE @error INT  = @@ERROR 
IF @error <>0
BEGIN
PRINT @error
ROLLBACK
END
ELSE BEGIN



-- A new employee ¡°Aragorn King¡± who's territory is ¡°Gondor¡±.
INSERT INTO Employees VALUES('Aragorn',	'King'	,'Sales Representative',	'Ms.'	,'1966-01-27 00:00:00.000','1994-11-15 00:00:00.000', 'Houndstooth Rd.',	'London',	NULL	,'WG2 7LT',	'UK',	'(71) 555-4444'	,452,NULL,	'Anne has a BA degree in English from St. Lawrence College.  She is fluent in French and German.',	5,	'http://accweb/emmployees/davolio.bmp/')
INSERT INTO EmployeeTerritories VALUES(@@IDENTITY,98105)
DECLARE @error2 INT  = @@ERROR 
IF @error2 <>0
BEGIN
PRINT @error2
ROLLBACK
END
ELSE BEGIN




--2 Change territory ¡°Gondor¡± to ¡°Arnor¡±.
    --begin tran
	--update Territories set TerritoryDescription = 'Arnor' WHERE RegionID =5
	--commit

	--begin tran 
	--update Employees set City = 'Arnor' WHERE LastName ='King' AND FirstName = 'Aragorn'
	--commit
UPDATE Territories
SET TerritoryDescription = 'Arnor'
WHERE TerritoryDescription = 'Gondor'
IF @@ERROR<>0
ROLLBACK
ELSE BEGIN



--3 Delete Region ¡°Middle Earth¡±. (tip: remove referenced data first) (Caution: do not forget WHERE or you will delete everything.) In case of an error, no changes should be made to DB. Unlock the tables mentioned in question 1.
   
   --begin tran
   --delete from Employees where EmployeeID = 11
   --delete from EmployeeTerritories  where EmployeeID = 11
   --delete from Territories where TerritoryID = 99999 
   --delete from region where RegionID = 5
   --commit
DELETE FROM EmployeeTerritories 
WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription = 'Arnor')
DELETE FROM Territories
WHERE TerritoryDescription = 'Arnor'
DELETE FROM Region
WHERE RegionDescription = 'Middel Earth'
IF @@ERROR <>0
ROLLBACK
ELSE BEGIN
COMMIT
END
END
END
END
END


--4 Create a view named ¡°view_product_order_[your_last_name]¡±, list all products and total ordered quantity for that product.
CREATE VIEW view_product_order_Qie AS
SELECT  p.ProductName, p.ProductID, SUM(od.Quantity) AS TotalQuan from products p left join [Order Details] od on p.ProductID = od.ProductID
GROUP BY p.ProductName, p.ProductID

SELECT * FROM view_product_order_Qie

--5 Create a stored procedure ¡°sp_product_order_quantity_[your_last_name]¡± that accept product id as an input and total quantities of order as output parameter.
create proc sp_product_order_quantity_Qie
@pid INT,
@TotalQuan INT out
AS
BEGIN
SELECT  @TotalQuan=SUM(od.Quantity)  
FROM Products p LEFT JOIN [Order Details] od on p.ProductID = od.ProductID
WHERE p.ProductID = @pid
END

declare @TQ INT
exec sp_product_order_quantity_Qie 1, @TQ out
print @TQ


--6(??????????????????????) Create a stored procedure ¡°sp_product_order_city_[your_last_name]¡± that accept product name as an input and top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.
create proc sp_product_order_city_Qie
@pname nvarchar(30)
AS 
BEGIN

SELECT TOP 5 o.ShipCity, SUM(od.Quantity) AS QuantityOrdered
FROM [Order Details] od LEFT JOIN Orders o on o.OrderID = od.OrderID LEFT JOIN Products p on p.ProductID = od.ProductID
WHERE p.ProductName = @pname
GROUP BY p.ProductName, o.ShipCity
Order by 2 DESC

END

exec sp_product_order_city_Qie  'Chai'

drop proc sp_product_order_city_Qie

select * from Products
--7 Lock tables Region, Territories, EmployeeTerritories and Employees. Create a stored procedure ¡°sp_move_employees_[your_last_name]¡± that automatically find all employees in territory ¡°Troy¡±; if more than 0 found, insert a new territory ¡°Stevens Point¡± of region ¡°North¡± to the database, and then move those employees to ¡°Stevens Point¡±.
--my answer
begin tran
select * from Region

select * from Territories

select * from EmployeeTerritories

select * from Employees
GO

create proc sp_move_employees_Qie
@NumOfEmpInTroy INT OUT
AS
BEGIN
SELECT @NumOfEmpInTroy = COUNT(distinct et.EmployeeID) 
FROM Territories t left join EmployeeTerritories et on t.TerritoryID = et.TerritoryID
WHERE t.TerritoryDescription = 'Troy'
IF(@NumOfEmpInTroy>0)
   BEGIN
   INSERT INTO Territories(TerritoryID,TerritoryDescription,RegionID)values(98432,'Stevens Point', 3)
   UPDATE EmployeeTerritories SET TerritoryID = 98432 WHERE TerritoryID = 48084
   END
   ELSE
   BEGIN
   PRINT('No more than 0 employees found in Troy')
   END
END

-----------------------------------------------------------------------------------
--correct answer
BEGIN TRAN
select * from Region
select * from Territories
select * from Employees
select * from EmployeeTerritories
GO
CREATE PROC sp_move_employees_gaddam
AS
BEGIN

IF EXISTS(SELECT EmployeeID FROM EmployeeTerritories WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription ='Troy'))
BEGIN
DECLARE @TerritotyID INT
SELECT @TerritotyID = MAX(TerritoryID) FROM Territories
BEGIN TRAN
INSERT INTO Territories VALUES(@TerritotyID+1 ,'Stevens Point',3)
UPDATE EmployeeTerritories
SET TerritoryID = @TerritotyID+1
WHERE EmployeeID IN (SELECT EmployeeID FROM EmployeeTerritories WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription ='Troy'))
IF @@ERROR <> 0
BEGIN
ROLLBACK
END
ELSE
COMMIT
END

END

EXEC sp_move_employees_gaddam




--8 Create a trigger that when there are more than 100 employees in territory ¡°Stevens Point¡±, move them back to Troy. (After test your code,) remove the trigger. Move those employees back to ¡°Troy¡±, if any. Unlock the tables.
--My ANSWER
CREATE TRIGGER back_to_Troy
on EmployeeTerritories
AFTER INSERT
AS
BEGIN
  if (SELECT COUNT(distinct et.EmployeeID) FROM Territories t left join EmployeeTerritories et on t.TerritoryID = et.TerritoryID WHERE t.TerritoryDescription = 'Stevens Point') >100
  BEGIN
  UPDATE EmployeeTerritories 
  SET TerritoryID =(SELECT TerritoryID FROM Territories WHERE TerritoryDescription ='Troy')  
  WHERE  EmployeeID IN (SELECT EmployeeID FROM EmployeeTerritories WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription ='Stevens Point' AND RegionID=3))
  END
END

DROP TRIGGER back_to_Troy

--------------------------------------------------------------------
--correct answer
CREATE TRIGGER tr_move_emp_gaddam
ON EmployeeTerritories
AFTER INSERT
AS
DECLARE @EmpCount INT
SELECT @EmpCount = COUNT(*) FROM EmployeeTerritories WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription = 'Stevens Point' AND RegionID=3) GROUP BY EmployeeID
IF (@EmpCount>100)
BEGIN
UPDATE EmployeeTerritories
SET TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription ='Troy')
WHERE EmployeeID IN (SELECT EmployeeID FROM EmployeeTerritories WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription ='Stevens Point' AND RegionID=3))
END

DROP TRIGGER tr_move_emp_gaddam

COMMIT




--9 Create 2 new tables ¡°people_your_last_name¡± ¡°city_your_last_name¡±. City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}. Remove city of Seattle. If there was anyone from Seattle, put them into a new city ¡°Madison¡±. Create a view ¡°Packers_your_name¡± lists all people from Green Bay. If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
create table City_Qie(
Id INT Primary key identity(1,1),
City Varchar(20)
)
insert into City_Qie values('Seattle'),('Green Bay')
select * from City_Qie

CREATE TABLE People_Qie(
ID int primary key identity(1,1),
Name varchar(20),
City INT foreign key REFERENCES City_Qie(Id)
)
Insert into People_Qie values('Aaron Rodgers', 2), ('Russell Wilson', 1),('Jody Nelson',2)
SELECT * FROM People_Qie
-- If there was anyone from Seattle, put them into a new city ¡°Madison¡±. 

IF(select COUNT(pq.ID) FROM People_Qie pq left join City_Qie cq on pq.City = cq.Id WHERE cq.City = 'Seattle')>0 
begin
insert into City_Qie values('Madison')
UPDATE People_Qie Set City = 3 WHERE City = 1
end




--Create a view ¡°Packers_your_name¡± lists all people from Green Bay
CREATE VIEW Packers_Langyu_Qie
AS
SELECT pq.Name
FROM People_Qie pq left join City_Qie cq on cq.ID=pq.City
WHERE cq.City = 'Green Bay'

select * from Packers_Langyu_Qie

DROP TABLE City_Qie
DROP TABLE People_Qie
DROP VIEW Packers_Langyu_Qie




------------------------correct answer -----------------------------
CREATE TABLE People_Gaddam
(
id int ,
name nvarchar(100),
city int
)

create table City_Gaddam
(
id int,
city nvarchar(100)
)
BEGIN TRAN 
insert into City_Gaddam values(1,'Seattle')
insert into City_Gaddam values(2,'Green Bay')

insert into People_Gaddam values(1,'Aaron Rodgers',1)
insert into People_Gaddam values(2,'Russell Wilson',2)
insert into People_Gaddam values(3,'Jody Nelson',2)

if exists(select id from People_Gaddam where city = (select id from City_Gaddam where city = 'Seatle'))
begin
insert into City_Gaddam values(3,'Madison')
update People_Gaddam
set city = 'Madison'
where id in (select id from People_Gaddam where city = (select id from City_Gaddam where city = 'Seatle'))
end
delete from City_Gaddam where city = 'Seattle'

CREATE VIEW Packers_Gaddam
AS
SELECT name FROM People_Gaddam WHERE city = 'Green Bay'

select * from Packers_Gaddam
commit
drop table People_Gaddam
drop table City_Gaddam
drop view Packers_Gaddam








--10 Create a stored procedure ¡°sp_birthday_employees_[you_last_name]¡± that creates a new table ¡°birthday_employees_your_last_name¡± and fill it with all employees that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected.
create proc sp_birthday_employees_qie
as
begin

SELECT EmployeeID, LastName+' '+FirstName AS FullName, BirthDate INTO birthday_employees_qie
FROM Employees
WHERE Month(BirthDate)=2

end

select * from birthday_employees_qie

drop table birthday_employees_qie





--11 Create a stored procedure named ¡°sp_your_last_name_1¡± that returns all cites that have at least 2 customers who have bought no or only one kind of product. Create a stored procedure named ¡°sp_your_last_name_2¡± that returns the same but using a different approach. (sub-query and no-sub-query).
create proc sp_qie_1
as 
begin
SELECT City FROM CUSTOMERS
GROUP BY City
HAVING COUNT(*)>2
INTERSECT
SELECT City FROM Customers C JOIN Orders O ON O.CustomerID=C.CustomerID JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY OD.ProductID,C.CustomerID,City
HAVING COUNT(*) BETWEEN 0 AND 1
end
GO
EXEC sp_qie_1
GO



--(?????????????????????????????)
CREATE PROC sp_qie_2
AS
BEGIN
SELECT City FROM CUSTOMERS
WHERE CITY IN (SELECT City FROM Customers C JOIN Orders O ON O.CustomerID=C.CustomerID JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY OD.ProductID,C.CustomerID,City
HAVING COUNT(*) BETWEEN 0 AND 1)
GROUP BY City
HAVING COUNT(*)>2
END
GO
EXEC sp_qie_2
GO


--12 How do you make sure two tables have the same data?
-- Use EXCEPT keyword
/* select * from Table1
   EXCEPT
   Select * from Table2
   If what returned is a empty table, than table1 and table2 have the same data.
*/




/* 14
First Name	Last Name	Middle Name
John	     Green	
Mike	     White	        M
Output should be
 Full Name
John Green
Mike White M.
Note: There is a dot after M when you output.
*/
create table #Name(
[First Name] varchar(20),
[Last Name]   varchar(20),
[Middle Name] varchar(20))
insert into #Name values ('John', 'Green', null), ('Mike', 'White', 'M')




SELECT [First Name]+ ' '+ [Last Name]+ ' '+ISNULL([Middle Name]+'.', ' ')
 AS [Full Name]
FROM #Name

/*15 
Student	Marks	Sex
Ci      70	     F
Bob	    80	     M
Li	    90       F
Mi	    95	     M
Find the top marks of Female students.
If there are to students have the max score, only output one.
*/
create table #StuMark(
Student  varchar(20),
Marks INT,
Sex char(1) NOT NULL CHECK (Sex IN('M','F')))
insert into #StuMark(Student, Marks, Sex) values('Ci', 70, 'F'),
                                               ('Bob', 80, 'M'),
                                               ('Li', 90, 'F'),
											   ('Mi', 95, 'M')
											   
SELECT  dt.Student,dt.Marks
FROM 
(SELECT Student, Marks,Sex,  ROW_NUMBER() OVER(Partition by Sex Order by Marks DESC) AS RNK
FROM #StuMark) dt
WHERE RNK =1 AND Sex = 'F'



/* 16
Student	Marks	Sex
Li	     90	     F
Ci	     70	     F
Mi	     95	     M
Bob    	 80	     M
How do you out put this?*/

SELECT  Student,Marks, Sex
FROM #StuMark
ORDER BY 3,2 desc

create table Name1(
[First Name] varchar(20),
[Last Name]   varchar(20),
[Middle Name] varchar(20))
insert into Name1 values ('John', 'Green', null), ('Mike', 'White', 'M')

select * into Name2 from Name1

select * from Name1
EXCEPT
Select * from Name2
drop table Name1
drop table Name2