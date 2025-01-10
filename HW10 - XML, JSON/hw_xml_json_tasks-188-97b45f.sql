/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

-- OPENXML
declare @xmlDocument XML

select @xmlDocument = BulkColumn 
from openrowset
(BULK 'C:\Users\KovalyovaAR\Desktop\OTUS\StockItems-188-1fb5df.xml',
single_clob)
as data;

--select @xmlDocument as [@xmldocument]

declare @docHandle int;
exec sp_xml_preparedocument @docHandle output, @xmlDocument

--select @docHandle

drop table if exists #StockItems 

CREATE TABLE #StockItems 
(
StockItemName nvarchar(100),
SupplierID int,
UnitPackageID int,
OuterPackageID int,
QuantityPerOuter int,
TypicalWeightPerUnit decimal(18, 3),
LeadTimeDays int,
IsChillerStock bit,
TaxRate decimal(18, 3),
UnitPrice decimal(18, 2)
)

insert into #StockItems
select * 
from openxml(@dochandle, N'/StockItems/Item')
WITH (
		StockItemName nvarchar(100) '@Name',
		SupplierID int 'SupplierID',
		UnitPackageID int 'Package/UnitPackageID',
		OuterPackageID int 'Package/OuterPackageID',
		QuantityPerOuter int 'Package/QuantityPerOuter',
		TypicalWeightPerUnit decimal(18,3) 'Package/TypicalWeightPerUnit',
		LeadTimeDays int 'LeadTimeDays',
		IsChillerStock bit 'IsChillerStock',
		TaxRate decimal(18,3) 'TaxRate',
		UnitPrice decimal (18,2) 'UnitPrice'
	)

EXEC sp_xml_removedocument @dochandle;

select * from #StockItems


MERGE Warehouse.StockItems AS Target
USING #StockItems AS Source
    ON (Target.StockItemName = Source.StockItemName)
WHEN MATCHED 
    THEN UPDATE 
        SET SupplierID = Source.SupplierID, 
			UnitPackageID = Source.UnitPackageID,
			OuterPackageID = Source.OuterPackageID,
			QuantityPerOuter = Source.QuantityPerOuter,
			TypicalWeightPerUnit = Source.TypicalWeightPerUnit,
			LeadTimeDays = Source.LeadTimeDays,
			IsChillerStock = Source.IsChillerStock,
			TaxRate = Source.TaxRate,
			UnitPrice = Source.UnitPrice
WHEN NOT MATCHED 
    THEN INSERT 
        VALUES (next value for sequences.StockItemID, 
				Source.StockItemName, 
				Source.UnitPackageID,
				Source.OuterPackageID,
				Source.QuantityPerOuter,
				Source.TypicalWeightPerUnit,
				Source.LeadTimeDays,
				Source.IsChillerStock,
				Source.TaxRate,
				Source.UnitPrice
				)
WHEN NOT MATCHED BY SOURCE
    THEN 
        DELETE
OUTPUT deleted.*, $action, inserted.*;



-- XQuery
declare @x XML

select @x = BulkColumn 
from openrowset
(BULK 'C:\Users\KovalyovaAR\Desktop\OTUS\StockItems-188-1fb5df.xml',
single_clob)
as data;

drop table if exists #StockItems 

CREATE TABLE #StockItems 
(
StockItemName nvarchar(100),
SupplierID int,
UnitPackageID int,
OuterPackageID int,
QuantityPerOuter int,
TypicalWeightPerUnit decimal(18, 3),
LeadTimeDays int,
IsChillerStock bit,
TaxRate decimal(18, 3),
UnitPrice decimal(18, 2)
)

insert into #StockItems
select 
	t.StockItems.value('@Name[1]', 'nvarchar(100)') as StockItemName
	, t.StockItems.value('(SupplierID)[1]', 'int') as SupplierID
	, t.StockItems.value('(Package/UnitPackageID)[1]', 'int') as UnitPackageID
	, t.StockItems.value('(Package/OuterPackageID)[1]', 'int') as OuterPackageID
	, t.StockItems.value('(Package/QuantityPerOuter)[1]', 'int') as QuantityPerOuter
	, t.StockItems.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18, 3)') as TypicalWeightPerUnit
	, t.StockItems.value('(LeadTimeDays)[1]', 'int') as LeadTimeDays
	, t.StockItems.value('(IsChillerStock)[1]', 'bit') as IsChillerStock
	, t.StockItems.value('(TaxRate)[1]', 'decimal(18, 3)') as TaxRate
	, t.StockItems.value('(UnitPrice)[1]', 'decimal(18, 2)') as UnitPrice
FROM @x.nodes('/StockItems/Item') as t(StockItems)


select * from #StockItems

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/


-- использовалась временная таблица, созданная в рамках задания 1

SELECT 
    StockItemName AS [@Name],
	SupplierID as [SupplierID],
    UnitPackageID AS [Package/UnitPackageID],
	OuterPackageID AS [Package/OuterPackageID],
	QuantityPerOuter AS [Package/QuantityPerOuter],
	TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit],
    LeadTimeDays as [LeadTimeDays],
    IsChillerStock AS [IsChillerStock],
	TaxRate as [TaxRate],
	UnitPrice as [UnitPrice]
FROM #StockItems
FOR XML PATH('Item'), ROOT('StockItems');


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select ws.StockItemID
	, ws.StockItemName
	, JSON_VALUE(ws.CustomFields, '$.CountryOfManufacture') as country
	, JSON_VALUE(ws.CustomFields, '$.Tags[0]')
from warehouse.StockItems ws

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

select ws.StockItemID
	, ws.StockItemName
	, string_agg(b.[value], ', ')
from warehouse.StockItems ws 
cross apply (select * 
			from openjson(JSON_QUERY(ws.CustomFields, '$.Tags'))) a
cross apply (select * 
			from openjson(JSON_QUERY(ws.CustomFields, '$.Tags'))) b
where a.[value] = 'Vintage'
group by ws.StockItemID
	, ws.StockItemName
