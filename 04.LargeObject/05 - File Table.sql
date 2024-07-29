

USE master;
GO

DROP DATABASE IF EXISTS DemoFileTable;
GO

CREATE DATABASE DemoFileTable
	WITH FILESTREAM
		( 
			NON_TRANSACTED_ACCESS = FULL,
			DIRECTORY_NAME = N'FileTableDirectory'
		);
GO

ALTER DATABASE DemoFileTable
	ADD FILEGROUP DemoFileTable_FG CONTAINS FILESTREAM;
GO

-- به دیتابیس  Filestream Container اضافه کردن
ALTER DATABASE DemoFileTable
	ADD FILE
		(
			NAME = 'DemoFileTable_File',
			FILENAME = 'C:\DumpFileTable\DemoFileTable_File'
		) TO FILEGROUP DemoFileTable_FG;
GO
--------------------------------------------------------------------

USE DemoFileTable;
GO

DROP TABLE IF EXISTS DemoFileTable;
GO

-- FileTable ایجاد جدول
CREATE TABLE DemoFileTable AS FILETABLE
	WITH
		( 
			FILETABLE_DIRECTORY = 'Dir4DemoFileTable',
			FILETABLE_COLLATE_FILENAME = database_default
		);
GO

SELECT * FROM DemoFileTable;
GO

-- Explore FileTable Directory بررسی مسیر از طریق 

INSERT INTO DemoFileTable(Stream_ID,name,file_stream)
	VALUES('AB5B3FB3-3603-E411-BE93-0CD2925C26C7','InsertedTextFile1.txt',0x);
GO

SELECT * FROM DemoFileTable
	WHERE Stream_ID = 'AB5B3FB3-3603-E411-BE93-0CD2925C26C7';
GO
--------------------------------------------------------------------

-- دسترسی به مسیرها
SELECT 
	file_stream.GetFileNamespacePath()
FROM DemoFileTable;
GO

SELECT FileTableRootPath('DemoFileTable') as RootPath;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS RelationTbl;
GO

-- FileTable ایجاد ارتباط با 
CREATE TABLE RelationTbl
	(
		ID INT,
		Stream_ID UNIQUEIDENTIFIER,
		FirstName NVARCHAR(100),
		LastName NVARCHAR(100),
		Comments NVARCHAR(100),
		CONSTRAINT PK_RelationTbl PRIMARY KEY (ID),
		CONSTRAINT FK_RelationTbl_DemoFileTable FOREIGN KEY (Stream_ID)
		REFERENCES DemoFileTable(Stream_id)
	);
GO

INSERT INTO RelationTbl(ID,Stream_ID,FirstName,LastName,Comments)
	VALUES (1,'AB5B3FB3-3603-E411-BE93-0CD2925C26C7',N'فرهاد',N'ارجمندی',N'دانشجوی دوره جدید');
GO

SELECT * FROM RelationTbl;
GO

SELECT * FROM DemoFileTable;
GO

DELETE FROM DemoFileTable
	WHERE stream_id = 'AB5B3FB3-3603-E411-BE93-0CD2925C26C7';
GO