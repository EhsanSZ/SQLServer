
/*
Logon TRIGGER
*/

/*
CREATE [ OR ALTER ] TRIGGER trigger_name   
ON ALL SERVER   
[ WITH <logon_trigger_option> [ ,...n ] ]  
{ FOR| AFTER } LOGON    
AS { sql_statement  [ ; ] [ ,...n ] | EXTERNAL NAME < method specifier >  [ ; ] }  
  
<logon_trigger_option> ::=  
    [ ENCRYPTION ]  
    [ EXECUTE AS Clause ]
*/

USE master;
GO

DROP DATABASE IF EXISTS Logon_Trigger_DB;
GO

CREATE DATABASE Logon_Trigger_DB;
GO

USE Logon_Trigger_DB;
GO

DROP TABLE IF EXISTS Logon_Auditing_Tbl;
GO

CREATE TABLE Logon_Auditing_Tbl
	(
		SessionId INT,
		LogonTime DATETIME,
		HostName VARCHAR(50),
		ProgramName VARCHAR(500),
		LoginName VARCHAR(50),
		ClientHost VARCHAR(50)
	);
GO

USE master;
GO

CREATE OR ALTER TRIGGER Logon_Audit_Trigger ON ALL SERVER
FOR LOGON
AS
BEGIN
	DECLARE @LogonTriggerData xml, @EventTime datetime, @LoginName varchar(50),
			@ClientHost varchar(50), @LoginType varchar(50), @HostName varchar(50),
			@AppName varchar(500);
	SET @LogonTriggerData = EVENTDATA();
	SET @EventTime = @LogonTriggerData.value('(/EVENT_INSTANCE/PostTime)[1]', 'DATETIME');
	SET @LoginName = @LogonTriggerData.value('(/EVENT_INSTANCE/LoginName)[1]', 'VARCHAR(50)');
	SET @ClientHost = @LogonTriggerData.value('(/EVENT_INSTANCE/ClientHost)[1]', 'VARCHAR(50)');
	SET @HostName = HOST_NAME();
	SET @AppName = APP_NAME();
	INSERT INTO Logon_Trigger_DB.dbo.Logon_Auditing_Tbl
	(SessionId,LogonTime,HostName,ProgramName,LoginName,ClientHost)
		SELECT	@@SPID,	@EventTime,	@HostName, @AppName, @LoginName, @ClientHost;
END
GO

SELECT * FROM Logon_Trigger_DB.dbo.Logon_Auditing_Tbl;
GO

-- !در پایان این بخش حتما اسکریپت زیر را اجرا کنید
DROP TRIGGER Logon_Audit_Trigger ON ALL SERVER;
GO