
declare @table varchar(20)

select @table = 'GoilGas' ----pon el nombre de la carpeta raiz de los reportes web , oaxaca,ver,rentom, rentco etc.
select  
ROW_NUMBER() over (order by Reporte )+ isnull((select max(IDWEBREPORTE) from ParaWebReportes),0) ,
q1.Reporte,q1.Name,'http://35.239.137.12:9191/ReportsSQL/Pages/Report.aspx?ItemPath=%2f'+@table+'%2f'+q1.Reporte+'%2f'+name URLREPORTE,null ParametroIdUsuario
 from ( 
select 

SUBSTRING(SUBSTRING(Path,CHARINDEX(@table,path),len(path)),
CHARINDEX('/',SUBSTRING(Path,CHARINDEX(@table,path),len(path)))+1
,charindex('/',SUBSTRING(Path,CHARINDEX(@table,path),len(path)),CHARINDEX('/',SUBSTRING(Path,CHARINDEX(@table,path),len(path)))+1)-1- 
CHARINDEX('/',SUBSTRING(Path,CHARINDEX(@table,path),len(path)))

  )Reporte, * from ReportServer.dbo.Catalog where Path like '%'+@table+'%' and type  not in (1,5)

)q1