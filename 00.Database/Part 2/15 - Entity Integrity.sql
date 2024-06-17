

USE master;
GO

DROP DATABASE IF EXISTS EntityIntegrity_DB;
GO

CREATE DATABASE EntityIntegrity_DB;
GO

USE EntityIntegrity_DB;
GO
--------------------------------------------------------------------

/*
Primary Key (PK)
In Column Level
*/

DROP TABLE IF EXISTS Students;
GO

-- PK in Column Level
CREATE TABLE Students
	(
		Code INT CONSTRAINT Code_PK PRIMARY KEY,
		FirstName NVARCHAR(100), 
		LastName NVARCHAR(100), 
		Age INT
	);
GO

/*
.با روش زیر هم می‌توان جدول بالا را ایجاد کرد
CREATE TABLE Students
	(
		Code INT,
		FirstName NVARCHAR(100), 
		LastName NVARCHAR(100), 
		Age INT,
		CONSTRAINT Code_PK PRIMARY KEY (Code)
	);
GO
*/

SP_HELP 'Students';
GO

SP_HELPCONSTRAINT 'Students';
GO

SELECT * FROM sys.key_constraints;
GO

INSERT INTO Students
	VALUES	(1000, N'سحر', N'صفایی', 23),
			(1001, N'علی', N'جاوید', 27);
GO

SELECT * FROM students;
GO

-- Students درج رکورد با کلید تکراری در جدول
INSERT INTO students
	VALUES	(1000, N'رضا', N'کریمی', 32);
GO

-- Students در جدول NULL درج رکورد با کلید
INSERT INTO students 
	VALUES	(NULL, N'رضا', N'کریمی', 32);
GO
--------------------------------------------------------------------

/*
Primary Key (PK)
in Table Level
*/

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		Code INT IDENTITY,
		FirstName NVARCHAR(100), 
		LastName NVARCHAR(100), 
		Age INT,
		CONSTRAINT FL_PK PRIMARY KEY(FirstName,LastName)
	);
GO

/*
!این روش اشتباه است
CREATE TABLE Students
	(
		Code INT IDENTITY,
		FirstName NVARCHAR(100) PRIMARY KEY, 
		LastName NVARCHAR(100) PRIMARY KEY, 
		Age INT
	);
GO
*/

INSERT INTO Students
	VALUES	(N'سحر', N'صفایی', 23),
			(N'علی', N'جاوید', 27);
GO

SELECT * FROM Students;	
GO

-- Students درج رکورد با کلید تکراری در جدول
INSERT INTO Students
	VALUES	(N'علی', N'جاوید', 43);
GO

-- Students در جدول NULL درج رکورد با کلید
INSERT INTO Students
	VALUES	(NULL, N'جاوید', 43);
GO

-- Students در جدول NULL درج رکورد با کلید
INSERT INTO Students
	VALUES	(NULL, NULL, 43);
GO

INSERT INTO Students
	VALUES	(N'احمد', N'جاوید', 43);
GO
--------------------------------------------------------------------

/*
پس از ایجاد جدول فاقد رکورد PRIMARY KEY افزودن
*/

DROP TABLE IF EXISTS T1;
GO

CREATE TABLE T1
	(
		F1 INT,
		F2 INT,
		F3 NVARCHAR (10)
	);
GO

ALTER TABLE T1
	ADD  PRIMARY KEY (F1,F2); -- ADD CONSTRAINT PK_T1 PRIMARY KEY (F1,F2)
GO

ALTER TABLE T1
	ALTER COLUMN F1 INT NOT NULL;
GO

ALTER TABLE T1
	ALTER COLUMN F2 INT NOT NULL;
GO

ALTER TABLE T1
	ADD  PRIMARY KEY (F1,F2); -- ADD CONSTRAINT PK_T1 PRIMARY KEY (F1,F2)
GO

SP_HELPCONSTRAINT T1;
GO
--------------------------------------------------------------------

/*
پس از ایجاد جدول فاقد رکورد PRIMARY KEY افزودن
*/

DROP TABLE IF EXISTS T2;
GO

CREATE TABLE T2
	(
		F1 INT NOT NULL,
		F2 INT NOT NULL,
		F3 NVARCHAR (10)
	);
GO

ALTER TABLE T2
	ADD F4 INT PRIMARY KEY (F1,F2,F4); -- ADD F4 INT CONSTRAINT PK_T2 PRIMARY KEY (F1,F2,F4)
GO

SELECT * FROM sys.key_constraints;
GO
--------------------------------------------------------------------

/*
و جابجایی با فیلد کلید Students افزودن فیلد جدید به جدول
*/

SELECT * FROM Students;
GO

SELECT * FROM sys.key_constraints
	WHERE OBJECT_NAME(parent_object_id) = 'Students';
GO

-- حذف‌ محدودیت كلید اصلی از جدول موردنظر  
ALTER TABLE Students DROP CONSTRAINT FL_PK;
GO

-- به جدول موردنظر PK افزودن‌ فیلد جدید با قابلیت
ALTER TABLE Students
	ADD SchoolID INT CONSTRAINT SchoolID_PK PRIMARY KEY(SchoolID,Code);
GO

ALTER TABLE Students
	ADD SchoolID INT 
	CONSTRAINT SchoolID_PK PRIMARY KEY(SchoolID,Code)
	CONSTRAINT Def_SchoolID DEFAULT 1;
GO

SELECT * FROM Students;
GO
---------------------------------------------------------------

/*
Unique Key (UK)
In Column Level
*/

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		Code INT CONSTRAINT Code_UK UNIQUE,
		FirstName NVARCHAR(100), 
		LastName NVARCHAR(100), 
		Age INT
	);
GO

/*
.با روش زیر هم می‌توان جدول بالا را ایجاد کرد
CREATE TABLE Students
	(
		Code INT,
		FirstName NVARCHAR(100), 
		LastName NVARCHAR(100), 
		Age INT,
		CONSTRAINT Code_UK UNIQUE (Code)
	);
GO
*/

SP_HELP 'Students';
GO

SP_HELPCONSTRAINT 'Students';
GO

INSERT INTO Students
	VALUES	(1000, N'سحر', N'صفایی', 23),
			(1001, N'علی', N'جاوید', 27),
			(NULL, N'فرهاد', N'نادری', 26);
GO

SELECT * FROM Students;	
GO

INSERT INTO Students
	VALUES(1000, N'مجید', N'هدایتی', 29);
GO

INSERT INTO Students
	VALUES(NULL, N'مجید', N'هدایتی', 29);
GO
---------------------------------------------------------------

/*
UNIQUE KEY CONSTRAINT
In Table Level
*/

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		Code INT IDENTITY,
		FirstName NVARCHAR(100), 
		LastName NVARCHAR(100), 
		Age INT,
		CONSTRAINT FL_UK UNIQUE (FirstName,LastName)
	);
GO
--------------------------------------------------------------------

-- !اشاره شود UK و PK به تفاوت‌های میان
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS EntityIntegrity_DB;
GO