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

  -- �������� ������������� �������������
  -- 3 �����
  select @Qty = 0
  select @Qty = r.Qty
    from [dbo].[Material] as m
    join MaterialType mt 
      on mt.MaterialTypeID = m.MaterialTypeID
     and mt.Name = '������������� ����'
    join Relation r 
      on r.MaterialID = m.MaterialID
     and r.StatusID = 25 
    where (@StorageID = 0 or r.StorageID = @StorageID)
      and m.Name = '�����'
 
  if isnull(@Qty, 0) < 1 
  begin
	return 1
  end

  --6 ������
  select @Qty = 0
  select @Qty = r.Qty
    from [dbo].[Material] as m
    join MaterialType mt 
      on mt.MaterialTypeID = m.MaterialTypeID
     and mt.Name = '������������� ����'
    join Relation r 
      on r.MaterialID = m.MaterialID
     and r.StatusID = 25 
    where (@StorageID = 0 or r.StorageID = @StorageID)
      and m.Name = '������'
 
  if isnull(@Qty, 0) < @Count 
  begin
	return 1
  end

  --9	����������
  select @Qty = 0
  select @Qty = r.Qty
    from [dbo].[Material] as m
    join MaterialType mt 
      on mt.MaterialTypeID = m.MaterialTypeID
     and mt.Name = '������������� ����'
    join Relation r 
      on r.MaterialID = m.MaterialID
     and r.StatusID = 25 
    where (@StorageID = 0 or r.StorageID = @StorageID)
      and m.Name = '����������'
 
  if isnull(@Qty, 0) < 1 
  begin
	return 1
  end

  --11	������
  select @Qty = 0
  select @Qty = r.Qty
    from [dbo].[Material] as m
    join MaterialType mt 
      on mt.MaterialTypeID = m.MaterialTypeID
     and mt.Name = '������������� ����'
    join Relation r 
      on r.MaterialID = m.MaterialID
     and r.StatusID = 25 
    where (@StorageID = 0 or r.StorageID = @StorageID)
      and m.Name = '������'
 
  if isnull(@Qty, 0) < 1 
  begin
	return 1
  end 

  return 0

END;
GO


