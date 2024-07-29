

-- سیستمی Stop List های موجود در Stop Word فهرستی از
SELECT * FROM sys.fulltext_system_stopwords;
GO

-- های زبان انگلیسی Stop Word فهرستی از
SELECT * FROM sys.fulltext_system_stopwords
	WHERE language_id = 1033;
GO

-- های زبان عربی Stop Word فهرستی از
SELECT * FROM sys.fulltext_system_stopwords
	WHERE language_id = 1025;
GO

-- های زبان خنثی Stop Word فهرستی از
SELECT * FROM sys.fulltext_system_stopwords
	WHERE language_id = 0;
GO
--------------------------------------------------------------------

USE NikamoozDB_Programmer;
GO

IF (SELECT 1 FROM sys.fulltext_stoplists
		WHERE name = 'StopList01') IS NOT NULL  
	DROP FULLTEXT STOPLIST StopList01;
GO

/*
Stop List ایجاد
.این دستور حتما باید با ; خاتمه یابد
*/
CREATE FULLTEXT STOPLIST StopList01
GO

SELECT * FROM sys.fulltext_stoplists;
GO

-- Stop List های موجود در Stop Word مشاهده
SELECT * FROM sys.fulltext_stopwords
	WHERE stoplist_id = ???;
GO

-- جدید Stop List سیستمی در یک Stop List های Stop Word کپی
CREATE FULLTEXT STOPLIST StopList02 FROM SYSTEM STOPLIST;
GO

SELECT * FROM sys.fulltext_stoplists;
GO

-- Stop List های موجود در Stop Word مشاهده
SELECT * FROM sys.fulltext_stopwords
	WHERE stoplist_id = ???;
GO

-- جدید Stop List های دیتابیسی دیگر در یک Stop Word کپی
CREATE FULLTEXT STOPLIST StopList03 FROM Your_Database_Name.Your_Stoplist_Name;
GO

-- Stop List حذف
DROP FULLTEXT STOPLIST StopList01;
DROP FULLTEXT STOPLIST StopList02;
GO

CREATE FULLTEXT STOPLIST Persian_Stoplist;
GO

SELECT * FROM sys.fulltext_stopwords;
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

SELECT * FROM sys.fulltext_stopwords;
GO

-- Stop List از Stop Word حذف
ALTER FULLTEXT STOPLIST Persian_Stoplist DROP 'He' LANGUAGE 'English'; -- حذف از یك زبان خاص
SELECT * FROM sys.fulltext_stopwords;
GO

ALTER FULLTEXT STOPLIST Persian_Stoplist DROP ALL LANGUAGE 'English'; -- های یک زبان خاص Stop Word حذف تمامی 
SELECT * FROM sys.fulltext_stopwords;
GO

ALTER FULLTEXT STOPLIST Persian_Stoplist DROP ALL; -- Stop List های Stop Word حذف تمامی 
SELECT * FROM sys.fulltext_stopwords;
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

SELECT * FROM sys.fulltext_stopwords;
GO

DROP FULLTEXT STOPLIST Persian_Stoplist;
GO