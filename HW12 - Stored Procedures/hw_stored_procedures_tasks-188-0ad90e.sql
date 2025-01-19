/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

CREATE FUNCTION dbo.fGetCustomerToMaxOrder()
RETURNS int
AS
BEGIN
    DECLARE @Res DECIMAL(18, 2);
    SELECT @Res = 
    (select top 1 i.CustomerID
	from sales.Invoices i 
	join sales.InvoiceLines il on i.InvoiceID = il.InvoiceID
	group by i.CustomerID
	order by sum(il.Quantity*il.UnitPrice) desc )

    RETURN @Res;
END;

select dbo.fGetCustomerToMaxOrder()

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE PROCEDURE dbo.GetOrderForCustomer(@CustomerId int)
AS
    SET NOCOUNT ON;

select sum(il.Quantity*il.UnitPrice)
from sales.Customers c
left join sales.Invoices i  on i.CustomerID = c.CustomerID
left join sales.InvoiceLines il on i.InvoiceID = il.InvoiceID
where i.CustomerID = @CustomerId
group by i.CustomerID

exec dbo.GetOrderForCustomer @customerid = 149

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

-- была создана функция на основе 2 задания 

/*
CREATE FUNCTION dbo.fGetOrderForCustomer
(
    @CustomerId int
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @Result decimal(18,2);
    SELECT @Result = 
    (select sum(il.Quantity*il.UnitPrice)
	from sales.Customers c
	left join sales.Invoices i  on i.CustomerID = c.CustomerID
	left join sales.InvoiceLines il on i.InvoiceID = il.InvoiceID
	where i.CustomerID = @CustomerId
	group by i.CustomerID);

    RETURN @Result;
END;
*/

особо сильной разницы в производительности замечено не была, судя по плану запроса стоимость запросов одинаковая. 
основное отличие, в целом, хранимой процедуры и функции в том, что хранимая процедура может не вернуть результат и внутри себя выполнять действия инсерта (например). 
в свою очередь функция может выполнять только селект и обязательно должна вернуть результат

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

CREATE FUNCTION dbo.ftGetOrderToCustomer(@CustomerId int)
RETURNS TABLE
AS
RETURN
(
    select i.CustomerID, c.CustomerName, sum(il.Quantity*il.UnitPrice) as SumOrder
	from sales.Customers c
	left join sales.Invoices i  on i.CustomerID = c.CustomerID
	left join sales.InvoiceLines il on i.InvoiceID = il.InvoiceID
	where i.CustomerID = @CustomerId
	group by i.CustomerID, c.CustomerName
)

select a.*
from sales.Customers c 
outer apply (select CustomerId, CustomerName, SumOrder from dbo.ftGetOrderToCustomer(c.customerid)) a

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
