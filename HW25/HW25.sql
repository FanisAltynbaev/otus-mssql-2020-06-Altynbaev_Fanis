--Оптимизируйте запрос по БД WorldWideImporters.
--Приложите текст запроса со статистиками по времени и операциям ввода вывода, опишите кратко ход рассуждений при оптимизации.
use WideWorldImporters
go

set statistics io, time on 
go


-- запрос до оптимизации
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans
ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
AND (Select SupplierId
FROM Warehouse.StockItems AS It
Where It.StockItemID = det.StockItemID) = 12
AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
FROM Sales.OrderLines AS Total
Join Sales.Orders AS ordTotal
On ordTotal.OrderID = Total.OrderID
WHERE ordTotal.CustomerID = Inv.CustomerID)> 250000
AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
/*
(3619 rows affected)
Таблица "StockItemTransactions". Число просмотров 1, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 66, lob физических чтений 1, lob упреждающих чтений 130.
Таблица "StockItemTransactions". Считано сегментов 1, пропущено 0.
Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 518, lob физических чтений 5, lob упреждающих чтений 795.
Таблица "OrderLines". Считано сегментов 2, пропущено 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "CustomerTransactions". Число просмотров 5, логических чтений 261, физических чтений 4, упреждающих чтений 253, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Orders". Число просмотров 2, логических чтений 883, физических чтений 4, упреждающих чтений 870, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Invoices". Число просмотров 1, логических чтений 72913, физических чтений 2, упреждающих чтений 11118, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 1, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 1906 мс, затраченное время = 56743 мс.
*/


-- избавляемся от AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
-- это тупо рвенство
Select ord.CustomerID
     , det.StockItemID
	 , SUM(det.UnitPrice)
	 , SUM(det.Quantity)
	 , COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
  ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
  ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
  ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans
  ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
  AND (Select SupplierId
       FROM Warehouse.StockItems AS It
       Where It.StockItemID = det.StockItemID
	   ) = 12
  AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
       FROM Sales.OrderLines AS Total
       Join Sales.Orders AS ordTotal
         On ordTotal.OrderID = Total.OrderID
       WHERE ordTotal.CustomerID = Inv.CustomerID
	   )> 250000
  AND Inv.InvoiceDate = ord.OrderDate
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
/*
(3619 rows affected)
Таблица "StockItemTransactions". Число просмотров 1, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 66, lob физических чтений 1, lob упреждающих чтений 130.
Таблица "StockItemTransactions". Считано сегментов 1, пропущено 0.
Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 518, lob физических чтений 5, lob упреждающих чтений 795.
Таблица "OrderLines". Считано сегментов 2, пропущено 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "CustomerTransactions". Число просмотров 5, логических чтений 261, физических чтений 4, упреждающих чтений 253, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Orders". Число просмотров 1, логических чтений 34292, физических чтений 73, упреждающих чтений 282, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Invoices". Число просмотров 1, логических чтений 71220, физических чтений 25, упреждающих чтений 11117, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 1, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 1594 мс, затраченное время = 2806 мс.
*/

--выносим 
--AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
--     FROM Sales.OrderLines AS Total
--     Join Sales.Orders AS ordTotal
--       On ordTotal.OrderID = Total.OrderID
--     WHERE ordTotal.CustomerID = Inv.CustomerID
--   )> 250000
--в CTE и начинаем плясать от  Sales.Invoices
;with CTE_ORD (CustomerID, summ)
as
(SELECT o.CustomerID, SUM(ol.UnitPrice*ol.Quantity)
   FROM Sales.Orders AS o
   join Sales.OrderLines AS ol
     on ol.OrderID = o.OrderID
   group by o.CustomerID
   having SUM(ol.UnitPrice*ol.Quantity) > 250000
)
Select ord.CustomerID
     , det.StockItemID
	 , SUM(det.UnitPrice)
	 , SUM(det.Quantity)
	 , COUNT(ord.OrderID)
FROM CTE_ORD
JOIN Sales.Invoices AS Inv
  ON Inv.CustomerID = CTE_ORD.CustomerID
JOIN Sales.OrderLines AS det
  ON det.OrderID = Inv.OrderID
JOIN Sales.Orders AS ord
  on ord.OrderID = det.OrderID
JOIN Sales.CustomerTransactions AS Trans
  ON Trans.InvoiceID = inv.CustomerID
JOIN Warehouse.StockItemTransactions AS ItemTrans
  ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
  AND (Select SupplierId
       FROM Warehouse.StockItems AS It
       Where It.StockItemID = det.StockItemID
	   ) = 12
  AND Inv.InvoiceDate = ord.OrderDate
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
/*
(3619 rows affected)
Таблица "StockItemTransactions". Число просмотров 1, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 29, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItemTransactions". Считано сегментов 1, пропущено 0.
Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 331, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "OrderLines". Считано сегментов 2, пропущено 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 35, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "CustomerTransactions". Число просмотров 5, логических чтений 261, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Invoices". Число просмотров 14458, логических чтений 75136, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Orders". Число просмотров 2, логических чтений 883, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 1063 мс, затраченное время = 1467 мс.
*/



--странно что сразу не заметил 
--AND (Select SupplierId
--   FROM Warehouse.StockItems AS It
--   Where It.StockItemID = det.StockItemID
--   ) = 12
--можно заменить на JOIN
;with CTE_ORD (CustomerID, summ)
as
(SELECT o.CustomerID, SUM(ol.UnitPrice*ol.Quantity)
   FROM Sales.Orders AS o
   join Sales.OrderLines AS ol
     on ol.OrderID = o.OrderID
   group by o.CustomerID
   having SUM(ol.UnitPrice*ol.Quantity) > 250000
)
Select ord.CustomerID
     , det.StockItemID
	 , SUM(det.UnitPrice)
	 , SUM(det.Quantity)
	 , COUNT(ord.OrderID)
FROM CTE_ORD
JOIN Sales.Invoices AS Inv
  ON Inv.CustomerID = CTE_ORD.CustomerID
JOIN Sales.OrderLines AS det
  ON det.OrderID = Inv.OrderID
JOIN Sales.Orders AS ord
  on ord.OrderID = det.OrderID
JOIN Sales.CustomerTransactions AS Trans
  ON Trans.InvoiceID = inv.CustomerID
JOIN Warehouse.StockItemTransactions AS ItemTrans
  ON ItemTrans.StockItemID = det.StockItemID
JOIN Warehouse.StockItems AS It
  ON It.StockItemID = det.StockItemID
 AND It.SupplierId = 12
WHERE Inv.BillToCustomerID != ord.CustomerID
  AND Inv.InvoiceDate = ord.OrderDate
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
/*
(3619 rows affected)
Таблица "StockItemTransactions". Число просмотров 1, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 29, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItemTransactions". Считано сегментов 1, пропущено 0.
Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 331, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "OrderLines". Считано сегментов 2, пропущено 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "CustomerTransactions". Число просмотров 5, логических чтений 261, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Invoices". Число просмотров 14458, логических чтений 75136, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Orders". Число просмотров 2, логических чтений 883, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 1094 мс, затраченное время = 1417 мс.
*/


-- пробуем использовать оконную функцию
-- результат удивил и оставил вопросы
-- реально стало быстрее работать, и по-видимому из-за уменьшения кол-ва просмотров Invoices
-- БЫЛО  - Таблица "Invoices". Число просмотров 14458, логических чтений 75136
-- СТАЛО - Таблица "Invoices". Число просмотров 1, логических чтений 11400,
-- ??? Как ??? В нашем CTE она не использовалась
-- по плану запросов пердыдущий был легче в 2 раза, а это сложнее а работает быстрее ?!?
;with CTE_ORD_ (CustomerID, summ)
as
(SELECT distinct o.CustomerID, SUM(ol.UnitPrice*ol.Quantity) OVER (PARTITION BY o.CustomerID) as summ
   FROM Sales.Orders AS o
   join Sales.OrderLines AS ol
     on ol.OrderID = o.OrderID
),
CTE_ORD (CustomerID, summ)
as
(SELECT CustomerID, summ
  from CTE_ORD_
 where CTE_ORD_.summ > 250000
)
Select ord.CustomerID
     , det.StockItemID
	 , SUM(det.UnitPrice)
	 , SUM(det.Quantity)
	 , COUNT(ord.OrderID)
FROM CTE_ORD
JOIN Sales.Invoices AS Inv
  ON Inv.CustomerID = CTE_ORD.CustomerID
JOIN Sales.OrderLines AS det
  ON det.OrderID = Inv.OrderID
JOIN Sales.Orders AS ord
  on ord.OrderID = det.OrderID
JOIN Sales.CustomerTransactions AS Trans
  ON Trans.InvoiceID = inv.CustomerID
JOIN Warehouse.StockItemTransactions AS ItemTrans
  ON ItemTrans.StockItemID = det.StockItemID
JOIN Warehouse.StockItems AS It
  ON It.StockItemID = det.StockItemID
 AND It.SupplierId = 12
WHERE Inv.BillToCustomerID != ord.CustomerID
  AND Inv.InvoiceDate = ord.OrderDate
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
/*
(3619 rows affected)
Таблица "StockItemTransactions". Число просмотров 1, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 29, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItemTransactions". Считано сегментов 1, пропущено 0.
Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 331, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "OrderLines". Считано сегментов 2, пропущено 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "CustomerTransactions". Число просмотров 5, логических чтений 261, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Invoices". Число просмотров 1, логических чтений 11400, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Orders". Число просмотров 2, логических чтений 883, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 594 мс, затраченное время = 844 мс.
*/


--последний шаг, судя по количеству чтений безсмысленный. разве что ради красоты кода
--перенос 
--WHERE Inv.BillToCustomerID != ord.CustomerID
--  AND Inv.InvoiceDate = ord.OrderDate
--в JOIN Sales.Orders AS ord
;with CTE_ORD_ (CustomerID, summ)
as
(SELECT distinct o.CustomerID, SUM(ol.UnitPrice*ol.Quantity) OVER (PARTITION BY o.CustomerID) as summ
   FROM Sales.Orders AS o
   join Sales.OrderLines AS ol
     on ol.OrderID = o.OrderID
),
CTE_ORD (CustomerID, summ)
as
(SELECT CustomerID, summ
  from CTE_ORD_
 where CTE_ORD_.summ > 250000
)
Select ord.CustomerID
     , det.StockItemID
	 , SUM(det.UnitPrice)
	 , SUM(det.Quantity)
	 , COUNT(ord.OrderID)
FROM CTE_ORD
JOIN Sales.Invoices AS Inv
  ON Inv.CustomerID = CTE_ORD.CustomerID
JOIN Sales.OrderLines AS det
  ON det.OrderID = Inv.OrderID
JOIN Sales.Orders AS ord
  on ord.OrderID = det.OrderID
 AND ord.CustomerID != Inv.BillToCustomerID 
 AND ord.OrderDate = Inv.InvoiceDate
JOIN Sales.CustomerTransactions AS Trans
  ON Trans.InvoiceID = inv.CustomerID
JOIN Warehouse.StockItemTransactions AS ItemTrans
  ON ItemTrans.StockItemID = det.StockItemID
JOIN Warehouse.StockItems AS It
  ON It.StockItemID = det.StockItemID
 AND It.SupplierId = 12
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID