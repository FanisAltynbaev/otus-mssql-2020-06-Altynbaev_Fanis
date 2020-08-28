--XML, JSON и динамический SQL 

--1. Загрузить данные из файла StockItems.xml в таблицу Warehouse.StockItems.
--Существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 
--Файл StockItems.xml в личном кабинете.

/* Вариант с импортом из файла */
DROP TABLE IF EXISTS #T
CREATE TABLE #T (IntCol int, XmlCol xml);  
GO 

INSERT INTO #T(XmlCol)  
SELECT * FROM OPENROWSET(  
   BULK 'c:\1\StockItems.xml',  
   SINGLE_BLOB) AS x;

--select * from #T

DECLARE @docHandle int;  
DECLARE @xmlDocument xml
SELECT top 1 
  @xmlDocument = XmlCol 
from #T
--select @xmlDocument
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;  
-- Use OPENXML to provide rowset consisting of StockItems data.  
WITH MyXML as (SELECT *   
FROM OPENXML(@docHandle, N'/StockItems/Item')   
  WITH (
    [StockItemName] nvarchar(max) '@Name',
    [SupplierID] int 'SupplierID',
    [UnitPackageID] int 'Package/UnitPackageID',
    [OuterPackageID] int 'Package/OuterPackageID',
    [QuantityPerOuter] int 'Package/QuantityPerOuter',
    [TypicalWeightPerUnit] decimal(18,2) 'Package/TypicalWeightPerUnit',
    [LeadTimeDays] int 'LeadTimeDays',
    [IsChillerStock] int 'IsChillerStock',
    [TaxRate] decimal(18,2) 'TaxRate',
    [UnitPrice] decimal(18,2) 'UnitPrice'
  )
)
MERGE INTO [Warehouse].[StockItems] SI
USING MyXML on (MyXML.StockItemName = SI.StockItemName)
WHEN MATCHED          
  THEN UPDATE
    SET
	SupplierID           = MyXML.SupplierID,
    UnitPackageID        = MyXML.UnitPackageID,
    OuterPackageID       = MyXML.OuterPackageID,
    QuantityPerOuter     = MyXML.QuantityPerOuter,
    TypicalWeightPerUnit = MyXML.TypicalWeightPerUnit,
    LeadTimeDays         = MyXML.LeadTimeDays,
    IsChillerStock       = MyXML.IsChillerStock,
    TaxRate              = MyXML.TaxRate,
    UnitPrice            = MyXML.UnitPrice
WHEN NOT MATCHED        
  THEN INSERT (
    StockItemName        ,
    SupplierID           ,
    UnitPackageID        ,
    OuterPackageID       ,
    QuantityPerOuter     ,
    TypicalWeightPerUnit ,
    LeadTimeDays         ,
    IsChillerStock       ,
    TaxRate              ,
    UnitPrice            ,
	LastEditedBy
	)  
  VALUES (
     MyXML.StockItemName       ,
     MyXML.SupplierID          ,
     MyXML.UnitPackageID       ,
     MyXML.OuterPackageID      ,
     MyXML.QuantityPerOuter    ,
     MyXML.TypicalWeightPerUnit,
     MyXML.LeadTimeDays        ,
     MyXML.IsChillerStock      ,
     MyXML.TaxRate             ,
     MyXML.UnitPrice           ,
	 1
    );

-- Remove the internal representation of the XML document.  
EXEC sp_xml_removedocument @docHandle;



--2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
select top 10 --* 
StockItemName as [@Name], 
SupplierID as [SupplierID],
UnitPackageID as [Package/UnitPackageID],
OuterPackageID as [Package/OuterPackageID],
QuantityPerOuter as [Package/QuantityPerOuter],
TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],
LeadTimeDays as [LeadTimeDays],
IsChillerStock as [IsChillerStock],
TaxRate as [TaxRate],
UnitPrice as [UnitPrice]
from [Warehouse].[StockItems]
FOR XML PATH('Item'), ROOT('StockItems')



/* Вариант с импортом из файла */
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

--SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp  "select top 10  StockItemName as [@Name],  SupplierID as [SupplierID], UnitPackageID as [Package/UnitPackageID], OuterPackageID as [Package/OuterPackageID], QuantityPerOuter as [Package/QuantityPerOuter], TypicalWeightPerUnit as [Package/TypicalWeightPerUnit], LeadTimeDays as [LeadTimeDays], IsChillerStock as [IsChillerStock], TaxRate as [TaxRate],UnitPrice as [UnitPrice]from [Warehouse].[StockItems]FOR XML PATH" queryout "C:\1\OutputFile.xml" -T -w -t"@eu&$1&" -S DESKTOP-5G2NUF4\OTUS'


--Примечания к заданиям 1, 2:
--* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
--* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
--* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).



--3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
--Написать SELECT для вывода:
--- StockItemID
--- StockItemName
--- CountryOfManufacture (из CustomFields)
--- FirstTag (из поля CustomFields, первое значение из массива Tags)
select
  StockItemID, 
  StockItemName,
  JSON_VALUE(s.CustomFields, '$.CountryOfManufacture')  AS CountryOfManufacture, 
  JSON_VALUE(s.CustomFields, '$.Tags[0]')  AS FirstTag
from Warehouse.StockItems s
WHERE ISJSON(CustomFields) > 0


--4. Найти в StockItems строки, где есть тэг "Vintage".
--Вывести: 
--- StockItemID
--- StockItemName
--- (опционально) все теги (из CustomFields) через запятую в одном поле

/* Записей с тегом Vintage найдено не было.*/
/* Зменил в запрсе на "MinimumAge"         */
;with MyCTE as (
  select
    StockItemID, 
    StockItemName,
    JSON_QUERY(s.CustomFields, '$')  AS CustomFields,
	(SELECT value FROM OPENJSON(JSON_QUERY(s.CustomFields, '$')) WHERE [key] = 'MinimumAge')  as MinimumAge
  from
    Warehouse.StockItems s
  WHERE ISJSON(s.CustomFields) > 0
)
select s.*
from  Warehouse.StockItems s
join MyCTE on MyCTE.StockItemID = s.StockItemID
where MyCTE.MinimumAge is not null

/* опциональное решение */
;with MyCTE as (
  select
    StockItemID, 
    StockItemName,
    JSON_QUERY(s.CustomFields, '$')  AS CustomFields,
	(SELECT [Value] FROM OPENJSON(JSON_QUERY(s.CustomFields, '$')) WHERE [key] = 'MinimumAge') as MinimumAge,
	(SELECT [key]+', ' FROM OPENJSON(JSON_QUERY(s.CustomFields, '$'))FOR XML PATH('')) as AllTags,
	(SELECT STRING_AGG ([key], ', ') FROM OPENJSON(JSON_QUERY(s.CustomFields), '$')) as AllTags2
  from
    Warehouse.StockItems s
  WHERE ISJSON(s.CustomFields) > 0
)
select MyCTE.MinimumAge, MyCTE.AllTags, MyCTE.AllTags2, s.*
from  Warehouse.StockItems s
join MyCTE on MyCTE.StockItemID = s.StockItemID
where MyCTE.MinimumAge is not null


--5. Пишем динамический PIVOT. 
--По заданию из занятия "Операторы CROSS APPLY, PIVOT, CUBE".
--Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
--Название клиента
--МесяцГод Количество покупок

--Нужно написать запрос, который будет генерировать результаты для всех клиентов.
--Имя клиента указывать полностью из CustomerName.
--Дата должна иметь формат dd.mm.yyyy например 01.12.2019 

declare @PivotString nvarchar(max)

with MyCTE (Date) as (
    select distinct  convert(varchar, DATEFROMPARTS( Year(o.OrderDate), MONTH(o.OrderDate), 1), 104)
    from Sales.Orders o
    --group by DATEFROMPARTS( Year(o.OrderDate),	MONTH(o.OrderDate),	1)
    --order by Date
)
select 
  @PivotString = '[' + STRING_AGG( Date, '], [') + ']'
from MyCTE

select @PivotString

/*
;with MyCTE (Date) as (
    select  DATEFROMPARTS( Year(o.OrderDate), MONTH(o.OrderDate), 1)
    from Sales.Orders o
    group by DATEFROMPARTS( Year(o.OrderDate),	MONTH(o.OrderDate),	1)
    --order by Date
)
select 
  @PivotString = STRING_AGG( Date, ', ') 
from MyCTE
*/
/*
 with PivotDate as(
   select
     c.CustomerName as CustomerName,
     convert(varchar, DATEFROMPARTS( Year(o.OrderDate), MONTH(o.OrderDate), 1), 104) as OrderDate,
     count(*) as nnn
   from Sales.Customers c
   join Sales.Orders o on o.CustomerID = c.CustomerID
   group by CustomerName, OrderDate
 )
 select * from PivotDate
 PIVOT (SUM(nnn)
 FOR OrderDate IN ( [01.12.2014], [01.01.2014], [01.04.2015], [01.01.2015], [01.04.2014], [01.06.2014], [01.02.2013], [01.08.2014], [01.07.2013], [01.07.2015], [01.09.2015], [01.11.2015], [01.11.2014], [01.10.2013], [01.04.2016], [01.01.2013], [01.07.2014], [01.08.2013], [01.05.2015], [01.06.2015], [01.02.2016], [01.08.2015], [01.03.2016], [01.11.2013], [01.12.2013], [01.05.2016], [01.03.2015], [01.10.2015], [01.03.2014], [01.02.2015], [01.04.2013], [01.10.2014], [01.12.2015], [01.05.2014], [01.03.2013], [01.01.2016], [01.05.2013], [01.09.2013], [01.06.2013], [01.02.2014], [01.09.2014]  )
 ) as PPP
 order by CustomerName
 */

EXEC (
 ' with PivotDate as('
+'   select'
+'     c.CustomerName as CustomerName,'
+'     convert(varchar, DATEFROMPARTS( Year(o.OrderDate), MONTH(o.OrderDate), 1), 104) as OrderDate,'
+'     count(*) as nnn'
+'   from Sales.Customers c'
+'   join Sales.Orders o on o.CustomerID = c.CustomerID'
+'   group by CustomerName, OrderDate'
+' )'
+' select * from PivotDate'
+' PIVOT (SUM(nnn)'
+' FOR OrderDate IN ( ' + @PivotString + ')'
+' ) as PPP'
+' order by CustomerName'
)

