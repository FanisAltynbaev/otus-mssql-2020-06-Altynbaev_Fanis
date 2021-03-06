
-- попробуем сначала отправить сообщения, без связки с процедурами обработки

USE [WideWorldImporters]
GO

ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = ON ,
        PROCEDURE_NAME = Sales.AddOrdersInfo, MAX_QUEUE_READERS = 100, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = ON ,
        PROCEDURE_NAME = Sales.GetNewCustomer, MAX_QUEUE_READERS = 100, EXECUTE AS OWNER) ; 

GO
--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/create-queue-transact-sql?view=sql-server-ver15