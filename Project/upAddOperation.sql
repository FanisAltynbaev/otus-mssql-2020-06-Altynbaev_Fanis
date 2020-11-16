use Apiary_OTUS
go

CREATE OR ALTER PROCEDURE upAddOperation 
( @RetVal         int out
 ,@OperationDate  datetime2      = NULL
 ,@ClientID		  int			 = NULL
 ,@MaterialID	  int			 = NULL
 ,@Qty			  decimal (18,2) = NULL
 ,@Price		  decimal (18,2) = NULL
 ,@Summa		  decimal (18,2) = NULL
 ,@StatusID		  int			 = NULL
 ,@StorageID      int            = NULL
)
AS
BEGIN
  select @RetVal = 0
  select @OperationDate = isnull(@OperationDate, GETDATE())

  insert into Operation
  ( OperationDate
  , ClientID
  , MaterialID
  , Qty
  , Price
  , Summa
  , StatusID
  , StorageID
  )
select 
    @OperationDate
  , @ClientID
  , @MaterialID
  , @Qty
  , @Price
  , @Summa
  , @StatusID
  , @StorageID

  return @RetVal
END

