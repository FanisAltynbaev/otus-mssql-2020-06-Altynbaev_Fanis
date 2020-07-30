--Insert, Update, Merge
use WideWorldImporters
go

--1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers
insert into Sales.Customers
(CustomerName
,BillToCustomerID
,CustomerCategoryID
--,BuyingGroupID
,PrimaryContactPersonID
--,AlternateContactPersonID
,DeliveryMethodID
,DeliveryCityID
,PostalCityID
--,CreditLimit
,AccountOpenedDate
,StandardDiscountPercentage
,IsStatementSent
,IsOnCreditHold
,PaymentDays
,PhoneNumber
,FaxNumber
--,DeliveryRun
--,RunPosition
,WebsiteURL
,DeliveryAddressLine1
--,DeliveryAddressLine2
,DeliveryPostalCode
--,DeliveryLocation
,PostalAddressLine1
--,PostalAddressLine2
,PostalPostalCode
,LastEditedBy
--,ValidFrom
--,ValidTo
)
select
 'New ' + CustomerName
,BillToCustomerID
,CustomerCategoryID
--,BuyingGroupID
,PrimaryContactPersonID
--,AlternateContactPersonID
,DeliveryMethodID
,DeliveryCityID
,PostalCityID
--,CreditLimit
,AccountOpenedDate
,StandardDiscountPercentage
,IsStatementSent
,IsOnCreditHold
,PaymentDays
,PhoneNumber
,FaxNumber
--,DeliveryRun
--,RunPosition
,WebsiteURL
,DeliveryAddressLine1
--,DeliveryAddressLine2
,DeliveryPostalCode
--,DeliveryLocation
,PostalAddressLine1
--,PostalAddressLine2
,PostalPostalCode
,LastEditedBy
--,ValidFrom
--,ValidTo
from Sales.Customers c
where c.CustomerID <=5


--2. удалите 1 запись из Customers, которая была вами добавлена
;with ForDelete (ID) as
(select max(CustomerID) from Sales.Customers
 where CustomerName like 'New %'
)
delete c
from Sales.Customers c
join ForDelete d on d.ID = c.CustomerID

select top 5 * from Sales.Customers
order by CustomerID desc


--3. изменить одну запись, из добавленных через UPDATE
;with ForDelete (ID) as
(select max(CustomerID) from Sales.Customers
where CustomerName like 'New %'
)
update c
set CustomerName = 'NEW++ ' + SUBSTRING(CustomerName, 5, LEN(CustomerName))
from Sales.Customers c
join ForDelete d on d.ID = c.CustomerID


--4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
MERGE Sales.Customers AS Target
USING (SELECT CustomerID
             ,CustomerName
             ,BillToCustomerID
             ,CustomerCategoryID
             --,BuyingGroupID
             ,PrimaryContactPersonID
             --,AlternateContactPersonID
             ,DeliveryMethodID
             ,DeliveryCityID
             ,PostalCityID
             --,CreditLimit
             ,AccountOpenedDate
             ,StandardDiscountPercentage
             ,IsStatementSent
             ,IsOnCreditHold
             ,PaymentDays
             ,PhoneNumber
             ,FaxNumber
             --,DeliveryRun
             --,RunPosition
             ,WebsiteURL
             ,DeliveryAddressLine1
             --,DeliveryAddressLine2
             ,DeliveryPostalCode
             --,DeliveryLocation
             ,PostalAddressLine1
             --,PostalAddressLine2
             ,PostalPostalCode
             ,LastEditedBy
             --,ValidFrom
             --,ValidTo
       from Sales.Customers
       where CustomerID < (select max(CustomerID) from Sales.Customers)

       union all 

       select CustomerID
             ,'New+2' + SUBSTRING(CustomerName, 6, LEN(CustomerName))
             ,BillToCustomerID
             ,CustomerCategoryID
             --,BuyingGroupID
             ,PrimaryContactPersonID
             --,AlternateContactPersonID
             ,DeliveryMethodID
             ,DeliveryCityID
             ,PostalCityID
             --,CreditLimit
             ,AccountOpenedDate
             ,StandardDiscountPercentage
             ,IsStatementSent
             ,IsOnCreditHold
             ,PaymentDays
             ,PhoneNumber
             ,FaxNumber
             --,DeliveryRun
             --,RunPosition
             ,WebsiteURL
             ,DeliveryAddressLine1
             --,DeliveryAddressLine2
             ,DeliveryPostalCode
             --,DeliveryLocation
             ,PostalAddressLine1
             --,PostalAddressLine2
             ,PostalPostalCode
             ,LastEditedBy
             --,ValidFrom
             --,ValidTo
       from Sales.Customers
       where CustomerID = (select max(CustomerID) from Sales.Customers)

       union all

       select CustomerID+1000
              ,'New+2' + SUBSTRING(CustomerName, 6, LEN(CustomerName))
              ,BillToCustomerID
              ,CustomerCategoryID
              --,BuyingGroupID
              ,PrimaryContactPersonID
              --,AlternateContactPersonID
              ,DeliveryMethodID
              ,DeliveryCityID
              ,PostalCityID
              --,CreditLimit
              ,AccountOpenedDate
              ,StandardDiscountPercentage
              ,IsStatementSent
              ,IsOnCreditHold
              ,PaymentDays
              ,PhoneNumber
              ,FaxNumber
              --,DeliveryRun
              --,RunPosition
              ,WebsiteURL
              ,DeliveryAddressLine1
              --,DeliveryAddressLine2
              ,DeliveryPostalCode
              --,DeliveryLocation
              ,PostalAddressLine1
              --,PostalAddressLine2
              ,PostalPostalCode
              ,LastEditedBy
              --,ValidFrom
              --,ValidTo
       from Sales.Customers
       where CustomerID = (select max(CustomerID) from Sales.Customers)
      ) AS Source
ON (Target.CustomerID = Source.CustomerID)
WHEN MATCHED 
    THEN UPDATE 
        SET CustomerName = Source.CustomerName
WHEN NOT MATCHED 
    THEN INSERT ( CustomerName
                 ,BillToCustomerID
                 ,CustomerCategoryID
                 --,BuyingGroupID
                 ,PrimaryContactPersonID
                 --,AlternateContactPersonID
                 ,DeliveryMethodID
                 ,DeliveryCityID
                 ,PostalCityID
                 --,CreditLimit
                 ,AccountOpenedDate
                 ,StandardDiscountPercentage
                 ,IsStatementSent
                 ,IsOnCreditHold
                 ,PaymentDays
                 ,PhoneNumber
                 ,FaxNumber
                 --,DeliveryRun
                 --,RunPosition
                 ,WebsiteURL
                 ,DeliveryAddressLine1
                 --,DeliveryAddressLine2
                 ,DeliveryPostalCode
                 --,DeliveryLocation
                 ,PostalAddressLine1
                 --,PostalAddressLine2
                 ,PostalPostalCode
                 ,LastEditedBy
                 --,ValidFrom
                 --,ValidTo
         )         	
         VALUES ( 'New+3' + SUBSTRING(source.CustomerName, 6, LEN(source.CustomerName))
                 ,source.BillToCustomerID
                 ,source.CustomerCategoryID
                 --,BuyingGroupID
                 ,source.PrimaryContactPersonID
                 --,AlternateContactPersonID
                 ,source.DeliveryMethodID
                 ,source.DeliveryCityID
                 ,source.PostalCityID
                 --,CreditLimit
                 ,source.AccountOpenedDate
                 ,source.StandardDiscountPercentage
                 ,source.IsStatementSent
                 ,source.IsOnCreditHold
                 ,source.PaymentDays
                 ,source.PhoneNumber
                 ,source.FaxNumber
                 --,DeliveryRun
                 --,RunPosition
                 ,source.WebsiteURL
                 ,source.DeliveryAddressLine1
                 --,DeliveryAddressLine2
                 ,source.DeliveryPostalCode
                 --,DeliveryLocation
                 ,source.PostalAddressLine1
                 --,PostalAddressLine2
                 ,source.PostalPostalCode
                 ,source.LastEditedBy
                 --,ValidFrom
                 --,ValidTo
		)
OUTPUT deleted.*, $action, inserted.*;

select top 5 * from Sales.Customers
order by CustomerID desc
/*
delete  Sales.Customers
where CustomerID in (1090,1088,1087,1086,1085)
*/



--5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert 
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp "SELECT CustomerID, CustomerName FROM WideWorldImporters.Sales.Customers WITH (NOLOCK)" queryout "C:\1\Sales_Customers_c.bcp" -T -w -t"@eu&$1&" -S DESKTOP-5G2NUF4\OTUS'

drop table if exists [Sales].[ShortCustomers]

CREATE TABLE [Sales].[ShortCustomers](
	[CustomerID] [int] NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL
)

BULK INSERT [WideWorldImporters].[Sales].[ShortCustomers]
		   FROM "C:\1\Sales_Customers_c.bcp"
		   WITH 
			 (
				BATCHSIZE = 1000, 
				DATAFILETYPE = 'widechar',
				FIELDTERMINATOR = '@eu&$1&',
				ROWTERMINATOR ='\n',
				KEEPNULLS,
				TABLOCK        
			  );

select * from [WideWorldImporters].[Sales].[ShortCustomers]
