
declare @FechaInicial datetime , @FechaFinal datetime , @NumeroInt int 

select @FechaInicial = '2022-12-28', @FechaFinal = getdate() , @NumeroInt = 20

select replace(replace(replace(ListaOperador,'UltMovimiento>',''),'</<',' , '),'</','')ListaOperador2 from (
select  stuff ((
		select   NombreCompleto+' '+convert(varchar,UltMov,103)UltMovimiento 
		from (
		select ohl.IdEmpleado,
				em.NombreCompleto
				,max(Fecha)UltMov
		from OperHorasLaboradas  ohl
		inner join CataEmpleados em on em.IdEmpleado = ohl.IdEmpleado
		where IdEquipoRenta = @NumeroInt  and ohl.Fecha between @FechaInicial and @FechaFinal
		
		group by ohl.IdEmpleado,em.NombreCompleto
		
		)q1 
		for XML PATH ('')
		),25,1,'') as ListaOperador
		)q3
		--)q2
		
		
-- FUNCION STUFF inserta un cadena en otra y elimna uan longitud determinada de caracteres 
--de la primera cadena a partir de la posicion de inicio y a continuacion inserta la segunda cadena en la primera posicion de inicio

--sintaxis ( EXPRESSION , START , LENGHT, ReplaceWithExpression)
	




