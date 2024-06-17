

USE master;
GO

DROP DATABASE IF EXISTS DomainIntegrity_DB;
GO

CREATE DATABASE DomainIntegrity_DB;
GO

USE DomainIntegrity_DB;
GO
--------------------------------------------------------------------

/*
DEFAULT CONSTRAINT
*/

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		NationalCode INT CONSTRAINT NationalCode_Const DEFAULT 0,
		Family NVARCHAR(100) NOT NULL,
		StdStatus NVARCHAR(100) CONSTRAINT StdStatus_Const DEFAULT N'ندارد'
	);
GO

-- Students های جدولCONSTRAINT مشاهده
SP_HELPCONSTRAINT 'Students';
GO

SELECT * FROM sys.default_constraints;
GO

INSERT INTO Students (Family)
	VALUES (N'احمدی'),(N'راد'),(N'سعیدی');
GO

SELECT * FROM Students;
GO

/*
در زمان اضافه کردن DEFAULT CONSTRAINT پیاده‌سازی 
WITH VALUES فیلد جدید به جدول با استفاده از
*/
ALTER TABLE Students
	ADD Code1 INT DEFAULT 100000 WITH VALUES;
GO

SP_HELPCONSTRAINT 'Students';
GO

SELECT * FROM Students;
GO

-- WITH VALUES بدون استفاده از
ALTER TABLE students
	ADD Code2 INT DEFAULT 200000;
GO

SP_HELPCONSTRAINT 'Students';
GO

SELECT * FROM Students;
GO

ALTER TABLE students
	ADD Age INT;
GO

SELECT * FROM Students;
GO

-- به یک فیلد موجود DEFAULT Constraint افزودن
ALTER TABLE Students
	ADD DEFAULT 0 FOR Age;
GO
--------------------------------------------------------------------

/*
CHECK CONSTRAINT
*/

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		StudentId INT,
		Gender NVARCHAR(6) CHECK (Gender IN ('Male','Female')), --(Column Level) در سطح فیلد
		MobilePhone VARCHAR(20) CHECK (MobilePhone LIKE '0912-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'), --(Column Level) در سطح فیلد
		Math DECIMAL(4,2) CHECK (Math BETWEEN 15 AND 20), --(Column Level) در سطح فیلد
		Physics DECIMAL(4,2) CONSTRAINT Physics_Const CHECK (Physics BETWEEN 15 AND 20), -- (Column Level) در سطح فیلد
		[Avg] AS ((Math+Physics)/2) PERSISTED CONSTRAINT Avg_Check CHECK ([AVG] BETWEEN 15 AND 20) -- (Table Level) در سطح جدول
	);
GO

SP_HELPCONSTRAINT 'Students';
GO

SELECT * FROM sys.check_constraints;
GO

INSERT INTO Students(StudentId,Gender,MobilePhone,Math,Physics) 
	VALUES	(12345, N'مرد', '09121234567', 16.25, 14.75);
GO

INSERT INTO Students(StudentId,Gender,MobilePhone,Math,Physics) 
	VALUES	(12345, 'Male', '09121234567', 16.25, 14.75);
GO

INSERT INTO Students(StudentId,Gender,MobilePhone,Math,Physics) 
	VALUES	(12345, 'Male', '0912-1234567', 16.25, 14.75);
GO

INSERT INTO Students(StudentId,Gender,MobilePhone,Math,Physics) 
	VALUES	(12345, 'Male', '0912-1234567', 16.25, 15.75),
			(12378, 'Female', '0912-1234500', 18.25, 16.45);
GO

SELECT * FROM Students;
GO

-- در لحظه افزودن فیلد جدید به جدول CHECK CONSTRAINT پیاده‌سازی 
ALTER TABLE Students
	ADD Chemistry DECIMAL(4,2) CHECK (Chemistry >= 10);
GO

SP_HELPCONSTRAINT 'Students';
GO

SELECT * FROM Students;
GO

ALTER TABLE Students
	ADD English DECIMAL(4,2) DEFAULT 12 WITH VALUES;
GO

SP_HELPCONSTRAINT 'Students';
GO

SELECT * FROM Students;
GO

-- بر روی فیلد موجود و دارای مقدار CHECK CONSTRAINT پیاده‌سازی 
ALTER TABLE Students
	ADD CHECK(English > 12);
GO

ALTER TABLE Students
	WITH NOCHECK -- بر روی مقادیر موجود Constraint نادیده گرفتن
	ADD CHECK(English > 12);
GO

SP_HELPCONSTRAINT 'Students';
GO
--------------------------------------------------------------------

/*
در هنگام ایجاد جدول CHECK و DEFAULT های Constraint ترکیب
*/

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
	(
		StudentId INT,
		Gender  NVARCHAR(6) CHECK (Gender IN ('Male','Female')), --(Column Level) در سطح فیلد
		MobilePhone VARCHAR(20) CHECK (MobilePhone LIKE '0912-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'), --(Column Level) در سطح فیلد
		Math  DECIMAL(4,2) DEFAULT 15 CHECK (Math BETWEEN 15 AND 20), --(Column Level) در سطح فیلد
		Physics  DECIMAL(4,2) CONSTRAINT Default_L2 DEFAULT 15 CONSTRAINT Math_Check CHECK (Physics BETWEEN 15 AND 20), -- (Column Level) در سطح فیلد
		[Avg]   AS ((Math+Physics)/2) PERSISTED CONSTRAINT Avg_Check CHECK ([AVG] BETWEEN 15 AND 20) -- (Table Level) در سطح جدول
	);
GO

SP_HELPCONSTRAINT 'Students';
GO

INSERT INTO Students(StudentId,Gender,MobilePhone) 
	VALUES	(12345, 'Male', '0912-1234567');
GO

SELECT * FROM Students;
GO
--------------------------------------------------------------------

-- ها در محیط ویژوالی Constraint نمایش
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS DomainIntegrity_DB;
GO