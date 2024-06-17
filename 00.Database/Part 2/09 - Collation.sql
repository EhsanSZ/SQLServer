

USE master;
GO

DROP DATABASE IF EXISTS Collate_DB;
GO

CREATE DATABASE Collate_DB;
GO

USE Collate_DB;
GO

ALTER DATABASE Collate_DB
COLLATE Persian_100_CI_AI;
GO

-- جاری Instance های موجود در Collation لیست
SELECT * FROM SYS.fn_helpcollations()
	WHERE name LIKE '%Persian%';
GO

DROP TABLE IF EXISTS Collate_Tbl;
GO

CREATE TABLE Collate_Tbl
	(
		ID INT,
		Col1 NVARCHAR(10) COLLATE SQL_Latin1_General_CP1256_CI_AS,
		Col2 NVARCHAR(10) COLLATE Persian_100_CI_AI
	);
GO

INSERT INTO Collate_Tbl
	VALUES	(1, N'ج', N'ج'),
			(2, N'پ', N'پ'),
			(3, N'ژ', N'ژ'),
			(4, N'ح', N'ح'),
			(5, N'ي', N'ي'), -- عربی
			(6, N'ی', N'ی'), -- فارسی
			(7, N'ك', N'ك'), -- عربی
			(8, N'ک', N'ک'), -- فارسی
			(9, N'گ', N'گ'),
			(10, N'ب', N'ب'),			
			(11, N'چ', N'چ'),
			(12, N'ف', N'ف');
GO

SELECT * FROM Collate_Tbl;
GO

-- در مرتب‌سازی Collation تاثیر
SELECT * FROM Collate_Tbl
ORDER BY Col1; -- Collation: SQL_Latin1_General_CP1256_CI_AS
GO

-- در مرتب‌سازی Collation تاثیر
SELECT * FROM Collate_Tbl
ORDER BY Col2; -- Collation: Persian_100_CI_AI
GO

-- در جستجو‌ Collation عدم تاثیر
SELECT * FROM Collate_Tbl
	WHERE Col1 = N'ی';
GO

SELECT * FROM Collate_Tbl
	WHERE Col1 = N'ي';
GO

SELECT * FROM Collate_Tbl
	WHERE Col2 = N'ی';
GO

SELECT * FROM Collate_Tbl
	WHERE Col2 = N'ي';
GO
--------------------------------------------------------------------

/*
مراحل تبدیل ي و ك عربی به فارسی

1) Persian فیلدها و تبدیل آن به Collation تغییر
2) جایگزینی ي و ك عربی با فارسی در جداول مختلف

NCHAR(1610)	ي عربی
NCHAR(1740)	ی فارسی
NCHAR(1603) ك عربی
NCHAR(1705) ک فارسی
*/

-- 1) Persian فیلدها و تبدیل آن به Collation تغییر
-- هاي دیتابیس و جداول‌ Collation يافتن تداخل میان 
DECLARE @DefaultDBCollation NVARCHAR(1000);  
SET @DefaultDBCollation = CAST(DATABASEPROPERTYEX(DB_NAME(), 'Collation') AS NVARCHAR(1000));
SELECT 
	sys.tables.name AS TableName,
	sys.columns.name AS ColumnName,
	sys.columns.is_nullable, sys.columns.collation_name,
	@DefaultDBCollation AS DefaultDBCollation
FROM sys.columns
INNER JOIN sys.tables
	ON sys.columns.object_id = sys.tables.object_id
	WHERE sys.columns.collation_name <> @DefaultDBCollation
	AND COLUMNPROPERTY(OBJECT_ID(sys.tables.name), sys.columns.name, 'IsComputed') = 0;
GO

-- 2) جایگزینی ي و ك عربی با فارسی در جداول مختلف
DECLARE @Table NVARCHAR(MAX), @Col NVARCHAR(MAX);
DECLARE Table_Cursor CURSOR   
FOR  
    --پيدا كردن تمام فيلدهاي متني تمام جداول ديتابيس جاري  
    SELECT
		a.name, -- table  
        b.name -- col  
    FROM   sysobjects a, syscolumns b 
    WHERE  a.id = b.id
           AND a.xtype = 'u' -- User table
           AND (  
                   b.xtype = 99 -- ntext
                   OR b.xtype = 35 -- text
                   OR b.xtype = 231 -- nvarchar
                   OR b.xtype = 167 -- varchar
                   OR b.xtype = 175 -- char
                   OR b.xtype = 239 -- nchar
               ) 
OPEN Table_Cursor FETCH NEXT FROM Table_Cursor INTO @Table,@Col  
WHILE (@@FETCH_STATUS = 0)  
	BEGIN  
		EXEC (  
				'UPDATE [' + @Table + '] SET [' + @Col +  
				']= REPLACE(REPLACE(CAST([' + @Col +  
				'] AS NVARCHAR(MAX)) , NCHAR(1610), NCHAR(1740)),NCHAR(1603),NCHAR(1705))' 
				/*
				 !جایگذاری در خط بالا برای تبدیل ی و ک عربی به فارسی
				'] AS NVARCHAR(MAX)) , NCHAR(1610), NCHAR(1740)),NCHAR(1603),NCHAR(1705))'

				 !جایگذاری در خط بالا برای تبدیل ی و ک فارسی به عربی
				'] AS NVARCHAR(MAX)) , NCHAR(1740), NCHAR(1610)),NCHAR(1705),NCHAR(1603)) ' 
				*/
			)  
     
		FETCH NEXT FROM Table_Cursor INTO @Table,@Col  
	END CLOSE Table_Cursor DEALLOCATE Table_Cursor;
GO

SELECT * FROM dbo.Collate_Tbl;
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS Collate_DB;
GO