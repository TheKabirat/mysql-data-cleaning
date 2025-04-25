---Data cleaning in sql---

SELECT * 
FROM `nashville housing data for data cleaning 2`;

---1. Duplicating the tables
CREATE TABLE nashville_housing_data
LIKE `nashville housing data for data cleaning 2`;

INSERT INTO nashville_housing_data
SELECT *
FROM `nashville housing data for data cleaning 2`;

SELECT *
FROM nashville_housing_data;

--Rearranging the saledate
SELECT 
    DATE_FORMAT(STR_TO_DATE(saledate, '%M %e, %Y'), '%Y-%m-%d') AS formatted_date
FROM nashville_housing_data;

UPDATE nashville_housing_data
SET saledate = STR_TO_DATE(saledate, '%M %e, %Y');

__Cleaning and populating the property address--

SELECT *
FROM nashville_housing_data
WHERE Propertyaddress IS NULL OR Propertyaddress = '';

UPDATE nashville_housing_data
SET Propertyaddress = NULL 
WHERE Propertyaddress = '';

SELECT *
FROM nashville_housing_data
ORDER BY ParcelID;

SELECT A.ParcelID, A.Propertyaddress, B.ParcelID, B.Propertyaddress, IFNULL(A.Propertyaddress, B.Propertyaddress)
FROM nashville_housing_data A
JOIN nashville_housing_data B
   ON A.ParcelID =  B.ParcelID
  AND A.uniqueID != B.uniqueID
WHERE A.Propertyaddress IS NULL;

UPDATE nashville_housing_data A
JOIN nashville_housing_data B
   ON A.ParcelID =  B.ParcelID
  AND A.uniqueID != B.uniqueID
SET A.Propertyaddress = IFNULL(A.Propertyaddress, B.Propertyaddress)
WHERE A.Propertyaddress IS NULL;

SELECT Propertyaddress
FROM nashville_housing_data
WHERE Propertyaddress IS NULL;


___Breaking out address into individual columns(address, city, state)
SELECT Propertyaddress
FROM nashville_housing_data
ORDER BY ParcelID;

SELECT 
SUBSTRING_INDEX(Propertyaddress, ',', 1) AS Address,
SUBSTRING_INDEX(Propertyaddress, ',', -1) AS City
FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
  ADD COLUMN `PropertySplitAddress` VARCHAR(255),
  ADD COLUMN `PropertyCity`    VARCHAR(100);


UPDATE nashville_housing_data
SET
  PropertySplitAddress = TRIM( SUBSTRING_INDEX(Propertyaddress, ',', 1) ),
  PropertyCity = TRIM( SUBSTRING_INDEX(Propertyaddress, ',', -1) )


___Breaking out owneraddress into individual columns(address, city, state)
SELECT owneraddress
FROM nashville_housing_data;

SELECT 
SUBSTRING_INDEX(owneraddress, ',', 1) AS Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(Owneraddress, ',', 2), ',', -1)  AS City,
SUBSTRING_INDEX(SUBSTRING_INDEX(Owneraddress, ',', 3), ',', -1) AS State
FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
  ADD COLUMN `OwnerSplitAddress` VARCHAR(255),
  ADD COLUMN `OwnerCity`    VARCHAR(100),
  ADD COLUMN `OwnerState` VARCHAR(50);


UPDATE nashville_housing_data
SET
  OwnerSplitAddress = TRIM( SUBSTRING_INDEX(owneraddress, ',', 1) ),
  OwnerCity= TRIM( SUBSTRING_INDEX(SUBSTRING_INDEX(Owneraddress, ',', 2), ',', -1) ),
 OwnerState= TRIM( SUBSTRING_INDEX(SUBSTRING_INDEX(Owneraddress, ',', 3), ',', -1) );
 
 SELECT *
FROM nashville_housing_data;

--Change Y and N to YES or NO in 'Sold as Vacant' field--

SELECT DISTINCT(SoldasVacant), Count(SoldasVacant)
FROM nashville_housing_data
GROUP BY SoldasVacant
ORDER BY 2;

SELECT SoldasVacant,
CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
     WHEN SoldasVacant = 'N' THEN 'No'
     ELSE SoldasVacant
     END
FROM nashville_housing_data;

UPDATE nashville_housing_data
SET SoldasVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
     WHEN SoldasVacant = 'N' THEN 'No'
     ELSE SoldasVacant
     END;
     
 --Removing Duplicates--
 WITH RowNumCTE AS( 
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
             SalePrice,
             SaleDate,
             LegalReference
             ORDER BY UniqueID) AS row_num
FROM nashville_housing_data)

SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


---Delete Unused Columns----
ALTER TABLE nashville_housing_data
DROP COLUMN OwnerAddress;

ALTER TABLE nashville_housing_data
DROP COLUMN TaxDistrict;

ALTER TABLE nashville_housing_data
DROP COLUMN PropertyAddress;

SELECT *
FROM nashville_housing_data;
            