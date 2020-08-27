--Pivot � Cross Apply
--1. ��������� �������� ������, ������� � ���������� ������ ���������� ��������� ������� ���������� ����:
--�������� �������
--�������� ���������� �������

--�������� ����� � ID 2-6, ��� ��� ������������� Tailspin Toys
--��� ������� ����� �������� ��� ����� �������� ������ ��������� 
--�������� �������� Tailspin Toys (Gasport, NY) - �� �������� � ����� ������ Gasport,NY
--���� ������ ����� ������ dd.mm.yyyy �������� 25.12.2019

--��������, ��� ������ ��������� ����������:
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

--2. ��� ���� �������� � ������, � ������� ���� Tailspin Toys
--������� ��� ������, ������� ���� � �������, � ����� �������

--������ �����������
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

--3. � ������� ����� ���� ���� � ����� ������ �������� � ���������
--�������� ������� �� ������, ��������, ��� - ����� � ���� ��� ���� �������� ���� ��������� ���
--������ ������

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

--4. ���������� �� �� ������� ������� ����� CROSS APPLY 
--�������� �� ������� ������� 2 ����� ������� ������, ������� �� �������
--� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������
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
-- ������� ��� ��� ������� �������
-- �� � ������������ ����� ��� �� ������ �������� ������� �� ��������� � ������� ��������. 
-- � ������ CROSS APPLY, ���� � ������������ ����� �������� ��������� �������, �� �� ������� ������ ��� �� ��� (��������� �� ���� �������)
-- � ������ � ������� ������� ��� ������������ ���� � ���������� ��� ������ � ����� ������




--5. Code review (�����������). ������ �������� � ��������� Hometask_code_review.sql. 
--��� ������ ������? 
--��� ����� �������� CROSS APPLY - ����� �� ������������ ������ ��������� �������\�������?
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
���������� ���������� (FolderId, T.FileVersionId, T.FileId) �� ���������� �����, ���� �� ��� ��� ���������� ������ ���� �� ��������� ������� #FileVersions 
� ������������ RowNum = 1 � ��� ���� �� �� ���������������� (��� ������ � vwFileHistoryRestore)

�� �����������
1. CROSS APPLY � ����������� ������� ����� ��������� �� JOIN. �� � ������ ������, �� ��� ������, TOP 1 ������ ������ ����� �� ���� ��������.
������������ - ������� ������� � ��������� �� PARTITION BY FileVersionId, FileId, FolderId, DirId � � ������������ �������� �� 1
2. ������� 'AND EXISTS (SELECT 1 FROM #FileVersions V WHERE V.DirVersionId <= FHR.DirVersionId)' ��� ������� ��������� �� ��� ��� � ��� ������������ � CROSS
3. � NOT EXISTS ��� �� ����������� ��������� ��� �������
		    'FROM dbo.vwFileHistoryRemove DFHR
			WHERE DFHR.FileId = T.FileId
				AND DFHR.[FolderId] = T.FolderId
				AND DFHR.DirVersionId = FHR.DirVersionId'
