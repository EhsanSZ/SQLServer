

-- master بررسی دیتابیس
USE master;
GO

SP_HELPFILE;
GO

-- master نمونه ای از جداول ذخیره شده در بانک اطلاعاتی 
SELECT * FROM sysdatabases;
SELECT * FROM syscacheobjects;
SELECT * FROM sysconfigures;
SELECT * FROM syslanguages;
SELECT * FROM syslogins;
SELECT * FROM sysmessages;
GO
--------------------------------------------------------------------

-- msdb بررسی دیتابیس
USE msdb;
GO

SP_HELPFILE;
GO

-- msdb نمونه ای از جداول ذخیره شده در بانک اطلاعاتی 
SELECT * FROM sysjobs;
SELECT * FROM sysjobhistory;
GO

SELECT * FROM backupset;
SELECT * FROM backupfile;
SELECT * FROM restorehistory;
GO
--------------------------------------------------------------------

-- tempdb بررسی بانک اطلاعاتی
USE tempdb;
GO

SP_HELPFILE;
GO

DROP TABLE IF EXISTS Test;
GO

CREATE TABLE Test
	(
		Col1 INT PRIMARY KEY,
		Col2 NVARCHAR(10)
	);
GO

INSERT INTO Test
	VALUES	(1,'A'), (2,'B'), (3,'C'),
			(4,'D'), (5,'E'), (6,'F');
GO

SELECT * FROM Test;
GO

/*
.پاک می‌شود Tempdb اطلاعات موجود در دیتابیس SQL SERVER سرویس Rrstart با
*/
--------------------------------------------------------------------

USE Northwind;
GO

CREATE TABLE #T1
	(
		Col1 INT PRIMARY KEY,
		Col2 NVARCHAR(10)
	);
GO

INSERT INTO #T1
	VALUES	(1,'A'), (2,'B'), (3,'C'),
			(4,'D'), (5,'E'), (6,'F');
GO

SELECT * FROM #T1;
GO

/*
.پاک می‌شود Tempdb اطلاعات موجود در دیتابیس SQL SERVER سرویس Rrstart با
*/
--------------------------------------------------------------------

-- model بررسی بانک اطلاعاتی
USE model;
GO

SP_HELPFILE;
GO

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		Code INT PRIMARY KEY,
		FirstName NVARCHAR(50),
		LastName NVARCHAR(50)
	);
GO

INSERT INTO Students
	VALUES	(1, N'امیر', N'رضایی'),
			(2, N'نرگس', N'کریمی'),
			(3, N'مجید', N'مهری'),
			(4, N'مهدی', N'شادمان'),
			(5, N'سمیرا', N'عباسی');
GO

SELECT * FROM Students;
GO

USE master;
GO

DROP DATABASE IF EXISTS Test01;
GO

CREATE DATABASE Test01;
GO

USE Test01;
GO

SP_HELPFILE;
GO

SELECT * FROM Students;
GO
--------------------------------------------------------------------

-- Resource بررسی دیتابیس
-- !به محل فیزیکی این دیتابیس اشاره شود

USE master;
GO

--To determine the version number of the Resource database, use
SELECT SERVERPROPERTY('ResourceVersion');
GO

--To determine when the Resource database was last updated, use:
SELECT SERVERPROPERTY('ResourceLastUpdateDateTime');
GO

-- Source View
SELECT OBJECT_DEFINITION(OBJECT_ID('sys.objects')) AS [SQL Definitions];
GO