

USE master;
GO

DROP DATABASE IF EXISTS Computed_DB;
GO

CREATE DATABASE Computed_DB;
GO

USE Computed_DB;
GO

SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS Computed_Tbl;
GO

CREATE TABLE Computed_Tbl
	(
		ID INT IDENTITY,
		FirstName NVARCHAR(50),
		LastName NVARCHAR(50),
		FullName AS (FirstName + ' - ' + LastName), -- Computed Column
		FatherName NVARCHAR(50)
	);
GO

INSERT INTO Computed_Tbl
	VALUES	(N'حمید', N'سجادی', N'علی'),
			(N'ترانه', N'رضایی', N'رضا'),
			(N'پوریا', N'سرمدی', N'محمد'),	
			(N'رضا', N'محمدی', N'بهزاد'),
			(N'پروانه', N'صداقت', N'سعید');
GO 1000

SELECT * FROM Computed_Tbl;
GO

DROP TABLE IF EXISTS Computed_Persisted_Tbl;
GO

CREATE TABLE Computed_Persisted_Tbl
	(
		ID INT IDENTITY,
		FirstName NVARCHAR(50),
		LastName NVARCHAR(50),
		FullName AS (FirstName + ' - ' + LastName) PERSISTED, -- PERSISTED Computed Column
		FatherName NVARCHAR(50)
	);
GO

INSERT INTO Computed_Persisted_Tbl
	VALUES	(N'حمید', N'سجادی', N'علی'),
			(N'ترانه', N'رضایی', N'رضا'),
			(N'پوریا', N'سرمدی', N'محمد'),	
			(N'رضا', N'محمدی', N'بهزاد'),
			(N'پروانه', N'صداقت', N'سعید');
GO 1000

SELECT * FROM Computed_Persisted_Tbl;
GO

-- بررسی فضای تخصیص یافته به جداول
SP_SPACEUSED Computed_Tbl;
GO
SP_SPACEUSED Computed_Persisted_Tbl;
GO
--------------------------------------------------------------------

/*
Computed Column بر روی UPDATE و INSERT عدم انجام عملیات‌های
*/
INSERT INTO Computed_Persisted_Tbl(FirstName,LastName,FullName,FatherName)
	VALUES	(N'مهدی', N'کبیری', N'مهدی - کبیری', N'علی');
GO

INSERT INTO Computed_Tbl(FirstName,LastName,FullName,FatherName)
	VALUES	(N'مهدی', N'کبیری', N'مهدی - کبیری', N'علی');
GO

UPDATE Computed_Tbl
	SET FullName = 'My Value';
GO

UPDATE Computed_Persisted_Tbl
	SET FullName = 'My Value';
GO
--------------------------------------------------------------------

-- .ایرادی ندارد
DELETE Computed_Tbl
	WHERE FullName = N'حمید - سجادی';
GO

-- .ایرادی ندارد
DELETE Computed_Persisted_Tbl
	WHERE FullName = N'حمید - سجادی';
GO

-- .ایرادی ندارد
UPDATE Computed_Tbl
	SET FirstName = N'پیمان'
	WHERE FirstName = N'پوریا';
GO

-- .ایرادی ندارد
UPDATE Computed_Persisted_Tbl
	SET FirstName = N'پیمان'
	WHERE FirstName = N'پوریا';
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS Computed_DB;
GO