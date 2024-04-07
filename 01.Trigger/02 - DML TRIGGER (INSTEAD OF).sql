
/*
CREATE [ OR ALTER ] TRIGGER [ schema_name . ]trigger_name   
ON { table | view }   
{ AFTER | INSTEAD OF }   
{ [ INSERT ] [ , ] [ UPDATE ] [ , ] [ DELETE ] }   
AS { sql_statement  [ ; ] [ ,...n ] }  
*/


/*
DML TRIGGER (INSTEAD OF)
*/

USE master;
GO

DROP DATABASE IF EXISTS DML_Trigger_DB;
GO

CREATE DATABASE DML_Trigger_DB;
GO

USE DML_Trigger_DB;
GO

DROP TABLE IF EXISTS Valid_Persons,InValid_Persons;
GO

CREATE TABLE Valid_Persons
	(
		Code INT,
		LastName NVARCHAR(50),
		Age TINYINT
	);
GO

CREATE TABLE InValid_Persons
	(
		Code INT,
		LastName NVARCHAR(50),
		Age TINYINT
	);
GO

CREATE TRIGGER Valid_InsertTrigger ON Valid_Persons
INSTEAD OF INSERT
AS
	DECLARE @Age TINYINT;
	SELECT @Age = Age FROM inserted;
	/*
	معادل دو خط بالا
	DECLARE @Age TINYINT = (SELECT Age FROM inserted)
	*/
	IF (@Age < 50)
		INSERT INTO Valid_Persons
			SELECT * FROM inserted;
	ELSE
		INSERT INTO InValid_Persons
			SELECT * FROM inserted;
GO

INSERT Valid_Persons (Code,LastName,Age)
	VALUES	(1, N'فرهادی', 54);
GO

INSERT Valid_Persons (Code,LastName,Age)
	VALUES	(2, N'احمدیان', 21);
GO

SELECT * FROM Valid_Persons;
SELECT * FROM InValid_Persons;
GO
--------------------------------------------------------------------

/*
ENCRYPTION
*/
-- .امکان‌پذیر است Natively Compiled Modules ها صرفا برای TRIGGER در سطح SCHEMABINDING استفاده از تنظیمات
CREATE OR ALTER TRIGGER Valid_InsertTrigger ON Valid_Persons
WITH ENCRYPTION
INSTEAD OF INSERT
AS
	DECLARE @Age TINYINT;
	SELECT @Age = Age FROM inserted;
	IF (@Age < 50)
		INSERT INTO Valid_Persons SELECT * FROM inserted;
	ELSE
		INSERT INTO InValid_Persons SELECT * FROM inserted;
GO