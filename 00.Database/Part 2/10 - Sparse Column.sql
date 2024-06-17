

USE master;
GO

DROP DATABASE IF EXISTS Sparse_DB;
GO

CREATE DATABASE Sparse_DB;
GO

USE Sparse_DB;
GO

DROP TABLE IF EXISTS Sparse_Tbl;
GO

CREATE TABLE Sparse_Tbl 
	(
		C1 INT SPARSE,
		C2 INT SPARSE,
		C3 CHAR(100) SPARSE,
		C4 VARCHAR(100) SPARSE
	);
GO

-- SPARSE جدول جهت بررسی Design مراجعه به محیط

INSERT INTO dbo.Sparse_Tbl (C1,C2,C3,C4)
	VALUES	(NULL, NULL, NULL, NULL),
			(1, 2, 'A', 'A');
GO

SELECT * FROM dbo.Sparse_Tbl;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS Student_Info1,Student_Info2_Sparse;
GO

-- Sparse Columns ایجاد جدول فاقد 
CREATE TABLE Student_Info1
	(
		ID INT IDENTITY,
		F_NAME NVARCHAR(50),
		L_NAME NVARCHAR(50),
		D1 CHAR(100),
		D2 CHAR(100),
		D3 CHAR(100),
		D4 CHAR(100),
		D5 CHAR(100),
		D6 CHAR(100),
		D7 CHAR(100),
		D8 CHAR(100),
		D9 CHAR(100),
		D10 CHAR(100)
	);
GO

-- Sparse Columns ایجاد جدول دارای 
CREATE TABLE Student_Info2_Sparse
	(
		ID INT IDENTITY,
		F_NAME NVARCHAR(50),
		L_NAME NVARCHAR(50),
		D1 CHAR(100) SPARSE,
		D2 CHAR(100) SPARSE,
		D3 CHAR(100) SPARSE,
		D4 CHAR(100) SPARSE,
		D5 CHAR(100) SPARSE,
		D6 CHAR(100) SPARSE,
		D7 CHAR(100) SPARSE,
		D8 CHAR(100) SPARSE,
		D9 CHAR(100) SPARSE,
		D10 CHAR(100) SPARSE
	);
GO

-- Sparse Columns درج رکورد در جدول فاقد 
INSERT INTO Student_Info1 (F_NAME,L_NAME,D2,D3,D4)
	VALUES	('A','A','D12E5','21E1','Q10A'),
			('B','B','1T2U5','41O1','R1D0'),
			('C','C','1U2O5','7P11','W0F5');
GO 1000

-- Sparse Columns درج رکورد در جدول دارای 
INSERT INTO Student_Info2_Sparse (F_NAME,L_NAME,D2,D3,D4)
	VALUES	('A','A','D12E5','21E1','Q10A'),
			('B','B','1T2U5','41O1','R1D0'),
			('C','C','1U2O5','7P11','W0F5');
GO 1000

UPDATE Student_Info1 
	SET D5='XXXX',D6='XXXX',D7='XXXX',
		D8='XXXX',D9='XXXX',D10='XXXX'
	WHERE ID % 45 = 1;
GO

UPDATE Student_Info2_Sparse
	SET D5='XXXX', D6='XXXX', D7='XXXX',
		D8='XXXX', D9='XXXX', D10='XXXX'
	WHERE ID % 45 = 1;
GO

SELECT * FROM Student_Info1;
SELECT * FROM Student_Info2_Sparse;
GO

-- مشاهده حجم تخصیص داده شده به جداول
SP_SPACEUSED Student_Info1;
GO
SP_SPACEUSED Student_Info2_Sparse;
GO

-- برآورد میانگین اندازه هر رکورد
SELECT
	[avg_record_size_in_bytes]
FROM sys.dm_db_index_physical_stats (DB_ID('Sparse_DB'), OBJECT_ID ('Student_Info1'), NULL, NULL, 'DETAILED');
GO

SELECT
	[avg_record_size_in_bytes]
FROM sys.dm_db_index_physical_stats (DB_ID('Sparse_DB'), OBJECT_ID ('Student_Info2_Sparse'), NULL, NULL, 'DETAILED');
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS Sparse_DB;
GO