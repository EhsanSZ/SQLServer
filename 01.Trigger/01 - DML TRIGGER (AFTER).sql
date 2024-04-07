
/*
CREATE [ OR ALTER ] TRIGGER [ schema_name . ]trigger_name   
ON { table | view }   
{ AFTER | INSTEAD OF }   
{ [ INSERT ] [ , ] [ UPDATE ] [ , ] [ DELETE ] }   
AS { sql_statement  [ ; ] [ ,...n ] }  
*/

/*
DML TRIGGER (AFTER)
*/
USE master;
GO

DROP DATABASE IF EXISTS DML_Trigger_DB;
GO

CREATE DATABASE DML_Trigger_DB;
GO

USE DML_Trigger_DB;
GO

DROP TABLE IF EXISTS Persons;
GO

CREATE TABLE Persons
	(
		Code INT,
		FirstName NVARCHAR(50),
		LastName NVARCHAR(50)
	);
GO

DROP TRIGGER IF EXISTS InsertTrg_Persons;
GO

CREATE TRIGGER InsertTrg_Persons ON Persons
AFTER INSERT
AS
	SELECT * FROM inserted;
GO

-- مشاهده اطلاعاتی درباره تریگرها
SP_HELPTRIGGER 'Persons';
SELECT * FROM sys.triggers;
SELECT * FROM sys.trigger_events;
GO

-- تریگر Source مشاهده
SP_HELPTEXT 'InsertTrg_Persons';
GO

SP_DEPENDS 'InsertTrg_Persons';
GO

INSERT INTO Persons
	VALUES	(1, N'امید', N'حسین‌نژاد‌'),
			(2, N'رضا', N'تقوایی');
GO

SELECT * FROM Persons;
GO

-- تغییر تریگر
ALTER TRIGGER InsertTrg_Persons ON Persons
AFTER INSERT,UPDATE,DELETE
AS
	ROLLBACK TRANSACTION
GO

INSERT INTO Persons
	VALUES (1, N'سامان', N'طلوعی');
GO

DELETE FROM Persons;
GO

UPDATE Persons
	SET Code = 100
		WHERE Code = 1;
GO

SELECT * FROM Persons;
GO
--------------------------------------------------------------------

/*
ها TRIGGER مدیریت رکوردهای تاثیر‌پذیر در هنگام کار با
*/

USE AdventureWorks2019;
GO

DROP TABLE IF EXISTS POD,POH;
GO

SELECT * INTO POD FROM Purchasing.PurchaseOrderDetail;
GO
SELECT * INTO POH FROM Purchasing.PurchaseOrderHeader;
GO

SELECT * FROM POH;
SELECT * FROM POD;

DROP TRIGGER IF EXISTS Single_Row_SubTotal;
GO

CREATE TRIGGER Single_Row_SubTotal ON POD 
AFTER INSERT
AS  
	UPDATE POH  
	SET SubTotal = SubTotal + LineTotal FROM inserted  
		WHERE POH.PurchaseOrderID = inserted.PurchaseOrderID; 
GO

INSERT INTO POH
	VALUES	(1,1,260,1520,3,'2021-06-24 00:00:00.000','2021-07-12 00:00:00.000',
			 0,-- SubTotal
			 19953.60,1097448.00,50.00,'2021-08-13 00:00:00.000');
GO

SELECT * FROM POH
ORDER BY PurchaseOrderID DESC;
GO

INSERT INTO POD
	VALUES	(4013,'2021-07-17 00:00:00.000',10,873,1.07,10.70,
			 30.00,0.00,50.00,'2021-08-13 00:00:00.000');
GO

SELECT * FROM POD
ORDER BY PurchaseOrderID DESC;
GO

SELECT * FROM POH
ORDER BY PurchaseOrderID DESC;
GO

-- SubTotal درج 2 رکورد دیگر برای فاکتور شماره 4013 و صرفا تاثیر آخرین مقدار بر روی
INSERT INTO POD
	VALUES	(4013,'2021-07-17 00:00:00.000',20,874,5.00,100.00,
			 20.00,0.00,20.00,'2021-08-13 00:00:00.000'),
			(4013,'2021-07-17 00:00:00.000',30,873,10.00,300.00,
			 30.00,0.00,30.00,'2021-08-13 00:00:00.000');
GO

SELECT * FROM POD
ORDER BY PurchaseOrderID DESC;
GO

SELECT * FROM POH
ORDER BY PurchaseOrderID DESC;
GO

DROP TRIGGER IF EXISTS Single_Row_SubTotal,Multi_Rows_SubTotal;
GO

CREATE TRIGGER Multi_Rows_SubTotal ON POD 
AFTER INSERT
AS  
	UPDATE POH  
	SET SubTotal = SubTotal + (SELECT SUM(LineTotal) FROM inserted  
								WHERE POH.PurchaseOrderID = inserted.PurchaseOrderID)  
		WHERE POH.PurchaseOrderID IN (SELECT PurchaseOrderID FROM inserted);
GO

INSERT INTO POH
	VALUES	(9,2,230,1500,3,'2021-06-24 00:00:00.000','2021-07-12 00:00:00.000',
			 0,-- SubTotal
			 19953.60,1097448.00,50.00,'2021-08-13 00:00:00.000');
GO

SELECT * FROM POH
ORDER BY PurchaseOrderID DESC;
GO

INSERT INTO POD
	VALUES	(4014,'2021-07-17 00:00:00.000',20,873,1.07,21.4,
			 20.00,0.00,20.00,'2021-08-13 00:00:00.000');
GO

SELECT * FROM POD
ORDER BY PurchaseOrderID DESC;
GO

SELECT * FROM POH
ORDER BY PurchaseOrderID DESC;
GO

-- SubTotal درج 2 رکورد دیگر برای فاکتور شماره 4014 و انجام صحیح محاسبات 
INSERT INTO POD
	VALUES	(4014,'2021-07-17 00:00:00.000',30,874,20.00,600.00,
			 30.00,0.00,30.00,'2021-08-13 00:00:00.000'),
			(4014,'2021-07-17 00:00:00.000',40,873,20.00,800.00,
			 40.00,0.00,40.00,'2021-08-13 00:00:00.000');
GO

SELECT * FROM POD
ORDER BY PurchaseOrderID DESC;
GO

SELECT * FROM POH
ORDER BY PurchaseOrderID DESC;
GO

DROP TRIGGER IF EXISTS Single_Row_SubTotal,Multi_Rows_SubTotal,SR_MR_SubTotal;
GO

CREATE TRIGGER SR_MR_SubTotal ON POD 
AFTER INSERT
AS
	IF @@ROWCOUNT = 1
		BEGIN
			UPDATE POH  
			SET SubTotal = SubTotal + LineTotal FROM inserted  
				WHERE POH.PurchaseOrderID = inserted.PurchaseOrderID;
		END
	ELSE
		BEGIN
			UPDATE POH  
			SET SubTotal = SubTotal + (SELECT SUM(LineTotal) FROM inserted  
										WHERE POH.PurchaseOrderID = inserted.PurchaseOrderID)  
			WHERE POH.PurchaseOrderID IN (SELECT PurchaseOrderID FROM inserted);
		END

GO
--------------------------------------------------------------------

/*
AFTER TRIGGER & Fragmentation
*/

USE DML_Trigger_DB;
GO

DROP TABLE IF EXISTS F_Table;
GO

CREATE TABLE F_Table
	(
		ID INT NOT NULL IDENTITY(1,1) primary key,
		Value INT NOT NULL,
		LobColumn VARCHAR(MAX) NULL
	);
GO

-- F_TABLE درج تعداد زیادی رکورد در جدول
WITH CTE1 (Col)
AS (SELECT 0 UNION ALL SELECT 0),
CTE2 (Col)
AS (SELECT 0 FROM CTE1 AS C1 CROSS JOIN CTE1 AS C2),
CTE3 (Col)
AS (SELECT 0 FROM CTE2 AS C1 CROSS JOIN CTE2 AS C2),
CTE4 (Col)
AS (SELECT 0 FROM CTE3 AS C1 CROSS JOIN CTE3 AS C2),
CTE5 (Col)
AS (SELECT 0 FROM CTE4 AS C1 CROSS JOIN CTE4 AS C2),
Numbers(Num)
AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM CTE5)
INSERT INTO F_TABLE(Value)
	SELECT Num FROM Numbers;
GO

SP_SPACEUSED F_Table;
GO

-- قبل از اعمال تریگر F_Table بر روی جدول Fragmentation بررسی وضعیت
SELECT 
	index_id, index_type_desc, alloc_unit_type_desc,
	index_depth, index_level, page_count, record_count,
	avg_fragment_size_in_pages, avg_fragmentation_in_percent, fragment_count
	FROM 
		sys.dm_db_index_physical_stats
		(
			DB_ID('DML_Trigger_DB'),
			OBJECT_ID('F_Table'),
			NULL,
			NULL,
			'DETAILED'
			)
	WHERE  index_level = 0;
GO

CREATE OR ALTER TRIGGER DML_Fake_Trigger ON F_Table
AFTER DELETE
AS
	RETURN;
GO

DELETE FROM F_Table
	WHERE ID % 2 = 0;
GO

-- قبل از اعمال تریگر F_Table بر روی جدول Fragmentation بررسی وضعیت
SELECT 
	index_id, index_type_desc, alloc_unit_type_desc,
	index_depth, index_level, page_count, record_count,
	avg_fragment_size_in_pages, avg_fragmentation_in_percent, fragment_count
	FROM 
		sys.dm_db_index_physical_stats
		(
			DB_ID('DML_Trigger_DB'),
			OBJECT_ID('F_TABLE'),
			NULL,
			NULL,
			'DETAILED'
			)
	WHERE index_level = 0;
GO
--------------------------------------------------------------------

/*
ENCRYPTION
*/
-- .امکان‌پذیر است Natively Compiled Modules ها صرفا برای TRIGGER در سطح SCHEMABINDING استفاده از تنظیمات

USE DML_Trigger_DB;
GO

CREATE OR ALTER TRIGGER InsertTrg_Persons ON Persons
WITH ENCRYPTION
AFTER INSERT
AS
	SELECT * FROM inserted;
GO
--------------------------------------------------------------------

/*
ذخیره‌سازی سوابق تغییرات با استفاده از تریگر
*/
DROP TABLE IF EXISTS History_Persons;
GO

CREATE TABLE History_Persons
	(
		Code INT,
		FirstName NVARCHAR(50),
		LastName NVARCHAR(50),
		Action_Type VARCHAR(10),
		Action_Date DATE
	);
GO

-- INSERT ایجاد تریگر برای حالت
CREATE TRIGGER Trg_Persons_Insert ON Persons
AFTER INSERT
AS
INSERT INTO History_Persons(Code,FirstName,LastName,Action_Type,Action_Date)
	SELECT
		Code, FirstName, LastName, 'INSERT', GETDATE()
	FROM inserted;
GO

-- UPDATE ایجاد تریگر برای حالت
CREATE TRIGGER Trg_Persons_Update ON Persons
AFTER UPDATE
AS
	--مقدار قبل از به‌روزرسانی
	INSERT INTO dbo.History_Persons(Code,FirstName,LastName,Action_Type,Action_Date)
		SELECT
			Code, FirstName, LastName, 'Old_Value', GETDATE()
		FROM deleted;
	--مقدار پس از به‌روزرسانی
	INSERT INTO dbo.History_Persons(Code,FirstName,LastName,Action_Type,Action_Date)
		SELECT
			Code, FirstName, LastName, 'New_Value', GETDATE()
		FROM inserted;
GO

-- DELETE ایجاد تریگر برای حالت
CREATE TRIGGER Trg_Persons_Delete ON Persons
AFTER DELETE
AS
	INSERT INTO History_Persons(Code,FirstName,LastName,Action_Type,Action_Date)
		SELECT
			Code, FirstName, LastName, 'DELETE', GETDATE()
		FROM deleted;
GO

INSERT INTO Persons
	VALUES	(1, N'فاطمه', N'طاعتی'),
			(2, N'بهروز', N'سعدنژاد'),
			(3, N'کامران', N'جاوید');
GO

SELECT * FROM Persons;
SELECT * FROM History_Persons;
GO

UPDATE Persons
	SET Code = 100
		WHERE Code = 2;
GO

SELECT * FROM Persons;
SELECT * FROM History_Persons;
GO

DELETE FROM Persons
	WHERE Code = 100;
GO

SELECT * FROM Persons;
SELECT * FROM History_Persons;
GO