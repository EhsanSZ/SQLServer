
/*
BEGIN TRY  
     { sql_statement | statement_block }  
END TRY  
BEGIN CATCH  
     [ { sql_statement | statement_block } ]  
END CATCH  
[ ; ]
*/

USE AdventureWorks2019;
GO

BEGIN TRY
    SELECT 1/0;
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

CREATE OR ALTER PROCEDURE Get_Error_Info  
AS  
SELECT  
    ERROR_NUMBER() AS ErrorNumber, 
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_STATE() AS ErrorState,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;  
GO  

BEGIN TRY  
    SELECT 1/0;  
END TRY  
BEGIN CATCH  
    EXECUTE Get_Error_Info;  
END CATCH;
GO
--------------------------------------------------------------------

BEGIN TRY
   DECLARE @x INT;
   SELECT @x = 1/0;
   PRINT 'This statement will not be executed';
END TRY
BEGIN CATCH 
   PRINT 'The error message is: ' + ERROR_MESSAGE();
END CATCH;
GO
--------------------------------------------------------------------

BEGIN TRY
    SELECT * FROM Production.Produc;
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
		ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

CREATE OR ALTER PROCEDURE Name_Resolution_Error
AS
    SELECT * FROM Production.Produc;
GO
  
BEGIN TRY
    EXECUTE Name_Resolution_Error;
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO
--------------------------------------------------------------------

BEGIN TRY
    SELECT 1/0;
END TRY
BEGIN CATCH
END CATCH;
GO

BEGIN TRY
    SELECT 1/0;
END TRY
BEGIN CATCH
	PRINT 'Error Message ...';
END CATCH;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS Error_Handling_Tbl;
GO

CREATE TABLE Error_Handling_Tbl
	(
		Col1 INT PRIMARY KEY,
		Col2 NVARCHAR(1)
	);
GO

INSERT INTO Error_Handling_Tbl
	VALUES (1,'A'),(2,'B'),(3,'C');
GO

DECLARE @Error_Var INT;
INSERT INTO Error_Handling_Tbl
	VALUES (2,'B');
SET @Error_Var = @@ERROR;
IF @Error_Var > 0 
BEGIN
	PRINT 'ERROR NO:' + CAST(@@ERROR AS NVARCHAR(100));
	PRINT 'ERROR NO:' + CAST(@Error_Var AS NVARCHAR(100));
	PRINT N'!درج رکورد به دلیل مقدار تکراری فیلد کلید غیر مجاز است';
END 
GO
--------------------------------------------------------------------

/*
ذخیره لاگ خطا در جدول
*/

DROP TABLE IF EXISTS Error_Handling_Log;
GO

CREATE TABLE Error_Handling_Log
	(
		Err_ID INT IDENTITY NOT NULL PRIMARY KEY,
		Err_Number INT NOT NULL,
		Err_Message NVARCHAR(4000) NULL,
		Err_Severity SMALLINT NOT NULL,
		Err_State SMALLINT NOT NULL DEFAULT ((1)),
		Err_Procedure NVARCHAR(200) COLLATE Latin1_General_BIN NOT NULL,
		Err_Line INT NOT NULL DEFAULT ((0)),
		UserName NVARCHAR(128) NOT NULL DEFAULT (''),
		HostName VARCHAR (128) NOT NULL DEFAULT (''),
		Time_Stamp DATETIME NOT NULL,
	);
GO

CREATE OR ALTER PROCEDURE Error_Handling_Proc
AS
DECLARE @Err_Number INT;
DECLARE @Err_Message VARCHAR(4000);
DECLARE @Err_Severity INT;
DECLARE @Err_State INT;
DECLARE @Err_Procedure VARCHAR(200);
DECLARE @Err_Line INT;
DECLARE @UserName VARCHAR(200);
DECLARE @HostName VARCHAR(200);
DECLARE @Time_Stamp DATETIME;

SELECT
	@Err_Number = ISNULL(ERROR_NUMBER(),0),
	@Err_Message = ISNULL(ERROR_MESSAGE(),'NULL Message'),
	@Err_Severity = ISNULL(ERROR_SEVERITY(),0),
	@Err_State = ISNULL(ERROR_STATE(),1),
	@Err_Procedure = ISNULL(ERROR_PROCEDURE(),''),
	@Err_Line = ISNULL(ERROR_LINE(), 0),
	@UserName = SUSER_SNAME(),
	@HostName = HOST_NAME(),
	@Time_Stamp = GETDATE();

INSERT INTO Error_Handling_Log(Err_Number,Err_Message,Err_Severity,Err_State,Err_Procedure,Err_Line,UserName,HostName,Time_Stamp)
	SELECT	@Err_Number,@Err_Message, @Err_Severity, @Err_State , @Err_Procedure, @Err_Line, @UserName, @HostName, @Time_Stamp;
GO

BEGIN TRY
    SELECT 1/0;
END TRY
BEGIN CATCH
    EXEC Error_Handling_Proc 
END CATCH
GO

SELECT * FROM Error_Handling_Log;
GO
--------------------------------------------------------------------

/*
THROW [ { error_number | @local_variable },  
        { message | @local_variable },  
        { state | @local_variable } ]   
[ ; ]
*/

BEGIN TRY
   DELETE FROM Production.Product  
		WHERE ProductID = 980;
END TRY
BEGIN CATCH
   THROW 50000, N'Unable to delete record...', 1;
END CATCH;
GO
--------------------------------------------------------------------

BEGIN TRANSACTION
	BEGIN TRY  
	    DELETE FROM Production.Product  
			WHERE ProductID = 980;  
	END TRY  
	BEGIN CATCH  
		SELECT   
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;
  
    IF @@TRANCOUNT > 0 -- Returns the number of BEGIN TRANSACTION statements that have occurred on the current connection.
        ROLLBACK TRANSACTION;     
	END CATCH;
GO

/*
https://docs.microsoft.com/en-us/sql/t-sql/language-elements/try-catch-transact-sql?view=sql-server-ver15
*/
