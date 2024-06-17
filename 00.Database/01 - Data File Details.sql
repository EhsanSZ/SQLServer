

-- بررسی جهت وجود دیتابیس و حذف آن 
DROP DATABASE IF EXISTS Test01;
GO

-- ایجاد دیتابیس
CREATE DATABASE Test01;
GO 

USE Test01;
GO

-- TestDataFile مشاهده مشخصات دیتابیس
SELECT * FROM sys.sysfiles;
GO

EXEC sp_helpfile;
GO

-- SQL 2016 بررسی جهت وجود جدول و حذف آن قبل از
IF OBJECT_ID('Students') > 0
	DROP TABLE Students;
GO

-- به‌بعد SQL 2016 بررسی جهت وجود جدول و حذف آن از
DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		FirstName NVARCHAR(100), 
		LastName NVARCHAR(100), 
		Age INT
	);
GO

INSERT INTO Students 
	VALUES	(N'سعید', N'محمدی', 27),
			(N'نرگس', N'جهانی', 24);
GO

SELECT * FROM Students;
GO

-- بررسي حجم جدول
SP_SPACEUSED Students;
GO

/*
Show Page Information

DBCC IND ( { 'dbname' | dbid }, { 'objname' | objid }, { nonclustered indid | 1 | 0 | -1 | -2 });
nonclustered indid = non-clustered Index ID 
1 = Clustered Index ID 
0 = Displays information in-row data pages and in-row IAM pages (from Heap) 
-1 = Displays information for all pages of all indexes including LOB (Large object binary) pages and row-overflow pages 
-2 = Displays information for all IAM pages

PageType Field Value:
1= data page
2= index page
3 and 4 = text pages
8 = GAM page
9 = SGAM page
10 = IAM page
11 = PFS page
*/

-- Students های تخصیص داده‌شده به جدولpage مشاهده
-- DBCC: Database Console Command
DBCC IND ('Test01', 'Students', 1);
GO 

SELECT
	sys.fn_PhysLocFormatter (%%physloc%%) AS [Physical RID], *
FROM Students;
GO

SELECT * FROM Students AS Std 
CROSS APPLY
sys.fn_PhysLocCracker(%%physloc%%) AS FPLC
ORDER BY FPLC.file_id, FPLC.page_id, FPLC.slot_id;
GO

/*
DBCC PAGE ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ]);Printopt:
0 - print just the page header
1 - page header plus per-row hex dumps and a dump of the page slot array 
2 - page header plus whole page hex dump
3 - page header plus detailed per-row interpretation
*/
-- students مشاهده محتوای جدول
DBCC TRACEON (3604);
DBCC PAGE ('Test01',1 ,??? ,3); -- !وارد کنید DBCC IND را از دستور PagePID به جای علامت سوال مقدار فیلد
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS Test01;
GO