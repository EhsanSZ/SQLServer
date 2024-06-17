

USE master;
GO

DROP DATABASE IF EXISTS Test01;
GO

CREATE DATABASE Test01
	ON
	(
		NAME = DataFile1, FILENAME = 'C:\Dump\DataFile1.mdf',
		SIZE = 100MB, MAXSIZE = UNLIMITED, FILEGROWTH = 10%
	)
	LOG ON
	(
		NAME = LogFile1, FILENAME = 'C:\Dump\LogFile1.ldf',
		SIZE = 200MB, MAXSIZE = 5GB, FILEGROWTH = 1024MB
	);
GO

USE Test01;
GO

SP_HELPFILE;
GO

-- های مرتبط با دیتابیس File Group مشاهده لیست
SP_HELPFILEGROUP;
GO

SELECT * FROM sys.filegroups;
GO
--------------------------------------------------------------------

--  جدید به دیتابیس File Group افزودن
ALTER DATABASE Test01
	ADD FILEGROUP FG1;
GO

SP_HELPFILEGROUP;
SELECT * FROM sys.filegroups;
GO

-- ایجاد شده File Group عدم وجود دیتا فایل به ازای
SP_HELPFILE;
GO

-- !اشاره شود Wizard به دیتابیس از طریق File Group به نحوه ایجاد
--------------------------------------------------------------------

-- File Group ایجاد دیتا فایل جدید و قرار دادن آن در یک 
ALTER DATABASE Test01
	ADD FILE
		(
			NAME = DataFile2, FILENAME = 'C:\Dump\DataFile2.ndf'
		) TO FILEGROUP FG1;
GO

SP_HELPFILE;
GO

-- File Group ایجاد دیتا فایل جدید دیگر و قرار دادن آن در یک 
ALTER DATABASE Test01
	ADD FILE
		(
			NAME = DataFile3, FILENAME = 'C:\Dump\DataFile3.ndf'
		) TO FILEGROUP FG1;
GO

SP_HELPFILE;
GO
--------------------------------------------------------------------

-- File Group ایجاد دیتابیس جدید به همراه چندین

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
		SIZE = 100MB, MAXSIZE = UNLIMITED, FILEGROWTH=10%		
	)
	LOG ON
	(
		NAME = LogFile1, FILENAME = 'C:\Dump\LogFile1.ldf',
		SIZE = 200MB, MAXSIZE = 5GB, FILEGROWTH = 1024MB
	);
GO

USE Test01;
GO

SP_HELPFILE;
GO

SP_HELPFILEGROUP;
GO
--------------------------------------------------------------------

-- خاص FILE GROUP قرار دادن یک جدول در یک
CREATE TABLE Customers
	(
		CustomerID INT IDENTITY,
		FirstName CHAR(4000),
		LastName CHAR(3000)
	) ON FG1;
GO

-- بررسی ساختار جدول
SP_HELP Customers;
GO

-- !خاص اشاره شود FILE GROUP به نحوه قرار دادن یک جدول در یک
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS Test01;
GO