--1. Все товары, в названии которых есть "urgent" или название начинается с "Animal"
--Таблицы: Warehouse.StockItems
select *
  from Warehouse.StockItems with(nolock)
 where StockItemName like '%urgent%'
    or StockItemName like 'Animal%'

--2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders). 
--Сделать через JOIN, с подзапросом задание принято не будет.
--Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
select distinct s.SupplierID, s.SupplierName
  from Purchasing.Suppliers s with(nolock)
  left join Purchasing.PurchaseOrders p with (nolock) on p.SupplierID = s.SupplierID
 where p.SupplierID is null

/*
3. Заказы (Orders) с ценой товара более 100$ либо количеством единиц товара более 20 штук 
и присутствующей датой комплектации всего заказа (PickingCompletedWhen). 
Вывести:
* OrderID
* дату заказа в формате ДД.ММ.ГГГГ
* название месяца, в котором была продажа
* номер квартала, к которому относится продажа
* треть года, к которой относится дата продажи (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой, пропустив первую 1000 и отобразив следующие 100 записей. 
Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию). 
Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
SET ROWCOUNT 100
select distinct
    o.OrderID
  , convert(varchar(10), o.OrderDate, 104) as OrderDate
  , case month(o.OrderDate) when  1 then 'January'
                            when  2 then 'February'
                            when  3 then 'March'
                            when  4 then 'April'
                            when  5 then 'May'
                            when  6 then 'June'
                            when  7 then 'July'
                            when  8 then 'August'
                            when  9 then 'September'
                            when 10 then 'October'
                            when 11 then 'November'
                            when 12 then 'December'
                            else ''
    end
  , (month(o.OrderDate)-1)/3+1 as g4--, 'квартал'
  , (month(o.OrderDate)-1)/4+1 as g3--, 'декада_года'
  , c.CustomerName
 -- , ol.OrderLineID
 -- , ol.Quantity
 -- , ol.UnitPrice
 from Sales.Orders o with(nolock)
 join Sales.Customers c with(nolock)
   on c.CustomerID = o.CustomerID
 join Sales.OrderLines ol with(nolock)
   on ol.OrderID = o.OrderID
  and (ol.UnitPrice >= 100 or ol.Quantity >= 20)
where o.PickingCompletedWhen is not null
order by g4, g3, OrderDate, o.OrderID
Offset 1000 Rows
SET ROWCOUNT 0

/*
4. Заказы поставщикам (Purchasing.Suppliers), которые были исполнены в январе 2014 года
с доставкой Air Freight или Refrigerated Air Freight (DeliveryMethodName).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/
select 
    o.PurchaseOrderID  --  в условии не было, но вывел чтобы хоть как то идентифицировать заказ
  , dm.DeliveryMethodName
  , o.ExpectedDeliveryDate
  , s.SupplierName
  , p.FullName as ContactPerson
--  , o.*
 from  Purchasing.PurchaseOrders o with(nolock)
 join Application.DeliveryMethods dm with(nolock)
   on dm.DeliveryMethodID = o.DeliveryMethodID
  and dm.DeliveryMethodName in ('Air Freight' ,'Refrigerated Air Freight')
 left join Application.People p with(nolock)
   on p.PersonID = o.ContactPersonID
 join Purchasing.Suppliers s with(nolock)
   on s.SupplierID = o.SupplierID
where o.ExpectedDeliveryDate between '20130101' and '20130131' -- изменил условие на 2013 год


--5. Десять последних продаж (по дате) с именем клиента и именем сотрудника, 
--который оформил заказ (SalespersonPerson).
select 
    top 10
	c.CustomerName as CustomerName
  , p.FullName as SalespersonPerson
  , o.*
 from [Sales].[Orders] o with(nolock)
 join [Sales].[Customers] c with(nolock)
   on c.CustomerID = o.CustomerID
 left join Application.People p with(nolock)
   on p.PersonID = o.SalespersonPersonID
 order by OrderDate desc, OrderID 


--6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g. 
--Имя товара смотреть в Warehouse.StockItems.
select
    c.CustomerID
  , c.CustomerName
  , c.PhoneNumber
 -- , *
 from [Sales].[Customers] c with(nolock)
 where exists(select 1 
                from Sales.Orders o with(nolock)
                join Sales.OrderLines ol with(nolock)
                  on ol.OrderID = o.OrderID
                join Warehouse.StockItems si with (nolock)
                  on si.StockItemID = ol.StockItemID
                 and si.StockItemName = 'Chocolate frogs 250g'
                where o.CustomerID = c.CustomerID
             )
