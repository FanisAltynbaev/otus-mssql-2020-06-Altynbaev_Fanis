use Apiary_OTUS
go

CREATE OR ALTER PROCEDURE upDeleteFamily 
( @Date   datetime2 = null
, @MaterialID int
)
AS
BEGIN
  -- значения по умолчанию
  select @Date = isnull(@Date, GETDATE())

  -- Обновляем свзи
  BEGIN TRANSACTION MF;
    
	declare
	  @RetVal int,
	  @RelationID int,
	  @StorageID int,
	  @StatusID int,
	  @Qty decimal(18,2)

	select @RelationID = 0
	select top 1
	  @RelationID = r.RelationID,
	  @StorageID  = r.StorageID,
	  @StatusID   = r.StatusID,
	  @Qty        = r.Qty       
	from Relation r 
	where r.MaterialID = @MaterialID

    if (@RelationID = 0)-- or (@Qty =0)
	begin
      ROLLBACK TRANSACTION MF;
      select @RetVal = 3
	  return @RetVal
	end

     -- обновляем свзи
    if (@RelationID > 0)
	begin
	  -- удаление семьи
      delete r 
	  from Relation r
	  where r.RelationID = @RelationID

	  select @Qty = -@Qty
      exec upAddOperation
	       @RetVal        = @RetVal,
	       @OperationDate = @Date,
	       @MaterialID    = @MaterialID,
	       @StorageID     = @StorageID,
	       @StatusID      = @StatusID,
	       @Qty	          = @Qty
	  select @Qty = -@Qty


      -- разукомплектация
	  select top 1
	    @MaterialID = m.MaterialID
	  from [dbo].[Material] m
      join MaterialType mt 
	    on mt.MaterialTypeID = m.MaterialTypeID
       and mt.Name = 'Комплектующие улий'
	  where m.Name = 'Днище'

      exec upChangeRelation
        @RetVal        = @RetVal
      , @MaterialID    = @MaterialID
      , @Date   	   = @Date   	  
      , @Count 		   = 1 		  
      , @StorageID_old = @StorageID
      , @StorageID_new = @StorageID
      , @StatusID_old  = 17 
      , @StatusID_new  = 25 

      if @RetVal > 0
	  begin
	    ROLLBACK TRANSACTION MF;
	    return @RetVal
	  end

	  select top 1
	    @MaterialID = m.MaterialID
	  from [dbo].[Material] m
      join MaterialType mt 
	    on mt.MaterialTypeID = m.MaterialTypeID
       and mt.Name = 'Комплектующие улий'
	  where m.Name = 'Корпус'

      exec upChangeRelation
        @RetVal        = @RetVal
      , @MaterialID    = @MaterialID
      , @Date   	   = @Date   	  
      , @Count 		   = @Qty 		  
      , @StorageID_old = @StorageID
      , @StorageID_new = @StorageID
      , @StatusID_old  = 17 
      , @StatusID_new  = 25 


      if @RetVal > 0
	  begin
	    ROLLBACK TRANSACTION MF;
	    return @RetVal
	  end

	  select top 1
	    @MaterialID = m.MaterialID
	  from [dbo].[Material] m
      join MaterialType mt 
	    on mt.MaterialTypeID = m.MaterialTypeID
       and mt.Name = 'Комплектующие улий'
	  where m.Name = 'Подкрышник'

      exec upChangeRelation
        @RetVal        = @RetVal
      , @MaterialID    = @MaterialID
      , @Date   	   = @Date   	  
      , @Count 		   = 1 		  
      , @StorageID_old = @StorageID
      , @StorageID_new = @StorageID
      , @StatusID_old  = 17 
      , @StatusID_new  = 25 

      if @RetVal > 0
	  begin
	    ROLLBACK TRANSACTION MF;
	    return @RetVal
	  end

	  select top 1
	    @MaterialID = m.MaterialID
	  from [dbo].[Material] m
      join MaterialType mt 
	    on mt.MaterialTypeID = m.MaterialTypeID
       and mt.Name = 'Комплектующие улий'
	  where m.Name = 'Крышка'

      exec upChangeRelation
        @RetVal        = @RetVal
      , @MaterialID    = @MaterialID
      , @Date   	   = @Date   	  
      , @Count 		   = 1 		  
      , @StorageID_old = @StorageID
      , @StorageID_new = @StorageID
      , @StatusID_old  = 17 
      , @StatusID_new  = 25 

      if @RetVal > 0
	  begin
	    ROLLBACK TRANSACTION MF;
	    return @RetVal
	  end

    end

  COMMIT TRANSACTION MF;
  return 0
END

/*
declare @RetVal int
exec upDeleteFamily 
  @RetVal = @RetVal
, @Date   = '20201116'
, @MaterialID  = 1013
select @RetVal
select Message from ReturnCode where ReturnCode = @RetVal
*/
