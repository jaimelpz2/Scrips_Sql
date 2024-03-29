USE [ITR_Data]
GO
/****** Object:  StoredProcedure [dbo].[ITR_SP_ImportarExcel]    Script Date: 04/04/2023 11:58:19 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		SAUL PEREZ
-- Create date: 4-FEB-2023
-- Description:	Importacion de archivo Excel a SQL
-- =============================================
ALTER PROCEDURE [dbo].[ITR_SP_ImportarExcel]
	-- Add the parameters for the stored procedure here
	--@table varchar(4000),
	@location    varchar(4000), 
	@tipo   varchar(100),
	@Sucursal int,
	@centro int ,
	@sheet		varchar(255)
	--, @idexcel	int	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
		--DECLARE @location   nvarchar(4000)
		--DECLARE @table nvarchar(255)
		DECLARE @datasrc varchar(max)
		DECLARE @sqlqry		varchar(max)
		DECLARE @sqlqry2		varchar(max)
		DECLARE @Max	varchar(200)
		DECLARE @Max2	varchar(200)
		DECLARE @colation   varchar(2048)

	--Asignacion de variables
		--SET @table = @table
		SET @datasrc =    ''''+'Database=' + @location +''''
		SET @sheet = '['+@sheet+'$]'



			if @tipo ='Lineas' 
			begin
					

					set @sqlqry  = 
					'select 
					Row_Number() over (order by Linea) idLinea,
					Row_Number() over (partition by Linea order by Linea)idmov,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Linea,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Linea,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Horometro,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Horometro,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Gasto,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Gasto,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(DepreciacionContableMeses,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))DepreciacionContableMeses,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(DepreciacionContablePorcentaje,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))DepreciacionContablePorcentaje,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(SeguroObligatorio,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))SeguroObligatorio,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Aseguradora,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Aseguradora,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(TiempoVenta,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))TiempoVenta

					 into PruebasLineas from OPENROWSET 
					 (''Microsoft.ACE.OLEDB.12.0'','+'''Excel 12.0 Xml;HRD=YES;'''+@datasrc+','+
					 '''SELECT * FROM ' +@sheet+''')'

				

		exec(@sqlqry) -- insertar la cadena que tiene el select into TODO LO DE ARRIBA


		
					  set @sqlqry = 'delete from PruebasLineas where Linea = '''' or Linea is null or idmov >1'
					   exec(@sqlqry) -- Limpia la tabla si no hay valores registrados como en este caso la razon social si no hay pues pelamos gallo


					   set  @colation = 'select  COLLATION_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = ''catalineas'' and COLUMN_NAME = ''Nombre'''
					    -- obtener el colation de la columna la cual hara el inner join para que lo inserte 
						execute(@colation)

		set @sqlqry='alter table PruebasLineas alter column Linea nvarchar(1000) '+@colation+';'
		exec(@sqlqry)-- ACTUALIZA EL TIPO DE TEXTO para hacer uniones

		select @Max=isnull(max(IdLinea),0) from CataLineas
		select @Max2=max(IdLineaSucursal) from CataLineasSucursal

		set @sqlqry = 'Select * from PruebasLineas '
		exec(@sqlqry)

			set @sqlqry = '
		select Row_number() over (order by Linea)+'+isnull(@Max,0)+' idlinea,UPPER(pbr.Linea) Linea,'''' Descripcion,pbr.Gasto, pbr.Horometro,null Codigo, 
		null IdLineaClasificacion , null ClaveProductoSat, null UnidadMedidaSat, pbr.SeguroObligatorio,null CostoMinimoAsegurar
		from PruebasLineas pbr left join catalineas lin on lin.Nombre = pbr.Linea where nombre is null' 

		exec(@sqlqry) --imprime que se inserto x


		set @sqlqry = '
		insert into catalineas
		select Row_number() over (order by Linea)+'+isnull(@Max,0)+' idlinea,UPPER(pbr.Linea) Linea,'''' Descripcion,pbr.Gasto,pbr.Horometro,null Codigo, 
		null IdLineaClasificacion , null ClaveProductoSat, null UnidadMedidaSat, pbr.SeguroObligatorio,null CostoMinimoAsegurar
		from PruebasLineas pbr left join catalineas lin on lin.Nombre = pbr.Linea where nombre is null' 
		-- INSSERCION A CATALINEAS DE LO QUE SOLAMENTE NO SE ENCUENTRA
		
		exec(@sqlqry)

	
		set @sqlqry2 = '
		insert into CataLineasSucursal
		select Row_number() over (order by cta.IdLinea)+'+isnull(@Max2,0)+' IdLineaSucursal,cta.IdLinea,'+convert(varchar,@Sucursal)+' IdSucursal, '+convert(varchar,@Centro)+' IdCentroOperativo,
		pbr.DepreciacionContableMeses, pbr.DepreciacionContablePorcentaje,
		pbr.TiempoVenta, pbr.Aseguradora,null PrecioRentaDiario,null PrecioRentaSemanal, null PrecioRentaQuincenal, null PrecioRentaMensual, null PrecioRentaHora,null MonedaRenta
		 from  catalineas cta
		 inner join PruebasLineas pbr on pbr.Linea = cta.Nombre 
		 where cta.idlinea >='+@Max+'
		'
		-- INSERCION A CATACLIENTES DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)

		set @sqlqry2 = '
		select Row_number() over (order by cta.IdLinea)+'+isnull(@Max2,0)+' IdLineaSucursal,cta.IdLinea,'+convert(varchar,@Sucursal)+' IdSucursal, '+convert(varchar,@Centro)+' IdCentroOperativo,
		pbr.DepreciacionContableMeses, pbr.DepreciacionContablePorcentaje,
		pbr.TiempoVenta, pbr.Aseguradora,null PrecioRentaDiario,null PrecioRentaSemanal, null PrecioRentaQuincenal, null PrecioRentaMensual, null PrecioRentaHora,null MonedaRenta
		 from  catalineas cta
		 inner join  PruebasLineas pbr on pbr.Linea = cta.Nombre 
		 where cta.idlinea >='+@Max+'  ' -- imprime que se inserto x2 
		 
		exec(@sqlqry2)

		set @sqlqry  = 'drop table PruebasLineas' -- Borramos la tabla temporal ya que , ya la utilizamos para las comparaciones
		print 'Tabla Temporal Borrada'
		exec(@sqlqry)

					end -- PARA LINEAS


					--- INICIO PROVEEDORES

			 if @tipo ='Proveedores' 
			 begin

			
				set @sqlqry  = 
					'select 
					Row_Number() over (order by Razonsocial) idProveedor,
					Row_Number() over (partition by RFC order by Razonsocial)idmov2,
					Row_Number() over (partition by Razonsocial,RFC order by Razonsocial)idmov,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(RazonSocial,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))RazonSocial,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Contacto,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Contacto,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Correo,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))EMAILS,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(RFC,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))RFC,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(CalleNombre,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))CalleNumero,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(NumeroInterior,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))NumeroExterior,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Colonia,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Colonia,
					isnull(ltrim(rtrim(CP)),'''')CP,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(MunicipioDelegacion,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))MunicipioDelegacion,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Ciudad,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Ciudad,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Estado,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Estado,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Telefonos,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Telefonos,
					convert(int,rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(DiasCredito,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),''0''))))DiasCredito,
					convert(numeric(12,2),rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(LimitedeCredito,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),''0''))))LimitedeCredito  
					 into PruebasProveedores from OPENROWSET 
					 (''Microsoft.ACE.OLEDB.12.0'','+'''Excel 12.0 Xml;HRD=YES;'''+@datasrc+','+
					 '''SELECT * FROM ' +@sheet+''')'

					 exec(@sqlqry) -- crea e inserta la tabla temporal  del excel a la base de datos 

					 
					  set @sqlqry = 'delete from PruebasProveedores where RazonSocial = '''' or RazonSocial is null or idmov >1'
					   exec(@sqlqry) -- Limpia la tabla si no hay valores registrados como en este caso la razon social si no hay pues pelamos gallo


					   		   set  @colation = 'select  COLLATION_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = ''CataProveedores'' and COLUMN_NAME = ''RazonSocial'''
					    -- obtener el colation de la columna la cual hara el inner join para que lo inserte 
						execute(@colation)


					set @sqlqry='alter table PruebasProveedores alter column RazonSocial nvarchar(1000)'+@colation+';'
					exec(@sqlqry)-- ACTUALIZA EL TIPO DE TEXTO para hacer uniones


						select @Max=isnull(max(IdProveedor),0) from CataProveedores
						select @Max2= max(IdProveedorSucursal) from CataProveedoresSucursal

			set @sqlqry = '
		select Row_number() over (order by pbr.RazonSocial)+'+isnull(@Max,0)+' idProveedor,pbr.RazonSocial,
		case when pbr.RFC = ''''  then ''TEMP4246010''+convert(varchar,ROW_NUMBER()over (partition by pbr.RFC order by pbr.RazonSocial)) else  substring(pbr.RFC,1,15) end RFC,
		'''' curp,Pbr.Contacto,pbr.Telefonos,null Faxes, pbr.Emails,pbr.CalleNumero,substring(pbr.CP,1,5) CP,
		isnull((select top 1 Colonia from CataColonias cpo where cpo.CodigoPostal = pbr.CP),pbr.colonia)Colonia,
		isnull( ccp.MunicipioDelegacion,pbr.MunicipioDelegacion) MunicipioDelegacion , 
		isnull(ccp.Ciudad,pbr.ciudad) Ciudad, isnull(ccp.Estado,pbr.Estado) Estado,
		case when len(pbr.RFC)>15 then ''RFC: ''+pbr.RFC+''  CP: ''+pbr.CP else ''RFC: ''+substring(pbr.RFC,1,15)+''  CP: ''+substring(pbr.CP,1,5) end Observaciones, 
		null SujetoRetencion, null CuentaDeposito,  null CuentaContable, 
		'+convert(varchar,@Sucursal)+' SucursalProveedor, null Referencia,0 LimiteCredito, pbr.DiasCredito, null Contacto1, null TelContacto1,
		null EmailContacto1, null Contacto2, null TelContacto2, null EmailContacto2, null Contacto3, null TelContacto3,
		null EmailContacto3, null PagaTransferencia, null PagaBancoReferencia, null ReferenciaBancaria,
		null RequiereEnvioFacturaFisica, null ObservacionesImportacion, 
		case when len(pbr.RFC) = 12 then ''Moral'' 
		when len(pbr.RFC) >= 13 and len(pbr.RFC) <=15 then ''Fisica''
		when len(pbr.RFC) >15 then ''Extranjero'' end PersonaFiscal, null ApellidoPaterno,
		null ApellidoMaterno, null Nombres,null IdClasificacionProveedor,null USOCFDI,null CuentaContable2,
		null CuentaContable3,null CuentaContable4,null WhatsAppContacto, null WhatsAppContacto1, null WhatsAppContacto2,
		null WhatsAppContacto3,null IdBanco,null CuentaBancariaDestino,null RequiereAutorizacionA, null RequiereAutorizacionB,
		null RequiereAutorizacionC, null CuentaBancariaOrigen, null AliasPortalBancario, null ClaveFormaPagoPortal,
		null CuentaBancariaOrigenUSD,null CuentaBancariaDestinoUSD, null AliasPortalBancarioUSD,null PagosMXP,null PagosUSD,
		null PreMoneda, null PrePorcentajeIVA,null PrePorcentajeRetencion1, null PrePorcentajeRetencion2,  null PrePorcentajeImpuesto1
		,null PrePorcentajeImpuesto2, null ClaveFormaPagoPortalUSD
		from PruebasProveedores pbr 
		left join CataProveedores pro on pro.RazonSocial = pbr.Razonsocial 
		left join CataCodigosPostales ccp on ccp.CodigoPostal = pbr.CP
		where pro.Razonsocial is null ' 

		exec(@sqlqry) --imprime que se va a insertar 

				set @sqlqry = '
		insert into CataProveedores
		select Row_number() over (order by pbr.RazonSocial)+'+isnull(@Max,0)+' idProveedor,pbr.RazonSocial,
		case when pbr.RFC = ''''  then ''TEMP4246010''+convert(varchar,ROW_NUMBER()over (partition by pbr.RFC order by pbr.RazonSocial)) else  substring(pbr.RFC,1,15) end RFC
		,'''' curp,Pbr.Contacto,pbr.Telefonos,null Faxes, pbr.Emails,pbr.CalleNumero,substring(pbr.CP,1,5) CP,
		isnull((select top 1 Colonia from CataColonias cpo where cpo.CodigoPostal = pbr.CP),pbr.colonia)Colonia,
		isnull( ccp.MunicipioDelegacion,pbr.MunicipioDelegacion) MunicipioDelegacion , 
		isnull(ccp.Ciudad,pbr.ciudad) Ciudad, isnull(ccp.Estado,pbr.Estado) Estado,
		case when len(pbr.RFC)>15 then ''RFC: ''+pbr.RFC+''  CP: ''+pbr.CP else ''RFC: ''+substring(pbr.RFC,1,15)+''  CP: ''+substring(pbr.CP,1,5) end Observaciones, 
		null SujetoRetencion, null CuentaDeposito,  null CuentaContable, 
		'+convert(varchar,@Sucursal)+' SucursalProveedor, null Referencia,0 LimiteCredito, pbr.DiasCredito, null Contacto1, null TelContacto1,
		null EmailContacto1, null Contacto2, null TelContacto2, null EmailContacto2, null Contacto3, null TelContacto3,
		null EmailContacto3, null PagaTransferencia, null PagaBancoReferencia, null ReferenciaBancaria,
		null RequiereEnvioFacturaFisica, null ObservacionesImportacion, 
		isnull(case when len(pbr.RFC) = 12 then ''Moral'' 
		when len(pbr.RFC) >= 13 and len(pbr.RFC) <=15 then ''Fisica''
		when len(pbr.RFC) >15 then ''Extranjero'' end,''Moral'') PersonaFiscal, null ApellidoPaterno,
		null ApellidoMaterno, null Nombres,null IdClasificacionProveedor,null USOCFDI,null CuentaContable2,
		null CuentaContable3,null CuentaContable4,null WhatsAppContacto, null WhatsAppContacto1, null WhatsAppContacto2,
		null WhatsAppContacto3,null IdBanco,null CuentaBancariaDestino,null RequiereAutorizacionA, null RequiereAutorizacionB,
		null RequiereAutorizacionC, null CuentaBancariaOrigen, null AliasPortalBancario, null ClaveFormaPagoPortal,
		null CuentaBancariaOrigenUSD,null CuentaBancariaDestinoUSD, null AliasPortalBancarioUSD,null PagosMXP,null PagosUSD,
		null PreMoneda, null PrePorcentajeIVA,null PrePorcentajeRetencion1, null PrePorcentajeRetencion2,  null PrePorcentajeImpuesto1
		,null PrePorcentajeImpuesto2, null ClaveFormaPagoPortalUSD
		from PruebasProveedores pbr 
		left join CataProveedores pro on pro.RazonSocial = pbr.Razonsocial 
		left join CataCodigosPostales ccp on ccp.CodigoPostal = pbr.CP
		where pro.Razonsocial is null' 
		-- INSSERCION A CataProveedores DE LO QUE SOLAMENTE NO SE ENCUENTRA
		
		exec(@sqlqry)


		set @sqlqry2 = '
		insert into CataProveedoresSucursal
			select IdProveedor, '+convert(varchar,@Sucursal)+' IdSucursal, Row_Number()over (order by RazonSocial)+'+isnull(@Max2,0)+' IdProveedorSucursal,  Contacto,  Telefonos, NULL Faxes,0 CompraDescuentoEquipos,0 CompraDescuentoEquiposExtra ,0 CompraDescuentoEquipos2, 0 CompraDescuentoEquiposExtra2,
0 CompraDescuentoEquipos3, 0 CompraDescuentoEquiposExtra3, 0 CompraDescuentoRefacciones, 0 CompraDescuentoRefaccionesExtra, 0 CompraDescuentoRefacciones2, 0 CompraDescuentoRefaccionesExtra2,0 CompraDescuentoRefacciones3,
0 CompraDescuentoRefaccionesExtra3, 0 CompraDiasCreditoEquipos,0 CompraDiasCreditoRefacciones,0 CompraDiasCreditoEquipos2,0 CompraDiasCreditoRefacciones2,0 CompraDiasCreditoEquipos3,0 CompraDiasCreditoRefacciones3,
0 VentaPorcentajeGananciaEquiposNuevosClienteA,0 VentaPorcentajeGananciaEquiposNuevosClienteB,0 VentaPorcentajeGananciaEquiposNuevosClienteC,0 VentaPorcentajeGananciaEquiposNuevosClienteD,0 VentaPorcentajeGananciaEquiposUsadosClienteA,
0 VentaPorcentajeGananciaEquiposUsadosClienteB,0 VentaPorcentajeGananciaEquiposUsadosClienteC,0 VentaPorcentajeGananciaEquiposUsadosClienteD,0 VentaPorcentajeGananciaAccesoriosParteClienteA,0 VentaPorcentajeGananciaAccesoriosParteClienteB,
0 VentaPorcentajeGananciaAccesoriosParteClienteC,0 VentaPorcentajeGananciaAccesoriosParteClienteD,0 VentaPorcentajeGananciaAccesoriosConsumibleClienteA,0 VentaPorcentajeGananciaAccesoriosConsumibleClienteB,
0 VentaPorcentajeGananciaAccesoriosConsumibleClienteC,0 VentaPorcentajeGananciaAccesoriosConsumibleClienteD,0 VentaPorcentajeGananciaRefaccionesClienteA,0 VentaPorcentajeGananciaRefaccionesClienteB,
0 VentaPorcentajeGananciaRefaccionesClienteC,0 VentaPorcentajeGananciaRefaccionesClienteD, NULL Observaciones
		 from  CataProveedores where idproveedor >'+@Max+'  '
		-- INSERCION A CATACLIENTES DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)

			set @sqlqry2 = '
		select IdProveedor, '+convert(varchar,@sucursal)+' IdSucursal, Row_Number()over (order by RazonSocial)+'+@Max2+' IdProveedorSucursal,  Contacto,  Telefonos, NULL Faxes,0 CompraDescuentoEquipos,0 CompraDescuentoEquiposExtra ,0 CompraDescuentoEquipos2, 0 CompraDescuentoEquiposExtra2,
0 CompraDescuentoEquipos3, 0 CompraDescuentoEquiposExtra3, 0 CompraDescuentoRefacciones, 0 CompraDescuentoRefaccionesExtra, 0 CompraDescuentoRefacciones2, 0 CompraDescuentoRefaccionesExtra2,0 CompraDescuentoRefacciones3,
0 CompraDescuentoRefaccionesExtra3, 0 CompraDiasCreditoEquipos,0 CompraDiasCreditoRefacciones,0 CompraDiasCreditoEquipos2,0 CompraDiasCreditoRefacciones2,0 CompraDiasCreditoEquipos3,0 CompraDiasCreditoRefacciones3,
0 VentaPorcentajeGananciaEquiposNuevosClienteA,0 VentaPorcentajeGananciaEquiposNuevosClienteB,0 VentaPorcentajeGananciaEquiposNuevosClienteC,0 VentaPorcentajeGananciaEquiposNuevosClienteD,0 VentaPorcentajeGananciaEquiposUsadosClienteA,
0 VentaPorcentajeGananciaEquiposUsadosClienteB,0 VentaPorcentajeGananciaEquiposUsadosClienteC,0 VentaPorcentajeGananciaEquiposUsadosClienteD,0 VentaPorcentajeGananciaAccesoriosParteClienteA,0 VentaPorcentajeGananciaAccesoriosParteClienteB,
0 VentaPorcentajeGananciaAccesoriosParteClienteC,0 VentaPorcentajeGananciaAccesoriosParteClienteD,0 VentaPorcentajeGananciaAccesoriosConsumibleClienteA,0 VentaPorcentajeGananciaAccesoriosConsumibleClienteB,
0 VentaPorcentajeGananciaAccesoriosConsumibleClienteC,0 VentaPorcentajeGananciaAccesoriosConsumibleClienteD,0 VentaPorcentajeGananciaRefaccionesClienteA,0 VentaPorcentajeGananciaRefaccionesClienteB,
0 VentaPorcentajeGananciaRefaccionesClienteC,0 VentaPorcentajeGananciaRefaccionesClienteD, NULL Observaciones
		 from  CataProveedores where idproveedor >'+@Max+'   ' -- imprime que se va insertar en Proveedores 
		 
		exec(@sqlqry2)



		set @sqlqry  = 'drop table PruebasProveedores' -- Borramos la tabla temporal ya que , ya la utilizamos para las comparaciones
		print 'Tabla Temporal Borrada'
		exec(@sqlqry)


			  end -- FIN DE PROVEEDORES


			 if @tipo ='Modelos' 

			 begin 

			 		set @sqlqry  = 
					'select 
					Row_Number() over (order by Nombre) idLinea,
					Row_Number() over (partition by Nombre order by Nombre)idmov,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Linea,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Linea,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Nombre,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Nombre   


					 into PruebasModelos from OPENROWSET 
					 (''Microsoft.ACE.OLEDB.12.0'','+'''Excel 12.0 Xml;HRD=YES;'''+@datasrc+','+
					 '''SELECT * FROM ' +@sheet+''')'

				

		exec(@sqlqry) -- insertar la cadena que tiene el select into TODO LO DE ARRIBA

		
					  set @sqlqry = 'delete from PruebasModelos where Nombre = '''' or Nombre is null or idmov >1'
					   exec(@sqlqry) -- Limpia la tabla si no hay valores registrados como en este caso la razon social si no hay pues pelamos gallo

					     set  @colation = 'select  COLLATION_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = ''Catamodelos'' and COLUMN_NAME = ''Nombre'' '
					    -- obtener el colation de la columna la cual hara el inner join para que lo inserte 
						execute(@colation)

		set @sqlqry='alter table PruebasModelos alter column Nombre nvarchar(1000)'+@colation+';'' alter table PruebasModelos alter column Linea nvarchar(1000) '+@colation+';'
		exec(@sqlqry)-- ACTUALIZA EL TIPO DE TEXTO para hacer uniones

		select @Max=max(idModelo) from CataModelos
		select @Max2= max(IdModeloSucursal) from CataModelosSucursal

		/*	SI NO EXISTEN LAS LINEAS DEL EXCEL EJECUTA Lo SIGUIENTE */
				set @sqlqry = '
		insert into catalineas
			select Row_number() over (order by Linea)+'+(select max(IdLinea) from CataLineas)+' idlinea,pbr.Linea, 
			'''' Descripcion,''N'' Gasto,''N'' Horometro,null Codigo, 
		null IdLineaClasificacion , null ClaveProductoSat, null UnidadMedidaSat, null SeguroObligatorio,null CostoMinimoAsegurar
		from (select top (1) Linea from PruebasModelos model
left join catalineas lin on lin.Nombre = model.linea
where lin.Nombre is null) pbr left join catalineas lin on lin.Nombre = pbr.Linea where nombre is null ' 
		-- INSSERCION A CATALINEAS DE LO QUE SOLAMENTE NO SE ENCUENTRA
		
		exec(@sqlqry)


		set @sqlqry2 = '
		insert into CataLineasSucursal
		select Row_number() over (order by IdLinea)+'+@Max2+' IdLineaSucursal,IdLinea,'+convert(varchar,@Sucursal)+' IdSucursal, '+convert(varchar,@Centro)+' IdCentroOperativo,1 DepreciacionContableMeses, 1 DepreciacionContablePorcentaje,
		0 TiempoVenta, ''N'' Aseguradora,null PrecioRentaDiario,null PrecioRentaSemanal, null PrecioRentaQuincenal, null PrecioRentaMensual, null PrecioRentaHora,null MonedaRenta
		 from  catalineas where idlinea >'+(select max(IdLinea) from CataLineas)+'
		'
		-- INSERCION A CATACLIENTES DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)


		/* FIN */
		
			set @sqlqry = '
			select ROW_NUMBER() over (order by pbr.nombre)+'+isnull(@Max,0)+' IdModelo,lin.idlinea,	pbr.Nombre,	'''' CodigoProveedor,	0 IdProveedor,	'''' Marca,	'''' Descripcion,	'''' CaracteristicasTecnicas,'''' Cuidados,
			'''' Moneda, 0 PrecioListaVenta,	0 PrecioListaProveedor,	'''' FechaUltimaActualizacion,	1 Activo,	0 CostoBase,	0 PorcentajeMinimoGanancia,	'''' Familia,'''' ImagenModelo,'''' CaracteristicasRFT,0 Peso,	
  '''' RubroMaquinaria,	'''' CalculoPrecioVenta,	0 IdModeloCategoria,	0 PrecioListaVenta2,'''' Moneda2,	0 Vehiculo,	0 KmPorDia,'''' ClaveProductoSAT,'''' CataServicios,'''' LeyendaReconstruido,	
    '''' ClaveUnidadPesoSAT,'''' ClaveTipoEmbalajeSAT

		from PruebasModelos pbr left join catamodelos modeli on modeli.Nombre = pbr.Nombre
left join catalineas lin on lin.Nombre = pbr.linea
where modeli.Nombre is null' 

		exec(@sqlqry) --imprime que se inserto x


		set @sqlqry = '
		insert into Catamodelos
		select ROW_NUMBER() over (order by pbr.nombre)+'+isnull(@Max,0)+' IdModelo,lin.idlinea,	pbr.Nombre,	'''' CodigoProveedor,	0 IdProveedor,	'''' Marca,	'''' Descripcion,	'''' CaracteristicasTecnicas,'''' Cuidados,
			'''' Moneda, 0 PrecioListaVenta,	0 PrecioListaProveedor,	'''' FechaUltimaActualizacion,	1 Activo,	0 CostoBase,	0 PorcentajeMinimoGanancia,	'''' Familia,'''' ImagenModelo,'''' CaracteristicasRFT,0 Peso,	
  '''' RubroMaquinaria,	'''' CalculoPrecioVenta,	0 IdModeloCategoria,	0 PrecioListaVenta2,'''' Moneda2,	0 Vehiculo,	0 KmPorDia,'''' ClaveProductoSAT,'''' CataServicios,'''' LeyendaReconstruido,	
    '''' ClaveUnidadPesoSAT,'''' ClaveTipoEmbalajeSAT

		from PruebasModelos pbr left join catamodelos modeli on modeli.Nombre = pbr.Nombre
left join catalineas lin on lin.Nombre = pbr.linea
where modeli.Nombre is null ' 
		-- INSSERCION A CATALINEAS DE LO QUE SOLAMENTE NO SE ENCUENTRA
		
		exec(@sqlqry)

	
		set @sqlqry2 = '
		insert into CataModelosSucursal
		select Row_number()over (order by idmodelo)+'+isnull(@Max2,0)+' IdModeloSucursal,	 IdModelo,	'+convert(varchar,@Sucursal)+' IdSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo,	0 UltimoCosto,	0 CostoFlete,	
		0 PrecioRentaDiario,	0 PrecioRentaSemanal,	0 PrecioRentaMensual,	
		''Pesos'' Moneda,0 TiempoEntrega,0 DescuentoSobrePrecioLista,	1 CondicionesCompra,	0 PrecioRentaHora,	0 PrecioRentaQuincenal,	0 CargoMinimo
		 from  Catamodelos where idmodelo >'+@Max+' '
		-- INSERCION A CATACLIENTES DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)

		set @sqlqry2 = '
			select Row_number()over (order by idmodelo)+'+isnull(@Max2,0)+' IdModeloSucursal,	 IdModelo,	'+convert(varchar,@Sucursal)+' IdSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo,	0 UltimoCosto,	0 CostoFlete,	
		0 PrecioRentaDiario,	0 PrecioRentaSemanal,	0 PrecioRentaMensual,	
		''Pesos'' Moneda,0 TiempoEntrega,0 DescuentoSobrePrecioLista,	1 CondicionesCompra,	0 PrecioRentaHora,	0 PrecioRentaQuincenal,	0 CargoMinimo
		 from  Catamodelos where idmodelo >'+@Max+' ' -- imprime que se inserto x2 
		 
		exec(@sqlqry2)

		set @sqlqry  = 'drop table PruebasLineas' -- Borramos la tabla temporal ya que , ya la utilizamos para las comparaciones
		print 'Tabla Temporal Borrada'
		exec(@sqlqry)


			

			 end -- FIN DE Modelos

			 if @tipo ='Refacciones' 
			 begin 

			 
					set @sqlqry  = 
					'select 
					Row_Number() over (order by Codigo) idRefaccion,
					Row_Number() over (partition by Codigo order by Codigo)idmov,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Codigo,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Codigo,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Descripcion,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Descripcion,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Marca,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Marca,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Proveedor,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Proveedor,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Existencia,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Cantidad,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Ubicacion,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Ubicacion

					 into PruebasRefacciones from OPENROWSET 
					 (''Microsoft.ACE.OLEDB.12.0'','+'''Excel 12.0 Xml;HRD=YES;'''+@datasrc+','+
					 '''SELECT * FROM ' +@sheet+''')'

				

		exec(@sqlqry) -- insertar la cadena que tiene el select into TODO LO DE ARRIBA


		
					  set @sqlqry = 'delete from PruebasRefacciones where Codigo = '''' or Codigo is null or idmov >1'
					   exec(@sqlqry) -- Limpia la tabla si no hay valores registrados como en este caso la razon social si no hay pues pelamos gallo


					   set  @colation = 'select  COLLATION_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = ''CataRefacciones'' and COLUMN_NAME = ''Codigo'''
					    -- obtener el colation de la columna la cual hara el inner join para que lo inserte 
						execute(@colation)

		set @sqlqry='alter table PruebasRefacciones alter column Codigo nvarchar(1000) '+@colation+';'
		+' alter table PruebasRefacciones alter column Proveedor nvarchar(1000) '+@colation+';'
		exec(@sqlqry)-- ACTUALIZA EL TIPO DE TEXTO para hacer uniones


		select @Max=isnull(max(IdRefaccion),0) from CataRefacciones
		select @Max2=max(IdRefaccionSucursal) from CataRefaccionesSucursal



		/* SI NO EXISTE EL PROVEEDOR LO AGREGAMOS.*/

					set @sqlqry = '
		insert into CataProveedores
		select Row_number() over (order by pbr.Proveedor)+'+convert(varchar,(select max(IdProveedor) from CataProveedores))+' idProveedor,pbr.Proveedor RazonSocial,
		 '''' RFC,'''' curp,'''' Contacto,'''' Telefonos,null Faxes, '''' Emails,'''' CalleNumero,'''' CP,
		''''Colonia,'''' MunicipioDelegacion ,'''' ciudad, '''' Estado,''insertado desde refaccion generico'' Observaciones, 
		null SujetoRetencion, null CuentaDeposito,  null CuentaContable, 
		'+convert(varchar,@Sucursal)+' SucursalProveedor, null Referencia,0 LimiteCredito, 0 DiasCredito, null Contacto1, null TelContacto1,
		null EmailContacto1, null Contacto2, null TelContacto2, null EmailContacto2, null Contacto3, null TelContacto3,
		null EmailContacto3, null PagaTransferencia, null PagaBancoReferencia, null ReferenciaBancaria,
		null RequiereEnvioFacturaFisica, null ObservacionesImportacion, 
		''Moral'' PersonaFiscal, null ApellidoPaterno,
		null ApellidoMaterno, null Nombres,null IdClasificacionProveedor,null USOCFDI,null CuentaContable2,
		null CuentaContable3,null CuentaContable4,null WhatsAppContacto, null WhatsAppContacto1, null WhatsAppContacto2,
		null WhatsAppContacto3,null IdBanco,null CuentaBancariaDestino,null RequiereAutorizacionA, null RequiereAutorizacionB,
		null RequiereAutorizacionC, null CuentaBancariaOrigen, null AliasPortalBancario, null ClaveFormaPagoPortal,
		null CuentaBancariaOrigenUSD,null CuentaBancariaDestinoUSD, null AliasPortalBancarioUSD,null PagosMXP,null PagosUSD,
		null PreMoneda, null PrePorcentajeIVA,null PrePorcentajeRetencion1, null PrePorcentajeRetencion2,  null PrePorcentajeImpuesto1
		,null PrePorcentajeImpuesto2, null ClaveFormaPagoPortalUSD
		from PruebasRefacciones pbr 
		left join CataProveedores pro on pro.RazonSocial = pbr.Proveedor
		where pro.Razonsocial is null
		group by pbr.proveedor' 
		-- INSSERCION A CataProveedores DE LO QUE SOLAMENTE NO SE ENCUENTRA
		
		exec(@sqlqry)


		set @sqlqry2 = '
		insert into CataProveedoresSucursal
			select IdProveedor, '+convert(varchar,@Sucursal)+' IdSucursal, Row_Number()over (order by RazonSocial)+'+convert(varchar,(select max(IdProveedorSucursal) from CataProveedoresSucursal))+' IdProveedorSucursal,  Contacto,  Telefonos, NULL Faxes,0 CompraDescuentoEquipos,0 CompraDescuentoEquiposExtra ,0 CompraDescuentoEquipos2, 0 CompraDescuentoEquiposExtra2,
0 CompraDescuentoEquipos3, 0 CompraDescuentoEquiposExtra3, 0 CompraDescuentoRefacciones, 0 CompraDescuentoRefaccionesExtra, 0 CompraDescuentoRefacciones2, 0 CompraDescuentoRefaccionesExtra2,0 CompraDescuentoRefacciones3,
0 CompraDescuentoRefaccionesExtra3, 0 CompraDiasCreditoEquipos,0 CompraDiasCreditoRefacciones,0 CompraDiasCreditoEquipos2,0 CompraDiasCreditoRefacciones2,0 CompraDiasCreditoEquipos3,0 CompraDiasCreditoRefacciones3,
0 VentaPorcentajeGananciaEquiposNuevosClienteA,0 VentaPorcentajeGananciaEquiposNuevosClienteB,0 VentaPorcentajeGananciaEquiposNuevosClienteC,0 VentaPorcentajeGananciaEquiposNuevosClienteD,0 VentaPorcentajeGananciaEquiposUsadosClienteA,
0 VentaPorcentajeGananciaEquiposUsadosClienteB,0 VentaPorcentajeGananciaEquiposUsadosClienteC,0 VentaPorcentajeGananciaEquiposUsadosClienteD,0 VentaPorcentajeGananciaAccesoriosParteClienteA,0 VentaPorcentajeGananciaAccesoriosParteClienteB,
0 VentaPorcentajeGananciaAccesoriosParteClienteC,0 VentaPorcentajeGananciaAccesoriosParteClienteD,0 VentaPorcentajeGananciaAccesoriosConsumibleClienteA,0 VentaPorcentajeGananciaAccesoriosConsumibleClienteB,
0 VentaPorcentajeGananciaAccesoriosConsumibleClienteC,0 VentaPorcentajeGananciaAccesoriosConsumibleClienteD,0 VentaPorcentajeGananciaRefaccionesClienteA,0 VentaPorcentajeGananciaRefaccionesClienteB,
0 VentaPorcentajeGananciaRefaccionesClienteC,0 VentaPorcentajeGananciaRefaccionesClienteD, NULL Observaciones
		 from  CataProveedores where idproveedor >'+convert(varchar,(select max(IdProveedor)-1 from CataProveedores))+'  '
		-- INSERCION A CATACLIENTES DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)

		/**/
	
		set @sqlqry = ' 
		select 
		Row_Number()over (order by pbr.Codigo)+'+@Max+' IdRefaccion,pbr.Codigo,	'''' CodigoAlternoProveedor,	pro.IdProveedor,	pbr.Descripcion,	0 Accesorio,	'''' TipoAccesorio,	convert(date,getdate()) FechaUltimaActualizacion,
		'''' GrupoRefaccion,	'''' TipoRefaccion,'''' CodigoAlternoInterno,0 Descontinuado,	0 PrecioVenta,	'''' MonedaVenta,	0 PrecioVenta2,	'''' MonedaVenta2,	0 PrecioCompra,	'''' MonedaCompra,	0 Peso,	pbr.Marca,
		0 IdAccesorio,	'''' CalculoPrecioVenta,0 PrecioCompra2,'''' MonedaCompra2,	0 PrecioCompra3,	'''' MonedaCompra3,	0 AditamentoEquipo,	''Nuevo'' CondicionesParte,	0 MilimetrajeAditamento,	0 IdUnidadMedida,
		'''' ClaveProductoSAT,	'''' UnidadMedidaSAT,'''' CodigoBarras,'''' ClaveUnidadPesoSAT,'''' ClaveTipoEmbalajeSAT,	0 AplicaIVA,	0 AplicaRet1,	0 AplicaRet2,	0 AplicaIEPS1,	0 AplicaIEPS2
		from pruebasRefacciones pbr
		left join CataProveedores pro on pro.RazonSocial = pbr.Proveedor
		left join CataRefacciones ref on ref.Codigo = pbr.Codigo
		where ref.Codigo is null 
		'
		execute (@sqlqry)


			set @sqlqry = ' 
		insert into cataRefacciones select 
		Row_Number()over (order by pbr.Codigo)+'+@Max+' IdRefaccion,pbr.Codigo,	'''' CodigoAlternoProveedor,	pro.IdProveedor,	pbr.Descripcion,	0 Accesorio,	'''' TipoAccesorio,	convert(date,getdate()) FechaUltimaActualizacion,
		'''' GrupoRefaccion,	'''' TipoRefaccion,'''' CodigoAlternoInterno,0 Descontinuado,	0 PrecioVenta,	'''' MonedaVenta,	0 PrecioVenta2,	'''' MonedaVenta2,	0 PrecioCompra,	'''' MonedaCompra,	0 Peso,	pbr.Marca,
		0 IdAccesorio,	'''' CalculoPrecioVenta,0 PrecioCompra2,'''' MonedaCompra2,	0 PrecioCompra3,	'''' MonedaCompra3,	0 AditamentoEquipo,	''Nuevo'' CondicionesParte,	0 MilimetrajeAditamento,	0 IdUnidadMedida,
		'''' ClaveProductoSAT,	'''' UnidadMedidaSAT,'''' CodigoBarras,'''' ClaveUnidadPesoSAT,'''' ClaveTipoEmbalajeSAT,	0 AplicaIVA,	0 AplicaRet1,	0 AplicaRet2,	0 AplicaIEPS1,	0 AplicaIEPS2
		from pruebasRefacciones pbr
		left join CataProveedores pro on pro.RazonSocial = pbr.Proveedor
		left join CataRefacciones ref on ref.Codigo = pbr.Codigo
		where ref.Codigo is null 
		'
		execute (@sqlqry)



		set @sqlqry2 = '
	select	'+convert(varchar,@Sucursal)+' IdSucursal,	Row_number() over (order by ref.idrefaccion)+'+@Max2+' IdRefaccionSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo,	ref.IdRefaccion,rof.Cantidad,	0 CantidadOrdenar,	
	0 PuntoReorden,	0 CantidadSeguridad,	0 PrecioListaProveedor,	''Pesos'' Moneda,	0 MultiplosCompra,	
	0 MinimoCompra,	0 CondicionesCompra,	0 UltimoCosto,	0 CostoFlete,	0 Costo,	'''' Ubicacion,	0 TiempoEntrega,	0 ExistenciaFisicaCongelada,	'''' FechaCongelaExistencia
	from catarefacciones ref 
	inner join PruebasRefacciones rof on rof.codigo = ref.Codigo
	where ref.IdRefaccion >'+@Max+'
	'
	execute(@sqlqry2)

		set @sqlqry2 = '
	insert into CataRefaccionesSucursal select	'+convert(varchar,@Sucursal)+' IdSucursal,	Row_number() over (order by ref.idrefaccion)+'+@Max2+' IdRefaccionSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo,	ref.IdRefaccion,rof.Cantidad,	0 CantidadOrdenar,	
	0 PuntoReorden,	0 CantidadSeguridad,	0 PrecioListaProveedor,	''Pesos'' Moneda,	0 MultiplosCompra,	
	0 MinimoCompra,	0 CondicionesCompra,	0 UltimoCosto,	0 CostoFlete,	0 Costo,	'''' Ubicacion,	0 TiempoEntrega,	0 ExistenciaFisicaCongelada,	'''' FechaCongelaExistencia
	from catarefacciones ref 
	inner join PruebasRefacciones rof on rof.codigo = ref.Codigo
	where ref.IdRefaccion >'+@Max+'
	'
	execute(@sqlqry2)
			 end ------ FIN DE REFACCIONES 

			 if @tipo ='Rentas' 
			 begin 


					set @sqlqry  = 
					'select 
					Row_Number() over (order by NumeroInterno) idEquipoRenta,
					Row_Number() over (partition by NumeroInterno,Linea,Modelo order by NumeroInterno)idmov3,
					Row_Number() over (partition by Linea,Modelo order by NumeroInterno)idmov2,
					Row_Number() over (partition by NumeroInterno order by NumeroInterno)idmov,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(NumeroInterno,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))NumeroInterno,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(NumeroSerieEquipo,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))NumeroSerieEquipo,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Linea,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Linea,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Modelo,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Modelo,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Marca,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Marca,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Horometro,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Horometro   


					 into PruebasRentas from OPENROWSET 
					 (''Microsoft.ACE.OLEDB.12.0'','+'''Excel 12.0 Xml;HRD=YES;'''+@datasrc+','+
					 '''SELECT * FROM ' +@sheet+''')'

				

		exec(@sqlqry) -- insertar la cadena que tiene el select into TODO LO DE ARRIBA

		
					  set @sqlqry = 'delete from PruebasRentas where NumeroInterno = '''' or NumeroInterno is null or idmov3 >1'
					   exec(@sqlqry) -- Limpia la tabla si no hay valores registrados como en este caso la razon social si no hay pues pelamos gallo

						set @sqlqry = 'update  PruebasRentas set numeroInterno=NumeroInterno+convert(varchar,idmov) where idmov >1'
					   exec(@sqlqry) -- actualizamos por que si peude haber 2 equipos de la misma linea y diferentes modelos pero tiene que ser diferentes numeros economicos

					     set  @colation = 'select  COLLATION_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = ''CataEquiposRenta'' and COLUMN_NAME = ''NumeroInterno'' '
					    -- obtener el colation de la columna la cual hara el inner join para que lo inserte 
						execute(@colation)

		set @sqlqry='alter table PruebasRentas alter column NumeroInterno nvarchar(1000) '+@colation+';'
		+' alter table PruebasRentas alter column Linea nvarchar(1000)'+@colation+';'
		+' alter table PruebasRentas alter column Modelo nvarchar(1000)'+@colation+';'
		--' alter table PruebasRentas alter column Modelo nvarchar(1000) '+@colation+';'
		exec(@sqlqry)-- ACTUALIZA EL TIPO DE TEXTO para hacer uniones

		select @Max=isnull(max(idEquipoRenta),0) from CataEquiposRenta

			/*	SI NO EXISTEN LAS LINEAS DEL EXCEL EJECUTA Lo SIGUIENTE */
				set @sqlqry = '
		insert into catalineas
			select Row_number() over (order by Linea)+'+convert(varchar,(select max(IdLinea) from CataLineas))+' idlinea,
			pbr.Linea, '''' Descripcion,''N'' Gasto,''N'' Horometro,null Codigo, 
		null IdLineaClasificacion , null ClaveProductoSat, null UnidadMedidaSat, null SeguroObligatorio,null CostoMinimoAsegurar
		from (select top (1) Linea from PruebasRentas model
left join catalineas lin on lin.Nombre = model.linea
where lin.Nombre is null) pbr left join catalineas lin on lin.Nombre = pbr.Linea where nombre is null ' 
		-- INSSERCION A CATALINEAS DE LO QUE SOLAMENTE NO SE ENCUENTRA
		
		exec(@sqlqry)


		set @sqlqry2 = '
		insert into CataLineasSucursal
		select Row_number() over (order by IdLinea)+'+@Max2+' IdLineaSucursal,IdLinea,'+convert(varchar,@Sucursal)+' IdSucursal, '+convert(varchar,@Centro)+' IdCentroOperativo,1 DepreciacionContableMeses, 1 DepreciacionContablePorcentaje,
		0 TiempoVenta, ''N'' Aseguradora,null PrecioRentaDiario,null PrecioRentaSemanal, null PrecioRentaQuincenal, null PrecioRentaMensual, null PrecioRentaHora,null MonedaRenta
		 from  catalineas where idlinea >'+convert(varchar,(select max(IdLinea) from CataLineas))+'
		'
		-- INSERCION A catalineas DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)


		/* FIN */
		
		/*	SI NO EXISTEN Los Modelos DEL EXCEL EJECUTA Lo SIGUIENTE */
		set @sqlqry = '	insert into Catamodelos
		
		select ROW_NUMBER() over (order by pbr.modelo)+(select max(IdModelo) from CataModelos) IdModelo,lin.idlinea,
			pbr.modelo,	'''' CodigoProveedor,	0 IdProveedor,	pbr.Marca,	'''' Descripcion,	'''' CaracteristicasTecnicas,'''' Cuidados,
			'''' Moneda, 0 PrecioListaVenta,	0 PrecioListaProveedor,	'''' FechaUltimaActualizacion,	1 Activo,	0 CostoBase,	0 PorcentajeMinimoGanancia,
				'''' Familia,'''' ImagenModelo,'''' CaracteristicasRFT,0 Peso,	
  '''' RubroMaquinaria,	'''' CalculoPrecioVenta,	0 IdModeloCategoria,	0 PrecioListaVenta2,'''' Moneda2,	0 Vehiculo,	0 KmPorDia,
  '''' ClaveProductoSAT,'''' CataServicios,'''' LeyendaReconstruido,	
    '''' ClaveUnidadPesoSAT,'''' ClaveTipoEmbalajeSAT

		from (select * from (
select  ROW_NUMBER()over (partition by pbr.modelo order by pbr.modelo)idmov,
			pbr.modelo,pbr.Linea,pbr.marca
		from PruebasRentas pbr left join catamodelos modeli on modeli.Nombre = pbr.Modelo
left join catalineas lin on lin.Nombre = pbr.linea
where modeli.Nombre is null ) q2 where idmov <2) pbr left join catamodelos modeli on modeli.Nombre = pbr.Modelo
left join catalineas lin on lin.Nombre = pbr.linea
where modeli.Nombre is null
 '  
exec(@sqlqry)

	set @sqlqry2 = '
		insert into CataModelosSucursal
		select Row_number()over (order by idmodelo)+'+isnull(@Max2,0)+' IdModeloSucursal,	 IdModelo,	'+convert(varchar,@Sucursal)+' IdSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo,	0 UltimoCosto,	0 CostoFlete,	
		0 PrecioRentaDiario,	0 PrecioRentaSemanal,	0 PrecioRentaMensual,	
		''Pesos'' Moneda,0 TiempoEntrega,0 DescuentoSobrePrecioLista,	1 CondicionesCompra,	0 PrecioRentaHora,	0 PrecioRentaQuincenal,	0 CargoMinimo
		 from  Catamodelos where idmodelo >'+convert(varchar,(select max(IdModelo) from CataModelos))+' '
		-- INSERCION A CATACLIENTES DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)

		/* FIN */

		/*ahora con EQUIPOS*/


		set @sqlqry = ' 
	 select 
 Row_number() over (order by pbr.NumeroInterno)+'+convert(varchar,@Max)+' IdEquipoRenta,'+convert(varchar,@sucursal)+' IdSucursal,'+convert(varchar,@centro)+' IdCentroOperativo,
 lin.IdLinea,model.IdModelo
 ,pbr.NumeroInterno,pbr.NumeroSerieEquipo,'''' NumeroSerieMotor,''''  NumeroPlaca,''Empresa''  Propietario,
''Disponible''  Estado,pbr.Horometro,0 CostoNacional,0 CostoEUA,0 TipoCambio,''''  NumeroFactura,''''  Aduana,''''  PedimentoImportacion,''''  FechaPedimento,''''  FechaFactura,
''''  FechaAltaEmpresa,''''  FechaAltaSucursal,''''  FechaUltimaAlta,''''  FechaPRUVTB,''''  ObservacionesPRUVTB,''''  EstadoAnteriorPR,0 DepreciacionContableAnterior,
0 IngresosAnteriores,0 GastosAnteriores,''N''  Asegurado,0 IdEquipoUsado,0 IdEquipoNuevo,''''  CuentaContable,''''  Comentarios,''''  Ubicacion,
''''  NumeroSerieAdicional,''''  NumeroSerieAdicional2,''''  Localizacion,0 IdModeloVersion,''''  AnoModelo,0 IdProveedor,0 IdPolizaEQR,''''  FechaEstado,
''''  NumeroIdentificacionVehicular,''''  SerieAlternador,''''  MarcaMotor,0 Horometro2,0 IdModelo2,0 IdEmpleado,0 IdArrendamientoEQR,0 BloqueadoPorGPS,
0 PrecioRentaDiario,0 PrecioRentaSemanal,0 PrecioRentaQuincenal,0 PrecioRentaMensual,0 PrecioRentaHora,
''''  MonedaRenta,0 IdConPed,0 RetornoTemporal,0 IdOrdenTrabajo,0 IdEmpleadoVendedor,''''  FechaVendedor,''''  DetallesVendedorAsignado,0 IdCotizacion
from pruebasRentas pbr
left join CataLineas lin on lin.Nombre = pbr.Linea
left join catamodelos model on model.Nombre = pbr.modelo
left join CataEquiposRenta ren on ren.NumeroInterno = pbr.numeroInterno
where ren.NumeroInterno is null 
'
execute (@sqlqry)

set @sqlqry = ' 
	insert into cataEquiposRenta select 
 Row_number() over (order by pbr.NumeroInterno)+'+@Max+' IdEquipoRenta,'+convert(varchar,@sucursal)+' IdSucursal,'+convert(varchar,@centro)+' IdCentroOperativo,lin.IdLinea,model.IdModelo,
 pbr.NumeroInterno,pbr.NumeroSerieEquipo,'''' NumeroSerieMotor,''''  NumeroPlaca,''Empresa''  Propietario,
''Disponible''  Estado,0 Horometro,0 CostoNacional,0 CostoEUA,0 TipoCambio,''''  NumeroFactura,''''  Aduana,''''  PedimentoImportacion,''''  FechaPedimento,''''  FechaFactura,
''''  FechaAltaEmpresa,''''  FechaAltaSucursal,''''  FechaUltimaAlta,''''  FechaPRUVTB,''''  ObservacionesPRUVTB,''''  EstadoAnteriorPR,0 DepreciacionContableAnterior,
0 IngresosAnteriores,0 GastosAnteriores,''N''  Asegurado,0 IdEquipoUsado,0 IdEquipoNuevo,''''  CuentaContable,''''  Comentarios,''''  Ubicacion,
''''  NumeroSerieAdicional,''''  NumeroSerieAdicional2,''''  Localizacion,0 IdModeloVersion,''''  AnoModelo,0 IdProveedor,0 IdPolizaEQR,''''  FechaEstado,
''''  NumeroIdentificacionVehicular,''''  SerieAlternador,''''  MarcaMotor,0 Horometro2,0 IdModelo2,0 IdEmpleado,0 IdArrendamientoEQR,0 BloqueadoPorGPS,
0 PrecioRentaDiario,0 PrecioRentaSemanal,0 PrecioRentaQuincenal,0 PrecioRentaMensual,0 PrecioRentaHora,
''''  MonedaRenta,0 IdConPed,0 RetornoTemporal,0 IdOrdenTrabajo,0 IdEmpleadoVendedor,''''  FechaVendedor,''''  DetallesVendedorAsignado,0 IdCotizacion
from pruebasRentas pbr
left join CataLineas lin on lin.Nombre = pbr.Linea
left join catamodelos model on model.Nombre = pbr.modelo
left join CataEquiposRenta ren on ren.NumeroInterno = pbr.numeroInterno
where ren.NumeroInterno is null 
'

execute (@sqlqry)

			 end -- FIN DE EQUIPOS EN RENTA 


			 if @tipo = 'Nuevos'
			 begin 

			 			set @sqlqry  = 
					'select 
					Row_Number() over (order by NumeroSerieEquipo) IdEquipoNuevo,
					Row_Number() over (partition by NumeroSerieEquipo,Linea,Modelo order by NumeroSerieEquipo)idmov3,
					Row_Number() over (partition by Linea,Modelo order by NumeroSerieEquipo)idmov2,
					Row_Number() over (partition by NumeroSerieEquipo order by NumeroSerieEquipo)idmov,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(NumeroSerieEquipo,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))NumeroSerieEquipo,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Linea,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Linea,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Modelo,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Modelo,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Marca,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Marca 

					 into PruebasNuevos from OPENROWSET 
					 (''Microsoft.ACE.OLEDB.12.0'','+'''Excel 12.0 Xml;HRD=YES;'''+@datasrc+','+
					 '''SELECT * FROM ' +@sheet+''')'

				

		exec(@sqlqry) -- insertar la cadena que tiene el select into TODO LO DE ARRIBA

		
					  set @sqlqry = 'delete from PruebasNuevos where NumeroSerieEquipo = '''' or NumeroSerieEquipo is null or idmov3 >1'
					   exec(@sqlqry) -- Limpia la tabla si no hay valores registrados como en este caso la razon social si no hay pues pelamos gallo

						set @sqlqry = 'update  PruebasNuevos set NumeroSerieEquipo=NumeroSerieEquipo+convert(varchar,idmov) where idmov >1'
					   exec(@sqlqry) -- actualizamos por que si peude haber 2 equipos de la misma linea y diferentes modelos pero tiene que ser diferentes numeros economicos

					     set  @colation = 'select  COLLATION_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = ''CataEquiposNuevos'' and COLUMN_NAME = ''NumeroSerieEquipo'' '
					    -- obtener el colation de la columna la cual hara el inner join para que lo inserte 
						execute(@colation)

		set @sqlqry='alter table PruebasNuevos alter column NumeroSerieEquipo nvarchar(1000) '+@colation+';'
		+' alter table PruebasNuevos alter column Linea nvarchar(1000)'+@colation+';'
		+' alter table PruebasNuevos alter column Modelo nvarchar(1000)'+@colation+';'
		--' alter table PruebasRentas alter column Modelo nvarchar(1000) '+@colation+';'
		exec(@sqlqry)-- ACTUALIZA EL TIPO DE TEXTO para hacer uniones

		select @Max=isnull(max(IdEquipoNuevo),0) from CataEquiposNuevos

			/*	SI NO EXISTEN LAS LINEAS DEL EXCEL EJECUTA Lo SIGUIENTE */
				set @sqlqry = '
		insert into catalineas
			select Row_number() over (order by Linea)+'+convert(varchar,(select max(IdLinea) from CataLineas))+' idlinea,
			pbr.Linea, '''' Descripcion,''N'' Gasto,''N'' Horometro,null Codigo, 
		null IdLineaClasificacion , null ClaveProductoSat, null UnidadMedidaSat, null SeguroObligatorio,null CostoMinimoAsegurar
		from (select top (1) Linea from PruebasNuevos model
left join catalineas lin on lin.Nombre = model.linea
where lin.Nombre is null) pbr left join catalineas lin on lin.Nombre = pbr.Linea where nombre is null ' 
		-- INSSERCION A CATALINEAS DE LO QUE SOLAMENTE NO SE ENCUENTRA
		
		exec(@sqlqry)


		set @sqlqry2 = '
		insert into CataLineasSucursal
		select Row_number() over (order by IdLinea)+'+@Max2+' IdLineaSucursal,IdLinea,'+convert(varchar,@Sucursal)+' IdSucursal, '+convert(varchar,@Centro)+' IdCentroOperativo,1 DepreciacionContableMeses, 1 DepreciacionContablePorcentaje,
		0 TiempoVenta, ''N'' Aseguradora,null PrecioRentaDiario,null PrecioRentaSemanal, null PrecioRentaQuincenal, null PrecioRentaMensual, null PrecioRentaHora,null MonedaRenta
		 from  catalineas where idlinea >'+convert(varchar,(select max(IdLinea) from CataLineas))+'
		'
		-- INSERCION A catalineas DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)


		/* FIN */
		
		/*	SI NO EXISTEN Los Modelos DEL EXCEL EJECUTA Lo SIGUIENTE */
		set @sqlqry = '	insert into Catamodelos
		
		select ROW_NUMBER() over (order by pbr.modelo)+(select max(IdModelo) from CataModelos) IdModelo,lin.idlinea,
			pbr.modelo,	'''' CodigoProveedor,	0 IdProveedor,	pbr.Marca,	'''' Descripcion,	'''' CaracteristicasTecnicas,'''' Cuidados,
			'''' Moneda, 0 PrecioListaVenta,	0 PrecioListaProveedor,	'''' FechaUltimaActualizacion,	1 Activo,	0 CostoBase,	0 PorcentajeMinimoGanancia,
				'''' Familia,'''' ImagenModelo,'''' CaracteristicasRFT,0 Peso,	
  '''' RubroMaquinaria,	'''' CalculoPrecioVenta,	0 IdModeloCategoria,	0 PrecioListaVenta2,'''' Moneda2,	0 Vehiculo,	0 KmPorDia,
  '''' ClaveProductoSAT,'''' CataServicios,'''' LeyendaReconstruido,	
    '''' ClaveUnidadPesoSAT,'''' ClaveTipoEmbalajeSAT

		from (select * from (
select  ROW_NUMBER()over (partition by pbr.modelo order by pbr.modelo)idmov,
			pbr.modelo,pbr.Linea,pbr.marca
		from PruebasNuevos pbr left join catamodelos modeli on modeli.Nombre = pbr.Modelo
left join catalineas lin on lin.Nombre = pbr.linea
where modeli.Nombre is null ) q2 where idmov <2) pbr left join catamodelos modeli on modeli.Nombre = pbr.Modelo
left join catalineas lin on lin.Nombre = pbr.linea
where modeli.Nombre is null
 '  
exec(@sqlqry)

	set @sqlqry2 = '
		insert into CataModelosSucursal
		select Row_number()over (order by idmodelo)+'+isnull(@Max2,0)+' IdModeloSucursal,	 IdModelo,	'+convert(varchar,@Sucursal)+' IdSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo,	0 UltimoCosto,	0 CostoFlete,	
		0 PrecioRentaDiario,	0 PrecioRentaSemanal,	0 PrecioRentaMensual,	
		''Pesos'' Moneda,0 TiempoEntrega,0 DescuentoSobrePrecioLista,	1 CondicionesCompra,	0 PrecioRentaHora,	0 PrecioRentaQuincenal,	0 CargoMinimo
		 from  Catamodelos where idmodelo >'+convert(varchar,(select max(IdModelo) from CataModelos))+' '
		-- INSERCION A CATACLIENTES DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)

		/* FIN */

		/*ahora con EQUIPOS*/


		set @sqlqry = ' 
select Row_number()over (order by pbr.NumeroSerieEquipo)+'+convert(varchar,@Max)+' IdEquipoNuevo,	'+convert(varchar,@Sucursal)+' IdSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo,	lin.IdLinea, model.IdModelo,
 pbr.NumeroSerieEquipo,	'''' NumeroSerieMotor,	''Empresa'' Propietario,	'''' PropietarioAnterior,	''Disponible'' Estado,	'''' EstadoAnterior,	0 Horometro,convert(date,getdate()) FechaAlta,	'''' Ubicacion,	
 '''' CompraFacturaNumero,'''' CompraFacturaFecha,	0 TipoCambio,	0 CostoNacional,	0 CostoEUA,	'''' Aduana,	'''' PedimentoImportacion,	'''' FechaPedimento,	'''' NumeroInterno,	'''' FechaRPVTD,'''' ObservacionesRPVTD,
 0 IdEquipoRenta,	'''' CuentaContable,	'''' Comentarios,	'''' NumeroSerieAdicional,	'''' NumeroSerieAdicional2,	'''' Localizacion,	0 IdModeloVersion,	'''' AñoModelo,	'''' NumeroIdentificacionVehicular,
'''' SerieAlternador,	'''' MarcaMotor,	0 Horometro2,	0 IdModelo2
	from PruebasNuevos pbr
left join CataLineas lin on lin.Nombre = pbr.Linea
left join catamodelos model on model.Nombre = pbr.modelo
left join CataEquiposNuevos new on new.NumeroSerieEquipo = pbr.NumeroSerieEquipo
where new.NumeroSerieEquipo is null '

exec(@sqlqry)

set @sqlqry = ' 
	insert into  CataEquiposNuevos  
select Row_number()over (order by pbr.NumeroSerieEquipo)+'+convert(varchar,@Max)+' IdEquipoNuevo,	'+convert(varchar,@Sucursal)+' IdSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo,	lin.IdLinea ,model.IdModelo,
 pbr.NumeroSerieEquipo,	'' '' NumeroSerieMotor,	''Empresa'' Propietario,	'''' PropietarioAnterior,	''Disponible'' Estado,	'''' EstadoAnterior,	0 Horometro,convert(date,getdate()) FechaAlta,	'''' Ubicacion,	'''' CompraFacturaNumero,
 '''' CompraFacturaFecha,	0 TipoCambio,	0 CostoNacional,	0 CostoEUA,	'''' Aduana,	'''' PedimentoImportacion,	'''' FechaPedimento,	'''' NumeroInterno,	'''' FechaRPVTD,'''' ObservacionesRPVTD,
 0 IdEquipoRenta,	'''' CuentaContable,	'''' Comentarios,	'''' NumeroSerieAdicional,	'''' NumeroSerieAdicional2,	'''' Localizacion,	0 IdModeloVersion,	'''' AñoModelo,	'''' NumeroIdentificacionVehicular,
'''' SerieAlternador,	'''' MarcaMotor,	0 Horometro2,	0 IdModelo2
	from PruebasNuevos pbr
left join CataLineas lin on lin.Nombre = pbr.Linea
left join catamodelos model on model.Nombre = pbr.modelo
left join CataEquiposNuevos new on new.NumeroSerieEquipo = pbr.NumeroSerieEquipo
where new.NumeroSerieEquipo is null'

execute(@sqlqry)
			 end  -- FIN DE EQUIPOS NUEVO

			 	 if @tipo = 'Usados'
			 begin 
			 
			 			set @sqlqry  = 
					'select 
					Row_Number() over (order by NumeroInterno) idEquipoRenta,
					Row_Number() over (partition by NumeroInterno,Linea,Modelo order by NumeroInterno)idmov3,
					Row_Number() over (partition by Linea,Modelo order by NumeroInterno)idmov2,
					Row_Number() over (partition by NumeroInterno order by NumeroInterno)idmov,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(NumeroInterno,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))NumeroInterno,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(NumeroSerieEquipo,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))NumeroSerieEquipo,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Linea,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Linea,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Modelo,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Modelo,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Marca,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Marca


					 into PruebasUsados from OPENROWSET 
					 (''Microsoft.ACE.OLEDB.12.0'','+'''Excel 12.0 Xml;HRD=YES;'''+@datasrc+','+
					 '''SELECT * FROM ' +@sheet+''')'

				

		exec(@sqlqry) -- insertar la cadena que tiene el select into TODO LO DE ARRIBA

		
					  set @sqlqry = 'delete from PruebasUsados where NumeroInterno = '''' or NumeroInterno is null or idmov3 >1'
					   exec(@sqlqry) -- Limpia la tabla si no hay valores registrados como en este caso la razon social si no hay pues pelamos gallo

						set @sqlqry = 'update  PruebasUsados set numeroInterno=NumeroInterno+convert(varchar,idmov) where idmov >1'
					   exec(@sqlqry) -- actualizamos por que si peude haber 2 equipos de la misma linea y diferentes modelos pero tiene que ser diferentes numeros economicos

					     set  @colation = 'select  COLLATION_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = ''CataEquiposUsados'' and COLUMN_NAME = ''NumeroSerieEquipo'' '
					    -- obtener el colation de la columna la cual hara el inner join para que lo inserte 
						execute(@colation)

		set @sqlqry='alter table PruebasUsados alter column NumeroSerieEquipo nvarchar(1000) '+@colation+';'
		+' alter table PruebasUsados alter column Linea nvarchar(1000)'+@colation+';'
		+' alter table PruebasUsados alter column Modelo nvarchar(1000)'+@colation+';'
		+' alter table PruebasUsados alter column NumeroInterno nvarchar(1000) '+@colation+';'
		exec(@sqlqry)-- ACTUALIZA EL TIPO DE TEXTO para hacer uniones

		select @Max=isnull(max(IdEquipoUsado),0) from cataEquiposUsados

			/*	SI NO EXISTEN LAS LINEAS DEL EXCEL EJECUTA Lo SIGUIENTE */
				set @sqlqry = '
		insert into catalineas
			select Row_number() over (order by Linea)+'+convert(varchar,(select max(IdLinea) from CataLineas))+' idlinea,
			pbr.Linea, '''' Descripcion,''N'' Gasto,''N'' Horometro,null Codigo, 
		null IdLineaClasificacion , null ClaveProductoSat, null UnidadMedidaSat, null SeguroObligatorio,null CostoMinimoAsegurar
		from (select top (1) Linea from PruebasUsados model
left join catalineas lin on lin.Nombre = model.linea
where lin.Nombre is null) pbr left join catalineas lin on lin.Nombre = pbr.Linea where nombre is null ' 
		-- INSSERCION A CATALINEAS DE LO QUE SOLAMENTE NO SE ENCUENTRA
		
		exec(@sqlqry)


		set @sqlqry2 = '
		insert into CataLineasSucursal
		select Row_number() over (order by IdLinea)+'+@Max2+' IdLineaSucursal,IdLinea,'+convert(varchar,@Sucursal)+' IdSucursal, '+convert(varchar,@Centro)+' IdCentroOperativo,1 DepreciacionContableMeses, 1 DepreciacionContablePorcentaje,
		0 TiempoVenta, ''N'' Aseguradora,null PrecioRentaDiario,null PrecioRentaSemanal, null PrecioRentaQuincenal, null PrecioRentaMensual, null PrecioRentaHora,null MonedaRenta
		 from  catalineas where idlinea >'+convert(varchar,(select max(IdLinea) from CataLineas))+'
		'
		-- INSERCION A catalineas DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)


		/* FIN */
		
		/*	SI NO EXISTEN Los Modelos DEL EXCEL EJECUTA Lo SIGUIENTE */
		set @sqlqry = '	insert into Catamodelos
		
		select ROW_NUMBER() over (order by pbr.modelo)+(select max(IdModelo) from CataModelos) IdModelo,lin.idlinea,
			pbr.modelo,	'''' CodigoProveedor,	0 IdProveedor,	pbr.Marca,	'''' Descripcion,	'''' CaracteristicasTecnicas,'''' Cuidados,
			'''' Moneda, 0 PrecioListaVenta,	0 PrecioListaProveedor,	'''' FechaUltimaActualizacion,	1 Activo,	0 CostoBase,	0 PorcentajeMinimoGanancia,
				'''' Familia,'''' ImagenModelo,'''' CaracteristicasRFT,0 Peso,	
  '''' RubroMaquinaria,	'''' CalculoPrecioVenta,	0 IdModeloCategoria,	0 PrecioListaVenta2,'''' Moneda2,	0 Vehiculo,	0 KmPorDia,
  '''' ClaveProductoSAT,'''' CataServicios,'''' LeyendaReconstruido,	
    '''' ClaveUnidadPesoSAT,'''' ClaveTipoEmbalajeSAT

		from (select * from (
select  ROW_NUMBER()over (partition by pbr.modelo order by pbr.modelo)idmov,
			pbr.modelo,pbr.Linea,pbr.marca
		from PruebasUsados pbr left join catamodelos modeli on modeli.Nombre = pbr.Modelo
left join catalineas lin on lin.Nombre = pbr.linea
where modeli.Nombre is null ) q2 where idmov <2) pbr left join catamodelos modeli on modeli.Nombre = pbr.Modelo
left join catalineas lin on lin.Nombre = pbr.linea
where modeli.Nombre is null
 '  
exec(@sqlqry)

	set @sqlqry2 = '
		insert into CataModelosSucursal
		select Row_number()over (order by idmodelo)+'+isnull(@Max2,0)+' IdModeloSucursal,	 IdModelo,	'+convert(varchar,@Sucursal)+' IdSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo,	0 UltimoCosto,	0 CostoFlete,	
		0 PrecioRentaDiario,	0 PrecioRentaSemanal,	0 PrecioRentaMensual,	
		''Pesos'' Moneda,0 TiempoEntrega,0 DescuentoSobrePrecioLista,	1 CondicionesCompra,	0 PrecioRentaHora,	0 PrecioRentaQuincenal,	0 CargoMinimo
		 from  Catamodelos where idmodelo >'+convert(varchar,(select max(IdModelo) from CataModelos))+' '
		-- INSERCION A CATACLIENTES DE LAS LINEAS INSERTADAS.

		exec(@sqlqry2)

		/* FIN */

		/*ahora con EQUIPOS*/


		set @sqlqry = ' 
select Row_Number()over (order by pbr.NumeroSerieEquipo)+'+convert(varchar,@Max)+' IdEquipoUsado,'+convert(varchar,@Sucursal)+' IdSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo, pbr.NumeroSerieEquipo,	lin.IdLinea,model.IdModelo,	
'''' NumeroSerieMotor,	''Disponible'' Estado,	0 Horometro, convert(date,getdate()) FechaAlta,	'''' CompraFacturaNumero,	0 CompraFacturaFecha,	
0 TipoCambio,	0 CostoNacional,	0 CostoEUA,	'''' Aduana,	'''' PedimentoImportacion,	'''' FechaPedimento,pbr.NumeroInterno,	'''' FechaAltaRenta,	0 DepreciacionContableAnterior,	0 IngresosAnteriores,	0 GastosAnteriores,	
'''' FechaRPVTD,	'''' ObservacionesRPVTD,	ron.IdEquipoRenta,	'''' CuentaContable,	'''' Comentarios,	'''' Ubicacion,	'''' NumeroSerieAdicional,	'''' NumeroSerieAdicional2,	'''' Localizacion,	0 IdModeloVersion,	'''' AñoModelo,	
0 IdEmpleado,	'''' NumeroIdentificacionVehicular,	0 Horometro2,	0 IdModelo2,	'''' NumeroEconomico,	'''' Placas,	'''' TarjetaCirculacion,	'''' CompañiaSeguro,	'''' NoPoliza,	'''' FechaInicioPoliza,	'''' FechaFinPoliza,
	0 UltimoHorometro,	'''' ClaveConfiguracionTransporteSAT
from PruebasUsados pbr
left join CataLineas lin on lin.Nombre = pbr.Linea
left join catamodelos model on model.Nombre = pbr.modelo
left join CataEquiposUsados ren on ren.NumeroSerieEquipo = pbr.NumeroSerieEquipo
left join CataEquiposRenta ron on ron.NumeroInterno = pbr.numeroInterno
where ren.NumeroSerieEquipo is null 
'
execute (@sqlqry)

/* ES NECESARIO TENER UN IDEQUIPORENTA; SI NO EXISTE LOS AGREGAMOS */
set @sqlqry = ' 
	insert into cataEquiposRenta select 
 Row_number() over (order by pbr.NumeroInterno)+'+convert(varchar,@Max)+' IdEquipoRenta,'+convert(varchar,@sucursal)+' IdSucursal,'+convert(varchar,@centro)+' IdCentroOperativo,lin.IdLinea,model.IdModelo,
 pbr.NumeroInterno,pbr.NumeroSerieEquipo,'''' NumeroSerieMotor,''''  NumeroPlaca,''Empresa''  Propietario,
''Disponible''  Estado,0 Horometro,0 CostoNacional,0 CostoEUA,0 TipoCambio,''''  NumeroFactura,''''  Aduana,''''  PedimentoImportacion,''''  FechaPedimento,''''  FechaFactura,
''''  FechaAltaEmpresa,''''  FechaAltaSucursal,''''  FechaUltimaAlta,''''  FechaPRUVTB,''''  ObservacionesPRUVTB,''''  EstadoAnteriorPR,0 DepreciacionContableAnterior,
0 IngresosAnteriores,0 GastosAnteriores,''N''  Asegurado,0 IdEquipoUsado,0 IdEquipoNuevo,''''  CuentaContable,''''  Comentarios,''''  Ubicacion,
''''  NumeroSerieAdicional,''''  NumeroSerieAdicional2,''''  Localizacion,0 IdModeloVersion,''''  AnoModelo,0 IdProveedor,0 IdPolizaEQR,''''  FechaEstado,
''''  NumeroIdentificacionVehicular,''''  SerieAlternador,''''  MarcaMotor,0 Horometro2,0 IdModelo2,0 IdEmpleado,0 IdArrendamientoEQR,0 BloqueadoPorGPS,
0 PrecioRentaDiario,0 PrecioRentaSemanal,0 PrecioRentaQuincenal,0 PrecioRentaMensual,0 PrecioRentaHora,
''''  MonedaRenta,0 IdConPed,0 RetornoTemporal,0 IdOrdenTrabajo,0 IdEmpleadoVendedor,''''  FechaVendedor,''''  DetallesVendedorAsignado,0 IdCotizacion
from PruebasUsados pbr
left join CataLineas lin on lin.Nombre = pbr.Linea
left join catamodelos model on model.Nombre = pbr.modelo
left join CataEquiposUsados ren on ren.NumeroSerieEquipo = pbr.NumeroSerieEquipo
left join CataEquiposRenta ron on ron.NumeroInterno = pbr.numeroInterno
where ren.NumeroSerieEquipo is null and ron.numerointerno is null  
'

execute (@sqlqry)

/**/

set @sqlqry2 = ' 
	insert into CataEquiposUsados 
	select Row_Number()over (order by pbr.NumeroSerieEquipo)+'+convert(varchar,@Max)+' IdEquipoUsado,'+convert(varchar,@Sucursal)+' IdSucursal,	'+convert(varchar,@centro)+' IdCentroOperativo, pbr.NumeroSerieEquipo,	lin.IdLinea,
	model.IdModelo,	'''' NumeroSerieMotor,	''Disponible'' Estado,	0 Horometro, convert(date,getdate()) FechaAlta,	'''' CompraFacturaNumero,	0 CompraFacturaFecha,	
0 TipoCambio,	0 CostoNacional,	0 CostoEUA,	'''' Aduana,	'''' PedimentoImportacion,	'''' FechaPedimento,pbr.NumeroInterno,	'''' FechaAltaRenta,	0 DepreciacionContableAnterior,	0 IngresosAnteriores,	0 GastosAnteriores,	
'''' FechaRPVTD,	'''' ObservacionesRPVTD,	ron.IdEquipoRenta,	'''' CuentaContable,	'''' Comentarios,	'''' Ubicacion,	'''' NumeroSerieAdicional,	'''' NumeroSerieAdicional2,	'''' Localizacion,	0 IdModeloVersion,	'''' AñoModelo,	
0 IdEmpleado,	'''' NumeroIdentificacionVehicular,	0 Horometro2,	0 IdModelo2,	'''' NumeroEconomico,	'''' Placas,	'''' TarjetaCirculacion,	'''' CompañiaSeguro,	'''' NoPoliza,	'''' FechaInicioPoliza,	'''' FechaFinPoliza,
	0 UltimoHorometro,	'''' ClaveConfiguracionTransporteSAT
from PruebasUsados pbr
left join CataLineas lin on lin.Nombre = pbr.Linea
left join catamodelos model on model.Nombre = pbr.modelo
left join CataEquiposUsados ren on ren.NumeroSerieEquipo = pbr.NumeroSerieEquipo
left join CataEquiposRenta ron on ron.NumeroInterno = pbr.numeroInterno
where ren.NumeroSerieEquipo is null '

execute (@sqlqry2)

			 end  -- FIN DE EQUIPOS USADOS


			 if @tipo ='Clientes' 
			 begin 

			 	set @sqlqry  = 
					'select 
					Row_Number()over (order by RazonSocial)idCliente,
					Row_Number()over (partition by RazonSocial  order by RazonSocial)idmov3,
					Row_Number()over (partition by RFC  order by RazonSocial)idmov2,
					Row_Number() over (partition by Razonsocial,RFC order by RazonSocial)idmov,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(RazonSocial,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))RazonSocial,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(RFC,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))RFC,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Correo,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Correo,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(Telefono,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))Telefonos,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(CalleNombre,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))CalleNombre,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(NumeroInterior,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))NumeroInterior,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(NumeroExterior,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))NumeroExterior,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(CFDI,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))CFDI,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(DiasCredito,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))DiasCredito,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(LimiteCredito,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))LimiteCredito,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(RegimenFiscal,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))RegimenFiscalSAT,
					rtrim(ltrim(isnull(replace(replace(replace(replace(replace(Replace(REPLACE(CP,''É'',''E''),''Á'',''A''),''Í'',''I''),''Ó'',''O''),''Ú'',''U''),''Ü'',''U''),''Ù'',''U''),'''')))CP 
					 into PruebasClientes from OPENROWSET 
					 (''Microsoft.ACE.OLEDB.12.0'','+'''Excel 12.0 Xml;HRD=YES;'''+@datasrc+','+
					 '''SELECT * FROM ' +@sheet+''')'

					

					 exec(@sqlqry) -- crea e inserta la tabla temporal  del excel a la base de datos 

					  set @sqlqry = 'delete from PruebasClientes where RazonSocial = '''' or RazonSocial is null or idmov >1;
					   delete from PruebasClientes where RFC not in (''XAXX010101000'',''XEXX010101000'','''')  and idmov2 >1;
					   delete from PruebasClientes where idmov3 >1'
					   exec(@sqlqry) -- Limpia la tabla si no hay valores registrados como en este caso la razon social si no hay pues pelamos gallo

					 
					  set  @colation = 'select  COLLATION_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = ''Cataclientes'' and COLUMN_NAME = ''RazonSocial'' '
					    -- obtener el colation de la columna la cual hara el inner join para que lo inserte 
						execute(@colation)

					set @sqlqry='alter table PruebasClientes alter column RazonSocial nvarchar(1000) '+@colation+';'
					exec(@sqlqry)-- ACTUALIZA EL TIPO DE TEXTO para hacer uniones

							select @Max=isnull(max(IDCLASIFICACIONCLIENTE),0) from CataClasificacionClientes
						select @Max2= isnull(max(IDORIGENCONTACTO),0) from CataOrigenContacto


				
						
		/* INSERTAR CLASIFICACION Y ORIGEN DE CONTACTO PARA no tener problemas*/


		if @Max = 0 begin

		set @sqlqry = 'insert into  CataClasificacionClientes select 1 IDCLASIFICACIONCLIENTE, ''Historial'' CLASIFICACION, '''' OBSERVACIONES , ''0'' BloquearCliente'
		execute(@sqlqry)
		end
			else 
		begin 
			set @sqlqry = 'insert into  CataClasificacionClientes select '+@Max+' IDCLASIFICACIONCLIENTE, ''Historial'' CLASIFICACION, '''' OBSERVACIONES , ''0'' BloquearCliente'
		execute(@sqlqry)
		end

		if @Max2=0 begin
		set @sqlqry2 = 'insert into  CataOrigenContacto select 1 IDORIGENCONTACTO, ''Historial'' ORIGENCONTACTO, '''' DESCRIPCION , '''' CLASIFICACION'
		execute(@sqlqry2)
		end
		else
		begin
		set @sqlqry2 = 'insert into  CataOrigenContacto select '+@Max2+' IDORIGENCONTACTO, ''Historial'' ORIGENCONTACTO, '''' DESCRIPCION , '''' CLASIFICACION'
		execute(@sqlqry2)
		end
		/**/
		DECLARE @CLA int, @ORI int
		set @CLA = case when @Max = 0 then 1 end 
		set @ORI = case when @Max2 = 0 then 1 end 

				select @Max=isnull(max(IdCliente),0) from CataClientes
						select @Max2= max(IdClienteSucursal) from CataClientesSucursal



			set @sqlqry = '
		select   Row_Number()over (order by pbr.RazonSocial)+'+@Max+' IdCliente,convert(date,getdate()) FechaAlta,''A'' Tipo, pbr.RazonSocial, 
		case 
when pbr.RFC = '''' and pbr.idmov2 >1  then ''TEMP424601''+convert(varchar,ROW_NUMBER()over (partition by pbr.RFC order by pbr.RazonSocial)) 
when pbr.RFC = ''XAXX010101000'' and pbr.idmov2 >1 then ''XAXX0101010''+convert(varchar,ROW_NUMBER()over (partition by pbr.RFC order by pbr.RazonSocial))
when pbr.RFC = ''XEXX010101000'' and pbr.idmov2 >1 then ''XEXX0101010''+convert(varchar,ROW_NUMBER()over (partition by pbr.RFC order by pbr.RazonSocial))
else pbr.RFC 
end RFC ,
		''S'' FacturarIVADesglosado,'''' CURP,NULL Contacto,substring(pbr.CalleNombre,1,11)CalleNombre,
NULL EntreCalles,
isnull((select top 1 Colonia from CataColonias cpo where cpo.CodigoPostal = pbr.CP),'''')Colonia,
substring(pbr.CP,1,5) CP,
isnull( ccp.MunicipioDelegacion,'''') MunicipioDelegacion,isnull(ccp.Ciudad,'''') Ciudad,isnull(ccp.Estado,'''') Estado,
pbr.Telefonos,NULL Telefono1,NULL Telefono2,NULL Telefono3,NULL TelefonoFax,'''' Observaciones,NULL Bloqueado,NULL BloqueadoMotivo,
NULL CuentaContable,NULL PorcentajeRetencion,substring(pbr.NumeroExterior,1,14)NumeroExterior,substring(pbr.NumeroInterior,1,14)NumeroInterior,
NULL Localidad,NULL Pais,'+convert(varchar,@Sucursal)+' SucursalCliente,NULL Referencia,
NULL Titular,NULL CuentaBancariaPago,NULL FormaPago,NULL NF,NULL Observaciones2,
NULL SoloVentasContado,NULL SoloRentasContado,NULL RequerirOrdenCompra,'+convert(varchar,@CLA)+' IdClasificacionCliente,
isnull(case when len(pbr.RFC) = 12 then ''Moral'' 
		when len(pbr.RFC) >= 13 and len(pbr.RFC) <=15 then ''Fisica''
		when len(pbr.RFC) >15 then ''Extranjero'' end,''Moral'') PersonaFiscal,
NULL ApellidoPaterno,NULL ApellidoMaterno,NULL Nombres,
NULL Juridico,NULL FechaJuridico,
NULL IdEmpleado,pbr.CFDI USOCFDI,'+convert(varchar,@ORI)+' IdOrigenContacto,NULL ImporteAutorizadoRenta,
case 
when pbr.RegimenFiscalSAT = '''' and len(pbr.RFC) =12 then ''603''
when pbr.RegimenFiscalSAT = '''' and len(pbr.RFC) =13 then ''612''
when pbr.RegimenFiscalSAT = '''' and len(pbr.RFC) >13 then ''616''
end RegimenFiscalSAT,NULL RegimenSociatario,NULL CuentaContable2,NULL CuentaContable3,NULL CuentaContable4,NULL MetodoPago,
NULL WhatsAppContacto
		from PruebasClientes pbr 
		left join cataclientes cli on cli.RazonSocial = pbr.Razonsocial 
		left join CataCodigosPostales ccp on ccp.CodigoPostal = pbr.CP
		where cli.Razonsocial is null' 

		exec(@sqlqry) --imprime que se va a insertar 

		print @sqlqry
		
				set @sqlqry = '
		insert into Cataclientes
		select   Row_Number()over (order by pbr.RazonSocial)+'+@Max+' IdCliente,convert(date,getdate())  FechaAlta,''A'' Tipo, pbr.RazonSocial,
		case 
when pbr.RFC = '''' and pbr.idmov2 >1  then ''TEMP424601''+convert(varchar,ROW_NUMBER()over (partition by pbr.RFC order by pbr.RazonSocial)) 
when pbr.RFC = ''XAXX010101000'' and pbr.idmov2 >1 then ''XAXX0101010''+convert(varchar,ROW_NUMBER()over (partition by pbr.RFC order by pbr.RazonSocial))
when pbr.RFC = ''XEXX010101000'' and pbr.idmov2 >1 then ''XEXX0101010''+convert(varchar,ROW_NUMBER()over (partition by pbr.RFC order by pbr.RazonSocial))
else pbr.RFC 
end RFC ,
		''S'' FacturarIVADesglosado,'''' CURP,NULL Contacto,substring(pbr.CalleNombre,1,11)CalleNombre,
NULL EntreCalles,
isnull((select top 1 Colonia from CataColonias cpo where cpo.CodigoPostal = pbr.CP),'''')Colonia,
substring(pbr.CP,1,5) CP,
isnull( ccp.MunicipioDelegacion,'''') MunicipioDelegacion,isnull(ccp.Ciudad,'''') Ciudad,isnull(ccp.Estado,'''') Estado,
pbr.Telefonos,NULL Telefono1,NULL Telefono2,NULL Telefono3,NULL TelefonoFax,NULL Observaciones,NULL Bloqueado,NULL BloqueadoMotivo,
NULL CuentaContable,NULL PorcentajeRetencion,substring(pbr.NumeroExterior,1,14)NumeroExterior,substring(pbr.NumeroInterior,1,14)NumeroInterior,
NULL Localidad,NULL Pais,'+convert(varchar,@Sucursal)+'SucursalCliente,NULL Referencia,NULL Titular,NULL CuentaBancariaPago,
NULL FormaPago,NULL NF,NULL Observaciones2,
NULL SoloVentasContado,NULL SoloRentasContado,NULL RequerirOrdenCompra,'+convert(varchar,@CLA)+' IdClasificacionCliente,
isnull(case when len(pbr.RFC) = 12 then ''Moral'' 
		when len(pbr.RFC) >= 13 and len(pbr.RFC) <=15 then ''Fisica''
		when len(pbr.RFC) >15 then ''Extranjero'' end,''Moral'') PersonaFiscal,
NULL ApellidoPaterno,NULL ApellidoMaterno,NULL Nombres,
NULL Juridico,NULL FechaJuridico,
NULL IdEmpleado,NULL USOCFDI,'+convert(varchar,@ORI)+' IdOrigenContacto,NULL ImporteAutorizadoRenta,
case 
when pbr.RegimenFiscalSAT = '''' and len(pbr.RFC) =12 then ''603''
when pbr.RegimenFiscalSAT = '''' and len(pbr.RFC) =13 then ''612''
when pbr.RegimenFiscalSAT = '''' and len(pbr.RFC) >13 then ''616''
end RegimenFiscalSAT,NULL RegimenSociatario,NULL CuentaContable2,NULL CuentaContable3,NULL CuentaContable4,NULL MetodoPago,
NULL WhatsAppContacto
		from PruebasClientes 
		pbr 
		left join cataclientes cli on cli.RazonSocial = pbr.Razonsocial 
		left join CataCodigosPostales ccp on ccp.CodigoPostal = pbr.CP
		where cli.Razonsocial is null' 
		-- INSSERCION A cataclientes DE LO QUE SOLAMENTE NO SE ENCUENTRA
		
		exec(@sqlqry)
		

set @sqlqry2 ='
insert into CataClientesSucursal
select Row_number() over (order by idcliente)+'+isnull(@Max2,0)+'  IdClienteSucursal,	'+convert(varchar,@Sucursal)+'  IdSucursal,	 IdCliente,	convert(date,getdate())   FechaAltaSucursal,	''A''  Tipo,	1  IdEmpleado,	0  LimiteCredito,	0  DiasCredito,	''''  Contacto1,
''''  TelContacto1,''''  EmailContacto1,	''''  Contacto2,	''''  TelContacto2,	''''  EmailContacto2,	''''  Contacto3,
	''''  TelContacto3,''''  EmailContacto3,''''  Contacto4,	''''  TelContacto4,	''''  EmailContacto4,	NULL  Descuento,	''''  Observaciones,	''''  DRFLu,
''''  DRFMa,	''S''  DRFMi,	''''  DRFJu,	''''  DRFVi,	''N''  DRFSa,	0  DRFDe,	0  DRFA,0  DRFDe2,0  DRFA2,	''''  DPLu,	''''  DPMa,	''N''  DPMi,''''  DPJu,	''''  DPVi,
	''N''  DPSa,	0  DPDe,	0  DPDe2,	0  DPA,	0  DPA2,	''''  DObservaciones,	
''''  CalleNumero,''''  EntreCalles,''''  Colonia,''''  CP,''''   MunicipioDelegacion,''''  Ciudad,
''''  Estado,	''''  CorreoElectronico,''''  Telefono1,''''  Telefono2,	''''  Telefono3,	''''  TelefonoFax,	
''''  Faxes,	''N''  Bloqueado,	''''  BloqueadoMotivo,	''N''  CLCopiaActaConstitutiva,	''N''  CLCopiaPoderRepresentanteLegal,''N''  CLCopiaIdentificacion,	
	''N''  CLCopiaComprobanteDomicilio,	''N''  CLCopiaRFC,	''''  CL2ReferenciasComerciales,	''''  CL2ReferenciasPersonales,	''''  CL2ReferenciasBancarias,	''''  CLCartaFianza,	''N''  CLPagareFirmado,
		''''  CLSeAutoriza,
	''''  CLObservaciones,	''''  CLElaboro,	''''  CLAutorizo,	''0''  PagareNumero,
		''''  PagareFecha,''''  PagareFechaVencimiento,
	''Pesos''  PagareMoneda,	0  PagareImporte,	4  PagareInteresMoratorioMensual,	''''    PagareSuscriptorRazonSocialNombre,''''  PagareSuscriptorRazonSocialNombreComentario,
	''''   PagareSuscriptorCalleNumero,	''''      PagareSuscriptorColonia,''''    PagareSuscriptorCiudadMunicipio,''''  PagareSuscriptorEstado,
		''''   PagareSuscriptorTelefonos,	
	''''  PagareSuscriptorRepresentanteLegal,	''''  PagareAvalNombre,	''''  PagareAvalCalleNumero,	
	''''  PagareAvalColonia,	''''  PagareAvalCiudadMunicipio,	''''  PagareAvalEstado,	''''  PagareAvalTelefonos,	0  DescuentoPrecioDiario,	0  DescuentoPrecioSemanal,	
	0  DescuentoPrecioQuincenal,	0  DescuentoPrecioMensual,	0  DescuentoPrecioHora,	''''  FormatoInterno,	''''  AltaAnteSAT,	''''  DomicilioContacto1,	''''  DomicilioContacto2,	
	''''  DomicilioContacto3,	''''  DomicilioContacto4,	''''  ReferenciaComercialEmpresa1,	''''  ReferenciaComercialEmpresa2,	''''  ReferenciaPersonal1,	''''  ReferenciaPersonal2,	
	''''  ReferenciaComercialPersona1,	''''  ReferenciaComercialPersona2,	''''  ReferenciaComercialDomicilio1,	''''  ReferenciaComercialDomicilio2,	''''  ReferenciaPersonalDomicilio1,	
	''''  ReferenciaPersonalDomicilio2,	''''  ReferenciaComercialEntreCalles1,	''''  ReferenciaComercialEntreCalles2,	''''  ReferenciaPersonalEntreCalles1,	''''  ReferenciaPersonalEntreCalles2,	
	''''  ReferenciaComercialColonia1,	''''  ReferenciaComercialColonia2,	''''  ReferenciaPersonalColonia1,	''''  ReferenciaPersonalColonia2,	''''  ReferenciaComercialCiudad1,	
	''''  ReferenciaComercialCiudad2,	''''  ReferenciaPersonalCiudad1,	''''  ReferenciaPersonalCiudad2,	''''  ReferenciaComercialEstado1,	''''  ReferenciaComercialEstado2,	
	''''  ReferenciaPersonalEstado1,	''''  ReferenciaPersonalEstado2,	''''  ReferenciaComercialTelefonos1,	''''  ReferenciaComercialTelefonos2,	''''  ReferenciaPersonalTelefonos1,	
	''''  ReferenciaPersonalTelefonos2,	''''  ReferenciaComercialCP1,	''''  ReferenciaComercialCP2,	''''  ReferenciaPersonalCP1,	''''  ReferenciaPersonalCP2,	''''  CalleNumeroCasa,	
	''''  EntreCallesCasa,	''''  ColoniaCasa,	''''  CPCasa,	''''  MunicipioDelegacionCasa,	''''  CiudadCasa,	''''  EstadoCasa,	''''  TelefonosCasa,	''''  CalleNumeroOficina,	
	''''  EntreCallesOficina,	''''  ColoniaOficina,	''''  CPOficina,	''''  MunicipioDelegacionOficina,	''''  CiudadOficina,	''''  EstadoOficina,	''''  TelefonosOficina,	
	''''  ObservacionesDireccionesCasaOficina,	0  PagaOficina,	0  PagaTransferencia,	0  PagaBancoReferencia,	0  RequiereEnvioFacturaFisica,	''''  ReferenciaBancaria,	0  ImpuestosProvisionales,	
	0  DeclaracionAnual,	''''  RFCContacto1,	''''  RFCContacto2,	''''  RFCContacto3,	''''  RFCContacto4,	''''  RepresentanteContrato,	''''  EscrituraNumero,	''''  EscrituraFecha,	
	''''  EscrituraNotario,	''''  EscrituraNotarioNumero,	'''' EscrituraNotarioLugar,	''''  EscrituraRegistroPublico,	''''  EscrituraRegistroPublicoFecha,	
	''''  EscrituraRepresentanteLegal,	''''  FolioElectronicoRegistro,	''''   EscrituraNumeroPoder,	''''  EscrituraFechaPoder,
		''''  EscrituraNotarioPoder,	''''  EscrituraNotarioNumeroPoder,	'''' EscrituraNotarioLugarPoder,	
		''''  EscrituraRegistroPublicoPoder,	''''  EscrituraRegistroPublicoFechaPoder,	0  WhatsAppContacto1,	0  WhatsAppContacto2,	0  WhatsAppContacto3,	
		0  WhatsAppContacto4
		from cataclientes where idcliente >'+@Max+' '

		exec(@sqlqry2)


		set @sqlqry2 ='
select Row_number() over (order by idcliente)+'+isnull(@Max2,0)+'  IdClienteSucursal,	'+convert(varchar,@Sucursal)+'  IdSucursal,	 IdCliente,	convert(date,getdate())   FechaAltaSucursal,	''A''  Tipo,	
1  IdEmpleado,	0  LimiteCredito,	0  DiasCredito,	''''  Contacto1,
''''  TelContacto1,''''  EmailContacto1,	''''  Contacto2,	''''  TelContacto2,	''''  EmailContacto2,	''''  Contacto3,
	''''  TelContacto3,''''  EmailContacto3,''''  Contacto4,	''''  TelContacto4,	''''  EmailContacto4,	NULL  Descuento,	''''  Observaciones,	''''  DRFLu,
''''  DRFMa,	''S''  DRFMi,	''''  DRFJu,	''''  DRFVi,	''N''  DRFSa,	0  DRFDe,	0  DRFA,0  DRFDe2,0  DRFA2,	''''  DPLu,	''''  DPMa,	''N''  DPMi,''''  DPJu,	''''  DPVi,
	''N''  DPSa,	0  DPDe,	0  DPDe2,	0  DPA,	0  DPA2,	''''  DObservaciones,	
''''  CalleNumero,''''  EntreCalles,''''  Colonia,''''  CP,''''   MunicipioDelegacion,''''  Ciudad,
''''  Estado,	''''  CorreoElectronico,''''  Telefono1,''''  Telefono2,	''''  Telefono3,	''''  TelefonoFax,	
''''  Faxes,	''N''  Bloqueado,	''''  BloqueadoMotivo,	''N''  CLCopiaActaConstitutiva,	''N''  CLCopiaPoderRepresentanteLegal,''N''  CLCopiaIdentificacion,	
	''N''  CLCopiaComprobanteDomicilio,	''N''  CLCopiaRFC,	''''  CL2ReferenciasComerciales,	''''  CL2ReferenciasPersonales,	''''  CL2ReferenciasBancarias,	''''  CLCartaFianza,	''N''  CLPagareFirmado,
		''''  CLSeAutoriza,
	''''  CLObservaciones,	''''  CLElaboro,	''''  CLAutorizo,	''0''  PagareNumero,
		''''  PagareFecha,''''  PagareFechaVencimiento,
	''Pesos''  PagareMoneda,	0  PagareImporte,	4  PagareInteresMoratorioMensual,	''''    PagareSuscriptorRazonSocialNombre,''''  PagareSuscriptorRazonSocialNombreComentario,
	''''   PagareSuscriptorCalleNumero,	''''      PagareSuscriptorColonia,''''    PagareSuscriptorCiudadMunicipio,''''  PagareSuscriptorEstado,
		''''   PagareSuscriptorTelefonos,	
	''''  PagareSuscriptorRepresentanteLegal,	''''  PagareAvalNombre,	''''  PagareAvalCalleNumero,	
	''''  PagareAvalColonia,	''''  PagareAvalCiudadMunicipio,	''''  PagareAvalEstado,	''''  PagareAvalTelefonos,	0  DescuentoPrecioDiario,	0  DescuentoPrecioSemanal,	
	0  DescuentoPrecioQuincenal,	0  DescuentoPrecioMensual,	0  DescuentoPrecioHora,	''''  FormatoInterno,	''''  AltaAnteSAT,	''''  DomicilioContacto1,	''''  DomicilioContacto2,	
	''''  DomicilioContacto3,	''''  DomicilioContacto4,	''''  ReferenciaComercialEmpresa1,	''''  ReferenciaComercialEmpresa2,	''''  ReferenciaPersonal1,	''''  ReferenciaPersonal2,	
	''''  ReferenciaComercialPersona1,	''''  ReferenciaComercialPersona2,	''''  ReferenciaComercialDomicilio1,	''''  ReferenciaComercialDomicilio2,	''''  ReferenciaPersonalDomicilio1,	
	''''  ReferenciaPersonalDomicilio2,	''''  ReferenciaComercialEntreCalles1,	''''  ReferenciaComercialEntreCalles2,	''''  ReferenciaPersonalEntreCalles1,	''''  ReferenciaPersonalEntreCalles2,	
	''''  ReferenciaComercialColonia1,	''''  ReferenciaComercialColonia2,	''''  ReferenciaPersonalColonia1,	''''  ReferenciaPersonalColonia2,	''''  ReferenciaComercialCiudad1,	
	''''  ReferenciaComercialCiudad2,	''''  ReferenciaPersonalCiudad1,	''''  ReferenciaPersonalCiudad2,	''''  ReferenciaComercialEstado1,	''''  ReferenciaComercialEstado2,	
	''''  ReferenciaPersonalEstado1,	''''  ReferenciaPersonalEstado2,	''''  ReferenciaComercialTelefonos1,	''''  ReferenciaComercialTelefonos2,	''''  ReferenciaPersonalTelefonos1,	
	''''  ReferenciaPersonalTelefonos2,	''''  ReferenciaComercialCP1,	''''  ReferenciaComercialCP2,	''''  ReferenciaPersonalCP1,	''''  ReferenciaPersonalCP2,	''''  CalleNumeroCasa,	
	''''  EntreCallesCasa,	''''  ColoniaCasa,	''''  CPCasa,	''''  MunicipioDelegacionCasa,	''''  CiudadCasa,	''''  EstadoCasa,	''''  TelefonosCasa,	''''  CalleNumeroOficina,	
	''''  EntreCallesOficina,	''''  ColoniaOficina,	''''  CPOficina,	''''  MunicipioDelegacionOficina,	''''  CiudadOficina,	''''  EstadoOficina,	''''  TelefonosOficina,	
	''''  ObservacionesDireccionesCasaOficina,	0  PagaOficina,	0  PagaTransferencia,	0  PagaBancoReferencia,	0  RequiereEnvioFacturaFisica,	''''  ReferenciaBancaria,	0  ImpuestosProvisionales,	
	0  DeclaracionAnual,	''''  RFCContacto1,	''''  RFCContacto2,	''''  RFCContacto3,	''''  RFCContacto4,	''''  RepresentanteContrato,	''''  EscrituraNumero,	''''  EscrituraFecha,	
	''''  EscrituraNotario,	''''  EscrituraNotarioNumero,	'''' EscrituraNotarioLugar,	''''  EscrituraRegistroPublico,	''''  EscrituraRegistroPublicoFecha,	
	''''  EscrituraRepresentanteLegal,	''''  FolioElectronicoRegistro,	''''   EscrituraNumeroPoder,	''''  EscrituraFechaPoder,
		''''  EscrituraNotarioPoder,	''''  EscrituraNotarioNumeroPoder,	'''' EscrituraNotarioLugarPoder,	
		''''  EscrituraRegistroPublicoPoder,	''''  EscrituraRegistroPublicoFechaPoder,	0  WhatsAppContacto1,	0  WhatsAppContacto2,	0  WhatsAppContacto3,	
		0  WhatsAppContacto4
		from cataclientes where idcliente >'+@Max+'  '

		exec(@sqlqry2)

		set @sqlqry  = 'drop table PruebasClientes' -- Borramos la tabla temporal ya que , ya la utilizamos para las comparaciones
		print 'Tabla Temporal Borrada'
		exec(@sqlqry)

			 end-- FIN DE INSERTAR CLIENTES
	
			
END


