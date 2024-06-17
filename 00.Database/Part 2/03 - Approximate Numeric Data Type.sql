

/*
Real
Range: - 3.40E + 38 to -1.18E - 38, 0 and 1.18E - 38 to 3.40E + 38
Storage: 4 Bytes
*/
DECLARE @Var REAL = 1234567;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

DECLARE @Var REAL = 12345678;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

/*
Float[(n)]
Float(n) : تعداد بیت‌های مورد استفاده برای مانتیس n
.در لگاریتم اعداد، جزء صحیح لگاریتم را مفسر و جزء اعشاری آن را «مانتیس » گویند

Storage:
n: 1-24		&	p:7 digits		4 Bytes
n: 25-53	&	p:15 digits		8 Bytes
*/
DECLARE @Var FLOAT(8) = 12345678.78954;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO

DECLARE @Var FLOAT = 12345678.78954;
SELECT @Var;
SELECT DATALENGTH(@Var);
GO