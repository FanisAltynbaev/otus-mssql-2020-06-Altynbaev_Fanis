--�������� �������� ��������� ������������ ������� � ��������� ������� ������ �������. 
--1) �������� ������� ������������ ������� � ���������� ������ �������.
use WideWorldImporters
go
--DROP PROCEDURE IF EXISTS #uspBestClient
CREATE OR ALTER PROCEDURE #uspBestClient
  WITH EXECUTE AS CALLER
-- CALLER - ���������, ��� ����������, ������������ � ������, ����������� � ��������� ������������, ����������� ���� ������.
-- ������������, ����������� ������, ������ ����� ��������������� ���������� �� ������ �� ��� ������, 
-- �� ����� � �� ������� ���� ������, �� ������� ������� ������ �� ����� ������.
AS
BEGIN
  SET NOCOUNT ON

  select top 5
    o.OrderID as OrderID,
	max(o.CustomerID) as CustomerID,
	max(c.CustomerName),
    sum(ol.Quantity * ol.UnitPrice) as SaleSum
  from [Sales].[Orders] o 
  join [Sales].[OrderLines] ol on ol.OrderID = o.OrderID
  join [Sales].[Customers] c on c.CustomerID = o.CustomerID
  group by o.OrderID
  order by SaleSum desc

  return;
END
GO

EXEC #uspBestClient


--2) �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
--������������ ������� :
--Sales.Customers
--Sales.Invoices
--Sales.InvoiceLines

use WideWorldImporters
GO

CREATE OR ALTER  PROCEDURE #uspClientOrders
  @CustomerID int
  WITH EXECUTE AS CALLER
-- CALLER - ���������, ��� ����������, ������������ � ������, ����������� � ��������� ������������, ����������� ���� ������.
-- ������������, ����������� ������, ������ ����� ��������������� ���������� �� ������ �� ��� ������, 
-- �� ����� � �� ������� ���� ������, �� ������� ������� ������ �� ����� ������.
AS
 BEGIN
  SET NOCOUNT ON

  select top 5
    c.CustomerID,
	c.CustomerName,
    sum(ol.Quantity * ol.UnitPrice) as SaleSum
  from [Sales].[Customers] c
  join [Sales].[Orders] o on c.CustomerID = o.CustomerID
  join [Sales].[OrderLines] ol on ol.OrderID = o.OrderID
  where c.CustomerID = @CustomerID
  GROUP BY c.CustomerID, c.CustomerName
  return;
END
GO

EXEC #uspClientOrders 
  @CustomerID = 71

--3) ������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.
use WideWorldImporters
GO

CREATE OR ALTER PROCEDURE #uspClientOrders
  @CustomerID int
  WITH EXECUTE AS CALLER
-- CALLER - ���������, ��� ����������, ������������ � ������, ����������� � ��������� ������������, ����������� ���� ������.
-- ������������, ����������� ������, ������ ����� ��������������� ���������� �� ������ �� ��� ������, 
-- �� ����� � �� ������� ���� ������, �� ������� ������� ������ �� ����� ������.
AS
 BEGIN
  SET NOCOUNT ON

  select
    sum(ol.Quantity * ol.UnitPrice) as SaleSum
  from [Sales].[Customers] c
  join [Sales].[Orders] o on c.CustomerID = o.CustomerID
  join [Sales].[OrderLines] ol on ol.OrderID = o.OrderID
  where c.CustomerID = @CustomerID
  GROUP BY c.CustomerID, c.CustomerName
  return;
END
GO

CREATE OR ALTER FUNCTION ufClientOrders (@CustomerID int)
  RETURNS decimal (18,2) 
  WITH EXECUTE AS CALLER
-- CALLER - ���������, ��� ����������, ������������ � ������, ����������� � ��������� ������������, ����������� ���� ������.
-- ������������, ����������� ������, ������ ����� ��������������� ���������� �� ������ �� ��� ������, 
-- �� ����� � �� ������� ���� ������, �� ������� ������� ������ �� ����� ������.
AS
 BEGIN
  declare @SaleSum decimal (18,2) 
  select 
    @SaleSum = sum(ol.Quantity * ol.UnitPrice)
  from [Sales].[Customers] c
  join [Sales].[Orders] o on c.CustomerID = o.CustomerID
  join [Sales].[OrderLines] ol on ol.OrderID = o.OrderID
  where c.CustomerID = @CustomerID
  GROUP BY c.CustomerID, c.CustomerName
  return (@SaleSum)
END
GO

set statistics io, time on

-- ����� ���������
EXEC #uspClientOrders  @CustomerID = 71
/* ����� ��������������� ������� � ���������� SQL Server: 
 ����� �� = 0 ��, �������� ����� = 0 ��.
����� ��������������� ������� � ���������� SQL Server: 
 ����� �� = 78 ��, �������� ����� = 99 ��.

 ����� ������ SQL Server:
   ����� �� = 0 ��, ����������� ����� = 0 ��.
������� "OrderLines". ����� ���������� 2, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 345, lob ���������� ������ 3, lob ����������� ������ 790.
������� "OrderLines". ������� ��������� 1, ��������� 0.
������� "Orders". ����� ���������� 1, ���������� ������ 2, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Customers". ����� ���������� 0, ���������� ������ 2, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

 ����� ������ SQL Server:
   ����� �� = 0 ��, ����������� ����� = 59 ��.

 ����� ������ SQL Server:
   ����� �� = 0 ��, ����������� ����� = 0 ��.

 ����� ������ SQL Server:
   ����� �� = 78 ��, ����������� ����� = 159 ��.

*/
-- ����� �������
select dbo.ufClientOrders(71)
/* ����� ��������������� ������� � ���������� SQL Server: 
 ����� �� = 0 ��, �������� ����� = 1 ��.

(1 row affected)

 ����� ������ SQL Server:
   ����� �� = 62 ��, ����������� ����� = 114 ��.
*/

/* ������� �������� � 2-3 ���� ������� */



--4) �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����. 
use WideWorldImporters
GO
--������� ���� ��� ������
CREATE TYPE udfTableType 
AS TABLE (ID int)
GO 

CREATE OR ALTER FUNCTION ufClientInfo (@CustomerID udfTableType READONLY)
  RETURNS TABLE 
-- WITH EXECUTE AS CALLER
-- CALLER - ���������, ��� ����������, ������������ � ������, ����������� � ��������� ������������, ����������� ���� ������.
-- ������������, ����������� ������, ������ ����� ��������������� ���������� �� ������ �� ��� ������, 
-- �� ����� � �� ������� ���� ������, �� ������� ������� ������ �� ����� ������.
AS
RETURN 
(
  select
    c.CustomerID as CustomerID,
	c.CustomerName as CustomerName
  from [Sales].[Customers] c
  where c.CustomerID in (select * from @CustomerID)
);
GO

DECLARE @myTable udfTableType
INSERT INTO @myTable(ID)
SELECT CustomerID 
from [Sales].[Customers]
where CustomerID < 50 and CustomerID%5 = 0

select  *
from ufClientInfo(@myTable)


--5) �����������. ���������� ��������� kitchen sink � ���������� ������� ���������� �� ������ � ������� �� ������������ SQL. �������� ����� �������. 
use WideWorldImporters
GO

-- KitchenSinkOtus
CREATE OR ALTER PROCEDURE dbo.CustomerSearch_KitchenSinkOtus
  @CustomerID            int            = NULL,
  @CustomerName          nvarchar(100)  = NULL,
  @BillToCustomerID      int            = NULL,
  @CustomerCategoryID    int            = NULL,
  @BuyingGroupID         int            = NULL,
  @MinAccountOpenedDate  date           = NULL,
  @MaxAccountOpenedDate  date           = NULL,
  @DeliveryCityID        int            = NULL,
  @IsOnCreditHold        bit            = NULL,
  @OrdersCount			 INT			= NULL, 
  @PersonID				 INT			= NULL, 
  @DeliveryStateProvince INT			= NULL,
  @PrimaryContactPersonIDIsEmployee BIT = NULL

AS
BEGIN
  SET NOCOUNT ON;
 
  SELECT CustomerID, CustomerName, IsOnCreditHold
  FROM Sales.Customers AS Client
	JOIN Application.People AS Person ON 
		Person.PersonID = Client.PrimaryContactPersonID
	JOIN Application.Cities AS City ON
		City.CityID = Client.DeliveryCityID
  WHERE (@CustomerID IS NULL 
         OR Client.CustomerID = @CustomerID)
    AND (@CustomerName IS NULL 
         OR Client.CustomerName LIKE @CustomerName)
    AND (@BillToCustomerID IS NULL 
         OR Client.BillToCustomerID = @BillToCustomerID)
    AND (@CustomerCategoryID IS NULL 
         OR Client.CustomerCategoryID = @CustomerCategoryID)
    AND (@BuyingGroupID IS NULL 
         OR Client.BuyingGroupID = @BuyingGroupID)
    AND Client.AccountOpenedDate >= 
        COALESCE(@MinAccountOpenedDate, Client.AccountOpenedDate)
    AND Client.AccountOpenedDate <= 
        COALESCE(@MaxAccountOpenedDate, Client.AccountOpenedDate)
    AND (@DeliveryCityID IS NULL 
         OR Client.DeliveryCityID = @DeliveryCityID)
    AND (@IsOnCreditHold IS NULL 
         OR Client.IsOnCreditHold = @IsOnCreditHold)
	AND ((@OrdersCount IS NULL)
		OR ((SELECT COUNT(*) FROM Sales.Orders
			WHERE Orders.CustomerID = Client.CustomerID)
				>= @OrdersCount
			)
		)
	AND ((@PersonID IS NULL) 
		OR (Client.PrimaryContactPersonID = @PersonID))
	AND ((@DeliveryStateProvince IS NULL)
		OR (City.StateProvinceID = @DeliveryStateProvince))
	AND ((@PrimaryContactPersonIDIsEmployee IS NULL)
		OR (Person.IsEmployee = @PrimaryContactPersonIDIsEmployee)
		);
END;
GO

-- DynamicSql
CREATE OR ALTER PROCEDURE dbo.CustomerSearch_DynamicSql
  @CustomerID            int            = NULL,
  @CustomerName          nvarchar(100)  = NULL,
  @BillToCustomerID      int            = NULL,
  @CustomerCategoryID    int            = NULL,
  @BuyingGroupID         int            = NULL,
  @MinAccountOpenedDate  date           = NULL,
  @MaxAccountOpenedDate  date           = NULL,
  @DeliveryCityID        int            = NULL,
  @IsOnCreditHold        bit            = NULL,
  @OrdersCount			 INT			= NULL, 
  @PersonID				 INT			= NULL, 
  @DeliveryStateProvince INT			= NULL,
  @PrimaryContactPersonIDIsEmployee BIT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @sql nvarchar(max),
		  @params nvarchar(max);
 
   SET @params = N'
  @CustomerID            int            = NULL,
  @CustomerName          nvarchar(100)  = NULL,
  @BillToCustomerID      int            = NULL,
  @CustomerCategoryID    int            = NULL,
  @BuyingGroupID         int            = NULL,
  @MinAccountOpenedDate  date           = NULL,
  @MaxAccountOpenedDate  date           = NULL,
  @DeliveryCityID        int            = NULL,
  @IsOnCreditHold        bit            = NULL,
  @OrdersCount			 INT			= NULL, 
  @PersonID				 INT			= NULL, 
  @DeliveryStateProvince INT			= NULL,
  @PrimaryContactPersonIDIsEmployee BIT = NULL';

  SET @sql =  '
  SELECT CustomerID, CustomerName, IsOnCreditHold
  FROM Sales.Customers AS Client
	JOIN Application.People AS Person ON 
		Person.PersonID = Client.PrimaryContactPersonID
	JOIN Application.Cities AS City ON
		City.CityID = Client.DeliveryCityID
	WHERE 1=1';

  IF @CustomerID IS NOT NULL 
    SET @sql = @sql + ' AND Client.CustomerID = @CustomerID'
  IF @CustomerName IS NOT NULL 
    SET @sql = @sql + ' AND Client.CustomerName LIKE @CustomerName'
  IF @BillToCustomerID IS NOT NULL  
    SET @sql = @sql + ' AND Client.BillToCustomerID = @BillToCustomerID'
  IF @CustomerCategoryID IS NOT NULL 
    SET @sql = @sql + ' AND Client.CustomerCategoryID = @CustomerCategoryID'
  IF @BuyingGroupID IS NOT NULL 
    SET @sql = @sql + ' AND Client.BuyingGroupID = @BuyingGroupID'
  IF @MinAccountOpenedDate IS NOT NULL
    SET @sql = @sql + ' AND Client.AccountOpenedDate >= @MinAccountOpenedDate'
  ELSE
    SET @sql = @sql + ' AND Client.AccountOpenedDate >= Client.AccountOpenedDate'
  IF @MinAccountOpenedDate IS NOT NULL
    SET @sql = @sql + ' AND Client.AccountOpenedDate <= @MaxAccountOpenedDate'
  ELSE
    SET @sql = @sql + ' AND Client.AccountOpenedDate <= Client.AccountOpenedDate'
  IF @DeliveryCityID IS NOT NULL 
    SET @sql = @sql + ' AND Client.DeliveryCityID = @DeliveryCityID'
  IF @IsOnCreditHold IS NOT NULL 
    SET @sql = @sql + ' AND Client.IsOnCreditHold = @IsOnCreditHold'
  IF @OrdersCount IS NOT NULL
	SET @sql = @sql + ' AND ((SELECT COUNT(*) FROM Sales.Orders
			                  WHERE Orders.CustomerID = Client.CustomerID)
				              >= @OrdersCount
			                )'
  IF @PersonID IS NOT NULL
	SET @sql = @sql + ' AND Client.PrimaryContactPersonID = @PersonID'
  IF @DeliveryStateProvince IS NOT NULL
	SET @sql = @sql + ' AND City.StateProvinceID = @DeliveryStateProvince'
  IF @PrimaryContactPersonIDIsEmployee IS NOT NULL
	SET @sql = @sql + ' AND Person.IsEmployee = @PrimaryContactPersonIDIsEmployee'

PRINT @sql;

    EXEC sys.sp_executesql @sql, @params, 
         @CustomerID            
       , @CustomerName          
       , @BillToCustomerID      
       , @CustomerCategoryID    
       , @BuyingGroupID         
       , @MinAccountOpenedDate  
       , @MaxAccountOpenedDate  
       , @DeliveryCityID        
       , @IsOnCreditHold        
       , @OrdersCount			
       , @PersonID				
       , @DeliveryStateProvince 
       , @PrimaryContactPersonIDIsEmployee;
END;

set statistics io, time on
GO

EXEC dbo.CustomerSearch_KitchenSinkOtus
EXEC dbo.CustomerSearch_DynamicSql
/* ��� ������ ������� ���������� ����� �������� 93% � 7% �������������� */

EXEC dbo.CustomerSearch_KitchenSinkOtus @CustomerID = 109
EXEC dbo.CustomerSearch_DynamicSql @CustomerID = 109
/* ��� ���������� ��������� @CustomerID, ���������� ����� �������� ���������� 82% � 18% �������������� */

/* 
��� ������������� ������������� SQL, � ������ � �������������� ���� �������� �������� ������ ���������� ����������, � �������� �� KitchenSink 
��� ����������� ��� ��������
*/
