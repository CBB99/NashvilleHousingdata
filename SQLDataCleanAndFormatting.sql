/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [CleaningData].[dbo].[DataClean]

  select * 
  from dbo.DataClean

  -- Standardize date format
  select SaleDateConverted, convert(Date, SaleDate) 
  from dbo.DataClean

  update DataClean
  set SaleDate = convert(Date, SaleDate)

  alter table dbo.DataClean
  add SaleDateConverted Date;

  update DataClean
  set SaleDateConverted = convert(Date, SaleDate)

  -- Populate property address data
  select *
  from dbo.DataClean
  --where PropertyAddress is null
  order by ParcelID
  
  -- If ParcelID is duplicate and address is null, replacing null value with address from ParcelID
  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  from dbo.DataClean a
  join dbo.DataClean b
      on a.ParcelID = b.ParcelID
	  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  from dbo.DataClean a
  join dbo.DataClean b
      on a.ParcelID = b.ParcelID
	  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out address into individual columns (Address, City, State)
select PropertyAddress
  from dbo.DataClean
  --where PropertyAddress is null
  --order by ParcelID

  select 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
  , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

  from dbo.DataClean


  alter table dbo.DataClean
  add PropertySplitAddress Nvarchar(255)

  update DataClean
  set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  alter table dbo.DataClean
  add PropertySplitCity Nvarchar(255)

   update DataClean
  set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

select *
from dbo.DataClean

select OwnerAddress
from dbo.DataClean

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from dbo.DataClean

 alter table dbo.DataClean
  add OwnerSplitAddress Nvarchar(255)

  update DataClean
  set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

  alter table dbo.DataClean
  add OwnerSplitCity Nvarchar(255)

   update DataClean
  set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

    alter table dbo.DataClean
  add OwnerSplitState Nvarchar(255)

   update DataClean
  set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

select * 
from dbo.DataClean
-- Change Y and N to Yes and No in "Sold as Vacant" field
select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END
from dbo.DataClean

update dbo.DataClean
Set SoldAsVacant =  CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END

select distinct(SoldAsVacant), count(SoldAsVacant)
from dbo.DataClean
group by SoldAsVacant
order by 2

-- Remove duplicates and unused columns

With RowNumCTE AS(
select *, 
  ROW_NUMBER() OVER (
  partition by ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY 
			      UniqueID
				  ) row_num
from dbo.DataClean
--order by ParcelID
) 
Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

ALTER TABLE dbo.DataClean
drop column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.DataClean
drop column Saledate

select * 
from dbo.DataClean
