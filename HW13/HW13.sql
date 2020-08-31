--Написать хранимую процедуру возвращающую Клиента с набольшей разовой суммой покупки. 
--1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
use WideWorldImporters
go
--DROP PROCEDURE IF EXISTS #uspBestClient
CREATE OR ALTER PROCEDURE #uspBestClient
  WITH EXECUTE AS CALLER
-- CALLER - Указывает, что инструкции, содержащиеся в модуле, выполняются в контексте пользователя, вызывающего этот модуль.
-- Пользователь, выполняющий модуль, должен иметь соответствующие разрешения не только на сам модуль, 
-- но также и на объекты базы данных, на которые имеются ссылки из этого модуля.
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


--2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
--Использовать таблицы :
--Sales.Customers
--Sales.Invoices
--Sales.InvoiceLines

use WideWorldImporters
GO

CREATE OR ALTER  PROCEDURE #uspClientOrders
  @CustomerID int
  WITH EXECUTE AS CALLER
-- CALLER - Указывает, что инструкции, содержащиеся в модуле, выполняются в контексте пользователя, вызывающего этот модуль.
-- Пользователь, выполняющий модуль, должен иметь соответствующие разрешения не только на сам модуль, 
-- но также и на объекты базы данных, на которые имеются ссылки из этого модуля.
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

--3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
use WideWorldImporters
GO

CREATE OR ALTER PROCEDURE #uspClientOrders
  @CustomerID int
  WITH EXECUTE AS CALLER
-- CALLER - Указывает, что инструкции, содержащиеся в модуле, выполняются в контексте пользователя, вызывающего этот модуль.
-- Пользователь, выполняющий модуль, должен иметь соответствующие разрешения не только на сам модуль, 
-- но также и на объекты базы данных, на которые имеются ссылки из этого модуля.
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
-- CALLER - Указывает, что инструкции, содержащиеся в модуле, выполняются в контексте пользователя, вызывающего этот модуль.
-- Пользователь, выполняющий модуль, должен иметь соответствующие разрешения не только на сам модуль, 
-- но также и на объекты базы данных, на которые имеются ссылки из этого модуля.
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

-- вызов процедуры
EXEC #uspClientOrders  @CustomerID = 71
/* Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 78 мс, истекшее время = 99 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Таблица "OrderLines". Число просмотров 2, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 345, lob физических чтений 3, lob упреждающих чтений 790.
Таблица "OrderLines". Считано сегментов 1, пропущено 0.
Таблица "Orders". Число просмотров 1, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "Customers". Число просмотров 0, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 59 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 78 мс, затраченное время = 159 мс.

*/
-- вызов функции
select dbo.ufClientOrders(71)
/* Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 1 мс.

(1 row affected)

 Время работы SQL Server:
   Время ЦП = 62 мс, затраченное время = 114 мс.
*/

/* Функция работает в 2-3 раза быстрее */



--4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
use WideWorldImporters
GO
--создаем свой тип данных
CREATE TYPE udfTableType 
AS TABLE (ID int)
GO 

CREATE OR ALTER FUNCTION ufClientInfo (@CustomerID udfTableType READONLY)
  RETURNS TABLE 
-- WITH EXECUTE AS CALLER
-- CALLER - Указывает, что инструкции, содержащиеся в модуле, выполняются в контексте пользователя, вызывающего этот модуль.
-- Пользователь, выполняющий модуль, должен иметь соответствующие разрешения не только на сам модуль, 
-- но также и на объекты базы данных, на которые имеются ссылки из этого модуля.
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


--5) Опционально. Переписать процедуру kitchen sink с множеством входных параметров по поиску в заказах на динамический SQL. Сравнить планы запроса. 
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
/* При данном запросе стоимомсть работ процедур 93% и 7% соответственно */

EXEC dbo.CustomerSearch_KitchenSinkOtus @CustomerID = 109
EXEC dbo.CustomerSearch_DynamicSql @CustomerID = 109
/* При добавлении параметра @CustomerID, стоимомсть работ процедур становится 82% и 18% соответственно */

/* 
При использовании динамического SQL, в запрос и соответственно план содержат проверку только переданных параметров, в отличиии от KitchenSink 
где проверяются все значения
*/
