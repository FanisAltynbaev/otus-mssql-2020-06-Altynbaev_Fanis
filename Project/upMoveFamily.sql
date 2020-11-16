use Apiary_OTUS
go

CREATE OR ALTER PROCEDURE upMoveFamily 
( @Date   datetime2 = null
, @MaterialID int
, @StorageID_old int
, @StorageID_new int
)
AS
BEGIN
  declare @RetVal int
  -- значения по умолчанию
  select @Date = isnull(@Date, GETDATE())

  -- Обновляем свзи
  BEGIN TRANSACTION MF;
    
	declare
	  @RelationID int,
	  @StatusID int,
	  @Qty decimal(18,2)

	select @RelationID = 0
	select top 1
	  @RelationID = r.RelationID,
	  @StatusID   = r.StatusID,
	  @Qty        = r.Qty       
	from Relation r 
	where r.MaterialID = @MaterialID
	  and r.StorageID  = @StorageID_old

    if (@RelationID = 0)-- or (@Qty =0)
	begin
      ROLLBACK TRANSACTION MF;
      select @RetVal = 3
	  return @RetVal
	end

     -- заполняем свзи
    if (@RelationID > 0)
	begin
	  -- перемещение семьи
      /*
	  update m
	  set r.StorageID = @StorageID_new
	  from Relation r 
	  where r.MaterialID = @MaterialID
	  */
      exec upChangeRelation
        @RetVal        = @RetVal
      , @MaterialID    = @MaterialID
      , @Date   	   = @Date   	  
      , @Count 		   = @Qty 		  
      , @StorageID_old = @StorageID_old
      , @StorageID_new = @StorageID_new
      , @StatusID_old  = @StatusID 
      , @StatusID_new  = @StatusID 

      -- перемещение комплектующих
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
      , @StorageID_old = @StorageID_old
      , @StorageID_new = @StorageID_new
      , @StatusID_old  = 17 
      , @StatusID_new  = 17 

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
      , @StorageID_old = @StorageID_old
      , @StorageID_new = @StorageID_new
      , @StatusID_old  = 17 
      , @StatusID_new  = 17 

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
      , @StorageID_old = @StorageID_old
      , @StorageID_new = @StorageID_new
      , @StatusID_old  = 17 
      , @StatusID_new  = 17 

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
      , @StorageID_old = @StorageID_old
      , @StorageID_new = @StorageID_new
      , @StatusID_old  = 17 
      , @StatusID_new  = 17 

      if @RetVal > 0
	  begin
	    ROLLBACK TRANSACTION MF;
	    return @RetVal
	  end

    end

  COMMIT TRANSACTION MF;

END

/*
declare @RetVal int
exec upMoveFamily 
  @RetVal = @RetVal
--, @Date   datetime2 = null
, @MaterialID  = 1012
, @StorageID_old = 3
, @StorageID_new = 1
select @RetVal
select Message from ReturnCode where ReturnCode = @RetVal
*/
