

USE NikamoozDB_Programmer;
GO

/*
درون دیتابیس Large Object ذخیره
*/

DROP TABLE IF EXISTS Employee_In_DB;
GO

CREATE TABLE Employee_In_DB
	(
		EmployeeID INT PRIMARY KEY,
		FirstName NVARCHAR(100),
		LastName NVARCHAR(100),
		Pic VARBINARY(MAX)
	);
GO

INSERT INTO Employee_In_DB
	VALUES	(1,N'زهره',N'کرامتی',0x),
			(2,N'سعید',N'محمدیان',NULL);
GO

SELECT * FROM Employee_In_DB
GO

-- OpenRowSet ذخیره یک تصویر در دیتابیس با استفاده از تابع
INSERT INTO Employee_In_DB
	SELECT 
		3,N'کامران',N'یزدانی',* 
	FROM OPENROWSET
	(
		BULK N'C:\Dump\Person01.jpg', SINGLE_BLOB
	) Tbl;
GO 

SELECT * FROM Employee_In_DB;
GO
--------------------------------------------------------------------

/*
خارج از دیتابیس Large Object ذخیره
*/

DROP TABLE IF EXISTS Employee_Out_DB
GO

CREATE TABLE Employee_Out_DB
	(
		EmployeeID INT PRIMARY KEY,
		FirstName NVARCHAR(100),
		LastName NVARCHAR(100),
		Pic NVARCHAR(200)
	);
GO

INSERT INTO Employee_Out_DB
	VALUES	(1,N'زهره',N'کرامتی',0x),
			(2,N'سعید',N'محمدیان',NULL),
			(3,N'کامران',N'یزدانی','C:\Dump\Person01.jpg');
GO

SELECT * FROM Employee_Out_DB;
GO
--------------------------------------------------------------------

-- مقایسه حجم هر دو جدول
EXEC SP_SPACEUSED Employee_In_DB;
EXEC SP_SPACEUSED Employee_Out_DB;
GO

-- IO تعداد عملیات 
SET STATISTICS IO ON;
GO

SELECT * FROM Employee_In_DB;
SELECT * FROM Employee_Out_DB;
GO

SET STATISTICS IO OFF
GO
--------------------------------------------------------------------

-- های تخصیص داده شده به هر دو جدولPage مقایسه 
SELECT 
	allocated_page_file_id,
	page_type_desc,
	allocated_page_iam_page_id,
	extent_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('NikamoozDB_Programmer'),
		OBJECT_ID('Employee_In_DB'),
		NULL,NULL,'DETAILED'
	);
GO

SELECT
	allocated_page_page_id,
	page_type_desc,
	allocated_page_iam_page_id,
	extent_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('NikamoozDB_Programmer'),
		OBJECT_ID('Employee_Out_DB'),
		NULL,NULL,'DETAILED'
	);
GO