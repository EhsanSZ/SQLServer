

USE master;
GO

-- FULLTEXTSERVICEPROPERTY با استفاده از تابع Full-Text بررسی وضعیت نصب سرویس
SELECT 
	CASE FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')
		WHEN 1 THEN 'Full-Text is installed.' 
		ELSE 'Full-Text is NOT installed.' 
	END;
GO

SELECT * FROM sys.dm_server_services;
GO

-- ویندوز Services و Configuration Manager در Full-Text نمایش سرویس
--------------------------------------------------------------------

-- به ازای دیتابیس‌ها Full-Text بررسی وضعیت
SELECT 
	name, is_fulltext_enabled
FROM sys.databases;
GO

USE Northwind;
GO

EXEC sp_fulltext_database 'disable';
GO

SELECT 
	name, is_fulltext_enabled
FROM sys.databases
	WHERE name = 'Northwind';
GO

EXEC sp_fulltext_database 'enable';
GO

SELECT 
	name, is_fulltext_enabled
FROM sys.databases
	WHERE name = 'Northwind';
GO