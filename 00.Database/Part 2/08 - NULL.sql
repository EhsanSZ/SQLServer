

USE tempdb;
GO

CREATE TABLE #NullTable
	(
		Col1 INT,
		Col2 NVARCHAR(20) NULL,
		Col3 NVARCHAR(20) NOT NULL
	);
GO

INSERT INTO #NullTable (Col1,Col2,Col3)
	VALUES	(NULL, NULL, N'Values');
GO

INSERT INTO #NullTable (Col1,Col2,Col3)
	VALUES	(1, NULL, NULL);
GO

INSERT INTO #NullTable (Col1,Col2,Col3)
	VALUES	(1, NULL, N'Values');
GO

INSERT INTO #NullTable (Col1,Col2,Col3)
	VALUES	(1, N'Values', '');
GO

INSERT INTO #NullTable (Col1,Col2,Col3)
	VALUES	(1, DEFAULT, N'Values');
GO

SELECT * FROM #NullTable
GO

-- !جداول به این موضوع اشاره شود Design در محیط