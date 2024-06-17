

USE tempdb;
GO

-- Irregular Identifier
CREATE TABLE #T1
	(
		1Col INT
	);

CREATE TABLE #T2
	(
		SELECT INT
	);

CREATE TABLE #T3
	(
		Father Name CHAR(100)
	);
GO

-- Delimited Identifier
CREATE TABLE #T1
	(
		[1Col] INT
	);

CREATE TABLE #T2
	(
		[Select] INT
	);

CREATE TABLE #T3
	(
		[Father Name] CHAR(100)
	);
GO