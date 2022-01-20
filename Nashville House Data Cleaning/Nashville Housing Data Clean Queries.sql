/*
Cleaning Data in SQL Queries
by Minh Le
*/

Select * 
From [Portfolio Database]..NashvilleHousing
------------------------------------------------------------------------------------
-- Problem: SaleDate was in Date Time format
-- Solution: Standardize Sale Date Format


--Checking Sale Date
Select SaleDate, CONVERT(Date, SaleDate)
From [Portfolio Database]..NashvilleHousing

-- This doesn't work for some reasons
Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- Adding a different column since the above query didn't work
Alter Table NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


--Checking
Select SaleDateConverted
From [Portfolio Database]..NashvilleHousing

----------------------------------------------------------------
-- Problem: Some Property Address was missing
-- Solution: Populate Property Address data

Select * 
From [Portfolio Database]..NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID

-- Joining the table with itself so we can compare ParcelID
-- Logic: Same Parcel ID ==> Same Property Address

Select a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Database]..NashvilleHousing a
Join [Portfolio Database]..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHere a.PropertyAddress is null

-- Updating the table according to the logic
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Database]..NashvilleHousing a
Join [Portfolio Database]..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHere a.PropertyAddress is null


-- Checking data after updated
SELECT PropertyAddress
FROM [Portfolio Database]..NashvilleHousing
Where PropertyAddress is null


-----------------------------------------------------------------------------------------------------------------------
-- Problem: Property Address and Owner Adress contained address, city  and state together
-- Solution: Breaking out Address into Individual Columns (Address, City, State)



-- Updating the Property Address first
Select PropertyAddress
From [Portfolio Database]..NashvilleHousing

-- Creating the substring from the original address (from index 1 to the comma)
Select 
SUBSTRING(PropertyAddress, 1, CharIndex(',', PropertyAddress)) AS Address
From [Portfolio Database]..NashvilleHousing


-- Adding the substring for City
Select 
SUBSTRING(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CharIndex(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City,
From [Portfolio Database]..NashvilleHousing



-- Altering and updating
Alter Table NashVilleHousing
Add PropertySplitAddress Nvarchar(255);

Alter Table NashVilleHousing
Add PropertySplitCity Nvarchar(255)


Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CharIndex(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Checking
Select * 
From [Portfolio Database]..NashvilleHousing



-- Updating the Owner Address

Select OwnerAddress
From [Portfolio Database]..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From [Portfolio Database]..NashvilleHousing


-- Altering Table
Alter Table NashVilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table NashVilleHousing
Add OwnerSplitCity Nvarchar(255)

Alter Table NashVilleHousing
Add OwnerSplitState Nvarchar(255);


Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Checking
Select * 
From [Portfolio Database]..NashvilleHousing


----------------------------------------------------------------------------------
-- Problem: In the "Sold as Vacant" column, there were mixed answers ("Yes", "No", "Y", "N")
-- Solution: Change Y and N to Yes and No in "Sold as Vacant" field

-- Seeing all the answers
Select Distinct(SoldAsVacant)
From [Portfolio Database]..NashvilleHousing


Select SoldAsVacant,
	Case When  SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From [Portfolio Database]..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = 
	Case When  SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

-- Checking
Select Distinct(SoldAsVacant)
From [Portfolio Database]..NashvilleHousing


----------------------------------------------------------------------
-- Problem: There were rows with the same PropertyAddressm Sale Price, ParcelID, SalePrice, SaleDate, etc
-- Solution: Remove Duplicates
-- Assumptions: UniqueID doesn't come into play

WITH RowNumCTE AS(
Select *,
	Row_Number() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY  
					UniqueID
					) row_num
From [Portfolio Database]..NashvilleHousing
--Order By ParcelID
)
DELETE
From RowNumCTE
where row_num > 1


-- Checking
WITH RowNumCTE AS(
Select *,
	Row_Number() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY  
					UniqueID
					) row_num
From [Portfolio Database]..NashvilleHousing
)
Select *
From RowNumCTE
where row_num > 1



-------------------
-- Problem: Some columns are unused Such as OwnerAdress that we have split apart
-- Deleting Unused Column


Select * 
From [Portfolio Database]..NashvilleHousing



Alter Table [Portfolio Database]..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table [Portfolio Database]..NashvilleHousing
Drop Column SaleDate


Select * 
From [Portfolio Database]..NashvilleHousing
