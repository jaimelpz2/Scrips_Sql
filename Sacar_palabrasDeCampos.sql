
select  IdCliente,RazonSocial,LTRIM(RTRIM(FirstWord))ApellidoPaterno,
LTRIM(RTRIM(SecondWord))ApellidoMaterno,LTRIM(RTRIM(thirddWord))Nombres
 from (
SELECT   IdCliente,RazonSocial,rfc,ApellidoMaterno,Nombres,PersonaFiscal,


    CASE 
        WHEN CHARINDEX(' ', ApellidoPaterno) = 0 
        THEN ApellidoPaterno 
        ELSE LEFT(ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) - 1) 
    END AS FirstWord,
    
    
    CASE 
        WHEN LEN(ApellidoPaterno) - LEN(REPLACE(ApellidoPaterno, ' ', '')) = 0
        THEN '' 
        WHEN CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1) = 0 -- cuando el charindex, detecta que el espacio esta en la posicion 0
        
        THEN  -- dice
            SUBSTRING(ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1, LEN(ApellidoPaterno)) -- extrae del campo,donde este el espacio mas 1 ala derecha hasta el tamaño del campo.
            
        ELSE SUBSTRING(ApellidoPaterno, --extrae de aqui
/*empieza */  CHARINDEX(' ', ApellidoPaterno) + 1,
CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1) -  -- pero extrae el campo, iniciando de donde encuntre el espacio ala derecha, osea en el segundo espacio
         
         CHARINDEX(' ', ApellidoPaterno) - 1) -- tamaño osea cuantas letras  
    END AS SecondWord,
    
    case when LEN(ApellidoPaterno) - LEN(REPLACE(ApellidoPaterno, ' ', '')) = 0
        THEN ''  
        when CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) +1+CHARINDEX(' ',ApellidoPaterno,+1)) = 0
       then SUBSTRING(ltrim(ApellidoPaterno), 
         CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1),
        LEN(ApellidoPaterno))
       else 
         SUBSTRING(ltrim(ApellidoPaterno), 
         CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1),
        LEN(ApellidoPaterno))
      
    end thirddWord,
    
    CHARINDEX(' ', ApellidoPaterno)Determinante1,--Determinan espacios
    CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1)Determinante2,
    CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) +1+CHARINDEX(' ',ApellidoPaterno,+1))Determinante3,
    ----*********
    LEN(ApellidoPaterno) tamaño,
    LEN(REPLACE(ApellidoPaterno, ' ', ''))tamañonSinEspacios,
    LEN(ApellidoPaterno) - LEN(REPLACE(ApellidoPaterno, ' ', ''))Palabras
FROM CataClientes
where RazonSocial = ApellidoPaterno and PersonaFiscal = 'Fisica' 
and     LEN(ApellidoPaterno) - LEN(REPLACE(ApellidoPaterno, ' ', '')) <5
) q1
order by IdCliente




----***************************************************************************************************** UPDATE

--update CA set ca.ApellidoPaterno=q1.ApellidoPaterno,ca.ApellidoMaterno=q1.ApellidoMaterno,ca.Nombres = q1.Nombres
--,ca.RazonSocial=''
-- from CataClientes ca inner join (

--select IdCliente,LTRIM(RTRIM(FirstWord))ApellidoPaterno,LTRIM(RTRIM(SecondWord))ApellidoMaterno,LTRIM(RTRIM(thirddWord))Nombres from (
--SELECT IdCliente,RazonSocial,rfc,ApellidoMaterno,Nombres,PersonaFiscal,


--    CASE 
--        WHEN CHARINDEX(' ', ApellidoPaterno) = 0 
--        THEN ApellidoPaterno 
--        ELSE LEFT(ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) - 1) 
--    END AS FirstWord,
    
    
--    CASE 
--        WHEN LEN(ApellidoPaterno) - LEN(REPLACE(ApellidoPaterno, ' ', '')) = 0
--        THEN '' 
--        WHEN CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1) = 0 -- cuando el charindex, detecta que el espacio esta en la posicion 0
        
--        THEN  -- dice
--            SUBSTRING(ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1, LEN(ApellidoPaterno)) -- extrae del campo,donde este el espacio mas 1 ala derecha hasta el tamaño del campo.
            
--        ELSE SUBSTRING(ApellidoPaterno, --extrae de aqui
--/*empieza */  CHARINDEX(' ', ApellidoPaterno) + 1,
--CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1) -  -- pero extrae el campo, iniciando de donde encuntre el espacio ala derecha, osea en el segundo espacio
         
--         CHARINDEX(' ', ApellidoPaterno) - 1) -- tamaño osea cuantas letras  
--    END AS SecondWord,
    
--    case when LEN(ApellidoPaterno) - LEN(REPLACE(ApellidoPaterno, ' ', '')) = 0
--        THEN ''  
--        when CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) +1+CHARINDEX(' ',ApellidoPaterno,+1)) = 0
--       then SUBSTRING(ltrim(ApellidoPaterno), 
--         CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1),
--        LEN(ApellidoPaterno))
--       else 
--         SUBSTRING(ltrim(ApellidoPaterno), 
--         CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1),
--        LEN(ApellidoPaterno))
      
--    end thirddWord,
    
--    CHARINDEX(' ', ApellidoPaterno)Determinante1,--Determinan espacios
--    CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) + 1)Determinante2,
--    CHARINDEX(' ', ApellidoPaterno, CHARINDEX(' ', ApellidoPaterno) +1+CHARINDEX(' ',ApellidoPaterno,+1))Determinante3,
--    ----*********
--    LEN(ApellidoPaterno) tamaño,
--    LEN(REPLACE(ApellidoPaterno, ' ', ''))tamañonSinEspacios,
--    LEN(ApellidoPaterno) - LEN(REPLACE(ApellidoPaterno, ' ', ''))Palabras
--FROM CataClientes
--where RazonSocial = ApellidoPaterno and PersonaFiscal = 'Fisica' 
--and     LEN(ApellidoPaterno) - LEN(REPLACE(ApellidoPaterno, ' ', '')) <5  


--) q1


--)q1 on q1.IdCliente=ca.IdCliente

-- where q1.IdCliente = ca.IdCliente and ca.PersonaFiscal = 'Fisica' 
