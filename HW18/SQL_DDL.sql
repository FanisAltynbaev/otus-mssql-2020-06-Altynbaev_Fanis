use master
DROP DATABASE [Apiary_OTUS]

---1 Создание базы данных с указанием файлов
CREATE DATABASE [Apiary_OTUS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = Apiary_OTUS, FILENAME = N'C:\1\Apiary_OTUS.mdf' , 
	SIZE = 8MB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB )
 LOG ON 
( NAME = Apiary_OTUS_log, FILENAME = N'C:\1\Apiary_OTUS_log.ldf' , 
	SIZE = 8MB , 
	MAXSIZE = 10GB , 
	FILEGROWTH = 65536KB )
GO


use [Apiary_OTUS];
GO

---- Создание таблиц
---- Первичные и внешние ключи для всех созданных таблиц.



/*************************************************/
CREATE TABLE MaterialType(
	MaterialTypeID 	int not null identity(1, 1)  primary key,
	Name            nvarchar(250)
)



/*************************************************/
CREATE TABLE Storage(
	StorageID 	int not null identity(1, 1)  primary key,
	Name        nvarchar(250)
)



/*************************************************/
CREATE TABLE Status(
	StatusID  int not null identity(1, 1)  primary key,
	Name      nvarchar(50)
)



/*************************************************/
CREATE TABLE Material(
	MaterialID     int not null identity(1, 1)  primary key,
	MaterialTypeID int not null,
	Name           nvarchar(250),
	StorageID      int not null,
	Qty            decimal(18,2),
	Date		   datetime2,
	Srok           int null,
	StatusID       int null
)
ALTER TABLE Material  ADD  CONSTRAINT FK_Material_MaterialType FOREIGN KEY(MaterialTypeID)
REFERENCES MaterialType (MaterialTypeID)

ALTER TABLE Material  ADD  CONSTRAINT FK_Material_Storage FOREIGN KEY(StorageID)
REFERENCES Storage (StorageID)

ALTER TABLE Material  ADD  CONSTRAINT FK_Material_Status FOREIGN KEY(StatusID)
REFERENCES Status (StatusID)


---- Индексы на таблицу.
create index idx_Material_MaterialType on Material (MaterialTypeID);
create index idx_Material_Storage on Material (StorageID);
create index idx_Material_Status on Material (StatusID);
create index idx_MaterialType_Storage on Material (MaterialTypeID, StorageID);
create index idx_Storage_MaterialType on Material (StorageID,MaterialTypeID);

---- Ограничения на ввод данных.
ALTER TABLE Material 
	ADD CONSTRAINT Qty 
		CHECK (Qty>=0);


/*************************************************/
CREATE TABLE Client(
	ClientID int not null identity(1, 1)  primary key,
	FIO      nvarchar(100),
	Address  nvarchar(250),
	Phone    nvarchar(25)
)



/*************************************************/
CREATE TABLE Operation(
	OperationID   int not null identity(1, 1)  primary key,
	OperationDate datetime2,
	ClientID      int null,
	MaterialID    int not null,
	Qty           decimal(18,2),
	Price         decimal(18,2),
	Summa         decimal(18,2),
	StatusID      int
)

ALTER TABLE Operation  ADD  CONSTRAINT FK_Operation_Status FOREIGN KEY(StatusID)
REFERENCES Status (StatusID)

ALTER TABLE Operation  ADD  CONSTRAINT FK_Operation_Client FOREIGN KEY(ClientID)
REFERENCES Client (ClientID)

ALTER TABLE Operation  ADD  CONSTRAINT FK_Operation_Material FOREIGN KEY(MaterialID)
REFERENCES Material (MaterialID)

---- Индексы на таблицу.
create index idx_Operation_Client on Operation (ClientID);
create index idx_Operation_Material on Operation (MaterialID);
create index idx_Operation_Status on Operation (StatusID);

create index idx_OperationDate on Operation (OperationDate);
create index idx_Client_OperationDate on Operation (ClientID, OperationDate);

---- Ограничения на ввод данных.
ALTER TABLE Operation 
	ADD CONSTRAINT OperationDate 
		DEFAULT GetDate() FOR OperationDate;

