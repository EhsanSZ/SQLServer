
USE Programmer;
GO

-- Plan Cache مربوط به Cache پاک کردن
DBCC FREEPROCCACHE;
GO

SELECT * FROM Employees
	WHERE EmployeeID = 1;
GO

-- .شده است Cache آن‌ها Plan لیست کوئری‌هایی که
SELECT * FROM sys.dm_exec_cached_plans;
GO

SELECT * FROM sys.dm_exec_sql_text(0x06001000918C8828908203A69901000001000000000000000000000000000000000000000000000000000000);
GO

-- به همراه متن کوئری Plan Cache مشاهده کوئری‌های موجود در
SELECT
	P.bucketid, P.usecounts, P.size_in_bytes, P.objtype, T.text
FROM sys.dm_exec_cached_plans AS P
CROSS APPLY sys.dm_exec_sql_text(P.plan_handle) AS T;
GO

-- به همراه متن کوئری و پلن اجرایی Plan Cache مشاهده کوئری‌های موجود در
SELECT 
	P.bucketid, P.usecounts, P.size_in_bytes, T.text,QP.query_plan 
FROM sys.dm_exec_cached_plans AS P
CROSS APPLY sys.dm_exec_sql_text(P.plan_handle) AS T
CROSS APPLY sys.dm_exec_query_plan(P.plan_handle) AS QP;
GO

DBCC FREEPROCCACHE;
GO

EXEC GetEmployeeByID 1;
GO

EXEC GetEmployeeByID 4;
GO

EXEC GetEmployeeByID 9;
GO

SELECT
	P.bucketid, P.usecounts, P.size_in_bytes, T.text
FROM sys.dm_exec_cached_plans AS P
CROSS APPLY sys.dm_exec_sql_text(P.plan_handle) AS T
	WHERE T.text LIKE '%Employees%';
GO

DBCC FREEPROCCACHE;
GO

-- .کوئری زیر استثنا چندین مرتبه اجرا شود
SELECT * FROM Employees
	WHERE EmployeeID = 1;
GO

SELECT * FROM Employees
	WHERE EmployeeID= 1;
GO

SELECT * FROM Employees
	WHERE EmployeeID= 1; -- کد کارمند
GO

SELECT
	P.bucketid, P.usecounts, P.size_in_bytes, T.text
FROM sys.dm_exec_cached_plans AS P
CROSS APPLY sys.dm_exec_sql_text(P.plan_handle) AS T;
GO