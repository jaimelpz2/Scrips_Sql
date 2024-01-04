
select 'select * from (' query,1 tipo
union
select 'select  case when count('+(select top 1 COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS mm where mm.TABLE_NAME = os.TABLE_NAME and mm.ORDINAL_POSITION = 1 )+')> 0 
then count('+(select top 1 COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS mm where mm.TABLE_NAME = os.TABLE_NAME and mm.ORDINAL_POSITION = 1 )+')
else 0 end query,''select * from '+TABLE_NAME+' where idrefaccion = 25256'' Tabla ,''update '+TABLE_NAME+' set idRefaccion=14011 where idrefaccion = 25256'' query2 from '+TABLE_NAME +
 '  Where idrefaccion = 25256 union  ' query
,2 tipo
from INFORMATION_SCHEMA.COLUMNS os where TABLE_NAME not like '%View%' and COLUMN_NAME = 'idrefaccion' and TABLE_NAME not like '%CataRefacciones%'
union 
select ')q1 where query > 0' query, 3 tipo
order by tipo 
