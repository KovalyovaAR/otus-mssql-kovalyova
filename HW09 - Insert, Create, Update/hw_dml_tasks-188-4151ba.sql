/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".
*/


USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/


INSERT INTO [Sales].[Customers]
    ([CustomerID]
    ,[CustomerName]
    ,[BillToCustomerID]
    ,[CustomerCategoryID]
    ,[BuyingGroupID]
    ,[PrimaryContactPersonID]
    ,[AlternateContactPersonID]
    ,[DeliveryMethodID]
    ,[DeliveryCityID]
    ,[PostalCityID]
    ,[CreditLimit]
    ,[AccountOpenedDate]
    ,[StandardDiscountPercentage]
    ,[IsStatementSent]
    ,[IsOnCreditHold]
    ,[PaymentDays]
    ,[PhoneNumber]
    ,[FaxNumber]
    ,[DeliveryRun]
    ,[RunPosition]
    ,[WebsiteURL]
    ,[DeliveryAddressLine1]
    ,[DeliveryAddressLine2]
    ,[DeliveryPostalCode]
    ,[DeliveryLocation]
    ,[PostalAddressLine1]
    ,[PostalAddressLine2]
    ,[PostalPostalCode]
    ,[LastEditedBy])
VALUES
    (
		next value for sequences.CustomerID
		,'Test1'
		,1
		,3
		,1
		,1001
		,1002
		,3
		,19586
		,19586
		,null
		,cast(getdate() as date)
		,0
		,0
		,0
		,5
		,'(303)654-1230'
		,'(303)654-1230'
		,''
		,''
		,'http://www.test1.com'
		,'shop 32'
		,'1734 Stathom Road'
		,'34652'
		,null
		,'PO Box 2345'
		,'Frasjr'
		,'23768'
		,1
	),
	(
		next value for sequences.CustomerID
		,'Test2'
		,1
		,3
		,1
		,1001
		,1002
		,3
		,19586
		,19586
		,null
		,cast(getdate() as date)
		,0
		,0
		,0
		,5
		,'(303)654-1230'
		,'(303)654-1230'
		,''
		,''
		,'http://www.test2.com'
		,'shop 32'
		,'1734 Stathom Road'
		,'34652'
		,null
		,'PO Box 2345'
		,'Frasjr'
		,'23768'
		,1
	),
	(
		next value for sequences.CustomerID
		,'Test3'
		,1
		,3
		,1
		,1001
		,1002
		,3
		,19586
		,19586
		,null
		,cast(getdate() as date)
		,0
		,0
		,0
		,5
		,'(303)654-1230'
		,'(303)654-1230'
		,''
		,''
		,'http://www.test3.com'
		,'shop 32'
		,'1734 Stathom Road'
		,'34652'
		,null
		,'PO Box 2345'
		,'Frasjr'
		,'23768'
		,1
	),
	(
		next value for sequences.CustomerID
		,'Test4'
		,1
		,3
		,1
		,1001
		,1002
		,3
		,19586
		,19586
		,null
		,cast(getdate() as date)
		,0
		,0
		,0
		,5
		,'(303)654-1230'
		,'(303)654-1230'
		,''
		,''
		,'http://www.test4.com'
		,'shop 32'
		,'1734 Stathom Road'
		,'34652'
		,null
		,'PO Box 2345'
		,'Frasjr'
		,'23768'
		,1
	),
	(
		next value for sequences.CustomerID
		,'Test5'
		,1
		,3
		,1
		,1001
		,1002
		,3
		,19586
		,19586
		,null
		,cast(getdate() as date)
		,0
		,0
		,0
		,5
		,'(303)654-1230'
		,'(303)654-1230'
		,''
		,''
		,'http://www.test5.com'
		,'shop 32'
		,'1734 Stathom Road'
		,'34652'
		,null
		,'PO Box 2345'
		,'Frasjr'
		,'23768'
		,1
	)


/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

delete from sales.Customers where CustomerID = 1730


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update sales.Customers
set PhoneNumber = '(206) 555-0100'
where CustomerID = 1729

/*
4. Написать MERGE, который вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE sales.customers_copy AS Target
USING sales.Customers AS Source
    ON (Target.CustomerID = Source.CustomerID)
WHEN MATCHED 
    THEN UPDATE 
        SET Customername = Source.Customername
WHEN NOT MATCHED 
    THEN INSERT 
        VALUES (Source.CustomerID, 
				Source.Customername, 
				Source.[BillToCustomerID],
				Source.[CustomerCategoryID],
				Source.[BuyingGroupID],
				Source.[PrimaryContactPersonID],
				Source.[AlternateContactPersonID],
				Source.[DeliveryMethodID],
				Source.[DeliveryCityID],
				Source.[PostalCityID],
				Source.[CreditLimit],
				Source.[AccountOpenedDate],
				Source.[StandardDiscountPercentage],
				Source.[IsStatementSent],
				Source.[IsOnCreditHold],
				Source.[PaymentDays],
				Source.[PhoneNumber],
				Source.[FaxNumber],
				Source.[DeliveryRun],
				Source.[RunPosition],
				Source.[WebsiteURL],
				Source.[DeliveryAddressLine1],
				Source.[DeliveryAddressLine2],
				Source.[DeliveryPostalCode],
				Source.[DeliveryLocation],
				Source.[PostalAddressLine1],
				Source.[PostalAddressLine2],
				Source.[PostalPostalCode],
				Source.[LastEditedBy],
				Source.[ValidFrom],
				Source.[ValidTo]
				)
WHEN NOT MATCHED BY SOURCE
    THEN 
        DELETE

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

bcp WideWorldImporters.Warehouse.Colors out ".\otus\color.txt" -c -T

bcp WideWorldImporters.Warehouse.Colors_copy in ".\otus\color.txt" -c -T