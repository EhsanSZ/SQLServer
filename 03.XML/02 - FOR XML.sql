

USE WideWorldImporters;
GO

/*
FOR XML RAW
*/

SELECT 
	SalesOrder.OrderDate, Customers.CustomerName,
	SalesOrder.OrderID, Product.StockItemName,
	LineItem.Quantity, LineItem.UnitPrice
FROM Sales.Orders AS SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON LineItem.OrderID = SalesOrder.OrderID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
	WHERE customers.CustomerName = 'Anand Mudaliyar';
GO

-- XML Fragment
SELECT 
	SalesOrder.OrderDate, Customers.CustomerName,
	SalesOrder.OrderID, Product.StockItemName,
	LineItem.Quantity, LineItem.UnitPrice
FROM Sales.Orders AS SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON LineItem.OrderID = SalesOrder.OrderID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
	WHERE customers.CustomerName = 'Anand Mudaliyar'
FOR XML RAW;
GO

-- (Well-Formed) ROOT افزودن عنصر
SELECT 
	SalesOrder.OrderDate, Customers.CustomerName,
	SalesOrder.OrderID, Product.StockItemName,
	LineItem.Quantity, LineItem.UnitPrice
FROM Sales.Orders AS SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON LineItem.OrderID = SalesOrder.OrderID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
	WHERE customers.CustomerName = 'Anand Mudaliyar'
FOR XML RAW, ROOT;
GO

-- با نام دلخواه ROOT افزودن عنصر
SELECT 
	SalesOrder.OrderDate, Customers.CustomerName,
	SalesOrder.OrderID, Product.StockItemName,
	LineItem.Quantity, LineItem.UnitPrice
FROM Sales.Orders AS SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON LineItem.OrderID = SalesOrder.OrderID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
	WHERE customers.CustomerName = 'Anand Mudaliyar'
FOR XML RAW, ROOT('SalesOrders');
GO

-- ELEMENTS با افزودن Element-Centric ایجاد ساختار
SELECT 
	SalesOrder.OrderDate, Customers.CustomerName,
	SalesOrder.OrderID, Product.StockItemName,
	LineItem.Quantity, LineItem.UnitPrice
FROM Sales.Orders AS SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON LineItem.OrderID = SalesOrder.OrderID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
	WHERE customers.CustomerName = 'Anand Mudaliyar'
FOR XML RAW, ROOT('SalesOrders'), ELEMENTS;
GO

-- <row> تعیین نام دلخواه برای 
SELECT 
	SalesOrder.OrderDate, Customers.CustomerName,
	SalesOrder.OrderID, Product.StockItemName,
	LineItem.Quantity, LineItem.UnitPrice
FROM Sales.Orders AS SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON LineItem.OrderID = SalesOrder.OrderID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
	WHERE customers.CustomerName = 'Anand Mudaliyar'
FOR XML RAW('LineItem'), ROOT('SalesOrders'), ELEMENTS;
GO
--------------------------------------------------------------------

/*
FOR XML AUTO
*/

SELECT 
	SalesOrder.OrderDate, Customers.CustomerName,
	SalesOrder.OrderID, Product.StockItemName,
	LineItem.Quantity, LineItem.UnitPrice
FROM Sales.Orders SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON LineItem.OrderID = SalesOrder.OrderID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
WHERE customers.CustomerName = 'Anand Mudaliyar'
FOR XML AUTO;
GO

SELECT 
	SalesOrder.OrderDate, Customers.CustomerName,
	SalesOrder.OrderID, Product.StockItemName,
	LineItem.Quantity, LineItem.UnitPrice
FROM Sales.Orders AS SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON LineItem.OrderID = SalesOrder.OrderID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
	WHERE customers.CustomerName = 'Anand Mudaliyar'
FOR XML AUTO, ROOT('SalesOrders');
GO

/*
SELECT ایده‌‌آل‌تر شدن خروجی کوئری بالا صرفا با تغییر فراخوانی نام فیلدها در بخش
<Customers>
	<SalesOrder>
		<LineItem>
			<Product>
*/
SELECT 
	Customers.CustomerName,
	SalesOrder.OrderDate, SalesOrder.OrderID,
	LineItem.Quantity, LineItem.UnitPrice,
	Product.StockItemName
FROM Sales.Orders SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON LineItem.OrderID = SalesOrder.OrderID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
	WHERE customers.CustomerName = 'Anand Mudaliyar'
FOR XML AUTO, ROOT('SalesOrders');
GO

SELECT 
	Customers.CustomerName,
	SalesOrder.OrderDate, SalesOrder.OrderID,
	LineItem.Quantity, LineItem.UnitPrice,
	Product.StockItemName
FROM Sales.Orders SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON LineItem.OrderID = SalesOrder.OrderID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
	WHERE customers.CustomerName = 'Anand Mudaliyar'
FOR XML AUTO, ROOT('SalesOrders'), ELEMENTS;
GO
--------------------------------------------------------------------

/*
FOR XML PATH

@:	Map to an Attribute
no @:	@: Map to an Element
/:	Define a node’s location in the hierarchy
*/

/*
-- .زیر باشد XML در قالب SELECT فرض کنید می‌خواهیم خروجی دستور
<SalesOrders>
	<Order>
		<OrderHeader>
			<CustomerName>Anand Mudaliyar</CustomerName>
			<OrderDate>2016-05-24</OrderDate>
			<OrderID>73081</OrderID>
		</OrderHeader>
		<OrderDetails>
			<Product ProductID="88"
					 ProductName="&quot;The Gu&quot; red shirt XML tag t-shirt (White) 7XL" 
					 Price="18.00" 
					 Qty="72" />
			<Product ProductID="59" 
					 ProductName="RC toy sedan car with remote control (Red) 1/50 scale" 
					 Price="25.00" 
					 Qty="2" />
			<Product 
					 ProductID="195" 
					 ProductName="Black and orange handle with care despatch tape  48mmx75m" 
					 Price="3.70" 
					 Qty="216" />
			<Product ProductID="160" 
					 ProductName="20 mm Double sided bubble wrap 20m" 
					 Price="33.00" 
					 Qty="20" />
		</OrderDetails>
	</Order>
	...
*/

-- Root Node و Repeating Elemnt تعیین
SELECT
	...
FOR XML PATH('Orders'), ROOT('SlesOrders') ;
GO

-- OrderHeader های مربوط به Child Element تعیین
SELECT 
	  CustomerName AS 'OrderHeader/CustomerName',
	  OrderDate AS 'OrderHeader/OrderDate',
	  OrderID AS 'OrderHeader/OrderID'
...
FOR XML PATH('Orders'), ROOT('SlesOrders');
GO

SELECT 
	  CustomerName AS 'OrderHeader/CustomerName',
	  OrderDate AS 'OrderHeader/OrderDate',
	  OrderID AS 'OrderHeader/OrderID',
	  (	SELECT
			LineItems2.StockItemID AS '@ProductID',
			StockItems.StockItemName AS '@ProductName',
			LineItems2.UnitPrice AS '@Price',
			Quantity AS '@Qty'
		FROM Sales.OrderLines AS LineItems2
		INNER JOIN Warehouse.StockItems AS StockItems
			ON LineItems2.StockItemID = StockItems.StockItemID
			WHERE LineItems2.OrderID = Base.OrderID
		FOR XML PATH('Product'), TYPE) AS 'OrderDetails'
FROM (	SELECT
			DISTINCT Customers.CustomerName,
			SalesOrder.OrderDate,
			SalesOrder.OrderID
		FROM Sales.Orders AS SalesOrder
		INNER JOIN Sales.OrderLines AS LineItem
			ON SalesOrder.OrderID = LineItem.OrderID
		INNER JOIN Sales.Customers AS Customers
			ON Customers.CustomerID = SalesOrder.CustomerID
			WHERE Customers.CustomerName = 'Anand Mudaliyar'
	 ) AS Base
FOR XML PATH('Order'), ROOT('SlesOrders');
GO
--------------------------------------------------------------------

/*
FOR XML EXPLICIT

[Name Complex!Tag Identifier!Name Node!ELEMENTS]
*/
SELECT  
	1 AS Tag,
	0 AS Parent,
	SalesOrder.OrderID AS [OrderDetails!1!SalesOrderID], -- OrderDetails Attribute
	SalesOrder.OrderDate AS [OrderDetails!1!OrderDate], -- OrderDetails Attribute
	SalesOrder.CustomerID AS [OrderDetails!1!CustomerID], -- OrderDetails Attribute
	NULL AS [SalesPerson!2!SalesPersonName], -- Sibling Node
	NULL AS [LineItem!3!LineTotal!ELEMENT], -- Sibling Node
	NULL AS [LineItem!3!ProductName!ELEMENT], -- Sibling Node
	NULL AS [LineItem!3!OrderQty!ELEMENT] -- Sibling Node
FROM Sales.Orders AS SalesOrder
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
	WHERE customers.CustomerName = 'Anand Mudaliyar'
UNION ALL   
SELECT 
	2 AS Tag,
	1 AS Parent,
	SalesOrder.OrderID,
	NULL,
	NULL,
	People.FullName,
	NULL,
	NULL,
	NULL           
FROM Sales.Orders AS SalesOrder
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
INNER JOIN Application.People AS People
	ON People.PersonID = SalesOrder.SalespersonPersonID
WHERE customers.CustomerName = 'Anand Mudaliyar'
UNION ALL  
SELECT 
	3 AS Tag,
	1 AS Parent,
	SalesOrder.OrderID,
	NULL,
	NULL,
	People.FullName,
	LineItem.UnitPrice,
	Product.StockItemName,
	LineItem.Quantity     
FROM Sales.Orders AS SalesOrder
INNER JOIN Sales.OrderLines AS LineItem
	ON SalesOrder.OrderID = LineItem.OrderID  
INNER JOIN Sales.Customers AS Customers
	ON Customers.CustomerID = SalesOrder.CustomerID
INNER JOIN Warehouse.StockItems AS Product
	ON Product.StockItemID = LineItem.StockItemID
INNER JOIN Application.People People
	ON People.PersonID = SalesOrder.SalespersonPersonID
	WHERE Customers.CustomerName = 'Anand Mudaliyar'
ORDER BY
	[OrderDetails!1!SalesOrderID],
	[SalesPerson!2!SalesPersonName],
	[LineItem!3!LineTotal!ELEMENT]  
FOR XML EXPLICIT, ROOT('SalesOrders'); 
GO
--------------------------------------------------------------------

/*
Binary Data & XML
*/

USE Northwind;
GO

SELECT 
	EmployeeID, FirstName, LastName, Photo
FROM Employees 
FOR XML AUTO, ROOT('Employees_Root');
GO

SELECT 
	EmployeeID, FirstName, LastName, Photo
FROM Employees 
FOR XML AUTO, BINARY BASE64, ROOT('Employees_Root');
GO
--------------------------------------------------------------------

SELECT 
	EmployeeID, FirstName, LastName
FROM Employees
FOR XML PATH('Employees'), ROOT('Employees_Root');
GO

-- Repeating Element حذف
SELECT 
	EmployeeID,FirstName,LastName
FROM Employees 
FOR XML PATH(''),ROOT('Employees_Root');
GO
--------------------------------------------------------------------

SELECT 
	EmployeeID AS "@EmpID",
	FirstName AS "@FirstName",
	LastName
FROM Employees 
FOR XML PATH;
GO

-- .بیاید Non-Attribute-Centric Column قبل از Attribute-centric Column در این حالت می‌بایست حتما
SELECT 
	EmployeeID,
	FirstName AS "@FirstName",
	LastName
FROM Employees 
FOR XML PATH; -- AUTO , RAW
GO
--------------------------------------------------------------------

SELECT 
	CustomerID AS "@CustCode",
	CompanyName AS "@CompName",
	Country AS "Location/Country", -- Element for Location
	City AS "Location/City" -- Element for Location
FROM Customers
FOR XML PATH,ROOT('Customers_Root');
GO
--------------------------------------------------------------------

-- FOR XML XMLSCHEMA
SELECT 
	EmployeeID,FirstName,LastName
FROM Employees 
FOR XML AUTO, XMLSCHEMA;
GO

SELECT 
	EmployeeID,FirstName,LastName
FROM Employees 
	WHERE 1> 100
FOR XML AUTO, XMLSCHEMA;
GO