

/*
در هنگام ایجاد یک جدول جدید Filestream افزودن قابلیت
*/

USE DB_FG;
GO

DROP TABLE IF EXISTS FG_Tbl;
GO

CREATE TABLE FG_Tbl
	(
		ID INT IDENTITY PRIMARY KEY,
		FS_ID  UNIQUEIDENTIFIER NOT NULL ROWGUIDCOL UNIQUE DEFAULT(NEWSEQUENTIALID()),
		Title NVARCHAR(255) NOT NULL,
		Content VARBINARY(MAX) FILESTREAM NULL
	)    
FILESTREAM_ON FG_FileStream;
GO

/*
NTFS بررسی فولدرهای موجود در 
جدول Design و محیط Object Explorer بررسی در
*/
--------------------------------------------------------------------

/*
به یک جدول موجود Filestream افزودن قابلیت
*/

DROP TABLE IF EXISTS FG_Tbl;
GO

CREATE TABLE FG_Tbl
	(
		ID INT IDENTITY PRIMARY KEY,
		Title NVARCHAR(255) NOT NULL
	);  
GO

-- به جدول Filestream مربوط به Filegroup تخصیص
ALTER TABLE FG_Tbl
	SET(FILESTREAM_ON = 'FG_FileStream');
GO

ALTER TABLE FG_Tbl
	ADD FS_ID UNIQUEIDENTIFIER NOT NULL ROWGUIDCOL UNIQUE DEFAULT(NEWSEQUENTIALID()),
		Content	VARBINARY(MAX) FILESTREAM NULL;
GO

SP_HELP FG_Tbl;
GO

SP_HELPINDEX FG_Tbl;
GO	 

INSERT INTO FG_Tbl(Title,Content)
	VALUES ('Hello SQL',CAST(REPLICATE('Hello SQL-',10) AS VARBINARY(MAX)));
GO

-- NTFS مشاهده فایل در

SELECT Content FROM FG_Tbl;
GO

SELECT
	*, CAST(Content AS VARCHAR(MAX)) 
FROM FG_Tbl;
GO

-- درج یک تصویر در جدول
INSERT INTO FG_Tbl(Title,Content)
	SELECT 
		'Filestream Title', BulkColumn
	FROM OPENROWSET
		(
			BULK N'C:\Dump\Person01.jpg',
			SINGLE_BLOB, Single_Blob
		) AS Tmp;
GO

SELECT * FROM FG_Tbl;
GO

SELECT
	*, CAST(Content AS VARCHAR(MAX))
FROM FG_Tbl;
GO

SELECT
	ID, FS_ID, Title, Content.PathName()
FROM FG_Tbl;
GO