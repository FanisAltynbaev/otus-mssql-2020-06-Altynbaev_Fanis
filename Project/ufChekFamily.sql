use Apiary_OTUS
go

CREATE OR ALTER FUNCTION ufChekFamily (
   @StorageID int = 0,
   @Count     int = 1
  )
  RETURNS int 
AS
BEGIN
  declare @Qty decimal(18,2)

  -- Проверка достаточности комплектующих
  -- 3 Днище
  select @Qty = 0
  select @Qty = r.Qty
    from [dbo].[Material] as m
    join MaterialType mt 
      on mt.MaterialTypeID = m.MaterialTypeID
     and mt.Name = 'Комплектующие улий'
    join Relation r 
      on r.MaterialID = m.MaterialID
     and r.StatusID = 25 
    where (@StorageID = 0 or r.StorageID = @StorageID)
      and m.Name = 'Днище'
 
  if isnull(@Qty, 0) < 1 
  begin
	return 1
  end

  --6 Корпус
  select @Qty = 0
  select @Qty = r.Qty
    from [dbo].[Material] as m
    join MaterialType mt 
      on mt.MaterialTypeID = m.MaterialTypeID
     and mt.Name = 'Комплектующие улий'
    join Relation r 
      on r.MaterialID = m.MaterialID
     and r.StatusID = 25 
    where (@StorageID = 0 or r.StorageID = @StorageID)
      and m.Name = 'Корпус'
 
  if isnull(@Qty, 0) < @Count 
  begin
	return 1
  end

  --9	Подкрышник
  select @Qty = 0
  select @Qty = r.Qty
    from [dbo].[Material] as m
    join MaterialType mt 
      on mt.MaterialTypeID = m.MaterialTypeID
     and mt.Name = 'Комплектующие улий'
    join Relation r 
      on r.MaterialID = m.MaterialID
     and r.StatusID = 25 
    where (@StorageID = 0 or r.StorageID = @StorageID)
      and m.Name = 'Подкрышник'
 
  if isnull(@Qty, 0) < 1 
  begin
	return 1
  end

  --11	Крышка
  select @Qty = 0
  select @Qty = r.Qty
    from [dbo].[Material] as m
    join MaterialType mt 
      on mt.MaterialTypeID = m.MaterialTypeID
     and mt.Name = 'Комплектующие улий'
    join Relation r 
      on r.MaterialID = m.MaterialID
     and r.StatusID = 25 
    where (@StorageID = 0 or r.StorageID = @StorageID)
      and m.Name = 'Крышка'
 
  if isnull(@Qty, 0) < 1 
  begin
	return 1
  end 

  return 0

END;
GO


