use [Apiary_OTUS];
GO

/*Первичное наполненеи таблиц */
--select * from [dbo].[Storage]
insert into [dbo].[Storage]
(Name)
select 'Склад 1' union all 
select 'Склад 2' union all 
select 'Пасека' 

-- select * from [dbo].[MaterialType]
insert into [dbo].[MaterialType]
(Name)
          select 'Комплектующие улий' 
union all select 'Комплектующие рамка'
union all select 'Инструменты' 
union all select 'Улий' 
union all select 'Рамка' 
union all select 'Готовая продукция'

--delete [dbo].[Status]
--select * from [dbo].[Status]
insert into [dbo].[Status]
(Name)
          select 'Новый' 
union all select 'На хранении'
union all select 'Используется'
union all select 'В ремонте'
union all select 'Заказ принят'
union all select 'Заказ комплектуется'
union all select 'Заказ исполнен'
union all select 'Семья Сильная'	 , 4
union all select 'Семья Средняя'	 , 4
union all select 'Семья Слабая'		 , 4

union all select 'Рамка новая'       , 5
union all select 'Рамка сушь'        , 5
union all select 'Рамка медовая'     , 5
union all select 'Рамка в работе'    , 5

--select * from [dbo].[Client]
insert into [dbo].[Client]
(FIO, Address, Phone)
select 'Иванов', 'ул. Пушкина 1',     '8-800-111-11-11' union all 
select 'Петров', 'ул. Маяковского 2', '8-800-222-22-22' union all 
select 'Сидоров','ул. Толстого 3',    '8-800-333-33-33'  


--select * from [dbo].[Material] order by MAterialID
insert into [dbo].[Material]
(MaterialTypeID, Name, StorageID, Qty, Date, Srok, StatusID)
          select 1, 'Днище'             , 1,  2, null, null, 18  
union all select 1, 'Днище'             , 1,  8, null, null, null  
union all select 1, 'Днище'             , 3, 10, null, null, 17  
union all select 1, 'Корпус'            , 1,  5, null, null, 18  
union all select 1, 'Корпус'            , 1, 45, null, null, null  
union all select 1, 'Корпус'            , 3, 10, null, null, 17  
union all select 1, 'Подкрышник'        , 1, 10, null, null, null  
union all select 1, 'Подкрышник'        , 3, 10, null, null, 17  
union all select 1, 'Крышка'            , 1, 10, null, null, null  
union all select 1, 'Крышка'            , 3, 10, null, null, 17  

union all select 2, 'Верхняя планка'    , 1, 150, null, null, 16  
union all select 2, 'Нижняя планка'     , 1, 200, null, null, 16  
union all select 2, 'Боковая планка'    , 1, 200, null, null, 16  							        
								        
union all select 3, 'Медогонка'         , 1,  1, null, null, 17  
union all select 3, 'Дымарь'            , 1,  1, null, null, 17  
union all select 3, 'Костюм'            , 1,  1, null, null, 17  
union all select 3, 'Маска'             , 1,  1, null, null, 16  
union all select 3, 'Маска'             , 1,  1, null, null, 17  

union all select 4, 'Семья 1'           , 3,  1, '20170501', 3, 24  
union all select 4, 'Семья 2'           , 3,  2, '20180501', 3, 23  
union all select 4, 'Семья 3'           , 3,  2, '20180501', 3, 23  
union all select 4, 'Семья 4'           , 3,  2, '20190501', 3, 22  
union all select 4, 'Семья 5'           , 3,  3, '20200501', 3, 22  

union all select 5, 'Рамка новая'       , 1,100, null, null, null  
union all select 5, 'Рамка сушь'        , 1,100, null, null, null  
union all select 5, 'Рамка медовая'     , 1, 20, null, null, null  
union all select 5, 'Рамка в работе'    , 3,100, null, null, null  

union all select 6, 'Мёд цветочный'   , 2,   20, '20180801', 36,  null  
union all select 6, 'Мёд цветочный'   , 2,   50, '20190801', 36,  null  
union all select 6, 'Мёд цветочный'   , 2,  150, '20190801', 36,  null  
union all select 6, 'Мёд липовый'     , 2,   20, '20180801', 36,  null  
union all select 6, 'Мёд липовый'     , 2,   50, '20190801', 36,  null  
union all select 6, 'Мёд липовый'     , 2,  150, '20200801', 36,  null  
union all select 6, 'Воск'            , 2,   10, '20180801', 120, null  
union all select 6, 'Воск'            , 2,   10, '20190801', 120, null  
union all select 6, 'Воск'            , 2,   10, '20200801', 120, null  
union all select 6, 'Прополис'        , 2,  100, '20180801', 24,  null  
union all select 6, 'Прополис'        , 2,  200, '20190801', 24,  null  
union all select 6, 'Прополис'        , 2,  300, '20200801', 24,  null  
union all select 6, 'Пыльца'          , 2,  500, '20180801', 12,  null  
union all select 6, 'Пыльца'          , 2, 1000, '20190801', 12,  null  
union all select 6, 'Пыльца'          , 2, 2000, '20200801', 12,  null  


--delete Relation
--select * from [dbo].[Relation]
insert into [dbo].[Relation]
(MaterialID, StorageID, Qty, StatusID)
          select   3, 1,    2, 18  
union all select   3, 1,    8, null  
union all select   3, 3,   10, 17  
union all select   6, 1,    5, 18  
union all select   6, 1,   45, null  
union all select   6, 3,   10, 17  
union all select   9, 1,   10, null  
union all select   9, 3,   10, 17  
union all select  11, 1,   10, null  
union all select  11, 3,   10, 17  

union all select  13, 1,  150,  16  
union all select  14, 1,  200,  16  
union all select  15, 1,  200,  16  							        
						 		        
union all select  16, 1,   1, 17  
union all select  17, 1,   1, 17  
union all select  18, 1,   1, 17  
union all select  19, 1,   1, 16  
union all select  20, 1,   1, 17  
						 
union all select  21, 3,   1, 24  
union all select  22, 3,   2, 23  
union all select  23, 3,   2, 23  
union all select  24, 3,   2, 22  
union all select  25, 3,   3, 22  
						 
union all select  26, 1, 100, 1016  
union all select  26, 1, 100, 1017  
union all select  26, 1,  20, 1018  
union all select  26, 3, 100, 1019  

union all select  35, 2,   20, null  
union all select  36, 2,   50, null  
union all select  37, 2,  150, null  
union all select  38, 2,   20, null  
union all select  39, 2,   50, null  
union all select  40, 2,  150, null  
union all select  41, 2,   10, null  
union all select  42, 2,   10, null  
union all select  43, 2,   10, null  
union all select  44, 2,  100, null  
union all select  45, 2,  200, null  
union all select  46, 2,  300, null  
union all select  47, 2,  500, null  
union all select  48, 2, 1000, null  
union all select  49, 2, 2000, null  



--select * from [dbo].[ReturnCode]
insert into [dbo].[ReturnCode]
(ReturnCode, Message)
          select   1, 'Не достаточно комплектующих'
union all select   2, 'Заданный склад не найден'
union all select   3, 'Не достаточно ценностей для пермещения'
union all select   4, 'Не достаточно товара для продажи'
