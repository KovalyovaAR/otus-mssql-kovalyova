exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO

exec sp_configure 'clr enabled', 1;
exec sp_configure 'clr strict security', 0
GO

reconfigure;
GO

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

CREATE ASSEMBLY HomeWork_CLR
FROM 'C:\Users\KovalyovaAR\source\repos\HomeWork\HomeWork\bin\Release\HomeWork.dll'
WITH PERMISSION_SET = SAFE;


CREATE FUNCTION [dbo].SplitStringCLR(@text [nvarchar](max), @delimiter [nchar](1))
RETURNS TABLE (
	part nvarchar(max),
	ID_ODER int
) AS EXTERNAL NAME HomeWork_CLR.UserDefinedFunctions.SplitString

select * 
from SplitStringCLR ('12,34,567,12,56,34,87,94', ',')