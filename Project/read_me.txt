������ - ������

����� ��������� ��� �������� �����:
1. ������������ - ���� ������������� ���������: ����, �����, ���������. ��� �� ����� � �����������, ��� � ������� �� ������, ��������� ����� �������� ����� � �.�.
2. ���������� - ��� ��������� ����������, ������, � �.�.

/*----------------*/
   1.������������
/*----------------*/
1.1 �������  Material
������������� ��� �������� ���������� �� ���� ������������ ��������� ������ �� ����������, ���������, ���� ��������
��� ����� 
 - ��������� ������������ � ������: ���������, ��������, �����, �����, � �.�
 - ������������� ��� �����: ���, ������, ������, �������� 
 - ����� ��� ������������ ��� � ������������� ��� ����� (�������/������ ������, ���������)
 - ������� ��������� ��, ����, �������� � �.�.
�������� ����� �������� ��� ������ �������� ������� ��������� �������, �� �� ���� �������������. ����������� ������������ �� MaterialType

Column_name	Type	Computed	Length	Prec	Scale	Nullable	TrimTrailingBlanks	FixedLenNullInSource	Collation
MaterialID	int	no	4	10   	0    	no	(n/a)	(n/a)	NULL
MaterialType	int	no	4	10   	0    	yes	(n/a)	(n/a)	NULL
Name	varchar	no	250	     	     	yes	no	yes	Cyrillic_General_CI_AS
Storage	int	no	4	10   	0    	yes	(n/a)	(n/a)	NULL
Rest	decimal	no	9	18   	2    	yes	(n/a)	(n/a)	NULL


1.2 ������� MaterialType
������������� ��� ����������� ������������ ���������: ���������, ������� ����������. ������������� � �.�.

Column_name	Type	Computed	Length	Prec	Scale	Nullable	TrimTrailingBlanks	FixedLenNullInSource	Collation
MaterialTypeID	int	no	4	10   	0    	no	(n/a)	(n/a)	NULL
Name	varchar	no	250	     	     	yes	no	yes	Cyrillic_General_CI_AS


/*--------------*/
   2. ����������
/*--------------*/
2.1 ������� Client
������ ��������� ����������� � �����������, �� ������ � ��������.
Column_name	Type	Computed	Length	Prec	Scale	Nullable	TrimTrailingBlanks	FixedLenNullInSource	Collation
ClientID	int	no	4	10   	0    	no	(n/a)	(n/a)	NULL
FIO	varchar	no	50	     	     	yes	no	yes	Cyrillic_General_CI_AS
Address	varchar	no	250	     	     	yes	no	yes	Cyrillic_General_CI_AS
Phone	varchar	no	25	     	     	yes	no	yes	Cyrillic_General_CI_AS

2.2 ������� Orders
������� �������.
� ���������������� ���������� ����� �������.
�������������� ������� 
 - ���������� �� ���������� ������� ���������: ��������, �����, ����, ������ ������ ������/������������/��������. ���� > 0 
 - ������� �������� (������������ ������������, ���������, ����): ��������, �����, ����, ������ ��������/�������/��������. ���� < 0
 - �������������� ������ ��� ����� ������ ���������� �������: ������� �� ��������, �����/����� �� �������, ����� � � �����. ���� = 0


Column_name	Type	Computed	Length	Prec	Scale	Nullable	TrimTrailingBlanks	FixedLenNullInSource	Collation
OrderID	int	no	4	10   	0    	no	(n/a)	(n/a)	NULL
OrderDate	datetime	no	8	     	     	yes	(n/a)	(n/a)	NULL
Client	int	no	4	10   	0    	yes	(n/a)	(n/a)	NULL
Material	int	no	4	10   	0    	yes	(n/a)	(n/a)	NULL
Quantity	decimal	no	9	18   	2    	yes	(n/a)	(n/a)	NULL
Price	decimal	no	9	18   	2    	yes	(n/a)	(n/a)	NULL
Status	int	no	4	10   	0    	yes	(n/a)	(n/a)	NULL

/*---------------------------*/
  3. ������� ����������������
/*---------------------------*/

3.1 ������� Storage
����� �������� ������������ ���������

Column_name	Type	Computed	Length	Prec	Scale	Nullable	TrimTrailingBlanks	FixedLenNullInSource	Collation
StorageID	int	no	4	10   	0    	no	(n/a)	(n/a)	NULL
Name	varchar	no	250	     	     	yes	no	yes	Cyrillic_General_CI_AS


3.2 ������� Status
������� ���������
��� ������� Orders ��� ����������� ������� �������� � ���������
��� ������� Material ��� ��������� ������������ ���������: ���������� �����/������������/������� ������� 
