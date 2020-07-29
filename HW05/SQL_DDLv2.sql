---1 Создание базы данных с указанием файлов
CREATE DATABASE [Apiary]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = Apiary, FILENAME = N'C:\1\Apiary.mdf' , 
	SIZE = 8MB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB )
 LOG ON 
( NAME = Apiary_log, FILENAME = N'C:\1\Apiary_log.ldf' , 
	SIZE = 8MB , 
	MAXSIZE = 10GB , 
	FILEGROWTH = 65536KB )
GO


----2 Создание таблиц
---- 3 Первичные и внешние ключи для всех созданных таблиц.

use [Apiary];
GO

CREATE TABLE Material(
	MaterialID    int not null identity(1, 1)  primary key,
	MaterialType  int null,
	Name          nvarchar(250),
	Storage       int null,
	Rest          decimal(18,2)
)
ALTER TABLE Material  ADD  CONSTRAINT FK_Material_MaterialType FOREIGN KEY(MaterialType)
REFERENCES MaterialType (MaterialTypeID)

ALTER TABLE Material  ADD  CONSTRAINT FK_Material_Storage FOREIGN KEY(Storage)
REFERENCES Storage (StorageID)

create index idx_Material_MaterialType on Material (MaterialType);
create index idx_Material_Storage on Material (Storage);


CREATE TABLE MaterialType(
	MaterialTypeID 	int not null identity(1, 1)  primary key,
	Name            nvarchar(250)
)

CREATE TABLE Storage(
	StorageID 	int not null identity(1, 1)  primary key,
	Name        nvarchar(250)
)

CREATE TABLE Client(
	ClientID int not null identity(1, 1)  primary key,
	FIO      nvarchar(250),
	Address  nvarchar(250),
	Phone    nvarchar(25)
)

CREATE TABLE Orders(
	OrderID   int not null identity(1, 1)  primary key,
	OrderDate datetime,
	Client    int,
	Material  int,
	Quantity  decimal(18,2),
	Price     decimal(18,2),
	Status    int
)

ALTER TABLE Orders  ADD  CONSTRAINT FK_Orders_Status FOREIGN KEY(Status)
REFERENCES Status (StatusID)
Orders
ALTER TABLE Orders  ADD  CONSTRAINT FK_Orders_Client FOREIGN KEY(Client)
REFERENCES Client (ClientID)

ALTER TABLE Orders  ADD  CONSTRAINT FK_Orders_Material FOREIGN KEY(Material)
REFERENCES Material (MaterialID)

create index idx_Orders_Client on Orders (Client);
create index idx_Orders_Material on Orders (Material);
create index idx_Orders_Status on Orders (Status);


CREATE TABLE Status(
	StatusID  int not null identity(1, 1)  primary key,
	Name      nvarchar(50)
)


---- 4. 1-2 индекса на таблицы.
create index idx_MaterialType_Storage on Material (MaterialType, Storage);
create index idx_Storage_MaterialType on Material (Storage,MaterialType);

create index idx_OrderDate on Orders (OrderDate);
create index idx_Client_OrderDate on Orders (Client, OrderDate);

---- 5. Наложите по одному ограничению в каждой таблице на ввод данных.
ALTER TABLE Material 
	ADD CONSTRAINT Rest 
		CHECK (Rest >=0);

ALTER TABLE Orders 
	ADD CONSTRAINT OrderDate 
		DEFAULT GetDate() FOR OrderDate;

