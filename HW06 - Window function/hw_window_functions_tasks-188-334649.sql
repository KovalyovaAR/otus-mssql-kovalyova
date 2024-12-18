/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".
*/

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

напишите здесь свое решение

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

select si.InvoiceID, ap.FullName, si.InvoiceDate, sil.ExtendedPrice, sum(sil.ExtendedPrice) over (partition by month(si.InvoiceDate), year(si.invoicedate))
from sales.Invoices si
join sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
join Application.People ap on ap.PersonID = si.CustomerID
where si.InvoiceDate between '2015-01-01' and getdate()
order by si.InvoiceDate asc

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

WITH SaleForMonth AS (
	select sil.Description as descr, month(si.InvoiceDate) as m
		, sum(sil.Quantity) as s
		, sil.StockItemID
	from sales.Invoices si
	join sales.InvoiceLines sil on si.InvoiceID = sil.InvoiceID
	where si.InvoiceDate between '2016-01-01' and '2016-12-31'
	group by sil.Description, month(si.InvoiceDate), sil.StockItemID
),
Sales AS (
	SELECT m,
		descr,
		s,
		ROW_NUMBER() OVER (PARTITION BY m ORDER BY s DESC) AS rankform
    FROM SaleForMonth
)

SELECT m, descr, s, rankform
FROM Sales
WHERE rankform <= 2
ORDER BY m, rankform;

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select  ws.StockItemID, ws.StockItemName, ws.Brand, ws.UnitPrice
	, ROW_NUMBER() over (partition by 0 order by left(ws.StockItemName, 1) asc) as rn
	, count(ws.StockItemID) over () as [общее кол-во]
	, count(ws.StockItemID) over (partition by left(ws.StockItemName, 1)) as [кол-во по первой букве]
	, lead(ws.StockItemID) over (order by ws.StockItemName asc) as [след.товар]
	, lag(ws.StockItemID) over (order by ws.StockItemName asc) as [пред.товар]
	, lag(ws.StockItemName, 2, 'No items') over (order by ws.StockItemName asc) as [товар 2 строки назад]
	, ntile(30) over (partition by ws.TypicalWeightPerUnit order by ws.StockItemName asc)
from Warehouse.StockItems ws
order by ws.StockItemName asc

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

WITH Orders AS (
    SELECT 
        so.SalespersonPersonID,
        so.customerid,
        so.orderdate,
        SUM(sol.unitprice * sol.quantity) AS amount,
        ROW_NUMBER() OVER (PARTITION BY so.SalespersonPersonID ORDER BY so.orderdate DESC) AS rn
    FROM sales.orders so
    JOIN sales.orderlines sol ON so.orderid = sol.orderid
    GROUP BY so.SalespersonPersonID, so.customerid, so.orderdate
)

SELECT 
    SalespersonPersonID,
    customerid,
    orderdate,
    amount
FROM Orders
WHERE rn = 1  
ORDER BY SalespersonPersonID;

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
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

 