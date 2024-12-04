/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

-- подзапрос
select ap.PersonID, ap.FullName 
from Application.People ap
where ap.IsSalesperson = 1 and
	ap.PersonID not in (select SalespersonPersonID
						from Sales.Invoices
						where InvoiceDate = '2015-07-04')


-- CTE 

;with TREE (saleid, invoicedate)
as 
(select distinct SalespersonPersonID, InvoiceDate
from Sales.Invoices
where InvoiceDate = '2015-07-04'
)

select ap.PersonID, ap.FullName
from Application.People ap 
left join tree t 
	on t.saleid = ap.PersonID
where ap.IsSalesperson = 1
	and t.saleid is null

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

select ws.StockItemID, ws.StockItemName, ws.UnitPrice
from Warehouse.StockItems ws
where ws.UnitPrice = (select min(UnitPrice) from Warehouse.StockItems)



/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

select sc.CustomerID, sc.CustomerName, sc.DeliveryCityID, sc.PhoneNumber, sc.FaxNumber, sc.DeliveryAddressLine1, sc.DeliveryAddressLine2
from sales.Customers sc
where sc.CustomerID in (select top 5 CustomerID 
						from Sales.CustomerTransactions
						order by TransactionAmount desc)

;with TREE (custid)
as 
(select top 5 CustomerID
from Sales.CustomerTransactions
order by TransactionAmount desc
)

select distinct sc.CustomerID, sc.CustomerName, sc.DeliveryCityID, sc.PhoneNumber, sc.FaxNumber, sc.DeliveryAddressLine1, sc.DeliveryAddressLine2
from sales.Customers sc
join TREE t
	on t.custid = sc.CustomerID

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

select sc.DeliveryCityID, ac.CityName, ap.FullName
from sales.Invoices si 
join sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
join Application.People ap on ap.PersonID = si.PackedByPersonID
join sales.Customers sc on sc.CustomerID = si.CustomerID
join Application.Cities ac on ac.CityID = sc.DeliveryCityID
where sil.StockItemID in (select top 3 StockItemID
						from Warehouse.StockItems ws
						order by ws.UnitPrice desc)

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

/*
запрос выводит продажи сумма которых больше 27000 (кол-во*стоимость)
*/

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

select 
	si.InvoiceID,
	si.InvoiceDate, 
	ap.FullName AS SalesPersonName, 
	SUM(sil.Quantity*sil.UnitPrice) AS TotalSummByInvoice
	, (SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = so.OrderID	
	) AS TotalSummForPickedItems
from Sales.Invoices si 
join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
join Application.People ap on ap.PersonID = si.SalespersonPersonID
join sales.Orders so on so.OrderID = si.OrderID and so.PickingCompletedWhen IS NOT NULL
group by si.InvoiceID, si.invoicedate, ap.FullName, so.OrderID
HAVING SUM(sil.Quantity*sil.UnitPrice) > 27000
ORDER BY  TotalSummByInvoice DESC
