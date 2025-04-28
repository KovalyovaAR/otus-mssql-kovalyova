ALTER PROCEDURE Sales.SendInvoiceDate
	@datefrom date,
	@dateto date
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(max);
	
	BEGIN TRAN 

	--��������� XML � ������ RequestMessage 
	SELECT @RequestMessage = (select sc.customername, count(si.OrderID) as kol, @datefrom as datefrom, @dateto as dateto
							from [Sales].[Invoices] si
							join [Sales].[Customers] sc on sc.CustomerID = si.CustomerID
							where si.InvoiceDate between @datefrom and @dateto
							group by sc.customername
							FOR XML AUTO, root('RequestMessage')); 
	
	
	--������� ������
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService] --�� ����� �������(��� ������ ������� ��, ������� �� �� ������)
	TO SERVICE
	'//WWI/SB/TargetService'    --� ����� �������(��� ������ ������� ����� ���� ���-��, ������� ������)
	ON CONTRACT
	[//WWI/SB/Contract]         --� ������ ����� ���������
	WITH ENCRYPTION=OFF;        --�� �����������


	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);

	SELECT @RequestMessage AS SentRequestMessage;
	
	COMMIT TRAN 
END