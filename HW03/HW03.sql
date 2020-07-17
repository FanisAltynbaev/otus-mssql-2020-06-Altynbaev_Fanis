/*
Подзапросы и CTE
Для всех заданий, где возможно, сделайте два варианта запросов:
1) через вложенный запрос
2) через WITH (для производных таблиц)
*/

--1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
--и не сделали ни одной продажи 04 июля 2015 года. Вывести ИД сотрудника и его полное имя. 
--Продажи смотреть в таблице Sales.Invoices.
select p.PersonID, p.FullName, s.SalespersonPersonID
  from Application.People p
  left join (select s_.SalespersonPersonID 
               from Sales.Invoices s_ 
              where s_.InvoiceDate = '20150704'
            ) s 
    on s.SalespersonPersonID = p.PersonID
 where p.IsSalesPerson = 1 
   and s.SalespersonPersonID is null

;with Invoices (SalespersonPersonID) as
(select SalespersonPersonID
   from Sales.Invoices s_ 
  where s_.InvoiceDate = '20150704'
)
select p.PersonID, p.FullName, s.SalespersonPersonID
  from Application.People p
  left join Invoices s
      on s.SalespersonPersonID = p.PersonID
 where p.IsSalesPerson = 1 
   and s.SalespersonPersonID is null

--2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
--Вывести: ИД товара, наименование товара, цена.

select [StockItemID], [StockItemName], [UnitPrice]
from [Warehouse].[StockItems] si
where si.UnitPrice <= (select min(si_.UnitPrice) 
                         from [Warehouse].[StockItems] si_
                      )

select [StockItemID], [StockItemName], [UnitPrice]
from [Warehouse].[StockItems] si
where si.UnitPrice <= All (select si_.UnitPrice 
                             from [Warehouse].[StockItems] si_
                          )

--3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей из Sales.CustomerTransactions. 
--Представьте несколько способов (в том числе с CTE). 

select top 5 s_c.CustomerName, s_c.PhoneNumber
from Sales.CustomerTransactions s_ct
join Sales.Customers s_c on s_c.CustomerID = s_ct.CustomerID 
order by s_ct.TransactionAmount  desc
       , s_c.CustomerName
       , s_c.PhoneNumber


select s_c.CustomerName, s_c.PhoneNumber
from Sales.Customers s_c 
where s_c.CustomerID in (select top 5 s_ct.CustomerID--,  s_ct.CustomerTransactionID, s_ct.TransactionAmount
                           from Sales.CustomerTransactions s_ct
						   order by s_ct.TransactionAmount  desc
						)


;with TR (CustomerID) as
(select top 5 s_ct.CustomerID--,  s_ct.CustomerTransactionID, s_ct.TransactionAmount
   from Sales.CustomerTransactions s_ct
  order by s_ct.TransactionAmount  desc
)
select distinct s_c.CustomerName, s_c.PhoneNumber
from Sales.Customers s_c 
join TR on TR.CustomerID = s_c.CustomerID


--4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, 
--а также имя сотрудника, который осуществлял упаковку заказов (PackedByPersonID).
select top 3 city.CityID, city.CityName, s_i.PackedByPersonID, p.FullName
from Sales.CustomerTransactions s_ct
join Sales.Invoices s_i on s_i.InvoiceID = s_ct.InvoiceID
join Sales.Customers s_c on s_c.CustomerID = s_ct.CustomerID
join Application.People p on p.PersonID = s_i.PackedByPersonID
join Application.Cities city on city.CityID = s_c.DeliveryCityID
order by s_ct.TransactionAmount  desc

;with TR (CustomerID, InvoiceID) as
(select top 3 s_ct.CustomerID, s_ct.InvoiceID--,  s_ct.CustomerTransactionID, s_ct.TransactionAmount
   from Sales.CustomerTransactions s_ct
  order by s_ct.TransactionAmount  desc
)
select city.CityID, city.CityName, s_i.PackedByPersonID, p.FullName
from TR
join Sales.Invoices s_i on s_i.InvoiceID = tr.InvoiceID
join Sales.Customers s_c on s_c.CustomerID = tr.CustomerID
join Application.People p on p.PersonID = s_i.PackedByPersonID
join Application.Cities city on city.CityID = s_c.DeliveryCityID


--5. Объясните, что делает и оптимизируйте запрос:
--Можно двигаться как в сторону улучшения читабельности запроса, так и в сторону упрощения плана\ускорения.
--Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
--Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
--Напишите ваши рассуждения по поводу оптимизации. 
/*
SELECT 
Invoices.InvoiceID, 
Invoices.InvoiceDate,
(SELECT People.FullName
FROM Application.People
WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice, 
(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM Sales.OrderLines
WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
FROM Sales.Orders
WHERE Orders.PickingCompletedWhen IS NOT NULL 
AND Orders.OrderId = Invoices.OrderId) 
) AS TotalSummForPickedItems
FROM Sales.Invoices 
JOIN
(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC
*/

SET STATISTICS IO, TIME ON
SELECT 
    Invoices.InvoiceID, 
    Invoices.InvoiceDate,
    (SELECT People.FullName
       FROM Application.People
      WHERE People.PersonID = Invoices.SalespersonPersonID
    ) AS SalesPersonName,
    SalesTotals.TotalSumm AS TotalSummByInvoice, 
    (SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
       FROM Sales.OrderLines
      WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
                                    FROM Sales.Orders
                                   WHERE Orders.PickingCompletedWhen IS NOT NULL 
                                     AND Orders.OrderId = Invoices.OrderId
							      ) 
    ) AS TotalSummForPickedItems
 FROM Sales.Invoices 
 JOIN (SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
         FROM Sales.InvoiceLines
        GROUP BY InvoiceId
       HAVING SUM(Quantity*UnitPrice) > 27000
	   ) AS SalesTotals
   ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- запрос отбирает счета-фактуры с общей стоимостью более 27000 и выводит по ним
-- ID счета-фактуты, дату, имя продавцв, общую суммe в счете-фактуре и общую сумму в собранных позиций	

-- удалось оптимизировать только удобочитаемость. производительность судя по планам запросов осталась без изменения

;with  SalesTotals (InvoiceId, TotalSumm) as
(SELECT InvoiceId, SUM(Quantity*UnitPrice)
  FROM Sales.InvoiceLines
 GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000
),
 PickedItems (OrderId, TotalSumm) as
(SELECT OrderLines.OrderId, SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
	  FROM Sales.Orders
	  join Sales.OrderLines
	    on OrderLines.OrderId = Orders.OrderId
     WHERE Orders.PickingCompletedWhen IS NOT NULL
	 group by OrderLines.OrderId 
)
SELECT 
    Invoices.InvoiceID, 
    Invoices.InvoiceDate,
    p.FullName AS SalesPersonName,
    SalesTotals.TotalSumm AS TotalSummByInvoice, 
    PickedItems.TotalSumm AS TotalSummForPickedItems
 FROM Sales.Invoices 
 JOIN SalesTotals 
   ON Invoices.InvoiceID = SalesTotals.InvoiceID
 join PickedItems
   on PickedItems.OrderId = Invoices.OrderId
 join Application.People p
   on P.PersonID = Invoices.SalespersonPersonID
ORDER BY TotalSummByInvoice DESC