SELECT* 
FROM car_prices

DROP TABLE IF EXISTS #ClearNull
CREATE TABLE #ClearNull (
year float,
make nvarchar(255),
model nvarchar(255),
trim nvarchar(255),
body nvarchar(255),
transmission nvarchar(255),
vin nvarchar(255),
state nvarchar(255),
condition float,
odometer float,
color nvarchar(255),
interior nvarchar(255),
seller nvarchar(255),
mmr float,
sellingprice float,
saledate nvarchar(255),
)

INSERT INTO #ClearNull
SELECT *
FROM car_prices
WHERE make is NOT NULL

SELECT *
FROM #ClearNull

/* WHERE THE "make" is not Null*/
CREATE TABLE NewCarPrices (
year float,
make nvarchar(255),
model nvarchar(255),
trim nvarchar(255),
body nvarchar(255),
transmission nvarchar(255),
vin nvarchar(255),
state nvarchar(255),
condition float,
odometer float,
color nvarchar(255),
interior nvarchar(255),
seller nvarchar(255),
mmr float,
sellingprice float,
saledate nvarchar(255),
)

INSERT INTO NewCarPrices
SELECT *
FROM car_prices
WHERE make is NOT NULL AND saledate is NOT NULL

SELECT *
FROM NewCarPrices
ORDER BY saledate

/* I Update the transmission car to Automatic or manual using the car that has the same 
year, model, trim and body, but the transmission is NOT NULL*/

SELECT a.year,a.make,a.model, a.trim, a.body,a.transmission, 
a. year, b.make, b.model,b.trim, b.body, b.transmission, 
ISNULL (a.transmission,b.transmission)
FROM NewCarPrices AS a 
JOIN NewCarPrices AS b
	ON a.year = b.year
	AND a.make = b.make
	AND a.model = b.model
	AND a.trim = b.trim
	AND a.body = b.body
	AND a.vin <> b.vin
WHERE a.transmission is NULL

UPDATE a
SET transmission = ISNULL(a.transmission,b.transmission)
FROM NewCarPrices AS a 
JOIN NewCarPrices AS b
	ON a.year = b.year
	AND a.make = b.make
	AND a.model = b.model
	AND a.trim = b.trim
	AND a.body = b.body
	AND a.vin <> b.vin
WHERE a.transmission is NULL

SELECT a.vin, a.transmission, b.vin, b.transmission
FROM NewCarPrices AS a 
JOIN car_prices AS b
	ON a.vin = b.vin
WHERE b.transmission is NULL

SELECT *
FROM NewCarPrices
WHERE transmission is NULL

/* Deleting duplicated data*/

SELECT vin, saledate, COUNT(*) AS total_sold
FROM NewCarPrices
GROUP BY vin, saledate
HAVING COUNT(*) > 1;

SELECT *
FROM NewCarPrices
WHERE vin = '1lnhl9ft3dg604165'

WITH DuplicatesToKeep AS (
    SELECT vin, saledate, ROW_NUMBER() OVER (PARTITION BY vin, saledate ORDER BY vin) AS RowNum
    FROM NewCarPrices
)
DELETE FROM DuplicatesToKeep
WHERE RowNum > 1;

/* Insert Color with the same vin to reduce NULL value */
SELECT a.make, a.model, a.color, b.make, b.model, b.color, a.saledate, b.saledate
FROM NewCarPrices as a
JOIN NewCarPrices as b
	ON a.vin = b.vin
WHERE a.color is NULL

UPDATE a
SET color = ISNULL(a.color,b.color)
FROM NewCarPrices AS a 
JOIN NewCarPrices AS b
	ON a.vin = b.vin
WHERE a.color is NULL

SELECT saledate
FROM NewCarPrices
WHERE saledate is NULL

/* Deleting error shift data */

SELECT *
FROM NewCarPrices 
WHERE saledate not like '%[^0-9]%' 

DELETE FROM NewCarPrices
WHERE saledate not like '%[^0-9]%' 

SELECT saledate,
CAST(SUBSTRING(saledate, CHARINDEX(' ', saledate) + 1, LEN(saledate) - CHARINDEX(' ', saledate))
 AS nvarchar(12))
FROM NewCarPrices

UPDATE NewCarPrices
SET saledate = CAST(SUBSTRING(saledate, CHARINDEX(' ', saledate) + 1, LEN(saledate) - CHARINDEX(' ', saledate))
 AS nvarchar(12))
 
UPDATE NewCarPrices
SET saledate = CONVERT(date,saledate)

SELECT *
FROM NewCarPrices

SELECT year, make, model, trim, condition, odometer, saledate,
    CASE 
        WHEN DATEDIFF(YEAR, CAST(saledate AS DATE), year) < 2 AND odometer < 20000 AND condition > 40 THEN 'Excellent'
        WHEN DATEDIFF(YEAR, CAST(saledate AS DATE), year) < 4 AND odometer > 20000 AND condition > 30 THEN 'Great'
        WHEN condition > 20 AND odometer > 20000 THEN 'Good'
        WHEN condition < 5 AND odometer > 100000 THEN 'Bad'
        ELSE 'Unknown'
    END AS 'Condition'
FROM NewCarPrices
ORDER BY make

SELECT year, make, model, trim, condition, odometer, saledate,
	CASE
		WHEN (sellingprice - mmr) < 0 THEN 'LOSS'
		ELSE 'PROFIT'
	END AS 'Profit or LOSS'
FROM NewCarPrices
ORDER BY make

ALTER TABLE NewCarPrices
ADD Car_Condition_Category NVARCHAR(255),
Profit_or_Loss NVARCHAR(255),
Country NVARCHAR(255)

UPDATE NewCarPrices
SET Car_Condition_Category = 
    CASE 
        WHEN DATEDIFF(YEAR, CAST(saledate AS DATE), year) < 2 AND odometer < 20000 AND condition > 40 THEN 'Excellent'
        WHEN DATEDIFF(YEAR, CAST(saledate AS DATE), year) < 4 AND odometer < 30000 AND condition > 20 THEN 'Great'
        WHEN condition >= 20 AND odometer >= 30000 THEN 'Good'
		WHEN condition < 20 AND odometer >= 30000 THEN 'Bad'
        WHEN condition < 5 AND odometer > 100000 THEN 'Very Bad'
        ELSE 'Unknown'
    END 

UPDATE NewCarPrices
SET Profit_or_Loss = 
    CASE
		WHEN (sellingprice - mmr) < 0 THEN 'LOSS'
		ELSE 'PROFIT'
	END

SELECT *
FROM NewCarPrices
WHERE Car_Condition_Category = 'Unknown'
ORDER BY condition DESC

ALTER TABLE NewCarPrices
ADD Country NVARCHAR(255)

UPDATE NewCarPrices
SET Country = 
    CASE 
        WHEN state IN ('ab', 'on', 'qc', 'ns') THEN 'Canada'
        ELSE 'United States'
    END

SELECT state, Country
FROM NewCarPrices
WHERE state IN ('ab', 'on', 'qc', 'ns')






 

