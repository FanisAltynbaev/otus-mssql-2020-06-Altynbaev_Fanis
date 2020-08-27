--Pivot и Cross Apply
--1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
--Название клиента
--МесяцГод Количество покупок

--Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
--имя клиента нужно поменять так чтобы осталось только уточнение 
--например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY
--дата должна иметь формат dd.mm.yyyy например 25.12.2019

--Например, как должны выглядеть результаты:
--InvoiceMonth Peeples Valley, AZ Medicine Lodge, KS Gasport, NY Sylvanite, MT Jessie, ND
--01.01.2013 3 1 4 2 2
--01.02.2013 7 3 4 2 1
with PivotDate as(
select
SUBSTRING(
  SUBSTRING(c.CustomerName, CHARINDEX('(', c.CustomerName)+1,9999),
  1, 
  CHARINDEX(')', SUBSTRING(c.CustomerName, CHARINDEX('(', c.CustomerName)+1,9999))-1
  ) as CustomerName
, Year(o.OrderDate) as Y
, MONTH(o.OrderDate) as M
, count(*) as nnn
from Sales.Customers c
join Sales.Orders o on o.CustomerID = c.CustomerID
where c.CustomerID between 2 and 6
group by CustomerName, Year(o.OrderDate), MONTH(o.OrderDate) 
)
select * from PivotDate
PIVOT (SUM(nnn)
FOR CustomerName IN ( [Gasport, NY]
                     ,[Jessie, ND]
					 ,[Medicine Lodge, KS]
	       			 ,[Peeples Valley, AZ]
					 ,[Sylvanite, MT]
                    )

) as PPP
order by Y, M

--2. Для всех клиентов с именем, в котором есть Tailspin Toys
--вывести все адреса, которые есть в таблице, в одной колонке

--Пример результатов
--CustomerName AddressLine
--Tailspin Toys (Head Office) Shop 38
--Tailspin Toys (Head Office) 1877 Mittal Road
--Tailspin Toys (Head Office) PO Box 8975
--Tailspin Toys (Head Office) Ribeiroville
--.....
select CustomerName, ClAddress--, AddressType
from
( select
  CustomerName,
  PostalAddressLine2,
  PostalAddressLine1,
  DeliveryAddressLine2,
  DeliveryAddressLine1
  from Sales.Customers c
  where c.CustomerName like 'Tailspin Toys%'
) as PivotData
UNPIVOT (ClAddress FOR AddressType IN( [DeliveryAddressLine1],
                                       [DeliveryAddressLine2],
                                       [PostalAddressLine1],
                                       [PostalAddressLine2]
                                      )
	  ) as UnPivotData

--3. В таблице стран есть поля с кодом страны цифровым и буквенным
--сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
--Пример выдачи

--CountryId CountryName Code
--1 Afghanistan AFG
--1 Afghanistan 4
--3 Albania ALB
--3 Albania 8
select CountryID, CountryName, CountryCode from
(select 
  CountryID
, CountryName
, cast(IsoAlpha3Code as varchar) as IsoAlpha3Code
, Cast(IsoNumericCode as varchar) as IsoNumericCode
from[Application].[Countries]
) as PivotData
UNPIVOT (CountryCode FOR CountryCodeType in (IsoAlpha3Code, IsoNumericCode)
)as UpPivotData

--4. Перепишите ДЗ из оконных функций через CROSS APPLY 
--Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
select-- top 10
    c.CustomerID,  c.CustomerName,
    s.StockItemID, s.StockItemName,
    s.UnitPrice,
    s.OrderDate
from [Sales].[Customers] c 
CROSS APPLY (
    select top 2
	    max(o.OrderDate) as OrderDate,
        s_.StockItemID as StockItemID,
        s_.StockItemName as StockItemName,
        s_.UnitPrice as UnitPrice 
    from [Sales].[Orders] o
    join [Sales].[OrderLines] ol on ol.OrderID = o.OrderID
    join [Warehouse].[StockItems] s_ on s_.StockItemID = ol.StockItemID
	where
	    c.CustomerID = o.CustomerID
    group by 
        s_.StockItemID,
        s_.StockItemName,
        s_.UnitPrice
	order by s_.UnitPrice desc
) s
-- понимаю что это учебное задание
-- но в практическом плане это не совсем красивое решение по сравнению с оконной функцией. 
-- в случае CROSS APPLY, если с максимальной ценой окажется несколько товаром, то мы выберем только два из них (последних по дате продажи)
-- с случае с оконкмм брались две максимальные цены и выбирались все товары с этими ценами




--5. Code review (опционально). Запрос приложен в материалы Hometask_code_review.sql. 
--Что делает запрос? 
--Чем можно заменить CROSS APPLY - можно ли использовать другую стратегию выборки\запроса?
/*
SELECT T.FolderId,
		   T.FileVersionId,
		   T.FileId		
	FROM dbo.vwFolderHistoryRemove FHR
	CROSS APPLY (SELECT TOP 1 FileVersionId, FileId, FolderId, DirId
			FROM #FileVersions V
			WHERE RowNum = 1
				AND DirVersionId <= FHR.DirVersionId
			ORDER BY V.DirVersionId DESC) T 
	WHERE FHR.[FolderId] = T.FolderId
	AND FHR.DirId = T.DirId
	AND EXISTS (SELECT 1 FROM #FileVersions V WHERE V.DirVersionId <= FHR.DirVersionId)
	AND NOT EXISTS (
			SELECT 1
			FROM dbo.vwFileHistoryRemove DFHR
			WHERE DFHR.FileId = T.FileId
				AND DFHR.[FolderId] = T.FolderId
				AND DFHR.DirVersionId = FHR.DirVersionId
				AND NOT EXISTS (
					SELECT 1
					FROM dbo.vwFileHistoryRestore DFHRes
					WHERE DFHRes.[FolderId] = T.FolderId
						AND DFHRes.FileId = T.FileId
						AND DFHRes.PreviousFileVersionId = DFHR.FileVersionId
					)
			)
*/
выбирается информация (FolderId, T.FileVersionId, T.FileId) по удаленному файлу, если он или его предыдущая версия есть во временной таблице #FileVersions 
с ограниченеим RowNum = 1 и при этом он не восстанволивался (нет данных в vwFileHistoryRestore)

по оптимизации
1. CROSS APPLY в большинстве случаев можно замениять на JOIN. но в данном случае, на мой взгляд, TOP 1 стразу ставит кретс на этом варианте.
Альтернатива - оконная функция с нумераций по PARTITION BY FileVersionId, FileId, FolderId, DirId и в последукющим фильтром на 1
2. условие 'AND EXISTS (SELECT 1 FROM #FileVersions V WHERE V.DirVersionId <= FHR.DirVersionId)' мне кажется дублирует то что уже и так проыверяется в CROSS
3. В NOT EXISTS так же дублируется имеющаяся уже выборка
		    'FROM dbo.vwFileHistoryRemove DFHR
			WHERE DFHR.FileId = T.FileId
				AND DFHR.[FolderId] = T.FolderId
				AND DFHR.DirVersionId = FHR.DirVersionId'
