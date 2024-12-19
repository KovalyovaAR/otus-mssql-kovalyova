/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".
*/

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

select indate 
      ,[Sylvanite, MT] 
	  ,[Peeples Valley, AZ] 
	  ,[Medicine Lodge, KS] 
	  ,[Gasport, NY] 
	  ,[Jessie, ND] 
from
(select DATEFROMPARTS(year(si.InvoiceDate), month(si.InvoiceDate), 01) as indate
	, si.InvoiceID 
	, substring(c.customername, charindex('(', c.CustomerName)+1, len(c.customername) - charindex('(', c.CustomerName)-1) as cusname
from sales.Invoices si
join sales.Customers c on c.CustomerID = si.CustomerID
where c.BuyingGroupID = 1 and c.CustomerID in (2,3,4,5,6)) 
as SourceTable
pivot
(
count(InvoiceID) 
for cusname  
in ([Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND] ) 
)
as PivotTable

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select CustomerName as columnname, AddressLine
from sales.Customers
unpivot
(
AddressLine for columnname in (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)
) as res
where BuyingGroupID = 1

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select CountryID, CountryName, code
from 
(select ac.CountryID, ac.CountryName, cast(ac.IsoAlpha3Code as varchar(10)) as txtcode, cast(ac.IsoNumericCode as varchar(10)) as numcode
from Application.Countries ac) as datatable
unpivot
(
code for columnname in (txtcode, numcode)
) as res

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

-- в задании не указано, что вывести нужно 2 уникальных товара и самую последнюю дату продажи, если один и тот же товар куплен одним и тем же клиентом несколько раз

WITH OrdersFoCustomer AS (
	select sol.StockItemID, sol.UnitPrice, ap.FullName, ap.PersonID, so.OrderDate
		, dense_rank() over (partition by ap.PersonID order by sol.UnitPrice desc) as b
	from sales.Orders so
	join sales.OrderLines sol on so.OrderID = sol.OrderID
	join Application.People ap on ap.PersonID = so.CustomerID
)

select PersonID, FullName, StockItemID, UnitPrice, OrderDate
from OrdersFoCustomer
where b <= 2
