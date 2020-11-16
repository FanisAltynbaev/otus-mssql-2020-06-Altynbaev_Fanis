use Apiary_OTUS
go

/* ��� ��� �������� ������ */
select m.MaterialID
     , m.Name
     , mt.Name as Type
     , s.Name as Storage
     , Qty
     , Date
     , Srok
     , st.Name as Status
from Material m
join MaterialType mt on mt.MaterialTypeID = m.MaterialTypeID
join Storage s on s.StorageID = m.StorageID
left join Status st on st.StatusID = m.StatusID
where m.StorageID = 3


/* ������� ������ �� ������������� */
select m.Name
     , mt.Name as Type
     , s.Name as Storage
     , Qty
     , Date
     , Srok
     , st.Name as Status
from Material m
join MaterialType mt on mt.MaterialTypeID = m.MaterialTypeID
join Storage s on s.StorageID = m.StorageID
left join Status st on st.StatusID = m.StatusID
where mt.MaterialTypeID in (1,2)


/* �� ������������ ������������� ��� ����� */
select m.MaterialID
     , m.Name
     , mt.Name as Type
     , s.Name as Storage
     , Qty
     , Date
     , Srok
     , st.Name as Status
from Material m
join MaterialType mt on mt.MaterialTypeID = m.MaterialTypeID
join Storage s on s.StorageID = m.StorageID
left join Status st on st.StatusID = m.StatusID
where mt.MaterialTypeID = 1 
  and m.StatusID = 25
--group by 
