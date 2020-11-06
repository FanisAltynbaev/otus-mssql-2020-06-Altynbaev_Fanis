--�������� �������
--����: ������������ �������
--��������� ������ ��� ������ � ���������
--�������� ������� ��� �������� � ��������� �������
--�������� ������� � �� ��� ������� ��������� ������ � ��.
--��������� � ���������� ������� � ������ ������ �������.

--���� � ����� ������� ��� ������, ������� �������� ��� ���������� ����� �������, �� � �������� ��:
--���������� ������� ��� �� WideWorldImporters:
--1. �������� ������� ��� ������������ ������� ��� �������� �� ������� Invoices.
--��� ������ ��������� ��� �������� ������ � ������� ������ ������������ ������.
--2. ��� ��������� ������� ���������� ����� �� ���������� ������� (Orders) �� ������� �� ��������
--������ ������� � ����������� ������� ����� � ����� �������.
--3. ���������, ��� �� ��������� ���������� � ���������� ������� � � ��� ��� �� �������.

drop table HW29_CustomerOrders
create table HW29_CustomerOrders
(CustomerID  int
,CountOrders int
)

declare @CustomerID int
select @CustomerID = min(i.CustomerID)
from [Sales].[Invoices] as i
while @CustomerID > 0
begin
  EXEC [Sales].[SendNewCustomer]
	@CustomerId = @CustomerID;

  select @CustomerID = min(i.CustomerID)
  from [Sales].[Invoices] as i
  where i.CustomerID > @CustomerID
end

/*
--��������  ��������
SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorQueueWWI;

SELECT CAST(message_body AS XML),*
FROM dbo.TargetQueueWWI;

--�������� �������, ��� ��� ��������
EXEC Sales.SendNewCustomer
	@CustomerId = 2;

--Target
EXEC Sales.GetNewCustomer;

--Initiator
EXEC Sales.AddOrdersInfo;

select * from HW29_CustomerOrders
*/



/*
                                                                       status priority queuing_order  conversation_group_id                conversation_handle                  message_sequence_number service_name                 service_id  service_contract_name   service_contract_id message_type_name                                          message_type_id validation message_body                                                                                                                                                                                                                                                     message_enqueue_time
---------------------------------------------------------------------- ------ -------- -------------- ------------------------------------ ------------------------------------ ----------------------- ---------------------------- ----------- ----------------------- ------------------- ---------------------------------------------------------- --------------- ---------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -----------------------
<ReplyMessage><inv CustomerID="1" CountOrders="129" /></ReplyMessage>  1      5        50             B2C8D511-7A20-EB11-B63C-308D9922A110 B1C8D511-7A20-EB11-B63C-308D9922A110 0                       //WWI/SB/InitiatorService    65537       //WWI/SB/Contract       65536               //WWI/SB/ReplyMessage                                      65537           X          0x3C005200650070006C0079004D006500730073006100670065003E003C0069006E007600200043007500730074006F006D0065007200490044003D00220031002200200043006F0075006E0074004F00720064006500720073003D00220031003200390022002F003E003C002F005200650070006C0079004D006500730073 2020-11-06 21:50:26.130
NULL                                                                   1      5        51             B2C8D511-7A20-EB11-B63C-308D9922A110 B1C8D511-7A20-EB11-B63C-308D9922A110 1                       //WWI/SB/InitiatorService    65537       //WWI/SB/Contract       65536               http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog   2               E          NULL                                                                                                                                                                                                                                                             2020-11-06 21:50:26.130

(2 rows affected)
*/

