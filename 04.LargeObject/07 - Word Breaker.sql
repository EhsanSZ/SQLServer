

/*
word breaker

sys.dm_fts_parser('query_string', lcid, stoplist_id, accent_sensitivity) 
*/

-- Fuul-Text لیست زبان‌های قابل پشتیبانی توسط
SELECT * FROM sys.fulltext_languages
ORDER BY name;
GO

-- Parse 'data-base' in English
SELECT * FROM sys.dm_fts_parser('data-base', 1033, 0, 0);
GO

-- Parse 'data-base' in korean
SELECT * FROM sys.dm_fts_parser('data-base', 1042, 0, 0);
GO

-- Parse 'data-base' in Neutral
SELECT * FROM sys.dm_fts_parser('data-base', 0, 0, 0);
GO

-- Parse 'اطلاعاتی-بانک' in English
SELECT * FROM sys.dm_fts_parser(N'اطلاعاتی-بانک', 1033, 0, 0)
GO

-- Parse 'اطلاعاتی-بانک' in Arabic
SELECT * FROM sys.dm_fts_parser(N'اطلاعاتی-بانک', 1025, 0, 0)
GO

-- Parse 'اطلاعاتی-بانک' in Neutral
SELECT * FROM sys.dm_fts_parser(N'بانک-اطلاعاتی', 0, 0, 0);
GO
--------------------------------------------------------------------

/*
Word Breaker & Stemmer

FORMSOF Clause
*/

-- English
SELECT  *  FROM sys.dm_fts_parser ('FORMSOF( INFLECTIONAL, "Operating System")', 1033, 0, 0);
GO

-- Germany
SELECT  *  FROM sys.dm_fts_parser ('FORMSOF( INFLECTIONAL, "Operating System")', 1031, 0, 0);
GO

-- Neutral
SELECT  *  FROM sys.dm_fts_parser ('FORMSOF( INFLECTIONAL, "Operating System")', 0, 0, 0);
GO

-- Arabic
SELECT  *  FROM sys.dm_fts_parser ('FORMSOF( INFLECTIONAL, "Operating System")', 1025, 0, 0);
GO