

USE master;
GO

DROP TABLE IF EXISTS Test01;
GO

CREATE DATABASE Test01;
GO

USE Test01;
GO

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		StudentID INT,
		FirstName NVARCHAR(100),
		LastName NVARCHAR(150),
		FatherName NCHAR(100)
	);
GO


/*
SQL_VARIANT
Maximum Length	8000 bytes
*/
DECLARE @Var SQL_VARIANT = '2021-01-01';
SELECT @Var;
SELECT DATALENGTH(@Var)
GO

DECLARE @Var SQL_VARIANT = 'Test';
SELECT @Var;
SELECT DATALENGTH(@Var)
GO

DECLARE @Var SQL_VARIANT = N'تست';
SELECT @Var;
SELECT DATALENGTH(@Var)
GO
--------------------------------------------------------------------

/*
UNIQUEIDENTIFIER
.است GUID همان
.مقدار همواره تصادفی است
*/

DECLARE @var UNIQUEIDENTIFIER = NEWID();
SELECT @var;
-- !به میزان فضای اشغال شده توجه شود 
SELECT DATALENGTH(@var);
GO
--------------------------------------------------------------------

/*
TIMESTAMP  
*/

USE tempdb;
GO

CREATE TABLE #TimeStampTable
	(
		ID INT IDENTITY,
		Col1 VARCHAR(50),
		TimeStampField TIMESTAMP
	);
GO

-- توسط کاربر TIMESTAMP عدم تخصیص مقدار به فیلد
INSERT INTO #TimeStampTable(Col1,TimeStampField)
	VALUES	('Val1','TimeValue1'),
			('Val2','TimeValue2'),
			('Val3','TimeValue3');
GO

INSERT INTO #TimeStampTable(Col1)
	VALUES ('Val1'),('Val2'),('Val3');
GO

SELECT * FROM #TimeStampTable;
GO

-- با ساخت یک جدول SSMS بررسی در

UPDATE #TimeStampTable
	SET Col1 = 'NewValue'
		WHERE ID = 2;
GO

SELECT * FROM #TimeStampTable;
GO

-- .و چالش‌های مرتبط با آن مورد بررسی قرار گیرد Concurrency مربوط به Application در ادامه
DROP TABLE IF EXISTS MySchema.Students, dbo.Students;
GO

CREATE TABLE MySchema.Students
	(
		StudentID INT IDENTITY,
		FirstName NVARCHAR(100),
		LastName NVARCHAR(150),
		FatherName NCHAR(100)
	);
GO

-- دسترسی به اسکیمای یک جدول
SELECT * FROM INFORMATION_SCHEMA.TABLES   /* تمامی اسکیماهای مرتبط با جداول یک دیتابیس */
	WHERE TABLE_NAME = 'Students';
GO

-- عدم نوشتن نام اسکیما و خطا
SELECT * FROM Students; -- MySchema.Tbl1
GO

INSERT INTO MySchema.Students
	VALUES	(N'علی', N'رضایی', N'محمد'),
			(N'سعید', N'کریمی', N'رضا'),
			(N'سروش', N'احمدی', N'علی');
GO

SELECT * FROM MySchema.Students;
GO

CREATE TABLE Students
	(
		StudentID INT IDENTITY,
		FirstName NVARCHAR(100),
		LastName NVARCHAR(150),
		FatherName NCHAR(100)
	);
GO

INSERT INTO Students
	VALUES	(N'سحر', N'رحمانی', N'مهدی'),
			(N'زهرا', N'محمودیان', N'علی'),
			(N'پروانه', N'نصیری', N'سروش');
GO

-- Students مشاهده رکوردهای جدول
SELECT * FROM Students;
SELECT * FROM dbo.Students;
GO

SELECT * FROM MySchema.Students;
GO
--------------------------------------------------------------------

USE master;
GO

DROP TABLE IF EXISTS Test01;
GO