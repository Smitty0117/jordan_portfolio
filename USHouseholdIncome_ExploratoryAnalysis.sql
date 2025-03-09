# US Household Income Exploratory Analysis

SELECT * 
FROM us_household_income;

SELECT *  
FROM us_household_income_statistics;



SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10;
-- Dig into top states by Land & Water areas


SELECT * 
FROM us_household_income u
INNER JOIN us_household_income_statistics us 
	ON u.ID = s.ID
WHERE u.Mean <> 0;



SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income u
INNER JOIN us_household_income_statistics us 
	ON u.ID = us.ID
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 2 DESC
LIMIT 5;
-- Dig into top 5 and bottom 5 average incomes by state


SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income u
INNER JOIN us_household_income_statistics us 
	ON u.ID = us.ID
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 4 DESC
LIMIT 20;
-- Outliers: Municipality (1), CPD (2), County(2), Urban (8), Community (17)
-- Community is the lowest avg income -> Query location record


SELECT *
FROM us_household_income
WHERE Type = 'Community';
-- Every record is recorded from Puerto Rico


SELECT u.State_Name, u.City, ROUND(AVG(Mean),1)
FROM us_household_income u
JOIN us_household_income_statistics us
	ON u.ID = us.ID
GROUP BY u.City, u.State_Name
ORDER BY 3 DESC;
-- Large cities were not seen in the top avg income records