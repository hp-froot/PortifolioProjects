-- Cleaning Data in SQL Queries
-- Skills used: Converting Data Types, Update table, alter table, join, parsename, substring, partition by, case statements


Select *
From PortfolioHousingData.dbo.NashvilleHousing

-------------------------------------------------------------------------------------

-- Standardize Date Format:

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioHousingData.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From PortfolioHousingData.dbo.NashvilleHousing

-------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioHousingData.dbo.NashvilleHousing
Where PropertyAddress is null

Select *
From PortfolioHousingData.dbo.NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioHousingData.dbo.NashvilleHousing a
JOIN PortfolioHousingData.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioHousingData.dbo.NashvilleHousing a
JOIN PortfolioHousingData.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioHousingData.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioHousingData.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioHousingData.dbo.NashvilleHousing

-- For Owner Address

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From PortfolioHousingData.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioHousingData.dbo.NashvilleHousing

--------------------------------------------------------------------------------

-- Chage Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioHousingData.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioHousingData.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-------------------------------------------------------------------------------------

--Remove Duplicates (Usullay it is best pratice to create a temp table with the removed duplicates instead of deleting data from the database)

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
From PortfolioHousingData.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1


-------------------------------------------------------------------------------------

--Get Rid of Unused Columns (It is best practice to not do this to the raw data)

Select *
From PortfolioHousingData.dbo.NashvilleHousing

ALTER TABLE PortfolioHousingData.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
