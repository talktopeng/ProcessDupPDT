USE [master]
GO

sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.15.0' , N'AllowInProcess' , 1
GO

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.15.0' , N'DynamicParameters' , 1
GO

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0' , N'AllowInProcess' , 1
GO

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0' , N'DynamicParameters' , 1
GO

SELECT *
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0 xml;HDR=YES;IMEX=1;Database=C:\temp\MasterProductsList.xlsx',
    'select * from [sheet1$]')
GO

SELECT *
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0 xml;HDR=YES;IMEX=1;Database=C:\temp\MasterDeterminantList.xlsx',
    'select * from [sheet1$]')
GO

SELECT *
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.15.0',
    'Excel 12.0 xml;HDR=Yes;IMEX=1;Database=C:\temp\MasterDeterminantList.xlsx',
    'select * from [sheet1$]')
GO
