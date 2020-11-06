--Создание очереди
--Цель: Использовать очередь
--Настроить сервер для работы с очередями
--Написать скрипты для создания и настройки очереди
--Создание очереди в БД для фоновой обработки задачи в БД.
--Подумайте и реализуйте очередь в рамках своего проекта.

--Если в вашем проекте нет задачи, которая подходит под реализацию через очередь, то в качестве ДЗ:
--Реализуйте очередь для БД WideWorldImporters:
--1. Создайте очередь для формирования отчетов для клиентов по таблице Invoices.
--При вызове процедуры для создания отчета в очередь должна отправляться заявка.
--2. При обработке очереди создавайте отчет по количеству заказов (Orders) по клиенту за заданный
--период времени и складывайте готовый отчет в новую таблицу.
--3. Проверьте, что вы корректно открываете и закрываете диалоги и у нас они не копятся.

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
