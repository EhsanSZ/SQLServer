
/*
CREATE { PROC | PROCEDURE } 
    [schema_name.] procedure_name
    [ { @parameter data_type }  
        [ = default ] [ OUT | OUTPUT | [READONLY]  
    ] [ ,...n ]   
AS { [ BEGIN ] sql_statement [;] [ ...n ] [ END ] }  
[;]  
*/

USE Programmer;
GO

DROP PROCEDURE IF EXISTS GetAllCustomers;
GO

-- !شروع نشود SP_ با Procedure هیچگاه نام
CREATE PROCEDURE GetAllCustomers
AS
BEGIN	
	SELECT 
		CustomerID, City
	FROM Customers;
END
GO

-- SP روش‌های فراخوانی
EXEC GetAllCustomers;
GO

GetAllCustomers;
GO
--------------------------------------------------------------------

-- Procedure و اطلاعاتی درباره Source مشاهده
SP_HELPTEXT 'GetAllCustomers';
GO

SELECT * FROM INFORMATION_SCHEMA.ROUTINES
	WHERE SPECIFIC_NAME = 'GetAllCustomers';
GO

SELECT
	OBJECT_NAME(id) AS Proc_Name,*
FROM sys.syscomments
	WHERE OBJECT_NAME(id) = 'GetAllCustomers';
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('GetAllCustomers'));
GO
--------------------------------------------------------------------

-- Procedure ویرایش
ALTER PROCEDURE GetAllCustomers
AS
BEGIN	
	SELECT 
		CustomerID, State, City
	FROM Customers;
END
GO

EXEC GetAllCustomers;
GO
--------------------------------------------------------------------

/*
SP With Input Parameters
*/

DROP PROCEDURE IF EXISTS GetEmployeeByID;
GO

CREATE PROCEDURE GetEmployeeByID
(
	@ID INT
)
AS
BEGIN
	SELECT 
		EmployeeID, FirstName, LastName
	FROM Employees
	WHERE EmployeeID = @ID;
END
GO

EXEC GetEmployeeByID 1;
GO

EXEC GetEmployeeByID @ID = 1;
GO

GetEmployeeByID 1;
GO
--------------------------------------------------------------------

/*
SP With Output Parameters
*/

DROP PROCEDURE IF EXISTS ExistsCustomer;
GO

CREATE PROCEDURE ExistsCustomer
(
	@CustomerID INT,
	@Exists BIT OUTPUT
)
AS
BEGIN	
	IF EXISTS(SELECT CustomerID FROM Customers
				WHERE CustomerID = @CustomerID)
		SET @Exists ='TRUE';
	ELSE
		SET @Exists ='FALSE';
		/*
		.نوشتن هر یک از موارد زیر اختیاری است
		RETURN;
		یا
		RETURN @Exists;
		*/
END
GO

DECLARE @V_RecordExistance BIT;
EXEC ExistsCustomer @CustomerID = 100, @Exists = @V_RecordExistance OUTPUT -- OUTPUT توجه به کلمه
SELECT @V_RecordExistance;
GO

DROP PROCEDURE IF EXISTS ConcatInfo;
GO

CREATE PROCEDURE ConcatInfo
(
	@FirstName NVARCHAR(40),
	@LastName NVARCHAR(60),
	@FullName NVARCHAR(100) OUTPUT
)
AS
BEGIN
	SELECT @FullName = CONCAT(@FirstName, ' ', @LastName);
END
GO

DECLARE @V_FullName NVARCHAR(100);
EXEC ConcatInfo @FirstName = N'بهزاد', @LastName = N'منافی', @FullName = @V_FullName OUTPUT;

SELECT @V_Fullname;
GO

-- روش دیگر
DECLARE @V_FullName NVARCHAR(100);
EXEC ConcatInfo N'مجید', N'اسدی', @V_FullName OUTPUT;
SELECT @V_Fullname;
GO
--------------------------------------------------------------------

-- دیگر Procedure در Procedure نحوه فراخوانی
DROP PROCEDURE IF EXISTS Inner_SP, Outer_SP;
GO

CREATE PROC Inner_SP
(
	@Ret INT OUTPUT
)
AS
BEGIN
	SET @Ret = (SELECT COUNT(*) AS Num FROM Customers);
END
GO

CREATE PROC Outer_SP
AS
BEGIN
	DECLARE @Ret_Param INT;
	EXEC Inner_SP  @Ret_Param OUTPUT;
	SELECT @Ret_Param;
END
GO

EXEC Outer_SP;
GO

-- Procedure در VIEW فراخوانی
CREATE OR ALTER VIEW View_in_SP
AS
	SELECT
		CustomerID, CompanyName
	FROM Customers;
GO

CREATE OR ALTER PROC Company_Orders
AS
BEGIN
	SELECT
		V.CompanyName, O.OrderID
	FROM Orders AS O
	JOIN View_in_SP AS V
		ON O.CustomerID = V.CustomerID;
END
GO

EXECUTE Company_Orders;
GO
--------------------------------------------------------------------

/*
Procedure & DML Statements
*/

DROP TABLE IF EXISTS Customers_SP_Tbl;
GO

SELECT CustomerID, CompanyName, City INTO Customers_SP_Tbl FROM Customers;
GO

CREATE OR ALTER PROCEDURE Insert_Customer
(
	@CompanyName NVARCHAR(40),
	@City NVARCHAR(15)
)
AS
BEGIN
	INSERT INTO Customers_SP_Tbl(CompanyName,City)
		VALUES (@CompanyName,@City);
END
GO

EXEC Insert_Customer @CompanyName = N'شرکت جدید 1', @City = N'تهران';
GO

SELECT * FROM Customers_SP_Tbl
ORDER BY CustomerID DESC;
GO

CREATE OR ALTER PROCEDURE Update_Customer
(
	@CustomerID INT,
	@City NVARCHAR(40)
)
AS
BEGIN
	UPDATE Customers_SP_Tbl
		SET 
		City = @City
		WHERE CustomerID = @CustomerID
END
GO

EXEC Update_Customer @CustomerID = 1, @City = N'بندرعباس';
GO

SELECT * FROM Customers_SP_Tbl;
GO

CREATE OR ALTER PROCEDURE Delete_Customer
(
	@CustomerID INT
)
AS
BEGIN
	DELETE Customers_SP_Tbl
		WHERE CustomerID <= @CustomerID
END
GO

EXEC Delete_Customer @CustomerID = 10;
GO

SELECT * FROM Customers_SP_Tbl;
GO