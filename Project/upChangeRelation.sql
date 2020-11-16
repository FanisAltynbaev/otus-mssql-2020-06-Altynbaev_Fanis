use Apiary_OTUS
go

CREATE OR ALTER PROCEDURE upChangeRelation 
( @RetVAl int out
, @MaterialID int
, @Date   datetime2
, @Count int = 0
, @StorageID_old int
, @StorageID_new int
, @StatusID_old int
, @StatusID_new int
)
AS
BEGIN

  -- �������� ������
  if not exists (select 1 
                 from Storage s
                 where s.StorageID = isnull(@StorageID_old, 0)
                )
  begin
    select @RetVAl = 2
	return @RetVAl
  end

  if not exists (select 1 
                 from Storage s
                 where s.StorageID = isnull(@StorageID_new, 0)
                )
  begin
    select @RetVAl = 2
	return @RetVAl
  end

  -- �������� �������
  begin

	declare @RelationID int,
	        @Qty  decimal(18,2)

	-- ���� �� ����� ����������?
	select @RelationID = 0, @Qty = 0
	select @RelationID = r.RelationID, 
		   @Qty        = r.Qty
    from Relation r
    where r.MaterialID = @MaterialID
	  and r.StorageID = @StorageID_old
	  and r.StatusID = @StatusID_old
	  and r.Qty > 0

	-- -- ���� �� �������, �� ������� �� ������
    if (@RelationID = 0) or (@Qty < @Count)
	begin
      select @RetVAl = 3
	  return @RetVAl
	end

    -- -- ����� ��������� ������� �������������
	else
	begin
	  if (@Qty = @Count)
        delete r 
	    from Relation r
	    where r.RelationID = @RelationID
	  else
        update r 
	    set Qty = @Qty-@Count
	    from Relation r
	    where r.RelationID = @RelationID

	  select @Qty = -@Count
      exec upAddOperation
	       @RetVal        = @RetVal,
	       @OperationDate = @Date,
	       @MaterialID    = @MaterialID,
	       @StorageID     = @StorageID_old,
	       @StatusID      = @StatusID_old,
	       @Qty	          = @Qty
    end

	-- ���������� �� ����� �����
	select @RelationID = 0, @Qty = 0
	select @RelationID = r.RelationID, 
		   @Qty        = r.Qty
    from Relation r
    where r.MaterialID = @MaterialID
	  and r.StorageID = @StorageID_new
	  and r.StatusID = @StatusID_new

	-- -- ��������� �� ����. ���������
    if (@RelationID = 0)
	begin
	  insert into [dbo].[Relation]
	  ( MaterialID
	  , StorageID
	  , StatusID
	  , Qty
	  )
	  select 
	    @MaterialID
	  , @StorageID_new
	  , @StatusID_new
	  , @Count
 	end
	-- -- �������� ����. ���������
	else
	begin
      update r 
	  set Qty = @Qty + @Count
	  from Relation r
	  where r.RelationID = @RelationID
    end

	select @Qty = @Count
    exec upAddOperation
	     @RetVal        = @RetVal,
	     @OperationDate = @Date,
	     @MaterialID    = @MaterialID,
	     @StorageID     = @StorageID_new,
	     @StatusID      = @StatusID_new,
	     @Qty	        = @Qty

  end

END
GO

