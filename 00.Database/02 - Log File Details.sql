

DROP DATABASE IF EXISTS Test01;
GO

CREATE DATABASE Test01;
GO

USE Test01;
GO

SP_HELPFILE;
GO

SELECT
	database_id, name, recovery_model_desc
FROM sys.databases;
GO

-- هاVLF مشاهده
DBCC LOGINFO;
GO

-- مشاهده محتوای لاگ فایل
DBCC LOG('Test01');
GO
SELECT * FROM sys.fn_dblog(NULL,NULL);
GO

-- Recovery Model: Simple در حالت Log File بررسی رفتار
ALTER DATABASE Test01 SET RECOVERY SIMPLE;
GO

-- ها از حافظه به دیسکDirty Page انتقال 
CHECKPOINT;
GO

--Log File مشاهده محتوای
SELECT * FROM sys.fn_dblog(NULL,NULL);
GO

DROP TABLE IF EXISTS MyTbl;
GO

CREATE TABLE MyTbl
	(
		Code INT IDENTITY,
		Family NVARCHAR(100)
	);
GO

SELECT * FROM sys.fn_dblog(NULL,NULL);
GO

CHECKPOINT;
GO

SELECT * FROM sys.fn_dblog(NULL,NULL);
GO

CHECKPOINT;
GO

INSERT INTO MyTbl 
	VALUES (N'داوری');
GO

SELECT * FROM sys.fn_dblog(NULL,NULL);
GO

CHECKPOINT;
GO

BEGIN TRANSACTION
	UPDATE MyTbl
	SET Family = N'تابش'
		WHERE Code = 1;
ROLLBACK TRANSACTION;
GO

SELECT * FROM sys.fn_dblog(NULL,NULL);
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS Test01;
GO