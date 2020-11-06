--DROP PROCEDURE Sales.AddOrdersInfo
CREATE PROCEDURE Sales.AddOrdersInfo
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER, --����� �������
			@Message NVARCHAR(1000),
			@CustomerID int,
			@CountOrders int,
			@xml XML; 
	
	BEGIN TRAN; 

	--������� ��������� �� ������� ����������
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@Message=Message_Body
		FROM dbo.InitiatorQueueWWI
--		where message_sequence_number = 0 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --������� ������ �� ������� ����������
		--��� ��������� ������� ������ ��������� ���
		--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/end-conversation-transact-sql?view=sql-server-ver15
		
	    SET @xml = CAST(@Message AS XML); -- �������� xml �� ��������
	    
	    --�������� CountOrders �� xml
	    SELECT @CustomerID = R.Inv.value('@CustomerID','INT')
		     , @CountOrders = R.Inv.value('@CountOrders','INT')
	    FROM @xml.nodes('/ReplyMessage/inv') as R(Inv);
	    
	    -- ������� ���������� ������� �� �������
	    insert into HW29_CustomerOrders
		( CustomerID
		, CountOrders
		) 
		SELECT @CustomerID, @CountOrders
	COMMIT TRAN; 
END


