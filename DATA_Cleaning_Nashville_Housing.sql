/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, convert(date,SaleDate)
From NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

-- If it doesn't Update properly

Alter TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

Select SaleDateConverted
From NashvilleHousing
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
Select *
From NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousing

Alter TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


select *
from NashvilleHousing



select OwnerAddress
from NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing

---does Process backwards


Alter TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


Alter TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select *
from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   Else SoldAsVacant
END
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   Else SoldAsVacant
END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNUMCTE AS(
select *, ROW_NUMBER() over (
partition by ParcelID, 
	PropertyAddress,
	SalePrice, 
	SaleDate, 
	LegalReference
	order by UniqueID) row_num
from NashvilleHousing
--order by ParcelID
)

select *
from RowNUMCTE
where row_num >1
--order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
select *
from NashvilleHousing

Alter TABLE NashvilleHousing
--drop Column OwnerAddress, TaxDistrict, PropertyAddress
drop Column SaleDate

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
