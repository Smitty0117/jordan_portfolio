#Beginning Queries - US Household Income Data Cleaning

SELECT * 
FROM us_household_income;

SELECT *  
FROM us_household_income_statistics;
-- ID column name did not properly import

ALTER TABLE us_household_income_statistics
RENAME COLUMN `ï»¿id` TO `ID`;

# Data Cleaning Process
SELECT ID, COUNT(ID)  
FROM us_household_income
GROUP BY ID
HAVING COUNT(ID) > 1;
-- Duplicates identified = 6 IDs

DELETE FROM us_household_income
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id, 
        ID, 
        ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) row_num
		FROM us_household_income) duplicates
	WHERE row_num > 1
	);
    
SELECT ID, COUNT(ID)  
FROM us_household_income_statistics
GROUP BY ID
HAVING COUNT(ID) > 1;
-- No duplicates in this table

SELECT DISTINCT State_Name
FROM us_household_income
GROUP BY State_Name;
-- Typo for Georgia entry 'georia'
-- Alabama standardization from 'alabama'

UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';

SELECT *
FROM us_household_income
WHERE Place = ''
ORDER BY 1;
-- 1 Null Place -> Deduced all but one record with the same county had a place of 'Autaugaville'

UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont';


SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY Type;

UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';

SELECT ALand, AWater 
FROM us_household_income
WHERE (AWater = 0 OR AWater = '' OR AWater IS NULL)
AND (ALand = 0 OR ALand = '' OR ALand IS NULL);
-- No dirty data where both values are 0
