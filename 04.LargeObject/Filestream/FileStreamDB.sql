

USE master;
GO

SP_CONFIGURE 'show advanced options',1;
RECONFIGURE;
GO

SP_CONFIGURE 'filestream access level',2;
RECONFIGURE;
GO
--------------------------------------------------------------------

DROP DATABASE IF EXISTS FileStreamTestDB;
GO

CREATE DATABASE FileStreamTestDB
	ON PRIMARY 
			(
				NAME = FileStreamTestDB, FILENAME = 'C:\Dump\FileStreamTestDB.mdf'
			),
	FILEGROUP FG_FileStream CONTAINS FILESTREAM
			(
				NAME = FileStreamTestDB_FSG, FILENAME ='C:\Dump\FileStreamTestDB_FSG'
			)
	LOG ON 
			(
				NAME = FileStreamTestDB_Log, FILENAME = 'C:\Dump\FileStreamTestDB_Log.ldf'
			);
GO

USE FileStreamTestDB;
GO

DROP TABLE IF EXISTS BLOB_Table;
GO

CREATE TABLE BLOB_Table
	(
		PkId INT PRIMARY KEY IDENTITY (1, 1),
		FileID UNIQUEIDENTIFIER NOT NULL UNIQUE ROWGUIDCOL DEFAULT NEWSEQUENTIALID(),
		Comments NVARCHAR(200) NOT NULL,
		FName NVARCHAR(200) NOT NULL,
		FileData VARBINARY(MAX) FILESTREAM NULL
	)
FILESTREAM_ON FG_FileStream;
GO
--------------------------------------------------------------------

SELECT * FROM BLOB_Table;
GO

SELECT
	PkId, FILEID, Comments, FName,
	FileData.PathName()
FROM BLOB_Table;
GO