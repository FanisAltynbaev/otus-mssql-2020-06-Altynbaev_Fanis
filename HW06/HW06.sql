--����������� � ���������� �������
--1. ��������� ������� ���� ������, ����� ����� ������� �� �������
--�������:
--* ��� ������� 
--* ����� �������
--* ������� ���� �� ����� �� ���� �������
--* ����� ����� ������
--������� �������� � ������� Sales.Invoices � ��������� ��������.
select 
  Year(i.InvoiceDate)
, Month(i.InvoiceDate)
, AVG(il.UnitPrice) as AVGPrice
, sum(il.Quantity * il.UnitPrice) as TotalSumm
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
group by Year(i.InvoiceDate), Month(i.InvoiceDate)
order by Year(i.InvoiceDate) desc, Month(i.InvoiceDate) desc


--2. ���������� ��� ������, ��� ����� ����� ������ ��������� 10 000 
--�������:
--* ��� ������� 
--* ����� �������
--* ����� ����� ������
--������� �������� � ������� Sales.Invoices � ��������� ��������.
select 
  Year(i.InvoiceDate)
, Month(i.InvoiceDate)
, sum(il.Quantity * il.UnitPrice) as TotalSumm
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
group by Year(i.InvoiceDate), Month(i.InvoiceDate)
having sum(il.Quantity * il.UnitPrice)  > 10000


--3. ������� ����� ������, ���� ������ ������� � ���������� ���������� �� �������, 
--�� �������, ������� ������� ����� 50 �� � �����. 
--����������� ������ ���� �� ����, ������, ������.
--�������:
--* ��� ������� 
--* ����� �������
--* ������������ ������
--* ����� ������
--* ���� ������ �������
--* ���������� ����������
--������� �������� � ������� Sales.Invoices � ��������� ��������.
select --top 10 
  Year(i.InvoiceDate) as Year
, Month(i.InvoiceDate) as Month
, il.Description as Description
, sum(il.Quantity * il.UnitPrice) as TotalSumm
, min(i.InvoiceDate) as min_InvoiceDate
, sum(il.Quantity) as Quantity
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
group by Year(i.InvoiceDate), Month(i.InvoiceDate), il.Description
having sum(il.Quantity) < 50


--4. �������� ����������� CTE sql ������ � ��������� �� ��������� ������� � ��������� ����������
--���� :
CREATE TABLE dbo.MyEmployees 
( 
EmployeeID smallint NOT NULL, 
FirstName nvarchar(30) NOT NULL, 
LastName nvarchar(40) NOT NULL, 
Title nvarchar(50) NOT NULL, 
DeptID smallint NOT NULL, 
ManagerID int NULL, 
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC) 
); 

INSERT INTO dbo.MyEmployees VALUES 
(1, N'Ken', N'Sanchez', N'Chief Executive Officer',16,NULL) 
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1) 
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273) 
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274) 
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274) 
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273) 
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285) 
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273) 
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16); 

select * from dbo.MyEmployees

--��������� �������
drop table #MyEmployees
CREATE TABLE #MyEmployees 
( EmployeeID smallint     NOT NULL, 
  Name       nvarchar(80) NOT NULL, 
  Title      nvarchar(50) NOT NULL, 
  Level      smallint     NOT NULL 
); 

with Tr
( EmployeeID,
  Name      ,
  Title     ,
  Level     
)as
(select EmployeeID                 as EmployeeID
      , FirstName + ' ' + LastName as Name
	  , Title                      as Title
	  , 1                          as Level
   from dbo.MyEmployees
  where ManagerID is null

  union all

 select e.EmployeeID                
      , e.FirstName + ' ' + e.LastName
	  , e.Title                     
	  , tr.Level + 1 
   from dbo.MyEmployees e
   join Tr on Tr.EmployeeID = e.ManagerID
)
insert into #MyEmployees (EmployeeID, Name, Title, Level)
select *
from Tr

select * from #MyEmployees


-- ��������� ����������
DECLARE @MyEmployees table(
  EmployeeID smallint     NOT NULL, 
  Name       nvarchar(80) NOT NULL, 
  Title      nvarchar(50) NOT NULL, 
  Level      smallint     NOT NULL 
); 

with Tr
( EmployeeID,
  Name      ,
  Title     ,
  Level     
)as
(select EmployeeID                 as EmployeeID
      , FirstName + ' ' + LastName as Name
	  , Title                      as Title
	  , 1                          as Level
   from dbo.MyEmployees
  where ManagerID is null

  union all

 select e.EmployeeID                
      , e.FirstName + ' ' + e.LastName
	  , e.Title                     
	  , tr.Level + 1 
   from dbo.MyEmployees e
   join Tr on Tr.EmployeeID = e.ManagerID
)
insert into @MyEmployees (EmployeeID, Name, Title, Level)
select *
from Tr

select * from @MyEmployees


--�����������:
--�������� ������� 1-3 ���, ����� ���� � �����-�� ������ �� ���� ������, 
--�� ���� ����� ����� ����������� �� � �����������, �� ��� ���� ����.