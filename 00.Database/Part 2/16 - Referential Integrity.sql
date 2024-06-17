

USE master;
GO

DROP DATABASE IF EXISTS Refrential_DB;
GO

CREATE DATABASE Refrential_DB;
GO

USE Refrential_DB;
GO
--------------------------------------------------------------------

/*
FOREIGN KEY CONSTRAINT
In Column Level
*/

DROP TABLE IF EXISTS Orders, Customers;
GO

-- (Parent) جدول پدر
CREATE TABLE Customers
	(
		ID INT PRIMARY KEY ,
		CompanyName NVARCHAR(100)
	);
GO

CREATE INDEX IX_CompanyName ON Customers(CompanyName);
GO

EXEC SP_HELPCONSTRAINT 'Customers';
GO

INSERT INTO Customers 
	VALUES	(100, N'مشتری 1'),
			(101, N'مشتری 2'),
			(102, N'مشتری 3');
GO
	
-- (Child) جدول فرزند
CREATE TABLE Orders
	(
		ID INT CONSTRAINT FK_ID REFERENCES Customers(ID),-- CONSTRAINT FK_ID FOREIGN KEY(ID) REFERENCES Customers(ID)
		OrderDate CHAR(10)
	);
GO

/*
FOREIGN KEYروش معادل برای ایجاد
CREATE TABLE Orders
	(
		ID INT,
		OrderDate CHAR(10),
		CONSTRAINT FK_ID FOREIGN KEY(ID) REFERENCES Customers(ID)
	);
GO
*/

EXEC SP_HELPCONSTRAINT 'Orders';
GO

INSERT INTO Orders 
	VALUES	(100,'1400.03.25'),
			(101,'1400.03.29'), (101,'1400.04.01'),
			(102,'1400.04.02'), (102,'1400.04.03'), (102,'1400.04.11');
GO

SELECT * FROM Customers;
SELECT * FROM Orders;
GO

-- (Parent) درج رکورد در جدول
INSERT INTO Customers 
	VALUES	(103, N'مشتری 4');
GO

SELECT * FROM Customers;
GO

-- (Child) درج رکورد در جدول
INSERT INTO Orders 
	VALUES	(104,'1400.04.22');
GO

/*
(Parent) به‌روز رسانی رکورد در جدول

مشاهده پلن اجرایی قبل از فعال‌سازی حالات مختلف
Insert And Update Specification بررسی حالت‌های مختلف
مشاهده پلن اجرایی پس از فعال‌سازی حالات مختلف
*/

UPDATE Customers
	SET ID = 1000
		WHERE ID = 100;
GO

-- و بررسی پلن اجرایی و مقایسه آن با حالت قبل Constraint غیر فعال‌سازی موقت
ALTER TABLE Orders
	NOCHECK CONSTRAINT FK_ID;
GO

-- Constraint فعال‌سازی مجدد
ALTER TABLE Orders
	CHECK CONSTRAINT FK_ID;
GO

-- (Child) به‌روز رسانی رکورد در جدول
UPDATE Orders
	SET ID = 2000
		WHERE ID = 1000;
GO

/*
(Parent) حذف رکورد از جدول
!توجه به اپراتور حذف رکورد از فضای ایندکس در پلن اجرایی   ‌   ‌
*/
DELETE FROM Customers
	WHERE ID = 1000;
GO

SELECT * FROM Customers;
SELECT * FROM Orders;
GO

-- (Child) حذف رکورد از جدول
DELETE FROM Orders
	WHERE ID = 101;
GO

SELECT * FROM Customers;
SELECT * FROM Orders;
GO
--------------------------------------------------------------------

/*
FOREIGN KEY CONSTRAINT
In Table Level
*/

DROP TABLE IF EXISTS ParentTbl, ChildTbl;
GO

-- (Parent) جدول پدر
CREATE TABLE ParentTbl
	(
		Col1 INT,
		Col2 INT,
		PRIMARY KEY(Col1,Col2)
	);
GO

-- (Child) جدول فرزند
CREATE TABLE ChildTbl
(
	Fld1 INT,
	Fld2 INT,
	Title VARCHAR(10),
	FOREIGN KEY(Fld1,Fld2) REFERENCES ParentTbl(Col1,Col2)
);
GO

EXEC SP_HELPCONSTRAINT 'ChildTbl';
GO
--------------------------------------------------------------------

/*
FORIEGN KEY CONSTRAINT
SET DEFAULT SET NULL
*/
DROP TABLE IF EXISTS Employees, Job_Type;
GO

-- (Parent) جدول پدر
CREATE TABLE Job_Type
	(
		Code INT IDENTITY,
		Title NVARCHAR(50) PRIMARY KEY
	);
GO

INSERT Job_Type
	VALUES	(N'مدیریت'),(N'معاونت'),(N'سرپرست'),
			(N'کارشناس'),(N'نامشخص');
GO

-- (Child) جدول فرزند
CREATE TABLE Employees
	(
		ID INT IDENTITY (0,100) PRIMARY KEY,
		Family NVARCHAR(100),
		JobTitle NVARCHAR(50) REFERENCES Job_Type(Title)
								ON UPDATE SET NULL
								ON DELETE SET DEFAULT
								   DEFAULT N'نامشخص'
	);
GO

INSERT Employees
	VALUES	(N'باقری', N'مدیریت'),
			(N'سعادت', N'معاونت'),
			(N'صدر', N'سرپرست'),
			(N'کریمی', N'سرپرست'),
			(N'صادقی', N'کارشناس'),
			(N'پویا', N'کارشناس');
GO

EXEC SP_HELPCONSTRAINT 'Employees';
GO

-- (Parent) حذف رکورد از جدول
DELETE FROM Job_Type 
	WHERE Code = 3;
GO

SELECT * FROM Job_Type;
SELECT * FROM Employees;
GO

-- (Parent) به‌روزرسانی رکورد از جدول
UPDATE Job_Type
	SET Title = N'مدیر سابق'
	WHERE Code = 1;
GO

SELECT * FROM Job_Type;
SELECT * FROM Employees;
GO
--------------------------------------------------------------------

USE master;
GO

DROP DATABASE IF EXISTS Refrential_DB;
GO