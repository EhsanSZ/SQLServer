

/*
CHAR(n)
1<= n <=8000
*/
DECLARE @Var CHAR(10) = 'Test';
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

/*
VARCHAR(n)
1<= n <=8000
*/
DECLARE @Var VARCHAR(10) = 'Test';
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

/*
VARCHAR(MAX)
*/
DECLARE @Var VARCHAR(MAX) = 'Test1*Test2*Test3';
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

/*
TEXT
*/
DECLARE @Var Text = 'Test1*Test2*Test3';
SELECT @Var
SELECT DATALENGTH(@Var);
GO

/*
NCHAR(n)
1<= n <=4000
*/
DECLARE @Var NCHAR(10) = 'Test';
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

/*
NVARCHAR(n)
1<= n <=4000
*/
DECLARE @Var NVARCHAR(10) = 'Test';
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

/*
NVARCHAR(MAX)
*/
DECLARE @Var NVARCHAR(MAX) = 'Test1*Test2*Test3';
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

/*
NTEXT
*/
DECLARE @Var NText = 'Test1*Test2*Te3st';
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

-- ذخیره یک مقدار یونیکدی در یک دیتا تایپ غیر یونیکدی
DECLARE @Var VARCHAR(100) = 'تست';
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

-- ذخیره یک مقدار یونیکدی در یک دیتا تایپ غیر یونیکدی
DECLARE @Var VARCHAR(100) = N'تست';
SELECT @Var
SELECT DATALENGTH(@Var);
GO

-- .استفاده شود N همواره در هنگام کار با مقادیر یونیکدی از تگ
DECLARE @Var NVARCHAR(100) = N'تست';
SELECT @Var
SELECT DATALENGTH(@Var);
GO
--------------------------------------------------------------------

USE tempdb;
GO

-- .باز هم به آن‌ها فضا تخصیص داده می‌شود NULL در صورت پذیرش مقدار Fixed Length های Data Type
CREATE TABLE #Tbl
	(
		Col1 CHAR(3000),
		Col2 CHAR(3000)
	);
GO

INSERT INTO #Tbl
	VALUES (NULL,NULL);
GO 1000

SP_SPACEUSED #Tbl;
GO
--------------------------------------------------------------------

/*
Unicode بررسی تغییرات جدید مرتبط با
.اجرا شود SQL Server 2019 اسکریپت‌های زیر حتما در
*/  

SELECT
	Name, Description FROM
fn_helpcollations() 
	WHERE Name like '%UTF8%';
GO

DROP DATABASE IF EXISTS UTF_DB;
GO

CREATE DATABASE UTF_DB COLLATE Persian_100_CI_AI_SC_UTF8;
GO

USE UTF_DB;
GO

DROP TABLE IF EXISTS UTF_Tbl;
GO

CREATE TABLE UTF_Tbl
	(
		Col1 VARCHAR(50),
		Col2 NVARCHAR(20)
	);
GO

INSERT INTO UTF_Tbl
	VALUES	('Test: تست', N'Test: تست'),
			('Test', N'Test');
GO

SELECT
	*, DATALENGTH(Col1) AS S_Col1, DATALENGTH(Col2) AS S_Col2 
FROM UTF_Tbl;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS FixedLengthTbl, VariableLengthTbl;
GO

CREATE TABLE FixedLengthTbl
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		FirstName CHAR(12),
	);
GO

CREATE TABLE VariableLengthTbl
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		FirstName VARCHAR(12) ,
	);
GO

SET NOCOUNT ON;
GO

DECLARE @Cnt INT = 1;
WHILE @Cnt <= 1000
BEGIN 
	INSERT INTO FixedLengthTbl (FirstName) VALUES(NULL) 
	INSERT INTO VariableLengthTbl (FirstName) VALUES(NULL) 
	SET @Cnt += 1
END
GO

SELECT
	*, DATALENGTH(ID) AS S_ID, DATALENGTH(FirstName) AS S_FirstName
FROM FixedLengthTbl;

SELECT
	*, DATALENGTH(ID) AS S_ID, DATALENGTH(FirstName) AS S_FirstName
FROM VariableLengthTbl;
GO

-- های تخصیص داده شده به هر دو جدولPage مشاهده 
SELECT 
	COUNT(database_id) AS PageCount_TB_FixedLength
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('UTF_DB'),OBJECT_ID('FixedLengthTbl'),
		NULL,NULL,'DETAILED'
	)
	WHERE page_type_desc = 'DATA_PAGE';
GO

SELECT 
	COUNT(database_id) AS PageCount_TB_VariableLength
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('UTF_DB'),OBJECT_ID('VariableLengthTbl'),
		NULL,NULL,'DETAILED'
	)
	WHERE page_type_desc = 'DATA_PAGE';
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS UTF_DB;
GO