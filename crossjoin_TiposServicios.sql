select ROW_NUMBER()over (order by idmodelo)+(select max(IdTipoServicioOT) From CataTiposServiciosOT) IdTipoServicioOT,
substring(q1.Linea,1,5)+'-'+q1.Modelo+'-0'+convert(varchar,ROW_NUMBER()over (order by idmodelo)+(select max(IdTipoServicioOT) From CataTiposServiciosOT)) Codigo,q2.Actividades TipoServicioOT
,case when q2.tiempo/60 not like '%0.% ' then Convert(varchar,Round(tiempo/60,2)) else convert(varchar,tiempo/60)  end horas ,IdModCalSer 
from (
select IdModCalSer,ser.idmodelo,numero,mo.Nombre Modelo, lin.Nombre Linea from ParaModCalSer  ser
inner join catamodelos mo on mo.IdModelo = ser.IdModelo
inner join CataLineas lin on lin.IdLinea = mo.IdLinea 
where periodo = 0 and Servicio like '%Preparacion Equipo%' and lin.IdLinea in (6,4)
) q1
cross join (select  Linea, Actividades , Tiempo from Hoja1$ where linea <> 'Nada' and linea ='Montacargas')  q2
