/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select  
	year(si.InvoiceDate) as y_sale,
	month(si.InvoiceDate) as m_sale,
	avg(sil.UnitPrice) as avg_price,
	sum(sil.ExtendedPrice) as sum_price
from Sales.Invoices si
join sales.InvoiceLines sil 
	on si.InvoiceID = sil.InvoiceID
group by year(si.InvoiceDate), month(si.InvoiceDate)
order by y_sale, m_sale

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select  
	year(si.InvoiceDate) as y_sale,
	month(si.InvoiceDate) as m_sale,
	sum(sil.ExtendedPrice) as sum_price
from Sales.Invoices si
join sales.InvoiceLines sil 
	on si.InvoiceID = sil.InvoiceID
group by year(si.InvoiceDate), month(si.InvoiceDate)
having sum(sil.ExtendedPrice) > 4600000
order by y_sale, m_sale

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select  
	year(si.InvoiceDate) as y_sale,
	month(si.InvoiceDate) as m_sale,
	wsi.StockItemName
	, sum(sil.ExtendedPrice) as sum_sale
	, min(si.InvoiceDate) as first_sale
	, sum(sil.Quantity) as kol_sale
from Sales.Invoices si
join sales.InvoiceLines sil 
	on si.InvoiceID = sil.InvoiceID
join Warehouse.StockItems wsi 
	on wsi.StockItemID = sil.StockItemID
group by year(si.InvoiceDate), month(si.InvoiceDate), wsi.StockItemName
having sum(sil.Quantity) < 50
order by y_sale, m_sale


