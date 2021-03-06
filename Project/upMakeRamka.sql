USE [Apiary_OTUS]
GO
/****** Object:  StoredProcedure [dbo].[upMakeRamka]    Script Date: 15.11.2020 20:12:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[upMakeRamka] 
( @RetVal int out
, @Date datetime2
, @Count int
, @StorageID int
)
AS
BEGIN
  
  -- Проверка склада
  if not exists (select 1 
                 from Storage s
                 where s.StorageID = isnull(@StorageID, 0)
                )
  begin
    select @RetVAl = 2
	return @RetVAl
  end

  -- Проверка достаточности комплектующих
  select @RetVAl = [dbo].[ufChekRamka](@StorageID, @Count)
  if @RetVAl > 0
  begin
	return @RetVAl
  end
  else
  begin
    BEGIN TRANSACTION MR;
    
	declare @RelationID int,
	        @MaterialID int,
			@StatusID   int,
			@Qty        decimal (18,2)

	select @RelationID = 0,
	       @MaterialID = 0, 
		   @Qty        = 0

	-- добавляем запись если их небыло на складе или увеличиваем количество если были  
	select top 1
	  @RelationID = r.RelationID,
	  @MaterialID = m.MaterialID,
	  @Qty        = r.Qty + @Count 
	from [dbo].[Material] m
	join [dbo].[Relation] r on r.MaterialID = m.MaterialID
	                       and r.StorageID = @StorageID
	                       and r.StatusID = 1016 -- Новая
	where m.MaterialTypeID  = 5 -- Рамки
    
	if (@RelationID = 0)
	  insert into [dbo].[Relation]
	  ( MaterialID
	  , StorageID
	  , Qty
	  , StatusID
	  )
	  select 
	    @MaterialID
	  , @StorageID
	  , @Count
	  , 1016
    else
	begin
	  update r 
	  set Qty = @Qty
	  from Relation r
	  where r.RelationID = @RelationID

      exec upAddOperation
	       @RetVal        = @RetVal,
		   @OperationDate = @Date,
	       @MaterialID    = @MaterialID,
	       @StorageID     = @StorageID,
	       @Qty		      = @Count,
	       @StatusID      = 1016
	end     

    -- уменьшаем остаток комплектующих
	-- 'Верхняя планка'
	select @RelationID = 0,
		   @Qty        = 0 
	select top 1 
	  @MaterialID = m.MaterialID,
      @StatusID   = r.StatusID,
	  @RelationID = r.RelationID,
	  @Qty        = r.Qty - @Count 
	from [dbo].[Material] m
	join [dbo].[Relation] r on r.MaterialID = m.MaterialID
	                       and r.StorageID = @StorageID
	where m.MaterialTypeID  = 2 -- Комплектующие рамка
	  and m.Name = 'Верхняя планка'

	if (@RelationID > 0)
	begin
	  update r 
	  set Qty = @Qty
	  from Relation r
	  where r.RelationID = @RelationID

	  select @Qty = -@Count
      exec upAddOperation
	       @RetVal        = @RetVal,
		   @OperationDate = @Date,
	       @MaterialID     = @MaterialID,
	       @StorageID      = @StorageID,
	       @Qty	           = @Qty
    end

    -- 'Нижняя планка'
	select @RelationID = 0,
		   @Qty        = 0
	select top 1 
	  @MaterialID = m.MaterialID,
      @StatusID   = r.StatusID,
	  @RelationID = r.RelationID,
	  @Qty        = r.Qty - @Count 
	from [dbo].[Material] m
	join [dbo].[Relation] r on r.MaterialID = m.MaterialID
	                       and r.StorageID = @StorageID
	where m.MaterialTypeID  = 2 -- Комплектующие рамка
	  and m.Name = 'Нижняя планка'

	if (@RelationID > 0)
	begin
	  update r 
	  set Qty = @Qty
	  from Relation r
	  where r.RelationID = @RelationID

	  select @Qty = -@Count
      exec upAddOperation
	       @RetVal        = @RetVal,
		   @OperationDate = @Date,
	       @MaterialID    = @MaterialID,
	       @StorageID     = @StorageID,
	       @Qty	          = @Qty
    end
	
	-- 'Боковая планка'
	select @RelationID = 0,
		   @Qty        = 0
	select top 1 
	  @MaterialID = m.MaterialID,
      @StatusID   = r.StatusID,
	  @RelationID = r.RelationID,
	  @Qty        = r.Qty - @Count 
	from [dbo].[Material] m
	join [dbo].[Relation] r on r.MaterialID = m.MaterialID
	                       and r.StorageID = @StorageID
	where m.MaterialTypeID  = 2 -- Комплектующие рамка
	  and m.Name = 'Боковая планка'

	if (@RelationID > 0)
	begin
	  update r 
	  set Qty = @Qty
	  from Relation r
	  where r.RelationID = @RelationID

	  select @Qty = -@Count
      exec upAddOperation
	       @RetVal        = @RetVal,
		   @OperationDate = @Date,
	       @MaterialID    = @MaterialID,
	       @StorageID     = @StorageID,
	       @Qty	          = @Qty
    end

	COMMIT TRANSACTION MR;
  end

  return @RetVal
END
/*
declare @RetVal int
exec [dbo].[upMakeRamka] 
     @RetVal out
   , @StorageID = 1
   , @Count = 3

select Message from ReturnCode where ReturnCode = @RetVal
*/