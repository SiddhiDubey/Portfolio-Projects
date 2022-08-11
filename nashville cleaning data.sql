select *
from datacleaning.dbo.NashvilleHousing

-- standardize data format

select SaleDate, CONVERT(Date,SaleDate)
from datacleaning.DBO.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)


-- Populate Property Address Data

select *
from datacleaning.dbo.NashvilleHousing
--where PropertyAddress is Null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from datacleaning.dbo.NashvilleHousing a
JOIN datacleaning.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from datacleaning.dbo.NashvilleHousing a
JOIN datacleaning.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]



-- Breaking out Adress into Individual Columns(Address,City, State)

Select PropertyAddress
From datacleaning.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From datacleaning.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From datacleaning.dbo.NashvilleHousing

select OwnerAddress
from datacleaning.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From datacleaning.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


select *
from datacleaning.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" Field
select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from datacleaning.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM datacleaning.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-- Remove Duplicates
WITH RowNumCTE AS(
Select *
, ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
				UniqueID
				) row_num


FROM datacleaning.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
--Order by PropertyAddress


-- delete Unused Columns

select * 
from datacleaning.dbo.NashvilleHousing

ALTER TABLE datacleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE datacleaning.dbo.NashvilleHousing
DROP COLUMN SaleDate
