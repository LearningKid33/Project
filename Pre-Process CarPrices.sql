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
WHERE make is NOT NULL AND saledate is NOT NULL AND odometer is NOT NULL

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

ALTER TABLE NewCarPrices
ADD Country NVARCHAR(255)

UPDATE NewCarPrices
SET Country = 
    CASE 
        WHEN state IN ('ab', 'on', 'qc', 'ns') THEN 'Canada'
        ELSE 'United States'
    END

CREATE TABLE CategorizedCar(
Year int,
Make NVARCHAR(255),
Body NVARCHAR (255),
Vin NVARCHAR(255),
State NVARCHAR(255),
Condition INT,
Odometer INT,
Color NVARCHAR(255),
MMR INT,
SellingPrice INT,
Seller NVARCHAR(255),
Saledate DATE,
Country NVARCHAR(255)
)

INSERT INTO CategorizedCar
SELECT year, make, body, vin, state, condition, odometer, color, mmr, sellingprice, saledate, Country
FROM NewCarPrices


SELECT make,
    CASE 
        WHEN make IN ('Dodge', 'Cadillac', 'Honda', 'Jeep', 'Subaru', 'Plymouth', 'Pontiac', 'HUMMER', 'Scion', 'Infiniti', 'Dodge', 'GMC', 'Volkswagen', 'Acura', 'Isuzu', 'Oldsmobile', 'Ford', 'Geo', 'Chevrolet', 'Buick', 'Saturn', 'Toyota', 'Mazda', 'Jaguar', 'Mercury', 'Chrysler', 'Daewoo', 'Lincoln', 'Ford', 'Ram', 'Audi') THEN 'American'
        WHEN make IN ('Maserati', 'Land Rover', 'Fisker', 'Volvo', 'Aston Martin', 'Mitsubishi', 'BMW', 'Mercedes', 'Porsche', 'Lotus', 'smart', 'Lamborghini', 'MINI', 'Rolls-Royce', 'Bentley', 'Lexus', 'Hyundai', 'Airstream', 'Mercedes-Benz', 'FIAT', 'VW', 'Mazda', 'Mercedes-Benz') THEN 'European'
        WHEN make IN ('Honda', 'Toyota', 'Nissan', 'Subaru', 'Mazda', 'Hyundai', 'Kia', 'Mitsubishi', 'Lexus', 'Acura', 'Infiniti', 'Isuzu', 'Suzuki', 'Daewoo') THEN 'Asian'
        ELSE 'Luxury'
    END AS category
FROM CategorizedCar;

ALTER TABLE CategorizedCar
ADD Category nvarchar(255)

UPDATE a
SET Category = CASE 
        WHEN make IN ('Dodge', 'Cadillac', 'Honda', 'Jeep', 'Subaru', 'Plymouth', 'Pontiac', 'HUMMER', 'Scion', 'Infiniti', 'Dodge', 'GMC', 'Volkswagen', 'Acura', 'Isuzu', 'Oldsmobile', 'Ford', 'Geo', 'Chevrolet', 'Buick', 'Saturn', 'Toyota', 'Mazda', 'Jaguar', 'Mercury', 'Chrysler', 'Daewoo', 'Lincoln', 'Ford', 'Ram', 'Audi') THEN 'American'
        WHEN make IN ('Maserati', 'Land Rover', 'Fisker', 'Volvo', 'Aston Martin', 'Mitsubishi', 'BMW', 'Mercedes', 'Porsche', 'Lotus', 'smart', 'Lamborghini', 'MINI', 'Rolls-Royce', 'Bentley', 'Lexus', 'Hyundai', 'Airstream', 'Mercedes-Benz', 'FIAT', 'VW', 'Mazda', 'Mercedes-Benz') THEN 'European'
        WHEN make IN ('Honda', 'Toyota', 'Nissan', 'Subaru', 'Mazda', 'Hyundai', 'Kia', 'Mitsubishi', 'Lexus', 'Acura', 'Infiniti', 'Isuzu', 'Suzuki', 'Daewoo') THEN 'Asian'
        ELSE 'Luxury'
    END
FROM CategorizedCar AS a 

/*Excellent (1-15), Good (16-30), Fair (31-45), Poor (46-49))*/

SELECT year, make, odometer, condition,
    CASE 
        WHEN condition BETWEEN 1 AND 15 THEN 'Poor'
		WHEN condition BETWEEN 16 AND 24 THEN 'Fair'
		WHEN condition BETWEEN 25 AND 39 THEN 'Good'
		WHEN condition BETWEEN 40 AND 49 THEN 'Excellent'
		ELSE 'Uknown'
    END AS 'Condition Categorized'
FROM CategorizedCar
WHERE condition BETWEEN 25 AND 39

ALTER TABLE CategorizedCar
ADD Condition_Categorized NVARCHAR(255)

UPDATE a
SET a.Condition_Categorized = 
  CASE WHEN a.condition BETWEEN 1 AND 15 THEN 'Poor'
       WHEN a.condition BETWEEN 16 AND 24 THEN 'Fair'
       WHEN a.condition BETWEEN 25 AND 39 THEN 'Good'
       WHEN a.condition BETWEEN 40 AND 49 THEN 'Excellent'
       ELSE 'Unknown' 
  END
FROM CategorizedCar AS a;

SELECT Condition_Categorized
FROM NewCarPrices
WHERE condition is NULL

ALTER TABLE CategorizedCar
ADD Basic_Colors NVARCHAR(255)

SELECT color, 
		CASE
		WHEN color IN ('black', 'charcoal') THEN 'Black'
        WHEN color IN ('blue', 'turquoise') THEN 'Blue'
        WHEN color IN ('green', 'lime') THEN 'Green'
        WHEN color IN ('yellow', 'gold') THEN 'Yellow'
        WHEN color IN ('red', 'burgundy') THEN 'Red'
        WHEN color IN ('silver', 'gray') THEN 'Gray'
        WHEN color IN ('white', 'off-white') THEN 'White'
		WHEN color IN ('orange') THEN 'Orange'
        WHEN color IN ('brown') THEN 'Brown'
        WHEN color IN ('purple') THEN 'Purple'
        WHEN color IN ('pink') THEN 'Pink'
		ELSE 'Uknown'
	END AS BC
FROM CategorizedCar

UPDATE a
SET Basic_Colors =
		CASE
		WHEN color IN ('black', 'charcoal') THEN 'Black'
        WHEN color IN ('blue', 'turquoise') THEN 'Blue'
        WHEN color IN ('green', 'lime') THEN 'Green'
        WHEN color IN ('yellow', 'gold') THEN 'Yellow'
        WHEN color IN ('red', 'burgundy') THEN 'Red'
        WHEN color IN ('silver', 'gray') THEN 'Gray'
        WHEN color IN ('white', 'off-white') THEN 'White'
		WHEN color IN ('orange') THEN 'Orange'
        WHEN color IN ('brown') THEN 'Brown'
        WHEN color IN ('purple') THEN 'Purple'
        WHEN color IN ('pink') THEN 'Pink'
		ELSE 'Uknown'
	END 
FROM CategorizedCar AS a 

ALTER TABLE CategorizedCar
ADD Body_Type NVARCHAR(255)

UPDATE a
SET Body_Type = 
		CASE 
        WHEN body IN ('E-Series Van', 'Ram Van', 'Transit Van', 'Promaster Cargo Van', 'Van') THEN 'Van'
        WHEN body IN ('Minivan', 'Club Cab', 'Crew Cab', 'SuperCab', 'Regular Cab', 'Cab Plus', 'CrewMax Cab', 'King Cab', 'Access Cab', 'Quad Cab', 'Mega Cab', 'Double Cab', 'Xtracab', 'Cab Plus 4', 'SuperCrew', 'regular-cab', 'extended cab') THEN 'Truck'
        WHEN body IN ('SUV') THEN 'SUV'
        WHEN body IN ('Convertible', 'Beetle Convertible', 'GranTurismo Convertible') THEN 'Convertible'
        WHEN body IN ('Coupe', 'CTS Coupe', 'Q60 Coupe', 'Genesis Coupe', 'CTS-V Coupe', 'Koup', 'G37 Coupe', 'G Coupe', 'Elantra Coupe', 'G Convertible', 'Q60 Convertible', 'G37 Convertible') THEN 'Coupe'
        WHEN body IN ('CTS-V Wagon', 'Wagon', 'CTS Wagon', 'TSX Sport Wagon') THEN 'Wagon'
		WHEN body IN ('Sedan', 'G Sedan') THEN 'Sedan'
        WHEN body IN ('Hatchback') THEN 'Hatchback'
        ELSE 'Uknown'
		END
FROM CategorizedCar AS a

ALTER TABLE CategorizedCar
ADD Seller NVARCHAR(255)

UPDATE a
SET Seller = b.seller
FROM CategorizedCar AS a 
JOIN NewCarPrices AS b
ON a.vin = b.vin



