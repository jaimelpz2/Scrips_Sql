USE [ITR_Data]
GO
/****** Object:  StoredProcedure [dbo].[ITR_SP_ObtenerCamposTablas]    Script Date: 18/04/2023 11:37:03 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[ITR_SP_ObtenerCamposTablas]
	-- Add the parameters for the stored procedure here
	 @tabla varchar(45) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @cols NVARCHAR(MAX), @query NVARCHAR(MAX), @table varchar(45);

set @table = '''' + ''+@tabla+''''

print @table

set @cols = stuff(
(
select ','+Quotename(COLUMN_NAME) from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @tabla
 for xml path(''), TYPE ).value('.','nvarchar(max)'),1,0,'')

 print substring(@cols,2,len(@cols)) +char(13)

SET @query = 'SELECT  '+substring(@cols,2,len(@cols))+' from (select 
case when Data_TYPE in (''varchar'',''nvarchar'',''date'',''datetime'') then  '''''' ''''''  else convert(varchar,1)  end ORDINAL_POSITION , COLUMN_NAME 
From INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = '+@table+' 
    )x pivot (max(ORDINAL_POSITION) for COLUMN_NAME in ('+substring(@cols,2,len(@cols))+')) p'

print @query

EXECUTE (@query);




END
