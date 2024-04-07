
/*
Encryption
*/

USE Programmer;
GO

SP_HELPTEXT 'GetAllCustomers';
GO

ALTER PROCEDURE GetAllCustomers
WITH ENCRYPTION
AS
BEGIN	
	SELECT 
		CustomerID, City
	FROM Customers;
END
GO
--------------------------------------------------------------------

/*
WITH RESULT SETS
*/

USE AdventureWorks2019;
GO

CREATE OR ALTER PROCEDURE Get_Order_Info
(
	@OrderID AS INT
)
AS
	SELECT 
		SalesOrderID, OrderDate, TotalDue, CurrencyRateID
		FROM Sales.SalesOrderHeader
		WHERE SalesOrderID = @OrderID;

	SELECT 
		SalesOrderID, SalesOrderDetailID, OrderQty
	FROM Sales.SalesOrderDetail
		WHERE SalesOrderID = @OrderID;
GO

EXEC Get_Order_Info @OrderID = 43671;
GO

EXEC Get_Order_Info @OrderID = 43671
	WITH RESULT SETS
	(
		(
			[شماره سفارش] INT NOT NULL,
			OrderDate_New DATE NOT NULL,
			TotalDue INT NOT NULL,
			CurrencyRateID INT NULL
		),
		(
			SalesOrderID_New INT NOT NULL,
			SalesOrderDetailID INT NOT NULL,
			OrderQty SMALLINT NOT NULL
		)
);
GO