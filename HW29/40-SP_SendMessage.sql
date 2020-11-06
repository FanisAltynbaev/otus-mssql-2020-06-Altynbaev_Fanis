SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

use WideWorldImporters
go

--��������� ����������� �������� ������� � ������� �������
--DROP PROCEDURE Sales.SendNewCustomer
CREATE PROCEDURE Sales.SendNewCustomer
	@CustomerId INT
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER; --open init dialog
	DECLARE @RequestMessage NVARCHAR(4000); --���������, ������� ����� ����������
	
	BEGIN TRAN --�������� ����������

	--Prepare the Message  !!!auto generate XML
	SELECT @RequestMessage = (SELECT CustomerID
							  FROM Sales.Invoices AS Inv
							  WHERE CustomerID = @CustomerId
							  group by CustomerID
							  FOR XML AUTO, root('RequestMessage')); 
	
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService]
	TO SERVICE
	'//WWI/SB/TargetService'
	ON CONTRACT
	[//WWI/SB/Contract]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	--SELECT @RequestMessage AS SentRequestMessage;--we can write data to log
	COMMIT TRAN 
END
GO
