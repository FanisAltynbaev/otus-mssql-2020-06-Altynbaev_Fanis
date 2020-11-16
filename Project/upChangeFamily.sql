use Apiary_OTUS
go

CREATE OR ALTER PROCEDURE upChangeFamily 
( @Date   datetime2 = null
, @MaterialID int
, @Count decimal(18,2)
, @StatusID_old int
, @StatusID_new int
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
	  @StorageID int,
	  @Qty decimal(18,2)

	select @RelationID = 0
	select top 1
	  @RelationID = r.RelationID,
	  @StorageID  = r.StorageID,
	  @Qty        = r.Qty       
	from Relation r 
	where r.MaterialID = @MaterialID
	  and r.StatusID  = @StatusID_old

    if (@RelationID = 0)
	begin
      ROLLBACK TRANSACTION MF;
      select @RetVal = 3
	  return @RetVal
	end

     -- заполняем свзи
    if (@RelationID > 0)
	begin
	  -- изменение  состояния
	  if (@StatusID_old != @StatusID_new)
      begin
        exec upChangeRelation
          @RetVal        = @RetVal
        , @MaterialID    = @MaterialID
        , @Date   	     = @Date   	  
        , @Count 		 = @Qty 		  
        , @StorageID_old = @StorageID
        , @StorageID_new = @StorageID
        , @StatusID_old  = @StatusID_old 
        , @StatusID_new  = @StatusID_new 

        if @RetVal > 0
	    begin
	      ROLLBACK TRANSACTION MF;
	      return @RetVal
        end
      end

	  -- изменяем поличество корпусов
      select @Qty = @Count - @Qty
	  if (@Qty != 0)
	  begin
	    update r
		set r.Qty  = @Count
		from Relation r
		where r.RelationID = @RelationID

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
        , @Date   	     = @Date   	  
        , @Count 		 = @Qty 		  
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

    end

  COMMIT TRANSACTION MF;

END

/*
declare @RetVal int
exec upChangeFamily 
  @RetVal = @RetVal
, @Date   = '20201115'
, @MaterialID  = 1014
, @StatusID_old = 23
, @StatusID_new = 22
select @RetVal
select Message from ReturnCode where ReturnCode = @RetVal
*/