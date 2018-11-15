USE AIMS_UAT
GO
DROP TABLE dbo.Productlist
DROP TABLE dbo.DeterminantList
DROP TABLE dbo.Techniquelist
GO

CREATE TABLE dbo.Productlist (ProductId NVARCHAR(500)
								, Name NVARCHAR(500)
								, MasterProductId NVARCHAR(500))



CREATE TABLE dbo.DeterminantList (DeterminationId NVARCHAR(500)
								, Name NVARCHAR(500) 
								, MasterDeterminationId NVARCHAR(500))


CREATE TABLE dbo.Techniquelist (TechniqueId NVARCHAR(500)
								, Name NVARCHAR(500)
								, MasterTechniqueId NVARCHAR(500))



GO

---------------------------------------------------------
------- Change connection to local ----------------------
---------------------------------------------------------
INSERT INTO vmdbnrh78.aims_uat.dbo.Productlist
SELECT ProductId, Name, MasterProductId
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0 xml;HDR=YES;IMEX=1;Database=C:\temp\MasterProductsList.xlsx',
    'select * from [sheet1$]')
GO
INSERT INTO vmdbnrh78.aims_uat.dbo.DeterminantList
SELECT DeterminationId, Name, MasterDeterminatId MasterDeterminationId
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 8.0;HDR=Yes;Database=C:\temp\MasterDeterminantList.xlsx',
    'select * from [sheet1$]')
GO
INSERT INTO vmdbnrh78.aims_uat.dbo.Techniquelist
SELECT TechniqueId, Name, MasterTechniqueId
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 8.0;HDR=YES;Database=C:\temp\MasterTechniqueList.xlsx',
    'select * from [sheet1$]')






INSERT INTO vmdbnrh78.aims_dev.dbo.Productlist
SELECT ProductId, Name, MasterProductId
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0 xml;HDR=YES;IMEX=1;Database=C:\temp\MasterProductsList.xlsx',
    'select * from [sheet1$]')
GO
INSERT INTO vmdbnrh78.aims_dev.dbo.DeterminantList
SELECT DeterminationId, Name, MasterDeterminatId MasterDeterminationId
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 8.0;HDR=Yes;Database=C:\temp\MasterDeterminantList.xlsx',
    'select * from [sheet1$]')
GO
INSERT INTO vmdbnrh78.aims_dev.dbo.Techniquelist
SELECT TechniqueId, Name, MasterTechniqueId
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 8.0;HDR=YES;Database=C:\temp\MasterTechniqueList.xlsx',
    'select * from [sheet1$]')
Go