declare @datefrom date = '2013-01-01', @dateto date = '2013-01-01'
, @xml xml, @kol int

--select sc.customername, count(si.OrderID) 
--from [Sales].[Invoices] si
--join [Sales].[Customers] sc on sc.CustomerID = si.CustomerID
--where si.InvoiceDate between @date1 and @date2
--group by sc.customername

DECLARE @RequestMessage NVARCHAR(max);

SELECT @RequestMessage = (select sc.customername, count(si.OrderID) as kol, @datefrom as datefrom, @dateto as dateto
							from [Sales].[Invoices] si
							join [Sales].[Customers] sc on sc.CustomerID = si.CustomerID
							where si.InvoiceDate between @datefrom and @dateto
							group by sc.customername
							FOR XML AUTO, root('RequestMessage'));

--SELECT @RequestMessage AS SentRequestMessage;

SET @xml = CAST(@RequestMessage AS XML);

select @xml

SELECT @kol = R.Iv.value('@kol','int')
	FROM @xml.nodes('/RequestMessage/sc') as R(Iv);

select @kol
