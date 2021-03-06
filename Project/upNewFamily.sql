USE [Apiary_OTUS]
GO
/****** Object:  StoredProcedure [dbo].[upNewFamily]    Script Date: 15.11.2020 23:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[upNewFamily] 
( @RetVAl int out
, @Name  nvarchar(250) = 'Семья ХХХ'
, @Count int		= null
, @StorageID int	= null
, @Date   datetime2	= null
, @Srok   int		= null
, @StatusID int     = null
)
AS
BEGIN
  -- значения по умолчанию
  select 
    @Name       = isnull(@Name, 'Семья ХХХ'),
    @Count 		= isnull(@Count, 1), 		
    @Date   	= isnull(@Date, GETDATE()),   	
    @Srok   	= isnull(@Srok, 2),   	
    @StatusID   = isnull(@StatusID, 23)  
  
  declare @Qty  decimal(18,2)

  -- Проверка склада
  if not exists (select 1 
                 from Storage s
                 where s.StorageID = isnull(@StorageID, 0)
                )
  begin
    select @RetVAl = 2
	return @RetVAl
  end

  select @RetVAl = [dbo].[ufChekFamily](@StorageID, @Count)

  if @RetVal > 0
  begin
	return @RetVAl 
  end
  else
  begin
    BEGIN TRANSACTION NF;
    
	declare @RelationID int,
	        @MaterialID int

	select @RelationID = 0, 
		   @Qty        = 0

    -- добавляем семью в список материалов
	insert into [dbo].[Material]
	(   MaterialTypeID
	  , Name 
      , Date 
      , Srok 
	)
	select 
	  4
	, cast(@@SPID as varchar) + '_' + @Name
	, @Date
	, @Srok

    -- заполняем свзи
    select @MaterialID = MaterialID
    from Material m
    where m.Name = cast(@@SPID as varchar) + '_' + @Name 

    if (@MaterialID > 0)
	begin

      update m
	  set Name = REPLACE(m.Name, cast(@@SPID as varchar) + '_', '')
	  from Material m 
	  where m.MaterialID = @MaterialID

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
	  , @StatusID

      exec upAddOperation
	       @RetVal        = @RetVal,
		   @OperationDate = @Date,
	       @MaterialID    = @MaterialID,
	       @StorageID     = @StorageID,
	       @Qty		      = @Count,
	       @StatusID      = @StatusID

      -- перемещение комплектующих
	  select top 1
	    @MaterialID = m.MaterialID
	  from [dbo].[Material] m
      join MaterialType mt 
	    on mt.MaterialTypeID = m.MaterialTypeID
       and mt.Name = 'Комплектующие улий'
	  where m.Name = 'Днище'

      exec upChangeRelation
        @RetVAl        = @RetVAl
      , @MaterialID    = @MaterialID
      , @Date   	   = @Date   	  
      , @Count 		   = 1 		  
      , @StorageID_old = @StorageID
      , @StorageID_new = @StorageID
      , @StatusID_old  = 25 
      , @StatusID_new  = 17 

      if @RetVAl > 0
	  begin
	    ROLLBACK TRANSACTION NF;
	    return @RetVAl
	  end

	  select top 1
	    @MaterialID = m.MaterialID
	  from [dbo].[Material] m
      join MaterialType mt 
	    on mt.MaterialTypeID = m.MaterialTypeID
       and mt.Name = 'Комплектующие улий'
	  where m.Name = 'Корпус'

      exec upChangeRelation
        @RetVAl        = @RetVAl
      , @MaterialID    = @MaterialID
      , @Date   	   = @Date   	  
      , @Count 		   = @Count 		  
      , @StorageID_old = @StorageID
      , @StorageID_new = @StorageID
      , @StatusID_old  = 25 
      , @StatusID_new  = 17 

      if @RetVAl > 0
	  begin
	    ROLLBACK TRANSACTION NF;
	    return @RetVAl
	  end
	  select top 1
	    @MaterialID = m.MaterialID
	  from [dbo].[Material] m
      join MaterialType mt 
	    on mt.MaterialTypeID = m.MaterialTypeID
       and mt.Name = 'Комплектующие улий'
	  where m.Name = 'Подкрышник'

      exec upChangeRelation
        @RetVAl        = @RetVAl
      , @MaterialID    = @MaterialID
      , @Date   	   = @Date   	  
      , @Count 		   = 1 		  
      , @StorageID_old = @StorageID
      , @StorageID_new = @StorageID
      , @StatusID_old  = 25 
      , @StatusID_new  = 17 

      if @RetVAl > 0
	  begin
	    ROLLBACK TRANSACTION NF;
	    return @RetVAl
	  end
	  select top 1
	    @MaterialID = m.MaterialID
	  from [dbo].[Material] m
      join MaterialType mt 
	    on mt.MaterialTypeID = m.MaterialTypeID
       and mt.Name = 'Комплектующие улий'
	  where m.Name = 'Крышка'

      exec upChangeRelation
        @RetVAl        = @RetVAl
      , @MaterialID    = @MaterialID
      , @Date   	   = @Date   	  
      , @Count 		   = 1 		  
      , @StorageID_old = @StorageID
      , @StorageID_new = @StorageID
      , @StatusID_old  = 25 
      , @StatusID_new  = 17 

      if @RetVAl > 0
	  begin
	    ROLLBACK TRANSACTION NF;
	    return @RetVAl
	  end

    end

	COMMIT TRANSACTION NF;
  end

END
