--*************************************************************************--
-- Title: Assignment06
-- Author: JaquelynGoldsberry
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,JaquelynGoldsberry,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JaquelynGoldsberry')
	 Begin 
	  Alter Database [Assignment06DB_JaquelynGoldsberry] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JaquelynGoldsberry;
	 End
	Create Database Assignment06DB_JaquelynGoldsberry;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JaquelynGoldsberry;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

 -- Create Products View
 Go
 Create 
 View vProducts With SchemaBinding
 As
	Select ProductID, ProductName,CategoryID, UnitPrice 
	From dbo.Products
Go

-- Create Categories View
Create
View vCategories With SchemaBinding
As
	Select CategoryID, CategoryName
	From dbo.Categories
Go

-- Create Employee View
Create
View vEmployees With SchemaBinding
As
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From dbo.Employees
Go

-- Create Inventory View
Create
View vInventories With SchemaBinding
As
	Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
	From dbo.Inventories
Go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Set permisions for Products
Deny Select On Products to Public;
Grant Select On vProducts to Public;

-- Set permisions for Categories
Deny Select On Categories to Public;
Grant Select On vCategories to Public;

-- Set permisions for Inventories
Deny Select On Inventories to Public;
Grant Select On vInventories to Public;

-- Set permisions for Employees
Deny Select On Employees to Public;
Grant Select On vEmployees to Public;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/*
-- See both tables
Select * from vProducts
Select * from vCategories

-- Join on Category ID & select columns
Select CategoryName, ProductName, UnitPrice
	from vProducts as p
		Join vCategories as c on c.CategoryID = p.CategoryID

-- Order results
Select CategoryName, ProductName, UnitPrice
	from vProducts as p
		Join vCategories as c on c.CategoryID = p.CategoryID
order by CategoryName, ProductName
*/
-- Create view
go
Create
View vProductsByCategories With SchemaBinding
As
Select CategoryName, ProductName, UnitPrice
	from vProducts as p
		Join vCategories as c on c.CategoryID = p.CategoryID
order by CategoryName, ProductName

go
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

/*
-- See both tables
Select * from vProducts
Select * from vInventories

-- Join on ProductID and select columns
Select ProductName, InventoryDate, i.Count
	from vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID

-- Order results
Select ProductName, InventoryDate, i.Count
	from vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
Order by ProductName, InventoryDate, Count
*/

-- Create view
go
Create
View vInventoriesByProductsByDates With SchemaBinding
As
Select ProductName, InventoryDate, i.Count
	from vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
Order by ProductName, InventoryDate, Count
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
/*
-- See tables
Select*from vEmployees
Select*from vInventories

-- Join on EmployeeID and select relevant columns
Select InventoryDate, EmployeeFirstName, EmployeeLastName
	from vEmployees as e
		Join vInventories as i on e.EmployeeID=i.EmployeeID

-- Select only distinct rows
Select Distinct InventoryDate, EmployeeFirstName, EmployeeLastName
	from vEmployees as e
		Join vInventories as i on e.EmployeeID=i.EmployeeID

-- Combine first and last name into one field
Select Distinct 
	InventoryDate, 
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
	from vEmployees as e
		Join vInventories as i on e.EmployeeID=i.EmployeeID

-- Order results by date
Select Distinct 
	InventoryDate, 
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
	from vEmployees as e
		Join vInventories as i on e.EmployeeID=i.EmployeeID
Order by InventoryDate

*/
-- Create view
go
Create
View vInventoriesByEmployeesByDates With SchemaBinding
As
Select Distinct 
	InventoryDate, 
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
	from vEmployees as e
		Join vInventories as i on e.EmployeeID=i.EmployeeID
Order by InventoryDate
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

/*
-- See all tables
Select * from vCategories
Select * from vProducts
Select * from vInventories

-- Join & select relevant columns
Select CategoryName, ProductName, InventoryDate, i.Count
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID

-- Order results
Select CategoryName, ProductName, InventoryDate, i.Count
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
Order by CategoryName, ProductName, InventoryDate, Count
*/

-- Create view
go
Create
View vInventoriesByProductsByCategories With SchemaBinding
As
Select CategoryName, ProductName, InventoryDate, i.Count
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
Order by CategoryName, ProductName, InventoryDate, Count
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

/*
-- See tables
Select*from vEmployees
Select*from vInventories

-- Join Employee on results from Q6 & add employee name
Select 
	CategoryName, 
	ProductName, 
	InventoryDate, 
	i.Count, 
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
		Join vEmployees as e on i.EmployeeID = e.EmployeeID

-- Order results
Select 
	CategoryName, 
	ProductName, 
	InventoryDate, 
	i.Count, 
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
		Join vEmployees as e on i.EmployeeID = e.EmployeeID
Order by InventoryDate, CategoryName, ProductName, EmployeeName
*/

-- Create view
go
Create
View vInventoriesByProductsByEmployees With SchemaBinding
As
Select 
	CategoryName, 
	ProductName, 
	InventoryDate, 
	i.Count, 
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
		Join vEmployees as e on i.EmployeeID = e.EmployeeID
Order by InventoryDate, CategoryName, ProductName, EmployeeName
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
/*
-- Subquery to find product ID
Select ProductID, ProductName
	From Products
	Where ProductName IN ('Chai','Chang')

-- Combine with results from Q7
Select 
	CategoryName, 
	ProductName, 
	InventoryDate, 
	i.Count, 
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
		Join vEmployees as e on i.EmployeeID = e.EmployeeID
	where p.ProductID IN (
		Select ProductID
			From vProducts
			Where ProductName IN ('Chai','Chang')
	)
Order by InventoryDate, CategoryName, ProductName, EmployeeName

*/
-- Create view
go
Create
View vInventoriesForChaiAndChangByEmployees With SchemaBinding
As
Select 
	CategoryName, 
	ProductName, 
	InventoryDate, 
	i.Count, 
	EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
		Join vEmployees as e on i.EmployeeID = e.EmployeeID
	where p.ProductID IN (
		Select ProductID
			From vProducts
			Where ProductName IN ('Chai','Chang')
	)
Order by InventoryDate, CategoryName, ProductName, EmployeeName
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

/*
--See all of employees table
Select * From vEmployees

--Self-join employee with itsef to get manager names
Select	[Manager Name] = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName,
		[Employee Name] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
From vEmployees as Emp
	Join vEmployees as Mgr On  Emp.ManagerID = Mgr.EmployeeID

-- Order the results by Manager's name
Select	[Manager Name] = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName,
		[Employee Name] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
From vEmployees as Emp
	Join vEmployees as Mgr On  Emp.ManagerID = Mgr.EmployeeID
Order by [Manager Name], [Employee Name]

*/
-- Create view
go
Create
View vEmployeesByManager With SchemaBinding
As
Select	[Manager Name] = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName,
		[Employee Name] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
From vEmployees as Emp
	Join vEmployees as Mgr On  Emp.ManagerID = Mgr.EmployeeID
Order by [Manager Name], [Employee Name]
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

/*
-- Start with results from Q7 & add columns
Select 
	c.CategoryID,
	CategoryName,
	p.ProductID,
	ProductName,
	UnitPrice,
	i.InventoryID,
	InventoryDate, 
	i.Count, 
	e.EmployeeID,
	EmployeeFirstName + ' ' + EmployeeLastName as Employee
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
		Join vEmployees as e on i.EmployeeID = e.EmployeeID

-- Add Manager Name
Select 
	c.CategoryID,
	CategoryName,
	p.ProductID,
	ProductName,
	UnitPrice,
	i.InventoryID,
	InventoryDate, 
	i.Count, 
	e.EmployeeID,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee,
	Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName as Manager
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
		Join vEmployees as e on i.EmployeeID = e.EmployeeID
		Join vEmployees as Mgr On  e.ManagerID = Mgr.EmployeeID


-- Order results
Select 
	c.CategoryID,
	CategoryName,
	p.ProductID,
	ProductName,
	UnitPrice,
	i.InventoryID,
	InventoryDate, 
	i.Count, 
	e.EmployeeID,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee,
	Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName as Manager
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
		Join vEmployees as e on i.EmployeeID = e.EmployeeID
		Join vEmployees as Mgr On  e.ManagerID = Mgr.EmployeeID
Order by CategoryName, ProductName, InventoryID, Employee
*/

-- Create view
go
Create
View vInventoriesByProductsByCategoriesByEmployees With SchemaBinding
As
Select 
	c.CategoryID,
	CategoryName,
	p.ProductID,
	ProductName,
	UnitPrice,
	i.InventoryID,
	InventoryDate, 
	i.Count, 
	e.EmployeeID,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee,
	Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName as Manager
	From vInventories as i
		Join vProducts as p on p.ProductID = i.ProductID
		Join vCategories as c on c.CategoryID = p.CategoryID
		Join vEmployees as e on i.EmployeeID = e.EmployeeID
		Join vEmployees as Mgr On  e.ManagerID = Mgr.EmployeeID
Order by CategoryName, ProductName, InventoryID, Employee
go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/