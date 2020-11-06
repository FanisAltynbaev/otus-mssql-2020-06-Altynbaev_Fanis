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

select * from HW29_CustomerOrders

declare @CustomerID int
select @CustomerID = min(i.CustomerID)
from [Sales].[Invoices] as i
while @CustomerID > 0
begin
  EXEC Sales.SendNewCustomer
	@CustomerId = @CustomerID;

  select @CustomerID = min(i.CustomerID)
  from [Sales].[Invoices] as i
  where i.CustomerID > @CustomerID
    and i.CustomerID < 10 --> @CustomerID
end

select * from HW29_CustomerOrders
