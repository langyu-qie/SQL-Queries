--Using AdventureWorks Database

--1 retrieves the columns ProductID, Name, Color and ListPrice from the Production.Product table, with no filter. 
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product

--2 retrieves the columns ProductID, Name, Color and ListPrice from the Production.Product table, exclude the rows that are 0 for the column ListPrice
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE NOT ListPrice = 0

--3 retrieves the columns ProductID, Name, Color and ListPrice from the Production.Product table, the rows that are rows that are NULL for the Color column.
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Color is NULL

--4 retrieves the columns ProductID, Name, Color and ListPrice from the Production.Product table, the rows that are not NULL for the Color column.
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Color is NOT NULL

--5 retrieves the columns ProductID, Name, Color and ListPrice from the Production.Product table, the rows that are not NULL for the column Color, and the column ListPrice has a value greater than zero.
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Color is NOT NULL AND ListPrice>0

--6  6.	Generate a report that concatenates the columns Name and Color from the Production.Product table by excluding the rows that are null for color.
SELECT Name +' is '+ Color
From Production.Product
WHERE Color is NOT NULL

/*7  Generates the following result set  from Production.Product:
Name And Color
--------------------------------------------------
NAME: LL Crankarm  --  COLOR: Black
NAME: ML Crankarm  --  COLOR: Black
NAME: HL Crankarm  --  COLOR: Black
NAME: Chainring Bolts  --  COLOR: Silver
NAME: Chainring Nut  --  COLOR: Silver
NAME: Chainring  --  COLOR: Black
    ………
*/
SELECT 'Name: '+Name+' -- COLOR: '+Color AS [Name And Color]
FROM Production.Product
WHERE Name is not null AND Color is not NULL

--8 retrieve the to the columns ProductID and Name from the Production.Product table filtered by ProductID from 400 to 500
SELECT ProductID, Name 
FROM Production.Product
WHERE ProductID Between 400 AND 500

--9 retrieve the to the columns  ProductID, Name and color from the Production.Product table restricted to the colors black and blue
SELECT ProductID, Name, Color
FROM Production.Product
WHERE Color='black' or Color = 'Blue'

--10 generate a report on products that begins with the letter S. 
SELECT Name as [products beginning with letter s]
FROM Production.Product
WHERE  Name LIKE 'S%'

/*11
Retrieves the columns Name and ListPrice from the Production.Product table. Your result set should look something like the following. Order the result set by the Name column. 
 
Name                                               ListPrice
-------------------------------------------------- -----------
Seat Lug                                           0,00
Seat Post                                          0,00
Seat Stays                                         0,00
Seat Tube                                          0,00
Short-Sleeve Classic Jersey, L                     53,99
Short-Sleeve Classic Jersey, M                     53,99

*/
SELECT Name,  ListPrice
FROM Production.Product
WHERE Name LIKE 'SE%' or Name LIKE  'Sh%'
ORDER BY ListPrice, Name

/*12 
Retrieves the columns Name and ListPrice from the Production.Product table. Your result set should look something like the following. Order the result set by the Name column. The products name should start with either 'A' or 'S'
 
Name                                               ListPrice
-------------------------------------------------- ----------
Adjustable Race                                    0,00
All-Purpose Bike Stand                             159,00
AWC Logo Cap                                       8,99
Seat Lug                                           0,00
Seat Post                                          0,00

*/
SELECT  Name, ListPrice
FROM Production.Product
WHERE Name LIKE '[A,S]%'
Order BY Name

--13  retrieve rows that have a Name that begins with the letters SPO, but is then not followed by the letter K. After this zero or more letters can exists. Order the result set by the Name column.
SELECT  Name
FROM Production.Product
WHERE Name Like 'spo[^k]%'
ORDER BY Name

--14  retrieves unique colors from the table Production.Product. Order the results  in descending  manner
SELECT DISTINCT Color
FROM Production.Product
Order BY Color DESC

--15 retrieves the unique combination of columns ProductSubcategoryID and Color from the Production.Product table. Format and sort so the result set accordingly to the following. We do not want any rows that are NULL.in any of the two columns in the result.
SELECT DISTINCT ProductSubcategoryID, Color
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL AND Color is not null
GROUP BY ProductSubcategoryID, Color

--16 We do not want any Red or Black products from any SubCategory than those with the value of 1 in column ProductSubCategoryID, unless they cost between 1000 and 2000
SELECT ProductSubCategoryID, LEFT([Name],35) AS [Name] , Color, ListPrice 
FROM Production.Product
WHERE (Color NOT IN ('Red','Black') 
      OR ListPrice BETWEEN 1000 AND 2000 )
      OR ProductSubCategoryID = 1   
ORDER BY ProductID
 
