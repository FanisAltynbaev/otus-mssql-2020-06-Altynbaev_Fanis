select * from [dbo].[Client]
select * from [dbo].[Material]
select * from [dbo].[MaterialType]
select * from [dbo].[Operation]
select * from [dbo].[Relation]  
select * from [dbo].[ReturnCode]
select * from [dbo].[Status]
select * from [dbo].[Storage]


/*****   данные по рамкам   *****/
select m.MaterialID, m.Name, r.Qty, st.Name, s.Name, mt.Name
from [dbo].[Relation] r
join [dbo].[Material] m
  on m.MaterialID = r.MaterialID
join [dbo].[MaterialType] mt
  on mt.MaterialTypeID = m.MaterialTypeID
 and mt.MaterialTypeID in (2, 5) 
join Status s on s.StatusID = r.StatusID
join Storage st on st.StorageID = r.StorageID
/*
declare @RetVal int
exec [dbo].[upMakeRamka] 
     @RetVal out
   , @Date = '20201001'
   , @StorageID = 1
   , @Count = 1
select Message from ReturnCode where ReturnCode = @RetVal

declare @RetVal int
exec [dbo].[upChangeRelation] 
     @RetVal out
   , @Date = '20201117'
   , @MaterialID = 26
   , @Count = 1
   , @StorageID_old = 1
   , @StorageID_new = 3
   , @StatusID_old = 1016
   , @StatusID_new = 1019
select Message from ReturnCode where ReturnCode = @RetVal
*/


/*****   данные по ульям   *****/
select m.MaterialID, m.Name, r.Qty, st.Name, s.Name, mt.Name
from [dbo].[Relation] r
join [dbo].[Material] m
  on m.MaterialID = r.MaterialID
join [dbo].[MaterialType] mt
  on mt.MaterialTypeID = m.MaterialTypeID
 and mt.MaterialTypeID in (1, 4) 
join Status s on s.StatusID = r.StatusID
join Storage st on st.StorageID = r.StorageID

/*
declare @RetVal int
exec [dbo].[upNewFamily] 
     @RetVal out
   , @Name = 'Семья 3.14'
   , @Count = 2
   , @StorageID = 1   
   , @Date = '20200509'
   , @Srok = 2
   , @StatusID = 23
select Message from ReturnCode where ReturnCode = @RetVal

declare @RetVal int
exec @RetVal = [dbo].[upMoveFamily]
     @Date = '20200510'
   , @MaterialID = 1015
   , @StorageID_old = 3
   , @StorageID_new = 1
select Message from ReturnCode where ReturnCode = @RetVal

declare @RetVal int
exec @RetVal = [dbo].[upChangeFamily]
     @Date = '20200510'
   , @MaterialID = 1015
   , @Count = 1
   , @StatusID_old = 24
   , @StatusID_new = 24
select Message from ReturnCode where ReturnCode = @RetVal

declare @RetVal int
exec @RetVal = upDeleteFamily 
  @Date   = '20201116'
, @MaterialID  = 1015
select Message from ReturnCode where ReturnCode = @RetVal
*/

/*****   данные по Покупкам/Продажам   *****/
select o.OperationID, o.OperationDate, m.MaterialID, m.Name, o.Qty, o.Price, o.Summa, cl.FIO
from [dbo].[Operation] o
left join [dbo].[Client] cl
  on cl.ClientID = o.ClientID
join [dbo].[Material] m
  on m.MaterialID = o.MaterialID
join [dbo].[MaterialType] mt
  on mt.MaterialTypeID = m.MaterialTypeID
 and mt.MaterialTypeID not in (1, 2, 4, 5) 
left join Status s on s.StatusID = o.StatusID
left join Storage st on st.StorageID = o.StorageID

/*
declare @RetVal int
exec [dbo].[upBuySell] 
  @RetVal     = @RetVal
, @Date       = '20200601'
, @MaterialID = 17
, @ClientID   = 3
, @Count      = 1
, @Price      = 500
--, @Summa      = n
, @StorageID  = 1
select @RetVal
select Message from ReturnCode where ReturnCode = @RetVal
*/