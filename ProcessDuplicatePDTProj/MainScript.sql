/*
USE master 
GO
CREATE DATABASE SNAP_AIMS_UAT_DupTest
ON
( NAME = AIMS_Prod,
FILENAME= 'C:\temp\SNAP_AIMS_UAT_DupTest.snap')
AS SNAPSHOT OF AIMS_UAT
GO

SET NOCOUNT ON	
GO

USE AIMS_UAT
GO


IF (OBJECT_ID('dbo.Productlist') IS NOT NULL)
	DROP TABLE dbo.Productlist
GO
SELECT ProductId, Name, MasterProductiD
--INTO dbo.Productlist
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 8.0;HDR=Yes;Database=C:\temp\MasterProductsList.xlsx',
    'select * from [sheet1$]')
GO


IF (OBJECT_ID('dbo.DeterminantList') IS NOT NULL)
	DROP TABLE dbo.DeterminantList
GO
SELECT DeterminationId, Name, MasterDeterminatId MasterDeterminationId
INTO dbo.DeterminantList
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 8.0;HDR=Yes;Database=C:\temp\MasterDeterminantList.xlsx',
    'select * from [sheet1$]')
GO

IF (OBJECT_ID('dbo.Techniquelist') IS NOT NULL)
	DROP TABLE dbo.Techniquelist
SELECT TechniqueId, Name, MasterTechniqueId
--INTO dbo.Techniquelist
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 8.0;HDR=YES;Database=C:\temp\MasterTechniqueList.xlsx',
    'select * from [sheet1$]')
GO

*/
/*
Clear up the imported tables
*/


USE AIMS_UAT
GO

delete 
-- select *
from dbo.ProductList 
where LEN(MasterProductid) !=36
GO


delete 
--select *
from dbo.ProductList 
where MasterProductid IS NULL 
	OR MasterProductid ='' 
	or productid = MasterProductid 
	or MasterProductid NOT IN (select productid from nata.Product)

delete 
--select *
from dbo.DeterminantList where  LEN([MasterDeterminationID])!= 36 
GO

delete 
--select *
from dbo.DeterminantList 
where  [MasterDeterminationID] IS NULL 
	OR [MasterDeterminationID] ='' 
	or DeterminationId = [MasterDeterminationID]
	or [MasterDeterminationID] NOT IN (select DeterminationId from nata.Determination)
GO

delete 
--select *
from dbo.Techniquelist where LEN([Mastertechniqueid]) != 36
GO

delete 
--select *
from dbo.Techniquelist 
where  [Mastertechniqueid] IS NULL 
	OR [Mastertechniqueid] ='' 
	or [techniqueid] = [Mastertechniqueid]
	OR [Mastertechniqueid] NOT IN (select TechniqueId from nata.Technique)
GO

/*
Remove Circular Reference
*/

delete from dbo.Productlist
where productid in (
	select p1.productid from dbo.ProductList p1
	inner join dbo.ProductList p2
		on p1.MasterProductid = p2.productid
)

delete from dbo.DeterminantList
where DeterminationID in(
	select d1.DeterminationID 
	from dbo.DeterminantList d1
	inner join dbo.DeterminantList d2
		on d1.[MasterDeterminationID] = d2.DeterminationID
)

delete from dbo.Techniquelist
where [techniqueid] IN (
	select t1.[techniqueid] from dbo.Techniquelist t1
	inner join dbo.Techniquelist t2
		on t1.[Mastertechniqueid] = t2.[techniqueid]
)

/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************   Preparation *********************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/

/******************************************************** @ProductReplaceList ******************************************/
DECLARE @ProductReplaceList Table (OldProductId uniqueidentifier NOT NULL, NewProductId uniqueidentifier NOT NULL)
;WITH dupProduct AS (
	select name ProductName, min(ProductId) MinProductId
	from nata.Product 
	group by name
	having count(*) > 1
)
INSERT INTO @ProductReplaceList
SELECT pl.ProductId, MasterProductId FROM dbo.ProductList pl
--select p.ProductId, dp.MinProductId 
--from nata.Product p
--inner join dupProduct dp
--	on p.name= dp.ProductName and p.ProductId != dp.MinProductId
/************************************************ END OF @ProductReplaceList ******************************************/



/************************************************  @DeterminationReplaceList ******************************************/
DECLARE @DeterminationReplaceList Table (OldDeterminationId uniqueidentifier NULL, NewDeterminationId uniqueidentifier NULL)
; WITH DupDetermination AS (
	select d.Name, min(d.DeterminationId) MinDeterminationId	
	from nata.Determination d		----------------------------------- 45
	group by d.Name 
	having count(*) > 1
)
INSERT INTO @DeterminationReplaceList
SELECT DeterminationId, MasterDeterminationid FROM dbo.DeterminantList
--SELECT d.DeterminationId, dd.MinDeterminationId 
--FROM NATA.Determination d
--INNER JOIN DupDetermination dd
--	ON d.Name = dd.Name AND d.DeterminationId != dd.MinDeterminationId


/******************************************* END OF @DeterminationReplaceList ******************************************/


/******************************************************** @TechniqueReplaceList ******************************************/
DECLARE @TechniqueReplaceList Table (OldTechniqueId uniqueidentifier NOT NULL, NewTechniqueId uniqueidentifier NOT NULL)
; WITH DupTechnique AS (
	select t.Name, min(t.TechniqueId) MinTechniqueId	
	from nata.Technique t		----------------------------------- 45
	group by t.Name 
	having count(*) > 1
)
INSERT INTO @TechniqueReplaceList
SELECT TechniqueId, MasterTechniqueid  FROM dbo.TechniqueList
--SELECT t.TechniqueId, dt.MinTechniqueId 
--FROM NATA.Technique t
--INNER JOIN DupTechnique dt
--	ON t.Name = dt.Name AND T.TechniqueId != dt.MinTechniqueId



/************************************************  END OF @TechniqueReplaceList ******************************************/

/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/******************************************* END OF Preparation *********************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/





/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************    Product    *********************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/


			/*********************************************************/
			--===================  NATA.ServiceProduct ============--
			/*********************************************************/

--------------------  UPDATE NATA.ServiceProduct -------------------
PRINT '********************** NATA.ServiceProduct ************************'
UPDATE sp
SET sp.ProductId = prl.NewProductId
--SELECT *				  ----------------------------------- 441					
FROM NATA.ServiceProduct sp
INNER JOIN @ProductReplaceList prl
	ON sp.ProductId = prl.OldProductId

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows UPDATED FROM NATA.ServiceProduct'

--------------------  DELETE NATA.ServiceProduct -------------------
; WITH RAW AS (
	SELECT sp.ServiceProductId, sp.ActivityServiceId, sp.ProductId, p.Name
		, ROW_NUMBER() OVER(PARTITION BY sp.ActivityServiceId, p.name order by p.ProductId) RNK
	FROM NATA.ServiceProduct sp
	INNER JOIN NATA.Product p	
		ON sp.ProductId = p.ProductId
) 
--SELECT * FROM RAW where rnk > 1
DELETE sp
--SELECT	*				----------------------------------- 7
FROM RAW r
INNER JOIN NATA.ServiceProduct sp
	ON r.serviceproductid = sp.ServiceProductId
WHERE RNK > 1

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.ServiceProduct'
PRINT '********************** END OF NATA.ServiceProduct **********************'
			/*********************************************************/
			--==================END OF NATA.ServiceProduct ============--
			/*********************************************************/




			/*********************************************************/
			--===================  NATA.LineScopeProduct ============--
			/*********************************************************/

--------------------  UPDATE NATA.LineScopeProduct -------------------
PRINT ''
PRINT '' 
PRINT '********************** NATA.LineScopeProduct ************************'
UPDATE lp
SET lp.ProductId = prl.NewProductId
--SELECT *				  ----------------------------------- 10482					
FROM NATA.LineScopeProduct lp
INNER JOIN @ProductReplaceList prl
	ON lp.ProductId = prl.OldProductId

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows UPDATED FROM NATA.LineScopeProduct'
--------------------  DELETE NATA.LineScopeProduct -------------------
; WITH RAW AS (
	SELECT lp.LineScopeProductId, lp.LineScopeId, lp.ProductId, p.Name
		, ROW_NUMBER() OVER(PARTITION BY lp.LineScopeId, p.name order by p.ProductId) RNK
	FROM NATA.LineScopeProduct lp
	INNER JOIN NATA.Product p	
		ON lp.ProductId = p.ProductId
)
--SELECT * FROM RAW WHERE RNK > 1
DELETE lp
--SELECT	*				----------------------------------- 2
FROM RAW r
INNER JOIN NATA.LineScopeProduct lp
	ON r.LineScopeProductId = lp.LineScopeProductId
WHERE RNK > 1

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.LineScopeProduct'
PRINT '********************** END OF NATA.LineScopeProduct ************************'
			/*********************************************************/
			--=============== END OF NATA.LineScopeProduct ==========--
			/*********************************************************/


			/*********************************************************/
			--===================  NATA.CompetencyProduct ============--
			/*********************************************************/
PRINT ''
PRINT '' 
PRINT '********************** NATA.CompetencyProduct ************************'
--------------------  UPDATE NATA.CompetencyProduct -------------------
UPDATE cp
SET cp.ProductId = prl.NewProductId
--SELECT *				  ----------------------------------- 64					
FROM NATA.CompetencyProduct cp
INNER JOIN @ProductReplaceList prl
	ON cp.ProductId= prl.OldProductId

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows UPDATEE FROM NATA.CompetencyProduct'
--------------------  DELETE NATA.CompetencyProduct -------------------
; WITH RAW AS (
	SELECT cp.CompetencyProductId, cp.CompetencyId, cp.ProductId, p.Name
		, ROW_NUMBER() OVER(PARTITION BY cp.CompetencyId, p.name order by p.ProductId) RNK
	FROM NATA.CompetencyProduct cp
	INNER JOIN NATA.Product p	
		ON cp.ProductId = p.ProductId
) 
--SELECT * FROM RAW WHERE RNK > 1
DELETE cp
--SELECT	*				----------------------------------- 0
FROM RAW r
INNER JOIN NATA.CompetencyProduct cp
	ON r.CompetencyProductId = cp.CompetencyProductId
WHERE RNK > 1

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.CompetencyProduct'
PRINT '********************** END OF NATA.CompetencyProduct ************************'


			/*********************************************************/
			--=============== END OF NATA.CompetencyProduct ==========--
			/*********************************************************/



			/*********************************************************/
			--===============  NATA.Product ==========--
			/*********************************************************/

PRINT ''
PRINT '' 
PRINT '********************** NATA.Product ************************'
--------------------  DELETE NATA.Product -------------------
DELETE p
--SELECT *				 ----------------------------------- 51
FROM NATA.Product p
WHERE p.ProductId IN (SELECT OldProductId FROM @ProductReplaceList)

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.Product'

PRINT '********************** END OF NATA.Product ************************'

			/*********************************************************/
			--===============END OF NATA.Product ==========--
			/*********************************************************/

/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************ END OF Product *********************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/







/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************DeterminationTechnqiue**************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/
/************************************************************************************************************************/



			/*********************************************************/
			--===================  NATA.DeterminationTechnique ========--
			/*********************************************************/
--------------------  UPDATE NATA.DeterminationTechnique -------------------
PRINT ''
PRINT '' 
PRINT '********************** NATA.DeterminationTechnique ************************'

UPDATE dt
SET dt.DeterminationId = drl.NewDeterminationID
--SELECT *				  ----------------------------------- 441					
FROM NATA.DeterminationTechnique dt
INNER JOIN @DeterminationReplaceList drl	
	ON dt.DeterminationId = drl.OldDeterminationId
PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows UPDATED FROM NATA.DeterminationTechnique for Determination'

UPDATE dt
SET dt.TechniqueId = trl.NewTechniqueId
--SELECT *				  ----------------------------------- 441					
FROM NATA.DeterminationTechnique dt
INNER JOIN @TechniqueReplaceList trl
	ON dt.TechniqueId= trl.OldTechniqueId

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows UPDATED FROM NATA.DeterminationTechnique for Technique'

--------------------  DELETE NATA.DeterminationTechnique -------------------
; WITH RAW AS (
	SELECT dt.DeterminationTechniqueId, d.name DName, t.name TName, sd.ActivityServiceId
		, ROW_NUMBER() OVER(PARTITION BY d.name, t.name, sd.ActivityServiceId ORDER BY dt.DeterminationTechniqueId) RNK
	FROM nata.DeterminationTechnique dt							---6,717
	INNER JOIN nata.ServiceDetermination sd
		ON dt.ServiceDeterminationId = sd.ServiceDeterminationId
	INNER JOIN nata.Determination d
		on dt.DeterminationId = d.DeterminationId
	INNER JOIN nata.Technique t
		on dt.TechniqueId = t.TechniqueId
)
--SELECT * FROM RAW WHERE RNK > 1
DELETE dt
--SELECT * 
FROM nata.DeterminationTechnique dt
INNER JOIN Raw r
	ON r.DeterminationTechniqueId = dt.DeterminationTechniqueId
WHERE RNK > 1

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.DeterminationTechnique'
PRINT '********************** END OF NATA.DeterminationTechnique ***********************'

			/*********************************************************/
			--================ END OF NATA.DeterminationTechnique ====--
			/*********************************************************/



			/*********************************************************/
			--===================  NATA.ServiceDeterminaiton =========--
			/*********************************************************/
--------------------  UPDATE NATA.ServiceDetermination -------------------
PRINT ''
PRINT '' 
PRINT '********************** NATA.ServiceDetermination ************************'

UPDATE sd
SET sd.DeterminationId = drl.NewDeterminationId
--SELECT *				  ----------------------------------- 441					
FROM NATA.ServiceDetermination sd
INNER JOIN @DeterminationReplaceList drl
	ON sd.DeterminationId = drl.OldDeterminationId

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows UPDATED FROM NATA.ServiceDetermination'


--------------------  ????????????  DELETE NATA.ServiceDeterminaiton ??????????? -------------------
; WITH RAW AS (
	SELECT sd.ServiceDeterminationId, sd.ActivityServiceId, sd.DeterminationId, d.Name
		, ROW_NUMBER() OVER(PARTITION BY sd.ActivityServiceId, d.name order by sd.ServiceDeterminationId) RNK
	FROM NATA.ServiceDetermination sd
	INNER JOIN NATA.determination d	
		ON sd.DeterminationId = d.DeterminationId
) 
--SELECT * FROM RAW WHERE RNK > 1
DELETE sd
--SELECT	*				----------------------------------- 7
FROM RAW r
INNER JOIN NATA.ServiceDetermination sd
	ON r.ServiceDeterminationId = sd.ServiceDeterminationId
WHERE RNK > 1

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.ServiceDeterminaiton'
PRINT '********************** END OF NATA.ServiceDetermination ************************'
			/*********************************************************/
			--===================END OF NATA.ServiceDeterminaiton ====--
			/*********************************************************/



			/*********************************************************/
			--===================  NATA.LineScopeDetermination ======--
			/*********************************************************/
--------------------  UPDATE NATA.LineScopeDetermination -------------------

PRINT ''
PRINT '' 
PRINT '********************** NATA.LineScopeDetermination ************************'
UPDATE lsd
SET lsd.DeterminationId = drl.NewDeterminationId
--SELECT *				  ----------------------------------- 10482					
FROM NATA.LineScopeDetermination lsd
INNER JOIN @DeterminationReplaceList drl
	ON lsd.DeterminationId = drl.OldDeterminationId

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows UPDATED FROM NATA.LineScopeDetermination'

--------------------  DELETE NATA.LineScopeDetermination -------------------
; WITH RAW AS (
	SELECT lsd.LineScopeDeterminationId, lsd.LineScopeId, lsd.DeterminationId
		, ROW_NUMBER() OVER(PARTITION BY lsd.LineScopeId, d.name order by lsd.LineScopeDeterminationId) RNK
	FROM NATA.LineScopeDetermination lsd
	INNER JOIN NATA.Determination d
		ON lsd.DeterminationId = d.DeterminationId
) 
--SELECT * FROM RAW WHERE RNK > 1
DELETE lsd
--SELECT	*				----------------------------------- 2
FROM RAW r
INNER JOIN NATA.LineScopeDetermination lsd
	ON r.LineScopeDeterminationId = lsd.LineScopeDeterminationId
WHERE RNK > 1

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.LineScopeDetermination'
PRINT '**********************END OF NATA.LineScopeDetermination ************************'
			/*********************************************************/
			--=============== END OF NATA.LineScopeDetermination =====--
			/*********************************************************/


			/*********************************************************/
			--=============  NATA.CompetencyDetermination ============--
			/*********************************************************/
--------------------  UPDATE NATA.CompetencyDetermination -------------------
PRINT ''
PRINT '' 
PRINT '********************** NATA.CompetencyDetermination ************************'
UPDATE cd
SET cd.DeterminationId = drl.NewDeterminationId
--SELECT *				  ----------------------------------- 64					
FROM NATA.CompetencyDetermination cd
INNER JOIN @DeterminationReplaceList drl
	ON cd.DeterminationId= drl.OldDeterminationId
PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows UPDATEE FROM NATA.CompetencyDetermination'


--------------------  DELETE NATA.CompetencyDetermination -------------------
; WITH RAW AS (
	SELECT cd.CompetencyDeterminationId, cd.CompetencyId, cd.DeterminationId, d.Name
		, ROW_NUMBER() OVER(PARTITION BY cd.CompetencyId, d.name order by d.DeterminationId) RNK
	FROM NATA.CompetencyDetermination cd
	INNER JOIN NATA.Determination d	
		ON cd.DeterminationId = d.DeterminationId
) 
--SELECT * FROM RAW WHERE RNK > 1
DELETE cd
--SELECT	*				----------------------------------- 0
FROM RAW r
INNER JOIN NATA.CompetencyDetermination cd
	ON r.CompetencyDeterminationId = cd.CompetencyDeterminationId
WHERE RNK > 1

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.CompetencyDetermination'
PRINT '**********************END OF NATA.CompetencyDetermination ************************'
			/*********************************************************/
			--===========END OF NATA.CompetencyDetermination ========--
			/*********************************************************/



			/*********************************************************/
			--===============  NATA.Determination ==========--
			/*********************************************************/
--------------------  DELETE NATA.Determination -------------------
PRINT ''
PRINT '' 
PRINT '********************** NATA.Determination ************************'
DELETE d
--SELECT *				 ----------------------------------- 51
FROM NATA.Determination d
WHERE d.DeterminationId IN (SELECT OldDeterminationId FROM @DeterminationReplaceList)

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.Determination'
PRINT '********************** END OF NATA.Determination *****************'
			/*********************************************************/
			--===============END OF NATA.Determination ==========--
			/*********************************************************/



			/*********************************************************/
			--===================  NATA.LineScopeTechnique ======--
			/*********************************************************/

PRINT ''
PRINT '' 
PRINT '********************** NATA.LineScopeTechnique ************************'
--------------------  UPDATE NATA.LineScopeTechnique -------------------

UPDATE lst
SET lst.TechniqueId = trl.NewTechniqueId
--SELECT *				  ----------------------------------- 10482					
FROM NATA.LineScopeTechnique	lst
INNER JOIN @TechniqueReplaceList trl
	ON lst.TechniqueId = trl.OldTechniqueId

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows UPDATED FROM NATA.LineScopeTechnique'

--------------------  DELETE NATA.LineScopeTechnique -------------------
; WITH RAW AS (
	SELECT lst.LineScopeTechniqueId, lst.LineScopeId, lst.TechniqueId
		, ROW_NUMBER() OVER(PARTITION BY lst.LineScopeId, t.name order by lst.TechniqueId) RNK
	FROM NATA.LineScopeTechnique lst
	INNER JOIN NATA.Technique t
		ON lst.TechniqueId = t.TechniqueId
) 
--SELECT * FROM RAW WHERE RNK > 1
DELETE lst
--SELECT	*				----------------------------------- 2
FROM RAW r
INNER JOIN NATA.LineScopeTechnique lst
	ON r.LineScopeTechniqueId = lst.LineScopeTechniqueId
WHERE RNK > 1

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.LineScopeTechnique'
PRINT '********************** END OF NATA.LineScopeTechnique ************************'
			/*********************************************************/
			--=============== END OF NATA.LineScopeTechnique =====--
			/*********************************************************/




			/*********************************************************/
			--=============  NATA.CompetencyTechnique ============--
			/*********************************************************/
--------------------  UPDATE NATA.CompetencyTechnique -------------------

PRINT ''
PRINT '' 
PRINT '********************** NATA.CompetencyTechnique ************************'

UPDATE ct
SET ct.TechniqueId = trl.NewTechniqueId
--SELECT *				  ----------------------------------- 64					
FROM NATA.CompetencyTechnique ct
INNER JOIN @TechniqueReplaceList trl
	ON ct.TechniqueId= trl.OldTechniqueId

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows UPDATED FROM NATA.CompetencyTechnique'

--------------------  DELETE NATA.CompetencyTechnique -------------------
; WITH RAW AS (
	SELECT ct.CompetencyTechniqueId, ct.CompetencyId, ct.TechniqueId, t.Name
		, ROW_NUMBER() OVER(PARTITION BY ct.CompetencyId, t.name order by ct.CompetencyTechniqueId) RNK
	FROM NATA.CompetencyTechnique ct
	INNER JOIN NATA.Technique t	
		ON ct.TechniqueId = t.TechniqueId
) 
--SELECT * FROM RAW WHERE RNK > 1
DELETE ct
--SELECT	*				----------------------------------- 0
FROM RAW r
INNER JOIN NATA.CompetencyTechnique ct
	ON r.CompetencyTechniqueId = ct.CompetencyTechniqueId
WHERE RNK > 1

PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.CompetencyTechnique'
PRINT '**********************END OF NATA.CompetencyTechnique ************************'
			/*********************************************************/
			--===========END OF NATA.CompetencyTechnique ========--
			/*********************************************************/




			/*********************************************************/
			--===============  NATA.Technique ==========--
			/*********************************************************/
--------------------  DELETE NATA.Technique -------------------
PRINT ''
PRINT '' 
PRINT '********************** NATA.Technique ************************'
DELETE t
--SELECT *				 ----------------------------------- 51
FROM NATA.Technique t
WHERE t.TechniqueId IN (SELECT OldTechniqueId FROM @TechniqueReplaceList)
PRINT CAST (@@RowCOUNT AS NVARCHAR(10))  + ' Rows DELETED FROM NATA.Technique'

PRINT '**********************END OF NATA.Technique ************************'
			/*********************************************************/
			--===============END OF NATA.Technique ==========--
			/*********************************************************/

GO
USE master
GO
SET NOCOUNT OFF