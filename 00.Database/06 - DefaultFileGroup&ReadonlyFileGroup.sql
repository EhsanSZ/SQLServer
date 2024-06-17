

USE master;
GO

DROP DATABASE IF EXISTS Test01;
GO

CREATE DATABASE Test01
	ON 
	PRIMARY
	(
		NAME = DataFile1, FILENAME = 'C:\Dump\DataFile1.mdf',
		SIZE = 100MB, MAXSIZE = UNLIMITED, FILEGROWTH = 10%
	),
	FILEGROUP FG1
	(
		NAME = DataFile2, FILENAME = 'C:\Dump\DataFile2.mdf',
		SIZE = 100MB, MAXSIZE = UNLIMITED, FILEGROWTH = 10%
	),
	(
		NAME = DataFile3, FILENAME = 'C:\Dump\DataFile3.mdf',
		SIZE = 100MB, MAXSIZE = UNLIMITED, FILEGROWTH = 10%
	),
	FILEGROUP FG2
	(
		NAME = DataFile4, FILENAME = 'C:\Dump\DataFile4.mdf',
		SIZE = 100MB, MAXSIZE = UNLIMITED, FILEGROWTH = 10%		
	)
	LOG ON
	(
		NAME = LogFile1, FILENAME = 'C:\Dump\LogFile1.LDF',
		SIZE = 200MB, MAXSIZE = 5GB, FILEGROWTH = 1024MB
	);
GO

USE Test01;
GO

SP_HELPFILE;
GO

SELECT * FROM sys.filegroups;
GO
--------------------------------------------------------------------

/*
Default File Group تعیین
*/

CREATE TABLE Customers01
	(
		CustomerID INT IDENTITY,
		FirstName CHAR(4000),
		LastName CHAR(3000)
	);
GO

SP_HELP Customers01;
GO

-- !ای هم نمایش داده شود Wizard این موضوع به شکل
ALTER DATABASE Test01
	MODIFY FILEGROUP FG1 DEFAULT;
GO

SELECT * FROM sys.filegroups;
GO

CREATE TABLE Customers02
	(
		CustomerID INT IDENTITY,
		FirstName CHAR(4000),
		LastName CHAR(3000)
	);
GO

SP_HELP Customers02;
GO
--------------------------------------------------------------------

/*
FILEGROUP تنظیمات مربوط به رشد‌پذیری دیتا فایل‌های موجود در
*/

-- !ای هم نمایش داده شود Wizard این موضوع به شکل
ALTER DATABASE Test01
	MODIFY FILEGROUP FG1 AUTOGROW_ALL_FILES;
GO

SELECT * FROM sys.filegroups;
GO

ALTER DATABASE Test01
	MODIFY FILEGROUP FG1 AUTOGROW_SINGLE_FILE;
GO

SELECT * FROM sys.filegroups;
GO
--------------------------------------------------------------------

/*
Read-Only File Group تعیین
*/

DROP TABLE IF EXISTS Customers03;
GO

CREATE TABLE Customers03
	(
		CustomerID INT IDENTITY,
		FirstName NCHAR(4000),
		LastName NCHAR(3000)
	) ON FG2;
GO

ALTER DATABASE Test01
	MODIFY FILEGROUP FG2 READ_ONLY
GO

INSERT INTO Customers03(FirstName,LastName)
	VALUES (N'سروش', N'کریمی');
GO

ALTER DATABASE Test01
	MODIFY  FILEGROUP FG2 READ_WRITE;
GO

INSERT INTO Customers03(FirstName,LastName)
	VALUES (N'سروش', N'کریمی');
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS Test01;
GO