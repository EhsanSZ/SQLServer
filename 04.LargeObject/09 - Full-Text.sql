

USE master;
GO

DROP DATABASE IF EXISTS [Full-TextDB];
GO

RESTORE DATABASE [Full-TextDB] FROM DISK = 'C:\Dump\Full-TextDB.BAK'
	WITH
		MOVE 'FullTextDB' TO 'C:\Dump\[Full-TextDB].mdf',
		MOVE 'FullTextDB_log' TO 'C:\Dump\[Full-TextDB]_log.ldf',
		REPLACE,
		STATS = 1;
GO

USE [Full-TextDB];
GO

SELECT * FROM Persian;
GO

SP_HELP 'Persian'; -- !مشاهده ساختار جدول به فیلد رشته ای دقت كنید 
GO
--------------------------------------------------------------------

-- File Groupایجاد
ALTER DATABASE [Full-TextDB]
	ADD FILEGROUP FG_PersianData;
GO

SELECT * FROM sys.filegroups;
GO

ALTER DATABASE [Full-TextDB]
	ADD FILE
			(
				NAME = PersianData, FILENAME = 'C:\Dump\PersianData.ndf'
			)
	TO FILEGROUP FG_PersianData;
GO

SELECT * FROM sys.database_files;
GO
--------------------------------------------------------------------

/*
Full Text Catalog ایجاد
*/
DROP FULLTEXT CATALOG Persian_Catalog;
GO

-- .توجه شود FULLTEXT CATALOG به ترتیب پارامترها در تعریف
CREATE FULLTEXT CATALOG Persian_Catalog
	ON FILEGROUP FG_PersianData -- File Group نام  
		WITH ACCENT_SENSITIVITY = OFF -- تعیین حساسیت به لهجه
			AS DEFAULT -- به عنوان كاتالوگ پیش فرض
				AUTHORIZATION dbo; -- مالك
GO

SELECT * FROM sys.fulltext_catalogs;
GO

-- .دیتابیس توضیح داده شود Storage از بخش Object Explorer از طریق Full Text Catalog نحوه ساخت
--------------------------------------------------------------------

/*
Full Text Index ایجاد
*/

DROP FULLTEXT INDEX ON Persian;
GO

-- .استفاده کنیم Full Text Index از قابلیت Persian از جدول Address می‌خواهیم بر روی فیلد

SP_HELP Persian;
GO

-- .وجود كلید اصلی و یا یك كلید كه منحصر به فرد بودن ركوردها را مشخص می كند 
SP_HELPINDEX Persian;
GO

DROP FULLTEXT STOPLIST Persian_Stoplist;
GO

CREATE FULLTEXT STOPLIST Persian_Stoplist;
GO

-- Stop List به Stop Word اضافه كردن
ALTER FULLTEXT STOPLIST Persian_Stoplist ADD 'SSMS' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST Persian_Stoplist ADD 'He' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST Persian_Stoplist ADD 'Here' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST Persian_Stoplist ADD 'Are' LANGUAGE 'English';
ALTER FULLTEXT STOPLIST Persian_Stoplist ADD 'SSMS' LANGUAGE 'Neutral';
ALTER FULLTEXT STOPLIST Persian_Stoplist ADD 'و' LANGUAGE 'Neutral';
ALTER FULLTEXT STOPLIST Persian_Stoplist ADD 'یا' LANGUAGE 'Neutral';
GO

-- FULLTEXT INDEX ایجاد 
CREATE FULLTEXT INDEX
	ON Persian ([Address] LANGUAGE 'Neutral') -- تعیین الگوی زبانی جهت ایندکس
		KEY INDEX PK_Persian -- نام كلید
			ON Persian_Catalog -- FullText Catalog نام
				WITH CHANGE_TRACKING = AUTO, -- نحوه ردیابی تغییرات
					STOPLIST = Persian_Stoplist; -- StopList نام 
GO

SELECT 
	[name] as CatalogName,
	FullTextCatalogProperty('Persian_Catalog', 'IndexSize') AS IndexSizeMB,
	FullTextCatalogProperty('Persian_Catalog', 'ItemCount') AS ItemCount,
	FullTextCatalogProperty('Persian_Catalog', 'UniqueKeyCount') AS UniqueKeyCount,
	CASE FullTextCatalogProperty('Persian_Catalog', 'PopulateStatus')
		WHEN 0 THEN 'Idle'
		WHEN 1 THEN 'Full population in progress'
		WHEN 2 THEN 'Paused'
		WHEN 3 THEN 'Throttled'
		WHEN 4 THEN 'Recovering'
		WHEN 5 THEN 'Shutdown'
		WHEN 6 THEN 'Incremental population in progress'
		WHEN 7 THEN 'Building index'
		WHEN 8 THEN 'Disk is full. Paused.'
		WHEN 9 THEN 'Change tracking'
		ELSE 'Error reading FullTextCatalogProperty PopulateStatus'
	END AS PopulateStatus,
	CASE is_default
		WHEN 1 then 'Yes'
		ELSE 'No'
	END AS IsDefaultCatalog
FROM sys.fulltext_catalogs
ORDER BY [name];
GO

-- استخراج مقادیر موجود در ایندكس
SELECT * FROM sys.dm_fts_index_keywords(db_id('Full-TextDB'), object_id('Persian'))
ORDER BY display_term;
GO

-- .توضیح داده شود Object Explorer از طریق FULLTEXT INDEX نحوه ساخت
--------------------------------------------------------------------

-- درج ركوردهای تستی در جدول
SET IDENTITY_INSERT Persian ON;
GO

INSERT INTO Persian(Code,Address)
	VALUES	(25911, N'SSMS'), -- Stop Word/Noise Word
			(25912, N'یا'), -- Stop Word/Noise Word
			(25913, N'مظاهر'),
			(25914, N'مرداویج');
GO

SET IDENTITY_INSERT Persian OFF;
GO

SELECT * FROM Persian
	WHERE Code BETWEEN 25911 AND 25914;
GO

-- !ها در ایندکس ظاهر نمی‌شوند Stop Word
SELECT * FROM sys.dm_fts_index_keywords(db_id('Full-TextDB'), object_id('Persian'))
	WHERE display_term IN (N'SSMS', N'یا', N'مظاهر', N'مرداویج');
GO

-- ویرایش نحوه ردیابی تغییرات
ALTER FULLTEXT INDEX ON Persian
	SET CHANGE_TRACKING MANUAL; -- MANUAL | AUTO | OFF
GO

-- POPULATION ویرایش نحوه
ALTER FULLTEXT INDEX
	ON Persian
			START  UPDATE POPULATION; -- START {FULL|INCREMENTAL|UPDATE} POPULATION 
GO

SET STATISTICS IO ON;
GO

SELECT * FROM Persian 
	WHERE ADDRESS LIKE N'%ظاهر%';
GO

SELECT * FROM Persian 
	WHERE CONTAINS(*,N'مظاهر');
GO
--------------------------------------------------------------------

SELECT
	 c.name as CatalogName, t.name as TableName,
	 idx.name as UniqueIndexName,
	 case i.is_enabled when 1 then 'Enabled' else 'Not Enabled' end as IsEnabled,
	 i.change_tracking_state_desc, sl.name as StoplistName
FROM sys.fulltext_indexes i
JOIN sys.fulltext_catalogs c
	ON i.fulltext_catalog_id = c.fulltext_catalog_id
JOIN sys.tables t
	ON i.object_id = t.object_id
JOIN sys.indexes idx
	ON i.unique_index_id = idx.index_id
	AND i.object_id = idx.object_id
LEFT JOIN sys.fulltext_stoplists sl
	ON sl.stoplist_id = i.stoplist_id;
GO