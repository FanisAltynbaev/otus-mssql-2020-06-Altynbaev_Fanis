--drop procedure if exists Sales.GetNewCustomer;
CREATE PROCEDURE Sales.GetNewCustomer
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, --идентификатор диалога
			@Message NVARCHAR(4000),--полученное сообщение
			@MessageType Sysname,--тип полученного сообщения
			@ReplyMessage NVARCHAR(4000),--ответное сообщение
			@CustomerID INT,
			@CountOrders int,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI; 

	SET @xml = CAST(@Message AS XML); -- получаем xml из мессаджа

	--получаем CustomerID из xml
	SELECT @CustomerID = R.Iv.value('@CustomerID','INT')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);


	-- считаем количество заказов по клиенту
	SELECT @ReplyMessage = (SELECT @CustomerID as CustomerID, count(*) as CountOrders
	                        from Sales.Orders	as inv	
	                        WHERE CustomerID = @CustomerID
							FOR XML AUTO, root('ReplyMessage'));

	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;--закроем диалог со стороны таргета
	END 
	
	COMMIT TRAN;
END