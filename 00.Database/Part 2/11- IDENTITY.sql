

USE master;
GO

DROP DATABASE IF EXISTS Identity_DB;
GO

CREATE DATABASE Identity_DB;
GO

USE Identity_DB;
GO

DROP TABLE IF EXISTS Identity_Tbl;
GO

CREATE TABLE Identity_Tbl
	(
		ID INT IDENTITY,
		Family NVARCHAR(100)
	);
GO

INSERT INTO Identity_Tbl
	VALUES	(N'سعادت'),(N'علوی'),(N'مقدم'),(N'پویا');
GO

/*
@@IDENTITY: جاری Session تولید شده در Identity آخرین مقدار
SCOPE_IDENTITY: جاری و مستقل از سایر حوزه‌ها Session تولید شده در Identity آخرین مقدار
IDENT_CURRENT: تولید شده در جدول جاری Identity آخرین مقدار
*/

-- دیگر و مشاهده نتایج Session اجرای کوئری زیر در
SELECT
	@@IDENTITY AS [@@IDENTITY],
	SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
	IDENT_CURRENT('Identity_Tbl') AS [IDENT_CURRENT];
GO

-- دیگر و اجرای کوئری زیر Session درج رکورد در
SELECT
	@@IDENTITY AS [@@IDENTITY],
	SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
	IDENT_CURRENT('Identity_Tbl') AS [IDENT_CURRENT];
GO

DROP TABLE IF EXISTS History_Identity_Tbl;
GO

CREATE TABLE History_Identity_Tbl
	(
		Serial INT IDENTITY,
		ID INT,
		Family NVARCHAR(100),
		Act_Type VARCHAR(20),
		Act_Date DATE
	);
GO

DROP TRIGGER IF EXISTS Trg_History_Identity_Tbl;
GO

CREATE TRIGGER Trg_History_Identity_Tbl ON Identity_Tbl
AFTER UPDATE
AS
	-- مقدار قبل از به‌روزرسانی
	INSERT INTO History_Identity_Tbl(ID,Family,Act_Type,Act_Date)
		SELECT
			ID, Family, 'Old_Value', GETDATE()
		FROM deleted
	-- مقدار پس از به‌روزرسانی
	INSERT INTO History_Identity_Tbl(ID,Family,Act_Type,Act_Date)
		SELECT
			ID, Family, 'New_Value', GETDATE()
		FROM inserted;
GO

SELECT
	@@IDENTITY AS [@@IDENTITY],
	SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
	IDENT_CURRENT('Identity_Tbl') AS [IDENT_CURRENT];
GO

UPDATE Identity_Tbl
	SET Family = N'سعادت نژاد'
	WHERE Family = N'سعادت';
GO

SELECT
	@@IDENTITY AS [@@IDENTITY],
	SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
	IDENT_CURRENT('Identity_Tbl') AS [IDENT_CURRENT];
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS Identity_Tbl;
GO

CREATE TABLE Identity_Tbl
	(
		ID INT IDENTITY,
		Family NVARCHAR(100),
		Score TINYINT
	);
GO

INSERT INTO Identity_Tbl
	VALUES	(N'سعادت', 100),(N'علوی', 200),(N'مقدم', 150),(N'پویا', 80);
GO

SELECT * FROM Identity_Tbl;
GO

INSERT INTO Identity_Tbl
	VALUES	(N'محمدی', 45),(N'عباسوند', 33),(N'کرامتی', 88),(N'محسنیان', 400);
GO

INSERT INTO Identity_Tbl
	VALUES	(N'محمدی', 45),(N'عباسوند', 33),(N'کرامتی', 88),(N'محسنیان', 40);
GO

SELECT * FROM Identity_Tbl;
GO

/*
DBCC CHECKIDENT
 (
    table_name  
        [, { NORESEED | { RESEED [, new_reseed_value ] } } ]  
)
*/

INSERT INTO Identity_Tbl
	VALUES	(N'نعمتی', 450);
GO

DBCC CHECKIDENT ('Identity_Tbl', NORESEED);
GO

DBCC CHECKIDENT ('Identity_Tbl', RESEED, 12);
GO

INSERT INTO Identity_Tbl
	VALUES	(N'نعمتی', 33);
GO

SELECT * FROM Identity_Tbl;
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS Identity_DB;
GO