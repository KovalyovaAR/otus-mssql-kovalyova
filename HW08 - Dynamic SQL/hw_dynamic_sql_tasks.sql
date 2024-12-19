/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".
*/

USE WideWorldImporters

/*

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


DECLARE @dml AS NVARCHAR(MAX)
DECLARE @cusname AS NVARCHAR(MAX)

SELECT @cusname= ISNULL(@cusname + ',','') 
       + QUOTENAME(cusname)
FROM (select distinct c.CustomerName as cusname
from sales.Invoices si
join sales.Customers c on c.CustomerID = si.CustomerID
where c.BuyingGroupID = 1
) AS cusromers

SET @dml = 
  N'SELECT convert(varchar(20), indate, 104) as InvoiceMonth, ' + @cusname + ' FROM
  (
  SELECT DATEFROMPARTS(year(si.InvoiceDate), month(si.InvoiceDate), 01) as indate
		, si.InvoiceID 
		, c.customername
   FROM sales.Invoices si
   JOIN sales.Customers c on c.CustomerID = si.CustomerID
   where c.BuyingGroupID = 1
   --order by indate asc
   ) AS T
    PIVOT(count(InvoiceID)  
           FOR customername IN (' + @cusname + ')) AS PVTable 
	order by indate asc'

EXEC sp_executesql @dml
