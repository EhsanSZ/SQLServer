

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