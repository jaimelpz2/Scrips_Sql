declare @tabla varchar(75)

select @tabla = 'CataAccesorios'

select tipo,columna,case when columna = (select max(columna) from (
  select ROW_NUMBER()over (order by column_name)columna from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @tabla
  )q1)


then SUBSTRING(query,1,len(query)-1) else query end query from (
select 1 tipo, 0 columna,'select' query, 0 Position
union
select 2 tipo,ROW_NUMBER() over (order by COLUMN_NAME) ,
+' convert(varchar(100),max(len('+COLUMN_NAME+')))   '  +  '  +  case when max(len('+COLUMN_NAME+')) <'+convert(varchar(100),isnull(CHARACTER_MAXIMUM_LENGTH,4))+' then '' OK '' else '' Error '' end '
+COLUMN_NAME+',', ORDINAL_POSITION from INFORMATION_SCHEMA.COLUMNS
 where TABLE_NAME =@tabla 
 union 
 select 3 tipo,0 columna,'from '+@tabla, 0 Position
 )q1
  order by tipo,Position,columna asc


  --select max(columna) from (
  --select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'CataAccesorios'
  --)q1
