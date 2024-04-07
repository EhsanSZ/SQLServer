
/*
DDL TRIGGER (Database Level)
*/

/* 
CREATE [ OR ALTER ] TRIGGER trigger_name   
ON { ALL SERVER | DATABASE }   
[ WITH <ddl_trigger_option> [ ,...n ] ]  
{ FOR | AFTER } { event_type | event_group } [ ,...n ]  
AS { sql_statement  [ ; ] [ ,...n ] | EXTERNAL NAME < method specifier >  [ ; ] }  
  
<ddl_trigger_option> ::=  
    [ ENCRYPTION ]  
    [ EXECUTE AS Clause ]
*/

USE master;
GO

DROP DATABASE IF EXISTS DDL_Trigger_DB;
GO

CREATE DATABASE DDL_Trigger_DB;
GO

USE DDL_Trigger_DB;
GO

/*
در سطوح مختلف DDL TRIGGER فهرست انواع
https://docs.microsoft.com/en-us/sql/relational-databases/triggers/ddl-event-groups?view=sql-server-ver15
*/

WITH DirectReports(name, parent_type, type, level, sort)
AS   
(  
    SELECT
		CONVERT(VARCHAR(255),type_name), parent_type, type, 1, CONVERT(VARCHAR(255),type_name)  
    FROM sys.trigger_event_types   
		WHERE parent_type IS NULL  
    UNION ALL  
    SELECT
		CONVERT(VARCHAR(255), REPLICATE ('|   ' , level) + ET.type_name),  
        ET.parent_type, ET.type, level + 1,  
		CONVERT (varchar(255), RTRIM(sort) + '|   ' + ET.type_name)  
    FROM sys.trigger_event_types AS ET  
	JOIN DirectReports AS DR  
		ON ET.parent_type = DR.type
)  
SELECT
	parent_type, type, name  
FROM DirectReports  
ORDER BY sort;
GO

-- .نمایش داده شود Object Explorer تریگر ایجاد شده در
CREATE OR ALTER TRIGGER DDL_Trigger1 ON DATABASE 
FOR DROP_TABLE, ALTER_TABLE 
AS 
   PRINT 'You must disable Trigger "safety" to drop or alter tables!';
   ROLLBACK;
GO

SELECT * FROM sys.triggers;
GO

SELECT * FROM sys.trigger_events;
GO

DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees
	(
		ID INT PRIMARY KEY,
		Family NVARCHAR(50)
	);
GO

DROP TABLE Employees;
GO

ALTER TABLE Employees
	ADD Phone CHAR(11) NULL;
GO

DROP TABLE IF EXISTS Employees;
GO

-- DDL TRIGGER کردن DISABLE
DISABLE TRIGGER DDL_Trigger1 ON DATABASE;
GO

ALTER TABLE Employees
	ADD Phone CHAR(11) NULL;
GO

-- DDL TRIGGER کردن ENABLE
ENABLE TRIGGER DDL_Trigger1 ON DATABASE;
GO

ALTER TABLE Employees
	ADD Stat VARCHAR(200) NULL;
GO

-- DDL TRIGGER کردن DROP
DROP TRIGGER DDL_Trigger1 ON DATABASE;
GO
--------------------------------------------------------------------

CREATE OR ALTER TRIGGER DDL_Trigger1 ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS 
AS 
	PRINT 'You are not allowed to do this action!';
	ROLLBACK;
GO

-- .تعریف شده، در سطح دیتابیس انجام داد TRIGGER در DDL_DATABASE_LEVEL_EVENTS هایی که نمی‌توان به واسطه استفاده از Event فهرست
WITH DirectReports
AS
(
	SELECT 
		type, type_name, parent_type , 1 AS [Level]
	FROM sys.trigger_event_types
		WHERE type_name = 'DDL_DATABASE_LEVEL_EVENTS'
	UNION ALL
	SELECT 
		TE.type, TE.type_name, TE.parent_type, DR.[Level] + 1 
	FROM sys.trigger_event_types AS TE
	JOIN DirectReports AS DR
		ON TE.parent_type = DR.type
)
SELECT * FROM DirectReports
ORDER BY [Level], type;
GO

DROP TABLE IF EXISTS Test;
GO

CREATE TABLE Test
	(
		Col1 INT
	);
GO

CREATE PROCEDURE Employees_List
AS
BEGIN
	SELECT * FROM Test;
END 
GO

DROP TRIGGER DDL_Trigger1 ON DATABASE;
GO
--------------------------------------------------------------------

-- EVENTDATA از طریق تابع DDL TRIGGER استخراج اطلاعات مرتبط با تاثیرگذاری
CREATE OR ALTER TRIGGER DDL_Trigger1 ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS 
AS
	DECLARE @data XML;
	SET @data = EVENTDATA();
	PRINT CAST (@data AS NVARCHAR(MAX));
GO

DROP TABLE IF EXISTS Test;
GO

CREATE TABLE Test
	(
		Col1 INT
	);
GO

DROP TRIGGER DDL_Trigger1 ON DATABASE;
GO

DROP TABLE IF EXISTS DDL_Log;
GO

CREATE TABLE DDL_Log 
	(
		PostTime DATETIME, 
		DB_User NVARCHAR(100), 
		Event_Type NVARCHAR(100), 
		T_SQL NVARCHAR(2000)
	);
GO

CREATE OR ALTER TRIGGER DDL_Trigger_Log ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS 
AS
	DECLARE @data XML;
	SET @data = EVENTDATA();
	INSERT INTO DDL_Log(PostTime,DB_User,Event_Type,T_SQL) 
		VALUES
			(
				GETDATE(), 
				CONVERT(NVARCHAR(100), CURRENT_USER), 
				@data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'), 
				@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(2000)') 
			);
GO

CREATE TABLE TestTable 
	(
		Col1 INT,
		Col2 TINYINT
	);
GO

DROP TABLE TestTable;
GO

SELECT * FROM DDL_Log;
GO

DROP TRIGGER DDL_Trigger_Log ON DATABASE;
GO

DELETE FROM DDL_Log;
GO
--------------------------------------------------------------------

/*
DDL TRIGGER (Server Level)
*/

USE master;
GO

-- .نمایش داده شود Object Explorer تریگر ایجاد شده در
CREATE TRIGGER DDL_Server_Trigger ON ALL SERVER
FOR DDL_DATABASE_LEVEL_EVENTS 
AS
	DECLARE @data XML;
	DECLARE @DB_Name NVARCHAR(100);
	SET @data = EVENTDATA();
	INSERT DDL_Trigger_DB..DDL_Log(PostTime,DB_User,Event_Type,T_SQL) 
		VALUES
			(
				GETDATE(), 
				CONVERT(NVARCHAR(100), CURRENT_USER), 
				@data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'), 
				@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(2000)')
			);
	PRINT (CAST(EVENTDATA() AS NVARCHAR(MAX)));
GO

USE NikamoozDB_Programmer;
GO

DROP TABLE IF EXISTS New_Customers;
GO

CREATE TABLE New_Customers
	(
		ID INT,
		Family NVARCHAR(50)
	);
GO

SELECT * FROM DDL_Trigger_DB.dbo.DDL_Log;
GO

-- دیگر Session و در یک Northwind انجام عملیات ایجاد جدول در دیتابیس

SELECT * FROM DDL_Trigger_DB.dbo.DDL_Log;
GO

USE master;
GO

DROP TRIGGER DDL_Server_Trigger ON ALL SERVER;
GO












/*
SCHEMABINDING & ENCRYPTION
*/
/*
برای خودم

.قابل استفاده است Natively Compiled Modules صرفا برای WITH SCHEMABINDING تنظیمات
.استفاده کرد DML TRIGGER را می‌توان بر رای هر یک از انواع مختلف WITH ENCRYPTION اما تنظیمات
*/


SP_DEPENDS 'InsertTrg_Persons'
SELECT * FROM sys.sql_expression_dependencies
SELECT * FROM sys.dm_sql_referenced_entities('Trigger_DB','DATABASE_DDL_TRIGGER') --     OBJECT  DATABASE_DDL_TRIGGER  | SERVER_DDL_TRIGGER 





-- غیر فعال کردن تریگری که در سطح دیتابیس تعریف شد 
CREATE TRIGGER safety   
ON DATABASE   
FOR DROP_TABLE, ALTER_TABLE   
AS   
   PRINT 'You must disable Trigger "safety" to drop or alter tables!'   
   ROLLBACK;  
GO  
DISABLE TRIGGER safety ON DATABASE;  
GO  
ENABLE TRIGGER safety ON DATABASE;  
GO 

-- غیر فعال کردن تمامی تریگرهای تعریف شده در سطح سرور
DISABLE Trigger ALL ON ALL SERVER;  
GO  
ENABLE Trigger ALL ON ALL SERVER;  
GO
--------------------------------------------------------------------

/*
ENCRYPTION
*/
-- .امکان‌پذیر است Natively Compiled Modules ها صرفا برای TRIGGER در سطح SCHEMABINDING استفاده از تنظیمات
/*
برای خودم

.قابل استفاده است Natively Compiled Modules صرفا برای WITH SCHEMABINDING تنظیمات
.استفاده کرد DML TRIGGER را می‌توان بر رای هر یک از انواع مختلف WITH ENCRYPTION اما تنظیمات
*/
USE DDL_Trigger_DB;
GO

CREATE OR ALTER TRIGGER DDL_Trigger1 ON DATABASE 
WITH ENCRYPTION
FOR DROP_TABLE, ALTER_TABLE
AS 
   PRINT 'You must disable Trigger "safety" to drop or alter tables!';
   ROLLBACK;
GO

CREATE OR ALTER TRIGGER DDL_Server_Trigger ON ALL SERVER
WITH ENCRYPTION
FOR DDL_DATABASE_LEVEL_EVENTS 
AS
	DECLARE @data XML;
	DECLARE @DB_Name NVARCHAR(100);
	SET @data = EVENTDATA();
	INSERT DDL_Trigger_DB..DDL_Log(PostTime,DB_User,Event_Type,T_SQL) 
		VALUES
			(
				GETDATE(), 
				CONVERT(NVARCHAR(100), CURRENT_USER), 
				@data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'), 
				@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(2000)')
			);
	PRINT (CAST(EVENTDATA() AS NVARCHAR(MAX)));
GO

DROP TRIGGER IF EXISTS DDL_Trigger1,DDL_Server_Trigger;
GO