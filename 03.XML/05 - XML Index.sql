

/*
PRIMARY XML Index
*/

USE WideWorldImporters;
GO

DROP TABLE IF EXISTS Sales.OrderSummary;
GO

CREATE TABLE Sales.OrderSummary
	(
		ID INT NOT NULL	IDENTITY,
		CustomerID INT NOT NULL,
		OrderSummary XML
	);
GO

INSERT INTO Sales.OrderSummary(CustomerID,OrderSummary)
SELECT 
	CustomerID,
	(SELECT
		CustomerName 'OrderHeader/CustomerName',
		OrderDate 'OrderHeader/OrderDate',
		OrderID 'OrderHeader/OrderID',
		(SELECT
			LineItems2.StockItemID '@ProductID',
			StockItems.StockItemName '@ProductName',
			LineItems2.UnitPrice '@Price',
			Quantity '@Qty'
		 FROM Sales.OrderLines AS LineItems2
		 INNER JOIN Warehouse.StockItems AS StockItems
			ON LineItems2.StockItemID = StockItems.StockItemID
			WHERE LineItems2.OrderID = Base.OrderID
		 FOR XML PATH('Product'), TYPE) AS 'OrderDetails'
	 FROM (SELECT
				DISTINCT Customers.CustomerName,
				SalesOrder.OrderDate,
				SalesOrder.OrderID
		   FROM Sales.Orders AS SalesOrder
		   INNER JOIN Sales.OrderLines AS LineItem
				ON SalesOrder.OrderID = LineItem.OrderID
		   INNER JOIN Sales.Customers AS Customers
				ON Customers.CustomerID = SalesOrder.CustomerID
				WHERE customers.CustomerID = OuterCust.CustomerID) AS Base
		  FOR XML PATH('Order'),ROOT('SalesOrders'),TYPE) AS OrderSummary
FROM Sales.Customers OuterCust;
GO

SP_HELPINDEX 'Sales.OrderSummary';
GO

-- بر روی جدول UNIQUE CLUSTERED INDEX ایجاد
CREATE UNIQUE CLUSTERED INDEX UC_Indx_ID
	ON Sales.OrderSummary(ID);
GO

SP_HELPINDEX 'Sales.OrderSummary';
GO

-- بر روی جدول PRIMARY KEY به دلیل عدم وجود PRIMARY XML INDEX خطا در ایجاد
CREATE PRIMARY XML INDEX PX_Indx_OrderSummary 
	ON Sales.OrderSummary (OrderSummary);
GO

DROP INDEX IF EXISTS UC_Indx_ID
	ON Sales.OrderSummary;
GO

ALTER TABLE Sales.OrderSummary
	ADD PRIMARY KEY (ID);
GO

SP_HELPINDEX 'Sales.OrderSummary';
GO

-- بر روی جدول PRIMARY XML INDEX ایجاد
CREATE PRIMARY XML INDEX PX_Indx_OrderSummary 
	ON Sales.OrderSummary (OrderSummary);
GO

SP_HELPINDEX 'Sales.OrderSummary';
GO

SELECT * FROM sys.xml_indexes;
GO
--------------------------------------------------------------------

/*
Secondary XML Index
*/

CREATE XML INDEX SX_Indx_Path_OrderSummary
	ON Sales.OrderSummary (OrderSummary)
	USING XML INDEX PX_Indx_OrderSummary FOR PATH;
GO

SELECT * FROM sys.xml_indexes;
GO

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS TIME ON;
GO

SELECT * FROM Sales.OrderSummary 
	WHERE OrderSummary.exist('/SalesOrders/Order/OrderDetails/Product/.[@ProductID = 223]') = 1;
GO

DROP INDEX IF EXISTS SX_Indx_Path_OrderSummary
	ON Sales.OrderSummary;
GO

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SELECT * FROM Sales.OrderSummary 
	WHERE OrderSummary.exist('/SalesOrders/Order/OrderDetails/Product/.[@ProductID = 223]') = 1;
GO

DROP INDEX IF EXISTS PX_Indx_OrderSummary
	ON Sales.OrderSummary;
GO

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SELECT * FROM Sales.OrderSummary
	WHERE OrderSummary.exist('/SalesOrders/Order/OrderDetails/Product/.[@ProductID = 223]') = 1;
GO