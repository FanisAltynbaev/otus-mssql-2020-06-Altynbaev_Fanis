use WideWorldImporters;

--создадим файловую группу
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [YearData]
GO

--добавляем файл БД
ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Years', FILENAME = N'C:\1\HW30\Yeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO

--создаем функцию партиционирования по годам - по умолчанию left!!
CREATE PARTITION FUNCTION [fnYearPartition](DATE) AS RANGE RIGHT FOR VALUES
('20120101','20130101','20140101','20150101','20160101', '20170101', '20180101', '20190101', '20200101', '20210101');																																																									
GO

-- партиционируем, используя созданную нами функцию
CREATE PARTITION SCHEME [schmYearPartition] AS PARTITION [fnYearPartition] 
ALL TO ([YearData])
GO

--создаем наши секционированные таблицы
CREATE TABLE [Sales].[OrdersYears](
	[OrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[SalespersonPersonID] [int] NOT NULL,
	[PickedByPersonID] [int] NULL,
	[ContactPersonID] [int] NOT NULL,
	[BackorderOrderID] [int] NULL,
	[OrderDate] [date] NOT NULL,
	[ExpectedDeliveryDate] [date] NOT NULL,
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsUndersupplyBackordered] [bit] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
) ON [schmYearPartition]([OrderDate])---в схеме [schmYearPartition] по ключу [OrderDate]
GO
--создадим кластерный индекс в той же схеме с тем же ключом
ALTER TABLE [Sales].[OrdersYears] ADD CONSTRAINT PK_Sales_OrdersYears 
PRIMARY KEY CLUSTERED  (OrderDate, OrderId)
 ON [schmYearPartition]([OrderDate]);


CREATE TABLE [Sales].[OrderLinesYears](
	[OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[OrderDate] [date] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[PickedQuantity] [int] NOT NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
) ON [schmYearPartition]([OrderDate])---в схеме [schmYearPartition] по ключу [OrderDate]
GO

--создадим кластерный индекс в той же схеме с тем же ключом
ALTER TABLE [Sales].[OrderLinesYears] ADD CONSTRAINT PK_Sales_OrderLinesYears 
PRIMARY KEY CLUSTERED  (OrderDate, OrderId, OrderLineId)
 ON [schmYearPartition]([OrderDate]);
 

-- переносим данные в новые таблицы
--SELECT count(1) from Sales.OrdersYears
--SELECT count(1) FROM Sales.Orders
insert INTO Sales.OrdersYears
SELECT * 
FROM Sales.Orders;

--SELECT count(1) from Sales.OrderLinesYears
--SELECT count(1) FROM Sales.OrderLines
insert INTO Sales.OrderLinesYears
SELECT ol.OrderLineID
	 , ol.OrderID
	 ,  o.OrderDate
	 , ol.StockItemID
	 , ol.Description
	 , ol.PackageTypeID
	 , ol.Quantity
	 , ol.UnitPrice
	 , ol.TaxRate
	 , ol.PickedQuantity
	 , ol.PickingCompletedWhen
	 , ol.LastEditedBy
	 , ol.LastEditedWhen
FROM Sales.OrderLines ol
join Sales.Orders o on o.OrderID = ol.OrderID;


use WideWorldImporters;
--смотрим какие таблицы у нас партиционированы
select distinct t.name
from sys.partitions p
inner join sys.tables t
	on p.object_id = t.object_id
where p.partition_number <> 1


--смотрим как конкретно по диапазонам уехали данные
SELECT $PARTITION.fnYearPartition(OrderDate) AS Partition,
       COUNT(*) AS [COUNT], MIN(OrderDate),MAX(OrderDate) 
FROM Sales.OrdersYears
GROUP BY $PARTITION.fnYearPartition(OrderDate) 
ORDER BY Partition ;  

SELECT $PARTITION.fnYearPartition(OrderDate) AS Partition,   
       COUNT(*) AS [COUNT], MIN(OrderDate),MAX(OrderDate) 
FROM Sales.OrderLinesYears
GROUP BY $PARTITION.fnYearPartition(OrderDate) 
ORDER BY Partition ;  

