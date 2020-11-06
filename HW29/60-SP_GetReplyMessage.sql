--DROP PROCEDURE Sales.AddOrdersInfo
CREATE PROCEDURE Sales.AddOrdersInfo
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER, --хэндл диалога
			@Message NVARCHAR(1000),
			@CustomerID int,
			@CountOrders int,
			@xml XML; 
	
	BEGIN TRAN; 

	--получим сообщение из очереди инициатора
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@Message=Message_Body
		FROM dbo.InitiatorQueueWWI
--		where message_sequence_number = 0 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --закроем диалог со стороны инициатора
		--оба участника диалога должны завершить его
		--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/end-conversation-transact-sql?view=sql-server-ver15
		
	    SET @xml = CAST(@Message AS XML); -- получаем xml из мессаджа
	    
	    --получаем CountOrders из xml
	    SELECT @CustomerID = R.Inv.value('@CustomerID','INT')
		     , @CountOrders = R.Inv.value('@CountOrders','INT')
	    FROM @xml.nodes('/ReplyMessage/inv') as R(Inv);
	    
	    -- считаем количество заказов по клиенту
	    insert into HW29_CustomerOrders
		( CustomerID
		, CountOrders
		) 
		SELECT @CustomerID, @CountOrders
	COMMIT TRAN; 
END


