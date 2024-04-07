
USE AdventureWorks2019;
GO

DECLARE @SalesOrderID INT = 70233;
DECLARE @OrderDate DATETIME = '2014-04-08 00:00:00.000';
SELECT * FROM Sales.SalesOrderHeader
	WHERE (SalesOrderID = @SalesOrderID OR @SalesOrderID IS NULL)
	AND  (OrderDate = @OrderDate OR @OrderDate IS NULL);
GO

DECLARE @SalesOrderID INT = NULL;
DECLARE @OrderDate DATETIME = '2014-04-08 00:00:00.000';
SELECT * FROM Sales.SalesOrderHeader
	WHERE (SalesOrderID = @SalesOrderID OR @SalesOrderID IS NULL)
	AND  (OrderDate = @OrderDate OR @OrderDate IS NULL);
GO

DECLARE @SalesOrderID INT = 70233;
DECLARE @OrderDate DATETIME = NULL;
SELECT * FROM Sales.SalesOrderHeader
	WHERE (SalesOrderID = @SalesOrderID OR @SalesOrderID IS NULL)
	AND  (OrderDate = @OrderDate OR @OrderDate IS NULL);
GO

DECLARE @SalesOrderID INT = NULL;
DECLARE @OrderDate DATETIME = NULL;
SELECT * FROM Sales.SalesOrderHeader
	WHERE (SalesOrderID = @SalesOrderID OR @SalesOrderID IS NULL)
	AND  (OrderDate = @OrderDate OR @OrderDate IS NULL);
GO

/*
!به منظور نمایش صحیح پلن اجرایی، برای هر یک از کوئری‌های بالا را با مقادیر معادل متغیرها جاگذاری می‌کنیم
*/
DECLARE @SalesOrderID INT = 70233;
DECLARE @OrderDate DATETIME = '2014-04-08 00:00:00.000';
SELECT * FROM Sales.SalesOrderHeader
		WHERE (SalesOrderID = 70233 OR 70233 IS NULL)
		AND  (OrderDate = '2014-04-08 00:00:00.000' OR '2014-04-08 00:00:00.000' IS NULL);
GO

DECLARE @SalesOrderID INT = NULL;
DECLARE @OrderDate DATETIME = '2014-04-08 00:00:00.000';
SELECT * FROM Sales.SalesOrderHeader
		WHERE (SalesOrderID IS NULL OR @SalesOrderID IS NULL)
		AND  (OrderDate = '2014-04-08 00:00:00.000' OR '2014-04-08 00:00:00.000' IS NULL);
GO

DECLARE @SalesOrderID INT = 70233;
DECLARE @OrderDate DATETIME = NULL;
SELECT * FROM Sales.SalesOrderHeader
	WHERE (SalesOrderID = 70233 OR 70233 IS NULL)
	AND  (OrderDate IS NULL OR @OrderDate IS NULL);
GO

DECLARE @SalesOrderID INT = NULL;
DECLARE @OrderDate DATETIME = NULL;
SELECT * FROM Sales.SalesOrderHeader
	WHERE (SalesOrderID IS NULL OR @SalesOrderID IS NULL)
	AND  (OrderDate IS NULL OR @OrderDate IS NULL);
GO
--------------------------------------------------------------------

CREATE OR ALTER PROCEDURE GetSalesOrderHeader
(
	@SalesOrderID INT,
	@OrderDate DATETIME
)
AS
	SELECT * FROM Sales.SalesOrderHeader
	WHERE (SalesOrderID = @SalesOrderID OR @SalesOrderID IS NULL)
	AND  (OrderDate = @OrderDate OR @OrderDate IS NULL);
GO

EXEC GetSalesOrderHeader 43671,NULL;
GO

EXEC GetSalesOrderHeader NULL,'2005-07-01 00:00:00.000';
GO
--------------------------------------------------------------------

/*
ها به ترتیبی دیگر SP و فراخوانی PROCEDURE ایجاد مجدد
*/
CREATE OR ALTER PROCEDURE GetSalesOrderHeader
(
	@SalesOrderID INT,
	@OrderDate DATETIME
)
AS
	SELECT * FROM Sales.SalesOrderHeader
	WHERE (SalesOrderID = @SalesOrderID OR @SalesOrderID IS NULL)
	AND  (OrderDate = @OrderDate OR @OrderDate IS NULL);
GO

EXEC GetSalesOrderHeader NULL,'2005-07-01 00:00:00.000';
GO

EXEC GetSalesOrderHeader 43671,NULL;
GO
--------------------------------------------------------------------

/*
Recompile
*/
CREATE OR ALTER PROCEDURE GetSalesOrderHeader
(
	@SalesOrderID INT,
	@OrderDate DATETIME
)
WITH RECOMPILE
AS
	SELECT * FROM Sales.SalesOrderHeader
	WHERE (SalesOrderID = @SalesOrderID OR @SalesOrderID IS NULL)
	AND  (OrderDate = @OrderDate OR @OrderDate IS NULL);
GO

EXEC GetSalesOrderHeader NULL,'2005-07-01 00:00:00.000';
GO

EXEC GetSalesOrderHeader 43671,NULL;
GO
--------------------------------------------------------------------

/*
OPTIMIZE FOR
*/
CREATE OR ALTER PROCEDURE GetSalesOrderHeader
(
	@SalesOrderID INT,
	@OrderDate DATETIME
)
AS
	SELECT * FROM Sales.SalesOrderHeader
	WHERE (SalesOrderID = @SalesOrderID OR @SalesOrderID IS NULL)
	AND  (OrderDate = @OrderDate OR @OrderDate IS NULL)
	OPTION (OPTIMIZE FOR (@SalesOrderID = 43671,@OrderDate = '2005-07-01 00:00:00.000'));
GO


EXEC GetSalesOrderHeader 43671,'2005-07-01 00:00:00.000';
GO

EXEC GetSalesOrderHeader NULL,'2005-07-01 00:00:00.000';
GO

EXEC GetSalesOrderHeader 43671,NULL;
GO
--------------------------------------------------------------------

/*
sp_executesql
*/
DROP PROCEDURE IF EXISTS GetSalesOrderHeader;
GO

CREATE PROCEDURE GetSalesOrderHeader
(
	@SalesOrderID INT,
	@OrderDate DATETIME
)
AS
	DECLARE @Cmd NVARCHAR(1000);
	SET @Cmd = N'SELECT * FROM Sales.SalesOrderHeader WHERE 1=1 ';

	IF @SalesOrderID IS NOT NULL
		SET @Cmd += ' AND SalesOrderID=@SalesOrderID';

	IF @OrderDate IS NOT NULL
		SET @Cmd += ' AND OrderDate=@OrderDate';
	
	EXEC sp_executesql @Cmd
		,N'@SalesOrderID INT,@OrderDate DATETIME',
		@SalesOrderID,@OrderDate;
GO

EXEC GetSalesOrderHeader 43671,NULL;
GO

EXEC GetSalesOrderHeader NULL,'2005-07-01 00:00:00.000';
GO

EXEC GetSalesOrderHeader 43672,'2005-07-02 00:00:00.000';
GO

EXEC GetSalesOrderHeader NULL,NULL;
GO