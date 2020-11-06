--������������� ������ �� �� WorldWideImporters.
--��������� ����� ������� �� ������������ �� ������� � ��������� ����� ������, ������� ������ ��� ����������� ��� �����������.
use WideWorldImporters
go

set statistics io, time on 
go


-- ������ �� �����������
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
������� "StockItemTransactions". ����� ���������� 1, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 66, lob ���������� ������ 1, lob ����������� ������ 130.
������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
������� "OrderLines". ����� ���������� 4, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 518, lob ���������� ������ 5, lob ����������� ������ 795.
������� "OrderLines". ������� ��������� 2, ��������� 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "CustomerTransactions". ����� ���������� 5, ���������� ������ 261, ���������� ������ 4, ����������� ������ 253, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Orders". ����� ���������� 2, ���������� ������ 883, ���������� ������ 4, ����������� ������ 870, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Invoices". ����� ���������� 1, ���������� ������ 72913, ���������� ������ 2, ����������� ������ 11118, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItems". ����� ���������� 1, ���������� ������ 2, ���������� ������ 1, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

 ����� ������ SQL Server:
   ����� �� = 1906 ��, ����������� ����� = 56743 ��.
*/


-- ����������� �� AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
-- ��� ���� ��������
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
������� "StockItemTransactions". ����� ���������� 1, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 66, lob ���������� ������ 1, lob ����������� ������ 130.
������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
������� "OrderLines". ����� ���������� 4, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 518, lob ���������� ������ 5, lob ����������� ������ 795.
������� "OrderLines". ������� ��������� 2, ��������� 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "CustomerTransactions". ����� ���������� 5, ���������� ������ 261, ���������� ������ 4, ����������� ������ 253, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Orders". ����� ���������� 1, ���������� ������ 34292, ���������� ������ 73, ����������� ������ 282, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Invoices". ����� ���������� 1, ���������� ������ 71220, ���������� ������ 25, ����������� ������ 11117, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItems". ����� ���������� 1, ���������� ������ 2, ���������� ������ 1, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

 ����� ������ SQL Server:
   ����� �� = 1594 ��, ����������� ����� = 2806 ��.
*/

--������� 
--AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
--     FROM Sales.OrderLines AS Total
--     Join Sales.Orders AS ordTotal
--       On ordTotal.OrderID = Total.OrderID
--     WHERE ordTotal.CustomerID = Inv.CustomerID
--   )> 250000
--� CTE � �������� ������� ��  Sales.Invoices
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
������� "StockItemTransactions". ����� ���������� 1, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 29, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
������� "OrderLines". ����� ���������� 4, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 331, lob ���������� ������ 0, lob ����������� ������ 0.
������� "OrderLines". ������� ��������� 2, ��������� 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 35, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "CustomerTransactions". ����� ���������� 5, ���������� ������ 261, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Invoices". ����� ���������� 14458, ���������� ������ 75136, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Orders". ����� ���������� 2, ���������� ������ 883, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItems". ����� ���������� 1, ���������� ������ 2, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

 ����� ������ SQL Server:
   ����� �� = 1063 ��, ����������� ����� = 1467 ��.
*/



--������� ��� ����� �� ������� 
--AND (Select SupplierId
--   FROM Warehouse.StockItems AS It
--   Where It.StockItemID = det.StockItemID
--   ) = 12
--����� �������� �� JOIN
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
������� "StockItemTransactions". ����� ���������� 1, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 29, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
������� "OrderLines". ����� ���������� 4, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 331, lob ���������� ������ 0, lob ����������� ������ 0.
������� "OrderLines". ������� ��������� 2, ��������� 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "CustomerTransactions". ����� ���������� 5, ���������� ������ 261, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Invoices". ����� ���������� 14458, ���������� ������ 75136, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Orders". ����� ���������� 2, ���������� ������ 883, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItems". ����� ���������� 1, ���������� ������ 2, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

 ����� ������ SQL Server:
   ����� �� = 1094 ��, ����������� ����� = 1417 ��.
*/


-- ������� ������������ ������� �������
-- ��������� ������ � ������� �������
-- ������� ����� ������� ��������, � ��-�������� ��-�� ���������� ���-�� ���������� Invoices
-- ����  - ������� "Invoices". ����� ���������� 14458, ���������� ������ 75136
-- ����� - ������� "Invoices". ����� ���������� 1, ���������� ������ 11400,
-- ??? ��� ??? � ����� CTE ��� �� ��������������
-- �� ����� �������� ���������� ��� ����� � 2 ����, � ��� ������� � �������� ������� ?!?
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
������� "StockItemTransactions". ����� ���������� 1, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 29, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
������� "OrderLines". ����� ���������� 4, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 331, lob ���������� ������ 0, lob ����������� ������ 0.
������� "OrderLines". ������� ��������� 2, ��������� 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "CustomerTransactions". ����� ���������� 5, ���������� ������ 261, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Invoices". ����� ���������� 1, ���������� ������ 11400, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Orders". ����� ���������� 2, ���������� ������ 883, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItems". ����� ���������� 1, ���������� ������ 2, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

 ����� ������ SQL Server:
   ����� �� = 594 ��, ����������� ����� = 844 ��.
*/


--��������� ���, ���� �� ���������� ������ �������������. ����� ��� ���� ������� ����
--������� 
--WHERE Inv.BillToCustomerID != ord.CustomerID
--  AND Inv.InvoiceDate = ord.OrderDate
--� JOIN Sales.Orders AS ord
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