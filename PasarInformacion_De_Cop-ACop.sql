select 'select * from (' query,1 tipo
union
select 'select case when count('+(select top 1 COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS mm where mm.TABLE_NAME = os.TABLE_NAME and mm.ORDINAL_POSITION = 1 )+')> 0 
then count('+(select top 1 COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS mm where mm.TABLE_NAME = os.TABLE_NAME and mm.ORDINAL_POSITION = 1 )+')
else 0 end query , '''+TABLE_NAME+''' Tabla from '+TABLE_NAME +
 '  Where idcentroOperativo = 2 union  ' query
,2 tipo
from INFORMATION_SCHEMA.COLUMNS os where TABLE_NAME not like '%View%' and COLUMN_NAME = 'IdcentroOperativo'
union 
select ')q1 where query > 1' query, 3 tipo
order by tipo 