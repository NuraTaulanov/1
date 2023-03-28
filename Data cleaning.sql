/*
Cleaning Data in SQL Queries
*/
select * 
from [data cleaning].dbo.Nashville
--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
select SaleDateConverted, convert(date,SaleDate)
from [data cleaning].dbo.Nashville

update nashville
set SaleDate = convert(date,SaleDate)

alter table nashville
add SaleDateConverted Date;
update nashville
set SaleDateConverted = convert(date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
select *
from [data cleaning].dbo.Nashville
order by parcelID

select a.ParcelID,a.propertyAddress, b.ParcelID,b.propertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from [data cleaning].dbo.Nashville a
join [data cleaning].dbo.Nashville b
	on a.parcelID=b.parcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null


update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from [data cleaning].dbo.Nashville a
join [data cleaning].dbo.Nashville b
	on a.parcelID=b.parcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
use [data cleaning]
go

select PropertyAddress
from [data cleaning].dbo.Nashville
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from [data cleaning].dbo.Nashville

alter table nashville
add PropertySplitAddress nvarchar(255);
update nashville
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table nashville
add PropertySplitCity nvarchar(255);
update nashville
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * 
from [data cleaning].dbo.Nashville


select OwnerAddress
from [data cleaning].dbo.Nashville


select 
PARSENAME(replace(OwnerAddress,',','.'),3) as OwnerSplitAddress,
PARSENAME(replace(OwnerAddress,',','.'),2) as OwnerSplitCity,
PARSENAME(replace(OwnerAddress,',','.'),1) as OwnerSplitState
from [data cleaning].dbo.Nashville


use [data cleaning]
go
alter table nashville
add OwnerSplitAddress nvarchar(255);
update nashville
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table nashville
add OwnerSplitCity nvarchar(255);
update nashville
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table nashville
add OwnerSplitState nvarchar(255);
update nashville
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

select * 
from [data cleaning].dbo.Nashville
--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (soldAsVacant), count(soldAsVacant)
from [data cleaning].dbo.Nashville
group by SoldAsVacant
order by 2


select SoldAsVacant
,case when soldAsVacant='Y' then 'Yes'
	  when SoldAsVacant='N' then 'No'
	  else SoldAsVacant
	  end
from [data cleaning].dbo.Nashville

update Nashville
set SoldAsVacant=case when soldAsVacant='Y' then 'Yes'
	  when SoldAsVacant='N' then 'No'
	  else SoldAsVacant
	  end
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
with RowNumCTE as (
select *, 
	ROW_NUMBER() over (
	partition by parcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 legalReference
				 order by 
					uniqueID
					) row_num
					
from [data cleaning].dbo.Nashville
)
select *
from RowNumCTE
where row_num>1
order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select * 
from [data cleaning].dbo.Nashville

alter table [data cleaning].dbo.Nashville
drop column OwnerAddress, TaxDistrict, PropertyAddress,SaleDate

