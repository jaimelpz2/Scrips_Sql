USE [ITR_Data]
GO
/****** Object:  StoredProcedure [dbo].[ITR_SP_ImportarExcel]    Script Date: 16/03/2023 10:48:40 a. m. ******/
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
	@datasrc    varchar(4000), 
	@sheet		varchar(255)
	--, @idexcel	int	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		DECLARE @provider   nvarchar(128)
		DECLARE @location   nvarchar(4000)
		DECLARE @provstr    nvarchar(4000)
		declare @temporary nvarchar(255)
		DECLARE @sqlqry		varchar(max)
		declare @id			int
		declare @columnas   varchar(2048)
		declare @IdExcelKey	int
	
		--select @IdExcelKey = isnull((Select Max(IdExcelBase) From ParaExcelBase), 0) + 1

		--SET @provider =   ''''+'Microsoft.ACE.OLEDB.12.0'+''''
		--SET @provstr =    ''''+'Excel 12.0 Xml;HRD=YES;'+''''
		set @temporary = 'exceldata#'
		SET @datasrc =    ''''+'Database=' + @location +''''
		set @sheet = '['+@sheet+'$]'
		
		/*
		Proveedores
		*/

		select @id = OBJECT_ID(@temporary)
		if @id >0
			begin
				set @sqlqry  = 'drop table ' + @temporary 
				print @sqlqry  
				exec(@sqlqry)
			end	

		set @sqlqry  = 'select * into '+@temporary+' from OPENROWSET  (''Microsoft.ACE.OLEDB.12.0'','+'Excel 12.0 Xml;HRD=YES;'+@datasrc+','+'''SELECT * FROM ' +@sheet+''')'
		print @sqlqry
		exec(@sqlqry)

		set @sqlqry = 'select * from ' + @temporary
		print @sqlqry
		exec(@sqlqry)

		--Select @columnas = dbo.ArmarColumnasExcel((SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'exceldata#'))

		--set @sqlqry  = 'insert into ParaExcelBase(IdTran, ' + @columnas +') select ' + convert(varchar, @idexcel) + ', * from ' + @temporary
		--print @sqlqry
		--exec(@sqlqry)

		set @sqlqry  = 'drop table ' + @temporary 
		print @sqlqry  
		exec(@sqlqry)
			
END
