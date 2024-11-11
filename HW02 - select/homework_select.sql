/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select st.StockItemID, st.StockItemName
from Warehouse.StockItems st 
where st.StockItemName like '%urgent%'
	or st.StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select ps.SupplierID, ps.SupplierName
from Purchasing.Suppliers ps
left join Purchasing.PurchaseOrders ppo
	on ps.SupplierID = ppo.SupplierID 
where ppo.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select 
	so.OrderID, 
	format(so.OrderDate, 'dd.MM.yyyy') as date_order,
	DATENAME(month, so.OrderDate) as m_order,
	datepart(QUARTER, so.OrderDate) as kv_order,
	case 
		when datepart(MONTH, so.OrderDate) in (1,2,3,4) then '1'
		when datepart(MONTH, so.OrderDate) in (5,6,7,8) then '2'
		when datepart(MONTH, so.OrderDate) in (9,10,11,12) then '3'
	end as tr_order,
	sc.CustomerName
from Sales.Orders so
join Sales.OrderLines sol
	on so.OrderID = sol.OrderID
join Sales.Customers sc 
	on sc.CustomerID = so.CustomerID
where sol.PickingCompletedWhen is not null
	and (sol.UnitPrice > 100 or sol.Quantity > 20)
order by 4, 5, 2


-- постраничная выборка
select 
	so.OrderID, 
	format(so.OrderDate, 'dd.MM.yyyy') as date_order,
	DATENAME(month, so.OrderDate) as m_order,
	datepart(QUARTER, so.OrderDate) as kv_order,
	case 
		when datepart(MONTH, so.OrderDate) in (1,2,3,4) then '1'
		when datepart(MONTH, so.OrderDate) in (5,6,7,8) then '2'
		when datepart(MONTH, so.OrderDate) in (9,10,11,12) then '3'
	end as tr_order,
	sc.CustomerName
from Sales.Orders so
join Sales.OrderLines sol
	on so.OrderID = sol.OrderID
join Sales.Customers sc 
	on sc.CustomerID = so.CustomerID
where sol.PickingCompletedWhen is not null
	and (sol.UnitPrice > 100 or sol.Quantity > 20)
order by 4, 5, 2
offset 1000 rows     
    fetch next 100 rows only

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select adv.DeliveryMethodName, 
	pop.ExpectedDeliveryDate,
	ps.SupplierName,
	ap.FullName
from Purchasing.Suppliers ps
join Purchasing.PurchaseOrders pop 
	on ps.SupplierID = pop.SupplierID
join Application.DeliveryMethods adv 
	on adv.DeliveryMethodID = pop.DeliveryMethodID
join Application.People ap
	on ap.PersonID = pop.ContactPersonID
where pop.IsOrderFinalized = 1
	and adv.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight')
	and pop.ExpectedDeliveryDate between '2013-01-01' and '2013-01-31'

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10 sc.CustomerName, ap.FullName, so.*
from Sales.Orders so
join Sales.Customers sc on sc.CustomerID = so.CustomerID
join Application.People ap on ap.PersonID = so.SalespersonPersonID
order by so.OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select ap.PersonID, ap.FullName, ap.PhoneNumber
from Application.People ap
join Purchasing.PurchaseOrders pop
	on ap.PersonID = pop.ContactPersonID
join Purchasing.PurchaseOrderLines pos
	on pos.PurchaseOrderID = pop.PurchaseOrderID
join Warehouse.StockItems wsi
	on wsi.StockItemID = pos.StockItemID
where wsi.StockItemName like '%Chocolate frogs 250g%'
