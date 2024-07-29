

/*
در زمان ایجاد یک دیتابیس Filestream مربوط به Filegroup ایجاد
*/

USE master;
GO

DROP DATABASE IF EXISTS DB_FG;
GO

CREATE DATABASE DB_FG
	ON PRIMARY
	(
		NAME = DB_FG, FILENAME = 'C:\Dump\DB_FG.mdf'),
	FILEGROUP FG_FileStream CONTAINS FILESTREAM
	(
		NAME = DB_FG_FS, FILENAME ='C:\Dump\DB_FG_FS')
LOG ON 
	(
		NAME = DB_FG_Log, FILENAME = 'C:\Dump\DB_FG_Log.ldf'
	);
GO

/*
NTFS بررسی مسیر 
FILESTREAM با قابلیت Object Explorer بررسی نحوه ایجاد بانک اطلاعاتی در
*/
--------------------------------------------------------------------

USE DB_FG;
GO

SP_HELPFILE;
GO

SELECT * FROM sys.database_files;
GO

SP_HELPFILEGROUP;
GO

SELECT * FROM sys.filegroups;
GO
--------------------------------------------------------------------

/*
به یک دیتابیس موجود Filestream مربوط به Filegroup ایجاد
*/

USE master;
GO

IF DB_ID('DB_FG') > 0
	BEGIN
		ALTER DATABASE DB_FG
			SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE DB_FG;
	END
GO

CREATE DATABASE DB_FG
	ON PRIMARY 
	(
		NAME = DB_FG, FILENAME = 'C:\Dump\DB_FG.mdf'
	)
LOG ON 
	(
		NAME = DB_FG_Log, FILENAME = 'C:\Dump\DB_FG_Log.ldf'
	);
GO

USE DB_FG;
GO

SP_HELPFILEGROUP;
GO

SELECT * FROM sys.filegroups;
GO

-- به دیتابیس Filestream از نوع Filegroup افزودن
ALTER DATABASE DB_FG 
	ADD	FILEGROUP FG_FileStream CONTAINS FILESTREAM;
GO

ALTER DATABASE DB_FG
	ADD FILE
		(
			NAME = DB_FG_FS, FILENAME = 'C:\Dump\DB_FG_FS'
		)TO FILEGROUP FG_FileStream;
GO

SP_HELPFILE;
GO

SELECT * FROM sys.database_files;
GO

SP_HELPFILEGROUP;
GO

SELECT * FROM sys.filegroups;
GO