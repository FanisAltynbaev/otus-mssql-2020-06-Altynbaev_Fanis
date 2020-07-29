Проект - ПАСЕКА

Будет содержать два основынх блока:
1. Производство - учет материального оснащения: ульи, рамки, инвентарь. Что из этого в использутся, что в резерве на складе, состояние семей возраста маток и т.д.
2. Реализация - уже привычнее покупатели, заказы, и т.д.

/*----------------*/
   1.Производство
/*----------------*/
1.1 Таблица  Material
Предназначена для хранения информации по всем материальным ценностям пасеки их количества, состояния, мест хранения
Тут будет 
 - инвентарь используемый в работе: медогонка, стамески, вилки, фляги, и т.д
 - комплектующие для ульев: дно, корпус, крышка, магазины 
 - рамки как используемые так и комплектующие для новых (верхняя/нижняя планки, боковинки)
 - готовая продукция мёд, воск, прополис и т.д.
Возможно более правльно под каждый подпункт создать отдельную таблицу, но не вижу необходимости. Ограничимся группировкой по MaterialType

Column_name	Type	Computed	Length	Prec	Scale	Nullable	TrimTrailingBlanks	FixedLenNullInSource	Collation
MaterialID	int	no	4	10   	0    	no	(n/a)	(n/a)	NULL
MaterialType	int	no	4	10   	0    	yes	(n/a)	(n/a)	NULL
Name	varchar	no	250	     	     	yes	no	yes	Cyrillic_General_CI_AS
Storage	int	no	4	10   	0    	yes	(n/a)	(n/a)	NULL
Rest	decimal	no	9	18   	2    	yes	(n/a)	(n/a)	NULL


1.2 Таблица MaterialType
Предназначена для группировки материальных ценностей: инверталь, готовая продуцкция. комплектующие и т.д.

Column_name	Type	Computed	Length	Prec	Scale	Nullable	TrimTrailingBlanks	FixedLenNullInSource	Collation
MaterialTypeID	int	no	4	10   	0    	no	(n/a)	(n/a)	NULL
Name	varchar	no	250	     	     	yes	no	yes	Cyrillic_General_CI_AS


/*--------------*/
   2. Реализация
/*--------------*/
2.1 Таблица Client
Список контактов поставциков и покупателей, их адреса и телефоны.
Column_name	Type	Computed	Length	Prec	Scale	Nullable	TrimTrailingBlanks	FixedLenNullInSource	Collation
ClientID	int	no	4	10   	0    	no	(n/a)	(n/a)	NULL
FIO	varchar	no	50	     	     	yes	no	yes	Cyrillic_General_CI_AS
Address	varchar	no	250	     	     	yes	no	yes	Cyrillic_General_CI_AS
Phone	varchar	no	25	     	     	yes	no	yes	Cyrillic_General_CI_AS

2.2 Таблица Orders
Таблица заказов.
В действительности назначение более широкое.
Предполагается ведение 
 - информации по реализации готовой продукции: заказчик, объем, цена, статус заказа принят/укомплектова/исполнен. Цена > 0 
 - текущих расходов (приобретение пчелопакетов, инфентаря, тары): постащик, объем, цена, статус оформлен/оплачен/исполнен. Цена < 0
 - информационных данных где важна просто хронология событий: кочевка на медоносы, вынос/занос на зимовку, качка и её объем. Цена = 0


Column_name	Type	Computed	Length	Prec	Scale	Nullable	TrimTrailingBlanks	FixedLenNullInSource	Collation
OrderID	int	no	4	10   	0    	no	(n/a)	(n/a)	NULL
OrderDate	datetime	no	8	     	     	yes	(n/a)	(n/a)	NULL
Client	int	no	4	10   	0    	yes	(n/a)	(n/a)	NULL
Material	int	no	4	10   	0    	yes	(n/a)	(n/a)	NULL
Quantity	decimal	no	9	18   	2    	yes	(n/a)	(n/a)	NULL
Price	decimal	no	9	18   	2    	yes	(n/a)	(n/a)	NULL
Status	int	no	4	10   	0    	yes	(n/a)	(n/a)	NULL

/*---------------------------*/
  3. Таблицы общегьназначения
/*---------------------------*/

3.1 Таблица Storage
Маста хранения материальных ценностей

Column_name	Type	Computed	Length	Prec	Scale	Nullable	TrimTrailingBlanks	FixedLenNullInSource	Collation
StorageID	int	no	4	10   	0    	no	(n/a)	(n/a)	NULL
Name	varchar	no	250	     	     	yes	no	yes	Cyrillic_General_CI_AS


3.2 Таблица Status
Таблица статустов
Для таблицы Orders это испольнения заказов продажам и поставкам
Для таблицы Material это состояние материальных ценностей: иневентарь Новый/Используется/Требует ремонта 
