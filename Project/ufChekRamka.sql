use Apiary_OTUS
go

CREATE OR ALTER FUNCTION ufChekRamka (
   @StorageID int = 0,
   @Count     int
  )
  RETURNS int 
AS
BEGIN
  declare @Qty decimal(18,2)
  select @Qty = min(r.Qty)
  from [dbo].[Material] as m
  join MaterialType mt on mt.MaterialTypeID = m.MaterialTypeID
    and mt.Name = 'Комплектующие рамка'
  join Relation r on r.MaterialID = m.MaterialID
  where (@StorageID = 0 or r.StorageID = @StorageID) 

  select @Qty = isnull(@Qty, 0)

  if (@Qty < @Count)
    return 1
  else
    return 0

  return 0

END;
GO


