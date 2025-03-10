#SmartWatch Data Cleaning
SELECT *
FROM unclean_smartwatch_health_data_auto -- original table name
LIMIT 1000;

/* Initial impressions: 
1. Rename columns to query-friendly headers
2. Investigate NULLs -- convert blanks to NULLs
3. Check prevalence of duplicates
4. Standardize the records decimals
*/

# 1 - Rename columns to query-friendly headers
ALTER TABLE unclean_smartwatch_health_data_auto
RENAME COLUMN `User ID` TO `user_id`,
RENAME COLUMN `Heart Rate (BPM)` TO `heart_rate`,
RENAME COLUMN `Blood Oxygen Level (%)` TO `blood_oxygen`,
RENAME COLUMN `Step Count` TO `step_count`,
RENAME COLUMN `Sleep Duration (hours)` TO `sleep_duration`,
RENAME COLUMN `Activity Level` TO `activity_level`,
RENAME COLUMN `Stress Level` TO `stress_level`;

RENAME TABLE unclean_smartwatch_health_data_auto TO clean_smartwatch_data;

#2 & #3 - Convert blanks to NULL & Check prevalence of duplicates
SELECT *
FROM clean_smartwatch_data
WHERE user_id IS NULL;
-- No NULLs within the data

SELECT *
FROM clean_smartwatch_data
WHERE user_id = '';
-- Blanks present in user_id - check for duplicates before assigning id or dropping

SELECT user_id, COUNT(user_id)
FROM clean_smartwatch_data
GROUP BY user_id
HAVING COUNT(user_id) > 1;
-- 191 blank UserIDs & many duplicate entries
-- Start by dropping the blank user_ids

DELETE FROM clean_smartwatch_data
WHERE user_id = '';
-- 191 records deleted per the Transaction History

SELECT COUNT(*) AS count_1_record
FROM (
		SELECT user_id
        FROM clean_smartwatch_data
        GROUP BY user_id
        HAVING COUNT(*) = 1
	) AS num_single_count;
/* 
Will keep duplicate records because there are more ids with duplicates than not; 
2641 (not inclusive of total num of duplicates) vs 935
*/

SELECT *
FROM clean_smartwatch_data 
WHERE heart_rate = '';
-- heart_rate, sleep_duration still have blank values

UPDATE clean_smartwatch_data
SET heart_rate = NULL
WHERE heart_rate = '';

UPDATE clean_smartwatch_data
SET sleep_duration = NULL
WHERE sleep_duration = '';

UPDATE clean_smartwatch_data
SET sleep_duration = NULL
WHERE sleep_duration = 'ERROR';
/*
With the presence of blanks ('') and 'ERROR'... 
could have done this in one UPDATE statement, but noticed the ERRORs after the fact
*/

SELECT activity_level, COUNT(activity_level)
FROM clean_smartwatch_data
GROUP BY activity_level;
/* Activity status updates: 
'Highly_Active' -> 'Highly Active'
'Seddentary' -> 'Sedentary'
'Actve' -> 'Active'
'nan' -> NULL
*/


UPDATE clean_smartwatch_data
SET activity_level = 'Highly Active'
WHERE activity_level = 'Highly_Active';

UPDATE clean_smartwatch_data
SET activity_level = 'Sedentary'
WHERE activity_level = 'Seddentary';

UPDATE clean_smartwatch_data
SET activity_level = 'Active'
WHERE activity_level = 'Actve';

UPDATE clean_smartwatch_data
SET activity_level = NULL
WHERE activity_level = 'nan';

#4 - Standardize the records decimals
SELECT *
FROM clean_smartwatch_data;

UPDATE clean_smartwatch_data
SET heart_rate = ROUND(heart_rate,2)
WHERE heart_rate IS NOT NULL;

UPDATE clean_smartwatch_data
SET blood_oxygen = ROUND(blood_oxygen,2)
WHERE blood_oxygen IS NOT NULL;

UPDATE clean_smartwatch_data
SET step_count = ROUND(step_count,2)
WHERE step_count IS NOT NULL;

UPDATE clean_smartwatch_data
SET sleep_duration = ROUND(sleep_duration,2)
WHERE sleep_duration IS NOT NULL;
-- Now I will standardize the table columns to store as 2 decimals (for trailing 0 formatting)

ALTER TABLE clean_smartwatch_data
MODIFY heart_rate DECIMAL(10,2),
MODIFY blood_oxygen DECIMAL(10,2),
MODIFY step_count DECIMAL(10,2),
MODIFY sleep_duration DECIMAL(10,2);

SELECT *
FROM clean_smartwatch_data;
