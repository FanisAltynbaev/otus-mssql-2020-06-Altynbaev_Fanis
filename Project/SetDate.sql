use [Apiary_OTUS];
GO

/*��������� ���������� ������ */
--select * from [dbo].[Storage]
insert into [dbo].[Storage]
(Name)
select '����� 1' union all 
select '����� 2' union all 
select '������' 

-- select * from [dbo].[MaterialType]
insert into [dbo].[MaterialType]
(Name)
          select '������������� ����' 
union all select '������������� �����'
union all select '�����������' 
union all select '����' 
union all select '�����' 
union all select '������� ���������'

--delete [dbo].[Status]
--select * from [dbo].[Status]
insert into [dbo].[Status]
(Name)
          select '�����' 
union all select '�� ��������'
union all select '������������'
union all select '� �������'
union all select '����� ������'
union all select '����� �������������'
union all select '����� ��������'
union all select '����� �������'	 , 4
union all select '����� �������'	 , 4
union all select '����� ������'		 , 4

union all select '����� �����'       , 5
union all select '����� ����'        , 5
union all select '����� �������'     , 5
union all select '����� � ������'    , 5

--select * from [dbo].[Client]
insert into [dbo].[Client]
(FIO, Address, Phone)
select '������', '��. ������� 1',     '8-800-111-11-11' union all 
select '������', '��. ����������� 2', '8-800-222-22-22' union all 
select '�������','��. �������� 3',    '8-800-333-33-33'  


--select * from [dbo].[Material] order by MAterialID
insert into [dbo].[Material]
(MaterialTypeID, Name, StorageID, Qty, Date, Srok, StatusID)
          select 1, '�����'             , 1,  2, null, null, 18  
union all select 1, '�����'             , 1,  8, null, null, null  
union all select 1, '�����'             , 3, 10, null, null, 17  
union all select 1, '������'            , 1,  5, null, null, 18  
union all select 1, '������'            , 1, 45, null, null, null  
union all select 1, '������'            , 3, 10, null, null, 17  
union all select 1, '����������'        , 1, 10, null, null, null  
union all select 1, '����������'        , 3, 10, null, null, 17  
union all select 1, '������'            , 1, 10, null, null, null  
union all select 1, '������'            , 3, 10, null, null, 17  

union all select 2, '������� ������'    , 1, 150, null, null, 16  
union all select 2, '������ ������'     , 1, 200, null, null, 16  
union all select 2, '������� ������'    , 1, 200, null, null, 16  							        
								        
union all select 3, '���������'         , 1,  1, null, null, 17  
union all select 3, '������'            , 1,  1, null, null, 17  
union all select 3, '������'            , 1,  1, null, null, 17  
union all select 3, '�����'             , 1,  1, null, null, 16  
union all select 3, '�����'             , 1,  1, null, null, 17  

union all select 4, '����� 1'           , 3,  1, '20170501', 3, 24  
union all select 4, '����� 2'           , 3,  2, '20180501', 3, 23  
union all select 4, '����� 3'           , 3,  2, '20180501', 3, 23  
union all select 4, '����� 4'           , 3,  2, '20190501', 3, 22  
union all select 4, '����� 5'           , 3,  3, '20200501', 3, 22  

union all select 5, '����� �����'       , 1,100, null, null, null  
union all select 5, '����� ����'        , 1,100, null, null, null  
union all select 5, '����� �������'     , 1, 20, null, null, null  
union all select 5, '����� � ������'    , 3,100, null, null, null  

union all select 6, '̸� ���������'   , 2,   20, '20180801', 36,  null  
union all select 6, '̸� ���������'   , 2,   50, '20190801', 36,  null  
union all select 6, '̸� ���������'   , 2,  150, '20190801', 36,  null  
union all select 6, '̸� �������'     , 2,   20, '20180801', 36,  null  
union all select 6, '̸� �������'     , 2,   50, '20190801', 36,  null  
union all select 6, '̸� �������'     , 2,  150, '20200801', 36,  null  
union all select 6, '����'            , 2,   10, '20180801', 120, null  
union all select 6, '����'            , 2,   10, '20190801', 120, null  
union all select 6, '����'            , 2,   10, '20200801', 120, null  
union all select 6, '��������'        , 2,  100, '20180801', 24,  null  
union all select 6, '��������'        , 2,  200, '20190801', 24,  null  
union all select 6, '��������'        , 2,  300, '20200801', 24,  null  
union all select 6, '������'          , 2,  500, '20180801', 12,  null  
union all select 6, '������'          , 2, 1000, '20190801', 12,  null  
union all select 6, '������'          , 2, 2000, '20200801', 12,  null  


--delete Relation
--select * from [dbo].[Relation]
insert into [dbo].[Relation]
(MaterialID, StorageID, Qty, StatusID)
          select   3, 1,    2, 18  
union all select   3, 1,    8, null  
union all select   3, 3,   10, 17  
union all select   6, 1,    5, 18  
union all select   6, 1,   45, null  
union all select   6, 3,   10, 17  
union all select   9, 1,   10, null  
union all select   9, 3,   10, 17  
union all select  11, 1,   10, null  
union all select  11, 3,   10, 17  

union all select  13, 1,  150,  16  
union all select  14, 1,  200,  16  
union all select  15, 1,  200,  16  							        
						 		        
union all select  16, 1,   1, 17  
union all select  17, 1,   1, 17  
union all select  18, 1,   1, 17  
union all select  19, 1,   1, 16  
union all select  20, 1,   1, 17  
						 
union all select  21, 3,   1, 24  
union all select  22, 3,   2, 23  
union all select  23, 3,   2, 23  
union all select  24, 3,   2, 22  
union all select  25, 3,   3, 22  
						 
union all select  26, 1, 100, 1016  
union all select  26, 1, 100, 1017  
union all select  26, 1,  20, 1018  
union all select  26, 3, 100, 1019  

union all select  35, 2,   20, null  
union all select  36, 2,   50, null  
union all select  37, 2,  150, null  
union all select  38, 2,   20, null  
union all select  39, 2,   50, null  
union all select  40, 2,  150, null  
union all select  41, 2,   10, null  
union all select  42, 2,   10, null  
union all select  43, 2,   10, null  
union all select  44, 2,  100, null  
union all select  45, 2,  200, null  
union all select  46, 2,  300, null  
union all select  47, 2,  500, null  
union all select  48, 2, 1000, null  
union all select  49, 2, 2000, null  



--select * from [dbo].[ReturnCode]
insert into [dbo].[ReturnCode]
(ReturnCode, Message)
          select   1, '�� ���������� �������������'
union all select   2, '�������� ����� �� ������'
union all select   3, '�� ���������� ��������� ��� ����������'
union all select   4, '�� ���������� ������ ��� �������'
