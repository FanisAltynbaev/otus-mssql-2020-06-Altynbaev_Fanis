--Группировки и агрегатные функции

--Опционально:
--Написать запросы 1-3 так, чтобы если в каком-то месяце не было продаж, то этот месяц также отображался бы в результатах, но там были нули.

--1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
--Вывести:
--* Год продажи 
--* Месяц продажи
--* Средняя цена за месяц по всем товарам
--* Общая сумма продаж
--Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
select 
  Year(i.InvoiceDate)
, Month(i.InvoiceDate)
, AVG(il.UnitPrice) as AVGPrice
, sum(il.Quantity * il.UnitPrice) as TotalSumm
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
group by Year(i.InvoiceDate), Month(i.InvoiceDate)
order by Year(i.InvoiceDate) desc, Month(i.InvoiceDate) desc

-- опциональное решение
;with MinDate(Value) As 
(select DATEFROMPARTS(year(min(InvoiceDate)),month(min(InvoiceDate)), 1) 
  from Sales.Invoices
)
,MaxDate(Value) As 
(select DateAdd(m,1,DATEFROMPARTS(year(max(InvoiceDate)),month(max(InvoiceDate)), 1)) 
   from Sales.Invoices
)
, AllMonth(Date, Month, Year) As
(select MinDate.Value
      , month(MinDate.Value)
	  , year(MinDate.Value)
  from MinDate
union all
 select       DateAdd(m,1,AllMonth.Date)
      , month(DateAdd(m,1,AllMonth.Date))
	  , year (DateAdd(m,1,AllMonth.Date))
  from AllMonth, MaxDate
  where /*AllMonth.Date < MaxDate.Value--*/DateAdd(m,1,AllMonth.Date) < MaxDate.Value
)
,MyInvoice (Year, Month, AVG, SUM) As
(select 
  Year(i.InvoiceDate)
, Month(i.InvoiceDate)
, AVG(il.UnitPrice) as AVGPrice
, sum(il.Quantity * il.UnitPrice) as TotalSumm
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
group by Year(i.InvoiceDate), Month(i.InvoiceDate)
)
select 
  am.Year
, am.Month
, isnull(i.AVG,0) as AVGPrice
, isnull(i.sum,0) as TotalSumm
from AllMonth am
left join MyInvoice i on i.Year = am.Year and i.Month = am.Month
order by am.Year desc, am.Month desc


--2. Отобразить все месяцы, где общая сумма продаж превысила 10 000 
--Вывести:
--* Год продажи 
--* Месяц продажи
--* Общая сумма продаж
--Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
/****************/
-- !!! позволил себе изменить порог вхождения до 4 млн
select 
  Year(i.InvoiceDate)
, Month(i.InvoiceDate)
, sum(il.Quantity * il.UnitPrice) as TotalSumm
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
group by Year(i.InvoiceDate), Month(i.InvoiceDate)
having sum(il.Quantity * il.UnitPrice)  > 4000000--10000
order by 1,2

-- опциональное решение
;with MinDate(Value) As 
(select DATEFROMPARTS(year(min(InvoiceDate)),month(min(InvoiceDate)), 1) 
  from Sales.Invoices
)
,MaxDate(Value) As 
(select DateAdd(m,1,DATEFROMPARTS(year(max(InvoiceDate)),month(max(InvoiceDate)), 1)) 
   from Sales.Invoices
)
, AllMonth(Date, Month, Year) As
(select MinDate.Value
      , month(MinDate.Value)
	  , year(MinDate.Value)
  from MinDate
union all
 select       DateAdd(m,1,AllMonth.Date)
      , month(DateAdd(m,1,AllMonth.Date))
	  , year (DateAdd(m,1,AllMonth.Date))
  from AllMonth, MaxDate
  where /*AllMonth.Date < MaxDate.Value--*/DateAdd(m,1,AllMonth.Date) < MaxDate.Value
)
,MyInvoice (Year, Month, TotalSumm) As
(select 
  Year(i.InvoiceDate)
, Month(i.InvoiceDate)
, sum(il.Quantity * il.UnitPrice)
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
group by Year(i.InvoiceDate), Month(i.InvoiceDate)
having sum(il.Quantity * il.UnitPrice)  > 4000000--10000
)
select 
  am.Year
, am.Month
, isnull(i.TotalSumm,0)
from AllMonth am
left join MyInvoice i on i.Year = am.Year and i.Month = am.Month
order by 1,2

--3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, 
--по товарам, продажи которых менее 50 ед в месяц. 
--Группировка должна быть по году, месяцу, товару.
--Вывести:
--* Год продажи 
--* Месяц продажи
--* Наименование товара
--* Сумма продаж
--* Дата первой продажи
--* Количество проданного
--Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
select 
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
order by 1,2,3


-- опциональное решение
;with MinDate(Value) As 
(select DATEFROMPARTS(year(min(InvoiceDate)),month(min(InvoiceDate)), 1) 
  from Sales.Invoices
)
,MaxDate(Value) As 
(select DateAdd(m,1,DATEFROMPARTS(year(max(InvoiceDate)),month(max(InvoiceDate)), 1)) 
   from Sales.Invoices
)
, AllMonth(Date, Month, Year) As
(select MinDate.Value
      , month(MinDate.Value)
	  , year(MinDate.Value)
  from MinDate
union all
 select       DateAdd(m,1,AllMonth.Date)
      , month(DateAdd(m,1,AllMonth.Date))
	  , year (DateAdd(m,1,AllMonth.Date))
  from AllMonth, MaxDate
  where /*AllMonth.Date < MaxDate.Value--*/DateAdd(m,1,AllMonth.Date) < MaxDate.Value
)
,MyInvoice As
(select 
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
)
select 
  am.Year
, am.Month
, isnull(i.Description,'')
, isnull(TotalSumm, 0)
, isnull(min_InvoiceDate, '')
, isnull(Quantity, 0)
from AllMonth am
left join MyInvoice i on i.Year = am.Year and i.Month = am.Month
order by 1,2,3



--4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
--Дано :
DROP TABLE dbo.MyEmployees
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

--временная таблица
drop table #MyEmployees
CREATE TABLE #MyEmployees 
( Level      smallint     NOT NULL, 
  Sort       nvarchar(100),
  EmployeeID smallint     NOT NULL, 
  ManagerID  smallint     NOT NULL, 
  Name       nvarchar(80) NOT NULL, 
  Title      nvarchar(50) NOT NULL 
); 

;with Tr
( Level,
  Sort,
  EmployeeID,
  ManagerID ,
  Name      ,
  Title     
)as
(select 1,
        cast(EmployeeID as varchar(max)) as Sort,
        EmployeeID                 as EmployeeID,
        0                          as ManagerID,
        FirstName + ' ' + LastName as Name,
	    Title                      as Title
   from dbo.MyEmployees
  where ManagerID is null

  union all

 select tr.Level+1,
        Tr.Sort+' ' + cast(e.EmployeeID as varchar(max)),
        e.EmployeeID,  
	    e.ManagerID,	
        e.FirstName + ' ' + e.LastName,
	    e.Title                     
   from dbo.MyEmployees e
   join Tr on Tr.EmployeeID = e.ManagerID
)
insert into #MyEmployees (Level, Sort, EmployeeID, ManagerID, Name, Title)
select *
from Tr
order by Sort

select EmployeeID,	Name,	Title, Level
from #MyEmployees
order by Sort


-- табличная переменная
DECLARE @MyEmployees table(
  Level      smallint     NOT NULL, 
  Sort       nvarchar(100),
  EmployeeID smallint     NOT NULL, 
  ManagerID  smallint     NOT NULL,
  Name       nvarchar(80) NOT NULL, 
  Title      nvarchar(50) NOT NULL
); 

;with Tr
( Level,
  Sort,
  EmployeeID,
  ManagerID ,
  Name      ,
  Title     
)as
(select 1,
        cast(EmployeeID as varchar(max)) as Sort,
        EmployeeID                 as EmployeeID,
        0                          as ManagerID,
        FirstName + ' ' + LastName as Name,
	    Title                      as Title
   from dbo.MyEmployees
  where ManagerID is null

  union all

 select tr.Level+1,
        Tr.Sort+' ' + cast(e.EmployeeID as varchar(max)),
        e.EmployeeID,  
	    e.ManagerID,	
        e.FirstName + ' ' + e.LastName,
	    e.Title                     
   from dbo.MyEmployees e
   join Tr on Tr.EmployeeID = e.ManagerID
)
insert into @MyEmployees (Level, Sort, EmployeeID, ManagerID, Name, Title)
select *
from Tr

select EmployeeID,	Name,	Title, Level
from @MyEmployees order by Sort
