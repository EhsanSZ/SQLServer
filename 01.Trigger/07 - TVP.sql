

/*
TVP: Table Value Parameter
*/

USE NikamoozDB_Programmer;
GO

DROP TABLE IF EXISTS Std, Std_Lessons;
GO

CREATE TABLE Std
	(
		Code INT,
		FirstName NVARCHAR(50),
		LastName NVARCHAR(50)
	);
GO

CREATE TABLE Std_Lessons
	(
		Code INT,
		Lesson_Code INT,
		Lesson_Name NVARCHAR(50)
	);
GO

DROP TYPE IF EXISTS Std_LessonsType;
GO

CREATE TYPE Std_LessonsType AS TABLE
	(
	   Code INT,
	   Lesson_Code INT,
	   Lesson_Name NVARCHAR(50)
	);
GO

DROP PROC IF EXISTS Insert_Std_Lesson;
GO

CREATE PROCEDURE Insert_Std_Lesson 
(
	@Code INT,
	@FirstName NVARCHAR(50),
	@LastName NVARCHAR(50),
	@T Std_LessonsType READONLY
)
AS
BEGIN
	INSERT INTO Std (Code, FirstName ,LastName)
		VALUES (@Code, @FirstName, @LastName);

	INSERT INTO Std_Lessons (Code, Lesson_Code, Lesson_Name)
		SELECT Code,Lesson_Code,Lesson_Name FROM @T;
END
GO

DECLARE @Code INT = 1;
DECLARE @FirstName NVARCHAR(50) = N'فرزانه';
DECLARE @LastName NVARCHAR(50) = N'شفیعیان';
DECLARE @T AS Std_LessonsType;

INSERT @T  
    VALUES	(1, 100, N'فیزیک'), 
			(1, 200, N'شیمی'), 
			(1, 300, N'هندسه'), 
			(1, 400, N'زبان'), 
			(1, 500, N'ادبیات');

EXEC Insert_Std_Lesson @Code, @FirstName, @LastName, @T;
GO

SELECT * FROM Std;
SELECT * FROM Std_Lessons;
GO

/*
https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/table-valued-parameters
*/