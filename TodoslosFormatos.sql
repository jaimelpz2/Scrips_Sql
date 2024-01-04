select TipoReporte from ParaReportes group by  TipoReporte -- consulta todos los tipos de formatos

declare @TipoFormato varchar(40)

select @TipoFormato = 'COTIZA'-- que formato vas a consultar.

select 
case when idmov = 
( 
 SELECT  top 1 ROW_NUMBER() over (order by name) idmov FROM sys.databases where name like '%ITR%' and name not like '%audit%' order by idmov desc 
) then REPLACE(query,'union','') else query end query
 from (
select 'select * from (' query,1 tipo,  0 idmov , '' tabla
union
SELECT 'select IndexReporte ,'' '+name+''' tabla from'+' '+name+'.dbo.ParaReportes where TipoReporte like ''%'+@TipoFormato+'%'' union'query,
2 tipo, ROW_NUMBER() over (order by name) idmov ,name Tabla

FROM sys.databases where name like '%ITR%' and name not like '%audit%' 
union 
select ')q1 group by IndexReporte,Tabla' query, 3 tipo, 0 idmov ,'' tabla
)q1
order by tipo --Copea y pega el resultado query en otro nuevo query para ver los indexreportes