SELECT* 
FROM ProjectCleaningHouse..HouseCleaning

ALTER TABLE ProjectCleaningHouse..HouseCleaning
ADD SaleDateConverted DATE

SELECT SaleDateConverted
FROM ProjectCleaningHouse..HouseCleaning

UPDATE ProjectCleaningHouse..HouseCleaning
SET SaleDateConverted = CAST(SaleDate AS DATE)

------------------------------------------------------------------------------

SELECT *
FROM ProjectCleaningHouse..HouseCleaning
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectCleaningHouse..HouseCleaning AS a
JOIN ProjectCleaningHouse..HouseCleaning AS b
	ON a.ParcelID = b.ParcelID AND
	a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is not NULL

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectCleaningHouse..HouseCleaning AS a
JOIN ProjectCleaningHouse..HouseCleaning AS b
	ON a.ParcelID = b.ParcelID AND
	a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

----------------------------------------------------------------------------------------------------------------

SELECT PropertyAddress
FROM ProjectCleaningHouse..HouseCleaning
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

ALTER TABLE ProjectCleaningHouse..HouseCleaning
Add City nvarchar(255)

ALTER TABLE ProjectCleaningHouse..HouseCleaning
Add Address nvarchar(255)

UPDATE ProjectCleaningHouse..HouseCleaning
SET Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) 

UPDATE ProjectCleaningHouse..HouseCleaning
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

SELECT *
FROM ProjectCleaningHouse..HouseCleaning

-----------------------------------------------------------------------------------------------------------

SELECT
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM ProjectCleaningHouse..HouseCleaning

ALTER TABLE ProjectCleaningHouse..HouseCleaning
ADD Owner_Address nvarchar(255)

ALTER TABLE ProjectCleaningHouse..HouseCleaning
ADD Owner_City nvarchar(255)

ALTER TABLE ProjectCleaningHouse..HouseCleaning
ADD Owner_State nvarchar(255)

UPDATE ProjectCleaningHouse..HouseCleaning
SET Owner_Address = PARSENAME (REPLACE(OwnerAddress,',','.'),3)

UPDATE ProjectCleaningHouse..HouseCleaning
SET Owner_City = PARSENAME (REPLACE(OwnerAddress,',','.'),2)

UPDATE ProjectCleaningHouse..HouseCleaning
SET Owner_State = PARSENAME (REPLACE(OwnerAddress,',','.'),1)

SELECT Owner_Address,Owner_City,Owner_State
FROM ProjectCleaningHouse..HouseCleaning

-----------------------------------------------------------------------------------------------------------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectCleaningHouse..HouseCleaning
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM ProjectCleaningHouse..HouseCleaning

UPDATE ProjectCleaningHouse..HouseCleaning
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-----------------------------------------------------------------------------------------------------------

