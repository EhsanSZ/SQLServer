

/*
Instance در سطح Filestream اعمال تنظیمات
*/

USE master;
GO

SP_CONFIGURE 'show advanced options',1;
RECONFIGURE;
GO

/*
0:Disable 
1:Transact SQL Access  
2:Full Acess Enabled

.خواهد شد Instance موجب اعمال تنظیمات بر روی RECONFIGURE ندارد و همان Restart این تنظیمات نیازی به
*/
SP_CONFIGURE 'filestream access level',2;
RECONFIGURE;
GO