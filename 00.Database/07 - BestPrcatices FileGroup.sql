

USE master;
GO

DROP DATABASE IF EXISTS Test01;
GO

CREATE DATABASE Test01
	ON PRIMARY
	(
		NAME = Test01_Primary, FILENAME = 'C:\Dump\Test01_Primary.mdf',
		SIZE = 100MB, MAXSIZE = UNLIMITED, FILEGROWTH = 10%
	)
	LOG ON
	(
		NAME = LogFile1, FILENAME = 'C:\Dump\LogFile1.ldf',
		SIZE = 200MB, MAXSIZE = 5GB, FILEGROWTH = 1024MB
	);
GO

-- Test01 به دیتابیس File Group ایجاد چندین
ALTER DATABASE Test01
	ADD FILEGROUP Data_FG;
ALTER DATABASE Test01
	ADD FILEGROUP Index_FG;
ALTER DATABASE Test01
	ADD FILEGROUP BLOB_FG;
GO

-- File Group ایجاد دیتا فایل‌های مربوط به هر
ALTER DATABASE Test01
	ADD FILE
		(
			NAME = Test01_Data, FILENAME = 'C:\Dump\Test01_Data.ndf'
		) TO FILEGROUP Data_FG;
GO
ALTER DATABASE Test01
	ADD FILE
	(
		NAME = Test01_Index, FILENAME = 'C:\Dump\Test01_Index.ndf'
	) TO FILEGROUP Index_FG;
GO
ALTER DATABASE Test01
	ADD FILE
	(
		NAME = Test01_BLOB, FILENAME = 'C:\Dump\Test01_BLOB.ndf'
	) TO FILEGROUP BLOB_FG;
GO

USE Test01;
GO

SP_HELPFILE;
GO

SP_HELPFILEGROUP;
SELECT * FROM sys.filegroups
GO

ALTER DATABASE Test01
	MODIFY FILEGROUP Data_FG DEFAULT;
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS Test01;
GO