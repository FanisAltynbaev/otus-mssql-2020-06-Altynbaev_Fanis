--drop procedure if exists Sales.GetNewCustomer;
CREATE PROCEDURE Sales.GetNewCustomer
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, --������������� �������
			@Message NVARCHAR(4000),--���������� ���������
			@MessageType Sysname,--��� ����������� ���������
			@ReplyMessage NVARCHAR(4000),--�������� ���������
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

	SET @xml = CAST(@Message AS XML); -- �������� xml �� ��������

	--�������� CustomerID �� xml
	SELECT @CustomerID = R.Iv.value('@CustomerID','INT')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);


	-- ������� ���������� ������� �� �������
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
		END CONVERSATION @TargetDlgHandle;--������� ������ �� ������� �������
	END 
	
	COMMIT TRAN;
END