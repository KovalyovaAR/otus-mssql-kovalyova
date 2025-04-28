ALTER PROCEDURE Sales.SendInvoiceDate
	@datefrom date,
	@dateto date
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(max);
	
	BEGIN TRAN 

	--Формируем XML с корнем RequestMessage 
	SELECT @RequestMessage = (select sc.customername, count(si.OrderID) as kol, @datefrom as datefrom, @dateto as dateto
							from [Sales].[Invoices] si
							join [Sales].[Customers] sc on sc.CustomerID = si.CustomerID
							where si.InvoiceDate between @datefrom and @dateto
							group by sc.customername
							FOR XML AUTO, root('RequestMessage')); 
	
	
	--Создаем диалог
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService] --от этого сервиса(это сервис текущей БД, поэтому он НЕ строка)
	TO SERVICE
	'//WWI/SB/TargetService'    --к этому сервису(это сервис который может быть где-то, поэтому строка)
	ON CONTRACT
	[//WWI/SB/Contract]         --в рамках этого контракта
	WITH ENCRYPTION=OFF;        --не шифрованный


	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);

	SELECT @RequestMessage AS SentRequestMessage;
	
	COMMIT TRAN 
END