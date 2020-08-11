use WideWorldImporters
go

--������� �������

--1. �������� ������ � ��������� �������� � ���������� ��� � ��������� ����������. �������� �����. 
--� �������� ������� � ��������� �������� � ��������� ���������� ����� ����� ���� ������ ��� ��������� ������:
--������� ������ ����� ������ ����������� ������ �� ������� � 2015 ���� (� ������ ������ ������ �� ����� ����������, 
--��������� ����� � ������� ������� �������)
--�������� id �������, �������� �������, ���� �������, ����� �������, ����� ����������� ������
--������ 
--���� ������� ����������� ���� �� ������
--2015-01-29 4801725.31
--2015-01-30 4801725.31
--2015-01-31 4801725.31
--2015-02-01 9626342.98
--2015-02-02 9626342.98
--2015-02-03 9626342.98
--������� ����� ����� �� ������� Invoices.
--����������� ���� ������ ���� ��� ������� �������.

-- ������� ����� WITH
;with CTE_Total As(
  select Year(i.InvoiceDate) as Y
       , Month(i.InvoiceDate) as M
       , sum(il.Quantity * il.UnitPrice) as TotalSumm
  from Sales.Invoices i
  join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
  where i.InvoiceDate >= '20150101'
  group by Year(i.InvoiceDate), Month(i.InvoiceDate)
)
,CTE_Invioce As(
 select i.InvoiceID
      , i.CustomerID
      , i.InvoiceDate
      , Year(i.InvoiceDate) as Y
      , Month(i.InvoiceDate) as M
	  , il.Quantity * il.UnitPrice as Summ
 from Sales.Invoices i
 join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
 where i.InvoiceDate >= '20150101'
)
select i.InvoiceID
     , c.CustomerName
     , i.InvoiceDate
	 , i.Summ
     --, t.TotalSumm
	 , (select sum(t.TotalSumm) from CTE_Total t where (t.Y <i.Y) or (t.Y =i.Y and t.M <=i.M ))
from CTE_Invioce i
--join CTE_Total t on t.Y = i.Y and t.M = i.M
join Sales.Customers c on c.CustomerID = i.CustomerID
order by i.InvoiceDate, i.InvoiceID
-- ����� ���������� 2:27

-- ������� � �������������� ��������� �������
-- ����� �� = 359 ��, ����������� ����� = 8507 ��.
drop table  #My_Total
create table #My_Total(
   n         int, 
   Y         int,
   M         int,
   TotalSumm numeric(18,2)
)
insert into #My_Total (Y, M, n)
select --distinct
       Year(i.InvoiceDate) as Y
     , Month(i.InvoiceDate) as M
	 , DENSE_RANK() OVER (ORDER BY Year(i.InvoiceDate), Month(i.InvoiceDate))
from Sales.Invoices i
where i.InvoiceDate >= '20150101'
group by Year(i.InvoiceDate)
       , Month(i.InvoiceDate)

declare @i int
      , @sum numeric(18,2)
select @i = min(t.n) from #My_Total t
while @i >0
begin
 select @sum = 0
 select @sum = sum(il.Quantity * il.UnitPrice)
 from #My_Total T
 join Sales.Invoices i on (i.InvoiceDate >= '20150101') 
                          and ((Year(i.InvoiceDate) < T.Y)
                            or (Year(i.InvoiceDate) = T.Y and Month(i.InvoiceDate) <= T.M)
							  )
 join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
 where T.n = @i

 update #My_Total
 set TotalSumm = @sum
 where #My_Total.n = @i 

 select @i = min(t.n) from #My_Total t where t.n > @i
end

select i.InvoiceID
     , c.CustomerName
     , i.InvoiceDate
	 , il.Quantity * il.UnitPrice
     , T.TotalSumm
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
join Sales.Customers c on c.CustomerID = i.CustomerID
join #My_Total T on (T.Y = Year(i.InvoiceDate) and T.M = Month(i.InvoiceDate))
order by i.InvoiceDate, i.InvoiceID


-- ������� � �������������� ��������� ����������
declare @My_Total table (
   n         int, 
   Y         int,
   M         int,
   TotalSumm numeric(18,2)
)
insert into @My_Total (Y, M, n)
select --distinct
       Year(i.InvoiceDate) as Y
     , Month(i.InvoiceDate) as M
	 , DENSE_RANK() OVER (ORDER BY Year(i.InvoiceDate), Month(i.InvoiceDate))
from Sales.Invoices i
where i.InvoiceDate >= '20150101'
group by Year(i.InvoiceDate)
       , Month(i.InvoiceDate)

select @i = min(t.n) from @My_Total t
while @i >0
begin
 select @sum = 0
 select @sum = sum(il.Quantity * il.UnitPrice)
 from @My_Total T
 join Sales.Invoices i on (i.InvoiceDate >= '20150101') 
                          and ((Year(i.InvoiceDate) < T.Y)
                            or (Year(i.InvoiceDate) = T.Y and Month(i.InvoiceDate) <= T.M)
							  )
 join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
 where T.n = @i

 update @My_Total
 set TotalSumm = @sum
 where n = @i 

 select @i = min(t.n) from @My_Total t where t.n > @i
end

select i.InvoiceID
     , c.CustomerName
     , i.InvoiceDate
	 , il.Quantity * il.UnitPrice
     , T.TotalSumm
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
join Sales.Customers c on c.CustomerID = i.CustomerID
join @My_Total T on (T.Y = Year(i.InvoiceDate) and T.M = Month(i.InvoiceDate))
order by i.InvoiceDate, i.InvoiceID




--2. ���� �� ����� ������������ ���� ������, �� �������� ������ ����� ����������� ������ � ������� ������� �������.
--�������� 2 �������� ������� - ����� windows function � ��� ���. �������� ����� ������� �����������, 
--�������� �� set statistics time on;

-- ������� � �������������� ������� �������
select i.InvoiceID
     , c.CustomerName
     , i.InvoiceDate
	 , il.Quantity * il.UnitPrice
	 , sum(il.Quantity * il.UnitPrice) OVER (ORDER BY Year(i.InvoiceDate), Month(i.InvoiceDate))
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
join Sales.Customers c on c.CustomerID = i.CustomerID
where i.InvoiceDate >= '20150101'

-- ������� � �������������� ������� �������:   ����� �� = 375 ��, ����������� ����� = 9510 ��.
-- ������� � �������������� ��������� �������: ����� �� = 359 ��, ����������� ����� = 8507 ��.



--3. ������� ������ 2� ����� ���������� ��������� (�� ���-�� ���������) � ������ ������ �� 2016� ���
--(�� 2 ����� ���������� �������� � ������ ������)
with aaa as
(select Year(i.InvoiceDate) as Y
      , Month(i.InvoiceDate) as M
      , il.Description as Description
	 , sum(il.Quantity) as Qty
  from Sales.Invoices i
  join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
  where i.InvoiceDate >= '20160101' and i.InvoiceDate < '20170101' 
  group by Year(i.InvoiceDate)
         , Month(i.InvoiceDate)
		 , il.Description
)select * 
from (
select aaa.Y
     , aaa.M
	 , aaa.Description
	 , aaa.Qty 
     , RANK() OVER (PARTITION BY
	                         Y
                           , M
	                ORDER BY Y
                           , M 
		                   , Qty desc
		           ) as top2
from aaa
) bbb 
where bbb.top2<=2
order by bbb.Y
       , bbb.M 
	   , bbb.Qty desc
       , bbb.Description



--4. ������� ����� ��������
--���������� �� ������� �������, � ����� ����� ������ ������� �� ������, ��������, ����� � ����
--������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
--���������� ����� ���������� ������� � �������� ����� � ���� �� �������
--���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
--���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� ����� 
--���������� �� ������ � ��� �� �������� ����������� (�� �����)
--�������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
--����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
--��� ���� ������ �� ����� ������ ������ ��� ������������� �������

select top 1000
StockItemID,
StockItemName,
Brand,
UnitPrice,

--������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
RANK() OVER (PARTITION BY substring(StockItemName, 1, 1) ORDER BY StockItemName),

--���������� ����� ���������� ������� � �������� ����� � ���� �� �������
count(*) OVER (),

--���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
count(*) OVER (PARTITION BY substring(StockItemName, 1, 1) ORDER BY substring(StockItemName, 1, 1) ),

--���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� ����� 
LEAD(StockItemID, 1, NULL) OVER (PARTITION BY substring(StockItemName, 1, 1) ORDER BY StockItemName),

--���������� �� ������ � ��� �� �������� ����������� (�� �����)
LAG(StockItemID, 1, NULL) OVER (PARTITION BY substring(StockItemName, 1, 1) ORDER BY StockItemName),

--�������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
LAG(StockItemName, 2, 'No items') OVER (PARTITION BY substring(StockItemName, 1, 1) ORDER BY StockItemName),

--����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
TypicalWeightPerUnit,
NTILE(30) OVER (ORDER BY TypicalWeightPerUnit)

from [Warehouse].[StockItems] s
order by StockItemName



--5. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������
--� ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������
select * from
(select
p.PersonID, p.FullName, 
c.CustomerID, c.CustomerName,
o.OrderDate,
(select sum(ol.Quantity*ol.UnitPrice) from Sales.OrderLines ol where ol.OrderID = o.OrderID) as sum,
RANK() over (partition by p.PersonID order by p.PersonID, o.OrderDate desc, c.CustomerID) as top1
from [Sales].[Orders] o
join [Application].[People] p on p.PersonID = o.SalespersonPersonID
join [Sales].[Customers] c on c.CustomerID = o.CustomerID
) aaa
where aaa.top1 = 1

--6. �������� �� ������� ������� 2 ����� ������� ������, ������� �� �������
--� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������
select 
CustomerID, 
CustomerName,
StockItemID,
StockItemName,
MaxPrice,
max(OrderDate)
from
(select
c.CustomerID, c.CustomerName,
o.OrderDate,
s.StockItemID,
s.StockItemName,
s.UnitPrice as MaxPrice,
DENSE_RANK() over (partition by c.CustomerID order by c.CustomerID, s.UnitPrice desc) as top2
from [Sales].[Orders] o
join Sales.OrderLines ol on ol.OrderID = o.OrderID
join [Warehouse].[StockItems] s on s.StockItemID = ol.StockItemID
join [Sales].[Customers] c on c.CustomerID = o.CustomerID
) aaa
where aaa.top2 <= 2
group by 
CustomerID, 
CustomerName,
StockItemID,
StockItemName,
MaxPrice
order by 
CustomerID, MaxPrice desc


--Bonus �� ���������� ����
--�������� ������, ������� �������� 10 ��������, ������� ������� ������ 30 ������� � ��������� ����� ��� �� ������� ������ 2016. 
select
c.CustomerID, c.CustomerName,
count(*)
from [Sales].[Orders] o
join [Sales].[Customers] c on c.CustomerID = o.CustomerID
where exists (select 1 from [Sales].[Orders] o1 where o1.CustomerID = o.CustomerID and o1.OrderDate >= '20160401')
group by c.CustomerID, c.CustomerName
having count(*) >= 30
