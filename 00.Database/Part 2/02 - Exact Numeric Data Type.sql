

USE master;
GO

-- SQL Server های سیستمی در Data Type لیست تمامی
SELECT * FROM sys.types;
GO

-- !های سیستمی در هر دیتابیس نمایش داده شود Data Type محل
--------------------------------------------------------------------

DECLARE @Var INT = 100;
SELECT @Var; 
GO

DECLARE @Var INT;
SELECT @Var = 100 -- SET @Var = 100;
SELECT @Var;
GO

-- DataLength بررسی تابع
DECLARE @Var INT;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

DECLARE @Var INT = 100;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO
--------------------------------------------------------------------

/*
BIT
Range: 0, 1, NULL
Storage:
BIT Columns <= 8		1 Byte
BIT Columns 9 - 16		2 Bytes
*/
DECLARE @Var BIT = 1;
SELECT DATALENGTH(@Var);
SELECT @Var;
GO
--------------------------------------------------------------------

/*
TINYINT
Range: 0 to 255
Storage: 1 Byte
*/
DECLARE @Var TINYINT = 100;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO
--------------------------------------------------------------------

/*
SMALLINT
Range: -2^15 (-32,768) to 2^15-1 (32,767)
Storage: 2 Bytes
*/
DECLARE @Var SMALLINT = 32000;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO
--------------------------------------------------------------------

/*
INT
Range: -2^31 (-2,147,483,648) to 2^31-1 (2,147,483,647)
Storage: 4 Bytes
*/
DECLARE @Var INT = 1000;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO
--------------------------------------------------------------------

/*
BIGINT
Range: -2^63 (-9,223,372,036,854,775,808) to 2^63-1 (9,223,372,036,854,775,807)
Storage: 8 Bytes
*/
DECLARE @Var BIGINT = 1000;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO
--------------------------------------------------------------------

/*
NUMERIC, DECIMAL
DECIMAL[ (p[ ,s] )] , NUMERIC[ (p[ ,s] )]

p(Precision): تعداد کل ارقام
مقدار پیش‌فرض = 18
38 = حداکثر مقدار

s(Scale): تعداد ارقام اعشاری

Storage:
P: 1-9			5 Bytes
P: 10-19		9 Bytes
P: 20-28		13 Bytes
P: 29-38		17 Bytes
*/
DECLARE @Var NUMERIC = 1400;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

DECLARE @Var DECIMAL = 1400;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

DECLARE @Var DECIMAL(8,3) = 12345.123;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

-- .انجام خواهد شد SQL Server در صورت عدم رسیدن به نهایت تعداد ارقام، مدیریت فضا توسط
DECLARE @Var DECIMAL(38,0) = 12345.123;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

DECLARE @Var NUMERIC(38,0) = 12345.123;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

DECLARE @Var DECIMAL(8,0) = 123456789.123;
SELECT @Var
SELECT DATALENGTH(@Var);
GO

DECLARE @Var DECIMAL(11,0) = 12345678912;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

DECLARE @Var DECIMAL(21,0) = 123456789123456789123;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

DECLARE @Var DECIMAL(38,0)=12345678912345678912345678912345678912
SELECT @Var
SELECT DATALENGTH(@Var);
GO

/*
FORMAT( value, format [, culture ] ) 
*/
DECLARE @Var DECIMAL(17,4) = 32000000;
SELECT @Var;
SELECT FORMAT(@Var, 'N', 'en-us');
SELECT FORMAT(@Var, '#,#');
GO
--------------------------------------------------------------------

/*
SMALLMONEY
Range: -214,748.3648 to 214,748.3647
Storage: 4 Bytes
*/

-- توجه به تعداد ارقام اعشار
DECLARE @Var SMALLMONEY = 214748;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

-- حداکثر تعداد ارقام اعشار
DECLARE @Var SMALLMONEY = 214748.1234;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO
--------------------------------------------------------------------

/*
MONEY
Range: -922,337,203,685,477.5808 to 922,337,203,685,477.5807
Storage: 8 Byte
*/

-- توجه به تعداد ارقام اعشار
DECLARE @Var MONEY = 1000000;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

-- حداکثر تعداد ارقام اعشار
DECLARE @Var MONEY = 1000000.1234;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO