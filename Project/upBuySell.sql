use Apiary_OTUS
go

CREATE OR ALTER PROCEDURE upBuySell 
( @Date   datetime2 = null
, @MaterialID int
, @ClientID int = null
, @Count decimal(18,2) -- @Count > 0 покупка, @Count < 0 продажа
, @Price decimal(18,2) = null
, @Summa decimal(18,2) = null
, @StorageID int
, @StatusID int = null
)
AS
BEGIN
  -- значения по умолчанию
  select @Date = isnull(@Date, GETDATE())

  -- Обновляем свзи
  BEGIN TRANSACTION BS;
    
	declare
	  @RetVal int,
      @RelationID int,
	  @Qty decimal(18,2)


    if (@Count > 0) -- покупка
	begin
	  -- есть ли товар?
	  select @RelationID = 0, @Qty = 0
	  select @RelationID = r.RelationID, 
	  	     @Qty        = r.Qty
      from Relation r
      where r.MaterialID = @MaterialID
	    and r.StorageID = @StorageID
	    and r.StatusID = @StatusID

	  -- -- если нет, добавляем
      if (@RelationID = 0) 
	  begin
	    insert into [dbo].Relation
	    (MaterialID
	    ,StorageID
	    ,Qty
	    ,StatusID
	    )
	    select 
	       @MaterialID
	     , @StorageID
	     , @Count
	     , @StatusID
	  end
      -- -- иначе увеличиваем остаток
	  else
	  begin
        update r 
	    set Qty = @Qty+@Count
	    from Relation r
	    where r.RelationID = @RelationID
      end
    end

    if (@Count < 0) -- продажа
	begin
	  -- есть ли товар?
	  select @RelationID = 0, @Qty = 0
	  select @RelationID = r.RelationID, 
	  	     @Qty        = r.Qty
      from Relation r
      where r.MaterialID = @MaterialID
	    and r.StorageID = @StorageID
	    and r.StatusID = @StatusID

 	  -- -- если не хватает, то выходим по ошибке
      if (@RelationID = 0) or (@Qty < @Count)
	  begin
	    ROLLBACK TRANSACTION BS;
        select @RetVAl = 4
	    return @RetVAl
	  end
	  -- -- иначе, уменьшаем остаток
	  else
	  begin
	    if (@Qty = @Count)
          delete r 
	      from Relation r
	      where r.RelationID = @RelationID
	    else
          update r 
	      set Qty = @Qty+@Count
	      from Relation r
	      where r.RelationID = @RelationID
	  end
    end

    if (@Price is null) and (@Summa is not null)
    begin
     select @Summa = -abs(@Summa)*(@Count/abs(@Count))
     select @Price = abs(@Summa / @Count)
    end
   
    if (@Price is not null) and (@Summa is null)
    begin
      select @Price = abs(@Price)
      select @Summa = -@Price * @Count
    end

    exec upAddOperation
      @RetVal        = @RetVal,
      @OperationDate = @Date,
	  @ClientID      = @ClientID,
      @MaterialID    = @MaterialID,
      @Qty		     = @Count,
      @Price         = @Price,
      @Summa         = @Summa,
      @StatusID      = @StatusID,
      @StorageID     = @StorageID

  COMMIT TRANSACTION BS;

END

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
