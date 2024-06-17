

USE master;
GO

DROP DATABASE IF EXISTS IdentityCache_DB;;
GO

CREATE DATABASE IdentityCache_DB;
GO

USE IdentityCache_DB;
GO

/*
Identity برای تولید SQL Server رفتار:
کردن آن‌ها جهت استفاده Cache و Identity تولید 1000 تا
*/

SELECT * FROM sys.database_scoped_configurations;
GO

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		TeacherID INT IDENTITY(1,1),
		FirstName NVARCHAR(100),
		LastName NVARCHAR(100)
	);
GO

INSERT INTO Students (FirstName,LastName)
	VALUES	(N'پریسا', N'محمدی'),
			(N'حمید', N'صفائیان'),
			(N'علی', N'توانایی'),
			(N'زهره', N'سعادتی'),
			(N'کاوه', N'مشیری');
GO

SELECT * FROM Students;
GO

-- Instance کردن Shutdown
SHUTDOWN WITH NOWAIT;
GO

-- SQL Server راه‌اندازی مجدد سرویس 

USE IdentityCache_DB;
GO

-- Identity شده از Cache از دست رفتن مقادیر
INSERT INTO Students (FirstName,LastName)
	VALUES	(N'رضا', N'علوی'),
			(N'شیرین', N'کریمی');
GO

SELECT * FROM Students;
GO
--------------------------------------------------------------------

-- به بعد SQL Server 2017 رفع مشکل برای ورژن‌های
USE IdentityCache_DB;
GO

ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = OFF; 
GO

SELECT * FROM SYS.database_scoped_configurations;
GO

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		TeacherID INT IDENTITY(1,1),
		FirstName NVARCHAR(100),
		LastName NVARCHAR(100)
	);
GO

INSERT INTO Students (FirstName,LastName)
	VALUES	(N'پریسا', N'محمدی'),
			(N'حمید', N'صفائیان'),
			(N'علی', N'توانایی'),
			(N'زهره', N'سعادتی'),
			(N'کاوه', N'مشیری');
GO

SELECT * FROM Students;
GO

-- Instance کردن Shutdown
SHUTDOWN WITH NOWAIT;
GO

-- SQL Server راه‌اندازی مجدد سرویس 

USE IdentityCache_DB;
GO

INSERT INTO Students (FirstName,LastName)
	VALUES	(N'رضا', N'علوی'),
			(N'شیرین', N'کریمی');
GO

SELECT * FROM Students;
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS IdentityCache_DB;;
GO