Select *
From [Portfolio Project]..[Nashville Housing Project]

--- Things to do in this particular Project---


--- 1. Cleaning the date in SQL Queries ---

----Standardizing the sale date----

Select SaleDateConverted, CONVERT(DATE, SaleDate)
From [Portfolio Project]..[Nashville Housing Project]

--- This code does not do anything to the table.

---Update [Nashville Housing Project]
---SET SaleDate = CONVERT(DATE, SaleDate)

ALTER Table [Nashville Housing Project]
ADD SaleDateConverted DATE;

Update [Nashville Housing Project]
SET SaleDateConverted = CONVERT(DATE, SaleDate)


--- 2. Populate Property Address Date ---

Select *
From [Nashville Housing Project]
-- Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing Project] a
Join [Nashville Housing Project] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing Project] a
Join [Nashville Housing Project] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


--- 3. Breaking address into Individual Colums (Address, City, State)----

Select PropertyAddress
From [Nashville Housing Project]
-- Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as ADDRESS
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as ADDRESS

From [Nashville Housing Project]

--- Creating new columns ----
ALTER Table [Nashville Housing Project]
ADD PropertySplitAddress nvarchar(255);

Update [Nashville Housing Project]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER Table [Nashville Housing Project]
ADD PropertySplitCity nvarchar(255);

Update [Nashville Housing Project]
SET  PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


---Verifying if we did the right thing ----

Select *
From [Portfolio Project]..[Nashville Housing Project]

---It could be seen that the new created columns are placed at the end of the data.

--- Working on the owner address--- 

Select OwnerAddress
From [Portfolio Project]..[Nashville Housing Project]
Where OwnerAddress is not null


Select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From [Portfolio Project]..[Nashville Housing Project]
Where OwnerAddress is not null


ALTER Table [Nashville Housing Project]
ADD OwnerSplitAddress nvarchar(255);

Update [Nashville Housing Project]
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)


ALTER Table [Nashville Housing Project]
ADD OwnerSplitCity nvarchar(255);

Update [Nashville Housing Project]
SET  OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER Table [Nashville Housing Project]
ADD OwnerSplitState nvarchar(255);

Update [Nashville Housing Project]
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)


Select *
From [Portfolio Project]..[Nashville Housing Project]


--- Change Y and N into Yes and No in "Sold as Vacant field"

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project]..[Nashville Housing Project]
Group By SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant ='Y' THEN 'Yes'
	   When SoldAsVacant ='N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio Project]..[Nashville Housing Project]


Update [Nashville Housing Project]
SET SoldAsVacant = CASE When SoldAsVacant ='Y' THEN 'Yes'
	   When SoldAsVacant ='N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates ---

With RownumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER  BY
					UniqueID
					) row_num
From [Portfolio Project]..[Nashville Housing Project]
--Order by ParcelID
)
Select *
From RownumCTE
Where row_num > 1
Order by PropertyAddress


--- Delete Unused Columns -----

Select *
From [Portfolio Project]..[Nashville Housing Project]


ALTER TABLE [Portfolio Project]..[Nashville Housing Project]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project]..[Nashville Housing Project]
DROP COLUMN SaleDate