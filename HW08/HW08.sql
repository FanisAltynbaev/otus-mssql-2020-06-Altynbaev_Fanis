use WideWorldImporters
go

--Оконные функции

--1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы. 
--В качестве запроса с временной таблицей и табличной переменной можно взять свой запрос или следующий запрос:
--Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет одинаковый, 
--нарастать будет в течение времени выборки)
--Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом
--Пример 
--Дата продажи Нарастающий итог по месяцу
--2015-01-29 4801725.31
--2015-01-30 4801725.31
--2015-01-31 4801725.31
--2015-02-01 9626342.98
--2015-02-02 9626342.98
--2015-02-03 9626342.98
--Продажи можно взять из таблицы Invoices.
--Нарастающий итог должен быть без оконной функции.

-- решение через WITH
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
-- время выполнения 2:27

-- решение с использованием временной таблицы
-- Время ЦП = 359 мс, затраченное время = 8507 мс.
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


-- решение с использованием табличной переменной
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




--2. Если вы брали предложенный выше запрос, то сделайте расчет суммы нарастающим итогом с помощью оконной функции.
--Сравните 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, 
--сравнить по set statistics time on;

-- решение с использованием оконной функции
select i.InvoiceID
     , c.CustomerName
     , i.InvoiceDate
	 , il.Quantity * il.UnitPrice
	 , sum(il.Quantity * il.UnitPrice) OVER (ORDER BY Year(i.InvoiceDate), Month(i.InvoiceDate))
from Sales.Invoices i
join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
join Sales.Customers c on c.CustomerID = i.CustomerID
where i.InvoiceDate >= '20150101'

-- решение с использованием оконной функции:   Время ЦП = 375 мс, затраченное время = 9510 мс.
-- решение с использованием временной таблицы: Время ЦП = 359 мс, затраченное время = 8507 мс.



--3. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год
--(по 2 самых популярных продукта в каждом месяце)
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



--4. Функции одним запросом
--Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
--пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
--посчитайте общее количество товаров и выведете полем в этом же запросе
--посчитайте общее количество товаров в зависимости от первой буквы названия товара
--отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
--предыдущий ид товара с тем же порядком отображения (по имени)
--названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
--сформируйте 30 групп товаров по полю вес товара на 1 шт
--Для этой задачи НЕ нужно писать аналог без аналитических функций

select top 1000
StockItemID,
StockItemName,
Brand,
UnitPrice,

--пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
RANK() OVER (PARTITION BY substring(StockItemName, 1, 1) ORDER BY StockItemName),

--посчитайте общее количество товаров и выведете полем в этом же запросе
count(*) OVER (),

--посчитайте общее количество товаров в зависимости от первой буквы названия товара
count(*) OVER (PARTITION BY substring(StockItemName, 1, 1) ORDER BY substring(StockItemName, 1, 1) ),

--отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
LEAD(StockItemID, 1, NULL) OVER (PARTITION BY substring(StockItemName, 1, 1) ORDER BY StockItemName),

--предыдущий ид товара с тем же порядком отображения (по имени)
LAG(StockItemID, 1, NULL) OVER (PARTITION BY substring(StockItemName, 1, 1) ORDER BY StockItemName),

--названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
LAG(StockItemName, 2, 'No items') OVER (PARTITION BY substring(StockItemName, 1, 1) ORDER BY StockItemName),

--сформируйте 30 групп товаров по полю вес товара на 1 шт
TypicalWeightPerUnit,
NTILE(30) OVER (ORDER BY TypicalWeightPerUnit)

from [Warehouse].[StockItems] s
order by StockItemName



--5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
--В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
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

--6. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
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


--Bonus из предыдущей темы
--Напишите запрос, который выбирает 10 клиентов, которые сделали больше 30 заказов и последний заказ был не позднее апреля 2016. 
select
c.CustomerID, c.CustomerName,
count(*)
from [Sales].[Orders] o
join [Sales].[Customers] c on c.CustomerID = o.CustomerID
where exists (select 1 from [Sales].[Orders] o1 where o1.CustomerID = o.CustomerID and o1.OrderDate >= '20160401')
group by c.CustomerID, c.CustomerName
having count(*) >= 30
